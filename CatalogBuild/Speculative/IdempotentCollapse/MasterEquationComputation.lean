/-! # CatalogBuild.Speculative.IdempotentCollapse.MasterEquationComputation

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 13
-/

import Mathlib

noncomputable section

/-- Deduplication of a list is idempotent. -/
theorem list_dedup_idempotent {α : Type*} [DecidableEq α] (l : List α) :
    l.dedup.dedup = l.dedup :=
  List.dedup_idem

/-- Deduplication of a multiset is idempotent. -/

theorem multiset_dedup_idempotent {α : Type*} [DecidableEq α] (s : Multiset α) :
    s.dedup.dedup = s.dedup :=
  Multiset.dedup_idem

/-! ## 2. Closure Operators as Idempotent Collapse -/

/-- A closure operator on a partial order is idempotent. -/

theorem closure_operator_idempotent {α : Type*} [PartialOrder α]
    (c : ClosureOperator α) (x : α) :
    c (c x) = c x :=
  c.idempotent x

/-- The topological closure is idempotent. -/

theorem normalization_idempotent_iff {α : Type*} (normalize : α → α) :
    (∀ x, normalize (normalize x) = normalize x) ↔
    (∀ y ∈ range normalize, normalize y = y) := by
  constructor
  · intro h y ⟨x, hx⟩; rw [← hx]; exact h x
  · intro h x; exact h (normalize x) ⟨x, rfl⟩

/-! ## 5. Idempotent Semirings and Shortest Paths -/

/-- In any semilattice, meet with self is idempotent. -/

theorem lattice_meet_idempotent {α : Type*} [SemilatticeInf α] (a : α) :
    a ⊓ a = a := inf_idem a

/-- In any semilattice, join with self is idempotent. -/

theorem lattice_join_idempotent {α : Type*} [SemilatticeSup α] (a : α) :
    a ⊔ a = a := sup_idem a

/-! ## 6. Galois Connections and Abstract Interpretation -/

/-- In a Galois connection, u ∘ l ∘ u ∘ l = u ∘ l (closure is idempotent). -/

theorem galois_connection_kernel {α β : Type*} [Preorder α] [PartialOrder β]
    {l : α → β} {u : β → α}
    (gc : GaloisConnection l u) (x : β) :
    l (u (l (u x))) = l (u x) :=
  gc.l_u_l_eq_l (u x)

/-! ## 7. Error Correction as Projection -/

/-- Error correction is idempotent: correcting a correct state does nothing. -/

theorem error_correction_idempotent {α : Type*} (valid : Set α)
    (correct : α → α) (h_into : ∀ x, correct x ∈ valid)
    (h_fixes : ∀ x ∈ valid, correct x = x) :
    ∀ x, correct (correct x) = correct x :=
  fun x => h_fixes (correct x) (h_into x)

/-! ## 8. The Master Equation: One Step Suffices -/

/-
PROBLEM
The Master Equation: one application reaches the fixed point.

PROVIDED SOLUTION
Induction on n. Base n=1: f^[1] x = f x. Inductive step: f^[n+1] x = f (f^[n] x) = f (f x) by IH = f x by hf.
-/

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

/-
PROBLEM
An idempotent splits through its image (categorical Master Equation).

PROVIDED SOLUTION
Let ι be the inclusion Subtype.val and π a = ⟨f a, a, rfl⟩. Then π(ι(⟨b, hb⟩)) = ⟨f b, ...⟩ = ⟨b, ...⟩ since b ∈ range f means b = f y for some y, so f b = f(f y) = f y = b. And ι(π(a)) = (⟨f a, ...⟩).val = f a.
-/

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

/-! ## 9. Computational Convergence: The Fixed-Point Theorem -/

/-
PROBLEM
In a finite type, iterating any function eventually becomes periodic.

PROVIDED SOLUTION
By pigeonhole principle on the finite type α → α (or on iterates). The set of functions f^[0], f^[1], ..., f^[|α^α|] must have a collision by Fintype.exists_ne_map_eq_of_card_lt or similar. Actually we can use that Fintype (α → α) means the iterates f^[n] can only take finitely many values. Use Finset.exists_ne_map_eq_of_card_lt_of_maps_to or pigeonhole on the sequence of iterates.
-/

theorem finite_iteration_periodic {α : Type*} [Fintype α]
    (f : α → α) : ∃ n m : ℕ, 0 < n ∧ n < m ∧ f^[n] = f^[m] := by
  by_contra! h_contra;
  exact absurd ( Set.infinite_range_of_injective ( show Function.Injective ( fun n : ℕ => f^[n+1] ) from fun m n hmn => le_antisymm ( not_lt.1 fun hmn' => h_contra _ _ ( Nat.succ_pos _ ) ( Nat.succ_lt_succ hmn' ) hmn.symm ) ( not_lt.1 fun hmn' => h_contra _ _ ( Nat.succ_pos _ ) ( Nat.succ_lt_succ hmn' ) hmn ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ )


end
