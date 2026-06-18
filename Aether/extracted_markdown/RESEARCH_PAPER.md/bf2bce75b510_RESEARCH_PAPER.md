# Voice Leading Algebras: Counterpoint as Categorical Structure

## Abstract

We introduce the **Voice Leading Algebra** (VLA), a parameterized algebraic structure that formalizes the rules of first-species counterpoint over ℤ/nℤ. Objects are consonant interval classes; morphisms are voice leadings (pairs of pitch-class motions) satisfying consonance preservation and the prohibition against parallel perfect consonances. We prove five main theorems: (1) the **Counterpoint Obstruction** — valid voice leadings are not closed under composition, refuting naive categorification of counterpoint; (2) **Strong Connectivity** — the valid-transition quiver is strongly connected; (3) **Inversion Asymmetry** — the perfect fifth is the unique consonance whose octave complement is dissonant; (4) the **Perfect Bottleneck** — perfect consonances admit exactly 1 parallel self-transition vs. 12 for imperfect consonances; (5) **Tension Injectivity** — consonant intervals are uniquely identified by their tension rank. All results are machine-verified in Lean 4 with Mathlib. The VLA framework generalizes to arbitrary equal-tempered tuning systems.

**Keywords**: counterpoint, voice leading, category theory, music theory, formal verification, modular arithmetic

---

## 1. Introduction

The rules of first-species counterpoint, codified by Fux in *Gradus ad Parnassum* (1725), govern the simplest form of polyphonic composition: note-against-note writing in two voices. The core constraints are:

1. Every vertical sonority must be a consonant interval (unison, third, fifth, sixth, or octave).
2. No parallel motion between identical perfect consonances (no parallel fifths, no parallel unisons/octaves).
3. Preference for contrary and oblique motion, especially when approaching perfect consonances.

These rules have been studied extensively in music theory (Jeppesen, 1939; Salzer & Schachter, 1969), computational musicology (Agmon, 1991; Tymoczko, 2011), and mathematical music theory (Mazzola, 2002; Fiore & Satyendra, 2005). However, a complete algebraic formalization that makes the *categorical failure* of these rules precise has been lacking.

We address this gap by introducing the **Voice Leading Algebra** (VLA), a structure that parameterizes counterpoint rules over an arbitrary cyclic group ℤ/nℤ. For the standard 12-tone equal temperament (12-TET), we establish five main results that reveal the algebraic structure of counterpoint.

### 1.1 Main Contributions

1. **The Counterpoint Obstruction Theorem** (Theorem 3.1): We prove that valid voice leadings under the parallel-perfects prohibition are not closed under composition. This definitively shows that first-species counterpoint cannot be organized as a category with voice-leading composition. The correct framework is the free category (path category) on the valid-transition quiver.

2. **Strong Connectivity** (Theorem 3.2): Despite the restrictions, the valid-transition quiver is strongly connected: any consonant interval can reach any other in a single step.

3. **Inversion Asymmetry** (Theorem 3.3): The perfect fifth is the unique consonant interval whose octave complement (inversion in ℤ/12ℤ) is not consonant. This provides a group-theoretic explanation for the special status of the fifth.

4. **The Perfect Bottleneck** (Theorem 3.4): Perfect consonances admit exactly 1 parallel self-transition (the identity), while imperfect consonances admit 12. The ratio 12:1 quantifies the restrictive nature of the parallel-perfects rule.

5. **Tension Injectivity** (Theorem 3.5): The tension rank function is injective on consonant intervals, providing a well-defined total ordering that respects the perfect/imperfect partition.

---

## 2. Definitions

### 2.1 The Chromatic Pitch-Class Group

We work over ℤ/12ℤ, the integers modulo 12, which represent the 12 chromatic pitch classes in standard equal temperament. Intervals between voices are elements of ℤ/12ℤ.

### 2.2 Consonant and Perfect Intervals

**Definition 2.1** (Consonant Set). The set of consonant intervals is:
$$C = \{0, 3, 4, 7, 8, 9\} \subset \mathbb{Z}/12\mathbb{Z}$$
corresponding to unison (0), minor third (3), major third (4), perfect fifth (7), minor sixth (8), and major sixth (9).

**Definition 2.2** (Perfect Set). The set of perfect consonances is:
$$P = \{0, 7\} \subset C$$

**Definition 2.3** (Imperfect Set). The set of imperfect consonances is:
$$I = \{3, 4, 8, 9\} = C \setminus P$$

**Lemma 2.4**. $C = P \sqcup I$ (disjoint union). $|C| = 6$, $|P| = 2$, $|I| = 4$.

### 2.3 Voice Leadings

**Definition 2.5** (Voice Leading). A voice leading is a pair $v = (\delta_u, \delta_l) \in (\mathbb{Z}/12\mathbb{Z})^2$, where $\delta_u$ is the motion of the upper voice and $\delta_l$ is the motion of the lower voice.

**Definition 2.6** (Apply). The application of voice leading $v = (\delta_u, \delta_l)$ to interval $i$ is:
$$v(i) = i + \delta_u - \delta_l$$

**Definition 2.7** (Composition). The composition of voice leadings $v_1 = (\delta_{u,1}, \delta_{l,1})$ and $v_2 = (\delta_{u,2}, \delta_{l,2})$ is:
$$v_1 \circ v_2 = (\delta_{u,1} + \delta_{u,2}, \delta_{l,1} + \delta_{l,2})$$

**Lemma 2.8** (Compatibility). $(v_1 \circ v_2)(i) = v_2(v_1(i))$.

**Definition 2.9** (Parallel Motion). A voice leading $v = (\delta_u, \delta_l)$ has parallel motion if $\delta_u = \delta_l$ and $\delta_u \neq 0$.

### 2.4 Valid Voice Leadings

**Definition 2.10** (Validity). A voice leading $v$ is valid from interval $i$ if:
1. $i \in C$ (source is consonant)
2. $v(i) \in C$ (target is consonant)
3. $\neg(i \in P \land v(i) = i \land v \text{ is parallel})$ (no parallel perfect consonances)

**Definition 2.11** (Identity). The identity voice leading is $\text{id} = (0, 0)$.

**Lemma 2.12**. The identity voice leading is valid from every consonant interval.

### 2.5 The Interval Inversion

**Definition 2.13** (Inversion). The inversion of interval $i$ is $\iota(i) = -i \in \mathbb{Z}/12\mathbb{Z}$.

**Lemma 2.14**. $\iota$ is an involution: $\iota(\iota(i)) = i$.

### 2.6 Tension Rank

**Definition 2.15** (Tension Rank). The function $\tau : \mathbb{Z}/12\mathbb{Z} \to \mathbb{N}$ assigns:
$$\tau(0) = 0, \quad \tau(7) = 1, \quad \tau(4) = 2, \quad \tau(3) = 3, \quad \tau(9) = 4, \quad \tau(8) = 5$$
with $\tau(i) = 6$ for $i \notin C$.

### 2.7 The Voice Leading Algebra (Generalization)

**Definition 2.16** (Voice Leading Algebra). A VLA over $\mathbb{Z}/n\mathbb{Z}$ is a triple $(C, P, n)$ where:
- $C \subseteq \mathbb{Z}/n\mathbb{Z}$ is a nonempty set of consonances
- $P \subseteq C$ is a set of perfect consonances
- Validity is defined as in Definition 2.10 with $C$ and $P$ replacing the standard sets

The standard 12-TET VLA is $(\{0,3,4,7,8,9\}, \{0,7\}, 12)$.

---

## 3. Main Results

### 3.1 The Counterpoint Obstruction

**Theorem 3.1** (Non-Compositionality). There exist consonant intervals $i, j$ and valid voice leadings $v_1 : i \to j$, $v_2 : j \to i$ such that $v_1 \circ v_2$ is not valid from $i$.

*Proof sketch*. Take $i = 7$ (P5), $j = 9$ (M6), $v_1 = (2, 0)$ (oblique: upper voice up 2), $v_2 = (0, 2)$ (oblique: lower voice up 2). Then:
- $v_1(7) = 7 + 2 - 0 = 9$. Valid: $9 \in C$, and $9 \neq 7$ so no parallel-perfect issue.
- $v_2(9) = 9 + 0 - 2 = 7$. Valid: $7 \in C$, and $9 \notin P$ so no parallel-perfect issue.
- $(v_1 \circ v_2) = (2, 2)$. $(v_1 \circ v_2)(7) = 7 + 2 - 2 = 7$. But $7 \in P$, $7 = 7$, $\delta_u = \delta_l = 2 \neq 0$: parallel motion to the same perfect consonance. Invalid. □

**Remark**. This theorem shows that the counterpoint rules define a *quiver* (directed graph with multiple edges), not a category. The correct categorical structure is the free category on this quiver — the path category, where morphisms are finite sequences of valid voice leadings.

### 3.2 Strong Connectivity

**Theorem 3.2** (Connectivity). For any consonant intervals $i, j \in C$, there exists a valid voice leading from $i$ to $j$.

*Proof sketch*. The witness is $v = (j - i, 0)$. Then $v(i) = i + (j-i) - 0 = j \in C$. The parallel condition requires $\delta_u = \delta_l = 0$ (since $\delta_l = 0$), so $\delta_u \neq 0$ fails if $i = j$ (giving $\delta_u = 0$). In all cases, the voice leading is valid. □

**Corollary**. The path category of the counterpoint quiver is connected.

### 3.3 Inversion Asymmetry

**Theorem 3.3** (Unique Inversion Failure). There exists a unique consonant interval whose inversion is not consonant, and it is the perfect fifth (7).

*Proof*. Compute: $\iota(0) = 0 \in C$, $\iota(3) = 9 \in C$, $\iota(4) = 8 \in C$, $\iota(7) = 5 \notin C$, $\iota(8) = 4 \in C$, $\iota(9) = 3 \in C$. The unique failure is $i = 7$. □

**Corollary 3.3.1**. The inversion $\iota$ restricts to an involution on the imperfect consonances $I$, swapping $3 \leftrightarrow 9$ and $4 \leftrightarrow 8$.

**Remark**. This result provides a group-theoretic explanation for the special treatment of the fifth in counterpoint. The perfect fifth is the *only* consonant interval that breaks the inversion symmetry of the consonance lattice. Its complement, the perfect fourth (5 semitones), is classified as dissonant in strict two-voice counterpoint — a classification that has puzzled theorists for centuries. Our result shows this is not arbitrary but reflects a fundamental asymmetry in the algebraic structure.

### 3.4 The Perfect Bottleneck

**Theorem 3.4** (Parallel Self-Transition Counts).
- For every $p \in P$: $|\{v : v \text{ valid from } p, v(p) = p, \delta_u = \delta_l\}| = 1$.
- For every $q \in I$: $|\{v : v \text{ valid from } q, v(q) = q, \delta_u = \delta_l\}| = 12$.

*Proof sketch*. A parallel self-transition $v = (a, a)$ satisfies $v(i) = i + a - a = i$. For $p \in P$: validity requires $\neg(p \in P \land p = p \land a = a \land a \neq 0)$, which forces $a = 0$. Only the identity works. For $q \in I$: $q \notin P$, so the parallel-perfects condition is vacuously satisfied. All 12 values of $a$ work. □

**Corollary 3.4.1** (Bottleneck Inequality). $\forall p \in P, \forall q \in I: |\text{ParSelf}(p)| < |\text{ParSelf}(q)|$.

The ratio 12:1 quantifies the "cost" of perfection: the parallel-fifths rule removes 11 of 12 parallel self-transitions from each perfect consonance.

### 3.5 Tension Injectivity

**Theorem 3.5** (Tension Injectivity). The tension rank $\tau$ is injective on $C$: for all $i, j \in C$, $\tau(i) = \tau(j) \implies i = j$.

*Proof*. The values $\tau(0) = 0, \tau(7) = 1, \tau(4) = 2, \tau(3) = 3, \tau(9) = 4, \tau(8) = 5$ are pairwise distinct. □

**Theorem 3.6** (Tension Separation). $\forall p \in P, \forall q \in I: \tau(p) < \tau(q)$.

*Proof*. $\max\{\tau(p) : p \in P\} = \tau(7) = 1 < 2 = \tau(4) = \min\{\tau(q) : q \in I\}$. □

### 3.6 Motion Classification

**Theorem 3.7** (Perfect Self-Transition Motion). Every valid non-identity voice leading from a perfect consonance to itself must use non-parallel motion type.

*Proof*. If $v$ has parallel motion type, then $\delta_u = \delta_l \neq 0$, so $v$ is parallel. Combined with $i \in P$ and $v(i) = i$, this violates validity. □

### 3.7 General VLA Results

**Theorem 3.8** (General Identity). In any VLA $(C, P, n)$, the zero voice leading $(0, 0)$ is valid from every consonant interval.

*Proof*. The target is $i + 0 - 0 = i \in C$. The parallel condition requires $0 \neq 0$, which is false. □

**Theorem 3.9** (12-TET Connectivity). In the standard VLA, oblique motion $(j - i, 0)$ is always valid from $i$ to $j$ (for $i, j \in C$).

---

## 4. The PEGB Analysis

### 4.1 Counterpoint Obstruction (Theorem 3.1)

- **P**roof: Machine-verified in Lean 4 with explicit witness $(i=7, j=9, v_1=(2,0), v_2=(0,2))$.
- **E**xample: In C major, soprano on E5 and bass on A3 (P5). Soprano moves to F♯5, bass stays (oblique to M6). Then soprano stays, bass moves to B3 (oblique back to P5). Individually legal; composite is parallel fifths.
- **G**eneralization: The obstruction holds in any VLA with $|P| \geq 1$ and $|C| \geq 2$ where $C \setminus P \neq \emptyset$ and there exist paths through imperfect consonances.
- **B**oundary: If $P = \emptyset$ (no perfect consonances), the obstruction vanishes and voice leadings form a category. The parallel-perfects rule is exactly the obstruction to categorification.

### 4.2 Inversion Asymmetry (Theorem 3.3)

- **P**roof: Exhaustive verification over $C = \{0,3,4,7,8,9\}$.
- **E**xample: The chord C-G (P5) inverts to G-C (P4), but P4 is dissonant. The chord C-E (M3) inverts to E-C (m6), both consonant.
- **G**eneralization: In 19-TET, the consonant set changes and the inversion analysis yields different asymmetries. The VLA framework handles all equal temperaments.
- **B**oundary: If we include the perfect fourth (5) as consonant (as in three-voice counterpoint), the inversion becomes closed on all consonances, and the asymmetry disappears.

### 4.3 Perfect Bottleneck (Theorem 3.4)

- **P**roof: Counting argument via decidable enumeration over ℤ/12ℤ.
- **E**xample: From unison C-C, the only valid parallel self-transition is "stay" (both voices hold). From major third C-E, any parallel motion (both up 1, both up 2, ..., both up 11) returns to major third C-E and is valid.
- **G**eneralization: In a VLA over ℤ/nℤ with $|P| = k$, perfect consonances admit 1 parallel self-transition and imperfect consonances admit $n$.
- **B**oundary: For $n = 1$ (trivial system), all intervals have 1 parallel self-transition. The bottleneck effect requires $n \geq 2$.

---

## 5. Falsifiable Conjecture

**Conjecture 5.1** (Chromatic Universality). For every prime $p \geq 5$, the VLA over ℤ/pℤ with $C = \{0, \lfloor p/4 \rfloor, \lfloor p/3 \rfloor, \lfloor p/2 \rfloor\}$ and $P = \{0, \lfloor p/2 \rfloor\}$ satisfies the Counterpoint Obstruction (non-compositionality of valid voice leadings).

**Computational Test**: Verify for $p = 5, 7, 11, 13, 17, 19, 23$ by exhaustive search over all voice-leading pairs.

---

## 6. Connection to Existing Results

Our work connects to the catalog theorem `root_triple_consonant_intervals` from `FINAL/Pythagorean/HarmonicMusicTheory.lean`, which establishes properties of consonant intervals in the Pythagorean tuning system. The VLA framework provides a categorical generalization: where the Pythagorean result works with specific frequency ratios, the VLA operates on the abstract algebraic structure of interval classes over ℤ/nℤ.

The non-compositionality result (Theorem 3.1) also connects to the Knuth-Bendix completion theorems in the catalog (`finished_rules_eq_theory` from `FINAL/Bridges/KnuthBendixCompletion.lean`), which study when rewriting systems converge. The counterpoint rules can be viewed as a non-confluent rewriting system, and our obstruction theorem shows that no completion to a category exists without enlarging the morphism set.

---

## 7. Discussion and Future Work

### 7.1 The Path Category

Since individual voice leadings don't compose, the natural categorical structure of counterpoint is the **path category** — the free category generated by the valid-transition quiver. Morphisms are finite sequences of valid voice leadings. This category is always well-defined and inherits strong connectivity from the underlying quiver.

### 7.2 Higher Species

First-species counterpoint is the simplest case. Second species (two notes against one), third species (four notes against one), and fourth species (syncopated counterpoint with suspensions) introduce temporal structure and dissonance treatment. The VLA framework could be extended to handle these by adding time-indexed validity conditions.

### 7.3 Microtonal Systems

The VLA framework naturally generalizes beyond 12-TET. For 19-TET, 31-TET, or 53-TET (which better approximate just intonation), the consonant set changes and new algebraic phenomena may emerge. The obstruction theorem and bottleneck inequality generalize to any VLA with non-trivial perfect consonances.

---

## 8. References

- Fux, J.J. (1725). *Gradus ad Parnassum*.
- Jeppesen, K. (1939). *Counterpoint: The Polyphonic Vocal Style of the Sixteenth Century*.
- Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
- Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
- Fiore, T.M. & Satyendra, R. (2005). Generalized contextual groups. *Music Theory Online*, 11(3).
- Agmon, E. (1991). Linear transformations between cyclically generated chords. *Musikometrika*, 3, 15-40.
