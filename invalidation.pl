#!/usr/bin/perl

use utf8;
binmode STDOUT,"utf8";
use open ":utf8";

use warnings;
use strict;

use JSON::XS qw/encode_json/;
use File::Temp qw/tempfile/;
use File::Slurp::Tiny qw/read_file/;

sub batch_json{
  my @items = @_;

  return encode_json {
    'Paths' => {
      'Quantity' => 5,
      'Items' => @items
    },
    'CallerReference' => time
  }
}

sub cf_cmd{
  my ($distribution_id, $batch_json_path) = @_;

  my $command = 
    "aws cloudfront create-invalidation " .
    "--distribution-id $distribution_id " .
    "--invalidation-batch file://$batch_json_path";
  return $command;
}

sub tmpfile{
  my $str = shift;
  my ($fh, $filename) = tempfile(UNLINK => 1, SUFFIX => '.json');
  print $fh $str;
  close $fh;
  return $filename;
}

sub pfile{
  my $filename = shift;
  print read_file($filename);
  print "\n";
}

sub main{
  my $distribution_id = shift @ARGV;
  my @paths = \@ARGV;

  my $batch_json_path = &tmpfile(&batch_json(@paths));

  &pfile($batch_json_path);
  my $command = &cf_cmd($distribution_id, $batch_json_path);
  print $command;
}

&main;
