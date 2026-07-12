# Computational Evidence: White's Quadratic Exchange Conjecture

## 1. Small-case calculations

### Uniform matroid `U_{2,4}` (bases = all 2-subsets of `{0,1,2,3}`)

There are `C(4,2) = 6` bases:
`{0,1}, {0,2}, {0,3}, {1,2}, {1,3}, {2,3}`.

Consider configurations consisting of two bases whose multiset union is the full
set `{0,1,2,3}` (each element once). These are exactly the three "perfect
matchings":

| Configuration        | Multiset union      |
|----------------------|---------------------|
| `{0,1} , {2,3}`      | `{0,1,2,3}`         |
| `{0,2} , {1,3}`      | `{0,1,2,3}`         |
| `{0,3} , {1,2}`      | `{0,1,2,3}`         |

All three share the same multiset union, so White's conjecture predicts they are
mutually reachable by quadratic moves. Direct check of the move
`{0,1},{2,3} → {0,2},{1,3}`:

```
{0,1} ⊎ {2,3} = {0,1,2,3} = {0,2} ⊎ {1,3}   ✓
```

so it is a legal quadratic move; likewise `{0,2},{1,3} → {0,3},{1,2}`. Two moves
connect all three matchings. This is formalized as `U24_matchings_rreachable`.

### Rank-1 uniform `U_{1,n}` (bases = singletons)

A configuration is a multiset of singletons; its multiset union is just the
multiset of the chosen elements. Any two configurations with equal union are
literally the same multiset of singletons, so connectivity is trivial. This is
the degenerate boundary case.

## 2. Counterexample hunt (necessary direction)

We tested the *necessary* direction (connected ⇒ equal union) — it must hold, and
does: every quadratic move replaces `B₁,B₂` by `C₁,C₂` with
`B₁ ⊎ B₂ = C₁ ⊎ C₂`, so the total union is preserved verbatim. No counterexample
exists; this is proved unconditionally as `reachable_preserves_union`.

For the *sufficient* direction (the open conjecture), a brute-force search over
`U_{2,4}` and `U_{2,5}` configurations of up to 3 bases found **no** pair of
equal-union configurations that fail to be connected — consistent with the
conjecture. (The general statement remains open.)

## 3. OEIS note

The number of bases of `U_{r,n}` is the binomial coefficient `C(n,r)`
(OEIS A007318, Pascal's triangle). For the perfect-matching configurations of
`U_{2,2k}` the count is the double factorial `(2k−1)!! `
(OEIS A001147: 1, 1, 3, 15, 105, ...), the number of perfect matchings of a
`2k`-element set — the relevant enumeration for the fibers of the multiset-union
map at the "each element once" degree.

## 4. Summary table of verified invariants

| Invariant                     | Status          | Lemma                        |
|-------------------------------|-----------------|------------------------------|
| Total multiset union          | preserved       | `reachable_preserves_union`  |
| Per-element multiplicity      | preserved       | `reachable_preserves_count`  |
| Number of bases               | preserved       | `reachable_preserves_card`   |
| Symmetric exchange ⇒ move     | always          | `symmExchange_qmove`         |
| `U_{2,4}` connectivity        | verified        | `U24_matchings_rreachable`   |
