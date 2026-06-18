# Future Directions: Quantum Gravity as Topological Quantum Field Theory

## 1. Turaev-Viro State Sum Invariance

The natural next step is to formalize the Turaev-Viro state sum construction itself. Given a fusion system `F` and a triangulation `T` of a closed 3-manifold, define the partition function `Z(T) = Σ (colorings) Π (6j-symbols)` and prove it is independent of the triangulation (invariance under Pachner moves). The key insight is that the pentagon equation for the fusion system — which we have already axiomatized as the `associativity` field — is precisely the algebraic identity that ensures invariance under the 2-3 Pachner move. Why now? Our formalization of fusion systems provides the exact algebraic data needed; what remains is the combinatorial machinery of triangulations and Pachner moves, which is largely independent of TQFT-specific content.

## 2. Modular S-Matrix and the Full Verlinde Formula

Our current formalization proves that quantum dimensions form a simultaneous eigenvector of the fusion matrices. The full Verlinde formula goes further: it asserts the existence of a unitary matrix `S` that simultaneously diagonalizes all fusion matrices, with `N_{ij}^k = Σ_l S_{il} S_{jl} S*_{kl} / S_{0l}`. The key insight is that the fusion matrices form a commutative semisimple algebra over ℝ (commutativity is our Theorem 1), so simultaneous diagonalization is guaranteed by the spectral theorem for commuting normal matrices. Why now? Mathlib has the spectral theorem for normal operators on finite-dimensional inner product spaces, and our commutativity result provides the critical prerequisite.

## 3. Mapping Class Group Representations and Unitarity

For a genus-g surface Σ_g, the TQFT assigns a finite-dimensional Hilbert space V(Σ_g) on which the mapping class group MCG(Σ_g) acts by unitary transformations. The conjecture is: formalize the MCG action via Dehn twist generators and prove unitarity using the inner product induced by the quantum trace. The key insight is that the MCG representation factors through the representation of the Temperley-Lieb or Hecke algebra, and unitarity follows from the positivity of quantum dimensions (which we have axiomatized as `qdim_positive`). Why now? The algebraic framework is in place; the main gap is formalizing the Dehn twist action in terms of fusion data, which requires only the 6j-symbols and braiding structure beyond what we have.

## 4. Crane-Yetter Extension to 4D and State Sum Models

The Turaev-Viro theory lives in 3 dimensions. The Crane-Yetter state sum extends it to 4 dimensions using a modular tensor category. The conjecture to test: the Crane-Yetter partition function on a closed 4-manifold depends only on the signature and Euler characteristic, and equals `D^{3σ+χ}` where `D` is the global dimension. The key insight is that this formula reduces to checking invariance under the 4D Pachner moves (1-5, 2-4, 3-3), which in turn reduce to algebraic identities in the fusion system that generalize our associativity axiom. Why now? Our `globalDimSq_pos` theorem and the fusion system framework provide the foundation; the 4D extension is a natural and falsifiable generalization.

## 5. Quantum Double Construction and Kitaev Models

Given a finite group G, the quantum double D(G) is a Hopf algebra whose representation category is a modular tensor category. The conjecture: formalize that D(G) yields a fusion system where the fusion coefficients equal the structure constants of the center of the group algebra Z(ℂ[G]), and the global dimension squared equals |G|². The key insight is that this provides a concrete, computable instantiation of our abstract fusion system axioms, and connects to Kitaev's toric code model of topological quantum computation. Why now? Mathlib has extensive support for finite groups, group algebras, and representation theory — the ingredients needed to construct D(G) are largely available, making this a high-feasibility target for connecting our abstract framework to concrete examples.
