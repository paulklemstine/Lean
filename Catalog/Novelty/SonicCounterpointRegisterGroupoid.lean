import Novelty.SonicCounterpointGapThreshold

/-!
# Categorical shape of the canonical counterpoint preorder

`Novelty.SonicCounterpointConnectivity` shows that the reflexive-transitive
closure of `CanonicalMotion` is the kernel of the register map, hence an
equivalence relation.  This file draws the categorical consequences for the
thin category the catalog file generates.

* The generated thin category on the seven canonical states is a **groupoid**:
  every morphism is invertible, because reachability is symmetric.
* It is **not** a partial order: the two thirds are distinct yet mutually
  reachable, so antisymmetry fails and the thin category is not skeletal.
* Its **skeleton has exactly four objects**: the quotient by mutual
  reachability is explicitly isomorphic to `Fin 4` through the register map,
  and the induced order on the quotient is equality.  So the seven-object model
  collapses to a four-object *discrete* category — the strongest possible
  failure of strong connectivity short of the discrete seven-object category.
-/

namespace SonicCounterpoint

/-- Reachability among canonical states is symmetric, so the generated thin
category is a groupoid. -/
theorem canonicalReachable_symm {i j : SimpleConsonance} (h : CanonicalReachable i j) :
    CanonicalReachable j i :=
  (canonicalReachable_iff_register j i).2 ((canonicalReachable_iff_register i j).1 h).symm

/-- Mutual reachability of canonical states. -/
def canonicalSetoid : Setoid SimpleConsonance where
  r := CanonicalReachable
  iseqv :=
    { refl := fun _ => Relation.ReflTransGen.refl
      symm := canonicalReachable_symm
      trans := Relation.ReflTransGen.trans }

instance canonicalSetoidDecidableRel :
    DecidableRel (α := SimpleConsonance) canonicalSetoid.r :=
  canonicalReachableDecidable

/-- Antisymmetry fails: the thirds are distinct but mutually reachable, so the
generated preorder is strictly weaker than a partial order. -/
theorem canonicalReachable_not_antisymm :
    ∃ i j : SimpleConsonance,
      i ≠ j ∧ CanonicalReachable i j ∧ CanonicalReachable j i :=
  ⟨.minorThird, .majorThird, by decide, by decide, by decide⟩

/-- A canonical representative of each register. -/
def registerRep : Fin 4 → SimpleConsonance
  | 0 => .unison
  | 1 => .minorThird
  | 2 => .perfectFifth
  | 3 => .octave

instance canonicalQuotientFintype : Fintype (Quotient canonicalSetoid) :=
  @Quotient.fintype _ _ canonicalSetoid (fun a b => canonicalReachableDecidable a b)

/-- The representative map is a section of `register`. -/
theorem register_registerRep (k : Fin 4) : register (registerRep k) = k := by
  revert k; decide

theorem registerRep_register (i : SimpleConsonance) :
    CanonicalReachable (registerRep (register i)) i := by
  revert i; decide

/-- **Skeleton of the generated category.** The quotient by mutual reachability
is isomorphic to `Fin 4`, the set of registers. -/
def registerQuotientEquiv : Quotient canonicalSetoid ≃ Fin 4 where
  toFun := Quotient.lift register fun a b h => (canonicalReachable_iff_register a b).1 h
  invFun k := Quotient.mk canonicalSetoid (registerRep k)
  left_inv := by
    intro x
    induction x using Quotient.inductionOn with
    | _ i => exact Quotient.sound (registerRep_register i)
  right_inv := register_registerRep

/-- The skeleton has exactly four objects: seven states, four registers. -/
theorem register_quotient_card : Fintype.card (Quotient canonicalSetoid) = 4 := by
  rw [Fintype.card_congr registerQuotientEquiv, Fintype.card_fin]

/-- Seven states collapse strictly: the quotient is smaller than the state set. -/
theorem register_quotient_card_lt :
    Fintype.card (Quotient canonicalSetoid) < Fintype.card SimpleConsonance := by
  rw [register_quotient_card, simpleConsonance_card]
  omega

/-- Strong connectivity would mean a one-object skeleton, which is false. -/
theorem register_quotient_card_ne_one :
    Fintype.card (Quotient canonicalSetoid) ≠ 1 := by
  rw [register_quotient_card]
  omega

/-- The order induced on the skeleton is equality: after collapsing mutually
reachable states, no nontrivial morphism survives, so the skeleton is the
*discrete* four-object category. -/
theorem quotient_order_discrete (x y : Quotient canonicalSetoid)
    (h : ∀ i j : SimpleConsonance,
      Quotient.mk canonicalSetoid i = x → Quotient.mk canonicalSetoid j = y →
        CanonicalReachable i j) : x = y := by
  induction x using Quotient.inductionOn with
  | _ i =>
    induction y using Quotient.inductionOn with
    | _ j => exact Quotient.sound (h i j rfl rfl)

/-- Between distinct registers there are no morphisms whatsoever. -/
theorem no_morphisms_between_registers (i j : SimpleConsonance)
    (h : register i ≠ register j) : ¬ CanonicalReachable i j := by
  rw [canonicalReachable_iff_register]
  exact h

/-- **Summary of the categorical collapse.** The generated thin category on the
seven canonical states is a groupoid whose skeleton is discrete with four
objects, and which therefore fails strong connectivity. -/
theorem canonical_category_shape :
    (∀ i j : SimpleConsonance, CanonicalReachable i j → CanonicalReachable j i) ∧
      Fintype.card (Quotient canonicalSetoid) = 4 ∧
      ¬ ∀ i j : SimpleConsonance, CanonicalReachable i j :=
  ⟨fun _ _ h => canonicalReachable_symm h, register_quotient_card,
    canonical_strong_connectivity_refuted⟩

end SonicCounterpoint