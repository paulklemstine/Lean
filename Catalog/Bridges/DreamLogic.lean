/-
  # Dream Logic: Non-Monotone Reasoning Where Contradictions Coexist

  We formalize Belnap's four-valued logic (FOUR) as a De Morgan algebra and prove
  it is paraconsistent: contradictions exist but do not entail everything.
  We define "dream spaces" — pre-topological structures not closed under
  arbitrary unions — and prove a concrete non-topological one exists.

  ## Main results

  1. `Belnap.instDistribLattice` — FOUR (truth ordering) is a bounded
     distributive lattice
  2. `Belnap.explosion_fails` — explosion (p ∧ ¬p → q) fails
  3. `DreamSpace.nat_finite_is_nonTopological` — a non-trivial dream space
     exists on ℕ
  4. `Belnap.paraconsistency_iff_glut` — paraconsistency ↔ existence of
     designated gluts
-/
import Mathlib

-- ============================================================================
-- SECTION 1: Belnap's Four-Valued Logic
-- ============================================================================

/-- The four truth values of Belnap's logic FOUR. -/
inductive Belnap : Type where
  | F : Belnap  -- false only
  | N : Belnap  -- neither true nor false (gap)
  | B : Belnap  -- both true and false (glut)
  | T : Belnap  -- true only
  deriving DecidableEq, Repr

namespace Belnap

/-- Truth-ordering meet (logical conjunction).
  Truth ordering: F ≤ {N,B} ≤ T (diamond). -/
def tmeet : Belnap → Belnap → Belnap
  | F, _ => F | _, F => F
  | T, x => x | x, T => x
  | N, N => N | B, B => B
  | N, B => F | B, N => F

/-- Truth-ordering join (logical disjunction). -/
def tjoin : Belnap → Belnap → Belnap
  | T, _ => T | _, T => T
  | F, x => x | x, F => x
  | N, N => N | B, B => B
  | N, B => T | B, N => T

/-- Truth ordering: a ≤ b iff tmeet a b = a -/
instance : LE Belnap := ⟨fun a b => tmeet a b = a⟩
instance : LT Belnap where lt a b := a ≤ b ∧ ¬(b ≤ a)
instance : DecidableRel (· ≤ · : Belnap → Belnap → Prop) :=
  fun a b => inferInstanceAs (Decidable (tmeet a b = a))

-- ============================================================================
-- SECTION 2: Bounded Distributive Lattice
-- ============================================================================

-- !-- All axioms verified by exhaustive case analysis over 4 values.
--     The truth-ordering diamond F-{N,B}-T is a non-chain bounded
--     distributive lattice. -- !--

instance instLattice : Lattice Belnap where
  sup := tjoin
  inf := tmeet
  le_refl := by intro a; cases a <;> rfl
  le_trans := by intro a b c; cases a <;> cases b <;> cases c <;> simp [LE.le, tmeet]
  le_antisymm := by intro a b; cases a <;> cases b <;> simp [LE.le, tmeet]
  inf_le_left := by intro a b; cases a <;> cases b <;> rfl
  inf_le_right := by
    intro a b; show tmeet (tmeet a b) b = tmeet a b
    cases a <;> cases b <;> rfl
  le_inf := by intro a b c; cases a <;> cases b <;> cases c <;> simp [LE.le, tmeet]
  le_sup_left := by
    intro a b; show tmeet a (tjoin a b) = a; cases a <;> cases b <;> rfl
  le_sup_right := by
    intro a b; show tmeet b (tjoin a b) = b; cases a <;> cases b <;> rfl
  sup_le := by
    intro a b c
    show tmeet a c = a → tmeet b c = b → tmeet (tjoin a b) c = tjoin a b
    cases a <;> cases b <;> cases c <;> simp [tmeet, tjoin]

/-- **Theorem 1**: Belnap's FOUR is a bounded distributive lattice
  under the truth ordering. -/
instance instDistribLattice : DistribLattice Belnap where
  le_sup_inf := by
    intro a b c
    show tmeet (tmeet (tjoin a b) (tjoin a c)) (tjoin a (tmeet b c)) =
         tmeet (tjoin a b) (tjoin a c)
    cases a <;> cases b <;> cases c <;> rfl

instance : BoundedOrder Belnap where
  top := T
  bot := F
  le_top := by intro a; show tmeet a T = a; cases a <;> rfl
  bot_le := by intro a; show tmeet F a = F; cases a <;> rfl

-- ============================================================================
-- SECTION 3: Negation and De Morgan Laws
-- ============================================================================

/-- Negation: swaps T↔F, fixes B and N. -/
def bneg : Belnap → Belnap
  | T => F | F => T | B => B | N => N

/-- A value is "designated" (accepted as true) if it is T or B. -/
def designated (a : Belnap) : Prop := a = T ∨ a = B

instance decidableDesignated : DecidablePred designated :=
  fun a => by cases a <;> simp only [designated] <;> exact instDecidableOr

-- !-- Belnap negation is a De Morgan involution on the truth ordering:
--     it reverses ≤, is involutive, and satisfies both De Morgan laws.
--     This is the key algebraic structure making FOUR a De Morgan algebra. -- !--

@[simp] theorem bneg_bneg (a : Belnap) : bneg (bneg a) = a := by cases a <;> rfl

/-- De Morgan: ¬(a ∧ b) = ¬a ∨ ¬b -/
theorem bneg_tmeet (a b : Belnap) : bneg (tmeet a b) = tjoin (bneg a) (bneg b) := by
  cases a <;> cases b <;> rfl

/-- De Morgan: ¬(a ∨ b) = ¬a ∧ ¬b -/
theorem bneg_tjoin (a b : Belnap) : bneg (tjoin a b) = tmeet (bneg a) (bneg b) := by
  cases a <;> cases b <;> rfl

/-- Negation reverses the truth ordering. -/
theorem bneg_antitone (a b : Belnap) (h : a ≤ b) : bneg b ≤ bneg a := by
  show tmeet (bneg b) (bneg a) = bneg b
  have h' : tmeet a b = a := h
  cases a <;> cases b <;> simp_all [tmeet, bneg]

-- ============================================================================
-- SECTION 4: Explosion Fails (Paraconsistency)
-- ============================================================================

-- !-- In classical {T,F} logic, p ∧ ¬p is always F (non-designated), so
--     "from contradiction anything follows" holds vacuously. In FOUR,
--     B ∧ ¬B = B ∧ B = B is designated, yet F is not. Explosion fails. -- !--

/-- **Theorem 2**: Explosion fails in Belnap logic.
  There exist p, q with p ∧ ¬p designated but q not designated. -/
theorem explosion_fails :
    ∃ (p q : Belnap), designated (tmeet p (bneg p)) ∧ ¬designated q := by
  exact ⟨B, F, Or.inr rfl, by simp [designated]⟩

/-- In classical 2-valued logic, contradictions are never designated. -/
theorem classical_no_contradiction :
    ∀ p : Belnap, p = T ∨ p = F → ¬designated (tmeet p (bneg p)) := by
  intro p hp; rcases hp with rfl | rfl <;> simp [bneg, tmeet, designated]

/-- The set {T, B} is closed under tmeet (conjunction preserves designation). -/
theorem designated_closed_tmeet (a b : Belnap)
    (ha : designated a) (hb : designated b) : designated (tmeet a b) := by
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;> simp [tmeet, designated]

/-- The set {T, B} is closed under tjoin (disjunction preserves designation). -/
theorem designated_closed_tjoin (a b : Belnap)
    (ha : designated a) (hb : designated b) : designated (tjoin a b) := by
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;> simp [tjoin, designated]

-- ============================================================================
-- SECTION 5: Paraconsistency Characterization
-- ============================================================================

/-- A "glut" is a value that is designated together with its negation. -/
def isGlut (a : Belnap) : Prop := designated a ∧ designated (bneg a)

/-- B is the unique glut in Belnap logic. -/
theorem glut_iff_B (a : Belnap) : isGlut a ↔ a = B := by
  cases a <;> simp [isGlut, designated, bneg]

/-- A "gap" is a value where neither it nor its negation is designated. -/
def isGap (a : Belnap) : Prop := ¬designated a ∧ ¬designated (bneg a)

/-- N is the unique gap in Belnap logic. -/
theorem gap_iff_N (a : Belnap) : isGap a ↔ a = N := by
  cases a <;> simp [isGap, designated, bneg]

/-- **Theorem 3**: Paraconsistency (explosion failure) is equivalent to
  existence of a designated glut. -/
theorem paraconsistency_iff_glut :
    (∃ p q : Belnap, designated (tmeet p (bneg p)) ∧ ¬designated q) ↔
    (∃ a : Belnap, isGlut a) := by
  constructor
  · rintro ⟨p, _, hd, _⟩
    refine ⟨p, ?_⟩
    constructor
    · cases p <;> simp_all [tmeet, bneg, designated]
    · cases p <;> simp_all [tmeet, bneg, designated]
  · rintro ⟨a, hga⟩
    refine ⟨a, F, ?_, by simp [designated]⟩
    rw [glut_iff_B] at hga; subst hga; simp [tmeet, bneg, designated]

end Belnap

-- ============================================================================
-- SECTION 6: Dream Spaces
-- ============================================================================

/-- A **dream space** is a set with a collection of "open" sets closed under
  finite intersection and pairwise union, containing ∅ and univ.
  Strictly weaker than a topology (no arbitrary union closure). -/
structure DreamSpace (X : Type*) where
  isOpen : Set X → Prop
  isOpen_univ : isOpen Set.univ
  isOpen_empty : isOpen ∅
  isOpen_inter : ∀ s t, isOpen s → isOpen t → isOpen (s ∩ t)
  isOpen_union_pair : ∀ s t, isOpen s → isOpen t → isOpen (s ∪ t)

/-- A dream space is **non-topological** if some indexed family of opens
  has a non-open union. -/
def DreamSpace.isNonTopological {X : Type*} (d : DreamSpace X) : Prop :=
  ∃ (ι : Type) (f : ι → Set X), (∀ i, d.isOpen (f i)) ∧ ¬d.isOpen (⋃ i, f i)

/-- Every topological space is a dream space. -/
def DreamSpace.ofTopologicalSpace (X : Type*) [TopologicalSpace X] : DreamSpace X where
  isOpen := IsOpen
  isOpen_univ := _root_.isOpen_univ
  isOpen_empty := _root_.isOpen_empty
  isOpen_inter := fun _ _ hs ht => hs.inter ht
  isOpen_union_pair := fun _ _ hs ht => hs.union ht

-- ============================================================================
-- SECTION 7: The Finite-or-Univ Dream Space on ℕ
-- ============================================================================

/-- A set of naturals is "dream-open" if it is finite or equal to univ. -/
def natDreamOpen (s : Set ℕ) : Prop := s.Finite ∨ s = Set.univ

private theorem natDreamOpen_inter (s t : Set ℕ)
    (hs : natDreamOpen s) (ht : natDreamOpen t) : natDreamOpen (s ∩ t) := by
  rcases hs with hs | rfl <;> rcases ht with ht | rfl
  · exact Or.inl (hs.inter_of_left t)
  · simp; exact Or.inl hs
  · simp; exact Or.inl ht
  · exact Or.inr (Set.inter_self _)

private theorem natDreamOpen_union (s t : Set ℕ)
    (hs : natDreamOpen s) (ht : natDreamOpen t) : natDreamOpen (s ∪ t) := by
  rcases hs with hs | rfl <;> rcases ht with ht | rfl
  · exact Or.inl (hs.union ht)
  · exact Or.inr (Set.union_univ s)
  · exact Or.inr (Set.univ_union t)
  · exact Or.inr (Set.union_self _)

/-- The finite-or-univ dream space on ℕ. -/
def dreamNat : DreamSpace ℕ where
  isOpen := natDreamOpen
  isOpen_univ := Or.inr rfl
  isOpen_empty := Or.inl Set.finite_empty
  isOpen_inter := natDreamOpen_inter
  isOpen_union_pair := natDreamOpen_union

-- !-- Each singleton {2n} is finite hence open, but their union (the even
--     numbers) is infinite and ≠ ℕ. This witnesses the failure of arbitrary
--     union closure, making this dream space genuinely non-topological. -- !--

/-- The even numbers are infinite. -/
private theorem evens_infinite : Set.Infinite {n : ℕ | n % 2 = 0} := by
  apply Set.infinite_of_injective_forall_mem (f := fun (n : ℕ) => 2 * n)
  · intro a b h; change 2 * a = 2 * b at h; omega
  · intro n; show 2 * n % 2 = 0; omega

/-- The even numbers are a proper subset of ℕ. -/
private theorem evens_ne_univ : {n : ℕ | n % 2 = 0} ≠ Set.univ := by
  intro h
  have : (1 : ℕ) ∈ {n : ℕ | n % 2 = 0} := h ▸ Set.mem_univ 1
  simp at this

/-- The even numbers are not dream-open. -/
theorem evens_not_dreamOpen : ¬natDreamOpen {n : ℕ | n % 2 = 0} := by
  intro h
  rcases h with hfin | huniv
  · exact evens_infinite.not_finite hfin
  · exact evens_ne_univ huniv

/-- The even numbers equal the union of singletons of even numbers. -/
private theorem evens_eq_union :
    (⋃ (n : ℕ), ({2 * n} : Set ℕ)) = {n : ℕ | n % 2 = 0} := by
  ext x; simp
  constructor
  · rintro ⟨i, rfl⟩; omega
  · intro hx; exact ⟨x / 2, by omega⟩

/-- **Theorem 4**: The finite-or-univ dream space on ℕ is non-topological.
  The singletons {2n} are all open (finite), but ⋃ₙ {2n} = evens is not. -/
theorem DreamSpace.nat_finite_is_nonTopological : dreamNat.isNonTopological := by
  refine ⟨ℕ, fun n => ({2 * n} : Set ℕ), fun i => Or.inl (Set.finite_singleton _), ?_⟩
  rw [evens_eq_union]
  exact evens_not_dreamOpen