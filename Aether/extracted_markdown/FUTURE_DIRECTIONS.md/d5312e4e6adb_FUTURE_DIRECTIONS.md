# Future Directions: Arithmetic Persistence Theory

## Synthesis

The functorial localization framework established in this cycle transforms primewise torsion stability from a family of isolated results into consequences of a single algebraic mechanism: exact base change along the localization map $\mathbb{Z} \to \mathbb{Z}_{(p)}$. This synthesis opens five research directions, ranging from immediate extensions (derived localization, spectral barcodes) to paradigm-shifting conjectures (arithmetic persistence sheaves, quantum torsion channels). Each direction exploits the same structural principle — that persistence modules over $\mathbb{Z}$ carry arithmetic information decomposable along the prime spectrum — but applies it to increasingly deep mathematical contexts. The thread connecting all five is the conviction that TDA over $\mathbb{Z}$ is not just "TDA with more information" but a bridge between topology and arithmetic, with localization as the organizing functor.

---

## Direction 1: Derived Localization and Higher Tor Invariants

**Conjecture:** For persistence modules $F$ that are not levelwise free, the derived localization $\mathbf{L} L_p(F)$ — computed via derived tensor product $F \otimes^{\mathbf{L}}_{\mathbb{Z}} \mathbb{Z}_{(p)}$ — carries higher Tor terms $\text{Tor}_i^{\mathbb{Z}}(F_j, \mathbb{Z}_{(p)})$ that measure the failure of the localization functor to be exact on non-flat inputs. These Tor terms define new persistence invariants: "localization obstruction barcodes" that quantify the cost of passing from global to local analysis.

**Test:** Compute $\text{Tor}_1^{\mathbb{Z}}(F_j, \mathbb{Z}_{(p)})$ for specific persistence modules built from non-free presentations (e.g., $F_j = \mathbb{Z}/n\mathbb{Z}$ with $\gcd(n, p) = 1$). Verify that Tor₁ vanishes exactly when $n$ is coprime to $p$ (as predicted by the theory), and identify cases where non-vanishing Tor₁ corresponds to detectable instability in the localized module.

**Impact:** Would create a complete homological algebra of persistence localization, connecting TDA to the derived category framework used in algebraic geometry and representation theory.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (Theorem 1: interleaving preservation), `Pythagorean/PrimewiseTorsionStability.lean` (primewise stability).

**Proof Strategy:** Define a bar resolution $\cdots \to F_1 \to F_0 \to M \to 0$ for each persistence module level, apply $- \otimes \mathbb{Z}_{(p)}$, and compute homology. The persistence maps induce maps on Tor, yielding a derived persistence module. Prove stability of this derived module using the fact that Tor commutes with filtered colimits.

**Domain Bridges:** Algebraic geometry (derived base change, Grothendieck's six operations), homological algebra (spectral sequences), representation theory (derived categories of quiver representations).

**Lineage:** Direct extension of Theorem 1 (localized_preserves_interleaving) to the derived setting.

**Ambition:** grand_challenge — this would be the first derived persistence theory with arithmetic content.

---

## Direction 2: Spectral Barcodes and Algorithmic Prime Decomposition

**Conjecture:** For finitely generated $\mathbb{Z}$-persistence modules of bounded rank, the *spectral barcode* — the collection $\{(\text{PTorBirth}(p, F), \text{PTorDeath}(p, F))\}_{p \text{ prime}}$ — can be computed in polynomial time and provides strictly finer invariants than any single field-valued barcode. Specifically, there exist modules $F, G$ with identical $\mathbb{F}_q$-barcodes for all fields $\mathbb{F}_q$ but distinct spectral barcodes.

**Test:** Implement the spectral barcode algorithm for persistence modules over $\mathbb{Z}/n\mathbb{Z}$ with $n$ having at least 3 distinct prime factors. Compare with field-valued barcodes over $\mathbb{F}_p$ for each prime $p | n$. Verify separation: find explicit examples where field barcodes agree but spectral barcodes differ.

**Impact:** Would provide a practical, computable invariant strictly more powerful than existing TDA tools, with immediate applications to materials science and protein topology.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (Theorem 2: birth set identification), `Pythagorean/PrimewiseTorsionStability.lean` (PTorsionBirthSet).

**Proof Strategy:** Use Smith normal form at each persistence level to extract primary decomposition. Track births and deaths of primary summands across the filtration. Prove that the resulting spectral barcode is invariant under change of basis and stable under interleavings (via Theorem 3).

**Domain Bridges:** Computational topology (barcode algorithms, Ripser), signal processing (spectral analysis, filter banks), computational algebra (Smith normal form, Hermite normal form).

**Lineage:** Builds on Theorem 2 (pTorBirth_eq_globTorBirth_localized) by extending birth data to death data.

**Ambition:** solid_extension — algorithmically tractable and immediately testable.

---

## Direction 3: Arithmetic Persistence Sheaves

**Conjecture:** The prime-indexed collection of localized persistence modules $\{L_p(F)\}_{p \in \text{Spec}(\mathbb{Z})}$ assembles into a sheaf on $\text{Spec}(\mathbb{Z})$ — the prime spectrum of the integers, equipped with the Zariski topology. The global sections of this sheaf recover the original persistence module $F$, and the stalks at each prime $p$ are exactly $L_p(F)$. This sheafification is functorial and interacts well with interleaving distances.

**The key insight is** that persistence modules over $\mathbb{Z}$ are secretly sheaves on an arithmetic space, and localization is the passage from global to local sections.

**Why now?** The localization functor $L_p$ is now formally verified to preserve interleavings and identify birth sets, providing the stalk-level data needed for sheafification.

**Test:** Construct the presheaf $U \mapsto F \otimes_{\mathbb{Z}} \mathcal{O}_{\text{Spec}(\mathbb{Z})}(U)$ for specific open sets $U$ (complements of finite sets of primes). Verify the sheaf axiom computationally for persistence modules with 3+ distinct torsion primes.

**Impact:** Would unify persistence theory with algebraic geometry, enabling the use of sheaf cohomology, Čech complexes, and descent theory in TDA.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (all main theorems), `Pythagorean/PrimewiseTorsionStability.lean` (prime channel independence).

**Proof Strategy:** Define the presheaf using localization at multiplicative sets. Prove the sheaf condition using the Chinese Remainder Theorem for coprime localization. Show that the interleaving distance globalizes: $d(F, G) = \sup_p d(L_p(F), L_p(G))$ (this is the local-to-global principle).

**Domain Bridges:** Algebraic geometry (sheaves on Spec ℤ, Zariski topology), number theory (adèles, local-global principle), category theory (Grothendieck topologies, descent).

**Lineage:** Conceptual completion of the localization program initiated by Theorem 1.

**Ambition:** grand_challenge — would create a new subfield at the intersection of TDA and arithmetic geometry.

---

## Direction 4: Prime Channel Denoising for Applied TDA

**Conjecture:** In practical TDA applications (protein structure, materials science, neural connectivity), applying prime localization as a preprocessing step — isolating the $p$-primary torsion channel before computing persistence — reduces noise in the barcode by removing torsion contributions at irrelevant primes. For protein folding data, the 2-primary channel (detecting non-orientability) and the 3-primary channel (detecting 3-fold symmetries) carry geometrically meaningful and distinct signals.

**The key insight is** that different primes correspond to different geometric phenomena, and isolating them enables targeted analysis.

**Why now?** The witness improvement criterion (Theorem 4) proves that localization can strictly reduce interleaving distances, providing a mathematical foundation for prime-channel denoising.

**Test:** Apply primewise persistence to the Alpha protein complex database. Compute spectral barcodes for 50 protein structures, decompose by prime, and test whether the 2-primary channel correlates with known non-orientable features (Möbius-strip-like loops in protein backbones).

**Impact:** Would provide the first practical TDA application of arithmetic persistence, demonstrating that integer coefficients aren't just theoretically richer but practically useful.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (Theorem 4: witness improvement), `Pythagorean/PrimewiseTorsionStability.lean` (primeShiftBound).

**Proof Strategy:** Implement the localization algorithm from `algorithms.py` for simplicial complexes. Use the Ripser library for persistence computation, apply prime decomposition at the chain level, and compute per-prime persistence diagrams.

**Domain Bridges:** Structural biology (protein topology), materials science (grain boundary topology), neuroscience (neural circuit topology), signal processing (channel separation).

**Lineage:** Applied consequence of Theorem 4 (localized_witness_improvement).

**Ambition:** solid_extension — directly implementable with existing computational tools.

---

## Direction 5: Quantum Torsion Channels and Error Correction

**Conjecture:** The prime decomposition of torsion persistence has a natural interpretation in quantum error correction. A quantum code built from the homology of a chain complex over $\mathbb{Z}$ decomposes into independent $p$-primary error channels, and the localization functor corresponds to isolating errors correctable by operations of $p$-power order. The stability theorem (Theorem 3) then translates to a noise threshold result: if the physical noise is $\delta$-bounded, each prime channel independently maintains its error-correcting properties.

**The key insight is** that the prime decomposition of persistence torsion mirrors the decomposition of quantum errors by their order, and localization provides a mathematical framework for channel isolation in quantum codes.

**Why now?** The formal verification of the localization functor and its stability properties provides a rigorous foundation for extending these results to the quantum setting.

**Test:** Construct a toric code over $\mathbb{Z}$ (instead of $\mathbb{F}_2$) and compute its spectral barcode. Identify the 2-primary channel with the standard bit-flip errors and the 3-primary channel (if present) with phase errors of order 3. Verify that the stability theorem gives independent noise thresholds per channel.

**Impact:** Would connect TDA with quantum computing, potentially yielding new families of quantum error-correcting codes with built-in arithmetic decomposition.

**Catalog References:** `Pythagorean/FunctorialLocalization.lean` (Theorems 1-3), `Pythagorean/PrimewiseTorsionStability.lean` (prime_channel_independence).

**Proof Strategy:** Formalize the toric code as a persistence module over $\mathbb{Z}$, apply the localization functor, and translate the stability theorem into a noise threshold statement using the quantum channel capacity framework.

**Domain Bridges:** Quantum computing (error correction, stabilizer codes), condensed matter physics (topological phases), coding theory (algebraic codes over rings).

**Lineage:** Speculative extension of prime_channel_independence to the quantum setting.

**Ambition:** grand_challenge — would open an entirely new connection between arithmetic persistence and quantum information science.
