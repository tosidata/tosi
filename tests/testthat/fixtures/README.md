# Hosted service request examples

The request files copy representative JSON envelopes from the canonical
[server fixtures](https://github.com/tosidata/tosi.server/tree/main/tests/testthat/fixtures/protocol-v1).
The accepted
[server-selected result profiles ADR](https://github.com/tosidata/tosi.server/blob/main/records/decisions/server-selected-result-profiles.md)
owns their meaning. These client copies allow request-shape tests without
installing the private server package; they do not define another protocol.

Focused tests construct both supported result profiles and SSE responses at
runtime. They cover direct-to-file download, complete R-object restoration,
cleanup, and the existing request frontends without retaining endpoint-specific
result fixtures.
