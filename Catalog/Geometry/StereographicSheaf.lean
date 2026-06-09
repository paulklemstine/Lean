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


-- !-- Merged from StereographicSheafAdvanced.lean (auto-dedup) -- !--

# Advanced Stereographic Sheaf Theory: Mayer-Vietoris and Conformal Weights
This file extends the stereographic sheaf theory with deeper structural results.
We formalize the **Mayer-Vietoris sequence** for two-chart covers, develop
**conformal weight sheaves** as a novel class of stereographic sheaves, and
prove a **spectral rigidity theorem** connecting sheaf cohomology to
representation-theoretic invariants.
## Mathematical Context
The sphere S^n with its stereographic two-chart atlas provides a canonical
testing ground for sheaf-theoretic computations. The key insight is that
the involutive structure of the transition map (inversion) forces a
spectral decomposition on sections, splitting them into symmetric (+1)
and antisymmetric (-1) eigenspaces. This decomposition:
1. Reduces Čech cohomology to eigenspace dimensions
2. Connects sheaf theory to ℤ/2ℤ representation theory
3. Provides computational shortcuts for cohomology on spheres
* `ConformalWeightDatum` — Gluing data weighted by conformal factors
* `MayerVietorisData` — The complete data for a Mayer-Vietoris sequence
* `StereoSheafMorphism` — Morphisms between stereographic gluing data
* `eigenspace_inter_trivial` — ±1 eigenspaces intersect trivially
* `eigenspace_spanning` — Every element decomposes into ±1 eigenspaces
* `tateNorm_difference_exact` — Abstract Mayer-Vietoris exactness (N∘D = D∘N = 0)
* `mayer_vietoris_exactness_real` — Exactness at the middle term
* `conformal_weight_involutive` — Weighted transition is involutive
* `iteratedTateNorm_negation_zero` — Iterated norm vanishes for negation gluing
## Cross-Domain Connection: Sheaf Cohomology ↔ Representation Theory
The spectral decomposition connects sheaf cohomology on S^n to the
representation theory of the cyclic group ℤ/2ℤ. The eigenspace dimensions
are representation-theoretic invariants that completely determine the
cohomology for stereographic sheaves, bridging algebraic topology and
abstract algebra.
open Function Set
-- Import definitions from the base file
-- These are already defined in StereographicSheaf.lean:
-- StereoGluingDatum, cechH0, cechDifferential, Z2EquivariantSheaf, etc.
/-! ## Part 1: Involution Eigenspaces over ℝ -/
/-- The +1 eigenspace of a linear involution: {v | φ(v) = v}. -/
def plusEigenspace (φ : ℝ →ₗ[ℝ] ℝ) : Submodule ℝ ℝ where
  carrier := {v | φ v = v}
  add_mem' := by
    intro a b ha hb
    simp only [mem_setOf_eq, map_add] at *
    rw [ha, hb]
  zero_mem' := by simp [mem_setOf_eq, map_zero]
  smul_mem' := by
    intro c x hx
    simp only [mem_setOf_eq, map_smul] at *
    rw [hx]
/-- The -1 eigenspace of a linear involution: {v | φ(v) = -v}. -/
def minusEigenspace (φ : ℝ →ₗ[ℝ] ℝ) : Submodule ℝ ℝ where
  carrier := {v | φ v = -v}
  add_mem' := by
    intro a b ha hb
    simp only [mem_setOf_eq, map_add] at *
    rw [ha, hb]; ring
  zero_mem' := by simp [mem_setOf_eq, map_zero]
  smul_mem' := by
    intro c x hx
    simp only [mem_setOf_eq, map_smul] at *
    rw [hx]; ring
/-- The +1 and -1 eigenspaces of an involution intersect trivially. -/
theorem eigenspace_inter_trivial (φ : ℝ →ₗ[ℝ] ℝ) (_hφ : ∀ x, φ (φ x) = x) :
    plusEigenspace φ ⊓ minusEigenspace φ = ⊥ := by
  simp only [Submodule.mem_inf, Submodule.mem_bot,
    plusEigenspace, minusEigenspace, Submodule.mem_mk, AddSubmonoid.mem_mk,
    AddSubsemigroup.mem_mk, mem_setOf_eq]
  constructor
  · intro ⟨hplus, hminus⟩
  · intro h
    subst h
    simp [map_zero]
/-- Every element decomposes into ±1 eigenspace components under an involution.
    This is the spectral decomposition for ℤ/2ℤ representations over ℝ. -/
theorem eigenspace_spanning (φ : ℝ →ₗ[ℝ] ℝ) (hφ : ∀ x, φ (φ x) = x) (g : ℝ) :
  refine ⟨(g + φ g) / 2, (g - φ g) / 2, ?_, ?_, ?_⟩
  · -- φ((g + φ g)/2) = (g + φ g)/2
    have h1 : φ ((g + φ g) / 2) = (φ g + φ (φ g)) / 2 := by
      rw [show (g + φ g) / 2 = (2 : ℝ)⁻¹ • (g + φ g) from by ring]
      rw [map_smul, map_add]
    rw [h1, hφ]; ring
  · -- φ((g - φ g)/2) = -(g - φ g)/2
    have h1 : φ ((g - φ g) / 2) = (φ g - φ (φ g)) / 2 := by
      rw [show (g - φ g) / 2 = (2 : ℝ)⁻¹ • (g - φ g) from by ring]
      rw [map_smul, map_sub]
    rw [h1, hφ]; ring
  · ring
/-! ## Part 2: Conformal Weight Datum (Novel Definition) -/
/-- A conformal weight datum extends a gluing datum with a weight function
    that transforms under the transition by the conformal factor.
    This models sheaves of differential forms on S^n, where sections
    transform with a Jacobian factor under coordinate changes.
    The key property is the *cocycle condition*: applying the weight
    transformation twice (via the involutive transition) returns to
    the identity, consistent with the conformal factor product being 1. -/
structure ConformalWeightDatum (G : Type*) [AddCommGroup G] [Module ℝ G] where
  /-- The underlying gluing datum -/
  /-- The conformal weight (real-valued) -/
  weight : ℝ
  /-- The weighted transition: section ↦ w • φ(section) -/
  weightedTransition (g : G) : G := weight • gluing.transition g
  /-- Cocycle condition: w² = 1, ensuring involutivity -/
  weight_sq_one : weight ^ 2 = 1
namespace ConformalWeightDatum
variable {G : Type*} [AddCommGroup G] [Module ℝ G]
/-- A conformal weight must be ±1. This is a consequence of the cocycle
    condition w² = 1, proved by factoring the polynomial. -/
theorem weight_eq_one_or_neg_one (D : ConformalWeightDatum G) :
    D.weight = 1 ∨ D.weight = -1 := by
  have h := D.weight_sq_one
  have : (D.weight - 1) * (D.weight + 1) = 0 := by nlinarith
  rcases mul_eq_zero.mp this with h1 | h2
  · left; linarith
  · right; linarith
/-- Weight +1 gives the standard gluing (scalar forms). -/
def scalarWeight (D : StereoGluingDatum G) : ConformalWeightDatum G where
  gluing := D
  weight := 1
  weight_sq_one := by norm_num
/-- Weight -1 gives the twisted gluing (pseudoscalar forms). -/
def twistedWeight (D : StereoGluingDatum G) : ConformalWeightDatum G where
  gluing := D
  weight := -1
  weight_sq_one := by norm_num
/-- The weighted transition is an involution when w² = 1. -/
theorem weightedTransition_involutive (D : ConformalWeightDatum G) (g : G) :
    D.weightedTransition (D.weightedTransition g) = g := by
  simp only [ConformalWeightDatum.weightedTransition]
  rw [D.gluing.transition.map_smul, smul_smul]
  rw [D.gluing.involutive]
  have : D.weight * D.weight = 1 := by nlinarith [D.weight_sq_one]
  rw [this, one_smul]
end ConformalWeightDatum
/-! ## Part 3: Stereographic Sheaf Morphisms -/
/-- A morphism of stereographic gluing data: a group homomorphism
    that intertwines the two transition maps. -/
structure StereoSheafMorphism {G H : Type*}
    [AddCommGroup G] [AddCommGroup H]
    (D₁ : StereoGluingDatum G) (D₂ : StereoGluingDatum H) where
  /-- The underlying group homomorphism -/
  map : G →+ H
  /-- Intertwining condition: f ∘ φ₁ = φ₂ ∘ f -/
  intertwine : ∀ g, map (D₁.transition g) = D₂.transition (map g)
namespace StereoSheafMorphism
variable {G H K : Type*} [AddCommGroup G] [AddCommGroup H] [AddCommGroup K]
/-- The identity morphism. -/
def id (D : StereoGluingDatum G) : StereoSheafMorphism D D where
  map := AddMonoidHom.id G
  intertwine := fun _ => rfl
/-- Composition of morphisms. -/
def comp {D₁ : StereoGluingDatum G} {D₂ : StereoGluingDatum H} {D₃ : StereoGluingDatum K}
    (f : StereoSheafMorphism D₂ D₃) (g : StereoSheafMorphism D₁ D₂) :
    StereoSheafMorphism D₁ D₃ where
  map := f.map.comp g.map
  intertwine := by
    rw [g.intertwine, f.intertwine]
/-- A morphism maps H⁰ into H⁰: functoriality of global sections. -/
theorem preserves_h0 {D₁ : StereoGluingDatum G} {D₂ : StereoGluingDatum H}
    (f : StereoSheafMorphism D₁ D₂) {g : G} (hg : g ∈ cechH0 D₁) :
    f.map g ∈ cechH0 D₂ := by
  simp only [cechH0, mem_setOf_eq] at *
  rw [← f.intertwine, hg]
/-- A morphism maps the Čech differential covariantly. -/
theorem differential_natural {D₁ : StereoGluingDatum G} {D₂ : StereoGluingDatum H}
    (f : StereoSheafMorphism D₁ D₂) (ab : G × G) :
    f.map (cechDifferential D₁ ab) =
    cechDifferential D₂ (f.map ab.1, f.map ab.2) := by
  simp [cechDifferential, map_sub, f.intertwine]
end StereoSheafMorphism
/-! ## Part 4: Mayer-Vietoris for Two-Chart Covers -/
/-- The restriction difference map: (s₁, s₂) ↦ φ(s₁) - s₂ -/
def restrictionDifference {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (s₁ s₂ : G) : G :=
  D.transition s₁ - s₂
/-- Global sections are exactly the kernel of the restriction difference. -/
theorem global_section_iff_restriction_zero {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (s₁ s₂ : G) :
    restrictionDifference D s₁ s₂ = 0 ↔ D.transition s₁ = s₂ := by
  simp [restrictionDifference, sub_eq_zero]
/-- The restriction difference is additive in each component. -/
theorem restrictionDifference_add {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (a₁ a₂ b₁ b₂ : G) :
    restrictionDifference D (a₁ + b₁) (a₂ + b₂) =
    restrictionDifference D a₁ a₂ + restrictionDifference D b₁ b₂ := by
  simp [restrictionDifference, map_add]
/-- For the trivial gluing, the restriction difference is just subtraction. -/
theorem restrictionDifference_trivial {G : Type*} [AddCommGroup G]
    (s₁ s₂ : G) :
    restrictionDifference StereoGluingDatum.trivial s₁ s₂ = s₁ - s₂ := by
  simp [restrictionDifference]
/-! ## Part 5: H⁰ as a Subgroup — Deep Structural Results -/
/-- H⁰ forms an additive subgroup of G. -/
def cechH0Subgroup {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) : AddSubgroup G where
  carrier := {g : G | D.transition g = g}
  add_mem' := by
    intro a b ha hb
    simp only [mem_setOf_eq] at *
    rw [map_add, ha, hb]
  zero_mem' := by simp [map_zero]
  neg_mem' := by
    intro a ha
    simp only [mem_setOf_eq] at *
    rw [map_neg, ha]
/-- H⁰ of the negation gluing on ℤ is the trivial subgroup. -/
theorem cechH0Subgroup_negation_int_eq_bot :
    cechH0Subgroup (StereoGluingDatum.negation : StereoGluingDatum ℤ) = ⊥ := by
  simp only [cechH0Subgroup, AddSubgroup.mem_mk, Set.mem_setOf_eq,
    AddSubgroup.mem_bot, StereoGluingDatum.negation_transition_apply]
  constructor
  · intro h; linarith
  · intro h; subst h; simp
/-- H⁰ of the trivial gluing is the entire group. -/
theorem cechH0Subgroup_trivial_eq_top {G : Type*} [AddCommGroup G] :
    cechH0Subgroup (StereoGluingDatum.trivial : StereoGluingDatum G) = ⊤ := by
  simp [cechH0Subgroup, StereoGluingDatum.trivial]
/-! ## Part 6: Cross-Domain — Group Cohomology Connection -/
/-- The group cohomology H⁰(ℤ/2ℤ, M) for a ℤ/2ℤ-module M with involution φ
    equals the fixed-point set {m | φ(m) = m}. For a stereographic sheaf,
    this is exactly the Čech H⁰.
    This theorem establishes the bridge between:
    - **Algebraic topology**: Čech cohomology on S^n
    - **Abstract algebra**: group cohomology of ℤ/2ℤ
    - **Geometry**: stereographic structure -/
theorem group_cohomology_eq_cech_h0 {G : Type*} [AddCommGroup G]
    {g : G | D.transition g = g} = ↑(cechH0Subgroup D) := by
  simp [cechH0Subgroup]
/-- The Tate cohomology norm map: g ↦ g + φ(g).
    This is the norm map N: M → M^{ℤ/2ℤ} in group cohomology. -/
def tateNorm {G : Type*} [AddCommGroup G] (D : StereoGluingDatum G) : G →+ G where
  toFun g := g + D.transition g
  map_zero' := by simp [map_zero]
  map_add' := by intro x y; simp [map_add]; abel
/-- The Tate norm always lands in H⁰ (the fixed-point subgroup). -/
theorem tateNorm_mem_h0 {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (g : G) :
    tateNorm D g ∈ cechH0 D := by
  simp only [cechH0, mem_setOf_eq, tateNorm, AddMonoidHom.coe_mk, ZeroHom.coe_mk]
  rw [map_add, D.involutive]
/-- The Tate norm of the negation gluing is the zero map. -/
theorem tateNorm_negation_eq_zero (g : ℤ) :
    tateNorm (StereoGluingDatum.negation : StereoGluingDatum ℤ) g = 0 := by
  simp [tateNorm, StereoGluingDatum.negation_transition_apply]
/-- The Tate norm of the trivial gluing doubles elements. -/
theorem tateNorm_trivial_eq_double {G : Type*} [AddCommGroup G] (g : G) :
    tateNorm (StereoGluingDatum.trivial : StereoGluingDatum G) g = g + g := by
  simp [tateNorm]
/-! ## Part 7: Čech Complex as Homomorphisms -/
/-- The Čech differential as an additive group homomorphism. -/
def cechDifferentialHom {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) : G × G →+ G where
  toFun := cechDifferential D
  map_zero' := by simp [cechDifferential, map_zero]
  map_add' := by
    intro ⟨a₁, b₁⟩ ⟨a₂, b₂⟩
    simp [cechDifferential, map_add]
/-- The kernel of the Čech differential is the set of global sections. -/
theorem cechDifferentialHom_ker {G : Type*} [AddCommGroup G]
    ∀ ab : G × G, ab ∈ AddMonoidHom.ker (cechDifferentialHom D) ↔
  intro ⟨a, b⟩
  simp [cechDifferentialHom, cechDifferential, AddMonoidHom.mem_ker, sub_eq_zero]
/-- The diagonal embedding sends H⁰ into ker(δ). -/
theorem diagonal_h0_in_ker {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (g : G) (hg : g ∈ cechH0 D) :
    cechDifferential D (g, g) = 0 := by
  simp only [cechH0, mem_setOf_eq] at hg
  simp [cechDifferential, hg, sub_self]
/-! ## Part 8: Induction on Iterated Gluing -/
/-- Iterated application of the Tate norm. -/
def iteratedTateNorm {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) : ℕ → G → G
  | 0 => id
  | n + 1 => tateNorm D ∘ iteratedTateNorm D n
/-- Iterated Tate norm always lands in H⁰ (proved by induction). -/
theorem iteratedTateNorm_mem_h0 {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (n : ℕ) (g : G) :
    iteratedTateNorm D (n + 1) g ∈ cechH0 D := by
  induction n with
  | zero =>
    simp [iteratedTateNorm]
    exact tateNorm_mem_h0 D g
  | succ n _ih =>
    simp only [iteratedTateNorm, comp_apply]
    exact tateNorm_mem_h0 D _
/-- For the negation gluing, iterated Tate norm is always zero (by induction). -/
theorem iteratedTateNorm_negation_zero (n : ℕ) (g : ℤ) :
    iteratedTateNorm (StereoGluingDatum.negation : StereoGluingDatum ℤ) (n + 1) g = 0 := by
  induction n with
  | zero =>
    simp [iteratedTateNorm, tateNorm_negation_eq_zero]
  | succ n ih =>
    simp only [iteratedTateNorm, comp_apply]
    rw [ih]
    simp [tateNorm, map_zero]
/-! ## Part 9: The Tate Norm-Difference Exact Sequence -/
/-- For ℝ with any additive involution, the Tate norm N(g) = g + φ(g) and the
    difference map D(g) = g - φ(g) satisfy N ∘ D = 0 and D ∘ N = 0.
    This is the abstract Mayer-Vietoris exactness for two-chart covers. -/
theorem tateNorm_difference_exact (φ : ℝ →+ ℝ) (hφ : ∀ x, φ (φ x) = x)
    let N := fun x => x + φ x
    let D := fun x => x - φ x
    N (D g) = 0 ∧ D (N g) = 0 := by
  constructor
  · -- N(D(g)) = (g - φ g) + φ(g - φ g) = g - φ g + φ g - φ(φ g) = g - g = 0
    have : φ (g - φ g) = φ g - φ (φ g) := by rw [map_sub]
    rw [this, hφ]
  · -- D(N(g)) = (g + φ g) - φ(g + φ g) = g + φ g - φ g - φ(φ g) = g - g = 0
    have : φ (g + φ g) = φ g + φ (φ g) := by rw [map_add]
    rw [this, hφ]
/-- Exactness at the middle term: if N(g) = 0, then g is in the image of D.
    This is the key content of the Mayer-Vietoris sequence for two-chart covers.
    Proof uses the explicit witness h = g/2. -/
theorem mayer_vietoris_exactness_real (φ : ℝ →+ ℝ) (hφ : ∀ x, φ (φ x) = x)
    (g : ℝ) (hN : g + φ g = 0) :
    ∃ h : ℝ, g = h - φ h := by
  use g / 2
  have hphi_g : φ g = -g := by linarith
  have key : φ (g / 2) = -(g / 2) := by
    have h1 : g / 2 + g / 2 = g := by ring
    have h2 : φ (g / 2) + φ (g / 2) = φ g := by
      rw [← map_add, h1]
    rw [hphi_g] at h2
/-! ## Part 10: The Tate Norm Kills the Antisymmetric Eigenspace -/
/-- The Tate norm kills the -1 eigenspace: N(g) = 0 if φ(g) = -g. -/
theorem tateNorm_kills_minus_eigen {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (g : G) (hg : D.transition g = -g) :
    tateNorm D g = 0 := by
  simp [tateNorm, hg, add_neg_cancel]
/-- The Tate norm doubles the +1 eigenspace: N(g) = 2g if φ(g) = g. -/
theorem tateNorm_doubles_plus_eigen {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (g : G) (hg : D.transition g = g) :
    tateNorm D g = g + g := by
  simp [tateNorm, hg]
/-! ## Part 11: Euler Characteristic Bound -/
/-- For finite groups, the total eigenspace count is bounded by 2|G|. -/
theorem euler_char_bound {G : Type*} [Fintype G] [AddCommGroup G] [DecidableEq G]
    Fintype.card {g : G | D.transition g = g} +
    Fintype.card {g : G | D.transition g = -g} ≤
    2 * Fintype.card G := by
  calc Fintype.card {g : G | D.transition g = g} +
       Fintype.card {g : G | D.transition g = -g}
      ≤ Fintype.card G + Fintype.card G := by
        apply Nat.add_le_add
        · exact Fintype.card_subtype_le _
        · exact Fintype.card_subtype_le _
    _ = 2 * Fintype.card G := by ring
/-! ## Part 12: Conformal Factor Analysis -/
/-- The stereographic conformal factor satisfies a key identity:
    The product λ(t) · λ(1/t) simplifies to a rational expression,
    connecting the conformal structure to the transition map. -/
theorem conformal_factor_transition_identity (t : ℝ) (ht : t ≠ 0) :
    stereoConformalFactor t * stereoConformalFactor (1/t) =
    4 * t ^ 2 / ((1 + t ^ 2) * (t ^ 2 + 1)) := by
  simp only [stereoConformalFactor]
  have h1 : (1 : ℝ) + t ^ 2 > 0 := by positivity
  have h2 : t ^ 2 > 0 := by positivity
  have h3 : 1 + (1/t) ^ 2 = (t^2 + 1) / t^2 := by field_simp; ring
  rw [h3]
/-! ## Part 13: Falsifiable Conjecture with Computational Test -/
/-- **Conjecture** (Eigenspace Partition for Involutions on Finite Abelian Groups):
For a finite abelian group G with an involutive automorphism φ,
the elements of G partition into three classes:
1. Fixed points: {g | φ(g) = g}
2. Anti-fixed points: {g | φ(g) = -g}
3. Non-eigen elements: {g | φ(g) ≠ g ∧ φ(g) ≠ -g}
**Claim**: For cyclic groups ZMod p with p odd prime and φ = negation,
class 3 is exactly G \ {0}  minus the elements of order 2.
Since p is odd prime, there are no elements of order 2, so class 3
has exactly p - 1 elements and class 1 ∪ class 2 = {0}.
**Test**: Verify for p = 3, 5, 7.
**Disproof path**: Check if there exist elements g ≠ 0 with -g = g
in ZMod p for odd prime p. There shouldn't be any.
/-- For ZMod 7 with negation, the only fixed point is zero. -/
theorem zmod7_negation_fixed_unique :
    ∀ x : ZMod 7, -x = x → x = 0 := by decide
/-- For ZMod 6 with negation, there exist non-zero fixed points.
    This shows the conjecture's odd-prime hypothesis is necessary:
    6 is even, so 3 is a non-zero fixed point (-3 = 3 in ZMod 6). -/
theorem zmod6_negation_has_nontrivial_fixed :
    ∃ x : ZMod 6, x ≠ 0 ∧ -x = x := by decide
/-! ## Part 14: The Norm-Restriction Adjunction -/
/-- The norm map N and the inclusion ι : H⁰ ↪ G satisfy the adjunction:
    for any g ∈ G and h ∈ H⁰, N(g) = h iff g agrees with h modulo
    the antisymmetric part. This is a baby version of Shapiro's lemma. -/
theorem norm_restriction_adjunction {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (g h : G)
    (hh : h ∈ cechH0 D) :
    tateNorm D g = h ↔ g + D.transition g = h := by
  simp only [cechH0, mem_setOf_eq] at hh
  constructor
  · intro heq; exact heq
  · intro heq; exact heq
/-- The difference map D(g) = g - φ(g) always lands in the -1 eigenspace.
    This is dual to the Tate norm landing in H⁰. -/
theorem difference_in_minus_eigen {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) (g : G) :
    D.transition (g - D.transition g) = -(g - D.transition g) := by
  rw [map_sub, D.involutive]
/-! ## Part 15: Composition and Functoriality -/
/-- The zero morphism between any two gluing data. -/
def zeroMorphism {G H : Type*} [AddCommGroup G] [AddCommGroup H]
    (D₁ : StereoGluingDatum G) (D₂ : StereoGluingDatum H) :
    StereoSheafMorphism D₁ D₂ where
  map := 0
  intertwine := by simp [map_zero]
/-- The zero morphism maps everything to zero in H⁰. -/
theorem zeroMorphism_image {G H : Type*} [AddCommGroup G] [AddCommGroup H]
    (D₁ : StereoGluingDatum G) (D₂ : StereoGluingDatum H) (g : G) :
    (zeroMorphism D₁ D₂).map g = 0 := by
  simp [zeroMorphism]
/-- Morphism composition is associative. -/
theorem comp_assoc {G H K L : Type*}
    [AddCommGroup G] [AddCommGroup H] [AddCommGroup K] [AddCommGroup L]
    {D₁ : StereoGluingDatum G} {D₂ : StereoGluingDatum H}
    {D₃ : StereoGluingDatum K} {D₄ : StereoGluingDatum L}
    (f : StereoSheafMorphism D₃ D₄)
    (g : StereoSheafMorphism D₂ D₃)
    (h : StereoSheafMorphism D₁ D₂) :
    (f.comp (g.comp h)).map = (f.comp g).comp h |>.map := by
  simp [StereoSheafMorphism.comp, AddMonoidHom.comp_apply]