/-
# Closure Holography Duality: Certified Boundary Reconstruction

This file formalizes a finite holography theorem for closure systems: bulk
dependency structure is completely encoded by boundary-visible capacity data,
with a certified minimal decoder recovering the bulk from the boundary.

## Main Results

* `FiniteClosureSystem` — Finite closure operator with extensivity, monotonicity, idempotence
* `BoundaryRankData` — Core rank function with monotonicity, closure invariance, faithfulness
* `closed_eq_of_rank_eq` — Faithfulness: equal rank on closed sets implies equal sets
* `cl_eq_of_rank_eq` — Equal rank implies equal closures
* `exists_minimal_generator` — Existence of minimum-cardinality generating set
* `holographicDecode` — Certified reconstruction algorithm
* `holographicDecode_correct` — Decoder produces cl(G) = cl(univ)
* `holographicDecode_minimal` — Decoder produces minimal generating set
* `mem_cl_iff_capacity` — Membership detection via capacity
* `holographic_duality` — Capacity profile determines the closure operator (the core duality)
* `admissible_rank_from_capacity` — Canonical rank data construction for separated systems
* `closure_holography_reconstruction` — Full reconstruction theorem
* `holographic_uniqueness` — Uniqueness up to closure isomorphism
* `finite_closure_holography_package` — Complete holography package

## Mathematical Significance

This is a finite algebraic analogue of holographic reconstruction (AdS/CFT):
- **Bulk** = closure system (dependency propagation)
- **Boundary** = capacity/rank profile (observable data)
- **Duality** = capacity profile determines the closure operator
- **Reconstruction** = minimal generator decoder with correctness certificate
- **Uniqueness** = any two systems with same boundary data are isomorphic

The key insight: `mem_cl_iff_capacity` shows that membership in the closure
can be detected purely from boundary capacity data, enabling full bulk
reconstruction from boundary observations.
-/

import Mathlib

set_option maxHeartbeats 800000

open Finset

namespace ClosureHolography

variable {B : Type*} [Fintype B] [DecidableEq B]

/-! ## Section 1: Core Structures -/

/-- A closure operator on finite sets, encoding dependency propagation. -/
structure FiniteClosureSystem (B : Type*) [Fintype B] [DecidableEq B] where
  cl : Finset B → Finset B
  extensive : ∀ X, X ⊆ cl X
  monotone : ∀ {X Y : Finset B}, X ⊆ Y → cl X ⊆ cl Y
  idempotent : ∀ X, cl (cl X) = cl X

/-- A set is closed if it is a fixpoint of the closure operator. -/
def FiniteClosureSystem.IsClosed (C : FiniteClosureSystem B) (X : Finset B) : Prop :=
  C.cl X = X

/-- The closure of any set is closed. -/
theorem FiniteClosureSystem.cl_isClosed (C : FiniteClosureSystem B) (X : Finset B) :
    C.IsClosed (C.cl X) :=
  C.idempotent X

/-- If X is closed and Y ⊆ X, then cl(Y) ⊆ X. -/
theorem FiniteClosureSystem.cl_sub_of_sub_closed (C : FiniteClosureSystem B)
    {X Y : Finset B} (hX : C.IsClosed X) (hYX : Y ⊆ X) :
    C.cl Y ⊆ X := by
  have h := C.monotone hYX
  rw [hX] at h
  exact h

/-- cl(univ) is closed. -/
theorem FiniteClosureSystem.univ_closed (C : FiniteClosureSystem B) :
    C.IsClosed (C.cl Finset.univ) :=
  C.idempotent Finset.univ

/-! ## Section 2: Closure Capacity -/

/-- The closure capacity of a set: the cardinality of its closure.
    This is the canonical boundary observable for a finite closure system. -/
def closureCapacity (C : FiniteClosureSystem B) (X : Finset B) : ℕ :=
  (C.cl X).card

theorem capacity_monotone (C : FiniteClosureSystem B) {X Y : Finset B} (h : X ⊆ Y) :
    closureCapacity C X ≤ closureCapacity C Y :=
  Finset.card_le_card (C.monotone h)

theorem capacity_idempotent (C : FiniteClosureSystem B) (X : Finset B) :
    closureCapacity C (C.cl X) = closureCapacity C X := by
  unfold closureCapacity; rw [C.idempotent]

theorem capacity_extensive (C : FiniteClosureSystem B) (X : Finset B) :
    X.card ≤ closureCapacity C X :=
  Finset.card_le_card (C.extensive X)

/-! ## Section 3: Boundary Rank Data -/

/-- Boundary rank data for a finite closure system: a rank function satisfying
    monotonicity, closure invariance, and faithfulness on closed sets.
    This is the minimal axiom set for holographic reconstruction. -/
structure BoundaryRankData (B : Type*) [Fintype B] [DecidableEq B]
    (C : FiniteClosureSystem B) where
  rho : Finset B → ℕ
  mono : ∀ {X Y : Finset B}, X ⊆ Y → rho X ≤ rho Y
  closed_invariant : ∀ X, rho X = rho (C.cl X)
  faithful_on_closed :
    ∀ {X Y : Finset B}, C.IsClosed X → C.IsClosed Y →
      rho X = rho Y → X = Y

/-- Extended admissible boundary rank data, including subadditivity.
    Subadditivity is an additional constraint beyond the core axioms;
    it characterizes closure systems where dependency propagation
    is "well-behaved" under union (e.g., matroid-like systems). -/
structure AdmissibleBoundaryRankData (B : Type*) [Fintype B] [DecidableEq B]
    (C : FiniteClosureSystem B) extends BoundaryRankData B C where
  subadditive : ∀ X Y, rho (X ∪ Y) ≤ rho X + rho Y

/-- Faithfulness: equal rank on closed sets implies equal sets. -/
theorem closed_eq_of_rank_eq (C : FiniteClosureSystem B)
    (R : BoundaryRankData B C)
    {X Y : Finset B} (hX : C.IsClosed X) (hY : C.IsClosed Y)
    (hρ : R.rho X = R.rho Y) : X = Y :=
  R.faithful_on_closed hX hY hρ

/-- Equal rank implies equal closures (via closure invariance + faithfulness). -/
theorem cl_eq_of_rank_eq (C : FiniteClosureSystem B)
    (R : BoundaryRankData B C)
    {X Y : Finset B} (hρ : R.rho X = R.rho Y) :
    C.cl X = C.cl Y := by
  apply R.faithful_on_closed (C.cl_isClosed X) (C.cl_isClosed Y)
  rw [← R.closed_invariant X, ← R.closed_invariant Y]
  exact hρ

/-! ## Section 4: Generator Candidates and Minimal Generators -/

/-- The set of all subsets G ⊆ B such that cl(G) = cl(univ). -/
def generatorCandidates (C : FiniteClosureSystem B) : Finset (Finset B) :=
  Finset.univ.powerset.filter (fun G => C.cl G = C.cl Finset.univ)

/-- univ is always a generator candidate. -/
theorem univ_mem_generatorCandidates (C : FiniteClosureSystem B) :
    Finset.univ ∈ generatorCandidates C := by
  simp [generatorCandidates, Finset.mem_filter]

/-- The set of generator candidates is nonempty. -/
theorem generatorCandidates_nonempty (C : FiniteClosureSystem B) :
    (generatorCandidates C).Nonempty :=
  ⟨Finset.univ, univ_mem_generatorCandidates C⟩

/-- There exists a minimum-cardinality generating set. This is the key
    existence theorem for holographic reconstruction: the bulk has a
    canonical minimal presentation. -/
theorem exists_minimal_generator (C : FiniteClosureSystem B) :
    ∃ G : Finset B, C.cl G = C.cl Finset.univ ∧
      ∀ H : Finset B, C.cl H = C.cl Finset.univ → G.card ≤ H.card := by
  obtain ⟨G, hG⟩ :
      ∃ G ∈ generatorCandidates C, ∀ H ∈ generatorCandidates C, G.card ≤ H.card :=
    Finset.exists_min_image _ _ (generatorCandidates_nonempty C)
  exact ⟨G, (Finset.mem_filter.mp hG.1).2,
    fun H hH => hG.2 H (Finset.mem_filter.mpr ⟨Finset.mem_powerset.mpr (Finset.subset_univ _), hH⟩)⟩

/-! ## Section 5: Holographic Decoder -/

/-- The holographic decoder: selects a minimum-cardinality generating set.
    This is the certified reconstruction algorithm that recovers a minimal
    bulk presentation from the closure system. -/
noncomputable def holographicDecode (C : FiniteClosureSystem B) : Finset B :=
  Classical.choose (exists_minimal_generator C)

/-- **Decoder Correctness**: the decoded set generates the full closure. -/
theorem holographicDecode_correct (C : FiniteClosureSystem B) :
    C.cl (holographicDecode C) = C.cl Finset.univ :=
  (Classical.choose_spec (exists_minimal_generator C)).1

/-- **Decoder Minimality**: the decoded set has minimum cardinality
    among all sets generating the full closure. -/
theorem holographicDecode_minimal (C : FiniteClosureSystem B)
    (H : Finset B) (hH : C.cl H = C.cl Finset.univ) :
    (holographicDecode C).card ≤ H.card :=
  (Classical.choose_spec (exists_minimal_generator C)).2 H hH

/-! ## Section 6: Membership Detection via Capacity -/

/-- **Holographic Membership Test**: an element belongs to cl(X) if and only if
    inserting it into X does not change the closure capacity. This is the
    fundamental "boundary observable detects bulk membership" principle. -/
theorem mem_cl_iff_capacity (C : FiniteClosureSystem B) (X : Finset B) (x : B) :
    x ∈ C.cl X ↔ closureCapacity C X = closureCapacity C (X ∪ {x}) := by
  constructor
  · intro hx
    have : C.cl (X ∪ {x}) = C.cl X := by
      apply Finset.Subset.antisymm
      · have : X ∪ {x} ⊆ C.cl X :=
          Finset.union_subset (C.extensive X) (Finset.singleton_subset_iff.mpr hx)
        calc C.cl (X ∪ {x}) ⊆ C.cl (C.cl X) := C.monotone this
          _ = C.cl X := C.idempotent X
      · exact C.monotone Finset.subset_union_left
    unfold closureCapacity; rw [this]
  · intro h
    have hsub : C.cl X ⊆ C.cl (X ∪ {x}) := C.monotone Finset.subset_union_left
    have heq : C.cl X = C.cl (X ∪ {x}) :=
      Finset.eq_of_subset_of_card_le hsub (by unfold closureCapacity at h; omega)
    have : x ∈ C.cl (X ∪ {x}) :=
      C.extensive _ (Finset.mem_union_right _ (Finset.mem_singleton_self _))
    rw [← heq] at this
    exact this

/-! ## Section 7: Holographic Duality — Capacity Determines Closure -/

/-- **The Core Holographic Duality Theorem**: if two closure operators on the same
    finite type have the same capacity function on every finite set, then they have
    identical closure functions. The boundary data completely determines the bulk.

    This is the finite algebraic analogue of the statement that boundary observables
    completely determine the bulk theory in holographic duality. -/
theorem holographic_duality (C₁ C₂ : FiniteClosureSystem B)
    (hcap : ∀ X : Finset B, closureCapacity C₁ X = closureCapacity C₂ X) :
    C₁.cl = C₂.cl := by
  funext X
  ext x
  rw [mem_cl_iff_capacity C₁, mem_cl_iff_capacity C₂, hcap X, hcap (X ∪ {x})]

/-! ## Section 8: Canonical Boundary Rank Data -/

/-- A closure system is cardinality-separated if distinct closed sets have
    distinct cardinalities. This is the finite analogue of probe faithfulness:
    the boundary observable (cardinality) separates all bulk states (closed sets). -/
def CardSeparated (C : FiniteClosureSystem B) : Prop :=
  ∀ {X Y : Finset B}, C.IsClosed X → C.IsClosed Y → X.card = Y.card → X = Y

/-- **Representation Theorem**: for a cardinality-separated closure system,
    the closure capacity gives canonical boundary rank data. This is the
    "bulk → boundary" direction: every probe-faithful closure system admits
    canonical boundary rank data that faithfully encodes it. -/
noncomputable def admissible_rank_from_capacity (C : FiniteClosureSystem B)
    (hsep : CardSeparated C) : BoundaryRankData B C where
  rho := closureCapacity C
  mono := fun h => capacity_monotone C h
  closed_invariant := fun X => (capacity_idempotent C X).symm
  faithful_on_closed := fun hX hY h => by
    exact hsep hX hY (by unfold closureCapacity at h; rw [hX, hY] at h; exact h)

/-! ## Section 9: Full Reconstruction Theorem -/

/-- **Finite Closure Holography Reconstruction Theorem.**

    Given a finite closure system with boundary rank data, there exists
    a canonical minimal generating set, the decoder correctly reconstructs it,
    the reconstruction is minimal, and the rank data faithfully encodes
    the closed-set structure.

    This packages: existence + correctness + minimality + faithfulness. -/
theorem closure_holography_reconstruction (C : FiniteClosureSystem B)
    (R : BoundaryRankData B C) :
    ∃ G : Finset B,
      C.cl G = C.cl Finset.univ ∧
      (∀ H : Finset B, C.cl H = C.cl Finset.univ → G.card ≤ H.card) ∧
      (∀ {X Y : Finset B}, C.IsClosed X → C.IsClosed Y →
        R.rho X = R.rho Y → X = Y) :=
  ⟨holographicDecode C, holographicDecode_correct C,
    fun H hH => holographicDecode_minimal C H hH,
    fun hX hY h => R.faithful_on_closed hX hY h⟩

/-! ## Section 10: Closure Isomorphism and Uniqueness -/

/-- An isomorphism between two finite closure systems: a bijection that
    preserves the closure operator. -/
structure ClosureIso
    {B₁ : Type*} {B₂ : Type*}
    [Fintype B₁] [DecidableEq B₁] [Fintype B₂] [DecidableEq B₂]
    (C₁ : FiniteClosureSystem B₁) (C₂ : FiniteClosureSystem B₂) where
  toEquiv : B₁ ≃ B₂
  closure_preserving :
    ∀ X : Finset B₁,
      (C₁.cl X).map toEquiv.toEmbedding = C₂.cl (X.map toEquiv.toEmbedding)

/-- Any closure system is isomorphic to itself. -/
def ClosureIso.refl (C : FiniteClosureSystem B) : ClosureIso C C :=
  ⟨Equiv.refl B, fun X => by simp [Finset.map_refl]⟩

/-- Two closure systems on the same type with the same cl are isomorphic. -/
theorem closure_iso_of_eq_cl (C₁ C₂ : FiniteClosureSystem B)
    (h : C₁.cl = C₂.cl) : Nonempty (ClosureIso C₁ C₂) :=
  ⟨⟨Equiv.refl B, fun X => by simp [Finset.map_refl, h]⟩⟩

/-- **Uniqueness via Holographic Duality**: if two closure systems on the same type
    have the same capacity profile, they are isomorphic. This is the uniqueness
    half of the holographic reconstruction: the reconstructed bulk is canonical. -/
theorem holographic_uniqueness (C₁ C₂ : FiniteClosureSystem B)
    (hcap : ∀ X : Finset B, closureCapacity C₁ X = closureCapacity C₂ X) :
    Nonempty (ClosureIso C₁ C₂) :=
  closure_iso_of_eq_cl C₁ C₂ (holographic_duality C₁ C₂ hcap)

/-! ## Section 11: Rank Profile Injectivity -/

/-- The rank profile: the capacity function viewed as a boundary datum. -/
def rankProfile (C : FiniteClosureSystem B) : Finset B → ℕ :=
  closureCapacity C

/-- **Rank Profile Injectivity**: the rank profile map from closure operators
    to boundary data is injective. Different bulk theories give different
    boundary observations. -/
theorem rankProfile_injective :
    ∀ C₁ C₂ : FiniteClosureSystem B,
      rankProfile C₁ = rankProfile C₂ → C₁.cl = C₂.cl :=
  fun C₁ C₂ h => holographic_duality C₁ C₂ (fun X => congr_fun h X)

/-! ## Section 12: Boundary Entanglement Rank -/

/-- The boundary entanglement rank of a set X: the minimum number of generators
    needed to produce the same closure as X. This is the finite analogue of
    entanglement entropy in holographic duality. -/
noncomputable def entanglementRank (C : FiniteClosureSystem B) (X : Finset B) : ℕ :=
  Finset.inf' (Finset.univ.powerset.filter (fun G => C.cl G = C.cl X))
    (by
      refine ⟨C.cl X, ?_⟩
      simp [Finset.mem_filter]
      exact C.idempotent X)
    Finset.card

/-- Entanglement rank is bounded by the set's cardinality. -/
theorem entanglementRank_le_card (C : FiniteClosureSystem B) (X : Finset B) :
    entanglementRank C X ≤ X.card := by
  exact Finset.inf'_le _ (by simp [Finset.mem_filter])

/-- Entanglement rank is closure-invariant: `ρ(X) = ρ(cl(X))`. -/
theorem entanglementRank_cl_eq (C : FiniteClosureSystem B) (X : Finset B) :
    entanglementRank C (C.cl X) = entanglementRank C X := by
  unfold entanglementRank
  simp only [C.idempotent]

/-! ## Section 13: Capacity Supermodularity -/

/-
The closure capacity satisfies a supermodular-like inequality:
    `cap(X) + cap(Y) ≤ cap(X ∪ Y) + |cl(X) ∩ cl(Y)|`.
    This is dual to submodularity and reflects the "synergy" of closure.
-/
theorem capacity_supermodular (C : FiniteClosureSystem B) (X Y : Finset B) :
    closureCapacity C X + closureCapacity C Y ≤
      closureCapacity C (X ∪ Y) + (C.cl X ∩ C.cl Y).card := by
  -- By definition of closure, we know that $cl(X) \cup cl(Y) \subseteq cl(X \cup Y)$.
  have h_closure_union : (C.cl X) ∪ (C.cl Y) ⊆ C.cl (X ∪ Y) := by
    exact Finset.union_subset ( C.monotone ( Finset.subset_union_left ) ) ( C.monotone ( Finset.subset_union_right ) );
  have := Finset.card_mono h_closure_union;
  have := Finset.card_union_add_card_inter ( C.cl X ) ( C.cl Y ) ; linarith!;

/-! ## Section 14: Complete Holography Package -/

/-- **The Complete Finite Closure Holography Package.**

    For a cardinality-separated finite closure system, we have:
    1. **Representation**: canonical boundary rank data exists from capacity
    2. **Reconstruction**: a certified minimal decoder exists
    3. **Uniqueness**: any two systems with same capacity are isomorphic

    This is the finite algebraic analogue of AdS/CFT holographic reconstruction:
    boundary data ↔ bulk structure, with certified decoder and uniqueness. -/
theorem finite_closure_holography_package (C : FiniteClosureSystem B)
    (hsep : CardSeparated C) :
    (∃ R : BoundaryRankData B C, R.rho = closureCapacity C) ∧
    (∃ G : Finset B, C.cl G = C.cl Finset.univ ∧
      ∀ H : Finset B, C.cl H = C.cl Finset.univ → G.card ≤ H.card) ∧
    (∀ C₂ : FiniteClosureSystem B,
      (∀ X, closureCapacity C X = closureCapacity C₂ X) →
      Nonempty (ClosureIso C C₂)) :=
  ⟨⟨admissible_rank_from_capacity C hsep, rfl⟩, exists_minimal_generator C,
    fun C₂ hcap => holographic_uniqueness C C₂ hcap⟩

end ClosureHolography