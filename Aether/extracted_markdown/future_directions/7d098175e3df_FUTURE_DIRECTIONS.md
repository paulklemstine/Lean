# Future Directions — Causal Loops in Category Theory

Follow-up conjectures arising from `CausalLoops.lean` (Cycle 0 + Cycle 1).
All results in that file are fully proved (0 sorries, standard axioms only).
Each direction below is stated to be **falsifiable** and **formalizable** in Lean 4 / Mathlib.

## Summary of what is established

- **Static loops collapse.** In a `Preorder` of events, `CausallyLooped a b := a ≤ b ∧ b ≤ a`
  is an equivalence relation, definitionally equal to `AntisymmRel (· ≤ ·)`; quotienting
  produces an acyclic (`PartialOrder`) causal structure, with loops being exactly the
  fibers of the collapse map.
- **Dynamic loops are self-consistent.** Every endomorphism of a finite nonempty type has a
  periodic point (`novikov_self_consistency`). The grandfather process `not` has no fixed
  point but is consistent at period 2. Idempotent loops always have a genuine fixed point;
  reversible (bijective) loops are globally periodic.
- **Composition loops back.** In any finite monoid / `End X` with finite hom, powers of any
  element repeat, and some positive power is idempotent.

---

## Conjecture 1 — Minimal consistent period is bounded by the state count

**Claim.** For a finite type `α` with `Nat.card α = N` and any `e : α → α`, there exists a
self-consistent history of *minimal* positive period `p` with `1 ≤ p ≤ N`. Moreover the set of
attainable minimal periods is exactly the set of cycle lengths of the eventual permutation of
`e` on its periodic core. Formalize via `Function.minimalPeriod` and `Function.IsPeriodicPt`,
proving `Function.minimalPeriod e x ≤ Nat.card α` for any periodic point `x`.

**Why bold/testable.** It upgrades "a consistent history exists" to a sharp quantitative bound,
giving a *spectrum of allowed periods* for a CTC of a given state-space size.

## Conjecture 2 — The periodic core is the universal terminal sub-loop

**Claim.** For finite `α` and `e : α → α`, the periodic points `periodicPts e` form an
`e`-invariant subset on which `e` restricts to a bijection (a disjoint union of cycles), and
this restricted system is the **terminal object** among all `(S, e|S)` with `e '' S ⊆ S` on
which `e` is bijective. Categorically: the eventual image `⋂ₙ eⁿ '' α` is the maximal
reversible sub-loop. Formalize the eventual image `⋂ n, Set.range e^[n]` and prove `e` maps it
bijectively onto itself.

**Why bold/testable.** It identifies a canonical "physical sector" of a causal loop — the part
that is genuinely reversible — and characterizes it by a universal property.

## Conjecture 3 — Loop collapse is functorial (Preorder ⥤ PartialOrder, left adjoint)

**Claim.** The collapse `α ↦ Antisymmetrization α (· ≤ ·)` extends to a functor from the
category of preorders (causal structures) and monotone maps to the category of partial orders
(acyclic causal structures), and it is **left adjoint** to the inclusion. I.e. paradox-removal
is the universal acyclic approximation of a causal order. Formalize using Mathlib's
`Preorder`/`PartialOrder` bundled categories and `Antisymmetrization`'s functorial action
(`Preorder_to_PartialOrder`), proving the adjunction unit/counit laws.

**Why bold/testable.** Turns the ad hoc "collapse" into a precise universal construction; the
adjunction is either provable or refutable by exhibiting a counterexample to the universal map.

## Conjecture 4 — Consistency amplitude: counting self-consistent histories

**Claim.** For finite `α` and `e : α → α`, the number of fixed points of `e^[n]` equals the
number of length-`n` closed orbits weighted by divisors:
`Fintype.card (Function.fixedPoints e^[n]) = ∑ d ∣ n, d · (#cycles of length d)`. In
particular the "consistency partition function" `Z(n) := card (fixedPoints e^[n])` is
multiplicative-structured and strictly positive for all `n` divisible by `lcm` of the cycle
lengths. This is the categorical analogue of a CTC path integral over self-consistent
histories.

**Why bold/testable.** A concrete combinatorial identity (Möbius/divisor sum over cycle
lengths) that can be proved in Mathlib and checked against `decide` on small `e`.

## Conjecture 5 — Idempotent stabilization rate (Suschkewitsch threshold)

**Claim.** For a finite monoid `M` with `Nat.card M = N`, every element `a` reaches an
idempotent power within exponent `≤ N`: there is `1 ≤ n ≤ N` with `IsIdempotentElem (a^n)`,
and more sharply `a^(N!)` is idempotent for every `a`. Equivalently, the "index + period" of
every element is `≤ N`. Formalize by bounding the pigeonhole indices `i < j ≤ N` in
`composition_loops_back_monoid` and strengthening `idempotent_power_of_finite` to an explicit
bound.

**Why bold/testable.** Converts the existence statement `idempotent_power_of_finite` into an
effective bound — a measurable "thermalization time" for a categorical loop process; refutable
by any monoid whose elements need exponent `> N`.
