# Future Directions: Primewise Persistence and Arithmetic Obstructions

## Synthesis

This research cycle established a novel bridge between persistent homology and arithmetic obstruction theory. The key construction — associating a family of prime-indexed Frobenius orbit signatures to an arithmetic object and analyzing these signatures via chain complex invariants — was formalized with machine-verified proofs of core structural theorems: fixed point monotonicity under divisibility, Euler characteristic additivity and boundedness, cofinal separation characterization, and the Frobenius-chain complex correspondence.

The most promising cross-domain connection discovered is the **Euler characteristic bridge**: the alternating sum of Frobenius fixed point counts simultaneously encodes topological (chain complex) and arithmetic (L-function coefficient) information. This dual interpretation opens pathways in both directions — using topological machinery to study arithmetic questions, and using arithmetic data to generate topological invariants. The existing catalog theorems on local-global obstructions (`Algebra/LocalGlobal.lean`) provide the arithmetic foundation, while the Frobenius orbit machinery (`Pythagorean/DynamicalSquaring.lean`) provides group-theoretic infrastructure.

The highest breakthrough potential lies in Direction 1 below: if the Hasse separation conjecture holds, it would create an entirely new computational approach to detecting Tate-Shafarevich group elements, bypassing the algebraic complexity of Brauer-Manin obstructions. Even a partial result — showing separation for specific curve families — would be significant.

---

### Direction 1: Prove Hasse Separation for CM Curves

**Conjecture**: For any elliptic curve E/ℚ with complex multiplication and any genus-one curve C in Ш(E/ℚ)[n] for some n ≥ 2, the Frobenius orbit signatures of E and C are cofinally distinguished at depth 2. Specifically, for all but finitely many primes p of good reduction, the Frobenius traces a_p(E) and a_p(C) differ.

**Test**: Take E: y² = x³ - x (CM by ℤ[i]) and construct explicit elements of Ш(E/ℚ) using 2-descent. Compute Frobenius traces for both E and the Ш-elements at all primes p < 50000. The conjecture predicts disagreement at a density bounded below by 1/[Ш:1].

**Impact**: If true, this would give the first topological criterion for detecting non-trivial Tate-Shafarevich elements, applicable to all CM curves simultaneously. If false, it would reveal that Frobenius trace data is insufficient for Hasse detection, redirecting research toward higher cohomological invariants.

**Catalog References**: `Algebra/LocalGlobal.lean` (mod9_obstruction_from_local), `Pythagorean/DynamicalSquaring.lean` (prime_has_two_fixed_points), `Speculative/PrimewisePersistence/Core.lean` (cofinallyDistinguished_imp_separated)

**Proof Strategy**: Use the theory of CM elliptic curves to explicitly compute Frobenius traces: for E with CM by K, a_p depends on the splitting of p in K. For a non-trivial torsor C, the trace is twisted by a character of the class group. Key lemma: if C represents a non-trivial element of Ш, the twisting character is non-trivial, so traces differ at primes determined by the character. Use Chebotarev density to show the set of disagreeing primes has positive density.

**Domain Bridges**: NumberTheory <-> Topology, Algebra <-> PersistentHomology

**Lineage**: Builds on the Frobenius chain complex construction and separation theorems from this cycle. Extends `mod9_obstruction_from_local` from finite modular obstructions to prime-indexed persistence obstructions.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Persistence Signatures via Valuations

**Conjecture**: For an elliptic curve E/ℚ with split multiplicative reduction at a prime p, the tropical curve Trop(E) at p determines the persistence barcode of the Frobenius chain complex at p up to a universal shift depending only on the Kodaira type.

**Test**: Compute tropical curves for Tate curves with known q-parameters at primes of multiplicative reduction. Compare the resulting tropical Betti numbers with the Frobenius persistence barcodes. The conjecture predicts agreement after a shift by the valuation of the discriminant.

**Impact**: This would establish a direct functor from tropical geometry to persistence homology in the arithmetic setting, creating a triangle: arithmetic → tropical → topological persistence. It would also give tropical interpretations of Frobenius fixed point counts via intersection theory on the tropical curve.

**Catalog References**: `Tropical/` (tropical geometry infrastructure), `Speculative/PrimewisePersistence/Core.lean` (frobeniusChainComplex, frobeniusEulerChar_eq_alternatingSum), `Algebra/LocalGlobal.lean` (local-global framework)

**Proof Strategy**: At a prime of split multiplicative reduction, E reduces to a nodal cubic whose tropicalization is a circle graph. The Frobenius action on the tropical curve has a combinatorial description in terms of the q-parameter. Express iterFixedCount in terms of tropical intersection numbers and use the tropical Riemann-Roch theorem. Key lemma: the tropical Euler characteristic equals the Frobenius chain complex Euler characteristic when the reduction is split multiplicative.

**Domain Bridges**: Tropical <-> NumberTheory, Tropical <-> Topology

**Lineage**: Extends the Frobenius chain complex bridge from this cycle into tropical geometry. Connects to existing Tropical catalog infrastructure.

**Ambition**: extension

---

### Direction 3: Neural Signature Classifiers for Arithmetic Objects

**Conjecture**: A feedforward neural network with O(log N) hidden neurons, trained on Frobenius trace vectors (a_{p_1}, ..., a_{p_k}) for primes p_i ≤ N, can classify whether a genus-one curve has a rational point with accuracy > 1 - ε for any ε > 0, provided k = Ω(log N / log log N).

**Test**: Generate a dataset of 10,000 elliptic curves over ℚ with known rational point status. Compute Frobenius traces at primes up to 10000. Train a classifier and measure accuracy as a function of the number of primes used. The conjecture predicts a logarithmic threshold for high accuracy.

**Impact**: This would demonstrate that the Hasse principle obstruction is learnable from finite prime data, with explicit sample complexity bounds. It connects arithmetic geometry to machine learning theory and could lead to practical tools for number theorists.

**Catalog References**: `MachineLearning/NeuralSheafCohomology.lean` (exists_global_radius_of_finite_local_witnesses), `Speculative/PrimewisePersistence/Core.lean` (ArithmeticObject, PrimewiseSeparated)

**Proof Strategy**: The key is the Chebotarev density theorem, which ensures that Frobenius traces at primes up to N determine the Galois representation up to bounded error. A VC-dimension argument then bounds the number of primes needed for classification. Key lemma: the set of curves with a given Frobenius trace pattern at k primes has VC dimension O(k), enabling PAC-learning bounds.

**Domain Bridges**: MachineLearning <-> NumberTheory, MachineLearning <-> Topology

**Lineage**: Builds on the neural sheaf cohomology framework in the catalog and extends the prime signature separation results from this cycle.

**Ambition**: extension

---

### Direction 4: Persistence Homology of the Tate-Shafarevich Group

**Conjecture**: For an elliptic curve E/ℚ with Ш(E/ℚ) ≅ (ℤ/nℤ)², the persistence barcode of the Frobenius chain complex at depth d ≥ 2n has exactly n² - 1 intervals of length ≥ 2, and the total persistence is asymptotically (n² - 1) · log log X as X → ∞ (where X bounds the primes considered).

**Test**: Compute persistence barcodes for curves with known Ш of order 4, 9, and 16. Compare the interval count and total persistence with the predicted formulas. Verify the asymptotic by extending the prime range to 10⁶.

**Impact**: If true, this would give a direct topological readout of the order of Ш from Frobenius data alone — a computable shadow of one of the most mysterious objects in arithmetic geometry. This could lead to new computational methods for the BSD conjecture.

**Catalog References**: `Speculative/PrimewisePersistence/Core.lean` (PersistenceModule, persistent_rank_le_rank), `Algebra/LocalGlobal.lean` (local-global framework)

**Proof Strategy**: Use the Cassels-Tate pairing on Ш to decompose the Frobenius data into n² components. Each non-trivial component contributes one persistence interval. The length-2 lower bound follows from the fact that non-trivial Ш elements twist Frobenius traces at density 1/n of primes (by Chebotarev). The asymptotic follows from prime counting with character sums.

**Domain Bridges**: NumberTheory <-> Topology, Algebra <-> PersistentHomology

**Lineage**: Directly extends the Hasse separation conjecture from this cycle to a quantitative prediction about the structure of Ш.

**Ambition**: grand_challenge

---

### Direction 5: Fixed Point Zeta Functions and p-adic Persistence

**Conjecture**: The generating function Z_F(t) = exp(Σ_{k≥1} iterFixedCount(F, k) · t^k / k) of a Frobenius action F is a rational function of t, and its poles determine the persistence barcode of the Frobenius chain complex in a functorial way.

**Test**: For Frobenius actions arising from elliptic curves mod p, verify that Z_F(t) = (1 - a_p t + p t²) / ((1 - t)(1 - pt)) (the Hasse-Weil zeta function). Compute persistence barcodes from the poles and compare with direct computation.

**Impact**: This would give an analytic interpretation of persistence barcodes via zeta functions, connecting the framework to the Weil conjectures and Grothendieck's étale cohomology. It would also provide a canonical persistence module associated to any variety over a finite field.

**Catalog References**: `Speculative/PrimewisePersistence/Core.lean` (identity_iterFixedCount, trivial_frobenius_euler), `Pythagorean/TropicalBerggrenZeta.lean` (prime_one_mod_four_has_sum_two_squares)

**Proof Strategy**: Use the Lefschetz fixed point theorem for étale cohomology: |Fix(σ^k)| = Σ (-1)^i Tr(σ^k | H^i). The generating function then factors according to the eigenvalues of Frobenius on each cohomology group. Key lemma: the persistence barcode intervals correspond to pairs of eigenvalues (or poles) of Z_F(t), with birth/death determined by their relative p-adic valuations.

**Domain Bridges**: NumberTheory <-> Topology, Algebra <-> Analysis

**Lineage**: Extends the Frobenius-Euler characteristic bridge from this cycle to a full zeta function correspondence. Builds on the sum-of-two-squares theorem as a model case.

**Ambition**: extension
