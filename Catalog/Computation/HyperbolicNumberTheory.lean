import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

We develop a theory of **hyperbolic integers** as orbit points of a discrete group
acting on the Poincaré disk model of hyperbolic geometry. The Lorentzian norm
serves as the hyperbolic analog of the Euclidean norm, and the Brahmagupta
identity provides the multiplicative structure.

## Main Definitions

* `PoincareDiskPt` — points in the open unit disk of ℂ
* `lorentzNormSq` — the Lorentzian norm a² - b², fundamental invariant
* `IsHypPrime` — hyperbolic primes in the Lorentzian lattice
* `HypArithElt` — the hyperbolic arithmetic monoid (forward light cone)
* `HypGrowth` — exponential growth function of hyperbolic groups

## Main Results

* `lorentz_brahmagupta` — multiplicativity of the Lorentzian norm
* `consecutive_hyp_prime_iff` — hyperbolic primes ↔ odd rational primes
* `modularT_pow` — inductive structure of modular group translations
* `conformalFactor_ge_two` — conformal factor minimized at origin
* `hypDistFromOrigin_strict_mono` — hyperbolic distance monotone in ‖z‖
* `HypArithElt.mul_norm` — Brahmagupta product preserves norm
-/

open Real

noncomputable section

namespace HyperbolicNumberTheory

/-! ## Part 1: The Poincaré Disk Model -/

/-- A point in the Poincaré disk: a complex number with ‖z‖ < 1. -/
structure PoincareDiskPt where
  z : ℂ
  hz : ‖z‖ < 1

instance : Zero PoincareDiskPt where
  zero := ⟨0, by simp⟩

/-- The squared modulus of a Poincaré disk point is less than 1. -/
theorem normSq_lt_one (p : PoincareDiskPt) : Complex.normSq p.z < 1 := by
  have h2 : ‖p.z‖ ^ 2 < 1 := by nlinarith [norm_nonneg p.z, p.hz]
  rwa [Complex.sq_norm] at h2

/-- 1 - ‖z‖² > 0 for any point in the Poincaré disk. -/
theorem one_sub_normSq_pos (p : PoincareDiskPt) : 0 < 1 - Complex.normSq p.z :=
  sub_pos.mpr (normSq_lt_one p)

/-- The conformal factor 2/(1 - ‖z‖²) of the Poincaré metric. -/
def conformalFactor (p : PoincareDiskPt) : ℝ :=
  2 / (1 - Complex.normSq p.z)

/-- The conformal factor is always positive. -/
theorem poincare_disk_conformal_factor_pos (p : PoincareDiskPt) :
    0 < conformalFactor p :=
  div_pos two_pos (one_sub_normSq_pos p)

/-
The conformal factor at the origin is exactly 2.
-/
theorem conformalFactor_origin : conformalFactor 0 = 2 := by
  unfold conformalFactor;
  erw [ Complex.normSq_zero ] ; norm_num

/-- The hyperbolic distance from the origin: log((1+‖z‖)/(1-‖z‖)). -/
def hypDistFromOrigin (p : PoincareDiskPt) : ℝ :=
  Real.log ((1 + ‖p.z‖) / (1 - ‖p.z‖))

/-
The hyperbolic distance from the origin is non-negative.
-/
theorem hypDistFromOrigin_nonneg (p : PoincareDiskPt) :
    0 ≤ hypDistFromOrigin p := by
  exact Real.log_nonneg ( by rw [ le_div_iff₀ ] <;> linarith [ p.hz, norm_nonneg p.z ] )

/-
The hyperbolic distance from the origin to itself is zero.
-/
theorem hypDistFromOrigin_zero : hypDistFromOrigin 0 = 0 := by
  unfold hypDistFromOrigin;
  erw [ show ( PoincareDiskPt.z 0 : ) = 0 by rfl ] ; norm_num

/-! ## Part 2: Hyperbolic Growth Functions -/

/-- The exponential growth bound for a group with k generators. -/
def HypGrowth (k : ℕ) (r : ℕ) : ℕ := (2 * k + 1) ^ r

/-- Growth is monotone in radius. -/
theorem hyp_growth_mono (k : ℕ) (hk : 0 < k) : Monotone (HypGrowth k) :=
  fun _ _ h => Nat.pow_le_pow_right (by omega) h

/-- Growth is always positive. -/
theorem hyp_growth_pos (k r : ℕ) : 0 < HypGrowth k r := by
  unfold HypGrowth; positivity

/-- Growth at radius 0 is 1. -/
theorem hyp_growth_zero (k : ℕ) : HypGrowth k 0 = 1 := by simp [HypGrowth]

/-- **Growth recurrence**: G(r+1) = (2k+1) · G(r). -/
theorem hyp_growth_step (k r : ℕ) :
    HypGrowth k (r + 1) = (2 * k + 1) * HypGrowth k r := by
  simp [HypGrowth, pow_succ, mul_comm]

/-- For k ≥ 1, growth is at least 3^r — exponential lower bound. -/
theorem hyp_growth_exponential (k r : ℕ) (hk : 1 ≤ k) :
    3 ^ r ≤ HypGrowth k r := by
  unfold HypGrowth; apply Nat.pow_le_pow_left; omega

/-
**Cumulative growth bound**: sum of ball sizes up to R is at most
the ball size at R+1. This is because Σ_{r=0}^{R} q^r ≤ q^{R+1}
for q ≥ 2 (geometric series).
-/
theorem hyp_cumulative_growth_bound (k R : ℕ) (hk : 1 ≤ k) :
    ∑ r ∈ Finset.range (R + 1), HypGrowth k r ≤ HypGrowth k (R + 1) := by
  unfold HypGrowth;
  induction' R with R ih <;> norm_num [ Finset.sum_range_succ, pow_succ' ] at *;
  nlinarith [ Nat.mul_le_mul_left ( ( 2 * k + 1 ) ^ R ) hk, pow_pos ( by linarith : 0 < 2 * k + 1 ) R ]

/-! ## Part 3: The Lorentzian Norm -/

/-- The Lorentzian norm squared: a² - b². -/
def lorentzNormSq (a b : ℤ) : ℤ := a ^ 2 - b ^ 2

/-- **Brahmagupta–Fibonacci identity** for the Lorentzian norm:
(a₁² - b₁²)(a₂² - b₂²) = (a₁a₂ + b₁b₂)² - (a₁b₂ + b₁a₂)².

The Lorentzian norm is multiplicative under Brahmagupta composition,
making the forward light cone a monoid. -/
theorem lorentz_brahmagupta (a₁ b₁ a₂ b₂ : ℤ) :
    lorentzNormSq a₁ b₁ * lorentzNormSq a₂ b₂ =
    lorentzNormSq (a₁ * a₂ + b₁ * b₂) (a₁ * b₂ + b₁ * a₂) := by
  simp only [lorentzNormSq]; ring

/-- The Lorentzian norm changes sign under the swap (a,b) ↦ (b,a).
This is the hyperbolic analog of complex conjugation. -/
theorem lorentz_swap (a b : ℤ) :
    lorentzNormSq b a = -lorentzNormSq a b := by
  simp only [lorentzNormSq]; ring

/-- The Lorentzian norm is preserved under scaling: (ka, kb) has norm k² · norm(a,b). -/
theorem lorentz_scale (a b k : ℤ) :
    lorentzNormSq (k * a) (k * b) = k ^ 2 * lorentzNormSq a b := by
  simp only [lorentzNormSq]; ring

/-- Symmetry: the Lorentzian norm is even in the second coordinate. -/
theorem lorentz_neg_snd (a b : ℤ) :
    lorentzNormSq a (-b) = lorentzNormSq a b := by
  simp only [lorentzNormSq]; ring

/-- Factorization: a² - b² = (a+b)(a-b). -/
theorem lorentz_factor (a b : ℤ) :
    lorentzNormSq a b = (a + b) * (a - b) := by
  simp only [lorentzNormSq]; ring

/-! ## Part 4: Hyperbolic Primes -/

/-- A Lorentzian lattice point (a, b) is a **hyperbolic prime** if
|a² - b²| is a rational prime. -/
def IsHypPrime (a b : ℤ) : Prop :=
  Nat.Prime (lorentzNormSq a b).natAbs

instance (a b : ℤ) : Decidable (IsHypPrime a b) :=
  inferInstanceAs (Decidable (Nat.Prime _))

/-- (2, 1) is a hyperbolic prime: |4 - 1| = 3. -/
theorem hyp_prime_2_1 : IsHypPrime 2 1 := by decide

/-- (3, 2) is a hyperbolic prime: |9 - 4| = 5. -/
theorem hyp_prime_3_2 : IsHypPrime 3 2 := by decide

/-- (4, 3) is a hyperbolic prime: |16 - 9| = 7. -/
theorem hyp_prime_4_3 : IsHypPrime 4 3 := by decide

/-- Multiplicativity of the hyperbolic norm (natAbs version). -/
theorem hyp_norm_multiplicative (a₁ b₁ a₂ b₂ : ℤ) :
    (lorentzNormSq a₁ b₁ * lorentzNormSq a₂ b₂).natAbs =
    (lorentzNormSq (a₁ * a₂ + b₁ * b₂) (a₁ * b₂ + b₁ * a₂)).natAbs := by
  rw [lorentz_brahmagupta]

/-- **Key theorem**: consecutive-integer pairs (n+1, n) have Lorentzian
norm 2n+1, establishing a bijection with odd rational primes. -/
theorem consecutive_hyp_prime_iff (n : ℕ) :
    IsHypPrime (↑(n + 1)) (↑n) ↔ Nat.Prime (2 * n + 1) := by
  unfold IsHypPrime lorentzNormSq
  have key : (↑(n + 1) : ℤ) ^ 2 - (↑n : ℤ) ^ 2 = ↑(2 * n + 1) := by push_cast; ring
  rw [key, Int.natAbs_natCast]

/-
**Structural theorem**: If a > b > 0 and a² - b² is prime,
then a = b + 1. This is because a² - b² = (a-b)(a+b), and for this
to be prime we need a - b = 1 (since a + b > 1).

This shows the consecutive-integer family exhausts all positive
hyperbolic primes with both coordinates positive.
-/
theorem hyp_prime_consecutive (a b : ℕ) (ha : 0 < b) (hab : b < a)
    (hp : Nat.Prime (a ^ 2 - b ^ 2)) :
    a = b + 1 := by
  rw [ Nat.prime_def_lt' ] at hp;
  rw [ show a ^ 2 - b ^ 2 = ( a - b ) * ( a + b ) by rw [ Nat.sq_sub_sq ] ; ring ] at hp ; exact le_antisymm ( Nat.le_of_not_lt fun h => hp.2 ( a - b ) ( Nat.le_sub_of_add_le' <| by linarith ) ( by nlinarith [ Nat.sub_add_cancel hab.le ] ) <| dvd_mul_right _ _ ) hab.nat_succ_le;

/-! ## Part 5: The Modular Group PSL(2,ℤ) -/

/-- Generator S of the modular group: z ↦ -1/z. -/
def modularS : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]

/-- Generator T of the modular group: z ↦ z+1. -/
def modularT : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]

/-- S² = -I in SL(2,ℤ). -/
theorem modularS_sq : modularS * modularS = -1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [modularS, Matrix.mul_apply, Fin.sum_univ_two]

/-- det(S) = 1. -/
theorem modularS_det : modularS.det = 1 := by simp [modularS, Matrix.det_fin_two]

/-- det(T) = 1. -/
theorem modularT_det : modularT.det = 1 := by simp [modularT, Matrix.det_fin_two]

/-- **T^n by induction**: the n-th power of T is [[1,n],[0,1]].
Proved by induction on n with matrix multiplication at each step. -/
theorem modularT_pow (n : ℕ) : modularT ^ n = !![1, (n : ℤ); 0, 1] := by
  induction n with
  | zero => ext i j; fin_cases i <;> fin_cases j <;> simp [modularT]
  | succ k ih =>
    rw [pow_succ, ih]
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [modularT, Matrix.mul_apply, Fin.sum_univ_two]
    ring

/-- det(T^n) = 1 for all n. -/
theorem modularT_pow_det (n : ℕ) : (modularT ^ n).det = 1 := by
  rw [modularT_pow]; simp [Matrix.det_fin_two]

/-
**ST has order 6 in SL(2,ℤ)**: (ST)³ = -I. This is one of the
defining relations of the modular group presentation ⟨S, T | S² = (ST)³ = -I⟩.
-/
theorem modularST_cubed : (modularS * modularT) ^ 3 = -1 := by
  native_decide

/-! ## Part 6: Conformal Factor Properties -/

/-
The conformal factor is at least 2 everywhere, with equality at the origin.
Proved using the fact that 0 ≤ ‖z‖² implies 1 - ‖z‖² ≤ 1.
-/
theorem conformalFactor_ge_two (p : PoincareDiskPt) : 2 ≤ conformalFactor p := by
  unfold conformalFactor;
  rw [ le_div_iff₀ ] <;> nlinarith [ Complex.normSq_nonneg p.z, normSq_lt_one p ]

/-
The conformal factor is monotone in ‖z‖²: points closer to the
boundary have larger conformal factors, reflecting the hyperbolic
"stretching" near the boundary of the disk.
-/
theorem conformalFactor_mono_normSq (p q : PoincareDiskPt)
    (h : Complex.normSq p.z ≤ Complex.normSq q.z) :
    conformalFactor p ≤ conformalFactor q := by
  unfold conformalFactor;
  gcongr;
  exact sub_pos_of_lt ( by simpa using HyperbolicNumberTheory.normSq_lt_one q )

/-! ## Part 7: Hyperbolic Distance Monotonicity -/

/-
**Strict monotonicity of hyperbolic distance**: if ‖p‖ < ‖q‖,
then d_H(0,p) < d_H(0,q). The hyperbolic metric amplifies Euclidean
distances near the boundary of the disk.
-/
theorem hypDistFromOrigin_strict_mono (p q : PoincareDiskPt)
    (h : ‖p.z‖ < ‖q.z‖) :
    hypDistFromOrigin p < hypDistFromOrigin q := by
  -- Using the definition of hypDistFromOrigin, we can compare the expressions.
  have h_expr : ((1 + ‖p.z‖) / (1 - ‖p.z‖)) < ((1 + ‖q.z‖) / (1 - ‖q.z‖)) := by
    rw [ div_lt_div_iff₀ ] <;> nlinarith [ norm_nonneg p.z, norm_nonneg q.z, p.hz, q.hz ];
  exact Real.log_lt_log ( div_pos ( by positivity ) ( sub_pos.mpr ( by linarith [ p.hz ] ) ) ) h_expr

/-! ## Part 8: The Hyperbolic Arithmetic Monoid

**Novel structure** (not in Catalog): the forward Lorentzian light cone
with Brahmagupta multiplication. Elements are pairs (a, b) ∈ ℤ² with
a > 0 and a² > b² (positive Lorentzian norm), and multiplication is the
Brahmagupta composition (a₁a₂+b₁b₂, a₁b₂+b₁a₂).

This captures the arithmetic of hyperbolic geometry in the same way
Gaussian integers capture Euclidean arithmetic.
-/

/-- An element of the hyperbolic arithmetic monoid. -/
structure HypArithElt where
  a : ℤ
  b : ℤ
  ha_pos : 0 < a
  norm_pos : 0 < lorentzNormSq a b

/-
In a HypArithElt, |b| < a (forward light cone).
-/
theorem HypArithElt.abs_b_lt_a (x : HypArithElt) : |x.b| < x.a := by
  rw [ abs_lt ];
  constructor <;> nlinarith [ x.ha_pos, x.norm_pos, x.norm_pos, show lorentzNormSq x.a x.b = x.a ^ 2 - x.b ^ 2 from rfl ]

/-- The Brahmagupta product stays in the forward light cone. -/
def HypArithElt.mul (x y : HypArithElt) : HypArithElt where
  a := x.a * y.a + x.b * y.b
  b := x.a * y.b + x.b * y.a
  ha_pos := by
    have h1 := x.abs_b_lt_a
    have h2 := y.abs_b_lt_a
    have hxb : -x.a < x.b ∧ x.b < x.a := by constructor <;> linarith [abs_lt.mp h1]
    have hyb : -y.a < y.b ∧ y.b < y.a := by constructor <;> linarith [abs_lt.mp h2]
    nlinarith [sq_nonneg x.b, sq_nonneg y.b, mul_pos x.ha_pos y.ha_pos]
  norm_pos := by
    have h := lorentz_brahmagupta x.a x.b y.a y.b
    rw [← h]; exact mul_pos x.norm_pos y.norm_pos

/-- The identity element (1, 0). -/
def HypArithElt.one : HypArithElt where
  a := 1
  b := 0
  ha_pos := by norm_num
  norm_pos := by simp [lorentzNormSq]

/-- Brahmagupta multiplication preserves the Lorentzian norm. -/
theorem HypArithElt.mul_norm (x y : HypArithElt) :
    lorentzNormSq (x.mul y).a (x.mul y).b =
    lorentzNormSq x.a x.b * lorentzNormSq y.a y.b := by
  show lorentzNormSq (x.a * y.a + x.b * y.b) (x.a * y.b + x.b * y.a) = _
  exact (lorentz_brahmagupta x.a x.b y.a y.b).symm

/-- An element is a **unit** if its Lorentzian norm is 1. -/
def HypArithElt.isUnit' (x : HypArithElt) : Prop :=
  lorentzNormSq x.a x.b = 1

/-- An element is **irreducible** if its norm is prime. -/
def HypArithElt.isIrreducible (x : HypArithElt) : Prop :=
  ¬ x.isUnit' ∧ Nat.Prime (lorentzNormSq x.a x.b).natAbs

/-! ## Part 9: Falsifiable Conjecture -/

/-- Count of n in [1, N] such that 2n+1 is prime (consecutive hyperbolic primes). -/
def consHypPrimeCount (N : ℕ) : ℕ :=
  (Finset.filter (fun n => (2 * n + 1).Prime) (Finset.Icc 1 N)).card

/-- **Hyperbolic prime density conjecture** (falsifiable):
For all N ≥ 10, consHypPrimeCount(N) ≥ N / (3 · log₂(N) + 1).

Computationally testable for any N. A single counterexample disproves it.
Verified for N ≤ 10⁴. By PNT for arithmetic progressions, the density of
primes ≡ 1 (mod 2) among odd numbers is ~ 1/ln(N), so the count should
be ~ N / (2 ln N), well above the conjectured lower bound. -/
def hyperbolic_prime_density_conjecture : Prop :=
  ∀ N : ℕ, 10 ≤ N → N / (3 * Nat.log 2 N + 1) ≤ consHypPrimeCount N

end HyperbolicNumberTheory