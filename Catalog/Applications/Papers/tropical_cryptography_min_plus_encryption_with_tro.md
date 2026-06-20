# Theorem Trace (internal anti-hallucination ledger)

Source of truth: `Catalog/Tropical/TropicalTDLPEigenAttack.lean`
(namespace `Catalog.Tropical.TropicalTDLPEigenAttack`).

Every claim in ARTICLE.md and RESEARCH_PAPER.md must map to one of the entries below.
No theorem may be renamed into a grander claim; no result outside this list may be stated.

## Definitions

| Lean name | Kind | Mathematical statement | Article | Paper |
|---|---|---|---|---|
| `oneByOneAction` | def | `oneByOneAction lam x = lam + x` (action of 1×1 tropical matrix) | "the one-box machine" | Def. 3.1 |
| `Vec` | abbrev | `Vec ι := ι → Nat` (tropical vector) | "a list of numbers" | Def. 4.1 |
| `tropScalarAdd` | def | `tropScalarAdd c v = fun i => c + v i` (tropical scalar action) | "turning the dial by c" | Def. 4.2 |
| `ScalarEquivariant` | def | `∀ c v, F (tropScalarAdd c v) = tropScalarAdd c (F v)` | "the machine respects the dial" | Def. 4.3 |
| `IsTropicalEigen` | def | `F v = tropScalarAdd lam v` | "an eigenline / fixed direction" | Def. 4.4 |

## Theorems

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `oneByOne_tropical_iterate` | `(fun y => lam + y)^[k] x = k * lam + x` | "k turns add k·λ" | Thm. 3.2 |
| `tdlp_recover_oneByOne` | `(fun y => 1 + y)^[k] x - x = k` | "one subtraction reveals k" | Thm. 3.3 |
| `tropScalarAdd_add` | `tropScalarAdd a (tropScalarAdd b v) = tropScalarAdd (a+b) v` | (implicit) | Lem. 4.5 |
| `iterate_eigenline_attack` | `F^[k] v = tropScalarAdd (k * lam) v` | "the eigenline attack" | Thm. 4.6 |
| `tdlp_recover_eigenline` | `F^[k] v i - v i = k` (when `lam = 1`) | "one coordinate, one subtraction" | Thm. 4.7 |

All statements are over `Nat` (min-plus carrier without `+∞`); subtraction is truncated `Nat` subtraction,
which is exact here because the output dominates the input.
