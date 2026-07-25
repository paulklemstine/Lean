import Mathlib

/-!
# Abstract contraction calculus for crystal skeletons

This file isolates two pieces of finite combinatorics used when a crystal is first
contracted into quasicrystals, then into quasicrystal-skeleton components, and
finally into a Bruhat-order skeleton.

* `contract` records the edges visible after identifying vertices by a map.
* `fiberCharacter` adds vertex weights over each contracted component.

The principal results say that iterated edge contraction is exactly direct
contraction, and that characters satisfy the corresponding fiberwise
associativity formula.  Thus a multi-stage skeleton construction neither loses
edges nor changes the total character.
-/

namespace CrystalSkeleton

section Relations

variable {V Q S T : Type*}

/-- The directed edge relation induced after identifying vertices via `q`. -/
def contract (E : V → V → Prop) (q : V → Q) : Q → Q → Prop :=
  fun a b => ∃ x y, q x = a ∧ q y = b ∧ E x y

/-
Contracting in two stages gives exactly the same edge relation as contracting
by the composite map.
-/
theorem contract_comp (E : V → V → Prop) (q : V → Q) (r : Q → S) :
    contract (contract E q) r = contract E (r ∘ q) := by
  ext a b;
  constructor;
  · rintro ⟨ x, y, hx, hy, ⟨ u, v, hu, hv, h ⟩ ⟩ ; exact ⟨ u, v, by aesop ⟩;
  · exact fun ⟨ x, y, hx, hy, hxy ⟩ => ⟨ q x, q y, hx, hy, x, y, rfl, rfl, hxy ⟩

/-
Three successive contractions are independent of parenthesization.
-/
theorem contract_comp_three (E : V → V → Prop) (q : V → Q)
    (r : Q → S) (t : S → T) :
    contract (contract (contract E q) r) t = contract E (t ∘ r ∘ q) := by
  rw [ contract_comp, contract_comp ] ; aesop;

/-
Every original edge is visible as an edge (possibly a loop) in the
contracted skeleton.
-/
theorem edge_maps_to_contract (E : V → V → Prop) (q : V → Q)
    {x y : V} (h : E x y) : contract E q (q x) (q y) := by
  exact ⟨ x, y, rfl, rfl, h ⟩

/-
A directed path in the original graph maps to a directed path in the
contracted graph.
-/
theorem path_maps_to_contract (E : V → V → Prop) (q : V → Q)
    {x y : V} (h : Relation.ReflTransGen E x y) :
    Relation.ReflTransGen (contract E q) (q x) (q y) := by
  induction h;
  · rfl;
  · exact .tail ‹_› ( edge_maps_to_contract _ _ ‹_› )

end Relations

section Characters

variable {V Q S T A : Type*} [Fintype V] [Fintype Q] [Fintype S]
  [Fintype T] [DecidableEq Q] [DecidableEq S] [DecidableEq T]
  [AddCommMonoid A]

/-- Character of the fiber over a contracted vertex: the sum of the weights of
all original vertices represented by it. -/
def fiberCharacter (q : V → Q) (w : V → A) (a : Q) : A :=
  ∑ x : V, if q x = a then w x else 0

/-
The total character is the sum of the characters of all contracted
vertices.  No surjectivity assumption is needed: empty fibers contribute zero.
-/
theorem sum_fiberCharacter (q : V → Q) (w : V → A) :
    ∑ a : Q, fiberCharacter q w a = ∑ x : V, w x := by
  unfold fiberCharacter; rw [ Finset.sum_comm ] ; simp +decide ;

/-
Character formation is associative along nested contractions.  The weight
of a second-stage component is the sum of the weights of its first-stage
components.
-/
omit [Fintype S] in
theorem fiberCharacter_comp (q : V → Q) (r : Q → S) (w : V → A) (b : S) :
    fiberCharacter (r ∘ q) w b =
      fiberCharacter r (fiberCharacter q w) b := by
  unfold fiberCharacter;
  simp +decide [ Finset.sum_ite, Function.comp ];
  simp +decide only [Finset.sum_sigma'];
  refine' Finset.sum_bij ( fun x hx => ⟨ q x, x ⟩ ) _ _ _ _ <;> aesop

/-
The explicit three-level formula underlying the passage from crystal
vertices through quasicrystals and quasicrystal skeletons to a final skeleton.
-/
omit [Fintype T] in
theorem fiberCharacter_comp_three (q : V → Q) (r : Q → S) (t : S → T)
    (w : V → A) (c : T) :
    fiberCharacter (t ∘ r ∘ q) w c =
      fiberCharacter t (fiberCharacter r (fiberCharacter q w)) c := by
  convert fiberCharacter_comp ( r ∘ q ) t w c using 2;
  exact funext fun x => Eq.symm ( fiberCharacter_comp q r w x )

/-
Summing at any intermediate contraction level gives the same global
character.
-/
omit [Fintype Q] [Fintype S] [DecidableEq Q] [DecidableEq S] in
theorem total_character_three_levels (q : V → Q) (r : Q → S) (t : S → T)
    (w : V → A) :
    ∑ c : T, fiberCharacter (t ∘ r ∘ q) w c = ∑ x : V, w x := by
  convert sum_fiberCharacter ( t ∘ r ∘ q ) w using 1

end Characters

end CrystalSkeleton