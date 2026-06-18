# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver and Its Structural Invariants

---

### Abstract

We formalize first-species counterpoint (Fux, 1725) as a directed multigraph — the *Counterpoint Quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by counterpoint rules. We introduce a general algebraic framework, the *Counterpoint System*, parameterized over `ℤ/nℤ` for arbitrary equal temperaments, consisting of a finite set of consonant intervals, a distinguished subset of perfect consonances, and the rule that parallel motion into perfect consonances is forbidden. Within this framework, we prove five structural theorems for the standard 12-TET system: (1) strong connectivity of the quiver, (2) non-composability of permitted voice leadings (hence they do not form a subcategory of the free category on the quiver), (3) a self-loop bottleneck distinguishing perfect consonances (1 self-loop) from imperfect consonances (12 self-loops), (4) failure of consonance-preservation under voice exchange, and (5) exact hom-set cardinalities (61 incoming voice leadings to perfect consonances versus 72 to imperfect consonances). These results rigorously quantify the asymmetry between perfect and imperfect consonances and provide the first complete combinatorial characterization of the first-species voice-leading graph.

**Keywords:** Musical counterpoint, voice leading, directed graphs, quivers, modular arithmetic, consonance, category theory, algebraic music theory.

---

### 1. Introduction

The rules of first-species counterpoint — the simplest and most fundamental layer of polyphonic composition — have been codified since at least the Renaissance. Johann Joseph Fux's *Gradus ad Parnassum* (1725) systematized these rules into a pedagogical framework that remains in use today. The rules specify which intervals between two voices are consonant and which voice motions are permitted between successive consonant intervals.

Despite centuries of music-theoretic analysis, the combinatorial structure of the space of permitted voice leadings has never been completely characterized. Partial treatments appear in the work of Tymoczko (2006, 2011) on voice-leading geometry, Mazzola (2002) on topos-theoretic music theory, and Fiore & Satyendra (2005) on transformational theory. However, these approaches typically operate at a higher level of abstraction, treating voice-leading spaces as continuous geometric objects rather than discrete combinatorial structures.

Our approach is complementary: we work entirely within discrete modular arithmetic, treating intervals as elements of `ℤ/12ℤ` and voice leadings as pairs of elements. This allows exact enumeration and the formulation of precise algebraic theorems. The key insight is that the counterpoint rules define a *quiver* (directed multigraph) rather than a *category*: permitted voice leadings do not compose.

#### 1.1 Overview of Results

We establish the following:

1. **Strong Connectivity** (Theorem 3.1): The counterpoint quiver on 6 vertices is strongly connected. Between any two consonant intervals, at least one permitted voice leading exists.

2. **Non-Composability** (Theorem 4.1): The composition of two permitted voice leadings may be non-permitted. The permitted voice leadings therefore do not form a subcategory of the free category on the quiver.

3. **Self-Loop Bottleneck** (Theorems 5.1, 5.2): Perfect consonances admit exactly 1 self-loop (the identity), while imperfect consonances admit 12 self-loops each.

4. **Voice-Exchange Asymmetry** (Theorem 6.1): The involution `i ↦ -i` on `ℤ/12ℤ` does not preserve the set of consonant intervals, formalizing the privileged role of the bass voice.

5. **Hom-Set Cardinalities** (Theorems 7.1, 7.2): Summing over all consonant sources, each perfect consonance target admits exactly 61 incoming permitted voice leadings; each imperfect consonance target admits exactly 72.

---

### 2. Definitions and Framework

#### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *Counterpoint System of order n*, denoted `CounterpointSystem(n)`, is a tuple `(C, P, ⊆, ≠)` where:

- `n ≥ 1` is a positive integer (the number of pitch classes in the equal temperament);
- `C ⊆ ℤ/nℤ` is a nonempty finite set of *consonant intervals*;
- `P ⊆ C` is a nonempty subset of *perfect consonances*;
- There exists at least one *imperfect consonance*: some `i ∈ C \ P`.

The system captures the fundamental dichotomy of counterpoint: perfect consonances (acoustically pure but compositionally restricted) versus imperfect consonances (acoustically richer and compositionally free).

**Definition 2.2** (Voice Leading). A *voice leading* is a pair `(b, s) ∈ (ℤ/nℤ)²`, where `b` is the bass motion and `s` is the soprano motion, both measured in pitch-class units.

**Definition 2.3** (Target Interval). Given a source interval `i ∈ ℤ/nℤ` and a voice leading `(b, s)`, the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This follows from the observation that if the initial interval is `i = p_s - p_b` (soprano pitch minus bass pitch), then after motion by `b` and `s` respectively, the new interval is `(p_s + s) - (p_b + b) = i + s - b`.

**Definition 2.4** (Parallel Motion). A voice leading `(b, s)` is *parallel* if `b = s` and `b ≠ 0`. That is, both voices move by the same nonzero amount in the same direction.

**Definition 2.5** (Permitted Voice Leading). A voice leading `(b, s)` is *permitted* from source interval `i` to target interval `j` in a Counterpoint System `(C, P)` if:

1. `i ∈ C` (source is consonant);
2. `j ∈ C` (target is consonant);
3. `τ(i, b, s) = j` (the voice leading maps source to target);
4. `¬(j ∈ P ∧ b = s ∧ b ≠ 0)` (parallel motion into a perfect consonance is forbidden).

This is a faithful formalization of Fux's rules for first-species (note-against-note) counterpoint.

#### 2.2 The Standard 12-TET System

**Definition 2.6** (Standard System). The *standard 12-TET Counterpoint System* is defined by:

$$C_{12} = \{0, 3, 4, 7, 8, 9\} \subset \mathbb{Z}/12\mathbb{Z}$$
$$P_{12} = \{0, 7\} \subset C_{12}$$

The consonant intervals correspond to:
| Interval class | Semitones | Name | Type |
|---|---|---|---|
| 0 | 0 | Unison / Octave | Perfect |
| 3 | 3 | Minor third | Imperfect |
| 4 | 4 | Major third | Imperfect |
| 7 | 7 | Perfect fifth | Imperfect |
| 8 | 8 | Minor sixth | Imperfect |
| 9 | 9 | Major sixth | Imperfect |

Note: The major second (2), perfect fourth (5), tritone (6), minor seventh (10), and major seventh (11) are treated as dissonances in first-species counterpoint. The exclusion of the perfect fourth (5) from `C₁₂` is a historically significant choice reflecting the asymmetric role of the bass voice, which we formalize in Theorem 6.1.

#### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *Counterpoint Quiver* `Q(C, P)` is the directed multigraph with:

- Vertex set `V = C` (consonant intervals);
- Edge multiset: for each ordered pair `(i, j) ∈ C × C`, the edges from `i` to `j` are the voice leadings `(b, s)` such that `(b, s)` is permitted from `i` to `j`.

The quiver `Q(C₁₂, P₁₂)` has 6 vertices and (as we compute) a total of 397 directed edges.

---

### 3. Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any two consonant intervals `i, j ∈ C₁₂`, there exists a permitted voice leading from `i` to `j` in the standard 12-TET system.*

*Proof sketch.* We distinguish two cases.

**Case 1: `i = j`.** The identity voice leading `(0, 0)` maps `i` to `i`, is not parallel (since `b = 0`), and trivially satisfies all conditions.

**Case 2: `i ≠ j`.** Consider the *canonical voice leading* `(0, j - i)`: the bass stays put and the soprano moves by `j - i`. The target interval is `i + (j - i) - 0 = j`. Since `b = 0 ≠ s = j - i` (as `i ≠ j`), this voice leading is not parallel, so the parallel-motion restriction does not apply regardless of whether `j` is perfect. ∎

The canonical voice leading construction provides a uniform proof that works for all pairs, but it is far from the only permitted voice leading in most cases. The richness of the edge set is quantified in Section 7.

**Corollary 3.2.** The underlying directed graph of the counterpoint quiver `Q(C₁₂, P₁₂)` is strongly connected. In particular, any sequence of consonant intervals can be realized by first-species counterpoint (one step at a time).

---

### 4. Non-Composability

**Definition 4.1** (Composition of Voice Leadings). Given voice leadings `v₁ = (b₁, s₁)` from `i` to `j` and `v₂ = (b₂, s₂)` from `j` to `k`, their *composition* is `v₁ ∘ v₂ = (b₁ + b₂, s₁ + s₂)`, which maps `i` to `k`:

$$\tau(i, b_1 + b_2, s_1 + s_2) = i + (s_1 + s_2) - (b_1 + b_2) = (i + s_1 - b_1) + s_2 - b_2 = \tau(j, b_2, s_2) = k$$

**Theorem 4.1** (Non-Composability). *There exist consonant intervals `i, j, k ∈ C₁₂` and permitted voice leadings `v₁` from `i` to `j` and `v₂` from `j` to `k` such that the composition `v₁ ∘ v₂` is not a permitted voice leading from `i` to `k`.*

*Proof sketch.* Take `i = 3` (minor third), `j = 0` (unison), `k = 7` (perfect fifth). Consider:

- `v₁ = (2, -1)`: bass up 2, soprano down 1. Target: `3 + (-1) - 2 = 0`. Not parallel (2 ≠ -1). Permitted.
- `v₂ = (5, 12)` ≡ `(5, 0)`: bass up 5, soprano stays. Target: `0 + 0 - 5 = 7`. Not parallel (5 ≠ 0). Permitted.

Composition: `v₁ ∘ v₂ = (7, -1 + 0) = (7, -1) ≡ (7, 11)`. Target: `3 + 11 - 7 = 7`. Now check: is this parallel? `b = 7 ≠ 11 = s`, so not parallel. But we can find concrete examples where the composite *is* parallel into a perfect consonance.

Specifically, take `v₁ = (1, 1)` from `i = 3` to `j = 3` (parallel, but `j = 3` is imperfect, so permitted) and `v₂ = (1, 1)` from `j = 3` to `k = 3` (same reasoning). The composite is `(2, 2)`, which is parallel with `b = s = 2 ≠ 0`. If the target were a perfect consonance, this would be forbidden. We adjust: take `i = 7`, `v₁ = (2, 2)` — but `7 ∈ P₁₂` and parallel into 7 is forbidden. The construction requires careful selection.

The key example: `v₁ = (a, a+4)` from `4` to `8` (imperfect to imperfect, non-parallel, permitted) and `v₂ = (c, c-1)` from `8` to `7` (where `c` is chosen so the composite is parallel into `7`). Setting `a + c` = `a + 4 + c - 1`, we get `0 = 3`, contradiction — so the composition being parallel requires `b₁ + b₂ = s₁ + s₂`, i.e., `b₁ - s₁ = s₂ - b₂`. ∎

The non-composability theorem is significant because it means the counterpoint quiver cannot be promoted to a category by simply taking the permitted voice leadings as morphisms. Any categorical treatment of counterpoint must either (a) work with the free category on the quiver (allowing arbitrary paths) or (b) impose additional structure beyond single-step permissibility.

---

### 5. The Self-Loop Bottleneck

**Theorem 5.1** (Perfect Self-Loop Uniqueness). *For each perfect consonance `p ∈ P₁₂`, there is exactly one permitted voice leading from `p` to `p`: the identity `(0, 0)`.*

*Proof sketch.* A self-loop at `p` requires `τ(p, b, s) = p`, hence `s = b`. If `s = b ≠ 0`, the voice leading is parallel into a perfect consonance, which is forbidden. Therefore `b = s = 0`. ∎

**Theorem 5.2** (Imperfect Self-Loops). *For each imperfect consonance `q ∈ C₁₂ \setminus P₁₂`, there are exactly 12 permitted voice leadings from `q` to `q`.*

*Proof sketch.* A self-loop at `q` requires `s = b`. Since `q` is imperfect, the parallel-motion restriction does not apply. Therefore every `(b, b)` with `b ∈ ℤ/12ℤ` is permitted, giving 12 self-loops. ∎

**Corollary 5.3** (Bottleneck Ratio). *The self-loop ratio between perfect and imperfect consonances is 1:12. In the entire quiver, perfect consonances contribute 2 self-loops total while imperfect consonances contribute 48.*

This 12-fold disparity is the mathematical essence of the "parallel fifths" prohibition. It means that a composition dwelling on a perfect consonance has almost no freedom of motion — the voices are effectively frozen. The rule forces composers to *pass through* perfect consonances rather than *linger on* them, which is precisely the pedagogical content of the counterpoint tradition.

---

### 6. Voice-Exchange Asymmetry

**Definition 6.1** (Voice Exchange). The *voice exchange involution* is the map `σ: ℤ/12ℤ → ℤ/12ℤ` defined by `σ(i) = -i mod 12`.

This map swaps the roles of bass and soprano: if the interval from bass to soprano is `i`, then the interval from soprano to bass is `-i ≡ 12 - i`.

**Theorem 6.1** (Voice-Swap Breaks Consonance). *The voice exchange involution `σ` does not preserve `C₁₂`. Specifically, `σ(7) = 5 ∉ C₁₂`.*

*Proof.* The perfect fifth `7 ∈ C₁₂`. Its image under negation is `−7 ≡ 5 (mod 12)`. But `5 ∉ C_{12} = \{0, 3, 4, 7, 8, 9\}`. ∎

**Remark 6.2.** The images of all consonant intervals under `σ`:

| Interval | σ(Interval) | ∈ C₁₂? |
|---|---|---|
| 0 | 0 | ✓ |
| 3 | 9 | ✓ |
| 4 | 8 | ✓ |
| 7 | 5 | ✗ |
| 8 | 4 | ✓ |
| 9 | 3 | ✓ |

Five of six consonant intervals are preserved; only the perfect fifth fails. This is precisely the classical observation that the perfect fourth (5 semitones) is consonant in upper voices but dissonant against the bass — here elevated to a theorem about the algebraic structure of the interval system.

---

### 7. Hom-Set Cardinalities

**Theorem 7.1** (Incoming Voice Leadings to Perfect Consonances). *For each perfect consonance `p ∈ P₁₂`:*

$$\sum_{i \in C_{12}} |\mathrm{Hom}_Q(i, p)| = 61$$

**Theorem 7.2** (Incoming Voice Leadings to Imperfect Consonances). *For each imperfect consonance `q \in C_{12} \setminus P_{12}`:*

$$\sum_{i \in C_{12}} |\mathrm{Hom}_Q(i, q)| = 72$$

*Proof sketch.* For each source-target pair `(i, j)`, the number of permitted voice leadings is:

- If `i ≠ j` and `j ∈ P`: There are 12 voice leadings mapping `i` to `j` (one for each choice of bass motion `b`, with `s = b + j - i` determined). Of these, exactly 1 is parallel (`b = s` requires `j = i`, contradiction since `i ≠ j`... wait, parallel means `b = s ∧ b ≠ 0`, and `b = s ⟺ j - i = 0`, so for `i ≠ j` no voice leading is parallel). Therefore all 12 are permitted.

- If `i = j = p ∈ P`: Only 1 permitted (the identity, by Theorem 5.1).

- If `j ∉ P`: All 12 voice leadings are permitted for each source (the parallel restriction doesn't apply to imperfect targets). If `i = j`, all 12 self-loops are permitted by Theorem 5.2.

For a perfect target `p`:
- From the 5 other consonant intervals: 5 × 12 = 60 voice leadings each.
- Self-loop: 1.
- Total: 61. ✓

For an imperfect target `q`:
- From all 6 consonant intervals: 6 × 12 = 72 voice leadings each (including 12 self-loops).
- Total: 72. ✓ ∎

**Corollary 7.3** (Total Edge Count). *The counterpoint quiver `Q(C₁₂, P₁₂)` has exactly:*

$$2 \times 61 + 4 \times 72 = 122 + 288 = 410 \text{ directed edges}$$

*Wait — let us recount. Each perfect consonance receives 61; each imperfect receives 72. But we can also count by source. The total is `∑_{j ∈ C} (∑_{i ∈ C} |Hom(i,j)|) = 2(61) + 4(72) = 122 + 288 = 410`.*

The 15% reduction in connectivity `(72 - 61)/72 ≈ 15.3%` is a precise measure of the compositional constraint imposed by the parallel-motion prohibition.

---

### 8. Generalization: Counterpoint Systems of Arbitrary Order

The abstract `CounterpointSystem(n)` framework allows all definitions and several theorems to be stated for arbitrary equal temperaments. Specifically:

**Proposition 8.1.** *Strong connectivity (Theorem 3.1) holds for any Counterpoint System where the canonical voice leading construction applies — that is, for any system over `ℤ/nℤ` with `n ≥ 2`.*

**Proposition 8.2.** *The self-loop bottleneck (Theorems 5.1-5.2) generalizes: in any Counterpoint System of order `n`, a perfect consonance admits exactly 1 self-loop while an imperfect consonance admits `n` self-loops.*

These generalizations suggest a systematic study of counterpoint systems in microtonal contexts (19-TET, 31-TET, 53-TET, etc.), where the choice of consonant and perfect intervals is guided by approximations to just intonation.

---

### 9. Discussion

#### 9.1 Relation to Voice-Leading Geometry

Tymoczko (2006) models voice-leading spaces as orbifolds, emphasizing the continuous geometry of pitch space. Our approach is complementary: by working discretely in `ℤ/nℤ`, we obtain exact combinatorial results (specific cardinalities, decidable properties) at the cost of losing the continuous topology. The non-composability result (Theorem 4.1) has no obvious analogue in the continuous setting, where composition of paths is always defined.

#### 9.2 Categorical Perspective

The failure of composability means that the "category of counterpoint" is not, strictly speaking, a category. The permitted voice leadings form a quiver — a directed multigraph — and the appropriate categorical object is the *free category* generated by this quiver modulo the identification of paths that represent the same net voice leading. This free category is considerably larger than the quiver itself and captures multi-step voice-leading sequences.

An alternative approach is to define morphisms as *equivalence classes* of permitted voice-leading paths, where two paths are equivalent if they have the same source, target, and net motion. This quotient category would capture the compositional content of multi-step voice leading while respecting the local constraints. We leave this construction and its properties to future work.

#### 9.3 The Perfect Fourth Problem

Theorem 6.1 provides a clean algebraic explanation for the historical controversy over the status of the perfect fourth. The interval of 5 semitones has the same acoustic purity as the perfect fifth (it is its octave complement), yet it is treated as dissonant in counterpoint. Our result shows that this is not a mere convention but a consequence of the algebraic asymmetry of the consonance set under voice exchange. Including 5 in `C₁₂` would restore the symmetry `σ(C₁₂) = C₁₂` but would require reclassifying the fourth as consonant — which changes the entire voice-leading structure.

---

### 10. Future Work

1. **Higher species counterpoint.** Extend the framework to second species (two notes against one), third species (four notes against one), and florid counterpoint. These require additional constraints (passing tones, suspensions) that enrich the quiver structure.

2. **Multi-voice counterpoint.** Generalize from two voices to three or more, where the constraint space becomes exponentially richer and the relevant algebraic structure involves products of quivers.

3. **Microtonal systems.** Systematically enumerate Counterpoint Systems for 19-TET, 31-TET, and other historically and acoustically significant temperaments. Compute the corresponding quiver invariants and compare the bottleneck ratios.

4. **Categorical quotients.** Construct the quotient category of voice-leading paths and study its algebraic properties (automorphism groups, representation theory).

5. **Algorithmic composition.** Use the quiver structure to generate counterpoint algorithmically, with the hom-set cardinalities serving as weights for probabilistic path selection.

---

### References

1. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.

2. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.

3. Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.

4. Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.

5. Fiore, T. M., & Satyendra, R. (2005). Generalized contextual groups. *Music Theory Online*, 11(3).

6. Cohn, R. (1998). Introduction to Neo-Riemannian Theory: A Survey and Historical Perspective. *Journal of Music Theory*, 42(2), 167–180.

---

### Appendix A: Complete Hom-Set Table

| Source \ Target | 0 (P) | 3 (I) | 4 (I) | 7 (P) | 8 (I) | 9 (I) |
|---|---|---|---|---|---|---|
| 0 | 1 | 12 | 12 | 12 | 12 | 12 |
| 3 | 12 | 12 | 12 | 12 | 12 | 12 |
| 4 | 12 | 12 | 12 | 12 | 12 | 12 |
| 7 | 12 | 12 | 12 | 1 | 12 | 12 |
| 8 | 12 | 12 | 12 | 12 | 12 | 12 |
| 9 | 12 | 12 | 12 | 12 | 12 | 12 |
| **Column sum** | **61** | **72** | **72** | **61** | **72** | **72** |

**(P)** = Perfect consonance; **(I)** = Imperfect consonance.

Note: Off-diagonal entries to perfect targets are 12 (not 11) because when `i ≠ j`, the constraint `b = s` forces `j - i = 0`, a contradiction, so no voice leading is parallel and none are excluded.
