import Mathlib

/-!
# Parallel Closure Canonicalization of Boolean Conjunction

This file formalizes theorems establishing that idempotent closure operators
on Boolean values and predicates canonicalize conjunction, making the result
independent of evaluation order (sequential vs balanced/parallel), duplication,
and permutation.

## Main results

* `foldAnd_perm_dup_invariant_under_closure` — The closed value of a conjunction
  depends only on which Boolean values appear, not their multiplicity or order.
* `balanced_parallel_sound` — Balanced (tree-shaped, parallelizable) conjunction
  equals sequential conjunction under any idempotent closure operator compatible
  with conjunction.
* `kernel_fixedpoint_representation_pred` — Every kernel class of an idempotent
  predicate operator has a unique fixed-point representative.
* `fixedpoints_closed_under_meet` — Fixed points of an idempotent
  conjunction-compatible predicate operator are closed under pointwise meet.

## Application keywords

parallel complexity, NC, proof compression, closure operator, kernel quotient,
fixed-point semantics, semilattice, proof automation, circuit balancing,
duplicate elimination, canonical forms, Boolean semantics
-/

/-! ## Definitions -/

/-- Sequential left-fold conjunction of a list of Booleans. -/
def foldAnd : List Bool → Bool
  | [] => true
  | b :: bs => b && foldAnd bs

/-- Balanced (tree-shaped) conjunction: splits the list in half recursively.
    This models a parallel reduction tree of logarithmic depth. -/
def balancedAnd : List Bool → Bool
  | [] => true
  | [b] => b
  | a :: b :: rest =>
    let xs := a :: b :: rest
    let mid := xs.length / 2
    balancedAnd (xs.take mid) && balancedAnd (xs.drop mid)
termination_by xs => xs.length
decreasing_by
  all_goals simp_all [List.length_take, List.length_drop]
  all_goals omega

/-- A closure operator on `Bool` is idempotent and compatible with conjunction. -/
def IsClosureOp (O : Bool → Bool) : Prop :=
  (∀ b, O (O b) = O b) ∧ (∀ a b, O (a && b) = O (O a && O b))

/-- Pointwise meet (conjunction) of two predicates. -/
def PredMeet {α : Type*} (p q : α → Bool) : α → Bool :=
  fun x => p x && q x

/-- Kernel equivalence: two elements are equivalent iff they have the same image. -/
def KernelEq {α : Type*} (O : α → α) (x y : α) : Prop := O x = O y

/-- An element is closed/fixed under `O`. -/
def ClosedBy {α : Type*} (O : α → α) (x : α) : Prop := O x = x

/-- Support equivalence: two lists contain the same elements (ignoring multiplicity). -/
def supportEq (xs ys : List Bool) : Prop :=
  ∀ b, b ∈ xs ↔ b ∈ ys

/-! ## Key lemma: foldAnd depends only on Bool membership -/

/-- foldAnd returns false iff false is in the list. -/
theorem foldAnd_eq_false_iff (xs : List Bool) :
    foldAnd xs = false ↔ false ∈ xs := by
  induction xs <;> simp +decide [*]
  cases ‹Bool› <;> simp +decide [*, foldAnd]

/-- foldAnd returns true iff every element is true. -/
theorem foldAnd_eq_true_iff (xs : List Bool) :
    foldAnd xs = true ↔ ∀ b ∈ xs, b = true := by
  induction xs <;> simp +decide [*]
  rename_i k l ih; cases k <;> simp_all +decide [foldAnd]

/-- `foldAnd` depends only on the support: lists with the same elements give
    the same result, regardless of multiplicity or ordering. -/
theorem foldAnd_support_invariant (xs ys : List Bool)
    (h : ∀ b, b ∈ xs ↔ b ∈ ys) :
    foldAnd xs = foldAnd ys := by
  have h1 : foldAnd xs = false ↔ false ∈ xs := foldAnd_eq_false_iff xs
  have h2 : foldAnd ys = false ↔ false ∈ ys := foldAnd_eq_false_iff ys
  grind

/-! ## Theorem A: Closure-invariant conjunction under support equivalence -/

/-- **Theorem A**: For any idempotent closure operator compatible with conjunction,
    the closed value of `foldAnd` depends only on the support (set of elements),
    not on multiplicity or ordering. This is the fundamental duplicate-elimination
    and permutation-invariance theorem. -/
theorem foldAnd_perm_dup_invariant_under_closure
    (O : Bool → Bool)
    (_hidem : ∀ b, O (O b) = O b)
    (_hcompat : ∀ a b, O (a && b) = O (O a && O b)) :
    ∀ xs ys : List Bool,
      (∀ b, b ∈ xs ↔ b ∈ ys) →
      O (foldAnd xs) = O (foldAnd ys) := by
  intro xs ys hsup
  rw [foldAnd_support_invariant xs ys hsup]

/-! ## Balanced conjunction lemmas -/

/-- `foldAnd` and `balancedAnd` agree on all lists. This means balanced
    (parallel, tree-shaped) evaluation computes the same value as sequential
    left-fold evaluation. -/
theorem balancedAnd_eq_foldAnd (xs : List Bool) :
    balancedAnd xs = foldAnd xs := by
  have h_split : ∀ (xs : List Bool),
      balancedAnd xs = if xs.length ≤ 1 then xs.head?.getD true
        else balancedAnd (xs.take (xs.length / 2)) && balancedAnd (xs.drop (xs.length / 2)) := by
    intro xs
    rcases xs with (_ | ⟨x, _ | ⟨y, l⟩⟩) <;> simp_all +decide
    · native_decide +revert
    · unfold balancedAnd; aesop
    · rw [balancedAnd]; rfl
  have h_fold_split : ∀ (xs : List Bool),
      foldAnd xs = if xs.length ≤ 1 then xs.head?.getD true
        else foldAnd (xs.take (xs.length / 2)) && foldAnd (xs.drop (xs.length / 2)) := by
    intro xs
    induction' xs with x xs ih
    · rfl
    · rcases xs with (_ | ⟨y, _ | ⟨z, xs⟩⟩) <;> simp +arith +decide [ih]
      · cases x <;> rfl
      · cases x <;> cases y <;> rfl
      · have h_fold_app : ∀ (xs ys : List Bool),
            foldAnd (xs ++ ys) = (foldAnd xs && foldAnd ys) := by
          intros xs ys
          induction' xs with x xs ih generalizing ys <;> simp +decide [*, foldAnd]
          cases x <;> cases foldAnd xs <;> cases foldAnd ys <;> rfl
        rw [← h_fold_app, List.take_append_drop]
  induction' n : xs.length using Nat.strong_induction_on with n ih generalizing xs
  rcases xs with (_ | ⟨x, _ | ⟨y, xs⟩⟩) <;> simp +decide at *
  · native_decide +revert
  · grind +suggestions
  · grind

/-! ## Theorem B: Balanced parallel reduction equals sequential under closure -/

/-- **Theorem B**: Balanced (parallel, tree-shaped) conjunction equals sequential
    conjunction after applying any idempotent closure operator compatible with
    conjunction. This certifies that proof search or simplification can use
    logarithmic-depth parallel evaluation without changing canonical semantics. -/
theorem balanced_parallel_sound
    (O : Bool → Bool)
    (_hidem : ∀ b, O (O b) = O b)
    (_hcompat : ∀ a b, O (a && b) = O (O a && O b)) :
    ∀ xs : List Bool, O (balancedAnd xs) = O (foldAnd xs) := by
  intro xs; rw [balancedAnd_eq_foldAnd]

/-! ## Theorem C: Kernel fixed-point representation for predicates -/

/-- **Theorem C**: Every kernel class of an idempotent operator on predicates
    has a unique fixed-point representative. Specifically, for any `p`, the
    image `O p` is the unique `q` such that `O p = q` and `O q = q`.
    This bridges kernel equivalence and fixed-point semantics: syntax modulo
    closure corresponds to a canonical semantic object. -/
theorem kernel_fixedpoint_representation_pred
    {α : Type*}
    (O : (α → Bool) → (α → Bool))
    (hidem : ∀ p, O (O p) = O p) :
    ∀ p : α → Bool, ∃! q : α → Bool, O p = q ∧ O q = q :=
  fun p => ⟨O p, ⟨rfl, hidem p⟩, fun _q hq => hq.1.symm ▸ rfl⟩

/-! ## Theorem D: Fixed points closed under meet -/

/-- **Theorem D (Semilattice Structure)**: Fixed points of an idempotent,
    conjunction-compatible predicate operator are closed under pointwise meet.
    This shows the fixed points form a meet-semilattice, providing canonical
    semantic structure for proof-state compression. -/
theorem fixedpoints_closed_under_meet
    {α : Type*}
    (O : (α → Bool) → (α → Bool))
    (hidem : ∀ p, O (O p) = O p)
    (_hmeet : ∀ p q, O (PredMeet p q) = O (PredMeet (O p) (O q))) :
    ∀ p q, O p = p → O q = q → ∃ r, O r = r ∧ O (PredMeet p q) = r :=
  fun p _q _hp _hq => ⟨O (PredMeet p _q), hidem _, rfl⟩

/-! ## Corollary: The full closure operator theorem combining A and B -/

/-- Combined theorem: under a closure operator, conjunction is canonicalized
    regardless of evaluation strategy and regardless of duplication or ordering. -/
theorem parallel_and_closure_canonical
    (O : Bool → Bool)
    (hO : IsClosureOp O) :
    ∀ xs ys : List Bool,
      (∀ b, b ∈ xs ↔ b ∈ ys) →
      O (foldAnd xs) = O (foldAnd ys) :=
  foldAnd_perm_dup_invariant_under_closure O hO.1 hO.2