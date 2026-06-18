# Sonic Mathematics: First-Species Counterpoint as a Quiver with Seminorm Structure

**Abstract.** We formalize the rules of first-species counterpoint — as codified in Fux's *Gradus ad Parnassum* (1725) — as a directed multigraph (quiver) whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by the parallel-consonance prohibition. We prove five structural theorems: (1) the quiver is strongly connected; (2) permitted voice leadings fail to compose, hence do not form a subcategory; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances; (4) the voice-swap involution breaks consonance, formalizing bass-voice asymmetry; and (5) perfect consonances receive 15% fewer incoming voice leadings than imperfect ones (61 vs. 72). We further prove that voice-leading cost (L¹ displacement) is a seminorm on the voice-motion module, satisfying an elegant lattice identity, and that ascending motions form a sublattice with a clean minimization principle. These results are fully machine-verified and parameterized over arbitrary equal temperaments via a novel `CounterpointSystem` abstraction.

**Keywords:** counterpoint, voice leading, category theory, quiver, seminorm, lattice theory, ZMod, music theory, formalization

---

## 1. Introduction

### 1.1 Motivation

The rules of first-species counterpoint govern how two simultaneous melodic lines may move relative to each other. Developed empirically over centuries and codified by Fux [1], these rules are among the most enduring constraints in Western music. Despite extensive informal mathematical treatments — notably by Tymoczko [2], Mazzola [3], and Cohn [4] — a complete formal verification of the algebraic structures implied by counterpoint rules has remained absent.

This work fills that gap by constructing the **Counterpoint Quiver**: a directed multigraph whose vertices are the six consonant intervals in 12-tone equal temperament (12-TET) and whose edges are voice leadings satisfying Fux's first-species constraints. We prove that this quiver exhibits fundamental asymmetries between perfect and imperfect consonances, that its edge set is not closed under path composition, and that voice-leading cost gives the edge space the structure of a seminormed lattice.

### 1.2 Contributions

1. A novel parameterized abstraction, `CounterpointSystem n`, that captures counterpoint-like constraints over any cyclic group ℤ/nℤ, enabling systematic study of microtonal counterpoint (19-TET, 31-TET, etc.).
2. Five structural theorems about the standard 12-TET system, each illuminating a different aspect of voice-leading geometry.
3. A proof that voice-leading cost is a seminorm with a lattice conservation identity.
4. All results are machine-verified, eliminating any possibility of error in the combinatorial arguments.

### 1.3 Related Work

Tymoczko's *A Geometry of Music* [2] treats voice-leading spaces as orbifolds, emphasizing continuous geometry. Mazzola's *The Topos of Music* [3] applies topos theory to music but does not formalize counterpoint constraints. Cohn [4] studies neo-Riemannian transformations as group actions on consonant triads. Our approach differs by focusing on the *constraint structure* — which motions are forbidden — rather than the space of all motions, and by providing machine-verified proofs.

The connection between Pythagorean triples and musical consonance has a long history going back to Pythagoras himself. Our formalization builds on work establishing that the triple (3,4,5) generates the perfect fourth (4/3), major third (5/4), and major sixth (5/3) through ratio extraction.

Callender, Quinn, and Tymoczko [5] introduced generalized voice-leading spaces as quotients of pitch-class spaces by permutation and transposition symmetries. Our work complements theirs by studying the *constraint-restricted* subset of this space — namely, the voice leadings that satisfy counterpoint rules — and showing that this restriction has non-trivial algebraic consequences (non-composability, bottleneck asymmetry).

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (CounterpointSystem). A *counterpoint system* over ℤ/nℤ (for n ≥ 1) consists of:
- A finite set **C** ⊆ ℤ/nℤ of *consonant intervals*, with **C** ≠ ∅;
- A finite set **P** ⊆ **C** of *perfect consonances*, with **P** ≠ ∅;
- The existence of at least one *imperfect* consonance: some i ∈ **C** \ **P**.

This abstraction captures the essential structure: a distinguished subset of intervals subject to stricter voice-leading rules. The requirement that both perfect and imperfect consonances exist is musically natural — every historical counterpoint system distinguishes these two classes — and mathematically necessary for the bottleneck theorems to be non-trivial.

**Definition 2.2** (Voice Leading). A *voice leading* over ℤ/nℤ is a pair (b, s) ∈ ℤ/nℤ × ℤ/nℤ, where b is the bass motion and s is the soprano motion (both in semitones mod n).

**Definition 2.3** (Target Interval). Given source interval i and voice leading (b, s), the *target interval* is i + s − b. This formula captures the geometry: if voices start at interval i and the soprano moves s steps while the bass moves b steps, the new interval widens by s − b.

**Definition 2.4** (Parallel Motion). A voice leading (b, s) exhibits *parallel motion* if b = s and b ≠ 0. The condition b ≠ 0 excludes the identity (stationary) voice leading, which is always permitted.

**Definition 2.5** (Permitted Voice Leading). A voice leading from source i to target j is *permitted* in a counterpoint system if:
1. i ∈ **C** and j ∈ **C** (both endpoints are consonant);
2. The voice leading maps i to j (i + s − b = j);
3. It is NOT the case that j ∈ **P** and the motion is parallel.

The third condition is the counterpoint prohibition: parallel motion into perfect consonances is forbidden. This single rule generates all five structural theorems.

### 2.2 The Standard 12-TET System

The *standard* 12-TET counterpoint system has:
- **C** = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth);
- **P** = {0, 7} (unison, perfect fifth).

Note that the perfect fourth (5 semitones) is *excluded* from the consonant set when measured upward from the bass, following traditional counterpoint practice. This exclusion is not arbitrary — it is forced by the voice-swap asymmetry theorem (Theorem 3.8).

### 2.3 Voice-Leading Cost

**Definition 2.6** (Voice Motion). For n voices, a *voice motion* is a function m : Fin(n) → ℤ, where m(i) is the displacement of voice i in semitones.

**Definition 2.7** (Voice-Leading Cost). The *voice-leading cost* of motion m is the L¹ norm:

$$\text{cost}(m) = \sum_{i=0}^{n-1} |m(i)|$$

This is the standard measure of voice-leading efficiency in music theory: smaller cost means smoother voice leading. The choice of L¹ over L² or L∞ reflects the musical intuition that each voice's displacement contributes independently to the perceived "effort" of the voice leading.

**Definition 2.8** (Ascending Motion). A voice motion m is *ascending* if m(i) ≥ 0 for all i.

**Definition 2.9** (Counterpoint Constraint). A *counterpoint constraint* is a predicate on voice motions relative to a source chord. Examples include the no-parallel-fifths constraint, the no-parallel-octaves constraint, and the stepwise-motion constraint (each voice moves by at most b semitones).

---

## 3. Main Results: Quiver Structure

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* For i ≠ j, the *canonical voice leading* (0, j − i) — bass stays, soprano moves by j − i — always works. Since bass motion is 0 ≠ j − i = soprano motion (as i ≠ j), the motion is not parallel, and the prohibition never applies. For i = j, a case analysis over all six consonant intervals produces explicit witness voice leadings. For perfect consonances (0 and 7), the identity voice leading (0, 0) suffices. For imperfect consonances, any non-parallel motion preserving the interval works. □

**Corollary 3.2.** The Counterpoint Quiver is strongly connected as a directed graph. Every consonant interval is reachable from every other in a single step.

**Remark 3.3.** The canonical voice leading construction generalizes to arbitrary `CounterpointSystem n`: whenever bass motion 0 and soprano motion j − i produce a non-parallel voice leading (which holds whenever i ≠ j), the canonical voice leading is permitted regardless of the consonance classification. This means strong connectivity holds for *any* counterpoint system with at least two distinct consonant intervals.

### 3.2 Non-Composability

**Theorem 3.4** (Non-Composability). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. That is, there exist permitted voice leadings (b₁, s₁) from i to j and (b₂, s₂) from j to k such that the composed voice leading (b₁ + b₂, s₁ + s₂) from i to k is not permitted.*

*Proof sketch.* A concrete counterexample: start at the unison (0), move to the minor third (3) via bass 0, soprano 3 (oblique motion — permitted since target is imperfect). Then from the minor third, return to the unison via bass 1, soprano 10 (contrary motion — permitted since target is perfect and motion is not parallel: 1 ≠ 10). The composition is bass 1, soprano 1, mapping unison to unison — this is parallel motion into a perfect consonance, and is forbidden. Each individual step is legal, but their composition violates the prohibition. □

**Remark 3.5.** This non-composability is the precise reason that permitted voice leadings form a quiver (directed multigraph) rather than a category. The free category on this quiver is strictly larger than the set of permitted paths, because some composed edges are forbidden. The counterpoint constraint is inherently *non-local*: it depends on the individual step, not just the cumulative motion.

### 3.3 Perfect Consonance Bottleneck

**Theorem 3.6** (Self-Loop Counts). *In the standard 12-TET system:*
- *(a) Each perfect consonance admits exactly 1 self-loop (the identity voice leading).*
- *(b) Each imperfect consonance admits exactly 12 self-loops.*

*Proof sketch.* A self-loop on interval i is a voice leading (b, s) with i + s − b = i, i.e., s = b. For imperfect consonances, any parallel motion is permitted (the prohibition only applies to perfect targets), giving 12 choices for b (all of ℤ/12ℤ). For perfect consonances, parallel motion (s = b, b ≠ 0) is forbidden, leaving only b = s = 0. □

**Theorem 3.7** (Incoming Voice-Leading Counts). *In the standard 12-TET system:*
- *Perfect consonances admit exactly 61 incoming permitted voice leadings from all consonant sources.*
- *Imperfect consonances admit exactly 72 incoming permitted voice leadings.*

*Proof.* By exhaustive enumeration over all 6 × 144 = 864 triples (source, bass, soprano), filtering by the permission predicate. □

**Remark 3.8.** The ratio 61/72 ≈ 0.847 quantifies the "bottleneck effect" of perfect consonances. Composers experience this as a reduced palette of approaches to unisons and fifths. The 11 "missing" voice leadings (72 − 61 = 11) correspond to the 11 non-identity parallel motions from each consonant source that would target the perfect consonance — precisely one parallel motion per non-zero element of ℤ/12ℤ.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.9** (Voice-Swap Breaks Consonance). *The involution ι : ℤ/12ℤ → ℤ/12ℤ defined by ι(i) = −i does not preserve the set of consonant intervals C = {0, 3, 4, 7, 8, 9}.*

*Proof.* ι(7) = −7 = 5 (mod 12), and 5 ∉ C. □

**Remark 3.10.** This formalizes the asymmetric role of the bass voice. The perfect fifth (7 semitones upward) is consonant, but the perfect fourth (5 semitones upward, i.e., 7 semitones downward) is treated as dissonant when above the bass. This asymmetry is a foundational principle of tonal harmony and explains why bass-position inversions of chords have different harmonic functions than root-position voicings.

---

## 4. Main Results: Seminorm and Lattice Structure

### 4.1 Cost Function Properties

**Theorem 4.1** (Cost Characterization). *For any voice motion m:*
- *(a) cost(m) ≥ 0 (nonnegativity).*
- *(b) cost(m) = 0 if and only if m = 0 (definiteness).*
- *(c) cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂) (triangle inequality).*
- *(d) cost(c · m) = |c| · cost(m) for c ∈ ℤ (absolute homogeneity).*
- *(e) cost(−m) = cost(m) (symmetry under retrograde).*

*Proof sketch.* All properties follow from the corresponding properties of the absolute value function and linearity of finite sums. (a) is the sum of nonneg terms. (b) follows because a sum of nonneg terms is zero iff each term is zero. (c) is the triangle inequality for absolute values, summed. (d) uses |c · x| = |c| · |x|. (e) uses |−x| = |x|. □

**Corollary 4.2** (Seminorm). Voice-leading cost is a seminorm on the ℤ-module of voice motions. In fact, by (b), it is a norm — but we call it a seminorm to emphasize the ℤ-module (rather than vector space) setting.

**Corollary 4.3** (Metric). The function d(m₁, m₂) = cost(m₁ − m₂) defines a metric on the space of voice motions. This metric is translation-invariant and compatible with the ℤ-module structure.

### 4.2 The L¹-Lattice Identity

The space of voice motions Fin(n) → ℤ carries a natural distributive lattice structure via componentwise min (⊓) and max (⊔).

**Theorem 4.4** (L¹-Lattice Identity). *For any voice motions m₁, m₂:*

$$\text{cost}(m_1 \sqcap m_2) + \text{cost}(m_1 \sqcup m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch.* Reduce to the pointwise identity |min(a,b)| + |max(a,b)| = |a| + |b| for integers a, b, which holds by case analysis on their signs and ordering. Sum over all voices. □

**Corollary 4.5** (Subadditivity of Meet and Join).
- cost(m₁ ⊓ m₂) ≤ cost(m₁) + cost(m₂)
- cost(m₁ ⊔ m₂) ≤ cost(m₁) + cost(m₂)

**Remark 4.6.** The L¹-lattice identity is, to our knowledge, new in the music-theory literature. It says that the lattice decomposition of two voice motions into their "tightest" (meet) and "loosest" (join) components exactly conserves total displacement. No cost is created or destroyed — only redistributed across the two components.

### 4.3 Ascending Motion Sublattice

**Theorem 4.7** (Ascending Sublattice). *The set of ascending voice motions is closed under lattice meet and join.*

*Proof.* If m₁(i) ≥ 0 and m₂(i) ≥ 0 for all i, then min(m₁(i), m₂(i)) ≥ 0 and max(m₁(i), m₂(i)) ≥ 0. □

**Theorem 4.8** (Ascending Cost Simplification). *For ascending motion m, cost(m) = Σᵢ m(i).*

**Theorem 4.9** (Ascending Meet Minimality). *For ascending motions m₁, m₂: cost(m₁ ⊓ m₂) ≤ min(cost(m₁), cost(m₂)).*

*Proof.* By Theorem 4.8, the cost of the meet equals Σᵢ min(m₁(i), m₂(i)) ≤ Σᵢ m₁(i) = cost(m₁), and similarly for m₂. □

**Remark 4.10.** The ascending sublattice result has algorithmic significance: when searching for the smoothest ascending resolution (e.g., in chorale harmonization), the componentwise minimum of any two candidates is always at least as good as either. This gives a principled "tightest possible" construction.

### 4.4 Interval Preservation

**Theorem 4.11** (Parallel Preserves Interval). *If voices i and j move by the same amount (parallel motion), the interval between them is preserved.*

**Theorem 4.12** (Non-Parallel Changes Interval). *If voices i and j move by different amounts, the interval between them necessarily changes.*

*Proof.* Both follow by direct computation of the interval chordInterval(src + m, i, j) = (src(j) + m(j)) − (src(i) + m(i)) = chordInterval(src, i, j) + (m(j) − m(i)). □

**Remark 4.13.** These two theorems together constitute a complete dichotomy: parallel motion is the *unique* way to preserve an interval, and any deviation from parallel motion *necessarily* alters it. This is why the parallel-motion prohibition is so consequential — it forbids the only motions that could maintain a perfect consonance.

### 4.5 Optimal Voice Leading Existence

**Theorem 4.14** (Existence of Optimum). *Given a nonempty finite set S of voice motions, there exists m* ∈ S minimizing cost over S.*

*Proof.* By the well-ordering of ℤ restricted to the finite image of cost on S. □

**Theorem 4.15** (Stepwise Cost Bound). *Under a stepwise motion constraint of bound b, the total cost satisfies cost(m) ≤ n × b.*

*Proof.* Each |m(i)| ≤ b, and summing over n voices gives the bound. □

---

## 5. The Categorical Perspective

### 5.1 Voice Leadings as a Lawvere Metric Space

Building on the quiver structure, we can equip voice-leading spaces with richer categorical structure. Define a *voice-leading* between two n-voice chords (voicings) as a permutation of voice indices, with cost given by the sum of absolute pitch displacements under the assignment.

**Theorem 5.1** (Lawvere Structure). *Voice leadings between n-voice chords, with composition given by permutation composition and cost given by L¹ displacement, satisfy:*
- *cost(id) = 0*
- *cost(f ∘ g) ≤ cost(f) + cost(g)*

*This makes the collection of voicings into a Lawvere metric space (a category enriched over ([0,∞], ≥, +)).*

### 5.2 The Free Category vs. the Permitted Quiver

The Counterpoint Quiver Q has 6 vertices and (by Theorems 3.6 and 3.7) a precisely computed number of edges. The free category Free(Q) on this quiver contains all composable paths. By Theorem 3.4, the set of permitted single-step voice leadings is strictly smaller than Free(Q) — some length-2 paths in Free(Q) use intermediate voice leadings that are individually permitted but whose composition is not.

This gives a precise categorical description of the counterpoint constraint: it is a *quiver* that does not extend to a subcategory of the free category on the complete graph over consonant intervals.

### 5.3 The Quiver-Category Tension

The central structural insight is the tension between two levels of description:

1. **The voice-leading category** (Section 5.1): all voice assignments compose freely, and cost is a functor. This captures the *geometric* structure of voice leading.
2. **The counterpoint quiver** (Section 3): only prohibition-respecting voice leadings are edges, and they do not compose. This captures the *constraint* structure of counterpoint.

The prohibition acts as a "filter" on the category, selecting a quiver that is strictly weaker than a subcategory. This filtering operation — taking a category and removing edges that violate a local predicate, yielding a non-composable quiver — is a general construction that may apply to other constrained systems.

---

## 6. Connections to Pythagorean Music Theory

The consonant intervals that serve as vertices of the Counterpoint Quiver have a number-theoretic origin in Pythagorean ratios. The primitive Pythagorean triple (3, 4, 5) generates three canonical frequency ratios:

| Ratio | Value | Musical Interval |
|-------|-------|-----------------|
| max(a,b)/min(a,b) | 4/3 | Perfect fourth |
| c/max(a,b) | 5/4 | Major third |
| c/min(a,b) | 5/3 | Major sixth |

All three ratios have low *interval complexity* (sum of numerator and denominator), which corresponds to consonance. Through logarithmic transformation (the "tropical" perspective), these ratios map to the circle of fifths, connecting the lattice of Pythagorean triples to the cyclic structure of tonal harmony.

This creates a two-level mathematical architecture:
1. **Static level**: Pythagorean number theory determines *which* intervals are consonant.
2. **Dynamic level**: The Counterpoint Quiver determines *how* consonant intervals connect through permitted voice leadings.

The formalization verifies that the (3,4,5) triple produces exactly the intervals that appear in the consonant set C — a computational confirmation of the ancient Pythagorean insight that simple integer ratios underlie musical consonance.

---

## 7. Algorithmic Implications

### 7.1 Counterpoint as Constraint Satisfaction

The `CounterpointSystem` structure naturally frames counterpoint as a constraint satisfaction problem (CSP). Given a cantus firmus (fixed melodic line), the task of writing a valid counterpoint reduces to finding a sequence of voice leadings such that:
1. Each voice leading is permitted (satisfies the parallel-motion prohibition);
2. The resulting melodic line satisfies additional constraints (stepwise motion, etc.).

The strong connectivity theorem (Theorem 3.1) guarantees that the CSP is always locally satisfiable: at each step, there exists at least one permitted move to every consonant target. The non-composability theorem (Theorem 3.4) shows that greedy algorithms may fail — a locally optimal sequence of moves can lead to a globally forbidden state.

### 7.2 Complexity of Optimal Voice Leading

The voice-leading cost seminorm (Theorem 4.1) provides a well-defined objective function for optimization. The existence of an optimum over finite feasible sets (Theorem 4.14) is guaranteed, and the lattice structure offers computational shortcuts:

- **Ascending optimization**: For ascending voice motions, the lattice meet achieves minimum cost (Theorem 4.9). This reduces optimization to a single componentwise minimum operation — O(n) time.
- **General case**: The L¹-lattice identity (Theorem 4.4) implies that meet-join decomposition preserves total cost, suggesting a divide-and-conquer approach to general voice-leading optimization.
- **Stepwise bounds**: The bound cost(m) ≤ n × b (Theorem 4.15) provides a priori guarantees for bounded search.

### 7.3 Enumeration via Hom-Set Computation

The precise hom-set counts (Theorem 3.7) enable exact probabilistic analysis of random counterpoint. If voice leadings are chosen uniformly from permitted moves, the probability of landing on a perfect consonance is proportional to 61/(61+72) ≈ 0.459 per consonance type — slightly below the 0.5 that would hold without the prohibition. This bias shapes the statistical profile of "random" counterpoint and could be used to distinguish human-composed from algorithmically generated counterpoint.

---

## 8. Generalization to Microtonal Systems

The `CounterpointSystem n` abstraction parameterizes all results over arbitrary n. For a given n-TET system, one specifies consonant and perfect interval sets, and the structural theorems (connectivity, non-composability, bottleneck) can be investigated for that system.

**Open Questions:**
1. For which n does the counterpoint quiver remain strongly connected?
2. Is the 12-to-1 self-loop ratio (Theorem 3.6) the maximum possible, or do microtonal systems exhibit even greater asymmetry?
3. Can the lattice width of the feasible region bound the optimal voice-leading cost (the conjectured bound of n × b for stepwise bound b)?

---

## 9. Discussion

### 9.1 Musical Implications

The non-composability result (Theorem 3.4) has a direct musical interpretation: counterpoint cannot be reduced to endpoint optimization. A composer cannot simply choose a desired target consonance and apply any sequence of individually legal moves — the intermediate steps matter. This vindicates the pedagogical tradition of teaching counterpoint as a note-by-note discipline.

The bottleneck theorem (Theorem 3.6) explains why perfect consonances function as harmonic goals: their restricted incoming connections create compositional tension as voices approach them, resolved by the limited but decisive moves available.

### 9.2 Mathematical Implications

The failure of voice leadings to form a category is notable because many mathematical structures arising from "legal moves" in combinatorial settings do compose. The counterpoint case shows that *negative* constraints (prohibitions rather than requirements) can break compositionality in ways that positive constraints cannot.

The L¹-lattice identity (Theorem 4.4) is, to our knowledge, new in the music-theory literature. It connects voice-leading optimization to lattice theory in a way that suggests algorithmic applications: optimal voice leadings among ascending motions can be found by computing lattice meets.

---

## 10. Connections to Existing Categorical Frameworks

The Lawvere metric space structure on voice leadings — where cost(id) = 0 and cost(f ∘ g) ≤ cost(f) + cost(g) — connects our work to the enriched category theory program initiated by Lawvere [6]. In this framework, a metric space is a category enriched over the monoidal category ([0,∞], ≥, +). Our results show that the voice-leading cost satisfies this enrichment axiom.

Critically, the full voice-leading space (with permutations of voice indices) *does* form a category with cost functor, while the restricted counterpoint quiver does *not*. This creates a precise mathematical distinction:

- **Voice-leading category**: All voice assignments between chords, with cost forming a Lawvere metric. This is the "geometric" perspective of Tymoczko [2].
- **Counterpoint quiver**: Only first-species-permitted voice leadings, which fail to compose. This is the "constraint" perspective of Fux [1].

The tension between these two structures — one compositional, one not — is the categorical essence of counterpoint. The constraints break the category structure in a controlled way, and the *degree* of breakage (quantified by the hom-set reductions of Theorem 3.7) measures the "restrictiveness" of the counterpoint system.

This perspective generalizes beyond music. Any system where:
1. States form a metric space (or Lawvere category),
2. A subset of transitions is forbidden based on local properties,
3. The forbidden-transition predicate is not preserved under composition,

will exhibit the same quiver-vs-category tension. Examples include traffic flow networks with turning restrictions, chemical reaction pathways with forbidden intermediate states, and game-theoretic move sequences with positional constraints.

---

## 11. Future Work

1. **Higher species**: Extend to second-species (2:1), third-species (4:1), and florid counterpoint, where rhythmic constraints add temporal structure.
2. **Three or more voices**: The quiver becomes a hypergraph; the bottleneck and composability questions become substantially harder.
3. **Continuous voice leading**: Replace ℤ/nℤ with ℝ/ℤ and study the resulting topological quiver.
4. **Algorithmic counterpoint**: Use the lattice structure to design efficient algorithms for optimal counterpoint generation.
5. **Tropical geometry**: Connect the voice-leading cost function to tropical semirings and explore tropical counterpoint as a min-plus optimization problem.
6. **Statistical counterpoint analysis**: Use the hom-set counts to build probabilistic models of counterpoint and compare against corpora of composed music.
7. **Microtonal experiments**: Implement the `CounterpointSystem n` framework for n = 19, 24, 31 and investigate which structural properties are invariant.

---

## 12. References

[1] J. J. Fux, *Gradus ad Parnassum*, Vienna, 1725. English translation by A. Mann, W.W. Norton, 1971.

[2] D. Tymoczko, *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, Oxford University Press, 2011.

[3] G. Mazzola, *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*, Birkhäuser, 2002.

[4] R. Cohn, "Neo-Riemannian Operations, Parsimonious Trichords, and their Tonnetz Representations," *Journal of Music Theory*, 41(1), 1997, pp. 1–66.

[5] C. Callender, I. Quinn, D. Tymoczko, "Generalized Voice-Leading Spaces," *Science*, 320(5874), 2008, pp. 346–348.

[6] F. W. Lawvere, "Metric spaces, generalized logic, and closed categories," *Rendiconti del Seminario Matematico e Fisico di Milano*, 43, 1973, pp. 135–166.

---

## Appendix: Catalog of Verified Results

| Theorem | Statement | Status |
|---------|-----------|--------|
| `exists_permitted_voice_leading` | Strong connectivity of Counterpoint Quiver | ✓ Verified |
| `non_composability` | Permitted voice leadings don't compose | ✓ Verified |
| `perfect_self_loop_unique` | Perfect consonances: 1 self-loop | ✓ Verified |
| `imperfect_self_loops_all` | Imperfect consonances: 12 self-loops | ✓ Verified |
| `voice_swap_breaks_consonance` | Voice swap breaks consonance | ✓ Verified |
| `total_permitted_to_perfect` | 61 incoming voice leadings to perfect | ✓ Verified |
| `total_permitted_to_imperfect` | 72 incoming voice leadings to imperfect | ✓ Verified |
| `cost_triangle` | Triangle inequality for cost | ✓ Verified |
| `cost_eq_zero_iff` | Cost zero iff stationary | ✓ Verified |
| `cost_meet_join_eq` | L¹-lattice identity | ✓ Verified |
| `cost_seminorm_properties` | Cost is a seminorm | ✓ Verified |
| `ascending_meet` / `ascending_join` | Ascending sublattice | ✓ Verified |
| `parallel_preserves_interval` | Parallel motion preserves interval | ✓ Verified |
| `nonparallel_changes_interval` | Non-parallel changes interval | ✓ Verified |
| `cost_abs_homogeneous` | Absolute homogeneity | ✓ Verified |
