import Mathlib
import Pythagorean.GaussianPythagorean
import Pythagorean.TripleDivisibility

/-! # Pythagorean.LegRealizability

Which integers occur as a *leg* of a Pythagorean triple, and what the resulting
triangles look like.

Main results:

* `every_int_ge_three_is_leg` — every integer `n ≥ 3` is a leg of some Pythagorean
  triple with a strictly larger hypotenuse (explicit construction, split on parity);
* `parametrization_area_six` — the area of any triangle produced by the classical
  parametrization `(m²−n², 2mn, m²+n²)` is a multiple of `6`, obtained by feeding the
  parametrization into `Pythagorean.TripleDivisibility.six_dvd_area`;
* `gaussian_parametrization_is_triple` — a direct reuse of the Gaussian-integer
  parametrization identity from the catalog file `Pythagorean.GaussianPythagorean`,
  recording that the same algebraic identity underlies both the integer and the `ℤ[i]`
  worlds.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the set of legs is cofinite in `ℕ` — precisely the
--   integers `≥ 3`. Bold form: *every* sufficiently large integer is a leg, with an
--   explicit closed-form partner.
-- Experiment (Experimenter): for odd `n = 2k+1`, take `((n²−1)/2, (n²+1)/2)`, giving
--   `c − b = 1`, `c + b = n²`; for even `n = 2k`, take `(k²−1, k²+1)`. Both verified by
--   `ring` after substitution; positivity by `nlinarith` using `n ≥ 3`.
-- Analysis (Analyst): the two constructions are the "descent partners" c∓b of the
--   factorisation n² = (c−b)(c+b); the parity split is exactly whether that factor pair
--   is (1, n²) or (2, n²/2).
-- Critique (Critic): the construction fails for n ≤ 2 (there b would be 0), consistent
--   with 1,2 not being legs — so the `3 ≤ n` hypothesis is sharp, not cosmetic.
-- Synthesis (PI): combined with the catalog Gaussian identity and the divisibility file
--   to show every parametrised triangle has area divisible by 6.
-/

namespace Pythagorean.LegRealizability

/-- **Every integer `n ≥ 3` is a leg of a Pythagorean triple** with a strictly larger
    hypotenuse: there exist `0 < b < c` with `n² + b² = c²`. -/
theorem every_int_ge_three_is_leg (n : ℤ) (hn : 3 ≤ n) :
    ∃ b c : ℤ, n ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < b ∧ b < c := by
  rcases Int.even_or_odd n with ⟨k, hk⟩ | ⟨k, hk⟩
  · -- n = k + k is even
    refine ⟨k ^ 2 - 1, k ^ 2 + 1, ?_, ?_, ?_⟩
    · subst hk; ring
    · nlinarith [hn, hk]
    · nlinarith [hn, hk]
  · -- n = 2k + 1 is odd
    refine ⟨2 * k ^ 2 + 2 * k, 2 * k ^ 2 + 2 * k + 1, ?_, ?_, ?_⟩
    · subst hk; ring
    · nlinarith [hn, hk]
    · nlinarith [hn, hk]

/-- Direct reuse of the catalog's Gaussian-integer parametrization identity
    (`Pythagorean.GaussianPythagorean.parametrization_identity`): the classical triple
    identity holds verbatim over `ℤ[i]`. -/
theorem gaussian_parametrization_is_triple (m n : GaussianInt) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 :=
  GaussianPythagorean.parametrization_identity m n

/-- The integer parametrization always yields a Pythagorean triple. -/
theorem parametrization_is_triple (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring

/-- **Area of a parametrised triangle is a multiple of 6.**
    The triangle with legs `a = m²−n²` and `b = 2mn` has area `A = (m²−n²)·m·n`, and
    `6 ∣ A`.  This chains the parametrization with
    `Pythagorean.TripleDivisibility.six_dvd_area`. -/
theorem parametrization_area_six (m n : ℤ) :
    (6 : ℤ) ∣ (m ^ 2 - n ^ 2) * m * n := by
  have htriple := parametrization_is_triple m n
  refine Pythagorean.TripleDivisibility.six_dvd_area
    (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) ((m ^ 2 - n ^ 2) * m * n) htriple ?_
  ring

/-- Non-vacuity: `5` is a leg (of `(5,12,13)`), witnessed by the general construction. -/
example : ∃ b c : ℤ, (5 : ℤ) ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < b ∧ b < c :=
  every_int_ge_three_is_leg 5 (by norm_num)

end Pythagorean.LegRealizability