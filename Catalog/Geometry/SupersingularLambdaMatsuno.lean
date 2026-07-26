import Mathlib

/-!
# A Matsuno-type formula for supersingular Iwasawa λ-invariants

Let `E` be an elliptic curve over `ℚ` with good supersingular reduction at `2` and
square-free conductor `N_E`, and let `D > 0` be a square-free integer with
`D ≡ 1 (mod 4)`.  A theorem of Matsuno type predicts that the difference between the
sharp/flat `2`-adic Iwasawa `λ`-invariants of the quadratic twist `E^D` and of `E`
(assuming vanishing `μ`-invariant) is a **purely local sum** over the prime divisors
`ℓ` of `D`:

* if `ℓ ∣ N_E` the local contribution is `2^{n_ℓ}`;
* if `ℓ ∤ N_E` and the order of the reduction of `E` modulo `ℓ` is even, the local
  contribution is `2^{n_ℓ + 1}`;
* otherwise the local contribution is `0`,

where `n_ℓ = v₂((ℓ² − 1)/8)` is the `2`-adic valuation of `(ℓ² − 1)/8`.

This file isolates and studies the **arithmetic content** of that formula.  The
`λ`-invariant difference is not available in the present library, so we take the
right-hand side of the formula as an explicit arithmetic function `lambdaDiff` and
prove the structural facts that make the formula meaningful and computable:

* `nEll` is well defined and satisfies the clean valuation identity
  `n_ℓ + 3 = v₂(ℓ − 1) + v₂(ℓ + 1)` for every odd `ℓ ≥ 3` (`nEll_add_three`);
* the local term is controlled: `localTerm` lies between `0` and `2^{n_ℓ + 1}`;
* the total invariant is **additive over coprime moduli** (`lambdaDiff_mul_coprime`),
  which is the algebraic shadow of the multiplicativity of quadratic twisting;
* the total invariant is **monotone** under divisibility of the (square-free) level
  (`lambdaDiff_le_of_dvd`), and on a single prime it reduces to the local term
  (`lambdaDiff_prime`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the Matsuno difference of supersingular `λ`-invariants is
governed entirely by the local `2`-adic depths `n_ℓ`, and hence should behave like a
completely additive arithmetic function on square-free twisting parameters.

Experiment (Experimenter): we defined `nEll`, `localTerm`, `lambdaDiff` as computable
`ℕ`-valued functions.  Small-case computation (`ℓ = 3,5,7,17,31,97`) gave
`n_ℓ = 0,0,1,2,3,3`, matching `v₂((ℓ²−1)/8)` and the "one factor divisible by 4"
heuristic.

Analysis (Analyst): the depth `n_ℓ` is genuinely `v₂(ℓ−1)+v₂(ℓ+1)−3`; the `−3` is
forced because exactly one of `ℓ±1` is divisible by `4` and the other only by `2`,
so `v₂(ℓ²−1) ≥ 3` always.  Additivity of `lambdaDiff` reduces to disjointness of
prime-factor supports of coprime integers.

Critique (Critic): none of the theorems is vacuous — additivity requires the
coprimality hypothesis (else prime supports overlap and the identity fails), and the
valuation identity requires `ℓ` odd (for even `ℓ`, `ℓ²−1` is odd and the depth
collapses).  Monotonicity uses that all local terms are nonnegative, which is real
content over `ℕ`-subtraction.

Synthesis (PI): `lambdaDiff` is an additive, monotone, locally computable model of the
supersingular `λ`-difference, and the depth identity gives a closed form for `n_ℓ`.
-/

open scoped BigOperators
open Finset

namespace SupersingularLambdaMatsuno

/-- The `2`-adic depth `n_ℓ = v₂((ℓ² − 1)/8)` appearing in the Matsuno formula. -/
def nEll (ℓ : ℕ) : ℕ := padicValNat 2 ((ℓ ^ 2 - 1) / 8)

/-- The local contribution `δ(ℓ)` of a prime `ℓ` to the `λ`-invariant difference.

`NE` is the conductor of `E` and `ord ℓ` models the order of the reduction of `E`
modulo `ℓ`. -/
def localTerm (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) : ℕ :=
  if ℓ ∣ NE then 2 ^ nEll ℓ
  else if 2 ∣ ord ℓ then 2 ^ (nEll ℓ + 1)
  else 0

/-- The Matsuno-type `λ`-invariant difference of the quadratic twist `E^D` and `E`,
expressed as the sum of the local contributions over the prime divisors of `D`. -/
def lambdaDiff (D NE : ℕ) (ord : ℕ → ℕ) : ℕ :=
  ∑ ℓ ∈ D.primeFactors, localTerm NE ord ℓ

/-! ### The depth `n_ℓ` -/

/-
For odd `ℓ`, the integer `ℓ² − 1` is divisible by `8`.
-/
lemma eight_dvd_sq_sub_one {ℓ : ℕ} (h : Odd ℓ) : 8 ∣ ℓ ^ 2 - 1 := by
  grind +suggestions

/-
Valuation form of the depth: for an odd `ℓ ≥ 3` we have
`v₂(ℓ² − 1) = n_ℓ + 3`.
-/
lemma padicValNat_sq_sub_one {ℓ : ℕ} (hodd : Odd ℓ) (h3 : 3 ≤ ℓ) :
    padicValNat 2 (ℓ ^ 2 - 1) = nEll ℓ + 3 := by
  convert padicValNat.mul _ _ using 1;
  rw [ Nat.mul_div_cancel' ];
  convert eight_dvd_sq_sub_one hodd using 1;
  · rw [ show ( 8 : ℕ ) = 2 ^ 3 by norm_num, padicValNat.prime_pow ] ; norm_num ; ring!;
  · exact ⟨ Nat.prime_two ⟩;
  · norm_num;
  · exact Nat.ne_of_gt ( Nat.div_pos ( Nat.le_sub_one_of_lt ( by nlinarith ) ) ( by decide ) )

/-
The closed form for the depth: `n_ℓ + 3 = v₂(ℓ − 1) + v₂(ℓ + 1)` for odd `ℓ ≥ 3`.
This exhibits `n_ℓ` as `v₂(ℓ−1) + v₂(ℓ+1) − 3`.
-/
lemma nEll_add_three {ℓ : ℕ} (hodd : Odd ℓ) (h3 : 3 ≤ ℓ) :
    nEll ℓ + 3 = padicValNat 2 (ℓ - 1) + padicValNat 2 (ℓ + 1) := by
  convert padicValNat_sq_sub_one hodd h3 |> Eq.symm using 1;
  rw [ show ℓ ^ 2 - 1 = ( ℓ - 1 ) * ( ℓ + 1 ) by convert Nat.sq_sub_sq ℓ 1 using 1; ring, padicValNat.mul ( by omega ) ( by omega ) ]

/-! ### The local term -/

/-
The local term never exceeds `2^{n_ℓ + 1}`.
-/
lemma localTerm_le (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) :
    localTerm NE ord ℓ ≤ 2 ^ (nEll ℓ + 1) := by
  unfold localTerm;
  split_ifs <;> norm_num [ pow_succ' ]

/-
If `ℓ` divides the conductor, the local term is the positive power `2^{n_ℓ}`.
-/
lemma localTerm_of_dvd_conductor {NE : ℕ} {ord : ℕ → ℕ} {ℓ : ℕ} (h : ℓ ∣ NE) :
    localTerm NE ord ℓ = 2 ^ nEll ℓ := by
  unfold localTerm; aesop;

/-! ### The global invariant -/

/-
On a single prime `p`, the invariant reduces to the local term.
-/
lemma lambdaDiff_prime {p NE : ℕ} {ord : ℕ → ℕ} (hp : p.Prime) :
    lambdaDiff p NE ord = localTerm NE ord p := by
  unfold lambdaDiff; aesop;

/-
**Additivity over coprime moduli.**  For coprime nonzero `a`, `b` the invariant of
the product is the sum of the invariants — the arithmetic shadow of the
multiplicativity of quadratic twisting.
-/
theorem lambdaDiff_mul_coprime {a b NE : ℕ} {ord : ℕ → ℕ}
    (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    lambdaDiff (a * b) NE ord = lambdaDiff a NE ord + lambdaDiff b NE ord := by
  unfold lambdaDiff;
  rw [ Nat.primeFactors_mul ha hb, Finset.sum_union hab.disjoint_primeFactors ]

/-
**Monotonicity in the level.**  If `d` divides `D` (with `D` nonzero) then the
invariant of `d` is at most that of `D`: enlarging the set of ramified primes can only
increase the invariant.
-/
theorem lambdaDiff_le_of_dvd {d D NE : ℕ} {ord : ℕ → ℕ} (hdvd : d ∣ D) (hD : D ≠ 0) :
    lambdaDiff d NE ord ≤ lambdaDiff D NE ord := by
  convert Finset.sum_le_sum_of_subset ( Nat.primeFactors_mono hdvd hD ) using 1;
  infer_instance

end SupersingularLambdaMatsuno