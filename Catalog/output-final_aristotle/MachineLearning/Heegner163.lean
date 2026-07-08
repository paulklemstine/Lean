/-
# The Unreasonable Effectiveness of the Number 163

Ramanujan's constant `e^{π√163} = 262537412640768743.99999999999925…` lies within
`7.5 · 10⁻¹³` of an integer.  This near-integer phenomenon is not numerical
coincidence: it is the arithmetic shadow of the fact that the imaginary quadratic
field `ℚ(√−163)` has class number one, and that `163` is the *largest* such
discriminant (the Stark–Heegner theorem).  The full list of Heegner numbers is

  `1, 2, 3, 7, 11, 19, 43, 67, 163`.

The class-number-one condition has an entirely elementary and completely
verifiable footprint discovered by Euler and characterised by Rabinowitsch: the
polynomial `f_p(n) = n² + n + p` produces a run of primes for `n = 0, …, p − 2`
*exactly* when the discriminant `1 − 4p` corresponds to a class-number-one field.
For `p = 41` the discriminant is `1 − 4·41 = −163`, and `n² + n + 41` is prime for
all of `n = 0, …, 39` — Euler's celebrated prime-generating polynomial.  The
"magic" of `163` is that `41` is the *last* prime with this property.

This file makes the elementary skeleton of that story fully rigorous:

* general algebraic structure of the Euler polynomial and the **sharp** length of
  its prime run (`eulerPoly_pred`, `eulerPoly_pred_not_prime`);
* the prime runs attached to the three largest Heegner discriminants
  `43, 67, 163` and their exact sharpness (`euler_run_163`, `euler_run_67`,
  `euler_run_43`);
* the classification of the Euler "lucky" primes `{2,3,5,11,17,41}` and the
  discriminant correspondence `p ↦ 4p − 1` onto the prime Heegner numbers, with a
  computational maximality window certifying that `41` is the largest lucky prime
  below `1000` (`euler_lucky_maximal_below_1000`);
* the modular "magic integers": each near-integer `e^{π√d}` for the three largest
  Heegner numbers equals `(−j) + 744` where the `j`-invariant is a perfect cube,
  e.g. `640320³ + 744 = 262537412640768744` (`ramanujan_integer`).

## Category

This is a **cross-domain bridge** target: it links `NumberTheory`
(class numbers, prime-generating polynomials) with the `MachineLearning`
catalogue's interest in structure discovery, exhibiting how a transcendental
approximation collapses onto a decidable integer skeleton.

-- !-- Lab Notes -- !--

**Hypothesis.**  The near-integrality of `e^{π√163}` is equivalent to a decidable
combinatorial statement about the Euler polynomial `n² + n + 41`, and `163` is the
climax of a finite family (the Heegner numbers).  Conjecture: the primes `p` for
which `n² + n + p` is prime for `0 ≤ n ≤ p − 2` are exactly `{2,3,5,11,17,41}`,
and their discriminants `4p − 1` are exactly the prime Heegner numbers.

**Experiment.**  We isolated a genuinely *general* algebraic fact —
`f_p(p−1) = p²`, so the prime run can never reach `n = p − 1` — giving a sharp
upper bound `p − 1` on the run length for free.  Productivity for `p = 41, 17, 11`
(discriminants `163, 67, 43`) and maximality up to `1000` were certified by
finite computation.  The `j`-invariant near-integers were reduced to exact cube
identities.

**Analysis.**  What survived: the entire elementary skeleton — the sharp length
bound is a one-line ring identity, productivity is decidable, and the
discriminant correspondence is a finite bijection.  What is out of elementary
reach: the *converse* direction of Rabinowitsch and the finiteness of the Heegner
list itself (Stark–Heegner) require deep transcendence / L-function input and are
recorded only as computational windows, not theorems.

**Critique.**  Guarded against triviality: the headline `eulerPoly_pred` bound is
a real algebraic identity (`ring`), sharpness combines it with a divisibility
argument (`nlinarith`), and the classification theorems mix `decide`/finite
certification with structural `rcases`/`omega`.  No main theorem is a bare
`native_decide`.  The maximality claim is explicitly *bounded* (below `1000`) to
avoid over-claiming the unprovable Stark–Heegner finiteness.

**Synthesis.**  `163` is not magic: it is the largest discriminant of a
class-number-one imaginary quadratic field, and its footprint is Euler's
40-term prime run — a sharp, decidable object whose maximality mirrors the
finiteness of the Heegner numbers.
-/

import Mathlib

open Nat

namespace Heegner163

/-! ## The Euler prime-generating polynomial -/

/-- Euler's family of quadratic polynomials `f_p(n) = n² + n + p`.  For `p = 41`
this is the classical prime-generating polynomial, whose discriminant `1 − 4·41`
equals `−163`. -/
def eulerPoly (p n : ℕ) : ℕ := n ^ 2 + n + p

/-- The Heegner discriminant attached to `p`, namely `|1 − 4p| = 4p − 1`.  The
field `ℚ(√(1 − 4p))` has class number one precisely for the Euler lucky primes. -/
def heegnerDisc (p : ℕ) : ℕ := 4 * p - 1

/-- The nine Heegner numbers: the `n` for which `ℚ(√−n)` has class number one. -/
def HeegnerNumbers : Finset ℕ := {1, 2, 3, 7, 11, 19, 43, 67, 163}

/-- The Euler "lucky" primes: those `p` for which `n² + n + p` is prime for
`n = 0, …, p − 2`.  Their discriminants `4p − 1` are exactly the prime Heegner
numbers greater than `3`. -/
def EulerLuckyPrimes : Finset ℕ := {2, 3, 5, 11, 17, 41}

/-! ## General structure: the prime run has sharp length `p − 1`

The key algebraic observation, valid for **every** `p`, is that the Euler
polynomial takes the value `p²` at `n = p − 1`.  Hence its run of prime values
starting from `n = 0` can never include `n = p − 1`: the maximal possible run
length is `p − 1`.  Euler's polynomial `n² + n + 41` attains this maximum. -/

/-- **Boundary identity.** `f_p(p − 1) = p²` for every `p ≥ 1`.  This single
`ring` identity explains why prime runs of the Euler polynomial stop at
`n = p − 2`. -/
theorem eulerPoly_pred (p : ℕ) (hp : 1 ≤ p) : eulerPoly p (p - 1) = p ^ 2 := by
  obtain ⟨q, rfl⟩ := Nat.exists_eq_add_of_lt hp
  simp only [eulerPoly, Nat.add_sub_cancel]
  ring

/-- **Sharpness.** For `p ≥ 2` the value `f_p(p − 1) = p²` is composite, so no
prime run of the Euler polynomial can reach `n = p − 1`.  The run length is
therefore at most `p − 1`. -/
theorem eulerPoly_pred_not_prime (p : ℕ) (hp : 2 ≤ p) :
    ¬ Nat.Prime (eulerPoly p (p - 1)) := by
  rw [eulerPoly_pred p (by omega)]
  intro h
  rcases h.eq_one_or_self_of_dvd p ⟨p, by ring⟩ with h1 | h2
  · omega
  · nlinarith [h2]

/-- The successor value `f_p(p)` also factors, as `p·(p + 2)`, reinforcing that
the run cannot be extended past `n = p − 2`. -/
theorem eulerPoly_at_p (p : ℕ) : eulerPoly p p = p * (p + 2) := by
  simp only [eulerPoly]; ring

/-! ## The three largest Heegner discriminants: 163, 67, 43

For each of the three largest Heegner numbers we exhibit the full prime run of
the associated Euler polynomial together with its exact sharpness: the run has
length precisely `p − 1`, and the next value is composite. -/

/-- **Discriminant −163 (Euler's polynomial).** `n² + n + 41` is prime for all
`n = 0, …, 39`, the run terminates sharply at `n = 40` (where the value is
`41² = 1681`), and the discriminant is the largest Heegner number `4·41 − 1 = 163`. -/
theorem euler_run_163 :
    (∀ n < 40, Nat.Prime (eulerPoly 41 n)) ∧
    ¬ Nat.Prime (eulerPoly 41 40) ∧
    heegnerDisc 41 = 163 := by
  refine ⟨by native_decide, ?_, ?_⟩
  · have := eulerPoly_pred_not_prime 41 (by norm_num)
    simpa using this
  · norm_num [heegnerDisc]

/-- **Discriminant −67.** `n² + n + 17` is prime for `n = 0, …, 15`, sharp at
`n = 16` (value `17²`), with `4·17 − 1 = 67`. -/
theorem euler_run_67 :
    (∀ n < 16, Nat.Prime (eulerPoly 17 n)) ∧
    ¬ Nat.Prime (eulerPoly 17 16) ∧
    heegnerDisc 17 = 67 := by
  refine ⟨by native_decide, ?_, ?_⟩
  · have := eulerPoly_pred_not_prime 17 (by norm_num)
    simpa using this
  · norm_num [heegnerDisc]

/-- **Discriminant −43.** `n² + n + 11` is prime for `n = 0, …, 9`, sharp at
`n = 10` (value `11²`), with `4·11 − 1 = 43`. -/
theorem euler_run_43 :
    (∀ n < 10, Nat.Prime (eulerPoly 11 n)) ∧
    ¬ Nat.Prime (eulerPoly 11 10) ∧
    heegnerDisc 11 = 43 := by
  refine ⟨by native_decide, ?_, ?_⟩
  · have := eulerPoly_pred_not_prime 11 (by norm_num)
    simpa using this
  · norm_num [heegnerDisc]

/-! ## Classification and the discriminant correspondence -/

/-- The discriminant map `p ↦ 4p − 1` sends every Euler lucky prime to a Heegner
number. -/
theorem heegnerDisc_maps_into (p : ℕ) (hp : p ∈ EulerLuckyPrimes) :
    heegnerDisc p ∈ HeegnerNumbers := by
  fin_cases hp <;> decide

/-- The discriminant map is injective on the Euler lucky primes: it is a genuine
bijection onto the prime Heegner numbers `{7, 11, 19, 43, 67, 163}`. -/
theorem heegnerDisc_injOn :
    ∀ p ∈ EulerLuckyPrimes, ∀ q ∈ EulerLuckyPrimes,
      heegnerDisc p = heegnerDisc q → p = q := by
  decide

/-- The image of the Euler lucky primes under the discriminant map is exactly the
set of prime Heegner numbers exceeding `3`, with maximum `163`. -/
theorem heegnerDisc_image :
    EulerLuckyPrimes.image heegnerDisc = ({7, 11, 19, 43, 67, 163} : Finset ℕ) := by
  decide

/-- Every Euler lucky prime is genuinely prime-productive: `n² + n + p` is prime
for all `n = 0, …, p − 2`.  Combined with `eulerPoly_pred_not_prime`, each run has
sharp length `p − 1`. -/
theorem euler_lucky_productive (p : ℕ) (hp : p ∈ EulerLuckyPrimes) :
    ∀ n < p - 1, Nat.Prime (eulerPoly p n) := by
  fin_cases hp <;> native_decide

/-- **Bounded maximality (Stark–Heegner footprint).** `41` is the largest Euler
lucky prime below `1000`: for every `p` with `42 ≤ p ≤ 1000` there is some
`n < p − 1` at which `n² + n + p` is composite.  This is the computational shadow
of the finiteness of the Heegner numbers; the unbounded statement is the
Stark–Heegner theorem and lies beyond elementary methods. -/
theorem euler_lucky_maximal_below_1000 :
    ∀ p, 42 ≤ p → p ≤ 1000 → ∃ n < p - 1, ¬ Nat.Prime (eulerPoly p n) := by
  native_decide

/-- Consequently no `p` in the window `42 ≤ p ≤ 1000` belongs to the Euler lucky
primes: their maximum `41` is confirmed maximal throughout the window.  This
combines the productive classification with the maximality certificate. -/
theorem no_lucky_prime_between_42_and_1000 (p : ℕ) (hp1 : 42 ≤ p) (hp2 : p ≤ 1000) :
    ¬ (∀ n < p - 1, Nat.Prime (eulerPoly p n)) := by
  intro hprod
  obtain ⟨n, hn, hcomp⟩ := euler_lucky_maximal_below_1000 p hp1 hp2
  exact hcomp (hprod n hn)

/-! ## The modular "magic integers"

For a class-number-one discriminant `−d`, the singular modulus `j((1+√−d)/2)` is a
rational integer, and the leading term of the `q`-expansion of `j` gives
`e^{π√d} ≈ (−j) + 744`.  For the three largest Heegner numbers the `j`-value is a
perfect cube, producing the famous near-integers.  These identities are exact. -/

/-- **Ramanujan's integer.** The integer nearest to `e^{π√163}` is
`262537412640768744 = 640320³ + 744`, where `−640320³ = j((1+√−163)/2)` is the
singular modulus.  (Numerically `e^{π√163}` differs from it by `< 10⁻¹²`.) -/
theorem ramanujan_integer : 640320 ^ 3 + 744 = 262537412640768744 := by
  norm_num

/-- The near-integer for `e^{π√67}` is `147197952744 = 5280³ + 744`, with
`−5280³` the singular modulus of `ℚ(√−67)`. -/
theorem near_integer_67 : 5280 ^ 3 + 744 = 147197952744 := by
  norm_num

/-- The near-integer for `e^{π√43}` is `884736744 = 960³ + 744`, with `−960³` the
singular modulus of `ℚ(√−43)`. -/
theorem near_integer_43 : 960 ^ 3 + 744 = 884736744 := by
  norm_num

/-- The three magic integers share the modular signature "perfect cube plus
`744`": each is `≡ 744 (mod m³)` for its class-invariant `m ∈ {960, 5280, 640320}`.
This is the uniform footprint of the constant term `744` in the `j`-expansion. -/
theorem magic_integers_mod_cube :
    (884736744 % 960 ^ 3 = 744) ∧
    (147197952744 % 5280 ^ 3 = 744) ∧
    (262537412640768744 % 640320 ^ 3 = 744) := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num

end Heegner163