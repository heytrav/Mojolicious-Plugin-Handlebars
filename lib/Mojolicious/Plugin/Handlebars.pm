package Mojolicious::Plugin::Handlebars;
use Mojo::Base 'Mojolicious::Plugin';
use Text::Handlebars;

our $VERSION = '0.01';

sub register {
    my ($self, $app, $args) = @_;

    $args ||= {};

    my $cache_dir;
    my @path = $app->home->rel_dir('views');

    if ($app) {
        $cache_dir = $app->home->rel_dir('tmp/compiled_templates');
        push @path, Mojo::Loader->new->data($app->renderer->classes->[0],);
    }
    else {
        $cache_dir = File::Spec->tmpdir;
    }

    my %config = (
        cache_dir    => $cache_dir,
        path         => \@path,
        warn_handler => sub { },
        die_handler  => sub { },
        %{ $args->{template_options} || {} },
    );
    my $xslate = Text::Handlebars->new(\%config);

    $app->renderer->add_handler(
        hb => sub {
            my ($renderer, $c, $output, $options) = @_;
            my $name = $c->stash->{'template'}
                || $renderer->template_name($options);
            my %params = (%{ $c->stash }, c => $c);

            local $@;
            if (defined(my $inline = $options->{inline})) {
                $$output = $xslate->render_string($inline, \%params);
            }
            else {
                $$output = $xslate->render($name, \%params);
            }
            die $@ if $@;

            return 1;

        });
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Handlebars - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Handlebars');

  # Mojolicious::Lite
  plugin Handlebars;
  plugin Handlebars => {
      template_options => { syntax => 'TTerse', ...}
  };

=head1 DESCRIPTION

L<Mojolicious::Plugin::Handlebars> is a L<Mojolicious> plugin. It is
heavily based on the L<MojoX::Renderer::Xslate> code. See that for
further reference.

=head1 METHODS

L<Mojolicious::Plugin::Handlebars> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>, L<Text::Handlebars>.

=cut
