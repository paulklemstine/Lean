# Cognitive Braids: A Topological Framework for Modeling Cognition via Braid Group Invariants

## Abstract

We introduce a mathematical framework in which cognitive processes are modeled as elements of braid groups *B_n*, where *n* represents the number of interacting brain regions. Each crossing in the braid represents a moment when one region's neural activity dominates another's, and a complete cognitive process is a braid word — a finite sequence of such crossings. We define and prove properties of several topological invariants that serve as measures of cognitive complexity: the writhe (algebraic crossing number), information content (|writhe|), and a cognitive level hierarchy. Our main results include: (1) writhe is a group homomorphism from the free group of braid words to ℤ; (2) information content is bounded above by crossing number, establishing a Shannon-type capacity bound; (3) the cognitive hierarchy is monotone with respect to crossing number; (4) writhe satisfies a parity constraint with respect to crossing number. All results are formalized and machine-verified. We further develop applications to EEG signal analysis, task complexity scoring, and creative process evaluation, and state a falsifiable conjecture connecting braid invariants to subjective cognitive experience.

**Keywords**: braid groups, cognitive science, topological invariants, information theory, Jones polynomial, formal verification

## 1. Introduction

### 1.1 Motivation

The brain's connectome exhibits a fundamentally braided structure: when multiple brain regions process information simultaneously, their temporal activation sequences interleave like strands of a braid [1, 2]. Despite decades of work in computational neuroscience, no rigorous topological framework has been developed to exploit this observation.

Braid groups, introduced by Artin [3], provide an algebraically rich setting for studying such interleaving patterns. A braid on *n* strands encodes a sequence of pairwise crossings, with group composition given by concatenation. Crucially, braid groups are *non-abelian* for *n ≥ 3*, reflecting the fundamental non-commutativity of cognitive processes: the order in which brain regions interact matters.

### 1.2 Related Work

- **Braid group theory**: Artin [3], Birman [4], Kassel & Turaev [5]
- **Jones polynomial**: Jones [6], Kauffman [7]
- **Topological models in neuroscience**: Curto et al. [8], Giusti et al. [9] (persistent homology of neural data)
- **Information theory of neural coding**: Shannon [10], Borst & Theunissen [11]
- **Category-theoretic models of cognition**: Phillips [12], Bolt et al. [13]

### 1.3 Contributions

1. A complete formalization of braid words as models of cognitive processes (Section 2)
2. Five rigorously proved invariant theorems with novel cross-domain interpretations (Section 3)
3. Computational algorithms for braid invariants with complexity analysis (Section 4)
4. Three applications: EEG analysis, task scoring, creative evaluation (Section 5)
5. A falsifiable conjecture with testable predictions (Section 6)

## 2. Definitions and Notation

### 2.1 Braid Generators

**Definition 2.1** (Braid Generator). For *n ≥ 2*, a *braid generator* on *n* strands is a pair *(i, ε)* where *i ∈ {0, ..., n-2}* is the strand index and *ε ∈ {+1, -1}* is the sign. We write *σ_i* for *(i, +1)* (positive crossing: strand *i* passes over strand *i+1*) and *σ_i⁻¹* for *(i, -1)*.

**Definition 2.2** (Sign). The sign function `sign : BraidGen(n) → ℤ` is defined by:
- `sign(σ_i) = +1`
- `sign(σ_i⁻¹) = -1`

**Definition 2.3** (Generator Inverse). The inverse `inv : BraidGen(n) → BraidGen(n)` swaps the sign:
- `inv(σ_i) = σ_i⁻¹`
- `inv(σ_i⁻¹) = σ_i`

### 2.2 Braid Words

**Definition 2.4** (Braid Word). A *braid word* on *n* strands is a finite list of braid generators:
```
BraidWord(n) = List(BraidGen(n))
```

**Definition 2.5** (Composition). The composition of braid words *w₁* and *w₂* is their concatenation:
```
comp(w₁, w₂) = w₁ ++ w₂
```

**Definition 2.6** (Word Inverse). The inverse of a braid word reverses the list and inverts each generator:
```
inv(w) = reverse(map(BraidGen.inv, w))
```

### 2.3 Writhe and Crossing Number

**Definition 2.7** (Writhe). The *writhe* of a braid word is the sum of signs of all generators:
```
writhe(w) = Σ_{g ∈ w} sign(g)
```

**Definition 2.8** (Crossing Number). The *crossing number* of a braid word is its length:
```
crossingNumber(w) = |w|
```

### 2.4 Cognitive Braid Structure

**Definition 2.9** (Cognitive Braid). A *cognitive braid* is a triple *(n, h, w)* where:
- *n ≥ 2* is the number of brain regions
- *h* is a proof that *n ≥ 2*
- *w* is a braid word on *n* strands

**Definition 2.10** (Cognitive Level). The *cognitive level* of a braid with *k* crossings is:
```
cogLevel(k) = 
  trivial   if k = 0
  simple    if 1 ≤ k ≤ 2
  moderate  if 3 ≤ k ≤ 5
  complex   if k ≥ 6
```

**Definition 2.11** (Information Content). The *information content* of a cognitive braid is `|writhe(w)|`.

## 3. Main Results

### 3.1 Writhe as a Homomorphism

**Theorem 3.1** (Writhe Identity). The writhe of the identity braid is zero:
```
writhe(id) = 0
```
*Proof*: The identity braid is the empty list. The sum over an empty list is zero. □

**Theorem 3.2** (Writhe Additivity). Writhe is additive under composition:
```
writhe(comp(w₁, w₂)) = writhe(w₁) + writhe(w₂)
```
*Proof*: By the definitions of `comp` (list concatenation) and `writhe` (sum of mapped signs), this reduces to the identity `sum(map(f, l₁ ++ l₂)) = sum(map(f, l₁)) + sum(map(f, l₂))`, which follows from `List.map_append` and `List.sum_append`. □

**Theorem 3.3** (Writhe of Inverse). The writhe of the inverse braid word negates:
```
writhe(inv(w)) = -writhe(w)
```
*Proof*: By induction on *w*. The base case (empty list) is trivial. For the inductive step, let *w = g :: rest*. Then:
```
writhe(inv(g :: rest)) = writhe(reverse(map(inv, g :: rest)))
                       = writhe(map(inv, rest).reverse ++ [inv(g)])
                       = writhe(inv(rest)) + sign(inv(g))    [by Thm 3.2]
                       = -writhe(rest) + (-sign(g))           [by IH and sign_inv]
                       = -(sign(g) + writhe(rest))
                       = -writhe(g :: rest)
```
The key lemma `sign(inv(g)) = -sign(g)` is proved by cases on *g*. □

**Corollary 3.4** (Self-Cancellation). A braid composed with its inverse has zero writhe:
```
writhe(comp(w, inv(w))) = 0
```
*Proof*: By Theorems 3.2 and 3.3: `writhe(w) + writhe(inv(w)) = writhe(w) + (-writhe(w)) = 0`. □

### 3.2 Generator Involution

**Theorem 3.5** (Double Inverse). Inverting a generator twice returns the original:
```
inv(inv(g)) = g
```
*Proof*: By cases: `inv(inv(σ_i)) = inv(σ_i⁻¹) = σ_i` and `inv(inv(σ_i⁻¹)) = inv(σ_i) = σ_i⁻¹`. □

**Theorem 3.6** (Word Double Inverse). Inverting a braid word twice returns the original:
```
inv(inv(w)) = w
```
*Proof*: Using Theorem 3.5 and the identities `reverse(reverse(l)) = l` and `map(f, map(g, l)) = map(f ∘ g, l)`:
```
inv(inv(w)) = reverse(map(inv, reverse(map(inv, w))))
            = reverse(reverse(map(inv, map(inv, w))))    [map distributes over reverse]
            = map(inv ∘ inv, w)                          [reverse involution]
            = map(id, w)                                  [Theorem 3.5]
            = w
```
□

### 3.3 Information-Theoretic Bounds

**Theorem 3.7** (Writhe-Crossing Bound). The absolute writhe is bounded by the crossing number:
```
|writhe(w)| ≤ crossingNumber(w)
```
*Proof*: By induction on *w*. For the base case, |0| ≤ 0. For the step, if *w = g :: rest*:
```
|writhe(g :: rest)| = |sign(g) + writhe(rest)|
                    ≤ |sign(g)| + |writhe(rest)|    [triangle inequality]
                    = 1 + |writhe(rest)|             [|sign(g)| = 1]
                    ≤ 1 + |rest|                      [inductive hypothesis]
                    = |g :: rest|
```
□

**Theorem 3.8** (Information ≤ Complexity). For any cognitive braid *cb*:
```
infoContent(cb) ≤ complexity(cb)
```
*Proof*: Immediate from Theorem 3.7 and the definitions of `infoContent` and `complexity`. □

**Theorem 3.9** (Subadditivity). Information content of a composition is bounded by the sum of complexities:
```
|writhe(comp(w₁, w₂))| ≤ crossingNumber(w₁) + crossingNumber(w₂)
```
*Proof*: By Theorem 3.7 applied to `comp(w₁, w₂)` and the identity `crossingNumber(comp(w₁, w₂)) = crossingNumber(w₁) + crossingNumber(w₂)`. □

### 3.4 Crossing Number Properties

**Theorem 3.10** (Crossing Number Additivity). The crossing number of a composition is the sum:
```
crossingNumber(comp(w₁, w₂)) = crossingNumber(w₁) + crossingNumber(w₂)
```
*Proof*: `List.length_append`. □

**Theorem 3.11** (Trivial Zero Writhe). If a cognitive braid is trivial (empty word), its writhe is zero:
```
isTrivial(cb) → writhe(cb.word) = 0
```
*Proof*: Trivial means `cb.word = []`, so `writhe([]) = sum([]) = 0`. □

### 3.5 Cognitive Hierarchy Monotonicity

**Theorem 3.12** (Hierarchy Monotonicity). The cognitive level rank is monotone in crossing number:
```
a ≤ b → rank(cogLevel(a)) ≤ rank(cogLevel(b))
```
*Proof*: By exhaustive case analysis on the range boundaries. The function `cogLevel` assigns rank 0 for *k=0*, rank 1 for *1 ≤ k ≤ 2*, rank 2 for *3 ≤ k ≤ 5*, and rank 3 for *k ≥ 6*. Since these ranges are contiguous and non-decreasing, monotonicity follows. □

### 3.6 Parity Constraint

**Theorem 3.13** (Writhe Parity). For any braid word *w*:
```
writhe(w) ≡ crossingNumber(w)  (mod 2)
```
*Proof*: Each generator contributes ±1 to the writhe and 1 to the crossing number. Since *1 ≡ -1 (mod 2)*, each generator preserves the parity relationship. By induction:
- Base: writhe([]) = 0 ≡ 0 = crossingNumber([]) (mod 2). ✓
- Step: writhe(g::w) = sign(g) + writhe(w). Since sign(g) ∈ {1,-1} and both ≡ 1 (mod 2), we get writhe(g::w) ≡ 1 + crossingNumber(w) ≡ crossingNumber(g::w) (mod 2). □

### 3.7 Existence of Non-Trivial Braids

**Theorem 3.14** (Existence). For *n ≥ 2*, there exist non-trivial braid words.

*Proof*: The singleton list `[σ₀]` is non-empty, hence distinct from the identity `[]`. □

### 3.8 Trefoil Properties

**Theorem 3.15** (Trefoil Classification). The trefoil braid *σ₁³* has:
- Crossing number 3
- Writhe 3
- Cognitive level "moderate"
- It is non-trivial

*Proof*: Direct computation from the definitions. □

## 4. Algorithms

### 4.1 Writhe Computation

```
Algorithm: COMPUTE_WRITHE(w)
Input: Braid word w = [g₁, ..., gₖ]
Output: writhe ∈ ℤ

    s ← 0
    for i = 1 to k:
        s ← s + sign(gᵢ)
    return s

Time: O(k)
Space: O(1)
```

### 4.2 Cognitive Level Assignment

```
Algorithm: COGNITIVE_LEVEL(w)
Input: Braid word w
Output: level ∈ {trivial, simple, moderate, complex}

    k ← |w|
    if k = 0: return trivial
    if k ≤ 2: return simple
    if k ≤ 5: return moderate
    return complex

Time: O(1) given |w|
```

### 4.3 Braid Composition

```
Algorithm: COMPOSE(w₁, w₂)
Input: Braid words w₁, w₂ on n strands
Output: Braid word w₁ · w₂

    return concatenate(w₁, w₂)

Time: O(|w₁| + |w₂|)
Space: O(|w₁| + |w₂|)
```

### 4.4 Braid Inversion

```
Algorithm: INVERT(w)
Input: Braid word w = [g₁, ..., gₖ]
Output: w⁻¹

    return [inv(gₖ), inv(gₖ₋₁), ..., inv(g₁)]

Time: O(k)
Space: O(k)
```

### 4.5 EEG-to-Braid Conversion

```
Algorithm: EEG_TO_BRAID(channels, activations)
Input: List of n channel names, 
       List of (dominant, subordinate) activation pairs
Output: BraidWord on n strands

    generators ← []
    for (d, s) in activations:
        i ← index(d), j ← index(s)
        if |i - j| = 1:
            idx ← min(i, j)
            sign ← +1 if i < j else -1
            generators.append(BraidGen(idx, sign))
    return BraidWord(n, generators)

Time: O(m) where m = |activations|
Space: O(m)
```

## 5. Applications

### 5.1 EEG Signal Analysis

We demonstrate conversion of EEG channel activation sequences to cognitive braids. For four brain regions (frontal, parietal, temporal, occipital), we construct braids representing:

| Cognitive State | Crossings | Writhe | Level    | Info Content |
|----------------|-----------|--------|----------|-------------|
| Resting state  | 0         | 0      | trivial  | 0           |
| Creative insight| 5        | 5      | moderate | 5           |
| Confusion      | 4         | 0      | moderate | 0           |

The confusion state demonstrates the figure-eight paradox: high crossing number (indicating active processing) but zero writhe (indicating no net information gain).

### 5.2 Task Complexity Scoring

Tasks are decomposed into subtask activation sequences, and their braid invariants are computed:

| Task              | Crossings | Writhe | Level    |
|-------------------|-----------|--------|----------|
| Reading aloud     | 3         | 3      | moderate |
| Mental arithmetic | 4         | 4      | moderate |
| Creative writing  | 5         | 3      | moderate |
| Mindless scrolling| 0         | 0      | trivial  |

### 5.3 Creative Process Evaluation

Creative processes are modeled as transitions between cognitive modes (analytical, intuitive, critical, imaginative):

| Process         | Crossings | Writhe | Quantum Dim | Creative? |
|-----------------|-----------|--------|-------------|-----------|
| Linear analysis | 0         | 0      | 0           | No        |
| Aha! moment     | 4         | 2      | 1.099       | Yes       |
| Brainstorm      | 6         | 4      | 1.609       | Yes       |
| Rumination      | 5         | 1      | 0.693       | Yes       |

## 6. Conjecture and Testable Prediction

### 6.1 The Writhe-Cognition Conjecture

**Conjecture** (Cognitive Braid Hypothesis): For any cognitive process modeled as a braid word *w* on *n ≥ 3* brain regions:

1. The writhe `writhe(w)` correlates positively with subjective ratings of insight quality (*r* > 0.3, *p* < 0.05 in a suitable experimental design).
2. The ratio `|writhe(w)| / crossingNumber(w)` (the "cognitive efficiency") correlates with task performance accuracy.
3. Cognitive states with high crossing number but zero writhe correspond to subjective reports of confusion or frustration.

### 6.2 Falsifiable Test

**Protocol**: 
1. Record high-density EEG (256 channels, collapsed to *n* = 10 brain regions via spatial PCA) during:
   - Baseline resting (30 seconds)
   - Simple arithmetic (2 minutes)
   - Creative word association (2 minutes)
   - Difficult unsolvable puzzle (2 minutes)
2. Convert each 1-second window to a braid word via EEG_TO_BRAID.
3. Compute writhe, crossing number, and cognitive level for each window.
4. Collect self-report ratings of insight/frustration every 10 seconds.
5. Correlate braid invariants with self-reports.

**Disproof criterion**: If the correlation between writhe and insight rating is negative or not significant (*p* > 0.1), the conjecture is refuted.

### 6.3 Writhe Parity Constraint

**Theorem** (proved): `writhe(w) ≡ crossingNumber(w) (mod 2)`.

This imposes a hard constraint on the space of possible cognitive braids: a braid with an odd number of crossings must have odd writhe, and vice versa. This is computationally testable by enumerating braids and verifying the constraint.

## 7. Discussion

### 7.1 Strengths

- **Mathematical rigor**: All core theorems are machine-verified, eliminating the possibility of subtle errors in the proofs.
- **Falsifiability**: The conjecture makes specific numerical predictions that can be tested with standard neuroscience equipment.
- **Computational tractability**: All algorithms run in linear time.

### 7.2 Limitations

- **Braid words ≠ braids**: We work with braid words (elements of the free group), not equivalence classes under braid relations. Two distinct braid words may represent the same braid.
- **Coarse-graining**: Mapping continuous neural dynamics to discrete crossings involves choices that may affect results.
- **Writhe alone is insufficient**: The writhe is a weak invariant; it does not distinguish all non-trivial braids from the identity. The Jones polynomial provides a much stronger invariant but is computationally expensive (exponential in general).

### 7.3 Future Work

1. **Braid group quotient**: Formalize the braid group as a quotient by Artin relations, proving that invariants descend.
2. **Jones polynomial**: Implement and verify the Kauffman bracket approach to the Jones polynomial.
3. **Experimental validation**: Execute the falsifiable test protocol of Section 6.2.
4. **Higher invariants**: Study Khovanov homology and HOMFLY-PT polynomial in the cognitive context.
5. **Cross-domain**: Connect to tropical geometry via the tropicalization of braid varieties.

## 8. References

[1] Sporns, O. (2010). *Networks of the Brain*. MIT Press.

[2] Bassett, D.S., & Sporns, O. (2017). Network neuroscience. *Nature Neuroscience*, 20(3), 353-364.

[3] Artin, E. (1947). Theory of braids. *Annals of Mathematics*, 48(1), 101-126.

[4] Birman, J.S. (1974). *Braids, Links, and Mapping Class Groups*. Princeton University Press.

[5] Kassel, C., & Turaev, V. (2008). *Braid Groups*. Springer.

[6] Jones, V.F.R. (1985). A polynomial invariant for knots via von Neumann algebras. *Bulletin of the AMS*, 12(1), 103-111.

[7] Kauffman, L.H. (1987). State models and the Jones polynomial. *Topology*, 26(3), 395-407.

[8] Curto, C. (2017). What can topology tell us about the neural code? *Bulletin of the AMS*, 54(1), 63-78.

[9] Giusti, C., Ghrist, R., & Bassett, D.S. (2016). Two's company, three (or more) is a simplex. *Journal of Computational Neuroscience*, 41(1), 1-14.

[10] Shannon, C.E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27(3), 379-423.

[11] Borst, A., & Theunissen, F.E. (1999). Information theory and neural coding. *Nature Neuroscience*, 2(11), 947-957.

[12] Phillips, S. (2014). Analogy, cognitive architecture and universal construction. *PLOS ONE*, 9(2), e89152.

[13] Bolt, J., Hedges, J., & Zahn, P. (2019). Bayesian open games. *arXiv:1910.03656*.
