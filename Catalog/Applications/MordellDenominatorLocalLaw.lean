import Applications.MordellDenominatorFiltration

/-!
# The complete local law at a good prime, for *arbitrary* rational points

Cycle 1 (`Shared.MordellDenominatorPrimes`) determined when a good prime `ℓ ≥ 5` divides
`den x(2P)` for an **integral** point `P = (x, y)`: exactly when `ℓ ∣ y`.  Cycle 3
(`Applications.MordellDenominatorFiltration`) determined what happens when `ℓ` already divides
`den x(P)`: its exponent is unchanged.  The two results cover complementary regimes, and this
file glues them into one statement covering **every** rational point:

> for a prime `ℓ ≥ 5` with `ℓ ∤ N`,
> `ℓ ∣ den x(2P) ↔ ℓ ∣ den x(P) ∨ ℓ ∣ num y(P)`.

Both alternatives say the same geometric thing — the reduction of `2P` mod `ℓ` is the point at
infinity — but they are visibly independent of the factorisation of `N`, which is the content
of the refutation of the "only bad primes" conjecture.

## Main results

* `mordell_param_general` : the coprime parametrisation `x = a/e²`, `y = b/e³`,
  `b² = a³ + N e⁶`, valid for every rational point (no divisibility hypothesis).
* `dvd_den_double_iff_of_not_dvd_den` : the good-prime criterion for `ℓ`-integral points,
  `ℓ ∣ den x(2P) ↔ ℓ ∣ num y`, generalising the integral-point criterion of cycle 1.
* `dvd_den_double_iff_dichotomy` : **the complete local law** at a good prime `ℓ ≥ 5`, for an
  arbitrary rational point.
* `good_prime_den_criterion_indep_of_factorisation` : the criterion in the previous item makes
  no reference to `N` beyond `ℓ ∤ N`; formally, two Mordell curves whose parameters agree at
  the point produce the same answer.
* `num_eq_one_mod_eight_of_two_dvd_den` : at the even prime there is in addition a congruence
  obstruction — an even `x`-denominator forces `x.num ≡ 1 (mod 8)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 5): the integral criterion `ℓ ∣ y` and the filtration
  invariance are the two halves of a single dichotomy valid for all rational points.
Experiment (Experimenter): on `E_55`, `P = (9,28)`: `v_7(den x(nP)) = 2` for even `n` and `0`
  for odd `n`, while `v_7(num y(nP)) = 1` exactly when `n` is odd — matching the dichotomy
  (`7 ∣ num y(nP)` for odd `n` feeds the denominator at `2nP`; `7 ∣ den x(nP)` for even `n`
  reproduces itself).
Analysis (Analyst): the parametrisation `x = a/e²`, `y = b/e³` makes both regimes a single
  computation with the fraction `x(2P) = (a⁴ − 8Nae⁶)/(4b²e²)`.  When `ℓ ∤ e` the `ℓ`-part of
  the denominator is that of `b²`; when `ℓ ∣ e` it is that of `e²`.  The numerator identity
  `a⁴ − 8Nae⁶ = a(b² − 9Ne⁶)` shows the numerator is prime to `ℓ` in both regimes as soon as
  `ℓ ≥ 5` and `ℓ ∤ N`.
Critique (Critic): the hypothesis `ℓ ∤ N` is used only in the `ℓ`-integral branch, and it is
  necessary there: at a bad prime the numerator can absorb the `ℓ`-part.  The hypothesis
  `5 ≤ ℓ` is necessary as well (`Shared.MordellDenominatorValuations.den_criterion_needs_five`
  gives the counterexample at `ℓ = 3`), so the statement is sharp in both hypotheses.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## The parametrisation for an arbitrary rational point -/

/-- **General parametrisation.**  Every rational point of `E_N : y² = x³ + N` with `N ∈ ℤ` can
be written `x = a/e²`, `y = b/e³` with `e > 0`, `a` and `b` coprime to `e`, `den x = e²` and
`b² = a³ + N e⁶`. -/
lemma mordell_param_general {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) :
    ∃ e : ℕ, 0 < e ∧ Nat.Coprime x.num.natAbs e ∧ Nat.Coprime y.num.natAbs e ∧
      x.den = e ^ 2 ∧ x = (x.num : ℚ) / ((e : ℚ)) ^ 2 ∧ y = (y.num : ℚ) / ((e : ℚ)) ^ 3 ∧
      y.num ^ 2 = x.num ^ 3 + N * (e : ℤ) ^ 6 := by
  obtain ⟨e, hxe, hye⟩ := mordell_den_pow_structure h
  have he0 : 0 < e := by
    rcases Nat.eq_zero_or_pos e with rfl | he
    · exfalso
      have hd := x.den_nz
      rw [hxe] at hd
      simp at hd
    · exact he
  have he' : ((e : ℚ)) ≠ 0 := by
    have : (0 : ℚ) < (e : ℚ) := by exact_mod_cast he0
    exact ne_of_gt this
  have hca : Nat.Coprime x.num.natAbs e := by
    have hcop : Nat.Coprime x.num.natAbs (e ^ 2) := by rw [← hxe]; exact x.reduced
    exact Nat.Coprime.of_dvd_right (dvd_pow_self e (by norm_num)) hcop
  have hcb : Nat.Coprime y.num.natAbs e := by
    have hcop : Nat.Coprime y.num.natAbs (e ^ 3) := by rw [← hye]; exact y.reduced
    exact Nat.Coprime.of_dvd_right (dvd_pow_self e (by norm_num)) hcop
  have hx : x = (x.num : ℚ) / ((e : ℚ)) ^ 2 := by
    rw [show ((e : ℚ)) ^ 2 = ((x.den : ℚ)) by rw [hxe]; push_cast; ring]
    exact (Rat.num_div_den x).symm
  have hy : y = (y.num : ℚ) / ((e : ℚ)) ^ 3 := by
    rw [show ((e : ℚ)) ^ 3 = ((y.den : ℚ)) by rw [hye]; push_cast; ring]
    exact (Rat.num_div_den y).symm
  refine ⟨e, he0, hca, hcb, hxe, hx, hy, ?_⟩
  have key : ((y.num : ℚ)) ^ 2 = ((x.num : ℚ)) ^ 3 + (N : ℚ) * ((e : ℚ)) ^ 6 := by
    rw [hx, hy] at h
    field_simp at h
    linear_combination h
  exact_mod_cast key

/-! ## The good-prime criterion for `ℓ`-integral points -/

/-- **Good-prime criterion, `ℓ`-integral case.**  Let `(x, y)` be a rational point of
`E_N : y² = x³ + N` with `N ∈ ℤ`, `y ≠ 0`, and let `ℓ ≥ 5` be a prime with `ℓ ∤ N` (good
reduction) which does **not** divide `den x`.  Then

`ℓ ∣ den x(2P) ↔ ℓ ∣ num y`.

For an integral point (`den x = den y = 1`, `num y = y`) this is the criterion of cycle 1;
here no integrality is assumed. -/
theorem dvd_den_double_iff_of_not_dvd_den {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ))
    (hy : y ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N)
    (hnd : ¬ℓ ∣ x.den) :
    ℓ ∣ ((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den ↔ (ℓ : ℤ) ∣ y.num := by
  obtain ⟨e, he0, hca, hcb, hxden, hx, hy', heq⟩ := mordell_param_general h
  set a : ℤ := x.num with ha
  set b : ℤ := y.num with hb
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hb0 : b ≠ 0 := by
    rw [hb]
    exact Rat.num_ne_zero.mpr hy
  have hB0 : (4 * b ^ 2 * (e : ℤ) ^ 2 : ℤ) ≠ 0 := by positivity
  have hle : ¬(ℓ : ℤ) ∣ ((e : ℤ)) := by
    intro hc
    have h1 : ℓ ∣ e := by simpa using Int.natAbs_dvd_natAbs.mpr hc
    exact hnd (by rw [hxden]; exact h1.trans (dvd_pow_self e (by norm_num)))
  have hl4 : ¬(ℓ : ℤ) ∣ 4 := by
    intro hc
    have h2 : (ℓ : ℤ) ∣ 2 := hp.dvd_of_dvd_pow (n := 2) (by norm_num at hc ⊢; exact hc)
    have := Int.le_of_dvd (by norm_num) h2
    omega
  rw [den_double_eq_int_frac (N := N) he0 hb0 hx hy']
  constructor
  · intro hm
    have h1 : (ℓ : ℤ) ∣ (4 * b ^ 2 * (e : ℤ) ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast hm) (den_dvd_denom _ _)
    rcases hp.dvd_mul.mp h1 with h2 | h3
    · rcases hp.dvd_mul.mp h2 with h4 | hb2
      · exact absurd h4 hl4
      · exact hp.dvd_of_dvd_pow hb2
    · exact absurd (hp.dvd_of_dvd_pow h3) hle
  · intro hm
    -- the numerator `a(b² − 9Ne⁶)` is prime to `ℓ`
    have hla : ¬(ℓ : ℤ) ∣ a := by
      intro hc
      have h3 : (ℓ : ℤ) ∣ a ^ 3 := hc.pow (by norm_num)
      have hb2 : (ℓ : ℤ) ∣ b ^ 2 := dvd_pow hm (by norm_num)
      have : (ℓ : ℤ) ∣ N * (e : ℤ) ^ 6 := by
        have := dvd_sub hb2 h3
        rwa [show b ^ 2 - a ^ 3 = N * (e : ℤ) ^ 6 by linarith [heq]] at this
      rcases hp.dvd_mul.mp this with hN | hE
      · exact hlN hN
      · exact hle (hp.dvd_of_dvd_pow hE)
    have hnum : ¬(ℓ : ℤ) ∣ (a ^ 4 - 8 * N * a * (e : ℤ) ^ 6) := by
      intro hc
      have hfac : a ^ 4 - 8 * N * a * (e : ℤ) ^ 6 = a * (b ^ 2 - 9 * (N * (e : ℤ) ^ 6)) := by
        linear_combination (-a) * heq
      rw [hfac] at hc
      rcases hp.dvd_mul.mp hc with h1 | h2
      · exact hla h1
      · have hb2 : (ℓ : ℤ) ∣ b ^ 2 := dvd_pow hm (by norm_num)
        have h9 : (ℓ : ℤ) ∣ 9 * (N * (e : ℤ) ^ 6) := by
          have := dvd_sub hb2 h2
          simpa using this
        rcases hp.dvd_mul.mp h9 with h9' | hNe
        · have h3 : (ℓ : ℤ) ∣ 3 :=
            hp.dvd_of_dvd_pow (n := 2) (by norm_num at h9' ⊢; exact h9')
          have := Int.le_of_dvd (by norm_num) h3
          omega
        · rcases hp.dvd_mul.mp hNe with hN | hE
          · exact hlN hN
          · exact hle (hp.dvd_of_dvd_pow hE)
    refine prime_dvd_den hB0 hl ?_ hnum
    exact Dvd.dvd.mul_right (Dvd.dvd.mul_left (dvd_pow hm (by norm_num)) 4) _

/-! ## The complete local law -/

/-- **The complete local law at a good prime.**  Let `(x, y)` be any rational point of
`E_N : y² = x³ + N` with `N ∈ ℤ` and `y ≠ 0`, and let `ℓ ≥ 5` be a prime of good reduction
(`ℓ ∤ N`).  Then

`ℓ ∣ den x(2P) ↔ ℓ ∣ den x(P) ∨ ℓ ∣ num y(P)`.

The right-hand side depends only on the point and on `ℓ`; nothing in it can distinguish the
prime factors of `N` from any other prime, which is exactly why the "only bad primes"
conjecture fails. -/
theorem dvd_den_double_iff_dichotomy {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ))
    (hy : y ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ℓ ∣ ((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den ↔ (ℓ ∣ x.den ∨ (ℓ : ℤ) ∣ y.num) := by
  by_cases hnd : ℓ ∣ x.den
  · have hinv := pow_dvd_den_double_iff_of_dvd_den h hy hl (by omega) hnd 1
    simp only [pow_one] at hinv
    exact ⟨fun _ => Or.inl hnd, fun _ => hinv.mpr hnd⟩
  · rw [dvd_den_double_iff_of_not_dvd_den h hy hl hl5 hlN hnd]
    exact ⟨fun hb => Or.inr hb, fun hcase => hcase.elim (fun hc => absurd hc hnd) id⟩

/-- **The criterion is blind to the factorisation of `N`.**  Take two Mordell curves `E_N` and
`E_M`, both with good reduction at `ℓ ≥ 5`, and points `(x,y) ∈ E_N(ℚ)`, `(u,v) ∈ E_M(ℚ)`
whose local data agree (`ℓ ∣ den x ↔ ℓ ∣ den u` and `ℓ ∣ num y ↔ ℓ ∣ num v`).  Then `ℓ` divides
`den x(2P)` if and only if it divides `den x(2Q)`.  In particular the answer is independent of
`N` and `M`, however they factor: no information about the factorisation can be extracted from
the denominators at good primes. -/
theorem good_prime_den_criterion_indep_of_factorisation {N M : ℤ} {x y u v : ℚ}
    (hN : y ^ 2 = x ^ 3 + (N : ℚ)) (hM : v ^ 2 = u ^ 3 + (M : ℚ)) (hy : y ≠ 0) (hv : v ≠ 0)
    {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) (hlM : ¬(ℓ : ℤ) ∣ M)
    (hden : (ℓ ∣ x.den ↔ ℓ ∣ u.den)) (hnum : ((ℓ : ℤ) ∣ y.num ↔ (ℓ : ℤ) ∣ v.num)) :
    (ℓ ∣ ((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den
      ↔ ℓ ∣ ((u ^ 4 - 8 * (M : ℚ) * u) / (4 * v ^ 2)).den) := by
  rw [dvd_den_double_iff_dichotomy hN hy hl hl5 hlN,
    dvd_den_double_iff_dichotomy hM hv hl hl5 hlM]
  exact or_congr hden hnum

/-! ## A congruence obstruction at the even prime -/

/-- **The `2`-adic congruence obstruction.**  If the denominator of the `x`-coordinate of a
rational point of `E_N` (`N ∈ ℤ`) is even, then its numerator is congruent to `1` modulo `8`.

Indeed `x = a/e²`, `y = b/e³` with `2 ∣ e`, so `64 ∣ e⁶` and the curve equation gives
`b² ≡ a³ (mod 8)` with `a`, `b` odd; odd squares are `1` mod `8` and cubing is the identity on
the units of `ℤ/8`, forcing `a ≡ 1 (mod 8)`.  Thus points in the `2`-adic kernel of reduction
are severely constrained, in contrast with the odd primes where no congruence restriction on
the numerator appears. -/
theorem num_eq_one_mod_eight_of_two_dvd_den {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ))
    (hdvd : 2 ∣ x.den) : ((x.num : ZMod 8)) = 1 := by
  obtain ⟨e, he0, hca, hcb, hxden, hx, hy', heq⟩ := mordell_param_general h
  have h2e : 2 ∣ e := by
    have : (2 : ℕ).Prime := Nat.prime_two
    exact this.dvd_of_dvd_pow (n := 2) (by rw [← hxden]; exact hdvd)
  -- `a` and `b` are odd
  have hodd_a : ∃ t : ℤ, x.num = 2 * t + 1 := by
    have h2 : ¬(2 ∣ x.num.natAbs) := fun hc =>
      Nat.Prime.one_lt Nat.prime_two |>.ne' (Nat.Coprime.eq_one_of_dvd
        (Nat.Coprime.coprime_dvd_left hc hca) h2e)
    have : x.num % 2 = 1 := by
      rcases Int.emod_two_eq_zero_or_one x.num with h0 | h1
      · exact absurd (by
          have : (2 : ℤ) ∣ x.num := Int.dvd_of_emod_eq_zero h0
          simpa using Int.natAbs_dvd_natAbs.mpr this) h2
      · exact h1
    exact ⟨x.num / 2, by omega⟩
  have hodd_b : ∃ s : ℤ, y.num = 2 * s + 1 := by
    have h2 : ¬(2 ∣ y.num.natAbs) := fun hc =>
      Nat.Prime.one_lt Nat.prime_two |>.ne' (Nat.Coprime.eq_one_of_dvd
        (Nat.Coprime.coprime_dvd_left hc hcb) h2e)
    have : y.num % 2 = 1 := by
      rcases Int.emod_two_eq_zero_or_one y.num with h0 | h1
      · exact absurd (by
          have : (2 : ℤ) ∣ y.num := Int.dvd_of_emod_eq_zero h0
          simpa using Int.natAbs_dvd_natAbs.mpr this) h2
      · exact h1
    exact ⟨y.num / 2, by omega⟩
  obtain ⟨t, ht⟩ := hodd_a
  obtain ⟨s, hs⟩ := hodd_b
  -- `8 ∣ b² - a³`
  have h8 : (8 : ℤ) ∣ (y.num ^ 2 - x.num ^ 3) := by
    obtain ⟨f, hf⟩ := h2e
    refine ⟨N * (8 * (f : ℤ) ^ 6), ?_⟩
    have hE : ((e : ℤ)) = 2 * (f : ℤ) := by exact_mod_cast congrArg (fun m : ℕ => (m : ℤ)) hf
    rw [show y.num ^ 2 - x.num ^ 3 = N * (e : ℤ) ^ 6 by linarith [heq], hE]
    ring
  have hz : ((y.num : ZMod 8)) ^ 2 = ((x.num : ZMod 8)) ^ 3 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (y.num ^ 2 - x.num ^ 3) 8).mpr (by
      exact_mod_cast h8)
    push_cast at this
    linear_combination this
  have key : ∀ u v : ZMod 8, (2 * v + 1) ^ 2 = (2 * u + 1) ^ 3 → (2 * u + 1 : ZMod 8) = 1 := by
    decide
  have hzt : ((x.num : ZMod 8)) = 2 * (t : ZMod 8) + 1 := by
    rw [ht]; push_cast; ring
  have hzs : ((y.num : ZMod 8)) = 2 * (s : ZMod 8) + 1 := by
    rw [hs]; push_cast; ring
  rw [hzt]
  refine key (t : ZMod 8) (s : ZMod 8) ?_
  rw [← hzt, ← hzs]
  exact hz

end MordellDenominators