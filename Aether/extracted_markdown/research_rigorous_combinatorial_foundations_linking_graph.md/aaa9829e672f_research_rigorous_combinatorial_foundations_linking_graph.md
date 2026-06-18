# Spectral Proof Complexity: Directed Conductance, Depth Hierarchies, and Layered Derivation Bounds

## Abstract

We develop a spectral theory of proof complexity based on directed conductance in derivation graphs. A *derivation graph* is a directed graph whose vertices are mathematical statements and whose edges represent single-step inference rules. We introduce *proof depth classes* — the stratification of reachable statements by the step at which they are first derived — and prove that under vertex expansion, these classes grow at a rate controlled by the directed conductance φ. Our main results are: (1) the *conductance ball growth theorem*, showing that the proof ball grows by factor (1+φ) per step; (2) the *depth hierarchy strictness theorem*, establishing that each depth class has size at least φ·|Ball(k)|; (3) a *reachability dichotomy* proving that every statement is either eventually reachable or permanently unreachable; (4) a *fixed-point characterization* showing that ball stabilization is equivalent to closure under derivation; and (5) tight bounds for *layered derivations* where the proof ball is exactly characterized by the layer function. All results are machine-verified. We conjecture a directed Cheeger inequality relating the conductance to the spectral gap of the directed Laplacian.

**Keywords**: proof complexity, spectral graph theory, derivation graphs, directed conductance, Cheeger inequality, depth hierarchy

---

## 1. Introduction

Proof complexity studies the minimum resources — primarily length and depth — required to derive a target statement from axioms in a given proof system. Classical results in this area (e.g., Haken's exponential lower bound for resolution, the Paris-Harrington independence results) rely on intricate combinatorial arguments specific to particular proof systems.

We propose a *spectral approach* to proof complexity, based on the observation that the derivation graph of a proof system — the directed graph whose vertices are statements and whose edges represent single-step inferences — carries geometric structure that constrains proof length. Specifically, we show that the *directed conductance* (the minimum boundary-to-volume ratio over small subsets) controls the growth rate of the *proof ball* (the set of statements reachable in k steps), yielding exponential ball growth and logarithmic proof length bounds.

### 1.1 Related Work

The connection between graph expansion and computational complexity has a rich history. Expander graphs play central roles in derandomization, error-correcting codes, and network design. The Cheeger inequality (Alon-Milman, 1985; Alon, 1986) relates vertex expansion to the spectral gap of the graph Laplacian, providing a linear-algebraic handle on expansion.

In proof complexity, graph-theoretic methods have been applied to specific proof systems. Beame, Pitassi, and Segerlind (2007) used expansion arguments for space-complexity lower bounds. Ben-Sasson and Wigderson (1999) connected proof length in resolution to expansion properties. Our work generalizes these system-specific results to an abstract framework applicable to any derivation graph.

The renormalization perspective connects to work on coarse-graining in network science and to the block-spin renormalization group in statistical physics.

### 1.2 Contributions

1. **Directed conductance framework**: We formalize the directed analog of the Cheeger constant for derivation graphs and prove that it controls proof ball growth (Theorem 5.1).

2. **Depth hierarchy**: We introduce proof depth classes and prove that under expansion, they form a strict hierarchy with quantitative lower bounds on class sizes (Theorem 5.2).

3. **Reachability dichotomy**: We prove that every statement is either eventually reachable or permanently unreachable, with stabilization occurring within |V| steps (Theorem 3.1).

4. **Fixed-point characterization**: We characterize ball stabilization as equivalent to closure under derivation (Theorem 2.2).

5. **Layered derivation bounds**: For layered derivation graphs (where edges increase layer by exactly 1), we prove tight characterizations of the proof ball in terms of the layer function (Theorems 4.1-4.2).

6. **Machine verification**: All results are formally verified in Lean 4 with the Mathlib library.

---

## 2. Preliminaries

### 2.1 Derivation Graphs

**Definition 2.1** (Derivation Graph). A *derivation graph* is a pair G = (V, adj) where V is a finite set and adj : V → V → Prop is a decidable binary relation. We write u → v when adj(u, v) holds, meaning "statement v can be derived from statement u in one step."

**Definition 2.2** (Out-neighborhood). For a vertex v, the out-neighborhood is N⁺(v) = {w ∈ V : v → w}. For a set S ⊆ V, the out-neighborhood is N⁺(S) = ⋃_{v ∈ S} N⁺(v).

**Definition 2.3** (Boundary). The boundary of S is ∂⁺S = N⁺(S) \ S.

**Definition 2.4** (Closure). A set S is *closed* under derivation if N⁺(S) ⊆ S.

### 2.2 Proof Balls

**Definition 2.5** (Proof Ball). For a set S ⊆ V and k ∈ ℕ:
- Ball(S, 0) = S
- Ball(S, k+1) = Ball(S, k) ∪ N⁺(Ball(S, k))

The proof ball Ball(S, k) contains all statements derivable from S in at most k steps.

---

## 3. Fixed Points and Reachability

### 3.1 Stabilization

**Theorem 2.1** (Ball Stability). If Ball(S, k+1) = Ball(S, k), then Ball(S, m) = Ball(S, k) for all m ≥ k.

*Proof sketch.* By induction on m. If Ball(S, k+1) = Ball(S, k), then N⁺(Ball(S, k)) ⊆ Ball(S, k). Hence Ball(S, k+2) = Ball(S, k+1) ∪ N⁺(Ball(S, k+1)) = Ball(S, k) ∪ N⁺(Ball(S, k)) = Ball(S, k+1) = Ball(S, k). □

**Theorem 2.2** (Fixed-Point Characterization). Ball(S, k+1) = Ball(S, k) if and only if Ball(S, k) is closed.

*Proof.* Ball(S, k+1) = Ball(S, k) ∪ N⁺(Ball(S, k)). This equals Ball(S, k) iff N⁺(Ball(S, k)) ⊆ Ball(S, k), which is the definition of closure. □

### 3.2 Reachability Dichotomy

**Definition 3.1** (Reachable Component). RC(S) = Ball(S, |V|).

**Theorem 3.1** (Reachability Dichotomy). For every v ∈ V, either v ∈ RC(S) or v ∉ Ball(S, k) for all k ∈ ℕ.

*Proof sketch.* The sequence |Ball(S, 0)| ≤ |Ball(S, 1)| ≤ ... is monotone and bounded by |V|. By pigeonhole, there exist consecutive steps j, j+1 with j ≤ |V| where the ball sizes are equal. By Theorem 2.1, the ball stabilizes at step j. Since j ≤ |V|, we have Ball(S, k) = Ball(S, j) ⊆ Ball(S, |V|) = RC(S) for all k ≥ j. For k < j, Ball(S, k) ⊆ RC(S) by monotonicity. □

---

## 4. Layered Derivations

**Definition 4.1** (Layered Derivation). A *layered derivation* is a derivation graph equipped with a function layer : V → ℕ such that u → v implies layer(v) = layer(u) + 1.

This models proof systems where each inference step increases a complexity measure by exactly one (e.g., formula depth in Frege systems, cut-rank in sequent calculus).

**Theorem 4.1** (Layer Bound). If every v ∈ S has layer(v) = 0, then for all v ∈ Ball(S, k), layer(v) ≤ k.

*Proof.* By induction on k. The base case holds by hypothesis. For the inductive step, if v ∈ Ball(S, k+1) \ Ball(S, k), then v ∈ N⁺(Ball(S, k)), so there exists u ∈ Ball(S, k) with u → v. By the layer condition, layer(v) = layer(u) + 1 ≤ k + 1. □

**Theorem 4.2** (Layer Exclusion). Under the same hypotheses, if layer(v) > k, then v ∉ Ball(S, k).

*Proof.* Immediate from Theorem 4.1 by contradiction. □

Together, these give a tight characterization: in a layered derivation, a layer-0 axiom set can reach a vertex v in at most k steps if and only if layer(v) ≤ k and v is in the reachable component.

---

## 5. Directed Conductance and Depth Hierarchies

### 5.1 Proof Depth Classes

**Definition 5.1** (Proof Depth Class).
- D(S, 0) = S
- D(S, k+1) = Ball(S, k+1) \ Ball(S, k)

The depth class D(S, k) contains the vertices first reached at exactly step k.

**Theorem 5.0** (Depth Class Decomposition). |Ball(S, k+1)| = |Ball(S, k)| + |D(S, k+1)|.

**Theorem 5.0'** (Growing Balls Have Nonempty Classes). If Ball(S, k) ≠ Ball(S, k+1), then D(S, k+1) is nonempty.

### 5.2 Boundary-Depth Containment

**Lemma 5.1** (Boundary ⊆ Depth Class). ∂⁺Ball(S, k) ⊆ D(S, k+1).

*Proof.* The boundary ∂⁺Ball(S, k) = N⁺(Ball(S, k)) \ Ball(S, k). Since Ball(S, k+1) = Ball(S, k) ∪ N⁺(Ball(S, k)), every element of ∂⁺Ball(S, k) is in Ball(S, k+1) \ Ball(S, k) = D(S, k+1). □

### 5.3 Main Theorems

**Theorem 5.1** (Conductance Ball Growth). Suppose that for every nonempty T ⊆ V with |T| ≤ |V|/2, we have |∂⁺T| ≥ φ·|T|. If Ball(S, k) is nonempty and |Ball(S, k)| ≤ |V|/2, then:

|Ball(S, k+1)| ≥ (1 + φ)·|Ball(S, k)|

*Proof.* By the expansion condition, |∂⁺Ball(S, k)| ≥ φ·|Ball(S, k)|. By Lemma 5.1, |D(S, k+1)| ≥ |∂⁺Ball(S, k)| ≥ φ·|Ball(S, k)|. By Theorem 5.0, |Ball(S, k+1)| = |Ball(S, k)| + |D(S, k+1)| ≥ (1 + φ)·|Ball(S, k)|. □

**Theorem 5.2** (Depth Hierarchy Strictness). Under the same hypotheses:

|D(S, k+1)| ≥ φ·|Ball(S, k)|

*Proof.* Direct from the expansion condition and Lemma 5.1. □

**Corollary 5.3** (Logarithmic Proof Length Bound). If G has expansion φ and |S| = 1, then the number of steps to reach any target t with |V|/2 or fewer predecessors is at most ⌈log(|V|/2) / log(1+φ)⌉.

### 5.4 The Spectral Connection

The expansion parameter φ is the *directed conductance* of G. The classical Cheeger inequality for undirected graphs states:

φ²/2 ≤ λ₂ ≤ 2φ

where λ₂ is the spectral gap (second-smallest eigenvalue of the normalized Laplacian).

**Conjecture 5.4** (Directed Cheeger for Derivation Graphs). For d-regular derivation graphs:

φ²/(2d) ≤ Re(λ₁) ≤ 2φ

where λ₁ is the eigenvalue of the directed Laplacian with smallest positive real part.

If true, Theorem 5.1 becomes: the proof ball growth rate is at least 1 + √(2d·Re(λ₁)), giving spectral lower bounds on proof length.

---

## 6. Composition and Sequential Derivation

**Definition 6.1** (Graph Composition). For derivation graphs G₁, G₂ on the same vertex set, the composition G₁ ∘ G₂ has adj(u, v) iff ∃w, G₁.adj(u, w) ∧ G₂.adj(w, v).

**Theorem 6.1** (Composition Reachability). If v ∈ Ball_G(S, j) and G.adj(v, w), then w ∈ Ball_G(S, j+1).

This gives transitivity of reachability: if we can reach v in j steps and then make one more step to w, we reach w in j+1 steps.

---

## 7. Algorithms

### 7.1 Proof Ball Computation

The proof ball can be computed by iterated breadth-first search:

```
Algorithm: ComputeProofBall(G, S, k)
Input: Derivation graph G, initial set S, depth bound k
Output: Ball(S, k)

B ← S
for i = 1 to k:
    B ← B ∪ N⁺(B)
return B
```

Time complexity: O(k · |E|) where |E| is the number of edges.

### 7.2 Conductance Estimation

Computing the exact directed conductance is NP-hard (as it reduces to minimum bisection). However, spectral methods give polynomial-time approximations:

1. Compute the directed Laplacian L = I - D⁻¹A
2. Find the eigenvalue with smallest positive real part
3. Apply the (conjectured) directed Cheeger inequality

### 7.3 Depth Class Stratification

```
Algorithm: StratifyDepthClasses(G, S, max_depth)
Input: Derivation graph G, initial set S, maximum depth
Output: Depth classes D(0), D(1), ..., D(max_depth)

D[0] ← S
B ← S
for k = 1 to max_depth:
    B_new ← B ∪ N⁺(B)
    D[k] ← B_new \ B
    if D[k] = ∅: break
    B ← B_new
return D
```

---

## 8. Discussion

### 8.1 Comparison with Existing Approaches

Our framework differs from traditional proof complexity in several ways:

1. **System-independent**: The derivation graph formalism applies to any proof system, not just resolution or Frege.

2. **Quantitative**: The conductance parameter gives explicit growth rates, not just asymptotic bounds.

3. **Spectral**: Through the Cheeger connection, our bounds can (conjecturally) be computed from eigenvalues.

### 8.2 Limitations

1. The expansion condition requires small sets to have large boundaries. In many proof systems, the derivation graph may have bottlenecks (small cuts) that violate expansion.

2. The directed Cheeger inequality is conjectured but not proven. The directed case is significantly harder than the undirected case.

3. Our bounds apply to the proof ball, not to individual proofs. A short proof may exist even if the ball grows slowly, if it follows a fortunate path.

### 8.3 Future Directions

The most promising direction is establishing the directed Cheeger inequality, which would close the gap between our combinatorial framework and spectral methods. Other directions include:

- Applying the framework to specific proof systems (resolution, Frege, bounded-depth Frege) to recover and potentially improve known lower bounds
- Extending to hypergraph derivations where multiple premises are combined in a single step
- Connecting the depth class stratification to circuit complexity measures

---

## 9. References

1. Alon, N. (1986). Eigenvalues and expanders. *Combinatorica*, 6(2), 83-96.

2. Alon, N., & Milman, V. D. (1985). λ₁, isoperimetric inequalities for graphs, and superconcentrators. *Journal of Combinatorial Theory, Series B*, 38(1), 73-88.

3. Ben-Sasson, E., & Wigderson, A. (1999). Short proofs are narrow — resolution made simple. *STOC*, 517-526.

4. Chung, F. (2005). Laplacians and the Cheeger inequality for directed graphs. *Annals of Combinatorics*, 9(1), 1-19.

5. Beame, P., Pitassi, T., & Segerlind, N. (2007). Lower bounds for Lovász-Schrijver systems and beyond follow from multiparty communication complexity. *SIAM Journal on Computing*, 37(3), 845-869.

6. Cook, S. A., & Reckhow, R. A. (1979). The relative efficiency of propositional proof systems. *Journal of Symbolic Logic*, 44(1), 36-50.
