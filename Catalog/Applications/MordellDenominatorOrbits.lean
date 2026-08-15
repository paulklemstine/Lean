import Applications.MordellDenominatorFiltration

/-!
# Orbits: a single point whose multiples fail the conjecture in *both* directions

Cycle 1 (`Shared.MordellDenominatorPrimes`) produced a good-reduction prime inside a
denominator; cycle 2 (`Shared.MordellDenominatorBarriers`) produced, on a *different* curve, a
point whose denominator misses both prime factors of `N`.  A sceptic could still hope that the
two failures never happen simultaneously — that a denominator either detects `p` or `q`, or is
"explained" by the bad primes.

This file kills that hope on a single curve and a single point, using Mathlib's group law and
no numerical postulates: for `E_55 : y² = x³ + 55` and `P = (9,28)`,

`x(3P) = -2302089191/656538129`,  `656538129 = 3⁶ · 13² · 73²`,

so the denominator of `x(3P)` is divisible by the good-reduction primes `13` and `73` and is
coprime to both `5` and `11`.  A *single* multiple of a *single* point therefore violates the
"only bad primes" conjecture and the "denominators reveal the factorisation" heuristic at the
same time.

Combining with `Applications.MordellDenominatorFiltration`, `13` then persists through the
whole `2`-power sub-orbit of `3P`, and the phenomenon is not special to `55`: for every prime
`ℓ ≥ 5` there is a Mordell curve with good reduction at `ℓ` carrying a point whose entire
`2`-power orbit has `ℓ` in the denominator.

## Main results

* `xCoord_triple_55` : `x(3P) = -2302089191/656538129`, computed inside Mathlib's group law
  (`add_self_of_Y_ne` followed by `add_of_X_ne`), not postulated.
* `den_triple_55` : the denominator is `3⁶ · 13² · 73²`.
* `two_sided_failure_55` : on one curve, at one point, a good prime divides the denominator
  while neither prime factor of `N = 5 · 11` does.
* `thirteen_dvd_den_two_pow_triple_55` : `13` divides the denominator of `x(2^k · 3P)` for all
  `k`.
* `good_prime_persists_two_pow` : for every prime `ℓ ≥ 5` there are `N` and a rational point
  `Q` of `E_N` with good reduction at `ℓ` such that `ℓ` divides the denominator of every
  `x(2^k Q)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 4): the two barriers (good primes intrude, bad primes vanish)
  are two faces of the same fact and should be observable at one point.
Experiment (Experimenter): rational arithmetic on `E_55`, `P = (9,28)` gives the denominators
  `1, 3136 = 2⁶·7², 656538129 = 3⁶·13²·73², 2149853638045926⋯` for `n = 1,2,3,4`.  At `n = 3`
  the prime factors are `{3, 13, 73}`: `13` and `73` are of good reduction and `5, 11` are
  absent.  The Lean proof recomputes `x(3P)` through the Weierstrass group law and checks the
  factorisation with `norm_num`.
Analysis (Analyst): every prime in the list is either `2, 3` (the primes dividing the constant
  `4` and the constant `9` appearing in the numerator identity `x⁴ − 8Nx = x(y² − 9N)`) or a
  prime at which the point reduces into the kernel of reduction.  Membership in that kernel is
  governed by `E_N(𝔽_ℓ)`, not by the factorisation of `N`; hence the denominators are a
  function of the *curve*, and the factorisation of `N` is invisible in them.
Critique (Critic): the computation of `3P` is the delicate point, so it is done with Mathlib's
  `Point.add_self_of_Y_ne` and `Point.add_of_X_ne` — the two branches of the affine group law —
  rather than by quoting the classical formulas.  The general statement
  `good_prime_persists_two_pow` guards against the objection that `55` might be special.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## The point `P = (9, 28)` on `E_55`, with integral parameter -/

/-- `(9, 28)` is a nonsingular point of `E_55 : y² = x³ + 55`, with `55` written as an
integer (matching the parametrisation used in `Applications.MordellDenominatorFiltration`). -/
lemma nonsingular_int_55_9_28 : (mordell (((55 : ℤ)) : ℚ)).toAffine.Nonsingular 9 28 := by
  have hΔ : (mordell (((55 : ℤ)) : ℚ)).Δ ≠ 0 := by rw [mordell_Δ]; norm_num
  exact (WeierstrassCurve.Affine.equation_iff_nonsingular_of_Δ_ne_zero hΔ).mp
    ((mordell_equation_iff _ _ _).mpr (by norm_num))

/-- `28 ≠ negY(9, 28)` on `E_55`, i.e. `P` is not `2`-torsion. -/
lemma negY_ne_55 : (28 : ℚ) ≠ (mordell (((55 : ℤ)) : ℚ)).toAffine.negY 9 28 := by
  simp [WeierstrassCurve.Affine.negY, mordell]
  norm_num

/-! ## Tripling `P` inside Mathlib's group law -/

/-- **The triple point.**  Applying the two branches of the affine group law
(`add_self_of_Y_ne` to get `2P`, then `add_of_X_ne` to add `P`) gives
`x(3P) = -2302089191/656538129` on `E_55`. -/
theorem xCoord_triple_55 :
    xCoord (Point.some nonsingular_int_55_9_28 + Point.some nonsingular_int_55_9_28
      + Point.some nonsingular_int_55_9_28) = some (-2302089191 / 656538129 : ℚ) := by
  rw [WeierstrassCurve.Affine.Point.add_self_of_Y_ne negY_ne_55]
  rw [WeierstrassCurve.Affine.Point.add_of_X_ne (by
    simp [WeierstrassCurve.Affine.addX, mordell]
    norm_num)]
  simp only [xCoord, WeierstrassCurve.Affine.addX, mordell]
  norm_num

/-- The denominator of `x(3P)` is `3⁶ · 13² · 73²`. -/
theorem den_triple_55 : ((-2302089191 / 656538129 : ℚ)).den = 3 ^ 6 * 13 ^ 2 * 73 ^ 2 := by
  norm_num

/-! ## Two-sided failure at one point -/

/-- **Simultaneous failure of both heuristics.**  On `E_55 : y² = x³ + 55` with `55 = 5 · 11`
and `P = (9, 28)`, the third multiple `3P` has
`x(3P) = -2302089191/656538129 = -2302089191/(3⁶·13²·73²)`.  Its denominator

* is divisible by `13` and by `73`, both primes of **good** reduction (`ℓ ∤ Δ = -432·55²`);
* is divisible by **neither** `5` nor `11`, the prime factors of `N`.

Hence at this single point the "only bad primes" conjecture fails and the denominator carries
no trace of the factorisation of `N`. -/
theorem two_sided_failure_55 :
    ∃ X : ℚ, xCoord (Point.some nonsingular_int_55_9_28 + Point.some nonsingular_int_55_9_28
        + Point.some nonsingular_int_55_9_28) = some X ∧
      13 ∣ X.den ∧ 73 ∣ X.den ∧ ¬(5 ∣ X.den) ∧ ¬(11 ∣ X.den) ∧
      ¬(13 : ℤ) ∣ (mordell (55 : ℤ)).Δ ∧ ¬(73 : ℤ) ∣ (mordell (55 : ℤ)).Δ := by
  refine ⟨-2302089191 / 656538129, xCoord_triple_55, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [den_triple_55]; exact ⟨3 ^ 6 * 13 * 73 ^ 2, by ring⟩
  · rw [den_triple_55]; exact ⟨3 ^ 6 * 13 ^ 2 * 73, by ring⟩
  · rw [den_triple_55]; norm_num
  · rw [den_triple_55]; norm_num
  · exact not_dvd_Δ (ℓ := 13) (by norm_num) (by norm_num) (by decide)
  · exact not_dvd_Δ (ℓ := 73) (by norm_num) (by norm_num) (by decide)

/-- **The good prime `13` persists.**  Since `13` is odd and divides the denominator of
`x(3P)`, the invariance law of `Applications.MordellDenominatorFiltration` propagates it to the
entire `2`-power sub-orbit: `13 ∣ den x(2^k · 3P)` for every `k`. -/
theorem thirteen_dvd_den_two_pow_triple_55 (k : ℕ) :
    ∀ X : ℚ, xCoord ((2 ^ k) • (Point.some nonsingular_int_55_9_28
      + Point.some nonsingular_int_55_9_28 + Point.some nonsingular_int_55_9_28))
        = some X → 13 ∣ X.den := by
  refine kernel_stable_two_pow (N := 55) (ℓ := 13) (by norm_num) (by norm_num)
    (X := (-2302089191 / 656538129 : ℚ)) xCoord_triple_55 ?_ k
  rw [den_triple_55]
  exact ⟨3 ^ 6 * 13 * 73 ^ 2, by ring⟩

/-! ## The phenomenon is generic: every prime `ℓ ≥ 5` has a persistent orbit -/

/-- **Persistence for every prime.**  For each prime `ℓ ≥ 5` there is a Mordell curve `E_N`
with **good reduction at `ℓ`** and a rational point `Q` of `E_N` such that `ℓ` divides the
denominator of the `x`-coordinate of `2^k Q` for **every** `k`.

Witness: `N = ℓ² − 1`, `P = (1, ℓ)`, `Q = 2P`.  Thus the failure of the "only bad primes"
conjecture is not a sporadic coincidence but a stable feature of the `2`-power orbits of
Mordell curves. -/
theorem good_prime_persists_two_pow {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) :
    ∃ (N : ℤ) (Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point),
      ¬(ℓ : ℤ) ∣ (mordell N).Δ ∧
      ∀ (k : ℕ) (X : ℚ), xCoord ((2 ^ k) • Q) = some X → ℓ ∣ X.den := by
  have hl0 : (5 : ℤ) ≤ (ℓ : ℤ) := by exact_mod_cast hl5
  set N : ℤ := (ℓ : ℤ) ^ 2 - 1 with hN
  have hN0 : N ≠ 0 := by rw [hN]; nlinarith
  have hlN : ¬(ℓ : ℤ) ∣ N := by
    rw [hN]
    intro hdvd
    have h2 : (ℓ : ℤ) ∣ (ℓ : ℤ) ^ 2 := dvd_pow_self _ (by norm_num)
    have h1 : (ℓ : ℤ) ∣ 1 := by simpa using dvd_sub h2 hdvd
    have := Int.le_of_dvd (by norm_num) h1
    omega
  have hΔ : (mordell ((N : ℤ) : ℚ)).Δ ≠ 0 := by
    rw [mordell_Δ]
    have : ((N : ℤ) : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hN0
    simp [this]
  have heqQ : ((ℓ : ℤ) : ℚ) ^ 2 = (1 : ℚ) ^ 3 + ((N : ℤ) : ℚ) := by
    rw [hN]; push_cast; ring
  have hns : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular 1 ((ℓ : ℤ) : ℚ) :=
    (WeierstrassCurve.Affine.equation_iff_nonsingular_of_Δ_ne_zero hΔ).mp
      ((mordell_equation_iff _ _ _).mpr heqQ)
  have hy0 : (((ℓ : ℤ) : ℚ)) ≠ 0 := by
    have : (0 : ℚ) < ((ℓ : ℤ) : ℚ) := by exact_mod_cast (by omega : (0 : ℤ) < (ℓ : ℤ))
    exact ne_of_gt this
  refine ⟨N, Point.some hns + Point.some hns, not_dvd_Δ hl hl5 hlN, ?_⟩
  -- the `x`-coordinate of `2P`, and the fact that `ℓ` divides its denominator
  have hx2 := mordell_double_xCoord ((N : ℤ) : ℚ) 1 ((ℓ : ℤ) : ℚ) hns hy0
  refine kernel_stable_two_pow (N := N) hl (by omega)
    (X := ((1 : ℚ) ^ 4 - 8 * ((N : ℤ) : ℚ) * 1) / (4 * ((ℓ : ℤ) : ℚ) ^ 2)) hx2 ?_
  have hkey := (dvd_den_double_iff (N := N) (x := 1) (y := (ℓ : ℤ))
    (by rw [hN]; ring) (by omega) hl hl5 hlN).mpr dvd_rfl
  have hcast : (((1 : ℤ) : ℚ) ^ 4 - 8 * ((N : ℤ) : ℚ) * ((1 : ℤ) : ℚ)) /
      (4 * (((ℓ : ℤ)) : ℚ) ^ 2)
      = ((1 : ℚ) ^ 4 - 8 * ((N : ℤ) : ℚ) * 1) / (4 * ((ℓ : ℤ) : ℚ) ^ 2) := by
    push_cast; ring
  rwa [hcast] at hkey

end MordellDenominators