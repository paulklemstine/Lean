import Mathlib

/-! # CatalogBuild.Speculative.IdempotentCollapse.MasterEquationComputation

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 13
-/

noncomputable section

/-- Deduplication of a list is idempotent. -/
theorem list_dedup_idempotent {α : Type*} [DecidableEq α] (l : List α) :
    l.dedup.dedup = l.dedup :=
  List.dedup_idem

/-- Deduplication of a multiset is idempotent. -/
theorem multiset_dedup_idempotent {α : Type*} [DecidableEq α] (s : Multiset α) :
    s.dedup.dedup = s.dedup :=
  Multiset.dedup_idem

/-- A closure operator on a partial order is idempotent. -/
theorem closure_operator_idempotent {α : Type*} [PartialOrder α]
    (c : ClosureOperator α) (x : α) :
    c (c x) = c x :=
  c.idempotent x

/-- A normalization function is idempotent iff normal forms are fixed points. -/
theorem normalization_idempotent_iff {α : Type*} (normalize : α → α) :
    (∀ x, normalize (normalize x) = normalize x) ↔
    (∀ y ∈ range normalize, normalize y = y) := by
  constructor
  · intro h y ⟨x, hx⟩; rw [← hx]; exact h x
  · intro h x; exact h (normalize x) ⟨x, rfl⟩

/-- In any semilattice, meet with self is idempotent. -/
theorem lattice_meet_idempotent {α : Type*} [SemilatticeInf α] (a : α) :
    a ⊓ a = a := inf_idem a

/-- In any semilattice, join with self is idempotent. -/
theorem lattice_join_idempotent {α : Type*} [SemilatticeSup α] (a : α) :
    a ⊔ a = a := sup_idem a

/-- In a Galois connection, l ∘ u ∘ l ∘ u = l ∘ u (kernel is idempotent). -/
theorem galois_connection_kernel {α β : Type*} [Preorder α] [PartialOrder β]
    {l : α → β} {u : β → α}
    (gc : GaloisConnection l u) (x : β) :
    l (u (l (u x))) = l (u x) :=
  gc.l_u_l_eq_l (u x)

/-- Error correction is idempotent: correcting a correct state does nothing. -/
theorem error_correction_idempotent {α : Type*} (valid : Set α)
    (correct : α → α) (h_into : ∀ x, correct x ∈ valid)
    (h_fixes : ∀ x ∈ valid, correct x = x) :
    ∀ x, correct (correct x) = correct x :=
  fun x => h_fixes (correct x) (h_into x)

/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.MasterEquationComputation
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 13] -/
theorem master_equation_one_step {α : Type*} (f : α → α)
    (hf : ∀ x, f (f x) = f x) (x : α) (n : ℕ) (hn : 0 < n) :
    f^[n] x = f x := by
  induction hn <;> simp +decide [ *, Function.iterate_succ_apply' ]

/-- The image of an idempotent computation is its set of stable states. -/
theorem computation_stable_states {α : Type*} (f : α → α)
    (hf : ∀ x, f (f x) = f x) :
    range f = {x | f x = x} := by
  ext x; simp only [mem_range, mem_setOf_eq]
  exact ⟨fun ⟨y, hy⟩ => hy ▸ hf y, fun hx => ⟨x, hx⟩⟩

/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.MasterEquationComputation
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 13] -/
theorem idempotent_splits_through_image {α : Type*} (f : α → α)
    (hf : ∀ x, f (f x) = f x) :
    ∃ (ι : range f → α) (π : α → range f),
      (∀ b, π (ι b) = b) ∧ (∀ a, ι (π a) = f a) := by
  exact ⟨ fun ⟨ x, hx ⟩ => x, fun x => ⟨ f x, x, rfl ⟩, fun ⟨ x, hx ⟩ => by aesop, fun x => by aesop ⟩

/-- Composition of two commuting idempotent computations is idempotent. -/
theorem commuting_idempotent_computations {α : Type*}
    (f g : α → α)
    (hf : ∀ x, f (f x) = f x) (hg : ∀ x, g (g x) = g x)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    ∀ x, (f ∘ g) ((f ∘ g) x) = (f ∘ g) x := by
  intro x; simp only [comp_apply]
  rw [hcomm, hf, hcomm, hg]

theorem finite_iteration_periodic {α : Type*} [Fintype α]
    (f : α → α) : ∃ n m : ℕ, 0 < n ∧ n < m ∧ f^[n] = f^[m] := by
  by_contra! h_contra;
  exact absurd ( Set.infinite_range_of_injective ( show Function.Injective ( fun n : ℕ => f^[n+1] ) from fun m n hmn => le_antisymm ( not_lt.1 fun hmn' => h_contra _ _ ( Nat.succ_pos _ ) ( Nat.succ_lt_succ hmn' ) hmn.symm ) ( not_lt.1 fun hmn' => h_contra _ _ ( Nat.succ_pos _ ) ( Nat.succ_lt_succ hmn' ) hmn ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ )

end
