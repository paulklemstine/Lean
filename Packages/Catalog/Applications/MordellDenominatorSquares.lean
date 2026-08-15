import Shared.MordellDenominatorBarriers

/-!
# The square-denominator law for Mordell curves, and the thinness of the denominator spectrum

`Catalog/Shared/MordellDenominatorPrimes.lean`, `…Valuations.lean` and `…Barriers.lean`
analysed the denominator of the *doubled* point `x(2P)` on a Mordell curve
`E_N : y² = x³ + N` and refuted the "only bad primes" conjecture.  All of that analysis was
local: it fixed one prime `ℓ` and one operation (doubling).

This file supplies the *global* structural law that governs **every** rational point of
**every** Mordell curve, hence in particular every multiple `nP`:

> if `(x, y) ∈ E_N(ℚ)` with `N ∈ ℤ`, then `den(x) = e²` and `den(y) = e³` for a single
> integer `e`.

Consequently every denominator prime occurs to an **even** exponent in `den x(nP)`.  This
turns the earlier "`7² ∥ den x(2P)`" numerical observation into a theorem valid for all `n`,
and it produces a hard obstruction in the opposite direction: a denominator which is not a
perfect square is *impossible*, so the set of achievable denominators has counting function
`≤ √X` — the denominators of an orbit are extremely thin inside ℕ.

## Main results

* `mordell_den_cube_eq_sq` : `den(x)³ = den(y)²` for any rational point of `y² = x³ + N`.
* `mordell_den_pow_structure` : the parametrisation `den x = e²`, `den y = e³`.
* `mordell_x_den_isSquare` : the `x`-denominator is a perfect square.
* `mordell_prime_sq_dvd_den` : if a prime `ℓ` divides `den x` then already `ℓ² ∣ den x`
  and `ℓ³ ∣ den y`: the shadow of the formal-group filtration.
* `point_x_den_isSquare`, `nsmul_x_den_isSquare` : the same for Mathlib's group-law points
  and for all multiples `n • P`, so the law is stable along the whole orbit.
* `den_seven_impossible`, `nonsquare_den_impossible` : denominators that can never occur;
  e.g. no point of `E_55(ℚ)` has `x`-denominator `7`, although `7` genuinely occurs
  (squared) in `den x(2P)`.
* `card_achievable_den_le_sqrt` : the achievable denominators below `n` number at most
  `√n + 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 3): the previous cycles showed `v_7(den x(2P)) = 2` for the
  counterexample `N = 55`, `P = (9,28)`, and `v_3 = 6`, `v_2 = 6` — all even.  Bold conjecture:
  *every* denominator valuation of *every* rational point of *every* Mordell curve is even,
  with the `y`-denominator locked to the `3/2` power of the `x`-denominator.
Experiment (Experimenter): a rational-arithmetic sweep of `n • P` for
  `(N,P) ∈ {(55,(9,28)), (35,(1,6)), (17,(4,9)), (-2,(3,5)), (1,(2,3))}` and `1 ≤ n ≤ 5`
  found `den x` a perfect square and `den y = (√ den x)³` in 25/25 cases
  (`ComputationalEvidence.md`).  Sample: `N = 55`, `n = 3`:
  `x(3P) = -2302089191/656538129`, `656538129 = 3⁶·13²·73²`, `√ = 25623` and
  `den y(3P) = 25623³`.
Analysis (Analyst): the mechanism is coprimality, not geometry: writing `x = a/d`, `y = b/f`
  in lowest terms, the curve equation gives `b²d³ = f²(a³ + N d³)`, whence `f² ∣ d³` and
  `d³ ∣ f²`, so `d³ = f²` and the exponents `(2,3)` are forced by `gcd(2,3) = 1`.
Critique (Critic): the theorem is *not* vacuous — `E_55` really does have points with
  non-trivial denominators (`3136 = 56²`), and the statement is sharp: both parities occur
  in `den y` and the exponent pair cannot be improved, since `e` ranges over all values
  realised by the orbit.  The hypothesis `N ∈ ℤ` is load-bearing: for `N = 1/8`,
  `(x,y) = (1/2, 1/2)` lies on `y² = x³ + N` and `den x = 2` is not a square.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## The coprime cross-multiplied form of the curve equation -/

/-- Cross-multiplying `y² = x³ + N` with `x = a/d`, `y = b/f` in lowest terms gives
`b² d³ = f² (a³ + N d³)`. -/
lemma mordell_cross_mul {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) :
    y.num ^ 2 * (x.den : ℤ) ^ 3 = (y.den : ℤ) ^ 2 * (x.num ^ 3 + N * (x.den : ℤ) ^ 3) := by
  have hd : ((x.den : ℚ)) ≠ 0 := by exact_mod_cast x.den_ne_zero
  have hf : ((y.den : ℚ)) ≠ 0 := by exact_mod_cast y.den_ne_zero
  have hx : (x.num : ℚ) = x * (x.den : ℚ) := (Rat.mul_den_eq_num x).symm
  have hy : (y.num : ℚ) = y * (y.den : ℚ) := (Rat.mul_den_eq_num y).symm
  have key : (y.num : ℚ) ^ 2 * (x.den : ℚ) ^ 3
      = (y.den : ℚ) ^ 2 * ((x.num : ℚ) ^ 3 + (N : ℚ) * (x.den : ℚ) ^ 3) := by
    rw [hx, hy]
    linear_combination ((y.den : ℚ)) ^ 2 * ((x.den : ℚ)) ^ 3 * h
  exact_mod_cast key

/-- The denominator of a rational number is coprime to its numerator, as integers. -/
lemma isCoprime_den_num (q : ℚ) : IsCoprime ((q.den : ℤ)) q.num := by
  rw [Int.isCoprime_iff_gcd_eq_one, Int.gcd]
  simpa [Int.natAbs_natCast, Nat.coprime_comm] using q.reduced

/-! ## `den(x)³ = den(y)²` -/

/-- **The square-cube denominator law.**  For any rational point `(x, y)` of the Mordell curve
`y² = x³ + N` with `N` an integer, the denominators satisfy `den(x)³ = den(y)²`. -/
theorem mordell_den_cube_eq_sq {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) :
    x.den ^ 3 = y.den ^ 2 := by
  have hkey := mordell_cross_mul h
  -- `f² ∣ d³`
  have hcf : IsCoprime ((y.den : ℤ) ^ 2) (y.num ^ 2) :=
    ((isCoprime_den_num y).pow_left).pow_right
  have h1 : ((y.den : ℤ)) ^ 2 ∣ ((x.den : ℤ)) ^ 3 := by
    refine hcf.dvd_of_dvd_mul_left ?_
    exact ⟨x.num ^ 3 + N * (x.den : ℤ) ^ 3, by linarith [hkey]⟩
  -- `d³ ∣ f²`
  have hcd : IsCoprime ((x.den : ℤ) ^ 3) (x.num ^ 3) :=
    ((isCoprime_den_num x).pow_left).pow_right
  have h2 : ((x.den : ℤ)) ^ 3 ∣ ((y.den : ℤ)) ^ 2 := by
    refine hcd.dvd_of_dvd_mul_right ?_
    exact ⟨y.num ^ 2 - (y.den : ℤ) ^ 2 * N, by linarith [hkey]⟩
  have hd0 : (0 : ℤ) ≤ ((x.den : ℤ)) ^ 3 := by positivity
  have hf0 : (0 : ℤ) ≤ ((y.den : ℤ)) ^ 2 := by positivity
  have hfin : ((x.den : ℤ)) ^ 3 = ((y.den : ℤ)) ^ 2 := Int.dvd_antisymm hd0 hf0 h2 h1
  exact_mod_cast hfin

/-- **Denominator parametrisation.**  For a rational point of `E_N` with `N ∈ ℤ` there is a
single natural number `e` with `den(x) = e²` and `den(y) = e³`. -/
theorem mordell_den_pow_structure {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) :
    ∃ e : ℕ, x.den = e ^ 2 ∧ y.den = e ^ 3 :=
  Nat.exists_eq_pow_of_exponent_coprime_of_pow_eq_pow (by decide) (mordell_den_cube_eq_sq h)

/-- **The `x`-denominator is a perfect square.** -/
theorem mordell_x_den_isSquare {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) :
    IsSquare x.den := by
  obtain ⟨e, he, -⟩ := mordell_den_pow_structure h
  exact ⟨e, by rw [he]; ring⟩

/-- **The `y`-denominator is a perfect cube.** -/
theorem mordell_y_den_isCube {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) :
    ∃ e : ℕ, y.den = e ^ 3 := by
  obtain ⟨e, -, he⟩ := mordell_den_pow_structure h
  exact ⟨e, he⟩

/-! ## Even valuations: the filtration shadow -/

/-- **No prime enters a denominator alone.**  If a prime `ℓ` divides the `x`-denominator of a
rational point of `E_N` (`N ∈ ℤ`), then `ℓ² ∣ den x` and `ℓ³ ∣ den y`.

For `ℓ ≥ 5` this is the affine shadow of the fact that the kernel of reduction mod `ℓ` is the
formal group `Ê(ℓℤ_ℓ)`, on which `v(x) = -2v(z)` and `v(y) = -3v(z)`. -/
theorem mordell_prime_sq_dvd_den {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) {ℓ : ℕ}
    (hl : ℓ.Prime) (hdvd : ℓ ∣ x.den) : ℓ ^ 2 ∣ x.den ∧ ℓ ^ 3 ∣ y.den := by
  obtain ⟨e, hx, hy⟩ := mordell_den_pow_structure h
  have hle : ℓ ∣ e := by
    rw [hx] at hdvd
    exact hl.dvd_of_dvd_pow hdvd
  exact ⟨by rw [hx]; exact pow_dvd_pow_of_dvd hle 2, by rw [hy]; exact pow_dvd_pow_of_dvd hle 3⟩

/-- The `ℓ`-adic valuation of the `x`-denominator of a rational point of `E_N` is even. -/
theorem mordell_den_factorization_even {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ))
    (ℓ : ℕ) : Even (x.den.factorization ℓ) := by
  obtain ⟨e, hx, -⟩ := mordell_den_pow_structure h
  rw [hx, Nat.factorization_pow]
  exact ⟨e.factorization ℓ, by simp [two_mul]⟩

/-! ## Transport to Mathlib's group law: all multiples `n • P` -/

/-- Any affine point of `mordell (N : ℚ)`, `N` an integer, has square `x`-denominator. -/
theorem point_x_den_isSquare {N : ℤ} (Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point) {X : ℚ}
    (hX : xCoord Q = some X) : IsSquare X.den := by
  cases Q with
  | zero => simp [xCoord] at hX
  | @some x y hns =>
      have hxX : x = X := by
        simpa [xCoord] using hX
      subst hxX
      exact mordell_x_den_isSquare (N := N) ((mordell_equation_iff _ _ _).1 hns.1)

/-- **Stability along the orbit.**  For every rational point `P` of `E_N` (`N ∈ ℤ`) and every
`n`, the `x`-coordinate of `n • P` has a perfect-square denominator.  In particular the
counterexample prime `7` for `N = 55` can only ever appear to an even power, at every `n`. -/
theorem nsmul_x_den_isSquare {N : ℤ} (Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point) (n : ℕ)
    {X : ℚ} (hX : xCoord (n • Q) = some X) : IsSquare X.den :=
  point_x_den_isSquare (n • Q) hX

/-! ## The impossible denominators -/

/-- **A hard obstruction.**  A rational number whose denominator is not a perfect square is
never the `x`-coordinate of a rational point of a Mordell curve with integral `N`. -/
theorem nonsquare_den_impossible {N : ℤ} {x : ℚ} (hx : ¬IsSquare x.den) :
    ¬∃ y : ℚ, y ^ 2 = x ^ 3 + (N : ℚ) := by
  rintro ⟨y, hy⟩
  exact hx (mordell_x_den_isSquare hy)

/-- **The counterexample prime cannot appear alone.**  Although `7` divides the denominator of
`x(2P)` for `N = 55`, `P = (9,28)` (`den = 3136 = 2⁶·7²`), *no* rational point of `E_55` has
`x`-denominator equal to `7`: the square law forbids it.  So the failure of the "only bad
primes" conjecture is constrained — good primes enter, but always squared. -/
theorem den_seven_impossible :
    ¬∃ x y : ℚ, x.den = 7 ∧ y ^ 2 = x ^ 3 + ((55 : ℤ) : ℚ) := by
  rintro ⟨x, y, hden, hxy⟩
  obtain ⟨e, he⟩ := mordell_x_den_isSquare hxy
  rw [hden] at he
  have hb : e ≤ 7 := by nlinarith
  interval_cases e <;> omega

/-- The `x`-denominator of a rational point of `E_N` is never twice an odd square, never a
prime, and generally never a non-square; here is the quantitative form: below `n` there are at
most `√n + 1` achievable `x`-denominators, whatever `N` is. -/
theorem card_achievable_den_le_sqrt (n : ℕ) :
    ((Finset.range n).filter (fun d => IsSquare d)).card ≤ n.sqrt + 1 := by
  have hcard : ((Finset.range n).filter (fun d => IsSquare d)).card
      ≤ (Finset.range (n.sqrt + 1)).card := by
    refine Finset.card_le_card_of_injOn Nat.sqrt ?_ ?_
    · intro d hd
      have hd1 : d < n := Finset.mem_range.mp (Finset.mem_filter.mp hd).1
      refine Finset.mem_range.mpr ?_
      have : d.sqrt ≤ n.sqrt := Nat.sqrt_le_sqrt hd1.le
      omega
    · intro d hd d' hd' hsq
      obtain ⟨e, he⟩ := (Finset.mem_filter.mp (Finset.mem_coe.mp hd)).2
      obtain ⟨e', he'⟩ := (Finset.mem_filter.mp (Finset.mem_coe.mp hd')).2
      have h1 : d = e ^ 2 := by rw [he]; ring
      have h2 : d' = e' ^ 2 := by rw [he']; ring
      rw [h1, h2] at hsq ⊢
      simp only [Nat.sqrt_eq'] at hsq
      rw [hsq]
  simpa using hcard

/-- **Density statement.**  The achievable `x`-denominators have density zero: the proportion
of integers below `n` that can occur is at most `(√n + 1)/n`. -/
theorem achievable_den_density_zero :
    ∀ ε : ℚ, 0 < ε → ∃ n₀ : ℕ, ∀ n ≥ n₀, 0 < n →
      (((Finset.range n).filter (fun d => IsSquare d)).card : ℚ) / n < ε := by
  intro ε hε
  obtain ⟨K, hK⟩ := exists_nat_gt (4 / ε)
  have hKε : 4 < ε * K := by
    rw [div_lt_iff₀ hε] at hK
    linarith
  refine ⟨(2 * K + 2) ^ 2, fun n hn hn0 => ?_⟩
  set s : ℕ := n.sqrt with hsdef
  have hsq : s * s ≤ n := by
    have := Nat.sqrt_le' n
    nlinarith [Nat.sqrt_le' n]
  have hsK : 2 * K + 2 ≤ s := by
    have h := Nat.sqrt_le_sqrt hn
    have hbase : Nat.sqrt ((2 * K + 2) ^ 2) = 2 * K + 2 := Nat.sqrt_eq' _
    rw [hbase] at h
    omega
  have hcard := card_achievable_den_le_sqrt n
  have hden : (0 : ℚ) < n := by exact_mod_cast hn0
  have hle : (((Finset.range n).filter (fun d => IsSquare d)).card : ℚ) ≤ (s : ℚ) + 1 := by
    exact_mod_cast hcard
  have hsq' : ((s : ℚ)) * (s : ℚ) ≤ (n : ℚ) := by exact_mod_cast hsq
  have hsK' : (2 * (K : ℚ) + 2) ≤ (s : ℚ) := by exact_mod_cast hsK
  have hs0 : (0 : ℚ) < (s : ℚ) := by linarith [Nat.cast_nonneg (α := ℚ) K]
  rw [div_lt_iff₀ hden]
  have step1 : ε * ((s : ℚ) * s) ≤ ε * n := by nlinarith
  have hmul : (2 * (K : ℚ) + 2) * s ≤ (s : ℚ) * s :=
    mul_le_mul_of_nonneg_right hsK' hs0.le
  have step2 : ε * ((2 * (K : ℚ) + 2) * s) ≤ ε * ((s : ℚ) * s) :=
    mul_le_mul_of_nonneg_left hmul hε.le
  have step3 : 2 * (s : ℚ) < ε * ((2 * (K : ℚ) + 2) * s) := by nlinarith
  nlinarith

end MordellDenominators