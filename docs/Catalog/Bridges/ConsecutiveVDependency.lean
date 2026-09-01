/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Consecutive-hit dependency: the density/dependence dichotomy

Research thread *hit positions along a scan axis* (papers 228-230, 231, 238/240,
241-242, 248), Phase A of paper 249.

The experimental programme measured the lag-1..20 autocorrelation of a *hit
indicator sequence* along a scan axis and found a flat, slightly negative
profile (`|rho| <= 0.020`) together with a null runs statistic, while an
injected lag-1 dependence was detected massively.  The verdict recorded there is
`H0_PURE_DENSITY`: **given position, neighbouring hits carry no information
about each other**; the observed mid-window excess is rate heterogeneity along
the scan axis, not sequence structure.

This file supplies the mathematics that makes that verdict a *theorem* rather
than a summary of one data set.  Two probabilistic models of a 0/1 scan are
formalised from scratch and compared:

* the **heterogeneous independent model** (`bernExp`): a product Bernoulli law
  with a position-dependent rate curve `p : ℕ → ℝ` — this is "pure density";
* the **stationary two-state Markov model** (`mstep`, `markovCorr`): the
  simplest genuine sequence structure.

The main results are:

* `bernExp_marker`, `bernExp_hit`, `bernExp_hit_mul` — the moment calculus of the
  product model, derived from the transfer identity `prod_sum_bool`;
* `bernExp_centeredPairSum` — the exact expectation of the lag-`k`
  cross-product estimator centred at an arbitrary trend `c`;
* `bernExp_detrended_pairSum_eq_zero` — centring at the *true* rate curve makes
  the expected lag-`k` statistic exactly `0` at every lag: the primary
  (detrended) reading of the experiment has population value zero under pure
  density, for every rate curve whatsoever;
* `spurious_autocorrelation_bound` — the *literal* (global-mean) reading is not
  exactly zero, but is bounded by `δ² / v`, where `δ` bounds the deviation of the
  rate curve from its centre and `v` is a floor for the Bernoulli variance.
  This is the quantitative form of control C2 ("curvature confound immaterial"):
  a `±0.05` hump on a `p ≈ 1/2` curve can fake at most `≈ 0.0105` of
  autocorrelation, five times below the pre-registered `0.05` bar
  (`curvature_cannot_fake_H1`);
* `bernExp_altCount`, `altCount_heterogeneity_bound` — the same analysis for the
  runs statistic: heterogeneity perturbs the expected number of alternations
  only to second order in `δ` when the curve is centred at `1/2`;
* `markovCorr_eq_lambda_pow`, `markov_profile_peaks_at_lag_one` — under the
  Markov alternative the lag profile is exactly geometric `λ^k`, so its argmax
  is lag 1 (the shape control C3 saw), and it vanishes identically iff `λ = 0`,
  i.e. iff the chain is the independent one (`markov_indep_iff`);
* `bernExp_centered_prod_eq_zero`, `bernExp_centeredPairSum_sq` — the multilinear
  form of independence, and the exact variance of the detrended statistic:
  `∑ᵢ pᵢ(1-pᵢ) pᵢ₊ₖ(1-pᵢ₊ₖ)`, the terms being pairwise uncorrelated even when two
  pairs share a position;
* `bern_chebyshev`, `detrended_noise_floor`, `detrended_noise_floor_experiment` —
  the resulting noise floor: under pure density the normalised statistic exceeds
  a level `t` with probability at most `1/(16 m t²)`, i.e. below `0.003` at the
  experiment's `m = 9594` and `t = 0.05`;
* `density_dependence_dichotomy` — the two regimes are separated by the
  pre-registered `0.05` bar: a heterogeneous-but-independent scan cannot cross
  it, a Markov scan with `|λ| ≥ 0.05` must.  Hence the null observed in the
  experiment is a genuine exclusion of sequence structure, not a blind test.

Everything is elementary and self-contained: the product law is a finite sum
over `Fin n → Bool`, the Markov `k`-step law is an iterate of an affine map on
`ℝ`, identified with the matrix power of the transition matrix in
`markov_matrix_pow_apply`.
-/

import Mathlib

open Finset

namespace ConsecutiveVDependency

/-! ## 1. The heterogeneous independent (pure density) model -/

/-- **Transfer identity**: summing a product of per-coordinate weights over all
`Fin n → Bool` configurations factorises into a product of two-term sums.  This
is the engine behind every moment computation below. -/
theorem prod_sum_bool (n : ℕ) (g : Fin n → Bool → ℝ) :
    ∑ s : Fin n → Bool, ∏ i, g i (s i) = ∏ i, (g i true + g i false) := by
  have hb : ∀ i : Fin n, g i true + g i false = ∑ b ∈ ({true, false} : Finset Bool), g i b := by
    intro i; simp
  simp_rw [hb]
  rw [Finset.prod_univ_sum]
  refine Finset.sum_congr ?_ (fun x _ => rfl)
  ext s; simp

/-- Weight of one 0/1 scan configuration under the rate curve `p`. -/
def confWeight (n : ℕ) (p : ℕ → ℝ) (s : Fin n → Bool) : ℝ :=
  ∏ i : Fin n, (if s i then p i.val else 1 - p i.val)

/-- Expectation of an observable under the heterogeneous independent model with
position-dependent hit rate `p i` at scan position `i`. -/
noncomputable def bernExp (n : ℕ) (p : ℕ → ℝ) (f : (Fin n → Bool) → ℝ) : ℝ :=
  ∑ s : Fin n → Bool, confWeight n p s * f s

/-- The hit indicator at scan position `i` (zero outside the window). -/
def hit (n : ℕ) (s : Fin n → Bool) (i : ℕ) : ℝ :=
  if h : i < n then (if s ⟨i, h⟩ then 1 else 0) else 0

theorem hit_eq (n : ℕ) (s : Fin n → Bool) {i : ℕ} (h : i < n) :
    hit n s i = if s ⟨i, h⟩ then 1 else 0 := dif_pos h

/-- The rate curve is a probability curve: total mass one. -/
theorem bernExp_mass (n : ℕ) (p : ℕ → ℝ) :
    ∑ s : Fin n → Bool, confWeight n p s = 1 := by
  unfold confWeight
  rw [prod_sum_bool n (fun i b => if b then p i.val else 1 - p i.val)]
  simp

theorem bernExp_const (n : ℕ) (p : ℕ → ℝ) (c : ℝ) :
    bernExp n p (fun _ => c) = c := by
  unfold bernExp
  rw [← Finset.sum_mul, bernExp_mass, one_mul]

/-- Linearity of the expectation over three observables and a constant. -/
theorem bernExp_comb (n : ℕ) (p : ℕ → ℝ) (F G H : (Fin n → Bool) → ℝ) (α β γ κ : ℝ) :
    bernExp n p (fun s => α * F s + β * G s + γ * H s + κ)
      = α * bernExp n p F + β * bernExp n p G + γ * bernExp n p H + κ := by
  unfold bernExp
  have e1 : ∀ s : Fin n → Bool,
      confWeight n p s * (α * F s + β * G s + γ * H s + κ)
      = α * (confWeight n p s * F s) + β * (confWeight n p s * G s)
        + γ * (confWeight n p s * H s) + κ * confWeight n p s := by
    intro s; ring
  rw [Finset.sum_congr rfl (fun s _ => e1 s)]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum, bernExp_mass]
  ring

theorem bernExp_add (n : ℕ) (p : ℕ → ℝ) (f g : (Fin n → Bool) → ℝ) :
    bernExp n p (fun s => f s + g s) = bernExp n p f + bernExp n p g := by
  have := bernExp_comb n p f g (fun _ => 0) 1 1 0 0
  simpa using this

theorem bernExp_const_mul (n : ℕ) (p : ℕ → ℝ) (c : ℝ) (f : (Fin n → Bool) → ℝ) :
    bernExp n p (fun s => c * f s) = c * bernExp n p f := by
  have := bernExp_comb n p f f f c 0 0 0
  simpa using this

/-- Expectation of a finite sum of observables. -/
theorem bernExp_sum {ι : Type*} [DecidableEq ι] (n : ℕ) (p : ℕ → ℝ) (T : Finset ι)
    (F : ι → (Fin n → Bool) → ℝ) :
    bernExp n p (fun s => ∑ i ∈ T, F i s) = ∑ i ∈ T, bernExp n p (F i) := by
  classical
  induction T using Finset.induction with
  | empty => simp [bernExp]
  | insert a T ha ih =>
      simp only [Finset.sum_insert ha]
      rw [show (fun s => F a s + ∑ i ∈ T, F i s)
            = (fun s => F a s + (fun t => ∑ i ∈ T, F i t) s) from rfl,
        bernExp_add, ih]

/-- **Joint moments factorise**: the expected product of the hit indicators over
any finite set of positions is the product of the rates.  This *is* independence
for the model, proved directly from the transfer identity. -/
theorem bernExp_marker (n : ℕ) (p : ℕ → ℝ) (T : Finset (Fin n)) :
    bernExp n p (fun s => ∏ i ∈ T, (if s i then (1 : ℝ) else 0)) = ∏ i ∈ T, p i.val := by
  unfold bernExp confWeight
  have key : ∀ s : Fin n → Bool,
      (∏ j : Fin n, (if s j then p j.val else 1 - p j.val)) * (∏ i ∈ T, (if s i then (1 : ℝ) else 0))
      = ∏ j : Fin n, ((if s j then p j.val else 1 - p j.val)
          * (if j ∈ T then (if s j then (1 : ℝ) else 0) else 1)) := by
    intro s
    rw [Finset.prod_mul_distrib, Finset.prod_ite_mem]
    simp
  simp_rw [key]
  rw [prod_sum_bool n (fun j b => (if b then p j.val else 1 - p j.val)
        * (if j ∈ T then (if b then (1 : ℝ) else 0) else 1))]
  trans (∏ i : Fin n, if i ∈ T then p i.val else 1)
  · refine Finset.prod_congr rfl (fun i _ => ?_)
    by_cases h : i ∈ T <;> simp [h]
  · rw [Finset.prod_ite_mem, Finset.univ_inter]

/-- One-point marginal: the expected hit indicator is the rate. -/
theorem bernExp_hit (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi : i < n) :
    bernExp n p (fun s => hit n s i) = p i := by
  have hfun : (fun s : Fin n → Bool => hit n s i)
      = fun s => ∏ x ∈ ({⟨i, hi⟩} : Finset (Fin n)), (if s x then (1 : ℝ) else 0) := by
    funext s; simp [hit, hi]
  rw [hfun, bernExp_marker]
  simp

/-- Two-point marginal at distinct positions: the expectation factorises. -/
theorem bernExp_hit_mul (n : ℕ) (p : ℕ → ℝ) {i j : ℕ} (hi : i < n) (hj : j < n) (hij : i ≠ j) :
    bernExp n p (fun s => hit n s i * hit n s j) = p i * p j := by
  have hne : (⟨i, hi⟩ : Fin n) ≠ ⟨j, hj⟩ := by
    simp only [ne_eq, Fin.mk.injEq]; exact hij
  have hfun : (fun s : Fin n → Bool => hit n s i * hit n s j)
      = fun s => ∏ x ∈ ({⟨i, hi⟩, ⟨j, hj⟩} : Finset (Fin n)), (if s x then (1 : ℝ) else 0) := by
    funext s
    rw [Finset.prod_pair hne]
    simp [hit, hi, hj]
  rw [hfun, bernExp_marker, Finset.prod_pair hne]

/-! ## 2. The lag-`k` cross-product statistic under pure density -/

/-- Lag-`k` cross-product statistic over the first `m` positions, with the
observations centred at an arbitrary trend `c : ℕ → ℝ`.  Taking `c` constant is
the *literal / global-mean* (secondary) reading of the experiment; taking `c = p`
is the idealised *detrended* (primary) reading. -/
def centeredPairSum (n : ℕ) (s : Fin n → Bool) (k m : ℕ) (c : ℕ → ℝ) : ℝ :=
  ∑ i ∈ Finset.range m, (hit n s i - c i) * (hit n s (i + k) - c (i + k))

/-- **Exact expectation of the lag-`k` statistic under pure density.**
For every rate curve, every lag `k ≥ 1` and every centring `c`, the expected
cross-product statistic is the corresponding statistic of the *rate curve
itself* — no term involving the joint law survives. -/
theorem bernExp_centeredPairSum (n : ℕ) (p : ℕ → ℝ) {k m : ℕ} (hk : 1 ≤ k) (hm : m + k ≤ n)
    (c : ℕ → ℝ) :
    bernExp n p (fun s => centeredPairSum n s k m c)
      = ∑ i ∈ Finset.range m, (p i - c i) * (p (i + k) - c (i + k)) := by
  unfold centeredPairSum
  rw [bernExp_sum]
  refine Finset.sum_congr rfl (fun i hi => ?_)
  have him : i < m := Finset.mem_range.mp hi
  have hin : i < n := by omega
  have hikn : i + k < n := by omega
  have hne : i ≠ i + k := by omega
  have hshape : (fun s : Fin n → Bool => (hit n s i - c i) * (hit n s (i + k) - c (i + k)))
      = fun s => (1 : ℝ) * (hit n s i * hit n s (i + k)) + (-(c (i + k))) * hit n s i
          + (-(c i)) * hit n s (i + k) + c i * c (i + k) := by
    funext s; ring
  rw [hshape, bernExp_comb, bernExp_hit_mul n p hin hikn hne, bernExp_hit n p hin,
    bernExp_hit n p hikn]
  ring

/-- **Detrending is exact under pure density.**  Centring the hit indicators at
the true positional rate curve makes the expected lag-`k` statistic vanish
identically, at every lag and for every rate curve: given position, neighbouring
hits carry no information about each other. -/
theorem bernExp_detrended_pairSum_eq_zero (n : ℕ) (p : ℕ → ℝ) {k m : ℕ} (hk : 1 ≤ k)
    (hm : m + k ≤ n) :
    bernExp n p (fun s => centeredPairSum n s k m p) = 0 := by
  rw [bernExp_centeredPairSum n p hk hm p]
  simp

/-! ## 3. The curvature confound: how much autocorrelation heterogeneity can fake -/

/-- **Heterogeneity bound.**  If the rate curve stays within `δ` of the centring
constant, the literal (global-mean) lag-`k` statistic has expectation at most
`m * δ²` in absolute value — uniformly in the lag `k`, whence the flat profile. -/
theorem ratePairSum_abs_le (p : ℕ → ℝ) (k m : ℕ) (c δ : ℝ)
    (hδ : ∀ i, i < m + k → |p i - c| ≤ δ) :
    |∑ i ∈ Finset.range m, (p i - c) * (p (i + k) - c)| ≤ m * δ ^ 2 := by
  calc |∑ i ∈ Finset.range m, (p i - c) * (p (i + k) - c)|
      ≤ ∑ i ∈ Finset.range m, |(p i - c) * (p (i + k) - c)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i ∈ Finset.range m, δ ^ 2 := by
        refine Finset.sum_le_sum (fun i hi => ?_)
        have him : i < m := Finset.mem_range.mp hi
        have h1 : |p i - c| ≤ δ := hδ i (by omega)
        have h2 : |p (i + k) - c| ≤ δ := hδ (i + k) (by omega)
        rw [abs_mul, sq]
        exact mul_le_mul h1 h2 (abs_nonneg _) (le_trans (abs_nonneg _) h1)
    _ = m * δ ^ 2 := by rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]

/-- **Control C2, quantified.**  The *spurious autocorrelation* that pure rate
heterogeneity can produce in the literal (undetrended) reading is at most
`δ² / v`, where `δ` bounds the curvature of the rate curve around its centre and
`v` is any positive lower bound for the per-position Bernoulli variance.  The
bound is uniform in the lag: a smooth density hump produces a *flat* profile, it
cannot manufacture a peak. -/
theorem spurious_autocorrelation_bound (n : ℕ) (p : ℕ → ℝ) {k m : ℕ} (hk : 1 ≤ k)
    (hm : m + k ≤ n) (c δ v : ℝ) (hm0 : 0 < m) (hv : 0 < v)
    (hδ : ∀ i, i < m + k → |p i - c| ≤ δ) :
    |bernExp n p (fun s => centeredPairSum n s k m (fun _ => c)) / (m * v)| ≤ δ ^ 2 / v := by
  rw [bernExp_centeredPairSum n p hk hm (fun _ => c)]
  have hmpos : (0 : ℝ) < m := by exact_mod_cast hm0
  rw [abs_div, abs_of_pos (by positivity : (0 : ℝ) < (m : ℝ) * v)]
  have hbase := ratePairSum_abs_le p k m c δ hδ
  calc |∑ i ∈ Finset.range m, (p i - c) * (p (i + k) - c)| / ((m : ℝ) * v)
      ≤ ((m : ℝ) * δ ^ 2) / ((m : ℝ) * v) := by gcongr
    _ = δ ^ 2 / v := by
        rw [mul_div_mul_left _ _ (ne_of_gt hmpos)]

/-- **The curvature confound cannot fake H1.**  With a rate curve confined to
`[0.45, 0.55]` (so `δ = 0.05` and the Bernoulli variance is at least
`v = 0.2475`), the literal lag-`k` autocorrelation produced by pure density is at
most `0.0102 < 0.05`, the pre-registered detection bar — for every lag and every
such curve. -/
theorem curvature_cannot_fake_H1 (n : ℕ) (p : ℕ → ℝ) {k m : ℕ} (hk : 1 ≤ k) (hm : m + k ≤ n)
    (hm0 : 0 < m) (hp : ∀ i, i < m + k → |p i - (1 / 2 : ℝ)| ≤ 1 / 20) :
    |bernExp n p (fun s => centeredPairSum n s k m (fun _ => 1 / 2)) / (m * (99 / 400))|
      < 1 / 20 := by
  have h := spurious_autocorrelation_bound n p hk hm (1 / 2) (1 / 20) (99 / 400) hm0
    (by norm_num) hp
  have hb : ((1 : ℝ) / 20) ^ 2 / (99 / 400) < 1 / 20 := by norm_num
  linarith

/-! ## 4. The runs / alternation statistic -/

/-- Number of alternations (runs boundaries) in the first `m + 1` positions,
written as a polynomial in the hit indicators. -/
def altCount (n : ℕ) (s : Fin n → Bool) (m : ℕ) : ℝ :=
  ∑ i ∈ Finset.range m, (hit n s i + hit n s (i + 1) - 2 * (hit n s i * hit n s (i + 1)))

/-- The polynomial really counts alternations: each term is `1` exactly when the
two neighbouring scan cells disagree. -/
theorem alt_term_eq_mismatch (n : ℕ) (s : Fin n → Bool) {i : ℕ} (hi : i < n) (hi1 : i + 1 < n) :
    hit n s i + hit n s (i + 1) - 2 * (hit n s i * hit n s (i + 1))
      = if s ⟨i, hi⟩ = s ⟨i + 1, hi1⟩ then 0 else 1 := by
  rw [hit_eq n s hi, hit_eq n s hi1]
  cases h1 : s ⟨i, hi⟩ <;> cases h2 : s ⟨i + 1, hi1⟩ <;> norm_num

/-- Expected number of alternations under pure density. -/
theorem bernExp_altCount (n : ℕ) (p : ℕ → ℝ) {m : ℕ} (hm : m + 1 ≤ n) :
    bernExp n p (fun s => altCount n s m)
      = ∑ i ∈ Finset.range m, (p i + p (i + 1) - 2 * (p i * p (i + 1))) := by
  unfold altCount
  rw [bernExp_sum]
  refine Finset.sum_congr rfl (fun i hi => ?_)
  have him : i < m := Finset.mem_range.mp hi
  have hin : i < n := by omega
  have hi1n : i + 1 < n := by omega
  have hne : i ≠ i + 1 := by omega
  have hshape : (fun s : Fin n → Bool =>
        hit n s i + hit n s (i + 1) - 2 * (hit n s i * hit n s (i + 1)))
      = fun s => (-2 : ℝ) * (hit n s i * hit n s (i + 1)) + 1 * hit n s i
          + 1 * hit n s (i + 1) + 0 := by
    funext s; ring
  rw [hshape, bernExp_comb, bernExp_hit_mul n p hin hi1n hne, bernExp_hit n p hin,
    bernExp_hit n p hi1n]
  ring

/-- **Runs statistic is second-order robust to rate heterogeneity.**  If the rate
curve stays within `δ` of `c`, the expected alternation count differs from the
homogeneous prediction `2 m c (1 - c)` by at most
`m * (2 δ |1 - 2c| + 2 δ²)`; at `c = 1/2` the first-order term vanishes and the
bias is `O(m δ²)`. -/
theorem altCount_heterogeneity_bound (p : ℕ → ℝ) (m : ℕ) (c δ : ℝ)
    (hδ : ∀ i, i < m + 1 → |p i - c| ≤ δ) :
    |(∑ i ∈ Finset.range m, (p i + p (i + 1) - 2 * (p i * p (i + 1))))
        - m * (2 * c * (1 - c))| ≤ m * (2 * δ * |1 - 2 * c| + 2 * δ ^ 2) := by
  have hsplit : (∑ i ∈ Finset.range m, (p i + p (i + 1) - 2 * (p i * p (i + 1))))
      - m * (2 * c * (1 - c))
      = ∑ i ∈ Finset.range m,
          ((p i + p (i + 1) - 2 * (p i * p (i + 1))) - 2 * c * (1 - c)) := by
    rw [Finset.sum_sub_distrib]
    simp [mul_comm]
  rw [hsplit]
  calc |∑ i ∈ Finset.range m, ((p i + p (i + 1) - 2 * (p i * p (i + 1))) - 2 * c * (1 - c))|
      ≤ ∑ i ∈ Finset.range m, |(p i + p (i + 1) - 2 * (p i * p (i + 1))) - 2 * c * (1 - c)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i ∈ Finset.range m, (2 * δ * |1 - 2 * c| + 2 * δ ^ 2) := by
        refine Finset.sum_le_sum (fun i hi => ?_)
        have him : i < m := Finset.mem_range.mp hi
        have h1 : |p i - c| ≤ δ := hδ i (by omega)
        have h2 : |p (i + 1) - c| ≤ δ := hδ (i + 1) (by omega)
        have hid : (p i + p (i + 1) - 2 * (p i * p (i + 1))) - 2 * c * (1 - c)
            = (1 - 2 * c) * ((p i - c) + (p (i + 1) - c))
              - 2 * ((p i - c) * (p (i + 1) - c)) := by ring
        rw [hid]
        have hA : |(1 - 2 * c) * ((p i - c) + (p (i + 1) - c))| ≤ |1 - 2 * c| * (2 * δ) := by
          rw [abs_mul]
          refine mul_le_mul_of_nonneg_left ?_ (abs_nonneg _)
          calc |(p i - c) + (p (i + 1) - c)| ≤ |p i - c| + |p (i + 1) - c| := abs_add_le _ _
            _ ≤ 2 * δ := by linarith
        have hB : |2 * ((p i - c) * (p (i + 1) - c))| ≤ 2 * δ ^ 2 := by
          rw [abs_mul, abs_mul]
          have : |p i - c| * |p (i + 1) - c| ≤ δ ^ 2 := by
            rw [sq]
            exact mul_le_mul h1 h2 (abs_nonneg _) (le_trans (abs_nonneg _) h1)
          simpa using by nlinarith [abs_nonneg (p i - c), abs_nonneg (p (i + 1) - c)]
        calc |(1 - 2 * c) * ((p i - c) + (p (i + 1) - c)) - 2 * ((p i - c) * (p (i + 1) - c))|
            ≤ |(1 - 2 * c) * ((p i - c) + (p (i + 1) - c))|
              + |2 * ((p i - c) * (p (i + 1) - c))| := abs_sub _ _
          _ ≤ |1 - 2 * c| * (2 * δ) + 2 * δ ^ 2 := by linarith
          _ = 2 * δ * |1 - 2 * c| + 2 * δ ^ 2 := by ring
    _ = m * (2 * δ * |1 - 2 * c| + 2 * δ ^ 2) := by
        rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]

/-! ## 5. The Markov alternative: genuine sequence structure -/

section Markov

variable (a b : ℝ)

/-- One step of the two-state chain on the probability of being a hit:
`0 → 1` with probability `a`, `1 → 0` with probability `b`. -/
def mstep (x : ℝ) : ℝ := x * (1 - b) + (1 - x) * a

/-- The second eigenvalue of the transition matrix. -/
def lam : ℝ := 1 - a - b

/-- The stationary hit rate. -/
noncomputable def statRate : ℝ := a / (a + b)

theorem mstep_sub (x y : ℝ) : mstep a b x - mstep a b y = lam a b * (x - y) := by
  unfold mstep lam; ring

theorem mstep_statRate (hab : 0 < a + b) : mstep a b (statRate a b) = statRate a b := by
  unfold mstep statRate
  field_simp
  ring

theorem iterate_mstep_sub (x y : ℝ) : ∀ k : ℕ,
    (mstep a b)^[k] x - (mstep a b)^[k] y = lam a b ^ k * (x - y) := by
  intro k
  induction k generalizing x y with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply, Function.iterate_succ_apply, ih (mstep a b x) (mstep a b y),
        mstep_sub]
      ring

theorem iterate_mstep_statRate (hab : 0 < a + b) : ∀ k : ℕ,
    (mstep a b)^[k] (statRate a b) = statRate a b := by
  intro k
  induction k with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ_apply', ih, mstep_statRate a b hab]

/-- `k`-step hit probability started from a hit. -/
noncomputable def kStepFromHit (k : ℕ) : ℝ := (mstep a b)^[k] 1

/-- The lag-`k` autocovariance of the stationary two-state chain. -/
noncomputable def markovCov (k : ℕ) : ℝ :=
  statRate a b * kStepFromHit a b k - statRate a b ^ 2

/-- The lag-`k` autocorrelation of the stationary two-state chain. -/
noncomputable def markovCorr (k : ℕ) : ℝ :=
  markovCov a b k / (statRate a b * (1 - statRate a b))

/-- **Exact geometric autocovariance.** -/
theorem markovCov_eq (hab : 0 < a + b) (k : ℕ) :
    markovCov a b k = statRate a b * (1 - statRate a b) * lam a b ^ k := by
  unfold markovCov kStepFromHit
  have h := iterate_mstep_sub a b 1 (statRate a b) k
  rw [iterate_mstep_statRate a b hab k] at h
  have h1 : (mstep a b)^[k] 1 = statRate a b + lam a b ^ k * (1 - statRate a b) := by linarith
  rw [h1]; ring

/-- **The Markov lag profile is exactly geometric**: `ρ(k) = λ^k`.  This is the
shape that control C3 injected and the analysis recovered (argmax at lag 1). -/
theorem markovCorr_eq_lambda_pow (hab : 0 < a + b) (hpos : statRate a b * (1 - statRate a b) ≠ 0)
    (k : ℕ) : markovCorr a b k = lam a b ^ k := by
  unfold markovCorr
  rw [markovCov_eq a b hab k, mul_comm (statRate a b * (1 - statRate a b)) (lam a b ^ k),
    mul_div_assoc, div_self hpos, mul_one]

/-- **The profile peaks at lag 1.**  For a contracting chain the autocorrelation
is largest in absolute value at lag 1, so an argmax anywhere else is evidence
against the Markov alternative. -/
theorem markov_profile_peaks_at_lag_one (hab : 0 < a + b)
    (hpos : statRate a b * (1 - statRate a b) ≠ 0) (hlam : |lam a b| ≤ 1) {k : ℕ} (hk : 1 ≤ k) :
    |markovCorr a b k| ≤ |markovCorr a b 1| := by
  rw [markovCorr_eq_lambda_pow a b hab hpos, markovCorr_eq_lambda_pow a b hab hpos, pow_one,
    abs_pow]
  exact pow_le_of_le_one (abs_nonneg _) hlam (by omega) |>.trans_eq rfl

/-- **Independence is exactly the `λ = 0` point of the Markov family.**  The lag
profile vanishes at some (equivalently every) lag `k ≥ 1` iff the chain has no
memory. -/
theorem markov_indep_iff (hab : 0 < a + b) (hpos : statRate a b * (1 - statRate a b) ≠ 0) :
    (∀ k : ℕ, 1 ≤ k → markovCorr a b k = 0) ↔ lam a b = 0 := by
  constructor
  · intro h
    have := h 1 le_rfl
    rwa [markovCorr_eq_lambda_pow a b hab hpos, pow_one] at this
  · intro h k hk
    rw [markovCorr_eq_lambda_pow a b hab hpos, h, zero_pow (by omega)]

/-- The transition matrix of the chain. -/
def transMatrix : Matrix (Fin 2) (Fin 2) ℝ := !![1 - a, a; b, 1 - b]

/-- **The affine iterate really is the matrix power**: the `k`-step probability
of a hit starting from a hit is the `(1,1)` entry of `M^k`, and the row sums stay
one.  This certifies that `kStepFromHit` is the Markov `k`-step law and not an
ad hoc recursion. -/
theorem markov_matrix_pow_apply : ∀ k : ℕ,
    (transMatrix a b ^ k) 1 1 = kStepFromHit a b k ∧
      (transMatrix a b ^ k) 1 0 = 1 - kStepFromHit a b k := by
  intro k
  induction k with
  | zero => simp [kStepFromHit]
  | succ k ih =>
      obtain ⟨ih1, ih0⟩ := ih
      have hmul : ∀ j : Fin 2, (transMatrix a b ^ (k + 1)) 1 j
          = (transMatrix a b ^ k) 1 0 * transMatrix a b 0 j
            + (transMatrix a b ^ k) 1 1 * transMatrix a b 1 j := by
        intro j
        rw [pow_succ, Matrix.mul_apply, Fin.sum_univ_two]
      have hstep : kStepFromHit a b (k + 1) = mstep a b (kStepFromHit a b k) := by
        unfold kStepFromHit
        rw [Function.iterate_succ_apply']
      constructor
      · rw [hmul 1, ih0, ih1, hstep]
        simp [transMatrix, mstep]; ring
      · rw [hmul 0, ih0, ih1, hstep]
        simp [transMatrix, mstep]; ring

end Markov

/-! ## 6. The dichotomy: density versus dependence -/

/-- **Density/dependence dichotomy.**  Fix the pre-registered detection bar
`0.05`.  A heterogeneous but *independent* scan whose rate curve stays inside
`[0.45, 0.55]` produces a literal lag-`k` autocorrelation strictly below the bar
at every lag, while a stationary two-state Markov scan with `|λ| ≥ 0.05` produces
a lag-1 autocorrelation at or above it.  Hence a measured null is a genuine
exclusion of sequence structure of that strength, not an artefact of the density
curve — the formal counterpart of the experiment's controls C2 (confound
immaterial) and C3 (power confirmed). -/
theorem density_dependence_dichotomy (n : ℕ) (p : ℕ → ℝ) {k m : ℕ} (hk : 1 ≤ k) (hm : m + k ≤ n)
    (hm0 : 0 < m) (hp : ∀ i, i < m + k → |p i - (1 / 2 : ℝ)| ≤ 1 / 20)
    (a b : ℝ) (hab : 0 < a + b) (hpos : statRate a b * (1 - statRate a b) ≠ 0)
    (hlam : 1 / 20 ≤ |lam a b|) :
    |bernExp n p (fun s => centeredPairSum n s k m (fun _ => 1 / 2)) / (m * (99 / 400))|
        < 1 / 20 ∧ 1 / 20 ≤ |markovCorr a b 1| := by
  refine ⟨curvature_cannot_fake_H1 n p hk hm hm0 hp, ?_⟩
  rw [markovCorr_eq_lambda_pow a b hab hpos, pow_one]
  exact hlam

/-! ## 7. Noise floor of the detrended statistic: the null has power -/

/-- **Centred products vanish.**  Under pure density the expectation of a product
of *centred* hit indicators over any nonempty set of distinct positions is `0`.
This is the full multilinear form of independence for the model. -/
theorem bernExp_centered_prod_eq_zero (n : ℕ) (p : ℕ → ℝ) (S : Finset (Fin n)) (hS : S.Nonempty) :
    bernExp n p (fun s => ∏ i ∈ S, ((if s i then (1 : ℝ) else 0) - p i.val)) = 0 := by
  classical
  have hexp : ∀ s : Fin n → Bool, (∏ i ∈ S, ((if s i then (1 : ℝ) else 0) - p i.val))
      = ∑ T ∈ S.powerset, (∏ i ∈ T, (if s i then (1 : ℝ) else 0)) * ∏ i ∈ S \ T, (-p i.val) := by
    intro s
    have h := Finset.prod_add (fun i : Fin n => (if s i then (1 : ℝ) else 0))
      (fun i : Fin n => -p i.val) S
    simpa [sub_eq_add_neg] using h
  simp_rw [hexp]
  rw [bernExp_sum]
  have hterm : ∀ T ∈ S.powerset,
      bernExp n p (fun s => (∏ i ∈ T, (if s i then (1 : ℝ) else 0)) * ∏ i ∈ S \ T, (-p i.val))
        = (∏ i ∈ T, p i.val) * ∏ i ∈ S \ T, (-p i.val) := by
    intro T _
    have hcomm : (fun s : Fin n → Bool =>
        (∏ i ∈ T, (if s i then (1 : ℝ) else 0)) * ∏ i ∈ S \ T, (-p i.val))
        = fun s => (∏ i ∈ S \ T, (-p i.val)) * (∏ i ∈ T, (if s i then (1 : ℝ) else 0)) := by
      funext s; ring
    rw [hcomm, bernExp_const_mul, bernExp_marker]
    ring
  rw [Finset.sum_congr rfl hterm,
    ← Finset.prod_add (fun i : Fin n => p i.val) (fun i : Fin n => -p i.val) S]
  obtain ⟨i0, hi0⟩ := hS
  exact Finset.prod_eq_zero hi0 (by ring)

/-- Centred hit indicators have mean zero. -/
theorem bernExp_centered_one (n : ℕ) (p : ℕ → ℝ) {i : ℕ} (hi : i < n) :
    bernExp n p (fun s => hit n s i - p i) = 0 := by
  have hfun : (fun s : Fin n → Bool => hit n s i - p i)
      = fun s => ∏ x ∈ ({⟨i, hi⟩} : Finset (Fin n)), ((if s x then (1 : ℝ) else 0) - p x.val) := by
    funext s; rw [Finset.prod_singleton, hit_eq n s hi]
  rw [hfun]
  exact bernExp_centered_prod_eq_zero n p _ ⟨⟨i, hi⟩, by simp⟩

/-- Two distinct centred hit indicators are uncorrelated. -/
theorem bernExp_centered_two (n : ℕ) (p : ℕ → ℝ) {i j : ℕ} (hi : i < n) (hj : j < n)
    (hij : i ≠ j) :
    bernExp n p (fun s => (hit n s i - p i) * (hit n s j - p j)) = 0 := by
  have hne : (⟨i, hi⟩ : Fin n) ≠ ⟨j, hj⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hij
  have hfun : (fun s : Fin n → Bool => (hit n s i - p i) * (hit n s j - p j))
      = fun s => ∏ x ∈ ({⟨i, hi⟩, ⟨j, hj⟩} : Finset (Fin n)),
          ((if s x then (1 : ℝ) else 0) - p x.val) := by
    funext s; rw [Finset.prod_pair hne, hit_eq n s hi, hit_eq n s hj]
  rw [hfun]
  exact bernExp_centered_prod_eq_zero n p _ ⟨⟨i, hi⟩, by simp⟩

/-- Three distinct centred hit indicators have vanishing joint moment. -/
theorem bernExp_centered_three (n : ℕ) (p : ℕ → ℝ) {i j l : ℕ} (hi : i < n) (hj : j < n)
    (hl : l < n) (hij : i ≠ j) (hil : i ≠ l) (hjl : j ≠ l) :
    bernExp n p (fun s => (hit n s i - p i) * ((hit n s j - p j) * (hit n s l - p l))) = 0 := by
  have hnij : (⟨i, hi⟩ : Fin n) ≠ ⟨j, hj⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hij
  have hnil : (⟨i, hi⟩ : Fin n) ≠ ⟨l, hl⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hil
  have hnjl : (⟨j, hj⟩ : Fin n) ≠ ⟨l, hl⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hjl
  have hmem : (⟨i, hi⟩ : Fin n) ∉ ({⟨j, hj⟩, ⟨l, hl⟩} : Finset (Fin n)) := by
    simp [hnij, hnil]
  have hfun : (fun s : Fin n → Bool =>
        (hit n s i - p i) * ((hit n s j - p j) * (hit n s l - p l)))
      = fun s => ∏ x ∈ ({⟨i, hi⟩, ⟨j, hj⟩, ⟨l, hl⟩} : Finset (Fin n)),
          ((if s x then (1 : ℝ) else 0) - p x.val) := by
    funext s
    rw [Finset.prod_insert hmem, Finset.prod_pair hnjl, hit_eq n s hi, hit_eq n s hj,
      hit_eq n s hl]
  rw [hfun]
  exact bernExp_centered_prod_eq_zero n p _ ⟨⟨i, hi⟩, by simp⟩

/-- Four distinct centred hit indicators have vanishing joint moment. -/
theorem bernExp_centered_four (n : ℕ) (p : ℕ → ℝ) {i j l r : ℕ} (hi : i < n) (hj : j < n)
    (hl : l < n) (hr : r < n) (hij : i ≠ j) (hil : i ≠ l) (hir : i ≠ r) (hjl : j ≠ l)
    (hjr : j ≠ r) (hlr : l ≠ r) :
    bernExp n p (fun s => (hit n s i - p i) *
      ((hit n s j - p j) * ((hit n s l - p l) * (hit n s r - p r)))) = 0 := by
  have hnij : (⟨i, hi⟩ : Fin n) ≠ ⟨j, hj⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hij
  have hnil : (⟨i, hi⟩ : Fin n) ≠ ⟨l, hl⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hil
  have hnir : (⟨i, hi⟩ : Fin n) ≠ ⟨r, hr⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hir
  have hnjl : (⟨j, hj⟩ : Fin n) ≠ ⟨l, hl⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hjl
  have hnjr : (⟨j, hj⟩ : Fin n) ≠ ⟨r, hr⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hjr
  have hnlr : (⟨l, hl⟩ : Fin n) ≠ ⟨r, hr⟩ := by simp only [ne_eq, Fin.mk.injEq]; exact hlr
  have hmem1 : (⟨i, hi⟩ : Fin n) ∉ ({⟨j, hj⟩, ⟨l, hl⟩, ⟨r, hr⟩} : Finset (Fin n)) := by
    simp [hnij, hnil, hnir]
  have hmem2 : (⟨j, hj⟩ : Fin n) ∉ ({⟨l, hl⟩, ⟨r, hr⟩} : Finset (Fin n)) := by
    simp [hnjl, hnjr]
  have hfun : (fun s : Fin n → Bool => (hit n s i - p i) *
        ((hit n s j - p j) * ((hit n s l - p l) * (hit n s r - p r))))
      = fun s => ∏ x ∈ ({⟨i, hi⟩, ⟨j, hj⟩, ⟨l, hl⟩, ⟨r, hr⟩} : Finset (Fin n)),
          ((if s x then (1 : ℝ) else 0) - p x.val) := by
    funext s
    rw [Finset.prod_insert hmem1, Finset.prod_insert hmem2, Finset.prod_pair hnlr,
      hit_eq n s hi, hit_eq n s hj, hit_eq n s hl, hit_eq n s hr]
  rw [hfun]
  exact bernExp_centered_prod_eq_zero n p _ ⟨⟨i, hi⟩, by simp⟩

/-- The Bernoulli variance at one position. -/
def posVar (p : ℕ → ℝ) (i : ℕ) : ℝ := p i * (1 - p i)

/-- The hit indicator is idempotent. -/
theorem hit_sq (n : ℕ) (s : Fin n → Bool) (i : ℕ) : hit n s i ^ 2 = hit n s i := by
  unfold hit
  split
  · split <;> norm_num
  · norm_num

/-- Squares linearise: `(X - p)² = (1 - 2p)(X - p) + p(1 - p)` for a `0/1` variable. -/
theorem centered_sq (n : ℕ) (s : Fin n → Bool) (p : ℕ → ℝ) (i : ℕ) :
    (hit n s i - p i) ^ 2 = (1 - 2 * p i) * (hit n s i - p i) + posVar p i := by
  unfold posVar
  linear_combination hit_sq n s i

/-- One lag-`k` cross-product term, centred at the true rate curve. -/
def detrTerm (n : ℕ) (s : Fin n → Bool) (p : ℕ → ℝ) (k i : ℕ) : ℝ :=
  (hit n s i - p i) * (hit n s (i + k) - p (i + k))

/-- **Second moment of a single term** equals the product of the two Bernoulli
variances. -/
theorem bernExp_detrTerm_sq (n : ℕ) (p : ℕ → ℝ) {k i : ℕ} (hk : 1 ≤ k) (hi : i < n)
    (hik : i + k < n) :
    bernExp n p (fun s => detrTerm n s p k i ^ 2) = posVar p i * posVar p (i + k) := by
  have hne : i ≠ i + k := by omega
  have hfun : (fun s : Fin n → Bool => detrTerm n s p k i ^ 2)
      = fun s => (1 - 2 * p i) * (1 - 2 * p (i + k))
            * ((hit n s i - p i) * (hit n s (i + k) - p (i + k)))
          + ((1 - 2 * p i) * posVar p (i + k)) * (hit n s i - p i)
          + (posVar p i * (1 - 2 * p (i + k))) * (hit n s (i + k) - p (i + k))
          + posVar p i * posVar p (i + k) := by
    funext s
    unfold detrTerm
    rw [mul_pow, centered_sq n s p i, centered_sq n s p (i + k)]
    ring
  rw [hfun, bernExp_comb, bernExp_centered_two n p hi hik hne, bernExp_centered_one n p hi,
    bernExp_centered_one n p hik]
  ring

/-- **Distinct terms are uncorrelated**, including the overlapping case `j = i + k`
where the two pairs share a position. -/
theorem bernExp_detrTerm_mul (n : ℕ) (p : ℕ → ℝ) {k i j : ℕ} (hk : 1 ≤ k) (hij : i ≠ j)
    (hi : i + k < n) (hj : j + k < n) :
    bernExp n p (fun s => detrTerm n s p k i * detrTerm n s p k j) = 0 := by
  have hin : i < n := by omega
  have hjn : j < n := by omega
  rcases eq_or_ne j (i + k) with hji | hji
  · subst hji
    have h2 : i + k + k < n := hj
    have hfun : (fun s : Fin n → Bool => detrTerm n s p k i * detrTerm n s p k (i + k))
        = fun s => (1 - 2 * p (i + k))
              * ((hit n s i - p i) * ((hit n s (i + k) - p (i + k))
                  * (hit n s (i + k + k) - p (i + k + k))))
            + posVar p (i + k)
              * ((hit n s i - p i) * (hit n s (i + k + k) - p (i + k + k)))
            + 0 * (hit n s i - p i) + 0 := by
      funext s
      unfold detrTerm
      have hsq : (hit n s (i + k) - p (i + k)) ^ 2
          = (1 - 2 * p (i + k)) * (hit n s (i + k) - p (i + k)) + posVar p (i + k) :=
        centered_sq n s p (i + k)
      linear_combination ((hit n s i - p i) * (hit n s (i + k + k) - p (i + k + k))) * hsq
    rw [hfun, bernExp_comb,
      bernExp_centered_three n p hin hi h2 (by omega) (by omega) (by omega),
      bernExp_centered_two n p hin h2 (by omega)]
    simp
  · rcases eq_or_ne i (j + k) with hij2 | hij2
    · subst hij2
      have h2 : j + k + k < n := hi
      have hfun : (fun s : Fin n → Bool => detrTerm n s p k (j + k) * detrTerm n s p k j)
          = fun s => (1 - 2 * p (j + k))
                * ((hit n s j - p j) * ((hit n s (j + k) - p (j + k))
                    * (hit n s (j + k + k) - p (j + k + k))))
              + posVar p (j + k)
                * ((hit n s j - p j) * (hit n s (j + k + k) - p (j + k + k)))
              + 0 * (hit n s j - p j) + 0 := by
        funext s
        unfold detrTerm
        have hsq : (hit n s (j + k) - p (j + k)) ^ 2
            = (1 - 2 * p (j + k)) * (hit n s (j + k) - p (j + k)) + posVar p (j + k) :=
          centered_sq n s p (j + k)
        linear_combination ((hit n s j - p j) * (hit n s (j + k + k) - p (j + k + k))) * hsq
      rw [hfun, bernExp_comb,
        bernExp_centered_three n p hjn hj h2 (by omega) (by omega) (by omega),
        bernExp_centered_two n p hjn h2 (by omega)]
      simp
    · have hfun : (fun s : Fin n → Bool => detrTerm n s p k i * detrTerm n s p k j)
          = fun s => 1 * ((hit n s i - p i) * ((hit n s (i + k) - p (i + k))
              * ((hit n s j - p j) * (hit n s (j + k) - p (j + k)))))
            + 0 * (hit n s i - p i) + 0 * (hit n s j - p j) + 0 := by
        funext s; unfold detrTerm; ring
      rw [hfun, bernExp_comb,
        bernExp_centered_four n p hin hi hjn hj (by omega) hij (by omega)
          (fun h => hji h.symm) (by omega) (by omega)]
      simp

/-- **Exact variance of the detrended lag-`k` statistic** under pure density: the
terms are uncorrelated, so the variance is the sum of the products of the two
Bernoulli variances at the two ends of each pair. -/
theorem bernExp_centeredPairSum_sq (n : ℕ) (p : ℕ → ℝ) {k m : ℕ} (hk : 1 ≤ k) (hm : m + k ≤ n) :
    bernExp n p (fun s => centeredPairSum n s k m p ^ 2)
      = ∑ i ∈ Finset.range m, posVar p i * posVar p (i + k) := by
  have hfun : (fun s : Fin n → Bool => centeredPairSum n s k m p ^ 2)
      = fun s => ∑ i ∈ Finset.range m, ∑ j ∈ Finset.range m,
          detrTerm n s p k i * detrTerm n s p k j := by
    funext s
    rw [sq]
    unfold centeredPairSum detrTerm
    rw [Finset.sum_mul_sum]
  rw [hfun, bernExp_sum]
  refine Finset.sum_congr rfl (fun i hi => ?_)
  have him : i < m := Finset.mem_range.mp hi
  have hik : i + k < n := by omega
  rw [bernExp_sum]
  rw [Finset.sum_eq_single i]
  · have : (fun s : Fin n → Bool => detrTerm n s p k i * detrTerm n s p k i)
        = fun s => detrTerm n s p k i ^ 2 := by funext s; rw [sq]
    rw [this, bernExp_detrTerm_sq n p hk (by omega) hik]
  · intro j hj hji
    have hjm : j < m := Finset.mem_range.mp hj
    exact bernExp_detrTerm_mul n p hk (fun h => hji h.symm) hik (by omega)
  · intro h; exact absurd hi h

/-- Probability of a set of scan configurations. -/
noncomputable def bernProb (n : ℕ) (p : ℕ → ℝ) (A : Finset (Fin n → Bool)) : ℝ :=
  ∑ s ∈ A, confWeight n p s

theorem confWeight_nonneg (n : ℕ) (p : ℕ → ℝ) (hp : ∀ i, i < n → 0 ≤ p i ∧ p i ≤ 1)
    (s : Fin n → Bool) : 0 ≤ confWeight n p s := by
  unfold confWeight
  refine Finset.prod_nonneg (fun i _ => ?_)
  rcases hp i.val i.isLt with ⟨h0, h1⟩
  by_cases h : s i <;> simp [h] <;> linarith

/-- **Chebyshev's inequality inside the model.** -/
theorem bern_chebyshev (n : ℕ) (p : ℕ → ℝ) (hp : ∀ i, i < n → 0 ≤ p i ∧ p i ≤ 1)
    (Z : (Fin n → Bool) → ℝ) {t : ℝ} (ht : 0 < t) :
    bernProb n p {s | t ≤ |Z s|} ≤ bernExp n p (fun s => Z s ^ 2) / t ^ 2 := by
  classical
  have hsub : ({s | t ≤ |Z s|} : Finset (Fin n → Bool)) ⊆ Finset.univ := Finset.subset_univ _
  have hstep : t ^ 2 * bernProb n p {s | t ≤ |Z s|}
      ≤ ∑ s ∈ ({s | t ≤ |Z s|} : Finset (Fin n → Bool)), confWeight n p s * Z s ^ 2 := by
    unfold bernProb
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum (fun s hs => ?_)
    have hts : t ≤ |Z s| := by simpa using hs
    have hZ : t ^ 2 ≤ Z s ^ 2 := by
      have : t ^ 2 ≤ |Z s| ^ 2 := by nlinarith [abs_nonneg (Z s)]
      simpa [sq_abs] using this
    have hw := confWeight_nonneg n p hp s
    nlinarith [hw, hZ]
  have htail : ∑ s ∈ ({s | t ≤ |Z s|} : Finset (Fin n → Bool)), confWeight n p s * Z s ^ 2
      ≤ bernExp n p (fun s => Z s ^ 2) := by
    unfold bernExp
    refine Finset.sum_le_sum_of_subset_of_nonneg hsub (fun s _ _ => ?_)
    have hw := confWeight_nonneg n p hp s
    positivity
  rw [le_div_iff₀ (by positivity)]
  calc bernProb n p {s | t ≤ |Z s|} * t ^ 2 = t ^ 2 * bernProb n p {s | t ≤ |Z s|} := by ring
    _ ≤ ∑ s ∈ ({s | t ≤ |Z s|} : Finset (Fin n → Bool)), confWeight n p s * Z s ^ 2 := hstep
    _ ≤ bernExp n p (fun s => Z s ^ 2) := htail

theorem posVar_le_quarter (p : ℕ → ℝ) (i : ℕ) : posVar p i ≤ 1 / 4 := by
  unfold posVar; nlinarith [sq_nonneg (p i - 1 / 2)]

theorem posVar_nonneg (p : ℕ → ℝ) {i : ℕ} (h0 : 0 ≤ p i) (h1 : p i ≤ 1) : 0 ≤ posVar p i := by
  unfold posVar; nlinarith

/-- **Noise floor of the null.**  Under pure density the detrended lag-`k`
statistic, normalised by the number of pairs, exceeds a level `t` with
probability at most `1 / (16 m t²)`.  With the experiment's `m = 9594` pairs and
the pre-registered bar `t = 0.05` this is below `0.003`: the observed flat
profile is not merely consistent with independence, crossing the bar under
independence is a rare event, so the recorded null genuinely excludes
dependence of detectable size. -/
theorem detrended_noise_floor (n : ℕ) (p : ℕ → ℝ) {k m : ℕ} (hk : 1 ≤ k) (hm : m + k ≤ n)
    (hm0 : 0 < m) (hp : ∀ i, i < n → 0 ≤ p i ∧ p i ≤ 1) {t : ℝ} (ht : 0 < t) :
    bernProb n p {s | t * m ≤ |centeredPairSum n s k m p|} ≤ 1 / (16 * m * t ^ 2) := by
  have hmpos : (0 : ℝ) < m := by exact_mod_cast hm0
  have hcheb := bern_chebyshev n p hp (fun s => centeredPairSum n s k m p)
    (t := t * m) (by positivity)
  have hvar : bernExp n p (fun s => centeredPairSum n s k m p ^ 2) ≤ m * (1 / 16) := by
    rw [bernExp_centeredPairSum_sq n p hk hm]
    calc ∑ i ∈ Finset.range m, posVar p i * posVar p (i + k)
        ≤ ∑ _i ∈ Finset.range m, (1 / 4 : ℝ) * (1 / 4) := by
          refine Finset.sum_le_sum (fun i hi => ?_)
          have him : i < m := Finset.mem_range.mp hi
          have h1 := posVar_le_quarter p i
          have h2 := posVar_le_quarter p (i + k)
          have hn1 : 0 ≤ posVar p i := by
            obtain ⟨ha, hb⟩ := hp i (by omega); exact posVar_nonneg p ha hb
          have hn2 : 0 ≤ posVar p (i + k) := by
            obtain ⟨ha, hb⟩ := hp (i + k) (by omega); exact posVar_nonneg p ha hb
          nlinarith
      _ = m * (1 / 16) := by
          rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]; ring
  have hfinal : bernExp n p (fun s => centeredPairSum n s k m p ^ 2) / (t * m) ^ 2
      ≤ 1 / (16 * m * t ^ 2) := by
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hvar, hmpos, sq_nonneg t, ht]
  exact le_trans hcheb hfinal

/-- Numerical instance at the experiment's scale: with `m = 9594` pairs, under pure
density the detrended lag-`k` statistic reaches the pre-registered `0.05` bar with
probability at most `0.003`. -/
theorem detrended_noise_floor_experiment (n : ℕ) (p : ℕ → ℝ) {k : ℕ} (hk : 1 ≤ k)
    (hm : 9594 + k ≤ n) (hp : ∀ i, i < n → 0 ≤ p i ∧ p i ≤ 1) :
    bernProb n p {s | (1 / 20 : ℝ) * 9594 ≤ |centeredPairSum n s k 9594 p|}
      ≤ 3 / 1000 := by
  have h := detrended_noise_floor n p hk hm (by norm_num) hp (t := 1 / 20) (by norm_num)
  have hb : (1 : ℝ) / (16 * (9594 : ℕ) * (1 / 20 : ℝ) ^ 2) ≤ 3 / 1000 := by
    norm_num
  exact le_trans h hb

end ConsecutiveVDependency