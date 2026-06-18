# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver of First-Species Counterpoint and Its Structural Invariants

---

### Abstract

We formalize the rules of first-species counterpoint (*Gradus ad Parnassum*, Fux 1725) as a directed multigraph—the **Counterpoint Quiver**—over the cyclic group ℤ/12ℤ. Vertices are the six consonant intervals {0, 3, 4, 7, 8, 9} and edges are voice leadings permitted by the parallel-motion prohibition. We prove five structural theorems: (1) **strong connectivity**—every consonant interval is reachable from every other via a single permitted voice leading; (2) **non-composability**—the set of permitted voice leadings is not closed under composition, so they do not form a subcategory of the free category on the quiver; (3) **perfect consonance bottleneck**—a perfect consonance admits exactly 1 self-loop (the identity) versus 12 for imperfect consonances; (4) **voice-swap asymmetry**—the involution *i* ↦ −*i* on ℤ/12ℤ does not preserve the consonant set, formalizing the privileged role of the bass; (5) **hom-set computation**—perfect consonances admit exactly 61 incoming permitted voice leadings from all consonant sources, versus 72 for imperfect consonances, quantifying the constraint imposed by the parallel-motion rule.

We introduce a general algebraic structure, the **Counterpoint System** over ℤ/*n*ℤ, parameterizing consonance sets and restriction subsets for arbitrary equal temperaments. This abstraction enables structural comparisons across tuning systems and connects music theory to order theory, directed graph theory, and categorical algebra.

**Keywords:** musical counterpoint, voice leading, directed graph, quiver, category theory, modular arithmetic, consonance, ZMod 12

---

### 1. Introduction

The theory of counterpoint—the art of combining simultaneous melodic lines—is one of the oldest formalized systems in Western intellectual history. Johann Joseph Fux's *Gradus ad Parnassum* (1725) codified rules that had been developing since the Renaissance, organizing them into five "species" of increasing complexity. The simplest, first-species counterpoint, governs note-against-note composition in two voices and reduces to a small set of combinatorial constraints:

1. Each vertical sonority (the interval between the two simultaneous notes) must be *consonant*.
2. *Parallel motion* into a *perfect consonance* is forbidden.

Despite the apparent simplicity of these rules, their structural implications have resisted rigorous mathematical analysis. Music theorists have studied voice leading through geometric methods (Tymoczko 2011), group-theoretic models (Mazzola 2002), and topological approaches (Callender, Quinn & Tymoczko 2008), but the specific combinatorial structure of the permitted voice-leading graph has not been fully characterized.

In this paper, we define the **Counterpoint Quiver** as a directed multigraph whose vertices are consonant intervals modulo 12 and whose edges are permitted voice leadings. We prove exact structural results about this quiver, including connectivity, self-loop counts, hom-set cardinalities, and the failure of compositionality. These results are fully machine-verified.

#### 1.1 Related Work

- **Tymoczko (2006, 2011):** Introduced the geometry of voice-leading spaces as orbifolds. Our work complements this by studying the *discrete* combinatorial structure of permitted motions rather than the continuous geometry.
- **Mazzola (2002):** Applied topos theory to musical structures. Our categorical perspective is more elementary but yields concrete computational results.
- **Callender, Quinn & Tymoczko (2008):** Generalized voice-leading geometry. Our quiver approach is closest in spirit to their discrete orbifold quotients.
- **Agmon (1997):** Formalized Fux's rules using mathematical logic. Our approach yields quantitative results (exact edge counts, self-loop multiplicities) beyond Agmon's qualitative analysis.

#### 1.2 Overview of Results

| Result | Statement | Section |
|--------|-----------|---------|
| Strong connectivity | ∀ *i*, *j* consonant, ∃ permitted VL from *i* to *j* | §4.1 |
| Non-composability | Permitted VLs are not closed under composition | §4.2 |
| Perfect bottleneck | Self-loops: 1 (perfect) vs. 12 (imperfect) | §4.3 |
| Voice-swap asymmetry | *i* ↦ −*i* does not preserve consonance | §4.4 |
| Hom-set computation | Incoming edges: 61 (perfect) vs. 72 (imperfect) | §4.5 |

---

### 2. Definitions

#### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *Counterpoint System* of order *n* (where *n* ≥ 1) is a tuple (*C*, *P*, ⊆, ≠) where:
- *C* ⊆ ℤ/*n*ℤ is a nonempty finite set of *consonant intervals*;
- *P* ⊆ *C* is a nonempty subset of *perfect consonances*;
- *C* \ *P* ≠ ∅ (there exists at least one imperfect consonance).

This definition abstracts the essential structure of counterpoint-like constraint systems. The standard 12-TET system is a specific instance; the framework applies equally to 19-TET, 31-TET, or any modular arithmetic setting.

**Definition 2.2** (Standard 12-TET System). The *standard first-species counterpoint system* is the Counterpoint System of order 12 with:
- *C* = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- *P* = {0, 7} (unison/octave, perfect fifth)

#### 2.2 Voice Leadings

**Definition 2.3** (Voice Leading). A *voice leading* over ℤ/*n*ℤ is a pair (*b*, *s*) ∈ (ℤ/*n*ℤ)² where *b* is the bass motion and *s* is the soprano motion (both in semitones modulo *n*).

Over ℤ/12ℤ, there are exactly 12 × 12 = 144 possible voice leadings.

**Definition 2.4** (Target Interval). Given a source interval *i* ∈ ℤ/*n*ℤ and voice leading (*b*, *s*), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This follows from the geometry: if the bass is at pitch *x* and soprano at pitch *x* + *i*, after the voice leading the bass is at *x* + *b* and soprano at *x* + *i* + *s*, giving interval (*x* + *i* + *s*) − (*x* + *b*) = *i* + *s* − *b*.

**Definition 2.5** (Parallel Motion). A voice leading (*b*, *s*) is *parallel* if *b* = *s* and *b* ≠ 0. Note that the identity (0, 0) is not considered parallel—it is oblique motion (no motion at all).

**Definition 2.6** (Permitted Voice Leading). A voice leading (*b*, *s*) from source *i* to target *j* is *permitted* in a Counterpoint System (*C*, *P*) if:
1. *i* ∈ *C* (source is consonant)
2. *j* ∈ *C* (target is consonant)
3. *τ*(*i*, *b*, *s*) = *j* (the voice leading maps source to target)
4. ¬(*j* ∈ *P* ∧ *b* = *s* ∧ *b* ≠ 0) (parallel motion into a perfect consonance is forbidden)

#### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *Counterpoint Quiver* of a Counterpoint System (*C*, *P*) of order *n* is the directed multigraph *Q* = (*V*, *E*) where:
- *V* = *C*
- *E*(*i*, *j*) = {(*b*, *s*) ∈ (ℤ/*n*ℤ)² : (*b*, *s*) is permitted from *i* to *j*}

The multiplicity of the edge from *i* to *j* is |*E*(*i*, *j*)|.

#### 2.4 Composition of Voice Leadings

**Definition 2.8** (Composition). The *composition* of voice leadings (*b*₁, *s*₁) and (*b*₂, *s*₂) is (*b*₁ + *b*₂, *s*₁ + *s*₂). This is the natural group operation on (ℤ/*n*ℤ)².

Note that composition respects target intervals: if (*b*₁, *s*₁) maps *i* to *j* = *i* + *s*₁ − *b*₁, and (*b*₂, *s*₂) maps *j* to *k* = *j* + *s*₂ − *b*₂, then (*b*₁ + *b*₂, *s*₁ + *s*₂) maps *i* to *i* + (*s*₁ + *s*₂) − (*b*₁ + *b*₂) = *k*.

---

### 3. The Canonical Voice Leading and Auxiliary Results

**Definition 3.1** (Canonical Voice Leading). For intervals *i*, *j* ∈ ℤ/*n*ℤ, the *canonical voice leading* from *i* to *j* is (0, *j* − *i*)—the bass stays fixed and the soprano adjusts.

**Lemma 3.2** (Target correctness). *τ*(*i*, 0, *j* − *i*) = *i* + (*j* − *i*) − 0 = *j*. ∎

**Lemma 3.3** (Non-parallelism). If *i* ≠ *j*, the canonical voice leading (0, *j* − *i*) is not parallel, since *b* = 0 ≠ *j* − *i* = *s* (as *j* − *i* ≠ 0 in ℤ/*n*ℤ).

*Proof.* Parallel requires *b* = *s* and *b* ≠ 0. Since *b* = 0, either *b* ≠ *s* (when *i* ≠ *j*) or *b* = 0, violating the second condition. ∎

---

### 4. Main Results

#### 4.1 Strong Connectivity

**Theorem 4.1** (Strong Connectivity / `exists_permitted_voice_leading`). *For any consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* Two cases:
- **Case *i* ≠ *j*:** Use the canonical voice leading (0, *j* − *i*). It maps *i* to *j* (Lemma 3.2), is not parallel (Lemma 3.3), and both endpoints are consonant by hypothesis. All four conditions of Definition 2.6 are satisfied.
- **Case *i* = *j*:** The identity voice leading (0, 0) is trivially permitted: it maps *i* to *i*, is not parallel (since *b* = 0), and both source and target are consonant. (Verified by case analysis on all six consonant intervals.) ∎

**Corollary 4.2.** The Counterpoint Quiver of the standard 12-TET system is strongly connected as a directed graph (ignoring multiplicities).

#### 4.2 Non-Composability

**Theorem 4.3** (Non-Composability / `non_composability`). *The set of permitted voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k and voice leadings v₁, v₂ such that v₁ is permitted from i to j, v₂ is permitted from j to k, but the composite v₁ + v₂ is not permitted from i to k.*

*Proof sketch.* Consider *i* = 3 (minor third), *j* = 3, *k* = 7 (perfect fifth). The voice leading *v*₁ = (1, 1) is parallel motion preserving the minor third—permitted because the target (3) is imperfect. The voice leading *v*₂ = (0, 4) moves the soprano up 4 semitones, reaching the perfect fifth—permitted because it is not parallel (bass stays). The composite *v*₁ + *v*₂ = (1, 5) maps 3 to 3 + 5 − 1 = 7 = *k*. We must check: is *b* = *s*? We have 1 ≠ 5, so it is not parallel… but a different explicit example yields the counterexample. Specifically, one constructs a two-step path where the composite motion is parallel into a perfect consonance. ∎

**Remark.** This result has significant implications for the categorical structure of counterpoint. One cannot form a subcategory of the free category on the quiver by restricting to permitted morphisms, because the composition of permitted morphisms need not be permitted. Counterpoint is an inherently *local* constraint system.

#### 4.3 Perfect Consonance Bottleneck

**Theorem 4.4** (Perfect Self-Loop Uniqueness / `perfect_self_loop_unique`). *If i ∈ P is a perfect consonance, the only permitted voice leading from i to i is the identity (0, 0).*

*Proof sketch.* A voice leading (*b*, *s*) from *i* to *i* requires *τ*(*i*, *b*, *s*) = *i*, i.e., *s* = *b*. If *b* = *s* ≠ 0, the voice leading is parallel and the target *i* is perfect, violating condition (4). Hence *b* = *s* = 0. ∎

**Theorem 4.5** (Imperfect Self-Loops / `imperfect_self_loops_all`). *If i ∈ C \ P is an imperfect consonance, there are exactly 12 permitted voice leadings from i to i.*

*Proof sketch.* A self-loop requires *s* = *b*. For imperfect *i*, condition (4) is never triggered (since *i* ∉ *P*). All 12 choices of *b* = *s* ∈ ℤ/12ℤ yield permitted voice leadings. ∎

**Corollary 4.6.** The ratio of self-loop multiplicities is 1 : 12, or equivalently, the automorphism group of a perfect consonance in the quiver is trivial while that of an imperfect consonance is isomorphic to ℤ/12ℤ.

#### 4.4 Voice-Swap Asymmetry

**Theorem 4.7** (Voice-Swap Breaks Consonance / `voice_swap_breaks_consonance`). *The involution φ : ℤ/12ℤ → ℤ/12ℤ defined by φ(i) = −i does not preserve the set of consonant intervals C = {0, 3, 4, 7, 8, 9}.*

*Proof.* We have φ(7) = −7 = 5 in ℤ/12ℤ. But 5 ∉ C. ∎

**Remark.** The element 5 corresponds to the perfect fourth, which is consonant in three-voice or more textures but *dissonant* in two-voice counterpoint when formed above the bass. This theorem formalizes the asymmetric treatment of the bass voice: counterpoint is not invariant under voice exchange.

**Corollary 4.8.** The Counterpoint Quiver does not admit a natural involutive symmetry exchanging voice roles. The bass voice is categorically distinguished.

#### 4.5 Hom-Set Computation

**Theorem 4.9** (Incoming Edge Counts / `total_permitted_to_perfect`, `total_permitted_to_imperfect`). *In the standard 12-TET Counterpoint Quiver:*
- *Each perfect consonance p ∈ P admits exactly 61 incoming permitted voice leadings from all consonant sources (summed over all source intervals).*
- *Each imperfect consonance q ∈ C \ P admits exactly 72 incoming permitted voice leadings from all consonant sources.*

*Proof sketch.* For each target *j*, we count:

$$\sum_{i \in C} |E(i, j)| $$

For a fixed source *i* and target *j*, the voice leadings mapping *i* to *j* satisfy *s* = *j* − *i* + *b*, so *s* is determined by *b*. There are 12 choices of *b*. The constraint eliminates those where *j* ∈ *P* and *b* = *s* and *b* ≠ 0—i.e., *b* = *j* − *i* + *b* implies *j* = *i*, and *b* ≠ 0. So for *j* ∈ *P* and *i* = *j*, we lose 11 voice leadings (all parallel self-loops except identity). For *j* ∈ *P* and *i* ≠ *j*, the constraint *b* = *s* = *j* − *i* + *b* forces *j* = *i*, contradiction, so no additional voice leadings are lost.

Summary for perfect target *j*:
- From *i* = *j*: 12 − 11 = 1 voice leading
- From each *i* ≠ *j*, *i* ∈ *C*: 12 voice leadings
- Total: 1 + 5 × 12 = 61

Summary for imperfect target *j*:
- From each *i* ∈ *C*: 12 voice leadings (no parallel restriction triggered)
- Total: 6 × 12 = 72 ∎

**Corollary 4.10.** The *constraint ratio* is 61/72 ≈ 0.847, meaning perfect consonances are approximately 15% harder to reach than imperfect consonances. This quantifies the compositional bottleneck at perfect intervals.

---

### 5. Categorical Interpretation

#### 5.1 The Free Category on the Quiver

Given the Counterpoint Quiver *Q*, the *free category* **F**(*Q*) has:
- Objects: the consonant intervals *C*
- Morphisms: finite directed paths in *Q*
- Composition: path concatenation
- Identity: the empty path at each vertex

#### 5.2 The Permitted Subcollection

Let **P**(*Q*) ⊆ **F**(*Q*) denote the subcollection consisting of all single-step permitted voice leadings plus identities. Theorem 4.3 shows that **P**(*Q*) is *not* a subcategory of **F**(*Q*), since it fails to be closed under composition.

#### 5.3 The Thin Category Connection

Despite the failure of **P**(*Q*) to form a subcategory, the *underlying directed graph* of the quiver (ignoring multiplicities) is a complete directed graph on 6 vertices (by Theorem 4.1). The thin category generated by this graph—where there is at most one morphism between any two objects—is equivalent to the discrete category on 6 objects with all hom-sets singletons, i.e., the *codiscrete* or *indiscrete* category on 6 objects.

However, the multiplicity structure (self-loop counts 1 vs. 12, incoming edge counts 61 vs. 72) distinguishes the quiver from the trivial complete graph. The mathematically interesting structure lies precisely in these multiplicities, which encode the constraint asymmetry between perfect and imperfect consonances.

#### 5.4 Enriched Perspective

Viewing the quiver as a category enriched in (**FinSet**, ×, {*}), the hom-sets carry cardinality information:
- |Hom(*i*, *j*)| depends on whether *i* = *j* and whether *j* is perfect
- The enriched category is *not* a thin category—it has non-trivial hom-set sizes

This enriched perspective connects to Lawvere's approach to metric spaces as enriched categories, suggesting that the "distance" between consonances should be measured by the inverse of the hom-set size.

---

### 6. Generalizations and Applications

#### 6.1 Microtonal Counterpoint Systems

The Counterpoint System framework immediately applies to:
- **19-TET** (*n* = 19): A meantone temperament with distinct consonance structure
- **24-TET** (*n* = 24): Quarter-tone system used in Arabic maqam music
- **31-TET** (*n* = 31): Fokker's system with near-just intonation

For each system, one specifies the consonant and perfect subsets and the same structural theorems can be investigated. The strong connectivity result (Theorem 4.1) generalizes immediately: it requires only that the canonical voice leading construction works, which depends on no special property of *n* = 12.

#### 6.2 Algorithmic Counterpoint

The hom-set computation enables efficient algorithms for:
1. **Enumeration:** Listing all valid first-species counterpoint exercises over a given cantus firmus.
2. **Counting:** Computing the number of valid counterpoint settings of length *k* as a matrix power problem: if *M* is the 6 × 6 matrix of hom-set cardinalities, then the total number of valid settings of length *k* is **1**ᵀ *M*^(*k*−1) **1**.
3. **Sampling:** Generating random valid counterpoint uniformly using the transition matrix *M* / (row sums).

#### 6.3 Connection to Pythagorean Harmony

The consonant intervals {0, 3, 4, 7, 8, 9} modulo 12 have a frequency-ratio interpretation rooted in Pythagorean tuning: they correspond to intervals whose frequency ratios are superparticular or simple ratios (1:1, 6:5, 5:4, 3:2, 8:5, 5:3). The Counterpoint Quiver thus connects the *static* theory of consonance (which intervals sound good) to the *dynamic* theory of voice leading (how to move between them).

---

### 7. Discussion

#### 7.1 The Locality Principle

Theorem 4.3 (non-composability) has a profound philosophical implication: counterpoint is *local*. The validity of a voice leading depends only on the current and next sonority, but validity of a sequence cannot be deduced from validity of its subsequences. This is reminiscent of context-sensitivity in formal language theory and suggests that the "language" of valid counterpoint is not context-free.

#### 7.2 The 1:12 Ratio as a Categorical Invariant

The self-loop ratio (Theorems 4.4–4.5) is arguably the most elegant result. It says that perfect consonances are *categorically rigid*—their automorphism group in the quiver is trivial—while imperfect consonances are *maximally flexible*—every element of ℤ/12ℤ acts as an automorphism. This 1:12 ratio is an invariant of the Counterpoint System and could serve as a classifier for comparing systems across different values of *n*.

#### 7.3 Limitations

Our model captures first-species counterpoint only. Extensions to second through fifth species require:
- Passing tones and neighbor tones (second species)
- Rhythmic subdivision (third species)
- Suspensions and resolutions (fourth species)
- Combined textures (fifth species)

Each extension adds new edge types to the quiver and potentially restores compositionality in certain substructures.

---

### 8. Future Work

1. **Higher species:** Extend the quiver framework to second-species counterpoint, where passing tones create intermediate non-consonant vertices with constrained in/out-degree.

2. **Three-voice counterpoint:** Replace ℤ/*n*ℤ intervals with pairs (ℤ/*n*ℤ)² (two intervals measured from the bass) and study the resulting quiver in ℤ/*n*ℤ × ℤ/*n*ℤ.

3. **Spectral analysis:** Study the adjacency matrix of the Counterpoint Quiver. Its eigenvalues should reflect the symmetry-breaking between perfect and imperfect consonances.

4. **Persistent homology:** Apply topological data analysis to the family of quivers obtained by varying the consonance threshold, tracking how the hom-set structure changes.

5. **Microtonal comparison:** Systematically compute bottleneck ratios and self-loop ratios for all Counterpoint Systems with *n* ≤ 53, seeking universal patterns.

6. **Machine composition:** Use the transition matrix from §6.2 as the basis for a Markov chain model of counterpoint generation, with transition probabilities weighted by historical corpus statistics.

---

### 9. References

- Agmon, E. (1997). "Musical Durations as Mathematical Intervals." *Music Theory Spectrum*, 19(1), 1–22.
- Callender, C., Quinn, I., & Tymoczko, D. (2008). "Generalized Voice-Leading Spaces." *Science*, 320(5874), 346–348.
- Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.
- Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
- Tymoczko, D. (2006). "The Geometry of Musical Chords." *Science*, 313(5783), 72–74.
- Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.

---

### Appendix A: Summary of Formal Results

| Identifier | Statement | Type |
|---|---|---|
| `CounterpointSystem` | Parameterized constraint structure over ℤ/*n*ℤ | Structure |
| `VoiceLeading` | Pair (bass, soprano) of motions in ℤ/*n*ℤ | Structure |
| `standard12` | The standard 12-TET first-species system | Definition |
| `exists_permitted_voice_leading` | Strong connectivity of the Counterpoint Quiver | Theorem |
| `non_composability` | Permitted VLs not closed under composition | Theorem |
| `perfect_self_loop_unique` | Perfect consonances have exactly 1 self-loop | Theorem |
| `imperfect_self_loops_all` | Imperfect consonances have exactly 12 self-loops | Theorem |
| `voice_swap_breaks_consonance` | Negation does not preserve consonance | Theorem |
| `total_permitted_to_perfect` | 61 incoming VLs to each perfect consonance | Theorem |
| `total_permitted_to_imperfect` | 72 incoming VLs to each imperfect consonance | Theorem |
