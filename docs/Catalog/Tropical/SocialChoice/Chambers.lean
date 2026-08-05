/-
# Polyhedral chambers of social decisiveness

The third face of the tropical/social-choice bridge: the *geometry* of a
min-plus aggregator `F x = min_{i ∈ S} (x i + δ i)`.

For each voter `i` in the tropical support `S` the set of profiles on which `i`
attains the social score is the **chamber**

`chamber S δ i = {x | ∀ j ∈ S, x i + δ i ≤ x j + δ j}`,

an intersection of half-spaces.  The chambers are convex polyhedra, they cover
the whole profile space, `F` is affine (indeed a coordinate projection shifted
by a constant) on each of them, and two chambers meet exactly along the wall
where the two tropical monomials agree.  Finally `F` itself is concave, being a
minimum of affine functions.

Main results: `chamber_convex`, `mem_chamber_of_eq_inf'`, `iUnion_chamber`,
`tropAgg_eq_on_chamber`, `wall_eq`, `tropAgg_concave`.
-/
import Mathlib

namespace TropicalChambers

open Finset

variable {ι : Type*}

/-- The tropical aggregator with support `S` and weights `δ`. -/
noncomputable def tropAgg (S : Finset ι) (hS : S.Nonempty) (δ : ι → ℝ) : (ι → ℝ) → ℝ :=
  fun x => S.inf' hS fun i => x i + δ i

/-- The chamber of profiles on which voter `i` attains the social score. -/
def chamber (S : Finset ι) (δ : ι → ℝ) (i : ι) : Set (ι → ℝ) :=
  {x | ∀ j ∈ S, x i + δ i ≤ x j + δ j}

/-- Chambers are convex (they are finite intersections of half-spaces). -/
theorem chamber_convex (S : Finset ι) (δ : ι → ℝ) (i : ι) :
    Convex ℝ (chamber S δ i) := by
  intro x hx y hy a b ha hb hab j hj
  have h1 := hx j hj
  have h2 := hy j hj
  have hxa : (a • x + b • y) i = a * x i + b * y i := rfl
  have hxb : (a • x + b • y) j = a * x j + b * y j := rfl
  rw [hxa, hxb]
  have hδi : a * δ i + b * δ i = δ i := by
    have h : (a + b) * δ i = δ i := by rw [hab, one_mul]
    linarith [h]
  have hδj : a * δ j + b * δ j = δ j := by
    have h : (a + b) * δ j = δ j := by rw [hab, one_mul]
    linarith [h]
  linarith [mul_le_mul_of_nonneg_left h1 ha, mul_le_mul_of_nonneg_left h2 hb]

/-- A minimizing voter lies in the corresponding chamber. -/
theorem mem_chamber_of_eq_inf' {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {x : ι → ℝ}
    {i : ι} (hi : tropAgg S hS δ x = x i + δ i) : x ∈ chamber S δ i := by
  intro j hj
  rw [← hi]
  exact Finset.inf'_le (fun k => x k + δ k) hj

/-- The chambers of the voters in the support cover the whole profile space. -/
theorem iUnion_chamber {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) :
    (⋃ i ∈ S, chamber S δ i) = Set.univ := by
  ext x
  simp only [Set.mem_iUnion, Set.mem_univ, iff_true]
  obtain ⟨i, hiS, hi⟩ := Finset.exists_mem_eq_inf' hS (fun k => x k + δ k)
  exact ⟨i, hiS, mem_chamber_of_eq_inf' hS δ hi⟩

/-- On its chamber the aggregator is the (shifted) projection to that voter. -/
theorem tropAgg_eq_on_chamber {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {i : ι}
    (hiS : i ∈ S) {x : ι → ℝ} (hx : x ∈ chamber S δ i) :
    tropAgg S hS δ x = x i + δ i :=
  le_antisymm (Finset.inf'_le (fun k => x k + δ k) hiS)
    (Finset.le_inf' hS _ (fun j hj => hx j hj))

/-- Two chambers meet exactly along the wall where their tropical monomials
agree. -/
theorem wall_eq {S : Finset ι} (δ : ι → ℝ) {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S)
    {x : ι → ℝ} (hi : x ∈ chamber S δ i) (hj : x ∈ chamber S δ j) :
    x i + δ i = x j + δ j :=
  le_antisymm (hi j hjS) (hj i hiS)

/-- A min-plus aggregator is concave: it is a minimum of affine functions. -/
theorem tropAgg_concave (S : Finset ι) (hS : S.Nonempty) (δ : ι → ℝ) :
    ConcaveOn ℝ Set.univ (tropAgg S hS δ) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ a b ha hb hab
  refine Finset.le_inf' hS _ ?_
  intro j hj
  have hxj : (a • x + b • y) j = a * x j + b * y j := rfl
  have h1 : tropAgg S hS δ x ≤ x j + δ j := Finset.inf'_le (fun k => x k + δ k) hj
  have h2 : tropAgg S hS δ y ≤ y j + δ j := Finset.inf'_le (fun k => y k + δ k) hj
  rw [hxj]
  have hδ : a * δ j + b * δ j = δ j := by
    have h : (a + b) * δ j = δ j := by rw [hab, one_mul]
    linarith [h]
  simp only [smul_eq_mul]
  linarith [mul_le_mul_of_nonneg_left h1 ha, mul_le_mul_of_nonneg_left h2 hb]

end TropicalChambers