/-
Copyright (c) 2026 Tropical Neural Geometry Research Team. All rights reserved.
Released under Apache 2.0 license.

# Close Proofs: topology and convex geometry of ReLU decision boundaries

This file *extends* `MachineLearning.TropicalReLUBridge` (the Zhang–Naitzat–Lim
correspondence between ReLU networks and tropical/max-plus rational functions).
That file proved the algebraic bridge: every one-hidden-layer ReLU network is a
**tropical rational function** `f = p − q` (a difference of two tropical
polynomials), and every tropical polynomial is **convex**.

Here we push the bridge into *topology* and *convex analysis*:

* `IsTropPoly.continuous`  — a tropical polynomial is continuous (a finite max
  of affine maps);
* `IsTropRational.continuous` — hence every tropical rational function, and in
  particular every ReLU-network classifier, is continuous;
* `IsTropRational.isClosed_decisionBoundary` — therefore the **decision
  boundary** `{x | f x = 0}` of a ReLU classifier is a *closed* set;
* `IsTropRational.differenceOfConvex` / `reluNet_differenceOfConvex` — every
  tropical rational function (hence every one-hidden-layer ReLU network) is a
  **difference of convex functions (DC)**.  This is the formal bridge from the
  tropical picture to *DC programming* / convex analysis.

We also *stress-test the frontier* adversarially:

* `IsTropRational.neg`, `IsTropRational.add` — the tropical-rational (= DC) class
  is closed under negation and sums (so it is genuinely a vector space of DC
  functions), whereas the tropical-*polynomial* (= convex) class is not (negation
  breaks convexity);
* `exists_tropRational_not_convexOn` — convexity does **not** survive the passage
  from tropical polynomials to tropical rationals: there is an explicit ReLU
  rational function (`x ↦ −ReLU(x)`) that is not convex. This pins down exactly
  where the convexity theorem of the base file stops holding.
-/

import Mathlib
import MachineLearning.TropicalReLUBridge

open scoped BigOperators
open Finset
open TropicalReLUBridge

namespace TropicalReLUBoundary

variable {d : ℕ}

/-
!-- Lab Notebook -- !--
Hypothesis: The algebraic bridge `IsTropRational` should upgrade to genuine
topological/convex-analytic structure: continuity, closed decision boundaries,
and a difference-of-convex (DC) decomposition.
Result: All four upgrades hold and are proved below; convexity itself does NOT
upgrade (adversarial counterexample `exists_tropRational_not_convexOn`).
Insight: The tropical-polynomial class = nonnegative-coefficient max-affine =
convex PL functions; the tropical-rational class = the linear span (under
subtraction) = DC functions = exactly the continuous PL functions that ReLU
nets compute. Continuity is the common floor; convexity is lost at the rational
(network) level, but closedness of the decision boundary survives.
Failure analysis: A naive attempt to prove the decision boundary is a finite
union of hyperplanes fails — it is only a closed *tropical hypersurface*, not a
hyperplane arrangement; closedness (via continuity) is the right, robust claim.
-/

/-! ### Continuity of tropical polynomials and rationals -/

-- !-- An affine functional is continuous: a finite sum of continuous coordinate -- !--
-- !-- products plus a constant. -- !--
theorem affEval_continuous (ab : (Fin d → ℝ) × ℝ) :
    Continuous (fun x => affEval ab x) := by
  unfold affEval
  exact (continuous_finset_sum _ (fun j _ => continuous_const.mul (continuous_apply j))).add
    continuous_const

-- !-- A tropical polynomial is continuous: a finite `sup'` of continuous affine -- !--
-- !-- maps, via `Continuous.finset_sup'_apply`. -- !--
theorem IsTropPoly.continuous {f : (Fin d → ℝ) → ℝ} (hf : IsTropPoly f) :
    Continuous f := by
  obtain ⟨S, hS, hfS⟩ := hf
  have hcongr : f = fun x => S.sup' hS (fun ab => affEval ab x) := funext hfS
  rw [hcongr]
  exact Continuous.finset_sup'_apply hS (fun ab _ => affEval_continuous ab)

-- !-- A tropical rational function `f = p - q` is continuous (difference of two -- !--
-- !-- continuous tropical polynomials). -- !--
theorem IsTropRational.continuous {f : (Fin d → ℝ) → ℝ} (hf : IsTropRational f) :
    Continuous f := by
  obtain ⟨p, q, hp, hq, hf⟩ := hf
  have hcongr : f = fun x => p x - q x := funext hf
  rw [hcongr]
  exact (IsTropPoly.continuous hp).sub (IsTropPoly.continuous hq)

/-! ### Decision boundaries of ReLU classifiers are closed -/

-- !-- The decision boundary of a tropical-rational classifier is a closed set: -- !--
-- !-- it is `f ⁻¹' {0}` for the continuous function `f`. -- !--
theorem IsTropRational.isClosed_decisionBoundary {f : (Fin d → ℝ) → ℝ}
    (hf : IsTropRational f) :
    IsClosed (decisionBoundary f) := by
  have hc := IsTropRational.continuous hf
  have hpre : decisionBoundary f = f ⁻¹' {(0 : ℝ)} := by
    ext x; simp [decisionBoundary]
  rw [hpre]
  exact isClosed_singleton.preimage hc

/-! ### Tropical rational functions form a DC (difference-of-convex) class -/

-- !-- Negation of a tropical rational function is tropical rational (swap p and q). -- !--
theorem IsTropRational.neg {f : (Fin d → ℝ) → ℝ} (hf : IsTropRational f) :
    IsTropRational (fun x => - f x) := by
  obtain ⟨p, q, hp, hq, hf⟩ := hf
  exact ⟨q, p, hq, hp, fun x => by show - f x = q x - p x; rw [hf]; ring⟩

-- !-- Sum of two tropical rational functions is tropical rational: -- !--
-- !-- (p₁ - q₁) + (p₂ - q₂) = (p₁ + p₂) - (q₁ + q₂), using `IsTropPoly.add`. -- !--
theorem IsTropRational.add {f g : (Fin d → ℝ) → ℝ}
    (hf : IsTropRational f) (hg : IsTropRational g) :
    IsTropRational (fun x => f x + g x) := by
  obtain ⟨p1, q1, hp1, hq1, hf⟩ := hf
  obtain ⟨p2, q2, hp2, hq2, hg⟩ := hg
  exact ⟨fun x => p1 x + p2 x, fun x => q1 x + q2 x,
    hp1.add hp2, hq1.add hq2, fun x => by
      show f x + g x = p1 x + p2 x - (q1 x + q2 x); rw [hf, hg]; ring⟩

-- !-- DC bridge: every tropical rational function is a difference of two CONVEX -- !--
-- !-- functions, since both tropical-polynomial parts are convex -- !--
-- !-- (`IsTropPoly.convexOn`). -- !--
theorem IsTropRational.differenceOfConvex {f : (Fin d → ℝ) → ℝ}
    (hf : IsTropRational f) :
    ∃ p q : (Fin d → ℝ) → ℝ,
      ConvexOn ℝ Set.univ p ∧ ConvexOn ℝ Set.univ q ∧ ∀ x, f x = p x - q x := by
  obtain ⟨p, q, hp, hq, hf⟩ := hf
  exact ⟨p, q, hp.convexOn, hq.convexOn, hf⟩

-- !-- Specialization: every one-hidden-layer ReLU network output is a difference -- !--
-- !-- of two convex functions (DC), via `reluNet_isTropRational`. -- !--
theorem reluNet_differenceOfConvex {n : ℕ} (A : Fin n → (Fin d → ℝ)) (bh : Fin n → ℝ)
    (c : Fin n → ℝ) (b0 : ℝ) :
    ∃ p q : (Fin d → ℝ) → ℝ,
      ConvexOn ℝ Set.univ p ∧ ConvexOn ℝ Set.univ q ∧
        ∀ x, reluNet A bh c b0 x = p x - q x :=
  IsTropRational.differenceOfConvex (reluNet_isTropRational A bh c b0)

/-! ### Adversarial frontier: convexity is lost at the rational level -/

/-
!-- The map `x ↦ −ReLU(x₀)` on `ℝ¹` is tropical rational (`0 − ReLU`) but NOT -- !--
!-- convex: at x=(-1), y=(1), midpoint m=(0) we have f m = 0 while -- !--
!-- (f x + f y)/2 = -1/2, violating the convexity inequality. This shows the -- !--
!-- base file's `IsTropPoly.convexOn` does not extend to `IsTropRational`. -- !--
-/
theorem exists_tropRational_not_convexOn :
    ∃ f : (Fin 1 → ℝ) → ℝ, IsTropRational f ∧ ¬ ConvexOn ℝ Set.univ f := by
  refine ⟨fun x => - relu (affEval ((fun _ => 1), 0) x), ?_, ?_⟩
  · -- tropical rational: `0 - ReLU(affine)`
    refine ⟨fun _ => 0, fun x => relu (affEval ((fun _ => 1), 0) x),
      const_isTropPoly 0, (affine_isTropPoly (fun _ => 1) 0).relu, ?_⟩
    intro x; ring
  · -- not convex: violated at x = -1, y = 1, midpoint 0
    intro h
    have key := h.2 (Set.mem_univ (fun _ => (-1 : ℝ))) (Set.mem_univ (fun _ => (1 : ℝ)))
      (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num)
    simp only [affEval, relu, smul_eq_mul, Fin.sum_univ_one] at key
    norm_num at key

end TropicalReLUBoundary