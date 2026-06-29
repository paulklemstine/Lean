# Computational Evidence — Dream Logic Cycle v19c

All claims below were checked with `#eval` against the Lean definitions before
formalisation, then turned into proved theorems.

## 1. Knowledge join `kjoin` (truth/false/both/neither = T/F/B/N)

| ⊕ | N | T | F | B |
|---|---|---|---|---|
| **N** | N | T | F | B |
| **T** | T | T | B | B |
| **F** | F | B | F | B |
| **B** | B | B | B | B |

Unit `N` (neither), absorbing `B` (both); disagreement `T⊕F = B` (a glut).
Commutative, associative, idempotent — verified on all 16 pairs (→ `kjoin_comm`,
`kjoin_assoc`, `kjoin_idem`).

## 2. Evidence accumulation `accumulate` (foldr ⊕ from N)

| evidence `e` | `accumulate e` | `dEntails e` |
|---|---|---|
| `[]` | N | **true** (default accept) |
| `[F]` | F | **false** (retracted!) |
| `[T]` | T | true |
| `[T, F]` | B (glut) | true (no explosion) |
| `[F, F]` | F | false |
| `[T, T, F]` | B | true |

The `[]` → `[F]` transition is the witnessed **non-monotonic retraction**
(`dEntails_nonmonotone`). The `[T,F]` glut row is `contradiction_coexists_no_explosion`.

## 3. Acceptance monotonicity (`designated` under ⊕)

`designated`: N↦F, T↦T, F↦F, B↦T. Going *up* `kle` only ever crosses
`F ↦ B` and `N ↦ T`, both *into* designation; never out. Checked on all
`kle`-comparable pairs → `designated_kmono`. Hence the evidence layer is
monotone and all non-monotonicity is the `N`-default firing.

## 4. Complement vs. negation

For every `x` there is a lattice complement (`x ∧ c = F`, `x ∨ c = T`):
N↔B, T↔F. But De Morgan `neg` fixes B and N, so `B ∧ neg B = B ∧ B = B ≠ F`:
`neg` is **not** the complement (`neg_ne_complement`). This is the algebraic
root of "contradictions coexist".

## OEIS / sequences

No integer sequence is central to this cycle (the structures are the fixed
4-element bilattice and finite truth tables), so an OEIS search is not
applicable. The evidence above is exhaustive over the finite domain.
