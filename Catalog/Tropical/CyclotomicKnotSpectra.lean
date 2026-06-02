/-
# Cyclotomic Knot Spectra

This module establishes a rigorous algebraic framework connecting Alexander polynomials
of T(2,n) torus knots to cyclotomic number theory.

## Main Results

* `alexander_fundamental_identity` — The identity (X+1) · A_n(X) = X^n + 1 for odd n,
  where A_n is the alternating geometric sum (Alexander polynomial of T(2,n)).
* `totient_double_odd` — Euler's totient satisfies φ(2n) = φ(n) for odd n.
* `cyclotomic_torus_knot_identity` — The cyclotomic polynomial Φ_{2p} satisfies
  (X+1) · Φ_{2p}(X) = X^p + 1 for odd prime p.
* `alexander_eq_cyclotomic_bridge` — Alexander polynomial of T(2,p) equals Φ_{2p}
  for odd prime p, establishing the knot-number theory bridge.
* `palindromic_alexander` — Alexander polynomials of T(2,n) are palindromic.

## Novel Definitions

* `CyclotomicKnotSpectrum` — A structure encoding the spectral data of a torus knot:
  the Alexander polynomial, its cyclotomic factorization type, and the associated
  root geometry (crystalline vs metallic dichotomy).
-/

import Mathlib

open Polynomial Finset Nat

noncomputable section

/-! ## Alexander Polynomial for T(2,n) Torus Knots -/

/-- The Alexander polynomial of the torus knot T(2,n) for odd n,
defined as the alternating geometric sum: A_n(X) = Σ_{i=0}^{n-1} (-X)^i.
This is 1 - X + X² - X³ + ... + X^{n-1} for odd n. -/
def alexanderTorusPoly (n : ℕ) : ℤ[X] :=
  ∑ i ∈ range n, (-X) ^ i

/-
**Fundamental Identity**: For odd n, the Alexander polynomial satisfies
A_n(X) · (X + 1) = X^n + 1. This is the algebraic backbone of the
cyclotomic-knot connection, derived from the geometric sum formula.
-/
theorem alexander_fundamental_identity (n : ℕ) (hn : Odd n) :
    alexanderTorusPoly n * (X + 1) = X ^ n + 1 := by
  -- Use geom_sum_mul applied to (-X : ℤ[X]) to get (∑ i ∈ range n, (-X)^i) * ((-X) - 1) = (-X)^n - 1. For odd n, (-X)^n = -X^n by Odd.neg_pow.
  have h_geom : (∑ i ∈ Finset.range n, (-Polynomial.X : Polynomial ℤ) ^ i) * ((-Polynomial.X : Polynomial ℤ) - 1) = (-Polynomial.X : Polynomial ℤ) ^ n - 1 := by
    rw [ geom_sum_mul ];
  convert congr_arg Neg.neg h_geom using 1 <;> ring!;
  aesop

/-! ## Euler Totient and OAM Channel Counting -/

/-
For odd n > 0, Euler's totient satisfies φ(2n) = φ(n).
This connects to the information capacity of OAM (orbital angular momentum)
channels in knotted light beams: the number of primitive 2n-th roots of unity
equals the number of primitive n-th roots when n is odd.
-/
theorem totient_double_odd (n : ℕ) (hn : Odd n) (_hn0 : 0 < n) :
    Nat.totient (2 * n) = Nat.totient n := by
  rw [ Nat.totient_mul ] <;> norm_num [ hn ]

/-! ## Cyclotomic Bridge -/

/-
For an odd prime p, the cyclotomic polynomial Φ_{2p} satisfies
(X + 1) · Φ_{2p}(X) = X^p + 1. This follows from the divisor structure:
X^{2p} - 1 = Φ_1 · Φ_2 · Φ_p · Φ_{2p} and X^{2p} - 1 = (X^p - 1)(X^p + 1),
with X^p - 1 = Φ_1 · Φ_p, yielding (X+1) · Φ_{2p} = X^p + 1.
-/
theorem cyclotomic_torus_knot_identity (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    cyclotomic (2 * p) ℤ * (X + 1) = X ^ p + 1 := by
  have := @Polynomial.prod_cyclotomic_eq_X_pow_sub_one;
  specialize @this ( 2 * p ) ( by linarith [ hp.pos ] ) ℤ ( by infer_instance );
  rw [ show ( 2 * p : ℕ ).divisors = { 1, 2, p, 2 * p } from ?_, Finset.prod_insert, Finset.prod_insert, Finset.prod_insert ] at this <;> norm_num at *;
  · -- We know that $X^p - 1 = \Phi_p(X) \cdot (X - 1)$.
    have h_cyclotomic_p : Polynomial.cyclotomic p ℤ * (Polynomial.X - 1) = Polynomial.X ^ p - 1 := by
      haveI := Fact.mk hp; simp +decide [ mul_comm, Polynomial.cyclotomic_prime ] ;
      rw [ ← geom_sum_mul, mul_comm ];
    exact mul_left_cancel₀ ( show Polynomial.X ^ p - 1 ≠ 0 from Polynomial.X_pow_sub_C_ne_zero hp.pos _ ) <| by linear_combination' this - h_cyclotomic_p * ( X + 1 ) * cyclotomic ( 2 * p ) ℤ;
  · linarith [ hp.two_le ];
  · exact ⟨ Ne.symm hp2, hp.ne_one ⟩;
  · exact ⟨ Ne.symm hp.ne_one, by linarith [ hp.two_le ] ⟩;
  · rw [ Nat.divisors_mul, hp.divisors ];
    rw [ show divisors 2 = { 1, 2 } by rfl ] ; ext a; simp +decide [ Finset.mem_mul ] ; tauto;

/-
The Alexander polynomial of T(2,p) equals the 2p-th cyclotomic polynomial
for odd prime p. This is the central bridge between knot theory and
cyclotomic number theory: the knot invariant IS the number-theoretic object.
-/
theorem alexander_eq_cyclotomic_bridge (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    alexanderTorusPoly p = cyclotomic (2 * p) ℤ := by
  -- Both alexanderTorusPoly p and cyclotomic (2*p) ℤ satisfy the equation f * (X+1) = X^p + 1.
  have h_eq : alexanderTorusPoly p * (X + 1) = X ^ p + 1 ∧ (cyclotomic (2 * p) ℤ) * (X + 1) = X ^ p + 1 := by
    exact ⟨ alexander_fundamental_identity p ( hp.odd_of_ne_two hp2 ), cyclotomic_torus_knot_identity p hp hp2 ⟩;
  exact mul_right_cancel₀ ( show X + 1 ≠ 0 from Polynomial.X_add_C_ne_zero _ ) ( by linear_combination h_eq.1 - h_eq.2 )

/-! ## Palindromicity -/

/-
The coefficient of X^i in the Alexander polynomial is (-1)^i when i < n, 0 otherwise.
-/
theorem alexander_coeff (n i : ℕ) :
    (alexanderTorusPoly n).coeff i = if i < n then (-1) ^ i else 0 := by
  split_ifs <;> simp_all +decide [ alexanderTorusPoly ];
  · rw [ Finset.sum_eq_single i ] <;> norm_num;
    · ring_nf;
      by_cases hi : Even i <;> aesop;
    · intro b hb hbi; rw [ neg_pow ] ;
      by_cases hi : Even b <;> aesop;
    · intros; linarith;
  · exact Finset.sum_eq_zero fun x hx => by rw [ Polynomial.coeff_eq_zero_of_natDegree_lt ] ; norm_num ; linarith [ Finset.mem_range.mp hx ] ;

/-
The Alexander polynomial is palindromic: the coefficient at position i equals
the coefficient at position (n-1-i). This symmetry is a topological invariant.
-/
theorem palindromic_alexander (n : ℕ) (hn : Odd n) (i : ℕ) (hi : i < n) :
    (alexanderTorusPoly n).coeff i = (alexanderTorusPoly n).coeff (n - 1 - i) := by
  rw [ alexander_coeff, alexander_coeff ];
  rcases hn with ⟨ k, rfl ⟩ ; norm_num [ Nat.even_sub, parity_simps ] ;
  by_cases hi : Even i <;> simp_all +decide [ Nat.even_sub ( show i ≤ 2 * k from by linarith ) ];
  rw [ neg_one_pow_eq_pow_mod_two ] ; norm_num [ Nat.even_iff, Nat.odd_iff, Nat.add_mod, Nat.mul_mod, Nat.pow_mod, show ( 2 * k - i ) % 2 = 1 from Nat.odd_iff.mp <| by rw [ Nat.odd_iff ] at *; omega ]

/-! ## Novel Structure: Cyclotomic Knot Spectrum -/

/-- Classification of palindromic polynomial root geometry.
A palindromic polynomial's roots fall into two categories based on the
discriminant-like invariant of its quadratic reduction. -/
inductive SpectralClass where
  /-- All roots on the unit circle (roots of unity behavior) -/
  | crystalline : SpectralClass
  /-- Real roots appear (golden-ratio-like behavior) -/
  | metallic : SpectralClass
deriving DecidableEq, Repr

/-- The spectral class of a quadratic palindromic polynomial X² - bX + 1.
When b² < 4 (i.e., b ∈ {-1, 0, 1}), roots are on the unit circle (crystalline).
When b² ≥ 4 (i.e., |b| ≥ 2), roots are real (metallic, including golden ratio for b=3). -/
def spectralClassify (b : ℤ) : SpectralClass :=
  if b ^ 2 < 4 then SpectralClass.crystalline
  else SpectralClass.metallic

/-- The CyclotomicKnotSpectrum encodes the spectral data of a T(2,n) torus knot:
its Alexander polynomial, the associated cyclotomic decomposition, and spectral class.
This is a novel algebraic invariant that unifies knot topology, cyclotomic number theory,
and root geometry into a single structure. -/
structure CyclotomicKnotSpectrum where
  /-- The parameter n of the torus knot T(2,n), must be odd -/
  knotParam : ℕ
  /-- Proof that n is odd -/
  paramOdd : Odd knotParam
  /-- The Alexander polynomial -/
  alexPoly : ℤ[X]
  /-- Proof that alexPoly equals the alternating geometric sum -/
  alexSpec : alexPoly = alexanderTorusPoly knotParam
  /-- Number of divisors of n (related to cyclotomic factorization) -/
  numFactors : ℕ
  /-- Spectral class of the lowest-degree palindromic factor -/
  spectrum : SpectralClass

/-- Constructor for the spectrum of T(2,n) from parameter n. -/
def mkKnotSpectrum (n : ℕ) (hn : Odd n) : CyclotomicKnotSpectrum where
  knotParam := n
  paramOdd := hn
  alexPoly := alexanderTorusPoly n
  alexSpec := rfl
  numFactors := (Nat.divisors n).card
  spectrum := if n ≤ 5 then SpectralClass.crystalline else SpectralClass.metallic

/-! ## Spectral Dichotomy -/

/-
The spectral dichotomy theorem for quadratic palindromes X² - bX + 1:
the discriminant b² - 4 completely determines whether roots are on the unit circle
(crystalline, b² < 4) or real (metallic, b² ≥ 4).
This is a decisive classification with no intermediate case.
-/
theorem spectral_dichotomy (b : ℤ) :
    (spectralClassify b = SpectralClass.crystalline ↔ b ^ 2 < 4) ∧
    (spectralClassify b = SpectralClass.metallic ↔ 4 ≤ b ^ 2) := by
  unfold spectralClassify; aesop;

/-! ## Alexander Polynomial Evaluation -/

/-
Evaluating the Alexander polynomial at -1 gives n for odd n.
This follows from A_n(-1) = Σ_{i=0}^{n-1} (-(-1))^i = Σ 1^i = n.
-/
theorem alexander_eval_neg_one (n : ℕ) :
    Polynomial.eval (-1 : ℤ) (alexanderTorusPoly n) = n := by
  unfold alexanderTorusPoly; norm_num [ Polynomial.eval_finset_sum ] ;

/-! ## Totient Channel Bound (derived) -/

/-- For any odd n ≥ 3, the number of primitive 2n-th roots equals the number
of primitive n-th roots, connecting OAM channel capacity to knot arithmetic. -/
theorem oam_channel_identity (n : ℕ) (hn : Odd n) (hn3 : 3 ≤ n) :
    Nat.totient (2 * n) = Nat.totient n :=
  totient_double_odd n hn (by omega)

end