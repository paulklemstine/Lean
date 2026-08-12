/-
# Cycle 7: the determinant of a torus knot, and `Φ_n(-1)` for odd `n`

The knot determinant is `|Δ_K(-1)|`. For the catalog's pencil `T(2,N)` it equals `N`
(`Bridges.AlexanderTorus.knot_determinant`), which is precisely why the `T(2,N)` bridge sees
the integer `N` at all. This cycle computes the determinant of a general torus knot with both
parameters odd, and the arithmetic input it needs, which Mathlib does not contain:

* `cyclotomic_eval_neg_one_odd` : `Φ_n(-1) = 1` for odd `n > 1` (strong induction on the
  divisor-product identity);
* `torusAlexander_eval_neg_one_odd` : `Δ_{a,b}(-1) = 1` for **odd** `a, b`, i.e. the
  determinant of `T(a,b)` is `1`;
* `torusAlexander_two_eval_neg_one` : by contrast `Δ_{2,N}(-1) = N`.

So the whole arithmetic content of the determinant lives in the *even* parameter: a torus
knot with two odd parameters has determinant `1` and its Alexander polynomial hides `ab` only
in the degree/spectrum data, whereas `T(2,N)` exposes `N` at a single evaluation point. This
is the sharpest form of the "catch": the cheap evaluation `Δ(-1)` returns `N`, not a factor
of `N`.
-/
import Computation.AlexanderTorusKnot.CyclotomicReciprocity

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-- **`Φ_n(-1) = 1` for odd `n > 1`.** -/
theorem cyclotomic_eval_neg_one_odd :
    ∀ {n : ℕ}, Odd n → 1 < n → (cyclotomic n ℤ).eval (-1) = 1 := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hodd hn
    have hpos : 0 < n := by omega
    have hprod := congrArg (Polynomial.eval (-1 : ℤ))
      (prod_cyclotomic_eq_X_pow_sub_one hpos ℤ)
    rw [eval_prod] at hprod
    have hrhs : ((X : ℤ[X]) ^ n - 1).eval (-1) = -2 := by
      simp [hodd.neg_one_pow]
    rw [hrhs] at hprod
    have h1mem : (1 : ℕ) ∈ n.divisors := Nat.one_mem_divisors.2 hpos.ne'
    rw [← Finset.mul_prod_erase _ _ h1mem, cyclotomic_one] at hprod
    have hΦ1 : ((X : ℤ[X]) - 1).eval (-1) = -2 := by simp
    rw [hΦ1] at hprod
    have hprod' : ∏ d ∈ n.divisors.erase 1, (cyclotomic d ℤ).eval (-1) = 1 :=
      mul_left_cancel₀ (show (-2 : ℤ) ≠ 0 by norm_num) (by rw [hprod]; ring)
    have hnmem : n ∈ n.divisors.erase 1 :=
      Finset.mem_erase.2 ⟨by omega, Nat.mem_divisors_self _ hpos.ne'⟩
    rw [← Finset.mul_prod_erase _ _ hnmem] at hprod'
    have hrest : ∏ d ∈ (n.divisors.erase 1).erase n, (cyclotomic d ℤ).eval (-1) = 1 := by
      refine Finset.prod_eq_one fun d hd => ?_
      have hdn : d ≠ n := (Finset.mem_erase.1 hd).1
      have hd' := Finset.mem_of_mem_erase hd
      have hd1 : d ≠ 1 := (Finset.mem_erase.1 hd').1
      have hdmem : d ∈ n.divisors := (Finset.mem_erase.1 hd').2
      have hdvd : d ∣ n := (Nat.mem_divisors.1 hdmem).1
      have hdpos : 0 < d := Nat.pos_of_mem_divisors hdmem
      have hdlt : d < n := lt_of_le_of_ne (Nat.le_of_dvd hpos hdvd) hdn
      exact ih d hdlt (Bridges.AlexanderTorus.odd_of_dvd_odd hodd hdvd) (by omega)
    rw [hrest, mul_one] at hprod'
    exact hprod'

/-- **The determinant of a torus knot with odd parameters is `1`.** (Coprimality is not
needed: the argument only uses that every element of the spectrum is odd and `> 1`.) -/
theorem torusAlexander_eval_neg_one_odd {a b : ℕ} (ha : Odd a) (hb : Odd b) : (torusAlexander a b).eval (-1) = 1 := by
  rw [torusAlexander, eval_prod]
  refine Finset.prod_eq_one fun d hd => ?_
  have hmem := mem_spectrum.1 hd
  have hdvd : d ∣ a * b := hmem.1
  have hd1 : d ≠ 1 := by
    intro h
    exact hmem.2.2.1 (h ▸ one_dvd a)
  have hdodd : Odd d := Bridges.AlexanderTorus.odd_of_dvd_odd (ha.mul hb) hdvd
  have hdpos : 0 < d := hdodd.pos
  exact cyclotomic_eval_neg_one_odd hdodd (by omega)

/-- By contrast, the `T(2,N)` pencil exposes `N` at the single point `-1`. -/
theorem torusAlexander_two_eval_neg_one {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    (torusAlexander 2 N).eval (-1) = (N : ℤ) := by
  rw [torusAlexander_two_eq_alexander hN h1]
  exact Bridges.AlexanderTorus.knot_determinant N

end Computation.AlexanderTorusKnot