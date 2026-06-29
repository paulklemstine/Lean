# Computational Evidence — Bounded Prime Gaps

All claims below are also discharged in Lean (no `native_decide`); this file records
the numerical exploration that motivated the formal statements.

## 1. First prime gaps `p_{n+1} - p_n`
Primes: 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53 …

| n  | p_n | p_{n+1} | gap |
|----|-----|---------|-----|
| 0  | 2   | 3       | 1   |
| 1  | 3   | 5       | 2   |
| 2  | 5   | 7       | 2   |
| 3  | 7   | 11      | 4   |
| 4  | 11  | 13      | 2   |
| 5  | 13  | 17      | 4   |
| 6  | 17  | 19      | 2   |
| 7  | 19  | 23      | 4   |
| 8  | 23  | 29      | 6   |

**Observation:** the only odd gap is `gap(0) = 1`; every later gap is even.
This is exactly `primeGap_even` (gaps of odd primes are differences of odd numbers)
and forces `not_boundedPrimeGaps_one` (gaps `≤ 1` occur only at `n = 0`).
The gap sequence is OEIS **A001223** (differences between consecutive primes);
the record (maximal) gaps are **A005250**.

## 2. Admissible triple `{0, 2, 6}` and prime constellations
Admissibility check via the finite reduction (`p ≤ |H| = 3`, i.e. `p ∈ {2, 3}`):

- mod 2: residues of `{0,2,6}` are `{0,0,0} = {0}` → class `1` is free. ✓
- mod 3: residues of `{0,2,6}` are `{0,2,0} = {0,2}` → class `1` is free. ✓

So `{0,2,6}` is admissible (`admissible_zero_two_six`). Realising constellations
`{n, n+2, n+6}` all prime:

| n  | n, n+2, n+6     | all prime? |
|----|------------------|------------|
| 5  | 5, 7, 11         | yes        |
| 11 | 11, 13, 17       | yes        |
| 17 | 17, 19, 23       | yes        |
| 41 | 41, 43, 47       | yes        |

`prime_triple_five` and `prime_triple_eleven` formalize the first two.

## 3. Counterexample hunt — non-admissible tuples are sterile
The tuple `{0, 1}` is **not** admissible: mod 2 it covers both classes `{0,1}`,
so for every `n` one of `n, n+1` is even. Indeed `{n, n+1}` both prime only for
`n = 2` (giving `2,3`). This matches `finite_constellation_of_not_admissible`:
non-admissibility ⇒ finitely many full prime constellations. No counterexample to
the formalized statements was found.

## 4. The headline target
Maynard (2014): there is an admissible 50-tuple of diameter 246, and the sieve
yields `liminf (p_{n+1} - p_n) ≤ 246`. Our `boundedPrimeGaps_iff_liminf` shows the
combinatorial `BoundedPrimeGaps 246` is *literally* this `liminf` bound; the
remaining (open, in this development) content is the sieve producing the infinitude.
External signal: the polymath8 admissible-tuples tables (diameters 246, 1402, …) are
all **even**, which motivated Future Direction 5.
