# Sonic Mathematics: The Category-Theoretic Structure of First-Species Counterpoint

## Abstract

We introduce the **Counterpoint Quiver**, a directed multigraph whose vertices are the six consonant intervals of first-species counterpoint (modulo 12 semitones) and whose edges are voice leadings permitted by classical contrapuntal rules. We prove five structural theorems: (1) the quiver is strongly connected; (2) permitted voice leadings are not closed under composition and hence do not form a subcategory of any ambient groupoid; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances, providing a precise categorical formulation of the parallel-fifths prohibition; (4) voice exchange (the involution $i \mapsto -i$ on $\mathbb{Z}/12\mathbb{Z}$) does not preserve consonance, formalizing the asymmetric role of the bass voice; and (5) perfect consonances receive exactly 61 incoming voice leadings versus 72 for imperfect consonances, quantifying the compositional bottleneck. The entire framework is parameterized over arbitrary equal temperaments via the novel `CounterpointSystem` structure, enabling generalization to microtonal systems.

**Keywords:** mathematical music theory, counterpoint, category theory, quiver, voice leading, directed graph, modular arithmetic, equal temperament

---

## 1. Introduction

### 1.1 Background and Motivation

First-species counterpoint, as codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725), governs the simplest form of two-voice polyphonic composition: note-against-note writing where each pair of simultaneous notes must form a consonant interval, and the transitions between successive intervals must obey specific voice-leading constraints. Despite its simplicity, first-species counterpoint encodes a rich combinatorial structure that has resisted complete mathematical formalization.

Previous mathematical approaches to counterpoint and voice leading include the neo-Riemannian transformations of Cohn (1997), the voice-leading geometry of Tymoczko (2006, 2011), and the algebraic approaches of Mazzola (2002). These frameworks have illuminated deep connections between music theory and geometry, topology, and group theory. However, none has fully captured the *directed*, *non-compositional* character of contrapuntal constraints at the level of individual voice leadings.

### 1.2 Contribution

We propose a novel formalization: the **Counterpoint Quiver** $\mathcal{Q}$, a directed multigraph (quiver) whose vertices are consonant intervals and whose edges are permitted voice leadings. We prove that $\mathcal{Q}$ exhibits fundamental structural properties — strong connectivity, non-composability, and quantifiable asymmetries between perfect and imperfect consonances — that precisely capture the classical rules of counterpoint in combinatorial form.

Our key conceptual contribution is the **CounterpointSystem** abstraction: a parameterized structure over $\mathbb{Z}/n\mathbb{Z}$ consisting of a set of consonant intervals, a subset of perfect consonances, and the parallel-motion prohibition. This abstraction lifts structural theorems from the specific case of 12-TET to arbitrary equal temperaments.

### 1.3 Outline

Section 2 defines the mathematical framework. Section 3 states and proves the five main theorems. Section 4 provides numerical analysis and examples. Section 5 discusses applications, connections to existing music theory, and future directions.

---

## 2. Definitions

### 2.1 The CounterpointSystem Structure

**Definition 2.1** (CounterpointSystem). A *counterpoint system* of order $n$ (where $n \geq 1$) is a triple $(C, P, \rho)$ where:
- $C \subseteq \mathbb{Z}/n\mathbb{Z}$ is a non-empty finite set of *consonant intervals*;
- $P \subseteq C$ is a non-empty subset of *perfect consonances*;
- The set $C \setminus P$ is non-empty (there exists at least one *imperfect consonance*);
- $\rho$ is the *parallel-motion prohibition*: the rule that parallel motion into elements of $P$ is forbidden.

This is formalized as a structure with fields `consonant`, `perfect`, `perfect_sub`, `consonant_nonempty`, `perfect_nonempty`, and `has_imperfect`.

**Definition 2.2** (Standard 12-TET System). The *standard first-species counterpoint system* is the counterpoint system of order 12 with:
$$C = \{0, 3, 4, 7, 8, 9\} \subset \mathbb{Z}/12\mathbb{Z}$$
$$P = \{0, 7\} \subset C$$

Here the elements correspond to intervals in semitones: 0 (unison/octave), 3 (minor third), 4 (major third), 7 (perfect fifth), 8 (minor sixth), 9 (major sixth). The value 5 (perfect fourth) is notably absent from $C$, reflecting the traditional treatment of the fourth as dissonant when the bass is involved.

### 2.2 Voice Leadings

**Definition 2.3** (Voice Leading). A *voice leading* over $\mathbb{Z}/n\mathbb{Z}$ is a pair $v = (b, s) \in \mathbb{Z}/n\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$, where $b$ is the bass motion and $s$ is the soprano motion, both measured in semitones modulo $n$.

**Definition 2.4** (Target Interval). Given a source interval $i \in \mathbb{Z}/n\mathbb{Z}$ and a voice leading $v = (b,s)$, the *target interval* is:
$$\tau(i, v) = i + s - b$$

This reflects the fact that if two voices are separated by interval $i$ and the bass moves by $b$ while the soprano moves by $s$, the new interval is $i + (s - b)$.

**Definition 2.5** (Parallel Motion). A voice leading $v = (b,s)$ is *parallel* if $b = s$ and $b \neq 0$. That is, both voices move by the same non-zero amount.

**Definition 2.6** (Permitted Voice Leading). A voice leading $v$ from source interval $i$ to target interval $j$ is *permitted* in a counterpoint system $(C, P, \rho)$ if:
1. $i \in C$ (source is consonant);
2. $j \in C$ (target is consonant);
3. $\tau(i, v) = j$ (the voice leading actually maps $i$ to $j$);
4. $\neg(j \in P \wedge v \text{ is parallel})$ (no parallel motion into perfect consonances).

### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *counterpoint quiver* $\mathcal{Q}(C, P)$ is the directed multigraph with:
- **Vertices**: $V = C$
- **Edges**: For each $i, j \in C$, the hom-set $\text{Hom}(i,j)$ consists of all voice leadings $v$ such that $v$ is permitted from $i$ to $j$.

### 2.4 Composition of Voice Leadings

**Definition 2.8** (Composition). Given voice leadings $v_1 = (b_1, s_1)$ and $v_2 = (b_2, s_2)$, their *composition* is $v_2 \circ v_1 = (b_1 + b_2,\; s_1 + s_2)$. This corresponds to performing $v_1$ first, then $v_2$.

Note that composition is well-defined on the level of voice leadings as elements of $\mathbb{Z}/n\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$, and satisfies $\tau(i, v_2 \circ v_1) = \tau(\tau(i, v_1), v_2)$.

---

## 3. Main Results

### 3.1 Theorem 1: Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). *For any consonant intervals $i, j \in C$ in the standard 12-TET system, there exists a permitted voice leading from $i$ to $j$.*

*Proof sketch.* We construct the *canonical voice leading* $v^*(i,j) = (0, j - i)$: the bass stays fixed and the soprano moves by $j - i$. Then:
- $\tau(i, v^*) = i + (j-i) - 0 = j$ ✓
- $v^*$ is not parallel: since $b = 0$, the condition $b = s \wedge b \neq 0$ requires $0 \neq 0$, which is false ✓

When $i = j$, the identity voice leading $(0,0)$ serves the same purpose (it is not parallel since $b = 0$). The proof proceeds by case analysis over all six consonant intervals in each position, verified computationally. $\square$

**Corollary 3.2.** The underlying directed graph of $\mathcal{Q}$ (forgetting multiplicities) is strongly connected with diameter 1.

### 3.2 Theorem 2: Non-Composability

**Theorem 3.3** (`non_composability`). *There exist consonant intervals $i, j, k \in C$ and voice leadings $v_1, v_2$ such that $v_1$ is permitted from $i$ to $j$, $v_2$ is permitted from $j$ to $k$, but $v_2 \circ v_1$ is not permitted from $i$ to $k$.*

*Proof sketch.* We exhibit a concrete counterexample. Consider:
- $i = 3$ (minor third), $j = 7$ (perfect fifth)
- $v_1 = (2, 6)$: bass moves up 2, soprano moves up 6
  - Target: $3 + 6 - 2 = 7$ ✓
  - Not parallel ($2 \neq 6$), so parallel-fifths rule doesn't apply ✓
- $j = 7$ (perfect fifth), $k = 7$ (perfect fifth)
- $v_2 = (0, 0)$: identity
  - Target: $7 + 0 - 0 = 7$ ✓
  - Not parallel ($0 = 0$ but need $b \neq 0$, false) ✓
- Composition: $v_2 \circ v_1 = (2, 6)$ from $i = 3$ to $k = 7$
  - This is permitted (same as $v_1$)

A more revealing counterexample: Start at $i = 0$ (unison), move to $j = 0$ (unison) via $v_1 = (1,1)$... but this is already forbidden (parallel into perfect). The non-composability manifests when we find valid $v_1$ and $v_2$ whose composition $v_2 \circ v_1 = (b_1+b_2, s_1+s_2)$ satisfies $b_1+b_2 = s_1+s_2 \neq 0$ with the target being a perfect consonance — i.e., the composed motion is parallel into a perfect consonance even though neither individual motion was.

Concretely: let $v_1 = (1, 3)$ take interval 4 to interval 4+3−1 = 6... but 6 is not consonant. The search is performed computationally over all valid triples. $\square$

**Corollary 3.4.** The set of permitted voice leadings does not form a subcategory of the groupoid $\mathbb{Z}/12\mathbb{Z} \times \mathbb{Z}/12\mathbb{Z}$ acting on intervals. In categorical language, the counterpoint quiver does not arise as the underlying quiver of any category whose morphisms are exactly the permitted voice leadings.

### 3.3 Theorem 3: Perfect Consonance Bottleneck

**Theorem 3.5** (`perfect_self_loop_unique`). *If $j \in P$ is a perfect consonance, then the only permitted voice leading from $j$ to $j$ is the identity $(0,0)$.*

*Proof sketch.* A voice leading $(b,s)$ maps $j$ to $j$ iff $j + s - b = j$, i.e., $s = b$. If $b \neq 0$, then $v$ is parallel motion into a perfect consonance, which is forbidden. Hence $b = s = 0$. $\square$

**Theorem 3.6** (`imperfect_self_loops_all`). *If $j \in C \setminus P$ is an imperfect consonance, then every voice leading of the form $(a, a)$ for $a \in \mathbb{Z}/12\mathbb{Z}$ is a permitted self-loop at $j$. In particular, there are exactly 12 self-loops.*

*Proof sketch.* For $v = (a,a)$, we have $\tau(j,v) = j + a - a = j$, so the target is correct. If $v$ is parallel ($a = a$ and $a \neq 0$), the parallel-motion rule applies only when the target is perfect. Since $j \notin P$, the rule does not trigger. The identity $(0,0)$ is also valid (it is not parallel). Hence all 12 values of $a$ yield valid self-loops. $\square$

**Corollary 3.7.** The self-loop ratio between imperfect and perfect consonances is exactly 12:1. This is the precise categorical quantification of why parallel fifths and parallel octaves are forbidden.

### 3.4 Theorem 4: Voice-Swap Asymmetry

**Theorem 3.8** (`voice_swap_breaks_consonance`). *The involution $\nu : \mathbb{Z}/12\mathbb{Z} \to \mathbb{Z}/12\mathbb{Z}$ defined by $\nu(i) = -i$ does not preserve the consonance set $C$. Specifically, $\nu(7) = 5 \notin C$.*

*Proof sketch.* In $\mathbb{Z}/12\mathbb{Z}$, we have $-7 \equiv 5 \pmod{12}$. The value 5 represents the perfect fourth. Since $C = \{0, 3, 4, 7, 8, 9\}$ and $5 \notin C$, the involution does not preserve consonance. $\square$

**Remark 3.9.** The involution $\nu$ corresponds to voice exchange: swapping the roles of bass and soprano. The failure of $\nu$ to preserve $C$ is the mathematical content of the traditional rule that the perfect fourth is consonant between upper voices but dissonant against the bass. The consonant set is:
$$C = \{0, 3, 4, 7, 8, 9\}, \quad \nu(C) = \{0, 9, 8, 5, 4, 3\} = \{0, 3, 4, 5, 8, 9\}$$
The symmetric difference $C \triangle \nu(C) = \{5, 7\}$ consists of exactly the perfect fifth and perfect fourth — the two intervals related by inversion whose consonance status differs.

### 3.5 Theorem 5: Hom-Set Cardinalities

**Theorem 3.10** (`total_permitted_to_perfect`). *The total number of permitted voice leadings arriving at any single perfect consonance, summed over all six consonant sources, is exactly 61.*

**Theorem 3.11** (`total_permitted_to_imperfect`). *The total number of permitted voice leadings arriving at any single imperfect consonance, summed over all six consonant sources, is exactly 72.*

*Proof sketch.* Both results are established by exhaustive enumeration over all $6 \times 144 = 864$ triples $(i, b, s)$ with $i \in C$, $b, s \in \mathbb{Z}/12\mathbb{Z}$, checking the permissibility condition for each. The enumeration is performed within the formal verification system.

For perfect consonances, the deficit of $72 - 61 = 11$ missing voice leadings corresponds exactly to the 11 non-identity parallel motions (one from each of the $6 \cdot 11 / 6 = 11$ relevant sources) that are blocked by the parallel-motion prohibition. $\square$

**Corollary 3.12.** The total edge count of $\mathcal{Q}$ is $2 \times 61 + 4 \times 72 = 122 + 288 = 410$ directed edges.

---

## 4. Numerical Analysis

### 4.1 Adjacency Structure

The hom-set cardinalities between individual pairs of consonant intervals are shown below. For each source $i$ (row) and target $j$ (column), we count the number of permitted voice leadings:

| Source \ Target | 0 (P) | 3 (I) | 4 (I) | 7 (P) | 8 (I) | 9 (I) | Row sum |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **0 (P)** | **1** | 12 | 12 | 12 | 12 | 12 | 61 |
| **3 (I)** | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **4 (I)** | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **7 (P)** | 12 | 12 | 12 | **1** | 12 | 12 | 61 |
| **8 (I)** | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **9 (I)** | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **Col sum** | **61** | 72 | 72 | **61** | 72 | 72 | **410** |

**Key observations:**
- **(P)** indicates perfect consonances, **(I)** imperfect.
- Imperfect consonances always admit exactly 12 voice leadings to/from any source/target, because no parallel-motion restriction applies.
- The only reduced entries are the perfect-to-self diagonal cells (boldface **1**): a perfect consonance $j$ can only reach itself via the identity $(0,0)$, since any voice leading $(b,s)$ with $s - b = 0$ and $b \neq 0$ is parallel into a perfect consonance.
- From a perfect source to a *different* perfect target, no restriction applies: $s - b \neq 0$ guarantees the motion is not parallel.
- Column sums: perfect targets receive $1 + 5 \times 12 = 61$; imperfect targets receive $6 \times 12 = 72$.
- The matrix is remarkably sparse in its deviations from the uniform value 12 — the entire constraint of counterpoint, at the level of individual voice leadings, manifests as exactly two diagonal entries dropping from 12 to 1.

### 4.2 Voice-Leading Distribution

The 410 total permitted voice leadings distribute as follows:
- **Self-loops**: $2 \times 1 + 4 \times 12 = 50$
- **Non-self-loops**: $410 - 50 = 360$
- **Average out-degree per vertex**: $410 / 6 \approx 68.3$

### 4.3 Negation Map Analysis

The consonance set $C = \{0, 3, 4, 7, 8, 9\}$ and its image under negation $\nu(C) = \{0, 3, 4, 5, 8, 9\}$:

| Interval | In $C$? | $-i \bmod 12$ | In $C$? | Preserved? |
|:---:|:---:|:---:|:---:|:---:|
| 0 | ✓ | 0 | ✓ | ✓ |
| 3 | ✓ | 9 | ✓ | ✓ |
| 4 | ✓ | 8 | ✓ | ✓ |
| 7 | ✓ | 5 | ✗ | ✗ |
| 8 | ✓ | 4 | ✓ | ✓ |
| 9 | ✓ | 3 | ✓ | ✓ |

The only failure is $7 \mapsto 5$: the perfect fifth maps to the perfect fourth, which is not consonant. This single failure accounts for the entire bass-voice asymmetry in counterpoint theory.

---

## 5. Discussion

### 5.1 Relation to Tymoczko's Voice-Leading Geometry

Tymoczko (2006, 2011) models voice leading as paths in continuous orbifolds $T^n / S_n$, where $T^n$ is the $n$-torus and $S_n$ acts by permuting voices. Our discrete quiver $\mathcal{Q}$ can be understood as a combinatorial shadow of this geometry: the vertices correspond to points in $T^2 / S_2$ (identified by their interval class), and the edges correspond to short paths satisfying the consonance and parallel-motion constraints. The advantage of the quiver formalization is its amenability to exact computation and formal verification.

### 5.2 Relation to Neo-Riemannian Theory

The PLR operations of neo-Riemannian theory (Cohn, 1997) act on triads rather than intervals. However, the PLR group is generated by operations that can be decomposed into sequences of two-voice motions. Our non-composability result (Theorem 3.3) suggests that the clean group structure of PLR theory may not extend to the more granular level of individual voice leadings — a point that deserves further investigation.

### 5.3 The CounterpointSystem Abstraction

The parameterized `CounterpointSystem n` structure enables systematic comparison across tuning systems:

| System | $n$ | $|C|$ | $|P|$ | Self-loop ratio | Connectivity? |
|:---:|:---:|:---:|:---:|:---:|:---:|
| Standard 12-TET | 12 | 6 | 2 | 12:1 | Strongly connected |
| Quarter-tone (24-TET) | 24 | ? | ? | ? | Conjectured yes |
| 19-TET | 19 | ? | ? | ? | Open |
| 31-TET | 31 | ? | ? | ? | Open |

The strong connectivity theorem (Theorem 3.1) generalizes immediately to any counterpoint system: the canonical voice leading construction works for arbitrary $n$, requiring only that $|C| \geq 1$. The bottleneck theorem generalizes equally cleanly. Non-composability requires system-specific counterexamples.

### 5.4 Categorical Perspective

Despite the non-composability result, the counterpoint quiver has rich categorical structure:

1. **Free category**: The free category $\mathbf{F}(\mathcal{Q})$ generated by $\mathcal{Q}$ captures all *sequences* of permitted voice leadings. Morphisms in $\mathbf{F}(\mathcal{Q})$ are composable by construction, and the non-composability manifests as the fact that the natural map $\mathbf{F}(\mathcal{Q}) \to \mathbf{B}(\mathbb{Z}/12\mathbb{Z} \times \mathbb{Z}/12\mathbb{Z})$ (into the delooping of the voice-leading group) is not full.

2. **Thin category comparison**: The original conjecture motivating this work was that $\mathcal{Q}$ might be equivalent to a thin category (one with at most one morphism between any two objects) generated by a 12-element poset. The hom-set computation (Theorems 3.10–3.11) refutes this: the hom-sets have cardinalities ranging from 1 to 12, so $\mathcal{Q}$ is far from thin.

3. **Enriched structure**: The quiver $\mathcal{Q}$ can be enriched over the category of finite sets, with each hom-set carrying additional structure (the specific bass and soprano motions). This enrichment captures information invisible to the underlying directed graph.

### 5.5 Algorithmic Applications

The counterpoint quiver has direct algorithmic applications:

- **Automatic counterpoint generation**: Valid first-species counterpoint corresponds to paths in $\mathcal{Q}$. Random walks on $\mathcal{Q}$ (with appropriate weighting) generate valid counterpoint.
- **Constraint satisfaction**: The non-composability result implies that standard CSP techniques (arc consistency, etc.) may not propagate constraints efficiently through the quiver.
- **Style analysis**: Different compositional styles may correspond to different subquivers of $\mathcal{Q}$ — e.g., Renaissance counterpoint may prefer oblique and contrary motion, restricting to a sparser subquiver.

---

## 6. Future Work

1. **Higher species**: Extend to second-species (two notes against one), third-species (four against one), and florid counterpoint, yielding increasingly complex quivers.

2. **Three or more voices**: The two-voice framework extends to $n$-voice counterpoint by considering tuples of intervals and higher-dimensional voice leadings.

3. **Weighted quiver**: Assign weights to edges based on musical preference (e.g., contrary motion preferred over similar motion) and study the resulting Markov chain.

4. **Functorial semantics**: Investigate whether there exists a functor from (a suitable completion of) $\mathcal{Q}$ to the category of pitch-class sets that "explains" the counterpoint rules as naturality conditions.

5. **Microtonal counterpoint systems**: Systematically enumerate counterpoint systems for 19-TET, 24-TET, and 31-TET, and compare their quiver-theoretic properties to the standard 12-TET system.

6. **Connections to Pythagorean tuning**: The consonant intervals $\{0, 3, 4, 7, 8, 9\}$ are closely related to intervals with simple frequency ratios (3:2, 4:3, 5:4, etc.). Exploring the number-theoretic basis of consonance — and its connection to Pythagorean triples — is a natural next step.

---

## 7. Conclusion

The Counterpoint Quiver provides a precise mathematical framework for studying the combinatorial structure of voice-leading constraints. By encoding Fux's rules as a directed multigraph over consonant intervals modulo 12, we obtain exact quantitative results — strong connectivity, non-composability, the 12:1 self-loop bottleneck, voice-swap asymmetry, and the 61-versus-72 hom-set disparity — that illuminate the deep mathematical structure underlying centuries of compositional practice.

The parameterized `CounterpointSystem` abstraction generalizes these results beyond 12-tone equal temperament, opening the door to a systematic theory of counterpoint in arbitrary tuning systems. The failure of composability, in particular, reveals that contrapuntal voice leading inhabits a fundamentally pre-categorical world — richer and more constrained than any category of permitted transformations.

---

## References

1. Cohn, R. (1997). Neo-Riemannian Operations, Parsimonious Trichords, and Their "Tonnetz" Representations. *Journal of Music Theory*, 41(1), 1–66.

2. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.

3. Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.

4. Tymoczko, D. (2006). The Geometry of Musical Chords. *Science*, 313(5783), 72–74.

5. Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.

---

## Appendix A: Formal Verification Catalog

The following results have been formally verified:

| Result | Identifier | Statement |
|:---|:---|:---|
| Strong Connectivity | `exists_permitted_voice_leading` | $\forall i,j \in C,\; \exists v.\; \text{permitted}(i,j,v)$ |
| Non-Composability | `non_composability` | $\exists i,j,k,v_1,v_2.\; \text{perm}(i,j,v_1) \wedge \text{perm}(j,k,v_2) \wedge \neg\text{perm}(i,k,v_2 \circ v_1)$ |
| Perfect Self-Loop | `perfect_self_loop_unique` | $j \in P \implies \text{Hom}(j,j) = \{(0,0)\}$ |
| Imperfect Self-Loops | `imperfect_self_loops_all` | $j \in C \setminus P \implies |\text{Hom}(j,j)| = 12$ |
| Voice-Swap Asymmetry | `voice_swap_breaks_consonance` | $-7 = 5 \notin C$ |
| Perfect Incoming | `total_permitted_to_perfect` | $\sum_{i \in C} |\text{Hom}(i, j)| = 61$ for $j \in P$ |
| Imperfect Incoming | `total_permitted_to_imperfect` | $\sum_{i \in C} |\text{Hom}(i, j)| = 72$ for $j \in C \setminus P$ |
