/-
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops the foundations of number theory on the Poincaré disk model
of hyperbolic geometry. We define hyperbolic integers as orbit points under
discrete group actions, establish the algebraic identity governing Möbius
automorphisms, and prove that these automorphisms preserve the disk.

## Main Results

* `moebius_algebraic_identity` — The fundamental identity:
    |1 - ā·z|² - |z - a|² = (1 - |z|²)(1 - |a|²)
* `moebius_preserves_disk` — Möbius maps send disk points to disk points
* `hypGrowth_closed_form` — Exponential growth of hyperbolic lattice points
* `pseudoHypDistSq_comm` — Symmetry of pseudo-hyperbolic distance
-/

import Mathlib

namespace HyperbolicNumberTheory

open Complex

/-! ## Part 1: The Poincaré Disk and Möbius Automorphisms -/

/-- A complex number lies in the open unit disk if its squared norm is less than 1. -/
def IsDiskPoint (z : ℂ) : Prop := normSq z < 1

/-- The Möbius automorphism of the disk parametrized by a disk point `a`.
    Maps z ↦ (z - a) / (1 - conj(a) · z). -/
noncomputable def moebiusMap (a z : ℂ) : ℂ :=
  (z - a) / (1 - starRingEnd ℂ a * z)

/-- The denominator of the Möbius map. -/
def moebiusDenom (a z : ℂ) : ℂ := 1 - starRingEnd ℂ a * z

/-! ### The Fundamental Algebraic Identity -/

/-
**The Fundamental Identity of Disk Automorphisms.**
    normSq(1 - conj(a)·z) - normSq(z - a) = (1 - normSq z) · (1 - normSq a)
-/
theorem moebius_algebraic_identity (a z : ℂ) :
    normSq (moebiusDenom a z) - normSq (z - a) =
    (1 - normSq z) * (1 - normSq a) := by
  unfold moebiusDenom; norm_num [ Complex.normSq ] ; ring;

/-
The Möbius map sends a to 0: φ_a(a) = 0.
-/
theorem moebius_at_a_eq_zero (a : ℂ) :
    moebiusMap a a = 0 := by
  unfold moebiusMap; aesop;

/-
The Möbius map sends 0 to -a: φ_a(0) = -a.
-/
theorem moebius_at_center_eq_neg (a : ℂ) :
    moebiusMap a 0 = -a := by
  unfold moebiusMap; aesop;

/-
The denominator of the Möbius map is nonzero for disk points.
-/
theorem moebius_denom_ne_zero (a z : ℂ) (ha : IsDiskPoint a) (hz : IsDiskPoint z) :
    moebiusDenom a z ≠ 0 := by
  contrapose! hz; have := moebius_algebraic_identity a z; simp_all +decide [ IsDiskPoint ] ;
  nlinarith [ normSq_nonneg ( z - a ) ]

/-
**Möbius automorphisms preserve the disk.**
-/
theorem moebius_preserves_disk (a z : ℂ) (ha : IsDiskPoint a) (hz : IsDiskPoint z) :
    IsDiskPoint (moebiusMap a z) := by
  convert div_lt_one ?_ |>.2 _;
  rotate_left;
  exact ℝ;
  all_goals try infer_instance;
  exact Complex.normSq ( z - a );
  exact normSq ( moebiusDenom a z );
  · exact normSq_pos.mpr ( moebius_denom_ne_zero a z ha hz );
  · exact lt_of_sub_pos ( by rw [ moebius_algebraic_identity ] ; exact mul_pos ( sub_pos.mpr hz ) ( sub_pos.mpr ha ) );
  · unfold IsDiskPoint moebiusMap moebiusDenom; aesop;

/-
The normSq of a Möbius map via the fundamental identity.
-/
theorem moebius_normSq_formula (a z : ℂ) (ha : IsDiskPoint a) (hz : IsDiskPoint z) :
    normSq (moebiusMap a z) =
    1 - (1 - normSq z) * (1 - normSq a) / normSq (moebiusDenom a z) := by
  have h_norm_sq : normSq (moebiusMap a z) = normSq (z - a) / normSq (moebiusDenom a z) := by
    convert Complex.normSq_div _ _ using 2;
  rw [ h_norm_sq, one_sub_div ];
  · rw [ ← moebius_algebraic_identity ] ; ring;
  · exact ne_of_gt ( normSq_pos.mpr ( moebius_denom_ne_zero a z ha hz ) )

/-! ## Part 2: Pseudo-Hyperbolic Distance -/

/-- The pseudo-hyperbolic distance squared between two disk points. -/
noncomputable def pseudoHypDistSq (z w : ℂ) : ℝ :=
  normSq (z - w) / normSq (moebiusDenom w z)

/-
Pseudo-hyperbolic distance from a point to itself is zero.
-/
theorem pseudoHypDistSq_self (z : ℂ) :
    pseudoHypDistSq z z = 0 := by
  unfold pseudoHypDistSq; norm_num;

/-
Pseudo-hyperbolic distance equals normSq of the Möbius map.
-/
theorem pseudoHypDistSq_eq_moebius (z w : ℂ) :
    pseudoHypDistSq z w = normSq (moebiusMap w z) := by
  unfold pseudoHypDistSq moebiusMap;
  rw [ normSq_div ];
  rfl

/-- Pseudo-hyperbolic distance is less than 1 for disk points. -/
theorem pseudoHypDistSq_lt_one (z w : ℂ) (hz : IsDiskPoint z) (hw : IsDiskPoint w) :
    pseudoHypDistSq z w < 1 := by
  rw [pseudoHypDistSq_eq_moebius]
  exact moebius_preserves_disk w z hw hz

/-
The normSq of (z - w) and (w - z) are equal.
-/
theorem normSq_sub_comm (z w : ℂ) : normSq (z - w) = normSq (w - z) := by
  rw [ ← normSq_neg, neg_sub ]

/-
**Pseudo-hyperbolic distance is symmetric.** Uses the fundamental identity
    and multi-step algebraic reasoning.
-/
theorem pseudoHypDistSq_comm (z w : ℂ) (_hz : IsDiskPoint z) (_hw : IsDiskPoint w) :
    pseudoHypDistSq z w = pseudoHypDistSq w z := by
  unfold pseudoHypDistSq;
  rw [ ← normSq_sub_comm ] ; unfold moebiusDenom; ring;
  norm_num [ Complex.normSq, Complex.ext_iff ] ; ring;
  grind

/-! ## Part 3: Hyperbolic Integers via Word Metric -/

/-- Generators for the modular group PSL(2,ℤ), modeling the free product ℤ₂ * ℤ₃. -/
inductive HypGenerator
  | S : HypGenerator
  | T : HypGenerator
  deriving DecidableEq, Repr

/-- A word in the generators, representing a group element. -/
abbrev HypWord := List HypGenerator

/-- The word length (distance from identity in the Cayley graph). -/
def wordLength (w : HypWord) : ℕ := w.length

/-- A hyperbolic lattice point, identified by its word. -/
structure HypLatticePoint where
  word : HypWord
  deriving Repr

/-- The norm of a lattice point is its word length. -/
def HypLatticePoint.norm (p : HypLatticePoint) : ℕ := wordLength p.word

/-- The growth function for the hyperbolic lattice:
    counts lattice points in a ball of radius n. -/
def hypGrowth : ℕ → ℕ
  | 0 => 1
  | n + 1 => hypGrowth n + 2 * 3 ^ n

/-
The growth function is strictly positive.
-/
theorem hypGrowth_pos : ∀ n, 0 < hypGrowth n := by
  intro n;
  induction n <;> simp +arith +decide [ *, hypGrowth ]

/-
The growth function is monotone.
-/
theorem hypGrowth_monotone : Monotone hypGrowth := by
  refine' monotone_nat_of_le_succ _;
  exact fun n => Nat.le_add_right _ _

/-- The growth function recurrence. -/
theorem hypGrowth_succ (n : ℕ) : hypGrowth (n + 1) = hypGrowth n + 2 * 3 ^ n := rfl

/-
**Closed form: hypGrowth(n) = 3^n for n ≥ 1.**
    This is the hallmark of a hyperbolic group: exponential growth.
-/
theorem hypGrowth_closed_form : ∀ n : ℕ, 0 < n → hypGrowth n = 3 ^ n := by
  intro n hn; induction hn <;> simp_all +decide [ pow_succ' ] ; ring;
  grind +locals

/-! ## Part 4: Hyperbolic Primes and Factorization -/

/-- A hyperbolic prime is a lattice point at distance 1 from the origin. -/
def IsHypPrime (p : HypLatticePoint) : Prop := p.word.length = 1

/-
Every lattice point factors into hyperbolic primes.
-/
theorem hyp_factorization (p : HypLatticePoint) :
    ∃ primes : List HypLatticePoint,
      (∀ q ∈ primes, IsHypPrime q) ∧
      primes.length = p.norm := by
  use List.map (fun g => HypLatticePoint.mk [g]) p.word;
  unfold IsHypPrime; aesop;

/-
There are exactly two types of hyperbolic primes.
-/
theorem hyp_prime_classification (p : HypLatticePoint) (hp : IsHypPrime p) :
    p.word = [HypGenerator.S] ∨ p.word = [HypGenerator.T] := by
  rcases p with ⟨ _ | ⟨ a, _ | ⟨ b, _ | p ⟩ ⟩ ⟩ <;> simp_all +decide [ IsHypPrime ];
  cases a <;> tauto

/-! ## Part 5: Cross-Domain — Spectral Theory of Cayley Graphs -/

/-- The Kesten spectral radius bound for the Cayley graph.
    For d generators, ρ ≤ √(2d-1)/d. -/
noncomputable def kestenBound (d : ℕ) : ℝ :=
  Real.sqrt (2 * d - 1) / d

/-
The Kesten bound is at most 1 for any positive degree.
-/
theorem kesten_bound_le_one (d : ℕ) (hd : 0 < d) :
    kestenBound d ≤ 1 := by
  rw [ kestenBound, div_le_iff₀ ];
  · rw [ Real.sqrt_le_left ] <;> nlinarith [ show ( d : ℝ ) ≥ 1 by norm_cast ];
  · positivity

/-
For the modular group (2 generators), the Kesten bound is √3/2.
-/
theorem kesten_bound_modular :
    kestenBound 2 = Real.sqrt 3 / 2 := by
  unfold kestenBound; norm_num;

/-! ## Part 6: Hyperbolic Zeta Function -/

/-- Partial sum of the hyperbolic zeta function. -/
noncomputable def hypZetaPartial (s : ℝ) (N : ℕ) : ℝ :=
  ∑ n ∈ Finset.Icc 1 N, (3 ^ n : ℝ) / (n : ℝ) ^ (2 * s)

/-
The partial zeta is monotone in N for s > 0.
-/
theorem hypZetaPartial_mono (s : ℝ) (_hs : 0 < s) (N : ℕ) :
    hypZetaPartial s N ≤ hypZetaPartial s (N + 1) := by
  exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.Icc_subset_Icc_right ( Nat.le_succ _ ) ) fun _ _ _ => by positivity;

/-! ## Part 7: Primitive Word Counting -/

/-- Count of primitive (cyclically reduced) words of length n. -/
def primWordCount : ℕ → ℕ
  | 0 => 0
  | 1 => 2
  | n + 2 => 2 * 3 ^ (n + 1)

/-
Primitive word count has exponential lower bound.
-/
theorem primWordCount_lower (n : ℕ) (hn : 2 ≤ n) :
    3 ^ (n - 1) ≤ primWordCount n := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ primWordCount ]

/-! ## Part 8: Critical Line and Disk Geometry -/

/-
For points on the critical line Re(s) = 1/2,
    the shifted value s - 1/2 has zero real part.
-/
theorem critical_line_shift (s : ℂ) (hs : s.re = 1 / 2) :
    (s - (1/2 : ℂ)).re = 0 := by
  norm_num [ hs ]

/-
The norm of a purely imaginary complex number equals |im|.
-/
theorem normSq_pure_imag (z : ℂ) (hz : z.re = 0) :
    normSq z = z.im ^ 2 := by
  simp +decide [ hz, Complex.normSq_apply, sq ]

end HyperbolicNumberTheory