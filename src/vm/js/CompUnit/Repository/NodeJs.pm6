my class CompUnit::Repository::NodeJs does CompUnit::Repository does CompUnit::Repository::Locally {
    method need(
        CompUnit::DependencySpecification $spec,
        CompUnit::PrecompilationRepository $precomp = self.precomp-repository(),
    )
        returns CompUnit:D
    {

        if $spec.from eq 'node.js' {
            my $module = nqp::getcomp('JavaScript').eval(
              'return function(name, prefix) {return require(require.resolve(name, {paths: [prefix]}))}'
            )($spec.short-name, $.prefix.Str);


            my $stash = Stash.new();

            my sub export {
                Map.new($spec.short-name, $module);
            }

            my $handle = (CompUnit::Handle.from-unit($stash) does my role :: {
                has &!EXPORT;
                submethod with-export(&EXPORT) {
                    &!EXPORT := &EXPORT;
                    self
                }
                method export-package() returns Stash {
                    Stash.new
                }
                method export-sub() returns Callable {
                    &!EXPORT
                }
            }).with-export(&export);

            return CompUnit.new(
                :short-name($spec.short-name),
                :$handle,
                :repo(self),
                :repo-id($spec.short-name),
                :from($spec.from),
            );
        }


        return self.next-repo.need($spec, $precomp) if self.next-repo;
        X::CompUnit::UnsatisfiedDependency.new(:specification($spec)).throw;
    }

    method loaded() {
        []
    }

    method id() {
        'Node.js'
    }

    method short-id {
        'nodejs'
    }
}
