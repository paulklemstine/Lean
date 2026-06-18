# Future Research Directions

## Synthesis

This research cycle established the mathematical foundations connecting pitch class set theory to persistent homology through the Hamming metric on subsets of ℤ/12ℤ. The central discovery is that the circle of fifths — the generator 7 of the cyclic group ℤ/12ℤ — creates measurable topological features (persistent H₁ cycles) in the Vietoris-Rips filtration of chord clouds. The most promising cross-domain connection is between the **algebraic structure of ℤ/12ℤ** (group generators, units, coprimality) and the **topological features of harmonic spaces** (persistence bars, Betti numbers, filtration monotonicity). This bridge between algebra and topology is not specific to music — it applies whenever a cyclic group acts on a metric space.

The isometry theorem (transposition preserves Hamming distance) connects this work to the Catalog's extensive coverage of group actions and symmetries, particularly the Berggren framework for Pythagorean triples (which also studies orbits of group actions on lattices). The Fourier analysis on ℤ/12ℤ connects to the EML Catalog's work on spectral methods and harmonic analysis. The most ambitious extension is **multi-parameter persistence** combining Hamming distance with voice-leading distance — this would require formalizing optimal transport on finite groups, a connection to the Computation and Bridges catalogs.

The highest breakthrough potential lies in Direction 1 (Directed Persistent Homology), because incorporating temporal ordering would transform the framework from static analysis to dynamic analysis, capturing *how* harmonic cycles evolve over time rather than just *whether* they exist.

---

### Direction 1: Directed Persistent Homology for Temporal Harmonic Analysis

**Conjecture**: For a temporally-ordered chord sequence C₁, C₂, ..., Cₙ from a Bach chorale, the *zigzag persistence* of the sequence — computed by alternating forward and backward inclusions along the temporal filtration — produces H₁ bars whose birth times correlate with the onset of modulation (key change) and whose death times correlate with the resolution back to the original key. Specifically, the number of zigzag H₁ bars of persistence ≥ 4 equals the number of distinct modulations in the chorale.

**Test**: Implement zigzag persistence for temporally-ordered chord clouds. Apply to 50 Bach chorales with known modulation schemes (annotated in the Bach Chorale Corpus). For each chorale, count the number of zigzag H₁ bars with persistence ≥ 4 and compare to the number of expert-annotated modulations. The conjecture predicts a Pearson correlation ≥ 0.7.

**Impact**: If true, this provides an *automated modulation detector* based on topology — no music-theoretic rules required. If false, the failure reveals whether modulation is a purely temporal phenomenon (not captured by chord proximity) or whether the persistence threshold of 4 is wrong (requiring calibration).

**Catalog References**: `EML/PersistentHarmony/PitchClass.lean` (Hamming metric, Rips filtration), `Bridges/AlgebraEMLClosureComputation.lean` (filtered systems)

**Proof Strategy**: Define a zigzag diagram of Rips complexes indexed by time windows [t, t+w] for sliding window parameter w. Formalize the zigzag persistence module and prove that modulation creates a new connected component in the "key graph" (graph on key centers with edges when two keys share ≥ 2 common diatonic scale degrees). The new component's birth/death in zigzag persistence corresponds to the modulation span.

**Domain Bridges**: Persistent homology (topology) ↔ Time series analysis (computation) ↔ Music theory (domain)

**Lineage**: Builds on `circleOfFifths_surjective`, `ripsEdge_monotone`, and the Hamming metric framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Voice-Leading Distance as Optimal Transport

**Conjecture**: When the Hamming metric on pitch class sets is replaced by the *voice-leading distance* (minimum total semitone displacement over all bijections between two chords of equal cardinality), the persistent homology of Bach chorale chord clouds has strictly higher maximum H₁ persistence than under the Hamming metric. Formally: for any Bach chorale with ≥ 8 distinct chords, max_persistence(H₁, d_VL) ≥ max_persistence(H₁, d_H) + 1.

**Test**: Compute persistence diagrams under both metrics for 100 Bach chorales from the MIDI corpus. Compare maximum H₁ bar lengths. The conjecture predicts a consistent advantage for the voice-leading metric.

**Impact**: If true, voice-leading distance captures harmonic structure *more efficiently* than Hamming distance, meaning that voice-leading (the motion of individual notes) is more topologically informative than chord identity (which notes are present). This would validate Tymoczko's geometric theory at the topological level. If false, it means Hamming distance already captures the essential topological information, and the additional refinement of voice leading adds noise rather than signal.

**Catalog References**: `EML/PersistentHarmony/PitchClass.lean` (Hamming metric), `Computation/InfoEfficientAlgorithms.lean` (algorithmic efficiency)

**Proof Strategy**: Define voice-leading distance as the solution to an assignment problem (optimal transport with discrete measure on ℤ/12ℤ with the cyclic metric d(a,b) = min(|a-b|, 12-|a-b|)). Prove that d_VL ≤ d_H for equal-cardinality chords (since each note moves by ≤ 6 semitones, while Hamming counts 2 for each differing note). The persistence inequality would then follow from the Rips monotonicity theorem: smaller distances → earlier edges → longer-lived cycles.

**Domain Bridges**: Optimal transport (analysis) ↔ Persistent homology (topology) ↔ Voice leading (music theory)

**Lineage**: Builds on `transpose_preserves_hammingDist` and `hammingDist_triangle` from this cycle.

**Ambition**: extension

---

### Direction 3: Spectral Persistence via Fourier Coefficients on ℤ/12ℤ

**Conjecture**: The persistent homology of the chord cloud computed in the *Fourier coefficient space* (using the L² distance between DFT magnitude profiles as the metric) has a qualitatively different barcode structure than the Hamming-distance persistence: specifically, in the Fourier space, the 5th-coefficient axis dominates the topology, and the longest H₁ bar lies in the 2D plane spanned by the 5th and 7th Fourier coefficients — the plane of "fifthness" and "minor-thirdness."

**Test**: For each chord S ∈ **PCS**, compute the 12-dimensional DFT magnitude vector (|Ŝ(0)|, ..., |Ŝ(11)|). Use L² distance between these vectors. Compute Vietoris-Rips persistence. Project the persistence generators onto coordinate subspaces and identify which pair of Fourier axes carries the dominant H₁ cycle. The conjecture predicts axes 5 and 7 for Bach, but axes 1 and 2 for atonal music.

**Impact**: If true, this identifies the *spectral signature* of tonal harmony — the circle of fifths manifests specifically in the (5,7)-Fourier plane. This would connect persistent homology to the music-theoretic "intervallic content" and Forte's interval vector. If false, the Fourier coefficients may be too redundant (related by symmetries of ℤ/12ℤ) to carry distinct topological information.

**Catalog References**: `EML/PersistentHarmony/PitchClass.lean` (Fourier magnitude, `fourier_zero_eq_card_sq`)

**Proof Strategy**: First prove that the DFT magnitude profile is transposition-invariant: |T̂_t(S)(k)| = |Ŝ(k)| for all t, k. This follows from the shift theorem for DFT. Then prove that the L² distance in Fourier space is bounded above and below by multiples of the Hamming distance (a bi-Lipschitz relationship). The topological equivalence of the two filtrations would follow from stability of persistence diagrams under bi-Lipschitz maps.

**Domain Bridges**: Fourier analysis (harmonic analysis) ↔ Persistent homology (topology) ↔ Pitch class set theory (music)

**Lineage**: Builds on `fourierMagnitudeSq`, `fourier_zero_eq_card_sq`, and the DFT framework from this cycle.

**Ambition**: extension

---

### Direction 4: Persistent Homology of the Tonnetz

**Conjecture**: The *tonnetz* — the infinite planar graph where vertices are pitch classes connected by major thirds (interval 4), minor thirds (interval 3), and perfect fifths (interval 7) — has a well-defined persistent homology when quotiented by the action of ℤ/12ℤ. The resulting quotient is a torus T², and the two fundamental H₁ generators of the torus correspond to the circle of fifths (generated by 7) and the circle of major thirds (generated by 4). A chord progression's trajectory on the tonnetz determines which fundamental cycles it activates in H₁.

**Test**: Construct the tonnetz as a simplicial complex on ℤ/12ℤ with 2-simplices {p, p+3, p+7} and {p, p+4, p+7} for each p. Compute its homology. The conjecture predicts H₀ = ℤ, H₁ = ℤ², H₂ = ℤ (the homology of a torus).

**Impact**: If true, this provides a rigorous topological explanation for the empirical observation that the tonnetz "looks like a torus" — a claim made informally in music theory since the 19th century. The two H₁ generators correspond to two independent harmonic dimensions: fifths motion and thirds motion. If false, the tonnetz may have a more complex topology due to the specific gcd relationships between 3, 4, 7, and 12.

**Catalog References**: `Geometry/` (simplicial complexes), `EML/PersistentHarmony/PitchClass.lean` (circle of fifths), `Algebra/Basic.lean` (group actions)

**Proof Strategy**: The tonnetz on ℤ/12ℤ is a 2-dimensional simplicial complex. Compute its homology using the chain complex ∂₂: C₂ → C₁ → C₀ with boundary maps determined by the simplicial structure. The key lemma is that 3 + 4 = 7 mod 12, which means the three edge types are algebraically dependent. This forces the simplicial complex to triangulate a torus rather than a higher-genus surface.

**Domain Bridges**: Simplicial homology (algebraic topology) ↔ Group theory (algebra) ↔ Music theory (domain) ↔ Geometry (lattice theory)

**Lineage**: Builds on `circleOfFifths_surjective`, `seven_coprime_twelve`, and the pitch class framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Chromatic Complexity Measure via Persistent Entropy

**Conjecture**: Define the *persistent entropy* of a persistence diagram as H = -∑ pᵢ log pᵢ where pᵢ = (dᵢ - bᵢ)/L is the normalized persistence of the i-th bar and L = ∑(dᵢ - bᵢ) is the total persistence. Then persistent entropy is maximized by 12-tone serial compositions (where all intervals are used equally, creating maximum topological disorder) and minimized by pedal point passages (where a single chord dominates, creating minimal topology). Bach chorales have intermediate persistent entropy, reflecting a balance between variety and structure.

**Test**: Compute persistent entropy for chord clouds from (a) all 371 Bach chorales, (b) Schoenberg's 12-tone compositions, (c) drone-based music (e.g., La Monte Young). Plot the distribution of persistent entropies. The conjecture predicts Schoenberg > Bach > drone, with non-overlapping distributions.

**Impact**: If true, persistent entropy provides a single-number summary of harmonic complexity that respects both variety (more distinct chords = higher entropy) and structure (organized motion through harmonic space = specific entropy level). This would give music theorists a quantitative tool for comparing harmonic styles across composers and periods. If false, persistent entropy may be too coarse to distinguish structured variety (Bach) from random variety (atonal), suggesting that higher-order topological invariants (e.g., persistence landscapes) are needed.

**Catalog References**: `EML/PersistentHarmony/PitchClass.lean` (persistence bars), `EML/AdvancedTheory.lean` (`ensembleComplexity`)

**Proof Strategy**: Prove that persistent entropy is transposition-invariant (immediate from `transpose_preserves_hammingDist`). Prove the upper bound: H ≤ log(n) where n is the number of bars, with equality iff all bars have equal persistence. The lower bound H = 0 occurs when a single bar dominates. For the Bach intermediate value, this requires computational verification rather than a pure proof.

**Domain Bridges**: Information theory (entropy) ↔ Persistent homology (topology) ↔ Music theory (harmonic analysis) ↔ EML (ensemble complexity)

**Lineage**: Builds on `PersistenceBar`, `hammingDist_triangle`, and the full persistence framework from this cycle. Connects to `EML/AdvancedTheory.lean` via the ensemble complexity concept.

**Ambition**: extension
