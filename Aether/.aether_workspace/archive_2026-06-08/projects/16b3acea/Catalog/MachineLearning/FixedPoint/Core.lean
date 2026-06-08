/-
# Fixed Point Theory: Core Development

This module develops the quantitative Banach contraction principle from scratch,
introduces certified contraction data structures, and establishes the compactness
upgrade principle that bridges approximate and exact fixed points.

## Main Results

- `iterate_dist_le_geometric`: Geometric decay of distances under iteration
- `eq_of_fixedPoints_of_contraction`: Uniqueness of fixed points
- `cauchySeq_of_contraction_iterates`: Cauchy property of Picard iterates
- `exists_unique_fixedPoint_of_contraction`: Banach fixed-point theorem
- `tendsto_iterate_to_fixedPoint_geometric`: Quantitative convergence rate
- `exists_fixedPoint_of_approx_fixedPoint_compactness`: Compactness upgrade principle
- `brouwer_fixedPoint_Icc`: Brouwer fixed-point theorem in dimension 1
-/

import Mathlib

open Filter Topology Metric Set Function

/-! ## Geometric Decay of Distances Under Iteration -/

/-
Iterates of a contraction map shrink distances geometrically.
-/
theorem iterate_dist_le_geometric
    {α : Type*} [MetricSpace α]
    (f : α → α) (K : ℝ)
    (hK0 : 0 ≤ K)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    ∀ n x y, dist ((f^[n]) x) ((f^[n]) y) ≤ K ^ n * dist x y := by
  intro n x y; induction' n with n ih <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ', mul_assoc ] ;
  exact le_trans ( hcontract _ _ ) ( mul_le_mul_of_nonneg_left ih hK0 )

/-! ## Uniqueness of Fixed Points -/

/-
Two fixed points of a contraction with K < 1 must coincide.
-/
theorem eq_of_fixedPoints_of_contraction
    {α : Type*} [MetricSpace α]
    (f : α → α) (K : ℝ) (_hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    {x y : α} (hx : f x = x) (hy : f y = y) :
    x = y := by
  exact Classical.not_not.1 fun hxy => by have := hcontract x y; rw [ hx, hy ] at this; nlinarith [ dist_pos.2 hxy ] ;

/-! ## Cauchy Sequence from Contraction Iterates -/

/-
The Picard iterates of any contraction map form a Cauchy sequence.
-/
theorem cauchySeq_of_contraction_iterates
    {α : Type*} [PseudoMetricSpace α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    (x₀ : α) :
    CauchySeq (fun n => (f^[n]) x₀) := by
  convert cauchySeq_of_le_geometric _ _ _ _;
  exact K;
  exact dist ( f x₀ ) x₀;
  · exact hK1;
  · intro n; rw [ mul_comm ] ; induction' n with n ih <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ ] ;
    · rw [ dist_comm ];
    · exact le_trans ( hcontract _ _ ) ( by nlinarith )

/-! ## Banach Fixed-Point Theorem -/

/-
**Banach Fixed-Point Theorem (Quantitative).**
Every contraction on a nonempty complete metric space has a unique fixed point.
This is proved by showing the Picard iterates form a Cauchy sequence that
converges to a fixed point.
-/
theorem exists_unique_fixedPoint_of_contraction
    {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (f : α → α) (K : ℝ)
    (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    ∃! x : α, f x = x := by
  -- By the properties of the contraction mapping, the sequence of Picard iterates converges to a fixed point.
  have h_converges : ∀ x₀ : α, ∃ x_star : α, Filter.Tendsto (fun n => (f^[n]) x₀) Filter.atTop (nhds x_star) ∧ f x_star = x_star := by
    intro x₀;
    have h_cauchy : CauchySeq (fun n => (f^[n]) x₀) := by
      convert cauchySeq_of_contraction_iterates f K hK0 hK1 hcontract x₀
    obtain ⟨x_star, hx_star⟩ : ∃ x_star : α, Filter.Tendsto (fun n => (f^[n]) x₀) Filter.atTop (nhds x_star) := by
      exact cauchySeq_tendsto_of_complete h_cauchy
    have h_fixed : f x_star = x_star := by
      have h_fixed_point : Filter.Tendsto (fun n => f ((f^[n]) x₀)) Filter.atTop (nhds (f x_star)) := by
        exact Filter.Tendsto.comp ( show Filter.Tendsto f ( nhds x_star ) ( nhds ( f x_star ) ) from by exact ( Metric.tendsto_nhds_nhds.mpr fun ε hε => by exact ⟨ ε, hε, by intro y hy; exact lt_of_le_of_lt ( hcontract _ _ ) ( by nlinarith ) ⟩ ) ) hx_star;
      exact tendsto_nhds_unique h_fixed_point ( by simpa only [ ← Function.iterate_succ_apply' ] using hx_star.comp ( Filter.tendsto_add_atTop_nat 1 ) )
    use x_star, hx_star, h_fixed;
  obtain ⟨ x_star, hx_star ⟩ := h_converges ( Classical.arbitrary α );
  exact ⟨ x_star, hx_star.2, fun y hy => eq_of_fixedPoints_of_contraction f K hK0 hK1 hcontract hy hx_star.2 ⟩

/-! ## Quantitative Convergence Rate -/

/-
The Picard iterates converge geometrically to the fixed point.
-/
theorem tendsto_iterate_to_fixedPoint_geometric
    {α : Type*} [MetricSpace α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K) (_hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    (x₀ x_star : α) (hx_star : f x_star = x_star) :
    ∀ n : ℕ, dist ((f^[n]) x₀) x_star ≤ K ^ n * dist x₀ x_star := by
  intro n;
  convert iterate_dist_le_geometric f K hK0 hcontract n x₀ x_star using 1 ; simp +decide [ *, Function.iterate_fixed ]

/-! ## Certified Contraction Data -/

/-- A `CertifiedContractionData` bundles a self-map with its contraction constant
and the proof that it is indeed a contraction. This structure enables compositional
reasoning about contraction maps and their algorithmic properties. -/
structure CertifiedContractionData (α : Type*) [MetricSpace α] where
  /-- The contraction map -/
  f : α → α
  /-- The contraction constant -/
  K : ℝ
  /-- The contraction constant is nonnegative -/
  hK0 : 0 ≤ K
  /-- The contraction constant is strictly less than 1 -/
  hK1 : K < 1
  /-- The contraction inequality -/
  contract : ∀ x y, dist (f x) (f y) ≤ K * dist x y

namespace CertifiedContractionData

variable {α : Type*} [MetricSpace α]

/-- A certified contraction has a unique fixed point in a complete nonempty space. -/
theorem exists_unique_fixedPoint [CompleteSpace α] [Nonempty α]
    (data : CertifiedContractionData α) :
    ∃! x : α, data.f x = x :=
  exists_unique_fixedPoint_of_contraction data.f data.K data.hK0 data.hK1 data.contract

/-- The iteration error bound for certified contraction data. -/
theorem iteration_error_bound (data : CertifiedContractionData α)
    (x₀ x_star : α) (hx_star : data.f x_star = x_star) (n : ℕ) :
    dist ((data.f^[n]) x₀) x_star ≤ data.K ^ n * dist x₀ x_star :=
  tendsto_iterate_to_fixedPoint_geometric data.f data.K data.hK0 data.hK1
    data.contract x₀ x_star hx_star n

/-- After n iterations, the error is at most ε if n is large enough. -/
theorem iterations_for_precision (data : CertifiedContractionData α)
    (x₀ x_star : α) (hx_star : data.f x_star = x_star)
    {ε : ℝ} (_hε : 0 < ε) {n : ℕ}
    (hn : data.K ^ n * dist x₀ x_star ≤ ε) :
    dist ((data.f^[n]) x₀) x_star ≤ ε :=
  le_trans (data.iteration_error_bound x₀ x_star hx_star n) hn

end CertifiedContractionData

/-! ## Approximate Fixed Points -/

/-- An ε-approximate fixed point of f is a point x with dist(f(x), x) ≤ ε. -/
def IsApproxFixedPoint {α : Type*} [PseudoMetricSpace α] (f : α → α) (ε : ℝ) (x : α) : Prop :=
  dist (f x) x ≤ ε

/-
An exact fixed point is a 0-approximate fixed point.
-/
theorem isApproxFixedPoint_zero_iff {α : Type*} [MetricSpace α]
    (f : α → α) (x : α) :
    IsApproxFixedPoint f 0 x ↔ f x = x := by
  simp +decide [IsApproxFixedPoint]

/-! ## Compactness Upgrade: Approximate → Exact Fixed Points -/

/-
**Compactness Upgrade Principle.**
If a continuous self-map of a compact set has ε-approximate fixed points
for every ε > 0, then it has an exact fixed point. This is the formal hinge
from Brouwer/Sperner approximation to Schauder.
-/
theorem exists_fixedPoint_of_approx_fixedPoint_compactness
    {α : Type*} [MetricSpace α]
    (K : Set α) (hK_compact : IsCompact K)
    (f : α → α) (hf_cont : Continuous f)
    (_h_maps : MapsTo f K K)
    (happrox : ∀ ε > 0, ∃ x ∈ K, dist (f x) x ≤ ε) :
    ∃ x ∈ K, f x = x := by
  -- By the properties of continuous functions on compact sets, the function g(x) = dist(f(x), x) attains its minimum value on K.
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ ∈ K, ∀ x ∈ K, dist (f x) x ≥ dist (f x₀) x₀ := by
    have h_continuous : ContinuousOn (fun x => dist (f x) x) K := by
      fun_prop;
    exact ( IsCompact.exists_isMinOn hK_compact ( Set.nonempty_of_mem ( happrox 1 zero_lt_one |> Classical.choose_spec |> And.left ) ) h_continuous );
  contrapose! happrox;
  exact ⟨ dist ( f x₀ ) x₀ / 2, half_pos ( dist_pos.mpr ( happrox x₀ hx₀.1 ) ), fun x hx => by linarith [ hx₀.2 x hx, dist_pos.mpr ( happrox x₀ hx₀.1 ) ] ⟩

/-! ## Brouwer Fixed-Point Theorem in Dimension 1 -/

/-
**Brouwer Fixed-Point Theorem (1D).**
Every continuous function mapping [0,1] to [0,1] has a fixed point.
This is proved using the Intermediate Value Theorem.
-/
theorem brouwer_fixedPoint_Icc
    (f : ℝ → ℝ) (hf : Continuous f)
    (h_maps : ∀ x, x ∈ Set.Icc 0 1 → f x ∈ Set.Icc 0 1) :
    ∃ x ∈ Set.Icc 0 1, f x = x := by
  -- By the properties of the intermediate value theorem, since $g(x) = f(x) - x$ is continuous and $g(0) \geq 0$ and $g(1) \leq 0$, there exists some $c \in [0, 1]$ such that $g(c) = 0$, i.e., $f(c) = c$.
  have h_ivt : ∃ c ∈ Set.Icc 0 1, (f c - c) = 0 := by
    apply_rules [ intermediate_value_Icc' ] <;> norm_num [ * ];
    · exact hf.continuousOn.sub continuousOn_id;
    · exact ⟨ h_maps 1 ( by norm_num ) |>.2, h_maps 0 ( by norm_num ) |>.1 ⟩;
  simpa only [ sub_eq_zero ] using h_ivt

/-! ## Schauder Fixed-Point Theorem via Compactness Upgrade -/

/-- **Schauder Fixed-Point Theorem** for compact convex sets.
Every continuous self-map of a nonempty compact convex subset of a
normed space has a fixed point.

Note: The full proof requires Brouwer's fixed-point theorem in finite
dimensions, which is not yet available in Mathlib. We provide the
reduction architecture: the result follows from
`exists_fixedPoint_of_approx_fixedPoint_compactness` once one
establishes that approximate fixed points exist on compact convex sets
(via finite-dimensional Schauder projections + Brouwer). -/
theorem schauder_fixedPoint_of_compact_convex
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (K : Set E)
    (_hK_nonempty : K.Nonempty)
    (_hK_convex : Convex ℝ K)
    (hK_compact : IsCompact K)
    (f : E → E)
    (hf_cont : Continuous f)
    (h_maps : MapsTo f K K)
    /- The following hypothesis is the Brouwer-dependent ingredient.
       It asserts that approximate fixed points exist for every ε > 0.
       This follows from finite-dimensional Brouwer + Schauder projection. -/
    (happrox_fp : ∀ ε > 0, ∃ x ∈ K, dist (f x) x ≤ ε) :
    ∃ x ∈ K, f x = x :=
  exists_fixedPoint_of_approx_fixedPoint_compactness K hK_compact f hf_cont h_maps happrox_fp

/-
**Brouwer Fixed-Point Theorem (1D, general interval).**
Every continuous function mapping [a,b] to [a,b] has a fixed point.
-/
theorem brouwer_fixedPoint_Icc_general
    {a b : ℝ} (hab : a ≤ b)
    (f : ℝ → ℝ) (hf : Continuous f)
    (h_maps : ∀ x, x ∈ Set.Icc a b → f x ∈ Set.Icc a b) :
    ∃ x ∈ Set.Icc a b, f x = x := by
  -- By the properties of the intermediate value theorem, since $g(a) = f(a) - a \geq 0$ and $g(b) = f(b) - b \leq 0$, there exists some $c \in [a, b]$ such that $g(c) = 0$, i.e., $f(c) = c$.
  have h_ivt : ∃ c ∈ Set.Icc a b, (f c - c) = 0 := by
    apply_rules [ intermediate_value_Icc' ];
    · exact hf.continuousOn.sub continuousOn_id;
    · grind;
  simpa only [ sub_eq_zero ] using h_ivt

/-
Contraction maps are Lipschitz continuous.
-/
theorem lipschitzWith_of_contraction
    {α : Type*} [PseudoMetricSpace α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    LipschitzWith ⟨K, hK0⟩ f := by
  exact LipschitzWith.of_dist_le_mul hcontract

/-
The composition of two contractions is a contraction with product constant.
-/
theorem contraction_comp
    {α : Type*} [MetricSpace α]
    (f g : α → α) (Kf Kg : ℝ)
    (hKf0 : 0 ≤ Kf) (_hKg0 : 0 ≤ Kg)
    (hf : ∀ x y, dist (f x) (f y) ≤ Kf * dist x y)
    (hg : ∀ x y, dist (g x) (g y) ≤ Kg * dist x y) :
    ∀ x y, dist ((f ∘ g) x) ((f ∘ g) y) ≤ (Kf * Kg) * dist x y := by
  exact fun x y => by simpa only [ mul_assoc, Function.comp_apply ] using le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ( hg _ _ ) hKf0 ) ;

/-! ## Cross-Domain: Energy Monotonicity at Fixed Points -/

/-
**Lyapunov Principle for Contraction Fixed Points.**
If an energy functional is monotonically non-increasing under a contraction map,
then the fixed point minimizes the energy over all points.
-/
theorem contraction_fixedPoint_energy_minimizer
    {α : Type*} [MetricSpace α] [CompleteSpace α]
    (data : CertifiedContractionData α)
    (E : α → ℝ) (hE_cont : Continuous E)
    (hmono : ∀ x, E (data.f x) ≤ E x)
    {x_star : α} (hx_star : data.f x_star = x_star)
    (_hx_star_limit : ∃ x₀, Tendsto (fun n => (data.f^[n]) x₀) atTop (𝓝 x_star)) :
    ∀ x₀, E x_star ≤ E x₀ := by
  intro x₀
  have h_seq_le : ∀ n : ℕ, E ((data.f^[n]) x₀) ≤ E x₀ := by
    exact fun n => Nat.recOn n ( by simp +decide ) fun n ihn => by simpa only [ Function.iterate_succ_apply' ] using le_trans ( hmono _ ) ihn;
  convert le_of_tendsto_of_tendsto' ( hE_cont.continuousAt.tendsto.comp ( show Filter.Tendsto ( fun n => data.f^[n] x₀ ) Filter.atTop ( nhds x_star ) from ?_ ) ) tendsto_const_nhds h_seq_le;
  have h_seq_conv : ∀ n : ℕ, dist ((data.f^[n]) x₀) x_star ≤ data.K ^ n * dist x₀ x_star := by
    exact fun n => CertifiedContractionData.iteration_error_bound data x₀ x_star hx_star n;
  exact tendsto_iff_dist_tendsto_zero.mpr ( squeeze_zero ( fun _ => dist_nonneg ) h_seq_conv ( by simpa using Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one data.hK0 data.hK1 ) tendsto_const_nhds ) )

/-
Iterates of a monotone-energy contraction produce a non-increasing energy sequence.
-/
theorem energy_nonincreasing_along_iterates
    {α : Type*} [MetricSpace α]
    (f : α → α) (E : α → ℝ)
    (hmono : ∀ x, E (f x) ≤ E x)
    (x₀ : α) :
    ∀ n : ℕ, E ((f^[n + 1]) x₀) ≤ E ((f^[n]) x₀) := by
  exact fun n => by simpa only [ Function.iterate_succ_apply' ] using hmono _;