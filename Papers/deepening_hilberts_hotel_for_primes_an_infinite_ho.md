# Computational evidence — deepening the prime hotel

Notation: `p n = Nat.nth Nat.Prime n` is the `n`-th prime (0-indexed), so
`p 0 = 2, p 1 = 3, p 2 = 5, p 3 = 7, p 4 = 11, p 5 = 13, p 6 = 17, p 7 = 19, …`.
The displacement ratio of a rearrangement `σ` is `primeRatio σ n = p(σ n)/p(n)`.

## 1. Subgroup closure (composition / inversion)

For a finitely supported `σ` (eventually the identity) the ratio is eventually `1`, so any
composition/inverse of such maps is again eventually `1`.  More generally, for any well-behaved
`σ, τ` we use the exact identity
`primeRatio (σ∘τ) n = primeRatio σ (τ n) · primeRatio τ n`,
and `τ n → ∞`, so the first factor `→ 1` and the second `→ 1`.  Sample check with
`σ = swap 0 1`, `τ = swap 2 3` (both finitely supported):

| n | p n | (σ∘τ) n | p((σ∘τ)n) | ratio |
|---|-----|---------|-----------|-------|
| 0 | 2   | 1→...   | 3         | 1.5   |
| 1 | 3   | 0       | 2         | 0.667 |
| 2 | 5   | 3       | 7         | 1.4   |
| 3 | 7   | 2       | 5         | 0.714 |
| ≥4| —   | n       | p n       | 1     |

Eventually `1`, consistent with membership in the subgroup.

## 2. The badly behaved family `badPermFrom a`

`badPermFrom a` swaps a sparse doubling sequence `jumpSeqFrom a` where each jump at least doubles
the prime value, so at even jump points the ratio is `≥ 2`.  It fixes every index `< a`.

- Doubling: choose `b > m` with `p b ≥ 2·p m` (possible since `p → ∞`).  Starting from `a`, the
  sequence `a = j₀ < j₁ < j₂ < …` satisfies `p(j_{k+1}) ≥ 2 p(j_k)`.
- At `j_{2i}` we swap to `j_{2i+1}`, giving `ratio = p(j_{2i+1})/p(j_{2i}) ≥ 2`.
- Since `j_{2i} → ∞`, the ratio is `≥ 2` infinitely often, so the limit is not `1`.

Hence `badPermFrom a` is **not** well behaved for every `a`, and fixing `[0,a)` lets us make it
agree with any target permutation on an arbitrarily long initial segment.

## 3. Genericity (both classes dense)

Given any `σ` and `N`:
- take a finitely supported `f` agreeing with `σ` on `{0,…,N-1}` (well behaved), and
- form `f · badPermFrom N`.
Because `badPermFrom N` fixes `[0,N)`, the product still agrees with `σ` on `{0,…,N-1}`; because
the well-behaved maps form a subgroup and `badPermFrom N` is not in it, the product is not well
behaved.  So arbitrarily good finite agreement is compatible with being badly behaved.

## Counterexample hunt

The bold conjecture tested was "well-behaved rearrangements are NOT a subgroup".  No
counterexample to closure was found — every attempted composition/inverse of well-behaved maps
stayed well behaved, matching the proof that closure always holds.  The disproved statement is
therefore the non-closure conjecture itself.

No OEIS sequence is central here (the objects are permutations, not a single integer sequence);
`p n` is A000040.
