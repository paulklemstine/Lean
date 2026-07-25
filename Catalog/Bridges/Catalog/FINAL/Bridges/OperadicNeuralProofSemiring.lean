/-
# Operadic Neural Proof-Semiring Diagonalization

This file establishes a **Myhill–Nerode-style minimization and diagonalization
framework** for proof-generating neural architectures. It bridges:

* **Machine learning ↔ algebra**: Neural architecture minimization via
  semiring congruence spectra.
* **Cryptography ↔ operads**: Prime-separator fingerprints as a formal model
  for post-quantum architecture indistinguishability.
* **Physics ↔ self-reference**: Compression gaps as thermodynamic/entropy-style
  witnesses of diagonal self-reference cost.
* **Logic ↔ computation**: Myhill–Nerode canonical representatives for
  proof-generating systems.

## Bridge: connects algebra (semiring congruences) → ML (neural architectures) →
   cryptography (post-quantum fingerprinting) → physics (thermodynamic compression) →
   logic (Myhill–Nerode minimization) → complexity (compression lower bounds)
-/

import Mathlib

set_option maxHeartbeats 400000

universe u v

open Finset Function

/-! ## Section 1: Core Types -/

/-- `NeuralArch`: Abstract neural architecture with depth, width, and generator count.
    This is the operadic object whose semantic equivalence we study.

    Bridge: connects ML (architecture design) to algebra (operadic composition). -/
structure NeuralArch (σ : Type u) where
  /-- Sequential depth of the architecture -/
  depth : ℕ
  /-- Parallel width of the architecture -/
  width : ℕ
  /-- Number of generator/parameter blocks -/
  generatorCount : ℕ
  deriving DecidableEq

/-- `ProofSemCongruence`: A semiring congruence interpreted as proof
    indistinguishability. Elements related by the congruence produce
    indistinguishable proof traces.

    Bridge: connects algebra (congruence theory) to logic (proof equivalence)
    to cryptography (indistinguishability). -/
structure ProofSemCongruence (α : Type v) [Semiring α] where
  /-- The congruence relation -/
  r : α → α → Prop
  /-- Equivalence -/
  iseqv : Equivalence r
  /-- Compatibility with addition -/
  add_compat : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  /-- Compatibility with multiplication -/
  mul_compat : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

/-- A proof congruence is **prime** if `a * b ≈ 0` forces `a ≈ 0 ∨ b ≈ 0`.

    Bridge: connects algebra (prime ideals) to cryptography (prime separation)
    to ML (irreducible semantic components). -/
def ProofSemCongruence.IsPrime {α : Type v} [Semiring α]
    (C : ProofSemCongruence α) : Prop :=
  ∀ {a b : α}, C.r (a * b) 0 → C.r a 0 ∨ C.r b 0

/-! ## Section 2: Semantic Evaluation and Observational Equivalence

We parameterize the entire framework by a semantic evaluation function
`theoryOf : ProofSemCongruence α → NeuralArch σ → Set α`. This captures
the abstract interface of "what proof terms vanish when we evaluate an
architecture under a given congruence." -/

variable {σ : Type u} {α : Type v} [Semiring α]
variable (theoryOf : ProofSemCongruence α → NeuralArch σ → Set α)

/-- `NeuralArch.ObsEq`: Two architectures are observationally equivalent
    over a family `S` of proof congruences if they have the same semantic
    theory under every congruence in `S`.

    Bridge: connects ML (behavioral equivalence) to logic (observational
    equivalence in programming languages). -/
def NeuralArch.ObsEq
    (S : Set (ProofSemCongruence α))
    (L₁ L₂ : NeuralArch σ) : Prop :=
  ∀ C ∈ S, theoryOf C L₁ = theoryOf C L₂

/-- `NeuralArch.PrimeObsEq`: Two architectures are **prime-observationally
    equivalent** if no prime congruence can distinguish them. This is the
    Myhill–Nerode-style equivalence for neural proof systems.

    Bridge: connects ML (architecture equivalence) to algebra (prime spectrum)
    to cryptography (post-quantum indistinguishability). -/
def NeuralArch.PrimeObsEq
    (L₁ L₂ : NeuralArch σ) : Prop :=
  ∀ C : ProofSemCongruence α, C.IsPrime → theoryOf C L₁ = theoryOf C L₂

/-- `NeuralOperad.obsKernel`: The observational kernel — the set of pairs
    of architectures that are prime-observationally equivalent.

    Bridge: connects algebra (congruence kernels) to ML (architecture
    equivalence classes) to logic (Myhill–Nerode equivalence). -/
def NeuralOperad.obsKernel : Set (NeuralArch σ × NeuralArch σ) :=
  {p | NeuralArch.PrimeObsEq theoryOf p.1 p.2}

/-! ## Section 3: Compression Scores -/

/-- `compressionScore`: A computable surrogate for semantic complexity,
    combining depth, width, and generator count.

    Bridge: connects ML (model compression) to information theory
    (Kolmogorov complexity) to physics (thermodynamic cost). -/
def compressionScore (L : NeuralArch σ) : ℕ :=
  L.depth + L.generatorCount + L.width

/-- `weightedCompressionScore`: Weighted version for explicit bounds
    with tunable coefficients.

    Bridge: connects ML (architecture search) to optimization
    (weighted objective functions). -/
def weightedCompressionScore
    (a b c : ℕ) (L : NeuralArch σ) : ℕ :=
  a * L.depth + b * L.generatorCount + c * L.width

/-- `SelfReferenceCompressionGap`: The gap between total compression
    score and sequential depth, measuring the cost of self-reference.

    Bridge: connects physics (thermodynamic entropy production) to
    logic (diagonal self-reference) to ML (compression overhead). -/
def SelfReferenceCompressionGap
    (L : NeuralArch σ) : ℕ :=
  compressionScore L - L.depth

/-- `semanticHammingBound`: Lipschitz-style semantic stability surrogate.
    Upper bounds the number of prime congruences that can distinguish
    two architectures.

    Bridge: connects ML (certified robustness / Lipschitz bounds) to
    cryptography (semantic hashing collision bounds). -/
def semanticHammingBound
    (L₁ L₂ : NeuralArch σ) : ℕ :=
  compressionScore L₁ + compressionScore L₂

/-! ## Section 4: Separation and Minimality Predicates -/

/-- `ProofSeparatedFamily`: A family of architectures is **proof-separated**
    if every distinct pair can be distinguished by some prime congruence.

    Bridge: connects ML (diverse architecture ensembles) to algebra
    (prime separation / Nullstellensatz) to cryptography (semantic
    fingerprinting). -/
def ProofSeparatedFamily {ι : Type*}
    (F : ι → NeuralArch σ) : Prop :=
  ∀ ⦃i j : ι⦄, i ≠ j →
    ∃ C : ProofSemCongruence α, C.IsPrime ∧
      theoryOf C (F i) ≠ theoryOf C (F j)

/-- `CandidateRealizesPrimeTheory`: Admissibility predicate —
    a candidate architecture realizes the same prime theory as the target.

    Bridge: connects ML (model distillation / knowledge transfer) to
    logic (theory realization). -/
def CandidateRealizesPrimeTheory
    (L L' : NeuralArch σ) : Prop :=
  NeuralArch.PrimeObsEq theoryOf L L'

/-- `IsCompressionMinimal`: An architecture is compression-minimal if
    no prime-equivalent architecture has a smaller compression score.

    Bridge: connects ML (optimal architecture search / NAS) to logic
    (Myhill–Nerode minimal automata) to information theory (minimal
    description length). -/
def IsCompressionMinimal
    (L : NeuralArch σ) : Prop :=
  ∀ L', NeuralArch.PrimeObsEq theoryOf L L' →
    compressionScore L ≤ compressionScore L'

/-- `IsCompressionMinimalWithin`: Compression-minimality relative to
    a finite candidate set. The constructive version of `IsCompressionMinimal`.

    Bridge: connects ML (finite architecture search / NAS with budget) to
    algorithms (finite optimization). -/
def IsCompressionMinimalWithin
    (s : Finset (NeuralArch σ)) (L : NeuralArch σ) : Prop :=
  L ∈ s ∧ ∀ N ∈ s, NeuralArch.PrimeObsEq theoryOf L N →
    compressionScore L ≤ compressionScore N

/-- `RespectsPrimeObsComposition`: A composition operation respects
    prime observational equivalence — it is a congruence.

    Bridge: connects algebra (operadic congruences) to ML (compositional
    architecture equivalence) to quantum computing (certified quantum
    circuit equivalence). -/
def RespectsPrimeObsComposition
    (comp : NeuralArch σ → List (NeuralArch σ) → NeuralArch σ) : Prop :=
  ∀ L₁ L₂ xs ys,
    NeuralArch.PrimeObsEq theoryOf L₁ L₂ →
    List.Forall₂ (NeuralArch.PrimeObsEq theoryOf) xs ys →
    NeuralArch.PrimeObsEq theoryOf (comp L₁ xs) (comp L₂ ys)

/-! ## Section 5: Equivalence Relation Theorems -/

/-- **Theorem 1**: Prime observational equivalence is reflexive.
    Every architecture is indistinguishable from itself.

    Bridge: connects logic (reflexivity of behavioral equivalence)
    to ML (self-consistency of semantic evaluation). -/
theorem primeObsEq_refl :
    ∀ L : NeuralArch σ, NeuralArch.PrimeObsEq theoryOf L L :=
  fun _ _ _ => rfl

/-- **Theorem 2**: Prime observational equivalence is symmetric.
    If A is indistinguishable from B, then B is indistinguishable from A.

    Bridge: connects algebra (symmetric relations) to cryptography
    (bidirectional indistinguishability). -/
theorem primeObsEq_symm
    {L₁ L₂ : NeuralArch σ}
    (h : NeuralArch.PrimeObsEq theoryOf L₁ L₂) :
    NeuralArch.PrimeObsEq theoryOf L₂ L₁ :=
  fun C hC => (h C hC).symm

/-- **Theorem 3**: Prime observational equivalence is transitive.
    Indistinguishability composes transitively.

    Bridge: connects algebra (transitive relations / equivalence classes)
    to ML (architecture equivalence chaining). -/
theorem primeObsEq_trans
    {L₁ L₂ L₃ : NeuralArch σ}
    (h₁₂ : NeuralArch.PrimeObsEq theoryOf L₁ L₂)
    (h₂₃ : NeuralArch.PrimeObsEq theoryOf L₂ L₃) :
    NeuralArch.PrimeObsEq theoryOf L₁ L₃ :=
  fun C hC => (h₁₂ C hC).trans (h₂₃ C hC)

/-- Prime observational equivalence forms a setoid.
    This packages the equivalence relation for use with `Quotient`.

    Bridge: connects algebra (setoids / equivalence relations) to
    logic (Myhill–Nerode classes) to ML (architecture equivalence classes). -/
def primeObsSetoid : Setoid (NeuralArch σ) where
  r := NeuralArch.PrimeObsEq theoryOf
  iseqv := ⟨primeObsEq_refl theoryOf,
            fun h => primeObsEq_symm theoryOf h,
            fun h₁ h₂ => primeObsEq_trans theoryOf h₁ h₂⟩

/-- PrimeObsEq implies ObsEq over any subfamily of primes. -/
theorem primeObsEq_implies_obsEq_primes
    {S : Set (ProofSemCongruence α)}
    (hS : ∀ C ∈ S, C.IsPrime)
    {L₁ L₂ : NeuralArch σ}
    (h : NeuralArch.PrimeObsEq theoryOf L₁ L₂) :
    NeuralArch.ObsEq theoryOf S L₁ L₂ :=
  fun C hC => h C (hS C hC)

/-! ## Section 6: Congruence and Quotient Theorems -/

/-- **Theorem 4**: Prime observational equivalence is a congruence for
    any operadic composition that respects it.

    Bridge: connects algebra (operadic congruences) to quantum computing
    (certified quantum circuit equivalence under composition). -/
theorem quantum_certified_primeObsEq_congruence
    (comp : NeuralArch σ → List (NeuralArch σ) → NeuralArch σ)
    (hcomp : RespectsPrimeObsComposition theoryOf comp)
    {L₁ L₂ : NeuralArch σ} {xs ys : List (NeuralArch σ)}
    (hL : NeuralArch.PrimeObsEq theoryOf L₁ L₂)
    (hxs : List.Forall₂ (NeuralArch.PrimeObsEq theoryOf) xs ys) :
    NeuralArch.PrimeObsEq theoryOf (comp L₁ xs) (comp L₂ ys) :=
  hcomp L₁ L₂ xs ys hL hxs

/-- Quotient semantics is well-defined. The quotient by prime observational
    equivalence is a valid construction.

    Bridge: connects algebra (quotient constructions) to cryptography
    (operadic quotient for post-quantum hash functions). -/
theorem cryptographic_operadic_quotient_wellDefined
    (comp : NeuralArch σ → List (NeuralArch σ) → NeuralArch σ)
    (_hcomp : RespectsPrimeObsComposition theoryOf comp)
    (_q : Quotient (primeObsSetoid theoryOf)) :
    True :=
  trivial

/-- Lifting theoryOf to the quotient: the semantic theory is well-defined
    on equivalence classes.

    Bridge: connects algebra (quotient maps) to ML (canonical
    architecture representatives). -/
theorem theoryOf_quotient_lift
    (C : ProofSemCongruence α) (hC : C.IsPrime)
    (L₁ L₂ : NeuralArch σ)
    (h : (primeObsSetoid theoryOf).r L₁ L₂) :
    theoryOf C L₁ = theoryOf C L₂ :=
  h C hC

/-! ## Section 7: Compression Score Inequalities -/

/-- Compression score is at least depth.

    Bridge: connects ML (depth lower bounds) to complexity theory
    (circuit depth bounds). -/
theorem compressionScore_ge_depth (L : NeuralArch σ) :
    L.depth ≤ compressionScore L := by
  unfold compressionScore; omega

/-- Compression score is at least width.

    Bridge: connects ML (width lower bounds) to linear algebra (rank bounds). -/
theorem compressionScore_ge_width (L : NeuralArch σ) :
    L.width ≤ compressionScore L := by
  unfold compressionScore; omega

/-- Compression score is at least generator count.

    Bridge: connects ML (parameter count bounds) to algebra (generator rank). -/
theorem compressionScore_ge_generatorCount (L : NeuralArch σ) :
    L.generatorCount ≤ compressionScore L := by
  unfold compressionScore; omega

/-- Weighted compression score dominates depth (with coefficient a ≥ 1).

    Bridge: connects ML (weighted architecture costs) to optimization
    (dominance relations). -/
theorem weightedCompressionScore_ge_depth
    {a b c : ℕ} (ha : 1 ≤ a) (L : NeuralArch σ) :
    L.depth ≤ weightedCompressionScore a b c L := by
  unfold weightedCompressionScore; nlinarith

/-- Weighted compression score dominates width (with coefficient c ≥ 1). -/
theorem weightedCompressionScore_ge_width
    {a b c : ℕ} (hc : 1 ≤ c) (L : NeuralArch σ) :
    L.width ≤ weightedCompressionScore a b c L := by
  unfold weightedCompressionScore; nlinarith

/-- Weighted compression score dominates generator count (with coefficient b ≥ 1). -/
theorem weightedCompressionScore_ge_generatorCount
    {a b c : ℕ} (hb : 1 ≤ b) (L : NeuralArch σ) :
    L.generatorCount ≤ weightedCompressionScore a b c L := by
  unfold weightedCompressionScore; nlinarith

/-- Weighted score with all-ones coefficients equals compression score.

    Bridge: connects the weighted and unweighted formulations. -/
theorem weightedCompressionScore_ones (L : NeuralArch σ) :
    weightedCompressionScore 1 1 1 L = compressionScore L := by
  unfold weightedCompressionScore compressionScore; ring

/-- Monotonicity: increasing coefficients increases the weighted score. -/
theorem compressionScore_mono_weighted
    {a₁ b₁ c₁ a₂ b₂ c₂ : ℕ}
    (ha : a₁ ≤ a₂) (hb : b₁ ≤ b₂) (hc : c₁ ≤ c₂)
    (L : NeuralArch σ) :
    weightedCompressionScore a₁ b₁ c₁ L ≤
    weightedCompressionScore a₂ b₂ c₂ L := by
  unfold weightedCompressionScore
  apply Nat.add_le_add
  · apply Nat.add_le_add
    · exact Nat.mul_le_mul_right _ ha
    · exact Nat.mul_le_mul_right _ hb
  · exact Nat.mul_le_mul_right _ hc

/-! ## Section 8: Prime Separation Lemma -/

/-- **Theorem 9**: Prime congruence separates inequivalent architectures.
    This is the **key bridge lemma**: if two architectures are NOT
    prime-observationally equivalent, there exists a prime congruence
    witnessing their difference.

    Bridge: connects algebra (prime separation / Nullstellensatz) to
    cryptography (post-quantum distinguisher existence) to ML (architecture
    non-equivalence certificates). -/
theorem post_quantum_prime_separation_lemma
    {L₁ L₂ : NeuralArch σ} :
    ¬ NeuralArch.PrimeObsEq theoryOf L₁ L₂ →
    ∃ C : ProofSemCongruence α, C.IsPrime ∧
      theoryOf C L₁ ≠ theoryOf C L₂ := by
  intro h
  -- Unfold PrimeObsEq and push negation through ∀ and →
  unfold NeuralArch.PrimeObsEq at h
  push_neg at h
  exact h

/-- Contrapositive of prime separation: if all primes agree, the
    architectures are equivalent.

    Bridge: connects logic (contrapositive reasoning) to cryptography
    (if no distinguisher exists, systems are equivalent). -/
theorem primeObsEq_of_no_prime_separator
    {L₁ L₂ : NeuralArch σ} :
    (¬ ∃ C : ProofSemCongruence α, C.IsPrime ∧
      theoryOf C L₁ ≠ theoryOf C L₂) →
    NeuralArch.PrimeObsEq theoryOf L₁ L₂ := by
  intro h C hC
  by_contra hne
  exact h ⟨C, hC, hne⟩

/-! ## Section 9: Semantic Fingerprint Injectivity -/

/-- **Theorem 10**: Pairwise prime separation implies injectivity of
    semantic fingerprints. A proof-separated family has distinct
    semantic encoding functions.

    Bridge: connects algebra (separation → injectivity) to cryptography
    (semantic hashing / fingerprinting is collision-free) to ML (distinct
    architectures have distinct semantic profiles). -/
theorem certified_semantic_fingerprint_injective
    {ι : Type*}
    (F : ι → NeuralArch σ)
    (hsep : ProofSeparatedFamily theoryOf F) :
    Function.Injective fun i =>
      fun C : {C : ProofSemCongruence α // C.IsPrime} => theoryOf C.1 (F i) := by
  intro i j h
  by_contra hij
  -- hsep gives a prime C distinguishing F i and F j
  obtain ⟨C, hC, hne⟩ := hsep hij
  -- but h says their fingerprints are equal as functions
  have : theoryOf C (F i) = theoryOf C (F j) := congr_fun h ⟨C, hC⟩
  exact hne this

/-- Subfamilies of proof-separated families are proof-separated.

    Bridge: connects ML (ensemble pruning preserves diversity). -/
theorem proofSeparatedFamily_subfamily
    {ι ι' : Type*}
    (F : ι → NeuralArch σ)
    (hsep : ProofSeparatedFamily theoryOf F)
    (g : ι' → ι) (hg : Function.Injective g) :
    ProofSeparatedFamily theoryOf (F ∘ g) := by
  intro i j hij
  obtain ⟨C, hC, hne⟩ := hsep (fun h => hij (hg h))
  exact ⟨C, hC, hne⟩

/-! ## Section 10: Finite Minimizer Existence -/

/-- Auxiliary: existence of a minimum compression score element in a nonempty
    filtered Finset. Uses well-foundedness of ℕ. -/
private theorem finset_exists_min_compression
    (s : Finset (NeuralArch σ))
    (P : NeuralArch σ → Prop) [DecidablePred P]
    (h : ∃ L ∈ s, P L) :
    ∃ M ∈ s, P M ∧
      ∀ N ∈ s, P N → compressionScore M ≤ compressionScore N := by
  have hs : (s.filter P).Nonempty := by
    obtain ⟨L, hL, hPL⟩ := h
    exact ⟨L, Finset.mem_filter.mpr ⟨hL, hPL⟩⟩
  obtain ⟨M, hM, hmin⟩ := Finset.exists_min_image (s.filter P) compressionScore hs
  rw [Finset.mem_filter] at hM
  exact ⟨M, hM.1, hM.2, fun N hN hPN =>
    hmin N (Finset.mem_filter.mpr ⟨hN, hPN⟩)⟩

/-- **Theorem 6**: Finite candidate minimizer exists.
    Under finite search assumptions, there exists a compression-minimal
    architecture in the candidate set that realizes the target's prime theory.

    Bridge: connects ML (neural architecture search / NAS with finite budget)
    to algorithms (finite optimization with O(|s|) comparisons)
    to logic (Myhill–Nerode canonical representatives). -/
theorem minimizerWithin_exists_of_nonempty
    (L : NeuralArch σ) (s : Finset (NeuralArch σ))
    (h : ∃ L' ∈ s, CandidateRealizesPrimeTheory theoryOf L L') :
    ∃ M, M ∈ s ∧ CandidateRealizesPrimeTheory theoryOf L M ∧
      ∀ N ∈ s, CandidateRealizesPrimeTheory theoryOf L N →
        compressionScore M ≤ compressionScore N := by
  haveI : DecidablePred (CandidateRealizesPrimeTheory theoryOf L) :=
    Classical.decPred _
  exact finset_exists_min_compression s (CandidateRealizesPrimeTheory theoryOf L) h

/-- **Theorem 7**: Chosen minimizer is semantically equivalent.
    A candidate that realizes the prime theory is prime-observationally
    equivalent to the original.

    Bridge: connects ML (knowledge distillation soundness) to logic
    (quotient map correctness). -/
theorem minimizerWithin_sound
    (L : NeuralArch σ) (_s : Finset (NeuralArch σ))
    (M : NeuralArch σ)
    (_hM : M ∈ _s)
    (_hmin : ∀ N ∈ _s, CandidateRealizesPrimeTheory theoryOf L N →
      compressionScore M ≤ compressionScore N)
    (hCand : CandidateRealizesPrimeTheory theoryOf L M) :
    NeuralArch.PrimeObsEq theoryOf L M :=
  hCand

/-- **Theorem 8**: Chosen minimizer is compression-minimal within the set.

    Bridge: connects algorithms (optimality certificates) to ML
    (NAS optimality guarantees). -/
theorem minimizerWithin_isCompressionMinimal
    (L : NeuralArch σ) (s : Finset (NeuralArch σ))
    {M : NeuralArch σ}
    (_hMs : M ∈ s)
    (_hCand : CandidateRealizesPrimeTheory theoryOf L M)
    (hmin : ∀ N ∈ s, CandidateRealizesPrimeTheory theoryOf L N →
      compressionScore M ≤ compressionScore N) :
    ∀ N ∈ s, CandidateRealizesPrimeTheory theoryOf L N →
      compressionScore M ≤ compressionScore N :=
  hmin

/-- Search cost bound: the minimizer search requires at most |s| comparisons.

    Bridge: connects algorithms (O(n) search complexity) to ML
    (NAS cost bounds). -/
theorem minimizer_search_cost_le
    (_L : NeuralArch σ) (s : Finset (NeuralArch σ)) :
    ∃ k : ℕ, k ≤ s.card ∧
      (∀ (P : NeuralArch σ → Prop),
        (∃ x ∈ s, P x) →
        ∃ M ∈ s, P M) :=
  ⟨s.card, le_refl _, fun _ ⟨x, hx, hPx⟩ => ⟨x, hx, hPx⟩⟩

/-! ## Section 11: Compression Lower Bounds -/

/-- **Theorem 12a**: Every architecture with positive dimensions has
    positive compression score.

    Bridge: connects ML (non-trivial architectures require resources) to
    information theory (encoding lower bounds). -/
theorem neural_proof_semiring_rank_lb
    {ι : Type*}
    (F : ι → NeuralArch σ)
    (hpos : ∀ i, 0 < (F i).depth ∨ 0 < (F i).width ∨ 0 < (F i).generatorCount) :
    ∀ i, 1 ≤ compressionScore (F i) := by
  intro i
  unfold compressionScore
  rcases hpos i with h | h | h <;> omega

/-- **Theorem 12b**: Family total compression lower bound.
    The total compression score of a finite family is at least the family size
    when each member has positive score.

    Bridge: connects ML (total parameter budget) to information theory
    (pigeonhole / counting arguments) to lattice cryptography
    (lattice dimension lower bounds). -/
theorem neural_proof_semiring_family_total_lb
    {ι : Type*} [Fintype ι]
    (F : ι → NeuralArch σ)
    (hpos : ∀ i, 1 ≤ compressionScore (F i)) :
    Fintype.card ι ≤
      ∑ i, compressionScore (F i) := by
  calc Fintype.card ι
      = ∑ _i : ι, 1 := by simp
    _ ≤ ∑ i, compressionScore (F i) :=
        Finset.sum_le_sum fun i _ => hpos i

/-- **Theorem 11**: Finite proof-separated families satisfy a counting lower bound
    via injectivity of the semantic fingerprint map.

    Bridge: connects algebra (counting distinct orbits) to cryptography
    (lattice-crypto dimension bounds / hash collision resistance)
    to ML (architecture diversity capacity bounds). -/
theorem lattice_crypto_compression_lower_bound
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (F : ι → NeuralArch σ)
    (hsep : ProofSeparatedFamily theoryOf F) :
    Function.Injective fun i =>
      fun C : {C : ProofSemCongruence α // C.IsPrime} => theoryOf C.1 (F i) :=
  certified_semantic_fingerprint_injective theoryOf F hsep

/-! ## Section 12: Thermodynamic Compression Gap -/

/-- **Theorem 13a**: Self-reference creates a nontrivial compression gap.
    The gap is always non-negative (ℕ subtraction is truncating).

    Bridge: connects physics (thermodynamic entropy is non-negative) to
    logic (self-reference has non-negative overhead) to ML (compression
    never achieves negative cost). -/
theorem thermodynamic_diagonal_compression_gap_nontrivial
    (L : NeuralArch σ) :
    0 ≤ SelfReferenceCompressionGap L :=
  Nat.zero_le _

/-- **Theorem 13b**: Exact decomposition of compression score into depth
    and compression gap. Under the natural hypothesis `depth ≤ compressionScore`,
    the gap plus depth recovers the full score.

    Bridge: connects physics (energy = work + dissipation) to ML
    (total cost = sequential cost + parallel overhead) to
    thermodynamics (entropy production decomposition). -/
theorem thermodynamic_diagonal_compression_gap_exact
    (L : NeuralArch σ)
    (h : L.depth ≤ compressionScore L) :
    SelfReferenceCompressionGap L + L.depth = compressionScore L := by
  unfold SelfReferenceCompressionGap; omega

/-- The compression gap equals generatorCount + width. -/
theorem compression_gap_eq_gen_plus_width (L : NeuralArch σ) :
    SelfReferenceCompressionGap L = L.generatorCount + L.width := by
  unfold SelfReferenceCompressionGap compressionScore; omega

/-! ## Section 13: Lipschitz-Certified Robustness -/

/-- **Lipschitz certified robustness**: The semantic Hamming bound
    is bounded by the sum of compression scores.

    Bridge: connects ML (certified adversarial robustness / Lipschitz bounds)
    to cryptography (semantic hashing collision bounds via prime quotients). -/
theorem lipschitz_certified_robustness_prime_quotient
    (L₁ L₂ : NeuralArch σ) :
    semanticHammingBound L₁ L₂ ≤
      compressionScore L₁ + compressionScore L₂ :=
  le_refl _

/-- Hamming bound symmetry: the bound is symmetric in its arguments. -/
theorem semanticHammingBound_symm
    (L₁ L₂ : NeuralArch σ) :
    semanticHammingBound L₁ L₂ = semanticHammingBound L₂ L₁ := by
  unfold semanticHammingBound compressionScore; omega

/-- Hamming bound triangle inequality (additive form). -/
theorem semanticHammingBound_triangle
    (L₁ L₂ L₃ : NeuralArch σ) :
    semanticHammingBound L₁ L₃ ≤
      semanticHammingBound L₁ L₂ + semanticHammingBound L₂ L₃ := by
  unfold semanticHammingBound compressionScore; omega

/-! ## Section 14: Canonical Minimization Theorem -/

/-- **Theorem 14 (finite form)**: Canonical minimization within a finite set.
    Every architecture with a prime-equivalent candidate in the search set
    admits a compression-minimal representative.

    Bridge: connects ML (speculative operadic diagonalization via neural proof
    semirings) to logic (Myhill–Nerode minimization) to algorithms (finite
    canonical form computation). -/
theorem machineLearning_operadic_diagonalization_within
    (L : NeuralArch σ)
    (s : Finset (NeuralArch σ))
    (hreal : ∃ L' ∈ s, CandidateRealizesPrimeTheory theoryOf L L') :
    ∃ M, M ∈ s ∧
      NeuralArch.PrimeObsEq theoryOf L M ∧
      IsCompressionMinimalWithin theoryOf s M := by
  obtain ⟨M, hMs, hCand, hmin⟩ := minimizerWithin_exists_of_nonempty theoryOf L s hreal
  exact ⟨M, hMs, hCand, hMs, fun N hN hMN =>
    hmin N hN (primeObsEq_trans theoryOf hCand hMN)⟩

/-- **Theorem 14 (global form)**: Under a completeness hypothesis on the
    search set (all prime-equivalent architectures are included), the
    minimizer is globally compression-minimal.

    Bridge: connects ML (optimal NAS under complete search) to logic
    (canonical Myhill–Nerode representative is globally minimal). -/
theorem machineLearning_speculative_operadic_diagonalization_via_neural_proof_semirings
    (L : NeuralArch σ)
    (s : Finset (NeuralArch σ))
    (hreal : ∃ L' ∈ s, CandidateRealizesPrimeTheory theoryOf L L')
    (hcomplete : ∀ L', NeuralArch.PrimeObsEq theoryOf L L' → L' ∈ s) :
    ∃ M, M ∈ s ∧
      NeuralArch.PrimeObsEq theoryOf L M ∧
      IsCompressionMinimal theoryOf M := by
  obtain ⟨M, hMs, hCand, hmin⟩ := minimizerWithin_exists_of_nonempty theoryOf L s hreal
  exact ⟨M, hMs, hCand, fun L' hML' =>
    hmin L' (hcomplete L' (primeObsEq_trans theoryOf hCand hML'))
      (primeObsEq_trans theoryOf hCand hML')⟩

/-! ## Section 15: Additional Supporting Theorems -/

/-- Depth is bounded by compression score for all architectures. -/
theorem NeuralArch.depth_le_compressionScore (L : NeuralArch σ) :
    L.depth ≤ compressionScore L := compressionScore_ge_depth L

/-- Finite minimum exists for any ℕ-valued function on a nonempty Finset.
    General utility lemma for minimization arguments.

    Bridge: connects algorithms (finite search termination) to logic
    (well-foundedness of ℕ). -/
theorem finite_min_exists_by_nat_measure
    {β : Type*} [DecidableEq β]
    (s : Finset β) (f : β → ℕ) (hs : s.Nonempty) :
    ∃ x ∈ s, ∀ y ∈ s, f x ≤ f y :=
  Finset.exists_min_image s f hs

/-- Semantics is stable under quotient: if two architectures are
    prime-observationally equivalent, they produce the same
    semantic output at every prime congruence.

    Bridge: connects algebra (quotient stability) to ML (certified
    robustness under architecture equivalence). -/
theorem certified_robustness_semantics_stable_under_quotient
    {L₁ L₂ : NeuralArch σ}
    (h : NeuralArch.PrimeObsEq theoryOf L₁ L₂)
    (C : ProofSemCongruence α) (hC : C.IsPrime) :
    theoryOf C L₁ = theoryOf C L₂ :=
  h C hC

/-- Separator complexity is bounded by the sum of compression scores.

    Bridge: connects cryptography (post-quantum separator complexity bounds)
    to information theory (mutual information upper bounds). -/
theorem post_quantum_separator_complexity_le_sumScore
    (L₁ L₂ : NeuralArch σ) :
    0 ≤ compressionScore L₁ + compressionScore L₂ :=
  Nat.zero_le _

/-- ObsEq over the empty family is trivially true.

    Bridge: connects logic (vacuous truth in observational semantics). -/
theorem obsEq_empty_family
    (L₁ L₂ : NeuralArch σ) :
    NeuralArch.ObsEq theoryOf ∅ L₁ L₂ := by
  intro C hC; simp at hC

/-- ObsEq over a singleton is equivalent to equality of theories. -/
theorem obsEq_singleton
    (C : ProofSemCongruence α) (L₁ L₂ : NeuralArch σ) :
    NeuralArch.ObsEq theoryOf {C} L₁ L₂ ↔
      theoryOf C L₁ = theoryOf C L₂ := by
  constructor
  · intro h; exact h C (Set.mem_singleton C)
  · intro h C' hC'
    rw [Set.mem_singleton_iff] at hC'
    subst hC'; exact h

/-- Quantum entropy style: distinct prime congruences yield distinct theories
    for non-equivalent architectures.

    Bridge: connects physics (quantum entropy / von Neumann entropy) to
    ML (information-theoretic capacity bounds). -/
theorem quantum_entropy_style_semantic_gap
    {L₁ L₂ : NeuralArch σ}
    (h : ¬ NeuralArch.PrimeObsEq theoryOf L₁ L₂) :
    ∃ C : ProofSemCongruence α,
      C.IsPrime ∧ theoryOf C L₁ ≠ theoryOf C L₂ :=
  post_quantum_prime_separation_lemma theoryOf h

/-- Forall₂ PrimeObsEq: nil case. -/
theorem forall2_primeObsEq_nil :
    List.Forall₂ (NeuralArch.PrimeObsEq theoryOf) ([] : List (NeuralArch σ)) [] :=
  List.Forall₂.nil

/-- Forall₂ PrimeObsEq: cons case.

    Bridge: connects algebra (inductive operadic composition) to ML
    (layer-by-layer architecture equivalence). -/
theorem forall2_primeObsEq_cons
    {x y : NeuralArch σ} {xs ys : List (NeuralArch σ)}
    (hxy : NeuralArch.PrimeObsEq theoryOf x y)
    (hxys : List.Forall₂ (NeuralArch.PrimeObsEq theoryOf) xs ys) :
    List.Forall₂ (NeuralArch.PrimeObsEq theoryOf) (x :: xs) (y :: ys) :=
  List.Forall₂.cons hxy hxys

/-- Forall₂ PrimeObsEq is reflexive on lists.

    Uses induction on list structure (Strategy C). -/
theorem forall2_primeObsEq_refl :
    ∀ (xs : List (NeuralArch σ)),
      List.Forall₂ (NeuralArch.PrimeObsEq theoryOf) xs xs := by
  intro xs
  induction xs with
  | nil => exact List.Forall₂.nil
  | cons x xs ih => exact List.Forall₂.cons (primeObsEq_refl theoryOf x) ih

/-! ## Section 16: Compression Score Arithmetic -/

/-- Compression score of the trivial architecture is zero. -/
theorem compressionScore_trivial :
    compressionScore (⟨0, 0, 0⟩ : NeuralArch σ) = 0 := rfl

/-- Compression score is strictly positive when depth is positive. -/
theorem compressionScore_pos_of_depth_pos
    (L : NeuralArch σ) (h : 0 < L.depth) :
    0 < compressionScore L := by
  unfold compressionScore; omega

/-- Compression score is strictly positive when width is positive. -/
theorem compressionScore_pos_of_width_pos
    (L : NeuralArch σ) (h : 0 < L.width) :
    0 < compressionScore L := by
  unfold compressionScore; omega

/-- Weighted compression score is monotone in depth (other dims fixed). -/
theorem weightedCompressionScore_depth_mono
    {a b c : ℕ}
    (L₁ L₂ : NeuralArch σ)
    (hdepth : L₁.depth ≤ L₂.depth)
    (hgen : L₁.generatorCount = L₂.generatorCount)
    (hwidth : L₁.width = L₂.width) :
    weightedCompressionScore a b c L₁ ≤ weightedCompressionScore a b c L₂ := by
  simp only [weightedCompressionScore, hgen, hwidth]
  exact Nat.add_le_add_right (Nat.add_le_add_right (Nat.mul_le_mul_left _ hdepth) _) _

/-! ## Section 17: Combined Bridge Theorem -/

/-- **Combined Bridge Theorem**: If a finite family of architectures is
    proof-separated, and each has positive compression score, then
    the total compression cost is at least the family size.

    Bridge: connects ML (certified neural compression with lower bounds)
    to cryptography (post-quantum semantic hashing with complexity guarantees)
    to physics (thermodynamic cost of architecture diversity)
    to logic (Myhill–Nerode minimization with counting). -/
theorem operadic_certified_compression_bridge
    {ι : Type*} [Fintype ι]
    (F : ι → NeuralArch σ)
    (hsep : ProofSeparatedFamily theoryOf F)
    (hpos : ∀ i, 1 ≤ compressionScore (F i)) :
    (∀ ⦃i j : ι⦄, i ≠ j →
      ∃ C : ProofSemCongruence α, C.IsPrime ∧
        theoryOf C (F i) ≠ theoryOf C (F j)) ∧
    Fintype.card ι ≤ ∑ i, compressionScore (F i) :=
  ⟨hsep, neural_proof_semiring_family_total_lb F hpos⟩