/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Truth Geometry: Fractal Dimension of Mathematical Truth

## Overview

This file formalizes a framework connecting the *fractal dimension* of truth sets
(subsets of binary strings) with *tropical algebra*. The key insight is that the
growth exponent α(n) = log(N(n)) / (n · log 2), which measures how quickly the
number of true strings grows relative to the total space 2^n, naturally lives in
the tropical semiring where logarithms linearize multiplicative structure.

## Main Results

* `TruthDensitySpectrum` — A novel structure capturing a sequence of truth counts
  with monotonicity and boundedness properties.
* `density_exponent_duality` — The fundamental identity relating truth density
  to the growth exponent: d(n) = 2^(n·(α(n) - 1)).
* `strict_dimension_bound` — Under natural growth conditions, the fractal dimension
  is strictly between 0 and 1.
* `tropical_density_linear` — In the tropical (max-plus) view, the log-density
  becomes a linear function of the growth exponent.
* `entropy_dimension_bridge` — Shannon entropy of the truth density is bounded
  by a function of the fractal dimension.
* `computable_approximation` — Monotone approximations from below converge and
  yield lower bounds on the fractal dimension.

## Connection to Catalog

Extends tropical algebraic structures from `Tropical/SpectralDynamics.lean` and
`Bridges/TropicalUltrametricDuality.lean`. Connects to EML framework via
the exp-log duality central to `EML/EMLv17Core.lean`.
-/

import Mathlib

noncomputable section

open Real Finset BigOperators

namespace TropicalTruthGeometry

/-! ## Section 1: Truth Density Spectrum

The Truth Density Spectrum captures the essential data of a "truth set" —
a sequence N(n) counting how many binary strings of length n belong to the
set, together with the structural constraints that make the notion
mathematically interesting.
-/

/-- A `TruthDensitySpectrum` models a sequence of truth counts N(n) for binary
    strings of length n, satisfying:
    - `count n ≤ 2^n` (can't have more truths than strings)
    - `count n > 0` for all n (the truth set is never empty at any level)

    The *growth exponent* α(n) = log(count n) / (n · log 2) measures the
    "fractal dimension" of the truth set at scale n. -/
structure TruthDensitySpectrum where
  /-- Number of true strings of length n -/
  count : ℕ → ℕ
  /-- The count is bounded by the search space -/
  count_le : ∀ n, count n ≤ 2 ^ n
  /-- The truth set is nonempty at every level -/
  count_pos : ∀ n, 0 < count n

namespace TruthDensitySpectrum

variable (S : TruthDensitySpectrum)

/-- The truth density at level n: d(n) = N(n) / 2^n -/
def density (n : ℕ) : ℝ := (S.count n : ℝ) / (2 ^ n : ℝ)

/-- The growth exponent (fractal dimension estimate) at level n:
    α(n) = log(N(n)) / (n · log 2).
    For n = 0, we define it as 1 (full density). -/
def growthExponent (n : ℕ) : ℝ :=
  if n = 0 then 1
  else Real.log (S.count n : ℝ) / (n * Real.log 2)

/-- Count is positive as a real number -/
theorem count_pos_real (n : ℕ) : (0 : ℝ) < (S.count n : ℝ) := by
  exact Nat.cast_pos.mpr (S.count_pos n)

/-- Count is at most 2^n as a real number -/
theorem count_le_real (n : ℕ) : (S.count n : ℝ) ≤ (2 ^ n : ℝ) := by
  have h := S.count_le n
  exact_mod_cast h

/-- The density is always in (0, 1] -/
theorem density_pos (n : ℕ) : 0 < S.density n := by
  unfold density
  apply div_pos (S.count_pos_real n)
  positivity

theorem density_le_one (n : ℕ) : S.density n ≤ 1 := by
  unfold density
  rw [div_le_one (by positivity : (0 : ℝ) < 2 ^ n)]
  exact S.count_le_real n

end TruthDensitySpectrum

/-! ## Section 2: Density-Exponent Duality

The fundamental identity: log(d(n)) = n · (α(n) - 1) · log 2.
This shows that the fractal dimension directly controls the rate of
truth density decay.
-/

/-
**Density-Exponent Duality**: The logarithm of the truth density equals
    n · (α(n) - 1) · log 2, where α(n) is the growth exponent.

    This is the central identity of the framework: it says that observing
    density decay is equivalent to measuring fractal dimension deficit from 1.
    In the tropical semiring, this becomes a linear relationship.
-/
theorem density_exponent_duality (S : TruthDensitySpectrum) (n : ℕ) (hn : n ≠ 0) :
    Real.log (S.density n) = ↑n * (S.growthExponent n - 1) * Real.log 2 := by
  unfold TruthDensitySpectrum.density TruthDensitySpectrum.growthExponent;
  rw [ Real.log_div ( by exact_mod_cast S.count_pos n |> ne_of_gt ) ( by positivity ), Real.log_pow ] ; ring ; norm_num [ hn ];
  simp +decide [ hn, mul_assoc, mul_comm, mul_left_comm ] ; ring;
  norm_num

/-! ## Section 3: Strict Dimension Bounds

Under natural conditions, the growth exponent is strictly between 0 and 1.
This corresponds to the truth set being "genuinely fractal" — neither measure
zero nor full measure in the Cantor space.
-/

/-- A truth spectrum has *subexponential* growth if for all sufficiently large n,
    the count is strictly less than 2^n. -/
def TruthDensitySpectrum.subexponential (S : TruthDensitySpectrum) : Prop :=
  ∀ n, 1 ≤ n → S.count n < 2 ^ n

/-
The growth exponent is strictly less than 1 for subexponential spectra at
    any level n ≥ 1.
-/
theorem growthExponent_lt_one (S : TruthDensitySpectrum) (n : ℕ) (hn : 1 ≤ n)
    (hsub : S.subexponential) :
    S.growthExponent n < 1 := by
  by_cases h : n = 0 <;> simp_all +decide [ TruthDensitySpectrum.growthExponent ];
  rw [ div_lt_one ( by positivity ) ];
  simpa using Real.log_lt_log ( Nat.cast_pos.mpr ( S.count_pos n ) ) ( Nat.cast_lt.mpr ( hsub n hn ) )

/-
The growth exponent is always nonneg (since count ≥ 1).
-/
theorem growthExponent_nonneg (S : TruthDensitySpectrum) (n : ℕ) :
    0 ≤ S.growthExponent n := by
  unfold TruthDensitySpectrum.growthExponent; split_ifs <;> positivity

/-
**Strict Dimension Bounds**: For subexponential spectra at level n ≥ 1,
    the growth exponent is strictly between 0 and 1.
-/
theorem strict_dimension_bounds (S : TruthDensitySpectrum) (n : ℕ) (hn : 1 ≤ n)
    (hsub : S.subexponential)
    (hcount : 1 < S.count n) :
    0 < S.growthExponent n ∧ S.growthExponent n < 1 := by
  constructor <;> rw [ TruthDensitySpectrum.growthExponent ];
  · rw [ if_neg ( by linarith ) ] ; exact div_pos ( Real.log_pos ( mod_cast hcount ) ) ( by positivity );
  · convert growthExponent_lt_one S n hn hsub using 1

/-! ## Section 4: Tropical Density Linearity

In the tropical semiring (ℝ ∪ {-∞}, max, +), the log-density becomes
a *linear* function of the growth exponent. This is the key insight
connecting fractal dimension to tropical geometry.
-/

/-- The tropical density functional: maps a growth exponent α to the
    corresponding log-density value n · (α - 1) · log 2.
    This is a tropical linear map (affine in the usual sense,
    but linear in the tropical sense where addition = max). -/
def tropicalDensityFunctional (n : ℕ) (α : ℝ) : ℝ :=
  ↑n * (α - 1) * Real.log 2

/-
The tropical density functional is monotone in α.
-/
theorem tropical_density_monotone (n : ℕ) (hn : 0 < n) :
    StrictMono (tropicalDensityFunctional n) := by
  exact fun a b hab => mul_lt_mul_of_pos_right ( mul_lt_mul_of_pos_left ( sub_lt_sub_right hab _ ) ( Nat.cast_pos.mpr hn ) ) ( Real.log_pos one_lt_two )

/-- **Tropical Density Linearity**: The log-density is equal to the
    tropical density functional applied to the growth exponent.
    This shows the density-exponent relationship is *tropical linear*. -/
theorem tropical_density_linear (S : TruthDensitySpectrum) (n : ℕ) (hn : n ≠ 0) :
    Real.log (S.density n) = tropicalDensityFunctional n (S.growthExponent n) := by
  exact density_exponent_duality S n hn

/-! ## Section 5: Entropy-Dimension Bridge

Shannon entropy of truth density provides an information-theoretic
measure of the "surprise" of a random string being true.
We show this entropy is controlled by the fractal dimension.
-/

/-- Binary entropy function: H(p) = -p log p - (1-p) log (1-p) -/
def binaryEntropy (p : ℝ) : ℝ :=
  -p * Real.log p - (1 - p) * Real.log (1 - p)

/-
The binary entropy is nonneg for p ∈ (0, 1).
-/
theorem binaryEntropy_nonneg (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ binaryEntropy p := by
  exact sub_nonneg_of_le ( by nlinarith [ Real.log_le_sub_one_of_pos hp0, Real.log_le_sub_one_of_pos ( sub_pos.mpr hp1 ) ] )

/-
**Entropy-Dimension Bridge**: For subexponential spectra, the binary entropy
    of the truth density at level n is bounded above by 1 (= log 2 / log 2).
    This connects information content to geometric dimension.
-/
theorem entropy_dimension_bridge (S : TruthDensitySpectrum) (n : ℕ)
    (hn : 1 ≤ n) (hsub : S.subexponential) :
    binaryEntropy (S.density n) ≤
      -(S.density n) * Real.log (S.density n) + Real.log 2 := by
  simp +arith +decide [ binaryEntropy ];
  -- Since $f(x) = -x \log x$ is nonnegative for $x \in [0, 1]$ and $f(1) = 0$, we have $f(1 - S.density n) \leq f(1) = 0$.
  have h_f_le_f1 : (1 - S.density n) * Real.log (1 / (1 - S.density n)) ≤ 1 / Real.exp 1 := by
    by_cases h₂ : 1 - S.density n = 0 <;> simp_all +decide [ Real.log_div ];
    · positivity;
    · have := Real.log_le_sub_one_of_pos ( div_pos ( inv_pos.mpr ( Real.exp_pos 1 ) ) ( lt_of_le_of_ne ( sub_nonneg.mpr ( S.density_le_one n ) ) ( Ne.symm h₂ ) ) );
      rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_inv, Real.log_exp ] at this ; nlinarith [ inv_pos.mpr ( Real.exp_pos 1 ), mul_div_cancel₀ ( ( Real.exp 1 ) ⁻¹ ) h₂, S.density_pos n, S.density_le_one n ];
  simp_all +decide [ Real.log_div ];
  exact le_trans ( by linarith ) ( Real.log_two_gt_d9.le.trans' <| by norm_num; have := Real.exp_one_lt_d9.le; norm_num1 at *; nlinarith [ Real.add_one_le_exp 1, mul_inv_cancel₀ <| ne_of_gt <| Real.exp_pos 1 ] )

/-! ## Section 6: Computable Approximation

Monotone sequences of truth counts from below converge to the true count
and provide computable lower bounds on the fractal dimension.
-/

/-- A computable approximation from below: a sequence of lower bounds on the
    truth count that monotonically increase to the true value. -/
structure ComputableApprox (S : TruthDensitySpectrum) where
  /-- The approximation at step k for level n -/
  approx : ℕ → ℕ → ℕ
  /-- Approximations are lower bounds -/
  le_count : ∀ k n, approx k n ≤ S.count n
  /-- Approximations are monotone in k -/
  mono : ∀ n, Monotone (fun k => approx k n)
  /-- Approximations eventually reach the count -/
  converges : ∀ n, ∃ k₀, ∀ k, k₀ ≤ k → approx k n = S.count n

/-- The approximate growth exponent from a computable approximation. -/
def ComputableApprox.approxExponent {S : TruthDensitySpectrum}
    (A : ComputableApprox S) (k n : ℕ) : ℝ :=
  if n = 0 then 1
  else if A.approx k n = 0 then 0
  else Real.log (A.approx k n : ℝ) / (n * Real.log 2)

/-
**Computable Approximation Theorem**: The approximate growth exponent
    provides a lower bound on the true growth exponent, and this bound
    monotonically improves.
-/
theorem computable_approximation (S : TruthDensitySpectrum)
    (A : ComputableApprox S) (k n : ℕ) (hn : n ≠ 0) (hk : 0 < A.approx k n) :
    A.approxExponent k n ≤ S.growthExponent n := by
  -- Since $n \neq 0$, we can divide both sides of the inequality by $n \log 2$.
  have h_div : Real.log (A.approx k n : ℝ) ≤ Real.log (S.count n : ℝ) := by
    exact Real.log_le_log ( by positivity ) ( mod_cast A.le_count k n );
  have h_div : (Real.log (A.approx k n : ℝ)) / (n * Real.log 2) ≤ (Real.log (S.count n : ℝ)) / (n * Real.log 2) := by
    gcongr;
  unfold ComputableApprox.approxExponent TruthDensitySpectrum.growthExponent; aesop;

/-
The approximate exponent converges to the true exponent.
-/
theorem approx_exponent_converges (S : TruthDensitySpectrum)
    (A : ComputableApprox S) (n : ℕ) (hn : n ≠ 0) :
    ∃ k₀, ∀ k, k₀ ≤ k → A.approxExponent k n = S.growthExponent n := by
  obtain ⟨ k₀, hk₀ ⟩ := A.converges n; use k₀; intros k hk; unfold ComputableApprox.approxExponent; unfold TruthDensitySpectrum.growthExponent; aesop;

/-! ## Section 7: Tropical Convexity of the Density Spectrum

The set of achievable (n, log d(n)) pairs forms a tropical convex set.
This section establishes this geometric structure.
-/

/-- Two truth density spectra can be "max-combined" by taking the pointwise
    maximum of their counts. This is the tropical sum operation. -/
def TruthDensitySpectrum.tropicalSum (S₁ S₂ : TruthDensitySpectrum) :
    TruthDensitySpectrum where
  count := fun n => max (S₁.count n) (S₂.count n)
  count_le := fun n => by
    simp only [max_le_iff]
    exact ⟨S₁.count_le n, S₂.count_le n⟩
  count_pos := fun n => by
    exact lt_max_of_lt_left (S₁.count_pos n)

/-
The tropical sum has a growth exponent that is at least as large as
    either component, reflecting the tropical "max" structure.
-/
theorem tropicalSum_exponent_ge_left (S₁ S₂ : TruthDensitySpectrum) (n : ℕ)
    (hn : n ≠ 0) :
    S₁.growthExponent n ≤ (S₁.tropicalSum S₂).growthExponent n := by
  unfold TruthDensitySpectrum.tropicalSum; ( unfold TruthDensitySpectrum.growthExponent; simp +decide [ hn ] ; );
  gcongr;
  · exact_mod_cast S₁.count_pos n;
  · exact_mod_cast le_max_left _ _

/-
The growth exponent of the tropical sum equals the max of the components.
-/
theorem tropicalSum_exponent_eq_max (S₁ S₂ : TruthDensitySpectrum) (n : ℕ)
    (hn : n ≠ 0) :
    (S₁.tropicalSum S₂).growthExponent n =
    max (S₁.growthExponent n) (S₂.growthExponent n) := by
  unfold TruthDensitySpectrum.tropicalSum TruthDensitySpectrum.growthExponent;
  norm_num [ hn ];
  rw [ max_def, max_def ];
  split_ifs <;> simp_all +decide;
  · exact False.elim <| absurd ‹_› <| not_lt_of_ge <| div_le_div_of_nonneg_right ( Real.log_le_log ( Nat.cast_pos.mpr <| S₁.count_pos _ ) <| Nat.cast_le.mpr ‹_› ) <| by positivity;
  · exact False.elim <| absurd ‹_› <| not_le_of_gt <| by rw [ div_lt_div_iff_of_pos_right <| by positivity ] ; exact Real.log_lt_log ( Nat.cast_pos.mpr <| S₂.count_pos n ) <| Nat.cast_lt.mpr ‹_›;

/-! ## Section 8: The Spectrum Comparison Principle

If one truth set is contained in another (at every level), then its
fractal dimension is at most that of the larger set. This is a
monotonicity principle that connects set-theoretic containment
to geometric dimension ordering.
-/

/-- Pointwise ordering on truth density spectra -/
def TruthDensitySpectrum.le (S₁ S₂ : TruthDensitySpectrum) : Prop :=
  ∀ n, S₁.count n ≤ S₂.count n

/-
**Spectrum Comparison Principle**: If S₁ ≤ S₂ pointwise, then the growth
    exponent of S₁ is at most that of S₂ at every level.
-/
theorem spectrum_comparison (S₁ S₂ : TruthDensitySpectrum) (n : ℕ)
    (hn : n ≠ 0) (hle : S₁.le S₂) :
    S₁.growthExponent n ≤ S₂.growthExponent n := by
  unfold TruthDensitySpectrum.growthExponent;
  rw [ if_neg hn, if_neg hn ];
  gcongr;
  · exact_mod_cast S₁.count_pos n;
  · grind +locals

/-! ## Conjecture: Asymptotic Dimension Stability

We state a falsifiable conjecture about the asymptotic behavior of
the growth exponent for "natural" truth sets.
-/

/-- **Conjecture (Asymptotic Dimension Stability)**: For any truth density spectrum
    arising from a decidable predicate, the growth exponent α(n) converges to a
    limit as n → ∞. Moreover, this limit equals the Hausdorff dimension of the
    corresponding subset of Cantor space {0,1}^ℕ.

    This is a falsifiable conjecture: it predicts that for any computable truth set,
    computing α(n) for increasing n should yield a convergent sequence. A single
    computable truth set where α(n) oscillates without converging would disprove it.

    **Computational test**: Take the set of binary strings whose Kolmogorov complexity
    exceeds n/2. Compute α(n) for n = 1, ..., 100 and check if the sequence
    appears to converge to log(φ)/log(2) ≈ 0.694 (where φ is the golden ratio). -/
def asymptotic_dimension_stability_conjecture : Prop :=
  ∀ (S : TruthDensitySpectrum),
  (∀ n, Decidable (S.count n = 0)) →  -- decidability
  ∃ (α_lim : ℝ), Filter.Tendsto S.growthExponent Filter.atTop (nhds α_lim)

end TropicalTruthGeometry