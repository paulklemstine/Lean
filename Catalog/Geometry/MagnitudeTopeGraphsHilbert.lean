/-
# Magnitude chains of tope graphs in arbitrary length, and their Vandermonde counts

This file continues `Geometry/MagnitudeTopeGraphs.lean` and
`Geometry/MagnitudeTopeGraphsDiagonal.lean`.  There the magnitude chain generators
`Gen1`, `Gen2`, the differential `δ₂`, the tope graph of the coordinate arrangement in
`ℝⁿ` and its Coxeter Cayley-graph model were introduced, and the bidegree `(2,2)` part of
the magnitude homology was computed.  Here we extend the count of the degree-2 chain
groups and of the cycle groups to *all* lengths `ℓ`, and record the general
finite-graph form of the `(2,2)` computation.

11. **The `(2,2)` computation for an arbitrary finite connected graph.**
    `MH_{2,2}(G) = ker δ₂` is free abelian of rank `#MC_{2,2}(G) - #MC_{1,2}(G)`
    (`finrank_ker_delta2_two`, `MH22_free_of_finite`).

12. **Degree-2 chains of the tope graph in arbitrary length.** A `(2,ℓ)`-chain of the
    tope graph is a tope `y` together with an *ordered pair of nonempty sets of
    hyperplanes* `(a,b)` with `|a| + |b| = ℓ` (`topeGen2EquivGeneral`).

13. **Counting them.** Pairs of subsets of an `n`-set with total size `ℓ` biject with
    `ℓ`-subsets of a `2n`-set, so there are `C(2n,ℓ)` of them (`card_pair_card_sum`);
    discarding the `2·C(n,ℓ)` pairs with an empty member (`card_subsetPair`) gives
    `#MC_{2,ℓ}(topeGraph n) = 2ⁿ · (C(2n,ℓ) - 2·C(n,ℓ))`
    (`card_tope_gen2_general`), which for `ℓ = 2` recovers `2ⁿ·n²`.

14. **The cycle group in arbitrary length.** Since `δ₂` is surjective for `ℓ ≥ 2` and
    `#MC_{1,ℓ} = 2ⁿ·C(n,ℓ)`, the `(2,ℓ)`-cycles of the tope graph form a free abelian
    group of rank `2ⁿ · (C(2n,ℓ) - 3·C(n,ℓ))` (`finrank_tope_cycles_general`,
    `tope_cycles_free_general`); for `ℓ = 2` this is `2ⁿ·C(n+1,2)`, the Hilbert-function
    value obtained before.  Everything transports to the Coxeter Cayley graph of
    `(ℤ/2)ⁿ` (`cayley_cycles_finrank_general`).

Everything is self-contained: only `Mathlib` and the two companion files are imported.
-/

import Mathlib
import Geometry.MagnitudeTopeGraphs
import Geometry.MagnitudeTopeGraphsDiagonal

namespace MagnitudeTope

open Finset

open scoped Classical

/-! ## 11. The `(2,2)` computation for an arbitrary finite connected graph -/

section GeneralFinite

variable {V : Type*} [Finite V] {G : SimpleGraph V}

/-- For a finite connected graph the `(2,2)`-cycles — which form `MH_{2,2}(G)`, since
there are no `(3,2)`-chains — have rank `#MC_{2,2} - #MC_{1,2}`. -/
theorem finrank_ker_delta2_two (hG : G.Connected) :
    Module.finrank ℤ (LinearMap.ker (delta2 hG 2))
      = Nat.card (Gen2 G 2) - Nat.card (Gen1 G 2) := by
  have h := finrank_ker_delta2_add hG (le_refl 2)
  omega

/-- `MH_{2,2}` of a finite connected graph is free abelian of rank
`#MC_{2,2} - #MC_{1,2}`. -/
theorem MH22_free_of_finite (hG : G.Connected) :
    Nonempty (LinearMap.ker (delta2 hG 2) ≃ₗ[ℤ]
      (Fin (Nat.card (Gen2 G 2) - Nat.card (Gen1 G 2)) →₀ ℤ)) :=
  free_of_finrank_eq (finrank_ker_delta2_two hG)

end GeneralFinite

/-! ## 12. Degree-2 chains of the tope graph in arbitrary length -/

section TopeChains

variable {n : ℕ}

/-- A symmetric difference equals its left argument exactly when the right one is empty. -/
lemma symmDiff_eq_left_iff {α : Type*} [DecidableEq α] (s t : Finset α) :
    symmDiff s t = s ↔ t = ∅ := by
  constructor
  · intro h
    have := congrArg (fun u => symmDiff s u) h
    simpa [symmDiff_symmDiff_cancel_left] using this
  · rintro rfl; simp

/-- Ordered pairs of *nonempty* sets of hyperplanes with total size `ℓ`. -/
def SubsetPair (n ℓ : ℕ) : Type :=
  {p : Finset (Fin n) × Finset (Fin n) //
    p.1.Nonempty ∧ p.2.Nonempty ∧ p.1.card + p.2.card = ℓ}

instance (n ℓ : ℕ) : Finite (SubsetPair n ℓ) := Subtype.finite

/-- **Degree-2 magnitude chains of the tope graph in length `ℓ`** are triples: a tope `y`
together with the nonempty sets `a = x Δ y` and `b = y Δ z` of hyperplanes separating it
from the two other topes, of total size `ℓ`. -/
def topeGen2EquivGeneral (n ℓ : ℕ) :
    Gen2 (topeGraph n) ℓ ≃ Finset (Fin n) × SubsetPair n ℓ where
  toFun g := (g.1.2.1, ⟨(symmDiff g.1.1 g.1.2.1, symmDiff g.1.2.1 g.1.2.2), by
      rw [Finset.nonempty_iff_ne_empty]
      intro h
      exact g.2.1 (by simpa [symmDiff_eq_bot] using h), by
      rw [Finset.nonempty_iff_ne_empty]
      intro h
      exact g.2.2.1 (by simpa [symmDiff_eq_bot] using h), by
      rw [← topeGraph_dist, ← topeGraph_dist]; exact g.2.2.2⟩)
  invFun p := ⟨(symmDiff p.1 p.2.1.1, p.1, symmDiff p.1 p.2.1.2), by
      intro h
      exact (Finset.nonempty_iff_ne_empty.mp p.2.2.1) ((symmDiff_eq_left_iff _ _).mp h), by
      intro h
      exact (Finset.nonempty_iff_ne_empty.mp p.2.2.2.1) ((symmDiff_eq_left_iff _ _).mp h.symm),
      by
      rw [topeGraph_dist, topeGraph_dist, symmDiff_comm (symmDiff p.1 p.2.1.1) p.1,
        symmDiff_symmDiff_cancel_left, symmDiff_symmDiff_cancel_left]
      exact p.2.2.2.2⟩
  left_inv g := by
    apply Subtype.ext
    obtain ⟨⟨x, y, z⟩, h1, h2, h3⟩ := g
    simp only [Prod.mk.injEq]
    refine ⟨?_, trivial, ?_⟩
    · rw [symmDiff_comm x y, symmDiff_symmDiff_cancel_left]
    · rw [symmDiff_symmDiff_cancel_left]
  right_inv p := by
    obtain ⟨y, ⟨a, b⟩, hp⟩ := p
    refine Prod.ext rfl (Subtype.ext ?_)
    simp only [Prod.mk.injEq]
    constructor
    · rw [symmDiff_comm (symmDiff y a) y, symmDiff_symmDiff_cancel_left]
    · rw [symmDiff_symmDiff_cancel_left]

/-- A pair of subsets of an `n`-set with total size `ℓ` is the same thing as an
`ℓ`-subset of the disjoint union of two `n`-sets. -/
def pairSumEquiv (n ℓ : ℕ) :
    {p : Finset (Fin n) × Finset (Fin n) // p.1.card + p.2.card = ℓ} ≃
      {S : Finset (Fin n ⊕ Fin n) // S.card = ℓ} where
  toFun p := ⟨p.1.1.disjSum p.1.2, by rw [Finset.card_disjSum]; exact p.2⟩
  invFun S := ⟨(S.1.toLeft, S.1.toRight), by
    rw [Finset.card_toLeft_add_card_toRight]; exact S.2⟩
  left_inv p := by
    apply Subtype.ext
    simp [Finset.toLeft_disjSum, Finset.toRight_disjSum]
  right_inv S := by
    apply Subtype.ext
    simp [Finset.toLeft_disjSum_toRight]

/-- **Vandermonde count.** There are `C(2n,ℓ)` ordered pairs of subsets of an `n`-set with
total size `ℓ`. -/
theorem card_pair_card_sum (n ℓ : ℕ) :
    Nat.card {p : Finset (Fin n) × Finset (Fin n) // p.1.card + p.2.card = ℓ}
      = (2 * n).choose ℓ := by
  rw [Nat.card_congr (pairSumEquiv n ℓ), Nat.card_eq_fintype_card, Fintype.card_finset_len]
  simp [two_mul]

/-- The pairs of subsets of total size `ℓ ≥ 1` with an empty member are exactly the
`2·C(n,ℓ)` pairs `(∅, b)` and `(a, ∅)` with `|a| = |b| = ℓ`. -/
theorem card_pair_with_empty (n ℓ : ℕ) (hl : 1 ≤ ℓ) :
    ((univ.filter (fun p : Finset (Fin n) × Finset (Fin n) => p.1.card + p.2.card = ℓ)).filter
      (fun p => ¬(p.1.Nonempty ∧ p.2.Nonempty))).card = 2 * n.choose ℓ := by
  classical
  have h : ((univ.filter
        (fun p : Finset (Fin n) × Finset (Fin n) => p.1.card + p.2.card = ℓ)).filter
      (fun p => ¬(p.1.Nonempty ∧ p.2.Nonempty)))
      = ((univ : Finset (Fin n)).powersetCard ℓ).image (fun b => ((∅ : Finset (Fin n)), b)) ∪
        ((univ : Finset (Fin n)).powersetCard ℓ).image (fun a => (a, (∅ : Finset (Fin n)))) := by
    ext ⟨a, b⟩
    simp only [Finset.mem_filter, Finset.mem_union, Finset.mem_image, Finset.mem_univ,
      true_and, Finset.mem_powersetCard, Finset.subset_univ,
      Finset.not_nonempty_iff_eq_empty, not_and_or, Prod.mk.injEq]
    constructor
    · rintro ⟨hcard, rfl | rfl⟩
      · exact Or.inl ⟨b, by simpa using hcard, rfl, rfl⟩
      · exact Or.inr ⟨a, by simpa using hcard, rfl, rfl⟩
    · rintro (⟨c, hc, rfl, rfl⟩ | ⟨c, hc, rfl, rfl⟩) <;> simp [hc]
  have hdisj : Disjoint
      (((univ : Finset (Fin n)).powersetCard ℓ).image (fun b => ((∅ : Finset (Fin n)), b)))
      (((univ : Finset (Fin n)).powersetCard ℓ).image (fun a => (a, (∅ : Finset (Fin n))))) := by
    rw [Finset.disjoint_left]
    rintro ⟨a, b⟩ h1 h2
    simp only [Finset.mem_image, Finset.mem_powersetCard, Finset.subset_univ, true_and,
      Prod.mk.injEq] at h1 h2
    obtain ⟨c, hc, rfl, rfl⟩ := h1
    obtain ⟨d, hd, hd1, hd2⟩ := h2
    subst hd1
    simp at hd
    omega
  rw [h, Finset.card_union_of_disjoint hdisj,
    Finset.card_image_of_injective _ (by intro x y hxy; simpa using hxy),
    Finset.card_image_of_injective _ (by intro x y hxy; simpa using hxy),
    Finset.card_powersetCard]
  simp [two_mul]

/-- **The number of ordered pairs of nonempty sets of hyperplanes of total size `ℓ ≥ 1`**
is `C(2n,ℓ) - 2·C(n,ℓ)`. -/
theorem card_subsetPair (n ℓ : ℕ) (hl : 1 ≤ ℓ) :
    Nat.card (SubsetPair n ℓ) + 2 * n.choose ℓ = (2 * n).choose ℓ := by
  classical
  set s : Finset (Finset (Fin n) × Finset (Fin n)) :=
    univ.filter (fun p => p.1.card + p.2.card = ℓ) with hs
  have hcard_s : s.card = (2 * n).choose ℓ := by
    rw [← card_pair_card_sum n ℓ, Nat.card_eq_fintype_card, Fintype.card_subtype]
  have hsub : Nat.card (SubsetPair n ℓ)
      = (s.filter (fun p => p.1.Nonempty ∧ p.2.Nonempty)).card := by
    unfold SubsetPair
    rw [Nat.card_eq_fintype_card, Fintype.card_subtype, hs, Finset.filter_filter]
    congr 1
    apply Finset.filter_congr
    intro p _
    constructor
    · rintro ⟨h1, h2, h3⟩; exact ⟨h3, h1, h2⟩
    · rintro ⟨h3, h1, h2⟩; exact ⟨h1, h2, h3⟩
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := s) (p := fun p => p.1.Nonempty ∧ p.2.Nonempty)
  rw [hsub, card_pair_with_empty n ℓ hl, hcard_s] at *
  omega

/-- **The rank of `MC_{2,ℓ}` of the tope graph is `2ⁿ · (C(2n,ℓ) - 2·C(n,ℓ))`.** -/
theorem card_tope_gen2_general (n ℓ : ℕ) (hl : 1 ≤ ℓ) :
    Nat.card (Gen2 (topeGraph n) ℓ) + 2 ^ n * (2 * n.choose ℓ)
      = 2 ^ n * (2 * n).choose ℓ := by
  have hcard : Nat.card (Gen2 (topeGraph n) ℓ) = 2 ^ n * Nat.card (SubsetPair n ℓ) := by
    rw [Nat.card_congr (topeGen2EquivGeneral n ℓ), Nat.card_prod]
    congr 1
    simp [Nat.card_eq_fintype_card]
  rw [hcard, ← Nat.mul_add, card_subsetPair n ℓ hl]

/-- Consistency check: for `ℓ = 2` the general count recovers `#MC_{2,2} = 2ⁿ·n²`. -/
theorem card_tope_gen2_general_two (n : ℕ) :
    Nat.card (Gen2 (topeGraph n) 2) = 2 ^ n * (n * n) :=
  card_tope_gen2 n

end TopeChains

/-! ## 14. The cycle group of the tope graph in arbitrary length -/

section TopeCycles

variable {n : ℕ}

/-- **The `(2,ℓ)`-cycles of the tope graph** form a free abelian group of rank
`2ⁿ · (C(2n,ℓ) - 3·C(n,ℓ))` for every `ℓ ≥ 2`. -/
theorem finrank_tope_cycles_general (n ℓ : ℕ) (hl : 2 ≤ ℓ) :
    Module.finrank ℤ (LinearMap.ker (delta2 (topeGraph_connected n) ℓ))
        + 2 ^ n * (3 * n.choose ℓ)
      = 2 ^ n * (2 * n).choose ℓ := by
  have h1 := finrank_ker_delta2_add (topeGraph_connected n) hl
  rw [card_tope_gen1 n ℓ (by omega)] at h1
  have h2 := card_tope_gen2_general n ℓ (by omega)
  have h3 : 2 ^ n * (3 * n.choose ℓ)
      = 2 ^ n * n.choose ℓ + 2 ^ n * (2 * n.choose ℓ) := by ring
  omega

/-- The `(2,ℓ)`-cycles of the tope graph are free abelian. -/
theorem tope_cycles_free_general (n ℓ : ℕ) (hl : 2 ≤ ℓ) :
    Nonempty (LinearMap.ker (delta2 (topeGraph_connected n) ℓ) ≃ₗ[ℤ]
      (Fin (2 ^ n * (2 * n).choose ℓ - 2 ^ n * (3 * n.choose ℓ)) →₀ ℤ)) := by
  refine free_of_finrank_eq ?_
  have := finrank_tope_cycles_general n ℓ hl
  omega

/-- Consistency check: for `ℓ = 2` the general rank formula recovers the Hilbert-function
value `2ⁿ · C(n+1,2)`. -/
theorem finrank_tope_cycles_general_two (n : ℕ) :
    Module.finrank ℤ (LinearMap.ker (delta2 (topeGraph_connected n) 2))
      = 2 ^ n * (n + 1).choose 2 :=
  topeMH22_finrank n

/-- The same rank formula holds for the Cayley graph of the Coxeter group `(ℤ/2)ⁿ`. -/
theorem cayley_cycles_finrank_general (n ℓ : ℕ) (hl : 2 ≤ ℓ) :
    Module.finrank ℤ (LinearMap.ker (delta2 (cayleyGraph_connected n) ℓ))
        + 2 ^ n * (3 * n.choose ℓ)
      = 2 ^ n * (2 * n).choose ℓ := by
  obtain ⟨f⟩ := ker_delta2_equiv (topeIsoCayley n) (topeGraph_connected n)
    (cayleyGraph_connected n) ℓ
  rw [← f.finrank_eq]
  exact finrank_tope_cycles_general n ℓ hl

end TopeCycles

end MagnitudeTope