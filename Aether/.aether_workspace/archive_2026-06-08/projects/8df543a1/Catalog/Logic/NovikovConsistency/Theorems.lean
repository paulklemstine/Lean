/-
# Novikov Consistency Theorems

Main results connecting Novikov's self-consistency principle to the Banach
fixed-point theorem.

## Main Results

1. `novikov_from_banach`: Every causal loop on a complete nonempty metric space
   is Novikov-consistent (has a self-consistent solution).

2. `novikov_unique`: The self-consistent solution is unique.

3. `affine_causal_is_contracting`: Affine maps with |a| < 1 are contracting.

4. `affine_fixed_point_correct`: The explicit fixed point b/(1-a) is correct.

5. `bvp_solution_is_consistent`: The BVP solution satisfies the boundary condition.

6. `composed_loop_consistent`: Sequential traversal of two CTCs with
   sufficiently damped dynamics admits a unique self-consistent history.

7. `novikov_iterate_convergence`: Iterating the causal map from any initial
   state converges to the self-consistent solution.
-/

import Mathlib
import Logic.NovikovConsistency.Defs

open Metric Set Function NNReal

noncomputable section

/-! ## Core Novikov Theorem -/

/-
**Novikov's Self-Consistency Principle (from Banach).**
Every contracting causal evolution on a complete nonempty metric space
admits a self-consistent solution. This is the central theorem:
the physical principle of self-consistency follows from the mathematical
structure of contractive dynamics on complete metric spaces.
-/
theorem novikov_from_banach {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (C : CausalLoop α) : NovikovConsistent C := by
  -- Apply the Banach fixed-point theorem to conclude that there exists a unique fixed point.
  have h_fixed_point : ∃ x : α, ContractingWith.fixedPoint C.evolve C.contracting = x ∧ IsFixedPt C.evolve x := by
    exact ⟨ _, rfl, ContractingWith.fixedPoint_isFixedPt _ ⟩;
  exact ⟨ _, h_fixed_point.choose_spec.2 ⟩

/-
**Uniqueness of self-consistent history.**
Under contracting dynamics, the self-consistent solution is unique.
Physically: there is exactly one way history can unfold self-consistently
through a contracting CTC.
-/
theorem novikov_unique {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (C : CausalLoop α) (x y : α) (hx : IsFixedPt C.evolve x) (hy : IsFixedPt C.evolve y) :
    x = y := by
  obtain ⟨ K, hK ⟩ := C;
  rename_i h;
  convert h.fixedPoint_unique' hx hy

/-! ## Affine Causal Maps -/

/-
An affine map x ↦ a*x + b with |a| < 1 is Lipschitz with constant |a|.
-/
theorem affine_lipschitz (f : AffineCausalMap) :
    LipschitzWith ⟨|f.a|, abs_nonneg _⟩ f.eval := by
  unfold AffineCausalMap.eval; simp +decide [ lipschitzWith_iff_norm_sub_le ] ;
  exact fun x y => by rw [ ← mul_sub, abs_mul ] ;

/-
An affine map with |a| < 1 is a contraction.
-/
theorem affine_causal_is_contracting (f : AffineCausalMap) :
    ContractingWith ⟨|f.a|, abs_nonneg _⟩ f.eval := by
  constructor;
  · exact f.ha;
  · exact affine_lipschitz f

/-
The explicit formula b/(1-a) is a fixed point of x ↦ ax + b when |a| < 1.
-/
theorem affine_fixed_point_correct (f : AffineCausalMap) :
    IsFixedPt f.eval f.fixedPoint := by
  unfold AffineCausalMap.eval AffineCausalMap.fixedPoint;
  exact Eq.symm ( by linear_combination mul_inv_cancel₀ ( show ( 1 - f.a ) ≠ 0 by cases abs_cases f.a <;> linarith [ f.ha ] ) * f.b )

/-
Affine causal maps on ℝ are Novikov-consistent, with the unique
self-consistent history at x = b/(1-a).
-/
theorem affine_novikov_consistent (f : AffineCausalMap) :
    ∃! x : ℝ, f.eval x = x := by
  unfold AffineCausalMap.eval;
  use f.b / (1 - f.a);
  constructor;
  · linarith [ mul_div_cancel₀ f.b ( show ( 1 - f.a ) ≠ 0 from sub_ne_zero_of_ne <| Ne.symm <| by intro h; have := f.ha; norm_num [ h ] at this ) ];
  · exact fun x hx => eq_div_of_mul_eq ( by cases abs_cases f.a <;> linarith [ f.ha ] ) ( by linarith )

/-! ## BVP Solution -/

/-
The BVP solution from Banach's theorem satisfies the boundary condition.
-/
theorem bvp_solution_is_consistent {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (bvp : TimeTravelBVP α) : IsFixedPt bvp.evolve bvp.solution := by
  exact bvp.hContract.fixedPoint_isFixedPt

/-
The BVP solution is the unique solution.
-/
theorem bvp_solution_unique {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (bvp : TimeTravelBVP α) (x : α) (hx : IsFixedPt bvp.evolve x) :
    x = bvp.solution := by
  convert bvp.hContract.fixedPoint_unique' _;
  rotate_left;
  exact bvp.solution;
  exact x;
  · exact bvp_solution_is_consistent bvp;
  · aesop

/-! ## Composition of Causal Loops -/

/-
Composition of two Lipschitz maps is Lipschitz with the product constant.
-/
theorem lipschitz_comp_of_causal {α : Type*} [MetricSpace α]
    (C : CausalLoop α) (D : CausalLoop α) :
    LipschitzWith (C.lipK * D.lipK) (D.evolve ∘ C.evolve) := by
  rw [ mul_comm ];
  exact D.contracting.2.comp C.contracting.2

/-
The composition of two causal loops is contracting when the product
of their Lipschitz constants is less than 1.
-/
theorem composed_loop_contracting {α : Type*} [MetricSpace α]
    (comp : ComposedCausalLoop α) :
    ContractingWith (comp.loop₁.lipK * comp.loop₂.lipK)
      (comp.loop₂.evolve ∘ comp.loop₁.evolve) := by
  constructor;
  · exact comp.hProd;
  · convert lipschitz_comp_of_causal comp.loop₁ comp.loop₂ using 1

/-
Sequential traversal of two CTCs admits a self-consistent history
when the composed dynamics are contracting.
-/
theorem composed_loop_consistent {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (comp : ComposedCausalLoop α) :
    ∃ x : α, (comp.loop₂.evolve ∘ comp.loop₁.evolve) x = x := by
  obtain ⟨x, hx⟩ := novikov_from_banach (CausalLoop.mk (comp.loop₂.evolve ∘ comp.loop₁.evolve) (comp.loop₁.lipK * comp.loop₂.lipK) (composed_loop_contracting comp));
  exact ⟨ x, hx ⟩

/-! ## Convergence of Iterates -/

/-
**Convergence to self-consistency.**
Iterating the causal evolution map from any initial state converges
to the unique self-consistent solution. This models the physical
intuition that "the universe settles into consistency."
-/
theorem novikov_iterate_convergence {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (C : CausalLoop α) (x₀ : α) :
    Filter.Tendsto (fun n => C.evolve^[n] x₀) Filter.atTop
      (nhds (ContractingWith.fixedPoint C.evolve C.contracting)) := by
  convert C.contracting.tendsto_iterate_fixedPoint x₀ using 1

/-! ## Perturbation Stability -/

/-
If a causal evolution is a contraction with constant K, then
perturbing the initial state by ε results in the n-th iterate
being at most K^n * ε away. The self-consistent solution is stable.
-/
theorem novikov_stability {α : Type*} [MetricSpace α]
    (C : CausalLoop α) (x y : α) (n : ℕ) :
    dist (C.evolve^[n] x) (C.evolve^[n] y) ≤ C.lipK ^ n * dist x y := by
  induction' n with n ih generalizing x y <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ];
  exact le_trans ( C.contracting.toLipschitzWith.dist_le_mul _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ _ ) ( NNReal.coe_nonneg _ ) )

end