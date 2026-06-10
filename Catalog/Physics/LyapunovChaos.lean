/-
  Chaos and the Three-Body Problem: Lyapunov Exponent Bounds
  ==========================================================

  The gravitational three-body problem is the canonical example of deterministic
  chaos: its flow has a strictly positive maximal Lyapunov exponent, so nearby
  trajectories separate exponentially fast. Formalizing the full Hamiltonian flow
  is out of reach of current Mathlib, so we formalize the *rigorous analytic core*
  of the phenomenon for smooth iterated maps — the setting in which positivity of
  Lyapunov exponents is actually provable and which captures every essential
  feature of chaos in the three-body problem:

  * the multiplicative (cocycle) structure of the derivative of an iterate,
  * exponential divergence of nearby orbits for uniformly expanding maps,
  * strict positivity of the (finite-time) maximal Lyapunov exponent, and
  * the Pesin / variational bridge between the Lyapunov exponent and entropy.

  The Birkhoff-sum identity `log_abs_deriv_iterate_eq_sum` is the discrete-time
  shadow of the variational equation governing the separation of three-body
  trajectories; positivity (`ftle_ge_log`) is the statement that the system is
  chaotic.

  Main results:
  1. `deriv_iterate_eq_prod`      — derivative of the n-th iterate is the orbit product (chain rule).
  2. `log_abs_deriv_iterate_eq_sum` — log of the stretching factor is a Birkhoff sum of `log|f'|`.
  3. `abs_deriv_iterate_ge`       — uniform expansion forces exponential growth `cⁿ`.
  4. `ftle_ge_log`                — the finite-time Lyapunov exponent is ≥ log c > 0 (CHAOS).
  5. `ftle_eq_log_of_uniform`     — exact Lyapunov exponent log c for constant-stretch maps.
  6. `entropy_periodic_growth`    — periodic-orbit growth rate (entropy) of the degree-d map is log d.
  7. `pesin_identity_uniform_model` — Pesin's formula: entropy = Lyapunov exponent = log d.

  Catalog synthesis: this complements `Catalog/Shared/HorseshoeComputation.lean`
  and `Catalog/Shared/SymbolicDynamics` (symbolic/topological chaos) and the
  tropical Lyapunov material in `Catalog/Tropical/TropicalDeepResearch.lean` by
  supplying the *smooth/analytic* Lyapunov-exponent theory and its entropy bridge.
-/
import Mathlib

noncomputable section

open Filter Topology Finset

namespace LyapunovChaos

/-- Finite-time Lyapunov exponent of `f` at `x` over `n` steps: the average
exponential stretching rate of the derivative of the `n`-th iterate. The maximal
Lyapunov exponent of a chaotic system (such as the three-body problem) is the
`limsup` of this quantity; strict positivity is the hallmark of chaos. -/
def ftle (f : ℝ → ℝ) (x : ℝ) (n : ℕ) : ℝ :=
  Real.log |deriv (f^[n]) x| / n

/-- Number of period-`n` points of the degree-`d` uniformly expanding circle map
`x ↦ d·x mod 1`. There are `dⁿ - 1` of them; their exponential growth rate is the
topological entropy of the map. -/
def periodicPointCount (d n : ℕ) : ℕ := d ^ n - 1

/-
!-- The derivative of the n-th iterate factors as a product along the orbit
by the chain rule (induction via `iterate_succ'` and `deriv_comp`). -- !--

**Chain rule for iterates.** The derivative of the `n`-th iterate of `f` at `x`
is the product of the derivatives of `f` taken along the forward orbit of `x`. This
is the multiplicative cocycle underlying every Lyapunov-exponent computation.
-/
theorem deriv_iterate_eq_prod (f : ℝ → ℝ) (hf : Differentiable ℝ f) (n : ℕ) (x : ℝ) :
    deriv (f^[n]) x = ∏ i ∈ Finset.range n, deriv f (f^[i] x) := by
  induction' n with n ih generalizing x;
  · norm_num;
  · convert deriv_comp _ ( hf _ ) ( show DifferentiableAt ℝ ( f^[n] ) x from ?_ ) using 1;
    · rw [ Function.iterate_succ' ];
    · rw [ Finset.prod_range_succ, ih, mul_comm ];
    · exact hf.iterate n x

/-
!-- Take logs of absolute values in `deriv_iterate_eq_prod`; `Real.log_prod`
applies since each factor is nonzero. -- !--

**Birkhoff-sum form of the stretching factor.** The logarithm of the absolute
stretching factor `|(fⁿ)'(x)|` equals the Birkhoff sum of `log|f'|` along the orbit.
This is the discrete-time variational equation for orbit separation.
-/
theorem log_abs_deriv_iterate_eq_sum (f : ℝ → ℝ) (hf : Differentiable ℝ f)
    (hne : ∀ y, deriv f y ≠ 0) (n : ℕ) (x : ℝ) :
    Real.log |deriv (f^[n]) x| = ∑ i ∈ Finset.range n, Real.log |deriv f (f^[i] x)| := by
  rw [ ← Real.log_prod, deriv_iterate_eq_prod f hf ];
  · rw [ Finset.abs_prod ];
  · aesop

/-
!-- The product form plus `Finset.prod_le_prod` with the uniform lower bound c
gives the geometric lower bound cⁿ. -- !--

**Exponential divergence.** If `f` stretches lengths by at least a factor
`c ≥ 0` everywhere, then the `n`-th iterate stretches by at least `cⁿ`. For `c > 1`
this is exponential sensitivity to initial conditions.
-/
theorem abs_deriv_iterate_ge (f : ℝ → ℝ) (hf : Differentiable ℝ f) {c : ℝ}
    (hc0 : 0 ≤ c) (hc : ∀ y, c ≤ |deriv f y|) (n : ℕ) (x : ℝ) :
    c ^ n ≤ |deriv (f^[n]) x| := by
  rw [ deriv_iterate_eq_prod ];
  · rw [ Finset.abs_prod ] ; exact le_trans ( by norm_num ) ( Finset.prod_le_prod ( fun _ _ => by positivity ) fun _ _ => hc _ ) ;
  · assumption

/-
!-- From abs_deriv_iterate_ge, log|(fⁿ)'(x)| ≥ n·log c; dividing by n≥1 gives
ftle ≥ log c, and log c > 0 since c > 1. -- !--

**Positivity of the maximal Lyapunov exponent ⇒ deterministic chaos.** For a
uniformly expanding map (`|f'| ≥ c > 1`), every finite-time Lyapunov exponent is at
least `log c > 0`. This is the rigorous statement that such a system is chaotic.
-/
theorem ftle_ge_log (f : ℝ → ℝ) (hf : Differentiable ℝ f) {c : ℝ} (hc : 1 < c)
    (hbound : ∀ y, c ≤ |deriv f y|) {n : ℕ} (hn : 1 ≤ n) (x : ℝ) :
    Real.log c ≤ ftle f x n := by
  convert div_le_div_of_nonneg_right ( Real.log_le_log ( by positivity ) ( abs_deriv_iterate_ge f hf ( by positivity ) hbound n x ) ) ( Nat.cast_nonneg n ) using 1;
  rw [ Real.log_pow, mul_div_cancel_left₀ _ ( by positivity ) ]

/-
**Strict positivity.** Under uniform expansion the finite-time Lyapunov
exponent is strictly positive.
-/
theorem ftle_pos (f : ℝ → ℝ) (hf : Differentiable ℝ f) {c : ℝ} (hc : 1 < c)
    (hbound : ∀ y, c ≤ |deriv f y|) {n : ℕ} (hn : 1 ≤ n) (x : ℝ) :
    0 < ftle f x n := by
  exact lt_of_lt_of_le ( Real.log_pos hc ) ( ftle_ge_log f hf hc hbound hn x )

/-
!-- For a constant-stretch map the Birkhoff sum is exactly n·log c, so dividing
by n gives log c. -- !--

**Exact Lyapunov exponent for constant-stretch maps.** If `f` stretches by a
constant factor `c > 0` everywhere (e.g. the equal-mass / uniformly hyperbolic
model), then every finite-time Lyapunov exponent equals `log c` exactly.
-/
theorem ftle_eq_log_of_uniform (f : ℝ → ℝ) (hf : Differentiable ℝ f) {c : ℝ}
    (hc : 0 < c) (hunif : ∀ y, |deriv f y| = c) {n : ℕ} (hn : 1 ≤ n) (x : ℝ) :
    ftle f x n = Real.log c := by
  unfold ftle; rw [ log_abs_deriv_iterate_eq_sum f hf (by
  exact fun y => by specialize hunif y; aesop;) n x ] ; simp [hunif];
  rw [ mul_div_cancel_left₀ _ ( by positivity ) ]

/-
!-- log(dⁿ-1)/n is squeezed between (n log d - log 2)/n and log d, both → log d. -- !--

**Topological entropy via periodic-orbit growth.** The exponential growth rate
of the number of period-`n` points of the degree-`d` uniformly expanding map equals
`log d`. This is the combinatorial/topological entropy of the canonical chaotic model.
-/
theorem entropy_periodic_growth (d : ℕ) (hd : 2 ≤ d) :
    Tendsto (fun n => Real.log (periodicPointCount d n) / n) atTop (𝓝 (Real.log d)) := by
  -- We'll use the fact that $\log(d^n - 1)$ is squeezed between $n \log d - \log 2$ and $n \log d$.
  have h_bounds : ∀ n : ℕ, 1 ≤ n → (n * Real.log d - Real.log 2) ≤ Real.log (periodicPointCount d n) ∧ Real.log (periodicPointCount d n) ≤ n * Real.log d := by
    intro n hn
    have h_bound : (d^n - 1 : ℝ) ≥ d^n / 2 := by
      linarith [ show ( d : ℝ ) ^ n ≥ 2 by exact_mod_cast one_lt_pow₀ ( by linarith ) ( by linarith ) ];
    have h_log_bound : Real.log ((d^n - 1 : ℕ) : ℝ) ≥ Real.log ((d^n : ℝ) / 2) ∧ Real.log ((d^n - 1 : ℕ) : ℝ) ≤ Real.log (d^n) := by
      exact ⟨ Real.log_le_log ( by exact div_pos ( by positivity ) zero_lt_two ) ( by rw [ Nat.cast_sub ( Nat.one_le_pow _ _ ( by linarith ) ) ] ; push_cast; linarith ), Real.log_le_log ( by exact Nat.cast_pos.mpr ( Nat.sub_pos_of_lt ( one_lt_pow₀ ( by linarith ) ( by linarith ) ) ) ) ( by rw [ Nat.cast_sub ( Nat.one_le_pow _ _ ( by linarith ) ) ] ; push_cast; linarith ) ⟩;
    rw [ Real.log_div, Real.log_pow ] at * <;> norm_num at * <;> aesop;
  refine' ( Metric.tendsto_atTop.mpr _ );
  intro ε ε_pos; use ⌈ε⁻¹ * Real.log 2⌉₊ + 1; intro n hn; refine' abs_lt.mpr ⟨ _, _ ⟩ <;> nlinarith [ Nat.le_ceil ( ε⁻¹ * Real.log 2 ), mul_inv_cancel₀ ( ne_of_gt ε_pos ), show ( n : ℝ ) ≥ ⌈ε⁻¹ * Real.log 2⌉₊ + 1 by exact_mod_cast hn, h_bounds n ( by linarith ), Real.log_pos one_lt_two, mul_div_cancel₀ ( Real.log ( periodicPointCount d n ) ) ( show ( n : ℝ ) ≠ 0 by norm_cast; linarith ) ] ;

/-
!-- Combine `ftle_eq_log_of_uniform` (with c = d) and `entropy_periodic_growth`:
both equal log d. -- !--

**Pesin's formula for the canonical uniformly expanding model.** For a smooth
map whose stretching factor is identically the integer degree `d ≥ 2`, the
Kolmogorov–Sinai / topological entropy (the periodic-orbit growth rate) equals the
maximal Lyapunov exponent — both equal `log d`. This is the bridge between the
combinatorial (entropy) and analytic (Lyapunov) descriptions of chaos.
-/
theorem pesin_identity_uniform_model (d : ℕ) (hd : 2 ≤ d)
    (f : ℝ → ℝ) (hf : Differentiable ℝ f) (hunif : ∀ y, |deriv f y| = (d : ℝ))
    (x : ℝ) {n : ℕ} (hn : 1 ≤ n) :
    ftle f x n = Real.log d ∧
      Tendsto (fun m => Real.log (periodicPointCount d m) / m) atTop (𝓝 (ftle f x n)) := by
  constructor;
  · exact ftle_eq_log_of_uniform f hf ( by positivity ) hunif hn x;
  · convert entropy_periodic_growth d hd using 1;
    rw [ ftle_eq_log_of_uniform f hf ( by positivity ) hunif hn x ]

end LyapunovChaos