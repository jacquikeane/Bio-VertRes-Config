#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Temp;
use File::Slurper qw[write_text read_text];
BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::VertRes::Config::Recipes::EukaryotesMappingUsingTophat'); #1
}

my $destination_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $destination_directory = $destination_directory_obj->dirname();
$ENV{VERTRES_DB_CONFIG} = 't/data/database_connection_details';

print "$destination_directory\n";

ok(
    (
        my $obj = Bio::VertRes::Config::Recipes::EukaryotesMappingUsingTophat->new(
            database    => 'my_database',
            config_base => $destination_directory,
            limits      => { project => ['ABC study( EFG )'] },
            reference_lookup_file => 't/data/refs.index',
            reference             => 'ABC',
        )
    ),
    'initalise creating files' #2
);
is ( $obj->additional_mapper_params, ' --library-type fr-unstranded', 'testing passing params');
ok( ( $obj->create ), 'Create all the config files and toplevel files' ); #3


# Are all the necessary top level files there?
ok( -e $destination_directory . '/my_database/my_database.ilm.studies' , 'study names file exists');         #4
ok( -e $destination_directory . '/my_database/my_database_import_cram_pipeline.conf', 'import toplevel file');    #5
ok( -e $destination_directory . '/my_database/my_database_mapping_pipeline.conf', 'mapping toplevel file');  #7

# Individual config files
ok((-e "$destination_directory/my_database/import_cram/import_cram_global.conf"), 'import config file exists');        #10
ok((-e "$destination_directory/my_database/mapping/mapping_ABC_study_EFG_ABC_tophat.conf"), 'mapping config file exists' ); #12


my $text = read_text( "$destination_directory/my_database/mapping/mapping_ABC_study_EFG_ABC_tophat.conf" );
my $input_config_file = eval($text);
$input_config_file->{prefix} = '_checked_elsewhere_';
is_deeply($input_config_file,{
  'db' => {
            'database' => 'my_database',
            'password' => 'some_password',
            'user' => 'some_user',
            'port' => 1234,
            'host' => 'some_hostname'
          },
  'data' => {
              'mark_duplicates' => 0,
              'do_recalibration' => 0,
              'db' => {
                        'database' => 'my_database',
                        'password' => 'some_password',
                        'user' => 'some_user',
                        'port' => 1234,
                        'host' => 'some_hostname'
                      },
              'get_genome_coverage' => 1,
              'dont_wait' => 0,
              'assembly_name' => 'ABC',
              'exit_on_errors' => 0,
              'add_index' => 1,
              'reference' => '/path/to/ABC.fa',
              'do_cleanup' => 1,
              'ignore_mapped_status' => 1,
              'slx_mapper' => 'tophat',
              'slx_mapper_exe' => '/software/pathogen/external/apps/usr/local/tophat-2.1.1/tophat',
              'additional_mapper_params' => ' --library-type fr-unstranded'
            },
  'limits' => {
                'project' => [
                               'ABC\ study\(\ EFG\ \)'
                             ]
              },
  'vrtrack_processed_flags' => {
                                 'qc' => 1,
                                 'import' => 1
                               },
  'log' => '/nfs/pathnfs05/log/my_database/mapping_ABC_study_EFG_ABC_tophat.log',
  'root' => '/lustre/scratch118/infgen/pathogen/pathpipe/my_database/seq-pipelines',
  'prefix' => '_checked_elsewhere_',
  'dont_use_get_lanes' => 1,
  'module' => 'VertRes::Pipelines::Mapping',
  'umask' => 23,
  'octal_permissions' => 488,
  'unix_group' => 'pathogen',
  'limit' => 40,
},'Mapping Config file as expected');    #14

done_testing();
