# Computational Evidence — Uncrowded Uniform Hypergraph List Coloring

## The target theorem (informal)

For every integer `r ≥ 2` and real `ε > 0` there is `Δ₀` such that every
`(r+1)`-uniform hypergraph `H` with girth `≥ 5` and maximum degree `Δ ≥ Δ₀`
has list chromatic number `χ_ℓ(H) ≤ ⌈(1+ε)(rΔ / ln Δ)^(1/r)⌉`.

The full statement is proved via a semi-random *nibble* argument together with a
Rosenfeld-style counting completion. That proof is far beyond current
formalization reach (it needs concentration inequalities, the entropy-compression
/ Rosenfeld method, and the local-lemma machinery for hypergraphs, none of which
are available in a usable packaged form in Mathlib). We instead formalize the
honest, fully-provable **elementary counting core** of the same circle of ideas,
plus matching lower bounds, in contrarian "prove-or-disprove" style.

## What the elementary counting gives

For an `(r+1)`-uniform hypergraph `H` with `m` edges, a uniform random
`k`-coloring makes a fixed edge monochromatic with probability `k^{-r}`
(choose the common colour `k` ways out of `k^{r+1}` colourings of the edge).
By the union bound, if `m < k^r` then a proper `k`-coloring exists. Hence

    χ(H) ≤ min { k : k^r > m }  ≤  ⌈ m^{1/r} ⌉ + 1.

Since a maximum-degree-`Δ` `(r+1)`-uniform hypergraph on `n` vertices has
`m ≤ nΔ/(r+1)` edges, this recovers a bound of order `(Δ)^{1/r}` (times a
constant, and *without* the `ln Δ` savings). This is the Erdős/Rosenfeld
counting floor that the nibble method refines.

## Small-case calculations (Property B, `k = 2`)

The corollary at `k = 2` is the classical Erdős result: an `(r+1)`-uniform
hypergraph with fewer than `2^r` edges is 2-colorable.

| r | uniformity r+1 | edges guaranteeing 2-colorable ( < 2^r ) |
|---|----------------|-------------------------------------------|
| 1 | 2 (graphs)     | < 2   (a single edge is 2-colorable)      |
| 2 | 3              | < 4                                       |
| 3 | 4              | < 8                                       |
| 4 | 5              | < 16                                      |

These thresholds `2^r = 2,4,8,16,…` (OEIS A000079, powers of two) match the
Property-B counting bound exactly and are reproduced by
`property_B_of_few_edges`.

## Lower bound / counterexample hunt

Naive over-optimistic conjecture: *"for `Δ` large every `(r+1)`-uniform
hypergraph needs only a bounded number of colours."* **False.** The complete
`(r+1)`-uniform hypergraph on `n` vertices (all `(r+1)`-subsets are edges) needs
`⌈n/r⌉` colours: if `k·r < n` then some colour class has `≥ r+1` vertices, which
form a monochromatic edge. This is `complete_needs_many_colors`, and it shows the
number of colours must grow with the instance — the constant-colour conjecture is
refuted, and the `(·)^{1/r}` growth of the target theorem is genuinely necessary.

## Summary of formally verified content

* `exists_proper_coloring_of_few_edges` — `m < k^r ⇒` proper `k`-coloring exists.
* `property_B_of_few_edges` — Erdős Property B: `m < 2^r ⇒` 2-colorable.
* `complete_needs_many_colors` — `k·r < n ⇒` a monochromatic `(r+1)`-set exists.

All are proved without `sorry`; see `ListChromaticUncrowded.lean`.
