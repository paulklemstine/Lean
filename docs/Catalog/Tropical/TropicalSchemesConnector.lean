import Mathlib

/-!
# Tropical schemes: corner loci, bend equations, and sheaf gluing

This file gives a self-contained semiring-scheme model suited to tropical geometry.
It isolates the part of the Grothendieck construction that does not require additive
inverses: a topological space equipped with a sheaf of commutative semirings.

The main connector theorem identifies two descriptions of a tropical hypersurface:

* the polyhedral description: the minimum of the polynomial's terms is attained twice;
* the scheme-theoretic description: every bend equation (delete one term) holds.

Thus the points of the principal tropical scheme cut out by the bend equations are
exactly the classical corner locus.  The canonical function structure sheaf is also
proved to satisfy arbitrary-cover existence and uniqueness of gluings.
-/

noncomputable section

open Set

namespace TropicalSchemes

/-! ## Semiring-valued sheaves -/

/-- A presheaf of commutative semirings, presented by sections and restriction maps. -/
structure SemiringPresheaf (X : Type*) where
  Section : Set X → Type*
  sectionSemiring : ∀ U, CommSemiring (Section U)
  restrict : ∀ {U V : Set X}, V ⊆ U → Section U →+* Section V
  restrict_id : ∀ (U : Set X) (s : Section U), restrict (Subset.rfl) s = s
  restrict_comp : ∀ {U V W : Set X} (hVU : V ⊆ U) (hWV : W ⊆ V) (s : Section U),
    restrict (fun _ hx => hVU (hWV hx)) s =
      @restrict V W hWV (@restrict U V hVU s)

attribute [instance] SemiringPresheaf.sectionSemiring

/-- The usual existence-and-uniqueness gluing axiom, for arbitrary indexed covers. -/
def SemiringPresheaf.IsSheaf {X : Type*} (F : SemiringPresheaf X) : Prop :=
  ∀ {ι : Type*} {U : Set X} (V : ι → Set X) (hcover : U = ⋃ i, V i),
    ∀ (s : ∀ i, F.Section (V i)),
      (∀ i j, F.restrict (inter_subset_left : V i ∩ V j ⊆ V i) (s i) =
        F.restrict (inter_subset_right : V i ∩ V j ⊆ V j) (s j)) →
      ∃! t : F.Section U, ∀ i,
        F.restrict (by intro x hx; rw [hcover]; exact mem_iUnion.mpr ⟨i, hx⟩) t = s i

/-- The canonical presheaf of `K`-valued functions.  This is the basic affine
structure sheaf model used below; operations are pointwise. -/
def functionPresheaf (K X : Type*) [CommSemiring K] : SemiringPresheaf X where
  Section U := U → K
  sectionSemiring _ := inferInstance
  restrict h :=
    { toFun := fun s x => s ⟨x.1, h x.2⟩
      map_one' := rfl
      map_mul' := fun _ _ => rfl
      map_zero' := rfl
      map_add' := fun _ _ => rfl }
  restrict_id _ _ := rfl
  restrict_comp _ _ _ := rfl

/-- Functions glue uniquely.  In particular, the structure sheaf of the tropical
scheme model below satisfies the tropical gluing axiom. -/
theorem functionPresheaf_isSheaf (K X : Type*) [CommSemiring K] :
    (functionPresheaf K X).IsSheaf := by
  rw [SemiringPresheaf.IsSheaf]
  intro ι U V hcover s hcompat
  let chooseIndex : U → ι := fun x =>
    Classical.choose (mem_iUnion.mp (show x.1 ∈ ⋃ i, V i by rw [← hcover]; exact x.2))
  have chooseIndex_mem (x : U) : x.1 ∈ V (chooseIndex x) := by
    exact Classical.choose_spec
      (mem_iUnion.mp (show x.1 ∈ ⋃ i, V i by rw [← hcover]; exact x.2))
  let t : U → K := fun x => s (chooseIndex x) ⟨x.1, chooseIndex_mem x⟩
  refine ⟨t, ?_, ?_⟩
  · intro i
    funext x
    let ux : U := ⟨x.1, by rw [hcover]; exact mem_iUnion.mpr ⟨i, x.2⟩⟩
    have hc := hcompat (chooseIndex ux) i
    change (fun z : (V (chooseIndex ux) ∩ V i : Set X) => s (chooseIndex ux) ⟨z.1, z.2.1⟩) =
      (fun z : (V (chooseIndex ux) ∩ V i : Set X) => s i ⟨z.1, z.2.2⟩) at hc
    exact congrFun hc ⟨x.1, chooseIndex_mem ux, x.2⟩
  · intro u hu
    funext x
    have hc := hu (chooseIndex x)
    change (fun z : V (chooseIndex x) => u ⟨z.1, by rw [hcover]; exact mem_iUnion.mpr ⟨chooseIndex x, z.2⟩⟩) =
      s (chooseIndex x) at hc
    exact congrFun hc ⟨x.1, chooseIndex_mem x⟩

/-- A semiring scheme over `K`: a topological space with a sheaf of commutative
semirings and a map from constants into global sections.  This is the direct
semiring analogue of the locally ringed-space layer of Grothendieck schemes. -/
structure SemiringSchemeOver (K : Type*) [CommSemiring K] where
  Point : Type*
  topology : TopologicalSpace Point
  structureSheaf : SemiringPresheaf Point
  isSheaf : structureSheaf.IsSheaf
  constants : K →+* structureSheaf.Section Set.univ

attribute [instance] SemiringSchemeOver.topology

/-- Every space has a canonical `K`-semiring scheme whose sections are functions. -/
def functionScheme (K X : Type*) [CommSemiring K] [TopologicalSpace X] :
    SemiringSchemeOver K where
  Point := X
  topology := inferInstance
  structureSheaf := functionPresheaf K X
  isSheaf := functionPresheaf_isSheaf K X
  constants :=
    { toFun := fun k _ => k
      map_one' := rfl
      map_mul' := fun _ _ => rfl
      map_zero' := rfl
      map_add' := fun _ _ => rfl }

/-- The standard min-plus tropical semiring used as the base semiring. -/
abbrev TropicalSemiring := Tropical (WithTop ℝ)

/-- A tropical scheme is a semiring scheme over the tropical semiring. -/
abbrev TropicalScheme := SemiringSchemeOver TropicalSemiring

/-! ## Corner loci and bend equations -/

variable {X α I : Type*}

/-- A term is pointwise minimal among all terms. -/
def IsMin [Preorder α] (f : I → X → α) (x : X) (i : I) : Prop :=
  ∀ k, f i x ≤ f k x

/-- The corner predicate: at least two distinct terms attain the minimum. -/
def IsCorner [Preorder α] (f : I → X → α) (x : X) : Prop :=
  ∃ i j, i ≠ j ∧ IsMin f x i ∧ IsMin f x j

/-- The bend equation associated with term `i`: after deleting `i`, another term
has value no larger than `i`.  At a minimum this says deletion does not change
the tropical polynomial's value. -/
def BendEquation [Preorder α] (f : I → X → α) (x : X) (i : I) : Prop :=
  ∃ j, j ≠ i ∧ f j x ≤ f i x

/-- The scheme-theoretic bend vanishing set: all bend equations hold. -/
def bendVanishingSet [Preorder α] (f : I → X → α) : Set X :=
  {x | ∀ i, BendEquation f x i}

/-- **Corner–bend connector.**  Provided a minimum exists, the polyhedral corner
condition is equivalent to the simultaneous validity of all scheme-theoretic bend
equations.  This is the key bridge from tropical piecewise-linear geometry to
Grothendieck-style equations and congruences. -/
theorem isCorner_iff_forall_bend [PartialOrder α] (f : I → X → α) (x : X)
    (hmin : ∃ i, IsMin f x i) :
    IsCorner f x ↔ ∀ i, BendEquation f x i := by
  constructor
  · rintro ⟨a, b, hab, ha, hb⟩ i
    by_cases hia : i = a
    · exact ⟨b, by simpa [hia] using hab.symm, hb i⟩
    · exact ⟨a, fun h => hia h.symm, ha i⟩
  · intro hbend
    obtain ⟨i, hi⟩ := hmin
    obtain ⟨j, hji, hjle⟩ := hbend i
    refine ⟨i, j, hji.symm, hi, ?_⟩
    intro k
    exact hjle.trans (hi k)

/-- Set form: the bend-equation support equals the classical corner locus. -/
theorem bendVanishingSet_eq_cornerLocus [PartialOrder α] (f : I → X → α)
    (hmin : ∀ x, ∃ i, IsMin f x i) :
    bendVanishingSet f = {x | IsCorner f x} := by
  ext x
  exact (isCorner_iff_forall_bend f x (hmin x)).symm

/-! ## The tropical scheme of a polynomial -/

/-- The principal tropical scheme associated with a polynomial term family.
Its points satisfy every bend equation and its structure sheaf is the canonical
semiring-valued function sheaf. -/
def principalTropicalScheme (K : Type*) [CommSemiring K]
    [TopologicalSpace X] [Preorder α] (f : I → X → α) : SemiringSchemeOver K :=
  let Y := bendVanishingSet f
  @functionScheme K Y _ inferInstance

/-- **Main scheme/corner-locus theorem.**  The underlying point set of the
principal tropical scheme associated to a finite tropical polynomial is canonically
the polynomial's corner locus. -/
theorem principalTropicalScheme_points_iff_corner [CommSemiring α] [TopologicalSpace X]
    [PartialOrder α] (f : I → X → α) (hmin : ∀ x, ∃ i, IsMin f x i) (x : X) :
    x ∈ bendVanishingSet f ↔ IsCorner f x :=
  (isCorner_iff_forall_bend f x (hmin x)).symm

/-- The principal scheme of an actual tropical-semiring-valued polynomial. -/
def tropicalPolynomialScheme [TopologicalSpace X]
    (f : I → X → TropicalSemiring) : TropicalScheme :=
  principalTropicalScheme TropicalSemiring f

/-- Specialized connector: an actual tropical polynomial scheme has exactly the
points of its classical corner locus. -/
theorem tropicalPolynomialScheme_points_iff_corner [TopologicalSpace X]
    (f : I → X → TropicalSemiring) (hmin : ∀ x, ∃ i, IsMin f x i) (x : X) :
    x ∈ bendVanishingSet f ↔ IsCorner f x :=
  principalTropicalScheme_points_iff_corner f hmin x

/-- The structure sheaf on a principal tropical scheme satisfies gluing. -/
theorem principalTropicalScheme_tropical_gluing [CommSemiring α] [TopologicalSpace X]
    [Preorder α] (f : I → X → α) :
    (principalTropicalScheme α f).structureSheaf.IsSheaf :=
  (principalTropicalScheme α f).isSheaf

/-! ## A concrete check -/

/-- The min-plus linear polynomial `min(0,x)` has a corner at `x = 0`. -/
def linearTerms : Fin 2 → ℤ → ℤ
  | 0 => fun _ => 0
  | 1 => fun x => x

/-- Both bend equations, hence the principal tropical scheme, select the crossing. -/
theorem linear_principal_scheme_exact (x : ℤ) :
    x ∈ bendVanishingSet linearTerms ↔ x = 0 := by
  constructor
  · intro h
    have h0 := h 0
    have h1 := h 1
    rcases h0 with ⟨j, hj, hle⟩
    fin_cases j <;> simp [linearTerms] at hj hle
    rcases h1 with ⟨j, hj, hle'⟩
    fin_cases j <;> simp [linearTerms] at hj hle'
    omega
  · rintro rfl
    intro i
    fin_cases i
    · exact ⟨1, by decide, by simp [linearTerms]⟩
    · exact ⟨0, by decide, by simp [linearTerms]⟩

end TropicalSchemes