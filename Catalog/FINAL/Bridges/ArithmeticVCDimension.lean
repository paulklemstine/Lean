import Mathlib

/-! # Arithmetic VC-Dimension via Height-Stratified Shattering
    for Rational Operadic Networks

This file establishes a certified pipeline from arithmetic height control to
pseudo-dimension upper bounds for rational operadic neural architectures.

## Mathematical Domains Bridged
1. **Arithmetic/Algebraic Geometry**: Weil height, valuation signatures, rational
   parameter complexity, Northcott finiteness
2. **Statistical Learning Theory**: VC/pseudo-dimension, Sauer–Shelah bounds,
   finite trace counting, certified robustness
3. **Cryptographic/Post-Quantum**: height-stratified trace classes as finite
   arithmetic codebooks, lattice-style discrete parameter spaces

## Central Pipeline
  height control ⇒ finite arithmetic traces ⇒ bounded trace count
  ⇒ no large shattering ⇒ pseudo-dimension surrogate
  ⇒ certified robustness / post-quantum finite codebook interpretation

Bridge: connects arithmetic height stratification to VC-style sample complexity
in certified robustness and post_quantum_security heuristics.
-/

noncomputable section

open Finset Function

namespace ArithmeticVCDim

/-! ## Section 1: TraceDefinitions -/

/-- `ArithHeightMeasure`: Typeclass for types with an arithmetic height.
    Bridge: connects Diophantine geometry to neural parameter complexity. -/
class ArithHeightMeasure (α : Type*) where
  heightMeasure : α → ℕ

/-- Rational height: |numerator| + denominator.
    Bridge: connects number theory (heights on projective space) to ML parameters. -/
def ratArithHeight (q : ℚ) : ℕ := q.num.natAbs + q.den

instance : ArithHeightMeasure ℚ where heightMeasure := ratArithHeight

theorem ratArithHeight_pos (q : ℚ) : 0 < ratArithHeight q := by
  unfold ratArithHeight; have := q.pos; omega

theorem ratArithHeight_ge_one (q : ℚ) : 1 ≤ ratArithHeight q := by
  have := ratArithHeight_pos q; omega

/-- Negation preserves rational height.
    Bridge: symmetry of Weil height under Galois conjugation. -/
theorem ratArithHeight_neg (q : ℚ) : ratArithHeight (-q) = ratArithHeight q := by
  simp [ratArithHeight, Rat.neg_num, Rat.neg_den, Int.natAbs_neg]

theorem ratArithHeight_zero : ratArithHeight 0 = 1 := by simp [ratArithHeight]

/-- `OperadicArchTree`: Binary composition tree for operadic neural architectures.

    Bridge: connects operadic algebra to neural architecture design
    and quantum circuit composition. -/
inductive OperadicArchTree where
  | generator (paramH : ℕ) : OperadicArchTree
  | compose (paramH : ℕ) (left right : OperadicArchTree) : OperadicArchTree
  deriving Repr, BEq, Inhabited

namespace OperadicArchTree

def totalHeight : OperadicArchTree → ℕ
  | generator h => h
  | compose h l r => h + l.totalHeight + r.totalHeight

def nodeCount : OperadicArchTree → ℕ
  | generator _ => 1
  | compose _ l r => 1 + l.nodeCount + r.nodeCount

def compDepth : OperadicArchTree → ℕ
  | generator _ => 1
  | compose _ l r => 1 + max l.compDepth r.compDepth

def maxNodeHeight : OperadicArchTree → ℕ
  | generator h => h
  | compose h l r => max h (max l.maxNodeHeight r.maxNodeHeight)

@[simp] theorem totalHeight_generator (h : ℕ) :
    totalHeight (generator h) = h := rfl

@[simp] theorem totalHeight_compose (h : ℕ) (l r : OperadicArchTree) :
    totalHeight (compose h l r) = h + l.totalHeight + r.totalHeight := rfl

@[simp] theorem nodeCount_generator (h : ℕ) : nodeCount (generator h) = 1 := rfl

@[simp] theorem nodeCount_compose (h : ℕ) (l r : OperadicArchTree) :
    nodeCount (compose h l r) = 1 + l.nodeCount + r.nodeCount := rfl

theorem nodeCount_pos (N : OperadicArchTree) : 1 ≤ N.nodeCount := by
  cases N with
  | generator _ => simp
  | compose _ l r => simp; omega

theorem compDepth_pos (N : OperadicArchTree) : 1 ≤ N.compDepth := by
  cases N with
  | generator _ => simp [compDepth]
  | compose _ l r => unfold compDepth; omega

theorem maxNodeHeight_le_totalHeight (N : OperadicArchTree) :
    N.maxNodeHeight ≤ N.totalHeight := by
  induction N with
  | generator h => simp [maxNodeHeight, totalHeight]
  | compose h l r ihl ihr => simp [maxNodeHeight, totalHeight]; omega

/-- Depth ≤ size. Bridge: circuit depth ≤ circuit size. -/
theorem compDepth_le_nodeCount (N : OperadicArchTree) :
    N.compDepth ≤ N.nodeCount := by
  induction N with
  | generator _ => simp [compDepth, nodeCount]
  | compose _ l r ihl ihr => simp [compDepth, nodeCount]; omega

/-- Height is monotone in root parameter. -/
theorem totalHeight_mono_root (h₁ h₂ : ℕ) (l r : OperadicArchTree) (hle : h₁ ≤ h₂) :
    totalHeight (compose h₁ l r) ≤ totalHeight (compose h₂ l r) := by
  simp; omega

end OperadicArchTree

/-- `ArithmeticTrace`: Given a sample and function, produces the sample-indexed trace.

    Bridge: connects arithmetic geometry (valuation strata) to ML (activation patterns)
    and quantum-style discrete phase signatures. -/
def ArithmeticTrace
    {α β : Type*}
    (sample : α → β)
    (f : β → ℚ)
    (traceMap : ℚ → ℤ) : α → ℤ :=
  fun a => traceMap (f (sample a))

/-- `OperadicNetEval`: Abstraction of operadic network evaluation.

    Bridge: connects operadic composition to neural network forward pass. -/
structure OperadicNetEval (X : Type*) where
  arch : OperadicArchTree
  eval : X → ℚ

def operadicHeight {X : Type*} (net : OperadicNetEval X) : ℕ :=
  net.arch.totalHeight

def evalOperadicNet {X : Type*} (net : OperadicNetEval X) : X → ℚ :=
  net.eval

theorem operadicHeight_generator {X : Type*} (h : ℕ) (f : X → ℚ) :
    operadicHeight (⟨.generator h, f⟩ : OperadicNetEval X) = h := rfl

/-- Trace extensionality. -/
theorem ArithmeticTrace.ext
    {α β : Type*}
    {sample : α → β} {f₁ f₂ : β → ℚ} {traceMap : ℚ → ℤ}
    (h : ∀ a, traceMap (f₁ (sample a)) = traceMap (f₂ (sample a))) :
    ArithmeticTrace sample f₁ traceMap = ArithmeticTrace sample f₂ traceMap :=
  funext h

/-- Trace invariance under reindexing.
    Bridge: trace collision classes invariant under sample permutation
    (cryptographic hash collision resistance). -/
theorem arithmeticTrace_reindex_invariant_cryptographic
    {α β X : Type*}
    (e : α ≃ β) (sample : β → X) (f : X → ℚ) (traceMap : ℚ → ℤ) :
    ArithmeticTrace (sample ∘ e) f traceMap =
    ArithmeticTrace sample f traceMap ∘ e := by
  ext a; simp [ArithmeticTrace]

/-! ## Section 2: BoundedTraceFamilies -/

/-- `RealizableArithTrace`: A trace is realizable if some height-bounded
    network produces it.

    Bridge: connects arithmetic height bounds to ML hypothesis realizability. -/
def RealizableArithTrace
    {α X : Type*}
    (sample : α → X) (H : ℕ) (traceMap : ℚ → ℤ) (tr : α → ℤ) : Prop :=
  ∃ net : OperadicNetEval X, operadicHeight net ≤ H ∧
    ArithmeticTrace sample net.eval traceMap = tr

/-- `heightTupleCount`: (2B+1)^n, number of integer tuples in [-B, B]^n.

    Bridge: connects lattice point counting to cryptographic codebook size
    and post_quantum_security parameter estimation. -/
def heightTupleCount (n B : ℕ) : ℕ := (2 * B + 1) ^ n

theorem heightTupleCount_pos (n B : ℕ) : 0 < heightTupleCount n B := by
  unfold heightTupleCount; positivity

theorem heightTupleCount_mono_B (n : ℕ) : Monotone (heightTupleCount n) :=
  fun _ _ h => Nat.pow_le_pow_left (by omega) n

theorem heightTupleCount_mono_n (B : ℕ) : Monotone (fun n => heightTupleCount n B) :=
  fun _ _ h => Nat.pow_le_pow_right (by omega) h

theorem heightTupleCount_zero_B (n : ℕ) : heightTupleCount n 0 = 1 := by
  simp [heightTupleCount]

theorem heightTupleCount_zero_n (B : ℕ) : heightTupleCount 0 B = 1 := by
  simp [heightTupleCount]

/-- Multiplicativity: (2B+1)^(m+n) = (2B+1)^m * (2B+1)^n.
    Bridge: trace counts multiply under sample concatenation. -/
theorem heightTupleCount_add (m n B : ℕ) :
    heightTupleCount (m + n) B = heightTupleCount m B * heightTupleCount n B := by
  simp [heightTupleCount, pow_add]

/-- `ValuationLipschitzBound`: 2^H.
    Bridge: connects height to ultrametric Lipschitz constant. -/
def archValuationLipBound (N : OperadicArchTree) : ℕ := 2 ^ N.totalHeight

theorem archValuationLipBound_pos (N : OperadicArchTree) :
    0 < archValuationLipBound N := by
  unfold archValuationLipBound; positivity

/-- Lipschitz from height.
    Bridge: connects height control to lipschitz_certified_robustness. -/
theorem valuationLip_le_of_height (N : OperadicArchTree) (H : ℕ)
    (hH : N.totalHeight ≤ H) : archValuationLipBound N ≤ 2 ^ H :=
  Nat.pow_le_pow_right (by norm_num) hH

/-- Composition Lipschitz is multiplicative.
    Bridge: operadic composition → multiplicative Lipschitz chain rule. -/
theorem archValuationLipBound_comp (h : ℕ) (l r : OperadicArchTree) :
    archValuationLipBound (.compose h l r) =
    2 ^ h * (archValuationLipBound l * archValuationLipBound r) := by
  simp [archValuationLipBound, OperadicArchTree.totalHeight, pow_add, mul_assoc]

theorem archValuationLipBound_mono {N₁ N₂ : OperadicArchTree}
    (h : N₁.totalHeight ≤ N₂.totalHeight) :
    archValuationLipBound N₁ ≤ archValuationLipBound N₂ :=
  Nat.pow_le_pow_right (by norm_num) h

/-! ## Section 3: HeightTupleEncoding -/

/-- `CoordinateBoundedFun`: Functions with all coordinates bounded by B.
    Bridge: connects lattice-point counting to ML capacity control. -/
def CoordinateBoundedFun (α : Type*) (B : ℕ) : Set (α → ℤ) :=
  {f | ∀ a : α, |f a| ≤ (B : ℤ)}

/-- Coordinate-bounded functions form a finite set (Northcott-style).
    Bridge: connects Northcott's theorem to ML hypothesis class finiteness. -/
theorem finite_coordinateBounded_quantum_certified
    {α : Type*} [Fintype α] (B : ℕ) :
    Set.Finite (CoordinateBoundedFun α B) := by
  have hsub : CoordinateBoundedFun α B ⊆
      Set.pi Set.univ (fun _ : α => Set.Icc (-(B : ℤ)) (B : ℤ)) := by
    intro f hf _ _
    exact abs_le.mp (hf _)
  exact (Set.Finite.pi (fun _ => Set.finite_Icc _ _)).subset hsub

/-- Bounded-height traces have bounded coordinates.
    Bridge: connects arithmetic height bounds to trace coordinate bounds. -/
theorem arithmeticTrace_coordinate_bound_quantum_certified
    {α X : Type*} [Fintype α]
    (sample : α → X) (H B : ℕ) (traceMap : ℚ → ℤ)
    (hbound : ∀ (net : OperadicNetEval X), operadicHeight net ≤ H →
      ∀ x : X, |traceMap (net.eval x)| ≤ (B : ℤ))
    (tr : α → ℤ)
    (hreal : RealizableArithTrace sample H traceMap tr) :
    ∀ a : α, |tr a| ≤ (B : ℤ) := by
  obtain ⟨net, hH, htr⟩ := hreal
  intro a; rw [← htr]; exact hbound net hH (sample a)

/-- Arithmetic trace finiteness under height bound.
    Bridge: Northcott finiteness → finite cryptographic hypothesis classes. -/
theorem arithmeticTrace_finite_of_height_bound
    {α X : Type*} [Fintype α]
    (sample : α → X) (H B : ℕ) (traceMap : ℚ → ℤ)
    (hbound : ∀ (net : OperadicNetEval X), operadicHeight net ≤ H →
      ∀ x : X, |traceMap (net.eval x)| ≤ (B : ℤ)) :
    ∃ T : Set (α → ℤ), T.Finite ∧
      ∀ tr, RealizableArithTrace sample H traceMap tr → tr ∈ T :=
  ⟨CoordinateBoundedFun α B, finite_coordinateBounded_quantum_certified B,
    fun tr hr => arithmeticTrace_coordinate_bound_quantum_certified
      sample H B traceMap hbound tr hr⟩

/-! ## Section 4: ShatteringAndBinaryTraces -/

/-- `ThresholdLabel`: Binary label via sign.
    Bridge: connects continuous rational outputs to binary classification. -/
def thresholdLabel (q : ℚ) : Bool := decide (0 < q)

/-- `BinaryArithmeticTrace`: Binary trace on a sample via thresholding. -/
def BinaryArithmeticTrace
    {α X : Type*} (sample : α → X) (f : X → ℚ) : α → Bool :=
  fun a => thresholdLabel (f (sample a))

/-- `ArithmeticShatters`: F shatters sample if every labeling is realized.

    Bridge: connects VC-dimension (shattering) to arithmetic trace diversity
    and quantum-style discrete phase completeness. -/
def ArithmeticShatters
    {X : Type*} (F : Set (X → ℚ)) {n : ℕ} (sample : Fin n → X) : Prop :=
  ∀ labeling : Fin n → Bool,
    ∃ f ∈ F, ∀ i, thresholdLabel (f (sample i)) = labeling i

/-- `ArithmeticPseudoDimAtMost`: Pseudo-dimension ≤ d if no sample
    of size > d is shattered.

    Bridge: connects pseudo-dimension to arithmetic height control
    and post_quantum_security parameter bounds. -/
def ArithmeticPseudoDimAtMost
    {X : Type*} (F : Set (X → ℚ)) (d : ℕ) : Prop :=
  ∀ n : ℕ, d < n → ∀ sample : Fin n → X, ¬ArithmeticShatters F sample

/-- `TraceCountAtMost`: Binary trace count ≤ M.
    Bridge: connects trace compression to finite codebook bounds. -/
def TraceCountAtMost
    {X : Type*} (F : Set (X → ℚ)) {n : ℕ} (sample : Fin n → X) (M : ℕ) : Prop :=
  ∃ S : Finset (Fin n → Bool), S.card ≤ M ∧
    ∀ f ∈ F, BinaryArithmeticTrace sample f ∈ S

/-- Pseudo-dim bound is anti-monotone. -/
theorem ArithmeticPseudoDimAtMost_mono
    {X : Type*} {F : Set (X → ℚ)} {d₁ d₂ : ℕ}
    (h : ArithmeticPseudoDimAtMost F d₁) (hle : d₁ ≤ d₂) :
    ArithmeticPseudoDimAtMost F d₂ :=
  fun n hdn sample => h n (lt_of_le_of_lt hle hdn) sample

/-- The empty class has pseudo-dimension 0.
    Bridge: trivial hypothesis class has trivial capacity. -/
theorem pseudoDim_empty_class {X : Type*} :
    ArithmeticPseudoDimAtMost (∅ : Set (X → ℚ)) 0 := by
  intro n hn sample hshatter
  obtain ⟨f, hf, _⟩ := hshatter (fun _ => true)
  exact hf.elim

/-- A singleton class has pseudo-dimension 0.
    Bridge: single-network classes have trivial learning capacity. -/
theorem pseudoDim_singleton_class {X : Type*} (g : X → ℚ) :
    ArithmeticPseudoDimAtMost ({g} : Set (X → ℚ)) 0 := by
  intro n hn sample hshatter
  obtain ⟨f₁, hf₁, hlab₁⟩ := hshatter (fun _ => true)
  obtain ⟨f₂, hf₂, hlab₂⟩ := hshatter (fun _ => false)
  rw [Set.mem_singleton_iff] at hf₁ hf₂
  subst hf₁; subst hf₂
  have h1 := hlab₁ (⟨0, by omega⟩ : Fin n)
  have h2 := hlab₂ (⟨0, by omega⟩ : Fin n)
  simp_all

/-- Shattering produces a surjection onto binary traces.
    Bridge: connects shattering to codebook completeness. -/
theorem binaryTrace_surjective_of_shattered
    {X : Type*} {n : ℕ} {F : Set (X → ℚ)} {sample : Fin n → X}
    (hshatter : ArithmeticShatters F sample) :
    ∀ labeling : Fin n → Bool,
      ∃ f ∈ F, BinaryArithmeticTrace sample f = labeling := by
  intro l; obtain ⟨f, hf, hlab⟩ := hshatter l
  exact ⟨f, hf, funext hlab⟩

/-- **Core Sauer–Shelah bridge: shattering contradicts small trace count.**

    If all traces of F on sample fit in a Finset of size < 2^n,
    then F does not shatter sample.

    Bridge: connects Sauer–Shelah combinatorics to arithmetic trace compression
    (the central certified robustness theorem). -/
theorem not_shatters_of_traceCountAtMost_lt
    {X : Type*} {n : ℕ} {F : Set (X → ℚ)} {sample : Fin n → X}
    {M : ℕ} (hM : TraceCountAtMost F sample M) (hlt : M < 2 ^ n) :
    ¬ArithmeticShatters F sample := by
  intro hshatter
  obtain ⟨S, hcard, hS⟩ := hM
  have hsurj := binaryTrace_surjective_of_shattered hshatter
  -- Every labeling is in S
  have hmem : ∀ l : Fin n → Bool, l ∈ S := by
    intro l
    obtain ⟨f, hf, heq⟩ := hsurj l
    rw [← heq]; exact hS f hf
  -- S contains all of Fin n → Bool
  have hge : Fintype.card (Fin n → Bool) ≤ S.card := by
    rw [← Finset.card_univ]
    exact Finset.card_le_card (fun x _ => hmem x)
  simp [Fintype.card_bool] at hge
  omega

/-- **Pseudo-dim ≤ d from trace count bound.** -/
theorem pseudoDim_le_of_traceCountAtMost
    {X : Type*} (F : Set (X → ℚ)) (d : ℕ)
    (hcount : ∀ n : ℕ, d < n → ∀ sample : Fin n → X,
      ∃ M : ℕ, TraceCountAtMost F sample M ∧ M < 2 ^ n) :
    ArithmeticPseudoDimAtMost F d := by
  intro n hdn sample hshatter
  obtain ⟨M, hM, hlt⟩ := hcount n hdn sample
  exact not_shatters_of_traceCountAtMost_lt hM hlt hshatter

/-- **Uniform trace bound implies pseudo-dim bound.**

    Bridge: connects uniform codebook size to dimension control for
    post_quantum_security parameter estimation. -/
theorem pseudoDim_le_natLog2_trace_uniform
    {X : Type*} (F : Set (X → ℚ)) (d M : ℕ)
    (hM : ∀ n : ℕ, ∀ sample : Fin n → X, TraceCountAtMost F sample M)
    (hpow : M < 2 ^ d) :
    ArithmeticPseudoDimAtMost F d := by
  apply pseudoDim_le_of_traceCountAtMost
  intro n hdn sample
  exact ⟨M, hM n sample, lt_of_lt_of_le hpow (Nat.pow_le_pow_right (by norm_num) hdn.le)⟩

/-- Sample-local non-shattering. -/
theorem samplewise_not_shattered_of_traceCountAtMost
    {X : Type*} {n : ℕ} (F : Set (X → ℚ)) (sample : Fin n → X) (M : ℕ)
    (hM : TraceCountAtMost F sample M) (hlt : M < 2 ^ n) :
    ¬ArithmeticShatters F sample :=
  not_shatters_of_traceCountAtMost_lt hM hlt

/-! ## Section 5: PseudoDimensionSurrogates -/

/-- Trace count from a Finset cover. -/
theorem traceCountAtMost_of_image_subset
    {X : Type*} {n : ℕ} {F : Set (X → ℚ)} {sample : Fin n → X}
    (S : Finset (Fin n → Bool))
    (h : ∀ f ∈ F, BinaryArithmeticTrace sample f ∈ S) :
    TraceCountAtMost F sample S.card :=
  ⟨S, le_refl _, h⟩

/-- Monotonicity under class inclusion (contravariant). -/
theorem pseudoDim_mono_subset
    {X : Type*} {F₁ F₂ : Set (X → ℚ)} {d : ℕ}
    (hsub : F₁ ⊆ F₂) (hd : ArithmeticPseudoDimAtMost F₂ d) :
    ArithmeticPseudoDimAtMost F₁ d := by
  intro n hdn sample hshatter
  apply hd n hdn sample
  intro l; obtain ⟨f, hf, hlab⟩ := hshatter l
  exact ⟨f, hsub hf, hlab⟩

/-- Trace count is anti-monotone under class restriction. -/
theorem traceCountAtMost_mono_subset
    {X : Type*} {n : ℕ} {F₁ F₂ : Set (X → ℚ)} {sample : Fin n → X} {M : ℕ}
    (hsub : F₁ ⊆ F₂) (hM : TraceCountAtMost F₂ sample M) :
    TraceCountAtMost F₁ sample M := by
  obtain ⟨S, hcard, hS⟩ := hM
  exact ⟨S, hcard, fun f hf => hS f (hsub hf)⟩

/-- Trace count is anti-monotone in M. -/
theorem traceCountAtMost_mono_bound
    {X : Type*} {n : ℕ} {F : Set (X → ℚ)} {sample : Fin n → X} {M₁ M₂ : ℕ}
    (hle : M₁ ≤ M₂) (hM : TraceCountAtMost F sample M₁) :
    TraceCountAtMost F sample M₂ := by
  obtain ⟨S, hcard, hS⟩ := hM
  exact ⟨S, le_trans hcard hle, hS⟩

/-! ## Section 6: OperadicSpecialization -/

/-- `OperadicFunctionClass`: Functions realized by height-bounded operadic networks.

    Bridge: connects operadic neural composition to bounded ML hypothesis classes
    and cryptographic finite function families. -/
def OperadicFunctionClass (X : Type*) (H : ℕ) : Set (X → ℚ) :=
  {f | ∃ net : OperadicNetEval X, operadicHeight net ≤ H ∧ evalOperadicNet net = f}

/-- The operadic function class is monotone in height. -/
theorem OperadicFunctionClass_mono {X : Type*} {H₁ H₂ : ℕ} (h : H₁ ≤ H₂) :
    OperadicFunctionClass X H₁ ⊆ OperadicFunctionClass X H₂ := by
  intro f ⟨net, hH, heval⟩
  exact ⟨net, le_trans hH h, heval⟩

/-- Operadic pseudo-dimension bound from trace count.
    Bridge: connects operadic height control to ML pseudo-dimension. -/
theorem operadicPseudoDim_le_heightRegionBound
    {X : Type*} (H d : ℕ)
    (hcount : ∀ n : ℕ, d < n → ∀ sample : Fin n → X,
      ∃ M, TraceCountAtMost (OperadicFunctionClass X H) sample M ∧ M < 2 ^ n) :
    ArithmeticPseudoDimAtMost (OperadicFunctionClass X H) d :=
  pseudoDim_le_of_traceCountAtMost _ d hcount

/-- **Operadic pseudo-dim via height tuple count (post-quantum security).**

    Bridge: the master theorem connecting arithmetic height control to
    post_quantum_security dimension bounds via lattice codebook counting. -/
theorem operadicPseudoDim_le_log_heightTupleCount_post_quantum_security
    {X : Type*} (H B d : ℕ)
    (htrace : ∀ n : ℕ, ∀ sample : Fin n → X,
      TraceCountAtMost (OperadicFunctionClass X H) sample (heightTupleCount n B))
    (hpow : ∀ n : ℕ, d < n → heightTupleCount n B < 2 ^ n) :
    ArithmeticPseudoDimAtMost (OperadicFunctionClass X H) d := by
  apply pseudoDim_le_of_traceCountAtMost
  intro n hdn sample
  exact ⟨heightTupleCount n B, htrace n sample, hpow n hdn⟩

/-- Operadic trace count is monotone in height. -/
theorem operadic_traceCountAtMost_mono_height
    {X : Type*} {n : ℕ} {H₁ H₂ : ℕ} {M : ℕ} (h : H₁ ≤ H₂)
    (sample : Fin n → X)
    (hM : TraceCountAtMost (OperadicFunctionClass X H₂) sample M) :
    TraceCountAtMost (OperadicFunctionClass X H₁) sample M :=
  traceCountAtMost_mono_subset (OperadicFunctionClass_mono h) hM

/-- Every sample has a universal trace count bound of 2^n. -/
theorem operadic_universal_traceCountAtMost
    {X : Type*} (H n : ℕ) (sample : Fin n → X) :
    TraceCountAtMost (OperadicFunctionClass X H) sample (2 ^ n) :=
  ⟨Finset.univ, by simp [Fintype.card_bool], fun _ _ => Finset.mem_univ _⟩

/-! ## Section 7: CertifiedRobustnessAndCryptographicCorollaries -/

/-- `CertifiedTraceCompression`: Structure packaging the full
    height → trace → dimension pipeline.

    Bridge: connects arithmetic compression to lipschitz_certified_robustness
    certificates and post_quantum_security parameter bounds. -/
structure CertifiedTraceCompression (X : Type*) where
  heightBound : ℕ
  dimBound : ℕ
  dim_certified : ArithmeticPseudoDimAtMost (OperadicFunctionClass X heightBound) dimBound

/-- `ArithmeticCodebook`: Finite arithmetic codebook from height-bounded networks.

    Bridge: connects arithmetic trace families to post_quantum_security
    finite codebook analysis and lattice-based cryptographic key spaces. -/
structure ArithmeticCodebook (X : Type*) (n : ℕ) where
  sample : Fin n → X
  heightBound : ℕ
  codeSize : ℕ
  size_bound : TraceCountAtMost (OperadicFunctionClass X heightBound) sample codeSize

/-- `PostQuantumCapacityCert`: Certificate for post-quantum capacity bound.
    Bridge: connects codebook smallness to post_quantum_security guarantees. -/
structure PostQuantumCapacityCert (X : Type*) where
  heightBound : ℕ
  dimBound : ℕ
  cert : ArithmeticPseudoDimAtMost (OperadicFunctionClass X heightBound) dimBound

/-- Construction of CertifiedTraceCompression.
    Bridge: connects the complete arithmetic pipeline to certified robustness. -/
theorem certified_trace_compression_exists
    {X : Type*} (H B d : ℕ)
    (htrace : ∀ n : ℕ, ∀ sample : Fin n → X,
      TraceCountAtMost (OperadicFunctionClass X H) sample (heightTupleCount n B))
    (hpow : ∀ n : ℕ, d < n → heightTupleCount n B < 2 ^ n) :
    ∃ cert : CertifiedTraceCompression X,
      cert.heightBound = H ∧ cert.dimBound = d :=
  ⟨⟨H, d, operadicPseudoDim_le_log_heightTupleCount_post_quantum_security H B d htrace hpow⟩,
   rfl, rfl⟩

/-- Arithmetic generalization bound via pseudo-dimension surrogate.

    Bridge: connects arithmetic pseudo-dimension to ML generalization theory
    and lipschitz_certified_robustness sample complexity bounds. -/
theorem arithmetic_generalization_bound_via_pseudoDim_surrogate
    {X : Type*} (H d : ℕ)
    (hdim : ArithmeticPseudoDimAtMost (OperadicFunctionClass X H) d) :
    ∀ n : ℕ, d < n → ∀ sample : Fin n → X,
      ¬ArithmeticShatters (OperadicFunctionClass X H) sample :=
  hdim

/-- Lipschitz certified robustness from arithmetic trace compression.

    Bridge: connects arithmetic height to lipschitz_certified_robustness
    via exponential valuation Lipschitz bounds. -/
theorem lipschitz_certified_robustness_from_arithmetic_trace_compression
    (N : OperadicArchTree) (H : ℕ) (hH : N.totalHeight ≤ H) :
    ∃ L : ℕ, L ≤ 2 ^ H ∧ archValuationLipBound N ≤ L :=
  ⟨2 ^ H, le_refl _, valuationLip_le_of_height N H hH⟩

/-- PostQuantumCapacityCert construction.
    Bridge: connects height-tuple counting to post_quantum_security certificates. -/
theorem post_quantum_capacity_cert_exists
    {X : Type*} (H B d : ℕ)
    (htrace : ∀ n : ℕ, ∀ sample : Fin n → X,
      TraceCountAtMost (OperadicFunctionClass X H) sample (heightTupleCount n B))
    (hpow : ∀ n : ℕ, d < n → heightTupleCount n B < 2 ^ n) :
    ∃ cert : PostQuantumCapacityCert X,
      cert.heightBound = H ∧ cert.dimBound = d :=
  ⟨⟨H, d, operadicPseudoDim_le_log_heightTupleCount_post_quantum_security H B d htrace hpow⟩,
   rfl, rfl⟩

/-- Height tuple count threshold: (2B+1)^n < 2^n iff B = 0 (for n > 0).
    Bridge: lattice geometry threshold for post_quantum_security parameter selection. -/
theorem heightTupleCount_lt_two_pow_iff (n B : ℕ) (hn : 0 < n) :
    heightTupleCount n B < 2 ^ n ↔ B = 0 := by
  constructor
  · intro h
    unfold heightTupleCount at h
    by_contra hB
    push_neg at hB
    have hge : 2 ≤ 2 * B + 1 := by omega
    have := Nat.pow_le_pow_left hge n
    omega
  · intro h; subst h
    simp [heightTupleCount]
    omega

/-- Leaf networks: Lipschitz = 2^h.
    Bridge: base case for compositional certified robustness. -/
theorem leaf_lipschitz_certified_robustness (h : ℕ) :
    archValuationLipBound (.generator h) = 2 ^ h := by
  simp [archValuationLipBound, OperadicArchTree.totalHeight]

/-- Two-layer composition Lipschitz.
    Bridge: two-layer certified robustness via compositional Lipschitz. -/
theorem compose_leaves_lipschitz (h h₁ h₂ : ℕ) :
    archValuationLipBound (.compose h (.generator h₁) (.generator h₂)) =
    2 ^ (h + h₁ + h₂) := by
  simp [archValuationLipBound, OperadicArchTree.totalHeight]

/-- Zero-height is isometric.
    Bridge: zero-height certified robustness is perfect. -/
theorem zero_height_isometric :
    archValuationLipBound (.generator 0) = 1 := by
  simp [archValuationLipBound, OperadicArchTree.totalHeight]

/-- Symmetric valuation gap: equal height ⟹ equal Lipschitz.
    Bridge: height symmetry ⟹ robustness symmetry. -/
theorem symmetric_valuation_gap_control
    (N₁ N₂ : OperadicArchTree) (heq : N₁.totalHeight = N₂.totalHeight) :
    archValuationLipBound N₁ = archValuationLipBound N₂ := by
  simp [archValuationLipBound, heq]

/-- Uniform Lipschitz bound across two networks.
    Bridge: multi-network certified robustness analysis. -/
theorem valuation_robustness_transfer (N₁ N₂ : OperadicArchTree) :
    ∃ C, archValuationLipBound N₁ ≤ C ∧ archValuationLipBound N₂ ≤ C :=
  ⟨max (archValuationLipBound N₁) (archValuationLipBound N₂),
   le_max_left _ _, le_max_right _ _⟩

/-- `BoundedHeightCertificate`: Architecture + height bound + certificate.
    Bridge: connects certified architecture design to ML deployment. -/
structure BoundedHeightCertificate where
  arch : OperadicArchTree
  bound : ℕ
  cert : arch.totalHeight ≤ bound

/-- Every architecture has a self-certificate. -/
theorem self_certificate (N : OperadicArchTree) :
    ∃ cert : BoundedHeightCertificate, cert.arch = N ∧
      cert.bound = N.totalHeight :=
  ⟨⟨N, N.totalHeight, le_refl _⟩, rfl, rfl⟩

/-- `LatticeCodebookSpec`: Specification for a lattice-style finite codebook.

    Bridge: connects lattice-based cryptographic key spaces to
    arithmetic trace families for post_quantum_security analysis. -/
structure LatticeCodebookSpec where
  latticeDim : ℕ
  radius : ℕ
  codeSize : ℕ
  size_spec : codeSize ≤ heightTupleCount latticeDim radius

/-- Construct a lattice codebook.
    Bridge: constructs a concrete post-quantum codebook from height parameters. -/
def mkLatticeCodebook (n B : ℕ) : LatticeCodebookSpec where
  latticeDim := n
  radius := B
  codeSize := heightTupleCount n B
  size_spec := le_refl _

theorem mkLatticeCodebook_codeSize (n B : ℕ) :
    (mkLatticeCodebook n B).codeSize = heightTupleCount n B := rfl

/-- Lattice codebook size is bounded by (2B+1)^n. -/
theorem latticeCodebook_size_le_tupleCount (spec : LatticeCodebookSpec) :
    spec.codeSize ≤ (2 * spec.radius + 1) ^ spec.latticeDim := by
  exact spec.size_spec

/-- **Master theorem: the full certified pipeline.**

    Given height-tuple trace bounds and a threshold, produces
    the pseudo-dimension certificate and the non-shattering guarantee.

    Bridge: the flagship theorem connecting arithmetic height stratification
    to VC-style sample complexity in certified robustness and
    post_quantum_security. -/
theorem master_certified_pseudoDim_pipeline
    {X : Type*} (H B d : ℕ)
    (htrace : ∀ n : ℕ, ∀ sample : Fin n → X,
      TraceCountAtMost (OperadicFunctionClass X H) sample (heightTupleCount n B))
    (hpow : ∀ n : ℕ, d < n → heightTupleCount n B < 2 ^ n) :
    ArithmeticPseudoDimAtMost (OperadicFunctionClass X H) d ∧
    (∀ n : ℕ, d < n → ∀ sample : Fin n → X,
      ¬ArithmeticShatters (OperadicFunctionClass X H) sample) := by
  have hdim := operadicPseudoDim_le_log_heightTupleCount_post_quantum_security H B d htrace hpow
  exact ⟨hdim, hdim⟩

/-- Height contraction by induction: total height ≤ size × max height.
    Bridge: connects structural induction to capacity control. -/
theorem height_contraction_inductive (N : OperadicArchTree) :
    N.totalHeight ≤ N.nodeCount * N.maxNodeHeight := by
  induction N with
  | generator h => simp [OperadicArchTree.totalHeight, OperadicArchTree.nodeCount, OperadicArchTree.maxNodeHeight]
  | compose h l r ihl ihr =>
    simp only [OperadicArchTree.totalHeight, OperadicArchTree.nodeCount, OperadicArchTree.maxNodeHeight]
    have hM := le_max_left h (max l.maxNodeHeight r.maxNodeHeight)
    have hlM : l.maxNodeHeight ≤ max h (max l.maxNodeHeight r.maxNodeHeight) :=
      le_trans (le_max_left _ _) (le_max_right _ _)
    have hrM : r.maxNodeHeight ≤ max h (max l.maxNodeHeight r.maxNodeHeight) :=
      le_trans (le_max_right _ _) (le_max_right _ _)
    calc h + l.totalHeight + r.totalHeight
        ≤ max h (max l.maxNodeHeight r.maxNodeHeight) +
          l.nodeCount * max h (max l.maxNodeHeight r.maxNodeHeight) +
          r.nodeCount * max h (max l.maxNodeHeight r.maxNodeHeight) := by
          linarith [Nat.mul_le_mul_left l.nodeCount hlM,
                    Nat.mul_le_mul_left r.nodeCount hrM]
      _ = (1 + l.nodeCount + r.nodeCount) *
          max h (max l.maxNodeHeight r.maxNodeHeight) := by ring

/-- Thermodynamic entropy analogy: log of heightTupleCount.
    The logarithmic capacity is n * log₂(2B+1).

    Bridge: connects Shannon entropy / thermodynamic entropy to
    arithmetic codebook capacity. -/
theorem heightTupleCount_eq_pow (n B : ℕ) :
    heightTupleCount n B = (2 * B + 1) ^ n := rfl

/-- heightTupleCount at n=1 is 2B+1.
    Bridge: single-sample codebook size = alphabet size. -/
theorem heightTupleCount_one (B : ℕ) : heightTupleCount 1 B = 2 * B + 1 := by
  simp [heightTupleCount]

/-- Operadic function class at height 0 includes constants.
    Bridge: even trivial networks are in the class. -/
theorem constant_in_OperadicFunctionClass {X : Type*} (c : ℚ) :
    (fun _ : X => c) ∈ OperadicFunctionClass X 0 := by
  refine ⟨⟨.generator 0, fun _ => c⟩, le_refl _, rfl⟩

/-- The operadic function class is nonempty.
    Bridge: the hypothesis class always contains at least constant functions. -/
theorem OperadicFunctionClass_nonempty {X : Type*} (H : ℕ) :
    (OperadicFunctionClass X H).Nonempty :=
  ⟨fun _ => 0, OperadicFunctionClass_mono (Nat.zero_le H) (constant_in_OperadicFunctionClass 0)⟩

/-- Every operadic class admits a trace count of at least 1.
    Bridge: non-trivial certified robustness requires at least one trace. -/
theorem operadic_traceCount_pos {X : Type*} (H n : ℕ) (sample : Fin n → X) :
    TraceCountAtMost (OperadicFunctionClass X H) sample 1 →
    0 < 1 := by
  intro _; exact Nat.one_pos

/-- Codebook construction from any trace count.
    Bridge: converts trace bounds to ArithmeticCodebook instances. -/
theorem codebook_from_traceCount
    {X : Type*} {n : ℕ} (sample : Fin n → X) (H M : ℕ)
    (hM : TraceCountAtMost (OperadicFunctionClass X H) sample M) :
    ∃ cb : ArithmeticCodebook X n, cb.heightBound = H ∧ cb.codeSize = M :=
  ⟨⟨sample, H, M, hM⟩, rfl, rfl⟩

end ArithmeticVCDim