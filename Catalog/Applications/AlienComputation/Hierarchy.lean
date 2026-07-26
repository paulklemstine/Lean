import Mathlib

/-!
# A universal, substrate-independent complexity hierarchy

**Research theme: Computational Complexity of Alien Civilizations.**

The diagonal argument (`Lawvere.lean`, `Uncomputability.lean`) shows that the
space of decision behaviours on a type is strictly richer than the type itself.
Iterating this one step at a time produces an **infinite strictly increasing
tower** of "decision-power levels":

`Level 0 = A`,  `Level (n+1) = Level n → Bool`.

Each level is the set of Boolean decision procedures over the previous one — the
"problems about problems about … about `A`".  We prove:

* there is a canonical **embedding** of each level into the next
  (`Hierarchy.embeds`), so power never decreases; and
* there is **no surjection** from a level onto the next
  (`Hierarchy.no_surjection`), so power strictly increases at every step
  (`Hierarchy.strict_step`); equivalently the **cardinalities strictly
  increase** (`Hierarchy.mk_lt`).

Because the construction and both proofs are pure function theory — no machine
model, no physics — this hierarchy is forced on *every* civilization: it is a
universal complexity hierarchy.  In particular there is **no maximal level**
(`Hierarchy.no_maximal`): whatever decision-power a civilization attains, a
strictly greater level provably exists.
-/

namespace AlienComputation
namespace Hierarchy

universe u

variable (A : Type u)

/-- The tower of decision-power levels over a base type `A`:
`Level 0 = A` and `Level (n+1) = (Level n → Bool)`, the decision procedures over
level `n`. -/
def Level : ℕ → Type u
  | 0 => A
  | n + 1 => Level n → Bool

@[simp] theorem Level_zero : Level A 0 = A := rfl
@[simp] theorem Level_succ (n : ℕ) : Level A (n + 1) = (Level A n → Bool) := rfl

/-- Boolean negation is fixed-point free (the only substrate input to the
diagonal argument). -/
theorem bool_ne_not (b : Bool) : b ≠ !b := by cases b <;> decide

/-- **Cantor step, negative half.**  No map from a type onto its space of Boolean
decision procedures is surjective. -/
theorem cantor_bool {X : Type u} (φ : X → (X → Bool)) : ¬ Function.Surjective φ := by
  intro hsurj
  obtain ⟨x, hx⟩ := hsurj (fun y => !(φ y y))
  have h : φ x x = !(φ x x) := congrFun hx x
  exact bool_ne_not _ h

/-- **Cantor step, positive half.**  The indicator map `a ↦ (· = a)` embeds a
type into its space of Boolean decision procedures. -/
theorem embeds_bool (X : Type u) : ∃ f : X → (X → Bool), Function.Injective f := by
  classical
  refine ⟨fun a x => decide (x = a), ?_⟩
  intro a b h
  have : (decide (b = a) : Bool) = decide (b = b) := congrFun h b
  have hba : b = a := by simpa using this
  exact hba.symm

/-- **No surjection between consecutive levels.**  Decision-power strictly
increases: level `n+1` cannot be exhausted by any map out of level `n`. -/
theorem no_surjection (n : ℕ) (φ : Level A n → Level A (n + 1)) :
    ¬ Function.Surjective φ :=
  cantor_bool φ

/-- **Embedding between consecutive levels.**  Level `n` injects into level
`n+1`; decision-power never decreases. -/
theorem embeds (n : ℕ) : ∃ f : Level A n → Level A (n + 1), Function.Injective f :=
  embeds_bool (Level A n)

/-- **Strict step of the universal hierarchy.**  At every level there is an
injection into the next but no surjection onto it — a strict increase in
decision-power, forced with no hypotheses on `A`. -/
theorem strict_step (n : ℕ) :
    (∃ f : Level A n → Level A (n + 1), Function.Injective f) ∧
      (∀ φ : Level A n → Level A (n + 1), ¬ Function.Surjective φ) :=
  ⟨embeds A n, no_surjection A n⟩

/-- **Cardinal form of the strict step.**  The cardinality of each level is
strictly smaller than that of the next. -/
theorem mk_lt (n : ℕ) : Cardinal.mk (Level A n) < Cardinal.mk (Level A (n + 1)) := by
  have h1 : Cardinal.mk (Level A (n + 1)) = 2 ^ Cardinal.mk (Level A n) := by
    rw [Level_succ, Cardinal.mk_arrow]; simp
  rw [h1]; exact Cardinal.cantor _

/-- **The hierarchy is unbounded below in cardinality across all levels.**  For
any two levels `m < n`, level `m` is strictly smaller than level `n`. -/
theorem mk_strictMono : StrictMono (fun n => Cardinal.mk (Level A n)) :=
  strictMono_nat_of_lt_succ (mk_lt A)

/-- **No maximal level.**  Whatever decision-power (level `n`) a civilization
attains, a strictly greater level `n+1` provably exists: it admits `Level n` as a
sub-power but is not itself reachable from `Level n`.  The universal complexity
hierarchy has no top. -/
theorem no_maximal (n : ℕ) :
    ∃ m : ℕ, n < m ∧ Cardinal.mk (Level A n) < Cardinal.mk (Level A m) :=
  ⟨n + 1, Nat.lt_succ_self n, mk_lt A n⟩

end Hierarchy
end AlienComputation