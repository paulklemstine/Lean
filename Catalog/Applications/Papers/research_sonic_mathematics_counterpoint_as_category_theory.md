# Sonic Mathematics: Counterpoint as Category Theory

## The Counterpoint Quiver and Its Algebraic Invariants

---

### Abstract

We formalize first-species counterpoint rules (Fux, 1725) as a directed multigraph — the **Counterpoint Quiver** — over the cyclic group $\mathbb{Z}/n\mathbb{Z}$ of pitch-class intervals. Vertices are consonant intervals; directed edges are voice leadings permitted by the prohibition on parallel motion into perfect consonances. For the standard 12-TET system, we prove five structural theorems: (1) the quiver is strongly connected; (2) permitted voice leadings fail to compose, so they do not form a subcategory; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances; (4) the voice-swap involution $i \mapsto -i$ does not preserve consonance; and (5) perfect consonances receive exactly 61 incoming edges versus 72 for imperfect consonances. In a parallel development, we establish that voice-leading cost (the $L^1$ norm on the voice-motion lattice $(\text{Fin}\, n \to \mathbb{Z})$) satisfies a seminorm identity, a lattice conservation law, and gives rise to sublattice structure on ascending motions. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords:** species counterpoint, voice leading, quiver, category theory, lattice theory, $L^1$ seminorm, modular arithmetic, music theory, formal verification

---

### 1. Introduction

The rules of species counterpoint, codified by Fux in *Gradus ad Parnassum* (1725) and refined by subsequent theorists, constitute one of the oldest formalized constraint systems in Western intellectual history. Despite three centuries of pedagogical refinement, these rules have resisted algebraic systematization. Recent work in mathematical music theory — notably Tymoczko's geometric approach to voice leading (2006, 2011) and Mazzola's categorical framework (2002) — has established that voice-leading spaces possess rich geometric and algebraic structure. However, the *combinatorial* structure of permitted voice leadings under counterpoint constraints has not been fully characterized.

We address this gap by constructing the **Counterpoint Quiver**: a directed multigraph whose vertices are consonant intervals in $\mathbb{Z}/12\mathbb{Z}$ and whose edges are voice leadings satisfying Fux's parallel-motion prohibition. Our main contributions are:

1. A parameterized algebraic structure, `CounterpointSystem n`, that generalizes counterpoint constraints to arbitrary equal temperaments $\mathbb{Z}/n\mathbb{Z}$.
2. A complete enumeration and structural analysis of the quiver for $n = 12$.
3. A proof that permitted voice leadings are not closed under composition, refuting the natural conjecture that they form a subcategory.
4. A quantitative analysis of the "bottleneck" at perfect consonances.
5. A parallel development establishing that voice-leading cost is a seminorm on the voice-motion lattice, with a conservation law under lattice meet and join.

All results are formalized in Lean 4 with the Mathlib library, providing machine-verified guarantees of correctness.

---

### 2. Definitions and Setup

#### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *counterpoint system* over $\mathbb{Z}/n\mathbb{Z}$ (where $n \geq 1$) is a triple $(C, P, \rho)$ where:

- $C \subseteq \mathbb{Z}/n\mathbb{Z}$ is a finite nonempty set of **consonant intervals**;
- $P \subseteq C$ is a nonempty subset of **perfect consonances**;
- $C \setminus P \neq \emptyset$ (there exists at least one imperfect consonance);
- $\rho$ is the **parallel-motion prohibition**: a voice leading into a perfect consonance by parallel motion is forbidden.

In Lean, this is captured by the structure:

```
structure CounterpointSystem (n : ℕ) [NeZero n] where
  consonant : Finset (ZMod n)
  perfect : Finset (ZMod n)
  perfect_sub : perfect ⊆ consonant
  consonant_nonempty : consonant.Nonempty
  perfect_nonempty : perfect.Nonempty
  has_imperfect : ∃ i ∈ consonant, i ∉ perfect
```

**Definition 2.2** (Voice Leading). A *voice leading* over $\mathbb{Z}/n\mathbb{Z}$ is a pair $(b, s) \in \mathbb{Z}/n\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$, where $b$ is the bass motion and $s$ is the soprano motion.

**Definition 2.3** (Target Interval). Given source interval $i$ and voice leading $(b, s)$, the *target interval* is $i + s - b$.

**Definition 2.4** (Parallel Motion). A voice leading $(b, s)$ is *parallel* if $b = s$ and $b \neq 0$.

**Definition 2.5** (Permitted Voice Leading). A voice leading from source $i$ to target $j$ is *permitted* if:
1. $i, j \in C$ (both consonant);
2. $i + s - b = j$ (the voice leading maps source to target);
3. $\neg(j \in P \wedge b = s \wedge b \neq 0)$ (no parallel motion into perfect consonances).

#### 2.2 The Standard 12-TET System

The **standard system** $\mathcal{S}_{12}$ has:

$$C = \{0, 3, 4, 7, 8, 9\} \subset \mathbb{Z}/12\mathbb{Z}$$

$$P = \{0, 7\} \subset C$$

where the consonant intervals correspond to unison (0), minor third (3), major third (4), perfect fifth (7), minor sixth (8), and major sixth (9). The perfect consonances are unison/octave and perfect fifth.

#### 2.3 Voice-Leading Cost

**Definition 2.6** (Voice-Leading Cost). For $n$ voices with voice motion $m : \text{Fin}\, n \to \mathbb{Z}$, the *voice-leading cost* is the $L^1$ norm:

$$\|m\|_1 = \sum_{i=0}^{n-1} |m(i)|$$

This measures total voice displacement in semitones and is the standard efficiency measure in voice-leading theory.

#### 2.4 The Voice-Motion Lattice

The space $\text{Fin}\, n \to \mathbb{Z}$ carries a natural distributive lattice structure under componentwise min/max:

$$(m_1 \wedge m_2)(i) = \min(m_1(i), m_2(i))$$
$$(m_1 \vee m_2)(i) = \max(m_1(i), m_2(i))$$

---

### 3. Main Results: The Counterpoint Quiver

#### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity; `exists_permitted_voice_leading`). *For any two consonant intervals $i, j \in C$ in the standard 12-TET system, there exists a permitted voice leading from $i$ to $j$.*

*Proof sketch.* We consider two cases. If $i = j$, the identity voice leading $(0, 0)$ is always permitted (it is not parallel since bass motion is 0). If $i \neq j$, the **canonical voice leading** $(0, j - i)$ — where the bass stays fixed and the soprano moves by $j - i$ — maps $i$ to $j$ and is never parallel (since $b = 0 \neq s$ when $i \neq j$). Both cases are verified by exhaustive computation over the six consonant intervals. $\square$

**Corollary.** The Counterpoint Quiver is strongly connected as a directed graph. Every consonant interval is reachable from every other in a single step.

*Musical interpretation:* A composer working in first-species counterpoint can always reach any desired consonant interval from any starting point without violating the rules. No harmonic dead ends exist.

#### 3.2 Non-Composability

**Theorem 3.2** (Non-Composability; `non_composability`). *The set of permitted one-step voice leadings in $\mathcal{S}_{12}$ is not closed under composition. That is, there exist permitted voice leadings $v_1: i \to j$ and $v_2: j \to k$ whose composition $(b_1 + b_2, s_1 + s_2)$ is not a permitted voice leading from $i$ to $k$.*

*Proof sketch.* Consider two voice leadings that individually avoid parallel motion into perfect consonances but whose composed bass and soprano motions satisfy $b_1 + b_2 = s_1 + s_2 \neq 0$, with the target $k$ being a perfect consonance. Each step is legal, but their combination constitutes parallel motion into a perfect interval. $\square$

*Mathematical significance:* This theorem shows that permitted voice leadings do **not** form a subcategory of the free category on the quiver. The Counterpoint Quiver is genuinely a quiver (directed multigraph), not a category. Composition of morphisms fails — a fundamental obstruction to naïve categorical modeling of counterpoint.

*Musical significance:* Validity in counterpoint is context-dependent. The legality of a passage cannot be determined by checking individual steps in isolation.

#### 3.3 The Perfect Consonance Bottleneck

**Theorem 3.3** (Self-Loop Asymmetry; `perfect_self_loop_unique`, `imperfect_self_loops_all`). *In $\mathcal{S}_{12}$:*
- *A perfect consonance admits exactly 1 self-loop: the identity voice leading $(0, 0)$.*
- *An imperfect consonance admits exactly 12 self-loops: one for each value of $b \in \mathbb{Z}/12\mathbb{Z}$ (with $s = b$, which is permitted since the target is imperfect).*

*Proof sketch.* A self-loop at interval $i$ requires $i + s - b = i$, hence $s = b$. If $b \neq 0$, this is parallel motion. If $i$ is perfect, parallel motion into $i$ is forbidden, leaving only $b = s = 0$. If $i$ is imperfect, parallel motion into $i$ is unrestricted, giving all 12 choices of $b$. $\square$

*Musical interpretation:* This 12-to-1 ratio is the categorical manifestation of why parallel fifths and octaves are forbidden. Perfect consonances are "narrow passages" in the quiver, admitting dramatically fewer self-reinforcing motions.

#### 3.4 Voice-Swap Asymmetry

**Theorem 3.4** (Voice-Swap Breaks Consonance; `voice_swap_breaks_consonance`). *The involution $\sigma: \mathbb{Z}/12\mathbb{Z} \to \mathbb{Z}/12\mathbb{Z}$ defined by $\sigma(i) = -i$ does not preserve the set $C$ of consonant intervals. Specifically, $\sigma(7) = 5 \notin C$.*

*Proof sketch.* Direct computation: $-7 \equiv 5 \pmod{12}$, and $5 \notin \{0, 3, 4, 7, 8, 9\}$. $\square$

*Musical interpretation:* The perfect fifth (7 semitones up from the bass) maps to the perfect fourth (5 semitones, equivalently 7 semitones *down*). In counterpoint, the perfect fourth above the bass is treated as a dissonance — a convention reflecting the asymmetric role of the lowest voice. This theorem formalizes that asymmetry: consonance is not invariant under voice exchange.

*Mathematical significance:* The consonant set $C$ does not carry a $\mathbb{Z}/2\mathbb{Z}$-action by negation. This breaks the natural involutive symmetry of $\mathbb{Z}/12\mathbb{Z}$ and is a source of structural richness in the quiver.

#### 3.5 Hom-Set Cardinality

**Theorem 3.5** (Hom-Set Computation; `total_permitted_to_perfect`, `total_permitted_to_imperfect`). *In $\mathcal{S}_{12}$:*
- *The total number of permitted voice leadings into a perfect consonance (across all consonant sources) is 61.*
- *The total number into an imperfect consonance is 72.*

*Proof sketch.* For each consonant target, enumerate all $(b, s) \in (\mathbb{Z}/12\mathbb{Z})^2$ satisfying the permitted-motion predicate. For perfect targets, parallel motions $(b, s)$ with $b = s \neq 0$ are excluded, removing 11 edges per perfect target from each source that would otherwise contribute 12 edges. The precise counts are verified by decidable computation over the finite sets. $\square$

*Quantitative interpretation:* Perfect consonances receive approximately 15% fewer incoming voice leadings than imperfect consonances ($61/72 \approx 0.847$). This quantifies the "compositional cost" of targeting a perfect interval.

---

### 4. Main Results: The Voice-Leading Seminorm

#### 4.1 Metric Properties

**Theorem 4.1** (Seminorm Properties; `cost_seminorm_properties`). *The voice-leading cost function $\|\cdot\|_1 : (\text{Fin}\, n \to \mathbb{Z}) \to \mathbb{Z}$ satisfies:*
1. *Nonnegativity:* $\|m\|_1 \geq 0$ for all $m$.
2. *Subadditivity (Triangle Inequality):* $\|m_1 + m_2\|_1 \leq \|m_1\|_1 + \|m_2\|_1$.
3. *Absolute Homogeneity:* $\|c \cdot m\|_1 = |c| \cdot \|m\|_1$ for all $c \in \mathbb{Z}$.
4. *Definiteness:* $\|m\|_1 = 0$ if and only if $m = 0$.

*Proof sketch.* Properties (1) and (2) follow from the corresponding properties of absolute value and the linearity of summation. Property (3) uses $|c \cdot m(i)| = |c| \cdot |m(i)|$. Property (4) follows from the fact that $|m(i)| = 0$ iff $m(i) = 0$. $\square$

*Remark.* By property (4), the cost function is actually a *norm*, not merely a seminorm. Combined with the triangle inequality, voice-leading cost is a metric on the voice-motion space.

#### 4.2 The Lattice Conservation Law

**Theorem 4.2** (Lattice Identity; `cost_meet_join_eq`). *For any voice motions $m_1, m_2 : \text{Fin}\, n \to \mathbb{Z}$:*

$$\|m_1 \wedge m_2\|_1 + \|m_1 \vee m_2\|_1 = \|m_1\|_1 + \|m_2\|_1$$

*Proof sketch.* At each coordinate $i$, we have $|\min(a, b)| + |\max(a, b)| = |a| + |b|$ for all $a, b \in \mathbb{Z}$ (verified by case analysis on the signs and ordering of $a, b$). Summing over all coordinates yields the result. $\square$

*Musical interpretation:* The lattice operations (componentwise min and max of voice motions) conserve total displacement. If a composer considers two candidate voice leadings and forms their "floor" and "ceiling," the combined cost is unchanged. This provides a cost-neutral method for generating alternative voice leadings.

**Corollary 4.3** (`cost_meet_le`, `cost_join_le`). $\|m_1 \wedge m_2\|_1 \leq \|m_1\|_1 + \|m_2\|_1$ and similarly for join.

#### 4.3 The Ascending Sublattice

**Definition 4.4.** A voice motion $m$ is *ascending* if $m(i) \geq 0$ for all $i$.

**Theorem 4.5** (Ascending Sublattice; `ascending_meet`, `ascending_join`). *The set of ascending voice motions is closed under lattice meet and join; hence it forms a sublattice of $(\text{Fin}\, n \to \mathbb{Z}, \wedge, \vee)$.*

**Theorem 4.6** (`ascending_cost_eq_sum`). *For ascending motions, $\|m\|_1 = \sum_i m(i)$.*

**Theorem 4.7** (`ascending_meet_cost_le`). *For ascending motions $m_1, m_2$: $\|m_1 \wedge m_2\|_1 \leq \|m_1\|_1$.*

*Musical interpretation:* Among voice leadings where all voices move upward, the "conservative" choice (componentwise minimum) is always at least as efficient as either original. This formalizes the intuition that, in ascending passages, "less motion is better."

#### 4.4 Interval Preservation

**Theorem 4.8** (Parallel Preserves Intervals; `parallel_preserves_interval`). *If two voices move by the same amount (parallel motion), the interval between them is preserved.*

**Theorem 4.9** (Non-Parallel Changes Intervals; `nonparallel_changes_interval`). *If two voices move by different amounts, the interval between them necessarily changes.*

*Remark.* These are the foundational lemmas connecting the algebraic structure of voice leadings to the intervallic structure of chords. Theorem 4.8 explains *why* parallel motion is special: it is the unique motion type that preserves harmonic identity.

---

### 5. Algorithms and Computation

The decidability of all predicates in the Counterpoint System — consonance, parallel motion, and the permitted-motion predicate — enables exhaustive enumeration of the quiver for any finite $n$. The key computational results for $n = 12$ are:

| Property | Value |
|---|---|
| Consonant intervals | 6 |
| Perfect consonances | 2 |
| Imperfect consonances | 4 |
| Total voice leadings ($12^2$) | 144 |
| Self-loops at perfect interval | 1 |
| Self-loops at imperfect interval | 12 |
| Incoming edges to perfect target | 61 |
| Incoming edges to imperfect target | 72 |
| Self-loop asymmetry ratio | 12 : 1 |
| Incoming-edge reduction (perfect vs. imperfect) | ≈ 15% |

The enumeration algorithm runs in $O(n^2 |C|^2)$ time: for each of the $|C|^2$ source-target pairs, we iterate over all $n^2$ voice leadings and check the permitted-motion predicate (constant time). For $n = 12$, $|C| = 6$, this is $144 \times 36 = 5{,}184$ checks.

---

### 6. Discussion

#### 6.1 Relationship to Prior Work

**Tymoczko (2006, 2011)** models voice-leading spaces as orbifolds — quotients of $\mathbb{R}^n$ by the symmetric group action. Our approach is complementary: rather than studying the continuous geometry of voice-leading space, we analyze the discrete combinatorics of *permitted* voice leadings under counterpoint constraints. The quiver structure captures information that the orbifold does not: which motions are legal, not just which are small.

**Mazzola (2002)** proposes a categorical framework for music theory using topoi and denotators. Our work is more concrete: we test the specific hypothesis that counterpoint forms a category and prove it false (Theorem 3.2). The failure of composability is a precise mathematical statement that constrains future categorical models of counterpoint.

**Cohn (2012)** studies parsimonious voice leading in neo-Riemannian theory, focusing on triadic transformations. Our framework operates at the level of two-voice intervals rather than triads, but the CounterpointSystem structure generalizes naturally to higher dimensions.

#### 6.2 Generalization to Microtonal Systems

The parameterization by $n$ (the number of equal divisions of the octave) is not merely a mathematical convenience. Microtonal music in 19-TET, 31-TET, and 53-TET has a long history, and each system has its own intervallic taxonomy. The CounterpointSystem structure enables systematic study of counterpoint-like constraints in these systems by specifying the appropriate consonant and perfect subsets of $\mathbb{Z}/n\mathbb{Z}$.

**Open Problem.** Characterize the pairs $(n, |C|)$ for which the resulting counterpoint quiver is strongly connected. Our proof for $n = 12$ uses the canonical voice leading construction, which works for *any* system satisfying the axioms, but the strong connectivity may depend on the specific choice of consonant set.

#### 6.3 The Category Theory Connection

Our original hypothesis — that first-species counterpoint forms a category equivalent to a thin category on a 12-element poset — is refuted by Theorem 3.2. The quiver is not a category because composition fails. However, several weaker categorical structures remain viable:

1. **Free category.** The free category generated by the quiver has well-defined composition but does not respect counterpoint constraints on composed paths.
2. **Partial category.** Restricting composition to pairs where the result is also permitted yields a partial algebraic structure.
3. **2-category.** Modeling "sequences of voice leadings" as 2-cells, with counterpoint constraints as 2-categorical structure, may recover composability at a higher categorical level.

These directions are left for future work.

#### 6.4 Connection to Order Theory

The voice-motion lattice $(\text{Fin}\, n \to \mathbb{Z}, \wedge, \vee)$ and the conservation law (Theorem 4.2) connect voice leading to the theory of valuations on lattices. The cost function $\|\cdot\|_1$ is a *modular function* on this lattice: $f(x \wedge y) + f(x \vee y) = f(x) + f(y)$. Modular functions on lattices are well-studied in combinatorial optimization (e.g., submodular function minimization), suggesting potential algorithmic applications to voice-leading optimization.

---

### 7. Future Work

1. **Higher species.** Extend the quiver construction to second- through fifth-species counterpoint, incorporating passing tones, suspensions, and rhythmic constraints.

2. **Multi-voice generalization.** The current framework handles two-voice counterpoint. Extension to $n > 2$ voices requires modeling consonance as a predicate on $\binom{n}{2}$ pairwise intervals simultaneously.

3. **Weighted quiver.** Assign edge weights based on voice-leading cost, and study shortest-path problems as optimal counterpoint generation.

4. **Temporal logic.** Model multi-step counterpoint constraints (e.g., "no parallel fifths in successive beats") using temporal logic over quiver paths.

5. **Microtonal classification.** Systematically compute quiver invariants (connectivity, bottleneck ratios, self-loop counts) for all $n \leq 100$ and classify the resulting structures.

6. **Machine composition.** Use the quiver as the state machine for an algorithmic composition system that generates guaranteed-valid first-species counterpoint.

---

### 8. References

1. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
2. Tymoczko, D. (2006). "The Geometry of Musical Chords." *Science*, 313(5783), 72–74.
3. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
4. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
5. Cohn, R. (2012). *Audacious Euphony: Chromaticism and the Triad's Second Nature*. Oxford University Press.
6. Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.
7. Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.

---

### Appendix A: Catalog of Lean 4 Declarations

| Declaration | Type | Description |
|---|---|---|
| `CounterpointSystem n` | Structure | Parameterized counterpoint constraint system |
| `VoiceLeading n` | Structure | Bass-soprano motion pair |
| `standard12` | `CounterpointSystem 12` | The standard 12-TET first-species system |
| `exists_permitted_voice_leading` | Theorem | Strong connectivity of the quiver |
| `non_composability` | Theorem | Failure of composition |
| `perfect_self_loop_unique` | Theorem | Unique self-loop at perfect consonances |
| `imperfect_self_loops_all` | Theorem | 12 self-loops at imperfect consonances |
| `voice_swap_breaks_consonance` | Theorem | Voice exchange destroys consonance |
| `total_permitted_to_perfect` | Theorem | 61 incoming edges to perfect consonances |
| `total_permitted_to_imperfect` | Theorem | 72 incoming edges to imperfect consonances |
| `cost_triangle` | Theorem | Triangle inequality for voice-leading cost |
| `cost_meet_join_eq` | Theorem | Lattice conservation law |
| `cost_seminorm_properties` | Theorem | Seminorm characterization |
| `ascending_meet` / `ascending_join` | Theorem | Ascending sublattice closure |
| `parallel_preserves_interval` | Theorem | Parallel motion preserves intervals |
| `nonparallel_changes_interval` | Theorem | Non-parallel motion changes intervals |
