# A Constructive Bridge Between Plane Trees, Binary Trees, and Dyck Paths

## Abstract

We establish an explicit, fully constructive correspondence linking three classical combinatorial families: **plane trees** (ordered rooted trees of arbitrary arity), **binary trees**, and **Dyck lattice paths**. The central device is the left-child / right-sibling encoding (the Knuth transform), which we prove to be a genuine bijection between plane forests and binary trees, with an explicit two-sided inverse and with the crucial property that it preserves node count. Transporting known enumeration results along this bijection yields, in a uniform way, that plane forests with $n$ nodes, plane trees with $n+1$ nodes, binary trees with $n$ internal nodes, and Dyck paths of semilength $n$ are all counted by the Catalan number $C_n = \frac{1}{n+1}\binom{2n}{n}$, and that these families are pairwise equinumerous through explicit bijections. The headline result is a direct, size-graded bijection between plane trees with $n+1$ nodes and Dyck paths of semilength $n$. This correspondence is the base layer ($m=1$) of a broader program relating planar tree families to intervals of the Tamari lattice *via Dyck paths*, generalizing the planarity-based enumeration of Bousquet-Mélou–Chapoton to arbitrary $m$. We give complete definitions, statements, proof sketches, algorithms, numerical evidence, applications, and a detailed account of future directions.

**Keywords:** plane trees, ordered trees, binary trees, Dyck paths, Catalan numbers, Knuth transform, left-child/right-sibling encoding, bijective combinatorics, Tamari lattice, Fuss–Catalan numbers.

---

## 1. Introduction

The Catalan numbers
$$C_n = \frac{1}{n+1}\binom{2n}{n} = 1, 1, 2, 5, 14, 42, 132, \dots$$
count an enormous variety of combinatorial objects. Among the best known are binary trees with $n$ internal nodes, ordered (plane) rooted trees with $n+1$ nodes, and Dyck paths of semilength $n$. That these counts coincide can be verified by formula, but the more illuminating — and more useful — statement is that the families are related by *explicit bijections*, maps that translate one object into another with an inverse that recovers the original exactly.

This paper develops one such bridge in full detail, organized around a single structural map. We introduce plane trees and plane forests as first-class objects, define the left-child / right-sibling (Knuth) encoding from plane forests to binary trees, prove it to be a bijection by exhibiting a two-sided inverse, and prove that it preserves the natural size statistic (node count). From this one theorem, all the enumeration consequences follow by transport of structure, and the final plane-tree ↔ Dyck-path correspondence is obtained by composing bijections.

Our motivation is not merely to re-derive Catalan counts. The correspondence is the foundational $m=1$ layer of a research program concerning **greedy Tamari intervals** in planar $(m+1)$-constellations, where a conjectural enumeration relates such intervals to families of labeled planar trees, always mediated *by Dyck paths*. The bijection built here is the shared lattice-path substrate on which the higher, order-theoretic correspondences must rest. Section 7 lays out that road in detail.

### 1.1 Contributions

1. A self-contained development of **plane trees** and **plane forests**, with a node-counting statistic.
2. The **Knuth transform** $\Phi$ and its inverse $\Psi$, proved to be mutually inverse, hence a bijection between plane forests and binary trees (Theorem 3.1).
3. A proof that the transform **preserves node count** (Theorem 3.2), the key to graded enumeration.
4. A **global bijection** between plane trees and binary trees (Corollary 3.3).
5. Graded enumeration results: plane forests with $n$ nodes and plane trees with $n+1$ nodes are each counted by $C_n$ (Theorems 5.1, 5.2).
6. The **headline bijection** between plane trees with $n+1$ nodes and Dyck paths of semilength $n$ (Theorem 6.1), and the associated equinumerosity statements (Theorem 6.2).

---

## 2. Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$.

### 2.1 Plane trees and plane forests

**Definition 2.1 (Plane tree).** A *plane tree* (equivalently, an *ordered* or *planar rooted tree*) is a root node together with a finite ordered list of subtrees, each of which is itself a plane tree. We write a plane tree as $\mathsf{node}(t_1, t_2, \dots, t_k)$, where the list $(t_1, \dots, t_k)$ is the ordered list of *children*. The list may be empty, in which case the node is a leaf. Because the list is ordered, two plane trees that differ only in the order of some node's children are considered distinct.

**Definition 2.2 (Plane forest).** A *plane forest* is a finite ordered list $(t_1, \dots, t_k)$ of plane trees.

Note that a plane tree is precisely a single root wrapped around a plane forest: its children *are* a plane forest. This near-tautology is used repeatedly.

**Definition 2.3 (Node count).** The number of nodes of a plane tree is defined recursively by
$$\operatorname{numNodes}(\mathsf{node}(t_1, \dots, t_k)) = 1 + \sum_{i=1}^{k} \operatorname{numNodes}(t_i).$$
For a plane forest $f = (t_1, \dots, t_k)$, the total node count is
$$\operatorname{forestNodes}(f) = \sum_{i=1}^{k} \operatorname{numNodes}(t_i).$$
In particular $\operatorname{forestNodes}(\,) = 0$ for the empty forest, and if $t = \mathsf{node}(f)$ then $\operatorname{numNodes}(t) = 1 + \operatorname{forestNodes}(f)$.

### 2.2 Binary trees

**Definition 2.4 (Binary tree).** A *binary tree* is either empty (denoted $\mathsf{nil}$) or an internal node $\mathsf{bin}(l, r)$ with a left binary subtree $l$ and a right binary subtree $r$. The number of *internal nodes* is $0$ for $\mathsf{nil}$ and $1 + (\text{internal nodes of } l) + (\text{internal nodes of } r)$ for $\mathsf{bin}(l,r)$. We write $\mathcal{T}_n$ for the set of binary trees with exactly $n$ internal nodes.

### 2.3 Dyck paths

**Definition 2.5 (Dyck path).** A *Dyck path* of *semilength* $n$ is a sequence of $2n$ steps, each $+1$ (an up-step $U$) or $-1$ (a down-step $D$), such that every partial sum is nonnegative and the total sum is $0$. Equivalently, it is a balanced string of $n$ pairs of brackets. We write $\mathcal{D}_n$ for the set of Dyck paths of semilength $n$.

### 2.4 Catalan numbers

**Definition 2.6.** The Catalan numbers are $C_0 = 1$ and $C_{n+1} = \sum_{i=0}^{n} C_i\, C_{n-i}$; equivalently $C_n = \frac{1}{n+1}\binom{2n}{n}$.

---

## 3. The Knuth transform and its bijectivity

The engine of the paper is the left-child / right-sibling encoding, which converts a plane forest of arbitrary arity into a binary tree.

### 3.1 The encoding and decoding maps

**Definition 3.1 (Encoding $\Phi$).** Define $\Phi : \{\text{plane forests}\} \to \{\text{binary trees}\}$ recursively by
$$\Phi(\,) = \mathsf{nil}, \qquad \Phi\big(\mathsf{node}(g) :: r\big) = \mathsf{bin}\big(\Phi(g),\ \Phi(r)\big),$$
where $\mathsf{node}(g) :: r$ denotes a forest whose first tree is $\mathsf{node}(g)$ (with children forest $g$) and whose remaining trees form the forest $r$. In words: the children of the first tree become the left subtree; the rest of the forest becomes the right subtree.

**Definition 3.2 (Decoding $\Psi$).** Define $\Psi : \{\text{binary trees}\} \to \{\text{plane forests}\}$ recursively by
$$\Psi(\mathsf{nil}) = (\,), \qquad \Psi(\mathsf{bin}(l, r)) = \mathsf{node}(\Psi(l)) :: \Psi(r).$$

The map $\Psi$ reinterprets each internal binary node as a plane-tree node whose children are the decoding of the left subtree, followed by the decoding of the right subtree as the remaining forest.

### 3.2 Bijectivity

**Theorem 3.1 (Bridge 1: forests ↔ binary trees).** The maps $\Phi$ and $\Psi$ are mutually inverse. Hence $\Phi$ is a bijection between plane forests and binary trees, with inverse $\Psi$.

*Proof sketch.* We show $\Psi(\Phi(f)) = f$ for every forest $f$ and $\Phi(\Psi(t)) = t$ for every binary tree $t$, both by structural induction.

For the first identity: the empty forest satisfies $\Psi(\Phi(\,)) = \Psi(\mathsf{nil}) = (\,)$. For a nonempty forest $\mathsf{node}(g) :: r$,
$$\Psi(\Phi(\mathsf{node}(g) :: r)) = \Psi(\mathsf{bin}(\Phi(g), \Phi(r))) = \mathsf{node}(\Psi(\Phi(g))) :: \Psi(\Phi(r)) = \mathsf{node}(g) :: r,$$
using the inductive hypotheses on the strictly smaller forests $g$ and $r$.

For the second identity: $\Phi(\Psi(\mathsf{nil})) = \Phi(\,) = \mathsf{nil}$, and for an internal node,
$$\Phi(\Psi(\mathsf{bin}(l,r))) = \Phi(\mathsf{node}(\Psi(l)) :: \Psi(r)) = \mathsf{bin}(\Phi(\Psi(l)), \Phi(\Psi(r))) = \mathsf{bin}(l, r),$$
using the inductive hypotheses on $l$ and $r$. $\square$

### 3.3 Preservation of size

**Theorem 3.2 (Size preservation).** For every plane forest $f$, the binary tree $\Phi(f)$ has exactly $\operatorname{forestNodes}(f)$ internal nodes.

*Proof sketch.* Induction on $f$. The empty forest maps to $\mathsf{nil}$, which has $0$ internal nodes, matching $\operatorname{forestNodes}(\,) = 0$. For $\mathsf{node}(g) :: r$,
$$
\#\text{internal}\big(\Phi(\mathsf{node}(g) :: r)\big)
= 1 + \#\text{internal}(\Phi(g)) + \#\text{internal}(\Phi(r))
= 1 + \operatorname{forestNodes}(g) + \operatorname{forestNodes}(r),
$$
by the inductive hypothesis. On the other side,
$$\operatorname{forestNodes}(\mathsf{node}(g) :: r) = \operatorname{numNodes}(\mathsf{node}(g)) + \operatorname{forestNodes}(r) = \big(1 + \operatorname{forestNodes}(g)\big) + \operatorname{forestNodes}(r).$$
The two expressions coincide. $\square$

Theorem 3.2 is what upgrades the bijection from a mere set correspondence to a *graded* correspondence, allowing us to match objects size class by size class.

### 3.4 Plane trees versus forests

**Lemma 3.1 (Trees ↔ forests).** The map $t \mapsto (\text{children of } t)$ is a bijection between plane trees and plane forests, with inverse $f \mapsto \mathsf{node}(f)$. Under it, a plane tree $t$ with $\operatorname{numNodes}(t) = n+1$ corresponds to a forest with $\operatorname{forestNodes} = n$.

*Proof sketch.* A plane tree is $\mathsf{node}(f)$ for a unique forest $f$ (its children); the two maps are inverse by definition. The count statement is $\operatorname{numNodes}(\mathsf{node}(f)) = 1 + \operatorname{forestNodes}(f)$. $\square$

**Corollary 3.3 (Global bijection).** Composing Lemma 3.1 with Theorem 3.1 yields an explicit bijection between plane trees and binary trees.

---

## 4. Binary trees, Dyck paths, and Catalan numbers

We use two classical, well-established facts as external inputs.

**Fact 4.1 (Catalan enumeration of binary trees).** The number of binary trees with $n$ internal nodes is $C_n$; that is, $|\mathcal{T}_n| = C_n$.

**Fact 4.2 (Binary trees ↔ Dyck paths).** There is an explicit size-preserving bijection between binary trees with $n$ internal nodes and Dyck paths of semilength $n$. Consequently $|\mathcal{D}_n| = C_n$.

Fact 4.2 is realized concretely by a traversal that records each internal node as an up-step and reflects the recursive structure as a balanced bracketing; it is a standard component of the theory of Catalan structures. We treat both facts as known and transport them across the bridge of Section 3.

---

## 5. Enumeration of plane forests and plane trees

Combining the bijections above with the classical facts gives clean graded counts.

**Theorem 5.1 (Plane forests are Catalan).** For every $n \in \mathbb{N}$, the number of plane forests with exactly $n$ nodes equals $C_n$.

*Proof sketch.* By Theorem 3.2, $\Phi$ restricts to a bijection between $\{f : \operatorname{forestNodes}(f) = n\}$ and $\mathcal{T}_n$. By Fact 4.1, $|\mathcal{T}_n| = C_n$. $\square$

**Theorem 5.2 (Plane trees are Catalan).** For every $n \in \mathbb{N}$, the number of plane trees with exactly $n+1$ nodes equals $C_n$.

*Proof sketch.* By Lemma 3.1, plane trees with $n+1$ nodes correspond bijectively to plane forests with $n$ nodes; apply Theorem 5.1. $\square$

---

## 6. The headline bridge: plane trees ↔ Dyck paths

**Theorem 6.1 (Explicit plane-tree ↔ Dyck-path bijection).** For every $n \in \mathbb{N}$, there is an explicit bijection
$$\{\, t : \operatorname{numNodes}(t) = n+1 \,\} \;\longleftrightarrow\; \{\, p : \operatorname{semilength}(p) = n \,\}$$
between plane trees with $n+1$ nodes and Dyck paths of semilength $n$.

*Proof sketch.* Compose three bijections, each restricted to the appropriate size class:
$$
\{t : \operatorname{numNodes}(t) = n+1\}
\overset{\text{Lem. 3.1}}{\longleftrightarrow}
\{f : \operatorname{forestNodes}(f) = n\}
\overset{\text{Thm. 3.1, 3.2}}{\longleftrightarrow}
\mathcal{T}_n
\overset{\text{Fact 4.2}}{\longleftrightarrow}
\mathcal{D}_n.
$$
Each arrow is a bijection preserving the relevant size, so the composite is a bijection. $\square$

**Theorem 6.2 (Cross-domain enumeration).** For every $n \in \mathbb{N}$,
$$\#\{\text{plane trees with } n+1 \text{ nodes}\} = \#\{\text{Dyck paths of semilength } n\} = C_n,$$
and likewise
$$\#\{\text{plane forests with } n \text{ nodes}\} = \#\{\text{Dyck paths of semilength } n\} = C_n.$$

*Proof sketch.* Immediate from Theorems 5.1, 5.2 and Fact 4.2. $\square$

Thus a tree-combinatorial family (plane trees), a data-structure family (binary trees), and a lattice-path family (Dyck paths) are unified by explicit, invertible, size-preserving maps. The count $C_n$ is a consequence, not the mechanism: the dictionary itself is the proof.

---

## 7. Applications

### 7.1 Faithful representation of general trees

The left-child / right-sibling encoding is the standard technique for storing rooted trees of arbitrary and unbounded arity using a fixed two-pointer node layout: each node records only "first child" and "next sibling." Theorem 3.1 is the precise guarantee that this representation is *lossless and unambiguous*: distinct trees never collide, and every binary skeleton corresponds to a genuine tree. Theorem 3.2 further guarantees the representation is space-faithful, with one binary node per original node.

### 7.2 Uniform random generation and ranking

Because the maps are explicit and size-preserving, one can generate a uniformly random plane tree of a given size by generating a uniformly random binary tree (or Dyck path) of the corresponding size and decoding. Likewise, ranking/unranking schemes for one family transport immediately to the others.

### 7.3 A substrate for Tamari-lattice combinatorics

The correspondence is the $m=1$ base of a program relating families of planar trees to intervals of the Tamari lattice, always mediated by Dyck paths. Any bijective statement in that program "factors through" the shared Dyck-path layer established here.

---

## 8. Algorithms

We summarize the two core algorithms; full type-hinted implementations accompany this work.

**Algorithm A (Encode: plane forest → binary tree).** Given a forest as a list of plane trees, return the empty binary tree if the list is empty; otherwise take the first tree, recursively encode its children as the left subtree and the remaining forest as the right subtree, and return the resulting internal node. Runs in $O(n)$ time for a forest of $n$ nodes, one recursive step per node.

**Algorithm B (Decode: binary tree → plane forest).** Given a binary tree, return the empty forest if it is $\mathsf{nil}$; otherwise decode the left subtree into the children of a new plane-tree node, decode the right subtree into the remaining forest, and cons them. Runs in $O(n)$ time. Algorithms A and B are exact inverses (Theorem 3.1).

**Algorithm C (Catalan enumeration and cross-checking).** Compute $C_n$ by the convolution recurrence and independently by direct enumeration of each family (plane forests, binary trees, Dyck paths); verify all three counts agree, confirming Theorems 5.1, 5.2, 6.2 numerically.

---

## 9. Numerical evidence

Direct enumeration for small $n$ gives the following node/semilength-graded counts, all equal to $C_n$:

| $n$ | plane trees ($n{+}1$ nodes) | plane forests ($n$ nodes) | binary trees ($n$ int. nodes) | Dyck paths (semilength $n$) | $C_n$ |
|----:|----:|----:|----:|----:|----:|
| 0 | 1 | 1 | 1 | 1 | 1 |
| 1 | 1 | 1 | 1 | 1 | 1 |
| 2 | 2 | 2 | 2 | 2 | 2 |
| 3 | 5 | 5 | 5 | 5 | 5 |
| 4 | 14 | 14 | 14 | 14 | 14 |
| 5 | 42 | 42 | 42 | 42 | 42 |
| 6 | 132 | 132 | 132 | 132 | 132 |

In addition, the encode/decode round trip returns every enumerated object unchanged, and node counts are preserved under encoding, confirming Theorems 3.1 and 3.2 exhaustively over these ranges.

---

## 10. Discussion

The value of the development is threefold. Structurally, it exposes the Knuth transform as an honest bijection with a clean two-sided inverse, converting unbounded arity into rigid binary branching without loss. Enumeratively, it derives all Catalan counts by *transport of structure* from a single bijection, avoiding formula manipulation. Foundationally, it introduces plane trees and their statistics as reusable objects and pins down the plane-tree ↔ Dyck-path layer that higher Tamari-lattice results require.

---

## 11. Future directions

**Fuss–Catalan / $m$-ary layer.** Introduce full $(m+1)$-ary plane trees and $m$-Dyck paths (steps $+1$ and $-m$, staying nonnegative). Generalize the Knuth transform to an $(m+1)$-fold first-return decomposition and prove the count is the Fuss–Catalan number $\frac{1}{mn+1}\binom{(m+1)n}{n}$. This is the direct $m$-analogue and the cleanest extension; the main new ingredient is a Fuss–Catalan convolution recurrence, provable by induction on the number of internal nodes.

**Tamari order.** Formalize the Tamari partial order on Dyck words / binary trees via the right-rotation cover relation, and prove antisymmetry through a strictly monotone integer statistic. This is the missing order-theoretic infrastructure needed even to *state* "Tamari interval."

**Greedy / synchronized intervals.** Define greedy (synchronized) Tamari intervals and their maximal elements, then attempt the enumeration bridge to labeled planar trees. This is genuine research-level territory generalizing Bousquet-Mélou–Chapoton; the bijection here is the shared Dyck-path substrate on which such a correspondence would be built.

**Reusability.** Plane trees, their node count, and the Knuth transform are stated generically and are independently useful; they could seed a broadly reusable development of ordered-tree combinatorics.

---

## References (background, standard)

- E. Catalan and the classical theory of Catalan numbers (survey treatments in modern enumerative combinatorics texts).
- D. E. Knuth, *The Art of Computer Programming*, Vol. 1 — the left-child / right-sibling representation of trees.
- R. P. Stanley, *Catalan Numbers* — a compendium of Catalan objects and bijections.
- M. Bousquet-Mélou and F. Chapoton, planarity-based enumeration of Tamari intervals — motivating context for the generalization program.
