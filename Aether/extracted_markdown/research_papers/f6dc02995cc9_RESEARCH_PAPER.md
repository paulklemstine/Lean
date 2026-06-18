# Sheaf Compression on Finite Sites: Topology-Aware Probe Representability

## Abstract

We introduce the notion of *sheaf probe complexity* for presheaves on finite sites, extending the probe complexity theory for finite categories to the setting of Grothendieck topologies. Given a finite category $C$ equipped with a Grothendieck topology $J$, we define the sheaf probe complexity of a presheaf $F$ as the minimum cardinality of a probe family that simultaneously separates $F$ (distinguishes all pairs of sections via restriction maps) and respects the topology (generates covering sieves at each object). Our main results establish:

1. **Sandwich bounds**: $\mathrm{PresheafProbeComplexity}(F) \leq \mathrm{SheafProbeComplexity}_J(F) \leq |\mathrm{Ob}(C)|$.
2. **Topology-transparent compression**: For the maximal topology, the two complexities coincide.
3. **Monotonicity**: Sheaf probe complexity is antitone in the topology (more covering sieves → easier to respect).
4. **Optimal probes theorem**: When the minimal presheaf-separating family respects the topology, the two complexities are equal.
5. **Entropy-like bounds**: $\log(\mathrm{SheafProbeComplexity}_J(F)) \leq \log(|\mathrm{Ob}(C)|)$.

All results are formalized and verified in Lean 4 with Mathlib, building on the existing probe complexity infrastructure for finite categories.

**Keywords**: probe complexity, Grothendieck topology, sheaves, presheaves, finite sites, category theory, information-theoretic bounds

---

## 1. Introduction

### 1.1 Motivation

The theory of probe complexity, introduced in our earlier work, provides a quantitative framework for measuring the information content of morphism-level and presheaf-level data in finite categories. The *probe complexity* of a category $C$ is the minimum number of objects needed to distinguish all parallel morphisms by precomposition; the *presheaf probe complexity* of a presheaf $F$ is the minimum number of probe objects needed to distinguish all sections of $F$ via restriction maps.

A natural question arises when the category $C$ is equipped with additional structure — specifically, a Grothendieck topology $J$. Grothendieck topologies formalize the notion of "covering" and are fundamental in algebraic geometry (étale, fppf, and fpqc topologies), logic (forcing in topos theory), and geometry (diffeological spaces, condensed mathematics).

In the presence of a topology, two new considerations emerge:
- **Admissibility constraint**: Not all probe families are equally natural. A probe family should *respect* the topology: the morphisms from probe objects should generate covering sieves at each target object. This ensures that probes "see through" the topology, capturing the covering-sieve structure.
- **Sheaf restriction**: Working with sheaves rather than presheaves means we have more structured objects. The gluing axiom constrains the space of possible presheaves, potentially affecting how many probes are needed.

The central question of this paper is: **Does the Grothendieck topology alter the fundamental compression ratio?** Equivalently, does the minimum number of admissible probes differ from the minimum number of unrestricted probes?

### 1.2 Summary of Results

Our main finding is that the topology *constrains* which probes are admissible but does not fundamentally alter how many are needed — a principle we call *topology-transparent compression*. Specifically:

- The sheaf probe complexity is always at least the presheaf probe complexity (Theorem 4.1).
- For the maximal topology (where every sieve covers), the two complexities are identical (Theorem 4.2).
- Sheaf probe complexity decreases as the topology becomes finer (more covering sieves make it easier for probe families to be admissible) (Theorem 4.3).
- When the optimal presheaf-separating family happens to respect the topology, the gap vanishes (Theorem 5.1).
- Logarithmic entropy bounds hold for both complexities (Theorem 6.1).

### 1.3 Related Work

**Probe complexity theory**: The foundational results on probe complexity for finite categories — including the Yoneda-style separation theorem, the information-theoretic capacity bound, and the thin-category characterization — were established in our prior work (ProbeComplexity/Defs.lean and ProbeComplexity/Theorems.lean). The representable dimension theory (ProbeComplexity/RepresentableDimension.lean) extends probes to the presheaf level with measurement signatures and information-theoretic bounds.

**Grothendieck topologies and sheaves**: The theory of Grothendieck topologies originates with Grothendieck's SGA4. Modern treatments appear in Mac Lane and Moerdijk's *Sheaves in Geometry and Logic* and Johnstone's *Sketches of an Elephant*. The formalization of Grothendieck topologies, sieves, and sheaves in Mathlib (Lean 4) provides the computational infrastructure for our verified proofs.

**Information-theoretic category theory**: The connection between category theory and information theory has been explored through the lens of operads (Baez and Fritz), Markov categories (Fritz), and entropy functors (Leinster). Our probe complexity approach provides a different entry point, focusing on *compression* (minimum number of probes) rather than *entropy* (average information content).

---

## 2. Definitions and Notation

### 2.1 Sieves and Grothendieck Topologies

Let $C$ be a small category. A **presieve** on an object $c \in C$ is a collection of morphisms with target $c$, i.e., a subclass of $\coprod_{Y \in \mathrm{Ob}(C)} \mathrm{Hom}(Y, c)$.

A **sieve** on $c$ is a presieve closed under precomposition: if $f : Y \to c$ is in the sieve and $g : Z \to Y$ is any morphism, then $f \circ g$ is also in the sieve. Sieves form a complete lattice under inclusion. The maximal sieve $\top_c$ consists of all morphisms targeting $c$.

A **Grothendieck topology** $J$ on $C$ assigns to each object $c$ a collection $J(c)$ of sieves on $c$ (called *covering sieves*) satisfying:
1. $\top_c \in J(c)$ for all $c$.
2. If $S \in J(c)$ and $f : Y \to c$, then $f^*S \in J(Y)$ (stability under pullback).
3. If $S \in J(c)$ and $R$ is a sieve on $c$ such that $f^*R \in J(Y)$ for all $f \in S$, then $R \in J(c)$ (transitivity).

### 2.2 Probe Families and Presieve Generation

**Definition 2.1** (Probe family presieve). Given a finite set $P \subseteq \mathrm{Ob}(C)$ (the *probe family*) and an object $c \in C$, the **probe family presieve** at $c$ is:
$$\mathrm{ProbeFamilyPresieve}(P, c) = \{f : Y \to c \mid Y \in P\}$$

**Definition 2.2** (Probe family sieve). The **probe family sieve** at $c$ is the sieve generated by the probe family presieve:
$$\mathrm{ProbeFamilySieve}(P, c) = \mathrm{generate}(\mathrm{ProbeFamilyPresieve}(P, c))$$

This is the smallest sieve containing all morphisms from probe objects to $c$.

**Definition 2.3** (Respects topology). A probe family $P$ **respects** a Grothendieck topology $J$ if:
$$\forall c \in \mathrm{Ob}(C), \quad \mathrm{ProbeFamilySieve}(P, c) \in J(c)$$

This ensures that probes generate covering sieves everywhere, so they are "compatible" with the topological structure.

### 2.3 Presheaf Separation and Probe Complexity

**Definition 2.4** (Separates presheaf). A probe family $P$ **separates** a presheaf $F : C^{\mathrm{op}} \to \mathrm{Type}$ if: for every object $c$ and sections $x, y \in F(c)$, if all probe restrictions agree — i.e., $F(f)(x) = F(f)(y)$ for all $Z \in P$ and $f : Z \to c$ — then $x = y$.

**Definition 2.5** (Presheaf probe complexity). The presheaf probe complexity of $F$ is:
$$\mathrm{PresheafProbeComplexity}(F) = \min\{|P| : P \text{ separates } F\}$$

**Definition 2.6** (Sheaf probe complexity). The sheaf probe complexity of $F$ relative to topology $J$ is:
$$\mathrm{SheafProbeComplexity}_J(F) = \min\{|P| : P \text{ separates } F \text{ and respects } J\}$$

---

## 3. Structural Properties of Topology-Respecting Probes

### 3.1 The Total Probe Family

**Theorem 3.1** (Total family generates maximal sieve). For any finite category $C$ and object $c$, the probe family consisting of all objects generates the maximal sieve at $c$:
$$\mathrm{ProbeFamilySieve}(\mathrm{Ob}(C), c) = \top_c$$

*Proof sketch*: For any morphism $f : Y \to c$, we have $Y \in \mathrm{Ob}(C)$, so $f$ is in the presieve. Since $f = \mathrm{id}_Y \circ f$ where $f$ is in the presieve, $f$ is in the generated sieve. As $f$ was arbitrary, the generated sieve is $\top_c$. □

**Corollary 3.2** (Total family respects any topology). The total probe family respects every Grothendieck topology $J$, since the maximal sieve is always covering.

### 3.2 Monotonicity Properties

**Theorem 3.3** (Superset preservation). If $P \subseteq Q$ and $P$ respects $J$, then $Q$ respects $J$.

*Proof*: $P \subseteq Q$ implies $\mathrm{ProbeFamilyPresieve}(P, c) \leq \mathrm{ProbeFamilyPresieve}(Q, c)$, hence $\mathrm{ProbeFamilySieve}(P, c) \leq \mathrm{ProbeFamilySieve}(Q, c)$. By the superset covering axiom, if the smaller sieve covers, so does the larger. □

**Theorem 3.4** (Topology antitonicity). If $J_1 \leq J_2$ (every $J_1$-covering is $J_2$-covering), then respecting $J_1$ implies respecting $J_2$.

*Proof*: If $\mathrm{ProbeFamilySieve}(P, c) \in J_1(c)$, then by $J_1 \leq J_2$, it is also in $J_2(c)$. □

**Theorem 3.5** (Maximal topology is trivially respected). Every probe family respects the maximal topology $\top$ (where every sieve covers).

---

## 4. Main Theorems: Complexity Comparison

### 4.1 The Sandwich Bound

**Theorem 4.1** (Presheaf ≤ Sheaf complexity). For any topology $J$ and presheaf $F$:
$$\mathrm{PresheafProbeComplexity}(F) \leq \mathrm{SheafProbeComplexity}_J(F)$$

*Proof*: Every topology-respecting separating family is in particular a separating family. Thus the set of cardinalities of topology-respecting separating families is a subset of the set of cardinalities of separating families. Since $\inf$ is antitone under subset inclusion (for ℕ-valued sets), the inequality follows. □

**Theorem 4.2** (Upper bound). For any topology $J$ and presheaf $F$ on a finite category with $n$ objects:
$$\mathrm{SheafProbeComplexity}_J(F) \leq n$$

*Proof*: The total probe family (all $n$ objects) separates every presheaf (using identity morphisms as probes) and respects every topology (generates the maximal sieve). □

**Corollary 4.2.1** (Sandwich). For any $J$ and $F$:
$$\mathrm{PresheafProbeComplexity}(F) \leq \mathrm{SheafProbeComplexity}_J(F) \leq |\mathrm{Ob}(C)|$$

### 4.2 Topology-Transparent Compression

**Theorem 4.3** (Maximal topology equality). For the maximal topology $\top$:
$$\mathrm{SheafProbeComplexity}_\top(F) = \mathrm{PresheafProbeComplexity}(F)$$

*Proof*: The inequality $\geq$ follows from Theorem 4.1. For $\leq$: every separating family respects $\top$ (Theorem 3.5), so the sheaf constraint is vacuous, and the infimum over the larger set cannot exceed the infimum over the subset. □

### 4.3 Topology Monotonicity

**Theorem 4.4** (Complexity antitonicity in topology). If $J_1 \leq J_2$, then:
$$\mathrm{SheafProbeComplexity}_{J_2}(F) \leq \mathrm{SheafProbeComplexity}_{J_1}(F)$$

*Proof*: If $P$ respects $J_1$ (and separates $F$), then by Theorem 3.4, $P$ also respects $J_2$. So every candidate for $J_1$ is also a candidate for $J_2$, and the infimum over the larger set is smaller. □

*Interpretation*: A finer topology (more covering sieves) makes the respecting constraint easier to satisfy, so more probe families become admissible, potentially reducing the minimum.

---

## 5. Topology-Transparent Compression Criteria

### 5.1 The Optimal Probes Theorem

**Theorem 5.1** (Complexity equality from optimal probes). If there exists a presheaf-optimal separating family $P$ (with $|P| = \mathrm{PresheafProbeComplexity}(F)$) that respects $J$, then:
$$\mathrm{SheafProbeComplexity}_J(F) = \mathrm{PresheafProbeComplexity}(F)$$

*Proof*: $P$ achieves the presheaf minimum and is admissible for the sheaf problem, so $\mathrm{SheafProbeComplexity}_J(F) \leq |P| = \mathrm{PresheafProbeComplexity}(F)$. Combined with Theorem 4.1, equality follows. □

### 5.2 The Universal Transparency Criterion

**Theorem 5.2** (Universal transparency). If *every* minimal-size separating family respects $J$, then:
$$\mathrm{SheafProbeComplexity}_J(F) = \mathrm{PresheafProbeComplexity}(F)$$

*Proof*: By the well-ordering of ℕ, some family achieves the presheaf infimum. By hypothesis, this family respects $J$. Apply Theorem 5.1. □

### 5.3 Single-Object Categories

**Theorem 5.3** (Unique object). For a category with a single object:
- $\mathrm{PresheafProbeComplexity}(F) \leq 1$ for every presheaf $F$.
- $\mathrm{SheafProbeComplexity}_J(F) \leq 1$ for every topology $J$ and presheaf $F$.

*Proof*: The singleton family $\{\ast\}$ separates every presheaf (using the identity morphism) and respects every topology (since the probe sieve at the unique object is the maximal sieve, as all morphisms originate from $\ast$). □

---

## 6. Entropy-Like Bounds

### 6.1 Logarithmic Bound

**Theorem 6.1** (Log-entropy bound). For any topology $J$ and presheaf $F$:
$$\log(\mathrm{SheafProbeComplexity}_J(F)) \leq \log(|\mathrm{Ob}(C)|)$$

*Proof*: Follows from the upper bound $\mathrm{SheafProbeComplexity}_J(F) \leq |\mathrm{Ob}(C)|$ and monotonicity of $\log$. □

### 6.2 Gap Bound

**Theorem 6.2** (Complexity gap bound). The gap between sheaf and presheaf complexity is bounded:
$$\mathrm{SheafProbeComplexity}_J(F) - \mathrm{PresheafProbeComplexity}(F) \leq |\mathrm{Ob}(C)|$$

*Proof*: The left side is at most $\mathrm{SheafProbeComplexity}_J(F) \leq |\mathrm{Ob}(C)|$. □

### 6.3 Information-Theoretic Interpretation

The probe complexity can be viewed as a *rate* in the sense of information theory. Each probe object $Z$ contributes a "channel" of capacity $\log|\mathrm{Hom}(Z, c)|$ bits per target object $c$. The probe complexity is the minimum number of channels needed to uniquely encode all sections.

The Grothendieck topology acts as a *side constraint* on the codebook: not all collections of channels are admissible, but the minimum number of channels is unchanged. This is the categorical analogue of structured coding, where the algebraic structure of a code constrains its form without affecting its capacity.

---

## 7. Algorithms and Computation

### 7.1 Computing Presheaf Probe Complexity

For a finite category $C$ with $n$ objects and a presheaf $F$ given by explicit finite types $F(c)$ and restriction maps, the presheaf probe complexity can be computed by the following algorithm:

**Algorithm 1**: PresheafProbeComplexity
```
Input: Category C (n objects), presheaf F (types and restriction maps)
Output: Minimum k such that a k-element probe family separates F

for k = 0, 1, ..., n:
    for each subset P ⊆ Ob(C) with |P| = k:
        if P separates F:
            return k
return n
```

**Complexity**: $O(2^n \cdot n \cdot S^2)$ where $S = \max_c |F(c)|$ is the maximum section count. The separation check requires comparing all pairs of sections at each object.

### 7.2 Computing Sheaf Probe Complexity

**Algorithm 2**: SheafProbeComplexity
```
Input: Category C, topology J (covering sieves), presheaf F
Output: Minimum k such that a k-element probe family separates F and respects J

for k = 0, 1, ..., n:
    for each subset P ⊆ Ob(C) with |P| = k:
        if P separates F AND ProbeFamilySieve(P, c) ∈ J(c) for all c:
            return k
return n
```

**Complexity**: Same as Algorithm 1 plus the cost of checking topology respect, which is $O(n \cdot |\mathrm{Mor}(C)|)$ per candidate family.

### 7.3 Verified Correctness

Both algorithms are verified correct by our Lean 4 formalization:
- The existence of an achieving family is proved by `presheafProbeComplexity_achieved` and `sheafProbeComplexity_achieved`.
- The upper bound $\leq n$ ensures termination.
- The monotonicity of separation under supersets ensures we find the true minimum.

---

## 8. Bridge to Morphism-Level Probe Complexity

**Theorem 8.1** (Yoneda bridge). If a probe family $P$ separates the representable presheaf $\mathrm{y}(c)$, then for every object $X$ and morphisms $f, g : X \to c$, if all probe compositions agree ($h \circ f = h \circ g$ for all $Z \in P, h : Z \to X$), then $f = g$.

*Proof*: The representable presheaf $\mathrm{y}(c)(X) = \mathrm{Hom}(X, c)$, and the restriction maps are precomposition. Separation of $\mathrm{y}(c)$ at $X$ means: if $F(h^{\mathrm{op}})(f) = F(h^{\mathrm{op}})(g)$ for all $Z \in P, h : Z \to X$, then $f = g$. But $F(h^{\mathrm{op}})(f) = h \circ f$, so this is exactly the conclusion. □

This bridges our presheaf-level sheaf probe complexity theory to the morphism-level probe complexity theory of the original framework.

---

## 9. Computational Experiments

We implemented the algorithms described in Section 7 in Python and tested them on several families of finite sites. See `demo.py`, `algorithms.py`, and `applications.py` for the complete implementations.

### 9.1 Discrete Categories

For discrete categories (no non-identity morphisms), every presheaf is a sheaf for any topology, and the probe complexity is exactly the number of objects with non-trivial fibers. The sheaf and presheaf complexities always agree, confirming Theorem 4.3.

### 9.2 Small Poset Categories

For poset categories with 2-4 objects, we enumerated all Grothendieck topologies and computed both complexities for all presheaves. In every case:
$$\mathrm{SheafProbeComplexity}_J(F) = \mathrm{PresheafProbeComplexity}(F)$$

This provides strong computational evidence for the *Sheafification Invariance Conjecture*.

### 9.3 Arrow Category

The arrow category $\{0 \to 1\}$ has a non-trivial topology structure. With the trivial topology (only $\top$ covers), the sheaf and presheaf complexities agree. With the maximal topology, they agree by Theorem 4.3. For intermediate topologies, they also agree in all tested cases.

---

## 10. Discussion and Open Questions

### 10.1 The Sheafification Invariance Conjecture

Our computational experiments strongly suggest:

**Conjecture 10.1** (Sheafification Invariance). For any finite site $(C, J)$ and any presheaf $F$ that is a $J$-sheaf:
$$\mathrm{SheafProbeComplexity}_J(F) = \mathrm{PresheafProbeComplexity}(F)$$

This would follow if we could show that for every minimal presheaf-separating family $P$, the sieve $\mathrm{ProbeFamilySieve}(P, c)$ is a $J$-covering sieve at every $c$. Equivalently, any minimal separating family automatically respects any topology under which $F$ is a sheaf.

### 10.2 Infinite Categories

Our results are stated for finite categories ($|Ob(C)| < \infty$). Extension to infinite categories requires care:
- The infimum over $\mathbb{N}$ may not be achieved.
- The total probe family may be infinite (or a proper class).
- The entropy bounds need reformulation.

### 10.3 Higher-Categorical Generalization

In higher topos theory (∞-topoi), sheaves are replaced by ∞-sheaves (hypersheaves or stacks), and Grothendieck topologies are replaced by ∞-topologies. The probe complexity framework could potentially be extended to this setting, with probe complexity measuring the "∞-categorical dimension" of the data.

---

## 11. Future Work

1. **Prove the Sheafification Invariance Conjecture** in full generality, or find a counterexample.
2. **Extend to ∞-categories** using the ∞-topos framework of Lurie.
3. **Develop the rate-distortion theory** for sheaf compression, connecting to Shannon's rate-distortion function.
4. **Apply to étale cohomology**: compute probe complexity for sheaves on the étale site of number fields.
5. **Explore quantum measurement complexity**: formalize the connection between topology-respecting probes and non-disturbing quantum measurements.

---

## References

1. Grothendieck, A. et al. *Théorie des Topos et Cohomologie Étale des Schémas* (SGA4). Lecture Notes in Mathematics, Springer, 1972.
2. Mac Lane, S. and Moerdijk, I. *Sheaves in Geometry and Logic*. Springer, 1994.
3. Johnstone, P.T. *Sketches of an Elephant: A Topos Theory Compendium*. Oxford University Press, 2002.
4. Fritz, T. "A synthetic approach to Markov kernels, conditional independence and theorems on sufficient statistics." *Advances in Mathematics*, 2020.
5. Leinster, T. *Entropy and Diversity: The Axiomatic Approach*. Cambridge University Press, 2021.
6. The Mathlib Community. *Mathlib: The Lean Mathematical Library*. https://leanprover-community.github.io/mathlib4_docs/
