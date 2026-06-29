# Tropical Hypergraph Counterpoint for SATB: Zero-Locus Legality, Shortest-Path Realization, and Pairwise Tensor Factorization

## Abstract

We establish an exact correspondence between four-voice (SATB) counterpoint legality and tropical optimization on weighted hypergraphs. Three main theorems are proved with full machine verification:

1. **Zero-Locus Characterization**: The set of legal SATB transitions equals the zero locus of a nonnegative tropical penalty functional assembled from six pairwise components. Legality is detected exactly by testing whether the aggregate penalty vanishes.

2. **Shortest-Path Realization**: Legal chord progressions are zero-cost paths in the induced weighted chord graph. By nonnegativity of all edge weights, legal paths are shortest among all paths connecting the same endpoints.

3. **Pairwise Tensor Factorization**: The total 4-voice sequential cost decomposes as a double sum over the 6 unordered voice pairs and all time steps. Legality of a full progression is determined entirely by pairwise legality at each step.

These results convert a classical problem in music theory into a certified tropical optimization problem, opening connections to weighted automata, tensor networks, multi-agent planning, and constraint satisfaction.

**Keywords**: tropical geometry, SATB harmonization, counterpoint, weighted hypergraphs, shortest paths, tensor factorization, constraint satisfaction, formal verification

---

## 1. Introduction

### 1.1 Background and Motivation

Four-part voice leading (Soprano, Alto, Tenor, Bass) is a foundational topic in Western music theory. The rules governing legal voice leading — prohibitions on parallel fifths, requirements against voice crossing, spacing constraints between adjacent voices — have been codified since the Baroque era and remain central to music education.

Despite extensive computational work on automated harmonization (Ebcioğlu 1988, Hild et al. 1992, Huang & Wu 2016), no previous work has identified the precise algebraic structure underlying these rules. In particular, the question of whether SATB legality admits a natural tropical-geometric formulation has not been addressed.

### 1.2 Contributions

We prove that SATB counterpoint rules form the zero locus of a tropical penalty functional — a nonnegative real-valued function that vanishes exactly on legal transitions. This is not an encoding trick but a structural theorem: the penalty decomposes over the six unordered voice pairs, and each component is the tropical maximum of three indicator penalties (parallel fifths, voice crossing, spacing).

From this local characterization, we derive two global results:
- Legal progressions are zero-cost paths in a weighted chord graph, and hence are shortest paths.
- The total cost of any progression factorizes as a sum over voice pairs and time steps, enabling structural decomposition of the optimization problem.

### 1.3 Related Work

**Computational musicology**: Automated harmonization has been approached via rule-based systems (Ebcioğlu 1988), neural networks (Huang & Wu 2016), and constraint programming (Pachet & Roy 2001). None of these identify the tropical structure.

**Tropical geometry**: The tropical semiring (ℝ ∪ {∞}, min, +) has deep connections to algebraic geometry (Maclagan & Sturmfels 2015), optimization (Butkovič 2010), and phylogenetics (Speyer & Sturmfels 2004). Our work applies tropical methods to symbolic constraint systems.

**Voice-leading geometry**: Tymoczko (2011) developed a geometric theory of voice leading using orbifold topology. Our approach differs by using tropical algebra rather than differential geometry, obtaining exact combinatorial results rather than continuous approximations.

---

## 2. Definitions and Notation

### 2.1 Core Objects

**Definition 2.1** (Voice, Chord). A *voice* is an element of Fin 4 = {0, 1, 2, 3}, representing Soprano (0), Alto (1), Tenor (2), Bass (3). A *chord* is a function `v : Fin 4 → ℤ` assigning integer pitches to voices.

**Definition 2.2** (Interval). The *interval* from pitch `a` to pitch `b` is `interval(a, b) = b - a`.

**Definition 2.3** (Unordered Voice Pairs). The set of unordered voice pairs is
```
unordVoicePairs = {(i, j) ∈ Fin 4 × Fin 4 | i < j}
```
This set has exactly 6 elements: (0,1), (0,2), (0,3), (1,2), (1,3), (2,3).

### 2.2 Pairwise Legality Predicates

For each voice pair (i, j) with i < j, we define three predicates:

**Definition 2.4** (No Parallel Fifths). `NoParallelFifthsPair(i, j, v, w)` holds iff:
if `interval(v(i), v(j)) = 7` then `interval(w(i), w(j)) ≠ 7`.

A perfect fifth is 7 semitones. Parallel fifths — two voices maintaining a fifth across a transition — are forbidden in classical counterpoint.

**Definition 2.5** (No Voice Crossing). `NoCrossingPair(i, j, w)` holds iff:
if `i < j` then `w(j) ≤ w(i)`.

Higher-indexed voices should not sound above lower-indexed ones.

**Definition 2.6** (Spacing OK). `SpacingOKPair(i, j, w)` holds iff:
if `i + 1 = j` and `i < 3` then `w(i) - w(j) ≤ 12`.

Adjacent upper voices should be within an octave (12 semitones).

**Definition 2.7** (Pair Legal). `PairLegal(i, j, v, w)` iff all three predicates hold:
```
PairLegal(i, j, v, w) ↔ NoParallelFifthsPair(i, j, v, w) ∧ NoCrossingPair(i, j, w) ∧ SpacingOKPair(i, j, w)
```

### 2.3 Global Legality

**Definition 2.8** (Legal SATB Step). A transition from `v` to `w` is legal iff all six pairs are pairwise legal:
```
LegalSATBStep(v, w) ↔ ∀ (i,j) ∈ unordVoicePairs, PairLegal(i, j, v, w)
```

### 2.4 Penalty Functions

Each legality predicate is encoded as an indicator penalty:

**Definition 2.9** (Component Penalties).
```
parallelFifthPenalty(i, j, v, w) = if NoParallelFifthsPair(i,j,v,w) then 0 else 1
crossingPenalty(i, j, w)        = if NoCrossingPair(i,j,w)          then 0 else 1
spacingPenalty(i, j, w)         = if SpacingOKPair(i,j,w)           then 0 else 1
```

**Definition 2.10** (Pair Penalty). The tropical max aggregation:
```
pairPenalty(i, j, v, w) = max(parallelFifthPenalty(i,j,v,w),
                              max(crossingPenalty(i,j,w), spacingPenalty(i,j,w)))
```

**Definition 2.11** (Total Penalty).
```
totalPenalty6(v, w) = Σ_{(i,j) ∈ unordVoicePairs} pairPenalty(i, j, v, w)
```

---

## 3. Main Results

### 3.1 Theorem Package 1: Zero-Locus Characterization

**Theorem 3.1** (Pairwise Completeness). *For all chords v, w:*
```
LegalSATBStep(v, w) ↔ ∀ (i,j) ∈ unordVoicePairs, PairLegal(i, j, v, w)
```

*Proof sketch.* By definition, `LegalSATBStep` requires `NoParallelFifths`, `NoCrossing`, and `SpacingOK` — each universally quantified over `unordVoicePairs`. Distributing the universal quantifier over the conjunction gives the equivalence. □

**Theorem 3.2** (Penalty Zero-Locus). *Each pair penalty vanishes iff the pair is legal:*
```
pairPenalty(i, j, v, w) = 0 ↔ PairLegal(i, j, v, w)
```

*Proof sketch.* The pair penalty is the maximum of three nonneg terms. It equals zero iff all three equal zero (since max(a, max(b, c)) = 0 with a, b, c ≥ 0 requires a = b = c = 0). Each component equals zero iff its predicate holds (by the definition of indicator penalties). □

**Theorem 3.3** (Zero-Locus — Pairwise Form). *Legal iff all pair penalties vanish:*
```
LegalSATBStep(v, w) ↔ ∀ (i,j) ∈ unordVoicePairs, pairPenalty(i, j, v, w) = 0
```

*Proof.* Combine Theorem 3.1 and Theorem 3.2. □

**Theorem 3.4** (Zero-Locus — Total Penalty Form). *Legal iff total penalty vanishes:*
```
LegalSATBStep(v, w) ↔ totalPenalty6(v, w) = 0
```

*Proof sketch.* By Theorem 3.3, legality equals vanishing of all pair penalties. The total penalty is a sum of nonneg terms, so it vanishes iff each term vanishes (a standard result about nonneg sums). □

**Theorem 3.5** (Tropical Sum Zero-Locus). *For any finset S and nonneg function f:*
```
(∀ i ∈ S, 0 ≤ f(i)) → (Σ_{i ∈ S} f(i) = 0 ↔ ∀ i ∈ S, f(i) = 0)
```

*Proof.* (⇐) Clear. (⇒) If `f(i₀) > 0` for some `i₀ ∈ S`, then `Σ f ≥ f(i₀) > 0`, contradicting the sum being zero. □

### 3.2 Theorem Package 2: Shortest-Path Realization

**Definition 3.6** (Progression, Cost, Legality).
```
ProgressionCost(σ) = Σ_{k=0}^{n-1} totalPenalty6(σ(k), σ(k+1))
LegalProgression(σ) ↔ ∀ k, LegalSATBStep(σ(k), σ(k+1))
```

**Theorem 3.7** (Legal ↔ Zero Cost).
```
LegalProgression(σ) ↔ ProgressionCost(σ) = 0
```

*Proof sketch.* Apply Theorem 3.4 at each step, then use Theorem 3.5 to convert the sum condition to a pointwise condition. □

**Theorem 3.8** (Shortest-Path Theorem). *If σ is a legal progression, then for any progression τ with the same endpoints:*
```
ProgressionCost(σ) ≤ ProgressionCost(τ)
```

*Proof.* `ProgressionCost(σ) = 0` by Theorem 3.7, and `ProgressionCost(τ) ≥ 0` by nonnegativity. □

**Corollary 3.9** (Illegal Detection). *If `¬ LegalSATBStep(v, w)`, then `totalPenalty6(v, w) > 0`.*

### 3.3 Theorem Package 3: Pairwise Tensor Factorization

**Theorem 3.10** (Cost Factorization).
```
ProgressionCost(σ) = Σ_{(i,j) ∈ unordVoicePairs} Σ_{k=0}^{n-1} pairPenalty(i, j, σ(k), σ(k+1))
```

*Proof.* Exchange the order of summation (Fubini for finite sums). □

**Theorem 3.11** (Legality from Pair Projections).
```
LegalProgression(σ) ↔ ∀ (i,j) ∈ unordVoicePairs, ∀ k, pairPenalty(i, j, σ(k), σ(k+1)) = 0
```

*Proof.* Combine Theorems 3.7, 3.10, and 3.5 (applied twice: first to the outer sum over pairs, then to the inner sum over time steps). □

**Theorem 3.12** (Musical Decomposition).
```
LegalProgression(σ) ↔ ∀ (i,j) ∈ unordVoicePairs, ∀ k, PairLegal(i, j, σ(k), σ(k+1))
```

*Proof.* Combine Theorem 3.11 with Theorem 3.2. □

---

## 4. Algorithms

### 4.1 Bellman-Ford on the SATB Chord Graph

**Input**: Finite pitch set P, source chord s, target chord t, number of steps n.
**Output**: Minimum-cost progression from s to t in n steps.

```
Algorithm: SATB-Bellman-Ford
1. Initialize: dist[0][s] ← 0; dist[0][v] ← ∞ for v ≠ s
2. For k = 1, ..., n:
     For each chord w ∈ P⁴:
       dist[k][w] ← min_{v ∈ P⁴} (dist[k-1][v] + totalPenalty6(v, w))
       pred[k][w] ← argmin_v (dist[k-1][v] + totalPenalty6(v, w))
3. Return dist[n][t], reconstruct path via pred
```

**Complexity**: O(n · |P|⁸) time, O(|P|⁴) space.

By Theorem 3.8, if a legal path exists, Bellman-Ford returns it with cost 0.

### 4.2 Viterbi Harmonization with Fixed Soprano

**Input**: Pitch set P, soprano melody s₀, ..., sₙ.
**Output**: Minimum-cost SATB harmonization.

```
Algorithm: SATB-Viterbi
1. Initialize: dist[0][a, t, b] ← 0 for all (a, t, b) ∈ P³
2. For k = 1, ..., n:
     For each (a', t', b') ∈ P³:
       w ← (s_k, a', t', b')
       dist[k][(a',t',b')] ← min_{(a,t,b)} (dist[k-1][(a,t,b)] + totalPenalty6((s_{k-1},a,t,b), w))
3. Return min_{(a,t,b)} dist[n][(a,t,b)]
```

**Complexity**: O(n · |P|⁶) time — cubic improvement over brute force.

### 4.3 Pairwise Factorized Search

By Theorem 3.12, legality decomposes into six pairwise constraints. This enables early pruning:

```
Algorithm: Factorized-Legal-Search
1. For each candidate next chord w:
     For each pair (i,j) ∈ unordVoicePairs:
       If pairPenalty(i, j, current, w) > 0:
         PRUNE w (skip to next candidate)
     Accept w as legal successor
```

**Expected speedup**: Instead of evaluating all 3 × 6 = 18 constraint checks, the search prunes on the first violation. In practice, most illegal transitions violate crossing or spacing on the first or second pair checked.

---

## 5. Computational Experiments

### 5.1 Exhaustive Verification

We exhaustively verified Theorem 3.4 (zero-locus characterization) on all 65,536 transitions in a 4-pitch universe {48, 55, 60, 64}:

| Metric | Value |
|--------|-------|
| Total chords | 256 |
| Total transitions | 65,536 |
| Legal transitions | 8,192 (12.5%) |
| Illegal transitions | 57,344 (87.5%) |
| Theorem 1 agreement | 65,536/65,536 (100%) |

### 5.2 Cost Matrix Statistics

For a 4-pitch universe:
- Maximum penalty per transition: 6.0 (all six pairs violated)
- Mean penalty: 2.14
- Zero entries (legal): 12.5% of all transitions

### 5.3 Factorization Verification

For a sample 4-chord progression with violations:
- Temporal sum: 2.0
- Factorized sum (pair-first ordering): 2.0
- Agreement: exact (as guaranteed by Theorem 3.10)

The violations localize to specific pairs at specific steps, confirming the structural decomposition.

---

## 6. Discussion

### 6.1 The Tropical Interpretation

Our results establish that SATB counterpoint rules define a tropical variety in the following sense. Each pairwise penalty is a {0, 1}-valued function on ℤ⁸ (the space of chord pairs). The total penalty is a sum of max-aggregated indicators. The legal set is the zero locus of this tropical functional.

This connects to the tropical fundamental theorem: every tropical variety is the intersection of tropical hypersurfaces. Here, the "hypersurfaces" are the six pairwise legality constraints, and their intersection is the legal transition set.

### 6.2 Comparison with Boolean Satisfiability

The zero-locus theorem can be viewed as a translation between Boolean satisfiability and tropical optimization:

| SAT | Tropical |
|-----|----------|
| Variable | Voice pitch |
| Clause | Pairwise legality |
| Satisfying assignment | Zero-cost chord |
| UNSAT | Positive cost |

The tropical formulation has an advantage over pure SAT: it provides a *graded* measure of infeasibility. When no legal transition exists, the penalty quantifies "how illegal" the best option is, enabling graceful degradation.

### 6.3 Limitations

1. **Simplified rules**: Our formalization captures three fundamental SATB rules (no parallel fifths, no crossing, spacing). Real counterpoint has additional rules (no parallel octaves, tendency tone resolution, doubling preferences) that could be added as further pairwise or unary penalties without changing the algebraic framework.

2. **Static penalties**: We use indicator (0/1) penalties. Graded penalties (reflecting severity of violations) would enable stylistic optimization but require modified zero-locus theorems.

3. **Fixed voice count**: The current formalization is specialized to 4 voices. Generalization to k voices is straightforward but changes the combinatorial structure.

---

## 7. Future Work

1. **Factor graph inference**: Prove that SATB harmonization reduces to min-plus belief propagation on a factor graph with treewidth bounded by the voice-pair structure.

2. **Tropical variety computation**: Identify the precise tropical variety structure of the legal transition set, including its dimension, degree, and fan structure.

3. **Existence and uniqueness**: Prove existence of optimal harmonizations over finite pitch sets and characterize uniqueness conditions.

4. **Multi-agent generalization**: Abstract the framework to k-agent systems with pairwise safety constraints, targeting applications in robotics and protocol verification.

5. **Learned penalties**: Replace indicator penalties with data-driven energies learned from chorale corpora, preserving the tropical algebraic structure while enabling style-specific optimization.

---

## 8. Conclusion

We have proved that four-voice counterpoint legality is exactly the zero locus of a tropical penalty functional, that legal progressions are shortest paths in the chord graph, and that the four-voice cost tensor factorizes over voice pairs. These results are machine-verified and establish a new paradigm: certified tropical symbolic dynamics for structured combinatorial constraint systems.

---

## References

1. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
2. Ebcioğlu, K. (1988). An expert system for harmonizing four-part chorales. *Computer Music Journal*, 12(3), 43–51.
3. Hild, H., Feulner, J., & Menzel, W. (1992). HARMONET: A neural net for harmonizing chorales in the style of J. S. Bach. *NIPS 1991*.
4. Huang, C.-Z. A., & Wu, H. H. (2016). Deep learning for music. *arXiv:1606.04930*.
5. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
6. Pachet, F., & Roy, P. (2001). Musical harmonization with constraints: A survey. *Constraints*, 6(1), 7–19.
7. Speyer, D., & Sturmfels, B. (2004). The tropical Grassmannian. *Advances in Geometry*, 4(3), 389–411.
8. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
