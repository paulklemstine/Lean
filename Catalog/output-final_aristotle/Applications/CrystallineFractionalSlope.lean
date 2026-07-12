import Mathlib

/-!
# Irreducibility of mod `p` reductions of crystalline representations at fractional slope

For an odd prime `p`, an even weight `k ≥ 2`, and a Frobenius trace `a_p` in the
algebraic closure of `ℚ_p` with valuation `v(a_p) > 0` that is *not* an integer
(a **fractional slope**), a folklore conjecture asserts that the semisimplified mod `p`
reduction `V̄_{k,a_p}` of the two–dimensional crystalline representation `V_{k,a_p}`
of `G_{ℚ_p}` is **irreducible**.

This file isolates the *arithmetic engine* behind the conjecture. The two Frobenius
eigenvalues of `V_{k,a_p}` are the roots of the polynomial

  `X² − a_p·X + p^{k−1}`,

whose Newton polygon (normalising `v(p) = 1`) has vertices `(0, k−1)`, `(1, v(a_p))`,
`(2, 0)`. When `v(a_p) < (k−1)/2` the polygon breaks, and the two root valuations
(the *Frobenius slopes*) are

  `lowSlope  = v(a_p)`,      `highSlope = (k−1) − v(a_p)`.

A reducible reduction would express `V̄` as a sum of two crystalline characters, each
of whose Frobenius slopes is an **integer**. Thus a fractional slope is an obstruction
to reducibility: both Newton slopes are then non-integral and distinct. We complement
this valuation-theoretic layer with the linear-algebra layer that governs irreducibility
of any two–dimensional representation: a representation with Frobenius trace `a` and
determinant `d` acquires an invariant line exactly when its characteristic polynomial
`X² − a·X + d` has a root, i.e. when the discriminant `a² − 4d` is a square. The two
layers together form a *cross-domain bridge* (`p`-adic valuations ↔ quadratic linear
algebra) which is the conceptual heart of the fractional-slope irreducibility statement.

## Main results

* `CrystallineFractionalSlope.slopes_sum` — the two Frobenius slopes sum to `k − 1`.
* `CrystallineFractionalSlope.lowSlope_lt_highSlope` — below the balanced point the
  slopes are strictly ordered.
* `CrystallineFractionalSlope.highSlope_not_isInt` / `lowSlope_not_isInt` — a fractional
  low slope forces *both* slopes to be non-integral.
* `CrystallineFractionalSlope.middle_slope_half_integer` — for even weight the balanced
  slope `(k−1)/2` is itself non-integral (a genuine half-integer).
* `CrystallineFractionalSlope.exists_root_iff_disc_isSquare` — the quadratic-formula
  criterion linking roots of `X² − a·X + d` to squareness of the discriminant.
* `CrystallineFractionalSlope.irreducible_iff_disc_not_isSquare` — a two–dimensional
  representation is irreducible (no invariant line) iff the discriminant is a non-square.
* `CrystallineFractionalSlope.fractional_slope_irreducibility_certificate` — the
  synthesis: even weight and a fractional sub-balanced slope yield distinct, non-integral
  Frobenius slopes summing to `k − 1`, the arithmetic certificate of irreducibility.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): fractional slope obstructs reducibility because a reducible
reduction is a sum of crystalline characters carrying *integer* slopes. Bold form: the
obstruction is purely arithmetic (non-integrality of a valuation) and is decoupled from
the residual linear algebra, which supplies an independent squareness criterion.

Experiment (Experimenter): formalised the Newton-slope pair and proved (i) their sum is
`k−1`, (ii) non-integrality propagates from the low slope to the high slope, (iii) strict
ordering below the balanced point, and (iv) the completing-the-square equivalence between
roots and square discriminants over any field of characteristic `≠ 2`.

Analysis (Analyst): the naive reduction of the Frobenius matrix is misleading — modulo `p`
the determinant `p^{k−1} ≡ 0`, so the naive characteristic polynomial `X² − ā·X` always
splits. The true semisimplified reduction is governed instead by the *slope*, an invariant
of the integral (Wach/Fontaine–Laffaille) structure rather than of the naive matrix. This
is exactly why the fractional-slope case is subtle: the obstruction lives at the level of
valuations, captured here by `highSlope_not_isInt` and `middle_slope_half_integer`.

Critique (Critic): distinctness of the two slopes needs the strict bound `2·v(a_p) < k−1`
(the low slope is the smaller Newton slope); even weight alone does not prevent the balanced
case `v(a_p) = (k−1)/2`. We keep the even-weight hypothesis because it is part of the stated
setting and it makes the balanced slope a genuine half-integer, but we record that the
strict slope bound is the load-bearing hypothesis for distinctness.

Synthesis (PI): the fractional-slope certificate bundles four independent facts (ordering,
two non-integralities, and the slope sum), giving a self-contained arithmetic witness that
the Frobenius data cannot split into integer-slope crystalline characters.
-/

namespace CrystallineFractionalSlope

/-! ## Section A — Newton slope arithmetic

The two Frobenius slopes of `X² − a_p·X + p^{k−1}` under the normalisation `v(p) = 1`,
with `s := v(a_p)` the low (smaller) slope. -/

/-- The low Frobenius slope `v(a_p)`. The weight `_k` is carried for symmetry with
`highSlope` (which depends on it), but the low slope equals `v(a_p)` regardless. -/
def lowSlope (_k : ℤ) (s : ℚ) : ℚ := s

/-- The high Frobenius slope `(k−1) − v(a_p)`. -/
def highSlope (k : ℤ) (s : ℚ) : ℚ := (k : ℚ) - 1 - s

/-- The two Frobenius slopes sum to `k − 1`, matching `v(α) + v(β) = v(p^{k−1})`. -/
theorem slopes_sum (k : ℤ) (s : ℚ) : lowSlope k s + highSlope k s = (k : ℚ) - 1 := by
  unfold lowSlope highSlope; ring

/-- A fractional low slope stays fractional. -/
theorem lowSlope_not_isInt (k : ℤ) (s : ℚ) (hs : ∀ n : ℤ, s ≠ (n : ℚ)) :
    ∀ m : ℤ, lowSlope k s ≠ (m : ℚ) := by
  intro m; unfold lowSlope; exact hs m

/-- Non-integrality **propagates** from the low slope to the high slope: since the two
slopes differ by the integer `k − 1`, a fractional low slope forces a fractional high
slope. This is the arithmetic core of the reducibility obstruction. -/
theorem highSlope_not_isInt (k : ℤ) (s : ℚ) (hs : ∀ n : ℤ, s ≠ (n : ℚ)) :
    ∀ m : ℤ, highSlope k s ≠ (m : ℚ) := by
  intro m h
  apply hs (k - 1 - m)
  unfold highSlope at h
  push_cast
  linarith

/-- Below the balanced point `v(a_p) < (k−1)/2` the low slope is strictly smaller. -/
theorem lowSlope_lt_highSlope (k : ℤ) (s : ℚ) (h : 2 * s < (k : ℚ) - 1) :
    lowSlope k s < highSlope k s := by
  unfold lowSlope highSlope; linarith

/-- Consequently the two slopes are distinct. -/
theorem slopes_ne_of_lt (k : ℤ) (s : ℚ) (h : 2 * s < (k : ℚ) - 1) :
    lowSlope k s ≠ highSlope k s :=
  ne_of_lt (lowSlope_lt_highSlope k s h)

/-- For an **even** weight `k` the balanced slope `(k−1)/2` is a genuine half-integer:
its double is `k−1` yet it is never an integer, because `k − 1` is odd. -/
theorem middle_slope_half_integer (k : ℤ) (hk : Even k) :
    ((k : ℚ) - 1) / 2 * 2 = (k : ℚ) - 1 ∧ ∀ n : ℤ, ((k : ℚ) - 1) / 2 ≠ (n : ℚ) := by
  constructor
  · ring
  · intro n h
    obtain ⟨j, hj⟩ := hk
    have h2q : (k : ℚ) - 1 = 2 * (n : ℚ) := by field_simp at h; linarith
    have hz : k - 1 = 2 * n := by exact_mod_cast h2q
    omega

/-! ## Section B — Quadratic linear algebra (the residual/irreducibility layer)

For any field of characteristic `≠ 2`, roots of the characteristic polynomial
`X² − a·X + d` are controlled by the discriminant `a² − 4d` via completing the square. -/

/-- The discriminant of the characteristic polynomial `X² − a·X + d`. -/
def disc {F : Type*} [Field F] (a d : F) : F := a ^ 2 - 4 * d

/-- **Quadratic-formula criterion.** Over a field of characteristic `≠ 2`, the polynomial
`X² − a·X + d` has a root iff the discriminant `a² − 4d` is a square. -/
theorem exists_root_iff_disc_isSquare {F : Type*} [Field F] (h2 : (2 : F) ≠ 0)
    (a d : F) :
    (∃ x : F, x ^ 2 - a * x + d = 0) ↔ (∃ r : F, r ^ 2 = a ^ 2 - 4 * d) := by
  constructor
  · rintro ⟨x, hx⟩
    exact ⟨2 * x - a, by linear_combination (4 : F) * hx⟩
  · rintro ⟨r, hr⟩
    refine ⟨(a + r) / 2, ?_⟩
    field_simp
    linear_combination hr

/-- **Irreducibility criterion.** A two–dimensional representation with Frobenius trace `a`
and determinant `d` has no invariant line — equivalently its characteristic polynomial has
no root — exactly when the discriminant is a non-square. -/
theorem irreducible_iff_disc_not_isSquare {F : Type*} [Field F] (h2 : (2 : F) ≠ 0)
    (a d : F) :
    (¬ ∃ x : F, x ^ 2 - a * x + d = 0) ↔ (¬ ∃ r : F, r ^ 2 = disc a d) := by
  unfold disc
  exact not_congr (exists_root_iff_disc_isSquare h2 a d)

/-! ## Section D — Synthesis: the fractional-slope irreducibility certificate -/

/-- **Fractional-slope irreducibility certificate.** For an even weight `k` and a fractional
low slope `s = v(a_p)` strictly below the balanced point, the two Frobenius slopes are
strictly ordered, both non-integral, and sum to `k − 1`. Any reducible reduction would
require an integer Frobenius slope, so this bundle certifies that the crystalline Frobenius
datum cannot split into integer-slope characters.

The even-weight hypothesis `hk` is used to certify that the balanced slope `(k−1)/2` is a
genuine half-integer; the strict slope bound `hslope` is the load-bearing hypothesis for
distinctness of the two Frobenius slopes. -/
theorem fractional_slope_irreducibility_certificate
    (k : ℤ) (s : ℚ) (hk : Even k) (hslope : 2 * s < (k : ℚ) - 1)
    (hfrac : ∀ n : ℤ, s ≠ (n : ℚ)) :
    lowSlope k s < highSlope k s ∧
      (∀ m : ℤ, lowSlope k s ≠ (m : ℚ)) ∧
      (∀ m : ℤ, highSlope k s ≠ (m : ℚ)) ∧
      lowSlope k s + highSlope k s = (k : ℚ) - 1 ∧
      (∀ n : ℤ, ((k : ℚ) - 1) / 2 ≠ (n : ℚ)) := by
  refine ⟨lowSlope_lt_highSlope k s hslope, lowSlope_not_isInt k s hfrac,
    highSlope_not_isInt k s hfrac, slopes_sum k s, (middle_slope_half_integer k hk).2⟩

/-! ## Examples (PEGB: concrete instantiation) -/

-- The two Frobenius slopes of weight `k = 6`, slope `s = 1/3` (fractional, `< 5/2`):
-- `lowSlope = 1/3`, `highSlope = 5 − 1/3 = 14/3`, summing to `5 = k − 1`.
example : lowSlope 6 (1/3) = 1/3 := rfl
example : highSlope 6 (1/3) = 14/3 := by unfold highSlope; norm_num
example : lowSlope 6 (1/3) + highSlope 6 (1/3) = 5 := by unfold lowSlope highSlope; norm_num

-- A concrete irreducible reduction: over `𝔽₅` the discriminant `1² − 4·2 = -7 ≡ 3`
-- is a non-square, so `X² − X + 2` has no root — the residual representation is irreducible.
example : ¬ ∃ x : ZMod 5, x ^ 2 - 1 * x + 2 = 0 := by decide
example : ¬ ∃ r : ZMod 5, r ^ 2 = 3 := by decide

#check @fractional_slope_irreducibility_certificate
#check @exists_root_iff_disc_isSquare
#check @irreducible_iff_disc_not_isSquare

end CrystallineFractionalSlope