import Catalog.Novelty.AntiFibonacciSumSpectrum
import Catalog.Novelty.RiordanRowSumFibonacci

/-!
# Anti-Fibonacci research synthesis: square sums and corrected growth

The data `1, 1, 2, 4, 7, 11, 16, …` determine the lazy-caterer recurrence
`A (n+1) = A n + n`, not the literal greedy rule stated in the research prompt.  This
file develops two consequences of that correction.  First, consecutive sums have the
unexpectedly simple square spectrum

`A n + A (n+1) = n² + 2`.

Second, the proposed approximation `A n = ⌊n²/4⌋ + O(1)` fails by an unbounded amount:
for every constant `C`, some `n` satisfies `A n > n²/4 + C`.  The exact leading
constant is `1/2`, as established in the imported asymptotic development.

The import of `RiordanRowSumFibonacci` also connects this polynomial sequence to the
catalog's genuine Fibonacci row-sum object; the final theorem records their eventual
strict separation.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): seven falsifiable targets were considered.  (H1) the listed
terms obey a first-difference law; (H2) consecutive sums are a shifted square; (H3) the
claimed quarter-square error is bounded; (H4) the value set has a quadratic Diophantine
spectrum; (H5) gaps diverge linearly; (H6) a genuine Fibonacci row-sum eventually
strictly dominates; (H7) intersections between the value spectrum and shifted squares
are controlled by a Pell-type equation.  H4 and H7 bridge combinatorics with Diophantine
arithmetic; H6 bridges polynomial enumeration with Fibonacci identities.

Experiment (Experimenter): the first consecutive sums are `2, 3, 6, 11, 18, 27, 38`,
exactly `n²+2`.  At `n = 10^6`, the closed form gives
`A n = 499999500001` and `A n / n² = 0.499999500001`, contradicting convergence to
`1/4`.  The quarter-square discrepancy grows quadratically.

Analysis (Analyst): adding the two identities
`2A n+n=n²+2` and `2A(n+1)+(n+1)=(n+1)²+2` cancels the linear terms and yields H2.
The same closed form, evaluated beyond any proposed constant, refutes H3 uniformly.
The recurrence makes H5 exact.  H4 is supplied by the imported square-spectrum theorem,
while H6 follows from the catalog's Riordan/Fibonacci identity and exponential domination.

Critique (Critic): the literal phrase “smallest positive integer not equal to the previous
sum” does not generate the displayed data, so no theorem here pretends otherwise.  The
sequence studied is explicitly the one forced by the displayed terms.  H7 was not promoted
to a theorem: reducing it to a Pell-type equation is sound, but a complete classification
was not established.  The density-zero claim concerns the values of this quadratic
sequence; it must not be confused with the separate genuinely greedy construction.

Synthesis: the displayed sequence has exact quadratic structure, shifted-square
consecutive sums, linearly widening gaps, and an unbounded discrepancy from every
quarter-square approximation.  Its polynomial growth is eventually dominated by the
catalog's odd-index Fibonacci row sums.
-- !-- Lab Notes -- !--
-/

namespace AntiFibonacciResearch

open AntiFibonacci

/-- Consecutive terms of the displayed anti-Fibonacci sequence sum to a shifted square. -/
theorem consecutive_sum_eq_square_add_two (n : ℕ) :
    antiFib n + antiFib (n + 1) = n ^ 2 + 2 := by
  have hn := antiFib_closed n
  have hs := antiFib_closed (n + 1)
  nlinarith

/-- The shifted-square description is exact as a spectrum: an integer is a consecutive
sum precisely when it is two more than a square. -/
theorem consecutive_sum_spectrum (m : ℕ) :
    (∃ n, antiFib n + antiFib (n + 1) = m) ↔ ∃ n, n ^ 2 + 2 = m := by
  constructor
  · rintro ⟨n, rfl⟩
    exact ⟨n, (consecutive_sum_eq_square_add_two n).symm⟩
  · rintro ⟨n, rfl⟩
    exact ⟨n, consecutive_sum_eq_square_add_two n⟩

/-- The gaps are exactly linear, hence become larger than any prescribed bound. -/
theorem arbitrarily_large_gaps (C : ℕ) :
    ∃ n, C < antiFib (n + 1) - antiFib n := by
  refine ⟨C + 1, ?_⟩
  rw [antiFib_succ]
  have hp := antiFib_pos (C + 1)
  omega

/-- There is no bounded-error approximation with leading term `n²/4`: for every
constant `C`, some term exceeds `n²/4 + C` after clearing the denominator by four. -/
theorem quarter_square_error_unbounded (C : ℕ) :
    ∃ n, n ^ 2 + 4 * C < 4 * antiFib n := by
  refine ⟨4 * C + 4, ?_⟩
  have h := antiFib_closed (4 * C + 4)
  nlinarith

/-- A concrete large-index check derived from the exact closed form. -/
theorem antiFib_million : antiFib 1000000 = 499999500001 := by
  have h := antiFib_closed 1000000
  omega

/-- The quadratic sequence lies below the odd-index Fibonacci sequence from index six. -/
lemma antiFib_lt_odd_fib (n : ℕ) (hn : 6 ≤ n) :
    antiFib n < Nat.fib (2 * n + 1) := by
  induction n with
  | zero => omega
  | succ k ih =>
      rcases Nat.lt_or_ge k 6 with hk | hk
      · have : k = 5 := by omega
        subst k
        decide
      · have hstep := ih hk
        have hkfib : k ≤ Nat.fib (2 * k + 2) := by
          have h5 : 5 ≤ 2 * k + 2 := by omega
          have h := Nat.le_fib_self h5
          omega
        have hrec : Nat.fib (2 * (k + 1) + 1) =
            Nat.fib (2 * k + 2) + Nat.fib (2 * k + 1) := by
          rw [show 2 * (k + 1) + 1 = (2 * k + 1) + 2 by ring, Nat.fib_add_two]
          ring_nf
        rw [antiFib_succ, hrec]
        omega

/-- Cross-domain comparison with the Riordan row-sum realization of odd-indexed
Fibonacci numbers: exponential Fibonacci growth dominates this quadratic sequence. -/
theorem eventually_below_riordan_fibonacci (n : ℕ) (hn : 6 ≤ n) :
    antiFib n < RiordanRowSumFibonacci.pascalRiordanA n := by
  have hcat : RiordanRowSumFibonacci.pascalRiordanA n = Nat.fib (2 * n + 1) :=
    RiordanRowSumFibonacci.pascalRiordanA_eq_fib n
  rw [hcat]
  exact antiFib_lt_odd_fib n hn

end AntiFibonacciResearch