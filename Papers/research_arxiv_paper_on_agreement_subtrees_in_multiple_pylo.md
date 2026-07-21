# Restriction Algebra, Overlap Gluing, and Quartet Transfer for Multiple Phylogenetic Trees

## Abstract

We develop a self-contained structural framework for agreement subtrees in finite families of unrooted phylogenetic trees. A tree is represented by a finite system of chosen edge-split sides, and restriction to a retained leaf set is modeled by intersection. This representation yields four principal results. First, restriction is functorial, so agreement is hereditary under leaf deletion. Second, common agreement for a nonempty family is equivalent both to agreement with one base tree and to pairwise agreement. Third, common restrictions glue across overlapping families and, inductively, across finite chains of overlapping families. Fourth, a restriction to $a$ leaves contains at most $2^a$ distinct split sides, giving a universal finite-state bound. We formulate agreement thresholds and prove their monotonicity, their exact one-tree base case, and the quartet-transfer principle: every bound forcing a common agreement subtree of size $n\ge4$ also forces a common quartet, with no quantitative loss. In particular, any fourfold iterated-exponential upper bound for the multiple-tree maximum-agreement-subtree problem transfers unchanged to the common-quartet threshold. The framework applies to arbitrary finite split systems; compatibility conditions specific to binary trees are needed only in the subsequent quantitative counting layer.

## 1. Introduction

Let several unrooted binary phylogenetic trees be defined on the same finite set of labelled leaves. Their global topologies may differ substantially, but after deleting enough leaves they may induce the same tree. The **multiple-tree maximum agreement subtree problem** asks how large a common induced subtree must occur. Its smallest nontrivial case concerns four leaves. An unrooted binary tree on four labels has one internal edge and therefore displays one of three resolved quartet types. For labels $a,b,c,d$, these types are

$$
ab\mid cd,\qquad ac\mid bd,\qquad ad\mid bc.
$$

For each number $k$ of trees, one may ask for the least ambient leaf number that forces a common quartet among every collection of $k$ trees. Quantitative work on this question naturally separates into two parts. The first is structural: define restriction, characterize agreement, glue local consensus, count unrestricted states, and transfer larger agreement guarantees to quartets. The second is genuinely phylogenetic: exploit compatibility among edge splits to derive sharp bounds and constructions.

This paper develops the first part. The central device is a split-system model. Deleting an edge of an unrooted tree partitions its leaf set into two sides. Choosing one side of each edge split represents the tree by a finite family of finite leaf sets. Restriction to a retained set is then intersection of each chosen side with that set. Although a full treatment of unrooted trees must account for the symmetry between the two sides and suppress degree-two vertices after pruning, the restriction identities studied here depend only on intersection. They therefore hold more generally for arbitrary finite split systems.

The resulting framework has three layers.

1. **Restriction algebra.** Repeated restriction composes by intersection. Agreement is an equivalence relation on restricted states and is inherited by every smaller leaf set.
2. **Connectivity and gluing.** A common state is equivalent to pairwise equality. Two coherent families sharing a member have the same witness, and consensus propagates along a finite chain of overlaps.
3. **Information and thresholds.** A restriction to $a$ labels uses at most $2^a$ split sides. Agreement thresholds are monotone in requested size, and every threshold for $n\ge4$ transfers unchanged to a quartet threshold.

The last principle is intentionally independent of the analytic form of a quantitative bound. If the ambient number is a fourfold iterate $f(f(f(f(x))))$, no additional iteration is incurred when passing from a larger common subtree to a quartet.

## 2. Split systems and restriction

### 2.1 Finite split systems

Let $X$ be a finite set of leaf labels. A **finite split system** on $X$ is a finite family $T$ of subsets of $X$. For a phylogenetic tree, the members of $T$ are consistently selected sides of edge-induced bipartitions. Our statements use only the set-theoretic structure of $T$, so no compatibility hypothesis is imposed unless explicitly stated.

Let $A\subseteq X$ be a retained leaf set.

**Definition 2.1 (Restriction).** The restriction of $T$ to $A$ is

$$
T\!\restriction_A=\{s\cap A:s\in T\}.
$$

Duplicate intersections are identified. Thus restriction is a finite family of subsets of $A$.

**Definition 2.2 (Agreement on a leaf set).** Two split systems $T$ and $U$ agree on $A$ if

$$
T\!\restriction_A=U\!\restriction_A.
$$

We write this relation conceptually as agreement on $A$; no additional witness is required.

**Definition 2.3 (Common agreement).** Let $I$ be a finite index set, let $F\subseteq I$ be a finite family of indices, and let $T_i$ be a split system for each $i\in I$. The indexed family has a common agreement subtree on $A$ if there is a split system $R$ such that

$$
T_i\!\restriction_A=R
$$

for every $i\in F$. The state $R$ is called a common restriction witness.

In the intended phylogenetic setting, this says that all trees indexed by $F$ induce the same split representation on the retained leaves.

### 2.2 Composition of restrictions

**Theorem 2.4 (Restriction composition).** For every finite split system $T$ and finite leaf sets $A$ and $B$,

$$
\bigl(T\!\restriction_A\bigr)\!\restriction_B
=T\!\restriction_{A\cap B}.
$$

**Proof sketch.** Every member of the left side has the form

$$
(s\cap A)\cap B=s\cap(A\cap B)
$$

for some $s\in T$, and every member of the right side arises in this way. Extensional equality of the two finite families follows. $\square$

**Corollary 2.5 (Nested restriction).** If $B\subseteq A$, then

$$
\bigl(T\!\restriction_A\bigr)\!\restriction_B=T\!\restriction_B.
$$

**Proof sketch.** Since $B\subseteq A$, one has $A\cap B=B$. Apply Theorem 2.4. $\square$

Two boundary cases are useful.

**Proposition 2.6 (Full and empty restrictions).** If every side $s\in T$ satisfies $s\subseteq A$, then $T\!\restriction_A=T$. Moreover,

$$
T\!\restriction_\varnothing=\begin{cases}
\varnothing,&T=\varnothing,\\
\{\varnothing\},&T\ne\varnothing.
\end{cases}
$$

**Proof sketch.** In the first claim, $s\cap A=s$ for every side. In the second, every side intersects the empty set in $\varnothing$; there are no resulting sides exactly when there were no input sides. $\square$

Restriction also respects union.

**Proposition 2.7 (Union law).** For split systems $T,U$ and a leaf set $A$,

$$
(T\cup U)\!\restriction_A
=(T\!\restriction_A)\cup(U\!\restriction_A).
$$

**Proof sketch.** A restricted side comes from $T\cup U$ exactly when its original side comes from $T$ or from $U$. Intersection with $A$ is applied identically in both cases. $\square$

The composition theorem expresses functoriality of leaf deletion: retaining $A$ and then retaining $B$ is equivalent to retaining only $A\cap B$ from the outset.

## 3. Structural characterizations of agreement

### 3.1 Agreement as an equivalence relation

For fixed $A$, agreement is equality of restricted systems. It is therefore reflexive, symmetric, and transitive.

**Proposition 3.1.** For any split systems $T,U,V$ and fixed leaf set $A$:

1. $T$ agrees with itself on $A$;
2. if $T$ agrees with $U$ on $A$, then $U$ agrees with $T$ on $A$;
3. if $T$ agrees with $U$ on $A$ and $U$ agrees with $V$ on $A$, then $T$ agrees with $V$ on $A$.

**Proof sketch.** These are respectively reflexivity, symmetry, and transitivity of equality applied to $T\!\restriction_A$, $U\!\restriction_A$, and $V\!\restriction_A$. $\square$

### 3.2 Heredity under leaf deletion

**Theorem 3.2 (Pairwise heredity).** If $T$ and $U$ agree on $A$ and $B\subseteq A$, then they agree on $B$.

**Proof sketch.** Restrict the equality $T\!\restriction_A=U\!\restriction_A$ to $B$. By Corollary 2.5, the two sides become $T\!\restriction_B$ and $U\!\restriction_B$. $\square$

**Theorem 3.3 (Common-agreement heredity).** If a finite family has a common agreement subtree on $A$ and $B\subseteq A$, then it has a common agreement subtree on $B$.

**Proof sketch.** Let $R$ witness common agreement on $A$. For every family member $T_i$,

$$
T_i\!\restriction_A=R.
$$

Restrict both sides to $B$. Nested restriction gives $T_i\!\restriction_B$, while the right side gives $R\!\restriction_B$. Thus $R\!\restriction_B$ is a common witness. $\square$

Heredity is the mechanism behind all threshold monotonicity below.

### 3.3 Base-tree and pairwise tests

**Theorem 3.4 (Base-tree characterization).** Let $F$ be a nonempty finite family of tree indices. The systems $(T_i)_{i\in F}$ have a common agreement subtree on $A$ if and only if there exists a base index $b\in F$ such that every $T_i$ with $i\in F$ agrees with $T_b$ on $A$.

**Proof sketch.** If $R$ is a common witness, then both $T_i\!\restriction_A$ and $T_b\!\restriction_A$ equal $R$. Conversely, if every restricted system equals the base restriction $T_b\!\restriction_A$, that base restriction is a common witness. Nonemptiness is used to select $b$. $\square$

**Theorem 3.5 (Pairwise characterization).** Let $F$ be nonempty. The family $(T_i)_{i\in F}$ has a common agreement subtree on $A$ if and only if every pair $i,j\in F$ agrees on $A$.

**Proof sketch.** A common witness makes every pair equal. Conversely, choose $b\in F$ and apply pairwise agreement to each pair $(i,b)$. Theorem 3.4 then gives a common witness. $\square$

This result has a direct algorithmic consequence. To test common agreement, one may compute one canonical restriction as a base state and compare each remaining restriction with it. This requires $|F|$ restrictions and $|F|-1$ equality tests rather than all $\binom{|F|}{2}$ pairwise tests.

## 4. Gluing agreement through overlaps

Local consensus need not globalize across disjoint families: two disjoint singleton families may have different restrictions. A shared member is sufficient to identify their witnesses.

**Theorem 4.1 (Two-family overlap gluing).** Let $F$ and $G$ be finite index families with $F\cap G\ne\varnothing$. Suppose $(T_i)_{i\in F}$ has common restriction $R$ on $A$, and $(T_i)_{i\in G}$ has common restriction $S$ on $A$. Then $R=S$, and the union family $(T_i)_{i\in F\cup G}$ has a common agreement subtree on $A$.

**Proof sketch.** Choose $c\in F\cap G$. Membership in $F$ gives $T_c\!\restriction_A=R$, while membership in $G$ gives $T_c\!\restriction_A=S$. Hence $R=S$. Every index in $F\cup G$ lies in one of the two families, so its restriction equals this common state. $\square$

**Corollary 4.2 (Cross-family agreement).** Under the hypotheses of Theorem 4.1, every $i\in F$ agrees on $A$ with every $j\in G$.

**Proof sketch.** Both restrictions equal the witness for $F\cup G$. $\square$

We now formulate the finite path version of connected gluing.

**Definition 4.3 (Overlap chain).** A finite list $F_1,\ldots,F_m$ of index families is an overlap chain if

$$
F_i\cap F_{i+1}\ne\varnothing
$$

for every $1\le i<m$. Empty and singleton lists satisfy this condition vacuously.

**Theorem 4.4 (Chain gluing).** Let $F_1,\ldots,F_m$ be an overlap chain. If every family $F_i$ has a common agreement subtree on the same leaf set $A$, then the union

$$
F_1\cup\cdots\cup F_m
$$

has a common agreement subtree on $A$.

**Proof sketch.** Induct on the length of the chain. The empty union is vacuously coherent, and the singleton case is immediate. For the induction step, glue $F_1$ to the union of the remaining chain. The consecutive overlap $F_1\cap F_2\ne\varnothing$ supplies an index belonging both to $F_1$ and to the tail union. Theorem 4.1 identifies the witness for $F_1$ with the witness supplied by the induction hypothesis. $\square$

The theorem is a local-to-global consistency principle. Witnesses behave as locally constant data on the path whose vertices are the families and whose edges mark nonempty intersections. The proof suggests a broader connected-overlap theorem: propagation should follow any spanning tree of a connected intersection graph.

## 5. A universal information bound

The restriction operation has a simple but useful counting property.

**Lemma 5.1 (Support lemma).** If $s\in T\!\restriction_A$, then $s\subseteq A$.

**Proof sketch.** By definition, $s=t\cap A$ for some $t\in T$, and every intersection with $A$ is a subset of $A$. $\square$

**Theorem 5.2 (Split-side information bound).** For every finite split system $T$ and finite leaf set $A$,

$$
\bigl|T\!\restriction_A\bigr|\le 2^{|A|}.
$$

**Proof sketch.** Lemma 5.1 embeds $T\!\restriction_A$ into the power set $\mathcal P(A)$. Since $|\mathcal P(A)|=2^{|A|}$, the claimed inequality follows. $\square$

**Corollary 5.3 (Crude state-space bound).** On a fixed $a$-element leaf set, the number of possible finite split systems is at most

$$
2^{2^a}.
$$

**Proof sketch.** A split system is a subset of $\mathcal P(A)$. The latter has $2^a$ elements, so its own power set has $2^{2^a}$ elements. $\square$

Corollary 5.3 is universal rather than phylogenetically sharp. Genuine tree splits satisfy pairwise compatibility, and binary trees display highly constrained collections of quartets. For $a=4$, arbitrary split systems number at most $2^{16}=65{,}536$, whereas resolved unrooted binary quartets have only three topological types. Thus compatibility-sensitive compression is the principal missing ingredient in turning the universal finite-state bound into a strong quantitative agreement theorem.

## 6. Agreement thresholds

We now isolate the extremal statements from the internal representation of any particular family.

**Definition 6.1 (Agreement threshold).** For natural numbers $N,k,n$, say that $N$ is an agreement threshold for $k$ systems and requested size $n$ if every indexed family

$$
T_1,\ldots,T_k
$$

of split systems on a common $N$-element leaf set has an $n$-element subset $A$ on which all $k$ restrictions agree.

The definition permits arbitrary finite split systems. When restricted to compatible split systems arising from unrooted binary phylogenetic trees, it is the natural threshold notion for the multiple-tree agreement-subtree problem.

### 6.1 Necessary ambient size

**Proposition 6.2 (Size necessity).** If $N$ is an agreement threshold for requested size $n$, then $n\le N$.

**Proof sketch.** Apply the threshold statement to any family, for example a family of empty split systems. It produces an $n$-element subset of an $N$-element ambient set. Such a subset can exist only if $n\le N$. $\square$

### 6.2 Exact one-tree case

**Theorem 6.3 (One-tree threshold).** For one tree on $N$ leaves, $N$ is an agreement threshold for requested size $n$ if and only if $n\le N$.

**Proof sketch.** Necessity is Proposition 6.2. For sufficiency, choose any $n$-element subset $A$ of the $N$ leaves. A one-member family has common witness $T_1\!\restriction_A$, so agreement is automatic. $\square$

This is the exact base case for all multiple-tree questions.

### 6.3 Monotonicity in requested size

**Theorem 6.4 (Threshold monotonicity).** If $N$ forces a common agreement subtree of size $n$ among every $k$-system family and $m\le n$, then $N$ also forces a common agreement subtree of size $m$.

**Proof sketch.** Given a family, obtain an $n$-element agreement set $A$. Choose any $m$-element subset $B\subseteq A$. Common-agreement heredity, Theorem 3.3, shows that $B$ is an agreement set. $\square$

The theorem shows that forcing power increases as the requested agreement size decreases.

### 6.4 Quartet transfer

A **quartet agreement set** is simply a common agreement set of cardinality $4$. In the binary phylogenetic setting, the induced topology is one of the three resolved quartets.

**Theorem 6.5 (Quartet transfer).** Let $n\ge4$. If $N$ is an agreement threshold for $k$ systems and requested size $n$, then $N$ is an agreement threshold for $k$ systems and requested size $4$.

**Proof sketch.** This is Theorem 6.4 with $m=4$. Explicitly, for any $k$-system family choose an $n$-leaf common agreement set $A$, select a four-element subset $Q\subseteq A$, and invoke heredity to show that every restriction to $Q$ is equal. $\square$

The transfer is lossless: the ambient number $N$ does not change.

**Corollary 6.6 (Uniform transfer).** Suppose $B(k,n)$ has the property that, for every $k$ and every $n\ge4$, every $k$-tree family on $B(k,n)$ common leaves has an $n$-leaf common agreement subtree. Then, for every such $k,n$, the same number $B(k,n)$ forces a common quartet.

**Proof sketch.** Apply Theorem 6.5 pointwise to the threshold $B(k,n)$. $\square$

**Corollary 6.7 (Fourfold-iterate transfer).** Let $f:\mathbb N\to\mathbb N$ and $C:\mathbb N^2\to\mathbb N$, and define

$$
N(k,n)=f(f(f(f(C(k,n))))).
$$

If $N(k,n)$ forces an $n$-leaf common agreement subtree among every $k$-tree family and $n\ge4$, then $N(k,n)$ forces a common quartet among every such family.

**Proof sketch.** Theorem 6.5 depends only on the threshold property and $n\ge4$, not on the formula defining $N(k,n)$. Therefore the same fourfold iterate transfers unchanged. $\square$

This corollary isolates the logical passage from a four-times iterated-exponential upper bound for multiple-tree agreement to a bound of the same form for the common-quartet threshold. All quantitative difficulty lies in proving the antecedent common-subtree estimate.

## 7. Algorithms

### 7.1 Canonical restriction

Represent each split side and the retained leaf set by immutable sets. To compute $T\!\restriction_A$, intersect every side with $A$ and insert the result into a hash set, automatically removing duplicates.

If $r=|T|$ and each set operation examines at most $a=|A|$ retained labels, the running time is $O(ra)$ with ordinary hashed membership assumptions; bit-vector representations reduce intersection to $O(r\lceil a/w\rceil)$ machine-word operations, where $w$ is the word size. The output has at most $\min(r,2^a)$ sides by Theorem 5.2.

### 7.2 Common-agreement test

For a nonempty family $T_1,\ldots,T_k$, compute $R=T_1\!\restriction_A$ and compare it with $T_i\!\restriction_A$ for $2\le i\le k$. Theorem 3.4 proves correctness. If every input contains at most $r$ split sides, the total time is $O(kra)$ under the same set model, plus equality-comparison overhead. Canonical hashing makes comparison linear in the representation size or expected constant time after digest computation.

### 7.3 Chain-consensus propagation

Suppose local groups $F_1,\ldots,F_m$ each carry a claimed restriction witness and consecutive groups overlap. Verify each local witness against its members, verify one shared index for every consecutive pair, and merge the groups from left to right. Theorem 4.4 proves that the final witness applies to the entire union. With precomputed restrictions, verification is linear in the total incidence count $\sum_i|F_i|$ plus the cost of set equality.

### 7.4 Quartet extraction

Given an $n$-leaf common agreement set with $n\ge4$, select any four labels and restrict the common state once more. Theorem 6.5 proves correctness. Selection itself is $O(n)$ for a generic iterable and $O(1)$ when four labels can be indexed directly; restriction costs depend on the number of displayed sides.

## 8. Worked examples

### 8.1 Restriction composition

Let

$$
T=\bigl\{\{1,2,3\},\{2,4\},\{1,4,5\}\bigr\},
$$

with $A=\{1,2,4\}$ and $B=\{2,4,5\}$. Then

$$
T\!\restriction_A
=\bigl\{\{1,2\},\{2,4\},\{1,4\}\bigr\}.
$$

Restricting again to $B$ gives

$$
\bigl(T\!\restriction_A\bigr)\!\restriction_B
=\bigl\{\{2\},\{2,4\},\{4\}\bigr\}.
$$

Since $A\cap B=\{2,4\}$, direct restriction yields the same family:

$$
T\!\restriction_{A\cap B}
=\bigl\{\{2\},\{2,4\},\{4\}\bigr\}.
$$

### 8.2 Overlap gluing

Suppose $F_1=\{1,2\}$, $F_2=\{2,3\}$, and $F_3=\{3,4\}$. If trees $1$ and $2$ agree on $A$, trees $2$ and $3$ agree on $A$, and trees $3$ and $4$ agree on $A$, then all four trees agree on $A$. Tree $2$ identifies the first two local witnesses, and tree $3$ identifies the resulting witness with the third. The chain need not contain an index common to all three families.

### 8.3 Finite-state growth

For $a=0,1,2,3,4,5$, the split-side bounds $2^a$ are

$$
1,2,4,8,16,32,
$$

while the crude split-system state counts $2^{2^a}$ are

$$
2,4,16,256,65{,}536,4{,}294{,}967{,}296.
$$

This double-exponential growth explains why arbitrary powerset counting rapidly becomes expensive and why compatibility-sensitive encodings are essential.

## 9. Applications

The framework applies wherever multiple labelled tree estimates must be reconciled.

**Consensus phylogenetics.** Different genes, bootstrap samples, or inference methods may produce different trees on the same taxa. Base-tree comparison tests agreement on a proposed taxon set, while heredity guarantees that every smaller subset remains stable.

**Distributed analyses.** Separate laboratories may analyze overlapping collections of inferred trees. The overlap gluing theorem shows exactly when local agreement certificates can be combined: one shared tree identifies two witnesses, and a chain of shared trees propagates consensus globally.

**Ramsey-style bounds.** Quantitative arguments may force a large common induced tree through iterative signature refinement. Quartet transfer then converts that result to a common-quartet bound without repeating the quantitative argument.

**Information compression.** The power-set estimate is a universal benchmark. Any encoding specialized to compatible tree splits can be evaluated by how far it improves on $2^{2^a}$ possible arbitrary states.

## 10. Scope and limitations

The restriction algebra deliberately abstracts away from several features of phylogenetic trees. Arbitrary finite split systems need not satisfy split compatibility, may include trivial or repeated information before canonicalization, and may not encode a unique binary tree. Consequently, Theorem 5.2 is not a count of binary tree topologies. It bounds only the number of distinct subset-valued split sides surviving restriction.

Likewise, the fourfold-iterate theorem is a transfer principle, not an independent derivation of a fourfold iterated-exponential agreement bound. Its conclusion is conditional on a quantitative theorem that forces an $n$-leaf agreement subtree. This separation is useful: it proves that no extra asymptotic loss is introduced when passing to quartets, while making clear that compatible-tree combinatorics must supply the antecedent.

Finally, overlap is essential in Theorem 4.1. If $F$ and $G$ are disjoint, each may be internally coherent while carrying a different witness. Connectivity, rather than mere local agreement, is the mechanism of globalization.

## 11. Future research

A first direction is **compatibility-sensitive state compression**. Edge splits of a tree are pairwise compatible, whereas the crude state count treats every subset as an independent bit. Canonical quartet signatures may encode restricted trees using dramatically fewer states.

A second direction is **gluing over arbitrary connected overlap graphs**. Chain gluing proves the path case. A spanning-tree argument should extend it to any finite connected intersection graph, and a hypergraph formulation may clarify the exact obstruction when overlap connectivity fails.

A third direction is **four-round signature refinement**. One may seek an explicit recurrence in which successive refinement controls leaf placement, split compatibility, tree identity, and family identity. Once such a recurrence forces an $n$-leaf common subtree, Corollary 6.7 immediately transfers it to quartets.

A fourth direction is **quartet coding theory**. Each four-label set admits three resolved types, suggesting ternary signatures. Large families with no common quartet resemble codes with constrained coordinates, but overlapping quartets must satisfy global tree consistency. Determining the resulting packing rates may lead to exponential lower bounds for the quartet threshold.

## 12. Conclusion

Restriction by intersection provides a compact algebra for agreement subtrees. It composes exactly, distributes over unions, and makes agreement hereditary. For nonempty families, common agreement is equivalent to pairwise agreement and can be tested against one base tree. Local witnesses glue whenever families overlap, and consensus propagates along finite overlap chains. Every restriction to $a$ leaves contains at most $2^a$ split sides, supplying a universal information bound and a benchmark for sharper compatible-tree encodings.

At the extremal level, agreement thresholds cannot request more leaves than exist, are exact for one tree, and are monotone in requested size. Most importantly, every threshold forcing a common subtree on at least four leaves forces a common quartet at precisely the same ambient size. Thus any fourfold iterated-exponential multiple-tree agreement bound transfers without loss to the common-quartet problem. The structural and quantitative layers are thereby cleanly separated: restriction algebra handles consensus and transfer, while phylogenetic compatibility controls the eventual strength of the bound.