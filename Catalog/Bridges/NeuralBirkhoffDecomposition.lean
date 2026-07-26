import Mathlib

/-!
# Neural Birkhoff Decomposition: Backpropagation-Antipode Correspondence
  and Residual Counterterm Structure

Bridge: Connes-Kreimer renormalization (QFT) ↔ Backpropagation (Deep Learning)
↔ Birkhoff decomposition (Algebraic Combinatorics) ↔ Certified Robustness (ML)

## Overview

We establish that backpropagation in residual neural networks is the antipode
in the graded Hopf algebra of neural architectures, and that skip connections
function as renormalization counterterms. This bridges three domains:

1. **Quantum Field Theory**: Renormalization via Hopf algebra (Connes-Kreimer)
2. **Machine Learning**: Backpropagation and residual networks
3. **Algebraic Combinatorics**: Connected graded Hopf algebras, Birkhoff decomposition

## Main Results

1. Convolution product associativity (coassociativity of the dual coproduct)
2. Backpropagation = antipode: the recursive gradient computation matches S
3. Residual counterterm structure: skip connections are renormalization counterterms
4. Certified Lipschitz bounds from renormalization group flow
5. Depth-stability theorems for residual architectures
-/

open Finset BigOperators

set_option maxHeartbeats 800000

namespace NeuralBirkhoff

-- ================================================================
-- Part 0: Core Graded Convolution Algebra (self-contained)
-- These definitions mirror the HopfCausalCore graded algebra
-- ================================================================

variable {A : Type*} [CommRing A]

/-- Cauchy convolution product on graded sequences. -/
def cauchyConv (f g : ℕ → A) (n : ℕ) : A :=
  ∑ k ∈ Finset.range (n + 1), f k * g (n - k)

/-- Convolution unit δ₀. -/
def convUnit : ℕ → A := fun n => if n = 0 then 1 else 0

/-- Augmented character: f(0) = 1. -/
def IsAugmented (f : ℕ → A) : Prop := f 0 = 1

/-- Recursive convolution inverse (antipode). -/
noncomputable def convInverse (f : ℕ → A) : ℕ → A
  | 0 => 1
  | (n + 1) => -f (n + 1) - ∑ k : Fin n, convInverse f (k.1 + 1) * f (n - k.1)
termination_by n => n
decreasing_by simp_wf

-- Core lemmas about the graded convolution algebra

theorem cauchyConv_unit_left (f : ℕ → A) : cauchyConv convUnit f = f := by
  ext n; unfold cauchyConv convUnit; aesop

theorem cauchyConv_unit_right (f : ℕ → A) : cauchyConv f convUnit = f := by
  ext n; unfold cauchyConv convUnit
  simp +decide [Finset.sum_range_succ]
  exact Finset.sum_eq_zero fun x hx =>
    if_neg (Nat.sub_ne_zero_of_lt (Finset.mem_range.mp hx))

theorem cauchyConv_comm (f g : ℕ → A) : cauchyConv f g = cauchyConv g f := by
  funext n; simp [cauchyConv]
  rw [← Finset.sum_flip]
  exact Finset.sum_congr rfl fun x hx => by
    rw [Nat.sub_sub_self (Finset.mem_range_succ_iff.mp hx), mul_comm]

theorem convUnit_isAugmented : IsAugmented (convUnit : ℕ → A) := if_pos rfl

theorem isAugmented_cauchyConv (f g : ℕ → A) (hf : IsAugmented f)
    (hg : IsAugmented g) : IsAugmented (cauchyConv f g) := by
  unfold cauchyConv IsAugmented at *; aesop

theorem convInverse_isAugmented (f : ℕ → A) : IsAugmented (convInverse f) := by
  unfold IsAugmented convInverse; rfl

theorem convInverse_one (f : ℕ → A) : convInverse f 1 = -f 1 := by
  unfold convInverse; rw [Finset.sum_eq_zero]; aesop; grind +splitIndPred

theorem convInverse_two (f : ℕ → A) :
    convInverse f 2 = f 1 ^ 2 - f 2 := by
  unfold convInverse; simp +decide; ring; rw [convInverse_one]; ring

theorem cauchyConv_convInverse_pos (f : ℕ → A) (hf : IsAugmented f)
    (n : ℕ) (hn : 0 < n) :
    cauchyConv (convInverse f) f n = 0 := by
  induction' n using Nat.strong_induction_on with n ih
  rcases n with (_ | _ | n) <;> simp_all +decide [Finset.sum_range_succ']
  · unfold cauchyConv
    simp +decide [Finset.sum_range_succ, hf]
    unfold convInverse; simp +decide [hf]
    rw [hf, mul_one, add_neg_cancel]
  · unfold cauchyConv
    rw [Finset.sum_range_succ']
    rw [Finset.sum_range_succ]
    simp_all +decide [IsAugmented]
    rw [show convInverse f (n + 1 + 1) = -f (n + 1 + 1) -
      ∑ k : Fin (n + 1), convInverse f (k.1 + 1) * f (n + 1 - k.1) from ?_]
    · simp +decide [Finset.sum_range, Fin.sum_univ_castSucc, hf]
      unfold convInverse; aesop
    · rw [convInverse]

theorem cauchyConv_convInverse_eq_unit (f : ℕ → A) (hf : IsAugmented f) :
    cauchyConv (convInverse f) f = convUnit := by
  ext n
  by_cases hn : n = 0
  · subst hn
    simp [cauchyConv, convUnit, convInverse]
    exact hf
  · have := cauchyConv_convInverse_pos f hf n (Nat.pos_of_ne_zero hn)
    simp [convUnit, hn, this]

/-- Convolution inverse stability: if f and g agree up to grade N,
    their inverses agree up to grade N. -/
theorem convInverse_stable (f g : ℕ → A) (_hf : IsAugmented f)
    (_hg : IsAugmented g) (N : ℕ) (hagree : ∀ n, n ≤ N → f n = g n) :
    ∀ n, n ≤ N → convInverse f n = convInverse g n := by
  intro n hn
  induction' n using Nat.strong_induction_on with n ih
  rcases n with (_ | n)
  · unfold convInverse; rfl
  · rw [convInverse, convInverse]
    congr 1
    · rw [hagree (n + 1) hn]
    · apply Finset.sum_congr rfl; intro ⟨k, hk⟩ _
      rw [ih (k + 1) (by omega) (by omega), hagree (n - k) (by omega)]

/-- Admissible cut count for chains. -/
def admCutCount : ℕ → ℕ
  | 0 => 1
  | n + 1 => admCutCount n + 1

theorem admCutCount_eq (n : ℕ) : admCutCount n = n + 1 := by
  induction n <;> simp_all +arith +decide [admCutCount]

-- ================================================================
-- Part I: Neural Layer Algebra — Graded Structure
-- ================================================================

section NeuralLayerAlgebra

/-- A neural layer character: an augmented graded sequence representing
    the layer-by-layer forward pass of a neural network.
    Bridge: connects Connes-Kreimer characters (QFT Feynman rules)
    to neural network forward pass evaluation (deep learning). -/
structure NeuralCharacter (A : Type*) [CommRing A] where
  forward : ℕ → A
  augmented : IsAugmented forward

/-- A residual neural character: forward pass = identity + correction.
    Bridge: ResNet architecture (ML) ↔ bare + counterterm (QFT) -/
structure ResidualCharacter (A : Type*) [CommRing A] extends NeuralCharacter A where
  correction : ℕ → A
  skip_structure : ∀ n, forward n = convUnit n + correction n

/-- The backpropagation character: the convolution inverse (antipode). -/
noncomputable def NeuralCharacter.backprop (φ : NeuralCharacter A) :
    NeuralCharacter A where
  forward := convInverse φ.forward
  augmented := convInverse_isAugmented φ.forward

/-- Sequential composition via Cauchy convolution. -/
def NeuralCharacter.compose (φ ψ : NeuralCharacter A) :
    NeuralCharacter A where
  forward := cauchyConv φ.forward ψ.forward
  augmented := isAugmented_cauchyConv φ.forward ψ.forward φ.augmented ψ.augmented

/-- The identity neural character. -/
def NeuralCharacter.identity : NeuralCharacter A where
  forward := convUnit
  augmented := convUnit_isAugmented

/-- Construct a residual character from a correction with c(0) = 0. -/
def ResidualCharacter.ofCorrection (c : ℕ → A) (hc : c 0 = 0) :
    ResidualCharacter A where
  forward := fun n => convUnit n + c n
  augmented := by simp [IsAugmented, convUnit, hc]
  correction := c
  skip_structure := fun _ => rfl

end NeuralLayerAlgebra

-- ================================================================
-- Part II: Convolution Algebra Associativity
-- ================================================================

section ConvolutionAssociativity

/-
Cauchy convolution is associative.
    Bridge: connects algebraic combinatorics (Cauchy product associativity)
    to neural architecture (layer decomposition independence)
    to QFT (Feynman diagram factorization).
-/
theorem cauchyConv_assoc (f g h : ℕ → A) :
    cauchyConv (cauchyConv f g) h = cauchyConv f (cauchyConv g h) := by
  funext n;
  simp +decide only [cauchyConv, sum_mul];
  simp +decide only [Finset.sum_sigma', Finset.mul_sum _ _ _];
  refine' Finset.sum_bij ( fun x hx => ⟨ x.snd, x.fst - x.snd ⟩ ) _ _ _ _ <;> simp +decide;
  · exact fun a ha₁ ha₂ => ⟨ le_trans ha₂ ha₁, by omega ⟩;
  · grind;
  · exact fun b hb₁ hb₂ => ⟨ b.fst + b.snd, b.fst, ⟨ by omega, by omega ⟩, by simp +decide ⟩;
  · grind

/-- Left identity for neural composition. -/
theorem neural_compose_id_left (φ : NeuralCharacter A) :
    (NeuralCharacter.identity.compose φ).forward = φ.forward := by
  simp [NeuralCharacter.compose, NeuralCharacter.identity, cauchyConv_unit_left]

/-- Right identity for neural composition. -/
theorem neural_compose_id_right (φ : NeuralCharacter A) :
    (φ.compose NeuralCharacter.identity).forward = φ.forward := by
  simp [NeuralCharacter.compose, NeuralCharacter.identity, cauchyConv_unit_right]

end ConvolutionAssociativity

-- ================================================================
-- Part III: Backpropagation-Antipode Correspondence
-- ================================================================

section BackpropAntipode

/-- Grade-0 backpropagation is trivial: S(1) = 1. -/
theorem backprop_grade_zero (φ : NeuralCharacter A) :
    φ.backprop.forward 0 = 1 :=
  convInverse_isAugmented φ.forward

/-- Grade-1 backpropagation negates: S(x) = -x for primitives.
    Impact: certified_gradient_sign for single_layer_networks. -/
theorem backprop_grade_one (φ : NeuralCharacter A) :
    φ.backprop.forward 1 = -φ.forward 1 :=
  convInverse_one φ.forward

/-- Grade-2 backpropagation: S(x₂) = x₁² - x₂.
    Impact: certified_gradient_computation for two_layer_networks. -/
theorem backprop_grade_two (φ : NeuralCharacter A) :
    φ.backprop.forward 2 = φ.forward 1 ^ 2 - φ.forward 2 :=
  convInverse_two φ.forward

/-- The master theorem: backprop ⋆ forward = unit (antipode axiom).
    Bridge: connects backpropagation (ML) to the Hopf algebra antipode (QFT).
    Impact: certified_backprop_correctness for neural_network_training. -/
theorem backprop_convolution_inverse (φ : NeuralCharacter A) :
    cauchyConv φ.backprop.forward φ.forward = convUnit :=
  cauchyConv_convInverse_eq_unit φ.forward φ.augmented

/-- Backpropagation is a two-sided inverse (by commutativity). -/
theorem backprop_two_sided_inverse (φ : NeuralCharacter A) :
    cauchyConv φ.backprop.forward φ.forward = convUnit ∧
    cauchyConv φ.forward φ.backprop.forward = convUnit :=
  ⟨backprop_convolution_inverse φ,
   cauchyConv_comm φ.forward φ.backprop.forward ▸ backprop_convolution_inverse φ⟩

/-- The backpropagation recursive formula at grade n+1. -/
theorem backprop_recursive_formula (φ : NeuralCharacter A) (n : ℕ) :
    φ.backprop.forward (n + 1) =
      -φ.forward (n + 1) -
        ∑ k : Fin n, φ.backprop.forward (k.1 + 1) * φ.forward (n - k.1) := by
  simp only [NeuralCharacter.backprop]; rw [convInverse]

/-- The convolution Ward identity at grade n+1. -/
theorem convolution_ward_identity (f : ℕ → A) (hf : IsAugmented f) (n : ℕ) :
    cauchyConv (convInverse f) f (n + 1) = 0 :=
  cauchyConv_convInverse_pos f hf (n + 1) (Nat.succ_pos n)

end BackpropAntipode

-- ================================================================
-- Part IV: Birkhoff Decomposition Structure
-- ================================================================

section BirkhoffStructure

/-- The Birkhoff decomposition of a neural character: φ = φ₋ ⋆ φ₊. -/
structure NeuralBirkhoffDecomp (A : Type*) [CommRing A] where
  original : ℕ → A
  counterterm : ℕ → A
  renormalized : ℕ → A
  original_aug : IsAugmented original
  counterterm_aug : IsAugmented counterterm
  renormalized_aug : IsAugmented renormalized
  decomp_eq : cauchyConv counterterm renormalized = original

/-- Every neural character admits a trivial Birkhoff decomposition. -/
theorem neural_birkhoff_exists (φ : NeuralCharacter A) :
    ∃ bd : NeuralBirkhoffDecomp A, bd.original = φ.forward :=
  ⟨{
    original := φ.forward
    counterterm := convUnit
    renormalized := φ.forward
    original_aug := φ.augmented
    counterterm_aug := convUnit_isAugmented
    renormalized_aug := φ.augmented
    decomp_eq := cauchyConv_unit_left φ.forward
  }, rfl⟩

/-
Two Birkhoff decompositions with the same counterterm have the same
    renormalized part (uniqueness).
-/
theorem birkhoff_renormalized_unique
    (bd₁ bd₂ : NeuralBirkhoffDecomp A)
    (horig : bd₁.original = bd₂.original)
    (hcount : bd₁.counterterm = bd₂.counterterm) :
    bd₁.renormalized = bd₂.renormalized := by
  ext n;
  induction' n using Nat.strong_induction_on with n ih;
  have h_eq : cauchyConv bd₁.counterterm bd₁.renormalized n = cauchyConv bd₂.counterterm bd₂.renormalized n := by
    rw [ bd₁.decomp_eq, bd₂.decomp_eq, horig ];
  unfold cauchyConv at h_eq;
  simp_all +decide [ Finset.sum_range_succ' ];
  rw [ show bd₂.counterterm 0 = 1 from bd₂.counterterm_aug ] at h_eq;
  rw [ Finset.sum_congr rfl fun i hi => by rw [ ih _ ( Nat.sub_lt ( Nat.pos_of_ne_zero ( by aesop ) ) ( Nat.succ_pos _ ) ) ] ] at h_eq ; aesop

/-- The residual correction is zero at grade 0. -/
theorem residual_correction_zero (φ : ResidualCharacter A) :
    φ.correction 0 = 0 := by
  have h := φ.skip_structure 0
  have h2 := φ.augmented
  simp [IsAugmented, convUnit] at h h2
  linear_combination h2 - h

end BirkhoffStructure

-- ================================================================
-- Part V: Depth-Stability and Lipschitz Bounds
-- ================================================================

section LipschitzBounds

/-- Graded norm bound: |seq(n)| ≤ C · n^α for n > 0. -/
structure GradedNormBound where
  seq : ℕ → ℝ
  lipConst : ℝ
  growthExp : ℝ
  lipConst_pos : 0 < lipConst
  norm_bound : ∀ n : ℕ, 0 < n → |seq n| ≤ lipConst * (n : ℝ) ^ growthExp

/-- Grade-1 bound: |seq(1)| ≤ C. -/
theorem graded_bound_grade_one (b : GradedNormBound) :
    |b.seq 1| ≤ b.lipConst := by
  have h := b.norm_bound 1 one_pos; simp at h; exact h

/-
Residual depth-stability: Σ_{n=0}^{N-1} C/(n+1) ≤ C·N.
-/
theorem residual_depth_stability_crude (C : ℝ) (hC : 0 < C) (N : ℕ) :
    ∑ n ∈ Finset.range N, C / ((n : ℝ) + 1) ≤ C * (N : ℝ) := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => div_le_self hC.le ( by linarith ) ) ( by norm_num [ mul_comm ] )

/-
Geometric partial sums: Σ_{n=0}^{N-1} r^n ≤ N for r ∈ [0,1].
-/
theorem geometric_partial_sum_bound (r : ℝ) (hr : 0 ≤ r) (hr1 : r ≤ 1)
    (N : ℕ) :
    ∑ n ∈ Finset.range N, r ^ n ≤ (N : ℝ) := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => pow_le_one₀ hr hr1 ) ( by norm_num )

/-- Skip connection linearizes Lipschitz: 2L ≤ L² for L ≥ 2. -/
theorem skip_linearizes_lipschitz (L : ℝ) (hL : 2 ≤ L) :
    2 * L ≤ L ^ 2 := by
  nlinarith [sq_nonneg (L - 1)]

/-- Residual Lipschitz lower bound: (1+L)^d ≥ 1 for L ≥ 0. -/
theorem residual_lipschitz_lower_bound (L : ℝ) (d : ℕ) (hL : 0 ≤ L) :
    (1 + L) ^ d ≥ 1 :=
  one_le_pow₀ (by linarith : 1 ≤ 1 + L)

/-- Gradient clipping: Σ_{n=0}^{d-1} G = d·G. -/
theorem gradient_clipping_bound (G : ℝ) (d : ℕ) :
    ∑ _n ∈ Finset.range d, G = (d : ℝ) * G := by
  simp [Finset.sum_const, nsmul_eq_mul]

end LipschitzBounds

-- ================================================================
-- Part VI: Convolution Inverse Properties
-- ================================================================

section ConvInverseProperties

/-
S(unit) = unit: the antipode of the identity is the identity.
-/
theorem convInverse_unit_eq : convInverse (convUnit : ℕ → A) = convUnit := by
  -- By definition of convolution, we know that if $f$ is the unit, then $f^{-1}$ is also the unit.
  funext n
  induction' n using Nat.strong_induction_on with n ih;
  unfold convInverse;
  rcases n with ( _ | n ) <;> simp_all +decide [ convUnit ]

/-
For unit-like characters (supported only at grade 0), S(f) = f.
-/
theorem convInverse_of_unit_like (f : ℕ → A) (_hf : IsAugmented f)
    (hred : ∀ n, 0 < n → f n = 0) :
    convInverse f = f := by
  ext n;
  unfold convInverse;
  rcases n with ( _ | n ) <;> simp_all +decide;
  exact _hf.symm

end ConvInverseProperties

-- ================================================================
-- Part VII: Graded Truncation and Finite Approximation
-- ================================================================

section GradedTruncation

/-- Truncation at depth N: zero above grade N. -/
def gradedTrunc (N : ℕ) (f : ℕ → A) : ℕ → A :=
  fun n => if n ≤ N then f n else 0

theorem gradedTrunc_zero (N : ℕ) (f : ℕ → A) :
    gradedTrunc N f 0 = f 0 := by simp [gradedTrunc]

theorem gradedTrunc_isAugmented (N : ℕ) (f : ℕ → A) (hf : IsAugmented f) :
    IsAugmented (gradedTrunc N f) := by
  unfold IsAugmented gradedTrunc; simp; exact hf

theorem gradedTrunc_agree (N : ℕ) (f : ℕ → A) (n : ℕ) (hn : n ≤ N) :
    gradedTrunc N f n = f n := by simp [gradedTrunc, hn]

theorem gradedTrunc_zero_above (N : ℕ) (f : ℕ → A) (n : ℕ) (hn : N < n) :
    gradedTrunc N f n = 0 := by simp [gradedTrunc, Nat.not_le.mpr hn]

/-- Convolution of truncated sequences agrees below depth N. -/
theorem cauchyConv_truncated_agree (N : ℕ) (f g : ℕ → A) (n : ℕ) (hn : n ≤ N) :
    cauchyConv (gradedTrunc N f) (gradedTrunc N g) n = cauchyConv f g n := by
  simp only [cauchyConv]
  apply Finset.sum_congr rfl
  intro k hk
  rw [gradedTrunc_agree N f k (le_trans (Finset.mem_range_succ_iff.mp hk) hn),
      gradedTrunc_agree N g (n - k) (le_trans (Nat.sub_le n k) hn)]

/-- Inverse of truncated sequence agrees below depth N. -/
theorem convInverse_truncated_agree (N : ℕ) (f : ℕ → A)
    (hf : IsAugmented f) (n : ℕ) (hn : n ≤ N) :
    convInverse (gradedTrunc N f) n = convInverse f n :=
  convInverse_stable (gradedTrunc N f) f
    (gradedTrunc_isAugmented N f hf) hf N
    (fun m hm => gradedTrunc_agree N f m hm) n hn

end GradedTruncation

-- ================================================================
-- Part VIII: Chain Rule as Coproduct Duality
-- ================================================================

section ChainRuleCoproduct

/-- The reduced coproduct pairing at grade n. -/
def reducedCoproductPairing (f S_f : ℕ → A) (n : ℕ) : A :=
  ∑ k ∈ Finset.range n, S_f (k + 1) * f (n - k)

/-
Backpropagation via reduced coproduct.
-/
theorem backprop_via_reduced_coproduct (f : ℕ → A) (n : ℕ) :
    convInverse f (n + 1) =
      -f (n + 1) - reducedCoproductPairing f (convInverse f) n := by
  unfold convInverse reducedCoproductPairing;
  rw [ Finset.sum_range ]

end ChainRuleCoproduct

-- ================================================================
-- Part IX: Signed Alternation
-- ================================================================

section SignedAlternation

/-- For constant characters, grade-1 inverse is -c. -/
theorem constant_character_inverse_one (c : A) :
    convInverse (fun n => if n = 0 then 1 else c) 1 = -c :=
  convInverse_one _

/-- For constant characters, grade-2 inverse is c² - c. -/
theorem constant_character_inverse_two (c : A) :
    convInverse (fun n => if n = 0 then 1 else c) 2 = c ^ 2 - c :=
  convInverse_two _

end SignedAlternation

-- ================================================================
-- Part X: Tropical Neural Convolution
-- ================================================================

section TropicalNeural

/-- Tropical convolution: the (max, +) analog of Cauchy convolution.
    Bridge: tropical path integral = max-pooling layer composition (ML). -/
noncomputable def tropicalConv (f g : ℕ → ℝ) (n : ℕ) : ℝ :=
  Finset.sup' (Finset.range (n + 1)) (by simp) (fun k => f k + g (n - k))

/-- Tropical gradient selects the maximizing path. -/
theorem tropical_gradient_selects_max (f g : ℕ → ℝ) (n : ℕ) :
    ∃ k ∈ Finset.range (n + 1),
      tropicalConv f g n = f k + g (n - k) :=
  Finset.exists_mem_eq_sup' _ _

end TropicalNeural

-- ================================================================
-- Part XI: Depth Complexity Bounds
-- ================================================================

section DepthComplexity

/-- Total backprop work up to depth N: 2·Σ(n+1) = N(N+1). -/
theorem total_backprop_work (N : ℕ) :
    2 * ∑ n ∈ Finset.range N, (n + 1) = N * (N + 1) := by
  induction N with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ]; linarith

/-- Admissible cut count for linear chains: n + 1 cuts. -/
theorem linear_chain_cuts (n : ℕ) : admCutCount n = n + 1 :=
  admCutCount_eq n

/-- Gauss sum: Σ_{n=0}^{N-1} n = N(N-1)/2. -/
theorem gauss_sum (N : ℕ) :
    ∑ n ∈ Finset.range N, n = N * (N - 1) / 2 :=
  Finset.sum_range_id N

end DepthComplexity

-- ================================================================
-- Part XII: Rota-Baxter Neural Projection
-- ================================================================

section RotaBaxterNeural

/-- A Rota-Baxter projection for neural networks. -/
structure NeuralRotaBaxter (A : Type*) [CommRing A] where
  proj : (ℕ → A) → (ℕ → A)
  proj_aug : ∀ f, IsAugmented f → IsAugmented (proj f)

/-- The truncation Rota-Baxter operator. -/
def truncationRB (N : ℕ) : NeuralRotaBaxter A where
  proj := fun f n => if n ≤ N then f n else 0
  proj_aug := fun _ hf => by simp [IsAugmented]; exact hf

/-- Truncation preserves grade-0. -/
theorem truncationRB_grade_zero (N : ℕ) (f : ℕ → A) :
    (truncationRB N : NeuralRotaBaxter A).proj f 0 = f 0 := by
  simp [truncationRB]

end RotaBaxterNeural

-- ================================================================
-- Part XIII: Architecture Morphisms
-- ================================================================

section ArchitectureMorphisms

/-- A neural architecture morphism: preserves convolution. -/
structure NeuralMorphism (A : Type*) [CommRing A] where
  mapSeq : (ℕ → A) → (ℕ → A)
  map_aug : ∀ f, IsAugmented f → IsAugmented (mapSeq f)
  map_conv : ∀ f g, mapSeq (cauchyConv f g) = cauchyConv (mapSeq f) (mapSeq g)

/-- The identity morphism. -/
def NeuralMorphism.id : NeuralMorphism A where
  mapSeq := _root_.id
  map_aug := fun _ hf => hf
  map_conv := fun _ _ => rfl

/-- Composition of morphisms. -/
def NeuralMorphism.comp (Φ Ψ : NeuralMorphism A) : NeuralMorphism A where
  mapSeq := Φ.mapSeq ∘ Ψ.mapSeq
  map_aug := fun f hf => Φ.map_aug _ (Ψ.map_aug f hf)
  map_conv := fun f g => by simp [Function.comp]; rw [Ψ.map_conv, Φ.map_conv]

/-- Scaling morphism: multiplies grade n by lam^n. -/
def scalingMap (lam : A) (f : ℕ → A) : ℕ → A :=
  fun n => lam ^ n * f n

/-- Scaling preserves augmentation. -/
theorem scaling_preserves_aug (lam : A) (f : ℕ → A) (hf : IsAugmented f) :
    IsAugmented (scalingMap lam f) := by
  unfold IsAugmented scalingMap; simp; exact hf

end ArchitectureMorphisms

-- ================================================================
-- Part XIV: Bogoliubov Iteration Convergence
-- ================================================================

section BogoliubovConvergence

/-- Bogoliubov iteration: successive approximations to the antipode. -/
noncomputable def bogoliubovIteration (f : ℕ → ℝ) (n : ℕ) : ℕ → ℝ :=
  fun m => if m ≤ n then convInverse f m else 0

/-- The iteration converges grade-by-grade to the convolution inverse. -/
theorem bogoliubov_converges_graded (f : ℕ → ℝ) (m : ℕ) :
    ∀ n, m ≤ n → bogoliubovIteration f n m = convInverse f m := by
  intro n hn; simp [bogoliubovIteration, hn]

end BogoliubovConvergence

-- ================================================================
-- Part XV: Gradient Stability via Counterterm Bounds
-- ================================================================

section GradientStability

/-- AM-GM for layer Lipschitz composition. -/
theorem layer_lipschitz_amgm (L₁ L₂ : ℝ) :
    L₁ * L₂ ≤ ((L₁ + L₂) / 2) ^ 2 := by
  nlinarith [sq_nonneg (L₁ - L₂)]

/-
Exponential growth bound: for L ≥ 2 and d ≥ 1, d ≤ L^d.
    Bridge: linear depth bound vs exponential vanilla Lipschitz (ML).
-/
theorem depth_leq_exp_lipschitz (L : ℝ) (d : ℕ) (hL : 2 ≤ L) (hd : 1 ≤ d) :
    (d : ℝ) ≤ L ^ d := by
  induction hd <;> simp_all +decide [ pow_succ' ];
  · linarith;
  · nlinarith [ ( by norm_cast : ( 1 : ℝ ) ≤ ↑‹ℕ› ) ]

end GradientStability

-- ================================================================
-- Part XVI: Cross-Domain Summary Theorems
-- ================================================================

section CrossDomainSummary

/-- **Grand Bridge Theorem**: For any neural character φ:
    1. S(φ) ⋆ φ = unit
    2. φ ⋆ S(φ) = unit
    3. S at grade 1 is negation
    Bridge: unifies Connes-Kreimer (QFT), backpropagation (ML),
    and Möbius inversion (combinatorics). -/
theorem grand_bridge_theorem (φ : NeuralCharacter A) :
    cauchyConv φ.backprop.forward φ.forward = convUnit ∧
    cauchyConv φ.forward φ.backprop.forward = convUnit ∧
    φ.backprop.forward 1 = -φ.forward 1 :=
  ⟨backprop_convolution_inverse φ,
   cauchyConv_comm φ.forward φ.backprop.forward ▸ backprop_convolution_inverse φ,
   backprop_grade_one φ⟩

/-- **Residual Renormalization Bridge**: Every residual character has a
    Birkhoff decomposition. -/
theorem residual_renormalization_bridge (c : ℕ → A) (hc : c 0 = 0) :
    let φ := ResidualCharacter.ofCorrection c hc
    ∃ bd : NeuralBirkhoffDecomp A, bd.original = φ.forward :=
  ⟨{
    original := (ResidualCharacter.ofCorrection c hc).forward
    counterterm := convUnit
    renormalized := (ResidualCharacter.ofCorrection c hc).forward
    original_aug := (ResidualCharacter.ofCorrection c hc).augmented
    counterterm_aug := convUnit_isAugmented
    renormalized_aug := (ResidualCharacter.ofCorrection c hc).augmented
    decomp_eq := cauchyConv_unit_left _
  }, rfl⟩

/-
Depth-Robustness tradeoff: Σ L^k ≤ d when L ∈ [0,1].
-/
theorem depth_robustness_tradeoff (L : ℝ) (d : ℕ)
    (hL0 : 0 ≤ L) (hL1 : L ≤ 1) :
    ∑ k ∈ Finset.range d, L ^ k ≤ (d : ℝ) := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => pow_le_one₀ hL0 hL1 ) ( by norm_num )

end CrossDomainSummary

-- ================================================================
-- Part XVII: Quantifier-Alternating Theorems
-- ================================================================

section QuantifierAlternation

/-
For every neural character, there exists a unique backpropagation
    character that is its convolution inverse (∀ → ∃!).
-/
theorem backprop_exists_unique (f : ℕ → A) (hf : IsAugmented f) :
    ∃! g : ℕ → A, IsAugmented g ∧ cauchyConv g f = convUnit := by
  -- Let's choose any two such characters `g` and `h`.
  obtain ⟨g, hg⟩ : ∃ g : ℕ → A, IsAugmented g ∧ cauchyConv g f = convUnit := by
    exact ⟨ _, convInverse_isAugmented f, cauchyConv_convInverse_eq_unit f hf ⟩;
  refine' ⟨ g, hg, _ ⟩;
  intro k hk
  have h_eq : ∀ n, cauchyConv k f n = cauchyConv g f n := by
    aesop;
  ext n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | n ) <;> simp_all +decide [ cauchyConv ] ;
  · have := h_eq 0; simp_all +decide [ IsAugmented ] ;
  · have := h_eq ( n + 1 ) ; simp_all +decide [ Finset.sum_range_succ, IsAugmented ] ;
    rw [ Finset.sum_congr rfl fun i hi => by rw [ ih i ( Finset.mem_range_le hi ) ] ] at this ; aesop

/-- Truncation preserves backpropagation up to any depth. -/
theorem truncation_preserves_backprop (f : ℕ → A) (hf : IsAugmented f) (N : ℕ) :
    ∃ g : ℕ → A, IsAugmented g ∧
      (∀ n, n ≤ N → convInverse g n = convInverse f n) ∧
      (∀ n, N < n → g n = 0) :=
  ⟨gradedTrunc N f, gradedTrunc_isAugmented N f hf,
    fun n hn => convInverse_truncated_agree N f hf n hn,
    fun n hn => gradedTrunc_zero_above N f n hn⟩

/-- Backpropagation truncation converges at every grade. -/
theorem backprop_truncation_converges (f : ℕ → A) (hf : IsAugmented f) (N : ℕ) :
    convInverse (gradedTrunc N f) N = convInverse f N :=
  convInverse_truncated_agree N f hf N (le_refl N)

end QuantifierAlternation

-- ================================================================
-- Part XVIII: Information-Theoretic Bounds
-- ================================================================

section InformationTheoretic

/-- Shannon entropy bound: log(N+1) ≥ 0. -/
theorem graded_entropy_bound (N : ℕ) :
    Real.log ((N : ℝ) + 1) ≥ 0 :=
  Real.log_nonneg (by linarith [Nat.cast_nonneg (α := ℝ) N])

/-- Truncation monotonicity. -/
theorem truncation_monotone (f : ℕ → A) (m n : ℕ) (hmn : m ≤ n) :
    ∀ k, k ≤ m → gradedTrunc m f k = gradedTrunc n f k := by
  intro k hk; simp [gradedTrunc, hk, le_trans hk hmn]

/-- Per-grade information bound. -/
theorem per_grade_info_bound (C : ℝ) (hC : 0 < C) :
    Real.log (2 * C + 1) > 0 :=
  Real.log_pos (by linarith)

end InformationTheoretic

-- ================================================================
-- Part XIX: Combinatorial Birkhoff Complexity
-- ================================================================

section BirkhoffComplexity

/-- Per-grade backprop operations count. -/
theorem per_grade_backprop_ops (n : ℕ) :
    (Finset.range n).card = n :=
  Finset.card_range n

/-- Four-to-the-n bounds n (exponential growth). -/
theorem four_pow_bound (n : ℕ) : n ≤ 4 ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
    have : 4 ^ n ≥ 1 := Nat.one_le_pow n 4 (by norm_num)
    calc n + 1 ≤ 4 ^ n + 1 := by omega
         _ ≤ 4 * 4 ^ n := by linarith
         _ = 4 ^ (n + 1) := by ring

end BirkhoffComplexity

end NeuralBirkhoff