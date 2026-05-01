/-! # CatalogBuild.Bridges.GaloisConnectionBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 10
-/

import Mathlib

/-- In a Galois connection l ⊣ u (l : α → β lower, u : β → α upper),
the lower adjoint l is monotone. -/
theorem gc_lower_monotone {α β : Type*} [Preorder α] [Preorder β]
    {l : α → β} {u : β → α} (gc : GaloisConnection l u) :
    Monotone l :=
  GaloisConnection.monotone_l gc


/-- In a Galois connection l ⊣ u, the upper adjoint u is monotone. -/
theorem gc_upper_monotone {α β : Type*} [Preorder α] [Preorder β]
    {l : α → β} {u : β → α} (gc : GaloisConnection l u) :
    Monotone u :=
  GaloisConnection.monotone_u gc


/-- In a Galois insertion (l, u), we have l ∘ u = id:
the lower adjoint reflects equality. -/
theorem gi_l_u_eq {α β : Type*} [Preorder α] [PartialOrder β]
    {l : α → β} {u : β → α} (gi : GaloisInsertion l u) (b : β) :
    l (u b) = b :=
  GaloisInsertion.l_u_eq gi b


/-- **Closure operators are idempotent**: c(c(x)) = c(x). -/
theorem closure_idempotent {α : Type*} [PartialOrder α]
    (c : ClosureOperator α) (x : α) :
    c (c x) = c x :=
  ClosureOperator.idempotent c x


/-- **Closure operators are monotone**: x ≤ y → c(x) ≤ c(y). -/
theorem closure_monotone {α : Type*} [PartialOrder α]
    (c : ClosureOperator α) :
    Monotone ⇑c :=
  ClosureOperator.monotone c


/-- **Closure operators are extensive**: x ≤ c(x).
Every element is contained in its closure. -/
theorem closure_extensive {α : Type*} [PartialOrder α]
    (c : ClosureOperator α) (x : α) :
    x ≤ c x :=
  ClosureOperator.le_closure c x


/-- sInf is a lower bound: a ∈ s → sInf s ≤ a. -/
theorem inf_le_of_mem {α : Type*} [CompleteSemilatticeInf α]
    {s : Set α} {a : α} (ha : a ∈ s) :
    sInf s ≤ a :=
  sInf_le ha


/-- sInf is the GREATEST lower bound: (∀ b ∈ s, a ≤ b) → a ≤ sInf s. -/
theorem le_inf_of_forall_le {α : Type*} [CompleteSemilatticeInf α]
    {s : Set α} {a : α} (h : ∀ b ∈ s, a ≤ b) :
    a ≤ sInf s :=
  le_sInf h


/-- sSup is an upper bound: a ∈ s → a ≤ sSup s. -/
theorem le_sup_of_mem {α : Type*} [CompleteSemilatticeSup α]
    {s : Set α} {a : α} (ha : a ∈ s) :
    a ≤ sSup s :=
  le_sSup ha


/-- sSup is the LEAST upper bound: (∀ b ∈ s, b ≤ a) → sSup s ≤ a. -/
theorem sup_le_of_forall_le {α : Type*} [CompleteSemilatticeSup α]
    {s : Set α} {a : α} (h : ∀ b ∈ s, b ≤ a) :
    sSup s ≤ a :=
  sSup_le h

