import Computation.BatchRootLawGeometry

/-!
# Unimodality of the batching cost, and the discrete (integer) optimum

Third research cycle on the root law.  A real batch size is a fiction: an
implementation must pick an integer `n ≥ 1`.  The root law
(`Catalog/Computation/BatchSubquadraticRootLaw.lean`) locates the real optimum
`k* = (A/((μ-1)q))^(1/μ)`, but by itself says nothing about which integer to use —
a priori the discrete optimum could sit far from `k*`.

Here we prove that it cannot, by establishing **strict unimodality** of the cost:

* `blockCostM_strictAntiOn_left` — strictly decreasing on `(0, k*]`;
* `blockCostM_strictMonoOn_right` — strictly increasing on `[k*, ∞)`.

The proof is a *balance-shift* argument rather than a derivative computation: for
`k₂ ≤ k*` the point `k₂` is the exact minimiser of the cost with the smaller setup
`A' = q(μ-1)k₂^μ ≤ A`, and the difference of the two cost functions, `(A-A')/k`, is
itself decreasing — so strictness transfers from the auxiliary problem to the real
one.  This reuses `balanced_cost_lt`/`balanced_cost_at` verbatim, with no analysis.

The payoff is the practitioner's statement:

* `blockCostM_nat_min` — **the best integer batch is `⌊k*⌋` or `⌈k*⌉`**: no integer
  `n ≥ 1` beats both neighbours of the real optimum.
-/

namespace BatchRootLaw

open Real

variable {A c q mu : ℝ}

/-- Below the optimum, a smaller batch is beaten by the auxiliary problem whose
optimum sits exactly at the larger batch. -/
lemma aux_setup_le (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) {k : ℝ} (hk : 0 < k)
    (hkle : k ≤ optBatch A q mu) : q * (mu - 1) * k ^ mu ≤ A := by
  have hbal := optBatch_balanced hA hq hmu
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hpow : k ^ mu ≤ (optBatch A q mu) ^ mu :=
    Real.rpow_le_rpow hk.le hkle (by linarith)
  rw [hbal]
  exact mul_le_mul_of_nonneg_left hpow (by positivity)

/-- Above the optimum, the auxiliary setup dominates the real one. -/
lemma le_aux_setup (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) {k : ℝ}
    (hkge : optBatch A q mu ≤ k) : A ≤ q * (mu - 1) * k ^ mu := by
  have hbal := optBatch_balanced hA hq hmu
  have hm1 : (0:ℝ) < mu - 1 := by linarith
  have hpow : (optBatch A q mu) ^ mu ≤ k ^ mu :=
    Real.rpow_le_rpow (optBatch_pos hA hq hmu).le hkge (by linarith)
  rw [hbal]
  exact mul_le_mul_of_nonneg_left hpow (by positivity)

/-- **Strictly decreasing below the optimum.** -/
theorem blockCostM_strictAntiOn_left (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu)
    {k₁ k₂ : ℝ} (hk₁ : 0 < k₁) (h12 : k₁ < k₂) (hk₂ : k₂ ≤ optBatch A q mu) :
    blockCostM A c q mu k₂ < blockCostM A c q mu k₁ := by
  have hk₂pos : 0 < k₂ := lt_trans hk₁ h12
  set A' : ℝ := q * (mu - 1) * k₂ ^ mu with hA'
  have hstrict : q * mu * k₂ ^ (mu - 1) < A' / k₁ + q * k₁ ^ (mu - 1) :=
    balanced_cost_lt hq hmu hk₂pos rfl hk₁ (by linarith)
  have hat : A' / k₂ + q * k₂ ^ (mu - 1) = q * mu * k₂ ^ (mu - 1) :=
    balanced_cost_at hk₂pos rfl
  have hle : A' ≤ A := aux_setup_le hA hq hmu hk₂pos hk₂
  have hdiff : (A - A') / k₂ ≤ (A - A') / k₁ :=
    div_le_div_of_nonneg_left (by linarith) hk₁ h12.le
  have hsplit₁ : A / k₁ = A' / k₁ + (A - A') / k₁ := by field_simp; ring
  have hsplit₂ : A / k₂ = A' / k₂ + (A - A') / k₂ := by field_simp; ring
  unfold blockCostM
  rw [hsplit₁, hsplit₂]
  linarith

/-- **Strictly increasing above the optimum.** -/
theorem blockCostM_strictMonoOn_right (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu)
    {k₁ k₂ : ℝ} (hk₁ : optBatch A q mu ≤ k₁) (h12 : k₁ < k₂) :
    blockCostM A c q mu k₁ < blockCostM A c q mu k₂ := by
  have hk₁pos : 0 < k₁ := lt_of_lt_of_le (optBatch_pos hA hq hmu) hk₁
  have hk₂pos : 0 < k₂ := lt_trans hk₁pos h12
  set A' : ℝ := q * (mu - 1) * k₁ ^ mu with hA'
  have hstrict : q * mu * k₁ ^ (mu - 1) < A' / k₂ + q * k₂ ^ (mu - 1) :=
    balanced_cost_lt hq hmu hk₁pos rfl hk₂pos (by linarith)
  have hat : A' / k₁ + q * k₁ ^ (mu - 1) = q * mu * k₁ ^ (mu - 1) :=
    balanced_cost_at hk₁pos rfl
  have hge : A ≤ A' := le_aux_setup hA hq hmu hk₁
  have hdiff : (A' - A) / k₂ ≤ (A' - A) / k₁ :=
    div_le_div_of_nonneg_left (by linarith) hk₁pos h12.le
  have hsplit₁ : A / k₁ = A' / k₁ - (A' - A) / k₁ := by field_simp; ring
  have hsplit₂ : A / k₂ = A' / k₂ - (A' - A) / k₂ := by field_simp; ring
  unfold blockCostM
  rw [hsplit₁, hsplit₂]
  linarith

/-- Packaged as a `StrictAntiOn` statement on `(0, k*]`. -/
theorem strictAntiOn_blockCostM (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    StrictAntiOn (blockCostM A c q mu) (Set.Ioc 0 (optBatch A q mu)) := by
  rintro k₁ ⟨h₁, -⟩ k₂ ⟨-, h₄⟩ h
  exact blockCostM_strictAntiOn_left hA hq hmu h₁ h h₄

/-- Packaged as a `StrictMonoOn` statement on `[k*, ∞)`. -/
theorem strictMonoOn_blockCostM (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    StrictMonoOn (blockCostM A c q mu) (Set.Ici (optBatch A q mu)) := by
  rintro k₁ h₁ k₂ - h
  exact blockCostM_strictMonoOn_right hA hq hmu h₁ h

/-! ## The discrete optimum -/

/-- **The best integer batch size is a neighbour of `k*`.**  For every integer
`n ≥ 1`, the cost at `n` is at least the smaller of the costs at
`max 1 ⌊k*⌋` and `⌈k*⌉`.  (The `max 1` only matters when `k* < 1`, where the
optimum is the smallest admissible batch.) -/
theorem blockCostM_nat_min (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) {n : ℕ} (hn : 0 < n) :
    min (blockCostM A c q mu ((max 1 ⌊optBatch A q mu⌋₊ : ℕ) : ℝ))
        (blockCostM A c q mu ((⌈optBatch A q mu⌉₊ : ℕ) : ℝ))
      ≤ blockCostM A c q mu (n : ℝ) := by
  have ht : 0 < optBatch A q mu := optBatch_pos hA hq hmu
  have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  by_cases hcase : (n : ℝ) ≤ optBatch A q mu
  · -- below the optimum: compare with the floor
    have hfl : n ≤ ⌊optBatch A q mu⌋₊ := Nat.le_floor (by exact_mod_cast hcase)
    have hmax : max 1 ⌊optBatch A q mu⌋₊ = ⌊optBatch A q mu⌋₊ :=
      max_eq_right (le_trans hn hfl)
    have hflle : ((⌊optBatch A q mu⌋₊ : ℕ) : ℝ) ≤ optBatch A q mu :=
      Nat.floor_le ht.le
    have hstep : blockCostM A c q mu ((⌊optBatch A q mu⌋₊ : ℕ) : ℝ)
        ≤ blockCostM A c q mu (n : ℝ) := by
      rcases eq_or_lt_of_le (show (n : ℝ) ≤ ((⌊optBatch A q mu⌋₊ : ℕ) : ℝ) by exact_mod_cast hfl)
        with heq | hlt
      · rw [heq]
      · exact le_of_lt (blockCostM_strictAntiOn_left hA hq hmu (by linarith) hlt hflle)
    rw [hmax]
    exact le_trans (min_le_left _ _) hstep
  · -- above the optimum: compare with the ceiling
    push_neg at hcase
    have hce : ⌈optBatch A q mu⌉₊ ≤ n := Nat.ceil_le.mpr (by exact_mod_cast hcase.le)
    have hcege : optBatch A q mu ≤ ((⌈optBatch A q mu⌉₊ : ℕ) : ℝ) := Nat.le_ceil _
    have hstep : blockCostM A c q mu ((⌈optBatch A q mu⌉₊ : ℕ) : ℝ)
        ≤ blockCostM A c q mu (n : ℝ) := by
      rcases eq_or_lt_of_le (show ((⌈optBatch A q mu⌉₊ : ℕ) : ℝ) ≤ (n : ℝ) by exact_mod_cast hce)
        with heq | hlt
      · rw [heq]
      · exact le_of_lt (blockCostM_strictMonoOn_right hA hq hmu hcege hlt)
    exact le_trans (min_le_right _ _) hstep

/-- **Unimodality in one statement**: the cost strictly decreases up to `k*` and
strictly increases after it, so `k*` is the unique local — hence global —
minimum, and any search procedure (binary/ternary search over batch sizes) is
guaranteed to converge to it. -/
theorem blockCostM_unimodal (hA : 0 < A) (hq : 0 < q) (hmu : 1 < mu) :
    StrictAntiOn (blockCostM A c q mu) (Set.Ioc 0 (optBatch A q mu))
      ∧ StrictMonoOn (blockCostM A c q mu) (Set.Ici (optBatch A q mu)) :=
  ⟨strictAntiOn_blockCostM hA hq hmu, strictMonoOn_blockCostM hA hq hmu⟩

end BatchRootLaw