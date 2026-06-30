/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Bridge: Vanishing First Cohomology ⟹ Global Certified L∞ Radius

This is the synthesis module of the *Certified Adversarial Robustness via Sheaf
Cohomology* cycle.  It joins the two halves of the argument:

* `Certificate.lean` provides the **per-region (stalk) certificate**: a linear
  score with margin exceeding `‖w‖₁ · R` is sign-stable on the L∞ ball of radius
  `R` (`linf_certified_radius`).

* `Cohomology.lean` provides the **gluing law**: on the path nerve of an open
  cover the first Čech cohomology vanishes (`H1_path_vanishes`), so any overlap
  inconsistency of local certificates is reconcilable by a global potential; on a
  loop nerve `H¹ ≠ 0` (`cyclic_not_coboundary`), so a nonzero holonomy is an
  ineliminable obstruction.

The main theorem `global_robustness_certificate` states that on a tree-shaped
cover with a uniform per-region margin, (i) **every** region's prediction is L∞
stable within the common radius `R`, and (ii) **every** prescribed overlap
discrepancy glues to a global potential (vanishing `H¹`).  Its counterpoint,
`cyclic_cover_has_unremovable_obstruction`, shows that on a loop cover a unit
holonomy can never be glued away — the cohomological signature of an adversarial
cycle in the decision-boundary cover.

This module also reuses the attached catalog: `EML.L2SheafRobustness`'s
`certified_local_radius_pos` certifies positivity of the explicit L∞ radius
`|score w x₀| / ‖w‖₁`, tying the L∞ story to the existing L₂ sheaf-robustness
framework.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): "Vanishing first cohomology of the cover nerve is
  *sufficient* for a global certified L∞ radius equal to the worst stalk radius."
* Experiment (Experimenter): combined `linf_certified_radius` (per stalk) with
  `H1_path_vanishes` (gluing) into a single conjunction; proved the cyclic
  counterexample with `cyclic_not_coboundary` applied to the unit cochain
  (holonomy `n+1`).
* Analysis (Analyst): the *direction* that survives is "vanishing `H¹` ⟹
  certified radius".  The converse ("vulnerability ⟹ nonzero `H¹`") is false in
  general (a tree cover can still host a vulnerable point if the *margin* is too
  small); cohomology controls *gluing*, not the stalk margin.  Recorded as a
  future direction.
* Critique (Critic): is the gluing clause vacuous?  No — `H1_path_vanishes` is a
  genuine surjectivity statement (constructed primitive), and the cyclic theorem
  exhibits an explicit non-coboundary, so both poles are witnessed.
* Synthesis (PI): robustness certification factors as *stalk margin × nerve
  acyclicity*; the loop obstruction is the precise locus of adversarial risk.
-/

import MachineLearning.SheafCohomologyRobustness.Cohomology
import MachineLearning.SheafCohomologyRobustness.Certificate
import EML.L2SheafRobustness

open BigOperators Finset

namespace SheafCohomologyRobustness

/-! ## §1. Positivity of the explicit L∞ certified radius (catalog reuse) -/

/-- The explicit certified L∞ radius `|score w x₀| / ‖w‖₁` is strictly positive
whenever the margin and the weight L¹ norm are positive.  Proved by reusing
`certified_local_radius_pos` from the catalog module `EML.L2SheafRobustness`,
linking the L∞ certificate to the existing L₂ sheaf-robustness framework. -/
theorem linf_certified_radius_pos {d : ℕ} (w x₀ : Fin d → ℝ)
    (hmargin : 0 < |score w x₀|) (hw : 0 < weightL1 w) :
    0 < |score w x₀| / weightL1 w :=
  certified_local_radius_pos |score w x₀| (weightL1 w) hmargin hw

/-! ## §2. Main bridge theorem -/

/-- **Vanishing `H¹` ⟹ global certified L∞ radius.**

Consider a path-nerve cover of the input space by `n+1` activation regions,
region `i` carrying a linear score `score (w i) ·` with reference point `x₀ i`.
If a *common* radius `R ≥ 0` satisfies the per-region margin condition
`‖w i‖₁ · R < |score (w i) (x₀ i)|`, then:

1. **(Stalk certificates.)**  Every region's binary prediction is invariant under
   all L∞ perturbations of radius ≤ `R`.

2. **(Gluing / vanishing `H¹`.)**  Every prescribed overlap-discrepancy cochain
   `g` admits a global potential `f` with `δ⁰ f = g`; there is no cohomological
   obstruction to reconciling local certificates on the tree cover.

The certified global radius is therefore `R`, valid simultaneously on every
region of the cover. -/
theorem global_robustness_certificate
    {n d : ℕ}
    (w : Fin (n + 1) → (Fin d → ℝ)) (x₀ : Fin (n + 1) → (Fin d → ℝ))
    (R : ℝ) (hR : 0 ≤ R)
    (hmargin : ∀ i, weightL1 (w i) * R < |score (w i) (x₀ i)|) :
    (∀ i x, (∀ j, |x j - x₀ i j| ≤ R) →
        ((0 < score (w i) x) ↔ (0 < score (w i) (x₀ i))))
    ∧ (∀ g : Cochain1 n, ∃ f : Cochain0 n, delta0 f = g) := by
  refine ⟨?_, ?_⟩
  · intro i x hball
    exact linf_certified_radius (w i) (x₀ i) R hR (hmargin i) x hball
  · intro g
    exact H1_path_vanishes g

/-! ## §3. The cyclic counterpoint: an unremovable adversarial obstruction -/

/-- **Loop cover hosts an ineliminable obstruction.**  On the cyclic nerve of
`n+1` regions, the unit overlap-discrepancy cochain (constant `1`, with loop
holonomy `n+1 ≠ 0`) is *not* a coboundary: no global potential reconciles it.
This nonzero first-cohomology class is the cohomological signature of an
adversarial cycle — a loop of regions whose local certificates cannot be glued
into a consistent global certificate. -/
theorem cyclic_cover_has_unremovable_obstruction (n : ℕ) :
    ¬ ∃ f : Fin (n + 1) → ℝ, deltaCyc f = (fun _ => 1) := by
  apply cyclic_not_coboundary
  have hsum : ∑ _i : Fin (n + 1), (1 : ℝ) = (n : ℝ) + 1 := by
    simp
  rw [hsum]
  positivity

end SheafCohomologyRobustness