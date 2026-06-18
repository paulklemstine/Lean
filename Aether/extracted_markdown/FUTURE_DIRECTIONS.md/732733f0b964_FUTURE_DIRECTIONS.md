# Future Directions: 𝔽₁ ⟷ Tropical ⟷ Toric

The file `TropicalF1ToricCorrespondence.lean` nails down three rigorously provable faces of
the slogan *"the field with one element is tropical, and tropical geometry is the geometry of
𝔽₁"*: characteristic-one idempotency of the tropical semiring, the 𝔽₁-torus
`Multiplicative ℝ ≃* Tropical ℝ` with its base changes (`ℤ[ℕ^d] = ℤ[x₁,…,x_d]` for affine
space, `ℤ[ℤ] = ℤ[x,x⁻¹]` for `𝔾_m`), and the central counting identity
`χ(X_P) = #vertices(P) = #𝔽₁-points`, proved exactly, shown multiplicative under products,
and instantiated on the simplex (`ℙ^d`, χ = `d+1`) and the cube (`(ℙ^1)^d`, χ = `2^d`). It
builds directly on `TropicalF1Skeleton.lean`, promoting its join-irreducible "𝔽₁-points"
(`TropF1.F1Card`) from a lattice shadow to genuine polytope vertices with a topological
invariant attached.

Below are five testable, falsifiable directions that extend this work.

## 1. The full Dehn–Sommerville / `h`-vector refinement of the Euler count

Our `toricEuler` collapses the orbit stratification to its vertex count because the torus
Euler characteristic `0^k` kills every positive-dimensional orbit. The richer invariant is
the **Poincaré polynomial** of a smooth complete toric variety: `Σ_k h_k t^{2k}`, where the
`h`-vector comes from the `f`-vector of the simple polytope via the
binomial transform `h_k = Σ_i (-1)^{k-i} C(d-i, k-i) f_{i-1}`. The conjecture to formalize is
that for a `ToricFan` whose faces form a *simple* polytope, the specialization
`t = 1` recovers the total Betti sum, while `t = -1` recovers our `toricEuler`, and that the
`h`-vector is symmetric (`h_k = h_{d-k}`, Dehn–Sommerville). **The key insight is** that our
single integer `χ = #vertices` is the `t = -1` shadow of a palindromic generating function
whose palindromy *is* Poincaré duality on the toric variety. **Why now?** We already have a
clean combinatorial `ToricFan` with a working multiplicative Euler theory; upgrading the
constant `torusEuler k = 0^k` to a polynomial `(t^2 - 1)^k`-style weight is a small, local
change that immediately exposes the entire cohomology, and Mathlib now has enough
`Polynomial` and `Finset.sum` machinery to state and test symmetry on the simplex and cube.

## 2. Lattice-point counting and the Ehrhart ⟷ Hilbert-series bridge over 𝔽₁

We counted *vertices* (the `0`-faces). The complementary 𝔽₁-invariant is the count of **all**
lattice points of `P`, which equals the `ℤ`-rank of the degree-1 piece of the base-changed
homogeneous coordinate ring, and whose dilation generating function is the Ehrhart polynomial
`L_P(n)`. Conjecture: for the simplex `Δ^d`, `L_{Δ^d}(n) = C(n+d, d)`, matching
`dim_ℤ (ℤ[ℕ^d])_n`; for the cube, `L(n) = (n+1)^d`; and `χ(X_P)` (our vertex count) is the
leading-coefficient-independent value `L_P(-1)` up to sign (Ehrhart–Macdonald reciprocity).
**The key insight is** that base change `ℤ[M]` turns the *geometric* Ehrhart count of `M` into
the *algebraic* Hilbert function of a graded ring, so the 𝔽₁-cardinality and the toric degree
are literally the same polynomial read in two languages. **Why now?** Our `baseChange_affineSpace`
already identifies `ℤ[ℕ^d]` with `MvPolynomial`, whose graded pieces have known ℤ-bases in
Mathlib (`MvPolynomial.basisMonomials`), so the `n = 1` case (`dim = d`) is provable today and
sets up the inductive Ehrhart statement.

## 3. A categorical equivalence: monoid objects in the tropical semiring vs. 𝔽₁-schemes

The headline conjecture of the concept is an *equivalence of categories* between tropical
schemes over 𝔽₁ and toric/𝔽₁-schemes. A tractable formal core: the category of finitely
generated commutative monoids with the base-change functor `M ↦ AddMonoidAlgebra ℤ M` is
**fully faithful** onto its image of toric coordinate rings, i.e. `M ≃ N` as monoids iff
`ℤ[M] ≃ₐ[ℤ] ℤ[N]` as graded ℤ-algebras (a graded-iso refinement, since the ungraded statement
is false). **The key insight is** that the monoid `M` is recovered from `ℤ[M]` as its set of
*group-like / grading-homogeneous units*, so the functor has a canonical retraction — this is
the precise sense in which "𝔽₁-data = combinatorial skeleton of toric data". **Why now?**
Mathlib's `AddMonoidAlgebra` functoriality (`AddMonoidAlgebra.mapDomainAlgHom`) and our two
base-change `AlgEquiv`s give both the functor and worked examples; the missing piece is the
graded structure, which `MvPolynomial`'s `homogeneousComponent` API now supports.

## 4. Tropical Bézout: vertex/mixed-volume counts as base-changed intersection numbers

Bernstein–Kushnirenko says the number of torus solutions of a generic system equals the
**mixed volume** of its Newton polytopes — the toric/tropical incarnation of Bézout. Conjecture
to formalize at the `ToricFan` level: define a `mixedVolume`-style multilinear count on tuples
of polytopes that (a) reduces to `d! · vol` on the diagonal, (b) is symmetric and multilinear,
and (c) for the simplex tuple returns `∏ degrees`, recovering classical Bézout `χ`-style. Our
`vertexCount_prod` is the degenerate `0`-dimensional shadow of this mixed count. **The key
insight is** that mixed volume is the unique multilinear extension of "lattice-point/vertex
counting", so the same combinatorial bookkeeping that gave `χ = #vertices` gives intersection
numbers once we let several polytopes interact. **Why now?** We have a stable product operation
on `ToricFan` with proven multiplicativity; generalizing from one polytope to a Minkowski-sum
multilinear functional is the natural next algebraic step, and Mathlib's `Finset`-based volume
and `MvPolynomial` resultant tools make the simplex base case checkable.

## 5. Weil-conjecture zeta shadow: `#X(𝔽_q)` as a polynomial whose `q → 1` limit is `χ`

The original motivation for 𝔽₁ is that toric varieties have point counts
`#X_P(𝔽_q) = Σ_{cones} (q-1)^{codim}` that are **polynomials in `q`**, and the 𝔽₁-philosophy
reads `lim_{q→1}` (or the value of a derived invariant at `q = 1`) as the 𝔽₁-cardinality.
Conjecture: define `pointCount P q := Σ_F (q-1)^{dim F}` for a `ToricFan`; then (a)
`pointCount P 1 = #vertices = χ` *exactly* (our theorem is the `q = 1` value, since
`(q-1)^k|_{q=1} = 0^k`), (b) `pointCount` is multiplicative under products, and (c) for the
simplex it equals `1 + q + ⋯ + q^d = #ℙ^d(𝔽_q)` and for the cube `(1+q)^d = #(ℙ^1)^d(𝔽_q)`.
**The key insight is** that our `torusEuler k = 0^k` is literally `(q-1)^k` evaluated at the
𝔽₁ point `q = 1`, so the Euler characteristic and the 𝔽₁-point count are the *same* Weil
polynomial read at `q = 1` — closing the loop back to the Weil conjectures that started the
whole program. **Why now?** This is a direct one-parameter deformation of theorems already
proved in the file: replace the constant `0` by `q - 1` and re-run the identical product and
instance proofs, turning three discharged lemmas into a parametrized family essentially for
free, and giving an honest, machine-checked `q → 1` realization of "the field with one
element".
