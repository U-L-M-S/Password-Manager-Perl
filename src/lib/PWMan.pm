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

sub cipher($self) {
	return $self->{ cipher };
}

sub getLoginByName ( $self, $which ) {
	return $self->{ data }->{ $which };
}

sub getLoginsByHost ( $self, $which ) {

	#sort { $a <=> $b } @numberArray;
	#sort { $a cmp $b } @stringArray;

	return sort { $a->{ 'name' } cmp $b->{ 'name' } }
	  grep {
		$_->{ 'url' } &&    # URL gibts auf dem Eintrag
		  $_->{ 'url' } eq $which    ## und entspricht dem gesuchten
	  } values( $self->{ data }->%* );
}

# Add an entry to the "database"
# should return true on success
sub addEntry ( $self, %params ) {
	my $paramsRef = \%params;
	my $name = $params{ 'name' };
	return undef if ( $self->getLoginByName( $name ) );

	# Create a new entry object
	my $new_entry = PWMan::Entry->new( $paramsRef, $self->cipher );

	# Add the new entry to the database
	$self->{ data }->{ $new_entry->name } = $new_entry;

	return $new_entry;
}
