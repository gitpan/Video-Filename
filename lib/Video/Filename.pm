# Copyright (c) 2008 Behan Webster. All rights reserved. This program is free
# software; you can redistribute it and/or modify it under the same terms
# as Perl itself.

package Video::Filename;

use strict;
require Exporter;

use Debug::Simple;
use Data::Dumper;
use Term::ANSIColor qw(:constants);
use Text::Roman qw(roman2int);
$Term::ANSIColor::AUTORESET = 1;

use vars qw($VERSION @filePatterns);

$VERSION = "0.33";

@filePatterns = (
	{ # DVD Episode Support - DddEee
		# Perl > v5.10
		re => '^(?:(?<name>.*?)[\/\s._-]+)?(?:d|dvd|disc|disk)[\s._]?(?<dvd>\d{1,2})[x\/\s._-]*(?:e|ep|episode)[\s._]?(?<episode>\d{1,2})(?:-?(?:(?:e|ep)[\s._]*)?(?<endep>\d{1,2}))?(?:[\s._]?(?:p|part)[\s._]?(?<part>\d+))?(?<subep>[a-z])?(?:[\/\s._-]*(?<epname>[^\/]+?))?$',

		# Perl < v5.10
		re_compat => '^(?:(.*?)[\/\s._-]+)?(?:d|dvd|disc|disk)[\s._]?(\d{1,2})[x\/\s._-]*(?:e|ep|episode)[\s._]?(\d{1,2})(?:-?(?:(?:e|ep)[\s._]*)?(\d{1,2}))?(?:[\s._]?(?:p|part)[\s._]?(\d+))?([a-z])?(?:[\/\s._-]*([^\/]+?))?$',
		keys_compat => [qw(name dvd episode endep part subep epname)],

		test_keys => [qw(filename name dvd episode endep part subep epname ext)],
		test => [
			['D01E02.Episode_name.avi', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.D01E02.Episode_name.avi', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/D01E02.Episode_name.avi', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/D01E02/Episode_name.avi', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.D01E02a.Episode_name.avi', 'Series Name', 1, 2, undef, undef, 'a', 'Episode_name', 'avi'],
			['Series Name.D01E02p4.Episode_name.avi', 'Series Name', 1, 2, undef, 4, undef, 'Episode_name', 'avi'],
			['Series Name.D01E02-03.Episode_name.avi', 'Series Name', 1, 2, 3, undef, undef, 'Episode_name', 'avi'],
			['Series Name.D01E02-E03.Episode_name.avi', 'Series Name', 1, 2, 3, undef, undef, 'Episode_name', 'avi'],
			['Series Name.D01E02E.03.Episode_name.avi', 'Series Name', 1, 2, 3, undef, undef, 'Episode_name', 'avi'],
			['Series Name/D01E02E03/Episode_name.avi', 'Series Name', 1, 2, 3, undef, undef, 'Episode_name', 'avi'],
			['D01E02E03/Episode name.avi', undef, 1, 2, 3, undef, undef, 'Episode name', 'avi'],
			['Series Name.DVD_01.Episode_02.Episode_name.avi', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.disk_V.Episode_XI.Episode_name.avi', 'Series Name', 5, 11, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.disc_V.Episode_XI.Part.XXV.Episode_name.avi', 'Series Name', 5, 11, undef, 25, undef, 'Episode_name', 'avi'],
			['Series Name.DVD01.Ep02.Episode_name.avi', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/dvd_01.Episode_02.Episode_name.avi', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/disk_01/Episode_02.Episode_name.avi', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/D.I/Ep02.Episode_name.avi', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/D three/Ep five Episode_name.avi', 'Series Name', 3, 5, undef, undef, undef, 'Episode_name', 'avi'],
		],
	},
	{ # TV Show Support - SssEee
		# Perl > v5.10
		re => '^(?:(?<name>.*?)[\/\s._-]+)?(?:(?:s|se|season|series)[\s._]?)?(?<season>\d{1,2})[x\/\s._-]*(?:e|ep|episode)[\s._]?(?<episode>\d{1,2})(?:-?(?:(?:e|ep)[\s._]*)?(?<endep>\d{1,2}))?(?:[\s._]?(?:p|part)[\s._]?(?<part>\d+))?(?<subep>[a-z])?(?:[\/\s._-]*(?<epname>[^\/]+?))?$',

		# Perl < v5.10
		re_compat => '^(?:(.*?)[\/\s._-]+)?(?:(?:s|se|season|series)[\s._]?)?(\d{1,2})[x\/\s._-]*(?:e|ep|episode)[\s._]?(\d{1,2})(?:-?(?:(?:e|ep)[\s._]*)?(\d{1,2}))?(?:[\s._]?(?:p|part)[\s._]?(\d+))?([a-z])?(?:[\/\s._-]*([^\/]+?))?$',
		keys_compat => [qw(name season episode endep part subep epname)],

		test_keys => [qw(filename name guess-name season episode endep part subep epname ext)],
		test => [
			['S01E02.Episode_name.avi', undef, undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.S01E02.Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/S01E02.Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/S01E02/Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series/Name/S01E02/Episode_name.avi', 'Name', 'Series Name', 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.S01E02a.Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, 'a', 'Episode_name', 'avi'],
			['Series Name.S01E02p4.Episode_name.avi', 'Series Name', undef, 1, 2, undef, 4, undef, 'Episode_name', 'avi'],
			['Series Name.S01E02-03.Episode_name.avi', 'Series Name', undef, 1, 2, 3, undef, undef, 'Episode_name', 'avi'],
			['Series Name.S01E02-E03.Episode_name.avi', 'Series Name', undef, 1, 2, 3, undef, undef, 'Episode_name', 'avi'],
			['Series Name.S01E02E.03.Episode_name.avi', 'Series Name', undef, 1, 2, 3, undef, undef, 'Episode_name', 'avi'],
			['Series Name/S01E02E03/Episode_name.avi', 'Series Name', undef, 1, 2, 3, undef, undef, 'Episode_name', 'avi'],
			['S01E02E03/Episode name.avi', undef, undef, 1, 2, 3, undef, undef, 'Episode name', 'avi'],
			['Series Name.Season_01.Episode_02.Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.Season_V.Episode_XI.Episode_name.avi', 'Series Name', undef, 5, 11, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.Season_V.Episode_XI.Part.XXV.Episode_name.avi', 'Series Name', undef, 5, 11, undef, 25, undef, 'Episode_name', 'avi'],
			['Series Name.Se01.Ep02.Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/Season_01.Episode_02.Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/Season_01/Episode_02.Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/S.I/Ep02.Episode_name.avi', 'Series Name', undef, 1, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/S.one/Ep twelve.Episode_name.avi', 'Series Name', undef, 1, 12, undef, undef, undef, 'Episode_name', 'avi'],
		],
	},
	{ # Movie IMDB Support
		# Perl > v5.10
		re => '^(?<movie>.*?)?(?:[\/\s._-]*(?<openb>\[)?(?<year>(?:19|20)\d{2})(?(<openb>)\]))?(?:[\/\s._-]*(?<openc>\[)?(?:(?:imdb|tt)[\s._-]*)*(?<imdb>\d{7})(?(<openc>)\]))(?:[\s._-]*(?<title>[^\/]+?))?$',

		# Perl < v5.10
		re_compat => '^(.*?)?(?:[\/\s._-]*\[?((?:19|20)\d{2})\]?)?(?:[\/\s._-]*\[?(?:(?:imdb|tt)[\s._-]*)*(\d{7})\]?)(?:[\s._-]*([^\/]+?))?$',
		keys_compat => [qw(movie year imdb title)],

		test_keys => [qw(filename movie guess-movie year imdb title ext)],
		test => [
			['Movie Name [1996] [imdb 1234567].mkv', 'Movie Name', undef, 1996, 1234567, undef, 'mkv'],
			['Movie Name [1996] [imdb tt1234567].mkv', 'Movie Name', undef, 1996, 1234567, undef, 'mkv'],
			['Movie Name [1996] [1234567].avi', 'Movie Name', undef, 1996, 1234567, undef, 'avi'],
			['Movie Name [1996] [tt1234567] foo.avi', 'Movie Name', undef, 1996, 1234567, 'foo', 'avi'],
			['Movie Name [1996]/tt1234567-foo.avi', 'Movie Name', undef, 1996, 1234567, 'foo', 'avi'],
			['Movie/Name/tt1234567_foo.avi', 'Name', 'Movie Name', undef, 1234567, 'foo', 'avi'],
			['Movie Name.[tt0096657] bar.avi', 'Movie Name', undef, undef, '0096657', 'bar', 'avi'],
			['Movie Name.tt0096657-foo.avi', 'Movie Name', undef, undef, '0096657', 'foo', 'avi'],
			['Movie.Name.tt0096657foo.avi', 'Movie.Name', undef, undef, '0096657', 'foo', 'avi'],
			['Movie Name.tt0096657_foo.avi', 'Movie Name', undef, undef, '0096657', 'foo', 'avi'],
			['Movie Name.tt0096657.avi', 'Movie Name', undef, undef, '0096657', undef, 'avi'],
			['Movie Name.[0096657].avi', 'Movie Name', undef, undef, '0096657', undef, 'avi'],
			['imdb-tt0096657.avi', undef, undef, undef, '0096657', undef, 'avi'],
			['tt0096657.mov', undef, undef, undef, '0096657', undef, 'mov'],
			['tt0096857', undef, undef, undef, '0096857', undef, undef],
			['1234576', undef, undef, undef, '1234576', undef, undef],
		],
		#warning => 'Found year instead of season+episode',
	},
	{ # Movie + Year Support
		# Perl > v5.10
		re => '^(?:(?<movie>.*?)[\/\s._-]*)?(?<openb>\[)?(?<year>(?:19|20)\d{2})(?(<openb>)\])(?:[\s._-]*(?<title>[^\/]+?))?$',

		# Perl < v5.10
		re_compat => '^(?:(.*?)[\/\s._-]*)?\[?((?:19|20)\d{2})\]?(?:[\s._-]*([^\/]+?))?$',
		keys_compat => [qw(movie year title)],

		test_keys => [qw(filename movie year title ext)],
		test => [
			['Movie.[1988].avi', 'Movie', 1988, undef, 'avi'],
			['Movie.2000.title.avi', 'Movie', 2000, 'title', 'avi'],
			['Movie/2009.title.avi', 'Movie', 2009, 'title', 'avi'],
		],
		#warning => 'Found year instead of season+episode',
	},
	{ # TV Show Support - see
		# Perl > v5.10
		re => '^(?:(?<name>.*?)[\/\s._-]*)?(?<season>\d{1,2}?)(?<episode>\d{2})(?:[\s._-]*(?<epname>.+?))?$',

		# Perl < v5.10
		re_compat => '^(?:(.*?)[\/\s._-]*)?(\d{1,2}?)(\d{2})(?:[\s._-]*(.+?))?$',
		keys_compat => [qw(name season episode epname)],

		test_keys => [qw(filename name season episode epname ext)],
		test => [
			['SN102.Episode_name.avi', 'SN', 1, 2, 'Episode_name', 'avi'],
			['Series Name.102.Episode_name.avi', 'Series Name', 1, 2, 'Episode_name', 'avi'],
			['Series Name/102.Episode_name.avi', 'Series Name', 1, 2, 'Episode_name', 'avi'],
		],
	},
	{ # TV Show Support - sxee
		# Perl > v5.10
		re => '^(?:(?<name>.*?)[\/\s._-]*)?(?<openb>\[)?(?<season>\d{1,2})[x\/](?<episode>\d{1,2})(?:-(?:\k<season>x)?(?<endep>\d{1,2}))?(?(<openb>)\])(?:[\s._-]*(?<epname>[^\/]+?))?$',

		# Perl < v5.10
		re_compat => '^(?:(.*?)[\/\s._-]*)?\[?(\d{1,2})[x\/](\d{1,2})(?:-(?:\d{1,2}x)?(\d{1,2}))?\]?(?:[\s._-]*([^\/]+?))?$',
		keys_compat => [qw(name season episode endep epname)],

		test_keys => [qw(filename name season episode endep epname ext)],
		test => [
			['Series Name.1x02.Episode_name.avi', 'Series Name', 1, 2, undef, 'Episode_name', 'avi'],
			['Series Name/1x02.Episode_name.avi', 'Series Name', 1, 2, undef, 'Episode_name', 'avi'],
			['Series Name.[1x02].Episode_name.avi', 'Series Name', 1, 2, undef, 'Episode_name', 'avi'],
			['Series Name.1x02-03.Episode_name.avi', 'Series Name', 1, 2, 3, 'Episode_name', 'avi'],
			['Series Name.1x02-1x03.Episode_name.avi', 'Series Name', 1, 2, 3, 'Episode_name', 'avi'],
		],
	},
	{ # TV Show Support - season only
		# Perl > v5.10
		re => '^(?:(?<name>.*?)[\/\s._-]+)?(?:s|se|season|series)[\s._]?(?<season>\d{1,2})(?:[\/\s._-]*(?<epname>[^\/]+?))?$',

		# Perl < v5.10
		re_compat => '^(?:(.*?)[\/\s._-]+)?(?:s|se|season|series)[\s._]?(\d{1,2})(?:[\/\s._-]*([^\/]+?))?$',
		keys_compat => [qw(name season epname)],

		test_keys => [qw(filename name season epname ext)],
		test => [
			['Series Name.s1.Episode_name.avi', 'Series Name', 1, 'Episode_name', 'avi'],
			['Series Name.s01.Episode_name.avi', 'Series Name', 1, 'Episode_name', 'avi'],
			['Series Name/se01.Episode_name.avi', 'Series Name', 1, 'Episode_name', 'avi'],
			['Series Name.season_1.Episode_name.avi', 'Series Name', 1, 'Episode_name', 'avi'],
			['Series Name/season_1/Episode_name.avi', 'Series Name', 1, 'Episode_name', 'avi'],
			['Series Name/season ten/Episode_name.avi', 'Series Name', 10, 'Episode_name', 'avi'],
		],
	},
	{ # TV Show Support - episode only
		# Perl > v5.10
		re => '^(?:(?<name>.*?)[\/\s._-]*)?(?:(?:e|ep|episode)[\s._]?)?(?<episode>\d{1,2})(?:-(?:e|ep)?(?<endep>\d{1,2}))?(?:(?:p|part)(?<part>\d+))?(?<subep>[a-z])?(?:[\/\s._-]*(?<epname>[^\/]+?))?$',

		# Perl < v5.10
		re_compat => '^(?:(.*?)[\/\s._-]*)?(?:(?:e|ep|episode)[\s._]?)?(\d{1,2})(?:-(?:e|ep)?(\d{1,2}))?(?:(?:p|part)(\d+))?([a-z])?(?:[\/\s._-]*([^\/]+?))?$',
		keys_compat => [qw(name episode endep part subep epname)],

		test_keys => [qw(filename name episode endep part subep epname ext)],
		test => [
			['Series Name.Episode_02.Episode_name.avi', 'Series Name', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/Episode_02.Episode_name.avi', 'Series Name', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/Ep02.Episode_name.avi', 'Series Name', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['E02.Episode_name.avi', undef, 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.E02.Episode_name.avi', 'Series Name', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.02.Episode_name.avi', 'Series Nam', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/E02.Episode_name.avi', 'Series Name', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/02.Episode_name.avi', 'Series Name', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/E02/Episode_name.avi', 'Series Name', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name/02/Episode_name.avi', 'Series Name', 2, undef, undef, undef, 'Episode_name', 'avi'],
			['Series Name.E02a.Episode_name.avi', 'Series Name', 2, undef, undef, 'a', 'Episode_name', 'avi'],
			['Series Name.E02p3.Episode_name.avi', 'Series Name', 2, undef, 3, undef, 'Episode_name', 'avi'],
			['Series Name.E02-03.Episode_name.avi', 'Series Name', 2, 3, undef, undef, 'Episode_name', 'avi'],
			['Series Name.E02-E03.Episode_name.avi', 'Series Name', 2, 3, undef, undef, 'Episode_name', 'avi'],
		],
	},
	{ # Default Movie Support
		# Perl > v5.10
		re => '^(?<movie>.*)$',

		# Perl < v5.10
		re_compat => '^(.*)$',
		keys_compat => [qw(movie)],

		test_keys => [qw(filename movie ext)],
		test => [
			['Movie.mov', 'Movie', 'mov'],
		],
		#warning => 'Found year instead of season+episode',
	},
);

###############################################################################
sub new {
	my $self = bless {};
	@$self{qw(file name season episode part)} = @_;
	&debug(5, "VideoFilename: $self->{file}\n");

	my $file = $self->{file};
	$self->{dir} = $1 if $file =~ m|^(.*/)|;
	$self->{ext} = lc $1 if $file =~ s/\.([0-9a-z]+)$//i;

	# Translate appropriate roman/english numbers to numerals
	my $prefix = '(?:day|d|dvd|disc|disk|s|se|season|e|ep|episode|part)[\s._-]+';
	$file = &_allroman2int($file, $prefix);
	$file = &_allnum2int($file, $prefix);

	# Episode
	$self->{endep} = $1 if $self->{episode} =~ s/-(\d+)//i;
	$self->{subep} = $1 if $self->{episode} =~ s/([a-z])$//i;

	# Parse filename
	for my $pat (@filePatterns) {
		if ($] >= 5.010000) {
			if ($file =~ /$pat->{re}/i) {
				&warning($pat->{warning}) if defined $pat->{warning};
				&debug(3, "PARSEINFO: $pat->{re}\n");
				$self->{regex} = $pat->{re};
				while (my ($key, $data) = each (%-)) {
					$self->{$key} = $data->[0] unless defined $self->{$key};
				}
				last;
			}
		} else { # No named groups in regexes
			my @matches;
			if (@matches = ($file =~ /$pat->{re_compat}/i)) {
				#print "MACTHES: ".join(',', @matches)."\n";
				&warning($pat->{warning}) if defined $pat->{warning};
				&debug(3, "PARSEINFO: $pat->{re_compat}\n");
				$self->{regex} = $pat->{re_compat};
				my $count = 0;
				foreach my $key (@{$pat->{keys_compat}}) {
					$self->{$key} = $matches[$count] unless defined $self->{$key};
					$count++;
				}
				last;
			}
		}
	}

	# Perhaps a movie is really a name with default season or episode
	if (($self->{name} || $self->{season} || $self->{episode}) && $self->{movie}) {
		$self->{name} = $self->{movie} unless $self->{name};
		delete $self->{movie};
	}

	# Process Series/Movie
	for my $key (qw(name movie)) {
		if ($self->{$key}) {
			if ($self->{$key} =~ /^.*\/(.*?)$/) {
				# Get rid of any directory parts
				$self->{"guess-$key"} = $self->{$key};
				# Keep the original name without '/' just in case the name contains a subdir
				$self->{$key} = $1;
				$self->{"guess-$key"} =~ s/[\/\s._-]+/ /;
			}
			$self->{$key} =~ s/^\s*(.+?)\s*$/$1/;	# Remove leading/trailing separators
		}
	}

	# Guess part from epname
	if ($self->{epname} && !$self->{part}) {
		my $rmpart = 'Episode|Part|PT';			 	# Remove "Part #" from episode name
		my $epname = &_allnum2int($self->{epname});	# Make letters into integers
		if ($epname =~ /(?:$rmpart) (\d+)/i
			|| $epname =~ /(\d+)\s*(?:of|-)\s*\d+/i
			|| $epname =~ /^(\d+)/
			|| $epname =~ /[\s._-](\d+)$/
		) {
			$self->{part} = $1;
		}
	}

	# Cosmetics
	for my $key (qw(dvd season episode endep part)) {
		$self->{$key} =~ s/^0+// if $self->{$key};
	}
	$self->{endep} = undef if $self->{endep} == $self->{episode};

	# Convenience for some developpers
	if ($self->{season}) {
		$self->{seasonepisode} = sprintf("S%02dE%02d", $self->{season}, $self->{episode});
	} elsif ($self->{dvd}) {
		$self->{seasonepisode} = sprintf("D%02dE%02d", $self->{dvd}, $self->{episode});
	}

	&debug(2, '', VideoFilename=>$self);
	return $self;
}

###############################################################################
sub _num2int {
	my $str = shift;
	my ($n, $c, $sum) = (0, 0, 0);
	while ($str) {
		$str =~ s/^[\s,]+//;
		debug(3, "STR=$str NUM=$n\n");

		if ($str =~ s/^(zero|and|&)//i)	 	{ next;
		} elsif ($str =~ s/^one//i)		 	{ $n += 1;
		} elsif ($str =~ s/^tw(o|en)//i)	{ $n += 2;
		} elsif ($str =~ s/^th(ree|ir)//i)	{ $n += 3;
		} elsif ($str =~ s/^four//i)		{ $n += 4;
		} elsif ($str =~ s/^fi(ve|f)//i)	{ $n += 5;
		} elsif ($str =~ s/^six//i)		 	{ $n += 6;
		} elsif ($str =~ s/^seven//i)		{ $n += 7;
		} elsif ($str =~ s/^eight//i)		{ $n += 8;
		} elsif ($str =~ s/^nine//i)		{ $n += 9;
		} elsif ($str =~ s/^(t|te|e)en//i)	{ $n += 10;
		} elsif ($str =~ s/^eleven//i)		{ $n += 11;
		} elsif ($str =~ s/^twelve//i)		{ $n += 12;
		} elsif ($str =~ s/^t?y//i)			{ $n *= 10;
		} elsif ($str =~ s/^hundred//i)		{ $c += $n * 100; $n = 0;
		} elsif ($str =~ s/^thousand//i)	{ $sum += ($c+$n) * 1000; ($c,$n) = (0,0);
		} elsif ($str =~ s/^million//i)		{ $sum += ($c+$n) * 1000000; ($c,$n) = (0,0);
		} elsif ($str =~ s/^billion//i)		{ $sum += ($c+$n) * 1000000000;	($c,$n) = (0,0);
		} elsif ($str =~ s/^trillion//i)	{ $sum += ($c+$n) * 1000000000000; ($c,$n) = (0,0);
		}
	}
	$sum += ($c+$n);
	debug(2, "STR=$str SUM=$sum\n");
	return $sum;
}
sub _allnum2int {
	my ($str, $prefix) = @_;

	my $single = 'zero|one|two|three|five|(?:twen|thir|four|fif|six|seven|nine)(?:|teen|ty)|eight(?:|een|y)|ten|eleven|twelve';
	my $mult = 'hundred|thousand|(?:m|b|tr)illion';
	my $sep = '\s|,|and|&';

	if ($] >= 5.010000) {
		$str =~ s/$prefix\K\b((?:(?:$single|$mult)(?:$single|$mult|$sep)+)?(?:$single|$mult))\b/&_num2int($1)/egis;
	} else {
		$str =~ s/($prefix)\b((?:(?:$single|$mult)(?:$single|$mult|$sep)+)?(?:$single|$mult))\b/"$1".&_num2int($2)/egis;
	}

	return $str;
}
sub _allroman2int {
	my ($str, $prefix) = @_;

	my $roman = '[MC]*[DC]*[CX]*[LX]*[XI]*[VI]*';
	if ($] >= 5.010000) {
		$str =~ s/$prefix\K($roman)\b/roman2int($1)/ieg;
	} else {
		$str =~ s/($prefix)($roman)\b/"$1".roman2int($2)/ieg;
	}
	return $str;
}

###############################################################################
sub isEpisode {
	my ($self) = @_;
	return $self->{name} && defined $self->{season} && defined $self->{episode};
}

###############################################################################
sub isMovie {
	my ($self) = @_;
	return $self->{movie} && $self->{year};
}


###############################################################################
sub testVideoFilename {
	for my $pat (@filePatterns) {
		for my $test (@{$pat->{test}}) {
			my $file = new($test->[0]);
			# Make the correct rule fired
			if ($file->{regex} ne $pat->{re}) {
				print RED "PATT RE: $pat->{re}\nFILE RE: $file->{regex}\n";
				print RED "FAILED: $file->{file} (wrong rule)\n";
				print Dumper($file); exit;
			}
			# Make sure all the attributes were correctly parsed
			my $keys = $pat->{test_keys};
			for my $i (1..8) {
				my $attr = $file->{$keys->[$i]};
				my $value = $test->[$i];
				if ($attr ne $value) {
					print RED "'$attr' ne '$value'\nFAILED: $file->{file}\n";
					print Dumper($file); exit;
				}
				&verbose(1, "'$attr' eq '$value'\n");
			}
			print GREEN "PASSED: $file->{file}\n";
		}
	}
}

###############################################################################
__END__

=head1 NAME

Video::Filename - Parse filenames for information about the video

=head1 SYNOPSIS

  use Video::Filename;

  my $file = Video::Filename::new($filename, [$series, [$season, [$episode]]]);

  # TV Episode
  $file->{regex}
  $file->{dir}
  $file->{file}
  $file->{series}
  $file->{season}
  $file->{episode}
  $file->{endep}
  $file->{subep}
  $file->{part}
  $file->{epname}
  $file->{ext}

  # Movie
  $file->{movie}
  $file->{year}
  $file->{title}

  $file->isEpisode();
  $file->isMovie();
  $file->testVideoFilename();

=head1 DESCRIPTION

Video::Filename is used to parse information line name/season/episode and such
from a video filename. It also does a reasonable job at distinguishing a movie
from a tv episode.

=over 4

=item $file = Video::Filename::new(FILENAME, [SERIES_NAME, [SEASON, [EPISODE]]]);

Parse C<FILENAME> and return a Video::Filename object containing the data. If
you specify C<SERIES_NAME>, C<SEASON>, and/or C<EPISODE> it will override what
is parsed from C<FILENAME>.

=item isEpisode();

Returns true if the object represents a TV episode.

=item isMovie();

Returns true if the object represents a Movie.

=item testVideoFilename();

Run a series of tests on the rules used to parse filenames. Basically a test
harness.

=back

=head1 COPYRIGHT

Copyright (c) 2008 by Behan Webster. All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=head1 AUTHOR

S<Behan Webster E<lt>behanw@websterwood.comE<gt>>

=cut

# vim: sw=4 ts=4
