# Computational Evidence — Anti-Gravity Mathematics

Concise numerical/structural checks performed before and during formalization.
All claims below are now backed by the sorry-free proofs in `Core.lean` and
`CatalogWitness.lean`; this file records the small-case evidence that guided them.

## 1. Small-case weight computations

Library on `Fin n`, `weight i = #{k | i ∈ deps k}`.

| Library            | n | weights (i = 0..n-1)        | ∑ weight | ∑ out-degree | match? |
|--------------------|---|-----------------------------|----------|--------------|--------|
| `discrete 4`       | 4 | 0, 0, 0, 0                  | 0        | 0            | ✓      |
| `star 4` (Fin 5)   | 5 | 4, 0, 0, 0, 0              | 4        | 4            | ✓      |
| `strongDivLibrary` | 6 | 5, 1, 2, 0, 0, 0           | 8        | 8            | ✓      |

The "∑ weight = ∑ out-degree" column is the conservation law
`total_weight_eq_total_deps`; it holds in every case computed.

For `strongDivLibrary`, deps = `![∅, {0}, {0}, {0,2}, {0,2}, {0,1}]`:
- node 0 is cited by nodes 1,2,3,4,5 → weight 5;
- node 1 is cited by node 5 → weight 1;
- node 2 is cited by nodes 3,4 → weight 2;
- nodes 3,4,5 are cited by nobody → weight 0.
Out-degrees: 0,1,1,2,2,2 → sum 8 = sum of weights. ✓

## 2. Anti-gravity density (refuting the "10%" prediction)

With threshold `(W, len) = (5, 1)`:

| Library            | #theorems | #anti-gravity | density |
|--------------------|-----------|---------------|---------|
| `discrete n`       | n         | 0             | 0       |
| `star n` (Fin n+1) | n+1       | 1 (the root)  | 1/(n+1) |
| `strongDivLibrary` | 6         | 1 (the root)  | 1/6     |

No single constant fits all three rows. The density ranges over `{0} ∪ {1/(n+1)} ∪
{1/6}`, contradicting any universal "10%" law. This is exactly what the Markov
bound `highweight_card_mul_le` predicts: density ≤ (∑ weight)/(W·n), i.e. governed
by average out-degree.

## 3. Counterexample hunt for "every library has an anti-gravity theorem"

Searched all libraries on `Fin n` with `deps ≡ ∅` (the discrete family): for every
`n`, anti-gravity count = 0 at any positive threshold. So the *universal*
existence claim ("every library contains one") is FALSE — existence is only
guaranteed when you are allowed to *choose* the library (the `star` construction),
which is what `star_root_antigravity` proves.

## 4. Sink check (no library is fully anti-gravity)

For every library on `Fin (n+1)`, the top index `Fin.last n` had weight 0 in all
computed cases (it appears in no `deps k`, since edges point backward). This
matches `top_weight_zero` and bounds anti-gravity density strictly below 1.

## OEIS note

The conservation identity makes ∑ weight equal the edge count of the dependency
DAG; for the `star` family this is the sequence `0,1,2,3,…` (A001477) and offers no
new sequence, so no OEIS submission is warranted. Evidence stage kept intentionally
short per the brief.
