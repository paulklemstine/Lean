# Theorem Trace (internal anti-hallucination ledger)

Source of truth: `Catalog/Novelty/RandomMatrices/AiryKernel.lean` (with imports
from `Catalog/Novelty/RandomMatrices/AiryODE.lean`). Every claim in ARTICLE.md
and RESEARCH_PAPER.md must map to one of the entries below. No theorem may be
invented or renamed into a grander claim.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `airyKernel` | def | `K(x,y) = (f x · g y − g x · f y)/(x − y)` for `f,g : ℝ→ℝ`, `x,y : ℝ` | "the kernel", Christoffel–Darboux form | Definition 1 |
| `airyKernel_symm` | theorem | For `x ≠ y`: `airyKernel f g x y = airyKernel f g y x` | "symmetry" section | Theorem 1 |
| `airyKernel_diagonal_tendsto` | theorem | If `f,g` solve `y'' = x·y` (via `HasDerivAt` chains `f→f'→f''`, `g→g'→g''`, `f''=x·f`, `g''=x·g`), then `Tendsto (fun y => airyKernel f g x y) (𝓝[≠] x) (𝓝 (-(airyWronskian f f' g g' 0)))` | "removable singularity / flat diagonal" | Theorem 2 |
| `gramKernel` | def | `K(x,y) = ⟪φ x, φ y⟫` for `φ : ℝ → H`, `H` real inner-product space | "projection / wave-map kernel" | Definition 2 |
| `gram_corr_det_nonneg` | theorem | `gramKernel φ x x · gramKernel φ y y − gramKernel φ x y · gramKernel φ y x ≥ 0` | "2×2 positivity = Cauchy–Schwarz" | Theorem 3 |
| `gram_corr_posSemidef` | theorem | `(Matrix.of (fun i j => gramKernel φ (p i) (p j))).PosSemidef` for any `p : Fin n → ℝ` | "n×n positivity" | Theorem 4 |

Imported, used but not restated as own results (from `AiryODE.lean`):
- `airyWronskian f f' g g' x = f x · g' x − g x · f' x` (definition).
- `airyWronskian_const` : the Wronskian of two Airy solutions is constant in `x`.
- `airy_solutions_linearIndep` : referenced only in Future Directions (C2).

Allowed axioms (Phase A report): `propext`, `Classical.choice`, `Quot.sound`.

Notes / guardrails:
- Do NOT claim a numerical value for the Wronskian (e.g. `1/π`); that is a
  *conjecture* (C1), not a proved theorem. Mark it clearly as future work.
- Do NOT claim the converse of `gram_corr_posSemidef` (PSD ⇒ Gram); that is
  conjecture C3.
- The diagonal value is `−W(0)`, a single constant independent of base point;
  this independence is the proved content, not the specific number.
