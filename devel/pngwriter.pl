#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
# use blib "$ENV{HOME}/perl/image/Image-PNGwriter-0.01/blib";

{
  require Image::PNGwriter;
  my $pw = Image::PNGwriter->new(1,1,
                                 0,
                                 '/dev/null');
  $pw->setcompressionlevel(9);
  $pw->square(5,5, 7,7, 1,1,1);
  #  $pw->resize (9,9);
  $pw->pngwriter_rename ('/tmp/x.png');
  $pw->write_png;

  {
    require Image::ExifTool;
    my $info = Image::ExifTool::ImageInfo ('/tmp/x.png');
    require Data::Dumper;
    print Data::Dumper->new([\$info],['info'])->Dump;
  }
  print "done\n";
  exit 0;
}
{
  my $class;
  $class = 'Image::Xpm';
  $class = 'Image::Base::PNGwriter';
  eval "require $class" or die;
  my $image = $class->new (-width  => 10,
                           -height => 10,
                           -author => 'Some Body');
  $image->rectangle (0,0, 5,5, '#FF00FF');
  $image->line (0,0, 5,5, '#FF00FF');
  $image->save ('/tmp/x.png');
  exit 0;
}

{
  require Image::PNGwriter;
  print Image::PNGwriter->VERSION,"\n";
  print Image::PNGwriter->version,"\n";
  my $pw = Image::PNGwriter->new(10,10,
                                        0,
                                        '/tmp/nosuchdir/x.png');
  $pw->square(5,5, 7,7, 1,1,1);
  print $pw->dread(6,6, 1),"\n";
  $pw->write_png;
  print "done\n";
  exit 0;
}
{
  require Image::PNGwriter;
  my $pw = Image::PNGwriter->new(10,10,
                                        0,
                                        '/tmp/x.png');
  $pw->plot(1,1, 0x11, 0x22, 0x33);
  print $pw->dread(1,1, 0),"\n";
  print $pw->dread(1,1, 1),"\n";
  print $pw->dread(1,1, 2),"\n";
  print $pw->dread(1,1, 3),"\n";
  $pw->write_png;
  exit 0;
}
{
  require Image::PNGwriter;
  my $filename = '/tmp/zz.png';
  my $pw = Image::PNGwriter->new (100,100, 0, $filename);
  $pw->pngwriter_rename($filename);
  substr ($filename,5,2, 'WW');
  $pw->write_png;
  print $filename,"\n";
  exit 0;
}
{
  require Image::PNGwriter;
  my $pw = Image::PNGwriter->new(100,100,
                                        0,
                                        '/tmp/zz.png');
  $pw->readfromfile ('/tmp/x.png');
  # $pw->filledsquare(10,10, 20,20, 255,255,255);
  $pw->write_png;
  exit 0;
}
