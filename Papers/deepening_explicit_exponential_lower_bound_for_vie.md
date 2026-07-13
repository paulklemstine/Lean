# Computational Evidence

This project proves a *cross-domain bridge* connecting three areas that meet at the
combinatorial core of the √2-threshold lower bound for Vietoris–Rips (VR)
approximations:

* **metric geometry / topological data analysis** — VR complexes,
* **extremal graph theory** — clique complexes and the maximal clique count,
* **information theory** — description length (`⌈log₂ card⌉` bits).

The central quantitative claims are all about the number of cliques of a graph on `n`
vertices, and the collapse/jump behaviour of the equidistant configuration.  Below we
give small-case evidence.

## 1. Number of cliques (= number of VR simplices) of small graphs

For a simple graph `H` on `n` vertices, a *clique* is a vertex subset that is pairwise
adjacent (the empty set and singletons count).  Writing `N(H)` for the number of cliques:

| graph on 3 vertices          | cliques (subsets that are pairwise adjacent) | N(H) |
|------------------------------|-----------------------------------------------|------|
| empty graph `K̄₃`            | ∅, {0},{1},{2}                                | 4    |
| single edge {0,1}            | ∅, {0},{1},{2}, {0,1}                          | 5    |
| path 0–1–2                   | ∅, {0},{1},{2}, {0,1},{1,2}                    | 6    |
| complete graph `K₃ = ⊤`      | all 8 subsets                                 | 8 = 2³ |

The complete graph attains the maximum `2ⁿ`, and *every* graph has `N(H) ≤ 2ⁿ` because
its clique family is a sub-collection of the power set.  This is exactly
`allCliques_card_le` and `card_allCliques_top`.

| n | max cliques `2^n` | achieved by |
|---|-------------------|-------------|
| 1 | 2                 | K₁          |
| 2 | 4                 | K₂          |
| 3 | 8                 | K₃          |
| 4 | 16                | K₄          |
| 5 | 32                | K₅          |

The sequence of maxima is `2^n` (OEIS A000079, powers of two: 1, 2, 4, 8, 16, 32, …).

## 2. The equidistant configuration `E_n` and its VR barcode

`E_n` puts every pair of `n` points at distance `d` (for `d = √2` this is realised
metrically by the `n` standard Euclidean basis vectors).  Its proximity graph at scale
`r`:

* `r < d`: no edges ⇒ only ∅ and singletons are cliques ⇒ `n + 1` simplices;
* `r ≥ d`: complete graph `K_n` ⇒ all `2^n` subsets are cliques.

| n | simplices below the gap (`n+1`) | simplices at/above the gap (`2^n`) |
|---|---------------------------------|------------------------------------|
| 2 | 3                               | 4                                  |
| 3 | 4                               | 8                                  |
| 4 | 5                               | 16                                 |
| 5 | 6                               | 32                                 |
| 8 | 9                               | 256                                |

A single scale therefore produces an exponential jump `n+1 → 2^n`.  This forces every
`c`-approximation (with `c` below the √2 interleaving threshold) to contain a level of
`2^n` simplices, i.e. `≥ n` addressing bits (`approx_bitComplexity_lower_bound`).

## 3. Threshold exponent γ(c) = ½ − log₂ c

The effective exponent is positive exactly on `[1, √2)` and vanishes at `√2`:

| c      | log₂ c    | γ(c) = ½ − log₂ c |
|--------|-----------|-------------------|
| 1.00   | 0.000     | 0.500             |
| 1.10   | 0.1375    | 0.3625            |
| 1.25   | 0.3219    | 0.1781            |
| 1.40   | 0.4854    | 0.0146            |
| √2 ≈ 1.41421 | 0.5   | 0.000             |

Since `√2 = 2^{1/2}`, `log₂ √2 = ½`, so γ hits `0` precisely at the √2 threshold.  This
matches the interleaving regime where net/Čech constructions start providing genuine
sub-exponential approximations (Jung constant `√(2n/(n+1)) → √2`).

## 4. No counterexample to the extremal bound

The universal claim `N(H) ≤ 2^n` was checked by hand for all `2^{C(3,2)} = 8` graphs on
3 vertices (max attained only by `K₃`) and follows structurally for all `n`: the clique
family is a filtered sub-collection of the `2^n`-element power set.  No counterexample can
exist, and this is the content of the formal proof `allCliques_card_le`.
