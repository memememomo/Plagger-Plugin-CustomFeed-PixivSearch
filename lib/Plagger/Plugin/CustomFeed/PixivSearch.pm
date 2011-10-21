package Plagger::Plugin::CustomFeed::PixivSearch;
use strict;
use warnings;
use base qw( Plagger::Plugin );

use WebService::Pixiv;

sub register {
    my ($self, $context) = @_;
    $context->register_hook(
	$self,
	'subscription.load' => \&load,
    );
}

sub load {
    my ($self, $context) = @_;
    my $feed = Plagger::Feed->new;
    $feed->aggregator(sub { $self->aggregate(@_) });
    $context->subscription->add($feed);
}

sub aggregate {
    my ($self, $context, $args) = @_;

    my $feed = Plagger::Feed->new;
    $feed->type('pixiv.search');
    $feed->title('Pixiv Search');
    $feed->id('pixiv:seach');

    my $pixiv = WebService::Pixiv->new(
	pixiv_id => $self->conf->{pixiv_id},
	password => $self->conf->{password},
    );

    $context->log(info => "login as " . $self->conf->{pixiv_id});

    my $tags = $self->conf->{params}->{tags} || [];
    $context->log(info => "Tag Searching " . join(',', @$tags));
    my $search_illust = $pixiv->search_illust(@{ $tags });

    my $latest = $search_illust->count > 20 ? 20 : $search_illust->count;
    $latest -= 1;
    for my $num ( 0 .. $latest ) {
	my $illust_info = $search_illust->get($num);
	my $entry = $self->_create_entry($context, $illust_info);
	$feed->add_entry($entry);
    }

    $context->update->add($feed);
}


sub _create_entry {
    my ($self, $context, $illust_info) = @_;

    my $body = $illust_info->description . "\n";
    $body .= '<a href="' . $illust_info->uri . '">';
    $body .= '<img src="' . $illust_info->illust . '"/>';
    $body .= '</a>';

    my $entry = Plagger::Entry->new;
    $entry->title( $illust_info->title );
    $entry->link( $illust_info->uri );
    $entry->body( $body );
    if (ref $illust_info->tags) {
	$entry->add_tag($_) for @{ $illust_info->tags }
    }
    $entry->icon({ url => $illust_info->thumbnail });

    return $entry;
}


1;
__END__

=head1 NAME

Plagger::Plugin::CustomFeed::PixivSearch - Pixiv Search as Custom Feed

=head1 SYNOPSIS

  - module: CustomFeed::PixivSearch
    config:
      pixiv_id: your_pixiv_id
      password: your_password
      params:
        tags:
         - QB

=head1 DESCRIPTION

Plagger::Plugin::CustomFeed::PixivSearch is Pixiv Search as Custom Feed

=head1 AUTHOR

mememememomo E<lt>memememomo {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
