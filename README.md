# Nim-HTML-Tools

- HTML5 Tools for Nim, all Templates, No CSS, No Libs, No JS Framework.


# Features

- [HTML Image Lazy Load.](https://codepen.io/FilipVitas/pen/pQBYQd)
- [HTML Input Email, that validates **before** Submit, uses IANA for validation.](https://coliff.github.io/html5-email-regex)
- HTML Input File, validates File Format **before** Upload, by default for Images but you can customize it.
- HTML Notification bubble, super easy to use.
- HTML Minifier, super fast performance.
- RST/Markdown to HTML using Nim std lib.
- HTML Input Number, wont allow Negative, maxlenght is enforced, dir auto, etc.
- Designed for Nim std lib templating engine and NimWC, but can be used anywhere.


# Use

```nim
import html_tools

echo inputEmailHtml(value="user@company.com", name="myMail", class="is-rounded", id="myMail", placeholder="Email", required=true)
echo inputNumberHtml(value="42", name="myNumber", class="is-rounded", id="myNumber", placeholder="Integer", required=true)
echo inputFileHtml(name="myImage", class="is-rounded", id="myImage", required=true)
echo imgLazyLoadHtml(src="myImage.jpg", class="is-rounded", id="lazyAsHell")
echo "<button onClick=''" & notifyHtml("This is a Notification") & "'>Notification</button>"
echo rst2html("**Hello** *World*")
echo minifyHtml("     <p>some</p>                                                  <b>HTML</b>     ") # Minifies when -d:release
```


# Install

- `nimble install html_tools`
