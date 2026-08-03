# Computational evidence: delayed ReLU and saddle-node model

The formal development uses the explicit scalar two-layer network

\[
G_d(t)=\max(t-d,0)
\]

and the saddle-node normal form

\[
F_\mu(x)=\mu-x^2.
\]

## Small-case calculations

For delay `d = 3`:

| time `t` | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---:|---:|---:|---:|---:|---:|---:|---:|
| `G₃(t)` | 0 | 0 | 0 | 0 | 1 | 2 | 3 |
| generalizes (`0 < G₃(t)`) | no | no | no | no | yes | yes | yes |

Thus this model has a sharp delayed onset at `t = 3`.

Representative saddle-node equilibria (`F_μ(x)=0`) are:

| parameter `μ` | equilibria |
|---:|:---|
| -4 | none |
| -1 | none |
| 0 | `0` |
| 1 | `-1, 1` |
| 4 | `-2, 2` |
| 9 | `-3, 3` |

## OEIS search

No OEIS search is relevant: the claims concern continuous real-valued functions,
not a newly identified integer sequence.

## Counterexample hunt

The network claim was checked algebraically over representative times before,
at, and after the threshold. The bifurcation claim was checked at negative,
zero, and positive parameters as shown above. No counterexample was found.
The Lean file proves the universal real-valued statements, rather than relying
on this finite evidence.

## Shape of the transition

`G_d(t)` is flat at zero for `t ≤ d` and linear with slope one for `t > d`.
For `F_μ`, the equilibrium diagram consists of no real branch for `μ < 0`, a
single coalesced point at `(0,0)`, and branches `x = ±√μ` for `μ > 0`.
