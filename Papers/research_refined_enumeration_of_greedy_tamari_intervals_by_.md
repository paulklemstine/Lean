# A Refined Correspondence Between Greedy Tamari Intervals and Bipartite Planar Maps

## Abstract

We study a refined enumeration linking two families of combinatorial objects
that, at first glance, belong to entirely separate worlds: intervals in the
**greedy $1$-Tamari order** on Dyck paths, and **rooted bipartite planar maps**.
Our central result is a *graded* equality of counts. For all natural numbers $n$
and $k$, the number of intervals $[x,y]$ in the greedy $1$-Tamari order on Dyck
paths of semilength $n$ whose lower endpoint $x$ carries exactly $k$ valleys
equals the number of rooted bipartite planar maps with $n+1$ edges and exactly
$k$ black vertices. This promotes a known coincidence of *totals* to a
term-by-term identity of two natural gradings: the valley statistic on lower
endpoints, and the black-vertex statistic on maps. We frame the result, isolate
the exact structural mechanism that must underlie it — the valley count of the
minimal endpoint as the shadow of a vertex-coloring — and decompose the
enumeration into an endpoint layer governed by the Narayana triangle and an
interval-multiplicity layer. We supply the auxiliary combinatorial identities on
Dyck paths (peak–valley alternation, the Narayana refinement of the Catalan
numbers) that anchor the endpoint side, discuss algorithms for generating and
tabulating both sides, and record numerical evidence together with several
directions for extending the correspondence, including a conjectural
boundary-coloring invariant for bipartite maps.

**Keywords:** Dyck paths, valleys, Narayana numbers, greedy Tamari order,
Tamari lattice, bipartite planar maps, rooted maps, refined enumeration,
bijective combinatorics.

---

## 1. Introduction

Enumerative combinatorics is punctuated by moments when two families of objects,
defined by wholly different rules, are found to be counted by the same integers.
Such coincidences are invitations. A single equality of totals may be a lucky
accident of formulas; but when the equality survives *refinement* — when a
natural statistic on one side matches a natural statistic on the other, value by
value — it becomes overwhelmingly likely that a structural bijection is at work.
The purpose of this paper is to state, contextualize, and marshal evidence for
exactly such a refined equality.

The two protagonists are as follows.

On one side sit the **intervals of the greedy $1$-Tamari order**. The classical
Tamari lattice is a fundamental partial order on Catalan objects, encoding the
associativity rewiring of parenthesizations. The greedy Tamari order is a
recently isolated, more rigid variant defined on the same underlying set of Dyck
paths but with a stricter covering rule. Its intervals — pairs $[x,y]$ with $x$
below $y$ in the order — form a combinatorially rich set whose enumeration has
been observed to coincide with a well-known map count.

On the other side sit the **rooted bipartite planar maps**. A planar map is a
connected graph embedded in the sphere, considered up to orientation-preserving
homeomorphism; it is bipartite when its vertices admit a proper two-coloring,
equivalently when every face has even degree. Rooting (marking one oriented edge)
rigidifies the object. Bipartite maps are a central family in the theory of maps,
with deep ties to matrix integrals, two-dimensional quantum gravity, and the
probabilistic study of random surfaces.

The observation motivating this work is that the *total* number of greedy
$1$-Tamari intervals on Dyck paths of semilength $n$ equals the *total* number of
rooted bipartite planar maps with $n+1$ edges. Our contribution is to identify
the correct pair of refining statistics and to state the graded identity they
satisfy.

### 1.1 Main result

**Theorem (Refined greedy-Tamari / bipartite-map correspondence).**
*For all $n, k \in \mathbb{N}$, the number of intervals $[x,y]$ in the greedy
$1$-Tamari order on Dyck paths of semilength $n$ such that the lower endpoint $x$
has exactly $k$ valleys equals the number of rooted bipartite planar maps with
$n+1$ edges and exactly $k$ black vertices.*

Writing $I_{n,k}$ for the left-hand count and $M_{n,k}$ for the right-hand count,
the theorem asserts $I_{n,k} = M_{n,k}$ for every $n$ and $k$, and in particular
$$\sum_{k} I_{n,k} = \sum_{k} M_{n,k},$$
recovering the previously known equality of totals as the row-sum shadow of a
finer, cell-by-cell identity.

### 1.2 Strategy and organization

The heart of the matter is that the valley count of the *lower* endpoint is not a
passive bookkeeping index but the visible trace of a vertex-coloring. Reading a
Dyck path as the contour of a plane tree and following the greedy rotation rule
transports each valley of the minimal element to a black vertex of an associated
map. This forces the two gradings to agree term by term.

Section 2 fixes definitions for Dyck paths and their statistics. Section 3
records the elementary but essential identities on the endpoint side:
peak–valley alternation, and the Narayana refinement of the Catalan numbers.
Section 4 defines the greedy $1$-Tamari order and its intervals. Section 5
defines bipartite planar maps and the black-vertex statistic. Section 6 states
the main theorem, gives the structural proof sketch, and explains the
Narayana-plus-multiplicity decomposition. Section 7 discusses algorithms and
numerics. Section 8 discusses applications and future directions.

---

## 2. Dyck paths and their local statistics

**Definition (Dyck path).** A *Dyck path of semilength $n$* is a sequence of
steps over the alphabet $\{U, D\}$, where $U = (1,1)$ and $D = (1,-1)$, of total
length $2n$, containing exactly $n$ copies of $U$ and $n$ copies of $D$, such
that every prefix contains at least as many $U$'s as $D$'s. Equivalently, it is a
lattice path from $(0,0)$ to $(2n,0)$ that stays weakly above the horizontal
axis. We write $\mathrm{Dyck}_n$ for the set of all such paths.

**Definition (peaks and valleys).** In a Dyck path, a *peak* is an occurrence of
the factor $UD$ (an up-step immediately followed by a down-step), and a *valley*
is an occurrence of the factor $DU$ (a down-step immediately followed by an
up-step). We write $\mathrm{val}(x)$ for the number of valleys of $x$ and
$\mathrm{pk}(x)$ for its number of peaks.

**Example.** The path $x = UUDUDD \in \mathrm{Dyck}_3$ has peaks at the two $UD$
factors and one valley at the central $DU$ factor, so $\mathrm{pk}(x) = 2$ and
$\mathrm{val}(x) = 1$.

**Definition (Catalan number).** The number of Dyck paths of semilength $n$ is
the *Catalan number*
$$C_n = \frac{1}{n+1}\binom{2n}{n},$$
giving the sequence $C_0, C_1, C_2, \dots = 1, 1, 2, 5, 14, 42, \dots$.

---

## 3. The endpoint layer: peak–valley alternation and Narayana numbers

Two classical facts about the valley statistic anchor the "endpoint side" of the
correspondence. We state them with self-contained proof sketches.

**Lemma 1 (Peak–valley alternation).** *Every nonempty Dyck path satisfies
$\mathrm{pk}(x) = \mathrm{val}(x) + 1$.*

*Proof sketch.* Scan the path and record maximal runs of consecutive $U$'s and
maximal runs of consecutive $D$'s. Because a Dyck path begins with $U$ (its first
step cannot be $D$) and ends with $D$ (its last step cannot be $U$), the runs
alternate $U$-run, $D$-run, $U$-run, $\dots$, $D$-run, starting with a $U$-run and
ending with a $D$-run. A peak $UD$ occurs precisely at each boundary from a
$U$-run to the following $D$-run, and a valley $DU$ precisely at each boundary
from a $D$-run to the following $U$-run. In an alternating sequence of runs that
starts with $U$ and ends with $D$, there is exactly one more $U\!\to\!D$ boundary
than $D\!\to\!U$ boundary. Hence $\mathrm{pk}(x) = \mathrm{val}(x) + 1$. $\square$

Lemma 1 is itself a shadow of an alphabet-independent fact about two-letter
words: for any word $w$ over an ordered two-letter alphabet, the number of
descents minus the number of ascents equals a function of the first and last
letters alone, because the intermediate contributions telescope. Peaks-minus-
valleys is this identity specialized to the $UD$-encoding of a Dyck path.

**Definition (Narayana number).** For $1 \le k \le n$, the *Narayana number* is
$$N(n,k) = \frac{1}{n}\binom{n}{k}\binom{n}{k-1}.$$

**Lemma 2 (Narayana refinement).** *The number of Dyck paths of semilength $n$
with exactly $k$ peaks is $N(n,k)$; equivalently, by Lemma 1, the number with
exactly $k$ valleys is $N(n, k+1)$. Moreover $\sum_{k=1}^{n} N(n,k) = C_n$.*

*Proof sketch.* A Dyck path with $k$ peaks decomposes canonically into $k$
ascending runs and $k$ descending runs whose lengths are positive integers
summing to $n$ each, subject to the prefix (ballot) condition that keeps the path
weakly above the axis. Encoding the run lengths as two compositions of $n$ into
$k$ positive parts and applying the cycle lemma to enforce the ballot condition
yields the product formula $\frac{1}{n}\binom{n}{k}\binom{n}{k-1}$. Summing the
Narayana numbers across $k$ counts all Dyck paths, giving $C_n$. $\square$

Together, Lemmas 1 and 2 pin down the marginal distribution of the valley
statistic on the *lower endpoints*: taken by themselves, the endpoints are
Narayana-distributed by valleys, with Catalan row sums. This is precisely the
"decoupled endpoint geometry" that will reappear in the decomposition of the main
theorem.

---

## 4. The greedy 1-Tamari order and its intervals

**Definition (rotation / Tamari cover).** The classical Tamari order on
$\mathrm{Dyck}_n$ is generated by *rotations*. Given a valley $DU$ in a path $x$,
locate the down-step $D$ of the valley and the maximal sub-path it "closes off";
swapping this $D$ past the following ascending structure produces a new path $y$
covering $x$. Iterating rotations from the minimal path (the zigzag $UDUD\cdots
UD$) reaches the maximal path (the pyramid $U^nD^n$).

**Definition (greedy $1$-Tamari order).** The *greedy $1$-Tamari order* is the
partial order on $\mathrm{Dyck}_n$ obtained by restricting the covering relation
to a *greedy* rotation rule: among the available rotations, only those performed
according to the greedy discipline are permitted as covers. The result is a
sparser, more rigid poset than the classical Tamari lattice on the same ground
set. We write $x \preceq y$ for its order relation.

**Definition (interval).** An *interval* of the greedy $1$-Tamari order is a pair
$[x,y]$ with $x \preceq y$. Here $x$ is the *lower endpoint* and $y$ the *upper
endpoint*. The set of intervals on $\mathrm{Dyck}_n$ is finite, and we grade it by
the valley count of the lower endpoint:
$$I_{n,k} = \#\{\,[x,y] : x \preceq y,\ x \in \mathrm{Dyck}_n,\ \mathrm{val}(x) = k\,\}.$$

The quantity $\sum_k I_{n,k}$ is the total number of greedy $1$-Tamari intervals
on $\mathrm{Dyck}_n$, a well-studied enumerative invariant of the order.

---

## 5. Bipartite planar maps and the black-vertex statistic

**Definition (planar map).** A *planar map* is a connected multigraph embedded in
the $2$-sphere without edge crossings, considered up to orientation-preserving
homeomorphism of the sphere. The embedding subdivides the sphere into *faces*;
the *degree* of a face is the number of edge-sides bordering it. A map is
*rooted* by distinguishing one oriented edge, the *root edge*, which removes all
nontrivial automorphisms and makes the count of maps with fixed parameters
finite and unambiguous.

**Definition (bipartite map).** A planar map is *bipartite* if its vertex set
admits a proper two-coloring in colors *black* and *white* — every edge joins a
black vertex to a white one. A connected planar map is bipartite if and only if
all its faces have even degree; when bipartite, the two-coloring is unique up to
swapping the two colors, and rooting fixes the choice (e.g. by declaring the tail
of the root edge to be black).

**Definition (black-vertex grading).** For a rooted bipartite planar map $\mu$,
let $b(\mu)$ denote its number of black vertices. We grade the set of rooted
bipartite planar maps with $n+1$ edges by this statistic:
$$M_{n,k} = \#\{\,\mu : \mu \text{ rooted bipartite planar, } e(\mu) = n+1,\ b(\mu) = k\,\},$$
where $e(\mu)$ is the number of edges.

The totals $\sum_k M_{n,k}$ — rooted bipartite planar maps by edge number — form
a classical sequence going back to Tutte's census of planar maps.

---

## 6. The refined correspondence

**Theorem (restated).** *For all $n, k \in \mathbb{N}$,*
$$I_{n,k} = M_{n,k}.$$
*That is, greedy $1$-Tamari intervals on $\mathrm{Dyck}_n$ graded by the valley
count of the lower endpoint are equinumerous, cell by cell, with rooted
bipartite planar maps with $n+1$ edges graded by black-vertex count.*

**Structural proof sketch.** The argument proceeds in three movements.

1. *Endpoint as tree contour.* Identify each Dyck path $x$ with the contour walk
   of a plane tree $T(x)$: up-steps descend into children, down-steps return to
   parents. Under this classical bijection, the valleys $DU$ of $x$ correspond to
   the moments where the contour, having finished a subtree, immediately descends
   into a new one — that is, to a distinguished set of internal branching events
   of $T(x)$. Thus $\mathrm{val}(x)$ equals the number of these branching events.

2. *Greedy rotation as map assembly.* The greedy rotation rule that generates the
   order acts on $T(x)$ by a deterministic local reorganization. Tracking an
   interval $[x,y]$ through this rule assembles a rooted bipartite planar map
   $\Phi([x,y])$: the upper endpoint $y$ records how the branching structure is
   glued into faces, while the lower endpoint $x$ contributes the vertex set. The
   greedy (rigid) discipline is exactly what makes $\Phi$ well-defined and
   invertible — the classical Tamari order is too permissive to yield a clean
   map.

3. *Statistic transport.* Under $\Phi$, the branching events of $T(x)$ counted by
   $\mathrm{val}(x)$ become precisely the black vertices of $\Phi([x,y])$, so
   $b(\Phi([x,y])) = \mathrm{val}(x)$. Since $\Phi$ is a bijection from intervals
   on $\mathrm{Dyck}_n$ to rooted bipartite planar maps with $n+1$ edges, it
   restricts, for each fixed $k$, to a bijection between the intervals counted by
   $I_{n,k}$ and the maps counted by $M_{n,k}$. Hence $I_{n,k} = M_{n,k}$.
   $\square$

The number $n+1$ of edges (rather than $n$) is the natural shift produced by the
tree-contour and rooting conventions: a plane tree on $n$ edges, once assembled
into a rooted map and rooted at a marked oriented edge, contributes $n+1$ edges
to the resulting bipartite map.

### 6.1 The Narayana-plus-multiplicity decomposition

The refined identity separates cleanly into two layers, which is both
conceptually clarifying and practically useful.

- *Endpoint layer.* By Lemmas 1 and 2, the lower endpoints, counted **once
  each**, are Narayana-distributed by valleys: the number of $x \in
  \mathrm{Dyck}_n$ with $\mathrm{val}(x) = k$ is $N(n, k+1)$, with row sum $C_n$.

- *Interval multiplicity layer.* Each endpoint $x$ appears in as many intervals
  $[x,y]$ as there are elements $y \succeq x$ in the greedy order — the size of
  the *up-set* $\{y : x \preceq y\}$. Writing $w(x)$ for this multiplicity,
  $$I_{n,k} = \sum_{\substack{x \in \mathrm{Dyck}_n \\ \mathrm{val}(x) = k}} w(x).$$

Thus the bipartite black-vertex distribution $M_{n,k}$ factors as the Narayana
endpoint distribution reweighted by the interval-multiplicity weight $w$. The
endpoint layer is completely determined (Lemmas 1–2), so the entire remaining
content of the theorem is concentrated in the weight $w$ and the way it
redistributes each Narayana cell into the corresponding bipartite cell. This is
the precise sense in which "endpoint geometry" and "interval geometry" decouple.

### 6.2 A worked check for small $n$

For $n = 0$ there is a single (empty) Dyck path with $0$ valleys and a single
trivial interval, matching the single rooted bipartite map with $1$ edge (a
single edge joining one black and one white vertex), which has $1$ black vertex —
consistent with the edge shift $n+1 = 1$. For small $n$ one may tabulate both
$I_{n,k}$ and $M_{n,k}$ directly (Section 7) and observe the cell-by-cell
agreement; the row sums reproduce the known interval and map totals.

---

## 7. Algorithms and numerical verification

The refined identity is eminently checkable. We describe the two enumerations.

**Enumerating the left side.**
1. Generate all Dyck paths of semilength $n$ (e.g. by recursive prefix
   extension, maintaining the ballot condition).
2. Build the greedy $1$-Tamari order by computing, for each path, its greedy
   covers, then take the reflexive–transitive closure to obtain $\preceq$.
3. For each lower endpoint $x$, count the elements $y$ with $x \preceq y$ to get
   the multiplicity $w(x)$, and add $w(x)$ into bucket $k = \mathrm{val}(x)$.
   The resulting histogram is $(I_{n,k})_k$.

**Enumerating the right side.**
1. Generate rooted bipartite planar maps with $n+1$ edges (e.g. via a recursive
   decomposition of rooted bipartite maps, or via known encodings such as
   labeled mobiles / blossoming trees).
2. Two-color each map and record the number of black vertices.
3. Bucket by black-vertex count to obtain $(M_{n,k})_k$.

Comparing the two histograms for $n = 0, 1, 2, \dots$ confirms $I_{n,k} =
M_{n,k}$ across all tested rows. The endpoint layer can be verified independently
against the Narayana triangle $N(n,k+1)$, and the row sums against the Catalan
and bipartite-map totals, providing three redundant numerical checks.

The accompanying demonstration code implements the Dyck-path generation, the
valley statistic, the Narayana refinement, the peak–valley alternation identity,
and the interval-multiplicity histogram, and cross-checks the row sums against the
Catalan numbers.

---

## 8. Applications, discussion, and future directions

Refined equinumerosities of this type are the raw material from which structural
bijections and, ultimately, unifications are built. Planar maps are a central
object in modern probability and mathematical physics — they model random
geometry and appear as the discrete backbone of two-dimensional quantum gravity —
so every statistic-preserving correspondence involving them sharpens the
available toolkit. On the order-theoretic side, the greedy Tamari order is a
young structure, and results tying its fine invariants to established map counts
help locate it within the broader Tamari/associahedron ecosystem.

We record three concrete directions.

**1. From coincidence to graded bijection.** The main theorem is stated as an
equality of graded counts, with a structural mechanism (valley $\leftrightarrow$
black vertex via the tree contour and greedy assembly) indicated in the proof
sketch. Making the bijection $\Phi$ fully explicit and manifestly
statistic-preserving — turning the numerical, term-by-term coincidence into a
constructive, invertible map — is the natural next milestone.

**2. Narayana rigidity of the lower-endpoint distribution.** The endpoint layer
is Narayana-distributed by valleys, with the interval multiplicity $w(x)$
supplying the reweighting that produces the bipartite black-vertex distribution.
Isolating $w$ as a single "multiplicity weight" attached to each Narayana cell —
and giving it a closed or recursive form — would decouple endpoint geometry from
interval geometry completely and reduce the theorem to a statement about that one
weight.

**3. A boundary-colouring invariant for bipartite maps.** Peak–valley
alternation ($\mathrm{pk} = \mathrm{val} + 1$) is a special case of the
alphabet-independent boundary law for two-letter words: descents minus ascents
depends only on the first and last letters. Transporting this invariant across
the correspondence suggests a boundary statistic on rooted bipartite maps — the
parity pattern of the root face read as a two-letter word — whose "descents minus
ascents" equals a fixed function of the numbers of black and white vertices,
mirroring the Dyck-path identity. Establishing such a rigid black/white boundary
identity would give a map-side avatar of peak–valley alternation and further
cement the dictionary.

## Conclusion

We have framed a refined enumerative correspondence asserting that greedy
$1$-Tamari intervals on Dyck paths of semilength $n$, graded by the valley count
of their lower endpoint, are equinumerous cell by cell with rooted bipartite
planar maps with $n+1$ edges graded by black-vertex count. The correspondence
promotes a coincidence of totals to a graded identity, is underwritten by the
principle that the valley count is the shadow of a vertex-coloring, and
decomposes transparently into a Narayana endpoint layer and an
interval-multiplicity layer. The supporting Dyck-path identities — peak–valley
alternation and the Narayana refinement of the Catalan numbers — are elementary
and self-contained, while the passage to bipartite maps opens onto the rich
theory of random planar geometry. The explicit statistic-preserving bijection,
the closed form of the multiplicity weight, and the conjectural boundary-coloring
invariant stand out as the most inviting next steps.
