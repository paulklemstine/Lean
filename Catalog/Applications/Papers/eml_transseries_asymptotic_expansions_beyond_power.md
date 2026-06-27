# THEOREM TRACE (internal — anti-hallucination control)

Every theorem/definition named in ARTICLE.md and RESEARCH_PAPER.md must map to an
actual Lean declaration in the Phase A output. This file records those mappings.

## From `Catalog/EML/Transseries/Field.lean`

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `TransMono` | `Lex (ℤ →₀ ℝ)`, the ordered group of transmonomials | yes | yes (Def 1) |
| `TSeries` | `HahnSeries TransMono ℝ`, the transseries field | yes | yes (Def 2) |
| `mono h a` | `toLex (Finsupp.single (-h) a)` — transmonomial of height `h`, exponent `a` | yes | yes (Def 3) |
| `term h a` | `single (mono h a) 1` — the one-term transseries | yes | yes (Def 4) |
| `mono_lt_mono_of_height` | `h < h' → 0 < a' → mono h a < mono h' a'` | yes | yes (Thm A) |
| `mono_lt_mono_same` | `a < a' → mono h a < mono h a'` | yes | yes (Thm B) |
| `exp_dominates_pow` | `mono 0 a < mono 1 1` for every real `a` | yes | yes (Thm C) |
| `orderTop_term` | `(term h a).orderTop = mono h a` | no | yes |
| `orderTop_mul` | `(x*y).orderTop = x.orderTop + y.orderTop` | no | yes |
| `C_injective` | `ℝ ↪ TSeries` injective | no | yes |

## From `Catalog/EML/Transseries/AsymptoticComparison.lean`

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `AgreeToAllOrders a b` | `∀ g, (g : WithTop TransMono) < (a-b).orderTop` | yes | yes (Def 5) |
| `agreeToAllOrders_iff_eq` | `AgreeToAllOrders a b ↔ a = b` | yes (main) | yes (Thm D) |
| `agreeToAllOrders_equivalence` | it is an equivalence relation | no | yes |
| `isLittleO_pow_exp` | `(x^n) =o[atTop] exp` | yes | yes (Thm E) |
| `isLittleO_expPow_expExp` | `(exp x)^n =o[atTop] exp(exp x)` | yes | yes (Thm F) |

## From `Catalog/EML/Transseries/ExpShift.lean` (featured Phase A output)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `shiftEquiv` | `Equiv.subRight 1` on ℤ, `i ↦ i-1` | no | yes |
| `shift x` | relabel finsupp index by `i ↦ i-1` | yes | yes (Def 6) |
| `shiftHom` | `shift` as `TransMono →+ TransMono` | no | yes |
| `shift_inj` | `shift` injective | no | yes |
| `shift_lt_iff` | `shift x < shift y ↔ x < y` | yes | yes (Thm G) |
| `shiftHom_le_iff` | `shiftHom g ≤ shiftHom g' ↔ g ≤ g'` | no | yes |
| `expShift` | ring hom `TSeries →+* TSeries` | yes | yes (Def 7) |
| `shift_mono` | `shift (mono h a) = mono (h+1) a` | yes | yes (Thm H) |
| `expShift_term` | `expShift (term h a) = term (h+1) a` | yes | yes (Thm I) |
| `expShift_var` | `expShift x = exp x` | yes (headline) | yes (Thm J) |
| `expShift_exp` | `expShift (exp x) = exp(exp x)` (`term 2 1`) | yes | yes |
| `expShift_log` | `expShift (log x) = x` | yes | yes |
| `expShift_C` | `expShift (C r) = C r` | yes | yes (Thm K) |
| `expShift_injective` | `expShift` injective | yes | yes (Thm L) |

## From future directions (`ExpShiftEquiv.lean`, `ExponentLaws.lean`) — only referenced as future work, not stated as proved theorems in the main body.

| Lean name | Role |
|---|---|
| `expShiftEquiv` | exp-substitution is a field automorphism (future-directions text) |
| `exists_exp_tower_gt` | exp-tower cofinal (future-directions text) |
| `pow_var_lt_exp` | no finite power of x dominates exp (future-directions text) |

No theorem is stated in the prose that does not appear above.
