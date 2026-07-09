# Computational Evidence: `ex(n, K_{a,b}, K_{3,b+1}) = O(n^3)` and its asymptotic bridge

This note collects small-case and structural evidence for the claim formalized in
`Catalog/Bridges/GenTuranAsymptoticBridge.lean`:

> For all integers `a, b` with `3 ≤ a ≤ b`, there is a constant `C > 0` such that every
> `n`-vertex `K_{3,b+1}`-free graph `G` contains at most `C · n^3` copies of `K_{a,b}`.

The formal artifact proves the explicit constant `C = C(b, a-3) = (b choose (a-3))` (using the
threshold `t = b+1`, so `t-1 = b`), and then re-expresses the bound in analytic form as
`IsBigO` and as a vanishing density.

## 1. The mechanism, in one line

The bound is a Kővári–Sós–Turán (KST) double count anchored on a 3-element core:

* every copy `(A,B)` of `K_{a,b}` has `|A| = a ≥ 3`, so it contains a triple `S ⊆ A`;
* `K_{3,b+1}`-freeness means **every** triple has at most `b` common neighbors
  (`K3tFree_iff_CNbound`), so the `b`-side `B` lives inside an `≤ b`-element set, and the
  remaining `a-3` vertices of `A` live inside an `≤ b`-element common neighborhood of `B`;
* choosing the triple (`≤ n^3` ways) and then `B` (`≤ C(b,b)=1` ways) and `A\S`
  (`≤ C(b,a-3)` ways) gives `#copies ≤ C(n,3)·C(b,b)·C(b,a-3) ≤ C(b,a-3)·n^3`.

The exponent `3` is exactly the `3` of `K_{3,b+1}`; the remaining `a+b-3` vertices are each
pinned into a bounded common neighborhood, contributing only a constant factor.

## 2. Small-case constants `C(b, a-3)` (at threshold `t = b+1`)

| a | b | a-3 | C = C(b, a-3) | bound `#K_{a,b} ≤ C·n^3` |
|---|---|-----|---------------|--------------------------|
| 3 | 3 | 0   | 1             | `n^3`                    |
| 3 | 4 | 0   | 1             | `n^3`                    |
| 4 | 4 | 1   | 4             | `4 n^3`                  |
| 4 | 5 | 1   | 5             | `5 n^3`                  |
| 5 | 5 | 2   | 10            | `10 n^3`                 |
| 5 | 6 | 2   | 15            | `15 n^3`                 |
| 6 | 6 | 3   | 20            | `20 n^3`                 |

All constants are positive, so the theorem is non-vacuous: for each admissible `(a,b)` there is
a genuine finite `C`.

## 3. Sanity check: the bound is consistent (not vacuously large or small)

* **Non-triviality.** The count `KabCopies` is an honest `Finset.card` of disjoint
  complete-bipartite pairs; it can be positive (e.g. the complete graph `K_m` with `m = a+b`
  contains copies of `K_{a,b}`), so the theorem constrains a real quantity.
* **Correct order.** For `K_{3,b+1}`-free host graphs the count is *cubic*, not `n^{a+b}`:
  the density check below confirms the fraction of `(a+b)`-vertex placements forming a copy
  tends to `0`.
* **Monotonicity in the forbidden threshold.** Adding edges keeps a subgraph `K_{3,b+1}`-free
  only if the supergraph is; the bound is inherited downward (see the companion file
  `GenTuranK3tDownwardClosure.lean`), consistent with the KST cap being monotone.

## 4. Density (probabilistic reading)

A labelled `K_{a,b}` uses `a + b ≥ 6` vertices, and there are `~ n^{a+b}` ways to place that
many labelled vertices. Since `#copies ≤ C · n^3` with `3 < a + b`, the density satisfies

```
#copies / n^{a+b} ≤ C / n^{a+b-3} → 0   as n → ∞,   since a+b-3 ≥ 3 > 0.
```

This is exactly `genTuran_density_tendsto_zero`. Numerically, for `a=b=3` (`a+b=6`):
`density ≤ 1 / n^3`, e.g. `≤ 10^{-6}` already at `n = 100`.

## 5. OEIS

No new integer sequence is conjectured here; the object of study is an asymptotic *upper bound*
`Θ(n^3)`, whose leading exponent `3` and constant `C(b, a-3)` are given in closed form above, so
an OEIS lookup is not applicable.

## 6. Counterexample hunt

The claim is an upper bound of the form "`#copies ≤ C·n^3`". A counterexample would be a
`K_{3,b+1}`-free graph with `> C·n^3` copies of `K_{a,b}`. The KST core argument shows this is
impossible for `C = C(b,a-3)`; the formal proof in `KabCopies_cubic_of_K3tFree` closes this with
no `sorry`, so no counterexample exists.
