import Mathlib

/-!
# Diophantine Cryptography Core: Berggren Descent One-Way Functions and Quadratic Form Preservation

## Overview

We establish the algebraic foundations for Diophantine cryptography by proving that the
three Berggren matrices preserve the Minkowski quadratic form Q(a,b,c) = a² + b² - c²,
lie in GL₃(ℤ) (with det = ±1), and that their word products grow at least linearly.

These results connect three mathematical domains:
- **Number theory**: Pythagorean triples and quadratic forms
- **Linear algebra**: Matrix groups and spectral theory
- **Cryptography**: One-way functions and collision resistance

## Main Results

* `berggren_quadratic_form_invariant` — each generator preserves Q = a² + b² - c²
* `berggren_word_quadratic_form_invariant` — word products preserve Q (by induction)
* `berggren_det_isUnit` — each generator has unit determinant (lies in GL₃(ℤ))
* `berggren_word_matrix_isUnit` — word products are invertible
* `berggren_children_pairwise_distinct` — distinct generators yield distinct children
* `berggren_word_action_free` — the Berggren monoid acts freely (injectivity)
* `berggren_hyp_strict_increase` — hypotenuse grows with each generator application
* `berggren_hyp_linear_growth` — word length gives linear lower bound on hypotenuse
* `berggren_hash_quadratic_check` — hash outputs satisfy the Pythagorean equation mod p
* `berggren_collision_mod_p` — collisions mod p imply componentwise divisibility
* `berggren_integral_collision_free` — no collisions over ℤ (freeness)
* `berggren_word_hyp_ge_five` — all triples have hypotenuse ≥ 5
* `berggren_descent_parent_unique_gen` — parent generator is uniquely determined
* `berggren_preserves_minkowski_metric` — Uᵀ J U = J (orthogonal group membership)
* `berggren_word_preserves_minkowski` — word products preserve Minkowski metric
-/

open Matrix Finset

set_option maxHeartbeats 1600000

/-! ## Section 1: Core Berggren Definitions

Bridge: connects free monoids (algebra) to matrix groups (representation theory). -/

/-- The three positive Berggren generators as 3×3 integer matrices.
    Generator 0 = U (left), 1 = A (middle), 2 = D (right).
    These generate all primitive Pythagorean triples from (3,4,5). -/
def BerggrenMat : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | ⟨0, _⟩ => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | ⟨1, _⟩ => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | ⟨2, _⟩ => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- A Berggren word: a finite sequence of generator indices in {0,1,2}. -/
abbrev BWord := List (Fin 3)

/-- The matrix product corresponding to a Berggren word.
    Bridge: connects free monoids (algebra) to matrix groups (representation theory). -/
def BWordMatrix : BWord → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | i :: w => BerggrenMat i * BWordMatrix w

/-- The root Pythagorean triple vector (3, 4, 5). -/
def rootVec : Fin 3 → ℤ := ![3, 4, 5]

/-- The triple obtained by applying a Berggren word to the root (3,4,5). -/
def BWordTriple (w : BWord) : Fin 3 → ℤ := BWordMatrix w *ᵥ rootVec

/-- A vector represents a positive Pythagorean triple. -/
def IsPosPythTriple (v : Fin 3 → ℤ) : Prop :=
  0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2 ∧ v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2

/-- The Minkowski quadratic form Q(a,b,c) = a² + b² - c².
    Bridge: connects quadratic forms (number theory) to Lorentz geometry (physics). -/
def minkowskiForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- Action of a single generator on a triple. -/
def actGen (g : Fin 3) (t : Fin 3 → ℤ) : Fin 3 → ℤ :=
  (BerggrenMat g).mulVec t

/-! ## Section 2: Word Matrix Algebra -/

/-- BWordMatrix is a monoid homomorphism: concatenation maps to multiplication.
    Bridge: connects free monoid structure to matrix multiplication. -/
theorem BWordMatrix_append (u v : BWord) :
    BWordMatrix (u ++ v) = BWordMatrix u * BWordMatrix v := by
  induction u with
  | nil => simp [BWordMatrix]
  | cons g u ih => simp only [List.cons_append, BWordMatrix, ih, mul_assoc]

/-- BWordMatrix of a singleton is the generator matrix. -/
@[simp] theorem BWordMatrix_singleton (i : Fin 3) :
    BWordMatrix [i] = BerggrenMat i := by
  simp [BWordMatrix, mul_one]

/-- BWordMatrix of the empty word is the identity. -/
@[simp] theorem BWordMatrix_nil : BWordMatrix [] = 1 := rfl

/-- BWordTriple relates to generator action. -/
theorem BWordTriple_cons (i : Fin 3) (w : BWord) :
    BWordTriple (i :: w) = actGen i (BWordTriple w) := by
  simp [BWordTriple, BWordMatrix, actGen, mulVec_mulVec]

/-- BWordTriple of the empty word is the root vector. -/
@[simp] theorem BWordTriple_nil : BWordTriple [] = rootVec := by
  simp [BWordTriple, BWordMatrix]

/-! ## Section 3: Quadratic Form Preservation

**Theorem**: Each Berggren matrix preserves the Minkowski quadratic form Q(a,b,c) = a² + b² - c².
This is the algebraic foundation for Pythagorean triple generation.

Bridge: connects quadratic form preservation (linear algebra) to Pythagorean triple
generation (number theory) and Lorentz symmetry (physics). -/

/-- Each Berggren matrix preserves the quadratic form Q(a,b,c) = a² + b² - c².
    This means U_i ∈ O(2,1; ℤ), the integral orthogonal group of the Minkowski form.
    Bridge: connects quadratic form preservation (linear algebra) to Lorentz symmetry (physics). -/
theorem berggren_quadratic_form_invariant (i : Fin 3) (v : Fin 3 → ℤ) :
    minkowskiForm (BerggrenMat i *ᵥ v) = minkowskiForm v := by
  simp only [minkowskiForm, mulVec, dotProduct, Fin.sum_univ_three]
  fin_cases i <;> simp [BerggrenMat] <;> ring

/-- Word products preserve the Minkowski quadratic form (by induction on word length).
    Bridge: connects monoid actions (algebra) to quadratic form theory (number theory). -/
theorem berggren_word_quadratic_form_invariant (w : BWord) (v : Fin 3 → ℤ) :
    minkowskiForm (BWordMatrix w *ᵥ v) = minkowskiForm v := by
  induction w with
  | nil => simp [BWordMatrix]
  | cons i w ih =>
    show minkowskiForm ((BerggrenMat i * BWordMatrix w) *ᵥ v) = _
    rw [← mulVec_mulVec, berggren_quadratic_form_invariant, ih]

/-- The root triple satisfies Q(3,4,5) = 0 (it's Pythagorean). -/
theorem root_minkowski_zero : minkowskiForm rootVec = 0 := by native_decide

/-- Every Berggren word triple satisfies the Pythagorean equation a² + b² = c².
    Bridge: connects Berggren tree structure to Pythagorean geometry. -/
theorem berggren_word_pythagorean (w : BWord) :
    (BWordTriple w 0) ^ 2 + (BWordTriple w 1) ^ 2 = (BWordTriple w 2) ^ 2 := by
  have h := berggren_word_quadratic_form_invariant w rootVec
  rw [root_minkowski_zero] at h
  simp only [minkowskiForm] at h
  unfold BWordTriple; linarith

/-! ## Section 4: Determinant and Invertibility

Bridge: connects matrix group theory (algebra) to post-quantum cryptographic hardness. -/

/-- Each Berggren matrix has unit determinant (det = ±1), hence lies in GL₃(ℤ).
    Bridge: connects Berggren generators to the general linear group over ℤ. -/
theorem berggren_det_isUnit (i : Fin 3) : IsUnit (BerggrenMat i).det := by
  fin_cases i <;> simp [BerggrenMat, Matrix.det_fin_three]

/-- Generator matrices are invertible (units in the matrix ring).
    Bridge: connects invertibility to cryptographic trapdoor structure. -/
theorem berggren_gen_isUnit (i : Fin 3) : IsUnit (BerggrenMat i) := by
  rw [Matrix.isUnit_iff_isUnit_det]; exact berggren_det_isUnit i

/-- Word products are invertible.
    Bridge: connects monoid homomorphisms to invertible transformations. -/
theorem berggren_word_matrix_isUnit (w : BWord) : IsUnit (BWordMatrix w) := by
  induction w with
  | nil => exact isUnit_one
  | cons i w ih => exact IsUnit.mul (berggren_gen_isUnit i) ih

/-! ## Section 5: Positivity Preservation

Bridge: connects order theory to Pythagorean geometry. -/

/-- Each generator preserves the positivity of Pythagorean triples.
    Bridge: connects Berggren tree closure to Pythagorean triple classification. -/
theorem berggren_gen_preserves_pos (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPosPythTriple t) : IsPosPythTriple (actGen g t) := by
  obtain ⟨h0, h1, h2, hpyth⟩ := ht
  refine ⟨?_, ?_, ?_, ?_⟩
  · fin_cases g <;> simp [actGen, BerggrenMat, mulVec, dotProduct, Fin.sum_univ_three] <;>
      nlinarith [sq_nonneg (t 0 - t 1)]
  · fin_cases g <;> simp [actGen, BerggrenMat, mulVec, dotProduct, Fin.sum_univ_three] <;>
      nlinarith [sq_nonneg (t 0 - t 1)]
  · fin_cases g <;> simp [actGen, BerggrenMat, mulVec, dotProduct, Fin.sum_univ_three] <;>
      nlinarith [sq_nonneg (t 0 - t 1)]
  · have := berggren_quadratic_form_invariant g t
    simp [actGen, minkowskiForm] at this ⊢; linarith

/-- The root vector is a positive Pythagorean triple. -/
theorem root_is_pos_pyth : IsPosPythTriple rootVec := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

/-- Every Berggren word triple is a positive Pythagorean triple.
    Bridge: connects induction on free monoids (algebra) to Pythagorean geometry (number theory). -/
theorem berggren_word_pos_pyth (w : BWord) : IsPosPythTriple (BWordTriple w) := by
  induction w with
  | nil => rw [BWordTriple_nil]; exact root_is_pos_pyth
  | cons g w ih => rw [BWordTriple_cons]; exact berggren_gen_preserves_pos g _ ih

/-! ## Section 6: Hypotenuse Growth and Depth Bounds

Bridge: connects exponential matrix growth (analysis) to computational hardness (cryptography). -/

/-- Each generator strictly increases the hypotenuse of a positive Pythagorean triple.
    Bridge: connects Berggren tree depth to triple size (number theory → cryptography). -/
theorem berggren_hyp_strict_increase (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPosPythTriple t) : t 2 < (actGen g t) 2 := by
  obtain ⟨h0, h1, h2, hpyth⟩ := ht
  fin_cases g <;> simp [actGen, BerggrenMat, mulVec, dotProduct, Fin.sum_univ_three] <;>
    nlinarith [sq_nonneg (t 0 - t 1)]

/-- The hypotenuse of any positive Pythagorean triple is at least 5.
    Bridge: connects the smallest Pythagorean triple (3,4,5) to universal bounds. -/
theorem pos_pyth_hyp_ge_five (t : Fin 3 → ℤ) (ht : IsPosPythTriple t) : 5 ≤ t 2 := by
  obtain ⟨h0, h1, h2, hpyth⟩ := ht
  by_contra hlt; push_neg at hlt
  have ht2 : t 2 ≤ 4 := by omega
  have ht0 : t 0 ≤ 4 := by nlinarith [sq_nonneg (t 0 - t 2)]
  have ht1 : t 1 ≤ 4 := by nlinarith [sq_nonneg (t 1 - t 2)]
  interval_cases (t 0) <;> interval_cases (t 1) <;> interval_cases (t 2) <;> omega

/-- The hypotenuse of any Berggren word triple is at least 5. -/
theorem berggren_word_hyp_ge_five (w : BWord) : 5 ≤ BWordTriple w 2 :=
  pos_pyth_hyp_ge_five _ (berggren_word_pos_pyth w)

/-- Each generator increases hypotenuse by at least 2 on positive Pythagorean triples.
    Bridge: connects tree growth (combinatorics) to post-quantum security parameters. -/
theorem berggren_hyp_increase_by_two (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPosPythTriple t) : t 2 + 2 ≤ (actGen g t) 2 := by
  obtain ⟨h0, h1, h2, hpyth⟩ := ht
  fin_cases g <;> simp [actGen, BerggrenMat, mulVec, dotProduct, Fin.sum_univ_three] <;>
    nlinarith [sq_nonneg (t 0 - t 1)]

/-- The hypotenuse grows linearly with word length: hyp(w) ≥ 5 + 2·|w|.
    Bridge: connects tree depth (combinatorics) to one-way function hardness (cryptography). -/
theorem berggren_hyp_linear_growth (w : BWord) :
    (5 : ℤ) + 2 * w.length ≤ BWordTriple w 2 := by
  induction w with
  | nil => simp [BWordTriple, BWordMatrix, rootVec]
  | cons g w ih =>
    rw [BWordTriple_cons]
    have hinc := berggren_hyp_increase_by_two g (BWordTriple w) (berggren_word_pos_pyth w)
    simp [List.length_cons]; linarith

/-- Word length is bounded by the hypotenuse: |w| ≤ (hyp - 5) / 2.
    Bridge: connects tree depth (combinatorics) to search complexity (post-quantum crypto). -/
theorem berggren_word_length_bound (w : BWord) :
    (w.length : ℤ) ≤ (BWordTriple w 2 - 5) / 2 := by
  have h := berggren_hyp_linear_growth w; omega

/-! ## Section 7: Freeness and Collision Resistance

Bridge: connects free monoid actions (algebra) to collision-resistant hashing (cryptography). -/

/-- Generator action is injective: each matrix is invertible on triples.
    Bridge: connects matrix invertibility to one-way function trapdoor structure. -/
theorem actGen_injective (g : Fin 3) : Function.Injective (actGen g) :=
  mulVec_injective_of_isUnit (berggren_gen_isUnit g)

/-- The root vector is never the output of a generator on a positive triple.
    Bridge: the root (3,4,5) is the unique fixed point of the descent function. -/
theorem actGen_ne_root (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPosPythTriple t) : actGen g t ≠ rootVec := by
  intro h
  have hinc := berggren_hyp_strict_increase g t ht
  have hge5 := pos_pyth_hyp_ge_five t ht
  have : (actGen g t) 2 = 5 := by
    have := congr_fun h 2; simp [rootVec] at this; exact this
  linarith

/-- The generator is uniquely determined by the output on positive triples.
    If U_i · t₁ = U_j · t₂ with positive triples, then i = j.
    Bridge: connects uniqueness of descent (combinatorics) to one-way function injectivity
    (post-quantum cryptography). -/
theorem berggren_descent_parent_unique_gen {g₁ g₂ : Fin 3} {t₁ t₂ : Fin 3 → ℤ}
    (ht₁ : IsPosPythTriple t₁) (ht₂ : IsPosPythTriple t₂)
    (h : actGen g₁ t₁ = actGen g₂ t₂) : g₁ = g₂ := by
  fin_cases g₁ <;> fin_cases g₂ <;> simp +decide [IsPosPythTriple] at *
  all_goals (unfold actGen at h; simp_all +decide [funext_iff, Fin.forall_fin_succ])
  all_goals (unfold BerggrenMat at h; simp_all +decide [mulVec])
  all_goals (norm_num [vecHead, vecTail] at *; nlinarith)

/-- **Freeness theorem**: The Berggren word evaluation on (3,4,5) is injective.
    Distinct words yield distinct primitive triples: the Berggren monoid acts freely.

    Bridge: connects free monoid actions (algebra) to collision-resistant hashing (cryptography).
    This is the INTEGRAL collision resistance: no collisions exist over ℤ.

    Proof: By induction on word structure. Non-root triples can only come from generator
    applications, and the generator is uniquely determined. -/
theorem berggren_word_action_free :
    Function.Injective BWordTriple := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h
    match w₂ with
    | [] => rfl
    | g :: rest =>
      exfalso
      rw [BWordTriple_nil] at h
      rw [BWordTriple_cons] at h
      exact actGen_ne_root g (BWordTriple rest) (berggren_word_pos_pyth rest) h.symm
  | cons g₁ rest₁ ih =>
    intro w₂ h
    match w₂ with
    | [] =>
      exfalso
      rw [BWordTriple_nil] at h
      rw [BWordTriple_cons] at h
      exact actGen_ne_root g₁ (BWordTriple rest₁) (berggren_word_pos_pyth rest₁) h
    | g₂ :: rest₂ =>
      rw [BWordTriple_cons, BWordTriple_cons] at h
      have hg := berggren_descent_parent_unique_gen
        (berggren_word_pos_pyth rest₁) (berggren_word_pos_pyth rest₂) h
      subst hg
      exact congrArg (g₁ :: ·) (ih (actGen_injective g₁ h))

/-! ## Section 8: Children Distinctness

Bridge: connects ternary tree structure (combinatorics) to one-way function
properties (cryptography). -/

/-- Distinct Berggren generators applied to the same positive triple yield distinct children.
    Bridge: connects tree branching (combinatorics) to hash function injectivity (cryptography). -/
theorem berggren_children_pairwise_distinct (t : Fin 3 → ℤ)
    (ht : IsPosPythTriple t) (i j : Fin 3) (hij : i ≠ j) :
    actGen i t ≠ actGen j t := by
  intro h; exact hij (berggren_descent_parent_unique_gen ht ht h)

/-! ## Section 9: Modular Hash Function and Post-Quantum Collision Resistance

Bridge: connects Pythagorean triples (number theory) to cryptographic hashing (post-quantum crypto). -/

/-- The Berggren hash: H_p(w) = U_w · (3,4,5)^T mod p, as a function to ZMod p.
    Bridge: connects Pythagorean triples (number theory) to post-quantum hashing (cryptography). -/
def BerggrenHash (p : ℕ) (w : BWord) : Fin 3 → ZMod p :=
  fun i => (BWordTriple w i : ZMod p)

/-- The Berggren hash family: parameterized by a prime p ≥ 5.
    Bridge: post-quantum hash function built from Diophantine structure. -/
structure BerggrenHashFamily where
  /-- The modulus prime -/
  prime : ℕ
  /-- Primality witness -/
  hp : Nat.Prime prime
  /-- Minimum prime size for security -/
  hmin : 5 ≤ prime

/-- Hash evaluation for a hash family. -/
def BerggrenHashFamily.eval (H : BerggrenHashFamily) (w : BWord) : Fin 3 → ZMod H.prime :=
  BerggrenHash H.prime w

/-- The Berggren hash of the empty word is (3, 4, 5) mod p. -/
@[simp] theorem berggren_hash_nil (p : ℕ) :
    BerggrenHash p [] = fun i => (rootVec i : ZMod p) := by
  ext i; simp [BerggrenHash]

/-- If two words collide mod p, then p divides each component of their difference.
    Bridge: connects modular arithmetic to cryptographic collision analysis. -/
theorem berggren_collision_mod_p (p : ℕ) [hp : Fact (Nat.Prime p)] (w₁ w₂ : BWord)
    (hcoll : BerggrenHash p w₁ = BerggrenHash p w₂) :
    ∀ i : Fin 3, (p : ℤ) ∣ (BWordTriple w₁ i - BWordTriple w₂ i) := by
  intro i
  have hi : (BWordTriple w₁ i : ZMod p) = (BWordTriple w₂ i : ZMod p) := congr_fun hcoll i
  rw [← sub_eq_zero, ← Int.cast_sub, ZMod.intCast_zmod_eq_zero_iff_dvd] at hi
  exact hi

/-- Over ℤ, there are no collisions at all: if the triples match, the words match.
    Bridge: connects freeness of Berggren monoid to unconditional collision resistance. -/
theorem berggren_integral_collision_free (w₁ w₂ : BWord)
    (hcoll : BWordTriple w₁ = BWordTriple w₂) : w₁ = w₂ :=
  berggren_word_action_free hcoll

/-- If w₁ ≠ w₂, their triples differ over ℤ.
    Bridge: connects Berggren freeness to modular collision analysis. -/
theorem collision_nonzero_difference (w₁ w₂ : BWord) (hne : w₁ ≠ w₂) :
    BWordTriple w₁ ≠ BWordTriple w₂ :=
  fun h => hne (berggren_word_action_free h)

/-- The hash quadratic verification: hash outputs satisfy a² + b² ≡ c² (mod p).
    This provides a checksum for hash validity.
    Bridge: connects quadratic form verification to hash validity checking (cryptography). -/
theorem berggren_hash_quadratic_check (p : ℕ) (w : BWord) :
    ((BWordTriple w 0 : ZMod p) ^ 2 + (BWordTriple w 1 : ZMod p) ^ 2 : ZMod p) =
      (BWordTriple w 2 : ZMod p) ^ 2 := by
  have h := berggren_word_pythagorean w
  have : ((BWordTriple w 0 ^ 2 + BWordTriple w 1 ^ 2 : ℤ) : ZMod p) =
    ((BWordTriple w 2 ^ 2 : ℤ) : ZMod p) := congrArg _ h
  push_cast at this; exact this

/-- The Minkowski form evaluates to zero on all Berggren hash outputs mod p.
    Bridge: connects Minkowski geometry to hash function properties. -/
theorem berggren_hash_minkowski_zero (p : ℕ) (w : BWord) :
    ((BWordTriple w 0 : ZMod p) ^ 2 + (BWordTriple w 1 : ZMod p) ^ 2 -
     (BWordTriple w 2 : ZMod p) ^ 2 : ZMod p) = 0 := by
  rw [berggren_hash_quadratic_check]; ring

/-! ## Section 10: Descent Structure and One-Way Function

Bridge: connects tree descent (combinatorics) to one-way functions (post-quantum cryptography). -/

/-- Descent depth determines the minimum hypotenuse value: hyp ≥ 5 + 2k.
    Bridge: connects tree depth (combinatorics) to search hardness (post-quantum crypto). -/
theorem descent_depth_hyp_bound (w : BWord) :
    (5 : ℤ) + 2 * w.length ≤ BWordTriple w 2 :=
  berggren_hyp_linear_growth w

/-- The Berggren word evaluation is injective on words of any fixed length.
    Bridge: connects free monoid injectivity to collision resistance per depth level. -/
theorem berggren_fixed_length_injective (k : ℕ) :
    Function.Injective (fun w : {w : BWord // w.length = k} => BWordTriple w.val) := by
  intro ⟨w₁, _⟩ ⟨w₂, _⟩ h; exact Subtype.ext (berggren_word_action_free h)

/-! ## Section 11: Hash Family Configuration

Bridge: connects computational bounds (complexity theory) to post-quantum security (cryptography). -/

/-- Hash family configuration with security parameters.
    Bridge: connects universal hashing (cryptography) to modular arithmetic (number theory). -/
structure CryptoHashConfig where
  /-- The modulus prime -/
  modulus : ℕ
  /-- Primality witness -/
  isPrime : Nat.Prime modulus
  /-- Security parameter: minimum word length -/
  securityParam : ℕ
  /-- The modulus is at least 5 -/
  modulusGe5 : 5 ≤ modulus

/-- Evaluate the hash for a given config. -/
def CryptoHashConfig.hash (cfg : CryptoHashConfig) (w : BWord) : Fin 3 → ZMod cfg.modulus :=
  BerggrenHash cfg.modulus w

/-! ## Section 12: Minkowski Metric Preservation

Bridge: connects the transpose relation Uᵀ J U = J to orthogonal group theory and
Lorentz symmetry (physics). -/

/-- The Minkowski metric matrix J = diag(1,1,-1).
    Bridge: connects the Berggren tree to Lorentz geometry. -/
def minkowskiMetric : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Each Berggren matrix satisfies Uᵀ J U = J, i.e., preserves the Minkowski metric.
    This is equivalent to U ∈ O(2,1; ℤ), the integral indefinite orthogonal group.
    Bridge: connects orthogonal groups (algebra) to Lorentz symmetry (physics). -/
theorem berggren_preserves_minkowski_metric (i : Fin 3) :
    (BerggrenMat i)ᵀ * minkowskiMetric * BerggrenMat i = minkowskiMetric := by
  fin_cases i <;> simp [BerggrenMat, minkowskiMetric] <;> ext a b <;>
    fin_cases a <;> fin_cases b <;> simp [mul_apply, Fin.sum_univ_three, transpose_apply]

/-- Word products also preserve the Minkowski metric: (U_w)ᵀ J U_w = J.
    Bridge: connects SL₃(ℤ) subgroup structure to Lorentz invariance. -/
theorem berggren_word_preserves_minkowski (w : BWord) :
    (BWordMatrix w)ᵀ * minkowskiMetric * BWordMatrix w = minkowskiMetric := by
  induction w with
  | nil => simp [BWordMatrix]
  | cons i w ih =>
    simp only [BWordMatrix, transpose_mul]
    have key : (BWordMatrix w)ᵀ * (BerggrenMat i)ᵀ * minkowskiMetric *
        (BerggrenMat i * BWordMatrix w) =
      (BWordMatrix w)ᵀ * ((BerggrenMat i)ᵀ * minkowskiMetric * BerggrenMat i) *
        BWordMatrix w := by noncomm_ring
    rw [key, berggren_preserves_minkowski_metric, ih]

/-! ## Section 13: Concrete Computations for Verification -/

/-- The three children of (3,4,5) are (5,12,13), (21,20,29), (15,8,17).
    These are the first-level nodes of the Berggren tree. -/
theorem berggren_root_children :
    BWordTriple [0] = ![5, 12, 13] ∧
    BWordTriple [1] = ![21, 20, 29] ∧
    BWordTriple [2] = ![15, 8, 17] := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- The hypotenuses of the root's children are 13, 29, 17 — all distinct and > 5.
    Bridge: verifies the tree structure computationally. -/
theorem berggren_root_children_hyp :
    BWordTriple [0] 2 = 13 ∧ BWordTriple [1] 2 = 29 ∧ BWordTriple [2] 2 = 17 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- Second-generation triple: word [0,0] gives (7,24,25). -/
theorem berggren_depth_two_example :
    BWordTriple [0, 0] = ![7, 24, 25] := by native_decide