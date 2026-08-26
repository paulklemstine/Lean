# Computational Evidence — Kernel patterns and the Bell numbers

All numbers below were produced inside Lean with `#eval` on the actual
definitions used in the formal development
(`Catalog/Geometry/KernelPatterns/`), so the evidence and the theorems talk
about the same objects.  Every claim that ended up in a `.lean` file is proved
there; the tables in this file are exploration, not verification.

## 1. Small-case calculations

`pat x : Fin n → Fin n` sends an index to the least index carrying the same
value; `patterns n m` is the finset of patterns realised by tuples
`Fin n → Fin m`.

| n | `#(patterns n n)` (evaluated) |
|---|-------------------------------|
| 0 | 1 |
| 1 | 1 |
| 2 | 2 |
| 3 | 5 |
| 4 | 15 |
| 5 | 52 |

These are the Bell numbers; the `n ≤ 5` rows are theorems
(`card_patterns_zero, …, card_patterns_five`, each closed by `decide`).

Restricting the number of available values gives the partial sums of a
Stirling row (`#(patterns n m) = Σ_{k ≤ m} S(n,k)`):

| (n, m) | `#(patterns n m)` | decomposition |
|--------|-------------------|---------------|
| (4, 2) | 8  | `S(4,1)+S(4,2) = 1+7` |
| (5, 2) | 16 | `1 + 15` |
| (5, 3) | 41 | `1 + 15 + 25` |

and `#(patternsWith 5 3) = 25 = Nat.stirlingSecond 5 3` (evaluated, and proved
in general by `card_patternsWith_eq_stirlingSecond`).

## 2. OEIS

* `1, 1, 2, 5, 15, 52, …` — **A000110** (Bell numbers), the total pattern
  counts.
* The refined counts `#(patternsWith n k)` reproduce the triangle **A008277**
  (Stirling numbers of the second kind): row `n = 5` is `1, 15, 25, 10, 1`.

## 3. Counterexample hunt

Two universal claims were stress-tested before formalisation.

* *"Equal kernel ⟹ same `Sym(X)`-orbit"* — searched for a failure over small
  finite `X`; none exists, and the general proof
  (`exists_perm_of_pat_eq`) explains why: over a **finite** value type the two
  complements have equal cardinality, so a partial bijection between the value
  ranges always extends to a permutation.  Over an *infinite* value type the
  same argument works, but the statement genuinely fails for a **proper**
  subgroup: with the trivial subgroup of `Sym(Fin 2)` the one-element tuples
  `![0]` and `![1]` share a kernel and lie in different orbits.  This is
  recorded as the theorem `pat_not_complete_of_trivial_group` — the hypothesis
  "the full symmetric group" is not decorative.
* *"The number of patterns does not depend on the size of the value set"* —
  false in general (`#(patterns 5 2) = 16 ≠ 52`), true once `n ≤ m`
  (`patterns_stabilise`).  The evidence table in §1 is what pinned down the
  correct hypothesis.

## 4. Geometry check

For the braid arrangement in `ℝ^n`, the flat `braidFlat x` has dimension equal
to the number of blocks: e.g. for `n = 3` the flats have dimensions `3, 2, 2, 2,
1`, summing over the `5` patterns of `Fin 3`.  This is proved in general
(`finrank_braidFlat`) by exhibiting the coordinate isomorphism with functions on
the set of block representatives.

## 5. Cycle 2: faces of the braid arrangement (ordered patterns)

Refining a kernel pattern by the *order* of its blocks gives the **ordered
pattern** `rank v`.  Enumerating the idempotents of `rank` on `Fin n → Fin n`
inside Lean (`decide`, `ordPatterns_eq_filter`) gives

| `n` | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| flats `#(patterns n n)` (Bell, A000110) | 1 | 1 | 2 | 5 | 15 | 52 |
| faces `#(ordPatterns n)` (Fubini, A000670) | 1 | 1 | 3 | 13 | 75 | 541 |
| chambers `Nat.card (chambers n)` (`n !`, A000142) | 1 | 1 | 2 | 6 | 24 | 120 |

The face row for `n ≤ 4` is verified by `decide` (`card_ordPatterns_zero` …
`card_ordPatterns_four`); the `n = 5` entry `541` is *not* obtained by brute
force (the search space `5^5·` idempotency test is still small, but the kernel
enumeration is slow) — it is derived from the proved general formula
`card_ordPatterns_eq_sum_stirlingSecond`, i.e. `∑_k S(5,k)·k! = 1+30+150+240+120
= 541`, and cross-checked against `fubini_values`.

**Pattern extracted.**  Row 2 = Σ_k S(n,k)·k! and row 1 = Σ_k S(n,k): the two
generating identities differ exactly by the `k!` orderings of the blocks.  This
observation is what suggested — and is now proved by —
`card_fibre_ordPatterns`: *every flat with `k` blocks carries exactly `k!`
faces.*  The `k = n` term of the Fubini sum is the chamber row, which is the
content of `card_chambers_le_card_ordPatterns`.
