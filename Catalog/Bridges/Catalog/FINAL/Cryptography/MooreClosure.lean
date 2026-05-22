/-
# Moore Family Closure Operator

This file formalizes the Moore family theorem: given a predicate `Closed : Set α → Prop`
that is preserved by arbitrary intersections and holds for `univ`, the hull
`mooreClosure Closed A = ⋂₀ {s | Closed s ∧ A ⊆ s}` defines a closure operator,
and the closed sets form a complete lattice under inclusion.

## Main results

* `mooreClosure_extensive` — `A ⊆ mooreClosure Closed A`
* `mooreClosure_closed` — `Closed (mooreClosure Closed A)`
* `mooreClosure_minimal` — if `Closed B` and `A ⊆ B` then `mooreClosure Closed A ⊆ B`
* `mooreClosure_mono` — monotonicity of the closure operator
* `mooreClosure_idempotent` — `mooreClosure Closed (mooreClosure Closed A) = mooreClosure Closed A`
* `mooreClosure_eq_iff` — `mooreClosure Closed A = A ↔ Closed A`
* `fixedPoints_sInter_closed` — fixed points of a closure operator are closed under `⋂₀`
* `mooreClosedSetsCompleteLattice` — the subtype of closed sets is a `CompleteLattice`

## Concrete instantiation

* `ClosedMulId` — multiplicatively closed matrix classes containing the identity
* `closedMulId_univ`, `closedMulId_sInter` — Moore family axioms for `ClosedMulId`
-/
import Mathlib

open Set

/-! ## Definition of Moore closure -/

/-- The Moore closure of a set `A` with respect to a closedness predicate:
    the intersection of all closed supersets of `A`. -/
def mooreClosure {α : Type*} (Closed : Set α → Prop) (A : Set α) : Set α :=
  ⋂₀ {s : Set α | Closed s ∧ A ⊆ s}

/-! ## Core closure operator properties -/

/-
The Moore closure is extensive: `A ⊆ mooreClosure Closed A`.
-/
theorem mooreClosure_extensive
    {α : Type*} {Closed : Set α → Prop}
    (_h_univ : Closed Set.univ)
    (_h_sInter : ∀ S : Set (Set α), (∀ s ∈ S, Closed s) → Closed (⋂₀ S))
    (A : Set α) :
    A ⊆ mooreClosure Closed A := by
      intro x hxA
      simp [mooreClosure]
      exact fun t _ htA => htA hxA

/-
The Moore closure of any set is closed.
-/
theorem mooreClosure_closed
    {α : Type*} {Closed : Set α → Prop}
    (_h_univ : Closed Set.univ)
    (h_sInter : ∀ S : Set (Set α), (∀ s ∈ S, Closed s) → Closed (⋂₀ S))
    (A : Set α) :
    Closed (mooreClosure Closed A) := by
      exact h_sInter _ fun s hs => hs.1

/-
The Moore closure is the smallest closed superset.
-/
theorem mooreClosure_minimal
    {α : Type*} {Closed : Set α → Prop}
    (_h_univ : Closed Set.univ)
    (_h_sInter : ∀ S : Set (Set α), (∀ s ∈ S, Closed s) → Closed (⋂₀ S))
    {A B : Set α} (hB : Closed B) (hAB : A ⊆ B) :
    mooreClosure Closed A ⊆ B := by
      exact Set.sInter_subset_of_mem ⟨ hB, hAB ⟩

/-
The Moore closure is idempotent.
-/
theorem mooreClosure_idempotent
    {α : Type*} {Closed : Set α → Prop}
    (h_univ : Closed Set.univ)
    (h_sInter : ∀ S : Set (Set α), (∀ s ∈ S, Closed s) → Closed (⋂₀ S))
    (A : Set α) :
    mooreClosure Closed (mooreClosure Closed A) = mooreClosure Closed A := by
      -- Apply the mooreClosure_minimal theorem with B=mooreClosure Closed A and use mooreClosure_closed.
      apply subset_antisymm;
      · exact mooreClosure_minimal h_univ h_sInter (mooreClosure_closed h_univ h_sInter A)
          (le_refl _)
      · exact mooreClosure_extensive h_univ h_sInter (mooreClosure Closed A)

/-
The Moore closure is monotone.
-/
theorem mooreClosure_mono
    {α : Type*} {Closed : Set α → Prop}
    (_h_univ : Closed Set.univ)
    (_h_sInter : ∀ S : Set (Set α), (∀ s ∈ S, Closed s) → Closed (⋂₀ S))
    {A B : Set α} (hAB : A ⊆ B) :
    mooreClosure Closed A ⊆ mooreClosure Closed B := by
      exact Set.sInter_subset_sInter fun s hs => ⟨ hs.1, hAB.trans hs.2 ⟩

/-! ## Fixed-point characterization -/

/-
A set is closed if and only if it equals its own Moore closure.
-/
theorem mooreClosure_eq_iff
    {α : Type*} {Closed : Set α → Prop}
    (_h_univ : Closed Set.univ)
    (h_sInter : ∀ S : Set (Set α), (∀ s ∈ S, Closed s) → Closed (⋂₀ S))
    {A : Set α} :
    mooreClosure Closed A = A ↔ Closed A := by
      grind +locals

/-! ## Galois-style minimality: fixed points of a closure operator form a Moore family -/

/-
If `c` is an extensive, monotone, idempotent operator, then the family of its
    fixed points (`c s = s`) is closed under arbitrary intersections.
-/
theorem fixedPoints_sInter_closed
    {α : Type*} (c : Set α → Set α)
    (h_ext : ∀ A, A ⊆ c A)
    (h_mono : Monotone c)
    (_h_idem : ∀ A, c (c A) = c A) :
    ∀ S : Set (Set α), (∀ s ∈ S, c s = s) → c (⋂₀ S) = ⋂₀ S := by
      intro S hS;
      refine' Set.Subset.antisymm _ _;
      · exact Set.subset_sInter fun s hs => h_mono ( Set.sInter_subset_of_mem hs ) |> Set.Subset.trans <| by aesop;
      · exact h_ext _

/-! ## Complete lattice on the subtype of Moore-closed sets -/

/-- The subtype of sets satisfying a Moore-closedness predicate. -/
def MooreClosedSets (α : Type*) (Closed : Set α → Prop) :=
  {s : Set α // Closed s}

/-- The Moore-closed sets form a complete lattice.
    The infimum is given by set intersection, and the supremum by Moore closure of the union. -/
noncomputable def mooreClosedSetsCompleteLattice
    {α : Type*} {Closed : Set α → Prop}
    (_h_univ : Closed Set.univ)
    (h_sInter : ∀ S : Set (Set α), (∀ s ∈ S, Closed s) → Closed (⋂₀ S)) :
    CompleteLattice (MooreClosedSets α Closed) := by
  let po : PartialOrder (MooreClosedSets α Closed) := Subtype.partialOrder _
  let infS : InfSet (MooreClosedSets α Closed) :=
    ⟨fun S => ⟨⋂₀ (Subtype.val '' S), h_sInter _ (fun s hs => by
      obtain ⟨⟨t, ht⟩, _, rfl⟩ := hs; exact ht)⟩⟩
  exact @completeLatticeOfInf _ po infS (fun S => by
    constructor
    · -- sInf S is a lower bound
      intro ⟨a, ha⟩ haS
      show (⋂₀ (Subtype.val '' S)) ⊆ a
      exact Set.sInter_subset_of_mem ⟨⟨a, ha⟩, haS, rfl⟩
    · -- sInf S is the greatest lower bound
      intro ⟨b, hb⟩ hlb
      show b ⊆ ⋂₀ (Subtype.val '' S)
      exact Set.subset_sInter (fun s hs => by
        obtain ⟨⟨t, ht⟩, htS, rfl⟩ := hs
        exact hlb htS))

/-! ## Concrete instantiation: multiplicatively closed matrix classes -/

/-- A set of 3×3 integer matrices is multiplicatively closed with identity if it
    contains the identity matrix and is closed under matrix multiplication. -/
def ClosedMulId (S : Set (Matrix (Fin 3) (Fin 3) ℤ)) : Prop :=
  (1 ∈ S) ∧ ∀ ⦃A B⦄, A ∈ S → B ∈ S → A * B ∈ S

/-
`ClosedMulId` holds for `univ`.
-/
theorem closedMulId_univ : ClosedMulId Set.univ := by
  exact ⟨ Set.mem_univ _, fun _ _ _ _ => Set.mem_univ _ ⟩

/-
`ClosedMulId` is preserved by arbitrary intersections.
-/
theorem closedMulId_sInter :
    ∀ S : Set (Set (Matrix (Fin 3) (Fin 3) ℤ)),
      (∀ s ∈ S, ClosedMulId s) → ClosedMulId (⋂₀ S) := by
        exact fun S hS => ⟨ Set.mem_sInter.2 fun s hs => hS s hs |>.1, fun A B hA hB => Set.mem_sInter.2 fun s hs => hS s hs |>.2 ( Set.mem_sInter.1 hA s hs ) ( Set.mem_sInter.1 hB s hs ) ⟩

/-- The Moore closure with respect to `ClosedMulId` gives the smallest
    multiplicatively closed set containing the identity that includes a seed set. -/
theorem closedMulId_mooreClosure_closed (A : Set (Matrix (Fin 3) (Fin 3) ℤ)) :
    ClosedMulId (mooreClosure ClosedMulId A) :=
  mooreClosure_closed closedMulId_univ closedMulId_sInter A

/-- Any seed set is contained in its multiplicative closure hull. -/
theorem closedMulId_mooreClosure_extensive (A : Set (Matrix (Fin 3) (Fin 3) ℤ)) :
    A ⊆ mooreClosure ClosedMulId A :=
  mooreClosure_extensive closedMulId_univ closedMulId_sInter A

/-! ## Concrete instantiation: orbit-stable classes -/

/-- A set is closed under a transformation `T` if applying `T` to any member
    stays in the set. -/
def ClosedUnderT {α : Type*} (T : α → α) (S : Set α) : Prop :=
  ∀ ⦃x⦄, x ∈ S → T x ∈ S

/-
`ClosedUnderT T` holds for `univ`.
-/
theorem closedUnderT_univ {α : Type*} (T : α → α) : ClosedUnderT T Set.univ := by
  exact fun _ _ => Set.mem_univ _

/-
`ClosedUnderT T` is preserved by arbitrary intersections.
-/
theorem closedUnderT_sInter {α : Type*} (T : α → α) :
    ∀ S : Set (Set α), (∀ s ∈ S, ClosedUnderT T s) → ClosedUnderT T (⋂₀ S) := by
      exact fun S hS x hx => Set.mem_sInter.2 fun s hs => hS s hs ( Set.mem_sInter.1 hx s hs )

/-- The Moore closure with respect to `ClosedUnderT T` is the smallest `T`-stable
    superset — the orbit-saturation hull. -/
theorem closedUnderT_mooreClosure_closed {α : Type*} (T : α → α)
    (A : Set α) :
    ClosedUnderT T (mooreClosure (ClosedUnderT T) A) :=
  mooreClosure_closed (closedUnderT_univ T) (closedUnderT_sInter T) A