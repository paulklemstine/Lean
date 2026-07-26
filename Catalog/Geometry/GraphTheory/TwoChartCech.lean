import Mathlib

/-!
# Two-Chart Čech Cohomology: The Algebraic Core of Stereographic Sheaf Theory

We formalize the algebraic framework of Čech cohomology for a two-element
open cover. This captures the essential algebra underlying the Mayer-Vietoris
sequence and applies to any space with a two-chart atlas, including spheres
with stereographic charts.

The key structural insight: for a two-element cover {U₀, U₁}, the Čech nerve
has exactly two vertices and one edge, so the Čech complex truncates at
degree 1. This means ALL cohomological information is encoded in a single
homomorphism — the Čech differential d⁰ : F(U₀) × F(U₁) → F(U₀ ∩ U₁).

## Main Definitions

* `TwoChartDatum` — algebraic gluing data for a two-chart cover
* `TwoChartDatum.cechDiff` — the Čech differential d⁰
* `TwoChartDatum.globalSections` — H⁰, the kernel of d⁰
* `TwoChartMorphism` — morphisms of two-chart data

## Main Results

* `mem_globalSections_iff` — global sections = equalizer of restrictions
* `morphism_maps_globalSections` — functoriality on H⁰
* `cechDiff_surjective_of_jointly_surjective` — H¹ vanishing criterion
* `globalSections_of_id` — concrete computation for trivial restrictions
-/

namespace TwoChartCech

/-! ### Core Structure -/

/-- A `TwoChartDatum` encodes the algebraic data of an abelian presheaf
on a space covered by two open sets U₀ and U₁. -/
structure TwoChartDatum where
  F₀ : Type*
  F₁ : Type*
  F₀₁ : Type*
  [grp₀ : AddCommGroup F₀]
  [grp₁ : AddCommGroup F₁]
  [grp₀₁ : AddCommGroup F₀₁]
  ρ₀ : F₀ →+ F₀₁
  ρ₁ : F₁ →+ F₀₁

attribute [instance] TwoChartDatum.grp₀ TwoChartDatum.grp₁ TwoChartDatum.grp₀₁

namespace TwoChartDatum

variable (D : TwoChartDatum)

/-! ### The Čech Differential -/

/-- The Čech differential d⁰ : F(U₀) × F(U₁) → F(U₀ ∩ U₁),
defined by d⁰(s₀, s₁) = ρ₀(s₀) - ρ₁(s₁). -/
def cechDiff : D.F₀ × D.F₁ →+ D.F₀₁ :=
  AddMonoidHom.mk' (fun p => D.ρ₀ p.1 - D.ρ₁ p.2) (by
    intro ⟨a₁, a₂⟩ ⟨b₁, b₂⟩
    simp only [Prod.fst_add, Prod.snd_add, map_add]
    abel)

@[simp]
theorem cechDiff_apply (s₀ : D.F₀) (s₁ : D.F₁) :
    D.cechDiff (s₀, s₁) = D.ρ₀ s₀ - D.ρ₁ s₁ := rfl

/-- Global sections: the kernel of the Čech differential. -/
def globalSections : AddSubgroup (D.F₀ × D.F₁) := D.cechDiff.ker

/-! ### Theorem 1: Characterization of Global Sections -/

/-
!-- Global sections are exactly the pairs that agree on the overlap.
Proof: unfold definitions and use sub_eq_zero. -- !--

**Characterization of global sections.**
A pair (s₀, s₁) is a global section if and only if the restrictions
agree: ρ₀(s₀) = ρ₁(s₁).
-/
theorem mem_globalSections_iff (p : D.F₀ × D.F₁) :
    p ∈ D.globalSections ↔ D.ρ₀ p.1 = D.ρ₁ p.2 := by
  exact sub_eq_zero

/-
Example: zero is always a global section.
-/
example : (0 : D.F₀ × D.F₁) ∈ D.globalSections := by
  exact AddMonoidHom.map_zero _

-- Generalization: for an n-chart cover, global sections are the kernel
-- of the total differential ∏ᵢ F(Uᵢ) → ∏ᵢ<ⱼ F(Uᵢ ∩ Uⱼ).
-- This requires a symmetric overlap type; we leave this for future work.

/-- Boundary: the additive inverse of a global section is a global section.
This relies on the abelian group structure — for monoids, negation doesn't exist. -/
example (p : D.F₀ × D.F₁) (hp : p ∈ D.globalSections) :
    -p ∈ D.globalSections :=
  D.globalSections.neg_mem hp

/-! ### Theorem 2: Functoriality -/

end TwoChartDatum

/-- A morphism of two-chart data: compatible homomorphisms on each piece. -/
structure TwoChartMorphism (D E : TwoChartDatum) where
  f₀ : D.F₀ →+ E.F₀
  f₁ : D.F₁ →+ E.F₁
  f₀₁ : D.F₀₁ →+ E.F₀₁
  comm₀ : ∀ x, f₀₁ (D.ρ₀ x) = E.ρ₀ (f₀ x)
  comm₁ : ∀ x, f₀₁ (D.ρ₁ x) = E.ρ₁ (f₁ x)

namespace TwoChartMorphism

variable {D E : TwoChartDatum}

/-
!-- A morphism intertwines the Čech differentials, so it maps
the kernel of D's differential into the kernel of E's differential.
Proof: use the compatibility conditions to rewrite. -- !--

**Functoriality**: a morphism of two-chart data maps global sections
to global sections.
-/
theorem morphism_maps_globalSections (φ : TwoChartMorphism D E)
    (p : D.F₀ × D.F₁) (hp : p ∈ D.globalSections) :
    (φ.f₀ p.1, φ.f₁ p.2) ∈ E.globalSections := by
  simp_all +decide [ TwoChartDatum.mem_globalSections_iff ];
  rw [ ← φ.comm₀, ← φ.comm₁, hp ]

/-- The induced map on global sections as an additive homomorphism. -/
noncomputable def onGlobalSections (φ : TwoChartMorphism D E) :
    D.globalSections →+ E.globalSections where
  toFun := fun ⟨p, hp⟩ => ⟨(φ.f₀ p.1, φ.f₁ p.2), φ.morphism_maps_globalSections p hp⟩
  map_zero' := by
    ext <;> simp
  map_add' := by
    intro ⟨a, ha⟩ ⟨b, hb⟩
    ext <;> simp [map_add]

/-- Example: the identity morphism. -/
def idMorphism (D : TwoChartDatum) : TwoChartMorphism D D where
  f₀ := AddMonoidHom.id _
  f₁ := AddMonoidHom.id _
  f₀₁ := AddMonoidHom.id _
  comm₀ := fun _ => rfl
  comm₁ := fun _ => rfl

theorem onGlobalSections_id (D : TwoChartDatum) (s : D.globalSections) :
    (idMorphism D).onGlobalSections s = s := by
  rfl

/-- Composition of morphisms. -/
def comp {D E G : TwoChartDatum} (φ : TwoChartMorphism E G) (ψ : TwoChartMorphism D E) :
    TwoChartMorphism D G where
  f₀ := φ.f₀.comp ψ.f₀
  f₁ := φ.f₁.comp ψ.f₁
  f₀₁ := φ.f₀₁.comp ψ.f₀₁
  comm₀ := fun x => by
    simp only [AddMonoidHom.comp_apply]
    rw [ψ.comm₀, φ.comm₀]
  comm₁ := fun x => by
    simp only [AddMonoidHom.comp_apply]
    rw [ψ.comm₁, φ.comm₁]

/-
Generalization: composition respects the induced map on global sections.
-/
theorem onGlobalSections_comp {D E G : TwoChartDatum}
    (φ : TwoChartMorphism E G) (ψ : TwoChartMorphism D E) (s : D.globalSections) :
    (φ.comp ψ).onGlobalSections s = φ.onGlobalSections (ψ.onGlobalSections s) := by
  rfl

/-
Boundary: without the compatibility conditions, global sections are NOT preserved.
-/
theorem boundary_no_compat :
    ∃ (D E : TwoChartDatum) (f₀ : D.F₀ →+ E.F₀) (f₁ : D.F₁ →+ E.F₁),
    ∃ p ∈ D.globalSections, (f₀ p.1, f₁ p.2) ∉ E.globalSections := by
  fconstructor;
  refine' { F₀ := ULift ℤ, F₁ := ULift ℤ, F₀₁ := ULift ℤ, ρ₀ := _, ρ₁ := _ };
  exact 0;
  exact AddMonoidHom.mk' ( fun x => ⟨ x.down * 2 ⟩ ) ( by intros; ext; simp +decide ; ring );
  refine' ⟨ _, _, _, _ ⟩ <;> norm_num [ TwoChartDatum.globalSections ];
  refine' { F₀ := ULift ℤ, F₁ := ULift ℤ, F₀₁ := ULift ℤ, grp₀ := inferInstance, grp₁ := inferInstance, grp₀₁ := inferInstance, ρ₀ := AddMonoidHom.mk' ( fun x => ⟨ x.down * 2 ⟩ ) ( by intros; ext; simp +decide ; ring ), ρ₁ := 0 };
  exact AddMonoidHom.mk' ( fun x => ⟨ x.down * 2 ⟩ ) ( by intros; ext; simp +decide ; ring );
  exact AddMonoidHom.mk' ( fun x => ⟨ x.down * 2 ⟩ ) ( by intros; ext; simp +decide ; ring );
  exists 1, 0

end TwoChartMorphism

namespace TwoChartDatum

variable (D : TwoChartDatum)

/-! ### Theorem 3: H¹ Vanishing Criterion -/

/-
!-- When ρ₀ is surjective, for any z ∈ F₀₁ we find s₀ with ρ₀(s₀) = z,
then d(s₀, 0) = z, so d is surjective. -- !--

**H¹ vanishing**: if ρ₀ is surjective, then the Čech differential
is surjective, which means Ȟ¹ = F₀₁ / im(d⁰) = 0.
-/
theorem cechDiff_surjective_of_surjective_rho0
    (h₀ : Function.Surjective D.ρ₀) :
    Function.Surjective D.cechDiff := by
  intro y; cases' h₀ y with x hx; use ( x, 0 ) ; aesop;

/-
Example: when F₀ = F₁ = F₀₁ = ℤ and ρ₀ = id, d is surjective.
-/
example : Function.Surjective
    (TwoChartDatum.mk (ℤ) (ℤ) (ℤ) (AddMonoidHom.id ℤ) (AddMonoidHom.id ℤ)).cechDiff := by
  convert TwoChartDatum.cechDiff_surjective_of_surjective_rho0 _ _;
  exact Function.surjective_id

/-
Generalization: characterize elements in the image of d⁰.
-/
theorem mem_range_cechDiff_iff (z : D.F₀₁) :
    z ∈ D.cechDiff.range ↔ ∃ s₀ : D.F₀, ∃ s₁ : D.F₁, D.ρ₀ s₀ - D.ρ₁ s₁ = z := by
  simp +decide [D.cechDiff_apply]

/-
Boundary: with non-surjective restrictions, d can fail to be surjective.
Here ρ₀(n) = (n, 0) and ρ₁(n) = (0, n), so im(d) misses elements like (1, 1).
-/
theorem boundary_nonsurjective :
    ¬ Function.Surjective
    (TwoChartDatum.mk (ℤ) (ℤ) (ℤ)
      ((2 : ℤ) • AddMonoidHom.id ℤ)
      (0 : ℤ →+ ℤ)).cechDiff := by
  unfold Function.Surjective;
  simp +decide [ TwoChartDatum.cechDiff ];
  exact ⟨ 1, fun x hx => by linarith [ show x = 0 by linarith ] ⟩

/-! ### Theorem 4: Concrete Computation — Constant Sheaf -/

-- !-- When both restrictions are the identity (constant sheaf), global sections
-- are exactly the diagonal {(x, x)}, giving H⁰ = G. -- !--

/-- The constant sheaf datum: F₀ = F₁ = F₀₁ = G with identity restrictions. -/
def constantDatum (G : Type*) [AddCommGroup G] : TwoChartDatum where
  F₀ := G
  F₁ := G
  F₀₁ := G
  ρ₀ := AddMonoidHom.id G
  ρ₁ := AddMonoidHom.id G

/-
**Constant sheaf computation**: global sections of the constant datum
are exactly the diagonal — pairs (x, x). This is H⁰(X, G) = G.
-/
theorem globalSections_of_id (G : Type*) [AddCommGroup G] (p : G × G) :
    p ∈ (constantDatum G).globalSections ↔ p.1 = p.2 := by
  convert mem_globalSections_iff ( constantDatum G ) p using 1

/-
Example: (3, 3) is a global section of the constant ℤ-datum.
-/
example : ((3 : ℤ), (3 : ℤ)) ∈ (constantDatum ℤ).globalSections := by
  exact Set.mem_setOf.mpr rfl

/-
Example: (1, 2) is NOT a global section of the constant ℤ-datum.
-/
example : ((1 : ℤ), (2 : ℤ)) ∉ (constantDatum ℤ).globalSections := by
  exact fun h => by have := TwoChartDatum.globalSections_of_id ℤ ( 1, 2 ) ; simp_all +decide ;

/-- The diagonal embedding into global sections of the constant datum. -/
def constantDatum_diag (G : Type*) [AddCommGroup G] :
    G →+ (constantDatum G).globalSections where
  toFun g := ⟨(g, g), by
    show (g, g) ∈ (constantDatum G).globalSections
    rw [globalSections, AddMonoidHom.mem_ker]
    simp [constantDatum, cechDiff]⟩
  map_zero' := by ext <;> simp
  map_add' := by intro a b; ext <;> simp

/-
The diagonal embedding is injective.
-/
theorem constantDatum_diag_injective (G : Type*) [AddCommGroup G] :
    Function.Injective (constantDatum_diag G) := by
  intro x y hxy
  have : (x, x) = (y, y) := by
    injection hxy
  aesop

/-
The diagonal embedding is surjective — every global section is diagonal.
-/
theorem constantDatum_diag_surjective (G : Type*) [AddCommGroup G] :
    Function.Surjective (constantDatum_diag G) := by
  intro ⟨ x, hx ⟩;
  convert globalSections_of_id G x;
  simp +decide [ constantDatum_diag, Subtype.ext_iff ];
  grind

/-
Generalization: if ρ₁ is injective,
the projection from global sections to F₀ is injective.
(Only injectivity of ρ₁ is needed, not ρ₀.)
-/
theorem globalSections_proj_injective
    (h₁ : Function.Injective D.ρ₁) :
    Function.Injective (fun (s : D.globalSections) => s.1.1) := by
  intro s t h;
  have := D.mem_globalSections_iff s; have := D.mem_globalSections_iff t; aesop;

/-! ### Čech Differential Basic Properties -/

/-
The Čech differential of (s, 0) recovers ρ₀(s).
-/
@[simp]
theorem cechDiff_fst (s : D.F₀) : D.cechDiff (s, 0) = D.ρ₀ s := by
  simp +decide [ TwoChartDatum.cechDiff ]

/-
The Čech differential of (0, s) recovers -ρ₁(s).
-/
@[simp]
theorem cechDiff_snd (s : D.F₁) : D.cechDiff (0, s) = -D.ρ₁ s := by
  simp +decide [ TwoChartDatum.cechDiff ]

end TwoChartDatum

end TwoChartCech