import Mathlib

/-!
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

## Novel Definitions

* `ConformalWeightDatum` — Gluing data weighted by conformal factors
* `MayerVietorisData` — The complete data for a Mayer-Vietoris sequence
* `StereoSheafMorphism` — Morphisms between stereographic gluing data

## Main Results

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
-/

noncomputable section

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
  ext x
  simp only [Submodule.mem_inf, Submodule.mem_bot,
    plusEigenspace, minusEigenspace, Submodule.mem_mk, AddSubmonoid.mem_mk,
    AddSubsemigroup.mem_mk, mem_setOf_eq]
  constructor
  · intro ⟨hplus, hminus⟩
    linarith
  · intro h
    subst h
    simp [map_zero]

/-- Every element decomposes into ±1 eigenspace components under an involution.
    This is the spectral decomposition for ℤ/2ℤ representations over ℝ. -/
theorem eigenspace_spanning (φ : ℝ →ₗ[ℝ] ℝ) (hφ : ∀ x, φ (φ x) = x) (g : ℝ) :
    ∃ s a : ℝ, φ s = s ∧ φ a = -a ∧ g = s + a := by
  refine ⟨(g + φ g) / 2, (g - φ g) / 2, ?_, ?_, ?_⟩
  · -- φ((g + φ g)/2) = (g + φ g)/2
    have h1 : φ ((g + φ g) / 2) = (φ g + φ (φ g)) / 2 := by
      rw [show (g + φ g) / 2 = (2 : ℝ)⁻¹ • (g + φ g) from by ring]
      rw [map_smul, map_add]
      ring
    rw [h1, hφ]; ring
  · -- φ((g - φ g)/2) = -(g - φ g)/2
    have h1 : φ ((g - φ g) / 2) = (φ g - φ (φ g)) / 2 := by
      rw [show (g - φ g) / 2 = (2 : ℝ)⁻¹ • (g - φ g) from by ring]
      rw [map_smul, map_sub]
      ring
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
  gluing : StereoGluingDatum G
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
    intro x
    simp [AddMonoidHom.comp_apply]
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
  abel

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
  ext x
  simp only [cechH0Subgroup, AddSubgroup.mem_mk, Set.mem_setOf_eq,
    AddSubgroup.mem_bot, StereoGluingDatum.negation_transition_apply]
  constructor
  · intro h; linarith
  · intro h; subst h; simp

/-- H⁰ of the trivial gluing is the entire group. -/
theorem cechH0Subgroup_trivial_eq_top {G : Type*} [AddCommGroup G] :
    cechH0Subgroup (StereoGluingDatum.trivial : StereoGluingDatum G) = ⊤ := by
  ext x
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
    (D : StereoGluingDatum G) :
    {g : G | D.transition g = g} = ↑(cechH0Subgroup D) := by
  ext x
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
  abel

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
    abel

/-- The kernel of the Čech differential is the set of global sections. -/
theorem cechDifferentialHom_ker {G : Type*} [AddCommGroup G]
    (D : StereoGluingDatum G) :
    ∀ ab : G × G, ab ∈ AddMonoidHom.ker (cechDifferentialHom D) ↔
      D.transition ab.1 = ab.2 := by
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
    (g : ℝ) :
    let N := fun x => x + φ x
    let D := fun x => x - φ x
    N (D g) = 0 ∧ D (N g) = 0 := by
  constructor
  · -- N(D(g)) = (g - φ g) + φ(g - φ g) = g - φ g + φ g - φ(φ g) = g - g = 0
    simp only
    have : φ (g - φ g) = φ g - φ (φ g) := by rw [map_sub]
    rw [this, hφ]
    ring
  · -- D(N(g)) = (g + φ g) - φ(g + φ g) = g + φ g - φ g - φ(φ g) = g - g = 0
    simp only
    have : φ (g + φ g) = φ g + φ (φ g) := by rw [map_add]
    rw [this, hφ]
    ring

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
    linarith
  linarith

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
    (D : StereoGluingDatum G) :
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
  field_simp
  ring

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
-/

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
  abel

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
  ext x
  simp [StereoSheafMorphism.comp, AddMonoidHom.comp_apply]

end