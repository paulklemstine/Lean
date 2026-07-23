# Computational Evidence — Discrete Model of Analogical Fidelity

We model an *analogy* between finite carriers `A`, `B` as a pair of maps
`fwd : A → B`, `bwd : B → A`, and score it by the **fidelity**
`fid(φ) = #{ a ∈ A : bwd(fwd(a)) = a }`, the number of source concepts fixed by
the round trip.

## 1. Small-case calculations

Take `A = B = {0,1,2}` (so `|A| = 3`).

| forward `fwd`        | backward `bwd`       | round trip `bwd∘fwd` | fidelity |
|----------------------|----------------------|----------------------|----------|
| id (0,1,2)           | id (0,1,2)           | id                   | 3 (max)  |
| swap 0↔1 (1,0,2)     | swap 0↔1 (1,0,2)     | id                   | 3 (max)  |
| const 0 (0,0,0)      | id                   | (0,0,0)              | 1        |
| (1,2,0) cycle        | (2,0,1) inverse      | id                   | 3 (max)  |
| (1,2,0) cycle        | id                   | (1,2,0)              | 0        |

Observations matching the formal results:
* Maximum fidelity `3` is attained by **every** permutation paired with its
  inverse, not only the identity (`perfect_iff_bijective_selfFinite`,
  `boolFlip_ne_copycat`).
* A non-injective `fwd` (the constant map) can never reach the maximum, because a
  maximiser forces `fwd` injective (`fwd_injective_of_perfect`).

## 2. Counting maximisers over `A = B = Fin n`

A self-analogy is perfect iff `fwd` is a permutation and `bwd = fwd⁻¹`.  Hence
the number of one-sided maximisers is `n!`:

| n | # perfect self-analogies |
|---|--------------------------|
| 1 | 1                        |
| 2 | 2                        |
| 3 | 6                        |
| 4 | 24                       |

This is the factorial sequence (OEIS A000142) and confirms that the maximiser
set is generically far larger than the single Copycat analogy.

## 3. Two-sided vs one-sided

With `A = {0,1}`, `B = {0,1,2}`, `fwd = (0,1)` (inclusion) and
`bwd = (0,1,0)` (retraction): the source round trip is the identity on `A`
(one-sided fidelity `2 = |A|`, maximal), yet the target round trip fixes only
`0,1` and misses `2`, so the two-sided score is `2 + 2 = 4 < 2 + 3 = |A| + |B|`.
This is exactly the split-mono/equivalence gap detected by
`twoSided_max_iff`: two-sided maximality holds **iff** the carriers biject.

## 4. Counterexample hunt

* *"Copycat is the unique one-sided maximiser."* — FALSE. Boolean negation
  (`not`, `not`) is a distinct maximiser (`boolFlip_ne_copycat`); more generally
  every non-identity permutation with its inverse is one.
* *"One-sided maximality forces a bijection."* — FALSE in general (any split
  mono into a larger carrier), TRUE in the self-finite case; the boundary is made
  precise by `perfect_iff_bijective_selfFinite`.

All tabulated values are consistent with the theorems proved in
`AnalogyFidelity.lean`.
