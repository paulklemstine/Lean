# Computational Evidence — Chromatic Sum

The **chromatic sum** `Σ(G)` is the minimum, over proper vertex colourings with
positive integer colours, of the sum of the colours. Below is the small-case
evidence that guided the formal statements in `Defs.lean` and `Dichotomy.lean`.

## 1. Small cases

| Graph `G`            | `|V|` | `|E|` | proper colouring achieving optimum      | `Σ(G)` |
|----------------------|:----:|:----:|-----------------------------------------|:------:|
| edgeless `E₃`        | 3    | 0    | `1,1,1`                                  | 3      |
| single edge `K₂`     | 2    | 1    | `1,2`                                    | 3      |
| triangle `K₃`        | 3    | 3    | `1,2,3`                                  | 6      |
| complete `Kₙ`        | n    | n(n-1)/2 | `1,2,…,n`                            | n(n+1)/2 |
| path `P₃` (= `K₁,₂`) | 3    | 2    | `1,2,1` (ends share colour 1)           | 4      |
| 4-cycle `C₄`         | 4    | 4    | `1,2,1,2`                               | 6      |
| star `K₁,ₖ`          | k+1  | k    | centre `2`, leaves `1`                  | k+2    |

All optima are obtained by finite enumeration over colourings with colours in
`{1,…,|V|}` (colours above `|V|` never help).

## 2. The tempting closed form `Σ(G) = |V| + |E(G)|`

This formula is **exact** for:
* edgeless graphs (`|V| + 0`),
* single edges (`2 + 1 = 3`),
* every complete graph: `n + n(n-1)/2 = n(n+1)/2 = Σ(Kₙ)` ✓.

so it looks plausible. **Counterexample hunt** immediately breaks it:
* `P₃`: `|V| + |E| = 3 + 2 = 5`, but `Σ(P₃) = 4`.  (Formalised as
  `conj_card_add_edges_false`.)
* `C₄`: `|V| + |E| = 8`, but `Σ(C₄) = 6`.
* star `K₁,ₖ`: `|V| + |E| = 2k+1`, but `Σ = k+2` (gap grows linearly).

So the formula fails on the very first non-complete connected graph.

## 3. Greedy / χ-colouring is not optimal for the sum

For `P₃` with centre `1`:
* colouring centre `1`, leaves `2` : sum `1+2+2 = 5` (uses `χ = 2` colours);
* colouring centre `2`, leaves `1` : sum `1+2+1 = 4` (also uses `χ = 2` colours).

Both use the minimum number of colours, yet the sums differ. Hence *minimising
the number of colours does not minimise their sum* — formalised as
`exists_proper_not_minimum`. This is the qualitative gap between the chromatic
number and the chromatic sum that underlies the difficulty of the Chromatic Sum
problem.

## 4. OEIS

The complete-graph values `Σ(Kₙ) = n(n+1)/2` are the triangular numbers
[OEIS A000217](https://oeis.org/A000217): `0, 1, 3, 6, 10, 15, 21, …`.

## Scope note

Complexity-theoretic content (P vs NP-completeness on `H`-free graphs) is *not*
computationally testable at small sizes and is not formalised; see
`FUTURE_DIRECTIONS.md`. The evidence above concerns the combinatorial
invariant `Σ(G)` itself, which is what the Lean development proves about.
