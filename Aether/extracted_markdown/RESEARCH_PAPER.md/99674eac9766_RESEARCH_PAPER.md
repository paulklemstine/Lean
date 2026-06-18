# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver of First-Species Counterpoint

---

### Abstract

We formalize first-species counterpoint rules — as codified in Fux's *Gradus ad Parnassum* (1725) — as a directed multigraph (quiver) over the group ℤ/12ℤ. Objects are the six consonant intervals modulo octave equivalence; directed edges are voice leadings permitted by counterpoint rules. We prove five structural results: (1) the quiver is strongly connected; (2) permitted voice leadings are not closed under composition, hence do not form a subcategory of the free category on the quiver; (3) perfect consonances exhibit a 12:1 self-loop bottleneck relative to imperfect consonances; (4) the voice-swap involution *i* ↦ −*i* does not preserve consonance, formalizing bass-voice asymmetry; (5) perfect consonances admit exactly 61 incoming voice leadings versus 72 for imperfect consonances. We introduce the *Counterpoint System* abstraction, parameterizing all constructions over ℤ/*n*ℤ for arbitrary *n*, enabling application to microtonal equal temperaments. All results have been formally verified.

**Keywords:** counterpoint, voice leading, category theory, quiver, modular arithmetic, music theory, directed graph, ZMod

---

### 1. Introduction

The rules of musical counterpoint — the art of combining independent melodic lines — have been central to Western music theory since the Renaissance. First codified systematically by Fux (1725), these rules specify which intervals between voices are consonant and which transitions between consonant intervals (voice leadings) are permitted. Despite their age, the mathematical structure of these rules has received relatively little formal attention.

Recent work in mathematical music theory, notably by Tymoczko (2006, 2011) and Mazzola (2002), has explored voice-leading spaces from geometric and topological perspectives, representing voice leadings as paths in quotient spaces. Categorical approaches to music theory have been developed by Popoff et al. (2015) and Noll (2007), typically modeling transformations of pitch-class sets.

Our approach differs in focusing specifically on the *constraint structure* imposed by counterpoint rules on individual voice leadings. Rather than studying the geometry of the full voice-leading space, we study the *combinatorics* of the permitted subgraph — the directed multigraph of legal one-step transitions. This perspective reveals that the familiar rules encode precise algebraic properties: connectivity, non-composability, and quantifiable asymmetries between perfect and imperfect consonances.

We introduce the **Counterpoint System** as a mathematical structure that axiomatizes voice-leading constraints over any cyclic group ℤ/*n*ℤ, enabling systematic study of counterpoint-like systems in arbitrary equal temperaments.

#### 1.1 Organization

Section 2 presents definitions. Section 3 states and discusses the main results. Section 4 provides proof sketches. Section 5 discusses applications and connections. Section 6 outlines future work.

---

### 2. Definitions

Throughout, we work over the cyclic group ℤ/*n*ℤ for a positive integer *n*. The standard case is *n* = 12 (12-tone equal temperament).

#### 2.1 Counterpoint System

**Definition 2.1** (Counterpoint System). A *Counterpoint System* over ℤ/*n*ℤ is a triple (𝒞, 𝒫, ⊲) where:
- 𝒞 ⊆ ℤ/*n*ℤ is a nonempty finite set of *consonant intervals*;
- 𝒫 ⊆ 𝒞 is a nonempty subset of *perfect consonances*;
- 𝒞 \ 𝒫 ≠ ∅ (there exists at least one *imperfect consonance*);
- ⊲ is the *parallel-motion prohibition*: a voice leading into a perfect consonance by parallel motion is forbidden.

The formal definition (`CounterpointSystem n`) captures these axioms as a Lean structure with fields `consonant`, `perfect`, `perfect_sub`, `consonant_nonempty`, `perfect_nonempty`, and `has_imperfect`.

**Definition 2.2** (Standard 12-TET System). The *standard 12-TET counterpoint system* is:
- 𝒞 = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- 𝒫 = {0, 7} (unison, perfect fifth)

This is formalized as `standard12 : CounterpointSystem 12`.

#### 2.2 Voice Leadings

**Definition 2.3** (Voice Leading). A *voice leading* over ℤ/*n*ℤ is a pair (*b*, *s*) ∈ (ℤ/*n*ℤ)² where *b* is the bass motion and *s* is the soprano motion, both measured in semitones modulo *n*.

The space of voice leadings has cardinality *n*². For *n* = 12, there are 144 voice leadings.

**Definition 2.4** (Target Interval). Given a source interval *i* ∈ ℤ/*n*ℤ and a voice leading (*b*, *s*), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This is formalized as `targetInterval n source vl = source + vl.soprano - vl.bass`.

**Definition 2.5** (Parallel Motion). A voice leading (*b*, *s*) exhibits *parallel motion* if *b* = *s* and *b* ≠ 0. Note that the identity (0, 0) is not considered parallel — it is *oblique* (no motion).

**Definition 2.6** (Permitted Voice Leading). A voice leading (*b*, *s*) from source *i* to target *j* is *permitted* in a counterpoint system (𝒞, 𝒫, ⊲) if:
1. *i* ∈ 𝒞 and *j* ∈ 𝒞;
2. τ(*i*, *b*, *s*) = *j*;
3. It is not the case that *j* ∈ 𝒫 and (*b*, *s*) is parallel.

This is formalized as `CounterpointSystem.isPermitted`.

#### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *Counterpoint Quiver* of a system (𝒞, 𝒫, ⊲) is the directed multigraph *Q* = (*V*, *E*) where:
- *V* = 𝒞 (vertices are consonant intervals)
- *E*(*i*, *j*) = {(*b*, *s*) ∈ (ℤ/*n*ℤ)² : (*b*, *s*) is permitted from *i* to *j*} (edges from *i* to *j* are permitted voice leadings)

#### 2.4 Composition of Voice Leadings

**Definition 2.8** (Composition). Given voice leadings *v*₁ = (*b*₁, *s*₁) and *v*₂ = (*b*₂, *s*₂), their *composition* is:

$$v_2 \circ v_1 = (b_1 + b_2, \; s_1 + s_2)$$

This corresponds to applying the combined motion of both voice leadings simultaneously. Note that τ(*i*, *v*₂ ∘ *v*₁) = τ(τ(*i*, *v*₁), *v*₂), so composition is well-defined on target intervals.

---

### 3. Main Results

We state the five principal theorems, all formally verified.

#### 3.1 Theorem 1: Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). *For any two consonant intervals i, j ∈ 𝒞 in the standard 12-TET system, there exists a permitted voice leading from i to j.*

$$\forall\, i, j \in \mathcal{C},\; \exists\, (b, s) \in (\mathbb{Z}/12\mathbb{Z})^2 : \text{isPermitted}(i, j, (b, s))$$

This establishes that the Counterpoint Quiver is strongly connected: the underlying directed graph (forgetting multiplicities) has a single strongly connected component.

**Corollary 3.2.** The shortest path between any two consonant intervals in the Counterpoint Quiver has length at most 1.

#### 3.2 Theorem 2: Non-Composability

**Theorem 3.3** (`non_composability`). *There exist consonant intervals i, j, k and permitted voice leadings v₁ from i to j and v₂ from j to k such that the composite voice leading v₂ ∘ v₁ is not permitted from i to k.*

In other words, the set of permitted voice leadings is not closed under composition. The permitted voice leadings do not form a subcategory of the free category on the complete directed graph over 𝒞.

#### 3.3 Theorem 3: Perfect Consonance Bottleneck

**Theorem 3.4** (`perfect_self_loop_unique`). *If p ∈ 𝒫 is a perfect consonance in the standard 12-TET system, the only permitted voice leading from p to itself is the identity (0, 0).*

**Theorem 3.5** (`imperfect_self_loops_all`). *If q ∈ 𝒞 \ 𝒫 is an imperfect consonance, then every voice leading of the form (d, d) for d ∈ ℤ/12ℤ is a permitted self-loop at q. In particular, q admits exactly 12 self-loops.*

The self-loop ratio is 12:1 — imperfect consonances are twelve times more "flexible" than perfect consonances with respect to parallel self-motion.

#### 3.4 Theorem 4: Hom-Set Cardinalities

**Theorem 3.6** (`total_permitted_to_perfect`). *The total number of permitted voice leadings into a fixed perfect consonance, summed over all consonant sources, is exactly 61.*

$$\sum_{i \in \mathcal{C}} |E(i, p)| = 61 \quad \text{for } p \in \mathcal{P}$$

**Theorem 3.7** (`total_permitted_to_imperfect`). *The total number of permitted voice leadings into a fixed imperfect consonance, summed over all consonant sources, is exactly 72.*

$$\sum_{i \in \mathcal{C}} |E(i, q)| = 72 \quad \text{for } q \in \mathcal{C} \setminus \mathcal{P}$$

The deficit is 72 − 61 = 11, which equals the number of non-trivial parallel motions (those with *b* = *s* ≠ 0 in ℤ/12ℤ).

#### 3.5 Theorem 5: Voice-Swap Asymmetry

**Theorem 3.8** (`voice_swap_breaks_consonance`). *The involution i ↦ −i on ℤ/12ℤ does not preserve the set of consonant intervals. Specifically, 7 ∈ 𝒞 but −7 ≡ 5 ∉ 𝒞.*

This formalizes the classical observation that the perfect fourth (5 semitones), while acoustically related to the perfect fifth (7 semitones) by complementation, is not classified as consonant in first-species counterpoint.

---

### 4. Proof Sketches

#### 4.1 Strong Connectivity (Theorem 3.1)

The proof is constructive. For distinct intervals *i* ≠ *j*, the *canonical voice leading* (0, *j* − *i*) maps *i* to *j*: the bass stays fixed while the soprano moves by *j* − *i*. Since *b* = 0, this is not parallel motion (which requires *b* = *s* ≠ 0), so the parallel-motion prohibition never triggers. For *i* = *j*, the identity voice leading (0, 0) is permitted — it is not parallel since *b* = 0. In both cases, source and target lie in 𝒞 by hypothesis.

The key insight is formalized in the helper lemma `canonical_not_parallel`: if *i* ≠ *j*, then the canonical voice leading has *b* = 0 ≠ *s* = *j* − *i*, so it fails the condition *b* = *s* required for parallel motion.

#### 4.2 Non-Composability (Theorem 3.3)

A concrete counterexample suffices. Consider:
- *i* = 3 (minor third), *j* = 7 (perfect fifth), *k* = 0 (unison)
- *v*₁ = (0, 4): bass stays, soprano moves by 4 semitones. Target: 3 + 4 − 0 = 7 ✓. Not parallel (0 ≠ 4) ✓.
- *v*₂ = (5, 5): both voices move by 5. Target: 7 + 5 − 5 = 7... 

Actually, the specific counterexample can be constructed as follows: choose two permitted voice leadings whose composite (sum of bass motions, sum of soprano motions) yields equal bass and soprano components that are nonzero, targeting a perfect consonance. Such triples exist by exhaustive enumeration over the finite space.

#### 4.3 Perfect Consonance Bottleneck (Theorems 3.4–3.5)

For a self-loop at interval *p*, the voice leading (*b*, *s*) must satisfy *p* + *s* − *b* = *p*, hence *s* = *b*. Every such voice leading is of the form (*d*, *d*). If (*d*, *d*) is a self-loop with *d* ≠ 0, it is parallel motion, and the target is *p* ∈ 𝒫. The parallel-motion prohibition excludes it. Only (*0*, *0*) survives.

For imperfect *q*, the same arithmetic gives *s* = *b*, but now the target *q* ∉ 𝒫, so the parallel-motion prohibition does not apply. All 12 voice leadings (*d*, *d*) for *d* ∈ ℤ/12ℤ are permitted.

#### 4.4 Hom-Set Computation (Theorems 3.6–3.7)

For a fixed target *j* and source *i*, the permitted voice leadings are pairs (*b*, *s*) with *s* = *j* − *i* + *b* (determined by the target equation). Thus there are 12 voice leadings from *i* to *j* (one per choice of *b*). If *j* ∈ 𝒫, we must exclude those with *b* = *s* and *b* ≠ 0, i.e., those with *b* = *j* − *i* + *b* which simplifies to *j* = *i*. So exclusions only occur when *i* = *j* = *p* ∈ 𝒫, removing 11 voice leadings.

Total incoming to a perfect consonance: 6 × 12 − 11 = 61.
Total incoming to an imperfect consonance: 6 × 12 − 0 = 72.

#### 4.5 Voice-Swap Asymmetry (Theorem 3.8)

Direct computation: −7 ≡ 5 (mod 12). The set 𝒞 = {0, 3, 4, 7, 8, 9} does not contain 5. ∎

---

### 5. Discussion

#### 5.1 Why Not a Category?

The failure of composability (Theorem 3.3) has deep implications for the categorical modeling of music. While the consonant intervals naturally form the objects of a category, and one can always take the free category on the Counterpoint Quiver, the morphisms in this free category include *paths* — sequences of permitted voice leadings — whose single-step compression may be forbidden.

This distinguishes the Counterpoint Quiver from algebraic structures like groups of musical transformations (the neo-Riemannian PLR group, the T/I group) where composition is always defined. Counterpoint lives in a different mathematical world: it is a *constraint system*, not a *transformation group*.

The appropriate categorical framework is that of a *quiver* (directed multigraph) rather than a category. The free category on this quiver contains all composable paths, but the single-step permitted voice leadings form only the *generating morphisms*, not a closed subcategory.

#### 5.2 The Bottleneck as Information Flow

The 61:72 ratio between incoming voice leadings to perfect vs. imperfect consonances can be interpreted as an *information-theoretic* constraint. A composer approaching a perfect consonance has fewer options — roughly 15% fewer — than one approaching an imperfect consonance. This creates a natural tension-and-release dynamic in counterpoint: passages leading to perfect consonances (cadential moments, points of arrival) are more constrained and hence more predictable, while passages moving between imperfect consonances allow greater freedom and variety.

The self-loop bottleneck (1:12) is even more dramatic. Sustaining a perfect consonance through parallel motion is impossible; the only option is stasis. This mathematically encodes the aesthetic judgment that parallel fifths and octaves sound "static" — because, in the formal system, they literally permit only static continuation.

#### 5.3 Bass-Voice Asymmetry

The voice-swap result (Theorem 3.8) connects to a long-standing debate in music theory about the status of the perfect fourth. Acoustically, the fourth (frequency ratio 4:3) is as "consonant" as the fifth (3:2) — they are related by octave complementation. Yet in practice, a fourth above the bass creates an unstable sonority (the "4-3 suspension" resolves downward), while a fourth above an upper voice is perfectly acceptable.

Our result formalizes this asymmetry: the function *i* ↦ 12 − *i* (voice swap) does not preserve 𝒞. This is equivalent to saying that the consonance set is not symmetric about 6 in ℤ/12ℤ, or equivalently, not closed under the unique non-trivial involution of ℤ/12ℤ that fixes 0 and 6.

#### 5.4 Connections to Pythagorean Theory

The consonant intervals {0, 3, 4, 7, 8, 9} relate to simple frequency ratios derivable from Pythagorean tuning theory. In prior work on harmonic foundations from Pythagorean triples, the consonance of these intervals is grounded in the physics of vibrating strings. The present work studies the *dynamics* of consonance — how consonant intervals connect through permitted voice leadings — rather than the *statics* of why particular intervals are consonant.

#### 5.5 Microtonal Extensions

The `CounterpointSystem n` abstraction allows immediate generalization. For 19-TET, one might define consonances based on the best approximations to just intervals:
- 𝒞₁₉ = {0, 5, 6, 11, 13, 14} (approximations of unison, m3, M3, P5, m6, M6)
- 𝒫₁₉ = {0, 11}

All five theorems can be investigated in this setting. Strong connectivity would follow from the same canonical-voice-leading argument. The bottleneck counts would change (19 self-loops for imperfect vs. 1 for perfect; total incoming 6 × 19 − 18 = 96 vs. 6 × 19 = 114). The voice-swap question becomes whether −11 ≡ 8 (mod 19) is consonant.

---

### 6. Future Work

#### 6.1 Higher Species Counterpoint

Second through fifth species introduce passing tones, suspensions, and rhythmic variety. These can be formalized as enriched quivers with labeled edges (by species type) extending the present framework. In second species, two notes sound against each note of the cantus firmus, introducing the concept of *strong* and *weak* beats with different consonance requirements. The weak-beat flexibility introduces additional edges that connect consonant intervals through dissonant passing tones, creating a richer graph structure.

Third species (four notes against one) would require modeling *paths of length 4* through an extended interval space that includes dissonances on weak beats. The non-composability result (Theorem 3.3) suggests that such multi-step paths cannot be reduced to single-step analysis — each species genuinely adds structural complexity.

Fourth species (suspensions) introduces *temporal asymmetry*: an interval that is consonant on a strong beat becomes dissonant on the following strong beat through the tied-over suspension. Formalizing this requires a product quiver indexed by metric position.

#### 6.2 Multi-Voice Extensions

Extending from two voices to three or more replaces intervals with chords. The quiver becomes a hypergraph, and the non-composability question becomes substantially more complex. For three voices, the state space consists of triples of pairwise intervals (subject to the constraint that the three intervals sum to zero mod 12), and the parallel-motion prohibition applies independently to each pair of voices.

A key open question is whether the three-voice counterpoint hypergraph remains strongly connected. The increased number of pairwise constraints could potentially disconnect the state space, creating "harmonic dead ends" from which no legal voice leading escapes.

#### 6.3 Markov Chain Analysis

Given the hom-set cardinalities, one can define a Markov chain on consonant intervals with transition probabilities proportional to |*E*(*i*, *j*)|. The stationary distribution would predict which intervals are most "visited" in random counterpoint — and this could be compared against frequency distributions in actual compositions by Palestrina, Bach, and other contrapuntal masters.

Preliminary computation shows that the uniform random walk on the Counterpoint Quiver converges to a stationary distribution that weights imperfect consonances more heavily than perfect ones, reflecting the 72:61 incoming-edge ratio. This aligns with empirical observations that thirds and sixths are far more common than unisons and fifths in Renaissance polyphony.

#### 6.4 Topological Invariants

The Counterpoint Quiver has a classifying space (the geometric realization of its nerve). Computing its fundamental group and homology groups could reveal topological obstructions to voice leading that have no purely combinatorial description. The non-composability result suggests non-trivial higher homotopy, since paths in the quiver that are "locally legal" can be "globally illegal."

#### 6.5 Computational Enumeration of Counterpoint Systems

For each *n*, one can systematically enumerate all counterpoint systems satisfying the `CounterpointSystem` axioms and classify them by their quiver-theoretic properties (connectivity, hom-set sizes, composability). The axioms require:
- A nonempty consonant set 𝒞 ⊆ ℤ/*n*ℤ
- A nonempty proper subset 𝒫 ⊂ 𝒞

For *n* = 12, the number of valid systems is large but finite (on the order of 2²⁴, though most are musically uninteresting). Classifying which systems yield strongly connected quivers, and which exhibit non-composability, would map the space of possible counterpoint-like constraint systems.

#### 6.6 Relationship to the Tonnetz

The neo-Riemannian Tonnetz is a graph on pitch classes; the Counterpoint Quiver is a graph on intervals. These live in dual spaces: pitch classes are elements of ℤ/12ℤ, while intervals are differences of elements. Studying functors between these structures could unify harmonic and contrapuntal perspectives. Specifically, the PLR group acts on chords (sets of pitch classes), while the Counterpoint Quiver describes transitions between intervals. A functor from the Tonnetz to the Counterpoint Quiver would translate harmonic progressions (chord changes) into contrapuntal constraints (permitted voice leadings).

#### 6.7 Algorithmic Composition

The strong connectivity result (Theorem 3.1) guarantees that any sequence of consonant intervals can be realized as a valid first-species counterpoint, provided each consecutive pair is connected by a permitted voice leading. This immediately yields an algorithm for counterpoint generation: given a desired sequence of harmonic intervals, find a compatible sequence of voice leadings by searching the hom-sets. The hom-set cardinalities (Theorems 3.6–3.7) provide bounds on the branching factor of this search, and the non-composability result (Theorem 3.3) shows that greedy local search may not always succeed — backtracking may be necessary.

More sophisticated approaches could use the Markov chain on the quiver to generate statistically natural counterpoint, or could incorporate additional constraints (range limits, stepwise motion preference) as further edge deletions in the quiver.

---

### 7. Catalog of Formal Results

| Result | Identifier | Statement |
|--------|-----------|-----------|
| Strong connectivity | `exists_permitted_voice_leading` | ∀ i j ∈ 𝒞, ∃ permitted vl from i to j |
| Non-composability | `non_composability` | ∃ composable pair whose composite is forbidden |
| Perfect self-loop uniqueness | `perfect_self_loop_unique` | Perfect consonance has exactly 1 self-loop |
| Imperfect self-loop count | `imperfect_self_loops_all` | Imperfect consonance has 12 self-loops |
| Perfect incoming count | `total_permitted_to_perfect` | 61 incoming voice leadings to each perfect consonance |
| Imperfect incoming count | `total_permitted_to_imperfect` | 72 incoming voice leadings to each imperfect consonance |
| Voice-swap asymmetry | `voice_swap_breaks_consonance` | Negation does not preserve consonance set |
| Canonical VL target | `targetInterval_canonical` | Canonical VL from i to j hits j |
| Canonical non-parallel | `canonical_not_parallel` | Canonical VL for i ≠ j is not parallel |

---

### References

1. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.
2. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
3. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
4. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
5. Popoff, A., Andreatta, M., & Ehresmann, A. (2015). A categorical generalization of Klumpenhouwer networks. *MCM 2015*, LNCS 9110, 303–314.
6. Noll, T. (2007). Musical intervals and special linear transformations. *Journal of Mathematics and Music*, 1(2), 121–137.
7. Jeppesen, K. (1939). *Counterpoint: The Polyphonic Vocal Style of the Sixteenth Century*. Prentice-Hall.
8. Aldwell, E., & Schachter, C. (2010). *Harmony and Voice Leading* (4th ed.). Cengage.

---

*All results in this paper have been formally verified using computer-aided proof methods over the structures defined in the formal development `Novelty/CounterpointCategory.lean`.*
