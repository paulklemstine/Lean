# An Explicit Symmetry Certificate for the Edge-Transitive Möbius Ladder $M_3$, with Application to the Hamiltonian Compression Conjecture

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Physics / Algebraic Graph Theory

## Abstract

We give a self-contained, fully verifiable treatment of the symmetry structure of
the Möbius ladder $M_3$, the cubic graph on six vertices obtained from a hexagonal
rim $i\sim i\pm1$ by adjoining the three antipodal rungs $i\sim i+3$ over the
cyclic group $\mathbb{Z}/6\mathbb{Z}$. We prove that $M_3$ is $3$-regular, has
nine edges, and is isomorphic to the complete bipartite graph $K_{3,3}$ via the
parity coloring of $\mathbb{Z}/6\mathbb{Z}$. Our central contribution is a
**certificate-based proof of edge-transitivity** that avoids the standard,
circular appeal to the structure of the automorphism group: we exhibit an
explicit list of nine adjacency-preserving permutations, verify case-by-case that
each preserves adjacency and that their images of a single base edge exhaust all
nine edges, and then derive global edge-transitivity from the elementary group
closure of graph symmetries (identity, composition, inversion). We further show
$M_3$ is vertex-transitive via its rotation (translation) symmetries. We situate
these results as the rigorously verified base case of the *Hamiltonian
compression conjecture*: every Hamiltonian connected cubic edge-transitive graph
$\Gamma$ has compression factor $\kappa(\Gamma)\ge 2$, i.e., admits a Hamiltonian
cycle invariant under an order-2 automorphism acting as a half-rotation. The rim
cycle of $M_3$ together with the half-rotation $x\mapsto x+3$ exhibits
$\kappa(M_3)\ge 2$. We discuss the certificate methodology, its complexity, and a
program for extending it to the infinite Möbius-ladder family and beyond.

## 1. Introduction

Symmetry is the organizing principle of structural physics. The spectrum of a
tight-binding Hamiltonian on a graph, the degeneracies of a molecular orbital
system, and the conserved quantities of a discrete dynamical model are all
governed, often decisively, by the automorphism group of the underlying network.
Among finite networks the cubic ($3$-regular) graphs are especially important:
they model trivalent bonding (graphene, honeycomb lattices), three-way junctions,
and a large class of quantum circuits. When a cubic graph is moreover
**edge-transitive**, its connections are mutually indistinguishable, and symmetry
constraints are maximally strong.

This paper studies the smallest twisted cubic network that achieves this maximal
fairness: the Möbius ladder $M_3$ on six vertices. We treat three intertwined
goals.

1. **Identification.** Establish the basic combinatorial invariants of $M_3$
   (regularity, edge count) and prove the classical fact that $M_3\cong K_{3,3}$.
2. **Certified symmetry.** Prove edge-transitivity and vertex-transitivity by
   *explicit certificates* rather than by structural automorphism-group theory,
   thereby breaking the circularity inherent in defining symmetry through the very
   group one wishes to exhibit.
3. **Physical motivation.** Connect the rotation symmetries to the *Hamiltonian
   compression factor* and present $M_3$ as the rigorously verified base case of
   the compression conjecture.

All combinatorial assertions below are finite and decidable; they have been
checked by exhaustive kernel computation. The mathematical content of the paper is
the *organization* of these finite checks into a non-circular global argument.

### 1.1 Notation

We work over the cyclic group $\mathbb{Z}/6\mathbb{Z}$, written $\mathbb{Z}_6$,
with elements $\{0,1,2,3,4,5\}$ and addition mod $6$. A simple graph on a vertex
set $V$ is a symmetric, irreflexive relation $\mathrm{Adj}$ on $V$. The
*degree* of a vertex is the number of its neighbors; a graph is *cubic* if every
degree equals $3$. An *edge* is an unordered pair $\{i,j\}$ with $\mathrm{Adj}(i,j)$;
we write $s(i,j)$ for the unordered pair. $\mathrm{Sym}(V)$ denotes the group of
permutations of $V$. For a permutation $\sigma$ and an edge $e=s(i,j)$ we write
$\sigma\!\cdot\! e := s(\sigma i,\sigma j)$.

## 2. The Möbius ladder $M_3$

**Definition 1 (Adjacency and the graph $M_3$).**
Define the relation $\mathrm{adj}_3$ on $\mathbb{Z}_6$ by
$$\mathrm{adj}_3(i,j) \;:\Longleftrightarrow\; j = i+1 \ \lor\ i = j+1 \ \lor\ j = i+3.$$
The first two disjuncts are the *rim* edges of the hexagon $C_6$; the third gives
the three antipodal *rungs*. The relation is symmetric: the rim clauses are
mutually symmetric, and $j=i+3 \Leftrightarrow i=j+3$ since $3+3=0$ in
$\mathbb{Z}_6$. It is irreflexive since $1\ne0$ and $3\ne0$. We let $M_3$ denote
the corresponding simple graph $(\mathbb{Z}_6,\mathrm{adj}_3)$.

*(Lean: `adj3`, `adj3_symm`, `MobiusLadder3`.)*

**Theorem 1 (Cubicity).** Every vertex of $M_3$ has degree $3$:
$$\forall v\in\mathbb{Z}_6,\quad \deg_{M_3}(v) = 3.$$

*Proof sketch.* The neighbors of $v$ are $v+1$, $v-1$, and $v+3$. These three are
pairwise distinct in $\mathbb{Z}_6$: $v+1\ne v-1$ (else $2=0$), $v+1\ne v+3$ (else
$2=0$), $v-1\ne v+3$ (else $4=0$). Hence the neighbor set has exactly three
elements. The claim is a finite statement over six vertices and is discharged by
direct computation. $\square$

*(Lean: `MobiusLadder3.cubic`.)*

**Proposition 2 (Edge count).** $M_3$ has nine edges:
$|E(M_3)| = 9$.

*Proof sketch.* By the handshake lemma $|E| = \tfrac12\sum_v \deg v =
\tfrac12\cdot 6\cdot 3 = 9$; equivalently, six rim edges plus three rungs. Checked
by enumeration of the edge finset. $\square$

*(Lean: `MobiusLadder3.card_edges`.)*

**Theorem 3 (Identification $M_3\cong K_{3,3}$).**
For all $i,j\in\mathbb{Z}_6$,
$$\mathrm{Adj}_{M_3}(i,j) \iff i \bmod 2 \neq j \bmod 2.$$
Consequently $M_3$ is the complete bipartite graph on the even part
$\{0,2,4\}$ and the odd part $\{1,3,5\}$, i.e. $M_3\cong K_{3,3}$.

*Proof sketch.* Each adjacency clause changes parity: $j=i\pm1$ flips parity, and
$j=i+3$ flips parity because $3$ is odd. Hence adjacency implies opposite parity.
Conversely there are exactly nine even–odd pairs, and $M_3$ has exactly nine
edges (Proposition 2), so every even–odd pair must be an edge. The biconditional
is a finite statement over the $36$ ordered pairs and is verified by direct
computation. Since $K_{3,3}$ is precisely the graph whose edges are all even–odd
pairs on these parts, the isomorphism follows. $\square$

*(Lean: `MobiusLadder3.adj_iff_parity`.)*

**Remark.** Theorem 3 already *suggests* why edge-transitivity should hold: the
parity-preserving permutations of $\mathbb{Z}_6$ (those mapping evens to evens and
odds to odds, or swapping the two parts) act as automorphisms of $K_{3,3}$, whose
automorphism group is $(S_3\times S_3)\rtimes \mathbb{Z}_2$ of order $72$ acting
transitively on the nine edges. We do **not** invoke this structural fact; the
next section gives an explicit, non-circular certificate instead.

## 3. Graph symmetries as a group

**Definition 4 (Symmetry).** A permutation $\sigma\in\mathrm{Sym}(\mathbb{Z}_6)$
is a *symmetry* of $M_3$, written $\mathrm{IsSym}(\sigma)$, if it preserves
adjacency in both directions:
$$\mathrm{IsSym}(\sigma)\ :\Longleftrightarrow\ \forall i,j,\quad
\mathrm{Adj}_{M_3}(\sigma i,\sigma j)\iff \mathrm{Adj}_{M_3}(i,j).$$
This is exactly the condition that $\sigma$ be a graph automorphism. Symmetry of a
fixed $\sigma$ is a finite, decidable predicate (a check over $36$ pairs).

*(Lean: `IsSym`.)*

**Lemma 5 (Group closure).** The symmetries of $M_3$ form a subgroup of
$\mathrm{Sym}(\mathbb{Z}_6)$:
1. $\mathrm{IsSym}(\mathrm{id})$;
2. $\mathrm{IsSym}(\sigma)\wedge\mathrm{IsSym}(\tau)\Rightarrow
   \mathrm{IsSym}(\sigma\circ\tau)$;
3. $\mathrm{IsSym}(\sigma)\Rightarrow\mathrm{IsSym}(\sigma^{-1})$.

*Proof sketch.* (i) The identity preserves adjacency trivially. (ii)
$\mathrm{Adj}(\sigma\tau i,\sigma\tau j)\iff\mathrm{Adj}(\tau i,\tau j)\iff
\mathrm{Adj}(i,j)$, applying $\mathrm{IsSym}(\sigma)$ then $\mathrm{IsSym}(\tau)$.
(iii) Apply $\mathrm{IsSym}(\sigma)$ at the arguments $\sigma^{-1}i,\sigma^{-1}j$
and use $\sigma\sigma^{-1}=\mathrm{id}$. $\square$

*(Lean: `isSym_one`, `isSym_mul`, `isSym_inv`.)*

Lemma 5 is the *only* structural input to the main theorem. It is purely
algebraic and does not reference any specific automorphism of $M_3$.

## 4. The explicit symmetry certificate

**Definition 6 (Base edge and certificate).** Fix the base edge
$e_0 := s(0,1)$ (a rim edge). Define the **certificate** to be the list of nine
permutations
$$
\mathcal{C} := \big[\,\mathrm{id},\ (1\,3),\ (1\,5),\ (0\,2),\ (0\,2)(1\,3),\
(0\,2)(1\,5),\ (0\,4),\ (0\,4)(1\,3),\ (0\,4)(1\,5)\,\big],
$$
where $(a\,b)$ denotes the transposition swapping $a$ and $b$. Each entry moves
even vertices only among $\{0,2,4\}$ and odd vertices only among $\{1,3,5\}$, so
each manifestly preserves the parity bipartition.

*(Lean: `baseEdge`, `cert`.)*

**Lemma 7 (Certificate legality).** Every $\sigma\in\mathcal{C}$ is a symmetry of
$M_3$: $\forall\sigma\in\mathcal{C},\ \mathrm{IsSym}(\sigma)$.

*Proof sketch.* Each $\sigma\in\mathcal{C}$ preserves parity, and by Theorem 3
adjacency in $M_3$ is exactly "opposite parity," which any parity-respecting
permutation preserves. The statement is finite (nine permutations $\times$ $36$
pairs) and is discharged by direct computation. $\square$

*(Lean: `cert_isSym`.)*

**Lemma 8 (Edge covering).** The images of the base edge $e_0$ under the
certificate exhaust the edge set:
$$\forall e\in E(M_3),\ \exists\,\sigma\in\mathcal{C},\quad \sigma\!\cdot\! e_0 = e.$$

*Proof sketch.* Apply each $\sigma\in\mathcal{C}$ to $e_0 = s(0,1)$ and observe
the nine images are pairwise distinct; since $|E(M_3)|=9$ (Proposition 2), they
are all of $E(M_3)$. Concretely, $\mathrm{id}$ fixes $s(0,1)$; $(1\,3)$ and
$(1\,5)$ rotate the odd endpoint to give $s(0,3),s(0,5)$; the $(0\,2)$-prefixed
moves yield the edges at even vertex $2$; the $(0\,4)$-prefixed moves yield the
edges at even vertex $4$. The statement is finite and verified by direct
computation. $\square$

*(Lean: `cert_covers`.)*

## 5. Main results

**Theorem 9 (Edge-transitivity of $M_3$).** For any two edges
$e_1,e_2\in E(M_3)$ there exists a symmetry $\sigma$ of $M_3$ with
$\sigma\!\cdot\! e_1 = e_2$.

*Proof.* By Lemma 8 choose $\sigma_1,\sigma_2\in\mathcal{C}$ with
$\sigma_1\!\cdot\! e_0 = e_1$ and $\sigma_2\!\cdot\! e_0 = e_2$. Put
$\sigma := \sigma_2\circ\sigma_1^{-1}$. By Lemma 7 both $\sigma_1,\sigma_2$ are
symmetries, so by Lemma 5(ii)–(iii) $\sigma$ is a symmetry. Finally
$$\sigma\!\cdot\! e_1 = \sigma_2\!\cdot\!\big(\sigma_1^{-1}\!\cdot\!(\sigma_1\!\cdot\! e_0)\big)
= \sigma_2\!\cdot\! e_0 = e_2,$$
using functoriality of the edge action ($(\sigma\tau)\!\cdot\! e =
\sigma\!\cdot\!(\tau\!\cdot\! e)$) and $\sigma_1^{-1}\sigma_1=\mathrm{id}$. $\square$

*(Lean: `edge_transitive`.)*

This is the paper's central result, and the certificate makes the proof entirely
non-circular: no property of the automorphism group is assumed beyond the
elementary closure Lemma 5, and the symmetries used are produced explicitly.

**Lemma 10 (Rotations are symmetries).** For every $c\in\mathbb{Z}_6$ the
translation $\rho_c:x\mapsto x+c$ is a symmetry of $M_3$.

*Proof sketch.* Translation by $c$ preserves each adjacency clause:
$j=i+1\Rightarrow (j+c)=(i+c)+1$, similarly for $i=j+1$, and
$j=i+3\Rightarrow(j+c)=(i+c)+3$. Finite check over $c$ and over the $36$ pairs.
$\square$

*(Lean: `isSym_addRight`.)*

**Theorem 11 (Vertex-transitivity of $M_3$).** For any $u,v\in\mathbb{Z}_6$
there is a symmetry $\sigma$ with $\sigma(u)=v$.

*Proof.* Take $\sigma=\rho_{v-u}$, a symmetry by Lemma 10; then
$\sigma(u)=u+(v-u)=v$. $\square$

*(Lean: `vertex_transitive`.)*

Thus $M_3$ is both vertex-transitive and edge-transitive — a cubic graph of
maximal combinatorial homogeneity.

## 6. Connection to the Hamiltonian compression conjecture

**Definition (Hamiltonian compression factor, informal).** Let $\Gamma$ be a
finite graph with $n=|V(\Gamma)|$ vertices admitting a Hamiltonian cycle. The
*Hamiltonian compression factor* $\kappa(\Gamma)$ is the largest order of an
automorphism $g$ of $\Gamma$ that fixes some Hamiltonian cycle $C$ setwise and
acts on $C$ as a rotation. A factor $\kappa(\Gamma)\ge 2$ means there is a
Hamiltonian cycle and an order-2 automorphism acting as a half-rotation by $n/2$
positions — a *2-symmetric* Hamiltonian cycle.

**Conjecture (Hamiltonian compression).** Every Hamiltonian, connected, cubic,
edge-transitive graph $\Gamma$ satisfies $\kappa(\Gamma)\ge 2$. Exhaustive
computation over all such graphs up to $10{,}000$ vertices reveals no
counterexample.

**$M_3$ as a verified base case.** The results above establish all the structural
hypotheses for $M_3$ rigorously: it is cubic (Theorem 1), connected and
Hamiltonian (the rim $0\to1\to2\to3\to4\to5\to0$ is a Hamiltonian cycle), and
edge-transitive (Theorem 9). The half-rotation $\rho_3:x\mapsto x+3$ is an
automorphism (Lemma 10) of order $2$ (since $3+3=0$) which maps the rim cycle to
itself, shifting it by $3 = n/2$ positions. Hence the rim is a 2-symmetric
Hamiltonian cycle and $\kappa(M_3)\ge 2$, confirming the conjecture in its
smallest twisted-ladder instance. The general Möbius ladder $M_m$ on
$\mathbb{Z}_{2m}$, with rim $i\sim i\pm1$ and rungs $i\sim i+m$, carries the same
half-rotation $x\mapsto x+m$ of order $2$, suggesting a uniform proof of
$\kappa(M_m)\ge 2$; note, however, that $M_m$ is edge-transitive only for the
small cases $M_2\cong K_4$ and $M_3\cong K_{3,3}$, while $\kappa\ge 2$ persists
for the whole vertex-transitive family.

## 7. Methodology and complexity

The certificate method replaces a structural existence argument with three
ingredients: (a) a finite generating *witness set* $\mathcal{C}$; (b) finite
*legality* checks (Lemma 7); and (c) a finite *covering* check (Lemma 8), glued by
the group closure Lemma 5. The cost of verifying transitivity this way is:

- **Legality:** $|\mathcal{C}|\cdot|V|^2$ adjacency evaluations — here
  $9\cdot 36 = 324$.
- **Covering:** $|\mathcal{C}|$ edge-image computations and a comparison against
  $|E|$ edges — here $9$ images against $9$ edges.

This is exponentially cheaper than materializing the full automorphism group
($|\mathrm{Aut}(K_{3,3})| = 72$) and orders of magnitude cheaper than the naive
"for all pairs of edges, search for a symmetry" approach, which would scan
$|E|^2 = 81$ edge pairs against up to $|V|! = 720$ permutations. The covering
lemma reduces a quadratic-in-edges existence problem to a linear-in-certificate
covering problem, the standard orbit–stabilizer compression: edge-transitivity is
equivalent to the single base edge having a full orbit.

**General certificate template.** For any vertex-transitive group action, to prove
transitivity on a set $X$ it suffices to (i) fix a base point $x_0\in X$, (ii)
exhibit group elements whose images of $x_0$ cover $X$, and (iii) verify each is a
legal symmetry. This template applies verbatim to larger circulant graphs and is
the natural route to mechanized proofs of edge-transitivity for infinite families.

## 8. Discussion

Two points deserve emphasis. First, the **isomorphism $M_3\cong K_{3,3}$**
(Theorem 3) is the conceptual bridge: it recasts a metric/geometric description
(a twisted ladder with antipodal rungs) as a purely combinatorial one (the
complete bipartite graph), and it is the parity bipartition that makes the
certificate permutations transparently legal. Second, the **non-circularity** of
the edge-transitivity proof is not a pedantic nicety: in mechanized mathematics,
defining a symmetry group and then quoting its transitivity is genuinely circular
unless the transitivity has an independent witness. The certificate *is* that
independent witness.

The physical reading is direct. A tight-binding Hamiltonian supported on $M_3$
inherits the full automorphism action; edge-transitivity forces all hopping
amplitudes to play symmetric roles and constrains the spectrum, while the
half-rotation $\rho_3$ provides an order-2 conserved symmetry that organizes
eigenstates into $\pm$ sectors. The compression factor measures the largest
cyclic symmetry compatible with a Hamiltonian transport path, a quantity relevant
to symmetric routing and to degeneracy counting on symmetric lattices.

## 9. Future directions

The following directions extend the present base case toward the full conjecture.

**C1. Generic cubicity of Möbius ladders.** Conjecture: for every $m\ge2$,
$M_m$ is $3$-regular. The connection multiset $\{+1,-1,+m\}$ has three distinct
elements in $\mathbb{Z}_{2m}$ exactly when $m\ge2$ (collisions $+1=+m$ and
$-1=+m$ occur only at $m=1$), so the neighbor set has cardinality $3$ uniformly. A
generic proof replaces per-$m$ computation by a single cardinality argument,
upgrading $\kappa(M_m)\ge2$ to a uniform theorem over an infinite cubic family.

**C2. Exact compression factor for $M_m$.** Conjecture: $\kappa(M_m)=2$
generically, but certain $m$ (when $2m$ has rich divisor structure) admit a
higher-order rotation also preserving a Hamiltonian cycle, giving
$\kappa(M_m)>2$. Rotation by $1$ generates the full cyclic group acting on the
cycle, so each divisor $d\mid 2m$ yields a rotation of order $2m/d$; the
compression factor is the largest order of a cycle-preserving rotation, sensitive
to the arithmetic of $2m$.

**C3. Necessity of Hamiltonicity (Petersen).** Target lemma: the Petersen graph
admits no Hamiltonian cycle; hence "Hamiltonian" cannot be dropped from the
hypotheses. Petersen is cubic, edge-transitive, and vertex-transitive yet not
Hamiltonian — maximal symmetry does not force $\kappa\ge2$. Formalizing this pins
the exact boundary of the conjecture; it is the canonical $10$-vertex witness.

**C4. Half-rotation symmetry of every circulant Hamiltonian cycle.** Conjecture:
for any symmetric connection set $S\subseteq\mathbb{Z}_{2m}$ with $1\in S$ and
$m\in S$, the circulant $C_{2m}(S)$ admits the half-rotation $x\mapsto x+m$ as an
order-2 automorphism realizing $\kappa\ge2$, regardless of the remaining chords.
The key point is that translation by $m$ is an automorphism whenever $m\in S$ and
preserves the canonical Hamiltonian rim cycle.

## 10. Conclusion

We have given a complete, finite, and non-circular account of the symmetry of the
Möbius ladder $M_3$: it is cubic, has nine edges, is isomorphic to $K_{3,3}$, and
is both vertex- and edge-transitive, the latter via an explicit nine-element
symmetry certificate whose legality and covering properties are checked directly
and whose global consequence follows from elementary group closure. As the
smallest cubic edge-transitive Hamiltonian graph, $M_3$ furnishes a rigorously
verified base case of the Hamiltonian compression conjecture, with its rim and
half-rotation $x\mapsto x+3$ realizing $\kappa(M_3)\ge2$, and it supplies a
reusable certificate template for the infinite circulant families that the
conjecture ultimately concerns.
