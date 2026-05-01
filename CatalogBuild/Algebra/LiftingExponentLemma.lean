/-! # CatalogBuild.Algebra.LiftingExponentLemma

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 4
-/

import Mathlib

noncomputable section

/-- **Lifting the Exponent Lemma (subtraction form, ℤ).**
For an odd prime `p`, integers `x, y` with `p ∣ (x - y)` and `p ∤ x`,
we have `v_p(x^n - y^n) = v_p(x - y) + v_p(n)`. -/
theorem lte_int_sub {p : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    {x y : ℤ} (hdvd : (p : ℤ) ∣ x - y) (hndvd : ¬(p : ℤ) ∣ x)
    (n : ℕ) :
    emultiplicity (p : ℤ) (x ^ n - y ^ n) =
      emultiplicity (p : ℤ) (x - y) + emultiplicity (p : ℕ) n :=
  Int.emultiplicity_pow_sub_pow hp hodd hdvd hndvd n


/-- **Lifting the Exponent Lemma (addition form, ℤ).**
For an odd prime `p`, integers `x, y` with `p ∣ (x + y)`, `p ∤ x`, and odd `n`,
we have `v_p(x^n + y^n) = v_p(x + y) + v_p(n)`. -/
theorem lte_int_add {p : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    {x y : ℤ} (hdvd : (p : ℤ) ∣ x + y) (hndvd : ¬(p : ℤ) ∣ x)
    {n : ℕ} (hn : Odd n) :
    emultiplicity (p : ℤ) (x ^ n + y ^ n) =
      emultiplicity (p : ℤ) (x + y) + emultiplicity (p : ℕ) n :=
  Int.emultiplicity_pow_add_pow hp hodd hdvd hndvd hn


/-- **Lifting the Exponent Lemma (subtraction form, ℕ).**
For an odd prime `p`, natural numbers `x, y` with `p ∣ (x - y)` and `p ∤ x`,
we have `v_p(x^n - y^n) = v_p(x - y) + v_p(n)`. -/
theorem lte_nat_sub {p : ℕ} (hp : Nat.Prime p) (hodd : Odd p)
    {x y : ℕ} (hdvd : p ∣ x - y) (hndvd : ¬p ∣ x)
    (n : ℕ) :
    emultiplicity p (x ^ n - y ^ n) =
      emultiplicity p (x - y) + emultiplicity p n :=
  Nat.emultiplicity_pow_sub_pow hp hodd hdvd hndvd n


/-- **Lifting the Exponent Lemma (without the p ∤ a condition).**
For an odd prime `p` and `p ∣ (x - y)`, we can still state the LTE when
`p ∤ x` (equivalently, `p ∤ y`). This is the "base case" form. -/
theorem lte_base_case {p : ℕ} (hp : Nat.Prime p) {x y : ℤ}
    (hdvd : (p : ℤ) ∣ x - y) (hndvd : ¬(p : ℤ) ∣ x) (n : ℕ) (hn : ¬(p : ℕ) ∣ n) :
    emultiplicity (p : ℤ) (x ^ n - y ^ n) = emultiplicity (p : ℤ) (x - y) :=
  emultiplicity_pow_sub_pow_of_prime (Nat.prime_iff_prime_int.mp hp) hdvd hndvd
    (by rwa [Int.natCast_dvd_natCast])


end
