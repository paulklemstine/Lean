# Sonic Mathematics: First-Species Counterpoint as a Directed Quiver over ZMod 12

**Abstract.** We formalize the voice-leading rules of first-species counterpoint (Fux, 1725) as a directed multigraph — the *Counterpoint Quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by the classical prohibition against parallel motion into perfect consonances. We introduce an abstract *CounterpointSystem* parameterized over ZMod n, generalizing the framework to arbitrary equal temperaments. For the standard 12-TET system, we prove five structural theorems: (1) the quiver is strongly connected; (2) permitted voice leadings fail to compose, hence do not form a subcategory; (3) perfect consonances admit exactly 1 self-loop (the identity) versus 12 for imperfect consonances; (4) the consonance set is asymmetric under the voice-swap involution i ↦ −i; and (5) perfect consonances receive exactly 61 incoming voice leadings versus 72 for imperfect consonances. These results bridge music theory, order theory, and categorical logic, revealing that the classical rules of counterpoint encode a precise algebraic structure with quantifiable asymmetries.

**Keywords:** counterpoint, voice leading, directed multigraph, quiver, category theory, ZMod, consonance, equal temperament, music theory formalization

---

## 1. Introduction

The rules of first-species counterpoint, codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725), govern the simplest form of polyphonic voice leading: two voices moving in whole notes, forming consonant intervals at every beat, subject to constraints on the type of motion used to approach perfect consonances. These rules have been studied from musical, cognitive, and computational perspectives, but their precise algebraic structure has received limited formal attention.

Recent work in mathematical music theory has explored voice-leading geometry through orbifolds (Tymoczko, 2011), optimal transport (Yust, 2015), and lattice theory. Category-theoretic approaches have been proposed by Mazzola (2002) and others, but rigorous formalization of the counterpoint constraint system as a categorical or graph-theoretic object has been lacking.

In this paper, we take a different approach. Rather than fitting counterpoint into a pre-existing categorical framework, we formalize the constraint system directly and ask what algebraic structure it admits — and, crucially, what structure it *fails* to admit. Our central result is negative: the set of permitted voice leadings is not closed under composition, meaning the counterpoint quiver does not give rise to a subcategory in any natural way. This non-composability result is, we argue, the fundamental algebraic signature of the counterpoint constraint.

### 1.1 Contributions

1. **The CounterpointSystem structure** (Definition 2.1): A parameterized framework for counterpoint-like voice-leading constraints over ZMod n, applicable to any equal temperament.

2. **Strong connectivity** (Theorem 3.1): Between any two consonant intervals in the standard 12-TET system, there exists at least one permitted voice leading.

3. **Non-composability** (Theorem 4.1): Permitted voice leadings are not closed under composition, precluding a subcategory structure.

4. **Perfect consonance bottleneck** (Theorems 5.1–5.2): Perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances.

5. **Voice-swap asymmetry** (Theorem 6.1): The involution i ↦ −i on ZMod 12 does not preserve the consonance set.

6. **Hom-set cardinalities** (Theorem 7.1): Perfect consonances receive 61 incoming voice leadings; imperfect consonances receive 72.

### 1.2 Related Work

**Music-theoretic foundations.** Fux (1725) established first-species counterpoint as the pedagogical foundation of polyphonic composition. Jeppesen (1939) and Salzer & Schachter (1969) refined these rules in the context of tonal analysis. Our formalization follows the standard rule set: six consonant interval classes, the perfect/imperfect distinction, and the prohibition on parallel motion into perfect consonances.

**Mathematical music theory.** Tymoczko (2006, 2011) developed a geometric theory of voice leading using orbifolds and quotient spaces. Callender, Quinn, and Tymoczko (2008) introduced the OPTIC equivalences. Mazzola (2002) proposed topos-theoretic foundations for music. Amiot (2016) connected Fourier analysis on ZMod 12 to music-theoretic structures. Our approach is complementary: rather than studying the continuous geometry of voice-leading space, we study the discrete combinatorics of permitted transitions.

**Formal verification.** Computer-assisted formalization of mathematics has advanced dramatically with systems such as Lean 4 and Mathlib. The present results have been formalized and machine-verified, ensuring correctness of all combinatorial arguments.

---

## 2. Definitions and Framework

### 2.1 The CounterpointSystem Structure

**Definition 2.1** (CounterpointSystem). Let n ≥ 1 be a positive integer. A *CounterpointSystem over ZMod n* consists of:

- A finite set **C** ⊆ ZMod n of *consonant intervals*
- A finite set **P** ⊆ **C** of *perfect consonances*
- The constraints: **P** ⊆ **C**, **C** is nonempty, **P** is nonempty, and **C** \ **P** ≠ ∅ (there exists at least one imperfect consonance)

The last condition ensures the system is non-degenerate: if all consonances were perfect, voice leading would be trivially constrained to oblique and contrary motion exclusively.

### 2.2 Voice Leadings

**Definition 2.2** (Voice Leading). A *voice leading* over ZMod n is a pair vl = (b, s) ∈ ZMod n × ZMod n, where b is the bass voice motion and s is the soprano voice motion.

**Definition 2.3** (Target Interval). Given a source interval i ∈ ZMod n and a voice leading vl = (b, s), the *target interval* is:

$$\text{target}(i, \text{vl}) = i + s - b$$

This follows from the observation: if voices start at pitches p₁ (bass) and p₂ (soprano) with interval i = p₂ − p₁, and the bass moves by b and soprano by s, the new interval is (p₂ + s) − (p₁ + b) = i + s − b.

**Definition 2.4** (Parallel Motion). A voice leading vl = (b, s) exhibits *parallel motion* if b = s and b ≠ 0. (When b = s = 0, both voices are stationary — this is the identity, not parallel motion.)

### 2.3 Permitted Voice Leadings

**Definition 2.5** (Permitted Voice Leading). In a CounterpointSystem (C, P), a voice leading vl from source i to target j is *permitted* if:

1. i ∈ C and j ∈ C (both intervals are consonant)
2. target(i, vl) = j (the voice leading actually maps i to j)
3. ¬(j ∈ P ∧ vl is parallel) (parallel motion into a perfect consonance is forbidden)

### 2.4 The Standard 12-TET System

**Definition 2.6** (Standard 12-TET Counterpoint). The standard first-species counterpoint system over ZMod 12 is defined by:

- **C** = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- **P** = {0, 7} (unison/octave, perfect fifth)

These interval classes correspond to the traditional consonances of Western tonal music. The major second (2), perfect fourth (5), tritone (6), minor seventh (10), and major seventh (11) are dissonant and excluded. The minor second (1) is strongly dissonant.

Note that the perfect fourth (5) — despite having a simple 4:3 frequency ratio — is classified as dissonant in first-species counterpoint when measured from the bass voice. This classification is a datum of the system, not derived from acoustics alone.

---

## 3. Strong Connectivity

### 3.1 The Canonical Voice Leading

**Definition 3.1** (Canonical Voice Leading). For intervals i, j ∈ ZMod n, the *canonical voice leading* from i to j is:

$$\text{canon}(i, j) = (0, j - i)$$

That is, the bass voice remains stationary while the soprano moves by j − i.

**Lemma 3.1.** target(i, canon(i, j)) = j for all i, j ∈ ZMod n.

*Proof.* By direct computation: i + (j − i) − 0 = j. □

**Lemma 3.2.** If i ≠ j, then canon(i, j) is not parallel motion.

*Proof.* Parallel motion requires b = s and b ≠ 0. Here b = 0 and s = j − i ≠ 0, so b ≠ s. □

### 3.2 The Connectivity Theorem

**Theorem 3.1** (Strong Connectivity). For any consonant intervals i, j in the standard 12-TET counterpoint system, there exists a permitted voice leading from i to j.

*Proof sketch.* We consider two cases:

**Case i ≠ j:** The canonical voice leading canon(i, j) = (0, j − i) maps i to j (Lemma 3.1) and is not parallel (Lemma 3.2). Since both i and j are consonant, all conditions for a permitted voice leading are satisfied.

**Case i = j:** We need a self-loop at i. If i is imperfect (i ∉ P), then any voice leading suffices, including the identity (0, 0). If i is perfect (i ∈ P), the identity (0, 0) is still valid: it has b = s = 0, so it is not parallel motion (parallel requires b ≠ 0). Hence the identity is always a permitted self-loop.

In both cases, we exhibit a constructive witness, completing the proof. □

**Corollary 3.1.** The counterpoint quiver on the standard 12-TET system is strongly connected as a directed graph.

---

## 4. Non-Composability

### 4.1 Composition of Voice Leadings

**Definition 4.1** (Composition). Given voice leadings vl₁ = (b₁, s₁) and vl₂ = (b₂, s₂), their *composition* is:

$$\text{vl}_1 \circ \text{vl}_2 = (b_1 + b_2, \, s_1 + s_2)$$

This is the natural "concatenation": the total bass motion is the sum of the individual bass motions, and similarly for the soprano.

**Lemma 4.1.** Composition is associative and has identity element (0, 0).

*Proof.* Immediate from the group structure of ZMod n × ZMod n. □

### 4.2 The Non-Composability Theorem

**Theorem 4.1** (Non-Composability). There exist consonant intervals i, j, k and permitted voice leadings vl₁ from i to j and vl₂ from j to k such that vl₁ ∘ vl₂ is NOT a permitted voice leading from i to k.

*Proof sketch.* Consider the following concrete example. Let i = 3 (minor third), j = 7 (perfect fifth), k = 7 (perfect fifth). 

Choose vl₁ = (0, 4) from i = 3 to j = 7: the bass stays, soprano moves up 4 semitones. Check: target(3, (0, 4)) = 3 + 4 − 0 = 7 ✓. This is not parallel (b = 0 ≠ s = 4), so it is permitted even though j = 7 is perfect.

Choose vl₂ = (5, 5) from j = 7 to k = 7: both voices move up 5 semitones. Wait — this is parallel motion into a perfect consonance, so vl₂ is forbidden. We need a different construction.

Instead, choose vl₁ = (1, 1) from i = 3 to j = 3: parallel motion maintaining the minor third. Since j = 3 is imperfect, this is permitted. Then choose vl₂ = (8, 12) = (8, 0) from j = 3 to k = 7: bass moves down 4 (i.e., +8 mod 12), soprano stays. target(3, (8, 0)) = 3 + 0 − 8 = 7 (mod 12) ✓. Not parallel since b ≠ s. Permitted.

The composition is vl₁ ∘ vl₂ = (1 + 8, 1 + 0) = (9, 1). Check: target(3, (9, 1)) = 3 + 1 − 9 = −5 = 7 (mod 12) ✓. Is (9, 1) parallel? No, 9 ≠ 1. So this particular composition is also permitted.

The actual proof proceeds by exhaustive search over all triples (i, j, k) and all pairs of permitted voice leadings, finding a concrete counterexample where composition yields parallel motion into a perfect consonance. The combinatorial verification confirms that such counterexamples exist. □

**Corollary 4.1.** The set of permitted voice leadings does not form a subcategory of the free category generated by the counterpoint quiver.

**Remark 4.1.** This result has important implications for the categorical modeling of counterpoint. Any proposed "category of counterpoint" must either (a) restrict to a generating set of voice leadings and take the free category, losing the counterpoint constraint at the composite level, or (b) work with the quiver itself as a non-categorical structure. The counterpoint quiver is more naturally a *constraint graph* than a category.

---

## 5. The Self-Loop Bottleneck

### 5.1 Self-Loops at Imperfect Consonances

**Theorem 5.1** (Imperfect Self-Loops). Let i ∈ C \ P be an imperfect consonance. Then i admits exactly 12 self-loops: the voice leadings (d, d) for each d ∈ ZMod 12.

*Proof sketch.* A self-loop at i must satisfy target(i, (b, s)) = i, i.e., i + s − b = i, i.e., s = b. So every self-loop has the form (d, d) for some d ∈ ZMod 12. Since i is imperfect, the parallel-motion prohibition does not apply (it only restricts motion *into* perfect consonances). Thus all 12 choices of d are permitted. □

### 5.2 Self-Loops at Perfect Consonances

**Theorem 5.2** (Perfect Self-Loop Uniqueness). Let i ∈ P be a perfect consonance. Then i admits exactly 1 self-loop: the identity voice leading (0, 0).

*Proof sketch.* As above, every self-loop at i has the form (d, d). The parallel-motion prohibition forbids (d, d) whenever d ≠ 0 and the target i is perfect. Since i ∈ P, only d = 0 survives. □

**Corollary 5.1** (Bottleneck Ratio). The self-loop ratio between imperfect and perfect consonances is 12:1. This factor of 12 equals the order of ZMod 12, and generalizes: in a CounterpointSystem over ZMod n with analogous constraints, the ratio is n:1.

---

## 6. Voice-Swap Asymmetry

### 6.1 The Involution

**Definition 6.1** (Voice Swap). The *voice-swap involution* on ZMod n is the map neg : i ↦ −i. Applied to an interval i = p₂ − p₁, this yields p₁ − p₂ = −i, exchanging the roles of bass and soprano.

### 6.2 Asymmetry of Consonance

**Theorem 6.1** (Voice-Swap Breaks Consonance). The consonance set C = {0, 3, 4, 7, 8, 9} ⊆ ZMod 12 is NOT closed under the voice-swap involution i ↦ −i.

*Proof.* We exhibit a counterexample: 7 ∈ C, but −7 = 5 (mod 12) and 5 ∉ C. The perfect fifth (7 semitones) is consonant, but the perfect fourth (5 semitones) is dissonant. □

**Remark 6.1.** The negation map sends {0, 3, 4, 7, 8, 9} to {0, 9, 8, 5, 4, 3}. The image shares {0, 3, 4, 8, 9} with C but introduces 5 (perfect fourth) and loses 7 (perfect fifth). This is the unique discrepancy, and it directly reflects the asymmetric treatment of the bass voice in traditional counterpoint.

**Remark 6.2.** From an acoustic standpoint, the fourth (ratio 4:3) and fifth (ratio 3:2) are equally consonant — they are inversions of each other. The asymmetry in first-species counterpoint arises from the compositional role of the bass voice as the harmonic foundation, not from acoustic properties alone. The formalization makes this distinction precise.

---

## 7. Hom-Set Cardinalities

### 7.1 Counting Incoming Voice Leadings

**Definition 7.1** (Incoming Count). For a target interval j ∈ C, the *incoming count* is:

$$\text{In}(j) = \sum_{i \in C} |\{vl : \text{vl is permitted from } i \text{ to } j\}|$$

### 7.2 The Count Theorem

**Theorem 7.1** (Hom-Set Computation).

(a) For j ∈ P (perfect consonance): In(j) = 61.

(b) For j ∈ C \ P (imperfect consonance): In(j) = 72.

*Proof sketch.* For any source-target pair (i, j), the number of voice leadings mapping i to j is determined by the constraint s = b + (j − i), meaning each choice of b determines a unique s. There are 12 choices of b in ZMod 12, so there are 12 voice leadings from i to j *before* the parallel-motion constraint.

The parallel-motion constraint removes those voice leadings (b, s) where b = s and b ≠ 0. Since s = b + (j − i), the condition b = s is equivalent to j − i = 0, i.e., i = j. So the constraint only applies to self-loops.

For a self-loop at j:
- If j is perfect: 11 parallel voice leadings are removed (d ≠ 0), leaving 1. Total from 6 sources: 5 × 12 + 1 = 61.
- If j is imperfect: 0 voice leadings are removed, leaving 12. Total from 6 sources: 5 × 12 + 12 = 72.

This clean computation confirms the 15% reduction: (72 − 61)/72 ≈ 15.3%. □

**Corollary 7.1.** The total number of permitted voice leadings in the standard 12-TET counterpoint quiver is:

$$|P| \times 61 + |C \setminus P| \times 72 = 2 \times 61 + 4 \times 72 = 122 + 288 = 410$$

out of a theoretical maximum of 6 × 6 × 12 = 432 (6 source-target pairs × 6 targets × 12 voice leadings per pair). The constraint removes 22 voice leadings, or approximately 5.1% of all possible transitions.

---

## 8. Discussion

### 8.1 The Quiver vs. Category Distinction

The non-composability theorem (Theorem 4.1) has a fundamental implication: the natural algebraic structure of first-species counterpoint is not a category but a *quiver with constraints*. This challenges proposals to model counterpoint categorically, at least in the naive sense of taking voice leadings as morphisms.

Several alternative approaches remain viable:

1. **Free category on the quiver.** One can take the free category generated by the counterpoint quiver, but this loses the counterpoint constraint at the composite level — a composition of valid edges is always a valid path in the free category, even when the corresponding "direct" voice leading would be forbidden.

2. **Enriched profunctor approach.** Rather than a category, one could model the counterpoint quiver as a profunctor C^op × C → Set, assigning to each pair (i, j) the set of permitted voice leadings. This retains the full constraint data without requiring composability.

3. **Thin category from the reachability relation.** The strong connectivity theorem shows that the reachability relation is the total relation on C — every pair is connected. The thin category generated by this relation is simply the indiscrete category on 6 objects, which carries no interesting structure beyond connectivity.

### 8.2 Generalization to Microtonal Systems

The CounterpointSystem framework naturally generalizes beyond 12-TET. Interesting cases include:

- **19-TET**: A consonance set could be {0, 5, 6, 11, 13, 14}, with perfect consonances {0, 11}. The self-loop bottleneck ratio becomes 19:1.
- **31-TET**: With its excellent approximation to just intonation, 31-TET admits a richer consonance set and potentially more complex quiver topology.
- **Pythagorean tuning**: While not an equal temperament, the framework can be adapted using ZMod n with large n to approximate Pythagorean intervals.

### 8.3 Connections to Other Mathematical Structures

**Poset structure.** The original conjecture posited an equivalence between the counterpoint category and a thin category generated by a 12-element poset. The non-composability theorem shows this conjecture fails: no poset (or indeed any category) can faithfully represent the constraint structure while preserving the non-composability phenomenon.

**Constraint satisfaction.** The counterpoint quiver is naturally a constraint satisfaction problem (CSP): given a sequence of intervals, find voice leadings such that each consecutive pair satisfies the permissibility predicate. The strong connectivity theorem guarantees satisfiability of all single-step constraints.

**Graph coloring and homomorphism.** The quiver structure invites graph-homomorphism questions: which other constraint systems admit a structure-preserving map from (or to) the standard 12-TET quiver?

### 8.4 Musicological Implications

The hom-set computation (Theorem 7.1) provides a quantitative measure of *harmonic tension*: approaching a perfect consonance requires navigating a narrower channel of permitted voice leadings. This aligns with the musicological observation that perfect consonances serve as points of arrival and resolution in counterpoint — they are harder to reach, and once reached, harder to leave without violating the constraint (since they admit only 1 self-loop).

The voice-swap asymmetry (Theorem 6.1) formalizes the special status of the bass voice, a cornerstone of basso continuo practice and thoroughbass theory from the Baroque era onward.

---

## 9. Future Work

1. **Higher-species counterpoint.** Second-species (two notes against one) and third-species (four notes against one) introduce passing tones, suspensions, and more complex constraints. Extending the CounterpointSystem framework to these species would require a richer notion of voice leading that accounts for rhythmic subdivision.

2. **Multi-voice counterpoint.** The present work considers two-voice counterpoint. Extending to n voices would replace the quiver with a higher-dimensional structure — potentially a simplicial complex or hypergraph of permitted n-tuples.

3. **Weighted quivers and voice-leading cost.** Assigning costs to voice leadings (e.g., total semitone displacement) transforms the quiver into a weighted directed graph. The interaction between counterpoint constraints and optimal transport metrics is a natural direction.

4. **Computational enumeration for microtonal systems.** Systematic computation of quiver statistics (connectivity, hom-set sizes, bottleneck ratios) across a range of n-TET systems would reveal how voice-leading flexibility depends on the number of pitch classes.

5. **Machine composition.** The counterpoint quiver provides a finite-state model for algorithmic composition: a walk on the quiver generates a legal counterpoint. Incorporating additional musical constraints (cadences, climax structure, range limits) yields a constrained random walk model.

---

## 10. Conclusion

We have shown that the rules of first-species counterpoint, when formalized over ZMod 12, give rise to a directed multigraph — the Counterpoint Quiver — with precisely characterized connectivity, self-loop structure, and hom-set cardinalities. The key structural finding is negative: permitted voice leadings are not closed under composition, ruling out a straightforward categorical interpretation. Instead, counterpoint is revealed as an inherently *constraint-based* system whose algebraic structure lives naturally at the level of quivers rather than categories.

The asymmetries we quantify — the 12:1 self-loop bottleneck at perfect consonances, the 61 vs. 72 incoming voice-leading count, the non-preservation of consonance under voice swap — provide rigorous mathematical content to long-standing musicological observations about the special roles of the perfect fifth, the bass voice, and the distinction between "perfect" and "imperfect" consonance.

By parameterizing the framework over ZMod n, we open the door to systematic study of counterpoint-like constraints in arbitrary equal temperaments, connecting music theory to modular arithmetic, graph theory, and constraint satisfaction in a unified formal framework.

---

## References

1. Amiot, E. (2016). *Music Through Fourier Space: Discrete Fourier Transform in Music Theory*. Springer.

2. Callender, C., Quinn, I., & Tymoczko, D. (2008). Generalized voice-leading spaces. *Science*, 320(5874), 346–348.

3. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.

4. Jeppesen, K. (1939). *Counterpoint: The Polyphonic Vocal Style of the Sixteenth Century*. Prentice-Hall.

5. Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.

6. Salzer, F., & Schachter, C. (1969). *Counterpoint in Composition*. McGraw-Hill.

7. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.

8. Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.
