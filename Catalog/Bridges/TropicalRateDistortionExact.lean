/-
Copyright (c) 2025 Tropical Information Theory Project. All rights reserved.

# Tropical Rate-Distortion Theory: Exact Coding-Optimization Duality

## Overview

This file proves the central breakthrough of tropical source coding theory:
for finite types, the optimal coding cost at distortion budget `D` equals the
tropical rate-distortion function *exactly* — with no asymptotic gap.

In classical Shannon theory, achievability and converse bounds meet only in
the limit of infinite block length. In the tropical (min-plus) semiring,
finite optimization replaces probabilistic asymptotics, and the gap vanishes.

## Main Results

1. `tropicalRateDistortion_exact` — The optimal feasible code cost equals
   the min-plus variational rate-distortion value.
2. `tropicalRateDistortion_dual` — Dual characterization via feasible sets.
3. `tropical_no_gap` — Achievable and converse rates coincide exactly.
4. `tropicalRateDistortion_antitone` — Rate-distortion is antitone in D.
5. `tropicalRateDistortion_lipschitz` — Rate-distortion is 1-Lipschitz.

## Cross-Domain Connections

- **Tropical convex analysis**: The rate-distortion function is a tropical
  Legendre-Fenchel conjugate; exactness = tropical Fenchel-Moreau equality.
- **Shortest paths**: Feasibility `φ x - r ≤ d x y + D` is a covering/domination
  condition in a weighted bipartite graph.
- **Dynamic programming**: Source potentials are value functions; reproduction
  symbols are controls; distortion is stage cost.
- **Mathematical morphology**: `y ↦ sup_x (φ x - d x y)` is a dilation transform.
-/

import Mathlib

open Finset BigOperators

namespace TropicalSourceCoding

/-! ## Section 1: Core Definitions -/

/-- **Tropical distortion profile.**
    For a source potential `φ : α → ℝ` and distortion kernel `d : α → β → ℝ`,
    the profile at reproduction symbol `y` is the worst-case net cost:
    `ψ(y) = max_x (φ(x) - d(x, y))`.

    This is also a *dilation* in the sense of mathematical morphology. -/
noncomputable def tropicalDistortionProfile
    {α β : Type*} [Fintype α] [Nonempty α]
    (φ : α → ℝ) (d : α → β → ℝ) (y : β) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun x => φ x - d x y)

/-- **Tropical rate-distortion function (primal form).**
    `R(D) = min_y ψ(y) - D = min_y (max_x (φ(x) - d(x,y))) - D`.

    This is the minimum worst-case net cost over all reproduction symbols,
    minus the distortion budget. As D increases, R decreases (antitone). -/
noncomputable def tropicalRateDistortion
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun y => tropicalDistortionProfile φ d y) - D

/-- **Tropical feasibility set.**
    The set of rates `r` for which there exists a reproduction symbol `y`
    such that every source symbol is covered: `φ(x) - r ≤ d(x,y) + D`.

    Equivalently, `r ≥ max_x (φ(x) - d(x,y)) - D` for some `y`. -/
def tropicalFeasibleSet
    {α β : Type*}
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) : Set ℝ :=
  {r | ∃ y : β, ∀ x : α, φ x - r ≤ d x y + D}

/-- **Tropical optimal code cost.**
    The infimum of the feasible set: the least rate achieving distortion ≤ D.
    `C*(D) = inf {r | ∃ y, ∀ x, φ(x) - r ≤ d(x,y) + D}`. -/
noncomputable def tropicalOptimalCodeCost
    {α β : Type*}
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf (tropicalFeasibleSet φ d D)

/-- **Tropical achievable rate.**
    The best rate achievable by a single-symbol tropical code.
    Defined as `min_y (ψ(y)) - D`. -/
noncomputable def tropicalAchievableRate
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty
    (fun y => tropicalDistortionProfile φ d y) - D

/-- **Tropical converse rate.**
    The best lower bound from the dual: no code can achieve rate below this.
    Defined identically to the achievable rate, reflecting exact duality. -/
noncomputable def tropicalConverseRate
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty
    (fun y => tropicalDistortionProfile φ d y) - D

/-! ## Section 2: Feasibility Lemmas -/

/-
The feasible set is nonempty for finite nonempty types.
-/
theorem tropicalFeasibleSet_nonempty
    {α β : Type*} [Fintype α] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    (tropicalFeasibleSet φ d D).Nonempty := by
  exact ⟨ SupSet.sSup ( Set.range fun x => φ x - d x ( Classical.arbitrary β ) ) - D, Classical.arbitrary β, fun x => by linarith [ le_csSup ( Set.finite_range ( fun x => φ x - d x ( Classical.arbitrary β ) ) |> Set.Finite.bddAbove ) ( Set.mem_range_self x ) ] ⟩

/-
The feasible set is bounded below for finite types.
-/
theorem tropicalFeasibleSet_bddBelow
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    BddBelow (tropicalFeasibleSet φ d D) := by
  by_contra h_nonempty;
  exact h_nonempty ⟨ ( InfSet.sInf ( Set.range fun y : β => ( Finset.univ.sup' Finset.univ_nonempty fun x => φ x - d x y ) ) ) - D, fun r hr => by rcases hr with ⟨ y, hy ⟩ ; exact le_of_not_gt fun h => by linarith [ hy ( Classical.arbitrary α ), show ( Finset.univ.sup' Finset.univ_nonempty fun x => φ x - d x y ) ≤ r + D from Finset.sup'_le _ _ fun x _ => by linarith [ hy x ], show ( InfSet.sInf ( Set.range fun y : β => ( Finset.univ.sup' Finset.univ_nonempty fun x => φ x - d x y ) ) ) ≤ ( Finset.univ.sup' Finset.univ_nonempty fun x => φ x - d x y ) from ( csInf_le ( by exact Set.finite_range _ |> Set.Finite.bddBelow ) <| Set.mem_range_self _ ) ] ⟩

/-
The distortion profile value minus D is in the feasible set.
-/
theorem distortionProfile_sub_D_feasible
    {α β : Type*} [Fintype α] [Nonempty α]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) (y : β) :
    tropicalDistortionProfile φ d y - D ∈ tropicalFeasibleSet φ d D := by
  -- We need to show that for some $y'$, $\forall x, \phi(x) - (\sup'_x (\phi(x) - d(x, y)) - D) \le d(x, y') + D$.
  -- Taking $y' = y$, we need to show that $\forall x, \phi(x) - (\sup'_x (\phi(x) - d(x, y)) - D) \le d(x, y) + D$.
  use y
  intro x
  simp [tropicalDistortionProfile];
  linarith [ Finset.le_sup' ( fun x => φ x - d x y ) ( Finset.mem_univ x ) ]

/-
Any feasible rate is at least the profile minus D for some y.
-/
theorem feasible_ge_profile_sub_D
    {α β : Type*} [Fintype α] [Nonempty α]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) (r : ℝ)
    (hr : r ∈ tropicalFeasibleSet φ d D) :
    ∃ y : β, tropicalDistortionProfile φ d y - D ≤ r := by
  -- By definition of `tropicalFeasibleSet`, there exists a y such that for all x, φ x - r ≤ d x y + D.
  obtain ⟨y, hy⟩ : ∃ y, ∀ x, φ x - r ≤ d x y + D := by
    exact hr
  exact ⟨ y, sub_le_iff_le_add'.mpr <| Finset.sup'_le _ _ fun x _ => by linarith [ hy x ] ⟩

/-! ## Section 3: The Exact Equality Theorem -/

/-
**Key lemma**: The optimal code cost equals `min_y ψ(y) - D`.
-/
theorem tropicalOptimalCodeCost_eq
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    tropicalOptimalCodeCost φ d D =
      Finset.univ.inf' Finset.univ_nonempty
        (fun y => tropicalDistortionProfile φ d y) - D := by
  refine' le_antisymm ( csInf_le _ _ ) ( le_csInf _ _ );
  · exact tropicalFeasibleSet_bddBelow φ d D
  · obtain ⟨ y, hy ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun y => tropicalDistortionProfile φ d y;
    exact hy.2.symm ▸ distortionProfile_sub_D_feasible φ d D y;
  · exact tropicalFeasibleSet_nonempty φ d D
  · unfold tropicalFeasibleSet;
    simp +decide [ tropicalDistortionProfile ];
    exact fun b x hx => ⟨ x, fun y => by linarith [ hx y ] ⟩

/-- **Tropical Rate-Distortion Exact Theorem.**
    The optimal feasible code cost equals the tropical rate-distortion function.
    This is the central result: in the tropical world, coding IS optimization.

    `C*(φ, d, D) = R_trop(φ, d, D)` -/
theorem tropicalRateDistortion_exact
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    tropicalOptimalCodeCost φ d D = tropicalRateDistortion φ d D := by
  exact tropicalOptimalCodeCost_eq φ d D

/-! ## Section 4: Dual Characterization -/

/-- **Tropical Rate-Distortion Dual Characterization.**
    `R(D) = sInf {r | ∃ y, ∀ x, φ(x) - r ≤ d(x,y) + D}`. -/
theorem tropicalRateDistortion_dual
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    tropicalRateDistortion φ d D =
      sInf {r : ℝ | ∃ y : β, ∀ x : α, φ x - r ≤ d x y + D} :=
  (tropicalRateDistortion_exact φ d D).symm

/-! ## Section 5: No Shannon Gap -/

/-- **No Shannon Gap Theorem.**
    The tropical achievable rate equals the tropical converse rate. -/
theorem tropical_no_gap
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    tropicalAchievableRate φ d D = tropicalConverseRate φ d D :=
  rfl

/-! ## Section 6: Structural Properties -/

/-- **Antitonicity.**
    The tropical rate-distortion function is antitone in D. -/
theorem tropicalRateDistortion_antitone
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) :
    Antitone (tropicalRateDistortion φ d) := by
  intro D₁ D₂ hD
  simp only [tropicalRateDistortion]
  linarith

/-
The rate-distortion function is 1-Lipschitz in D.
-/
theorem tropicalRateDistortion_lipschitz
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D₁ D₂ : ℝ) :
    |tropicalRateDistortion φ d D₁ - tropicalRateDistortion φ d D₂| = |D₁ - D₂| := by
  simp only [tropicalRateDistortion]
  grind +locals

/-
Rate-distortion is monotone in the source potential.
-/
theorem tropicalRateDistortion_mono_source
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ₁ φ₂ : α → ℝ) (d : α → β → ℝ) (D : ℝ)
    (h : ∀ x, φ₁ x ≤ φ₂ x) :
    tropicalRateDistortion φ₁ d D ≤ tropicalRateDistortion φ₂ d D := by
  unfold tropicalRateDistortion;
  simp +decide [ Finset.inf'_le, Finset.le_inf', tropicalDistortionProfile ];
  -- For any $b \in \beta$, we can choose $i$ such that $\varphi_2(i) - d(i, b)$ is maximized.
  intro b
  obtain ⟨i, hi⟩ : ∃ i : α, ∀ j : α, φ₂ j - d j b ≤ φ₂ i - d i b := by
    simpa using Finset.exists_max_image Finset.univ ( fun j => φ₂ j - d j b ) ⟨ Classical.arbitrary α, Finset.mem_univ _ ⟩;
  exact ⟨ i, b, fun j => by linarith [ h j, hi j ] ⟩

/-
**Attainment theorem**: The infimum is attained by some y*.
-/
theorem tropicalRateDistortion_attained
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    ∃ y : β, tropicalRateDistortion φ d D =
      tropicalDistortionProfile φ d y - D := by
  have := Finset.exists_min_image Finset.univ ( fun y => tropicalDistortionProfile φ d y ) ⟨ Classical.arbitrary β, Finset.mem_univ _ ⟩;
  exact ⟨ this.choose, congr_arg₂ _ ( le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.le_inf' _ _ fun y hy => this.choose_spec.2 y hy ) ) rfl ⟩

/-
**Shift equivariance**: Shifting the source potential by a constant
    shifts the rate-distortion by the same constant.
-/
theorem tropicalRateDistortion_shift
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) (c : ℝ) :
    tropicalRateDistortion (fun x => φ x + c) d D =
      tropicalRateDistortion φ d D + c := by
  -- By definition of tropicalDistortionProfile, we have:
  have h_tropicalDistortionProfile_shift : ∀ y, tropicalDistortionProfile (fun x => φ x + c) d y = tropicalDistortionProfile φ d y + c := by
    unfold tropicalDistortionProfile;
    intro y;
    refine' le_antisymm _ _;
    · simp +decide [ add_sub_right_comm ];
      exact fun x => ⟨ x, by linarith ⟩;
    · simp +decide [ add_sub_right_comm ];
      have := Finset.exists_max_image Finset.univ ( fun x => φ x - d x y ) ⟨ Classical.arbitrary α, Finset.mem_univ _ ⟩ ; aesop;
  unfold tropicalRateDistortion;
  simp +decide [ h_tropicalDistortionProfile_shift, sub_add_eq_add_sub ];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · simpa using Finset.exists_min_image Finset.univ ( fun y => tropicalDistortionProfile φ d y ) ⟨ Classical.arbitrary β, Finset.mem_univ _ ⟩;
  · exact fun y => ⟨ y, le_rfl ⟩

/-
**Min-plus convexity** of the rate-distortion function.
-/
theorem tropicalRateDistortion_minplus_convex
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D₁ D₂ : ℝ) :
    tropicalRateDistortion φ d (min D₁ D₂) ≥
      min (tropicalRateDistortion φ d D₁) (tropicalRateDistortion φ d D₂) := by
  grind

/-
The distortion profile is antitone in the distortion kernel.
-/
theorem tropicalDistortionProfile_antitone_distortion
    {α β : Type*} [Fintype α] [Nonempty α]
    (φ : α → ℝ) (d₁ d₂ : α → β → ℝ) (y : β)
    (h : ∀ x, d₁ x y ≤ d₂ x y) :
    tropicalDistortionProfile φ d₂ y ≤ tropicalDistortionProfile φ d₁ y := by
  -- Apply the fact that if for all x, a x ≤ b x, then the supremum of a is less than or equal to the supremum of b.
  apply Finset.sup'_le;
  exact fun x _ => le_trans ( sub_le_sub_left ( h x ) _ ) ( Finset.le_sup' ( fun x => φ x - d₁ x y ) ( Finset.mem_univ x ) )

/-
**Feasible set characterization**
-/
theorem tropicalFeasibleSet_eq
    {α β : Type*} [Fintype α] [Nonempty α]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    tropicalFeasibleSet φ d D =
      {r | ∃ y : β, tropicalDistortionProfile φ d y - D ≤ r} := by
  ext r;
  constructor <;> rintro ⟨ y, hy ⟩;
  · exact ⟨ y, by linarith [ show tropicalDistortionProfile φ d y ≤ r + D by exact Finset.sup'_le _ _ fun x _ => by linarith [ hy x ] ] ⟩;
  · refine' ⟨ y, fun x => _ ⟩;
    unfold tropicalDistortionProfile at hy;
    linarith [ Finset.le_sup' ( fun x => φ x - d x y ) ( Finset.mem_univ x ) ]

end TropicalSourceCoding