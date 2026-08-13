/-
# Cycle 3: an unconditional query lower bound for gcd-based factoring

`Logic.ThreeSumBirthdayHierarchy` shows that every *collision* method in the
hierarchy pays `> p` enumerated tuples.  That bound is about one particular
mechanism (the pigeonhole).  Here we prove a bound about the **only interface**
all of these methods use, namely the gcd:

> A "gcd-query algorithm" produces a finite multiset of integers `Q` and hopes
> that some `gcd x N` is a nontrivial factor of `N`.  3SUM sums `a+b+c`, sumset
> differences, Pollard `p-1` values `aᵏ - 1` and singular-moduli differences are
> all of this shape.

**Theorem (`gcd_query_lower_bound`).**  If such a `Q` succeeds on *every*
semiprime `p*q` with `p ≠ q` taken from a set `P` of primes, then
`P.card ≤ Q.card * Nat.log 2 M + 1`, where `M` bounds the queries.  Equivalently
`|Q| ≥ (|P| - 1) / log₂ M`: the number of gcd queries is at least linear in the
number of candidate primes, no matter how cleverly the queries are chosen.

Since the primes available for a balanced semiprime `N` number about
`√N / log √N`, this reproduces — unconditionally and without any pigeonhole
hypothesis — the `√N` wall of the hierarchy table.

The proof is an adversary argument: the prime factors of all queries form a set
`U` of size `≤ |Q| log₂ M`; if `|P| > |U| + 1` two primes of `P` avoid every
query, and for that semiprime every gcd query returns `1`.
-/

import Mathlib
import Logic.ThreeSumBirthdayHierarchy

namespace ThreeSumBirthday

open Finset

/-! ## Counting the prime factors touched by a query set -/

/-- A number has at most `log₂ x` distinct prime factors. -/
theorem card_primeFactors_le_log (x : ℕ) (hx : x ≠ 0) :
    x.primeFactors.card ≤ Nat.log 2 x := by
  have h2 : 2 ^ x.primeFactors.card ≤ x := by
    calc 2 ^ x.primeFactors.card = ∏ _p ∈ x.primeFactors, 2 := by simp [Finset.prod_const]
      _ ≤ ∏ p ∈ x.primeFactors, p :=
          Finset.prod_le_prod' (fun p hp => (Nat.prime_of_mem_primeFactors hp).two_le)
      _ ≤ x := Nat.le_of_dvd (Nat.pos_of_ne_zero hx) (Nat.prod_primeFactors_dvd x)
  exact (Nat.le_log_iff_pow_le (by norm_num) hx).2 h2

/-- The set of primes that any query in `Q` can possibly reveal. -/
def touched (Q : Finset ℕ) : Finset ℕ := Q.biUnion Nat.primeFactors

/-- A query set of `m` numbers, all at most `M`, touches at most `m log₂ M`
primes. -/
theorem card_touched_le (Q : Finset ℕ) (M : ℕ) (hQ : ∀ x ∈ Q, x ≤ M) : (touched Q).card ≤ Q.card * Nat.log 2 M := by
  refine le_trans (Finset.card_biUnion_le) ?_
  calc ∑ x ∈ Q, x.primeFactors.card ≤ ∑ _x ∈ Q, Nat.log 2 M := by
        refine Finset.sum_le_sum (fun x hx => ?_)
        rcases eq_or_ne x 0 with rfl | hx0
        · simp
        · exact le_trans (card_primeFactors_le_log x hx0)
            (Nat.log_mono_right (hQ x hx))
    _ = Q.card * Nat.log 2 M := by simp [Finset.sum_const]

/-- If a prime does not occur among the prime factors of any query, it divides
no query. -/
theorem not_dvd_of_not_touched {Q : Finset ℕ} {p : ℕ} (hp : p.Prime)
    (hpU : p ∉ touched Q) : ∀ x ∈ Q, x ≠ 0 → ¬ p ∣ x := by
  intro x hx hx0 hdvd
  exact hpU (Finset.mem_biUnion.2 ⟨x, hx, Nat.mem_primeFactors.2 ⟨hp, hdvd, hx0⟩⟩)

/-! ## The adversary: two untouched primes hide the factorisation -/

/-- Every gcd query of `Q` is trivial for the semiprime `p*q` built from two
untouched primes. -/
theorem gcd_eq_one_of_untouched {Q : Finset ℕ} {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hpU : p ∉ touched Q) (hqU : q ∉ touched Q) :
    ∀ x ∈ Q, x ≠ 0 → Nat.gcd x (p * q) = 1 := by
  intro x hx hx0
  have h1 : ¬ p ∣ x := not_dvd_of_not_touched hp hpU x hx hx0
  have h2 : ¬ q ∣ x := not_dvd_of_not_touched hq hqU x hx hx0
  rw [gcd_semiprime_classification hp hq hpq, if_neg h1, if_neg h2]

/-- If `P` contains more than `|touched Q| + 1` primes, two distinct primes of
`P` are untouched by `Q`. -/
theorem exists_two_untouched_primes {Q P : Finset ℕ}
    (h : (touched Q).card + 1 < P.card) :
    ∃ p ∈ P, ∃ q ∈ P, p ≠ q ∧ p ∉ touched Q ∧ q ∉ touched Q := by
  have hcard : 1 < (P \ touched Q).card := by
    have := Finset.le_card_sdiff (touched Q) P
    omega
  obtain ⟨p, hp, q, hq, hpq⟩ := Finset.one_lt_card.1 hcard
  rw [Finset.mem_sdiff] at hp hq
  exact ⟨p, hp.1, q, hq.1, hpq, hp.2, hq.2⟩

/-! ## The lower bound -/

/-- **Unconditional gcd-query lower bound.**  Suppose a query set `Q` of nonzero
numbers, all bounded by `M`, *solves* every semiprime built from two distinct
primes of `P`, in the sense that some query has a nontrivial gcd with it.
Then `|P| ≤ |Q| · log₂ M + 1`.

Contrapositively, to cover `n` candidate primes one needs at least
`(n - 1) / log₂ M` gcd queries: no choice of algebraic structure for the queries
(3SUM sums, sumset differences, `aᵏ - 1`, singular moduli, …) can beat this. -/
theorem gcd_query_lower_bound {Q P : Finset ℕ} {M : ℕ}
    (hQ0 : ∀ x ∈ Q, x ≠ 0) (hQM : ∀ x ∈ Q, x ≤ M)
    (hP : ∀ p ∈ P, p.Prime)
    (hsolve : ∀ p ∈ P, ∀ q ∈ P, p ≠ q → ∃ x ∈ Q, Nat.gcd x (p * q) ≠ 1) :
    P.card ≤ Q.card * Nat.log 2 M + 1 := by
  by_contra hcon
  push_neg at hcon
  have hstep : (touched Q).card + 1 < P.card :=
    lt_of_le_of_lt (by have := card_touched_le Q M hQM; omega) hcon
  obtain ⟨p, hpP, q, hqP, hpq, hpU, hqU⟩ := exists_two_untouched_primes hstep
  obtain ⟨x, hx, hgcd⟩ := hsolve p hpP q hqP hpq
  exact hgcd (gcd_eq_one_of_untouched (hP p hpP) (hP q hqP) hpq hpU hqU x hx (hQ0 x hx))

/-- The same bound as an explicit query-count lower bound. -/
theorem query_count_lower_bound {Q P : Finset ℕ} {M : ℕ}
    (hQ0 : ∀ x ∈ Q, x ≠ 0) (hQM : ∀ x ∈ Q, x ≤ M)
    (hP : ∀ p ∈ P, p.Prime)
    (hsolve : ∀ p ∈ P, ∀ q ∈ P, p ≠ q → ∃ x ∈ Q, Nat.gcd x (p * q) ≠ 1) :
    (P.card - 1) / Nat.log 2 M ≤ Q.card := by
  have h := gcd_query_lower_bound hQ0 hQM hP hsolve
  have h' : P.card - 1 ≤ Nat.log 2 M * Q.card := by rw [Nat.mul_comm]; omega
  exact Nat.div_le_of_le_mul h'

/-- **Cost comparison with the birthday hierarchy.**  A single revealing query
`x` (`p ∣ x`, `q ∤ x`) does solve the instance — so the lower bound above is not
vacuous: it says the *hard part* is finding such an `x`, not testing it. -/
theorem revealing_query_solves {p q x : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h1 : p ∣ x) (h2 : ¬ q ∣ x) : Nat.gcd x (p * q) ≠ 1 := by
  rw [gcd_eq_left_of_dvd_of_not_dvd hp hq h1 h2]
  exact hp.one_lt.ne'

/-- Instantiation: with all queries below `2^64` a gcd-query algorithm that
covers a set of `n` candidate primes needs at least `(n-1)/64` queries. -/
theorem gcd_query_lower_bound_64 {Q P : Finset ℕ}
    (hQ0 : ∀ x ∈ Q, x ≠ 0) (hQM : ∀ x ∈ Q, x ≤ 2 ^ 64)
    (hP : ∀ p ∈ P, p.Prime)
    (hsolve : ∀ p ∈ P, ∀ q ∈ P, p ≠ q → ∃ x ∈ Q, Nat.gcd x (p * q) ≠ 1) :
    (P.card - 1) / 64 ≤ Q.card := by
  have hlog : Nat.log 2 (2 ^ 64) = 64 := Nat.log_pow (by norm_num) 64
  have h := query_count_lower_bound (M := 2 ^ 64) hQ0 hQM hP hsolve
  rwa [hlog] at h

end ThreeSumBirthday