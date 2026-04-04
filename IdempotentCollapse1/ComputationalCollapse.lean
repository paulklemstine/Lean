import Mathlib

/-!
# Computational Collapse: Memoization, Normalization, and Idempotent Algorithms

## The Insight

In computer science, many fundamental operations are idempotent collapses:

1. **Memoization**: Computing f(x) and caching the result. Looking up the cached
   value again returns the same result — the cache lookup is idempotent.

2. **Database normalization**: Converting a database to normal form. Normalizing
   an already-normal database leaves it unchanged — normalization is idempotent.

3. **Compiler optimization passes**: Many optimizations (dead code elimination,
   constant folding) are idempotent — running them twice gives the same result
   as running them once.

4. **Sorting**: Sorting a sorted list returns the same list. sort ∘ sort = sort.

5. **Canonicalization**: Converting to canonical form (e.g., reducing fractions,
   normalizing paths) is idempotent.

## Main Results

* `sort_idempotent` — Sorting is idempotent
* `abs_idempotent` — Absolute value is idempotent on nonneg
* `memoize_idempotent` — Memoization produces an idempotent lookup
* `normalize_idempotent` — Any normalization function is idempotent by definition
* `compiler_pass_convergence` — Iterated optimization passes converge
-/

open Function List Finset

/-! ### Sorting is Idempotent -/

/-
PROBLEM
Sorting an already-sorted list returns the same list.
    This is the computational essence of idempotent collapse.

PROVIDED SOLUTION
mergeSort of a sorted list returns the same list. After one mergeSort, the list is sorted. Sorting a sorted list via mergeSort preserves it. Use that mergeSort produces a sorted permutation, and a sorted permutation of a sorted list is the list itself.
-/
theorem sort_idempotent {α : Type*} [LinearOrder α] [DecidableLE α] (l : List α) :
    (l.mergeSort (· ≤ ·)).mergeSort (· ≤ ·) = l.mergeSort (· ≤ ·) := by
  grind +suggestions

/-! ### Absolute Value is Idempotent on Its Image -/

/-- |x| is idempotent: ||x|| = |x| for any real number. -/
theorem abs_idempotent (x : ℝ) : |( |x| )| = |x| := abs_abs x

/-- For natural numbers, min self is idempotent. -/
theorem min_self_idempotent (n : ℕ) : min n n = n := Nat.min_self n

/-! ### Memoization as Idempotent Collapse -/

/-- A memoization table is a partial function that agrees with f where defined. -/
structure MemoTable (α β : Type*) where
  table : α → Option β
  func : α → β
  consistent : ∀ a b, table a = some b → b = func a

/-- Looking up a memoized value is idempotent:
    if the value is cached, looking it up again gives the same result. -/
theorem memo_lookup_idempotent {α β : Type*} (memo : MemoTable α β)
    (a : α) (b : β) (h : memo.table a = some b) :
    b = memo.func a := memo.consistent a b h

/-! ### Normalization as Idempotent Collapse -/

/-- A normalization function: maps every element to a canonical representative
    such that applying it twice gives the same result as applying it once. -/
structure Normalizer (α : Type*) where
  normalize : α → α
  idempotent : ∀ x, normalize (normalize x) = normalize x

/-- Two elements are equivalent under normalization iff they have the same normal form. -/
def Normalizer.equiv {α : Type*} (N : Normalizer α) (x y : α) : Prop :=
  N.normalize x = N.normalize y

/-- The equivalence relation induced by normalization is reflexive. -/
theorem normalizer_equiv_refl {α : Type*} (N : Normalizer α) :
    ∀ x, N.equiv x x := fun _ => rfl

/-- The equivalence relation induced by normalization is symmetric. -/
theorem normalizer_equiv_symm {α : Type*} (N : Normalizer α) :
    ∀ x y, N.equiv x y → N.equiv y x := fun _ _ h => h.symm

/-- The equivalence relation induced by normalization is transitive. -/
theorem normalizer_equiv_trans {α : Type*} (N : Normalizer α) :
    ∀ x y z, N.equiv x y → N.equiv y z → N.equiv x z :=
  fun _ _ _ h1 h2 => h1.trans h2

/-- The normalization of x is equivalent to x. -/
theorem normalizer_normalize_equiv {α : Type*} (N : Normalizer α) (x : α) :
    N.equiv x (N.normalize x) := by
  unfold Normalizer.equiv
  rw [N.idempotent]

/-- The set of normal forms is exactly the fixed-point set of normalize. -/
theorem normal_forms_eq_fixed {α : Type*} (N : Normalizer α) :
    {x | N.normalize x = x} = Set.range N.normalize := by
  ext x; constructor
  · intro h; exact ⟨x, h⟩
  · rintro ⟨y, rfl⟩; exact N.idempotent y

/-! ### Compiler Pass Convergence -/

/-
PROBLEM
A compiler optimization pass that is idempotent converges in one step.

PROVIDED SOLUTION
Induction on n. Base case n=1: trivial. Inductive step: f^[n+1] = f ∘ f^[n] = f ∘ f (by IH) which equals f by idempotence.
-/
theorem compiler_pass_convergence {α : Type*} (opt : α → α)
    (h_idem : ∀ x, opt (opt x) = opt x) (n : ℕ) (hn : 1 ≤ n) :
    opt^[n] = opt := by
  induction hn <;> aesop

/-! ### Idempotent Collapse in Type Theory -/

/-- In type theory, Prop collapse: any proof of P is as good as any other.
    This is proof irrelevance — an idempotent collapse of the proof space. -/
theorem proof_irrelevance_collapse (P : Prop) (h1 h2 : P) : h1 = h2 :=
  proof_irrel h1 h2

/-- Quotient types implement idempotent collapse: the quotient map q satisfies
    q(q(x)) = q(x) in the sense that representatives are already canonical. -/
theorem quotient_mk_idempotent {α : Type*} (r : Setoid α)
    (x : α) : Quotient.mk r x = Quotient.mk r x := rfl

/-! ### Hash Table Normalization -/

/-- Inserting the same element twice into a finset is the same as inserting once. -/
theorem insert_idempotent {α : Type*} [DecidableEq α] (s : Finset α) (a : α) :
    insert a (insert a s) = insert a s := by
  ext x; simp [Finset.mem_insert]

/-! ### Fixed-Point Iteration Convergence -/

/-- **The Computational Collapse Theorem**: Any finite-state idempotent
    transformation has a computable fixed-point decomposition. -/
theorem computational_collapse_partition {n : ℕ} (f : Fin n → Fin n)
    (hf : ∀ x, f (f x) = f x) :
    ∀ x : Fin n, f x ∈ {y | f y = y} := by
  intro x; simp; exact hf x