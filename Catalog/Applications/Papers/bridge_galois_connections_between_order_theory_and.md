# THEOREM TRACE (internal anti-hallucination ledger)

Source: `Catalog/Bridges/GaloisLatticeZariskiBridge.lean`
(namespace `GaloisLatticeZariskiBridge`).

Every claim in ARTICLE.md and RESEARCH_PAPER.md must map to one of these.

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `le_closure` | For a Galois connection `l ⊣ u`, `a ≤ u (l a)` (closure is extensive) | "closure only grows" | Prop. (extensive) |
| `closure_idem` | `u (l (u (l a))) = u (l a)` (closure is idempotent) | "closing twice = closing once" | Prop. (idempotent) |
| `Fix gc` | `{x : α // u (l x) = x}`, the fixed points of `u ∘ l` | "stable elements" | Def. Fix |
| `closed_sInf` | If all `x ∈ S` satisfy `u (l x) = x`, then `u (l (sInf S)) = sInf S` | "intersection of closed is closed" | Lemma (meet-closed) |
| `instInfSet` | `Fix gc` has an `InfSet`: `sInf S` is the ambient infimum | — | Def. inf on Fix |
| `coe_sInf` | `(sInf S : α) = sInf (val '' S)` | — | (coercion lemma) |
| `isGLB_sInf` | `IsGLB S (sInf S)` in `Fix gc` | "greatest lower bound" | Lemma (GLB) |
| `instCompleteLattice` | **Theorem A**: `Fix gc` is a `CompleteLattice` | main theorem A | Theorem A |
| `closure_le_iff` | `u (l a) ≤ x ↔ a ≤ x` for closed `x` | "universal property" | Lemma (adjoint UMP) |
| `coe_sSup` | `(sSup S : α) = u (l (sSup (val '' S)))` (join = re-closed ambient join) | "join must be re-closed" | Prop. (join formula) |
| `zariski_adjunction` | `I ≤ vanishingIdeal S ↔ S ⊆ zeroLocus I` | "the dictionary flips" | Theorem B (adjunction) |
| `zariski_galoisConnection` | `GaloisConnection (zeroLocus) (vanishingIdeal)` into `(Set (Spec R))ᵒᵈ` | "V and I are adjoint" | Theorem B |
| `vanishingIdeal_eq_iInf` | `vanishingIdeal S = ⨅ p ∈ S, p.asIdeal` | "intersection of primes" | (formula) |
| `zariski_closure_eq_radical` | `vanishingIdeal (zeroLocus I) = I.radical` | "closure = radical" | Theorem B (radical) |
| `zariski_fixedPoint_iff_radical` | `vanishingIdeal (zeroLocus I) = I ↔ I.IsRadical` | "fixed points = radical ideals" | Corollary |

No theorem appears in prose that is not in this table.
