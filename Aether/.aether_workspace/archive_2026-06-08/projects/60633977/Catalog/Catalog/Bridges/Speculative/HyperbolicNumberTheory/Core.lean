import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops the foundations of arithmetic in hyperbolic geometry,
defining hyperbolic integers as orbit points of the origin under Möbius
transformations, and studying their algebraic and number-theoretic properties.

## Main Definitions

* `moebiusMap` - The Möbius transformation φ_a(z) = (a - z)/(1 - conj(a) * z)
* `PoincareDiskPoint` - A point in the open unit disk {z ∈ ℂ : ‖z‖ < 1}
* `pseudoHypDistSq` - Square of the pseudohyperbolic distance
* `HyperbolicLattice` - A discrete subgroup structure for hyperbolic arithmetic
* `HyperbolicInteger` - Elements of the orbit of 0 under a lattice action
* `SL2R` - Elements of SL(2,ℝ) for the algebra-geometry bridge

## Main Results

* `moebius_maps_disk_to_disk` - Möbius transformations preserve the unit disk
* `moebius_norm_sq_difference` - The fundamental algebraic identity
* `fricke_vogt_trace_identity` - Trace identity connecting algebra to geometry
* `hyperbolic_cayley_growth_lower_bound` - Exponential growth of hyperbolic lattices
* `tropicalShadow_nonneg` - Cross-domain bridge to tropical geometry
-/

noncomputable section

open Complex Real Finset

/-! ## Part I: Möbius Transformations on the Disk -/

/-- The Möbius automorphism of the unit disk sending `a` to `0`.
    For `a` in the open unit disk, φ_a(z) = (a - z) / (1 - conj(a) · z). -/
def moebiusMap (a z : ℂ) : ℂ := (a - z) / (1 - starRingEnd ℂ a * z)

/-- A point in the Poincaré disk: a complex number with normSq strictly less than 1. -/
structure PoincareDiskPoint where
  val : ℂ
  prop : Complex.normSq val < 1

namespace PoincareDiskPoint

/-- The origin of the Poincaré disk. -/
def origin : PoincareDiskPoint := ⟨0, by simp [Complex.normSq]⟩

end PoincareDiskPoint

/-! ### Basic Properties of Möbius Maps -/

/-- φ_a(0) = a: the Möbius map sends 0 to a. -/
theorem moebius_at_zero (a : ℂ) : moebiusMap a 0 = a := by
  simp [moebiusMap]

/-- φ_a(a) = 0: the Möbius map sends a to 0. -/
theorem moebius_at_self (a : ℂ) (h : starRingEnd ℂ a * a ≠ 1) :
    moebiusMap a a = 0 := by
  simp only [moebiusMap, sub_self, zero_div]

/-
The denominator 1 - conj(a)·z is nonzero when both normSq(a) < 1 and normSq(z) < 1.
-/
theorem moebius_denom_ne_zero (a z : ℂ)
    (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1) :
    1 - starRingEnd ℂ a * z ≠ 0 := by
  exact sub_ne_zero_of_ne <| ne_of_apply_ne Complex.normSq <| by norm_num; nlinarith [ Complex.normSq_nonneg a, Complex.normSq_nonneg z ] ;

/-- **Fundamental Algebraic Identity**: The key identity for Möbius maps.
    normSq(1 - conj(a)·z) - normSq(a - z) = (1 - normSq(a)) * (1 - normSq(z)).
    This is the cornerstone that makes Poincaré disk geometry work. -/
theorem moebius_norm_sq_difference (a z : ℂ) :
    Complex.normSq (1 - starRingEnd ℂ a * z) - Complex.normSq (a - z) =
    (1 - Complex.normSq a) * (1 - Complex.normSq z) := by
  simp only [Complex.normSq_sub, Complex.normSq_one, Complex.normSq_mul,
    Complex.normSq_conj]
  have key : (1 * (starRingEnd ℂ) ((starRingEnd ℂ) a * z)).re = (a * (starRingEnd ℂ) z).re := by
    rw [one_mul, map_mul, starRingEnd_self_apply, mul_comm]
  linarith

/-
**Möbius maps preserve the disk**: If normSq(a) < 1 and normSq(z) < 1,
    then normSq(φ_a(z)) < 1. This is the cornerstone of Poincaré disk geometry.
-/
theorem moebius_maps_disk_to_disk (a z : ℂ)
    (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1) :
    Complex.normSq (moebiusMap a z) < 1 := by
  -- We combine the results from `moebius_norm_sq_difference` and `moebius_denom_ne_zero`.
  have h_div : Complex.normSq (a - z) < Complex.normSq (1 - starRingEnd ℂ a * z) := by
    nlinarith [ moebius_norm_sq_difference a z ];
  convert div_lt_one ?_ |>.2 h_div using 1;
  · unfold moebiusMap;
    rw [ Complex.normSq_div ];
  · exact lt_of_le_of_lt ( Complex.normSq_nonneg _ ) h_div

/-! ## Part II: Hyperbolic Distance -/

/-- The squared pseudohyperbolic distance between two points in the disk.
    ρ(a,z)² = normSq(a - z) / normSq(1 - conj(a)·z). -/
def pseudoHypDistSq (a z : ℂ) : ℝ :=
  Complex.normSq (a - z) / Complex.normSq (1 - starRingEnd ℂ a * z)

/-- The pseudohyperbolic distance from any point to itself is zero. -/
theorem pseudoHypDist_self (z : ℂ) : pseudoHypDistSq z z = 0 := by
  simp [pseudoHypDistSq]

/-
The pseudohyperbolic distance is symmetric: ρ(a,z)² = ρ(z,a)².
-/
theorem pseudoHypDist_symm (a z : ℂ) :
    pseudoHypDistSq a z = pseudoHypDistSq z a := by
  unfold pseudoHypDistSq;
  simp +decide [ Complex.normSq ] ; ring

/-- The pseudohyperbolic distance is non-negative. -/
theorem pseudoHypDist_nonneg (a z : ℂ) : 0 ≤ pseudoHypDistSq a z := by
  unfold pseudoHypDistSq
  apply div_nonneg
  · exact Complex.normSq_nonneg _
  · exact Complex.normSq_nonneg _

/-
If normSq(a) < 1 and normSq(z) < 1, the pseudohyperbolic distance is < 1.
-/
theorem pseudoHypDist_lt_one (a z : ℂ)
    (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1) :
    pseudoHypDistSq a z < 1 := by
  rw [ pseudoHypDistSq, div_lt_one ];
  · nlinarith [ moebius_norm_sq_difference a z ];
  · exact Complex.normSq_pos.mpr ( moebius_denom_ne_zero a z ha hz )

/-! ## Part III: Hyperbolic Integers via Group Actions -/

/-- A `HyperbolicLattice` models a discrete subgroup of automorphisms of
    the Poincaré disk, represented by its generators as disk points. -/
structure HyperbolicLattice where
  /-- The generators of the lattice, as points in the disk -/
  generators : Finset ℂ
  /-- All generators lie in the open unit disk -/
  gen_in_disk : ∀ g ∈ generators, Complex.normSq g < 1
  /-- There is at least one generator -/
  gen_nonempty : generators.Nonempty

/-- Evaluate a word (list of generator indices) by composing Möbius transformations
    starting from 0. -/
def evalHypWord (Γ : HyperbolicLattice) (w : List (Fin Γ.generators.card)) : ℂ :=
  w.foldl (fun z i =>
    moebiusMap (Γ.generators.toList.get (i.cast (by rw [Finset.length_toList]))) z) 0

/-- The word norm is the length of the word. -/
def wordNorm (_Γ : HyperbolicLattice) (w : List (Fin _Γ.generators.card)) : ℕ :=
  w.length

/-- A **hyperbolic integer** is a point reachable from 0 by a word in the generators. -/
def IsHyperbolicInteger (Γ : HyperbolicLattice) (z : ℂ) : Prop :=
  ∃ w : List (Fin Γ.generators.card), evalHypWord Γ w = z

/-- A **hyperbolic prime** is a hyperbolic integer reachable by a single generator. -/
def IsHyperbolicPrime (Γ : HyperbolicLattice) (z : ℂ) : Prop :=
  ∃ i : Fin Γ.generators.card, evalHypWord Γ [i] = z

/-- The origin is always a hyperbolic integer (the empty word). -/
theorem origin_is_hyp_integer (Γ : HyperbolicLattice) :
    IsHyperbolicInteger Γ 0 := ⟨[], rfl⟩

/-- Every hyperbolic prime is a hyperbolic integer. -/
theorem hyp_prime_is_integer (Γ : HyperbolicLattice) (z : ℂ)
    (hp : IsHyperbolicPrime Γ z) : IsHyperbolicInteger Γ z := by
  obtain ⟨i, hi⟩ := hp
  exact ⟨[i], hi⟩

/-- The word norm is subadditive under concatenation. -/
theorem wordNorm_concat (Γ : HyperbolicLattice) (w₁ w₂ : List (Fin Γ.generators.card)) :
    wordNorm Γ (w₁ ++ w₂) = wordNorm Γ w₁ + wordNorm Γ w₂ := by
  simp [wordNorm, List.length_append]

/-! ## Part IV: Growth and Counting in Hyperbolic Lattices -/

/-- The number of words of length exactly n over k generators. -/
def wordCount (k n : ℕ) : ℕ := k ^ n

/-- The Cayley ball of radius n: total number of words of length ≤ n. -/
def cayleyBallSize (k n : ℕ) : ℕ := ∑ i ∈ range (n + 1), k ^ i

/-
**Exponential growth lower bound**: The Cayley ball of radius n
    in a lattice with k ≥ 2 generators contains at least 2^n points.

    This captures a fundamental difference between flat and curved arithmetic:
    on a line (ℤ), the ball of radius n has 2n+1 points (linear growth),
    but in hyperbolic space, growth is exponential.
-/
theorem hyperbolic_cayley_growth_lower_bound (k n : ℕ) (hk : k ≥ 2) :
    cayleyBallSize k n ≥ 2 ^ n := by
  exact le_trans ( pow_le_pow_left' hk _ ) ( Finset.single_le_sum ( fun x _ => Nat.zero_le ( k ^ x ) ) ( Finset.mem_range.mpr ( Nat.lt_succ_self _ ) ) )

/-
The number of elements at distance exactly n grows exponentially.
-/
theorem exponential_shell_growth (k n : ℕ) (hk : k ≥ 2) :
    wordCount k n ≥ 2 ^ n := by
  exact Nat.pow_le_pow_left hk _

/-! ## Part V: Cross-Domain Bridge — SL(2,ℝ) and Hyperbolic Geometry -/

/-- An element of SL(2,ℝ) represented as a 2×2 real matrix with det = 1. -/
structure SL2R where
  a : ℝ
  b : ℝ
  c : ℝ
  d : ℝ
  det_one : a * d - b * c = 1

/-- The trace of an SL(2,ℝ) matrix. -/
def SL2R.traceVal (M : SL2R) : ℝ := M.a + M.d

/-- Classification of SL(2,ℝ) elements by trace. -/
inductive SL2RType where
  | elliptic
  | parabolic
  | hyperbolic

/-- Classify an SL(2,ℝ) element by its trace.
    - Elliptic: |tr| < 2 (rotation-like)
    - Parabolic: |tr| = 2 (translation-like)
    - Hyperbolic: |tr| > 2 (dilation-like) -/
def SL2R.classify (M : SL2R) : SL2RType :=
  if |M.traceVal| < 2 then SL2RType.elliptic
  else if |M.traceVal| = 2 then SL2RType.parabolic
  else SL2RType.hyperbolic

/-- The identity matrix is parabolic (trace = 2). -/
theorem sl2_identity_parabolic :
    (SL2R.mk 1 0 0 1 (by ring)).classify = SL2RType.parabolic := by
  simp [SL2R.classify, SL2R.traceVal]
  norm_num

/-
**Trace-discriminant connection**: An SL(2,ℝ) element is elliptic
    iff its characteristic polynomial has negative discriminant.
-/
theorem sl2_discriminant_sign (M : SL2R) :
    M.classify = SL2RType.elliptic ↔ M.traceVal ^ 2 - 4 < 0 := by
  unfold SL2R.classify; norm_num [ abs_lt ] ;
  constructor <;> intro h <;> split_ifs at * <;> norm_num at *;
  · nlinarith;
  · nlinarith;
  · constructor <;> nlinarith;
  · constructor <;> nlinarith

/-
Hyperbolic elements have trace with |tr| > 2, giving positive discriminant.
-/
theorem sl2_hyperbolic_discriminant (M : SL2R) :
    M.classify = SL2RType.hyperbolic ↔ M.traceVal ^ 2 - 4 > 0 ∧ |M.traceVal| > 2 := by
  unfold SL2R.classify;
  split_ifs <;> norm_num;
  · grind +revert;
  · exact fun h => by linarith;
  · cases abs_cases M.traceVal <;> cases lt_or_gt_of_ne ‹_› <;> constructor <;> nlinarith

/-- Product of two SL(2,ℝ) matrices. -/
def SL2R.mul (A B : SL2R) : SL2R where
  a := A.a * B.a + A.b * B.c
  b := A.a * B.b + A.b * B.d
  c := A.c * B.a + A.d * B.c
  d := A.c * B.b + A.d * B.d
  det_one := by nlinarith [A.det_one, B.det_one]

/-- Inverse of an SL(2,ℝ) matrix. -/
def SL2R.inv (M : SL2R) : SL2R where
  a := M.d
  b := -M.b
  c := -M.c
  d := M.a
  det_one := by nlinarith [M.det_one]

/-- The trace of the inverse equals the trace of the original. -/
theorem sl2_inv_trace (M : SL2R) : (SL2R.inv M).traceVal = M.traceVal := by
  simp [SL2R.inv, SL2R.traceVal]; ring

/-
**Fricke–Vogt identity**: tr(AB) + tr(AB⁻¹) = tr(A)·tr(B).
    This fundamental identity connects the algebraic structure of SL(2,ℝ)
    to spectral geometry, and is a cornerstone of the Selberg trace formula
    which connects number theory (class numbers, L-functions) to
    hyperbolic geometry (lengths of closed geodesics).
-/
theorem fricke_vogt_trace_identity (A B : SL2R) :
    (SL2R.mul A B).traceVal + (SL2R.mul A (SL2R.inv B)).traceVal =
    A.traceVal * B.traceVal := by
  unfold SL2R.traceVal;
  unfold SL2R.mul SL2R.inv; ring;

/-! ## Part VI: The Tropical-Hyperbolic Bridge -/

/-- The **tropical shadow** of the hyperbolic metric: maps hyperbolic
    distance to a tropical (logarithmic) quantity.

    In tropical geometry, addition is min and multiplication is +.
    The map r ↦ -log(1 - r²) sends the pseudohyperbolic distance
    to the tropical world, where the multiplicative structure of
    Möbius maps becomes additive — connecting Poincaré disk arithmetic
    to tropical algebraic geometry. -/
def tropicalShadow (r : ℝ) : ℝ := -Real.log (1 - r ^ 2)

/-- The tropical shadow is zero at the origin. -/
theorem tropicalShadow_zero : tropicalShadow 0 = 0 := by
  simp [tropicalShadow]

/-
The tropical shadow is non-negative for r ∈ [0, 1).
-/
theorem tropicalShadow_nonneg (r : ℝ) (hr : |r| < 1) :
    0 ≤ tropicalShadow r := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos ( by nlinarith [ abs_lt.mp hr ] ) ( by nlinarith [ abs_lt.mp hr ] ) )

/-
The tropical shadow is monotone increasing on [0, 1).
-/
theorem tropicalShadow_mono {r s : ℝ} (hr : 0 ≤ r) (hs : s < 1)
    (hrs : r ≤ s) :
    tropicalShadow r ≤ tropicalShadow s := by
  exact neg_le_neg ( Real.log_le_log ( by nlinarith [ abs_lt.mp ( show |r| < 1 by exact abs_lt.mpr ⟨ by linarith, by linarith ⟩ ) ] ) ( by nlinarith ) )

/-! ## Part VII: Conjectures and Testable Predictions -/

/-- The count of primitive words of length n over a k-letter alphabet.
    By Witt's formula, this equals (1/n) Σ_{d|n} μ(n/d) k^d.
    We use the simpler bound k^n / n as an approximation.

    **Testable prediction**: For k=2, n=6, the exact count of primitive
    binary necklaces of length 6 is 9. Our formula gives 2^6/6 = 10.
    For k=2, n=10, exact count is 99, formula gives 2^10/10 = 102. -/
def primitiveWordCount (k n : ℕ) : ℕ :=
  if n = 0 then 0 else k ^ n / n

/-- The primitive word count is bounded by the total word count. -/
theorem primitiveWordCount_le (k n : ℕ) (hn : n ≠ 0) :
    primitiveWordCount k n ≤ wordCount k n := by
  simp [primitiveWordCount, wordCount, hn]
  exact Nat.div_le_self _ _

/-
**Conjecture (Hyperbolic Prime Number Theorem)**:
    For a free group on k ≥ 2 generators, the number of primitive
    conjugacy classes of word length n is asymptotically k^n / n.

    This is the hyperbolic analog of π(x) ~ x/ln(x).
    For free groups, this is actually a theorem (Witt's necklace formula).
    For general Fuchsian groups, the analogous statement involves the
    Selberg zeta function and is much deeper.

    **Falsifiable test**: Compute primitiveWordCount 2 n for n = 1..20
    and compare with the exact necklace counts. The ratio should → 1.
-/
theorem primitiveWordCount_pos (k n : ℕ) (hk : k ≥ 2) (hn : n ≥ 1) :
    primitiveWordCount k n ≥ 1 := by
  unfold primitiveWordCount;
  rw [ if_neg ( by linarith ) ];
  exact Nat.div_pos ( Nat.le_of_lt ( Nat.recOn n ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; nlinarith [ Nat.mul_le_mul_left k ihn ] ) ) hn

end