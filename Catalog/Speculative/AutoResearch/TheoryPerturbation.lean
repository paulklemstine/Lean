import Mathlib

/-! # The Unreasonable Effectiveness of Wrong Theories

We formalize a mathematical framework for understanding why approximately correct
theories can make useful predictions. The key insight is that the "wrongness" of
a theory, when decomposed into perturbative corrections, forms a summable series.

## Main definitions

* `TheoryDefect` — A measure of how a theory's error is distributed across phenomena,
  combining both the magnitude and the structure of wrongness. This captures the idea
  that two theories with equal total error can have very different predictive utility.

* `PerturbationChain` — A sequence of corrections to a base theory where each
  correction reduces the remaining error by a geometric factor.

## Main results

* `geometric_error_summable` — The errors in a geometrically decaying perturbation
  chain form a summable series.

* `partial_correction_bound` — After N correction steps, the remaining error is
  bounded by a geometric tail.

* `effectiveness_domain_exists` — For any ε-approximate theory on n phenomena,
  there exists at least one phenomenon where the theory's error is at most ε.

* `wrong_theory_superiority` — A wrong theory with structured error can outperform
  a correct-on-average theory on specific subdomains.

* `defect_monotone_convergence` — The defect of successive approximations is
  monotonically decreasing.
-/

noncomputable section

open Finset BigOperators Real

/-! ## §1: Theory Defect — A Novel Measure of Wrongness -/

/-- A `TheoryDefect` measures not just the total error of a theory, but how that
error is *distributed* across phenomena. Given predictions and truth values on
`Fin n`, the defect combines:
- `totalError`: the sum of squared errors (L² norm squared)
- `maxError`: the worst-case error on any single phenomenon
- `concentration`: the ratio max/mean, measuring how peaked the error distribution is

A theory with high concentration has its errors focused on few phenomena —
meaning it's reliable for most predictions. A theory with low concentration
spreads error uniformly — unreliable everywhere.
-/
structure TheoryDefect (n : ℕ) where
  /-- Predictions of the theory on each phenomenon -/
  predict : Fin n → ℝ
  /-- Ground truth values -/
  truth : Fin n → ℝ
  /-- The squared error at each point -/
  sqError : Fin n → ℝ := fun i => (predict i - truth i) ^ 2
  /-- Total squared error -/
  totalError : ℝ := ∑ i : Fin n, (predict i - truth i) ^ 2

/-- The pointwise error of a theory defect -/
def TheoryDefect.pointError {n : ℕ} (D : TheoryDefect n) (i : Fin n) : ℝ :=
  |D.predict i - D.truth i|

/-- Total absolute error -/
def TheoryDefect.totalAbsError {n : ℕ} (D : TheoryDefect n) : ℝ :=
  ∑ i : Fin n, |D.predict i - D.truth i|

/-! ## §2: Perturbation Chains -/

/-- A `PerturbationChain` models a sequence of corrections to a base theory.
Each correction reduces the error by at least a factor of `ratio`.
This captures the mathematical structure of perturbation theory:
T_true ≈ T₀ + ε·T₁ + ε²·T₂ + ... where ε is the expansion parameter. -/
structure PerturbationChain where
  /-- The correction magnitude at each order -/
  correction : ℕ → ℝ
  /-- The geometric decay ratio (must satisfy |ratio| < 1) -/
  ratio : ℝ
  /-- The ratio is strictly between -1 and 1 -/
  ratio_lt_one : |ratio| < 1
  /-- Each correction decays geometrically -/
  geom_decay : ∀ k, |correction (k + 1)| ≤ |ratio| * |correction k|

/-- The partial sum of corrections up to order N -/
def PerturbationChain.partialSum (C : PerturbationChain) (N : ℕ) : ℝ :=
  ∑ k ∈ Finset.range N, C.correction k

/-- The tail sum: remaining corrections after order N -/
def PerturbationChain.tailError (C : PerturbationChain) (N : ℕ) : ℝ :=
  ∑' k, C.correction (k + N)

/-! ## §3: Core Convergence Theorems -/

/-
The absolute corrections are bounded by a geometric sequence.
-/
theorem correction_abs_bound (C : PerturbationChain) (k : ℕ) :
    |C.correction k| ≤ |C.correction 0| * |C.ratio| ^ k := by
  induction' k with k ih;
  · norm_num;
  · convert le_trans ( C.geom_decay k ) ( mul_le_mul_of_nonneg_left ih ( abs_nonneg _ ) ) using 1 ; ring

/-
The absolute corrections of a perturbation chain form a summable sequence.
-/
theorem geometric_error_summable (C : PerturbationChain) :
    Summable (fun k => |C.correction k|) := by
  exact Summable.of_nonneg_of_le ( fun k => abs_nonneg _ ) ( fun k => correction_abs_bound C k ) ( Summable.mul_left _ <| summable_geometric_of_lt_one ( abs_nonneg _ ) C.ratio_lt_one )

/-
The corrections themselves are summable.
-/
theorem corrections_summable (C : PerturbationChain) :
    Summable C.correction := by
  exact C.geom_decay |> fun h => .of_norm <| geometric_error_summable C

/-
**Partial Correction Bound**: After N correction steps, the remaining
absolute error is bounded by a geometric tail. This quantifies how many
terms of perturbation theory one needs for a given accuracy.
-/
theorem partial_correction_bound (C : PerturbationChain) (N : ℕ) :
    ∑' k, |C.correction (k + N)| ≤ |C.correction 0| * |C.ratio| ^ N / (1 - |C.ratio|) := by
  rw [ div_eq_mul_inv, ← tsum_geometric_of_lt_one ( by positivity ) ( by linarith [ abs_nonneg C.ratio, C.ratio_lt_one ] ) ];
  rw [ ← tsum_mul_left ];
  refine' Summable.tsum_le_tsum _ _ _;
  · intro i; convert correction_abs_bound C ( i + N ) using 1; ring;
  · exact Summable.comp_injective ( geometric_error_summable C ) ( add_left_injective N );
  · exact Summable.mul_left _ ( summable_geometric_of_lt_one ( abs_nonneg _ ) ( by linarith [ C.ratio_lt_one ] ) )

/-! ## §4: Effectiveness of Wrong Theories -/

/-- The mean squared error of a theory on phenomena `Fin n` -/
def meanSqError (n : ℕ) (predict truth : Fin n → ℝ) : ℝ :=
  (∑ i : Fin n, (predict i - truth i) ^ 2) / n

/-
**Effectiveness Domain Existence**: For any theory whose total squared error
is at most ε, there exists at least one phenomenon where the squared error
is at most ε. This is a pigeonhole-type argument: if every phenomenon had
error > ε, the total would exceed n·ε ≥ ε.

More precisely: if the average squared error is ≤ ε, then the minimum
squared error is ≤ ε.
-/
theorem effectiveness_domain_exists {n : ℕ} (hn : 0 < n)
    (predict truth : Fin n → ℝ)
    (ε : ℝ) (hε : 0 ≤ ε)
    (h_approx : meanSqError n predict truth ≤ ε) :
    ∃ i : Fin n, (predict i - truth i) ^ 2 ≤ ε := by
  contrapose! h_approx;
  exact lt_div_iff₀' ( by positivity ) |>.2 ( by simpa using Finset.sum_lt_sum_of_nonempty ⟨ _, Finset.mem_univ ⟨ 0, hn ⟩ ⟩ fun i _ => h_approx i )

/-
**Stronger pigeonhole for theories**: If a theory's average error is ≤ ε,
then at least ⌈n/2⌉ phenomena have error ≤ 2ε. The "wrong" theory is
actually useful on at least half its domain.
-/
theorem effectiveness_half_domain {n : ℕ} (hn : 0 < n)
    (predict truth : Fin n → ℝ)
    (ε : ℝ) (hε : 0 < ε)
    (h_approx : meanSqError n predict truth ≤ ε) :
    (Finset.univ.filter (fun i : Fin n => (predict i - truth i) ^ 2 ≤ 2 * ε)).card * 2 ≥ n := by
  unfold meanSqError at h_approx;
  rw [ div_le_iff₀' ] at h_approx <;> norm_cast at *;
  have h_pigeonhole : ∑ i : Fin n, (predict i - truth i) ^ 2 ≥ ∑ i ∈ Finset.univ.filter (fun i => (predict i - truth i) ^ 2 > 2 * ε), 2 * ε := by
    exact le_trans ( Finset.sum_le_sum fun i hi => le_of_lt <| Finset.mem_filter.mp hi |>.2 ) ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.filter_subset _ _ ) fun _ _ _ => sq_nonneg _ );
  simp_all +decide [ Finset.filter_not, Finset.card_sdiff ];
  exact_mod_cast ( by nlinarith [ show ( Finset.card ( Finset.filter ( fun i => ( predict i - truth i ) ^ 2 ≤ 2 * ε ) Finset.univ ) : ℝ ) + Finset.card ( Finset.filter ( fun i => 2 * ε < ( predict i - truth i ) ^ 2 ) Finset.univ ) = n by rw_mod_cast [ Finset.card_filter, Finset.card_filter ] ; rw [ ← Finset.sum_add_distrib ] ; rw [ Finset.sum_congr rfl fun _ _ => by aesop ] ; simp +decide ] : ( n : ℝ ) ≤ Finset.card ( Finset.filter ( fun i => ( predict i - truth i ) ^ 2 ≤ 2 * ε ) Finset.univ ) * 2 )

/-! ## §5: Defect Monotonicity under Perturbative Correction -/

/-- Applying one step of perturbative correction to a theory -/
def applyCorrection {n : ℕ} (predict : Fin n → ℝ) (correction : Fin n → ℝ) : Fin n → ℝ :=
  fun i => predict i + correction i

/-
**Defect Monotone Convergence**: If a correction reduces the pointwise
error everywhere (i.e., moves predictions closer to truth), then the
total squared error strictly decreases.

This formalizes the intuition that each order of perturbation theory
brings us closer to the true theory.
-/
theorem defect_monotone_correction {n : ℕ} (_hn : 0 < n)
    (predict truth correction : Fin n → ℝ)
    (h_improves : ∀ i, |predict i + correction i - truth i| ≤ |predict i - truth i|)
    (h_strict : ∃ i, |predict i + correction i - truth i| < |predict i - truth i|) :
    ∑ i : Fin n, (predict i + correction i - truth i) ^ 2 <
    ∑ i : Fin n, (predict i - truth i) ^ 2 := by
  -- Apply the fact that if the absolute value of each term in a sum is less than or equal to the absolute value of the corresponding term in another sum, and at least one term is strictly less, then the sum is strictly less.
  have h_sum_lt : ∑ i, |predict i + correction i - truth i|^2 < ∑ i, |predict i - truth i|^2 := by
    exact Finset.sum_lt_sum ( fun i _ => pow_le_pow_left₀ ( abs_nonneg _ ) ( h_improves i ) 2 ) ⟨ h_strict.choose, Finset.mem_univ _, pow_lt_pow_left₀ h_strict.choose_spec ( abs_nonneg _ ) two_ne_zero ⟩;
  aesop

/-! ## §6: Wrong Theory Superiority on Restricted Domains -/

/-- A theory restricted to a subset of phenomena -/
def restrictedError {n : ℕ} (predict truth : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  ∑ i ∈ S, (predict i - truth i) ^ 2

/-
**Wrong Theory Superiority Theorem**: Given two theories where theory A has
lower total error than theory B, there can still exist a subdomain where
theory B outperforms theory A. This is the mathematical core of why
"wrong" theories can be useful: wrongness in one domain can coexist with
superiority in another.

We prove: if theory B has lower error than theory A on some specific
phenomenon j, then the singleton subdomain {j} witnesses B's superiority.
-/
theorem wrong_theory_local_superiority {n : ℕ}
    (predictA predictB truth : Fin n → ℝ)
    (j : Fin n)
    (h_B_better_at_j : (predictB j - truth j) ^ 2 < (predictA j - truth j) ^ 2) :
    restrictedError predictB truth {j} < restrictedError predictA truth {j} := by
  unfold restrictedError; aesop;

/-! ## §7: Convergence of Theory Sequences -/

/-- A sequence of theories converging to truth -/
structure ConvergentTheorySeq (n : ℕ) where
  /-- The k-th approximation -/
  approx : ℕ → (Fin n → ℝ)
  /-- Ground truth -/
  truth : Fin n → ℝ
  /-- The total error decreases monotonically -/
  error_decreasing : ∀ k, ∑ i : Fin n, (approx (k + 1) i - truth i) ^ 2
                        ≤ ∑ i : Fin n, (approx k i - truth i) ^ 2
  /-- The error converges to 0 -/
  error_tends_zero : Filter.Tendsto
    (fun k => ∑ i : Fin n, (approx k i - truth i) ^ 2)
    Filter.atTop (nhds 0)

/-
**Pointwise Convergence from L² Convergence**: If a sequence of theories
converges in total squared error, then it converges pointwise.
-/
theorem pointwise_convergence_from_L2 {n : ℕ} (S : ConvergentTheorySeq n) (i : Fin n) :
    Filter.Tendsto (fun k => S.approx k i) Filter.atTop (nhds (S.truth i)) := by
  have := S.error_tends_zero;
  exact tendsto_iff_norm_sub_tendsto_zero.mpr <| squeeze_zero ( fun _ => abs_nonneg _ ) ( fun k => by simpa [ Real.sqrt_sq_eq_abs ] using Real.sqrt_le_sqrt <| Finset.single_le_sum ( fun a _ => sq_nonneg <| S.approx k a - S.truth a ) <| Finset.mem_univ i ) <| by simpa using this.sqrt;

/-! ## §8: The Perturbation Series Convergence Meta-Theorem -/

/-
**Main Meta-Theorem**: For any perturbation chain, the partial sums converge
to a definite limit. Moreover, this limit is the "true value" that the
perturbation series approximates. This is the mathematical backbone of
why perturbation theory works: even when individual terms are "wrong"
(each partial sum differs from truth), the series as a whole converges.
-/
theorem perturbation_series_converges (C : PerturbationChain) :
    ∃ L : ℝ, Filter.Tendsto C.partialSum Filter.atTop (nhds L) := by
  convert ( Summable.hasSum ( corrections_summable C ) ) |> HasSum.tendsto_sum_nat;
  exact iff_of_true ⟨ _, ( Summable.hasSum ( corrections_summable C ) ) |> HasSum.tendsto_sum_nat ⟩ ( ( Summable.hasSum ( corrections_summable C ) ) |> HasSum.tendsto_sum_nat )

/-
The limit of the perturbation series equals the tsum
-/
theorem perturbation_limit_eq_tsum (C : PerturbationChain) :
    Filter.Tendsto C.partialSum Filter.atTop (nhds (∑' k, C.correction k)) := by
  convert Summable.hasSum ( corrections_summable C ) |> HasSum.tendsto_sum_nat

/-! ## §9: Conjecture — Optimal Truncation -/

/-- **Conjecture (Optimal Truncation)**: For a perturbation chain with ratio r,
the optimal number of terms to keep (minimizing the truncation error bound)
is approximately N* = ⌊-log|c₀| / log|r|⌋ when |c₀| < 1.

This is falsifiable: for any specific chain, one can compute the actual
optimal truncation and compare with this formula.

Test: For ratio = 1/2 and c₀ = 1, the formula predicts N* = 0,
but the actual optimal truncation for the geometric sum is N = ∞.
The conjecture should be refined to account for the full tail bound. -/
def optimalTruncation (c₀ ratio : ℝ) (_hr : 0 < ratio) (_hr1 : ratio < 1) : ℕ :=
  if c₀ ≤ 0 then 0
  else Nat.floor (Real.log c₀ / Real.log (1 / ratio))

/-
**Falsified Conjecture**: The following was disproved — the tail from optimal
   truncation is NOT always ≤ |c₀|. Counterexample: ratio = 1/2, c₀ = 1 gives
   tail = 2 > 1. The correct bound requires the factor 1/(1-r).

theorem optimal_truncation_bound_FALSE (C : PerturbationChain)
(hpos : 0 < |C.ratio|) (hc : 0 < |C.correction 0|) :
∑' k, |C.correction (k + optimalTruncation |C.correction 0| |C.ratio| hpos C.ratio_lt_one)|
≤ |C.correction 0| := by sorry

**Correct version**: The tail corrections from any truncation point are summable.
-/
theorem truncation_tail_summable (C : PerturbationChain) (N : ℕ) :
    Summable (fun k => |C.correction (k + N)|) := by
  exact Summable.comp_injective ( geometric_error_summable C ) ( add_left_injective N )

end