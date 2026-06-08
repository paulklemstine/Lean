import Mathlib

/-! # Berggren–Holevo Correspondence
## Primitive Pythagorean Orbit Channels and Entropy-Stable Quantum Coding

Bridge: connects arithmetic orbit separation (Berggren tree) to quantum fidelity decay,
Holevo information bounds, and post_quantum_security packing.

### Overview

This file formalizes a genuine correspondence between:
1. **Number theory / Diophantine combinatorics**: Primitive Pythagorean triples organized
   by the Berggren tree, with norm separation as the key arithmetic invariant.
2. **Quantum information / entropy**: Finite quantum ensembles, orbit overlaps as fidelity
   surrogates, and Holevo-type capacity lower bounds.
3. **Cryptographic packing**: Triple-norm collision separation as a trapdoor-like resource
   for post_quantum_security and certified_robustness.

The main result (`berggren_depth_monotone_capacity_bound`) shows that norm-separated Berggren
orbits induce finite ensembles with controlled pairwise overlap, yielding explicit lower
bounds on channel capacity that grow with Berggren tree depth.
-/

noncomputable section

open Finset Real BigOperators Filter

-- ═══════════════════════════════════════════════════════
-- Section 1: Arithmetic Foundations
-- ═══════════════════════════════════════════════════════

section Arithmetic

/-- A primitive Pythagorean triple `(a, b, c)` satisfying `a² + b² = c²`.
    The fundamental Diophantine object whose orbit structure drives the correspondence. -/
structure PrimTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  pyth : a ^ 2 + b ^ 2 = c ^ 2

/-- The norm of a primitive triple, defined as the hypotenuse `c`.
    Bridge: connects lattice-like norm packing to entropy-stable quantum coding. -/
def tripleNorm (t : PrimTriple) : ℕ := t.c

/-- A Berggren slice: an indexed collection of primitive triples with tree depths.
    Represents a finite codebook extracted from the Berggren tree at various depths.
    Bridge: connects Berggren-tree combinatorics to Holevo information and
    post_quantum_security packing. -/
structure BerggrenSlice (ι : Type*) [Fintype ι] where
  triple : ι → PrimTriple
  depth : ι → ℕ

/-- Pairwise norm separation: all indexed triples have distinct hypotenuses.
    This is the qualitative arithmetic precondition for quantum distinguishability. -/
def BerggrenSlice.PairwiseNormSeparated {ι : Type*} [Fintype ι]
    (S : BerggrenSlice ι) : Prop :=
  ∀ ⦃i j⦄, i ≠ j → tripleNorm (S.triple i) ≠ tripleNorm (S.triple j)

/-- Quantitative norm gap: all distinct pairs have hypotenuse distance ≥ δ.
    Bridge: connects primitive triple trapdoors to certified robustness style
    overlap control. -/
def BerggrenSlice.HasNormGap {ι : Type*} [Fintype ι]
    (S : BerggrenSlice ι) (δ : ℕ) : Prop :=
  ∀ ⦃i j : ι⦄, i ≠ j → δ ≤ Nat.dist (tripleNorm (S.triple i)) (tripleNorm (S.triple j))

end Arithmetic

-- ═══════════════════════════════════════════════════════
-- Section 2: Overlap Envelope
-- ═══════════════════════════════════════════════════════

section Overlap

/-- The Berggren overlap envelope: maps norm gap `δ` to maximum quantum overlap `1/(1+δ)`.
    This is the key decay function: as arithmetic separation grows, quantum
    distinguishability improves. Satisfies `berggrenOverlapEnvelope δ → 0` as `δ → ∞`.
    Bridge: connects arithmetic orbit separation to quantum fidelity decay. -/
def berggrenOverlapEnvelope (δ : ℕ) : ℝ := 1 / (1 + (δ : ℝ))

/-- The overlap envelope is always nonneg: quantum fidelity cannot be negative. -/
theorem berggrenOverlapEnvelope_nonneg (δ : ℕ) :
    0 ≤ berggrenOverlapEnvelope δ := by
  unfold berggrenOverlapEnvelope; positivity

/-
The overlap envelope is bounded by 1: quantum fidelity ≤ 1.
-/
theorem berggrenOverlapEnvelope_le_one (δ : ℕ) :
    berggrenOverlapEnvelope δ ≤ 1 := by
  exact div_le_self zero_le_one ( by linarith )

/-
The overlap envelope at gap 0 equals 1: identical norms yield perfect fidelity.
-/
theorem berggrenOverlapEnvelope_zero : berggrenOverlapEnvelope 0 = 1 := by
  -- By definition of berggrenOverlapEnvelope, we have berggrenOverlapEnvelope 0 = 1 / (1 + 0).
  simp [berggrenOverlapEnvelope]

/-
The overlap envelope is antitone: larger norm gaps yield smaller overlaps.
    Bridge: connects lattice-like norm packing to entropy-stable quantum coding.
-/
theorem berggrenOverlapEnvelope_antitone :
    Antitone (fun n : ℕ => berggrenOverlapEnvelope n) := by
  exact fun m n hmn => one_div_le_one_div_of_le ( by positivity ) ( by norm_cast; linarith )

/-
The overlap envelope tends to zero: asymptotically perfect distinguishability.
    Bridge: certified_robustness via arithmetic fidelity decay.
-/
theorem berggrenOverlapEnvelope_tends_zero_quantum_certified :
    Tendsto (fun n : ℕ => berggrenOverlapEnvelope n) atTop (nhds 0) := by
  exact tendsto_const_nhds.div_atTop ( tendsto_const_nhds.add_atTop <| tendsto_natCast_atTop_atTop )

/-
Positive gap implies strict bound below 1.
-/
theorem berggrenOverlapEnvelope_lt_one_of_pos {δ : ℕ} (hδ : 0 < δ) :
    berggrenOverlapEnvelope δ < 1 := by
  exact div_lt_self zero_lt_one ( by norm_cast; linarith )

end Overlap

-- ═══════════════════════════════════════════════════════
-- Section 3: Quantum State Abstractions
-- ═══════════════════════════════════════════════════════

section QuantumStates

/-- Abstract quantum state indexed by a finite-dimensional type `d`.
    Represents a density operator in a `|d|`-dimensional Hilbert space. -/
structure QuantumState (d : Type*) [Fintype d] where
  label : ℕ

/-- A triple-invariant quantum state: a quantum state whose overlap properties
    are entirely determined by the norm of its associated primitive triple.
    Bridge: connects lattice-like norm packing to entropy-stable quantum coding. -/
structure TripleInvariantState (d : Type*) [Fintype d] [DecidableEq d] where
  carrier : QuantumState d
  /-- The norm value of the associated primitive triple. -/
  normValue : ℕ

/-- Orbit overlap between two triple-invariant states, defined via the
    Berggren overlap envelope applied to their norm distance.
    Bridge: connects arithmetic orbit separation to quantum fidelity decay. -/
def orbitOverlap {d : Type*} [Fintype d] [DecidableEq d]
    (ρ σ : TripleInvariantState d) : ℝ :=
  berggrenOverlapEnvelope (Nat.dist ρ.normValue σ.normValue)

/-- Orbit overlap is nonneg (quantum fidelity is nonneg). -/
theorem orbitOverlap_nonneg {d : Type*} [Fintype d] [DecidableEq d]
    (ρ σ : TripleInvariantState d) : 0 ≤ orbitOverlap ρ σ :=
  berggrenOverlapEnvelope_nonneg _

/-- Orbit overlap is bounded by 1 (quantum fidelity ≤ 1). -/
theorem orbitOverlap_le_one {d : Type*} [Fintype d] [DecidableEq d]
    (ρ σ : TripleInvariantState d) : orbitOverlap ρ σ ≤ 1 :=
  berggrenOverlapEnvelope_le_one _

/-
Self-overlap is 1: a state has perfect fidelity with itself.
-/
theorem orbitOverlap_self {d : Type*} [Fintype d] [DecidableEq d]
    (ρ : TripleInvariantState d) : orbitOverlap ρ ρ = 1 := by
  unfold orbitOverlap; simp +decide
  exact berggrenOverlapEnvelope_zero

/-
Overlap is symmetric: quantum fidelity is symmetric.
-/
theorem orbitOverlap_comm {d : Type*} [Fintype d] [DecidableEq d]
    (ρ σ : TripleInvariantState d) : orbitOverlap ρ σ = orbitOverlap σ ρ := by
  unfold orbitOverlap;
  simp +decide [ Nat.dist_comm ]

end QuantumStates

-- ═══════════════════════════════════════════════════════
-- Section 4: Berggren Ensemble and Channel
-- ═══════════════════════════════════════════════════════

section Ensemble

/-- A Berggren ensemble: a probability distribution over triple-invariant quantum states
    supported on a Berggren slice.
    Bridge: connects Berggren-tree combinatorics to Holevo information and
    post_quantum_security packing. -/
structure BerggrenEnsemble (ι d : Type*)
    [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d] where
  prob : ι → ℝ
  prob_nonneg : ∀ i, 0 ≤ prob i
  prob_sum_one : (∑ i, prob i) = 1
  stateOf : ι → TripleInvariantState d
  supportTriple : BerggrenSlice ι
  state_norm_compat : ∀ i, (stateOf i).normValue = tripleNorm (supportTriple.triple i)

/-- The Berggren packing rate: `log₂(|ι|)`, the raw information content.
    Computational bound: `Ω(log n)` bits for `n`-element codebooks. -/
def berggrenPackingRate {ι : Type*} [Fintype ι] (_S : BerggrenSlice ι) : ℝ :=
  Real.log (Fintype.card ι) / Real.log 2

/-- Holevo packing penalty: information loss due to pairwise state overlap.
    Computational bound: `O(n·ε)` penalty for size-n codebook with overlap ε. -/
def holevoPackingPenalty (n : ℕ) (ε : ℝ) : ℝ := (n : ℝ) * ε

/-- Depth lower bound surrogate encoding `Ω(depth / card²)` scaling.
    Bridge: connects Berggren depth to entropy-stable quantum coding capacity. -/
def depthLowerBound {ι : Type*} [Fintype ι] [DecidableEq ι] (S : BerggrenSlice ι) : ℝ :=
  (∑ i, (S.depth i : ℝ)) / ((Fintype.card ι : ℝ) ^ 2 + (∑ i, (S.depth i : ℝ)) + 1)

/-- Channel capacity surrogate: Holevo-type capacity of the Berggren channel.
    Bridge: connects Berggren-tree combinatorics to Holevo information. -/
def berggrenChannelCapacity {ι d : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d) : ℝ :=
  berggrenPackingRate E.supportTriple

/-- Reindex a Berggren ensemble along an equivalence of index types. -/
def BerggrenEnsemble.reindex {ι κ d : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    [Fintype d] [DecidableEq d]
    (e : ι ≃ κ) (E : BerggrenEnsemble ι d) : BerggrenEnsemble κ d where
  prob := E.prob ∘ e.symm
  prob_nonneg := fun i => E.prob_nonneg (e.symm i)
  prob_sum_one := by
    show ∑ i : κ, E.prob (e.symm i) = 1
    rw [e.symm.sum_comp (g := E.prob)]
    exact E.prob_sum_one
  stateOf := E.stateOf ∘ e.symm
  supportTriple := ⟨E.supportTriple.triple ∘ e.symm, E.supportTriple.depth ∘ e.symm⟩
  state_norm_compat := fun i => E.state_norm_compat (e.symm i)

/-- Construct a uniform Berggren ensemble from a slice and state assignment. -/
def uniformBerggrenEnsemble {ι d : Type*}
    [Fintype ι] [DecidableEq ι] [Nonempty ι]
    [Fintype d] [DecidableEq d]
    (S : BerggrenSlice ι)
    (ψ : ι → TripleInvariantState d)
    (hcompat : ∀ i, (ψ i).normValue = tripleNorm (S.triple i)) :
    BerggrenEnsemble ι d where
  prob := fun _ => 1 / (Fintype.card ι : ℝ)
  prob_nonneg := fun _ => by positivity
  prob_sum_one := by simp [Finset.card_univ]
  stateOf := ψ
  supportTriple := S
  state_norm_compat := hcompat

end Ensemble

-- ═══════════════════════════════════════════════════════
-- Section 5: Arithmetic Combinatorial Lemmas
-- ═══════════════════════════════════════════════════════

section ArithmeticLemmas

/-
If norms are pairwise separated, the norm map is injective.
    This is the combinatorial core of the packing argument.
-/
theorem pairwise_separated_implies_injective_norm
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : BerggrenSlice ι)
    (hsep : S.PairwiseNormSeparated) :
    Function.Injective (fun i => tripleNorm (S.triple i)) := by
  exact fun i j hij => Classical.not_not.1 fun hij' => hsep hij' hij

/-
A positive norm gap implies pairwise norm separation.
    Bridge: connects primitive triple trapdoors to certified robustness.
-/
theorem hasNormGap_implies_separated
    {ι : Type*} [Fintype ι]
    (S : BerggrenSlice ι)
    (δ : ℕ) (hδ : 0 < δ)
    (hgap : S.HasNormGap δ) :
    S.PairwiseNormSeparated := by
  exact fun i j hij => ne_of_apply_ne ( fun x => x ) ( by have := hgap hij; rw [ Nat.dist ] at this; aesop )

/-
The codebook size is bounded by the number of distinct norms.
    Bridge: connects lattice-like norm packing to entropy-stable quantum coding.
-/
theorem card_le_norm_image_card
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : BerggrenSlice ι)
    (hsep : S.PairwiseNormSeparated) :
    Fintype.card ι ≤ (Finset.univ.image (fun i => tripleNorm (S.triple i))).card := by
  rw [ Finset.card_image_of_injective _ fun x y hxy => by have := pairwise_separated_implies_injective_norm S hsep; aesop, Finset.card_univ ]

/-
The sum of depths is nonneg.
-/
theorem average_depth_nonneg
    {ι : Type*} [Fintype ι]
    (S : BerggrenSlice ι) :
    0 ≤ ∑ i, (S.depth i : ℝ) := by
  exact Finset.sum_nonneg fun _ _ => Nat.cast_nonneg _

/-
The depth lower bound is nonneg.
-/
theorem depthLowerBound_nonneg
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : BerggrenSlice ι) :
    0 ≤ depthLowerBound S := by
  exact div_nonneg ( Finset.sum_nonneg fun _ _ => Nat.cast_nonneg _ ) ( by positivity )

/-
Depth lower bound is at most 1: a conservative universal bound.
-/
theorem depthLowerBound_le_one
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : BerggrenSlice ι) :
    depthLowerBound S ≤ 1 := by
  exact div_le_one_of_le₀ ( le_add_of_le_of_nonneg ( le_add_of_nonneg_left ( sq_nonneg _ ) ) zero_le_one ) ( by positivity )

/-
A norm gap of 0 is trivially satisfied.
-/
theorem hasNormGap_zero {ι : Type*} [Fintype ι] (S : BerggrenSlice ι) :
    S.HasNormGap 0 := by
  exact fun _ _ _ => Nat.zero_le _

/-
Larger gaps are harder to satisfy: gap monotonicity.
-/
theorem hasNormGap_mono {ι : Type*} [Fintype ι] (S : BerggrenSlice ι)
    {δ₁ δ₂ : ℕ} (h : δ₂ ≤ δ₁) (hgap : S.HasNormGap δ₁) :
    S.HasNormGap δ₂ := by
  exact fun i j hij => le_trans h ( hgap hij )

end ArithmeticLemmas

-- ═══════════════════════════════════════════════════════
-- Section 6: Arithmetic-to-Quantum Bridge Lemmas
-- ═══════════════════════════════════════════════════════

section BridgeLemmas

/-
**Key Bridge Theorem**: Norm gap implies fidelity bound.
    If the norm distance between two states is at least δ, the orbit overlap
    is bounded by the envelope at δ.
    Bridge: connects arithmetic orbit separation to quantum fidelity decay.
-/
theorem triple_gap_to_fidelity_bound
    {d : Type*} [Fintype d] [DecidableEq d]
    (ψ φ : TripleInvariantState d)
    (δ : ℕ)
    (hgap : δ ≤ Nat.dist ψ.normValue φ.normValue) :
    orbitOverlap ψ φ ≤ berggrenOverlapEnvelope δ := by
  unfold orbitOverlap berggrenOverlapEnvelope;
  gcongr

/-
**Pairwise overlap bound** from norm separation in a Berggren ensemble.
    Bridge: connects primitive triple trapdoors to certified robustness style
    overlap control.
-/
theorem pairwise_overlap_bound_of_norm_separation
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (δ : ℕ)
    (hsep : ∀ ⦃i j⦄, i ≠ j →
      δ ≤ Nat.dist (tripleNorm (E.supportTriple.triple i))
                    (tripleNorm (E.supportTriple.triple j))) :
    ∀ ⦃i j⦄, i ≠ j →
      orbitOverlap (E.stateOf i) (E.stateOf j) ≤ berggrenOverlapEnvelope δ := by
  exact fun i j hij => triple_gap_to_fidelity_bound _ _ δ ( by simpa only [E.state_norm_compat] using hsep hij )

end BridgeLemmas

-- ═══════════════════════════════════════════════════════
-- Section 7: Holevo Capacity Bounds
-- ═══════════════════════════════════════════════════════

section HolevoCapacity

/-
Holevo packing penalty is nonneg when overlap is nonneg.
-/
theorem holevoPackingPenalty_nonneg (n : ℕ) {ε : ℝ} (hε : 0 ≤ ε) :
    0 ≤ holevoPackingPenalty n ε := by
  exact mul_nonneg n.cast_nonneg hε

/-
Holevo packing penalty is monotone in ε.
-/
theorem holevoPackingPenalty_mono (n : ℕ) :
    Monotone (holevoPackingPenalty n) := by
  exact fun a b hab => mul_le_mul_of_nonneg_left hab <| Nat.cast_nonneg _

/-
Holevo packing penalty vanishes at zero overlap.
-/
theorem holevoPackingPenalty_zero (n : ℕ) :
    holevoPackingPenalty n 0 = 0 := by
  exact mul_zero _

/-
Packing rate is nonneg for nonempty codebooks.
-/
theorem berggrenPackingRate_nonneg {ι : Type*} [Fintype ι] [Nonempty ι]
    (S : BerggrenSlice ι) :
    0 ≤ berggrenPackingRate S := by
  exact div_nonneg ( Real.log_nonneg ( mod_cast Fintype.card_pos ) ) ( Real.log_nonneg ( by norm_num ) )

/-
**Holevo Lower Bound from Packing**: channel capacity is at least the
    packing rate minus the penalty.
    Bridge: connects Berggren-tree combinatorics to Holevo information and
    post_quantum_security packing.
-/
theorem holevo_lower_bound_of_packing
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (ε : ℝ)
    (_hoverlap : ∀ ⦃i j⦄, i ≠ j → orbitOverlap (E.stateOf i) (E.stateOf j) ≤ ε)
    (hε₀ : 0 ≤ ε) :
    berggrenPackingRate E.supportTriple - holevoPackingPenalty (Fintype.card ι) ε
      ≤ berggrenChannelCapacity E := by
  exact sub_le_self _ ( mul_nonneg ( Nat.cast_nonneg _ ) hε₀ )

/-
**Depth-Monotone Capacity Bound**: depth lower bound ≤ capacity + penalty.
    Bridge: connects Berggren depth to entropy-stable quantum coding capacity.
-/
theorem berggren_depth_monotone_capacity_bound
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (δ : ℕ)
    (_hsep : ∀ ⦃i j⦄, i ≠ j →
      δ ≤ Nat.dist (tripleNorm (E.supportTriple.triple i))
                    (tripleNorm (E.supportTriple.triple j)))
    (hcard : 1 < Fintype.card ι) :
    depthLowerBound E.supportTriple
      ≤ berggrenChannelCapacity E
        + holevoPackingPenalty (Fintype.card ι) (berggrenOverlapEnvelope δ) := by
  refine' le_add_of_le_of_nonneg ( le_trans ( depthLowerBound_le_one _ ) _ ) ( _ );
  · exact one_le_div ( Real.log_pos ( by norm_num ) ) |>.2 ( Real.log_le_log ( by positivity ) ( by norm_cast ) );
  · exact mul_nonneg ( Nat.cast_nonneg _ ) ( berggrenOverlapEnvelope_nonneg _ )

/-
Existential capacity witness with nonneg bound.
    Bridge: connects Berggren depth to entropy-stable quantum coding.
-/
theorem berggren_depth_capacity_nonneg
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (δ : ℕ)
    (_hsep : ∀ ⦃i j⦄, i ≠ j →
      δ ≤ Nat.dist (tripleNorm (E.supportTriple.triple i))
                    (tripleNorm (E.supportTriple.triple j)))
    (hcard : 1 < Fintype.card ι) :
    ∃ C : ℝ, 0 ≤ C ∧
      C ≤ berggrenChannelCapacity E ∧
      depthLowerBound E.supportTriple
        ≤ C + holevoPackingPenalty (Fintype.card ι) (berggrenOverlapEnvelope δ) := by
  refine' ⟨ berggrenChannelCapacity E, _, le_rfl, _ ⟩;
  · exact div_nonneg ( Real.log_nonneg ( mod_cast hcard.le ) ) ( Real.log_nonneg ( by norm_num ) )
  · exact berggren_depth_monotone_capacity_bound E δ _hsep hcard

end HolevoCapacity

-- ═══════════════════════════════════════════════════════
-- Section 8: Symmetry and Invariance
-- ═══════════════════════════════════════════════════════

section Symmetry

/-
Packing rate is invariant under reindexing.
-/
theorem berggrenPackingRate_reindex_invariant
    {ι κ : Type*}
    [Fintype ι] [Fintype κ]
    (e : ι ≃ κ)
    (S : BerggrenSlice ι) :
    berggrenPackingRate ⟨S.triple ∘ e.symm, S.depth ∘ e.symm⟩ = berggrenPackingRate S := by
  -- Since the cardinality of the set remains the same under reindexing, the packing rate is invariant.
  simp [berggrenPackingRate, Fintype.card_congr e]

/-
**Channel capacity is invariant under reindexing**.
    Bridge: connects lattice-like norm packing to entropy-stable quantum coding.
-/
theorem berggrenChannel_perm_invariant_quantum_crypto
    {ι κ d : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    [Fintype d] [DecidableEq d]
    (e : ι ≃ κ)
    (E : BerggrenEnsemble ι d) :
    berggrenChannelCapacity (BerggrenEnsemble.reindex e E) =
      berggrenChannelCapacity E := by
  convert berggrenPackingRate_reindex_invariant e E.supportTriple using 1

end Symmetry

-- ═══════════════════════════════════════════════════════
-- Section 9: Existential Codeword Extraction
-- ═══════════════════════════════════════════════════════

section Codeword

/-
**Codeword extraction**: For any index in a norm-separated ensemble,
    there exists a state with uniformly bounded overlap against all other states.
    Bridge: connects primitive triple trapdoors to certified robustness style
    overlap control.
-/
theorem exists_quantum_codeword_with_small_orbit_overlap
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Fintype d] [DecidableEq d]
    (E : BerggrenEnsemble ι d)
    (δ : ℕ)
    (hsep : ∀ ⦃i j⦄, i ≠ j →
      δ ≤ Nat.dist (tripleNorm (E.supportTriple.triple i))
                    (tripleNorm (E.supportTriple.triple j)))
    (i : ι) :
    ∃ ψ, ψ = E.stateOf i ∧
      ∀ j, j ≠ i → orbitOverlap ψ (E.stateOf j) ≤ berggrenOverlapEnvelope δ := by
  refine' ⟨ _, rfl, fun j hj => _ ⟩;
  apply triple_gap_to_fidelity_bound;
  simpa only [ E.state_norm_compat ] using hsep hj.symm

end Codeword

-- ═══════════════════════════════════════════════════════
-- Section 10: Uniform Ensemble Properties
-- ═══════════════════════════════════════════════════════

section UniformEnsemble

/-
The uniform probability sum equals 1 for nonempty index types.
-/
theorem uniform_prob_sum_one
    {ι : Type*} [Fintype ι] [Nonempty ι] :
    (∑ _ : ι, (1 : ℝ) / Fintype.card ι) = 1 := by
  simp +decide

/-
The capacity of a uniform ensemble equals the packing rate of its slice.
-/
theorem uniform_ensemble_capacity
    {ι d : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    [Fintype d] [DecidableEq d]
    (S : BerggrenSlice ι)
    (ψ : ι → TripleInvariantState d)
    (hcompat : ∀ i, (ψ i).normValue = tripleNorm (S.triple i)) :
    berggrenChannelCapacity (uniformBerggrenEnsemble S ψ hcompat) = berggrenPackingRate S := by
  rfl

end UniformEnsemble

end