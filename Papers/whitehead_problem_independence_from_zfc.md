# THEOREM_TRACE.md (internal)

Source of truth: `Catalog/1e3d4863_retry2_aristotle/Algebra/ProjectiveWhitehead.lean`
(namespace `ProjectiveWhitehead`).

Anti-hallucination note: the *concept* title speaks of full ZFC-independence
(Shelah). The Lean output does **not** prove the independence metatheorem. It
proves the ZFC-provable skeleton: the "easy half" (projective ⇒ Whitehead),
torsion-freeness of projectives, and the torsion obstruction. All prose states
this honestly and frames independence only as background context, never as a
formalized result.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `IsWhiteheadGroup` | def | `A` is Whitehead iff every short exact sequence `0 → ℤ → G → A → 0` of abelian groups admits a ℤ-linear section `s : A → G` with `p ∘ s = id`. | "What is a Whitehead group" section | Definition 1 |
| `isWhiteheadGroup_of_projective` | theorem | Every projective ℤ-module (abelian group) `A` is a Whitehead group. | "The easy half" section | Theorem 1 |
| `Module.IsTorsionFree.of_projective_int` | theorem | Every projective ℤ-module is torsion-free. | "Why no twisting" section | Theorem 2 |
| `not_isWhiteheadGroup_zmod` | theorem | For `n ≥ 2`, `ZMod n` is not a Whitehead group (extension `0 → ℤ →(·n) ℤ → ℤ/n → 0` does not split). | "The obstruction" section | Theorem 3 |

No other theorems are claimed. The future-directions conjectures (Conj 1–4) are
clearly labeled as conjectures / future work, not as proven results.
