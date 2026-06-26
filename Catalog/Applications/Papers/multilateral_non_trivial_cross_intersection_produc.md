# Theorem Trace — Multilateral Cross-Intersecting Product Bound

Internal anti-hallucination ledger. Every Lean name below comes from the Phase A
file `Catalog/Novelty/CrossIntersectingProductBound.lean`. No result is stated in
`ARTICLE.md` or `RESEARCH_PAPER.md` that is not on this list.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `IsUniform` | def | `𝓕` is `k`-uniform: every `A ∈ 𝓕` has `|A| = k`. | yes (plain) | yes (Def) |
| `IsStar` | def | `∃ x, ∀ A ∈ 𝓕, x ∈ A` (all members share a point). | yes (plain) | yes (Def) |
| `NonTrivial` | def | `¬ IsStar 𝓕` (not contained in a star). | yes (plain) | yes (Def) |
| `CrossIntersecting` | def | `∀ A ∈ 𝓕, ∀ B ∈ 𝓖, (A ∩ B).Nonempty`. | yes (plain) | yes (Def) |
| `hm` | def | `h(n,k) = C(n-1,k-1) - C(n-k-1,k-1) + 1` (Hilton–Milner value). | yes | yes (Def) |
| `g` | def | `g(n,k) = C(n,k) - C(n-k,k)` (count of `k`-sets meeting a fixed `k`-set). | yes | yes (Def) |
| `crossIntersecting_symm` | lemma | `CrossIntersecting 𝓕 𝓖 → CrossIntersecting 𝓖 𝓕`. | yes (mentioned) | yes (Lemma) |
| `nonTrivial_iff` | lemma | `NonTrivial 𝓕 ↔ ∀ x, ∃ A ∈ 𝓕, x ∉ A`. | yes (mentioned) | yes (Lemma) |
| `card_le_of_cross` | lemma | If `𝓖` is `k`-uniform, `|A₀|=k`, and every `B ∈ 𝓖` meets `A₀`, then `|𝓖| ≤ g(n,k)`. | yes (core) | yes (Lemma) |
| `prod_card_le_pow` | lemma | If `(F i).card ≤ M` for all `i`, then `∏ i, (F i).card ≤ M^r`. | yes (mentioned) | yes (Lemma) |
| `multilateral_cross_product_bound` | theorem | For `r ≥ 2`, non-empty `k`-uniform pairwise cross-intersecting `(F i)`, `∏ i, (F i).card ≤ g(n,k)^r`. | yes (main) | yes (Thm) |
| `bilateral_cross_product_bound` | theorem | Non-empty `k`-uniform cross-intersecting `𝓕,𝓖`: `|𝓕|·|𝓖| ≤ g(n,k)·g(n,k)`. | yes | yes (Cor) |

Numerical anchors used in prose (verified arithmetic):
- `h(6,3) = C(5,2) - C(2,2) + 1 = 10 - 1 + 1 = 10`.
- `g(6,3) = C(6,3) - C(3,3) = 20 - 1 = 19`.
- `C(n,k) = 1` extreme is excluded by non-triviality (the gap `g → h`).

Claims explicitly NOT made (open / not in Lean): the sharp `h(n,k)` bound,
uniqueness of extremizers, the `k ≤ 2` threshold. These appear only in
"Future Directions".
