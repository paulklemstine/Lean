import Mathlib

/-!
# Certified small activation-pattern calculations

These self-contained examples expose the key correction to the naive `2^k`
claim. Two gates can realize all four patterns, but two perfectly correlated
gates realize only two feasible patterns.
-/

open Function Set

namespace ActivationStoneExamples

abbrev Pattern (k : ℕ) := Fin k → Bool
def Feasible {X : Type*} {k : ℕ} (a : X → Pattern k) := Set.range a

/-- Two independent gates, with the pattern itself as input. -/
def independentTwo : Pattern 2 → Pattern 2 := id

/-- Two duplicated gates: both copy the same Boolean input. -/
def duplicatedTwo (b : Bool) : Pattern 2 := fun _ => b

/-
Independent two-gate activations realize all four formal patterns.
-/
theorem independentTwo_feasible_card :
    Fintype.card (Feasible independentTwo) = 4 := by
  -- The range of the independentTwo function is the set of all possible patterns of length 2, which has cardinality $2^2 = 4$.
  have h_range : Feasible independentTwo = Set.univ := by
    exact Set.eq_univ_of_forall fun x => ⟨ x, rfl ⟩;
  aesop

/-
Duplicated gates realize only the all-false and all-true patterns.
-/
theorem duplicatedTwo_feasible_card :
    Fintype.card (Feasible duplicatedTwo) = 2 := by
  convert Set.toFinset_card ( Set.range duplicatedTwo );
  rw [ Set.toFinset_card ];
  convert rfl

/-
Thus the unconditional assertion that two gates always yield four Stone
points is false.
-/
theorem two_gates_not_always_four :
    ∃ (X : Type) (_ : Fintype X) (a : X → Pattern 2),
      Fintype.card (Feasible a) ≠ 4 := by
  use PUnit-- 1-element set;
  use inferInstance;
  by_contra! h0;
  specialize h0 ( fun _ => fun _ => Bool.true ) ; simp +decide [ Feasible ] at h0;

/-
For zero gates there is one formal pattern and every nonempty input type
realizes it.
-/
theorem zero_gate_feasible_card {X : Type*} [Fintype X] [Nonempty X]
    (a : X → Pattern 0) : Fintype.card (Feasible a) = 1 := by
  rw [ Fintype.card_eq_one_iff ];
  simp +decide [ Feasible ];
  exact ⟨ Classical.arbitrary X, fun x hx => by ext i; fin_cases i ⟩

end ActivationStoneExamples