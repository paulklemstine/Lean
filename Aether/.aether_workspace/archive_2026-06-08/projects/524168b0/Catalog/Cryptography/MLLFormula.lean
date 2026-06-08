import Mathlib

/-!
# Multiplicative Linear Logic Formulas for Lattice Cryptography

This module defines the formula language of multiplicative linear logic (MLL) indexed
by lattice dimension, and develops the structural theory needed for the
proof-theoretic lattice cryptography framework.

## Key Definitions

* `MLLFormula n` — MLL formulas with atoms indexed by `Fin n` (lattice dimension)
* `MLLFormula.depth` — formula tree depth, the proof-theoretic analogue of lattice norm
* `MLLFormula.neg` — linear negation (De Morgan dual), corresponding to `v ↦ −v`
* `CutPair n` — a pair of dual formulas linked by a cut
* `buildTensorChain` — constructs tensor chains encoding integer magnitudes

## Main Results

* `MLLFormula.neg_neg` — linear negation is an involution
* `MLLFormula.depth_neg` — negation preserves depth (norm symmetry)
* `MLLFormula.depth_lt_size` — depth < size (height < weight)
* `MLLFormula.tensorCount_neg` — negation swaps tensor/par counts (De Morgan)
* `MLLFormula.neg_injective` — negation is injective
* `buildTensorChain_depth` — tensor chains have prescribed depth
* `encodeCoefficientAsCut_complexity` — cut complexity = 2 · |coefficient|

## References

Bridge: connects Girard's linear logic (1987) to lattice geometry via the
correspondence between formula depth and lattice vector norms.
-/

namespace ProofTheoreticCrypto

-- ═══════════════════════════════════════════════════════════════════
-- §1. Multiplicative Linear Logic Formulas
-- ═══════════════════════════════════════════════════════════════════

/-- Multiplicative linear logic formulas indexed by lattice dimension `n`.
    Each atom corresponds to a lattice basis vector; `tensor` (⊗) and `par` (⅋)
    encode positive and negative contributions to the lattice vector.
    Bridge: connects linear logic to lattice geometry via atom indexing. -/
inductive MLLFormula (n : ℕ) where
  | atom (i : Fin n)
  | dual (i : Fin n)
  | tensor (A B : MLLFormula n)
  | par (A B : MLLFormula n)
  | one
  | bot
  deriving DecidableEq

namespace MLLFormula

variable {n : ℕ}

-- ── Structural measures ──────────────────────────────────────────

/-- Depth of a formula tree — measures structural complexity.
    Bridge: this is the proof-theoretic analogue of a lattice vector's norm component. -/
def depth : MLLFormula n → ℕ
  | atom _ | dual _ | one | bot => 0
  | tensor A B | par A B => max A.depth B.depth + 1

/-- Size of a formula — total number of nodes in the formula tree.
    Bridge: represents the encoding cost (space complexity) of a proof-net node. -/
def size : MLLFormula n → ℕ
  | atom _ | dual _ | one | bot => 1
  | tensor A B | par A B => A.size + B.size + 1

/-- Linear negation (De Morgan dual) in MLL.
    Bridge: corresponds to lattice point negation v ↦ −v. The involutive
    nature of negation reflects the symmetric norm property ‖v‖ = ‖−v‖. -/
def neg : MLLFormula n → MLLFormula n
  | atom i => dual i
  | dual i => atom i
  | tensor A B => par A.neg B.neg
  | par A B => tensor A.neg B.neg
  | one => bot
  | bot => one

/-- Count tensor connectives — measures multiplicative "positive" complexity. -/
def tensorCount : MLLFormula n → ℕ
  | tensor A B => A.tensorCount + B.tensorCount + 1
  | par A B => A.tensorCount + B.tensorCount
  | _ => 0

/-- Count par connectives — measures multiplicative "negative" complexity. -/
def parCount : MLLFormula n → ℕ
  | par A B => A.parCount + B.parCount + 1
  | tensor A B => A.parCount + B.parCount
  | _ => 0

/-- Total connective count — upper bound on proof-net link count. -/
def connectiveCount : MLLFormula n → ℕ
  | atom _ | dual _ | one | bot => 0
  | tensor A B | par A B => A.connectiveCount + B.connectiveCount + 1

/-- Whether a formula is atomic (leaf in the formula tree). -/
def isAtomic : MLLFormula n → Bool
  | atom _ | dual _ | one | bot => true
  | tensor _ _ | par _ _ => false

-- ── Core Theorems ────────────────────────────────────────────────

/-- Linear negation is an involution: ¬(¬A) = A.
    Bridge: connects to lattice duality (−(−v) = v) and the fact that
    cryptographic encoding/decoding are inverse operations. -/
@[simp]
theorem neg_neg (A : MLLFormula n) : A.neg.neg = A := by
  induction A <;> simp [neg, *]

/-- Negation preserves formula depth: proof-theoretic complexity is dual-invariant.
    Bridge: ‖v‖ = ‖−v‖ in any symmetric norm — the encoding of a lattice vector
    and its negation have the same proof-theoretic cost. -/
@[simp]
theorem depth_neg (A : MLLFormula n) : A.neg.depth = A.depth := by
  induction A <;> simp [neg, depth, *]

/-- Negation preserves formula size: the dual proof has identical representation cost.
    Bridge: encoding v and −v use the same number of proof-net nodes. -/
@[simp]
theorem size_neg (A : MLLFormula n) : A.neg.size = A.size := by
  induction A <;> simp [neg, size, *]

/-- Every formula has positive size — no empty formulas exist.
    Bridge: every lattice basis vector requires at least one proof-net node. -/
theorem size_pos (A : MLLFormula n) : 0 < A.size := by
  cases A <;> simp [size]

/-- Depth is strictly less than size: tree height < tree weight.
    Bridge: the structural depth of a proof (which controls cut-elimination time)
    is bounded by its representation size (which controls encoding space). -/
theorem depth_lt_size (A : MLLFormula n) : A.depth < A.size := by
  induction A with
  | atom _ | dual _ | one | bot => simp [depth, size]
  | tensor A B ihA ihB =>
    simp only [depth, size]
    have : A.size ≥ 1 := A.size_pos
    have : B.size ≥ 1 := B.size_pos
    omega
  | par A B ihA ihB =>
    simp only [depth, size]
    have : A.size ≥ 1 := A.size_pos
    have : B.size ≥ 1 := B.size_pos
    omega

/-- Negation swaps tensor and par counts: De Morgan duality exchanges ⊗ and ⅋.
    Bridge: the positive/negative decomposition of a lattice vector is
    exchanged by negation, but the total complexity is preserved. -/
theorem tensorCount_neg (A : MLLFormula n) : A.neg.tensorCount = A.parCount := by
  induction A <;> simp [neg, tensorCount, parCount, *]

/-- The dual of De Morgan: negation maps par counts to tensor counts. -/
theorem parCount_neg (A : MLLFormula n) : A.neg.parCount = A.tensorCount := by
  induction A <;> simp [neg, tensorCount, parCount, *]

/-- Negation preserves connective count: total complexity is dual-invariant. -/
@[simp]
theorem connectiveCount_neg (A : MLLFormula n) :
    A.neg.connectiveCount = A.connectiveCount := by
  induction A <;> simp [neg, connectiveCount, *]

/-- Negation is injective: distinct formulas have distinct duals.
    Bridge: the encoding preserves distinctness — different lattice vectors
    yield different proof-net structures. -/
theorem neg_injective : Function.Injective (neg : MLLFormula n → MLLFormula n) := by
  intro A B h
  have := congr_arg neg h
  simp at this
  exact this

/-- Negation is surjective: every formula is the dual of some formula. -/
theorem neg_surjective : Function.Surjective (neg : MLLFormula n → MLLFormula n) := by
  intro A
  exact ⟨A.neg, A.neg_neg⟩

/-- Negation is a bijection: it's an involutive automorphism of formulas.
    Bridge: duality is a perfect symmetry of the proof-net encoding space. -/
theorem neg_bijective : Function.Bijective (neg : MLLFormula n → MLLFormula n) :=
  ⟨neg_injective, neg_surjective⟩

/-- Atomic formulas have depth zero. -/
theorem depth_eq_zero_of_isAtomic (A : MLLFormula n) (h : A.isAtomic = true) :
    A.depth = 0 := by
  cases A <;> simp [depth, isAtomic] at *

/-- Tensor formulas have positive depth. -/
theorem depth_tensor_pos (A B : MLLFormula n) : 0 < (tensor A B).depth := by
  simp [depth]

/-- Par formulas have positive depth. -/
theorem depth_par_pos (A B : MLLFormula n) : 0 < (par A B).depth := by
  simp [depth]

/-- Depth of a tensor is at least 1 + depth of each component.
    Bridge: composing two proof structures strictly increases complexity. -/
theorem depth_tensor_ge_left (A B : MLLFormula n) :
    A.depth + 1 ≤ (tensor A B).depth := by
  simp [depth]

theorem depth_tensor_ge_right (A B : MLLFormula n) :
    B.depth + 1 ≤ (tensor A B).depth := by
  simp [depth]

/-- Connective count equals tensorCount + parCount.
    Bridge: total proof complexity decomposes into positive and negative parts. -/
theorem connectiveCount_eq_tensor_add_par (A : MLLFormula n) :
    A.connectiveCount = A.tensorCount + A.parCount := by
  induction A with
  | atom _ | dual _ | one | bot => simp [connectiveCount, tensorCount, parCount]
  | tensor A B ihA ihB =>
    simp [connectiveCount, tensorCount, parCount, ihA, ihB]; ring
  | par A B ihA ihB =>
    simp [connectiveCount, tensorCount, parCount, ihA, ihB]; ring

/-- Size equals 2 · connectiveCount + 1 for non-unit formulas.
    More precisely, size = 2c + 1 where c is the connective count. -/
theorem size_eq_two_connective_add_one (A : MLLFormula n) :
    A.size = 2 * A.connectiveCount + 1 := by
  induction A with
  | atom _ | dual _ | one | bot => simp [size, connectiveCount]
  | tensor A B ihA ihB =>
    simp [size, connectiveCount, ihA, ihB]; ring
  | par A B ihA ihB =>
    simp [size, connectiveCount, ihA, ihB]; ring

end MLLFormula

-- ═══════════════════════════════════════════════════════════════════
-- §2. Cut Pairs and Cut Complexity
-- ═══════════════════════════════════════════════════════════════════

/-- A cut pair: two formulas connected by a cut link in a proof net.
    In the proof-theoretic interpretation, a cut represents composition.
    In the lattice interpretation, a cut encodes a lattice vector component.
    Bridge: connects proof-net cuts to lattice vector entries. -/
structure CutPair (n : ℕ) where
  left : MLLFormula n
  right : MLLFormula n
  deriving DecidableEq

namespace CutPair

variable {n : ℕ}

/-- The complexity of a single cut pair: sum of formula depths.
    Bridge: this is the proof-theoretic analogue of |vᵢ| for a lattice component. -/
def complexity (c : CutPair n) : ℕ :=
  c.left.depth + c.right.depth

/-- A cut pair is well-typed if the right formula is the negation of the left.
    This is the fundamental typing constraint of MLL: cuts must connect duals. -/
def isWellTyped (c : CutPair n) : Prop :=
  c.right = c.left.neg

/-- Well-typed cut pairs have complexity exactly 2 · depth(left).
    Bridge: well-typing ensures the encoding faithfully represents norms. -/
theorem complexity_of_wellTyped (c : CutPair n) (h : c.isWellTyped) :
    c.complexity = 2 * c.left.depth := by
  simp [complexity, isWellTyped] at *
  rw [h, MLLFormula.depth_neg]; omega

/-- The dual cut pair (swapping left and right). -/
def swap (c : CutPair n) : CutPair n :=
  ⟨c.right, c.left⟩

/-- Swapping preserves complexity — cut complexity is symmetric. -/
theorem complexity_swap (c : CutPair n) : c.swap.complexity = c.complexity := by
  simp [swap, complexity]; omega

/-- Swapping is an involution. -/
@[simp]
theorem swap_swap (c : CutPair n) : c.swap.swap = c := by
  simp [swap]

end CutPair

-- ═══════════════════════════════════════════════════════════════════
-- §3. Tensor Chains and Vector Encoding
-- ═══════════════════════════════════════════════════════════════════

/-- Build a tensor chain of depth `k` from atom `i`.
    This constructs a left-leaning binary tree: tensor(tensor(...(atom i)..., atom i), atom i)
    encoding the magnitude of a lattice coefficient.
    Bridge: maps ℕ-magnitudes to proof-theoretic structures of corresponding depth. -/
def buildTensorChain {n : ℕ} (i : Fin n) : ℕ → MLLFormula n
  | 0 => .atom i
  | k + 1 => .tensor (buildTensorChain i k) (.atom i)

/-- Tensor chains have depth exactly k — the depth faithfully encodes the magnitude.
    Bridge: this is the key lemma ensuring the norm-cut correspondence is tight. -/
@[simp]
theorem buildTensorChain_depth {n : ℕ} (i : Fin n) (k : ℕ) :
    (buildTensorChain i k).depth = k := by
  induction k with
  | zero => simp [buildTensorChain, MLLFormula.depth]
  | succ k ih => simp [buildTensorChain, MLLFormula.depth, ih]

/-- Tensor chains have size 2k + 1 — linear space overhead for encoding. -/
@[simp]
theorem buildTensorChain_size {n : ℕ} (i : Fin n) (k : ℕ) :
    (buildTensorChain i k).size = 2 * k + 1 := by
  induction k with
  | zero => simp [buildTensorChain, MLLFormula.size]
  | succ k ih => simp [buildTensorChain, MLLFormula.size, ih]; ring

/-- Tensor chains have exactly k tensor connectives. -/
@[simp]
theorem buildTensorChain_tensorCount {n : ℕ} (i : Fin n) (k : ℕ) :
    (buildTensorChain i k).tensorCount = k := by
  induction k with
  | zero => simp [buildTensorChain, MLLFormula.tensorCount]
  | succ k ih => simp [buildTensorChain, MLLFormula.tensorCount, ih]

/-- Encode a single integer coefficient as a well-typed cut pair.
    Positive and negative values both use tensor chains of depth |a|.
    Bridge: maps ℤ-coefficients to proof-theoretic cut structures preserving magnitude. -/
def encodeCoefficientAsCut {n : ℕ} (i : Fin n) (a : ℤ) : CutPair n :=
  { left := buildTensorChain i a.natAbs
    right := (buildTensorChain i a.natAbs).neg }

/-- Coefficient encoding produces well-typed cut pairs.
    Bridge: the encoding respects the MLL typing discipline. -/
theorem encodeCoefficientAsCut_wellTyped {n : ℕ} (i : Fin n) (a : ℤ) :
    (encodeCoefficientAsCut i a).isWellTyped := by
  simp [encodeCoefficientAsCut, CutPair.isWellTyped]

/-- The complexity of an encoded coefficient equals 2|a|.
    Bridge: this is the atom of the norm-cut correspondence —
    each lattice component contributes 2|vᵢ| to total cut complexity. -/
theorem encodeCoefficientAsCut_complexity {n : ℕ} (i : Fin n) (a : ℤ) :
    (encodeCoefficientAsCut i a).complexity = 2 * a.natAbs := by
  simp [encodeCoefficientAsCut, CutPair.complexity, MLLFormula.depth_neg]
  ring

/-- Encode a lattice vector v : Fin n → ℤ as a vector of cut pairs.
    Each component vᵢ becomes a cut pair of complexity 2|vᵢ|.
    Bridge: maps lattice points ℤⁿ to proof-net cut structures. -/
def encodeVector {n : ℕ} (v : Fin n → ℤ) : Fin n → CutPair n :=
  fun i => encodeCoefficientAsCut i (v i)

/-- The total cut complexity of a vector encoding.
    Bridge: this is the proof-theoretic analogue of the L¹ norm ‖v‖₁. -/
def vectorCutComplexity {n : ℕ} (cuts : Fin n → CutPair n) : ℕ :=
  ∑ i, (cuts i).complexity

/-- All cut pairs in a vector encoding are well-typed. -/
theorem encodeVector_wellTyped {n : ℕ} (v : Fin n → ℤ) (i : Fin n) :
    (encodeVector v i).isWellTyped := by
  simp [encodeVector]
  exact encodeCoefficientAsCut_wellTyped i (v i)

end ProofTheoreticCrypto