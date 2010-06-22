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


package Image::Base::PNGwriter;
# Image::PNGwriter 0.01 requires 5.8.5, no need to go back earlier than it,
# though seems it could probably go earlier, depending perhaps what new
# enough xsubpp can do C++
use 5.004;
use strict;
use warnings;
use Carp;
use File::Spec 0.8;  # version 0.8 in perl 5.6 for ->devnull()
use Image::PNGwriter;
use base 'Image::Base';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 1;

use constant _DEFAULT_PALETTE => { 'black' => [ 0,0,0 ],
                                   'white' => [ 1,1,1 ] };

sub new {
  my ($class, %params) = @_;
  ### Image-Base-PNGwriter new(): %params

  # -palette not yet documented
  my $self = bless { -palette => _DEFAULT_PALETTE,
                     -zlib_compression => -1 }, $class;
  if (! defined $params{'-pngwriter'}) {
    my $width = delete $params{'-width'};
    if (! defined $width) { $width = 1; }
    my $height = delete $params{'-height'};
    if (! defined $height) { $height = 1; }
    my $pw = $self->{'-pngwriter'}
      = Image::PNGwriter->new ($width, $height,
                               0,  # background
                               File::Spec->devnull);
    $pw->pngwriter_rename ('');
  }
  my $filename = delete $params{'-file'};

  $self->set (%params);

  if (defined $filename) {
    $self->load ($filename);
  }
  return $self;
}

my %attr_to_get_method = (-width     => 'getwidth',
                          -height    => 'getheight',
                          # these not documented yet ...
                          -bitdepth  => 'getbitdepth',
                          -gamma     => 'getgamma',
                          -colortype => 'getcolortype');
sub _get {
  my ($self, $key) = @_;
  if (my $method = $attr_to_get_method{$key}) {
    return $self->{'-pngwriter'}->$method;
  }
  return $self->SUPER::_get ($key);
}

sub set {
  my ($self, %params) = @_;

  if (exists $params{'-pngwriter'}) {
    $self->{'-pngwriter'} = delete $params{'-pngwriter'};
    delete $self->{'-file'};
    delete $self->{'-zlib_compression'};
    delete $self->{'-title'};
    delete $self->{'-author'};
    delete $self->{'-description'};
    delete $self->{'-software'};
  }

  if (exists $params{'-width'} || exists $params{'-height'}) {
    my $width = (exists $params{'-width'}
                 ? delete $params{'-width'}
                 : $self->{'-pngwriter'}->getwidth);
    my $height = (exists $params{'-height'}
                  ? delete $params{'-height'}
                  : $self->{'-pngwriter'}->getheight);
    $self->{'-pngwriter'}->resize ($width, $height);
  }

  # not documented, yet ...
  if (exists $params{'-gamma'}) {
    $self->{'-pngwriter'}->setgamma (delete $params{'-gamma'});
  }

  %$self = (%$self, %params);

  if (exists $params{'-file'}) {
    $self->{'-pngwriter'}->pngwriter_rename ($params{'-file'});
  }
  if (exists $params{'-zlib_compression'}) {
    $self->{'-pngwriter'}->setcompressionlevel ($params{'-zlib_compression'});
  }

  # not documented yet ...
  if (exists $params{'-title'} || exists $params{'-author'} || exists $params{'-description'} || exists $params{'-software'}) {
    $self->{'-pngwriter'}->settext
      (map {defined $params{$_} ? $params{$_} : ''} '-title', '-author', '-description', '-software');
  }
}

sub load {
  my ($self, $filename) = @_;
  if (@_ == 1) {
    $filename = $self->get('-file');
  } else {
    $self->set('-file', $filename);
  }
  $self->{'-pngwriter'}->readfromfile ($filename);
}
sub save {
  my ($self, $filename) = @_;
  if (@_ == 2) {
    $self->set('-file', $filename);
  }
  $self->{'-pngwriter'}->write_png;
}

sub xy {
  my ($self, $x, $y, $colour) = @_;
  my $pw = $self->{'-pngwriter'};
  $x++;
  $y = $pw->getheight - $y;
  if (@_ == 4) {
    ### plot: $x, $y, $self->colour_to_drgb($colour)
    $pw->plot ($x, $y, $self->colour_to_drgb($colour));
  } else {
    ### dread: $x, $y, $pw->dread($x,$y,1), $pw->dread($x,$y,2), $pw->dread($x,$y,3)
    return sprintf ('#%02X%02X%02X',
                    map {int (255 * $pw->dread($x,$y,$_) + 0.5)} 1,2,3);
  }
}
sub line {
  my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
  my $pw = $self->{'-pngwriter'};
  my $h = $pw->getheight;
  $pw->line ($x1+1, $h-$y1,
             $x2+1, $h-$y2,
             $self->colour_to_drgb($colour));
}
sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;
  ### Image-Base-PNGwriter rectangle(): $x1, $y1, $x2, $y2, $colour, $fill
  my $pw = $self->{'-pngwriter'};
  my $h = $pw->getheight;
  my $method = ($fill ? 'filledsquare' : 'square');
  $pw->$method ($x1+1, $h-$y1,
                $x2+1, $h-$y2,
                $self->colour_to_drgb($colour));
}

# only $pw->circle available, apparently
# sub ellipse {
#   my ($self, $x1, $y1, $x2, $y2, $colour) = @_;
# }

# not documented, yet ...
sub colour_to_drgb {
  my ($self, $colour) = @_;
  if (exists $self->{'-palette'}->{$colour}) {
    $colour = $self->{'-palette'}->{$colour};
  }
  if (ref $colour) {
    return @$colour;
  }
  if (my ($r, $g, $b) = ($colour =~ /^#([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})$/i)) {
    return hex($r) / 255, hex($g) / 255, hex($b) / 255;
  }
  croak "Unknown colour: $colour";
}

1;
__END__

=for stopwords PNG pngwriter filename undef Ryde Zlib Image::Base::PNGwriter Image::PNGwriter

=head1 NAME

Image::Base::PNGwriter -- draw PNG format images

=head1 SYNOPSIS

 use Image::Base::PNGwriter;
 my $image = Image::Base::PNGwriter->new (-width => 100,
                                          -height => 100);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');
 $image->save ('/some/filename.png');

=head1 CLASS HIERARCHY

C<Image::Base::PNGwriter> is a subclass of C<Image::Base>,

    Image::Base
      Image::Base::PNGwriter

=head1 DESCRIPTION

C<Image::Base::PNGwriter> extends C<Image::Base> to create or update PNG
format image files using the C<Image::PNGwriter> module and pngwriter
library.

There's no colour name database as yet, only "black", "white" and two digit
hex "#RRGGBB".

As per C<Image::Base>, coordinates are from 0,0 for the top-left corner.
(The underlying pngwriter library is 1,1 as the bottom-left but
C<Image::Base::PNGwriter> converts.)

=head1 FUNCTIONS

=over 4

=item C<$image = Image::Base::PNGwriter-E<gt>new (key=E<gt>value,...)>

Create and return an image object.  A new image can be started with
C<-width> and C<-height>,

    $image = Image::Base::PNGwriter->new (-width => 200,
                                          -height => 100);

Or an existing file can be read,

    $image = Image::Base::PNGwriter->new
                 (-file => '/some/filename.png');

Or an C<Image::PNGwriter> object can be given,

    $image = Image::Base::PNGwriter->new (-pngwriter => $pwobj);

=back

=head1 ATTRIBUTES

The following attributes can be C<get> and C<set>.

=over

=item C<-file> (string filename)

The file to load in a C<new>, and the default filename for subsequent
C<save> or C<load>.

=item C<-width> (integer)

=item C<-height> (integer)

Setting these changes the size of the image, but also clears it to all
black.  The image must be at least 1x1 pixels.

=item C<-zlib_compression> (integer 0-9 or -1)

The amount of data compression to apply when saving.  The value is Zlib
style 0 for no compression up to 9 for maximum effort.  -1 means Zlib's
default level.

=item C<-pngwriter> (C<Image::PNGwriter> object)

The underlying C<Image::PNGwriter> object in use.

Because filename and compression level can't be read out of a pngwriter
object, if you set C<-pngwriter> then a C<get> of the C<-file> or
C<-zlib_compression> will return C<undef>, and there's no default filename
for C<load>.  A C<save> will use the filename and compression in the object
though.  Perhaps this will improve in the future.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Image::Base::GD>,
L<Image::PNGwriter>

=head1 HOME PAGE

http://user42.tuxfamily.org/image-base-pngwriter/index.html

=head1 LICENSE

Image-Base-PNGwriter is Copyright 2010 Kevin Ryde

Image-Base-PNGwriter is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Image-Base-PNGwriter is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Image-Base-PNGwriter.  If not, see <http://www.gnu.org/licenses/>.

=cut
