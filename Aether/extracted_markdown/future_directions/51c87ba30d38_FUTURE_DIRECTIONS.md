# Future Directions: Tropical Brill–Noether Theory

## Synthesis

This cycle laid the load-bearing foundation of Baker–Norine divisor theory on a finite
graph, entirely over an ordinary Mathlib `SimpleGraph V`, in two new files
(`Tropical/ChipFiring/Defs.lean`, `Tropical/ChipFiring/Theorems.lean`). The chip-firing
operator is the graph Laplacian `(lap G f).coeff v = ∑_{u ∼ v}(f v − f u)`, and we proved
that `f ↦ lap G f` is a degree-zero additive homomorphism `(V → ℤ) → Divisor V` killing
the constants (`lap_zero`, `lap_const`, `lap_add`, `lap_neg`, `lap_deg_zero`). From these
homomorphism facts the algebraic layer dropped out formally: chip-firing equivalence is a
genuine `Equivalence` (`linEquiv_equivalence`, packaged as `linSetoid`), degree is a class
invariant (`linEquiv_deg`), and the easy direction of Riemann–Roch — negative degree forces
an empty linear system — falls out in three lines (`neg_deg_no_effective_equiv`).

The structural insight of the cycle is that *the entire algebraic layer is the coset
relation of one homomorphism*: the three equivalence-relation axioms are literally
`lap_zero`/`lap_neg`/`lap_add`, and degree invariance is exactly the sum-zero property
`lap_deg_zero`. The sum-zero property itself reduces to the antisymmetry of `f v − f u`
under the symmetric adjacency relation — a single `Finset.sum_nbij'` swap `(v,u) ↦ (u,v)`
forcing `X = −X`, with no handshake/degree-counting needed. The one genuinely
combinatorial result, `lap_kernel_const_of_connected`, is the discrete maximum principle:
on a *connected* graph the kernel of the Laplacian is exactly the constants. Its proof
isolates connectivity to a single step — propagating the argmax level set along walks
(`reachClosed` + `Connected.preconnected`) — while the arithmetic is the local equality
case of the maximum principle (`lapNeighborConst`).

On the numerics side the Brill–Noether number `ρ(g,r,d) = g − (r+1)(g−d+r)` was shown to
satisfy Serre duality (`bnNumber_serre_duality`), the genus-0 formula
(`bnNumber_genus_zero`), strict monotonicity in degree (`bnNumber_strict_mono_d`), and an
exact unit increment (`bnNumber_succ_d`). These give a clean numerical scaffold any future
rank/Riemann–Roch formula must respect. As a bonus the foundation repairs the previously
dangling `Tropical.CompleteGraph` file, whose `import Tropical.ChipFiring.Theorems` now
resolves; `degree_canonicalDivisor` (`= 2g − 2`) closes the loop with `genus` and
`canonicalDivisor`.

## Results Summary

- `lap_zero`, `lap_const` — the empty/constant firing patterns are in the kernel.
- `lap_add`, `lap_neg` — the Laplacian is additive and respects negation.
- `lap_deg_zero` — every Laplacian has degree zero (antisymmetry + `Finset.sum_nbij'`).
- `linEquiv_equivalence` / `linSetoid` — chip-firing equivalence is an `Equivalence`.
- `linEquiv_deg` — degree is a linear-equivalence invariant.
- `neg_deg_no_effective_equiv` — negative-degree divisors have empty linear systems.
- `lap_max_principle`, `lapNeighborConst` — discrete maximum principle and its equality case.
- `reachClosed` — adjacency-closed predicates are reachability-closed.
- `lap_kernel_const_of_connected` / `lap_kernel_iff_const` — on a connected graph the
  Laplacian kernel is *exactly* the constant functions (the deep result of this cycle).
- `degree_canonicalDivisor` — `deg(K_G) = 2g − 2`.
- `bnNumber_serre_duality`, `bnNumber_genus_zero`, `bnNumber_strict_mono_d`,
  `bnNumber_succ_d` — the numerical Brill–Noether scaffold.

## Research Directions

### Direction 1: The graph Jacobian is a finite abelian group
For a connected graph `G` on a `Fintype V`, the degree-0 part of
`Quotient (linSetoid G)` should carry an abelian group structure inherited from pointwise
`+` (descending because `lap_add` makes `lap` additive), and this group `Jac(G)` should be
*finite*. The test is concrete: define `Jac(G)` as the degree-0 classes, lift pointwise
addition through `linEquiv_equivalence`, and prove `Finite (Jac G)` by surjecting a bounded
fundamental domain (e.g. `q`-reduced divisors) onto it. The key insight is that finiteness
is *forced by* `lap_kernel_const_of_connected`: the Laplacian's kernel being
one-dimensional (the constants) makes its image in degree-0 divisors a full-rank
sublattice, hence of finite index — which is precisely what makes `Jac(G)` finite. Why now?
We already have the setoid (`linSetoid`), additivity (`lap_add`), and degree descent
(`linEquiv_deg`); the only missing ingredient is the index computation, and the kernel
description that controls it is now proven. If true, this opens the matrix–tree theorem
`|Jac(G)| = #spanning trees` and a computable Lean sandpile group. If false, it would mean
the kernel-of-Laplacian description fails to control the cokernel, pointing to a missing
connectivity or torsion hypothesis.

### Direction 2: Dhar's burning algorithm and unique `q`-reduced representatives
Fixing a sink vertex `q`, every divisor class should have a *unique* `q`-reduced
representative, computable by a terminating burning process on `Finset V`. The test:
define `q`-reducedness (`∀` nonempty `S ⊆ V∖{q}, ∃ v ∈ S, D.coeff v < outdeg_S(v)`),
implement Dhar's burning as a well-founded recursion on the shrinking unburnt set, and
prove existence + uniqueness, sanity-checking on the path and cycle graphs with `#eval`.
The key insight is that uniqueness is the *equality case* of the maximum principle we
already proved: `lapNeighborConst` says a harmonic firing is flat across each edge, so two
`q`-reduced divisors in one class differ by a Laplacian whose firing set, if nonempty,
would violate reducedness at its boundary. Why now? `lapNeighborConst` and `reachClosed`
already package exactly the boundary-flatness argument that drives the uniqueness proof,
and Lean 4 well-founded recursion on `Finset V` makes termination tractable. If true, this
gives canonical class representatives, decidable equality on `Jac(G)`, and a constructive
route to the full Baker–Norine rank. If false, a non-unique reduced divisor would reveal
that adjacency alone is too weak and edge multiplicities must be tracked.

### Direction 3: Full Baker–Norine Riemann–Roch from the easy direction
With `rank D` defined as the largest `k` such that `D − E` is equivalent to an effective
divisor for every effective `E` of degree `k` (and `−1` if `D` itself is not equivalent to
an effective divisor), the identity `rank D − rank (K_G − D) = deg D − g + 1` should hold.
The test: prove the two Riemann–Roch inequalities separately — the `≤` direction via
`q`-reduced divisors (Direction 2), the `≥` direction via a Dhar duality between `D` and
`K_G − D` — and cross-check `deg D < 0 ⇒ rank D = −1` against `neg_deg_no_effective_equiv`.
The key insight is that `neg_deg_no_effective_equiv` is *already* the base case `rank = −1`
for `deg < 0`, and `bnNumber_succ_d` (the exact `+(r+1)` increment) plus
`degree_canonicalDivisor` (`deg K_G = 2g−2`) pin down the numerical target before the
combinatorics begin. Why now? The numerical scaffold and the rank-`−1` base case are both
proven, so the remaining work is purely combinatorial and has a fixed target to hit. If
true, this yields a complete formal graph Riemann–Roch. If false, the likely failure (the
`≥` direction) would localize exactly which graph hypothesis Baker–Norine secretly needs.

### Direction 4: Quantitative maximum principle and a spectral gap
On a connected graph a near-harmonic firing pattern should be near-constant:
`‖lap G f‖_∞ ≤ ε` should imply `max f − min f ≤ C(G)·ε`, with `C(G)` controlled by the
graph diameter — i.e. the Laplacian has a strictly positive smallest nonzero eigenvalue.
The test: first prove the qualitative diameter bound
`max f − min f ≤ diam(G)·‖lap G f‖_∞` by telescoping the local inequalities along a
geodesic, then relate it to the `Matrix.IsHermitian` eigenvalues of the Laplacian matrix in
Mathlib. The key insight is that `lap_kernel_const_of_connected` is the `ε = 0` case of a
robust statement, and its proof already walks a path from the argmax to every vertex —
turning that walk into a telescoping inequality immediately yields the diameter bound. Why
now? The exact `ε = 0` proof structure (`lapNeighborConst` along a walk produced by
`reachClosed`/`Connected.preconnected`) is in hand, and the quantitative version reuses the
identical path with `≤` in place of `=`. If true, it connects the combinatorial divisor
theory to spectral graph theory and Cheeger/expander estimates catalogued elsewhere. If
false, it would show the kernel description is fragile under perturbation, isolating
bottlenecked graphs as the obstruction.

### Direction 5: Specialization preserves the Brill–Noether obstruction
Any rank function `r` satisfying Serre duality `r(D) − r(K−D) = deg D − g + 1` should make
the Brill–Noether obstruction `ρ(g,r,d)` invariant under the Serre involution, so tropical
and algebraic sides share the *same* numerical liftability condition. The test: show
abstractly that `bnNumber_serre_duality` plus degree preservation (a `linEquiv_deg`-style
invariance under a specialization map) forces `ρ` to agree on both sides; formalize a
`SpecializationDatum` interface (rank-non-decreasing, degree-preserving) and derive the
necessary condition `ρ(g,r,d) ≥ 0` purely tropically. The key insight is that the
Serre-duality identity we proved is *exactly* the numerical invariant any specialization
must respect, so the liftability obstruction can be checked entirely in the tropical
setting before any non-Archimedean geometry enters. Why now? `bnNumber_serre_duality` and
`linEquiv_deg` are both proven, giving the two ingredients (the `ρ`-symmetry and degree
preservation) the abstract argument needs. If true, this gives a computable, formally
verified necessary condition for lifting tropical divisors to algebraic ones. If false, a
specialization datum violating the `ρ` identity would expose a hidden hypothesis (e.g.
faithful tropicalization) needed for Baker's specialization lemma.
