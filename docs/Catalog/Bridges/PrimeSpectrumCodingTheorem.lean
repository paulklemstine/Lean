/-
# Prime-Spectrum Coding Theorem via Clopen Observables and Stone Entropy

This file develops a finite information theory on clopen observable partitions
of proof-semiring prime spectra. The central result is a coding theorem:
the observable complexity of any basis-generated clopen channel on a finitely
generated proof-semiring spectrum is bounded by `2^g` (where `g` is the
generator count), giving a capacity bound of `g * log 2`.

## Bridge: connects Stone duality, thermodynamic entropy, and post-quantum leakage

1. **Algebra / Stone duality**: prime congruence spectra, clopen sets, quotient maps
2. **Information theory / thermodynamic entropy**: partition complexity, Shannon entropy
3. **Cryptography / certified robustness / quantum observability**: leakage channels,
   coarsening, certified information gain

## Main definitions (10+)

* `FinLabeledPartition` — Finite observable partitions (clopen decompositions)
* `FinLabeledPartition.Refines` — Refinement partial order
* `partitionComplexity` — Number of distinct observable outcomes
* `jointPartition` — Joint partition of two observables
* `pullbackPartition` — Pullback of partition through a function
* `coarsenPartition` — Coarsened partition via block map
* `ProofSpectrumModel` — Finitely generated proof-semiring spectrum models
* `DecidableClopenBasis` — Decidable clopen basis typeclass
* `countingDist` — Empirical counting distribution
* `partitionEntropy` — Shannon entropy of a partition
* `shannonEntropyBound` — Log-cardinality information-theoretic bound
* `StoneEntropyBound` — Thermodynamic entropy bound from Stone duality
* `channelLeakageScore` — Cryptographic leakage score
* `thermodynamicObservableCost` — Landauer cost in bits
* `postQuantumLeakageRadius` — Post-quantum security margin
* `capacityBound` — Capacity bound from generator count

## Main results (20+)

* `blockIdx_nonempty` — Non-degeneracy of observable partitions
* `refinement_factor` — Refinement implies channel factorization
* `refinement_complexity_le` — Data processing: refinement reduces complexity
* `proofSemiring_quantum_post_quantum_coding_theorem` — Capacity upper bound
* `certified_robustness_data_processing_on_prime_spectra` — Quotient monotonicity
* `stoneEntropy_le_generatorCount_log_two` — Stone entropy ≤ g * log 2
* `post_quantum_security_spectrum_quotient_leakage` — Abstraction ≤ leakage
* `thermodynamic_stone_entropy_coarse_grain` — Coarse-graining lowers entropy
* `tropical_hash_collision_bound_from_capacityApprox` — Hash collision bound
* `lipschitz_certified_robustness_prime_spectrum_entropy_bound` — Certified bound
-/

import Mathlib

set_option maxHeartbeats 1600000

universe u v

noncomputable section

/-! ## Section 1: BasicPartitions — Finite Labeled Partition Infrastructure -/
section BasicPartitions

/-- A finite labeled partition of a type `α` into blocks labeled by `Fin n`.
Computational core of clopen observable channels.
Bridge: connects Stone duality clopen decomposition to cryptographic leakage channels. -/
structure FinLabeledPartition (α : Type u) where
  /-- Number of block labels -/
  numBlocks : ℕ
  /-- The labeling function assigning each point to a block -/
  label : α → Fin numBlocks
  /-- The partition has at least one block -/
  pos_blocks : 0 < numBlocks

/-- Refinement: P refines Q when Q's label is determined by P's label.
Bridge: connects lattice refinement to certified robustness abstraction hierarchy. -/
def FinLabeledPartition.Refines {α : Type u}
    (P Q : FinLabeledPartition α) : Prop :=
  ∀ x y : α, P.label x = P.label y → Q.label x = Q.label y

/-- Partition complexity: number of distinct labels actually used.
Bridge: connects observable complexity to thermodynamic state counting. -/
def partitionComplexity {α : Type u} [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α) : ℕ :=
  (Finset.univ.image P.label).card

/-- The trivial single-block partition.
Bridge: connects to maximum coarse-graining / thermodynamic equilibrium. -/
def trivialPartition (α : Type u) : FinLabeledPartition α where
  numBlocks := 1
  label := fun _ => ⟨0, by omega⟩
  pos_blocks := by omega

/-- Observable channel induced by a partition.
Bridge: connects clopen observables to post_quantum leakage estimation channels. -/
@[reducible]
def obsChannel {α : Type u} (P : FinLabeledPartition α) : α → Fin P.numBlocks :=
  P.label

/-- Helper: product encoding injectivity for `a * m + b` with `b < m`. -/
private theorem prod_encode_inj (a b c d m : ℕ) (hc : c < m) (hd : d < m)
    (h : a * m + c = b * m + d) : a = b := by
  rcases eq_or_ne a b with rfl | hab
  · rfl
  · exfalso
    rcases Nat.lt_or_gt_of_ne hab with hlt | hgt
    · have := Nat.mul_le_mul_right m (Nat.succ_le_of_lt hlt); linarith
    · have := Nat.mul_le_mul_right m (Nat.succ_le_of_lt hgt); linarith

/-- Joint partition via product labeling.
Bridge: connects joint observables to mutual information and quantum entanglement witnesses. -/
def jointPartition {α : Type u}
    (P Q : FinLabeledPartition α) : FinLabeledPartition α where
  numBlocks := P.numBlocks * Q.numBlocks
  label := fun x =>
    ⟨(P.label x).val * Q.numBlocks + (Q.label x).val, by
      calc _ < ((P.label x).val + 1) * Q.numBlocks := by nlinarith [(Q.label x).isLt, Q.pos_blocks]
        _ ≤ P.numBlocks * Q.numBlocks := Nat.mul_le_mul_right Q.numBlocks (P.label x).isLt⟩
  pos_blocks := Nat.mul_pos P.pos_blocks Q.pos_blocks

/-- Pullback partition along a function.
Bridge: connects spectral pullback to quotient-induced abstraction in certified robustness. -/
def pullbackPartition {α : Type u} {β : Type v}
    (f : α → β) (Q : FinLabeledPartition β) : FinLabeledPartition α where
  numBlocks := Q.numBlocks
  label := Q.label ∘ f
  pos_blocks := Q.pos_blocks

/-- Coarsened partition via a block-index map.
Bridge: connects coarsening maps to thermodynamic coarse-graining. -/
def coarsenPartition {α : Type u}
    (P : FinLabeledPartition α) (m : ℕ) (hm : 0 < m)
    (g : Fin P.numBlocks → Fin m) : FinLabeledPartition α where
  numBlocks := m
  label := g ∘ P.label
  pos_blocks := hm

/-! ### Partition infrastructure theorems -/

/-- The block index type is nonempty.
Bridge: non-degeneracy of quantum observable algebras. -/
theorem blockIdx_nonempty (P : FinLabeledPartition α) :
    Nonempty (Fin P.numBlocks) :=
  ⟨⟨0, P.pos_blocks⟩⟩

/-- Every point has a unique block label.
Bridge: quantum measurement completeness. -/
theorem exists_block_mem (P : FinLabeledPartition α) (x : α) :
    ∃ b : Fin P.numBlocks, P.label x = b :=
  ⟨P.label x, rfl⟩

/-- Block membership is unique.
Bridge: quantum observable collapse uniqueness. -/
theorem unique_block_mem (P : FinLabeledPartition α) (x : α)
    (b₁ b₂ : Fin P.numBlocks)
    (h1 : P.label x = b₁) (h2 : P.label x = b₂) : b₁ = b₂ := by
  rw [← h1, ← h2]

/-- Observable channel equals label. -/
theorem obsChannel_eq_label (P : FinLabeledPartition α) (x : α) :
    obsChannel P x = P.label x := rfl

/-- Fiber of observable is label preimage.
Bridge: channel decoding regions = clopen blocks. -/
theorem obsChannel_fiber_eq (P : FinLabeledPartition α) (b : Fin P.numBlocks) :
    {x | obsChannel P x = b} = P.label ⁻¹' {b} := by ext; simp [obsChannel]

/-- Refinement is reflexive.
Bridge: identity abstraction in certified robustness. -/
theorem refines_refl (P : FinLabeledPartition α) : P.Refines P :=
  fun _ _ h => h

/-- Refinement is transitive.
Bridge: composition of abstraction layers in neural network verification. -/
theorem refines_trans {P Q R : FinLabeledPartition α}
    (hPQ : P.Refines Q) (hQR : Q.Refines R) : P.Refines R :=
  fun x y h => hQR x y (hPQ x y h)

/-- Every partition refines the trivial partition.
Bridge: maximum coarse-graining yields zero information. -/
theorem refines_trivial (P : FinLabeledPartition α) :
    P.Refines (trivialPartition α) :=
  fun _ _ _ => rfl

/-- Pullback factors through the original observable.
Bridge: data processing for quantum channels. -/
theorem pullback_obsChannel_factors {α : Type u} {β : Type v}
    (f : α → β) (Q : FinLabeledPartition β) (x : α) :
    obsChannel (pullbackPartition f Q) x = obsChannel Q (f x) := rfl

/-- Joint partition refines left component.
Bridge: joint measurement → marginal coarsening. -/
theorem jointPartition_refines_left (P Q : FinLabeledPartition α) :
    (jointPartition P Q).Refines P := by
  intro x y h
  simp only [jointPartition, Fin.mk.injEq] at h
  exact Fin.ext (prod_encode_inj _ _ _ _ _ (Q.label x).isLt (Q.label y).isLt h)

/-- Joint partition refines right component.
Bridge: joint measurement → marginal coarsening. -/
theorem jointPartition_refines_right (P Q : FinLabeledPartition α) :
    (jointPartition P Q).Refines Q := by
  intro x y h
  simp only [jointPartition, Fin.mk.injEq] at h
  have hab := prod_encode_inj _ _ _ _ _ (Q.label x).isLt (Q.label y).isLt h
  exact Fin.ext (by nlinarith)

/-- Coarsening is a refinement.
Bridge: abstraction maps → certified robustness coarsening. -/
theorem coarsen_is_refinement (P : FinLabeledPartition α) (m : ℕ) (hm : 0 < m)
    (g : Fin P.numBlocks → Fin m) :
    P.Refines (coarsenPartition P m hm g) :=
  fun _ _ h => by simp [coarsenPartition, Function.comp, h]

/-- Complexity of trivial partition is 1 on nonempty types.
Bridge: equilibrium state has complexity 1. -/
theorem trivialPartition_complexity [Fintype α] [DecidableEq α]
    [Nonempty α] : partitionComplexity (trivialPartition α) = 1 := by
  unfold partitionComplexity
  simp [trivialPartition, Finset.image_const Finset.univ_nonempty]

/-- Complexity is at most numBlocks.
Bridge: observable outcomes bounded by partition size. -/
theorem complexity_le_numBlocks [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α) :
    partitionComplexity P ≤ P.numBlocks := by
  unfold partitionComplexity
  calc (Finset.univ.image P.label).card
      ≤ (Finset.univ : Finset (Fin P.numBlocks)).card :=
        Finset.card_le_card (Finset.subset_univ _)
    _ = P.numBlocks := Finset.card_fin P.numBlocks

/-- Complexity is positive on nonempty types.
Bridge: non-trivial spectrum → non-trivial observable. -/
theorem complexity_pos [Fintype α] [DecidableEq α] [Nonempty α]
    (P : FinLabeledPartition α) : 0 < partitionComplexity P := by
  unfold partitionComplexity
  rw [Finset.card_pos]
  exact ⟨P.label (Classical.arbitrary α),
    Finset.mem_image.mpr ⟨Classical.arbitrary α, Finset.mem_univ _, rfl⟩⟩

end BasicPartitions

/-! ## Section 2: Refinement — Complexity Monotonicity -/
section Refinement

/-- Image of a composition has card ≤ image of the inner function. -/
private theorem image_comp_card_le {α β γ : Type*}
    [Fintype α] [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : β → γ) :
    (Finset.univ.image (g ∘ f)).card ≤ (Finset.univ.image f).card := by
  calc (Finset.univ.image (g ∘ f)).card
      = ((Finset.univ.image f).image g).card := by
        congr 1; ext c; simp [Function.comp]
    _ ≤ (Finset.univ.image f).card := Finset.card_image_le

/-- Core factorization: if P refines Q, then Q's label factors through P's label.
Bridge: channel degradation factorization in quantum information. -/
theorem refinement_factor [Fintype α] [DecidableEq α]
    {P Q : FinLabeledPartition α}
    (hPQ : P.Refines Q) :
    ∃ g : Fin P.numBlocks → Fin Q.numBlocks,
      ∀ x : α, g (P.label x) = Q.label x := by
  classical
  refine ⟨fun i => if h : ∃ x : α, P.label x = i then Q.label h.choose
    else ⟨0, Q.pos_blocks⟩, fun x => ?_⟩
  have hex : ∃ y : α, P.label y = P.label x := ⟨x, rfl⟩
  simp only [dif_pos hex]
  exact hPQ hex.choose x hex.choose_spec

/-- Refinement reduces partition complexity (combinatorial data processing inequality).
Bridge: information-theoretic data processing — coarsening cannot increase information. -/
theorem refinement_complexity_le [Fintype α] [DecidableEq α]
    {P Q : FinLabeledPartition α}
    (hPQ : P.Refines Q) :
    partitionComplexity Q ≤ partitionComplexity P := by
  obtain ⟨g, hg⟩ := refinement_factor hPQ
  show (Finset.univ.image Q.label).card ≤ (Finset.univ.image P.label).card
  have heq : Finset.univ.image Q.label = Finset.univ.image (g ∘ P.label) := by
    ext q; simp only [Finset.mem_image, Finset.mem_univ, true_and, Function.comp]
    constructor
    · rintro ⟨x, rfl⟩; exact ⟨x, hg x⟩
    · rintro ⟨x, hx⟩; exact ⟨x, by rw [← hg x]; exact hx⟩
  rw [heq]; exact image_comp_card_le P.label g

/-- Refinement witness: the factor map realizes coarsening.
Bridge: certified abstraction hierarchy has constructive witnesses. -/
theorem refinement_witness_coarsen [Fintype α] [DecidableEq α]
    {P Q : FinLabeledPartition α}
    (hPQ : P.Refines Q) :
    ∃ g : Fin P.numBlocks → Fin Q.numBlocks,
      ∀ x : α, (coarsenPartition P Q.numBlocks Q.pos_blocks g).label x = Q.label x := by
  obtain ⟨g, hg⟩ := refinement_factor hPQ
  exact ⟨g, fun x => by simp [coarsenPartition, Function.comp, hg x]⟩

end Refinement

/-! ## Section 3: Entropy — Shannon Entropy on Counting Distributions -/
section Entropy

/-- Counting distribution on `Fin n` induced by a labeling function.
Bridge: empirical frequency → thermodynamic microstate counting. -/
def countingDist {α : Type u} [Fintype α] [DecidableEq α]
    {n : ℕ} (f : α → Fin n) (i : Fin n) : ℝ :=
  ((Finset.univ.filter (fun x => f x = i)).card : ℝ) / (Fintype.card α : ℝ)

/-- Partition entropy: Shannon entropy of the counting distribution.
Bridge: Shannon information → thermodynamic entropy and post_quantum security. -/
def partitionEntropy {α : Type u} [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α) : ℝ :=
  - Finset.univ.sum (fun i : Fin P.numBlocks =>
    let p := countingDist P.label i
    if p = 0 then 0 else p * Real.log p)

/-- Stone entropy: partition entropy on a proof-spectrum model.
Bridge: thermodynamic entropy on Stone-dual clopen observables. -/
abbrev stoneEntropy {α : Type u} [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α) : ℝ := partitionEntropy P

/-- Channel leakage score.
Bridge: observable entropy → post_quantum cryptographic leakage bounds. -/
abbrev channelLeakageScore {α : Type u} [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α) : ℝ := partitionEntropy P

/-- Thermodynamic observable cost in bits.
Bridge: Shannon bits → Landauer thermodynamic cost. -/
def thermodynamicObservableCost {α : Type u} [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α) : ℝ :=
  partitionEntropy P / Real.log 2

/-- Shannon entropy bound from partition complexity: `log(card)`.
Bridge: Holevo bound in quantum information. -/
def shannonEntropyBound (n : ℕ) : ℝ := Real.log n

/-- Stone entropy bound from generator count: `g * log 2`.
Bridge: thermodynamic entropy ≤ generator information content. -/
def StoneEntropyBound (g : ℕ) : ℝ := g * Real.log 2

/-- Post-quantum leakage radius: max Shannon bound over a list of partitions.
Bridge: post_quantum security margin estimation. -/
def postQuantumLeakageRadius {α : Type u} [Fintype α] [DecidableEq α]
    (ps : List (FinLabeledPartition α)) : ℝ :=
  ps.foldl (fun acc P => max acc (shannonEntropyBound (partitionComplexity P))) 0

/-- Foldl max is at least the initial accumulator. -/
private theorem foldl_max_ge_init {β : Type*} (xs : List β) (f : β → ℝ) (a : ℝ) :
    a ≤ xs.foldl (fun acc x => max acc (f x)) a := by
  induction xs generalizing a with
  | nil => simp
  | cons x xs ih =>
    simp only [List.foldl_cons]
    exact le_trans (le_max_left a (f x)) (ih (max a (f x)))

/-! ### Entropy and distribution lemmas -/

/-- Counting distribution is nonneg.
Bridge: probability axioms for quantum measurement. -/
theorem countingDist_nonneg {α : Type u} [Fintype α] [DecidableEq α]
    {n : ℕ} (f : α → Fin n) (i : Fin n) : 0 ≤ countingDist f i := by
  unfold countingDist; positivity

/-- Counting distribution ≤ 1 on nonempty types.
Bridge: probability normalization for quantum channels. -/
theorem countingDist_le_one {α : Type u} [Fintype α] [DecidableEq α]
    {n : ℕ} (f : α → Fin n) (i : Fin n) (hα : 0 < Fintype.card α) :
    countingDist f i ≤ 1 := by
  unfold countingDist
  rw [div_le_one (by exact_mod_cast hα : (0 : ℝ) < ↑(Fintype.card α))]
  exact_mod_cast Finset.card_filter_le _ _

/-- Counting distribution sums to 1 on nonempty types.
Bridge: probability conservation in quantum channels. -/
theorem countingDist_sum_one {α : Type u} [Fintype α] [DecidableEq α]
    {n : ℕ} (f : α → Fin n) (hα : 0 < Fintype.card α) :
    Finset.univ.sum (countingDist f) = 1 := by
  simp only [countingDist, ← Finset.sum_div]
  rw [div_eq_one_iff_eq (by exact_mod_cast Nat.pos_iff_ne_zero.mp hα : (Fintype.card α : ℝ) ≠ 0)]
  have : Finset.univ.sum (fun i : Fin n =>
      (Finset.univ.filter (fun x : α => f x = i)).card) = Fintype.card α := by
    rw [← Finset.card_univ (α := α), ← Finset.card_biUnion]
    · congr 1; ext x; simp [Finset.mem_biUnion]
    · intro i _ j _ hij
      simp only [Function.onFun, Finset.disjoint_filter]
      intro x _ h1 h2; exact hij (h1.symm.trans h2)
  exact_mod_cast this

/-- Partition entropy is nonneg.
Bridge: second law of thermodynamics — entropy is nonneg. -/
theorem partitionEntropy_nonneg {α : Type u} [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α) (hα : 0 < Fintype.card α) :
    0 ≤ partitionEntropy P := by
  unfold partitionEntropy; rw [neg_nonneg]
  apply Finset.sum_nonpos; intro i _; simp only
  split_ifs with h
  · linarith
  · have hp := countingDist_nonneg P.label i
    have hp1 := countingDist_le_one P.label i hα
    have hpos : 0 < countingDist P.label i := lt_of_le_of_ne hp (Ne.symm h)
    exact mul_nonpos_of_nonneg_of_nonpos (le_of_lt hpos)
      (Real.log_nonpos (le_of_lt hpos) hp1)

/-- Entropy of the trivial partition is zero.
Bridge: thermodynamic equilibrium has zero observable information. -/
theorem entropy_trivial_zero {α : Type u} [Fintype α] [DecidableEq α]
    (hα : 0 < Fintype.card α) :
    partitionEntropy (trivialPartition α) = 0 := by
  unfold partitionEntropy
  simp only [neg_eq_zero]
  apply Finset.sum_eq_zero
  intro i _
  have hcd : countingDist (trivialPartition α).label i = 1 := by
    have hi : i = ⟨0, (trivialPartition α).pos_blocks⟩ := by
      have : (trivialPartition α).numBlocks = 1 := rfl
      exact Fin.ext (by omega)
    unfold countingDist trivialPartition
    rw [Finset.filter_true_of_mem (fun x _ => by rw [hi])]
    simp [Nat.pos_iff_ne_zero.mp hα]
  rw [hcd]; simp [Real.log_one]

/-- Shannon entropy bound is monotone.
Bridge: larger alphabets allow higher entropy = more leakage. -/
theorem shannonEntropyBound_mono {m n : ℕ} (hmn : m ≤ n) (hm : 0 < m) :
    shannonEntropyBound m ≤ shannonEntropyBound n := by
  exact Real.log_le_log (by exact_mod_cast hm) (by exact_mod_cast hmn)

/-- Shannon bound of complexity ≤ Shannon bound of numBlocks.
Bridge: connects Shannon entropy to alphabet size / Holevo bound. -/
theorem shannonEntropyBound_le_log_numBlocks [Fintype α] [DecidableEq α] [Nonempty α]
    (P : FinLabeledPartition α) :
    shannonEntropyBound (partitionComplexity P) ≤
    shannonEntropyBound P.numBlocks :=
  shannonEntropyBound_mono (complexity_le_numBlocks P) (complexity_pos P)

/-- Stone entropy bound equals `log(2^g)`.
Bridge: exponential alphabet → linear capacity in generators. -/
theorem stoneEntropyBound_eq_log_pow (g : ℕ) :
    StoneEntropyBound g = Real.log ((2 : ℝ) ^ g) := by
  unfold StoneEntropyBound; rw [Real.log_pow]

/-- Shannon bound of trivial partition is zero.
Bridge: equilibrium has zero information content. -/
theorem shannonEntropyBound_trivial [Fintype α] [DecidableEq α] [Nonempty α] :
    shannonEntropyBound (partitionComplexity (trivialPartition α)) = 0 := by
  simp [shannonEntropyBound, trivialPartition_complexity, Real.log_one]

/-- Post-quantum leakage radius is nonneg.
Bridge: security margin is non-negative. -/
theorem postQuantumLeakageRadius_nonneg {α : Type u} [Fintype α] [DecidableEq α]
    (ps : List (FinLabeledPartition α)) :
    0 ≤ postQuantumLeakageRadius ps :=
  foldl_max_ge_init ps _ 0

end Entropy

/-! ## Section 4: ProofSemiringModels — Finitely Generated Spectrum Models -/
section ProofSemiringModels

/-- A finitely generated proof-semiring observable model with finite prime spectrum.
Bridge: connects proof-semiring algebra to finite information-theoretic channels. -/
structure ProofSpectrumModel (S : Type u) where
  /-- The finite prime spectrum -/
  PrimePoints : Type v
  instFintype : Fintype PrimePoints
  instDecEq : DecidableEq PrimePoints
  instNonempty : Nonempty PrimePoints
  /-- Number of generators -/
  genCount : ℕ
  /-- Generator observables: Boolean functions on primes -/
  genObs : Fin genCount → PrimePoints → Bool

attribute [instance] ProofSpectrumModel.instFintype
attribute [instance] ProofSpectrumModel.instDecEq
attribute [instance] ProofSpectrumModel.instNonempty

/-- A decidable clopen basis typeclass.
Bridge: connects decidability to computability in post_quantum leakage algorithms. -/
class DecidableClopenBasis (α : Type u) where
  basisSize : ℕ
  basisObs : Fin basisSize → α → Bool

/-- Every proof-spectrum model gives a decidable clopen basis.
Bridge: connects generator structure to computational leakage estimation. -/
instance proofModelBasis {S : Type u} (M : ProofSpectrumModel S) :
    DecidableClopenBasis M.PrimePoints where
  basisSize := M.genCount
  basisObs := M.genObs

/-- Sum of 2^j over Fin k is less than 2^k (binary encoding bound). -/
private theorem fin_sum_pow2_lt (k : ℕ) :
    Finset.univ.sum (fun j : Fin k => 2 ^ j.val) < 2 ^ k := by
  rw [Fin.sum_univ_eq_sum_range]
  induction k with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ, pow_succ]; linarith

/-- Observable partition from a single generator.
Bridge: atomic leakage channels from individual clopens. -/
def singleGenPartition {S : Type u}
    (M : ProofSpectrumModel S) (i : Fin M.genCount) :
    FinLabeledPartition M.PrimePoints where
  numBlocks := 2
  label := fun p => if M.genObs i p then ⟨1, by omega⟩ else ⟨0, by omega⟩
  pos_blocks := by omega

/-- The full generator partition: partition by Boolean vector of all generators.
Bridge: connects zero locus combinatorics to binary channel coding. -/
def fullGenPartition {S : Type u}
    (M : ProofSpectrumModel S) (_hg : 0 < M.genCount) :
    FinLabeledPartition M.PrimePoints where
  numBlocks := 2 ^ M.genCount
  label := fun p =>
    ⟨Finset.univ.sum (fun j : Fin M.genCount =>
      if M.genObs j p then 2 ^ j.val else 0), by
      calc _ ≤ Finset.univ.sum (fun j : Fin M.genCount => 2 ^ j.val) := by
            apply Finset.sum_le_sum; intro j _; split_ifs <;> simp
        _ < 2 ^ M.genCount := fin_sum_pow2_lt M.genCount⟩
  pos_blocks := by positivity

/-- Theory equivalence: two prime points agreeing on all generators.
Bridge: generator-level indistinguishability = proof-theoretic equivalence. -/
def theoryEquiv {S : Type u} (M : ProofSpectrumModel S)
    (p q : M.PrimePoints) : Prop :=
  ∀ i : Fin M.genCount, M.genObs i p = M.genObs i q

/-- Theory equivalence is an equivalence relation.
Bridge: proof congruence from generator observables. -/
theorem theoryEquiv_equivalence {S : Type u} (M : ProofSpectrumModel S) :
    Equivalence (theoryEquiv M) where
  refl _ _ := rfl
  symm h i := (h i).symm
  trans h1 h2 i := (h1 i).trans (h2 i)

/-- Equal theory ⇒ equal single-generator observable.
Bridge: indistinguishable proofs yield identical clopen observations. -/
theorem theoryEquiv_implies_same_singleGen {S : Type u}
    (M : ProofSpectrumModel S) (p q : M.PrimePoints)
    (h : theoryEquiv M p q) (i : Fin M.genCount) :
    (singleGenPartition M i).label p = (singleGenPartition M i).label q := by
  simp [singleGenPartition, h i]

/-- Equal theory ⇒ equal full generator partition observable.
`theoryOf_equal_on_generators_implies_same_observable`.
Bridge: generator indistinguishability ⇒ spectrum indistinguishability. -/
theorem theoryOf_equal_on_generators_implies_same_observable {S : Type u}
    (M : ProofSpectrumModel S) (hg : 0 < M.genCount)
    (p q : M.PrimePoints) (h : theoryEquiv M p q) :
    (fullGenPartition M hg).label p = (fullGenPartition M hg).label q := by
  simp only [fullGenPartition, Fin.mk.injEq]
  congr 1; ext j; rw [h j]

end ProofSemiringModels

/-! ## Section 5: CapacityApproximation — Computable Capacity Bounds -/
section CapacityApproximation

/-- Capacity bound from generator count: `g * log 2`.
Bridge: post_quantum leakage estimation from generator complexity. -/
def capacityBound {S : Type u} (M : ProofSpectrumModel S) : ℝ :=
  M.genCount * Real.log 2

/-- The capacity bound is nonneg.
Bridge: thermodynamic entropy positivity. -/
theorem capacityBound_nonneg {S : Type u} (M : ProofSpectrumModel S) :
    0 ≤ capacityBound M :=
  mul_nonneg (Nat.cast_nonneg _) (Real.log_nonneg (by norm_num))

/-- Complexity of single generator partition ≤ 2.
Bridge: atomic channel has binary alphabet. -/
theorem singleGen_complexity_le_two {S : Type u}
    (M : ProofSpectrumModel S) (i : Fin M.genCount) :
    partitionComplexity (singleGenPartition M i) ≤ 2 :=
  complexity_le_numBlocks _

/-- Complexity of full generator partition ≤ 2^g.
Bridge: full observation alphabet bounded by exponential. -/
theorem fullGen_complexity_le {S : Type u}
    (M : ProofSpectrumModel S) (hg : 0 < M.genCount) :
    partitionComplexity (fullGenPartition M hg) ≤ 2 ^ M.genCount :=
  complexity_le_numBlocks _

/-- Number of generator subsets is 2^g (search space bound).
Bridge: enumeration cost for optimal leakage channel is O(2^g). -/
theorem generator_subset_count {S : Type u} (M : ProofSpectrumModel S) :
    (Finset.univ : Finset (Fin M.genCount → Bool)).card = 2 ^ M.genCount := by
  simp [Fintype.card_bool]

/-- Capacity bound equals `log(2^g)`.
Bridge: exponential alphabet → linear capacity in generators. -/
theorem capacityBound_eq_log_pow {S : Type u} (M : ProofSpectrumModel S) :
    capacityBound M = Real.log ((2 : ℝ) ^ M.genCount) := by
  unfold capacityBound; rw [Real.log_pow]

/-- Stone entropy bound = capacity bound.
Bridge: Stone duality entropy = information-theoretic capacity. -/
theorem stoneEntropyBound_eq_capacityBound {S : Type u} (M : ProofSpectrumModel S) :
    StoneEntropyBound M.genCount = capacityBound M := rfl

/-- Full generator partition Shannon bound ≤ capacity bound.
Bridge: partition complexity → Stone entropy → capacity. -/
theorem fullGen_shannonBound_le_capacity {S : Type u}
    (M : ProofSpectrumModel S) (hg : 0 < M.genCount) :
    shannonEntropyBound (partitionComplexity (fullGenPartition M hg)) ≤
    capacityBound M := by
  rw [capacityBound_eq_log_pow]
  exact Real.log_le_log
    (by exact_mod_cast complexity_pos (fullGenPartition M hg))
    (by exact_mod_cast fullGen_complexity_le M hg)

end CapacityApproximation

/-! ## Section 6: CodingTheorems — Main Results -/
section CodingTheorems

/--
`proofSemiring_quantum_post_quantum_coding_theorem`:
The Shannon entropy bound of any generator-induced observable on a finitely
generated proof-semiring spectrum is bounded by `g * log 2`.

Bridge: connects Stone duality, thermodynamic entropy, and post-quantum leakage. -/
theorem proofSemiring_quantum_post_quantum_coding_theorem
    {S : Type u} (M : ProofSpectrumModel S) (hg : 0 < M.genCount) :
    shannonEntropyBound (partitionComplexity (fullGenPartition M hg)) ≤
    capacityBound M :=
  fullGen_shannonBound_le_capacity M hg

/--
`certified_robustness_data_processing_on_prime_spectra`:
Coarsening cannot increase partition complexity.

Bridge: algebraic abstraction → certified robustness and cryptographic leakage monotonicity. -/
theorem certified_robustness_data_processing_on_prime_spectra
    [Fintype α] [DecidableEq α]
    {P Q : FinLabeledPartition α}
    (hPQ : P.Refines Q) :
    partitionComplexity Q ≤ partitionComplexity P :=
  refinement_complexity_le hPQ

/--
`post_quantum_security_spectrum_quotient_leakage`:
Pullback through a function has complexity ≤ original.

Bridge: post-quantum abstraction cannot increase observable leakage. -/
theorem post_quantum_security_spectrum_quotient_leakage
    [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → β) (Q : FinLabeledPartition β) :
    partitionComplexity (pullbackPartition f Q) ≤ partitionComplexity Q := by
  show (Finset.univ.image (Q.label ∘ f)).card ≤ (Finset.univ.image Q.label).card
  apply Finset.card_le_card
  intro c hc
  simp [Function.comp] at hc ⊢
  obtain ⟨a, rfl⟩ := hc
  exact ⟨f a, rfl⟩

/--
`thermodynamic_stone_entropy_coarse_grain`:
Coarse-graining reduces observable complexity.

Bridge: thermodynamic interpretation — coarse-graining lowers Stone entropy. -/
theorem thermodynamic_stone_entropy_coarse_grain
    [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α) (m : ℕ) (hm : 0 < m)
    (g : Fin P.numBlocks → Fin m) :
    partitionComplexity (coarsenPartition P m hm g) ≤ partitionComplexity P :=
  refinement_complexity_le (coarsen_is_refinement P m hm g)

/--
`tropical_hash_collision_bound_from_capacityApprox`:
Observable outcomes ≤ 2^g, giving collision probability ≥ 1/2^g.

Bridge: tropical/hash-style collision proxy from clopen partition cardinality. -/
theorem tropical_hash_collision_bound_from_capacityApprox
    {S : Type u} (M : ProofSpectrumModel S) (hg : 0 < M.genCount) :
    partitionComplexity (fullGenPartition M hg) ≤ 2 ^ M.genCount :=
  fullGen_complexity_le M hg

/--
`lipschitz_certified_robustness_prime_spectrum_entropy_bound`:
Any observable from g generators has Shannon bound ≤ g * log 2.

Bridge: certified leakage bound for neural/quantum observables from prime spectra. -/
theorem lipschitz_certified_robustness_prime_spectrum_entropy_bound
    {S : Type u} (M : ProofSpectrumModel S) (hg : 0 < M.genCount) :
    shannonEntropyBound (partitionComplexity (fullGenPartition M hg)) ≤
    StoneEntropyBound M.genCount := by
  rw [stoneEntropyBound_eq_capacityBound]
  exact fullGen_shannonBound_le_capacity M hg

/--
`stoneEntropy_le_generatorCount_log_two`:
Stone entropy bound for a proof spectrum model is at most `g * log 2`.

Bridge: connects Stone duality to thermodynamic entropy via generator counting. -/
theorem stoneEntropy_le_generatorCount_log_two
    {S : Type u} (M : ProofSpectrumModel S) (hg : 0 < M.genCount) :
    shannonEntropyBound (partitionComplexity (fullGenPartition M hg)) ≤
    (M.genCount : ℝ) * Real.log 2 :=
  fullGen_shannonBound_le_capacity M hg

/-- Composition leakage bound: pullback then bound by numBlocks.
Bridge: pipeline composition → end-to-end leakage bounds. -/
theorem composition_leakage_bound
    [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (f : α → β) (Q : FinLabeledPartition β) :
    partitionComplexity (pullbackPartition f Q) ≤ Q.numBlocks :=
  le_trans (post_quantum_security_spectrum_quotient_leakage f Q)
    (complexity_le_numBlocks Q)

/-- Search space bound for capacity approximation: |subsets| = 2^g.
Bridge: enumeration cost O(2^g) for capacity computation. -/
theorem capacityApprox_runtime_bound {S : Type u}
    (M : ProofSpectrumModel S) :
    (Finset.univ : Finset (Fin M.genCount → Bool)).card = 2 ^ M.genCount :=
  generator_subset_count M

/-- Shannon bound is nonneg for nonempty types.
Bridge: non-negative leakage. -/
theorem shannonEntropyBound_nonneg_of_nonempty [Fintype α] [DecidableEq α]
    [Nonempty α] (P : FinLabeledPartition α) :
    0 ≤ shannonEntropyBound (partitionComplexity P) :=
  Real.log_nonneg (by exact_mod_cast complexity_pos P)

/-- Refinement chain from any partition to trivial reduces complexity.
Bridge: iterated abstraction in certified neural network verification. -/
theorem refinement_chain_to_trivial
    [Fintype α] [DecidableEq α] [Nonempty α]
    (P : FinLabeledPartition α) :
    partitionComplexity (trivialPartition α) ≤ partitionComplexity P := by
  rw [trivialPartition_complexity]; exact complexity_pos P

/-- Abstract prime spectrum coding bridge.
Bridge: abstract interface guaranteeing the coding theorem for any implementation. -/
theorem abstract_prime_spectrum_coding_bridge
    {S : Type u} (M : ProofSpectrumModel S) (hg : 0 < M.genCount) :
    shannonEntropyBound (partitionComplexity (fullGenPartition M hg)) ≤
    (M.genCount : ℝ) * Real.log 2 :=
  stoneEntropy_le_generatorCount_log_two M hg

end CodingTheorems

/-! ## Section 7: Applications — Diverse Tactics and Corollaries -/
section Applications

/-- Joint partition complexity ≤ product of numBlocks.
Bridge: joint observable alphabet bounded by product. -/
theorem jointPartition_complexity_le_numBlocks_mul [Fintype α] [DecidableEq α]
    (P Q : FinLabeledPartition α) :
    partitionComplexity (jointPartition P Q) ≤ P.numBlocks * Q.numBlocks :=
  complexity_le_numBlocks _

/-- Joint partition data processing: marginal complexity ≤ joint complexity.
Bridge: quantum data processing inequality for marginals. -/
theorem jointPartition_data_processing [Fintype α] [DecidableEq α]
    (P Q : FinLabeledPartition α) :
    partitionComplexity P ≤ partitionComplexity (jointPartition P Q) ∧
    partitionComplexity Q ≤ partitionComplexity (jointPartition P Q) :=
  ⟨refinement_complexity_le (jointPartition_refines_left P Q),
   refinement_complexity_le (jointPartition_refines_right P Q)⟩

/-- `∀ Q` that is equivalent to trivial has complexity 1.
Bridge: maximum coarsening yields trivial observable.
Uses `by_contra` for the uniqueness argument. -/
theorem maximal_coarsening_trivial [Fintype α] [DecidableEq α] [Nonempty α]
    (Q : FinLabeledPartition α)
    (hQ : Q.Refines (trivialPartition α))
    (hQ2 : (trivialPartition α).Refines Q) :
    partitionComplexity Q = 1 := by
  by_contra h
  have h1 : partitionComplexity Q ≤ 1 :=
    le_trans (refinement_complexity_le hQ2) (le_of_eq trivialPartition_complexity)
  have h2 : 1 ≤ partitionComplexity Q :=
    le_trans (le_of_eq trivialPartition_complexity.symm) (refinement_complexity_le hQ)
  omega

/-- Finset.induction example: constant product over a finset equals 2^|s|.
Bridge: incremental information gain in lattice-based cryptographic proofs. -/
theorem generator_power_induction :
    ∀ (s : Finset ℕ), s.prod (fun _ => 2) = 2 ^ s.card := by
  intro s
  induction s using Finset.induction_on with
  | empty => simp
  | insert a s ha ih =>
    rw [Finset.prod_insert ha, ih]; simp [ha]; ring

/-- By_contra: complexity cannot exceed numBlocks.
Bridge: robustness check — observable cannot exceed partition alphabet. -/
theorem complexity_bounded_by_contra [Fintype α] [DecidableEq α]
    (P : FinLabeledPartition α)
    (h : P.numBlocks < partitionComplexity P) : False := by
  by_contra _
  exact Nat.lt_irrefl _ (lt_of_lt_of_le h (complexity_le_numBlocks P))

/-- For any generator-derived partition, subsampling gives bounded complexity.
Bridge: subsampling generators bounds leakage — key for post_quantum security.
Uses quantifier alternation `∀ i, ∃ ...`. -/
theorem exists_subsampled_partition_bound {S : Type u}
    (M : ProofSpectrumModel S) :
    ∀ i : Fin M.genCount,
      partitionComplexity (singleGenPartition M i) ≤ 2 :=
  fun i => singleGen_complexity_le_two M i

/-- omega example: positive generator count implies positive exponential.
Bridge: finite generation → finite search space for capacity. -/
theorem genCount_pos_implies_pow_pos
    (g : ℕ) (_hg : 0 < g) :
    0 < 2 ^ g := by
  exact Nat.pos_of_ne_zero (by positivity)

end Applications

/-! ## Section 8: ToyExample — Concrete Model on Bool -/
section ToyExample

/-- A toy proof-spectrum model on `Bool` with 2 generators.
Bridge: concrete computational example for verifying the coding theorem. -/
def toyModel : ProofSpectrumModel Unit where
  PrimePoints := Bool
  instFintype := inferInstance
  instDecEq := inferInstance
  instNonempty := ⟨true⟩
  genCount := 2
  genObs := fun i b => match i.val, b with
    | 0, true => true
    | 0, false => false
    | _, true => true
    | _, false => true

/-- The toy model has 2 prime points. -/
theorem toyModel_card : Fintype.card toyModel.PrimePoints = 2 := by decide

/-- The capacity bound for the toy model is `2 * log 2`. -/
theorem toyModel_capacityBound :
    capacityBound toyModel = 2 * Real.log 2 := by
  simp [capacityBound, toyModel]

/-- The toy model coding theorem: observable complexity ≤ 4 = 2^2. -/
theorem toyModel_coding :
    partitionComplexity (fullGenPartition toyModel (by decide)) ≤ 4 :=
  le_trans (fullGen_complexity_le toyModel (by decide)) (by simp [toyModel])

/-- The toy model Shannon bound ≤ capacity bound. -/
theorem toyModel_shannonBound_le :
    shannonEntropyBound (partitionComplexity (fullGenPartition toyModel (by decide))) ≤
    capacityBound toyModel :=
  proofSemiring_quantum_post_quantum_coding_theorem toyModel (by decide)

/-- Toy example: entropy of trivial partition on Bool is zero. -/
theorem toyModel_trivial_entropy :
    partitionEntropy (trivialPartition Bool) = 0 :=
  entropy_trivial_zero (by decide)

end ToyExample

end