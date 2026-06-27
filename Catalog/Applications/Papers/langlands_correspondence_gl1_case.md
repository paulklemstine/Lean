# THEOREM TRACE (internal anti-hallucination ledger)

Every claim in ARTICLE.md and RESEARCH_PAPER.md must map to one of the
declarations below, taken verbatim from the Phase A Lean output. No grander
claims, no invented theorems.

## From `Catalog/NumberTheory/GL1Correspondence.lean`

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `LanglandsGL1.artinIso` (def) | Iso `Gal(ℚ(ζₙ)/ℚ) ≃* (ZMod n)ˣ` (cyclotomic Artin reciprocity) | "Artin reciprocity" boxed iso | Def/Thm (Artin iso) |
| `LanglandsGL1.galois_abelian` | `Gal(ℚ(ζₙ)/ℚ)` is abelian: `a*b = b*a` | "Galois group is commutative" | Prop (abelian) |
| `LanglandsGL1.precompMulEquiv` (def) | `(H →* M) ≃* (G →* M)` from `e : G ≃* H` | functoriality remark | Def (precomp) |
| `LanglandsGL1.langlandsGL1` (def) | `DirichletCharacter ℂ n ≃* ((L ≃ₐ[ℚ] L) →* ℂˣ)` | "the same list, perfectly paired" | Main Def/Thm |
| `LanglandsGL1.card_dirichlet_eq_totient` | `Nat.card (DirichletCharacter ℂ n) = φ(n)` | counting section | Thm (count, Hecke) |
| `LanglandsGL1.card_galois_reps_eq_totient` | `Nat.card ((L ≃ₐ[ℚ] L) →* ℂˣ) = φ(n)` | "= φ(n)" punchline | Thm (count, Galois) |
| `LanglandsGL1.card_galois_reps_prime` | for prime `p`: count `= p - 1` | "φ(p) = p-1, Q(ζ₇) has 6" | Cor (prime count) |

## From `Catalog/Applications/Langlands/ExplicitReciprocity.lean`

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `artinIso_eq_galEquivZMod` | catalog Artin map = Mathlib `galEquivZMod` | (implicit, proof note) | Lemma (identification) |
| `artin_action` | `σ(ζₙ) = ζₙ^(artinIso σ)` | "σ(ζₙ)=ζₙ^a" | Thm (explicit action) |
| `langlandsGL1_apply` | `langlandsGL1 D σ = mulEquivToUnitHom D (artinIso σ)` | "compose with Artin map" | Lemma (apply) |
| `langlandsGL1_apply_coe` | `(langlandsGL1 D σ : ℂ) = D(artinIso σ)` | "feed a into D" | Lemma (scalar form) |
| `explicit_reciprocity` | conjunction: `σ(ζₙ)=ζₙ^a` ∧ `ρ_D(σ)=D(a)` | boxed explicit law + n=5 example | Main Thm |
| `langlandsGL1_eq_one_iff` | `langlandsGL1 D = 1 ↔ D = 1` | "zero detector" | Cor (triviality) |

## From `Catalog/Applications/Langlands/IdeleClassGroup.lean`

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `IdeleGroup` (def) | `(AdeleRing R K)ˣ` | "idèle group 𝕀" | Def (idèle group) |
| `ideleDiag` (def) | `Kˣ →* IdeleGroup R K` diagonal | "principal idèles diagonal" | Def (diagonal) |
| `principalIdeles` (def) | `(ideleDiag R K).range` | "principal idèles" | Def (principal) |
| `IdeleClassGroup` (def) | `IdeleGroup ⧸ principalIdeles` | "C_K = 𝕀/Kˣ" | Def (class group) |
| `ideleDiag_injective` | diagonal embedding injective | "embedding is faithful" | Thm (injectivity) |
| `principalIdelesEquiv` | `Kˣ ≃* principalIdeles R K` | "Q^× clean copy" | Cor (copy) |
| `ideleClass_mk_surjective` | class map surjective (`1→Kˣ→𝕀→C→1`) | "exact sequence onto" | Thm (surjectivity) |
| `heckeCharEquiv` | Hecke chars = idèle class characters | "universal property" | Thm (universal property) |

Notes:
- `card_galois_reps_prime` example uses `p=7 ⇒ φ(7)=6`; consistent with statement.
- IdeleClassGroup.lean source was truncated in Phase A at `heckeCharEquiv`
  ("continuous-free finite-order Hecke charac…"); we describe it at the level
  the docstring guarantees and do not overstate the precise hypotheses.
