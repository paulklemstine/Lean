import Mathlib

/-!
# Top-K Robustness: Definitions

Core definitions for the top-`k` certified robustness theory for multiclass
piecewise-linear networks. All definitions avoid sorting machinery and instead
phrase top-`k` membership via pairwise comparison against outside classes.

## Main definitions

* `scoreGap` — The score gap `f(x,i) - f(x,j)` between two classes.
* `finCompl` — The complement of a finset `S` in `Fin n`.
* `crossGaps` — The finite set of all score gaps between classes in `S` and classes outside `S`.
* `topkMargin'` — The minimum score gap across all (in, out) pairs, via `Finset.min'`.
* `IsTopKSet` — Predicate: all classes in `S` weakly dominate all classes outside `S`.
* `StrictTopKSet` — Predicate: all classes in `S` strictly dominate all classes outside `S`.
-/

open Finset

noncomputable section

variable {n : ℕ}

/-- The score gap between class `i` and class `j` at input `x`. -/
def scoreGap {α : Type*} (f : α → Fin n → ℝ) (x : α) (i j : Fin n) : ℝ :=
  f x i - f x j

/-- The complement of `S` in `Fin n`, as a `Finset`. -/
def finCompl (S : Finset (Fin n)) : Finset (Fin n) :=
  Finset.univ.filter fun j => j ∉ S

/-- The finite set of all score gaps `f(x,i) - f(x,j)` for `i ∈ S` and `j ∉ S`. -/
def crossGaps {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Finset ℝ :=
  (S ×ˢ finCompl S).image (fun p => scoreGap f x p.1 p.2)

/-- Nonemptiness of `crossGaps` from nonemptiness of `S` and its complement. -/
theorem crossGaps_nonempty {α : Type*} (f : α → Fin n → ℝ) (x : α)
    (S : Finset (Fin n))
    (hS : S.Nonempty) (hSc : (finCompl S).Nonempty) :
    (crossGaps f x S).Nonempty := by
  rcases hS with ⟨i, hi⟩; rcases hSc with ⟨j, hj⟩
  exact ⟨scoreGap f x i j, Finset.mem_image.mpr
    ⟨(i, j), Finset.mem_product.mpr ⟨hi, hj⟩, rfl⟩⟩

/-- The minimum score gap across all `(i ∈ S, j ∉ S)` pairs.
This is the "top-k margin" — the smallest advantage any in-set class holds
over any out-set class. -/
def topkMargin' {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n))
    (hS : S.Nonempty) (hSc : (finCompl S).Nonempty) : ℝ :=
  (crossGaps f x S).min' (crossGaps_nonempty f x S hS hSc)

/-- `S` is a (weak) top-k set at `x`: every class in `S` has score ≥ every class
outside `S`. -/
def IsTopKSet {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → f x j ≤ f x i

/-- `S` is a strict top-k set at `x`: every class in `S` has score strictly greater
than every class outside `S`. -/
def StrictTopKSet {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → f x j < f x i

/-- A strict top-k set is also a weak top-k set. -/
theorem StrictTopKSet.isTopKSet {α : Type*} {f : α → Fin n → ℝ} {x : α}
    {S : Finset (Fin n)}
    (h : StrictTopKSet f x S) : IsTopKSet f x S :=
  fun _ _ hi hj => le_of_lt (h hi hj)

/-- Membership in `crossGaps` unpacked. -/
theorem mem_crossGaps_iff {α : Type*} {f : α → Fin n → ℝ} {x : α}
    {S : Finset (Fin n)} {r : ℝ} :
    r ∈ crossGaps f x S ↔ ∃ i ∈ S, ∃ j, j ∉ S ∧ r = scoreGap f x i j := by
  simp only [crossGaps, Finset.mem_image, Finset.mem_product, finCompl,
    Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨⟨i, j⟩, ⟨hi, hj⟩, heq⟩
    exact ⟨i, hi, j, hj, heq.symm⟩
  · rintro ⟨i, hi, j, hj, heq⟩
    exact ⟨⟨i, j⟩, ⟨hi, hj⟩, heq.symm⟩

/-- Every `(i, j)` gap with `i ∈ S`, `j ∉ S` is at least the top-k margin. -/
theorem topkMargin'_le_scoreGap {α : Type*} {f : α → Fin n → ℝ} {x : α}
    {S : Finset (Fin n)}
    {hS : S.Nonempty} {hSc : (finCompl S).Nonempty}
    {i j : Fin n} (hi : i ∈ S) (hj : j ∉ S) :
    topkMargin' f x S hS hSc ≤ scoreGap f x i j := by
  apply Finset.min'_le
  simp only [crossGaps, Finset.mem_image, Finset.mem_product, finCompl,
    Finset.mem_filter, Finset.mem_univ, true_and]
  exact ⟨⟨i, j⟩, ⟨hi, hj⟩, rfl⟩

/-- Positive top-k margin implies `StrictTopKSet`. -/
theorem strictTopKSet_of_pos_margin {α : Type*} {f : α → Fin n → ℝ} {x : α}
    {S : Finset (Fin n)}
    {hS : S.Nonempty} {hSc : (finCompl S).Nonempty}
    (hpos : 0 < topkMargin' f x S hS hSc) :
    StrictTopKSet f x S := by
  intro i j hi hj
  have h : topkMargin' f x S hS hSc ≤ scoreGap f x i j :=
    topkMargin'_le_scoreGap hi hj
  simp only [scoreGap] at h
  linarith

end