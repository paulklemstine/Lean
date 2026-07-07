# Computational Evidence — Semicubes, the Helly property, and Cartesian products

We model the hypercube `Q(ι)` over an index set `ι` by taking a vertex to be a finite
set `A : Finset ι` (the coordinates equal to `1`), with Hamming distance
`hdist A B = |A △ B|`. A **semicube** is a coordinate half-space: for a coordinate `i`
and a sign `b`, `semicube i b` is `{A | i ∈ A}` when `b = true` and `{A | i ∉ A}` when
`b = false`. The **opposite** of `semicube i b` is `semicube i (¬b)`.

## 1. Small-case calculations (pairwise vs. global intersection)

Take `ι = Fin 2`. Consider the family of semicubes indexed by
`s = {(0,true), (1,false)}`.

* `semicube 0 true = {A | 0 ∈ A}`.
* `semicube 1 false = {A | 1 ∉ A}`.
* Pairwise intersection: `{A | 0 ∈ A ∧ 1 ∉ A} = {{0}}` — nonempty.
* Global intersection: same set — nonempty. Witness `A = {0}`.

Now add a conflicting pair `s = {(0,true), (0,false)}`.

* `semicube 0 true ∩ semicube 0 false = {A | 0 ∈ A ∧ 0 ∉ A} = ∅`.
* So the family is *not* pairwise intersecting, and indeed has no common vertex.

Pattern observed on all `ι = Fin k` for `k ≤ 4`: a family of semicubes has a common
vertex **iff** no coordinate occurs with both signs **iff** it is pairwise intersecting.
This is the Helly property for semicubes, and the "obstruction" is always a single
opposite pair. (Helly number = 2.)

## 2. Cross-factor pairs in a product

Vertices of `Q(ι) × Q(κ)` are pairs `(A, B) : Finset ι × Finset κ`. A left semicube
constrains only `A`; a right semicube constrains only `B`. For any left semicube `L`
and right semicube `R`, choosing `A` to satisfy `L` and `B` to satisfy `R`
independently gives a point of `L ∩ R`. Hence **every** cross pair intersects, and the
only obstructions to a common vertex live *within a single factor*.

Consequence, verified by hand on `Fin 2 × Fin 2`: a mixed family of product semicubes
has a common vertex iff its left part has a common vertex and its right part has a
common vertex. The product Helly property therefore reduces to the two factors.

## 3. Geodesics (partial-cube / Djoković–Winkler check)

For `ι = Fin 3`, `A = {0,1}`, `B = {1,2}`: `hdist A B = |{0,2}| = 2`. A shortest walk
inside `Q(3)` is `{0,1} → {1} → {1,2}` (delete `0`, insert `2`), length `2 = hdist`.
No shorter walk exists (triangle inequality). This confirms the hypercube is an
isometric (partial-cube) host, the setting for the Djoković–Winkler theory of
Θ-classes and semicubes.

## 4. OEIS

No integer sequence is central to these structural (existence/characterization)
results, so no OEIS lookup applies.

## Conclusion

The computations support three provable statements: (i) semicubes have the Helly
property with Helly number 2, the sole obstruction being an opposite pair;
(ii) the Helly property of a product reduces to that of its factors because cross
pairs are never obstructions; (iii) the hypercube is an isometric host, so semicubes
are genuine Θ-classes in the sense of Djoković and Winkler.
