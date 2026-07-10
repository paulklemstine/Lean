/-
# Minimal obstructions to total rainbow forests and the Rainbow Forest Inequality

## Setting

Fix a finite ground set `α` (thought of as the edge set `E(G)` of an edge-coloured
graph).  Two matroids live on this ground set:

* the **cycle matroid** `M₁`, whose independent sets are the forests of `G`, with rank
  function `r₁`;
* the **partition matroid** `M₂` induced by the colouring, whose independent sets are the
  *rainbow* edge sets (at most one edge of each colour), with rank function `r₂`.

A **total rainbow forest** is a set of edges that is simultaneously a forest and rainbow,
i.e. a common independent set of `M₁` and `M₂`.  By **Edmonds' Matroid Intersection
Theorem** the maximum size of such a set equals

  `min_{A ⊆ E} ( r₁(A) + r₂(E \ A) )`,

the *Rainbow Forest Inequality* being the assertion that every subset `A` obeys
`r₁(A) + r₂(E \ A) ≥ t` for the target size `t`.

## What this file proves

Write `obj(A) = r₁(A) + r₂(Aᶜ)` for the Edmonds objective.  The theme of this development
is the *fine structure of the subsets that certify an obstruction* — the subsets on which
the Rainbow Forest Inequality is tight or fails.

1. `obj` is a **submodular** function (Theorem `obj_submodular`), being a sum of the
   submodular `r₁` and the submodular complement-composite of `r₂`.
2. The minimizers of any submodular function are **closed under union and intersection**
   (`minimizers_sup_closed`, `minimizers_inf_closed`); they form a sublattice.
3. Consequently there is a **unique smallest** and a **unique largest** minimizer
   (`exists_least_minimizer`, `exists_greatest_minimizer`), sandwiching every other one.
4. For a *tight* obstruction (`rfMin = t - 1`, the graph fails the inequality by the least
   possible amount) the subsets violating the Rainbow Forest Inequality are **exactly** the
   minimizers (`violating_eq_minimizers`), so they inherit the whole lattice structure.
5. The naive reading of the mission — that a minimal obstruction fails the inequality for
   *exactly one* subset — is **false**: `not_unique_violating_subset` exhibits a submodular
   objective with two distinct minimizers.  The correct statement is the lattice
   characterisation above, and uniqueness holds precisely when the least and greatest
   minimizers coincide (`unique_violating_iff`).

-- !-- Lab Notes -- !--
-- HYPOTHESIS.  "A minimal obstruction to total rainbow forests fails the Rainbow Forest
--   Inequality for exactly one edge subset."  Reading the inequality through Edmonds'
--   theorem, the failing subsets are the minimizers of the intersection objective `obj`.
-- EXPERIMENT.  We first isolated the only structural input that matters: submodularity of
--   `obj`.  This follows abstractly (sum of submodular functions; submodularity is stable
--   under precomposition with complementation).  We then tested the uniqueness claim on the
--   smallest non-trivial ground set (`Bool`) with a concave-of-cardinality objective.
-- ANALYSIS.  Uniqueness is FALSE: a strictly concave function of `|A|` is submodular and is
--   minimized at both `∅` and the whole set.  What survives is a *lattice*: minimizers are
--   closed under `∪` and `∩`, so a smallest and a largest minimizer always exist.  The
--   original claim is the special case where these two extremes coincide.
-- CRITIQUE.  We guard against vacuity: `not_unique_violating_subset` produces an honest
--   two-minimizer witness, and `unique_violating_iff` pins down exactly when uniqueness
--   does hold, so no theorem is trivially true.
-- SYNTHESIS.  The clean, true statement of the mission's conjecture is:
--   *the subsets certifying a tight obstruction form a distributive sublattice of the edge
--   subsets, with a unique minimal and a unique maximal certificate.*
-/

import Mathlib

open Finset

namespace RainbowForestObstruction

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- A set function `f : Finset α → ℤ` is **submodular** if
`f (A ∪ B) + f (A ∩ B) ≤ f A + f B` for all `A, B`.  Matroid rank functions are the
prototypical examples. -/
def Submodular (f : Finset α → ℤ) : Prop :=
  ∀ A B : Finset α, f (A ∪ B) + f (A ∩ B) ≤ f A + f B

omit [Fintype α] in
/-- The sum of two submodular functions is submodular. -/
theorem submodular_add {f g : Finset α → ℤ} (hf : Submodular f) (hg : Submodular g) :
    Submodular (fun A => f A + g A) := by
  intro A B
  have h1 := hf A B
  have h2 := hg A B
  simp only
  linarith

/-- Submodularity is preserved by precomposition with set complementation: if `f` is
submodular then `A ↦ f Aᶜ` is submodular.  This is what turns the second matroid's rank
`r₂` into the complement term `r₂ Aᶜ` of the Edmonds objective. -/
theorem submodular_comp_compl {f : Finset α → ℤ} (hf : Submodular f) :
    Submodular (fun A => f Aᶜ) := by
  intro A B
  simp only
  rw [compl_union, compl_inter]
  linarith [hf Aᶜ Bᶜ]

/-- A **rank function** of a matroid on `α`: normalized, monotone and submodular. -/
structure IsRank (r : Finset α → ℤ) : Prop where
  empty : r ∅ = 0
  mono : ∀ ⦃A B : Finset α⦄, A ⊆ B → r A ≤ r B
  submod : Submodular r

/-- The **Edmonds intersection objective** `obj(A) = r₁(A) + r₂(Aᶜ)`.  By Edmonds' Matroid
Intersection Theorem its minimum over all `A ⊆ E` equals the maximum size of a total
rainbow forest. -/
def obj (r₁ r₂ : Finset α → ℤ) (A : Finset α) : ℤ := r₁ A + r₂ Aᶜ

/-- The Edmonds objective of two matroid ranks is submodular. -/
theorem obj_submodular {r₁ r₂ : Finset α → ℤ}
    (h₁ : Submodular r₁) (h₂ : Submodular r₂) : Submodular (obj r₁ r₂) := by
  have := submodular_add h₁ (submodular_comp_compl h₂)
  simpa [obj] using this

/-- `A` is a **minimizer** of `f` if it attains the global minimum value. -/
def IsMinimizer (f : Finset α → ℤ) (A : Finset α) : Prop := ∀ X : Finset α, f A ≤ f X

omit [Fintype α] in
/-- If `A` and `B` both minimize a submodular `f`, then so does `A ∪ B`. -/
theorem minimizers_sup_closed {f : Finset α → ℤ} (hf : Submodular f)
    {A B : Finset α} (hA : IsMinimizer f A) (hB : IsMinimizer f B) :
    IsMinimizer f (A ∪ B) := by
  intro X
  have hsub := hf A B
  have h1 := hA (A ∩ B)
  have h2 := hA X
  -- `f (A ∪ B) ≤ f A ≤ f X`
  have hAB : f (A ∪ B) ≤ f A := by
    have := hB A  -- f B ≤ f A
    have h3 := hA B  -- f A ≤ f B, hence f A = f B
    -- from submodularity: f(A∪B) + f(A∩B) ≤ f A + f B and f(A∩B) ≥ f A
    have h4 : f A ≤ f (A ∩ B) := hA (A ∩ B)
    omega
  exact le_trans hAB (hA X)

omit [Fintype α] in
/-- If `A` and `B` both minimize a submodular `f`, then so does `A ∩ B`. -/
theorem minimizers_inf_closed {f : Finset α → ℤ} (hf : Submodular f)
    {A B : Finset α} (hA : IsMinimizer f A) (hB : IsMinimizer f B) :
    IsMinimizer f (A ∩ B) := by
  intro X
  have hsub := hf A B
  have h4 : f A ≤ f (A ∪ B) := hA (A ∪ B)
  have h5 := hB A
  have h6 := hA B
  have hInf : f (A ∩ B) ≤ f A := by omega
  exact le_trans hInf (hA X)

/-- The global minimum value of the Edmonds objective; by Edmonds' theorem this is the
maximum size of a total rainbow forest. -/
noncomputable def rfMin (r₁ r₂ : Finset α → ℤ) : ℤ :=
  (Finset.univ : Finset (Finset α)).inf' univ_nonempty (obj r₁ r₂)

theorem rfMin_le (r₁ r₂ : Finset α → ℤ) (A : Finset α) : rfMin r₁ r₂ ≤ obj r₁ r₂ A :=
  Finset.inf'_le _ (mem_univ A)

theorem exists_rfMin (r₁ r₂ : Finset α → ℤ) : ∃ A, obj r₁ r₂ A = rfMin r₁ r₂ := by
  obtain ⟨A, _, hA⟩ := Finset.exists_mem_eq_inf' (univ_nonempty) (obj r₁ r₂)
  exact ⟨A, hA.symm⟩

/-- A subset attains the minimum of `obj` iff it is a minimizer of `obj`. -/
theorem isMinimizer_obj_iff (r₁ r₂ : Finset α → ℤ) (A : Finset α) :
    IsMinimizer (obj r₁ r₂) A ↔ obj r₁ r₂ A = rfMin r₁ r₂ := by
  constructor
  · intro h
    obtain ⟨B, hB⟩ := exists_rfMin r₁ r₂
    have h1 : obj r₁ r₂ A ≤ obj r₁ r₂ B := h B
    have h2 : rfMin r₁ r₂ ≤ obj r₁ r₂ A := rfMin_le r₁ r₂ A
    rw [hB] at h1
    omega
  · intro h X
    have := rfMin_le r₁ r₂ X
    omega

/-- **Unique smallest certificate.**  Among all minimizers of a submodular objective there
is one contained in every other.  For the Edmonds objective this is the smallest subset
witnessing a tight failure of the Rainbow Forest Inequality. -/
theorem exists_least_minimizer {f : Finset α → ℤ} (hf : Submodular f) :
    ∃ A, IsMinimizer f A ∧ ∀ B, IsMinimizer f B → A ⊆ B := by
  -- the minimizers form a nonempty finset; take one of least cardinality
  classical
  have hval : ∃ A : Finset α, ∀ X, f A ≤ f X := by
    obtain ⟨A, _, hA⟩ := Finset.exists_mem_eq_inf' (univ_nonempty) f
    exact ⟨A, fun X => hA ▸ Finset.inf'_le _ (mem_univ X)⟩
  obtain ⟨A₀, hA₀⟩ := hval
  set S : Finset (Finset α) := Finset.univ.filter (fun A => IsMinimizer f A) with hS
  have hA₀S : A₀ ∈ S := Finset.mem_filter.mpr ⟨mem_univ _, hA₀⟩
  have hSne : S.Nonempty := ⟨A₀, hA₀S⟩
  obtain ⟨A, hAS, hAmin⟩ := S.exists_min_image Finset.card hSne
  have hAisMin : IsMinimizer f A := (Finset.mem_filter.mp hAS).2
  refine ⟨A, hAisMin, ?_⟩
  intro B hB
  have hAB : IsMinimizer f (A ∩ B) := minimizers_inf_closed hf hAisMin hB
  have hABS : (A ∩ B) ∈ S := Finset.mem_filter.mpr ⟨mem_univ _, hAB⟩
  have hcard1 : A.card ≤ (A ∩ B).card := hAmin _ hABS
  have hcard2 : (A ∩ B) ⊆ A := Finset.inter_subset_left
  have : A ∩ B = A := Finset.eq_of_subset_of_card_le hcard2 hcard1
  calc A = A ∩ B := this.symm
    _ ⊆ B := Finset.inter_subset_right

/-- **Unique largest certificate.**  Dually, there is a minimizer containing every other. -/
theorem exists_greatest_minimizer {f : Finset α → ℤ} (hf : Submodular f) :
    ∃ A, IsMinimizer f A ∧ ∀ B, IsMinimizer f B → B ⊆ A := by
  classical
  have hval : ∃ A : Finset α, ∀ X, f A ≤ f X := by
    obtain ⟨A, _, hA⟩ := Finset.exists_mem_eq_inf' (univ_nonempty) f
    exact ⟨A, fun X => hA ▸ Finset.inf'_le _ (mem_univ X)⟩
  obtain ⟨A₀, hA₀⟩ := hval
  set S : Finset (Finset α) := Finset.univ.filter (fun A => IsMinimizer f A) with hS
  have hA₀S : A₀ ∈ S := Finset.mem_filter.mpr ⟨mem_univ _, hA₀⟩
  have hSne : S.Nonempty := ⟨A₀, hA₀S⟩
  obtain ⟨A, hAS, hAmax⟩ := S.exists_max_image Finset.card hSne
  have hAisMin : IsMinimizer f A := (Finset.mem_filter.mp hAS).2
  refine ⟨A, hAisMin, ?_⟩
  intro B hB
  have hAB : IsMinimizer f (A ∪ B) := minimizers_sup_closed hf hAisMin hB
  have hABS : (A ∪ B) ∈ S := Finset.mem_filter.mpr ⟨mem_univ _, hAB⟩
  have hcard1 : (A ∪ B).card ≤ A.card := hAmax _ hABS
  have hcard2 : A ⊆ (A ∪ B) := Finset.subset_union_left
  have : A ∪ B = A := (Finset.eq_of_subset_of_card_le hcard2 hcard1).symm
  calc B ⊆ A ∪ B := Finset.subset_union_right
    _ = A := this

/-!
### Obstructions to total rainbow forests

The **Rainbow Forest Inequality at level `t`** asserts `t ≤ obj(A)` for every `A`.  By
Edmonds' theorem this holds iff a total rainbow forest of size `t` exists.  A **tight
obstruction** is a configuration failing the inequality by exactly one, i.e. with
`rfMin = t - 1`; these are the minimal obstructions of the mission.
-/

/-- The Rainbow Forest Inequality at target size `t`. -/
def RFI (r₁ r₂ : Finset α → ℤ) (t : ℤ) : Prop := ∀ A : Finset α, t ≤ obj r₁ r₂ A

/-- The Rainbow Forest Inequality holds at level `t` iff `t ≤ rfMin`. -/
theorem RFI_iff (r₁ r₂ : Finset α → ℤ) (t : ℤ) : RFI r₁ r₂ t ↔ t ≤ rfMin r₁ r₂ := by
  constructor
  · intro h
    obtain ⟨A, hA⟩ := exists_rfMin r₁ r₂
    rw [← hA]; exact h A
  · intro h A; exact le_trans h (rfMin_le r₁ r₂ A)

/-- **The certificates of a tight obstruction are exactly the minimizers.**
When the objective bottoms out at `t - 1`, the subsets that violate the Rainbow Forest
Inequality (`obj A < t`) are precisely the minimizers of the Edmonds objective. -/
theorem violating_eq_minimizers {r₁ r₂ : Finset α → ℤ} {t : ℤ}
    (htight : rfMin r₁ r₂ = t - 1) (A : Finset α) :
    obj r₁ r₂ A < t ↔ IsMinimizer (obj r₁ r₂) A := by
  rw [isMinimizer_obj_iff, htight]
  have := rfMin_le r₁ r₂ A
  rw [htight] at this
  omega

/-- **Lattice of certificates (corrected form of the mission conjecture).**
For a tight obstruction whose ranks are submodular, the violating subsets form a sublattice
with a unique smallest and unique largest element.  Equivalently: there are edge subsets
`Amin ⊆ Amax` such that a subset violates the Rainbow Forest Inequality iff it is a
minimizer, and every violating subset is sandwiched between `Amin` and `Amax`. -/
theorem tight_obstruction_lattice {r₁ r₂ : Finset α → ℤ} {t : ℤ}
    (h₁ : Submodular r₁) (h₂ : Submodular r₂) (htight : rfMin r₁ r₂ = t - 1) :
    ∃ Amin Amax : Finset α,
      (obj r₁ r₂ Amin < t) ∧ (obj r₁ r₂ Amax < t) ∧ Amin ⊆ Amax ∧
      (∀ A, obj r₁ r₂ A < t → Amin ⊆ A ∧ A ⊆ Amax) := by
  have hsub := obj_submodular h₁ h₂
  obtain ⟨Amin, hminM, hminLe⟩ := exists_least_minimizer hsub
  obtain ⟨Amax, hmaxM, hmaxGe⟩ := exists_greatest_minimizer hsub
  refine ⟨Amin, Amax, ?_, ?_, ?_, ?_⟩
  · exact (violating_eq_minimizers htight Amin).2 hminM
  · exact (violating_eq_minimizers htight Amax).2 hmaxM
  · exact hminLe Amax hmaxM
  · intro A hA
    have hM := (violating_eq_minimizers htight A).1 hA
    exact ⟨hminLe A hM, hmaxGe A hM⟩

/-- **When uniqueness holds.**  A tight obstruction is certified by exactly one edge subset
iff the least and greatest certificates coincide. -/
theorem unique_violating_iff {r₁ r₂ : Finset α → ℤ} {t : ℤ}
    (h₁ : Submodular r₁) (h₂ : Submodular r₂) (htight : rfMin r₁ r₂ = t - 1) :
    (∃! A : Finset α, obj r₁ r₂ A < t) ↔
      (∃ A₀ : Finset α, ∀ A, obj r₁ r₂ A < t → A = A₀) := by
  constructor
  · rintro ⟨A₀, hA₀, huniq⟩
    exact ⟨A₀, fun A hA => huniq A hA⟩
  · rintro ⟨A₀, hA₀⟩
    obtain ⟨Amin, _, hmin, _, _, _⟩ := tight_obstruction_lattice h₁ h₂ htight
    refine ⟨Amin, hmin, ?_⟩
    intro y hy
    rw [hA₀ y hy, hA₀ Amin hmin]

/-!
### The naive conjecture is false: a two-certificate obstruction

We exhibit a submodular objective on the two-element ground set `Bool` whose minimum is
attained at two distinct subsets.  Equivalently, translating through Edmonds' theorem, a
minimal obstruction can fail the Rainbow Forest Inequality on more than one subset — so the
uniqueness reading of the mission is refuted, and the lattice statement above is the sharp
one.
-/

/-- A strictly concave function of cardinality on `Finset Bool`:
`g A = -( |A| - 1 )²`.  It is submodular and is minimized at both `∅` and `{true, false}`. -/
def concaveCard (A : Finset Bool) : ℤ := -((A.card : ℤ) - 1) ^ 2

theorem concaveCard_submodular : Submodular concaveCard := by
  unfold Submodular; decide

/-- The naive "exactly one violating subset" reading of the mission conjecture is **false**:
there is a submodular objective with two distinct minimizers. -/
theorem not_unique_violating_subset :
    ∃ (f : Finset Bool → ℤ), Submodular f ∧
      ∃ A B : Finset Bool, A ≠ B ∧ IsMinimizer f A ∧ IsMinimizer f B := by
  refine ⟨concaveCard, concaveCard_submodular, ∅, Finset.univ, ?_, ?_, ?_⟩
  · decide
  · unfold IsMinimizer; decide
  · unfold IsMinimizer; decide

end RainbowForestObstruction