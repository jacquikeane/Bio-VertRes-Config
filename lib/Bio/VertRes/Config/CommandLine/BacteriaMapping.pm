package Bio::VertRes::Config::CommandLine::BacteriaMapping;

# ABSTRACT: Create config scripts to map bacteria

=head1 SYNOPSIS

Create config scripts to map bacteria.

=method run

run the code

=cut

use Moose;
use Bio::VertRes::Config::Recipes::BacteriaMappingUsingBwa;
use Bio::VertRes::Config::Recipes::BacteriaMappingUsingSmalt;
use Bio::VertRes::Config::Recipes::BacteriaMappingUsingSsaha2;
use Bio::VertRes::Config::Recipes::BacteriaMappingUsingStampy;
use Bio::VertRes::Config::Recipes::BacteriaMappingUsingTophat;
use Bio::VertRes::Config::Recipes::BacteriaMappingUsingBowtie2;
with 'Bio::VertRes::Config::CommandLine::ReferenceHandlingRole';
extends 'Bio::VertRes::Config::CommandLine::Common';

sub run {
    my ($self) = @_;

    ( ( ( defined($self->available_references) && $self->available_references ne "" ) || ( $self->reference && $self->type && $self->id ) )
          && !$self->help ) or die $self->usage_text;

    return if(handle_reference_inputs_or_exit( $self->reference_lookup_file, $self->available_references, $self->reference ) == 1);

    if ( defined($self->mapper) && $self->mapper eq 'bwa' ) {
        Bio::VertRes::Config::Recipes::BacteriaMappingUsingBwa->new($self->mapping_parameters )->create();
    }
    elsif ( defined($self->mapper) && $self->mapper eq 'ssaha2' ) {
        Bio::VertRes::Config::Recipes::BacteriaMappingUsingSsaha2->new($self->mapping_parameters )->create();
    }
    elsif ( defined($self->mapper) && $self->mapper eq 'stampy' ) {
        Bio::VertRes::Config::Recipes::BacteriaMappingUsingStampy->new( $self->mapping_parameters )->create();
    }
    elsif ( defined($self->mapper) && $self->mapper eq 'tophat' ) {
        Bio::VertRes::Config::Recipes::BacteriaMappingUsingTophat->new( $self->mapping_parameters )->create();
    }
    elsif ( defined($self->mapper) && $self->mapper eq 'bowtie2' ) {
        Bio::VertRes::Config::Recipes::BacteriaMappingUsingBowtie2->new( $self->mapping_parameters )->create();
    }
    else {
        Bio::VertRes::Config::Recipes::BacteriaMappingUsingSmalt->new( $self->mapping_parameters)->create();
    }

    $self->retrieving_results_text;
}


sub retrieving_results_text {
    my ($self) = @_;
    $self->retrieving_mapping_results_text;
}

sub usage_text
{
  my ($self) = @_;
  $self->mapping_usage_text;
}

sub mapping_usage_text {
    my ($self) = @_;
    return <<USAGE;
Usage: bacteria_mapping -t <ID type> -i <ID> -r <reference> [options]
Pipeline for bacteria mapping

Required: 
  -t        STR Type (study/lane/file)
  -i        STR Study name, study ID, lane, file of lanes
  -r        STR Reference to map against. Must match exactly one of the references from the -a option.

Options:
  -s            STR Limit to a single species name (e.g. 'Staphylococcus aureus')
  -m            STR Set a different mapper (bwa/stampy/smalt/ssaha2/bowtie2/tophat) [smalt]
  -d            STR STR Specify a database [pathogen_prok_track]
  -c            STR Base directory to config files [/nfs/pathnfs05/conf]
  --root        STR Base directory for the pipelines [/lustre/scratch118/infgen/pathogen/pathpipe]
  --log         STR Base directory for the log files [/nfs/pathnfs05/log]
  --db_file     STR Filename containing database connection details [/software/pathogen/config/database_connection_details]
  -a            STR Search for available reference matching pattern and exit.  
  -h            Print this message and exit

Smalt options:
  --smalt_index_k       STR Set index k for smalt [13]
  --smalt_index_s       STR Set index s for smalt [4]
  --smalt_mapper_r      STR Set mapping r for smalt [0]
  --smalt_mapper_y      STR Set mapping y for smalt [0]
  --smalt_mapper_x          Set mapping x for smalt
  --smalt_mapper_l      STR Set orientation of mate pairs for smalt (pe/mp/pp)

TopHat options:
  --tophat_mapper_library_type  STR Set the library type for TopHat (fr-unstranded/fr-firststrand/fr-secondstrand) [fr-unstranded]

NOTE - If the data you are regestering is external you need to add the -d pathogen_prok_external option to the command.

NOTE - If you are uncertain that your request was successful, please do NOT run the command again. Instead, please direct any queries to path-help\@sanger.ac.uk.

If you use the results of this pipeline, please acknowledge the pathogen informatics team and include the appropriate citations for the pipeline. For more information on how to cite this pipeline, please see:
http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Pipelines_-_Methods#Bacteria_Mapping_and_Variant_Detection

For example usage and more information about the mapping pipeline, please see:
http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Mapping_Pipeline

USAGE
}



__PACKAGE__->meta->make_immutable;
no Moose;
1;
