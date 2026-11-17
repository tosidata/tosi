read_only_binding <- function(name) {
  # R6 replaces binding environments, so embed names instead of capturing them.
  eval(substitute(
    function(value) {
      if (!missing(value)) {
        cli_abort(message)
      }
      private[[field]]
    },
    list(
      message = glue("{{.field {name}}} is read-only."),
      field = glue(".{name}")
    )
  ))
}

read_only_bindings <- function(fields) {
  set_names(map(fields, read_only_binding), fields)
}
