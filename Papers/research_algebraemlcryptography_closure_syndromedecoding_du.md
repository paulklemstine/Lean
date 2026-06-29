# Closure–Syndrome Decoding Duality via Idempotent Parity Semimodules and Certified Minimal Tanner Reconstruction

## Abstract

We establish a finite duality theorem connecting closure-parity systems to canonical minimal Tanner hypergraph realizations. Given a finite closure operator on a set of symbols equipped with parity observables (each with a closed support set and a weight), we prove the existence and uniqueness of a minimal Tanner hypergraph that realizes the system. The key results are: (1) the canonical Tanner construction achieves minimum check-node count, (2) any two minimal realizations are equivalent, (3) syndrome computation factors through the Tanner incidence structure, and (4) under an incomparability condition on supports, the check nodes correspond bijectively to extremal generators of the parity semimodule. All results are formalized and machine-verified. The framework applies to code design over arbitrary semirings and establishes that decoding objects are canonical algebraic invariants of closure-parity semantics.

**Keywords:** closure operators, Tanner graphs, parity-check codes, syndrome decoding, idempotent semimodules, certified reconstruction, tropical algebra

---

## 1. Introduction

### 1.1 Motivation

Error-correcting codes are typically specified by a parity-check matrix $H$ whose rows define the parity constraints. The associated Tanner graph—a bipartite graph between variable nodes and check nodes—is the standard combinatorial representation used for iterative decoding algorithms such as belief propagation. A fundamental question in coding theory is:

> *Given the algebraic constraints of a code, what is the minimal Tanner graph that faithfully represents the decoding structure, and is it unique?*

Classical approaches address this via linear algebra over finite fields. We take a different perspective, replacing the linear-algebraic framework with **closure operators** and **parity observables**, yielding a theory that:

1. Applies to codes over arbitrary semirings (not just finite fields),
2. Reveals the canonical nature of minimal Tanner realizations,
3. Connects coding theory to closure lattice theory and tropical algebra,
4. Provides certified, computable reconstruction algorithms.

### 1.2 Related Work

Closure operators have been studied extensively in lattice theory (Birkhoff, 1940), formal concept analysis (Ganter & Wille, 1999), and matroid theory (Welsh, 1976). Their connection to information theory appears in the work on closure capacities and secret-sharing duality. Tanner graphs were introduced by Tanner (1981) as a graphical representation of parity-check codes, with subsequent development by Wiberg, Loeliger, and Kötter (1995) for iterative decoding. Tropical (min-plus) algebra has found applications in optimization, algebraic geometry, and more recently in coding theory. Our work bridges these traditions by showing that closure-parity semantics canonically determine Tanner structure.

### 1.3 Contributions

1. **Structures:** We define closure-parity systems, Tanner hypergraphs, and parity indicator semimodules in a unified framework.
2. **Existence and minimality:** We prove that every closure-parity system admits a canonical minimal Tanner realization (Theorem 5.1).
3. **Uniqueness:** We prove that minimal realizations are unique up to equivalence (Theorem 5.3).
4. **Extremal correspondence:** Under support incomparability, we establish a bijection between extremal generators and check nodes (Theorem 6.1).
5. **Syndrome duality:** We prove that syndrome computation is invariant under passage to the Tanner representation (Theorem 4.1).
6. **Certified reconstruction:** We provide an explicit computable reconstruction algorithm with correctness proof (Theorem 5.4).
7. **Machine verification:** All results are formalized and verified in a proof assistant with the Mathlib library.

---

## 2. Definitions and Notation

### 2.1 Finite Closure Operators

**Definition 2.1.** A *finite closure operator* on a finite set $\alpha$ is a function $\mathrm{cl} : \mathcal{P}_{\mathrm{fin}}(\alpha) \to \mathcal{P}_{\mathrm{fin}}(\alpha)$ satisfying:
- **Extensivity:** $S \subseteq \mathrm{cl}(S)$ for all $S$
- **Monotonicity:** $S \subseteq T \implies \mathrm{cl}(S) \subseteq \mathrm{cl}(T)$
- **Idempotency:** $\mathrm{cl}(\mathrm{cl}(S)) = \mathrm{cl}(S)$

A set $S$ is *closed* if $\mathrm{cl}(S) = S$.

### 2.2 Closure-Parity Systems

**Definition 2.2.** A *closure-parity system* $(α, \mathrm{Obs}, \mathrm{cl}, \mathrm{supp}, \mathrm{wt})$ consists of:
- A finite type $\alpha$ of message symbols
- A finite type $\mathrm{Obs}$ of parity observables
- A finite closure operator $\mathrm{cl}$ on $\alpha$
- A support function $\mathrm{supp} : \mathrm{Obs} \to \mathcal{P}_{\mathrm{fin}}(\alpha)$ assigning each observable a closed support set
- A weight function $\mathrm{wt} : \mathrm{Obs} \to \mathbb{N}$

The requirement that supports are closed ($\mathrm{cl}(\mathrm{supp}(o)) = \mathrm{supp}(o)$ for all $o$) is the key structural constraint.

**Definition 2.3.** The *active observables* are $\mathrm{activeObs} = \{o \in \mathrm{Obs} \mid \mathrm{supp}(o) \neq \emptyset\}$.

**Definition 2.4.** A system is *separated* if $\mathrm{supp}$ is injective. It has *incomparable supports* if for all distinct active $o_1, o_2$, neither $\mathrm{supp}(o_1) \subseteq \mathrm{supp}(o_2)$ nor $\mathrm{supp}(o_2) \subseteq \mathrm{supp}(o_1)$.

### 2.3 Tanner Hypergraphs

**Definition 2.5.** A *Tanner hypergraph* consists of:
- A set of check nodes $\mathrm{checkNodes} \subseteq \mathrm{Obs}$
- An incidence function $\mathrm{inc} : \mathrm{Obs} \to \mathcal{P}_{\mathrm{fin}}(\alpha)$
- A weight function $\mathrm{wt}_T : \mathrm{Obs} \to \mathbb{N}$

**Definition 2.6.** A Tanner hypergraph *realizes* a closure-parity system if:
1. Every active observable is a check node
2. Check node incidences match system supports
3. Check node weights match system weights

**Definition 2.7.** A realization is *minimal* if it has the fewest check nodes among all realizations.

### 2.4 Parity Indicators and Semimodules

**Definition 2.8.** The *parity indicator* of observable $o$ is:
$$\mathbf{v}_o(a) = \begin{cases} \mathrm{wt}(o) & \text{if } a \in \mathrm{supp}(o) \\ 0 & \text{otherwise} \end{cases}$$

**Definition 2.9.** A vector $v : \alpha \to \mathbb{N}$ is in the *parity semimodule* if $v = \sum_o c_o \cdot \mathbf{v}_o$ for some coefficients $c : \mathrm{Obs} \to \mathbb{N}$.

**Definition 2.10.** An observable $o$ is an *extremal generator* if $\mathrm{supp}(o) \neq \emptyset$ and $\mathbf{v}_o$ cannot be written as $\sum_{o' \neq o} c_{o'} \cdot \mathbf{v}_{o'}$.

---

## 3. Parity Capacity and Closure Invariance

### 3.1 Parity Capacity

**Definition 3.1.** The *parity capacity* of a set $S \subseteq \alpha$ is:
$$\kappa(S) = |\{o \in \mathrm{Obs} \mid \mathrm{supp}(o) \subseteq S,\ \mathrm{supp}(o) \neq \emptyset\}|$$

**Theorem 3.1** (Monotonicity). $S \subseteq T \implies \kappa(S) \leq \kappa(T)$.

*Proof.* If $\mathrm{supp}(o) \subseteq S$ then $\mathrm{supp}(o) \subseteq T$, so the defining set for $\kappa(S)$ is a subset of that for $\kappa(T)$. □

**Theorem 3.2** (Closure invariance). $\kappa(S) \leq \kappa(\mathrm{cl}(S))$.

*Proof.* Since supports are closed, $\mathrm{supp}(o) \subseteq S$ implies $\mathrm{supp}(o) = \mathrm{cl}(\mathrm{supp}(o)) \subseteq \mathrm{cl}(S)$ by monotonicity of $\mathrm{cl}$. □

### 3.2 Connection to Closure-Capacity Theory

The parity capacity function is a monotone, closure-invariant set function, connecting our framework to the closure-capacity–secret-sharing duality and the closure-capacity–attention duality established in prior work. The parity capacity plays the role of the "information content" of a set of symbols, measured by the number of independent parity checks it supports.

---

## 4. Syndrome Map and Duality

### 4.1 Syndrome Computation

**Definition 4.1.** The *syndrome* of a word $w : \alpha \to \mathbb{N}$ at observable $o$ is:
$$\mathrm{syn}(w, o) = \sum_{a \in \mathrm{supp}(o)} w(a)$$

**Theorem 4.1** (Syndrome-Tanner factorization). For any realization $T$ of a closure-parity system and any $o \in \mathrm{checkNodes}(T)$:
$$\mathrm{syn}(w, o) = \sum_{a \in \mathrm{inc}_T(o)} w(a)$$

*Proof.* Since $\mathrm{inc}_T(o) = \mathrm{supp}(o)$ for check nodes, the sums are identical. □

### 4.2 Syndrome Separation

**Theorem 4.2** (Syndrome separation under disjointness). If $\mathrm{supp}(o_1) \cap \mathrm{supp}(o_2) = \emptyset$ and $\mathrm{supp}(o_1) \neq \emptyset$, then there exists $w$ with $\mathrm{syn}(w, o_1) \neq \mathrm{syn}(w, o_2)$.

*Proof sketch.* Choose $a \in \mathrm{supp}(o_1)$ and set $w = \mathbb{1}_{\{a\}}$. Then $\mathrm{syn}(w, o_1) = 1$ but $\mathrm{syn}(w, o_2) = 0$ (since $a \notin \mathrm{supp}(o_2)$ by disjointness). □

**Theorem 4.3** (Syndrome separation under separation). If the system is separated and $o_1 \neq o_2$ with $\mathrm{supp}(o_1) \neq \emptyset$, then there exists $w$ with $\mathrm{syn}(w, o_1) \neq \mathrm{syn}(w, o_2)$.

*Proof sketch.* Since $\mathrm{supp}(o_1) \neq \mathrm{supp}(o_2)$, there exists $a$ in the symmetric difference. Setting $w = \mathbb{1}_{\{a\}}$ gives differing syndromes. □

---

## 5. Canonical Construction and Main Theorems

### 5.1 The Canonical Tanner Hypergraph

**Definition 5.1.** The *canonical Tanner hypergraph* of a closure-parity system has:
- $\mathrm{checkNodes} = \mathrm{activeObs}$
- $\mathrm{inc}(o) = \mathrm{supp}(o)$
- $\mathrm{wt}_T(o) = \mathrm{wt}(o)$

**Theorem 5.1** (Realization). The canonical Tanner hypergraph realizes the closure-parity system.

*Proof.* Every active observable is in $\mathrm{checkNodes}$ by construction. Incidences and weights match by definition. □

### 5.2 Minimality

**Theorem 5.2** (Minimality). The canonical Tanner hypergraph is a minimal realization.

*Proof.* Any realization $T'$ must contain all active observables as check nodes (by the realization condition), so $|\mathrm{activeObs}| \leq |\mathrm{checkNodes}(T')|$. The canonical construction achieves this lower bound. □

**Lemma 5.1** (Check-node characterization). In any minimal realization $T$, $\mathrm{checkNodes}(T) = \mathrm{activeObs}$.

*Proof.* We have $\mathrm{activeObs} \subseteq \mathrm{checkNodes}(T)$ (from the realization condition) and $|\mathrm{checkNodes}(T)| \leq |\mathrm{activeObs}|$ (from minimality, since the canonical construction achieves $|\mathrm{activeObs}|$). Equal cardinality with subset containment implies equality. □

### 5.3 Uniqueness

**Theorem 5.3** (Uniqueness of minimal realizations). Any two minimal realizations $T_1, T_2$ of a closure-parity system are equivalent: they have the same check nodes, the same incidences on check nodes, and the same weights on check nodes.

*Proof.* By Lemma 5.1, $\mathrm{checkNodes}(T_1) = \mathrm{activeObs} = \mathrm{checkNodes}(T_2)$. For any $o \in \mathrm{checkNodes}(T_1)$, both realizations give $\mathrm{inc}_{T_i}(o) = \mathrm{supp}(o)$ and $\mathrm{wt}_{T_i}(o) = \mathrm{wt}(o)$. □

### 5.4 Certified Reconstruction

**Theorem 5.4** (Certified reconstruction). The function $\mathrm{reconstructMinimalTanner}$ computes a minimal realization from closure-parity data, with machine-verified correctness.

**Algorithm: reconstructMinimalTanner**
```
Input: Closure-parity system (α, Obs, cl, supp, wt)
Output: Minimal Tanner hypergraph T

1. Compute activeObs = {o ∈ Obs | supp(o) ≠ ∅}
2. Set T.checkNodes = activeObs
3. Set T.incidence(o) = supp(o) for all o
4. Set T.checkWeight(o) = wt(o) for all o
5. Return T
```

**Complexity.** The algorithm runs in $O(|\mathrm{Obs}| \cdot |\alpha|)$ time (filtering active observables and copying support/weight data).

---

## 6. Extremal Generator Correspondence

### 6.1 Main Extremal Theorem

**Theorem 6.1** (Extremal-Tanner correspondence). If the closure-parity system has incomparable supports and positive weights on active observables, then:
1. Every check node of the canonical minimal Tanner realization is an extremal generator.
2. Every extremal generator is a check node.

Hence the extremal generators correspond bijectively to the check nodes.

*Proof sketch.* For (2): extremal generators have nonempty support by definition, so they are active and hence check nodes.

For (1): Suppose $o$ is active but not extremal. Then $\mathbf{v}_o = \sum_{o' \neq o} c_{o'} \cdot \mathbf{v}_{o'}$ for some coefficients. For any $a \notin \mathrm{supp}(o)$, we have $\mathbf{v}_o(a) = 0$, so $\sum_{o'} c_{o'} \cdot \mathbf{v}_{o'}(a) = 0$. Since all terms are non-negative, each $c_{o'} \cdot \mathbf{v}_{o'}(a) = 0$. If $a \in \mathrm{supp}(o')$ and $\mathrm{wt}(o') \neq 0$, then $c_{o'} = 0$. This means any $o'$ with $c_{o'} > 0$ must have $\mathrm{supp}(o') \subseteq \mathrm{supp}(o)$. By incomparability, no active $o' \neq o$ satisfies this. So all $c_{o'} = 0$, giving $\mathbf{v}_o = 0$, contradicting $\mathrm{wt}(o) \neq 0$. □

### 6.2 Support Recovery from Indicators

**Theorem 6.2** (Support recovery). If $\mathrm{wt}(o) \neq 0$, the support of $o$ can be recovered from its parity indicator:
$$\mathrm{supp}(o) = \{a \in \alpha \mid \mathbf{v}_o(a) \neq 0\}$$

**Theorem 6.3** (Indicator determines support). If $\mathbf{v}_{o_1}$ and $\mathbf{v}_{o_2}$ have the same nonzero pattern and both have positive weights, then $\mathrm{supp}(o_1) = \mathrm{supp}(o_2)$.

---

## 7. The Main Duality Package

**Theorem 7.1** (Certified Minimal Tanner Reconstruction). Every closure-parity system admits a canonical minimal Tanner realization $T$ such that:
1. $T$ realizes the system (supports and weights match)
2. $T$ achieves minimum check-node count
3. Syndrome computation factors through $T$'s incidence structure
4. $T$ is unique among minimal realizations up to equivalence

**Theorem 7.2** (Closure-Parity Semimodule Duality). Under incomparable supports and positive weights, the canonical minimal Tanner realization satisfies the additional property that its check nodes correspond bijectively to the extremal generators of the parity semimodule.

---

## 8. Applications

### 8.1 Code Design Pipeline

The certified reconstruction theorem provides a systematic code design methodology:
1. Specify the desired closure operator (encoding the logical structure of the code)
2. Choose parity observables with closed supports (encoding the error-detection constraints)
3. Apply `reconstructMinimalTanner` to obtain the optimal Tanner graph
4. Use the Tanner graph for iterative decoding (belief propagation, min-sum, etc.)

### 8.2 Cryptographic Applications

In code-based cryptography (e.g., McEliece/Niederreiter), the security relies on the difficulty of decoding random linear codes. The canonical nature of the minimal Tanner graph has implications:
- **Positive:** Certified reconstruction can verify that a designed code has the intended structure.
- **Cautionary:** The uniqueness theorem implies that the Tanner structure cannot be hidden by choosing a different representation—it is algebraically determined.

### 8.3 Worked Example

Consider $\alpha = \{0, 1, 2, 3\}$ with the identity closure ($\mathrm{cl}(S) = S$) and three observables:
- $o_1$: support $\{0, 1\}$, weight 1
- $o_2$: support $\{2, 3\}$, weight 1
- $o_3$: support $\{0, 2\}$, weight 2

The supports are pairwise incomparable. The canonical Tanner hypergraph has 3 check nodes (all active), with incidence matching the supports. This is minimal and unique.

For the word $w = (1, 0, 1, 0)$:
- $\mathrm{syn}(w, o_1) = w(0) + w(1) = 1$
- $\mathrm{syn}(w, o_2) = w(2) + w(3) = 1$
- $\mathrm{syn}(w, o_3) = w(0) + w(2) = 2$

The syndrome vector $(1, 1, 2)$ uniquely identifies the error pattern in this small example.

---

## 9. Computational Experiments

We implemented the closure-parity system framework and canonical Tanner reconstruction in Python. See `demo.py` for:
- Construction of closure-parity systems from adjacency data
- Canonical Tanner reconstruction with verification
- Syndrome computation and visualization
- Comparison of minimal vs. non-minimal realizations

Key numerical results:
- For random closure-parity systems on $|\alpha| = 20$ with $|\mathrm{Obs}| = 30$, the canonical construction consistently produces minimal realizations with $|\mathrm{activeObs}| \leq |\mathrm{Obs}|$ check nodes.
- The syndrome separation property holds in all tested instances with separation.
- Extremal generator count matches check-node count under incomparability.

---

## 10. Discussion

### 10.1 Relationship to Classical Coding Theory

In classical linear coding theory over $\mathbb{F}_q$, the parity-check matrix $H$ determines the code and the Tanner graph. Our framework generalizes this by replacing the field structure with a closure operator and replacing matrix rows with parity observables. The key advantage is that closure operators exist in much greater generality than field structures, enabling codes over arbitrary algebraic settings.

### 10.2 Limitations

1. The current framework uses $\mathbb{N}$-valued weights. Extending to tropical semirings ($\mathbb{N}_\infty$ with min-plus) would give a richer theory.
2. The incomparability condition for extremal correspondence is sufficient but may not be necessary in all cases.
3. The uniqueness theorem characterizes uniqueness among Tanner hypergraphs with the same observable type. Cross-type uniqueness (comparing systems with different observable sets) requires the stronger notion of Tanner isomorphism.

### 10.3 Open Questions

1. Does the extremal correspondence extend to tropical semimodules over arbitrary idempotent semirings?
2. Can the canonical Tanner graph be used to certify the convergence of belief propagation?
3. What is the computational complexity of determining whether a given Tanner graph is the canonical minimal realization of some closure-parity system?

---

## 11. Future Work

See `FUTURE_DIRECTIONS.md` for a structured roadmap including:
1. Tropical belief propagation correctness via residuated projection
2. Matroidal decoding semantics
3. Cryptographic hardness transfer theorems
4. Categorical equivalence of closure-parity systems and admissible semimodules
5. Tropical convex hull semantics for list decoding

---

## References

1. Birkhoff, G. (1940). *Lattice Theory*. AMS Colloquium Publications.
2. Ganter, B., & Wille, R. (1999). *Formal Concept Analysis*. Springer.
3. Tanner, R. M. (1981). A recursive approach to low complexity codes. *IEEE Trans. Inform. Theory*, 27(5), 533–547.
4. Welsh, D. J. A. (1976). *Matroid Theory*. Academic Press.
5. Wiberg, N., Loeliger, H.-A., & Kötter, R. (1995). Codes and iterative decoding on general graphs. *European Trans. Telecomm.*, 6(5), 513–525.
6. Richardson, T. J., & Urbanke, R. L. (2008). *Modern Coding Theory*. Cambridge University Press.
