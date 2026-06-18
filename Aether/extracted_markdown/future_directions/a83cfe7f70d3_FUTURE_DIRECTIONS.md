# Future Directions: Arithmetic Persistence Theory

## Synthesis

The functorial localization framework established in this cycle — with its four core theorems (interleaving preservation, birth set identification, primewise stability rederivation, and witness improvement) — reveals that primewise torsion stability is not an isolated phenomenon but a shadow of classical commutative algebra projected onto persistence theory. This opens a systematic research program: every technique from localization theory, homological algebra, and arithmetic geometry has a potential persistence-theoretic counterpart. The directions below are organized from concrete extensions (Directions 1–3) to paradigm-shifting conjectures (Directions 4–5), each building on the localization functor $L_p$ and its interaction with the interleaving machinery.

---

## Direction 1: Derived Localization and Higher Tor Persistence

**Conjecture:** For persistence modules $F$ valued in chain complexes of abelian groups, the derived localization $\mathbb{L}L_p(F)$ produces higher Tor terms $\text{Tor}_i^{\mathbb{Z}}(F, \mathbb{Z}_{(p)})$ that measure the obstruction to primewise stability being an *equality* (rather than just a bound). Specifically, the failure of the natural map $H_*(L_p(F)) \to L_p(H_*(F))$ to be an isomorphism is controlled by $\text{Tor}_1$.

**Test:** Formalize the derived base change spectral sequence for a concrete persistence module built from a simplicial complex with known torsion (e.g., $\mathbb{RP}^2$). Compute $\text{Tor}_1$ explicitly and verify that it measures the discrepancy between chain-level and homology-level localization.

**Impact:** This would connect persistence stability to the Grothendieck spectral sequence and establish a bridge between computational topology and derived algebraic geometry. The higher Tor terms could serve as new persistence invariants capturing information invisible to ordinary barcodes.

**Catalog References:**
- `Catalog/Pythagorean/FunctorialLocalization.lean` — `localized_preserves_interleaving`, `pTorBirth_eq_globTorBirth_localized`
- `Catalog/Pythagorean/PrimewiseTorsionStability.lean` — `pTorsionBirthSet_deltaClose`

**Proof Strategy:** Define chain-level persistence modules as functors to $\text{Ch}(\mathbf{Ab})$. Construct $\mathbb{L}L_p$ using flat resolutions of $\mathbb{Z}_{(p)}$ (trivially: $\mathbb{Z}_{(p)}$ is flat over $\mathbb{Z}$, so $\text{Tor}_i = 0$ for $i \geq 1$ in the standard case). The interesting direction is when we replace $\mathbb{Z}_{(p)}$ by non-flat quotients like $\mathbb{Z}/p$ — then the Tor terms are nontrivial and carry persistence information.

**Domain Bridges:** Derived algebraic geometry ↔ topological data analysis; homological algebra ↔ computational topology.

**Lineage:** Builds directly on Theorem 1 (localized_preserves_interleaving) by extending from the abelian category level to the derived category.

**Ambition:** Grand challenge — establishing derived persistence would open an entirely new computational and theoretical toolkit for TDA.

---

## Direction 2: Adelic Persistence and the Local-Global Principle

**Conjecture:** There exists a "local-global" theorem for persistence modules: a persistence module $F$ can be reconstructed (up to isomorphism) from the family of all its localizations $\{L_p(F)\}_p$ together with a compatibility datum, analogous to the adelic reconstruction of number fields. Moreover, the interleaving distance of $F$ and $G$ equals the supremum of the interleaving distances of $L_p(F)$ and $L_p(G)$ over all primes $p$.

**The key insight is** that the adele ring $\mathbb{A}_{\mathbb{Q}} = \prod_p' \mathbb{Q}_p \times \mathbb{R}$ provides a framework where all local information is assembled simultaneously, and the localization functor $L_p$ is the projection to the $p$-th factor.

**Why now?** The functorial localization framework provides the necessary infrastructure: we now know each $L_p$ preserves interleavings, so the supremum bound is meaningful. The question is whether it is sharp.

**Test:** For 100 random module pairs, compute $d_H(\text{GlobTorBirth}(F), \text{GlobTorBirth}(G))$ and compare with $\sup_p d_H(\text{PTorBirth}(p,F), \text{PTorBirth}(p,G))$. If these always agree, the local-global principle holds at the birth-set level.

**Impact:** A positive result would provide a new algorithm for computing interleaving distances: compute at each prime separately (which is simpler) and take the supremum.

**Catalog References:**
- `Catalog/Pythagorean/FunctorialLocalization.lean` — `pTorBirth_deltaClose_via_localization`, `GlobTorDet_iff_exists_prime`
- `Catalog/Pythagorean/PrimewiseTorsionStability.lean` — `global_stability_from_primewise`

**Proof Strategy:** Use the decomposition theorem `GlobTorDet_iff_exists_prime` to show that global torsion birth is determined by the minimum over primewise births. Then show the Hausdorff distance inherits a min/max formula.

**Domain Bridges:** Algebraic number theory (adeles, local-global principle) ↔ topological data analysis.

**Lineage:** Direct extension of Theorems 2 and 5 from this cycle.

**Ambition:** Solid extension — the birth-set version is likely provable; the full module-reconstruction version is harder.

---

## Direction 3: Cohen-Lenstra Heuristics for Random Persistence Modules

**Conjecture:** The distribution of prime support in random persistence modules (constructed from random simplicial complexes or Erdős–Rényi random clique complexes) follows a variant of the Cohen-Lenstra distribution: for a prime $p$, the probability that $p$-torsion appears in the homology is proportional to $1/p$ (after appropriate normalization). The birth index of $p$-torsion, conditioned on its occurrence, follows a distribution that depends on the model of randomness.

**The key insight is** that Cohen-Lenstra heuristics predict the distribution of torsion in "random" algebraic objects (class groups, cokernels of random matrices). Persistence modules arising from random topological constructions are natural candidates for similar universality phenomena.

**Why now?** The localization framework provides the tools to isolate individual prime channels, making it possible to study the distribution of each channel independently.

**Test:** Generate 10,000 random persistence modules from the growing-torsion model. For each prime $p \in \{2, 3, 5, 7, 11, 13\}$, compute the frequency of $p$-torsion occurrence and the distribution of birth indices. Compare with the Cohen-Lenstra prediction $\text{Prob}(p \text{ divides } |T|) \approx 1 - \prod_{k=1}^{\infty}(1 - p^{-k})$.

**Impact:** This would connect TDA to arithmetic statistics, opening a new interdisciplinary research area. It would also provide practical guidance: if the Cohen-Lenstra distribution holds, then torsion at large primes is exponentially rare and can be safely ignored in most computations.

**Catalog References:**
- `Catalog/Pythagorean/FunctorialLocalization.lean` — `globTorBirth_decomposes_primewise`
- `Catalog/Pythagorean/PrimewiseTorsionStability.lean` — `prime_channel_independence`

**Proof Strategy:** Empirical first: gather statistics from computational experiments. If the data fits, attempt a proof using random matrix theory (the homology groups of random complexes can be modeled as cokernels of random integer matrices).

**Domain Bridges:** Arithmetic statistics (Cohen-Lenstra) ↔ random topology ↔ topological data analysis.

**Lineage:** Builds on the prime decomposition theorem (Theorem 5) and the prime channel independence theorem.

**Ambition:** Grand challenge — connecting Cohen-Lenstra to persistence would be a landmark result in probabilistic topology.

---

## Direction 4: Quantum Error Correction via Torsion Channel Codes

**Conjecture:** The primewise decomposition of torsion persistence provides a natural framework for constructing quantum error-correcting codes with arithmetic structure. Specifically, a persistence module with torsion at multiple primes can be used to construct a *prime-channel code* where errors at different primes are corrected independently, analogous to the use of Chinese Remainder Theorem codes in classical coding theory.

**The key insight is** that prime localization decomposes the torsion signal into independent channels (proved as `prime_channel_independence`), and independent channels are exactly what error-correcting codes need: errors in one channel don't affect others.

**Why now?** The localization framework provides the mathematical infrastructure to construct and analyze these codes. The interleaving stability theorem guarantees that small perturbations (errors) at the code level produce small changes in the decoded signal.

**Test:** Construct a toy code using $\mathbb{Z}/6\mathbb{Z} \cong \mathbb{Z}/2 \oplus \mathbb{Z}/3$ as the alphabet. Encode a message in the 2-channel and 3-channel independently. Introduce random errors and decode using the localization projection. Measure the error-correction rate.

**Impact:** This would bridge quantum information theory and topological data analysis via the arithmetic structure of persistence modules. If the codes have good parameters, it would be of practical interest for quantum computing.

**Catalog References:**
- `Catalog/Pythagorean/FunctorialLocalization.lean` — `localized_witness_improvement`, `GlobTorDet_iff_exists_prime`
- `Catalog/Pythagorean/PrimewiseTorsionStability.lean` — `prime_channel_independence`

**Proof Strategy:** Define the code space as a tensor product of prime-channel persistence modules. Use the interleaving stability bound as the minimum distance of the code. Apply the localization functor as the decoding map.

**Domain Bridges:** Quantum error correction ↔ commutative algebra ↔ topological data analysis.

**Lineage:** Builds on Theorem 4 (witness improvement) and prime channel independence.

**Ambition:** Grand challenge — speculative but with concrete testable predictions.

---

## Direction 5: Primewise Optimal Transport and Wasserstein Persistence

**Conjecture:** The localization functor $L_p$ commutes with the optimal transport formulation of persistence distances. That is, the $p$-Wasserstein distance between persistence diagrams (appropriately defined for integer-valued persistence) decomposes as a supremum or sum over prime-localized Wasserstein distances.

**The key insight is** that the Wasserstein/bottleneck distance between persistence diagrams is the optimal transport cost between point measures on the birth-death plane. Localization at $p$ restricts to the $p$-primary part of the diagram, and the optimal transport over the restricted diagram should relate to the transport over the full diagram.

**Why now?** Optimal transport methods in persistence theory are an active area of research. The localization framework provides the algebraic tools to decompose the transport problem primewise.

**Test:** Implement a Wasserstein distance computation for persistence modules with torsion (using the torsion barcode formulation). For 100 random pairs, compare the full Wasserstein distance with the supremum of prime-local Wasserstein distances. If they agree, the decomposition theorem holds at the metric level.

**Impact:** This would provide faster algorithms for computing persistence distances: decompose primewise, compute each prime's contribution independently (potentially in parallel), and assemble.

**Catalog References:**
- `Catalog/Pythagorean/FunctorialLocalization.lean` — all four main theorems
- `Catalog/Pythagorean/PrimewiseTorsionStability.lean` — `pTorsionBirthSet_triangle`

**Proof Strategy:** Formulate the torsion barcode as a measure on $\mathbb{R}^2$, with mass weighted by torsion order. Show that localization at $p$ restricts to the $p$-primary masses. Use the structure of optimal transport on product spaces.

**Domain Bridges:** Optimal transport ↔ persistence theory ↔ commutative algebra.

**Lineage:** Builds on Theorem 3 (primewise stability via localization) and extends to metric geometry.

**Ambition:** Solid extension with grand challenge potential — the metric-level decomposition is new and would be impactful if true.
