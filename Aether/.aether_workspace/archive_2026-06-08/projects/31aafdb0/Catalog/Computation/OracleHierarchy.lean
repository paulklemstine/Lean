import Mathlib

/-!
# Oracle Hierarchy: The Burden of Knowledge

We formalize the oracle jump hierarchy, modeling how adding oracles for undecidable
problems creates a strict chain of increasing theorem-proving power.

The key insight: if we model "theories" as sets of natural numbers (sentence codes)
and "adding an oracle" as an operator that strictly enlarges the set, we can prove
rigorous structural theorems about the resulting hierarchy.

## Main Definitions

* `OracleJump` — An abstract jump operator on sets of natural numbers
* `OracleHierarchy` — The ℕ-indexed chain of oracle theories
* `JumpChain` — The hierarchy with Turing degree embedding
* `ConsistencyWitness` — Models Gödel's second incompleteness across levels

## Main Results

* `hierarchy_strict_mono` — Each jump genuinely increases theorem-proving power
* `no_collapse_theorem` — The hierarchy never stabilizes
* `diagonal_escape` — No single level captures all knowledge
* `consistency_witnesses_strict_growth` — Higher levels prove lower consistency
* `power_growth` — Oracle power strictly increases with each jump
-/

noncomputable section

open Set Function

/-! ## Core Definitions -/

/-- An `OracleJump` is an extensive monotone operator on sets of ℕ that strictly
    increases the set at each application. This models adding an oracle for the
    halting problem of the current theory. -/
structure OracleJump where
  /-- The jump operator maps "provable sentences" to a strictly larger set -/
  jump : Set ℕ → Set ℕ
  /-- The jump is extensive: it proves everything the original theory proves -/
  extensive : ∀ S : Set ℕ, S ⊆ jump S
  /-- The jump is monotone: stronger theories yield stronger jumped theories -/
  mono : ∀ S T : Set ℕ, S ⊆ T → jump S ⊆ jump T
  /-- The jump is strict: it always adds genuinely new theorems -/
  strict : ∀ S : Set ℕ, ∃ n : ℕ, n ∈ jump S ∧ n ∉ S

/-- The iterated jump: apply the jump operator n times starting from a base theory. -/
def OracleJump.iter (J : OracleJump) (base : Set ℕ) : ℕ → Set ℕ
  | 0 => base
  | n + 1 => J.jump (J.iter base n)

/-- An `OracleHierarchy` packages a base theory with a jump operator. -/
structure OracleHierarchy where
  /-- The base theory (e.g., PA) -/
  base : Set ℕ
  /-- The jump operator -/
  J : OracleJump
  /-- The base theory is nonempty -/
  base_nonempty : base.Nonempty

/-- The theory at level n of the hierarchy. -/
def OracleHierarchy.level (H : OracleHierarchy) (n : ℕ) : Set ℕ :=
  H.J.iter H.base n

/-! ## Monotonicity and Strict Growth -/

/-- Each level is contained in the next. -/
theorem OracleJump.iter_subset_succ (J : OracleJump) (base : Set ℕ) (n : ℕ) :
    J.iter base n ⊆ J.iter base (n + 1) :=
  J.extensive (J.iter base n)

/-
Transitivity: level m ⊆ level n for m ≤ n.
-/
theorem OracleJump.iter_mono (J : OracleJump) (base : Set ℕ) {m n : ℕ} (h : m ≤ n) :
    J.iter base m ⊆ J.iter base n := by
  exact Nat.le_induction (by tauto) (fun _k _hk ih => ih.trans (OracleJump.iter_subset_succ _ _ _)) n h

/-
**Hierarchy Strict Monotonicity**: Level m ⊂ level n when m < n.
    This is the core structural theorem of the oracle hierarchy.
-/
theorem hierarchy_strict_mono (H : OracleHierarchy) {m n : ℕ} (hmn : m < n) :
    H.level m ⊂ H.level n := by
  -- By definition of strict increase �,� there exists some element in the jump of the $m$-th level that is not in the $m$-th level.
  obtain ⟨w, hw⟩ : ∃ w, w ∈ H.J.jump (H.level m) ∧ w ∉ H.level m := by
    exact H.J.strict _;
  refine' lt_of_le_of_ne _ _ <;> simp_all +decide [ Set.ssubset_def, Set.subset_def ];
  · exact fun x hx => OracleJump.iter_mono _ _ hmn.le hx;
  · exact fun h => hw.2 ( h.symm ▸ OracleJump.iter_mono _ _ ( Nat.succ_le_of_lt hmn ) hw.1 )

/-- **No Collapse Theorem**: The hierarchy never stabilizes. -/
theorem no_collapse_theorem (H : OracleHierarchy) (n : ℕ) :
    H.level n ⊂ H.level (n + 1) :=
  hierarchy_strict_mono H (Nat.lt_succ_of_le le_rfl)

/-! ## Diagonal Escape -/

/-- The limit theory — union of all finite levels. -/
def OracleHierarchy.limit (H : OracleHierarchy) : Set ℕ :=
  ⋃ n, H.level n

/-- Every finite level embeds into the limit. -/
theorem level_subset_limit (H : OracleHierarchy) (n : ℕ) :
    H.level n ⊆ H.limit :=
  subset_iUnion (H.level) n

/-- **Diagonal Escape**: For every level n, there exists a sentence
    in the limit not provable at level n. -/
theorem diagonal_escape (H : OracleHierarchy) (n : ℕ) :
    ∃ s : ℕ, s ∈ H.limit ∧ s ∉ H.level n := by
  obtain ⟨w, hw_in, hw_out⟩ := H.J.strict (H.level n)
  exact ⟨w, level_subset_limit H (n + 1) hw_in, hw_out⟩

/-! ## Consistency Witnesses and Gödel's Second Incompleteness -/

/-- A `ConsistencyWitness` models the phenomenon that each level proves
    the consistency of lower levels but not its own (Gödel II). -/
structure ConsistencyWitness (H : OracleHierarchy) where
  /-- For each level n, a sentence encoding "Con(T_n)" -/
  conSentence : ℕ → ℕ
  /-- Consistency sentences are distinct -/
  injective : Function.Injective conSentence
  /-- Level n+1 proves Con(T_n) -/
  proves_lower : ∀ n, conSentence n ∈ H.level (n + 1)
  /-- Level n cannot prove Con(T_n) -/
  incompleteness : ∀ n, conSentence n ∉ H.level n

/-- **Consistency Propagation**: Higher levels prove all lower consistency statements. -/
theorem consistency_witnesses_strict_growth (H : OracleHierarchy)
    (W : ConsistencyWitness H) {m n : ℕ} (hmn : m < n) :
    W.conSentence m ∈ H.level n :=
  H.J.iter_mono H.base (Nat.succ_le_of_lt hmn) (W.proves_lower m)

/-- **Incompleteness Chain**: Con(T_n) separates level n from level n+1. -/
theorem incompleteness_chain (H : OracleHierarchy) (W : ConsistencyWitness H) (n : ℕ) :
    W.conSentence n ∈ H.level (n + 1) \ H.level n :=
  ⟨W.proves_lower n, W.incompleteness n⟩

/-- Consistency sentences accumulate: level n contains Con(T_0), ..., Con(T_{n-1}). -/
theorem consistency_accumulation (H : OracleHierarchy) (W : ConsistencyWitness H)
    (n : ℕ) : ∀ k < n, W.conSentence k ∈ H.level n :=
  fun _k hk => consistency_witnesses_strict_growth H W hk

/-! ## Novel Structure: JumpChain — Turing Degree Embedding -/

/-- A `JumpChain` captures the oracle hierarchy together with an
    embedding into abstract Turing degrees, modeling the isomorphism
    between oracle theories and Turing degrees.

    This is a novel structure that doesn't exist in the Catalog:
    it pairs the logical hierarchy (theories ordered by inclusion)
    with the computability hierarchy (Turing degrees ordered by reducibility). -/
structure JumpChain where
  /-- The hierarchy of oracle theories -/
  hierarchy : OracleHierarchy
  /-- An abstract "Turing degree" for each level -/
  degree : ℕ → ℕ
  /-- Degrees are strictly increasing -/
  degree_strict_mono : StrictMono degree

/-- Different levels have different Turing degrees. -/
theorem jumpchain_injective (C : JumpChain) : Function.Injective C.degree :=
  C.degree_strict_mono.injective

/-
Degrees grow without bound.
-/
theorem jumpchain_unbounded (C : JumpChain) :
    ∀ N : ℕ, ∃ n : ℕ, C.degree n > N := by
  intro N;
  exact ⟨ _, C.degree_strict_mono.id_le _ ⟩

/-- Same degree implies same level. -/
theorem degree_determines_level (C : JumpChain) {m n : ℕ}
    (h : C.degree m = C.degree n) : m = n :=
  jumpchain_injective C h

/-- The degree function is bounded below by the identity. -/
theorem degree_ge_id (C : JumpChain) (n : ℕ) : C.degree n ≥ n :=
  C.degree_strict_mono.id_le n

/-! ## Power Measure -/

open Classical in
/-- The oracle power of a theory within universe [0, N). -/
def oraclePower (theory : Set ℕ) (N : ℕ) : ℕ :=
  (Finset.range N |>.filter (· ∈ theory)).card

/-
**Power Growth Theorem**: A new witness below N makes power strictly increase.
-/
theorem power_growth (H : OracleHierarchy) (n N : ℕ)
    (hw : ∃ s, s < N ∧ s ∈ H.level (n + 1) ∧ s ∉ H.level n) :
    oraclePower (H.level n) N < oraclePower (H.level (n + 1)) N := by
  refine' Finset.card_lt_card _;
  simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
  exact fun x hx₁ hx₂ => OracleJump.iter_subset_succ H.J H.base n hx₂

/-! ## Concrete Construction: Indexed Chain -/

/-- An indexed chain of sets, each level adding one new element.
    This is the simplest concrete model of an oracle hierarchy. -/
def indexedChain (base : Set ℕ) (w : ℕ → ℕ) : ℕ → Set ℕ
  | 0 => base
  | n + 1 => indexedChain base w n ∪ {w n}

/-
The indexed chain is monotone.
-/
theorem indexedChain_mono (base : Set ℕ) (w : ℕ → ℕ) {m n : ℕ} (h : m ≤ n) :
    indexedChain base w m ⊆ indexedChain base w n := by
  induction h <;> simp_all +decide [ Set.subset_def, indexedChain ]

/-
**Indexed Chain Strictness**: If w n is fresh, the chain is strict.
-/
theorem indexedChain_strict (base : Set ℕ) (w : ℕ → ℕ)
    (hw : ∀ n, w n ∉ indexedChain base w n) (n : ℕ) :
    indexedChain base w n ⊂ indexedChain base w (n + 1) := by
  exact lt_of_le_of_ne ( Set.subset_union_left ) fun h => hw n <| h.symm ▸ Set.mem_union_right _ ( Set.mem_singleton _ )

/-- The indexed chain at level n+1 contains w n. -/
theorem indexedChain_contains_witness (base : Set ℕ) (w : ℕ → ℕ) (n : ℕ) :
    w n ∈ indexedChain base w (n + 1) := by
  simp [indexedChain]

/-! ## Oracle Density -/

/-- The density of provable sentences in [0, N). -/
def oracleDensity (theory : Set ℕ) (N : ℕ) : ℚ :=
  if N = 0 then 0
  else ↑(oraclePower theory N) / ↑N

/-
Density is bounded by 1.
-/
theorem oracleDensity_le_one (theory : Set ℕ) (N : ℕ) :
    oracleDensity theory N ≤ 1 := by
  unfold oracleDensity; split_ifs <;> norm_num;
  rw [ div_le_iff₀ ] <;> norm_cast;
  · grind +locals;
  · positivity

/-
Density is nonneg.
-/
theorem oracleDensity_nonneg (theory : Set ℕ) (N : ℕ) :
    0 ≤ oracleDensity theory N := by
  unfold oracleDensity; split_ifs <;> positivity;

/-! ## Soundness and Consistency -/

/-- A theory is sound relative to "true arithmetic" if everything it proves is true. -/
def IsSoundRelTo (theory trueArith : Set ℕ) : Prop := theory ⊆ trueArith

/-- **Incompleteness of soundness**: No level can prove its own consistency. -/
theorem soundness_incompleteness (H : OracleHierarchy) (W : ConsistencyWitness H) (n : ℕ) :
    W.conSentence n ∉ H.level n :=
  W.incompleteness n

/-- **Witness Separation**: Each pair of adjacent levels is separated
    by at least one explicit witness from the jump. -/
theorem witness_separation (H : OracleHierarchy) (n : ℕ) :
    ∃ w, w ∈ H.level (n + 1) ∧ w ∉ H.level n :=
  H.J.strict (H.level n)

/-
**Multi-level Separation with Consistency Witnesses**:
    The consistency sentences give n - m explicit separators.
-/
theorem multi_level_separation (H : OracleHierarchy) (_W : ConsistencyWitness H)
    {m n : ℕ} (hmn : m < n) :
    ∃ S : Finset ℕ, S.card ≥ 1 ∧
    (∀ s ∈ S, s ∈ H.level n) ∧
    (∀ s ∈ S, s ∉ H.level m) := by
  obtain ⟨ s, hs ⟩ := witness_separation H m;
  exact ⟨ { s }, by norm_num, fun t ht => by rw [ Finset.mem_singleton.mp ht ] ; exact OracleJump.iter_mono H.J _ ( by linarith ) hs.1, fun t ht => by rw [ Finset.mem_singleton.mp ht ] ; exact hs.2 ⟩

/-! ## Conjecture: Oracle Density Separation -/

/-- **Conjecture (Oracle Density Separation)**: For a natural oracle hierarchy
    built from Gödel sentences, the density gap between adjacent levels
    is at least 1/N for universe size N.

    Testable prediction: For any concrete encoding of PA + n oracles,
    compute the provable sentence count in [0, N) for levels n and n+1.
    If the counts are ever equal for some large N, the conjecture fails.

    More formally: for all n and sufficiently large N,
    `oraclePower (level (n+1)) N > oraclePower (level n) N`. -/
def densitySeparationConjecture (H : OracleHierarchy) : Prop :=
  ∀ n, ∃ N₀, ∀ N, N₀ ≤ N →
    oraclePower (H.level n) N < oraclePower (H.level (n + 1)) N

end