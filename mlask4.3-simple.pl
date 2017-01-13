#!/usr/bin/perl -s
#use re::engine::RE2 -max_mem => 8<<23; #64MiB
use utf8;
use MeCab;
binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");

if ($help==1 or $h==1){
	print '
This is help for ML-Ask, or eMotive eLement and Expression Analysis system, ver. 4.0-4.3

ML-Ask is a keyword-based language-dependent system for automatic affect annotation on utterances in Japanese.

To use on standard input, launch in command line as: "perl mlask.pl"
To use on files, launch in command line as: "perl mlask.pl input_file.txt > output_file.txt"
Using -h or -help option will diplay this help message and exit the program.

The system was developed by Michal Ptaszynski (ptaszynski@ieee.org), Pawel Dybala, Rafal Rzepka and Kenji Araki. 

The ML-Ask system is described in detail in papers below. When using ML-Ask please add reference to either of these papers (or both if you like):

Michal Ptaszynski, Pawel Dybala, Rafal Rzepka and Kenji Araki, "Affecting Corpora: Experiments with Automatic Affect Annotation System - A Case Study of the 2channel Forum -", In Proceedings of The Conference of the Pacific Association for Computational Linguistics (PACLING-09), September 1-4, 2009, Hokkaido University, Sapporo, Japan, pp. 223-228.

Michal Ptaszynski, Pawel Dybala, Wenhan Shi, Rafal Rzepka and Kenji Araki, "A System for Affect Analysis of Utterances in Japanese Supported with Web Mining", Journal of Japan Society for Fuzzy Theory and Intelligent Informatics, Vol. 21, No. 2 (April), pp. 30-49 (194-213), 2009.

Please report any comments and bugs to: ptaszynski@ieee.org

';
	exit;
}

# to use on standard input, launch in command line as: "perl mlask.pl"
# to use on files launch in command line as: "perl mlask.pl input_file.txt > output_file.txt"


#	EMOTIONS: 
#	aware_uncoded.txt, annotated as AWA
#	haji_uncoded.txt, annotated as HAJ
#	ikari_uncoded.txt, annotated as IKA
#	iya_uncoded.txt, annotated as IYA
#	kowa_uncoded.txt, annotated as KOW
#	odoroki_uncoded.txt, annotated as ODO
#	suki_uncoded.txt, annotated as SUK
#	takaburi_uncoded.txt, annotated as TAK
#	yasu_uncoded.txt, annotated as YAS
#	yorokobi_uncoded.txt, annotated as YOR
#	
#	2D valence scale maptr perlping: 
#	positive is annotated as POS
#	negative is annotated as NEG
#	activeted(active) is annotated as ACT
#	deactivated(passive) is annotated as PAS
#
# the same as the above but for emotions.

my @emotions = qw(aware haji ikari iya kowa odoroki suki takaburi yasu yorokobi);

foreach $emotion_class (@emotions) {
	utf8::decode($emotion_class);
	open(FILE, "emotions/$emotion_class".'_uncoded.txt') or die "Cannot open!";
	@$emotion_class = <FILE>;
	close FILE;
	chomp(@$emotion_class);
	foreach (@$emotion_class) {
		utf8::decode($_);
		$_ =~ tr/ //;
		$_ = "\Q$_\E";
	}
	next;
}

# a hash used in CVS procedure ('KEY' , 'VALUE')
my %hash_cvs = (
	'suki' => {'iya'},
	'ikari' => {'yasu'},
	'kowa' => {'yasu'},
	'yasu' => {'ikari','takaburi','odoroki','haji','kowa'},
	'iya' => {'yorokobi','suki'},
	'aware' => {'suki','yorokobi','takaburi','odoroki','haji'},
	'takaburi' => {'yasu','aware'},
	'odoroki' => {'yasu','aware'},
	'haji' => {'yasu','aware'},
	'yorokobi' => {'iya'} );

#this is used in CVS pattern: ($cvs_type1)(.*?)(感情表現)(.*?)ない 
my $cvs_type1="いまひとつも|ちょっとも|いまいち|いまひと|すこしも|ぜったい|ゼッタイ|ぜんぜん|そもそも|そんなに|ちっとも|まったく|マッタク|今ひとつ|あまり|そんな|とても|まさか|今いち|今一つ|少しも|すら|今一|絶対|全く|全然|余り";

#this is used in CVS pattern: (感情表現)(.*?)($cvs_type2)
my $cvs_type2="いまひとつもない|なくても問題ない|わけにはいかない|わけにはいくまい|わけにもいかない|いまひとつない|ちょっともない|とすら思えない|なくて問題ない|なくても大丈夫|今ひとつもない|訳にはいかない|訳には行かない|訳にはいくまい|訳にも行かない|そんなにない|ぜったいない|まったくない|すこしもない|ちっともない|いまいちない|ぜんぜんない|そもそもない|とはいえない|とは思わない|とは思えない|てはいけない|ちゃいけない|じゃいけない|なくて大丈夫|なくてもいい|なくてもOK|なくても結構|わけではない|わけじゃない|ゼッタイない|今ひとつない|今一つもない|とは言えない|ては行けない|ちゃ行けない|じゃ行けない|なくても良い|あまりない|といえない|と思わない|と思えない|てはいかん|てはあかん|ちゃいかん|じゃいかん|じゃあかん|ちゃあかん|なくていい|なくてOK|なくてＯＫ|なくて結構|く思わない|く思えない|わけがない|わけはない|わけもない|少しもない|今一つない|今いちない|と言えない|ては行かん|ちゃ行かん|じゃ行かん|じゃあかん|ちゃあかん|なくて良い|なくてOK|なくてＯＫ|訳ではない|訳じゃない|てはだめ|ちゃだめ|じゃだめ|わけない|余りない|絶対ない|全くない|今一ない|全然ない|訳がない|訳はない|訳もない|もんか|ものか|わけか|訳ない|訳か|のに|あるますん|ない"; # the のに cvs is experimental. need to find longer のに patterns
# my $cvs_type2="いまひとつもない|なくても問題ない|わけにはいかない|わけにはいくまい|わけにもいかない|いまひとつない|ちょっともない|とすら思えない|なくて問題ない|なくても大丈夫|今ひとつもない|訳にはいかない|訳には行かない|訳にはいくまい|訳にも行かない|そんなにない|ぜったいない|まったくない|すこしもない|ちっともない|いまいちない|ぜんぜんない|そもそもない|とはいえない|とは思わない|とは思えない|てはいけない|ちゃいけない|じゃいけない|なくて大丈夫|なくてもいい|なくてもOK|なくても結構|わけではない|わけじゃない|ゼッタイない|今ひとつない|今一つもない|とは言えない|ては行けない|ちゃ行けない|じゃ行けない|なくても良い|あまりない|といえない|と思わない|と思えない|てはいかん|てはあかん|ちゃいかん|じゃいかん|じゃあかん|ちゃあかん|なくていい|なくてOK|なくてＯＫ|なくて結構|く思わない|く思えない|わけがない|わけはない|わけもない|少しもない|今一つない|今いちない|と言えない|ては行かん|ちゃ行かん|じゃ行かん|じゃあかん|ちゃあかん|なくて良い|なくてOK|なくてＯＫ|訳ではない|訳じゃない|てはだめ|ちゃだめ|じゃだめ|わけない|余りない|絶対ない|全くない|今一ない|全然ない|訳がない|訳はない|訳もない|もんか|ものか|わけか|訳ない|訳か|のに"; # the のに cvs is experimental. need to find longer のに patterns

# precompiling regexes to use later in the main code
# my $cvs_regex = qr/$cvs_type1?.*?$gotcha_emotion.*?$cvs_type2/; # precompiled cvs regex
my $kii = qr/\Aaware\z|\Ahaji\z|\Aikari\z|\Aiya\z|\Akowa\z|\Aodoroki\z|\Asuki\z|\Atakaburi\z|\Ayasu\z|\Ayorokobi\z/; # precompiled $key regex; 

while (<>) {
utf8::decode($_);
my $input = $_;
$input =~ tr/\!/！/;
$input =~ tr/\?/？/;
chomp $input;
my $input_mecab = $input;
push(my @final_output, $input);

#mecab trick.

my @input_lemmas;
my @found_interjections;
my @input_lemma_no_emo;

my $mecab = MeCab::Tagger->new();#"-d/usr/lib/mecab/dic/ipadic");
my $node = $mecab->parseToNode($input_mecab);
for( ; $node; $node = $node->{next} ) {
	next unless defined $node->{surface};
	my $midasi = $node->{surface};
	my( $hinsi, $kijutsu, $genkei ) = (split( /,/, $node->{feature} ))[0,1,6];
	push (@input_lemmas, $genkei);
}

chomp(@input_lemmas);
my $input_lemma = join ('', @input_lemmas);
utf8::decode($input_lemma);
$input_lemma =~ s/\*//g;


#here Nakamura's dictionary kicks in.
push(@final_output, '|emotions:');

foreach my $emo_class (@emotions) {
	my $input_lemma_matching = $input_lemma;
	foreach my $emotion_item (@{$emo_class}) {
		utf8::decode($emotion_item);
		while (index($input_lemma_matching,$emotion_item) != -1) {
			my $gotcha_emotion; 
			$gotcha_emotion = $emotion_item;
			if ($input_lemma_matching =~ /($gotcha_emotion)(.*?)($cvs_type2)|($cvs_type1)(.*?)($gotcha_emotion)(.*?)(あるますん|ない)/) { #here CVS procedure kicks in.
			# if ($input_lemma_matching =~ /$cvs_regex/) { #here CVS procedure kicks in.
				foreach (%{$hash_cvs{$emo_class}}) {
					$new_emo_class=$_;
					push (@{$found_hash{$new_emo_class}}, "$gotcha_emotion＊CVS");
				}
				$input_lemma_matching =~ s/$gotcha_emotion//;
			} else {
				push (@{$found_hash{$emo_class}}, "$gotcha_emotion");
				$input_lemma_matching =~ s/$gotcha_emotion//;
			}
			next;
		}
	}
}

my @output_emotions;
my @how_many;
foreach my $key (keys %found_hash) {
	if ($key =~ /$kii/g){
		my $key_3  = substr uc $key, 0, 3;
		push (@output_emotions, '|'.$key_3.':'."@{$found_hash{$key}}");	
		push (@how_many, $key);
	}
}
push(@final_output, '('.@how_many.')');
push(@final_output, @output_emotions);
undef @output_emotions;

if (@how_many>0){
	my $how_many_valence = my $how_many_activation = join (",", @how_many); 
	$how_many_valence =~ s/yasu|yorokobi|suki/P/g;
	$how_many_valence =~ s/iya|aware|ikari|kowa/N/g;
	$how_many_valence =~ s/takaburi|odoroki|haji/NorP/g;
	my $cnt_valence_P = $how_many_valence =~ tr/P/P/;
	my $cnt_valence_N = $how_many_valence =~ tr/N/N/;
	push(@final_output, '||2D|');
	my @output_valence;
	
	if ($cnt_valence_N == $cnt_valence_P) {
		push(@final_output, 'POS_or_NEG');
	} else {
		my %hash_valence = (
		$cnt_valence_P => 'POS',
		$cnt_valence_N => 'NEG');
		my $valence_array = (sort {$b<=>$a} ($cnt_valence_P,$cnt_valence_N) )[0];
		#my $valence_array = $cnt_valence_P>=$cnt_valence_N?$cnt_valence_P:$cnt_valence_N; # a different way to get highest value
		#my $valence_array = ($cnt_valence_P,$cnt_valence_N)[$cnt_valence_P<$cnt_valence_N]; # another way to get highest value
		push (@output_valence, $hash_valence{$valence_array});
		
		if (($cnt_valence_N == 0) or ($cnt_valence_P == 0)) {
			push(@final_output, @output_valence);
		} else {
			unshift (@output_valence, 'mostly_');
			push(@final_output, @output_valence);
		}
	undef @output_valence;
	}
	$how_many_activation =~ s/takaburi|odoroki|haji|ikari|kowa/A/g;
	$how_many_activation =~ s/yasu|aware/D/g;
	$how_many_activation =~ s/iya|yorokobi|suki/DorA/g;
	my $cnt_activation_A = $how_many_activation =~ tr/A/A/;
	my $cnt_activation_D = $how_many_activation =~ tr/D/D/;
	
	push(@final_output, '|');
	my @output_activation;
	if ($cnt_activation_A == $cnt_activation_D) {
		push(@final_output, 'ACT_or_PAS');
	} else {
		my %hash_activation = (
		$cnt_activation_A => 'ACT',
		$cnt_activation_D => 'PAS');
		my $activation_array = (sort {$b<=>$a}($cnt_activation_D,$cnt_activation_A) )[0];
		push (@output_activation, $hash_activation{$activation_array});
		
		if (($cnt_activation_A == 0) or ($cnt_activation_D == 0)) {
			push(@final_output, @output_activation);
		} else {
			unshift (@output_activation, 'mostly_');
			push(@final_output, @output_activation);
		}
	undef @output_activation;
	}
}

undef @how_many;
undef %found_hash;
print @final_output;
print "\n";
undef @final_output;
next;
}
__END__