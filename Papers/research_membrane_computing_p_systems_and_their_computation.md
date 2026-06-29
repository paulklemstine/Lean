# Duplication versus Conservation in a Multiset Model of Membrane Computing

## Abstract

We give a minimal, fully formalized multiset-rewriting model of object evolution
in membrane computing (P systems) and prove that a *duplicating* evolution rule
eventually strictly out-populates any *conservative* rule. The development is
machine-checked in Lean 4 (with Mathlib) and is free of `sorry`. The Lean source
is `Catalog/Computation/MembraneComputing.lean`, in the `MembraneComputing`
namespace.

## The model

Fix an object alphabet `α` (an arbitrary type — we do **not** require decidable
equality, so the results apply to objects drawn from any type).

* A **configuration** is a multiset of objects: `Config α := Multiset α`.
* An **object rule** assigns to each object the multiset of objects it produces
  in one step: `ObjRule α := α → Config α`.
* A **synchronous step** rewrites every object in the configuration at once,
  collecting all products: `step r c := c.bind r` (using `Multiset.bind`).
* **Iteration** is `steps r 0 c = c` and `steps r (k+1) c = step r (steps r k c)`.

Two regimes are compared:

* The **duplicating** rule `dupRule a = {a} + {a}` replaces each object by two
  copies of itself.
* A rule is **conservative**, `Conservative r := ∀ a, (r a).card = 1`, when every
  object produces exactly one object (e.g. a pure relabeling).

## Results

Cardinality (population size) is tracked through `Multiset.card`. The lemmas are
established strictly bottom-up, so there is no circular dependency: the
single-step laws are proved directly from the definitions, and the iterated laws
are proved by induction using only the single-step laws.

1. `card_dupRule a : (dupRule a).card = 2` — each object yields two.
2. `card_step_dup c : (step dupRule c).card = 2 * c.card` — one duplicating step
   doubles the population. Proved directly by multiset induction; it does **not**
   use the iterated lemma.
3. `card_step_dup_strict (h : 0 < c.card) : c.card < (step dupRule c).card` — a
   nonempty configuration strictly grows.
4. `card_steps_dup k c : (steps dupRule k c).card = 2 ^ k * c.card` — after `k`
   steps the population grows geometrically. Proved by induction on `k`, using
   only `card_step_dup` in the successor case.
5. `card_step_conservative (h : Conservative r) c : (step r c).card = c.card` —
   one conservative step preserves the population.
6. `relabel_count_const (h : Conservative r) k c : (steps r k c).card = c.card` —
   the population is invariant under any number of conservative steps. Proved by
   induction on `k`, using only `card_step_conservative`.
7. `dup_vs_conservative (h : Conservative r) (hpos : 0 < cDup.card) :`
   `∃ k, (steps dupRule k cDup).card > (steps r k cCons).card` — the main
   theorem.

## Proof of the main theorem

Take the explicit witness `k = cCons.card + 1`. The conservative side keeps its
size by `relabel_count_const`, so `(steps r k cCons).card = cCons.card`. The
duplicating side equals `2 ^ (cCons.card + 1) * cDup.card` by `card_steps_dup`.
The helper lemma `lt_two_pow_succ : n < 2 ^ (n + 1)` (proved by induction) gives
`cCons.card < 2 ^ (cCons.card + 1)`, and since `0 < cDup.card` we have
`2 ^ (cCons.card + 1) ≤ 2 ^ (cCons.card + 1) * cDup.card`. Chaining the two
inequalities yields `cCons.card < (steps dupRule k cDup).card`, which is exactly
the strict inequality required.

## Verification

The file imports `Mathlib`, builds without errors, and contains no `sorry`. The
only axioms used by `dup_vs_conservative` are the standard `propext`,
`Classical.choice`, and `Quot.sound`.
