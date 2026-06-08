import Mathlib
import Bridges.TropicalNerode.Basic
import Bridges.TropicalNerode.Representation

/-! # Extremal Generator Decomposition and Tropical Fourier Theory

**Theorem D:** In a finite lattice, every element decomposes as a join of
join-irreducible generators — the tropical analogue of a Fourier basis.

For neural networks, join-irreducibles are "concept neurons": irreducible
behavioral modes that generate all compressed observables.
-/

noncomputable section

open Classical Finset

/-! ## Join-Irreducibility -/

/-- An element is join-irreducible if it is not bot and whenever a = b ⊔ c,
    either a = b or a = c. -/
def IsJoinIrreducible' {α : Type*} [SemilatticeSup α] [OrderBot α] (a : α) : Prop :=
  a ≠ ⊥ ∧ ∀ b c : α, a = b ⊔ c → a = b ∨ a = c

/-- The set of join-irreducible elements. -/
def joinIrreducibles' (α : Type*) [SemilatticeSup α] [OrderBot α]
    [Fintype α] [DecidableEq α] [DecidablePred (IsJoinIrreducible' (α := α))] : Finset α :=
  Finset.univ.filter (IsJoinIrreducible' (α := α))

/-- The tropical support: join-irreducibles below a given element. -/
def tropicalSupport {α : Type*} [SemilatticeSup α] [OrderBot α]
    [Fintype α] [DecidableEq α] [DecidablePred (IsJoinIrreducible' (α := α))]
    (a : α) : Finset α :=
  (joinIrreducibles' α).filter (· ≤ a)

/-! ## Key Properties -/

/-- Every join-irreducible is in its own support. -/
theorem joinIrreducible_mem_self_support {α : Type*}
    [SemilatticeSup α] [OrderBot α] [Fintype α] [DecidableEq α]
    [DecidablePred (IsJoinIrreducible' (α := α))]
    (a : α) (ha : IsJoinIrreducible' a) : a ∈ tropicalSupport a := by
  simp [tropicalSupport, joinIrreducibles', ha]

/-- Support is monotone: a ≤ b implies support(a) ⊆ support(b). -/
theorem tropicalSupport_mono {α : Type*}
    [SemilatticeSup α] [OrderBot α] [Fintype α] [DecidableEq α]
    [DecidablePred (IsJoinIrreducible' (α := α))]
    {a b : α} (h : a ≤ b) : tropicalSupport a ⊆ tropicalSupport b := by
  intro x hx
  simp [tropicalSupport, joinIrreducibles'] at hx ⊢
  exact ⟨hx.1, le_trans hx.2 h⟩

/-- The number of join-irreducibles is at most the total cardinality. -/
theorem joinIrreducibles_card_le {α : Type*}
    [SemilatticeSup α] [OrderBot α] [Fintype α] [DecidableEq α]
    [DecidablePred (IsJoinIrreducible' (α := α))] :
    (joinIrreducibles' α).card ≤ Fintype.card α :=
  card_le_card (filter_subset _ _)

/-! ## Birkhoff's Theorem for Finite Distributive Lattices -/

/-
**Theorem D (Birkhoff Decomposition):** In a finite distributive lattice,
    every element is the sup of the join-irreducibles below it.

    This is the tropical Fourier decomposition theorem.
-/
theorem sup_joinIrreducibles_below {α : Type*}
    [DistribLattice α] [OrderBot α] [Fintype α] [DecidableEq α]
    [DecidablePred (IsJoinIrreducible' (α := α))]
    (a : α) : (tropicalSupport a).sup id = a := by
  -- This is essentially Birkhoff's representation theorem for finite distributive lattices. In a finite lattice, every element a equals the sup of all join-irreducible elements below it.
  have h_birkhoff : ∀ a : α, ∃ (s : Finset α), (∀ x ∈ s, IsJoinIrreducible' x) ∧ (∀ x ∈ s, x ≤ a) ∧ a = s.sup id := by
    intro a;
    induction' a using WellFoundedLT.induction with a ih;
    by_cases ha : IsJoinIrreducible' a;
    · exact ⟨ { a }, by simpa using ha ⟩;
    · by_cases ha_bot : a = ⊥;
      · exact ⟨ ∅, by simp +decide [ ha_bot ] ⟩;
      · obtain ⟨b, c, hb, hc, habc⟩ : ∃ b c : α, b < a ∧ c < a ∧ a = b ⊔ c := by
          unfold IsJoinIrreducible' at ha; aesop;
        grind +revert;
  obtain ⟨ s, hs₁, hs₂, hs₃ ⟩ := h_birkhoff a; rw [ hs₃ ] ;
  refine' le_antisymm _ _;
  · simp +decide [ tropicalSupport ];
  · exact Finset.sup_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hs₁ x hx ⟩, Finset.le_sup ( f := id ) hx ⟩

/-! ## Tropical Compression Certificate -/

/-- A compression certificate: an element with its irreducible support. -/
structure TropicalCompressionCert (α : Type*) [SemilatticeSup α] [OrderBot α] where
  element : α
  support : Finset α
  all_irreducible : ∀ x ∈ support, IsJoinIrreducible' x
  all_below : ∀ x ∈ support, x ≤ element

def TropicalCompressionCert.size {α : Type*} [SemilatticeSup α] [OrderBot α]
    (cert : TropicalCompressionCert α) : ℕ :=
  cert.support.card

/-- Build a compression certificate for any element. -/
def mkCompressionCert {α : Type*} [SemilatticeSup α] [OrderBot α]
    [Fintype α] [DecidableEq α] [DecidablePred (IsJoinIrreducible' (α := α))]
    (a : α) : TropicalCompressionCert α where
  element := a
  support := tropicalSupport a
  all_irreducible := by
    intro x hx
    simp [tropicalSupport, joinIrreducibles'] at hx
    exact hx.1
  all_below := by
    intro x hx
    simp [tropicalSupport] at hx
    exact hx.2

/-! ## Idempotent Tropical Semiring Connection -/

/-- In an idempotent additive monoid, `a + a = a` for all a.
    This makes addition behave like join/max. -/
class IdempotentAdd (α : Type*) [Add α] : Prop where
  add_idem : ∀ a : α, a + a = a

/-- The max operation on linearly ordered types is idempotent. -/
theorem tropical_max_idem {α : Type*} [LinearOrder α] (a : α) : max a a = a := max_self a

/-- The min operation on linearly ordered types is idempotent. -/
theorem tropical_min_idem {α : Type*} [LinearOrder α] (a : α) : min a a = a := min_self a

/-- Tropical distributivity (max-plus): a + max(b,c) = max(a+b, a+c). -/
theorem tropical_max_distrib (a b c : ℤ) :
    a + max b c = max (a + b) (a + c) :=
  (max_add_add_left a b c).symm

/-- Tropical distributivity (min-plus): a + min(b,c) = min(a+b, a+c). -/
theorem tropical_min_distrib (a b c : ℤ) :
    a + min b c = min (a + b) (a + c) :=
  (min_add_add_left a b c).symm

end