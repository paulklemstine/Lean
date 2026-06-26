# Theorem Trace (internal anti-hallucination ledger)

Every named object below is taken **verbatim** from the Phase A Lean output. Prose
files only state results listed here. Items marked *(imported)* are referenced by the
synthesis file but their bodies live in `Catalog/Novelty/SuperspecialK3Symplectic.lean`
(not reproduced in the Phase A excerpt); the prose treats them as named hypotheses /
imported facts, never as results proved in this package.

## File: `Catalog/Novelty/MukaiTameness.lean`

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `mukaiOrders` | def | The list `[960, 384, 288, 192, 192, 72, 72, 48, 168, 360, 120]` of the 11 Mukai maximal symplectic group orders. | yes (table) | yes (Def 1, table) |
| `mukaiLcm` | def | The natural number `40320 = 2^7 · 3^2 · 5 · 7`. | yes | yes (Def 2) |
| `mukaiOrder_dvd_lcm` | theorem | For all `N`, if `N ∈ mukaiOrders` then `N ∣ 40320`. | yes | yes (Thm 1) |
| `mukaiOrder_prime_factor_le_seven` | theorem | For all `N ∈ mukaiOrders`, prime `q`, if `q ∣ N` then `q ≤ 7`. | yes | yes (Thm 2) |
| `mukaiOrder_tame` | theorem | For prime `p` with `11 < p`, and `N ∈ mukaiOrders`, `¬ (p ∣ N)`. | yes (main) | yes (Thm 3, main) |
| `mukaiOrder_coprime` | theorem | For prime `p` with `11 < p`, and `N ∈ mukaiOrders`, `Nat.Coprime p N`. | yes | yes (Cor 1) |

## File: `Catalog/Novelty/SuperspecialK3FullTameness.lean`

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `aut_order_not_dvd_char` | theorem | For field `k` with `CharP k p`, `p` prime, `11 < p`, character `χ : G →* kˣ`, if `Nat.card (symplecticSubgroup χ) ∈ mukaiOrders` then `¬ (p ∣ Nat.card G)`. | yes (synthesis) | yes (Thm 4, main synthesis) |
| `aut_order_coprime_char` | theorem | Same hypotheses; conclusion is the coprimality form (statement truncated in excerpt; treated as the coprime restatement of Thm 4). | yes | yes (Cor 2) |

## Imported names referenced by the synthesis (not proved in this package)

| Lean name | Source | Role |
|---|---|---|
| `symplecticSubgroup χ` *(imported)* | `SuperspecialK3Symplectic` | the kernel `ker χ = G_s` |
| `card_eq_symplectic_mul_index` *(imported)* | `SuperspecialK3Symplectic` | factorisation `#G = #G_s · [G:G_s]` |
| `nonSymplecticIndex_not_dvd_char` *(imported)* | `SuperspecialK3Symplectic` | `p ∤ [G:G_s]` in char `p` |
| `nonSymplectic_isCyclic` *(imported, future dir.)* | `SuperspecialK3Symplectic` | non-symplectic part is cyclic `C_n ↪ kˣ` |
| `noNonTrivialExtension_iff` *(imported, future dir.)* | `SuperspecialK3Symplectic` | rigidity `⇔ n = 1` |

## Rules applied
- No theorem is renamed into a grander claim.
- No result outside this table appears in the prose as "proved".
- The geometric rigidity `[G:G_s] = 1` is stated only as a **conjecture / future direction**, never as a theorem, matching Phase A.
