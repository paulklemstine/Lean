# Future Directions — Tropical Convexity (Helly, Carathéodory, Radon)

## Synthesis

This cycle establishes the max-plus convexity dictionary inside the catalog and
proves two of the three classical convexity pillars in genuinely tropical form,
plus the dependence mechanism behind the third:

* **Tropical Carathéodory** (`tropical_caratheodory`, `mem_tHull_caratheodory`):
  a point of the tropical convex hull of points in `ℝ^n` already lies in the hull
  of at most `n` of them. The tropical Carathéodory number is `n`, strictly below
  the classical `n+1`, because each coordinate's defining maximum is attained at a
  *single* generator. The whole proof is `Finset.exists_mem_eq_sup'` plus image
  cardinality bookkeeping.
* **Tropical Helly for blocks** (`box_helly`, with `interval_helly` underneath):
  for axis-parallel tropical blocks the Helly number collapses to `2`, independent
  of dimension — a strengthening invisible to Mathlib's classical `helly_theorem`
  (which only gives `n+1`). The witness is the coordinatewise supremum of lower
  corners.
* **Tropical Radon, dependent case** (`tropical_radon_dependent`): tropical
  dependence (one point inside the hull of the rest) immediately yields a Radon
  partition `{q}` vs. the rest, with hulls meeting at `q`.

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. They build directly on the catalog's tropical semiring distributivity
`TropicalSemiringProperties.tropical_scalar_distrib` (`a + max b c = max (a+b) (a+c)`,
the engine of tropical linearity) and sit alongside `ConvexTropicalBridge`.

## Results Summary

| Theorem | Statement | Tropical number |
|---|---|---|
| `tropical_caratheodory` | hull membership needs `≤ n` generators | Carathéodory `= n` |
| `box_helly` | pairwise-meeting blocks share a point | Helly `= 2` |
| `tropical_radon_dependent` | dependence ⟹ Radon partition | Radon (conditional) |

## Falsifiable Research Directions

### 1. Unconditional tropical Radon for `n+2` points
**Conjecture.** Any `n+2` points in `ℝ^n` are tropically dependent in the strong
sense that the index set partitions into `A, B` with intersecting tropical hulls;
equivalently the tropical Radon number of `ℝ^n` equals `n+2`. **Falsifiable:** exhibit
`n+2` points in some `ℝ^n` for which *every* 2-partition has disjoint tropical hulls.
**The key insight is** that `tropComb` membership is decided coordinatewise by which
generator attains each `sup'`, so a Radon partition should be readable off the
"argmax type" (the map coordinate ↦ winning generator), turning Radon into a
pigeonhole statement on `n+2` types over `n` coordinates. **Why now?** With
`tropical_radon_dependent` already reducing Radon to producing one dependence, and
`tropical_caratheodory` controlling hulls by `n` coordinates, the only missing step
is the type-counting pigeonhole — a self-contained finite-combinatorics lemma.

### 2. Sharpness of the Carathéodory number `n`
**Conjecture.** The bound `n` in `tropical_caratheodory` is tight: for every `n ≥ 1`
there exist points and a coefficient vector whose combination needs all `n`
generators, i.e. no `(n-1)`-subset reproduces it. **Falsifiable:** prove instead that
`n-1` always suffices. **The key insight is** to use the `n` standard tropical unit
vectors (`e_j = -∞` off `j`, modeled by very negative coordinates) so each coordinate
is won by a distinct generator. **Why now?** The forward bound is formalized; the
matching lower bound only needs one explicit witness family and a `sup'`-attainment
computation, completing a sharp characterization.

### 3. Full tropical Helly with number `n+1` for general tropical polytopes
**Conjecture.** Every finite family of (bounded) tropically convex sets in `ℝ^n` such
that every `n+1` of them meet has a common point — and `n+1` is optimal (blocks are
the special case where `2` suffices). **Falsifiable:** find `n+2` tropical polytopes,
pairwise- and `(n+1)`-wise-meeting, with empty total intersection. **The key insight
is** the Develin–Sturmfels result that tropical polytopes are *ordinary* polyhedral
complexes (unions of bounded cells), so classical `helly_theorem` should transfer
through the type decomposition once "tropically convex" is bridged to a covering by
ordinary convex cells. **Why now?** Mathlib already provides `helly_theorem`; the work
is the bridge lemma "tropically convex ⟹ finite union of ordinary convex cells",
which dovetails with the existing `ConvexTropicalBridge`.

### 4. Tropical Tverberg (partition into `r` meeting hulls)
**Conjecture.** Any `(n+1)(r-1)+1` points in `ℝ^n` split into `r` parts whose tropical
hulls have a common intersection point. **Falsifiable:** a point set of that size with
no such `r`-partition. **The key insight is** that the coordinatewise-argmax structure
that gives `tropical_radon_dependent` should iterate: each coordinate can be "shared"
by assigning its winning generator across parts, reducing Tverberg to a balanced
assignment of `n` coordinates among `r` parts. **Why now?** Radon (`r=2`) is in hand
conditionally; the tropical setting may make the notoriously hard Tverberg step
*easier* than classical, because tropical hull membership is purely order-theoretic
(`sup'`) rather than barycentric.

### 5. Coloured / fractional tropical Helly
**Conjecture.** A colourful Helly holds for tropical blocks with the *same* number `2`:
given two colour classes of blocks such that every bichromatic pair meets, one whole
class has a common point. **Falsifiable:** two families, every cross pair meeting, yet
neither class has a common point. **The key insight is** that `box_helly`'s witness
`sup` of lower corners is monotone and depends only on the inequality `a i k ≤ b j k`,
which the colourful hypothesis supplies across classes — so the coordinatewise proof
should survive verbatim. **Why now?** `box_helly` is already coordinate-separable, so
the colourful variant is a low-risk, high-signal extension that probes whether the
Helly-number-`2` phenomenon is robust to the colourful strengthening.
