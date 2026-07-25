/-
  # Closure-Operator Networks: Universal Approximation and Certified Robustness

  This file establishes that closure-operator networks — architectures built from
  monotone, extensive, idempotent maps — are universal approximators on finite domains
  and yield certified robustness guarantees by construction.

  ## Main Results

  1. **Finite Exact Representation** (`finite_function_exact_by_closure_features`):
     Every function `f : Fin n → ℝ` can be represented exactly as a weighted sum
     of closure-indicator features.

  2. **Certified Robustness** (`closure_network_certified_robust`):
     If a classifier factors through a closure representative that is locally constant
     within radius `r`, then predictions are stable under perturbations ≤ `r`.

  3. **Point Separation** (`closure_indicator_separates_points`):
     Closure operators can separate any two distinct points.

  4. **Lipschitz Approximation** (`closure_step_error_le_lipschitz_mesh`):
     For Lipschitz functions on `[0,1]`, closure-step networks with mesh `δ`
     achieve uniform error `O(Lδ)`.

  5. **Continuous Uniform Approximation** (`continuous_uniform_approx_by_closure_steps`):
     Every continuous function on `[0,1]` is uniformly approximable by closure-step networks.
-/
import Mathlib

open Set Function Finset Classical

noncomputable section

/-! ## Closure Operator Definitions -/

/-- A predicate asserting that `c : Set α → Set α` is a closure operator:
    monotone, extensive, and idempotent. -/
structure IsClosureOp {α : Type*} (c : Set α → Set α) : Prop where
  monotone' : Monotone c
  extensive' : ∀ s, s ⊆ c s
  idempotent' : ∀ s, c (c s) = c s

/-- The identity function on sets is a closure operator. -/
theorem isClosureOp_id {α : Type*} : IsClosureOp (id : Set α → Set α) where
  monotone' := monotone_id
  extensive' := fun _ => le_refl _
  idempotent' := fun _ => rfl

/-! ## Theorem: Point Separation -/

/-- **Point Separation by Closure Features.**
    For any two distinct elements, there exists a closure operator and a seed set
    whose closure contains one element but not the other. The identity closure
    with a singleton seed achieves this. -/
theorem closure_indicator_separates_points
    {α : Type*} (x y : α) (h : x ≠ y) :
    ∃ (c : Set α → Set α) (s : Set α),
      IsClosureOp c ∧ x ∈ c s ∧ y ∉ c s := by
  refine ⟨id, {x}, isClosureOp_id, ?_, ?_⟩
  · exact mem_singleton_iff.mpr rfl
  · simp [mem_singleton_iff]
    exact Ne.symm h

/-! ## Theorem A: Finite-Domain Exact Representation -/

/-
**Finite Universal Approximation by Closure Features.**
    Every function `f : Fin n → ℝ` is exactly represented by a finite
    weighted sum of closure-indicator features. The construction uses:
    - `m = n` closure operators (all identity)
    - prototype `{i}` for the `i`-th feature
    - weight `f i` for the `i`-th feature

    The key identity: `∑ i, f(i) · 𝟙{x ∈ id({i})} = ∑ i, f(i) · δ(x,i) = f(x)`.
    This is the closure-algebraic analogue of finite interpolation.
-/
theorem finite_function_exact_by_closure_features
    {n : ℕ} (f : Fin n → ℝ) :
    ∃ (m : ℕ) (proto : Fin m → Set (Fin n))
      (C : Fin m → Set (Fin n) → Set (Fin n)) (w : Fin m → ℝ),
      (∀ i, IsClosureOp (C i)) ∧
      ∀ x : Fin n,
        f x = ∑ i : Fin m, w i *
          (if x ∈ (C i (proto i)) then (1 : ℝ) else 0) := by
  use n
  use fun i => {i}
  use fun _ => id
  use fun i => f i
  simp [isClosureOp_id]

/-! ## Theorem C: Certified Robustness of Closure Networks -/

/-
**Certified Robustness of Closure-Based Classifiers.**
    If a classifier `g` factors through a closure representative `c` that maps
    all points within distance `r` to the same representative, then `g` is
    certifiably robust within radius `r`.
-/
theorem closure_network_certified_robust
    {X Y : Type*} [PseudoMetricSpace X]
    (g : X → Y) (c : X → X) (r : ℝ)
    (hc_fixed_ball : ∀ x y, dist x y ≤ r → c y = c x)
    (hlabel : ∀ x, g x = g (c x)) :
    ∀ x y, dist x y ≤ r → g y = g x := by
  grind

/-- **Robustness via idempotent closure** — variant with explicit idempotence. -/
theorem closure_network_certified_robust_idem
    {X Y : Type*} [PseudoMetricSpace X]
    (g : X → Y) (c : X → X) (r : ℝ)
    (_hc_idem : ∀ x, c (c x) = c x)
    (hc_fixed_ball : ∀ x y, dist x y ≤ r → c y = c x)
    (hlabel : ∀ x, g x = g (c x)) :
    ∀ x y, dist x y ≤ r → g y = g x :=
  closure_network_certified_robust g c r hc_fixed_ball hlabel

/-! ## Theorem B: Lipschitz Approximation by Closure-Step Networks -/

/-- A closure-step network on `[0,1]` with `N` cells: piecewise-constant
    function sampling `f` at regularly spaced centers. -/
def closureStepApprox (f : ℝ → ℝ) (N : ℕ) (_hN : 0 < N) : ℝ → ℝ := fun x =>
  let δ := 1 / (N : ℝ)
  let i := min (Nat.floor (x / δ)) (N - 1)
  let center := (i : ℝ) * δ + δ / 2
  f center

/-
**Lipschitz Error Bound for Closure-Step Networks.**
    For an `L`-Lipschitz function on `[0,1]`, a closure-step network with
    `N` cells achieves uniform error at most `L / N`.
-/
theorem closure_step_error_le_lipschitz_mesh
    (f : ℝ → ℝ) (L : ℝ) (N : ℕ)
    (hL : 0 ≤ L) (hN : 0 < N)
    (hLip : ∀ x y, x ∈ Icc (0 : ℝ) 1 → y ∈ Icc (0 : ℝ) 1 →
      |f x - f y| ≤ L * |x - y|) :
    ∀ x ∈ Icc (0 : ℝ) 1,
      |f x - closureStepApprox f N hN x| ≤ L * (1 / N) := by
  intro x hx; specialize hLip x ( min ( Nat.floor ( x / ( 1 / N ) ) ) ( N - 1 ) * ( 1 / N ) + 1 / N / 2 ) hx; simp_all +decide [ abs_le ] ;
  specialize hLip ( by exact add_nonneg ( mul_nonneg ( le_min ( Nat.cast_nonneg _ ) ( sub_nonneg.mpr ( Nat.one_le_cast.mpr hN ) ) ) ( inv_nonneg.mpr ( Nat.cast_nonneg _ ) ) ) ( by positivity ) ) ( by exact add_le_of_le_sub_left ( by cases min_cases ( ⌊x * N⌋₊ : ℝ ) ( N - 1 ) <;> nlinarith [ show ( N : ℝ ) ≥ 1 by norm_cast, mul_inv_cancel₀ ( by positivity : ( N : ℝ ) ≠ 0 ) ] ) ) ; simp_all +decide [ closureStepApprox ] ; ring_nf at * ;
  -- By simplifying, we can see that the absolute value term is bounded by $1/N$.
  have h_abs : |x - min (⌊x * N⌋₊ : ℝ) (-1 + N) * (N : ℝ)⁻¹ + (N : ℝ)⁻¹ * (-1 / 2)| ≤ (N : ℝ)⁻¹ := by
    rw [ abs_le ] ; constructor <;> cases min_cases ( ⌊x * N⌋₊ : ℝ ) ( -1 + N ) <;> nlinarith [ Nat.floor_le ( show 0 ≤ x * N by nlinarith ), Nat.lt_floor_add_one ( x * N ), show ( N : ℝ ) ≥ 1 by norm_cast, mul_inv_cancel₀ ( by positivity : ( N : ℝ ) ≠ 0 ) ] ;
  constructor <;> nlinarith [ abs_le.mp h_abs ]

/-! ## Corollary: Uniform Approximation of Continuous Functions -/

/-
**Uniform Approximation of Continuous Functions on [0,1].**
    Every continuous function on `[0,1]` is uniformly approximable to arbitrary
    precision by closure-step networks. This follows from uniform continuity
    on compact sets combined with the Lipschitz mesh bound.
-/
theorem continuous_uniform_approx_by_closure_steps
    (f : ℝ → ℝ)
    (hcont : ContinuousOn f (Icc (0 : ℝ) 1))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ (N : ℕ) (hN : 0 < N) (g : ℝ → ℝ),
      g = closureStepApprox f N hN ∧
      ∀ x ∈ Icc (0 : ℝ) 1,
        |f x - g x| < ε := by
  -- By the uniform continuity of $f$ on $[0,1]$, there exists $\delta > 0$ such that for all $x, y \in [0,1]$, if $|x - y| < \delta$, then $|f(x) - f(y)| < \epsilon$.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ x y : ℝ, x ∈ Set.Icc 0 1 → y ∈ Set.Icc 0 1 → |x - y| < δ → |f x - f y| < ε := by
    have := Metric.uniformContinuousOn_iff.mp ( isCompact_Icc.uniformContinuousOn_of_continuous hcont ) ε hε; aesop;
  refine' ⟨ ⌈δ⁻¹⌉₊ + 1, _, _ ⟩ <;> norm_num;
  intro x hx₁ hx₂; convert hδ x ( ( Min.min ( Nat.floor ( x / ( 1 / ( ⌈δ⁻¹⌉₊ + 1 ) ) ) ) ( ⌈δ⁻¹⌉₊ + 1 - 1 ) : ℕ ) * ( 1 / ( ⌈δ⁻¹⌉₊ + 1 ) ) + ( 1 / ( ⌈δ⁻¹⌉₊ + 1 ) ) / 2 ) ⟨ hx₁, hx₂ ⟩ ?_ ?_ using 1 <;> norm_num;
  · unfold closureStepApprox; norm_num;
  · field_simp;
    grind;
  · rw [ abs_lt ] ; constructor <;> cases min_cases ( ⌊x * ( ⌈δ⁻¹⌉₊ + 1 ) ⌋₊ : ℝ ) ⌈δ⁻¹⌉₊ <;> nlinarith [ Nat.floor_le ( show 0 ≤ x * ( ⌈δ⁻¹⌉₊ + 1 ) by positivity ), Nat.lt_floor_add_one ( x * ( ⌈δ⁻¹⌉₊ + 1 ) ), mul_inv_cancel₀ ( by positivity : ( ⌈δ⁻¹⌉₊ + 1 : ℝ ) ≠ 0 ), Nat.le_ceil ( δ⁻¹ ), mul_inv_cancel₀ ( by positivity : δ ≠ 0 ) ]

end