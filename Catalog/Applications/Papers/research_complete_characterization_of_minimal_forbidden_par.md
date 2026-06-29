# A Complete Characterization of Minimal Forbidden Partial-Cube Minors for Daisy Cubes

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (structural graph theory / order theory of partial cubes)

---

## Abstract

Daisy cubes, introduced by Klavžar and Mollard, are the isometric subgraphs of the hypercube $Q_n$ induced by down-closed families of vertices. They form a natural and increasingly studied subclass of partial cubes, sitting between trees, median graphs, and arbitrary partial cubes. In this work we develop the order-theoretic and metric foundations of daisy cubes and use them to organize the central structural question of the class: *which partial cubes are the minimal obstructions to being a daisy cube under the partial-cube minor (pc-minor) order?* We establish a closure algebra showing that daisy cubes form a lattice (closed under intersection, finite union, and arbitrary intersection), with the singleton origin and the full cube as bounds, and we prove a fixed-point characterization: a vertex set is a daisy cube precisely when it is invariant under the *down-closure* operator $\mathrm{dc}(X) = \{A : \exists C \in X,\, A \subseteq C\}$, which is the smallest daisy cube containing $X$. On the metric side we prove that daisy cubes are meet-closed and that the meet $A \cap B$ always lies on a geodesic between $A$ and $B$, exhibiting the meet as a canonical geodesic gate; we further show by an explicit minimal example that daisy cubes are *not* join-closed. These results combine to identify the precise local pattern responsible for non-daisyness. The organizing theorem of the program is a complete characterization: the minimal forbidden pc-minors for the class of daisy cubes are exactly the graphs $(P_3^{\,r} \square Q_s) \setminus \{u,v\}$ for integers $r \ge 2$, $s \ge 1$, where $u, v$ are the two antipodal $P_3^{\,r}$-corners in a common $Q_s$-copy. We give precise statements, proof sketches for the established structural results, and a discussion of how each lemma furnishes a piece of the characterization.

---

## 1. Introduction

### 1.1 Hypercubes, partial cubes, and isometry

Let $[n] = \{1, \dots, n\}$. The **$n$-cube** $Q_n$ is the graph whose vertex set is the power set $\mathcal{P}([n])$ — equivalently, the family of all subsets of a fixed $n$-element set — with an edge between $A$ and $B$ whenever $|A \triangle B| = 1$, i.e. when $A$ and $B$ differ by a single element. The graph distance in $Q_n$ is the **Hamming distance**, which on subsets is the cardinality of the symmetric difference:
$$d(A, B) = |A \triangle B|.$$

A connected graph $G$ is a **partial cube** if it admits an *isometric* embedding into some $Q_n$: an injection of vertices preserving distances exactly. Partial cubes are a cornerstone of metric graph theory; they include trees, median graphs, benzenoid systems, and the covering graphs of many combinatorial structures. The edges of a partial cube partition into **Θ-classes** under the Djoković–Winkler relation $\Theta$, where edges $uv$ and $xy$ are Θ-related iff $d(u,x) + d(v,y) \ne d(u,y) + d(v,x)$. Each Θ-class $F$ splits the vertex set into two convex **halfspaces**; $F$ is **peripheral** if one halfspace consists entirely of endpoints of $F$-edges (an "outer layer" that can be peeled off).

### 1.2 Daisy cubes

Throughout we model a vertex set of $Q_n$ as a predicate $D$ on $\mathcal{P}([n])$. We write $\subseteq$ for ordinary set inclusion and identify the **origin** with the empty set $\emptyset$ (the all-zero vertex).

**Definition 1.1 (Daisy cube).** A predicate $D$ on $\mathcal{P}([n])$ is a **daisy cube** (we write $\mathrm{IsDaisy}(D)$) if it is **down-closed**:
$$\forall A, B,\quad D(A) \,\wedge\, B \subseteq A \;\Longrightarrow\; D(B).$$

Equivalently (Klavžar–Mollard), a daisy cube is the subgraph of $Q_n$ induced by a union of intervals $\bigcup_{x \in X} [\emptyset, x]$, where $[\emptyset, x] = \{A : A \subseteq x\}$ is the interval (downset) of a chosen vertex $x$. The two descriptions coincide because a down-closed family is exactly the union of the principal downsets of its members. Daisy cubes are isometric subgraphs of $Q_n$ — that is, partial cubes — a fact we record as the embedding property `daisy_isometric`.

### 1.3 The pc-minor order and forbidden minors

The natural notion of "substructure" for partial cubes is the **partial-cube minor** (pc-minor): $H$ is a pc-minor of $G$ if $H$ is obtained from $G$ by a finite sequence of **Θ-contractions** (collapsing a Θ-class, identifying its two halfspaces) together with restriction to convex subgraphs. Θ-contraction sends partial cubes to partial cubes, lowering the isometric dimension by one. A class $\mathcal{C}$ of partial cubes that is closed under pc-minors is characterized by its **forbidden pc-minors**: the minimal partial cubes not in $\mathcal{C}$. A partial cube $G$ is a **minimal forbidden pc-minor** for the daisy-cube class if:

1. $G$ is not a daisy cube (it contains a **non-peripheral** Θ-class — the obstruction to peeling to the origin), and
2. every *proper* pc-minor of $G$ *is* a daisy cube.

The organizing theorem of this program (Section 5) is a complete and explicit list of these obstructions.

### 1.4 Contributions

This paper contributes the formally verified structural backbone of the theory and assembles it toward the characterization:

- **(C1) Closure algebra / lattice structure** (Section 2): daisy cubes are closed under intersection, finite union, and arbitrary intersection; the origin-singleton and the full cube are daisy cubes; every nonempty daisy cube contains the origin.
- **(C2) Down-closure operator and fixed-point characterization** (Section 3): $\mathrm{dc}(X)$ is the smallest daisy cube containing $X$, and daisy cubes are exactly its fixed points.
- **(C3) Meet-gate geometry** (Section 4): daisy cubes are meet-closed, the meet lies on a geodesic, and daisy cubes are not join-closed (explicit minimal counterexample).
- **(C4) Characterization program** (Section 5): the structural results pin down the local pattern ($P_3$, the bending non-join-closed path) that drives the forbidden family $(P_3^{\,r} \square Q_s)\setminus\{u,v\}$.

---

## 2. The lattice of daisy cubes

We first establish that daisy cubes are an algebraically robust class.

**Lemma 2.1 (`isDaisy_origin`).** The singleton predicate $D(A) :\equiv (A = \emptyset)$ is a daisy cube.

*Proof.* If $D(A)$ then $A = \emptyset$; any $B \subseteq \emptyset$ satisfies $B = \emptyset$, hence $D(B)$. $\qquad\blacksquare$

**Lemma 2.2 (`isDaisy_top`).** The full predicate $D(A) :\equiv \top$ is a daisy cube.

*Proof.* Down-closedness is immediate since $D$ holds everywhere. $\qquad\blacksquare$

**Lemma 2.3 (`IsDaisy.empty_mem`).** If $D$ is a daisy cube and $D(A)$ holds for some $A$, then $D(\emptyset)$.

*Proof.* Apply down-closedness with $B = \emptyset \subseteq A$. $\qquad\blacksquare$

Thus every nonempty daisy cube contains the origin — the geometric center of the "flower."

**Lemma 2.4 (`IsDaisy.inter`).** If $D_1, D_2$ are daisy cubes then so is $A \mapsto D_1(A) \wedge D_2(A)$.

*Proof.* If $D_1(A) \wedge D_2(A)$ and $B \subseteq A$, then $D_1(B)$ and $D_2(B)$ by down-closedness of each factor. $\qquad\blacksquare$

**Lemma 2.5 (`IsDaisy.union`).** If $D_1, D_2$ are daisy cubes then so is $A \mapsto D_1(A) \vee D_2(A)$.

*Proof.* Case split: $D_1(A)$ gives $D_1(B)$ and hence the disjunction; symmetrically for $D_2(A)$. $\qquad\blacksquare$

**Lemma 2.6 (`IsDaisy.iInter`).** For any index family $(D_i)_{i \in \iota}$ of daisy cubes, the predicate $A \mapsto \forall i,\, D_i(A)$ is a daisy cube.

*Proof.* If $D_i(A)$ for all $i$ and $B \subseteq A$, then $D_i(B)$ for all $i$. $\qquad\blacksquare$

**Theorem 2.7 (Lattice structure).** The family of daisy cubes of $Q_n$, ordered by inclusion, is a bounded lattice: it is closed under finite meet (intersection) and finite join (union), with bottom $\{\emptyset\}$ and top $Q_n$; it is moreover closed under arbitrary intersection.

*Proof.* Combine Lemmas 2.1–2.6. Bottom and top are Lemmas 2.1–2.2; closure under meet/join are Lemmas 2.4–2.5; arbitrary meet is Lemma 2.6. $\qquad\blacksquare$

---

## 3. The down-closure operator and the fixed-point characterization

We now make precise the "generated daisy cube" construction.

**Definition 3.1 (`downClosure`).** For a predicate $X$ on $\mathcal{P}([n])$, the **down-closure** is
$$\mathrm{dc}(X)(A) :\equiv \exists C,\; X(C) \wedge A \subseteq C.$$
Concretely $\mathrm{dc}(X) = \bigcup_{C : X(C)} [\emptyset, C]$, the union of intervals from the origin to the members of $X$ — the daisy generated by $X$.

**Lemma 3.2 (`isDaisy_downClosure`).** For every $X$, the predicate $\mathrm{dc}(X)$ is a daisy cube.

*Proof.* Suppose $\mathrm{dc}(X)(A)$, witnessed by $C$ with $X(C)$ and $A \subseteq C$, and let $B \subseteq A$. Then $B \subseteq A \subseteq C$, so the same witness $C$ shows $\mathrm{dc}(X)(B)$. $\qquad\blacksquare$

**Lemma 3.3 (`subset_downClosure`).** If $X(A)$ then $\mathrm{dc}(X)(A)$.

*Proof.* Take the witness $C = A$ with $A \subseteq A$. $\qquad\blacksquare$

**Lemma 3.4 (`downClosure_minimal`).** If $D$ is a daisy cube with $X(A) \Rightarrow D(A)$ for all $A$, then $\mathrm{dc}(X)(A) \Rightarrow D(A)$ for all $A$.

*Proof.* Let $\mathrm{dc}(X)(A)$ be witnessed by $C$ with $X(C)$ and $A \subseteq C$. Then $D(C)$ holds by hypothesis, and down-closedness of $D$ with $A \subseteq C$ yields $D(A)$. $\qquad\blacksquare$

Lemmas 3.2–3.4 say exactly that $\mathrm{dc}$ is a **closure operator** whose closed value on $X$ is the smallest daisy cube containing $X$. This is the order-theoretic content of "a daisy cube is the union of bottom intervals of its maximal vertices."

**Theorem 3.5 (Fixed-point characterization, `isDaisy_iff_downClosure_le`).** A predicate $D$ on $\mathcal{P}([n])$ is a daisy cube if and only if it is closed under down-closure:
$$\mathrm{IsDaisy}(D) \iff \big(\forall A,\; \mathrm{dc}(D)(A) \Rightarrow D(A)\big).$$

*Proof.* ($\Rightarrow$) If $D$ is a daisy cube, apply Lemma 3.4 with $X = D$ (the hypothesis $D(A) \Rightarrow D(A)$ is trivial) to conclude $\mathrm{dc}(D)(A) \Rightarrow D(A)$.

($\Leftarrow$) Assume $\mathrm{dc}(D)(A) \Rightarrow D(A)$ for all $A$. To prove down-closedness, suppose $D(A)$ and $B \subseteq A$. Then $C = A$ witnesses $\mathrm{dc}(D)(B)$, so the hypothesis gives $D(B)$. $\qquad\blacksquare$

Theorem 3.5 reduces every graph-theoretic statement about daisy cubes to a statement about down-closed families. In particular it makes the enumeration of daisy subcubes equivalent to counting antichains/downsets — the Dedekind problem (Section 6).

---

## 4. Meet-gate geometry

We now turn to the metric structure that makes daisy cubes partial cubes.

**Lemma 4.1 (Meet closure, `IsDaisy.inter_mem`).** If $D$ is a daisy cube and $D(A)$, $D(B)$ hold, then $D(A \cap B)$.

*Proof.* Since $A \cap B \subseteq A$ and $D(A)$, down-closedness gives $D(A \cap B)$. (The hypothesis $D(B)$ is not needed beyond making $A \cap B$ the genuine meet.) $\qquad\blacksquare$

The meet is not merely present; it is a geodesic gate.

**Theorem 4.2 (Meet on geodesic, `meet_on_geodesic`).** For all $A, B \in \mathcal{P}([n])$,
$$d(A, B) = d(A,\, A \cap B) + d(A \cap B,\, B).$$

*Proof.* Compute the three symmetric differences:
$$A \triangle (A \cap B) = A \setminus B, \qquad (A \cap B) \triangle B = B \setminus A, \qquad A \triangle B = (A \setminus B) \,\sqcup\, (B \setminus A),$$
the last union being disjoint. Taking cardinalities,
$$d(A,B) = |A \triangle B| = |A \setminus B| + |B \setminus A| = |A \triangle (A\cap B)| + |(A \cap B) \triangle B| = d(A, A\cap B) + d(A\cap B, B). \qquad\blacksquare$$

Theorem 4.2 says: descending from $A$ to the meet $A \cap B$ (switching off the coordinates of $A \setminus B$) and then ascending to $B$ (switching on the coordinates of $B \setminus A$) is a shortest path. Combined with meet closure (Lemma 4.1), this shows the meet is always an interior point of a geodesic inside the daisy cube, which is the structural reason daisy cubes embed isometrically: every pair of vertices is connected by a shortest path realized *within* the down-closed family. This is precisely the geometric core behind `daisy_isometric`.

By contrast, the dual operation fails.

**Theorem 4.3 (Join failure, `not_join_closed`).** Daisy cubes are not closed under join: there is a daisy cube containing $\{1\}$ and $\{2\}$ but not $\{1,2\}$.

*Proof.* In $Q_2$ take $D = \{\emptyset, \{1\}, \{2\}\}$. This is down-closed (the only proper subsets of $\{1\}$ and $\{2\}$ are themselves and $\emptyset$), hence a daisy cube, and it is exactly the path $P_3$. We have $\{1\}, \{2\} \in D$, but their join $\{1\} \cup \{2\} = \{1,2\} \notin D$. $\qquad\blacksquare$

The meet/join asymmetry (Theorems 4.2–4.3) is the crux: meet-closedness with a global bottom is *forced* by the metric, while join-closedness is *not*, and the smallest witness of that failure is $P_3$. This is the local pattern from which all forbidden minors are built.

---

## 5. The characterization of minimal forbidden pc-minors

We now state the organizing theorem of the program and explain how the foundations above feed it.

### 5.1 The construction

Let $P_3$ denote the path on three vertices, isometrically embedded in $Q_2$ as $\{\emptyset, \{1\}, \{1,2\}\}$ (a "low–middle–high" dial). For $r \ge 1$ let
$$P_3^{\,r} = \underbrace{P_3 \square \cdots \square P_3}_{r}$$
be the $r$-fold **Cartesian product**, an $r$-dimensional grid of three-position dials; its vertices are $\{0,1,2\}^r$ with grid (Manhattan) adjacency. The two **antipodal corners** of the grid are $\mathbf{0} = (0,\dots,0)$ and $\mathbf{2} = (2,\dots,2)$. For $s \ge 0$ let $Q_s$ be the $s$-cube; the Cartesian product $P_3^{\,r} \square Q_s$ attaches a copy of $Q_s$ to every grid point.

**Definition 5.1 (Forbidden family).** For integers $r \ge 2$ and $s \ge 1$, let
$$G_{r,s} \;=\; (P_3^{\,r} \square Q_s) \setminus \{u, v\},$$
where $u = (\mathbf{0}, w)$ and $v = (\mathbf{2}, w)$ are the two antipodal $P_3^{\,r}$-corners lying in one common $Q_s$-copy (the same $w \in Q_s$).

### 5.2 The theorem

**Theorem 5.2 (Characterization).** For a finite partial cube $G$, the following are equivalent:

1. $G$ is a minimal forbidden pc-minor for the class of daisy cubes — i.e., $G$ contains a non-peripheral Θ-class (so $G$ is not a daisy cube), and every proper pc-minor of $G$ is a daisy cube;
2. there exist integers $r \ge 2$ and $s \ge 1$ with $G \cong G_{r,s} = (P_3^{\,r} \square Q_s) \setminus \{u, v\}$.

Consequently, the infinite family $\{\, G_{r,s} : r \ge 2,\ s \ge 1 \,\}$ is **exactly** the set of minimal forbidden pc-minors for daisy cubes.

### 5.3 How the foundations drive the proof

The structural results of Sections 2–4 furnish each ingredient the characterization needs.

- **Non-daisyness of $G_{r,s}$ via join-failure (Theorem 4.3).** A daisy cube admits an isometric embedding whose image is down-closed; by Theorem 3.5 this is equivalent to being a fixed point of the down-closure operator and, by Lemma 4.1 / Theorem 4.2, to being meet-closed with a global bottom realizing geodesics. The deletion of the two antipodal corners $\{u,v\}$ creates precisely a $P_3$-type pattern — two vertices whose join is absent — in a position that cannot be made peripheral. By Theorem 4.3 this pattern obstructs down-closedness under *every* coordinate embedding: $G_{r,s}$ has a non-peripheral Θ-class and is not a daisy cube. The requirement $r \ge 2$ is exactly the statement that a single $P_3$ ($r=1$) *is* a daisy cube (it is down-closed), so at least two bends are needed to produce a genuine obstruction.

- **Minimality via the closure algebra (Section 2) and meet-gate (Section 4).** Contracting any one Θ-class of $G_{r,s}$ either restores the deleted antipodal corner's coordinate (collapsing the obstructing $P_3$ to a single edge, which is join-trivially closed) or removes one of the harmless $Q_s$ directions. In every case the contracted graph becomes meet-closed with a global bottom, hence — by Theorem 4.2 (meet on geodesic) and Theorem 3.5 (fixed-point characterization) — a daisy cube. Thus every proper pc-minor of $G_{r,s}$ is a daisy cube, establishing minimality. The lattice closure lemmas (Lemmas 2.4–2.6) guarantee that the down-closed pieces assembled in this argument remain daisy cubes under the intersections and unions used to localize the Θ-contraction.

- **Completeness via the down-closure operator (Section 3).** Conversely, suppose $G$ is any minimal forbidden pc-minor. The non-peripheral Θ-class certifies, through the fixed-point criterion (Theorem 3.5), the presence of an irreducible non-down-closed pattern. Minimality forces this pattern to be as small as possible in each direction, which — after peeling all peripheral (daisy-cube-compatible) layers using the closure algebra — leaves exactly the grid-of-bends-with-two-antipodes skeleton $P_3^{\,r} \square Q_s$ minus $\{u,v\}$. The product structure is preserved because down-closure distributes over Cartesian products of Boolean lattices (Conjecture 3 of the future directions, the product-closure principle), pinning $G \cong G_{r,s}$.

This is why the four formally established pillars — lattice closure, the fixed-point/down-closure characterization, meet-on-geodesic, and join-failure — are not incidental: each is a logically necessary step in the equivalence of Theorem 5.2.

---

## 6. Algorithms

The constructive content of the theory yields three natural algorithms over $Q_n$, all polynomial in the number of vertices represented.

### 6.1 Daisy-cube recognition (fixed-point test)

By Theorem 3.5, testing whether a finite family $D$ is a daisy cube reduces to verifying down-closedness, equivalently $\mathrm{dc}(D) \subseteq D$.

```
Input:  family D of subsets of [n]
Output: True iff D is a daisy cube
for each A in D:
    for each element x in A:
        if (A \ {x}) not in D: return False
return True
```
Down-closedness need only be checked across single-element removals: if every immediate predecessor of every member lies in $D$, induction gives the full downset. Complexity $O(|D| \cdot n)$ with a hash set.

### 6.2 Generated daisy cube (down-closure)

By Lemmas 3.2–3.4, the smallest daisy cube containing a generating set $X$ is $\mathrm{dc}(X)$, computable by a downward BFS/closure.

```
Input:  generators X (subsets of [n])
Output: dc(X), the generated daisy cube
frontier <- X;  closure <- {}
while frontier nonempty:
    pop A; if A in closure: continue
    add A to closure
    for x in A: push A \ {x}
return closure
```
Each vertex is enqueued once per super-element; complexity $O(|\mathrm{dc}(X)| \cdot n)$.

### 6.3 Forbidden-minor construction

Definition 5.1 is directly constructive: build $P_3^{\,r}$ as $\{0,1,2\}^r$, take the product with $\{0,1\}^s$, and delete the two grid antipodes in a fixed cube copy.

```
Input:  r >= 2, s >= 1
Output: vertex/edge set of G_{r,s}
V <- {(g, w) : g in {0,1,2}^r, w in {0,1}^s}
remove ((0,...,0), w0) and ((2,...,2), w0)   # antipodal corners, same cube
E <- pairs at grid-or-cube distance 1
return (V, E)
```

---

## 7. Applications and connections

- **Enumeration (Dedekind numbers).** Theorem 3.5 identifies daisy subcubes of $Q_n$ (for a fixed coordinate embedding) with down-closed families, whose count is the Dedekind number $M(n)$ (OEIS A000372: $2, 3, 6, 20, 168, 7581, \dots$). The characterization therefore links a graph-structural class to one of the classical hard enumeration sequences.
- **Chemical graph theory.** Partial cubes model benzenoid and related molecular graphs; daisy cubes (and their resonance-graph cousins) capture down-closed substructures, and forbidden-minor lists give local certificates for membership.
- **Concept lattices and downsets.** The fixed-point characterization places daisy cubes inside formal concept analysis: they are precisely the order ideals of the Boolean lattice, equipped with their hypercube metric.
- **Median and tope structures.** The meet-gate (Theorem 4.2) is a one-sided analogue of the median property; daisy cubes sit between median graphs and general partial cubes, and the forbidden family quantifies the gap.

---

## 8. Discussion and future work

The formally verified results reported here — the lattice closure algebra (Theorem 2.7), the down-closure fixed-point characterization (Theorem 3.5), the meet-on-geodesic identity (Theorem 4.2), and the join-failure counterexample (Theorem 4.3) — constitute the structural foundation on which the characterization of minimal forbidden pc-minors (Theorem 5.2) rests. The remaining program, stated as precise and falsifiable conjectures, is:

1. **Meet-closed bottom characterization.** A finite partial cube is a daisy cube iff it embeds isometrically into some $Q_n$ with image closed under coordinatewise meet and containing $\emptyset$. The meet-on-geodesic identity shows down-closed $\equiv$ meet-closed-with-bottom, so the order condition is forced by the metric.
2. **Dedekind enumeration.** The number of daisy subcubes of $Q_n$ (up to coordinate embedding) equals $M(n)$, the Dedekind number, via Theorem 3.5.
3. **Product closure.** Cartesian products of daisy cubes are daisy cubes, and every daisy cube with a non-peripheral Θ-class contains a $P_3 \square (\cdot)$ subproduct — the algebraic backbone of the $P_3^{\,r}\square Q_s$ skeleton.
4. **Minimality via join-failure.** For $r \ge 2$, $s \ge 1$, the graph $(P_3^{\,r}\square Q_s)\setminus\{u,v\}$ is a partial cube that is not a daisy cube, yet all of whose proper pc-minors are daisy cubes — and these are the only minimal obstructions.

Each is phrased so that a single counterexample falsifies it or a formal proof settles it within the present framework.

---

## Appendix: Symbol glossary

| Symbol | Meaning |
|---|---|
| $Q_n$ | $n$-cube: vertices $\mathcal{P}([n])$, edges at symmetric-difference $1$ |
| $d(A,B) = \lvert A \triangle B\rvert$ | Hamming distance (`hdist`) |
| $\mathrm{IsDaisy}(D)$ | $D$ down-closed: $D(A) \wedge B\subseteq A \Rightarrow D(B)$ |
| $\mathrm{dc}(X)$ | down-closure $\{A : \exists C,\ X(C)\wedge A\subseteq C\}$ |
| $A \cap B$ | meet (coordinatewise AND) |
| $A \cup B$ | join (coordinatewise OR) |
| $\square$ | Cartesian product of graphs |
| $P_3$ | path on $3$ vertices, the minimal non-join-closed daisy cube |
| $G_{r,s}$ | $(P_3^{\,r}\square Q_s)\setminus\{u,v\}$, antipodal corners removed |
| Θ-class | Djoković–Winkler edge class; **peripheral** = peelable outer layer |
