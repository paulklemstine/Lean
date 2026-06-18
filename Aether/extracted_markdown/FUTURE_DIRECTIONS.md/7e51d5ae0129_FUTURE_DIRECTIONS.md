# Future Directions: Tropical Satake Theory for Reductive Groups

## Hypothesis 1: Tropical Satake = Permutahedral Support Equivalence

**Conjecture.** For every dominant weight λ of GL_n, the tropical Schur function tropSchur(λ, x) equals the support function of the permutahedron P(λ) = conv{σ · λ : σ ∈ S_n}, evaluated in the min-convention:

    tropSchur(λ, x) = min_{v ∈ P(λ)} ⟨v, x⟩

Moreover, tropical multiplication (pointwise addition) of tropical Schur functions corresponds to Minkowski addition of the associated permutahedra:

    tropSchur(λ, x) + tropSchur(μ, x) ≤ tropSchur(λ + μ, x)

with equality holding precisely when λ and μ are "convolutionally compatible" (i.e., the minimizing permutations for λ and μ can be taken to coincide).

**Test.** Formalize the polyhedral support function h_P(x) = min_{v ∈ P} ⟨v, x⟩ in Lean 4 and prove equality with tropSchur for n ≤ 6 computationally. For the Minkowski inequality, compute both sides for all pairs of dominant weights in GL_3, GL_4, GL_5 with entries ≤ 5 and characterize when equality holds.

**Impact.** This would establish a formal bridge between tropical Satake theory and polyhedral combinatorics, enabling tools from convex optimization (e.g., support function arithmetic, Minkowski decomposition) to be applied to Hecke algebra computations. It would also connect to MV polytope theory in geometric representation theory.

---

## Hypothesis 2: Injectivity Extends to Other Root Systems

**Conjecture.** The orbit-min construction yields an injective tropical Satake map for all classical root systems:
- **Type B_n / C_n**: Replace S_n with the hyperoctahedral group (signed permutations on n elements, order 2^n · n!). Define tropSchur_B(λ, x) = min_{σ ∈ W(B_n)} ∑ λ(σ(i)) x(i) where W(B_n) acts by permutations and sign changes.
- **Type D_n**: Use the even-signed permutation group (order 2^{n-1} · n!).

For each type, the map λ ↦ tropSchur_W(λ) should be injective on dominant weights.

**Test.**
1. Define the signed permutation action for B_2, B_3, B_4 in Lean 4.
2. Verify injectivity computationally: enumerate dominant weights with entries ≤ 5 and check fingerprint distinctness.
3. Attempt a uniform proof by adapting the test-vector construction. The test vectors will need to account for sign changes: use e_k(i) = 1 if |i| ≥ k, with appropriate sign conventions.

**Impact.** A positive result would extend the tropical Satake framework from GL_n to all classical groups, covering the main cases of interest in representation theory and creating a unified tropical theory for the Langlands program.

---

## Hypothesis 3: Tropical Hecke Multiplication Matches Polyhedral Minkowski Structure

**Conjecture.** Define tropical Hecke convolution on basis elements by:

    (δ_λ ⊗ δ_μ)(x) = min_{y + z = x} (tropSchur(λ, y) + tropSchur(μ, z))

where the min is over all decompositions x = y + z. Then:

    δ_λ ⊗ δ_μ = ∑^{trop}_{ν} c^ν_{λμ} ⊗ δ_ν

where the tropical structure constants c^ν_{λμ} are determined by the Minkowski decomposition of P(λ) + P(μ) into a "min-plus combination" of permutahedra P(ν).

**Test.** Compute the tropical convolution δ_λ ⊗ δ_μ for all pairs of dominant weights in GL_3 with entries ≤ 3. Decompose the result into the tropical Schur basis and compare the coefficients with the Minkowski structure of the corresponding permutahedra. Verify at least 20 cases in GL_4.

**Impact.** This would establish that the tropical Satake isomorphism is not just a basis bijection but a full semiring isomorphism, upgrading the current result from a correspondence of generators to a correspondence of algebras. It would also provide a combinatorial algorithm for computing Hecke algebra structure constants.

---

## Hypothesis 4: Tropical Satake Detects the Dominance Order

**Conjecture.** For dominant weights λ, μ of GL_n:

    λ ⪯_dom μ  ⟺  ∀ x ∈ ℤⁿ (decreasing), tropSchur(λ, x) ≤ tropSchur(μ, x)

where λ ⪯_dom μ means ∑_{i=0}^{k} λ(i) ≤ ∑_{i=0}^{k} μ(i) for all k, with equality at k = n-1 (majorization/dominance order).

The forward direction (⪯_dom implies pointwise ≤ on decreasing inputs) should follow from the rearrangement inequality. The converse requires showing that if λ is not dominated by μ, there exists a decreasing test vector that separates them.

**Test.** For GL_3, GL_4, GL_5, enumerate all pairs of dominant weights with entries ≤ 5 and check both directions. If the conjecture is true, verify the forward direction formally in Lean 4. If false, classify the counterexamples and determine whether a modified statement (e.g., restricting to strictly decreasing x, or using a different ordering) rescues the correspondence.

**Impact.** The dominance order is fundamental in combinatorics, representation theory, and majorization theory (with applications to quantum information, economics, and statistics). A formal link between the dominance order and tropical Schur evaluation would make the tropical Satake framework a computational tool for these areas. It would also connect to Schur-convexity, a classical topic in inequality theory.

---

## Hypothesis 5: Tropical Schur Basis Admits Polynomial-Size Circuits

**Conjecture.** For each dominant weight λ of GL_n, the function x ↦ tropSchur(λ, x) can be computed by a min-plus circuit (a DAG with min and + gates) of size O(n^c) for some constant c, rather than the naive O(n! · n) obtained by orbit enumeration.

More precisely, the optimal circuit size for tropSchur(λ, x) is Θ(n log n) when λ has distinct entries, achieved by a sorting network that pairs the entries of λ and x in opposite orders (by the rearrangement inequality, the minimum over permutations is the "antidiagonal" pairing).

**Test.**
1. Implement circuit synthesis for tropSchur using known sorting network constructions (e.g., AKS network, bitonic sort) and verify correctness against naive enumeration for n ≤ 8.
2. Measure circuit size as a function of n and compare with theoretical bounds.
3. For weights with repeated entries, investigate whether smaller circuits are possible by exploiting the reduced orbit size.

**Impact.** A positive result would transform the tropical Satake framework from a theoretical tool to a practical computational one. It would connect to:
- Circuit complexity theory (min-plus circuits are a central model)
- Algorithm design for symmetric optimization
- Efficient evaluation of spherical functions in computational number theory

The O(n log n) bound would make tropical Satake computations feasible for n in the hundreds or thousands, enabling applications to large-scale assignment problems and neural network symmetry reduction.
