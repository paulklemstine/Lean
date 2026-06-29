# THEOREM TRACE (internal anti-hallucination ledger)

Every result below is taken verbatim (in meaning) from the Phase A Lean output
in `BettiWhittakerPeriods.lean` (core) and `BettiWhittakerFunctionalEquation.lean`
(functional equation). No theorem is invented; no name is paraphrased into a
grander claim. Notation: `Weight n := Fin n → ℤ`,
`e(λ) := periodExp λ = Σ_i (2i+1-n)·λ_i`, `(λ^∨)_i := -λ_{n-1-i}` (`dual`).

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `Weight` (def) | `Weight n = (Fin n → ℤ)`; the highest weight / infinitesimal character. | §"The cast of characters" | Def. 1 |
| `dual` (def) | `(λ^∨)_i = -λ_{n-1-i}`: negate-and-reverse the weight. | §"Mirror, mirror" | Def. 2 |
| `periodExp` (def) | `e(λ) = Σ_{i=0}^{n-1} (2i+1-n)·λ_i`: centered period exponent (the `2πi`-content). | §"A single number" | Def. 3 |
| `twist` (def) | `(twist k λ)_i = λ_i + k`: twist by `|det|^k`, a uniform shift. | §"Twisting the dial" | Def. 4 |
| `Regular` (def) | `Regular λ ⇔ StrictAnti λ`: weight strictly decreasing (strict dominance). | §"Dropping the fine print" | Def. 5 |
| `dual_involutive` | `(λ^∨)^∨ = λ`. | §"Mirror, mirror" | Prop. 1 |
| `dual_purity` | purity weight negates: `p(λ^∨) = -p(λ)` where `p_i = λ_i + λ_{n-1-i}`. | §"Self-dual harmony" | Prop. 2 |
| `sum_dual` | `Σ_i (λ^∨)_i = -Σ_i λ_i`. | §"Mirror, mirror" | Prop. 3 |
| `periodExp_dual` | `e(λ^∨) = e(λ)`: period exponent is contragredient-invariant. **Main A.** | §"A single number" | Thm. 1 |
| `dual_eq_self_iff` | `λ^∨ = λ ⇔ ∀ i, λ_i + λ_{n-1-i} = 0` (all purity weights vanish). | §"Self-dual harmony" | Thm. 2 |
| `coeff_sum_zero` | `Σ_{i : Fin n} (2i+1-n) = 0`: balanced Gauss sum. | §"Why centering matters" | Lemma 1 |
| `periodExp_twist` | `e(twist k λ) = e(λ)`: period exponent is twist-invariant. **Main B.** | §"Twisting the dial" | Thm. 3 |
| `bw_functional_equation` | `e((twist k λ)^∨) = e(λ)` for every `k`, every `λ`. **Main (combined).** | §"The functional equation" | Thm. 4 |
| `notRegular_witness` | `¬ Regular (![1,1,0])`. | §"Dropping the fine print" | Prop. 4 |
| `regularityFree_witness` | `¬ Regular (![1,1,0]) ∧ e((![1,1,0])^∨) = e(![1,1,0])`. | §"Dropping the fine print" | Thm. 5 |

Conjectures (Phase A future directions, NOT proved — clearly labelled as open in
both documents): off-center moment `m(λ)=Σ_i i·λ_i` detects regularity;
tensor/box additivity of `e`; free action of the reflection/twist group.
