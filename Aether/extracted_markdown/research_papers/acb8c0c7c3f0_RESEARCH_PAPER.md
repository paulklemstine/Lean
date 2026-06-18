# The Fux Category: First-Species Counterpoint as a Categorical Structure

## Abstract

We formalize the rules of Fux's first-species counterpoint as a category where objects are consonant interval classes in ℤ/12ℤ and morphisms are permitted voice leadings labeled by motion type. The resulting structure — the **Fux Category** — exhibits remarkable algebraic properties. We prove that: (1) the consonant set {0, 3, 4, 7, 8, 9} is spectrally complete (its pairwise differences cover all of ℤ/12ℤ) but NOT closed under inversion (the Perfect Fourth Anomaly); (2) Fux's constraint removes exactly 12 of 144 labeled transitions, yielding a {3,4}-valued adjacency matrix with uniform outgoing degree 22; (3) valid transitions compose to valid transitions, establishing the categorical structure; (4) the consonant set generates ℤ/12ℤ as an additive group. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: music theory, category theory, counterpoint, Fux, ℤ/12ℤ, interval classes, formal verification

---

## 1. Introduction

The connection between mathematics and music is ancient — Pythagoras, Euler, and Helmholtz all explored it. However, most mathematical treatments of music theory focus on *tuning systems* (frequency ratios, temperaments) or *pitch-class set theory* (combinatorics of note collections). The *compositional constraints* of counterpoint — the rules governing how voices move relative to each other — have received comparatively little algebraic attention.

In this paper, we formalize Fux's first-species counterpoint (note-against-note, two voices) as a categorical structure. The key insight is that counterpoint rules define a directed multigraph (quiver) on consonant interval classes, and the path category of this quiver has non-trivial algebraic properties.

### 1.1 Related Work

Mazzola's *The Topos of Music* (2002) applies category theory to music at a high level of abstraction. Tymoczko's *A Geometry of Music* (2011) uses geometric and topological methods. Our approach is more concrete: we define a specific finite category with 6 objects and 132 generating morphisms, prove exact combinatorial properties, and verify everything in a proof assistant.

The catalog theorem `root_triple_consonant_intervals` from the Pythagorean music theory formalization establishes that Pythagorean triple ratios (3:4:5) yield consonant intervals. Our work builds on this by studying the *transition structure* among consonant intervals under counterpoint constraints.

## 2. Definitions

### 2.1 Consonant Interval Classes

**Definition 2.1.** The set of *consonant interval classes* in 12-tone equal temperament is
$$C = \{0, 3, 4, 7, 8, 9\} \subset \mathbb{Z}/12\mathbb{Z}$$
where 0 = unison/octave, 3 = minor third, 4 = major third, 7 = perfect fifth, 8 = minor sixth, 9 = major sixth.

**Definition 2.2.** An interval class $c \in C$ is *perfect* if $c \in \{0, 7\}$ and *imperfect* if $c \in \{3, 4, 8, 9\}$.

### 2.2 Motion Types

**Definition 2.3.** A *motion type* is one of: contrary, oblique, similar, or parallel.

### 2.3 The Fux Quiver

**Definition 2.4.** The *Fux Quiver* $Q$ has:
- **Objects**: $\text{Ob}(Q) = C$ (the six consonant interval classes)
- **Edges**: For each $(s, t, m) \in C \times C \times \text{Motion}$, there is an edge $s \xrightarrow{m} t$ iff $\text{fuxValid}(s, t, m) = \text{true}$.

**Definition 2.5.** A transition $(s, t, m)$ is *Fux-valid* iff it is NOT the case that $t$ is perfect AND $m$ is parallel. Formally:
$$\text{fuxValid}(s, t, m) = \neg(t.\text{isPerfect} \wedge m = \text{parallel})$$

### 2.4 The Fux Category

**Definition 2.6.** The *Fux Category* $\mathcal{F}$ is the free category on the Fux Quiver $Q$. Its objects are consonant intervals, and its morphisms are finite paths of Fux-valid transitions.

## 3. Main Results

### 3.1 Consonant-Dissonant Partition

**Theorem 3.1** (Consonant-Dissonant Partition). $\mathbb{Z}/12\mathbb{Z}$ partitions into the consonant set $C = \{0,3,4,7,8,9\}$ and the dissonant set $D = \{1,2,5,6,10,11\}$, each of cardinality 6.

*Proof.* By enumeration (verified by `decide` in Lean). □

### 3.2 Inversion Asymmetry

**Definition 3.2.** The *interval inversion* is the map $\iota: n \mapsto (12-n) \bmod 12$ on $\mathbb{Z}/12\mathbb{Z}$.

**Theorem 3.3** (Inversion Asymmetry). The consonant set $C$ is NOT closed under interval inversion: $\iota(7) = 5 \notin C$.

*Proof.* Direct computation. The perfect fifth (7) inverts to the perfect fourth (5), which is dissonant in two-voice counterpoint. □

**Theorem 3.4** (Imperfect Inversion Closure). The imperfect consonant set $\{3,4,8,9\}$ IS closed under $\iota$: $\iota(3) = 9$, $\iota(4) = 8$.

*Proof.* By enumeration. □

**Remark 3.5.** The asymmetry is confined to perfect consonances. The perfect fourth anomaly — where the fourth is consonant in chords of three or more voices but dissonant in two-voice counterpoint — has its precise algebraic counterpart in Theorems 3.3 and 3.4.

### 3.3 Transition Counting

**Theorem 3.6** (Transition Count). Of 144 total labeled transitions, exactly 132 are Fux-valid and 12 are forbidden.

*Proof.* The forbidden transitions are $\{(s, t, \text{parallel}) : s \in C, t \in \{0, 7\}\}$, giving $|C| \times |\{0,7\}| = 6 \times 2 = 12$. □

**Theorem 3.7** (Adjacency Dichotomy). For any source $s$ and target $t$, the number of valid motion types is:
$$\text{transitionCount}(s, t) = \begin{cases} 3 & \text{if } t \text{ is perfect} \\ 4 & \text{if } t \text{ is imperfect} \end{cases}$$

*Proof.* If $t$ is imperfect, all 4 motion types are valid (no constraint applies). If $t$ is perfect, parallel is forbidden, leaving 3. □

### 3.4 Regularity Properties

**Theorem 3.8** (Uniform Outgoing). Every consonant interval has exactly 22 valid outgoing transitions: $\text{out}(s) = 4 \times 4 + 3 \times 2 = 22$.

**Theorem 3.9** (Imperfect Advantage). Every imperfect consonance has 24 valid incoming transitions, while every perfect consonance has only 18. The ratio is $\frac{24}{18} = \frac{4}{3}$.

*Proof.* Incoming count for target $t$: if $t$ is imperfect, all $6 \times 4 = 24$ transitions are valid. If $t$ is perfect, $6 \times 3 = 18$ (parallel forbidden from each source). □

### 3.5 Composition Preservation

**Theorem 3.10** (Composition Preservation). If $t_2$ is Fux-valid, then for any $t_1$, the composition $t_1 \circ t_2$ (with composed motion type) is also Fux-valid.

*Proof.* The composed motion is $m_1 \circ m_2$, where the composition operation on motion types satisfies: $m_1 \circ m_2 = \text{parallel}$ iff $m_1 = m_2 = \text{parallel}$. If $t_2$ is valid and targets a perfect consonance, then $m_2 \neq \text{parallel}$, so $m_1 \circ m_2 \neq \text{parallel}$. If $t_2$ targets an imperfect consonance, validity is automatic. □

**Corollary 3.11.** The Fux Category $\mathcal{F}$ is well-defined: it is the path category of the Fux Quiver.

### 3.6 Spectral Completeness

**Theorem 3.12** (Spectral Completeness). The set of pairwise differences $\{a - b \bmod 12 : a, b \in C\}$ equals all of $\mathbb{Z}/12\mathbb{Z}$.

*Proof.* By enumeration: the 36 pairwise differences include all 12 residues. □

### 3.7 Generation

**Theorem 3.13** (Generation). The additive subgroup of $\mathbb{Z}/12\mathbb{Z}$ generated by $C = \{0, 3, 4, 7, 8, 9\}$ is $\mathbb{Z}/12\mathbb{Z}$ itself.

*Proof.* Since $4, 3 \in C$, we have $4 - 3 = 1$ in the generated subgroup. Since $1$ generates $\mathbb{Z}/12\mathbb{Z}$, the result follows. □

### 3.8 Tritone Uniqueness

**Theorem 3.14** (Tritone Uniqueness). The tritone (6 semitones) is the unique non-zero element of $\mathbb{Z}/12\mathbb{Z}$ that is both self-inverse ($\iota(6) = 6$) and dissonant ($6 \notin C$).

*Proof.* The self-inverse elements are $\{0, 6\}$ (solutions to $2n \equiv 0 \pmod{12}$). Of these, only 6 is non-zero, and $6 \notin C$. □

### 3.9 Forbidden Transition Characterization

**Theorem 3.15** (Forbidden Characterization). A transition $(s, t, m)$ is forbidden iff $t$ is perfect and $m$ is parallel. Every forbidden transition targets either the unison or the perfect fifth.

### 3.10 Diatonic Completeness

**Theorem 3.16** (Diatonic Intervallical Completeness). The C major diatonic scale $\{0,2,4,5,7,9,11\} \subset \mathbb{Z}/12\mathbb{Z}$ is intervallically complete: its pairwise difference set covers all of $\mathbb{Z}/12\mathbb{Z}$.

## 4. The PEGB Analysis

### 4.1 Inversion Asymmetry (PEGB)

- **Proof**: Machine-verified; `inversion_asymmetry` in Lean.
- **Example**: $\iota(7) = 5 \notin C$. The perfect fifth inverts to the dissonant perfect fourth.
- **Generalization**: For any $n > 2$, define consonance in $\mathbb{Z}/n\mathbb{Z}$ by a subset $C_n$. The inversion closure property $\iota(C_n) \subseteq C_n$ depends on the specific consonance theory. In the Pythagorean system (based on 3:2 ratios), this asymmetry persists for all even $n \geq 12$.
- **Boundary**: In 24-TET (quarter tones), the inversion of the "fifth" (14 quarter-tones ≈ 7 semitones) is 10 quarter-tones, a different interval class. The asymmetry may or may not persist depending on which intervals are classified as consonant.

### 4.2 Composition Preservation (PEGB)

- **Proof**: `fux_composition_valid` verified by `native_decide` over all $144 \times 144$ pairs.
- **Example**: A contrary-motion step to a fifth, followed by an oblique step to a third, composes to a valid contrary step from the source to the third.
- **Generalization**: Replace the Fux constraint with ANY constraint of the form "motion type $m$ is forbidden for targets in set $T \subseteq C$." The composition preservation holds whenever the motion composition table satisfies: $m_1 \circ m_2 \in F \Rightarrow m_2 \in F$, where $F$ is the set of forbidden motions. This is equivalent to saying each forbidden motion is a right-ideal element of the motion monoid.
- **Boundary**: If we add the stronger "no similar motion to a perfect consonance" rule (forbidding both parallel AND similar), composition preservation FAILS: similar ∘ similar = similar, and the constraint is not absorbed.

### 4.3 Adjacency Dichotomy (PEGB)

- **Proof**: `adjacency_dichotomy` proved by case analysis on `isPerfect`.
- **Example**: The row for "major third → X" is [3, 4, 4, 3, 4, 4].
- **Generalization**: For $k$ forbidden motion types targeting $p$ perfect consonances among $c$ total consonant intervals, the adjacency matrix has entries from $\{|\text{Motion}| - k, |\text{Motion}|\}$ and uniform outgoing degree $c \cdot |\text{Motion}| - k \cdot p$.
- **Boundary**: If ALL motion types were forbidden for perfect targets ($k = 4$), the matrix would have entries from $\{0, 4\}$ and the quiver would disconnect into two components: perfect and imperfect.

### 4.4 Spectral Completeness (PEGB)

- **Proof**: `consonant_spectrum_complete` verified by `native_decide`.
- **Example**: $9 - 4 = 5$, $4 - 3 = 1$, $3 - 0 = 3$ — each difference fills a slot.
- **Generalization**: A subset $S \subseteq \mathbb{Z}/n\mathbb{Z}$ is spectrally complete iff $|S| \geq \lceil\sqrt{n}\rceil$ (pigeonhole gives this as a sufficient condition for large $|S|$, though not necessary). For $|S| = 6$ in $\mathbb{Z}/12\mathbb{Z}$, spectral completeness is not guaranteed (consider $\{0,1,2,3,4,5\}$ — differences only give $\{0,1,2,3,4,5,7,8,9,10,11\}$, which IS complete). Determining the minimum $|S|$ for spectral completeness in $\mathbb{Z}/n\mathbb{Z}$ is related to additive number theory.
- **Boundary**: The pentatonic scale $\{0, 2, 4, 7, 9\}$ (5 elements) also achieves spectral completeness. But $\{0, 1, 2, 3\}$ (4 elements) does not: its difference set is $\{0, 1, 2, 3, 9, 10, 11\}$, missing $\{4, 5, 6, 7, 8\}$.

## 5. Falsifiable Conjecture

**Conjecture 5.1** (Consonance Persistence under Temperament Extension). For any even $n \geq 12$ and the "natural consonant set" $C_n$ defined by intervals with frequency ratios of small-integer form (complexity ≤ 10), the Fux quiver of $C_n$ (forbidding parallel motion to perfect consonances) satisfies:
1. The adjacency matrix remains $\{k-1, k\}$-valued for some $k$.
2. Composition preservation holds.

**Test**: Compute $C_n$ for $n \in \{12, 19, 24, 31, 53\}$ using just-intonation frequency ratio approximations. For each, enumerate all transitions and check properties (1) and (2). This can be done computationally in O(|C_n|² × |Motion|) time.

## 6. Connections to the Catalog

Our work connects to:

1. **`root_triple_consonant_intervals`** (Pythagorean/HarmonicMusicTheory): The consonance of intervals derived from the (3,4,5) triple (ratios 4:3 = perfect fourth, 5:4 = major third) directly feeds our consonant set. The major third (4 semitones) and perfect fourth (5 semitones) are the pair that generates the inversion asymmetry.

2. **`MusicalCounterpoint`** (Algebra): The existing formalization treats counterpoint as a constraint satisfaction problem with an L¹ cost function. Our categorical approach complements this by studying the *transition structure* rather than the *optimization problem*.

3. **`finished_rules_eq_theory`** (Bridges/KnuthBendixCompletion): The Fux rules can be viewed as a rewriting system on interval sequences, with the forbidden transitions as reduction rules. The completion procedure could potentially be applied to derive additional constraints.

## 7. Discussion

The Fux Category reveals that the rules of first-species counterpoint are not arbitrary pedagogical conventions but encode precise algebraic structure. The {3,4}-valued adjacency matrix, the composition preservation theorem, and the inversion asymmetry are three faces of the same phenomenon: perfect consonances are acoustically special, and this specialness creates exactly one algebraic irregularity in an otherwise uniform structure.

The 22-22 outgoing regularity is particularly striking: despite the asymmetric constraint (which treats targets differently based on perfectness), every *source* interval sees exactly the same number of available transitions. This outgoing regularity is a form of "fairness" built into the counterpoint system — no starting interval is more constrained than any other.

## 8. Future Work

See FUTURE_DIRECTIONS.md for detailed research directions. Key open questions:

1. **Higher-species counterpoint**: How does the categorical structure change when we add passing tones (second species), suspensions (fourth species), or florid counterpoint (fifth species)?
2. **Multi-voice extension**: With $n > 2$ voices, the interval space becomes $C^{\binom{n}{2}}$, and the constraints become more complex. Does composition preservation survive?
3. **Non-Western consonance**: Different musical traditions define consonance differently. How does the category theory adapt?
4. **Spectral geometry**: The Fux Quiver defines a directed graph. What are its spectral properties (eigenvalues of the adjacency matrix)? How do they relate to harmonic properties?

## References

1. Fux, J.J. *Gradus ad Parnassum* (1725).
2. Mazzola, G. *The Topos of Music* (2002).
3. Tymoczko, D. *A Geometry of Music* (2011).
4. Forte, A. *The Structure of Atonal Music* (1973).
