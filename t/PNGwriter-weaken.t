#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Image-Base-PNGwriter.
#
# Image-Base-PNGwriter is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Image-Base-PNGwriter is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Image-Base-PNGwriter.  If not, see <http://www.gnu.org/licenses/>.

use 5.006;
use strict;
use warnings;
use Test::More;
use Image::Base::PNGwriter;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

eval "use Test::Weaken 2.000; 1"
  or plan skip_all => "due to Test::Weaken 2.000 not available -- $@";
diag ("Test::Weaken version ", Test::Weaken->VERSION);

# version 1.18 for pure-perl refaddr() fix, maybe
eval "use Scalar::Util 1.18 'refaddr'; 1"
  or plan skip_all => "due to Scalar::Util 1.18 not available -- $@";

plan tests => 1;

sub my_ignore {
  my ($ref) = @_;
  return (refaddr($ref) == refaddr(Image::Base::PNGwriter::_DEFAULT_PALETTE));
}

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub { return Image::Base::PNGwriter->new
                              (-width => 6, -height => 7);
                          },
       ignore => \&my_ignore,
     });
  is ($leaks, undef, 'deep garbage collection');
  MyTestHelpers::test_weaken_show_leaks($leaks);
}

exit 0;
