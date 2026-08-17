# Computational Evidence

All numbers below were produced by brute-force enumeration inside Lean (`#eval` on
`Finset`-based subgroup enumeration: subsets of a finite group containing `1`, closed
under multiplication and inverses; conjugacy classes obtained by imaging each subgroup
under all conjugations and counting distinct orbits). The enumeration script was a
throwaway exploration file; the conclusions it suggested are what the formal Lean files
in `Catalog/Bridges/` actually prove.

**Status of these numbers**: they are computations, not machine-checked theorems, except
where explicitly re-proved in Lean (noted below).

## What is being counted

By the Galois correspondence proved in
`Catalog/Bridges/FundamentalGroupCoveringGalois.lean`
(`nonempty_gEquiv_iff_isConj`), connected coverings of a `K(G,1)` of degree `n` are in
bijection with **conjugacy classes** of index-`n` subgroups of `G`. So:

* `#subgroups of index n` overcounts coverings (equality of subgroups is too fine);
* `#conjugacy classes of index-n subgroups` is the exact count.

## Table

| group `G` | order | # subgroups | index `n` | # subgroups of index `n` | # conj. classes = # coverings |
|---|---|---|---|---|---|
| `V = C₂ × C₂` | 4 | 5 | 2 | 3 | **3** |
| `C₄` | 4 | 3 | 2 | 1 | **1** |
| `S₃` | 6 | 6 | 3 | 3 | **1** |
| `S₃` | 6 | 6 | 2 | 1 | **1** |
| `S₃ × C₂` | 12 | — | 2 | 3 | **3** |
| `C₂ × C₂ × C₂` | 8 | — | 2 | 7 | **7** |
| `D₄` (dihedral of order 8) | 8 | 10 | 2 | 3 | **3** |
| `C₃ × C₃` | 9 | — | 3 | 4 | **4** |

## Readings of the table

1. **`V` row (3 = 3).** The Klein four group has three index-two subgroups and they are
   pairwise non-conjugate (the group is abelian), so the `K(V,1)` has exactly three
   connected double coverings. All three subgroups are cyclic of order two, so all three
   total spaces are `K(C₂,1)`s: **π₁ of the total space distinguishes none of them**.
   *Formally proved*: `klein_three_double_coverings` in
   `Catalog/Bridges/FundamentalGroupCoveringConjugacy.lean` (including the completeness
   statement that every index-two subgroup is one of the three), and
   `fundamentalGroup_not_complete_invariant_for_coverings` in
   `Catalog/Bridges/FundamentalGroupCoveringExamples.lean`.

2. **`S₃`, index 3 row (3 subgroups but only 1 class).** The three point stabilisers are
   distinct but conjugate: a single three-sheeted connected covering. This is the
   counterexample to "subgroups = coverings" over a non-abelian base.
   *Formally proved*: `stab_zero_ne_stab_one`, `stab_one_eq_conj`,
   `s3_coverings_isomorphic` in `FundamentalGroupCoveringConjugacy.lean`.

3. **`C₄` row (1).** A cyclic base has a unique double covering — consistent with the
   circle case `K(ℤ,1)`, where the number of sheets is a *complete* invariant
   (`circle_coverings_classified_by_degree` in
   `Catalog/Bridges/FundamentalGroupCoveringCircle.lean`).

4. **`S₃ × C₂` and `D₄` rows (3 each).** Index-two subgroups are always normal, so
   conjugacy never merges them: the counts of subgroups and of coverings agree even over
   non-abelian bases. This is the computational shadow of the formal statement
   `index_two_gEquiv_iff_eq` (`FundamentalGroupCoveringTwistedPair.lean`).
   For `S₃ × C₂` the three index-two subgroups are `A₃ × C₂ ≅ C₆`, `S₃ × 1 ≅ S₃`, and the
   graph `{(σ, sgn σ)} ≅ S₃`. The last two are **isomorphic but not equal**, hence give
   two non-isomorphic double coverings with homotopy equivalent total spaces over a
   **non-abelian** base. *Formally proved in general*: `twistedPair_theorem` and its
   instance `s3_twistedPair`.

## Counterexample hunt

The universal claim tested was: *"if two connected coverings of a `K(G,1)` have isomorphic
fundamental groups and the same number of sheets, they are isomorphic as coverings."*

Counterexamples found immediately, at the smallest possible size:

* `G = V`, degree 2: three coverings, all with π₁ `≅ C₂` — three pairwise counterexamples.
* `G = C₂³`, degree 2: seven coverings, all with π₁ `≅ C₂ × C₂`.
* `G = S₃ × C₂`, degree 2: two of the three coverings have π₁ `≅ S₃` (non-abelian base).

The claim is therefore false, and false generically: the family
`G ↦ (G × C₂, ker pr₂ vs graph of φ)` produces a counterexample for **every** `G` with a
surjection onto `C₂` (formally: `twistedPair_theorem`).

## Prediction check for the odd-prime conjecture

Conjecture 1 of `FUTURE_DIRECTIONS.md` predicts, for a prime `p`, a count of
`(p^d − 1)/(p − 1)` regular degree-`p` coverings plus one per non-normal conjugacy class.
Tested here:

* `G = S₃`, `p = 3`: `Hom(S₃, C₃) = 0`, predicted `0` regular coverings plus `1`
  non-normal class = `1`; enumerated: **1**. ✔
* `G = C₃ × C₃`, `p = 3`: `d = 2`, predicted `(9 − 1)/2 = 4`, all regular; enumerated:
  **4** subgroups of index three forming **4** conjugacy classes. ✔

## Sequence check

The counts of index-two subgroups above (`1, 3, 7` for `C₄`, `C₂²`, `C₂³`) are the values
`2^r − 1` where `r` is the 2-rank, i.e. the number of nonzero functionals on the
`𝔽₂`-vector space `G/G²`. No OEIS lookup was needed; the pattern is explained exactly by
the formal statement `index_ker_eq_two` plus the fact that an index-two subgroup is the
kernel of a surjection onto `C₂`.

## Why no plots

Every object here is finite and discrete; the tables above carry all the information a
plot would.


## Addendum: degree-three coverings of the torus (now machine-checked)

Index-three subgroups of `ℤ²` were enumerated as kernels of the eight nonzero characters
`χ_{a,b}(m,n) = a·m + b·n mod 3`:

| `(a,b)` | kernel | canonical representative |
| --- | --- | --- |
| `(1,0)`, `(2,0)` | `m ≡ 0` | `TorusL10` |
| `(0,1)`, `(0,2)` | `n ≡ 0` | `TorusL01` |
| `(1,1)`, `(2,2)` | `m + n ≡ 0` | `TorusL11` |
| `(1,2)`, `(2,1)` | `m ≡ n` | `TorusL12` |

Eight characters, four kernels, `8 / (3 − 1) = 4 = σ(3)` — the `(p − 1)`-to-one collapse
predicted by the character count.  Both the collapse (`card_surjective_chars_with_ker`) and
the resulting classification (`torus_four_triple_coverings`, including the fact that each of
the four total spaces is again a torus, via the determinant-three matrices
`[[3,0],[0,1]]`, `[[1,0],[0,3]]`, `[[1,0],[-1,3]]`, `[[1,0],[1,3]]`) are now Lean theorems
rather than enumerations.

## Addendum: the general degree-`n` count for the torus (now a theorem)

Hermite normal form parametrises the index-`n` sublattices of `ℤ²` by pairs `(a, c)` with
`a ∣ n` and `0 ≤ c < a`, the lattice being spanned by `(a,0)` and `(c, n/a)`.  Counting the
pairs gives `∑_{a ∣ n} a = σ(n)`:

| `n` | sublattices, by `a ∣ n` | total `σ(n)` |
| --- | --- | --- |
| 1 | 1 | 1 |
| 2 | 1 + 2 | 3 |
| 3 | 1 + 3 | 4 |
| 4 | 1 + 2 + 4 | 7 |
| 5 | 1 + 5 | 6 |
| 6 | 1 + 2 + 3 + 6 | 12 |
| 7 | 1 + 7 | 8 |
| 8 | 1 + 2 + 4 + 8 | 15 |

The rows `n = 2, 3` reproduce the earlier enumerations, and `n = 4` confirms the
checkpoint `σ(4) = 7` predicted in `FUTURE_DIRECTIONS.md`.  The whole table is now a
consequence of the Lean theorem `card_index_n_subgroups_torus_sigma`
(`Catalog/Bridges/FundamentalGroupCoveringTorusSigma.lean`), with `σ(4) = 7` recorded
separately as `card_index_four_subgroups_torus`; the sequence `1, 3, 4, 7, 6, 12, 8, 15`
is the divisor-sum function `σ₁` (OEIS A000203).

## Addendum: a non-regular covering of prime degree (now machine-checked)

The point stabilisers of `S₃ ⟳ {0,1,2}` have index three and order two, and the three of
them are conjugate but distinct, so none is normal; the normaliser of one of them is
itself.  Consequently the associated three-sheeted covering of a `K(S₃,1)` has trivial
deck group — the extreme opposite of a regular covering, whose deck group would have order
three.  Both facts are now Lean theorems (`stabZero_not_normal`,
`stabZero_self_normalizing`, `s3_triple_covering_deck_trivial` in
`Catalog/Bridges/FundamentalGroupCoveringNonRegular.lean`), together with the general
obstruction `minFac_lt_index_of_not_normal` explaining why `3` had to exceed the smallest
prime factor `2` of `|S₃| = 6`.
