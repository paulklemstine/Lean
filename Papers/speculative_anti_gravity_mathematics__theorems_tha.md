# Computational evidence

The main result is structural rather than a conjectured numerical sequence, so only finite sanity checks are relevant.

| Library | Number of theorems | Direct dependency edges | Weights | Positive-weight anti-gravity count (length bound 1) |
|---|---:|---:|---|---:|
| Edgeless | 1 | 0 | `[0]` | 0 |
| Edgeless | 10 | 0 | ten copies of `0` | 0 |
| Chain `t₁ → t₀` | 2 | 1 | `[1, 0]` | 1 |
| Star with ten users of a root | 11 | 10 | `[10, 0, …, 0]` | 1 |

The ten-node edgeless case is encoded and proved in `Bridges/AntiGravityTheorems.lean`; it is a counterexample to an unconditional claim that at least ten percent of every library is anti-gravity when positive weight is required.

No OEIS search was performed: these checks concern arbitrary finite dependency graphs and do not define a canonical integer sequence.

The counterexample hunt immediately finds the whole family of nonempty edgeless libraries. Consequently, density and percentage claims require structural hypotheses. The Lean development proves two such exact sufficient conditions: dependency-cofinality for topological density and a bounded-fiber charging map for a ten-percent lower bound.