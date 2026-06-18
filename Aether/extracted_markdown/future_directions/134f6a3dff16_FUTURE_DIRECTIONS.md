# Future Directions: Chip-Firing, Divisors, and Tropical Brill–Noether Theory

## Synthesis

This cycle was a genuine cold start: the catalog placeholders cited by the
research brief (`chipFiring_degree_invariant`, `Divisor`, `rho_serre_duality`,
`CDPRAllocation`, `MetricChainOfLoops`, …) did **not** exist anywhere in the
project. Rather than build on phantom foundations, we constructed the
combinatorial backbone of Baker–Norine divisor theory from scratch on top of
Mathlib, in `Catalog/Tropical/BakerNorine/Core.lean`.

The central conceptual move is to package chip-firing as a single
`AddMonoidHom`, the graph Laplacian `lapHom : (V → ℤ) →+ (V → ℤ)`. Almost the
entire elementary theory then becomes formal:

* **Degree invariance of firing** (`lapHom_degHom_zero`) follows from one fact —
  antisymmetry of the summand `A(v,w)·(f w − f v)` under swapping `v` and `w`.
* The **Picard / Jacobian group** `Pic Γ = (V → ℤ) / range(lapHom)` is just an
  `AddCommGroup` quotient, and the **Abel–Jacobi degree map** `picDeg : Pic Γ →+ ℤ`
  is the universal lift of `degHom` through that quotient — surjective whenever
  `Γ` has a vertex.
* The **handshaking lemma** (`handshake_even`) and the **canonical degree
  identity** `deg K = 2g − 2` (`canonical_degree_genus`) reuse the same
  symmetry/looplessness data.
* The **Brill–Noether number** `ρ(g,r,d) = g − (r+1)(g−d+r)` is Serre-self-dual
  (`rho_serre_duality`): it is invariant under `(r,d) ↦ (r−d+g−1, 2g−2−d)`,
  i.e. under `D ↦ K − D`.

## Results Summary (all `sorry`-free, only standard axioms)

| Theorem | Statement |
|---|---|
| `FinGraph.lapHom_degHom_zero` | firing a script never changes total degree |
| `FinGraph.linearEquiv_degHom_eq` | degree is well defined on linear-equivalence classes |
| `FinGraph.picDeg` / `picDeg_mk` | the Abel–Jacobi degree homomorphism `Pic Γ →+ ℤ` |
| `FinGraph.picDeg_surjective` | every integer is the degree of some divisor class |
| `FinGraph.handshake_even` | the handshaking lemma `2 ∣ ∑ deg v` |
| `FinGraph.canonical_degree_eq` / `canonical_degree_genus` | `deg K = ∑deg − 2|V| = 2g − 2` |
| `rho_serre_duality` | Serre-duality symmetry of the Brill–Noether number |

## Research Directions

### 1. The rank function and the full Baker–Norine Riemann–Roch theorem
Define the Baker–Norine rank `r(D)` (the largest `k` such that `D − E` is linearly
equivalent to an effective divisor for every effective `E` of degree `k`, with the
convention `r(D) = −1` when `D` is not equivalent to an effective divisor) and prove
`r(D) − r(K − D) = deg D − g + 1`. The key insight is that our Laplacian-as-`AddMonoidHom`
already certifies the *only* hard structural input to one inequality — that linear
equivalence is degree-preserving (`lapHom_degHom_zero`) — so the remaining work is the
purely order-theoretic theory of `q`-reduced divisors and Dhar's burning algorithm, which
can be formalized as a *certified decision procedure* deciding effectivity within a
linear-equivalence class. Why now? `linearEquiv_degHom_eq` and `picDeg` give a clean,
quotient-level setting in which "equivalent to effective" is a well-posed predicate on
`Pic Γ`, and `canonical_degree_genus` already supplies the exact constant `g` that the
Riemann–Roch right-hand side must reproduce.

### 2. Finiteness of `Pic⁰` and the Matrix–Tree theorem
Prove that the degree-zero Jacobian `Pic⁰ Γ = ker(picDeg)` is finite for connected `Γ`
and that its order equals the number of spanning trees of `Γ` (Kirchhoff's Matrix–Tree
theorem). The key insight is that `Pic⁰ Γ` is exactly the cokernel of the reduced
Laplacian acting on `ℤ^{V∖{q}}`, so its cardinality is the absolute value of any cofactor
of the Laplacian matrix — a determinant identity rather than a graph traversal. Why now?
The quotient `Pic Γ = (V → ℤ)/range(lapHom)` and the surjection `picDeg` are already
built, so `Pic⁰` is available as `picDeg.ker`; Mathlib's Smith-normal-form and
determinant machinery (`Matrix.det`, `Module.Finite`) can finish the cardinality count.

### 3. The discrete Abel–Jacobi isomorphism `Pic⁰ Γ ≅ ℤ^V / (im L + ⟨𝟙⟩)`
Establish a canonical group isomorphism between `Pic⁰ Γ` and the sandpile/critical group
presented as the cokernel of the *reduced* Laplacian. The key insight is that our `lapHom`
has the all-ones vector in its kernel and `range(lapHom) ⊆ ker(degHom)`, so the two
"obvious" quotients (`ker degHom / range lapHom` vs. `ℤ^{V∖{q}} / reduced-Laplacian`)
must agree, and the isomorphism is induced by deleting a fixed sink vertex `q`. Why now?
Both quotients are now first-class objects: the first is `picDeg.ker` from this file, and
the second is a finitely-presented `ℤ`-module; proving the iso is an exercise in
`QuotientAddGroup` universal properties already used to build `picDeg`.

### 4. Genus monotonicity and Euler characteristic under graph operations
Prove that `genus` is additive/monotone under the standard graph operations — disjoint
union, one-point wedge, edge subdivision, and edge contraction — e.g. subdividing an edge
leaves `genus` invariant while adding a parallel edge increases it by one. The key insight
is that `genus = totalDeg/2 − |V| + 1` is an *Euler-characteristic* quantity, so each
operation's effect on `genus` is computed locally from its effect on `totalDeg` and `|V|`,
both of which are explicit finite sums in our `FinGraph` encoding. Why now? `handshake_even`
guarantees `totalDeg/2` behaves like an honest edge count, so the bookkeeping needed for
each operation reduces to `Finset.sum` manipulations of exactly the kind already automated
in `canonical_degree_eq`.

### 5. Serre duality as an involution on divisor classes, lifting `rho_serre_duality`
Promote the *numerical* Serre symmetry `rho_serre_duality` to a *structural* one: show that
`D ↦ K − D` descends to a well-defined involution on `Pic Γ` that negates degree relative
to `g − 1` (`deg(K − D) = 2g − 2 − deg D`) and, once rank is available (Direction 1),
exchanges `r(D)` and `r(K − D)`. The key insight is that `rho_serre_duality` already
identifies the *exact* index substitution `(r,d) ↦ (r−d+g−1, 2g−2−d)` that Riemann–Roch
must realize, so it functions as a falsifiable target: any candidate rank function whose
`r(K−D)` does not match this substitution is provably wrong. Why now? With `canonical`,
`degHom`, and `picDeg` in place, the divisor-level map `D ↦ K − D` is literally
`fun D => G.canonical - D`, and proving it is a degree-reflecting group involution on
`Pic Γ` is immediate from the homomorphism lemmas established here.
