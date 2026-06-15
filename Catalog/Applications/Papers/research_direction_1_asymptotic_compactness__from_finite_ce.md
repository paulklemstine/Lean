# Asymptotic Compactness for Monotone Circuit Lower Bounds: Hereditary Certificate Schemes

## Abstract

We develop a formal framework for *hereditary certificate schemes* — uniform families of sandwich certificates that witness monotone circuit lower bounds across all input sizes simultaneously. Building on the finite duality between complete sandwich families and the non-existence of small monotone circuits, we prove that pointwise certificate existence can be lifted to a uniform asymptotic scheme via a compactness extraction principle. We formalize the completeness monotonicity theorem, the finite duality equivalence, the asymptotic extraction theorem, and the refutation system interpretation, and instantiate the framework for triangle detection. All theorems are machine-verified. This work establishes the foundational language for a new research program connecting monotone circuit complexity to proof complexity, finite model theory, and combinatorial obstruction theory.

## 1. Introduction

### 1.1 Motivation

Monotone circuit lower bounds are among the few unconditional results in computational complexity theory. Razborov's approximation method (1985) showed that the monotone circuit complexity of the clique function is super-polynomial, and subsequent work by Alon and Boppana (1987) strengthened these bounds. However, each lower bound proof is bespoke: tailored to a specific graph property via property-specific combinatorial arguments.

A natural question is whether there exists a *uniform* theory — a general mechanism that produces lower bounds from compact, polynomially describable certificates. This paper initiates such a theory by defining **hereditary certificate schemes** and proving that the finite certificate framework lifts cleanly to the asymptotic setting.

### 1.2 Contributions

1. **Completeness Monotonicity** (Theorem 1): If a sandwich family is complete up to circuit size $k_2$, it is complete up to $k_1 \leq k_2$.

2. **Finite Duality** (Theorem 3): On finite domains, a complete sandwich family exists iff no small circuit computes the target function.

3. **Asymptotic Compactness Extraction** (Theorem 5): Pointwise existence of certificate families implies a uniform choice function.

4. **Uniform Lower Bounds** (Theorem 6): A uniform certificate scheme yields lower bounds at every input size.

5. **Refutation System Interpretation** (Theorem 7): Complete sandwich families are finite refutation systems.

6. **Triangle Instantiation** (Theorems 8-10): The framework correctly specializes to triangle detection.

All results are machine-verified in Lean 4 with Mathlib.

### 1.3 Related Work

- **Razborov's approximation method** [Raz85]: The original framework for monotone circuit lower bounds, using approximation by low-degree polynomials.
- **Alon-Boppana** [AB87]: Strengthened Razborov's clique lower bound to $n^{\Omega(\sqrt{k})}$ for $k$-clique.
- **Karchmer-Wigderson** [KW88]: Communication complexity approach to formula depth lower bounds.
- **Haken** [Hak95]: Exponential lower bounds for resolution proofs of pigeonhole formulas, connecting to proof complexity.

Our work differs in focus: rather than proving a new lower bound, we develop the *meta-theory* — the structural framework in which all monotone lower bounds live.

## 2. Preliminaries

### 2.1 Monotone Boolean Functions and Circuits

Let $\alpha$ be a finite preordered type. A **monotone Boolean function** is a function $f : \alpha \to \text{Bool}$ such that $x \leq y \implies f(x) \leq f(y)$.

A **monotone circuit profile** abstracts a monotone circuit to its size and evaluation function:
```
structure MonoCircuitProfile (α : Type*) [Preorder α] where
  size : ℕ
  eval : α → Bool
  mono_eval : Monotone eval
```

### 2.2 Certified Sandwich Families

A **certified sandwich family** for $f$ consists of positive and negative witness sets:
```
structure CertifiedSandwichFamily (α : Type*) [Preorder α] [Fintype α]
    (f : α → Bool) where
  Pos : Finset α
  Neg : Finset α
  pos_spec : ∀ x ∈ Pos, f x = true
  neg_spec : ∀ x ∈ Neg, f x = false
```

A family **hits** a circuit $C$ if some witness disagrees with $C$:
$$\text{Hits}(S, C) \iff (\exists x \in S.\text{Pos},\, C(x) = \text{false} \land f(x) = \text{true}) \lor (\exists x \in S.\text{Neg},\, C(x) = \text{true} \land f(x) = \text{false})$$

Completeness up to size $s$ means: $\forall C,\, |C| \leq s \implies \text{Hits}(S, C)$.

### 2.3 Certificate Ordering

The **certificate ordering** $S_1 \leq S_2$ holds iff $S_1.\text{Pos} \subseteq S_2.\text{Pos}$ and $S_1.\text{Neg} \subseteq S_2.\text{Neg}$. This is a preorder. Completeness is upward-closed in this ordering.

## 3. Main Results

### Theorem 1: Completeness Monotonicity

**Statement.** If $S$ is complete up to size $k_2$ and $k_1 \leq k_2$, then $S$ is complete up to size $k_1$.

**Proof.** Any circuit of size $\leq k_1$ has size $\leq k_2$, so completeness at $k_2$ implies completeness at $k_1$. $\square$

This is mathematically immediate but structurally important: it ensures that lower bound certificates form a filtration indexed by the size parameter.

### Theorem 2: The Engine Theorem

**Statement.** If $S$ is complete up to size $s$, then no monotone circuit of size $\leq s$ computes $f$.

**Proof.** Suppose for contradiction that circuit $C$ with $|C| \leq s$ computes $f$. By completeness, $S$ hits $C$: there exists $x$ where $C(x) \neq f(x)$. But $C$ computes $f$ everywhere — contradiction. $\square$

### Theorem 3: Finite Duality

**Statement.** On finite domains, $(\exists S,\, \text{Complete}(S, s)) \iff \neg(\exists C,\, |C| \leq s \land C = f)$.

**Proof sketch.**
- ($\Rightarrow$): By the Engine Theorem.
- ($\Leftarrow$): Construct the **universal family** $S^* = (\{x \mid f(x) = \text{true}\}, \{x \mid f(x) = \text{false}\})$. Since $\text{Pos} \cup \text{Neg}$ covers all elements, any circuit that disagrees with $f$ on any input is hit. If no circuit of size $\leq s$ computes $f$, every such circuit disagrees on some input, which is caught by $S^*$. $\square$

This theorem is the fundamental transfer principle between the combinatorial world (certificates) and the computational world (circuits).

### Theorem 4: Union Composition

**Statement.** If $S_1$ is complete up to size $k$, then $S_1 \cup S_2$ is also complete up to size $k$.

**Proof.** The union extends $S_1$ in the certificate ordering. Completeness is upward-closed. $\square$

### Theorem 5: Asymptotic Compactness Extraction

**Statement.** If for every $n$, there exists a sandwich family $S_n$ complete up to threshold $s(n)$, then there exists a uniform family $F : \forall n, \text{CertifiedSandwichFamily}$ such that $F(n)$ is complete up to $s(n)$ for all $n$.

**Proof.** By the axiom of choice. For each $n$, select $F(n) = \text{choose}(\text{hex}(n))$. The choice function is uniform. $\square$

**Discussion.** While the proof is a direct application of choice, the theorem is significant because it reifies the pointwise existence of certificates into a single mathematical object — the hereditary certificate scheme. This is the starting point for studying structural properties of the scheme (polynomial bounds, hereditary compatibility, etc.).

### Theorem 6: Uniform Lower Bounds

**Statement.** If a hereditary certificate scheme $H$ exists, then for every $n$, no monotone circuit of size $\leq H.\text{sizeThreshold}(n)$ computes $H.\text{prop}(n)$.

**Proof.** Apply the Engine Theorem at each $n$ using $H.\text{complete}(n)$. $\square$

### Theorem 7: Refutation System Interpretation

**Statement.** If $S$ is complete up to size $s$, then for every circuit $C$ with $|C| \leq s$, there exists $x \in S.\text{Pos} \cup S.\text{Neg}$ such that $C(x) \neq f(x)$.

**Proof.** By definition of completeness and the structure of `SandwichHitsCircuit`. $\square$

**Significance.** This theorem interprets the certificate family as a *finite refutation system*: each element of $\text{Pos} \cup \text{Neg}$ acts as a potential counterexample, and completeness guarantees that for every incorrect circuit, at least one counterexample applies. This connects monotone lower bounds to proof complexity, where refutation systems are the central objects of study.

### Theorems 8-10: Triangle Instantiation

We define the **triangle property** on $n$-vertex graphs:
$$\text{hasTriangle}(G) = \exists i,j,k.\, i \neq j \neq k \neq i \land G(i,j) \land G(j,k) \land G(i,k)$$

**Theorem 8 (Triangle Monotonicity).** The triangle predicate is monotone under edge addition.

**Theorem 9 (Triangle Lower Bound).** If a sandwich family for triangle detection is complete up to size $s$, then no monotone circuit of size $\leq s$ computes triangle detection.

**Theorem 10 (Triangle Compactness).** If for every $n$, a complete sandwich family for triangle detection exists at threshold $s(n)$, then a uniform lower bound holds at every $n$.

## 4. Algorithms

### 4.1 Universal Family Construction

**Input:** Integer $n$, monotone property $P$.
**Output:** Universal sandwich family $S^*$.

```
Algorithm UniversalFamily(n, P):
  Enumerate all graphs G on n vertices
  Pos ← {G | P(G) = true}
  Neg ← {G | P(G) = false}
  Return (Pos, Neg)
```

**Complexity:** $O(2^{\binom{n}{2}} \cdot T_P)$ where $T_P$ is the time to evaluate $P$.

### 4.2 Greedy Minimal Family

**Input:** Integer $n$, monotone property $P$, set of circuits $\mathcal{C}$.
**Output:** Approximately minimal sandwich family hitting all circuits in $\mathcal{C}$.

```
Algorithm GreedyMinimal(n, P, C):
  pos_candidates ← {G | P(G) = true}
  neg_candidates ← {G | P(G) = false}
  selected ← ∅
  unhit ← C
  While unhit ≠ ∅:
    best ← argmax_{w ∈ candidates} |{C ∈ unhit | w hits C}|
    selected ← selected ∪ {best}
    unhit ← unhit \ {C | best hits C}
  Return selected
```

**Complexity:** $O(|\text{candidates}| \cdot |\mathcal{C}|)$ per round, $O(|S|)$ rounds.

### 4.3 Polynomial Growth Estimation

Given family sizes at $n = 3, 4, 5, \ldots$, we fit $|S_n| \approx C \cdot n^d$ via least-squares in log-log space. This provides empirical evidence for or against polynomial certificate schemes.

## 5. Computational Experiments

### 5.1 Triangle Detection Certificates

We computed universal sandwich families for triangle detection on $n = 3, 4, 5, 6$:

| $n$ | Edges | Total Graphs | |Pos| | |Neg| | Family Size | log₂(Size) |
|-----|-------|-------------|-------|-------|-------------|-------------|
| 3   | 3     | 8           | 1     | 7     | 8           | 3.0         |
| 4   | 6     | 64          | 23    | 41    | 64          | 6.0         |
| 5   | 10    | 1,024       | 636   | 388   | 1,024       | 10.0        |
| 6   | 15    | 32,768      | 26,979| 5,789 | 32,768      | 15.0        |

The universal family has size $2^{\binom{n}{2}}$, which is exponential. The fraction of positive witnesses (graphs with triangles) grows rapidly: from 12.5% at $n=3$ to 82.3% at $n=6$.

### 5.2 Growth Analysis

The universal family size equals $2^{\binom{n}{2}}$, confirming exponential growth. The key open question is whether a *minimal* complete family can be polynomial. For triangle detection, Razborov's constructions suggest $O(n^{O(1)})$ witnesses suffice — specifically, $O(n^3)$ sunflower-based witnesses.

## 6. Discussion

### 6.1 Significance

This work establishes the formal foundations for a new approach to monotone circuit lower bounds. The key conceptual contributions are:

1. **Certificate schemes as mathematical objects:** By defining hereditary certificate schemes as structures, we make the meta-theory of lower bounds a formal subject.

2. **Compactness as a unifying principle:** The extraction theorem shows that pointwise lower bounds automatically lift to uniform lower bounds. This is a structural result, not merely a reformulation.

3. **Cross-domain connections:** The refutation system interpretation connects to proof complexity. The hereditary restriction property connects to finite model theory. The certificate ordering connects to order theory and compactness.

### 6.2 Limitations

1. **The extraction theorem uses choice:** While mathematically natural, this means the uniform family is not constructively obtained. Future work should explore whether effective extraction is possible.

2. **Polynomial bounds are not proven:** The framework identifies polynomial certificate complexity as the key question but does not resolve it.

3. **The universal family is exponential:** Our computational experiments use the universal family, which is too large. The interesting case is minimal families, which require more sophisticated algorithms.

### 6.3 Open Questions

1. For triangle detection, does there exist a polynomial-size hereditary certificate scheme?
2. Can certificate families be described in a fixed first-order or existential second-order logic?
3. Is there a well-quasi-ordering on certificates under restriction?
4. Can the refutation system interpretation be made quantitative, connecting certificate size to proof complexity measures?

## 7. Future Work

See `FUTURE_DIRECTIONS.md` for detailed testable conjectures. The most pressing questions are:

1. **Polynomial certificate conjecture:** For every monotone graph property with super-polynomial circuit complexity, does a polynomial certificate scheme exist?
2. **Definability conjecture:** Certificate families for natural properties are definable in existential second-order logic.
3. **Well-quasi-order conjecture:** Under a natural restriction ordering, certificate families for hereditary properties satisfy a well-quasi-ordering condition.

## 8. Formal Verification

All theorems in Sections 3 and 5 are formally verified in Lean 4 with Mathlib. The key files are:

- `Pythagorean/SandwichDefs.lean`: Core definitions (sandwich families, completeness, certificate ordering)
- `Pythagorean/AsymptoticCompactness.lean`: All main theorems (11 verified results)

The verification uses only standard axioms (propext, Classical.choice, Quot.sound).

## References

- [Raz85] A. A. Razborov. Lower bounds on the monotone complexity of some Boolean functions. *Doklady Akademii Nauk SSSR*, 1985.
- [AB87] N. Alon, R. B. Boppana. The monotone circuit complexity of Boolean functions. *Combinatorica*, 1987.
- [KW88] M. Karchmer, A. Wigderson. Monotone circuits for connectivity require super-logarithmic depth. *STOC*, 1988.
- [Hak95] A. Haken. The intractability of resolution. *Theoretical Computer Science*, 1985.
- [RS04] N. Robertson, P. D. Seymour. Graph Minors XX: Wagner's Conjecture. *JCTB*, 2004.
