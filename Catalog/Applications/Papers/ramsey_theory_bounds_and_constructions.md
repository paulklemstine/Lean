# Theorem Trace — Ramsey Theory: Bounds and Constructions

Internal anti-hallucination map. Every Lean declaration from the Phase A output
for `Catalog/Applications/Ramsey.lean` is listed with its mathematical statement
and where it is discussed in `ARTICLE.md` (A) and `RESEARCH_PAPER.md` (P).
No result outside this list is claimed as proved.

| Lean name | Statement | A | P |
|---|---|---|---|
| `Arrows` (def) | `Arrows n s t` ⟺ every red/blue colouring of any vertex set of size ≥ n contains a red `s`-clique or a blue `t`-clique | ✓ | ✓ |
| `ArrowsType` (abbrev) | ambient type `SimpleGraph (Fin (s+t))` | — | ✓ |
| `Arrows.mono` | `Arrows n s t → n ≤ n' → Arrows n' s t` | ✓ | ✓ |
| `arrows_step` | `0<m → 0<n → Arrows m s (t+1) → Arrows n (s+1) t → Arrows (m+n) (s+1) (t+1)` | ✓ | ✓ |
| `arrows_one_red` | `Arrows 1 1 b` | — | ✓ |
| `arrows_one_blue` | `Arrows 1 a 1` | — | ✓ |
| `arrows_recursion` | `Arrows ((s+t).choose s) (s+1) (t+1)` | ✓ | ✓ |
| `arrows_binomial_bound` | restatement: `R(s+1,t+1) ≤ C(s+t,s)` | ✓ | ✓ |
| `arrows_three_three` | `Arrows 6 3 3` | ✓ | ✓ |
| `pentagon` (def) | `C₅` on `Fin 5`, adjacency `a+1=b` | ✓ | ✓ |
| `pentagon_no_triangle` | no red triangle in `C₅` | ✓ | ✓ |
| `pentagon_compl_no_triangle` | no blue triangle in `C₅ᶜ` | ✓ | ✓ |
| `not_arrows_five_three_three` | `¬ Arrows 5 3 3` | ✓ | ✓ |
| `ramsey_three_three` | `Arrows 6 3 3 ∧ ¬ Arrows 5 3 3` (R(3,3)=6) | ✓ | ✓ |
| `arrows_two_t` | `Arrows t 2 t` | ✓ | ✓ |
| `not_arrows_two_succ` | `¬ Arrows t 2 (t+1)` | ✓ | ✓ |
| `not_arrows_pred_two_t` | `1 ≤ t → ¬ Arrows (t-1) 2 t` | — | ✓ |
| `ramsey_two_t` | `Arrows t 2 t ∧ ¬ Arrows (t-1) 2 t` (R(2,t)=t) | ✓ | ✓ |
| `Arrows.symm` | `Arrows n s t → Arrows n t s` | ✓ | ✓ |

## NOT proved (must never be claimed as theorems)
- `R(3,4)=9`, `R(4,4)=18` — future directions only.
- Probabilistic / Paley lower bounds — future directions only.
- Hales–Jewett theorem — future directions only.
