import Mathlib

/-! # Basic monotone circuit complexity -/

namespace CircuitComplexity

/-- Monotone Boolean circuits with variables, constants, conjunction, and disjunction. -/
inductive MCircuit (ι : Type*) where
  | var (i : ι)
  | top
  | bot
  | and (left right : MCircuit ι)
  | or (left right : MCircuit ι)

namespace MCircuit

variable {ι : Type*}

/-- Evaluation of a monotone circuit. -/
def eval : MCircuit ι → (ι → Bool) → Bool
  | var i, x => x i
  | top, _ => true
  | bot, _ => false
  | and a b, x => a.eval x && b.eval x
  | or a b, x => a.eval x || b.eval x

/-- Circuit size, counting every node. -/
def size : MCircuit ι → ℕ
  | var _ => 1
  | top => 1
  | bot => 1
  | and a b => a.size + b.size + 1
  | or a b => a.size + b.size + 1

/-- Circuit depth. -/
def depth : MCircuit ι → ℕ
  | var _ => 0
  | top => 0
  | bot => 0
  | and a b => max a.depth b.depth + 1
  | or a b => max a.depth b.depth + 1

/-- A Boolean function depends on a variable if flipping that variable can change its value. -/
def DependsOn [DecidableEq ι] (f : (ι → Bool) → Bool) (i : ι) : Prop :=
  ∃ x, f (Function.update x i false) ≠ f (Function.update x i true)

/-- The finite set of variables occurring in a circuit. -/
def vars [DecidableEq ι] : MCircuit ι → Finset ι
  | var i => {i}
  | top => ∅
  | bot => ∅
  | and a b => a.vars ∪ b.vars
  | or a b => a.vars ∪ b.vars

/-- Updating a variable absent from a circuit cannot change its evaluation. -/
theorem eval_update_eq_of_not_mem [DecidableEq ι] (C : MCircuit ι) (x : ι → Bool)
    {i : ι} (hi : i ∉ C.vars) (b : Bool) : C.eval (Function.update x i b) = C.eval x := by
  induction C with
  | var j =>
      simp only [vars, Finset.mem_singleton] at hi
      simp [eval, Function.update, Ne.symm hi]
  | top => rfl
  | bot => rfl
  | and a c iha ihc =>
      simp only [vars, Finset.mem_union, not_or] at hi
      simp only [eval, iha hi.1, ihc hi.2]
  | or a c iha ihc =>
      simp only [vars, Finset.mem_union, not_or] at hi
      simp only [eval, iha hi.1, ihc hi.2]

/-- Every relevant variable occurs syntactically in the circuit. -/
theorem mem_vars_of_dependsOn [DecidableEq ι] (C : MCircuit ι) (i : ι)
    (h : DependsOn C.eval i) : i ∈ C.vars := by
  by_contra hi
  obtain ⟨x, hx⟩ := h
  apply hx
  rw [eval_update_eq_of_not_mem C x hi false, eval_update_eq_of_not_mem C x hi true]

/-- The number of distinct variables in a circuit is at most its size. -/
theorem card_vars_le_size [DecidableEq ι] (C : MCircuit ι) : C.vars.card ≤ C.size := by
  induction C with
  | var i => simp [vars, size]
  | top => simp [vars, size]
  | bot => simp [vars, size]
  | and a b iha ihb =>
      simp only [vars, size]
      calc
        (a.vars ∪ b.vars).card ≤ a.vars.card + b.vars.card := Finset.card_union_le _ _
        _ ≤ a.size + b.size := Nat.add_le_add iha ihb
        _ ≤ a.size + b.size + 1 := Nat.le_succ _
  | or a b iha ihb =>
      simp only [vars, size]
      calc
        (a.vars ∪ b.vars).card ≤ a.vars.card + b.vars.card := Finset.card_union_le _ _
        _ ≤ a.size + b.size := Nat.add_le_add iha ihb
        _ ≤ a.size + b.size + 1 := Nat.le_succ _

/-- A circuit computing `f` must contain every variable on which `f` depends. -/
theorem card_le_size_of_relevant [Fintype ι] [DecidableEq ι]
    (C : MCircuit ι) (f : (ι → Bool) → Bool)
    (hC : ∀ x, C.eval x = f x)
    (S : Finset ι) (hS : ∀ i ∈ S, DependsOn f i) : S.card ≤ C.size := by
  calc
    S.card ≤ C.vars.card := Finset.card_le_card (by
      intro i hi
      apply mem_vars_of_dependsOn C i
      obtain ⟨x, hx⟩ := hS i hi
      exact ⟨x, by simpa only [hC] using hx⟩)
    _ ≤ C.size := card_vars_le_size C

end MCircuit
end CircuitComplexity