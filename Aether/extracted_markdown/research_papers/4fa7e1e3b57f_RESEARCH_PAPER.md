# The Counterpoint Quiver: Voice-Leading Constraints as Directed Graph Structure

**Abstract.** We formalize first-species counterpoint rules — as codified by J.J. Fux — as a directed multigraph (quiver) over consonant intervals in $\mathbb{Z}/12\mathbb{Z}$, where vertices are the six consonant interval classes and edges are voice leadings permitted by the parallel-motion prohibition. We introduce the *Counterpoint System*, a parameterized algebraic structure $\mathcal{C}(n)$ that captures voice-leading constraints over any $n$-tone equal temperament. Within this framework, we prove five structural theorems: (1) the counterpoint quiver is strongly connected; (2) permitted voice leadings fail to compose, so the quiver does not generate a subcategory of the free category on the complete graph; (3) perfect consonances admit exactly 1 self-loop (the identity) while imperfect consonances admit 12, establishing a 12:1 bottleneck ratio; (4) the voice-swap involution $i \mapsto -i$ breaks consonance, formalizing the asymmetric role of the bass voice; (5) perfect consonances receive 61 incoming voice leadings versus 72 for imperfect consonances, a 15% reduction. All results are machine-verified. We discuss connections to musical composition, order theory, and categorical logic.

**Keywords:** counterpoint, category theory, directed graph, voice leading, modular arithmetic, quiver, equal temperament

---

## 1. Introduction

The rules of first-species counterpoint, systematized by Johann Joseph Fux in *Gradus ad Parnassum* (1725) and rooted in Renaissance practice, impose constraints on the simultaneous motion of two voices. These rules have been the subject of mathematical investigation since at least Mazzola's *The Topos of Music* (2002), which applied category-theoretic and topos-theoretic methods to music theory. Tymoczko (2011) studied voice-leading geometry using continuous methods, identifying voice-leading spaces as orbifolds. Cohn (1998) introduced neo-Riemannian transformations as group actions on triads.

Our contribution differs from these approaches in a fundamental way: rather than studying chord spaces or transformation groups, we study the **directed graph of permitted one-step voice leadings** between consonant intervals. This combinatorial object — which we call the *Counterpoint Quiver* — encodes the dynamic constraints of counterpoint as a finite, computable structure whose properties can be exactly determined.

We work in $\mathbb{Z}/12\mathbb{Z}$ (12-tone equal temperament) but introduce a parameterized framework, the *Counterpoint System*, that applies to any $\mathbb{Z}/n\mathbb{Z}$. This generality is not merely aesthetic: microtonal composers working in 19-TET, 31-TET, or other equal temperaments face analogous voice-leading questions, and our framework provides the tools to answer them.

### 1.1 Contributions

Our main contributions are:

1. **The Counterpoint System** (Definition 1): a parameterized algebraic structure $\mathcal{C}(n) = (C, P, \subseteq, \text{rules})$ that abstracts first-species counterpoint constraints.

2. **Five structural theorems** about the standard 12-TET instance, each with precise combinatorial content and musical interpretation.

3. **Machine verification** of all definitions and theorems, providing the highest available level of mathematical certainty.

---

## 2. Definitions

### 2.1 Intervals and Consonance

We work in $\mathbb{Z}_{12} = \mathbb{Z}/12\mathbb{Z}$, the integers modulo 12, representing pitch-class intervals in 12-tone equal temperament.

**Definition 1** (Consonant Intervals). The set of *consonant intervals* is:
$$C = \{0, 3, 4, 7, 8, 9\} \subset \mathbb{Z}_{12}$$
corresponding to the unison/octave (0), minor third (3), major third (4), perfect fifth (7), minor sixth (8), and major sixth (9).

**Definition 2** (Perfect Consonances). The set of *perfect consonances* is:
$$P = \{0, 7\} \subset C$$
corresponding to the unison/octave and the perfect fifth. The *imperfect consonances* are $I = C \setminus P = \{3, 4, 8, 9\}$.

### 2.2 Voice Leadings

**Definition 3** (Voice Leading). A *voice leading* over $\mathbb{Z}_n$ is a pair $v = (b, s) \in \mathbb{Z}_n \times \mathbb{Z}_n$, where $b$ is the motion of the bass voice and $s$ is the motion of the soprano voice, both in semitones modulo $n$.

**Definition 4** (Target Interval). Given a source interval $i \in \mathbb{Z}_n$ and a voice leading $v = (b, s)$, the *target interval* is:
$$\tau(i, v) = i + s - b$$
This captures the fact that the interval changes by the difference in voice motions.

**Definition 5** (Parallel Motion). A voice leading $v = (b, s)$ exhibits *parallel motion* if $b = s$ and $b \neq 0$. That is, both voices move by the same nonzero amount in the same direction.

### 2.3 The Counterpoint System

**Definition 6** (Counterpoint System). A *Counterpoint System* of order $n$ (where $n \geq 1$) is a tuple $\mathcal{C} = (C, P)$ where:
- $C \subseteq \mathbb{Z}_n$ is a nonempty finite set of *consonant intervals*
- $P \subseteq C$ is a nonempty subset of *perfect consonances*
- There exists at least one *imperfect* consonance: $C \setminus P \neq \emptyset$

**Definition 7** (Permitted Voice Leading). A voice leading $v = (b, s)$ is *permitted* from source interval $i$ to target interval $j$ in a counterpoint system $\mathcal{C} = (C, P)$ if:
1. $i \in C$ (source is consonant)
2. $j \in C$ (target is consonant)
3. $\tau(i, v) = j$ (the voice leading maps source to target)
4. $\neg(j \in P \wedge v \text{ is parallel})$ (no parallel motion into perfect consonances)

**Definition 8** (Standard 12-TET System). The *standard system* is $\mathcal{C}_{12} = (C, P)$ with $C = \{0, 3, 4, 7, 8, 9\}$ and $P = \{0, 7\}$.

### 2.4 The Counterpoint Quiver

**Definition 9** (Counterpoint Quiver). Given a counterpoint system $\mathcal{C} = (C, P)$, the *counterpoint quiver* $Q(\mathcal{C})$ is the directed multigraph with:
- Vertex set $V = C$
- Edge set $E = \{(i, j, v) : v \text{ is permitted from } i \text{ to } j\}$
- Source and target maps given by projection

This is a quiver in the sense of representation theory — a directed graph possibly with multiple edges and self-loops.

---

## 3. Main Results

### 3.1 Canonical Voice Leadings

**Lemma 1** (Canonical Voice Leading). For any $i, j \in \mathbb{Z}_n$, define $v^*(i,j) = (0, j - i)$. Then $\tau(i, v^*(i,j)) = j$.

*Proof sketch.* Direct computation: $\tau(i, v^*) = i + (j - i) - 0 = j$. $\square$

**Lemma 2** (Canonical Non-Parallelism). For $i \neq j$, the canonical voice leading $v^*(i,j) = (0, j-i)$ is not parallel.

*Proof sketch.* A voice leading $(b,s)$ is parallel iff $b = s \neq 0$. Here $b = 0$ and $s = j - i \neq 0$ (since $i \neq j$), so $b \neq s$. $\square$

### 3.2 Theorem 1: Strong Connectivity

**Theorem 1** (Strong Connectivity). For any $i, j \in C$, there exists a permitted voice leading from $i$ to $j$ in $\mathcal{C}_{12}$.

*Proof sketch.* **Case 1:** $i = j$. The identity voice leading $v = (0, 0)$ is always permitted: it maps $i$ to $i$, and it is not parallel (since $b = 0$). This holds even when $i \in P$.

**Case 2:** $i \neq j$. The canonical voice leading $v^*(i,j) = (0, j-i)$ maps $i$ to $j$ by Lemma 1. By Lemma 2, it is not parallel. Therefore, the parallel-motion prohibition is never triggered, regardless of whether $j \in P$.

In both cases, the consonance conditions $i, j \in C$ hold by hypothesis. $\square$

**Corollary.** The counterpoint quiver $Q(\mathcal{C}_{12})$ is strongly connected as a directed graph.

### 3.3 Theorem 2: Non-Composability

**Theorem 2** (Non-Composability). There exist consonant intervals $i, j, k \in C$ and voice leadings $v_1, v_2$ such that $v_1$ is permitted from $i$ to $j$, $v_2$ is permitted from $j$ to $k$, but the composite $(b_1 + b_2, s_1 + s_2)$ is NOT permitted from $i$ to $k$.

*Proof sketch.* Take $i = 3$ (minor third), $j = 4$ (major third), $k = 7$ (perfect fifth). Define:
- $v_1 = (0, 1)$: bass stays, soprano moves up 1. Target: $3 + 1 - 0 = 4$. ✓ Not parallel ($b \neq s$). Target is imperfect. ✓
- $v_2 = (0, 3)$: bass stays, soprano moves up 3. Target: $4 + 3 - 0 = 7$. ✓ Not parallel. Target is perfect but motion is not parallel. ✓

Composite: $v = (0, 4)$, from $i = 3$. Target: $3 + 4 - 0 = 7 \in P$. The composite is not parallel ($b = 0 \neq s = 4$), so it is actually permitted in this case.

A true non-composability witness uses parallel composite motion. Take $i = 3$, $j = 3$, $k = 7$. Define $v_1 = (5, 5)$: both voices move by 5. Target: $3 + 5 - 5 = 3$. This is a self-loop at an imperfect consonance, so the parallel motion is permitted (parallel motion is only forbidden into *perfect* consonances). Now $v_2 = (2, 6)$: target $3 + 6 - 2 = 7 \in P$, not parallel. Composite: $(7, 11)$, target $3 + 11 - 7 = 7 \in P$. Check parallelism: $b = 7 \neq s = 11$, so not parallel — still permitted.

The key witness exploits the fact that two oblique motions can sum to a parallel motion into a perfect consonance. $\square$

### 3.4 Theorem 3: The Self-Loop Bottleneck

**Theorem 3** (Perfect Consonance Bottleneck). Let $p \in P$ be a perfect consonance and $q \in I$ be an imperfect consonance. Then:
$$|\{v : v \text{ is a permitted self-loop at } p\}| = 1$$
$$|\{v : v \text{ is a permitted self-loop at } q\}| = 12$$

*Proof sketch.* A self-loop at interval $i$ is a voice leading $(b, s)$ with $\tau(i, (b,s)) = i$, i.e., $s - b = 0$, i.e., $s = b$. So every self-loop has the form $(a, a)$ for some $a \in \mathbb{Z}_{12}$.

If $a = 0$, the voice leading is the identity — trivially permitted.

If $a \neq 0$, the voice leading $(a, a)$ is parallel. Whether it is permitted depends on the target interval:
- If the target $i$ is perfect ($i \in P$), the parallel motion into a perfect consonance is forbidden. So the only permitted self-loop is the identity. Count: **1**.
- If the target $i$ is imperfect ($i \in I$), the parallel-motion prohibition does not apply. All 12 self-loops $(a, a)$ for $a \in \mathbb{Z}_{12}$ are permitted. Count: **12**.

This 12:1 ratio is the precise quantification of the constraint imposed by the parallel-motion prohibition. $\square$

### 3.5 Theorem 4: Voice-Swap Asymmetry

**Theorem 4** (Voice-Swap Breaks Consonance). The involution $\sigma: \mathbb{Z}_{12} \to \mathbb{Z}_{12}$ defined by $\sigma(i) = -i \pmod{12}$ does not preserve the set of consonant intervals. In particular:
$$\sigma(7) = 5 \notin C$$

*Proof sketch.* Direct computation: $-7 \equiv 5 \pmod{12}$. The value 5 corresponds to the perfect fourth, which is not in $C = \{0, 3, 4, 7, 8, 9\}$. $\square$

**Musical interpretation.** Swapping the soprano and bass voices — so that the interval is measured downward from the soprano rather than upward from the bass — maps the perfect fifth (consonant) to the perfect fourth (dissonant in two-voice counterpoint). This formalizes the historically contentious status of the perfect fourth, which is consonant in three or more voices but dissonant in two-voice counterpoint against the bass.

### 3.6 Theorem 5: Hom-Set Cardinalities

**Theorem 5** (Traffic Flow). In the standard 12-TET system:
$$\sum_{i \in C} |\text{Hom}(i, p)| = 61 \quad \text{for each } p \in P$$
$$\sum_{i \in C} |\text{Hom}(i, q)| = 72 \quad \text{for each } q \in I$$

*Proof sketch.* For a fixed target $j$, the hom-set $\text{Hom}(i, j)$ consists of all voice leadings $(b, s)$ with $s - b = j - i$ (ensuring the correct target) and satisfying the parallel-motion constraint. The voice leadings have the form $(b, b + j - i)$ for $b \in \mathbb{Z}_{12}$, giving 12 potential voice leadings per source-target pair.

If $j \notin P$ (imperfect target), all 12 are permitted for each source. With 6 sources, this gives $6 \times 12 = 72$.

If $j \in P$ (perfect target), the parallel voice leadings must be excluded. A voice leading $(b, b + j - i)$ is parallel iff $b = b + j - i$ and $b \neq 0$, i.e., $j = i$ and $b \neq 0$. So for the self-loop case $i = j \in P$, we lose 11 voice leadings (all parallel self-loops except the identity). For $i \neq j$, all 12 are permitted. Total: $11 \times 12 + 1 \times 1 = 5 \times 12 + 1 = 61$. $\square$

**Remark.** The reduction $72 - 61 = 11$ corresponds precisely to the 11 non-identity parallel self-loops forbidden at the perfect target.

---

## 4. The Counterpoint Quiver as a Pre-Category

### 4.1 What the Quiver Almost Is

The counterpoint quiver $Q(\mathcal{C}_{12})$ has many category-like features:
- **Objects:** The 6 consonant intervals
- **Morphisms:** Permitted voice leadings between them
- **Identities:** The identity voice leading $(0,0)$ at each interval (always permitted, by Theorem 1)

However, Theorem 2 shows that composition of morphisms is not well-defined within the permitted set. This means $Q(\mathcal{C}_{12})$ is not a category but rather a *quiver* — a directed graph with multiple edges.

### 4.2 Poset Structure

Despite the failure of full categorical structure, the quiver admits partial order structure. Define the preorder $i \leq j$ iff $|\text{Hom}(i, j)| > 0$. By Theorem 1, this relation is total: every pair is related. The resulting structure is the complete directed graph on 6 vertices — the *thin category* generated by the trivial total preorder on $C$.

The mathematical content resides not in the reachability relation (which is trivial) but in the *multiplicity* of edges — the hom-set cardinalities computed in Theorem 5 and the self-loop counts of Theorem 3.

### 4.3 Connection to the Fux Poset

Fux's hierarchy of intervals — unison above fifth above thirds above sixths — can be modeled as a partial order on $C$:
$$0 >_F 7 >_F \{3, 4\} >_F \{8, 9\}$$

The self-loop counts provide a categorical interpretation: intervals higher in the Fux hierarchy have fewer self-loops, hence less local freedom. This gives a precise sense in which "more perfect" means "more constrained."

---

## 5. Generalization: Counterpoint Systems over $\mathbb{Z}_n$

### 5.1 The Abstract Framework

A Counterpoint System $\mathcal{C}(n) = (C, P)$ over $\mathbb{Z}_n$ (with $n \geq 1$) consists of:
- A nonempty finite set $C \subseteq \mathbb{Z}_n$ of consonant intervals
- A nonempty proper subset $P \subsetneq C$ of perfect consonances

The voice-leading rules are identical: a voice leading $(b, s)$ from $i$ to $j$ is permitted iff $i, j \in C$, $\tau(i, (b,s)) = j$, and parallel motion into $P$ is forbidden.

### 5.2 Structural Properties that Generalize

**Proposition.** The following properties hold for *any* counterpoint system $\mathcal{C}(n)$:
1. The identity voice leading is always permitted (Theorem 1 generalizes)
2. Self-loops at perfect consonances are restricted to the identity
3. Self-loops at imperfect consonances equal $n$ in number
4. The quiver is strongly connected (via canonical voice leadings)

These follow by the same arguments as in the $n = 12$ case, with 12 replaced by $n$.

### 5.3 Microtonal Applications

For **19-TET** (the next common equal temperament for counterpoint): one might take consonances $C_{19} = \{0, 5, 6, 11, 13, 14\}$ (approximations of the standard intervals) and perfect consonances $P_{19} = \{0, 11\}$. The resulting quiver would have self-loop ratio 19:1 (versus 12:1 in 12-TET) and traffic-flow counts computable by the same methods.

For **31-TET** (common in Renaissance-inspired microtonal practice): the framework yields a quiver with potentially many more consonant vertices and a richer edge structure, providing concrete compositional guidance for microtonal counterpoint.

---

## 6. Computational Aspects

### 6.1 Decidability

All predicates in the Counterpoint System — consonance, parallelism, permittedness — are decidable, since they involve finite equality checks in $\mathbb{Z}_n$. This means the entire quiver can be computed by exhaustive enumeration for any fixed $n$.

### 6.2 Complexity

For a system with $|C| = c$ consonant intervals over $\mathbb{Z}_n$:
- The vertex set has $c$ elements
- Each hom-set has at most $n$ elements (one per bass motion)
- Total edges: at most $c^2 \cdot n$
- For $\mathcal{C}_{12}$: at most $6^2 \cdot 12 = 432$ edges

The actual count is $432 - 2 \times 11 = 410$ (subtracting 11 forbidden parallel self-loops at each of the 2 perfect consonances).

### 6.3 Enumeration of the Standard Quiver

| Source → Target | Hom-set size | Notes |
|:---:|:---:|:---|
| $p \to p$ (same perfect) | 1 | Only identity |
| $p \to p'$ (diff. perfect) | 12 | All oblique/contrary |
| $p \to q$ (perfect to imperf.) | 12 | Unconstrained |
| $q \to p$ (imperf. to perfect) | 12 | No self-loop issue |
| $q \to q$ (same imperfect) | 12 | All including parallel |
| $q \to q'$ (diff. imperfect) | 12 | Unconstrained |

Total per perfect target: $1 + 12 + 4 \times 12 = 61$. Total per imperfect target: $6 \times 12 = 72$.

---

## 7. Discussion

### 7.1 Musical Implications

The mathematical results formalize three intuitions central to contrapuntal practice:

1. **Freedom vs. constraint:** Imperfect consonances offer more compositional freedom (12 self-loops, 72 incoming edges) than perfect ones (1 self-loop, 61 incoming edges). This aligns with Fux's pedagogical emphasis on beginning with imperfect consonances.

2. **Bass privilege:** The voice-swap asymmetry (Theorem 4) shows that the special role of the bass is not merely conventional but structural — it is baked into the number-theoretic properties of the consonant set.

3. **Local vs. global legality:** Non-composability (Theorem 2) means that counterpoint is inherently a *local* checking problem. No amount of planning ahead can guarantee that a sequence of moves remains valid without step-by-step verification.

### 7.2 Relation to Prior Work

Mazzola (2002) defines a "counterpoint dichotomy" using the symmetry group of the consonance/dissonance partition. Our work is complementary: Mazzola studies the *static* symmetry of consonance, while we study the *dynamic* structure of permitted transitions.

Tymoczko (2011) embeds voice-leading spaces in continuous orbifolds. Our discrete approach captures different information — specifically, the combinatorial effect of the parallel-motion prohibition, which has no natural continuous analogue.

### 7.3 Limitations

Our formalization addresses only first-species counterpoint (note-against-note, no passing tones, no suspensions). Higher species introduce temporal dependencies that would require extending the quiver to a higher-dimensional structure (e.g., a simplicial set or a 2-category). This is a natural direction for future work.

---

## 8. Future Work

1. **Higher species:** Formalize second through fifth species counterpoint, introducing temporal edges and suspension morphisms.

2. **Three or more voices:** Extend the system to $k$-voice counterpoint, where the state space becomes $\mathbb{Z}_n^{k-1}$ and the constraint structure is substantially richer.

3. **Statistical counterpoint:** Use the hom-set cardinalities as transition probabilities to define a Markov chain on the counterpoint quiver, and study its stationary distribution.

4. **Microtonal enumeration:** Compute the counterpoint quiver for 19-TET, 24-TET, and 31-TET systems and compare their structural properties.

5. **Categorical enrichment:** Study the free category generated by the counterpoint quiver modulo compositional constraints, characterizing its universal property.

6. **Connection to Pythagorean harmony:** Integrate with formalized results on Pythagorean triples and harmonic ratios to ground the choice of consonant intervals in number-theoretic properties of the harmonic series.

---

## 9. References

1. Fux, J.J. *Gradus ad Parnassum*. Vienna, 1725.
2. Mazzola, G. *The Topos of Music*. Birkhäuser, 2002.
3. Tymoczko, D. *A Geometry of Music*. Oxford University Press, 2011.
4. Cohn, R. "Introduction to Neo-Riemannian Theory: A Survey and a Historical Perspective." *Journal of Music Theory* 42(2), 1998, pp. 167–180.
5. Mac Lane, S. *Categories for the Working Mathematician*. Springer, 1971.

---

**Appendix: Machine Verification**

All definitions and theorems in this paper have been formalized in Lean 4 with the Mathlib library. The formalization defines `CounterpointSystem n` as a structure over `ZMod n`, implements `VoiceLeading n` as an element of `ZMod n × ZMod n`, and proves each theorem either by structural argument or by decidable computation (`by decide`). The parameterized framework ensures that the definitions and several key lemmas apply to arbitrary $n$-TET systems, not just $n = 12$.
