# Computational Evidence — Merkle Commitments & Local-Check Soundness

This note records the small-case checks that motivated the two formalized files,
`MerkleCommitment.lean` and `LocalCheckSoundness.lean`.

## 1. Merkle-root binding (constructive collision extraction)

Model: complete binary tree of depth `d`, `2^d` leaves addressed by bit-strings,
compression function `h : α → α → α`; the root folds child digests.

Claim tested: if two distinct leaf assignments hash to the *same* root, the
extractor exhibits an explicit collision `(a,b) ≠ (a',b')` with `h a b = h a' b'`.

Toy compression `h a b = 2*a + 3*b + 1` over `ℤ` (not collision-resistant, chosen
precisely so ambiguities exist and the extractor has something to find):

| depth `d` | leaves `f` | leaves `g` (`f ≠ g`) | root(f) | root(g) | collision found by extractor |
|-----------|-----------|----------------------|---------|---------|------------------------------|
| 1 | (0,1) | found via search | equal for some pairs | — | top-node pair `(F0,F1)≠(G0,G1)` with equal `h` |
| 2 | random  | random with equal root | equal | equal | divergence recurses to a subtree node |

Key qualitative observations that shaped the proof:
- When `h` is *injective* (e.g. pairing into distinct integers), an exhaustive
  search over small `d` finds **no** two distinct leaf assignments with equal
  root — matching `mroot_injective`.
- When `h` is non-injective, every equal-root/distinct-leaf pair yields a
  collision located either at the top node or (after equal child digests) inside
  exactly one subtree — the dichotomy that becomes the induction's case split.

## 2. Local-check soundness gap and amplification

Model: challenge space `Ω` of size `n`; an *invalid* certificate fails at least
one challenge, so at most `n-1` challenges pass.

Single-round accepting fraction `p = (#passing)/n` for the worst cheater
(corrupting exactly one location):

| `n` (|Ω|) | worst-case `p` | `p < 1`? |
|-----------|----------------|----------|
| 2 | 1/2 | yes |
| 3 | 2/3 | yes |
| 6 | 5/6 | yes |
| 10 | 9/10 | yes |

`k`-round survival probability `p^k` (tightness: exactly `((n-1)/n)^k`):

| `n` \ `k` | 1 | 5 | 20 | 50 |
|-----------|------|-------|--------|--------|
| 2 | 0.500 | 0.031 | 9.5e-7 | 8.9e-16 |
| 6 | 0.833 | 0.402 | 0.026 | 1.1e-4 |
| 10 | 0.900 | 0.590 | 0.122 | 0.0052 |

Observation matching the Analyst note: to reach error `2^{-k}` one needs
`Θ(n·k)` rounds when `n` is large; the blanket `2^{-k}` claim holds only when a
single round already catches with probability `≥ 1/2` (i.e. `n = 2`).

## 3. Catalog bridge (graph 3-colouring)

For a graph with edge set `E` and an improper committed 3-colouring, the passing
(distinct-colour) edges number at most `|E|-1` by
`ZK.Graph3Coloring.soundness_exists_catch`, so the `k`-round survival probability
is at most `((|E|-1)/|E|)^k`. Tested on `K₄` (`|E| = 6`) with a colouring that
monochromatically collapses one edge: single-round accept `5/6`, matching the row
`n = 6` above.

## Counterexample hunt

- Searched for distinct leaf assignments with equal root under an *injective*
  toy `h` up to depth 3: none found (consistent with `mroot_injective`).
- Searched for an invalid certificate whose accepting fraction equals `1`: none
  (consistent with `accept_frac_lt_one`).

No counterexamples to the formalized statements were found.
