import Mathlib

/-!
# Tropical Differential Equations I: Valuation Rules for Power-Series Differential Algebra

This file develops the *tropical* (= order / valuation) calculus for the differential
algebra of formal power series `K⟦X⟧` over a characteristic-zero field, with the formal
derivation `d/dX = PowerSeries.derivativeFun`.

The "tropicalization" of a power series `f` is its order `f.order : ℕ∞` (the index of the
lowest nonzero coefficient, with `⊤` for `0`).  The classical algebraic operations
tropicalize to the *min-plus* semiring `(ℕ∞, min, +)`:

* multiplication `f * g`  tropicalizes to addition of orders        (`order_mul`, Mathlib);
* addition `f + g`        tropicalizes to `min` of orders (a lower bound, `min_order_le_order_add`);
* the derivation `d/dX`   *decreases the order by one* (`order_derivativeFun_eq`).

These three rules make `order` a tropical valuation on the differential ring, and they
let us compute the order of an arbitrary **differential monomial**
`∏ᵢ (dⁱf/dXⁱ)^{eᵢ}` exactly as an affine (min-plus linear) function of `f.order`
(`order_diff_monomial`).

## Main results

* `order_derivativeFun_eq` — the tropical derivation rule: `ord f = k+1 ⟹ ord f' = k`.
* `order_iterate_derivativeFun` — `ord f = n ⟹ ord (dⁱf) = n - i` for `i ≤ n`.
* `order_diff_monomial` — order of a differential monomial is `∑ᵢ eᵢ·(n-i)`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  The order map `f ↦ f.order` should be a homomorphism
  from the *differential* ring `(K⟦X⟧, +, *, d/dX)` onto the min-plus semiring with an
  extra "shift by −1" rule for the derivation.  In particular the order of any differential
  monomial should be a fixed affine function of `ord f`, independent of the field `K`.
* **Experiment (Experimenter).**  Mathlib already supplies `order_mul`, `order_pow`,
  `min_order_le_order_add` and `coeff_derivativeFun`.  The only genuinely new ingredient is
  the derivation rule, which needs `CharZero` so the coefficient factor `(n+1)` is nonzero;
  the iterated rule and the monomial formula then follow by induction.
* **Analysis (Analyst).**  `CharZero` is *load-bearing*: in characteristic `p`, `d/dX (X^p)=0`,
  so `ord(f') = ord f - 1` fails.  This is the structural reason tropical differential algebra
  is usually set over char-zero fields (e.g. `ℂ⟦t⟧`).
* **Critique (Critic).**  None of the results are definitional: `order_derivativeFun_eq`
  must produce a *nonzero* coefficient (uses `Nat.cast_add_one_ne_zero`), and the monomial
  formula is a genuine `Finset.induction` combining the product and power rules.
-/

open PowerSeries Finset

namespace Tropical.DiffVal

variable {K : Type*} [Field K] [CharZero K]

/-- **Tropical derivation rule.**  Over a characteristic-zero field, differentiating a power
series drops its order by exactly one: if `ord f = k+1` then `ord f' = k`.  This is the
differential ingredient that the classical product/sum rules cannot supply. -/
theorem order_derivativeFun_eq {f : K⟦X⟧} {k : ℕ}
    (hf : f.order = (k + 1 : ℕ)) : (derivativeFun f).order = (k : ℕ) := by
  rw [order_eq_nat] at hf ⊢
  obtain ⟨hne, hlt⟩ := hf
  refine ⟨?_, ?_⟩
  · rw [coeff_derivativeFun]
    have h1 : ((k : K) + 1) ≠ 0 := Nat.cast_add_one_ne_zero k
    simp only [ne_eq, mul_eq_zero, not_or]
    exact ⟨by simpa using hne, h1⟩
  · intro i hi
    rw [coeff_derivativeFun]
    simp [hlt (i + 1) (by omega)]

/-- **Iterated tropical derivation rule.**  If `ord f = n` then the `i`-th derivative has
order `n - i`, for every `i ≤ n`. -/
theorem order_iterate_derivativeFun {f : K⟦X⟧} {n : ℕ}
    (hf : f.order = (n : ℕ)) :
    ∀ i ≤ n, ((derivativeFun)^[i] f).order = ((n - i : ℕ) : ℕ∞) := by
  intro i hi
  induction i with
  | zero => simpa using hf
  | succ j ih =>
    have hj : j ≤ n := Nat.le_of_succ_le hi
    rw [Function.iterate_succ_apply']
    have hkey : ((derivativeFun)^[j] f).order = (((n - j - 1) + 1 : ℕ) : ℕ∞) := by
      rw [ih hj]; congr 1; omega
    rw [order_derivativeFun_eq hkey, Nat.sub_sub]

/-- **Order of a differential monomial.**  For `ord f = n` and a finite set `s` of
derivative-orders bounded by `n`, the differential monomial `∏ᵢ (dⁱf)^{eᵢ}` has order equal
to the min-plus linear form `∑ᵢ eᵢ · (n - i)`.  This is the exact tropicalization of a
differential monomial. -/
theorem order_diff_monomial {f : K⟦X⟧} {n : ℕ}
    (hf : f.order = (n : ℕ)) (s : Finset ℕ) (hs : ∀ i ∈ s, i ≤ n) (e : ℕ → ℕ) :
    (∏ i ∈ s, ((derivativeFun)^[i] f) ^ (e i)).order
      = ∑ i ∈ s, (e i : ℕ∞) * ((n - i : ℕ) : ℕ∞) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a t ha ih =>
    rw [Finset.prod_insert ha, Finset.sum_insert ha, order_mul, order_pow,
      order_iterate_derivativeFun hf a (hs a (mem_insert_self a t)),
      ih (fun i hi => hs i (mem_insert_of_mem hi)), nsmul_eq_mul]

end Tropical.DiffVal