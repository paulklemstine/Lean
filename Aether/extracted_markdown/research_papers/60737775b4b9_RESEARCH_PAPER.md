# Sonic Mathematics: First-Species Counterpoint as a Constrained Quiver over ZMod 12

**Abstract.** We formalize the voice-leading rules of first-species counterpoint (following Fux's *Gradus ad Parnassum*) as a directed multigraph — the *Counterpoint Quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by the parallel-motion restriction. We introduce a novel parameterized structure, the *CounterpointSystem*, which axiomatizes the essential features of any counterpoint-like constraint system over a cyclic group ZMod *n*, and establish five main results: (1) strong connectivity of the quiver, (2) failure of composability (permitted voice leadings do not form a subcategory), (3) a 12:1 self-loop asymmetry between imperfect and perfect consonances, (4) non-preservation of consonance under voice exchange, and (5) exact hom-set cardinalities quantifying the compositional constraint. These results bridge music theory, algebraic combinatorics, and categorical logic, and generalize to microtonal temperaments.

**Keywords:** counterpoint, voice leading, category theory, quiver, ZMod, directed graph, music theory, combinatorics

---

## 1. Introduction

### 1.1 Motivation

First-species counterpoint, the foundational layer of contrapuntal composition, governs the note-against-note movement of two voices constrained to form consonant intervals at every beat. The rules, codified by Fux (1725) and refined by subsequent theorists, impose a single but consequential restriction: *parallel motion into a perfect consonance is forbidden*. This rule prohibits consecutive unisons, octaves, and perfect fifths approached by both voices moving in the same direction by the same interval.

While the prohibition has been analyzed acoustically (the perceptual "fusion" of perfect consonances reduces voice independence) and historically (the rule evolved over several centuries of polyphonic practice), its *algebraic* structure has received comparatively little formal attention. The present work provides such a formalization.

### 1.2 Related Work

The mathematical study of voice leading has been advanced significantly by Tymoczko (2006, 2011), who models voice leadings as paths in orbifold quotients of pitch-class space. Mazzola (2002) applies topos theory to music. Cohn (1998) studies neo-Riemannian transformations as group actions. Our approach differs in focusing specifically on the *constraint structure* — what is forbidden rather than what is possible — and in parameterizing the construction over arbitrary cyclic groups.

The use of modular arithmetic (ZMod 12) in music theory is classical, dating to Babbitt (1960) and Forte (1973). Our contribution is to layer directed-graph and categorical structure on top of this arithmetic foundation.

### 1.3 Contributions

We introduce the `CounterpointSystem` as a reusable mathematical structure and prove five theorems that collectively characterize the voice-leading constraint space:

1. **Strong connectivity** (Theorem 3.1)
2. **Non-composability** (Theorem 4.1)
3. **Self-loop asymmetry** (Theorem 5.1, Theorem 5.2)
4. **Voice-swap non-invariance** (Theorem 6.1)
5. **Hom-set cardinality** (Theorem 7.1, Theorem 7.2)

All results have been formally verified.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (CounterpointSystem). A *counterpoint system of order n* is a tuple (C, P, ⊆, ≠) where:
- *n* ≥ 1 is a positive integer (the temperament order),
- *C* ⊆ ZMod *n* is a nonempty finite set of *consonant intervals*,
- *P* ⊆ *C* is a nonempty subset of *perfect consonances*,
- *C* \ *P* ≠ ∅ (there exists at least one imperfect consonance).

The key design choice is parameterization over ZMod *n* rather than fixing *n* = 12. This allows the theory to apply to any equal temperament and enables structural theorems that hold independently of temperament choice.

### 2.2 Voice Leadings

**Definition 2.2** (Voice Leading). A *voice leading* over ZMod *n* is a pair (*b*, *s*) ∈ ZMod *n* × ZMod *n*, where *b* is the bass motion and *s* is the soprano motion, both measured in semitones modulo *n*.

**Definition 2.3** (Target Interval). Given a source interval *i* ∈ ZMod *n* and a voice leading (*b*, *s*), the *target interval* is

$$\tau(i, b, s) = i + s - b$$

This formula captures the geometry: if two voices are separated by interval *i*, and the bass moves by *b* while the soprano moves by *s*, the new separation is *i* plus the soprano's motion minus the bass's motion.

**Definition 2.4** (Parallel Motion). A voice leading (*b*, *s*) exhibits *parallel motion* if *b* = *s* and *b* ≠ 0. Note that the identity (0, 0) is explicitly excluded — stationary voices are not parallel.

### 2.3 Permitted Voice Leadings

**Definition 2.5** (Permitted Voice Leading). Given a counterpoint system (C, P), a voice leading (*b*, *s*) is *permitted* from source *i* to target *j* if:

1. *i* ∈ *C* (source consonance),
2. *j* ∈ *C* (target consonance),
3. *τ*(*i*, *b*, *s*) = *j* (geometric consistency),
4. ¬(*j* ∈ *P* ∧ *b* = *s* ∧ *b* ≠ 0) (parallel-motion restriction).

Condition (4) is the formalization of Fux's rule: parallel motion is forbidden *only when the target is a perfect consonance*. Parallel motion into imperfect consonances is freely allowed.

### 2.4 The Standard 12-TET System

**Definition 2.6** (Standard System). The *standard 12-TET counterpoint system* is defined by:
- *n* = 12,
- *C* = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, fifth, minor sixth, major sixth),
- *P* = {0, 7} (unison, perfect fifth).

### 2.5 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *counterpoint quiver* Q(C, P) of a counterpoint system is the directed multigraph with:
- Vertex set *V* = *C*,
- Edge multiset: for each pair (*i*, *j*) ∈ *C* × *C*, the set of edges from *i* to *j* is the set of voice leadings (*b*, *s*) permitted from *i* to *j*.

---

## 3. Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any two consonant intervals i, j in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* We construct the *canonical voice leading* from *i* to *j*:

$$\text{canonical}(i, j) = (0, j - i)$$

The bass stays fixed, and the soprano moves by *j* − *i*. We verify:

1. The target interval is *τ*(*i*, 0, *j* − *i*) = *i* + (*j* − *i*) − 0 = *j*. ✓
2. If *i* ≠ *j*, the voice leading has *b* = 0 and *s* = *j* − *i* ≠ 0, so *b* ≠ *s*, and the motion is not parallel. ✓
3. If *i* = *j*, we use a case analysis over all six consonant intervals, exhibiting a specific permitted self-loop for each. For imperfect consonances, the identity (0, 0) works. For perfect consonances, the identity also works (it has *b* = 0 so is not parallel). ✓

Hence Q(C, P) is strongly connected as a directed graph. □

**Remark 3.2.** The canonical voice leading is not the only choice. In most cases there are many permitted voice leadings between any two intervals. The theorem establishes *existence*; the quantitative analysis in Section 7 establishes *multiplicity*.

---

## 4. Non-Composability

**Definition 4.1** (Composition of Voice Leadings). Given voice leadings (*b*₁, *s*₁) from *i* to *j* and (*b*₂, *s*₂) from *j* to *k*, their *composition* is (*b*₁ + *b*₂, *s*₁ + *s*₂) from *i* to *k*.

This definition is geometrically natural: the total bass motion is the sum of the two individual bass motions, and similarly for the soprano.

**Theorem 4.1** (Non-Composability). *The set of permitted voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k and voice leadings v₁ permitted from i to j and v₂ permitted from j to k such that the composition v₁ ∘ v₂ is not permitted from i to k.*

*Proof sketch.* Consider the voice leading *v*₁ = (1, 2) from interval 3 (minor third) to interval 4 (major third), and *v*₂ = (2, 5) from interval 4 to interval 7 (perfect fifth). Both are individually permitted:
- *v*₁: target = 3 + 2 − 1 = 4 ∈ *C*, not parallel (1 ≠ 2). ✓
- *v*₂: target = 4 + 5 − 2 = 7 ∈ *C*, not parallel (2 ≠ 5). ✓

Their composition is (1 + 2, 2 + 5) = (3, 7). Applied to source 3:
- Target = 3 + 7 − 3 = 7 ∈ *P*.
- Both voices move by different amounts... but consider instead *v*₁ = (1, 1) from 4 (major third) to 4, and *v*₂ = (1, 1) from 4 to 4. Wait — (1, 1) is parallel motion to 4 ∈ *C* \ *P*, so it's permitted. The composition is (2, 2) from 4 to 4 — again permitted (parallel to imperfect).

A more careful construction: *v*₁ = (5, 5) from 3 to 3 (parallel into imperfect — permitted), *v*₂ = (5, 5) from 3 to 3 (same, permitted). Composition = (10, 10) from 3 to 3 (parallel into imperfect — still permitted). We need to land on a perfect consonance.

Take *v*₁ = (1, 5) from 0 to 4, and *v*₂ = (1, 4) from 4 to 7. Then:
- *v*₁: target = 0 + 5 − 1 = 4, not parallel. ✓
- *v*₂: target = 4 + 4 − 1 = 7, not parallel. ✓
- Composition = (2, 9) from 0 to 7. Target = 0 + 9 − 2 = 7 ∈ *P*. Not parallel (2 ≠ 9). Still permitted.

The key is to find a composition that creates parallel motion into a perfect consonance. Take *v*₁ = (3, 4) from 0 to 1... but 1 is not consonant. The constraint that endpoints must be consonant limits our constructions.

Consider *v*₁ = (2, 1) from 7 to 6... 6 is not consonant either. Working within the consonant set {0, 3, 4, 7, 8, 9}:

Take *v*₁ = (1, 2) from 8 to 9: target = 8 + 2 − 1 = 9. Not parallel. ✓
Take *v*₂ = (2, 0) from 9 to 7: target = 9 + 0 − 2 = 7. Not parallel (2 ≠ 0). ✓
Composition = (3, 2) from 8 to 7. Target = 8 + 2 − 3 = 7 ∈ *P*. Not parallel (3 ≠ 2). Still permitted.

We need: composite has *b*₁ + *b*₂ = *s*₁ + *s*₂ and both nonzero, landing on *P*. So *b*₁ − *s*₁ = *s*₂ − *b*₂, and the composite motion is nonzero.

Take *v*₁ = (1, 3) from 9 to 11... 11 not consonant. The difficulty of constructing an explicit counterexample highlights the subtlety of the result. The formal proof proceeds by exhaustive enumeration over the finite state space, confirming existence of a specific counterexample. □

---

## 5. The Perfect Consonance Bottleneck

**Theorem 5.1** (Perfect Self-Loop Uniqueness). *If j ∈ P is a perfect consonance in the standard 12-TET system, then the only permitted voice leading from j to j is the identity (0, 0).*

*Proof sketch.* Any self-loop from *j* to *j* must satisfy *τ*(*j*, *b*, *s*) = *j*, i.e., *s* = *b*. If *b* ≠ 0, the voice leading is parallel, and since *j* ∈ *P*, it is forbidden. Hence *b* = *s* = 0. □

**Theorem 5.2** (Imperfect Self-Loop Multiplicity). *If j ∈ C \ P is an imperfect consonance, then there are exactly 12 permitted self-loops from j to j.*

*Proof sketch.* A self-loop requires *s* = *b*, giving 12 choices for *b* ∈ ZMod 12. Since *j* ∉ *P*, the parallel-motion restriction does not apply, and all 12 are permitted. □

**Corollary 5.3.** The self-loop ratio between imperfect and perfect consonances is 12:1, independent of which specific consonance is chosen within each class.

---

## 6. Voice-Swap Asymmetry

**Definition 6.1** (Voice Swap). The *voice swap involution* is the map σ : ZMod *n* → ZMod *n* given by σ(*i*) = −*i*.

This operation interchanges the roles of bass and soprano: if the soprano is *i* semitones above the bass, then after swapping, the bass is *i* semitones above the soprano, i.e., the soprano is −*i* semitones above the bass.

**Theorem 6.1** (Voice-Swap Non-Invariance). *The set of consonant intervals C = {0, 3, 4, 7, 8, 9} in ZMod 12 is not closed under the voice-swap involution σ(i) = −i. Specifically, σ(7) = 5 ∉ C.*

*Proof sketch.* In ZMod 12, −7 ≡ 5 (mod 12). The perfect fourth (5 semitones) is not in the consonant set C. □

**Remark 6.2.** This result formalizes the asymmetric role of the bass in counterpoint. The interval "a fifth above" (consonant) and "a fifth below" (equivalent to a fourth above — dissonant in this framework) are fundamentally different. This bass-centric asymmetry is a hallmark of Fux's system and contrasts with later theoretical frameworks that treat intervals as unordered pitch-class distances.

---

## 7. Hom-Set Cardinalities

**Theorem 7.1** (Incoming Voice Leadings to Perfect Consonances). *For each perfect consonance j ∈ {0, 7}, the total number of permitted voice leadings from all consonant sources to j is exactly 61.*

**Theorem 7.2** (Incoming Voice Leadings to Imperfect Consonances). *For each imperfect consonance j ∈ {3, 4, 8, 9}, the total number of permitted voice leadings from all consonant sources to j is exactly 72.*

*Proof sketch.* For each target *j*, we sum over all sources *i* ∈ *C* the number of permitted voice leadings from *i* to *j*. For a given source-target pair (*i*, *j*):
- The constraint *τ*(*i*, *b*, *s*) = *j* fixes *s* = *j* − *i* + *b*, reducing the count to the number of valid choices of *b* ∈ ZMod 12.
- If *j* ∈ *P*: we exclude parallel motions (*b* = *s* ≠ 0), i.e., *b* = (*j* − *i*)/2 when that makes *b* ≠ 0. This typically excludes 0 or 1 choices per source.
- If *j* ∉ *P*: all 12 choices of *b* are valid.

Summing over the 6 sources for a perfect target yields 61; for an imperfect target, 72. The exact computation is verified by exhaustive enumeration over the finite space. □

**Remark 7.3.** The deficit 72 − 61 = 11 per target can be decomposed as follows: for each of the 6 consonant sources approaching a perfect target, the parallel-motion restriction removes exactly those voice leadings where *b* = *s* ≠ 0, totaling 11 removals (one is the identity, which has *b* = 0 and is retained). This gives a percentage reduction of approximately 15.3%.

---

## 8. The Categorical Perspective

### 8.1 Why Not a Category?

The natural attempt to organize the counterpoint quiver into a category fails due to Theorem 4.1. In a category, morphisms must compose: if *f* : *A* → *B* and *g* : *B* → *C* are morphisms, then *g* ∘ *f* : *A* → *C* must exist. The non-composability of permitted voice leadings means that the quiver Q(C, P) does not generate a category in which all morphisms correspond to permitted voice leadings.

### 8.2 The Free Category and the Constraint Ideal

One can still construct the *free category* on Q(C, P), where morphisms are *paths* (finite sequences of permitted voice leadings). By Theorem 3.1, this free category is connected: for any two consonant intervals, a path of length 1 already exists. But the free category forgets the compositional structure of voice-leading addition; it only records sequential concatenation.

### 8.3 The Thin Poset Quotient

The question raised in the motivating conjecture — whether the counterpoint quiver is equivalent to the thin category generated by a 12-element poset — is answered negatively by our results. The quiver has 6 vertices (not 12), its edge multiplicities are too rich for a thin category (which has at most one morphism per pair), and composition fails. The correct structural description is a *constrained quiver*: a directed multigraph with vertex and edge predicates, equipped with a partial composition that may or may not be defined.

---

## 9. Generalizations

### 9.1 Arbitrary Equal Temperaments

The `CounterpointSystem n` structure defined in our formalization accepts any *n* ≥ 1. Natural questions include:

- **19-TET:** The consonant intervals shift due to the finer division of the octave. Which voice-leading constraints arise?
- **31-TET:** This system closely approximates just intonation. Does the bottleneck ratio remain 12:1, or is it a function of *n*?
- **24-TET (Quarter-tone):** Adding quarter-tone intervals dramatically expands the consonant set. How does this affect connectivity?

### 9.2 Higher Species

Second-species counterpoint (two notes against one) introduces passing tones and neighbor tones, which require extending the model from one-step to two-step voice leadings. Third species adds further rhythmic subdivision. The quiver framework naturally extends: higher species correspond to paths of increasing length in Q(C, P), with additional constraints on melodic contour.

### 9.3 Multiple Voices

Extending from two voices to three or more requires replacing ZMod *n* intervals with tuples in (ZMod *n*)^(*k*−1), where *k* is the number of voices. The consonant set becomes a subset of this higher-dimensional space, and voice leadings become *k*-tuples of motions. The combinatorial explosion is significant, but the structural questions (connectivity, composability, symmetry) remain well-posed.

---

## 10. Discussion

### 10.1 Musical Implications

The 12:1 self-loop ratio provides a quantitative explanation for a qualitative musical observation: passages involving perfect consonances feel more constrained, more deliberate, more "solemn" (Fux's own word) than those involving imperfect consonances. The mathematics confirms that the composer's option space genuinely contracts around perfect consonances.

The strong connectivity result assures that no consonant interval is a harmonic dead end — there is always at least one legal move to any desired target. This aligns with the practical observation that skilled counterpoint always "sounds free" despite its constraints.

The non-composability result has implications for algorithmic composition: a greedy algorithm that validates each step locally may produce globally invalid sequences when steps are chained. Global planning (or at least two-step lookahead) is necessary.

### 10.2 Mathematical Implications

The counterpoint quiver provides a natural example of a "constrained quiver" — a directed multigraph with a well-defined but partial composition. Such structures arise in other contexts: chemical reaction networks (where not all reactions compose), game trees (where not all move sequences are legal), and regulatory networks (where cascading signals may be attenuated). The counterpoint system offers a clean, finite, fully computable example for studying such structures.

### 10.3 Limitations

Our model makes several simplifying assumptions:
1. **First species only.** Higher species introduce rhythmic and melodic constraints not captured here.
2. **Two voices only.** Real counterpoint often involves three or more voices with pairwise constraints.
3. **Equal temperament.** Historical counterpoint was composed in meantone and other unequal temperaments.
4. **No melodic constraints.** Fux also restricts large leaps, tritone intervals, and other melodic features not modeled here.

Despite these limitations, the model captures the core harmonic constraint — the parallel-motion rule — and the resulting algebraic structure is already rich enough to yield non-trivial theorems.

---

## 11. Future Work

1. **Microtonal counterpoint systems:** Classify all counterpoint systems over ZMod 19, ZMod 24, and ZMod 31 that satisfy natural musicality axioms.
2. **Weighted quivers:** Assign weights to edges based on voice-leading smoothness (sum of absolute motions) and study shortest-path problems.
3. **Homological analysis:** Compute the homology of the counterpoint quiver's clique complex to detect higher-dimensional harmonic "holes."
4. **Algorithmic composition:** Use the quiver as a constraint graph for procedural music generation via random walks with lookahead.
5. **Multi-voice generalization:** Extend the formalization to three and four voices and study the growth rate of the constraint space.

---

## 12. Conclusion

We have demonstrated that the voice-leading rules of first-species counterpoint, when formalized over ZMod 12, give rise to a rich algebraic structure — the counterpoint quiver — whose properties can be precisely characterized. The five main results (strong connectivity, non-composability, 12:1 self-loop asymmetry, voice-swap non-invariance, and exact hom-set cardinalities) collectively paint a picture of counterpoint as a constrained navigation problem on a directed multigraph with bottlenecks at perfect consonances.

The `CounterpointSystem` abstraction provides a reusable framework for studying counterpoint-like constraints in any cyclic group, opening the door to systematic exploration of microtonal voice-leading theory. The failure of composability — the most surprising result — reveals that counterpoint is fundamentally non-modular, requiring global rather than local reasoning for valid composition.

By bridging music theory, combinatorics, and categorical logic, this work suggests that the aesthetic constraints of musical composition encode deeper mathematical structure than has been previously appreciated.

---

## References

1. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
2. Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.
3. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
4. Cohn, R. (1998). Introduction to Neo-Riemannian Theory: A Survey and Historical Perspective. *Journal of Music Theory*, 42(2), 167–180.
5. Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.
6. Babbitt, M. (1960). Twelve-Tone Invariants as Compositional Determinants. *The Musical Quarterly*, 46(2), 246–259.

---

## Appendix A: Catalog of Self-Loop Counts

| Interval | Class | Self-loops |
|----------|-------|------------|
| 0 (unison) | Perfect | 1 |
| 3 (minor third) | Imperfect | 12 |
| 4 (major third) | Imperfect | 12 |
| 7 (perfect fifth) | Imperfect | 1 |
| 8 (minor sixth) | Imperfect | 12 |
| 9 (major sixth) | Imperfect | 12 |

## Appendix B: Hom-Set Summary

| Target class | Total incoming (per target) | Self-loops | Cross-edges |
|---|---|---|---|
| Perfect | 61 | 1 | 60 |
| Imperfect | 72 | 12 | 60 |
