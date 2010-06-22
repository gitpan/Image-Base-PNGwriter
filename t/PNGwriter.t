#!/usr/bin/perl

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You can get a copy of the GNU General Public License online at
# http://www.gnu.org/licenses.

use 5.010;
use strict;
use warnings;
use Test::More tests => 46;

BEGIN {
 SKIP: { eval 'use Test::NoWarnings; 1'
           or skip 'Test::NoWarnings not available', 1; }
}

require Image::Base::PNGwriter;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 1;
  is ($Image::Base::PNGwriter::VERSION, $want_version, 'VERSION variable');
  is (Image::Base::PNGwriter->VERSION,  $want_version, 'VERSION class method');

  ok (eval { Image::Base::PNGwriter->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Image::Base::PNGwriter->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $image = Image::Base::PNGwriter->new (-pngwriter => 'dummy');
  is ($image->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $image->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $image->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# colour_to_rgb

{
  my $image = Image::Base::PNGwriter->new (-pngwriter => 'dummy');
  foreach my $elem (['#FF00FF', [1.0, 0.0, 1.0] ],
                    ['black', [0,0,0] ],
                    ['white', [1,1,1] ],
                   ) {
    my ($colour, $want) = @$elem;
    is_deeply ([$image->colour_to_drgb ($colour)],
               $want,
               "colour_to_drgb '$colour'");
  }
}

#------------------------------------------------------------------------------
# new()

{
  my $image = Image::Base::PNGwriter->new (-width => 1,
                                           -height => 1);
  is ($image->get('-file'), undef);
  is ($image->get('-zlib_compression'), -1);
  isa_ok ($image, 'Image::Base');
  isa_ok ($image, 'Image::Base::PNGwriter');

  $image->set(-zlib_compression => 7);
  is ($image->get('-zlib_compression'), 7);

  $image->set(-file => 'PNGwriter-test.tmp');
  is ($image->get('-file'),  'PNGwriter-test.tmp');
}

#------------------------------------------------------------------------------
# save() / load()

my $have_File_Temp = eval { require File::Temp; 1 };
if (! $have_File_Temp) {
  diag "File::Temp not available: $@";
}

SKIP: {
  $have_File_Temp
    or skip 'File::Temp not available', 6;

  my $fh = File::Temp->new;
  my $filename = $fh->filename;

  # save file
  {
    my $image = Image::Base::PNGwriter->new (-width => 1,
                                                             -height => 1);
    $image->xy (0,0, '#FFFFFF');
    $image->set(-file => $filename,
                -zlib_compression => 1);
    is ($image->get('-file'), $filename);
    $image->save;
    cmp_ok (-s $filename, '>', 0);
  }

  # existing file with new(-file)
  {
    my $image = Image::Base::PNGwriter->new (-width => 1,
                                                             -height => 1,
                                                             -file => $filename);
    is ($image->get('-file'), $filename);
    is ($image->xy (0,0), '#FFFFFF');
  }

  # existing file with load()
  {
    my $image = Image::Base::PNGwriter->new (-width => 1,
                                                             -height => 1);
    $image->load ($filename);
    is ($image->get('-file'), $filename);
    is ($image->xy (0,0), '#FFFFFF');
  }
}


#------------------------------------------------------------------------------
# xy

{
  my $image = Image::Base::PNGwriter->new (-width => 20,
                                                           -height => 10);
  $image->xy (0,0, '#112233');
  $image->xy (1,1, '#445566');
  is ($image->xy (0,0), '#112233');
  is ($image->xy (1,1), '#445566');
}

#------------------------------------------------------------------------------
# rectangle

{
  my $image = Image::Base::PNGwriter->new (-width => 20,
                                                           -height => 10);
  $image->rectangle (5,5, 7,7, '#FFFFFF', 0);
  is ($image->xy (5,5), '#FFFFFF');
  is ($image->xy (6,6), '#000000');
  is ($image->xy (7,6), '#FFFFFF');
  is ($image->xy (8,8), '#000000');
}
{
  my $image = Image::Base::PNGwriter->new (-width => 20,
                                                           -height => 10);
  $image->rectangle (0,0, 2,2, '#FFFFFF', 1);
  is ($image->xy (0,0), '#FFFFFF');
  is ($image->xy (1,1), '#FFFFFF');
  is ($image->xy (2,1), '#FFFFFF');
  is ($image->xy (3,3), '#000000');
}

#------------------------------------------------------------------------------
# line

{
  my $image = Image::Base::PNGwriter->new (-width => 20,
                                                           -height => 10);
  $image->line (5,5, 8,8, '#FFFFFF', 0);
  is ($image->xy (4,4), '#000000');
  is ($image->xy (5,5), '#FFFFFF');
  is ($image->xy (5,6), '#000000');
  is ($image->xy (6,6), '#FFFFFF');
  is ($image->xy (7,7), '#FFFFFF');
  is ($image->xy (8,8), '#FFFFFF');
  is ($image->xy (9,9), '#000000');
}
{
  my $image = Image::Base::PNGwriter->new (-width => 20,
                                                           -height => 10);
  $image->line (0,0, 2,2, '#FFFFFF', 1);
  is ($image->xy (0,0), '#FFFFFF');
  is ($image->xy (1,1), '#FFFFFF');
  is ($image->xy (2,1), '#000000');
  is ($image->xy (3,3), '#000000');
}

#------------------------------------------------------------------------------
# get -file

{
  my $image = Image::Base::PNGwriter->new (-width => 10,
                                                           -height => 10);
  is (scalar ($image->get ('-file')), undef);
  is_deeply  ([$image->get ('-file')], [undef]);
}

exit 0;
