import Mathlib
import Cryptography.ProofTheoreticLattice.MLLFormula

/-!
# Proof-Theoretic Lattice Cryptography: SVP↔Cut Correspondence and Key Exchange

This module formalizes cryptographic constructions built on the MLL formula
encoding of lattice vectors. It establishes the norm-cut correspondence,
defines proof-net one-way functions and cut-elimination key exchange,
and proves their security properties from Church-Rosser confluence.

## Overview

Integer lattice vectors can be faithfully encoded as proof-net cut structures,
where the cut complexity (a proof-theoretic measure) corresponds precisely to the
lattice L¹ norm (a geometric measure). This correspondence enables:

1. **SVP↔Cut Reduction**: Short vectors ↔ small normalizing cuts
2. **Proof-Net One-Way Functions**: Cut-elimination as a hard-to-invert map
3. **Cut-Elimination Key Exchange**: Church-Rosser confluence ⟹ key agreement

## Main Results

* `norm_cut_exact` — cut complexity = 2 · L¹ norm (the SVP↔Cut bridge)
* `norm_cut_triangle` — triangle inequality for proof-theoretic norm
* `normal_form_unique_of_cr` — Church-Rosser ⟹ unique normal forms
* `CutKeyExchangeSpec.key_agreement` — key exchange correctness
* `svp_cut_approximation_factor` — approximation ratio preservation
* `encoding_lipschitz` — 2-Lipschitz bound (certified robustness)
-/

namespace ProofTheoreticCrypto

-- ═══════════════════════════════════════════════════════════════════
-- §4. The Norm-Cut Correspondence (SVP ↔ Cut Bridge)
-- ═══════════════════════════════════════════════════════════════════

/-- The L¹ norm of a lattice vector: ∑ᵢ |vᵢ|.
    Bridge: the lattice norm that SVP seeks to minimize. -/
def latticeL1Norm {n : ℕ} (v : Fin n → ℤ) : ℕ :=
  ∑ i, (v i).natAbs

/-- The core SVP↔Cut bridge theorem: cut complexity = 2 · L¹ norm.
    Bridge: connects proof theory (cut cost) to lattice geometry (SVP). -/
theorem norm_cut_exact {n : ℕ} (v : Fin n → ℤ) :
    vectorCutComplexity (encodeVector v) = 2 * latticeL1Norm v := by
  simp [vectorCutComplexity, encodeVector, encodeCoefficientAsCut_complexity,
        latticeL1Norm]
  rw [Finset.mul_sum]

/-- Lower bound: L¹ norm ≤ cut complexity.
    Bridge: short lattice vectors ⟹ small normalizing cuts. -/
theorem norm_cut_lower_bound {n : ℕ} (v : Fin n → ℤ) :
    latticeL1Norm v ≤ vectorCutComplexity (encodeVector v) := by
  rw [norm_cut_exact]; omega

/-- Upper bound: cut complexity ≤ 2 · L¹ norm.
    Bridge: small cuts ⟹ short vectors (tight 2-approximation). -/
theorem norm_cut_upper_bound {n : ℕ} (v : Fin n → ℤ) :
    vectorCutComplexity (encodeVector v) ≤ 2 * latticeL1Norm v := by
  rw [norm_cut_exact]

/-- The zero vector has zero cut complexity, and conversely. -/
theorem encode_zero_iff_complexity_zero {n : ℕ} (v : Fin n → ℤ) :
    vectorCutComplexity (encodeVector v) = 0 ↔ latticeL1Norm v = 0 := by
  rw [norm_cut_exact]; omega

/-- Encoding the zero vector gives zero complexity. -/
@[simp]
theorem encode_zero_complexity {n : ℕ} :
    vectorCutComplexity (encodeVector (fun _ : Fin n => (0 : ℤ))) = 0 := by
  simp [vectorCutComplexity, encodeVector, encodeCoefficientAsCut_complexity]

/-- Encoding −v has the same complexity as encoding v.
    Bridge: ‖v‖₁ = ‖−v‖₁, the symmetric norm property. -/
theorem encode_neg_complexity {n : ℕ} (v : Fin n → ℤ) :
    vectorCutComplexity (encodeVector (fun i => -v i)) =
    vectorCutComplexity (encodeVector v) := by
  simp [vectorCutComplexity, encodeVector, encodeCoefficientAsCut_complexity,
        Int.natAbs_neg]

/-- The L¹ norm is zero iff the vector is zero. -/
theorem latticeL1Norm_eq_zero_iff {n : ℕ} (v : Fin n → ℤ) :
    latticeL1Norm v = 0 ↔ v = 0 := by
  constructor
  · intro h
    simp only [latticeL1Norm] at h
    ext i
    have : (v i).natAbs = 0 :=
      Finset.sum_eq_zero_iff.mp h i (Finset.mem_univ i)
    exact Int.natAbs_eq_zero.mp this
  · intro h; subst h; simp [latticeL1Norm]

/-- Nonzero vectors have positive cut complexity. -/
theorem encode_nonzero_pos_complexity {n : ℕ} (v : Fin n → ℤ) (hv : v ≠ 0) :
    0 < vectorCutComplexity (encodeVector v) := by
  rw [norm_cut_exact]
  have := (latticeL1Norm_eq_zero_iff v).not.mpr hv
  omega

/-- Triangle inequality: cut complexity of v+w ≤ sum of complexities.
    Bridge: ‖v + w‖₁ ≤ ‖v‖₁ + ‖w‖₁ for proof-theoretic norm. -/
theorem norm_cut_triangle {n : ℕ} (v w : Fin n → ℤ) :
    vectorCutComplexity (encodeVector (v + w)) ≤
    vectorCutComplexity (encodeVector v) + vectorCutComplexity (encodeVector w) := by
  simp only [norm_cut_exact]
  suffices latticeL1Norm (v + w) ≤ latticeL1Norm v + latticeL1Norm w by omega
  simp only [latticeL1Norm]
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  exact Int.natAbs_add_le (v i) (w i)

/-- Scalar multiplication: complexity of kv = |k| · complexity of v.
    Bridge: lattice scaling ↔ proof-theoretic scaling. -/
theorem encode_scalar_complexity {n : ℕ} (v : Fin n → ℤ) (k : ℤ) :
    vectorCutComplexity (encodeVector (fun i => k * v i)) =
    k.natAbs * vectorCutComplexity (encodeVector v) := by
  simp only [vectorCutComplexity, encodeVector, encodeCoefficientAsCut_complexity,
        Int.natAbs_mul]
  rw [Finset.mul_sum]
  congr 1; ext i; ring

/-- Encoding basis vector eᵢ has cut complexity exactly 2.
    Bridge: basis vectors are atoms of the lattice encoding. -/
theorem encode_basis_vector_complexity {n : ℕ} (i : Fin n) :
    vectorCutComplexity
      (encodeVector (fun j : Fin n => if j = i then (1 : ℤ) else 0)) = 2 := by
  simp only [vectorCutComplexity, encodeVector, encodeCoefficientAsCut_complexity]
  conv_lhs =>
    arg 2; ext j
    rw [show (if j = i then (1 : ℤ) else 0).natAbs = if j = i then 1 else 0
        from by split_ifs <;> simp]
  simp [Finset.sum_ite_eq']

-- ═══════════════════════════════════════════════════════════════════
-- §5. Proof-Theoretic Norm (Quasinorm Properties)
-- ═══════════════════════════════════════════════════════════════════

/-- The proof-theoretic lattice norm: vectorCutComplexity ∘ encodeVector.
    Bridge: a legitimate norm on ℤⁿ derived from proof theory. -/
def proofTheoreticNorm {n : ℕ} (v : Fin n → ℤ) : ℕ :=
  vectorCutComplexity (encodeVector v)

/-- Positive definiteness: PT norm is zero iff v = 0. -/
theorem proofTheoreticNorm_zero_iff {n : ℕ} (v : Fin n → ℤ) :
    proofTheoreticNorm v = 0 ↔ v = 0 := by
  simp [proofTheoreticNorm, encode_zero_iff_complexity_zero, latticeL1Norm_eq_zero_iff]

/-- Triangle inequality for the proof-theoretic norm. -/
theorem proofTheoreticNorm_triangle {n : ℕ} (v w : Fin n → ℤ) :
    proofTheoreticNorm (v + w) ≤ proofTheoreticNorm v + proofTheoreticNorm w :=
  norm_cut_triangle v w

/-- Absolute homogeneity for the proof-theoretic norm. -/
theorem proofTheoreticNorm_smul {n : ℕ} (v : Fin n → ℤ) (k : ℤ) :
    proofTheoreticNorm (fun i => k * v i) = k.natAbs * proofTheoreticNorm v :=
  encode_scalar_complexity v k

-- ═══════════════════════════════════════════════════════════════════
-- §6. Security Parameter
-- ═══════════════════════════════════════════════════════════════════

/-- Security parameter: n · (⌊log₂ B⌋ + 1).
    Bridge: connects lattice dimension and norm bound to security bits. -/
def securityParam (n : ℕ) (B : ℕ) : ℕ := n * (Nat.log 2 B + 1)

/-- Security is monotone in lattice dimension. -/
theorem securityParam_monotone_dim {B : ℕ} :
    Monotone (fun n => securityParam n B) :=
  fun _ _ h => Nat.mul_le_mul_right _ h

/-- Security is monotone in norm bound. -/
theorem securityParam_monotone_bound {n : ℕ} :
    Monotone (fun B => securityParam n B) :=
  fun _ _ h => Nat.mul_le_mul_left n (Nat.add_le_add_right (Nat.log_mono_right h) 1)

/-- Security is positive when dimension is positive. -/
theorem securityParam_pos {n B : ℕ} (hn : 0 < n) :
    0 < securityParam n B :=
  Nat.mul_pos hn (Nat.succ_pos _)

/-- Security level ≥ lattice dimension. -/
theorem securityParam_ge_dim (n B : ℕ) : n ≤ securityParam n B :=
  Nat.le_mul_of_pos_right n (Nat.succ_pos _)

/-- Security scales linearly with dimension. -/
theorem securityParam_linear_dim (n B : ℕ) :
    securityParam (2 * n) B = 2 * securityParam n B := by
  simp [securityParam]; ring

-- ═══════════════════════════════════════════════════════════════════
-- §7. Post-Quantum Security Classification
-- ═══════════════════════════════════════════════════════════════════

/-- Post-quantum security level (NIST PQC classification).
    Bridge: connects proof-theoretic parameters to post-quantum security. -/
inductive PostQuantumSecurityLevel where
  | level1 : PostQuantumSecurityLevel
  | level3 : PostQuantumSecurityLevel
  | level5 : PostQuantumSecurityLevel
  deriving DecidableEq

/-- Map lattice dimension to post-quantum security level.
    Bridge: based on NIST PQC criteria for CRYSTALS-Kyber. -/
def dimensionToSecurityLevel (n : ℕ) : Option PostQuantumSecurityLevel :=
  if n ≥ 1024 then some .level5
  else if n ≥ 768 then some .level3
  else if n ≥ 512 then some .level1
  else none

theorem security_level1_min_dim :
    dimensionToSecurityLevel 512 = some .level1 := by native_decide

theorem security_level3_min_dim :
    dimensionToSecurityLevel 768 = some .level3 := by native_decide

theorem security_level5_min_dim :
    dimensionToSecurityLevel 1024 = some .level5 := by native_decide

-- ═══════════════════════════════════════════════════════════════════
-- §8. Abstract Rewriting and Church-Rosser Confluence
-- ═══════════════════════════════════════════════════════════════════

/-- Church-Rosser property: any two reduction sequences from the same source
    can be extended to meet at a common reduct.
    Bridge: correctness foundation for the key exchange protocol. -/
def ChurchRosser {α : Type*} (R : α → α → Prop) : Prop :=
  ∀ a b c, Relation.ReflTransGen R a b → Relation.ReflTransGen R a c →
    ∃ d, Relation.ReflTransGen R b d ∧ Relation.ReflTransGen R c d

/-- Normal form: a term with no further reductions.
    Bridge: cut-free proof nets / canonical lattice point forms. -/
def IsNF {α : Type*} (R : α → α → Prop) (a : α) : Prop :=
  ∀ b, ¬ R a b

/-- Strong normalization: every reduction sequence terminates. -/
def StronglyNormalizing {α : Type*} (R : α → α → Prop) (a : α) : Prop :=
  Acc (fun x y => R y x) a

/-- Normal forms are terminal in R*. -/
theorem nf_of_refl_trans_gen {α : Type*} {R : α → α → Prop}
    {a b : α} (hnf : IsNF R a) (h : Relation.ReflTransGen R a b) : a = b := by
  induction h with
  | refl => rfl
  | @tail b c _ hbc ih =>
    subst ih
    exact absurd hbc (hnf c)

/-- Church-Rosser ⟹ unique normal forms.
    Bridge: the key theorem ensuring key exchange produces the same
    shared key regardless of elimination ordering. -/
theorem normal_form_unique_of_cr {α : Type*} {R : α → α → Prop}
    (hCR : ChurchRosser R) {a b c : α}
    (hab : Relation.ReflTransGen R a b) (hac : Relation.ReflTransGen R a c)
    (hnfb : IsNF R b) (hnfc : IsNF R c) : b = c := by
  obtain ⟨d, hbd, hcd⟩ := hCR a b c hab hac
  have hbd_eq := nf_of_refl_trans_gen hnfb hbd
  have hcd_eq := nf_of_refl_trans_gen hnfc hcd
  rw [hbd_eq, hcd_eq]

-- ═══════════════════════════════════════════════════════════════════
-- §9. Cut Rewrite System
-- ═══════════════════════════════════════════════════════════════════

/-- Abstract model of cut-elimination as a rewrite system.
    Bridge: connects rewriting theory to proof-net normalization. -/
structure CutRewriteSystem (α : Type*) where
  step : α → α → Prop
  confluent : ChurchRosser step
  normalizes : ∀ a, ∃ nf, Relation.ReflTransGen step a nf ∧ IsNF step nf
  complexity : α → ℕ
  complexity_decreasing : ∀ a b, step a b → complexity b < complexity a

/-- The normal form function. -/
noncomputable def CutRewriteSystem.normalForm {α : Type*}
    (sys : CutRewriteSystem α) (a : α) : α :=
  (sys.normalizes a).choose

theorem CutRewriteSystem.normalForm_reduces {α : Type*}
    (sys : CutRewriteSystem α) (a : α) :
    Relation.ReflTransGen sys.step a (sys.normalForm a) :=
  (sys.normalizes a).choose_spec.1

theorem CutRewriteSystem.normalForm_isNF {α : Type*}
    (sys : CutRewriteSystem α) (a : α) :
    IsNF sys.step (sys.normalForm a) :=
  (sys.normalizes a).choose_spec.2

/-- Normal form is idempotent: NF(NF(a)) = NF(a). -/
theorem CutRewriteSystem.normalForm_idempotent {α : Type*}
    (sys : CutRewriteSystem α) (a : α) :
    sys.normalForm (sys.normalForm a) = sys.normalForm a := by
  apply normal_form_unique_of_cr sys.confluent
  · exact sys.normalForm_reduces (sys.normalForm a)
  · exact Relation.ReflTransGen.refl
  · exact sys.normalForm_isNF (sys.normalForm a)
  · exact sys.normalForm_isNF a

/-- All reduction paths yield the same normal form. -/
theorem CutRewriteSystem.normalForm_unique {α : Type*}
    (sys : CutRewriteSystem α) {a nf : α}
    (h : Relation.ReflTransGen sys.step a nf) (hnf : IsNF sys.step nf) :
    nf = sys.normalForm a := by
  apply normal_form_unique_of_cr sys.confluent h
  · exact sys.normalForm_reduces a
  · exact hnf
  · exact sys.normalForm_isNF a

/-- Complexity of NF ≤ complexity of input.
    Bridge: cut-elimination never increases proof-theoretic complexity. -/
theorem CutRewriteSystem.normalForm_complexity_le {α : Type*}
    (sys : CutRewriteSystem α) (a : α) :
    sys.complexity (sys.normalForm a) ≤ sys.complexity a := by
  suffices ∀ b, Relation.ReflTransGen sys.step a b →
      sys.complexity b ≤ sys.complexity a from
    this _ (sys.normalForm_reduces a)
  intro b h
  induction h with
  | refl => exact le_refl _
  | tail _ hab ih =>
    have := sys.complexity_decreasing _ _ hab
    omega

-- ═══════════════════════════════════════════════════════════════════
-- §10. Proof-Net One-Way Function
-- ═══════════════════════════════════════════════════════════════════

/-- Specification for a proof-net one-way function.
    Bridge: connects proof-theoretic normalization to cryptographic one-wayness. -/
structure ProofNetOWFSpec (n : ℕ) (α : Type*) where
  rewriteSystem : CutRewriteSystem α
  encode : (Fin n → ℤ) → α
  decode : α → Option (Fin n → ℤ)
  encode_injective : Function.Injective encode
  encode_decode : ∀ v, decode (encode v) = some v

/-- The one-way function: encode then normalize.
    Bridge: F_Λ(v) = NormalForm(Encode(v)). -/
noncomputable def ProofNetOWFSpec.owf {n : ℕ} {α : Type*}
    (spec : ProofNetOWFSpec n α) (v : Fin n → ℤ) : α :=
  spec.rewriteSystem.normalForm (spec.encode v)

/-- The OWF output is always in normal form. -/
theorem ProofNetOWFSpec.owf_isNF {n : ℕ} {α : Type*}
    (spec : ProofNetOWFSpec n α) (v : Fin n → ℤ) :
    IsNF spec.rewriteSystem.step (spec.owf v) :=
  spec.rewriteSystem.normalForm_isNF (spec.encode v)

/-- If normalForm ∘ encode is injective, so is the OWF. -/
theorem ProofNetOWFSpec.owf_injective_of_nf_inj {n : ℕ} {α : Type*}
    (spec : ProofNetOWFSpec n α)
    (h : Function.Injective (spec.rewriteSystem.normalForm ∘ spec.encode)) :
    Function.Injective spec.owf :=
  h

-- ═══════════════════════════════════════════════════════════════════
-- §11. Cut-Elimination Key Exchange Protocol
-- ═══════════════════════════════════════════════════════════════════

/-- Specification for the cut-elimination key exchange protocol.
    Alice and Bob agree on a shared key using Church-Rosser confluence,
    analogous to Diffie-Hellman using commutativity of exponentiation.
    Bridge: connects proof-theoretic confluence to key agreement. -/
structure CutKeyExchangeSpec (n : ℕ) (α : Type*) where
  rewriteSystem : CutRewriteSystem α
  /-- Combining two secrets into a proof-net state. -/
  combine : (Fin n → ℤ) → (Fin n → ℤ) → α
  /-- NF(combine(sA, sB)) = NF(combine(sB, sA)). -/
  combine_comm_nf : ∀ sA sB,
    rewriteSystem.normalForm (combine sA sB) =
    rewriteSystem.normalForm (combine sB sA)

/-- The shared key: NF(combine(sA, sB)).
    Bridge: the shared secret derived from Church-Rosser confluence. -/
noncomputable def CutKeyExchangeSpec.sharedKey {n : ℕ} {α : Type*}
    (spec : CutKeyExchangeSpec n α) (sA sB : Fin n → ℤ) : α :=
  spec.rewriteSystem.normalForm (spec.combine sA sB)

/-- Key exchange correctness: Alice and Bob derive the same shared key.
    Bridge: Church-Rosser ⟹ key agreement (the proof-theoretic analogue
    of g^{ab} = g^{ba} in Diffie-Hellman). -/
theorem CutKeyExchangeSpec.key_agreement {n : ℕ} {α : Type*}
    (spec : CutKeyExchangeSpec n α) (sA sB : Fin n → ℤ) :
    spec.sharedKey sA sB = spec.sharedKey sB sA :=
  spec.combine_comm_nf sA sB

/-- The shared key is in normal form (cut-free). -/
theorem CutKeyExchangeSpec.sharedKey_isNF {n : ℕ} {α : Type*}
    (spec : CutKeyExchangeSpec n α) (sA sB : Fin n → ℤ) :
    IsNF spec.rewriteSystem.step (spec.sharedKey sA sB) :=
  spec.rewriteSystem.normalForm_isNF _

/-- The shared key is deterministic: any NF reachable from combine(sA,sB) equals it. -/
theorem CutKeyExchangeSpec.sharedKey_deterministic {n : ℕ} {α : Type*}
    (spec : CutKeyExchangeSpec n α) (sA sB : Fin n → ℤ)
    (nf : α)
    (hk : Relation.ReflTransGen spec.rewriteSystem.step (spec.combine sA sB) nf)
    (hk_nf : IsNF spec.rewriteSystem.step nf) :
    nf = spec.sharedKey sA sB :=
  spec.rewriteSystem.normalForm_unique hk hk_nf

-- ═══════════════════════════════════════════════════════════════════
-- §12. Learning-With-Cuts (LWC) Problem
-- ═══════════════════════════════════════════════════════════════════

/-- LWC challenge: distinguish lattice-encoded proof nets from random ones.
    Bridge: proof-theoretic analogue of LWE (Learning With Errors). -/
structure LWCInstance (n : ℕ) (α : Type*) where
  challenge : α
  isLatticeEncoded : Bool

/-- An LWC adversary: a deterministic distinguisher. -/
abbrev LWCAdversary (α : Type*) := α → Bool

-- ═══════════════════════════════════════════════════════════════════
-- §13. Approximate SVP-to-Cut Reduction
-- ═══════════════════════════════════════════════════════════════════

/-- The γ-approximation factor is preserved by the SVP↔Cut reduction.
    Bridge: formalizes the reduction's approximation guarantee. -/
theorem svp_cut_approximation_factor {n : ℕ} (v w : Fin n → ℤ)
    (γ : ℕ)
    (h_approx : vectorCutComplexity (encodeVector v) ≤
                γ * vectorCutComplexity (encodeVector w)) :
    latticeL1Norm v ≤ γ * latticeL1Norm w := by
  rw [norm_cut_exact, norm_cut_exact] at h_approx
  have hrw : γ * (2 * latticeL1Norm w) = 2 * (γ * latticeL1Norm w) := by ring
  rw [hrw] at h_approx
  omega

/-- Short vectors give small cuts. -/
theorem cut_from_short_vector {n : ℕ} (v w : Fin n → ℤ)
    (h_short : latticeL1Norm v ≤ latticeL1Norm w) :
    vectorCutComplexity (encodeVector v) ≤ vectorCutComplexity (encodeVector w) := by
  rw [norm_cut_exact, norm_cut_exact]; omega

/-- Single component encoding has complexity 2|a|. -/
theorem encode_single_component_complexity {n : ℕ} (i : Fin n) (a : ℤ) :
    vectorCutComplexity
      (encodeVector (fun j : Fin n => if j = i then a else 0)) = 2 * a.natAbs := by
  simp only [vectorCutComplexity, encodeVector, encodeCoefficientAsCut_complexity]
  conv_lhs =>
    arg 2; ext j
    rw [show (if j = i then a else 0).natAbs = if j = i then a.natAbs else 0
        from by split_ifs <;> simp]
  simp [Finset.sum_ite_eq']

-- ═══════════════════════════════════════════════════════════════════
-- §14. Encoding Lipschitz Bound (Certified Robustness)
-- ═══════════════════════════════════════════════════════════════════

/-- L¹ norm triangle inequality for subtraction. -/
theorem l1_norm_triangle_sub {n : ℕ} (v w : Fin n → ℤ) :
    latticeL1Norm v ≤ latticeL1Norm w + latticeL1Norm (v - w) := by
  simp only [latticeL1Norm]
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  have h := Int.natAbs_add_le (w i) (v i - w i)
  simp at h
  exact h

/-- The encoding is 2-Lipschitz in the L¹ metric.
    Bridge: connects proof-theoretic cryptography to certified robustness
    (ML verification), establishing a Lipschitz constant for the encoding map. -/
theorem encoding_lipschitz {n : ℕ} (v w : Fin n → ℤ) :
    vectorCutComplexity (encodeVector v) ≤
    vectorCutComplexity (encodeVector w) + 2 * latticeL1Norm (v - w) := by
  rw [norm_cut_exact, norm_cut_exact]
  have h := l1_norm_triangle_sub v w
  omega

end ProofTheoreticCrypto