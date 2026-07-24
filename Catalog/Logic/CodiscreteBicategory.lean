import Mathlib
import Pythagorean.CausalLoops.NonStrictBicategory

/-!
# Codiscrete one-object bicategories from unital magmas

The concrete example in `NonStrictBicategory` builds a genuinely non-strict bicategory from
one hand-picked nonassociative unital multiplication on the natural numbers.  This file packages
that construction for **every** unital magma at once, and pins down exactly when the resulting
bicategory is strict.

Given any type `M` equipped with a unital multiplication (`MulOneClass M`), we form the
one-object bicategory `Obj M` whose:

* single object is `star`;
* 1-cells `star ⟶ star` are the elements of `M`, composed by multiplication with identity `1`;
* 2-cells form a *codiscrete* category: exactly one 2-cell between any two parallel 1-cells.

Because every hom-category is codiscrete, all coherence diagrams commute automatically, so the
data always assembles into a bicategory — regardless of whether `M` is associative.  The unit and
associativity *defects* of `M` are absorbed into invertible 2-cells (the unitors and associator).

The main structural result, `strict_iff_associative`, characterises strictness: the codiscrete
bicategory on `M` admits a `Bicategory.Strict` structure **iff** the multiplication on `M` is
associative.  This exhibits the associator as a genuine obstruction, and recovers the concrete
`no_strict_structure` theorem as a special case.
-/

namespace CausalLoops.Codiscrete

open CategoryTheory
open CategoryTheory.Bicategory

universe u

/-- The 1-cells: a thin wrapper around the carrier of the magma.  The wrapper lets us install a
codiscrete hom-category on the 1-cells without imposing any instances on `M` itself. -/
@[ext]
structure Cell (M : Type u) where
  /-- The underlying magma element. -/
  val : M

/-- Between any two 1-cells there is exactly one 2-cell. -/
instance quiverCell (M : Type u) : Quiver (Cell M) where
  Hom _ _ := PUnit

/-- The codiscrete hom-category on 1-cells: a unique 2-cell between every parallel pair. -/
instance codiscreteCategory (M : Type u) : Category (Cell M) where
  id _ := PUnit.unit
  comp _ _ := PUnit.unit
  id_comp _ := rfl
  comp_id _ := rfl
  assoc _ _ _ := rfl

/-- The single object of the bicategory. -/
inductive Obj (M : Type u)
  | star

open Obj

variable {M : Type u} [MulOneClass M]

/-- 1-cell composition is magma multiplication; the identity 1-cell is the unit. -/
instance categoryStruct : CategoryStruct (Obj M) where
  Hom _ _ := Cell M
  id _ := ⟨1⟩
  comp f g := ⟨f.val * g.val⟩

@[simp] theorem id_val (a : Obj M) : (𝟙 a : Cell M).val = 1 := rfl

@[simp] theorem comp_val {a b c : Obj M} (f : a ⟶ b) (g : b ⟶ c) :
    (f ≫ g).val = f.val * g.val := rfl

/-- The unique isomorphism between any two 1-cells, from codiscreteness. -/
def uniqueIso (f g : Cell M) : f ≅ g where
  hom := PUnit.unit
  inv := PUnit.unit

/-- Any two parallel 2-cells coincide: the hom-categories are codiscrete. -/
theorem subsingleton_two_cells {N : Type u} {f g : Cell N} (η θ : f ⟶ g) : η = θ := rfl

/-- Any two isomorphisms between the same 1-cells coincide. -/
theorem subsingleton_iso {N : Type u} {f g : Cell N} (α β : f ≅ g) : α = β := by
  apply Iso.ext
  rfl

/-- The codiscrete one-object bicategory attached to a unital magma `M`.  All coherence
laws hold automatically because parallel 2-cells are equal. -/
instance bicategory : Bicategory (Obj M) where
  homCategory _ _ := codiscreteCategory M
  whiskerLeft := fun {_ _ _} _ {_ _} _ => PUnit.unit
  whiskerRight := fun {_ _ _} {_ _} _ _ => PUnit.unit
  associator _ _ _ := uniqueIso _ _
  leftUnitor _ := uniqueIso _ _
  rightUnitor _ := uniqueIso _ _
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

/-- **If `M` is associative, the codiscrete bicategory is strict.**  The unit laws hold
definitionally from `MulOneClass`, associativity of 1-cells is the hypothesis, and the
unitor/associator coherence conditions are automatic from codiscreteness. -/
def strictOfAssoc (h : ∀ a b c : M, a * b * c = a * (b * c)) :
    Bicategory.Strict (Obj M) where
  id_comp f := by
    apply Cell.ext
    show (1 : M) * f.val = f.val
    exact one_mul _
  comp_id f := by
    apply Cell.ext
    show f.val * (1 : M) = f.val
    exact mul_one _
  assoc f g h' := by
    apply Cell.ext
    show (f.val * g.val) * h'.val = f.val * (g.val * h'.val)
    exact h f.val g.val h'.val
  leftUnitor_eqToIso f := subsingleton_iso _ _
  rightUnitor_eqToIso f := subsingleton_iso _ _
  associator_eqToIso f g h' := subsingleton_iso _ _

/-- **Conversely, strictness forces associativity of the magma.**  A `Bicategory.Strict`
structure supplies an equality of 1-cell composites, whose underlying magma equation is
precisely associativity. -/
theorem assoc_of_strict (s : Bicategory.Strict (Obj M)) :
    ∀ a b c : M, a * b * c = a * (b * c) := by
  intro a b c
  have := s.assoc (a := star) (b := star) (c := star) (d := star)
    ⟨a⟩ ⟨b⟩ ⟨c⟩
  have hv := congrArg Cell.val this
  exact hv

/-- **Strictness characterisation.**  The codiscrete one-object bicategory on a unital magma
`M` admits a strict structure exactly when `M` is associative. -/
theorem strict_iff_associative :
    Nonempty (Bicategory.Strict (Obj M)) ↔ (∀ a b c : M, a * b * c = a * (b * c)) := by
  constructor
  · rintro ⟨s⟩
    exact assoc_of_strict s
  · intro h
    exact ⟨strictOfAssoc h⟩

/-- Every monoid yields a strict codiscrete bicategory. -/
def strictOfMonoid {N : Type u} [Monoid N] : Bicategory.Strict (Obj N) :=
  strictOfAssoc (fun a b c => mul_assoc a b c)

end CausalLoops.Codiscrete

/-!
## Recovering the concrete example

We now feed the hand-picked nonassociative `twistedComp` from `NonStrictBicategory` into the
general machinery and recover the non-strictness result as a corollary.
-/

namespace CausalLoops.TwistedInstance

open CategoryTheory
open CausalLoops
open CausalLoops.Codiscrete

/-- The natural numbers under the twisted, nonassociative composition, as a unital magma. -/
def Twisted : Type := Nat

instance : MulOneClass Twisted where
  one := (0 : Nat)
  mul a b := twistedComp a b
  one_mul a := twistedComp_zero_left a
  mul_one a := twistedComp_zero_right a

/-- The twisted magma is not associative (witnessed at `1, 1, 1`). -/
theorem twisted_not_assoc :
    ¬ (∀ a b c : Twisted, a * b * c = a * (b * c)) := by
  intro h
  exact twistedComp_not_associative (h (1 : Nat) (1 : Nat) (1 : Nat))

/-- **The codiscrete bicategory on the twisted magma is genuinely non-strict.**  This is the
general `strict_iff_associative` specialised to the concrete nonassociative example. -/
theorem twisted_no_strict_structure :
    ¬ Nonempty (Bicategory.Strict (Obj Twisted)) := by
  rw [strict_iff_associative]
  exact twisted_not_assoc

end CausalLoops.TwistedInstance

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  The concrete non-strict bicategory built from one hand-picked nonassociative
multiplication on the natural numbers is not an accident of that multiplication.  We conjectured
that *every* unital magma `M` (any `MulOneClass`) gives rise to a one-object bicategory via a
codiscrete hom-category, and that strictness of the resulting bicategory is governed exactly by
associativity of `M` — turning the associator into a sharp obstruction rather than a coincidence.

**Experiment.**  We packaged the codiscrete construction generically: 1-cells are elements of
`M` (wrapped so as not to pollute `M` with instances), 2-cells are codiscrete, composition is
multiplication, and the identity is the unit.  Because parallel 2-cells are definitionally equal,
all coherence data (pentagon, triangle, unitors, interchange) is discharged uniformly.  We then
proved both implications of the strictness characterisation and specialised them to the twisted
multiplication of the original example.

**Analysis.**  The two directions of `strict_iff_associative` are genuinely different in flavour.
The forward direction (`assoc_of_strict`) *extracts* an equation: a strict structure hands us an
equality of 1-cell composites, whose underlying magma equation is associativity.  The backward
direction (`strictOfAssoc`) *builds* structure: unit laws come from `MulOneClass`, associativity
of composites is the hypothesis, and — crucially — the three `eqToIso` coherence conditions hold
for free precisely because the hom-categories are codiscrete (`subsingleton_iso`).  Thus
codiscreteness is what lets any associative magma be strictified without touching the 1-cells,
while the non-strictness of the twisted example is an honest failure of the magma equation.

**Critique.**  A subtle trap: strictness of a bicategory is *not* only about 1-cell
associativity; it also demands that the unitors and associator be `eqToIso`.  Had the hom
categories been anything richer than codiscrete, `strictOfAssoc` would have required extra
cocycle-type data and the iff could fail.  We guarded against triviality by anchoring to a
concretely nonassociative instance (`twisted_not_assoc`), so `twisted_no_strict_structure` is a
non-vacuous negative result, and by checking that every theorem depends only on the standard
foundational axioms.

**Synthesis.**  The upshot is a clean dichotomy for one-object codiscrete bicategories:
associativity of the underlying unital magma is equivalent to the existence of a strict structure
on the fixed composition.  The original hand-built example is recovered as the special case of a
nonassociative magma, and `strictOfMonoid` records that every monoid sits at the strict end of
the dichotomy.
-/