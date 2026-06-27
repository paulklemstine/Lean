# Theorem Trace — Euler–Mascheroni Midpoint Acceleration

Internal anti-hallucination ledger. Every result discussed in `ARTICLE.md`,
`RESEARCH_PAPER.md`, and `RESEARCH_PAPER.tex` maps to an actual declaration in
the Phase A Lean source
`Catalog/MachineLearning/EulerMascheroni/MidpointAcceleration.lean`. No result
is stated in the prose that is not in this table.

Background facts used (from Mathlib `Mathlib/NumberTheory/Harmonic/EulerMascheroni.lean`):
- `Real.eulerMascheroniConstant` — the constant γ, defined as the limit of `eulerMascheroniSeq`.
- `Real.eulerMascheroniSeq n = harmonic n − log (n+1)` — strictly increasing, converges to γ from below.
- `Real.eulerMascheroniSeq' n = harmonic n − log n` (junk at 0) — strictly decreasing, converges to γ from above.
- `Real.tendsto_eulerMascheroniSeq`, `Real.tendsto_harmonic_sub_log` — convergence facts.

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `EulerMascheroniMidpoint.midpointSeq` (def) | `midpointSeq n = H_n − log(n + 1/2)` | "the midpoint sequence" | Definition 2 |
| `two_mul_lt_log_div` | For `t ∈ (0,1)`: `2t < log((1+t)/(1−t))` | "the engine inequality" | Lemma 1 |
| `midpoint_step` | `1/(n+1) < log(n+3/2) − log(n+1/2)` | "each step shrinks" | Lemma 2 |
| `strictAnti_midpointSeq` | `midpointSeq` is strictly decreasing | "always decreasing" | Theorem 3 |
| `tendsto_midpointSeq` | `midpointSeq → γ` (squeeze) | "lands exactly on γ" | Theorem 4 |
| `eulerMascheroniConstant_lt_midpointSeq` | `γ < midpointSeq n` for all n | "always above γ" | Theorem 5 (main) |
| `eulerMascheroniSeq_lt_midpointSeq` | `eulerMascheroniSeq n < midpointSeq n` | "beats the lower approximant" | Theorem 6 |
| `midpointSeq_sandwich` | `eulerMascheroniSeq n < γ < midpointSeq n` | "the new sandwich" | Theorem 7 |

Notes:
- The numerical rate `midpointSeq n − γ ≈ 1/(24 n²)` is an EXPERIMENTAL observation
  recorded in the Lean lab notes, not a proved theorem. Prose marks it as numerical.
- Identities mentioned only in the Lean docstring (e.g. linking midpoint to the
  classical lower approximant, and `midpointSeq n < eulerMascheroniSeq' n`) are
  discussed qualitatively but never claimed as separate proved theorems beyond the
  table above.
