import Cryptography.MordellDenominators.Basic

/-!
# Exact `ℓ`-adic behaviour of denominators under duplication

`Basic.lean` shows that a prime in a denominator never disappears.  Here we
compute the exact multiplicity, which turns out to be rigid:

* for an **odd** prime `ℓ` in the denominator, duplication *preserves* the
  `ℓ`-adic valuation:
  `padicValNat ℓ (dblX N x).den = padicValNat ℓ x.den`
  (`MordellDenominators.padicValNat_den_dblX_odd`);
* for `ℓ = 2` the valuation increases by exactly `2`
  (`MordellDenominators.padicValNat_den_dblX_two`);
* a good prime `ℓ` *not yet* present enters with the exact valuation
  `2 v_ℓ(num y)` (`MordellDenominators.padicValNat_den_dblX_good`), so it
  enters iff it divides the numerator of the `y`-coordinate
  (`MordellDenominators.good_prime_dvd_den_dblX_iff`).

This is the elementary shadow of the formal-group statement `z(2P) = 2z + …`:
away from the residue characteristic of the multiplier, multiplication by `2`
is an isomorphism of the kernel of reduction, whereas at `ℓ = 2` it strictly
deepens it.  In particular a good prime, once present, occurs with the *same*
exponent forever — the denominators keep broadcasting it.
-/

namespace MordellDenominators

/-- **Valuation of a denominator.**  If `q = A/B` with `ℓ ∤ A`, then the
`ℓ`-adic valuation of the reduced denominator of `q` is that of `B`. -/
theorem padicValNat_den_of_eq_div {q : ℚ} {A B : ℤ} (hB : B ≠ 0)
    (hq : q = (A : ℚ) / (B : ℚ)) {l : ℕ} (hl : l.Prime) (hlA : ¬ (l : ℤ) ∣ A) :
    padicValNat l q.den = padicValNat l B.natAbs := by
  haveI : Fact l.Prime := ⟨hl⟩
  have hA : A ≠ 0 := by
    intro h0
    exact hlA (by rw [h0]; exact dvd_zero _)
  have hlAnat : ¬ l ∣ A.natAbs := by
    intro hcon
    exact hlA (Int.ofNat_dvd_left.mpr hcon)
  have hAnat : A.natAbs ≠ 0 := Int.natAbs_ne_zero.mpr hA
  have hBnat : B.natAbs ≠ 0 := Int.natAbs_ne_zero.mpr hB
  have hq0 : q ≠ 0 := by
    rw [hq]
    exact div_ne_zero (Int.cast_ne_zero.mpr hA) (Int.cast_ne_zero.mpr hB)
  have hnum0 : q.num.natAbs ≠ 0 := Int.natAbs_ne_zero.mpr (Rat.num_ne_zero.mpr hq0)
  have hden0 : q.den ≠ 0 := q.den_nz
  -- cross multiplication, in `ℕ`
  have key : q.num.natAbs * B.natAbs = A.natAbs * q.den := by
    have hZ : q.num * B = A * (q.den : ℤ) := num_mul_den_eq hB hq
    have := congrArg Int.natAbs hZ
    simpa [Int.natAbs_mul] using this
  have hval : padicValNat l q.num.natAbs + padicValNat l B.natAbs
      = padicValNat l A.natAbs + padicValNat l q.den := by
    have h1 : padicValNat l (q.num.natAbs * B.natAbs)
        = padicValNat l q.num.natAbs + padicValNat l B.natAbs :=
      padicValNat.mul hnum0 hBnat
    have h2 : padicValNat l (A.natAbs * q.den)
        = padicValNat l A.natAbs + padicValNat l q.den :=
      padicValNat.mul hAnat hden0
    rw [← h1, ← h2, key]
  have hvA : padicValNat l A.natAbs = 0 := padicValNat.eq_zero_of_not_dvd hlAnat
  -- the numerator of `q` is prime to `ℓ`
  have hvnum : padicValNat l q.num.natAbs = 0 := by
    by_contra hcon
    have hdvdnum : l ∣ q.num.natAbs := (dvd_iff_padicValNat_ne_zero hnum0).mpr hcon
    have hnotden : ¬ l ∣ q.den := by
      intro hdden
      have := Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left hdvdnum q.reduced) hdden
      exact hl.one_lt.ne' this
    have hvden : padicValNat l q.den = 0 := padicValNat.eq_zero_of_not_dvd hnotden
    rw [hvA, hvden] at hval
    omega
  rw [hvnum, hvA] at hval
  omega

/-- The `ℓ`-adic valuation of `x.den` in terms of the parameter `e`. -/
theorem padicValNat_den_eq {x : ℚ} {e : ℕ} (he0 : 0 < e) (hxe : x.den = e ^ 2)
    {l : ℕ} (hl : l.Prime) : padicValNat l x.den = 2 * padicValNat l e := by
  haveI : Fact l.Prime := ⟨hl⟩
  rw [hxe, padicValNat.pow 2 he0.ne']

/-- Auxiliary computation of the valuation of the denominator produced by the
duplication formula. -/
theorem padicValNat_dblX_den {N : ℤ} {x y : ℚ} (h : OnCurve N x y) {l : ℕ}
    (hl : l.Prime) (hd : l ∣ x.den) :
    padicValNat l (dblX N x).den
      = padicValNat l 4 + padicValNat l x.den := by
  haveI : Fact l.Prime := ⟨hl⟩
  obtain ⟨e, he0, hxe, hye⟩ := exists_den_param h
  have hy : y ≠ 0 := ne_zero_of_dvd_den h hl hd
  have hb0 : y.num ≠ 0 := Rat.num_ne_zero.mpr hy
  have hle : l ∣ e := hl.dvd_of_dvd_pow (by rw [← hxe]; exact hd)
  have hleZ : (l : ℤ) ∣ (e : ℤ) := by exact_mod_cast hle
  have hla : ¬ (l : ℤ) ∣ x.num := by
    intro hcon
    have h1 : l ∣ x.num.natAbs := by simpa using Int.natAbs_dvd_natAbs.mpr hcon
    have := Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left h1 x.reduced) hd
    exact hl.one_lt.ne' this
  -- `ℓ ∤ y.num`, since `ℓ ∣ e ∣ y.den`
  have hlb : ¬ l ∣ y.num.natAbs := by
    intro hcon
    have hdy : l ∣ y.den := by
      rw [hye]; exact Dvd.dvd.trans hle (dvd_pow_self e (by norm_num))
    have := Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left hcon y.reduced) hdy
    exact hl.one_lt.ne' this
  have heZ : (e : ℤ) ≠ 0 := by exact_mod_cast he0.ne'
  have hBne : (4 * y.num ^ 2 * (e : ℤ) ^ 2 : ℤ) ≠ 0 := by positivity
  have hAdvd : ¬ (l : ℤ) ∣ (x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6) := by
    intro hcon
    have h6 : (l : ℤ) ∣ 8 * N * x.num * (e : ℤ) ^ 6 :=
      Dvd.dvd.mul_left (dvd_pow hleZ (by norm_num)) _
    have hpow : (l : ℤ) ∣ x.num ^ 4 := by
      have := dvd_add hcon h6
      simpa using this
    exact hla ((Nat.prime_iff_prime_int.mp hl).dvd_of_dvd_pow hpow)
  have hden := padicValNat_den_of_eq_div hBne (dblX_eq_div h he0 hxe hye hy) hl hAdvd
  have hnatAbs : (4 * y.num ^ 2 * (e : ℤ) ^ 2 : ℤ).natAbs = 4 * y.num.natAbs ^ 2 * e ^ 2 := by
    simp [Int.natAbs_mul, Int.natAbs_pow]
  rw [hnatAbs] at hden
  have hbne : y.num.natAbs ≠ 0 := Int.natAbs_ne_zero.mpr hb0
  have hsplit : padicValNat l (4 * y.num.natAbs ^ 2 * e ^ 2)
      = padicValNat l 4 + 2 * padicValNat l y.num.natAbs + 2 * padicValNat l e := by
    rw [padicValNat.mul (by positivity) (by positivity),
      padicValNat.mul (by norm_num) (by positivity),
      padicValNat.pow 2 hbne, padicValNat.pow 2 he0.ne']
  rw [hsplit, padicValNat.eq_zero_of_not_dvd hlb] at hden
  rw [hden, padicValNat_den_eq he0 hxe hl]
  omega

/-- **Odd primes: duplication preserves the valuation.**  If an odd prime `ℓ`
divides the denominator of `x(P)`, then `x(2P)` has exactly the same `ℓ`-adic
denominator valuation. -/
theorem padicValNat_den_dblX_odd {N : ℤ} {x y : ℚ} (h : OnCurve N x y) {l : ℕ}
    (hl : l.Prime) (hodd : l ≠ 2) (hd : l ∣ x.den) :
    padicValNat l (dblX N x).den = padicValNat l x.den := by
  haveI : Fact l.Prime := ⟨hl⟩
  have h4 : padicValNat l 4 = 0 := by
    refine padicValNat.eq_zero_of_not_dvd ?_
    intro hcon
    have : l ∣ 2 ^ 2 := by simpa using hcon
    exact hodd ((Nat.prime_dvd_prime_iff_eq hl Nat.prime_two).mp (hl.dvd_of_dvd_pow this))
  rw [padicValNat_dblX_den h hl hd, h4, zero_add]

/-- **The prime `2`: duplication deepens the valuation by exactly `2`.** -/
theorem padicValNat_den_dblX_two {N : ℤ} {x y : ℚ} (h : OnCurve N x y)
    (hd : 2 ∣ x.den) :
    padicValNat 2 (dblX N x).den = padicValNat 2 x.den + 2 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have h4 : padicValNat 2 4 = 2 := by
    have : (4 : ℕ) = 2 ^ 2 := by norm_num
    rw [this, padicValNat.prime_pow]
  rw [padicValNat_dblX_den h Nat.prime_two hd, h4]
  omega

/-- **Entry of a good prime, exactly.**  Let `ℓ` be a prime of good reduction
(`ℓ ∤ 6N`) that is *not yet* in the denominator of `x(P)`.  Then the `ℓ`-adic
valuation of the denominator of `x(2P)` is exactly twice the `ℓ`-adic valuation
of the numerator of `y(P)`:
`v_ℓ(den x(2P)) = 2 v_ℓ(num y)`.

In particular a good prime enters the orbit precisely when it divides the
numerator of the `y`-coordinate, and it enters with the minimal exponent `2`
exactly when it divides that numerator exactly once. -/
theorem padicValNat_den_dblX_good {N : ℤ} {x y : ℚ} (h : OnCurve N x y)
    (hy : y ≠ 0) {l : ℕ} (hl : l.Prime) (hl6N : ¬ ((l : ℤ) ∣ 6 * N))
    (hnd : ¬ l ∣ x.den) :
    padicValNat l (dblX N x).den = 2 * padicValNat l y.num.natAbs := by
  haveI : Fact l.Prime := ⟨hl⟩
  obtain ⟨e, he0, hxe, hye⟩ := exists_den_param h
  have hb0 : y.num ≠ 0 := Rat.num_ne_zero.mpr hy
  have hbnat : y.num.natAbs ≠ 0 := Int.natAbs_ne_zero.mpr hb0
  have hle : ¬ l ∣ e := by
    intro hc
    exact hnd (by rw [hxe]; exact hc.trans (dvd_pow_self e (by norm_num)))
  have hleZ : ¬ ((l : ℤ) ∣ (e : ℤ)) := by
    intro hc; exact hle (by exact_mod_cast hc)
  have hlN : ¬ ((l : ℤ) ∣ N) := fun hc => hl6N (Dvd.dvd.mul_left hc 6)
  have hl6 : ¬ ((l : ℤ) ∣ 6) := fun hc => hl6N (Dvd.dvd.mul_right hc N)
  have hl2 : l ≠ 2 := by
    intro hc; exact hl6 (by rw [hc]; norm_num)
  have hl3 : ¬ ((l : ℤ) ∣ 3) := fun hc => hl6 (hc.trans (by norm_num))
  have hlp : Prime (l : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hBne : (4 * y.num ^ 2 * (e : ℤ) ^ 2 : ℤ) ≠ 0 := by
    have heZ : (e : ℤ) ≠ 0 := by exact_mod_cast he0.ne'
    positivity
  have hdiv := dblX_eq_div h he0 hxe hye hy
  have hmodel : y.num ^ 2 = x.num ^ 3 + N * (e : ℤ) ^ 6 := curve_integral_model h hxe hye
  by_cases hlb : (l : ℤ) ∣ y.num
  · -- the prime really enters; compute the valuation of the denominator
    have hlb2 : (l : ℤ) ∣ y.num ^ 2 := Dvd.dvd.trans hlb (dvd_pow_self _ (by norm_num))
    have hla : ¬ ((l : ℤ) ∣ x.num) := by
      intro hc
      have h2 : (l : ℤ) ∣ x.num ^ 3 := Dvd.dvd.trans hc (dvd_pow_self _ (by norm_num))
      have h3 : (l : ℤ) ∣ N * (e : ℤ) ^ 6 := by
        have hsub := dvd_sub hlb2 h2
        rw [hmodel] at hsub
        simpa using hsub
      rcases hlp.dvd_mul.mp h3 with hN | hE
      · exact hlN hN
      · exact hleZ (hlp.dvd_of_dvd_pow hE)
    -- the numerator factors as `a (b² - 9Ne⁶)`, which is prime to `ℓ`
    have hfact : x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6
        = x.num * (y.num ^ 2 - 9 * N * (e : ℤ) ^ 6) := by
      have hx3 : x.num ^ 3 = y.num ^ 2 - N * (e : ℤ) ^ 6 := by linarith [hmodel]
      calc x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6
          = x.num * (x.num ^ 3 - 8 * N * (e : ℤ) ^ 6) := by ring
        _ = x.num * ((y.num ^ 2 - N * (e : ℤ) ^ 6) - 8 * N * (e : ℤ) ^ 6) := by rw [hx3]
        _ = x.num * (y.num ^ 2 - 9 * N * (e : ℤ) ^ 6) := by ring
    have hAne : ¬ ((l : ℤ) ∣ x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6) := by
      rw [hfact]
      intro hc
      rcases hlp.dvd_mul.mp hc with hcx | hcy
      · exact hla hcx
      · have h9 : (l : ℤ) ∣ 9 * N * (e : ℤ) ^ 6 := by
          have := dvd_sub hlb2 hcy
          simpa using this
        rcases hlp.dvd_mul.mp h9 with h9N | hE
        · rcases hlp.dvd_mul.mp h9N with h9' | hN
          · refine hl3 (hlp.dvd_of_dvd_pow (n := 2) ?_)
            rw [show ((3 : ℤ) ^ 2) = 9 by norm_num]
            exact h9'
          · exact hlN hN
        · exact hleZ (hlp.dvd_of_dvd_pow hE)
    have hval := padicValNat_den_of_eq_div hBne hdiv hl hAne
    have hnatAbs : (4 * y.num ^ 2 * (e : ℤ) ^ 2 : ℤ).natAbs
        = 4 * y.num.natAbs ^ 2 * e ^ 2 := by
      simp [Int.natAbs_mul, Int.natAbs_pow]
    rw [hnatAbs] at hval
    have hsplit : padicValNat l (4 * y.num.natAbs ^ 2 * e ^ 2)
        = padicValNat l 4 + 2 * padicValNat l y.num.natAbs + 2 * padicValNat l e := by
      rw [padicValNat.mul (by positivity) (by positivity),
        padicValNat.mul (by norm_num) (by positivity),
        padicValNat.pow 2 hbnat, padicValNat.pow 2 he0.ne']
    have h4 : padicValNat l 4 = 0 := by
      refine padicValNat.eq_zero_of_not_dvd ?_
      intro hc
      have : l ∣ 2 ^ 2 := by simpa using hc
      exact hl2 ((Nat.prime_dvd_prime_iff_eq hl Nat.prime_two).mp (hl.dvd_of_dvd_pow this))
    have hve : padicValNat l e = 0 := padicValNat.eq_zero_of_not_dvd hle
    rw [hval, hsplit, h4, hve]
    omega
  · -- the prime is absent from the numerator of `y`: both sides vanish
    have hvb : padicValNat l y.num.natAbs = 0 := by
      refine padicValNat.eq_zero_of_not_dvd ?_
      intro hc
      exact hlb (Int.ofNat_dvd_left.mpr hc)
    have hdenDvd : ((dblX N x).den : ℤ) ∣ (4 * y.num ^ 2 * (e : ℤ) ^ 2) := by
      have := Rat.den_dvd (x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6)
        (4 * y.num ^ 2 * (e : ℤ) ^ 2)
      rwa [← Rat.intCast_div_eq_divInt, ← hdiv] at this
    have hnotdvd : ¬ l ∣ (dblX N x).den := by
      intro hc
      have hcZ : (l : ℤ) ∣ ((dblX N x).den : ℤ) := Int.ofNat_dvd_left.mpr hc
      have hB : (l : ℤ) ∣ 4 * y.num ^ 2 * (e : ℤ) ^ 2 := hcZ.trans hdenDvd
      rcases hlp.dvd_mul.mp hB with h1 | h2
      · rcases hlp.dvd_mul.mp h1 with h3 | h4
        · exact hl2 ((Nat.prime_dvd_prime_iff_eq hl Nat.prime_two).mp
            (hl.dvd_of_dvd_pow (n := 2) (by
              have : (l : ℤ) ∣ (4 : ℤ) := h3
              have : l ∣ 4 := by exact_mod_cast this
              simpa using this)))
        · exact hlb (hlp.dvd_of_dvd_pow h4)
      · exact hleZ (hlp.dvd_of_dvd_pow h2)
    rw [padicValNat.eq_zero_of_not_dvd hnotdvd, hvb]

/-- **Which good primes enter.**  A prime of good reduction not already in the
denominator of `x(P)` divides the denominator of `x(2P)` if and only if it
divides the numerator of `y(P)`.  This is the exact form of the counterexample
mechanism: the primes that appear are dictated by the point, not by `N`. -/
theorem good_prime_dvd_den_dblX_iff {N : ℤ} {x y : ℚ} (h : OnCurve N x y)
    (hy : y ≠ 0) {l : ℕ} (hl : l.Prime) (hl6N : ¬ ((l : ℤ) ∣ 6 * N))
    (hnd : ¬ l ∣ x.den) :
    l ∣ (dblX N x).den ↔ (l : ℤ) ∣ y.num := by
  haveI : Fact l.Prime := ⟨hl⟩
  have hb0 : y.num ≠ 0 := Rat.num_ne_zero.mpr hy
  have hbnat : y.num.natAbs ≠ 0 := Int.natAbs_ne_zero.mpr hb0
  have hval := padicValNat_den_dblX_good h hy hl hl6N hnd
  have hden0 : (dblX N x).den ≠ 0 := (dblX N x).den_nz
  constructor
  · intro hc
    have h1 : padicValNat l (dblX N x).den ≠ 0 := (dvd_iff_padicValNat_ne_zero hden0).mp hc
    have h2 : padicValNat l y.num.natAbs ≠ 0 := by omega
    exact Int.ofNat_dvd_left.mpr ((dvd_iff_padicValNat_ne_zero hbnat).mpr h2)
  · intro hc
    have hcn : l ∣ y.num.natAbs := by simpa using Int.natAbs_dvd_natAbs.mpr hc
    have h2 : padicValNat l y.num.natAbs ≠ 0 := (dvd_iff_padicValNat_ne_zero hbnat).mp hcn
    have h1 : padicValNat l (dblX N x).den ≠ 0 := by omega
    exact (dvd_iff_padicValNat_ne_zero hden0).mpr h1

/-- **Constancy along the orbit.**  For an odd prime `ℓ` already present in the
denominator at step `n`, the `ℓ`-adic valuation of the denominators of the
`x`-coordinates is constant from step `n` onwards. -/
theorem padicValNat_den_dblIter_const {N : ℤ}
    (hnt : ∀ x y : ℚ, OnCurve N x y → y ≠ 0) {P : ℚ × ℚ}
    (h : OnCurve N P.1 P.2) {l : ℕ} (hl : l.Prime) (hodd : l ≠ 2) {n : ℕ}
    (hd : l ∣ (dblIter N n P).1.den) :
    ∀ m : ℕ, padicValNat l (dblIter N (n + m) P).1.den
      = padicValNat l (dblIter N n P).1.den := by
  intro m
  induction m with
  | zero => simp
  | succ k ih =>
      have hstep : dblIter N (n + k + 1) P = dbl N (dblIter N (n + k) P) := by
        simp [dblIter, Function.iterate_succ_apply']
      have hsum : n + (k + 1) = n + k + 1 := by ring
      have hdk : l ∣ (dblIter N (n + k) P).1.den :=
        dvd_den_dblIter_of_dvd hnt h hl hd k
      rw [hsum, hstep]
      have := padicValNat_den_dblX_odd (dblIter_onCurve hnt h (n + k)) hl hodd hdk
      simpa [dbl] using this.trans ih

/-- **Sharpness of `sq_dvd_x_den`.**  If an odd prime divides the denominator
of `x(P)` to order exactly `2` — the minimum allowed by the `(e², e³)` shape —
then the same holds for `x(2P)`; the exponent never grows. -/
theorem sq_exact_dblX {N : ℤ} {x y : ℚ} (h : OnCurve N x y) {l : ℕ}
    (hl : l.Prime) (hodd : l ≠ 2) (hd : l ∣ x.den)
    (hexact : padicValNat l x.den = 2) :
    l ^ 2 ∣ (dblX N x).den ∧ ¬ (l ^ 3 ∣ (dblX N x).den) := by
  haveI : Fact l.Prime := ⟨hl⟩
  have hval : padicValNat l (dblX N x).den = 2 := by
    rw [padicValNat_den_dblX_odd h hl hodd hd, hexact]
  have hne : (dblX N x).den ≠ 0 := (dblX N x).den_nz
  constructor
  · rw [padicValNat_dvd_iff_le hne, hval]
  · rw [padicValNat_dvd_iff_le hne, hval]
    omega

end MordellDenominators