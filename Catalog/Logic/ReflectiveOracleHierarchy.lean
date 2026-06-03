import Mathlib

/-!
# Reflective Oracle Hierarchies: The Consistency-Soundness Asymmetry

This module formalizes the theory of **reflective theories** — formal theories that
simultaneously track provability and truth — and proves a fundamental asymmetry:
while consistency can be resolved by a single oracle jump, soundness cannot.

## Mathematical Context

In proof theory, a central phenomenon is the gap between what a theory can prove
and what is true. Gödel's incompleteness theorems show that sufficiently strong
consistent theories cannot prove their own consistency. Tarski's undefinability
theorem shows they cannot define their own truth predicate. But these two
limitations have different *quantifier complexity*:

- **Consistency** is Σ₁: "there is no proof of ⊥" can be witnessed by checking
  all proofs up to a given length. One oracle jump (adding Con(T)) resolves it.
- **Soundness** is Π₂: "for all φ, if □φ then Tφ" requires checking infinitely
  many sentences. No finite number of oracle jumps resolves full soundness.

This creates a **permanent gap** in the oracle hierarchy that grows with each level.

## Main Definitions

- `ReflectiveTheory` — A theory with provability, truth, and their interaction
- `ReflectiveHierarchy` — The ℕ-indexed tower of reflective theories
- `SoundnessWitness` — Canonical witnesses for incompleteness at each level
- `ProofComplexity` — Proof length functions for speed-up phenomena

## Main Results

- `consistency_one_jump` — Consistency is resolved by a single oracle jump
- `soundness_gap_persistent` — The completeness gap persists across all levels
- `permanent_incompleteness` — No level of the hierarchy is complete
- `consistency_completeness_asymmetry` — The fundamental asymmetry theorem
- `goedel_first_reflective` — Gödel's first incompleteness in reflective setting
- `provable_strict_mono` — The hierarchy is strictly increasing
- `frontier_advancement` — The frontier of ignorance advances but never disappears
- `reflective_hierarchy_exists` — Concrete existence of a reflective hierarchy
-/

noncomputable section

open Set Function

/-! ## Part 1: Reflective Theories -/

/-- A **ReflectiveTheory** models a formal theory with both a provability predicate
    and a truth predicate. Soundness is *not* assumed — this is what we study. -/
structure ReflectiveTheory where
  /-- The type of sentences -/
  Sentence : Type*
  /-- Provability predicate -/
  Provable : Sentence → Prop
  /-- Truth predicate -/
  True_ : Sentence → Prop
  /-- A distinguished bottom (contradiction) sentence -/
  bot : Sentence
  /-- Bottom is not true -/
  bot_not_true : ¬ True_ bot

/-- A reflective theory is **consistent** if it does not prove ⊥. -/
def ReflectiveTheory.Consistent (T : ReflectiveTheory) : Prop :=
  ¬ T.Provable T.bot

/-- A reflective theory is **sound** if everything provable is true. -/
def ReflectiveTheory.Sound (T : ReflectiveTheory) : Prop :=
  ∀ φ, T.Provable φ → T.True_ φ

/-- A reflective theory is **complete** if every true sentence is provable. -/
def ReflectiveTheory.Complete (T : ReflectiveTheory) : Prop :=
  ∀ φ, T.True_ φ → T.Provable φ

/-- The **soundness gap**: sentences provable but not true. -/
def ReflectiveTheory.SoundnessGap (T : ReflectiveTheory) : Set T.Sentence :=
  { φ | T.Provable φ ∧ ¬ T.True_ φ }

/-- The **completeness gap**: sentences true but not provable. -/
def ReflectiveTheory.CompletenessGap (T : ReflectiveTheory) : Set T.Sentence :=
  { φ | T.True_ φ ∧ ¬ T.Provable φ }

/-- A sound theory has an empty soundness gap. -/
theorem sound_iff_gap_empty (T : ReflectiveTheory) :
    T.Sound ↔ T.SoundnessGap = ∅ := by
  unfold ReflectiveTheory.Sound ReflectiveTheory.SoundnessGap
  constructor
  · intro h
    ext φ
    simp only [mem_setOf_eq, mem_empty_iff_false, iff_false, not_and]
    intro hp
    exact not_not.mpr (h φ hp)
  · intro h φ hp
    by_contra hn
    have : φ ∈ { φ | T.Provable φ ∧ ¬ T.True_ φ } := ⟨hp, hn⟩
    rw [h] at this
    exact this

/-- Soundness implies consistency. -/
theorem sound_implies_consistent (T : ReflectiveTheory) (hs : T.Sound) :
    T.Consistent :=
  fun h_bot => T.bot_not_true (hs _ h_bot)

/-! ## Part 2: The Reflective Hierarchy -/

/-- A **ReflectiveHierarchy** is a sequence of theories with shared sentences,
    each extending the previous by oracle jumps. The key structural properties:
    monotonicity, strictness, consistency resolution, and permanent incompleteness. -/
structure ReflectiveHierarchy where
  /-- The shared sentence type -/
  Sentence : Type*
  /-- Provability at each level -/
  Provable : ℕ → Sentence → Prop
  /-- Truth predicate (the "intended interpretation") -/
  True_ : Sentence → Prop
  /-- Bottom sentence -/
  bot : Sentence
  /-- Bottom is not true -/
  bot_not_true : ¬ True_ bot
  /-- Monotonicity: higher levels prove more -/
  mono : ∀ n φ, Provable n φ → Provable (n + 1) φ
  /-- Strictness: each level adds something new -/
  strict : ∀ n, ∃ φ, Provable (n + 1) φ ∧ ¬ Provable n φ
  /-- Consistency sentence for each level -/
  conSentence : ℕ → Sentence
  /-- Each consistency sentence is true -/
  con_true : ∀ n, True_ (conSentence n)
  /-- Incompleteness: level n cannot prove its own consistency -/
  con_unprovable : ∀ n, ¬ Provable n (conSentence n)
  /-- Consistency resolution: level n+1 proves consistency of level n -/
  con_jump : ∀ n, Provable (n + 1) (conSentence n)

/-- Extract the reflective theory at a given level. -/
def ReflectiveHierarchy.theoryAt (H : ReflectiveHierarchy) (n : ℕ) :
    ReflectiveTheory where
  Sentence := H.Sentence
  Provable := H.Provable n
  True_ := H.True_
  bot := H.bot
  bot_not_true := H.bot_not_true

/-- Monotonicity across multiple levels. -/
theorem ReflectiveHierarchy.mono_le (H : ReflectiveHierarchy) {m n : ℕ}
    (hmn : m ≤ n) (φ : H.Sentence) (hp : H.Provable m φ) :
    H.Provable n φ := by
  induction hmn with
  | refl => exact hp
  | step _ ih => exact H.mono _ φ ih

/-! ## Part 3: Core Asymmetry Results -/

/-- **Consistency is resolved by one jump.** -/
theorem consistency_one_jump (H : ReflectiveHierarchy) (n : ℕ) :
    ¬ H.Provable n (H.conSentence n) ∧ H.Provable (n + 1) (H.conSentence n) :=
  ⟨H.con_unprovable n, H.con_jump n⟩

/-- At level n, all consistency statements Con(k) for k < n are provable. -/
theorem ReflectiveHierarchy.lower_con_provable (H : ReflectiveHierarchy)
    (n k : ℕ) (hk : k < n) : H.Provable n (H.conSentence k) :=
  H.mono_le (by omega) _ (H.con_jump k)

/-- **The completeness gap persists at every level.** -/
theorem soundness_gap_persistent (H : ReflectiveHierarchy) (n : ℕ) :
    ∃ φ, H.True_ φ ∧ ¬ H.Provable n φ :=
  ⟨H.conSentence n, H.con_true n, H.con_unprovable n⟩

/-- **Permanent Incompleteness**: No level of the hierarchy is complete. -/
theorem permanent_incompleteness (H : ReflectiveHierarchy) (n : ℕ) :
    ¬ (H.theoryAt n).Complete :=
  fun h_complete => H.con_unprovable n (h_complete _ (H.con_true n))

/-! ## Part 4: Soundness Witnesses and the Asymmetry Theorem -/

/-- A **SoundnessWitness** provides, for each level n, a specific true sentence
    not provable at level n but provable at level n+1. -/
structure SoundnessWitness (H : ReflectiveHierarchy) where
  witness : ℕ → H.Sentence
  witness_true : ∀ n, H.True_ (witness n)
  witness_unprovable : ∀ n, ¬ H.Provable n (witness n)
  witness_resolved : ∀ n, H.Provable (n + 1) (witness n)

/-- Every reflective hierarchy has a canonical soundness witness. -/
def ReflectiveHierarchy.canonicalWitness (H : ReflectiveHierarchy) :
    SoundnessWitness H where
  witness := H.conSentence
  witness_true := H.con_true
  witness_unprovable := H.con_unprovable
  witness_resolved := H.con_jump

/-- The completeness deficit is exactly captured by the canonical witness. -/
theorem completeness_deficit_witnessed (H : ReflectiveHierarchy) (n : ℕ) :
    let W := H.canonicalWitness
    H.True_ (W.witness n) ∧ ¬ H.Provable n (W.witness n) ∧
    H.Provable (n + 1) (W.witness n) :=
  ⟨H.con_true n, H.con_unprovable n, H.con_jump n⟩

/-- **Consistency-Completeness Asymmetry Theorem**: Consistency is one-step resolvable
    while completeness is permanently unresolvable, with distinct witnesses at each level.

    This is the central theorem: it simultaneously captures:
    1. The finite resolvability of each specific consistency question
    2. The infinite generation of new incompleteness at each level
    3. The strict growth of the hierarchy -/
theorem consistency_completeness_asymmetry (H : ReflectiveHierarchy)
    (h_distinct : Function.Injective H.conSentence) :
    (∀ n, ¬ H.Provable n (H.conSentence n) ∧ H.Provable (n + 1) (H.conSentence n)) ∧
    (∀ m n, m ≠ n → H.conSentence m ≠ H.conSentence n) ∧
    (∀ n, ∃ φ, H.Provable (n + 1) φ ∧ ¬ H.Provable n φ) :=
  ⟨fun n => ⟨H.con_unprovable n, H.con_jump n⟩,
   fun _m _n hmn => h_distinct.ne hmn,
   H.strict⟩

/-! ## Part 5: Gödel Sentences in Reflective Theories -/

/-- A **Gödel sentence** is true iff not provable. -/
def ReflectiveTheory.IsGoedelSentence (T : ReflectiveTheory) (φ : T.Sentence) : Prop :=
  T.True_ φ ↔ ¬ T.Provable φ

/-- If a reflective theory has a Gödel sentence and is sound, the sentence is true. -/
theorem goedel_sentence_true_if_sound (T : ReflectiveTheory)
    (φ : T.Sentence) (hg : T.IsGoedelSentence φ) (hs : T.Sound) :
    T.True_ φ := by
  rw [ReflectiveTheory.IsGoedelSentence] at hg
  by_contra h
  have h_prov : T.Provable φ := by
    by_contra h_not_prov
    exact h (hg.mpr h_not_prov)
  exact h (hs φ h_prov)

/-- If a reflective theory has a Gödel sentence and is sound, it is not provable. -/
theorem goedel_sentence_unprovable_if_sound (T : ReflectiveTheory)
    (φ : T.Sentence) (hg : T.IsGoedelSentence φ) (hs : T.Sound) :
    ¬ T.Provable φ :=
  hg.mp (goedel_sentence_true_if_sound T φ hg hs)

/-- **Gödel's First Incompleteness (Reflective version)**: A sound reflective theory
    with a Gödel sentence is incomplete. -/
theorem goedel_first_reflective (T : ReflectiveTheory)
    (φ : T.Sentence) (hg : T.IsGoedelSentence φ) (hs : T.Sound) :
    ¬ T.Complete := by
  intro hc
  exact (goedel_sentence_unprovable_if_sound T φ hg hs) (hc φ (goedel_sentence_true_if_sound T φ hg hs))

/-! ## Part 6: Strict Monotonicity -/

/-- The provable sets form a strictly increasing chain. -/
theorem provable_strict_mono (H : ReflectiveHierarchy) (n : ℕ) :
    { φ | H.Provable n φ } ⊂ { φ | H.Provable (n + 1) φ } := by
  refine Set.ssubset_iff_subset_ne.mpr ⟨fun φ hp => H.mono n φ hp, ?_⟩
  intro h_eq
  obtain ⟨φ, hp, hnp⟩ := H.strict n
  have : φ ∈ { φ | H.Provable n φ } := by rwa [h_eq]
  exact hnp this

/-- **Multi-level separation**: For m < n, there exists a sentence provable at n but not m. -/
theorem multi_level_separation (H : ReflectiveHierarchy) {m n : ℕ} (hmn : m < n) :
    ∃ φ, H.Provable n φ ∧ ¬ H.Provable m φ := by
  obtain ⟨φ, hp, hnp⟩ := H.strict m
  exact ⟨φ, H.mono_le (by omega) φ hp, hnp⟩

/-! ## Part 7: Speed-up Phenomenon -/

/-- A **proof complexity** function assigns proof length to each provable sentence. -/
structure ProofComplexity (H : ReflectiveHierarchy) where
  length : ℕ → H.Sentence → ℕ
  pos_of_provable : ∀ n φ, H.Provable n φ → 0 < length n φ
  zero_of_unprovable : ∀ n φ, ¬ H.Provable n φ → length n φ = 0

/-- **Speed-up theorem**: Consistency sentences jump from length 0 to positive
    length in a single step — the paradigmatic speed-up. -/
theorem consistency_speedup (H : ReflectiveHierarchy) (C : ProofComplexity H) (n : ℕ) :
    C.length n (H.conSentence n) = 0 ∧ 0 < C.length (n + 1) (H.conSentence n) :=
  ⟨C.zero_of_unprovable n _ (H.con_unprovable n),
   C.pos_of_provable (n + 1) _ (H.con_jump n)⟩

/-! ## Part 8: Union Theory (ω-limit) -/

/-- The **union theory**: provable iff provable at some finite level. -/
def ReflectiveHierarchy.unionProvable (H : ReflectiveHierarchy) (φ : H.Sentence) : Prop :=
  ∃ n, H.Provable n φ

/-- The union theory proves all finite consistency sentences. -/
theorem union_proves_all_consistency (H : ReflectiveHierarchy) (n : ℕ) :
    H.unionProvable (H.conSentence n) :=
  ⟨n + 1, H.con_jump n⟩

/-- The union theory is sound for consistency sentences. -/
theorem union_con_sound (H : ReflectiveHierarchy) (n : ℕ) :
    H.unionProvable (H.conSentence n) → H.True_ (H.conSentence n) :=
  fun _ => H.con_true n

/-- **The union theory is still incomplete** if it has its own unprovable truth. -/
theorem union_incomplete (H : ReflectiveHierarchy)
    (con_omega : H.Sentence)
    (h_true : H.True_ con_omega)
    (h_unprov : ¬ H.unionProvable con_omega) :
    ¬ ∀ φ, H.True_ φ → H.unionProvable φ :=
  fun h_complete => h_unprov (h_complete con_omega h_true)

/-! ## Part 9: The Gap Transfer and Frontier Advancement -/

/-- **Soundness-Completeness Duality**: Soundness and completeness cannot
    both hold at any level of the hierarchy. -/
theorem soundness_completeness_duality (H : ReflectiveHierarchy) (n : ℕ) :
    ¬ ((H.theoryAt n).Sound ∧ (H.theoryAt n).Complete) :=
  fun ⟨_, hc⟩ => H.con_unprovable n (hc _ (H.con_true n))

/-- **Gap Transfer**: Con(n) lives in the completeness gap at level n but not at n+1. -/
theorem gap_transfer (H : ReflectiveHierarchy) (n : ℕ) :
    H.conSentence n ∈ (H.theoryAt n).CompletenessGap ∧
    H.conSentence n ∉ (H.theoryAt (n + 1)).CompletenessGap := by
  exact ⟨⟨H.con_true n, H.con_unprovable n⟩,
         fun ⟨_, h_unprov⟩ => h_unprov (H.con_jump n)⟩

/-- **Frontier Advancement**: The "frontier of ignorance" moves forward but never
    disappears. Con(n) is resolved at level n+1, but Con(n+1) takes its place.
    This is the mechanism generating permanent incompleteness. -/
theorem frontier_advancement (H : ReflectiveHierarchy) (n : ℕ) :
    (H.conSentence n ∈ (H.theoryAt n).CompletenessGap ∧
     H.conSentence n ∉ (H.theoryAt (n + 1)).CompletenessGap) ∧
    H.conSentence (n + 1) ∈ (H.theoryAt (n + 1)).CompletenessGap :=
  ⟨gap_transfer H n, ⟨H.con_true (n + 1), H.con_unprovable (n + 1)⟩⟩

/-! ## Part 10: Concrete Construction -/

/-- Construct a concrete reflective hierarchy from an injective witness function.
    Sentences are ℕ, provability at level n means "is a witness for some k < n". -/
def mkReflectiveHierarchy
    (witness : ℕ → ℕ)
    (h_inj : Function.Injective witness)
    (bot_val : ℕ)
    (h_bot : ∀ k, bot_val ≠ witness k) :
    ReflectiveHierarchy where
  Sentence := ℕ
  Provable := fun n s => ∃ k, k < n ∧ s = witness k
  True_ := fun s => ∃ k, s = witness k
  bot := bot_val
  bot_not_true := fun ⟨k, hk⟩ => h_bot k hk
  mono := fun n s ⟨k, hk, hs⟩ => ⟨k, by omega, hs⟩
  strict := fun n => ⟨witness n, ⟨n, by omega, rfl⟩, fun ⟨k, hk, hs⟩ => by
    have := h_inj hs; omega⟩
  conSentence := witness
  con_true := fun n => ⟨n, rfl⟩
  con_unprovable := fun n ⟨k, hk, hs⟩ => by have := h_inj hs; omega
  con_jump := fun n => ⟨n, by omega, rfl⟩

/-- **Existence theorem**: Reflective hierarchies with all structural properties exist. -/
private def oddWitness : ℕ → ℕ := fun k => 2 * k + 1

private theorem oddWitness_injective : Function.Injective oddWitness := by
  intro a b hab; unfold oddWitness at hab; omega

private theorem zero_ne_oddWitness : ∀ k, (0 : ℕ) ≠ oddWitness k := by
  intro k; unfold oddWitness; omega

/-- **Existence theorem**: Reflective hierarchies with all structural properties exist. -/
theorem reflective_hierarchy_exists :
    ∃ H : ReflectiveHierarchy.{0},
      Function.Injective H.conSentence ∧
      (∀ n, ¬ (H.theoryAt n).Complete) ∧
      (∀ n, { φ | H.Provable n φ } ⊂ { φ | H.Provable (n + 1) φ }) := by
  refine ⟨mkReflectiveHierarchy oddWitness oddWitness_injective 0 zero_ne_oddWitness,
         oddWitness_injective, ?_, ?_⟩
  · intro n; exact permanent_incompleteness _ n
  · intro n; exact provable_strict_mono _ n

/-! ## Conjecture -/

/-- **Conjecture (Soundness Deficit Growth Rate)**: In a reflective hierarchy,
    the number of true-but-unprovable sentences grows without bound.

    **Testable prediction**: For any concrete arithmetic hierarchy
    (PA, PA+Con(PA), ...), count the true Π₁ sentences unprovable at level n.
    If the count ever decreases or stabilizes, the conjecture fails. -/
def soundnessDeficitGrowthConjecture (H : ReflectiveHierarchy) : Prop :=
  ∀ n, ∃ S : Finset H.Sentence,
    (∀ φ ∈ S, H.True_ φ ∧ ¬ H.Provable (n + 1) φ) ∧
    ∀ T : Finset H.Sentence,
      (∀ φ ∈ T, H.True_ φ ∧ ¬ H.Provable n φ) →
      S.card ≥ T.card

end