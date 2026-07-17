# Contraction Calculus for Crystal Skeletons: Reachability, Character Decomposition, and Iterated Quotients

## Abstract

We develop a self-contained calculus for hierarchical contraction of finite weighted directed graphs, motivated by crystal skeletons, quasicrystal decompositions, Young quasisymmetric Schur functions, and the order structures arising after successive contractions. A contraction induced by a map $q:V\to Q$ places an edge between two quotient labels whenever some original edge has endpoints in the corresponding fibers. We prove that contraction is associative: successive contractions agree exactly with contraction by the composite quotient map. Because quotient paths may otherwise splice incompatible representatives, we isolate directed fiber connectivity—the requirement that every ordered pair in one fiber be joined by a directed path—as a sufficient lifting condition. Under this condition, quotient reachability is equivalent to original reachability, reachability depends only on fibers, and antisymmetry descends. These conclusions persist through a two-stage hierarchy.

For finite weighted graphs, we define the character of a fiber as the sum of its vertex weights in an arbitrary commutative additive target. Fiber characters partition the total character and are associative under iterated contraction. Consequently, a final tile character may be calculated either directly from original vertices or by summing intermediate component characters; summing all final tiles recovers the global character. We give constructive path-lifting and character-aggregation algorithms, examples, failure modes, and the precise interface with crystal combinatorics. The results supply the generic graph- and character-theoretic core required for passing from crystals to quasicrystals, from quasicrystals to Young-quasisymmetric tiles, and ultimately toward Bruhat-type quotients and applications to Stanley symmetric functions.

## 1. Introduction

A crystal graph packages representation-theoretic information into a directed, often edge-colored combinatorial object. Its vertices carry weights, and the sum of their weight monomials forms the crystal character. In type $A$, the character of a connected highest-weight crystal is a Schur polynomial. A finer partition into quasicrystals exposes Gessel fundamental quasisymmetric functions. Contracting those pieces creates a crystal skeleton, and a further tiling of the skeleton is expected to carry Young quasisymmetric Schur characters. Contracting still further can reveal an order such as Bruhat order. This hierarchy suggests a general mathematical question: what survives when a directed weighted graph is repeatedly compressed?

Two kinds of information matter. The first is dynamic: which vertices can reach which others by directed paths? The second is enumerative: how do vertex weights combine into component and global characters? A quotient defined merely by the existence of representative edges always maps fine paths to coarse paths, but the converse is false without an internal compatibility condition. A coarse path can enter a fiber at one representative and leave through another, even when no directed route connects those representatives. The appropriate condition is directed connectivity within every fiber.

The enumerative problem is governed by a different but complementary principle. Fibers partition the vertex set, so the total weight is the sum of fiber weights. Under nested partitions, finite sums may be regrouped associatively. This elementary observation becomes the structural foundation for decomposing a crystal character first into quasicrystal characters and then into tile characters.

This paper presents the resulting contraction calculus independently of any particular tableau model. The main results are:

1. successive graph contractions equal contraction by the composite map;
2. directed fiber connectivity gives exact preservation and lifting of reachability;
3. exact reachability persists through two contraction stages;
4. antisymmetry of reachability descends to the quotient;
5. fiber characters partition the global character;
6. fiber-character aggregation is associative through two or three stages.

These statements separate universal quotient mechanics from the specialized combinatorics still required to identify fibers with quasicrystals, tile characters with Young quasisymmetric Schur functions, and final quotient edges with Bruhat covers.

## 2. Directed graphs, paths, and contractions

### 2.1 Directed relations and reachability

Let $V$ be a set and let $E\subseteq V\times V$ be a directed edge relation. We write $x\to_E y$ when $(x,y)\in E$. A directed path from $x$ to $y$ is a finite sequence

$$
x=x_0,x_1,\ldots,x_k=y
$$

such that $x_i\to_E x_{i+1}$ for every $0\le i<k$. We allow $k=0$, so every vertex reaches itself. Write $x\leadsto_E y$ for this reflexive, transitive reachability relation.

The relation $\leadsto_E$ is always reflexive and transitive. We say it is antisymmetric if

$$
x\leadsto_E y\ \text{and}\ y\leadsto_E x\quad\Longrightarrow\quad x=y.
$$

In that case reachability is a partial order. Directed acyclic graphs provide the standard finite example.

### 2.2 Contraction along a labeling map

Let $q:V\to Q$ be any map. Its fibers $q^{-1}(a)$ are the groups to be compressed. Surjectivity is not required; unused labels simply have no representatives.

**Definition 2.1 (Contracted edge relation).** The contraction of $E$ along $q$ is the relation $E/q$ on $Q$ defined by

$$
a\to_{E/q} b
\quad\Longleftrightarrow\quad
\exists x,y\in V:\ q(x)=a,\ q(y)=b,\ x\to_E y.
$$

Loops are retained when an original edge has both endpoints in one fiber. For reachability, retaining or deleting such loops does not affect the reflexive transitive closure, but retaining them makes the contraction identity exact at the edge-relation level.

**Lemma 2.2 (Edge descent).** If $x\to_E y$, then $q(x)\to_{E/q}q(y)$.

**Proof sketch.** Use $x$ and $y$ themselves as the witnesses in Definition 2.1. $\square$

**Proposition 2.3 (Path descent).** If $x\leadsto_E y$, then $q(x)\leadsto_{E/q}q(y)$.

**Proof sketch.** Map each vertex of a directed path through $q$. Lemma 2.2 maps each edge to a contracted edge. A path of length zero remains a path of length zero. $\square$

Thus contraction never destroys reachability between images. The central issue is whether it creates new reachability.

## 3. Associativity of graph contraction

Suppose $q:V\to Q$ and $r:Q\to S$. One may contract $E$ along $q$ and then contract the resulting relation along $r$. Alternatively, one may contract $E$ directly along the composite $r\circ q:V\to S$.

**Theorem 3.1 (Two-stage contraction identity).** For all $s,t\in S$,

$$
s\to_{(E/q)/r}t
\quad\Longleftrightarrow\quad
s\to_{E/(r\circ q)}t.
$$

Hence $(E/q)/r=E/(r\circ q)$ as directed relations.

**Proof sketch.** Suppose first that $s\to_{(E/q)/r}t$. Then there are $a,b\in Q$ with $r(a)=s$, $r(b)=t$, and $a\to_{E/q}b$. The latter edge has representatives $x,y\in V$ satisfying $q(x)=a$, $q(y)=b$, and $x\to_E y$. Therefore $(r\circ q)(x)=s$ and $(r\circ q)(y)=t$, witnessing a direct composite contraction edge. Conversely, if $x\to_E y$ witnesses an edge under $r\circ q$, then $q(x)\to_{E/q}q(y)$, and these intermediate labels witness the second contraction. $\square$

**Corollary 3.2 (Three-stage contraction identity).** Given $t:S\to T$,

$$
((E/q)/r)/t=E/(t\circ r\circ q).
$$

**Proof sketch.** Apply Theorem 3.1 twice and use associativity of function composition. $\square$

By induction, any finite sequence of contractions agrees with one contraction by the composite labeling map. This means that a multilevel skeleton has a canonical final edge relation independent of the parenthesization of its construction.

## 4. Directed fiber connectivity and path lifting

### 4.1 The correct internal connectivity condition

**Definition 4.1 (Directed fiber connectivity).** The map $q:V\to Q$ has directed-connected fibers with respect to $E$ if, for every $x,y\in V$,

$$
q(x)=q(y)\quad\Longrightarrow\quad x\leadsto_E y.
$$

Because the assertion is quantified over ordered pairs, exchanging $x$ and $y$ shows that representatives in a common fiber can reach one another in both directions. Each nonempty fiber therefore lies inside a strongly connected component of the original graph.

This condition is deliberately stronger than connectedness of the underlying undirected graph. The direction matters because a quotient path must move from an arbitrary entry representative to a potentially different exit representative.

### 4.2 Lifting one quotient edge

**Lemma 4.2 (Edge lifting from a prescribed representative).** Assume that $q$ has directed-connected fibers. Let $x\in V$ and $b\in Q$. If

$$
q(x)\to_{E/q}b,
$$

then there exists $y\in V$ such that $q(y)=b$ and $x\leadsto_E y$.

**Proof sketch.** Choose representatives $u,v\in V$ witnessing the quotient edge, so $q(u)=q(x)$, $q(v)=b$, and $u\to_Ev$. Directed fiber connectivity gives $x\leadsto_Eu$. Append the edge $u\to_Ev$ and take $y=v$. $\square$

### 4.3 Lifting paths

**Theorem 4.3 (Path lifting).** Assume that $q$ has directed-connected fibers. Let $a,b\in Q$, let $a\leadsto_{E/q}b$, and choose any $x\in V$ with $q(x)=a$. Then there exists $y\in V$ such that

$$
q(y)=b\qquad\text{and}\qquad x\leadsto_Ey.
$$

**Proof sketch.** Induct on the length of the quotient path. A path of length zero is lifted by $y=x$. For the inductive step, lift the initial segment to a representative of the penultimate quotient vertex, then apply Lemma 4.2 to the last quotient edge. Concatenating the two lifted paths gives the result. $\square$

The lifting theorem is constructive. Given witnesses for quotient edges and routines that find internal fiber paths, it produces a fine path by alternately traversing a fiber and crossing a witnessing edge.

## 5. Exact preservation of reachability

**Theorem 5.1 (Exact Reachability Theorem).** If $q$ has directed-connected fibers, then for every $x,y\in V$,

$$
q(x)\leadsto_{E/q}q(y)
\quad\Longleftrightarrow\quad
x\leadsto_Ey.
$$

**Proof sketch.** The forward implication uses Theorem 4.3 to lift the quotient path from $x$ to some $z$ satisfying $q(z)=q(y)$. Directed fiber connectivity then supplies $z\leadsto_Ey$, and concatenation completes the lift. The reverse implication is Proposition 2.3. $\square$

**Corollary 5.2 (Fiber invariance of reachability).** Suppose $q$ has directed-connected fibers. If $q(x)=q(x')$ and $q(y)=q(y')$, then

$$
x\leadsto_Ey
\quad\Longleftrightarrow\quad
x'\leadsto_Ey'.
$$

**Proof sketch.** By Theorem 5.1, both statements are equivalent to reachability from the common source label to the common target label in the contracted graph. $\square$

This corollary says that under the connectivity hypothesis, reachability is genuinely a property of fibers rather than representatives.

### 5.1 Two-stage exactness

Let $q:V\to Q$ and $r:Q\to S$. Assume that each $q$-fiber is directed-connected for $E$, and each $r$-fiber is directed-connected for the contracted relation $E/q$.

**Theorem 5.3 (Two-Stage Reachability Theorem).** For all $x,y\in V$,

$$
r(q(x))\leadsto_{(E/q)/r}r(q(y))
\quad\Longleftrightarrow\quad
x\leadsto_Ey.
$$

**Proof sketch.** Apply Theorem 5.1 first to the map $r$ on the intermediate graph and then to the map $q$ on the original graph. The first equivalence replaces final reachability by intermediate reachability; the second replaces intermediate reachability by original reachability. $\square$

The theorem models the passage from crystal vertices to quasicrystals and then from quasicrystals to larger skeleton tiles. It isolates the exact hypotheses needed at each layer.

### 5.2 Descent of antisymmetry

**Theorem 5.4 (Antisymmetry after contraction).** Assume that $q$ has directed-connected fibers and that original reachability is antisymmetric. If

$$
q(x)\leadsto_{E/q}q(y)
\qquad\text{and}\qquad
q(y)\leadsto_{E/q}q(x),
$$

then $q(x)=q(y)$.

**Proof sketch.** Theorem 5.1 lifts the two quotient reachability statements to $x\leadsto_Ey$ and $y\leadsto_Ex$. Antisymmetry upstairs gives $x=y$, hence their images are equal. $\square$

Thus, when the original reachability relation is an order, contraction under the stated condition cannot introduce a nontrivial directed cycle among represented quotient vertices. This is the order-theoretic mechanism relevant to identifying a terminal skeleton with a Bruhat-type order.

## 6. Weighted characters and fiber decomposition

### 6.1 Additive setting

Let $V$ be finite. Let $A$ be a commutative additive monoid with identity $0$, and let $w:V\to A$ assign a weight to every vertex. The generality of $A$ permits numerical weights, vectors, monomials in an additive polynomial space, or formal generating functions, provided finite addition is commutative and associative.

**Definition 6.1 (Total character).** The total character is

$$
\operatorname{Ch}(V,w)=\sum_{x\in V}w(x).
$$

**Definition 6.2 (Fiber character).** For $q:V\to Q$ and $a\in Q$, the fiber character is

$$
\operatorname{Ch}_q(a)=\sum_{\substack{x\in V\\q(x)=a}}w(x).
$$

If a label has an empty fiber, its character is $0$.

**Theorem 6.3 (Character partition theorem).** If $Q$ is finite, then

$$
\sum_{a\in Q}\operatorname{Ch}_q(a)
=
\operatorname{Ch}(V,w).
$$

**Proof sketch.** Expand the left side as a double sum. For each $x\in V$, exactly one label, namely $q(x)$, includes $w(x)$; every other label contributes $0$ for that vertex. Reordering the finite sum leaves precisely one copy of each weight. $\square$

No graph connectivity assumption is needed for character decomposition. This is a partition identity, not a path-lifting statement.

### 6.2 Associativity of fiber characters

Let $q:V\to Q$ and $r:Q\to S$. Regard the first-stage character $a\mapsto\operatorname{Ch}_q(a)$ as a weight function on $Q$.

**Theorem 6.4 (Fiber-Character Associativity Theorem).** For each $s\in S$,

$$
\operatorname{Ch}_{r\circ q}(s)
=
\sum_{\substack{a\in Q\\r(a)=s}}\operatorname{Ch}_q(a).
$$

Equivalently,

$$
\sum_{\substack{x\in V\\r(q(x))=s}}w(x)
=
\sum_{\substack{a\in Q\\r(a)=s}}
\sum_{\substack{x\in V\\q(x)=a}}w(x).
$$

**Proof sketch.** The sets $q^{-1}(a)$ with $r(a)=s$ form a disjoint partition of $(r\circ q)^{-1}(s)$. Regroup the finite sum according to the intermediate label $a=q(x)$. $\square$

**Corollary 6.5 (Total character from final tiles).** If $S$ is finite, then

$$
\sum_{s\in S}\sum_{\substack{a\in Q\\r(a)=s}}\operatorname{Ch}_q(a)
=
\sum_{x\in V}w(x).
$$

**Proof sketch.** Apply Theorem 6.3 to the intermediate weight function and then apply it again to the original weights, or sum Theorem 6.4 over $s$. $\square$

**Theorem 6.6 (Three-level character associativity).** Given $t:S\to T$, for every $c\in T$,

$$
\operatorname{Ch}_{t\circ r\circ q}(c)
=
\sum_{\substack{s\in S\\t(s)=c}}
\sum_{\substack{a\in Q\\r(a)=s}}
\operatorname{Ch}_q(a).
$$

**Proof sketch.** Apply Theorem 6.4 to $(r\circ q,t)$ and then apply it to $(q,r)$ inside each summand. $\square$

The theorem extends by induction to any finite hierarchy. Parenthesization affects neither a final component character nor the total character.

## 7. Algorithms

### 7.1 Constructing a contraction

For finite graphs represented by an edge list, the contracted graph can be built in one pass.

**Algorithm 7.1 (Representative-edge contraction).** For each edge $(x,y)$, insert $(q(x),q(y))$ into a set of quotient edges. The set removes duplicates automatically.

If the graph has $m$ edges and labels are available in constant time, expected running time is $O(m)$ with hash sets and space is $O(\min(m,|Q|^2))$. A deterministic balanced-tree implementation takes $O(m\log m)$ time.

### 7.2 Lifting a quotient path

Suppose a quotient path $a_0,a_1,\ldots,a_k$ is supplied together with a witness edge $u_i\to_Ev_i$ for each transition $a_i\to a_{i+1}$. Starting from $x_0$ in the fiber of $a_0$, find an internal path from the current representative to $u_i$, append the witness edge, and continue from $v_i$. If an exact endpoint $y$ is desired, append an internal path from the final representative to $y$.

If breadth-first search is used independently inside each visited fiber, the worst-case time is $O(k(|V|+|E|))$. Precomputing routing data inside fibers can reduce repeated-query costs. The mathematical guarantee of success is precisely directed fiber connectivity.

### 7.3 Aggregating characters

Initialize every quotient label with $0$. For each vertex $x$, add $w(x)$ to the accumulator indexed by $q(x)$. This computes all fiber characters in $O(|V|)$ additions and $O(|Q|)$ storage. Repeating the operation for $r$ computes second-stage characters. Alternatively, aggregating once by $r\circ q$ gives the same result by Theorem 6.4.

## 8. Examples and failure modes

Consider vertices $V=\{0,1,2,3,4,5\}$. Within each pair $\{0,1\}$, $\{2,3\}$, and $\{4,5\}$ include both directed edges. Add bridge edges $1\to2$ and $3\to4$. Let $q$ map the pairs to $A,B,C$. Each fiber is directed-connected, and the quotient contains $A\to B\to C$. A path from $A$ to $C$ lifts from any representative of $A$. From $0$, one lifted route is

$$
0\to1\to2\to3\to4.
$$

Assign weights

$$
w(0)=1,\ w(1)=2,\ w(2)=4,\ w(3)=8,\ w(4)=16,\ w(5)=32.
$$

The fiber characters are $3$, $12$, and $48$, and their sum is $63$. If $r(A)=r(B)=X$ and $r(C)=Y$, then the second-stage characters are $15$ and $48$. Direct aggregation by $r\circ q$ gives exactly the same values.

For a failure mode, take vertices $u,v,z$ with the only relevant edge $v\to z$, and put $u,v$ in one fiber $A$ and $z$ in another fiber $B$. The quotient has $A\to B$, but a traveler starting at $u$ cannot follow it unless $u\leadsto_Ev$. Even if the fiber is connected after forgetting directions—for example, if $v\to u$ exists—this does not provide the required route from $u$ to $v$. Quotient reachability can therefore overstate original reachability when directed fiber connectivity fails.

## 9. Application to crystal skeletons

In the intended combinatorial hierarchy, $V$ is a crystal graph. A first map $q$ identifies vertices belonging to one quasicrystal. A second map $r$ groups quasicrystals into quasicrystal-skeleton tiles. Theorem 3.1 shows that the final edge relation is the direct contraction by $r\circ q$. If quasicrystal fibers are directed-connected in the required sense and tile fibers are directed-connected in the intermediate skeleton, Theorem 5.3 identifies final reachability exactly with crystal reachability.

On the character side, let $w(x)$ be the monomial weight of a crystal vertex. If each first-stage fiber character is identified with a Gessel fundamental quasisymmetric function, then Theorem 6.4 says that each second-stage tile character is the sum of its fundamental characters. If the resulting sum is identified with a Young quasisymmetric Schur function, Corollary 6.5 decomposes the total crystal character into those tile characters. This establishes the universal bookkeeping implication while leaving the tableau-specific character identification as a separate theorem.

Similarly, if labels on final components and crossing edges are shown to coincide with the elements and covers of a Bruhat order, Theorems 5.3 and 5.4 supply the generic reachability and antisymmetry steps. The paper-specific work must still characterize exactly which skeleton edges cross tile boundaries. For Stanley symmetric functions, one must additionally connect reduced words and Coxeter–Knuth moves to the chosen crystal and quotient structures.

## 10. Discussion

The graph and character theories require different hypotheses. Exact path lifting demands directed fiber connectivity. Character aggregation requires only finiteness and an additive commutative target. Keeping these assumptions separate prevents an enumerative partition identity from being mistaken for a structural graph theorem.

Directed fiber connectivity is sufficient but may not be minimal. Path lifting only needs enough internal movement to connect representatives at successive interfaces: an entry representative must reach a suitable outgoing-edge representative, and a terminal representative must reach the requested endpoint. A weaker interface condition could suffice for a fixed quotient graph or a restricted family of paths. The stronger all-pairs condition has the advantage of a short statement, representative independence, and immediate iteration.

The contraction identity itself needs no connectivity. Even a badly behaved quotient is associative at the one-edge level. Connectivity enters only when comparing transitive closures. This distinction is important: edge contraction and reachability preservation are separate operations with separate proofs.

The character results are instances of finite sum reindexing, but their formulation at the fiber level makes them useful as a compositional interface. Once local component characters are known, any hierarchy of tiles can be analyzed without returning to individual vertices. This modularity is especially valuable when the intermediate basis—fundamental quasisymmetric functions, Young quasisymmetric Schur functions, or Schur functions—changes from one layer to the next.

## 11. Future directions

Several concrete developments would specialize the contraction calculus to the full crystal-skeleton program.

1. **Tableau-level crystal data.** Define semistandard Young tableaux, crystal operators, descent compositions, and the quasicrystal equivalence relation. This connects the abstract contraction map to concrete crystal skeletons.

2. **Young quasisymmetric Schur functions.** Realize vertex and fiber characters in a multivariate polynomial or formal power-series target, prove that a quasicrystal fiber has Gessel fundamental character, and prove that a quasicrystal-skeleton tile has Young quasisymmetric Schur character.

3. **Bruhat identification.** Define the relevant labels and weak or strong Bruhat order, characterize precisely which skeleton edges cross tile boundaries, and prove that the final contracted edge relation agrees with Bruhat covers. The two-stage reachability and antisymmetry theorems then provide the generic order steps.

4. **Stanley symmetric functions.** Develop reduced words, Coxeter–Knuth moves, and Stanley symmetric functions, and instantiate the character decomposition to derive their Schur expansion.

5. **Weaker lifting hypotheses.** Replace pairwise directed connectivity of every fiber by the minimal interface condition needed to connect incoming and outgoing edge representatives, and compare that condition with connectivity properties of actual quasicrystals.

6. **Converses and counterexamples.** Determine when exact quotient reachability implies a useful fiber-connectivity condition, and classify small directed counterexamples showing why ordinary undirected connectivity does not suffice.

## 12. Conclusion

Hierarchical contraction can preserve both the geometry and the enumeration of a directed weighted graph, but the two claims rest on distinct principles. Directed fiber connectivity lets every coarse route be realized at fine scale, yielding exact reachability, representative independence, two-stage lifting, and descent of antisymmetry. Fiberwise addition partitions the total character and is associative through repeated groupings. Together these results provide a reusable foundation for crystal skeletons: local quasicrystal pieces may be compressed into larger Young-quasisymmetric tiles while paths and characters remain controlled. The remaining work is not a change to this calculus but its specialization to tableau operators, quasisymmetric bases, Bruhat covers, and Stanley symmetric functions.