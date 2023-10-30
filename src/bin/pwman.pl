#!/usr/bin/perl

use Mojo::Base -strict, -signatures;
use AKLib::Utils::GetOpt;


my $action = shift(@ARGV);

my %defaultOptions = (
  "vault" => {
    type => 'file',
    help => 'Where are the passwords stored',
    useMojo => 1,
    required => 1,
    mustExist => 0,
  },
  "dry-run" => {help => 'Only print what would happen, don\'t actually do it',},

);

my $opt;
if($action eq 'add'){
  $opt = GetSmartOptions(
    %defaultOptions,
    "name" => {type => 's', help => 'Name of the password entry', required => 1},
    "username" => {type => 's', help => 'Username of the password entry', required => 1},
    "password" => {type => 's', help => 'Password of the password entry', required => 1},
    "url" => {type => 's', help => 'URL of the password entry', required => 1},
    "comment" => {type => 's', help => 'Comment for the password entry', required => 0},

    {description => 'Add a new password entry',}
  );
	if ( $opt->name eq "" || $opt->username eq "" || $opt->password eq "" || $opt->url eq "" ) {
		die( "Error: Required fields cannot be empty.\n" );
	}
}elsif ($action eq 'del'){
  $opt = GetSmartOptions(
    %defaultOptions,
    "name" => {type => 's', help => 'Name of the password entry', required => 1},
		{ description => 'Delete a password entry', }
  );
}elsif ( $action eq 'get' ) {
	$opt = GetSmartOptions(
		%defaultOptions,
		"name" => { type => 's', help => 'Name of the password entry to get' },
		"url"  => { type => 's', help => 'URL of the entry to get' },

		{ description => 'Get a password entry', }
	);

	if ( ( !$opt->name && !$opt->url ) || ( $opt->name && $opt->url ) ) {
		die( "You must specify exactly one of --name or --url\n" );
	}

} elsif ( $action eq 'list' ) {
	$opt = GetSmartOptions(
		%defaultOptions,
		{ description => 'list all passwords and informations', }

	); 
} elsif ( $action eq 'edit' ) {
	$opt = GetSmartOptions(
		%defaultOptions,

		"name"     => { type => 's', help => 'Name of the password entry to edit',  required => 1 },
		"username" => { type => 's', help => 'New Username for the password entry', required => 0 },
		"password" => { type => 's', help => 'New Password for the password entry', required => 0 },
		"url"      => { type => 's', help => 'New URL for the password entry',      required => 0 },
		"comment"  => { type => 's', help => 'New Comment for the password entry',  required => 0 },

		{ description => 'Add a new password entry', }
	);
} else {
	die( sprintf( "Unknown action: %s. Available: add, del, get, list, edit\n", $action ) );
}

# ############################################################################################################### #

