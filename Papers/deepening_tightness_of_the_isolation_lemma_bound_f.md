# Computational Evidence — Tightness of the Isolation-Lemma bound for arbitrary offsets

Setting: inclusion-free hypergraph `H` on `n` vertices, real edge-offset
`f : H → ℝ`. Each edge `S` gets weight `f(S) + ∑_{v∈S} w(v)` for a weight
assignment `w ∈ {0,…,d-1}^n`. `w` is **isolating** when a *unique* edge attains
the minimum weight. Faber–Harris lower bound:

```
#isolating(H,f) ≥ n · ∑_{j=0}^{d-1} j^{n-1}    (=: B(n,d))
```

`B(n,d)` first terms: `B(2,2)=2, B(2,3)=6, B(3,2)=3, B(3,3)=15, B(3,4)=42, …`.

## 1. Small-case exact minimisation over offsets

For each inclusion-free hypergraph on `n ≤ 3` vertices we minimised the isolating
count over a fine offset grid (half-integer offsets, which suffice to realise all
tie / strict combinatorial types). Selected results:

| n | d | H (edges) | min over f of #isolating | B(n,d) | tight? |
|---|---|-----------|--------------------------|--------|--------|
| 2 | 2 | {{0}} (single edge) | 4 | 2 | **NO** (const 4) |
| 2 | 2 | {{0},{1}} (singletons) | 2 | 2 | yes |
| 2 | 2 | {{0,1}} (single edge) | 4 | 2 | **NO** |
| 3 | 2 | {{0,1},{0,2}} (covering!) | 4 | 3 | **NO** |
| 3 | 2 | {{0},{1},{2}} (singletons) | 3 | 3 | yes |
| 3 | 2 | {{0,1},{0,2},{1,2}} (all pairs) | 3 | 3 | yes |
| 3 | 3 | {{0},{1}} | 18 | 15 | **NO** |
| 3 | 3 | {{0},{1},{2}} | 15 | 15 | yes |
| 3 | 3 | {{0,1},{0,2},{1,2}} | 15 | 15 | yes |

Full enumeration output is reproduced by the scripts summarised below.

**Key finding (contrarian).** The bound is **not** attainable for every
inclusion-free hypergraph, *even allowing arbitrary real offsets*. The single
edge case is extreme and rigorous: with one edge every `w` is isolating, so the
count is `d^n` for **all** `f`, never `B(n,d)`. Even *covering* antichains such as
`{{0,1},{0,2}}` (excess 1) and `{{0},{1}}` (excess 3) fail. This is the basis of
the formal theorem `general_tightness_fails`.

## 2. A new family that DOES attain the bound: co-singletons

The **co-singleton hypergraph** = all `(n-1)`-subsets (complements of singletons)
attains `B(n,d)` exactly with zero offset:

| n\d | 2 | 3 | 4 |
|-----|---|---|---|
| 2 | 2 | 6 | 12 |
| 3 | 3 | 15 | 42 |
| 4 | 4 | 36 | 144 |

Every entry equals `B(n,d)`. Reason (proved formally): edge `V\{v}` has weight
`(∑ all) − w(v)`, so *minimising* the edge is *maximising* the vertex weight;
isolating ⇔ unique strict **maximum** vertex, and reflection `w ↦ (rev∘w)` gives
a bijection with the unique-strict-minimum assignments. This is the formal
theorem `card_strictMax_eq`.

## 3. Sequences / OEIS

`B(n,d) = n · ∑_{j<d} j^{n-1}`. For fixed `n=3`: `0,1,15,42,90,…` — the values
`3·∑_{j<d} j²`. These match the singleton count sequence already documented in
the companion file. No new OEIS entry is claimed.

## Reproducibility

Two Python enumerators were used (exact integer arithmetic, offsets scaled to
half-integers to expose ties):
- brute minimisation of `#isolating(H,f)` over all inclusion-free `H` for
  `n ∈ {2,3}`, `d ∈ {2,3}`;
- direct zero-offset count for the co-singleton hypergraph, `n,d ≤ 4`.
Both confirm the table entries above and motivated the formal theorems in
`IsolationLemmaTightnessArbitraryOffsets.lean`.
