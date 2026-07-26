/-
# Ordered Additive Aggregation: Abstract Monotone-Sum Calculus

This module establishes a general **ordered additive aggregation principle**:
if pointwise inequalities hold coordinatewise over a finite index type, then
the corresponding sums satisfy the same inequality. The key insight is that the
weighted coupling/gap-growth inequality from `TropicalFactorCoupling` is not
an artifact of `ℝ` — it is a theorem of any partially ordered additive
commutative monoid with left-monotone addition.

## Minimal Algebraic Assumptions

The abstract theorems require only:
- `AddCommMonoid α` — commutative addition with a zero,
- `PartialOrder α` — a partial order,
- `AddLeftMono α` — addition is monotone on the left: `a ≤ b → c + a ≤ c + b`.

This is strictly weaker than requiring a linear order. In particular, it covers:
- `ℝ`, `ℤ`, `ℕ`, `ℚ` — the classical ordered fields and rings,
- `ℝ≥0∞` (`ENNReal`) — extended nonneg reals for measure theory,
- `WithTop ℝ` — extended reals for Bellman/DP with infinite penalties,
- any `OrderedAddCommMonoid`.

## Main Results

* `sum_le_sum_of_pointwise'` — Pointwise `f i ≤ g i` implies `∑ f ≤ ∑ g`.
* `total_gap_growth_of_factorwise_growth_weighted_ordered` — Abstract weighted
  coupling: `∀ i, w i + a i ≤ b i → (∑ w) + (∑ a) ≤ ∑ b`.
* `total_gap_growth_of_factorwise_growth_weighted_ordered_fintype` — Same over
  arbitrary `Fintype`.
* Concrete instantiations for `ℝ≥0∞`, `ℤ`, `WithTop ℝ`.
* Tropical bridge theorem connecting to min-plus dynamics.

## Architecture

The proof factors through two reusable engines:
1. `Finset.sum_le_sum` (from Mathlib) — the core monotonicity of finite sums,
2. `Finset.sum_add_distrib` — distributivity of sums over addition.

Every domain-specific theorem is a one-line specialization of the abstract result.
-/

import Mathlib

open Finset BigOperators

/-! ## Abstract Monotone-Sum Engine -/

/-- **Pointwise-to-global monotonicity of finite sums.**

If `f i ≤ g i` for every `i` in a finite type, then `∑ i, f i ≤ ∑ i, g i`.

This is the reusable engine behind all weighted coupling theorems. The minimal
assumptions are: `AddCommMonoid α`, `PartialOrder α`, and `AddLeftMono α`
(left-monotonicity of addition). No linearity of the order is needed.

This follows immediately from Mathlib's `Finset.sum_le_sum`. -/
theorem sum_le_sum_of_pointwise'
    {α ι : Type*} [AddCommMonoid α] [PartialOrder α] [AddLeftMono α] [Fintype ι]
    {f g : ι → α}
    (h : ∀ i, f i ≤ g i) :
    ∑ i, f i ≤ ∑ i, g i :=
  Finset.sum_le_sum fun i _ => h i

/-! ## Abstract Weighted Coupling Theorem -/

/-- **Abstract weighted coupling over `Fin k`.**

For any partially ordered additive commutative monoid with left-monotone addition:
if for every coordinate `i`, `w i + a i ≤ b i`, then `(∑ w) + (∑ a) ≤ ∑ b`.

This is the abstract generalization of `total_gap_growth_of_factorwise_growth_weighted`
from `TropicalFactorCoupling.lean`, which was stated only for `ℝ`. The proof uses
only `Finset.sum_le_sum` and `Finset.sum_add_distrib`. -/
theorem total_gap_growth_of_factorwise_growth_weighted_ordered
    {α : Type*} [AddCommMonoid α] [PartialOrder α] [AddLeftMono α]
    {k : ℕ}
    (w a b : Fin k → α)
    (h : ∀ i, w i + a i ≤ b i) :
    (∑ i, w i) + (∑ i, a i) ≤ ∑ i, b i := by
  rw [← Finset.sum_add_distrib]
  exact sum_le_sum_of_pointwise' h

/-- **Abstract weighted coupling over arbitrary `Fintype`.**

Same as `total_gap_growth_of_factorwise_growth_weighted_ordered` but with the
index type generalized from `Fin k` to any `Fintype ι`. -/
theorem total_gap_growth_of_factorwise_growth_weighted_ordered_fintype
    {α ι : Type*} [AddCommMonoid α] [PartialOrder α] [AddLeftMono α] [Fintype ι]
    (w a b : ι → α)
    (h : ∀ i, w i + a i ≤ b i) :
    (∑ i, w i) + (∑ i, a i) ≤ ∑ i, b i := by
  rw [← Finset.sum_add_distrib]
  exact sum_le_sum_of_pointwise' h

/-! ## Instantiation 1: `ℝ≥0∞` (ENNReal)

`ℝ≥0∞` is the native codomain for measures, outer measures, entropy-like
quantities, and nonnegative extended costs. It satisfies `AddCommMonoid`,
`PartialOrder`, and `AddLeftMono`, so the abstract theorem applies directly. -/

/-- Weighted coupling inequality for extended nonnegative reals (`ℝ≥0∞`).

This is the aggregation principle for measure-theoretic costs: if each
coordinate's weighted cost is bounded, the total weighted cost is bounded. -/
theorem total_gap_growth_weighted_ennreal
    {k : ℕ}
    (w a b : Fin k → ENNReal)
    (h : ∀ i, w i + a i ≤ b i) :
    (∑ i, w i) + (∑ i, a i) ≤ ∑ i, b i :=
  total_gap_growth_of_factorwise_growth_weighted_ordered w a b h

/-- `Fintype` version for `ℝ≥0∞`. -/
theorem total_gap_growth_weighted_ennreal_fintype
    {ι : Type*} [Fintype ι]
    (w a b : ι → ENNReal)
    (h : ∀ i, w i + a i ≤ b i) :
    (∑ i, w i) + (∑ i, a i) ≤ ∑ i, b i :=
  total_gap_growth_of_factorwise_growth_weighted_ordered_fintype w a b h

/-! ## Instantiation 2: `ℤ` (Integers)

Integers arise in combinatorial optimization, discrete convexity, scheduling,
and complexity-theoretic potential functions. The theorem makes the aggregation
principle algorithmically native. -/

/-- Weighted coupling inequality for integers. -/
theorem total_gap_growth_weighted_int
    {k : ℕ}
    (w a b : Fin k → ℤ)
    (h : ∀ i, w i + a i ≤ b i) :
    (∑ i, w i) + (∑ i, a i) ≤ ∑ i, b i :=
  total_gap_growth_of_factorwise_growth_weighted_ordered w a b h

/-! ## Instantiation 3: `WithTop ℝ` (Extended Reals)

`WithTop ℝ` models costs with infinite penalties, as in Bellman equations
with forbidden states or value iteration with `⊤` penalties. -/

/-- Weighted coupling inequality for `WithTop ℝ`.

This works because `WithTop ℝ` satisfies `AddCommMonoid`, `PartialOrder`,
and `AddLeftMono`. It covers Bellman/DP scenarios with infinite-cost states. -/
theorem total_gap_growth_weighted_withTop_real
    {k : ℕ}
    (w a b : Fin k → WithTop ℝ)
    (h : ∀ i, w i + a i ≤ b i) :
    (∑ i, w i) + (∑ i, a i) ≤ ∑ i, b i :=
  total_gap_growth_of_factorwise_growth_weighted_ordered w a b h

/-! ## Instantiation 4: `ℕ` (Natural Numbers) -/

/-- Weighted coupling inequality for natural numbers. -/
theorem total_gap_growth_weighted_nat
    {k : ℕ}
    (w a b : Fin k → ℕ)
    (h : ∀ i, w i + a i ≤ b i) :
    (∑ i, w i) + (∑ i, a i) ≤ ∑ i, b i :=
  total_gap_growth_of_factorwise_growth_weighted_ordered w a b h

/-! ## Recovering the Original Real-Valued Theorem

The original `total_gap_growth_of_factorwise_growth_weighted` from
`TropicalFactorCoupling.lean` is now a corollary of the abstract theorem,
modulo the `gap`/`step` formulation. Here we show the direct specialization. -/

/-- The original weighted coupling for `ℝ`, recovered as a specialization. -/
theorem total_gap_growth_weighted_real
    {k : ℕ}
    (w a b : Fin k → ℝ)
    (h : ∀ i, w i + a i ≤ b i) :
    (∑ i, w i) + (∑ i, a i) ≤ ∑ i, b i :=
  total_gap_growth_of_factorwise_growth_weighted_ordered w a b h

/-- The `gap`/`step` formulation from `TropicalFactorCoupling`, derived from
the abstract ordered theorem. -/
theorem total_gap_growth_of_factorwise_growth_weighted_from_abstract
    {α : Type*} {k : ℕ}
    (gap : α → ℝ) (step : α → α) (βi : Fin k → ℝ)
    (hfactor : ∀ (i : Fin k) (x : α), gap (step x) ≥ gap x + βi i) :
    ∀ s : Fin k → α,
      (∑ i : Fin k, gap (step (s i))) ≥
        (∑ i : Fin k, gap (s i)) + ∑ i : Fin k, βi i := by
  intro s
  have key := total_gap_growth_of_factorwise_growth_weighted_ordered
    βi (fun i => gap (s i)) (fun i => gap (step (s i)))
    (fun i => by linarith [hfactor i (s i)])
  linarith

/-! ## Tropical Bridge: Min-Plus Monotonicity

In tropical (min-plus) algebra, ordinary addition plays the role of tropical
multiplication, and `min` plays the role of tropical addition. The abstract
coupling theorem translates into a statement about tropical cost dominance:
if each factor's weighted cost is bounded, the aggregate tropical cost is bounded.

The key observation is that the ordinary ordered additive structure on `ℝ` is
exactly what tropical dynamics uses for cost accumulation. The min-plus semiring
adds `min` on top, but the *summation* of costs is ordinary addition — which is
precisely what our abstract theorem governs. -/

/-- **Tropical cost dominance**: If coordinatewise weighted costs satisfy
`w i + a i ≤ b i`, then the total weighted cost is dominated, and in particular
the min of the two sides equals the smaller one.

This connects the abstract coupling theorem to tropical/min-plus dynamics:
in a shortest-path or Bellman context, `w i` is the transition cost, `a i` is the
current value, and `b i` is the updated value. The theorem says total transition
cost plus total current value cannot exceed total updated value. -/
theorem tropical_cost_dominance
    {k : ℕ}
    (w a b : Fin k → ℝ)
    (h : ∀ i, w i + a i ≤ b i) :
    min ((∑ i, w i) + (∑ i, a i)) (∑ i, b i) = (∑ i, w i) + (∑ i, a i) := by
  exact min_eq_left (total_gap_growth_weighted_real w a b h)

/-- **Tropical Bellman dominance**: In a Bellman/DP setting with `k` states,
if each state's one-step update satisfies `cost i + V i ≤ V' i` (where `V` is the
current value function and `V'` is the updated value), then the total cost plus
total current value is dominated by the total updated value.

Under min-plus interpretation, this is the monotonicity of the Bellman operator
aggregated over all states. -/
theorem tropical_bellman_dominance
    {k : ℕ}
    (cost V V' : Fin k → ℝ)
    (hBellman : ∀ i, cost i + V i ≤ V' i) :
    (∑ i, cost i) + (∑ i, V i) ≤ ∑ i, V' i :=
  total_gap_growth_weighted_real cost V V' hBellman

/-- **Tropical path weight monotonicity**: If each edge's weight plus source
potential is at most the target potential, then total edge weights plus total
source potentials is at most total target potentials. This is the finite-path
version of the shortest-path optimality condition. -/
theorem tropical_path_weight_mono
    {ι : Type*} [Fintype ι]
    (edgeWeight srcPotential tgtPotential : ι → ℝ)
    (hOptimality : ∀ i, edgeWeight i + srcPotential i ≤ tgtPotential i) :
    (∑ i, edgeWeight i) + (∑ i, srcPotential i) ≤ ∑ i, tgtPotential i :=
  total_gap_growth_of_factorwise_growth_weighted_ordered_fintype
    edgeWeight srcPotential tgtPotential hOptimality

/-! ## Abstract Bellman Operator Monotonicity

The coupling theorem can be lifted to function spaces: if a Bellman-like operator
improves each coordinate's gap, the total gap improves. This generalizes the
`sum_residual_growth_of_factorwise_bellman_growth` from `TropicalFactorCoupling.lean`
to abstract ordered types. -/

/-- **Abstract Bellman residual coupling**: coordinatewise Bellman improvement
implies total improvement, over any ordered additive commutative monoid. -/
theorem abstract_bellman_residual_coupling
    {α σ : Type*} [AddCommMonoid α] [PartialOrder α] [AddLeftMono α]
    {k : ℕ}
    (gap : (σ → α) → α)
    (T : Fin k → (σ → α) → (σ → α))
    (βi : Fin k → α)
    (hmono : ∀ i f, gap f + βi i ≤ gap (T i f)) :
    ∀ V : Fin k → σ → α,
      (∑ i : Fin k, gap (V i)) + ∑ i : Fin k, βi i ≤
        ∑ i : Fin k, gap (T i (V i)) := by
  intro V
  rw [add_comm]
  exact total_gap_growth_of_factorwise_growth_weighted_ordered
    βi (fun i => gap (V i)) (fun i => gap (T i (V i)))
    (fun i => by rw [add_comm]; exact hmono i (V i))

/-! ## Axiom Audit -/

#print axioms sum_le_sum_of_pointwise'
#print axioms total_gap_growth_of_factorwise_growth_weighted_ordered
#print axioms total_gap_growth_of_factorwise_growth_weighted_ordered_fintype
#print axioms total_gap_growth_weighted_ennreal
#print axioms total_gap_growth_weighted_int
#print axioms total_gap_growth_weighted_withTop_real
#print axioms total_gap_growth_weighted_real
#print axioms tropical_cost_dominance
#print axioms tropical_bellman_dominance
#print axioms tropical_path_weight_mono
#print axioms abstract_bellman_residual_coupling