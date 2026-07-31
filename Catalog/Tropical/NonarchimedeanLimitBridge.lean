import Mathlib
import Tropical.CornerLocusProduct

/-!
# A non-Archimedean bridge to tropical corner loci

This file isolates a kernel-level form of the hypersurface direction of the
fundamental theorem of tropical geometry.  If finitely many nonzero terms add
to zero over a valued ring, their valuations cannot have a unique maximum.
Thus the valuation data of every classical zero lies in the corresponding
(max-convention) tropical corner locus.

It also gives a finite, weighted correspondence principle for intersection
numbers.  This is the precise combinatorial step used in tropical Bézout once
a multiplicity-preserving correspondence between classical and tropical
intersection points has been constructed.
-/

namespace Tropical

variable {K Γ₀ I X : Type*}

/-- A term is maximal at a point.  This is the max-convention counterpart of
`Tropical.IsMin`. -/
def IsMax [Preorder Γ₀] (f : I → X → Γ₀) (x : X) (i : I) : Prop :=
  ∀ k, f k x ≤ f i x

/-- The maximum of a finite family is attained at two distinct terms. -/
def IsMaxCorner [Preorder Γ₀] (f : I → X → Γ₀) (x : X) : Prop :=
  ∃ i j, i ≠ j ∧ IsMax f x i ∧ IsMax f x j

/-- Reversing signs identifies the max and min conventions. -/
theorem isCorner_neg_iff_isMaxCorner
    [AddCommGroup Γ₀] [LinearOrder Γ₀] [IsOrderedAddMonoid Γ₀]
    (f : I → X → Γ₀) (x : X) :
    IsCorner (fun i x ↦ -f i x) x ↔ IsMaxCorner f x := by
  simp only [IsCorner, IsMin, IsMaxCorner, IsMax, neg_le_neg_iff]

/-- Non-Archimedean cancellation: in a vanishing finite sum of nonzero terms,
no term can have valuation strictly larger than every other term. -/
theorem valuation_max_not_unique
    [DivisionRing K] [LinearOrderedCommMonoidWithZero Γ₀] [Nontrivial Γ₀]
    (v : Valuation K Γ₀) (s : Finset I) (a : I → K)
    (hsum : ∑ i ∈ s, a i = 0) (ha : ∀ i ∈ s, a i ≠ 0)
    {i : I} (hi : i ∈ s) :
    ∃ j ∈ s, j ≠ i ∧ v (a i) ≤ v (a j) := by
  classical
  by_contra h
  push_neg at h
  have hzero : v (a i) ≠ 0 := (v.ne_zero_iff).2 (ha i hi)
  have hlt : ∀ j ∈ s.erase i, v (a j) < v (a i) := by
    intro j hj
    exact h j (Finset.mem_of_mem_erase hj) (Finset.ne_of_mem_erase hj)
  have hvsum : v (∑ j ∈ s.erase i, a j) < v (a i) :=
    v.map_sum_lt hzero hlt
  have hsum' : ∑ j ∈ s.erase i, a j = -a i := by
    have heq := Finset.sum_erase_add s a hi
    rw [hsum] at heq
    exact eq_neg_of_add_eq_zero_left heq
  rw [hsum', v.map_neg] at hvsum
  exact lt_irrefl _ hvsum

/-- Finite hypersurface form of the tropical fundamental theorem (one
inclusion): valuation vectors of classical zeros belong to the tropical corner
locus. -/
theorem valuation_zero_isMaxCorner
    [Fintype I] [DecidableEq I] [Nonempty I] [DivisionRing K]
    [LinearOrderedCommMonoidWithZero Γ₀] [Nontrivial Γ₀]
    (v : Valuation K Γ₀) (term : I → X → K) (x : X)
    (hsum : ∑ i, term i x = 0) (hnonzero : ∀ i, term i x ≠ 0) :
    IsMaxCorner (fun i x ↦ v (term i x)) x := by
  obtain ⟨i, hi, himax⟩ := Finset.exists_max_image Finset.univ
    (fun i => v (term i x)) Finset.univ_nonempty
  obtain ⟨j, hj, hji, hij⟩ := valuation_max_not_unique v Finset.univ
    (fun i => term i x) (by simpa using hsum) (by simp [hnonzero]) hi
  refine ⟨i, j, hji.symm, ?_, ?_⟩
  · intro k
    exact himax k (Finset.mem_univ k)
  · intro k
    exact le_trans (himax k (Finset.mem_univ k)) hij

/-- Rescaling a real-valued tropical polynomial by a positive parameter does
not change its corner locus.  Consequently, the corner locus is stable along
any sequence of valuation scales tending to infinity. -/
theorem isMaxCorner_positive_scale_iff
    (f : I → X → ℝ) (x : X) {c : ℝ} (hc : 0 < c) :
    IsMaxCorner (fun i x ↦ c * f i x) x ↔ IsMaxCorner f x := by
  simp only [IsMaxCorner, IsMax, mul_le_mul_iff_of_pos_left hc]

/-- In particular, every positive integral valuation scale has exactly the same
tropical hypersurface.  This is the exact setwise stabilization statement
behind viewing tropicalization as the infinite-scale limit. -/
theorem cornerLocus_natScale (f : I → X → ℝ) (n : ℕ) :
    {x | IsMaxCorner (fun i x ↦ ((n + 1 : ℕ) : ℝ) * f i x) x} =
      {x | IsMaxCorner f x} := by
  ext x
  exact isMaxCorner_positive_scale_iff f x (by positivity)

/-- Weighted intersection number of a finite intersection set. -/
def intersectionNumber {P : Type*} (s : Finset P) (mult : P → ℕ) : ℕ :=
  ∑ p ∈ s, mult p

/-- A multiplicity-preserving equivalence preserves finite intersection
numbers.  This is the counting bridge underlying tropical correspondence. -/
theorem intersectionNumber_eq_of_equiv
    {P Q : Type*} [DecidableEq P] [DecidableEq Q]
    (s : Finset P) (t : Finset Q) (e : P ≃ Q)
    (he : ∀ p, p ∈ s ↔ e p ∈ t)
    (mP : P → ℕ) (mQ : Q → ℕ)
    (hm : ∀ p ∈ s, mP p = mQ (e p)) :
    intersectionNumber s mP = intersectionNumber t mQ := by
  unfold intersectionNumber
  exact Finset.sum_equiv e he hm

/-- Conditional tropical Bézout bridge: a multiplicity-preserving
correspondence transfers the classical Bézout number `d * e` to the tropical
intersection.  The geometric content needed by later developments is exactly
the supplied correspondence and the classical count. -/
theorem tropical_bezout_of_correspondence
    {P Q : Type*} [DecidableEq P] [DecidableEq Q]
    (classicalPts : Finset P) (tropicalPts : Finset Q) (corr : P ≃ Q)
    (hcorr : ∀ p, p ∈ classicalPts ↔ corr p ∈ tropicalPts)
    (classicalMult : P → ℕ) (tropicalMult : Q → ℕ)
    (hmult : ∀ p ∈ classicalPts,
      classicalMult p = tropicalMult (corr p))
    (d e : ℕ)
    (hbezout : intersectionNumber classicalPts classicalMult = d * e) :
    intersectionNumber tropicalPts tropicalMult = d * e := by
  rw [← hbezout]
  exact (intersectionNumber_eq_of_equiv classicalPts tropicalPts corr hcorr
    classicalMult tropicalMult hmult).symm

end Tropical