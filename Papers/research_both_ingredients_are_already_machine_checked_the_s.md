# Vertex Amalgamation and the Independence Ratio: Closure, Defect, and the Sharp $1/7$ Barrier

**Author:** Aristotle
**Date:** 2026-08-19

## Abstract

We study how two families of graph invariants behave under *vertex amalgamation*
(also called the 1-sum, or clique-sum of order one), and under its $m$-fold
generalisation, the *star amalgam* in which $m$ parts are glued at a single
common cut vertex. We prove that colouring-type invariants amalgamate as a
maximum: $k$-colourability is preserved, and both the chromatic number and the
clique number of an amalgam equal the maximum of those of its parts, so that
the class of graphs satisfying $\chi = \omega$ is amalgam-closed. By contrast,
the independence ratio $i(G) = \alpha(G)/n$ is only *superadditive with a
defect*: independent sets of the parts glue with a loss of exactly $m-1$
vertices, the surplus copies of the cut vertex, yielding the sharp estimate
$i(G) \ge r - (m-1)(1-r)/n$ when every side has independence density at least
$r$.

Two exact results delimit the phenomenon. First, we give the complete equality
analysis of the classical pigeonhole bound $n \le k\,\alpha(G)$ for
$k$-colourable graphs: equality holds for a given proper $k$-colouring if and
only if every one of its colour classes is a maximum independent set, so that
$i(G) = 1/k$ is a *balancedness* statement rather than a metric accident.
Second, we show that the threshold property $i(G) \ge 1/4$ — enjoyed by every
$4$-colourable, in particular every planar, graph — is **not** closed under
vertex amalgamation: two copies of $K_8$ minus an edge, each with independence
ratio exactly $1/4$, amalgamate to a graph on $15$ vertices with independence
ratio $1/5$, attaining the defect bound with equality. The $m$-fold version of
this family has independence ratio $(m+1)/(7m+1)$, with the exact gap identity
$i(G) - 1/7 = 6/(7(7m+1))$.

Our main theorem shows this collapse has an absolute floor. **The $1/7$ Barrier
Theorem:** every star amalgam whose sides each contain at least two vertices and
each carry an independent set of relative density at least $1/4$ satisfies
$n \le 7\,\alpha(G)$, hence $i(G) \ge 1/7$; and $1/7$ is optimal. The proof is a
two-regime argument combining the defect bound (when all sides are large) with a
cut-free union bound (when some side is small). We conclude with the general
conjecture that the amalgamation floor of the threshold $i \ge r$ is exactly
$r/(2-r)$, and with a proposed structural characterisation of the largest
hereditary amalgam-closed subclass of $\{i \ge 1/4\}$.

**Keywords:** independence ratio, vertex amalgamation, clique-sum, chromatic
number, clique number, pigeonhole equality analysis, extremal graph theory.

---

## 1. Introduction

### 1.1 Two ways to certify a large independent set

Let $G$ be a finite simple graph on a vertex set $V$ with $n = |V|$ vertices.
A set $S \subseteq V$ is *independent* if no two of its vertices are adjacent;
$\alpha(G)$ denotes the maximum size of an independent set, and

$$i(G) \;=\; \frac{\alpha(G)}{n}$$

is the *independence ratio*. The independence ratio is one of the most heavily
used density parameters in combinatorics, and one of the cheapest ways to bound
it from below is via colouring. If $C : V \to \{1,\dots,k\}$ is a proper
$k$-colouring, each colour class $C^{-1}(c)$ is independent, and the classes
partition $V$; hence

$$n \;=\; \sum_{c=1}^{k} \bigl|C^{-1}(c)\bigr| \;\le\; k\,\alpha(G),
\qquad\text{so}\qquad i(G) \;\ge\; \frac1k. \tag{1.1}$$

Since planar graphs are $4$-colourable, every planar graph has $i(G) \ge 1/4$;
this is the classical *quarter bound*. Inequality (1.1) is sharp: complete
graphs, and more generally balanced complete multipartite graphs, attain it.

This yields two distinct-looking hypotheses one might impose on a class of
graphs:

* the **structural hypothesis** "$G$ is $k$-colourable"; and
* the **metric hypothesis** "$i(G) \ge 1/k$".

The first implies the second, and the second is strictly weaker: the disjoint
union of $K_5$ with an independent set of $95$ vertices has $i = 96/100$, far
above $1/4$, yet requires five colours. The purpose of this paper is to show that the two hypotheses behave
*completely differently* under a basic gluing operation, and to compute exactly
how far apart they are.

### 1.2 Amalgamation

**Definition 1.1 (1-sum).** Let $G$, $G_1$, $G_2$ be graphs on a common vertex
set $V$, let $A, B \subseteq V$ and $v \in V$. We say that $G$ is the **1-sum**
(vertex amalgamation) of $G_1$ and $G_2$ along the cut vertex $v$, with sides
$A$ and $B$, if:

1. $G = G_1 \cup G_2$ as edge sets;
2. every edge of $G_1$ has both endpoints in $A$, and every edge of $G_2$ has
   both endpoints in $B$;
3. $A \cap B = \{v\}$;
4. $A \cup B = V$.

**Definition 1.2 (star amalgam).** Let $H_i$ ($i \in I$, $I$ finite and
nonempty) be graphs on $V$, with sides $A_i \subseteq V$ and a common cut vertex
$v$. We say $G$ is the **star amalgam** of the family if $G = \bigcup_i H_i$,
every edge of $H_i$ lies inside $A_i$, $A_i \cap A_j = \{v\}$ for $i \ne j$,
$v \in A_i$ for all $i$, and $\bigcup_i A_i = V$.

A 1-sum is the case $|I| = 2$. We write $m = |I|$ and $N_i = |A_i|$. Conditions
3 and 4 are both load-bearing, as we note in Section 6.

The two conditions have an immediate consequence used throughout: **no edge of
$G$ joins a vertex of $A \setminus B$ to a vertex of $B \setminus A$**, because
every edge lies within one side. Equivalently, deleting $v$ disconnects the
sides from each other.

### 1.3 Results

Section 2 proves that colouring invariants amalgamate as a maximum
(Theorems 2.1–2.4). Section 3 gives the equality analysis of (1.1)
(Theorem 3.1) and its ratio form (Corollary 3.2). Section 4 isolates the
splitting identity (Lemma 4.1) and proves superadditivity with defect
(Theorem 4.3) and the resulting sharp ratio bound (Theorem 4.4). Section 5
gives the counterexample to closure of the quarter threshold (Theorem 5.2), the
$m$-fold family (Theorem 5.4), and the main theorem: the $1/7$ barrier
(Theorem 5.6) with its optimality (Theorem 5.7). Section 6 discusses
hypothesis-minimality and the conceptual reading; Section 7 lists algorithms;
Section 8 gives applications; Section 9 states future directions.

---

## 2. Colouring invariants amalgamate as a maximum

### 2.1 Closure of colourability

**Theorem 2.1 (1-sum closure of colourability).** *Let $G$ be the 1-sum of
$G_1$ and $G_2$ along $v$ with sides $A, B$. If $G_1$ and $G_2$ are both
$k$-colourable, then so is $G$.*

*Proof sketch.* Let $C_1$ and $C_2$ be proper $k$-colourings of $G_1$ and $G_2$
with colour set $\{1,\dots,k\}$, and let $\tau$ be the transposition of the two
colours $C_1(v)$ and $C_2(v)$ (the identity if they coincide). Define

$$C(x) \;=\; \begin{cases} C_1(x), & x \in A,\\ \tau\bigl(C_2(x)\bigr), & x \notin A.\end{cases}$$

Let $xy$ be an edge of $G$. If $xy \in G_1$, both endpoints lie in $A$ and
$C(x) = C_1(x) \ne C_1(y) = C(y)$. If $xy \in G_2$, both endpoints lie in $B$,
and $C_2(x) \ne C_2(y)$. Three cases remain. If neither endpoint lies in $A$,
then $C(x) = \tau(C_2(x)) \ne \tau(C_2(y)) = C(y)$ since $\tau$ is injective. If
both lie in $A$, then both lie in $A \cap B = \{v\}$, so $x = y = v$,
contradicting adjacency. If exactly one — say $x$ — lies in $A$, then
$x \in A \cap B = \{v\}$, so $x = v$ and $C(x) = C_1(v)$, while
$C(y) = \tau(C_2(y))$; but $\tau(t) = C_1(v)$ holds only for $t = C_2(v)$, and
$C_2(y) \neq C_2(v) = C_2(x)$ because $xy$ is an edge of $G_2$. Hence
$C(x) \ne C(y)$. $\square$

The delicate case is precisely the third, and it is where condition 3 of
Definition 1.1 is used: a single transposition can match the colourings at
*one* shared vertex, and no more. If the sides met in two vertices, two
simultaneous matches would be required and the construction would break — as it
must, since already for the 2-sum of two triangles along an edge the statement is
false in the corresponding form for larger overlaps.

The construction extends verbatim to star amalgams, one transposition per part.

**Theorem 2.2 (star closure of colourability).** *If every part of a star
amalgam is $k$-colourable, so is the amalgam.*

*Proof sketch.* Fix a reference index $i_0$ and colourings $C_i$ of the parts.
Every $x \ne v$ lies in a *unique* side $A_{\iota(x)}$ (uniqueness is exactly
$A_i \cap A_j = \{v\}$). Set $C(v) = C_{i_0}(v)$ and, for $x \ne v$,
$C(x) = \tau_{\iota(x)}\bigl(C_{\iota(x)}(x)\bigr)$, where $\tau_i$ transposes
$C_{i_0}(v)$ and $C_i(v)$. Any edge lies in a single part $H_i$; if it avoids
$v$, injectivity of $\tau_i$ applies, and if it meets $v$, the transposition
sends only $C_i(v)$ to $C_{i_0}(v)$. $\square$

### 2.2 The maximum formulas

**Theorem 2.3 (chromatic number of an amalgam).** *For a 1-sum,
$\chi(G) = \max(\chi(G_1), \chi(G_2))$; for a star amalgam,
$\chi(G) = \max_i \chi(H_i)$.*

*Proof sketch.* "$\ge$" is monotonicity: each part is a subgraph of $G$.
"$\le$": let $k$ be the maximum of the parts' chromatic numbers; every part is
$k$-colourable, so by Theorem 2.1 (resp. 2.2) so is $G$. $\square$

**Lemma 2.4 (cliques do not straddle a cut).** *If $S$ is a clique of a 1-sum,
then $S \subseteq A$ or $S \subseteq B$, and $S$ is then a clique of the
corresponding part. In a star amalgam, every clique lies inside a single side
$A_i$ and is a clique of $H_i$.*

*Proof sketch.* Suppose $S \not\subseteq A$ and $S \not\subseteq B$. Choose
$x \in S \setminus A$ and $y \in S \setminus B$. By condition 4, $x \in B$ and
$y \in A$, and $x \ne y$. Since $S$ is a clique, $xy$ is an edge, hence lies in
$G_1$ (forcing $x \in A$) or in $G_2$ (forcing $y \in B$) — a contradiction
either way. Once $S \subseteq A$, any edge of $S$ that came from $G_2$ would have
both endpoints in $A \cap B = \{v\}$, hence be a loop; so all edges of $S$ come
from $G_1$. The star case is the same argument applied to the side containing a
fixed non-cut vertex of $S$. $\square$

**Theorem 2.5 (clique number of an amalgam).**
*$\omega(G) = \max(\omega(G_1), \omega(G_2))$, and $\omega(G) = \max_i
\omega(H_i)$ in the star case.*

*Proof sketch.* "$\ge$" is monotonicity. "$\le$": take a maximum clique of $G$;
by Lemma 2.4 it is a clique of some part, hence of size at most that part's
clique number. $\square$

**Corollary 2.6 (weak perfection is amalgam-closed).** *If every part of a
(star) amalgam satisfies $\chi = \omega$, then so does the amalgam.*

*Proof.* Both sides of the desired identity are maxima of the same list of
numbers, by Theorems 2.3 and 2.5. $\square$

This corollary is the "equality analysis" of the pair of maximum formulas: closure
of the *class* $\{\chi = \omega\}$ is not an extra theorem but a formal
consequence of computing both invariants exactly.

---

## 3. The pigeonhole bound and exactly when it is tight

**Theorem 3.1 (equality analysis of $n \le k\,\alpha$).** *Let $G$ be a finite
graph and $C$ a proper colouring of $G$ with colour set of size $k$. Then*

$$n \;=\; k\,\alpha(G) \iff \bigl|C^{-1}(c)\bigr| = \alpha(G) \ \text{for every colour } c.$$

*Proof.* Each class $C^{-1}(c)$ is independent, so $|C^{-1}(c)| \le \alpha(G)$,
and $n = \sum_c |C^{-1}(c)|$ by fibre decomposition. ($\Leftarrow$) If all $k$
classes have exactly $\alpha(G)$ elements, the sum equals $k\,\alpha(G)$.
($\Rightarrow$) Suppose some class $c_0$ has $|C^{-1}(c_0)| < \alpha(G)$. Summing
the $k$ term-wise inequalities with one strict gives
$n = \sum_c |C^{-1}(c)| < k\,\alpha(G)$, contradicting equality. $\square$

**Corollary 3.2 (equality in the ratio bound).** *If $n > 0$ and $C$ is a proper
$k$-colouring of $G$, then $i(G) = 1/k$ if and only if every colour class of $C$
is a maximum independent set of $G$.*

*Proof.* Clear denominators: $i(G) = \alpha(G)/n = 1/k$ iff $n = k\,\alpha(G)$;
apply Theorem 3.1. Note that $k > 0$ automatically, since a graph with a vertex
admits no colouring with an empty colour set. $\square$

Corollary 3.2 is the conceptual pivot of the paper. It converts the metric
statement "$G$ sits exactly on the threshold $1/k$" into the combinatorial
statement "*some* — equivalently, by the corollary applied to each colouring,
*every* — proper $k$-colouring of $G$ is perfectly balanced with all levels
maximum". Threshold graphs in this sense are rigid: they admit no slack anywhere.

**Examples.** $K_4$ with its unique $4$-colouring: four classes of size
$1 = \alpha$, and $i = 1/4$. The $4$-cycle with its bipartition: two classes of
size $2 = \alpha$, and $i = 1/2$. The path on three vertices with its
bipartition: classes of sizes $2$ and $1$; the second is not maximum, and indeed
$3 = n < k\alpha = 4$ and $i = 2/3 > 1/2$. Finally $K_8 - e$ with a
$7$-colouring: classes of sizes $2,1,1,1,1,1,1$, so $i = 1/4$ is *not* explained
by the pigeonhole at $k = 7$ — the graph is far above $1/7$.

---

## 4. Independence under amalgamation: the defect

Colourings glue because they are local certificates. Independent sets almost
glue; the obstruction is a single vertex, and this section quantifies it exactly.

**Lemma 4.1 (splitting identity).** *Let $G$ be a 1-sum with sides $A, B$ and
cut vertex $v$. Then for every set $S$ of vertices,*

$$|S| + [\,v \in S\,] \;=\; |S \cap A| + |S \cap B| ,$$

*where $[\,v \in S\,] \in \{0,1\}$ is the indicator of $v \in S$.*

*Proof.* By inclusion–exclusion, $|S \cap A| + |S \cap B| = |S \cap (A \cup B)| +
|S \cap A \cap B| = |S| + |S \cap \{v\}|$, using conditions 3 and 4. $\square$

Applying Lemma 4.1 with $S = V$ gives $n + 1 = N_1 + N_2$ for a 1-sum and, by
induction, the *covering identity* for a star amalgam:

$$n + (m-1) \;=\; \sum_{i=1}^{m} N_i. \tag{4.1}$$

**Lemma 4.2 (gluing independent sets).** *Let $G$ be a 1-sum. If $s_1 \subseteq
A$ is independent in $G_1$, $s_2 \subseteq B$ is independent in $G_2$, and
$v \in s_1 \iff v \in s_2$, then $s_1 \cup s_2$ is independent in $G$.*

*Proof sketch.* Let $x, y \in s_1 \cup s_2$ be distinct and adjacent in $G$. The
edge lies in $G_1$ or in $G_2$; say in $G_1$. Then $x, y \in A$. Any endpoint
lying in $s_2$ and in $A$ lies in $A \cap B = \{v\}$, hence equals $v$, hence
lies in $s_1$ by the hypothesis. So $x, y \in s_1$, contradicting independence.
The other case is symmetric. $\square$

**Theorem 4.3 (superadditivity with defect).** *Let $G$ be the star amalgam of
$m$ parts. If $s_i \subseteq A_i$ is independent in $H_i$ for each $i$, then*

$$\sum_{i=1}^{m} |s_i| \;\le\; \alpha(G) + (m-1).$$

*In particular, for a 1-sum, $|s_1| + |s_2| \le \alpha(G) + 1$. The defect
$m - 1$ is attained.*

*Proof sketch.* Two cases.

*(a) Every $s_i$ contains $v$.* Then $\bigcup_i s_i$ is independent in $G$ by the
$m$-fold form of Lemma 4.2; the sets $s_i \setminus \{v\}$ are pairwise disjoint
(a common element would lie in $A_i \cap A_j = \{v\}$), so
$\bigl|\bigcup_i s_i\bigr| = 1 + \sum_i (|s_i| - 1) = \sum_i |s_i| - (m-1)$, and
this is at most $\alpha(G)$.

*(b) Some $s_j$ avoids $v$.* Put $t_i = s_i \setminus \{v\}$. The $t_i$ are
pairwise disjoint, avoid $v$, live on distinct sides, and are jointly
independent (an edge between $t_i$ and $t_j$ would lie in some part $H_l$, whose
edges have both endpoints in $A_l$, forcing $i = l = j$ by uniqueness of sides
off the cut). Hence $\sum_i |t_i| \le \alpha(G)$. Each $|s_i| \le |t_i| + 1$, and
$|s_j| = |t_j|$, so $\sum_i |s_i| \le \sum_i |t_i| + (m-1) \le \alpha(G) + (m-1)$.
$\square$

The proof of case (b) already isolates the tool that will drive the main theorem:

**Lemma 4.4 (cut-free union bound).** *If $t_i \subseteq A_i$ is independent in
$H_i$ and $v \notin t_i$ for every $i$, then $\bigcup_i t_i$ is independent in
$G$ and the union is disjoint, so $\sum_i |t_i| \le \alpha(G)$ — with no defect
at all.*

Combining Theorem 4.3 with the covering identity (4.1) gives the sharp ratio
estimate.

**Theorem 4.5 (defect bound for the independence ratio).** *Let $G$ be a star
amalgam of $m$ parts on $n \ge 1$ vertices, and let $r \in \mathbb{Q}$. If each
side $A_i$ carries an independent set $s_i$ of $H_i$ with $|s_i| \ge r\,N_i$,
then*

$$i(G) \;\ge\; r - \frac{(m-1)(1-r)}{n}.$$

*In particular, for a 1-sum, $i(G) \ge r - (1-r)/n$.*

*Proof.* By hypothesis and (4.1),
$\sum_i |s_i| \ge r \sum_i N_i = r\bigl(n + (m-1)\bigr)$. By Theorem 4.3,
$\alpha(G) \ge \sum_i |s_i| - (m-1) \ge r n + r(m-1) - (m-1)
= rn - (m-1)(1-r)$. Divide by $n$. $\square$

Both the defect $m-1$ and the resulting ratio bound are attained; see
Theorems 5.2 and 5.4.

---

## 5. Failure of threshold closure and the $1/7$ barrier

### 5.1 The extremal building block

**Definition 5.1.** Let $K_8 - e$ denote the complete graph on eight vertices
$\{0,1,\dots,7\}$ with the single edge $\{0,1\}$ deleted.

Any two distinct non-adjacent vertices of $K_8 - e$ must be $0$ and $1$, so the
only independent set of size $2$ is $\{0,1\}$ and no independent set has three
vertices: $\alpha(K_8 - e) = 2$ and

$$i(K_8 - e) = \tfrac{2}{8} = \tfrac14 .$$

Note also that $K_8 - e$ contains $K_7$ (on $\{1,\dots,7\}$), so
$\chi(K_8 - e) = \omega(K_8 - e) = 7$; in particular it is *not*
$4$-colourable. This is forced: by Theorem 2.1 and the quarter bound, any
counterexample to closure of $\{i \ge 1/4\}$ must have a non-$4$-colourable
side.

### 5.2 The threshold $i \ge 1/4$ is not amalgam-closed

**Theorem 5.2 (failure of closure).** *There is a 1-sum $G$ whose two sides are
isomorphic copies of a graph with independence ratio exactly $1/4$, but with*

$$i(G) = \tfrac15 < \tfrac14 .$$

*Moreover $G$ attains the defect bound of Theorem 4.5 with equality:
$\tfrac15 = \tfrac14 - \tfrac{1 - 1/4}{15}$.*

*Proof sketch.* Take $V = \{0,1,\dots,14\}$. Let $G_1$ be the copy of $K_8 - e$
on $A = \{0,\dots,7\}$ with missing edge $\{0,1\}$, and let $G_2$ be the copy of
$K_8 - e$ on $B = \{0,8,9,\dots,14\}$ with missing edge $\{0,8\}$. Then
$A \cap B = \{0\}$, $A \cup B = V$, and $G = G_1 \cup G_2$ is a 1-sum along the
cut vertex $0$; both sides are isomorphic to $K_8 - e$, of ratio $1/4$.

*Upper bound $\alpha(G) \le 3$.* Let $S$ be independent. Inside $A$, any two
distinct elements of $S$ must be the non-adjacent pair $\{0,1\}$; hence
$|S \cap A| \le 2$, with $0 \in S$ whenever $|S \cap A| = 2$. Likewise
$|S \cap B| \le 2$, with $0 \in S$ whenever $|S \cap B| = 2$. By Lemma 4.1,
$|S| + [\,0 \in S\,] = |S \cap A| + |S \cap B| \le 4$. If $0 \in S$ the left side
is $|S| + 1$, giving $|S| \le 3$. If $0 \notin S$ then $|S \cap A| \le 1$ and
$|S \cap B| \le 1$, so $|S| \le 2$.

*Lower bound.* $\{0,1,8\}$ is independent: $0$ is non-adjacent to $1$ and to $8$
by construction, and $1$ and $8$ lie on opposite sides of the cut, hence are
non-adjacent.

So $\alpha(G) = 3$, $n = 15$, $i(G) = 1/5$. The numerical identity
$1/4 - (3/4)/15 = 1/4 - 1/20 = 1/5$ gives the equality claim. $\square$

**Corollary 5.3 (dichotomy).** *The class of $4$-colourable graphs is closed
under 1-sums (Theorem 2.1) and contained in $\{i \ge 1/4\}$, but
$\{i \ge 1/4\}$ itself is not closed under 1-sums. Consequently, whenever a
1-sum drops below $1/4$, at least one of its two sides fails to be
$4$-colourable.*

### 5.3 The $m$-fold family and the value $1/7$

**Definition 5.4.** For $m \ge 1$ let $\mathrm{St}_m$ be the star amalgam of $m$
copies of $K_8 - e$ glued at a common cut vertex, realised concretely on
$\{0,1,\dots,7m\}$: block $b$ ($0 \le b < m$) is $\{7b+1,\dots,7b+7\}$ and spans
a $K_7$; the cut vertex $0$ is joined to every block vertex except the first,
$7b+1$. Thus side $b$ (block $b$ together with $0$) is a copy of $K_8 - e$ with
missing edge $\{0, 7b+1\}$.

**Theorem 5.5 (the collapse to $1/7$).** *For every $m \ge 1$,*

$$\alpha(\mathrm{St}_m) = m+1, \qquad
  i(\mathrm{St}_m) = \frac{m+1}{7m+1}, \qquad
  i(\mathrm{St}_m) - \frac17 = \frac{6}{7(7m+1)} .$$

*Consequently $i(\mathrm{St}_m) \downarrow 1/7$ but never attains it;
$i(\mathrm{St}_m) < 1/4$ for all $m \ge 2$; and for every $\varepsilon>0$ there
is $m$ with $i(\mathrm{St}_m) < 1/7 + \varepsilon$. Moreover the $m$-fold defect
bound of Theorem 4.5 is attained with equality for every $m$:*

$$i(\mathrm{St}_m) \;=\; \frac14 - \frac{(m-1)\,(1 - 1/4)}{7m+1}.$$

*Proof sketch.* *Upper bound.* Let $S$ be independent. Each block spans a clique,
so $S$ meets each block in at most one vertex; the map sending a non-cut vertex
of $S$ to the index of its block is therefore injective on $S \setminus \{0\}$,
giving $|S \setminus \{0\}| \le m$ and $|S| \le m+1$.

*Lower bound.* The set $\{0\} \cup \{7b+1 : 0 \le b < m\}$ has $m+1$ elements and
is independent: the cut vertex is non-adjacent to each $7b+1$ by construction,
and two vertices $7a+1, 7b+1$ with $a \ne b$ lie in different blocks, hence in
different sides, hence are non-adjacent.

Since $n = 7m+1$, the closed form follows, and the two displayed identities are
elementary algebra:
$\frac{m+1}{7m+1} - \frac17 = \frac{7(m+1) - (7m+1)}{7(7m+1)} = \frac{6}{7(7m+1)}$,
and $\frac14 - \frac{3(m-1)}{4(7m+1)} = \frac{(7m+1) - 3(m-1)}{4(7m+1)}
= \frac{4m+4}{4(7m+1)} = \frac{m+1}{7m+1}$. $\square$

The gap identity says the deficiency below $1/7$ is exactly of order $1/n$: the
whole loss is carried by the single shared vertex.

### 5.4 The main theorem

**Theorem 5.6 (the $1/7$ Barrier Theorem).** *Let $G$ be a star amalgam of $m
\ge 1$ parts $H_i$ with sides $A_i$, $N_i = |A_i|$, on $n$ vertices. Suppose
that for every $i$:*

* *$N_i \ge 2$ (each side has a vertex besides the cut vertex); and*
* *$H_i$ has an independent set $s_i \subseteq A_i$ with $N_i \le 4|s_i|$
  (relative density at least $1/4$).*

*Then $n \le 7\,\alpha(G)$; equivalently $i(G) \ge 1/7$.*

*Proof.* Recall the covering identity (4.1): $n + (m-1) = \sum_i N_i$. We
distinguish two regimes.

**Regime 1: $N_i \ge 8$ for every $i$.** By Theorem 4.3,
$\sum_i |s_i| \le \alpha + (m-1)$ where $\alpha = \alpha(G)$. By the density
hypothesis, $\sum_i N_i \le 4\sum_i |s_i| \le 4\alpha + 4(m-1)$. By the regime
hypothesis, $\sum_i N_i \ge 8m$. Combining with (4.1):

$$n = \sum_i N_i - (m-1) \le 4\alpha + 3(m-1),
\qquad n = \sum_i N_i - (m-1) \ge 8m - m + 1 = 7m+1 .$$

The second inequality gives $m \le (n-1)/7$, hence
$3(m-1) \le 3(n-1)/7 - 3 < 3n/7$, and the first gives
$n < 4\alpha + 3n/7$, i.e. $4n/7 < 4\alpha$, i.e. $n < 7\alpha$ — strictly, so in
particular $n \le 7\alpha$. (When $m = 1$ the estimate degenerates harmlessly to
$n \le 4\alpha$.)

**Regime 2: $N_j \le 7$ for some $j$.** Here the defect bound is too lossy —
with many parts, the charge $m-1$ can exceed a small side entirely — so we use
the cut-free bound instead. For each $i$ define

$$t_i \;=\; \begin{cases} s_i \setminus \{v\}, & \text{if } s_i \setminus \{v\} \neq \emptyset,\\[2pt]
\{x_i\}, & \text{otherwise, where } x_i \in A_i \setminus \{v\} \text{ is arbitrary}.\end{cases}$$

The vertex $x_i$ exists because $N_i \ge 2$. In both cases $t_i \subseteq A_i$ is
independent in $H_i$, avoids $v$, and satisfies $|t_i| \ge 1$ and
$|s_i| \le |t_i| + 1$. By Lemma 4.4,

$$\sum_i |t_i| \;\le\; \alpha .$$

Pointwise, for every $i$,

$$N_i \;\le\; 4|s_i| \;\le\; 4|t_i| + 4 \;\le\; 7|t_i| + 1,$$

the last step because $|t_i| \ge 1$ implies $3|t_i| \ge 3$. For the small index
$j$ we do better: $N_j \le 7 \le 7|t_j|$, again because $|t_j| \ge 1$. Summing
the pointwise estimate over $i \ne j$ and the improved estimate at $j$:

$$\sum_i N_i \;\le\; 7\sum_i |t_i| + (m-1) \;\le\; 7\alpha + (m-1).$$

With (4.1), $n + (m-1) \le 7\alpha + (m-1)$, i.e. $n \le 7\alpha$. $\square$

**Theorem 5.7 (optimality).** *The constant $1/7$ in Theorem 5.6 cannot be
increased: the family $\mathrm{St}_m$ satisfies the hypotheses of Theorem 5.6
for every $m \ge 1$ (each side has $8 \ge 2$ vertices and carries the independent
pair $\{0, 7b+1\}$, so $N_i = 8 = 4\cdot 2$), and by Theorem 5.5,
$\inf_m i(\mathrm{St}_m) = 1/7$ while $i(\mathrm{St}_m) > 1/7$ for every $m$.*

Thus $1/7$ is the exact *amalgamation floor* of the quarter threshold: the
greatest constant $c$ such that every star amalgam of quarter-density parts has
$i \ge c$, and it is an infimum that is approached but not attained.

**Remark 5.8 (both hypotheses are needed).** Dropping the density hypothesis
destroys the conclusion: the star amalgam of five copies of $K_{12} - e$ has
$n = 56$ and $\alpha = 6$, so $i = 3/28 < 1/7$; its sides have density
$2/12 = 1/6 < 1/4$. Dropping $N_i \ge 2$ allows a side equal to $\{v\}$, for
which $t_i$ would be empty and the pointwise estimate of Regime 2 fails; it is
also the natural non-degeneracy requirement that each part genuinely contributes.

---

## 6. Discussion

### 6.1 Local certificates glue; global averages do not

The two halves of this paper can be summarised in one sentence: *amalgamation
acts as a maximum on colouring invariants and as a mediant-with-defect on the
independence ratio.*

Colourability is a **local certificate**: a function on vertices, whose validity
is checked edge by edge. Two certificates on two sides that overlap in a single
vertex can always be reconciled, because reconciling them is a one-point matching
problem, solvable by a transposition of the colour set. That is Theorem 2.1, and
it is why $\chi$, $\omega$, and the class $\{\chi = \omega\}$ all amalgamate
perfectly.

The independence ratio is a **global average**. Averaging two fractions is a
mediant operation, and the mediant of two copies of $1/4$ would be $1/4$ were it
not for the double-counted cut vertex. That defect — precisely one vertex per
seam, isolated by the splitting identity of Lemma 4.1 — is what pushes the
mediant strictly below the threshold. It is the entire content of the failure.

Corollary 3.2 explains why the failure is *unavoidable* for extremal inputs: a
graph on the threshold $i = 1/k$ has *every* colour class a maximum independent
set, so there is no slack anywhere to absorb the loss of one vertex. Extremal
inputs are exactly the ones that cannot afford the seam.

### 6.2 Minimality of hypotheses

The two conditions in Definition 1.1 are both load-bearing.

*The covering condition $A \cup B = V$* is needed for Lemma 2.4 and Lemma 4.1: a
vertex outside both sides would be isolated in $G$, hence joinable to every
independent set while belonging to no side, and the splitting identity would
fail by that vertex.

*The one-point overlap $A \cap B = \{v\}$* is needed for Theorem 2.1: with a
two-vertex overlap, matching the two colourings requires simultaneously aligning
two colours, which no single transposition delivers, and in general no
permutation need exist.

In Theorem 5.6, the hypothesis $N_i \ge 2$ is load-bearing (Remark 5.8), and the
density hypothesis is of course essential.

### 6.3 The shape of the constant

The number $7$ is not an artefact of the case split; it comes from an
optimisation. Fix a target density $r$ and consider a single side of size $N$
carrying an independent set of size $\lceil rN \rceil$. After deleting the cut
vertex, the side contributes about $rN - 1$ independent vertices out of $N - 1$
usable ones, an efficiency of

$$f(N) \;=\; \frac{rN - 1}{N - 1}.$$

The function $f$ is increasing in $N$ (for $r < 1$), so the worst case is the
*smallest admissible side*, namely the smallest $N$ with $rN \ge 2$, i.e.
$N = 2/r$, where

$$f(2/r) \;=\; \frac{2 - 1}{2/r - 1} \;=\; \frac{r}{2 - r}.$$

For $r = 1/4$ this is $1/7$, attained at $N = 8$: precisely $K_8 - e$. This is
the numerical fingerprint of the extremal family, and it is the source of
Conjecture 9.1 below.

---

## 7. Algorithms

The theory is fully constructive, and every quantity above can be computed or
certified.

**(A) Amalgam recolouring.** *Input:* proper $k$-colourings $C_i$ of the parts of
a star amalgam with sides $A_i$ and cut $v$. *Output:* a proper $k$-colouring of
the amalgam. *Method:* fix $i_0$; for each vertex $x \ne v$, locate its unique
side $A_{\iota(x)}$ and output $\tau_{\iota(x)}(C_{\iota(x)}(x))$, where $\tau_i$
transposes $C_{i_0}(v)$ and $C_i(v)$; output $C_{i_0}(v)$ for $v$. *Complexity:*
$O(n)$ after side lookup, i.e. linear. This is the algorithmic content of
Theorems 2.1–2.2 and gives $\chi$ of the amalgam in a single pass once the parts'
chromatic numbers are known.

**(B) Balancedness certificate for threshold membership.** *Input:* a graph with a
proper $k$-colouring $C$ and its independence number $\alpha$. *Output:* the
verdict $i(G) = 1/k$ or a witness colour class of size $< \alpha$. *Method:*
compute all class sizes; equality holds iff all equal $\alpha$ (Theorem 3.1).
*Complexity:* $O(n)$ given $\alpha$; the certificate of failure is a single
colour class.

**(C) Defect-bound evaluation.** *Input:* the sides $A_i$ and independent sets
$s_i$ of an amalgam. *Output:* the lower bound $r - (m-1)(1-r)/n$ with
$r = \min_i |s_i|/N_i$. *Complexity:* linear in the total size of the data. The
bound is tight exactly on the family $\mathrm{St}_m$.

**(D) Two-regime barrier certificate.** *Input:* a star amalgam meeting the
hypotheses of Theorem 5.6. *Output:* an explicit independent set of size at least
$n/7$. *Method:* if all $N_i \ge 8$, output the union produced by the defect
argument; otherwise build the sets $t_i$ (delete $v$; substitute a non-cut vertex
if empty) and output $\bigcup_i t_i$, which is independent by Lemma 4.4 and has
size at least $(n - (m-1) - (m-1))/7 \ge n/7$ by the pointwise estimates.
*Complexity:* linear in $n$ plus the cost of the per-side independent sets. This
turns the barrier from an existence statement into a construction.

Computing $\alpha$ itself is NP-hard in general; all statements above take the
per-side independent sets as *given*, which is exactly the situation in an
amalgamation where the parts are known.

---

## 8. Applications

**Tree decompositions and clique-sums.** Graphs of treewidth $1$ are built from
edges by 1-sums; more generally the structure theory of minor-closed classes
assembles graphs by clique-sums of small order. Our results say that any property
one hopes to propagate along such a decomposition must be certificate-like: the
chromatic and clique numbers propagate exactly (Theorems 2.3, 2.5), while density
thresholds degrade by a computable amount per seam (Theorem 4.5). The $1/7$
barrier quantifies the total degradation over an arbitrary number of seams at one
point.

**Independent sets in sparse and planar-like graphs.** The quarter bound for
planar graphs is inherited by any $4$-colourable graph; Theorem 2.1 shows the
class is stable under pinning, so bounds proved for pieces transfer. Conversely,
Theorem 5.2 warns against the tempting shortcut of assuming the *bound* rather
than the *colouring* when assembling.

**Perfect-graph-like classes.** Corollary 2.6 shows the identity $\chi = \omega$
is amalgam-closed, in keeping with the classical fact that clique-sums preserve
perfection; our proof derives it purely from the two maximum formulas, giving an
elementary route to the order-one case.

**Constraint satisfaction and distributed verification.** A colouring is a
locally checkable labelling; independence density is not. The dichotomy proved
here is a combinatorial instance of the general principle that only locally
checkable properties compose along thin interfaces.

---

## 9. Future directions

**Conjecture 9.1 (the amalgamation floor function).** *For $r \in (0,1]$, the
exact floor of the threshold $i \ge r$ under vertex amalgamation is
$r/(2-r)$.* Formally: if every side of a star amalgam $G$ carries an independent
set of relative density at least $r$ and has at least two vertices, then
$i(G) \ge r/(2-r)$; and for every $\varepsilon > 0$ some amalgam of parts of
density exactly $r$ has $i(G) < r/(2-r) + \varepsilon$. Specialising $r = 1/k$
predicts the floor $1/(2k-1)$, approached by amalgams of $K_{2k}$ minus an edge;
the case $k = 4$ is Theorem 5.6. The key insight is the efficiency computation of
Section 6.3: after deleting the cut vertex, a side of size $N$ contributes
$\lceil rN\rceil - 1$ independent vertices out of $N-1$, and
$N \mapsto (rN-1)/(N-1)$ is minimised at the smallest admissible side $N = 2/r$,
where it equals $r/(2-r)$. The extremal object is always "the smallest threshold
graph all of whose maximum independent sets pass through the cut". The argument
of Theorem 5.6 is uniform in $r$ except for two integer comparisons ($8 = 2/r$
and $7 = 2/r - 1$), so the general statement should be a parameterisation of the
existing induction rather than a new argument.

**Conjecture 9.2 (threshold repair).** *The largest hereditary, 1-sum-closed
subclass of $\{G : i(G) \ge 1/4\}$ is the class of fractionally
$4$-colourable graphs.* Formally: if a class $\mathcal{C} \subseteq
\{G : i(G) \ge 1/4\}$ is closed under 1-sums and under induced subgraphs, then
every $G \in \mathcal{C}$ has fractional chromatic number at most $4$. The key
insight is that closure under amalgamation forces a *local* certificate for the
ratio bound, and the only local certificate available is a (fractional)
colouring — exactly the dictionary "$i \ge 1/k$ versus $k$-colourability". The
forward half (colourability implies closure) is Theorem 2.1; the converse is
open.

**Further questions.**

* *Higher-order sums.* What is the analogue of the defect $m-1$ for clique-sums
  of order $t$? The splitting identity generalises to
  $|S| + (t-1)\,[\,\text{overlap terms}\,]$, and one expects a floor depending on
  both $r$ and $t$.
* *Attainment.* The floor $1/7$ is an infimum, not a minimum. Is there a natural
  compactification (weighted or fractional amalgams) in which it is attained?
* *Equality analysis for the barrier.* Theorem 3.1 characterises equality in the
  pigeonhole bound. What is the exact characterisation of star amalgams with
  $n = 7\alpha(G)$, and are all of them built from $K_8 - e$?
* *Algorithmic consequences.* Does the constructive certificate (D) extend to an
  approximation algorithm for independent sets in graphs given by a
  clique-sum decomposition with quarter-dense pieces?

---

## 10. Summary of results

| Statement | Content |
|---|---|
| Closure of colourability | $k$-colourability is preserved by 1-sums and star amalgams |
| Chromatic maximum formula | $\chi(G) = \max_i \chi(H_i)$ |
| Clique confinement | every clique of an amalgam lies in a single side |
| Clique maximum formula | $\omega(G) = \max_i \omega(H_i)$ |
| Weak perfection closure | $\chi = \omega$ is amalgam-closed |
| Splitting identity | $\lvert S\rvert + [\,v \in S\,] = \lvert S\cap A\rvert + \lvert S \cap B\rvert$ |
| Pigeonhole equality analysis | $n = k\alpha$ iff every colour class is maximum |
| Ratio equality analysis | $i(G) = 1/k$ iff the colouring is balanced with maximum classes |
| Superadditivity with defect | $\sum_i \lvert s_i\rvert \le \alpha(G) + (m-1)$ |
| Defect bound | $i(G) \ge r - (m-1)(1-r)/n$ |
| Failure of threshold closure | two copies of $K_8-e$ with $i=1/4$ glue to $i = 1/5$ |
| The $m$-fold family | $i(\mathrm{St}_m) = (m+1)/(7m+1)$, $\;i - 1/7 = 6/(7(7m+1))$ |
| The $1/7$ Barrier Theorem | quarter-dense sides force $n \le 7\alpha(G)$ |
| Optimality | $1/7$ is approached arbitrarily closely and never attained |
