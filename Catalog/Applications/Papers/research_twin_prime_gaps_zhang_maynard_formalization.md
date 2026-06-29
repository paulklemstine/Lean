# The Unique Excluded Minor for $\mathbb{Z}/n$-Gainable Parallel Classes

**Author:** Aristotle

**Date:** 2026-06-29

## Abstract

We study when a *biased graph* — a graph together with a distinguished family of
*balanced* closed walks — admits a gain labelling valued in a finite cyclic
group $\mathbb{Z}/n$ that realises its prescribed balance: a closed walk is
balanced exactly when its signed sum of edge labels vanishes. We call such a
biased graph *$\mathbb{Z}/n$-gainable*. Our central result is an excluded-minor
characterisation for the family of **parallel classes** (graphs whose only cycles
are digons between two fixed vertices): such a biased graph is
$\mathbb{Z}/n$-gainable if and only if it contains no minor isomorphic to
$(n+1)K_2$, the parallel class of $n+1$ edges; equivalently, if and only if its
number of balance classes is at most $n$. Consequently $(n+1)K_2$ is the unique
minor-minimal non-gainable parallel class. The obstruction is a pigeonhole
phenomenon depending only on $|\mathbb{Z}/n| = n$, so it holds for every modulus
$n \ge 1$, prime or composite. We further establish two structural laws:
gainability over any abelian group is closed under labelled minors, and it is
*monotone under injective group homomorphisms*; specialised to cyclic groups
this yields a **divisibility law** — if $m \mid n$ then every
$\mathbb{Z}/m$-gainable biased graph is $\mathbb{Z}/n$-gainable. We give the
definitions, full proof sketches, an algorithm deciding gainability of a finite
parallel class, and worked numerical examples.

## 1. Introduction

Gain graphs (equivalently *voltage graphs*) attach to each oriented edge of a
graph an element of a group, and ask which closed walks have trivial total gain.
Biased graphs, introduced by Zaslavsky, abstract this one step further by
recording *which* cycles are balanced, without committing to a particular gain
group; a gain labelling then *realises* a biased graph when balance coincides
with vanishing gain. This viewpoint underlies frame and lift matroids, Dowling
geometries, signed graphs, and a wide range of applications where the central
question is whether a combinatorial pattern of "consistency" can be implemented
by genuine group-valued arithmetic.

A recurring theme — following the philosophy of the Graph Minor Theorem — is to
characterise gain-theoretic properties by *forbidden minors*: a finite list of
irreducible patterns whose avoidance is equivalent to the property. For
gainability over a cyclic group, the conjectural list (in the signed/biased
setting of Zaslavsky and Funk) begins with the parallel-class obstruction
$(n+1)K_2$ and continues with triangle and tetrahedron obstructions $\pm K_3$
and $-K_4$. This paper isolates and completely resolves the **parallel-class
slice** of that program over *every* cyclic group $\mathbb{Z}/n$, $n \ge 1$,
including composite moduli, and supplements it with monotonicity laws that
organise the dependence on $n$.

### Contributions

1. A clean abstract model of biased graphs by their oriented cycles and balance
   predicate, and of gainability over an arbitrary additive abelian group
   (Section 2).
2. **Minor-closedness** of gainability over any abelian group, via a signed
   pullback of gain labellings (Theorem 3.2).
3. **Monotonicity under injective homomorphisms** of the gain group, and the
   resulting **divisibility law** $m \mid n \Rightarrow (\text{Gainable}_m
   \Rightarrow \text{Gainable}_n)$ (Theorems 4.1–4.3).
4. The **pigeonhole obstruction**: $(n+1)K_2$ is not $\mathbb{Z}/n$-gainable for
   any $n \ge 1$, and hence no gainable biased graph has an $(n+1)K_2$ minor
   (Theorems 5.1–5.2).
5. The **excluded-minor characterisation** for parallel classes: gainability
   $\Leftrightarrow$ no $(n+1)K_2$ minor $\Leftrightarrow$ at most $n$ balance
   classes; hence $(n+1)K_2$ is the unique excluded minor (Theorems 6.3–6.4).

### Relation to prior notions

The parallel-class obstruction is the gain-theoretic shadow of two classical
facts. The first is the proper-colouring bound: a complete description of
pairwise distinctness on $k$ items needs at least $k$ colours, and $\mathbb{Z}/n$
supplies exactly $n$. The second is the representability of *parallel elements*
in matroids: in a frame or lift matroid built from a $\mathbb{Z}/n$-gain graph,
a parallel class of size exceeding $n$ cannot be faithfully coordinatised. Our
contribution is to package both into a single excluded-minor statement that is
uniform in $n$ and accompanied by an explicit, constructive realisation in the
feasible regime. Unlike representability results that hinge on field
characteristic, our analysis uses only the *order* of the gain group, which is
why primality of $n$ plays no role for the parallel-class slice.

## 2. The gain framework

We model walks, cycles, and balance combinatorially.

**Definition 2.1 (Signed sum).** Let $A$ be an additive abelian group and
$g : E \to A$ a labelling of an edge set $E$. An *oriented closed walk* is a list
$c = [(e_1, b_1), \dots, (e_\ell, b_\ell)]$ of edges with traversal directions
$b_i \in \{\mathrm{true}, \mathrm{false}\}$. Its **signed sum** (gain) is
$$
\operatorname{sgnsum}(g, c) \;=\; \sum_{i=1}^{\ell} \varepsilon_i\, g(e_i),
\qquad \varepsilon_i = \begin{cases} +1 & b_i = \mathrm{true},\\ -1 & b_i = \mathrm{false}.\end{cases}
$$

**Definition 2.2 (Biased graph).** A *biased graph* on edge set $E$ is a pair of
predicates on oriented closed walks: $\operatorname{isCycle}(c)$ marking the
cycles, and $\operatorname{balanced}(c)$ marking the balanced cycles.

**Definition 2.3 (Gainability).** A biased graph $G$ is **gainable over $A$**,
written $\mathrm{Gainable}_A(G)$, if there is a labelling $g : E \to A$ realising
its balance:
$$
\forall c,\ \operatorname{isCycle}(c) \;\Rightarrow\; \big(\operatorname{balanced}(c) \iff \operatorname{sgnsum}(g, c) = 0\big).
$$
We write $\mathrm{Gainable}_n := \mathrm{Gainable}_{\mathbb{Z}/n}$.

A basic compatibility lemma drives all transport arguments.

**Lemma 2.4 (Homomorphism law).** For an additive group homomorphism
$f : A \to B$, every labelling $g$ and walk $c$ satisfy
$\operatorname{sgnsum}(f \circ g, c) = f\big(\operatorname{sgnsum}(g, c)\big)$.

*Proof sketch.* $f$ commutes with finite sums and with negation, and the signed
sum is a finite sum of labels and their negations; applying $f$ termwise and
re-summing gives the claim. $\square$

## 3. Minors and minor-closedness

We use the *labelled minor* (weak-map) relation, which respects gains.

**Definition 3.1 (Labelled minor).** $H$ is a **minor** of $G$, written
$H \preceq G$, if there exist an injection of edges $\varphi : E_H \to E_G$ and
an orientation switch $\sigma : E_H \to \{\mathrm{true},\mathrm{false}\}$ such
that the induced map on walks,
$\operatorname{mapCycle}(\varphi,\sigma,c) = [(\varphi(e_i),\, \sigma(e_i)\oplus b_i)]_i$,
carries every cycle of $H$ to a cycle of $G$ and matches balance:
$\operatorname{balanced}_H(c) \iff \operatorname{balanced}_G(\operatorname{mapCycle}(\varphi,\sigma,c))$.

Given $g : E_G \to A$ define the **pullback** $\operatorname{pull}(\varphi,\sigma,g) : E_H \to A$
by $e \mapsto g(\varphi(e))$ if $\sigma(e) = \mathrm{false}$ and
$e \mapsto -g(\varphi(e))$ if $\sigma(e) = \mathrm{true}$. A direct expansion
gives the key identity
$$
\operatorname{sgnsum}(\operatorname{pull}(\varphi,\sigma,g),\, c) \;=\; \operatorname{sgnsum}\big(g,\, \operatorname{mapCycle}(\varphi,\sigma,c)\big).
$$

**Theorem 3.2 (Minor-closedness).** If $G$ is gainable over $A$ and $H \preceq G$,
then $H$ is gainable over $A$.

*Proof sketch.* Let $g$ realise $G$. Take $g' = \operatorname{pull}(\varphi,\sigma,g)$.
For any cycle $c$ of $H$,
$$
\operatorname{balanced}_H(c) \iff \operatorname{balanced}_G(\operatorname{mapCycle}(\varphi,\sigma,c)) \iff \operatorname{sgnsum}(g, \operatorname{mapCycle}(\varphi,\sigma,c)) = 0 \iff \operatorname{sgnsum}(g', c) = 0,
$$
using the minor's balance matching, the realisation of $G$, and the pullback
identity in turn. Hence $g'$ realises $H$. $\square$

The contrapositive is the engine of every lower bound: *if $H$ is not gainable
over $A$ and $H \preceq G$, then $G$ is not gainable over $A$.*

## 4. Monotonicity in the gain group

**Theorem 4.1 (Monotonicity under injective homomorphisms).** Let
$f : A \to B$ be an injective additive homomorphism. If $G$ is gainable over $A$,
then $G$ is gainable over $B$.

*Proof sketch.* If $g$ realises $G$ over $A$, set $g_B = f \circ g$. By
Lemma 2.4, $\operatorname{sgnsum}(g_B, c) = f(\operatorname{sgnsum}(g, c))$.
Since $f$ is injective and $f(0) = 0$, we have $\operatorname{sgnsum}(g_B, c) = 0
\iff \operatorname{sgnsum}(g, c) = 0$, so $g_B$ realises the same balance. $\square$

**Theorem 4.2 (Cyclic embedding).** If $m \mid n$ (with $m, n \ge 1$), there is
an injective additive homomorphism $\mathbb{Z}/m \hookrightarrow \mathbb{Z}/n$.

*Proof sketch.* Send the residue $j \bmod m$ to $j \cdot (n/m) \bmod n$. This is
additive, and its image is the unique subgroup of order $m$ in $\mathbb{Z}/n$;
it is injective because $j\cdot(n/m) \equiv 0 \pmod n$ forces $m \mid j$. (The
generator $1$ maps to $n/m$, an element of order exactly $m$.) $\square$

**Theorem 4.3 (Divisibility law).** If $m \mid n$, then every
$\mathbb{Z}/m$-gainable biased graph is $\mathbb{Z}/n$-gainable.

*Proof.* Combine Theorems 4.2 and 4.1. $\square$

Thus the dependence of gainability on the modulus factors through the lattice of
cyclic groups under divisibility: enlarging the clock along a divisibility chain
only enlarges the class of gainable biased graphs.

## 5. The pigeonhole obstruction

**Definition 5.1 (The parallel class $kK_2$).** For $k \ge 0$, let $kK_2$ be the
biased graph on edge set $\{1, \dots, k\}$ whose cycles are exactly the digons
$[(i,\mathrm{true}), (j,\mathrm{false})]$ for distinct $i \ne j$, none of which
is declared balanced. A digon's signed sum under a labelling $g$ is
$g(i) - g(j)$.

**Theorem 5.2 (Parallel-class threshold).** $kK_2$ is $\mathbb{Z}/n$-gainable if
and only if $k \le n$.

*Proof sketch.*

*(Sufficiency, $k \le n$.)* Choose any injection $g : \{1,\dots,k\} \to
\mathbb{Z}/n$ (possible because $k \le n = |\mathbb{Z}/n|$). For distinct
$i \ne j$ the digon has gain $g(i) - g(j) \ne 0$ by injectivity, so no digon is
balanced — matching the prescription that none should be. Hence $g$ realises
$kK_2$.

*(Necessity, $k > n$.)* Suppose $g$ realises $kK_2$. For any $i \ne j$, since the
digon is declared unbalanced, $g(i) - g(j) \ne 0$, i.e. $g(i) \ne g(j)$; thus
$g$ is injective. An injection $\{1,\dots,k\} \hookrightarrow \mathbb{Z}/n$
forces $k \le |\mathbb{Z}/n| = n$, contradicting $k > n$. $\square$

The case $k = n+1$ is the sharp obstruction.

**Corollary 5.3.** $(n+1)K_2$ is not $\mathbb{Z}/n$-gainable, for every
$n \ge 1$, prime or composite.

**Theorem 5.4 (Universal necessity).** No $\mathbb{Z}/n$-gainable biased graph
has an $(n+1)K_2$ minor.

*Proof.* If $(n+1)K_2 \preceq G$ and $G$ were gainable, minor-closedness
(Theorem 3.2) would make $(n+1)K_2$ gainable, contradicting Corollary 5.3.
$\square$

Note that primality of $n$ is never used: the only property of $\mathbb{Z}/n$
invoked is its cardinality $n$.

## 6. The excluded-minor characterisation for parallel classes

We now treat the full parallel-class family, where edges may be grouped into
*balance classes*: digons within a class are declared balanced, across classes
unbalanced.

**Definition 6.1 (Digon graph of an equivalence).** Given an equivalence
relation $s$ (a setoid) on a finite edge set $E$, the biased graph
$\operatorname{digon}(s)$ has cycles all digons $[(i,\mathrm{true}),(j,\mathrm{false})]$
($i \ne j$), with such a digon balanced iff $i \mathrel{s} j$.

**Lemma 6.2 (Realisation = class separator).** $\operatorname{digon}(s)$ is
$\mathbb{Z}/n$-gainable iff there exists $g : E \to \mathbb{Z}/n$ with
$i \mathrel{s} j \iff g(i) = g(j)$ for all $i, j$.

*Proof sketch.* A labelling realises $\operatorname{digon}(s)$ exactly when, for
all $i \ne j$, $i \mathrel s j \iff g(i)-g(j)=0 \iff g(i)=g(j)$; the diagonal
case $i = j$ is automatic since $s$ is reflexive and $g(i)=g(i)$. $\square$

Such a $g$ is constant on $s$-classes and takes distinct values on distinct
classes — i.e. it descends to an *injection of the quotient*
$E/s \hookrightarrow \mathbb{Z}/n$. This is possible iff the number of classes is
at most $n$.

**Theorem 6.3 (Card criterion).** For finite $E$,
$\operatorname{digon}(s)$ is $\mathbb{Z}/n$-gainable iff
$\lvert E/s \rvert \le n$.

*Proof sketch.* ($\Rightarrow$) A realising $g$ induces a well-defined injection
$E/s \to \mathbb{Z}/n$ (Lemma 6.2), so $\lvert E/s\rvert \le |\mathbb{Z}/n| = n$.
($\Leftarrow$) If $\lvert E/s\rvert \le n$, pick an injection
$\iota : E/s \hookrightarrow \mathbb{Z}/n$ and set $g = \iota \circ \pi$ with
$\pi : E \to E/s$ the quotient map; then $g(i)=g(j) \iff \pi(i)=\pi(j) \iff
i \mathrel s j$, realising $\operatorname{digon}(s)$ by Lemma 6.2. $\square$

**Theorem 6.4 (Minor criterion).** For finite $E$,
$(n+1)K_2 \preceq \operatorname{digon}(s)$ iff $\lvert E/s\rvert \ge n+1$.

*Proof sketch.* ($\Rightarrow$) A minor embedding $(\varphi,\sigma)$ sends the
$n+1$ edges of $(n+1)K_2$ to edges whose pairwise digons are unbalanced in
$\operatorname{digon}(s)$, hence to $n+1$ pairwise $s$-inequivalent edges; the
composite $a \mapsto \pi(\varphi(a))$ is then an injection
$\{1,\dots,n+1\} \hookrightarrow E/s$, so $\lvert E/s\rvert \ge n+1$.
($\Leftarrow$) If there are at least $n+1$ classes, choose representatives of
$n+1$ distinct classes and let $\varphi$ pick them (with trivial switch
$\sigma \equiv \mathrm{false}$); distinctness of classes makes every image digon
unbalanced and the map a valid labelled-minor embedding. $\square$

Combining the two criteria gives the headline theorem.

**Theorem 6.5 (Excluded-minor characterisation).** For a finite parallel-class
biased graph $\operatorname{digon}(s)$,
$$
\mathbb{Z}/n\text{-gainable} \quad\iff\quad (n+1)K_2 \not\preceq \operatorname{digon}(s).
$$

*Proof.* By Theorems 6.3 and 6.4, both sides are equivalent to
$\lvert E/s\rvert \le n$ (the right side being the negation of
$\lvert E/s\rvert \ge n+1$). $\square$

**Corollary 6.6 (Uniqueness and minimality).** $(n+1)K_2$ is the unique
minor-minimal non-gainable parallel class over $\mathbb{Z}/n$: it is not
gainable (Corollary 5.3), yet deleting any single edge yields $nK_2$, which is
gainable (Theorem 5.2). Therefore the parallel-class slice of $\mathbb{Z}/n$-
gainability is characterised by the single forbidden minor $(n+1)K_2$.

## 7. Algorithm: deciding gainability of a finite parallel class

By Theorem 6.3, gainability of $\operatorname{digon}(s)$ reduces to counting
balance classes. The decision is therefore linear-time after a union–find pass.

```
Input:  modulus n ≥ 1; finite edge set E; balance relation s (given as
        a list of balanced pairs generating an equivalence).
Output: whether digon(s) is ℤ/n-gainable, plus a realising labelling g if so.

1. Initialise a union–find structure over E.
2. For each balanced pair (i, j): union(i, j).
3. Let C = number of distinct roots (the number of balance classes |E/s|).
4. If C > n: return "NOT GAINABLE" (it contains an (n+1)K₂ minor).
5. Else:
     a. Enumerate the classes as r_1, …, r_C and fix an injection
        ι: {r_1,…,r_C} → ℤ/n, e.g. ι(r_t) = (t − 1) mod n.
     b. Define g(e) = ι(find(e)) for every edge e.
     c. return ("GAINABLE", g).
```

Correctness is exactly Theorem 6.3 (and its constructive converse): the produced
$g$ is constant on classes and injective across classes, so it separates the
classes and realises $\operatorname{digon}(s)$. Complexity is
$O(\lvert E\rvert\, \alpha(\lvert E\rvert))$ for the union–find plus $O(C)$ to
assign labels.

## 8. Worked examples

We illustrate the criteria on concrete parallel classes.

**Example 8.1 (Threshold over a small clock).** Take $n = 3$ and the parallel
class $kK_2$ (no two edges balanced). For $k = 3$ the labelling
$g = (0,1,2)$ assigns distinct residues, so the three digons have gains
$1, 2, 2$ — all nonzero — and $3K_2$ is $\mathbb{Z}/3$-gainable. For $k = 4$,
any labelling places $4$ residues in $\{0,1,2\}$, so by pigeonhole two coincide
and a balanced digon appears; $4K_2 = (3{+}1)K_2$ is not $\mathbb{Z}/3$-gainable.
This is exactly Theorem 5.2 at the boundary, and the failing case is the
excluded minor.

**Example 8.2 (Balance classes and the card criterion).** Let $E$ have six
edges grouped into three balance classes $\{1,2\}, \{3,4\}, \{5,6\}$; digons
within a class are balanced, across classes unbalanced. By Theorem 6.3 this is
$\mathbb{Z}/n$-gainable iff $3 \le n$. Over $\mathbb{Z}/3$ a realising labelling
is $g = (0,0,1,1,2,2)$: equal residues exactly within classes. Over
$\mathbb{Z}/2$ there are only two residues for three classes, so by Theorem 6.4
an $(2{+}1)K_2 = 3K_2$ minor is present and no labelling works. The number of
classes, not the number of edges, is what the modulus must accommodate.

**Example 8.3 (Divisibility transport).** A graph realised over $\mathbb{Z}/3$
is automatically realised over $\mathbb{Z}/12$ because $3 \mid 12$: compose the
$\mathbb{Z}/3$ labelling with the embedding $j \mapsto 4j \bmod 12$ (the
generator $1 \mapsto 4$, of order $3$). The image residues $\{0,4,8\}$ remain
pairwise distinct, so no balanced digon is created. The same labelling does
*not* obviously transport to $\mathbb{Z}/5$, since $3 \nmid 5$ — though here
$\mathbb{Z}/5$ happens to admit its own realisation because $3 \le 5$; the
divisibility law gives a *sufficient*, structurally canonical transport, not the
only route to gainability.

## 9. Applications and interpretation

- **Voltage/electrical consistency.** With $\mathbb{Z}/n$ modelling discrete
  potentials, the threshold $k \le n$ is the maximum number of mutually
  inconsistent parallel branches that distinct potential levels can certify; the
  divisibility law explains why refining the level set (passing from $n$ to a
  multiple) only relaxes constraints.
- **Frustration and frequency assignment.** Unbalanced digons model pairwise
  conflicts; $\lvert E/s\rvert \le n$ is precisely the condition that $n$
  "colours" suffice to honour all conflicts and coincidences simultaneously.
- **Matroid theory.** Parallel classes are the local building blocks of frame
  and lift matroids over $\mathbb{Z}/n$; the excluded-minor statement is the
  ground floor of the corresponding representability theory, identifying the
  smallest non-representable parallel configuration as $(n+1)K_2$.
- **Periodic structures and frustration.** In lattice models a balanced loop is
  a region where local phase constraints close up consistently; the threshold
  $k \le n$ quantifies how many competing local rules a discrete phase space of
  size $n$ can keep mutually frustrated, and the divisibility law shows that
  refining the phase space along a divisor chain can only ease frustration, never
  create it.
- **Algorithmics.** Because the criterion reduces to counting equivalence
  classes, deciding gainability of a parallel class — and producing a witness
  labelling or certifying the $(n+1)K_2$ obstruction — is achievable in
  near-linear time, with no dependence on the arithmetic structure of $n$.

## 10. Discussion

The result exhibits the structural-mathematics ideal in miniature: an infinite
family's membership in a property is decided by avoidance of a single explicit
pattern. Three features deserve emphasis. First, *uniformity*: nothing depends on
the arithmetic of $n$ beyond its size, so prime and composite moduli behave
identically for parallel classes. Second, *monotonicity*: the divisibility law
organises all moduli into a single lattice, with the parallel-class threshold
$k \le n$ as its visible shadow. Third, *robustness via minors*: minor-closedness
turns a pigeonhole fact into a universal necessary condition, and the matching
sufficiency for parallel classes closes the loop.

The scope is honestly limited to the parallel-class (digon) slice. The full
Zaslavsky–Funk program over $\mathbb{Z}/n$ predicts further excluded minors
($\pm K_3$, $-K_4$) that are genuine signed-graph / Dowling-geometry phenomena;
capturing them requires a model with vertex-level structure, beyond the
cycle-and-balance abstraction used here. Extending the present clean
characterisation to those obstructions — and proving where primality finally
*does* intervene — is the natural continuation.

## 11. Future work

- A finer biased-graph model carrying vertex incidence, to state and attack the
  $\pm K_3$ and $-K_4$ obstructions over $\mathbb{Z}/n$.
- A converse to the divisibility law: characterise exactly which group
  homomorphisms preserve gainability, and whether $m \nmid n$ can ever block
  transport for specific families.
- Quantitative excluded-minor lists for richer subclasses (e.g. series–parallel
  biased graphs) over cyclic and general abelian gain groups.

## References

- T. Zaslavsky, *Biased graphs. I. Bias, balance, and gains*, J. Combin. Theory
  Ser. B, 1989.
- N. Robertson and P. D. Seymour, *Graph Minors* series.
- D. Funk, *Biased graphs and their excluded minors*, 2015.
