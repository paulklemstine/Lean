/-
# Tropical Performance Envelopes

Two-sided tropical performance envelopes: a formal bridge theorem showing that
paired min-plus / max-plus certificates produce interval-valued execution laws

    k · lam_min + v_min  ≤  x_k  ≤  k · lam_max + v_max

with direct interpretation as latency lower bounds, throughput upper bounds,
schedulability windows, and robust timing envelopes.

## Key Results

- `step_lower_to_global_lower`: One-step lower drift implies global lower envelope
- `step_upper_to_global_upper`: One-step upper drift implies global upper envelope
- `affine_envelope_of_step_bounds`: Two-sided envelope from one-step drift bounds
- `upper_bound_iff_lower_bound_neg`: Dualization via negation (max-plus ↔ min-plus)
- `envelope_dualization`: Full envelope duality under negation
- `maxplus_recursion_envelope`: Envelope from bounded max-plus recursion
- `network_calculus_backlog_bound`: Backlog bound from service/arrival envelopes

## Cross-domain connections

- **Network calculus**: lower envelope = guaranteed service floor,
  upper envelope = worst-case delay ceiling
- **Control theory**: paired bounds define forward invariant interval tubes
- **Abstract interpretation**: conjunction of bounds = certified safety contract
- **Scheduling**: affine bands certify greedy schedule correctness
-/
import Mathlib

/-!
## One-sided envelope lemmas

These are the building blocks: from one-step drift bounds to global affine bounds.
-/

/-
From a one-step lower drift bound lam ≤ x(n+1) - x(n), we get the global
    lower affine envelope x(0) + k·lam ≤ x(k) for all k.
    This is the min-plus certificate side of the tropical envelope.
-/
theorem step_lower_to_global_lower
    (x : ℕ → ℝ) (lam : ℝ)
    (h : ∀ n : ℕ, lam ≤ x (n+1) - x n) :
    ∀ k : ℕ, x 0 + (k : ℝ) * lam ≤ x k := by
  exact fun k => by induction' k with n hn <;> norm_num ; linarith [ h n ] ;

/-
From a one-step upper drift bound x(n+1) - x(n) ≤ lam, we get the global
    upper affine envelope x(k) ≤ x(0) + k·lam for all k.
    This is the max-plus certificate side of the tropical envelope.
-/
theorem step_upper_to_global_upper
    (x : ℕ → ℝ) (lam : ℝ)
    (h : ∀ n : ℕ, x (n+1) - x n ≤ lam) :
    ∀ k : ℕ, x k ≤ x 0 + (k : ℝ) * lam := by
  exact fun n ↦ by induction' n with n ih <;> norm_num at * ; linarith [ h n ] ;

/-!
## The main two-sided envelope theorem

This is the atomic theorem from which more tropical-looking corollaries can be derived.
It is the certified passage from **local drift inequalities** to **global tropical envelopes**.
-/

/-- **Two-sided affine envelope from one-step drift bounds.**
    If every increment of x is bounded between lam_min and lam_max, then x is trapped
    in the affine envelope x(0) + k·lam_min ≤ x(k) ≤ x(0) + k·lam_max.

    This is the fundamental theorem connecting local drift bounds to global
    tropical performance envelopes. The lower bound is a min-plus certificate,
    the upper bound is a max-plus certificate. -/
theorem affine_envelope_of_step_bounds
    (x : ℕ → ℝ) (lam_min lam_max : ℝ)
    (h_lower : ∀ n : ℕ, lam_min ≤ x (n+1) - x n)
    (h_upper : ∀ n : ℕ, x (n+1) - x n ≤ lam_max) :
    ∀ k : ℕ,
      (x 0) + (k : ℝ) * lam_min ≤ x k ∧
      x k ≤ (x 0) + (k : ℝ) * lam_max := by
  intro k
  exact ⟨step_lower_to_global_lower x lam_min h_lower k,
         step_upper_to_global_upper x lam_max h_upper k⟩

/-!
## Dualization theorems

These connect the max-plus and min-plus worlds via negation, using the algebraic
identity min(a,b) = -max(-a,-b) (cf. `min_max_duality` in the catalog).
-/

/-
**Dualization via negation**: an upper max-plus envelope for x is equivalent
    to a lower min-plus envelope for -x. This is the formal bridge between the
    two tropical semirings.

    Uses the algebraic identity: x ≤ a ↔ -a ≤ -x
    which is the pointwise form of min_max_duality.
-/
theorem upper_bound_iff_lower_bound_neg
    (x : ℕ → ℝ) (slope intercept : ℝ) :
    (∀ k : ℕ, x k ≤ (k : ℝ) * slope + intercept) ↔
    (∀ k : ℕ, -((k : ℝ) * slope + intercept) ≤ - x k) := by
  constructor <;> intro h <;> intro k <;> linarith [ h k ]

/-
**Full envelope duality**: a two-sided envelope for x is equivalent to
    a two-sided envelope for -x with swapped and negated parameters.

    This is the "one proof, two semirings" architecture: proving an envelope
    in the max-plus world automatically gives one in the min-plus world.
-/
theorem envelope_dualization
    (x : ℕ → ℝ) (lam_min lam_max vmin vmax : ℝ) :
    (∀ k : ℕ, (k : ℝ) * lam_min + vmin ≤ x k ∧ x k ≤ (k : ℝ) * lam_max + vmax) ↔
    (∀ k : ℕ, -((k : ℝ) * lam_max + vmax) ≤ -x k ∧
              -x k ≤ -((k : ℝ) * lam_min + vmin)) := by
  grind +splitImp

/-
**Envelope transfer via negation**: If x has a two-sided drift envelope,
    then -x has a two-sided drift envelope with negated and swapped slopes.
    This demonstrates that proving the lower bound theorem suffices—the upper
    bound follows by applying it to -x.
-/
theorem envelope_of_neg
    (x : ℕ → ℝ) (lam_min lam_max : ℝ)
    (h_lower : ∀ n : ℕ, lam_min ≤ x (n+1) - x n)
    (h_upper : ∀ n : ℕ, x (n+1) - x n ≤ lam_max) :
    ∀ k : ℕ,
      (-x) 0 + (k : ℝ) * (-lam_max) ≤ (-x) k ∧
      (-x) k ≤ (-x) 0 + (k : ℝ) * (-lam_min) := by
  exact fun k => affine_envelope_of_step_bounds ( fun n => -x n ) ( -lam_max ) ( -lam_min ) ( fun n => by norm_num; linarith [ h_lower n, h_upper n ] ) ( fun n => by norm_num; linarith [ h_lower n, h_upper n ] ) k

/-!
## Max-plus recursion envelope

A more interesting theorem: from a max-plus recursion with bounded disturbance,
deduce affine envelopes.
-/

/-
**Envelope from bounded max-plus recursion.**
    If x(n+1) = max(x(n) + a, c(n)) where c(n) - x(n) is bounded between
    dmin and dmax, then x is trapped in an affine envelope with slopes
    min(a, dmin) and max(a, dmax).

    The key insight: x(n+1) - x(n) = max(a, c(n) - x(n)), so the one-step
    drift is bounded between min(a, dmin) and max(a, dmax), and we can
    apply `affine_envelope_of_step_bounds`.
-/
theorem maxplus_recursion_envelope
    (x c : ℕ → ℝ) (a dmin dmax : ℝ)
    (hrec : ∀ n : ℕ, x (n+1) = max (x n + a) (c n))
    (hcd : ∀ n : ℕ, dmin ≤ c n - x n ∧ c n - x n ≤ dmax) :
    ∀ n : ℕ,
      x 0 + (n : ℝ) * (min a dmin) ≤ x n ∧
      x n ≤ x 0 + (n : ℝ) * (max a dmax) := by
  -- By induction on $n$, we can show that $x(n)$ is bounded between $x(0) + n \cdot \min(a, d_{\text{min}})$ and $x(0) + n \cdot \max(a, d_{\text{max}})$.
  have h_ind : ∀ n, x n ≥ x 0 + n * min a dmin ∧ x n ≤ x 0 + n * max a dmax := by
    intro n
    induction' n with n ih
    · simp
    ·
      grind;
  exact h_ind

/-!
## Application: Network calculus backlog bound

In network calculus, x(k) represents cumulative arrivals and y(k) cumulative
departures. The backlog at time k is x(k) - y(k). If arrivals grow at most
at rate ρ (arrival curve) and departures grow at least at rate σ (service curve),
the backlog is bounded.
-/

/-
**Network calculus backlog bound.**
    If arrivals x grow at most at rate rho from initial value x(0), and
    departures y grow at least at rate sigma from initial value y(0), then
    the backlog x(k) - y(k) is bounded above by
    x(0) - y(0) + k·(rho - sigma).

    When rho < sigma (service rate exceeds arrival rate), the backlog eventually
    becomes negative, meaning the system drains.
    When rho ≥ sigma, the backlog grows at most linearly.
-/
theorem network_calculus_backlog_bound
    (x y : ℕ → ℝ) (rho sigma : ℝ)
    (hx : ∀ n : ℕ, x (n+1) - x n ≤ rho)
    (hy : ∀ n : ℕ, sigma ≤ y (n+1) - y n) :
    ∀ k : ℕ, x k - y k ≤ (x 0 - y 0) + (k : ℝ) * (rho - sigma) := by
  exact fun k => by have := step_upper_to_global_upper x rho hx k; have := step_lower_to_global_lower y sigma hy k; linarith;

/-
**Two-sided schedulability window.**
    If both arrivals and departures have exact (constant) rates, then the
    difference x(k) - y(k) is exactly determined. More generally, if each
    has bounded drift, we get a two-sided envelope on the difference.
-/
theorem schedulability_window
    (x y : ℕ → ℝ) (rho_min rho_max sigma_min sigma_max : ℝ)
    (hx_lower : ∀ n : ℕ, rho_min ≤ x (n+1) - x n)
    (hx_upper : ∀ n : ℕ, x (n+1) - x n ≤ rho_max)
    (hy_lower : ∀ n : ℕ, sigma_min ≤ y (n+1) - y n)
    (hy_upper : ∀ n : ℕ, y (n+1) - y n ≤ sigma_max) :
    ∀ k : ℕ,
      (x 0 - y 0) + (k : ℝ) * (rho_min - sigma_max) ≤ x k - y k ∧
      x k - y k ≤ (x 0 - y 0) + (k : ℝ) * (rho_max - sigma_min) := by
  exact fun n => ⟨ by linarith [ step_lower_to_global_lower x rho_min hx_lower n, step_upper_to_global_upper y sigma_max hy_upper n ], by linarith [ step_upper_to_global_upper x rho_max hx_upper n, step_lower_to_global_lower y sigma_min hy_lower n ] ⟩

/-!
## Throughput bounds

The affine envelope directly implies throughput bounds: the long-run average
growth rate of x is trapped between lam_min and lam_max.
-/

/-
**Throughput bounds from affine envelope.**
    If x satisfies one-step drift bounds, then the average rate x(k)/k
    is trapped between lam_min and lam_max (for k > 0, with a correction
    term x(0)/k that vanishes asymptotically).
-/
theorem throughput_bounds
    (x : ℕ → ℝ) (lam_min lam_max : ℝ)
    (h_lower : ∀ n : ℕ, lam_min ≤ x (n+1) - x n)
    (h_upper : ∀ n : ℕ, x (n+1) - x n ≤ lam_max)
    (k : ℕ) (hk : 0 < k) :
    lam_min + x 0 / (k : ℝ) ≤ x k / (k : ℝ) ∧
    x k / (k : ℝ) ≤ lam_max + x 0 / (k : ℝ) := by
  constructor <;> nlinarith [ h_lower k, h_upper k, show ( 0 : ℝ ) < k by positivity, div_mul_cancel₀ ( x 0 ) ( show ( k : ℝ ) ≠ 0 by positivity ), div_mul_cancel₀ ( x k ) ( show ( k : ℝ ) ≠ 0 by positivity ), show x k ≥ x 0 + k * lam_min by exact ( affine_envelope_of_step_bounds x lam_min lam_max h_lower h_upper k ) |>.1, show x k ≤ x 0 + k * lam_max by exact ( affine_envelope_of_step_bounds x lam_min lam_max h_lower h_upper k ) |>.2 ]