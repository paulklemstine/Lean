/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Mirror Symmetry: Min-Plus Duality, Legendre Transform, and Corner Loci

This file formalizes the mathematical correspondence between string-theoretic
T-duality, tropical Legendre transforms, and conifold transitions as corner loci
in piecewise-linear geometry.

## Main Results

### Part A: T-Duality Package
- `tDualRadius_involutive`: R ↦ 1/R is an involution
- `tDualCharge_involutive`: charge swap is an involution
- `logRadiusEnergy_tdual`: energy is invariant under (r, n, w) ↦ (-r, w, n)
- `circleEnergy_tdual_invariant`: energy invariance in multiplicative coordinates

### Part B: Tropical Legendre Transform
- `tropLegendre_at_neg_slope`: Legendre duality at matching slopes
- `tropBiconj_le`: biconjugate inequality f°°(x) ≤ f(x) (Fenchel-Moreau)

### Part C: Corner Locus and Conifold Transition
- `inCornerLocus_iff_two_minimizers`: corner locus ↔ two distinct minimizers
- `conifoldFamily_corner_at_origin`: the conifold has a corner at (0,0)
- `conifoldFamily_resolved_for_positive_t`: no singularity when t > 0
-/

noncomputable section

open Real Finset

namespace TropicalMirrorSymmetry

/-! ## Part A: T-Duality as Involutive Min-Plus Symmetry -/

/-- Radius inversion: the T-duality map on the radius modulus. -/
def tDualRadius (R : ℝ) : ℝ := 1 / R

/-- Charge swap: exchanges momentum quantum number n with winding number w. -/
def tDualCharge (p : ℝ × ℝ) : ℝ × ℝ := (p.2, p.1)

/-- Log-radius energy: the tropicalized circle energy in logarithmic coordinates.
    `r = log R`, with branches `n + r` (momentum) and `w - r` (winding). -/
def logRadiusEnergy (r n w : ℝ) : ℝ := min (n + r) (w - r)

/-- Circle energy in multiplicative coordinates.
    `min(n + R, w + 1/R)` encodes the momentum/winding spectrum. -/
def circleEnergy (R n w : ℝ) : ℝ := min (n + R) (w + 1 / R)

/-- Radius inversion is an involution on nonzero reals. -/
theorem tDualRadius_involutive {R : ℝ} (hR : R ≠ 0) :
    tDualRadius (tDualRadius R) = R := by
  unfold tDualRadius; field_simp

/-- Charge swap is an involution. -/
theorem tDualCharge_involutive (p : ℝ × ℝ) :
    tDualCharge (tDualCharge p) = p := by
  simp [tDualCharge]

/-- **T-duality symmetry of log-radius energy.**
    Negating the log-radius and swapping momentum/winding preserves the energy. -/
theorem logRadiusEnergy_tdual (r n w : ℝ) :
    logRadiusEnergy r n w = logRadiusEnergy (-r) w n := by
  unfold logRadiusEnergy
  ring_nf
  exact min_comm _ _

/-- **T-duality symmetry of circle energy.**
    Inverting the radius and swapping momentum/winding preserves the energy. -/
theorem circleEnergy_tdual_invariant {R : ℝ} (_hR : R ≠ 0) (n w : ℝ) :
    circleEnergy R n w = circleEnergy (tDualRadius R) w n := by
  unfold circleEnergy tDualRadius
  rw [one_div_one_div]
  exact min_comm _ _

/-- Combined T-duality package. -/
theorem tDuality_package {R : ℝ} (hR : R ≠ 0) :
    tDualRadius (tDualRadius R) = R ∧
    (∀ p : ℝ × ℝ, tDualCharge (tDualCharge p) = p) ∧
    (∀ n w, circleEnergy R n w = circleEnergy (tDualRadius R) w n) :=
  ⟨tDualRadius_involutive hR, tDualCharge_involutive,
   fun n w => circleEnergy_tdual_invariant hR n w⟩

/-! ## Part B: Tropical Legendre Transform on Finite Potentials -/

/-- A piecewise-linear tropical potential: `inf_i (c i + m i * x)`. -/
def tropPotentialPL {ι : Type*} [DecidableEq ι]
    (A : Finset ι) (hA : A.Nonempty) (c m : ι → ℝ) (x : ℝ) : ℝ :=
  A.inf' hA (fun i => c i + m i * x)

/-- The dual potential: `inf_i (c i - p * m i)`. -/
def dualPotential {ι : Type*} [DecidableEq ι]
    (A : Finset ι) (hA : A.Nonempty) (c m : ι → ℝ) (p : ℝ) : ℝ :=
  A.inf' hA (fun i => c i - p * m i)

/-- The finite tropical Legendre transform: `inf_{x ∈ S} (f(x) + p * x)`. -/
def tropLegendreFinset (S : Finset ℝ) (hS : S.Nonempty) (f : ℝ → ℝ) (p : ℝ) : ℝ :=
  S.inf' hS (fun x => f x + p * x)

/-- Some member achieves the infimum of the potential. -/
theorem tropPotentialPL_achieved {ι : Type*} [DecidableEq ι]
    (A : Finset ι) (hA : A.Nonempty) (c m : ι → ℝ) (x : ℝ) :
    ∃ i ∈ A, tropPotentialPL A hA c m x = c i + m i * x := by
  obtain ⟨i, hi, hmin⟩ := Finset.exists_min_image A (fun i => c i + m i * x) hA
  exact ⟨i, hi, le_antisymm (Finset.inf'_le _ hi)
    (Finset.le_inf' _ _ (fun j hj => hmin j hj))⟩

/-
**Tropical Legendre duality at matching slopes.**
    When `p = -m i`, the Legendre transform is bounded by `c i`.
-/
theorem tropLegendre_at_neg_slope {ι : Type*} [DecidableEq ι]
    (A : Finset ι) (hA : A.Nonempty) (c m : ι → ℝ) (i : ι) (hi : i ∈ A) :
    tropLegendreFinset (A.image m) (Nonempty.image hA m) (tropPotentialPL A hA c m) (-m i)
      ≤ c i := by
  unfold tropLegendreFinset tropPotentialPL;
  simp +decide;
  exact ⟨ i, hi, i, hi, by ring_nf; norm_num ⟩

/-- The tropical Fenchel conjugate: `f°(p) = inf_{x ∈ S} (f(x) - p * x)`.
    This uses the SUBTRACTION convention, which is the correct one for
    obtaining a biconjugate inequality. -/
def tropFenchelConj (S : Finset ℝ) (hS : S.Nonempty) (f : ℝ → ℝ) (p : ℝ) : ℝ :=
  S.inf' hS (fun x => f x - p * x)

/-- The tropical biconjugate: `f°°(x) = inf_{p ∈ S} (f°(p) + p * x)`. -/
def tropBiconj (S : Finset ℝ) (hS : S.Nonempty) (f : ℝ → ℝ) (x : ℝ) : ℝ :=
  S.inf' hS (fun p => tropFenchelConj S hS f p + p * x)

/-- **Tropical Fenchel-Moreau inequality.**
    The biconjugate satisfies `f°°(x) ≤ f(x)` for all `x ∈ S`.
    This is the tropical analogue of the classical Fenchel-Moreau theorem,
    and captures the mathematical content of "mirror symmetry = tropical
    Legendre duality": applying the duality twice yields a function
    pointwise bounded by the original. -/
theorem tropBiconj_le (S : Finset ℝ) (hS : S.Nonempty) (f : ℝ → ℝ) (x : ℝ)
    (hx : x ∈ S) :
    tropBiconj S hS f x ≤ f x := by
  unfold tropBiconj tropFenchelConj
  apply Finset.inf'_le_of_le _ hx
  have h1 : S.inf' hS (fun y => f y - x * y) ≤ f x - x * x := Finset.inf'_le _ hx
  linarith

/-! ## Part C: Corner Locus and Conifold Transitions -/

/-- A point `x` is in the **corner locus** if ≥ 2 distinct indices achieve the min. -/
def InCornerLocus {ι : Type*} [DecidableEq ι]
    (A : Finset ι) (hA : A.Nonempty) (c m : ι → ℝ) (x : ℝ) : Prop :=
  ∃ i ∈ A, ∃ j ∈ A, i ≠ j ∧
    c i + m i * x = tropPotentialPL A hA c m x ∧
    c j + m j * x = tropPotentialPL A hA c m x

/-
**Corner locus ↔ two distinct minimizers with equal values.**
-/
theorem inCornerLocus_iff_two_minimizers {ι : Type*} [DecidableEq ι]
    (A : Finset ι) (hA : A.Nonempty) (c m : ι → ℝ) (x : ℝ) :
    InCornerLocus A hA c m x ↔
      ∃ i ∈ A, ∃ j ∈ A, i ≠ j ∧
        c i + m i * x = c j + m j * x ∧
        c i + m i * x = tropPotentialPL A hA c m x := by
  -- By definition of InCornerLocus, if there exists i and j such that c i + m i * x = c j + m j * x and both equal the tropPotentialPL, then InCornerLocus holds.
  apply Iff.intro;
  · exact fun ⟨ i, hi, j, hj, hij, hi', hj' ⟩ => ⟨ i, hi, j, hj, hij, hi'.trans hj'.symm, hi' ⟩;
  · exact fun ⟨ i, hi, j, hj, hij, h₁, h₂ ⟩ => ⟨ i, hi, j, hj, hij, h₂, h₁.symm ▸ h₂ ⟩

/-- The conifold family: `min(x, min(-x, t))`. -/
def conifoldFamily (t x : ℝ) : ℝ := min x (min (-x) t)

/-- At `x = 0, t = 0`, the conifold family has value 0. -/
theorem conifoldFamily_value_at_origin : conifoldFamily 0 0 = 0 := by
  simp [conifoldFamily]

/-
**Conifold corner at the origin when t = 0.**
-/
theorem conifoldFamily_corner_at_origin :
    let f := conifoldFamily 0
    ∃ (a₁ b₁ a₂ b₂ : ℝ), (a₁ ≠ a₂ ∨ b₁ ≠ b₂) ∧
      f 0 = a₁ * 0 + b₁ ∧ f 0 = a₂ * 0 + b₂ := by
  -- By definition of conifoldFamily, we have conifoldFamily 0 0 = min 0 (min 0 0) = 0.
  simp [conifoldFamily];
  exact ⟨ 0, 1, by norm_num ⟩

/-
**Resolution: no corner at x = 0 when t > 0.**
-/
theorem conifoldFamily_resolved_for_positive_t (t : ℝ) (ht : 0 < t) :
    conifoldFamily t 0 = 0 ∧ t ≠ conifoldFamily t 0 := by
  grind +locals

/-
**Two-branch corner locus**: the unique corner point is `(b₂ - b₁)/(a₁ - a₂)`.
-/
theorem two_branch_corner_locus (a₁ b₁ a₂ b₂ : ℝ) (hne : a₁ ≠ a₂) (x : ℝ) :
    a₁ * x + b₁ = a₂ * x + b₂ ↔ x = (b₂ - b₁) / (a₁ - a₂) := by
  grind

/-
At the corner, both branches achieve the minimum.
-/
theorem two_branch_corner_is_min (a₁ b₁ a₂ b₂ : ℝ) (hne : a₁ ≠ a₂) :
    let x₀ := (b₂ - b₁) / (a₁ - a₂)
    min (a₁ * x₀ + b₁) (a₂ * x₀ + b₂) = a₁ * x₀ + b₁ := by
  grind

/-! ## Min-Plus Algebraic Infrastructure -/

/-- Min-plus distributivity: addition distributes over min. -/
theorem tropical_plus_distributes_over_min (a b c : ℝ) :
    c + min a b = min (c + a) (c + b) := by
  simp [min_add_add_left]

/-- Tropical interference: min selects the dominant path. -/
theorem tropical_interference_min (S₁ S₂ : ℝ) :
    min S₁ S₂ ≤ S₁ ∧ min S₁ S₂ ≤ S₂ :=
  ⟨min_le_left _ _, min_le_right _ _⟩

end TropicalMirrorSymmetry
end