# Cucumber hash tags

Adds hash tags support to Gherkin and Cucumber through monkey patching. 
Also includes a feature converter, from Business Analyst format to Gherkin and back (two-way).

## Cucumber monkey patch

*tags.rb* class *Cucumber::Ast::Tags*

## Gherkin monkey patch

*tags_expression.rb* class *Gherkin::TagExpression*

## Feature converter

A feature converter is also included that can convert a feature with tags to a nice Business Analyst format where the tag hash values are nicely spaced.
It can then write back this BA format to a valid Gherkin format. The Business Analyst would never know about this underlying conversion taking place.
This is f.ex usable by Cucumber FM (Feature Manager) ;)

See the *feature_converter_spec.rb* for instructions on how to use it!

## Usage

Load the 'cucumber-hash-tags' library after loading cucumber to ensure monkey patch takes effect overriding the strategic classes 
with new and improved tags functionality.

<pre>
require 'cucumber'
require 'cucumber-hash-tags'
</pre>

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Kristian Mandrup. See LICENSE for details.
