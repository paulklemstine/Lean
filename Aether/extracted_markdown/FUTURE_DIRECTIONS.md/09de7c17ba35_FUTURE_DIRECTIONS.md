# Future Directions: Arithmetic Persistence Theory

## Synthesis

The functorial localization framework established in this cycle transforms primewise torsion stability from isolated theorem statements into consequences of a single algebraic principle: base change along the localization map $\mathbb{Z} \to \mathbb{Z}_{(p)}$. This opens five directions that extend the theory vertically (derived/spectral), horizontally (across prime spectra), and outward (to applications in signal processing, arithmetic statistics, and quantum error correction). The common thread is that **prime decomposition of persistence modules is not an invariant-level trick but a functorial structure** — and functorial structures propagate.

---

## Direction 1: Derived Localization and Higher Tor Obstructions

**Conjecture:** For persistence modules $F$ valued in finitely generated $\mathbb{Z}$-modules, the higher derived functors $\text{Tor}_i^{\mathbb{Z}}(F, \mathbb{Z}_{(p)})$ for $i \geq 1$ measure the precise obstruction to improving interleaving witnesses via localization. Specifically, there exists a spectral sequence $E_2^{s,t} = \text{Tor}_s(H_t(F), \mathbb{Z}_{(p)}) \Rightarrow H_{s+t}(F \otimes^L \mathbb{Z}_{(p)})$ whose differentials encode primewise instability.

**Test:** Formalize $\text{Tor}_1^{\mathbb{Z}}(F(i), \mathbb{Z}_{(p)})$ for cyclic modules $\mathbb{Z}/n\mathbb{Z}$ (where it is $\mathbb{Z}/\gcd(n, q)$ for primes $q \neq p$) and verify computationally that nonvanishing Tor correlates with failure of witness improvement. Implement this for 100 random modules.

**Impact:** Would establish persistence localization as a derived functor theory, connecting TDA to the full machinery of homological algebra. Opens the door to sheaf-theoretic persistence constructions.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` — Theorem 4 (`localized_witness_improvement_criterion`), which gives a sufficient condition; the Tor computation would give a necessary and sufficient condition.

**Proof Strategy:** Define $\text{Tor}_1^{\mathbb{Z}}(\mathbb{Z}/n, \mathbb{Z}_{(p)})$ directly via the presentation $0 \to \mathbb{Z} \xrightarrow{n} \mathbb{Z} \to \mathbb{Z}/n \to 0$ and the flatness criterion. Show that $\text{Tor}_1 = 0$ iff $n$ is a power of $p$ (i.e., no mixed-prime torsion). Then prove that the persistence-level Tor vanishes iff localization preserves interleaving witnesses optimally.

**Domain Bridges:** Homological algebra, derived algebraic geometry, sheaf cohomology.

**Lineage:** Extends Theorem 4 of the current cycle.

**Ambition:** Grand challenge — requires substantial new Lean infrastructure for derived categories.

The key insight is that the gap between preservation and strict improvement of interleavings is measured by a computable homological invariant, not by ad hoc analysis.

Why now? The localization functor is now formally constructed, and Mathlib's growing derived category infrastructure is approaching the level needed for persistence applications.

---

## Direction 2: Arithmetic Statistics of Torsion Births

**Conjecture:** For a natural ensemble of random persistence modules (e.g., modules arising from random simplicial complexes on $n$ vertices), the distribution of $p$-torsion birth indices satisfies a Cohen-Lenstra-type heuristic: the probability that $p$-torsion first appears at index $i$ is inversely proportional to the size of the automorphism group of the $p$-primary part.

**Test:** Generate 10,000 random persistence modules from Erdős-Rényi simplicial complexes. For each prime $p \in \{2, 3, 5, 7\}$, record the empirical distribution of $p$-torsion birth indices. Compare with the Cohen-Lenstra prediction $\text{Prob}(G) \propto 1/|\text{Aut}(G)|$.

**Impact:** Would connect TDA to arithmetic statistics, one of the most active areas of modern number theory. Could reveal universal laws governing how topological features distribute across primes.

**Catalog References:** `Pythagorean/PrimewiseTorsionStability.lean` — `prime_channel_independence` (showing different primes give independent channels).

**Proof Strategy:** Establish independence of prime channels (already done) and then study the marginal distribution of each channel. Use the structure theorem for finitely generated abelian groups to relate group-theoretic probability to combinatorial counts.

**Domain Bridges:** Number theory (Cohen-Lenstra heuristics), random topology, probabilistic combinatorics.

**Lineage:** Extends the prime channel independence theorem.

**Ambition:** Grand challenge — would require new probabilistic techniques in formal verification.

The key insight is that prime localization decomposes random persistence into independent channels, each of which may obey the same universal distribution laws as random abelian groups in number theory.

Why now? The independence of prime channels is now formally verified, and computational tools for random simplicial complexes are mature.

---

## Direction 3: Primewise Barcode Refinement Algorithm

**Conjecture:** For persistence modules over $\mathbb{Z}$ with finitely generated levels, there exists a polynomial-time algorithm that computes the *primewise barcode* — a collection of barcodes $\{B_p\}_{p \text{ prime}}$ such that $B_p$ encodes the birth-death pairs of $p$-primary torsion features. The primewise barcode is a strictly finer invariant than the global torsion barcode.

**Test:** Implement the algorithm for persistence modules with levels $\mathbb{Z}/n$ for various $n$. Verify that the primewise barcode distinguishes modules that the global barcode cannot (e.g., $\mathbb{Z}/6$ vs $\mathbb{Z}/2 \oplus \mathbb{Z}/3$).

**Impact:** Would provide a practical algorithmic tool for TDA practitioners. The primewise barcode could replace existing torsion barcodes in applications where arithmetic structure matters.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` — `LocalizedAtPrime` (the localization construction), `pTorsionBirthSet_eq_localizedTorsionBirthSet` (birth set identification).

**Proof Strategy:** Use the localization functor to reduce primewise barcode computation to standard barcode computation on localized modules. Prove correctness via Theorem 2 (birth set identification) and extend to death indices using dual arguments.

**Domain Bridges:** Computational topology, algorithmic algebra, data science.

**Lineage:** Direct extension of Theorems 2 and 3.

**Ambition:** Solid extension — algorithmically tractable and practically useful.

The key insight is that localization reduces primewise barcode computation to a sequence of standard barcode computations on simpler (p-primary) modules.

Why now? The birth set identification theorem provides the theoretical foundation, and existing barcode algorithms can be adapted with minimal modification.

---

## Direction 4: Quantum Error Correction via Prime Channels

**Conjecture:** For quantum error-correcting codes defined by chain complexes over $\mathbb{Z}$, the error-correcting capacity at a prime $p$ (the $p$-primary distance) is determined by the localized homology $H_*(C) \otimes \mathbb{Z}_{(p)}$. Localization at different primes isolates independent error channels, enabling prime-by-prime code optimization.

**Test:** Compute the $p$-primary homology of known quantum codes (toric codes, hyperbolic codes) for small primes. Verify that the $p$-primary distance is at least as large as the global distance, and search for codes where strict improvement occurs.

**Impact:** Would provide new tools for quantum code design. The prime decomposition could enable fault-tolerant quantum computation with arithmetic structure-awareness.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` — `localized_witness_improvement_criterion` (witness improvement), `localized_distance_le_original` (non-increasing distance).

**Proof Strategy:** Model quantum codes as persistence modules (chain complexes are special cases). Apply localization to each prime channel and use the interleaving preservation theorem to bound error rates per channel.

**Domain Bridges:** Quantum information theory, coding theory, condensed matter physics.

**Lineage:** Extends Theorem 4 to the quantum coding setting.

**Ambition:** Grand challenge — requires bridging formal persistence theory with quantum information.

The key insight is that the prime decomposition of torsion homology in quantum codes decomposes error correction into independent arithmetic channels, each potentially optimizable.

Why now? Recent advances in homological quantum codes have highlighted the role of torsion, and the localization framework provides the right algebraic language.

---

## Direction 5: Spectral Filtering for Topological Signal Processing

**Conjecture:** For time-varying point cloud data producing a persistence module $F_t$, the localization $L_p(F_t)$ acts as a band-pass filter in the arithmetic frequency domain. Different primes isolate different "frequencies" of topological change, enabling primewise denoising: removing torsion artifacts at unwanted primes while preserving signal at target primes.

**Test:** Apply primewise localization to persistence modules computed from:
1. Synthetic datasets with known prime structure (e.g., union of lens spaces)
2. Time-series data from dynamical systems with periodic orbits of prime period
Measure signal-to-noise ratio before and after localization at each prime.

**Impact:** Would establish a new paradigm for topological signal processing. Just as Fourier analysis decomposes signals into frequency components, prime localization decomposes topological signals into arithmetic components.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` — all four theorems; `Pythagorean/PrimewiseTorsionStability.lean` — `global_stability_from_primewise` (reassembly from prime channels).

**Proof Strategy:** Formalize the reconstruction theorem: $\text{GlobalTorsionBirthSet}(F) = \bigcup_p \text{PTorsionBirthSet}(p, F)$ (set-level version already in the catalog). Prove a quantitative version: the Hausdorff distance between the global birth set and the union of primewise birth sets is zero.

**Domain Bridges:** Signal processing, time-series analysis, dynamical systems, computational topology.

**Lineage:** Direct extension of the prime channel independence and reassembly theorems.

**Ambition:** Solid extension — practically implementable with existing TDA software.

The key insight is that the prime decomposition of persistence torsion is the topological analogue of spectral decomposition in signal processing, with primes playing the role of frequencies.

Why now? TDA software (Ripser, Gudhi, Dionysus) already computes persistence over $\mathbb{Z}$, and the localization framework provides the missing algebraic theory for primewise analysis.
