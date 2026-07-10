# Computational Evidence — The Emotional Chromatic Number

We study `emoChrom G = min { k : k ≥ 3 and G is properly k-colorable }`, the smallest number
of "emotions" (≥ 3) needed to assign one emotion per person in a social network `G` so that no
two friends share an emotion.

## 1. Small-case calculations

Let `χ(G)` be the ordinary chromatic number. Because colorability is monotone in `k`, the
admissible set `{k | k ≥ 3 ∧ Colorable k}` is the up-set `[max(χ(G), 3), ∞)`, so

    emoChrom G = max(χ(G), 3).

Hand-computed instances:

| Graph `G`                     | χ(G) | emoChrom G | note                             |
|-------------------------------|------|------------|----------------------------------|
| single edge `K_2` (bipartite) | 2    | 3          | floor raises 2 → 3               |
| path `P_4`                    | 2    | 3          | bipartite                        |
| even cycle `C_4`, `C_6`       | 2    | 3          | bipartite, floor bites           |
| odd cycle `C_3`, `C_5`, `C_7` | 3    | 3          | already at the floor             |
| clique `K_3`                  | 3    | 3          | `max 3 3`                        |
| clique `K_4`                  | 4    | 4          | `max 4 3`                        |
| clique `K_6`                  | 6    | 6          | six mutual friends, six emotions |
| clique `K_7`                  | 7    | 7          | exceeds the six-emotion window   |

These match the formalized results `emoChrom_complete` (`= max n 3`) and `emoChrom_cycle` (`= 3`).

## 2. Sequence / pattern

For cliques, `emoChrom(K_n) = max(n, 3)` gives `3, 3, 3, 4, 5, 6, 7, 8, …` for `n = 1, 2, 3, …`.
For cycles, `emoChrom(C_n) = 3` is the constant sequence `3, 3, 3, …` (n ≥ 3), collapsing the
even/odd χ dichotomy `2, 3, 2, 3, …`.

## 3. Counterexample hunt (folklore claim)

The proposal asserts: *"the chromatic polynomial has a root at k = 2 for any bipartite graph."*
This is FALSE. Test on the smallest bipartite graph with an edge, `K_2`:

    P(K_2, k) = k·(k−1),   so   P(K_2, 2) = 2·1 = 2 ≠ 0.

Two proper two-colorings exist, so `k = 2` is not a root. The universal root for any graph with an
edge is `k = 1` (`P(G, 1) = 0`). This counterexample is formalized as `bipartite_root_claim_false`
(`chromVal (K_2) 2 = 2`), and the intended "two emotions are trivial" phenomenon is re-encoded as
the emotional floor `emoChrom ≥ 3`.

## 4. Six-emotion window

For any network colorable with the six basic emotions, `3 ≤ emoChrom G ≤ 6`
(`emotionally_consistent`). Empirically most sparse social networks have small chromatic number, so
they fall inside this window; only large cliques (`K_7` and beyond) escape it.

**Conclusion.** The computational landscape supports `emoChrom = max(χ, 3)`, confirms the clique and
cycle formulas, and refutes the bipartite-root folklore. We proceeded to formal proof on this basis.
