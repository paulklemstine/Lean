import Mathlib

/-!
# Minor-closed classes, excluded minors and representability

This file sets up the basic vocabulary of matroid minor theory that is used in
`Applications/PosetTheory/Structural.lean`:

* `MinorClosed P` — the class `P` is closed under taking minors;
* `IsForbiddenMinor P N` — `N` is an *excluded minor* for `P`: it fails `P`
  while all its proper minors satisfy `P`;
* `IsRepresentable F M` — `M` is representable over the field `F` by vectors in
  some finite-dimensional coordinate space;
* `dual_isMinor_dual` — the minor order is compatible with matroid duality;
* `GGW_Conjecture` — the Geelen–Gerards–Whittle well-quasi-ordering statement
  for `F`-representable matroids, and `ggw_implies_finite_excluded_minors`, the
  deduction that under it every minor-closed class has only finitely many
  representable excluded minors (excluded minors form an antichain, and a
  well-quasi-order has no infinite antichain).
-/

open Set Matroid

variable {α : Type*}

/-! ## Minor-closed classes -/

/-- A property of matroids is **minor-closed** if it passes to every minor. -/
def MinorClosed (P : Matroid α → Prop) : Prop :=
  ∀ M N : Matroid α, P M → N ≤m M → P N

/-- `N` is an **excluded (forbidden) minor** for `P` if `N` fails `P` but every
proper minor of `N` satisfies `P`. -/
def IsForbiddenMinor (P : Matroid α → Prop) (N : Matroid α) : Prop :=
  ¬ P N ∧ ∀ M : Matroid α, M <m N → P M

/-- Excluded minors form an **antichain** in the minor order: two distinct
excluded minors are incomparable. -/
theorem not_isMinor_of_isForbiddenMinor {P : Matroid α → Prop} {M N : Matroid α}
    (hM : IsForbiddenMinor P M) (hN : IsForbiddenMinor P N) (hne : M ≠ N) : ¬ M ≤m N := by
  intro hle
  have hstrict : M <m N := ⟨hle, fun hge => hne (Matroid.IsMinor.antisymm hle hge)⟩
  exact hM.1 (hN.2 M hstrict)

/-! ## Duality -/

/-- **Duality preserves the minor order.**  If `N` is a minor of `M`, then `N✶`
is a minor of `M✶`. -/
theorem dual_isMinor_dual {M N : Matroid α} (h : N ≤m M) : N✶ ≤m M✶ := by
  obtain ⟨C, D, -, -, hCD, rfl⟩ := h.exists_eq_contract_delete_disjoint
  rw [Matroid.dual_contract_delete, ← Matroid.contract_delete_comm _ hCD.symm]
  exact ⟨D, C, rfl⟩

/-! ## Representability -/

/-- `M` is **representable over `F`** if its ground set can be mapped to a
finite-dimensional coordinate space over `F` so that independence in `M` is
linear independence of the corresponding vectors. -/
def IsRepresentable (F : Type*) [Field F] (M : Matroid α) : Prop :=
  ∃ (n : ℕ) (φ : α → (Fin n → F)), ∀ I ⊆ M.E, (M.Indep I ↔ LinearIndepOn F φ I)

/-! ## Well-quasi-ordering and finiteness of excluded minors -/

/-- The **Geelen–Gerards–Whittle statement**: the matroids representable over a
finite field `F` are well-quasi-ordered by the minor order, i.e. in every
infinite sequence of representable matroids some earlier term is a minor of some
later term. -/
def GGW_Conjecture (α : Type*) (F : Type*) [Field F] [Fintype F] : Prop :=
  ∀ f : ℕ → Matroid α, (∀ i, IsRepresentable F (f i)) → ∃ i j, i < j ∧ f i ≤m f j

/-- **From well-quasi-ordering to finitely many excluded minors.**

If the `F`-representable matroids are well-quasi-ordered by the minor relation,
then for every property `P` there are only finitely many representable excluded
minors for `P`: they form an antichain, and an infinite antichain would give an
infinite sequence violating the well-quasi-ordering.

(The minor-closedness hypothesis `_hP` is recorded because it is part of the
usual statement, but the antichain argument does not need it.) -/
theorem ggw_implies_finite_excluded_minors (F : Type*) [Field F] [Fintype F]
    (hGGW : GGW_Conjecture α F) (P : Matroid α → Prop) (_hP : MinorClosed P) :
    Set.Finite {N : Matroid α | IsRepresentable F N ∧ IsForbiddenMinor P N} := by
  by_contra hinf
  rw [Set.not_finite] at hinf
  obtain ⟨e⟩ : Nonempty (ℕ ↪ {N : Matroid α | IsRepresentable F N ∧ IsForbiddenMinor P N}) :=
    ⟨hinf.natEmbedding⟩
  set f : ℕ → Matroid α := fun i => (e i : Matroid α) with hf
  have hmem : ∀ i, IsRepresentable F (f i) ∧ IsForbiddenMinor P (f i) := fun i => (e i).2
  obtain ⟨i, j, hij, hle⟩ := hGGW f (fun i => (hmem i).1)
  have hne : f i ≠ f j := by
    intro h
    exact absurd (e.injective (Subtype.ext h)) (Nat.ne_of_lt hij)
  exact not_isMinor_of_isForbiddenMinor (hmem i).2 (hmem j).2 hne hle