import Mathlib

/-!
# Stereographic Sheaf Theory: Gluing Data on Spheres

This file develops a theory of **stereographic sheaves** — sheaves on the sphere S^n
whose gluing data is constrained by the conformal structure of the stereographic atlas.

## Mathematical Setup

The sphere S^n admits a two-chart atlas {U_N, U_S} via stereographic projection from
the north and south poles. Each chart is diffeomorphic to ℝ^n. The transition map on
the overlap U_N ∩ U_S ≅ ℝ^n \ {0} is the conformal inversion x ↦ x/|x|².

For the circle S^1, the transition map is simply t ↦ 1/t on ℝ \ {0}.

A **stereographic sheaf** is a sheaf on this two-chart cover specified by:
- A module of sections over U_N
- A module of sections over U_S
- A gluing isomorphism on the overlap that commutes with the Möbius transition

## Main Results

* `stereo_transition_involutive` — The stereographic transition map is an involution
* `conformal_factor_product_one` — Conformal factors multiply to 1 at inverse points
* `stereoProj_on_circle` — Stereographic projection maps to the unit circle
* `stereoProj_injective` — Stereographic projection is injective
* `stereo_gluing_unique` — Unique gluing for compatible local sections
* `sym_antisym_inter_zero` — Orthogonality of sym/antisym decomposition
* `symmetric_antisymmetric_decomposition` — Spectral decomposition over ℝ

## Novel Definitions

* `StereoGluingDatum` — Involutive gluing data for stereographic sheaves
* `Z2EquivariantSheaf` — ℤ/2ℤ-equivariant sheaf from antipodal symmetry
-/

noncomputable section

open Function

/-! ## Part 1: Stereographic Transition Maps -/

/-- The stereographic transition map on ℝ \ {0} for S^1: t ↦ 1/t. -/
def stereoTransition (t : ℝ) : ℝ := t⁻¹

/-- The conformal factor of the stereographic transition: 1/t². -/
def conformalFactor (t : ℝ) : ℝ := t⁻¹ ^ 2

/-- The stereographic transition map is an involution on ℝ \ {0}. -/
theorem stereo_transition_involutive (t : ℝ) (_ht : t ≠ 0) :
    stereoTransition (stereoTransition t) = t := by
  simp [stereoTransition, inv_inv]

/-
The conformal factor at a point times the conformal factor at the
    image point equals 1. This encodes conformal compatibility.
-/
theorem conformal_factor_product_one (t : ℝ) (ht : t ≠ 0) :
    conformalFactor t * conformalFactor (stereoTransition t) = 1 := by
  unfold conformalFactor stereoTransition; ring_nf; aesop;

/-- The transition map preserves positivity. -/
theorem stereo_transition_pos (t : ℝ) (ht : 0 < t) :
    0 < stereoTransition t := by
  simp [stereoTransition]; positivity

/-- The conformal factor is always positive on ℝ \ {0}. -/
theorem conformal_factor_pos (t : ℝ) (ht : t ≠ 0) :
    0 < conformalFactor t := by
  simp [conformalFactor]; positivity

/-! ## Part 2: Gluing Data and Stereographic Sheaves -/

/-- A gluing datum for a stereographic sheaf.
    The transition function φ : G → G must be an involutive group homomorphism,
    reflecting the involutive nature of the stereographic transition map. -/
structure StereoGluingDatum (G : Type*) [AddCommGroup G] where
  /-- The transition isomorphism on the overlap -/
  transition : G →+ G
  /-- The transition is an involution -/
  involutive : ∀ x, transition (transition x) = x

namespace StereoGluingDatum

variable {G : Type*} [AddCommGroup G]

/-- The transition map is injective. -/
theorem transition_injective (D : StereoGluingDatum G) :
    Injective D.transition := by
  intro x y h
  have hx := D.involutive x
  have hy := D.involutive y
  rw [h] at hx
  rw [← hx, hy]

/-- The transition map is surjective. -/
theorem transition_surjective (D : StereoGluingDatum G) :
    Surjective D.transition :=
  fun y => ⟨D.transition y, D.involutive y⟩

/-- The identity gluing datum: trivial transition. -/
def trivial : StereoGluingDatum G where
  transition := AddMonoidHom.id G
  involutive := fun _ => rfl

/-- The negation gluing datum: transition by negation. -/
def negation : StereoGluingDatum G where
  transition := -AddMonoidHom.id G
  involutive := by intro x; simp

@[simp]
theorem trivial_transition_apply (g : G) :
    (trivial : StereoGluingDatum G).transition g = g := rfl

@[simp]
theorem negation_transition_apply (g : G) :
    (negation : StereoGluingDatum G).transition g = -g := by
  simp [negation]

/-
In a torsion-free ℤ-module, the negation gluing has only zero as
    a fixed point: -g = g implies g = 0.
-/
theorem negation_fixed_point_zero_int (g : ℤ)
    (h : (negation : StereoGluingDatum ℤ).transition g = g) :
    g = 0 := by
  grind +suggestions

/-
In ℝ, the negation gluing has only zero as a fixed point.
-/
theorem negation_fixed_point_zero_real (g : ℝ)
    (h : (negation : StereoGluingDatum ℝ).transition g = g) :
    g = 0 := by
  simp_all +decide [ neg_eq_iff_add_eq_zero ]

end StereoGluingDatum

/-! ## Part 3: Čech Cohomology for Two-Chart Covers -/

/-- H⁰ of a stereographic sheaf: fixed points of the transition. -/
def cechH0 {G : Type*} [AddCommGroup G] (D : StereoGluingDatum G) : Set G :=
  {g : G | D.transition g = g}

/-- H⁰ for the trivial gluing is all of G. -/
theorem cechH0_trivial_eq_univ {G : Type*} [AddCommGroup G] :
    cechH0 (StereoGluingDatum.trivial : StereoGluingDatum G) = Set.univ := by
  ext x; simp [cechH0]

/-
H⁰ for the negation gluing on ℤ is {0}.
-/
theorem cechH0_negation_eq_zero_int :
    cechH0 (StereoGluingDatum.negation : StereoGluingDatum ℤ) = {0} := by
  ext g
  simp [cechH0, StereoGluingDatum.negation];
  grind

/-- H⁰ contains zero. -/
theorem cechH0_zero_mem {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) : (0 : G) ∈ cechH0 D := by
  simp [cechH0, map_zero]

/-- H⁰ is closed under addition. -/
theorem cechH0_add_mem {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) {x y : G}
    (hx : x ∈ cechH0 D) (hy : y ∈ cechH0 D) : x + y ∈ cechH0 D := by
  simp only [cechH0, Set.mem_setOf_eq] at *
  rw [map_add, hx, hy]

/-- H⁰ is closed under negation. -/
theorem cechH0_neg_mem {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) {x : G}
    (hx : x ∈ cechH0 D) : -x ∈ cechH0 D := by
  simp only [cechH0, Set.mem_setOf_eq] at *
  rw [map_neg, hx]

/-! ## Part 4: The Čech Differential and Mayer-Vietoris -/

/-- The Čech differential: (a, b) ↦ φ(a) - b where φ is the transition. -/
def cechDifferential {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (ab : G × G) : G :=
  D.transition ab.1 - ab.2

/-- A pair (a, b) is a global section iff the Čech differential vanishes. -/
theorem global_section_iff_cech_zero {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (ab : G × G) :
    cechDifferential D ab = 0 ↔ D.transition ab.1 = ab.2 := by
  simp [cechDifferential, sub_eq_zero]

/-
The gluing is unique: if two pairs have the same Čech differential,
    their difference lies in the kernel.
-/
theorem stereo_gluing_unique {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (a₁ b₁ a₂ b₂ : G)
    (h : cechDifferential D (a₁, b₁) = cechDifferential D (a₂, b₂)) :
    cechDifferential D (a₁ - a₂, b₁ - b₂) = 0 := by
  convert sub_eq_zero.mpr h using 1 ; simp +decide [ cechDifferential, map_sub ];
  abel1

/-- For the trivial gluing, H¹ vanishes: every element arises as a differential. -/
theorem H1_trivial_vanishes {G : Type*} [AddCommGroup G] :
    ∀ g : G, ∃ ab : G × G,
      cechDifferential StereoGluingDatum.trivial ab = g := by
  intro g; exact ⟨(g, 0), by simp [cechDifferential]⟩

/-
For the negation gluing on ℤ, Čech differential zero implies b = -a.
-/
theorem negation_cech_kernel_int (a b : ℤ)
    (h : cechDifferential StereoGluingDatum.negation (a, b) = 0) :
    b = -a := by
  erw [ sub_eq_zero, StereoGluingDatum.negation ] at h ; aesop

/-! ## Part 5: Stereographic Projection -/

/-- The stereographic projection from ℝ to S^1. -/
def stereoProj (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- The image of stereoProj lies on S^1. -/
theorem stereoProj_on_circle (t : ℝ) :
    (stereoProj t).1 ^ 2 + (stereoProj t).2 ^ 2 = 1 := by
  simp only [stereoProj]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

/-- The conformal factor of stereographic projection. -/
def stereoConformalFactor (t : ℝ) : ℝ := 2 / (1 + t ^ 2)

/-- The conformal factor is always positive. -/
theorem stereoConformalFactor_pos (t : ℝ) : 0 < stereoConformalFactor t := by
  simp [stereoConformalFactor]; positivity

/-
The conformal factor is bounded above by 2.
-/
theorem stereoConformalFactor_le_two (t : ℝ) :
    stereoConformalFactor t ≤ 2 := by
  exact div_le_self zero_le_two ( by nlinarith )

/-
The conformal factor achieves its maximum at t = 0.
-/
theorem stereoConformalFactor_max_at_zero (t : ℝ) :
    stereoConformalFactor t ≤ stereoConformalFactor 0 := by
  rw [ show stereoConformalFactor = fun t => 2 / ( 1 + t ^ 2 ) from funext fun t => rfl ] ; norm_num;
  exact div_le_self ( by norm_num ) ( by nlinarith )

/-
Stereographic projection is injective.
-/
theorem stereoProj_injective : Injective stereoProj := by
  intro s t h;
  unfold stereoProj at h;
  -- From the equality of the pairs, we can split into two equations:
  -- $2s / (1 + s^2) = 2t / (1 + t^2)$ and $(1 - s^2) / (1 + s^2) = (1 - t^2) / (1 + t^2)$.
  have h1 : 2 * s / (1 + s ^ 2) = 2 * t / (1 + t ^ 2) := by
    injection h
  have h2 : (1 - s ^ 2) / (1 + s ^ 2) = (1 - t ^ 2) / (1 + t ^ 2) := by
    injection h;
  rw [ div_eq_div_iff ] at h1 h2 <;> nlinarith [ sq_nonneg ( s - t ) ]

/-! ## Part 6: Cross-Domain — Sheaf Cohomology × Representation Theory -/

/-- A ℤ/2ℤ-equivariant gluing datum models the antipodal symmetry of S^n.
    Connects sheaf theory to representation theory of ℤ/2ℤ. -/
structure Z2EquivariantSheaf (G : Type*) [AddCommGroup G] where
  gluing : StereoGluingDatum G
  antipodal : G →+ G
  antipodal_involutive : ∀ x, antipodal (antipodal x) = x
  compatible : ∀ x, gluing.transition (antipodal x) = antipodal (gluing.transition x)

/-- The symmetric fixed points of the antipodal action. -/
def symmetricSections {G : Type*} [AddCommGroup G]
    (S : Z2EquivariantSheaf G) : Set G :=
  {g | S.antipodal g = g}

/-- The antisymmetric fixed points of the antipodal action. -/
def antisymmetricSections {G : Type*} [AddCommGroup G]
    (S : Z2EquivariantSheaf G) : Set G :=
  {g | S.antipodal g = -g}

/-
Over ℝ, a section that is both symmetric and antisymmetric must be zero.
    Key orthogonality connecting representation theory to sheaf cohomology.
    Note: this fails for groups with 2-torsion (e.g., ℤ/2ℤ).
-/
theorem sym_antisym_inter_zero_real
    (S : Z2EquivariantSheaf ℝ) (g : ℝ)
    (hsym : g ∈ symmetricSections S) (hanti : g ∈ antisymmetricSections S) :
    g = 0 := by
  linarith [ hsym.symm, hanti.symm ]

/-- Zero is always a symmetric section. -/
theorem zero_mem_symmetric {G : Type*} [AddCommGroup G]
    (S : Z2EquivariantSheaf G) : (0 : G) ∈ symmetricSections S := by
  simp [symmetricSections, map_zero]

/-- Zero is always an antisymmetric section. -/
theorem zero_mem_antisymmetric {G : Type*} [AddCommGroup G]
    (S : Z2EquivariantSheaf G) : (0 : G) ∈ antisymmetricSections S := by
  simp [antisymmetricSections, map_zero]

/-! ## Part 7: Spectral Decomposition -/

/-
Over ℝ, every element decomposes into symmetric and antisymmetric parts
    under an involution. This is the spectral decomposition for ℤ/2ℤ reps.

    Given an involution φ on ℝ and any g ∈ ℝ, we can write
    g = s + a where s = (g + φ(g))/2 and a = (g - φ(g))/2.
    Then φ(s) = s and φ(a) = -a.
-/
theorem symmetric_antisymmetric_decomposition
    (φ : ℝ →+ ℝ) (hφ : ∀ x, φ (φ x) = x)
    (g : ℝ) : ∃ s a : ℝ, φ s = s ∧ φ a = -a ∧ g = s + a := by
  -- Set s = (g + φ(g))/2 and a = (g - φ(g))/2. Then g = s + a.
  use (g + φ g) / 2, (g - φ g) / 2;
  grind

/-! ## Part 8: Falsifiable Conjecture -/

/-
**Conjecture** (Stereographic Completeness):
   For ZMod p with p odd prime and φ = negation, the only fixed point is 0.
   This is equivalent to -1 ≠ 1 in ZMod p, which holds iff p > 2.

   Test: Verify for p = 3, 5, 7.
   Disproof path: fails for p = 2 since -1 = 1 in ZMod 2.

In ZMod 3, the only self-negative element is zero.
-/
theorem zmod3_negation_fixed_point :
    ∀ x : ZMod 3, -x = x → x = 0 := by
  decide +revert

/-
In ZMod 5, the only self-negative element is zero.
-/
theorem zmod5_negation_fixed_point :
    ∀ x : ZMod 5, -x = x → x = 0 := by
  native_decide

/-
In ZMod 2, every element is self-negative (conjecture fails).
-/
theorem zmod2_negation_all_fixed :
    ∀ x : ZMod 2, -x = x := by
  decide +revert

/-! ## Part 9: Composition of Gluing Data -/

/-- Composition of commuting gluing data. -/
def StereoGluingDatum.compose {G : Type*} [AddCommGroup G]
    (D₁ D₂ : StereoGluingDatum G)
    (hcomm : ∀ x, D₁.transition (D₂.transition x) =
      D₂.transition (D₁.transition x)) :
    StereoGluingDatum G where
  transition := D₁.transition.comp D₂.transition
  involutive := by
    intro x; simp [AddMonoidHom.comp_apply]
    rw [hcomm, D₁.involutive, D₂.involutive]

/-- The trivial gluing is a left identity for composition. -/
theorem StereoGluingDatum.trivial_compose_eq {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G)
    (hcomm : ∀ x, StereoGluingDatum.trivial.transition (D.transition x) =
      D.transition (StereoGluingDatum.trivial.transition x)) :
    (StereoGluingDatum.trivial.compose D hcomm).transition = D.transition := by
  ext x; simp [StereoGluingDatum.compose]

/-- The H⁰ of the composition of trivial with any D equals H⁰(D). -/
theorem cechH0_trivial_compose {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G)
    (hcomm : ∀ x, StereoGluingDatum.trivial.transition (D.transition x) =
      D.transition (StereoGluingDatum.trivial.transition x)) :
    cechH0 (StereoGluingDatum.trivial.compose D hcomm) = cechH0 D := by
  ext x; simp [cechH0, StereoGluingDatum.compose]

/-- The rank of H⁰ is bounded by |G| for finite groups. -/
theorem cechH0_card_le {G : Type*} [Fintype G] [AddCommGroup G] [DecidableEq G]
    (D : StereoGluingDatum G) :
    Fintype.card {g : G | D.transition g = g} ≤ Fintype.card G :=
  Fintype.card_subtype_le _

end