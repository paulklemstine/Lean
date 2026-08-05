import Mathlib
import Combinatorics.RamseyExponentialBounds

/-!
# The root test characterizes sub-four upper bounds

This file settles conjecture **FD2** of the research thread on exponential bounds
for diagonal Ramsey numbers, and simultaneously exhibits the precise sense in
which the naive reading of that conjecture is *false*.

The catalog predicate `RamseyBounds.HasSubFourUpperBound r` asks for a fixed
`ε ∈ (0,4)` with `r k ≤ (4-ε)^k` eventually.  FD2 proposes to replace it by the
single analytic invariant `limsup (r k)^{1/k} < 4`.

* `RamseyBounds.hasSubFourUpperBound_iff_rootLimsup_lt_four` proves the
  conjecture when the `limsup` is taken in `ℝ≥0∞` (a complete lattice, so the
  `limsup` is the honest asymptotic supremum of the root sequence).
* `RamseyBounds.real_rootLimsup_test_fails` shows the conjecture is **false**
  if the `limsup` is taken in `ℝ`: for `r k = k^k` the real-valued `limsup`
  degenerates to `sInf ∅ = 0 < 4` while `r` has no sub-four bound at all.

So the correct analytic invariant is the extended-nonnegative-real root limsup;
the real-valued one silently discards unbounded root sequences.
-/

namespace RamseyBounds

open Filter ENNReal

/-- The root-test invariant of a sequence, computed in `ℝ≥0∞` so that the
`limsup` is a genuine asymptotic supremum even for unbounded sequences. -/
noncomputable def rootLimsup (r : ℕ → ℕ) : ℝ≥0∞ :=
  limsup (fun k => (r k : ℝ≥0∞) ^ ((k : ℝ)⁻¹)) atTop

/-- The real-valued root-test invariant.  Because `ℝ` is only conditionally
complete, this is a `sInf` over a possibly empty set and therefore *not* an
asymptotic supremum in general. -/
noncomputable def realRootLimsup (r : ℕ → ℕ) : ℝ :=
  limsup (fun k => (r k : ℝ) ^ ((k : ℝ)⁻¹)) atTop

/-! ### The correct form of the root test -/

/-- A sub-four upper bound forces the root limsup to stay below four. -/
theorem rootLimsup_lt_four_of_hasSubFourUpperBound {r : ℕ → ℕ}
    (h : HasSubFourUpperBound r) : rootLimsup r < 4 := by
  obtain ⟨ε, hε, hε4, k₀, hk₀⟩ := h
  set c : ℝ≥0∞ := ENNReal.ofReal (4 - ε) with hc
  have hclt : c < 4 := by
    rw [hc, show (4 : ℝ≥0∞) = ENNReal.ofReal 4 by simp]
    exact (ENNReal.ofReal_lt_ofReal_iff (by norm_num)).mpr (by linarith)
  refine lt_of_le_of_lt (Filter.limsup_le_of_le isCobounded_le_of_bot ?_) hclt
  filter_upwards [eventually_ge_atTop (max k₀ 1)] with k hk
  have hk0 : k₀ ≤ k := le_trans (le_max_left _ _) hk
  have hk1 : 1 ≤ k := le_trans (le_max_right _ _) hk
  have hrk : (r k : ℝ≥0∞) ≤ c ^ k := by
    rw [hc, ← ENNReal.ofReal_pow (by linarith),
      show ((r k : ℕ) : ℝ≥0∞) = ENNReal.ofReal (r k : ℝ) by simp]
    exact ENNReal.ofReal_le_ofReal (hk₀ k hk0)
  calc (r k : ℝ≥0∞) ^ ((k : ℝ)⁻¹) ≤ (c ^ k) ^ ((k : ℝ)⁻¹) :=
        ENNReal.rpow_le_rpow hrk (by positivity)
    _ = c := by
        rw [← ENNReal.rpow_natCast c k, ← ENNReal.rpow_mul,
          mul_inv_cancel₀ (by exact_mod_cast Nat.one_le_iff_ne_zero.mp hk1)]
        simp

/-- A root limsup below four produces an explicit sub-four upper bound. -/
theorem hasSubFourUpperBound_of_rootLimsup_lt_four {r : ℕ → ℕ}
    (h : rootLimsup r < 4) : HasSubFourUpperBound r := by
  have hmax : max (rootLimsup r) 1 < 4 := max_lt h (by norm_num)
  obtain ⟨c, hc1, hc2⟩ := exists_between hmax
  have hcgt1 : (1 : ℝ≥0∞) < c := lt_of_le_of_lt le_sup_right hc1
  have hcne : c ≠ ⊤ := (lt_of_lt_of_le hc2 le_top).ne
  have hlim : rootLimsup r < c := lt_of_le_of_lt le_sup_left hc1
  obtain ⟨k₀, hk₀⟩ := eventually_atTop.mp
    (Filter.eventually_lt_of_limsup_lt hlim)
  set C : ℝ := c.toReal with hC
  have hC1 : 1 < C := by
    rw [hC, show (1 : ℝ) = (1 : ℝ≥0∞).toReal by simp]
    exact (ENNReal.toReal_lt_toReal (by simp) hcne).mpr hcgt1
  have hC4 : C < 4 := by
    rw [hC, show (4 : ℝ) = (4 : ℝ≥0∞).toReal by simp]
    exact (ENNReal.toReal_lt_toReal hcne (by simp)).mpr hc2
  refine ⟨4 - C, by linarith, by linarith, max k₀ 1, ?_⟩
  intro k hk
  have hk0 : k₀ ≤ k := le_trans (le_max_left _ _) hk
  have hk1 : 1 ≤ k := le_trans (le_max_right _ _) hk
  have hkne : (k : ℝ) ≠ 0 := by exact_mod_cast Nat.one_le_iff_ne_zero.mp hk1
  have hle : (r k : ℝ≥0∞) ≤ c ^ k := by
    have h2 : ((r k : ℝ≥0∞) ^ ((k : ℝ)⁻¹)) ^ (k : ℝ) ≤ c ^ (k : ℝ) :=
      ENNReal.rpow_le_rpow (hk₀ k hk0).le (by positivity)
    rwa [← ENNReal.rpow_mul, inv_mul_cancel₀ hkne, ENNReal.rpow_one,
      ENNReal.rpow_natCast] at h2
  have htoReal := ENNReal.toReal_mono (ENNReal.pow_ne_top hcne) hle
  rw [ENNReal.toReal_pow] at htoReal
  simpa [hC, show (4 : ℝ) - (4 - C) = C by ring] using htoReal

/-- **FD2.**  The catalog predicate `HasSubFourUpperBound` is exactly the root
test `limsup (r k)^{1/k} < 4`, the `limsup` being taken in `ℝ≥0∞`. -/
theorem hasSubFourUpperBound_iff_rootLimsup_lt_four (r : ℕ → ℕ) :
    HasSubFourUpperBound r ↔ rootLimsup r < 4 :=
  ⟨rootLimsup_lt_four_of_hasSubFourUpperBound,
    hasSubFourUpperBound_of_rootLimsup_lt_four⟩

/-- Combined with the catalog equivalence, the proportional-saving predicate is
also characterized by the root test. -/
theorem hasProportionalSaving_iff_rootLimsup_lt_four (r : ℕ → ℕ) :
    HasProportionalSaving r ↔ rootLimsup r < 4 :=
  (subFour_iff_proportionalSaving r).symm.trans
    (hasSubFourUpperBound_iff_rootLimsup_lt_four r)

/-! ### The real-valued root test is *not* a valid characterization -/

/-- For `r k = k^k` the root sequence is `k`, which is unbounded, so the set of
eventual upper bounds is empty and the `ℝ`-valued `limsup` collapses to `0`. -/
theorem realRootLimsup_pow_self : realRootLimsup (fun k => k ^ k) = 0 := by
  rw [realRootLimsup, Filter.limsup_eq]
  convert Real.sInf_empty
  rw [Set.eq_empty_iff_forall_notMem]
  intro a ha
  simp only [Set.mem_setOf_eq, eventually_atTop] at ha
  obtain ⟨N, hN⟩ := ha
  obtain ⟨M, hM⟩ := exists_nat_gt (max a 0)
  have hk := hN (max N (max M 1)) (le_max_left _ _)
  have h1 : 1 ≤ max N (max M 1) := le_trans (le_max_right _ _) (le_max_right _ _)
  set k := max N (max M 1) with hkdef
  have heq : (((k ^ k : ℕ) : ℝ)) ^ ((k : ℝ)⁻¹) = (k : ℝ) := by
    push_cast
    rw [← Real.rpow_natCast (k : ℝ) k, ← Real.rpow_mul (by positivity),
      mul_inv_cancel₀ (by exact_mod_cast Nat.one_le_iff_ne_zero.mp h1),
      Real.rpow_one]
  rw [heq] at hk
  have hMk : (M : ℝ) ≤ (k : ℝ) := by
    have : M ≤ k := le_trans (le_max_left _ _) (le_max_right _ _)
    exact_mod_cast this
  have hax : a < (M : ℝ) := lt_of_le_of_lt (le_max_left _ _) hM
  linarith

/-- The sequence `k ↦ k^k` has no sub-four upper bound. -/
theorem not_hasSubFourUpperBound_pow_self :
    ¬ HasSubFourUpperBound (fun k => k ^ k) := by
  rintro ⟨ε, hε, hε4, k₀, hk₀⟩
  set k := max k₀ 4 with hkdef
  have hk4 : 4 ≤ k := le_max_right _ _
  have h := hk₀ k (le_max_left _ _)
  have h1 : ((4 : ℝ) - ε) ^ k < 4 ^ k :=
    pow_lt_pow_left₀ (by linarith) (by linarith) (by omega)
  have h2 : (4 : ℝ) ^ k ≤ ((k : ℝ)) ^ k := by
    refine pow_le_pow_left₀ (by norm_num) ?_ k
    exact_mod_cast hk4
  simp only [Nat.cast_pow] at h
  linarith

/-- **Falsification of the naive FD2.**  With the `limsup` taken in `ℝ`, the
root test does *not* characterize sub-four upper bounds: `r k = k^k` has real
root limsup `0 < 4` yet admits no sub-four bound.  The failure is caused by the
conditional completeness of `ℝ`, which turns an unbounded root sequence into
the junk value `sInf ∅ = 0`; this is exactly what the `ℝ≥0∞` formulation
above repairs. -/
theorem real_rootLimsup_test_fails :
    ∃ r : ℕ → ℕ, realRootLimsup r < 4 ∧ ¬ HasSubFourUpperBound r :=
  ⟨fun k => k ^ k, by rw [realRootLimsup_pow_self]; norm_num,
    not_hasSubFourUpperBound_pow_self⟩

end RamseyBounds