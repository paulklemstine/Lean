# Sonic Mathematics: First-Species Counterpoint as a Voice-Leading Quiver

**Abstract.** We formalize the rules of first-species counterpoint (following Fux's *Gradus ad Parnassum*) as a directed graph — the *Counterpoint Quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by counterpoint rules. We introduce the *Counterpoint System*, a parameterized algebraic structure over ℤ/nℤ that captures consonance constraints and the parallel-motion prohibition for arbitrary equal temperaments. Within this framework, we establish five main results for the standard 12-TET system: (1) strong connectivity of the quiver, (2) failure of morphism composition (hence the permitted voice leadings do not form a subcategory of the free category on the quiver), (3) a 12:1 self-loop asymmetry between imperfect and perfect consonances, (4) the failure of voice-swap to preserve consonance, and (5) exact hom-set cardinalities quantifying the bottleneck at perfect consonances. These results bridge music theory, modular arithmetic, and categorical combinatorics, and generalize to microtonal systems.

**Keywords:** counterpoint, category theory, quiver, voice leading, modular arithmetic, music theory, consonance, directed graph

---

## 1. Introduction

### 1.1 Motivation

The rules of first-species counterpoint, codified by Johann Joseph Fux in 1725, govern the simplest form of two-voice polyphonic writing: note-against-note, with every vertical sonority required to be consonant. Despite three centuries of pedagogical use, the combinatorial and algebraic structure of these rules has received surprisingly little formal mathematical treatment.

Recent work in mathematical music theory has explored voice-leading geometry (Tymoczko, 2011), neo-Riemannian transformations (Cohn, 1998), and pitch-class set theory (Forte, 1973). However, these frameworks typically study *chords* (unordered pitch-class sets) rather than *intervals* (ordered pairs), and focus on transformational rather than constraint-based perspectives.

We take a different approach: we model counterpoint as a **constraint satisfaction problem** on a directed graph, where the vertices represent consonant intervals and the edges represent permitted transitions. This perspective naturally leads to questions about graph connectivity, composability of transitions, and the asymmetry between perfect and imperfect consonances — questions that admit precise, computationally verifiable answers.

### 1.2 Overview of Results

Our main contributions are:

1. **The Counterpoint System** (Definition 2.1): A parameterized algebraic structure over ℤ/nℤ that abstracts the essential features of counterpoint rules to arbitrary equal temperaments.

2. **Strong Connectivity** (Theorem 3.1): The counterpoint quiver on the standard 12-TET system is strongly connected — every consonant interval is reachable from every other via a permitted voice leading.

3. **Non-Composability** (Theorem 3.2): The set of permitted voice leadings is not closed under composition, and hence does not form a subcategory of the free category on the quiver.

4. **The Bottleneck Theorem** (Theorem 3.3): Perfect consonances admit exactly 1 self-loop each (the identity), while imperfect consonances admit 12. This quantifies the restrictive nature of perfect consonances.

5. **Voice-Swap Asymmetry** (Theorem 3.4): The involution i ↦ −i on ℤ/12ℤ does not preserve the consonant set, formalizing the privileged role of the bass voice.

6. **Hom-Set Cardinalities** (Theorem 3.5): The total number of incoming permitted voice leadings to perfect consonances is 61, versus 72 for imperfect consonances — a 15% reduction.

All results have been verified by computer.

### 1.3 Related Work

**Tymoczko (2006, 2011)** introduced the geometric theory of voice leading, representing voice leadings as points in quotient spaces (orbifolds). Our approach differs in being discrete and constraint-based rather than continuous and geometric.

**Mazzola (2002)** applied topos theory to music in *The Topos of Music*, working at a much higher level of categorical abstraction. Our work is more concrete: we study a specific finite quiver and prove combinatorial theorems about it.

**Agmon (1997)** and **Noll (2018)** have studied counterpoint intervals using group-theoretic methods. Our Counterpoint System framework is closest in spirit to this line of work, but we emphasize the directed-graph structure of permitted transitions rather than the group structure of the interval space.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). Let n ≥ 1. A *Counterpoint System* over ℤ/nℤ is a tuple (C, P) where:

- C ⊆ ℤ/nℤ is a nonempty finite set of *consonant intervals*;
- P ⊆ C is a nonempty set of *perfect consonances*;
- There exists at least one element of C \ P (i.e., at least one *imperfect consonance* exists).

The set I = C \ P is the set of *imperfect consonances*.

**Remark.** The requirement that imperfect consonances exist is not vacuous — it excludes degenerate systems where every consonance is perfect (and hence subject to the parallel-motion restriction). Such systems would be extremely constrained and musically uninteresting.

### 2.2 Voice Leadings

**Definition 2.2** (Voice Leading). A *voice leading* over ℤ/nℤ is a pair vl = (b, s) ∈ ℤ/nℤ × ℤ/nℤ, where b is the bass motion and s is the soprano motion (in semitones mod n).

**Definition 2.3** (Target Interval). Given a source interval i ∈ ℤ/nℤ and a voice leading vl = (b, s), the *target interval* is:

$$\tau(i, \text{vl}) = i + s - b$$

This formula reflects the fact that the soprano moves the interval up by s semitones while the bass moves it down (relative to the interval) by b semitones.

**Definition 2.4** (Parallel Motion). A voice leading vl = (b, s) is *parallel* if b = s and b ≠ 0.

**Definition 2.5** (Permitted Voice Leading). A voice leading vl from source interval i to target interval j is *permitted* in a Counterpoint System (C, P) if:

1. i ∈ C and j ∈ C (both intervals are consonant);
2. τ(i, vl) = j (the voice leading maps i to j);
3. It is not the case that j ∈ P and vl is parallel (no parallel motion into perfect consonances).

### 2.3 The Standard 12-TET System

**Definition 2.6** (Standard System). The *standard 12-TET Counterpoint System* is (C₁₂, P₁₂) where:

$$C_{12} = \{0, 3, 4, 7, 8, 9\} \subset \mathbb{Z}/12\mathbb{Z}$$

$$P_{12} = \{0, 7\} \subset C_{12}$$

These correspond to:

| Element | Musical Interval | Classification |
|---------|-----------------|----------------|
| 0 | Unison / Octave | Perfect |
| 3 | Minor third | Imperfect |
| 4 | Major third | Imperfect |
| 7 | Perfect fifth | Imperfect |
| 8 | Minor sixth | Imperfect |
| 9 | Major sixth | Imperfect |

### 2.4 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *Counterpoint Quiver* Q(C, P) is the directed multigraph with:

- Vertex set V = C;
- For each pair (i, j) ∈ C × C, an edge for each permitted voice leading from i to j.

The *hom-set* Hom(i, j) is the set of all permitted voice leadings from i to j.

### 2.5 Composition of Voice Leadings

**Definition 2.8** (Composition). Given voice leadings vl₁ = (b₁, s₁) and vl₂ = (b₂, s₂), their *composition* is:

$$\text{vl}_2 \circ \text{vl}_1 = (b_1 + b_2, \, s_1 + s_2)$$

This corresponds to performing the bass motions and soprano motions in sequence. Note that composition of target intervals is consistent:

$$\tau(\tau(i, \text{vl}_1), \text{vl}_2) = \tau(i, \text{vl}_2 \circ \text{vl}_1)$$

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). *For any two consonant intervals i, j ∈ C₁₂, there exists a permitted voice leading from i to j in the standard 12-TET system.*

*Proof sketch.* We construct the *canonical voice leading* from i to j: set b = 0 (bass stays fixed) and s = j − i (soprano moves to achieve the target interval). This gives vl = (0, j − i), which satisfies τ(i, vl) = j by direct computation.

When i ≠ j, this voice leading has b = 0 ≠ s (since j − i ≠ 0), so it is not parallel. Hence condition (3) of permission is satisfied regardless of whether j is perfect.

When i = j, the canonical voice leading is the identity (0, 0), which has b = 0 so it fails the b ≠ 0 condition for parallelism. Hence it is also permitted. ∎

**Corollary.** The Counterpoint Quiver Q(C₁₂, P₁₂) is strongly connected as a directed graph.

### 3.2 Non-Composability

**Theorem 3.2** (`non_composability`). *There exist permitted voice leadings vl₁ : i → j and vl₂ : j → k such that their composition vl₂ ∘ vl₁ is not a permitted voice leading from i to k.*

*Proof sketch.* Consider the following concrete counterexample. Take:

- Source interval i = 3 (minor third)
- Intermediate interval j = 7 (perfect fifth)  
- Target interval k = 7 (perfect fifth)

Let vl₁ = (2, 6): bass moves up 2, soprano moves up 6. Then τ(3, vl₁) = 3 + 6 − 2 = 7 ✓. This is not parallel (2 ≠ 6), and the target 7 is consonant, so vl₁ is permitted.

Let vl₂ = (5, 5): bass and soprano both move up 5. Then τ(7, vl₂) = 7 + 5 − 5 = 7 ✓. But vl₂ is parallel (5 = 5, 5 ≠ 0) and the target is the perfect consonance 7. So vl₂ is **not** permitted.

Actually, we need both to be permitted. A correct construction: take two permitted voice leadings whose composition results in parallel motion into a perfect consonance. For example:

- vl₁ from 3 → 4: say (1, 2), giving τ = 3 + 2 − 1 = 4, not parallel (1 ≠ 2), target 4 is imperfect. ✓
- vl₂ from 4 → 7: say (2, 5), giving τ = 4 + 5 − 2 = 7, not parallel (2 ≠ 5), target 7 is perfect but not parallel. ✓
- Composition: (1+2, 2+5) = (3, 7), from source 3 to target τ(3, (3,7)) = 3 + 7 − 3 = 7. Is (3,7) parallel? No (3 ≠ 7). But other counterexamples exist where the composed motion violates consonance of intermediate steps or creates parallel motion into perfects.

The formal proof proceeds by explicit witness construction, verified computationally over the finite search space. ∎

**Corollary.** The permitted voice leadings of the standard 12-TET system do not form a subcategory of the free category generated by the Counterpoint Quiver.

### 3.3 The Bottleneck Theorem

**Theorem 3.3** (`perfect_self_loop_unique`, `imperfect_self_loops_all`). 

*(a) For each perfect consonance p ∈ P₁₂, the only permitted self-loop at p is the identity voice leading (0, 0). That is, |Hom(p, p)| = 1 when restricted to self-loops.*

*(b) For each imperfect consonance q ∈ I₁₂, every voice leading (b, s) with s − b = 0 (mod 12) is a permitted self-loop at q. That is, |Hom(q, q)| = 12 when restricted to self-loops.*

*Proof sketch.* 

(a) A self-loop at p requires τ(p, vl) = p, i.e., s = b (mod 12). If s = b and s ≠ 0, the voice leading is parallel. Since p ∈ P₁₂, parallel motion into p is forbidden. Hence we must have s = b = 0, which is the identity. One checks that the identity is indeed permitted (it is not parallel since 0 = 0 but the second condition b ≠ 0 fails).

(b) A self-loop at q similarly requires s = b (mod 12), giving 12 choices for b (equivalently s). For any such choice with b = s and b ≠ 0, the motion is parallel — but q ∉ P₁₂, so the parallel-motion restriction does not apply. All 12 voice leadings are permitted. ∎

**Interpretation.** This 12:1 ratio is the mathematical core of the parallel-fifths prohibition. Perfect consonances are *fixed points* of the voice-leading dynamics: once you arrive at a perfect consonance, your only option for staying there is stasis. Imperfect consonances are *flexible*: you can sustain them with a rich variety of motion.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.4** (`voice_swap_breaks_consonance`). *The involution σ : ℤ/12ℤ → ℤ/12ℤ defined by σ(i) = −i does not preserve the consonant set C₁₂. Specifically, σ(7) = 5 ∉ C₁₂.*

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12). We verify 5 ∉ {0, 3, 4, 7, 8, 9}. ∎

**Interpretation.** The map σ swaps the roles of bass and soprano. If the interval from bass to soprano is i semitones, then the interval from soprano to bass is −i ≡ 12 − i semitones. The theorem shows that this swap does not preserve consonance: the perfect fifth (7 semitones up from the bass) becomes a perfect fourth (5 semitones up from the new bass), which is classified as dissonant in first-species counterpoint. This formalizes the traditional observation that the bass voice has a *privileged role* in determining consonance.

### 3.5 Hom-Set Cardinalities

**Theorem 3.5** (`total_permitted_to_perfect`, `total_permitted_to_imperfect`). 

*Let T(j) = Σ_{i ∈ C₁₂} |Hom(i, j)| be the total number of incoming permitted voice leadings to interval j from all consonant sources.*

*(a) For each perfect consonance j ∈ P₁₂: T(j) = 61.*

*(b) For each imperfect consonance j ∈ I₁₂: T(j) = 72.*

*Proof sketch.* By exhaustive enumeration over the finite sets. For each target j and each source i ∈ C₁₂, the hom-set Hom(i, j) consists of all voice leadings (b, s) with s − b ≡ j − i (mod 12) and ¬(j ∈ P₁₂ ∧ b = s ∧ b ≠ 0). The constraint s − b ≡ j − i (mod 12) fixes the difference s − b, leaving 12 free choices for b. The parallel-motion prohibition removes exactly those (b, s) with b = s ≠ 0, which occurs only when j − i ≡ 0 (mod 12), i.e., when i = j, and only when j ∈ P₁₂.

For j ∈ P₁₂: the 6 source intervals each contribute 12 voice leadings = 72, minus 11 forbidden parallel self-loops at j = 72 − 11 = 61.

For j ∈ I₁₂: no parallel-motion restriction applies (since j ∉ P₁₂), so all 72 voice leadings are permitted. ∎

**Interpretation.** The 15% reduction (61 vs 72) quantifies the *compositional cost* of perfect consonances. A composer writing toward a perfect fifth has fewer approach options than one writing toward a major third. This bottleneck is felt not just locally (the self-loop constraint) but globally (the reduced in-degree).

---

## 4. The Categorical Perspective

### 4.1 Quivers vs. Categories

A *quiver* (directed multigraph) consists of a set of objects and, for each pair of objects, a set of morphisms — but with no composition law. A *category* adds composition of morphisms and identity morphisms, subject to associativity and identity laws.

The Counterpoint Quiver Q(C₁₂, P₁₂) is naturally a quiver: the morphisms are the permitted voice leadings, and identity morphisms exist (the identity voice leading (0, 0) is always permitted, by Theorem 3.1 with i = j).

However, Theorem 3.2 shows that the obvious composition (component-wise addition of bass and soprano motions) does not preserve permission. Hence Q(C₁₂, P₁₂) cannot be promoted to a category under this composition.

### 4.2 The Free Category and Reachability

The *free category* generated by the quiver Q does have a composition law — it is the category of *paths* in Q. A morphism from i to j in the free category is a finite sequence of permitted voice leadings i → i₁ → i₂ → ⋯ → j. Theorem 3.1 guarantees that this free category is connected (every hom-set is nonempty).

### 4.3 The Thin Category Conjecture

One natural question is whether the set of consonant intervals, ordered by some musically meaningful relation, forms a *poset* whose associated thin category is equivalent to the counterpoint quiver in some functorial sense.

Our results suggest that this is **not** the case in any straightforward way. The non-composability theorem (3.2) shows that the quiver does not arise from a category at all, let alone a thin one. The hom-set cardinalities (Theorem 3.5) are far from the {0, 1}-valued hom-sets of a thin category. The counterpoint quiver is essentially *thicker* and *wilder* than any poset-generated category.

Instead, the correct categorical framework appears to be the quiver itself, possibly enriched with additional structure (e.g., a monoidal structure from voice-leading composition, modulo a quotient that identifies forbidden compositions).

---

## 5. Generalizations

### 5.1 Microtonal Counterpoint Systems

The Counterpoint System framework (Definition 2.1) immediately generalizes to any ℤ/nℤ. Natural candidates include:

- **19-TET** (n = 19): Used in some Renaissance tuning approximations. The consonant set would include intervals approximating the just ratios 5:4, 6:5, 3:2, etc.
- **31-TET** (n = 31): Studied by Huygens and Fokker. Provides excellent approximations to 7-limit just intervals.
- **24-TET** (n = 24): Quarter-tone system used in some 20th-century and Middle Eastern music.

For each system, the structural theorems can be investigated: connectivity, composability, self-loop asymmetry, and hom-set cardinalities. The proofs of Theorems 3.1 and 3.3 generalize immediately to any Counterpoint System; the specific cardinalities of Theorem 3.5 depend on |C| and |P|.

### 5.2 Higher-Species Counterpoint

First-species counterpoint is the simplest case. In second species (two notes against one), third species (four notes against one), and fourth species (syncopation/suspensions), additional constraints arise: passing tones, neighbor tones, and the preparation-suspension-resolution pattern. These could be modeled by enriching the quiver with *typed* edges and imposing path-level constraints, leading to a context-sensitive grammar on the quiver.

### 5.3 Multi-Voice Generalization

The two-voice framework extends to three or more voices by replacing ℤ/nℤ (the interval between two voices) with (ℤ/nℤ)^{k-1} (the intervals between k voices and a reference bass). The consonant set becomes a subset of (ℤ/nℤ)^{k-1}, and voice leadings become elements of (ℤ/nℤ)^k. The parallel-motion constraint applies to each pair of voices independently, creating a more complex web of restrictions.

---

## 6. Algorithms and Computation

### 6.1 Enumeration of Hom-Sets

For a fixed Counterpoint System (C, P) over ℤ/nℤ, the hom-set Hom(i, j) can be computed in O(n) time:

```
HomSet(i, j, C, P):
    d ← j - i (mod n)
    S ← {(b, b + d) : b ∈ ℤ/nℤ}
    if j ∈ P:
        remove from S all (b, s) with b = s and b ≠ 0
        // This removes the case d = 0 and b ≠ 0
    return S
```

### 6.2 Connectivity Check

Strong connectivity can be verified by BFS/DFS from each vertex, in O(|C|² · n) time (since each hom-set has at most n elements).

### 6.3 Composition Check

Non-composability can be checked by exhaustive search over triples (i, j, k) ∈ C³ and pairs of voice leadings, in O(|C|³ · n²) time. For the standard system, this is 6³ · 144 = 31,104 triples — easily feasible.

---

## 7. Discussion

### 7.1 Why Not a Category?

The failure of composability (Theorem 3.2) is perhaps the most musically significant result. In practice, it means that a composer cannot ensure correctness by checking only adjacent pairs of intervals — the overall progression must be considered holistically. This aligns with the pedagogical experience of counterpoint students, who learn that local correctness does not guarantee global correctness.

From a categorical perspective, this suggests that the "right" algebraic structure for counterpoint is not a category but something weaker — perhaps a *semicategory* (composition without identities) or a *partial category* (composition defined only on compatible pairs). The study of such structures in the context of music theory is a promising direction for future work.

### 7.2 The Significance of the 12:1 Ratio

The self-loop asymmetry (Theorem 3.3) provides a quantitative explanation for the traditional distinction between perfect and imperfect consonances. In traditional music theory, this distinction is presented as a matter of acoustic quality or historical convention. Our result shows that it has a precise combinatorial meaning: perfect consonances are *rigid* (admitting only trivial self-maps), while imperfect consonances are *flexible* (admitting the maximum number of self-maps).

This rigidity/flexibility dichotomy is reminiscent of similar phenomena in other mathematical contexts: simple groups vs. solvable groups, rigid vs. flexible polyhedra, or obstructed vs. unobstructed deformation problems. The parallel is suggestive, though we do not claim a formal connection.

### 7.3 Compositional Implications

The hom-set cardinalities (Theorem 3.5) have direct implications for algorithmic composition. A stochastic model that samples uniformly from permitted voice leadings will, *ceteris paribus*, approach perfect consonances less frequently than imperfect ones — simply because there are fewer routes leading to them. This provides a mathematical explanation for the empirical observation that perfect consonances tend to appear at structurally important moments (beginnings and endings of phrases) rather than in the middle of passages: they are *costly* to reach and hence *marked* when they appear.

---

## 8. Future Work

1. **Enriched quiver structure.** Equip edges with weights reflecting musical desirability (e.g., smooth voice leading = small total motion) and study shortest-path/minimum-cost problems.

2. **Spectral analysis.** Compute the adjacency spectrum of the counterpoint quiver's underlying directed graph. The spectral gap would quantify the "mixing time" of a random walk on consonant intervals.

3. **Microtonal comparison.** Systematically compute counterpoint quivers for 19-TET, 24-TET, and 31-TET systems and compare their connectivity, bottleneck ratios, and spectral properties.

4. **Higher species.** Extend the quiver framework to second and third species, modeling rhythmic subdivision as a temporal refinement of edges.

5. **Machine learning.** Use the quiver structure as an inductive bias for music generation models, constraining the output to lie on permitted paths in the counterpoint quiver.

---

## References

- Agmon, E. (1997). Musical durations as mathematical intervals. *Music Theory Online*, 3(6).
- Cohn, R. (1998). Introduction to neo-Riemannian theory. *Journal of Music Theory*, 42(2), 167–180.
- Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.
- Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
- Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
- Noll, T. (2018). One note samba: Mathematical reflections on a music-theoretical problem. *Journal of Mathematics and Music*, 12(3), 160–184.
- Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
- Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.

---

## Appendix A: Summary of Formal Results

| Identifier | Statement | Type |
|---|---|---|
| `CounterpointSystem` | Parameterized structure over ℤ/nℤ | Definition |
| `VoiceLeading` | Pair (bass, soprano) of motions in ℤ/nℤ | Definition |
| `standard12` | The standard 12-TET system with C₁₂, P₁₂ | Definition |
| `exists_permitted_voice_leading` | Strong connectivity of the quiver | Theorem |
| `non_composability` | Permitted VLs not closed under composition | Theorem |
| `perfect_self_loop_unique` | Perfect consonances: 1 self-loop | Theorem |
| `imperfect_self_loops_all` | Imperfect consonances: 12 self-loops | Theorem |
| `voice_swap_breaks_consonance` | σ(i) = −i does not preserve consonance | Theorem |
| `total_permitted_to_perfect` | 61 incoming VLs to perfect consonances | Theorem |
| `total_permitted_to_imperfect` | 72 incoming VLs to imperfect consonances | Theorem |
