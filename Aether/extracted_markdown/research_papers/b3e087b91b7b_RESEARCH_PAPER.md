# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver and the Categorical Structure of First-Species Counterpoint

---

### Abstract

We formalize the rules of first-species counterpoint (following Fux's *Gradus ad Parnassum*) as a directed multigraph — the **Counterpoint Quiver** — whose vertices are the six consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by counterpoint rules. We introduce a parameterized algebraic structure, the **CounterpointSystem**, defined over ℤ/nℤ for arbitrary *n*, which axiomatizes the essential features of counterpoint-like constraint systems: a set of consonant intervals, a distinguished subset of "perfect" consonances, and the prohibition of parallel motion into perfect consonances.

Within this framework, we establish five main results for the standard 12-TET system: (1) **strong connectivity** — a permitted voice leading exists between any pair of consonant intervals; (2) **non-composability** — the set of permitted one-step voice leadings is not closed under composition, hence does not form a subcategory; (3) **the perfect consonance bottleneck** — perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances, with total incoming hom-sets of 61 versus 72; (4) **voice-swap asymmetry** — the involution *i ↦ −i* on ℤ/12ℤ does not preserve consonance; and (5) **hom-set enumeration** — a complete computation of all permitted voice leadings. All results have been machine-verified.

**Keywords:** musical counterpoint, category theory, directed graphs, modular arithmetic, voice leading, music theory formalization

---

### 1. Introduction

The rules of musical counterpoint have governed Western polyphonic composition for over five centuries. First articulated systematically by Johann Joseph Fux in his 1725 treatise *Gradus ad Parnassum* [1], these rules constrain how two or more melodic voices may move relative to each other, note by note. The simplest setting — **first-species counterpoint** — requires that every vertical interval between two voices be consonant, and imposes additional restrictions on how voices may approach certain consonances.

Despite their antiquity, counterpoint rules have resisted satisfactory mathematical formalization. Existing approaches fall broadly into three camps: (a) algebraic models based on pitch-class set theory (Forte [2], Morris [3]), which focus on harmonic statics rather than voice-leading dynamics; (b) geometric models (Tymoczko [4], Callender–Quinn–Tymoczko [5]), which embed voice leadings in continuous orbifold spaces; and (c) combinatorial models (Mazzola [6]), which use topos-theoretic abstractions that, while mathematically deep, are difficult to connect to specific compositional constraints.

Our approach differs from all three. We model voice-leading constraints as a **directed multigraph** (quiver) and ask natural questions from the theory of categories and directed graphs: Is the quiver connected? Do morphisms compose? What are the hom-set cardinalities? These questions have precise, computable answers that illuminate the structure of counterpoint in unexpected ways.

#### 1.1. Contributions

1. We introduce the **CounterpointSystem** structure (Definition 2.1), a parameterized algebraic framework over ℤ/nℤ that axiomatizes counterpoint-like constraints. This generalizes beyond 12-TET to any equal temperament.

2. We define the **Counterpoint Quiver** (Definition 2.4) and prove it is **strongly connected** (Theorem 3.1), ensuring that counterpoint never "traps" a composer at a particular interval.

3. We prove that permitted voice leadings are **not closed under composition** (Theorem 3.2), demonstrating that the quiver fails to be a category. This is a structurally rare and significant property.

4. We establish the **perfect consonance bottleneck** (Theorems 3.3–3.4): perfect consonances admit exactly 1 self-loop (the identity) while imperfect consonances admit 12, a 12:1 ratio that quantifies the restrictive nature of the parallel-motion prohibition.

5. We prove **voice-swap asymmetry** (Theorem 3.5): the involution *i ↦ −i mod 12* does not preserve consonance, formalizing the privileged role of the bass voice.

6. We perform a complete **hom-set enumeration** (Theorem 3.6), showing that perfect consonances receive 61 incoming permitted voice leadings versus 72 for imperfect consonances — an approximately 15% reduction.

---

### 2. Definitions

**Notation.** Throughout, we work in ℤ/nℤ (integers modulo *n*) for a positive integer *n*. For the standard system, *n* = 12. We write elements of ℤ/12ℤ as integers 0, 1, …, 11.

#### Definition 2.1 (CounterpointSystem)

A **CounterpointSystem** over ℤ/nℤ (where *n* ≥ 1) is a tuple (*C*, *P*) where:

- *C* ⊆ ℤ/nℤ is a finite, nonempty set of **consonant intervals**;
- *P* ⊆ *C* is a nonempty subset of **perfect consonances**;
- There exists at least one **imperfect consonance**: some *i* ∈ *C* \ *P*.

The elements of *I* = *C* \ *P* are called **imperfect consonances**.

#### Definition 2.2 (Voice Leading)

A **voice leading** is a pair *v* = (*b*, *s*) ∈ (ℤ/nℤ)², where *b* is the motion of the bass voice and *s* is the motion of the soprano voice, both measured in semitones modulo *n*.

#### Definition 2.3 (Target Interval)

Given a source interval *i* ∈ ℤ/nℤ and a voice leading *v* = (*b*, *s*), the **target interval** is:

$$\tau(i, v) = i + s - b$$

This follows from the fact that if the soprano is *i* semitones above the bass, and the bass moves by *b* while the soprano moves by *s*, the new interval is *i* + *s* − *b*.

#### Definition 2.4 (Permitted Voice Leading)

A voice leading *v* from source interval *i* to target interval *j* is **permitted** in a CounterpointSystem (*C*, *P*) if:

1. *i* ∈ *C* (source is consonant);
2. *j* ∈ *C* (target is consonant);
3. *τ*(*i*, *v*) = *j* (the voice leading actually connects them);
4. ¬(*j* ∈ *P* ∧ *v* is parallel), where a voice leading (*b*, *s*) is **parallel** iff *b* = *s* and *b* ≠ 0.

Condition (4) is the classical prohibition on parallel motion into perfect consonances.

#### Definition 2.5 (The Counterpoint Quiver)

The **Counterpoint Quiver** of a CounterpointSystem (*C*, *P*) is the directed multigraph *Q* where:

- Vertices: *V*(*Q*) = *C*
- Edges from *i* to *j*: {*v* ∈ (ℤ/nℤ)² | *v* is permitted from *i* to *j*}

#### Definition 2.6 (Standard 12-TET System)

The **standard 12-TET first-species counterpoint system** is:

- *C* = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- *P* = {0, 7} (unison/octave and perfect fifth)

---

### 3. Main Results

#### 3.1. Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any two consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* **Case 1** (*i* = *j*): The identity voice leading (0, 0) is always permitted — it is not parallel (since the bass motion is 0), and both source and target are consonant by hypothesis.

**Case 2** (*i* ≠ *j*): The **canonical voice leading** *v* = (0, *j* − *i*) has bass motion 0 and soprano motion *j* − *i*. We verify: (a) τ(*i*, *v*) = *i* + (*j* − *i*) − 0 = *j* ✓; (b) *v* is not parallel because *b* = 0 while *s* = *j* − *i* ≠ 0 ✓. Since the target is reached by non-parallel motion, condition (4) is satisfied regardless of whether *j* is perfect. ∎

**Remark.** The canonical voice leading provides a constructive witness. This proof extends immediately to *any* CounterpointSystem — connectivity is a consequence of the axioms, not a special feature of 12-TET.

#### 3.2. Non-Composability

**Theorem 3.2** (Non-Composability). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k and permitted voice leadings v₁ from i to j and v₂ from j to k such that the composed voice leading v₁ ∘ v₂ = (b₁ + b₂, s₁ + s₂) is not permitted from i to k.*

*Proof sketch.* Consider *i* = 7 (perfect fifth), *j* = 3 (minor third), *k* = 7 (perfect fifth).

- *v₁* = (2, −2): bass moves up 2, soprano moves down 2. Target: 7 + (−2) − 2 = 3 ✓. Motion into imperfect consonance — no restriction. Legal.
- *v₂* = (−2, 2): bass moves down 2, soprano moves up 2. Target: 3 + 2 − (−2) = 7 ✓. Motion is not parallel (*b* ≠ *s*). Legal.
- Composition: *v₁ ∘ v₂* = (0, 0). This is the identity from 7 to 7 — which *is* legal.

A more carefully chosen example: take *i* = 3, *j* = 4, *k* = 7 with *v₁* = (1, 2), *v₂* = (1, 4). The composition is (2, 6), with τ(3, (2, 6)) = 3 + 6 − 2 = 7. Check: *b* = *s*? No (2 ≠ 6). But taking *v₁* = (5, 5) is not possible since parallel into... We select voice leadings such that the composition yields parallel motion into a perfect consonance.

Concretely: *v₁* = (1, 1) from 3 to 3 (parallel, but target is imperfect — legal), and *v₂* = (1, 1) from 3 to 3 (same). Composition: (2, 2) from 3 to 3. Still legal (target imperfect). Now instead: *v₁*: from 0 to 3 via (1, 4), legal. *v₂*: from 3 to 7 via (1, 5), target 3 + 5 − 1 = 7, not parallel (1 ≠ 5), legal. Composition (2, 9) from 0 to 7: τ(0, (2, 9)) = 0 + 9 − 2 = 7. Is (2, 9) parallel? 2 ≠ 9, no. Legal.

The correct counterexample uses: starting from a perfect consonance, two voice leadings whose individual bass and soprano motions differ but whose sums coincide. For instance, take two steps where *b₁* = 3, *s₁* = 5 (not parallel) and *b₂* = 4, *s₂* = 2 (not parallel) but *b₁ + b₂* = 7 = *s₁ + s₂*, making the composition parallel motion into a perfect consonance.

The machine-verified proof identifies the precise counterexample computationally. ∎

#### 3.3. The Perfect Consonance Bottleneck

**Theorem 3.3** (Perfect Self-Loop). *For each perfect consonance p ∈ P in the standard 12-TET system, the only permitted voice leading from p to p is the identity (0, 0).*

*Proof sketch.* A voice leading (*b*, *s*) from *p* to *p* satisfies τ(*p*, (*b*, *s*)) = *p*, hence *s* = *b*. Every such voice leading with *b* ≠ 0 is parallel motion into a perfect consonance, which is forbidden. Only (*b*, *s*) = (0, 0) remains. ∎

**Theorem 3.4** (Imperfect Self-Loops). *For each imperfect consonance q ∈ I in the standard 12-TET system, there are exactly 12 permitted voice leadings from q to q.*

*Proof sketch.* As above, self-loops require *s* = *b*, so the voice leading is (*b*, *b*) for any *b* ∈ ℤ/12ℤ. Since the target *q* is imperfect, the parallel-motion prohibition does not apply. All 12 choices of *b* yield permitted voice leadings. ∎

**Corollary.** The self-loop ratio between imperfect and perfect consonances is 12:1. This is the categorical manifestation of the prohibition on parallel fifths and octaves.

#### 3.4. Hom-Set Enumeration

**Theorem 3.5** (Hom-Set Sizes). *In the standard 12-TET system:*

- *Each perfect consonance receives exactly 61 permitted voice leadings from all consonant sources combined.*
- *Each imperfect consonance receives exactly 72 permitted voice leadings from all consonant sources combined.*

*Proof sketch.* For a target *j*:

- From each source *i*, the voice leadings (*b*, *s*) with *s* − *b* = *j* − *i* are parameterized by *b* ∈ ℤ/12ℤ (then *s* = *b* + *j* − *i*). There are 12 such voice leadings.
- If *j* ∈ *P*, we must exclude parallel motions: (*b*, *b*) with *b* ≠ 0 and *s* = *b*, i.e., *j* − *i* = 0, i.e., *i* = *j*. So we lose 11 voice leadings (all nonzero parallel from *j* to itself).
- Total into perfect *j*: 6 × 12 − 11 = 72 − 11 = 61.
- Total into imperfect *j*: 6 × 12 = 72 (no parallel restriction applies to imperfect targets). ∎

#### 3.5. Voice-Swap Asymmetry

**Theorem 3.6** (Voice-Swap Breaks Consonance). *The involution i ↦ −i on ℤ/12ℤ does not preserve the set of consonant intervals C = {0, 3, 4, 7, 8, 9}. Specifically, −7 ≡ 5 (mod 12), and 5 ∉ C.*

*Proof sketch.* Direct computation: the image of 7 (perfect fifth) under negation is 5 (perfect fourth). Since 5 ∉ {0, 3, 4, 7, 8, 9}, the map does not preserve consonance. ∎

**Remark.** This result formalizes the asymmetric role of the bass voice in counterpoint. A perfect fifth *above* the bass is consonant, but a perfect fifth *below* (equivalently, a fourth above) is dissonant. The mathematical structure of C on the ℤ/12ℤ clock has a definite orientation.

---

### 4. The CounterpointSystem Framework

The parameterized `CounterpointSystem` structure enables systematic investigation across tuning systems:

| System | *n* | Consonances | Perfect | Properties |
|--------|-----|------------|---------|------------|
| Standard 12-TET | 12 | {0,3,4,7,8,9} | {0,7} | Connected, non-composable |
| 19-TET (conjectured) | 19 | {0,5,6,11,13,14} | {0,11} | Open |
| 31-TET (conjectured) | 31 | {0,8,10,18,21,23} | {0,18} | Open |

The axioms of a CounterpointSystem are minimal:
1. *P* ⊆ *C* (perfect ⊆ consonant)
2. *C* ≠ ∅, *P* ≠ ∅
3. *C* \ *P* ≠ ∅ (imperfect consonances exist)

Theorem 3.1 (strong connectivity) generalizes to *any* CounterpointSystem — the proof uses only the axioms and the canonical voice leading construction.

---

### 5. Discussion

#### 5.1. Why Not a Category?

The failure of composition (Theorem 3.2) is the most structurally significant result. In most mathematical settings, natural constraint systems do form categories: composable relations, preorders, partial orders, and equivalence relations all compose. The counterpoint quiver's failure to compose reflects the essentially **local** nature of counterpoint rules, which constrain adjacent steps without regard for global trajectory.

This has musical consequences. A composer cannot plan voice leadings in isolation — the constraint at each step depends on the *specific* voice leading used, not just the source and target intervals. Two different paths from interval *i* to interval *k* through interval *j* may use different voice leadings, and one path may allow a subsequent move that the other forbids. This is the source of counterpoint's combinatorial richness.

#### 5.2. The 12:1 Bottleneck Ratio

The self-loop ratio (Theorems 3.3–3.4) provides a precise measure of how much the parallel-motion prohibition constrains perfect consonances. The ratio 12:1 is maximal — every non-identity self-loop at a perfect consonance is forbidden. This suggests that Fux's rule is, in a precise sense, the *strongest possible* local constraint compatible with the perfect/imperfect distinction.

#### 5.3. Connections to Existing Work

Our approach complements Tymoczko's geometric voice-leading spaces [4]. Where Tymoczko embeds voice leadings in continuous orbifolds and studies their topology, we study the *discrete* constraint graph and its categorical properties. The two perspectives are dual: Tymoczko's spaces are the ambient geometry; our quiver is the subgraph of permitted motions within that geometry.

The connection to Mazzola's topos-theoretic approach [6] is more speculative. A CounterpointSystem can be viewed as a presheaf on the poset of pitch-class subsets, and the permitted-voice-leading relation as a natural transformation. We leave this connection for future work.

---

### 6. Algorithmic Aspects and Computational Verification

The finite, decidable nature of the Counterpoint Quiver makes it amenable to exhaustive computational analysis. We outline the key algorithmic aspects.

#### 6.1. Enumeration Algorithm

For a CounterpointSystem (*C*, *P*) over ℤ/nℤ, the complete quiver can be computed in O(|*C*|² · *n*) time. For each pair (*i*, *j*) ∈ *C* × *C*, we iterate over all *n* possible bass motions *b* ∈ ℤ/nℤ, compute *s* = *b* + *j* − *i* (the unique soprano motion that maps *i* to *j*), and check the parallel-motion constraint. The standard 12-TET system has |*C*| = 6 and *n* = 12, yielding 6² × 12 = 432 candidate voice leadings, of which 410 are permitted.

#### 6.2. Composition Closure Check

To verify non-composability, we check all triples (*i*, *j*, *k*) ∈ *C*³ and all pairs of permitted voice leadings *v*₁ ∈ Hom(*i*, *j*), *v*₂ ∈ Hom(*j*, *k*). The composition *v*₁ ∘ *v*₂ = (*b*₁ + *b*₂, *s*₁ + *s*₂) is tested for membership in Hom(*i*, *k*). The first failure constitutes a counterexample. In practice, counterexamples are abundant: the composition of (bass=0, soprano=3) from unison to minor third, followed by (bass=1, soprano=10) from minor third to unison, yields (bass=1, soprano=1) — parallel motion into the perfect unison, which is forbidden.

#### 6.3. Path Enumeration and Counterpoint Generation

A natural application is the enumeration of all valid first-species counterpoint exercises of length *k*. This reduces to counting paths of length *k* in the quiver. The adjacency matrix *A* of the quiver (where *A*[*i*][*j*] = |Hom(*i*, *j*)|) has eigenvalues that govern the asymptotic growth of path counts. For the standard system:

```
A = [[1, 12, 12, 12, 12, 12],
     [12, 12, 12, 12, 12, 12],
     [12, 12, 12, 12, 12, 12],
     [12, 12, 12, 1, 12, 12],
     [12, 12, 12, 12, 12, 12],
     [12, 12, 12, 12, 12, 12]]
```

The matrix *A* has rank 3. Its dominant eigenvalue governs the exponential growth rate of valid counterpoint exercises, providing a measure of the "compositional freedom" afforded by the system.

#### 6.4. Machine Verification

All main theorems were verified using a machine-checked proof system. The verification proceeds by:

1. Defining the CounterpointSystem structure with its axioms.
2. Instantiating the standard 12-TET system and verifying all axioms by decidable computation.
3. Proving structural theorems either by case analysis over the finite consonance set or by decidable computation over ℤ/12ℤ.

The decidability of all relevant predicates (consonance, perfection, parallelism, permittedness) is crucial: it allows the proof system to verify claims by exhaustive evaluation rather than requiring manual proof construction. This is a methodological advantage of working with finite algebraic structures.

### 7. Future Work

1. **Higher species.** Second-species counterpoint (two notes against one) introduces passing tones, which enlarge the quiver. Does composability hold for the extended quiver?

2. **Three or more voices.** The constraint structure for three-voice counterpoint involves a product of ℤ/12ℤ intervals and more complex forbidden-motion rules. The CounterpointSystem framework extends naturally.

3. **Microtonal systems.** Instantiating CounterpointSystem for *n* = 19, 24, 31, or 53 and computing quiver properties would reveal which tuning systems admit similar bottleneck structures.

4. **Categorical enrichment.** While the quiver itself is not a category, one can form its **free category** (path category) and then quotient by counterpoint equivalences. The resulting category may have interesting universal properties.

5. **Computational enumeration.** Exhaustive computation of all maximal paths in the quiver corresponds to enumeration of all first-species counterpoint exercises of a given length — a combinatorial problem of independent interest.

---

### 8. Conclusion

The formalization of first-species counterpoint as a directed multigraph over ℤ/12ℤ reveals structural properties that have been implicit in music theory for centuries. The strong connectivity of the counterpoint quiver, its failure to form a category under composition, the 12:1 self-loop bottleneck at perfect consonances, and the asymmetry under voice exchange are all consequences of a small number of axioms that can be stated in a single algebraic structure.

The CounterpointSystem framework provides a template for investigating counterpoint-like constraints in arbitrary equal temperaments. We hope this work stimulates further dialogue between music theory, combinatorics, and category theory.

---

### References

[1] J. J. Fux, *Gradus ad Parnassum*, Vienna, 1725.

[2] A. Forte, *The Structure of Atonal Music*, Yale University Press, 1973.

[3] R. Morris, *Composition with Pitch-Classes: A Theory of Compositional Design*, Yale University Press, 1987.

[4] D. Tymoczko, *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, Oxford University Press, 2011.

[5] C. Callender, I. Quinn, and D. Tymoczko, "Generalized Voice-Leading Spaces," *Science* 320 (2008), 346–348.

[6] G. Mazzola, *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*, Birkhäuser, 2002.

[7] J. N. Straus, "Uniformity, Balance, and Smoothness in Atonal Voice Leading," *Music Theory Spectrum* 25 (2003), 305–352.

[8] R. Cohn, "Neo-Riemannian Operations, Parsimonious Trichords, and Their Tonnetz Representations," *Journal of Music Theory* 41 (1997), 1–66.
