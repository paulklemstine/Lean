# Computational Evidence — Transfinite Cellular Automata on ω²

This note records the finite-case sanity checks behind the formal results in
`Catalog/Applications/OrdinalCellularAutomata/TransfiniteComputation.lean`.

## Setup

A computation of order type `ω²` is indexed by pairs `(block, tick) : ℕ × ℕ`
under lexicographic order. Successor ticks apply the Rule 110 local update
`rule110Step`; the start of each new block is chosen by a *limit rule* that may
read the entire preceding `ω`-history.

For the scheduled family we use `predicateLimit P`, which at the boundary
following block `k` writes the single bit `P k` into cell `0` and clears every
other cell.

## Small-case calculations

Successor evolution reduces to ordinary iteration `rule110Step^[n]`:

- Block 0, tick n: `rule110Step^[n] initial`.
- All-zero tape is a Rule 110 fixed point:
  `rule110Step (fun _ => false) = fun _ => false`
  (checked cell-by-cell for positions `0`, `1`, `≥2`; formalised as an `example`).

Boundary bits for the schedule `P n = decide (Even n)`:

| block k | boundary cell value `scheduledOmegaRun P initial (k+1) 0 0` |
|--------:|:----------------------------------------------------------|
| 0       | `Even 0 = true`                                           |
| 1       | `Even 1 = false`                                          |
| 2       | `Even 2 = true`                                           |
| 3       | `Even 3 = false`                                          |
| 4       | `Even 4 = true`                                           |

The block-4 entry (`= true`) is recorded as an `example` in the file via
`scheduledOmegaRun_boundary`.

General identity checked at blocks 0, 1, 5:
`scheduledOmegaRun P initial (k+1) 0 0 = P k` (theorem `scheduledOmegaRun_boundary`).

## Counterexample hunt

The universal claim under test is *faithfulness*: distinct schedules produce
distinct histories. On the finite window "read cell 0 at each boundary" this is
just `boundaryTrace ∘ scheduledOmegaRun = id`, and the diagonal test

`d n = if enumerate n n then false else true`

defeats any proposed enumeration `enumerate : ℕ → (ℕ → Bool)` (theorem
`no_predicate_enumeration`), so no countable list of histories can be complete
(`no_history_enumeration`). No counterexample to faithfulness was found; on the
contrary it upgrades to an exact cardinality: the histories realise the full
continuum (`continuum_scheduled_histories`).

## OEIS

No integer sequence drives the construction; target selection used no external
sequence signal, so no OEIS/LMFDB object was consulted.

## Conclusion

The finite checks are consistent with, and are subsumed by, the formal theorems:
successor locality, boundary faithfulness, non-enumerability via diagonalisation,
and the continuum-cardinality bridge.
