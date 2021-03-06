package Gearman::Job;
use version ();
$Gearman::Job::VERSION = version->declare("2.002.003");

use strict;
use warnings;

use Gearman::Util ();
use Carp ();
use Ref::Util qw/
    is_plain_scalarref
    is_ref
    /;

=head1 NAME

Gearman::Job - Job in gearman distributed job system

=head1 DESCRIPTION


I<Gearman::Job> is the object that's handed to the worker subrefs

=head1 METHODS

=cut

use fields (
    'func',
    'argref',
    'handle',
    'jss',    # job server's socket
);

sub new {
    my ($self, $func, $argref, $handle, $jss) = @_;
    unless (is_ref($self)) {
        $self = fields::new($self);
    }

    $self->{func}   = $func;
    $self->{handle} = $handle;
    $self->{argref} = $argref;
    $self->{jss}    = $jss;
    return $self;
} ## end sub new

=head2 set_status($numerator, $denominator)

Updates the status of the job (most likely, a long-running job) and sends
it back to the job server. I<$numerator> and I<$denominator> should
represent the percentage completion of the job.

=cut

sub set_status {
    my $self = shift;
    my ($nu, $de) = @_;

    my $req = Gearman::Util::pack_req_command("work_status",
        join("\0", $self->{handle}, $nu, $de));

    Carp::croak "work_status write failed"
        unless Gearman::Util::send_req($self->{jss}, \$req);

    return 1;
} ## end sub set_status

=head2 argref()

=cut

sub argref {
    my $self = shift;
    return $self->{argref};
}

=head2 arg()

B<return> the scalar argument that the client sent to the job server.

=cut

sub arg {
    my $self = shift;
    return ${ $self->{argref} };
}

=head2 handle()

B<return> handle

=cut

sub handle {
    my $self = shift;
    return $self->{handle};
}

