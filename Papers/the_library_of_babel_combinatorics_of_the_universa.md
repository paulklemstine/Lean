# THEOREM TRACE (internal — anti-hallucination)

Every result stated in `ARTICLE.md` and `RESEARCH_PAPER.md` maps to a concrete
Lean declaration in the Phase A output. No theorem is invented or renamed into a
grander claim.

## `Catalog/Bridges/BabelDeBruijnCatalog.lean` (namespace `BabelDeBruijn`)

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `cat` (def) | The de Bruijn word `B(4,2)`: `cat : Fin 16 → Fin 4 = [0,0,1,0,2,0,3,1,1,2,1,3,2,2,3,3]` | §"A single magic volume" | Def. 4 |
| `window` (def) | `window i = (cat i, cat (i+1))`, indices mod 16 | §"A single magic volume" | Def. 5 |
| `window_bijective` | `Function.Bijective window` (`window : Fin 16 → Fin 4 × Fin 4`) | §"A single magic volume" | Thm. 6 |
| `every_address_once` | `∀ p, ∃! i, window i = p` | §"A single magic volume" | Cor. 7 |
| `catalog_complete` | `∀ p, ∃ i, window i = p` | §"A single magic volume" | Cor. 8 |
| `catalog_no_repeats` | `Function.Injective window` | §"A single magic volume" | Cor. 9 |

## `Catalog/Bridges/BabelDiagonalCatalog.lean`

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `no_single_complete_catalog` | No injection from `Finset (Volume b L)` into a single `Volume b L`; equivalently `b^L < 2^(b^L)` | §"The diagonal wall" | Thm. 10 |
| `distributed_catalog_iff` | An injection `Finset (Volume b L) ↪ (Fin N → Volume b L)` exists **iff** `2^(b^L) ≤ (b^L)^N` | §"Many volumes, one index" | Thm. 11 |
| `single_volume_below_threshold` | The `N = 1` instance of the threshold never holds | §"The diagonal wall" | Cor. 12 |

## `Catalog/Algebra/LibraryOfBabel.lean` + `LibraryOfBabelProbability.lean` (namespace `LibraryOfBabel`)

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `card_volume` / `card_library` | `Fintype.card (Volume n) = 25^n`; `(Library b L).card = b^L` | §"Counting the unthinkable" | Thm. 1 |
| `universalCatalog` (+ `_apply_symm_apply`) | A bijection enumerating all volumes (encode/decode correct) | §"Counting the unthinkable" | Thm. 2 |
| `prob_singleton` / `countingProb_singleton` | A fixed target volume has probability `b^(-L)` | §"The odds of meaning" | Thm. 3 |
| `expected_substring_count` | Expected occurrences of a length-`k` pattern in a length-`L` book `= (L-k+1)·b^(-k)` | §"The odds of meaning" | Thm. 3a |
| `prob_contains_substring_bound` | `P(book contains pattern) ≤ (L-k+1)·b^(-k)` | §"The odds of meaning" | Thm. 3b |

Note: `Catalog/Bridges/BabelIncompressibility.lean` is referenced in Phase A
future directions (FD-3) but its individual theorem statements were not included
in the Phase A excerpt; therefore the prose does not state named theorems from
that file beyond the incompressibility *idea* attributed to future work.
