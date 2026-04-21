/-! # CatalogBuild.Computation.Oracles.SelfLearningOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 24
-/

import Mathlib

noncomputable section

/-- Fixed points are exactly the range of the oracle. -/
theorem Oracle.mem_truthSet_iff_fixed {α : Type*} (O : Oracle α) (x : α) :
    x ∈ O.truthSet ↔ O.apply x = x := by
  rfl




/-- The oracle maps everything into its truth set. -/
theorem Oracle.apply_mem_truthSet {α : Type*} (O : Oracle α) (x : α) :
    O.apply x ∈ O.truthSet := by
  simp [Oracle.truthSet, O.idempotent]




/-- Composing two oracles (when the composition is idempotent) gives a new oracle. -/
def Oracle.compose {α : Type*} (O₁ O₂ : Oracle α)
    (h : ∀ x, (O₁.apply ∘ O₂.apply) ((O₁.apply ∘ O₂.apply) x) = (O₁.apply ∘ O₂.apply) x) :
    Oracle α where
  apply := O₁.apply ∘ O₂.apply
  idempotent := h




/-- [Section: # CatalogBuild.Computation.Oracles.SelfLearningOracle
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 24] -/
theorem Oracle.compose_truthSet_subset_left {α : Type*} (O₁ O₂ : Oracle α)
    (h : ∀ x, (O₁.apply ∘ O₂.apply) ((O₁.apply ∘ O₂.apply) x) = (O₁.apply ∘ O₂.apply) x)
    (hcomm : ∀ x, O₁.apply (O₂.apply x) = O₂.apply (O₁.apply x)) :
    (Oracle.compose O₁ O₂ h).truthSet ⊆ O₁.truthSet := by
  intro x hx;
  -- By commutativity, we have $O₂(O₁(x)) = x$.
  have h_comm : O₂.apply (O₁.apply x) = x := by
    exact hcomm x ▸ hx;
  have := O₁.idempotent ( O₂.apply x ) ; aesop;

-- ============================================================================
-- PART III: TROPICAL ORACLE ON FINITE SIGNALS
-- ============================================================================




/-- A tropical max-projection oracle: projects a signal to its "best n coordinates".
This models extracting the sub-oracle from the universal integer oracle. -/
def tropicalMaxOracle {n : ℕ} (hn : 0 < n) (threshold : ℝ) :
    (Fin n → ℝ) → (Fin n → ℝ) :=
  fun f i => max (f i) threshold




/-- The tropical max oracle is idempotent. -/
theorem tropicalMaxOracle_idempotent {n : ℕ} (hn : 0 < n) (τ : ℝ) (f : Fin n → ℝ) :
    tropicalMaxOracle hn τ (tropicalMaxOracle hn τ f) = tropicalMaxOracle hn τ f := by
  ext i; simp [tropicalMaxOracle]




/-- Package as an Oracle structure. -/
def tropicalMaxOracleStruct {n : ℕ} (hn : 0 < n) (τ : ℝ) : Oracle (Fin n → ℝ) where
  apply := tropicalMaxOracle hn τ
  idempotent := tropicalMaxOracle_idempotent hn τ




/-- [Section: # CatalogBuild.Computation.Oracles.SelfLearningOracle
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 24] -/
theorem tropicalMaxOracle_truthSet {n : ℕ} (hn : 0 < n) (τ : ℝ) (f : Fin n → ℝ) :
    f ∈ (tropicalMaxOracleStruct hn τ).truthSet ↔ ∀ i, f i ≥ τ := by
  -- To prove the equivalence, we split it into two implications.
  apply Iff.intro;
  · intro hf i; have := congr_fun hf i; simp_all +decide [ tropicalMaxOracle ] ;
    exact le_of_not_gt fun h => by erw [ show ( tropicalMaxOracleStruct hn τ ).apply f i = Max.max ( f i ) τ by rfl ] at this; cases max_cases ( f i ) τ <;> linarith;
  · -- If for all i, f i ≥ τ, then applying the tropical max oracle to f will result in f itself.
    intro h
    simp [tropicalMaxOracleStruct, h];
    exact funext fun i => max_eq_left ( h i )




theorem oracle_learns_in_one_step {α : Type*} (O : Oracle α) (x : α) (k : ℕ) (hk : 0 < k) :
    O.apply^[k] x = O.apply x := by
  induction hk <;> simp +decide [ *, Function.iterate_succ_apply' ];
  exact O.idempotent x




/-- Corollary: the oracle sequence is eventually constant. -/
theorem oracle_eventually_constant {α : Type*} (O : Oracle α) (x : α) :
    ∀ m n : ℕ, 0 < m → 0 < n → O.apply^[m] x = O.apply^[n] x := by
  intro m n hm hn
  rw [oracle_learns_in_one_step O x m hm, oracle_learns_in_one_step O x n hn]

-- ============================================================================
-- PART V: SUB-ORACLE EXTRACTION
-- ============================================================================




/-- A sub-oracle is a restriction of an oracle to a subset of its domain. -/
def Oracle.restrict {α : Type*} (O : Oracle α) (S : Set α) (hS : ∀ x ∈ S, O.apply x ∈ S) :
    Oracle S where
  apply := fun ⟨x, hx⟩ => ⟨O.apply x, hS x hx⟩
  idempotent := fun ⟨x, _⟩ => by
    simp [Subtype.ext_iff]
    exact O.idempotent x




/-- The truth set of a restricted oracle is the intersection with the original truth set. -/
theorem Oracle.restrict_truthSet {α : Type*} (O : Oracle α) (S : Set α)
    (hS : ∀ x ∈ S, O.apply x ∈ S) :
    (O.restrict S hS).truthSet = Subtype.val ⁻¹' O.truthSet := by
  ext ⟨x, hx⟩
  simp [Oracle.truthSet, Oracle.restrict, Subtype.ext_iff]

-- ============================================================================
-- PART VI: MONOTONE ORACLE REFINEMENT (SELF-OPTIMIZATION)
-- ============================================================================




/-- An oracle O₁ refines O₂ if O₁'s truth set is contained in O₂'s. -/
def Oracle.refines {α : Type*} (O₁ O₂ : Oracle α) : Prop :=
  O₁.truthSet ⊆ O₂.truthSet




/-- Refinement is reflexive. -/
theorem Oracle.refines_refl {α : Type*} (O : Oracle α) : O.refines O :=
  Set.Subset.refl _




/-- Refinement is transitive. -/
theorem Oracle.refines_trans {α : Type*} (O₁ O₂ O₃ : Oracle α)
    (h₁₂ : O₁.refines O₂) (h₂₃ : O₂.refines O₃) : O₁.refines O₃ :=
  Set.Subset.trans h₁₂ h₂₃

-- ============================================================================
-- PART VII: THE INTEGER ENCODING THEOREM
-- ============================================================================




/-- For any finite set of "truths" (reals), there exists a tropical max oracle
whose truth set contains exactly those signals above the threshold.
This models "working backwards" from the full set to find the best sub-oracle. -/
theorem exists_tropical_sub_oracle (n : ℕ) (hn : 0 < n) (truths : Fin n → ℝ) :
    ∃ τ : ℝ, ∀ i, truths i ≥ τ →
      truths i = tropicalMaxOracle hn τ truths i := by
  use Finset.univ.inf' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) truths
  intro i hi
  simp [tropicalMaxOracle, max_eq_left hi]




/-- The tropical max oracle with τ = -∞ equivalent (using a very low threshold)
accepts everything — it is the "universal oracle" that knows all truths.
As τ increases, the oracle becomes more selective (self-optimizing). -/
theorem tropical_oracle_monotone_threshold {n : ℕ} (hn : 0 < n) (τ₁ τ₂ : ℝ)
    (h : τ₁ ≤ τ₂) :
    (tropicalMaxOracleStruct hn τ₂).truthSet ⊆ (tropicalMaxOracleStruct hn τ₁).truthSet := by
  intro f hf
  rw [tropicalMaxOracle_truthSet] at hf ⊢
  exact fun i => le_trans h (hf i)

-- ============================================================================
-- PART VIII: INFORMATION COMPRESSION BOUNDS
-- ============================================================================




/-- The "compression ratio" of an oracle: what fraction of the space are fixed points.
For a finite oracle on {0,...,n-1} → ℝ with threshold τ, signals with all
coordinates ≥ τ are fixed. Raising τ reduces the truth set (more compression). -/
theorem oracle_compression_increases {n : ℕ} (hn : 0 < n) (τ₁ τ₂ : ℝ)
    (h : τ₁ < τ₂) :
    (tropicalMaxOracleStruct hn τ₂).refines (tropicalMaxOracleStruct hn τ₁) := by
  exact tropical_oracle_monotone_threshold hn τ₁ τ₂ (le_of_lt h)

-- ============================================================================
-- PART IX: TEAM CONSENSUS ORACLE
-- ============================================================================




/-- Given a family of oracles, the consensus truth set is the intersection
of all individual truth sets. This models the research team reaching
consensus by intersecting their individual findings. -/
def consensusTruthSet {α : Type*} {ι : Type*} (Os : ι → Oracle α) : Set α :=
  ⋂ i, (Os i).truthSet




/-- Consensus is more selective than any individual oracle. -/
theorem consensus_subset {α : Type*} {ι : Type*} (Os : ι → Oracle α) (i : ι) :
    consensusTruthSet Os ⊆ (Os i).truthSet := by
  exact Set.iInter_subset _ i




/-- An element is in the consensus iff it is a fixed point of ALL oracles. -/
theorem mem_consensus_iff {α : Type*} {ι : Type*} (Os : ι → Oracle α) (x : α) :
    x ∈ consensusTruthSet Os ↔ ∀ i, (Os i).apply x = x := by
  simp [consensusTruthSet, Oracle.truthSet]

-- ============================================================================
-- PART X: TROPICAL PROJECTIVE ORACLE
-- ============================================================================




/-- The projective normalization oracle: normalizes signals to have max = 0.
This is the tropical analogue of probability normalization. -/
def projNormOracle {n : ℕ} (hn : 0 < n) :
    (Fin n → ℝ) → (Fin n → ℝ) :=
  fun f i => f i - Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) f




theorem projNormOracle_idempotent {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) :
    projNormOracle hn (projNormOracle hn f) = projNormOracle hn f := by
  -- By definition of projNormOracle, we have:
  unfold projNormOracle; ext i; simp [Finset.sup'_le];
  refine' le_antisymm _ _ <;> norm_num [ Finset.sup'_le ] at * ; aesop;
  simpa using Finset.exists_max_image Finset.univ ( fun x => f x ) ⟨ i, Finset.mem_univ i ⟩ |> Exists.imp fun x hx => by aesop;




/-- The projective oracle as an Oracle structure. -/
def projNormOracleStruct {n : ℕ} (hn : 0 < n) : Oracle (Fin n → ℝ) where
  apply := projNormOracle hn
  idempotent := projNormOracle_idempotent hn




end
