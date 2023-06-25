[![Ruby](https://github.com/djberg96/interface/actions/workflows/ruby.yml/badge.svg)](https://github.com/djberg96/interface/actions/workflows/ruby.yml)

## Description
This module provides Java style interfaces for Ruby, including a somewhat
similar syntax. This is largely a proof of concept library.

## Installation
`gem install interface`

## Adding the trusted cert
`gem cert --add <(curl -Ls https://raw.githubusercontent.com/djberg96/interface/main/certs/djberg96_pub.pem)`

## Synopsis
```ruby
require 'interface'

MyInterface = interface{
  required_methods :foo, :bar, :baz
}

# Raises an error until 'baz' is defined
class MyClass
  def foo
    puts "foo"
  end

  def bar
    puts "bar"
  end

  implements MyInterface
end
```
   
## General Notes
Subinterfaces work as well. See the test_sub.rb file under the 'test'
directory for a sample.

## Developer's Notes
A discussion on IRC with Mauricio Fernandez got us talking about traits.
During that discussion I remembered a blog entry by David Naseby. I 
revisited his blog entry and took a closer look:

http://ruby-naseby.blogspot.com/2008/11/traits-in-ruby.html

Keep in mind that I also happened to be thinking about Java at the moment
because of a recent job switch that involved coding in Java. I was also
trying to figure out what the purpose of interfaces were.

As I read the first page of David Naseby's article I realized that,
whether intended or not, he had implemented a rudimentary form of interfaces
for Ruby. When I discovered this, I talked about it some more with Mauricio
and he and I (mostly him) fleshed out the rest of the module, including some
syntax improvements. The result is syntax and functionality that is nearly
identical to Java.

I should note that, although I am listed as the author, this was mostly the
combined work of David Naseby and Mauricio Fernandez. I just happened to be
the guy that put it all together.

## Acknowledgements
This module was largely inspired and somewhat copied from a post by
David Naseby (see URL above). It was subsequently modified almost entirely
by Mauricio Fernandez through a series of discussions on IRC.

## See Also
The Crystal programming language, which has syntax very similar to Ruby's,
effectively implements interfaces via the `abstract` keyword.
	
## Copyright
(C) 2004-2023 Daniel J. Berger
All rights reserved.
	
## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.
	
## License
Artistic-2.0
	
## Author
Daniel J. Berger
