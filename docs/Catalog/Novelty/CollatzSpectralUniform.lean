import Catalog.Novelty.CollatzSpectralNormalized

/-!
# Uniform quantitative estimates and the blindness of one-step spectra

This file continues `Catalog/Novelty/CollatzSpectralNormalized.lean`.  There we
proved the limit law `F a ω N / N → limitAmp a ω`.  Here we make the convergence
*quantitative and uniform*, and we prove a sharp negative result explaining why a
one-step spectral statistic can never encode orbit information.

## Main results

* `norm_E_sub_one` — the exact identity `‖e(x) - 1‖ = 2 |sin(π x)|`.
* `norm_F_div_sub_limitAmp_le` — **explicit error bound**
  `‖F a ω N / N - limitAmp a ω‖ ≤ (1 + 2π|ω| (1 + log N)) / N`,
  uniform in the multiplier `a` and locally uniform in the frequency `ω`.
* `uniform_convergence_on_compacts` — consequently the normalized transforms
  converge uniformly on every compact frequency set `{|ω| ≤ M}`, simultaneously
  for all multipliers.
* `norm_Fgen_sub_le` and `spectral_blind_to_density_zero` — **no-go theorem**:
  two maps whose one-step phase ratios differ only on a set of density zero have
  the *same* normalized transform in the limit.
* `spectral_blind_to_finite_modification` — in particular, modifying the map at
  finitely many points (e.g. inserting or destroying a cycle) leaves the
  normalized spectrum unchanged.  Hence no implication of the form
  "spectral estimate ⟹ orbit hitting-time estimate" can hold for the one-step
  cutoff sum.
-/

namespace CollatzSpectral

open Filter Complex
open scoped Real Topology

/-! ## Sharp estimates for the character increment -/

lemma E_sub_E_neg (x : ℝ) : E x - E (-x) = 2 * (Real.sin (2 * Real.pi * x) : ℂ) * Complex.I := by
  rw [E, E, Complex.ofReal_sin, Complex.two_sin]
  push_cast
  ring_nf
  rw [Complex.I_sq]
  ring

/-- The exact modulus of the character increment. -/
lemma norm_E_sub_one (x : ℝ) : ‖E x - 1‖ = 2 * |Real.sin (Real.pi * x)| := by
  have ha : x / 2 + -(x / 2) = 0 := by ring
  have hb : x / 2 + x / 2 = x := by ring
  have h1 : E x - 1 = E (x / 2) * (E (x / 2) - E (-(x / 2))) := by
    rw [mul_sub, ← E_add, ← E_add, ha, hb, E_zero]
  have harg : 2 * Real.pi * (x / 2) = Real.pi * x := by ring
  rw [h1, E_sub_E_neg (x / 2), harg, norm_mul, norm_E, one_mul, norm_mul, norm_mul,
    Complex.norm_I, Complex.norm_real, Real.norm_eq_abs]
  norm_num

/-- The Lipschitz bound `‖e(x) - 1‖ ≤ 2π |x|`. -/
lemma norm_E_sub_one_le (x : ℝ) : ‖E x - 1‖ ≤ 2 * Real.pi * |x| := by
  rw [norm_E_sub_one]
  have h := Real.abs_sin_le_abs (x := Real.pi * x)
  rw [abs_mul, abs_of_pos Real.pi_pos] at h
  linarith

lemma norm_dseq_le_div (a : ℕ) (ω : ℝ) (k : ℕ) :
    ‖dseq a ω k‖ ≤ 2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1)) := by
  refine (norm_dseq_le a ω k).trans ?_
  refine (norm_E_sub_one_le (ω / ((k : ℝ) + 1))).trans ?_
  have hk : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  rw [abs_div, abs_of_pos hk]
  rw [div_eq_mul_one_div]
  ring_nf
  rfl

/-! ## The harmonic bound -/

lemma sum_one_div_le_one_add_log (N : ℕ) :
    ∑ k ∈ Finset.range N, (1 : ℝ) / ((k : ℝ) + 1) ≤ 1 + Real.log N := by
  have h := harmonic_le_one_add_log N
  have hq : ((harmonic N : ℚ) : ℝ) = ∑ k ∈ Finset.range N, (1 : ℝ) / ((k : ℝ) + 1) := by
    rw [harmonic]
    push_cast
    refine Finset.sum_congr rfl (fun k _ => ?_)
    rw [one_div]
  rwa [hq] at h

/-! ## The quantitative, uniform error bound -/

lemma norm_branchGap_le (a : ℕ) (ω : ℝ) : ‖branchGap a ω‖ ≤ 1 := by
  unfold branchGap
  rw [norm_div]
  have h1 : ‖E ((a : ℝ) * ω) - E (ω / 2)‖ ≤ ‖E ((a : ℝ) * ω)‖ + ‖E (ω / 2)‖ := norm_sub_le _ _
  rw [norm_E, norm_E] at h1
  have h2 : ‖(2 : ℂ)‖ = 2 := by norm_num
  rw [h2]
  linarith

/-- **Explicit error bound.**  The convergence `F a ω N / N → limitAmp a ω` holds
with rate `O((1 + |ω| log N)/N)`, and the implied constants are absolute: the
bound is uniform in the multiplier `a` and locally uniform in `ω`. -/
theorem norm_F_div_sub_limitAmp_le (a : ℕ) (ω : ℝ) {N : ℕ} (hN : 1 ≤ N) :
    ‖F a ω N / (N : ℂ) - limitAmp a ω‖
      ≤ (1 + 2 * Real.pi * |ω| * (1 + Real.log N)) / N := by
  have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN
  have hNc : (N : ℂ) ≠ 0 := by
    simp only [ne_eq, Nat.cast_eq_zero]
    omega
  have hdiff : F a ω N / (N : ℂ) - limitAmp a ω
      = (branchGap a ω * (∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)
        + ∑ k ∈ Finset.range N, dseq a ω k) / (N : ℂ) := by
    rw [F_eq]
    field_simp
    ring
  have halt : ‖branchGap a ω * (∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)‖ ≤ 1 := by
    rw [norm_mul]
    have hb : ‖∑ k ∈ Finset.range N, (-1 : ℂ) ^ k‖ ≤ 1 := by
      rw [neg_one_geom_sum]
      by_cases h : Even N <;> simp [h]
    have := norm_branchGap_le a ω
    nlinarith [norm_nonneg (branchGap a ω), norm_nonneg (∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)]
  have hsum : ‖∑ k ∈ Finset.range N, dseq a ω k‖ ≤ 2 * Real.pi * |ω| * (1 + Real.log N) := by
    refine (norm_sum_le _ _).trans ?_
    have hterm : ∑ k ∈ Finset.range N, ‖dseq a ω k‖
        ≤ ∑ k ∈ Finset.range N, 2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1)) :=
      Finset.sum_le_sum (fun k _ => norm_dseq_le_div a ω k)
    refine hterm.trans ?_
    rw [← Finset.mul_sum]
    have hpos : (0 : ℝ) ≤ 2 * Real.pi * |ω| := by positivity
    exact mul_le_mul_of_nonneg_left (sum_one_div_le_one_add_log N) hpos
  rw [hdiff, norm_div, Complex.norm_natCast]
  rw [div_le_div_iff_of_pos_right hN0]
  calc ‖branchGap a ω * (∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)
        + ∑ k ∈ Finset.range N, dseq a ω k‖
      ≤ ‖branchGap a ω * (∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)‖
        + ‖∑ k ∈ Finset.range N, dseq a ω k‖ := norm_add_le _ _
    _ ≤ 1 + 2 * Real.pi * |ω| * (1 + Real.log N) := by linarith

lemma tendsto_log_div_nat : Tendsto (fun N : ℕ => Real.log N / (N : ℝ)) atTop (𝓝 0) := by
  have h := Real.isLittleO_log_id_atTop.tendsto_div_nhds_zero
  exact h.comp tendsto_natCast_atTop_atTop

/-- The error bound tends to `0`, at a rate depending only on the frequency
bound `M`. -/
lemma tendsto_errorBound (M : ℝ) :
    Tendsto (fun N : ℕ => (1 + 2 * Real.pi * M * (1 + Real.log N)) / N) atTop (𝓝 0) := by
  have h1 : Tendsto (fun N : ℕ => (1 + 2 * Real.pi * M) / (N : ℝ)) atTop (𝓝 0) :=
    tendsto_const_div_atTop_nhds_zero_nat _
  have h2 : Tendsto (fun N : ℕ => (2 * Real.pi * M) * (Real.log N / (N : ℝ))) atTop (𝓝 0) := by
    simpa using tendsto_log_div_nat.const_mul (2 * Real.pi * M)
  have h3 := h1.add h2
  rw [add_zero] at h3
  refine h3.congr (fun N => ?_)
  by_cases hN : (N : ℝ) = 0
  · simp [hN]
  · field_simp
    ring

/-- **Uniform convergence on compact frequency sets.**  For every `M` and every
`ε > 0` there is a threshold, depending only on `M` and `ε`, beyond which the
normalized transform is `ε`-close to its amplitude for *all* multipliers `a` and
*all* frequencies with `|ω| ≤ M`.  This is the corrected replacement for the
impossible pointwise statement over all irrational frequencies. -/
theorem uniform_convergence_on_compacts (M : ℝ) {ε : ℝ} (hε : 0 < ε) :
    ∃ N₀ : ℕ, 1 ≤ N₀ ∧ ∀ N ≥ N₀, ∀ (a : ℕ) (ω : ℝ), |ω| ≤ M →
      ‖F a ω N / (N : ℂ) - limitAmp a ω‖ ≤ ε := by
  have hb := (tendsto_errorBound M).eventually (eventually_le_nhds hε)
  obtain ⟨N₁, hN₁⟩ := (hb.and (eventually_ge_atTop 1)).exists_forall_of_atTop
  refine ⟨N₁, (hN₁ N₁ le_rfl).2, fun N hN a ω hω => ?_⟩
  obtain ⟨hle, hone⟩ := hN₁ N hN
  refine (norm_F_div_sub_limitAmp_le a ω (le_trans (hN₁ N₁ le_rfl).2 hN)).trans ?_
  refine le_trans ?_ hle
  have hN0 : (0 : ℝ) < N := by
    have : 1 ≤ N := le_trans (hN₁ N₁ le_rfl).2 hN
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one this
  rw [div_le_div_iff_of_pos_right hN0]
  have hlogpos : 0 ≤ 1 + Real.log N := by
    have : (1 : ℝ) ≤ N := by
      have : 1 ≤ N := le_trans (hN₁ N₁ le_rfl).2 hN
      exact_mod_cast this
    have := Real.log_nonneg this
    linarith
  have : |ω| * (1 + Real.log N) ≤ M * (1 + Real.log N) :=
    mul_le_mul_of_nonneg_right hω hlogpos
  nlinarith [Real.pi_pos]

/-! ## The one-step spectrum is blind to sparse modifications -/

/-- The cutoff transform of an arbitrary phase-ratio function. -/
noncomputable def Fgen (r : ℕ → ℝ) (ω : ℝ) (N : ℕ) : ℂ :=
  ∑ k ∈ Finset.range N, E (ω * r (k + 1))

lemma F_eq_Fgen (a : ℕ) (ω : ℝ) (N : ℕ) : F a ω N = Fgen (ratio a) ω N := rfl

/-- The two transforms differ by at most twice the number of indices where the
phase ratios disagree. -/
theorem norm_Fgen_sub_le (r₁ r₂ : ℕ → ℝ) (ω : ℝ) (N : ℕ) :
    ‖Fgen r₁ ω N - Fgen r₂ ω N‖
      ≤ 2 * (((Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1))).card : ℝ) := by
  classical
  have hsplit : Fgen r₁ ω N - Fgen r₂ ω N
      = ∑ k ∈ (Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1)),
          (E (ω * r₁ (k + 1)) - E (ω * r₂ (k + 1))) := by
    unfold Fgen
    rw [← Finset.sum_sub_distrib]
    refine (Finset.sum_subset (Finset.filter_subset _ _) ?_).symm
    intro k hk hknot
    simp only [Finset.mem_filter, not_and, not_not] at hknot
    rw [hknot hk, sub_self]
  rw [hsplit]
  refine (norm_sum_le _ _).trans ?_
  have hb : ∀ k ∈ (Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1)),
      ‖E (ω * r₁ (k + 1)) - E (ω * r₂ (k + 1))‖ ≤ 2 := by
    intro k _
    refine (norm_sub_le _ _).trans ?_
    rw [norm_E, norm_E]
    norm_num
  calc ∑ k ∈ (Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1)),
        ‖E (ω * r₁ (k + 1)) - E (ω * r₂ (k + 1))‖
      ≤ ∑ _k ∈ (Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1)), (2 : ℝ) :=
        Finset.sum_le_sum hb
    _ = 2 * (((Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1))).card : ℝ) := by
        rw [Finset.sum_const, nsmul_eq_mul]; ring

/-- **No-go theorem: the one-step spectrum is blind to density-zero changes.**
If two phase-ratio functions disagree only on a set of indices of density zero,
their normalized cutoff transforms have the same asymptotic behaviour.  Orbit
data (cycles, stopping times on sparse sets) therefore cannot be recovered from
the one-step transform. -/
theorem spectral_blind_to_density_zero (r₁ r₂ : ℕ → ℝ) (ω : ℝ)
    (h : Tendsto (fun N : ℕ =>
      ((((Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1))).card : ℝ)) / (N : ℝ))
      atTop (𝓝 0)) :
    Tendsto (fun N : ℕ => Fgen r₁ ω N / (N : ℂ) - Fgen r₂ ω N / (N : ℂ)) atTop (𝓝 0) := by
  classical
  refine squeeze_zero_norm (fun N => ?_)
    (by simpa using h.const_mul (2 : ℝ))
  rw [div_sub_div_same, norm_div, Complex.norm_natCast]
  rcases Nat.eq_zero_or_pos N with hN | hN
  · simp [hN, Fgen]
  · have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
    rw [div_le_iff₀ hN0]
    have := norm_Fgen_sub_le r₁ r₂ ω N
    have hmul : 2 * (((Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1))).card : ℝ)
        = 2 * ((((Finset.range N).filter (fun k => r₁ (k + 1) ≠ r₂ (k + 1))).card : ℝ) / N) * N := by
      field_simp
    linarith [hmul ▸ this]

/-- **Corollary: cycles are spectrally invisible.**  If a phase-ratio function
agrees with `ratio a` outside a finite set of arguments -- for instance because
the underlying map was altered along one finite orbit or cycle -- then its
normalized transform still converges to `limitAmp a ω`.  Consequently no
nontrivial orbit statement (hitting times, cycle structure) is implied by, or
implies, the one-step spectral asymptotics. -/
theorem spectral_blind_to_finite_modification (a : ℕ) (ω : ℝ) (r : ℕ → ℝ) (S : Finset ℕ)
    (h : ∀ n, n ∉ S → r n = ratio a n) :
    Tendsto (fun N : ℕ => Fgen r ω N / (N : ℂ)) atTop (𝓝 (limitAmp a ω)) := by
  classical
  have hcard : ∀ N : ℕ,
      (((Finset.range N).filter (fun k => r (k + 1) ≠ ratio a (k + 1))).card : ℝ) ≤ S.card := by
    intro N
    have hsub : ((Finset.range N).filter (fun k => r (k + 1) ≠ ratio a (k + 1))).card ≤ S.card := by
      refine Finset.card_le_card_of_injOn (fun k => k + 1) ?_ ?_
      · intro k hk
        simp only [Finset.coe_filter, Set.mem_setOf_eq] at hk
        by_contra hnot
        have hnS : (k + 1) ∉ S := by simpa using hnot
        exact hk.2 (h (k + 1) hnS)
      · intro x _ y _ hxy
        simpa using hxy
    exact_mod_cast hsub
  have hdens : Tendsto (fun N : ℕ =>
      ((((Finset.range N).filter (fun k => r (k + 1) ≠ ratio a (k + 1))).card : ℝ)) / (N : ℝ))
      atTop (𝓝 0) := by
    refine squeeze_zero (fun N => by positivity) (fun N => ?_)
      (tendsto_const_div_atTop_nhds_zero_nat (S.card : ℝ))
    rcases Nat.eq_zero_or_pos N with hN | hN
    · simp [hN]
    · have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
      exact (div_le_div_iff_of_pos_right hN0).mpr (hcard N)
  have hdiff := spectral_blind_to_density_zero r (ratio a) ω hdens
  have hF : Tendsto (fun N : ℕ => F a ω N / (N : ℂ)) atTop (𝓝 (limitAmp a ω)) := tendsto_F_div a ω
  have := hdiff.add hF
  rw [zero_add] at this
  refine this.congr (fun N => ?_)
  rw [F_eq_Fgen]
  ring

end CollatzSpectral