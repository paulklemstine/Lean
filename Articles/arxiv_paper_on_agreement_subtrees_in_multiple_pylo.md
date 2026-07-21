# When Many Evolutionary Trees Tell the Same Four-Leaf Story

## A local language for a global problem

An evolutionary tree is a compact record of ancestry. Its leaves are present-day species, genes, languages, or viral samples; its internal branches represent inferred divisions in their histories. Yet the same data can support many plausible trees. If several reconstructions disagree globally, what fragment of evolutionary history must they still share?

The smallest genuinely branching answer has four leaves. Choose four labels, say $a,b,c,d$. An unrooted binary tree on them has one internal edge, and that edge separates the leaves into two pairs. Thus there are three possible resolved **quartets**:

$$
ab\mid cd,\qquad ac\mid bd,\qquad ad\mid bc.
$$

A quartet is the atomic yes-or-no statement of unrooted phylogenetics: which two leaves belong together on one side of the central split? The multiple-tree agreement problem asks how large a common leaf set must be before every tree in a family induces exactly the same branching pattern there. Its quartet version asks an especially sharp Ramsey-type question: how many common labels force $k$ trees to agree on at least one four-label subset?

The key ideas can be developed without drawing a single tree. Instead, we translate trees into collections of cuts and then study what happens when leaves are deleted. This shift—from pictures to restriction algebra—reveals a clean structural core: restriction composes, agreement survives deletion, local witnesses glue through overlaps, and every restricted state carries a universal finite information bound.

## Trees as collections of cuts

Remove an edge from an unrooted tree. The leaves fall into two groups. This bipartition is called an **edge split**. If one consistently records one side of each split, a tree may be represented by a finite family $T$ of subsets of its label set. The results below actually hold for every finite split system, whether or not it comes from a binary tree.

For a retained leaf set $A$, define the restriction of $T$ to $A$ by intersecting every recorded split side with $A$:

$$
T\!\restriction_A=\{s\cap A:s\in T\}.
$$

Repeated subsets are discarded because this is a set of split sides, not a list. Two trees $T$ and $U$ **agree on $A$** when

$$
T\!\restriction_A=U\!\restriction_A.
$$

A family of trees has a **common agreement subtree on $A$** when all its members have one and the same restriction on $A$. In ordinary phylogenetic language, their induced trees on those labels coincide.

This definition captures the essential operation of pruning away unwanted leaves. Its first law is almost obvious, but enormously useful.

**Restriction Composition Theorem.** For any split system $T$ and leaf sets $A$ and $B$,

$$
\bigl(T\!\restriction_A\bigr)\!\restriction_B
=T\!\restriction_{A\cap B}.
$$

Indeed, each split side becomes $(s\cap A)\cap B=s\cap(A\cap B)$. If $B\subseteq A$, this simplifies to

$$
\bigl(T\!\restriction_A\bigr)\!\restriction_B=T\!\restriction_B.
$$

In words: pruning in stages gives the same answer as pruning once. Two boundary laws complete the basic picture. If every side of $T$ already lies in $A$, then $T\!\restriction_A=T$. Restriction to the empty set is empty when $T$ is empty and is the singleton family $\{\varnothing\}$ otherwise. Restriction also distributes over union:

$$
(T\cup U)\!\restriction_A=(T\!\restriction_A)\cup(U\!\restriction_A).
$$

These identities are immediate from intersection and provide useful checks for implementations. Restriction composition is the algebraic reason agreement is hereditary.

**Heredity Theorem.** If two trees agree on $A$, then they agree on every $B\subseteq A$. More generally, if an entire family has a common agreement subtree on $A$, it has a common agreement subtree on every subset $B\subseteq A$.

The proof is a one-line application of restriction composition. Restrict the common state on $A$ once more to $B$; every tree reaches the same result.

This matters in practice. A large shared evolutionary pattern contains many smaller shared patterns, and no fresh comparison is needed to certify them.

## Pairwise checks are enough

The definition of common agreement appears to require producing a separate common witness. There is a simpler test.

**Pairwise Characterization Theorem.** Let $F$ be a nonempty finite family of split systems. The family has a common agreement subtree on $A$ if and only if every pair of members of $F$ agrees on $A$.

One direction is immediate: if every restricted tree equals the same state $R$, then any two restricted trees equal each other. Conversely, choose any base tree in the nonempty family. Pairwise agreement says every other restriction equals the base restriction, which serves as $R$.

This converts a global consensus question into equality tests. For $k$ trees, at most $\binom{k}{2}$ pairwise comparisons suffice, and in fact comparison with one fixed base tree reduces this to $k-1$ tests. The theorem is elementary, but it exposes the right computational interface: compute restrictions, canonicalize them, and compare.

## Consensus travels through overlaps

Suppose one research group compares trees indexed by a set $F$, while another compares trees indexed by $G$. Both groups find consensus on the same leaf set $A$. Can their conclusions be combined?

Not always. If the groups have no tree in common, their consensus patterns might differ. But one shared tree changes everything.

**Overlap Gluing Theorem.** If $F\cap G$ is nonempty, the trees in $F$ have a common restriction on $A$, and the trees in $G$ have a common restriction on $A$, then all trees in $F\cup G$ have a common restriction on $A$.

To see why, call the two local consensus states $R$ and $S$. A tree belonging to both groups restricts to $R$ because it lies in $F$ and to $S$ because it lies in $G$. Hence $R=S$, so one witness works for the union.

The same hypotheses also imply a cross-family conclusion: every tree in $F$ agrees on $A$ with every tree in $G$, because both restrictions equal the glued witness. The idea propagates down a chain.

**Chain Gluing Theorem.** Consider a finite list of tree families $F_1,\ldots,F_m$. Suppose each $F_i$ has a common restriction on $A$ and every consecutive intersection $F_i\cap F_{i+1}$ is nonempty. Then every tree in $F_1\cup\cdots\cup F_m$ has the same restriction on $A$.

This is a discrete local-to-global principle. Consensus behaves like a label that cannot change while moving through connected overlaps. It resembles consistency propagation in distributed databases: teams need not all share the same record, but a chain of shared records synchronizes their conclusions.

## How much information can a restriction contain?

Every split side in $T\!\restriction_A$ is a subset of $A$. A set of $a=|A|$ elements has exactly $2^a$ subsets. Therefore:

**Finite Information Bound.** For every split system $T$ and finite retained set $A$,

$$
\bigl|T\!\restriction_A\bigr|\le 2^{|A|}.
$$

Consequently, because a restriction itself is some family of subsets of $A$, there are at most

$$
2^{2^{|A|}}
$$

possible unrestricted split-system states on $A$.

The first bound is established directly; the second is its immediate counting consequence. It is deliberately crude for genuine trees. Edge splits of a tree cannot be arbitrary: they satisfy strong compatibility conditions. Nonetheless, the powerset bound identifies a finite state space to which pigeonhole and Ramsey arguments can be applied. It also pinpoints where sharper phylogenetic estimates must enter: not in restriction itself, but in counting only compatible states.

For example, if $|A|=4$, the universal split-side bound is $2^4=16$, and the crude number of families of split sides is $2^{16}=65{,}536$. A resolved binary quartet has only three topological types. The enormous gap between $65{,}536$ arbitrary states and three genuine quartet topologies measures how much structural information compatibility contributes.

## From a large common subtree to a quartet

Now comes the bridge to the quartet threshold. Suppose a theorem guarantees that every $k$-tree family on $N$ common labels has a common agreement subtree on $n$ labels. If $n\ge4$, choose any four of those labels. Heredity says the trees still agree after the other $n-4$ labels are deleted.

**Quartet Transfer Theorem.** If $N$ labels always force a common agreement subtree of size $n$ among $k$ trees, and $n\ge4$, then the same $N$ labels always force a common agreement subtree of size $4$ among those $k$ trees.

This remains true regardless of the formula used for $N$. In particular, if a quantitative argument supplies a bound of the form

$$
f(f(f(f(B(k,n)))))
$$

for an $n$-leaf agreement subtree, then exactly that fourfold iterated bound also forces a quartet whenever $n\ge4$. The transfer introduces no extra exponential and no hidden loss.

More generally, threshold size is monotone: a bound forcing agreement on $n$ leaves also forces agreement on every $m\le n$. There is also an exact sanity check at the base of the theory.

**One-Tree Threshold Theorem.** For a single tree on $N$ leaves, agreement on $n$ leaves is guaranteed exactly when $n\le N$.

Necessity is simple: one cannot select more leaves than exist. Sufficiency is equally simple: choose any $n$ leaves; a lone tree automatically agrees with itself.

## What has—and has not—been reduced

These theorems separate the multiple-tree problem into layers. The restriction layer is exact and general. It tells us how induced states compose, when local consensus becomes global, how many arbitrary split sides can survive, and why every sufficiently large common subtree yields a quartet.

The difficult quantitative layer remains compatibility-sensitive. A fourfold iterated-exponential upper bound for multiple-tree agreement, once obtained by a phylogenetic counting or refinement argument, passes immediately to the quartet threshold by the Quartet Transfer Theorem. An exponential lower bound, by contrast, calls for large families whose quartet signatures avoid a shared coordinate—an error-correcting-code problem constrained by tree consistency.

That division of labor is valuable. It prevents the elementary threshold logic from becoming entangled with the hard combinatorics. It also suggests two broad programs: compress restricted trees by compatible quartet signatures rather than arbitrary subsets, and extend overlap gluing from chains to every connected overlap network.

The story began with many incompatible evolutionary pictures. Its structural conclusion is unexpectedly optimistic. Agreement need not be found all at once. It can be inherited by deletion, certified pairwise, carried across overlapping teams, and distilled from any larger common pattern down to four leaves. In the search for consensus among trees, the quartet is not merely the smallest interesting object. It is the durable atom of agreement.