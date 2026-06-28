# Theorem Trace (internal anti-hallucination ledger)

Every theorem/lemma/definition below is extracted verbatim from the Phase A Lean
output and the supporting EML catalog files. Prose in ARTICLE.md and
RESEARCH_PAPER.md is restricted to these statements.

## Catalog/EML/QuadraticApproxRate.lean (supporting)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `emlQuadApprox` (def) | `emlQuadApprox h x = (2/h²)·(exp(h·x) − 1 − h·x)` | yes | yes |
| `exp_sub_quadratic_le` | `u∈[0,1] ⇒ |exp u − (1+u+u²/2)| ≤ (2/9)u³` | — | yes |
| `emlQuadApprox_error` | `0<h≤1, x∈[0,1] ⇒ |emlQuadApprox h x − x²| ≤ (4/9)h` | yes | yes |
| `emlQuadApprox_rate` | `1≤n, x∈[0,1] ⇒ |emlQuadApprox (1/n) x − x²| ≤ 4/(9n)` | yes | yes |
| `emlQuadApprox_tendsto` | `x∈[0,1] ⇒ emlQuadApprox (1/n) x → x²` | — | yes |

## Catalog/EML/CubicApproxRate.lean (Phase A)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `emlCubicApprox` (def) | `emlCubicApprox h x = (6/h³)·(exp(h·x) − 1 − h·x − (h·x)²/2)` | yes | yes |
| `exp_sub_cubic_le` | `u∈[0,1] ⇒ |exp u − (1+u+u²/2+u³/6)| ≤ (5/96)u⁴` | — | yes |
| `emlCubicApprox_error` | `0<h≤1, x∈[0,1] ⇒ |emlCubicApprox h x − x³| ≤ (5/16)h` | yes | yes |
| `emlCubicApprox_rate` | `1≤n, x∈[0,1] ⇒ |emlCubicApprox (1/n) x − x³| ≤ 5/(16n)` | yes | yes |
| `emlCubicApprox_tendsto` | `x∈[0,1] ⇒ emlCubicApprox (1/n) x → x³` | — | yes |

## Catalog/EML/QuadraticApproxLowerBound.lean (Phase A)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `exp_ge_cubic` | `0≤h ⇒ 1+h+h²/2+h³/6 ≤ exp h` | — | yes |
| `emlQuadApprox_lower` | `0<h ⇒ h/3 ≤ emlQuadApprox h 1 − 1²` | yes | yes |
| `emlQuadApprox_error_Theta` | `at x=1: h/3 ≤ error ≤ (4/9)h` | yes | yes |
| `emlQuadApprox_rate_lower` | `width-n: 1/(3n) ≤ emlQuadApprox (1/n) 1 − 1` | yes | yes |
| `emlQuadApprox_not_o` | error at x=1 never beats the linear rate (not o(h)) | yes | yes |

## Catalog/EML/MonotoneSeparation.lean (supporting)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `emlSep` (def) | `emlSep a b c t = exp a · log(b·t + c)` | yes | yes |
| `emlSep_strictMonoOn` | `b>0 ⇒ emlSep a b c strictly increasing on {0<b·t+c}` | yes | yes |
| `emlSep_separates` | `b>0, args positive, x≠y ⇒ emlSep a b c x ≠ emlSep a b c y` | yes | yes |
| `emlSep_separates_Icc` | on `[lo,hi]` with `a=0,b=1,c=1−lo`, separates | — | yes |
| `emlSepCM` (def) | `t ↦ log(t + 1 − lo)` as element of `C([lo,hi],ℝ)` | — | yes |
| `emlSepCM_separatesPoints` | adjoin of single EML fn separates points of `[lo,hi]` | yes | yes |
| `eml_adjoin_dense_on_Icc` | adjoin closure = ⊤, i.e. dense in `C([lo,hi],ℝ)` | yes | yes |

## Catalog/EML/StoneWeierstrassApprox.lean (supporting)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `eml_topologicalClosure_eq_top_of_separatesPoints` | separating subalgebra is dense | yes | yes |
| `eml_exists_uniform_approx` | ε-approx by a separating subalgebra | — | yes |
| `eml_universalApproximation` | abstract EML universal approximation | yes | yes |
| `eml_pullback_universalApproximation` | pullback along injective φ is dense | — | yes |

Forbidden: no theorem may be renamed into a grander claim; no result stated that
is absent above.
