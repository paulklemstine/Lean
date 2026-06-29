# Theorem Trace — Pólya Tree Coefficient Recurrence (internal)

This file lists every definition, lemma, and theorem from the Phase A Lean source
`Catalog/Bridges/PolyaTreeRecurrence.lean`, its precise mathematical statement, and
where it is discussed in `ARTICLE.md` and `RESEARCH_PAPER.md`. No result outside this
list is claimed in the prose.

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `omegaSeq` | def | `omegaSeq a n = ∑_{d ∣ n} d · a_d` (the divisor weight `ω_n`) | "The divisor weight" section | Definition 2 |
| `sCoeff` | def | `sCoeff a n = ∑_{i ∣ n} a_{n/i} / i` (the `n`-th coefficient of `S(z)=Σ_{i≥1}A(zⁱ)/i`) | "The hidden series S" section | Definition 3 |
| `divisor_bridge` | theorem | `(n : ℚ) · sCoeff a n = omegaSeq a n` | "The bridge" section (central claim) | Theorem 4 (DB) |
| `feSum_eq_omegaSum` | theorem | `∑_{j=1}^{n-1} a_j · ((n−j)·sCoeff a (n−j)) = ∑_{j=1}^{n-1} a_j · omegaSeq a (n−j)` | mentioned as the bookkeeping step | Lemma 5 |
| `polya_FE_iff_recurrence` | theorem | log-derivative identity `∀ n≥1` ⟺ recurrence `∀ k≥2` | "Two faces of one equation" | Theorem 6 (equivalence) |
| `polya_tree_recurrence` | theorem | If `a₁=1` and the log-derivative identity holds, then `a₁=1` and `∀ k≥2, a_k = (1/(k−1)) ∑_{j=1}^{k-1} a_j · ω_{k−j}` | main result, stated with example | Theorem 7 (main) |

Naming discipline: the article and paper use exactly the four ideas above —
the divisor weight `ω`, the series coefficient `sCoeff`, the divisor bridge,
and the equivalence/recurrence — with no embellished or invented theorem names.
