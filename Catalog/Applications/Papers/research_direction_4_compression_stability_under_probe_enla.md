# Compression Stability Under Probe Enlargement: A Categorical Data Processing Inequality

## Abstract

We develop a formal theory of **compression stability** for probe families on finite presheaf categories. A probe family is a finite collection of objects used to distinguish elements of a presheaf via their restriction signatures. We prove that enlarging the probe family can only increase the measurement invariant (monotonicity), that equality holds exactly when no new element-level separations are introduced (rigidity), and that any genuinely new separation produces a strict increase (strictness). Together, these results constitute a categorical analogue of the **data processing inequality** from information theory, with a precise equality characterization that connects to the theory of sufficient statistics. All results are machine-verified in Lean 4.

**Keywords:** probe complexity, measurement invariant, data processing inequality, partition refinement, sufficient statistics, categorical dimension theory

---

## 1. Introduction

### 1.1 Motivation

The classical data processing inequality in information theory states that processing data through a deterministic channel cannot increase the mutual information between input and output. This principle has deep consequences: it underpins the theory of sufficient statistics, rate-distortion theory, and the Blackwell ordering of experiments.

We establish a structural analogue of this principle in the setting of finite presheaf categories. Rather than probability distributions and mutual information, our objects are:

- **Presheaves** on a finite discrete category, i.e., families of finite sets indexed by objects with restriction maps.
- **Probe families** — finite subsets of objects used to "observe" presheaf elements via their restriction signatures.
- **Measurement invariants** — the total count of distinguishable probe signatures across all objects.

### 1.2 Summary of Results

Our main contributions are:

1. **Definitions.** We introduce `ObsEq` (observational equivalence), `NoNewSeparation`, `Refines`, and `RedundantOver` — capturing the refinement order on probe families.

2. **Monotonicity (Theorem 1).** If P ⊆ P', then μ(P) ≤ μ(P'), where μ denotes the measurement invariant.

3. **Equality from redundancy (Theorem 2).** If P ⊆ P' and P' introduces no new separations beyond P, then μ(P) = μ(P').

4. **Rigidity (Theorem 3).** Conversely, if μ(P) = μ(P') and P ⊆ P', then P' introduces no new separations.

5. **Iff characterization (Theorem 4).** Combining Theorems 2 and 3: μ(P) = μ(P') iff NoNewSeparation(P, P').

6. **Strict monotonicity (Theorem 5).** If P ⊆ P' and P' separates some pair that P does not, then μ(P) < μ(P').

7. **Saturation (Theorem 6).** If P already separates all elements (injective signatures), then any P' ⊇ P has μ(P') = μ(P).

8. **Abstract refinement (Lemma).** A foundational lemma on image cardinality under function refinement, applicable independently of the presheaf setting.

### 1.3 Related Work

- **Shannon (1948):** The data processing inequality for mutual information.
- **Blackwell (1953):** Comparison of experiments via sufficiency and the Blackwell ordering.
- **Yoneda lemma:** The principle that representable functors separate morphisms.
- **Probe complexity (Harmonic catalog):** The quantitative theory of how many probes are needed to separate morphisms in a finite category.

Our work extends the probe complexity theory from qualitative separation to quantitative measurement invariants, and from the morphism level to the presheaf element level.

---

## 2. Definitions and Setup

### 2.1 Finite Presheaf Model

Let **Ob** be a finite type with decidable equality. A **presheaf** on the discrete category **Ob** consists of:
- A family of finite types F : Ob → Type
- Restriction maps r : ∀ Y Z, F(Y) → F(Z)

A **probe family** is a finite subset P ⊆ Ob.

### 2.2 Probe Signatures

The **probe signature** of an element x ∈ F(Y) with respect to probe family P is:

```
sig_P(x) = (r(Y, Z)(x))_{Z ∈ P} : ∏_{Z ∈ P} F(Z)
```

This is the "fingerprint" of x as seen through the probes.

### 2.3 Measurement Invariants

The **measurement space image cardinality** at object Y is:

```
μ_Y(P) = |{sig_P(x) : x ∈ F(Y)}|
```

The **measurement invariant** is:

```
μ(P) = Σ_Y μ_Y(P)
```

### 2.4 Observational Equivalence

Two elements x, y ∈ F(Y) are **observationally equivalent** under P (written P.ObsEq(x, y)) if sig_P(x) = sig_P(y).

This is an equivalence relation. Its classes are the "indistinguishability classes" of the measurement system.

### 2.5 Key Definitions

**No New Separation.** P.NoNewSeparation(P', r) holds when every pair separated by P' is already separated by P:

```
∀ Y, ∀ x y ∈ F(Y), sig_{P'}(x) ≠ sig_{P'}(y) → sig_P(x) ≠ sig_P(y)
```

**Refines.** P'.Refines(P, r) holds when P'-equivalence implies P-equivalence:

```
∀ Y, ∀ x y ∈ F(Y), sig_{P'}(x) = sig_{P'}(y) → sig_P(x) = sig_P(y)
```

**Redundant Over.** P'.RedundantOver(P, r) holds when the two families induce identical equivalence relations.

---

## 3. Main Results

### 3.1 Abstract Refinement Lemma

**Lemma (Image cardinality monotonicity).** Let f : α → β and g : α → γ be functions on a finite type α. If g refines f (i.e., g(x) = g(y) → f(x) = f(y)), then |image(f)| ≤ |image(g)|.

*Proof sketch.* There is a well-defined surjection h : image(g) → image(f) given by h(g(x)) = f(x), which is well-defined by the refinement hypothesis. Surjectivity of h between finite sets gives the cardinality inequality. □

**Lemma (Bijection upgrade).** Under the same hypotheses, if additionally |image(f)| = |image(g)|, then f refines g.

*Proof sketch.* The surjection h is between finite sets of equal cardinality, hence is a bijection. Bijectivity (injectivity) of h means: if f(x) = f(y), then h(g(x)) = h(g(y)), so g(x) = g(y) by injectivity. □

These lemmas are the abstract engine powering all subsequent theorems.

### 3.2 Theorem 1: Monotonicity (Data Processing Inequality)

**Theorem.** If P ⊆ P', then μ(P) ≤ μ(P').

*Proof.* For each Y, the signature sig_{P'} refines sig_P (more probes means equal P'-signatures imply equal P-signatures, by restricting the signature to the subset P). By the abstract refinement lemma, μ_Y(P) ≤ μ_Y(P'). Summing over Y gives μ(P) ≤ μ(P'). □

### 3.3 Theorem 2: Equality from Redundancy

**Theorem.** If P ⊆ P' and NoNewSeparation(P, P'), then μ(P) = μ(P').

*Proof.* The forward inequality μ(P) ≤ μ(P') is Theorem 1. For the reverse, NoNewSeparation means (by contrapositive): if sig_P(x) = sig_P(y) then sig_{P'}(x) = sig_{P'}(y). So sig_P refines sig_{P'}, and the abstract lemma gives μ_Y(P') ≤ μ_Y(P). Summing gives μ(P') ≤ μ(P). □

### 3.4 Theorem 3: Rigidity

**Theorem.** If P ⊆ P' and μ(P) = μ(P'), then NoNewSeparation(P, P').

*Proof.* From μ(P) = μ(P') and the per-object inequality μ_Y(P) ≤ μ_Y(P') (Theorem 1, objectwise), we deduce μ_Y(P) = μ_Y(P') for all Y (a sum of non-negative differences equals zero). Applying the bijection upgrade lemma at each Y: since sig_{P'} refines sig_P and the image cardinalities are equal, sig_P also refines sig_{P'}. By contrapositive, this gives NoNewSeparation. □

### 3.5 Theorem 4: Iff Characterization

**Theorem.** For P ⊆ P':

```
μ(P) = μ(P')  ⟺  NoNewSeparation(P, P')
```

*Proof.* Immediate from Theorems 2 and 3. □

### 3.6 Theorem 5: Strict Monotonicity

**Theorem.** If P ⊆ P' and there exist Y, x, y with sig_{P'}(x) ≠ sig_{P'}(y) but sig_P(x) = sig_P(y), then μ(P) < μ(P').

*Proof.* By Theorem 1, μ(P) ≤ μ(P'). If μ(P) = μ(P'), then by Theorem 3, NoNewSeparation holds, contradicting the existence of a newly separated pair. Hence μ(P) < μ(P'). □

### 3.7 Theorem 6: Saturation

**Theorem.** If P separates the presheaf (all probe signatures are injective), then μ(P) = μ(P') for all P' ⊇ P.

*Proof.* Apply Theorem 2. NoNewSeparation holds because: if sig_P(x) = sig_P(y) then x = y by injectivity of sig_P, hence sig_{P'}(x) = sig_{P'}(y). So no pair is separated by P' but not by P. □

---

## 4. Algorithms

### 4.1 Measurement Invariant Computation

**Input:** Presheaf (Ob, F, r), probe family P ⊆ Ob.
**Output:** μ(P).

```
Algorithm ComputeMeasurementInvariant(Ob, F, r, P):
    total ← 0
    for each Y ∈ Ob:
        signatures ← {}
        for each x ∈ F(Y):
            sig ← (r(Y, Z)(x) for Z ∈ P)
            signatures.add(sig)
        total ← total + |signatures|
    return total
```

**Complexity:** O(Σ_Y |F(Y)| · |P|) time, O(max_Y |F(Y)|) space.

### 4.2 No-New-Separation Detection

**Input:** Presheaf, nested probe families P ⊆ P'.
**Output:** Boolean indicating whether NoNewSeparation(P, P') holds.

```
Algorithm CheckNoNewSeparation(Ob, F, r, P, P'):
    for each Y ∈ Ob:
        for each pair (x, y) ∈ F(Y) × F(Y):
            sig_P_x ← ComputeSignature(x, P)
            sig_P_y ← ComputeSignature(y, P)
            sig_P'_x ← ComputeSignature(x, P')
            sig_P'_y ← ComputeSignature(y, P')
            if sig_P'_x ≠ sig_P'_y and sig_P_x = sig_P_y:
                return False  // New separation found
    return True
```

**Complexity:** O(Σ_Y |F(Y)|² · max(|P|, |P'|)) time.

### 4.3 Full Stability Verification

Combines both algorithms to verify all three properties (monotonicity, iff characterization, strict monotonicity) for all nested pairs of probe families.

**Complexity:** O(2^{2|Ob|} · Σ_Y |F(Y)|² · |Ob|) time.

---

## 5. Computational Experiments

### 5.1 Exhaustive Verification

We exhaustively verified all three main theorems on all presheaves over a 2-object category with fiber sizes |F(A)| = 2 and |F(B)| = 3.

| Metric | Count |
|--------|-------|
| Total presheaves tested | 72 |
| Monotonicity checks passed | 648 |
| Iff characterization checks passed | 648 |
| Strict monotonicity checks passed | 312 |
| Violations found | 0 |

### 5.2 Partition Refinement Example

For a 3-object presheaf with fibers of size 4, 2, and 3, we computed the partition refinement lattice at object A:

| Probe Family | Partition | Classes |
|---|---|---|
| ∅ | {a1, a2, a3, a4} | 1 |
| {B} | {a1, a2}, {a3, a4} | 2 |
| {B, C} | {a1}, {a2}, {a3}, {a4} | 4 |
| {A, B, C} | {a1}, {a2}, {a3}, {a4} | 4 |

The transition from {B, C} to {A, B, C} preserves the partition — adding probe A is redundant here, consistent with the rigidity theorem.

---

## 6. Discussion

### 6.1 Relationship to Classical Data Processing

The classical data processing inequality states: for a Markov chain X → Y → Z, I(X; Z) ≤ I(X; Y). Our Theorem 1 is the structural analogue: if P ⊆ P', then μ(P) ≤ μ(P'). The key difference is that our setting is deterministic and combinatorial rather than probabilistic, and our invariant counts equivalence classes rather than measuring entropy.

The equality characterization (Theorem 4) corresponds to the condition for equality in the data processing inequality: I(X; Z) = I(X; Y) iff X → Z → Y is also a valid Markov chain (the channel Y → Z is sufficient for X). Our NoNewSeparation condition is the deterministic analogue of sufficiency.

### 6.2 Relationship to Blackwell's Theorem

Blackwell (1953) defined a comparison ordering on statistical experiments: experiment E is "more informative" than experiment F if every decision problem that can be solved with F can also be solved with E. Our refinement order P ≤ P' (via Refines) is a deterministic, combinatorial version of this comparison. The iff characterization gives a concrete, checkable criterion for equivalence.

### 6.3 Limitations

The current framework is restricted to:
- **Discrete categories.** Extension to non-discrete categories would require handling morphisms and functoriality.
- **Deterministic restriction maps.** Probabilistic or noisy observations would require an entropy-based invariant.
- **Finite types.** Infinite presheaves would need measure-theoretic treatment.

---

## 7. Future Work

1. **Quantitative information gain.** Define an "information gap" Δ(P, P') that measures how much new information P' provides beyond P, going beyond the binary sufficient/not-sufficient distinction.

2. **Infinite categories.** Extend the framework to locally finite categories with infinitely many objects but finite hom-sets.

3. **Probabilistic probe families.** Replace deterministic restriction maps with stochastic kernels and connect to classical information theory.

4. **Blackwell ordering.** Formalize the full Blackwell comparison of experiments in the categorical setting.

5. **Computational complexity.** Determine the complexity of finding the minimum separating probe family (a set cover variant).

---

## 8. Formal Verification

All theorems in this paper have been formalized and machine-verified in Lean 4, using the Mathlib library. The formalization includes:

- 5 new definitions (ObsEq, SeparatesElements, NoNewSeparation, Refines, RedundantOver)
- 2 abstract lemmas on image cardinality under refinement
- 6 theorems on measurement invariant stability
- 3 structural lemmas connecting the definitions

The complete formalization is approximately 380 lines, with zero remaining `sorry` statements.

---

## References

1. Shannon, C.E. "A Mathematical Theory of Communication." *Bell System Technical Journal* 27 (1948): 379–423.

2. Blackwell, D. "Equivalent Comparisons of Experiments." *Annals of Mathematical Statistics* 24 (1953): 265–272.

3. Cover, T.M. and Thomas, J.A. *Elements of Information Theory*. Wiley, 2006.

4. Mac Lane, S. *Categories for the Working Mathematician*. Springer, 1971.
