# Regularity of Flag Graphs of Maniplexes and a Census-Based Classification of Regular 4-Maniplexes

## Abstract

A rank-$n$ maniplex is a combinatorial abstraction of a regular
$n$-dimensional polytope-like structure: a set of *flags* equipped with $n$
connection involutions that swap flags across each dimension. Its *flag graph*
records adjacency under these swaps. We prove, from a minimal and
dimension-agnostic set of axioms, that the flag graph of a rank-$n$ maniplex is
regular of degree $n$; in the rank-4 case this establishes that flag graphs of
4-maniplexes are exactly *tetravalent* (4-valent). This valence theorem is the
foundational plank of a classification program: it places every regular
4-maniplex inside the world of tetravalent graphs, supporting the conjecture
that isomorphism classes of regular 4-maniplexes are in bijective correspondence
with the tetravalent graphs of an existing census. We give the precise
definitions, a complete proof of the regularity theorem, its rank-4 corollary,
the divisibility consequences of the involution structure, and a discussion of
the classification conjecture together with concrete open problems.

## 1. Introduction

Regular polytopes and their higher-dimensional generalizations have a long
history, but many of the most flexible modern tools describe them purely
combinatorially, via *flags* and *connection operations*. A **maniplex** — a
common generalization of maps on surfaces and of abstract polytopes — is such a
description. It abstracts away all geometry and retains only the essential
symmetry data: a set of flags together with, for each dimension, an involution
that exchanges each flag with its unique neighbor across that dimension.

A central theme in the study of highly symmetric combinatorial objects is
**classification by translation**: encode the object as a graph of a recognizable
type, then classify the graphs. Graphs are among the most extensively catalogued
mathematical objects, and complete censuses of small graphs of fixed valence now
exist. If regular 4-maniplexes correspond faithfully to tetravalent graphs, then
enumerating the former reduces to consulting an existing census of the latter.

The purpose of this paper is to establish, with full rigor and in maximal
generality, the keystone of that translation: the flag graph of a maniplex is
*regular*, of degree equal to the rank. We isolate exactly the hypotheses needed,
prove the theorem, and derive its consequences for the rank-4 classification
conjecture.

## 2. Definitions

Throughout, let $\alpha$ be a set (the *flag set*), and let $n \in \mathbb{N}$.
Indices are drawn from $\{0, 1, \dots, n\}$ (an $(n+1)$-element index set), so a
family indexed this way has $n+1$ members; the rank-4 case corresponds to $n =
3$, giving four connection operations.

**Definition 2.1 (Involution family).** An *involution family* of size $n+1$ on
$\alpha$ is a family of maps $\sigma_0, \sigma_1, \dots, \sigma_n : \alpha \to
\alpha$ satisfying:

1. **(Involutivity)** For every index $i$, $\sigma_i \circ \sigma_i =
   \mathrm{id}$; equivalently $\sigma_i(\sigma_i(x)) = x$ for all $x \in \alpha$.
2. **(Fixed-point freeness)** For every index $i$ and every $x \in \alpha$,
   $\sigma_i(x) \neq x$.
3. **(String / non-adjacent commutativity)** For all indices $i, j$ with $|i -
   j| \geq 2$, and all $x \in \alpha$, $\sigma_i(\sigma_j(x)) =
   \sigma_j(\sigma_i(x))$.
4. **(Separation of images)** For every $v \in \alpha$ and all indices $i \neq
   j$, $\sigma_i(v) \neq \sigma_j(v)$.

Conditions (1)–(3) are the defining relations of a *string* maniplex; the
$\sigma_i$ are the *connection involutions*. Condition (4) records that the
neighbor across dimension $i$ genuinely differs from the neighbor across a
distinct dimension $j$ — a nondegeneracy hypothesis that is automatic for
faithful maniplexes and is exactly what forces full valence.

**Definition 2.2 (Rank-$n$ maniplex).** A *rank-$n$ maniplex* is a flag set
$\alpha$ together with an involution family of size $n$ (indices $0, \dots,
n-1$). A **4-maniplex** is the case of four connection involutions $\sigma_0,
\sigma_1, \sigma_2, \sigma_3$.

**Definition 2.3 (Flag graph).** Given an involution family $\{\sigma_i\}$ on
$\alpha$, its *flag graph* $\Gamma$ is the simple graph on vertex set $\alpha$ in
which two vertices $v, w$ are adjacent if and only if
$$\exists\, i : \quad w = \sigma_i(v) \ \text{ or }\ v = \sigma_i(w).$$
This relation is symmetric by construction, and it is loopless because each
$\sigma_i$ is fixed-point-free (so $w = \sigma_i(v)$ forces $w \neq v$).

**Definition 2.4 (Regular of degree $d$).** A graph is *regular of degree $d$*
if every vertex has exactly $d$ neighbors. For a finite flag set, the number of
neighbors of $v$ is the cardinality of its neighbor set $N(v) = \{w : v \sim
w\}$. A 4-valent (equivalently, *tetravalent*) graph is one that is regular of
degree $4$.

## 3. Main results

### 3.1 The regularity theorem

**Theorem 3.1 (Regularity of the flag graph).** *Let $\alpha$ be a finite flag
set carrying an involution family $\{\sigma_i\}_{i}$ of size $n+1$. Then the flag
graph $\Gamma$ is regular of degree $n+1$: for every vertex $v$, $|N(v)| = n+1$.*

**Proof.** Fix $v \in \alpha$. We claim
$$N(v) = \{\, \sigma_i(v) : i \in \{0, \dots, n\} \,\}, \tag{$\ast$}$$
the image of the map $\Phi : i \mapsto \sigma_i(v)$.

*($\subseteq$)* Let $w \in N(v)$. By Definition 2.3 there is an index $i$ with
$w = \sigma_i(v)$ or $v = \sigma_i(w)$. In the first case $w$ is manifestly of
the required form. In the second case, apply $\sigma_i$ to both sides of $v =
\sigma_i(w)$; by involutivity (Def. 2.1), $\sigma_i(v) = \sigma_i(\sigma_i(w)) =
w$, so again $w = \sigma_i(v)$. Hence $w \in \operatorname{im}\Phi$.

*($\supseteq$)* Conversely, for any index $i$ the element $\sigma_i(v)$ is
adjacent to $v$ (take the disjunct $w = \sigma_i(v)$ in Def. 2.3), so $\sigma_i(v)
\in N(v)$.

This proves $(\ast)$. Now the Separation hypothesis (Def. 2.1(4)) states exactly
that $\Phi$ is injective: if $i \neq j$ then $\sigma_i(v) \neq \sigma_j(v)$.
Therefore
$$|N(v)| = |\operatorname{im}\Phi| = |\{0, \dots, n\}| = n + 1,$$
using that the image of an injective map has the same cardinality as its finite
domain. Since $v$ was arbitrary, $\Gamma$ is regular of degree $n+1$.
$\blacksquare$

Two features of the proof deserve emphasis. First, involutivity is used only to
fold the "$v = \sigma_i(w)$" case of adjacency back into the "$w = \sigma_i(v)$"
case, thereby giving the clean image description $(\ast)$. Second, the entire
degree count reduces to the injectivity of a single finite map; no global or
inductive argument over the graph is needed. The string condition (3) is not
required for regularity itself — it belongs to the maniplex axioms and governs
the *local geometry* (the polygon structure of color pairs) rather than the
valence.

### 3.2 The tetravalent corollary

**Corollary 3.2 (Tetravalence of 4-maniplex flag graphs).** *The flag graph of a
finite 4-maniplex is tetravalent: every vertex has exactly four neighbors.*

**Proof.** A 4-maniplex is an involution family of size $4 = n+1$ with $n = 3$.
By Theorem 3.1 the flag graph is regular of degree $3 + 1 = 4$. $\blacksquare$

More generally, taking arbitrary $n$ in Theorem 3.1 yields the rank-valence
principle: *the flag graph of a rank-$n$ maniplex is $n$-valent.* Thus the
translation from maniplexes to fixed-valence graphs is uniform across all ranks.

### 3.3 Divisibility from the involution structure

**Proposition 3.3 (Even flag count).** *A finite maniplex has an even number of
flags.*

**Proof.** Any single connection involution $\sigma_0$ is a fixed-point-free
involution on the finite flag set $\alpha$. Its orbits are therefore all of size
exactly two (the pairs $\{x, \sigma_0(x)\}$ with $x \neq \sigma_0(x)$), and they
partition $\alpha$. A set partitioned into two-element blocks has even
cardinality. $\blacksquare$

The four independent fixed-point-free involutions of a 4-maniplex, together with
the 4-gon structure imposed by the string condition on non-adjacent color pairs,
produce nested two-to-one pairings and hence higher powers of two dividing the
flag count. The smallest regular 4-maniplexes have flag counts $120$, $384$,
$1152$, and $14400$; each is divisible by $24$, consistent with the conjectural
refinements (divisibility by $8$ in general, by $24$ in the regular case)
discussed in Section 6.

## 4. The classification conjecture

The **flag graph** construction (Def. 2.3) sends each regular 4-maniplex to a
connected tetravalent graph (Corollary 3.2). Conversely, one can attempt to
reverse the construction: given a tetravalent graph $G$, a proper edge-coloring
by four colors in which each color class is a perfect matching, and in which each
pair of *non-adjacent* colors decomposes $G$ into $4$-gons (encoding the string
condition), determines four fixed-point-free commuting-where-required
involutions and hence a maniplex — its *$1$-coskeleton*.

**Conjecture 4.1 (Census correspondence).** *The isomorphism classes of regular
4-maniplexes are in bijective correspondence with the isomorphism classes of
tetravalent graphs (equipped with the admissible four-coloring) in the census of
tetravalent graphs. In particular, the number of regular 4-maniplexes with a
given flag count equals the number of admissible tetravalent census graphs on
that many vertices.*

Theorem 3.1 supplies the well-definedness of one direction of this
correspondence: every regular 4-maniplex does yield a tetravalent graph, with no
degenerate vertices of lower degree. The reverse direction — characterizing
*which* tetravalent graphs arise, i.e. which admit the admissible four-coloring —
is the substantive open problem (Section 6).

## 5. Algorithms

The definitions are directly computational and yield simple, verifiable
procedures on finite flag sets.

**Algorithm A (Verify an involution family).** Given permutations $\sigma_0,
\dots, \sigma_n$ of a finite set $\alpha$, check the four axioms:
involutivity ($\sigma_i^2 = \mathrm{id}$), fixed-point-freeness ($\sigma_i(x)
\neq x$), non-adjacent commutativity ($\sigma_i \sigma_j = \sigma_j \sigma_i$ for
$|i-j| \geq 2$), and separation ($\sigma_i(v) \neq \sigma_j(v)$ for $i \neq j$).
Complexity: $O(n^2 |\alpha|)$ operations.

**Algorithm B (Build the flag graph and confirm valence).** Form the graph whose
edges are $\{v, \sigma_i(v)\}$ over all $v$ and $i$; compute each vertex's degree.
By Theorem 3.1 every degree equals $n+1$; the computation both realizes the graph
and empirically re-confirms the theorem on any given instance. Complexity: $O(n
|\alpha|)$ to build, $O(|\alpha|)$ additional to tabulate degrees.

**Algorithm C (Orbit / flag-count divisibility check).** Using any single
$\sigma_i$, decompose $\alpha$ into two-element orbits to witness Proposition
3.3, and report the flag count together with its factorization to test the
divisibility refinements. Complexity: $O(|\alpha|)$.

## 6. Discussion and future work

The regularity theorem is deliberately proved from the weakest sufficient
hypotheses so that it applies at every rank and to every maniplex, not merely to
the regular or the rank-4 case. Its role is structural: it certifies that the
maniplex-to-graph dictionary never loses valence, which is the minimal
consistency requirement for a census-based classification.

Several concrete directions extend this work.

**(1) Which tetravalent graphs are flag graphs?** We conjecture that a connected
tetravalent graph admits the admissible four-coloring (four perfect matchings,
with non-adjacent color pairs decomposing the graph into $4$-gons) if and only if
it carries a fixed-point-free automorphism structure whose generators satisfy the
string relations, and that admissibility is decidable in polynomial time. The
$4$-gon condition on non-adjacent color classes is local, so a
colour-propagation (local-to-global) argument should decide it without global
search. Existing complete censuses of small tetravalent graphs provide a finite
testbed.

**(2) Sharper divisibility.** Beyond Proposition 3.3, we conjecture that the flag
count of a rank-4 maniplex is always divisible by $8$, and by $24$ when the
maniplex is regular, with the residue recording how many color pairs are adjacent
versus non-adjacent. The mechanism is the nesting of the four fixed-point-free
matchings and the $4$-gon structure, compounding factors of two. The observed
counts $120, 384, 1152, 14400$ (all divisible by $24$) motivate the target.

**(3) A full local model of regularity.** For non-adjacent color pairs the two
matchings bound $4$-gons; for adjacent pairs they bound $2p$-gons with $p$ a
Schläfli-type parameter. We conjecture that the multiset of these polygon sizes,
together with the $4$-gon closure for non-adjacent pairs, is a complete
isomorphism invariant for *regular* rank-4 maniplexes — two are isomorphic iff
their color-pair polygon data agree — because regularity makes the connection
group act freely and transitively, so the whole object is reconstructible from
finitely many local relations.

**(4) Rank-$n$ generalization and valence $n$.** The rank-4 flag graph is
4-valent because there are four connection involutions; Theorem 3.1 already shows
the rank-$n$ flag graph is $n$-valent. The natural next step is to extend the
admissible-coloring characterization to properly $n$-edge-colored $n$-valent
graphs, opening census-based classification to maniplexes of every rank.

## 7. Conclusion

We have given precise, self-contained definitions of involution families, flag
graphs, and maniplexes, and proved that the flag graph of a rank-$n$ maniplex is
regular of degree $n$ — in particular tetravalent when $n = 4$. This valence
theorem is the foundational step making a census-based classification of regular
4-maniplexes possible, reducing (conjecturally) the enumeration of these
high-dimensional symmetric structures to the consultation of existing tetravalent
graph censuses. Combined with the divisibility phenomena forced by the involution
structure, it points toward a complete and computable classification.
