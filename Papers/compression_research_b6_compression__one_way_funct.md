# Computational Evidence — Compression ⇋ One-Way Functions (Phase B / M8)

All numbers below were produced by `#eval` inside the Lean environment, using
the definitions of the three new files
(`Catalog/Shared/CompressionOneWayFunctions.lean`,
`Catalog/Shared/CompressionUniversality.lean`,
`Catalog/Shared/CompressionSearchToDecision.lean`).  They are *evidence*, not
proof; every claim they support is separately proved as a theorem in those
files (see the cross-references).

## 1. The pigeonhole ceiling `2^(s+1) − 1` is exactly tight

Number of bit strings of length `≤ s`, against the bound `2^(s+1) − 1` proved in
`card_le_of_K_le`:

| s | #{p : |p| ≤ s} | bound 2^(s+1)−1 |
|---|----------------|-----------------|
| 0 | 1 | 1 |
| 1 | 3 | 3 |
| 2 | 7 | 7 |
| 3 | 15 | 15 |
| 4 | 31 | 31 |
| 5 | 63 | 63 |

The bound is attained by the injective decompressor `D₀ p = p ++ [true]`: the
number of distinct outputs from programs of length `≤ s` is again
`1, 3, 7, 15, 31`.  So `card_le_of_K_le` is sharp, not merely an upper estimate.
(The sequence `2^(s+1) − 1` is OEIS A000225, the Mersenne numbers.)

## 2. The numeral code `natCode`

`natCode` maps a bit string to a positive natural number with
`2^|p| ≤ natCode p < 2^(|p|+1)`.  Sample values (length, code):

`(0,1), (1,3), (1,2), (2,7), (2,5), (2,6), (2,4), (3,15)`

Injectivity check on all 31 strings of length `≤ 4`: the number of distinct
codes equals the number of strings (`true`).  Proved as `natCode_injective`.

## 3. Seeded (randomized) compression covers exactly `|R|·2^s` strings

For prefix seeds of length `k` and programs of length `s`, every string of
length `k+s` is covered (exhaustive check over all strings):

| (k, s) | all `2^(k+s)` strings covered? |
|--------|-------------------------------|
| (1, 2) | true |
| (2, 2) | true |
| (2, 3) | true |
| (3, 2) | true |

Matching upper bound `|R|·(2^(s+1) − 1)` is `card_le_of_K_le_seeded`; the two
together are `randomness_gain_exact`.

## 4. Bounded search `leastFrom`

`leastFrom (fun l => decide (l ≥ t)) 10` for `t = 0..5` returns `0,1,2,3,4,5`:
the least witness, as proved in `leastFrom_spec`.

## 5. Inversion → shortest-program finding (`searchFinder`)

With `f p = true :: p` and brute-force inverters `A l` for the guarded functions
`guardFun f l`, `searchFinder f A (fun n => n)` was run on all `y = f p` with
`|p| ∈ {1,2}`.  In every case the output equals `p` (a shortest program) —
6/6 successes, matching `searchFinder_correct`.

## 6. Decision → search (`decisionToFinder`)

Decompressor `D₂ (b :: t) = t ++ t`, `D₂ [] = []`, with the exact prefix-decision
oracle `dec₂ y w n = ∃ p, |p| = n ∧ D₂ (w ++ p) = y` computed by brute force.

* On all 8 strings `y` of length 3, `decisionToFinder` returns a valid program
  (`D₂ (output) = D₂ y` in 8/8 cases), always taking the `false` branch first,
  exactly as the definition of `rebuild` prescribes.
* Output length vs. brute-force minimum `K D₂ y` over 12 test values:
  `(2,2), (2,2), (2,2), (2,2), (3,3), (3,3), (3,3), (3,3), (3,3), (3,3), (3,3), (3,3)`
  — the reconstruction is *exactly* optimal, as proved in
  `decisionToFinder_correct`.

## 7. Universality and self-delimiting overhead

* Invariance: for the family `fam i p = replicate i true ++ p`, programs
  `unaryTag i p` with `|p| = 2` have lengths `3,4,5,6` for `i = 0,1,2,3`, i.e.
  overhead exactly `i + 1`, and `univSys fam` reproduces `fam i p` in all cases
  (`K_univSys_le`).
* Pairing: for `p = [1,0]`, `q = [0,0,1]`, `|sdPair p q| = 8 = 2·2 + 1 + 3` and
  `parseSD (sdPair p q) = (p, q)` (`sdPair_length`, `parseSD_sdPair`,
  `K_pairSys_le`).

## 8. Counterexample hunt

The two statements most at risk of being false were tested exhaustively on small
cases before being proved:

* "a shortest program produced by the guarded search may be too long" — tested
  on all `p` with `|p| ≤ 2` for `f p = true :: p`: no counterexample;
* "the bit-by-bit reconstruction may return a suboptimal program" — tested on
  all `y` of length `≤ 3` for `D₂`: no counterexample (lengths matched the
  brute-force minimum in 12/12 cases).

No counterexamples were found, and both statements are now theorems.
