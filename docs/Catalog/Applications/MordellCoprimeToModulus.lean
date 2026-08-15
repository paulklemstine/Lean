import Applications.MordellDenominatorLocalLaw

/-!
# Denominators coprime to the modulus: the anti-factoring law

Cycles 1–5 established that the primes appearing in the denominators of `x(nP)` on a Mordell
curve `E_N : y² = x³ + N` are governed by reduction to the identity, not by bad reduction, so
the "only bad primes" conjecture is false.  The present cycle attacks the *converse* question,
which is the one that actually matters for the factoring application:

> can a bad prime — a prime `p ∣ N` — ever show up in a denominator?

The answer proved here is a sharp structural law: a prime `p ≠ 2` dividing `N` divides
`den x(2P)` **only** if the point already meets the singular locus mod `p`, i.e. only if
`p ∣ den x(P)` or `p` divides both `x.num` and `y.num` (the reduction of `P` is the singular
point `(0,0)` of `E_N` mod `p`).  Consequently, for an odd `N` and a point whose coordinates
are `p`-units for every `p ∣ N`, the *entire doubling orbit* has denominators coprime to `N`:
a denominator oracle along `{2^k P}` never reveals a factor of `N`.

This is the precise mechanism behind the survey observation that the second prime `q` of a
semiprime `N = pq` was never seen in a denominator, and it converts "barrier 5" from an
empirical remark into a theorem.

## Main results

* `den_double_dvd_and_num_dvd` : the integral bookkeeping for one doubling step,
  `den x(2P) ∣ 4·y.num²·den x(P)` and `num x(2P) ∣ x.num·(x.num³ − 8N·den x(P)³)`.
* `isCoprime_num_y_of_isCoprime_num_x` : coprimality to `N` propagates from `x.num` to `y.num`.
* `den_double_isCoprime` : one doubling step preserves coprimality of the numerator and the
  denominator of the `x`-coordinate to an odd `N`.
* `bad_prime_dvd_den_double` : **the singular-locus law** — a bad prime `p ≠ 2` divides
  `den x(2P)` only if `p ∣ den x(P)` or `p ∣ x.num ∧ p ∣ y.num`.
* `xCoord_two_pow_smul_isCoprime` : the orbit form — along `{2^k P}` all `x`-numerators and
  `x`-denominators stay coprime to `N`.
* `no_factor_of_N_in_doubling_orbit` : **the anti-factoring theorem** — no prime factor of `N`
  ever divides a denominator along the doubling orbit of such a point.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 6): the empirical "`q` appears in 0% of denominators" is not a
  statistical accident but a theorem: bad primes are *forbidden* in denominators unless the
  point is already `p`-singular, whereas good primes are forced by a codimension-one condition.
Experiment (Experimenter): `N = 55`, `P = (9,28)`: denominators `3136 = 2⁶·7²` (2P),
  `3⁶·13²·73²` (3P); none of `5`, `11` occurs, while `7`, `13`, `73` (all good) do.
  `N = 1763 = 41·43`, `P = (1,42)`: `x(2P) = −1567/784`, `784 = 2⁴·7²` — again only good primes.
Analysis (Analyst): with the coprime parametrisation `x = a/e²`, `y = b/e³`, the doubled
  `x`-coordinate is `a(a³ − 8Ne⁶)/(4b²e²)`.  Every prime of the denominator divides `2be`, and
  `b² = a³ + Ne⁶` forces `gcd(b, N) ∣ gcd(a, N)`: a bad prime can only enter through `a` or `e`.
Critique (Critic): the hypothesis `p ≠ 2` (resp. `N` odd) is necessary — the factor `4` in the
  doubling formula puts `2` into the denominator for free, which is why the even prime is
  excluded from the statements below and why the family theorems use odd `N`.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## Integral bookkeeping for one doubling step -/

/-- If `q = A / B` in lowest terms with `B ≠ 0`, then `q.num` divides `A`. -/
lemma num_dvd_numer {A B : ℤ} (hB : B ≠ 0) : ((A : ℚ) / (B : ℚ)).num ∣ A := by
  set q : ℚ := (A : ℚ) / (B : ℚ) with hq
  obtain ⟨C, hC⟩ : ((q.den : ℤ)) ∣ B := den_dvd_denom A B
  have hkey : q.num * B = A * (q.den : ℤ) := num_mul_den hB
  have hd : ((q.den : ℤ)) ≠ 0 := by exact_mod_cast q.den_nz
  refine ⟨C, ?_⟩
  have : (A * (q.den : ℤ)) = (q.num * C) * (q.den : ℤ) := by
    rw [← hkey, hC]; ring
  exact (mul_right_cancel₀ hd this)

/-- **Integral bookkeeping for doubling.**  For a rational point `(x, y)` of `E_N` with `y ≠ 0`,
the denominator of `x(2P)` divides `4·y.num²·den x(P)` and the numerator of `x(2P)` divides
`x.num·(x.num³ − 8N·den x(P)³)`. -/
lemma den_double_dvd_and_num_dvd {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) (hy : y ≠ 0) :
    ((((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den : ℤ) ∣
        4 * y.num ^ 2 * ((x.den : ℤ))) ∧
      (((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).num ∣
        x.num * (x.num ^ 3 - 8 * N * ((x.den : ℤ)) ^ 3)) := by
  obtain ⟨e, he0, -, -, hxden, hx, hy', -⟩ := mordell_param_general h
  have hb0 : y.num ≠ 0 := Rat.num_ne_zero.mpr hy
  have hE : ((e : ℤ)) ^ 2 = ((x.den : ℤ)) := by rw [hxden]; push_cast; ring
  have hfrac := den_double_eq_int_frac (N := N) (x := x) (y := y) (a := x.num) (b := y.num)
    he0 hb0 hx hy'
  have hB0 : (4 * y.num ^ 2 * (e : ℤ) ^ 2 : ℤ) ≠ 0 := by
    have : ((e : ℤ)) ≠ 0 := by exact_mod_cast he0.ne'
    positivity
  constructor
  · have h1 := den_dvd_denom (x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6)
      (4 * y.num ^ 2 * (e : ℤ) ^ 2)
    rw [hfrac]
    calc ((((x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6 : ℤ) : ℚ) /
            ((4 * y.num ^ 2 * (e : ℤ) ^ 2 : ℤ) : ℚ)).den : ℤ)
        ∣ 4 * y.num ^ 2 * (e : ℤ) ^ 2 := h1
      _ = 4 * y.num ^ 2 * ((x.den : ℤ)) := by rw [hE]
  · have h2 := num_dvd_numer (A := x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6)
      (B := 4 * y.num ^ 2 * (e : ℤ) ^ 2) hB0
    have h6 : ((e : ℤ)) ^ 6 = ((x.den : ℤ)) ^ 3 := by rw [← hE]; ring
    have hEq : x.num ^ 4 - 8 * N * x.num * (e : ℤ) ^ 6
        = x.num * (x.num ^ 3 - 8 * N * ((x.den : ℤ)) ^ 3) := by rw [← h6]; ring
    rw [hfrac, ← hEq]
    exact h2

/-! ## Coprimality to the modulus propagates -/

/-- If `x.num` is coprime to `N` then so is `y.num`: from `b² = a³ + N e⁶`, any common divisor
of `b` and `N` divides `a³`. -/
lemma isCoprime_num_y_of_isCoprime_num_x {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ))
    (hco : IsCoprime x.num N) : IsCoprime y.num N := by
  obtain ⟨e, -, -, -, -, -, -, heq⟩ := mordell_param_general h
  have hcube : IsCoprime (x.num ^ 3) N := hco.pow_left
  obtain ⟨u, v, huv⟩ := hcube
  have hsq : IsCoprime (y.num ^ 2) N := by
    refine ⟨u, v - u * (e : ℤ) ^ 6, ?_⟩
    rw [heq]; linear_combination huv
  exact IsCoprime.of_isCoprime_of_dvd_left hsq (dvd_pow_self _ (by norm_num))

/-! ## The doubling step preserves coprimality to an odd modulus -/

/-- **One doubling step preserves coprimality.**  Let `N` be odd and let `(x, y)` be a rational
point of `E_N` with `y ≠ 0` whose `x`-coordinate has numerator and denominator coprime to `N`.
Then the same holds for `x(2P)`. -/
theorem den_double_isCoprime {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) (hy : y ≠ 0)
    (hN : IsCoprime (2 : ℤ) N) (hnum : IsCoprime x.num N) (hden : IsCoprime ((x.den : ℤ)) N) :
    IsCoprime ((((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den : ℤ)) N ∧
      IsCoprime ((((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).num)) N := by
  obtain ⟨hdvdD, hdvdA⟩ := den_double_dvd_and_num_dvd h hy
  have hb : IsCoprime y.num N := isCoprime_num_y_of_isCoprime_num_x h hnum
  constructor
  · have hfour : IsCoprime (4 : ℤ) N := by
      have : IsCoprime ((2 : ℤ) * 2) N := hN.mul_left hN
      simpa [show (2 : ℤ) * 2 = 4 by norm_num] using this
    have hB : IsCoprime (4 * y.num ^ 2 * ((x.den : ℤ))) N :=
      (hfour.mul_right hb.pow_left).mul_right hden
    exact IsCoprime.of_isCoprime_of_dvd_left hB hdvdD
  · have hshift : IsCoprime (x.num ^ 3 - 8 * N * ((x.den : ℤ)) ^ 3) N := by
      obtain ⟨u, v, huv⟩ := (hnum.pow_left : IsCoprime (x.num ^ 3) N)
      exact ⟨u, v + u * 8 * ((x.den : ℤ)) ^ 3, by linear_combination huv⟩
    exact IsCoprime.of_isCoprime_of_dvd_left (hnum.mul_left hshift) hdvdA

/-! ## The singular-locus law for bad primes -/

/-- **Bad primes only enter through the singular locus.**  Let `p ≠ 2` be a prime dividing `N`
(a prime of bad reduction for `E_N`) and let `(x, y)` be a rational point of `E_N` with
`y ≠ 0`.  If `p` divides `den x(2P)` then either `p` already divides `den x(P)`, or the
reduction of `P` mod `p` is the singular point `(0,0)`, i.e. `p ∣ x.num` and `p ∣ y.num`.

Equivalently: at a point of good reduction mod `p`, a bad prime never appears in the doubled
denominator.  This is the structural reason why the factors of `N` are not visible in the
denominator sequence. -/
theorem bad_prime_dvd_den_double {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) (hy : y ≠ 0)
    {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hpN : (p : ℤ) ∣ N)
    (hdvd : p ∣ (((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den)) :
    (p : ℤ) ∣ ((x.den : ℤ)) ∨ ((p : ℤ) ∣ x.num ∧ (p : ℤ) ∣ y.num) := by
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  obtain ⟨hdvdD, -⟩ := den_double_dvd_and_num_dvd h hy
  have hdz : ((p : ℤ)) ∣ 4 * y.num ^ 2 * ((x.den : ℤ)) :=
    dvd_trans (by exact_mod_cast hdvd) hdvdD
  rcases hpz.dvd_mul.mp hdz with hleft | hright
  · rcases hpz.dvd_mul.mp hleft with h4 | hb2
    · exfalso
      have h2 : ((p : ℤ)) ∣ 2 := hpz.dvd_of_dvd_pow (n := 2) (by norm_num at h4 ⊢; exact h4)
      have hle : ((p : ℤ)) ≤ 2 := Int.le_of_dvd (by norm_num) h2
      have : p ≤ 2 := by exact_mod_cast hle
      interval_cases p <;> simp_all (config := { decide := true })
    · -- `p ∣ y.num`; then `p ∣ x.num` via the curve equation
      right
      have hb : ((p : ℤ)) ∣ y.num := hpz.dvd_of_dvd_pow hb2
      obtain ⟨e, -, -, -, -, -, -, heq⟩ := mordell_param_general h
      have hx3 : ((p : ℤ)) ∣ x.num ^ 3 := by
        have h1 : ((p : ℤ)) ∣ y.num ^ 2 := by rw [sq]; exact hb.mul_left y.num
        have h2 : ((p : ℤ)) ∣ N * (e : ℤ) ^ 6 := hpN.mul_right _
        have := dvd_sub h1 h2
        rwa [heq, add_sub_cancel_right] at this
      exact ⟨hpz.dvd_of_dvd_pow hx3, hb⟩
  · exact Or.inl hright

/-! ## Squarefree moduli: the singular locus is empty -/

/-- **Squarefree moduli have no integral singular points.**  If `N` is squarefree and `(x, y)`
is an integral point of `E_N`, then `x` is automatically coprime to `N`: a common prime factor
`p` of `x` and `N` would force `p² ∣ N`. -/
lemma isCoprime_x_of_squarefree {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hsf : Squarefree N) :
    IsCoprime x N := by
  rw [Int.isCoprime_iff_gcd_eq_one]
  by_contra hg
  set g : ℕ := Int.gcd x N with hgdef
  have hg1 : 1 < g := by
    rcases Nat.lt_or_ge g 1 with h | h
    · interval_cases g
      · exfalso
        have hx0 : x = 0 := Int.gcd_eq_zero_iff.mp hgdef.symm |>.1
        have hN0 : N = 0 := Int.gcd_eq_zero_iff.mp hgdef.symm |>.2
        rw [hN0] at hsf
        exact (not_squarefree_zero hsf)
    · omega
  set p : ℕ := g.minFac with hpdef
  have hp : p.Prime := Nat.minFac_prime (by omega)
  have hpg : (p : ℤ) ∣ (g : ℤ) := Int.natCast_dvd_natCast.mpr (Nat.minFac_dvd g)
  have hpx : (p : ℤ) ∣ x := hpg.trans (Int.gcd_dvd_left)
  have hpN : (p : ℤ) ∣ N := hpg.trans (Int.gcd_dvd_right)
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hpy : (p : ℤ) ∣ y := by
    have h1 : (p : ℤ) ∣ y ^ 2 := by
      rw [heq]
      exact dvd_add (Dvd.dvd.pow hpx (by norm_num)) hpN
    exact hpz.dvd_of_dvd_pow h1
  have hy2 : ((p : ℤ)) * (p : ℤ) ∣ y ^ 2 := by
    obtain ⟨c, rfl⟩ := hpy; exact ⟨c ^ 2, by ring⟩
  have hx3 : ((p : ℤ)) * (p : ℤ) ∣ x ^ 3 := by
    obtain ⟨c, rfl⟩ := hpx; exact ⟨(p : ℤ) * c ^ 3, by ring⟩
  have hNsq : ((p : ℤ)) * (p : ℤ) ∣ N := by
    have : N = y ^ 2 - x ^ 3 := by omega
    rw [this]; exact dvd_sub hy2 hx3
  have := hsf _ hNsq
  rw [Int.isUnit_iff] at this
  have := hp.one_lt
  omega

/-- **No bad prime in the doubled denominator, for squarefree moduli.**  If `N` is squarefree —
in particular if `N = pq` is a semiprime — then for *every* integral point `(x, y)` of `E_N`
with `y ≠ 0` and every odd prime `p ∣ N`, the prime `p` does **not** divide `den x(2P)`.

No hypothesis on the point is needed: over a squarefree modulus the singular locus carries no
integral points, so the only route by which a bad prime could enter a denominator is closed. -/
theorem no_bad_prime_of_squarefree {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (hsf : Squarefree N) {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hpN : (p : ℤ) ∣ N) :
    ¬ p ∣ ((((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den) := by
  intro hdvd
  have heq' : ((y : ℚ)) ^ 2 = ((x : ℚ)) ^ 3 + (N : ℚ) := by
    exact_mod_cast congrArg (Int.cast : ℤ → ℚ) heq
  have hy' : ((y : ℚ)) ≠ 0 := Int.cast_ne_zero.mpr hy
  have hco : IsCoprime x N := isCoprime_x_of_squarefree heq hsf
  rcases bad_prime_dvd_den_double heq' hy' hp hp2 hpN hdvd with hden | ⟨hnum, -⟩
  · rw [Rat.den_intCast] at hden
    have : ((p : ℤ)) ≤ 1 := Int.le_of_dvd (by norm_num) (by simpa using hden)
    have : p ≤ 1 := by exact_mod_cast this
    have := hp.one_lt
    omega
  · rw [Rat.num_intCast] at hnum
    have hu : IsUnit ((p : ℤ)) := hco.isUnit_of_dvd' hnum hpN
    rw [Int.isUnit_iff] at hu
    have := hp.one_lt
    omega

/-! ## The integral case and the doubling orbit -/

/-- **Integral points.**  If `N` is odd and `(x, y)` is an integral point of `E_N` with `y ≠ 0`
whose `x`-coordinate is coprime to `N`, then the denominator of `x(2P)` is coprime to `N`. -/
theorem den_double_isCoprime_int {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (hN : IsCoprime (2 : ℤ) N) (hx : IsCoprime x N) :
    IsCoprime ((((((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den : ℤ))) N := by
  have heq' : ((y : ℚ)) ^ 2 = ((x : ℚ)) ^ 3 + (N : ℚ) := by exact_mod_cast congrArg (Int.cast : ℤ → ℚ) heq
  have hy' : ((y : ℚ)) ≠ 0 := Int.cast_ne_zero.mpr hy
  have hnum : IsCoprime ((x : ℚ)).num N := by rw [Rat.num_intCast]; exact hx
  have hden : IsCoprime ((((x : ℚ)).den : ℤ)) N := by
    rw [Rat.den_intCast]; exact isCoprime_one_left
  exact (den_double_isCoprime heq' hy' hN hnum hden).1

/-- One doubling step in group-law form: coprimality to an odd `N` of the numerator and
denominator of the `x`-coordinate is inherited by `R + R`. -/
theorem xCoord_double_isCoprime {N : ℤ} (hN : IsCoprime (2 : ℤ) N)
    {R : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ} (hR : xCoord R = some X)
    (hnum : IsCoprime X.num N) (hden : IsCoprime ((X.den : ℤ)) N)
    {Y : ℚ} (hY : xCoord (R + R) = some Y) :
    IsCoprime Y.num N ∧ IsCoprime ((Y.den : ℤ)) N := by
  cases hRc : R with
  | zero => rw [hRc] at hR; simp [xCoord] at hR
  | @some x y hns =>
      have hxX : x = X := by rw [hRc] at hR; simpa [xCoord] using hR
      have heq : y ^ 2 = x ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hns.1
      have hy0 : y ≠ 0 := by
        intro hy
        have hzero : (Point.some hns) + (Point.some hns) = 0 := by
          refine WeierstrassCurve.Affine.Point.add_self_of_Y_eq ?_
          simp [WeierstrassCurve.Affine.negY, mordell, hy]
        rw [hRc, hzero] at hY
        simp [xCoord] at hY
      have hdbl : xCoord ((Point.some hns) + (Point.some hns))
          = some ((x ^ 4 - 8 * ((N : ℤ) : ℚ) * x) / (4 * y ^ 2)) :=
        mordell_double_xCoord _ _ _ hns hy0
      have hYeq : Y = (x ^ 4 - 8 * ((N : ℤ) : ℚ) * x) / (4 * y ^ 2) := by
        rw [hRc, hdbl] at hY
        simpa using hY.symm
      subst hYeq
      obtain ⟨h1, h2⟩ := den_double_isCoprime heq hy0 hN (by rw [hxX]; exact hnum)
        (by rw [hxX]; exact hden)
      exact ⟨h2, h1⟩

/-- **The doubling orbit stays coprime to `N`.**  Let `N` be odd and let `R` be a rational point
of `E_N` whose `x`-coordinate has numerator and denominator coprime to `N`.  Then for every `k`,
whenever `2^k · R` is affine its `x`-coordinate again has numerator and denominator coprime
to `N`. -/
theorem xCoord_two_pow_smul_isCoprime {N : ℤ} (hN : IsCoprime (2 : ℤ) N)
    {R : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ} (hR : xCoord R = some X)
    (hnum : IsCoprime X.num N) (hden : IsCoprime ((X.den : ℤ)) N) (k : ℕ) :
    ∀ Y : ℚ, xCoord ((2 ^ k : ℕ) • R) = some Y →
      IsCoprime Y.num N ∧ IsCoprime ((Y.den : ℤ)) N := by
  induction k with
  | zero =>
      intro Y hYk
      simp only [pow_zero, one_nsmul] at hYk
      rw [hR] at hYk
      have : Y = X := by simpa using hYk.symm
      subst this
      exact ⟨hnum, hden⟩
  | succ k ih =>
      intro Y hYk
      have hstep : ((2 ^ (k + 1) : ℕ)) • R = (2 ^ k : ℕ) • R + (2 ^ k : ℕ) • R := by
        rw [← two_nsmul, ← mul_nsmul', pow_succ, mul_comm]
      rw [hstep] at hYk
      -- the intermediate point is affine, else the sum would be the point at infinity
      cases hS : ((2 ^ k : ℕ) • R) with
      | zero => rw [hS] at hYk; simp [xCoord] at hYk
      | @some x y hns =>
          have hX' : xCoord ((2 ^ k : ℕ) • R) = some x := by rw [hS]; rfl
          obtain ⟨h1, h2⟩ := ih x hX'
          exact xCoord_double_isCoprime hN hX' h1 h2 hYk

/-- **The anti-factoring theorem.**  Let `N` be odd (e.g. `N = pq` a semiprime) and let `R` be a
rational point of `E_N` whose `x`-coordinate has numerator and denominator coprime to `N`.
Then no prime factor of `N` divides the denominator of the `x`-coordinate of any point of the
doubling orbit `{2^k · R}`.

So the denominator sequence along a doubling orbit is a *`N`-unit* sequence: reading it off
never exposes a factor of `N`, no matter how far the orbit is followed.  Together with the
refutation of the "only bad primes" conjecture — the denominators do contain plenty of primes,
just good ones — this pins down exactly what the denominator oracle can and cannot see. -/
theorem no_factor_of_N_in_doubling_orbit {N : ℤ} (hN : IsCoprime (2 : ℤ) N)
    {R : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ} (hR : xCoord R = some X)
    (hnum : IsCoprime X.num N) (hden : IsCoprime ((X.den : ℤ)) N) {p : ℕ} (hp : p.Prime)
    (hpN : (p : ℤ) ∣ N) (k : ℕ) {Y : ℚ} (hYk : xCoord ((2 ^ k : ℕ) • R) = some Y) :
    ¬ p ∣ Y.den := by
  intro hdvd
  obtain ⟨-, hcop⟩ := xCoord_two_pow_smul_isCoprime hN hR hnum hden k Y hYk
  have hpd : ((p : ℤ)) ∣ ((Y.den : ℤ)) := by exact_mod_cast hdvd
  have : IsUnit ((p : ℤ)) := hcop.isUnit_of_dvd' hpd hpN
  rw [Int.isUnit_iff] at this
  have hp1 : 1 < p := hp.one_lt
  omega

/-- **The capstone.**  Let `N` be odd and squarefree — e.g. `N = pq` an odd semiprime, exactly
the situation of the factoring application — and let `P = (X, Y)` be **any** integral point of
`E_N`.  Then no prime factor of `N` divides the denominator of the `x`-coordinate of any point
of the doubling orbit `{2^k · P}`.

The denominators along a doubling orbit therefore carry no information whatsoever about the
factorisation of `N`: every prime they contain is a prime of good reduction (or `2`).  This is
the exact converse of the refuted "only bad primes" conjecture. -/
theorem integral_point_orbit_no_factor {N X Y : ℤ} (hodd : IsCoprime (2 : ℤ) N)
    (hsf : Squarefree N) (hns : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular ((X : ℚ)) ((Y : ℚ)))
    {p : ℕ} (hp : p.Prime) (hpN : (p : ℤ) ∣ N) (k : ℕ) {Z : ℚ}
    (hZ : xCoord ((2 ^ k : ℕ) • (Point.some hns)) = some Z) : ¬ p ∣ Z.den := by
  have heqQ : ((Y : ℚ)) ^ 2 = ((X : ℚ)) ^ 3 + ((N : ℤ) : ℚ) :=
    (mordell_equation_iff _ _ _).1 hns.1
  have heq : Y ^ 2 = X ^ 3 + N := by exact_mod_cast heqQ
  have hnum : IsCoprime (((X : ℚ)).num) N := by
    rw [Rat.num_intCast]; exact isCoprime_x_of_squarefree heq hsf
  have hden : IsCoprime ((((X : ℚ)).den : ℤ)) N := by
    rw [Rat.den_intCast]; exact isCoprime_one_left
  exact no_factor_of_N_in_doubling_orbit hodd (X := (X : ℚ)) rfl hnum hden hp hpN k hZ

end MordellDenominators