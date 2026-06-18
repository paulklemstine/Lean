# Future Directions: Quadratic Reciprocity and Proof Comparison

## Synthesis

The formalization of multiple proof architectures for quadratic reciprocity opens a new research program: *verified proof comparison in arithmetic*. Our work shows that Eisenstein's lattice-point method and Gauss's lemma extract identical parity invariants from prime pairs. This naturally leads to questions about higher reciprocity laws, deeper proof invariants, and the computational content of different proof strategies. The five directions below form a coherent program: Direction 1 tests whether the parity-extraction framework extends to all elementary proofs; Direction 2 explores higher reciprocity as a stress test for formal methods; Direction 3 connects our discrete-geometric framework to analytic number theory via Dedekind sums; Direction 4 pushes toward the Langlands program; and Direction 5 investigates the computational complexity gap between proof methods.

---

## Direction 1: Universal Parity Factorization for Elementary QR Proofs

**Conjecture:** Every "elementary" proof of quadratic reciprocity (one that does not use algebraic number theory or complex analysis) factors through the same ZMod 2 parity invariant as the Eisenstein and Gauss proofs.

**Test:** Formalize at least two additional elementary proofs — Zolotarev's permutation-sign proof and the proof via counting lattice points in triangles (as in Eisenstein's second proof) — and verify that their extracted parities agree with `eisensteinParity` and `gaussParity` on all pairs of odd primes up to 1000.

**Impact:** If confirmed, this would establish that the "hidden bit" of reciprocity is a proof-theoretic invariant, not just a theorem-theoretic one. It would suggest a classification of QR proofs by the mechanism through which they access this invariant. If falsified (a proof extracting a genuinely different intermediate quantity), it would reveal unexpected diversity in proof structure.

**Catalog References:** `Catalog/Algebra/QuadraticReciprocity/Core.lean` — `eisenstein_gauss_parity_equiv`, `QRParityModel`

**Proof Strategy:** Formalize Zolotarev's proof using `Equiv.Perm.sign` from Mathlib. The permutation is x ↦ ax mod p on {1,...,p-1}. Show sign(σ_a) = (a/p) and extract the parity. Compare with `eisensteinParity`.

**Domain Bridges:** Combinatorics (permutation groups) ↔ Number theory (Legendre symbols) ↔ Geometry (lattice points)

**Lineage:** Extends `eisenstein_gauss_parity_equiv` to a three-way or n-way equivalence.

**Ambition:** Medium-high. Zolotarev's proof is well-understood but nontrivial to formalize; the universal claim is bold but testable.

---

## Direction 2: Cubic Reciprocity via Eisenstein Integers

**Conjecture:** The `ReciprocityWitness` framework extends naturally to cubic reciprocity over Z[ω] (ω = e^{2πi/3}), with a `CubicReciprocityWitness` structure whose sign function takes values in {1, ω, ω²} and whose soundness condition involves the cubic residue symbol.

**Test:** Define `CubicReciprocityWitness` in Lean. Formalize the cubic residue symbol over `GaussianInt`-like structures for Eisenstein integers. State and attempt to prove the cubic reciprocity law. Computationally verify for Eisenstein primes of norm up to 1000.

**Impact:** This would be the first formal verification of cubic reciprocity. It would validate the `ReciprocityWitness` framework as a template for higher reciprocity, and provide infrastructure for eventual formalization of the full Artin reciprocity law.

**Catalog References:** `Catalog/Algebra/QuadraticReciprocity/Core.lean` — `ReciprocityWitness` structure

**Proof Strategy:** Use Mathlib's `EisensteinInt` (if available) or define Eisenstein integers as Z[X]/(X²+X+1). Define the cubic residue symbol via the norm-based Euler criterion. Adapt Eisenstein's proof of cubic reciprocity (1844).

**Domain Bridges:** Algebraic number theory ↔ Formal verification ↔ Computational algebra

**Lineage:** Direct generalization of the quadratic `ReciprocityWitness`.

**Ambition:** Grand challenge. Cubic reciprocity is significantly harder than quadratic; Eisenstein integers are less developed in Mathlib.

---

## Direction 3: Dedekind Sums and the Eisenstein Floor Sum

**Conjecture:** The Eisenstein floor sum `eisensteinFloorSum(p,q)` is a specialization of a Dedekind sum s(q,p), and the floor-sum identity is a consequence of the Dedekind sum reciprocity formula s(a,b) + s(b,a) = (a²+b²+1)/(12ab) − 1/4.

**Test:** Define Dedekind sums in Lean. Prove the Dedekind sum reciprocity formula. Show that `eisensteinFloorSum(p,q) = p·s(q,p) + (p-1)/4 + ...` (the exact relation involves sawtooth functions). Verify computationally for primes up to 500 that the Dedekind sum formula recovers the Eisenstein floor-sum identity.

**Impact:** This connects quadratic reciprocity to modular forms, eta functions, and the theory of lattice-point enumeration. Dedekind sums appear in topology (signature defects of lens spaces), algebraic geometry (toric varieties), and mathematical physics (partition functions). A formal bridge between reciprocity and Dedekind sums would open all these connections.

**Catalog References:** `Catalog/Algebra/QuadraticReciprocity/Core.lean` — `eisensteinFloorSum`, `eisenstein_floor_identity`

**Proof Strategy:** Define s(a,b) = ∑_{k=1}^{b-1} ((k/b))·((ka/b)) where ((x)) is the sawtooth function. Prove reciprocity by the same lattice-point counting argument used in `eisenstein_floor_identity`, generalized to non-prime arguments.

**Domain Bridges:** Number theory ↔ Topology (lens space signatures) ↔ Algebraic geometry (toric varieties) ↔ Mathematical physics

**Lineage:** Builds directly on `eisenstein_floor_identity` and `reciprocity_lattice_region_card`.

**Ambition:** Medium. Dedekind sums are well-understood mathematically, but require careful formalization of the sawtooth function and its properties.

---

## Direction 4: Artin Symbol and Quadratic Character Uniqueness

**Conjecture:** The Legendre symbol (a/p) is the unique nontrivial quadratic character on (Z/pZ)×, and quadratic reciprocity is equivalent to the statement that the Artin symbol of p in Q(√q)/Q depends only on p mod 4q.

**Test:** Formalize the quadratic character as a `MulChar (ZMod p) ℤˣ` in Mathlib. Prove uniqueness: there is exactly one nontrivial character χ with χ² = 1. Show χ agrees with `legendreSym`. Then formalize the Frobenius-at-p computation for Q(√q)/Q and derive reciprocity from Frobenius properties.

**Impact:** This is the entry point to class field theory. A formalization would connect elementary reciprocity to the Langlands program and validate that the `ReciprocityWitness` framework captures the "abelian character-theoretic skeleton" of the local-global proof.

**Catalog References:** `Catalog/Algebra/QuadraticReciprocity/Core.lean` — `legendreWitness`, `quadratic_reciprocity_eisenstein`

**Proof Strategy:** Use Mathlib's `quadraticChar` from `Mathlib.NumberTheory.LegendreSymbol.QuadraticChar`. Show it is the unique order-2 character. Connect to splitting behavior in quadratic extensions.

**Domain Bridges:** Algebraic number theory ↔ Galois theory ↔ Representation theory ↔ Automorphic forms

**Lineage:** Extends the `legendreWitness` from a computational wrapper to a character-theoretic foundation.

**Ambition:** Grand challenge. Full class field theory is out of reach, but the finite-field character perspective is achievable.

---

## Direction 5: Computational Complexity of Proof-Extracted Algorithms

**Conjecture:** The algorithms extracted from different proofs of quadratic reciprocity have provably different computational complexities. Specifically: the Jacobi symbol algorithm (from reciprocity + supplementary laws) runs in O(log² n) time, while the Gauss lemma algorithm runs in O(n) time, and no proof in the "Gauss lemma family" can yield a sub-linear algorithm.

**Test:** Formalize the Jacobi symbol algorithm in Lean with a certified time bound. Prove that it computes the Legendre symbol correctly (using `quadratic_reciprocity_eisenstein` and the supplementary laws). Prove a lower bound: any algorithm that explicitly enumerates upper-half residues requires Ω(p) steps. Benchmark the implementations in Python for primes up to 10^6.

**Impact:** This would demonstrate that proof comparison has *computational* consequences: different proofs yield different algorithms with different complexities. This is a concrete example of "proof mining" — extracting quantitative information from the structure of proofs.

**Catalog References:** `Catalog/Algebra/QuadraticReciprocity/Core.lean` — `upperHalfResidueCount`, `eisensteinFloorSum`

**Proof Strategy:** The upper bound for Jacobi follows from the analysis of the Euclidean algorithm. The lower bound for Gauss-type algorithms follows from the observation that the count depends on all (p-1)/2 residues.

**Domain Bridges:** Computational complexity ↔ Number theory ↔ Proof theory ↔ Algorithm design

**Lineage:** Extends the Python benchmarks in `algorithms.py` to formal complexity analysis.

**Ambition:** Medium-high. The upper bound is standard; the lower bound formalization is novel but straightforward.
