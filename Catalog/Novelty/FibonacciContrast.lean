import Catalog.Novelty.AntiFibonacci.Basic
import Catalog.Novelty.RiordanRowSumFibonacci

/-!
# Anti-Fibonacci vs. Fibonacci — Exponential Domination

This file makes the "counterpoint" precise by *comparing* the anti-Fibonacci sequence
with a genuine Fibonacci object taken from the catalog.

We reuse `Catalog.Novelty.RiordanRowSumFibonacci`, whose main theorem
`pascalRiordanA_eq_fib` proves the Riordan row-sum identity
`∑_{k=0}^{n} C(n+k, 2k) = fib (2n+1)`.  Thus `pascalRiordanA n` is exactly the
odd-indexed Fibonacci number `fib (2n+1)`, which grows *exponentially*.

We prove that from index `6` on, the (quadratic) anti-Fibonacci sequence is dominated by
this (exponential) Fibonacci row-sum, quantifying the slogan "the anti-Fibonacci
sequence grows far more slowly than anything driven by addition".

## Main results

* `antiFib_lt_fib` — `antiFib n < fib (2n+1)` for all `n ≥ 6` (by induction, using the
  Fibonacci lower bound `Nat.le_fib_self`).
* `antiFib_lt_fibRowSum` — the same inequality phrased via the **catalog** object:
  `antiFib n < RiordanRowSumFibonacci.pascalRiordanA n` for `n ≥ 6`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the brief frames anti-Fibonacci as "a beautiful counterpoint
to Fibonacci".  A falsifiable sharpening: anti-Fibonacci is eventually dominated by an
honest Fibonacci sequence (exponential beats quadratic).

Experiment (Experimenter): `antiFib 6 = 16`, `fib 13 = 233`; `antiFib 10 = 46`,
`fib 21 = 10946`.  Domination looks overwhelming and starts early.

Analysis (Analyst): `antiFib` increases by `+n` per step (arithmetic increments) while
`fib (2n+1)` multiplies by roughly `φ²` per step.  The clean induction is: assuming
`antiFib n < fib(2n+1)`, we get `antiFib (n+1) = antiFib n + n < fib(2n+1) + n`, and
`fib(2n+3) = fib(2n+2) + fib(2n+1) ≥ n + fib(2n+1)` because `n ≤ 2n+2 ≤ fib(2n+2)`
(via `Nat.le_fib_self`, valid once `2n+2 ≥ 5`).  Base case `n = 6` by `decide`.

Critique (Critic): to *use the catalog* rather than merely restate `Nat.fib`, we phrase
the final inequality against `RiordanRowSumFibonacci.pascalRiordanA n` and discharge it by
rewriting with the catalog's `pascalRiordanA_eq_fib`.  This makes the dependency real.

Synthesis: exponential Fibonacci growth provably dominates quadratic anti-Fibonacci
growth from index `6`, cementing the "counterpoint" as a theorem.
-- !-- Lab Notes -- !--
-/

namespace AntiFibonacci

/-- The anti-Fibonacci sequence is dominated by the odd-indexed Fibonacci numbers:
`antiFib n < fib (2n+1)` for every `n ≥ 6`.  Proof by induction; the inductive step uses
the Fibonacci lower bound `Nat.le_fib_self` to absorb the arithmetic increment `+n`. -/
theorem antiFib_lt_fib (n : ℕ) (hn : 6 ≤ n) : antiFib n < Nat.fib (2 * n + 1) := by
  induction n with
  | zero => omega
  | succ k ih =>
      rcases Nat.lt_or_ge k 6 with hk | hk
      · have hk5 : k = 5 := by omega
        subst hk5; decide
      · have hstep := ih hk
        have hkfib : k ≤ Nat.fib (2 * k + 2) := by
          have h5 : (5 : ℕ) ≤ 2 * k + 2 := by omega
          have := Nat.le_fib_self h5
          omega
        have hrec : Nat.fib (2 * (k + 1) + 1)
            = Nat.fib (2 * k + 2) + Nat.fib (2 * k + 1) := by
          have h : 2 * (k + 1) + 1 = (2 * k + 1) + 2 := by ring
          rw [h, Nat.fib_add_two]
          ring_nf
        rw [antiFib_succ, hrec]
        omega

/-- **Exponential domination, catalog form.** From index `6` on, the anti-Fibonacci
sequence is strictly below the Riordan Fibonacci row-sum `pascalRiordanA n = fib (2n+1)`
from `Catalog.Novelty.RiordanRowSumFibonacci`.  Quadratic growth is eventually dwarfed by
the exponential, addition-driven Fibonacci growth. -/
theorem antiFib_lt_fibRowSum (n : ℕ) (hn : 6 ≤ n) :
    antiFib n < RiordanRowSumFibonacci.pascalRiordanA n := by
  have hcat : RiordanRowSumFibonacci.pascalRiordanA n = Nat.fib (2 * n + 1) :=
    RiordanRowSumFibonacci.pascalRiordanA_eq_fib n
  rw [hcat]
  exact antiFib_lt_fib n hn

end AntiFibonacci