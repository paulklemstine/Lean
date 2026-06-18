# The order valuation `ordEGF` of a combinatorial species and its tropical interpretation

## Summary

This development extends the species ↔ exponential-generating-function (EGF) dictionary already
formalized in `Catalog/Applications/CombinatorialSpecies.lean` from *order-only enumerative data*
toward a genuine **tropical (min-plus) interpretation**. The new file
`Catalog/Bridges/SpeciesTropicalValuation.lean` introduces the order valuation `ordEGF` of a
species and proves that it is compatible with the species product and the species sum in exactly the
way a valuation is compatible with multiplication and addition — that is, it is a tropical-semiring
shadow of the combinatorial calculus of species.

All declarations compile against Mathlib (Lean `v4.28.0`) with no `sorry`, and the main theorems use
only the standard axioms `propext`, `Classical.choice`, and `Quot.sound`.

## Definitions used

The base file provides:

* `CombinatorialSpecies.Species` — a species in skeletal form: a family `obj : ℕ → Type` of finite
  structure sets together with a functorial action `act n : Equiv.Perm (Fin n) →* Equiv.Perm (obj n)`
  of the relabelling group.
* `Species.coeffSeq F n = Fintype.card (F.obj n)` — the counting sequence.
* `egf a = PowerSeries.mk (fun n => a n / n!)` — the EGF of a counting sequence `a : ℕ → ℚ`.
* `Species.EGF F = egf (fun n => (F.coeffSeq n : ℚ))` — the EGF of a species.
* `egf_add`, `egf_mul`, `binConv`, `card_prodSpecies`, `egf_card_prodSpecies` — the additive and
  multiplicative (Day-convolution / binomial-convolution) bridges.

The new file adds:

* **`ordEGF F = PowerSeries.order F.EGF : ℕ∞`** — the *order valuation* of a species: the index of
  the lowest non-vanishing coefficient of its EGF, equivalently the size of the smallest label set
  carrying an `F`-structure. The order of a power series is the prototypical discrete valuation, and
  `ℕ∞ = (ℕ ∪ {∞})` carrying `(min, +)` is the **tropical (min-plus) semiring**.

* **`Species.add F G`** — the disjoint union (sum) of species, `(F ⊕ G)[n] = F[n] ⊕ G[n]`, with the
  diagonal relabelling action assembled from `Equiv.Perm.sumCongrHom` and the two component actions.
  Its counting law is `coeffSeq_add` and its EGF law is `EGF_add` (the species-level form of
  `egf_add`).

## Completed theorems

1. **`ordEGF_structProd`** (tropical multiplication law, `⊙ = +`).
   For species `A`, `B`, the order of the EGF of their *structural (Day-convolution) product* —
   whose `n`-th structure set is `Σ S ⊆ [n], A[|S|] × B[n∖S]` — equals the sum of the orders:
   ```
   (egf (fun n => Fintype.card (Σ S : Finset (Fin n), A.obj S.card × B.obj (n - S.card)))).order
     = ordEGF A + ordEGF B
   ```

2. **`ordEGF_add_min_le`** (tropical addition law, `⊕ = min`).
   For species `F`, `G`,
   ```
   min (ordEGF F) (ordEGF G) ≤ ordEGF (F.add G)
   ```

3. **`ordEGF_setSpecies`** and **`ordEGF_linearOrderSpecies`** (the tropical unit).
   Both the species of sets `E` and the species of linear orders `L` have `ordEGF = 0`, because each
   carries a structure on the empty label set (one set; `0! = 1` orders).

A supporting general lemma `ordEGF_eq_zero_of_coeffSeq_zero_ne` records that a non-zero count on the
empty label set forces order `0`.

## Proof strategy

* **Multiplication law.** The single decisive input is the already-proved EGF product bridge
  `egf_card_prodSpecies`, which identifies the EGF of the structural product with the *product* of
  the two EGFs in `ℚ⟦X⟧`. Multiplicativity of the order valuation, `PowerSeries.order_mul`, then
  gives the additive law on orders. `order_mul` requires `NoZeroDivisors`, which holds because `ℚ`
  is a field; this is exactly the place where the *valuation* property (sending products to sums) is
  used, and it is the heart of the tropical correspondence. After rewriting, the two sides are
  definitionally equal (`coeffSeq` unfolds to `Fintype.card ∘ obj`), so `rfl` closes the goal.

* **Addition law.** `Species.add` is built so that `coeffSeq_add` holds (`Fintype.card_sum`), whence
  `EGF_add` follows from `egf_add` after a `push_cast`/`ring` normalization of the natural-number
  sum. The general power-series fact `PowerSeries.min_order_le_order_add` then yields the tropical
  inequality. Note this is genuinely an inequality, not an equality: the leading coefficients of two
  EGFs of the same order could in principle cancel, raising the order of the sum. For the disjoint
  union of *species* the counting sequences are non-negative integers, so no cancellation occurs and
  the bound is the right tropical-shaped statement.

* **Base computations.** For a species with `coeffSeq 0 ≠ 0`, the constant coefficient of the EGF is
  `(coeffSeq 0)/0! = coeffSeq 0 ≠ 0`; `PowerSeries.order_le` then bounds the order above by `0`, and
  antisymmetry with the trivial lower bound gives `ordEGF = 0`.

## Tropical / valuation consequence obtained

Writing `(ℕ∞, min, +)` for the tropical semiring, the results assemble into the statement that
`ordEGF` is a **tropical shadow of the combinatorial calculus of species**:

* it sends the species product to tropical multiplication (`ordEGF (A · B) = ordEGF A ⊙ ordEGF B`,
  i.e. `ordEGF A + ordEGF B`);
* it sends the species sum to (a bound by) tropical addition
  (`ordEGF (F ⊕ G) ≥ ordEGF F ⊕ ordEGF G`, i.e. `min (ordEGF F) (ordEGF G)`);
* it sends the multiplicative units `E` and `L` to the tropical unit `0`.

Concretely, the "earliest label size at which a structure appears" behaves additively under the
combinatorial product and min-subadditively under disjoint union — the defining laws of a valuation,
now realized directly on Joyal's species rather than on abstract power series.
