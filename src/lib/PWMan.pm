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
	my $result    = {
		vaultFile => $jsonFile,
		data      => {},
		cipher    => $cipher,
	};

  	# Allow either strings or Mojo::File objects as parameter
	if ( -f $jsonFile ) {
		my $jsontext = $jsonFile->slurp;
		my $jsondata = $jsxs->decode( $jsontext );

		foreach my $passwordName ( keys $jsondata->%* ) {
			my $passwordData = $jsondata->{ $passwordName };
			$passwordData->{ name } = $passwordName;

			my $entry = PWMan::Entry->fromJson( $passwordData, $cipher );
			$result->{ data }->{ $passwordName } = $entry;
		}
	}

  return bless $result, $class;

}
