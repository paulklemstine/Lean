import Mathlib

/-!
# Prime gap transitions

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/PrimeGapTransitions.lean`.  It is reconstructed here as a
self-contained development of *transitions* between consecutive primes, i.e. the
gaps `q - p` for `p < q` consecutive primes.

Main results:

* `PrimeGap.exists_consecutive_composites` — for every `n` there is a block of `n`
  consecutive composite numbers (the factorial construction);
* `PrimeGap.nextPrime` and `PrimeGap.prevPrime` — the successor and predecessor
  primes of a given bound, together with the fact that nothing prime lies strictly
  in between (`PrimeGap.no_prime_between`);
* `PrimeGap.exists_large_gap` — **prime gaps are unbounded**: for every `n` there
  are consecutive primes `p < q` with `n ≤ q - p`.
-/

namespace PrimeGap

open Nat

/-! ## A block of consecutive composites -/

/-- For every `n` there are `n` consecutive composite numbers, starting at
`(n+1)! + 2`.  Indeed `(k+2) ∣ (n+1)!` for `k < n`, so `(k+2) ∣ (n+1)! + 2 + k`. -/
theorem exists_consecutive_composites (n : ℕ) :
    ∃ m, 3 ≤ m ∧ ∀ k < n, ¬ Nat.Prime (m + k) := by
  have hfac : 1 ≤ (n + 1)! := Nat.one_le_iff_ne_zero.mpr (Nat.factorial_ne_zero _)
  refine ⟨(n + 1)! + 2, by omega, ?_⟩
  intro k hk hp
  have hdvd1 : (k + 2) ∣ (n + 1)! := Nat.dvd_factorial (by omega) (by omega)
  have hdvd : (k + 2) ∣ ((n + 1)! + 2 + k) := by
    have : (n + 1)! + 2 + k = (n + 1)! + (k + 2) := by omega
    rw [this]
    exact Nat.dvd_add hdvd1 dvd_rfl
  have hne1 : k + 2 ≠ 1 := by omega
  have hne : k + 2 ≠ (n + 1)! + 2 + k := by omega
  exact hne ((Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd).resolve_left hne1)

/-! ## Consecutive primes -/

/-- The least prime `≥ N`. -/
noncomputable def nextPrime (N : ℕ) : ℕ := sInf {p | N ≤ p ∧ p.Prime}

lemma nextPrime_spec (N : ℕ) : N ≤ nextPrime N ∧ (nextPrime N).Prime := by
  have : {p | N ≤ p ∧ p.Prime}.Nonempty := by
    obtain ⟨p, hp, hpp⟩ := Nat.exists_infinite_primes N
    exact ⟨p, hp, hpp⟩
  exact Nat.sInf_mem this

lemma nextPrime_prime (N : ℕ) : (nextPrime N).Prime := (nextPrime_spec N).2

lemma le_nextPrime (N : ℕ) : N ≤ nextPrime N := (nextPrime_spec N).1

lemma nextPrime_min {N p : ℕ} (hN : N ≤ p) (hp : p.Prime) : nextPrime N ≤ p :=
  Nat.sInf_le ⟨hN, hp⟩

/-- Nothing prime lies in `[N, nextPrime N)`. -/
lemma no_prime_below_nextPrime {N q : ℕ} (h1 : N ≤ q) (h2 : q < nextPrime N) : ¬ q.Prime :=
  fun hq => absurd (nextPrime_min h1 hq) (by omega)

/-- The greatest prime `< N`, for `N ≥ 3`. -/
noncomputable def prevPrime (N : ℕ) : ℕ :=
  sSup {p | p < N ∧ p.Prime}

lemma prevPrime_spec {N : ℕ} (hN : 3 ≤ N) : prevPrime N < N ∧ (prevPrime N).Prime := by
  have hne : {p | p < N ∧ p.Prime}.Nonempty := ⟨2, by omega, Nat.prime_two⟩
  have hbdd : BddAbove {p | p < N ∧ p.Prime} := ⟨N, fun p hp => le_of_lt hp.1⟩
  exact Nat.sSup_mem hne hbdd

lemma prevPrime_max {N p : ℕ} (hp : p < N) (hpp : p.Prime) : p ≤ prevPrime N := by
  have hbdd : BddAbove {p | p < N ∧ p.Prime} := ⟨N, fun p hp => le_of_lt hp.1⟩
  exact le_csSup hbdd ⟨hp, hpp⟩

/-- Between `prevPrime N` and `N` there is no prime. -/
lemma no_prime_between {N q : ℕ} (h1 : prevPrime N < q) (h2 : q < N) : ¬ q.Prime :=
  fun hq => absurd (prevPrime_max h2 hq) (by omega)

/-! ## Unbounded gaps -/

/-- **Prime gaps are unbounded.**  For every `n` there are two primes `p < q` with
`n ≤ q - p` and no prime strictly in between: a "prime gap transition" of size at
least `n`. -/
theorem exists_large_gap (n : ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p < q ∧ n ≤ q - p ∧ ∀ r, p < r → r < q → ¬ r.Prime := by
  obtain ⟨m, hm2, hcomp⟩ := exists_consecutive_composites n
  -- every element of `[m, m + n)` is composite, so the next prime is at least `m + n`
  set q := nextPrime m with hq
  have hqp : q.Prime := nextPrime_prime m
  have hmq : m ≤ q := le_nextPrime m
  have hqbig : m + n ≤ q := by
    by_contra hcon
    push_neg at hcon
    obtain ⟨k, hk⟩ : ∃ k, q = m + k := ⟨q - m, by omega⟩
    exact hcomp k (by omega) (hk ▸ hqp)
  have hq3 : 3 ≤ q := le_trans hm2 hmq
  set p := prevPrime q with hp
  obtain ⟨hpq, hpp⟩ := prevPrime_spec hq3
  refine ⟨p, q, hpp, hqp, hpq, ?_, fun r hr1 hr2 => no_prime_between hr1 hr2⟩
  -- `p < m`, since everything in `[m, q)` is composite
  have hpm : p < m := by
    by_contra hcon
    push_neg at hcon
    exact no_prime_below_nextPrime hcon (hq ▸ hpq) hpp
  omega

end PrimeGap