import Mathlib
import Catalog.Novelty.Counting
import Catalog.Novelty.Dimension
import Catalog.Shared.ProofSpacePhaseTransition

/-!
# The Dimension Spectrum of Counted Theorem Families

Companion to `Shared.RecodingCriticalGeometry`.  There the *level* observable
(density) was shown to be only quasi-invariant under recoding while the
*growth rate* is exactly invariant.  This file develops the growth rate into a
genuine spectrum for families of derivable statements.

A stratum of derivable statements is a cumulative count `N : ℕ → ℕ`; it has
*entropy dimension* `h` when `log (N n) / n → h`.  We prove:

* **Realization of the whole spectrum** (`stratumCount_hasDimension`,
  `stratumCount_le_S`, `stratumCount_density_tendsto_zero`): for every
  `h ∈ [0, log k]` there is a genuine subfamily of the `k`-letter language with
  entropy dimension exactly `h`; when `h < log k` it has ambient density zero.
  So zero density is compatible with a continuum of distinct dimensions — the
  provable/unprovable ratio really does discard internal geometry.

* **Union law** (`dimension_union`): the dimension of a union of two strata is
  the maximum of their dimensions.

* **Strict drop at independent intersections**
  (`dimension_intersection_independent`, `dimension_intersection_strict_drop`):
  if two strata meet independently in the counting sense
  (`|A ∩ B| · |Ball| = |A| · |B|`), the intersection has dimension
  `h₁ + h₂ - log k`, which is *strictly below* both `h₁` and `h₂` whenever both
  strata are proper (dimension below the ambient `log k`).
-/

namespace DimensionSpectrum

open Filter Topology

/-- A stratum `N` has entropy dimension `h` when its cumulative counts grow at
exponential rate `h`. -/
def HasEntropyDimension (N : ℕ → ℕ) (h : ℝ) : Prop :=
  Tendsto (fun n : ℕ => Real.log (N n) / n) atTop (𝓝 h)

/-! ## 1. Every dimension in `[0, log k]` is realized -/

/-- The canonical stratum of prescribed exponential rate `h`. -/
noncomputable def stratumCount (h : ℝ) (n : ℕ) : ℕ := ⌈Real.exp (h * n)⌉₊

theorem exp_le_stratumCount (h : ℝ) (n : ℕ) :
    Real.exp (h * n) ≤ (stratumCount h n : ℝ) :=
  Nat.le_ceil _

theorem one_le_stratumCount (h : ℝ) (hh : 0 ≤ h) (n : ℕ) : 1 ≤ stratumCount h n := by
  have h1 : (1 : ℝ) ≤ Real.exp (h * n) := Real.one_le_exp (by positivity)
  have h2 : (1 : ℝ) ≤ (stratumCount h n : ℝ) := le_trans h1 (exp_le_stratumCount h n)
  exact_mod_cast h2

theorem stratumCount_le_two_mul (h : ℝ) (hh : 0 ≤ h) (n : ℕ) :
    (stratumCount h n : ℝ) ≤ 2 * Real.exp (h * n) := by
  have h1 : (1 : ℝ) ≤ Real.exp (h * n) := Real.one_le_exp (by positivity)
  have h2 : (stratumCount h n : ℝ) < Real.exp (h * n) + 1 :=
    Nat.ceil_lt_add_one (le_trans zero_le_one h1)
  linarith

/-- **Realization of the spectrum.**  The canonical stratum of rate `h ≥ 0` has
entropy dimension exactly `h`. -/
theorem stratumCount_hasDimension (h : ℝ) (hh : 0 ≤ h) :
    HasEntropyDimension (stratumCount h) h := by
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le'
    (g := fun _ : ℕ => h) (h := fun n : ℕ => Real.log 2 / n + h)
    tendsto_const_nhds ?_ ?_ ?_
  · have hz : Tendsto (fun n : ℕ => Real.log 2 / n) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    simpa using hz.add (tendsto_const_nhds (x := h))
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
    have h1 : Real.exp (h * n) ≤ (stratumCount h n : ℝ) := exp_le_stratumCount h n
    have h2 : h * n ≤ Real.log (stratumCount h n) := by
      have := Real.log_le_log (Real.exp_pos _) h1
      rwa [Real.log_exp] at this
    rw [le_div_iff₀ hnpos]
    linarith
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
    have hpos : (0 : ℝ) < (stratumCount h n : ℝ) := by
      have := one_le_stratumCount h hh n
      exact_mod_cast lt_of_lt_of_le Nat.zero_lt_one this
    have h2 : Real.log (stratumCount h n) ≤ Real.log 2 + h * n := by
      have h3 := Real.log_le_log hpos (stratumCount_le_two_mul h hh n)
      rwa [Real.log_mul (by norm_num) (ne_of_gt (Real.exp_pos _)), Real.log_exp] at h3
    rw [div_le_iff₀ hnpos]
    have : Real.log 2 / n * n = Real.log 2 := by field_simp
    nlinarith [this]

/-- The canonical stratum of rate `h ≤ log k` really is a subfamily of the
ambient `k`-letter language. -/
theorem stratumCount_le_S (k : ℕ) (h : ℝ)
    (hlk : Real.exp h ≤ k) (n : ℕ) : stratumCount h n ≤ ProofSpace.S k n := by
  rw [stratumCount, Nat.ceil_le]
  have h1 : Real.exp (h * n) = Real.exp h ^ n := by
    rw [mul_comm, Real.exp_nat_mul]
  have h2 : Real.exp h ^ n ≤ (k : ℝ) ^ n :=
    pow_le_pow_left₀ (Real.exp_pos h).le hlk n
  have h3 : ((k : ℕ) : ℝ) ^ n ≤ (ProofSpace.S k n : ℝ) := by
    exact_mod_cast ProofSpace.pow_le_S k n
  rw [h1]
  linarith

/-- A stratum of dimension strictly below the ambient entropy has ambient
density zero: a continuum of distinct dimensions all sit inside the
zero-density phase. -/
theorem stratumCount_density_tendsto_zero (k : ℕ) (h : ℝ) (hh : 0 ≤ h) (hk : 2 ≤ k)
    (hlk : Real.exp h < k) :
    Tendsto (CountedProofSpace.density (stratumCount h) k) atTop (𝓝 0) := by
  refine CountedProofSpace.density_tendsto_zero (stratumCount h) k (Real.exp h) 2 hk
    (Real.exp_pos h).le hlk (by norm_num) (fun n => ?_)
  have h1 : Real.exp (h * n) = Real.exp h ^ n := by
    rw [mul_comm, Real.exp_nat_mul]
  have := stratumCount_le_two_mul h hh n
  rw [h1] at this
  linarith

/-! ## 2. Unions: the dimension is the maximum of the stratum dimensions -/

/-- **Union law for the dimension spectrum.** -/
theorem dimension_union (N₁ N₂ : ℕ → ℕ) (h₁ h₂ : ℝ)
    (hp₁ : ∀ n, 1 ≤ N₁ n) (hp₂ : ∀ n, 1 ≤ N₂ n)
    (hd₁ : HasEntropyDimension N₁ h₁) (hd₂ : HasEntropyDimension N₂ h₂) :
    HasEntropyDimension (fun n => N₁ n + N₂ n) (max h₁ h₂) := by
  have hpos₁ : ∀ n, (0 : ℝ) < (N₁ n : ℝ) := fun n => by
    exact_mod_cast lt_of_lt_of_le Nat.zero_lt_one (hp₁ n)
  have hpos₂ : ∀ n, (0 : ℝ) < (N₂ n : ℝ) := fun n => by
    exact_mod_cast lt_of_lt_of_le Nat.zero_lt_one (hp₂ n)
  set A : ℕ → ℝ := fun n => max (Real.log (N₁ n) / n) (Real.log (N₂ n) / n) with hA
  have hAlim : Tendsto A atTop (𝓝 (max h₁ h₂)) := hd₁.max hd₂
  have hBlim : Tendsto (fun n : ℕ => Real.log 2 / n + A n) atTop (𝓝 (max h₁ h₂)) := by
    simpa using (tendsto_const_div_atTop_nhds_zero_nat (Real.log 2)).add hAlim
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hAlim hBlim ?_ ?_
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
    have hsum : (0 : ℝ) < (N₁ n : ℝ) + (N₂ n : ℝ) := by linarith [hpos₁ n, hpos₂ n]
    have hcast : ((N₁ n + N₂ n : ℕ) : ℝ) = (N₁ n : ℝ) + (N₂ n : ℝ) := by push_cast; ring
    have hle₁ : Real.log (N₁ n) / n ≤ Real.log ((N₁ n + N₂ n : ℕ) : ℝ) / n := by
      rw [hcast]
      have : Real.log (N₁ n) ≤ Real.log ((N₁ n : ℝ) + N₂ n) :=
        Real.log_le_log (hpos₁ n) (by linarith [hpos₂ n])
      gcongr
    have hle₂ : Real.log (N₂ n) / n ≤ Real.log ((N₁ n + N₂ n : ℕ) : ℝ) / n := by
      rw [hcast]
      have : Real.log (N₂ n) ≤ Real.log ((N₁ n : ℝ) + N₂ n) :=
        Real.log_le_log (hpos₂ n) (by linarith [hpos₁ n])
      gcongr
    exact max_le hle₁ hle₂
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
    have hcast : ((N₁ n + N₂ n : ℕ) : ℝ) = (N₁ n : ℝ) + (N₂ n : ℝ) := by push_cast; ring
    have hmax : (N₁ n : ℝ) + (N₂ n : ℝ) ≤ 2 * max (N₁ n : ℝ) (N₂ n : ℝ) := by
      rcases le_total (N₁ n : ℝ) (N₂ n : ℝ) with hle | hle
      · rw [max_eq_right hle]; linarith
      · rw [max_eq_left hle]; linarith
    have hmaxpos : (0 : ℝ) < max (N₁ n : ℝ) (N₂ n : ℝ) :=
      lt_of_lt_of_le (hpos₁ n) (le_max_left _ _)
    have hlogmax : Real.log (max (N₁ n : ℝ) (N₂ n : ℝ))
        = max (Real.log (N₁ n)) (Real.log (N₂ n)) := by
      rcases le_total (N₁ n : ℝ) (N₂ n : ℝ) with hle | hle
      · rw [max_eq_right hle, max_eq_right (Real.log_le_log (hpos₁ n) hle)]
      · rw [max_eq_left hle, max_eq_left (Real.log_le_log (hpos₂ n) hle)]
    have hstep : Real.log ((N₁ n + N₂ n : ℕ) : ℝ)
        ≤ Real.log 2 + max (Real.log (N₁ n)) (Real.log (N₂ n)) := by
      rw [hcast, ← hlogmax]
      have h4 := Real.log_le_log (by linarith [hpos₁ n, hpos₂ n]) hmax
      rwa [Real.log_mul (by norm_num) (ne_of_gt hmaxpos)] at h4
    have hdivmax : max (Real.log (N₁ n)) (Real.log (N₂ n)) / n = A n := by
      show max (Real.log (N₁ n)) (Real.log (N₂ n)) / n
        = max (Real.log (N₁ n) / n) (Real.log (N₂ n) / n)
      rcases le_total (Real.log (N₁ n)) (Real.log (N₂ n)) with hle | hle
      · rw [max_eq_right hle,
          max_eq_right (show Real.log (N₁ n) / n ≤ Real.log (N₂ n) / n by gcongr)]
      · rw [max_eq_left hle,
          max_eq_left (show Real.log (N₂ n) / n ≤ Real.log (N₁ n) / n by gcongr)]
    calc Real.log ((N₁ n + N₂ n : ℕ) : ℝ) / n
        ≤ (Real.log 2 + max (Real.log (N₁ n)) (Real.log (N₂ n))) / n := by gcongr
      _ = Real.log 2 / n + max (Real.log (N₁ n)) (Real.log (N₂ n)) / n := by ring
      _ = Real.log 2 / n + A n := by rw [hdivmax]

/-! ## 3. Independent intersections drop the dimension strictly -/

/-- **Dimension of an independent intersection.**  Counting independence
`|A ∩ B| · |Ball| = |A| · |B|` forces the intersection dimension to be
`h₁ + h₂ - log k`. -/
theorem dimension_intersection_independent (N₁ N₂ Ncap : ℕ → ℕ) (k : ℕ) (h₁ h₂ : ℝ)
    (hk : 2 ≤ k)
    (hp₁ : ∀ n, 1 ≤ N₁ n) (hp₂ : ∀ n, 1 ≤ N₂ n) (hpc : ∀ n, 1 ≤ Ncap n)
    (hind : ∀ n, Ncap n * ProofSpace.S k n = N₁ n * N₂ n)
    (hd₁ : HasEntropyDimension N₁ h₁) (hd₂ : HasEntropyDimension N₂ h₂) :
    HasEntropyDimension Ncap (h₁ + h₂ - Real.log k) := by
  have hpos₁ : ∀ n, (0 : ℝ) < (N₁ n : ℝ) := fun n => by
    exact_mod_cast lt_of_lt_of_le Nat.zero_lt_one (hp₁ n)
  have hpos₂ : ∀ n, (0 : ℝ) < (N₂ n : ℝ) := fun n => by
    exact_mod_cast lt_of_lt_of_le Nat.zero_lt_one (hp₂ n)
  have hposc : ∀ n, (0 : ℝ) < (Ncap n : ℝ) := fun n => by
    exact_mod_cast lt_of_lt_of_le Nat.zero_lt_one (hpc n)
  have hposS : ∀ n, (0 : ℝ) < (ProofSpace.S k n : ℝ) := fun n => by
    exact_mod_cast CountedProofSpace.statementsUpTo_pos k n
  have hlogid : ∀ n, Real.log (Ncap n)
      = Real.log (N₁ n) + Real.log (N₂ n) - Real.log (ProofSpace.S k n) := by
    intro n
    have hc : (Ncap n : ℝ) * (ProofSpace.S k n : ℝ) = (N₁ n : ℝ) * (N₂ n : ℝ) := by
      exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) (hind n)
    have h1 : Real.log ((Ncap n : ℝ) * (ProofSpace.S k n : ℝ))
        = Real.log ((N₁ n : ℝ) * (N₂ n : ℝ)) := by rw [hc]
    rw [Real.log_mul (ne_of_gt (hposc n)) (ne_of_gt (hposS n)),
      Real.log_mul (ne_of_gt (hpos₁ n)) (ne_of_gt (hpos₂ n))] at h1
    linarith
  have hS := CountedProofSpace.entropyDensity_tendsto_log k hk
  have hlim : Tendsto
      (fun n : ℕ => Real.log (N₁ n) / n + Real.log (N₂ n) / n
        - Real.log (ProofSpace.S k n) / n) atTop (𝓝 (h₁ + h₂ - Real.log k)) := by
    exact (hd₁.add hd₂).sub hS
  refine hlim.congr (fun n => ?_)
  rw [hlogid n]
  ring

/-- The purely arithmetic strict-drop inequality. -/
theorem strict_drop {h₁ h₂ L : ℝ} (hl₁ : h₁ < L) (hl₂ : h₂ < L) :
    h₁ + h₂ - L < min h₁ h₂ := by
  rcases le_total h₁ h₂ with hle | hle
  · rw [min_eq_left hle]; linarith
  · rw [min_eq_right hle]; linarith

/-- **Strict dimension drop at an independent intersection.**  Two proper strata
(dimension below the ambient entropy `log k`) that meet independently intersect
in a stratum of strictly smaller dimension than either. -/
theorem dimension_intersection_strict_drop (N₁ N₂ Ncap : ℕ → ℕ) (k : ℕ) (h₁ h₂ : ℝ)
    (hk : 2 ≤ k)
    (hp₁ : ∀ n, 1 ≤ N₁ n) (hp₂ : ∀ n, 1 ≤ N₂ n) (hpc : ∀ n, 1 ≤ Ncap n)
    (hind : ∀ n, Ncap n * ProofSpace.S k n = N₁ n * N₂ n)
    (hd₁ : HasEntropyDimension N₁ h₁) (hd₂ : HasEntropyDimension N₂ h₂)
    (hlt₁ : h₁ < Real.log k) (hlt₂ : h₂ < Real.log k) :
    HasEntropyDimension Ncap (h₁ + h₂ - Real.log k) ∧
      h₁ + h₂ - Real.log k < min h₁ h₂ :=
  ⟨dimension_intersection_independent N₁ N₂ Ncap k h₁ h₂ hk hp₁ hp₂ hpc hind hd₁ hd₂,
    strict_drop hlt₁ hlt₂⟩

/-- **A nontrivial spectrum exists.**  Two canonical strata of distinct rates
`0 ≤ h₁ < h₂ ≤ log k` have distinct dimensions, both have zero ambient density
when `h₂ < log k`, and their union has the larger dimension. -/
theorem nontrivial_spectrum (k : ℕ) (h₁ h₂ : ℝ) (hk : 2 ≤ k)
    (hh₁ : 0 ≤ h₁) (hlt : h₁ < h₂) (hh₂ : Real.exp h₂ < k) :
    HasEntropyDimension (stratumCount h₁) h₁ ∧
      HasEntropyDimension (stratumCount h₂) h₂ ∧
      HasEntropyDimension (fun n => stratumCount h₁ n + stratumCount h₂ n) h₂ ∧
      Tendsto (CountedProofSpace.density (stratumCount h₁) k) atTop (𝓝 0) ∧
      Tendsto (CountedProofSpace.density (stratumCount h₂) k) atTop (𝓝 0) := by
  have hh₂0 : 0 ≤ h₂ := le_trans hh₁ hlt.le
  have hd₁ := stratumCount_hasDimension h₁ hh₁
  have hd₂ := stratumCount_hasDimension h₂ hh₂0
  have hexp₁ : Real.exp h₁ < k := lt_of_le_of_lt (Real.exp_le_exp.2 hlt.le) hh₂
  refine ⟨hd₁, hd₂, ?_, stratumCount_density_tendsto_zero k h₁ hh₁ hk hexp₁,
    stratumCount_density_tendsto_zero k h₂ hh₂0 hk hh₂⟩
  have hunion := dimension_union (stratumCount h₁) (stratumCount h₂) h₁ h₂
    (one_le_stratumCount h₁ hh₁) (one_le_stratumCount h₂ hh₂0) hd₁ hd₂
  rwa [max_eq_right hlt.le] at hunion

-- !-- Lab Notes -- !--
-- Hypothesis: (1) Every rate in [0, log k] is the entropy dimension of a genuine
-- subfamily; (2) all such subfamilies with rate below log k have ambient density
-- zero, so the provable/unprovable ratio cannot see them; (3) unions take the
-- maximum dimension; (4) counting-independent intersections drop the dimension
-- strictly.  All four survive.
-- Experiment: The canonical stratum ceil(exp(h n)) was squeezed between
-- exp(h n) and 2 exp(h n), giving log-count / n between h and h + log 2 / n.
-- The same bounds place it below the ambient count whenever exp h <= k, and the
-- sparsity bound 2 (exp h)^n feeds the catalog's density_tendsto_zero.  For
-- unions the sum was squeezed between the maximum and twice the maximum; for
-- intersections the independence identity |A cap B| * |Ball| = |A| * |B| was
-- turned into an exact additive identity between logarithms.
-- Analysis: Zero density is compatible with a continuum of distinct dimensions,
-- which is the precise sense in which a single ratio discards internal geometry.
-- The union law is a sup law because logs of sums are dominated by the maximum
-- up to log 2, a term that vanishes after dividing by n.  The intersection drop
-- h1 + h2 - log k is strictly below both dimensions exactly when both strata are
-- proper, which is the expected codimension-additivity.
-- Critique: Independence is imposed as an exact counting identity; approximate
-- independence (up to subexponential factors) would give the same dimension but
-- is not proved here.  The union law is proved for two strata; countable unions
-- need a separate argument since the sup may not be attained.
-- Synthesis: The dimension spectrum, not the density, is the informative
-- invariant of a family of theorems, and it forms a lattice: sup on unions,
-- strict drop on independent intersections.

end DimensionSpectrum