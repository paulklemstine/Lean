import Catalog.Shared.MordellDenominatorPrimes

/-!
# `ℓ`-adic valuations of the denominators of doubled points on Mordell curves

This file sharpens `Catalog/Shared/MordellDenominatorPrimes.lean` from a *divisibility*
statement to an *exact valuation* statement, and delimits the boundary of its hypotheses.

## Main results

* `prime_pow_dvd_den` : a prime power dividing the denominator of a fraction survives
  reduction as soon as the prime misses the numerator.
* `pow_dvd_den_double_iff` : for an integral point `(x,y)`, `y ≠ 0`, on `E_N : y² = x³ + N`
  and a prime `ℓ ≥ 5` of good reduction, for **every** exponent `m`
  `ℓ ^ m ∣ den x(2P) ↔ ℓ ^ m ∣ y²`.
  Equivalently, `v_ℓ(den x(2P)) = 2 v_ℓ(y)`: the `ℓ`-part of the denominator of `x(2P)` is
  exactly the square of the `ℓ`-part of `y`, which is the affine shadow of the fact that
  the formal group at `ℓ` doubles valuations.
* `den_double_55_exact` : the counterexample `N = 55`, `P = (9,28)` realises this with
  `7² ∥ den x(2P) = 3136 = 2⁶ · 7²`.
* `den_criterion_needs_five` : the hypothesis `5 ≤ ℓ` is sharp — for `ℓ = 3` the criterion
  fails (`N = 8`, `P = (1,3)`: `3 ∣ y` but `x(2P) = -7/4` has denominator prime to `3`).
* `three_dvd_den_double_iff` : the exact law at the anomalous prime, `3 ∣ den x(2P) ↔ 9 ∣ y`
  (for `3 ∤ N`) — the criterion at `3` is the one for `ℓ ≥ 5` shifted by one level.
* `two_dvd_den_double_iff`, `sixteen_dvd_den_double` : the law at `ℓ = 2` for odd `N`,
  `2 ∣ den x(2P) ↔ 2 ∣ y`, and then in fact `16 ∣ den x(2P)`.  Together with the two previous
  items every prime is classified.
* `infinitely_many_N_with_good_prime` : for a *fixed* prime `ℓ ≥ 5`, infinitely many `N`
  carry an integral point whose doubled `x`-coordinate has `ℓ` in its denominator while
  `E_N` has good reduction at `ℓ`.  Hence the appearance of `ℓ` carries no information
  whatsoever about the arithmetic (in particular the factorisation) of `N`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if `ℓ ∣ den x(2P)` is governed by the reduction `P̄ ∈ E(𝔽_ℓ)[2]`,
  then the *height* of the denominator at `ℓ` should be governed by the formal group, giving
  the exact doubling law `v_ℓ(den x(2P)) = 2 v_ℓ(y)` and no dependence on `N` beyond `ℓ ∤ N`.
Experiment (Experimenter): proved the two divisibility directions separately.  The upper
  bound comes from `den (A/B) ∣ B` with `B = 4y²`, the lower bound from coprimality of
  `ℓ^m` with the numerator `x⁴ - 8Nx`.  Numerically: `N = 55`, `P = (9,28)` gives
  `den = 3136 = 2⁶·7²` and `v_7(28) = 1`, matching `v_7(den) = 2`.
Analysis (Analyst): the `ℓ = 3` failure is *not* an artefact of the proof: the numerator
  `x⁴ - 8Nx ≡ -9Nx (mod ℓ)` when `ℓ ∣ y`, and `9 ≡ 0 (mod 3)`, so at `ℓ = 3` the numerator
  can absorb the whole `3`-part.  `N = 8`, `P = (1,3)` realises the absorption.
Critique (Critic): `pow_dvd_den_double_iff` is stated with `y²` rather than `y` on the right
  so that it is a genuine equivalence for all `m` (odd `m` included); the `m = 1` case
  recovers `dvd_den_double_iff`.  The infinitude statement uses an explicit injective family
  `N_m = ℓ²(m+1)² - 1`, so it is constructive rather than a counting argument.
Second cycle (Hypothesizer → Experimenter): rather than leaving `ℓ ∈ {2,3}` as an excluded
  edge case, we asked for the *correct* statement there.  The identity
  `x⁴ - 8Nx = x(y² - 9N)` gives it: at `ℓ = 3` the numerator always carries two extra powers
  of `3`, so the criterion becomes `9 ∣ y` (`three_dvd_den_double_iff`); at `ℓ = 2`, odd `N`
  forces `x` odd whenever `y` is even, so the numerator is odd and the criterion is `2 ∣ y`
  with the stronger conclusion `16 ∣ den` (`sixteen_dvd_den_double`).  Numerical checks:
  `N = 8, P = (1,3)`: `9 ∤ 3`, `den = 4`; `N = 17, P = (4,9)`: `9 ∣ 9`, `den = 9`;
  `N = 199, P = (5,18)`: `9 ∣ 18`, `den = 144`; `N = 35, P = (1,6)`: `den = 16`.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## Coprimality toolkit -/

/-- A prime `ℓ` not dividing an integer `A` gives `ℓ ^ m` coprime to `A`. -/
lemma isCoprime_pow_of_not_dvd {A : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (h : ¬(ℓ : ℤ) ∣ A) (m : ℕ) :
    IsCoprime ((ℓ : ℤ) ^ m) A := by
  have h1 : IsCoprime ((ℓ : ℤ)) A := by
    rw [Int.isCoprime_iff_gcd_eq_one]
    refine (Nat.Prime.coprime_iff_not_dvd hl).mpr ?_
    intro hc
    exact h ((Int.natCast_dvd_natCast.mpr hc).trans (Int.natAbs_dvd.mpr dvd_rfl))
  exact h1.pow_left

/-- **Prime powers survive reduction.**  If `ℓ ^ m ∣ B` and `ℓ ∤ A`, then `ℓ ^ m` divides the
reduced denominator of `A / B`. -/
lemma prime_pow_dvd_den {A B : ℤ} (hB : B ≠ 0) {ℓ m : ℕ} (hl : ℓ.Prime)
    (hlB : (ℓ : ℤ) ^ m ∣ B) (hlA : ¬(ℓ : ℤ) ∣ A) : ℓ ^ m ∣ ((A : ℚ) / (B : ℚ)).den := by
  have key := num_mul_den (A := A) (B := B) hB
  have h1 : (ℓ : ℤ) ^ m ∣ A * ((((A : ℚ) / (B : ℚ)).den : ℤ)) := key ▸ hlB.mul_left _
  have h2 : (ℓ : ℤ) ^ m ∣ ((((A : ℚ) / (B : ℚ)).den : ℤ)) :=
    (isCoprime_pow_of_not_dvd hl hlA m).dvd_of_dvd_mul_left h1
  exact_mod_cast h2

/-! ## The exact `ℓ`-adic valuation of `den x(2P)` -/

/-- **Exact valuation law.**  Let `(x, y)` be an integral point with `y ≠ 0` on
`E_N : y² = x³ + N` and let `ℓ ≥ 5` be a prime of good reduction (`ℓ ∤ N`).  Then for every
exponent `m`,
`ℓ ^ m ∣ den x(2P) ↔ ℓ ^ m ∣ y²`.
In particular `v_ℓ(den x(2P)) = 2 · v_ℓ(y)`: doubling squares the `ℓ`-part of the
denominator, exactly as predicted by the formal group of `E_N` at `ℓ`. -/
theorem pow_dvd_den_double_iff {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) {ℓ m : ℕ}
    (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ℓ ^ m ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den ↔
      (ℓ : ℤ) ^ m ∣ y ^ 2 := by
  have hB : (4 * y ^ 2 : ℤ) ≠ 0 := by positivity
  have hcast : ((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)
      = ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ) := by push_cast; ring
  rw [hcast]
  constructor
  · intro h
    have h1 : (ℓ : ℤ) ^ m ∣ (4 * y ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast h) (den_dvd_denom _ _)
    have hcop : IsCoprime ((ℓ : ℤ) ^ m) (4 : ℤ) :=
      isCoprime_pow_of_not_dvd hl (by
        intro h4
        exact absurd ((Nat.prime_iff_prime_int.mp hl).dvd_of_dvd_pow (n := 2)
          (by norm_num at h4 ⊢; exact h4)) (not_dvd_two hl5)) m
    exact hcop.dvd_of_dvd_mul_left h1
  · intro h
    rcases Nat.eq_zero_or_pos m with hm | hm
    · subst hm; simp
    refine prime_pow_dvd_den hB hl (h.mul_left 4) ?_
    have hly : (ℓ : ℤ) ∣ y := by
      have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
      exact hp.dvd_of_dvd_pow (dvd_trans (dvd_pow_self (ℓ : ℤ) (by omega)) h)
    exact not_dvd_double_num heq hl hl5 hlN hly

/-! ## The counterexample is *exactly* `7²` -/

/-- For `N = 55`, `P = (9, 28)` the general valuation law is realised sharply:
`7² ∥ den x(2P) = 3136 = 2⁶·7²`, matching `v_7(28) = 1`. -/
theorem den_double_55_exact :
    7 ^ 2 ∣ ((((9 : ℤ) : ℚ) ^ 4 - 8 * ((55 : ℤ) : ℚ) * ((9 : ℤ) : ℚ)) /
        (4 * ((28 : ℤ) : ℚ) ^ 2)).den ∧
    ¬7 ^ 3 ∣ ((((9 : ℤ) : ℚ) ^ 4 - 8 * ((55 : ℤ) : ℚ) * ((9 : ℤ) : ℚ)) /
        (4 * ((28 : ℤ) : ℚ) ^ 2)).den := by
  constructor
  · exact (pow_dvd_den_double_iff (N := 55) (x := 9) (y := 28) (ℓ := 7) (m := 2)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)).mpr (by norm_num)
  · have hval : ((((9 : ℤ) : ℚ) ^ 4 - 8 * ((55 : ℤ) : ℚ) * ((9 : ℤ) : ℚ)) /
        (4 * ((28 : ℤ) : ℚ) ^ 2)) = 2601 / 3136 := by norm_num
    rw [hval]
    norm_num

/-! ## Sharpness of the hypothesis `5 ≤ ℓ` -/

/-- **The bound `ℓ ≥ 5` is sharp.**  The implication "`ℓ ∣ y` forces `ℓ ∣ den x(2P)`" fails for
`ℓ = 3`: on `E_8 : y² = x³ + 8` the integral point `P = (1, 3)` has `3 ∣ y` and `3 ∤ 8`, yet
`x(2P) = (1 - 64)/36 = -7/4` has denominator `4`, prime to `3`.  The `3`-part of `4y² = 36`
is entirely absorbed by the numerator, because `x⁴ - 8Nx ≡ -9Nx (mod ℓ)` and `3 ∣ 9`. -/
theorem den_criterion_needs_five :
    ¬∀ (N x y : ℤ) (ℓ : ℕ), y ^ 2 = x ^ 3 + N → y ≠ 0 → ℓ.Prime → 3 ≤ ℓ → ¬(ℓ : ℤ) ∣ N →
      (ℓ : ℤ) ∣ y → ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den := by
  intro h
  have hbad := h 8 1 3 3 (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by decide) (by norm_num)
  norm_num at hbad

/-! ## The exact law at the anomalous prime `ℓ = 3` -/

/-- If `3 ∤ N` and `(x, y)` is an integral point of `E_N` with `3 ∣ y`, then `3 ∤ x`. -/
lemma not_three_dvd_x {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hN : ¬(3 : ℤ) ∣ N)
    (hy : (3 : ℤ) ∣ y) : ¬(3 : ℤ) ∣ x := by
  intro hx
  refine hN ?_
  have h1 : (3 : ℤ) ∣ y ^ 2 := by rw [sq]; exact hy.mul_left y
  have h2 : (3 : ℤ) ∣ x ^ 3 := hx.pow (by norm_num)
  have : N = y ^ 2 - x ^ 3 := by linarith
  rw [this]
  exact dvd_sub h1 h2

/-- **The `3`-adic law is shifted by one level.**  Let `(x, y)` be an integral point with
`y ≠ 0` on `E_N : y² = x³ + N` and suppose `3 ∤ N`.  Then
`3 ∣ den x(2P) ↔ 9 ∣ y`.

Contrast with `dvd_den_double_iff`, where for `ℓ ≥ 5` the condition is `ℓ ∣ y`.  The shift is
caused by the identity `x⁴ - 8Nx = x(y² - 9N)`: at `ℓ = 3` the constant `9` contributes two
extra powers of `3` to the numerator, which cancel the whole `3`-part of `4y²` unless `y` is
divisible by `9`.  This makes `den_criterion_needs_five` sharp and explains it. -/
theorem three_dvd_den_double_iff {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (hN : ¬(3 : ℤ) ∣ N) :
    3 ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den ↔ (9 : ℤ) ∣ y := by
  have hp3 : Prime (3 : ℤ) := Int.prime_three
  have hcast : ((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)
      = ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ) := by push_cast; ring
  rw [hcast]
  constructor
  · intro h
    -- first, `3 ∣ y`
    have h1 : (3 : ℤ) ∣ (4 * y ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast h) (den_dvd_denom _ _)
    have h3y : (3 : ℤ) ∣ y := by
      rcases hp3.dvd_mul.mp h1 with h4 | hy2
      · exact absurd h4 (by decide)
      · exact hp3.dvd_of_dvd_pow hy2
    obtain ⟨u, hu⟩ := h3y
    by_contra h9
    have hu0 : u ≠ 0 := by rintro rfl; exact hy (by simpa using hu)
    -- cancel a factor `9` from numerator and denominator
    have hA : x ^ 4 - 8 * N * x = 9 * (x * (u ^ 2 - N)) := by
      subst hu; linear_combination (-x) * heq
    have hB : (4 * y ^ 2 : ℤ) = 9 * (4 * u ^ 2) := by subst hu; ring
    have hden0 : ((4 * u ^ 2 : ℤ) : ℚ) ≠ 0 := by
      have : (4 * u ^ 2 : ℤ) ≠ 0 := by positivity
      exact_mod_cast this
    have hnum0 : ((4 * y ^ 2 : ℤ) : ℚ) ≠ 0 := by
      have : (4 * y ^ 2 : ℤ) ≠ 0 := by positivity
      exact_mod_cast this
    have key : ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ)
        = ((x * (u ^ 2 - N) : ℤ) : ℚ) / ((4 * u ^ 2 : ℤ) : ℚ) := by
      rw [div_eq_div_iff hnum0 hden0, hA, hB]
      push_cast
      ring
    rw [key] at h
    have h2 : (3 : ℤ) ∣ (4 * u ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast h) (den_dvd_denom _ _)
    have h3u : (3 : ℤ) ∣ u := by
      rcases hp3.dvd_mul.mp h2 with h4 | hu2
      · exact absurd h4 (by decide)
      · exact hp3.dvd_of_dvd_pow hu2
    obtain ⟨v, hv⟩ := h3u
    exact h9 ⟨v, by rw [hu, hv]; ring⟩
  · rintro ⟨t, ht⟩
    have ht0 : t ≠ 0 := by rintro rfl; exact hy (by simpa using ht)
    have h3y : (3 : ℤ) ∣ y := ⟨3 * t, by rw [ht]; ring⟩
    have hx3 : ¬(3 : ℤ) ∣ x := not_three_dvd_x heq hN h3y
    have hA : x ^ 4 - 8 * N * x = 9 * (x * (9 * t ^ 2 - N)) := by
      subst ht; linear_combination (-x) * heq
    have hB : (4 * y ^ 2 : ℤ) = 9 * (36 * t ^ 2) := by subst ht; ring
    have hden0 : ((36 * t ^ 2 : ℤ) : ℚ) ≠ 0 := by
      have : (36 * t ^ 2 : ℤ) ≠ 0 := by positivity
      exact_mod_cast this
    have hnum0 : ((4 * y ^ 2 : ℤ) : ℚ) ≠ 0 := by
      have : (4 * y ^ 2 : ℤ) ≠ 0 := by positivity
      exact_mod_cast this
    have key : ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ)
        = ((x * (9 * t ^ 2 - N) : ℤ) : ℚ) / ((36 * t ^ 2 : ℤ) : ℚ) := by
      rw [div_eq_div_iff hnum0 hden0, hA, hB]
      push_cast
      ring
    rw [key]
    refine prime_dvd_den (by positivity) (by norm_num) ⟨12 * t ^ 2, by ring⟩ ?_
    intro hdvd
    rcases hp3.dvd_mul.mp hdvd with h1 | h2
    · exact hx3 h1
    · refine hN ?_
      have h9t : (3 : ℤ) ∣ 9 * t ^ 2 := ⟨3 * t ^ 2, by ring⟩
      simpa using dvd_sub h9t h2

/-! ## The law at `ℓ = 2` (odd `N`) -/

/-- For an integral point of `E_N` with `N` odd, `y` is even exactly when `x` is odd. -/
lemma even_y_iff_odd_x {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hN : ¬(2 : ℤ) ∣ N) :
    (2 : ℤ) ∣ y ↔ ¬(2 : ℤ) ∣ x := by
  have hp2 : Prime (2 : ℤ) := Int.prime_two
  constructor
  · intro h hx
    have h1 : (2 : ℤ) ∣ y ^ 2 := by rw [sq]; exact h.mul_left y
    have h2 : (2 : ℤ) ∣ x ^ 3 := hx.pow (by norm_num)
    exact hN (by rw [show N = y ^ 2 - x ^ 3 by linarith]; exact dvd_sub h1 h2)
  · intro hx
    by_contra hy
    have ha : ¬(2 : ℤ) ∣ y ^ 2 := fun h => hy (hp2.dvd_of_dvd_pow h)
    have hb : ¬(2 : ℤ) ∣ x ^ 3 := fun h => hx (hp2.dvd_of_dvd_pow h)
    refine hN ?_
    rw [show N = y ^ 2 - x ^ 3 by linarith]
    omega

/-- **At `ℓ = 2` an even `y` contributes a full `2⁴`.**  If `N` is odd and `2 ∣ y`, then
`16 ∣ den x(2P)`: the numerator `x⁴ - 8Nx` is odd, so the whole `2`-part `4y²` of the
denominator survives. -/
theorem sixteen_dvd_den_double {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (hN : ¬(2 : ℤ) ∣ N) (h2y : (2 : ℤ) ∣ y) :
    16 ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den := by
  have hp2 : Prime (2 : ℤ) := Int.prime_two
  have hB : (4 * y ^ 2 : ℤ) ≠ 0 := by positivity
  have hcast : ((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)
      = ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ) := by push_cast; ring
  rw [hcast]
  have hx : ¬(2 : ℤ) ∣ x := (even_y_iff_odd_x heq hN).mp h2y
  have hnum : ¬(2 : ℤ) ∣ (x ^ 4 - 8 * N * x) := by
    intro hd
    refine hx (hp2.dvd_of_dvd_pow (n := 4) ?_)
    have h8 : (2 : ℤ) ∣ 8 * N * x := ⟨4 * N * x, by ring⟩
    simpa using dvd_add hd h8
  obtain ⟨k, hk⟩ := h2y
  have h16 : ((2 : ℕ) : ℤ) ^ 4 ∣ (4 * y ^ 2 : ℤ) := ⟨k ^ 2, by rw [hk]; push_cast; ring⟩
  have := prime_pow_dvd_den (ℓ := 2) (m := 4) hB (by norm_num) h16 hnum
  simpa using this

/-- **The `2`-adic criterion.**  For odd `N` and an integral point with `y ≠ 0`,
`2 ∣ den x(2P) ↔ 2 ∣ y`.  Together with `dvd_den_double_iff` (`ℓ ≥ 5`) and
`three_dvd_den_double_iff` (`ℓ = 3`, condition `9 ∣ y`) this classifies *every* prime
occurring in the denominator of a doubled integral point. -/
theorem two_dvd_den_double_iff {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (hN : ¬(2 : ℤ) ∣ N) :
    2 ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den ↔ (2 : ℤ) ∣ y := by
  have hp2 : Prime (2 : ℤ) := Int.prime_two
  have hcast : ((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)
      = ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ) := by push_cast; ring
  constructor
  · intro h
    by_contra h2y
    have hx : (2 : ℤ) ∣ x := by
      by_contra hx
      exact h2y ((even_y_iff_odd_x heq hN).mpr hx)
    obtain ⟨s, hs⟩ := hx
    have hy0 : ((y ^ 2 : ℤ) : ℚ) ≠ 0 := by
      have : (y ^ 2 : ℤ) ≠ 0 := by positivity
      exact_mod_cast this
    have hB0 : ((4 * y ^ 2 : ℤ) : ℚ) ≠ 0 := by
      have : (4 * y ^ 2 : ℤ) ≠ 0 := by positivity
      exact_mod_cast this
    have key : ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ)
        = ((4 * (s ^ 4 - N * s) : ℤ) : ℚ) / ((y ^ 2 : ℤ) : ℚ) := by
      rw [div_eq_div_iff hB0 hy0, hs]
      push_cast
      ring
    rw [hcast, key] at h
    have hdvd : (2 : ℤ) ∣ (y ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast h) (den_dvd_denom _ _)
    exact h2y (hp2.dvd_of_dvd_pow hdvd)
  · intro h2y
    exact dvd_trans (by norm_num) (sixteen_dvd_den_double heq hy hN h2y)

/-! ## A fixed good prime occurs for infinitely many `N` -/

/-- **The denominator prime carries no information about `N`.**  Fix any prime `ℓ ≥ 5`.  Then
infinitely many integers `N` admit an integral point `P` on `E_N` such that `E_N` has good
reduction at `ℓ` and yet `ℓ` divides the denominator of `x(2P)`.  Explicit family:
`N_m = ℓ²(m+1)² - 1`, `P = (1, ℓ(m+1))`.

Consequently the set of denominator primes of `x(2P)` cannot be read as a fingerprint of the
factorisation of `N`: any fixed good prime already appears for infinitely many `N`. -/
theorem infinitely_many_N_with_good_prime {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) :
    {N : ℤ | ∃ x y : ℤ, y ≠ 0 ∧ y ^ 2 = x ^ 3 + N ∧ ¬(ℓ : ℤ) ∣ (mordell N).Δ ∧
      ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den}.Infinite := by
  have hl0 : (5 : ℤ) ≤ (ℓ : ℤ) := by exact_mod_cast hl5
  refine Set.infinite_of_injective_forall_mem
    (f := fun m : ℕ => (ℓ : ℤ) ^ 2 * ((m : ℤ) + 1) ^ 2 - 1) ?_ ?_
  · intro a b hab
    simp only [sub_left_inj] at hab
    have hsq : ((a : ℤ) + 1) ^ 2 = ((b : ℤ) + 1) ^ 2 := by
      have hne : ((ℓ : ℤ) ^ 2) ≠ 0 := by positivity
      exact mul_left_cancel₀ hne hab
    have hz : ((a : ℤ) + 1 - ((b : ℤ) + 1)) * ((a : ℤ) + 1 + ((b : ℤ) + 1)) = 0 := by
      linear_combination hsq
    have ha : (0 : ℤ) ≤ (a : ℤ) := Int.natCast_nonneg a
    have hb : (0 : ℤ) ≤ (b : ℤ) := Int.natCast_nonneg b
    rcases mul_eq_zero.mp hz with h1 | h2
    · have : (a : ℤ) = (b : ℤ) := by linarith
      exact_mod_cast this
    · exfalso; linarith
  · intro m
    have hlN : ¬(ℓ : ℤ) ∣ ((ℓ : ℤ) ^ 2 * ((m : ℤ) + 1) ^ 2 - 1) := by
      intro hdvd
      have h2 : (ℓ : ℤ) ∣ (ℓ : ℤ) ^ 2 * ((m : ℤ) + 1) ^ 2 :=
        Dvd.dvd.mul_right (dvd_pow_self _ (by norm_num)) _
      have h1 : (ℓ : ℤ) ∣ 1 := by simpa using dvd_sub h2 hdvd
      have := Int.le_of_dvd (by norm_num) h1
      omega
    refine ⟨1, (ℓ : ℤ) * ((m : ℤ) + 1), ?_, by ring, not_dvd_Δ hl hl5 hlN, ?_⟩
    · have : (0 : ℤ) < (ℓ : ℤ) * ((m : ℤ) + 1) := by positivity
      omega
    · refine (dvd_den_double_iff (by ring) ?_ hl hl5 hlN).mpr ⟨(m : ℤ) + 1, rfl⟩
      have : (0 : ℤ) < (ℓ : ℤ) * ((m : ℤ) + 1) := by positivity
      omega

end MordellDenominators