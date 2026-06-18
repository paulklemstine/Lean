# Future Directions: Arithmetic Persistence Theory

## Synthesis

The functorial localization theory developed in this cycle establishes that primewise torsion stability is a shadow of a general base-change principle. This opens a systematic research program: every construction in commutative algebra that preserves exact sequences (flat base change, completion, henselization) potentially induces a new stability theorem for persistence modules. The five directions below exploit this insight at increasing levels of ambition, from concrete computational extensions to paradigm-shifting conjectures connecting persistence to derived algebraic geometry and quantum error correction. All directions share the common thread that *arithmetic structure in persistence modules is not noise but signal*, and that the right algebraic optics (localization, completion, derived functors) can separate, sharpen, and amplify this signal.

---

## Direction 1: Derived Localization and Higher Tor Obstructions

**Conjecture:** For persistence modules over rings R where localization at a prime ideal 𝔭 is not flat (e.g., certain non-commutative or non-noetherian settings), the higher derived functors Tor_i^R(F, R_𝔭) carry information about *instability modes* — obstructions to interleaving that vanish at the level of H_0 but persist in higher homological degree.

**Test:** Formalize the Tor computation for explicit persistence modules over ℤ[x]/(x²) (dual numbers), where localization is no longer flat. Compute Tor_1 and determine whether it measures the discrepancy between the naive primewise stability bound and the actual interleaving distance.

**Impact:** Would establish a *derived persistence stability theory* where classical stability is the degree-0 shadow, with higher corrections measuring subtler alignment failures. This would parallel the role of higher K-theory in algebraic geometry.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (localized_preserves_interleaving, localizedMap_injective — both rely on flatness, which fails in derived settings), `Pythagorean/PrimewiseTorsionStability.lean` (pTorsionBirthSet_deltaClose).

**Proof Strategy:** Define a persistence Tor complex using bar resolutions. Show that Tor_1 vanishes iff the naive bound is tight. Use spectral sequence arguments to relate higher Tor to interleaving obstructions.

**Domain Bridges:** Derived algebraic geometry, homological algebra, spectral sequences.

**Lineage:** Extends Theorem 1 (interleaving preservation) by asking what happens when the flatness hypothesis fails.

**Ambition:** Grand challenge — would create a new homological invariant for persistence modules.

---

## Direction 2: Primewise Barcode Decomposition for Simplicial Complexes

**Conjecture:** For a Rips filtration of a finite point cloud in ℝ^d, the p-primary channel birth indices satisfy a universality property: as the number of points grows, the distribution of 2-torsion births converges to a limit law depending on the ambient manifold's Stiefel-Whitney classes, while 3-torsion births converge to a law depending on mod-3 Steenrod operations.

**Test:** Compute integer persistent homology of Rips complexes for 1000 random point clouds sampled from RP², the Klein bottle, and L(3,1). For each, compute the p-torsion birth distributions for p = 2, 3, 5 and compare with theoretical predictions from characteristic class theory.

**Impact:** Would connect computational TDA to classical algebraic topology via a statistical bridge. Practitioners could identify the underlying manifold by examining the prime spectrum of the persistence barcode.

**The key insight is** that the prime localization functor acts as a *spectral filter* that isolates exactly the topological information encoded in mod-p characteristic classes.

**Why now?** The localization functor provides the first computationally tractable way to separate p-primary persistence information. Previous approaches required explicit chain-level primary decomposition, which is exponentially more expensive than the quotient construction.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (pTorsionBirth_eq_torsionBirth_localized, torsion_detector_factorizes), `Pythagorean/PrimewiseTorsionStability.lean` (prime_channel_independence).

**Proof Strategy:** Use Steenrod operations to predict which primes carry torsion for specific manifolds. Apply the localization functor to filtered simplicial complexes and compare empirical birth distributions to theoretical predictions.

**Domain Bridges:** Algebraic topology (Steenrod algebra), arithmetic statistics, computational geometry.

**Lineage:** Extends Theorem 2 (birth set identification) to a statistical setting.

**Ambition:** Solid extension with grand-challenge statistical component.

---

## Direction 3: Localization-Based Denoising for Materials Science

**Conjecture:** In persistent homology computed from X-ray crystallography data, 2-torsion artifacts arise from numerical issues with Z₂-symmetric structures, while genuine topological features (voids, channels) produce torsion at larger primes corresponding to the crystal symmetry group. Localization at odd primes removes the numerical artifacts while preserving the structural information.

**Test:** Apply the primewise denoising algorithm (localization at p=3, 5, 7) to persistent homology computations from the Materials Project database. Compare the denoised barcodes to experimental measurements of material porosity and conductivity. Measure signal-to-noise improvement quantitatively.

**Impact:** Would provide a mathematically principled denoising tool for materials informatics, replacing ad hoc thresholding with functorial localization.

**The key insight is** that symmetry-induced torsion and noise-induced torsion typically concentrate at different primes, so localization naturally separates signal from noise without any parameter tuning.

**Why now?** The functorial preservation of interleavings (Theorem 1) guarantees that denoising via localization is stability-preserving — localized distances never exceed original distances. This theoretical guarantee was previously unavailable.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (LocalizedAtPrime, localized_preserves_interleaving), `Pythagorean/PrimewiseTorsionStability.lean` (pTorsionBirthSet_deltaClose).

**Proof Strategy:** Formalize the denoising guarantee: if the noise torsion is supported at primes in a set S and the signal at primes in T with S ∩ T = ∅, then localization at any p ∈ T removes all noise while preserving signal exactly.

**Domain Bridges:** Materials science, crystallography, signal processing.

**Lineage:** Application of Theorem 1 to a practical domain.

**Ambition:** Solid extension with immediate practical applications.

---

## Direction 4: Quantum Error Correction via Torsion Channel Coding

**Conjecture:** The prime decomposition of torsion persistence modules provides a natural algebraic framework for constructing quantum error-correcting codes. Specifically, the independence of prime channels (each prime carries independent torsion information) mirrors the structure of stabilizer codes, where different syndrome measurements detect independent error types.

**Test:** Construct a persistence-based quantum code where the logical qubits are encoded in the free part of integer homology and the syndrome measurements are the p-torsion detectors for small primes. Compute the code distance and compare to the best known stabilizer codes of the same parameters.

**Impact:** Would establish a novel connection between TDA and quantum information theory, potentially yielding new families of quantum codes with algebraically structured syndrome decoders.

**The key insight is** that prime channel independence (Theorem: `prime_channel_independence` in the catalog) provides exactly the algebraic structure needed for independent syndrome measurements in a stabilizer code.

**Why now?** The localization functor provides a systematic way to construct and analyze the independent channels, which previously required ad hoc algebraic constructions.

**Catalog References:** `Pythagorean/PrimewiseTorsionStability.lean` (prime_channel_independence, torsion_detector_factorizes_over_primes), `Pythagorean/FunctorialLocalization.lean` (torsion_detector_factorizes).

**Proof Strategy:** Map the persistence module structure to a chain complex defining a CSS code. Show that localization at each prime defines an independent syndrome subspace. Compute code parameters using primewise birth sets.

**Domain Bridges:** Quantum information theory, coding theory, homological algebra.

**Lineage:** Grand challenge connecting Theorem 5 (prime factorization) to quantum error correction.

**Ambition:** Grand challenge — paradigm-shifting if successful.

---

## Direction 5: Adelic Persistence and the Local-Global Principle

**Conjecture:** The collection of all prime localizations of a persistence module, together with its rationalization (tensor with ℚ), assembles into an *adelic persistence module* that carries strictly more information than the original integer persistence module. The local-global principle for persistence would state conditions under which the original module can be recovered from its adelic data.

**Test:** Formalize the adelic persistence module as the restricted product ∏'_p L_p(F) and prove that for finitely generated persistence modules, the natural map F → F^{adelic} is injective. Construct an explicit example where the adelic module distinguishes two modules that have identical barcodes over every field.

**Impact:** Would introduce number-theoretic techniques (adeles, ideles, class field theory) into persistence theory, creating a new interface between arithmetic geometry and TDA.

**The key insight is** that the localization functor at each prime captures different "local" information, and the adelic product assembles all this local data into a global invariant that is richer than any single localization.

**Why now?** The functorial localization theory provides the first rigorous framework for constructing local factors of persistence modules. The adelic assembly is the natural next step.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (LocalizedAtPrime, pTorsionBirth_eq_torsionBirth_localized), `Pythagorean/AdelicPersistentHomology.lean`.

**Proof Strategy:** Define the adelic persistence module using restricted direct products. Prove the local-global map is injective for f.g. modules using the structure theorem. Construct distinguishing examples using modules with identical Betti numbers but different torsion.

**Domain Bridges:** Algebraic number theory (adeles), arithmetic geometry, automorphic forms.

**Lineage:** Grand challenge extending all four main theorems to the adelic setting.

**Ambition:** Grand challenge — would create arithmetic persistence theory as a new subfield.
