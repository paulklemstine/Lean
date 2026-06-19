# THEOREM TRACE (internal anti-hallucination ledger)

Every name below is taken verbatim from the Phase A Lean output:
`Catalog/Shared/PartialSectionGluing.lean` (fully proven) and the Phase A file
`Catalog/Algebra/SheafImputationAlgebra.lean` (which `import`s and extends it).
No theorem is stated in ARTICLE.md / RESEARCH_PAPER.md that is absent here.

## Core definitions (PartialSectionGluing.lean)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `PartialSection` | `PartialSection ι α := ι → Option α` | "a row with holes" | Def. 1 |
| `Support` | `{i | f i ≠ none}` | "the filled cells" | Def. 2 |
| `Compatible` | `∀ i, f i ≠ none → g i ≠ none → f i = g i` | "agree where both filled" | Def. 3 |
| `Extends` | `∀ i, f i ≠ none → g i = f i` | "a completion of" | Def. 4 |
| `glue` | take `f i` if defined else `g i` | "overlay / merge" | Def. 5 |
| `PairwiseCompatible` | `∀ j k, Compatible (s j) (s k)` | "every pair agrees" | Def. 6 |
| `familyGlue` | choice-based merge of a whole family | "merge of all rows" | Def. 7 |

## Algebra file extra definitions (SheafImputationAlgebra.lean)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `emptySection` | `fun _ => none` | "the empty row" | Def. 8 |
| `HasGlobalSection` | `∃ h, ∀ j, Extends h (s j)` | "consistent fill-in exists" | Def. 9 |

## Theorems (PartialSectionGluing.lean — all fully proven)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `glue_apply` | `(glue f g) i = if f i ≠ none then f i else g i` | implicit | Lem. 1 |
| `support_glue_eq_union` | `(glue f g).Support = f.Support ∪ g.Support` | "merging unions the cells" | Prop. 2 |
| `glue_extends_left` | `Extends (glue f g) f` | "merge keeps f" | Lem. 3 |
| `glue_extends_right` | `Compatible f g → Extends (glue f g) g` | "and keeps g if compatible" | Lem. 4 |
| `compatible_iff_exists_common_extension` | `Compatible f g ↔ ∃ h, Extends h f ∧ Extends h g` | **main (pairwise)** | Thm. 5 |
| `restrict_locality` | `Extends f g → Extends g f → f = g` | "locality axiom" | Thm. 6 |
| `glue_unique` | unique global section bounded by support union | **uniqueness** | Thm. 7 |
| `familyGlue_extends` | `PairwiseCompatible s → ∀ j, Extends (familyGlue s) (s j)` | "merge completes all" | Lem. 8 |
| `glue_family_exists` | `PairwiseCompatible s → ∃ h, ∀ j, Extends h (s j)` | **main (family)** | Thm. 9 |

## Theorems (SheafImputationAlgebra.lean — Phase A)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `glue_emptySection_left` | `glue emptySection f = f` | "empty row is unit" | Thm. 10 |
| `glue_emptySection_right` | `glue f emptySection = f` | "empty row is unit" | Thm. 10 |
| `glue_assoc` | `glue (glue f g) h = glue f (glue g h)` | "merging is associative" | Thm. 11 |
| `glue_idem` | `glue f f = f` | "merging twice = once" | Thm. 12 |
| `glue_band_left` | `glue (glue f g) f = glue f g` | "left-regular band law" | Thm. 13 |
| `glue_band_right` | `glue f (glue g f) = glue f g` | "left-regular band law" | Thm. 13 |

## Conjectural / modeling content (NOT proven in shown Lean)

- `P(sheaf) = (1-r)^{C(n,k)}` and the names
  `consistencyProb_antitone_columns`, `consistencyProb_tendsto_zero`
  are referenced in Phase A future directions for a probability file that is
  NOT part of the shown Lean output. These are presented strictly as a
  **probabilistic model / conjecture** and confined to the "model" and
  "future work" sections — never asserted as proven theorems.
