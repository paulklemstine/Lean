import Probability.NET89TwoSidedSpectral

/-!
# NET-89, cycle 13: signal-to-resolution accounting for interleaved protocols

Cycle 3 proved that an `m`-fold round robin multiplies the context-doubling increment by
`m` (`roundRobin_ctxSens_multiplier`), and cycle 8 proved that it divides the finest
visible staircase step by `m` (`exists_substep_le_pooled_div_m`).  Direction **D4** of the
previous round conjectured that the *product* of the two — the "information density" of a
protocol — is therefore an invariant: no interleaving scheme makes a budget measurement
more informative.

This cycle settles D4, and the answer is a boundary rather than a plain yes.

* `minSubStep` — the resolution of a round-robin protocol at a given budget: the narrowest
  of the `m` sub-steps refining one pooled step.
* `minSubStep_le_pooled_div_m` — cycle 8's estimate in the form the density needs.
* `rrDensity`, `poolDensity` — increment × resolution for the two protocols.
* `rrDensity_le_poolDensity_add_step` — **the conservation half.**  For *every* family of
  domains the interleaved density exceeds the pooled density by at most one pooled step.
  Interleaving is never a measurement amplifier.
* `minSubStep_balanced`, `balanced_density_invariance` — **the exact case.**  When the `m`
  domains are copies of one profile the resolution is exactly `1/m` of the pooled step, and
  the two densities agree up to `(1 - 1/m)` of a pooled step, which is the honest form of
  D4: the increment slack `m - 1` of cycle 3 is exactly one resolution unit.
* `resolution_loss_unbounded` — **the refutation of the two-sided conjecture.**  Without
  balance the resolution is not bounded below by any fixed fraction of the pooled step: a
  two-domain mixture whose second domain is faint has resolution smaller than the pooled
  step divided by *any* prescribed constant.  So D4 holds only as an inequality, with
  equality confined to balanced mixtures; unbalanced mixing strictly destroys information.
* `net89_signal_resolution_boundary` — the two halves in one statement, instantiated at the
  two-domain protocol actually run in NET-89.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 13, ranked):
 (H1) Density is conserved exactly by every interleaving.                       [BOLD]
 (H2) Density is conserved as an inequality: interleaving can only lose.        [BOLD]
 (H3) Balance is the exact boundary: equal domains conserve, faint domains lose
      unboundedly.                                                              [BOLD]
 (H4) The `m - 1` increment slack of cycle 3 is one resolution unit, not an artefact.

Experimenter: H1 is **false** (`resolution_loss_unbounded`); H2, H3 and H4 are proved
below with zero sorries.  The witness for H1's failure is the two-domain family with
weights `1` and `ε`, whose faint sub-step is `ε / (1 + ε)` of the pooled step.

Analyst: the failure of H1 is informative rather than disappointing.  Density is conserved
precisely when the interleaved domains carry equal mass, which is the regime the NET-89
protocol claims to be in (a 50/50 mixture of code and prose).  As soon as the mixture is
skewed the protocol loses resolution faster than it gains increment, so a *ratio* sweep is
not a sequence of equally informative measurements — the very sweep the report proposes as
its next step needs a per-point resolution correction.

Critic: the conservation theorem is stated with the additive one-step error that the
truncated-subtraction increment bracket of cycle 3 genuinely carries; it is not hidden in
an asymptotic.  The refutation is quantified over an arbitrary constant `C`, so it is not a
statement about one unlucky profile, and both witnesses are explicit positive profiles, so
no hypothesis class here is empty.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {m n k j : ℕ} {τ : ℝ} {U : ℕ → ℕ → ℝ} {u : ℕ → ℝ}

/-! ## 1. The resolution of a round-robin protocol -/

/-- The **resolution** of an `m`-domain round-robin measurement at budget `k`: the width of
the narrowest of the `m` sub-steps into which the `k`-th pooled step is split. -/
noncomputable def minSubStep (m : ℕ) (U : ℕ → ℕ → ℝ) (n k : ℕ) : ℝ :=
  if h : (range m).Nonempty then
    (range m).inf' h (fun j => stepWidth (roundRobin m U) (m * n) (m * k + j))
  else 0

lemma minSubStep_le (hj : j < m) (U : ℕ → ℕ → ℝ) (n k : ℕ) :
    minSubStep m U n k ≤ stepWidth (roundRobin m U) (m * n) (m * k + j) := by
  have hne : (range m).Nonempty := ⟨j, mem_range.mpr hj⟩
  rw [minSubStep, dif_pos hne]
  exact Finset.inf'_le _ (mem_range.mpr hj)

lemma minSubStep_pos (hm : 0 < m) (hU : ∀ j i, 0 < U j i) (hn : 0 < n) :
    0 < minSubStep m U n k := by
  have hne : (range m).Nonempty := ⟨0, mem_range.mpr hm⟩
  rw [minSubStep, dif_pos hne]
  rw [Finset.lt_inf'_iff]
  intro j _
  exact stepWidth_pos (roundRobin_pos hU) (Nat.mul_pos hm hn) _

/-- Cycle 8's resolution budget, read off the narrowest sub-step. -/
lemma minSubStep_le_pooled_div_m (hm : 0 < m) (U : ℕ → ℕ → ℝ) (n k : ℕ) :
    minSubStep m U n k ≤ stepWidth (poolFam m U) n k / m := by
  obtain ⟨j, hj, hle⟩ := exists_substep_le_pooled_div_m hm U n k
  exact (minSubStep_le hj U n k).trans hle

/-! ## 2. Information density -/

/-- The information density of an `m`-domain round-robin protocol: its context-doubling
increment times its gate resolution. -/
noncomputable def rrDensity (m : ℕ) (U : ℕ → ℕ → ℝ) (τ : ℝ) (n k : ℕ) : ℝ :=
  (ctxSens (roundRobin m U) τ (m * n) : ℝ) * minSubStep m U n k

/-- The information density of the pooled protocol it is compared against. -/
noncomputable def poolDensity (m : ℕ) (U : ℕ → ℕ → ℝ) (τ : ℝ) (n k : ℕ) : ℝ :=
  (ctxSens (poolFam m U) τ n : ℝ) * stepWidth (poolFam m U) n k

/-- **Conservation, upper half.**  Interleaving `m` domains cannot raise the information
density of a budget measurement by more than a single pooled step: the `m`-fold gain in
increment is paid for exactly by the `m`-fold loss of resolution.  No interleaving scheme
is a measurement amplifier. -/
theorem rrDensity_le_poolDensity_add_step (hm : 0 < m) (hU : ∀ j i, 0 < U j i) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    rrDensity m U τ n k ≤ poolDensity m U τ n k + stepWidth (poolFam m U) n k := by
  set S := stepWidth (poolFam m U) n k with hS
  have hSpos : 0 < S := stepWidth_pos (poolFam_pos hm hU) hn k
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hmul := (roundRobin_ctxSens_multiplier hm hU hn hτ).2
  have hcast : (ctxSens (roundRobin m U) τ (m * n) : ℝ)
      ≤ (m : ℝ) * (ctxSens (poolFam m U) τ n : ℝ) + ((m : ℝ) - 1) := by
    have h1 : ((ctxSens (roundRobin m U) τ (m * n) : ℕ) : ℝ)
        ≤ ((m * ctxSens (poolFam m U) τ n + (m - 1) : ℕ) : ℝ) := by exact_mod_cast hmul
    have h2 : ((m - 1 : ℕ) : ℝ) = (m : ℝ) - 1 := by
      have : (1 : ℕ) ≤ m := hm
      push_cast [Nat.cast_sub this]
      ring
    rw [Nat.cast_add, Nat.cast_mul, h2] at h1
    exact h1
  have hres : minSubStep m U n k ≤ S / m := minSubStep_le_pooled_div_m hm U n k
  have hd0 : (0 : ℝ) ≤ (ctxSens (roundRobin m U) τ (m * n) : ℝ) := Nat.cast_nonneg _
  have hstep : rrDensity m U τ n k
      ≤ (ctxSens (roundRobin m U) τ (m * n) : ℝ) * (S / m) :=
    mul_le_mul_of_nonneg_left hres hd0
  have hdiv0 : (0 : ℝ) ≤ S / m := le_of_lt (div_pos hSpos hm0)
  have hstep2 : (ctxSens (roundRobin m U) τ (m * n) : ℝ) * (S / m)
      ≤ ((m : ℝ) * (ctxSens (poolFam m U) τ n : ℝ) + ((m : ℝ) - 1)) * (S / m) :=
    mul_le_mul_of_nonneg_right hcast hdiv0
  have hm1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hexp : ((m : ℝ) * (ctxSens (poolFam m U) τ n : ℝ) + ((m : ℝ) - 1)) * (S / m)
      = (ctxSens (poolFam m U) τ n : ℝ) * S + (1 - 1 / m) * S := by
    field_simp
  have hfrac : (1 - 1 / (m : ℝ)) * S ≤ S := by
    have : 0 < 1 / (m : ℝ) := by positivity
    nlinarith
  rw [poolDensity]
  linarith [hstep, hstep2, hexp ▸ hstep2]

/-! ## 3. The balanced case: exact conservation -/

/-- A balanced family: `m` copies of one profile. -/
noncomputable def constFam (u : ℕ → ℝ) : ℕ → ℕ → ℝ := fun _ => u

lemma headMass_poolFam_balanced (m : ℕ) (u : ℕ → ℝ) (n : ℕ) :
    headMass (poolFam m (constFam u)) n = m * headMass u n := by
  rw [headMass_poolFam]
  simp [constFam]

lemma poolFam_balanced_apply (m : ℕ) (u : ℕ → ℝ) (k : ℕ) :
    poolFam m (constFam u) k = m * u k := by
  simp [poolFam, constFam]

/-- In a balanced mixture every sub-step is *exactly* `1/m` of the pooled step it refines:
the resolution budget of cycle 8 is attained on the nose. -/
lemma stepWidth_roundRobin_balanced (hm : 0 < m) (hj : j < m) (hu : ∀ i, 0 < u i)
    (hn : 0 < n) :
    stepWidth (roundRobin m (constFam u)) (m * n) (m * k + j)
      = stepWidth (poolFam m (constFam u)) n k / m := by
  have hH : 0 < headMass u n := headMass_pos hu hn
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  rw [stepWidth_roundRobin hm hj, stepWidth, headMass_poolFam_balanced,
    poolFam_balanced_apply]
  have hsum : ∑ i ∈ range m, headMass (constFam u i) n = m * headMass u n := by
    simp [constFam]
  rw [hsum]
  simp only [constFam]
  field_simp

/-- Hence the resolution of a balanced round robin is exactly the pooled step over `m`. -/
lemma minSubStep_balanced (hm : 0 < m) (hu : ∀ i, 0 < u i) (hn : 0 < n) (k : ℕ) :
    minSubStep m (constFam u) n k
      = stepWidth (poolFam m (constFam u)) n k / m := by
  have hne : (range m).Nonempty := ⟨0, mem_range.mpr hm⟩
  rw [minSubStep, dif_pos hne]
  refine le_antisymm ?_ ?_
  · refine (Finset.inf'_le _ (mem_range.mpr hm)).trans ?_
    exact le_of_eq (stepWidth_roundRobin_balanced hm hm hu hn)
  · refine Finset.le_inf' hne _ fun j hj => ?_
    exact ge_of_eq (stepWidth_roundRobin_balanced hm (mem_range.mp hj) hu hn)

/-- **D4, exact form.**  For a balanced `m`-domain mixture the interleaved and pooled
information densities differ by at most `(1 - 1/m)` of one pooled step: the increment is
multiplied by `m`, the resolution divided by `m`, and the residual discrepancy is precisely
the `m - 1` keys of increment slack from cycle 3, measured in resolution units. -/
theorem balanced_density_invariance (hm : 0 < m) (hu : ∀ i, 0 < u i) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    |rrDensity m (constFam u) τ n k - poolDensity m (constFam u) τ n k|
      ≤ (1 - 1 / (m : ℝ)) * stepWidth (poolFam m (constFam u)) n k := by
  set U := constFam u with hUdef
  have hU : ∀ j i, 0 < U j i := fun _ i => hu i
  set S := stepWidth (poolFam m U) n k with hS
  have hSpos : 0 < S := stepWidth_pos (poolFam_pos hm hU) hn k
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hm1 : (1 : ℕ) ≤ m := hm
  obtain ⟨hlow, hup⟩ := roundRobin_ctxSens_multiplier hm hU hn hτ
  have hcastsub : ((m - 1 : ℕ) : ℝ) = (m : ℝ) - 1 := by
    push_cast [Nat.cast_sub hm1]; ring
  have hup' : (ctxSens (roundRobin m U) τ (m * n) : ℝ)
      ≤ (m : ℝ) * (ctxSens (poolFam m U) τ n : ℝ) + ((m : ℝ) - 1) := by
    have h1 : ((ctxSens (roundRobin m U) τ (m * n) : ℕ) : ℝ)
        ≤ ((m * ctxSens (poolFam m U) τ n + (m - 1) : ℕ) : ℝ) := by exact_mod_cast hup
    rw [Nat.cast_add, Nat.cast_mul, hcastsub] at h1
    exact h1
  have hlow' : (m : ℝ) * (ctxSens (poolFam m U) τ n : ℝ)
      ≤ (ctxSens (roundRobin m U) τ (m * n) : ℝ) + ((m : ℝ) - 1) := by
    have h1 : ((m * ctxSens (poolFam m U) τ n : ℕ) : ℝ)
        ≤ ((ctxSens (roundRobin m U) τ (m * n) + (m - 1) : ℕ) : ℝ) := by exact_mod_cast hlow
    rw [Nat.cast_add, Nat.cast_mul, hcastsub] at h1
    exact h1
  have hres : minSubStep m U n k = S / m := minSubStep_balanced hm hu hn k
  rw [rrDensity, poolDensity, hres, ← hS]
  rw [abs_le]
  constructor
  · have := mul_le_mul_of_nonneg_right hlow' (le_of_lt (div_pos hSpos hm0))
    have hexp1 : (m : ℝ) * (ctxSens (poolFam m U) τ n : ℝ) * (S / m)
        = (ctxSens (poolFam m U) τ n : ℝ) * S := by field_simp
    have hexp2 : ((ctxSens (roundRobin m U) τ (m * n) : ℝ) + ((m : ℝ) - 1)) * (S / m)
        = (ctxSens (roundRobin m U) τ (m * n) : ℝ) * (S / m) + (1 - 1 / m) * S := by
      field_simp
    nlinarith [this]
  · have := mul_le_mul_of_nonneg_right hup' (le_of_lt (div_pos hSpos hm0))
    have hexp : ((m : ℝ) * (ctxSens (poolFam m U) τ n : ℝ) + ((m : ℝ) - 1)) * (S / m)
        = (ctxSens (poolFam m U) τ n : ℝ) * S + (1 - 1 / m) * S := by
      field_simp
    nlinarith [this]

/-! ## 4. Without balance the conservation is strictly one-sided -/

/-- The two-domain witness family: a loud domain and a faint one of weight `ε`. -/
noncomputable def skewFam (ε : ℝ) : ℕ → ℕ → ℝ := fun j _ => if j = 0 then 1 else ε

lemma skewFam_pos {ε : ℝ} (hε : 0 < ε) : ∀ j i, 0 < skewFam ε j i := by
  intro j i
  simp only [skewFam]
  split <;> [norm_num; exact hε]

lemma headMass_const (c : ℝ) (n : ℕ) : headMass (fun _ => c) n = n * c := by
  simp [headMass, Finset.sum_const, nsmul_eq_mul]

/-- **The refutation of exact invariance.**  Resolution is not bounded below by any fixed
fraction of the pooled step: for every constant `C` there is a two-domain mixture whose
narrowest sub-step is smaller than the pooled step divided by `C`.  Interleaving unequal
domains therefore *loses* information density without limit, so the conservation law of
`rrDensity_le_poolDensity_add_step` cannot be upgraded to an equality. -/
theorem resolution_loss_unbounded (C : ℝ) (hC : 0 < C) (n k : ℕ) (hn : 0 < n) :
    ∃ U : ℕ → ℕ → ℝ, (∀ j i, 0 < U j i) ∧
      minSubStep 2 U n k < stepWidth (poolFam 2 U) n k / C := by
  obtain ⟨ε, hε, hεC⟩ : ∃ ε : ℝ, 0 < ε ∧ ε * C < 1 + ε := by
    refine ⟨1 / (2 * C + 2), by positivity, ?_⟩
    rw [div_mul_eq_mul_div, div_lt_iff₀ (by positivity)]
    nlinarith [hC, (by positivity : (0 : ℝ) < 1 / (2 * C + 2))]
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  refine ⟨skewFam ε, skewFam_pos hε, ?_⟩
  have hsum : ∑ i ∈ range 2, headMass (skewFam ε i) n = n * 1 + n * ε := by
    have h0 : skewFam ε 0 = fun _ => (1 : ℝ) := by funext i; simp [skewFam]
    have h1 : skewFam ε 1 = fun _ => ε := by funext i; simp [skewFam]
    rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero, h0, h1,
      headMass_const, headMass_const, zero_add]
  have hfaint : stepWidth (roundRobin 2 (skewFam ε)) (2 * n) (2 * k + 1)
      = ε / (n * 1 + n * ε) := by
    rw [stepWidth_roundRobin (by norm_num) (by norm_num), hsum]
    simp [skewFam]
  have hpool : stepWidth (poolFam 2 (skewFam ε)) n k = (1 + ε) / (n * 1 + n * ε) := by
    rw [stepWidth, headMass_poolFam, hsum]
    congr 1
    simp [poolFam, skewFam, Finset.sum_range_succ]
  have hden : (0 : ℝ) < n * 1 + n * ε := by nlinarith
  have hle : minSubStep 2 (skewFam ε) n k ≤ ε / (n * 1 + n * ε) := by
    have := minSubStep_le (m := 2) (j := 1) (by norm_num) (skewFam ε) n k
    rwa [hfaint] at this
  refine lt_of_le_of_lt hle ?_
  rw [hpool, div_div, div_lt_div_iff₀ hden (by positivity)]
  nlinarith [mul_lt_mul_of_pos_right hεC hden]

/-! ## 5. The boundary, at the protocol NET-89 actually ran -/

/-- **The signal-to-resolution boundary.**  For the two-domain protocol of NET-89: a
balanced 50/50 mixture conserves information density up to half a pooled step, while a
skewed mixture can lose an arbitrary factor of resolution.  Reported increments from
mixtures at different ratios are therefore not comparable without a resolution correction —
a precondition on the proposed mixing-ratio sweep, not on the model. -/
theorem net89_signal_resolution_boundary (hu : ∀ i, 0 < u i) (hn : 0 < n) (hτ : τ ≤ 1)
    (k : ℕ) (C : ℝ) (hC : 0 < C) :
    |rrDensity 2 (constFam u) τ n k - poolDensity 2 (constFam u) τ n k|
        ≤ stepWidth (poolFam 2 (constFam u)) n k / 2 ∧
      ∃ U : ℕ → ℕ → ℝ, (∀ j i, 0 < U j i) ∧
        minSubStep 2 U n k < stepWidth (poolFam 2 U) n k / C := by
  refine ⟨?_, resolution_loss_unbounded C hC n k hn⟩
  have h := balanced_density_invariance (m := 2) (u := u) (k := k) (by norm_num) hu hn hτ
  have hcoef : (1 - 1 / ((2 : ℕ) : ℝ)) = 1 / 2 := by norm_num
  rw [hcoef] at h
  calc |rrDensity 2 (constFam u) τ n k - poolDensity 2 (constFam u) τ n k|
      ≤ 1 / 2 * stepWidth (poolFam 2 (constFam u)) n k := h
    _ = stepWidth (poolFam 2 (constFam u)) n k / 2 := by ring

end Catalog.Probability.NET89MixedDomainKnee