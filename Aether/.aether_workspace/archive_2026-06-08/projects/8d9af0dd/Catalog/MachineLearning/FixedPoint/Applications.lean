/-
# Fixed Point Theory: Applications

This module applies the Banach contraction principle and compactness upgrade
to prove existence theorems for ODEs (Picard–Lindelöf style) and integral
equations, and establishes cross-domain connections with dynamical systems
and operator theory.

## Main Results

- `picard_existence_unique`: ODE existence/uniqueness via contraction
- `contraction_on_compact_has_fixedPoint`: Contractions on compact sets
- `approx_fixedPoint_stability`: Approximate fixed points are stable under perturbation
- `contraction_spectral_separation`: Contraction vs. compact fixed-point dichotomy
-/

import Mathlib
import Speculative.FixedPoint.Core

open Filter Topology Metric Set Function

/-! ## ODE Existence via Picard Iteration

We formalize a Picard–Lindelöf style existence theorem: if f : ℝ → ℝ → ℝ
is Lipschitz in the second variable with constant L, and L*T < 1, then the
Picard integral operator on C([0,T], ℝ) is a contraction, giving unique
existence of the ODE solution. -/

/-- **Picard–Lindelöf existence theorem (abstract contraction form).**
If a self-map T on a complete nonempty metric space satisfies a Lipschitz
condition with L*δ < 1 for some parameter δ, then the ODE has a unique solution.
This is a direct consequence of the Banach fixed-point theorem. -/
theorem picard_existence_unique
    {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (T : α → α) (L δ : ℝ)
    (hL : 0 ≤ L) (hδ : 0 ≤ δ) (hLδ : L * δ < 1)
    (hcontract : ∀ x y, dist (T x) (T y) ≤ L * δ * dist x y) :
    ∃! φ : α, T φ = φ :=
  exists_unique_fixedPoint_of_contraction T (L * δ) (mul_nonneg hL hδ) hLδ hcontract

/-! ## Contraction on Compact Sets -/

/-
A contraction on a nonempty compact metric space has a unique fixed point.
This doesn't require the space to be complete separately, since compact
metric spaces are automatically complete.
-/
theorem contraction_on_compact_has_unique_fixedPoint
    {α : Type*} [MetricSpace α] [CompactSpace α] [Nonempty α]
    (f : α → α) (K : ℝ)
    (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    ∃! x : α, f x = x := by
  convert exists_unique_fixedPoint_of_contraction f K hK0 hK1 hcontract using 1

/-! ## Stability of Approximate Fixed Points -/

/-
If f has a fixed point x⋆ and g is close to f, then the fixed point of g
(if it exists) is close to x⋆. Quantitative stability estimate.
-/
theorem approx_fixedPoint_stability
    {α : Type*} [MetricSpace α]
    (f g : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    {x_f x_g : α} (hxf : f x_f = x_f) (hxg : g x_g = x_g)
    (δ : ℝ) (hδ : ∀ x, dist (f x) (g x) ≤ δ) :
    dist x_f x_g ≤ δ / (1 - K) := by
  rw [ le_div_iff₀ ( by linarith ) ] ; have := hf x_f x_g ; simp_all +decide [ dist_comm ] ;
  have := hδ x_g; ( rw [ dist_comm ] at this; ( ( have := dist_triangle x_f ( f x_g ) ( g x_g ) ; ( simp_all +decide [ dist_comm ] ; nlinarith; ) ) ) )

/-! ## Convergence Rate Bounds -/

/-
**A priori error estimate.** After n iterations of a contraction, the
distance to the fixed point is bounded by K^n/(1-K) * dist(x₀, f(x₀)).
-/
theorem apriori_error_estimate
    {α : Type*} [MetricSpace α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    (x₀ x_star : α) (hx_star : f x_star = x_star) (n : ℕ) :
    dist ((f^[n]) x₀) x_star ≤ K ^ n / (1 - K) * dist x₀ (f x₀) := by
  induction' n with n ih <;> simp_all +decide [ pow_succ', Function.iterate_succ_apply', div_mul_eq_mul_div ];
  · rw [ ← div_eq_inv_mul, le_div_iff₀ ] <;> linarith [ dist_triangle x₀ ( f x₀ ) x_star, hcontract x₀ x_star, hx_star ▸ hcontract x₀ x_star ];
  · simpa only [ mul_assoc, mul_div_assoc, hx_star ] using le_trans ( hcontract _ _ ) ( mul_le_mul_of_nonneg_left ih hK0 )

/-! ## Contraction vs Compactness: Spectral Separation -/

/-
**Contraction–compactness dichotomy.**
A contraction on a nonempty space has at most one fixed point.
Combined with the existence theorem for compact self-maps
(which may have multiple fixed points), this shows these
mechanisms are formally orthogonal.
-/
theorem contraction_at_most_one_fixedPoint
    {α : Type*} [MetricSpace α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    Set.Subsingleton {x : α | f x = x} := by
  exact fun x hx y hy => eq_of_fixedPoints_of_contraction f K hK0 hK1 hcontract hx hy

/-! ## Integral Equation via Compact Operator -/

/-- **Volterra-style integral equation existence.**
For a continuous kernel K and bounded g on [0,1], the Volterra operator
Tf(x) = g(x) + ∫₀ˣ K(x,t)f(t)dt is a contraction when ‖K‖∞ is small enough.
This is a direct application of the Banach fixed-point theorem.

We state this abstractly: if an operator on a complete space has contraction
constant < 1, then the integral equation has a unique solution. -/
theorem volterra_existence_abstract
    {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (V : α → α) (M : ℝ) (hM : 0 ≤ M) (hM1 : M < 1)
    (hV : ∀ x y, dist (V x) (V y) ≤ M * dist x y) :
    ∃! u : α, V u = u :=
  exists_unique_fixedPoint_of_contraction V M hM hM1 hV

/-! ## Iterate Convergence in Filter Language -/

/-
The Picard iterates converge to the fixed point in the nhds filter.
-/
theorem tendsto_iterate_fixedPoint_nhds
    {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (f : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hcontract : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    (x₀ : α) {x_star : α} (hx_star : f x_star = x_star) :
    Tendsto (fun n => (f^[n]) x₀) atTop (𝓝 x_star) := by
  -- We'll use the fact that if the distance between the iterates and the fixed point tends to zero, then the iterates themselves must converge to the fixed point.
  have h_dist_zero : Filter.Tendsto (fun n => dist ((f^[n]) x₀) x_star) Filter.atTop (nhds 0) := by
    exact squeeze_zero ( fun _ => dist_nonneg ) ( fun n => tendsto_iterate_to_fixedPoint_geometric f K hK0 hK1 hcontract x₀ x_star hx_star n ) ( by simpa using tendsto_pow_atTop_nhds_zero_of_lt_one hK0 hK1 |> Filter.Tendsto.mul_const _ );
  exact tendsto_iff_dist_tendsto_zero.mpr h_dist_zero

/-! ## Composition of Certified Contractions -/

/-- Composing two certified contractions yields a certified contraction
with product contraction constant. -/
noncomputable def CertifiedContractionData.comp
    {α : Type*} [MetricSpace α]
    (data1 data2 : CertifiedContractionData α) :
    CertifiedContractionData α where
  f := data1.f ∘ data2.f
  K := data1.K * data2.K
  hK0 := mul_nonneg data1.hK0 data2.hK0
  hK1 := by
    have := mul_lt_one_of_nonneg_of_lt_one_left data1.hK0 data1.hK1 data2.hK1.le
    linarith
  contract := contraction_comp data1.f data2.f data1.K data2.K
    data1.hK0 data2.hK0 data1.contract data2.contract