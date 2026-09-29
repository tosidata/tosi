# Configure your `tosi` options

Set your service URL and access token before retrieving data. You can
also choose your preferred languages. Settings apply to subsequent calls
in the current R session.

## Usage

``` r
tosi_options(url = NULL, token = NULL, language_preference = NULL)
```

## Arguments

- url:

  The HTTPS service URL provided with your TosiData access details. If
  no scheme is supplied, `https://` is added.

- token:

  Your access token. Treat it like a password: do not include a real
  token in code you share or commit to version control.

- language_preference:

  Language codes in order of preference. For example, `c("fi", "en")`
  requests Finnish when available, then English. When no preference is
  set or none of the preferred languages is available, the service uses
  the source's first language. This is a default, not a restriction: see
  [`tosi()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
  for choosing a language for an individual call.

## Value

Invisible `NULL`. The function changes settings without displaying them
or returning your token.

## Details

You only need to supply the settings you want to change. For example,
changing your language preference leaves your connection settings alone.

## Connecting safely

Use a service you trust. Your token is sent to the configured service
for both requests and result downloads. Results are restored as native R
objects, so receiving them requires trusting the service as well.

## Changing and clearing settings

Call `tosi_options()` again with just the setting you want to change.
Use `language_preference = NULL` to clear your language preference.
Similarly, `url = NULL` or `token = NULL` clears that connection
setting; an environment variable may still provide its value (see
below). Calling `tosi_options()` with no arguments changes nothing.

## Environment variables and R options

For persistent setup or automated scripts, you can supply the connection
details through `TOSI_URL` and `TOSI_TOKEN` environment variables. For
example, add these lines with your own values to `~/.Renviron` and
restart R:

Values set with `tosi_options()` take priority over environment
variables. Clearing a URL or token setting with `NULL` makes the package
use the corresponding environment variable again; it does not revoke
your token. Without a URL from either source, requests cannot proceed.

The settings are stored as the R options `tosi.url`, `tosi.token`, and
`tosi.language_preference`. They are read when you make a request. The
function does not change environment variables or write files, so
settings made with it do not carry over when you restart R. There is no
environment variable for language preferences.

## Examples

``` r
if (FALSE) { # \dontrun{
# Connect using the details provided to you (placeholders shown here).
tosi_options(
  url = "https://service.example.invalid",
  token = "<your-access-token>"
)

# Prefer Finnish, then English, without changing the connection.
tosi_options(language_preference = c("fi", "en"))

# Let the service choose the language again.
tosi_options(language_preference = NULL)
} # }
```
