# Future Directions: Measurable Cardinals and the Large-Cardinal Hierarchy

## Synthesis

This cycle established `Catalog/Shared/MeasurableCardinal.lean`, a self-contained,
`sorry`-free formalization of **measurable cardinals** via `κ`-complete nonprincipal
ultrafilters. A cardinal `κ` is measurable when it is uncountable and some type `α` of
cardinality `κ` carries a nonprincipal `(#α)`-complete ultrafilter `U`
(`Cardinal.IsMeasurable`). The entire development rests on one combinatorial engine,
`MeasurableCardinal.small_notMem` — "sets of size `< κ` are null" — together with the
`κ`-completeness interface `MeasurableCardinal.IsCardComplete` and its convenience
restatement `IsCardComplete.iInter_mem`.

## Results Summary

* `MeasurableCardinal.small_notMem` — any subset of `α` with `#s < #α` lies outside a
  nonprincipal `(#α)`-complete ultrafilter. This is proved by complement duality:
  `sᶜ = ⋂_{a∈s} {a}ᶜ` is an intersection of `< κ` members of `U`, hence in `U`.
* `Cardinal.IsMeasurable.isRegular` — a measurable cardinal is regular. If
  `cof κ.ord < κ`, an unbounded set covers `α` by `< κ` small initial segments, whose
  complements intersect to `∅ ∈ U`, a contradiction.
* `Cardinal.IsMeasurable.isStrongLimit` — a measurable cardinal is a strong limit. If
  `κ ≤ 2 ^ μ` with `μ < κ`, an embedding `α ↪ (μ.out → Bool)` together with a coordinate-
  wise ultrafilter choice produces a singleton-or-smaller set in `U`, contradicting
  `small_notMem`.
* `Cardinal.IsMeasurable.isInaccessible` — assembled from the previous two plus
  uncountability.

All four results verify against only `propext`, `Classical.choice`, and `Quot.sound`.

## Direction 1 — Fodor's pressing-down lemma on the ultrafilter

State and prove the ultrafilter form of Fodor's lemma: for a fixed well order `r` on `α`
and any regressive `f : α → α` (`∀ x, r (f x) x ∨ f x = x`), there is a constant `c` with
`{x | f x = c} ∈ U`. The key insight is that `small_notMem` already shows each
"below a fixed point" fiber is null, so a regressive `f` partitions `α` into `≤ κ` blocks
of which exactly one can be large — the same complement-duality case split used in
`isRegular_aux`, now indexed by the range instead of by initial segments. Why now? The
`κ`-complete dual-ideal closure (`IsCardComplete.iInter_mem`, `small_notMem`) is exactly
the closure property Fodor's argument consumes; only the "exactly one block is large"
case analysis over `≤ κ` blocks remains, with no new cardinal arithmetic.

## Direction 2 — Measurable implies Mahlo

Strengthen `isInaccessible` to: the set of regular (indeed inaccessible) cardinals below
`κ`, transported to `α` via the canonical well order, is a *member of `U`* (hence
stationary). The key insight is that membership in `U` is strictly stronger than
stationarity and is obtained by showing the complementary set of singular `μ < κ` is null
through an Ulam-matrix decomposition by cofinality, each layer null by `small_notMem`. Why
now? `isRegular` supplies the reflection target and `IsCardComplete` lets us sum `< κ`
null layers; the only missing piece is the Ulam matrix, whose recursion is finite and
formalization-friendly.

## Direction 3 — The `κ`-complete ultrapower and Łoś's theorem

Build the ultrapower of `Λ → α` modulo `U`-a.e.-equality as a Lean quotient and prove
Łoś's theorem for atomic formulas, then derive elementarity of the diagonal embedding on
bounded quantifiers. The key insight is that `IsCardComplete` is *literally* the
hypothesis of Łoś's theorem for `κ`-complete ultrapowers: `< κ`-closure of `U` is exactly
what validates a.e.-quantifier exchange. Why now? Every ingredient of the Łoś hypothesis
is already a named lemma — the quotient and the atomic case are bookkeeping over the
existing `Ultrafilter` and `IsCardComplete` interface, requiring no new set theory.

## Direction 4 — Sharpness of the uncountability hypothesis

Pin down that `ℵ₀ < #α` is load-bearing: exhibit a nonprincipal `#ℕ`-complete
(vacuously, since `#ℕ`-completeness only constrains finite intersections) ultrafilter on
`ℕ` for which `small_notMem` **fails** — every singleton is null yet `ℕ` is a countable
union of singletons. The key insight is that the theory hinges on the strict inequality
`#ι < #α` controlling index size, and at `α = ℕ` the critical index size `ℵ₀` equals
`#α`, so the covering-by-singletons step is unavailable. Why now? The boundary witness
`Ultrafilter.hyperfilter` is already in Mathlib; formalizing both the positive
`#ℕ`-completeness statement and the failure of `small_notMem` closes the boundary analysis
with no new infrastructure.

## Direction 5 — From single ultrafilters to the Mitchell order

Define the Mitchell order `U ◁ W` ("`U` belongs to the ultrapower by `W`") on
`κ`-complete nonprincipal ultrafilters and prove it well-founded, equipping each `U` with
an ordinal rank `o(U)`. The key insight is that `IsCardComplete` makes the collection of
`U`-measure-one sets a `κ`-complete filter, and well-foundedness of `◁` reduces (via the
Łoś machinery of Direction 3) to well-foundedness of `∈` on ultrapowers, available through
Mathlib's ordinal `WellFoundedLT`. Why now? Direction 3 supplies the ultrapower and
Mathlib's ordinal-rank API turns the descending-chain condition into a definable rank with
essentially no new mathematics.
