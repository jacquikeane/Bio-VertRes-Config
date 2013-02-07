package Bio::VertRes::Config::Recipes::VirusMappingUsingSsaha2;
# ABSTRACT: Standard snp calling pipeline for virus

=head1 SYNOPSIS

Standard snp calling pipeline for virus.
   use Bio::VertRes::Config::Recipes::VirusMappingUsingSsaha2;
   
   my $obj = Bio::VertRes::Config::Recipes::VirusMappingUsingSsaha2->new( 
     database => 'abc', 
     limits => {project => ['Study ABC']}, 
     reference => 'ABC', 
     reference_lookup_file => '/path/to/refs.index'
     );
   $obj->create;
   
=cut

use Moose;
extends 'Bio::VertRes::Config::Recipes::Common';
with 'Bio::VertRes::Config::Recipes::Roles::RegisterStudy';
with 'Bio::VertRes::Config::Recipes::Roles::Reference';
with 'Bio::VertRes::Config::Recipes::Roles::CreateGlobal';
with 'Bio::VertRes::Config::Recipes::Roles::VirusMapping';

override '_pipeline_configs' => sub {
    my ($self) = @_;
    my @pipeline_configs;
    
    $self->add_qc_config(\@pipeline_configs);
    $self->add_virus_ssaha2_mapping_config(\@pipeline_configs);
    
    # Insert BAM Improvment here
    return \@pipeline_configs;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

