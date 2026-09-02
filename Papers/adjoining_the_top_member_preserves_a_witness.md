# Computational Evidence

All computations below were run inside Lean 4 (`#eval`, compiled evaluation) on the same
definitions used in the formal proofs
(`Catalog/Computation/UnionClosedAdjoinTop.lean`).  Everything that is *claimed as a
theorem* in the Lean files is proved there; the numbers here are the exploratory data that
guided the proofs.  Where a check is reproduced as a kernel-verified statement, the
corresponding theorem name is given.

Notation: `F : Finset (Finset α)` is a family of finite sets, `deg F x` is the number of
members containing `x`, `x` is *abundant* when `|F| ≤ 2 · deg F x`, `adjoinTop F =
insert (F.sup id) F`, and `surplus F x = 2·deg F x − |F| ∈ ℤ`.

## 1. Small-case calculations

Ground set `Fin 3`, all `2^8 = 256` families.

| quantity | value |
|---|---|
| families `F` with `F.sup id ∉ F` (adjoining the top is a real change) | 97 |
| pairs `(F, x)` with `F` nonempty, `x` abundant in `F`, `x` **not** abundant in `adjoinTop F` | **0** |
| pairs `(F, x)` with `x` abundant in `F`, `x` **not** abundant in `adjoinTop F` (no nonemptiness guard) | **3** — exactly `F = ∅` with `x ∈ {0,1,2}` |
| pairs `(F, x)` with `F.sup id ∉ F`, `x ∈ F.sup id`, and `surplus (adjoinTop F) x ≠ surplus F x + 1` | **0** |
| families with `F.sup id ∉ F` and `|F|` odd | 48 (none of them a counterexample) |

Conclusions drawn: the mission claim is true; the parity of `|F|` is *not* an obstruction
(the surplus always moves up by exactly `+1`); the unique failure of the unguarded claim is
the empty family.  Formalised as `census_abundant_adjoinTop`,
`census_empty_is_unique_failure`, `surplus_adjoinTop_of_notMem`,
`abundant_adjoinTop_iff_nonempty`, `not_abundant_adjoinTop_empty`.

## 2. Counting union-closed families (OEIS check)

Number of union-closed families of subsets of an `n`-set (the empty family counts, and
membership of `∅` is unrestricted):

| `n` | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| count | 2 | 4 | 14 | 122 | 4960 |

The sequence `2, 4, 14, 122, 4960` is the enumeration of union-closed families on `n`
labelled elements; it is catalogued in the OEIS (we could not query the OEIS from this
environment, so the identifier is deliberately not asserted here).  The doubling pattern
`2, 4` and the sharp jump to `4960` are a sanity check on the `IsUnionClosed` predicate as
formalised: e.g. for `n = 1` all four subfamilies of `{∅, {0}}` are union-closed, which the
count confirms.

## 3. Counterexample hunt

**(a) Does abundance survive the *whole* union closure?**  Over `Fin 3`, searching all
`(F, x)` with `F` nonempty and `x` abundant in `F`:

* counterexamples for `uclosure F`: **9**
* counterexamples for one pairwise-completion step `pairUnion F`: **the same 9**

so the failure already happens at the first pairwise step.  Encoding each family by
`∑_{A ∈ F} 2^(bitmask A)`, the offending pairs are

```
(154,1) (156,0) (166,2) (180,0) (189,0) (198,2) (210,1) (219,1) (231,2)
```

Decoding `156` with `x = 0` gives `F = {{0,1,2}, {0,1}, {1}, {2}}`: `|F| = 4`,
`deg F 0 = 2` (abundant), while `uclosure F = {{1}, {2}, {1,2}, {0,1}, {0,1,2}}` has
`|F| = 5` and `deg 0 = 2` (not abundant).  Formalised as
`exists_uclosure_destroying_abundance`.

**(b) Adjoining a set that avoids `x`.**  `F = {∅, {0}}`, `A = {1}` over `Fin 2`: `0` is
abundant in `F` but not in `insert A F`.  Formalised as
`exists_insert_destroying_abundance`.

**(c) Frankl on `Fin 3`.**  All `122` union-closed families on `Fin 3` with a nonempty
member have an abundant element; the only nonempty union-closed family on `Fin 3` *without*
one is `{∅}`.  Formalised as `census_frankl_fin3` and `not_abundant_singleton_empty`.

## 4. The local degree ratio (input to cycle 3)

Over all `4960` union-closed families on `Fin 4`, the maximum of `|F| / deg F a` taken over
all `a ∈ A ∈ F` with `|A| = k`:

| `k` = `|A|` | 1 | 2 | 3 | 4 |
|---|---|---|---|---|
| worst ratio `|F| / deg F a` | 2 | 3 | 5 | 9 |
| `2^(k−1) + 1` | 2 | 3 | 5 | 9 |

The exact agreement suggested — before any proof was attempted — that the naive fibre bound
`|F| ≤ 2^k · deg F a` is not optimal and that `2^(k−1) + 1` is the truth.  Both the bound
and its sharpness are now theorems: `card_le_localBound_mul_deg` and
`localBound_is_optimal`, the latter via the extremal family
`insert A (A.erase a).powerset`, which realises the ratio for *every* `k`.

## 5. Reproducing

Each table above can be recomputed by `#eval`-ing the corresponding expression against the
definitions in `Catalog/Computation/UnionClosedAdjoinTop.lean`; the exhaustive `Fin 3`
checks additionally appear as `decide`-verified theorems in that file, so they are re-run by
the Lean kernel at build time.  The `Fin 4` searches in §2 and §4 are exploratory only (the
kernel cannot enumerate `2^16` families within reasonable resources) and are *not* claimed
as theorems; the general statements they suggested are proved for arbitrary ground sets
instead.
