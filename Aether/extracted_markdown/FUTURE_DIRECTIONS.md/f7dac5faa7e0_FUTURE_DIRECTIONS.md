# Future Directions: Arithmetic TDA Pipeline

## Synthesis

The results established in this cycle — formally verified torsion prime profile extraction from Smith normal form data, the Tor₁ detection bridge, and degreewise signature assembly — form the mathematical kernel of arithmetic TDA. They demonstrate that torsion information is computationally native: asymptotically free beyond the Smith computation. The directions below extend this kernel in five complementary ways: (1) persistent torsion tracking across filtrations, (2) p-adic refinement of the prime profile, (3) stability of torsion under perturbation, (4) connecting to persistent homology of real datasets, and (5) a grand challenge linking torsion complexity to matrix multiplication exponent bounds. Each direction builds directly on the verified theorems and is formulated as a falsifiable hypothesis.

---

## Direction 1: Persistent Torsion Prime Barcodes

**Conjecture**: For a filtered simplicial complex K with filtration K₀ ⊂ K₁ ⊂ ... ⊂ Kₙ, the torsion prime profile function t(i) = TorsionPrimeProfile(Hₖ(Kᵢ; ℤ)) satisfies an interval decomposition: for each prime p, the set {i : p ∈ t(i)} is a union of at most β̃ₖ intervals (where β̃ₖ is the rank of Hₖ over Z/pZ). This would yield a "torsion barcode" analogous to the standard persistence barcode.

**Test**: Implement the persistent torsion profile on random Vietoris-Rips filtrations with 50-200 points. For each prime p ≤ 13, check whether the support set {i : p ∈ t(i)} is indeed a union of intervals. Count exceptions. If more than 5% of instances violate the interval structure, the conjecture is false.

**Impact**: If true, this would give arithmetic TDA a full persistence theory: not just which primes appear, but when they appear and disappear. This is the natural next step from the degreewise union theorem (Theorem 3.6).

**Catalog References**: `Pythagorean/ArithmeticTDAPipeline.lean` (DegreewiseTorsionSignature, degreewise_signature_of_smith); `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (torsion birth/death definitions).

**Proof Strategy**: Use the structure theorem for persistence modules over PID (Z is a PID). The key is whether the Smith normal form of the filtered boundary matrices produces invariant factors that vary monotonically with the filtration parameter. Decompose into interval modules using the Crawley-Boevey theorem.

**Domain Bridges**: Computational topology ↔ persistence theory; connects to barcode stability results (Bauer-Lesnick).

**Lineage**: Extends degreewise_signature_eq_biUnion to filtered settings.

**Ambition**: solid_extension

---

## Direction 2: p-Adic Torsion Exponent Profiles

**Conjecture**: The full invariant factor structure (not just prime support) of a finitely generated abelian group is captured by a "p-adic valuation profile" v_p(A) = max{k : ∃ a ∈ A, order(a) = p^k}, and this profile satisfies v_p(A × B) = max(v_p(A), v_p(B)) for all primes p. Furthermore, v_p can be extracted from Smith data in O(Σ log² dᵢ) time.

**Test**: Compute v_p for random products of cyclic groups Z/d₁Z × ... × Z/dₖZ with dᵢ ∈ {2, ..., 100}. Verify the max formula for 1000 random pairs. If any counterexample is found, the conjecture is false (it shouldn't be — this is a well-known property, but the computational extraction claim needs verification).

**Impact**: Refines the torsion prime profile from a set of primes to a function from primes to exponents. This captures strictly more information: Z/4Z and Z/2Z × Z/2Z have the same prime profile {2} but different exponent profiles (v₂ = 2 vs v₂ = 1).

**Catalog References**: `Pythagorean/ArithmeticTDAPipeline.lean` (TorsionPrimeProfile, smith_extraction_finset).

**Proof Strategy**: Define v_p using additive order of elements. Prove the max formula by reducing to cyclic groups via Smith decomposition. The extraction algorithm computes max p-adic valuations of the Smith diagonal entries.

**Domain Bridges**: Number theory (p-adic valuations) ↔ computational topology; connects to the theory of p-groups.

**Lineage**: Refines TorsionPrimeProfile from Set ℕ to ℕ →₀ ℕ (finitely supported function).

**Ambition**: solid_extension

---

## Direction 3: Stability of Torsion Prime Profiles Under Perturbation

**Conjecture**: For two simplicial complexes K and K' that differ by at most δ simplices (in the edit distance), the symmetric difference of their arithmetic signatures satisfies |ATS(K) △ ATS(K')| ≤ f(δ) for some explicit function f. Specifically, we conjecture f(δ) = O(δ): adding or removing one simplex changes the torsion prime profile by at most a bounded number of primes.

**Test**: Generate random simplicial complexes with 100 vertices. Compute ATS(K). Add/remove 1, 2, 5, 10 simplices to get K'. Compute ATS(K') and measure the symmetric difference. Plot |ATS(K) △ ATS(K')| vs δ for 500 trials. If the relationship is super-linear, the conjecture is false.

**Impact**: Stability is the fundamental prerequisite for any topological invariant to be useful in practice. Without stability, small perturbations in the input data could produce wildly different torsion signatures, making them useless for data analysis.

**Catalog References**: `Pythagorean/ArithmeticTDAPipeline.lean` (torsionPrimeProfile_congr — invariance under isomorphism is the δ=0 case).

**Proof Strategy**: Use the long exact sequence in homology for the pair (K', K). The connecting homomorphism bounds how torsion can change. The key is to show that adding one simplex changes the Smith diagonal by a bounded amount.

**Domain Bridges**: Computational topology ↔ metric geometry; connects to persistence diagram stability (bottleneck distance).

**Lineage**: Extends torsionPrimeProfile_congr from exact isomorphisms to approximate correspondences.

**Ambition**: grand_challenge

---

## Direction 4: Arithmetic TDA for Materials Science Data

**Conjecture**: The torsion prime profile of the Vietoris-Rips complex of a crystal structure encodes the symmetry class of the crystal. Specifically, for the 230 crystallographic space groups, the function mapping a space group to the torsion prime profile of its quotient space is injective on "most" (> 90%) pairs of space groups with identical Betti numbers.

**Test**: Compute the integral homology of the quotient spaces Γ\ℝ³ for the 230 crystallographic space groups (many are known in the literature). Extract torsion prime profiles. Count the number of pairs (G₁, G₂) with identical Betti numbers but different torsion profiles. If this exceeds 90% of same-Betti pairs, the conjecture is confirmed.

**Impact**: This would be the first application of arithmetic TDA to materials science: a computationally cheap way to distinguish crystal structures that look topologically identical to standard TDA.

**Catalog References**: `Pythagorean/ArithmeticTDAPipeline.lean` (compute_torsion_primes_from_smith — the extraction algorithm); `Catalog/Pythagorean/ArithmeticPhaseClassification.lean` (arithmetic phase profiles for groups).

**Proof Strategy**: Primarily computational. Use existing databases of crystallographic space groups and their homology. The formal component would be to verify the torsion computations for specific small examples.

**Domain Bridges**: Computational topology ↔ crystallography ↔ materials science.

**Lineage**: Applies the computational pipeline to a concrete scientific domain.

**Ambition**: solid_extension

---

## Direction 5: Torsion Complexity and the Matrix Multiplication Exponent

**Conjecture**: Computing the full torsion prime profile of a simplicial complex with N simplices requires Ω(N^ω) time, where ω is the matrix multiplication exponent. That is, torsion profile computation is asymptotically equivalent to Smith normal form computation, and no shortcut exists that avoids the full matrix decomposition.

Equivalently: arithmetic TDA is asymptotically no harder than linear-algebraic TDA (our upper bound), and also no easier (the lower bound). The torsion prime profile is a "complete" invariant for the computational complexity of integral homology.

**Test**: Construct families of simplicial complexes where the torsion prime profile can be computed without full SNF (e.g., using partial factorization or modular reductions). Measure whether the runtime scales as O(N^(ω-ε)) for any ε > 0. If such a shortcut exists and can be verified on complexes up to N = 10000, the lower bound conjecture is false.

**Impact**: This would establish that torsion computation is computationally equivalent to matrix algebra — neither harder (already proven) nor easier (the conjecture). It would mean that any improvement in Smith normal form algorithms automatically improves torsion computation, and vice versa.

**Catalog References**: `Pythagorean/ArithmeticTDAPipeline.lean` (computeTorsionPrimesFromSmith_correct — the upper bound).

**Proof Strategy**: For the lower bound, reduce matrix multiplication to torsion profile computation. Construct a family of simplicial complexes whose torsion encodes the product of two matrices. This is a circuit complexity argument.

**Domain Bridges**: Computational complexity ↔ algebraic topology; connects to the rich literature on matrix multiplication lower bounds.

**Lineage**: Complements the upper bound established in this cycle with a matching lower bound.

**Ambition**: grand_challenge

---

## Summary of Testable Predictions

| Direction | Conjecture | Key Test | Falsification Criterion |
|-----------|-----------|----------|------------------------|
| 1 | Persistent torsion barcodes | Interval structure of prime support | >5% non-interval instances |
| 2 | p-adic exponent profiles | Max formula for products | Any counterexample |
| 3 | Stability under perturbation | Symmetric difference vs edit distance | Super-linear growth |
| 4 | Crystal classification | Torsion distinguishes space groups | <90% discrimination |
| 5 | Torsion ≡ matrix multiplication | Shortcut algorithms | Sub-N^ω torsion computation |
