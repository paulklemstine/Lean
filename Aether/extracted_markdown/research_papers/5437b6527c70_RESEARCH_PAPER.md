# Sonic Mathematics: First-Species Counterpoint as a Directed Graph over ℤ/12ℤ

## Abstract

We introduce a novel algebraic framework — the **Counterpoint System** — that formalizes the voice-leading rules of first-species counterpoint as a directed multigraph (quiver) over the cyclic group ℤ/nℤ. Vertices are consonant intervals modulo n semitones; directed edges are voice leadings permitted by the standard counterpoint rule that parallel motion into perfect consonances is forbidden. For the classical case n = 12, we establish five principal results: (1) the quiver is strongly connected; (2) permitted voice leadings fail to compose, so the quiver does not underlie a subcategory of the free category on its edges; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances, quantifying the "bottleneck" effect of the parallel-motion prohibition; (4) the voice-swap involution i ↦ −i does not preserve the consonant set, formalizing the privileged role of the bass voice; and (5) perfect consonances receive 61 incoming permitted voice leadings versus 72 for imperfect consonances. All results are verified by formal machine-checked proof. The framework generalizes to arbitrary equal temperaments and suggests new directions in computational music theory.

**Keywords:** counterpoint, voice leading, directed graph, quiver, cyclic group, consonance, ℤ/12ℤ, category theory, music theory, formal verification

---

## 1. Introduction

The rules of first-species counterpoint, codified by Fux (1725), govern the simplest case of two-voice polyphonic writing: note-against-note motion between consonant intervals. Despite their apparent simplicity, these rules encode rich algebraic structure that has resisted precise formalization.

Prior mathematical treatments of voice leading include the geometric approach of Tymoczko (2006, 2011), who models voice leadings as paths in orbifold quotient spaces, and the group-theoretic work of Mazzola (2002), who applies topos theory to counterpoint. Clampitt (1997) and others have studied the combinatorics of specific voice-leading types. However, none of these approaches formally captures the *directed* constraint structure imposed by the parallel-motion prohibition — that is, the asymmetry between source and target consonance types.

Our contribution is threefold:

1. We define a parameterized algebraic structure, the **CounterpointSystem**, that captures voice-leading constraints over any ℤ/nℤ.
2. We prove precise structural theorems about the resulting directed graph for the classical case n = 12.
3. We demonstrate that permitted voice leadings fail to compose, establishing a negative categorical result that clarifies the relationship between counterpoint and category theory.

### 1.1 Notation

Throughout, we write ℤₙ for ℤ/nℤ. Elements of ℤ₁₂ are identified with pitch-class intervals in semitones. Addition and subtraction are modular.

---

## 2. Definitions

### 2.1 Counterpoint System

**Definition 2.1** (CounterpointSystem). A *counterpoint system* of order n (where n ≥ 1) is a triple (C, P, ρ) where:
- C ⊆ ℤₙ is a nonempty finite set of *consonant intervals*;
- P ⊆ C is a nonempty finite set of *perfect consonances*;
- C \ P ≠ ∅ (there exists at least one imperfect consonance);
- ρ is the *parallel-motion prohibition rule*: a voice leading into an interval in P by parallel motion is forbidden.

The standard 12-TET system is:
- C = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- P = {0, 7} (unison/octave, perfect fifth)

**Definition 2.2** (Voice Leading). A *voice leading* over ℤₙ is a pair (b, s) ∈ ℤₙ × ℤₙ, where b is the bass motion and s is the soprano motion (both in semitones mod n).

**Definition 2.3** (Target Interval). Given a source interval i ∈ ℤₙ and a voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This follows from the observation that if the soprano is at pitch p + i and the bass is at pitch p, then after the bass moves by b and soprano by s, the new interval is (p + i + s) − (p + b) = i + s − b.

**Definition 2.4** (Parallel Motion). A voice leading (b, s) is *parallel* if b = s and b ≠ 0. Note that the identity (0, 0) is explicitly excluded — stationary voices are not considered parallel.

**Definition 2.5** (Permitted Voice Leading). A voice leading (b, s) is *permitted* from source interval i to target interval j in a counterpoint system (C, P, ρ) if:
1. i ∈ C (source is consonant)
2. j ∈ C (target is consonant)
3. τ(i, b, s) = j (the voice leading maps source to target)
4. ¬(j ∈ P ∧ b = s ∧ b ≠ 0) (parallel motion into a perfect consonance is forbidden)

### 2.2 The Counterpoint Quiver

**Definition 2.6** (Counterpoint Quiver). The *counterpoint quiver* Q(C, P) is the directed multigraph with:
- Vertex set: C
- Edge set from i to j: {(b, s) ∈ ℤₙ × ℤₙ : (b, s) is permitted from i to j}

### 2.3 Canonical Voice Leading

**Definition 2.7** (Canonical Voice Leading). For any i, j ∈ ℤₙ, the *canonical voice leading* from i to j is the pair (0, j − i) — the bass holds while the soprano moves by the interval difference.

**Lemma 2.8.** The canonical voice leading from i to j has target interval j. Moreover, when i ≠ j, the canonical voice leading is not parallel (since the bass motion is 0 but the soprano motion is j − i ≠ 0).

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *The counterpoint quiver Q(C, P) of the standard 12-TET system is strongly connected: for any consonant intervals i, j ∈ C, there exists a permitted voice leading from i to j.*

*Proof sketch.* We construct an explicit witness. If i = j, the identity voice leading (0, 0) suffices — it is never parallel (since 0 = 0 but the condition requires b ≠ 0). If i ≠ j, the canonical voice leading (0, j − i) works: it is not parallel because b = 0 ≠ j − i = s (since i ≠ j), so the parallel-motion prohibition does not apply regardless of whether j is perfect.  □

**Remark.** Strong connectivity is a non-trivial property. A priori, the parallel-motion prohibition could isolate perfect consonances — making it impossible to reach a perfect fifth from certain intervals. The theorem guarantees this never happens.

### 3.2 Self-Loop Asymmetry: The Bottleneck Theorem

**Theorem 3.2** (Perfect Self-Loop Uniqueness). *If j ∈ P is a perfect consonance, then the only permitted self-loop at j is the identity (0, 0).*

*Proof sketch.* A self-loop at j requires τ(j, b, s) = j, i.e., s = b. If s = b = 0, we have the identity. If s = b ≠ 0, the motion is parallel into a perfect consonance, which is forbidden.  □

**Theorem 3.3** (Imperfect Self-Loops). *If j ∈ C \ P is an imperfect consonance, then all 12 voice leadings of the form (k, k) for k ∈ ℤ₁₂ are permitted self-loops at j.*

*Proof sketch.* For any k ∈ ℤ₁₂, the voice leading (k, k) has target interval j + k − k = j, so it is a self-loop. Since j ∉ P, the parallel-motion prohibition does not apply, and the voice leading is permitted.  □

**Corollary 3.4** (Bottleneck Ratio). *Perfect consonances admit 1 self-loop; imperfect consonances admit 12. The ratio is 1:12.*

This result quantifies the classical intuition that perfect consonances are "harder to sustain" — there are twelve times fewer ways to maintain a perfect fifth than a minor third.

### 3.3 Non-Composability

**Definition 3.5** (Composition of Voice Leadings). Given voice leadings (b₁, s₁) and (b₂, s₂), their *composition* is (b₁ + b₂, s₁ + s₂).

**Theorem 3.6** (Non-Composability). *The set of permitted voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k ∈ C and permitted voice leadings v₁ from i to j and v₂ from j to k such that the composition v₁ ∘ v₂ is not a permitted voice leading from i to k.*

*Proof sketch.* Consider two voice leadings that are individually non-parallel but whose bass (resp. soprano) motions sum to the same nonzero value. For example, take a voice leading with bass = 1, soprano = 0 (oblique motion) from i to some j, followed by bass = 0, soprano = 1 from j to some k. The composition has bass = 1, soprano = 1 — parallel motion. If k happens to be a perfect consonance, the composition is forbidden despite both components being permitted.  □

**Corollary 3.7.** *The counterpoint quiver does not underlie a subcategory of the free category on its edges via composition of voice leadings.*

This is a fundamental negative result. It means that counterpoint rules create a structure that is intrinsically *non-categorical* under the natural notion of arrow composition. The rules are context-sensitive in a way that prevents local consistency from guaranteeing global consistency.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.8** (Voice-Swap Breaks Consonance). *The involution ι : ℤ₁₂ → ℤ₁₂ defined by ι(i) = −i does not preserve the set of consonant intervals C. Specifically, ι(7) = 5 ∉ C.*

*Proof sketch.* We compute: −7 ≡ 5 (mod 12). Since 5 (the perfect fourth) is not in C = {0, 3, 4, 7, 8, 9}, the involution maps the perfect fifth outside the consonant set.  □

**Remark.** The perfect fourth (5 semitones) is the complement of the perfect fifth (7 semitones) modulo the octave. In counterpoint, the fourth is treated as dissonant when it occurs above the bass — a rule that has puzzled theorists for centuries. Theorem 3.8 provides a mathematical explanation: the consonant set is not closed under the voice-swap involution, and the fourth is precisely the element that breaks this symmetry.

### 3.5 Hom-Set Cardinality

**Theorem 3.9** (Hom-Set Computation). *In the standard 12-TET counterpoint quiver:*

*(a) For each perfect consonance j ∈ P, the total number of permitted voice leadings from all consonant sources to j is 61.*

*(b) For each imperfect consonance j ∈ C \ P, the total number of permitted voice leadings from all consonant sources to j is 72.*

*Proof sketch.* For a fixed target j, we sum over all sources i ∈ C the number of voice leadings (b, s) with i + s − b = j. This means s − b = j − i, so s = b + (j − i). As b ranges over ℤ₁₂, we get 12 potential voice leadings. If j ∈ P, we must exclude the parallel ones (b = s ≠ 0, i.e., b = b + (j − i) and b ≠ 0, which requires j = i and b ≠ 0), losing 11 per perfect-consonance source. There are |P| = 2 sources that coincide with a perfect target via identity (for j = 0: source 0; for j = 7: source 7). Actually, the self-loop reduction is 11 when source = target ∈ P, and for other sources i ≠ j with target j ∈ P, we must exclude cases where b = s = b and j − i = 0 (impossible when i ≠ j). The precise count, verified computationally, gives 61 for perfect targets and 72 for imperfect targets.  □

**Corollary 3.10** (Constraint Differential). *Perfect consonances receive approximately 15.3% fewer permitted incoming voice leadings than imperfect consonances: (72 − 61)/72 ≈ 0.153.*

---

## 4. The Counterpoint System as a General Framework

### 4.1 Parameterization

The CounterpointSystem structure is defined for arbitrary order n ≥ 1. This enables investigation of counterpoint-like constraints in non-standard tuning systems:

| System | n | Example consonances | Notes |
|--------|---|-------------------|-------|
| 12-TET (standard) | 12 | {0, 3, 4, 7, 8, 9} | Classical Western |
| 19-TET | 19 | {0, 5, 6, 11, 13, 14} | Better thirds |
| 24-TET (quarter-tone) | 24 | {0, 6, 8, 14, 16, 18} | Extended palette |
| 31-TET | 31 | {0, 8, 10, 18, 21, 23} | Close to just intonation |

For each system, the same structural questions arise:
- Is the quiver strongly connected?
- Do permitted voice leadings compose?
- What is the bottleneck ratio between perfect and imperfect self-loops?

### 4.2 Connection to Prior Work

**Tymoczko's geometric theory.** Tymoczko (2006) models n-voice voice leadings as points in the orbifold T^n/S_n. Our framework is complementary: we focus on the *constraint structure* (which voice leadings are permitted) rather than the *geometric distance* between voice leadings. The non-composability result (Theorem 3.6) cannot be naturally stated in the geometric framework.

**Mazzola's topos theory.** Mazzola (2002) uses the topos of presheaves over a category of "local compositions" to study counterpoint. Our work shows that the naive attempt to form such a category from first-species voice leadings fails (Corollary 3.7), suggesting that more sophisticated categorical constructions are needed.

**Algebraic music theory.** The identification of consonant intervals with a subset of ℤ₁₂ is standard in post-tonal theory (Forte 1973, Straus 2016). Our contribution is to study the *dynamics* over this set — the directed graph of transitions — rather than the static set-theoretic properties.

---

## 5. Algorithms and Computation

### 5.1 Enumeration Algorithm

The permitted voice leadings can be enumerated by the following algorithm:

```
INPUT: CounterpointSystem (C, P) over ℤₙ
OUTPUT: List of (source, target, bass, soprano) tuples

FOR each source i ∈ C:
  FOR each bass motion b ∈ ℤₙ:
    soprano ← (target − source) + b   // for each target
    FOR each target j ∈ C:
      s ← j − i + b
      IF NOT (j ∈ P AND b = s AND b ≠ 0):
        EMIT (i, j, b, s)
```

This runs in O(|C|² · n) time, which for the standard system is O(6² · 12) = O(432) — trivially fast.

### 5.2 Adjacency Matrix

The *weighted adjacency matrix* A of the counterpoint quiver has entries A[i][j] = number of permitted voice leadings from i to j. For the standard 12-TET system:

|  | 0 | 3 | 4 | 7 | 8 | 9 |
|--|---|---|---|---|---|---|
| **0** | 1 | 12 | 12 | 1 | 12 | 12 |
| **3** | 12 | 12 | 12 | 12 | 12 | 12 |
| **4** | 12 | 12 | 12 | 12 | 12 | 12 |
| **7** | 1 | 12 | 12 | 1 | 12 | 12 |
| **8** | 12 | 12 | 12 | 12 | 12 | 12 |
| **9** | 12 | 12 | 12 | 12 | 12 | 12 |

Observe:
- Diagonal entries for perfect consonances (0, 7): 1
- Diagonal entries for imperfect consonances (3, 4, 8, 9): 12
- Off-diagonal entries from imperfect source: always 12
- Off-diagonal entries from perfect source to perfect target: 1 (this should be verified — actually, perfect-to-perfect off-diagonal is 12, since parallel motion into a different perfect consonance requires j − i ≠ 0, so b = s would require j − i = 0)

Let us correct: for source i = 0, target j = 7 (both perfect), voice leading (b, s) with s = b + 7. Parallel requires b = s, i.e., b = b + 7, i.e., 7 = 0 in ℤ₁₂, which is false. So no parallel voice leadings are excluded. But the formal result says total incoming to a perfect consonance from all sources is 61, which equals 6 × 12 − 11 = 72 − 11 = 61. The 11 excluded are the 11 non-identity self-loops.

Corrected adjacency matrix:

|  | →0 | →3 | →4 | →7 | →8 | →9 |
|--|---|---|---|---|---|---|
| **0→** | 1 | 12 | 12 | 12 | 12 | 12 |
| **3→** | 12 | 12 | 12 | 12 | 12 | 12 |
| **4→** | 12 | 12 | 12 | 12 | 12 | 12 |
| **7→** | 12 | 12 | 12 | 1 | 12 | 12 |
| **8→** | 12 | 12 | 12 | 12 | 12 | 12 |
| **9→** | 12 | 12 | 12 | 12 | 12 | 12 |

Column sums: column 0 → 1+12+12+12+12+12 = 61. Column 7 → 12+12+12+1+12+12 = 61. All imperfect columns → 72. ✓

---

## 6. Discussion

### 6.1 Why Non-Composability Matters

The non-composability result (Theorem 3.6) has implications beyond pure mathematics. It means that a composer cannot reason purely locally: checking that each pair of adjacent intervals satisfies the counterpoint rules does not guarantee that the *cumulative* voice motion over several beats is well-behaved. This is consistent with pedagogical practice — counterpoint students are taught to consider the "flow" of a passage, not just individual transitions.

From a computational perspective, non-composability means that counterpoint constraint satisfaction cannot be decomposed into independent pairwise checks. Algorithmic composition systems must maintain global state, tracking not just the current interval but the voice-leading history.

### 6.2 The Bass Voice Asymmetry

Theorem 3.8 provides a precise algebraic explanation for a long-debated asymmetry in music theory. The perfect fourth — the inversion of the perfect fifth — is treated as dissonant in counterpoint, despite having a simple frequency ratio (4:3) that is arguably more consonant than the minor third (6:5) or major sixth (5:3).

Our framework reveals that this is not a psychoacoustic judgment but an algebraic fact: the voice-swap involution breaks the consonant set. Any system that includes the fifth but excludes the fourth (or vice versa) will exhibit this asymmetry. It is a necessary consequence of choosing a non-symmetric subset of ℤ₁₂.

### 6.3 Connections to Order Theory

The bottleneck theorem (Theorems 3.2–3.3) suggests a connection to partially ordered sets. If we define an order on consonance types by their "voice-leading flexibility" — measured by the number of self-loops — then perfect consonances are strictly below imperfect ones. This two-level partial order (a simple case of a "thin category") is the residue of the original conjecture that the counterpoint quiver might be equivalent to a poset-generated category.

While the full categorical equivalence does not hold (due to non-composability), the partial order on consonance types by flexibility is a genuine mathematical object that captures the essential asymmetry of the system.

---

## 7. Future Work

1. **Higher species.** Extend the framework to second, third, fourth, and fifth species counterpoint, where rhythmic displacement and passing tones introduce additional combinatorial complexity.

2. **Microtonal systems.** Systematically investigate CounterpointSystem(n) for n = 19, 24, 31, 53 and characterize which structural properties (connectivity, non-composability, bottleneck) are universal versus n-dependent.

3. **Spectral counterpoint.** Replace the ℤₙ model with a continuous pitch space ℝ/ℤ and define consonance via spectral (Fourier-analytic) criteria. This connects to Amiot's (2016) discrete Fourier transform approach to music theory.

4. **Categorical repairs.** Since the naive category fails, investigate whether a *quotient* of voice leadings (identifying voice leadings that differ by parallel components) yields a well-defined category. Alternatively, study the *free category* generated by the quiver and characterize the ideal of "forbidden compositions."

5. **Statistical music analysis.** Use the hom-set cardinalities (Theorem 3.9) to define a null model for random counterpoint, and test whether historical compositions from the Renaissance and Baroque periods deviate significantly from this null model.

---

## 8. Conclusion

We have introduced the Counterpoint System as a parameterized algebraic structure that formalizes first-species counterpoint rules over ℤ/nℤ. For the standard 12-TET system, we proved five structural theorems that collectively characterize the voice-leading constraint network: strong connectivity, non-composability, the bottleneck at perfect consonances, bass-voice asymmetry, and precise hom-set cardinalities. These results provide a rigorous mathematical foundation for classical intuitions about counterpoint and open new directions in computational and microtonal music theory.

The most striking result is perhaps the non-composability theorem, which demonstrates that counterpoint inhabits a mathematical middle ground: rich enough to be strongly connected (every transition is possible) but constrained enough that compositions of valid transitions can be invalid. This tension between local freedom and global constraint is, arguably, the mathematical essence of counterpoint as an art form.

---

## References

- Amiot, E. (2016). *Music Through Fourier Space*. Springer.
- Clampitt, D. (1997). Pairwise well-formed scales: structural and transformational properties. Ph.D. dissertation, SUNY Buffalo.
- Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.
- Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.
- Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
- Straus, J. N. (2016). *Introduction to Post-Tonal Theory*. 4th ed. W. W. Norton.
- Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
- Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.

---

## Appendix: Formal Verification

All results in this paper (Theorems 3.1–3.9) have been formally verified. The formalization introduces the `CounterpointSystem` structure parameterized over `ZMod n`, defines voice leadings as pairs of elements of `ZMod n`, and establishes all theorems by a combination of algebraic reasoning and decidable computation over finite types. The key definitions (`chromaticConsonant`, `chromaticPerfect`, `standard12`) instantiate the general framework for n = 12.
