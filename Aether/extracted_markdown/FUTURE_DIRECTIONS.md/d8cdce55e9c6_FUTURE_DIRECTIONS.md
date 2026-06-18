# Future Directions: Hilbert 16 — Topology of Real Algebraic Curves

## 1. Petrovsky Inequalities as Sharp Bounds on Signed Oval Counts

The current formalization proves that each parity class of ovals is bounded by the
Harnack number. The full Petrovsky inequality is much sharper: for a smooth real
curve of degree 2k, the signed count satisfies |χ(B⁺) - 1| ≤ (3k² - 3k)/2, where
B⁺ is the positive region and χ is the Euler characteristic. The key insight is
that the Petrovsky inequality follows from the Hodge index theorem applied to the
complexification — a bridge between real algebraic geometry and complex Hodge theory
that has not been formalized in any proof assistant. Why now? The genus-degree formula
and Harnack bound are now in place, providing the combinatorial scaffolding. The
next step is to formalize the Smith-Thom inequality (relating Betti numbers of the
real locus to those of the complexification via mod-2 homology), which would make
the Petrovsky inequalities a direct corollary.

## 2. Viro Patchworking as Constructive Harnack Tightness

We proved the Harnack bound H(d) = (d-1)(d-2)/2 + 1 as an upper bound, but did not
construct M-curves (curves achieving this bound). Viro's patchworking method (1979)
provides a combinatorial construction: subdivide the Newton triangle of a degree-d
polynomial, assign signs to lattice points, and glue local curve patches. The key
insight is that patchworking reduces the existence of M-curves to a purely
combinatorial problem about sign distributions on triangulations — making it
amenable to formalization as a finite verification. Why now? The triangular number
identification genus(d) = T(d-2) directly connects to the Newton polygon lattice
point count, and the period-4 parity classification constrains which patchworking
sign patterns are valid.

## 3. Gudkov-Rokhlin Congruence via Rokhlin's Signature Theorem

The Gudkov-Rokhlin congruence p - n ≡ k² (mod 8) is axiomatized in our formalization.
A proof would require formalizing Rokhlin's theorem: for a closed, smooth, spin
4-manifold M, σ(M) ≡ 0 (mod 16), where σ is the signature. The key insight is that
the double cover of CP² branched along a smooth complex curve of even degree is a
spin 4-manifold when the degree ≡ 0 (mod 4), and the signature computation reduces
to the lattice-theoretic intersection form on H₂. Why now? Formalizations of
intersection forms on 4-manifolds are beginning to appear in Lean/Mathlib, and the
arithmetic consequences (our gudkov_degree6_constraint theorem) provide concrete
test cases to validate any formalized proof.

## 4. Limit Cycles of Polynomial Vector Fields (Hilbert 16, Part 2)

Hilbert's 16th problem Part 2 asks for an upper bound H(n) on the number of limit
cycles of a planar polynomial vector field of degree n. This is wide open even for
n = 2 (the known bound for quadratic systems is finite but the exact value is unknown).
The key insight is that our oval arrangement formalism — specifically the nesting depth
bound and Bezout intersection constraints — transfers directly to limit cycle
configurations via the Poincaré-Bendixson theorem: limit cycles are nested simple
closed curves, and the algebraic degree of the vector field constrains their
arrangement exactly as Bezout constrains oval nesting. Why now? The
`OvalArrangement` structure with its `nesting_bound` axiom captures exactly the
combinatorial constraint that applies to both algebraic ovals and limit cycles,
enabling a unified treatment.

## 5. Computational Classification for Degree 8

For degree 8, the Harnack bound gives H(8) = 22, and the Gudkov-Rokhlin congruence
with k = 4 gives p - n ≡ 16 ≡ 0 (mod 8). Combined with p + n = 22, the arithmetic
solutions are (p, n) ∈ {(3,19), (7,15), (11,11), (15,7), (19,3)}. But many of these
are eliminated by the Petrovsky inequalities and Arnold's congruence. The key insight
is that formalizing the full constraint system (GR + Petrovsky + Arnold + nesting depth)
as a finite integer program would yield a machine-verified enumeration of all
topologically possible M-curve configurations for degree 8, advancing the
classification beyond degree 6. Why now? The `gudkov_degree6_constraint` theorem
demonstrates that this type of finite arithmetic enumeration is tractable in Lean,
and the framework scales directly to higher degrees.
