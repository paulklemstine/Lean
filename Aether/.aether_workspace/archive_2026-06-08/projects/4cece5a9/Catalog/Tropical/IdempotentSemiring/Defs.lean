/-
# Idempotent Semiring Framework for Abstract Tropical Dominance Elimination

This file establishes the algebraic foundation for tropical polynomial canonicalization
over arbitrary linearly ordered idempotent commutative monoids.

## Main results

* `IdempotentOrdAddCommMonoid` — the abstract algebraic class
* `IdempotentOrdAddCommMonoid.add_eq_max` — idempotent addition equals `max`
* `eval_remove_dominated` — one-step dominated monomial deletion preserves evaluation
* `eval_canon_eq_eval` — iterated canonicalization preserves polynomial semantics
* Max-plus, min-plus, and Boolean instances
-/

import Mathlib

set_option maxHeartbeats 800000

open scoped Classical

/-! ## The abstract algebraic class -/

/-- A linearly ordered idempotent commutative additive monoid where
addition is idempotent (`a + a = a`) and the order is characterized by
`a ≤ b ↔ a + b = b`. -/
class IdempotentOrdAddCommMonoid (R : Type*) extends
    LinearOrder R, AddCommMonoid R where
  add_idem : ∀ a : R, a + a = a
  le_iff_add : ∀ a b : R, a ≤ b ↔ a + b = b

namespace IdempotentOrdAddCommMonoid

variable {R : Type*} [IdempotentOrdAddCommMonoid R]

/-
In an idempotent ordered additive monoid, `a + b = max a b`.
-/
theorem add_eq_max (a b : R) : a + b = max a b := by
  cases' ‹IdempotentOrdAddCommMonoid R› with _ _ _ _ _ add_idem le_iff_add;
  cases le_total a b <;> simp_all +decide [ add_comm ]

/-- If `a ≤ b`, then `a + b = b`. -/
theorem add_of_le {a b : R} (h : a ≤ b) : a + b = b :=
  (le_iff_add a b).mp h

/-
`a ≤ a + b` always holds.
-/
theorem le_add_right' (a b : R) : a ≤ a + b := by
  cases' ‹IdempotentOrdAddCommMonoid R› with _ _ _ _ _ _ _ _ _ _ _ _ _ _;
  rename_i h₁ h₂ h₃ h₄;
  have h_le : a + (a + b) = a + b := by
    rw [ ← add_assoc, h₃ ];
  exact h₄ _ _ |>.2 h_le

end IdempotentOrdAddCommMonoid

/-! ## Polynomial evaluation as idempotent sum -/

/-- Evaluate a list of terms by folding with `+`. -/
def iEval {R : Type*} [IdempotentOrdAddCommMonoid R] : List R → R
  | [] => 0
  | (a :: as) => a + iEval as

@[simp]
theorem iEval_nil {R : Type*} [IdempotentOrdAddCommMonoid R] :
    iEval ([] : List R) = 0 := rfl

@[simp]
theorem iEval_cons {R : Type*} [IdempotentOrdAddCommMonoid R] (a : R) (as : List R) :
    iEval (a :: as) = a + iEval as := rfl

/-! ## Core dominance elimination theorem -/

/-
**Theorem A (abstract dominance elimination).**
If a term `m` is dominated by (≤) the sum of the remaining terms `rest`,
then adding `m` to the front does not change the evaluation.
-/
theorem eval_remove_dominated {R : Type*} [IdempotentOrdAddCommMonoid R]
    (m : R) (rest : List R)
    (hdom : m ≤ iEval rest) :
    iEval (m :: rest) = iEval rest := by
  cases ‹IdempotentOrdAddCommMonoid R›;
  rename_i h₁ h₂ h₃ h₄;
  convert h₄ _ _ |>.1 hdom using 1

/-! ## Canonicalization -/

/-- A term is dominated by a list if it is ≤ the evaluation of that list. -/
def isDominatedBy {R : Type*} [IdempotentOrdAddCommMonoid R]
    (m : R) (ms : List R) : Prop :=
  m ≤ iEval ms

/-- Remove the first dominated term from a list (if any). -/
noncomputable def removeOneDominated {R : Type*} [IdempotentOrdAddCommMonoid R] :
    List R → List R
  | [] => []
  | (m :: ms) =>
    if isDominatedBy m ms then ms
    else m :: removeOneDominated ms

/-
**One step of canonicalization preserves evaluation.**
-/
theorem eval_removeOneDominated {R : Type*} [IdempotentOrdAddCommMonoid R]
    (ms : List R) :
    iEval (removeOneDominated ms) = iEval ms := by
  rename_i h;
  cases' h with _ _ _ _;
  induction ms <;> simp_all +decide [ removeOneDominated ];
  split_ifs <;> simp_all +decide [ isDominatedBy ]

/-- Iterated canonicalization: apply removeOneDominated up to n times. -/
noncomputable def canon {R : Type*} [IdempotentOrdAddCommMonoid R] :
    ℕ → List R → List R
  | 0, ms => ms
  | n + 1, ms => canon n (removeOneDominated ms)

/-- **Theorem B (generic canonical form soundness).**
Iterated canonicalization preserves evaluation. -/
theorem canon_zero {R : Type*} [IdempotentOrdAddCommMonoid R] (ms : List R) :
    canon 0 ms = ms := rfl

theorem canon_succ {R : Type*} [IdempotentOrdAddCommMonoid R] (n : ℕ) (ms : List R) :
    canon (n + 1) ms = canon n (removeOneDominated ms) := rfl

theorem eval_canon_eq_eval {R : Type*} [IdempotentOrdAddCommMonoid R]
    (n : ℕ) (ms : List R) :
    iEval (canon n ms) = iEval ms := by
  induction n generalizing ms with
  | zero => rfl
  | succ n ih =>
    rw [canon_succ, ih, eval_removeOneDominated]

/-! ## Monomial-level formulation -/

/-- A monomial with coefficient and weight vector. -/
structure IMonomial (R : Type*) (σ : Type*) where
  coeff : R
  weight : σ → R

/-- Evaluate a list of monomials by mapping each to a value in `R` and summing. -/
def evalMonomials {R : Type*} [IdempotentOrdAddCommMonoid R] {σ : Type*}
    (evalM : IMonomial R σ → (σ → R) → R)
    (ms : List (IMonomial R σ)) (x : σ → R) : R :=
  iEval (ms.map (fun m => evalM m x))

/-- A monomial is pointwise dominated if its evaluation is ≤ the sum of the rest. -/
def monomialDominated {R : Type*} [IdempotentOrdAddCommMonoid R] {σ : Type*}
    (evalM : IMonomial R σ → (σ → R) → R)
    (m : IMonomial R σ) (rest : List (IMonomial R σ)) : Prop :=
  ∀ x : σ → R, evalM m x ≤ evalMonomials evalM rest x

/-- **Corollary: Removing a pointwise-dominated monomial preserves the polynomial function.** -/
theorem eval_remove_dominated_monomial {R : Type*} [IdempotentOrdAddCommMonoid R] {σ : Type*}
    (evalM : IMonomial R σ → (σ → R) → R)
    (m : IMonomial R σ) (rest : List (IMonomial R σ))
    (hdom : monomialDominated evalM m rest)
    (x : σ → R) :
    evalMonomials evalM (m :: rest) x = evalMonomials evalM rest x := by
  simp only [evalMonomials, List.map_cons]
  exact eval_remove_dominated _ _ (hdom x)

/-! ## Max-Plus wrapper type -/

/-- The max-plus algebra wrapper. Wraps `WithBot ℤ` with tropical addition (= max). -/
structure MaxPlusSemiring where
  val : WithBot ℤ
  deriving DecidableEq

namespace MaxPlusSemiring

instance : LinearOrder MaxPlusSemiring :=
  LinearOrder.lift' (fun m => m.val) (fun a b h => by cases a; cases b; simp_all)

instance : Add MaxPlusSemiring where
  add a b := ⟨max a.val b.val⟩

instance : Zero MaxPlusSemiring where
  zero := ⟨⊥⟩

@[simp] theorem add_val (a b : MaxPlusSemiring) : (a + b).val = max a.val b.val := rfl
@[simp] theorem zero_val : (0 : MaxPlusSemiring).val = ⊥ := rfl

private theorem ext_iff (a b : MaxPlusSemiring) : a = b ↔ a.val = b.val := by
  cases a; cases b; simp

noncomputable instance : IdempotentOrdAddCommMonoid MaxPlusSemiring where
  add_comm := fun a b => by
    cases a; cases b; exact congr_arg MaxPlusSemiring.mk (max_comm _ _)
  add_zero := fun a => by
    apply (ext_iff _ _).mpr; simp
  zero_add := fun a => by
    apply (ext_iff _ _).mpr; simp
  add_assoc := fun a b c => by
    apply (ext_iff _ _).mpr; simp [max_assoc]
  nsmul := fun n a => match n with | 0 => 0 | _ + 1 => a
  nsmul_zero := fun _ => rfl
  nsmul_succ := by
    intro n a; cases n with
    | zero => apply (ext_iff _ _).mpr; simp
    | succ n => apply (ext_iff _ _).mpr; simp [max_self]
  add_idem := fun a => by
    apply (ext_iff _ _).mpr; simp [max_self]
  le_iff_add := by
    intro a b; constructor
    · intro h
      apply (ext_iff _ _).mpr; simp
      exact h
    · intro h
      have hv := congr_arg MaxPlusSemiring.val h
      simp at hv; exact hv

end MaxPlusSemiring

/-- **Theorem C (max-plus specialization).** -/
theorem eval_canon_maxplus (n : ℕ) (ms : List MaxPlusSemiring) :
    iEval (canon n ms) = iEval ms :=
  eval_canon_eq_eval n ms

/-! ## Min-Plus wrapper type -/

/-- The min-plus algebra wrapper. Wraps `WithTop ℤ` with tropical addition (= min). -/
structure MinPlusSemiring where
  val : WithTop ℤ
  deriving DecidableEq

namespace MinPlusSemiring

/-- Min-plus uses the REVERSED order: larger values are "smaller" tropically. -/
instance : LinearOrder MinPlusSemiring :=
  LinearOrder.lift' (fun m => OrderDual.toDual m.val) (fun a b h => by cases a; cases b; simpa using h)

instance : Add MinPlusSemiring where
  add a b := ⟨min a.val b.val⟩

instance : Zero MinPlusSemiring where
  zero := ⟨⊤⟩

@[simp] theorem add_val (a b : MinPlusSemiring) : (a + b).val = min a.val b.val := rfl
@[simp] theorem zero_val : (0 : MinPlusSemiring).val = ⊤ := rfl

private theorem ext_iff (a b : MinPlusSemiring) : a = b ↔ a.val = b.val := by
  cases a; cases b; simp

noncomputable instance : IdempotentOrdAddCommMonoid MinPlusSemiring where
  add_comm := fun a b => by
    apply (ext_iff _ _).mpr; simp [min_comm]
  add_zero := fun a => by
    apply (ext_iff _ _).mpr; simp
  zero_add := fun a => by
    apply (ext_iff _ _).mpr; simp
  add_assoc := fun a b c => by
    apply (ext_iff _ _).mpr; simp [min_assoc]
  nsmul := fun n a => match n with | 0 => 0 | _ + 1 => a
  nsmul_zero := fun _ => rfl
  nsmul_succ := by
    intro n a; cases n with
    | zero => apply (ext_iff _ _).mpr; simp
    | succ n => apply (ext_iff _ _).mpr; simp [min_self]
  add_idem := fun a => by
    apply (ext_iff _ _).mpr; simp [min_self]
  le_iff_add := by
    intro a b; constructor
    · intro h  -- h : a ≤ b, i.e., b.val ≤ a.val
      apply (ext_iff _ _).mpr; simp
      exact h  -- min a.val b.val = b.val ← b.val ≤ a.val (simp reduces)
    · intro h
      have hv := congr_arg MinPlusSemiring.val h
      simp at hv; exact hv

end MinPlusSemiring

/-- **Theorem C (min-plus specialization).** -/
theorem eval_canon_minplus (n : ℕ) (ms : List MinPlusSemiring) :
    iEval (canon n ms) = iEval ms :=
  eval_canon_eq_eval n ms

/-! ## Boolean two-point semiring -/

/-- `Bool` with `||` as addition is an ordered idempotent additive monoid. -/
noncomputable instance boolIdempotent : IdempotentOrdAddCommMonoid Bool where
  add := (· || ·)
  zero := false
  add_comm := Bool.or_comm
  add_zero := Bool.or_false
  zero_add := Bool.false_or
  add_assoc := Bool.or_assoc
  nsmul := fun n b => match n with | 0 => false | _ + 1 => b
  nsmul_zero := fun _ => rfl
  nsmul_succ := by
    intro n x; cases n with
    | zero => rfl
    | succ n => exact (Bool.or_self x).symm
  add_idem := Bool.or_self
  le_iff_add := by
    intro a b; cases a <;> cases b <;> simp [HAdd.hAdd, Add.add]

/-- Boolean absorption is an instance of tropical dominance elimination. -/
theorem bool_dominance_elimination (a b : Bool) (h : a ≤ b) :
    @iEval Bool boolIdempotent [a, b] = @iEval Bool boolIdempotent [b] := by
  apply @eval_remove_dominated Bool boolIdempotent a [b]
  show a ≤ @iEval Bool boolIdempotent [b]
  simp only [iEval]
  cases a <;> cases b <;> exact h

/-! ## Duality principle -/

/-- The abstract dominance theorem applies uniformly to any idempotent ordered additive monoid. -/
theorem abstract_dominance_is_universal {R : Type*} [IdempotentOrdAddCommMonoid R]
    (m : R) (rest : List R) (hdom : m ≤ iEval rest) :
    iEval (m :: rest) = iEval rest :=
  eval_remove_dominated m rest hdom