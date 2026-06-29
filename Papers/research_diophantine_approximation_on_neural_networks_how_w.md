# The Parity Theorem for Eulerian Trails on Finite Multigraphs

## Abstract

We present a self-contained, fully rigorous treatment of the classical parity
obstruction to Eulerian trails on finite multigraphs — the theorem underlying
Euler's 1736 resolution of the Königsberg bridge problem and, with it, the birth of
graph theory. Working with multigraphs encoded by an endpoint map
$\mathrm{ends}\colon \{0,\dots,n_E-1\} \to V \times V$ and with vertex degree
defined as the number of incident *edge endpoints* (so loops count twice), we prove
a sequence of five results. The cornerstone is a **double-counting identity**
(Theorem A) equating the degree of a vertex with a sum over the steps of an
Eulerian trail, followed by an **endpoint-correction identity** (Theorem B) which
exhibits the corrected degree as a manifestly even number. From these two
arithmetic facts the qualitative theory follows mechanically: interior vertices have
even degree (Theorem C), odd-degree vertices must be the trail's endpoints
(Theorem D), and hence a multigraph admitting an Eulerian trail has **at most two
odd-degree vertices** (Theorem E). We give complete proof sketches, an explicit
verification on the seven bridges of Königsberg, algorithmic consequences for route
inspection, and a discussion of applications ranging from genome assembly to
circuit testing. All definitions and theorems are stated inline; the paper is
self-contained.

**Keywords:** Eulerian trail, multigraph, degree parity, handshake lemma,
double counting, Königsberg bridges, route inspection.

---

## 1. Introduction

In 1736 Leonhard Euler proved that no walk through Königsberg could cross each of
the city's seven bridges exactly once. His argument inaugurated graph theory and
crystallized a style of reasoning — abstract to a combinatorial structure, then
exploit a conserved parity — that pervades modern mathematics and computer science.

The purpose of this paper is to isolate and prove, from first principles, the exact
arithmetic kernel of Euler's theorem: the parity constraint on vertex degrees
imposed by the existence of an Eulerian trail. We deliberately avoid invoking any
prior graph-theoretic machinery. Everything reduces to two counting identities and
the observation that an expression of the form $2k$ is even.

### 1.1 Contributions

1. A clean encoding of finite multigraphs and Eulerian trails suitable for
   completely formal reasoning (Section 2).
2. **Theorem A** (degree = walk-step count): a double-counting identity that
   re-expresses the static notion of degree in terms of the dynamics of a trail.
3. **Theorem B** (endpoint correction): a telescoping identity exhibiting
   $\deg(v) + (\text{endpoint indicators})$ as twice an integer.
4. **Theorems C–E**: the qualitative parity theory — even degree for interior
   vertices, endpoint-membership for odd vertices, and the bound of at most two
   odd-degree vertices.
5. A worked verification on Königsberg, algorithmic consequences, and applications
   (Sections 4–6).

---

## 2. Definitions

Throughout, $n_V$ and $n_E$ are natural numbers (the number of vertices and edges),
and we identify the vertex set with $\{0, 1, \dots, n_V - 1\}$ and the edge set with
$\{0, 1, \dots, n_E - 1\}$. We write $[\,P\,]$ for the **Iverson bracket**, equal to
$1$ when the proposition $P$ holds and $0$ otherwise.

### 2.1 Multigraphs

> **Definition 2.1 (Multigraph).** A *multigraph* on $n_V$ vertices and $n_E$ edges
> is a map
> $$ \mathrm{ends} \colon \{0,\dots,n_E-1\} \longrightarrow \{0,\dots,n_V-1\} \times \{0,\dots,n_V-1\}, $$
> assigning to each edge $e$ an *ordered* pair $\mathrm{ends}(e) = (\mathrm{ends}(e).1,\ \mathrm{ends}(e).2)$ of endpoints.

The ordering of the pair is a representational convenience only; it carries no
combinatorial meaning, and every result below is invariant under swapping the two
coordinates. **Multi-edges** (several edges with identical endpoint pairs) and
**loops** (edges $e$ with $\mathrm{ends}(e).1 = \mathrm{ends}(e).2$) are permitted.

> **Definition 2.2 (Degree).** The *degree* of a vertex $v$ in a multigraph $G$ is
> the number of edge endpoints equal to $v$:
> $$ \deg_G(v) \;=\; \sum_{e=0}^{n_E-1} \Big( [\,\mathrm{ends}(e).1 = v\,] + [\,\mathrm{ends}(e).2 = v\,] \Big). $$

Each edge contributes the sum of two indicators. An ordinary edge $\{u,w\}$ with
$u \neq w$ contributes $1$ to $\deg_G(u)$ and $1$ to $\deg_G(w)$; a **loop** at $v$
contributes $1 + 1 = 2$ to $\deg_G(v)$. Counting *endpoints* rather than *edges* is
the convention that makes the parity argument seamless, since it is endpoints, not
edges, that are consumed when a trail steps across a loop.

### 2.2 Eulerian trails

A trail that crosses each of the $n_E$ edges exactly once passes through a sequence
of $n_E + 1$ vertices. We index trail positions by $j \in \{0, 1, \dots, n_E\}$ and
trail *steps* by $i \in \{0, 1, \dots, n_E - 1\}$; step $i$ moves from position $i$
to position $i+1$.

> **Definition 2.3 (Eulerian trail).** An *Eulerian trail* of a multigraph $G$
> consists of:
> - a vertex sequence $\mathrm{walk} \colon \{0,1,\dots,n_E\} \to \{0,\dots,n_V-1\}$;
> - a permutation $\mathrm{edgeAt}$ of the edge set $\{0,\dots,n_E-1\}$;
>
> subject to the *compatibility condition*: for every step $i$,
> $$ \mathrm{ends}(\mathrm{edgeAt}(i)) = (\mathrm{walk}(i),\ \mathrm{walk}(i{+}1)) \quad\text{or}\quad \mathrm{ends}(\mathrm{edgeAt}(i)) = (\mathrm{walk}(i{+}1),\ \mathrm{walk}(i)). $$

Two features deserve emphasis.

- **The permutation enforces "each edge exactly once."** Because $\mathrm{edgeAt}$
  is a bijection of the edge set, every edge $e$ equals $\mathrm{edgeAt}(i)$ for
  precisely one step $i$. This is the formal content of an *Eulerian* (as opposed to
  arbitrary) trail.
- **Orientation-agnosticism.** The disjunction in the compatibility condition lets
  a trail cross an edge in either direction, as a physical walker would.

We write $\mathrm{start} = \mathrm{walk}(0)$ and $\mathrm{end} = \mathrm{walk}(n_E)$
for the first and last vertices of the trail.

### 2.4 Design choices and their consequences

Three modelling decisions deserve comment, because each is load-bearing for the
proofs that follow.

*Endpoints, not edges.* Degree counts incident endpoints. The alternative
— counting incident edges — would mishandle loops, which contribute two endpoints
but one edge. With the endpoint convention, a loop at $v$ adds $2$ to $\deg_G(v)$,
which is exactly what the trail dynamics demand: traversing a loop both arrives at
and departs from $v$, consuming two of its incidences. Any convention that broke
this symmetry would invalidate the endpoint-correction identity (Theorem B).

*Permutation, not surjection.* The requirement “every edge exactly once” is encoded
as a bijection $\mathrm{edgeAt}$ from step indices to edges. This is strictly
stronger than asking the steps to *cover* the edges, and strictly stronger than a
counting constraint, yet it is the cleanest hypothesis: it makes the
reindexing in Theorem A an exact, assumption-free change of summation variable. It
also transparently handles multi-edges — parallel edges are distinct elements of the
edge set and are permuted independently.

*Ordered endpoint pairs with an orientation disjunction.* Storing $\mathrm{ends}(e)$
as an ordered pair keeps the data type simple, while the disjunction in the
compatibility condition restores the physical reality that a walker may cross an
edge in either direction. Every theorem below is invariant under swapping the two
coordinates of any $\mathrm{ends}(e)$, so no genuine orientation is imposed.

Together these choices yield a model that is both faithful to the combinatorics of
physical walks and frictionless for arithmetic manipulation.

---

## 3. Main results

Fix a multigraph $G$ on $n_V$ vertices and $n_E$ edges and an Eulerian trail
$(\mathrm{walk}, \mathrm{edgeAt})$ of $G$.

### 3.1 The double-counting identity

> **Theorem A (Degree equals walk-step count).** For every vertex $v$,
> $$ \deg_G(v) \;=\; \sum_{i=0}^{n_E-1} \Big( [\,\mathrm{walk}(i) = v\,] + [\,\mathrm{walk}(i{+}1) = v\,] \Big). \tag{A} $$

*Proof sketch.* Start from Definition 2.2,
$\deg_G(v) = \sum_{e}\big([\mathrm{ends}(e).1=v]+[\mathrm{ends}(e).2=v]\big)$. Since
$\mathrm{edgeAt}$ is a permutation of the edge set, reindexing the sum along
$e = \mathrm{edgeAt}(i)$ leaves the total unchanged:
$$ \deg_G(v) = \sum_{i} \big([\,\mathrm{ends}(\mathrm{edgeAt}(i)).1 = v\,] + [\,\mathrm{ends}(\mathrm{edgeAt}(i)).2 = v\,]\big). $$
Now apply the compatibility condition step by step. In either branch of the
disjunction, the *unordered* pair of endpoints of $\mathrm{edgeAt}(i)$ equals the
unordered pair $\{\mathrm{walk}(i), \mathrm{walk}(i{+}1)\}$; hence the two-indicator
sum for that edge equals
$[\mathrm{walk}(i)=v] + [\mathrm{walk}(i{+}1)=v]$ regardless of which orientation
holds. Substituting term by term yields (A). $\qquad\blacksquare$

Theorem A is a textbook instance of **double counting**: the same quantity (the
number of incidences at $v$) is enumerated first by edges and then by trail steps.
The permutation is precisely the bijection that licenses the change of summation
index.

### 3.2 The endpoint-correction identity

> **Theorem B (Endpoint correction).** For every vertex $v$,
> $$ \deg_G(v) + \Big( [\,\mathrm{walk}(0) = v\,] + [\,\mathrm{walk}(n_E) = v\,] \Big) \;=\; 2 \sum_{j=0}^{n_E} [\,\mathrm{walk}(j) = v\,]. \tag{B} $$

*Proof sketch.* Let $N_v = \sum_{j=0}^{n_E} [\mathrm{walk}(j)=v]$ be the number of
trail positions equal to $v$. Split the step-sum in Theorem A into its two halves
and reindex each as a sum over positions:
$$ \sum_{i=0}^{n_E-1} [\mathrm{walk}(i)=v] = \sum_{j=0}^{n_E} [\mathrm{walk}(j)=v] - [\mathrm{walk}(n_E)=v] = N_v - [\mathrm{walk}(n_E)=v], $$
because the index $i$ ranges over positions $0,\dots,n_E-1$ — all positions except
the last. Symmetrically,
$$ \sum_{i=0}^{n_E-1} [\mathrm{walk}(i{+}1)=v] = \sum_{j=1}^{n_E} [\mathrm{walk}(j)=v] = N_v - [\mathrm{walk}(0)=v], $$
since $i+1$ ranges over positions $1,\dots,n_E$ — all positions except the first.
Adding the two displays and invoking Theorem A,
$$ \deg_G(v) = \big(N_v - [\mathrm{walk}(n_E)=v]\big) + \big(N_v - [\mathrm{walk}(0)=v]\big) = 2N_v - [\mathrm{walk}(0)=v] - [\mathrm{walk}(n_E)=v]. $$
Rearranging gives (B). $\qquad\blacksquare$

The right-hand side of (B) is $2N_v$, a manifestly even integer. The bracketed term
on the left is the *endpoint correction*: it equals $0$, $1$, or $2$ according to
whether $v$ coincides with neither, one, or both of the trail's two extremities.
This single equation contains the entire parity theory.

### 3.3 Parity of interior vertices

> **Theorem C (Interior vertices have even degree).** If $v \neq \mathrm{walk}(0)$
> and $v \neq \mathrm{walk}(n_E)$, then $\deg_G(v)$ is even.

*Proof sketch.* Under the hypothesis, both indicators
$[\mathrm{walk}(0)=v]$ and $[\mathrm{walk}(n_E)=v]$ vanish, so the correction term
in (B) is $0$. Identity (B) then reads $\deg_G(v) = 2N_v$, which is even.
$\qquad\blacksquare$

### 3.4 Odd vertices are endpoints

> **Theorem D (Odd-degree vertices are trail endpoints).** If $\deg_G(v)$ is odd,
> then $v = \mathrm{walk}(0)$ or $v = \mathrm{walk}(n_E)$.

*Proof sketch.* This is the contrapositive of Theorem C. If $v$ were neither
endpoint, Theorem C would force $\deg_G(v)$ even, contradicting oddness. Hence $v$
is one of the two endpoints. $\qquad\blacksquare$

Equivalently and directly from (B): since the right side $2N_v$ is even, the parity
of $\deg_G(v)$ equals the parity of the correction $[\mathrm{walk}(0)=v] +
[\mathrm{walk}(n_E)=v]$. For this correction to be odd it must equal $1$, which
requires $v$ to be exactly one of the endpoints.

### 3.5 The two-odd-vertex bound

> **Theorem E (At most two odd-degree vertices).** The number of vertices of odd
> degree is at most $2$:
> $$ \#\{\, v : \deg_G(v) \text{ is odd} \,\} \;\le\; 2. $$

*Proof sketch.* By Theorem D, every odd-degree vertex lies in the two-element set
$\{\mathrm{walk}(0),\ \mathrm{walk}(n_E)\}$. Hence the set of odd-degree vertices is
a subset of a set of cardinality at most $2$, and its cardinality is therefore at
most $2$. (If the start and end coincide — a closed trail, or *Eulerian circuit* —
the bound improves to $0$, recovering the fact that an Eulerian circuit forces all
degrees even.) $\qquad\blacksquare$

### 3.6 The handshake corollary and the parity of the odd set

The parity identities also re-derive, with no extra work, the most basic global
invariant of any multigraph.

> **Corollary F (Handshake lemma).** In any multigraph,
> $$ \sum_{v} \deg_G(v) = 2 n_E. $$
> Consequently the number of odd-degree vertices is *even*.

*Proof sketch.* Summing Definition 2.2 over all vertices and exchanging the order
of summation, each edge $e$ contributes the indicator $[\mathrm{ends}(e).1 = v]$ to
exactly one vertex and $[\mathrm{ends}(e).2 = v]$ to exactly one vertex, for a total
of $2$ per edge; hence the grand total is $2n_E$. A sum of integers is even if and
only if an even number of its summands are odd, so the count of odd-degree vertices
is even. $\qquad\blacksquare$

Corollary F sharpens Theorem E in the trail case: the number of odd-degree vertices
is *even and at most two*, hence exactly $0$ or exactly $2$. An Eulerian trail with
distinct endpoints has exactly two odd-degree vertices (its endpoints); one whose
endpoints coincide — an *Eulerian circuit* — has none. There is no multigraph with
a single odd-degree vertex, trail or no trail. This dichotomy is precisely what one
expects physically: a one-way walk has a head and a tail, or it closes up.

### 3.7 Remarks on sharpness and the converse

The bound in Theorem E is tight: a single edge between two distinct vertices is an
Eulerian trail with exactly two odd-degree vertices (each of degree $1$). The
results above establish the **necessary** condition for the existence of an Eulerian
trail. The celebrated **converse** — that a connected multigraph with at most two
odd-degree vertices in fact admits an Eulerian trail (Euler–Hierholzer) — is a
separate constructive theorem requiring a connectivity hypothesis and is not treated
here; the present paper isolates and proves the parity obstruction, which is the
half responsible for *impossibility* results such as Königsberg.

---

## 4. Worked example: the seven bridges of Königsberg

Model the city with four vertices — the north bank $N$, the south bank $S$, the
large island $A$, and the smaller island $B$ — and seven edges representing the
historical bridges. In the standard configuration the bridges connect:

| Bridge | Endpoints |
|-------:|:----------|
| 1 | $A$ – $N$ |
| 2 | $A$ – $N$ |
| 3 | $A$ – $S$ |
| 4 | $A$ – $S$ |
| 5 | $A$ – $B$ |
| 6 | $B$ – $N$ |
| 7 | $B$ – $S$ |

Counting endpoints (Definition 2.2):

$$ \deg(A) = 5, \qquad \deg(B) = 3, \qquad \deg(N) = 3, \qquad \deg(S) = 3. $$

All four vertices have **odd** degree. By Theorem E, any multigraph admitting an
Eulerian trail has at most two odd-degree vertices. Since $4 > 2$, **no Eulerian
trail exists**: it is impossible to cross every bridge exactly once. This is Euler's
1736 conclusion, recovered as a one-line corollary of the parity bound.

Had the city authorities removed or added a bridge to reduce the count of
odd-degree landmasses to two (or zero), a single-pass route would have become
possible — a quantitative design principle still used when planning sweep routes
over road networks.

---

## 5. Algorithms

The parity theory yields immediate, linear-time decision and design procedures.

### 5.1 Deciding the parity obstruction

Given a multigraph as an endpoint list, computing all degrees and counting odd ones
is a single linear pass.

```
Algorithm DEGREE-PARITY-CHECK
Input:  endpoint list ends[0..nE-1], each a pair (u, w) of vertices in 0..nV-1
Output: number of odd-degree vertices, and whether the parity obstruction allows
        an Eulerian trail
1.  deg[v] <- 0  for all v in 0..nV-1
2.  for e in 0..nE-1:
3.        (u, w) <- ends[e]
4.        deg[u] <- deg[u] + 1
5.        deg[w] <- deg[w] + 1        # a loop (u = w) adds 2 to deg[u]
6.  odd <- count of v with deg[v] odd
7.  return (odd, odd <= 2)            # necessary condition for an Eulerian trail
```

Complexity: $O(n_V + n_E)$ time and $O(n_V)$ space. By Theorem E the predicate
`odd <= 2` is a *necessary* condition; combined with a connectivity test (a
breadth/depth-first search over the non-isolated vertices) it becomes the *exact*
Euler–Hierholzer criterion.

### 5.2 Counting the forced repetitions (route inspection)

When the obstruction fails, the *route inspection* (Chinese-postman) problem asks
how many edge-traversals must be repeated to cover every edge. The number of
odd-degree vertices, always even by the handshake lemma, controls the answer: they
must be paired up and the shortest paths between paired vertices duplicated.

```
Algorithm ROUTE-INSPECTION-LOWER-BOUND
Input:  connected multigraph G
Output: a lower bound on extra traversals for a closed covering walk
1.  D <- { v : deg[v] is odd }        # |D| is even (handshake lemma)
2.  if D is empty: return 0           # Eulerian circuit exists, no repeats
3.  pair the vertices of D into |D|/2 pairs minimizing total shortest-path length
4.  return the total length of the minimizing pairing
```

The set $D$ in step 1 is exactly the object bounded by Theorem E (in the trail case
$|D| \le 2$); for general covering walks its size is the engine of the optimization.

---

## 6. Applications and discussion

**Route inspection and logistics.** Snowplows, street-sweepers, meter-readers, and
postal carriers all face the problem of traversing every street with minimum
backtracking. The first quantity any solver computes is the multiset of odd-degree
intersections — precisely the object constrained by Theorems D and E.

**Genome assembly.** De Bruijn–graph assemblers reconstruct a sequence from short
reads by seeking a trail that uses every edge (a $k$-mer overlap). Existence and
multiplicity of such trails are governed by node in/out balance, the directed
analogue of the parity condition proved here.

**Circuit testing and network sweeps.** Verifying that every connection in a network
or every wire on a board has been exercised exactly once is an Eulerian-trail
question; the parity count determines whether a single sweep suffices.

**Methodological significance.** Beyond its applications, the result is a model of
the *conserved-quantity* method. Theorem B exhibits an invariant — the corrected
degree is always twice an integer — and every qualitative conclusion is read off
from the parity of that invariant. This is the same reasoning pattern that yields
conservation laws in physics, invariants in topology, and checksums in computing.
The whole edifice rests on the trivial observation that you cannot enter a vertex
mid-trail without leaving it, so interior incidences pair up perfectly, and only the
two trail-ends escape the pairing.

**On the role of the permutation.** A subtle but essential modelling choice is that
"uses every edge exactly once" is encoded as a *permutation* of the edge set rather
than, say, a surjection or a counting constraint. This makes the change-of-variables
in Theorem A exact and assumption-free, and it cleanly accommodates multi-edges and
loops, which no simpler edge-set formulation handles gracefully.

---

## 7. Future directions

- **The constructive converse.** Formalize the Euler–Hierholzer theorem: a
  connected multigraph with at most two odd-degree vertices admits an Eulerian
  trail. This complements the obstruction proved here with an existence statement
  and an explicit trail-construction algorithm.
- **Directed and mixed multigraphs.** Replace degree parity by the in-degree =
  out-degree balance condition, and treat mixed graphs (some edges oriented), which
  are the relevant model for one-way-street route inspection and de Bruijn assembly.
- **Quantitative route inspection.** Turn the lower bound of Section 5.2 into a
  proved optimality guarantee via minimum-weight perfect matching on the odd-degree
  set, with certified approximation ratios.
- **Higher-dimensional analogues.** Investigate parity obstructions for "trails" in
  simplicial complexes, where boundary operators generalize the in/out pairing that
  drives Theorem B.

---

## 8. Conclusion

We have given a complete, self-contained proof of the parity obstruction to
Eulerian trails. Two counting identities — degree equals walk-step count
(Theorem A) and the endpoint correction (Theorem B) — reduce the entire qualitative
theory to the parity of an explicitly even quantity, yielding even interior degrees
(Theorem C), endpoint-membership of odd vertices (Theorem D), and the bound of at
most two odd-degree vertices (Theorem E). Applied to Königsberg's four odd
landmasses, the bound delivers Euler's impossibility verdict in a single line. The
argument is elementary yet final: it certifies that *no* route can succeed, and it
exemplifies the conserved-quantity reasoning that has shaped mathematics since
Euler first walked the bridges in his mind.
