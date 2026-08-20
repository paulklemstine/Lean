# The Shape of Sameness

## What a word remembers when it forgets its letters

Look at the word **BANANA**. Now look at the word **LOLOLO**. They share no letters, they mean nothing alike, and yet something about them is the same. Write down, for each, only *which positions agree with which*:

- In BANANA, positions $1$ stands alone; positions $2,4,6$ agree; positions $3,5$ agree.
- In LOLOLO, positions $1,3,5$ agree; positions $2,4,6$ agree.

Not the same after all. Try **BANANA** against **SUSUSU**? No. Try **BANANA** against **XYZYZY**? Positions $2,4,6$ carry $Y$... no, $X,Y,Z,Y,Z,Y$ has $1$ alone, $2,4,6$ agreeing, $3,5$ agreeing. Yes: **BANANA** and **XYZYZY** have exactly the same *shape of sameness*.

This shape has a name. Given a finite list — a tuple $x = (x_1, \dots, x_n)$ with entries drawn from some alphabet $\alpha$ — its **kernel** (or **equality pattern**) is the relation
$$ i \sim_x j \iff x_i = x_j $$
on the index positions $\{1, \dots, n\}$. It is an equivalence relation: it is reflexive, symmetric and transitive for free, because equality is. It records everything about which slots repeat and nothing at all about *what* is in them.

This article is about a single, sharp claim: **the kernel is exactly the information that survives renaming**, and about the surprising amount of classical combinatorics that falls out once you take that claim seriously and make it computational.

## Renaming is the whole story

Suppose you have a machine that relabels letters: a bijection $\sigma$ of the alphabet with itself — a permutation. Feed it BANANA with the substitution $B \mapsto X$, $A \mapsto Y$, $N \mapsto Z$ and out comes XYZYZY. Obviously renaming can't change which positions agree, since a bijection sends equals to equals and unequals to unequals. So the kernel is an **invariant** of the renaming action.

The interesting direction is the converse. Is the kernel a *complete* invariant — does sameness of kernel force the two tuples to be renamings of one another?

**Completeness Theorem.** *Let $x$ and $y$ be $n$-tuples with entries in the same alphabet $\alpha$ (of any cardinality whatsoever, finite or infinite). Then $x$ and $y$ have the same kernel if and only if there exists a permutation $\sigma$ of $\alpha$ with $\sigma(x_i) = y_i$ for every $i$.*

The proof is the natural one, done carefully. Same kernel means the assignment $x_i \mapsto y_i$ is well defined (if $x_i = x_j$ then $y_i = y_j$) and injective (if $y_i = y_j$ then $x_i = x_j$) as a map between the two finite sets of values actually used. That is a bijection between two finite subsets of $\alpha$ of the same size. To promote it to a permutation of *all* of $\alpha$, you must match up the leftovers: the complements of the two value sets. When $\alpha$ is finite the complements have equal size, so any bijection between them will do. When $\alpha$ is infinite, removing a finite set doesn't change the cardinality — the complements are each of size $|\alpha|$ — so again a bijection exists. Glue and you have your $\sigma$.

Small example, infinite alphabet: over the natural numbers, $(0,0,1)$ and $(5,5,7)$ have the same kernel, so some permutation of $\mathbb{N}$ carries one to the other. It cannot be a "nice" formula, but it exists, and the theorem hands it to you.

So: **two lists are renamings of each other precisely when they repeat in the same places.** Everything below is an exploration of the consequences of taking that as a definition of "shape".

## Giving the shape a name you can compute with

An equivalence relation is a fine mathematical object, but a clumsy thing to store or to compare. The trick is to pick a *canonical representative* of each shape. For a tuple $x$, define
$$ \operatorname{can}(x)_i \;=\; \min\{\, j : x_j = x_i \,\}, $$
the earliest position carrying the same value. BANANA $\mapsto (1,2,3,2,3,2)$; XYZYZY $\mapsto (1,2,3,2,3,2)$; identical, as promised. Computer scientists know these strings under the name **restricted growth strings**; the process is exactly the "first-occurrence renaming" used to hash variable names or to normalise database queries up to renaming of constants.

Two facts make $\operatorname{can}$ the right object.

*It is a complete encoding.* Two tuples have the same kernel if and only if their canonical forms are literally equal, and $\operatorname{can}(f \circ x) = \operatorname{can}(x)$ for **any injection** $f$ of the alphabet into any other alphabet — not merely for permutations. So canonical form is a stable name for the shape, comparable across alphabets.

*Its image is describable.* Call a map $p: \{1,\dots,n\} \to \{1,\dots,n\}$ a **pattern** if
$$ p(i) \le i \quad\text{and}\quad p(p(i)) = p(i) \quad\text{for all } i. $$
That is: $p$ is *contracting* (it never points forward) and *idempotent* (its values are fixed points). These two little conditions are exactly the image of $\operatorname{can}$: every canonical form is a pattern, and every pattern is its own canonical form, $\operatorname{can}(p) = p$. So $\operatorname{can}$ is an idempotent retraction of the set of all tuples onto a small, explicitly checkable set of normal forms. Because the conditions are decidable inequalities, a computer can enumerate all patterns on $n$ letters by brute force — a fact we will cash in shortly.

## The count: Bell numbers

How many shapes are there?

**Classification Theorem.** *Patterns on $n$ letters are in canonical bijection with equivalence relations on an $n$-element set: a pattern $p$ goes to the relation $i \sim j \iff p(i) = p(j)$, and an equivalence relation goes to the canonical form of its own quotient map.*

Counting equivalence relations on a finite set is counting *set partitions*, and set partitions are counted by the **Bell numbers** $B_n$:
$$ B_0, B_1, B_2, B_3, B_4, B_5, \dots \;=\; 1,\, 1,\, 2,\, 5,\, 15,\, 52, \dots $$
This is one of the most famous integer sequences in mathematics (catalogued as A000110). The Bell numbers satisfy the binomial recurrence
$$ B_{n+1} \;=\; \sum_{k=0}^{n} \binom{n}{k} B_{n-k}, $$
which you prove by asking: how many of the other $n$ points share a block with a distinguished point? Choose those $k$ partners in $\binom{n}{k}$ ways, then partition the remaining $n-k$ points arbitrarily. Making that argument airtight is more delicate than it sounds — you have to exhibit the fibres of the "which points sit with the distinguished point" map as genuinely being the equivalence relations on the complement, gluing a subset and a relation back into a single relation and checking transitivity across all the cases — but it works, and it yields:

**Counting Theorem.** *There are exactly $B_n$ patterns on $n$ letters, hence exactly $B_n$ possible kernels of an $n$-tuple.*

And now the punchline that ties the invariant to the count:

**Orbit Theorem.** *If the alphabet $\alpha$ is finite with at least $n$ letters, then the group of all permutations of $\alpha$ has exactly $B_n$ orbits on the set of $n$-tuples over $\alpha$, and the complete invariant separating those orbits is the equality pattern.*

For instance the symmetric group on five letters has exactly $52$ orbits on the $5^5 = 3125$ quintuples over a five-letter alphabet. There is nothing to check about the group: $52$ is $B_5$, and every quintuple is nothing more than its shape.

Because patterns are defined by decidable conditions on a finite set of maps, the values $1, 1, 2, 5, 15, 52$ can be obtained by direct exhaustive computation over the finite set of patterns, and then transported back to the Bell numbers by the Classification Theorem — a rare instance where a famous sequence is verified by literally listing the objects it counts.

## Refining by the number of blocks: Stirling

A pattern has **blocks** — the classes of the relation, equivalently the fixed points of $p$, equivalently the distinct values of the original tuple. Sorting the $B_n$ patterns by their number of blocks refines the Bell count into the **Stirling numbers of the second kind** $S(n,k)$, defined by the recurrence
$$ S(n+1, k+1) = (k+1)\,S(n,k+1) + S(n,k), \qquad S(0,0)=1, $$
with $S(0,k+1) = S(n+1,0) = 0$.

**Refinement Theorem.** *The number of patterns on $n$ letters with exactly $k$ blocks is $S(n,k)$; consequently $\sum_{k=0}^{n} S(n,k) = B_n$.*

The proof is the "last letter" fibration and is genuinely pretty. Delete the last coordinate of a pattern on $n+1$ letters: you get a pattern on $n$ letters. Conversely, to extend a pattern $q$ on $n$ letters you must choose the value at the new last coordinate, and there are exactly two kinds of legal choice: either point at one of the existing block representatives of $q$ (joining an old block, block count unchanged — and if $q$ has $k+1$ blocks there are $k+1$ such choices), or point at the new coordinate itself (starting a fresh block, raising the count from $k$ to $k+1$, one choice). Count the fibre and the Stirling recurrence appears on the page. The row $n=5$ reads $0, 1, 15, 25, 10, 1$, and indeed $1 + 15 + 25 + 10 + 1 = 52$.

## When the alphabet runs out

The Orbit Theorem assumed the alphabet had at least $n$ letters. What if it doesn't? A three-letter word over a two-letter alphabet can never realise the shape "all three positions different". The general answer is exactly this obstruction and nothing more:

**Realisability Theorem.** *A pattern occurs as the pattern of some tuple over a finite alphabet $\alpha$ if and only if its number of blocks is at most $|\alpha|$.*

**General Orbit Theorem.** *For every finite alphabet $\alpha$ and every $n$, the permutation group of $\alpha$ has exactly*
$$ \sum_{k=0}^{|\alpha|} S(n,k) $$
*orbits on the $n$-tuples over $\alpha$ — a truncated Stirling row, with no relation assumed between $n$ and $|\alpha|$.*

Truncated rows can be summed in closed form for tiny alphabets, and the answers are charming.

**Binary alphabet.** Bit strings of length $n+1$ fall into exactly $2^{n}$ classes up to swapping $0$ and $1$. (Reason: $S(m,0)+S(m,1)+S(m,2) = 0 + 1 + (2^{m-1}-1) = 2^{m-1}$.) This is the classical count of "necklaces up to colour swap" for linear strings: half of the $2^{n+1}$ strings, as one would expect from a free involution — and the theorem proves it as a corollary of a partition-counting statement rather than by the parity argument.

**Ternary alphabet.** Strings of length $n+1$ over three letters fall into $(3^{n}+1)/2$ classes; the theorem is stated in the clean integral form $2 \cdot (\text{number of classes}) = 3^{n}+1$.

And from length $3$ onwards the binary count $2^{n-1}$ is *strictly* below the Bell number $B_n$: a two-letter alphabet is genuinely too poor to realise every shape. Concretely, the $3$-bit strings fall into $4$ classes, while $B_3 = 5$; the missing shape is "three distinct letters".

## A power identity for free

Here is the payoff that turns the classification into an algebraic identity. Fix a finite alphabet of size $a$. Every tuple over it factors *uniquely* as a shape plus an injective labelling of the shape's blocks by letters. So the tuples with a prescribed pattern $p$ with $k$ blocks are in bijection with the injections of a $k$-element set into an $a$-element set, of which there are the falling factorial $a^{\underline{k}} = a(a-1)\cdots(a-k+1)$ many. Summing over all patterns and grouping by block count:

**Connection Formula.** *For every $a$ and $n$,*
$$ a^{n} \;=\; \sum_{k=0}^{n} S(n,k)\, a^{\underline{k}}, \qquad a^{\underline{k}} = a(a-1)\cdots(a-k+1). $$

This is the classical change of basis between ordinary powers and falling factorials — usually proved by manipulating generating functions or by induction on the recurrence — obtained here as pure bookkeeping: *count the same finite set two ways*. It also explains the truncation phenomenon above without any extra work: when $k > a$, the falling factorial $a^{\underline{k}}$ is zero, so the terms beyond the alphabet size simply vanish. Check it at $a=3$, $n=4$: $81 = 0\cdot 1 + 1\cdot 3 + 7\cdot 6 + 6\cdot 6 + 1\cdot 0 = 3 + 42 + 36 = 81$. 

## Symmetric functions, counted

One last reformulation, for readers who like linear algebra. Fix a field $K$ and consider the $K$-valued functions $f$ of an $n$-tuple over an alphabet $\beta$ that are *invariant under relabelling*: $f(\sigma \circ x) = f(x)$ for every permutation $\sigma$ of $\beta$. These form a vector space. What is its dimension?

An invariant function is precisely a function on the orbit space, and a function on a finite set is a free choice of one value per point. Hence:

**Dimension Theorem.** *If $n \le |\beta| < \infty$, the space of relabelling-invariant $K$-valued functions of an $n$-tuple over $\beta$ has dimension exactly $B_n$.*

So "a symmetric function of $n$ arguments drawn from a large enough alphabet" is *nothing more* than a function of the equality pattern, and the Bell numbers measure how much such a function can possibly know. For $n = 5$ that is $52$ degrees of freedom, no matter how large the alphabet.

## Why this matters outside the page

The kernel of a tuple is one of those ideas that keeps being reinvented under different names because it is genuinely fundamental:

- **Databases.** Query answers must not depend on the names of constants; the shape of a tuple is exactly the part of it that a name-independent query can see. The truncated Stirling counts tell you how many distinguishable tuples exist over a bounded domain.
- **Programming languages.** Alpha-equivalence — the doctrine that bound variable names don't matter — is the kernel idea; canonical forms like de Bruijn indices are cousins of the restricted growth string.
- **Statistics and machine learning.** Permutation-invariant models over a set of tokens can only depend on which tokens coincide; the Dimension Theorem is a hard ceiling on the expressivity of such a model in terms of the Bell numbers.
- **Combinatorics of hashing and collision patterns.** The pattern of a list of hash values is its collision structure; the Connection Formula is the exact count of how many value-assignments realise each collision structure.

The moral, if there is one, is that the humblest question you can ask about a list — *which entries are equal?* — has a complete, computable answer, a canonical name, a classical count, and enough structure to reproduce the Bell numbers, the Stirling numbers, and the change of basis between powers and falling factorials, all from the single act of forgetting what the letters are called.

BANANA and XYZYZY, it turns out, know quite a lot.
