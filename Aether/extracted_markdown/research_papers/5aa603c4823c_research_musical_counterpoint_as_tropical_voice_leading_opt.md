# Tropical Counterpoint: Musical Voice-Leading as Min-Plus Optimization

## Abstract

We develop a mathematical framework that identifies first-species counterpoint with the zero locus of a tropical (min-plus) cost functional, proves that minimizers of weighted voice-leading cost must satisfy strict contrapuntal rules under sufficient penalty separation, establishes a tropical Bellman recursion for computing optimal voice leading in polynomial time, and demonstrates that multi-objective optimization with harmonic variety yields Pareto frontiers that formally distinguish historical compositional styles. All theorems are machine-verified in the Lean 4 proof assistant with the Mathlib library. We provide algorithms for certified counterpoint generation, style classification via tropical cost signatures, and automated constraint verification.

**Keywords**: tropical algebra, min-plus optimization, counterpoint, voice leading, formal music theory, dynamic programming, Pareto optimality, certified algorithms

## 1. Introduction

### 1.1 Background and Motivation

First-species counterpoint, codified by Fux (1725) and rooted in the practice of Palestrina, imposes three fundamental constraints on two-voice compositions: (1) every simultaneous interval must be consonant, (2) consecutive perfect consonances in parallel motion are forbidden, and (3) melodic motion should be predominantly stepwise. These rules have been taught for centuries as aesthetic guidelines, but their precise mathematical structure has remained informal.

Independently, tropical (min-plus) algebra—where the semiring operations are minimum and addition—has become a central tool in optimization theory, algebraic geometry, phylogenetics, and formal verification. The tropical semiring (ℝ ∪ {∞}, min, +) provides the natural algebraic framework for shortest-path problems, dynamic programming, and weighted constraint satisfaction.

### 1.2 Contributions

This paper makes four principal contributions:

1. **Zero-Cost Equivalence (Theorem 1)**: We prove that first-species legality is equivalent to the total tropical contrapuntal cost being zero. This identifies species counterpoint as an exact feasibility condition in a weighted constraint satisfaction problem.

2. **Strict-Style Dominance (Theorem 2)**: Under positive penalty weights with a legal witness, every cost minimizer must satisfy strict contrapuntal rules. This formalizes the principle that sufficient penalty separation converts soft optimization into hard style laws.

3. **Tropical Bellman Recursion (Theorem 3)**: The optimal voice-leading cost satisfies a min-plus Bellman equation, enabling polynomial-time computation via dynamic programming. The proof uses tropical distributivity explicitly.

4. **Pareto Tradeoff (Theorem 4)**: When harmonic variety enters as a second objective, the feasible set exhibits nontrivial Pareto structure: zero-cost (Palestrina-style) and high-variety (Bach-style) points coexist as incomparable Pareto optima.

### 1.3 Related Work

Tymoczko (2006, 2011) pioneered geometric approaches to voice leading using continuous orbifold geometry. Mazzola (1990, 2002) developed algebraic and category-theoretic models of musical structure. Agmon (1997) and Clough & Myerson (1985) formalized aspects of diatonic theory. Our approach differs in using discrete tropical optimization rather than continuous geometry, enabling machine-verified proofs and certified algorithms.

In tropical mathematics, connections to phylogenetics (Pachter & Sturmfels, 2004), neural networks (Zhang et al., 2018), and optimal transport (Léonard, 2012) are well established. To our knowledge, this is the first application of tropical algebra to counterpoint theory.

## 2. Mathematical Setup

### 2.1 Basic Definitions

**Definition 2.1** (Melody). A melody of length n+1 is a function v : Fin(n+1) → ℤ, mapping time indices to integer pitch values (MIDI numbers).

**Definition 2.2** (Vertical Interval). For melodies u, v of length n+1, the vertical interval at position i is:
```
verticalInterval(u, v, i) = v(i) - u(i)
```

**Definition 2.3** (Consonance Classification).
- Perfect consonances: k is a perfect consonance if |k| ∈ {0, 7, 12} (unison, fifth, octave).
- Imperfect consonances: k is an imperfect consonance if |k| ∈ {3, 4, 8, 9} (thirds and sixths).
- Consonant: k is consonant if it is perfect or imperfect.

### 2.2 Penalty Functions

**Definition 2.4** (Forbidden Vertical Penalty).
```
forbiddenVerticalPenalty(k) = if consonant(k) then 0 else 1
```

**Definition 2.5** (Melodic Leap Penalty).
```
melodicLeapPenalty(x, y) = max(0, |y - x| - 2)
```

**Definition 2.6** (Parallel Perfect Penalty).
```
parallelPerfectPenalty(u, v, i) = if perfectConsonance(interval(u,v,i)) ∧ perfectConsonance(interval(u,v,i+1)) then 1 else 0
```

### 2.3 Total Cost Functional

**Definition 2.7** (Total Contrapuntal Cost).
```
totalCost(u, v) = Σᵢ forbiddenVerticalPenalty(interval(u,v,i))
                + Σᵢ melodicLeapPenalty(v(i), v(i+1))
                + Σᵢ parallelPerfectPenalty(u, v, i)
```

### 2.4 First-Species Legality

**Definition 2.8** (FirstSpeciesLegal). A pair (u, v) is first-species legal if:
1. ∀i, consonant(verticalInterval(u, v, i))
2. ∀i, ¬(perfectConsonance(interval(u,v,i)) ∧ perfectConsonance(interval(u,v,i+1)))
3. ∀i, |v(i+1) - v(i)| ≤ 2

## 3. Main Results

### 3.1 Theorem 1: Zero-Cost Equivalence

**Theorem 3.1** (firstSpecies_iff_zeroCost). For any melodies u, v of length n+1:
```
FirstSpeciesLegal(u, v) ↔ totalCost(u, v) = 0
```

*Proof Sketch.* The proof proceeds in three stages:

1. **Nonnegativity**: Each penalty term is nonneg (forbiddenVerticalPenalty ∈ {0,1}, melodicLeapPenalty = max(0,·) ≥ 0, parallelPerfectPenalty ∈ {0,1}).

2. **Zero characterization**: Each penalty equals zero iff its corresponding rule holds:
   - forbiddenVerticalPenalty(k) = 0 ↔ consonant(k)
   - melodicLeapPenalty(x,y) = 0 ↔ |y-x| ≤ 2
   - parallelPerfectPenalty(u,v,i) = 0 ↔ ¬(both consecutive intervals are perfect)

3. **Sum decomposition**: Since totalCost is a sum of three sums of nonneg terms, it equals zero iff every summand is zero. By the Finset.sum_eq_zero_iff_of_nonneg lemma, this is equivalent to each individual penalty being zero, which is equivalent to all three conditions of FirstSpeciesLegal.

The forward direction (legal → zero cost) substitutes the rule conditions directly. The backward direction (zero cost → legal) uses the nonneg sum decomposition. □

### 3.2 Theorem 2: Strict-Style Dominance

**Definition 3.2** (Weighted Total Cost).
```
weightedTotalCost(A, B, C, u, v) = A·Σvertical + B·Σmelodic + C·Σparallel
```

**Theorem 3.3** (minimizer_is_legal). Let S be a finite set of melodies, u a cantus firmus, and A, B, C > 0 real-valued penalty weights. If there exists a legal witness w ∈ S with FirstSpeciesLegal(u, w), and v ∈ S minimizes weightedTotalCost over S, then FirstSpeciesLegal(u, v).

*Proof Sketch.* Since w is legal, by Theorem 3.1, totalCost(u, w) = 0, and hence each penalty sum vanishes. Therefore weightedTotalCost(A, B, C, u, w) = 0.

Since v minimizes over S, weightedTotalCost(u, v) ≤ weightedTotalCost(u, w) = 0. But each term A·Σvertical, B·Σmelodic, C·Σparallel is nonneg (product of positive weight and nonneg sum), so weightedTotalCost(u, v) ≥ 0. Hence weightedTotalCost(u, v) = 0.

Since A > 0 and A·Σvertical = 0, we get Σvertical = 0. Similarly for B·Σmelodic and C·Σparallel. All penalty sums vanish, so totalCost(u, v) = 0, and by Theorem 3.1, FirstSpeciesLegal(u, v). □

### 3.3 Theorem 3: Tropical Bellman Recursion

**Definition 3.4** (DP Value Function). Over a finite pitch set Y with cantus sequence:
```
dpValue(0, x) = dpCostBase(cantus(0), x)
dpValue(k+1, x) = min_{y ∈ Y} (dpTransition(cantus(k), cantus(k+1), y, x) + dpValue(k, y))
```

**Theorem 3.5** (tropical_bellman). For nonempty Y:
```
dpValue(k+1, x) = Y.inf' (fun y => dpTransition(y, x) + dpValue(k, y))
```

**Theorem 3.6** (tropical_plus_distributes_over_min_real). For a, b, c ∈ ℝ:
```
a + min(b, c) = min(a + b, a + c)
```

This tropical distributivity law is the algebraic engine powering the Bellman recursion.

**Theorem 3.7** (dpValue_le_pathCost). For any path p with all values in Y:
```
dpValue(n, p(n)) ≤ pathCost(n, p)
```

*Proof Sketch.* By induction on n. The base case is immediate. For the inductive step, dpValue(n+1, p(n+1)) = min_y(transition(y, p(n+1)) + dpValue(n, y)) ≤ transition(p(n), p(n+1)) + dpValue(n, p(n)) ≤ transition(p(n), p(n+1)) + pathCost(n, p|_{≤n}) = pathCost(n+1, p). □

*Complexity*. The DP algorithm runs in O(n·P²) time and O(n·P) space, where n is melody length and P is the pitch alphabet size.

### 3.4 Theorem 4: Pareto Tradeoff

**Definition 3.8** (Harmonic Variety).
```
harmonicVariety(u, v) = |{verticalInterval(u, v, i) : i ∈ Fin(n+1)}|
```

**Definition 3.9** (Pareto Dominance). v Pareto-dominates w (with respect to u) if:
- totalCost(u, v) ≤ totalCost(u, w)
- harmonicVariety(u, w) ≤ harmonicVariety(u, v)
- At least one inequality is strict.

**Theorem 3.10** (exists_pareto_optimal). Every nonempty finite set S contains a Pareto-optimal point.

*Proof.* Take the cost-minimizer; among cost-minimizers, take the variety-maximizer. This point cannot be dominated: any dominator would need equal or lower cost (impossible, since we started with the minimum) and strictly higher variety (impossible, since we maximized variety among cost-minimizers). □

**Theorem 3.11** (pareto_incomparable_of_variety_gain). If v_strict is legal (cost = 0) and v_rich has positive cost with strictly higher variety, then neither dominates the other.

*Proof.* v_strict can't dominate v_rich because variety(v_strict) < variety(v_rich). v_rich can't dominate v_strict because cost(v_rich) > 0 = cost(v_strict). □

**Theorem 3.12** (exists_two_pareto_points). Under the hypotheses of Theorem 3.11, the set S contains both a Pareto-optimal zero-cost melody and a Pareto-optimal melody with variety strictly exceeding that of v_strict.

*Proof Sketch.* For part 1: Apply the domination lemma (exists_pareto_dominating) to v_strict. Since cost is nonneg and the dominating point has cost ≤ cost(v_strict) = 0, its cost must be 0. For part 2: Apply the domination lemma to v_rich. The dominating Pareto point has variety ≥ variety(v_rich) > variety(v_strict). □

## 4. Algorithms

### 4.1 Tropical DP for Optimal Voice Leading

```
Algorithm 1: TROPICAL-DP-VOICE-LEADING(cantus, pitchRange, weights)
Input: cantus firmus u[0..n-1], pitch set P, weights (A, B, C)
Output: optimal melody v[0..n-1], optimal cost

1. For each x ∈ P: dp[0][x] ← A · forbiddenVerticalPenalty(x - u[0])
2. For k = 1 to n-1:
3.   For each x ∈ P:
4.     dp[k][x] ← min_{y ∈ P} (A·vert(x,u[k]) + B·mel(y,x) + C·par(y,x) + dp[k-1][y])
5.     parent[k][x] ← argmin of line 4
6. opt ← argmin_{x ∈ P} dp[n-1][x]
7. Backtrack: v[n-1] ← opt; for k = n-2 downto 0: v[k] ← parent[k+1][v[k+1]]
8. Return v, dp[n-1][opt]

Time: O(n · |P|²)    Space: O(n · |P|)
```

### 4.2 Pareto Frontier Computation

```
Algorithm 2: PARETO-FRONTIER(cantus, candidates)
Input: cantus u, candidate melodies S
Output: Pareto-optimal subset P ⊆ S

1. For each m ∈ S: compute (cost(m), variety(m))
2. P ← ∅
3. For each m ∈ S:
4.   If no m' ∈ S dominates m: P ← P ∪ {m}
5. Return P sorted by cost

Time: O(|S|²)    Space: O(|S|)
```

## 5. Computational Experiments

### 5.1 Theorem 1 Verification

We verify the zero-cost equivalence on a cantus firmus C4-D4-E4-F4-G4:

| Melody | Intervals | Cost | Legal |
|--------|-----------|------|-------|
| G4-F#4-G4-G#4-G4 | 7,4,3,3,0 | 0.0 | ✓ |
| C#4-F#4-G4-G#4-G4 | 1,4,3,3,0 | 4.0 | ✗ |
| G4-A4-B4-C5-D5 | 7,7,7,7,7 | 4.0 | ✗ |

### 5.2 Pareto Frontier

Over a cantus of length 8 with ~1.4 million candidate melodies:
- 65 Pareto-optimal points identified
- 19 legal (zero-cost) Pareto points with variety up to 7
- 46 higher-variety Pareto points with positive cost (variety up to 8)
- Clear transition at λ ≈ 1.5 in Bach score optimization

### 5.3 Bach Score Analysis

As the variety reward λ increases from 0 to 5:

| λ | Optimal Cost | Variety | Legal |
|---|-------------|---------|-------|
| 0.0 | 0.0 | 4 | ✓ |
| 0.5 | 0.0 | 7 | ✓ |
| 1.0 | 0.0 | 7 | ✓ |
| 2.0 | 1.0 | 8 | ✗ |
| 5.0 | 1.0 | 8 | ✗ |

The transition from legal to illegal optimal solutions occurs near λ = 1.5, representing the style boundary between strict Palestrina counterpoint and harmonically richer Bach-style writing.

## 6. Discussion

### 6.1 Interpretation

Our results formalize three key insights:

1. **Style as feasibility**: Musical style is not arbitrary preference but a precise algebraic condition. Palestrina counterpoint = tropical zero locus.

2. **Style as scale separation**: When rule-violation penalties dominate motion costs, optimization produces legal compositions automatically. Style emerges from the relative scaling of different objectives.

3. **Style as Pareto geometry**: Different historical styles correspond to different regions of a multi-objective optimization landscape. The "Bach saddle" is a Pareto-optimal point that is not cost-minimal but variety-maximal under cost constraints.

### 6.2 Connections

**Formal verification**: The legal/illegal dichotomy corresponds to safety/violation in temporal logic monitoring. The total cost is a robustness measure: zero means exactly on the specification boundary.

**Sequence alignment**: Voice leading is structurally identical to sequence alignment in bioinformatics: local transition penalties, global optimization via DP, tropical algebraic structure.

**Neural networks**: Recent work shows that ReLU neural networks compute tropical polynomials. Our cost functions are piecewise-linear, hence tropical. The counterpoint optimization landscape is, in a precise sense, the same kind of object that neural networks learn to navigate.

### 6.3 Limitations

- The model treats only two voices; polyphonic texture requires extension.
- Pitch is modeled in absolute semitones rather than pitch-class space (mod 12).
- The consonance classification is simplified (no distinction between melodic and harmonic intervals in context).
- Rhythm is not modeled (first species only).

## 7. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. Key next steps include: extension to four-part writing via layered tropical optimization, tropical rate-distortion theory for harmonic variety, categorical semantics of compositional operations, and connections to discrete optimal transport.

## 8. References

1. Agmon, E. (1997). Musical durations as mathematical intervals. *Music Theory Spectrum*, 19(2).
2. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
3. Léonard, C. (2012). From the Schrödinger problem to the Monge-Kantorovich problem. *J. Funct. Anal.*, 262(4).
4. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
5. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
6. Pachter, L. & Sturmfels, B. (2004). Tropical geometry of statistical models. *PNAS*, 101(46).
7. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783).
8. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
9. Zhang, L. et al. (2018). Tropical geometry of deep neural networks. *ICML*.
