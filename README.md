# jQuery-style yet another Deferred implementation

## What's this?

jQuery.Deferred comes in handy when you want to handle nested asychronous tasks. Once I tried to decipher the source code of jQuery Deferred libraby only in vain because it looks so complicated. First, I was discouraged thinking that I was not smart enough to understand this sophisticated code. A few days later, however, I came to realize that jQuery Deferred might be unnecessarily complicated. So I decided to rewrite the Deferred library on my own using CoffeeScript.

First, I took out Notify/Progress event for simplification. I also renamed class Callbacks to EventListenerList, which I believe better reflects its responsibilites. I attached jasmine tests so you can better understand how my small library works.

## How to use

This is not a plugin or an extension of any existing libraries. It is more like a sample code which helps you understand how jQuery.Deferred works. I recommend you use my code to build your own class libraries or just use jQuery.Deferred on your production system.

Please feel free to contact me if you find any issues on my source code. Pull requests are always welcome.

## References

[jQuery repository at Github](https://github.com/jquery/jquery)

## License & Contact information.

This source code is MIT licensed.

Created by [@elm200](http://twitter.com/dimsemenov). My English speaking blog is located [here](http://elm200.blogspot.jp/).
