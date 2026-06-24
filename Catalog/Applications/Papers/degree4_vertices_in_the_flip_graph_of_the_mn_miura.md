# Theorem Trace — Degree-4 vertices in the flip graph of the m×n Miura-ori

Internal anti-hallucination ledger. Every name below is taken verbatim from the
Phase A Lean file `Catalog/Pythagorean/MiuraFlipDegree.lean`. Prose in
`ARTICLE.md` and `RESEARCH_PAPER.md` must only state these results.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `VertexMV` | abbrev | `Fin 4 → Bool`: a mountain/valley assignment at a degree-4 vertex (`true = mountain`). | "four creases, each a mountain or a valley" | §2 Def 1 |
| `mountains` | def | `mountains a = (univ.filter (fun i => a i = true)).card`: number of mountain creases. | "count the mountains" | §2 Def 2 |
| `GenericValid` | def | `GenericValid a ↔ a 0 ≠ a 1 ∧ a 2 = a 3`: Hull's local characterization of a generic flat-foldable degree-4 vertex. | "the smallest sector forces a disagreement; the rest must agree" | §2 Def 3 |
| `mountains_of_genericValid` | theorem | `GenericValid a → mountains a = 1 ∨ mountains a = 3` (Maekawa, combinatorial form). | "three of one, one of the other" | §3 Thm 1 |
| `card_genericValid` | theorem | `(univ.filter GenericValid).card = 4`: exactly 4 valid MV assignments (Hull's count). | "exactly four ways to fold" | §3 Thm 2 |
| `flipGraph` | def | `SimpleGraph (Fin d → Bool)` with `Adj a b ↔ (univ.filter (fun i => a i ≠ b i)).card = 1`: the Boolean hypercube `Q_d`. | "the flip graph" | §4 Def 4 |
| `flipGraph_adj_iff` | theorem | `(flipGraph d).Adj a b ↔ ∃ i, b = Function.update a i (!a i)`. | "neighbours differ by one flip" | §4 Lem 1 |
| `flipGraph_degree` | theorem | `(flipGraph d).degree a = d`: `Q_d` is `d`-regular. | main theorem, plain language | §4 Thm 3 |
| `flipGraph_degree_four` | theorem | `(flipGraph 4).degree a = 4`: every vertex of `Q_4` has degree 4. | "the headline: degree four everywhere" | §4 Cor 1 |
| `flipGraph_card_edges` | theorem | `(flipGraph d).edgeFinset.card * 2 = d * 2 ^ d`: `Q_d` has `d·2^{d-1}` edges. | "counting the folds" | §4 Thm 4 |
| `flipGraph_connected` | theorem | `(flipGraph d).Connected`: any configuration reaches any other by single flips. | "every folding is reachable" | §4 Thm 5 |

Results referenced in Phase A future directions but NOT present in the visible
Lean file (so they are mentioned only as future/coupled-regime conjectures, never
asserted as proven): `flipGraph_adj_parity`, `flipGraph_card_verts`.
