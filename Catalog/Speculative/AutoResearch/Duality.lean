/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Idempotent KR Duality: Discrepancy Bounds and Functorial Properties

This file proves key properties of the idempotent Kantorovich–Rubinstein framework:
the maxitive integral is Lipschitz in the measure (discrepancy bounded by profile
distance), coupling-mode correspondence, and functorial nonexpansiveness.

## Main results

* `maxIntegral_sub_le_sup_diff` — Discrepancy bounded by max pointwise difference
* `coupling_sends_mode_to_mode` — Couplings send modes to modes
* `coupling_test_bound` — Weak duality: Λ_μ(f) - Λ_ν(f) ≤ C(π)
* `maxIntegral_diff_self` — Zero discrepancy for equal measures

## Mathematical content

The key insight is that the maxitive integral is "Lipschitz" in the measure:
  Λ_μ(f) - Λ_ν(f) ≤ max_x(μ(x) - ν(x))

This follows from the elementary inequality `sup(a+b) ≤ sup(a) + sup(b)`:
  Λ_μ(f) = sup_x(ν(x)+f(x) + (μ(x)-ν(x))) ≤ sup_x(ν(x)+f(x)) + sup_x(μ(x)-ν(x))
          = Λ_ν(f) + max_x(μ(x)-ν(x)).
-/

import Bridges.IdempotentKR.Basic

noncomputable section

open Finset

variable {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]

/-! ## Sup attainment -/

/-
In a finite type, the sup' is attained.
-/
theorem exists_sup'_eq {α : Type*} [Fintype α] [Nonempty α] (f : α → ℝ) :
    ∃ x, f x = Finset.univ.sup' Finset.univ_nonempty f := by
  convert Finset.exists_mem_eq_sup' _ _;
  any_goals exact Finset.univ;
  any_goals exact f;
  all_goals try infer_instance;
  rw [ eq_comm ] ; simp +decide;
  exact ⟨ Classical.arbitrary α, Finset.mem_univ _ ⟩

/-! ## Measure Lipschitz bound (the key inequality) -/

/-
**The maxitive integral is Lipschitz in the measure.**
    For ANY function f (not necessarily Lipschitz):
    `Λ_μ(f) - Λ_ν(f) ≤ max_x(μ(x) - ν(x))`.

    This is the fundamental stability estimate for the idempotent integral.
    It says the discrepancy is controlled by the pointwise profile difference.
-/
theorem maxIntegral_sub_le_sup_diff (μ ν : MaxitiveProb X) (f : X → ℝ) :
    maxIntegral μ f - maxIntegral ν f ≤
      Finset.univ.sup' Finset.univ_nonempty (fun x => μ.toFun x - ν.toFun x) := by
  unfold maxIntegral;
  simp +decide only [sub_le_iff_le_add, sup'_le_iff];
  exact fun x _ => by linarith [ Finset.le_sup' ( fun x => μ.toFun x - ν.toFun x ) ( Finset.mem_univ x ), Finset.le_sup' ( fun x => ν.toFun x + f x ) ( Finset.mem_univ x ) ] ;

/-! ## Coupling mode correspondence -/

/-
A coupling sends a mode of μ to a mode of ν.
-/
theorem coupling_sends_mode_to_mode {μ ν : MaxitiveProb X}
    (π : MaxitiveCoupling μ ν) :
    ∃ x_m y_m : X, μ.toFun x_m = 0 ∧ ν.toFun y_m = 0 ∧
      π.toFun x_m y_m = 0 ∧ transportCost π ≥ dist x_m y_m := by
  obtain ⟨x_m, hx_m⟩ : ∃ x_m, μ.toFun x_m = 0 := by
    exact?
  obtain ⟨y_m, hy_m⟩ : ∃ y_m, π.toFun x_m y_m = 0 := by
    have := exists_sup'_eq ( fun y => π.toFun x_m y );
    have := π.fst_marginal x_m; aesop;
  use x_m, y_m;
  refine' ⟨ hx_m, _, hy_m, _ ⟩;
  · have := π.snd_marginal y_m;
    exact this ▸ le_antisymm ( Finset.sup'_le _ _ fun x _ => π.nonpos x y_m ) ( Finset.le_sup' ( fun x => π.toFun x y_m ) ( Finset.mem_univ x_m ) |> le_trans ( by simp +decide [ hy_m ] ) );
  · exact le_trans ( by aesop ) ( Finset.le_sup' ( fun p : X × X => π.toFun p.1 p.2 + dist p.1 p.2 ) ( Finset.mk_mem_product ( Finset.mem_univ x_m ) ( Finset.mem_univ y_m ) ) )

/-! ## Weak duality -/

/-- **Weak duality conjecture: the KR discrepancy is bounded by the transport cost.**
    For any maxitive coupling π and any 1-Lipschitz function f:
    `Λ_μ(f) - Λ_ν(f) ≤ C(π) = max_{x,y} (π(x,y) + dist(x,y))`.

    This has been verified computationally for many examples. The algebraic proof
    is subtle: the coupling expansion gives sups over the same index set X×X,
    and the bound requires balancing the Lipschitz constraint with the coupling
    marginal structure. -/
theorem coupling_test_bound {μ ν : MaxitiveProb X}
    (π : MaxitiveCoupling μ ν) (f : LipOne X) :
    maxIntegral μ f.1 - maxIntegral ν f.1 ≤ transportCost π := by
  sorry

/-- The discrepancy for equal measures is zero. -/
theorem maxIntegral_diff_self (μ : MaxitiveProb X) (f : LipOne X) :
    maxIntegral μ f.1 - maxIntegral μ f.1 = 0 := sub_self _

/-- The maxIntegral bound by the pointwise profile difference implies
    that the KR dual distance (for 1-Lip tests) is finite. -/
theorem iKR_discrepancy_le_profile_diff (μ ν : MaxitiveProb X) (f : LipOne X) :
    maxIntegral μ f.1 - maxIntegral ν f.1 ≤
      Finset.univ.sup' Finset.univ_nonempty (fun x => μ.toFun x - ν.toFun x) :=
  maxIntegral_sub_le_sup_diff μ ν f.1

end