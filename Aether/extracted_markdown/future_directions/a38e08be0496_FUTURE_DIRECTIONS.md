# Future Directions: Arithmetic Persistence Theory

## Synthesis

The functorial localization framework established here — extracting p-primary torsion components from persistence modules and proving that this operation preserves interleavings and identifies birth sets — opens a systematic research program at the intersection of commutative algebra, homological algebra, and topological data analysis. The five directions below form a coherent progression: Direction 1 extends the theory from birth sets to full barcodes; Direction 2 lifts to derived categories to capture higher-order obstructions; Direction 3 develops the computational engine for practical applications; Direction 4 connects to number-theoretic structures via adelic completion; and Direction 5 bridges to quantum information theory via torsion in chain complexes. Together, they constitute a roadmap for **arithmetic persistence theory** — the systematic study of persistence modules through the lens of prime decomposition.

---

## Direction 1: Full Barcode Localization and Persistence Diagrams

**Conjecture:** For finitely generated ℤ-persistence modules with finitely many critical indices, the localization functor L_p induces a well-defined map on persistence barcodes (birth-death pairs) such that the bottleneck distance between localized barcodes is bounded by the bottleneck distance of the original barcodes.

**The key insight is** that the current framework tracks only birth indices (which are at most singletons), but a complete persistence theory requires tracking full birth-death pairs. The localization functor should commute with the barcode decomposition for tame persistence modules, producing a "localized barcode" that retains only p-primary bars.

**Why now?** The birth set identification theorem (Theorem 2) provides the foundational case. Extending to death indices requires analyzing how localization interacts with the quotient maps that define deaths — this is tractable given the exactness of localization for flat modules.

**Test:** Implement barcode computation for small ℤ-persistence modules (up to 20 indices), compute localized barcodes, and verify bottleneck distance preservation on 1000 random examples. A counterexample to distance preservation would falsify the conjecture.

**Impact:** Would provide the first complete primewise barcode theory, enabling prime-by-prime topological data analysis with full persistence diagrams.

**Catalog References:** `Pythagorean/PrimewiseTorsionStability.lean` (birth set stability), `Pythagorean/FunctorialLocalization.lean` (localization functor)

**Proof Strategy:** Represent persistence modules via presentation matrices (Smith normal form). Show that localization at p corresponds to extracting p-primary blocks from the Smith normal form. Use the interlacing inequalities for singular values to bound the bottleneck distance.

**Domain Bridges:** Topological data analysis, computational algebra, signal processing (spectral decomposition of persistence)

**Lineage:** Extends Theorems 1-3 from birth sets to full barcodes

**Ambition:** Solid extension — builds directly on established framework

---

## Direction 2: Derived Persistence Localization and Higher Tor Obstructions

**Conjecture:** For persistence modules that are not levelwise free, the derived functors Tor_n^ℤ(F(i), ℤ_{(p)}) for n ≥ 1 measure the obstruction to localization being exact, and these obstructions are bounded by the torsion complexity of F.

**The key insight is** that our localization construction (p-primary extraction) is exact because ℤ_{(p)} is flat over ℤ. But if we replace ℤ_{(p)} with a non-flat module (e.g., ℤ/pℤ), the higher Tor terms become nontrivial and carry additional persistence information. These derived persistence modules could detect phenomena invisible to ordinary localization.

**Why now?** The functorial framework provides the degree-0 foundation. Derived categories and Tor functors are well-developed in Mathlib (via `CategoryTheory.Abelian` and `Algebra.Homology`). The key challenge is connecting the abstract derived functor machinery to concrete persistence computations.

**Test:** For small chain complexes over ℤ with known torsion, compute Tor_1^ℤ(H_*(C), ℤ/pℤ) and verify that it recovers the universal coefficient theorem's torsion term. Test whether these terms satisfy stability under chain homotopy equivalence.

**Impact:** Would establish **derived arithmetic persistence theory**, opening connections to sheaf cohomology and derived algebraic geometry.

**Catalog References:** `Pythagorean/DerivedPersistence/Basic.lean`, `Pythagorean/FunctorialLocalization.lean`

**Proof Strategy:** Use the universal coefficient theorem as the base case: Tor_1^ℤ(H_n, ℤ/pℤ) ≅ H_n[p] (the p-torsion subgroup). Show this identification is natural and compatible with persistence structure maps. Prove stability via the long exact sequence in Tor.

**Domain Bridges:** Homological algebra, derived algebraic geometry, sheaf theory, spectral sequences

**Lineage:** Lifts the localization framework to derived categories

**Ambition:** Grand challenge — requires significant new mathematical infrastructure

---

## Direction 3: Parallel Prime-Channel Algorithms for Interleaving Distance

**Conjecture:** The interleaving distance between two ℤ-persistence modules F and G satisfies:

d_I(F, G) ≤ max_p d_I(L_p(F), L_p(G))

where the maximum is over all primes p dividing torsion in F or G, and furthermore, computing d_I(L_p(F), L_p(G)) is asymptotically faster than d_I(F, G) by a factor proportional to the number of active primes.

**The key insight is** that localization decomposes the interleaving problem into independent subproblems, one per prime. Each subproblem involves modules with simpler torsion structure (only p-primary torsion), which should be easier to solve. The independence allows parallel computation.

**Why now?** Theorem 1 (interleaving preservation) provides the theoretical foundation: d_I(L_p(F), L_p(G)) ≤ d_I(F, G). The conjectured reverse bound would make the decomposition tight. Computational experiments show that localized distances are frequently strictly smaller, suggesting the bound may not be tight in general — but the algorithmic speedup from parallelism remains valid.

**Test:** Implement interleaving distance computation for small ℤ-persistence modules (via integer linear programming). Compare wall-clock time of direct computation vs. parallel prime-channel computation on 100 random examples of increasing size. Measure the speedup factor.

**Impact:** Would provide the first practical algorithm that exploits prime decomposition for persistence computation, with potential for GPU parallelization.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (Theorem 1), `Pythagorean/PrimewiseTorsionStability.lean` (delta-closeness)

**Proof Strategy:** For the upper bound, use the Chinese Remainder Theorem reconstruction: an interleaving of all L_p(F) with L_p(G) can be assembled into an interleaving of F with G (for finitely generated modules). For the algorithmic claim, analyze the complexity reduction from having fewer and simpler torsion factors.

**Domain Bridges:** Algorithm design, parallel computing, computational topology, integer programming

**Lineage:** Computational realization of Theorems 1 and 4

**Ambition:** Solid extension — algorithmic with clear benchmarks

---

## Direction 4: Adelic Persistence and Arithmetic Reconstruction

**Conjecture (Grand Challenge):** For finitely generated ℤ-persistence modules, there exists an **adelic persistence module** — the product of all p-localizations together with the rationalization — from which the original module can be reconstructed up to isomorphism. The adelic interleaving distance equals the original interleaving distance.

**The key insight is** that in algebraic number theory, a global object (a number field, an algebraic variety) can be reconstructed from its local completions at all primes plus the archimedean place. The persistence analogue would reconstruct a ℤ-persistence module from its prime localizations plus its rationalization (tensoring with ℚ). This is the Hasse-Minkowski principle for persistence.

**Why now?** The localization framework provides the "local" components. The Chinese Remainder Theorem for finitely generated abelian groups provides the reconstruction mechanism. What remains is to show that the reconstruction is compatible with persistence structure maps and interleavings.

**Test:** For 100 random finitely generated ℤ-persistence modules (length 10, torsion from primes {2,3,5,7}): (a) compute all prime localizations; (b) compute the rationalization; (c) attempt CRT reconstruction; (d) verify isomorphism with the original. A failure would indicate a flaw in the reconstruction procedure (not the conjecture itself, which is known to hold for individual groups).

**Impact:** Would establish a complete **local-global principle for persistence**, connecting TDA to the deepest structures in number theory.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean`, `Pythagorean/AdelicPersistentHomology.lean`

**Proof Strategy:** For individual groups, the reconstruction is the exact sequence 0 → ℤ → ℚ × ∏_p ℤ_p → 𝔸_f → 0 (the adele sequence). Extend this levelwise to persistence modules and show that persistence structure maps are compatible with the adelic product. Use flatness of ℚ over ℤ and completeness of ℤ_p.

**Domain Bridges:** Algebraic number theory, adelic analysis, arithmetic geometry, class field theory

**Lineage:** Grand synthesis of localization framework with number-theoretic reconstruction

**Ambition:** Grand challenge — paradigm-shifting if achieved

---

## Direction 5: Torsion Channels in Quantum Error-Correcting Codes

**Conjecture:** For homological quantum error-correcting codes defined over ℤ (or ℤ/Nℤ), the prime decomposition of the torsion in the chain complex determines independent error channels, and the code distance decomposes as the minimum over prime channels of the localized code distances.

**The key insight is** that topological quantum codes (e.g., toric codes, surface codes) are defined by chain complexes whose homology determines the code parameters. When the chain complex is defined over ℤ rather than a field, torsion in homology corresponds to additional code states. The prime decomposition of this torsion should decompose the code into independent prime channels, each protecting against a different type of error.

**Why now?** The localization framework provides the mathematical machinery to decompose torsion channels functorially. Recent work on quantum LDPC codes has shown interest in codes over non-field alphabets. The persistence stability results translate to stability of code parameters under small perturbations of the chain complex.

**Test:** For the toric code on a genus-g surface with ℤ/Nℤ coefficients: compute the torsion of H_1 for N = 6, 12, 30 (products of small primes); decompose into prime channels; compute the code distance in each channel; verify that the minimum matches the global code distance.

**Impact:** Would establish a new connection between arithmetic persistence and quantum information, potentially leading to new code constructions optimized for specific error models.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (prime channel independence), `Pythagorean/TropicalMorse/HigherQuantumLDPC.lean`

**Proof Strategy:** Use the universal coefficient theorem to relate H_*(C; ℤ/Nℤ) to H_*(C; ℤ) modulo torsion. Show that the minimum-weight representative in each prime channel can be lifted to a representative in the original code. The code distance decomposition then follows from the independence of prime channels (our Lemma on q-torsion vanishing in p-primary subgroups).

**Domain Bridges:** Quantum information theory, coding theory, algebraic topology, condensed matter physics

**Lineage:** Application of prime channel independence to quantum codes

**Ambition:** Grand challenge — bridges to an entirely different field
