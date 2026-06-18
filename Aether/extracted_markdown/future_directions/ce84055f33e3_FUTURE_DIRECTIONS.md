# Future Directions — Fusion Systems and the Turaev–Viro / Verlinde Program

The file `Physics/FusionSystems.lean` formalizes the algebraic core of the
state-sum approach to 3d topological quantum field theory: a `FusionSystem`
(the commutative Grothendieck ring of a fusion category), its regular
representation by **fusion matrices** (`fmat_mul`), their pairwise
**commutativity** (`fmat_comm`), the **Verlinde left-eigenvector** property of
fusion characters / quantum dimensions (`char_left_eigenvector`), strict
**global-dimension positivity** (`globalDimSq_pos`), and a concrete computable
instantiation, the pointed fusion system `Vec_G` of a finite abelian group
(`groupFusion`, `groupFusion_globalDimSq`). The conjectures below build directly
on these declarations.

## 1. Full simultaneous diagonalization (the complete Verlinde formula)

We proved that the fusion matrices pairwise commute (`fmat_comm`) and that a
fusion character is a *left* eigenvector of every fusion matrix
(`char_left_eigenvector`). The next step is to upgrade this to genuine
simultaneous diagonalization: produce a single invertible (in the unitary case,
orthogonal) matrix `S` whose columns are the common eigenvectors, and derive the
closed Verlinde fusion-coefficient formula `N i j k = ∑ₗ S i l · S j l · S k l / S 0 l`.
**The key insight is** that a finite family of pairwise-commuting matrices over a
field is simultaneously triangularizable, and over ℝ with the symmetry
`N i j k = N j i k` the fusion matrices become symmetric in a suitable basis,
so the real spectral theorem applies verbatim. **Why now?** Mathlib already has
`Matrix.IsHermitian.spectral_theorem` and the commuting-diagonalization API for
finite-dimensional inner product spaces; our `fmat_comm` supplies the missing
commutativity hypothesis, so the remaining work is bookkeeping rather than new
mathematics.

## 2. Perron–Frobenius uniqueness and positivity of quantum dimensions

`char_left_eigenvector` shows quantum dimensions are *a* common eigenvector; it
does not yet show they are the distinguished Perron–Frobenius one with strictly
positive entries. Conjecture: for a fusion system whose coefficients are
non-negative and whose fusion graph is connected (irreducible), there is a unique
positive simultaneous eigenvector up to scaling, namely the quantum dimensions,
and it maximizes the spectral radius of each `fmat i`. **The key insight is** that
each `fmat i` has non-negative entries, so the classical Perron–Frobenius theorem
pins down a unique positive eigenvector, and commutativity forces this eigenvector
to be shared across all `i`. **Why now?** Non-negativity is already expressible in
our `FusionSystem` API by adding a single field `Nnonneg`, and the irreducibility
hypothesis is a clean combinatorial condition on the support of `N`, making the
statement immediately falsifiable on small examples (e.g. Fibonacci, Ising).

## 3. Turaev–Viro tetrahedral partition function and 2–3 Pachner invariance

Define the local Boltzmann weight of a colored tetrahedron from the fusion data
and the partition function `Z(T) = ∑_(colorings) ∏_(tetrahedra) weight`, then
prove invariance under the 2–3 Pachner move. **The key insight is** that the 2–3
move identity is *exactly* the associativity axiom `assoc` already in our
`FusionSystem` (the pentagon shadow): summing a product of two weights over the
internal edge reproduces the three-tetrahedron weight, term by term, just as
`fmat_mul` rewrites `Nᵢ Nⱼ` via the structure constants. **Why now?** The hard
algebraic content is the associativity field we have axiomatized and exploited in
`fmat_mul`; what remains is a purely combinatorial encoding of triangulations and
moves, independent of any analytic TQFT machinery, so it can be developed entirely
within Lean as finite sums over coloring functions.

## 4. The quantum double `D(G)` and the `|G|²` global dimension

`groupFusion` realizes the pointed system `Vec_G` with global dimension `|G|`
(`groupFusion_globalDimSq`). The quantum double `D(G)` of a finite group should
yield a fusion system whose simple objects are pairs (conjugacy class, irrep of
the centralizer) and whose global dimension squared equals `|G|²`. Conjecture:
construct `doubleFusion G : FusionSystem (Drinfeld labels)` and prove
`∑ d_i² = (Fintype.card G)²`. **The key insight is** that `D(G)`'s fusion
coefficients are the structure constants of the center `Z(ℂ[G])`, and the sum of
squared quantum dimensions telescopes via the orthogonality relations to
`(∑_class |class| · 1)² = |G|²`. **Why now?** Mathlib has finite groups, conjugacy
classes, group algebras and character orthogonality; combined with our
`globalDimSq_pos` and `IsCharacter` scaffolding, the construction reduces to
assembling existing pieces and is directly checkable on `ℤ/2`, `S₃`.

## 5. Crane–Yetter 4d state sum and the signature formula

Extend the framework one dimension up: from a modular fusion system, define the
Crane–Yetter partition function on a closed 4-manifold and conjecture it equals
`D^(3σ + χ)` (σ the signature, χ the Euler characteristic). **The key insight is**
that, exactly as in direction 3, invariance under the 4d Pachner moves (3–3, 2–4,
1–5) reduces to algebraic identities generalizing our `assoc`/`fmat_mul`
structure-constant rewrite, and the dependence collapses to the two homotopy
invariants σ and χ because the local weights are built from the same global
dimension `D` whose positivity we proved in `globalDimSq_pos`. **Why now?** With
the 3d invariance machinery of direction 3 in place, the 4d case is a structural
generalization rather than a fresh start, and the target formula is sharply
falsifiable on `S⁴`, `ℂP²`, and `S² × S²` where σ and χ are known integers.
