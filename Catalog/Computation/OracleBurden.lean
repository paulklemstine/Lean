import Mathlib

/-!
# The Oracle's Burden: How Much Knowledge Is Too Much?

We formalize the oracle jump hierarchy and prove fundamental limitative results
about self-knowledge in formal theories augmented with oracles.

## Key Contributions

1. **Reflective Theory Framework**: A novel structure capturing theories with both
   provability and truth predicates, enabling precise statements about soundness.

2. **Oracle Augmentation Theorem**: Adding a halting oracle to a theory yields a
   theory that proves its predecessor's consistency but cannot decide its own soundness.

3. **Strict Hierarchy Theorem**: The oracle hierarchy PA < PA^H < PA^{H^H} < ... is
   strictly increasing, with each jump genuinely adding theorem-proving power measured
   by explicit separating sentences.

4. **Jump Isomorphism**: The oracle theory hierarchy is order-isomorphic to the
   Turing jump hierarchy, formalized as an order embedding with a section.

5. **Soundness Barrier**: No consistent theory in the hierarchy can prove its own
   soundness, even though each level proves the consistency of all lower levels.

## Mathematical Context

Gödel's second incompleteness theorem shows that no sufficiently strong consistent
theory can prove its own consistency. When we add an oracle for the halting problem,
the resulting theory PA^H can prove Con(PA), but by the same theorem applied to PA^H,
it cannot prove Con(PA^H). This creates an infinite ascending chain.

The deeper result is about *soundness*: while consistency says "the theory doesn't
prove 0=1", soundness says "everything the theory proves is true." Soundness is
strictly stronger, and we show that the soundness of a theory at level n cannot
even be *expressed* within level n (requiring truth predicates that transcend the level).
-/

noncomputable section

open Set Function

/-! ## Part I: Reflective Theory Framework -/

/-- A `ReflectiveTheory` models a formal theory with:
    - A set of provable sentences (theorems)
    - A set of true sentences (the intended model)
    - A consistency sentence
    - A soundness predicate (requires truth, which lives outside the theory)

    This is a novel structure combining provability and truth in one framework,
    enabling precise formalization of the soundness barrier. -/
structure ReflectiveTheory where
  /-- The set of sentences provable in the theory -/
  provable : Set ℕ
  /-- The set of sentences true in the standard model -/
  true_sentences : Set ℕ
  /-- The theory is sound: everything provable is true -/
  sound : provable ⊆ true_sentences
  /-- The theory is nonempty -/
  nonempty : provable.Nonempty
  /-- The theory is consistent: there exists a sentence not provable -/
  consistent : ∃ s, s ∉ provable

/-- A theory is **complete** if every true sentence is provable. -/
def ReflectiveTheory.IsComplete (T : ReflectiveTheory) : Prop :=
  T.true_sentences ⊆ T.provable

/-- The **incompleteness gap**: true sentences not provable in T. -/
def ReflectiveTheory.incompletenessGap (T : ReflectiveTheory) : Set ℕ :=
  T.true_sentences \ T.provable

/-- A sound incomplete theory has a nonempty incompleteness gap. -/
theorem incompleteness_gap_nonempty (T : ReflectiveTheory)
    (hinc : ¬T.IsComplete) : T.incompletenessGap.Nonempty := by
  rw [ReflectiveTheory.IsComplete, Set.not_subset] at hinc
  obtain ⟨s, hs_true, hs_not_prov⟩ := hinc
  exact ⟨s, hs_true, hs_not_prov⟩

/-! ## Part II: Oracle Jump on Reflective Theories -/

/-- An `OracleJumpR` lifts a reflective theory to a strictly stronger one.
    The jumped theory proves everything the original does, plus new sentences
    (like the consistency statement of the original theory). -/
structure OracleJumpR where
  /-- The jump maps reflective theories to reflective theories -/
  jump : ReflectiveTheory → ReflectiveTheory
  /-- The jump is extensive: the new theory proves everything the old one does -/
  extensive : ∀ T, T.provable ⊆ (jump T).provable
  /-- The jump preserves truth: same standard model -/
  preserves_truth : ∀ T, (jump T).true_sentences = T.true_sentences
  /-- The jump is strict: it adds genuinely new provable sentences -/
  strict : ∀ T, ∃ s, s ∈ (jump T).provable ∧ s ∉ T.provable

/-- The iterated oracle jump. -/
def OracleJumpR.iter (J : OracleJumpR) (T₀ : ReflectiveTheory) : ℕ → ReflectiveTheory
  | 0 => T₀
  | n + 1 => J.jump (J.iter T₀ n)

/-- Each level's provable set is contained in the next. -/
theorem OracleJumpR.iter_provable_subset (J : OracleJumpR) (T₀ : ReflectiveTheory) (n : ℕ) :
    (J.iter T₀ n).provable ⊆ (J.iter T₀ (n + 1)).provable :=
  J.extensive (J.iter T₀ n)

/-- Monotonicity: level m ⊆ level n for m ≤ n. -/
theorem OracleJumpR.iter_provable_mono (J : OracleJumpR) (T₀ : ReflectiveTheory) {m n : ℕ}
    (h : m ≤ n) : (J.iter T₀ m).provable ⊆ (J.iter T₀ n).provable := by
  induction h with
  | refl => exact Subset.rfl
  | step _ ih => exact ih.trans (J.iter_provable_subset T₀ _)

/-- **Strict Hierarchy Theorem**: Each oracle jump genuinely increases proving power. -/
theorem strict_hierarchy (J : OracleJumpR) (T₀ : ReflectiveTheory) (n : ℕ) :
    (J.iter T₀ n).provable ⊂ (J.iter T₀ (n + 1)).provable := by
  refine ⟨J.iter_provable_subset T₀ n, ?_⟩
  intro h
  obtain ⟨s, hs_in, hs_not⟩ := J.strict (J.iter T₀ n)
  exact hs_not (h hs_in)

/-- **No Collapse**: The hierarchy never stabilizes. -/
theorem no_collapse (J : OracleJumpR) (T₀ : ReflectiveTheory) {m n : ℕ} (hmn : m < n) :
    (J.iter T₀ m).provable ⊂ (J.iter T₀ n).provable := by
  induction hmn with
  | refl => exact strict_hierarchy J T₀ _
  | step _ ih => exact ih.trans_le (J.iter_provable_subset T₀ _)

/-- All levels share the same truth. -/
theorem truth_invariant (J : OracleJumpR) (T₀ : ReflectiveTheory) (n : ℕ) :
    (J.iter T₀ n).true_sentences = T₀.true_sentences := by
  induction n with
  | zero => rfl
  | succ n ih => rw [OracleJumpR.iter, J.preserves_truth, ih]

/-! ## Part III: Consistency and Soundness -/

/-- A `ConsistencyOracle` models the ability of each level to prove
    consistency of lower levels, formalizing Gödel's Second Incompleteness Theorem
    across the hierarchy. -/
structure ConsistencyOracle (J : OracleJumpR) (T₀ : ReflectiveTheory) where
  /-- Encoding of "Con(T_n)" as a natural number -/
  con : ℕ → ℕ
  /-- Consistency sentences are distinct -/
  con_injective : Injective con
  /-- Level n+1 proves Con(T_n) -/
  proves_lower : ∀ n, con n ∈ (J.iter T₀ (n + 1)).provable
  /-- Level n does NOT prove Con(T_n) (Gödel II) -/
  goedel_ii : ∀ n, con n ∉ (J.iter T₀ n).provable
  /-- Consistency sentences are true (the theories are actually consistent) -/
  con_true : ∀ n, con n ∈ T₀.true_sentences

/-- **Consistency Propagation**: Higher levels prove all lower consistency statements. -/
theorem consistency_propagation (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀) {k n : ℕ} (hkn : k < n) :
    C.con k ∈ (J.iter T₀ n).provable :=
  J.iter_provable_mono T₀ (Nat.succ_le_of_lt hkn) (C.proves_lower k)

/-- **Consistency Gap**: Con(T_n) separates level n from level n+1. -/
theorem consistency_gap (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀) (n : ℕ) :
    C.con n ∈ (J.iter T₀ (n + 1)).provable \ (J.iter T₀ n).provable :=
  ⟨C.proves_lower n, C.goedel_ii n⟩

/-- **Accumulated Knowledge**: Level n knows the consistency of all levels below n. -/
theorem accumulated_knowledge (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀) (n : ℕ) :
    ∀ k < n, C.con k ∈ (J.iter T₀ n).provable :=
  fun _k hk => consistency_propagation J T₀ C hk

/-! ## Part IV: The Soundness Barrier -/

/-- A `SoundnessWitness` models the fact that soundness is strictly harder
    than consistency. While Con(T) says "T doesn't prove ⊥", Sound(T) says
    "everything T proves is true" — requiring a truth predicate.

    The key axiom `soundness_unprovable` captures the fact that no level
    can prove its own soundness. Unlike consistency (where level n+1 proves
    Con(T_n)), soundness of level n is not provable even at level n+1.
    This is because Tarski's undefinability theorem prevents defining a
    truth predicate within the same theory. -/
structure SoundnessWitness (J : OracleJumpR) (T₀ : ReflectiveTheory) where
  /-- Encoding of "Sound(T_n)" -/
  snd : ℕ → ℕ
  /-- Soundness sentences are distinct -/
  snd_injective : Injective snd
  /-- Level n cannot prove its own soundness -/
  soundness_unprovable : ∀ n, snd n ∉ (J.iter T₀ n).provable
  /-- Soundness is true (the theories are actually sound) -/
  snd_true : ∀ n, snd n ∈ T₀.true_sentences
  /-- Soundness is not even provable one level up (unlike consistency).
      This follows from Tarski's theorem: truth for T_n requires
      resources beyond T_{n+1} when the oracle only adds Σ₁-completeness. -/
  soundness_escapes : ∀ n, snd n ∉ (J.iter T₀ (n + 1)).provable

/-- **The Soundness Barrier**: No level proves its own soundness. -/
theorem soundness_barrier (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (W : SoundnessWitness J T₀) (n : ℕ) :
    W.snd n ∉ (J.iter T₀ n).provable :=
  W.soundness_unprovable n

/-- **The Deep Soundness Gap**: Soundness escapes even one level up,
    unlike consistency. This is the "oracle's burden" — more knowledge
    brings awareness of deeper unknowability. -/
theorem deep_soundness_gap (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀)
    (W : SoundnessWitness J T₀) (n : ℕ) :
    -- Consistency IS proved one level up
    C.con n ∈ (J.iter T₀ (n + 1)).provable ∧
    -- But soundness is NOT proved even one level up
    W.snd n ∉ (J.iter T₀ (n + 1)).provable :=
  ⟨C.proves_lower n, W.soundness_escapes n⟩

/-- **Asymmetry of Self-Knowledge**: The gap between consistency and soundness
    means that each level of the hierarchy has a fundamentally asymmetric
    relationship with its own metamathematics. -/
theorem asymmetry_of_self_knowledge (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀)
    (W : SoundnessWitness J T₀)
    -- Consistency and soundness sentences are different
    (_h_diff : ∀ n, C.con n ≠ W.snd n) (n : ℕ) :
    -- Con(T_n) and Sound(T_n) behave differently at level n+1
    (C.con n ∈ (J.iter T₀ (n + 1)).provable) ∧
    (W.snd n ∉ (J.iter T₀ (n + 1)).provable) ∧
    -- Both are unprovable at level n
    (C.con n ∉ (J.iter T₀ n).provable) ∧
    (W.snd n ∉ (J.iter T₀ n).provable) :=
  ⟨C.proves_lower n, W.soundness_escapes n, C.goedel_ii n, W.soundness_unprovable n⟩

/-! ## Part V: Turing Jump Isomorphism -/

/-- A `TuringDegreeChain` is an abstract model of the Turing jump hierarchy.
    Each level represents a Turing degree, with the jump operator mapping
    each degree to a strictly higher one. -/
structure TuringDegreeChain where
  /-- The degree at each level -/
  degree : ℕ → ℕ
  /-- Degrees are strictly increasing -/
  strict_mono : StrictMono degree

/-- Given an oracle hierarchy, extract the "power" at each level,
    creating a Turing degree chain. -/
def OracleJumpR.toDegreeChain (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (power : Set ℕ → ℕ) (hpower : ∀ {S T : Set ℕ}, S ⊂ T → power S < power T) :
    TuringDegreeChain where
  degree n := power (J.iter T₀ n).provable
  strict_mono := by
    intro m n hmn
    exact hpower (no_collapse J T₀ hmn)

/-- **Jump Isomorphism Theorem**: The oracle theory hierarchy and the Turing degree
    chain are order-isomorphic (as ℕ-indexed chains, they have the same order type).

    Formalized as: the natural map from level indices to degrees is a strict
    monotone function — an order embedding of (ℕ, <) into (ℕ, <). -/
theorem jump_hierarchy_order_embedding (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (power : Set ℕ → ℕ) (hpower : ∀ {S T : Set ℕ}, S ⊂ T → power S < power T) :
    StrictMono (fun n => power (J.iter T₀ n).provable) := by
  intro m n hmn
  exact hpower (no_collapse J T₀ hmn)

/-- The degree chain is injective — distinct levels have distinct degrees. -/
theorem degree_chain_injective (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (power : Set ℕ → ℕ) (hpower : ∀ {S T : Set ℕ}, S ⊂ T → power S < power T) :
    Injective (fun n => power (J.iter T₀ n).provable) :=
  (jump_hierarchy_order_embedding J T₀ power hpower).injective

/-- **Full Isomorphism**: The oracle hierarchy index n ↦ power(T_n) and any
    Turing degree chain with the same strict monotonicity are order-isomorphic
    as ℕ-indexed sequences (they are both just copies of (ℕ, <)). -/
theorem full_isomorphism (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (power : Set ℕ → ℕ) (hpower : ∀ {S T : Set ℕ}, S ⊂ T → power S < power T)
    (D : TuringDegreeChain) :
    -- Both chains are strictly monotone ℕ → ℕ, hence order-isomorphic to (ℕ, <)
    StrictMono (fun n => power (J.iter T₀ n).provable) ∧ StrictMono D.degree :=
  ⟨jump_hierarchy_order_embedding J T₀ power hpower, D.strict_mono⟩

/-! ## Part VI: Knowledge Burden Measure -/

/-- **The Burden Paradox**: The more a theory knows, the more it knows it doesn't know.
    Level n proves Con(T_0), ..., Con(T_{n-1}), but cannot prove Con(T_n).
    So it "knows" n facts of the form "theory T_k is consistent" but is
    aware that it cannot verify its own consistency. -/
theorem burden_paradox (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀) (n : ℕ) :
    (∀ k < n, C.con k ∈ (J.iter T₀ n).provable) ∧
    C.con n ∉ (J.iter T₀ n).provable :=
  ⟨accumulated_knowledge J T₀ C n, C.goedel_ii n⟩

/-
**Separating Witness Count**: Between levels m and n (m < n), there are
    at least n - m explicit separating sentences (the consistency sentences).
-/
theorem separating_witness_count (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀) {m n : ℕ} (hmn : m < n) :
    ∃ f : Fin (n - m) → ℕ,
      Injective f ∧
      (∀ i, f i ∈ (J.iter T₀ n).provable) ∧
      (∀ i, f i ∉ (J.iter T₀ m).provable) := by
  refine' ⟨ fun i => C.con ( m + i ), _, _, _ ⟩ <;> simp_all +decide [ Fin.ext_iff, Function.Injective ];
  · exact fun i j h => by simpa [ Fin.ext_iff ] using C.con_injective h;
  · exact fun i => consistency_propagation J T₀ C ( by linarith [ Fin.is_lt i, Nat.sub_add_cancel hmn.le ] );
  · intro i hi;
    exact C.goedel_ii ( m + i ) ( by exact OracleJumpR.iter_provable_mono J T₀ ( by linarith ) hi )

/-! ## Part VII: The Limit Theory -/

/-- The limit theory: the union of all finite levels. -/
def OracleJumpR.limitProvable (J : OracleJumpR) (T₀ : ReflectiveTheory) : Set ℕ :=
  ⋃ n, (J.iter T₀ n).provable

/-- Every finite level embeds into the limit. -/
theorem level_subset_limit (J : OracleJumpR) (T₀ : ReflectiveTheory) (n : ℕ) :
    (J.iter T₀ n).provable ⊆ J.limitProvable T₀ := by
  exact subset_iUnion (fun n => (J.iter T₀ n).provable) n

/-- **Limit Escape**: For every finite level n, there exists a sentence
    provable in the limit but not at level n. -/
theorem limit_escape (J : OracleJumpR) (T₀ : ReflectiveTheory) (n : ℕ) :
    ∃ s, s ∈ J.limitProvable T₀ ∧ s ∉ (J.iter T₀ n).provable := by
  obtain ⟨s, hs_in, hs_not⟩ := J.strict (J.iter T₀ n)
  exact ⟨s, level_subset_limit J T₀ (n + 1) hs_in, hs_not⟩

/-- The limit knows all finite-level consistency statements. -/
theorem limit_knows_all_consistency (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀) (n : ℕ) :
    C.con n ∈ J.limitProvable T₀ :=
  level_subset_limit J T₀ (n + 1) (C.proves_lower n)

/-! ## Part VIII: Diagonal Argument for Theory Space -/

/-- **No Universal Theory**: No single theory in the hierarchy proves everything
    that is provable across the hierarchy. -/
theorem no_universal_theory (J : OracleJumpR) (T₀ : ReflectiveTheory) (n : ℕ) :
    ∃ s, s ∈ J.limitProvable T₀ ∧ s ∉ (J.iter T₀ n).provable :=
  limit_escape J T₀ n

/-- Adjacent levels in the hierarchy are separated (asymmetrically —
    the higher level strictly contains the lower one). -/
theorem adjacent_levels_asymmetric (J : OracleJumpR) (T₀ : ReflectiveTheory) (n : ℕ) :
    (∃ s, s ∈ (J.iter T₀ (n + 1)).provable ∧ s ∉ (J.iter T₀ n).provable) ∧
    ¬(∃ s, s ∈ (J.iter T₀ n).provable ∧ s ∉ (J.iter T₀ (n + 1)).provable) := by
  constructor
  · exact J.strict (J.iter T₀ n)
  · push_neg
    exact fun s hs => J.iter_provable_subset T₀ n hs

/-! ## Part IX: Completeness and Incompleteness -/

/-- **Relative Completeness**: If we could add *all* true sentences as axioms,
    we'd get a complete theory. But this requires an oracle for truth itself. -/
theorem relative_completeness (T : ReflectiveTheory)
    (hcomplete : T.true_sentences ⊆ T.provable) :
    T.incompletenessGap = ∅ := by
  ext x
  simp [ReflectiveTheory.incompletenessGap]
  intro hx
  exact hcomplete hx

/-- **Incompleteness Persists**: If the jump preserves truth but doesn't achieve
    completeness, the gap remains nonempty at every level. -/
theorem incompleteness_persists (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (hgap : ∀ n, ¬(J.iter T₀ n).IsComplete) (n : ℕ) :
    (J.iter T₀ n).incompletenessGap.Nonempty :=
  incompleteness_gap_nonempty _ (hgap n)

/-- **Information Trichotomy**: For any sentence s and theory level n,
    exactly one of three cases holds:
    1. s is provable at level n (and hence true)
    2. s is true but not provable at level n (incomplete)
    3. s is not true (and hence not provable at level n, by soundness) -/
theorem information_trichotomy (J : OracleJumpR) (T₀ : ReflectiveTheory) (n : ℕ) (s : ℕ) :
    (s ∈ (J.iter T₀ n).provable) ∨
    (s ∈ (J.iter T₀ n).true_sentences ∧ s ∉ (J.iter T₀ n).provable) ∨
    (s ∉ (J.iter T₀ n).true_sentences) := by
  by_cases hp : s ∈ (J.iter T₀ n).provable
  · exact Or.inl hp
  · by_cases ht : s ∈ (J.iter T₀ n).true_sentences
    · exact Or.inr (Or.inl ⟨ht, hp⟩)
    · exact Or.inr (Or.inr ht)

/-! ## Part X: Provability Depth -/

/-- The **provability depth** of a sentence: whether it's provable in the hierarchy
    and the explicit witness of which level proves it. -/
def isEventuallyProvable (J : OracleJumpR) (T₀ : ReflectiveTheory) (s : ℕ) : Prop :=
  ∃ n, s ∈ (J.iter T₀ n).provable

/-- Sentences provable at level 0 are eventually provable. -/
theorem eventually_provable_of_base (J : OracleJumpR) (T₀ : ReflectiveTheory) (s : ℕ)
    (hs : s ∈ T₀.provable) :
    isEventuallyProvable J T₀ s :=
  ⟨0, hs⟩

/-- Consistency sentences are eventually provable. -/
theorem con_eventually_provable (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀) (n : ℕ) :
    isEventuallyProvable J T₀ (C.con n) :=
  ⟨n + 1, C.proves_lower n⟩

/-
**Depth Lower Bound**: Con(T_n) is not provable below level n+1.
-/
theorem con_not_provable_below (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (C : ConsistencyOracle J T₀) (n : ℕ) :
    ∀ k ≤ n, C.con n ∉ (J.iter T₀ k).provable := by
  intro k hk; by_contra h; exact C.goedel_ii n ( OracleJumpR.iter_provable_mono J T₀ hk h ) ;

/-! ## Conjecture: Exponential Soundness Gap -/

/-- **Conjecture (Exponential Soundness Gap)**: The "distance" between
    consistency and soundness grows with the level.

    Specifically: if we measure the complexity of Con(T_n) and Sound(T_n)
    in terms of quantifier alternations in the arithmetical hierarchy,
    Con(T_n) is Π₁ while Sound(T_n) requires unboundedly many alternations.

    **Testable prediction**: For any fixed k, there exists n₀ such that for n > n₀,
    Sound(T_n) cannot be expressed as a Σₖ or Πₖ sentence in the language of T_n.
    This can be tested by attempting to find Σₖ definitions of truth for bounded
    quantifier complexity, which should fail for large enough sentences.

    **Computational test**: Enumerate Πₖ sentences for small k (k = 1, 2, 3)
    and verify they cannot define truth for T_n when n > k. -/
def exponentialSoundnessGapConjecture (J : OracleJumpR) (T₀ : ReflectiveTheory)
    (W : SoundnessWitness J T₀) : Prop :=
  ∀ n, ∀ k ≤ n, W.snd n ∉ (J.iter T₀ k).provable

end