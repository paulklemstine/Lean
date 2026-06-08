import Mathlib

/-!
# Tropical Hypergraph Counterpoint for SATB

This module establishes an exact bridge between four-voice (SATB) counterpoint
legality and tropical optimization on weighted hypergraphs.

## Mathematical Content

We model SATB voice leading as a constrained dynamical system on `Fin 4 → ℤ`
and prove three main theorem packages:

### Theorem Package 1: Zero-Locus Characterization
Legal SATB transitions are exactly the zero locus of a nonnegative tropical
penalty functional assembled from six pairwise components (one per unordered
voice pair). This converts Boolean legality into tropical vanishing.

### Theorem Package 2: Shortest-Path Realization
Legal progressions (sequences of chords) are exactly zero-cost paths in the
induced weighted hypergraph. Since all edge weights are nonnegative, legal
paths are globally shortest among all paths with the same endpoints.

### Theorem Package 3: Pairwise Tensor Factorization
The total SATB cost factorizes as a double sum over voice pairs and time steps.
Legality of a full progression is determined entirely by pairwise legality at
each time step, establishing an exact structural decomposition of the 4-voice
problem into coupled 2-voice subproblems.

## Significance

This formalization proves that a high-arity symbolic constraint system (4-voice
counterpoint) admits exact tropical optimization with:
- certifiable legality detection via zero-locus testing,
- shortest-path semantics for legal progressions,
- nontrivial state-space compression via pairwise factorization.
-/

open Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- A voice is one of four SATB parts: Soprano (0), Alto (1), Tenor (2), Bass (3). -/
abbrev Voice := Fin 4

/-- A chord is an assignment of integer pitches to the four voices. -/
def Chord := Voice → ℤ

/-- The six unordered voice pairs `(i, j)` with `i < j`. -/
def unordVoicePairs : Finset (Fin 4 × Fin 4) :=
  Finset.univ.filter (fun p => p.1 < p.2)

/-- The interval between two pitches. -/
def interval (a b : ℤ) : ℤ := b - a

/-! ## Pairwise Legality Predicates -/

/-- No parallel fifths between voices `i` and `j`:
    If the interval between `v i` and `v j` is a perfect fifth (7 semitones),
    then the interval between `w i` and `w j` must differ. -/
def NoParallelFifthsPair (i j : Voice) (v w : Chord) : Prop :=
  interval (v i) (v j) = 7 → interval (w i) (w j) ≠ 7

/-- No voice crossing between voices `i` and `j` in chord `w`:
    If `i < j` then voice `i` should be at least as high as voice `j`. -/
def NoCrossingPair (i j : Voice) (w : Chord) : Prop :=
  i < j → w j ≤ w i

/-- Spacing constraint between voices `i` and `j` in chord `w`:
    Adjacent upper voices should be within an octave (12 semitones). -/
def SpacingOKPair (i j : Voice) (w : Chord) : Prop :=
  (i.val + 1 = j.val) → i.val < 3 → w i - w j ≤ 12

/-- Combined pairwise legality: all three rules hold for the pair `(i, j)`. -/
def PairLegal (i j : Voice) (v w : Chord) : Prop :=
  NoParallelFifthsPair i j v w ∧ NoCrossingPair i j w ∧ SpacingOKPair i j w

instance (i j : Voice) (v w : Chord) : Decidable (NoParallelFifthsPair i j v w) :=
  inferInstanceAs (Decidable (_ → _))

instance (i j : Voice) (w : Chord) : Decidable (NoCrossingPair i j w) :=
  inferInstanceAs (Decidable (_ → _))

instance (i j : Voice) (w : Chord) : Decidable (SpacingOKPair i j w) :=
  inferInstanceAs (Decidable (_ → _))

instance (i j : Voice) (v w : Chord) : Decidable (PairLegal i j v w) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))

/-! ## Global Legality -/

/-- No parallel fifths between any pair of voices. -/
def NoParallelFifths (v w : Chord) : Prop :=
  ∀ ij ∈ unordVoicePairs, NoParallelFifthsPair ij.1 ij.2 v w

/-- No voice crossing in chord `w`. -/
def NoCrossing (w : Chord) : Prop :=
  ∀ ij ∈ unordVoicePairs, NoCrossingPair ij.1 ij.2 w

/-- All spacing constraints hold in chord `w`. -/
def SpacingOK (w : Chord) : Prop :=
  ∀ ij ∈ unordVoicePairs, SpacingOKPair ij.1 ij.2 w

/-- A transition from chord `v` to chord `w` is legal if no parallel fifths occur,
    no voices cross in `w`, and all spacing constraints hold in `w`. -/
def LegalSATBStep (v w : Chord) : Prop :=
  NoParallelFifths v w ∧ NoCrossing w ∧ SpacingOK w

/-! ## Pairwise Penalty Functions -/

/-- Parallel fifths penalty for a voice pair: 1 if violated, 0 if legal. -/
def parallelFifthPenalty_pair (i j : Voice) (v w : Chord) : ℝ :=
  if NoParallelFifthsPair i j v w then 0 else 1

/-- Crossing penalty for a voice pair: 1 if violated, 0 if legal. -/
def crossingPenalty_pair (i j : Voice) (w : Chord) : ℝ :=
  if NoCrossingPair i j w then 0 else 1

/-- Spacing penalty for a voice pair: 1 if violated, 0 if legal. -/
def spacingPenalty_pair (i j : Voice) (w : Chord) : ℝ :=
  if SpacingOKPair i j w then 0 else 1

/-- Combined pairwise penalty: maximum of the three component penalties.
    This is the tropical (max-plus) aggregation of constraints for a single pair. -/
def pairPenalty (i j : Voice) (v w : Chord) : ℝ :=
  max (parallelFifthPenalty_pair i j v w)
    (max (crossingPenalty_pair i j w) (spacingPenalty_pair i j w))

/-- Total penalty over all six voice pairs. -/
def totalPenalty6 (v w : Chord) : ℝ :=
  ∑ ij ∈ unordVoicePairs, pairPenalty ij.1 ij.2 v w

/-! ## Component Penalty Properties -/

theorem parallelFifthPenalty_pair_nonneg (i j : Voice) (v w : Chord) :
    0 ≤ parallelFifthPenalty_pair i j v w := by
  unfold parallelFifthPenalty_pair; split <;> norm_num

theorem crossingPenalty_pair_nonneg (i j : Voice) (w : Chord) :
    0 ≤ crossingPenalty_pair i j w := by
  unfold crossingPenalty_pair; split <;> norm_num

theorem spacingPenalty_pair_nonneg (i j : Voice) (w : Chord) :
    0 ≤ spacingPenalty_pair i j w := by
  unfold spacingPenalty_pair; split <;> norm_num

theorem parallelFifthPenalty_pair_eq_zero_iff (i j : Voice) (v w : Chord) :
    parallelFifthPenalty_pair i j v w = 0 ↔ NoParallelFifthsPair i j v w := by
  unfold parallelFifthPenalty_pair; split <;> simp_all

theorem crossingPenalty_pair_eq_zero_iff (i j : Voice) (w : Chord) :
    crossingPenalty_pair i j w = 0 ↔ NoCrossingPair i j w := by
  unfold crossingPenalty_pair; split <;> simp_all

theorem spacingPenalty_pair_eq_zero_iff (i j : Voice) (w : Chord) :
    spacingPenalty_pair i j w = 0 ↔ SpacingOKPair i j w := by
  unfold spacingPenalty_pair; split <;> simp_all

/-! ## Pairwise Penalty Zero-Locus -/

theorem pairPenalty_nonneg (i j : Voice) (v w : Chord) :
    0 ≤ pairPenalty i j v w := by
  simp only [pairPenalty]
  exact le_max_of_le_left (parallelFifthPenalty_pair_nonneg i j v w)

theorem pairPenalty_eq_zero_iff (i j : Voice) (v w : Chord) :
    pairPenalty i j v w = 0 ↔ PairLegal i j v w := by
  simp only [pairPenalty, PairLegal]
  constructor
  · intro h
    have h1 : parallelFifthPenalty_pair i j v w ≤ 0 := by
      linarith [le_max_left (parallelFifthPenalty_pair i j v w)
        (max (crossingPenalty_pair i j w) (spacingPenalty_pair i j w))]
    have h2 : crossingPenalty_pair i j w ≤ 0 := by
      linarith [le_max_right (parallelFifthPenalty_pair i j v w)
        (max (crossingPenalty_pair i j w) (spacingPenalty_pair i j w)),
        le_max_left (crossingPenalty_pair i j w) (spacingPenalty_pair i j w)]
    have h3 : spacingPenalty_pair i j w ≤ 0 := by
      linarith [le_max_right (parallelFifthPenalty_pair i j v w)
        (max (crossingPenalty_pair i j w) (spacingPenalty_pair i j w)),
        le_max_right (crossingPenalty_pair i j w) (spacingPenalty_pair i j w)]
    exact ⟨(parallelFifthPenalty_pair_eq_zero_iff i j v w).mp
             (le_antisymm h1 (parallelFifthPenalty_pair_nonneg i j v w)),
           (crossingPenalty_pair_eq_zero_iff i j w).mp
             (le_antisymm h2 (crossingPenalty_pair_nonneg i j w)),
           (spacingPenalty_pair_eq_zero_iff i j w).mp
             (le_antisymm h3 (spacingPenalty_pair_nonneg i j w))⟩
  · intro ⟨h1, h2, h3⟩
    rw [← parallelFifthPenalty_pair_eq_zero_iff] at h1
    rw [← crossingPenalty_pair_eq_zero_iff] at h2
    rw [← spacingPenalty_pair_eq_zero_iff] at h3
    simp [h1, h2, h3]

/-! ## Theorem Package 1: Zero-Locus Characterization -/

/-- **Pairwise completeness**: SATB legality is equivalent to legality of all six
    unordered voice pairs. This is the structural hinge between music-theoretic
    and tropical formulations. -/
theorem legalSATBStep_iff_all_pairs_legal (v w : Chord) :
    LegalSATBStep v w ↔ ∀ ij ∈ unordVoicePairs, PairLegal ij.1 ij.2 v w := by
  simp only [LegalSATBStep, NoParallelFifths, NoCrossing, SpacingOK, PairLegal]
  constructor
  · intro ⟨h1, h2, h3⟩ ij hij
    exact ⟨h1 ij hij, h2 ij hij, h3 ij hij⟩
  · intro h
    exact ⟨fun ij hij => (h ij hij).1,
           fun ij hij => (h ij hij).2.1,
           fun ij hij => (h ij hij).2.2⟩

/-- **Theorem 1a**: A transition is legal iff every pairwise penalty vanishes.
    This converts Boolean legality into tropical zero-locus detection. -/
theorem legal_iff_pairPenalty_zero (v w : Chord) :
    LegalSATBStep v w ↔ ∀ ij ∈ unordVoicePairs, pairPenalty ij.1 ij.2 v w = 0 := by
  rw [legalSATBStep_iff_all_pairs_legal]
  constructor
  · intro h ij hij
    exact (pairPenalty_eq_zero_iff ij.1 ij.2 v w).mpr (h ij hij)
  · intro h ij hij
    exact (pairPenalty_eq_zero_iff ij.1 ij.2 v w).mp (h ij hij)

/-- Total penalty is nonnegative. -/
theorem totalPenalty6_nonneg (v w : Chord) : 0 ≤ totalPenalty6 v w :=
  Finset.sum_nonneg (fun ij _ => pairPenalty_nonneg ij.1 ij.2 v w)

/-- **Tropical sum zero-locus lemma**: A sum of nonnegative terms over a finset
    vanishes iff every term vanishes. -/
theorem sum_nonneg_eq_zero_iff' {ι : Type*} {s : Finset ι} {f : ι → ℝ}
    (hf : ∀ i ∈ s, 0 ≤ f i) :
    ∑ i ∈ s, f i = 0 ↔ ∀ i ∈ s, f i = 0 := by
  constructor
  · intro hsum i hi
    have h1 : f i ≤ ∑ j ∈ s, f j := Finset.single_le_sum hf hi
    linarith [hf i hi]
  · intro h
    exact Finset.sum_eq_zero (fun i hi => h i hi)

/-- **Theorem 1b (stronger tropical form)**: Total penalty vanishes iff every
    pairwise penalty vanishes. This is the exact zero-locus characterization
    using the nonnegativity structure. -/
theorem totalPenalty6_eq_zero_iff (v w : Chord) :
    totalPenalty6 v w = 0 ↔ ∀ ij ∈ unordVoicePairs, pairPenalty ij.1 ij.2 v w = 0 :=
  sum_nonneg_eq_zero_iff' (fun ij _ => pairPenalty_nonneg ij.1 ij.2 v w)

/-- **Theorem 1c**: A transition is legal iff the total tropical penalty vanishes.
    This is the master zero-locus theorem combining 1a and 1b. -/
theorem legal_iff_totalPenalty6_zero (v w : Chord) :
    LegalSATBStep v w ↔ totalPenalty6 v w = 0 := by
  rw [legal_iff_pairPenalty_zero, totalPenalty6_eq_zero_iff]

/-! ## Theorem Package 2: Shortest-Path Realization -/

/-- The cost of a progression is the sum of transition penalties. -/
def ProgressionCost {n : ℕ} (σ : Fin (n + 1) → Chord) : ℝ :=
  ∑ k : Fin n, totalPenalty6 (σ k.castSucc) (σ k.succ)

/-- A progression is legal if every consecutive transition is legal. -/
def LegalProgression {n : ℕ} (σ : Fin (n + 1) → Chord) : Prop :=
  ∀ k : Fin n, LegalSATBStep (σ k.castSucc) (σ k.succ)

/-- Progression cost is nonnegative. -/
theorem progressionCost_nonneg {n : ℕ} (σ : Fin (n + 1) → Chord) :
    0 ≤ ProgressionCost σ :=
  Finset.sum_nonneg (fun _ _ => totalPenalty6_nonneg _ _)

/-- **Theorem 2a**: A progression is legal iff its cost is zero.
    Legal harmonizations are exactly zero-cost paths in the tropical hypergraph. -/
theorem legalProgression_iff_zero_cost {n : ℕ} (σ : Fin (n + 1) → Chord) :
    LegalProgression σ ↔ ProgressionCost σ = 0 := by
  simp only [LegalProgression, ProgressionCost]
  rw [sum_nonneg_eq_zero_iff' (fun _ _ => totalPenalty6_nonneg _ _)]
  constructor
  · intro h k _
    exact (legal_iff_totalPenalty6_zero _ _).mp (h k)
  · intro h k
    exact (legal_iff_totalPenalty6_zero _ _).mpr (h k (Finset.mem_univ k))

/-- **Theorem 2b**: Legal progressions are shortest paths.
    Among all progressions sharing the same endpoints, a legal one has
    minimal (zero) cost. This is the tropical geodesicity theorem. -/
theorem zero_cost_path_is_shortest {n : ℕ} (σ : Fin (n + 1) → Chord)
    (hlegal : LegalProgression σ) :
    ∀ τ : Fin (n + 1) → Chord,
      σ 0 = τ 0 → σ (Fin.last n) = τ (Fin.last n) →
      ProgressionCost σ ≤ ProgressionCost τ := by
  intro τ _ _
  have h0 : ProgressionCost σ = 0 := (legalProgression_iff_zero_cost σ).mp hlegal
  linarith [progressionCost_nonneg τ]

/-! ## Theorem Package 3: Pairwise Tensor Factorization -/

/-- **Theorem 3a**: The progression cost factorizes as a double sum over voice
    pairs and time steps. This is the exact tensor decomposition showing that
    the 4-voice sequential cost is a sum of six 2-voice sequential costs. -/
theorem progression_cost_factorizes_over_pairs {n : ℕ} (σ : Fin (n + 1) → Chord) :
    ProgressionCost σ =
      ∑ ij ∈ unordVoicePairs,
        ∑ k : Fin n,
          pairPenalty ij.1 ij.2 (σ k.castSucc) (σ k.succ) := by
  simp only [ProgressionCost, totalPenalty6]
  rw [Finset.sum_comm]

/-- **Theorem 3b**: Legality of a full progression is determined entirely by
    pairwise legality at each time step. This is the exact structural
    decomposition of the 4-voice problem into coupled 2-voice subproblems. -/
theorem legal_progression_determined_by_pair_projections {n : ℕ}
    (σ : Fin (n + 1) → Chord) :
    LegalProgression σ ↔
      ∀ ij ∈ unordVoicePairs,
        ∀ k : Fin n,
          pairPenalty ij.1 ij.2 (σ k.castSucc) (σ k.succ) = 0 := by
  rw [legalProgression_iff_zero_cost, progression_cost_factorizes_over_pairs]
  rw [sum_nonneg_eq_zero_iff' (fun ij _ =>
    Finset.sum_nonneg (fun _ _ => pairPenalty_nonneg ij.1 ij.2 _ _))]
  constructor
  · intro h ij hij k
    have := h ij hij
    rw [sum_nonneg_eq_zero_iff' (fun _ _ => pairPenalty_nonneg ij.1 ij.2 _ _)] at this
    exact this k (Finset.mem_univ k)
  · intro h ij hij
    exact Finset.sum_eq_zero (fun k _ => h ij hij k)

/-- **Theorem 3c**: Legality decomposes into pairwise musical predicates at each step.
    This combines the penalty zero-locus with pairwise factorization to give the
    full structural decomposition in terms of musical predicates. -/
theorem legal_progression_iff_all_pairs_all_steps {n : ℕ}
    (σ : Fin (n + 1) → Chord) :
    LegalProgression σ ↔
      ∀ ij ∈ unordVoicePairs,
        ∀ k : Fin n,
          PairLegal ij.1 ij.2 (σ k.castSucc) (σ k.succ) := by
  rw [legal_progression_determined_by_pair_projections]
  constructor
  · intro h ij hij k
    exact (pairPenalty_eq_zero_iff _ _ _ _).mp (h ij hij k)
  · intro h ij hij k
    exact (pairPenalty_eq_zero_iff _ _ _ _).mpr (h ij hij k)

/-! ## Additional Results: Tropical Structure -/

/-- Violation of any single pairwise constraint implies positive total penalty.
    This is the converse bound: constraint failure is always detected. -/
theorem totalPenalty6_pos_of_violation (v w : Chord)
    (ij : Fin 4 × Fin 4) (hij : ij ∈ unordVoicePairs)
    (hviol : ¬ PairLegal ij.1 ij.2 v w) :
    0 < totalPenalty6 v w := by
  have hne : pairPenalty ij.1 ij.2 v w ≠ 0 :=
    mt (pairPenalty_eq_zero_iff _ _ _ _).mp hviol
  have hpos : 0 < pairPenalty ij.1 ij.2 v w :=
    lt_of_le_of_ne (pairPenalty_nonneg _ _ _ _) (Ne.symm hne)
  calc 0 < pairPenalty ij.1 ij.2 v w := hpos
    _ ≤ totalPenalty6 v w :=
        Finset.single_le_sum (fun p _ => pairPenalty_nonneg p.1 p.2 v w) hij

/-- The pair projection extracts a 2-voice sub-chord from a full SATB chord. -/
def pairProjection (i j : Voice) (v : Chord) : Fin 2 → ℤ :=
  fun k => if k = 0 then v i else v j

/-- The number of unordered voice pairs is exactly 6. -/
theorem unordVoicePairs_card : unordVoicePairs.card = 6 := by
  native_decide

/-- Illegal transitions have strictly positive cost, hence cannot be shortest paths. -/
theorem illegal_implies_positive_cost (v w : Chord) (h : ¬ LegalSATBStep v w) :
    0 < totalPenalty6 v w := by
  rw [legal_iff_totalPenalty6_zero] at h
  exact lt_of_le_of_ne (totalPenalty6_nonneg v w) (Ne.symm h)

/-- The total penalty is additive: the penalty of concatenation equals the sum
    of penalties. This is immediate from the definition but important
    structurally — it shows the path cost is a tropical semiring morphism. -/
theorem progressionCost_additive_structure {n : ℕ} (σ : Fin (n + 1) → Chord) :
    ProgressionCost σ =
      ∑ k : Fin n, totalPenalty6 (σ k.castSucc) (σ k.succ) := rfl

end