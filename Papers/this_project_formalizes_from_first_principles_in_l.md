# Computational Evidence — the symmetric Euler/semantics bridge

This note records the small-case evidence that motivated the theorems in
`ArgumentationSymmetric.lean`.

## 1. The complete conflict graph `K_n`

`completeAF n` is the framework on `n` arguments in which every two distinct
arguments attack each other (mutually). A set is conflict-free iff it contains at
most one argument, so the conflict-free complex `K(AF)` is `n` isolated points.

| n | conflict-free faces           | #preferred (singletons) | Euler χ | grounded |
|---|-------------------------------|-------------------------|---------|----------|
| 0 | {∅}                           | 1 (the empty set)       | 0       | ∅        |
| 1 | {∅, {0}}                      | 1                       | 1       | {0}      |
| 2 | {∅, {0}, {1}}                 | 2                       | 2       | ∅        |
| 3 | {∅, {0},{1},{2}}              | 3                       | 3       | ∅        |
| 4 | ∅ plus 4 singletons           | 4                       | 4       | ∅        |

The Euler characteristic is `∑_{∅≠s} (-1)^(|s|-1)`; here only singletons are
nonempty faces, each contributing `(-1)^0 = 1`, so `χ = n`.

**Observation.** For `n ≥ 1`, `χ(K(AF)) = #preferred = n` exactly. This is the
*correct* Euler/semantics bridge, replacing the refuted identity
`χ = |preferred| − |grounded|`.

**Boundary.** At `n = 0` the framework is empty: the complex is the single empty
face (`χ = 0`), but there is exactly one preferred extension (the empty set), so
`χ = 0 ≠ 1 = #preferred`. Hence the hypothesis `n ≥ 1` is necessary. This is
formalized as `euler_ne_preferred_completeAF_zero`.

## 2. Symmetric self-defense (why the bridge holds)

For any symmetric framework, a conflict-free set `S` is automatically admissible:
if `b` attacks `a ∈ S`, then by symmetry `a` attacks `b`, so `a` defends itself.
Spot check on `completeAF 3` with `S = {1}`: the attackers of `1` are `0` and `2`;
`1` attacks both back, so `{1}` defends its member and is admissible. Every
singleton is therefore admissible and (being a maximal conflict-free set) is
preferred — giving `n` preferred extensions.

## 3. Grounded = isolated vertices

`groundedExt` is the least fixed point of the defense operator; for symmetric
frameworks it equals the set of unattacked arguments. In `completeAF n` with
`n ≥ 2` no argument is unattacked, so the grounded extension is empty; for
`n = 1` the lone argument is unattacked and grounded `= {0}`. This matches the
table above.

## 4. OEIS

The Euler-characteristic sequence for `completeAF n` (n ≥ 1) is simply
`1, 2, 3, 4, …` = the natural numbers (OEIS A000027), i.e. the number of
maximal independent sets of the complete graph. This trivial-looking sequence is
the smallest instance of the general conjecture (see `FUTURE_DIRECTIONS.md`) that
for symmetric irreflexive frameworks `χ(K(AF))` counts the maximal independent
sets of the conflict graph.

All numeric claims above are verified as theorems in `ArgumentationSymmetric.lean`
(`euler_completeAF`, `preferred_completeAF_ncard`, `euler_eq_preferred_completeAF`,
`euler_ne_preferred_completeAF_zero`).
