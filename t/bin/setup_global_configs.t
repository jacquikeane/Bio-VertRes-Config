#!/usr/bin/env perl
package Bio::VertRes::Config::Tests;
use Moose;
use Data::Dumper;
use File::Temp;

use File::Find;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

my $script_name = 'setup_global_configs';

my %scripts_and_expected_files = (
    '-d pathogen_euk_track' => [
        'command_line.log',
        'eukaryotes/eukaryotes_import_cram_pipeline.conf',
        'eukaryotes/import_cram/import_cram_global.conf',
        'eukaryotes/eukaryotes_permissions_pipeline.conf',
	    #'eukaryotes/permissions/permissions_.conf',
    ],
    '-d some_other_db_name' => [
        'command_line.log',
        'some_other_db_name/import_cram/import_cram_global.conf',
        'some_other_db_name/some_other_db_name_import_cram_pipeline.conf',
        #'some_other_db_name/permissions/permissions_.conf',
	    'some_other_db_name/some_other_db_name_permissions_pipeline.conf',
    ],

);

execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

done_testing();
