import Mathlib
import NumberTheory.Irrationality

/-!
# The golden ratio is badly approximable (the sharp side of Hurwitz)

Dirichlet's theorem (`Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational`,
already in Mathlib) gives, for every irrational `ξ`, infinitely many rationals
`p/q` with `|ξ - p/q| < 1/q²`.  Hurwitz's theorem sharpens the constant to
`1/(√5 q²)`, and the *golden ratio* `φ = (1+√5)/2` shows this constant cannot be
improved: `φ` is the prototypical **badly approximable** number.

This file proves the elementary, quantitative lower bound behind that fact:

* `GoldenRatio.norm_form` — the real factorisation
  `(p - qφ)(p - qψ) = p² - pq - q²` where `ψ = (1-√5)/2` is the conjugate;
* `GoldenRatio.norm_ne_zero` — for integers with `q ≥ 1`, `p² - pq - q² ≠ 0`
  (because `5` is not a perfect square);
* `GoldenRatio.fib_binet` — the Binet-type identity
  `fib (n+1) - φ · fib n = ψ ^ n`;
* `GoldenRatio.irrational_phi` — `φ` is irrational, proved through the catalog's
  Diophantine engine `EulerMascheroni.irrational_of_forall_eps_linear_form`,
  fed by the Fibonacci linear forms `fib n · φ - fib (n+1) = -ψⁿ`;
* `GoldenRatio.badly_approximable` — for all integers `p` and `q ≥ 1`,
  `|φ - p/q| ≥ (1/3)/q²`;
* `GoldenRatio.not_liouville` — consequently `φ` is **not** a Liouville number.

-- !-- Lab Notes -- !--
HYPOTHESIS.  The golden ratio is the worst-approximable real: its continued
fraction `[1;1,1,…]` has the smallest possible partial quotients, so its
convergents (ratios of consecutive Fibonacci numbers) converge as slowly as
possible.  Quantitatively `|φ - p/q| ≥ c/q²` for an absolute `c > 0`.

EXPERIMENT.  The clean route avoids continued fractions entirely.  The integer
"norm" `N = p² - pq - q²` factors over `ℝ` as `(p-qφ)(p-qψ)`.  Since `x²-x-1`
has no rational root (`5` is not a square), `N ≠ 0`, hence `|N| ≥ 1`.  Writing
`t = |p-qφ|` and using `p - qψ = (p-qφ) + q√5`, we get
`1 ≤ |N| = t·|p-qψ| ≤ t(t + √5 q)`, which forbids `q·t` from being too small.

ANALYSIS.  With `q·t < 1/3` and `t < 1/3` we would get
`1 ≤ t² + √5(q t) < 1/9 + √5/3 < 1` (using `√5 < 8/3`), a contradiction; so
`q·t ≥ 1/3`, i.e. `|φ - p/q| ≥ (1/3)/q²`.  The Fibonacci forms `fib n φ -
fib (n+1) = -ψⁿ → 0` (nonzero) drive the catalog irrationality engine.

CRITIQUE.  The constant `1/3` is not the optimal `1/√5`; sharpness (that `√5`
is optimal) is proved in the companion file `GoldenRatioHurwitzSharp`.  None of
these statements is in Mathlib, which stops at Dirichlet's `1/q²`.

SYNTHESIS.  Norm-form lower bound + Fibonacci forms = a self-contained bridge
from continued-fraction folklore to a fully formal badly-approximable theorem,
yielding `¬ Liouville φ` as a corollary.
-/

open scoped Classical

namespace GoldenRatio

/-- The golden ratio `φ = (1+√5)/2`. -/
noncomputable def phi : ℝ := (1 + Real.sqrt 5) / 2

/-- The conjugate `ψ = (1-√5)/2`. -/
noncomputable def psi : ℝ := (1 - Real.sqrt 5) / 2

lemma sqrt5_sq : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)

lemma sqrt5_nonneg : (0 : ℝ) ≤ Real.sqrt 5 := Real.sqrt_nonneg 5

lemma sqrt5_lt : Real.sqrt 5 < 8 / 3 := by
  rw [ Real.sqrt_lt ] <;> norm_num

lemma phi_add_psi : phi + psi = 1 := by
  unfold phi psi; ring

lemma phi_mul_psi : phi * psi = -1 := by
  unfold phi psi
  have := sqrt5_sq
  nlinarith [this]

lemma phi_sub_psi : phi - psi = Real.sqrt 5 := by
  unfold phi psi; ring

/-- `ψ` is a root of `x² = x + 1`. -/
lemma psi_sq : psi ^ 2 = psi + 1 := by
  unfold psi
  have := sqrt5_sq
  nlinarith [this]

/-- `φ` is a root of `x² = x + 1`. -/
lemma phi_sq : phi ^ 2 = phi + 1 := by
  unfold phi
  have := sqrt5_sq
  nlinarith [this]

/-
`|ψ| < 1`.
-/
lemma abs_psi_lt_one : |psi| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ psi ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ], by rw [ psi ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ⟩

/-- The real factorisation of the integer norm `p² - pq - q²`. -/
lemma norm_form (p q : ℝ) :
    (p - q * phi) * (p - q * psi) = p ^ 2 - p * q - q ^ 2 := by
  have h1 := phi_add_psi
  have h2 := phi_mul_psi
  linear_combination (-(p * q)) * h1 + (q ^ 2) * h2

/-
For integers with `q ≥ 1`, the norm `p² - pq - q²` is nonzero
(`x² - x - 1` has no rational root since `5` is not a perfect square).
-/
lemma norm_ne_zero (p q : ℤ) (hq : 1 ≤ q) : p ^ 2 - p * q - q ^ 2 ≠ 0 := by
  by_contra h_contra;
  -- If $p^2 - pq - q^2 = 0$, then $(2p - q)^2 = 5q^2$, so $5$ is a perfect square.
  have h_perfect_square : ∃ r : ℤ, r^2 = 5 := by
    exact ⟨ ( 2 * p - q ) / q, by cases abs_cases ( 2 * p - q ) <;> nlinarith [ Int.ediv_mul_cancel ( show q ∣ 2 * p - q from Int.pow_dvd_pow_iff two_ne_zero |>.1 ⟨ 5, by linarith ⟩ ) ] ⟩;
  exact absurd h_perfect_square ( by rintro ⟨ r, hr ⟩ ; nlinarith [ show r ≤ 2 by nlinarith, show r ≥ -2 by nlinarith ] )

/-
Hence `|p² - pq - q²| ≥ 1`.
-/
lemma one_le_abs_norm (p q : ℤ) (hq : 1 ≤ q) :
    (1 : ℝ) ≤ |((p : ℝ) ^ 2 - p * q - q ^ 2)| := by
  exact mod_cast abs_pos.mpr ( norm_ne_zero p q hq )

/-
**Binet-type identity.** `fib (n+1) - φ · fib n = ψ ^ n`.
-/
lemma fib_binet (n : ℕ) :
    (Nat.fib (n + 1) : ℝ) - phi * (Nat.fib n : ℝ) = psi ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ pow_succ', Nat.fib_add_two ] at *;
  · unfold phi psi; ring;
  · convert congr_arg₂ ( · + · ) ( ih n ( by linarith ) ) ( ih ( n + 1 ) ( by linarith ) ) using 1 <;> push_cast [ Nat.fib_add_two ] <;> ring;
    rw [ show psi ^ 2 = psi + 1 by exact psi_sq ] ; ring

/-
**Fibonacci linear forms for `φ`.**  For every `ε > 0` there is a Fibonacci
linear form `fib n · φ - fib (n+1)` that is nonzero yet has absolute value
`< ε`.  This is the continued-fraction content (convergents of
`φ = [1;1,1,…]` are `fib (n+1)/fib n`), packaged as the hypothesis of the
catalog Diophantine engine.  It cannot be reduced to a bare irrationality
fact: it is the *quantitative* statement that the forms `-ψⁿ → 0`.
-/
theorem phi_small_linear_forms :
    ∀ ε : ℝ, 0 < ε → ∃ (q : ℕ) (p : ℤ),
      1 ≤ q ∧ 0 < |(q : ℝ) * phi - (p : ℝ)| ∧ |(q : ℝ) * phi - (p : ℝ)| < ε := by
  intro ε hε;
  obtain ⟨ N, hN ⟩ := exists_pow_lt_of_lt_one hε ( abs_psi_lt_one );
  refine' ⟨ Nat.fib ( N + 1 ), Nat.fib ( N + 2 ), _, _, _ ⟩ <;> norm_num;
  · exact Nat.fib_pos.mpr ( Nat.succ_pos _ );
  · convert fib_binet ( N + 1 ) |> fun h => h.symm ▸ neg_ne_zero.mpr ( pow_ne_zero _ <| show psi ≠ 0 from div_ne_zero ( sub_ne_zero_of_ne <| by nlinarith [ Real.sq_sqrt <| show 0 ≤ 5 by norm_num ] ) two_ne_zero ) using 1 ; ring;
  · have := fib_binet ( N + 1 );
    rw [ show ( Nat.fib ( N + 1 ) : ℝ ) * phi - Nat.fib ( N + 2 ) = - ( psi ^ ( N + 1 ) ) by linarith ] ; norm_num [ abs_mul, abs_neg, abs_of_pos, hε ];
    exact lt_of_le_of_lt ( pow_le_pow_of_le_one ( abs_nonneg _ ) ( abs_le.mpr ⟨ by rw [ psi ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ], by rw [ psi ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ⟩ ) ( Nat.le_succ _ ) ) hN

/-
**`φ` is irrational, via the catalog Diophantine engine.**  We feed the
Fibonacci linear forms `phi_small_linear_forms` into the engine
`EulerMascheroni.irrational_of_forall_eps_linear_form` imported from the
catalog file `Catalog.NumberTheory.Irrationality`.  This is the
continued-fraction route to irrationality.
-/
theorem irrational_phi : Irrational phi :=
  EulerMascheroni.irrational_of_forall_eps_linear_form phi phi_small_linear_forms

/-
**The golden ratio is badly approximable.**  For all integers `p` and
`q ≥ 1`, `|φ - p/q| ≥ (1/3)/q²`.
-/
theorem badly_approximable (p q : ℤ) (hq : 1 ≤ q) :
    (1 / 3 : ℝ) / (q : ℝ) ^ 2 ≤ |phi - (p : ℝ) / (q : ℝ)| := by
  rw [ div_le_iff₀ ( by positivity ) ];
  -- Let $t = |p - q \phi|$.
  set t := |(p : ℝ) - q * phi| with ht

  -- Then $t / q = |phi - p / q|$.
  have ht_div : t / (q : ℝ) = |phi - p / q| := by
    rw [ sub_div', abs_div ] <;> norm_num [ show q ≠ 0 by linarith ];
    rw [ abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ q ), abs_sub_comm, mul_comm ];
  -- Lower bound on `|norm|`: by `norm_form`, `((p:ℝ) - Q*phi)*((p:ℝ) - Q*psi) = (p:ℝ)^2 - p*q - q^2`, and by `one_le_abs_norm`, `1 ≤ |(p:ℝ)^2 - p*q - q^2| = |(p - Q*phi)*(p - Q*psi)| = t * |p - Q*psi|`.
  have h_lower_bound : 1 ≤ t * |(p : ℝ) - q * psi| := by
    convert one_le_abs_norm p q hq using 1;
    rw [ ← abs_mul, GoldenRatio.norm_form ];
  -- Upper bound on `|p - Q*psi|`: `p - Q*psi = (p - Q*phi) + Q*(phi - psi) = (p - Q*phi) + Q*√5` (using `phi_sub_psi`).
  have h_upper_bound : |(p : ℝ) - q * psi| ≤ t + q * Real.sqrt 5 := by
    rw [ show ( p : ℝ ) - q * psi = ( p - q * phi ) + q * ( phi - psi ) by ring, phi_sub_psi ] ; exact abs_le.mpr ⟨ by cases abs_cases ( ( p : ℝ ) - q * phi ) <;> nlinarith [ Real.sqrt_nonneg 5, ( by norm_cast : ( 1 :ℝ ) ≤ q ) ], by cases abs_cases ( ( p : ℝ ) - q * phi ) <;> nlinarith [ Real.sqrt_nonneg 5, ( by norm_cast : ( 1 :ℝ ) ≤ q ) ] ⟩ ;
  rw [ ← ht_div, div_mul_eq_mul_div, le_div_iff₀ ] <;> try positivity;
  by_cases h_case : t < 1 / 3;
  · nlinarith [ show ( q : ℝ ) ≥ 1 by norm_cast, show ( Real.sqrt 5 : ℝ ) < 8 / 3 by rw [ Real.sqrt_lt ] <;> norm_num, abs_nonneg ( ( p : ℝ ) - q * phi ), abs_nonneg ( ( p : ℝ ) - q * psi ), mul_le_mul_of_nonneg_left h_case.le ( show ( 0 : ℝ ) ≤ q by positivity ) ];
  · nlinarith [ show ( q : ℝ ) ≥ 1 by norm_cast, show ( q : ℝ ) ^ 2 ≥ q by norm_cast; nlinarith ]

/-
**The golden ratio is not a Liouville number.**
-/
theorem not_liouville : ¬ Liouville phi := by
  by_contra h_contra;
  obtain ⟨a, b, hb, hlt⟩ : ∃ a b : ℤ, 1 < b ∧ |phi - (a : ℝ) / (b : ℝ)| < 1 / (b : ℝ) ^ 4 := by
    obtain ⟨ a, b, hb, hlt ⟩ := h_contra 4;
    exact ⟨ a, b, hb, hlt.2 ⟩;
  -- Apply `badly_approximable` to get hge : (1/3)/(b:ℝ)^2 ≤ |phi - (a:ℝ)/(b:ℝ)|.
  have hge : (1 / 3 : ℝ) / (b : ℝ) ^ 2 ≤ |phi - (a : ℝ) / (b : ℝ)| := by
    convert badly_approximable a b ( by linarith ) using 1;
  rw [ div_le_iff₀ ( by positivity ) ] at hge;
  rw [ lt_div_iff₀ ( by positivity ) ] at hlt;
  nlinarith [ show ( b : ℝ ) ≥ 2 by norm_cast, pow_pos ( by positivity : 0 < ( b : ℝ ) ) 3, pow_pos ( by positivity : 0 < ( b : ℝ ) ) 4 ]

end GoldenRatio