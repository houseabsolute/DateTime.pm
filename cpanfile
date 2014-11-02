requires "Carp" => "0";
requires "DateTime::Locale" => "0.41";
requires "DateTime::TimeZone" => "1.74";
requires "POSIX" => "0";
requires "Params::Validate" => "0.76";
requires "Scalar::Util" => "0";
requires "Try::Tiny" => "0";
requires "XSLoader" => "0";
requires "base" => "0";
requires "constant" => "0";
requires "integer" => "0";
requires "overload" => "0";
requires "perl" => "5.008001";
requires "strict" => "0";
requires "vars" => "0";
requires "warnings" => "0";
requires "warnings::register" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "Storable" => "0";
  requires "Test::Fatal" => "0";
  requires "Test::More" => "0.88";
  requires "Test::Warnings" => "0.005";
  requires "utf8" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "Module::Build" => "0.28";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Changes" => "0.19";
  requires "Test::EOL" => "0";
  requires "Test::More" => "0.88";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "Test::Spelling" => "0.12";
};
