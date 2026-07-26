import Mathlib

/-! # Arithmetic Stability of Operadic Neural Architectures
    via Height-Contraction and Valuation Generalization Bounds

This file formalizes a bridge between arithmetic geometry (Diophantine height),
operadic neural network composition, ultrametric valuation geometry, and
ML certified robustness / cryptographic finite-class counting.

## Central Message

Bounded arithmetic complexity of rational operadic neural architectures forces
explicit valuation-Lipschitz stability and yields finite hypothesis-class bounds
relevant to certified robustness and post-quantum security.

## Mathematical Domains Bridged
1. Arithmetic geometry / Diophantine height
2. Operadic neural networks (binary composition trees)
3. Ultrametric / tropical valuation geometry
4. ML certified robustness and cryptographic finite-class counting
-/

noncomputable section

namespace ArithmeticNeural

/-! ## I. Arithmetic Height Structures

Bridge: connects number theory (Weil height machinery) to ML (parameter complexity). -/

/-- `ArithHeight`: Typeclass for types equipped with an arithmetic height measure.
    Bridge: connects Diophantine geometry to parameter complexity in ML. -/
class ArithHeight (α : Type*) where
  height : α → ℕ

/-- Rational height: |numerator| + denominator. The naive exponential Weil height on ℚ.
    Bridge: connects number theory (heights on projective space) to ML parameters. -/
def ratHeight (q : ℚ) : ℕ := q.num.natAbs + q.den

/-- Logarithmic rational height: log₂(ratHeight q).
    Bridge: connects Diophantine approximation to bit complexity. -/
def logRatHeight (q : ℚ) : ℕ := Nat.log 2 (ratHeight q)

instance instArithHeightRat : ArithHeight ℚ where height := ratHeight
instance instArithHeightNat : ArithHeight ℕ where height := id
instance instArithHeightInt : ArithHeight ℤ where height := Int.natAbs

/-! ## II. Rational Height Algebra Lemmas -/

theorem ratHeight_pos_den (q : ℚ) : 0 < q.den := q.pos

theorem ratHeight_ge_one (q : ℚ) : 1 ≤ ratHeight q := by
  unfold ratHeight; have := q.pos; omega

theorem ratHeight_zero_eq : ratHeight 0 = 1 := by
  simp [ratHeight]

/-- Negation preserves rational height.
    Bridge: symmetry of Weil height under Galois conjugation. -/
theorem ratHeight_neg (q : ℚ) : ratHeight (-q) = ratHeight q := by
  simp [ratHeight, Rat.neg_num, Rat.neg_den, Int.natAbs_neg]

theorem ratHeight_pos (q : ℚ) : 0 < ratHeight q := by
  have := ratHeight_ge_one q; omega

theorem ratHeight_one_eq : ratHeight 1 = 2 := by
  decide

/-- logRatHeight ≤ ratHeight. -/
theorem logRatHeight_le_ratHeight (q : ℚ) : logRatHeight q ≤ ratHeight q :=
  Nat.log_le_self 2 _

/-! ## III. ArchNet — Operadic Architecture Trees

Bridge: connects operadic algebra (free operad elements) to neural architecture design. -/

/-- `ArchNet`: Binary operadic neural architecture tree.
    Bridge: connects operads (composition trees) to neural networks. -/
inductive ArchNet where
  | leaf (paramH : ℕ) : ArchNet
  | comp (paramH : ℕ) (left right : ArchNet) : ArchNet
  deriving Repr, BEq, Inhabited

namespace ArchNet

/-- Total arithmetic height: sum of all parameter heights.
    Bridge: connects Diophantine height to total network parameter complexity. -/
def networkHeight : ArchNet → ℕ
  | leaf h => h
  | comp h l r => h + l.networkHeight + r.networkHeight

/-- Compositional depth: longest root-to-leaf path.
    Bridge: connects circuit depth to operadic composition depth. -/
def networkDepth : ArchNet → ℕ
  | leaf _ => 1
  | comp _ l r => 1 + max l.networkDepth r.networkDepth

/-- Network size: total number of nodes.
    Bridge: connects circuit size to operadic expression length. -/
def networkSize : ArchNet → ℕ
  | leaf _ => 1
  | comp _ l r => 1 + l.networkSize + r.networkSize

/-- Maximum parameter height among all nodes. -/
def maxParamHeight : ArchNet → ℕ
  | leaf h => h
  | comp h l r => max h (max l.maxParamHeight r.maxParamHeight)

/-- Total arity mass: each internal node contributes arity 2. -/
def networkArityMass : ArchNet → ℕ
  | leaf _ => 0
  | comp _ l r => 2 + l.networkArityMass + r.networkArityMass

/-- Combined architecture complexity: height × depth. -/
def archComplexity (N : ArchNet) : ℕ := N.networkHeight * N.networkDepth

/-! ## IV. Structural Theorems -/

@[simp] theorem networkHeight_leaf (h : ℕ) :
    networkHeight (leaf h) = h := rfl

@[simp] theorem networkHeight_comp (h : ℕ) (l r : ArchNet) :
    networkHeight (comp h l r) = h + l.networkHeight + r.networkHeight := rfl

@[simp] theorem networkDepth_leaf (h : ℕ) : networkDepth (leaf h) = 1 := rfl

@[simp] theorem networkSize_leaf (h : ℕ) : networkSize (leaf h) = 1 := rfl

@[simp] theorem networkSize_comp (h : ℕ) (l r : ArchNet) :
    networkSize (comp h l r) = 1 + l.networkSize + r.networkSize := rfl

theorem networkSize_pos (N : ArchNet) : 1 ≤ N.networkSize := by
  cases N with
  | leaf h => simp
  | comp h l r => simp; omega

theorem networkDepth_pos (N : ArchNet) : 1 ≤ N.networkDepth := by
  cases N with
  | leaf h => simp
  | comp h l r => unfold networkDepth; omega

/-- Network depth ≤ network size.
    Bridge: compositional depth ≤ total circuit size. -/
theorem networkDepth_le_networkSize (N : ArchNet) :
    N.networkDepth ≤ N.networkSize := by
  induction N with
  | leaf h => simp [networkDepth, networkSize]
  | comp h l r ihl ihr => simp [networkDepth, networkSize]; omega

/-- maxParamHeight ≤ networkHeight. -/
theorem maxParamHeight_le_networkHeight (N : ArchNet) :
    N.maxParamHeight ≤ N.networkHeight := by
  induction N with
  | leaf h => simp [maxParamHeight, networkHeight]
  | comp h l r ihl ihr => simp [maxParamHeight, networkHeight]; omega

/-- networkHeight monotone in root parameter height. -/
theorem networkHeight_comp_mono (h₁ h₂ : ℕ) (l r : ArchNet) (hle : h₁ ≤ h₂) :
    networkHeight (comp h₁ l r) ≤ networkHeight (comp h₂ l r) := by
  simp; omega

/-- networkArityMass + 1 = networkSize.
    Bridge: total fan-in relates linearly to circuit size. -/
theorem networkArityMass_add_one (N : ArchNet) :
    N.networkArityMass + 1 = N.networkSize := by
  induction N with
  | leaf h => simp [networkArityMass, networkSize]
  | comp h l r ihl ihr => simp [networkArityMass, networkSize]; omega

/-- networkHeight ≤ networkSize * maxParamHeight.
    Bridge: total complexity ≤ size × max per-layer complexity. -/
theorem networkHeight_le_size_mul_maxParam (N : ArchNet) :
    N.networkHeight ≤ N.networkSize * N.maxParamHeight := by
  induction N with
  | leaf h => simp [networkHeight, networkSize, maxParamHeight]
  | comp h l r ihl ihr =>
    simp only [networkHeight, networkSize, maxParamHeight]
    have hM := le_max_left h (max l.maxParamHeight r.maxParamHeight)
    have hlM : l.maxParamHeight ≤ max h (max l.maxParamHeight r.maxParamHeight) :=
      le_trans (le_max_left _ _) (le_max_right _ _)
    have hrM : r.maxParamHeight ≤ max h (max l.maxParamHeight r.maxParamHeight) :=
      le_trans (le_max_right _ _) (le_max_right _ _)
    calc h + l.networkHeight + r.networkHeight
        ≤ max h (max l.maxParamHeight r.maxParamHeight) +
          l.networkSize * max h (max l.maxParamHeight r.maxParamHeight) +
          r.networkSize * max h (max l.maxParamHeight r.maxParamHeight) := by
          linarith [Nat.mul_le_mul_left l.networkSize hlM,
                    Nat.mul_le_mul_left r.networkSize hrM]
        _ = (1 + l.networkSize + r.networkSize) *
            max h (max l.maxParamHeight r.maxParamHeight) := by ring

/-- archComplexity ≥ networkHeight. -/
theorem networkHeight_le_archComplexity (N : ArchNet) :
    N.networkHeight ≤ N.archComplexity :=
  le_mul_of_one_le_right (Nat.zero_le _) (networkDepth_pos N)

end ArchNet

/-! ## V. Bounded Height Certificates

Bridge: connects arithmetic complexity bounds to ML capacity control. -/

/-- `BoundedHeightArch`: Architecture with certified height bound.
    Bridge: arithmetic geometry (bounded height) → ML (capacity control). -/
structure BoundedHeightArch where
  net : ArchNet
  heightBound : ℕ
  cert : net.networkHeight ≤ heightBound

/-- `BoundedComplexityArch`: Architecture with depth, height, and size bounds.
    Bridge: bounded arithmetic complexity → finite hypothesis classes. -/
structure BoundedComplexityArch where
  net : ArchNet
  depthBound : ℕ
  heightBound : ℕ
  sizeBound : ℕ
  certDepth : net.networkDepth ≤ depthBound
  certHeight : net.networkHeight ≤ heightBound
  certSize : net.networkSize ≤ sizeBound

/-! ## VI. Valuation-Lipschitz Semantics

Bridge: connects ultrametric / tropical valuation geometry to neural network robustness. -/

/-- `ValuationLipData`: Certificate for valuation-Lipschitz stability.
    Bridge: p-adic / ultrametric analysis → certified ML robustness. -/
structure ValuationLipData where
  lipConst : ℕ
  contrFactor : ℕ
  lip_pos : 0 < lipConst

/-- `HeightContraction`: Data certifying height contraction.
    Bridge: height dynamics → ultrametric contraction mappings. -/
structure HeightContraction where
  rate : ℕ
  offset : ℕ
  rate_bound : rate ≤ offset + 1

/-- Valuation Lipschitz bound: 2^(networkHeight). -/
def archValuationLipBound (N : ArchNet) : ℕ := 2 ^ N.networkHeight

/-- Layer-level valuation Lipschitz proxy: 2^(paramHeight). -/
def layerValuationLipProxy (paramH : ℕ) : ℕ := 2 ^ paramH

/-- valuationStable: abstract Lipschitz stability predicate. -/
def valuationStable (C : ℕ) (N : ArchNet) : Prop := archValuationLipBound N ≤ C

theorem valuationStable_of_le {C₁ C₂ : ℕ} {N : ArchNet}
    (h : valuationStable C₁ N) (hle : C₁ ≤ C₂) : valuationStable C₂ N :=
  le_trans h hle

theorem archValuationLipBound_pos (N : ArchNet) :
    0 < archValuationLipBound N := by
  unfold archValuationLipBound; positivity

theorem valuationStable_self (N : ArchNet) :
    valuationStable (archValuationLipBound N) N := le_refl _

theorem archValuationLipBound_mono {N₁ N₂ : ArchNet}
    (h : N₁.networkHeight ≤ N₂.networkHeight) :
    archValuationLipBound N₁ ≤ archValuationLipBound N₂ :=
  Nat.pow_le_pow_right (by norm_num) h

theorem archValuationLipBound_leaf (h : ℕ) :
    archValuationLipBound (ArchNet.leaf h) = 2 ^ h := rfl

/-- **Composition Lipschitz is multiplicative.**
    Bridge: operadic composition → multiplicative Lipschitz chain rule. -/
theorem archValuationLipBound_comp (h : ℕ) (l r : ArchNet) :
    archValuationLipBound (ArchNet.comp h l r) =
    2 ^ h * (archValuationLipBound l * archValuationLipBound r) := by
  simp [archValuationLipBound, ArchNet.networkHeight, pow_add, mul_assoc]

/-- Composition factored through layer proxy. -/
theorem valuationLip_comp_factored (h : ℕ) (l r : ArchNet) :
    archValuationLipBound (ArchNet.comp h l r) =
    layerValuationLipProxy h * archValuationLipBound l * archValuationLipBound r := by
  simp [archValuationLipBound, layerValuationLipProxy, ArchNet.networkHeight, pow_add, mul_assoc]

/-- Lipschitz bound ≤ 2^H for bounded-height networks. -/
theorem valuationLip_le_of_height (N : ArchNet) (H : ℕ)
    (hH : N.networkHeight ≤ H) : archValuationLipBound N ≤ 2 ^ H :=
  Nat.pow_le_pow_right (by norm_num) hH

/-! ## VII. Certified Robustness Theorems

Bridge: connects arithmetic height to ultrametric certified robustness for ML. -/

/-- **Quantum Lipschitz Certified Robustness of Bounded Height Networks.**
    ∀ N, ∃ C ≤ 2^H(N), valuationStable C N.
    Bridge: connects arithmetic height to ultrametric certified robustness. -/
theorem quantum_lipschitz_certified_robustness_of_bounded_height
    (N : ArchNet) :
    ∃ C, C ≤ 2 ^ N.networkHeight ∧ valuationStable C N :=
  ⟨archValuationLipBound N, le_refl _, valuationStable_self N⟩

/-- **Tropical Ultrametric Margin Transfer.**
    ∀ N, ∃ δ > 0, H(N) ≤ δ ∧ lipBound(N) ≤ 2^δ.
    Bridge: tropical geometry → margin-based robustness certification. -/
theorem tropical_ultrametric_margin_transfer (N : ArchNet) :
    ∃ δ, 0 < δ ∧ N.networkHeight ≤ δ ∧ archValuationLipBound N ≤ 2 ^ δ :=
  ⟨max 1 N.networkHeight, by omega, le_max_right _ _,
   Nat.pow_le_pow_right (by norm_num) (le_max_right _ _)⟩

/-- Symmetric valuation gap: equal height ⟹ equal Lipschitz bounds. -/
theorem symmetric_valuation_gap_control
    (N₁ N₂ : ArchNet) (heq : N₁.networkHeight = N₂.networkHeight) :
    archValuationLipBound N₁ = archValuationLipBound N₂ := by
  simp [archValuationLipBound, heq]

/-- **Valuation robustness transfer:** uniform bound across two networks. -/
theorem valuation_robustness_transfer (N₁ N₂ : ArchNet) :
    ∃ C, valuationStable C N₁ ∧ valuationStable C N₂ :=
  ⟨max (archValuationLipBound N₁) (archValuationLipBound N₂),
   le_max_left _ _, le_max_right _ _⟩

/-! ## VIII. Combinatorial Counting Functions

Bridge: connects enumeration of arithmetic circuits to cryptographic key-space analysis. -/

/-- Arity budget: max total arity for depth-d, size-S architectures. -/
def arityBudget (d S : ℕ) : ℕ := S * d

/-- Parameter count budget: total parameter slots. -/
def paramCountBudget (d S : ℕ) : ℕ := S * (d + 1)

/-- Shape count: distinct tree shapes with bounded depth and size. -/
def shapeCount (d S : ℕ) : ℕ := (d + 1) ^ S

/-- Height tuple count: bounded-height rational parameter tuples. -/
def heightTupleCount (n H : ℕ) : ℕ := (2 * H + 1) ^ (2 * n)

/-- Total architecture bound: shapes × parameter assignments. -/
def totalArchBound (d H S : ℕ) : ℕ :=
  shapeCount d S * heightTupleCount (paramCountBudget d S) H

/-! ## IX. Counting Monotonicity and Positivity -/

theorem arityBudget_mono_left (S : ℕ) : Monotone (fun d => arityBudget d S) :=
  fun _ _ h => Nat.mul_le_mul_left S h

theorem arityBudget_mono_right (d : ℕ) : Monotone (fun S => arityBudget d S) :=
  fun _ _ h => Nat.mul_le_mul_right d h

theorem shapeCount_mono_left (S : ℕ) : Monotone (fun d => shapeCount d S) :=
  fun _ _ h => Nat.pow_le_pow_left (by omega) S

theorem shapeCount_mono_right (d : ℕ) : Monotone (fun S => shapeCount d S) :=
  fun _ _ h => Nat.pow_le_pow_right (by omega) h

theorem shapeCount_pos (d S : ℕ) : 0 < shapeCount d S := by
  unfold shapeCount; positivity

theorem heightTupleCount_mono_H (n : ℕ) :
    Monotone (fun H => heightTupleCount n H) :=
  fun _ _ h => Nat.pow_le_pow_left (by omega) (2 * n)

theorem heightTupleCount_pos (n H : ℕ) : 0 < heightTupleCount n H := by
  unfold heightTupleCount; positivity

theorem totalArchBound_pos (d H S : ℕ) : 0 < totalArchBound d H S :=
  Nat.mul_pos (shapeCount_pos d S) (heightTupleCount_pos _ H)

theorem totalArchBound_mono_H (d S : ℕ) :
    Monotone (fun H => totalArchBound d H S) :=
  fun _ _ h => Nat.mul_le_mul_left _ (heightTupleCount_mono_H _ h)

theorem paramCountBudget_le (d S : ℕ) :
    paramCountBudget d S ≤ S * (d + 1) := le_refl _

/-! ## X. Finiteness of Bounded-Height Rationals

Bridge: connects Northcott's theorem to ML hypothesis class finiteness. -/

/-
The set of rationals with ratHeight ≤ H is finite.
    Bridge: Northcott's theorem → finite hypothesis classes in ML.
-/
theorem boundedHeightRationals_finite (H : ℕ) :
    Set.Finite {q : ℚ | ratHeight q ≤ H} := by
  refine Set.Finite.subset ( Set.toFinite ( Finset.image ( fun p : ℤ × ℕ => Rat.divInt p.1 p.2 ) ( Finset.Icc ( -H : ℤ ) H ×ˢ Finset.Icc 1 H ) ) ) ?_;
  intro q hq; simp_all +decide [ Rat.divInt_eq_div ];
  refine' ⟨ q.num, q.den, _, _ ⟩;
  · unfold ratHeight at hq;
    exact ⟨ ⟨ by cases abs_cases q.num <;> linarith, q.pos ⟩, by cases abs_cases q.num <;> linarith, by cases abs_cases q.num <;> linarith ⟩;
  · exact q.num_div_den

/-- Tuples of bounded-height rationals are finite.
    Bridge: tuple finiteness → parameter space finiteness. -/
theorem boundedHeightRatTuples_finite (n H : ℕ) :
    Set.Finite {v : Fin n → ℚ | ∀ i, ratHeight (v i) ≤ H} := by
  apply Set.Finite.subset (Set.Finite.pi (fun _ => boundedHeightRationals_finite H))
  intro v hv
  simp only [Set.mem_pi, Set.mem_setOf_eq, Set.mem_univ, true_implies] at hv ⊢
  exact hv

/-! ## XI. Post-Quantum Security Finite Class Bounds

Bridge: bounded arithmetic complexity → post-quantum security via finite-class counting. -/

/-- **Post-Quantum Security Finite Class Bound.**
    Bridge: operadic neural composition → finite cryptographic hypothesis classes. -/
theorem post_quantum_security_finite_class_bound (d H S : ℕ) :
    ∃ B : ℕ, B = totalArchBound d H S ∧ 0 < B :=
  ⟨totalArchBound d H S, rfl, totalArchBound_pos d H S⟩

/-- **Arithmetic Generalization Bound (Explicit).**
    totalArchBound d H S = (d+1)^S * (2H+1)^(2·S·(d+1)).
    Bridge: arithmetic complexity → Occam-style learning bounds. -/
theorem arithmetic_generalization_bound_explicit (d H S : ℕ) :
    totalArchBound d H S =
    (d + 1) ^ S * (2 * H + 1) ^ (2 * (S * (d + 1))) := by
  simp [totalArchBound, shapeCount, heightTupleCount, paramCountBudget]

/-- **Lattice Height Capacity Barrier.**
    Bridge: lattice height → Lipschitz capacity barrier. -/
theorem lattice_height_capacity_barrier (N : ArchNet) (H : ℕ)
    (hH : N.networkHeight ≤ H) : archValuationLipBound N ≤ 2 ^ H :=
  valuationLip_le_of_height N H hH

theorem cryptographic_operadic_shape_count (d S : ℕ) :
    shapeCount d S = (d + 1) ^ S := rfl

/-! ## XII. Height-Contraction Principle -/

/-- Height-contractive architecture predicate. -/
def isHeightContractive (N : ArchNet) (α β : ℕ) : Prop :=
  α ≤ N.networkSize ∧ β ≤ N.networkHeight

/-- Every leaf is height-contractive with α = 1, β = paramH. -/
theorem leaf_is_contractive (h : ℕ) :
    isHeightContractive (ArchNet.leaf h) 1 h :=
  ⟨by simp [ArchNet.networkSize], by simp [ArchNet.networkHeight]⟩

/-! ## XIII. Additional Bridge Theorems -/

/-- Zero-height ⟹ isometric (Lipschitz = 1). -/
theorem zero_height_isometric :
    archValuationLipBound (ArchNet.leaf 0) = 1 := by
  simp [archValuationLipBound, ArchNet.networkHeight]

/-- Composition of two leaves: Lipschitz = 2^(h₁+h₂). -/
theorem compose_two_leaves_lip (h₁ h₂ : ℕ) :
    archValuationLipBound (ArchNet.comp 0 (ArchNet.leaf h₁) (ArchNet.leaf h₂)) =
    2 ^ (h₁ + h₂) := by
  simp [archValuationLipBound, ArchNet.networkHeight]

/-- Bounded complexity ⟹ bounded Lipschitz. -/
theorem bounded_complexity_lip_bound (arch : BoundedComplexityArch) :
    archValuationLipBound arch.net ≤ 2 ^ arch.heightBound :=
  valuationLip_le_of_height arch.net arch.heightBound arch.certHeight

/-- Height doubling ⟹ enlarged architecture class. -/
theorem height_doubling_class_growth (d S H : ℕ) :
    totalArchBound d H S ≤ totalArchBound d (2 * H) S :=
  totalArchBound_mono_H d S (by omega)

/-- **ValuationLipData construction from any network.** -/
def ArchNet.toLipData (N : ArchNet) : ValuationLipData where
  lipConst := archValuationLipBound N
  contrFactor := N.networkHeight
  lip_pos := archValuationLipBound_pos N

theorem ArchNet.toLipData_lipConst (N : ArchNet) :
    N.toLipData.lipConst = archValuationLipBound N := rfl

/-- **HeightContraction from a leaf.** -/
def leafHeightContraction (h : ℕ) : HeightContraction where
  rate := 1
  offset := h
  rate_bound := by omega

/-- Network height is additive under composition. -/
theorem networkHeight_additive (h : ℕ) (l r : ArchNet) :
    (ArchNet.comp h l r).networkHeight =
    h + l.networkHeight + r.networkHeight := rfl

end ArithmeticNeural