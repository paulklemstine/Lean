# Sonic Mathematics: First-Species Counterpoint as a Directed Quiver

## A Categorical and Combinatorial Analysis of Voice-Leading Constraints

---

### Abstract

We formalize the voice-leading rules of first-species counterpoint — the oldest and most fundamental framework for two-voice composition in Western music theory — as a directed multigraph (quiver) over the consonant intervals of the chromatic scale. Objects are consonant intervals modulo 12 semitones; arrows are voice leadings permitted by the classical rule prohibiting parallel motion into perfect consonances. We establish five main results: (1) the quiver is strongly connected; (2) the arrow set is not closed under composition, precluding categorical structure; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances, quantifying the "bottleneck" at perfect intervals; (4) the interval-negation involution does not preserve consonance, formalizing bass-voice privilege; and (5) perfect consonances admit exactly 61 incoming arrows versus 72 for imperfect consonances. All results are established within a general parameterized framework — the *Counterpoint System* — applicable to arbitrary equal temperaments, not just the standard 12-tone system.

**Keywords:** counterpoint, voice leading, category theory, directed graph, quiver, consonance, music theory, modular arithmetic, ZMod

---

### 1. Introduction

The rules of first-species counterpoint, codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725) and refined by subsequent theorists, govern the simplest possible setting for two-voice composition: note-against-note, every simultaneity a consonance. Despite their elementary nature, these rules encode a surprisingly rich mathematical structure that has attracted attention from researchers in mathematical music theory (Tymoczko 2011, Mazzola 2002, Cohn 1998).

Recent work in the geometry of voice-leading spaces (Tymoczko 2006, Callender et al. 2008) has explored continuous models of voice leading in pitch-class space. Our approach is complementary: we work in the *discrete* setting of modular arithmetic (`ZMod 12`) and study the *combinatorial* structure of the voice-leading graph — which pairs of consonant intervals can be connected by a permitted voice leading, and what global properties this graph exhibits.

The central observation is that the set of consonant intervals, together with the voice leadings permitted by counterpoint rules, forms a quiver (directed multigraph) with rich structure but *without* the closure properties needed to form a category. This failure of composability is not a defect but a feature: it captures the essentially *contextual* nature of voice-leading constraints, where the legality of a composite motion depends on the intermediate steps.

We introduce the *Counterpoint System* — a parameterized mathematical structure that abstracts the essential features of counterpoint-like constraints — and prove structural theorems at this level of generality before specializing to the standard 12-TET system.

#### 1.1 Related Work

Guerino Mazzola's *The Topos of Music* (2002) applies category theory and topos theory to music at a high level of abstraction. Our work is more concrete: we study a specific quiver arising from classical counterpoint rules and prove precise combinatorial theorems about it.

Dmitri Tymoczko's geometric theory of voice leading (2006, 2011) models voice-leading spaces as orbifolds. Our discrete model captures complementary aspects: while Tymoczko's geometry reveals the continuous topology of voice-leading space, our quiver reveals the combinatorial constraints imposed by consonance/dissonance distinctions and parallel-motion rules.

The neo-Riemannian theory (Cohn 1998, Lewin 1987) studies transformations between triads as group actions. Our voice leadings are more general (arbitrary pairs of motions) and our constraint structure (the parallel-motion rule) has no direct analog in neo-Riemannian theory.

---

### 2. Definitions

#### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *counterpoint system* of order $n$ (where $n \geq 1$) is a triple $(C, P, \varphi)$ where:

- $C \subseteq \mathbb{Z}/n\mathbb{Z}$ is a finite nonempty set of *consonant intervals*;
- $P \subseteq C$ is a nonempty set of *perfect consonances*;
- $C \setminus P \neq \emptyset$ (there exists at least one *imperfect consonance*);
- $\varphi$ is the *voice-leading rule*: parallel motion into a perfect consonance is forbidden.

The elements of $I := C \setminus P$ are called *imperfect consonances*.

**Definition 2.2** (Voice Leading). A *voice leading* over $\mathbb{Z}/n\mathbb{Z}$ is a pair $v = (b, s) \in (\mathbb{Z}/n\mathbb{Z})^2$, where $b$ is the bass motion and $s$ is the soprano motion.

**Definition 2.3** (Target Interval). Given a source interval $i \in \mathbb{Z}/n\mathbb{Z}$ and a voice leading $v = (b, s)$, the *target interval* is:
$$\tau(i, v) = i + s - b$$

**Definition 2.4** (Parallel Motion). A voice leading $v = (b, s)$ is *parallel* if $b = s$ and $b \neq 0$.

**Definition 2.5** (Permitted Voice Leading). A voice leading $v$ from source interval $i$ to target interval $j$ is *permitted* in counterpoint system $(C, P, \varphi)$ if:
1. $i \in C$ and $j \in C$;
2. $\tau(i, v) = j$;
3. $\neg(j \in P \land v \text{ is parallel})$.

#### 2.2 The Standard 12-TET System

The *standard 12-TET counterpoint system* is the counterpoint system of order 12 with:
$$C = \{0, 3, 4, 7, 8, 9\}$$
$$P = \{0, 7\}$$

These correspond to the six consonant intervals of first-species counterpoint:

| Interval | Semitones | Type |
|----------|-----------|------|
| Unison/Octave | 0 | Perfect |
| Minor third | 3 | Imperfect |
| Major third | 4 | Imperfect |
| Perfect fifth | 7 | Perfect |
| Minor sixth | 8 | Imperfect |
| Major sixth | 9 | Imperfect |

#### 2.3 The Counterpoint Quiver

**Definition 2.6** (Counterpoint Quiver). The *counterpoint quiver* of a counterpoint system $(C, P, \varphi)$ of order $n$ is the directed multigraph $Q = (V, E)$ where:
- $V = C$ (vertices are consonant intervals);
- For each $i, j \in C$, the set of edges from $i$ to $j$ is the set of voice leadings $v$ such that $v$ is permitted from $i$ to $j$.

---

### 3. Main Results

#### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *The counterpoint quiver of the standard 12-TET system is strongly connected: for any consonant intervals $i, j \in C$, there exists a permitted voice leading from $i$ to $j$.*

*Proof sketch.* We construct a *canonical voice leading* $v_{i \to j} = (0, j - i)$: the bass holds its note while the soprano moves by $j - i$ semitones. We verify:
- Target: $\tau(i, v_{i \to j}) = i + (j - i) - 0 = j$. ✓
- Parallel motion check: The bass motion is 0 and the soprano motion is $j - i$. For these to be parallel, we need $0 = j - i$ and $0 \neq 0$. The second condition is always false. Hence $v_{i \to j}$ is never parallel. ✓

Since $v_{i \to j}$ is never parallel, the parallel-fifths rule is never triggered, regardless of whether $j$ is perfect. When $i = j$, the identity voice leading $(0, 0)$ trivially satisfies all conditions. $\square$

**Remark.** This result generalizes immediately to any counterpoint system of any order: the canonical construction uses only the additive group structure of $\mathbb{Z}/n\mathbb{Z}$ and the fact that $(0, \cdot)$ is never parallel.

#### 3.2 Non-Composability

**Definition 3.2** (Composition of Voice Leadings). Given voice leadings $v_1 = (b_1, s_1)$ and $v_2 = (b_2, s_2)$, their *composition* is $v_2 \circ v_1 = (b_1 + b_2, s_1 + s_2)$.

**Theorem 3.3** (Non-Composability). *The set of permitted voice leadings in the standard 12-TET system is not closed under composition. There exist consonant intervals $i, j, k$ and permitted voice leadings $v_1$ (from $i$ to $j$) and $v_2$ (from $j$ to $k$) such that $v_2 \circ v_1$ is not permitted from $i$ to $k$.*

*Proof sketch.* Consider the following concrete witness:
- Let $i = 3$ (minor third), $j = 4$ (major third), $k = 7$ (perfect fifth).
- $v_1 = (0, 1)$: bass holds, soprano rises by 1. Source 3, target $3 + 1 - 0 = 4$. Not parallel (bass = 0 ≠ soprano = 1). Permitted. ✓
- $v_2 = (d, d+3)$ for some appropriate $d \neq 0$: both voices move, soprano moves 3 more than bass. Source 4, target $4 + (d+3) - d = 7$. Check if parallel: $d = d+3$ iff $3 = 0$ in $\mathbb{Z}/12\mathbb{Z}$, false. Permitted. ✓
- Composition: $v_2 \circ v_1 = (d, 1 + d + 3) = (d, d + 4)$. Source 3, target $3 + (d + 4) - d = 7$. Check: is $d = d + 4$? Only if $4 = 0$ mod 12, false. So this particular composition is also not parallel.

A more direct witness: take $v_1 = (1, 1)$ from source 3 to target 3 (parallel motion, $1 = 1$ and $1 \neq 0$, but target 3 is imperfect — permitted). Then $v_2 = (1, 1)$ from 3 to 3 (same reasoning). Composition $(2, 2)$ from 3: target = $3 + 2 - 2 = 3$, still imperfect — still permitted.

The actual witness used in the formal proof is found by exhaustive computation over all $12^2 = 144$ voice leadings and all $6^3 = 216$ triples of consonant intervals, identifying a triple where both steps are permitted but the composition is not. The existence of such a triple is verified by decidable computation. $\square$

**Corollary 3.4.** *The counterpoint quiver cannot be promoted to a category with composition of voice leadings as morphism composition. Permitted voice leadings form a quiver but not a subcategory of the free category on that quiver.*

#### 3.3 The Perfect Consonance Bottleneck

**Theorem 3.5** (Self-Loop Counts). *In the standard 12-TET counterpoint system:*
1. *Each perfect consonance $p \in P$ admits exactly 1 self-loop: the identity voice leading $(0, 0)$.*
2. *Each imperfect consonance $q \in I$ admits exactly 12 self-loops.*

*Proof sketch.* A self-loop at interval $i$ is a voice leading $(b, s)$ with $\tau(i, (b, s)) = i$, i.e., $s = b$, that is permitted from $i$ to $i$.

The constraint $s = b$ gives 12 possible voice leadings: $(k, k)$ for $k \in \mathbb{Z}/12\mathbb{Z}$.

- For $k = 0$: the identity, which is not parallel ($b = 0$). Always permitted.
- For $k \neq 0$: the voice leading $(k, k)$ is parallel ($b = s$ and $b \neq 0$). This is forbidden if and only if the target $i$ is perfect.

Hence:
- If $i \in P$: only $k = 0$ yields a permitted self-loop. Count = 1.
- If $i \in I$: all 12 values of $k$ yield permitted self-loops. Count = 12. $\square$

**Interpretation.** The ratio 12:1 between imperfect and perfect self-loop counts is a precise quantification of the "stiffness" at perfect consonances. A composer sitting on a perfect fifth has no room to maneuver while maintaining the same interval; a composer on a major third has twelve-fold freedom.

#### 3.4 Voice-Swap Asymmetry

**Definition 3.6** (Interval Negation). The *voice-swap involution* on $\mathbb{Z}/n\mathbb{Z}$ is the map $\nu : i \mapsto -i$.

**Theorem 3.7** (Voice-Swap Breaks Consonance). *The voice-swap involution $\nu$ does not preserve the consonant set $C$ of the standard 12-TET system. Specifically, $7 \in C$ but $\nu(7) = -7 = 5 \notin C$.*

*Proof.* Direct computation: $-7 \equiv 5 \pmod{12}$, and $5 \notin \{0, 3, 4, 7, 8, 9\}$. $\square$

**Remark.** The interval of 5 semitones is the perfect fourth, which in counterpoint is treated as a *dissonance* (or at best a special case requiring resolution). The asymmetry under negation formalizes the *privileged role of the bass voice*: the harmonic meaning of an interval depends on which voice is lower. This is a well-known principle in music theory, here given precise mathematical expression.

**Remark.** Observe that $\nu$ does preserve individual elements: $\nu(0) = 0 \in C$, $\nu(3) = 9 \in C$, $\nu(4) = 8 \in C$, $\nu(8) = 4 \in C$, $\nu(9) = 3 \in C$. It is *only* the perfect fifth $7 \mapsto 5$ that breaks consonance. The failure is thus minimal but structurally significant, affecting precisely the non-trivial perfect consonance.

#### 3.5 Hom-Set Cardinalities

**Theorem 3.8** (Hom-Set Computation). *In the standard 12-TET counterpoint quiver, the total number of incoming permitted voice leadings (summed over all consonant sources) is:*
- *61 for each perfect consonance;*
- *72 for each imperfect consonance.*

*Proof sketch.* For each target $j \in C$ and each source $i \in C$, the voice leading $(b, s)$ is permitted from $i$ to $j$ iff:
1. $s - b = j - i$ (target constraint): this fixes $s = b + (j - i)$, leaving $b$ free over $\mathbb{Z}/12\mathbb{Z}$ — 12 choices.
2. Not (parallel and target is perfect): eliminates the voice leadings with $b = s$ and $b \neq 0$, i.e., $j - i = 0$ and $b \neq 0$, which only applies when $i = j$.

So for $i \neq j$: 12 permitted voice leadings.
For $i = j$, $j$ perfect: 1 permitted voice leading (identity only).
For $i = j$, $j$ imperfect: 12 permitted voice leadings.

Summing over all 6 sources:
- For $j$ perfect: $5 \times 12 + 1 = 61$.
- For $j$ imperfect: $5 \times 12 + 12 = 72$. $\square$

**Corollary 3.9.** *The ratio of incoming voice leadings to imperfect versus perfect consonances is $72/61 \approx 1.18$, representing an 18% "tax" on approaching perfect consonances.*

---

### 4. The General Theory

#### 4.1 Counterpoint Systems of Arbitrary Order

All definitions in Section 2 are parametric in $n$, the number of equal divisions of the octave. The Counterpoint System structure over $\mathbb{Z}/n\mathbb{Z}$ requires only:
- A nonempty finite set $C \subseteq \mathbb{Z}/n\mathbb{Z}$ of consonances
- A nonempty subset $P \subseteq C$ of perfect consonances
- The existence of at least one imperfect consonance in $C \setminus P$

**Theorem 4.1** (General Connectivity). *For any counterpoint system of order $n$, the counterpoint quiver is strongly connected.*

*Proof.* The canonical voice-leading construction from Theorem 3.1 uses only the group structure of $\mathbb{Z}/n\mathbb{Z}$ and is independent of $|C|$, $|P|$, and $n$. $\square$

**Theorem 4.2** (General Self-Loop Dichotomy). *In a counterpoint system of order $n$:*
- *Each perfect consonance admits exactly 1 self-loop.*
- *Each imperfect consonance admits exactly $n$ self-loops.*

**Theorem 4.3** (General Hom-Set Formula). *In a counterpoint system of order $n$ with $|C| = c$ consonances:*
- *Each perfect consonance admits $(c-1) \cdot n + 1$ total incoming voice leadings.*
- *Each imperfect consonance admits $c \cdot n$ total incoming voice leadings.*

#### 4.2 Notable Microtonal Systems

| System | $n$ | Possible $|C|$ | Perfect self-loops | Imperfect self-loops |
|--------|-----|----------------|-------------------|---------------------|
| 12-TET | 12 | 6 | 1 | 12 |
| 19-TET | 19 | varies | 1 | 19 |
| 31-TET | 31 | varies | 1 | 31 |
| 53-TET | 53 | varies | 1 | 53 |

The self-loop ratio $n : 1$ grows with $n$, suggesting that perfect consonance constraints become relatively *more* restrictive in finer temperaments.

---

### 5. Categorical Perspective

#### 5.1 What the Quiver Is — and Is Not

The counterpoint quiver is a *quiver* (directed multigraph) but not a *category*. The distinction is important:

- A **quiver** is a set of objects with a set of arrows between each pair — no composition required.
- A **category** requires composition of arrows to be defined, associative, and internal (composing two arrows yields another arrow in the category).

Theorem 3.3 shows that the obvious composition operation (adding voice-leading vectors) takes permitted arrows to non-permitted ones. Hence the quiver of permitted voice leadings is not a subcategory of the free category on the quiver of all voice leadings.

#### 5.2 The Free Category and Its Quotients

The *free category* $\mathbf{Free}(Q)$ on the counterpoint quiver $Q$ does form a category: its morphisms are paths (finite sequences of permitted voice leadings). In this category, composability holds by construction — composition is concatenation of paths. However, this category does not identify voice leadings that produce the same net motion, and hence is much larger than the "naive" attempt at a voice-leading category.

One could quotient $\mathbf{Free}(Q)$ by the equivalence relation identifying paths with the same net voice-leading vector, but the resulting quotient would not generally be a category (the equivalence relation is not a congruence with respect to composition, precisely because of non-composability).

#### 5.3 The Thin Category Conjecture

The original motivation for this work was to test whether the counterpoint quiver might be equivalent to the thin category generated by a specific poset of 12 elements. The non-composability result (Theorem 3.3) definitively shows this is not the case for the voice-leading quiver with its natural composition. The counterpoint quiver has a richer structure than any poset-generated thin category: it is a quiver with multiple edges between vertices and no well-defined composition.

This negative result is itself illuminating: it shows that counterpoint rules are fundamentally *non-algebraic* in the sense that they cannot be captured by a single binary operation on voice leadings. The constraints are inherently *contextual* — they depend on the source and target intervals, not just the voice-leading vector.

---

### 6. Applications and Discussion

#### 6.1 Algorithmic Composition

The strong connectivity theorem (Theorem 3.1) guarantees that any sequence of consonant intervals can be realized by a sequence of permitted voice leadings. This has immediate algorithmic applications: given a target sequence of intervals, one can always construct a valid two-voice counterpoint realization by choosing, at each step, a permitted voice leading from the current interval to the next. The canonical voice-leading construction provides a default choice; richer musical results come from exploring the multiplicity of available voice leadings.

#### 6.2 Constraint Quantification

The hom-set computation (Theorem 3.8) provides a precise measure of compositional freedom at each interval. This can inform algorithmic composition by weighting random choices proportionally, or guide pedagogical exercises by directing students toward the more constrained (and hence more instructive) voice leadings involving perfect consonances.

#### 6.3 Microtonal Counterpoint

The general theory (Section 4) provides a rigorous framework for defining and studying counterpoint-like constraints in microtonal systems. The self-loop dichotomy (Theorem 4.2) predicts that the perfect/imperfect distinction becomes more extreme in finer temperaments, suggesting that microtonal counterpoint may require relaxed constraints on perfect consonances to remain compositionally viable.

---

### 7. Future Work

1. **Higher species.** Extend to second-species (two notes against one), third-species (four against one), and florid counterpoint. The quiver becomes a 2-quiver or higher categorical structure.

2. **Triadic counterpoint.** Move from two-voice intervals to three-voice chords. The object set becomes triads rather than intervals, and the morphism structure involves three simultaneous voice motions.

3. **Weighted quivers.** Assign weights to edges based on musical "smoothness" (total voice-leading distance, common-tone retention, etc.) and study shortest paths and flow problems on the weighted quiver.

4. **Homological invariants.** Compute the homology of the simplicial complex associated with the counterpoint quiver and interpret it musically.

5. **Machine learning.** Use the quiver structure as an inductive bias for neural network models of counterpoint, constraining the model to only produce permitted voice leadings.

---

### 8. References

1. Callender, C., Quinn, I., & Tymoczko, D. (2008). Generalized voice-leading spaces. *Science*, 320(5874), 346–348.

2. Cohn, R. (1998). Introduction to neo-Riemannian theory: A survey and a historical perspective. *Journal of Music Theory*, 42(2), 167–180.

3. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.

4. Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.

5. Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.

6. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.

7. Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.

---

### Appendix A: Catalog of Formal Results

| Result | Statement | Type |
|--------|-----------|------|
| `CounterpointSystem` | Parameterized constraint structure over `ZMod n` | Structure |
| `VoiceLeading` | Bass/soprano motion pair | Structure |
| `targetInterval` | $\tau(i, v) = i + s - b$ | Definition |
| `standard12` | The 12-TET system with $C = \{0,3,4,7,8,9\}$, $P = \{0,7\}$ | Definition |
| `exists_permitted_voice_leading` | Strong connectivity of the quiver | Theorem |
| `non_composability` | Permitted VLs not closed under composition | Theorem |
| `perfect_self_loop_unique` | Perfect consonances have 1 self-loop | Theorem |
| `imperfect_self_loops_all` | Imperfect consonances have 12 self-loops | Theorem |
| `voice_swap_breaks_consonance` | Negation map doesn't preserve consonance | Theorem |
| `total_permitted_to_perfect` | 61 incoming VLs to perfect consonances | Theorem |
| `total_permitted_to_imperfect` | 72 incoming VLs to imperfect consonances | Theorem |
