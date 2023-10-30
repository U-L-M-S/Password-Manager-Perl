package PWMan;

use Mojo::Base -strict, -signatures;

use Mojo::File;
use Mojo::File qw(curfile);

sub new($class, $vaultName, $secret="SuperTemporatySecret-123"){
    	# Bless all objects from the JSON data hash to our Class
	my $vaultFile = curfile->dirname->child( "../../passwords/" )->child( $vaultName . '.json' );
	my $jsonFile  = ref( $vaultName ) eq 'Mojo::File' ? $vaultName : Mojo::File->new( $vaultFile );
	my $cipher = Crypt::CBC->new(
		-pass   => $secret,
		-cipher => 'Cipher::AES',
		-iv     => '1234567890987654',
		-pbkdf  => 'pbkdf2',
	);

}