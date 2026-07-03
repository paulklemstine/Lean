# Computational Evidence — Finite Arity and Filtered-Colimit Preservation

This note records the small-case checks that motivated the three theorems in
`Catalog/Probability/FilteredColimitArity.lean` and their ring corollaries in
`Catalog/Probability/ShearedWittColimit.lean`.

We model a filtered colimit of rings by its concrete incarnation, a **directed
union** `⋃ i, S i` of a monotone family of subsets/subrings. A functor whose
underlying set is a power `R ↦ R^κ` "preserves the colimit" exactly when

```
{ f : κ → A | ∀ k, f k ∈ ⋃ i, S i }   =   ⋃ i, { f : κ → A | ∀ k, f k ∈ S i }.
```

The left-hand side is "every coordinate is a germ"; the right-hand side is "all
coordinates live at one common stage". Equality is preservation.

## 1. The standard exhaustion

Take `A = ℕ` and the monotone directed family `S i = {n | n ≤ i} = Set.Iic i`.
Then `⋃ i, S i = ℕ` and the family is totally ordered, hence directed.

| i | S i (as a set)      |
|---|---------------------|
| 0 | {0}                 |
| 1 | {0,1}               |
| 2 | {0,1,2}             |
| 3 | {0,1,2,3}           |

## 2. Finite arity lifts (evidence for `finite_product_preserves`)

Pick `κ = Fin 3` and the tuple `g = (3, 7, 2)`. Each coordinate is a germ
(`3 ∈ S 3`, `7 ∈ S 7`, `2 ∈ S 2`). The **finite** set of witnessing indices is
`{3, 7, 2}`, whose maximum is `7`; and indeed all coordinates lie in the single
stage `S 7 = {0,…,7}`. So the tuple lifts to stage `7`.

General small-case pattern: for any tuple `g : Fin n → ℕ`, the stage
`M = max over the n coordinates` always works, because there are only finitely
many coordinates to bound. This is precisely the `Finset.exists_le` step in the
proof.

## 3. Infinite arity fails (evidence for `infinite_product_fails`)

Take `κ = ℕ` and the identity sequence `g = id`, i.e. `g k = k`.

* Left-hand side: every coordinate is a germ (`k ∈ S k`), so `id` is in the LHS.
* Right-hand side: membership would require a single `i` with `∀ k, k ≤ i` — but
  `i + 1 ⊄ S i`. No such `i` exists.

So `id` is a witness separating the two sides: the countable power does **not**
commute with the directed union. This is the obstruction that the naive big Witt
functor `R ↦ R^ℕ` runs into.

Counterexample hunt: any *unbounded* sequence works as a witness; every *bounded*
sequence lifts. So the failure set is exactly the unbounded sequences.

## 4. The sheared repair (evidence for `sheared_product_preserves`)

Restrict `κ = ℕ` to sequences eventually equal to a basepoint `b ∈ every S i`
(here `b = 0 ∈ S i` for all `i`). Example: `g = (5, 2, 9, 0, 0, 0, …)`.

* Essential support is `{0,1,2}` (indices before the tail of zeros).
* The finitely many active coordinates `{5,2,9}` are bounded by `9`, so choose
  stage `M = 9`; the zero tail is in `S 9` automatically since `0 ∈ S 9`.
* Hence `g` lifts to stage `9`.

General pattern: an eventually-`b` sequence has finite essential support, so the
same "bound the finitely many active coordinates" argument applies. Shearing (=
keeping only finitely supported coordinates) turns the failing infinite-arity
functor back into a colimit-preserving one.

## 5. Summary table

| Functor shape                | Preserves directed union? | Witness / reason              |
|------------------------------|---------------------------|-------------------------------|
| finite power `R^n` (Wₙ)      | yes                       | `Finset.exists_le` over `n`   |
| countable power `R^ℕ` (big)  | no                        | `id` unbounded                |
| eventually-`b` power (sheared)| yes                      | finite essential support      |

No sequence/OEIS lookup is relevant here — the phenomenon is structural
(finiteness of an index set), not numerical. The three checks above were the
direct precursors of the three formalised theorems.
