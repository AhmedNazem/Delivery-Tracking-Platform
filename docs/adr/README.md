# Architecture decision records

An ADR records why a non-obvious design choice was made. It is not needed for
every file or routine setup task.

Copy `template.md` to `NNNN-short-title.md`, using the next unused four-digit
number, starting with `0001`. Link the related issue and TASKS.md item. Change
the status to Accepted when the decision is agreed during review.

Preserve accepted records as history. If a later decision replaces one, create a
new ADR and mark the old record Superseded with a link to its replacement.

Example: choosing row locking for shipment assignment deserves an ADR because
two dispatchers could otherwise assign the same shipment concurrently.
