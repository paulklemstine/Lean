# THEOREM TRACE (internal anti-hallucination ledger)

Source of truth: `Catalog/Applications/EulerMascheroni/IrrationalityCriterion.lean`
(namespace `EMR`). Every result below is taken verbatim from the Phase A Lean
output. No theorem appears in ARTICLE.md or RESEARCH_PAPER.md that is not listed
here.

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `EMR.irrational_of_int_linear_combo_tendsto_zero` | If `a, b : ℕ → ℤ` satisfy `aₙ + bₙ x ≠ 0` for all `n` and `aₙ + bₙ x → 0`, then `x` is irrational. | "The Rigidity Theorem" / main idea | Theorem 1 (Sufficiency) |
| `EMR.exists_rat_mem_den_ge` | If `x` is irrational, then for every `N` there is a rational `q` with `\|x − q\| < 1/q.den²` and `q.den ≥ N`. | "Dirichlet with unbounded denominators" | Lemma 2 (Unbounded denominators) |
| `EMR.irrational_iff_exists_int_linear_combo_tendsto_zero` | `x` irrational ⇔ there exist integer sequences `a, b` with `aₙ + bₙ x ≠ 0` and `aₙ + bₙ x → 0`. | "The Characterization" | Theorem 3 (Characterization) |
| `EMR.eulerMascheroniConstant_irrational_iff` | `Irrational γ` ⇔ there exist integer sequences `a, b` with `aₙ + bₙ γ ≠ 0` and `aₙ + bₙ γ → 0`. | "Reducing the γ problem" | Theorem 4 (Reduction of the open problem) |

Supporting Mathlib results referenced (not original to this package):
- `Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational` (Dirichlet / Hurwitz infinitude of good approximations).
- `Int.one_le_abs` (a nonzero integer has absolute value ≥ 1).

Related companion results in the wider EulerMascheroni development (named for context only, NOT restated as if original here):
- `EulerMascheroni.gterm`, `EulerMascheroni.hasSum_gterm` (positive series `∑ gterm = γ`).
- `EulerMascheroni.gamma_sub_seq_lt_inv` (the `O(1/n)` approximation bound).

Rules applied:
- No theorem name paraphrased into a grander claim.
- The corollary `eulerMascheroniConstant_irrational_iff` is an honest *reduction*,
  NOT a claim that γ is (ir)rational.
