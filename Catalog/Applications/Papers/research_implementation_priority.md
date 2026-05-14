# Pareto Rigidity and Transposition Invariance on Pitch-Class Space ℤ/12ℤ

## Abstract

We establish a rigidity theorem for Pareto-optimal voice leadings on the pitch-class space ℤ/12ℤ equipped with the cyclic distance metric. We prove that the Pareto dominance relation between voice assignments is invariant under the natural transposition action of ℤ/12ℤ, implying that Pareto optimality descends to the quotient (orbifold) of configuration space. As a corollary, every Pareto-minimality question reduces to a normalized form where the first voice is fixed at pitch class 0. These results are formalized and machine-verified in Lean 4 with the Mathlib library. We provide computational experiments enumerating all Pareto-optimal voice leadings between standard triad classes, and discuss connections to discrete optimal transport, tropical geometry, and rate-distortion theory.

**Keywords:** Pareto optimality, pitch-class space, cyclic distance, transposition invariance, voice leading, optimal transport, orbifold geometry

---

## 1. Introduction

### 1.1 Motivation

Voice leading — the art of moving individual voices smoothly between successive chords — is a central concern of Western music theory. The mathematical study of voice leading was placed on rigorous geometric foundations by Tymoczko [1], who identified the configuration space of n-voice chords with orbifolds obtained from ℝⁿ by quotienting by permutation and octave equivalence. Subsequent work by Callender, Quinn, and Tymoczko [2] developed the theory of chord-class geometry using continuous pitch spaces.

However, the finite case — pitch classes in ℤ/nℤ — admits exact combinatorial analysis that complements the continuous theory. In this paper, we work entirely within ℤ/12ℤ (the standard chromatic pitch-class space) and establish rigidity theorems for Pareto-optimal voice leadings under the cyclic transposition action.

### 1.2 Contributions

1. **Cyclic distance metric lemmas:** We define and prove basic properties (reflexivity, symmetry, translation invariance, boundedness) of the cyclic distance on ℤ/12ℤ.

2. **Pareto dominance invariance:** We prove that the Pareto dominance relation between voice assignments is invariant under simultaneous transposition of source and target configurations.

3. **Pareto optimality rigidity:** We establish that Pareto-optimal voice assignments descend to the quotient of configuration space under the transposition action.

4. **Normal-form reduction:** We prove that every Pareto-minimality question reduces to a canonical form where the first voice is at pitch class 0.

5. **Machine verification:** All results are formalized in Lean 4 using the Mathlib library, providing the highest level of mathematical certainty.

6. **Computational experiments:** We enumerate Pareto-optimal voice leadings between standard triad classes and analyze the cost landscape.

### 1.3 Related Work

Tymoczko [1] introduced the geometric perspective on voice leading using continuous orbifolds. Callender, Quinn, and Tymoczko [2] developed OPTIC equivalence classes for chord comparison. Hook [3] studied uniform triadic transformations using group-theoretic methods. Fiore and Satyendra [4] applied category theory to musical transformations. Yust [5] connected voice leading to discrete Fourier analysis on ℤ/12ℤ.

Our work differs in its focus on Pareto optimality (rather than minimum cost alone) and in providing machine-verified proofs via formal methods.

---

## 2. Definitions and Notation

### 2.1 Pitch-Class Space

Let **pc** = ℤ/12ℤ denote the set of pitch classes under octave equivalence. Elements are residues modulo 12, with 0 = C, 1 = C#, ..., 11 = B.

### 2.2 Cyclic Distance

**Definition 2.1** (Raw distance). For a, b ∈ pc, define
$$\text{rawDist}(a, b) = (a - b) \bmod 12 \in \{0, 1, \ldots, 11\}.$$

**Definition 2.2** (Cyclic distance). For a, b ∈ pc, define
$$d(a, b) = \min(\text{rawDist}(a, b), \; 12 - \text{rawDist}(a, b)).$$

This is the minimum arc length between a and b on the 12-element cycle, with values in {0, 1, ..., 6}.

### 2.3 Voice Configurations

An **n-voice configuration** is a function x : Fin n → pc assigning a pitch class to each voice. For n = 3, this models a three-voice chord.

**Definition 2.3** (Transposition). For t ∈ pc, the transposition of x by t is
$$T_t(x)(i) = x(i) + t.$$

### 2.4 Voice-Leading Cost

**Definition 2.4** (Voice-leading cost). For n-voice configurations x, y, the voice-leading cost is
$$\text{VLC}(x, y) = \sum_{i=0}^{n-1} d(x(i), y(i)).$$

### 2.5 Voice Assignment and Pareto Dominance

**Definition 2.5** (Assignment cost). Given source and target configurations s, t : Fin n → pc and a permutation σ ∈ S_n, the assignment cost is
$$C(s, t, \sigma) = \sum_{i=0}^{n-1} d(s(i), t(\sigma(i))).$$

**Definition 2.6** (Assignment dominance). Permutation σ **Pareto-dominates** τ for the pair (s, t) if:
1. ∀i: d(s(i), t(σ(i))) ≤ d(s(i), t(τ(i))),
2. ∃j: d(s(j), t(σ(j))) < d(s(j), t(τ(j))).

**Definition 2.7** (Pareto optimality). An assignment τ is **Pareto-optimal** for (s, t) if no σ ∈ S_n dominates τ.

### 2.6 Normal Form

**Definition 2.8** (Normalization). For a 3-voice configuration x, the normalized form is
$$\hat{x}(i) = x(i) - x(0).$$
This places the first voice at pitch class 0.

---

## 3. Main Results

### 3.1 Metric Lemmas

**Theorem 3.1** (Reflexivity). For all a ∈ pc: d(a, a) = 0.

*Proof.* rawDist(a, a) = (a - a) mod 12 = 0, so d(a, a) = min(0, 12) = 0. □

**Theorem 3.2** (Symmetry). For all a, b ∈ pc: d(a, b) = d(b, a).

*Proof sketch.* If a = b, both sides are 0. If a ≠ b, then (a - b) + (b - a) ≡ 0 (mod 12), so rawDist(a, b) + rawDist(b, a) = 12. Therefore {rawDist(a,b), 12 - rawDist(a,b)} = {rawDist(b,a), 12 - rawDist(b,a)} as sets, and min is symmetric. □

**Theorem 3.3** (Translation invariance). For all a, b, t ∈ pc:
$$d(a + t, b + t) = d(a, b).$$

*Proof.* rawDist(a+t, b+t) = ((a+t) - (b+t)) mod 12 = (a - b) mod 12 = rawDist(a, b). The result follows since cycDist depends only on rawDist. □

**Theorem 3.4** (Boundedness). For all a, b ∈ pc: d(a, b) ≤ 6.

*Proof.* Let r = rawDist(a, b) ∈ {0, ..., 11}. Then min(r, 12-r) ≤ 6 since one of r, 12-r is at most 6. □

### 3.2 Cost Invariance

**Theorem 3.5** (Voice-leading cost invariance). For all n, t, x, y:
$$\text{VLC}(T_t(x), T_t(y)) = \text{VLC}(x, y).$$

*Proof.* Each summand d(x(i)+t, y(i)+t) = d(x(i), y(i)) by Theorem 3.3. □

**Theorem 3.6** (Assignment cost invariance). For all n, t, s, t, σ:
$$C(T_t(s), T_t(t), \sigma) = C(s, t, \sigma).$$

*Proof.* Each summand d(s(i)+t, t(σ(i))+t) = d(s(i), t(σ(i))) by Theorem 3.3. □

### 3.3 Dominance and Pareto Invariance

**Theorem 3.7** (Dominance invariance). For all σ, τ ∈ S_n:
$$\sigma \text{ dominates } \tau \text{ for } (s, t) \iff \sigma \text{ dominates } \tau \text{ for } (T_u(s), T_u(t)).$$

*Proof.* Both conditions in Definition 2.6 involve only expressions of the form d(s(i), t(σ(i))), which are invariant under simultaneous translation by Theorem 3.3. □

**Theorem 3.8** (Pareto optimality rigidity — Main Theorem). For all τ ∈ S_n and u ∈ pc:
$$\tau \text{ is Pareto-optimal for } (s, t) \iff \tau \text{ is Pareto-optimal for } (T_u(s), T_u(t)).$$

*Proof.* Pareto optimality is the negation of "∃σ that dominates τ." By Theorem 3.7, dominance of any σ over τ is equivalent for (s,t) and (T_u(s), T_u(t)). Therefore the existential, and its negation, are equivalent. □

**Corollary 3.9.** The set of Pareto-optimal assignments for (s, t) depends only on the transposition-orbit class of (s, t).

### 3.4 Normal-Form Reduction

**Theorem 3.10** (Normal-form reduction). For 3-voice configurations x, y:
$$\tau \text{ is Pareto-optimal for } (x, y) \iff \tau \text{ is Pareto-optimal for } (\hat{x}, y - x(0))$$
where $\hat{x}(i) = x(i) - x(0)$ and $(y - x(0))(i) = y(i) - x(0)$.

*Proof.* Apply Theorem 3.8 with u = -x(0). Then T_u(x)(i) = x(i) - x(0) = x̂(i), and T_u(y)(i) = y(i) - x(0). □

### 3.5 Difference Dependence

**Theorem 3.11** (Cost depends only on differences). If y(i) - x(i) = y'(i) - x'(i) for all i, then VLC(x, y) = VLC(x', y').

*Proof.* The condition implies x(i) - y(i) = x'(i) - y'(i) for all i. Since rawDist(a, b) = (a - b).val depends only on a - b, we have rawDist(x(i), y(i)) = rawDist(x'(i), y'(i)), hence d(x(i), y(i)) = d(x'(i), y'(i)), and the sums agree. □

---

## 4. Algorithms

### 4.1 Cyclic Distance Computation

```
Algorithm CycDist(a, b, n):
    Input: pitch classes a, b ∈ ℤ/nℤ
    Output: cyclic distance d(a, b)
    r ← (a - b) mod n
    return min(r, n - r)
```
**Complexity:** O(1) time, O(1) space.

### 4.2 Optimal Voice Assignment (Brute Force)

```
Algorithm OptimalAssignment(s, t, n, k):
    Input: source s, target t ∈ (ℤ/nℤ)^k
    Output: optimal permutation σ*, minimum cost c*
    c* ← ∞
    for each σ ∈ S_k:
        c ← Σ_{i=0}^{k-1} CycDist(s[i], t[σ[i]], n)
        if c < c*:
            c* ← c, σ* ← σ
    return (σ*, c*)
```
**Complexity:** O(k! · k) time, O(k) space. Practical for k ≤ 6.

For larger k, the Hungarian algorithm provides O(k³) time.

### 4.3 Pareto Frontier Enumeration

```
Algorithm ParetoFrontier(s, t, n, k):
    Input: source s, target t ∈ (ℤ/nℤ)^k
    Output: set of Pareto-optimal permutations
    P ← S_k
    frontier ← ∅
    for each τ ∈ P:
        dominated ← false
        for each σ ∈ P, σ ≠ τ:
            if σ dominates τ:
                dominated ← true; break
        if not dominated:
            frontier ← frontier ∪ {τ}
    return frontier
```
**Complexity:** O(k!² · k) time, O(k!) space.

### 4.4 Normal-Form Reduction

```
Algorithm Normalize(x, k, n):
    Input: configuration x ∈ (ℤ/nℤ)^k
    Output: normalized configuration x̂ with x̂[0] = 0
    offset ← x[0]
    for i = 0 to k-1:
        x̂[i] ← (x[i] - offset) mod n
    return x̂
```
**Complexity:** O(k) time, O(k) space.

---

## 5. Computational Experiments

### 5.1 Distance Structure

The cyclic distance matrix on ℤ/12ℤ exhibits the expected circulant structure. Maximum distance is 6 (tritone), achieved uniquely by pairs separated by 6 semitones.

### 5.2 Optimal Voice-Leading Costs Between Triads

We computed the optimal voice-leading cost between all pairs of root-position major and minor triads. Key findings:

| Source → Target | Optimal Cost | Optimal Assignment |
|---|---|---|
| C maj → C min | 1 | identity (E→E♭) |
| C maj → E min | 1 | identity (E→E, G→G, C→B) |
| C maj → A min | 2 | (2,0,1): C→C, E→A, G→E → reassigned |
| C maj → F maj | 3 | (2,0,1): C→C, E→F, G→A |
| C maj → G maj | 3 | (1,2,0): C→B, E→D, G→G |
| C maj → D min | 5 | identity: C→D, E→F, G→A |

### 5.3 Transposition Invariance Verification

For every pair of triads tested, the optimal voice-leading cost is exactly preserved under all 12 transpositions. The Pareto frontier (set of Pareto-optimal assignments) is also preserved. This computationally confirms Theorems 3.6 and 3.8.

### 5.4 Pareto Frontier Statistics

For most triad-to-triad transitions, the Pareto frontier contains exactly one assignment — the cost-optimal one. This means that for triadic voice leading, the fairness criterion (Pareto optimality) and the efficiency criterion (minimum total cost) typically agree.

### 5.5 Normal-Form Compression

Normalization reduces the source configuration space from 12³ = 1,728 configurations to 12² = 144 distinct interval pairs (with first voice fixed at 0). For classification purposes, this is a 12× reduction that makes exhaustive analysis tractable.

---

## 6. Applications

### 6.1 Automatic Voice Leading

Given a chord progression (sequence of chords), the optimal assignment algorithm produces voice leadings that minimize total semitone displacement. By Theorem 3.8, these assignments are key-independent: transposing the entire progression preserves all voice-leading decisions.

### 6.2 Discrete Optimal Transport

Voice-leading cost is a discrete transport cost on the cyclic group ℤ/12ℤ. The optimal assignment minimizes the Wasserstein-1 distance between the source and target pitch-class distributions. Theorem 3.6 establishes that this Wasserstein distance is transposition-invariant — a finite analogue of the translation-invariance of Wasserstein distances on ℝ.

### 6.3 Certified Harmonic Robustness

If voice leading A has strictly lower cost than voice leading B, this preference is preserved under all transpositions (by Theorem 3.6). This provides a *certificate of robustness*: the preference is structural, not key-dependent. This is a finite analogue of certified robustness results in machine learning.

### 6.4 Harmonic Classification

Theorem 3.10 enables classification of voice leadings by interval coordinates rather than absolute pitch classes. Combined with exhaustive computation, this yields a complete database of optimal voice-leading strategies between chord types.

---

## 7. Discussion

### 7.1 Significance

The Pareto rigidity theorem establishes that voice-leading optimality on ℤ/12ℤ is a quotient-geometric phenomenon: it depends on the orbifold structure (chord shapes modulo transposition) rather than on absolute pitch. This provides a mathematical foundation for the music-theoretic intuition that "voice leading is the same in every key."

### 7.2 Relationship to Prior Work

Our results complement Tymoczko's continuous orbifold theory [1] by providing exact, machine-verified results in the finite case. While the continuous theory uses Riemannian geometry and smooth orbifolds, our approach is purely combinatorial and algebraic, using group actions on finite sets.

### 7.3 Limitations

1. We consider only the cyclic distance metric. Other metrics (e.g., weighted by voice register, or incorporating harmonic context) would require separate treatment.
2. The brute-force algorithms are practical only for small voice counts (k ≤ 6). Larger ensembles require polynomial-time algorithms (Hungarian method).
3. We do not address voice crossing constraints, which are important in traditional counterpoint.

### 7.4 Connection to Tropical Geometry

The cyclic distance d(a,b) = min(rawDist(a,b), 12 - rawDist(a,b)) has a tropical character: it's the minimum (tropical sum) of two linear functions. The assignment cost is a sum (tropical product) of such terms. This places voice-leading optimization within the framework of tropical linear programming, suggesting connections to tropical eigenvalues and the spectral theory of min-plus matrices.

---

## 8. Future Work

1. **Four-voice generalization:** Extend all results to Fin 4 → pc, the setting relevant to SATB (soprano, alto, tenor, bass) voice leading. The quotient space is richer, with connections to 4-dimensional orbifolds.

2. **Optimal transport formulation:** Formulate voice leading as a Kantorovich optimal transport problem with cyclic ground metric, and prove transposition invariance of the Wasserstein distance.

3. **Rate-distortion bridge:** Define a source-coding problem where chord classes are symbols and voice-leading cost is distortion. Prove that the rate-distortion function is transposition-invariant.

4. **Tropical spectral theory:** Encode chord transitions as a weighted graph and study its tropical (min-plus) eigenvalues. The transposition invariance should impart circulant structure to the transition matrix.

5. **Classification theorem:** Achieve a complete classification of Pareto-optimal voice leadings between all triad classes (major, minor, diminished, augmented) up to transposition and permutation equivalence.

---

## 9. References

[1] D. Tymoczko, "A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice," Oxford University Press, 2011.

[2] C. Callender, I. Quinn, D. Tymoczko, "Generalized Voice-Leading Spaces," *Science* 320(5874), 346–348, 2008.

[3] J. Hook, "Uniform Triadic Transformations," *Journal of Music Theory* 46(1/2), 57–126, 2002.

[4] T. M. Fiore, R. Satyendra, "Generalized Contextual Groups," *Music Theory Online* 11(3), 2005.

[5] J. Yust, "Schubert's Harmonic Language and Fourier Phase Space," *Journal of Music Theory* 59(1), 121–181, 2015.

[6] C. Villani, "Optimal Transport: Old and New," Springer, 2008.

[7] D. Maclagan, B. Sturmfels, "Introduction to Tropical Geometry," AMS, 2015.

---

## Appendix: Machine Verification

All theorems in Sections 3.1–3.5 have been formalized and verified in Lean 4 (version 4.28.0) using the Mathlib library. The formalization consists of three modules:

- `Bridges.Mod12Pareto.Defs`: Core definitions (cycDist, voiceLeadCost, Dominates, ParetoMinimal, etc.)
- `Bridges.Mod12Pareto.MetricLemmas`: Theorems 3.1–3.4
- `Bridges.Mod12Pareto.Invariance`: Theorems 3.5, 3.11, and the unconstrained versions of Theorems 3.7–3.10
- `Bridges.Mod12Pareto.Constrained`: Theorems 3.6–3.8, 3.10 for the assignment-based formulation

The proofs use `native_decide` for the finite metric lemmas (exhaustive verification over all 12³ cases), and structural algebraic arguments (congruence, function extensionality) for the invariance theorems. No axioms beyond the standard ones (propext, Classical.choice, Quot.sound) are used.
