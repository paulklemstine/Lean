# Future Directions — Cellular Automata at the Ordinals

Derived from the verified results in
`Catalog/Shared/TransfiniteCellularAutomata.lean` and
`Catalog/Shared/TransfiniteCAGardenOrdinalBridge.lean`.

These two files established, with 0 sorries:

* a transfinite (ordinal-indexed) cellular-automaton evolution `TransfiniteCA.run`
  that restricts to `step^[n]` on `ℕ` and applies a global limit rule at limit stages;
* the **ITTM limit law inside a cellular automaton** (`ittm_run_omega`): the value at
  stage `ω` is the `limsup` (`∃ᶠ`, "cofinally on") of the finite history;
* a **super-Turing separation** (`ittmLim_not_finitary`, `ittm_toggle_super_turing`):
  the parity automaton's finite orbit never converges, yet the `ω`-stage assigns it a
  definite value;
* a **cross-domain collapse theorem** (`wellfounded_transfinite_ca_collapses`): when an
  ordinal Lyapunov potential exists, the orbit reaches a non-Garden-of-Eden fixed point
  in `< ω` steps and the `ω`-stage adds nothing.

---

## Conjecture 1 — The potential dichotomy is exact

**Statement.** A transfinite cellular automaton's `ω`-stage is informative (differs from
every finite stage on some cell) **iff** the local rule admits *no* ordinal Lyapunov
potential on the reachable configurations.

The key insight is that `wellfounded_transfinite_ca_collapses` proves one direction
(potential ⇒ collapse) and the parity automaton refutes the converse hypothesis's
contrapositive, so the only missing piece is "no collapse ⇒ no potential," which should
follow from building a potential out of the stabilization stage itself.

Why now? We already have both halves as separate theorems in the bridge file; promoting
them to an `iff` only requires a converse construction, and the Mathlib ordinal API
(`Ordinal.lt_wf`, `nonincreasing_eventually_constant`) is in place.

## Conjecture 2 — A clock-hierarchy theorem at `ω·k`

**Statement.** For every `k`, there is a transfinite CA whose output first stabilizes at
stage `ω·k` and not before; hence the stages `ω·k` form a strict hierarchy of
computational power, and `ω²` strictly dominates every `ω·k`.

The key insight is that `omega_sq_has_infinitely_many_limit_stages` shows the limit stages
`ω·(k+1)` are cofinal below `ω²`, so iterating the `limsup` rule across them stacks `k`
independent ITTM limits — exactly the resource a single `ω`-limit cannot supply.

Why now? The cofinality lemma is already proved; the remaining work is a diagonal
construction nesting `k` copies of the `toggle` separation, each resolved one limit later.

## Conjecture 3 — Genuine ordinal limsup rule subsumes nat-sampling at `ω`

**Statement.** Replacing the nat-sampling `ittmLim` with the true ordinal `limsup`
("cell on cofinally below `o`") yields a rule that (a) agrees with `ittmLim` at `ω` but
(b) is strictly more expressive at every limit `o ≥ ω·2`.

The key insight is that `ittmLim` only reads stages `< ω` (documented as the Analyst's
failure mode), so it is blind to information created between `ω` and `ω·2`; an honest
ordinal `limsup` is not.

Why now? The `run_limit`/`run_omega_add_nat` scaffolding already exposes the post-`ω`
stages, so the only new object needed is the cofinal-below-`o` predicate, definable
directly from `<` on `Ordinal`.

## Conjecture 4 — Garden-of-Eden states are exactly the transfinitely unreachable ones

**Statement.** For an ITTM cellular automaton, a configuration is a Garden-of-Eden state
(no `step`-preimage) iff it is never produced at any ordinal stage from a dense set of
initial configurations.

The key insight is that `fixed_not_gardenOfEden` already shows attractors are reachable;
the conjecture asserts the converse globally, linking the *static* surjectivity criterion
`exists_garden_of_eden_iff_not_surjective` (Bridges) to *dynamic* transfinite reachability.

Why now? Both endpoints — surjectivity ⇔ no-GoE and the transfinite run — are formalized
and compile together, so the bridge is one reachability argument away.

## Conjecture 5 — Super-Turing power requires a non-well-orderable orbit

**Statement.** A transfinite CA computes a function not computable by any halting Turing
machine **only if** its reachable-configuration orbit cannot be embedded order-preservingly
into the ordinals by any `step`-monotone map.

The key insight is that the collapse theorem turns *any* ordinal embedding of the orbit
into a finite-time termination certificate, so super-Turing behaviour forces the absence of
such an embedding — making "order type of the orbit" the right complexity measure.

Why now? `wellfounded_reaches_fixed` already converts an ordinal potential into finite-time
termination; negating its hypothesis is precisely the embedding-failure condition, so the
statement is a contrapositive away from the verified core.
