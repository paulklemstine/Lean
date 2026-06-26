# Monotone Boolean Circuit Complexity: Foundations, the CLIQUE Lower Bound, and the Karchmer–Wigderson Correspondence

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty (Computational Complexity Theory)

## Abstract

We develop a rigorous foundation for *monotone Boolean circuit complexity* over
an arbitrary index type $\iota$ of input variables. A monotone circuit is built
from input variables, the constants $\mathrm{true}$ and $\mathrm{false}$, and the
two binary gates AND ($\wedge$) and OR ($\vee$), with no negation. We define
evaluation, size, depth, and the set of variables a circuit reads, and we prove
the structural backbone of the theory: (i) every monotone circuit computes a
monotone Boolean function ($\texttt{eval\_monotone}$); (ii) a circuit depends only
on the variables it physically contains ($\texttt{eval\_eq\_of\_agree\_on\_vars}$);
(iii) every relevant variable of the computed function must appear in the circuit
($\texttt{dependsOn\_mem\_vars}$); and (iv) the number of distinct variables read
lower-bounds the size ($\texttt{card\_vars\_le\_size}$), yielding the
relevant-variable size lower bound ($\texttt{card\_le\_size\_of\_relevant}$). We
then model graphs on $m$ vertices by edge-indicator inputs and define the CLIQUE
function, proving it monotone ($\texttt{cliqueFn\_monotone}$), that for $k=2$
every edge variable is relevant ($\texttt{cliqueFn\_two\_dependsOn}$), and
consequently that any monotone circuit for $2$-CLIQUE has size at least
$\binom{m}{2}$ ($\texttt{clique2\_size\_ge\_choose}$). Finally we discuss the
Karchmer–Wigderson correspondence between circuit depth and communication
complexity (forward direction $\texttt{kwCost\_le\_depth}$), and we situate
Razborov's exponential CLIQUE bound via the approximation method as the principal
open extension. All results are stated with full mathematical content and proof
sketches.

---

## 1. Introduction

A central goal of computational complexity theory is to prove unconditional lower
bounds — to show that certain functions cannot be computed by small or shallow
devices, regardless of cleverness. Boolean circuits are the canonical
non-uniform model: a circuit is a directed acyclic graph of logic gates that
computes a function of its input bits. Proving super-polynomial circuit lower
bounds for an explicit function in NP would separate $P$ from $NP$; this remains
out of reach.

*Monotone* circuits — those built from AND and OR gates only, with no NOT — are a
restricted but natural and powerful model, because they exactly capture the class
of monotone Boolean functions, which includes many fundamental graph and
combinatorial properties. The landmark theorem of Razborov (1985) established
that monotone circuits computing the $k$-CLIQUE function require *exponential*
size, the first super-polynomial lower bound for a natural problem in any
meaningful circuit model. A complementary structural result, the
Karchmer–Wigderson correspondence, equates the minimal circuit depth of a
function with the deterministic communication complexity of an associated
two-player relation.

This paper presents a clean, self-contained development of the foundations of
this theory and the elementary but genuine lower bounds that follow directly,
together with a precise account of the deeper results (Razborov's bound, the
Karchmer–Wigderson equivalence) that the foundations are designed to support.

### 1.1 Contributions

1. A generic inductive definition of monotone circuits over an arbitrary index
   type, with evaluation, size, depth, and variable-set semantics.
2. Four structural theorems: monotonicity of computed functions, locality
   (dependence only on read variables), relevance implies occurrence, and the
   variable-count size bound.
3. The relevant-variable size lower bound, an explicit and reusable lower-bound
   principle.
4. A formalization of the CLIQUE function in the edge-variable model, a proof
   that it is monotone, and a quadratic ($\binom{m}{2}$) monotone size lower
   bound for $2$-CLIQUE.
5. A precise statement and proof sketch of the Karchmer–Wigderson forward
   direction, and a roadmap to the converse, to Razborov's approximation method,
   and to monotone/non-monotone separation.

---

## 2. Monotone circuits: definitions

Throughout, $\iota$ is an arbitrary type of variable indices. An **input
assignment** is a function $x : \iota \to \mathsf{Bool}$.

**Definition 2.1 (Monotone circuit).** The type $\mathrm{MCircuit}(\iota)$ of
monotone Boolean circuits over $\iota$ is generated inductively by:
- $\mathrm{var}(i)$ for $i : \iota$ (an input leaf);
- $\top$ (the constant $\mathrm{true}$);
- $\bot$ (the constant $\mathrm{false}$);
- $\mathrm{and}(a,b)$ for circuits $a, b$ (an AND gate);
- $\mathrm{or}(a,b)$ for circuits $a, b$ (an OR gate).

**Definition 2.2 (Evaluation).** The value $\mathrm{eval}(C, x) : \mathsf{Bool}$
of a circuit $C$ on an assignment $x$ is defined recursively:
$$
\mathrm{eval}(\mathrm{var}\,i, x) = x_i, \quad
\mathrm{eval}(\top, x) = \mathrm{true}, \quad
\mathrm{eval}(\bot, x) = \mathrm{false},
$$
$$
\mathrm{eval}(\mathrm{and}(a,b), x) = \mathrm{eval}(a,x) \,\&\&\, \mathrm{eval}(b,x), \quad
\mathrm{eval}(\mathrm{or}(a,b), x) = \mathrm{eval}(a,x) \,||\, \mathrm{eval}(b,x).
$$

**Definition 2.3 (Size).** The size $\mathrm{size}(C) \in \mathbb{N}$ counts all
nodes: $\mathrm{size}(\mathrm{var}\,i) = \mathrm{size}(\top) =
\mathrm{size}(\bot) = 1$, and $\mathrm{size}(\mathrm{and}(a,b)) =
\mathrm{size}(\mathrm{or}(a,b)) = \mathrm{size}(a) + \mathrm{size}(b) + 1$.

**Definition 2.4 (Depth).** The depth $\mathrm{depth}(C) \in \mathbb{N}$ is the
longest output-to-leaf path: $\mathrm{depth}$ of a leaf or constant is $0$, and
$\mathrm{depth}(\mathrm{and}(a,b)) = \mathrm{depth}(\mathrm{or}(a,b)) =
\max(\mathrm{depth}(a), \mathrm{depth}(b)) + 1$.

**Definition 2.5 (Variables read).** Assuming decidable equality on $\iota$, the
finite set $\mathrm{vars}(C) \subseteq \iota$ is: $\mathrm{vars}(\mathrm{var}\,i)
= \{i\}$; $\mathrm{vars}(\top) = \mathrm{vars}(\bot) = \emptyset$; and
$\mathrm{vars}(\mathrm{and}(a,b)) = \mathrm{vars}(\mathrm{or}(a,b)) =
\mathrm{vars}(a) \cup \mathrm{vars}(b)$.

**Definition 2.6 (Pointwise order).** For assignments $x, y$, we write $x \le y$
to mean: for all $i$, if $x_i = \mathrm{true}$ then $y_i = \mathrm{true}$.

**Definition 2.7 (Dependence / relevance).** A Boolean function
$f : (\iota \to \mathsf{Bool}) \to \mathsf{Bool}$ **depends on** coordinate $i$,
written $\mathrm{DependsOn}(f, i)$, if there is a background assignment $x$ with
$$
f(x[i \mapsto \mathrm{true}]) \neq f(x[i \mapsto \mathrm{false}]),
$$
where $x[i \mapsto b]$ denotes $x$ updated to take value $b$ at coordinate $i$
(in Lean, $\texttt{Function.update}\ x\ i\ b$). Such an $i$ is called *relevant*.

---

## 3. Structural theorems

### 3.1 Monotonicity

**Theorem 3.1 ($\texttt{eval\_monotone}$).** Let $C$ be a monotone circuit and
$x \le y$. If $\mathrm{eval}(C, x) = \mathrm{true}$ then $\mathrm{eval}(C, y) =
\mathrm{true}$.

*Proof sketch.* Structural induction on $C$. For $\mathrm{var}\,i$ the claim is
exactly the hypothesis $x_i = \mathrm{true} \Rightarrow y_i = \mathrm{true}$. For
$\top$ the output is always $\mathrm{true}$; for $\bot$ the premise
$\mathrm{eval}(\bot, x) = \mathrm{true}$ is false, so the implication is vacuous.
For $\mathrm{and}(a,b)$, if the conjunction is true at $x$ then both conjuncts are
true at $x$, hence (by induction) both at $y$, hence the conjunction at $y$. For
$\mathrm{or}(a,b)$, a true disjunction at $x$ means some disjunct is true at $x$,
hence true at $y$ by induction, hence the disjunction at $y$. $\square$

This theorem is the semantic justification for studying monotone circuits: the
functions they compute are precisely the monotone Boolean functions (the forward
inclusion is Theorem 3.1; the converse, that every monotone function has a
monotone circuit, follows from the disjunctive normal form built from
minterms).

### 3.2 Locality

**Theorem 3.2 ($\texttt{eval\_eq\_of\_agree\_on\_vars}$).** If $x$ and $y$ agree
on every variable in $\mathrm{vars}(C)$ — that is, $x_i = y_i$ for all $i \in
\mathrm{vars}(C)$ — then $\mathrm{eval}(C, x) = \mathrm{eval}(C, y)$.

*Proof sketch.* Structural induction. A leaf $\mathrm{var}\,i$ reads only $i \in
\mathrm{vars}(C) = \{i\}$, so agreement at $i$ gives equal outputs. Constants are
trivial. For $\mathrm{and}(a,b)$ and $\mathrm{or}(a,b)$, since $\mathrm{vars}(a),
\mathrm{vars}(b) \subseteq \mathrm{vars}(a) \cup \mathrm{vars}(b)$, the agreement
hypothesis restricts to each child; the induction hypotheses give
$\mathrm{eval}(a,x) = \mathrm{eval}(a,y)$ and $\mathrm{eval}(b,x) =
\mathrm{eval}(b,y)$, and the gate semantics combine them. $\square$

### 3.3 Relevance implies occurrence

**Theorem 3.3 ($\texttt{dependsOn\_mem\_vars}$).** If
$\mathrm{DependsOn}(\mathrm{eval}(C, \cdot), i)$ then $i \in \mathrm{vars}(C)$.

*Proof sketch.* Contrapositive. Suppose $i \notin \mathrm{vars}(C)$. Take any
background $x$. The two assignments $x[i \mapsto \mathrm{true}]$ and
$x[i \mapsto \mathrm{false}]$ differ only at coordinate $i$, and they agree on
every $j \in \mathrm{vars}(C)$ (since $i \notin \mathrm{vars}(C)$, no read
coordinate equals $i$, and at $j \neq i$ the update does nothing). By Theorem 3.2,
$\mathrm{eval}(C, x[i \mapsto \mathrm{true}]) = \mathrm{eval}(C, x[i \mapsto
\mathrm{false}])$, so flipping $i$ never changes the output and $C$ does not
depend on $i$. $\square$

### 3.4 Variable count bounds size

**Theorem 3.4 ($\texttt{card\_vars\_le\_size}$).** For every circuit $C$,
$|\mathrm{vars}(C)| \le \mathrm{size}(C)$.

*Proof sketch.* Structural induction. A leaf has $|\{i\}| = 1 = \mathrm{size}$.
Constants have $|\emptyset| = 0 \le 1$. For a binary gate with children $a, b$,
$$
|\mathrm{vars}(a) \cup \mathrm{vars}(b)| \le |\mathrm{vars}(a)| +
|\mathrm{vars}(b)| \le \mathrm{size}(a) + \mathrm{size}(b) \le \mathrm{size}(a)
+ \mathrm{size}(b) + 1,
$$
using subadditivity of cardinality on unions and the induction hypotheses.
$\square$

### 3.5 The relevant-variable lower bound

**Theorem 3.5 ($\texttt{card\_le\_size\_of\_relevant}$).** Let $C$ be a circuit
and $R$ a finite set of indices such that every $i \in R$ is relevant to
$\mathrm{eval}(C, \cdot)$. Then $|R| \le \mathrm{size}(C)$.

*Proof sketch.* By Theorem 3.3, $R \subseteq \mathrm{vars}(C)$, so $|R| \le
|\mathrm{vars}(C)|$ by monotonicity of cardinality, and $|\mathrm{vars}(C)| \le
\mathrm{size}(C)$ by Theorem 3.4. Compose. $\square$

This is the first genuine, reusable size lower bound: any function depending on
many inputs requires a proportionally large circuit. While elementary, it is not
vacuous, and it specializes to a concrete quadratic bound for CLIQUE below.

---

## 4. The CLIQUE function and a monotone size lower bound

### 4.1 The edge-variable graph model

We model an undirected graph on vertex set $\mathrm{Fin}\,m = \{0, 1, \dots,
m-1\}$ by its edge-indicator. The natural index type for unordered pairs is
$\mathrm{Sym2}(\mathrm{Fin}\,m)$, the type of unordered pairs of vertices, so an
input assignment is $g : \mathrm{Sym2}(\mathrm{Fin}\,m) \to \mathsf{Bool}$, with
$g(\{u,v\}) = \mathrm{true}$ meaning the edge $\{u,v\}$ is present. The number of
non-loop edges is $\binom{m}{2}$.

**Definition 4.1 (CLIQUE function, $\texttt{cliqueFn}$).** For a parameter $k$,
the function $\mathrm{cliqueFn}_{m,k}(g)$ returns $\mathrm{true}$ iff there exists
a set $S$ of $k$ distinct vertices that is *complete* in $g$: for every pair
$u \neq v$ in $S$, the edge $\{u, v\}$ is present ($g(\{u,v\}) = \mathrm{true}$).
The existential over the finitely many vertex subsets is decidable, so the
function is well defined and computable.

### 4.2 Monotonicity of CLIQUE

**Theorem 4.2 ($\texttt{cliqueFn\_monotone}$).** $\mathrm{cliqueFn}_{m,k}$ is a
monotone function: if $g \le h$ (every edge present in $g$ is present in $h$) and
$\mathrm{cliqueFn}_{m,k}(g) = \mathrm{true}$, then $\mathrm{cliqueFn}_{m,k}(h) =
\mathrm{true}$.

*Proof sketch.* If $S$ is a complete $k$-set in $g$, then for each pair $u \neq v$
in $S$ we have $g(\{u,v\}) = \mathrm{true}$, hence $h(\{u,v\}) = \mathrm{true}$
since $g \le h$. Thus $S$ is complete in $h$ too, witnessing
$\mathrm{cliqueFn}_{m,k}(h) = \mathrm{true}$. $\square$

Consequently CLIQUE is a legitimate target for monotone circuits: by the converse
of Theorem 3.1 it does admit *some* monotone circuit, and we may ask for the
minimal size.

### 4.3 Every edge is relevant for $2$-CLIQUE

**Theorem 4.3 ($\texttt{cliqueFn\_two\_dependsOn}$).** For $k = 2$ and any
non-loop edge $e = \{u,v\}$ with $u \neq v$, the function
$\mathrm{cliqueFn}_{m,2}$ depends on the edge variable $e$.

*Proof sketch.* A $2$-clique is exactly an edge. Take the background assignment
$g_0$ that sets every edge to $\mathrm{false}$ (the empty graph). Then
$g_0[e \mapsto \mathrm{true}]$ is the single-edge graph, which has the complete
pair $\{u,v\}$ and so satisfies $\mathrm{cliqueFn}_{m,2} = \mathrm{true}$, whereas
$g_0[e \mapsto \mathrm{false}] = g_0$ is the empty graph with no edge at all, so
$\mathrm{cliqueFn}_{m,2} = \mathrm{false}$. The two values differ, witnessing
dependence on $e$. $\square$

### 4.4 The quadratic lower bound

**Theorem 4.4 ($\texttt{clique2\_size\_ge\_choose}$).** Any monotone circuit $C$
over the edge variables that computes $\mathrm{cliqueFn}_{m,2}$ has size at least
$\binom{m}{2}$:
$$
\mathrm{eval}(C, \cdot) = \mathrm{cliqueFn}_{m,2} \implies \mathrm{size}(C) \ge
\binom{m}{2}.
$$

*Proof sketch.* Let $R$ be the set of all $\binom{m}{2}$ non-loop edges. By
Theorem 4.3, every $e \in R$ is relevant to $\mathrm{cliqueFn}_{m,2}$, hence
(since $C$ computes this function) relevant to $\mathrm{eval}(C, \cdot)$. By the
relevant-variable lower bound (Theorem 3.5), $|R| \le \mathrm{size}(C)$. Since
$|R| = \binom{m}{2}$, the bound follows. $\square$

This is a genuine (quadratic) unconditional monotone size lower bound. It is the
specialization of the general relevant-variable principle to the simplest CLIQUE
parameter, and it serves as the base case and sanity check for the far deeper
exponential bound discussed next.

---

## 5. The Karchmer–Wigderson correspondence

### 5.1 The monotone KW relation and game

Fix a monotone function $f$. The **monotone Karchmer–Wigderson game** is played
by two cooperating players. Alice receives an input $x$ with $f(x) =
\mathrm{true}$; Bob receives $y$ with $f(y) = \mathrm{false}$. Their goal is to
output a coordinate $i$ such that
$$
x_i = \mathrm{true} \quad\text{and}\quad y_i = \mathrm{false}.
$$
Such an $i$ always exists for monotone $f$: if no coordinate were true in $x$ and
false in $y$, then $x \le y$ on the support, and monotonicity would force $f(y) =
\mathrm{true}$, a contradiction. The **deterministic communication complexity**
of the game is the minimum, over protocols, of the worst-case number of bits
exchanged.

**Theorem 5.1 (separator existence, $\texttt{monotone\_separator\_exists}$).**
For monotone $f$ and any $x, y$ with $f(x) = \mathrm{true}$ and $f(y) =
\mathrm{false}$, there exists a coordinate $i$ with $x_i = \mathrm{true}$ and
$y_i = \mathrm{false}$.

*Proof sketch.* Suppose not. Then for every $i$, $x_i = \mathrm{true}$ implies
$y_i = \mathrm{true}$, i.e. $x \le y$. Monotonicity (Theorem 3.1 at the level of
functions) gives $f(x) = \mathrm{true} \Rightarrow f(y) = \mathrm{true}$,
contradicting $f(y) = \mathrm{false}$. $\square$

### 5.2 Forward direction: depth bounds communication

Let $\mathrm{kwCost}(f)$ denote the communication cost of the KW protocol
obtained by descending the optimal circuit, and let $\mathrm{kwFind}$ be the
explicit search procedure that, given a circuit and a true/false input pair,
walks from the output to a leaf producing a separating coordinate.

**Theorem 5.2 (forward KW, $\texttt{kwCost\_le\_depth}$).** For every monotone
circuit $C$ computing $f$, the KW game admits a protocol whose cost is at most
$\mathrm{depth}(C)$. Hence the deterministic communication complexity of the
monotone KW game for $f$ is at most the minimal monotone circuit depth of $f$.

*Proof sketch.* Induct on the circuit, descending from the output. At the output
of $C$ we have $\mathrm{eval}(C, x) = \mathrm{true}$ and $\mathrm{eval}(C, y) =
\mathrm{false}$. At an OR gate $\mathrm{or}(a,b)$, since $\mathrm{eval}(a,x) \,||\,
\mathrm{eval}(b,x) = \mathrm{true}$, at least one child evaluates to
$\mathrm{true}$ on $x$; Alice announces such a child (one bit). At an AND gate
$\mathrm{and}(a,b)$, since $\mathrm{eval}(a,y) \,\&\&\, \mathrm{eval}(b,y) =
\mathrm{false}$, at least one child evaluates to $\mathrm{false}$ on $y$; Bob
announces such a child (one bit). In both cases the chosen child preserves the
invariant ($\mathrm{true}$ on $x$, $\mathrm{false}$ on $y$). After at most
$\mathrm{depth}(C)$ steps the players reach a leaf $\mathrm{var}\,i$ with $x_i =
\mathrm{true}$ and $y_i = \mathrm{false}$, the desired separator. Total bits:
$\le \mathrm{depth}(C)$. $\square$

### 5.3 The converse (open, formalization target)

The converse direction states that a $c$-bit protocol can be *compiled* into a
depth-$c$ monotone circuit, so that minimal depth *equals* communication
complexity. The construction recursively turns the protocol tree into a circuit:
a node where Alice speaks becomes an OR gate, a node where Bob speaks becomes an
AND gate, and each leaf is labelled by the coordinate the players agreed upon.
Correctness reuses the monotonicity semantics (Theorem 3.1). Formalizing the
converse requires a protocol datatype and an inductive protocol-to-circuit
translation; see Section 7.

---

## 6. Algorithms

We summarize the constructive content as explicit algorithms.

**Algorithm A — Recursive circuit evaluation.** Given a circuit $C$ and an
assignment $x$, compute $\mathrm{eval}(C, x)$ by post-order traversal: evaluate
children, then apply the gate's Boolean operation. Runs in time linear in
$\mathrm{size}(C)$.

**Algorithm B — Relevant-variable size certifier.** Given a target function $f$
(as an oracle) and a candidate set $R$ of indices, verify for each $i \in R$ that
flipping coordinate $i$ on some witness assignment changes $f$. If all checks
pass, $|R|$ is a certified lower bound on the size of any circuit computing $f$
(Theorem 3.5). For $2$-CLIQUE, $R$ is the full edge set and each witness is the
empty graph with a single edge toggled.

**Algorithm C — KW descent (separator search, $\texttt{kwFind}$).** Given a
circuit $C$ computing $f$ and inputs $x$ (true) and $y$ (false), descend from the
output: at an OR gate move to a child true on $x$; at an AND gate move to a child
false on $y$; at a leaf $\mathrm{var}\,i$, return $i$. The returned $i$ satisfies
$x_i = \mathrm{true}, y_i = \mathrm{false}$, and the number of moves is at most
$\mathrm{depth}(C)$, realizing the protocol of Theorem 5.2.

---

## 7. Discussion and future directions

The development above gives a complete and self-contained foundation: monotone
circuits compute exactly the monotone functions, locality holds, relevance forces
occurrence, and the variable count lower-bounds size. The CLIQUE module
instantiates these to a concrete quadratic lower bound for $2$-CLIQUE, and the
Karchmer–Wigderson forward direction connects depth to communication. The deeper
results below build directly on these foundations.

**Razborov's exponential CLIQUE bound (approximation method).** The headline
target is to show that monotone circuits for $k$-CLIQUE require size
$m^{\Omega(\sqrt{k})}$. The proof replaces each gate by an approximator drawn
from a lattice of monotone functions closed under approximate-AND and
approximate-OR; each replacement deletes only a controlled number of positive
test inputs (cliques) and negative test inputs (colorings/independent sets). The
combinatorial heart is the **sunflower lemma**: a large family of small sets
contains a sunflower, which bounds the per-gate approximation error. Because a
small circuit accumulates only a small total error, it cannot separate the
clique-indicators from the independent-set-indicators, a contradiction. The
edge-variable model and the CLIQUE function fixed here are exactly the inputs to
this argument; the missing pieces are a formal sunflower lemma and the closure
structure of the approximator family over
$\mathrm{Sym2}(\mathrm{Fin}\,m) \to \mathsf{Bool}$.

**Karchmer–Wigderson converse.** Compile a $c$-bit protocol into a depth-$c$
monotone circuit, establishing depth $=$ communication complexity. Needs a
protocol datatype and inductive translation; the semantics reuse Theorem 3.1.

**Sensitivity sharpening.** The relevant-variable bound counts globally relevant
variables (one witness input per variable). Counting coordinates simultaneously
sensitive at a *single* input forces edge-disjoint subcircuits, multiplying the
lower bound — strictly improving Theorem 3.5 for functions such as threshold.

**Monotone/non-monotone separation.** Functions like perfect matching or CLIQUE
are conjectured (and, for matching, known) to have polynomial general circuits
but only exponential monotone circuits, showing the inclusion monotone $\subseteq$
general is exponentially lossy.

---

## 8. Conclusion

We have formalized the foundations of monotone Boolean circuit complexity and
derived genuine, unconditional lower bounds from first principles: the
relevant-variable size bound and its quadratic CLIQUE instantiation, alongside
the forward Karchmer–Wigderson correspondence between depth and communication.
These results are individually elementary but collectively form the rigorous
scaffolding on which the celebrated exponential CLIQUE lower bound and the depth
equivalence rest. The foundations are deliberately generic — over an arbitrary
index type — so that the same machinery serves the graph (edge-variable) setting
and any future application.

---

## Appendix: Index of formal results

- $\texttt{eval\_monotone}$ — monotone circuits compute monotone functions (Thm 3.1).
- $\texttt{eval\_eq\_of\_agree\_on\_vars}$ — locality on read variables (Thm 3.2).
- $\texttt{dependsOn\_mem\_vars}$ — relevance implies occurrence (Thm 3.3).
- $\texttt{card\_vars\_le\_size}$ — variable count bounds size (Thm 3.4).
- $\texttt{card\_le\_size\_of\_relevant}$ — relevant-variable size lower bound (Thm 3.5).
- $\texttt{cliqueFn}$ — the CLIQUE Boolean function (Def 4.1).
- $\texttt{cliqueFn\_monotone}$ — CLIQUE is monotone (Thm 4.2).
- $\texttt{cliqueFn\_two\_dependsOn}$ — every edge relevant for $2$-CLIQUE (Thm 4.3).
- $\texttt{clique2\_size\_ge\_choose}$ — quadratic lower bound for $2$-CLIQUE (Thm 4.4).
- $\texttt{monotone\_separator\_exists}$ — KW separator existence (Thm 5.1).
- $\texttt{kwCost\_le\_depth}$ / $\texttt{kwFind}$ — forward KW direction (Thm 5.2, Alg C).
