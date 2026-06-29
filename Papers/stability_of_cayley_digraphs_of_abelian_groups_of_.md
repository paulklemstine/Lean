# Theorem Trace — Stability of Cayley Digraphs of Abelian Groups of Odd Order

Internal anti-hallucination ledger. Every named object below is taken verbatim
from the Phase A Lean output. Prose in `ARTICLE.md` and `RESEARCH_PAPER.md`
states only these objects; no result is invented or renamed into a grander claim.

## File: `Catalog/Applications/CayleyStability/Embedding.lean`

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `cayAdj` | def | `cayAdj S g h := h - g ∈ S`. Arc `g → h` in `Cay(G,S)` iff `h - g ∈ S`. | "The Cayley digraph" section | Def. 1 |
| `dcAdj` | def | `dcAdj S p q := (q.1 - p.1 ∈ S) ∧ (p.2 ≠ q.2)`. Arc `(g,a) → (h,b)` in the double cover iff `h - g ∈ S` and `a ≠ b`. | "Doubling" section | Def. 2 |
| `AutRel` | def | For `r : V → V → Prop`, `AutRel r` is the subgroup of `Equiv.Perm V` of permutations `σ` with `∀ a b, r (σ a) (σ b) ↔ r a b`. | "Symmetries" section | Def. 3 |
| `mem_AutRel` | simp lemma | `σ ∈ AutRel r ↔ ∀ a b, r (σ a) (σ b) ↔ r a b`. | (implicit) | Def. 3 remark |
| `prodCongr_mem` | lemma | If `σ ∈ AutRel (cayAdj S)` then `σ.prodCongr π ∈ AutRel (dcAdj S)` for any `π : Perm Bool`. | "Expected symmetries" section | Lemma 4 |
| `expectedHom` | def | Group hom `(AutRel (cayAdj S)) × (Perm Bool) →* AutRel (dcAdj S)`, `(σ,π) ↦ σ ×ₚ π`. | "Expected symmetries" section | Def. 5 |
| `expectedHom_injective` | theorem | `Function.Injective (expectedHom S)` for every `G`, `S`. | Main theorem (plain language + example) | Thm. 6 (full statement + proof sketch) |
| `boolEquivZMod2` | def | `Bool ≃ ZMod 2`, `false ↦ 0`, `true ↦ 1`. | "Double cover is Cayley" section | Def. 7 |
| `dcConn` | def | `dcConn S := {p : G × ZMod 2 | p.1 ∈ S ∧ p.2 = 1}`. | "Double cover is Cayley" section | Def. 7 |
| `dcCayleyIso` | def | An equiv `f : (G × Bool) ≃ (G × ZMod 2)` with `∀ p q, dcAdj S p q ↔ cayAdj (dcConn S) (f p) (f q)`. | "Double cover is Cayley" section | Thm. 8 (proof sketch) |

## File: `Catalog/Applications/CayleyStability/OddOrderNecessity.lean`

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `odd_no_involution` | theorem/lemma | In a finite abelian group of odd order, `g + g = 0 → g = 0` (no nontrivial involutions). | "Why odd order" section | Thm. 9 (proof sketch) |
| `TwinFree` | def (named) | The twin-free hypothesis on a Cayley digraph (named in the file/critique). Described, not over-claimed. | "Why odd order" section | Discussion |
| `tau` | def (named) | The explicit layer-mixing transposition witnessing instability in the even-order case. Described, not over-claimed. | "Why odd order" section | Discussion |

Notes:
- The hard half — surjectivity of `expectedHom` (i.e. full stability) — is NOT
  claimed as proved. It is the central open conjecture. Prose states this
  honestly.
- `OddOrderNecessity.lean` is truncated in the Phase A output; only
  `odd_no_involution` has a confirmed full statement. `TwinFree` and `tau`
  are referenced at the level the source provides, without inventing statements.
