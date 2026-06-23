# Theorem Trace — Orderly Friedman Numbers (internal, anti-hallucination)

Every name below is taken verbatim from the Phase A Lean source
`Catalog/NumberTheory/OrderlyFriedman.lean`. No other theorems are claimed.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `FOp` | inductive | The operation alphabet `{add, mul, pow}` | yes (operations) | Def. 1 |
| `FExpr` | inductive | Digit expression trees: `lit d`, `neg e`, `bin op l r` | yes (expression trees) | Def. 2 |
| `FOp.apply` | def | `add↦+`, `mul↦×`, `pow↦a^(b.toNat)` | yes | Def. 3 |
| `eval` | def | Integer value of an expression | yes | Def. 4 |
| `digitSeq` | def | Left-to-right list of digit leaves | yes (reading order) | Def. 5 |
| `numLits` | def | Number of digit leaves | yes | Def. 6 |
| `IsOrderlyFriedman` | def | `∃ e, numLits e ≥ 2 ∧ digitSeq e = (digits 10 n).reverse ∧ eval e = n` | yes (main definition) | Def. 7 |
| `IsFriedman` | def | `∃ e, numLits e ≥ 2 ∧ (digitSeq e).Perm (digits 10 n) ∧ eval e = n` | yes | Def. 8 |
| `orderlyFriedman_127` | theorem | `127 = -1 + 2^7` is orderly | yes (worked example) | Thm. 9 |
| `orderlyFriedman_343` | theorem | `343 = (3+4)^3` is orderly | yes | Thm. 9 |
| `orderlyFriedman_736` | theorem | `736 = 7 + 3^6` is orderly | yes | Thm. 9 |
| `orderlyFriedman_1285` | theorem | `1285 = (1 + 2^8)·5` is orderly | yes (correction note) | Thm. 9 |
| `orderlyFriedman_2592` | theorem | `2592 = 2^5 · 9^2` is orderly | yes (headline example) | Thm. 9 |
| `numLits_eq_length` | theorem | `numLits e = (digitSeq e).length` | yes | Thm. 10 |
| `numLits_pos` | theorem | `1 ≤ numLits e` | yes | Lem. 11 |
| `single_leaf` | theorem | one leaf ⇒ `eval e = ±d`, `digitSeq e = [d]` | yes | Thm. 12 |
| `reachable2` | def | values `±((±a) op (±b))` from two ordered digits | yes | Def. 13 |
| `reachable2_of` | theorem | any combination of `±a`, `±b` is reachable | yes | Thm. 14 |
| `reachable2_neg` | theorem | reachable values closed under negation | yes | Lem. 15 |

Notes:
- `1285` informal "`1·2^8+5`" is wrong; the verified reading-order witness is
  `(1 + 2^8)·5 = 257·5 = 1285`. Both documents carry this correction.
- The Lean header lists further goals (`orderlyFriedman_ge_ten`,
  `no_two_digit_orderlyFriedman`, `orderly_imp_friedman`, `digits_in_order`);
  these are described as directions/program, not asserted as proved here, because
  their proof bodies are not in the provided source. Future Directions covers them.
