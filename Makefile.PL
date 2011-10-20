use inc::Module::Install;
name 'Plagger-Plugin-CustomFeed-PixivSearch';
all_from 'lib/Plagger/Plugin/CustomFeed/PixivSearch.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
