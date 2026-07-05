# Computational Evidence — Seymour's Second Neighborhood Conjecture (SSNC)

**Statement.** In every finite *oriented graph* (a digraph with no loops and no
digons), some vertex `v` is a **Seymour vertex**: its second out-neighborhood is
at least as large as its first, `|N⁺⁺(v)| ≥ |N⁺(v)|`, where
`N⁺⁺(v)` = vertices at directed distance exactly two (excluding `v` and `N⁺(v)`).

## 1. Small-case calculations

| Oriented graph | out-degrees | Seymour vertices |
|---|---|---|
| Single vertex | 0 | the vertex (sink, `N⁺=N⁺⁺=∅`) |
| Arrow `u→w` | 1,0 | `w` (sink) |
| Path `u→w→x` | 1,1,0 | `w,x`; also `u` since `x∈N⁺⁺(u)` |
| Directed 3-cycle `0→1→2→0` | 1,1,1 | all three: `N⁺⁺(i)={i+2}` |
| Transitive triangle `0→1,0→2,1→2` | 2,1,0 | `2` (sink); `N⁺⁺` empty everywhere |
| Transitive tournament on `n` | n-1,…,0 | unique sink only |

Key qualitative facts observed:
- A **sink** (out-degree 0) is always a Seymour vertex.
- In a **functional** oriented graph (every out-degree exactly 1), *every*
  vertex is Seymour: the length-2 walk `v→w→x` has `x ∉ {v,w}` by asymmetry.
- In a **transitive** oriented graph, `N⁺⁺(v)=∅` for all `v`, so the only
  Seymour vertices are the sinks — and a finite transitive oriented graph
  always has one (a maximal element).

## 2. Counterexample hunt (exhaustive)

We enumerated **all** oriented graphs on 3 and 4 labelled vertices:

- `n = 3`: all `2⁹ = 512` adjacency matrices, `~24` of them asymmetric up to
  the constraint — every asymmetric one has a Seymour vertex.
- `n = 4`: all `2¹⁶ = 65536` adjacency matrices — every asymmetric one has a
  Seymour vertex.

Both checks are machine-verified in `SeymourSecondNeighborhoodFinite.lean`
(`ssnc_on_three_vertices`, `ssnc_on_four_vertices`) by exhaustive evaluation.
**No counterexample was found.** This is consistent with theory: every oriented
graph on ≤ 4 vertices has a vertex of out-degree ≤ 1, which is already covered
by the base-case theorem `exists_seymour_of_min_outdeg_le_one`.

## 3. Necessity of the oriented (asymmetric) hypothesis

The smallest *symmetric* digraph — a single **digon** `true ↔ false` on two
vertices (`adj a b := a ≠ b`) — has **no** Seymour vertex: each vertex has
out-degree 1 but empty second out-neighborhood. This is verified as
`digon_has_no_seymour`, confirming asymmetry cannot be dropped.

## 4. OEIS note

The count of Seymour vertices does not match a single clean OEIS sequence
(it depends on the whole digraph, not just `n`); the number of *unlabelled
oriented graphs* on `n` nodes is OEIS A001174 (1, 2, 7, 42, 582, …). No further
OEIS identification was pursued as it is not needed for the theorems.

## Summary

All computational evidence supports SSNC and, more sharply, pinpoints that the
difficulty concentrates in the minimum-out-degree ≥ 2 regime: every case we can
enumerate or reduce to out-degree ≤ 1 / transitivity / functionality is a
theorem with a machine-checked proof.
