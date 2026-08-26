import Geometry.KernelPatterns.BellRecursion
import Geometry.KernelPatterns.BraidFlats

/-!
# Synthesis: one classification theorem, four counting corollaries

The three strands of `Geometry.KernelPatterns` meet here.

* Algebraic: kernel patterns classify the orbits of the diagonal symmetric
  group action (`orbit_card_eq_bell`).
* Combinatorial: they are the set partitions, counted with `k` blocks by the
  Stirling numbers and in total by the Bell numbers, giving the classical
  identity `bell n = Σ_k S(n,k)` (`bell_eq_sum_stirlingSecond`) — both sides of
  which are Mathlib definitions given purely by recursions.
* Geometric: they are the flats of the braid arrangement in `ℝ^n`, so the
  intersection lattice of the braid arrangement has `Nat.bell n` elements
  (`card_braidFlats_eq_bell`).
-/

namespace Geometry.KernelPatterns

open Finset

/-- **`bell n = Σ_k S(n,k)`.**  Mathlib defines `Nat.bell` by the binomial
recursion and `Nat.stirlingSecond` by the triangle recursion; the two are
connected here through the common combinatorial model of kernel patterns. -/
theorem bell_eq_sum_stirlingSecond (n : ℕ) :
    Nat.bell n = ∑ k ∈ range (n + 1), Nat.stirlingSecond n k := by
  rw [← card_patterns_eq_sum_stirlingSecond, card_patterns_eq_bell]

/-- The number of equivalence relations on any finite type is the Bell number of
its cardinality. -/
theorem card_setoid_eq_bell (α : Type*) [Fintype α] :
    Nat.card (Setoid α) = Nat.bell (Fintype.card α) := by
  rw [card_setoid_of_card_eq, card_patterns_eq_bell]

/-- **Orbit count.**  As soon as there are at least as many available values as
positions, the diagonal `Sym(Fin m)`-action on `n`-tuples has exactly
`Nat.bell n` orbits. -/
theorem orbit_card_eq_bell {n m : ℕ} (h : n ≤ m) :
    Nat.card (MulAction.orbitRel.Quotient (Equiv.Perm (Fin m)) (Fin n → Fin m))
      = Nat.bell n := by
  rw [orbit_card_eq_card_patterns, patterns_stabilise h, card_patterns_eq_bell]

/-- **The intersection lattice of the braid arrangement in `ℝ^n` has `Nat.bell n`
elements.** -/
theorem card_braidFlats_eq_bell (n : ℕ) : Nat.card (braidFlats n) = Nat.bell n := by
  rw [card_braidFlats, card_patterns_eq_bell]

/-- Refined geometric count: the flats of dimension `k` are counted by the
Stirling number `S(n,k)`. -/
theorem card_braidFlats_dim (n k : ℕ) :
    ((patterns n n).filter fun p =>
        Module.finrank ℝ (braidFlat p) = k).card = Nat.stirlingSecond n k := by
  rw [← card_patternsWith_eq_stirlingSecond]
  refine congrArg Finset.card (Finset.filter_congr fun p hp => ?_)
  rw [mem_patterns_self] at hp
  rw [finrank_braidFlat, hp]

end Geometry.KernelPatterns