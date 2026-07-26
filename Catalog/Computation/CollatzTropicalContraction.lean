import Mathlib

/-!
# Tropical Contraction Theory for Collatz Dynamics

This module develops a rigorous tropical/Bellman contraction framework for the Collatz
iteration. The central result is that a discounted tropical Collatz operator is a
contraction on the complete metric space of bounded functions `ℕ →ᵇ ℝ`, admitting a
unique fixed point and geometrically convergent Picard iteration by the Banach
contraction principle.

## Main Results

### Branch Geometry
- `collatz_branchEven_isometry`: The even branch `x ↦ x - log 2` is an isometry.
- `collatz_branchOdd_isometry`: The odd branch `x ↦ x + log(3/2)` is an isometry.
- `collatz_branch_nonexpansive`: Both branches are nonexpansive (1-Lipschitz).

### Min-Plus Contraction Algebra
- `abs_min_sub_min_le`: `|min(a,b) - min(c,d)| ≤ max(|a-c|, |b-d|)`.

### Bellman Operator Contraction
- `collatzBellman_pointwise_bound`: Pointwise contraction inequality.
- `collatzBellmanBCF_contracting`: The operator is `ContractingWith γ` on `ℓ∞(ℕ)`.

### Fixed-Point Theorems
- `collatzBellman_unique_fixed_point`: Existence and uniqueness of the fixed point.
- `collatzBellman_iterate_converges`: Picard iteration converges to the fixed point.
- `collatzBellman_fixedPoint_eq`: The fixed point satisfies the Bellman equation.

## Mathematical Significance

This formalizes the observation that the Collatz iteration, when lifted to a min-plus
(tropical) Bellman equation with discounting, becomes a contraction mapping on a
function space. The unique fixed point is the tropical value function — a potential
encoding optimal branch-cost structure of Collatz orbits. The discount factor `γ < 1`
transforms the non-contracting arithmetic dynamics into a contracting operator on
potentials, analogous to discounted dynamic programming in control theory.
-/

noncomputable section

open BoundedContinuousFunction Filter Topology

namespace CollatzTropicalContraction

/-! ## Section 1: Collatz Branch Maps as Isometries -/

/-- Even branch of the Collatz map in log-coordinates. -/
def branchEven (x : ℝ) : ℝ := x - Real.log 2

/-- Odd branch of the Collatz map in log-coordinates. -/
def branchOdd (x : ℝ) : ℝ := x + Real.log 3 - Real.log 2

/-- Normalized branch selector. -/
def normalizedBranch (b : Bool) (x : ℝ) : ℝ :=
  if b then branchOdd x else branchEven x

/-
The even Collatz branch is an isometry: it preserves distances exactly.
    This follows because `branchEven` is a translation by a constant.
-/
theorem collatz_branchEven_isometry :
    ∀ x y : ℝ, dist (branchEven x) (branchEven y) = dist x y := by
  unfold branchEven; norm_num [ dist_eq_norm ] ;

/-
The odd Collatz branch is an isometry: it preserves distances exactly.
-/
theorem collatz_branchOdd_isometry :
    ∀ x y : ℝ, dist (branchOdd x) (branchOdd y) = dist x y := by
  unfold branchOdd;
  norm_num [ dist_eq_norm ]

/-- Both Collatz branches are nonexpansive (1-Lipschitz). -/
theorem collatz_branch_nonexpansive :
    ∀ b : Bool, ∀ x y : ℝ,
      dist (normalizedBranch b x) (normalizedBranch b y) ≤ dist x y := by
  intro b x y
  cases b <;> simp [normalizedBranch]
  · exact le_of_eq (collatz_branchEven_isometry x y)
  · exact le_of_eq (collatz_branchOdd_isometry x y)

/-! ## Section 2: Min-Plus Contraction Algebra -/

/-
The min operation is 1-Lipschitz in max-norm: the distance between mins
    is at most the max of component distances. This is the key algebraic
    fact for tropical Bellman contraction.
-/
theorem abs_min_sub_min_le (a b c d : ℝ) :
    |min a b - min c d| ≤ max (|a - c|) (|b - d|) := by
  grind

/-! ## Section 3: The Collatz Bellman Operator -/

/-- The discounted tropical Collatz Bellman operator on functions `ℕ → ℝ`.
    Given discount `γ`, branch costs `a b`, and value function `f`,
    produces a new value function by discounted minimum over branches. -/
def collatzBellmanFn (γ a b : ℝ) (f : ℕ → ℝ) : ℕ → ℝ :=
  fun n => γ * min (f (n / 2) + a) (f ((3 * n + 1) / 2) + b)

/-
Pointwise contraction bound: for each `n`, the difference between
    operator values is bounded by `γ` times the sup-norm distance.
    Uses the min-Lipschitz lemma and the contraction factor `γ`.
-/
theorem collatzBellman_pointwise_bound
    {γ a b : ℝ} (hγ : 0 ≤ γ) (f g : ℕ →ᵇ ℝ) (n : ℕ) :
    |collatzBellmanFn γ a b (⇑f) n - collatzBellmanFn γ a b (⇑g) n| ≤
      γ * dist f g := by
  -- By definition of $collatzBellmanFn$, we have:
  have h_def : |collatzBellmanFn γ a b f n - collatzBellmanFn γ a b g n| = γ * |min (f (n / 2) + a) (f ((3 * n + 1) / 2) + b) - min (g (n / 2) + a) (g ((3 * n + 1) / 2) + b)| := by
    unfold collatzBellmanFn;
    rw [ ← mul_sub, abs_mul, abs_of_nonneg hγ ];
  refine' h_def ▸ mul_le_mul_of_nonneg_left _ hγ;
  refine' le_trans ( abs_min_sub_min_le _ _ _ _ ) _;
  exact max_le_iff.mpr ⟨ by simpa using f.dist_coe_le_dist ( n / 2 ), by simpa using f.dist_coe_le_dist ( ( 3 * n + 1 ) / 2 ) ⟩

/-! ## Section 4: Lifting to Bounded Functions -/

/-
Bound on the absolute value of min of shifted evaluations.
-/
theorem abs_min_shifted_le (f : ℕ →ᵇ ℝ) (a b : ℝ) (n : ℕ) :
    |min (f (n / 2) + a) (f ((3 * n + 1) / 2) + b)| ≤ ‖f‖ + max |a| |b| := by
  -- Apply the triangle inequality to each term inside the min.
  have h_triangle : |f (n / 2) + a| ≤ ‖f‖ + |a| ∧ |f ((3 * n + 1) / 2) + b| ≤ ‖f‖ + |b| := by
    exact ⟨ by simpa using norm_add_le ( f ( n / 2 ) ) a |> le_trans <| add_le_add ( f.norm_coe_le_norm _ ) le_rfl, by simpa using norm_add_le ( f ( ( 3 * n + 1 ) / 2 ) ) b |> le_trans <| add_le_add ( f.norm_coe_le_norm _ ) le_rfl ⟩;
  cases min_cases ( f ( n / 2 ) + a ) ( f ( ( 3 * n + 1 ) / 2 ) + b ) <;> cases abs_cases ( min ( f ( n / 2 ) + a ) ( f ( ( 3 * n + 1 ) / 2 ) + b ) ) <;> cases abs_cases a <;> cases abs_cases b <;> linarith [ le_max_left |a| |b|, le_max_right |a| |b|, abs_le.mp h_triangle.1, abs_le.mp h_triangle.2 ]

/-- Construction of the Bellman operator on bounded continuous functions `ℕ →ᵇ ℝ`.
    Uses discrete topology on `ℕ` (all functions continuous) and explicit norm bound. -/
def collatzBellmanBCF (γ a b : ℝ) (f : ℕ →ᵇ ℝ) : ℕ →ᵇ ℝ :=
  BoundedContinuousFunction.ofNormedAddCommGroup
    (collatzBellmanFn γ a b (⇑f))
    continuous_of_discreteTopology
    (|γ| * (‖f‖ + max |a| |b|))
    (fun n => by
      simp only [collatzBellmanFn, Real.norm_eq_abs]
      calc |γ * min (f (n / 2) + a) (f ((3 * n + 1) / 2) + b)|
          = |γ| * |min (f (n / 2) + a) (f ((3 * n + 1) / 2) + b)| := abs_mul γ _
        _ ≤ |γ| * (‖f‖ + max |a| |b|) :=
            mul_le_mul_of_nonneg_left (abs_min_shifted_le f a b n) (abs_nonneg γ))

/-- The construction evaluates pointwise to the expected function. -/
theorem collatzBellmanBCF_apply (γ a b : ℝ) (f : ℕ →ᵇ ℝ) (n : ℕ) :
    collatzBellmanBCF γ a b f n = collatzBellmanFn γ a b (⇑f) n := by
  simp [collatzBellmanBCF, BoundedContinuousFunction.ofNormedAddCommGroup]

/-! ## Section 5: Contraction on the Complete Metric Space -/

/-
The Bellman operator satisfies the Lipschitz condition with constant `γ`.
    This is the core technical result enabling application of Banach fixed-point.
-/
theorem collatzBellmanBCF_lipschitz
    (γ a b : ℝ) (hγ0 : 0 ≤ γ) (_hγ1 : γ < 1) :
    LipschitzWith ⟨γ, hγ0⟩ (collatzBellmanBCF γ a b) := by
  refine' LipschitzWith.of_dist_le_mul _;
  intro f g;
  rw [ BoundedContinuousFunction.dist_le ];
  · exact fun n => by simpa only [ collatzBellmanBCF_apply ] using collatzBellman_pointwise_bound hγ0 f g n;
  · exact mul_nonneg hγ0 ( dist_nonneg )

/-- The discounted Collatz Bellman operator is a contraction mapping
    on the complete metric space `ℕ →ᵇ ℝ`. This is the main structural theorem. -/
theorem collatzBellmanBCF_contracting
    (γ a b : ℝ) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) :
    ContractingWith ⟨γ, hγ0⟩ (collatzBellmanBCF γ a b) :=
  ⟨by exact_mod_cast hγ1, collatzBellmanBCF_lipschitz γ a b hγ0 hγ1⟩

/-! ## Section 6: The Fixed-Point Theorems -/

/-
**Existence and uniqueness of the tropical Collatz fixed point.**
    The Bellman operator has a unique fixed point in `ℕ →ᵇ ℝ`.
    This is the tropical value function that encodes the optimal branch-cost
    structure of Collatz orbits under discounting.
-/
theorem collatzBellman_unique_fixed_point
    (γ a b : ℝ) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) :
    ∃! f : ℕ →ᵇ ℝ, collatzBellmanBCF γ a b f = f := by
  have := collatzBellmanBCF_contracting γ a b hγ0 hγ1;
  exact ⟨ _, this.fixedPoint_isFixedPt, fun f hf => this.fixedPoint_unique hf ⟩

/-
**Convergence of Picard iteration.**
    Starting from any bounded function, iterated application of the Bellman operator
    converges to the unique fixed point in the sup-norm topology. This is the
    tropical analogue of value iteration in dynamic programming.
-/
theorem collatzBellman_iterate_converges
    (γ a b : ℝ) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (f₀ : ℕ →ᵇ ℝ) :
    Tendsto (fun k => (collatzBellmanBCF γ a b)^[k] f₀) atTop
      (𝓝 (ContractingWith.fixedPoint _ (collatzBellmanBCF_contracting γ a b hγ0 hγ1))) := by
  convert ( ContractingWith.tendsto_iterate_fixedPoint _ _ ) using 1

/-
The fixed point satisfies the Bellman equation pointwise:
    for every `n`, the value at `n` equals the discounted minimum over branches.
-/
theorem collatzBellman_fixedPoint_eq
    (γ a b : ℝ) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) :
    let f := ContractingWith.fixedPoint _ (collatzBellmanBCF_contracting γ a b hγ0 hγ1)
    ∀ n : ℕ, f n = γ * min (f (n / 2) + a) (f ((3 * n + 1) / 2) + b) := by
  intro f n
  generalize_proofs at *;
  convert congr_arg ( fun g => g n ) ( show f = collatzBellmanBCF γ a b f from _ ) using 1;
  -- Since f is the fixed point of the contraction mapping, we have f = collatzBellmanBCF γ a b f.
  apply Eq.symm; exact (by
  -- By definition of `ContractingWith.fixedPoint`, we know that `f` is a fixed point of `collatzBellmanBCF γ a b`.
  apply Function.IsFixedPt.eq;
  exact ContractingWith.fixedPoint_isFixedPt _)

end CollatzTropicalContraction

end