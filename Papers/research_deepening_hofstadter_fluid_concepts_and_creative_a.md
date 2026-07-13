# Analogy as an Adjoint Operation: Galois Connections, Closure, Fidelity, and the Tropical Residual

## Abstract

We develop a mathematical theory of analogy-making between ordered structures. An analogy from a source poset $A$ to a target poset $B$ is defined as a pair of order-preserving maps $(F, G)$ — a *forward* map $F : A \to B$ and a *backward* map $G : B \to A$ — satisfying the adjunction law $F(a) \le b \iff a \le G(b)$; that is, a monotone Galois connection. From this single law we derive the entire structural theory: (i) the round-trip map $G \circ F$ is a closure operator on $A$ (inflationary, monotone, idempotent), while $F \circ G$ is dually an interior operator on $B$; (ii) the backward map is *uniquely* determined by the forward map, given by $G(b) = \sup\{a : F(a) \le b\}$; (iii) the **fidelity** of an analogy — the number of source points recovered exactly by a round trip — equals the cardinality of the image of $G \circ F$, and is maximized precisely by the *perfect* analogies, those with $G \circ F = \mathrm{id}_A$. We then instantiate the theory in the min-plus (tropical) semiring, where min-plus matrix multiplication $v \mapsto A \otimes v$ is paired with its canonical adjoint, the max-plus **residual** $A^\sharp$. The adjunction specializes to the classical reconstruction inequalities $w \le A \otimes (A^\sharp w)$ and $A^\sharp(A \otimes v) \le v$, recovering the standard theory of solving min-plus linear systems and shortest-path reconstruction. We give algorithms, numerical demonstrations, and applications to analogical reasoning, data reconstruction, and combinatorial optimization, and we conclude with a program of conjectures relating fidelity to a rank-type invariant, to Lipschitz-optimal reconstruction, and to order isomorphisms of stable cores.

---

## 1. Introduction

Analogy — the recognition that two ostensibly different structures share a common relational skeleton — is a central mode of human and machine reasoning. It is usually studied informally or heuristically: an analogy is judged "good" if it "captures the right correspondences." Our goal is to make this precise by treating analogy as a genuine mathematical *operation* between ordered structures, endowed with laws, a canonical best form, and quantitative invariants.

The key move is to insist that an analogy is not a single map but a *matched pair*: a forward translation together with a backward translation, bound by a compatibility law. The right law is the one that makes each map the best possible partner of the other — the **adjunction** condition of a monotone Galois connection. This viewpoint immediately explains several intuitive properties of good analogies: that translating a concept out and back can only stabilize it (closure), that the backward interpretation is not a free artistic choice but is forced by the forward map (uniqueness), and that some analogies are strictly more faithful than others (fidelity). We then show that in the tropical semiring — the arithmetic of optimization and shortest paths — the abstract "best analogy" is a concrete, computable object: the residual matrix.

### Contributions

1. A definition of analogy as a monotone Galois connection between posets, and a self-contained derivation of its structural consequences (Section 3).
2. A proof that the round-trip map is a closure operator and that the backward map is uniquely determined by the forward map (Section 3).
3. A quantitative theory of **fidelity**, identifying it with the size of the closure image and characterizing perfect analogies as the fidelity maximizers (Section 4).
4. An instantiation in the min-plus semiring, exhibiting the residual as the canonical best analogy and deriving the reconstruction inequalities (Section 5).
5. Algorithms, numerical demonstrations, and applications (Sections 6–7), and a program of open conjectures (Section 8).

---

## 2. Preliminaries: posets and monotone maps

A **partially ordered set** (poset) is a set $P$ with a relation $\le$ that is reflexive ($x \le x$), antisymmetric ($x \le y$ and $y \le x$ imply $x = y$), and transitive. A map $f : P \to Q$ between posets is **monotone** (order-preserving) if $x \le y$ implies $f(x) \le f(y)$.

We interpret a poset as a "conceptual world": elements are concepts, and $x \le y$ means "$x$ is subsumed by / more specific than / contained in $y$." Standard examples: the powerset $2^S$ ordered by inclusion; the divisibility order on $\mathbb{N}$; a vector of costs ordered coordinatewise; and, centrally for us, $(\overline{\mathbb{R}})^n = (\mathbb{R} \cup \{+\infty\})^n$ ordered coordinatewise.

---

## 3. Analogies as adjoint pairs

### 3.1 Definition

**Definition 3.1 (Analogy).** Let $(A, \le)$ and $(B, \le)$ be posets. An **analogy** from $A$ to $B$ is a pair $(F, G)$ of maps $F : A \to B$ and $G : B \to A$ such that
$$F(a) \le b \quad \Longleftrightarrow \quad a \le G(b) \qquad \text{for all } a \in A,\ b \in B. \tag{$\ast$}$$
We call $F$ the **forward** map and $G$ the **backward** map. In the terminology of order theory, $(F, G)$ is a *monotone Galois connection* with $F$ the left adjoint and $G$ the right adjoint.

The law $(\ast)$ is the entire axiomatic content. Everything below is a consequence.

### 3.2 Monotonicity is automatic

**Proposition 3.2.** If $(F, G)$ is an analogy, then both $F$ and $G$ are monotone.

*Proof sketch.* Suppose $a \le a'$ in $A$. Applying $(\ast)$ to the pair $(a', F(a'))$ with the reflexive fact $F(a') \le F(a')$ gives $a' \le G(F(a'))$; combining with $a \le a'$ yields $a \le G(F(a'))$, and $(\ast)$ (used right-to-left) turns this into $F(a) \le F(a')$. The argument for $G$ is dual: from $b \le b'$ and $G(b) \le G(b)$ one gets $F(G(b)) \le b \le b'$, hence $G(b) \le G(b')$. $\square$

### 3.3 The unit and counit inequalities

**Proposition 3.3.** For every analogy $(F, G)$ and all $a \in A$, $b \in B$:
$$a \le G(F(a)) \qquad \text{(unit)}, \qquad\qquad F(G(b)) \le b \qquad \text{(counit)}.$$

*Proof sketch.* The unit is $(\ast)$ applied to the reflexive instance $F(a) \le F(a)$; the counit is $(\ast)$ applied to $G(b) \le G(b)$. $\square$

Interpretation: a round trip *out and back* through the analogy inflates a source concept ($a \le GFa$), while a round trip *in and out* deflates a target concept ($FGb \le b$). Translation is directionally honest.

### 3.4 The triangle identities

**Proposition 3.4.** $F \circ G \circ F = F$ and $G \circ F \circ G = G$.

*Proof sketch.* Apply $F$ (monotone) to the unit $a \le GFa$ to get $Fa \le FGFa$; apply the counit at $b = Fa$ to get $FGFa \le Fa$. Antisymmetry gives $FGFa = Fa$. The other identity is dual. $\square$

### 3.5 The round trip is a closure operator

**Definition 3.5.** A **closure operator** on a poset $P$ is a map $C : P \to P$ that is inflationary ($x \le C(x)$), monotone, and idempotent ($C \circ C = C$). Dually, an **interior (kernel) operator** is deflationary ($K(x) \le x$), monotone, and idempotent.

**Theorem 3.6.** Let $(F, G)$ be an analogy. Then $C := G \circ F$ is a closure operator on $A$, and $K := F \circ G$ is an interior operator on $B$.

*Proof sketch.* *Inflationary:* the unit (Prop. 3.3). *Monotone:* composition of monotone maps (Prop. 3.2). *Idempotent:* apply $G$ to the triangle identity $FGF = F$ (Prop. 3.4) to get $GFGF = GF$, i.e. $C \circ C = C$. The dual statement for $K$ follows by the symmetric argument. $\square$

The image of a closure operator, $\{a : C(a) = a\}$, is exactly its set of fixed points, and the operator acts as an idempotent retraction onto that set.

### 3.6 Uniqueness of the backward map

**Theorem 3.7 (Uniqueness).** The backward map of an analogy is uniquely determined by the forward map. Explicitly, if $G$ and $G'$ both complete $F$ into an analogy, then $G = G'$. Moreover, whenever the relevant suprema exist,
$$G(b) = \sup\{\, a \in A : F(a) \le b \,\}. \tag{3.1}$$

*Proof sketch.* Fix $b \in B$. By $(\ast)$, for any $a$ we have $a \le G(b)$ iff $F(a) \le b$; thus $G(b)$ is an upper bound of $S_b := \{a : F(a) \le b\}$ (take $a \in S_b$, then $F(a) \le b$ gives $a \le G(b)$), and $G(b)$ itself lies in $S_b$ because $F(G(b)) \le b$ by the counit. Hence $G(b)$ is the greatest element of $S_b$, which is its supremum, proving (3.1). Since the right-hand side of (3.1) refers only to $F$, any two backward maps agree, giving uniqueness. $\square$

Theorem 3.7 justifies speaking of *the* analogy generated by a forward map (when a completing backward map exists). The backward map is the *tightest monotone over-approximation* of a set-theoretic inverse: it returns the largest source concept whose forward image still fits below the target.

**Existence.** When $A$ is a complete lattice, a map $F$ admits a completing backward map iff $F$ preserves arbitrary suprema; then $G$ is defined by (3.1). In finite settings the suprema always exist, so the theory is unconditional.

---

## 4. Fidelity: quantifying analogical quality

### 4.1 Stable concepts

**Definition 4.1 (Stable concept).** A concept $a \in A$ is **stable** under the analogy $(F, G)$ if the round trip fixes it: $G(F(a)) = a$. Equivalently, $a$ is a fixed point of the closure operator $C = G \circ F$.

By Theorem 3.6, the set of stable concepts is exactly the image $C(A) = \{C(a) : a \in A\}$. Stability captures *lossless* translation: $a$ passes into $B$ and back with no distortion.

### 4.2 Fidelity

**Definition 4.2 (Fidelity).** For an analogy over a finite source poset $A$, the **fidelity** is
$$\Phi(F, G) := \#\{\, a \in A : G(F(a)) = a \,\} = \# C(A).$$

**Proposition 4.3.** $0 < \Phi(F, G) \le \#A$, and $\Phi(F, G) = \#C(A)$ where $C = G \circ F$.

*Proof sketch.* Every fixed point of $C$ lies in $C(A)$, and conversely each $c = C(a) \in C(A)$ satisfies $C(c) = C(C(a)) = C(a) = c$ by idempotence, so $c$ is a fixed point; hence the stable set equals $C(A)$. It is nonempty (it contains $C$ of any element) and bounded by $\#A$. $\square$

### 4.3 Perfect analogies maximize fidelity

**Definition 4.4 (Perfect analogy).** An analogy $(F, G)$ is **perfect** if $G \circ F = \mathrm{id}_A$; that is, every source concept is stable.

**Theorem 4.5 (Fidelity maximization).** Over a fixed finite source $A$, an analogy attains the maximum fidelity $\Phi = \#A$ if and only if it is perfect.

*Proof sketch.* If $(F,G)$ is perfect then every $a$ is stable, so $\Phi = \#A$, the maximum allowed by Prop. 4.3. Conversely, if $\Phi = \#A$ then all $\#A$ elements are stable, i.e. $GFa = a$ for every $a$, which is exactly $G \circ F = \mathrm{id}_A$. $\square$

Perfect analogies are precisely the situations where $F$ is injective with $G$ a left inverse compatible with the orders; on the stable core they realize an order embedding whose round trip is the identity. This is the rigorous sense in which "the best analogies maximize structural similarity": the composite $G \circ F$ is *as close to the identity as possible*, and it equals the identity exactly for the perfect ones.

---

## 5. The tropical instantiation: analogy as residuation

### 5.1 The min-plus semiring

The **min-plus** (tropical) semiring is $\overline{\mathbb{R}} = \mathbb{R} \cup \{+\infty\}$ with addition $x \oplus y = \min(x, y)$ and multiplication $x \otimes y = x + y$; the additive identity is $+\infty$ and the multiplicative identity is $0$. It is the arithmetic of optimization: sums of costs become genuine additions, and choices among alternatives become minima. On vectors and matrices, order is coordinatewise, and

$$(A \otimes v)_i = \min_j \big( A_{ij} + v_j \big), \qquad A \in \overline{\mathbb{R}}^{m \times n},\ v \in \overline{\mathbb{R}}^n.$$

This is the Bellman "relax all edges" operation: $(A \otimes v)_i$ is the cheapest way to reach node $i$ by paying edge cost $A_{ij}$ and then continuing at cost $v_j$.

### 5.2 The residual

The min-plus product $v \mapsto A \otimes v$ preserves coordinatewise infima (minima), so in the language of adjoint pairs it is a *right* adjoint; its uniquely determined *left*-adjoint partner is computed with the dual (max-plus) operations.

**Definition 5.1 (Residual).** For $A \in \overline{\mathbb{R}}^{m \times n}$, the **residual** $A^\sharp : \overline{\mathbb{R}}^m \to \overline{\mathbb{R}}^n$ is
$$(A^\sharp w)_j := \max_i \big( w_i - A_{ij} \big),$$
with the convention $w_i - (+\infty) = -\infty$ so that missing edges impose no constraint.

**Theorem 5.2 (Tropical analogy).** With the forward (reconstruction) map $F(w) = A^\sharp w$ and the backward (encoding) map $G(v) = A \otimes v$ on the coordinatewise order, the pair $(F, G)$ is an analogy:
$$A^\sharp w \le v \quad \Longleftrightarrow \quad w \le A \otimes v.$$

*Proof sketch.* $w \le A \otimes v$ means $w_i \le \min_j(A_{ij}+v_j)$ for all $i$, i.e. $w_i \le A_{ij}+v_j$ for all $i,j$, i.e. $w_i - A_{ij} \le v_j$ for all $i,j$, i.e. $\max_i(w_i - A_{ij}) \le v_j$ for all $j$ — precisely $A^\sharp w \le v$. Thus $(\ast)$ holds, with $A^\sharp w$ characterized as the *least* $v$ with $A \otimes v \ge w$ (the least super-solution). $\square$

By Theorem 3.7 the adjoint is unique: $A^\sharp$ is the canonical best analogy partner of the min-plus product, computed with the "opposite" (max/subtraction) operations — the max-plus residual of a min-plus map.

### 5.3 Reconstruction inequalities

Specializing Prop. 3.3 (unit and counit) gives the classical **reconstruction sandwich**:
$$w \le A \otimes (A^\sharp w) \qquad \text{(unit)}, \qquad\qquad A^\sharp (A \otimes v) \le v \qquad \text{(counit)}.$$

The unit says: encoding the residual reconstruction of $w$ never under-claims — the re-encoded vector dominates $w$. The counit says: residuating an encoded $v$ recovers something no larger than $v$. Together they trap any round trip, and $A^\sharp$ gives the *tightest* such reconstruction. This is exactly the inequality underlying the solvability of min-plus linear systems $A \otimes x = b$: the system has a solution iff $A \otimes (A^\sharp b) = b$, in which case $A^\sharp b$ is the greatest solution. In shortest-path terms, $A^\sharp$ recovers the largest node potentials consistent with observed path costs.

### 5.4 The closure operator, tropically

The round trip $C = G \circ F = (A \otimes -) \circ A^\sharp$ is, by Theorem 3.6, a closure operator on $\overline{\mathbb{R}}^m$: its fixed points are exactly the observation vectors reconstructible without loss — the *stable* signals — which are precisely those $b$ for which $A \otimes x = b$ is solvable. Fidelity, in this setting, counts (over a finite discretized domain) how many signals survive the encode–decode round trip unchanged, and the perfect case is exactly reconstructibility of every signal.

---

## 6. Algorithms

We summarize the core computational procedures; full pseudocode and reference implementations accompany this work.

**(A) Verifying an adjunction.** Given finite posets $A, B$ (as order relations) and candidate maps $F, G$, check the biconditional $(\ast)$ for all pairs $(a, b)$. Complexity $O(\#A \cdot \#B)$ order comparisons. This certifies that a proposed pair of translations is a genuine analogy.

**(B) Computing the induced backward map.** Given $F$ on a finite lattice, compute $G(b) = \sup\{a : F(a) \le b\}$ for each $b$ by scanning the source and taking the join of qualifying elements. Complexity $O(\#A \cdot \#B)$ join operations. Returns the unique completing backward map (Theorem 3.7).

**(C) Fidelity.** Given an analogy, compute $C = G \circ F$ and count fixed points $\#\{a : C(a) = a\}$. Complexity $O(\#A)$ round-trip evaluations. Reports $\Phi(F, G)$ and flags perfection when $\Phi = \#A$.

**(D) Tropical residual and reconstruction.** Given $A \in \overline{\mathbb{R}}^{m\times n}$, form $A^\sharp$ by $(A^\sharp w)_j = \min_i(w_i - A_{ij})$; evaluate the reconstruction sandwich and test solvability of $A \otimes x = b$ via the equality $A \otimes (A^\sharp b) = b$. Complexity $O(mn)$ per matrix–vector residuation.

---

## 7. Applications

**Analogical reasoning and knowledge transfer.** Modeling two conceptual hierarchies as posets, an analogy is a validated forward/backward translation pair. Fidelity quantifies how much of one domain's structure transfers losslessly to the other, and the closure operator identifies the "analogically closed" concepts — the stable core on which the analogy is trustworthy.

**Data compression and reconstruction.** In the min-plus setting the forward map is a lossy encoder and the residual is the canonical decoder. The reconstruction inequalities certify that the decoder never fabricates detail, and fidelity counts exactly reconstructible signals — a principled figure of merit for lossy tropical codecs.

**Combinatorial optimization.** Residuation solves min-plus linear systems, which model shortest paths, project scheduling (critical path / PERT), and resource allocation. The adjoint viewpoint unifies "compute optimal costs" (forward) and "recover consistent potentials/dual certificates" (backward) as two halves of one analogy.

**Formal concept analysis.** Galois connections between objects and attributes generate concept lattices; our fidelity invariant and perfection criterion give quantitative tools for comparing conceptual scalings.

---

## 8. Discussion and future directions

The adjoint viewpoint turns a fuzzy cognitive notion into a rigid, computable one. Three consequences stand out: the backward half of an analogy is *forced*, not chosen; quality is a *countable* invariant with an attainable maximum; and the classical machinery of residuation is the tropical shadow of this general theory. We close with a program of conjectures extending the results.

**Conjecture 8.1 (Fidelity as a rank-type invariant).** For an analogy over a finite source, the fidelity equals the size of the image of the closure operator $G \circ F$, and this quantity is monotone under composition: the fidelity of a composite analogy never exceeds the smaller of the two component fidelities. The stable set is the "analogically stable" sublattice, so counting it measures the rank of the stabilized core, and rank can only drop under chaining.

**Conjecture 8.2 (Lipschitz-optimal reconstruction).** Among all backward maps paired with a fixed forward map, the adjoint backward map minimizes the worst-case reconstruction defect in the natural sup-metric; in the tropical setting this optimal defect is controlled by the spread of the matrix entries along each column. The residual is not merely *a* left inverse but the *tightest* over-approximation permitted by monotonicity, so any competitor pays a strictly larger error somewhere — and in min-plus that error is a difference of column extrema.

**Conjecture 8.3 (Perfect two-way analogies are isomorphisms of stable cores).** Every analogy restricts to a perfect two-way analogy — an order isomorphism — between the image of its source-side closure operator and the image of its target-side interior operator. Thus every analogy contains, canonically, a perfect analogy between its stable cores, and these cores are order-isomorphic.

Together these would establish fidelity as a compositional rank, the residual as a Lipschitz-optimal decoder, and a structure theorem exhibiting the perfect isomorphic core hidden inside every analogy.

---

## 9. Conclusion

We have defined analogy-making as an adjoint pair of order-preserving maps bound by a single balancing law, and shown that this definition alone forces a rich and useful theory: round trips are closure operators, backward maps are unique, and fidelity is a countable invariant maximized exactly by perfect analogies. In the tropical semiring the abstract best analogy becomes the concrete residual, and the general round-trip inequalities become the classical reconstruction sandwich of min-plus algebra. Analogy, long treated as an art, admits a precise algebra — and its best instances obey exact equations.
