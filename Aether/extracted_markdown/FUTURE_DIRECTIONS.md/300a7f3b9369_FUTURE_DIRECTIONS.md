# Future Directions: Primewise Persistent Homology

## Synthesis

The five directions below form a coherent research program extending primewise persistent homology from its current foundations (Shannon entropy monotonicity, bottleneck stability, Pythagorean counting) into deeper arithmetic territory. The first two directions (Conjectures 1–2) are *grand challenges* that would connect barcode theory to the Langlands program and tropical geometry. The remaining three (Conjectures 3–5) are *solid extensions* building directly on the verified theorems, each provable within 6–12 months. Together, they aim to establish primewise persistence as a permanent computational interface between topological data analysis and arithmetic geometry.

---

## Direction 1: Barcode Modularity for Elliptic Curves

**Conjecture.** For every elliptic curve E/ℚ of conductor N, there exists a degree-1 barcode statistic T_bar(E, p) — computed from the persistence of the arithmetic Čech nerve at prime p — such that for all primes p ∤ N,
$$|T_{\text{bar}}(E, p) - a_p(E)| \leq C \cdot p^{-1/4}$$
where C depends only on N and a_p(E) = p + 1 − #E(𝔽_p) is the Frobenius trace.

**Test.** For curves in the LMFDB with conductor N ≤ 100, compute T_bar(E, p) for all good primes p ≤ 1000. Compare with tabulated a_p values. The conjecture fails if the error grows faster than p^{-1/4} for any curve. A single persistent counterexample at large p disproves the exact-decay form.

**Impact.** If true, this creates the first *barcode estimator for modular form coefficients*, opening a purely combinatorial route to modularity detection. This would bridge topological data analysis and the Langlands program at a computational level.

**Catalog References.** `Pythagorean/PrimewisePersistence/Stability.lean` (ArithmeticBarcodeSignature), `Pythagorean/PrimewisePersistence/Arithmetic.lean` (pythagoreanCount).

**Proof Strategy.** (1) Relate degree-1 persistent generators to cycle classes in the reduction graph. (2) Define a Frobenius-equivariant pairing on persistence intervals. (3) Show the signed sum equals a_p via the Lefschetz trace formula applied to the nerve filtration. Key obstacle: formalizing the nerve theorem for arithmetic covers.

**Domain Bridges.** Arithmetic geometry ↔ TDA ↔ Modular forms ↔ Automorphic representations.

**The key insight is** that barcode statistics are finite, computable shadows of the Frobenius endomorphism acting on cohomology, and the persistence pairing structure captures the signed trace.

**Why now?** Persistent homology algorithms are now efficient enough to handle the filtrations arising from arithmetic data at primes up to 10⁴, and the LMFDB provides millions of verified a_p values for comparison.

**Lineage.** Extends pythagorean_count_* and ArithmeticBarcodeSignature.

**Ambition.** Grand challenge — would unify TDA and number theory.

---

## Direction 2: Tropical–Arithmetic Barcode Correspondence

**Conjecture.** For a smooth projective curve X/ℤ with semistable reduction at p, there exists a natural isomorphism between the degree-1 persistence module of ASC(X, p) and the tropical homology H₁^trop(Γ_p) of the dual graph Γ_p of the special fiber, compatible with the monodromy pairing.

**Test.** Compute both sides for hyperelliptic curves of genus 2 and 3 with explicitly known semistable models at small primes. Compare barcode decompositions with tropical cycle decompositions.

**Impact.** Would establish a *tropicalization functor* for persistence modules, connecting the discrete tropical world to the filtered arithmetic world. This opens a route to applying tropical intersection theory to barcode computations.

**Catalog References.** `Pythagorean/PrimewisePersistence/Arithmetic.lean` (ArithmeticFilteredComplex).

**Proof Strategy.** (1) Construct the comparison map via the specialization homomorphism. (2) Show it intertwines filtrations using the semistable reduction theorem. (3) Verify on examples using the explicit models.

**Domain Bridges.** Arithmetic geometry ↔ Tropical geometry ↔ TDA ↔ Combinatorics.

**The key insight is** that the degeneration of an arithmetic variety at a prime produces a tropical object whose combinatorial homology should equal the persistence homology of the arithmetic filtration, because both record the same incidence structure from different perspectives.

**Why now?** Tropical geometry has recently developed a rigorous homology theory (Itenberg–Katzarkov–Mikhalkin–Zharkov), and the comparison with arithmetic persistence has never been attempted.

**Lineage.** Extends ArithmeticFilteredComplex and filtration_monotone.

**Ambition.** Grand challenge — would create a new dictionary between tropical and arithmetic geometry.

---

## Direction 3: General Pythagorean Counting Law

**Conjecture.** For all primes p ≥ 2,
$$|\{(a, b, c) \in (\mathbb{Z}/p\mathbb{Z})^3 : a^2 + b^2 = c^2\}| = p^2$$

**Test.** Already verified computationally for all primes p ≤ 43 and formally verified for p ∈ {2, 3, 5, 7}. The general proof requires formalizing character sums over finite fields.

**Impact.** Completes the first theorem in the primewise persistence program, establishing the universal quadratic scaling law that makes arithmetic barcode signatures well-defined.

**Catalog References.** `Pythagorean/PrimewisePersistence/Arithmetic.lean` (pythagorean_count_two through pythagorean_count_seven).

**Proof Strategy.** (1) For each nonzero c ∈ 𝔽_p, the substitution (a,b) → (ca', cb') shows #{(a,b) : a²+b²=c²} = #{(a',b') : a'²+b'²=1}. (2) Count solutions to x²+y²=1 using the Legendre symbol: the count is p − (−1/p). (3) Sum over c = 0 and c ≠ 0, showing that the Legendre-symbol–dependent terms cancel, yielding p² for all p.

**Domain Bridges.** Number theory ↔ Combinatorics ↔ TDA.

**The key insight is** that the Pythagorean equation's quadratic nature ensures the Legendre symbol contributions from c = 0 and c ≠ 0 cancel exactly, producing a count independent of p mod 4.

**Why now?** Mathlib's recent improvements to `ZMod` and character sum infrastructure make the formalization tractable.

**Lineage.** Direct extension of pythagorean_count_two, ..., pythagorean_count_seven.

**Ambition.** Solid extension — provable within 3 months.

---

## Direction 4: Entropy Growth Rate and Conductor

**Conjecture.** For a fixed arithmetic object X, the barcode entropy H(X, p) grows as
$$H(X, p) = \alpha(X) \cdot \ln(p) + O(1)$$
where α(X) is a computable constant determined by the conductor of X.

**Test.** For Pythagorean filtered complexes, compute H(p) for primes p ≤ 100 and fit a linear model in ln(p). Check whether the slope α is consistent across different arithmetic objects of the same conductor.

**Impact.** Would establish barcode entropy as a *conductor detector*: an information-theoretic invariant that detects the arithmetic complexity of a variety. This bridges information theory and arithmetic geometry quantitatively.

**Catalog References.** `Pythagorean/PrimewisePersistence/Entropy.lean` (shannonEntropy_nonneg, entropy_monotone_coarsening).

**Proof Strategy.** (1) Use the entropy monotonicity theorem to establish the lower bound H(p) ≥ H(p') for finer filtrations. (2) Upper-bound entropy by ln(p − 1) (the maximum for p − 1 bars). (3) Analyze the growth rate using the distribution of filtration values, which relates to point counts and hence to the conductor.

**Domain Bridges.** Information theory ↔ Arithmetic geometry ↔ Analytic number theory.

**The key insight is** that the entropy growth rate captures the rate at which new arithmetic features appear as the prime grows, and this rate should be governed by the conductor — the measure of arithmetic complexity.

**Why now?** The entropy monotonicity theorem provides the theoretical foundation, and computational experiments are straightforward.

**Lineage.** Extends entropy_monotone_coarsening and barcodeEntropy_nonneg.

**Ambition.** Solid extension — testable immediately, provable within 6 months.

---

## Direction 5: Quantum Barcode Entropy and Spectral Flow

**Conjecture.** The barcode entropy H_bar(X, p) as a function of p exhibits spectral-flow–type behavior: it increases monotonically within congruence classes of p, with phase transitions at primes dividing the discriminant of X.

**Test.** For the curve y² = x³ − x (discriminant 64), plot H(p) against p for p ≤ 200, separated by congruence class mod 4. Check for monotonicity within each class and discontinuities at p = 2.

**Impact.** Would connect barcode entropy to the spectral theory of arithmetic operators, providing an analogy with entanglement entropy in quantum systems. Phase transitions at bad primes would give a barcode-level detection of singular reduction.

**Catalog References.** `Pythagorean/PrimewisePersistence/Entropy.lean` (shannonEntropy_nonneg), `Pythagorean/PrimewisePersistence/Stability.lean` (barcodeEntropy_nonneg, bottleneck_self).

**Proof Strategy.** (1) Within a congruence class, the filtration structure varies smoothly, so entropy monotonicity applies. (2) At discriminant primes, the topology changes discontinuously, breaking monotonicity and producing a "phase transition." (3) Formalize the comparison using the stability theorem and conductor analysis.

**Domain Bridges.** Arithmetic geometry ↔ Quantum information ↔ Spectral theory ↔ Physics.

**The key insight is** that barcode entropy, viewed as a function of the prime, behaves like an order parameter in statistical mechanics: it varies smoothly within phases (congruence classes) and jumps at critical points (bad primes).

**Why now?** Quantum information theory has recently developed powerful tools for analyzing entropy monotonicity (strong subadditivity, conditional entropy bounds), and these tools can be imported into the arithmetic barcode setting.

**Lineage.** Extends barcodeEntropy_nonneg and bottleneck_self.

**Ambition.** Solid extension with speculative elements — testable within 1 month, theoretically challenging.
