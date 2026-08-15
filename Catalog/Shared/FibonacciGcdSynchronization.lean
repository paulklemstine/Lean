import Mathlib
import Shared.NumberTheory.CarmichaelHelpers
import Applications.ProofAutomation.FibonacciTactics
import Shared.CarmichaelHelper

/-!
# Finite gcd synchronization for Fibonacci apparition

This chapter connects three structures that are usually treated separately:
the strong-divisibility law of the Fibonacci sequence, gcd aggregation over a
finite family, and primitive prime divisors at prime indices.  The resulting
synchronization theorem says that, for every prime index `q ≥ 13`, one can find
a prime `p` whose divisibility pattern across *every finite family* of Fibonacci
numbers is governed exactly by divisibility of the gcd of the indices by `q`.

The selected target is a **cross-domain bridge**: arithmetic of recurrence
sequences is transported through the semilattice operation on finite index sets.
It also advances the Carmichael primitive-divisor program by upgrading existence
at one index to a global description of all later appearances of the divisor.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Seven testable possibilities were ranked by
  structural reach: (1) finite gcd transport for every strong divisibility
  sequence; (2) exact apparition at prime Fibonacci indices; (3) finite-family
  synchronization by a single primitive prime; (4) an analogous lcm law for
  ranks of apparition; (5) extension to Lucas sequences; (6) a cyclotomic
  description at arbitrary composite indices; (7) an elliptic-divisibility
  analogue.  Items (4)--(7) are the bold program; (1)--(3) form a rigorous
  bridge supporting it.
* **Experiment (Experimenter).** Small families, including the empty family and
  families containing index zero, exposed no exception: both gcd conventions
  return zero there.  Induction over insertion transports the binary Fibonacci
  gcd identity to arbitrary finite families.  A primitive divisor at prime
  index `q` was then tested against `gcd q m`; primality forces this gcd to be
  either `1` or `q`.
* **Analysis (Analyst).** All three selected claims survive.  The decisive
  pattern is that a binary strong-divisibility identity automatically preserves
  finite meets.  Primitive divisibility at a prime index then determines the
  complete infinite divisibility locus, not merely the first occurrence.
* **Critique (Critic).** The lower bound `13 ≤ q` enters only through the
  primitive-divisor existence theorem; primality is essential to the two-case
  collapse of divisors of `q`.  Empty finite sets are not hidden exceptions.
  The proofs use induction, contradiction, and gcd divisibility rather than a
  finite decision procedure.
* **Synthesis (Principal Investigator).** The final theorem packages the result
  as a uniform statement over all finite index families, making the recurrence
  arithmetic usable as a finite-meet invariant.
-/

open Catalog.ProofAutomation.Fibonacci

/-- Finite gcds commute with the Fibonacci map.  Thus the binary strong
Divisibility identity extends to every finite family of indices. -/
theorem finset_gcd_fib (s : Finset ℕ) :
    s.gcd Nat.fib = Nat.fib (s.gcd id) := by
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
      rw [Finset.gcd_insert, Finset.gcd_insert, ih]
      exact Fib_gcd_identity a (s.gcd id)

/-- A number divides all Fibonacci values in a finite family exactly when it
Divides the Fibonacci value at the gcd of that family. -/
theorem dvd_fib_finset_gcd_iff (p : ℕ) (s : Finset ℕ) :
    p ∣ Nat.fib (s.gcd id) ↔ ∀ n ∈ s, p ∣ Nat.fib n := by
  rw [← finset_gcd_fib s]
  exact Finset.dvd_gcd_iff

/-- At a sufficiently large prime index, Carmichael primitivity upgrades to an
exact global apparition law: one prime divisor appears precisely at multiples
of that index. -/
theorem prime_index_exact_fib_apparition (q : ℕ) (hq : Nat.Prime q)
    (hq13 : 13 ≤ q) :
    ∃ p, Nat.Prime p ∧ ∀ m, p ∣ Nat.fib m ↔ q ∣ m := by
  rcases fib_primitive_divisor_prime q hq13 hq with ⟨p, hp, hpq, hprimitive⟩
  refine ⟨p, hp, fun m => ?_⟩
  constructor
  · intro hpm
    by_contra hnot
    have hgcd_dvd : p ∣ Nat.fib (Nat.gcd q m) := by
      rw [← Fib_gcd_identity]
      exact Nat.dvd_gcd hpq hpm
    rcases hq.eq_one_or_self_of_dvd (Nat.gcd q m) (Nat.gcd_dvd_left q m) with hgcd | hgcd
    · rw [hgcd, Nat.fib_one] at hgcd_dvd
      exact hp.not_dvd_one hgcd_dvd
    · exact hnot (hgcd ▸ Nat.gcd_dvd_right q m)
  · intro hqm
    exact dvd_trans hpq (Nat.fib_dvd q m hqm)

/-- **Finite synchronization theorem.** For a prime Fibonacci index `q ≥ 13`,
there is a prime `p` such that, simultaneously for every finite set of indices,
`p` divides the gcd of the corresponding Fibonacci numbers exactly when `q`
divides the gcd of the indices. -/
theorem fibonacci_prime_finset_synchronization (q : ℕ) (hq : Nat.Prime q)
    (hq13 : 13 ≤ q) :
    ∃ p, Nat.Prime p ∧ ∀ s : Finset ℕ,
      p ∣ s.gcd Nat.fib ↔ q ∣ s.gcd id := by
  rcases prime_index_exact_fib_apparition q hq hq13 with ⟨p, hp, happ⟩
  refine ⟨p, hp, fun s => ?_⟩
  rw [Finset.dvd_gcd_iff, Finset.dvd_gcd_iff]
  constructor
  · intro hall n hn
    exact (happ n).mp (hall n hn)
  · intro hall n hn
    exact (happ n).mpr (hall n hn)