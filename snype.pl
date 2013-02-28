
  # This is a common method of declaring package scoped variables before the
  # 'our' keyword was introduced.  You should pick one form or the other, but
  # generally speaking, the our $var is preferred in new code.

  #use vars qw($VERSION %IRSSI);

  use Irssi;

  our $VERSION = '1.00';
  our %IRSSI = (
      authors     => 'Author Name(s)',
      contact     => 'author_email@example.com another_author@example.com',
      name        => 'Script Title',
      description => 'Longer script description, '
                  .  'maybe on multiple lines',
      license     => 'Public Domain',
  );


use Data::Dumper;
use WWW::Mechanize;

my $y = WWW::Mechanize->new();
my $url = "http://forums.somethingawful.com/forumdisplay.php?forumid=219";
my $starttime = time;
my $lasttime;
my %snipe;
my @snipes;
my $replyurl = "http://forums.somethingawful.com/newreply.php?action=newreply&threadid=";
sub snypecheck {
$y->get ($url);


my $yos = $y->content;
my @yospos = split("\n",$yos);

until ($yospos[0] =~ '<table id="forum" summary="Threads" class="threadlist ">') {
        shift @yospos;
}
my $threadid;
my $threadtitle;
foreach (@yospos){
if ($_ =~ m/thread_title/) {
        $threadid = $_;
        $threadid =~  s/.*adid=([\d]+)".*/$1/;
        $threadtitle = $_;
        $threadtitle =~ s/.*class=\"thread_title\">(.*?)<\/a>/$1/;
        $snipe{$threadid}{postcount} = 1 unless defined($snipe{$threadid}{postcount});
        $snipe{$threadid}{title} = $threadtitle;
	

}
if ($_ =~ m/td\ class="replies">/) {
        my $postcount = $_;
        $postcount =~ s/.*replies">([\d]+)<.*/$1/;
        $snipe{$threadid}{postcount} = $postcount;

}

if ($_ =~ m/td class="lastpost"/) {
        my $sniper = $_;
	my $thr = $_;
        $sniper =~ s/.*threadid=\d+">(.+)<\/a><\/td>.*/$1/;
        $thr =~ s/.*threadid=(\d+)">.+/$1/;
        $snipe{$thr}{sniper} = $sniper;
}


}
foreach (keys %snipe) {
	if ((($snipe{$_}{postcount} +1) % 40) == 0) {
		if ($snipe{$_}{postcount} > $snipe{$_}{notifiedcount}) {
			my $snipewarn = "\cC8,4SNIPE IT!\cC9,1[\cC0 $snipe{$_}{title}\cC9,1 ] \cC8Reply: \cC12$replyurl$_\cO\n";
			push (@snipes, $snipewarn);
			$snipe{$_}{notifiedcount} = $snipe{$_}{postcount};
			Irssi::print("PC: $snipe{$_}{postcount}, NC: $snipe{$_}{notifiedcount}", MSGLEVEL_CLIENTCRAP)
		}
	}

	if (($snipe{$_}{postcount}  % 40) == 0) {
                if ($snipe{$_}{postcount} > $snipe{$_}{notifiedcount}) {
			my $sniped = "\cC8THREAD SNIPED!\cC9,1[\cC0 $snipe{$_}{title}\cC9,1 ] \cC8Sniper: \cC7$snipe{$_}{sniper}\cO\n";
                        push (@snipes, $sniped);
                        $snipe{$_}{notifiedcount} = $snipe{$_}{postcount};
                        Irssi::print("PC: $snipe{$_}{postcount}, NC: $snipe{$_}{notifiedcount}", MSGLEVEL_CLIENTCRAP)
                }
        }			



}
my $c = Irssi::server_find_chatnet("syn")->channel_find("#yospos");
foreach (@snipes) {
$c->command("msg #yospos $_");
}
@snipes = ();
}
Irssi::timeout_add(60000,'snypecheck',undef);
