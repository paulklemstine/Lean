/-
# Phantom Topologies: Spaces That Change When You Look at Them

A phantom topology on a set X is a family of topologies indexed by "observers."
The consensus topology is what all observers agree on — the supremum in Mathlib's
lattice of topologies (where ≤ means "finer", ⊥ = discrete, ⊤ = indiscrete).

A set U is consensus-open iff it is open for EVERY observer.

The phantom number of a topology τ measures the minimum number of observers
whose consensus equals τ. This connects topology to lattice decomposition theory.
-/
import Mathlib

open TopologicalSpace Set

/-! ## Core Definitions -/

/-- A `PhantomSystem` on a type `X` assigns a topology to each observer in `O`.
The consensus topology is the supremum of all observer topologies: a set is
consensus-open iff every observer considers it open. -/
structure PhantomSystem (X : Type*) (O : Type*) where
  /-- Each observer sees their own topology on X -/
  observe : O → TopologicalSpace X

namespace PhantomSystem

variable {X : Type*} {O : Type*}

/-- The consensus topology: U is open iff U is open for every observer.
This is the supremum in the TopologicalSpace lattice (coarsest among those
coarser than each observer's topology). -/
noncomputable def consensus (P : PhantomSystem X O) : TopologicalSpace X :=
  ⨆ o : O, P.observe o

/-- Two observers agree on a set if it is open in both their topologies. -/
def agree (P : PhantomSystem X O) (o₁ o₂ : O) (U : Set X) : Prop :=
  @IsOpen X (P.observe o₁) U ∧ @IsOpen X (P.observe o₂) U

/-- A set is consensus-open iff it is open for every observer. -/
theorem consensus_isOpen_iff (P : PhantomSystem X O) (U : Set X) :
    @IsOpen X P.consensus U ↔ ∀ o : O, @IsOpen X (P.observe o) U := by
  simp [consensus, isOpen_iSup_iff]

/-- The consensus topology is coarser than any individual observer's topology.
In Mathlib's ordering, the consensus is ≥ each observer (has fewer open sets). -/
theorem observe_le_consensus (P : PhantomSystem X O) (o : O) :
    P.observe o ≤ P.consensus := by
  exact le_iSup P.observe o

/-- Every consensus-open set is open for each observer. -/
theorem consensus_open_implies_observer_open (P : PhantomSystem X O)
    (o : O) (U : Set X) (hU : @IsOpen X P.consensus U) :
    @IsOpen X (P.observe o) U := by
  rw [consensus_isOpen_iff] at hU
  exact hU o

end PhantomSystem

/-! ## Phantom Number -/

/-- A phantom representation of τ with n observers: n topologies whose
supremum equals τ. -/
structure PhantomRepr (X : Type*) (τ : TopologicalSpace X) (n : ℕ) where
  observers : Fin n → TopologicalSpace X
  consensus_eq : ⨆ i, observers i = τ

/-- The phantom number of a topology τ on X is the minimum n such that
τ can be expressed as the supremum of n topologies. -/
noncomputable def phantomNumber (X : Type*) (τ : TopologicalSpace X) : ℕ :=
  sInf {n : ℕ | ∃ (f : Fin n → TopologicalSpace X), ⨆ i, f i = τ}

/-! ## Lattice-Theoretic Foundations -/

/-- The supremum over Fin 1 is the single element. -/
theorem iSup_fin_one {α : Type*} [CompleteLattice α] (f : Fin 1 → α) :
    ⨆ i, f i = f 0 := by
  convert @ciSup_unique _ _ _ _ _

/-- The supremum over Fin 2 equals the join. -/
theorem iSup_fin_two {α : Type*} [CompleteLattice α] (f : Fin 2 → α) :
    ⨆ i, f i = f 0 ⊔ f 1 := by
  refine le_antisymm ?_ ?_
  · exact iSup_le fun i => by fin_cases i <;> simp
  · exact sup_le (le_iSup f 0) (le_iSup f 1)

/-! ## Two-Observer Phantom Systems -/

/-- In a two-observer system, the consensus is the join of the two topologies. -/
theorem two_observer_consensus (X : Type*) (P : PhantomSystem X (Fin 2)) :
    P.consensus = P.observe 0 ⊔ P.observe 1 := by
  convert iSup_fin_two _

/-- If all observers see the same topology, the consensus equals that topology. -/
theorem identical_observers_consensus {X O : Type*} [Nonempty O]
    (P : PhantomSystem X O) (τ : TopologicalSpace X)
    (h : ∀ o, P.observe o = τ) :
    P.consensus = τ := by
  simp [PhantomSystem.consensus, h]

/-! ## Observer Refinement and Monotonicity -/

namespace PhantomSystem

variable {X : Type*} {O : Type*}

/-- A phantom system P₁ refines P₂ if every observer in P₁ has a finer
topology than the corresponding observer in P₂. -/
def Refines (P₁ P₂ : PhantomSystem X O) : Prop :=
  ∀ o : O, P₂.observe o ≤ P₁.observe o

/-- If P₁ refines P₂ (each observer in P₁ is finer), then P₁'s consensus
is also finer (has more open sets) than P₂'s. -/
theorem refines_consensus (P₁ P₂ : PhantomSystem X O) (h : P₁.Refines P₂) :
    P₂.consensus ≤ P₁.consensus := by
  exact iSup_mono fun i => h i

/-- Adding observers can only make the consensus coarser. Extending from O to
O ⊕ O' while preserving the original observers' topologies yields a coarser
consensus. -/
theorem extend_observers_coarser
    (P : PhantomSystem X O) {O' : Type*}
    (ext : PhantomSystem X (O ⊕ O'))
    (h : ∀ o : O, ext.observe (Sum.inl o) = P.observe o) :
    P.consensus ≤ ext.consensus := by
  exact iSup_le fun o => le_iSup_of_le (Sum.inl o) (h o ▸ le_rfl)

end PhantomSystem

/-! ## Disagreement Sets -/

/-- The disagreement set of two observers: sets open for exactly one. -/
def PhantomSystem.disagreementSets {X O : Type*} (P : PhantomSystem X O)
    (o₁ o₂ : O) : Set (Set X) :=
  {U | (@IsOpen X (P.observe o₁) U ∧ ¬@IsOpen X (P.observe o₂) U) ∨
       (¬@IsOpen X (P.observe o₁) U ∧ @IsOpen X (P.observe o₂) U)}

/-- If two observers have the same topology, their disagreement set is empty. -/
theorem PhantomSystem.disagreement_empty_of_eq {X O : Type*}
    (P : PhantomSystem X O) (o₁ o₂ : O)
    (h : P.observe o₁ = P.observe o₂) :
    P.disagreementSets o₁ o₂ = ∅ := by
  ext U
  simp [h, PhantomSystem.disagreementSets]

/-- Disagreement is symmetric. -/
theorem PhantomSystem.disagreement_symm {X O : Type*}
    (P : PhantomSystem X O) (o₁ o₂ : O) :
    P.disagreementSets o₁ o₂ = P.disagreementSets o₂ o₁ := by
  ext U
  simp only [PhantomSystem.disagreementSets, mem_setOf_eq]
  tauto

/-! ## Phantom Morphisms -/

/-- A phantom morphism preserves the observer structure: the underlying map
is continuous with respect to each observer's topology. -/
structure PhantomMorphism {X Y : Type*} {O : Type*}
    (P : PhantomSystem X O) (Q : PhantomSystem Y O) where
  map : X → Y
  continuous_observe : ∀ o, @Continuous X Y (P.observe o) (Q.observe o) map

/-- A phantom morphism is automatically consensus-continuous:
if f is continuous for each observer pair, it is continuous for the consensus. -/
theorem PhantomMorphism.consensus_continuous {X Y : Type*} {O : Type*}
    {P : PhantomSystem X O} {Q : PhantomSystem Y O}
    (φ : PhantomMorphism P Q) :
    @Continuous X Y P.consensus Q.consensus φ.map := by
  rw [continuous_iff_le_induced]
  apply iSup_le
  intro o
  calc P.observe o
      ≤ TopologicalSpace.induced φ.map (Q.observe o) :=
        (φ.continuous_observe o).le_induced
    _ ≤ TopologicalSpace.induced φ.map Q.consensus :=
        induced_mono (le_iSup Q.observe o)

/-! ## Separation Axioms -/

/-- A phantom system is observer-Hausdorff if every observer sees a Hausdorff space. -/
def PhantomSystem.ObserverHausdorff {X O : Type*} (P : PhantomSystem X O) : Prop :=
  ∀ o, @T2Space X (P.observe o)

/-- If the consensus equals some observer's topology, and that observer is T2,
then the consensus is T2. -/
theorem consensus_t2_of_eq_observer {X O : Type*}
    (P : PhantomSystem X O) (o : O)
    (heq : P.consensus = P.observe o)
    (h : @T2Space X (P.observe o)) :
    @T2Space X P.consensus := by
  convert h

/-! ## Cross-Domain: Phantom Topologies ↔ Complete Lattice Decomposition

The phantom number is a purely lattice-theoretic concept: given an element a
in a complete lattice L, its "sup-decomposition number" is the minimum n
such that a = ⨆ of n elements. This connects topology to abstract algebra. -/

/-- The sup-decomposition number in an arbitrary complete lattice. -/
noncomputable def supDecompNumber {α : Type*} [CompleteLattice α] (a : α) : ℕ :=
  sInf {n : ℕ | ∃ (f : Fin n → α), ⨆ i, f i = a}

/-- Every element has sup-decomposition number at most 1 (it equals ⨆ of itself). -/
theorem supDecomp_le_one {α : Type*} [CompleteLattice α] (a : α) :
    ∃ (f : Fin 1 → α), ⨆ i, f i = a := by
  exact ⟨fun _ => a, by simp⟩

/-- An element is sup-irreducible if it cannot be expressed as a proper
join of two strictly larger elements. -/
def SupIrreducible {α : Type*} [SemilatticeSup α] (a : α) : Prop :=
  ∀ b c : α, a = b ⊔ c → a = b ∨ a = c

/-- The discrete topology (⊥) is sup-irreducible: if ⊥ = b ⊔ c then b = ⊥ or c = ⊥.
Since ⊥ is the bottom, b ⊔ c = ⊥ forces both b = ⊥ and c = ⊥. -/
theorem discrete_sup_irreducible (X : Type*) :
    SupIrreducible (⊥ : TopologicalSpace X) := by
  intro b c h
  have : b ⊔ c = ⊥ := h.symm
  rw [sup_eq_bot_iff] at this
  exact Or.inl (this.1.symm)

/-! ## Monotone Phantom Systems -/

/-- A phantom system is monotone if observer ordering refines topology ordering:
later observers have coarser topologies (fewer open sets, larger in ≤). -/
def PhantomSystem.IsMonotone {X : Type*} {O : Type*} [Preorder O]
    (P : PhantomSystem X O) : Prop :=
  ∀ o₁ o₂ : O, o₁ ≤ o₂ → P.observe o₂ ≤ P.observe o₁

/-- For a monotone phantom system with a bottom element, the consensus
equals the bottom observer's topology (the coarsest one). -/
theorem monotone_consensus_eq_bot {X : Type*} {O : Type*} [Preorder O]
    [OrderBot O] (P : PhantomSystem X O) (hmon : P.IsMonotone) :
    P.consensus = P.observe ⊥ := by
  refine le_antisymm (iSup_le ?_) (le_iSup _ _)
  exact fun o => hmon _ _ bot_le

/-! ## Restricting Observers -/

/-
Restricting to a subset of observers yields a finer consensus
(more open sets, since fewer observers need to agree).
-/
theorem restrict_observers_finer {X O : Type*}
    (P : PhantomSystem X O) (S : Set O) :
    (⨆ o : S, P.observe o) ≤ (⨆ o : O, P.observe o) := by
  refine' iSup_le _;
  exact fun i => le_iSup _ _

/-! ## Conjecture: Finite Phantom Bound

**Conjecture**: For any finite type X with n elements, every topology on X
has phantom number at most n.

**Testable prediction**: For n = 2, there are 4 topologies on {0,1}:
discrete, indiscrete, {∅, {0}, {0,1}}, {∅, {1}, {0,1}}.
Each should have phantom number ≤ 2.

This is falsifiable: find a topology on a finite set whose phantom number
exceeds the set's cardinality. -/
def FinitePhantomBoundConjecture : Prop :=
  ∀ (n : ℕ), ∀ (τ : TopologicalSpace (Fin n)),
    ∃ (f : Fin n → TopologicalSpace (Fin n)), ⨆ i, f i = τ

/-! ## Phantom Systems and Galois Connections -/

/-- If every topology in a family g is also in a family f, then the
supremum of f is at least the supremum of g (in terms of open sets). -/
theorem consensus_antitone {X : Type*} {O₁ O₂ : Type*}
    (f : O₁ → TopologicalSpace X) (g : O₂ → TopologicalSpace X)
    (h : ∀ τ, (∃ o₁, f o₁ = τ) → (∃ o₂, g o₂ = τ))
    (_hsurj : ∀ o₂, ∃ o₁, g o₂ = f o₁) :
    ⨆ o₁, f o₁ ≤ ⨆ o₂, g o₂ := by
  apply iSup_le
  intro o
  obtain ⟨o₂, ho₂⟩ := h _ ⟨o, rfl⟩
  exact le_iSup_of_le o₂ (by rw [ho₂])

/-! ## Three-Observer Characterization

For three observers, the consensus topology is the three-way meet. This
gives a "triangulation" of the topology by three viewpoints. -/

/-
The supremum over Fin 3 equals the three-way join.
-/
theorem iSup_fin_three {α : Type*} [CompleteLattice α] (f : Fin 3 → α) :
    ⨆ i, f i = f 0 ⊔ f 1 ⊔ f 2 := by
  rw [ @iSup ];
  rw [ show ( range fun i => f i ) = { f 0, f 1, f 2 } by ext x; simp +decide [ Fin.exists_fin_succ ] ; tauto ] ; simp +decide [ sSup_insert, sSup_singleton ] ;
  rw [ sup_assoc ]

/-
In a three-observer system, the consensus is the three-way join.
-/
theorem three_observer_consensus (X : Type*) (P : PhantomSystem X (Fin 3)) :
    P.consensus = P.observe 0 ⊔ P.observe 1 ⊔ P.observe 2 := by
  convert iSup_fin_three P.observe using 1

/-! ## Phantom Product Systems

Given phantom systems on X and Y, we can form a phantom system on X × Y
by taking the product topology for each observer. -/

/-- The product of two phantom systems: each observer sees the product
of their respective topologies. -/
noncomputable def PhantomSystem.prod {X Y : Type*} {O : Type*}
    (P : PhantomSystem X O) (Q : PhantomSystem Y O) :
    PhantomSystem (X × Y) O where
  observe o := @instTopologicalSpaceProd X Y (P.observe o) (Q.observe o)

/-- The identity phantom morphism. -/
def PhantomMorphism.id {X : Type*} {O : Type*} (P : PhantomSystem X O) :
    PhantomMorphism P P where
  map := _root_.id
  continuous_observe o := @continuous_id X (P.observe o)

/-- Composition of phantom morphisms. -/
def PhantomMorphism.comp {X Y Z : Type*} {O : Type*}
    {P : PhantomSystem X O} {Q : PhantomSystem Y O} {R : PhantomSystem Z O}
    (ψ : PhantomMorphism Q R) (φ : PhantomMorphism P Q) :
    PhantomMorphism P R where
  map := ψ.map ∘ φ.map
  continuous_observe o := @Continuous.comp X Y Z (P.observe o) (Q.observe o)
    (R.observe o) _ _ (ψ.continuous_observe o) (φ.continuous_observe o)