# Computational evidence — ascent-cost economics (exp 547 formalisation)

All numbers below were produced with double-precision evaluation of the closed-form laws

```
K(α)      = (1-α)(2-α)
E_dfs(α,h)      = h(1 - K/2) + K(3^(h+1) - 3)/4          -- ternary DFS backtracking
E_restart(α,h)  = h / α^h                                 -- restart from root
E_b(b,w,h)      = h(1 - w/(b-1)) + w(b^(h+1) - b)/(b-1)^2 -- general branching factor
```

These are *exploratory* numerics.  Everything that is asserted as a result is proved in Lean in
`Catalog/Novelty/AscentCostLaw.lean`, `Catalog/Novelty/AscentCostExponent.lean` and
`Catalog/Novelty/AscentCostBranching.lean`; the tables here only motivated and sanity-checked the
statements before they were formalised.

## 1. The DFS law and its growth ratio (effective-branching test)

| α | K(α) | E_dfs(10) | leading term 3^10·3K/4 | E(11)/E(10) | E(15)/E(14) |
|---|------|-----------|------------------------|-------------|-------------|
| 0.9  | 0.11   | 4880.91 | 4871.54 | 2.99636 | 2.99994 |
| 0.99 | 0.0101 | 457.24  | 447.30  | 2.95869 (h=12: 2.99434) | 2.99993 |

The ratio approaches `3` from below for both accuracies: accuracy moves the prefactor (a factor
`~11` between the two rows) but not the base.  This is the numerical shadow of
`dfs_growth_ratio_tendsto_three`.

Boundary calibration (both proved in Lean): at `α = 0` the law returns exactly the exhaustive
level sweep `(3^(h+1)-3)/2` (`dfsCost_zero`), and at `α = 1` exactly the depth `h`
(`dfsCost_one`).

## 2. The α = 1/3 crossover

| α | E_restart(10) | E_dfs(10) | winner at h=10 | smallest h where restart wins (h ≤ 40) |
|---|---------------|-----------|----------------|-----------------------------------------|
| 0.30 | 1.69·10^6 | 5.27·10^4 | DFS | none (α < 1/3: DFS wins for all h) |
| 0.34 | 4.84·10^5 | 4.85·10^4 | DFS | none up to 40 (crossover is asymptotic; `1/α = 2.94 < 3`) |
| 0.40 | 9.54·10^4 | 4.25·10^4 | DFS | 18 |
| 0.50 | 1.02·10^4 | 3.32·10^4 | restart | 6 |
| 0.90 | 28.68     | 4.88·10^3 | restart | 2 |

On the grid `α ∈ {0.05, 0.10, …, 0.95}`, `h ∈ {1, …, 40}` restart is cheaper in 434 of 760 cells
(57.1%).  The cell fraction is grid-dependent; what is grid-independent — and what is proved —
is the asymptotic statement: restart wins by an unbounded factor for every `α > 1/3`
(`restart_dominates_dfs`) and loses by an unbounded factor for every `α < 1/3`
(`dfs_dominates_restart`).  Rows `α = 0.34` and `α = 0.40` show why a finite grid understates
the win region: near the boundary the crossover height is large.

## 3. Logarithmic rates (exponent law)

`log E / h`, compared with the predicted limits `log 3 = 1.09861` and `log(1/α)`:

| α | h | log E_restart/h | log(1/α) | log E_dfs/h | log 3 |
|---|---|-----------------|----------|-------------|-------|
| 0.50 | 10 | 0.92341 | 0.69315 | 1.04109 | 1.09861 |
| 0.50 | 40 | 0.78537 | 0.69315 | 1.08423 | 1.09861 |
| 0.25 | 10 | 1.61655 | 1.38629 | 1.09704 | 1.09861 |

At `α = 0.5 > 1/3` the minimum of the two rates tracks `log(1/α) = log 2`; at `α = 0.25 < 1/3`
it is pinned at `log 3`.  This is `ascent_exponent_law`: the optimal exponent is
`min(3, 1/α)`.

## 4. Universality in the branching factor

With `b = 5`:

| w | E_5(6) | E_5(7)/E_5(6) |
|---|--------|----------------|
| 4 (= b-1, blind) | 19530 (= (5^7-5)/4, the exact 5-ary internal-node count) | 5.00026 |
| 0.2 | 982.2 | 4.97801 |

The base is `5` for both waste weights, a factor `20` apart in prefactor.  Restart at `b = 5`
crosses over at `α = 1/5`: at `α = 0.15`, `E_restart(8) = 3.12·10^7` versus `E_5(8) = 1.22·10^5`
(w = 1) — DFS wins; at `α = 0.25`, `E_restart(8) = 5.24·10^5` and the ratio decays like
`(1/(5α))^h`.  Proved as `dfsB_growth_ratio_tendsto`, `restart_dominates_dfsB`,
`dfsB_dominates_restart`, `ascent_exponent_law_general`.

## 5. Breakeven accuracy against an exact-solver budget

Critical accuracy `α*(c,h) = ((1+c)h/F)^(1/h)` for a budget of `F = 183000` steps (the median of
the reference exact scan):

| h \ c | 0 | 10 | 100 | 1000 | 3000 |
|-------|---|----|-----|------|------|
| 10 | 0.3748 | 0.4763 | 0.5945 | 0.7478 | 0.8346 |
| 20 | 0.6338 | 0.7145 | 0.7983 | 0.8953 | 0.9458 |
| 40 | 0.8100 | 0.8601 | 0.9091 | 0.9627 | 0.9895 |

`α*` increases in `c` (proved: `criticalAccuracy_strictMono_cost`) and in `h`, and the win
condition is an exact iff (`breakeven_iff`).  For a depth in the twenties and a per-step overhead
in the thousands of visit-equivalents, the required accuracy sits in the 0.85–0.96 band, which is
the band reported by the reference experiment; a measured channel with accuracy near the majority
baseline is far below it.

## 6. Counterexample hunt

* "Beam wins somewhere": swept `α ∈ {0, 0.01, …, 1}`, `h ≤ 30`; `E_dfs ≤ beam` everywhere with
  equality exactly at `α = 0`.  Proved as `dfsCost_le_beamCost` (and sharpness as
  `dfsCost_zero`).
* "Some `α < 1` gives growth ratio below 3": swept `α ∈ {0.5, 0.9, 0.99, 0.999, 0.9999}` up to
  `h = 60`; the ratio always converges to `3` from below, and the approach is slower for larger
  `α` — the exponential-to-polynomial transition only occurs *at* `α = 1`.  Proved as
  `dfs_growth_ratio_tendsto_three` together with `dfsCost_one`.
* "Class-hint cap 3 bounds the branch-hint speedup": false already at `α = 0.9`, `h = 3`
  (`(3α)^3 = 19.7 > 3`).  Proved in general as `hintSpeedup_exceeds_cap`.

No OEIS sequence is involved: the objects are one-parameter real cost laws rather than integer
sequences.  The one integer sequence that does appear, the internal-node counts
`(3^(h+1)-3)/2 = 3, 12, 39, 120, 363, …` of complete ternary trees, is standard.
