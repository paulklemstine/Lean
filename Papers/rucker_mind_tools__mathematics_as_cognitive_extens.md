# Computational Evidence — Mind Tools

This note records the small-case checks that motivated the formal statements in
the `MindTools/` Lean files. The whole development is elementary and finite/
countable in flavour, so the "evidence" is a handful of concrete instances of
the structures involved; each is discharged rigorously in Lean.

## 1. The abstract incompleteness core (Cantor diagonal)

Statements are modelled as `Set ℕ`. A formal system is `Enumerable` when its
theorems are covered by some `e : ℕ → Set ℕ`. The engine is the classical
diagonal: given any `e`, the set

    D(e) = { n | n ∉ e n }

differs from every `e n` (it disagrees at `n`), so `e` is not surjective and
`D(e)` is a statement no enumerable system lists.

Tiny sanity check of the diagonal for a sample `e`:

| n | e n (first bits)      | n ∈ e n ? | n ∈ D(e) ? |
|---|-----------------------|-----------|------------|
| 0 | evens {0,2,4,…}       | yes       | no         |
| 1 | odds  {1,3,5,…}       | yes       | no         |
| 2 | {0,1}                 | no        | yes        |
| 3 | {3,4,5,…}             | yes       | no         |

`D(e)` disagrees with `e n` at index `n` for every `n`, confirming `D(e) ∉ range e`.
Formalized as `enumerable_incomplete` / `complete_not_enumerable`
(via `Function.cantor_surjective`).

## 2. Extending an enumerable system stays enumerable

Given `e` enumerating `B`, prepend a new statement `s`:
`e' 0 = s`, `e' (k+1) = e k`. Then `range e' = insert s (range e)`. So a brain
can always adjoin one new theorem and remain enumerable — the ascending
"mind-tool" step. Formalized as `Enumerable.insert` and
`exists_mindTool_of_enumerable`.

## 3. The hierarchy is NOT a well-order (contrarian check)

**Descending chain.** `tailSystem n` proves exactly `{ {m} | m ≥ n }`:

| n | theorems of tailSystem n              | strictly ⊃ next? |
|---|--------------------------------------|------------------|
| 0 | { {0}, {1}, {2}, {3}, … }            | yes ({0} dropped)|
| 1 | { {1}, {2}, {3}, … }                 | yes ({1} dropped)|
| 2 | { {2}, {3}, … }                      | yes ({2} dropped)|
| 3 | { {3}, … }                           | …                |

Each step strictly loses the statement `{n}`, giving an infinite strictly
decreasing chain `tailSystem 0 ≻ tailSystem 1 ≻ ⋯`. Hence the power order is not
well-founded (`power_order_not_wellFounded`).

**Non-totality.** The systems proving `{∅}` and `{univ}` are incomparable:
`∅ ≠ univ` (e.g. `0 ∈ univ`, `0 ∉ ∅`), so neither theorem set contains the
other (`power_not_total`).

Either failure alone refutes "well-ordered by theorem-power".

## 4. Category-level vs set-level (finite vs infinite)

Problem family `probStmt n = {n}`. A set-level worker who has settled the finite
index set `F` knows `|F|` instances; a category-level theorem settles all of `ℕ`.

| F (solved indices) | # set-level theorems | # category-level theorems |
|--------------------|----------------------|---------------------------|
| ∅                  | 0                    | ∞                         |
| {0,1,2}            | 3                    | ∞                         |
| {0,…,99}           | 100                  | ∞                         |

For every finite `F`, `probStmt '' F ⊊ range probStmt`, and no finite `F`
reproduces `range probStmt` (finite ≠ infinite). Formalized as
`setLevel_ssubset_catLevel`, `catLevel_is_mind_tool`,
`no_finite_setLevel_matches_catLevel`.

## OEIS

No integer sequence is central to the results; the only counts appearing are
`|F|` (trivially the identity) and the cardinality contrast finite-vs-ℵ₀, so no
OEIS lookup is relevant.

## Counterexample hunt

The universal claims we tested and *retained* survived all sampled cases above.
The universal claim we deliberately targeted for refutation — "the mind-tool
hierarchy is well-ordered by theorem-power" — fails already at the smallest
scales (the two-element incomparable pair in §3, and the length-ω descending
chain), and this refutation is what `Hierarchy.lean` proves.
