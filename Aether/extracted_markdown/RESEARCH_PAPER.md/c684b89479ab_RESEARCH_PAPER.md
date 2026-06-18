# A Bridge from Combinatorial EGF Algebra to Tropical / Order Semantics

**File:** `Catalog/Bridges/SpeciesTropicalValuation.lean`

## Overview

This note records a compact, fully formalized bridge connecting the combinatorial algebra
of *exponential generating functions* (EGFs) of counting sequences to the *tropical /
order* semantics carried by the formal power-series valuation `PowerSeries.order`.

The combinatorial side is already developed in
`Catalog/Applications/CombinatorialSpecies.lean`, which defines

* `egf a = ∑ₙ (aₙ / n!) Xⁿ`, the EGF of a counting sequence `a : ℕ → ℚ`, and
* `binConv a b = (n ↦ ∑_{i+j=n} C(n,i) aᵢ bⱼ)`, the binomial (exponential) convolution,

and proves the two structural facts we transport:

* `egf_mul : egf (binConv a b) = egf a * egf b` (binomial convolution ↔ Cauchy product),
* `egf_add : egf (fun n => a n + b n) = egf a + egf b` (additivity of the EGF transform).

## The invariant `ordEGF`

We define the **order valuation of the EGF**:

```lean
noncomputable def ordEGF (a : ℕ → ℚ) : WithTop ℕ := PowerSeries.order (egf a)
```

`PowerSeries.order φ ∈ ℕ∞ = WithTop ℕ` is the index of the lowest nonvanishing coefficient
of `φ` (and `⊤` when `φ = 0`). Concretely, `ordEGF a` is the least `n` with `aₙ ≠ 0`, packaged
as a tropical (extended-natural) value. It is a coarse but robust *order-only profile* of the
sequence: it forgets the magnitudes of the coefficients and keeps only their first support.

## The bridge theorem

The point of the construction is that `ordEGF` intertwines the `(binConv, +)` algebra of
counting sequences with the tropical `(+, min)` semiring on `WithTop ℕ`. Two clean theorems
make this precise, each obtained by transporting an existing power-series order lemma through
the EGF transform.

* **Multiplicative bridge.**
  ```lean
  theorem ordEGF_binConv (a b : ℕ → ℚ) : ordEGF (binConv a b) = ordEGF a + ordEGF b
  ```
  Proof: rewrite by `egf_binConv` and apply `PowerSeries.order_mul`, valid because `ℚ` is an
  integral domain. Thus binomial convolution of sequences becomes *ordinary addition* of
  orders — the multiplicative half of a tropical homomorphism.

* **Additive bridge.**
  ```lean
  theorem ordEGF_add_ge (a b : ℕ → ℚ) : min (ordEGF a) (ordEGF b) ≤ ordEGF (a + b)
  ```
  Proof: rewrite by `egf_add` and apply `PowerSeries.min_order_le_order_add`. Pointwise sums
  are `(min,+)`-superadditive: the order of a sum is at least the min of the orders, with
  strict inequality possible exactly when leading terms cancel.

Together these say that `ordEGF` is a *valuation* in the tropical sense: multiplicative
structure `↦` `+`, additive structure `↦` `min` (as an inequality).

A convenience re-export `egf_binConv` restates `egf_mul` under the name requested by the
bridge interface.

## Species corollary layer

Because `Catalog/Applications/CombinatorialSpecies.lean` packages a counting sequence
`Species.coeffSeq F : ℕ → ℕ` and its EGF `Species.EGF F`, we add a thin corollary layer:

```lean
noncomputable def speciesOrdEGF (F : Species) : WithTop ℕ :=
  ordEGF (fun n => (F.coeffSeq n : ℚ))

theorem speciesOrdEGF_eq_order (F : Species) : speciesOrdEGF F = (F.EGF).order := rfl
```

so the species invariant is literally the order of the species EGF. As a worked example we
record `ordEGF_setSpecies : speciesOrdEGF setSpecies = 0`: the species of sets `E` has EGF
`exp`, whose constant term is `1 ≠ 0`, hence order `0`. We deliberately do not introduce new
species combinators (sum/product of species objects), since the project provides product data
only at the level of type families (`egf_card_prodSpecies`), not as a species-valued operation;
the bridge above already captures the product/addition laws at the sequence level.

## Verification

The file compiles with no `sorry` and no unfinished declarations. The principal theorems
(`ordEGF_binConv`, `ordEGF_add_ge`, `egf_binConv`, `ordEGF_setSpecies`) depend only on the
standard axioms `propext`, `Classical.choice`, `Quot.sound`.
