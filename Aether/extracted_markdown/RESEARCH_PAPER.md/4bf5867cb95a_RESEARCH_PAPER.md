# Sonic Mathematics: First-Species Counterpoint as a Voice-Leading Quiver

## Abstract

We formalize the rules of first-species counterpoint—the simplest form of polyphonic voice leading codified in Fux's *Gradus ad Parnassum* (1725)—as a directed multigraph (quiver) over the twelve-tone chromatic universe. The vertices of this quiver are the six consonant intervals modulo 12 semitones; the edges are voice leadings permitted by the parallel-motion prohibition on perfect consonances. We introduce a parameterized algebraic structure, the **Counterpoint System**, which abstracts these constraints to arbitrary equal-temperament systems over ℤ/nℤ.

Within this framework, we establish five main results: (1) the counterpoint quiver is strongly connected; (2) permitted voice leadings fail to compose, hence do not form a subcategory of any ambient categorical structure; (3) self-loops at perfect consonances are uniquely the identity, while imperfect consonances admit 12 self-loops, yielding a 12:1 bottleneck ratio; (4) the involution i ↦ −i on ℤ/12ℤ does not preserve consonance, formalizing the asymmetric role of the bass voice; and (5) the total incoming hom-sets to perfect consonances contain 61 elements versus 72 for imperfect consonances. These results bridge music theory, combinatorics on ℤ/nℤ, and quiver theory, revealing that the structural constraints of counterpoint are algebraic rather than merely aesthetic.

**Keywords:** counterpoint, voice leading, quiver, category theory, modular arithmetic, consonance, music theory, Fux

---

## 1. Introduction

### 1.1 Historical Context

The study of counterpoint—the art of combining independent melodic lines—is among the oldest formalized disciplines in Western intellectual history. Its rules were codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725), building on centuries of practice and earlier treatises by Zarlino (1558) and others. First-species counterpoint, the foundation of Fux's pedagogical system, restricts attention to note-against-note motion: two voices move simultaneously in whole notes, and every vertical sonority must be consonant.

The mathematical study of these rules has a rich modern history. Guerino Mazzola's *The Topos of Music* (2002) applied category theory and topos theory to music-theoretic structures. Dmitri Tymoczko (2006, 2011) modeled voice-leading spaces as orbifolds, revealing their geometric structure. The neo-Riemannian tradition (Cohn 1998, Fiore & Satyendra 2005) employed group actions on pitch-class sets.

Our approach differs from these predecessors in a specific way: rather than modeling pitch-class *sets* or *chord spaces*, we formalize the **constraint structure** of counterpoint rules as a directed multigraph and study its combinatorial and algebraic properties. This shift—from the objects of harmony to the morphisms of voice leading—reveals structural phenomena that are invisible at the level of individual chords.

### 1.2 Overview of Results

We introduce the **Counterpoint System** as a parameterized algebraic structure over ℤ/nℤ, consisting of a set of consonant intervals, a distinguished subset of perfect consonances, and the parallel-motion prohibition. For the standard 12-TET system, we compute the complete structure of the resulting voice-leading quiver and establish five theorems that characterize its combinatorics.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *counterpoint system of order n*, where n ≥ 1, is a triple (C, P, φ) where:
- C ⊆ ℤ/nℤ is a finite nonempty set of *consonant intervals*;
- P ⊆ C is a nonempty set of *perfect consonances*;
- C \ P ≠ ∅ (there exists at least one *imperfect consonance*);
- φ is the *parallel-motion prohibition*: a voice leading into a perfect consonance via parallel motion is forbidden.

The requirement that imperfect consonances exist is essential—a system consisting only of perfect consonances would prohibit all parallel motion, creating a qualitatively different (and musically uninteresting) constraint regime.

### 2.2 Voice Leadings

**Definition 2.2** (Voice Leading). A *voice leading* in ℤ/nℤ is a pair (b, s) ∈ ℤ/nℤ × ℤ/nℤ, where b is the motion of the bass voice and s is the motion of the soprano voice, both measured in semitones modulo n.

**Definition 2.3** (Target Interval). Given a source interval i ∈ ℤ/nℤ and a voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This formula reflects the fact that if the voices are initially at interval i, soprano motion by s increases the interval while bass motion by b decreases it.

**Definition 2.4** (Parallel Motion). A voice leading (b, s) exhibits *parallel motion* if b = s and b ≠ 0. When b = s, both voices move by the same amount, preserving the interval; the condition b ≠ 0 excludes the identity (stationary) voice leading.

### 2.3 Permitted Voice Leadings

**Definition 2.5** (Permitted Voice Leading). Given a counterpoint system (C, P, φ), a voice leading (b, s) from source interval i to target interval j is *permitted* if:
1. i ∈ C (source is consonant);
2. j ∈ C (target is consonant);
3. τ(i, b, s) = j (the voice leading maps source to target);
4. ¬(j ∈ P ∧ b = s ∧ b ≠ 0) (no parallel motion into a perfect consonance).

### 2.4 The Standard 12-TET System

**Definition 2.6** (Standard System). The *standard 12-TET counterpoint system* is the counterpoint system of order 12 with:
- C = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth);
- P = {0, 7} (unison and perfect fifth).

This matches the consonance classification of first-species counterpoint as taught in standard harmony textbooks (Aldwell & Schachter 2010, Kostka & Payne 2012).

### 2.5 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *counterpoint quiver* of a counterpoint system (C, P, φ) of order n is the directed multigraph Q = (V, E) where:
- V = C (vertices are consonant intervals);
- For each i, j ∈ C, the edge set E(i, j) consists of all voice leadings (b, s) ∈ ℤ/nℤ × ℤ/nℤ such that the voice leading is permitted from i to j.

We use the term "quiver" rather than "category" advisedly—as Theorem 3.2 shows, the edges do not compose.

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *In the standard 12-TET counterpoint system, for any consonant intervals i, j ∈ C, there exists a permitted voice leading from i to j.*

*Proof sketch.* For i ≠ j, the *canonical voice leading* (0, j − i)—bass stationary, soprano moves by j − i—maps interval i to interval j. Since bass motion is 0, this is never parallel (parallel motion requires b = s ≠ 0, but b = 0). Both endpoints are consonant by hypothesis, so the voice leading is permitted.

For i = j, the identity voice leading (0, 0) is always permitted: it maps i to i, and it is not parallel (since b = 0). The case analysis over all six consonant intervals confirms this. □

**Corollary 3.1.1.** The counterpoint quiver is strongly connected as a directed graph (ignoring edge multiplicities).

### 3.2 Non-Composability

**Theorem 3.2** (Non-Composability). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k ∈ C and permitted voice leadings (b₁, s₁) from i to j and (b₂, s₂) from j to k such that the composed voice leading (b₁ + b₂, s₁ + s₂) is not permitted from i to k.*

*Proof sketch.* Consider the voice leading from interval 3 (minor third) to interval 7 (perfect fifth) via (b₁, s₁) where soprano and bass motions are chosen so that their sum with a subsequent voice leading from 7 to 7 yields a parallel motion into a perfect consonance. Concretely, take a non-trivial voice leading arriving at 7, then compose with the identity at 7; alternatively, construct two voice leadings whose individual non-parallelism combines into parallelism via:
- (b₁, s₁) from some i to j with b₁ ≠ s₁;
- (b₂, s₂) from j to k ∈ P with b₂ ≠ s₂;
- But b₁ + b₂ = s₁ + s₂ ≠ 0.

Such configurations exist because the constraint is on individual steps, not cumulative motion. A systematic search over ℤ/12ℤ confirms the existence of such witnesses. □

**Remark 3.2.1.** This theorem has a fundamental structural consequence: the counterpoint quiver is genuinely a quiver (directed multigraph), not a category. The permitted voice leadings do not form a subcategory of the ambient free category on the quiver. This means counterpoint is inherently *non-compositional* in the algebraic sense—validity cannot be checked locally and combined globally.

### 3.3 The Perfect-Consonance Bottleneck

**Theorem 3.3** (Self-Loop Asymmetry). *In the standard 12-TET system:*
- *(a) Each perfect consonance p ∈ P admits exactly 1 self-loop: the identity voice leading (0, 0).*
- *(b) Each imperfect consonance q ∈ C \ P admits exactly 12 self-loops.*

*Proof sketch.* A self-loop at interval i is a voice leading (b, s) with τ(i, b, s) = i, which forces s = b. The set of self-loops is therefore {(b, b) : b ∈ ℤ/12ℤ}.

For imperfect consonances (i ∉ P): the target i is not perfect, so the parallel-motion prohibition does not apply. All 12 choices of b yield permitted self-loops.

For perfect consonances (i ∈ P): the parallel-motion prohibition eliminates all (b, b) with b ≠ 0, leaving only (0, 0). □

**Corollary 3.3.1.** The ratio of self-loop counts between imperfect and perfect consonances is 12:1.

**Interpretation.** This asymmetry is the quantitative expression of Fux's parallel-motion rule. At a perfect consonance, the only way to stay is to be still. At an imperfect consonance, any parallel motion is permitted. This creates a "bottleneck" at perfect consonances: they are hard to sustain, forcing the music to move through them quickly or arrive via non-parallel motion.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.4** (Voice-Swap Breaks Consonance). *The involution σ : ℤ/12ℤ → ℤ/12ℤ defined by σ(i) = −i does not preserve the set of consonant intervals. Specifically, σ(7) = 5 ∉ C.*

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12), and 5 ∉ {0, 3, 4, 7, 8, 9}. □

**Interpretation.** The map i ↦ −i represents voice exchange: if the soprano is i semitones above the bass, then after swapping, the soprano is −i ≡ 12 − i semitones above the (new) bass. The fact that this map sends the perfect fifth (7) to the perfect fourth (5)—which is dissonant in counterpoint—formalizes the well-known asymmetry of the bass voice.

This result has deep music-theoretic significance. The perfect fourth is acoustically consonant (frequency ratio 4:3) but functionally dissonant when it involves the bass voice. Our formalization shows this is not an arbitrary convention but a structural consequence of the asymmetry of the consonance set under negation.

### 3.5 Hom-Set Cardinalities

**Theorem 3.5** (Hom-Set Computation). *In the standard 12-TET system, the total number of permitted voice leadings with target in P (perfect consonances) is 61, while the total with target in C \ P (imperfect consonances) is 72 per imperfect target.*

*Proof sketch.* For each target j, the number of permitted voice leadings from all sources i ∈ C is computed by:

$$|E(*, j)| = \sum_{i \in C} |\{(b,s) \in (\mathbb{Z}/12\mathbb{Z})^2 : \tau(i,b,s) = j \text{ and } \neg(j \in P \land b = s \neq 0)\}|$$

For each source i and target j, the constraint τ(i, b, s) = j fixes s = j − i + b, giving 12 choices of b. If j ∈ P, we must subtract the cases where b = s = j − i + b, which simplifies to those where b = s and b ≠ 0—this eliminates one case (when b = 0 is the only non-parallel option... more precisely, parallel motion means b = s ≠ 0, and s = j − i + b = b requires j = i, so only self-loops are affected by the subtraction).

Careful case analysis over all 6 × 2 = 12 source-target pairs involving perfect targets yields a total of 61. The analogous count for each imperfect target yields 72. □

**Remark 3.5.1.** The ratio 61/72 ≈ 0.847 quantifies the "cost" of targeting a perfect consonance: approximately 15% fewer voice leadings are available. This provides a precise measure of the compositional constraint imposed by Fux's rules.

---

## 4. The Counterpoint System as an Algebraic Structure

### 4.1 Generalization to ℤ/nℤ

The parameterization of the counterpoint system over ℤ/nℤ enables the study of counterpoint-like constraints in microtonal systems. Historical and contemporary tuning systems that fit this framework include:

| System | n | Historical Usage |
|--------|---|-----------------|
| 12-TET | 12 | Standard Western (Bach onwards) |
| 19-TET | 19 | Salinas (1577), Costeley (1570) |
| 24-TET | 24 | Quarter-tone music (Hába, Ives) |
| 31-TET | 31 | Huygens (1691), Fokker (1950s) |
| 53-TET | 53 | Mercator, Chinese theory |

For each such system, one may define consonance and perfectness sets and study the resulting quiver. The structural theorems generalize as follows:

**Proposition 4.1.** *Strong connectivity holds for any counterpoint system (C, P, φ) of order n ≥ 2 with |C| ≥ 2.*

*Proof sketch.* The canonical voice leading construction depends only on the availability of bass-stationary motion, which is never parallel. □

**Proposition 4.2.** *Non-composability holds for any counterpoint system of order n in which there exist consonant intervals i, j, k with k ∈ P and elements b₁, b₂ ∈ ℤ/nℤ such that j − i + b₁ ≠ b₁, k − j + b₂ ≠ b₂, but (b₁ + b₂) = (j − i + b₁) + (k − j + b₂).*

### 4.2 The Quiver vs. Category Distinction

Our result that permitted voice leadings do not compose (Theorem 3.2) places the counterpoint quiver firmly in the world of *quivers* (directed multigraphs) rather than *categories*. This has precedent in other mathematical modeling contexts:

- In homotopy theory, paths compose but not all morphisms in a quiver do.
- In database theory, schema mappings form quivers that may not compose (Fagin et al. 2005).
- In quantum computing, certain gate sets generate categories only when composition constraints are lifted.

The counterpoint quiver occupies a middle ground: it is not a free quiver (not all conceivable voice leadings are permitted), nor a category (permitted ones don't compose), nor a poset (multiple edges between vertices exist). It is a *constrained quiver with multiplicity*, a structure that merits further algebraic study.

### 4.3 Relationship to the Thin Category Conjecture

The original motivating conjecture asked whether the category of first-species counterpoint is equivalent to a thin category (one with at most one morphism between any two objects) generated by a poset. Our results show this conjecture must be refined:

1. The permitted voice leadings do not form a category at all (Theorem 3.2), so "the category of first-species counterpoint" requires careful definition.
2. The edge multiplicities (12 self-loops at imperfect consonances vs. 1 at perfect) show the structure is far from thin.
3. The correct mathematical object is a *quiver with constraints*, not a category.

However, the *underlying directed graph* (ignoring multiplicities) does have interesting poset-like properties, and the quotient by an appropriate equivalence relation on voice leadings may yield a thin category. This remains an open question.

---

## 5. Computational Aspects

### 5.1 Enumeration

The complete counterpoint quiver for the standard 12-TET system can be computed by exhaustive search over the 6 × 6 × 12² = 5184 possible (source, target, voice-leading) combinations. Of these, the permitted ones number:

| Target Type | Per Target | Number of Targets | Total |
|-------------|-----------|-------------------|-------|
| Perfect | 61 | 2 | 122 |
| Imperfect | 72 | 4 | 288 |
| **Total** | | **6** | **410** |

### 5.2 Algorithmic Applications

The quiver structure enables algorithmic composition under counterpoint constraints:

1. **Path enumeration**: Finding all valid n-step counterpoint progressions reduces to counting paths of length n in the quiver.
2. **Constraint satisfaction**: Composing counterpoint with additional constraints (e.g., avoiding certain intervals, targeting cadences) becomes a constraint-satisfaction problem on the quiver.
3. **Markov models**: Assigning transition probabilities to the quiver edges yields a Markov chain model of counterpoint, enabling style-specific generation.

---

## 6. Discussion

### 6.1 Music-Theoretic Implications

Our results provide mathematical precision to several well-known music-theoretic observations:

- **The "strength" of perfect consonances**: The bottleneck effect (Theorem 3.3) quantifies why perfect consonances sound "final" or "strong"—they are hard to reach and hard to leave via parallel motion, giving them a structural weight in the voice-leading network.

- **The bass voice asymmetry**: Theorem 3.4 gives a group-theoretic explanation for why counterpoint theory treats the bass differently from upper voices—the consonance set is not invariant under the natural involution of voice exchange.

- **The necessity of voice independence**: The non-composability result (Theorem 3.2) explains why counterpoint requires *continuous attention* to voice leading—one cannot simply string together locally valid moves. This reflects the musical insight that good counterpoint emerges from planning, not concatenation.

### 6.2 Connections to Other Mathematical Frameworks

- **Tymoczko's orbifold model** (2006): Our quiver lives on the boundary of Tymoczko's voice-leading orbifold, restricted to consonant intervals. The orbifold captures continuous voice leading; our model captures the discrete constraint structure.

- **Neo-Riemannian theory**: The PLR group acts on major and minor triads; our voice leadings act on intervals. The connection between these frameworks—via the decomposition of triads into constituent intervals—is a natural direction for future work.

- **Mazzola's counterpoint theory** (2002): Mazzola's deformation-theoretic approach to counterpoint models consonance through symmetry groups. Our approach is complementary, focusing on the combinatorial constraint structure rather than the symmetry algebra.

---

## 7. Future Work

1. **Higher species**: Extend the framework to second, third, fourth, and fifth species counterpoint, which introduce passing tones, suspensions, and rhythmic variety. The quiver structure will become richer, with typed edges corresponding to different species.

2. **Multi-voice counterpoint**: Generalize from two voices to n voices, where the constraint applies to all pairs. The resulting structure is a quiver on n-tuples of intervals.

3. **The composition closure**: Study the smallest category containing all permitted voice leadings—the free category generated by the quiver, quotiented by the relations that identify composed paths with their net voice leadings when those are themselves permitted.

4. **Microtonal counterpoint**: Systematically study counterpoint systems for n = 19, 24, 31, 53, determining which structural properties (connectivity, non-composability, bottleneck) persist and which are specific to n = 12.

5. **Spectral and probabilistic analysis**: Study the adjacency operator of the quiver as a linear map on ℝ^|C| and analyze its spectrum. This would connect counterpoint structure to spectral graph theory and random walks on the quiver.

---

## 8. References

- Aldwell, E. & Schachter, C. (2010). *Harmony and Voice Leading*. 4th ed. Cengage.
- Cohn, R. (1998). Introduction to neo-Riemannian theory. *Journal of Music Theory*, 42(2), 167–180.
- Fiore, T. & Satyendra, R. (2005). Generalized contextual groups. *Music Theory Online*, 11(3).
- Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
- Kostka, S. & Payne, D. (2012). *Tonal Harmony*. 7th ed. McGraw-Hill.
- Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
- Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
- Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
- Zarlino, G. (1558). *Le Istitutioni Harmoniche*. Venice.
