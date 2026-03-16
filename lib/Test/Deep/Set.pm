use strict;
use warnings;

package Test::Deep::Set;

use Test::Deep::Cmp;

sub init
{
  my $self = shift;

  $self->{IgnoreDupes} = shift;
  $self->{SubSup} = shift;

  $self->{val} = [];

  $self->add(@_);
}

sub descend
{
  my $self = shift;
  my $d1 = shift;

  my $d2 = $self->{val};

  my $IgnoreDupes = $self->{IgnoreDupes};

  my $data = $self->data;

  my $SubSup = $self->{SubSup};

  my $type = $IgnoreDupes ? "Set" : "Bag";

  my $diag;

  if (ref $d1 ne 'ARRAY')
  {
    my $got = Test::Deep::render_val($d1);
    $diag = <<EOM;
got    : $got
expect : An array to use as a $type
EOM
  }

  if (not $diag)
  {
    my @got = @$d1;
    my @found;
    my @missing;
    foreach my $expect (@$d2)
    {
      my $found = 0;

      for (my $i = $#got; $i >= 0; $i--)
      {
        if (Test::Deep::eq_deeply_cache($got[$i], $expect))
        {
          $found = 1;
          push(@found, $expect);
          splice(@got, $i, 1);

          last unless $IgnoreDupes;
        }
      }

      push(@missing, $expect) unless $found;
    }

    my @diags;
    if (@missing and $SubSup ne "sub" && $SubSup ne "none")
    {
      push(@diags, "Missing: ".nice_list(\@missing));
    }

    if (@got and $SubSup ne "sup" && $SubSup ne "none")
    {
      my $got = __PACKAGE__->new($IgnoreDupes, "", @got);
      push(@diags, "Extra: ".nice_list($got->{val}));
    }

    if (@found and $SubSup eq "none")
    {
      my $found = __PACKAGE__->new($IgnoreDupes, "", @found);
      push(@diags, "Extra: ".nice_list($found->{val}));
    }

    $diag = join("\n", @diags);
  }

  if ($diag)
  {
    $data->{diag} = $diag;

    return 0;
  }
  else
  {
    return 1;
  }
}

sub diagnostics
{
  my $self = shift;
  my ($where, $last) = @_;

  my $type = $self->{IgnoreDupes} ? "Set" : "Bag";
  $type = "Sub$type" if $self->{SubSup} eq "sub";
  $type = "Super$type" if $self->{SubSup} eq "sup";
        $type = "NoneOf" if $self->{SubSup} eq "none";

  my $error = $last->{diag};
  my $diag = <<EOM;
Comparing $where as a $type
$error
EOM

  return $diag;
}

sub _is_cmp {
  my ($value) = @_;
  return unless Scalar::Util::blessed($value);
  return $value->isa('Test::Deep::Cmp');
}

sub add
{
  # this takes an array.

  # For each element A of the array, it looks for an element, B, already in
  # the set which are deeply equal to A. If no matching B is found then A is
  # added to the set. If a B is found and IgnoreDupes is true, then A will
  # be discarded, if IgnoreDupes is false, then B will be added to the set
  # again.

  my $self = shift;

  my @array = @_;

  my $IgnoreDupes = $self->{IgnoreDupes};

  my $already = $self->{val};

  local $Test::Deep::Expects = 1;
  foreach my $new_elem (@array)
  {
    my $want_push = 1;
    my $push_this = $new_elem;

    # Say you've written this:
    #
    #   set(1,2,2,3,4)
    #
    # You want the actual values stored to be (1,2,3,4).  What, though, if you
    # wrote this:
    #
    #   set(re($x), re($y));
    #
    # It's hard to say!  The two re() objects (Test::Deep::Regexp objects) will
    # be distinct objects.  Their wrapped patterns *may* be the same (if $x and
    # $y refer to the same qr object).  At some level, the equivalence of two
    # tests can't be decided.  Meanwhile, eq_deeply (used below, although rjbs
    # thinks it's possibly a bad choice) will end up testing one test object
    # against the other's test.  This is madness, as demonstrated by the case
    # that brought this up:
    #
    #   set(qr{1}, qr{2});
    #
    # If the refaddr of the first item has a 2 in it, we will end up with a set
    # containing only the first item.  So, to avoid this, we will never
    # deduplicate Test::Deep::Cmp objects, meaning that all this commentary
    # just explains why the foreach below is wrapped in this unless:
    unless (_is_cmp($new_elem))
    {
      foreach my $old_elem (@$already)
      {
        if (Test::Deep::eq_deeply($new_elem, $old_elem))
        {
          $push_this = $old_elem;
          $want_push = ! $IgnoreDupes;
          last;
        }
      }
    }

    push(@$already, $push_this) if $want_push;
  }

  # so we can compare 2 Test::Deep::Set objects using array comparison

  @$already = sort {(defined $a ? $a : "") cmp (defined $b ? $b : "")} @$already;
}

sub nice_list
{
  my $list = shift;

  my @scalars = grep ! ref $_, @$list;
  my $refs = grep ref $_, @$list;

  my @ref_string = "$refs reference" if $refs;
  $ref_string[0] .= "s" if $refs > 1;

  # sort them so we can predict the diagnostic output

  return join(", ",
    (map {Test::Deep::render_val($_)} sort {(defined $a ? $a : "") cmp (defined $b ? $b : "")} @scalars),
    @ref_string
  );
}

sub compare
{
  my $self = shift;

  my $other = shift;

  return 0 if $self->{IgnoreDupes} != $other->{IgnoreDupes};

  # this works (kind of) because the arrays are sorted

  return Test::Deep::descend($self->{val}, $other->{val});
}

1;
