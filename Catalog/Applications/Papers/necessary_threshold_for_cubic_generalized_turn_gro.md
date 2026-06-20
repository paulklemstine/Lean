# Theorem Trace (internal anti-hallucination ledger)

Source of truth: `Catalog/6d018212_retry2_aristotle/Algebra/MDSUncertainty.lean`.
Every prose claim in ARTICLE.md and RESEARCH_PAPER.md maps to one of the
declarations below. No theorem is invented or renamed into a grander claim.

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `vecSupport` (def) | supp(v) = { i : v i ≠ 0 } | "Counting where a vector lives" | Def 3.1 |
| `vecZeros` (def) | zeros(v) = { i : v i = 0 } | "support…and the positions where f is zero" | Def 3.1 |
| `IsMDS` (def) | ∀ k r c, det(M.submatrix r c) ≠ 0 | "What makes a matrix MDS" | Def 3.2 |
| `SatisfiesUncertainty` (def) | ∀ f≠0, \|supp f\|+\|supp(Mf)\| ≥ bound | headline statement | Def 3.3 |
| `UncertaintyProfile` (struct) | (mat, certifiedBound, bound_valid) | — (not in article) | Def 3.4 |
| `vecSupport_card_add_vecZeros_card` | \|supp v\|+\|zeros v\| = n | "support plus zeros equals n" | Lemma 4.1 |
| `vecSupport_nonempty_of_ne_zero` | v≠0 ⇒ supp v nonempty | implicit | §4.1 |
| `vecSupport_card_pos_of_ne_zero` | v≠0 ⇒ 0 < \|supp v\| | implicit | §4.1 |
| `submatrix_mulVec_of_support` | f supported on range c ⇒ (submatrix·(f∘c))_i = (Mf)_{r i} | "carving" / restriction | Lemma 4.2 |
| `mds_invertible` | IsMDS M ⇒ det M ≠ 0 | "an MDS matrix is invertible" | Thm 4.3 |
| `mds_implies_uncertainty` | IsMDS M, f≠0 ⇒ sum ≥ n+1 | "From MDS to the uncertainty bound" | Thm 5.1 |
| `not_mds_implies_violator` | ¬IsMDS M ⇒ ∃ f≠0, sum ≤ n | "From the uncertainty bound back to MDS" | Thm 5.2 |
| `mds_iff_uncertainty` | IsMDS M ↔ SatisfiesUncertainty M (n+1) | headline equivalence | Thm 6.1 |
| `mds_transpose` | IsMDS M ⇒ IsMDS Mᵀ | "A duality, for free" | Thm 6.2 |
| `singleton_bound` | 0<n, det M≠0 ⇒ ∃ f≠0, sum ≤ n+1 | "The bound is as sharp as it can be" | Thm 6.3 |

Notes:
- The article's worked examples (2×2 Hadamard, [[1,1],[1,1]], 3×3 Vandermonde)
  are illustrations of the above theorems, computed and confirmed in demo.py.
- The DFT-over-𝔽_p / Chebotarev remark and Reed–Solomon / Donoho–Stark context
  are background framing matching the file's own docstring and reference list
  (Donoho–Stark; Tao; MacWilliams–Sloane); no new theorems are asserted.
