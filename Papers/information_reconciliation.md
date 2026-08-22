# Computational evidence — information reconciliation transcripts

All numbers below were computed by kernel evaluation (`#eval`) inside the Lean
project itself, on the same definitions that the theorems use
(`InformationReconciliation.Scheme`, `Scheme.syndrome`, `hammingNorm`).  They
guided the statements that were subsequently proved.

## 1. Hamming-ball volumes `V(n,t) = ∑_{i ≤ t} C(n,i)`

| `n` | `V(n,0)` | `V(n,1)` | `V(n,2)` | `V(n,3)` |
|-----|----------|----------|----------|----------|
| 3   | 1        | 4        | 7        | —        |
| 7   | 1        | 8        | 29       | 64       |
| 15  | 1        | 16       | 121      | —        |

`V(3,1) = 4 = 2²` and `V(7,1) = 8 = 2³` (and `V(15,1) = 16 = 2⁴`): exactly the
perfect single-error-correcting cases, where the sphere-packing leakage bound
`V(n,t) ≤ 2^m` proved in `Scheme.sphere_packing_leakage` is met with equality.
By contrast `V(7,2) = 29 > 8`, so no 3-bit transcript can reconcile two errors
in a 7-bit key — the bound already rules this out.

## 2. Fiber sizes (residual key spaces)

For each scheme we computed the multiset of fiber sizes
`|{x : syndrome x = s}|` over all syndromes `s`:

| scheme | `n` | `m` | fiber sizes (as a set) | #achievable transcripts |
|--------|-----|-----|------------------------|--------------------------|
| `repScheme` (repetition `[3,1]`) | 3 | 2 | `{2}` | 4 |
| `hamScheme` (Hamming `[7,4]`)    | 7 | 3 | `{16}` | 8 |
| `badScheme` (two disjoint checks on 4 bits) | 4 | 2 | `{4}` | 4 |

Every fiber of a given scheme has the same size — the coset structure later
proved in `Scheme.card_consistent_transcript` — and the size is
`2^(n − rank H)`: `2 = 2^(3−2)`, `16 = 2^(7−3)`, `4 = 2^(4−2)`.  The number of
achievable transcripts is `2^rank H` (`Scheme.card_image_syndrome`), matching
`4, 8, 4` above.

## 3. Perfectness / covering check

`|{syndrome x : hammingNorm x ≤ 1}| = 8 = 2³` for the Hamming scheme: the eight
weight-`≤1` patterns realise *every* syndrome, so decoding never fails.  This is
the content of `Scheme.image_syndrome_ball_eq_univ` and `Scheme.exists_decode`.

For the same computation on `badScheme` we get `3 < 4`: one syndrome has no
low-weight explanation, and moreover

```
#eval (univ.filter (fun x : Key 4 =>
    badScheme.syndrome x = badScheme.syndrome ![1,0,0,0] ∧ hammingNorm x ≤ 1)).card
-- 2
```

two distinct weight-1 patterns (`1000` and `0100`) share a syndrome.  The
nonzero kernel weights of `badScheme` are `{2, 4}`, so `2 * t = 2 ≮ 2`: the
separation hypothesis `Scheme.Separating` fails, exactly as it must — this is
the counterexample that shows the hypothesis in `Scheme.correct_transcript`
cannot be dropped.

## 4. Counterexample hunt for the universal bound

We looked for a correct protocol beating `V(n,t) ≤ |T|`.  Fixing Bob's input at
`0` turns any protocol into an injection of the radius-`t` ball into the
transcript alphabet, so no counterexample can exist; the search was replaced by
the proof `Protocol.ball_card_le_card_transcript`.  Small-case sanity check:
for `n = 3, t = 1` a protocol needs `|T| ≥ 4`, and `repScheme` achieves `|T| = 4`.

## 5. OEIS

The row sums `V(n,1) = n+1` and the partial binomial sums `V(n,t)` are the
partial sums of Pascal's triangle (`A008949`); no new sequence arises here.
