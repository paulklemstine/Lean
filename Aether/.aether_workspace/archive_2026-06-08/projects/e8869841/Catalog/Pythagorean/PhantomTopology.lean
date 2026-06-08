import Mathlib

/-!
# Phantom Topologies: Observer-Dependent Topological Spaces

A *phantom topology* on a type `X` assigns to each observer `o : O` a topology on `X`.
The *consensus topology* is the supremum (in the Mathlib lattice) of all observer topologies.

**Lattice convention**: In Mathlib, `t₁ ≤ t₂` for topological spaces means t₁ is *finer*
(has more open sets). So `⊥` = discrete (finest) and `⊤` = indiscrete (coarsest).
The consensus — where a set is open iff ALL observers agree — corresponds to the
*supremum* `⨆ o, T o`, which is the coarsest topology that all observers are finer than.

## Main Results

- `consensus_open_iff_agreement`: Open in consensus ↔ every observer agrees
- `discrete_phantomIrreducible`: The discrete topology is phantom-irreducible
- `indiscrete_not_phantomIrreducible`: The indiscrete topology on a nontrivial type
  admits a strict 2-observer decomposition
- `strict_decomp_not_subsingleton`: Every strict decomposition needs ≥ 2 observers
-/

open TopologicalSpace Set

noncomputable section

/-- A phantom topology on `X` indexed by observers `O` assigns to each
    observer a topological space structure on `X`. -/
structure PhantomTopology (O : Type*) (X : Type*) where
  /-- The assignment of topologies to observers. -/
  observe : O → TopologicalSpace X

namespace PhantomTopology

variable {O X : Type*}

/-- The consensus topology: the supremum of all observer topologies.
    A set is open in the consensus iff it is open for every observer. -/
def consensus (T : PhantomTopology O X) : TopologicalSpace X :=
  ⨆ o : O, T.observe o

/-- A set is in *phantom agreement* if every observer considers it open. -/
def agreement (T : PhantomTopology O X) (U : Set X) : Prop :=
  ∀ o : O, @IsOpen X (T.observe o) U

/-- Each observer is finer than (or equal to) the consensus. -/
theorem observer_le_consensus (T : PhantomTopology O X) (o : O) :
    T.observe o ≤ T.consensus :=
  le_iSup _ o

/-- **Agreement characterization**: Open in consensus ↔ every observer agrees. -/
theorem consensus_open_iff_agreement (T : PhantomTopology O X) (U : Set X) :
    @IsOpen X T.consensus U ↔ T.agreement U := by
  convert @isOpen_iSup_iff X O (fun o => T.observe o) U

/-- Observer-wise finer phantom topology ⟹ finer consensus. -/
theorem consensus_mono (T₁ T₂ : PhantomTopology O X)
    (h : ∀ o, T₁.observe o ≤ T₂.observe o) :
    T₁.consensus ≤ T₂.consensus :=
  iSup_mono h

/-- Surjective reparametrization preserves the consensus. -/
theorem consensus_comp_surjective {O' : Type*}
    (T : PhantomTopology O X) (f : O' → O) (hf : Function.Surjective f) :
    T.consensus = (PhantomTopology.mk (T.observe ∘ f)).consensus := by
  refine le_antisymm ?_ ?_
  · exact iSup_le fun o =>
      le_iSup_of_le (hf o |> Classical.choose)
        (by simp [hf o |> Classical.choose_spec])
  · exact iSup_le fun o => observer_le_consensus _ _

/-- The empty set is always in phantom agreement. -/
theorem agreement_empty (T : PhantomTopology O X) :
    T.agreement ∅ :=
  fun o => @isOpen_empty X (T.observe o)

/-- The universal set is always in phantom agreement. -/
theorem agreement_univ (T : PhantomTopology O X) :
    T.agreement Set.univ :=
  fun o => @TopologicalSpace.isOpen_univ X (T.observe o)

/-- Phantom agreement is closed under arbitrary unions. -/
theorem agreement_sUnion {T : PhantomTopology O X} {s : Set (Set X)}
    (hs : ∀ U ∈ s, T.agreement U) :
    T.agreement (⋃₀ s) :=
  fun o => @isOpen_sUnion X (T.observe o) s (fun U hU => hs U hU o)

/-- Phantom agreement is closed under finite intersections. -/
theorem agreement_inter {T : PhantomTopology O X} {U V : Set X}
    (hU : T.agreement U) (hV : T.agreement V) :
    T.agreement (U ∩ V) :=
  fun o => @IsOpen.inter X (T.observe o) U V (hU o) (hV o)

end PhantomTopology

/-! ## Strict Phantom Decompositions -/

/-- A *strict phantom decomposition* of a topology `τ` expresses it as the supremum
    of a nonempty family of strictly finer topologies. -/
structure StrictPhantomDecomp (X : Type*) (τ : TopologicalSpace X) where
  /-- The type of observers. -/
  Obs : Type
  /-- There is at least one observer. -/
  obs_nonempty : Nonempty Obs
  /-- The observer topologies. -/
  topo : Obs → TopologicalSpace X
  /-- Each observer is strictly finer than the real topology. -/
  strictly_finer : ∀ o, topo o < τ
  /-- The supremum recovers the real topology. -/
  consensus_eq : ⨆ o, topo o = τ

/-- A topology is *phantom-irreducible* if no strict decomposition exists. -/
def phantomIrreducible {X : Type*} (τ : TopologicalSpace X) : Prop :=
  ∀ (_ : StrictPhantomDecomp X τ), False

/-- A 2-observer strict phantom decomposition from a binary supremum. -/
def sup_strict_decomp {X : Type*} {τ τ₁ τ₂ : TopologicalSpace X}
    (h_eq : τ₁ ⊔ τ₂ = τ) (h₁ : τ₁ < τ) (h₂ : τ₂ < τ) :
    StrictPhantomDecomp X τ where
  Obs := Bool
  obs_nonempty := ⟨true⟩
  topo := fun b => bif b then τ₁ else τ₂
  strictly_finer := by intro b; cases b <;> simp [*]
  consensus_eq := by rw [← h_eq, iSup_bool_eq]; rfl

/-- **The discrete topology is phantom-irreducible.**
    No strictly finer topology exists below `⊥`. -/
theorem discrete_phantomIrreducible (X : Type*) :
    phantomIrreducible (⊥ : TopologicalSpace X) := by
  intro D
  cases D with | mk Obs obs_nonempty topo strictly_finer consensus_eq =>
  exact not_lt_bot (strictly_finer obs_nonempty.some)

/-
A strict decomposition must have at least 2 distinct observers.
    If there is only one observer, the supremum equals that observer's topology,
    contradicting strict fineness.
-/
theorem strict_decomp_not_subsingleton {X : Type*} {τ : TopologicalSpace X}
    (D : StrictPhantomDecomp X τ) : ¬ Subsingleton D.Obs := by
  intro h;
  obtain ⟨o₀⟩ := D.obs_nonempty;
  have h_topo_eq : ⨆ o, D.topo o = D.topo o₀ := by
    exact iSup_eq_of_forall_le_of_forall_lt_exists_gt ( fun o => by rw [ Subsingleton.elim o o₀ ] ) fun t ht => ⟨ o₀, by rw [ Subsingleton.elim o₀ o₀ ] ; exact ht ⟩;
  exact D.strictly_finer o₀ |> fun h => h.ne ( h_topo_eq.symm.trans D.consensus_eq )

/-
Every strict phantom decomposition uses at least 2 observers.
-/
theorem strict_decomp_obs_card_ge_two {X : Type*} {τ : TopologicalSpace X}
    (D : StrictPhantomDecomp X τ) [Fintype D.Obs] :
    2 ≤ Fintype.card D.Obs := by
  convert strict_decomp_not_subsingleton D using 1;
  constructor <;> intro h;
  · exact fun h' => by have := Fintype.card_le_one_iff_subsingleton.mpr h'; linarith;
  · exact Fintype.one_lt_card_iff_nontrivial.mpr ( not_subsingleton_iff_nontrivial.mp h )

/-! ## Helper lemmas for the indiscrete decomposition -/

/-
`generateFrom {{a}}` is strictly finer than the indiscrete topology `⊤`,
    because `{a}` is open in the generated topology but not in `⊤`.
-/
theorem generateFrom_singleton_lt_top {X : Type*} (a : X)
    (h : ∃ b : X, b ≠ a) :
    TopologicalSpace.generateFrom {{a}} < (⊤ : TopologicalSpace X) := by
  refine' lt_of_le_of_ne _ _;
  · exact le_top;
  · intro h';
    obtain ⟨ b, hb ⟩ := h;
    have h_open : @IsOpen X (generateFrom {{a}}) {a} := by
      exact TopologicalSpace.GenerateOpen.basic _ ( Set.mem_singleton _ );
    simp_all +decide [ TopologicalSpace.ext_iff ];
    specialize h' { a } ; simp_all +decide [ isOpen_iff_mem_nhds ];
    simp_all +decide [ nhds_top ];
    exact hb ( by simpa using Set.ext_iff.mp h_open b )

/-
Open sets of `generateFrom {{a}}` are exactly `∅`, `{a}`, and `univ`.
    The topology generated by a single set `{a}` is the Sierpiński-style topology
    `{∅, {a}, univ}`.
-/
theorem isOpen_generateFrom_singleton_iff {X : Type*} (a : X) (U : Set X) :
    @IsOpen X (TopologicalSpace.generateFrom {{a}}) U ↔
    U = ∅ ∨ U = {a} ∨ U = Set.univ := by
  constructor;
  · intro hU
    induction' hU with U hU ih;
    · grind;
    · exact Or.inr <| Or.inr rfl;
    · grind;
    · grind;
  · rintro ( rfl | rfl | rfl ) <;> simp +decide [ TopologicalSpace.isOpen_generateFrom_of_mem ]

/-
The supremum (= intersection of opens) of `generateFrom {{a}}` and
    `generateFrom {{b}}` for `a ≠ b` is the indiscrete topology `⊤`.
    This is because `{a}` is open in the first but not the second, and
    `{b}` is open in the second but not the first, so the only sets
    open in both are `∅` and `univ`.
-/
theorem sup_generateFrom_singletons_eq_top {X : Type*} {a b : X} (hab : a ≠ b) :
    TopologicalSpace.generateFrom {{a}} ⊔ TopologicalSpace.generateFrom {{b}} =
    (⊤ : TopologicalSpace X) := by
  refine' le_antisymm ( le_top ) _;
  -- Take any open set U in the supremum. By definition, U is open in both generateFrom {{a}} and generateFrom {{b}}.
  intro U hU
  have hU_a : @IsOpen X (TopologicalSpace.generateFrom {{a}}) U := by
    exact hU.1
  have hU_b : @IsOpen X (TopologicalSpace.generateFrom {{b}}) U := by
    exact hU.2
  generalize_proofs at *; (
  rw [ isOpen_generateFrom_singleton_iff ] at hU_a hU_b;
  rcases hU_a with ( rfl | rfl | rfl ) <;> rcases hU_b with ( h | h | h ) <;> simp_all +decide [ Set.ext_iff ])

/-- **The indiscrete topology on a nontrivial type is NOT phantom-irreducible.**
    Two observers suffice, each seeing one extra singleton as open. -/
theorem indiscrete_not_phantomIrreducible (X : Type*)
    [Nontrivial X] :
    ¬ phantomIrreducible (⊤ : TopologicalSpace X) := by
  obtain ⟨a, b, hab⟩ := exists_pair_ne X
  intro h
  exact h (sup_strict_decomp
    (sup_generateFrom_singletons_eq_top hab)
    (generateFrom_singleton_lt_top a ⟨b, hab.symm⟩)
    (generateFrom_singleton_lt_top b ⟨a, hab⟩))

/-! ## Observer Stability -/

/-
If a new observer is finer than the consensus, adjoining it does not change
    the consensus. In the lattice, `τ_new ≤ T.consensus` means `τ_new` has
    more open sets than the consensus.
-/
theorem consensus_stable_of_finer
    (T : PhantomTopology O X) (τ_new : TopologicalSpace X)
    (h : τ_new ≤ T.consensus) :
    T.consensus ⊔ τ_new = T.consensus := by
  convert sup_eq_left.mpr h

/-- **Phantom Intersection Principle**: Open in consensus ↔ open for all observers. -/
theorem phantom_intersection_principle (T : PhantomTopology O X) :
    ∀ U : Set X, @IsOpen X T.consensus U ↔ ∀ o, @IsOpen X (T.observe o) U := by
  convert PhantomTopology.consensus_open_iff_agreement T using 1

end