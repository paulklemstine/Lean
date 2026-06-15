# Future Directions — Zeckendorf / additive Fibonacci structure

This cycle formalized **Zeckendorf's theorem** from scratch against Mathlib
(`Core.lean`, `Existence.lean`, `Uniqueness.lean`): every `n : ℕ` has a unique
representation as a sum of non-consecutive Fibonacci numbers, encoded as a
strictly-decreasing index list `l` with gaps `≥ 2` and indices `≥ 2`
(`Zeckendorf.zeckendorf : ∃! l, IsZeck l ∧ value l = n`). The entire theorem turns
on one two-sided estimate, the half-open interval `[F a, F (a+1))` for the value of a
valid list with largest index `a` (`value_lt_fib_succ_head`, `fib_head_le_value`).

The catalog's prior Fibonacci work (`RankOfApparition`, `FibonacciLucasBridge`,
`FibonacciPisanoRepresentation`, the Carmichael primitive-divisor files) is entirely
*multiplicative* (divisibility, entry points, periods). Zeckendorf is the orthogonal
*additive* pillar. The conjectures below are concrete, falsifiable, and chosen to
either deepen the additive theory or bridge it to the existing multiplicative theory.

## Conjecture 1 (Lekkerkerker term-count bounds — testable now)
Define `numTerms n := (Classical.choose (exists_zeck n)).length`. Then the number of
Fibonacci summands obeys, for `n ≥ 1`,
`F (numTerms n + 1) ≤ ... ` more sharply: `numTerms n ≤ Nat.log φ`-style bound, and
concretely the **clean falsifiable form** `Nat.fib (numTerms n + 1) ≤ n + 1`
(each used index is distinct and `≥ 2`, so `n ≥ value of the smallest admissible
`numTerms`-term list = F 2 + F 4 + … = F (2k) - 1`). Stronger: the maximal number of
terms in any Zeckendorf representation of an `n < F (m+1)` is `⌊m/2⌋`.
**Target lemma:** `numTerms n ≤ n` and the sharp `2 * numTerms n ≤ greatestIndex n + 1`.

## Conjecture 2 (Greatest-index = Fibonacci logarithm)
Let `gIndex n := (Classical.choose (exists_zeck n)).headD 0` for `n ≥ 1`. Then
`gIndex n` is exactly the unique `a` with `F a ≤ n < F (a+1)` (already essentially
`exists_greatest_fib_le`). **Conjecture:** `gIndex` is monotone and
`gIndex (F k) = k` for `k ≥ 2`, giving an exact "Fibonacci floor-logarithm" that is
the additive analogue of the catalog's `RankOfApparition.fibRank_fib` (`fibRank (F k) = k`).
This is a precise **additive/multiplicative duality** to formalize.

## Conjecture 3 (Fibbinary bijection and counting)
Encode a valid list as a finite 0/1 string with no two consecutive 1s ("Fibbinary").
**Conjecture:** the number of `n` with `F m ≤ n < F (m+1)` whose Zeckendorf strings
have length exactly `m-1` equals `F (m-1)`, and the total count of admissible strings
of length `k` is `F (k+2)`. Formal target: a length-preserving bijection
`{l // IsZeck l ∧ gIndex-bound} ≃ {b : Fin k → Bool // no two adjacent true}` and
`Fintype.card` of the right side `= Nat.fib (k+2)`. This connects Zeckendorf to the
classical "Fibonacci counts independent sets on a path" theorem.

## Conjecture 4 (Zeckendorf is the unique greedy-stable representation)
Among **all** representations of `n` as sums of distinct Fibonacci numbers
(`F i`, `i ≥ 2`, allowing consecutive indices), the Zeckendorf one uses the
**fewest** terms and is the lexicographically-greatest by index multiset.
**Falsifiable target:** for any `IsRep l` (distinct indices `≥ 2`, no gap condition)
with `value l = n`, `numTerms n ≤ l.length`, with equality iff `IsZeck l`. This makes
non-consecutiveness equivalent to term-count minimality.

## Conjecture 5 (Additive ↔ multiplicative bridge via the rank of apparition)
For a modulus `m` with Fibonacci rank `r = fibRank m` (catalog `RankOfApparition`),
the residues `n mod m` realized by truncating a Zeckendorf representation to indices
`< r` are exactly a complete residue transversal "twisted" by the Pisano data.
**Concrete first step:** `m ∣ value l` is governed by the indices of `l` modulo `r`
through `m ∣ F i ↔ r ∣ i` (`fibRank_dvd_iff`). Conjecture: an explicit formula for
`value l mod m` in terms of the index residues `l mod π(m)` (Pisano period), unifying
the additive (Zeckendorf) and multiplicative (entry-point/Pisano) catalog threads in
a single divisibility criterion for Zeckendorf sums.
