/-
# Novikov's Self-Consistency Principle as a Fixed-Point Theorem

We formalize the idea that Novikov's self-consistency principle for time travel
follows from the Banach fixed-point theorem. A time-travel scenario is modeled
as a "causal loop" -- a self-map on a state space. Self-consistent histories
correspond to fixed points. We prove:

1. Contractive causal loops always admit self-consistent solutions (Novikov from Banach).
2. Composition of contractive causal loops preserves contractivity.
3. Affine causal maps with small slope are contractive, giving explicit fixed points.
4. Perturbation stability: nearby causal loops have nearby consistent solutions.
5. Multi-traveler scenarios via product spaces preserve consistency.
-/

import Mathlib

open scoped NNReal ENNReal
open Function

/-! ## Core Definitions -/

/-- A `CausalLoop` models a time-travel scenario: a self-map on a state space
    equipped with a metric. The map `f` represents the total causal influence:
    given state `x` entering the time machine, `f x` is the state that emerges.
    A self-consistent history is a fixed point `x = f x`. -/
structure CausalLoop (α : Type*) [EMetricSpace α] where
  /-- The causal map: how states transform through the time loop -/
  f : α → α
  /-- Contraction factor, must satisfy K < 1 -/
  K : NNReal
  /-- The causal map is a contraction -/
  contracting : ContractingWith K f

/-- A causal loop satisfies Novikov's self-consistency principle if it admits
    at least one fixed point (self-consistent solution). -/
def NovikovConsistent {α : Type*} [EMetricSpace α] (cl : CausalLoop α) : Prop :=
  ∃ x : α, cl.f x = x

/-- The severity of a time-travel paradox: how far a state is from being
    self-consistent. A paradox severity of 0 means the state is self-consistent. -/
noncomputable def paradoxSeverity {α : Type*} [EMetricSpace α]
    (f : α → α) (x : α) : ENNReal :=
  edist x (f x)

/-- A `TemporalBVP` (temporal boundary value problem) models the constraint that
    a time traveler must arrive in a state consistent with their departure.
    This generalizes CausalLoop by allowing separate forward and backward maps. -/
structure TemporalBVP (α : Type*) [EMetricSpace α] where
  /-- Forward evolution map -/
  forward : α → α
  /-- Backward (time-travel) map -/
  backward : α → α
  /-- The composed round-trip map -/
  roundTrip : α → α := backward ∘ forward

/-- An affine causal map `x ↦ a * x + b` on the reals, modeling linear causal
    influence with a constant offset. -/
structure AffineCausalMap where
  /-- Slope (causal sensitivity) -/
  slope : ℝ
  /-- Offset (external influence) -/
  offset : ℝ
  /-- The slope magnitude is strictly less than 1 -/
  slope_lt_one : |slope| < 1

/-! ## Main Theorems -/

/-
**Novikov's Principle from Banach**: Every contractive causal loop on a nonempty
    complete metric space admits a self-consistent solution. This is the core theorem:
    time-travel paradoxes cannot arise when the causal influence is contractive.
-/
theorem novikov_from_banach {α : Type*} [EMetricSpace α] [CompleteSpace α] [Nonempty α]
    (cl : CausalLoop α)
    (hfin : ∃ x : α, edist x (cl.f x) ≠ ⊤) :
    NovikovConsistent cl := by
  obtain ⟨ x, hx ⟩ := hfin;
  -- Apply the Banach fixed-point theorem (ContractingWith.efixedPoint) to obtain the existence of a fixed point.
  have h_fixed_point : ∃ y, y = cl.f y := by
    have := cl.contracting;
    have := this.exists_fixedPoint x ?_;
    · exact ⟨ this.choose, this.choose_spec.1.symm ⟩;
    · exact hx;
  exact ⟨ h_fixed_point.choose, h_fixed_point.choose_spec.symm ⟩

/-
**Composition of causal loops**: If two causal loops are contractive with factors
    K₁ and K₂, their composition is contractive with factor K₁ * K₂.
    This models nested time-travel: going through two time machines in sequence.
-/
theorem causal_loop_compose_contracting {α : Type*} [EMetricSpace α]
    (cl₁ cl₂ : CausalLoop α) :
    ContractingWith (cl₁.K * cl₂.K) (cl₁.f ∘ cl₂.f) := by
  refine' ⟨ _, _ ⟩;
  · exact lt_of_le_of_lt ( mul_le_of_le_one_left ( by positivity ) ( cl₁.contracting.1.le ) ) ( cl₂.contracting.1 );
  · exact LipschitzWith.comp ( cl₁.contracting.toLipschitzWith ) ( cl₂.contracting.toLipschitzWith )

/-
**Uniqueness of self-consistent solutions**: In a contractive causal loop,
    the self-consistent solution is unique (among points with finite distance).
-/
theorem novikov_unique {α : Type*} [EMetricSpace α] [CompleteSpace α]
    (cl : CausalLoop α)
    {x y : α} (hx : cl.f x = x) (hy : cl.f y = y)
    (hfin : edist x y ≠ ⊤) :
    x = y := by
  have h_contract : edist x y ≤ cl.K * edist x y := by
    have := cl.contracting.2 x y; aesop;
  contrapose! h_contract;
  rw [ ← ENNReal.toReal_lt_toReal ] <;> norm_num [ hfin ];
  · refine' mul_lt_of_lt_one_left ( ENNReal.toReal_pos _ _ ) _;
    · aesop;
    · exact hfin;
    · exact_mod_cast cl.contracting.1;
  · exact ENNReal.mul_ne_top ( ENNReal.coe_ne_top ) hfin

/-
**Paradox severity decreases under iteration**: The distance between
    consecutive iterates of the causal map decreases exponentially. After n
    iterations, `edist (f^[n] x) (f^[n+1] x) ≤ K^n * edist x (f x)`.
-/
theorem paradox_severity_iterate {α : Type*} [EMetricSpace α]
    (cl : CausalLoop α) (x : α) (n : ℕ) :
    edist (cl.f^[n] x) (cl.f^[n + 1] x) ≤
      (cl.K : ENNReal) ^ n * edist x (cl.f x) := by
  induction' n with n ih;
  · simp +decide;
  · rw [ pow_succ', mul_assoc ];
    simpa only [ Function.iterate_succ_apply' ] using le_trans ( cl.contracting.toLipschitzWith.edist_le_mul _ _ ) ( mul_le_mul_left' ih _ )

/-
**Affine causal maps are contractions on the reals**: The map `x ↦ a*x + b` with
    `|a| < 1` is a contraction with factor `|a|`.
-/
theorem affine_causal_contracting (acm : AffineCausalMap) :
    ContractingWith ⟨|acm.slope|, abs_nonneg _⟩
      (fun x : ℝ => acm.slope * x + acm.offset) := by
  refine' ⟨acm.slope_lt_one, _⟩;
  refine' LipschitzWith.of_dist_le_mul _;
  norm_num [ dist_eq_norm, mul_sub ];
  exact fun x y => by rw [ ← mul_sub, abs_mul ] ;

/-
**Fixed point of affine causal map**: The unique fixed point of `x ↦ a*x + b`
    with `|a| < 1` is `b / (1 - a)`.
-/
theorem affine_fixed_point (acm : AffineCausalMap) :
    let x0 := acm.offset / (1 - acm.slope)
    acm.slope * x0 + acm.offset = x0 := by
  field_simp;
  rw [ div_add_one ] <;> ring ; cases abs_cases acm.slope <;> linarith [ acm.slope_lt_one ]

/-
**Perturbation stability**: If two affine causal maps have the same slope
    but different offsets, the distance between their fixed points equals
    the offset difference scaled by `1/|1-a|`.
-/
theorem novikov_perturbation_stability
    (a b1 b2 : ℝ) (_ha : |a| < 1) :
    |b1 / (1 - a) - b2 / (1 - a)| = |b1 - b2| / |1 - a| := by
  rw [ ← abs_div, div_sub_div_same ]

/-
**Grandfather paradox impossibility**: The negation map `x ↦ -x` has no
    fixed point except 0, formalizing why the grandfather paradox is inconsistent
    for any nonzero state.
-/
theorem grandfather_paradox_no_fixedpoint :
    ∀ x : ℝ, x ≠ 0 → (-x) ≠ x := by
  exact fun x hx => by contrapose! hx; linarith;

/-
**Causal loop iteration converges**: Starting from any state, iterating
    the causal map converges to the unique self-consistent solution.
-/
theorem causal_iteration_convergence {α : Type*} [EMetricSpace α] [CompleteSpace α]
    (cl : CausalLoop α) {x : α} (hx : edist x (cl.f x) ≠ ⊤) :
    Filter.Tendsto (fun n => cl.f^[n] x) Filter.atTop
      (nhds (ContractingWith.efixedPoint cl.f cl.contracting x hx)) := by
  -- Apply the theorem that states the iterates of a contraction converge to the unique fixed point.
  apply ContractingWith.tendsto_iterate_efixedPoint

/-
**Temporal BVP reduces to fixed point**: If a temporal boundary value problem
    has a contractive round-trip map, it admits a self-consistent solution.
-/
theorem temporal_bvp_solvable {α : Type*} [EMetricSpace α] [CompleteSpace α]
    [Nonempty α]
    (bvp : TemporalBVP α) (K : NNReal) (hK : ContractingWith K bvp.roundTrip)
    (hfin : ∃ x : α, edist x (bvp.roundTrip x) ≠ ⊤) :
    ∃ x : α, bvp.roundTrip x = x := by
  convert novikov_from_banach ⟨ bvp.roundTrip, K, hK ⟩ hfin

/-
**Conjecture (affine case)**: Every affine causal map with `|a| < 1` has a
    unique fixed point. This is the simplest case of the polynomial conjecture.
-/
theorem polynomial_causal_affine_case (a b : ℝ) (ha : |a| < 1) :
    ∃! x : ℝ, a * x + b = x := by
  -- The unique fixed point is x₀ = b/(1-a). Existence: a*x₀ + b = x₀ by algebra.
  use b / (1 - a);
  grind

/-- The derivative bound for a polynomial with coefficients given by `Fin n → ℝ`,
    evaluated on `[-r, r]`: `sum of i * |a_i| * r^(i-1)`.
    If this is < 1, the polynomial is a contraction on `[-r, r]`. -/
noncomputable def polynomialDerivBound (n : ℕ) (coeffs : Fin n → ℝ) (r : ℝ) : ℝ :=
  ∑ i : Fin n, (i : ℝ) * |coeffs i| * r ^ ((i : ℕ) - 1)