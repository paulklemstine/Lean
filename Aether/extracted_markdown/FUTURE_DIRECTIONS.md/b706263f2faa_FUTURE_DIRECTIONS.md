# Future Directions — Cellular Automata at the Ordinals

Derived from the Phase A cycle that produced `Computation/TransfiniteCA.lean`,
`Computation/TransfiniteCAOmegaSquared.lean`, and `Bridges/TransfiniteCABridge.lean`.
Those files established: (i) an ITTM-style limsup limit rule on ordinal time;
(ii) `ω`-stage and `ω²`-stage halting detection for latching cells;
(iii) a concrete super-Turing separation (the `shiftLatch` automaton); and
(iv) a Logic/Computation bridge pinning the super-Turing boundary at the
*(non-)monotonicity* of a cell history.

---

## Conjecture 1 — The clockable-ordinal hierarchy of `shiftLatch` families
**Statement.** For every recursive ordinal `α < ω₁ᶜᵏ` there is a transfinite CA whose
designated cell first *stabilises* exactly at stage `α`, and no CA in the family stabilises
at any non-clockable ordinal below `ω₁ᶜᵏ`.

*The key insight is...* that `shiftLatch` already realises the stabilisation time `k+1` for
each finite `k`; nesting `shiftLatch`-style fuses across `ω`-blocks should realise every
ordinal built by the same successor/limit recursion that `run` itself uses, so the set of
realisable stabilisation times is closed under exactly the clockable-ordinal operations.

*Why now?* We have a closed-form orbit (`shiftLatch_iter`) and a uniform limit law
(`run_succLimit_iff`) valid at *every* limit; the only missing step is the transfinite
bookkeeping of nested fuses, which the proven `global_halt_detected_at_succLimit` already
supports.

## Conjecture 2 — `liminf` automata compute strictly less than `limsup` automata
**Statement.** Replacing the limit rule "on iff cofinally often on" (`limsup`) by "on iff
eventually always on" (`liminf`) yields a *strictly weaker* model: there is a latching
history detected at `ω` by the `limsup` automaton but never by the `liminf` automaton.

*The key insight is...* that `latch_cofinal_iff` makes `limsup` coincide with an unbounded
existential (`Σ⁰₁`), whereas `liminf` coincides with an eventual universal (`Π⁰₁`); a single
late-firing latch separates the two quantifier classes.

*Why now?* `run` is parametric in its limit rule, so swapping `limsup` for `liminf` is a
one-line change, and `run_omega_iff` already isolates the exact quantifier the separation
must exploit.

## Conjecture 3 — The monotonicity dichotomy is the *only* obstruction
**Statement.** A transfinite CA cell collapses to finite time (its `ω`-value equals some
finite-stage value for *all* inputs) **iff** every cell history it produces is eventually
monotone.

*The key insight is...* that `antitone_collapses_to_finite` proves one direction via the
ordinal-potential `n ↦ if on then 1 else 0` and the Logic well-foundedness lemma; the
converse should follow by running the `shiftLatch` separation inside any non-eventually-monotone
cell to manufacture an `ω`-vs-finite disagreement.

*Why now?* The bridge theorem `transfinite_CA_super_turing_boundary` already contains both a
collapse half and a separation half; upgrading the separation half from "exists an automaton"
to "for this very automaton" closes the iff.

## Conjecture 4 — `ω²` strictly dominates `ω`
**Statement.** There is a globally latching transfinite CA whose designated cell is `false`
at every stage `< ω·k` for all finite `k`, `false` at `ω·ω⁻`-approachable stages below `ω²`,
yet `true` at `ω²`; hence the `ω²` clock decides a predicate no `ω·k` clock decides.

*The key insight is...* that `global_halt_detected_at_succLimit` shows each limit stage reads
off *all* prior activity, so staggering the first firing into successively later `ω`-blocks
forces the detection event arbitrarily high, with `ω²` as the least stage that sees them all.

*Why now?* `run_omega_mul_two_iff` and `run_omega_sq_iff` give the exact limit characterisations
at the relevant stages; only the explicit staggered construction remains.

## Conjecture 5 — Rule 110 transfinite universality
**Statement.** With the limsup limit rule, the Rule 110 automaton `rule110Step` on ordinal
time decides the halting problem of every Turing machine: encode the machine as a Rule 110
finite computation whose "halt" cell latches, then read the answer at stage `ω`.

*The key insight is...* that `rule110_halt_detection` already reduces transfinite Rule 110
halting detection to the *finite* Turing-universality of Rule 110 (Cook's theorem); the
ordinal limit rule supplies precisely the one transfinite step a finite machine lacks.

*Why now?* The transfinite scaffolding is proven and Rule 110 is plugged in; the remaining
gap is a Lean formalisation of Rule 110's finite Turing-completeness, a self-contained
classical result independent of the transfinite machinery built here.
