# Future Directions: Shadow-Based Circuit Lower Bounds for the Permanent

## Synthesis

The exact shadow formula |Sh₂(suppPerm(n))| = C(n,2)² · (n-2)! reveals that the permanent's monomial support has a rigid combinatorial geometry far more structured than previously suspected. The uniform completion multiplicity of 2 transforms the shadow from a mysterious lower-bound object into a precisely enumerable combinatorial family. Together, these results establish a complete pipeline from support combinatorics through shadow expansion to (conditional) circuit lower bounds.

The five directions below form a coherent research program: Direction 1 extends the shadow formula to all depths (solidifying the foundation), Direction 2 bridges to the algebraic certificate framework (activating the lower bound), Directions 3 and 4 expand the method to broader polynomial families, and Direction 5 connects to statistical physics, potentially importing powerful external tools.

---

## Direction 1: Complete Proof of the Higher Shadow Formula

**Conjecture.** For all 0 ≤ k ≤ n,

|Sh_k(suppPerm(n))| = C(n,k)² · (n-k)!

and every (n-k)-partial permutation support extends to exactly k! full permutations.

**Test.** Already verified computationally for n ≤ 8, k ≤ n. A formal proof would require showing: (a) the k-shadow characterization (generalizing Theorem 1), (b) the completion multiplicity equals k! (generalizing Theorem 3), and (c) the double-counting identity n! · C(n,k) = C(n,k)² · (n-k)! · k!.

**Impact.** Would provide a complete shadow profile of the permanent support — the first such result for any non-trivial polynomial family. Would yield sharper conditional lower bounds at multiple shadow depths.

**Catalog References.** `Pythagorean/PermanentShadow.lean` (Theorems 1-3), `Pythagorean/NonCancellationCertificate.lean`.

**Proof Strategy.** Generalize the defect analysis: an (n-k)-partial permutation support has k defect rows and k defect columns, and completion requires a bijection between them — k! choices. The double-counting identity follows from C(n,k) · k! · (n-k)! = n!.

**Domain Bridges.** Combinatorics ↔ Complexity theory; rook polynomial theory ↔ shadow enumeration.

**Lineage.** Direct extension of the k=2 case proved in `PermanentShadow.lean`.

**Ambition.** solid_extension — extends the core theorem package to all depths.

**"The key insight is..."** that the completion multiplicity k! is exactly the number of bijections between k-element sets, making the counting argument uniform across all shadow levels.

**"Why now?"** The k=2 case is formally verified, and the proof method (defect analysis + double counting) generalizes mechanically.

---

## Direction 2: Unconditional Non-Cancellation Transfer for the Permanent

**Conjecture.** The permanent polynomial over ℚ satisfies the full non-cancellation certificate hypotheses from `NonCancellationCertificate.lean`, enabling unconditional transfer of the shadow lower bound to a circuit lower bound of size Ω(2^(n/2) / poly(n)).

**Test.** Formalize that: (1) all permanent coefficients are +1 (positive, no cancellation); (2) the Hessian support of the permanent is exactly the predicted quadratic leaf set; (3) these conditions compose under the iterated differentiation scheme in the certificate framework.

**Impact.** Would yield the first super-polynomial arithmetic circuit lower bound for the permanent via purely combinatorial methods — a paradigm-shifting result in complexity theory.

**Catalog References.** `Pythagorean/NonCancellationCertificate.lean` (non-cancellation framework), `Algebra/AlgebraicCircuitComplexity.lean` (circuit model).

**Proof Strategy.** The permanent has all coefficients equal to 1, so no cancellation occurs in any partial derivative. The chain: (a) verify the Hessian support exactly matches the quadratic leaf set of the permanent's support, (b) verify the Hessian scalar is nonzero (which holds over ℚ by `hessianScalar_pos`), (c) apply the certificate theorem.

**Domain Bridges.** Algebraic complexity ↔ Combinatorics; coefficient positivity ↔ support geometry.

**Lineage.** Combines the shadow enumeration (this work) with the existing certificate framework.

**Ambition.** grand_challenge — would resolve a major open problem in complexity theory.

**"The key insight is..."** that the permanent's positive coefficients make non-cancellation trivially hold at the coefficient level, and the shadow formula provides the combinatorial lower bound that the certificate converts to a circuit bound.

**"Why now?"** Both the combinatorial side (exact shadow formula) and the algebraic side (non-cancellation certificate) are now formalized; only the interface theorem remains.

---

## Direction 3: Shadow Analysis of Immanants and Character-Weighted Permanents

**Conjecture.** For the immanant associated to an irreducible character χ of S_n, the k-shadow of its support satisfies

|Sh_k(supp(Imm_χ))| ≥ C(n,k)² · (n-k)! · dim(χ) / n!

where the support is weighted by the character values. For the sign character (determinant), the shadow degenerates; for the trivial character (permanent), it matches our formula.

**Test.** Compute immanant supports for standard and hook characters of S_n for n = 4, 5, 6 and compare shadow sizes to the conjectured formula.

**Impact.** Would extend the shadow lower bound method from the permanent to a family of polynomials parameterized by representations of S_n, potentially revealing which polynomials are "hard" from a shadow perspective.

**Catalog References.** `Pythagorean/PermanentShadow.lean`, representation theory of S_n.

**Proof Strategy.** Use the Schur-Weyl duality to decompose immanant supports into irreducible components. The shadow of each component should be controlled by the corresponding Young diagram's structure.

**Domain Bridges.** Representation theory ↔ Complexity theory; Young tableaux ↔ shadow geometry.

**Lineage.** Generalizes the permanent shadow analysis to the full immanant family.

**Ambition.** solid_extension — natural generalization with rich mathematical content.

**"The key insight is..."** that the shadow structure of a polynomial's support reflects the representation-theoretic symmetry of the polynomial, and the permanent's maximal shadow expansion corresponds to its maximal symmetry type (trivial representation).

**"Why now?"** The permanent case provides the template, and Mathlib's group representation infrastructure supports the generalization.

---

## Direction 4: Tropical Shadow Geometry and Matroid Connections

**Conjecture.** The permanent support family forms a **transversal matroid**, and its shadow hierarchy corresponds to the matroid's truncation hierarchy. The exact shadow formula C(n,k)² · (n-k)! is a special case of the Whitney numbers of the matroid's lattice of flats.

**Test.** Verify that the permanent support family satisfies the matroid exchange axiom. Compute the characteristic polynomial of the corresponding matroid and compare its coefficients to the shadow sizes.

**Impact.** Would connect circuit lower bounds to matroid theory, potentially importing tools from tropical geometry and the theory of valuated matroids. The matroid perspective could reveal which polynomial support families have maximal shadow expansion.

**Catalog References.** `Pythagorean/PermanentShadow.lean`, tropical geometry infrastructure in the Catalog.

**Proof Strategy.** The permutation supports form the bases of the transversal matroid of K_{n,n}. The shadow at depth k consists of the (n-k)-element independent sets. The formula should follow from the matroid's rank function and Whitney's theorem.

**Domain Bridges.** Matroid theory ↔ Complexity theory ↔ Tropical geometry.

**Lineage.** New perspective on the permanent shadow, connecting to a different mathematical framework.

**Ambition.** grand_challenge — could create a new bridge between matroid theory and circuit complexity.

**"The key insight is..."** that the permanent support is not merely a combinatorial family but a matroid, and matroid theory provides powerful structural theorems (Whitney numbers, Tutte polynomials, basis exchange) that could constrain shadow behavior in ways not visible from pure set-theoretic methods.

**"Why now?"** The exact shadow formula reveals a level of structure (clean factorization, uniform multiplicity) that is characteristic of matroids, suggesting the matroid framework is the natural home for these results.

---

## Direction 5: Monomer-Dimer Thermodynamics and Circuit Complexity

**Conjecture.** The shadow hierarchy of the permanent encodes the partition function hierarchy of the monomer-dimer model on K_{n,n}. Specifically, the k-shadow counts configurations with exactly k monomers per side, and the ratio

Z_k / Z_0 = C(n,k) / k!

where Z_0 = n! (perfect dimer partition function) and Z_k = C(n,k)² · (n-k)! (k-monomer partition function). This ratio has a thermodynamic interpretation as the free energy cost of introducing k defects.

**Test.** Compute the monomer-dimer partition functions for K_{n,n} for n ≤ 8 and verify the ratio formula. Investigate whether the free energy landscape (as a function of monomer density) exhibits phase transition-like behavior.

**Impact.** Would create a bridge between statistical physics and circuit complexity, potentially importing techniques from the theory of phase transitions, correlation decay, and partition function zeros (Lee-Yang theory) to prove lower bounds.

**Catalog References.** `Pythagorean/PermanentShadow.lean`, statistical physics literature on dimer models.

**Proof Strategy.** Use the exact shadow formula to compute the k-monomer partition function. Analyze the generating function Σ_k Z_k · x^k as a polynomial in x and relate its roots to circuit complexity via connections to #P-hardness.

**Domain Bridges.** Statistical physics ↔ Complexity theory; dimer models ↔ support geometry; phase transitions ↔ computational hardness.

**Lineage.** New cross-domain bridge inspired by the exact counting results.

**Ambition.** grand_challenge — could import powerful physical intuition into complexity theory.

**"The key insight is..."** that the shadow hierarchy is secretly a partition function hierarchy, and the tools of statistical mechanics (correlation functions, cluster expansions, transfer matrices) provide an entirely new language for expressing and proving circuit lower bounds.

**"Why now?"** The exact formula Z_k = C(n,k)² · (n-k)! is now rigorously established (for k=2) and computationally verified (for all k ≤ n ≤ 8), making the statistical physics interpretation precise and testable.
