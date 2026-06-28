# THEOREM TRACE — Equality Cases for the Spectral Radius Bound of Signed Graphs

Internal anti-hallucination map. Every named object below is taken verbatim from
the Phase A Lean source `Catalog/Novelty/SignedGraphSpectralEquality.lean`. No
result appears in ARTICLE.md or RESEARCH_PAPER.md that is not listed here.

## Definitions

| Lean name | Mathematical meaning | Article | Paper |
|---|---|---|---|
| `SignedAdj n` | Structure: real symmetric `n×n` matrix `A` with entries in `{-1,0,1}`, zero diagonal | "signed graph / signed adjacency matrix" | Def. 1 |
| `degree A i` | `∑ j, |A i j|` — absolute row sum = number of incident edges | "degree" | Def. 2 |
| `completePositive n` | `Matrix.of (fun i j => if i = j then 0 else 1)`, the all-positive complete graph `K_n^+` | "complete graph example" | Def. 3 |
| `completePositiveSignedAdj n` | `K_n^+` packaged as a `SignedAdj n` | example | Def. 3 (remark) |

## Theorems

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `eigenvalue_abs_le_maxDeg` | If `A *ᵥ v = μ • v`, `v ≠ 0`, and `∀ i, ∑ j, |A i j| ≤ Δ`, then `|μ| ≤ Δ` | "the Δ-bound" | Thm. 1 |
| `eq_case_degree_saturated` | Under the bound hypotheses with `|μ| = Δ`, a peak vertex `i₀` (with `∀ j, |v j| ≤ |v i₀|`, `0 < |v i₀|`) satisfies `∑ j, |A i₀ j| = Δ` | "degree saturation" | Thm. 2 |
| `eq_case_neighbors_attain_max` | Same hypotheses: `∀ j, A i₀ j ≠ 0 → |v j| = |v i₀|` (peak magnitude propagates to neighbours) | "magnitude propagation" | Thm. 3 |
| `completePositive_realizes_equality` | For `K_n^+`: `completePositive n *ᵥ (fun _ => 1) = ((n:ℝ) - 1) • (fun _ => 1)` and every degree equals `n - 1` | "the bound is sharp" | Thm. 4 |

## Scope notes (faithfulness)

- The **concept framing** mentioned `λ₁(Σ) ≤ √(λ₁²(Σ−v) + 2d(v) − 1)`. The Lean
  file does NOT prove that interlacing/Hong-type inequality. It proves the
  **Δ-bound** `|μ| ≤ Δ` together with its equality cases and a sharp realiser.
  The √(2m − n + 1) Hong-type refinement is listed only as **future work (C3)**.
  Prose must reflect the Δ-bound, not the unproven interlacing statement.
- All four theorems use only `|A i j|` (absolute values), so the bound is a
  statement about the underlying *unsigned* multigraph; the signs only matter for
  which switching class realises equality (future work C2).
