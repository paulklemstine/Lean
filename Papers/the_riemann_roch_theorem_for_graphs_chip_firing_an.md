# Computational Evidence: Complete Graphs and the Canonical Divisor

For the loopless complete graph `K_n`, each vertex has valency `n-1`. Under the standard Baker–Norine convention,

- `K(v) = val(v) - 2 = n - 3`,
- `deg(K) = n(n-3)`,
- `g = |E|-|V|+1 = (n-1)(n-2)/2`, and
- Riemann–Roch at `D=K`, together with `r(0)=0`, predicts `r(K)=g-1`.

## Small-case calculations

| Graph | Vertex valency | `K(v)` | `deg(K)` | Genus `g` | Predicted `r(K)` |
|---|---:|---:|---:|---:|---:|
| `K_3` | 2 | 0 | 0 | 1 | 0 |
| `K_4` | 3 | 1 | 4 | 3 | 2 |
| `K_5` | 4 | 2 | 10 | 6 | 5 |
| `K_6` | 5 | 3 | 18 | 10 | 9 |

The identities `deg(K)=2g-2` hold respectively as `0=0`, `4=4`, `10=10`, and `18=18`.

## Sequence identification

The genus sequence for `K_n` is the shifted triangular-number sequence

`0, 0, 1, 3, 6, 10, 15, ...`,

corresponding to OEIS A000217 after an index shift. The canonical-rank sequence for `n ≥ 3` is

`0, 2, 5, 9, 14, ... = g(K_n)-1`.

## Counterexample hunt and diagnosis

The proposed coefficient `n-2` fails immediately under the standard canonical-divisor definition. For `K_3`, it would assign one chip to every vertex and degree `3`, contradicting the universal identity `deg(K)=2g-2=0`. The correct coefficient is `n-3`.

The apparent conclusion `r(K)=0` for every complete graph also fails because the substitution omitted `deg(K)=2g-2`. The right-hand side is

`(2g-2)+1-g+r(0)=g-1`,

not zero. A second possible source of confusion is notation: Baker–Norine rank satisfies `r(0)=0`, whereas the dimension normalization `ℓ(D)=r(D)+1` satisfies `ℓ(0)=1`.

## Representative checks

The formulas were checked symbolically for arbitrary positive `n` and instantiated at `n=3,4,5,6`. No counterexample occurs after correcting the canonical coefficient and keeping rank distinct from dimension. The numerical rank entries are conditional on the Riemann–Roch identity; all other columns follow directly from the complete-graph definitions.
