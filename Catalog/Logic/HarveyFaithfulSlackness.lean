import Mathlib

/-!
# Faithful-model slackness for Harvey's `N^{1/5}` factoring algorithm

Harvey's deterministic `N^{1/5}` factoring algorithm (Math. Comp. 90 (2021); arXiv:2010.05450)
is analysed in the catalog (`Crypto.FactoringBarrier.HarveyFloor`,
`Crypto.FactoringBarrier.HarveyBalance`) through the **three-leg** cost
`max{ r, m, N^{1/2}/(r^{1/2} m) }` (pair floor, baby-step budget, BSGS interior).

Algorithm 4.3 Step 2 additionally fixes `M := ⌈(N/r)^{1/2}⌉`, which costs `(N/r)^{1/4}`
(up to logarithms). The **faithful** four-leg cost is therefore
`max{ (N/r)^{1/4}, N^{1/2}/(r^{1/2} m), r, m }`.

This file shows, in the exponent model (`r = N^a`, `m = N^b`, exponents in `ℚ`) and in
the genuine real-power model:

* `pair_leg_lower`, `slackness_any_replacement`, `faithful_slackness_real`: the two legs
  `(N/r)^{1/4}` and `r` **alone** already force `N^{1/5}`. Replacing the interior and the
  `m`-leg by *anything* (even deleting them) cannot go below `N^{1/5}`.
* `faithful_unique_minimizer`, `relax_unique_minimizer`: both models have the *same*
  unique minimiser `a = b = 1/5`. The four legs co-bind there, but the value `1/5` has
  **two disjoint certificates**: `{M-leg, r}` and `{interior, r, m}`.
* `beating_fifth_requires_both`: any modified four-leg cost with exponent `< 1/5` must
  cheapen the `M`-leg **and** cheapen the interior or the `m`-leg. Improving one family
  alone is provably useless.
* `m_floor_deletion`, `pair_floor_deletion`: deleting the baby-step floor gives `1/3`
  (penalty `2/15`), deleting the pair floor gives `1/4` (penalty `1/20`). This settles the
  attribution: `N^{1/20}` is the pair-floor deletion, the `m`-floor deletion costs `2/15`.
* `fourth_floor_blocked`, `fourth_floor_relaxed_reaches_sixth`: a fourth search floor of
  weight `1/2` *does* give `1/6` in the three-leg relaxation, but **not** in the faithful
  model, because the new floor does not enter the `M`-leg. The "fourth floor" lever is a
  property of the relaxation.
* `mleg_pair_optimum`, `sixth_needs_mleg_exponent`: with an `M`-leg of shape `(N/r)^μ`
  the `{M, r}` pair alone is optimised at exactly `μ/(1+μ)`; Harvey's `μ = 1/4` gives `1/5`,
  and `1/6` requires `μ ≤ 1/5`.
* `partition_lemma_sq`, `partition_lemma`, `partition_lemma_strict`: a `k`-level
  baby-step/giant-step structure with `L_i T_i ≥ S_i` over a pool `S = Σ S_i` costs
  `Σ (L_i + T_i) ≥ 2 √S`, **strictly** more as soon as two levels carry part of the pool;
  `uniform_split_cost` shows the uniform `k`-way split costs exactly `√k` times as much.
* `independent_certificate_law`: in the generalised model
  `max{ (N/r)^μ, N^γ/(r^α m), r, m }` the optimum is exactly
  `max(μ/(1+μ), γ/(2+α))` — the two certificates never interact.
* `coupling_alone_useless`, `coupled_sixth_iff`: coupling the `M`-leg to the baby steps
  (exponent `(1-a)/4 - θ b`) is useless alone, and together with a weight-`1/2` fourth floor
  reaches `1/6` **iff** `θ ≥ 1/4`.
-/

namespace Logic.HarveyFaithfulSlackness

open Finset

/-! ## Exponent model -/

/-- The catalog's three-leg exponent (identical to `HarveyBalance.costExp`):
`r = N^a` (pair floor), `m = N^b` (baby steps), interior `N^{1/2 - a/2 - b}`. -/
def relaxExp (a b : ℚ) : ℚ := max a (max b (1 / 2 - a / 2 - b))

/-- The faithful four-leg exponent: the three-leg cost plus the `M`-leg `(N/r)^{1/4}`
forced by Algorithm 4.3 Step 2. -/
def faithfulExp (a b : ℚ) : ℚ := max ((1 - a) / 4) (relaxExp a b)

/-- The two-leg core `{M-leg, r}` of the faithful model. -/
def pairLegExp (a : ℚ) : ℚ := max ((1 - a) / 4) a

/-- The `{M-leg, r}` core alone forces exponent `1/5`. -/
theorem pair_leg_lower (a : ℚ) : 1 / 5 ≤ pairLegExp a := by
  unfold pairLegExp
  rcases le_or_gt (1 / 5) a with h | h
  · exact le_max_of_le_right h
  · exact le_max_of_le_left (by linarith)

/-- **Slackness.** Replace the interior by any `f` and the `m`-leg by any `g`
(even `-∞`-like values, i.e. delete them): the faithful cost stays `≥ 1/5`. -/
theorem slackness_any_replacement (a f g : ℚ) :
    1 / 5 ≤ max ((1 - a) / 4) (max f (max a g)) := by
  have h := pair_leg_lower a
  unfold pairLegExp at h
  rcases le_max_iff.mp h with h1 | h1
  · exact le_max_of_le_left h1
  · exact le_max_of_le_right (le_max_of_le_right (le_max_of_le_left h1))

/-- The three-leg relaxation is bounded below by `1/5`. -/
theorem relax_lower (a b : ℚ) : 1 / 5 ≤ relaxExp a b := by
  unfold relaxExp
  by_contra hcon
  simp only [le_max_iff, not_or, not_le] at hcon
  obtain ⟨h1, h2, h3⟩ := hcon
  linarith

/-- The faithful cost dominates the relaxation. -/
theorem faithful_ge_relax (a b : ℚ) : relaxExp a b ≤ faithfulExp a b :=
  le_max_right _ _

theorem faithful_lower (a b : ℚ) : 1 / 5 ≤ faithfulExp a b :=
  (relax_lower a b).trans (faithful_ge_relax a b)

/-- All four legs coincide at `a = b = 1/5`. -/
theorem faithful_attained : faithfulExp (1 / 5) (1 / 5) = 1 / 5 := by
  unfold faithfulExp relaxExp; norm_num

/-- The faithful model has the **unique** minimiser `a = b = 1/5`. -/
theorem faithful_unique_minimizer (a b : ℚ) (h : faithfulExp a b ≤ 1 / 5) :
    a = 1 / 5 ∧ b = 1 / 5 := by
  unfold faithfulExp relaxExp at h
  simp only [max_le_iff] at h
  obtain ⟨h1, h2, h3, h4⟩ := h
  constructor <;> linarith

/-- The relaxation has the same unique minimiser. -/
theorem relax_unique_minimizer (a b : ℚ) (h : relaxExp a b ≤ 1 / 5) :
    a = 1 / 5 ∧ b = 1 / 5 := by
  unfold relaxExp at h
  simp only [max_le_iff] at h
  obtain ⟨h2, h3, h4⟩ := h
  constructor <;> linarith

/-- **Two disjoint certificates; improvement must hit both.** Take any modified four-leg
cost `max{M', f, a, g}` (modified `M`-leg `M'`, interior `f`, `m`-leg `g`). If it is
below `1/5`, then the `M`-leg was cheapened below `(1-a)/4` **and**, for every baby-step
exponent `b`, the interior was cheapened below `1/2 - a/2 - b` or the `m`-leg below `b`. -/
theorem beating_fifth_requires_both (a M' f g : ℚ)
    (h : max M' (max f (max a g)) < 1 / 5) :
    M' < (1 - a) / 4 ∧ ∀ b : ℚ, f < 1 / 2 - a / 2 - b ∨ g < b := by
  simp only [max_lt_iff] at h
  obtain ⟨hM, hf, ha, hg⟩ := h
  refine ⟨by linarith, fun b => ?_⟩
  by_contra hc
  simp only [not_or, not_lt] at hc
  obtain ⟨hc1, hc2⟩ := hc
  have := relax_lower a b
  unfold relaxExp at this
  simp only [le_max_iff] at this
  rcases this with h1 | h1 | h1 <;> linarith

/-! ## Floor deletions (the `#421` attribution) -/

/-- Deleting the baby-step floor (`b = 0`): optimum exactly `1/3`. -/
theorem m_floor_deletion :
    (∀ a : ℚ, 1 / 3 ≤ faithfulExp a 0) ∧ faithfulExp (1 / 3) 0 = 1 / 3 := by
  refine ⟨fun a => ?_, by unfold faithfulExp relaxExp; norm_num⟩
  unfold faithfulExp relaxExp
  rcases le_or_gt (1 / 3) a with h | h
  · exact le_max_of_le_right (le_max_of_le_left h)
  · exact le_max_of_le_right (le_max_of_le_right (le_max_of_le_right (by linarith)))

/-- Deleting the pair floor (`a = 0`): optimum exactly `1/4`. -/
theorem pair_floor_deletion :
    (∀ b : ℚ, 1 / 4 ≤ faithfulExp 0 b) ∧ faithfulExp 0 (1 / 4) = 1 / 4 := by
  refine ⟨fun b => le_max_of_le_left (by norm_num), by unfold faithfulExp relaxExp; norm_num⟩

/-- The two deletion penalties: `m`-floor `2/15`, pair floor `1/20`. -/
theorem deletion_penalties : (1 / 3 : ℚ) - 1 / 5 = 2 / 15 ∧ (1 / 4 : ℚ) - 1 / 5 = 1 / 20 := by
  norm_num

/-! ## The fourth-floor lever -/

/-- Four-floor relaxation: a new search floor `c` of weight `w` enters the interior only. -/
def relaxFourExp (a b c w : ℚ) : ℚ := max a (max b (max c (1 / 2 - a / 2 - b - w * c)))

/-- Faithful four-floor model: the `M`-leg is untouched by the new floor. -/
def faithfulFourExp (a b c w : ℚ) : ℚ := max ((1 - a) / 4) (relaxFourExp a b c w)

/-- In the relaxation, a fourth floor of weight `1/2` reaches `1/6` … -/
theorem fourth_floor_relaxed_reaches_sixth :
    relaxFourExp (1 / 6) (1 / 6) (1 / 6) (1 / 2) = 1 / 6 := by
  unfold relaxFourExp; norm_num

/-- … and `1/6` is optimal there (for `w = 1/2`). -/
theorem fourth_floor_relaxed_lower (a b c : ℚ) : 1 / 6 ≤ relaxFourExp a b c (1 / 2) := by
  unfold relaxFourExp
  by_contra hcon
  simp only [le_max_iff, not_or, not_le] at hcon
  obtain ⟨h1, h2, h3, h4⟩ := hcon
  linarith

/-- **The lever is blocked in the faithful model**: for every weight `w` and every value of
the new floor, the faithful four-floor cost is still `≥ 1/5`. -/
theorem fourth_floor_blocked (a b c w : ℚ) : 1 / 5 ≤ faithfulFourExp a b c w := by
  unfold faithfulFourExp relaxFourExp
  rcases le_max_iff.mp (pair_leg_lower a) with h | h
  · exact le_max_of_le_left h
  · exact le_max_of_le_right (le_max_of_le_left h)

/-! ## A generalised `M`-leg `(N/r)^μ` -/

/-- With an `M`-leg of exponent `μ(1-a)`, the `{M, r}` pair is optimised at `μ/(1+μ)`. -/
theorem mleg_pair_optimum (μ : ℚ) (hμ : 0 < μ) :
    (∀ a : ℚ, μ / (1 + μ) ≤ max (μ * (1 - a)) a) ∧
      max (μ * (1 - μ / (1 + μ))) (μ / (1 + μ)) = μ / (1 + μ) := by
  have h1 : (0 : ℚ) < 1 + μ := by linarith
  have key : μ * (1 - μ / (1 + μ)) = μ / (1 + μ) := by field_simp; ring
  refine ⟨fun a => ?_, by rw [key, max_self]⟩
  rcases le_or_gt (μ / (1 + μ)) a with h | h
  · exact le_max_of_le_right h
  · refine le_max_of_le_left ?_
    rw [← key]
    exact mul_le_mul_of_nonneg_left (by linarith) hμ.le

/-- Harvey's `μ = 1/4` gives exactly `1/5`. -/
theorem harvey_mleg_gives_fifth : (1 / 4 : ℚ) / (1 + 1 / 4) = 1 / 5 := by norm_num

/-- Reaching exponent `1/6` past the `{M, r}` pair requires `μ ≤ 1/5`. -/
theorem sixth_needs_mleg_exponent (μ : ℚ) (hμ : 0 < μ)
    (h : ∃ a : ℚ, max (μ * (1 - a)) a ≤ 1 / 6) : μ ≤ 1 / 5 := by
  obtain ⟨a, ha⟩ := h
  have h1 := (mleg_pair_optimum μ hμ).1 a
  have h2 : μ / (1 + μ) ≤ 1 / 6 := h1.trans ha
  have h3 : (0 : ℚ) < 1 + μ := by linarith
  rw [div_le_iff₀ h3] at h2
  linarith

/-! ## Real-power model -/

/-- **Faithful slackness, real form.** For any `N, r > 0` and *arbitrary* replacements
`f` (interior) and `g` (`m`-leg), `max{(N/r)^{1/4}, f, r, g} ≥ N^{1/5}`. -/
theorem faithful_slackness_real (N r f g : ℝ) (hN : 0 < N) (hr : 0 < r) :
    N ^ ((1 : ℝ) / 5) ≤ max ((N / r) ^ ((1 : ℝ) / 4)) (max f (max r g)) := by
  by_contra hcon
  simp only [le_max_iff, not_or, not_le] at hcon
  obtain ⟨hM, -, hr5, -⟩ := hcon
  have hNr : 0 < N / r := div_pos hN hr
  have hM4 : ((N / r) ^ ((1 : ℝ) / 4)) ^ (4 : ℕ) < (N ^ ((1 : ℝ) / 5)) ^ (4 : ℕ) :=
    pow_lt_pow_left₀ hM (by positivity) (by norm_num)
  have e1 : ((N / r) ^ ((1 : ℝ) / 4)) ^ (4 : ℕ) = N / r := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul hNr.le]; norm_num
  have e2 : (N ^ ((1 : ℝ) / 5)) ^ (4 : ℕ) = N ^ ((4 : ℝ) / 5) := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul hN.le]; norm_num
  rw [e1, e2, div_lt_iff₀ hr] at hM4
  have e3 : N ^ ((4 : ℝ) / 5) * N ^ ((1 : ℝ) / 5) = N := by
    rw [← Real.rpow_add hN]; norm_num
  have hpos : 0 < N ^ ((4 : ℝ) / 5) := by positivity
  have : N ^ ((4 : ℝ) / 5) * r < N ^ ((4 : ℝ) / 5) * N ^ ((1 : ℝ) / 5) :=
    mul_lt_mul_of_pos_left hr5 hpos
  linarith

/-- At `r = m = N^{1/5}` all four faithful legs equal `N^{1/5}`. -/
theorem faithful_legs_coincide_real (N : ℝ) (hN : 0 < N) :
    (N / N ^ ((1 : ℝ) / 5)) ^ ((1 : ℝ) / 4) = N ^ ((1 : ℝ) / 5) ∧
      N ^ ((1 : ℝ) / 2) / ((N ^ ((1 : ℝ) / 5)) ^ ((1 : ℝ) / 2) * N ^ ((1 : ℝ) / 5))
        = N ^ ((1 : ℝ) / 5) := by
  constructor
  · have : N / N ^ ((1 : ℝ) / 5) = N ^ ((4 : ℝ) / 5) := by
      rw [div_eq_iff (by positivity), ← Real.rpow_add hN]; norm_num
    rw [this, ← Real.rpow_mul hN.le]; norm_num
  · rw [← Real.rpow_mul hN.le, ← Real.rpow_add hN, ← Real.rpow_sub hN]; norm_num

/-! ## The partition lemma for multi-level baby-step structures -/

/-- Squared form: `4 Σ S_i ≤ (Σ (L_i + T_i))²` whenever `S_i ≤ L_i T_i`, `L_i, T_i ≥ 0`. -/
theorem partition_lemma_sq {ι : Type*} [DecidableEq ι] (s : Finset ι) (L T S : ι → ℝ)
    (hL : ∀ i ∈ s, 0 ≤ L i) (hT : ∀ i ∈ s, 0 ≤ T i) (hLT : ∀ i ∈ s, S i ≤ L i * T i) :
    4 * ∑ i ∈ s, S i ≤ (∑ i ∈ s, (L i + T i)) ^ 2 := by
  induction s using Finset.induction_on with
  | empty => simp
  | insert a s ha ih =>
    rw [sum_insert ha, sum_insert ha]
    have h1 := ih (fun i hi => hL i (mem_insert_of_mem hi))
      (fun i hi => hT i (mem_insert_of_mem hi)) (fun i hi => hLT i (mem_insert_of_mem hi))
    have ha1 := hL a (mem_insert_self a s)
    have ha2 := hT a (mem_insert_self a s)
    have ha3 := hLT a (mem_insert_self a s)
    have hs : 0 ≤ ∑ i ∈ s, (L i + T i) := sum_nonneg (fun i hi =>
      add_nonneg (hL i (mem_insert_of_mem hi)) (hT i (mem_insert_of_mem hi)))
    nlinarith [sq_nonneg (L a - T a), mul_nonneg (add_nonneg ha1 ha2) hs]

/-- **Partition lemma.** Any multi-level structure over the pool `S = Σ S_i` with
`L_i T_i ≥ S_i` costs at least `2 √S`. -/
theorem partition_lemma {ι : Type*} [DecidableEq ι] (s : Finset ι) (L T S : ι → ℝ)
    (hL : ∀ i ∈ s, 0 ≤ L i) (hT : ∀ i ∈ s, 0 ≤ T i) (hS : ∀ i ∈ s, 0 ≤ S i)
    (hLT : ∀ i ∈ s, S i ≤ L i * T i) :
    2 * Real.sqrt (∑ i ∈ s, S i) ≤ ∑ i ∈ s, L i + ∑ i ∈ s, T i := by
  rw [← sum_add_distrib]
  have h := partition_lemma_sq s L T S hL hT hLT
  have hX : 0 ≤ ∑ i ∈ s, S i := sum_nonneg hS
  have hu : 0 ≤ ∑ i ∈ s, (L i + T i) := sum_nonneg (fun i hi => add_nonneg (hL i hi) (hT i hi))
  by_contra hc
  push_neg at hc
  nlinarith [Real.sq_sqrt hX, Real.sqrt_nonneg (∑ i ∈ s, S i)]

/-- **Strict partition lemma.** If two distinct levels both carry a positive part of the
pool, the cost is *strictly* above `2 √S`: equality forces a single level. -/
theorem partition_lemma_strict {ι : Type*} [DecidableEq ι] (s : Finset ι) (L T S : ι → ℝ)
    (hL : ∀ i ∈ s, 0 ≤ L i) (hT : ∀ i ∈ s, 0 ≤ T i) (hS : ∀ i ∈ s, 0 ≤ S i)
    (hLT : ∀ i ∈ s, S i ≤ L i * T i) {i j : ι} (hi : i ∈ s) (hj : j ∈ s) (hij : i ≠ j)
    (hSi : 0 < S i) (hSj : 0 < S j) :
    2 * Real.sqrt (∑ k ∈ s, S k) < ∑ k ∈ s, L k + ∑ k ∈ s, T k := by
  rw [← sum_add_distrib]
  have hj' : j ∈ s.erase i := mem_erase.mpr ⟨hij.symm, hj⟩
  set t := (s.erase i).erase j with ht
  have hts : ∀ k ∈ t, k ∈ s := fun k hk => mem_of_mem_erase (mem_of_mem_erase hk)
  have hrest := partition_lemma_sq t L T S (fun k hk => hL k (hts k hk))
    (fun k hk => hT k (hts k hk)) (fun k hk => hLT k (hts k hk))
  have hu : 0 ≤ ∑ k ∈ t, (L k + T k) :=
    sum_nonneg (fun k hk => add_nonneg (hL k (hts k hk)) (hT k (hts k hk)))
  have eU : ∑ k ∈ s, (L k + T k) = (L i + T i) + ((L j + T j) + ∑ k ∈ t, (L k + T k)) := by
    rw [← add_sum_erase s _ hi, ← add_sum_erase (s.erase i) _ hj']
  have eS : ∑ k ∈ s, S k = S i + (S j + ∑ k ∈ t, S k) := by
    rw [← add_sum_erase s _ hi, ← add_sum_erase (s.erase i) _ hj']
  have hX : 0 ≤ ∑ k ∈ s, S k := sum_nonneg hS
  have hLi := hL i hi; have hTi := hT i hi; have hLTi := hLT i hi
  have hLj := hL j hj; have hTj := hT j hj; have hLTj := hLT j hj
  have hpi : 0 < L i + T i := by
    by_contra h0; push_neg at h0
    have : L i = 0 := by linarith
    rw [this] at hLTi; linarith
  have hpj : 0 < L j + T j := by
    by_contra h0; push_neg at h0
    have : L j = 0 := by linarith
    rw [this] at hLTj; linarith
  have hsq : 4 * ∑ k ∈ s, S k < (∑ k ∈ s, (L k + T k)) ^ 2 := by
    rw [eU, eS]
    nlinarith [sq_nonneg (L i - T i), sq_nonneg (L j - T j), mul_pos hpi hpj,
      mul_nonneg hpi.le hu, mul_nonneg hpj.le hu]
  have hU : 0 ≤ ∑ k ∈ s, (L k + T k) :=
    sum_nonneg (fun k hk => add_nonneg (hL k hk) (hT k hk))
  by_contra hc
  push_neg at hc
  nlinarith [Real.sq_sqrt hX, Real.sqrt_nonneg (∑ k ∈ s, S k)]

/-- The uniform `k`-way split (`S_i = S/k`, `L_i = T_i = √(S/k)`) costs exactly `√k · 2√S`:
a multiplicative penalty of `√k` over the single-level optimum. -/
theorem uniform_split_cost (S : ℝ) (hS : 0 ≤ S) (k : ℕ) (hk : 0 < k) :
    (k : ℝ) * (2 * Real.sqrt (S / k)) = Real.sqrt k * (2 * Real.sqrt S) := by
  have hk' : (0 : ℝ) < k := by exact_mod_cast hk
  rw [Real.sqrt_div hS]
  have hsk : 0 < Real.sqrt k := Real.sqrt_pos.mpr hk'
  have : (k : ℝ) = Real.sqrt k * Real.sqrt k := (Real.mul_self_sqrt hk'.le).symm
  field_simp
  nth_rewrite 1 [this]
  ring

/-! ## Independent certificate law

Generalised faithful model `max{ μ(1-a), γ - α a - b, a, b }` (exponents of
`(N/r)^μ`, `N^γ/(r^α m)`, `r`, `m`). The optimum is exactly the larger of the two
independent certificates `μ/(1+μ)` (`{M, r}`) and `γ/(2+α)` (`{interior, r, m}`). -/

/-- Generalised faithful four-leg exponent. -/
def genFaithfulExp (μ γ α a b : ℚ) : ℚ := max (μ * (1 - a)) (max (γ - α * a - b) (max a b))

/-- The `{interior, r, m}` triple alone forces `γ/(2+α)` (for `α ≥ 0`). -/
theorem interior_triple_lower (γ α a b : ℚ) (hα : 0 ≤ α) :
    γ / (2 + α) ≤ max (γ - α * a - b) (max a b) := by
  have h2 : (0 : ℚ) < 2 + α := by linarith
  rw [div_le_iff₀ h2]
  by_contra hcon
  push_neg at hcon
  set t := max (γ - α * a - b) (max a b) with ht
  have h1 : γ - α * a - b ≤ t := le_max_left _ _
  have ha : a ≤ t := le_trans (le_max_left _ _) (le_max_right _ _)
  have hb : b ≤ t := le_trans (le_max_right _ _) (le_max_right _ _)
  nlinarith [mul_le_mul_of_nonneg_left ha hα]

/-- **Independent certificate law.** For `μ > 0`, `α ≥ 0`, the generalised faithful cost
is everywhere `≥ max(μ/(1+μ), γ/(2+α))`, and this value is attained. The two certificates
never interact: the optimum is the worse of the two. -/
theorem independent_certificate_law (μ γ α : ℚ) (hμ : 0 < μ) (hα : 0 ≤ α) :
    (∀ a b : ℚ, max (μ / (1 + μ)) (γ / (2 + α)) ≤ genFaithfulExp μ γ α a b) ∧
      ∃ a b : ℚ, genFaithfulExp μ γ α a b = max (μ / (1 + μ)) (γ / (2 + α)) := by
  have h1 : (0 : ℚ) < 1 + μ := by linarith
  have h2 : (0 : ℚ) < 2 + α := by linarith
  refine ⟨fun a b => ?_, ?_⟩
  · unfold genFaithfulExp
    refine max_le ?_ ?_
    · have hp := (mleg_pair_optimum μ hμ).1 a
      rcases le_max_iff.mp hp with h | h
      · exact le_max_of_le_left h
      · exact le_max_of_le_right (le_max_of_le_right (le_max_of_le_left h))
    · exact le_max_of_le_right (interior_triple_lower γ α a b hα)
  · set t := max (μ / (1 + μ)) (γ / (2 + α)) with ht
    refine ⟨t, t, le_antisymm ?_ (le_max_of_le_right (le_max_of_le_right (le_max_left _ _)))⟩
    have hP : μ / (1 + μ) ≤ t := le_max_left _ _
    have hI : γ / (2 + α) ≤ t := le_max_right _ _
    have hP' : μ ≤ t * (1 + μ) := (div_le_iff₀ h1).mp hP
    have hI' : γ ≤ t * (2 + α) := (div_le_iff₀ h2).mp hI
    unfold genFaithfulExp
    refine max_le (by nlinarith) (max_le (by nlinarith) (by simp))

/-- Harvey's parameters `μ = 1/4`, `γ = 1/2`, `α = 1/2`: both certificates equal `1/5`. -/
theorem harvey_certificates_coincide :
    (1 / 4 : ℚ) / (1 + 1 / 4) = 1 / 5 ∧ (1 / 2 : ℚ) / (2 + 1 / 2) = 1 / 5 := by
  constructor <;> norm_num

/-! ## Coupling the `M`-leg to the baby steps

If the `M`-step could reuse the baby-step list, its exponent would become
`(1-a)/4 - θ b`. Alone this changes nothing (the interior triple still forces `1/5`);
together with a weight-`1/2` fourth floor it reaches `1/6` exactly when `θ ≥ 1/4`. -/

/-- Faithful cost with a baby-step-coupled `M`-leg and a fourth floor `c` of weight `w`. -/
def coupledFourExp (θ a b c w : ℚ) : ℚ := max ((1 - a) / 4 - θ * b) (relaxFourExp a b c w)

/-- Coupling the `M`-leg alone (no new floor) never beats `1/5`. -/
theorem coupling_alone_useless (θ a b : ℚ) :
    1 / 5 ≤ max ((1 - a) / 4 - θ * b) (relaxExp a b) :=
  le_max_of_le_right (relax_lower a b)

/-- With coupling `θ ≥ 1/4` and a weight-`1/2` fourth floor, the cost `1/6` is attained … -/
theorem coupled_reaches_sixth (θ : ℚ) (hθ : 1 / 4 ≤ θ) :
    coupledFourExp θ (1 / 6) (1 / 6) (1 / 6) (1 / 2) = 1 / 6 := by
  unfold coupledFourExp relaxFourExp
  have : (1 - 1 / 6 : ℚ) / 4 - θ * (1 / 6) ≤ 1 / 6 := by linarith
  rw [max_eq_right (by norm_num; linarith)]; norm_num

/-- … and it is optimal. -/
theorem coupled_lower (θ a b c : ℚ) : 1 / 6 ≤ coupledFourExp θ a b c (1 / 2) :=
  le_max_of_le_right (fourth_floor_relaxed_lower a b c)

/-- **Sharp threshold.** With a weight-`1/2` fourth floor, cost `≤ 1/6` is achievable
**iff** the coupling satisfies `θ ≥ 1/4`. -/
theorem coupled_sixth_iff (θ : ℚ) :
    (∃ a b c : ℚ, coupledFourExp θ a b c (1 / 2) ≤ 1 / 6) ↔ 1 / 4 ≤ θ := by
  constructor
  · rintro ⟨a, b, c, h⟩
    unfold coupledFourExp relaxFourExp at h
    simp only [max_le_iff] at h
    obtain ⟨hM, ha, hb, hc, hi⟩ := h
    have ea : a = 1 / 6 := by linarith
    have eb : b = 1 / 6 := by linarith
    subst ea eb
    linarith
  · intro hθ
    exact ⟨1 / 6, 1 / 6, 1 / 6, (coupled_reaches_sixth θ hθ).le⟩

end Logic.HarveyFaithfulSlackness