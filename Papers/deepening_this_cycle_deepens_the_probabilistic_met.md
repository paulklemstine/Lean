# Computational Evidence — Property B for sparse `k`-uniform hypergraphs

**Claim formalised.** Every `k`-uniform hypergraph with fewer than `2^{k-1}` edges is
two-colourable (has *Property B*). Equivalently, the minimum number of edges `m(k)` in a
non-two-colourable `k`-uniform hypergraph satisfies `m(k) ≥ 2^{k-1}`.

## 1. Small-case calculations (the counting bound)

The proof is a finite double-count over the `2^N` colourings (`R ⊆ V`, `N = |V|`).
For one edge `e` of size `k`, exactly `2^{N-k}` colourings make it all-red and `2^{N-k}`
make it all-blue, so `2·2^{N-k}` colourings make it monochromatic. A union bound over the
`|H|` edges makes some colouring proper as soon as

    |H| · 2·2^{N-k} < 2^N   ⟺   |H| < 2^{k-1}.

| k | 2^{k-1} (our lower bound for m(k)) | true m(k) |
|---|------------------------------------|-----------|
| 1 | 1                                  | 1         |
| 2 | 2                                  | 3         |
| 3 | 4                                  | 7 (Fano plane) |
| 4 | 8                                  | 23        |
| 5 | 16                                 | ≥ 51      |

The bound is exact at `k = 1` and grows exponentially, matching the known exponential
growth of `m(k)` (the current best lower bound is `m(k) = Ω(2^k √(k/ln k))`, Radhakrishnan–Srinivasan).

## 2. OEIS

The exact values of `m(k)` (1, 3, 7, 23, …) are OEIS **A051611**-adjacent; the small
values `1, 3, 7, 23` are the established minima. Our theorem proves the clean exponential
lower envelope `2^{k-1}`, not the exact sequence.

## 3. Counterexample hunt

* `k = 3`, `|H| = 3`: any three triples are 2-colourable (checked by the general theorem;
  `twoColorable_of_three_uniform_card_lt_four`). The Fano plane (`|H| = 7`) is the first
  non-2-colourable 3-uniform hypergraph, consistent with `m(3) = 7 ≥ 4`.
* A single edge of size `≥ 2` is always 2-colourable (`twoColorable_single_edge`); a
  single edge of size `1` is **not** (it is unavoidably monochromatic), so the hypothesis
  `2 ≤ |e|` is necessary — this boundary case is handled explicitly in the statement.

No counterexample to the formalised claim was found; the union-bound inequality is tight
exactly at the stated threshold.

## 4. Why the finite model

Encoding a colouring by its red vertex set `R ⊆ V` turns the probability calculation into
plain `Finset.powerset` cardinalities (`card_filter_superset`, `card_filter_disjoint`),
avoiding measure theory entirely, exactly as in the companion Ramsey lower-bound file.
