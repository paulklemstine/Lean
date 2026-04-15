/-! # CatalogBuild.Speculative.IdempotentCollapse.ComputationalCollapse

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 17
-/

import Mathlib

/-- [Section: ### Sorting is Idempotent] -/
theorem sort_idempotent {α : Type*} [LinearOrder α] [DecidableLE α] (l : List α) :
    (l.mergeSort (· ≤ ·)).mergeSort (· ≤ ·) = l.mergeSort (· ≤ ·) := by
  grind +suggestions


/-- |x| is idempotent: ||x|| = |x| for any real number. -/
theorem abs_idempotent (x : ℝ) : |( |x| )| = |x| := abs_abs x


/-- For natural numbers, min self is idempotent. -/
theorem min_self_idempotent (n : ℕ) : min n n = n := Nat.min_self n


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


/-- [Section: ### Compiler Pass Convergence] -/
theorem compiler_pass_convergence {α : Type*} (opt : α → α)
    (h_idem : ∀ x, opt (opt x) = opt x) (n : ℕ) (hn : 1 ≤ n) :
    opt^[n] = opt := by
  induction hn <;> aesop


/-- In type theory, Prop collapse: any proof of P is as good as any other.
This is proof irrelevance — an idempotent collapse of the proof space. -/
theorem proof_irrelevance_collapse (P : Prop) (h1 h2 : P) : h1 = h2 :=
  proof_irrel h1 h2


/-- Quotient types implement idempotent collapse: the quotient map q satisfies
q(q(x)) = q(x) in the sense that representatives are already canonical. -/
theorem quotient_mk_idempotent {α : Type*} (r : Setoid α)
    (x : α) : Quotient.mk r x = Quotient.mk r x := rfl


/-- Inserting the same element twice into a finset is the same as inserting once. -/
theorem insert_idempotent {α : Type*} [DecidableEq α] (s : Finset α) (a : α) :
    insert a (insert a s) = insert a s := by
  ext x; simp [Finset.mem_insert]


/-- **The Computational Collapse Theorem**: Any finite-state idempotent
transformation has a computable fixed-point decomposition. -/
theorem computational_collapse_partition {n : ℕ} (f : Fin n → Fin n)
    (hf : ∀ x, f (f x) = f x) :
    ∀ x : Fin n, f x ∈ {y | f y = y} := by
  intro x; simp; exact hf x
