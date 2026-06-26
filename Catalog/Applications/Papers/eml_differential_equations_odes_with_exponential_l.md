# THEOREM TRACE (internal anti-hallucination ledger)

Source of truth: `Catalog/EML/EMLAiryRiccati.lean` (Phase A new file) and the
catalog file `Catalog/EML/EMLDiffObstruction.lean`. Only the names below may be
stated as proved results; no result outside this list may be claimed.

## EMLAiryRiccati.lean

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `natDegree_wronskianLike_le` | For `p, q ∈ ℝ[X]`: `deg(p′·q − p·q′) ≤ deg p + deg q − 1`. | "the cross term drops a degree" (Lemma, plain language) | Lemma 1 (full statement + proof sketch) |
| `no_rational_solves_riccati_odd_deg` | For `f, p, q ∈ ℝ[X]`, `q ≠ 0`, `deg f` odd: the cleared identity `p′q − pq′ + p² = f·q²` is impossible. Equivalently `v′ + v² = f` has no rational solution. | main theorem, plain language + example | Theorem 2 (full statement + proof sketch) |
| `no_rational_solves_riccati_airy` | Airy case `f = X`: no `p, q` with `q ≠ 0` satisfy `p′q − pq′ + p² = X·q²`; i.e. `v′ + v² = x` has no rational solution. | headline result | Theorem 3 (corollary) |
| `airy_no_poly_and_no_rational_riccati` | Combined first-step obstruction bundling `EMLDiffObstruction.no_poly_solves_airy` with the rational Riccati obstruction. | mentioned as "the combined barrier" | Corollary 4 |

## EMLDiffObstruction.lean (catalog, referenced)

| Lean name | Mathematical statement | Use |
|---|---|---|
| `degree_second_deriv_lt_degree_X_mul` | For `p ≠ 0`: `deg(p″) < deg(X·p)`. | supports `no_poly_solves_airy` |
| `no_poly_solves_airy` | No nonzero `p ∈ ℝ[X]` solves `p″ = X·p`. | polynomial layer (background) |
| `no_poly_solves_second_order_pos_deg` | For `deg q ≥ 1`, `p ≠ 0`: `p″ = q·p` impossible. | general polynomial obstruction |
| `poly_wronskian_derivative_zero` | If `f″ = q·f`, `g″ = q·g` then `(f·g′ − g·f′)′ = 0`. | Wronskian/Abel identity (background) |
| `no_poly_solves_riccati_airy` | No `p ∈ ℝ[X]` solves `p′ + p² = X`. | polynomial Riccati layer |
| `no_poly_solves_gen_airy` | For `n ≥ 1`, `p ≠ 0`: `p″ = Xⁿ·p` impossible. | generalized Airy family |
| `polyWronskian` (def) | `W(f,g) = f·g′ − g·f′`. | definition |

NOTE: do NOT claim full differential Galois group computations, Kovacic
algorithm termination proofs, or algebraic (non-rational) obstruction — those
are listed only as Future Directions, not proved.
