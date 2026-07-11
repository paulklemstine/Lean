import Mathlib
import CausalLoops.ParenTree

/-!
# Strictification: collapsing the loops

The parenthesization category `PTree α` of `CausalLoops.ParenTree` is a genuinely
non-strict monoidal category: `(a ⊗ b) ⊗ c` and `a ⊗ (b ⊗ c)` are *distinct objects*
linked by the associator.  This file shows what "coherence" buys us: the whole tower of
loops **collapses**.

## Main results

* `PTree.ofList` — the canonical right-nested tree of a leaf-word (a *normal form* for
  bracketings).
* `PTree.normalize` — every tree is canonically isomorphic to its normal form; all
  bracketings of a word are uniquely isomorphic (Mac Lane coherence, concrete form).
* `PTree.iso_iff` — two trees are isomorphic **iff** they have the same leaf-word: the
  isomorphism class of a bracketing remembers only the underlying word.
* `PTree.flattenFunctor` — the strictification functor collapsing every bracketing to its
  word.
* `PTree.flattenFunctor_map_associator` — the associator maps to (an) identity: the loop
  is contracted by strictification.
* `PTree.strictify` — **the parenthesization category is equivalent to the discrete
  category `Discrete (List α)`**, i.e. to the strict skeleton.  A non-strict monoidal
  structure is, up to equivalence, a strict one: the "higher" data is coherent and hence
  removable.
-/

open CategoryTheory MonoidalCategory CausalLoops

namespace CausalLoops.PTree

variable {α : Type*}

/-- The canonical **right-nested** tree of a leaf-word:
`ofList [a,b,c] = a ⊗ (b ⊗ (c ⊗ nil))` after a fashion.  This is a chosen normal form
for the reassociation classes of bracketings. -/
def ofList : List α → PTree α
  | [] => nil
  | a :: rest => node (leaf a) (ofList rest)

@[simp] theorem flatten_ofList (l : List α) : flatten (ofList l) = l := by
  induction l with
  | nil => rfl
  | cons a rest ih => simp [ofList, ih]

/-- **Every tree is canonically isomorphic to its normal form.**  In particular *all*
bracketings of a fixed word are canonically (and uniquely) isomorphic — this is Mac
Lane's coherence theorem in the concrete, thin case. -/
def normalize (s : PTree α) : s ≅ ofList (flatten s) :=
  isoOfEq (by simp)

/-- Two bracketings are isomorphic exactly when they have the same underlying leaf-word:
the isomorphism class remembers only the word, not how it is parenthesized. -/
theorem iso_iff (s t : PTree α) : Nonempty (s ≅ t) ↔ flatten s = flatten t := by
  constructor
  · rintro ⟨e⟩; exact e.hom.down
  · intro h; exact ⟨isoOfEq h⟩

/-- **The strictification functor.**  It sends a bracketing to its underlying leaf-word,
collapsing every reassociation to an equality in the discrete category. -/
def flattenFunctor : PTree α ⥤ Discrete (List α) where
  obj s := ⟨flatten s⟩
  map f := Discrete.eqToHom f.down
  map_id := by intros; apply Subsingleton.elim
  map_comp := by intros; apply Subsingleton.elim

@[simp] theorem flattenFunctor_obj (s : PTree α) :
    (flattenFunctor.obj s : Discrete (List α)).as = flatten s := rfl

/-- **The loop is contracted.**  Under strictification, the associator — the invertible
`2`-cell repairing the on-the-nose failure of associativity — becomes an identity-type
morphism in the discrete target.  "When composition loops back, strictification unbends
the loop." -/
theorem flattenFunctor_map_associator (a b c : PTree α) :
    (flattenFunctor (α := α)).map (α_ a b c).hom =
      eqToHom (by apply Discrete.ext; simp [flattenFunctor, List.append_assoc]) :=
  Subsingleton.elim _ _

/-- The inverse to strictification: realise a word as its normal-form bracketing. -/
def unnormalize : Discrete (List α) ⥤ PTree α :=
  Discrete.functor ofList

/-- **The parenthesization category is equivalent to its strict skeleton.**

`PTree α ≌ Discrete (List α)`: the entire non-strict monoidal structure — objects for
every bracketing, an associator loop connecting them — is, up to equivalence, the strict
discrete category on leaf-words.  This is the payoff of coherence: a *coherent*
loop-tolerant structure is equivalent to a strict (loop-free) one. -/
def strictify : PTree α ≌ Discrete (List α) where
  functor := flattenFunctor
  inverse := unnormalize
  unitIso := NatIso.ofComponents
    (fun _ => isoOfEq (by simp [flattenFunctor, unnormalize, Discrete.functor]))
    (by intros; apply Subsingleton.elim)
  counitIso := NatIso.ofComponents
    (fun d => Discrete.eqToIso (by
      obtain ⟨l⟩ := d
      simp [flattenFunctor, unnormalize, Discrete.functor]))
    (by intros; apply Subsingleton.elim)
  functor_unitIso_comp := by intros; apply Subsingleton.elim

end CausalLoops.PTree