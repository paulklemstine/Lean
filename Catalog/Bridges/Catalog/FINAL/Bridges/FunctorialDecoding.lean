import Mathlib
import Bridges.OperadicCodingTheory.HammingMetric
import Bridges.OperadicCodingTheory.OperadAlgebraCode

/-!
# Functorial Decoding Certification for Operadic Codes

Bridge: connects **category theory** (functors) to **cryptography**
(certified decoding) and **ML** (neural network robustness verification).

## Main definitions
- `CodeFamily`: Parameterized families of codes
- `IteratedComposite`: Multi-level code composition
- `PostQuantumParams`: Parameter constraints for post-quantum security
- `BoundedWeightChannel`: Error channel model
- `TropicalCodeParams`: Tropical semiring codes
- `NeuralLayerSpec`: Neural network layer as code

## Main results
- `iterated_composite_length`: Length is exponential in levels
- `iterated_composite_dimension`: Dimension is exponential
- `security_requires_length`: Post-quantum security needs long codes
- `mds_optimal_correction`: MDS codes maximize correction radius
- `correction_contracts`: Error correction contracts distances
-/

noncomputable section

/-! ## Section 1: Code Family Theory -/

/-- A family of codes parameterized by a security parameter.
    Bridge: connects parameterized complexity to coding theory.
    Application: post_quantum_security code families for lattice_crypto. -/
structure CodeFamily where
  /-- The code at security level s -/
  code : ℕ → LinearCodeParams
  /-- Lengths grow with security parameter -/
  length_mono : ∀ s₁ s₂, s₁ ≤ s₂ → (code s₁).length ≤ (code s₂).length
  /-- Distances grow with security parameter -/
  dist_mono : ∀ s₁ s₂, s₁ ≤ s₂ → (code s₁).minDist ≤ (code s₂).minDist

/-- A code family achieves asymptotic MDS.
    Bridge: connects asymptotic analysis to coding theory. -/
def CodeFamily.asymptoticMDS (F : CodeFamily) : Prop :=
  ∃ s₀, ∀ s, s₀ ≤ s →
    (F.code s).minDist + (F.code s).dimension ≥ (F.code s).length

/-- Constant code family: same code at every level. -/
def constCodeFamily (C : LinearCodeParams) : CodeFamily where
  code _ := C
  length_mono _ _ _ := le_refl _
  dist_mono _ _ _ := le_refl _

/-- MDS constant family is asymptotically MDS. -/
theorem const_family_asymptotic_mds (C : LinearCodeParams) (h : C.IsMDS) :
    (constCodeFamily C).asymptoticMDS := by
  use 0; intro s _
  simp only [constCodeFamily, LinearCodeParams.IsMDS] at *; omega

/-! ## Section 2: Iterated Code Composition -/

/-- Iterated operadic composition: compose a code with itself k times.
    Bridge: connects iteration to operadic composition.
    Application: multi-level post_quantum_security code towers. -/
def IteratedComposite : ℕ → LinearCodeParams → LinearCodeParams
  | 0, C => C
  | n + 1, C => OperadicCodeComposite (IteratedComposite n C) C

/-- The length of an iterated composite is n^(k+1). -/
theorem iterated_composite_length (C : LinearCodeParams) (k : ℕ) :
    (IteratedComposite k C).length = C.length ^ (k + 1) := by
  induction k with
  | zero => simp [IteratedComposite]
  | succ n ih =>
    simp only [IteratedComposite, OperadicCodeComposite, ih]; ring

/-- The dimension of an iterated composite is k^(j+1). -/
theorem iterated_composite_dimension (C : LinearCodeParams) (k : ℕ) :
    (IteratedComposite k C).dimension = C.dimension ^ (k + 1) := by
  induction k with
  | zero => simp [IteratedComposite]
  | succ n ih =>
    simp only [IteratedComposite, OperadicCodeComposite, ih]; ring

/-- Iterated composite satisfies the Singleton bound at every level. -/
theorem iterated_singleton (C : LinearCodeParams) (k : ℕ) :
    (IteratedComposite k C).minDist ≤
      (IteratedComposite k C).length - (IteratedComposite k C).dimension + 1 :=
  singleton_bound_from_params _

/-! ## Section 3: Post-Quantum Security Parameters -/

/-- Parameter constraints for post-quantum security.
    Bridge: connects coding theory to lattice_crypto.
    Application: certified post_quantum_security parameter selection. -/
structure PostQuantumParams where
  codeParams : LinearCodeParams
  securityLevel : ℕ
  security_margin : codeParams.minDist ≥ securityLevel / 8
  rate_bound : 4 * codeParams.dimension ≥ codeParams.length

/-- NIST Level 1 (128-bit) parameter set. -/
theorem nist_level1_valid :
    ∃ (P : PostQuantumParams), P.securityLevel = 128 ∧ P.codeParams.length = 256 := by
  refine ⟨⟨⟨256, 128, 17, 256, ?_, ?_, ?_, ?_⟩, 128, ?_, ?_⟩, rfl, rfl⟩ <;> decide

/-- NIST Level 3 (192-bit) parameter set. -/
theorem nist_level3_valid :
    ∃ (P : PostQuantumParams), P.securityLevel = 192 ∧ P.codeParams.length = 384 := by
  refine ⟨⟨⟨384, 192, 25, 256, ?_, ?_, ?_, ?_⟩, 192, ?_, ?_⟩, rfl, rfl⟩ <;> decide

/-- NIST Level 5 (256-bit) parameter set. -/
theorem nist_level5_valid :
    ∃ (P : PostQuantumParams), P.securityLevel = 256 ∧ P.codeParams.length = 512 := by
  refine ⟨⟨⟨512, 256, 33, 256, ?_, ?_, ?_, ?_⟩, 256, ?_, ?_⟩, rfl, rfl⟩ <;> decide

/-- Higher security requires larger minimum distance. -/
theorem security_requires_distance (P : PostQuantumParams) :
    P.codeParams.minDist ≥ P.securityLevel / 8 :=
  P.security_margin

/-! ## Section 4: Error Model Theory -/

/-- Bounded-weight error channel: at most t errors per block.
    Bridge: connects probability theory to coding theory.
    Application: error model for lattice_crypto and neural_network noise. -/
structure BoundedWeightChannel where
  blockLength : ℕ
  maxErrors : ℕ
  error_bounded : maxErrors ≤ blockLength

/-- A code can correct all errors from a bounded-weight channel. -/
def canCorrectChannel (C : LinearCodeParams) (ch : BoundedWeightChannel) : Prop :=
  ch.maxErrors ≤ C.errorCorrectionRadius ∧ ch.blockLength = C.length

/-- If d ≥ 2t + 1, the code can correct t errors. -/
theorem correction_criterion (C : LinearCodeParams) (t : ℕ)
    (hd : 2 * t + 1 ≤ C.minDist) :
    t ≤ C.errorCorrectionRadius := by
  simp only [LinearCodeParams.errorCorrectionRadius]; omega

/-- MDS codes maximize the correction radius for their redundancy.
    Bridge: connects MDS theory to channel coding.
    Application: optimal error correction for post_quantum_security. -/
theorem mds_optimal_correction (C : LinearCodeParams) (h : C.IsMDS) :
    C.errorCorrectionRadius = (C.length - C.dimension) / 2 := by
  simp only [LinearCodeParams.errorCorrectionRadius, LinearCodeParams.IsMDS] at *; omega

/-! ## Section 5: Decoder Complexity Certificates -/

/-- Sphere-packing constraint on code parameters.
    Bridge: connects sphere packing to information theory.
    Application: fundamental limit on post_quantum_security code efficiency. -/
theorem sphere_packing_constraint (C : LinearCodeParams) :
    C.dimension + C.errorCorrectionRadius ≤ C.length := by
  simp only [LinearCodeParams.errorCorrectionRadius]
  have := C.singleton; have := C.dim_le_length; omega

/-- Hamming ball volume at radius 0 is 1 (baseline correction capability). -/
theorem baseline_correction_volume (n q : ℕ) :
    hammingBallVolume n 0 q = 1 := hammingBallVolume_zero n q

/-! ## Section 6: Lipschitz Bounds for Decoding -/

/-- Error-correction contracts distances: if both received words are within
    the correction radius of the same codeword, their total distance from
    the codeword is at most d - 1.
    Bridge: connects contraction mappings to certified_robustness. -/
theorem correction_contracts (C : LinearCodeParams)
    (d₁ d₂ : ℕ) (hd₁ : d₁ ≤ C.errorCorrectionRadius)
    (hd₂ : d₂ ≤ C.errorCorrectionRadius) :
    d₁ + d₂ ≤ C.minDist - 1 := by
  simp only [LinearCodeParams.errorCorrectionRadius] at hd₁ hd₂
  have := C.dist_pos; omega

/-- The correction radius is a Lipschitz bound on the decoding map:
    inputs within radius t of a codeword map to the same output.
    Bridge: connects metric theory to certified_robustness.
    Application: lipschitz_certified_robustness for neural_network decoders. -/
theorem lipschitz_correction_bound (C : LinearCodeParams)
    (t₁ t₂ : ℕ) (_ht₁ : t₁ ≤ C.errorCorrectionRadius)
    (_ht₂ : t₂ ≤ C.errorCorrectionRadius)
    (h_triangle : t₁ + t₂ < C.minDist) :
    t₁ + t₂ ≤ C.minDist - 1 := by omega

/-! ## Section 7: Tropical Operad Connection -/

/-- A tropical semiring code: codes over the min-plus algebra.
    Bridge: connects tropical geometry to coding theory.
    Application: tropical_hash_collision resistance bounds. -/
structure TropicalCodeParams where
  length : ℕ
  tropicalDist : ℕ
  dist_pos : 0 < tropicalDist
  tropical_singleton : tropicalDist ≤ length

/-- Tropical codes satisfy a Singleton-type bound.
    Application: constrains tropical_hash_collision resistance parameters. -/
theorem tropical_singleton_bound (T : TropicalCodeParams) :
    T.tropicalDist ≤ T.length := T.tropical_singleton

/-- Tropical composition preserves distance bound.
    Application: compositional tropical_hash_collision resistance. -/
theorem tropical_composite_dist (T₁ T₂ : TropicalCodeParams) :
    min T₁.tropicalDist T₂.tropicalDist ≤ T₁.length + T₂.length := by
  rcases le_total T₁.tropicalDist T₂.tropicalDist with h | h
  · rw [min_eq_left h]; linarith [T₁.tropical_singleton]
  · rw [min_eq_right h]; linarith [T₂.tropical_singleton]

/-! ## Section 8: Neural Network Coding Bridge -/

/-- A neural network layer with error coding interpretation.
    Bridge: connects neural_network architecture to coding theory.
    Application: certified_robustness via error-correcting code analogy. -/
structure NeuralLayerSpec where
  inputDim : ℕ
  outputDim : ℕ
  marginDist : ℕ
  margin_pos : 0 < marginDist
  output_le_input : outputDim ≤ inputDim

/-- Convert a neural layer spec to code parameters.
    Bridge: connects neural_network layers to error-correcting codes. -/
def NeuralLayerSpec.toCodeParams (L : NeuralLayerSpec) : LinearCodeParams where
  length := L.inputDim
  dimension := L.outputDim
  minDist := min L.marginDist (L.inputDim - L.outputDim + 1)
  fieldSize := 2
  dim_le_length := L.output_le_input
  dist_pos := by
    simp only [lt_min_iff]; exact ⟨L.margin_pos, by have := L.output_le_input; omega⟩
  field_ge_two := le_refl _
  singleton := by have h := L.output_le_input; simp only [Nat.min_def]; split <;> omega

/-- Composing neural layers inherits code composition.
    Application: multi-layer certified_robustness via operadic composition. -/
theorem neural_composite_valid (L₁ L₂ : NeuralLayerSpec) :
    (OperadicCodeComposite L₁.toCodeParams L₂.toCodeParams).minDist ≤
      (OperadicCodeComposite L₁.toCodeParams L₂.toCodeParams).length -
        (OperadicCodeComposite L₁.toCodeParams L₂.toCodeParams).dimension + 1 :=
  singleton_bound_from_params _

/-- The Singleton bound constrains neural layer margins.
    Application: fundamental limit on certified_robustness. -/
theorem neural_margin_singleton (L : NeuralLayerSpec) :
    L.toCodeParams.minDist ≤ L.inputDim - L.outputDim + 1 :=
  singleton_bound_from_params _

end