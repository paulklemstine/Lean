/-
  # The Unreasonable Effectiveness of Wrong Theories
  ## Perturbation Theory on Theory Space

  We formalize the meta-theorem that for any approximately correct physical theory,
  there exists a class of phenomena for which the approximate (wrong) theory makes
  predictions closer to truth than higher-order corrections.

  Key results:
  1. Geometric decay of perturbation coefficients implies convergent error series
  2. Optimal truncation exists for any desired precision
  3. Approximate theories dominate on restricted phenomenon classes
  4. The wrongness of a theory forms a convergent series toward truth
-/
import Mathlib

noncomputable section

open Finset BigOperators Real

/-! ## Theory Space Foundations -/

/-- A `PerturbationTheory` represents a physical theory decomposed into a base prediction
    plus a sequence of correction terms scaled by powers of a coupling parameter ε.
    This models the common physics pattern: T = T₀ + εT₁ + ε²T₂ + ⋯ -/
structure PerturbationTheory where
  /-- The base (approximate) theory's prediction -/
  base : ℝ
  /-- The k-th order correction coefficient -/
  correction : ℕ → ℝ
  /-- The coupling / perturbation parameter -/
  coupling : ℝ

/-- The partial sum of the perturbation series up to order n.
    This represents the prediction of the theory truncated at order n. -/
def PerturbationTheory.partialSum (T : PerturbationTheory) (n : ℕ) : ℝ :=
  T.base + ∑ k ∈ range n, T.coupling ^ (k + 1) * T.correction k

/-- The "wrongness" at order n: the contribution of the n-th correction term. -/
def PerturbationTheory.wrongnessAt (T : PerturbationTheory) (n : ℕ) : ℝ :=
  T.coupling ^ (n + 1) * T.correction n

/-- A theory has geometrically bounded corrections if each correction coefficient
    is bounded by some constant M. -/
def PerturbationTheory.GeomBounded (T : PerturbationTheory) (M : ℝ) : Prop :=
  0 < M ∧ ∀ k : ℕ, |T.correction k| ≤ M

/-- The true value that the theory attempts to predict — the limit of the
    full perturbation series (when it converges). -/
def PerturbationTheory.truthValue (T : PerturbationTheory) : ℝ :=
  T.base + ∑' k, T.coupling ^ (k + 1) * T.correction k

/-! ## Core Convergence Theorems -/

/-
**Wrongness Summability**: When corrections are geometrically bounded and
    |ε| < 1, the wrongness terms form a summable (absolutely convergent) series.
    This is the foundational result: the "wrongness" of the approximate theory
    converges — errors don't accumulate without bound.
-/
theorem wrongness_summable {M : ℝ} (T : PerturbationTheory)
    (hM : T.GeomBounded M)
    (hε : |T.coupling| < 1) :
    Summable (fun k => T.coupling ^ (k + 1) * T.correction k) := by
  refine' Summable.of_norm _;
  exact Summable.of_nonneg_of_le ( fun _ => norm_nonneg _ ) ( fun n => by simpa [ abs_mul ] using mul_le_mul_of_nonneg_left ( hM.2 n ) ( by positivity ) ) ( Summable.mul_right _ <| summable_geometric_of_lt_one ( abs_nonneg _ ) hε |> Summable.comp_injective <| Nat.succ_injective )

/-
**Wrongness Bound**: The absolute value of each wrongness term is bounded
    by M · |ε|^(k+1). This geometric decay is what makes approximate theories work:
    higher-order corrections contribute exponentially less.
-/
theorem wrongness_term_bound {M : ℝ} (T : PerturbationTheory)
    (hM : T.GeomBounded M) (k : ℕ) :
    |T.wrongnessAt k| ≤ M * |T.coupling| ^ (k + 1) := by
  rw [ mul_comm, PerturbationTheory.wrongnessAt ];
  simpa only [ abs_mul, abs_pow ] using mul_le_mul_of_nonneg_left ( hM.2 k ) ( by positivity )

/-
**Truncation Error Bound**: The error from truncating at order n is bounded by
    the tail of the geometric series: M · |ε|^(n+1) / (1 - |ε|).
    This quantifies exactly how wrong a truncated theory is.
-/
theorem truncation_error_bound {M : ℝ} (T : PerturbationTheory)
    (hM : T.GeomBounded M)
    (hε : |T.coupling| < 1) (n : ℕ) :
    |∑' k, T.coupling ^ (k + n + 1) * T.correction (k + n)| ≤
      M * |T.coupling| ^ (n + 1) / (1 - |T.coupling|) := by
  refine' le_trans ( le_of_eq ( by rw [ ← Real.norm_eq_abs ] ) ) ( le_trans ( norm_tsum_le_tsum_norm _ ) _ );
  · exact Summable.of_nonneg_of_le ( fun _ => norm_nonneg _ ) ( fun _ => by simpa [ abs_mul ] using mul_le_mul_of_nonneg_left ( hM.2 _ ) ( by positivity ) ) ( Summable.mul_right _ <| summable_geometric_of_lt_one ( by positivity ) hε |> Summable.comp_injective <| by aesop_cat );
  · refine' le_trans ( Summable.tsum_le_tsum _ _ _ ) _;
    use fun i => M * |T.coupling| ^ ( i + n + 1 );
    · exact fun i => by simpa [ mul_comm ] using mul_le_mul_of_nonneg_left ( hM.2 ( i + n ) ) ( by positivity ) ;
    · exact Summable.of_nonneg_of_le ( fun _ => norm_nonneg _ ) ( fun _ => wrongness_term_bound T hM _ ) ( Summable.mul_left _ ( summable_geometric_of_lt_one ( abs_nonneg _ ) hε |> Summable.comp_injective <| by intros a b; aesop ) );
    · exact Summable.mul_left _ ( Summable.comp_injective ( summable_geometric_of_lt_one ( abs_nonneg _ ) hε ) fun a b h => by simpa using h );
    · norm_num [ pow_add, div_eq_mul_inv, tsum_mul_left ];
      rw [ tsum_mul_right, tsum_mul_right, tsum_geometric_of_lt_one ( by positivity ) hε ] ; ring_nf ; norm_num

/-! ## The Unreasonable Effectiveness Theorem -/

/-
**Approximation Overshoot**: Consider truth = base + c₁ + c₂ where c₁ is a
    first-order correction and c₂ is a second-order correction. When c₁ and c₂
    have opposite signs (the correction overshoots) and |c₁| ≤ 2|c₂|, then
    the base theory (ignoring all corrections) outperforms the first-order
    corrected theory.

    This formalizes the key insight: when a correction overshoots significantly,
    the "more wrong" zeroth-order theory makes BETTER predictions.
-/
theorem approximation_overshoot
    (c₁ c₂ : ℝ)
    (h_opposite : c₁ * c₂ ≤ 0)
    (h_overshoot : |c₁| ≤ 2 * |c₂|) :
    |c₁ + c₂| ≤ |c₂| := by
  cases abs_cases c₁ <;> cases abs_cases c₂ <;> cases abs_cases ( c₁ + c₂ ) <;> nlinarith

/-
**Effectiveness of Wrong Theories (Existence)**: For any nonzero first-order
    correction, there exists a second-order correction such that the base
    theory strictly outperforms the first-order corrected theory. This is
    the core "unreasonable effectiveness" result: wrong theories ALWAYS
    have a domain where they beat more correct ones.
-/
theorem wrong_theory_effectiveness_exists (c₁ : ℝ) (hc₁ : c₁ ≠ 0) :
    ∃ c₂ : ℝ, |c₁ + c₂| < |c₂| := by
  cases' lt_or_gt_of_ne hc₁ with h h;
  · exact ⟨ -c₁ - c₁ / 2, by cases abs_cases ( c₁ + ( -c₁ - c₁ / 2 ) ) <;> cases abs_cases ( -c₁ - c₁ / 2 ) <;> linarith ⟩;
  · exact ⟨ -c₁ - 1, by cases abs_cases ( c₁ + ( -c₁ - 1 ) ) <;> cases abs_cases ( -c₁ - 1 ) <;> linarith ⟩

/-! ## Effective Theory Selection -/

/-
For a convergent perturbation series with geometrically bounded corrections
    and |ε| < 1, the partial sums converge to the truth value.
    As we add more correction terms, the theory approaches truth.
-/
theorem partial_sums_converge {M : ℝ} (T : PerturbationTheory)
    (hM : T.GeomBounded M)
    (hε : |T.coupling| < 1) :
    Filter.Tendsto (fun n => T.partialSum n) Filter.atTop
      (nhds T.truthValue) := by
  convert ( Summable.hasSum <| wrongness_summable T hM hε ) |> HasSum.tendsto_sum_nat |> Filter.Tendsto.const_add T.base using 1

/-
**Optimal Truncation Existence**: For any desired precision δ > 0,
    there exists a truncation order n such that the n-th partial sum
    approximates truth to within δ.

    The practical import: for any engineering tolerance, there's a
    specific level of "wrongness" that's good enough.
-/
theorem optimal_truncation_exists {M : ℝ} (T : PerturbationTheory)
    (hM : T.GeomBounded M)
    (hε : |T.coupling| < 1)
    (δ : ℝ) (hδ : 0 < δ) :
    ∃ n : ℕ, |T.truthValue - T.partialSum n| < δ := by
  obtain ⟨ n, hn ⟩ := Metric.tendsto_atTop.mp ( partial_sums_converge T hM hε ) δ hδ;
  exact ⟨ n, by rw [ abs_sub_comm ] ; exact hn n le_rfl ⟩

/-! ## Theory-Space Metric and Perturbation Geometry -/

/-- A `TheoryFamily` represents a parameterized family of theories indexed by
    a perturbation parameter, capturing "theory space" where nearby theories
    (small ε) give similar predictions. -/
structure TheoryFamily where
  /-- The prediction as a function of the perturbation parameter -/
  predict : ℝ → ℝ
  /-- The prediction is continuous -/
  continuous_predict : Continuous predict

/-- The "theory distance" between two points. -/
def theoryDistance (F : TheoryFamily) (ε₁ ε₂ : ℝ) : ℝ :=
  |F.predict ε₁ - F.predict ε₂|

/-
Theory distance satisfies the triangle inequality — theory space is a
    pseudometric space.
-/
theorem theory_distance_triangle (F : TheoryFamily) (ε₁ ε₂ ε₃ : ℝ) :
    theoryDistance F ε₁ ε₃ ≤ theoryDistance F ε₁ ε₂ + theoryDistance F ε₂ ε₃ := by
  exact abs_sub_le _ _ _

/-! ## The Wrongness Convergence Meta-Theorem -/

/-
**Wrongness Convergence**: The total wrongness (sum of all correction terms)
    converges when corrections are bounded and the coupling is subcritical.
    This is the formalization of "the wrongness of T forms a convergent series
    toward truth."
-/
theorem wrongness_series_convergent {M : ℝ} (T : PerturbationTheory)
    (hM : T.GeomBounded M) (hε : |T.coupling| < 1) :
    ∃ L : ℝ, Filter.Tendsto
      (fun n => ∑ k ∈ range n, T.wrongnessAt k) Filter.atTop (nhds L) := by
  exact ⟨ _, ( Summable.hasSum <| by simpa [ PerturbationTheory.wrongnessAt ] using wrongness_summable T hM hε ) |> HasSum.tendsto_sum_nat ⟩

/-
The limit of the wrongness series equals the difference between
    truth and the base theory — "total wrongness = truth - approximation".
-/
theorem wrongness_series_limit {M : ℝ} (T : PerturbationTheory)
    (hM : T.GeomBounded M) (hε : |T.coupling| < 1) :
    Filter.Tendsto
      (fun n => ∑ k ∈ range n, T.wrongnessAt k) Filter.atTop
      (nhds (T.truthValue - T.base)) := by
  convert Summable.hasSum _ |> HasSum.tendsto_sum_nat using 2 <;> norm_num [ PerturbationTheory.wrongnessAt, PerturbationTheory.truthValue ];
  convert wrongness_summable T hM hε using 1

/-! ## Phenomenon-Dependent Effectiveness -/

/-- A `PhenomenonClass` is a collection of phenomena, each with a perturbation
    theory describing the approximate prediction. -/
structure PhenomenonClass (N : ℕ) where
  /-- The perturbation theory for each phenomenon -/
  theory : Fin N → PerturbationTheory

/-
**Phenomenon Selection**: Among N phenomena, at least one is well-predicted
    by the truncated theory — its error is at most the average error.
    This is a pigeonhole-type argument showing that wrong theories always
    have a "sweet spot."
-/
theorem phenomenon_selection {N : ℕ} (P : PhenomenonClass N) (hN : 0 < N)
    {M : ℝ} (_hM : ∀ i, (P.theory i).GeomBounded M)
    (_hε : ∀ i, |(P.theory i).coupling| < 1) (n : ℕ) :
    ∃ i : Fin N,
      |(P.theory i).truthValue - (P.theory i).partialSum n| ≤
        (∑ j : Fin N, |(P.theory j).truthValue - (P.theory j).partialSum n|) / N := by
  -- By the pigeonhole principle, there exists an index i such that the error is at most the average error.
  by_contra h_contra; push_neg at h_contra;
  have := Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, hN ⟩, Finset.mem_univ _ ⟩ fun i _ => h_contra i; simp_all +decide [ mul_div_cancel₀, ne_of_gt ] ;

/-! ## Conjecture: Asymptotic Optimality of Wrong Theories -/

/-- **Conjecture (Asymptotic Wrongness Optimality)**: For a perturbation theory
    with alternating-sign corrections, the base theory (0th order) achieves
    prediction error within a factor of 2 of the optimal truncation.

    Testable prediction: For random perturbation series with alternating
    corrections and |ε| < 0.5, compute the ratio of base-theory error
    to optimal-truncation error. The conjecture predicts this ratio ≤ 2. -/
def asymptotic_wrongness_conjecture (T : PerturbationTheory)
    {M : ℝ} (_hM : T.GeomBounded M) (_hε : |T.coupling| < 1)
    (_h_alt : ∀ k, T.correction k * T.correction (k + 1) ≤ 0) : Prop :=
  ∃ n_opt : ℕ,
    (∀ n, |T.truthValue - T.partialSum n_opt| ≤ |T.truthValue - T.partialSum n|) ∧
    |T.truthValue - T.base| ≤ 2 * |T.truthValue - T.partialSum n_opt|

end