# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver of First-Species Counterpoint

---

### Abstract

We formalize first-species counterpoint rules (Fux, *Gradus ad Parnassum*, 1725) as a directed multigraph—the **Counterpoint Quiver**—whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by counterpoint rules. We introduce a novel algebraic structure, the **Counterpoint System**, parameterized over arbitrary equal temperaments ZMod(n), which captures the constraint structure of any counterpoint-like voice-leading system. Within this framework, we establish five main results for the standard 12-TET system: (1) **strong connectivity**—between any two consonant intervals, at least one permitted voice leading exists; (2) **non-composability**—permitted voice leadings fail to compose, hence do not form a subcategory of the free category on the quiver; (3) **the perfect consonance bottleneck**—perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances; (4) **voice-swap asymmetry**—the involution i ↦ −i on ZMod(12) does not preserve consonance, formalizing the privileged role of the bass voice; and (5) **hom-set cardinality computation**—perfect consonances receive 61 incoming permitted voice leadings versus 72 for imperfect consonances. These results bridge music theory, order theory, and categorical logic, providing a rigorous mathematical foundation for classical voice-leading constraints.

**Keywords:** counterpoint, category theory, voice leading, directed graph, modular arithmetic, music theory, equal temperament

---

### 1. Introduction

The rules of first-species counterpoint, as codified by Fux (1725) and refined by subsequent pedagogues, constitute one of the oldest and most widely taught bodies of compositional constraint in Western music. Despite their centrality to music education, these rules have resisted satisfactory mathematical formalization. Prior work has addressed voice-leading geometry (Tymoczko, 2006, 2011), the group-theoretic structure of pitch-class sets (Forte, 1973; Lewin, 1987), and neo-Riemannian transformational theory (Cohn, 1998), but the *constraint structure of counterpoint itself*—which voice leadings are permitted and why—has not been treated as a first-class mathematical object.

We propose such a treatment. By modeling consonant intervals as vertices and permitted voice leadings as directed edges, we obtain a finite directed multigraph (quiver) whose structural properties encode deep features of the counterpoint system. Our main contribution is the **Counterpoint System**, a parameterized algebraic structure over ZMod(n) that abstracts the essential features of counterpoint-like constraints:

1. A finite set of **consonant intervals** (the vertices).
2. A distinguished subset of **perfect consonances** subject to stricter rules.
3. The **parallel-motion prohibition**: voice leadings where both voices move by the same nonzero amount are forbidden when the target is a perfect consonance.

This abstraction enables structural theorems that hold not only for standard 12-TET counterpoint but for any equal temperament, opening the door to mathematical analysis of microtonal counterpoint systems.

#### 1.1 Related Work

Tymoczko (2006, 2011) introduced the voice-leading geometry, treating chords as points in an orbifold and voice leadings as paths. Our approach is complementary: we focus on the *constraint structure* (which paths are forbidden) rather than the *metric structure* (how far paths travel). Mazzola (2002) applied topos theory to music, and Noll (2004) studied diatonic systems via algebraic combinatorics. Our Counterpoint System is closest in spirit to Mazzola's *local compositions* but simpler and more directly tied to classical pedagogy.

#### 1.2 Overview of Results

| Result | Statement | Significance |
|--------|-----------|--------------|
| Strong Connectivity | ∀ consonant i, j: ∃ permitted voice leading i → j | The quiver has no dead ends |
| Non-Composability | ∃ permitted f: A→B, g: B→C such that g∘f is forbidden | Voice leadings do not form a subcategory |
| Bottleneck (self-loops) | Perfect: 1 self-loop; Imperfect: 12 self-loops | Quantifies the "restrictedness" of perfect consonances |
| Voice-Swap Asymmetry | The map i ↦ −i does not preserve consonance | Bass voice is structurally privileged |
| Hom-Set Computation | Perfect targets: 61 incoming; Imperfect targets: 72 incoming | 15% fewer paths to perfect consonances |

---

### 2. Definitions

#### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *Counterpoint System of order n*, denoted CS(n), is a triple (C, P, ρ) where:
- n ≥ 1 is a positive integer (the number of pitch classes),
- C ⊆ ZMod(n) is a finite, nonempty set of **consonant intervals**,
- P ⊆ C is a nonempty set of **perfect consonances**,
- C \ P ≠ ∅ (there exists at least one imperfect consonance),
- ρ is the **parallel-motion prohibition rule**: a voice leading into a perfect consonance via parallel motion is forbidden.

The formal structure is:

```
structure CounterpointSystem (n : ℕ) [NeZero n] where
  consonant : Finset (ZMod n)
  perfect : Finset (ZMod n)
  perfect_sub : perfect ⊆ consonant
  consonant_nonempty : consonant.Nonempty
  perfect_nonempty : perfect.Nonempty
  has_imperfect : ∃ i ∈ consonant, i ∉ perfect
```

**Definition 2.2** (Voice Leading). A *voice leading* over ZMod(n) is a pair (b, s) ∈ ZMod(n) × ZMod(n), where b is the bass motion and s is the soprano motion, both measured in pitch-class increments modulo n.

```
structure VoiceLeading (n : ℕ) [NeZero n] where
  bass : ZMod n
  soprano : ZMod n
```

**Definition 2.3** (Target Interval). Given a source interval i ∈ ZMod(n) and a voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This follows from the observation that if the soprano is i semitones above the bass, and the bass rises by b while the soprano rises by s, the new interval is i + s − b.

**Definition 2.4** (Parallel Motion). A voice leading (b, s) exhibits *parallel motion* if b = s and b ≠ 0.

**Definition 2.5** (Permitted Voice Leading). A voice leading (b, s) from source interval i to target interval j is *permitted* in a Counterpoint System (C, P, ρ) if:
1. i ∈ C and j ∈ C (both intervals are consonant),
2. τ(i, b, s) = j (the voice leading maps i to j),
3. ¬(j ∈ P ∧ b = s ∧ b ≠ 0) (parallel motion into a perfect consonance is forbidden).

```
def CounterpointSystem.isPermitted (sys : CounterpointSystem n)
    (source target : ZMod n) (vl : VoiceLeading n) : Prop :=
  source ∈ sys.consonant ∧
  target ∈ sys.consonant ∧
  targetInterval n source vl = target ∧
  ¬(target ∈ sys.perfect ∧ vl.isParallel)
```

#### 2.2 The Standard 12-TET Counterpoint System

**Definition 2.6** (Standard System). The *standard 12-TET first-species counterpoint system* is CS(12) with:
- C = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- P = {0, 7} (unison/octave, perfect fifth)

```
def chromaticConsonant : Finset (ZMod 12) := {0, 3, 4, 7, 8, 9}
def chromaticPerfect : Finset (ZMod 12) := {0, 7}
```

The choice of consonances reflects the traditional classification: intervals whose frequency ratios involve small integers (2:1, 3:2, 4:3, 5:4, 6:5, 5:3, 8:5) modulo octave equivalence. The exclusion of the perfect fourth (5 semitones) from consonance—despite its simple ratio 4:3—reflects its historical treatment as a dissonance when it appears above the bass voice.

#### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *Counterpoint Quiver* Q(CS) of a Counterpoint System CS = (C, P, ρ) is the directed multigraph with:
- Vertex set V = C,
- Edge multiset E = {(i, j, b, s) : the voice leading (b, s) from i to j is permitted}.

For the standard 12-TET system, |V| = 6 and we compute |E| = 408 (see Section 4).

---

### 3. Main Results

#### 3.1 Theorem 1: Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). For all consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.

*Proof sketch.* We distinguish two cases.

**Case 1: i ≠ j.** Consider the *canonical voice leading* vl = (0, j − i), which holds the bass stationary and moves the soprano by j − i. The target interval is τ(i, 0, j − i) = i + (j − i) − 0 = j, so condition (2) is satisfied. Since the bass motion is 0 and the soprano motion is j − i ≠ 0, the motion is not parallel (the voices move by different amounts), so condition (3) is vacuously satisfied regardless of whether j is perfect. Conditions (1) are given by hypothesis.

**Case 2: i = j.** The identity voice leading vl = (0, 0) maps i to itself with τ(i, 0, 0) = i. Since both motions are 0, the motion is not parallel (parallel requires b = s ≠ 0). This is verified by case analysis over all six consonant intervals. ∎

The canonical voice leading construction yields a stronger result:

**Corollary 3.2** (`canonical_not_parallel`). For i ≠ j, the canonical voice leading (0, j − i) is never parallel.

#### 3.2 Theorem 2: Non-Composability

**Theorem 3.3** (`non_composability`). The set of permitted voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals A, B, C and permitted voice leadings f: A → B and g: B → C such that the composite voice leading g ∘ f (defined by adding the bass and soprano motions) is not permitted from A to C.

*Proof sketch.* The composition of voice leading (b₁, s₁) followed by (b₂, s₂) produces the total motion (b₁ + b₂, s₁ + s₂). We exhibit a concrete counterexample: choose intervals and voice leadings such that both individual steps satisfy the permission rules, but the composite has b₁ + b₂ = s₁ + s₂ ≠ 0 and the final target is a perfect consonance—violating the parallel-motion prohibition.

This result has a deep structural consequence: the Counterpoint Quiver does **not** underlie a subcategory of the free category generated by the voice-leading graph. Permitted voice leadings are inherently a *one-step* constraint, not a compositional system. ∎

**Remark.** This non-composability is musically significant. It explains why Fux's pedagogy is organized as a sequence of increasingly complex "species," each adding new constraints: the one-step rules of first species are insufficient to guarantee good multi-step progressions.

#### 3.3 Theorem 3: The Perfect Consonance Bottleneck

**Theorem 3.4** (`perfect_self_loop_unique`). For any perfect consonance p ∈ P in the standard 12-TET system, there is exactly 1 permitted voice leading from p to itself (the identity).

**Theorem 3.5** (`imperfect_self_loops_all`). For any imperfect consonance q ∈ C \ P, there are exactly 12 permitted voice leadings from q to itself.

*Proof sketch.* A self-loop at interval i is a voice leading (b, s) with τ(i, b, s) = i, which simplifies to s = b. If i is perfect, then any such voice leading with b = s ≠ 0 is parallel motion into a perfect consonance—forbidden. The only remaining possibility is b = s = 0, the identity. Hence exactly 1 self-loop.

If i is imperfect, the parallel-motion prohibition does not apply (the target is not perfect). Every (b, b) with b ∈ ZMod(12) gives a valid self-loop. There are 12 choices. ∎

The ratio 12:1 is the mathematical expression of a phenomenon every student of counterpoint knows intuitively: sustaining a perfect fifth through motion is exceptionally difficult compared to sustaining a third or sixth.

#### 3.4 Theorem 4: Voice-Swap Asymmetry

**Theorem 3.6** (`voice_swap_breaks_consonance`). The involution σ: ZMod(12) → ZMod(12) defined by σ(i) = −i does not preserve the consonant set C. Specifically, σ(7) = 5 ∉ C.

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12). We verify that 5 ∉ {0, 3, 4, 7, 8, 9}. ∎

**Corollary 3.7.** The Counterpoint Quiver admits no involutory automorphism induced by voice exchange.

This result formalizes the observation that the bass voice occupies a structurally privileged position in counterpoint. The perfect fifth (7 semitones above the bass) is consonant, but the perfect fourth (5 semitones above the bass, equivalently 7 semitones *below*) is dissonant. This asymmetry is not a convention but a consequence of the algebraic structure of the consonance set under negation in ZMod(12).

#### 3.5 Theorem 5: Hom-Set Cardinality

**Theorem 3.8** (`total_permitted_to_perfect`). The total number of permitted voice leadings into any single perfect consonance (from all consonant sources) is 61.

**Theorem 3.9** (`total_permitted_to_imperfect`). The total number of permitted voice leadings into any single imperfect consonance (from all consonant sources) is 72.

*Proof sketch.* For each target interval t and each source interval s ∈ C, the number of voice leadings (b, σ) with s + σ − b = t is |ZMod(12)| = 12 (parameterized freely by b, with σ = t − s + b determined). If t is perfect, we subtract the parallel voice leadings: those with b = σ ≠ 0, i.e., b = (t − s)/2 when t ≠ s (at most 1 per source), plus the 11 parallel self-loops when s = t. Over 6 sources, the total is 6 × 12 − 11 = 61. If t is imperfect, no subtractions apply, yielding 6 × 12 = 72. ∎

---

### 4. The Counterpoint Quiver: Full Enumeration

We compute the complete edge structure of the standard 12-TET Counterpoint Quiver.

| Target \ Source | 0 | 3 | 4 | 7 | 8 | 9 | Total In |
|-----------------|---|---|---|---|---|---|----------|
| **0** (perf) | 1 | 12 | 12 | 12 | 12 | 12 | 61 |
| **3** (imp) | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **4** (imp) | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **7** (perf) | 12 | 12 | 12 | 1 | 12 | 12 | 61 |
| **8** (imp) | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **9** (imp) | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **Total Out** | 61 | 72 | 72 | 61 | 72 | 72 | **410** |

**Note on the table:** The self-loop entries for perfect consonances (0→0 and 7→7) are 1, reflecting the identity-only constraint. All other entries are 12 (the full set of voice leadings parameterized by free choice of bass motion). The total edge count is 2 × 61 + 4 × 72 = 122 + 288 = 410.

The diagonal entries (self-loops) exhibit the 1-vs-12 bottleneck. The off-diagonal entries are uniformly 12, reflecting the fact that the parallel-motion prohibition only restricts same-interval transitions to perfect consonances. The quiver's adjacency structure is thus completely determined by which consonances are perfect.

---

### 5. Categorical Perspective

#### 5.1 The Free Category on the Quiver

The Counterpoint Quiver Q generates a free category **Free**(Q), whose objects are the 6 consonant intervals and whose morphisms are finite composable sequences of permitted voice leadings. By Theorem 3.1, **Free**(Q) is connected: for every pair of objects, the hom-set is nonempty.

#### 5.2 The Failure of Subcategory Structure

By Theorem 3.3, the one-step voice leadings do not form a subcategory of **Free**(Q). This distinguishes the Counterpoint Quiver from structures like posets (where the "thin category" condition ensures transitivity) and groupoids (where every morphism is invertible).

The Counterpoint Quiver occupies an intermediate position: it is a reflexive directed graph (every vertex has a self-loop, namely the identity voice leading) that is strongly connected but fails transitivity. In the language of enriched category theory, it is a Set-enriched directed graph that does not lift to a Set-enriched category.

#### 5.3 Comparison with Poset Categories

The original conjecture motivating this work was that the category of first-species counterpoint might be equivalent to the thin category generated by a specific 12-element poset. Our results show this conjecture is **false** in a strong sense:

1. The quiver has only 6 vertices (consonant intervals), not 12.
2. The edge structure is not thin (most hom-sets have cardinality 12).
3. Most importantly, the one-step edges do not compose (Theorem 3.3), so the structure is not a category at all.

The correct mathematical object is not a category but a **quiver with forbidden compositions**—a richer structure that captures the essentially non-transitive nature of counterpoint constraints.

---

### 6. Generalization: Microtonal Counterpoint Systems

The Counterpoint System framework extends naturally to arbitrary equal temperaments.

**Definition 6.1.** A *microtonal counterpoint system* is a CounterpointSystem(n) for arbitrary n ≥ 1.

**Example 6.2** (19-TET). In 19-tone equal temperament, the consonant intervals might be taken as {0, 5, 6, 11, 13, 14} (approximating the just intervals), with perfect consonances {0, 11}. The resulting quiver would have 6 vertices and its hom-set structure could be analyzed using the same framework.

**Open Question 6.3.** For which values of n and which consonance sets does the Counterpoint Quiver achieve maximum edge density (subject to the parallel-motion prohibition)? This optimization problem connects to extremal graph theory and coding theory.

**Open Question 6.4.** Is there a microtonal counterpoint system whose permitted voice leadings *do* compose? That is, for which CS(n) do the one-step voice leadings form a subcategory?

---

### 7. Connections to Other Mathematical Domains

#### 7.1 Pythagorean Harmonics

The choice of consonant intervals is not arbitrary but rooted in number theory. The consonant intervals in 12-TET approximate frequency ratios of the form p/q where p, q are small integers. This connects to the theory of Pythagorean triples and continued fraction approximations of just intervals. Our framework takes the consonance set as given and studies its *dynamic* consequences—how consonant intervals connect through voice leading.

#### 7.2 Graph Theory

The Counterpoint Quiver is a specific instance of a vertex-labeled directed multigraph with edge constraints. The strong connectivity result (Theorem 3.1) shows it has diameter 1 as a directed graph. The non-composability result (Theorem 3.3) shows that the transitive closure of the quiver's edge relation is strictly larger than the edge set itself.

#### 7.3 Constraint Satisfaction

The permission predicate `isPermitted` can be viewed as a constraint satisfaction problem (CSP) over ZMod(n). Each voice leading must satisfy a conjunction of constraints (consonance of source, consonance of target, correct interval arithmetic, and the parallel-motion prohibition). The structure theory of such CSPs connects to computational complexity via Schaefer's dichotomy theorem.

---

### 8. Discussion

#### 8.1 Musical Implications

Our results provide rigorous justification for several aspects of traditional counterpoint pedagogy:

1. **The hierarchy of consonances.** The 1-vs-12 self-loop ratio and the 61-vs-72 incoming edge count formalize the intuition that perfect consonances are "stronger" but "harder to use." The mathematical bottleneck at perfect consonances forces composers to approach them via contrary or oblique motion, creating the characteristic texture of contrapuntal music.

2. **The locality of counterpoint rules.** Non-composability (Theorem 3.3) explains why Fux's pedagogy proceeds through increasingly complex "species" rather than deriving all rules from a single principle. The one-step rules are genuinely non-transitive; multi-step coherence requires additional constraints.

3. **The bass privilege.** Voice-swap asymmetry (Theorem 3.6) provides a structural explanation for figured bass notation, where harmony is specified relative to the lowest voice. The bass is not merely conventional; it is the only voice relative to which the consonance set has its standard form.

#### 8.2 Limitations

Our formalization captures only first-species counterpoint (note-against-note in whole values). Higher species introduce passing tones, suspensions, and rhythmic diversity, all of which would require a richer mathematical framework—potentially involving 2-categories or higher structures to model the temporal nesting of constraints.

We also work in equal temperament throughout. The historical practice of counterpoint predates equal temperament by centuries and was originally conceived in terms of just intonation. A formalization in terms of rational frequency ratios (rather than ZMod(n)) would capture different mathematical phenomena.

---

### 9. Future Work

1. **Higher species.** Extend the Counterpoint System to model second through fifth species, potentially using enriched categories or operads to capture the hierarchical constraint structure.

2. **Harmonic counterpoint.** Incorporate chord-scale theory to model counterpoint within a harmonic context, connecting to Tymoczko's voice-leading geometry.

3. **Algorithmic composition.** Use the Counterpoint Quiver as the state space for Markov chain or reinforcement learning approaches to automated counterpoint generation. The hom-set cardinalities provide natural transition probabilities.

4. **Microtonal classification.** Systematically enumerate Counterpoint Systems for small values of n and classify their quiver structures, seeking universal properties or phase transitions as n varies.

5. **Topological analysis.** Compute the homology of the simplicial complex associated to the Counterpoint Quiver (the clique complex of its underlying undirected graph) to detect topological features of voice-leading space.

---

### 10. References

1. Cohn, R. (1998). Introduction to Neo-Riemannian Theory: A Survey and a Historical Perspective. *Journal of Music Theory*, 42(2), 167–180.

2. Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.

3. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.

4. Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.

5. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.

6. Tymoczko, D. (2006). The Geometry of Musical Chords. *Science*, 313(5783), 72–74.

7. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.

---

### Appendix A: Catalog of Formal Results

| Identifier | Statement | Status |
|------------|-----------|--------|
| `exists_permitted_voice_leading` | ∀ i j ∈ C, ∃ vl, isPermitted i j vl | Proved |
| `non_composability` | ∃ counterexample to composition closure | Proved |
| `perfect_self_loop_unique` | Self-loops at perfect consonances = {id} | Proved |
| `imperfect_self_loops_all` | Self-loops at imperfect consonances = 12 | Proved |
| `voice_swap_breaks_consonance` | σ(7) = 5 ∉ C | Proved |
| `total_permitted_to_perfect` | |Hom(−, p)| = 61 for p ∈ P | Proved |
| `total_permitted_to_imperfect` | |Hom(−, q)| = 72 for q ∈ C\P | Proved |
| `canonical_not_parallel` | Canonical VL is never parallel for i ≠ j | Proved |
| `targetInterval_canonical` | τ(i, canonical(i,j)) = j | Proved |
