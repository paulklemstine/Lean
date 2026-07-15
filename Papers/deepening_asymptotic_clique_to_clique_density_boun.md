# Computational Evidence: Arbitrary-Order Clique Shadows

## Small-case calculations

All labelled simple graphs on `n = 3, 4, 5, 6` vertices were exhaustively enumerated. The numbers tested were respectively `8`, `64`, `1,024`, and `32,768`. For every graph, every `s ≤ t`, and every `t ≤ k ≤ n`, the implication

`C(k,t) ≤ k_t(G)  ⇒  C(k,s) ≤ k_s(G)`

held. Thus no counterexample was found among all `33,864` graphs in this range.

| vertices | labelled graphs tested | counterexamples |
|---:|---:|---:|
| 3 | 8 | 0 |
| 4 | 64 | 0 |
| 5 | 1,024 | 0 |
| 6 | 32,768 | 0 |

Complete graphs attain equality simultaneously for all orders: `k_r(K_n)=C(n,r)`. Complete multipartite examples generally exhibit strict loss under the shadow bound, confirming that the finite binomial-threshold theorem is not by itself the sharp continuous Lovász–Simonovits envelope.

## Counterexample hunt

The exhaustive search included empty graphs, complete graphs, stars, cycles, disjoint unions, and every intermediate labelled graph through six vertices. Edge cases `s=0`, `s=t`, and `t=n` were included. No contradiction was found.

## Sequence search

No new integer sequence is introduced: the extremal thresholds are the classical binomial coefficients. Consequently an OEIS lookup would not distinguish the conjecture or add evidence beyond the exact combinatorial interpretation.

## Structural interpretation

The calculations support the deletion experiment: repeatedly deleting vertices from a `t`-clique produces `(t-i)`-cliques. The family reached after `i=t-s` deletions is therefore contained in the family of `s`-cliques. Its cardinality is controlled by the Kruskal–Katona shadow bound, which explains the observed implication.