# Future Directions: Tropical Brill–Noether Theory

The file `Catalog/Tropical/BakerNorineRiemannRoch.lean` builds the divisor and
Picard-group foundations of Baker–Norine graph Riemann–Roch from scratch: the
graph Laplacian, chip-firing / linear equivalence as an equivalence relation,
the invariance of degree under linear equivalence, the canonical degree formula
`deg K = 2g - 2`, and the Riemann–Roch degree duality `deg(K - D) = (2g-2) - deg D`.
What is *not yet* formalized is the rank function `r(D)` and the full
Riemann–Roch identity. The directions below are the natural, falsifiable next
steps; each is stated so that it can be turned into a concrete Lean theorem.

## 1. The Baker–Norine rank function and the full Riemann–Roch identity

Define the effective divisors (`∀ v, D v ≥ 0`), the relation "`D` is equivalent
to an effective divisor", and the Baker–Norine rank
`r(D) = max { k ≥ -1 : ∀ effective E of degree k, D - E ~ effective }`. The
target is `r(D) - r(K - D) = deg D + 1 - g`, where `g = |E| - |V| + 1` for a
connected graph and `K = canonical G`. **The key insight is** that the degree
duality `degree_canonical_sub` already proved here is the "Euler characteristic"
skeleton of the theorem — the remaining content is purely about the *defect*
`r(D) - (deg D - g)`, which Baker–Norine control through `q`-reduced divisors.
**Why now?** The equivalence relation `linEquiv` and the invariant `degree` are
exactly the two ingredients needed to even *state* `r(D)` rigorously, and they
are now available and axiom-clean.

## 2. Uniqueness of `q`-reduced divisors (Dhar's burning algorithm)

For a fixed base vertex `q`, every divisor class contains a unique `q`-reduced
representative, computable by Dhar's burning algorithm. Formalize existence and
uniqueness of the `q`-reduced divisor in each `linEquiv`-class.
**The key insight is** that `q`-reducedness is a *finite* extremality condition on representatives
within a class, so uniqueness becomes an antisymmetry argument over the partial
order induced by chip-firing — no analysis is required, only the finite Laplacian
combinatorics already set up. **Why now?** With `linEquiv` proven to be an
equivalence relation and degree proven invariant, divisor classes are
well-defined objects, which is the prerequisite for choosing canonical
representatives.

## 3. The graph genus equals the dimension of the cycle space

We currently take the genus relation `∑ vdeg = 2|E|`, `g = |E| - |V| + 1` as a
hypothesis. Promote it to a theorem by defining `|E|` and `g` intrinsically and
proving, for a connected graph, that `g` equals the rank of the cycle space
(first Betti number) `dim ker(∂)` of the incidence map. **The key insight is**
that `2g - 2 = deg K` should be a *corollary* of a rank–nullity computation on
the boundary map `∂ : ℤ^E → ℤ^V`, whose image is precisely the principal
divisors `fire`. **Why now?** `degree_fire` shows `fire` lands in the
degree-zero subgroup; identifying `image(fire)` with `ker(degree)/Pic⁰` is the
homological refinement that makes the genus canonical rather than assumed.

## 4. The Jacobian (critical/sandpile group) and Kirchhoff's matrix–tree theorem

Define `Pic⁰(G)` as degree-zero classes under `linEquiv` and prove it is finite
with `|Pic⁰(G)| = ` number of spanning trees (Kirchhoff). **The key insight is**
that `Pic⁰(G) ≅ ℤ^V₀ / image(reduced Laplacian)`, a cokernel of an integer
matrix, so its order is the determinant of any cofactor of `laplacian` — directly
linking the `laplacian` defined here to the matrix–tree theorem. **Why now?**
The column-sum-zero property `laplacian_colSum_zero` is exactly the statement
that makes the *reduced* Laplacian (delete one row/column) the correct
presentation matrix for the sandpile group.

## 5. Clifford's inequality and a tropical Brill–Noether existence bound

For a special effective divisor `D` (both `D` and `K - D` equivalent to
effective), prove the graph-theoretic Clifford bound `r(D) ≤ deg D / 2`, and
from it derive an upper bound on the Brill–Noether locus
`W^r_d(G) = { [D] : deg D = d, r(D) ≥ r }`. **The key insight is** that Clifford's
inequality follows formally from the rank super-additivity `r(D) + r(E) ≤
r(D + E)` together with the duality `r(D) = r(K - D)` for special divisors — and
the degree side `deg(K - D) = (2g-2) - deg D` is already a theorem here. **Why
now?** Clifford is the first *inequality* (as opposed to identity) in the theory
and is the gateway to genuine Brill–Noether existence/non-existence statements,
the stated long-term goal of this research line.
