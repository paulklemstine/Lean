# Theorem Trace (internal anti-hallucination ledger)

This package concerns the **Euler–Mascheroni constant γ** (concept title:
"Euler-Mascheroni Constant: Irrationality Approaches", domain: MachineLearning).

The Lean output block pasted into the Phase A prompt was a *mismatched* file
(a Hodge–Deligne E-polynomial file). It is unrelated to this concept and is
**not** used here. The genuine Phase A artifacts for this cycle are the γ
theorems explicitly named in the Phase A "Future Directions" block, which are
the source of truth for every claim packaged below. No theorem is stated in
the prose that is not in this ledger.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `eulerMascheroniConstant` | def | `γ := lim_{n→∞} (H_n − log n)`, the common limit of the two monotone auxiliary sequences | yes (γ defined) | yes (Def. 1) |
| `eulerMascheroniSeq` | def | `a_n := H_n − log(n+1)`, increasing, converging up to γ | yes (lower fence) | yes (Def. 2) |
| `eulerMascheroniSeq'` | def | `b_n := H_n − log n`, decreasing, converging down to γ | yes (upper fence) | yes (Def. 2) |
| `abs_harmonic_sub_log_sub_gamma_lt` | thm | `∀ n ≥ 1, |H_n − log n − γ| < 1/n` | yes (Main Thm A) | yes (Thm 1) |
| `hasSum_gammaSeries` | thm | `HasSum (fun k => 1/k − log((k+1)/k)) γ`, a positive-term telescoping series | yes (Main Thm B) | yes (Thm 2) |
| `irrational_of_int_linear_forms` | thm | If integers `a_n, b_n` satisfy `b_n>0`, `b_n x − a_n ≠ 0`, `|b_n x − a_n| → 0`, then `x` is irrational | yes (Main Thm C) | yes (Thm 3) |

Honesty constraints respected:
- γ is **not** claimed to be proved irrational (that is open). Theorem 3 is a
  one-way *criterion*; the package presents it as the toolkit for irrationality,
  not a proof of γ's irrationality.
- The approximation theorem is stated as an absolute bound `< 1/n`; the sharper
  one-sided `1/(2n)` form is listed only under Future Directions as a conjecture.
