/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Geometry of the max-plus Legendre--Fenchel rate function

This file continues the study of idempotent (max-plus) large deviations begun in
`Probability.IdempotentLargeDeviations`.  There, the *pathwise upper bound*
`pathScore p ≤ - rate (velocity p)` was established, but nothing was known about
the *domain* of the rate function, about its behaviour under products, or about
the sharpness of the bound.

The results proved here are:

* `MaxPlusLaw.bddAbove_legendreSet_iff_mem_convexHull` — the affine family whose
  supremum defines the real-valued rate is bounded above at `x` **iff** `x` lies
  in the convex hull of the finite set of increment values.  (Conjecture 3 of the
  research thread.)
* `MaxPlusLaw.rate_nonneg` — with the `sSup ∅ = 0` convention of `Real`, the rate
  is nonnegative at *every* real point, not only at realized velocities.
* `MaxPlusLaw.rate_le_neg_mixture` — the "easy half" of a max-plus Cramér
  theorem: every convex mixture of increments realizing `x` bounds the rate.
* `MaxPlusLaw.cumulant_prod` — the max-plus cumulant tensorizes *exactly*, and
  hence `MaxPlusLaw.rate_prod_le_add`, the infimal-convolution upper bound
  (half of Conjecture 2).
* `MaxPlusLaw.eventWeightE_le` and `maxPlus_limsup_le_neg_sInf_rate` — the full
  closed-set (indeed arbitrary-set) upper bound in an extended-real formulation,
  where empty events correctly receive weight `⊥ = -∞`.  (Conjecture 4.)
-/

import Probability.IdempotentLargeDeviations

open scoped BigOperators
open Finset

namespace IdempotentProbability

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## The Legendre set and the extreme increment values -/

/-- The family of affine values whose supremum defines the rate function. -/
def MaxPlusLaw.legendreSet (μ : MaxPlusLaw ι) (x : ℝ) : Set ℝ :=
  {r : ℝ | ∃ θ : ℝ, r = θ * x - μ.cumulant θ}

theorem MaxPlusLaw.rate_eq_sSup (μ : MaxPlusLaw ι) (x : ℝ) :
    μ.rate x = sSup (μ.legendreSet x) := rfl

theorem MaxPlusLaw.legendreSet_nonempty (μ : MaxPlusLaw ι) (x : ℝ) :
    (μ.legendreSet x).Nonempty :=
  ⟨0 * x - μ.cumulant 0, ⟨0, rfl⟩⟩

/-- The largest increment value. -/
noncomputable def MaxPlusLaw.vmax (μ : MaxPlusLaw ι) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty μ.value

/-- The smallest increment value. -/
noncomputable def MaxPlusLaw.vmin (μ : MaxPlusLaw ι) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty μ.value

theorem MaxPlusLaw.value_le_vmax (μ : MaxPlusLaw ι) (i : ι) : μ.value i ≤ μ.vmax :=
  Finset.le_sup' _ (Finset.mem_univ i)

theorem MaxPlusLaw.vmin_le_value (μ : MaxPlusLaw ι) (i : ι) : μ.vmin ≤ μ.value i :=
  Finset.inf'_le _ (Finset.mem_univ i)

theorem MaxPlusLaw.exists_value_eq_vmax (μ : MaxPlusLaw ι) : ∃ i, μ.value i = μ.vmax := by
  obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ι)) μ.value
  exact ⟨i, hi.symm⟩

theorem MaxPlusLaw.exists_value_eq_vmin (μ : MaxPlusLaw ι) : ∃ i, μ.value i = μ.vmin := by
  obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_inf' (Finset.univ_nonempty (α := ι)) μ.value
  exact ⟨i, hi.symm⟩

theorem MaxPlusLaw.vmin_le_vmax (μ : MaxPlusLaw ι) : μ.vmin ≤ μ.vmax := by
  obtain ⟨i, hi⟩ := μ.exists_value_eq_vmax
  exact hi ▸ μ.vmin_le_value i

/-- In dimension one the convex hull of the (finite, nonempty) set of increment
values is exactly the interval between the extreme values. -/
theorem MaxPlusLaw.convexHull_range_value (μ : MaxPlusLaw ι) :
    convexHull ℝ (Set.range μ.value) = Set.Icc μ.vmin μ.vmax := by
  apply le_antisymm
  · apply convexHull_min _ (convex_Icc _ _)
    rintro _ ⟨i, rfl⟩
    exact ⟨μ.vmin_le_value i, μ.value_le_vmax i⟩
  · obtain ⟨i, hi⟩ := μ.exists_value_eq_vmin
    obtain ⟨j, hj⟩ := μ.exists_value_eq_vmax
    have hmem : ∀ k : ι, μ.value k ∈ convexHull ℝ (Set.range μ.value) := fun k =>
      subset_convexHull ℝ _ ⟨k, rfl⟩
    have := (convex_convexHull ℝ (Set.range μ.value)).segment_subset (hmem i) (hmem j)
    rwa [hi, hj, segment_eq_Icc μ.vmin_le_vmax] at this

/-! ## Conjecture 3: the convex-hull characterization of the effective domain -/

/-- If `x` lies between the extreme increment values then the Legendre family is
bounded above: the bound is provided by the weight of an extremal increment. -/
theorem MaxPlusLaw.bddAbove_legendreSet_of_mem_Icc (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x ∈ Set.Icc μ.vmin μ.vmax) : BddAbove (μ.legendreSet x) := by
  obtain ⟨hmin, hmax⟩ := hx
  obtain ⟨i, hi⟩ := μ.exists_value_eq_vmax
  obtain ⟨j, hj⟩ := μ.exists_value_eq_vmin
  refine ⟨max (-μ.weight i) (-μ.weight j), ?_⟩
  rintro r ⟨θ, rfl⟩
  rcases le_total 0 θ with hθ | hθ
  · have h := μ.tilted_score_le_cumulant θ i
    rw [hi] at h
    have : θ * x - μ.cumulant θ ≤ -μ.weight i := by nlinarith
    exact this.trans (le_max_left _ _)
  · have h := μ.tilted_score_le_cumulant θ j
    rw [hj] at h
    have : θ * x - μ.cumulant θ ≤ -μ.weight j := by nlinarith
    exact this.trans (le_max_right _ _)

/-- For nonnegative tilts the cumulant is at most `θ * vmax`; this uses the
max-plus normalization `weight ≤ 0`. -/
theorem MaxPlusLaw.cumulant_le_of_nonneg (μ : MaxPlusLaw ι) {θ : ℝ} (hθ : 0 ≤ θ) :
    μ.cumulant θ ≤ θ * μ.vmax := by
  rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
  intro i _
  have h1 : θ * μ.value i ≤ θ * μ.vmax := by
    exact mul_le_mul_of_nonneg_left (μ.value_le_vmax i) hθ
  linarith [μ.weight_nonpos i]

/-- For nonpositive tilts the cumulant is at most `θ * vmin`. -/
theorem MaxPlusLaw.cumulant_le_of_nonpos (μ : MaxPlusLaw ι) {θ : ℝ} (hθ : θ ≤ 0) :
    μ.cumulant θ ≤ θ * μ.vmin := by
  rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
  intro i _
  have h1 : θ * μ.value i ≤ θ * μ.vmin :=
    mul_le_mul_of_nonpos_left (μ.vmin_le_value i) hθ
  linarith [μ.weight_nonpos i]

/-- Beyond the largest increment value the Legendre family is unbounded. -/
theorem MaxPlusLaw.not_bddAbove_legendreSet_of_gt (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : μ.vmax < x) : ¬ BddAbove (μ.legendreSet x) := by
  rintro ⟨M, hM⟩
  set θ : ℝ := (max M 0 + 1) / (x - μ.vmax) with hθdef
  have hpos : 0 < x - μ.vmax := by linarith
  have hθ : 0 ≤ θ := by positivity
  have hbound : θ * x - μ.cumulant θ ≤ M := hM ⟨θ, rfl⟩
  have hcum := μ.cumulant_le_of_nonneg hθ
  have hkey : θ * (x - μ.vmax) = max M 0 + 1 := by
    rw [hθdef, div_mul_cancel₀ _ (ne_of_gt hpos)]
  nlinarith [le_max_left M 0]

/-- Below the smallest increment value the Legendre family is unbounded. -/
theorem MaxPlusLaw.not_bddAbove_legendreSet_of_lt (μ : MaxPlusLaw ι) {x : ℝ}
    (hx : x < μ.vmin) : ¬ BddAbove (μ.legendreSet x) := by
  rintro ⟨M, hM⟩
  set θ : ℝ := -((max M 0 + 1) / (μ.vmin - x)) with hθdef
  have hpos : 0 < μ.vmin - x := by linarith
  have hθ : θ ≤ 0 := by
    rw [hθdef]
    simp only [neg_nonpos]
    positivity
  have hbound : θ * x - μ.cumulant θ ≤ M := hM ⟨θ, rfl⟩
  have hcum := μ.cumulant_le_of_nonpos hθ
  have hkey : θ * (x - μ.vmin) = max M 0 + 1 := by
    rw [hθdef]; field_simp; ring
  nlinarith [le_max_left M 0]

/-- **Conjecture 3 (proved).**  For a finite max-plus law, the affine set whose
supremum defines the real-valued Legendre--Fenchel rate is bounded above at `x`
if and only if `x` belongs to the convex hull of the finite set of increment
values.  Thus the effective domain of the rate function is exactly that hull. -/
theorem MaxPlusLaw.bddAbove_legendreSet_iff_mem_convexHull (μ : MaxPlusLaw ι) (x : ℝ) :
    BddAbove (μ.legendreSet x) ↔ x ∈ convexHull ℝ (Set.range μ.value) := by
  rw [μ.convexHull_range_value]
  constructor
  · intro h
    by_contra hx
    simp only [Set.mem_Icc, not_and_or, not_le] at hx
    rcases hx with hx | hx
    · exact μ.not_bddAbove_legendreSet_of_lt hx h
    · exact μ.not_bddAbove_legendreSet_of_gt hx h
  · exact μ.bddAbove_legendreSet_of_mem_Icc

/-! ## Global nonnegativity of the rate -/

/-- **The rate function is nonnegative everywhere.**  Inside the hull this is the
usual Legendre argument at `θ = 0`; outside the hull the defining family is
unbounded, so the `Real` convention `sSup = 0` applies.  Either way `rate ≥ 0`,
which is what makes infima of rates over arbitrary sets well behaved. -/
theorem MaxPlusLaw.rate_nonneg (μ : MaxPlusLaw ι) (x : ℝ) : 0 ≤ μ.rate x := by
  by_cases h : BddAbove (μ.legendreSet x)
  · exact ArithLDP.rateFunction_nonneg μ.cumulant μ.cumulant_zero h
  · rw [MaxPlusLaw.rate_eq_sSup, Real.sSup_of_not_bddAbove h]

theorem MaxPlusLaw.bddBelow_rate_image (μ : MaxPlusLaw ι) (C : Set ℝ) :
    BddBelow (μ.rate '' C) := by
  refine ⟨0, ?_⟩
  rintro _ ⟨x, -, rfl⟩
  exact μ.rate_nonneg x

/-! ## The easy half of a max-plus Cramér theorem -/

/-- **Mixture bound.**  If the velocity `x` is realized as a convex combination
`∑ λ i • value i` of the increments, then the rate at `x` is at most minus the
corresponding average weight.  (Equality — the full max-plus Cramér theorem — is
the content of `Novelty.MaxPlusCramer`.) -/
theorem MaxPlusLaw.rate_le_neg_mixture (μ : MaxPlusLaw ι) {x : ℝ} (lam : ι → ℝ)
    (hnn : ∀ i, 0 ≤ lam i) (hsum : ∑ i, lam i = 1)
    (hx : ∑ i, lam i * μ.value i = x) :
    μ.rate x ≤ -∑ i, lam i * μ.weight i := by
  rw [MaxPlusLaw.rate_eq_sSup]
  apply csSup_le (μ.legendreSet_nonempty x)
  rintro r ⟨θ, rfl⟩
  have hlow : ∑ i, lam i * μ.weight i + θ * x ≤ μ.cumulant θ := by
    have h1 : ∑ i, lam i * (μ.weight i + θ * μ.value i) ≤ ∑ i, lam i * μ.cumulant θ := by
      refine Finset.sum_le_sum fun i _ => ?_
      exact mul_le_mul_of_nonneg_left (μ.tilted_score_le_cumulant θ i) (hnn i)
    rw [← Finset.sum_mul, hsum, one_mul] at h1
    have h2 : ∑ i, lam i * (μ.weight i + θ * μ.value i)
        = (∑ i, lam i * μ.weight i) + θ * x := by
      rw [← hx, Finset.mul_sum, ← Finset.sum_add_distrib]
      refine Finset.sum_congr rfl fun i _ => by ring
    linarith [h2 ▸ h1]
  linarith

/-- Realized velocities always lie in the convex hull of the increment values,
witnessed by the empirical distribution of the path. -/
theorem MaxPlusLaw.empiricalVelocity_mem_Icc (μ : MaxPlusLaw ι) {n : ℕ} (hn : 0 < n)
    (p : Fin n → ι) : μ.empiricalVelocity p ∈ Set.Icc μ.vmin μ.vmax := by
  have hnreal : (0 : ℝ) < n := by exact_mod_cast hn
  constructor
  · rw [MaxPlusLaw.empiricalVelocity, le_div_iff₀ hnreal]
    calc μ.vmin * (n : ℝ) = ∑ _k : Fin n, μ.vmin := by
          simp [Finset.sum_const, mul_comm]
      _ ≤ ∑ k, μ.value (p k) := Finset.sum_le_sum fun k _ => μ.vmin_le_value (p k)
  · rw [MaxPlusLaw.empiricalVelocity, div_le_iff₀ hnreal]
    calc ∑ k, μ.value (p k) ≤ ∑ _k : Fin n, μ.vmax :=
          Finset.sum_le_sum fun k _ => μ.value_le_vmax (p k)
      _ = μ.vmax * (n : ℝ) := by simp [Finset.sum_const, mul_comm]

/-- The rate vanishes at any *typical* velocity, i.e. at the value of an increment
carrying the full max-plus mass `weight = 0`.  This is the idempotent law of large
numbers: typical velocities cost nothing. -/
theorem MaxPlusLaw.rate_eq_zero_of_weight_eq_zero (μ : MaxPlusLaw ι) {i : ι}
    (hw : μ.weight i = 0) : μ.rate (μ.value i) = 0 := by
  classical
  refine le_antisymm ?_ (μ.rate_nonneg _)
  have h := μ.rate_le_neg_mixture (x := μ.value i) (fun k => if k = i then 1 else 0)
    (fun k => by by_cases h : k = i <;> simp [h]) (by simp) (by simp)
  simpa [hw] using h

/-- **The rate function is convex on its effective domain.**  Being a supremum of affine
functions, the Legendre--Fenchel rate is convex wherever it is genuinely real-valued;
`bddAbove_legendreSet_iff_mem_convexHull` identifies that region with `[vmin, vmax]`. -/
theorem MaxPlusLaw.rate_convexOn (μ : MaxPlusLaw ι) :
    ConvexOn ℝ (Set.Icc μ.vmin μ.vmax) μ.rate := by
  refine ⟨convex_Icc _ _, ?_⟩
  intro x hx y hy a b ha hb hab
  simp only [smul_eq_mul]
  have hbx : BddAbove (μ.legendreSet x) := μ.bddAbove_legendreSet_of_mem_Icc hx
  have hby : BddAbove (μ.legendreSet y) := μ.bddAbove_legendreSet_of_mem_Icc hy
  rw [MaxPlusLaw.rate_eq_sSup]
  refine csSup_le (μ.legendreSet_nonempty _) ?_
  rintro r ⟨θ, rfl⟩
  have e1 : θ * x - μ.cumulant θ ≤ μ.rate x := le_csSup hbx ⟨θ, rfl⟩
  have e2 : θ * y - μ.cumulant θ ≤ μ.rate y := le_csSup hby ⟨θ, rfl⟩
  have : θ * (a * x + b * y) - μ.cumulant θ
      = a * (θ * x - μ.cumulant θ) + b * (θ * y - μ.cumulant θ) := by
    linear_combination (μ.cumulant θ) * hab
  rw [this]
  have h1 : a * (θ * x - μ.cumulant θ) ≤ a * μ.rate x :=
    mul_le_mul_of_nonneg_left e1 ha
  have h2 : b * (θ * y - μ.cumulant θ) ≤ b * μ.rate y :=
    mul_le_mul_of_nonneg_left e2 hb
  simpa using add_le_add h1 h2

/-! ## Conjecture 2 (half): exact tensorization of the cumulant -/

variable {κ : Type*} [Fintype κ] [Nonempty κ]

/-- The product of two max-plus laws: values and weights add. -/
def MaxPlusLaw.prod (μ₁ : MaxPlusLaw ι) (μ₂ : MaxPlusLaw κ) : MaxPlusLaw (ι × κ) where
  value := fun p => μ₁.value p.1 + μ₂.value p.2
  weight := fun p => μ₁.weight p.1 + μ₂.weight p.2
  weight_nonpos := fun p => add_nonpos (μ₁.weight_nonpos p.1) (μ₂.weight_nonpos p.2)
  exists_weight_zero := by
    obtain ⟨i, hi⟩ := μ₁.exists_weight_zero
    obtain ⟨j, hj⟩ := μ₂.exists_weight_zero
    exact ⟨(i, j), by simp [hi, hj]⟩

/-- **The max-plus cumulant is exactly additive under products.**  This is the
idempotent analogue of the multiplicativity of moment generating functions for
independent random variables. -/
theorem MaxPlusLaw.cumulant_prod (μ₁ : MaxPlusLaw ι) (μ₂ : MaxPlusLaw κ) (θ : ℝ) :
    (μ₁.prod μ₂).cumulant θ = μ₁.cumulant θ + μ₂.cumulant θ := by
  apply le_antisymm
  · rw [MaxPlusLaw.cumulant, Finset.sup'_le_iff]
    rintro ⟨i, j⟩ -
    have h1 := μ₁.tilted_score_le_cumulant θ i
    have h2 := μ₂.tilted_score_le_cumulant θ j
    show μ₁.weight i + μ₂.weight j + θ * (μ₁.value i + μ₂.value j) ≤ _
    nlinarith
  · obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ι))
      (fun i => μ₁.weight i + θ * μ₁.value i)
    obtain ⟨j, -, hj⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := κ))
      (fun j => μ₂.weight j + θ * μ₂.value j)
    have h := (μ₁.prod μ₂).tilted_score_le_cumulant θ (i, j)
    show μ₁.cumulant θ + μ₂.cumulant θ ≤ _
    rw [MaxPlusLaw.cumulant, MaxPlusLaw.cumulant, hi, hj]
    show _ ≤ (μ₁.prod μ₂).cumulant θ
    have : (μ₁.prod μ₂).weight (i, j) + θ * (μ₁.prod μ₂).value (i, j)
        = (μ₁.weight i + θ * μ₁.value i) + (μ₂.weight j + θ * μ₂.value j) := by
      show μ₁.weight i + μ₂.weight j + θ * (μ₁.value i + μ₂.value j) = _
      ring
    linarith [this ▸ h]

/-- **Infimal-convolution upper bound (half of Conjecture 2).**  The rate of a
product law is at most the sum of the factor rates along any splitting of the
velocity.  Consequently `rateProd x ≤ inf_y (rate₁ y + rate₂ (x - y))`. -/
theorem MaxPlusLaw.rate_prod_le_add (μ₁ : MaxPlusLaw ι) (μ₂ : MaxPlusLaw κ) (x y : ℝ)
    (h1 : BddAbove (μ₁.legendreSet y)) (h2 : BddAbove (μ₂.legendreSet (x - y))) :
    (μ₁.prod μ₂).rate x ≤ μ₁.rate y + μ₂.rate (x - y) := by
  rw [MaxPlusLaw.rate_eq_sSup]
  apply csSup_le ((μ₁.prod μ₂).legendreSet_nonempty x)
  rintro r ⟨θ, rfl⟩
  have e1 : θ * y - μ₁.cumulant θ ≤ μ₁.rate y := le_csSup h1 ⟨θ, rfl⟩
  have e2 : θ * (x - y) - μ₂.cumulant θ ≤ μ₂.rate (x - y) := le_csSup h2 ⟨θ, rfl⟩
  rw [MaxPlusLaw.cumulant_prod]
  nlinarith

/-! ## Conjecture 4: the full (extended-real) upper bound over arbitrary sets -/

/-- Extended-real max-plus weight of the event "the empirical velocity lies in
`C`" among paths of length `n`.  The empty event correctly receives `⊥ = -∞`. -/
noncomputable def MaxPlusLaw.eventWeightE (μ : MaxPlusLaw ι) (n : ℕ) (C : Set ℝ) : EReal :=
  sSup ((fun p : Fin n → ι => ((μ.pathScore p : ℝ) : EReal)) ''
    {p : Fin n → ι | μ.empiricalVelocity p ∈ C})

/-- Finite-`n` form of the upper bound: for every `n ≥ 1` and every set `C` of
velocities, the max-plus weight of the event is at most minus the infimum of the
rate over `C`.  No closedness or compactness is needed for the upper bound. -/
theorem MaxPlusLaw.eventWeightE_le (μ : MaxPlusLaw ι) {n : ℕ} (hn : 0 < n) (C : Set ℝ) :
    μ.eventWeightE n C ≤ ((-sInf (μ.rate '' C) : ℝ) : EReal) := by
  rw [MaxPlusLaw.eventWeightE]
  apply sSup_le
  rintro _ ⟨p, hp, rfl⟩
  have hmem : μ.empiricalVelocity p ∈ C := hp
  have hpath := maxPlus_randomWalk_LDP μ hn p
  have hinf : sInf (μ.rate '' C) ≤ μ.rate (μ.empiricalVelocity p) :=
    csInf_le (μ.bddBelow_rate_image C) ⟨_, hmem, rfl⟩
  have : μ.pathScore p ≤ -sInf (μ.rate '' C) := by
    rw [MaxPlusLaw.pathScore]
    rw [show (∑ k, μ.value (p k)) / (n : ℝ) = μ.empiricalVelocity p from rfl] at hpath
    linarith
  show ((μ.pathScore p : ℝ) : EReal) ≤ ((-sInf (μ.rate '' C) : ℝ) : EReal)
  exact EReal.coe_le_coe_iff.mpr this

/-- **Conjecture 4 (proved, in fact for arbitrary sets).**  The limit superior of
the normalized max-plus weights of the velocity event `C` is at most minus the
infimum of the rate function over `C`. -/
theorem maxPlus_limsup_le_neg_sInf_rate (μ : MaxPlusLaw ι) (C : Set ℝ) :
    Filter.limsup (fun n => μ.eventWeightE n C) Filter.atTop ≤
      ((-sInf (μ.rate '' C) : ℝ) : EReal) := by
  apply Filter.limsup_le_of_le
  · exact Filter.isCobounded_le_of_bot
  · filter_upwards [Filter.eventually_gt_atTop 0] with n hn
    exact μ.eventWeightE_le hn C

end IdempotentProbability