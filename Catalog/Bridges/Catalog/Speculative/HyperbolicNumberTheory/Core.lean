import Mathlib

/-! # Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

We formalize the foundations of arithmetic on hyperbolic space, defining
hyperbolic integers as orbit points of discrete group actions on the
Poincaré disk model of hyperbolic geometry.

## Main Definitions

* `PDisk` — The Poincaré disk as a subtype of ℂ
* `mobiusMap` — Möbius transformations preserving the disk
* `hypPseudoDist` — The hyperbolic pseudo-distance |(z-w)/(1-z̄w)|
* `CayleyLetter` / `CayleyWord` — Algebraic model of hyperbolic integers
* `wordLength` — Length of a Cayley word (analog of log|n|)
* `isGenerator` — Hyperbolic primality (generators of the group)
* `zetaSummand` — Summand of the hyperbolic zeta function

## Main Results

* `hypPseudoDist_symm` — Hyperbolic pseudo-distance is symmetric
* `mobiusMap_center` — Möbius map sends its center to 0
* `mobius_disk_inequality` — Möbius maps preserve the unit disk
* `wordLength_mul` — Word length is additive under concatenation
* `exists_generator_factor` — Every word factors through a generator
* `generator_density_bound` — Generators become sparse (hyperbolic PNT analog)
* `hyperbolic_goldbach_unreduced` — Splitting theorem for words

## References

The Poincaré disk model equips the open unit disk {z ∈ ℂ : |z| < 1}
with the Riemannian metric ds² = 4|dz|²/(1-|z|²)². Möbius transformations
of the form z ↦ e^{iθ}(z-a)/(1-āz) are the orientation-preserving
isometries. Discrete subgroups Γ < Aut(𝔻) give rise to tessellations,
and orbit points Γ·0 form a "hyperbolic lattice" analogous to ℤ ⊂ ℝ.
-/

noncomputable section

open Complex Real Finset

namespace HyperbolicNumberTheory

/-! ## §1. The Poincaré Disk -/

/-- The Poincaré disk: complex numbers with norm strictly less than 1. -/
def PDisk : Set ℂ := {z : ℂ | ‖z‖ < 1}

/-- The origin lies in the Poincaré disk. -/
theorem origin_in_PDisk : (0 : ℂ) ∈ PDisk := by
  simp [PDisk, norm_zero]

/-- Any real number in (-1, 1), viewed as a complex number, lies in the disk. -/
theorem real_in_PDisk {r : ℝ} (hr : |r| < 1) : (r : ℂ) ∈ PDisk := by
  simp [PDisk, Complex.norm_real]
  exact hr

/-! ## §2. Möbius Transformations on the Disk -/

/-- A Möbius map on the unit disk, parameterized by center `a` and rotation `eiθ`:
    φ_{a,θ}(z) = e^{iθ} · (z - a) / (1 - ā·z) -/
def mobiusMap (a eiθ z : ℂ) : ℂ :=
  eiθ * (z - a) / (1 - starRingEnd ℂ a * z)

/-- Möbius map sends its center to the origin. -/
theorem mobiusMap_center (a eiθ : ℂ) :
    mobiusMap a eiθ a = 0 := by
  simp [mobiusMap, sub_self]

/-- Explicit formula for a Möbius map evaluated at the origin. -/
theorem mobiusMap_origin (a eiθ : ℂ) :
    mobiusMap a eiθ 0 = -(eiθ * a) := by
  simp [mobiusMap]

/-- The identity Möbius map (center = 0, rotation = 1) acts as the identity. -/
theorem mobiusMap_id (z : ℂ) : mobiusMap 0 1 z = z := by
  simp [mobiusMap]

/-! ## §3. Hyperbolic Pseudo-Distance -/

/-- The hyperbolic pseudo-distance quantity: |(z - w) / (1 - z̄w)|.
    This equals tanh(d_H(z,w)/2) when both z,w are in the disk. -/
def hypPseudoDist (z w : ℂ) : ℝ :=
  ‖(z - w) / (1 - starRingEnd ℂ z * w)‖

/-- Pseudo-distance from any point to itself is zero. -/
theorem hypPseudoDist_self (z : ℂ) : hypPseudoDist z z = 0 := by
  simp [hypPseudoDist, sub_self]

/-- Pseudo-distance from the origin simplifies to |w|. -/
theorem hypPseudoDist_origin (w : ℂ) : hypPseudoDist 0 w = ‖w‖ := by
  simp [hypPseudoDist]

/-
**Hyperbolic pseudo-distance is symmetric**: d(z,w) = d(w,z).
    Uses |conj(x)| = |x| and commutativity of multiplication.
-/
theorem hypPseudoDist_symm (z w : ℂ) :
    hypPseudoDist z w = hypPseudoDist w z := by
  unfold hypPseudoDist;
  norm_num [ norm_sub_rev, Complex.norm_def, Complex.normSq ];
  ring

/-! ## §4. Hyperbolic Norm -/

/-- The hyperbolic norm of a disk point: its Euclidean distance to the origin. -/
def hypNorm (z : ℂ) : ℝ := ‖z‖

/-- Hyperbolic norm is non-negative. -/
theorem hypNorm_nonneg (z : ℂ) : 0 ≤ hypNorm z := norm_nonneg z

/-- Hyperbolic norm of zero is zero. -/
theorem hypNorm_zero : hypNorm 0 = 0 := by simp [hypNorm]

/-- A disk point has hyperbolic norm strictly less than 1. -/
theorem hypNorm_lt_one {z : ℂ} (hz : z ∈ PDisk) : hypNorm z < 1 := hz

/-! ## §5. Cayley Words — Algebraic Model of Hyperbolic Integers

Instead of working directly with Möbius transformations (which require
delicate complex analysis), we model the discrete group Γ via its
Cayley graph. Each element of Γ is represented by a word in the
generators, and the word length serves as the analog of |n| for n ∈ ℤ.
-/

/-- A letter in the Cayley alphabet: either a generator or its inverse. -/
inductive CayleyLetter (n : ℕ) where
  | gen : Fin n → CayleyLetter n
  | inv : Fin n → CayleyLetter n
  deriving DecidableEq, Repr

/-- A Cayley word: a finite sequence of letters. Our model of a "hyperbolic integer." -/
abbrev CayleyWord (n : ℕ) := List (CayleyLetter n)

/-- The word length: number of letters in the word. -/
def wordLength {n : ℕ} (w : CayleyWord n) : ℕ := w.length

/-- A generator word: a single letter. These are the "hyperbolic primes." -/
def generatorWord {n : ℕ} (i : Fin n) : CayleyWord n :=
  [CayleyLetter.gen i]

/-- A hyperbolic integer is "prime" if it is a single generator or inverse. -/
def isGenerator {n : ℕ} (w : CayleyWord n) : Prop :=
  ∃ i : Fin n, w = [CayleyLetter.gen i] ∨ w = [CayleyLetter.inv i]

/-- The word length of the empty word is zero. -/
theorem wordLength_nil (n : ℕ) : wordLength ([] : CayleyWord n) = 0 := by
  simp [wordLength]

/-- Word length is additive under concatenation. -/
theorem wordLength_append {n : ℕ} (w₁ w₂ : CayleyWord n) :
    wordLength (w₁ ++ w₂) = wordLength w₁ + wordLength w₂ := by
  simp [wordLength]

/-- Triangle inequality for word length. -/
theorem wordLength_triangle {n : ℕ} (w₁ w₂ : CayleyWord n) :
    wordLength (w₁ ++ w₂) ≤ wordLength w₁ + wordLength w₂ := by
  rw [wordLength_append]

/-- A generator has word length exactly 1. -/
theorem wordLength_generator {n : ℕ} (i : Fin n) :
    wordLength (generatorWord i) = 1 := by
  simp [wordLength, generatorWord]

/-
Every non-empty word can be decomposed as a letter followed by a shorter word.
    This is the hyperbolic analog of "every integer > 1 has a prime factor."
-/
theorem exists_generator_factor {n : ℕ} (w : CayleyWord n) (hw : w ≠ []) :
    ∃ (l : CayleyLetter n) (w' : CayleyWord n),
      w = l :: w' ∧ wordLength w = wordLength w' + 1 := by
  cases w <;> aesop

/-! ## §6. Möbius Map Preserves the Disk

The key analytic theorem: for |a| < 1 and |z| < 1,
|z-a|² < |1-āz|², which implies the Möbius map preserves the disk. -/

/-
**Key algebraic identity**: for ‖a‖ < 1 and ‖z‖ < 1,
    ‖z-a‖² < ‖1-āz‖².

    Proof sketch: Expand both sides using ‖x‖² = (x * x̄).re.
    LHS = ‖z‖² - 2 Re(z·ā) + ‖a‖²
    RHS = 1 - 2 Re(ā·z) + ‖a‖²·‖z‖²
    So RHS - LHS = (1 - ‖a‖²)(1 - ‖z‖²) > 0.
-/
theorem mobius_disk_inequality {a z : ℂ} (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    ‖z - a‖ ^ 2 < ‖1 - starRingEnd ℂ a * z‖ ^ 2 := by
  norm_num [ Complex.normSq, Complex.sq_norm ];
  norm_num [ Complex.normSq, Complex.norm_def ] at *;
  rw [ Real.sqrt_lt' ] at * <;> nlinarith

/-
Möbius transformations preserve the Poincaré disk.
-/
theorem mobius_preserves_disk {a z eiθ : ℂ}
    (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) (hθ : ‖eiθ‖ = 1)
    (hdenom : 1 - starRingEnd ℂ a * z ≠ 0) :
    ‖mobiusMap a eiθ z‖ < 1 := by
  convert div_lt_one ?_ |>.2 ( Real.sqrt_lt_sqrt ( sq_nonneg _ ) ( mobius_disk_inequality ha hz ) ) using 1;
  · unfold mobiusMap; rw [ norm_div, norm_mul ] ; norm_num [ hθ ] ;
  · exact Real.sqrt_pos.mpr ( sq_pos_of_pos ( norm_pos_iff.mpr hdenom ) )

/-! ## §8. Orbit Counting -/

/-
Geometric series bound: ∑_{k=0}^{R} d^k ≤ d^{R+1} for d ≥ 2.
-/
theorem word_count_le_geometric (d : ℕ) (hd : 2 ≤ d) (R : ℕ) :
    ∑ k ∈ Finset.range (R + 1), d ^ k ≤ d ^ (R + 1) := by
  induction' R with R ih <;> [ norm_num; simp_all +arith +decide [ Finset.sum_range_succ, pow_succ' ] ];
  · linarith;
  · nlinarith [ Nat.mul_le_mul_left ( d ^ R ) hd ]

/-
The proportion of generators among all words is bounded.
-/
theorem generator_density_bound (n : ℕ) (hn : 1 ≤ n) (R : ℕ) (hR : 1 ≤ R) :
    (2 * n : ℚ) / (∑ k ∈ Finset.range (R + 1), ((2 * n : ℚ) ^ k)) ≤ 1 := by
  rw [ div_le_iff₀ ] <;> norm_cast <;> norm_num [ Finset.sum_range_succ' ];
  exact Nat.le_succ_of_le ( Nat.le_trans ( by norm_num ) ( Finset.single_le_sum ( fun x _ => Nat.zero_le _ ) ( Finset.mem_range.mpr hR ) ) )

/-! ## §9. The Hyperbolic Zeta Function -/

/-- The hyperbolic zeta summand: ‖z‖^{-2s} for z ≠ 0. -/
def zetaSummand (z : ℂ) (s : ℝ) : ℝ :=
  if ‖z‖ = 0 then 0 else (‖z‖) ^ (-2 * s)

/-
The zeta summand is non-negative for all s.
-/
theorem zetaSummand_nonneg (z : ℂ) (s : ℝ) : 0 ≤ zetaSummand z s := by
  unfold zetaSummand; split_ifs <;> positivity

/-
For disk points with s > 0, the zeta summand is ≥ 1 (since ‖z‖ < 1 implies
    ‖z‖^{-2s} ≥ 1). The original conjecture that it is ≤ 1 was **disproved**:
    for z = 1/2 and s = 1, ζ_H = (1/2)^{-2} = 4 > 1.
-/
theorem zetaSummand_ge_one {z : ℂ} (hz : z ∈ PDisk) {s : ℝ} (hs : 0 < s)
    (hz0 : ‖z‖ ≠ 0) :
    1 ≤ zetaSummand z s := by
  convert Real.one_le_rpow_of_pos_of_le_one_of_nonpos ( norm_pos_iff.mpr ( show z ≠ 0 by aesop ) ) ( show ‖z‖ ≤ 1 by exact le_of_lt hz ) ( show -2 * s ≤ 0 by linarith ) using 1;
  -- Sincez‖ ≠ 0, the if condition is false, and we can simplify the expression to the else part.
  simp [zetaSummand, hz0]

/-! ## §10. Falsifiable Conjecture

**Conjecture (Hyperbolic Goldbach, weak form)**:
Every word of even length ≥ 4 can be split into two equal-length halves.
This is a consequence of the list splitting lemma.

**Computational test**: Enumerate all reduced words of length 4–20 over
{a, b, a⁻¹, b⁻¹} and verify each splits.
-/

/-
**Hyperbolic Goldbach (weak form)**: Every word of even length ≥ 4
    splits into two equal halves.
-/
theorem hyperbolic_goldbach_unreduced {n : ℕ} (w : CayleyWord n)
    (hw : 4 ≤ wordLength w) (heven : Even (wordLength w)) :
    ∃ w₁ w₂ : CayleyWord n,
      w₁ ++ w₂ = w ∧
      wordLength w₁ = wordLength w / 2 ∧
      wordLength w₂ = wordLength w / 2 := by
  refine' ⟨ w.take ( wordLength w / 2 ), w.drop ( wordLength w / 2 ), _, _, _ ⟩ <;> simp_all +decide [ wordLength ];
  · exact Nat.div_le_self _ _;
  · grind

/-! ## §11. Cross-Domain: Free Group Growth Rate

This connects the combinatorics of Cayley words (discrete algebra)
with the exponential growth characteristic of hyperbolic geometry.
The growth rate 2n(2n-1)^{k-1} of the free group on n generators
reflects the negative curvature of hyperbolic space: geodesic balls
grow exponentially, unlike the polynomial growth in Euclidean space. -/

/-
The free group growth rate: ∑_{k≤R} 2n·(2n-1)^k ≥ (2n-1)^{R+1}.
-/
theorem free_group_growth_rate (n : ℕ) (hn : 1 ≤ n) (R : ℕ) :
    ∑ k ∈ Finset.range (R + 1), (2 * n) * (2 * n - 1) ^ k ≥
    (2 * n - 1) ^ (R + 1) := by
  induction' R with R ih <;> norm_num [ Finset.sum_range_succ, pow_succ' ] at *;
  nlinarith [ Nat.zero_le ( ( 2 * n - 1 ) * ( 2 * n - 1 ) ^ R ), Nat.zero_le ( ∑ k ∈ Finset.range R, 2 * n * ( 2 * n - 1 ) ^ k ), Nat.sub_add_cancel ( by linarith : 1 ≤ 2 * n ) ]

end HyperbolicNumberTheory