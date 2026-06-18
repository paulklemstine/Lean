# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver and Its Structural Invariants

---

### Abstract

We introduce the *Counterpoint System*, a parametric mathematical structure that formalizes the constraint logic of first-species counterpoint over an arbitrary equal temperament `ZMod n`. Objects are consonant intervals, and edges in the resulting directed graph (quiver) are voice leadings permitted by the prohibition against parallel motion into perfect consonances. We prove five structural theorems for the standard 12-TET system: (1) the quiver is strongly connected — every consonant interval is reachable from every other in one step; (2) permitted voice leadings are not closed under composition, so the quiver does not embed as a subcategory of any natural category; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances, formalizing the "bottleneck" effect; (4) the involution i ↦ −i (voice exchange) does not preserve consonance, proving the bass voice is algebraically privileged; (5) perfect consonances receive exactly 61 incoming voice leadings versus 72 for imperfect consonances. These results bridge music theory, combinatorics on `ZMod n`, and the theory of quivers, providing a rigorous foundation for computational and theoretical analysis of voice-leading spaces.

**Keywords:** counterpoint, voice leading, category theory, quiver, ZMod, Fux, consonance, directed graph, music theory

---

### 1. Introduction

The theory of counterpoint — the art of combining independent melodic lines — has been a cornerstone of Western music pedagogy since at least the 16th century. Johann Joseph Fux's *Gradus ad Parnassum* (1725) codified the rules into the "species" framework that remains standard today. Despite centuries of musical application and informal mathematical commentary (e.g., Mazzola 2002, Tymoczko 2011), the combinatorial structure of the voice-leading constraints has not been fully formalized.

Recent work in mathematical music theory has studied voice-leading spaces as continuous geometric objects (Callender, Quinn, and Tymoczko 2008) or as group actions on pitch-class sets (Fiore and Satyendra 2005). Our approach is complementary: we study the *discrete* combinatorial structure of permitted first-species voice leadings as a directed graph (quiver) and prove exact structural theorems about its connectivity, composability, and symmetry properties.

The key innovation is the `CounterpointSystem n` abstraction, which parameterizes the constraint structure over arbitrary `ZMod n`, enabling both the study of standard 12-TET counterpoint and its generalization to microtonal systems.

#### 1.1 Organization

Section 2 defines the core mathematical structures. Section 3 states and sketches proofs of the five main theorems. Section 4 provides quantitative analysis and computational results. Section 5 discusses implications for music theory and category theory. Section 6 outlines future directions.

---

### 2. Definitions

#### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *Counterpoint System* of order `n` (where `n ≥ 1`) consists of:

1. A finite set `consonant ⊆ ZMod n` of *consonant intervals*,
2. A finite set `perfect ⊆ consonant` of *perfect consonances*,
3. The constraint that `consonant` is nonempty, `perfect` is nonempty, and there exists at least one *imperfect* consonance (an element of `consonant \ perfect`).

We write `imperfect = consonant \ perfect` for the set of imperfect consonances.

**Definition 2.2** (Voice Leading). A *voice leading* over `ZMod n` is a pair `(b, s) ∈ ZMod n × ZMod n`, where `b` is the bass motion and `s` is the soprano motion, both measured in pitch-class units.

**Definition 2.3** (Target Interval). Given a source interval `i ∈ ZMod n` and a voice leading `(b, s)`, the *target interval* is:

$$\text{target}(i, b, s) = i + s - b$$

This follows from the observation that if the bass is at pitch `p`, the soprano is at pitch `p + i`, the bass moves to `p + b`, and the soprano moves to `p + i + s`, then the new interval is `(p + i + s) - (p + b) = i + s - b`.

**Definition 2.4** (Parallel Motion). A voice leading `(b, s)` is *parallel* if `b = s` and `b ≠ 0`.

**Definition 2.5** (Permitted Voice Leading). A voice leading `(b, s)` is *permitted* from source `i` to target `j` in a Counterpoint System if:

1. `i ∈ consonant` and `j ∈ consonant`,
2. `target(i, b, s) = j`,
3. It is NOT the case that `j ∈ perfect` and `(b, s)` is parallel.

Condition (3) encodes Fux's rule: parallel motion into perfect consonances is forbidden.

#### 2.2 The Standard 12-TET System

**Definition 2.6** (Standard System). The *standard 12-TET Counterpoint System* `standard12` is defined over `ZMod 12` with:

- `consonant = {0, 3, 4, 7, 8, 9}` (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- `perfect = {0, 7}` (unison, perfect fifth)
- `imperfect = {3, 4, 8, 9}` (minor third, major third, minor sixth, major sixth)

The conditions of Definition 2.1 are easily verified: `{0, 7} ⊆ {0, 3, 4, 7, 8, 9}`, both sets are nonempty, and `3 ∈ consonant \ perfect`.

#### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *Counterpoint Quiver* of a system is the directed multigraph whose vertex set is `consonant` and whose edge set consists of all permitted voice leadings: an edge from `i` to `j` exists for each voice leading `(b, s)` permitted from `i` to `j`.

Note that this is a multigraph — there may be multiple edges between the same pair of vertices, corresponding to different voice leadings achieving the same interval transition.

---

### 3. Main Results

#### 3.1 Theorem 1: Strong Connectivity

**Theorem** (`exists_permitted_voice_leading`). *For any two consonant intervals `i, j ∈ consonant` in `standard12`, there exists a permitted voice leading from `i` to `j`.*

*Proof sketch.* We distinguish two cases.

**Case 1: `i = j`.** We must find a self-loop. If `i ∈ imperfect`, the identity voice leading `(0, 0)` works (the target is `i + 0 - 0 = i`, and since `i ∉ perfect`, the parallel-motion restriction is vacuously satisfied). If `i ∈ perfect`, the identity also works: `(0, 0)` has `b = s = 0`, but `b = 0`, so the motion is not parallel (parallelism requires `b ≠ 0`). Thus the identity voice leading is always a legal self-loop.

**Case 2: `i ≠ j`.** Consider the *canonical voice leading* `(0, j - i)`: the bass stays fixed and the soprano moves by `j - i`. The target interval is `i + (j - i) - 0 = j`. Since `b = 0 ≠ j - i = s` (because `i ≠ j`), the motion is not parallel. Hence the parallel-motion restriction does not apply, and the voice leading is permitted regardless of whether `j` is perfect. ∎

**Corollary.** The Counterpoint Quiver of `standard12` is strongly connected as a directed graph.

This result is constructive and generalizes immediately: for *any* Counterpoint System, the quiver is strongly connected, because the canonical voice leading construction depends only on the source and target being consonant.

#### 3.2 Theorem 2: Non-Composability

**Theorem** (`non_composability`). *There exist consonant intervals `i, j, k` and voice leadings `vl₁, vl₂` such that `vl₁` is permitted from `i` to `j`, `vl₂` is permitted from `j` to `k`, but the composite voice leading `(vl₁.bass + vl₂.bass, vl₁.soprano + vl₂.soprano)` is NOT permitted from `i` to `k`.*

*Proof sketch.* We exhibit a concrete counterexample in `standard12`. Choose voice leadings whose individual steps are legal but whose composition produces parallel motion into a perfect consonance. The composite voice leading has `bass = soprano ≠ 0` and targets a perfect interval, violating the parallel-motion rule. Since each individual step avoids this violation (either the motion is not parallel, or the target is not perfect), this demonstrates the failure of composition closure. ∎

**Interpretation.** This is the key negative result. In category-theoretic terms, the permitted voice leadings form a quiver but NOT a category (or even a semicategory). The composition of morphisms is not guaranteed to yield a morphism. This means counterpoint is an inherently *local* constraint system: validity cannot be verified by checking endpoints alone.

#### 3.3 Theorem 3: The Perfect Consonance Bottleneck

**Theorem** (`perfect_self_loop_unique`). *For each perfect consonance `i ∈ perfect` in `standard12`, there is exactly 1 permitted voice leading from `i` to `i`.*

**Theorem** (`imperfect_self_loops_all`). *For each imperfect consonance `i ∈ imperfect` in `standard12`, there are exactly 12 permitted voice leadings from `i` to `i`.*

*Proof sketch.* A voice leading from `i` to `i` must satisfy `i + s - b = i`, i.e., `s = b`. So every self-loop has the form `(b, b)` for some `b ∈ ZMod 12`.

For imperfect consonances: `(b, b)` with `b = 0` is the identity (not parallel). `(b, b)` with `b ≠ 0` is parallel, but the target `i` is imperfect, so the parallel-motion restriction (which only applies to *perfect* targets) does not activate. All 12 values of `b` yield permitted self-loops.

For perfect consonances: `(0, 0)` is permitted (identity). `(b, b)` with `b ≠ 0` is parallel motion into a perfect consonance — explicitly forbidden. Only 1 self-loop survives. ∎

**Ratio.** The self-loop ratio between perfect and imperfect consonances is 1:12, a factor of 12 = |ZMod 12| − (|ZMod 12| − 1) ... more precisely, imperfect consonances admit all `n` self-loops while perfect consonances admit exactly 1. This generalizes to arbitrary `CounterpointSystem n`: perfect consonances always have exactly 1 self-loop, and imperfect consonances always have `n`.

#### 3.4 Theorem 4: Voice-Exchange Asymmetry

**Theorem** (`voice_swap_breaks_consonance`). *The involution `i ↦ -i` on `ZMod 12` does NOT preserve the set `chromaticConsonant`. Specifically, `7 ∈ chromaticConsonant` but `-7 = 5 ∉ chromaticConsonant`.*

*Proof sketch.* Direct computation: in `ZMod 12`, `-7 ≡ 5 (mod 12)`. The interval 5 (perfect fourth) is not in `{0, 3, 4, 7, 8, 9}`. ∎

**Interpretation.** Voice exchange — swapping which voice sings the higher pitch — does not preserve consonance. This means the Counterpoint Quiver is not invariant under the natural `ZMod 12` involution, and the bass voice occupies an algebraically privileged position. This formalizes what music theorists have long observed: the perfect fourth is consonant between upper voices but dissonant against the bass, a rule that seemed arbitrary but is here shown to be a structural necessity of the consonance set's asymmetry under negation.

#### 3.5 Theorem 5: Hom-Set Cardinalities

**Theorem** (`total_permitted_to_perfect`). *Each perfect consonance in `standard12` admits exactly 61 incoming permitted voice leadings (summed over all consonant sources).*

**Theorem** (`total_permitted_to_imperfect`). *Each imperfect consonance in `standard12` admits exactly 72 incoming permitted voice leadings (summed over all consonant sources).*

*Proof sketch.* For a target `j`, the number of permitted voice leadings from source `i` is the number of pairs `(b, s)` with `i + s - b = j` and `¬(j ∈ perfect ∧ b = s ∧ b ≠ 0)`. The constraint `s = b + j - i` eliminates one degree of freedom, leaving `b` free to range over `ZMod 12`. If `j ∈ perfect`, we must subtract the 11 parallel motions (b = s ≠ 0), so each source contributes `12 - 11 = 1` non-self voice leading plus possible self-contribution. Careful accounting over all 6 sources yields 61 for perfect and 72 for imperfect targets. ∎

**The 15% constraint.** The ratio 61/72 ≈ 0.847 quantifies the "compositional bottleneck" at perfect consonances. A composer approaching a perfect fifth or unison has approximately 15% fewer voice-leading options than when approaching a third or sixth. This precise quantification is, to our knowledge, new.

---

### 4. Quantitative Analysis

#### 4.1 Edge Counts in the Counterpoint Quiver

| Target type | Self-loops per vertex | Incoming edges per vertex | Total edges to type |
|---|---|---|---|
| Perfect (×2) | 1 | 61 | 122 |
| Imperfect (×4) | 12 | 72 | 288 |
| **Total** | | | **410** |

The total number of edges in the Counterpoint Quiver of `standard12` is 410, distributed asymmetrically between perfect and imperfect targets.

#### 4.2 Source-Target Matrix

For each ordered pair `(i, j)` of consonant intervals, the number of permitted voice leadings is:

- If `j ∈ imperfect`: always 12 (all values of `b` work, since parallel motion into imperfect consonances is unrestricted).
- If `j ∈ perfect` and `i ≠ j`: exactly 11 (exclude the one parallel motion `b = s = j - i + something`... more precisely, the one value of `b` that makes `s = b`).
- If `j ∈ perfect` and `i = j`: exactly 1 (only the identity).

Wait — let us be more careful. Given source `i` and target `j`, a voice leading `(b, s)` is permitted iff `s = b + j - i` and `¬(j ∈ perfect ∧ b = s ∧ b ≠ 0)`. The substitution gives `s = b + j - i`, so the parallel condition `b = s` becomes `b = b + j - i`, i.e., `j = i`. Thus:

- If `i ≠ j`: parallel motion is impossible regardless of `b`, so all 12 values of `b` are permitted. The count is 12 for both perfect and imperfect targets.
- If `i = j` and `j ∈ imperfect`: all 12 self-loops are permitted.
- If `i = j` and `j ∈ perfect`: only `b = 0` is permitted (the identity). Count: 1.

This gives us the source-target matrix:

| Source \ Target | 0 (P) | 3 (I) | 4 (I) | 7 (P) | 8 (I) | 9 (I) |
|---|---|---|---|---|---|---|
| **0 (P)** | 1 | 12 | 12 | 12 | 12 | 12 |
| **3 (I)** | 12 | 12 | 12 | 12 | 12 | 12 |
| **4 (I)** | 12 | 12 | 12 | 12 | 12 | 12 |
| **7 (P)** | 12 | 12 | 12 | 1 | 12 | 12 |
| **8 (I)** | 12 | 12 | 12 | 12 | 12 | 12 |
| **9 (I)** | 12 | 12 | 12 | 12 | 12 | 12 |

Column sums: Perfect targets (0, 7) each receive `1 + 12×5 = 61`. Imperfect targets (3, 4, 8, 9) each receive `12×6 = 72`.

#### 4.3 Graph-Theoretic Properties

- **Vertices:** 6
- **Edges:** 410 (with multiplicity)
- **Strongly connected:** Yes (Theorem 1)
- **Self-loops:** 2×1 + 4×12 = 50
- **Non-loop edges:** 360
- **Diameter:** 1 (every pair is connected by at least one direct edge)

---

### 5. Discussion

#### 5.1 The Category-Theory Perspective

Our original motivation was to determine whether first-species counterpoint forms a category. The answer is definitively negative (Theorem 2). The permitted voice leadings form a quiver — a directed multigraph — but composition is not closed. This places counterpoint in the same structural class as other constraint systems where local validity does not guarantee global validity, such as tiling problems and certain constraint-satisfaction problems in computer science.

However, the quiver itself is a rich combinatorial object. Its hom-sets are finite and computable (Theorem 5), its automorphism group can be studied, and its higher-dimensional analogues (for second-species, third-species, etc.) offer natural extensions.

#### 5.2 The Role of Perfect Consonances

Theorems 3 and 5 together establish that perfect consonances function as *bottlenecks* in the voice-leading graph. They are harder to reach (fewer incoming edges) and harder to leave without changing interval (only the identity self-loop). This formalizes the musical intuition that perfect consonances are "stable" or "final" — they resist the fluid voice-leading that characterizes free counterpoint.

The bottleneck ratio of 61/72 is specific to 12-TET. For a general `CounterpointSystem n`, the ratio would be `(n·|consonant| - n + 1) / (n·|consonant|)` for diagonal vs. off-diagonal targets, assuming the same structural pattern holds.

#### 5.3 Generalization to Microtonal Systems

The `CounterpointSystem n` abstraction is designed for generalization. For 19-TET, one might define consonant intervals based on approximations to just intonation ratios in that temperament (e.g., {0, 5, 6, 11, 13, 14} for the nearest approximations). For 31-TET, the consonance set is richer. In each case, the same structural questions — connectivity, composability, bottleneck ratios — can be asked and answered using the same framework.

#### 5.4 Connection to Pythagorean Harmony

This work connects to the Pythagorean foundations of consonance. The intervals classified as consonant in `standard12` — unison (1:1), fifth (3:2), major third (5:4), minor third (6:5), major sixth (5:3), minor sixth (8:5) — are precisely those with simple frequency ratios in just intonation. The "perfect" consonances (1:1 and 3:2) are those involving only factors of 2 and 3. Thus the classification has a number-theoretic origin, and the voice-leading constraints we study are downstream consequences of this arithmetic structure.

---

### 6. Future Work

1. **Higher species.** Second-species counterpoint introduces passing tones and suspensions; third-species adds further rhythmic subdivision. Each can be modeled as a decorated quiver with additional edge types.

2. **Multi-voice counterpoint.** Extending from two voices to three or more requires replacing intervals with tuples (or equivalence classes under transposition), dramatically increasing the state space.

3. **Categorical enrichment.** While the raw quiver is not a category, one could study its free category (the path category), its reflexive-transitive closure, or quotients that restore composability. The free category on the Counterpoint Quiver is the "space of all valid counterpoint passages" and inherits a rich combinatorial structure.

4. **Topological voice-leading spaces.** Tymoczko (2006, 2011) studies voice-leading as geometry on orbifolds. Our discrete quiver should embed naturally into these continuous spaces, with edges corresponding to short geodesics.

5. **Algorithmic composition.** The Counterpoint Quiver can be used as the state-transition graph for algorithmic composition: a random walk on the quiver produces valid counterpoint. The bottleneck effect at perfect consonances would produce statistically detectable cadential patterns.

6. **Spectral analysis.** The adjacency matrix of the Counterpoint Quiver (with multiplicity) has eigenvalues that encode structural information. The spectral gap relates to mixing time of random walks and thus to the "diversity" of randomly generated counterpoint.

---

### 7. References

1. Callender, C., Quinn, I., and Tymoczko, D. (2008). "Generalized Voice-Leading Spaces." *Science* 320(5874): 346–348.

2. Fiore, T. M. and Satyendra, R. (2005). "Generalized Contextual Groups." *Music Theory Online* 11(3).

3. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.

4. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.

5. Tymoczko, D. (2006). "The Geometry of Musical Chords." *Science* 313(5783): 72–74.

6. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.

---

### Appendix: Formal Verification

All five main theorems have been stated and proved as formal mathematical theorems using rigorous machine-checked proofs. The formalization defines the `CounterpointSystem` structure, `VoiceLeading` type, and all associated predicates over `ZMod n`, with the standard 12-TET system as a concrete instantiation. Decidability instances are provided for all relevant predicates, enabling computational verification of the finite cases. The proofs combine case analysis on the finite type `ZMod 12` with algebraic reasoning in modular arithmetic.
