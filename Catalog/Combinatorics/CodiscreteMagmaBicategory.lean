/-
# Codiscrete bicategories of unital magmas

For an *arbitrary* pointed magma `M` (a type with a multiplication `* : M → M → M` and a
distinguished element `1 : M`, subject to **no axioms whatsoever**) we build a bicategory
`MagmaBicat M` with a single object `⋆`, whose category of 1-cells `⋆ ⟶ ⋆` is the
*codiscrete* category on `M` (exactly one 2-cell between any two 1-cells), horizontal
composition being the magma multiplication and the identity 1-cell being `1`.

The point of the construction is that the codiscrete hom-category converts *arbitrary*
unit and associativity defects of `M` into coherent invertible 2-cells: the associator
`α_ : (a*b)*c ≅ a*(b*c)` and the unitors `λ_ : 1*a ≅ a`, `ρ_ : a*1 ≅ a` always exist and
are invertible, and the pentagon/triangle coherence equations hold automatically, because
the hom-category is thin.

Main definitions:
* `CodiscreteMagma.MagmaBicat M` : the one-object bicategory attached to a pointed magma;
* `CodiscreteMagma.star` : its unique object;
* `CodiscreteMagma.cellEquivalence` : *any* ordered pair of 1-cells is an adjoint equivalence;
* `CodiscreteMagma.mapPseudofunctor` : *any* function `M → N` (no algebraic hypothesis at all)
  induces a pseudofunctor `MagmaBicat M ⥤ᵖ MagmaBicat N`.

Main results:
* `CodiscreteMagma.two_cell_isIso`, `CodiscreteMagma.two_cell_unique` : all 2-cells are
  invertible and any two parallel 2-cells agree (coherence is automatic);
* `CodiscreteMagma.strict_iff_monoid` : the bicategory is *strict* iff the underlying pointed
  magma is a monoid.  So the construction is genuinely weak exactly when `M` has a defect;
* `CodiscreteMagma.assoc_defect_iff` / `CodiscreteMagma.unit_defect_iff` : the associator
  and the unitors are `eqToHom`s precisely at the non-defective triples/elements;
* `CodiscreteMagma.strictly_invertible_iff` : a 1-cell is *strictly* invertible iff the
  corresponding magma element has a two-sided inverse — so, unlike the 2-cell level, the
  1-cell level still remembers the algebra;
* `CodiscreteMagma.mapPseudofunctor_id`, `CodiscreteMagma.mapPseudofunctor_comp` :
  functoriality of the construction on *all* set maps.
-/
import Mathlib

universe u v

open CategoryTheory Bicategory

namespace CodiscreteMagma

/-! ### The unique 2-cell of a codiscrete category -/

/-- The unique isomorphism between two objects of a codiscrete category. -/
def codIso {A : Type u} (x y : Codiscrete A) : x ≅ y where
  hom := ⟨⟩
  inv := ⟨⟩
  hom_inv_id := rfl
  inv_hom_id := rfl

/-- Any two parallel morphisms of a codiscrete category coincide. -/
theorem cod_hom_unique {A : Type u} {x y : Codiscrete A} (η θ : x ⟶ y) : η = θ := rfl

/-! ### The one-object bicategory of a pointed magma -/

/-- The one-object bicategory attached to a pointed magma `M`: its unique object is `star`,
its 1-cells are the elements of `M`, and its 2-cells form the codiscrete category on `M`. -/
@[nolint unusedArguments]
def MagmaBicat (M : Type u) [Mul M] [One M] : Type := PUnit

variable (M : Type u) [Mul M] [One M]

instance : Inhabited (MagmaBicat M) := ⟨PUnit.unit⟩

/-- The unique object of `MagmaBicat M`. -/
def star : MagmaBicat M := PUnit.unit

variable {M}

instance magmaBicategory : Bicategory (MagmaBicat M) where
  Hom _ _ := Codiscrete M
  id _ := ⟨1⟩
  comp f g := ⟨f.as * g.as⟩
  whiskerLeft := by intros; exact PUnit.unit
  whiskerRight := by intros; exact PUnit.unit
  associator _ _ _ := codIso _ _
  leftUnitor _ := codIso _ _
  rightUnitor _ := codIso _ _
  whiskerLeft_id := by intros; rfl
  whiskerLeft_comp := by intros; rfl
  id_whiskerLeft := by intros; rfl
  comp_whiskerLeft := by intros; rfl
  id_whiskerRight := by intros; rfl
  comp_whiskerRight := by intros; rfl
  whiskerRight_id := by intros; rfl
  whiskerRight_comp := by intros; rfl
  whisker_assoc := by intros; rfl
  whisker_exchange := by intros; rfl
  pentagon := by intros; rfl
  triangle := by intros; rfl

/-- The 1-cell of `MagmaBicat M` named by an element of `M`. -/
def cell (a : M) : star M ⟶ star M := ⟨a⟩

@[simp] lemma cell_as (a : M) : (cell a).as = a := rfl

@[simp] lemma comp_cell (a b : M) : cell a ≫ cell b = cell (a * b) := rfl

@[simp] lemma id_cell : 𝟙 (star M) = cell (1 : M) := rfl

lemma cell_injective : Function.Injective (cell : M → (star M ⟶ star M)) := by
  intro a b h
  exact congrArg Codiscrete.as h

@[simp] lemma cell_eq_cell {a b : M} : cell a = cell b ↔ a = b :=
  ⟨fun h => cell_injective h, fun h => by rw [h]⟩

/-! ### Coherence is automatic: the hom-categories are thin groupoids -/

/-- Any two parallel 2-cells of `MagmaBicat M` are equal: every coherence diagram commutes. -/
theorem two_cell_unique {f g : star M ⟶ star M} (η θ : f ⟶ g) : η = θ := rfl

/-- Every 2-cell of `MagmaBicat M` is invertible. -/
theorem two_cell_isIso {f g : star M ⟶ star M} (η : f ⟶ g) : IsIso η :=
  ⟨⟨(codIso g f).hom, two_cell_unique _ _, two_cell_unique _ _⟩⟩

/-- The hom-category of `MagmaBicat M` is a groupoid: the codiscrete category on `M`. -/
noncomputable def homGroupoid : Groupoid (star M ⟶ star M) where
  inv {f g} _ := (codIso g f).hom
  inv_comp _ := two_cell_unique _ _
  comp_inv _ := two_cell_unique _ _

/-- The canonical invertible 2-cell repairing the associativity defect at `(a, b, c)`. -/
def assocDefectIso (a b c : M) : cell ((a * b) * c) ≅ cell (a * (b * c)) := codIso _ _

/-- The canonical invertible 2-cell repairing the left unit defect at `a`. -/
def leftUnitDefectIso (a : M) : cell ((1 : M) * a) ≅ cell a := codIso _ _

/-- The canonical invertible 2-cell repairing the right unit defect at `a`. -/
def rightUnitDefectIso (a : M) : cell (a * (1 : M)) ≅ cell a := codIso _ _

lemma assocDefectIso_eq_associator (a b c : M) :
    assocDefectIso a b c = α_ (cell a) (cell b) (cell c) := rfl

lemma leftUnitDefectIso_eq_leftUnitor (a : M) :
    leftUnitDefectIso a = λ_ (cell a) := rfl

lemma rightUnitDefectIso_eq_rightUnitor (a : M) :
    rightUnitDefectIso a = ρ_ (cell a) := rfl

/-- The associator at `(a,b,c)` is an *endo*-2-cell (i.e. its source and target 1-cells agree)
exactly when the magma is associative at `(a,b,c)`. -/
theorem assoc_defect_iff (a b c : M) :
    (cell a ≫ cell b) ≫ cell c = cell a ≫ (cell b ≫ cell c) ↔ (a * b) * c = a * (b * c) := by
  simp

/-- The left unitor at `a` is an endo-2-cell exactly when `1` is a left unit for `a`. -/
theorem unit_defect_iff (a : M) : 𝟙 (star M) ≫ cell a = cell a ↔ (1 : M) * a = a := by
  simp

/-- The right unitor at `a` is an endo-2-cell exactly when `1` is a right unit for `a`. -/
theorem right_unit_defect_iff (a : M) : cell a ≫ 𝟙 (star M) = cell a ↔ a * (1 : M) = a := by
  simp

/-! ### Every pair of 1-cells is an adjoint equivalence -/

/-- **Codiscreteness trivialises invertibility at the 1-cell level up to iso**: for *any* two
elements `a b : M` — with no algebraic relation between them whatsoever — the 1-cells they name
form an adjoint equivalence of the unique object of `MagmaBicat M` with itself. -/
def cellEquivalence (a b : M) : Bicategory.Equivalence (star M) (star M) where
  hom := cell a
  inv := cell b
  unit := codIso _ _
  counit := codIso _ _
  left_triangle := Iso.ext (two_cell_unique _ _)

@[simp] lemma cellEquivalence_hom (a b : M) : (cellEquivalence a b).hom = cell a := rfl
@[simp] lemma cellEquivalence_inv (a b : M) : (cellEquivalence a b).inv = cell b := rfl

/-- Every 1-cell of `MagmaBicat M` is an equivalence, whatever the magma. -/
theorem exists_equivalence (f : star M ⟶ star M) :
    ∃ e : Bicategory.Equivalence (star M) (star M), e.hom = f :=
  ⟨cellEquivalence f.as f.as, rfl⟩

/-- **The 1-cell layer still remembers the algebra.**  In contrast with `cellEquivalence`,
a 1-cell is *strictly* invertible iff the corresponding magma element has a two-sided inverse. -/
theorem strictly_invertible_iff (a : M) :
    (∃ g : star M ⟶ star M, cell a ≫ g = 𝟙 (star M) ∧ g ≫ cell a = 𝟙 (star M)) ↔
      ∃ b : M, a * b = 1 ∧ b * a = 1 := by
  constructor
  · rintro ⟨g, h₁, h₂⟩
    exact ⟨g.as, congrArg Codiscrete.as h₁, congrArg Codiscrete.as h₂⟩
  · rintro ⟨b, h₁, h₂⟩
    exact ⟨cell b, by simp [h₁], by simp [h₂]⟩

/-! ### Strictness detects exactly the monoid axioms -/

/-- **The strictness criterion.**  `MagmaBicat M` is a strict bicategory (a 2-category) if and
only if the pointed magma `M` is a monoid.  Every genuine unit or associativity defect of `M`
therefore produces a bicategory that is weak but coherent. -/
theorem strict_iff_monoid :
    Bicategory.Strict (MagmaBicat M) ↔
      ((∀ a b c : M, (a * b) * c = a * (b * c)) ∧ (∀ a : M, (1 : M) * a = a) ∧
        ∀ a : M, a * (1 : M) = a) := by
  constructor
  · intro h
    refine ⟨fun a b c => ?_, fun a => ?_, fun a => ?_⟩
    · exact congrArg Codiscrete.as (h.assoc (cell a) (cell b) (cell c))
    · exact congrArg Codiscrete.as (h.id_comp (cell a))
    · exact congrArg Codiscrete.as (h.comp_id (cell a))
  · rintro ⟨hassoc, hone, hone'⟩
    refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro _ _ f; exact Codiscrete.ext (hone f.as)
    · intro _ _ f; exact Codiscrete.ext (hone' f.as)
    · intro _ _ _ _ f g h; exact Codiscrete.ext (hassoc f.as g.as h.as)
    · intro _ _ f; exact Iso.ext (two_cell_unique _ _)
    · intro _ _ f; exact Iso.ext (two_cell_unique _ _)
    · intro _ _ _ _ f g h; exact Iso.ext (two_cell_unique _ _)

/-- A monoid gives a strict bicategory. -/
instance strict_of_monoid {M : Type u} [Monoid M] : Bicategory.Strict (MagmaBicat M) :=
  (strict_iff_monoid).2 ⟨fun a b c => (mul_assoc a b c), fun a => one_mul a, fun a => mul_one a⟩

/-- If the magma has an associativity or a unit defect, the bicategory is **not** strict:
weakness is not an artefact of the encoding. -/
theorem not_strict_of_defect
    (h : (∃ a b c : M, (a * b) * c ≠ a * (b * c)) ∨ (∃ a : M, (1 : M) * a ≠ a) ∨
      (∃ a : M, a * (1 : M) ≠ a)) :
    ¬ Bicategory.Strict (MagmaBicat M) := by
  intro hs
  obtain ⟨h1, h2, h3⟩ := (strict_iff_monoid).1 hs
  rcases h with ⟨a, b, c, hd⟩ | ⟨a, hd⟩ | ⟨a, hd⟩
  · exact hd (h1 a b c)
  · exact hd (h2 a)
  · exact hd (h3 a)

/-! ### Functoriality on *all* set maps -/

section Functoriality

variable {N : Type v} [Mul N] [One N]

/-- **Any** function `f : M → N` — not required to preserve the multiplication or the unit —
induces a pseudofunctor between the codiscrete bicategories.  This is the precise sense in
which the codiscrete construction only sees the underlying pointed set. -/
def mapPseudofunctor (f : M → N) : Pseudofunctor (MagmaBicat M) (MagmaBicat N) where
  obj _ := star N
  map g := cell (f g.as)
  map₂ := by intros; exact PUnit.unit
  map₂_id := by intros; rfl
  map₂_comp := by intros; rfl
  mapId _ := codIso _ _
  mapComp _ _ := codIso _ _
  map₂_whisker_left := by intros; rfl
  map₂_whisker_right := by intros; rfl
  map₂_associator := by intros; rfl
  map₂_left_unitor := by intros; rfl
  map₂_right_unitor := by intros; rfl

@[simp] lemma mapPseudofunctor_map (f : M → N) (a : M) :
    (mapPseudofunctor f).map (cell a) = cell (f a) := rfl

/-- The pseudofunctor induced by the identity map acts as the identity on 1-cells. -/
theorem mapPseudofunctor_id (a : M) :
    (mapPseudofunctor (id : M → M)).map (cell a) = cell a := rfl

/-- The construction is functorial: composing set maps composes the induced pseudofunctors
(on 1-cells). -/
theorem mapPseudofunctor_comp {P : Type u} [Mul P] [One P] (f : M → N) (g : N → P) (a : M) :
    (mapPseudofunctor (g ∘ f)).map (cell a)
      = (mapPseudofunctor g).map ((mapPseudofunctor f).map (cell a)) := rfl

/-- A *multiplicative* map induces a pseudofunctor which is strictly compatible with horizontal
composition; the general `mapPseudofunctor` is only compatible up to the (invertible) `mapComp`
2-cell. -/
theorem mapPseudofunctor_strict_comp (f : M → N) (hf : ∀ a b : M, f (a * b) = f a * f b)
    (a b : M) :
    (mapPseudofunctor f).map (cell a ≫ cell b)
      = (mapPseudofunctor f).map (cell a) ≫ (mapPseudofunctor f).map (cell b) :=
  Codiscrete.ext (hf a b)

/-- Conversely, if the induced pseudofunctor is strictly multiplicative on 1-cells, the map is
a magma homomorphism: strict compatibility is *not* automatic. -/
theorem multiplicative_of_strict_comp (f : M → N)
    (h : ∀ a b : M, (mapPseudofunctor f).map (cell a ≫ cell b)
      = (mapPseudofunctor f).map (cell a) ≫ (mapPseudofunctor f).map (cell b)) :
    ∀ a b : M, f (a * b) = f a * f b :=
  fun a b => congrArg Codiscrete.as (h a b)

/-- **Round trips are invisible to the 2-cell layer.**  For arbitrary maps `g : M → N` and
`h : N → M`, the round trip `mapPseudofunctor h ∘ mapPseudofunctor g` sends every 1-cell to a
1-cell canonically isomorphic to it. -/
theorem roundTrip_iso (g : M → N) (h : N → M) (f : star M ⟶ star M) :
    Nonempty ((mapPseudofunctor h).map ((mapPseudofunctor g).map f) ≅ f) :=
  ⟨codIso _ _⟩

/-- ... but the round trip is an *equality* of 1-cells only where `h ∘ g` fixes the element:
the collapse is genuinely only up to invertible 2-cells. -/
theorem roundTrip_eq_iff (g : M → N) (h : N → M) (a : M) :
    (mapPseudofunctor h).map ((mapPseudofunctor g).map (cell a)) = cell a ↔ h (g a) = a :=
  ⟨fun hh => congrArg Codiscrete.as hh, fun hh => congrArg cell hh⟩

end Functoriality

/-! ### Collapse onto the terminal codiscrete bicategory -/

section Collapse

/-- The pseudofunctor collapsing `MagmaBicat M` onto the one-point magma. -/
def toTerminal : Pseudofunctor (MagmaBicat M) (MagmaBicat PUnit) :=
  mapPseudofunctor fun _ => PUnit.unit

/-- The pseudofunctor picking out the identity 1-cell of `MagmaBicat M`. -/
def fromTerminal : Pseudofunctor (MagmaBicat PUnit) (MagmaBicat M) :=
  mapPseudofunctor fun _ => (1 : M)

/-- **Every codiscrete magma bicategory collapses.**  Composing the two pseudofunctors above
returns, up to an invertible 2-cell, the 1-cell one started with: at the level of
2-isomorphism classes the construction retains no information about `M` at all. -/
theorem collapse_iso (f : star M ⟶ star M) :
    Nonempty ((fromTerminal (M := M)).map ((toTerminal (M := M)).map f) ≅ f) :=
  ⟨codIso _ _⟩

/-- The collapse is not an equality unless the 1-cell is the identity: the *strict* 1-cell layer
still separates the elements of `M`.  Together with `collapse_iso` this delimits exactly how much
the codiscrete construction forgets. -/
theorem collapse_eq_iff (a : M) :
    (fromTerminal (M := M)).map ((toTerminal (M := M)).map (cell a)) = cell a ↔ a = 1 :=
  ⟨fun hh => (congrArg Codiscrete.as hh).symm, fun hh => congrArg cell hh.symm⟩

end Collapse

end CodiscreteMagma