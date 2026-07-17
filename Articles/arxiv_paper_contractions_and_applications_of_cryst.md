# From Crystal Graphs to Skeletons: How Contraction Preserves Paths and Characters

## A map can become clearer when neighborhoods become points

A subway map is useful because it forgets. It does not show every doorway, staircase, or turn of the tunnel. It groups complicated local structure into stations and retains the connections that matter for travel. Combinatorics often makes the same move: replace a large graph by a smaller graph whose vertices represent coherent pieces of the original.

This simple idea becomes especially powerful in the study of crystal graphs. These directed, colored graphs encode the representation theory of Lie algebras. A connected crystal has a character—a weighted generating function recording its vertices—and, in familiar type-$A$ settings, that character is a Schur polynomial. A crystal may be partitioned into smaller pieces called quasicrystals, whose characters are Gessel fundamental quasisymmetric functions. Contracting each such piece to one point produces a crystal skeleton. Grouping those skeleton vertices once more produces larger tiles associated with Young quasisymmetric Schur functions. At the far end of this sequence, one expects an order such as Bruhat order to emerge.

But every act of forgetting raises two questions. Does the smaller graph invent routes that did not exist before? And does regrouping vertices preserve the generating function we care about? The contraction calculus developed here gives precise answers. Under a strong but transparent connectivity condition inside each contracted piece, contraction preserves directed reachability exactly. In parallel, weighted characters can be summed fiber by fiber without losing or duplicating any contribution. Both principles remain valid through repeated contractions.

The result is a rigorous explanation of why a richly decorated graph can be compressed into a skeleton without sacrificing either its path structure or its total character.

## The basic contraction

Let $V$ be the vertex set of a directed graph, and write $E(x,y)$ when there is an edge from $x$ to $y$. Suppose a map $q:V\to Q$ assigns every original vertex to a component label. The contracted graph has vertex set $Q$. It contains an edge from $a$ to $b$ exactly when there are representatives $x,y\in V$ such that

$$
q(x)=a,\qquad q(y)=b,\qquad E(x,y).
$$

This definition keeps every edge visible at the level of labels. In particular, an original edge from $x$ to $y$ becomes an edge from $q(x)$ to $q(y)$. Therefore every directed path in the original graph descends to a directed path in the quotient.

The reverse direction is subtler. A quotient path may use one representative of a component to enter and another representative to leave. Unless those representatives can be joined inside the component, the quotient path may splice together incompatible fragments and create a route that never existed upstairs.

The needed hypothesis is **directed fiber connectivity**. It says that whenever $q(x)=q(y)$, there is a directed path from $x$ to $y$ in the original graph. Notice the order: a path must exist from every chosen representative to every other. Ordinary undirected connectivity is not enough.

Under this condition, every quotient edge can be lifted from any chosen representative of its source. If a quotient edge from $q(x)$ to $b$ is witnessed by an original edge $u\to v$, directed fiber connectivity first takes us from $x$ to $u$, after which the witnessing edge takes us to $v$. Repeating this maneuver lifts an entire quotient path.

This yields the central reachability theorem:

> **Exact Reachability Theorem.** If every fiber of $q$ is directed-connected, then for all $x,y\in V$, there is a directed path from $q(x)$ to $q(y)$ in the contracted graph if and only if there is a directed path from $x$ to $y$ in the original graph.

The theorem says much more than “edges map to edges.” It says that contraction preserves the transitive geometry of the graph. No route is lost, and no fictitious route appears.

## Two compressions are one compression

Crystal skeletons are naturally built in stages. First one contracts crystal vertices into quasicrystals. Then one groups quasicrystals into larger skeleton components. Let $q:V\to Q$ perform the first grouping and $r:Q\to S$ the second.

There are two ways to describe the outcome. One can first contract by $q$ and then contract the resulting graph by $r$. Or one can assign every original vertex directly to $r(q(x))$ and contract once. These procedures produce exactly the same edge relation. In symbols, two-stage contraction equals contraction by the composite map $r\circ q$.

The same fact holds for three stages and, by iteration, for any finite hierarchy. This is the graph-theoretic analogue of replacing neighborhoods by districts and districts by cities: the final adjacency does not depend on whether the labels were applied one layer at a time or all at once.

If the fibers of $q$ are directed-connected in the original graph, and the fibers of $r$ are directed-connected in the first contracted graph, then reachability after both contractions is equivalent to reachability before either contraction. This is the **Two-Stage Reachability Theorem**. It supplies the abstract mechanism needed when crystal vertices are first organized into quasicrystals and then into Young-quasisymmetric tiles.

There is also an order-theoretic consequence. Suppose mutual reachability in the original graph forces equality: if $x$ reaches $y$ and $y$ reaches $x$, then $x=y$. Under directed fiber connectivity, mutual reachability of two quotient vertices forces those quotient vertices to be equal. Thus contraction preserves antisymmetry of reachability. When a final skeleton is identified with a partial order such as Bruhat order, this is the essential structural safeguard: cycles cannot mysteriously appear merely because vertices were grouped.

## Characters survive the journey

Paths are only half the story. Crystal combinatorics also attaches a weight $w(x)$ to every vertex. The weights may be monomials, polynomials, formal series, vectors, or elements of any commutative additive system. For a finite vertex set, the total character is

$$
\operatorname{ch}(V)=\sum_{x\in V} w(x).
$$

For a component label $a\in Q$, define its fiber character by

$$
\operatorname{ch}_q(a)=\sum_{\substack{x\in V\\q(x)=a}}w(x).
$$

This is simply the total weight of the vertices assigned to $a$. Summing over all labels recovers the original character:

$$
\sum_{a\in Q}\operatorname{ch}_q(a)=\sum_{x\in V}w(x).
$$

Every vertex belongs to exactly one fiber, so each weight occurs exactly once. The identity sounds elementary, yet it is the accounting principle behind character expansions: a global generating function becomes a sum of component generating functions.

More importantly, this accounting is associative. Given $q:V\to Q$ and $r:Q\to S$, the character of a final tile $s\in S$ can be computed in either of two ways. One may sum original vertex weights directly over all $x$ with $r(q(x))=s$, or first compute the character of each $q$-fiber and then sum those intermediate characters over all $a$ with $r(a)=s$. The two answers agree:

$$
\sum_{\substack{x\in V\\r(q(x))=s}}w(x)
=
\sum_{\substack{a\in Q\\r(a)=s}}
\left(\sum_{\substack{x\in V\\q(x)=a}}w(x)\right).
$$

This is the **Fiber-Character Associativity Theorem**. It extends to three stages and beyond. Summing all final tile characters always returns the total original character.

In the crystal setting, this explains the architecture of increasingly coarse expansions. If the first fibers carry Gessel fundamental quasisymmetric characters and the next tiles carry Young quasisymmetric Schur characters, then the global crystal character is the sum of the tile characters. The contraction calculus does not by itself establish those particular tableau-level character identifications; rather, it guarantees that once the local identifications are known, their assembly into the global character is exact and independent of how the hierarchy is parenthesized.

## A small example

Take six vertices $0,1,2,3,4,5$ with directed edges allowing movement within each pair $\{0,1\}$, $\{2,3\}$, and $\{4,5\}$ in both directions, together with bridge edges $1\to2$ and $3\to4$. Contract the three pairs to labels $A,B,C$. The quotient has the chain

$$
A\longrightarrow B\longrightarrow C.
$$

Because each pair is directed-connected, a quotient route from $A$ to $C$ lifts from any starting vertex in $A$. Starting at $0$, one can move to $1$, cross to $2$, move to $3$, and cross to $4$. The quotient has summarized the route but not fabricated it.

Give the six vertices weights $1,2,4,8,16,32$. The three fiber characters are $3$, $12$, and $48$, and their sum is $63$, the total vertex weight. If $A$ and $B$ are grouped into a larger tile $X$ while $C$ becomes $Y$, then the tile characters are $15$ and $48$. Direct summation and two-stage summation agree.

Now remove the edge $0\to1$ while keeping $1\to0$. The first pair remains connected if directions are ignored, but it is no longer directed-connected. The quotient still displays the edge $A\to B$, witnessed by $1\to2$, yet a traveler starting at $0$ cannot necessarily reach that witness. This exposes exactly why the theorem demands directed, not merely undirected, connectivity.

## Why the abstraction matters

Hierarchical compression appears far beyond crystals. In state-space reduction, one groups microscopic states into macrostates. In workflow analysis, detailed tasks become departments and departments become stages. In network routing, local subnetworks become supernodes. In each case, a coarse graph is trustworthy only if its displayed routes correspond to genuine fine-scale routes. Directed fiber connectivity is a clean sufficient condition.

The character identities have an equally broad interpretation. Whenever objects carry additive statistics, grouping can be performed locally, globally, or in stages without changing the total. This is the familiar principle behind partitioning sums, but here it is coupled to a precise statement about graph reachability. Structure and enumeration survive the same hierarchy.

For crystal skeletons, the next challenge is specialization. One must define the tableau data, crystal operators, descent compositions, and quasicrystal equivalence relation; identify tile characters with Young quasisymmetric Schur functions; characterize which edges cross tile boundaries; and prove that the final contraction matches the relevant Bruhat covers. Reduced words and Coxeter–Knuth moves would then connect the framework to Stanley symmetric functions and their Schur expansions.

The main conceptual lesson is already clear. A skeleton is not merely a smaller picture. When its pieces are internally navigable in the directed sense, it is a faithful map of every possible journey. When weights are aggregated fiber by fiber, it is also a faithful ledger. Contraction can therefore reveal the order hidden inside a crystal while preserving the character carried by the whole graph.