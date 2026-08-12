import Mathlib

/-!
# Barrier I: the polynomial (algebraic) barrier for integer factorization

A large family of proposed factoring strategies has the following shape: build some
*polynomial invariant* of the modulus `N` (a resultant, a discriminant, a
hyperdeterminant, a lattice/LLL-derived integer, ...), evaluate it at `N`, and take
a gcd with `N` hoping to peel off a prime factor.

This file proves that the whole family is powerless, and quantifies exactly how
powerless.

* `FactoringBarriers.polyBarrier_dvd_iff` : for a prime `p ∣ N` and `f ∈ ℤ[X]`,
  `p ∣ f(N) ↔ p ∣ f(0)`.
* `FactoringBarriers.polyWitness_eq_gcd_const` : `gcd (f(N), N) = gcd (f(0), N)`,
  i.e. the witness does not depend on `N` through `f` at all.
* `FactoringBarriers.no_universal_family_witness` : no *finite family* of integer
  polynomials splits every semiprime; in particular no single polynomial does
  (`no_universal_polynomial_witness`).
* `FactoringBarriers.card_revealedPrimes_le_log` : a fixed `f` can ever reveal at
  most `log₂ |f(0)|` primes in total, over all inputs `N`.

The proofs use only the divisibility `a - b ∣ f(a) - f(b)` plus unique factorization
and the infinitude of primes; no computational hypotheses are needed, so the barrier
is unconditional and information-theoretic in nature.
-/

namespace FactoringBarriers

open Polynomial

/-- `N` is a product of two *distinct* primes: the shape of an RSA-like modulus. -/
def IsDistinctSemiprime (N : ℕ) : Prop :=
  ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ N = p * q

/-- The gcd-witness produced by the polynomial invariant `f` on input `N`. -/
def polyWitness (f : ℤ[X]) (N : ℕ) : ℕ := Int.gcd (f.eval (N : ℤ)) (N : ℤ)

/-- `f` *splits* `N` if its gcd-witness is a nontrivial divisor of `N`. -/
def Splits (f : ℤ[X]) (N : ℕ) : Prop := 1 < polyWitness f N ∧ polyWitness f N < N

/-- The primes a fixed polynomial invariant can ever expose: the prime factors of
its constant term.  This finite set is *independent of the input* `N`. -/
def revealedPrimes (f : ℤ[X]) : Finset ℕ := ((f.eval 0).natAbs).primeFactors

/-! ### The congruence at the heart of the barrier -/

/-- `f(N) ≡ f(0) (mod N)` for every integer polynomial. -/
theorem eval_sub_eval_zero_dvd (f : ℤ[X]) (N : ℤ) : N ∣ f.eval N - f.eval 0 := by
  simpa using Polynomial.sub_dvd_eval_sub N 0 f

/-- **Polynomial barrier, local form.**  A prime dividing `N` divides `f(N)` exactly
when it divides the constant term `f(0)`.  Consequently the *set* of prime factors of
`N` that a polynomial invariant can detect does not depend on `N`. -/
theorem polyBarrier_dvd_iff (f : ℤ[X]) (p : ℕ) (N : ℤ) (hpN : (p : ℤ) ∣ N) :
    (p : ℤ) ∣ f.eval N ↔ (p : ℤ) ∣ f.eval 0 := by
  have hd : (p : ℤ) ∣ f.eval N - f.eval 0 := hpN.trans (eval_sub_eval_zero_dvd f N)
  constructor
  · intro h
    have := dvd_sub h hd
    simpa using this
  · intro h
    have := dvd_add h hd
    simpa using this

/-- **Polynomial barrier, global form.**  The gcd witness of `f` at `N` coincides with
the gcd of the *constant term* with `N`.  All dependence on `N` inside `f` cancels. -/
theorem polyWitness_eq_gcd_const (f : ℤ[X]) (N : ℕ) :
    polyWitness f N = Int.gcd (f.eval 0) (N : ℤ) := by
  obtain ⟨k, hk⟩ := eval_sub_eval_zero_dvd f (N : ℤ)
  have hval : f.eval (N : ℤ) = f.eval 0 + (N : ℤ) * k := by linarith [hk]
  unfold polyWitness
  rw [hval, Int.gcd_add_mul_left_left]

/-- Every prime that a polynomial invariant actually exposes lies in the fixed finite
set `revealedPrimes f`. -/
theorem mem_revealedPrimes_of_splits_prime
    {f : ℤ[X]} {N r : ℕ} (hf : f.eval 0 ≠ 0) (hr : r.Prime)
    (hrN : r ∣ N) (hrf : (r : ℤ) ∣ f.eval (N : ℤ)) : r ∈ revealedPrimes f := by
  have hrN' : (r : ℤ) ∣ (N : ℤ) := Int.natCast_dvd_natCast.mpr hrN
  have h0 : (r : ℤ) ∣ f.eval 0 := (polyBarrier_dvd_iff f r (N : ℤ) hrN').mp hrf
  have : r ∣ (f.eval 0).natAbs := by
    simpa using Int.natAbs_dvd_natAbs.mpr h0
  exact Nat.mem_primeFactors.mpr ⟨hr, this, by simpa [Int.natAbs_eq_zero] using hf⟩

/-! ### Extension: rational (integer-valued) invariants -/

/-- **Barrier I for scaled / integer-valued invariants.**  Many proposed invariants are
rational: an integer `g(N)` divided by a fixed denominator `m` (a determinant, an index,
a factorial normalisation).  Write the value as `v` with `m * v = g(N)`.  Then any prime
of `N` that divides the value must divide either the denominator `m` or the constant
value `v₀`.  So passing to rational invariants adds exactly one new source of primes —
the denominator — and no dependence on `N`. -/
theorem scaled_barrier {g : ℤ[X]} {m N vN v0 : ℤ} {r : ℕ} (hr : r.Prime)
    (hrN : (r : ℤ) ∣ N) (hvN : m * vN = g.eval N) (hv0 : m * v0 = g.eval 0)
    (hrv : (r : ℤ) ∣ vN) : (r : ℤ) ∣ m ∨ (r : ℤ) ∣ v0 := by
  have hdiff : (r : ℤ) ∣ m * vN - m * v0 := by
    rw [hvN, hv0]
    exact hrN.trans (eval_sub_eval_zero_dvd g N)
  have hmvN : (r : ℤ) ∣ m * vN := Dvd.dvd.mul_left hrv m
  have hmv0 : (r : ℤ) ∣ m * v0 := by
    have := dvd_sub hmvN hdiff
    simpa using this
  have hprime : Prime (r : ℤ) := Nat.prime_iff_prime_int.mp hr
  exact hprime.dvd_mul.mp hmv0

/-- If the prime does not divide the denominator, the scaled invariant obeys the same
dichotomy as an integral one: divisibility of the value at `N` is equivalent to
divisibility of the value at `0`. -/
theorem scaled_barrier_iff {g : ℤ[X]} {m N vN v0 : ℤ} {r : ℕ} (hr : r.Prime)
    (hrN : (r : ℤ) ∣ N) (hrm : ¬ (r : ℤ) ∣ m) (hvN : m * vN = g.eval N)
    (hv0 : m * v0 = g.eval 0) : (r : ℤ) ∣ vN ↔ (r : ℤ) ∣ v0 := by
  have hprime : Prime (r : ℤ) := Nat.prime_iff_prime_int.mp hr
  have hdiff : (r : ℤ) ∣ m * (vN - v0) := by
    have : m * (vN - v0) = g.eval N - g.eval 0 := by rw [mul_sub, hvN, hv0]
    rw [this]
    exact hrN.trans (eval_sub_eval_zero_dvd g N)
  have hsub : (r : ℤ) ∣ vN - v0 := (hprime.dvd_mul.mp hdiff).resolve_left hrm
  constructor
  · intro h
    have := dvd_sub h hsub
    simpa using this
  · intro h
    have := dvd_add h hsub
    simpa using this

/-! ### Quantitative form: a fixed invariant reveals at most `log₂ |f(0)|` primes -/

/-- A fixed polynomial invariant can expose at most `log₂ |f(0)|` distinct primes in
its entire lifetime, no matter how many moduli it is fed. -/
theorem card_revealedPrimes_le_log (f : ℤ[X]) (hf : f.eval 0 ≠ 0) :
    (revealedPrimes f).card ≤ Nat.log 2 (f.eval 0).natAbs := by
  set n := (f.eval 0).natAbs with hn
  have hn0 : n ≠ 0 := by simpa [hn, Int.natAbs_eq_zero] using hf
  have hprod : ∏ p ∈ n.primeFactors, p ∣ n := Nat.prod_primeFactors_dvd n
  have hle : ∏ p ∈ n.primeFactors, p ≤ n := Nat.le_of_dvd (Nat.pos_of_ne_zero hn0) hprod
  have hpow : 2 ^ n.primeFactors.card ≤ ∏ p ∈ n.primeFactors, p := by
    refine Finset.pow_card_le_prod _ _ 2 ?_
    intro p hp
    exact (Nat.mem_primeFactors.mp hp).1.two_le
  have : 2 ^ n.primeFactors.card ≤ n := le_trans hpow hle
  exact (Nat.le_log_iff_pow_le (by norm_num) hn0).mpr this

/-! ### The impossibility theorem -/

/-- **Sharp form of Barrier I.**  If a polynomial invariant splits the semiprime
`N = p q`, then the *smaller* prime factor is at most `|f(0)|`.  Equivalently: an
invariant with constant term of `b` bits can only ever split moduli having a prime
factor of at most `b` bits — it is useless exactly in the balanced, cryptographic
regime. -/
theorem splits_imp_small_prime_factor {f : ℤ[X]} {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hsplit : Splits f (p * q)) : min p q ≤ (f.eval 0).natAbs := by
  obtain ⟨hlow, hhigh⟩ := hsplit
  set w := polyWitness f (p * q) with hw
  have hwc : w = Int.gcd (f.eval 0) ((p * q : ℕ) : ℤ) := polyWitness_eq_gcd_const f (p * q)
  by_cases hzero : f.eval 0 = 0
  · -- the witness is the whole modulus, so nothing was split
    rw [hzero] at hwc
    simp [Int.gcd] at hwc
    omega
  · have hw1 : w ≠ 1 := by omega
    obtain ⟨r, hr, hrw⟩ := Nat.exists_prime_and_dvd hw1
    have hdvdN : (w : ℤ) ∣ ((p * q : ℕ) : ℤ) := by rw [hwc]; exact Int.gcd_dvd_right _ _
    have hdvdC : (w : ℤ) ∣ f.eval 0 := by rw [hwc]; exact Int.gcd_dvd_left _ _
    have hrN : r ∣ p * q := by
      have h1 : (r : ℤ) ∣ ((p * q : ℕ) : ℤ) :=
        dvd_trans (Int.natCast_dvd_natCast.mpr hrw) hdvdN
      exact_mod_cast h1
    have hrC : r ∣ (f.eval 0).natAbs := by
      have h0 : (r : ℤ) ∣ f.eval 0 := dvd_trans (Int.natCast_dvd_natCast.mpr hrw) hdvdC
      simpa using Int.natAbs_dvd_natAbs.mpr h0
    have hCne : (f.eval 0).natAbs ≠ 0 := by simpa [Int.natAbs_eq_zero] using hzero
    have hrle : r ≤ (f.eval 0).natAbs := Nat.le_of_dvd (Nat.pos_of_ne_zero hCne) hrC
    rcases (Nat.Prime.dvd_mul hr).mp hrN with h1 | h1
    · have : r = p := (Nat.prime_dvd_prime_iff_eq hr hp).mp h1
      have : min p q ≤ p := Nat.min_le_left p q
      omega
    · have : r = q := (Nat.prime_dvd_prime_iff_eq hr hq).mp h1
      have : min p q ≤ q := Nat.min_le_right p q
      omega

/-- **No finite family of polynomial invariants is a universal factoring witness.**

Given any finite family `F : ι → ℤ[X]` indexed by a finite type, there is a semiprime
`N = p q` (with `p`, `q` distinct primes) on which *every* member of the family fails
to produce a nontrivial factor.  The failing modulus can be taken with both primes
larger than the constant terms of the family, which is precisely the
cryptographically relevant regime. -/
theorem no_universal_family_witness {ι : Type*} [Fintype ι] (F : ι → ℤ[X]) :
    ¬ ∀ N : ℕ, IsDistinctSemiprime N → ∃ i, Splits (F i) N := by
  intro h
  classical
  set B : ℕ := Finset.univ.sup (fun i : ι => ((F i).eval 0).natAbs) with hB
  obtain ⟨p, hpB, hp⟩ := Nat.exists_infinite_primes (B + 2)
  obtain ⟨q, hqp, hq⟩ := Nat.exists_infinite_primes (p + 1)
  have hpq : p ≠ q := by omega
  obtain ⟨i, hsplit⟩ := h (p * q) ⟨p, q, hp, hq, hpq, rfl⟩
  have hmin := splits_imp_small_prime_factor hp hq hsplit
  have hbnd : ((F i).eval 0).natAbs ≤ B :=
    Finset.le_sup (f := fun j : ι => ((F j).eval 0).natAbs) (Finset.mem_univ i)
  have : min p q = p := Nat.min_eq_left (by omega)
  omega

/-- **No single polynomial invariant is a universal factoring witness.** -/
theorem no_universal_polynomial_witness (f : ℤ[X]) :
    ¬ ∀ N : ℕ, IsDistinctSemiprime N → Splits f N := by
  intro h
  refine no_universal_family_witness (fun _ : Fin 1 => f) ?_
  intro N hN
  exact ⟨0, h N hN⟩

/-- **No residue-adaptive polynomial witness.**  Even an adversary allowed to *choose*
the polynomial invariant as a function of the residue class of `N` modulo a fixed
modulus `M` — a lookup table of infinitely many moduli but finitely many polynomials —
still fails on some semiprime.  Adaptivity of bounded granularity buys nothing. -/
theorem no_residue_adaptive_witness (M : ℕ) [NeZero M] (F : ZMod M → ℤ[X]) :
    ¬ ∀ N : ℕ, IsDistinctSemiprime N → Splits (F ((N : ZMod M))) N := by
  intro h
  refine no_universal_family_witness F ?_
  intro N hN
  exact ⟨(N : ZMod M), h N hN⟩

end FactoringBarriers