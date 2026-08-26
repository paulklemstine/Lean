# The Shape of Sameness

## How one three-word question — *which entries agree?* — builds a geometry counted by the Bell numbers

Take a list of five things. Maybe five coloured beads:

$$\text{red},\ \text{blue},\ \text{red},\ \text{green},\ \text{blue}.$$

Now forget the colours. Do not forget everything — keep exactly one fact: *which positions carry the same thing as which*. Position $1$ matches position $3$; position $2$ matches position $5$; position $4$ is alone. Write that down as a shorthand: replace each entry by the **first position where its value appeared**. Red first appeared at position $1$, blue at position $2$, green at position $4$, so our bead string collapses to

$$(1,\,2,\,1,\,4,\,2).$$

This little tuple is what we will call the **kernel pattern** of the list. It is a remarkably economical object: it throws away the colours entirely but keeps every fact about coincidences. And it turns out to be the hinge of three quite different-looking pieces of mathematics — a classification theorem about symmetry, a counting sequence that mathematicians have loved for three centuries, and the geometry of a famous family of hyperplanes in high-dimensional space.

This article is about how those three things are the same thing.

---

## Part I. A complete invariant

Here is the first observation, and it is the one everything rests on.

Suppose you took the original bead string and applied some universal recolouring: every red becomes purple, every blue becomes orange, every green becomes yellow — but crucially, *different colours must stay different*. The recoloured string is

$$\text{purple},\ \text{orange},\ \text{purple},\ \text{yellow},\ \text{orange},$$

and its kernel pattern is, of course, still $(1,2,1,4,2)$. The pattern cannot see the recolouring, because the recolouring did not create or destroy any coincidence.

Formally: let $x = (x_1,\dots,x_n)$ be a tuple with entries in a set $X$, and define its kernel pattern by

$$\operatorname{pat}(x)_i \;=\; \min\{\,j : x_j = x_i\,\}.$$

If $f : X \to Y$ is any injective map, then $\operatorname{pat}(f\circ x) = \operatorname{pat}(x)$. In particular, if $\sigma$ is a permutation of $X$ — a relabelling of the alphabet — the pattern is unchanged. The pattern is an **invariant** of the action of the symmetric group $\operatorname{Sym}(X)$ that acts on tuples by relabelling all entries simultaneously.

Invariants are cheap; *complete* invariants are the prize. An invariant tells you that two objects in the same orbit look alike. A complete invariant tells you the converse: if they look alike, they *are* in the same orbit. That is the first theorem.

> **Completeness Theorem.** Let $X$ be a finite set and let $x,y$ be $n$-tuples with entries in $X$. There exists a permutation $\sigma$ of $X$ with $\sigma \circ x = y$ **if and only if** $\operatorname{pat}(x) = \operatorname{pat}(y)$.

One direction we have already seen. The other direction is a genuinely constructive argument: if the patterns agree, the map "$x_i \mapsto y_i$" is well defined and injective on the set of values actually used by $x$, because $x_i = x_j$ exactly when $y_i = y_j$. That gives a bijection between the *used* values of $x$ and the used values of $y$. The two unused parts have the same size, since $X$ is finite and the used parts match up; pick any bijection between them, glue, and you have your permutation $\sigma$.

Notice how much that argument depends on finiteness, and on having the whole symmetric group available. Both dependencies are real. Shrink the group and the theorem dies: over the two-element alphabet $\{0,1\}$, the one-entry tuples $(0)$ and $(1)$ have the same pattern — namely $(1)$, since in a one-entry list the first occurrence of the only value is at position $1$ — yet if you are only allowed the identity permutation, no group element carries one to the other. Sameness of pattern is exactly sameness of orbit for the *full* symmetric group, and for nothing less.

There is a pleasing fixed-point characterisation lurking here. Which tuples $p$ are patterns? Exactly the ones that are their own pattern: $\operatorname{pat}(p) = p$. Equivalently, $p$ is a pattern precisely when $p_i \le i$ for every $i$ and $p_{p_i} = p_i$ — a tuple of "first representatives", weakly pointing backwards and stable under a second application. Applying $\operatorname{pat}$ twice is the same as applying it once; the pattern map is a canonical-form operator, a retraction of the space of tuples onto its own image.

One more consequence, small but structurally important: as soon as the alphabet has at least $n$ letters, the set of achievable patterns of $n$-tuples stops depending on the alphabet at all. With $n$ positions you can create at most $n$ distinct values, so a larger alphabet buys nothing. The theory **stabilises**.

---

## Part II. Counting: the Bell numbers appear

Once you know that patterns classify orbits, counting orbits becomes counting patterns. And counting patterns is a classical problem in disguise.

A kernel pattern is nothing more nor less than a way of splitting the positions $\{1,\dots,n\}$ into groups — a **set partition**. Positions $1$ and $3$ together, positions $2$ and $5$ together, position $4$ alone: that is the partition $\{\{1,3\},\{2,5\},\{4\}\}$, and the pattern $(1,2,1,4,2)$ is just the same data written by naming each group after its smallest member. The correspondence is a bijection: every partition gives a pattern, every pattern gives a partition, and the two constructions undo each other.

The number of set partitions of an $n$-element set is the $n$-th **Bell number** $B_n$. The sequence begins

$$1,\ 1,\ 2,\ 5,\ 15,\ 52,\ 203,\ 877,\ 4140,\ \dots$$

For $n=3$, the five partitions of $\{1,2,3\}$ are: everything separate; $\{1,2\}$ together; $\{1,3\}$ together; $\{2,3\}$ together; everything together. Five patterns, five orbits.

So the count of orbits, the count of patterns, and the Bell numbers are one sequence. But there are two ways to *prove* it, and they have very different characters.

The first is brute confirmation. For $n$ up to $5$ one can simply enumerate all $n^n$ candidate tuples, keep those that satisfy the fixed-point condition $\operatorname{pat}(p)=p$, and count: $1, 1, 2, 5, 15, 52$. That is an exhaustive check, and for $n=5$ it inspects $3125$ tuples. Reassuring, and completely finite — but it says nothing about $n = 6$.

The second is a recursion, and it is the real theorem.

> **Bell Counting Theorem.** For every $n$, the number of kernel patterns of $n$-tuples is the Bell number $B_n$; equivalently, the number of equivalence relations on an $n$-element set is $B_n$.

The proof is the classical "look at the block containing the last element" argument, run carefully. Given a partition of $\{1,\dots,n+1\}$, look at the block $S \cup \{n+1\}$ containing the final index, where $S \subseteq \{1,\dots,n\}$. Delete that whole block. What is left is an arbitrary partition of the complement of $S$ — and *arbitrary* is the crucial word: any partition of the complement can be re-attached, and the construction is reversible. So the total count over all $n+1$-element partitions is

$$B_{n+1} \;=\; \sum_{S\subseteq\{1,\dots,n\}} B_{\,n - |S|} \;=\; \sum_{i=0}^{n} \binom{n}{i} B_{n-i},$$

grouping the subsets $S$ by their size. That is exactly the defining recursion of the Bell numbers, so induction closes the argument.

The same delete-the-last-index technique, run one level finer, resolves the count by the number of groups. Write $S(n,k)$ for the number of partitions of $\{1,\dots,n\}$ into exactly $k$ nonempty blocks — the **Stirling numbers of the second kind**. Deleting the last index does one of two things: either that index was alone in its block, and we are left with a partition of $n$ elements into $k-1$ blocks; or it sat inside one of the $k$ existing blocks, and we are left with a partition of $n$ elements into $k$ blocks, together with a choice of which of the $k$ blocks the deleted index came from. That is the recursion

$$S(n+1,k+1) \;=\; (k+1)\,S(n,k+1) \;+\; S(n,k),$$

and it yields:

> **Refined Counting Theorem.** The number of kernel patterns of $n$-tuples using exactly $k$ distinct values is $S(n,k)$, and summing over $k$ recovers the identity $B_n = \sum_{k=0}^{n} S(n,k)$.

That last identity is worth pausing on. The Bell numbers and the Stirling numbers are each defined by a recursion of their own, and neither recursion mentions the other. The identity linking them is not formal bookkeeping; it is the statement that two different recursions are counting the same objects in two different ways. The kernel pattern is the object they are both counting.

---

## Part III. The same story, in geometry

Now change the picture entirely and put yourself in $\mathbb{R}^n$. Consider the family of hyperplanes

$$H_{ij} = \{v \in \mathbb{R}^n : v_i = v_j\}, \qquad 1 \le i < j \le n.$$

This is the **braid arrangement**, one of the most-studied objects in the theory of hyperplane arrangements. It is the reflection arrangement of the symmetric group: each $H_{ij}$ is the mirror of the transposition swapping coordinates $i$ and $j$.

An arrangement of hyperplanes cuts space into pieces, and it also generates a lattice of subspaces — the **flats**, obtained by intersecting subfamilies of the hyperplanes. What is a flat of the braid arrangement? Intersecting $H_{13}$ and $H_{25}$ inside $\mathbb{R}^5$ gives $\{v : v_1 = v_3,\ v_2 = v_5\}$: the set of vectors that are *constant on the blocks of a partition*. And every flat has this form, because the equations $v_i = v_j$ that hold on a flat are automatically transitive.

So a flat is a partition, and a partition is a kernel pattern, and now the whole of Part I comes for free. Given any tuple $x$ (with entries anywhere at all), define

$$L(x) \;=\; \{v \in \mathbb{R}^n : x_i = x_j \implies v_i = v_j\}.$$

> **Geometric Classification Theorem.** $L(x) = L(y)$ if and only if $\operatorname{pat}(x)=\operatorname{pat}(y)$. Moreover $L(x) \subseteq L(y)$ if and only if the partition of $y$ refines to the partition of $x$ — inclusion of flats is reverse refinement of kernels — and the dimension of $L(x)$ equals the number of blocks of $x$.

The dimension statement is a one-line matter once you see the coordinates: a vector constant on blocks is precisely a free choice of one real number per block, so $L(x) \cong \mathbb{R}^{\#\text{blocks}}$. The extreme cases sit at the two ends of the lattice: a tuple with all entries distinct imposes no equations and gives the whole space $\mathbb{R}^n$, while a constant tuple gives the line of constant vectors, of dimension $1$.

Combining with Part II:

> **The intersection lattice of the braid arrangement in $\mathbb{R}^n$ has exactly $B_n$ elements, of which $S(n,k)$ have dimension $k$.**

In $\mathbb{R}^5$: $52$ flats. One of dimension $1$ (the constant line), $15$ of dimension $2$, $25$ of dimension $3$, $10$ of dimension $4$, and $1$ of dimension $5$ (all of $\mathbb{R}^5$) — and indeed $1+15+25+10+1 = 52$.

---

## Part IV. Adding order: faces, chambers, and a second famous sequence

The kernel pattern remembers *which* coordinates agree. Deliberately, it forgets everything else — including the fact that real numbers come in an order. What happens if we remember the order too?

Given a real vector $v$, define its **ordered pattern** by

$$\operatorname{rank}(v)_i \;=\; \#\{\text{distinct values of } v \text{ that are} < v_i\}.$$

For $v = (3.1,\, 7.0,\, 3.1,\, -2.0,\, 7.0)$ the distinct values are $-2.0 < 3.1 < 7.0$, so $\operatorname{rank}(v) = (1,2,1,0,2)$: each coordinate is labelled by how many distinct values sit below it. This records the full weak order on the coordinates — every fact of the form $v_i < v_j$ and every fact of the form $v_i = v_j$ — and nothing more. It is invariant under any strictly increasing reparametrisation of the value line: rescale, translate, apply $\tanh$, and the ordered pattern does not move. Applying $\operatorname{pat}$ to $\operatorname{rank}(v)$ returns $\operatorname{pat}(v)$: the ordered pattern refines the unordered one, exactly as it should.

Geometrically, the ordered pattern is the invariant of the **face**. Where flats are the subspaces the arrangement generates, faces are the relatively open cones the arrangement carves out — the pieces you get by choosing, for each pair $i<j$, one of $v_i<v_j$, $v_i=v_j$, $v_i>v_j$ consistently. Define the face of $v$ as the set of all $w$ satisfying the same strict comparisons as $v$:

$$F(v) = \{w : v_i < v_j \iff w_i < w_j \text{ for all } i,j\}.$$

> **Face Classification Theorem.** $F(v) = F(w)$ if and only if $\operatorname{rank}(v) = \operatorname{rank}(w)$. Every face is convex, hence connected.

The top-dimensional faces are the **chambers**: the pieces of the complement of the arrangement, where no two coordinates are equal. A chamber is precisely the open cone

$$C_\sigma = \{v : v_{\sigma(1)} < v_{\sigma(2)} < \cdots < v_{\sigma(n)}\}$$

for a permutation $\sigma$, and distinct permutations give distinct chambers. They are pairwise disjoint, and together they cover exactly the injective vectors. Hence:

> **The braid arrangement in $\mathbb{R}^n$ has exactly $n!$ chambers.**

That is the classical, very satisfying reason the symmetric group has $n!$ elements when you look at it geometrically: its reflection arrangement has one chamber per element.

And now the counting of *all* faces. Here is the beautiful bookkeeping step:

> **Fibre Theorem.** A flat with $k$ blocks carries exactly $k!$ faces.

The reason is that a face lying over a given flat is the flat's partition *together with a linear ordering of its blocks*, and a $k$-element set has $k!$ linear orders. Summing over flats and grouping by block count gives the **Fubini formula**:

$$\#\{\text{faces}\} \;=\; \sum_{k=0}^{n} S(n,k)\, k!.$$

These are the **ordered Bell numbers**, also called the Fubini numbers:

$$1,\ 1,\ 3,\ 13,\ 75,\ 541,\ 4683,\ \dots$$

They count *weak orderings* of $n$ items — the number of ways a race with $n$ runners can finish if ties are allowed. In $\mathbb{R}^5$ the braid arrangement has $52$ flats, $120$ chambers, and $541$ faces. The three counts are locked together by two inequalities that fall straight out of the Fubini formula: the number of chambers $n! = S(n,n)\cdot n!$ is a single term of the sum, so chambers never outnumber faces; and each term $S(n,k)$ of the Bell sum is at most $S(n,k)\cdot k!$, so flats never outnumber faces either. Every chamber is a face; every flat carries at least one face.

---

## Why this is more than an accounting exercise

The pattern of the argument — and it is a pattern in the same sense as everything else here — is *coincidence structure first, everything else afterwards*. Three separate classification problems, in three separate parts of mathematics, turned out to have the same answer because they were secretly asking one question:

- **Algebra:** classify the orbits of the symmetric group acting on tuples by relabelling. Answer: the kernel patterns.
- **Combinatorics:** enumerate the set partitions of a finite set. Answer: the Bell numbers, refined by the Stirling numbers.
- **Geometry:** describe the intersection lattice and the face poset of the braid arrangement. Answer: the flats are the patterns (counted by $B_n$), the faces are the ordered patterns (counted by the ordered Bell numbers), the chambers are the total orders ($n!$ of them), and dimension is block count.

The pivot in each case is that "which entries agree" is the only datum that survives the relevant symmetry — permuting the alphabet, in the first case; sliding along a flat, in the second; deforming within a face, in the third. Whenever you find yourself asking a question that is blind to the identity of values but sensitive to their coincidences, this machinery applies verbatim.

That happens far more often than it sounds. Databases group rows by equal keys — set partitions. Clustering algorithms output partitions and are compared by partition-lattice metrics. Statistical models over exchangeable data — the Chinese restaurant process and its relatives — are literally probability distributions on the $B_n$ patterns, with the Bell recursion as their normalisation. Phylogenetics, coalescent theory, and the theory of exchangeable random partitions all live in this lattice. And in every one of these settings the flat's dimension — the number of blocks — is the number of free parameters left after the coincidences are imposed, which is exactly the geometric statement above.

There is also a lesson about *sharpness*. The completeness theorem is not a soft fact; it fails immediately if you shrink the group, and it needs the finiteness of the alphabet to build the missing bijection. The theory is exactly as strong as its hypotheses allow, and no stronger. That is what one wants from a classification theorem: not that it is true, but that you know precisely why it stops being true.

Finally, a remark about the two proofs of the Bell count. The exhaustive check for $n \le 5$ and the recursion for all $n$ are both valid, and they are not redundant: the finite check is a specification, the recursion is the theorem, and the agreement of the two at $1, 1, 2, 5, 15, 52$ is the sanity condition that says the recursion was set up right. Good mathematics usually has both — a hard-edged small case you can hold in your hand, and a general argument you can believe. The kernel pattern gives you a place to stand where both are visible at once.
