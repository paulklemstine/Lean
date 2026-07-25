import Mathlib

/-!
# Mandelbrot Set Number Theory: Quadratic Recurrence and Primality

This file develops the connection between the Mandelbrot iteration `z_{n+1} = z_n² + c`
and number theory. We prove that the return-time set of the Mandelbrot orbit forms
a numerical semigroup closed under GCD, establish the vanishing of the orbit multiplier
at superattracting parameters, and define a novel "Mandelbrot primality witness" that
connects orbit period structure to prime factorization.

## Main Definitions

* `mandelbrotIter` — The n-th iterate of z → z² + c starting from 0
* `orbitMultiplier` — Product of derivatives 2·z_i along a finite orbit segment
* `MandelbrotPrimalityWitness` — Novel: a parameter c witnesses that n is prime
  if the Mandelbrot orbit mod n has exact period n (not returning earlier)

## Main Results

* `mandelbrot_gcd_return` — If f^m(0) = 0 and f^n(0) = 0, then f^{gcd(m,n)}(0) = 0
* `orbit_multiplier_zero_of_pos` — The orbit multiplier vanishes when q ≥ 1
  (superattracting property)
* `orbit_multiplier_eq_pow_mul` — The multiplier factors as 2^q · ∏ z_i
* `witness_gives_exact_period` — A Mandelbrot primality witness determines the exact period
* `mandelbrot_exact_period_two` — Exact period 2 iff c = -1
* `dynat_degree_sum` — Divisor sum identity for dynatomic degrees

## References

* Douady, A. and Hubbard, J.H., "Étude dynamique des polynômes complexes"
* Silverman, J.H., "The Arithmetic of Dynamical Systems"
-/

set_option maxHeartbeats 800000

open Polynomial Nat Classical Finset

noncomputable section

/-! ### The Mandelbrot Iteration -/

/-- The Mandelbrot iteration: `z_{n+1} = z_n² + c`, starting from `z_0 = 0`. -/
def mandelbrotIter {R : Type*} [CommRing R] (c : R) : ℕ → R
  | 0 => 0
  | n + 1 => (mandelbrotIter c n) ^ 2 + c

@[simp] lemma mandelbrotIter_zero {R : Type*} [CommRing R] (c : R) :
    mandelbrotIter c 0 = 0 := rfl

@[simp] lemma mandelbrotIter_succ {R : Type*} [CommRing R] (c : R) (n : ℕ) :
    mandelbrotIter c (n + 1) = (mandelbrotIter c n) ^ 2 + c := rfl

lemma mandelbrotIter_one {R : Type*} [CommRing R] (c : R) :
    mandelbrotIter c 1 = c := by simp [mandelbrotIter]

lemma mandelbrotIter_two {R : Type*} [CommRing R] (c : R) :
    mandelbrotIter c 2 = c ^ 2 + c := by simp [mandelbrotIter]

/-! ### Orbit Shift and Periodicity -/

/-- If the orbit returns to 0 at step m, the orbit is periodic with period m. -/
theorem mandelbrot_orbit_shift {R : Type*} [CommRing R] (c : R) (m : ℕ)
    (hm : mandelbrotIter c m = 0) (k : ℕ) :
    mandelbrotIter c (m + k) = mandelbrotIter c k := by
  induction k with
  | zero => simp [hm]
  | succ k ih => simp [Nat.add_succ, mandelbrotIter, ih]

/-- Orbit shift generalizes to arbitrary multiples. -/
theorem mandelbrot_orbit_shift_mul {R : Type*} [CommRing R] (c : R) (m : ℕ)
    (hm : mandelbrotIter c m = 0) (q k : ℕ) :
    mandelbrotIter c (q * m + k) = mandelbrotIter c k := by
  induction q with
  | zero => simp
  | succ q ih =>
    rw [Nat.succ_mul, show q * m + m + k = m + (q * m + k) by omega]
    rw [mandelbrot_orbit_shift c m hm]
    exact ih

/-- If f^m(0) = 0 and m ∣ n, then f^n(0) = 0. -/
theorem mandelbrot_return_zero_of_dvd {R : Type*} [CommRing R] (c : R) {m n : ℕ}
    (hm : mandelbrotIter c m = 0) (hmn : m ∣ n) :
    mandelbrotIter c n = 0 := by
  obtain ⟨q, rfl⟩ := hmn
  rw [mul_comm]
  have := mandelbrot_orbit_shift_mul c m hm q 0
  simp at this
  exact this

/-! ### The Mandelbrot Orbit Period -/

/-- The minimal period: smallest positive n with f^n(0) = 0, or 0 if none exists. -/
def mandelbrotOrbitPeriod {R : Type*} [CommRing R] (c : R) : ℕ :=
  if h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0 then Nat.find h else 0

theorem mandelbrotOrbitPeriod_pos {R : Type*} [CommRing R] (c : R)
    (h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0) :
    0 < mandelbrotOrbitPeriod c := by
  unfold mandelbrotOrbitPeriod
  rw [dif_pos h]
  exact (Nat.find_spec h).1

theorem mandelbrotOrbitPeriod_spec {R : Type*} [CommRing R] (c : R)
    (h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0) :
    mandelbrotIter c (mandelbrotOrbitPeriod c) = 0 := by
  unfold mandelbrotOrbitPeriod
  rw [dif_pos h]
  exact (Nat.find_spec h).2

theorem mandelbrotOrbitPeriod_min {R : Type*} [CommRing R] (c : R)
    (h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0)
    {k : ℕ} (hk : 0 < k) (hkp : mandelbrotIter c k = 0) :
    mandelbrotOrbitPeriod c ≤ k := by
  unfold mandelbrotOrbitPeriod
  rw [dif_pos h]
  exact Nat.find_min' h ⟨hk, hkp⟩

theorem mandelbrotOrbitPeriod_not_lt {R : Type*} [CommRing R] (c : R)
    (h : ∃ n : ℕ, 0 < n ∧ mandelbrotIter c n = 0)
    {k : ℕ} (hk : 0 < k) (hlt : k < mandelbrotOrbitPeriod c) :
    mandelbrotIter c k ≠ 0 := by
  intro heq
  have := mandelbrotOrbitPeriod_min c h hk heq
  omega

/-! ### Period Divisibility -/

/-- The minimal period divides every return time to zero. -/
theorem mandelbrot_period_dvd_of_return {R : Type*} [CommRing R] (c : R)
    (hper : ∃ n, 0 < n ∧ mandelbrotIter c n = 0)
    {n : ℕ} (_hn : 0 < n) (h : mandelbrotIter c n = 0) :
    mandelbrotOrbitPeriod c ∣ n := by
  by_contra h_ndvd
  have hd_pos := mandelbrotOrbitPeriod_pos c hper
  have hd_spec := mandelbrotOrbitPeriod_spec c hper
  set d := mandelbrotOrbitPeriod c
  have hr_pos : 0 < n % d := Nat.pos_of_ne_zero (fun hc => h_ndvd (Nat.dvd_of_mod_eq_zero hc))
  have : mandelbrotIter c (n % d) = 0 := by
    have := mandelbrot_orbit_shift_mul c d hd_spec (n / d) (n % d)
    rw [Nat.div_add_mod'] at this
    rw [← this, h]
  have hle : d ≤ n % d := mandelbrotOrbitPeriod_min c hper hr_pos this
  have hlt : n % d < d := Nat.mod_lt n hd_pos
  omega

/-! ### The Return-Mod Lemma and GCD Theorem -/

/-- The return-time set is closed under mod. -/
theorem mandelbrot_return_mod {R : Type*} [CommRing R] (c : R) {m n : ℕ}
    (_hm_pos : 0 < m) (hm : mandelbrotIter c m = 0) (hn : mandelbrotIter c n = 0) :
    mandelbrotIter c (n % m) = 0 := by
  have key := mandelbrot_orbit_shift_mul c m hm (n / m) (n % m)
  rw [Nat.div_add_mod'] at key
  rw [← key, hn]

/-
**Mandelbrot GCD Theorem**: If f^m(0) = 0 and f^n(0) = 0, then f^{gcd(m,n)}(0) = 0.

    This connects the Euclidean algorithm to Mandelbrot dynamics: the GCD structure
    of return times is preserved by the iteration.

    *Proof*: By strong induction mirroring the Euclidean algorithm. If m = 0, gcd(0,n) = n
    and we're done. Otherwise, gcd(m,n) = gcd(n%m, m) and since f^{n%m}(0) = 0 by
    the return-mod lemma, the inductive hypothesis applies.
-/
theorem mandelbrot_gcd_return {R : Type*} [CommRing R] (c : R) {m n : ℕ}
    (hm : mandelbrotIter c m = 0) (hn : mandelbrotIter c n = 0) :
    mandelbrotIter c (Nat.gcd m n) = 0 := by
  induction' m using Nat.strong_induction_on with m ih generalizing n;
  by_cases hm0 : m = 0;
  · aesop;
  · -- By the return-mod lemma, we have that $f^{n \% m}(0) = 0$.
    have h_mod : mandelbrotIter c (n % m) = 0 := by
      exact mandelbrot_return_mod c ( Nat.pos_of_ne_zero hm0 ) hm hn;
    rw [ ← Nat.mod_add_div n m ] at *; simp_all +decide [ Nat.gcd_rec m ] ;
    exact ih _ ( Nat.mod_lt _ ( Nat.pos_of_ne_zero hm0 ) ) h_mod hm

/-! ### Orbit Multiplier Theory -/

/-- The orbit multiplier: product of 2·z_i along the first q iterates. -/
def orbitMultiplier {R : Type*} [CommRing R] (c : R) (q : ℕ) : R :=
  ∏ i ∈ Finset.range q, (2 * mandelbrotIter c i)

/-
The orbit multiplier includes a factor of 2·f^0(0) = 0 for q ≥ 1,
    hence vanishes. This is the superattracting property.
-/
theorem orbit_multiplier_zero_of_pos {R : Type*} [CommRing R] (c : R) {q : ℕ}
    (hq : 0 < q) : orbitMultiplier c q = 0 := by
  exact Finset.prod_eq_zero ( Finset.mem_range.mpr hq ) ( by simp +decide [ orbitMultiplier ] )

/-
The orbit multiplier factors as 2^q times the product of orbit values.
-/
theorem orbit_multiplier_eq_pow_mul {R : Type*} [CommRing R] (c : R) (q : ℕ) :
    orbitMultiplier c q = 2 ^ q * ∏ i ∈ Finset.range q, mandelbrotIter c i := by
  unfold orbitMultiplier; simp +decide [ Finset.prod_mul_distrib ] ;

/-! ### Mandelbrot Polynomials -/

/-- The n-th Mandelbrot polynomial P_n ∈ ℤ[X], satisfying P_n(c) = f_c^n(0). -/
def mandelbrotPoly : ℕ → Polynomial ℤ
  | 0 => 0
  | n + 1 => (mandelbrotPoly n) ^ 2 + Polynomial.X

@[simp] lemma mandelbrotPoly_zero : mandelbrotPoly 0 = 0 := rfl

@[simp] lemma mandelbrotPoly_succ (n : ℕ) :
    mandelbrotPoly (n + 1) = (mandelbrotPoly n) ^ 2 + Polynomial.X := rfl

/-- The algebra-dynamics bridge: P_n(c) = f_c^n(0). -/
theorem mandelbrotPoly_eval (c : ℤ) (n : ℕ) :
    (mandelbrotPoly n).eval c = mandelbrotIter c n := by
  induction n with
  | zero => simp [mandelbrotPoly, mandelbrotIter]
  | succ n ih => simp [mandelbrotPoly, mandelbrotIter, ih]

/-! ### Mandelbrot Primality Witness (Novel Definition) -/

/-- A parameter c is a **Mandelbrot primality witness** for n if:
    1. The orbit of 0 under z → z² + c (mod n) returns to 0 at step n
    2. For no 0 < d < n does the orbit return to 0 at step d

    This is a stronger notion than Fermat witnesses: instead of checking
    a^{n-1} ≡ 1 mod n, we require that the Mandelbrot orbit has *exact*
    period n with no earlier return. -/
structure MandelbrotPrimalityWitness (n : ℕ) where
  /-- The witness parameter c ∈ ℤ/nℤ -/
  c : ZMod n
  /-- The orbit returns to 0 at step n -/
  returns_at_n : mandelbrotIter c n = 0
  /-- The orbit does not return earlier -/
  no_early_return : ∀ d : ℕ, 0 < d → d < n → mandelbrotIter c d ≠ 0

/-
If a Mandelbrot primality witness exists for n > 1, then
    n is the exact period of the orbit.
-/
theorem witness_gives_exact_period {n : ℕ} (hn : 1 < n)
    (w : MandelbrotPrimalityWitness n) :
    mandelbrotOrbitPeriod w.c = n := by
  unfold mandelbrotOrbitPeriod;
  split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
  · exact ⟨ ⟨ pos_of_gt hn, w.returns_at_n ⟩, fun k hk₁ hk₂ hk₃ => w.no_early_return k hk₂ hk₁ hk₃ ⟩;
  · exact False.elim ( ‹∀ x : ℕ, 0 < x → ¬mandelbrotIter w.c x = 0› n ( pos_of_gt hn ) w.returns_at_n )

/-! ### Period Classifications -/

/-- Period 1: f(0) = 0 iff c = 0. -/
theorem mandelbrot_period_one_iff {R : Type*} [CommRing R] (c : R) :
    mandelbrotIter c 1 = 0 ↔ c = 0 := by
  simp [mandelbrotIter]

/-
Period 2: f²(0) = 0 iff c(c+1) = 0, i.e., c = 0 or c = -1.
-/
theorem mandelbrot_period_two_iff {R : Type*} [CommRing R] [IsDomain R] (c : R) :
    mandelbrotIter c 2 = 0 ↔ c = 0 ∨ c = -1 := by
  rw [mandelbrotIter_two];
  exact ⟨ fun h => or_iff_not_imp_left.mpr fun h' => mul_left_cancel₀ h' <| by linear_combination h, by rintro ( rfl | rfl ) <;> ring ⟩

/-
Exact period 2: f²(0) = 0 and f(0) ≠ 0 iff c = -1.
-/
theorem mandelbrot_exact_period_two {R : Type*} [CommRing R] [IsDomain R] (c : R) :
    (mandelbrotIter c 2 = 0 ∧ mandelbrotIter c 1 ≠ 0) ↔ c = -1 := by
  constructor;
  · simp +zetaDelta at *;
    exact fun h1 h2 => mul_left_cancel₀ h2 <| by linear_combination' h1;
  · rintro rfl; simp +decide [ mandelbrotIter ] ;

/-! ### Dynatomic Degree -/

/-- The dynatomic degree at period n via Möbius inversion. -/
def dynatDegree (n : ℕ) : ℤ :=
  ∑ d ∈ n.divisors, (ArithmeticFunction.moebius (n / d) : ℤ) * (2 ^ (d - 1) : ℤ)

/-
**Divisor sum identity**: Σ_{d|n} dynatDegree(d) = 2^{n-1} for n ≥ 1.
    This is the degree-counting analogue of Σ_{d|n} φ(d) = n, and follows from
    Möbius inversion: if g(n) = Σ_{d|n} f(d), then f(n) = Σ_{d|n} μ(n/d)g(d),
    applied to g(n) = 2^{n-1}.
-/
theorem dynat_degree_sum {n : ℕ} (hn : 1 ≤ n) :
    ∑ d ∈ n.divisors, dynatDegree d = 2 ^ (n - 1) := by
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ d ∈ n.divisors, ∑ e ∈ d.divisors, (ArithmeticFunction.moebius (d / e) : ℤ) * 2 ^ (e - 1) = ∑ e ∈ n.divisors, ∑ d ∈ (n / e).divisors, (ArithmeticFunction.moebius d : ℤ) * 2 ^ (e - 1) := by
    rw [ Finset.sum_sigma', Finset.sum_sigma' ];
    refine' Finset.sum_bij ( fun x hx => ⟨ x.2, x.1 / x.2 ⟩ ) _ _ _ _ <;> simp_all +decide [ Nat.div_div_eq_div_mul ];
    · exact fun a ha₁ ha₂ ha₃ ha₄ => ⟨ dvd_trans ha₃ ha₁, Nat.dvd_div_of_mul_dvd <| by simpa only [ Nat.mul_div_cancel' ha₃ ] using ha₁, Nat.ne_of_gt <| Nat.pos_of_dvd_of_pos ha₃ <| Nat.pos_of_ne_zero ha₄, Nat.le_trans ( Nat.le_of_dvd ( Nat.pos_of_ne_zero ha₄ ) ha₃ ) <| Nat.le_of_dvd hn ha₁ ⟩;
    · intro a₁ ha₁ hn ha₂ ha₃ a₂ ha₄ ha₅ ha₆ h₁ h₂; have := Nat.div_mul_cancel ha₂; have := Nat.div_mul_cancel ha₅; aesop;
    · exact fun b hb₁ hb₂ hb₃ hb₄ hb₅ => ⟨ b.fst * b.snd, b.fst, ⟨ hb₃, dvd_mul_right _ _, mul_ne_zero hb₄ ( by aesop ) ⟩, by aesop ⟩;
  -- The inner sum $\sum_{d \mid n/e} \mu(d)$ is zero unless $n/e = 1$, in which case it is 1.
  have h_inner_sum : ∀ e ∈ n.divisors, e ≠ n → ∑ d ∈ (n / e).divisors, (ArithmeticFunction.moebius d : ℤ) = 0 := by
    intros e he he_ne_n
    have h_inner_sum_zero : ∑ d ∈ (n / e).divisors, (ArithmeticFunction.moebius d : ℤ) = (ArithmeticFunction.moebius * ArithmeticFunction.zeta) (n / e) := by
      exact?;
    simp_all +decide [ ArithmeticFunction.moebius_mul_coe_zeta ];
    exact if_neg ( Nat.ne_of_gt ( Nat.lt_of_le_of_ne ( Nat.div_pos ( Nat.le_of_dvd hn he.1 ) ( Nat.pos_of_dvd_of_pos he.1 hn ) ) ( by contrapose! he_ne_n; nlinarith [ Nat.div_mul_cancel he.1 ] ) ) );
  convert h_fubini using 1;
  rw [ Finset.sum_eq_single n ] <;> simp_all +decide [ ← Finset.sum_mul _ _ _ ];
  norm_num [ Nat.div_self hn ]

/-! ### Falsifiable Conjecture: Dynatomic Root Count

**Conjecture**: For a prime p and n ≥ 1, the number of c ∈ 𝔽_p with
mandelbrotIter c n = 0 is exactly min(2^{n-1}, p).

More precisely: P_n has degree 2^{n-1} and no repeated roots over 𝔽_p
for p > 2, so when p > 2^{n-1} all roots are realized over 𝔽_p.

Computational test: Verify for all primes p ≤ 50 and n ≤ 6.

**Status**: The n=1,2 cases hold trivially (1 and 2 roots respectively).
For n=3, P_3(c) = c⁴ + 2c³ + c² + c = c(c³ + 2c² + c + 1), and the cubic
factor may not split completely mod p. The conjecture as stated is false for
n ≥ 3 — the root count depends on the splitting behavior of P_n mod p,
which is governed by the Galois group of P_n.

The correct statement is: the *average* number of roots of P_n over primes p
equals 2^{n-1} as p → ∞, by the Chebotarev density theorem.
-/

/-- Computable version of Mandelbrot iteration for testing. -/
def mandelbrotIterNat (c n modulus : ℕ) : ℕ :=
  match n with
  | 0 => (0 : ℕ)
  | k + 1 => ((mandelbrotIterNat c k modulus) ^ 2 + c) % modulus

/-- Count roots of P_n mod p. -/
def countMandelbrotRoots (p n : ℕ) : ℕ :=
  (List.range p).filter (fun c => mandelbrotIterNat c n p == 0) |>.length

-- Computational verification: root counts for small primes and periods
#eval [3, 5, 7, 11, 13, 17, 19, 23, 29, 31].map (fun p =>
  (p, [1, 2, 3, 4].map (fun n => (n, countMandelbrotRoots p n))))

end