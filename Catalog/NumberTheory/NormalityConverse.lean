import Mathlib

/-!
# Aligned-cylinder frequencies and interval equidistribution

This file formalizes the approximation step in the converse normality criterion.
An arbitrary interval is squeezed between aligned base-`b` intervals whose lengths
approach its length.  Convergence of the two aligned-interval frequencies then
forces convergence of the arbitrary interval frequency.
-/

namespace NormalityConverse

open Filter Set
open scoped Topology

/-- The empirical frequency of a predicate among the first `N` indices. -/
noncomputable def empiricalFrequency (P : ℕ → Prop) [DecidablePred P] (N : ℕ) : ℝ :=
  ((Finset.filter P (Finset.range N)).card : ℝ) / N

/-- Interval equidistribution in the unit interval. -/
def IntervalEquidistributed (u : ℕ → ℝ) : Prop :=
  ∀ a c : ℝ, 0 ≤ a → a < c → c ≤ 1 →
    Tendsto (empiricalFrequency (fun n => u n ∈ Ico a c)) atTop (𝓝 (c - a))

/-- An arbitrary interval admits arbitrarily accurate inner and outer aligned
base-`b` approximations, and the empirical frequencies of those aligned intervals
have the expected limits. -/
def HasBAdicSandwichFrequencies (b : ℕ) (u : ℕ → ℝ) : Prop :=
  ∀ a c : ℝ, 0 ≤ a → a < c → c ≤ 1 → ∀ ε : ℝ, 0 < ε →
    ∃ k Ai Ci Ao Co : ℕ,
      Ai < Ci ∧ Ci ≤ b ^ k ∧ Ao < Co ∧ Co ≤ b ^ k ∧
      Ico ((Ai : ℝ) / (b : ℝ) ^ k) ((Ci : ℝ) / (b : ℝ) ^ k) ⊆ Ico a c ∧
      Ico a c ⊆ Ico ((Ao : ℝ) / (b : ℝ) ^ k) ((Co : ℝ) / (b : ℝ) ^ k) ∧
      c - a - ε < ((Ci : ℝ) - Ai) / (b : ℝ) ^ k ∧
      ((Co : ℝ) - Ao) / (b : ℝ) ^ k < c - a + ε ∧
      Tendsto
        (empiricalFrequency (fun n => u n ∈
          Ico ((Ai : ℝ) / (b : ℝ) ^ k) ((Ci : ℝ) / (b : ℝ) ^ k)))
        atTop (𝓝 (((Ci : ℝ) - Ai) / (b : ℝ) ^ k)) ∧
      Tendsto
        (empiricalFrequency (fun n => u n ∈
          Ico ((Ao : ℝ) / (b : ℝ) ^ k) ((Co : ℝ) / (b : ℝ) ^ k)))
        atTop (𝓝 (((Co : ℝ) - Ao) / (b : ℝ) ^ k))

/-- Uniform limiting frequencies for every interval whose endpoints lie on one
base-`b` grid.  This is the aligned-cylinder hypothesis used by the converse. -/
def HasBAdicIntervalFrequencies (b : ℕ) (u : ℕ → ℝ) : Prop :=
  2 ≤ b ∧ ∀ k A C : ℕ, A < C → C ≤ b ^ k →
    Tendsto
      (empiricalFrequency (fun n => u n ∈
        Ico ((A : ℝ) / (b : ℝ) ^ k) ((C : ℝ) / (b : ℝ) ^ k)))
      atTop (𝓝 (((C : ℝ) - A) / (b : ℝ) ^ k))

/-- Uniform limiting frequencies for the individual aligned base-`b` cylinder
cells.  This is the usual digit-word hypothesis: at depth `k`, each of the
`b^k` cells has limiting frequency `b⁻ᵏ`. -/
def HasBAdicCylinderFrequencies (b : ℕ) (u : ℕ → ℝ) : Prop :=
  2 ≤ b ∧ ∀ k A : ℕ, A < b ^ k →
    Tendsto
      (empiricalFrequency (fun n => u n ∈
        Ico ((A : ℝ) / (b : ℝ) ^ k) (((A : ℝ) + 1) / (b : ℝ) ^ k)))
      atTop (𝓝 (1 / (b : ℝ) ^ k))

/-- Every nonempty subinterval of `[0,1]` has arbitrarily tight inner and outer
approximations with endpoints on a common base-`b` grid. -/
lemma exists_bAdic_interval_sandwich
    {b : ℕ} (hb : 2 ≤ b) {a c ε : ℝ}
    (ha : 0 ≤ a) (hac : a < c) (hc : c ≤ 1) (hε : 0 < ε) :
    ∃ k Ai Ci Ao Co : ℕ,
      Ai < Ci ∧ Ci ≤ b ^ k ∧ Ao < Co ∧ Co ≤ b ^ k ∧
      Ico ((Ai : ℝ) / (b : ℝ) ^ k) ((Ci : ℝ) / (b : ℝ) ^ k) ⊆ Ico a c ∧
      Ico a c ⊆ Ico ((Ao : ℝ) / (b : ℝ) ^ k) ((Co : ℝ) / (b : ℝ) ^ k) ∧
      c - a - ε < ((Ci : ℝ) - Ai) / (b : ℝ) ^ k ∧
      ((Co : ℝ) - Ao) / (b : ℝ) ^ k < c - a + ε := by
  -- Choose k such that b^k > max(2/(c-a), 2/ε)
  -- We use 2/(c-a) to ensure gap > 2, so ⌊a*bk⌋ + 1 < ⌊c*bk⌋
  have hbpos : (1 : ℝ) < b := by norm_cast
  have hca : 0 < c - a := by linarith
  have hε' : 0 < ε := hε
  -- Use Archimedean property to find suitable k
  have hmax_pos : 0 < max (2 / (c - a)) (2 / ε) := by positivity
  have : ∃ k : ℕ, (max (2 / (c - a)) (2 / ε)) < (b : ℝ) ^ k := by
    have hb1 : (1 : ℝ) ≤ b := by norm_cast; linarith
    exact pow_unbounded_of_one_lt _ hbpos
  obtain ⟨k, hk⟩ := this
  -- Define the grid points
  let bk : ℝ := (b : ℝ) ^ k
  have hbkle : 0 < bk := pow_pos (by positivity) k
  have hbkle' : (1 : ℕ) ≤ b ^ k := by
    calc 1 = b ^ 0 := by norm_num
      _ ≤ b ^ k := Nat.pow_le_pow_right (by linarith) (Nat.zero_le _)
  -- Outer bounds
  let Ao := ⌊a * bk⌋₊
  let Co' := ⌈c * bk⌉
  let Co := if Co' ≤ 0 then 0 else Co'.toNat
  -- Inner bounds: use floor + 1 to ensure strict inequality Ai > a * bk
  let Ai := ⌊a * bk⌋₊ + 1
  let Ai' : ℤ := (⌊a * bk⌋₊ : ℕ) + 1
  let Ci := ⌊c * bk⌋₊
  -- Key: bk * (c - a) > 2
  have h1 : 2 / (c - a) < bk := lt_of_le_of_lt (le_max_left _ _) hk
  have hbkcma : bk * (c - a) > 2 := by
    rwa [div_lt_iff₀ hca] at h1
  -- Properties of floor and ceiling
  have ha_bk : (Ao : ℝ) ≤ a * bk ∧ a * bk < (Ao + 1 : ℝ) :=
    ⟨ Nat.floor_le (by positivity), Nat.lt_floor_add_one _ ⟩
  have hc_bk : (Ci : ℝ) ≤ c * bk ∧ c * bk < (Ci + 1 : ℝ) :=
    ⟨ Nat.floor_le (by nlinarith), Nat.lt_floor_add_one _ ⟩
  have ha_ai : (Ai : ℝ) > a * bk := by
    simp only [Ai, Nat.cast_add, Nat.cast_one]
    linarith [ha_bk.2]
  -- Co > 0 since c > 0 and bk > 0
  have hCo'_pos : Co' > 0 := by
    have h1 : c * bk > 0 := by nlinarith
    exact Int.ceil_pos.mpr h1
  -- Co = Co'.toNat since Co' > 0
  have hCo_eq : Co = Co'.toNat := by
    simp [Co, hCo'_pos]
  -- Key: Ai' = ⌊a * bk⌋ + 1 > a * bk
  have ha_ai : (Ai : ℝ) > a * bk := by
    simp only [Ai, Nat.cast_add, Nat.cast_one]
    linarith [ha_bk.2]
  -- Prove Ai < Ci
  -- Ai = ⌊a * bk⌋ + 1, and we have a * bk < ⌊a * bk⌋ + 1 = Ai
  -- Also c * bk > a * bk + 2 (from hbkcma)
  -- So c * bk > a * bk + 2 > ⌊a * bk⌋ + 1 + 1 = Ai + 1
  -- Hence Ai < Ai + 1 ≤ ⌊c * bk⌋ = Ci
  have hAi_lt_Ci : Ai < Ci := by
    -- Ai = ⌊a * bk⌋ + 1, so (Ai : ℝ) = ⌊a * bk⌋ + 1
    -- We have ⌊a * bk⌋ ≤ a * bk, so (Ai : ℝ) ≤ a * bk + 1 < a * bk + 2 < c * bk
    simp only [Ai] at ha_ai ⊢
    have h1 : ((⌊a * bk⌋₊ : ℕ) + 1 : ℝ) ≤ a * bk + 1 := by
      have := Nat.floor_le (by positivity : 0 ≤ a * bk)
      linarith
    have h2 : a * bk + 1 < a * bk + 2 := by linarith
    have h3 : a * bk + 2 < c * bk := by linarith [hbkcma]
    have h4 : ((⌊a * bk⌋₊ : ℕ) + 1 : ℝ) < c * bk := by linarith
    have h5 : ((⌊a * bk⌋₊ : ℕ) + 1 : ℕ) + 1 ≤ Ci := by
      have h4' : ((⌊a * bk⌋₊ + 1 + 1 : ℕ) : ℝ) ≤ c * bk := by push_cast; linarith
      exact Nat.le_floor h4'
    omega
  -- Now provide the witness
  use k, Ai, Ci, Ao, Co
  refine ⟨hAi_lt_Ci, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  -- Ci ≤ b^k: since c ≤ 1, c * bk ≤ bk = b^k, so ⌊c * bk⌋ ≤ b^k
  · have h1 : (Ci : ℝ) ≤ c * bk := hc_bk.1
    have h2 : (Ci : ℝ) ≤ bk := by nlinarith
    have hbk_eq : bk = (b ^ k : ℝ) := rfl
    rw [hbk_eq] at h2
    exact_mod_cast h2
  -- Ao < Co: since a < c, ⌊a * bk⌋ < ⌈c * bk⌉
  · rw [hCo_eq]
    have hCo'_gt : (Co' : ℝ) > a * bk := by
      have h1 : (Co' : ℝ) ≥ c * bk := by
        have := Int.le_ceil (c * bk)
        exact this
      linarith
    have hAo_lt : (Ao : ℝ) < a * bk + 1 := by linarith [ha_bk.2]
    have hAo_lt_Co' : (Ao : ℝ) < Co' := by linarith
    have h1 : (Ao : ℤ) < Co' := by exact_mod_cast hAo_lt_Co'
    have h2 : Ao < Co'.toNat := by
      rw [Int.lt_toNat]
      exact h1
    exact h2
  -- Co ≤ b^k: since c ≤ 1, c * bk ≤ bk, so ⌈c * bk⌉ ≤ b^k
  · rw [hCo_eq]
    have hbkle_real : ((b ^ k : ℕ) : ℝ) = (b : ℝ) ^ k := by norm_cast
    have h1 : c * bk ≤ ((b ^ k : ℕ) : ℝ) := by
      simp only [bk, hbkle_real]
      apply mul_le_of_le_one_left
      · positivity
      · exact hc
    have h2 : Co' ≤ (b ^ k : ℕ) := Int.ceil_le.mpr h1
    exact Int.toNat_le.mpr h2
  -- Inner subset: Ico (Ai/bk) (Ci/bk) ⊆ Ico a c
  · apply Ico_subset_Ico
    · -- Show a ≤ Ai / bk: since Ai > a * bk, we have Ai / bk > a
      rw [le_div_iff₀ (by positivity : (0 : ℝ) < (b : ℝ) ^ k)]
      have : (Ai : ℝ) > a * (b : ℝ) ^ k := ha_ai
      linarith
    · -- Show Ci / bk ≤ c: since Ci ≤ c * bk, we have Ci / bk ≤ c
      rw [div_le_iff₀ (by positivity : (0 : ℝ) < (b : ℝ) ^ k)]
      have : (Ci : ℝ) ≤ c * (b : ℝ) ^ k := hc_bk.1
      linarith
  -- Outer subset: Ico a c ⊆ Ico (Ao/bk) (Co/bk)
  · apply Ico_subset_Ico
    · -- Show Ao / bk ≤ a: since Ao ≤ a * bk, we have Ao / bk ≤ a
      rw [div_le_iff₀ (by positivity : (0 : ℝ) < (b : ℝ) ^ k)]
      have : (Ao : ℝ) ≤ a * (b : ℝ) ^ k := ha_bk.1
      linarith
    · -- Show c ≤ Co / bk: since Co ≥ c * bk, we have Co / bk ≥ c
      rw [le_div_iff₀ (by positivity : (0 : ℝ) < (b : ℝ) ^ k)]
      have hCo_ge : ((Co : ℝ)) ≥ c * (b : ℝ) ^ k := by
        rw [hCo_eq]
        have hCo'_ge : (Co' : ℝ) ≥ c * (b : ℝ) ^ k := Int.le_ceil _
        have hCo'_nat : ((Co'.toNat : ℕ) : ℝ) = Co' := by
          exact_mod_cast Int.toNat_of_nonneg (le_of_lt hCo'_pos)
        rw [hCo'_nat]
        exact hCo'_ge
      linarith
  -- Inner length bound: c - a - ε < (Ci - Ai) / bk
  · -- Ci > c * bk - 1, Ai ≤ a * bk + 1, so Ci - Ai > c*bk - 1 - a*bk - 1 = bk*(c-a) - 2
    -- So (Ci - Ai)/bk > (c-a) - 2/bk > (c-a) - ε since bk > 1/ε
    rw [lt_div_iff₀ (by positivity : (0 : ℝ) < (b : ℝ) ^ k)]
    -- Ai ≤ a * bk + 1
    have hAi_le : (Ai : ℝ) ≤ a * (b : ℝ) ^ k + 1 := by
      have h1 : (⌊a * bk⌋₊ : ℝ) + 1 ≤ a * (b : ℝ) ^ k + 1 := by
        simp only [bk] at ha_bk ⊢
        linarith [ha_bk.1]
      simp only [Ai]
      convert h1 using 1
      norm_cast
    -- Ci > c * bk - 1
    have hCi_gt : (Ci : ℝ) > c * (b : ℝ) ^ k - 1 := by
      have := hc_bk.2
      linarith
    -- Ci - Ai > (c - a) * bk - 2
    have h1 : (Ci : ℝ) - Ai > (c : ℝ) * (b : ℝ) ^ k - 1 - (a * (b : ℝ) ^ k + 1) := by linarith
    have h2 : (Ci : ℝ) - Ai > (b : ℝ) ^ k * (c - a) - 2 := by linarith
    -- Also bk > 2/ε, so 2/bk < ε, so 2 < bk * ε
    have hbk_eps : (b : ℝ) ^ k > 2 / ε := lt_of_le_of_lt (le_max_right _ _) hk
    have hbkle_pos : (0 : ℝ) < ε := hε'
    have h3 : 2 < (b : ℝ) ^ k * ε := by
      rw [gt_iff_lt, div_lt_iff₀ hbkle_pos] at hbk_eps
      linarith
    linarith
  -- Outer length bound: (Co - Ao) / bk < c - a + ε
  · rw [div_lt_iff₀ (by positivity : (0 : ℝ) < (b : ℝ) ^ k)]
    have hbk_eps : (b : ℝ) ^ k > 2 / ε := lt_of_le_of_lt (le_max_right _ _) hk
    have hbkle_pos : (0 : ℝ) < ε := hε'
    have h1 : 2 < (b : ℝ) ^ k * ε := by rw [gt_iff_lt, div_lt_iff₀ hbkle_pos] at hbk_eps; linarith
    have hCeil_le : (Co' : ℝ) ≤ c * (b : ℝ) ^ k + 1 := by linarith [Int.ceil_lt_add_one (c * bk)]
    have hCo_le : (Co : ℝ) ≤ c * (b : ℝ) ^ k + 1 := by
      simp only [hCo_eq]
      convert hCeil_le using 1
      exact_mod_cast Int.toNat_of_nonneg (le_of_lt hCo'_pos)
    have hAo_gt : (Ao : ℝ) > a * (b : ℝ) ^ k - 1 := by simp only [bk] at ha_bk ⊢; linarith [ha_bk.2]
    linarith

/-- An aligned grid interval is the disjoint union of its individual cylinder
cells, so its empirical frequency is the sum of their empirical frequencies. -/
lemma empiricalFrequency_bAdic_interval_eq_sum
    {u : ℕ → ℝ} {b k A C N : ℕ} (hb : 1 ≤ b) :
    empiricalFrequency (fun n => u n ∈
      Ico ((A : ℝ) / (b : ℝ) ^ k) ((C : ℝ) / (b : ℝ) ^ k)) N =
      ∑ j ∈ Finset.Ico A C,
        empiricalFrequency (fun n => u n ∈
          Ico ((j : ℝ) / (b : ℝ) ^ k) (((j : ℝ) + 1) / (b : ℝ) ^ k)) N := by
  unfold empiricalFrequency
  rw [← Finset.sum_div]
  congr 1
  -- Need to show: card of filter = sum of card of each filter
  -- First, establish the biUnion equality
  have hfilter_eq : Finset.filter (fun m => u m ∈ Ico ((A : ℝ) / (b : ℝ) ^ k) ((C : ℝ) / (b : ℝ) ^ k)) (Finset.range N) =
      Finset.biUnion (Finset.Ico A C) (fun j => Finset.filter (fun m => u m ∈ Ico ((j : ℝ) / (b : ℝ) ^ k) (((j : ℝ) + 1) / (b : ℝ) ^ k)) (Finset.range N)) := by
    ext n
    simp only [Finset.mem_filter, Finset.mem_biUnion, Finset.mem_range, Finset.mem_Ico]
    constructor
    · intro ⟨hn, hAu, hCu⟩
      -- Let a = floor(u n * b^k), which satisfies A ≤ a < C
      set bk := (b : ℝ) ^ k with hbk_def
      have hbk_pos : 0 < bk := pow_pos (by positivity) k
      set a := ⌊u n * bk⌋₊ with ha_def
      have hAu' : (A : ℝ) ≤ u n * bk := by
        rw [div_le_iff₀ hbk_pos] at hAu
        linarith
      have ha_ge_A : A ≤ a := Nat.le_floor hAu'
      have hCu' : u n * bk < (C : ℝ) := by
        rw [lt_div_iff₀ hbk_pos] at hCu
        linarith
      have ha_lt_C : a < C := Nat.floor_lt (by linarith : 0 ≤ u n * bk) |>.mpr hCu'
      use a
      refine ⟨⟨ha_ge_A, ha_lt_C⟩, hn, ?_⟩
      simp only [ha_def]
      constructor
      · exact div_le_iff₀ hbk_pos |>.mpr (Nat.floor_le (by linarith : 0 ≤ u n * bk))
      · rw [lt_div_iff₀ hbk_pos]
        exact Nat.lt_floor_add_one (u n * bk)
    · intro ⟨j, ⟨hAj, hJC⟩, hn, hij⟩
      refine ⟨hn, ⟨?_, ?_⟩⟩
      · have h1 : (A : ℝ) ≤ j := Nat.cast_le.mpr hAj
        exact le_trans (div_le_div_of_nonneg_right h1 (by positivity)) hij.1
      · have h2 : (j + 1 : ℕ) ≤ C := Nat.succ_le_of_lt hJC
        have h3 : ((j : ℝ) + 1) = ((j + 1 : ℕ) : ℝ) := by simp
        rw [h3] at hij
        exact lt_of_lt_of_le hij.2 (div_le_div_of_nonneg_right (Nat.cast_le.mpr h2) (by positivity))
  -- Now prove disjointness
  have hdisj : PairwiseDisjoint (↑(Finset.Ico A C) : Set ℕ) (fun j => Finset.filter (fun m => u m ∈ Ico ((j : ℝ) / (b : ℝ) ^ k) (((j : ℝ) + 1) / (b : ℝ) ^ k)) (Finset.range N)) := by
    intro i hi j hj hij
    simp only [Function.onFun]
    rw [Finset.disjoint_left]
    intro m hm hmi
    simp only [Finset.mem_filter, Finset.mem_range] at hm hmi
    obtain ⟨hm_range, hmi_Ico⟩ := hmi
    obtain ⟨hmj_range, hmj_Ico⟩ := hm
    -- If i ≠ j, the intervals don't overlap
    rcases lt_trichotomy i j with hlt | heq | hgt
    · -- Case i < j: (i+1)/bk ≤ j/bk
      have hbound : ((i : ℝ) + 1) / (b : ℝ) ^ k ≤ (j : ℝ) / (b : ℝ) ^ k := by
        gcongr
        norm_cast
      linarith [hmj_Ico.2, hmi_Ico.1]
    · exact hij heq
    · -- Case i > j: (j+1)/bk ≤ i/bk
      have hbound : ((j : ℝ) + 1) / (b : ℝ) ^ k ≤ (i : ℝ) / (b : ℝ) ^ k := by
        gcongr
        norm_cast
      linarith [hmi_Ico.2, hmj_Ico.1]
  rw [hfilter_eq, Finset.card_biUnion hdisj]
  simp

/-- Uniform frequencies of individual aligned cylinder cells imply the expected
frequency for every interval with endpoints on the same base-`b` grid. -/
theorem hasBAdicIntervalFrequencies_of_cylinder_frequencies
    {b : ℕ} {u : ℕ → ℝ} (h : HasBAdicCylinderFrequencies b u) :
    HasBAdicIntervalFrequencies b u := by
  refine ⟨h.1, fun k A C hAC hC => ?_⟩
  have hb : 2 ≤ b := h.1
  have hb0 : b ≠ 0 := by omega
  have hfun :
      empiricalFrequency (fun n => u n ∈
        Ico ((A : ℝ) / (b : ℝ) ^ k) ((C : ℝ) / (b : ℝ) ^ k)) =
        fun N => ∑ j ∈ Finset.Ico A C,
          empiricalFrequency (fun n => u n ∈
            Ico ((j : ℝ) / (b : ℝ) ^ k) (((j : ℝ) + 1) / (b : ℝ) ^ k)) N :=
    funext fun N => empiricalFrequency_bAdic_interval_eq_sum
      (Nat.one_le_iff_ne_zero.mpr hb0)
  rw [hfun]
  convert tendsto_finset_sum (Finset.Ico A C)
    (fun j hj => h.2 k j (lt_of_lt_of_le (Finset.mem_Ico.mp hj).2 hC)) using 1
  simp [Nat.cast_sub (Nat.le_of_lt hAC)]
  ring

/-- Frequencies of all aligned intervals supply the tight frequency sandwiches
needed by the analytic squeezing argument. -/
theorem hasBAdicSandwichFrequencies_of_interval_frequencies
    {b : ℕ} {u : ℕ → ℝ} (h : HasBAdicIntervalFrequencies b u) :
    HasBAdicSandwichFrequencies b u := by
  intro a c ha hac hc ε hε
  obtain ⟨k, Ai, Ci, Ao, Co, hAiCi, hCi, hAoCo, hCo, hsubIn, hsubOut,
    hlenIn, hlenOut⟩ := exists_bAdic_interval_sandwich h.1 ha hac hc hε
  exact ⟨k, Ai, Ci, Ao, Co, hAiCi, hCi, hAoCo, hCo, hsubIn, hsubOut,
    hlenIn, hlenOut, h.2 k Ai Ci hAiCi hCi, h.2 k Ao Co hAoCo hCo⟩

/-- Empirical frequency is monotone under inclusion of predicates. -/
lemma empiricalFrequency_mono {P Q : ℕ → Prop} [DecidablePred P] [DecidablePred Q]
    (hPQ : ∀ n, P n → Q n) (N : ℕ) :
    empiricalFrequency P N ≤ empiricalFrequency Q N := by
  unfold empiricalFrequency
  gcongr
  exact hPQ _

/-- **Aligned-cylinder converse criterion.**  If every interval can be squeezed
arbitrarily tightly between aligned base-`b` intervals having their expected
asymptotic frequencies, then the sequence is interval-equidistributed. -/
theorem intervalEquidistributed_of_bAdic_sandwich
    {b : ℕ} (u : ℕ → ℝ) (h : HasBAdicSandwichFrequencies b u) :
    IntervalEquidistributed u := by
  intro a c ha hc hc1
  rw [Metric.tendsto_atTop]
  intro ε hε
  -- Use the sandwich hypothesis with ε / 2
  obtain ⟨k, Ai, Ci, Ao, Co, hAiCi, hCi_bk, hAoCo, hCo_bk,
           hinner, houter, hinner_len, houter_len, htend_inner, htend_outer⟩ :=
    h a c ha hc hc1 (ε / 2) (half_pos hε)
  -- Get N for inner sequence with ε / 4 tolerance
  have hε4 : ε / 4 > 0 := by linarith
  rw [Metric.tendsto_atTop] at htend_inner htend_outer
  obtain ⟨N_inner, hN_inner⟩ := htend_inner (ε / 4) hε4
  obtain ⟨N_outer, hN_outer⟩ := htend_outer (ε / 4) hε4
  use max N_inner N_outer
  intro n hn
  have hn_inner : n ≥ N_inner := le_trans (le_max_left _ _) hn
  have hn_outer : n ≥ N_outer := le_trans (le_max_right _ _) hn
  have hin_inner := hN_inner n hn_inner
  have hin_outer := hN_outer n hn_outer
  -- Apply monotonicity
  have hmono_inner : empiricalFrequency (fun n => u n ∈ Ico ((Ai : ℝ) / (b : ℝ) ^ k) ((Ci : ℝ) / (b : ℝ) ^ k)) n ≤
                     empiricalFrequency (fun n => u n ∈ Ico a c) n :=
    empiricalFrequency_mono (fun n h => hinner h) n
  have hmono_outer : empiricalFrequency (fun n => u n ∈ Ico a c) n ≤
                     empiricalFrequency (fun n => u n ∈ Ico ((Ao : ℝ) / (b : ℝ) ^ k) ((Co : ℝ) / (b : ℝ) ^ k)) n :=
    empiricalFrequency_mono (fun n h => houter h) n
  -- Extract bound values from distances
  rw [Real.dist_eq] at hin_inner hin_outer
  rw [abs_lt] at hin_inner hin_outer
  -- hin_inner : -ε/4 < inner_freq - inner_len ∧ inner_freq - inner_len < ε/4
  -- hin_outer : -ε/4 < outer_freq - outer_len ∧ outer_freq - outer_len < ε/4
  set infreq := empiricalFrequency (fun n => u n ∈ Ico ((Ai : ℝ) / (b : ℝ) ^ k) ((Ci : ℝ) / (b : ℝ) ^ k)) n with hinfreq_def
  set outfreq := empiricalFrequency (fun n => u n ∈ Ico ((Ao : ℝ) / (b : ℝ) ^ k) ((Co : ℝ) / (b : ℝ) ^ k)) n with houtfreq_def
  set midfreq := empiricalFrequency (fun n => u n ∈ Ico a c) n with hmidfreq_def
  set inlen := ((Ci : ℝ) - Ai) / (b : ℝ) ^ k with hinlen_def
  set outlen := ((Co : ℝ) - Ao) / (b : ℝ) ^ k with houtlen_def
  -- From hin_inner: inlen - ε/4 < infreq < inlen + ε/4
  have hinfreq_lower : infreq > inlen - ε / 4 := by linarith [hin_inner.1]
  have hinfreq_upper : infreq < inlen + ε / 4 := by linarith [hin_inner.2]
  -- From hin_outer: outlen - ε/4 < outfreq < outlen + ε/4
  have houtfreq_lower : outfreq > outlen - ε / 4 := by linarith [hin_outer.1]
  have houtfreq_upper : outfreq < outlen + ε / 4 := by linarith [hin_outer.2]
  -- From hinner_len: (c - a) - ε/2 < inlen
  have hinlen_lower : inlen > (c - a) - ε / 2 := hinner_len
  -- From houter_len: outlen < (c - a) + ε/2
  have houtlen_upper : outlen < (c - a) + ε / 2 := houter_len
  -- Combine bounds: midfreq > (c - a) - 3ε/4 and midfreq < (c - a) + 3ε/4
  have hmid_lower : midfreq > (c - a) - 3 * ε / 4 := by linarith
  have hmid_upper : midfreq < (c - a) + 3 * ε / 4 := by linarith
  -- Therefore dist midfreq (c - a) < ε
  rw [Real.dist_eq, abs_lt]
  constructor <;> linarith

/-- **Converse criterion.** Expected limiting frequencies on all aligned
base-`b` intervals imply interval equidistribution. -/
theorem intervalEquidistributed_of_bAdic_interval_frequencies
    {b : ℕ} (u : ℕ → ℝ) (h : HasBAdicIntervalFrequencies b u) :
    IntervalEquidistributed u :=
  intervalEquidistributed_of_bAdic_sandwich u
    (hasBAdicSandwichFrequencies_of_interval_frequencies h)

/-- **Cylinder converse criterion.** Uniform limiting frequencies for every
individual aligned base-`b` cylinder imply interval equidistribution. -/
theorem intervalEquidistributed_of_bAdic_cylinder_frequencies
    {b : ℕ} (u : ℕ → ℝ) (h : HasBAdicCylinderFrequencies b u) :
    IntervalEquidistributed u :=
  intervalEquidistributed_of_bAdic_interval_frequencies u
    (hasBAdicIntervalFrequencies_of_cylinder_frequencies h)

/-- The cylinder converse specialized to the multiplicative fractional-part orbit. -/
theorem fract_orbit_intervalEquidistributed_of_bAdic_cylinder_frequencies
    {b : ℕ} (x : ℝ)
    (h : HasBAdicCylinderFrequencies b
      (fun n => Int.fract ((b : ℝ) ^ n * x))) :
    IntervalEquidistributed (fun n => Int.fract ((b : ℝ) ^ n * x)) :=
  intervalEquidistributed_of_bAdic_cylinder_frequencies _ h

/-- The aligned-interval converse specialized to a multiplicative fractional-part
orbit. -/
theorem fract_orbit_intervalEquidistributed_of_bAdic_interval_frequencies
    {b : ℕ} (x : ℝ)
    (h : HasBAdicIntervalFrequencies b
      (fun n => Int.fract ((b : ℝ) ^ n * x))) :
    IntervalEquidistributed (fun n => Int.fract ((b : ℝ) ^ n * x)) :=
  intervalEquidistributed_of_bAdic_interval_frequencies _ h

/-- The criterion applies directly to the multiplicative orbit modulo one. -/
theorem fract_orbit_intervalEquidistributed_of_bAdic_sandwich
    {b : ℕ} (x : ℝ)
    (h : HasBAdicSandwichFrequencies b
      (fun n => Int.fract ((b : ℝ) ^ n * x))) :
    IntervalEquidistributed (fun n => Int.fract ((b : ℝ) ^ n * x)) :=
  intervalEquidistributed_of_bAdic_sandwich _ h

end NormalityConverse