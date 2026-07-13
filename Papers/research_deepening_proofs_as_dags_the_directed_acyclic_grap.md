# The Topological Structure of Proof Dependency Graphs

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

A mathematical proof induces a directed graph whose nodes are statements and whose
edges encode the direct-dependency relation "$a$ is used in the proof of $b$." The
prohibition against circular argument is precisely the condition that this graph is
*acyclic*: no statement is reachable from itself along a nonempty chain of
dependencies. We develop the topological consequences of this single hypothesis for
a finite collection of statements. Modeling a proof abstractly as an *acyclic
relation* — a binary relation whose transitive closure is irreflexive — we prove a
self-reinforcing chain of results. First, acyclicity forbids cycles of every length,
not merely self-loops and $2$-cycles. Second, the *ancestor set* of a node (the set
of statements reaching it) is strictly monotone along reachability, which yields a
**topological numbering**: an integer rank function that strictly increases along
every dependency. From the extremes of this rank function we obtain the existence of
**foundational (source)** and **capstone (sink)** statements in every nonempty
finite proof graph. Finally, asymmetry of the dependency relation gives a
**sparsity** bound: a proof graph on $n$ statements has at most $n(n-1)/2$ direct
dependencies. We discuss algorithmic realizations, applications to software builds,
scheduling, and spreadsheet evaluation, and outline extensions to antichain
decompositions (proof depth), transitive reduction, weighted critical paths, and a
"spine of mathematics" conjecture.

---

## 1. Introduction

Mathematics is cumulative. Each theorem is established by appeal to earlier
theorems, definitions, and axioms; those in turn rest on still earlier material.
Iterating this observation reveals a global structure: a network in which statements
are connected by the relation of *logical dependency*. Assigning to each statement a
node and drawing an edge from $a$ to $b$ whenever $a$ is invoked in the proof of $b$
produces a **directed graph of proofs**.

This graph is not arbitrary. It obeys one structural law of overwhelming importance:
**there are no circular arguments.** One cannot legitimately prove $A$ from $B$ and
$B$ from $A$; such an argument establishes nothing, since neither statement is ever
grounded. Translated to the graph, this law states that no directed cycle exists —
the graph is a *directed acyclic graph* (DAG).

The present paper asks: *what does acyclicity alone force upon the structure of a
proof?* We answer with a chain of theorems, each building on its predecessors, in
the same cumulative spirit as its subject matter. The results are elementary in
their hypotheses and robust in their reach: they apply verbatim to any finite
acyclic dependency structure, whether it arises from a mathematical theory, a
software module hierarchy, a task schedule, or a spreadsheet.

### Contributions

1. A clean abstract model of a proof as an **acyclic relation** on a finite vertex
   type (Section 2).
2. Proof that acyclicity forbids cycles of *all* lengths via asymmetry of the
   reachability (transitive-closure) relation (Section 3).
3. The **ancestor-set monotonicity** lemma and its consequence, the **Topological
   Numbering Theorem** (Section 4).
4. Existence of **foundational** and **capstone** statements (Section 5).
5. The **Sparsity Theorem**: $2|E| \le n(n-1)$ (Section 6).
6. Algorithms, applications, and future directions (Sections 7–9).

---

## 2. Definitions and model

Throughout, let $V$ be a type of *statements* (the vertices), and let $R$ be a
binary relation on $V$, written $R\,a\,b$ or $a \to b$, meaning **"$a$ is used
directly in the proof of $b$."** We call $R$ the *direct-dependency relation*.

### 2.1 Reachability

To speak of indirect dependency we take the transitive closure of $R$.

**Definition 2.1 (Reachability).** The *reachability relation* is the transitive
closure of $R$, denoted $R^{+}$. Concretely, $R^{+}\,a\,b$ holds iff there is a
nonempty chain
$$ a = x_0 \to x_1 \to \cdots \to x_k = b, \qquad k \ge 1, $$
with each $x_{i} \to x_{i+1}$ an edge of $R$. When $R^{+}\,a\,b$ we say *$a$ reaches
$b$*, or *$a$ is a (strict) ancestor of $b$*.

### 2.2 Acyclicity

**Definition 2.2 (Acyclic relation).** The relation $R$ is **acyclic** if its
reachability relation is irreflexive:
$$ \forall v \in V,\quad \neg\, R^{+}\,v\,v. $$
Equivalently, no statement is reachable from itself along a nonempty chain — there
is no circular argument.

This single condition is the sole hypothesis of the entire development. A finite $V$
together with an acyclic $R$ is our abstract model of a proof: a **proof DAG**.

### 2.3 The ancestor set

**Definition 2.3 (Ancestor / predecessor set).** For $v \in V$, the *ancestor set*
of $v$ is
$$ \mathrm{Anc}(v) \;=\; \{\, u \in V : R^{+}\,u\,v \,\}, $$
the set of all statements that reach $v$. When $V$ is finite this is a finite set,
and its cardinality $|\mathrm{Anc}(v)|$ will serve as our rank function.

We assume from Section 4 onward that $V$ is **finite**.

---

## 3. Acyclicity forbids cycles of every length

We begin with the immediate structural consequences of Definition 2.2. Each follows
from the one before.

**Proposition 3.1 (No self-loops).** If $R$ is acyclic then $R\,v\,v$ fails for
every $v$.

*Proof.* A single edge $v \to v$ is a nonempty chain, so it witnesses
$R^{+}\,v\,v$, contradicting acyclicity. $\square$

**Proposition 3.2 (Asymmetry of $R$).** If $R$ is acyclic and $R\,a\,b$, then
$R\,b\,a$ fails.

*Proof.* From $a \to b$ and $b \to a$ we form the chain $a \to b \to a$, a witness
of $R^{+}\,a\,a$, contradicting acyclicity. $\square$

**Theorem 3.3 (Asymmetry of reachability).** If $R$ is acyclic and $R^{+}\,a\,b$,
then $R^{+}\,b\,a$ fails. Reachability points in one consistent direction.

*Proof.* If both $R^{+}\,a\,b$ and $R^{+}\,b\,a$ held, transitivity of the
transitive closure would give $R^{+}\,a\,a$, contradicting acyclicity. $\square$

Theorem 3.3 is the strongest of the three and the workhorse of what follows: it
rules out directed cycles of *arbitrary* length, not merely of length $1$ or $2$.

---

## 4. Monotone ancestor sets and the topological numbering

We now assume $V$ is finite. The technical heart of the paper is that reachability
enlarges the ancestor set *strictly*.

**Lemma 4.1 (Ancestors are captured by reachability).** If $R^{+}\,a\,b$ then
$a \in \mathrm{Anc}(b)$.

*Proof.* Immediate from the definition of $\mathrm{Anc}(b)$: $a$ reaches $b$. $\square$

**Lemma 4.2 (Monotonicity).** If $R^{+}\,a\,b$ then
$\mathrm{Anc}(a) \subseteq \mathrm{Anc}(b)$.

*Proof.* Let $u \in \mathrm{Anc}(a)$, so $R^{+}\,u\,a$. Combining with
$R^{+}\,a\,b$ via transitivity gives $R^{+}\,u\,b$, i.e. $u \in \mathrm{Anc}(b)$.
$\square$

**Lemma 4.3 (No node is its own ancestor).** If $R$ is acyclic then
$a \notin \mathrm{Anc}(a)$ for every $a$.

*Proof.* Membership $a \in \mathrm{Anc}(a)$ means $R^{+}\,a\,a$, forbidden by
acyclicity. $\square$

**Lemma 4.4 (Strict monotonicity).** If $R$ is acyclic and $R^{+}\,a\,b$, then
$\mathrm{Anc}(a) \subsetneq \mathrm{Anc}(b)$.

*Proof.* Containment $\mathrm{Anc}(a) \subseteq \mathrm{Anc}(b)$ is Lemma 4.2. The
containment is proper because $a$ separates the two sets: $a \in \mathrm{Anc}(b)$ by
Lemma 4.1 (since $a$ reaches $b$), while $a \notin \mathrm{Anc}(a)$ by Lemma 4.3.
$\square$

We can now manufacture the rank function promised in the introduction.

**Theorem 4.5 (Topological Numbering Theorem).** Let $R$ be an acyclic relation on a
finite type $V$. Then there is a rank function $f : V \to \mathbb{N}$ such that
$$ R^{+}\,a\,b \;\Longrightarrow\; f(a) < f(b) \qquad \text{for all } a,b \in V. $$
In particular $f(a) < f(b)$ for every direct edge $R\,a\,b$.

*Proof.* Define $f(v) = |\mathrm{Anc}(v)|$. If $R^{+}\,a\,b$ then by Lemma 4.4
$\mathrm{Anc}(a) \subsetneq \mathrm{Anc}(b)$, and a proper subset of a finite set has
strictly smaller cardinality, so $f(a) < f(b)$. The direct-edge form follows because
each edge $R\,a\,b$ yields $R^{+}\,a\,b$. $\square$

The rank $f$ is a *topological numbering* (equivalently, a linear extension) of the
dependency order. It certifies that every finite proof can be laid out on the
integer line with all dependencies pointing upward — the abstract justification for
the existence of a valid teaching order, compilation order, or evaluation order.

---

## 5. Foundations and capstones

The extremes of the rank function are meaningful landmarks. A **source** is a
statement with no incoming dependency; a **sink** is one with no outgoing
dependency.

**Theorem 5.1 (Foundation Theorem — existence of a source).** Let $R$ be acyclic on
a finite *nonempty* type $V$. Then there exists $v \in V$ such that no $u$ satisfies
$R\,u\,v$.

*Proof.* Let $f$ be the rank function of Theorem 4.5. Since $V$ is finite and
nonempty, $f$ attains a minimum at some $v$. If some $u$ satisfied $R\,u\,v$ then
$f(u) < f(v)$, contradicting minimality of $f(v)$. Hence $v$ has no incoming edge.
$\square$

**Theorem 5.2 (Capstone Theorem — existence of a sink).** Let $R$ be acyclic on a
finite nonempty type $V$. Then there exists $v \in V$ such that no $u$ satisfies
$R\,v\,u$.

*Proof.* Symmetric: take $v$ maximizing $f$. If $R\,v\,u$ held then $f(v) < f(u)$,
contradicting maximality. $\square$

A source is an axiom-like statement, the bedrock of the theory; a sink is a capstone
result, used by nothing further. Both exist *unconditionally* in any nonempty finite
proof DAG — they are consequences of acyclicity, not features one must arrange.

---

## 6. Sparsity of proof graphs

We finally bound the number of edges. Write $n = |V|$ for the number of statements
and let $E = \{\, (a,b) : R\,a\,b \,\}$ be the set of direct-dependency edges, with
$|E|$ its cardinality.

**Theorem 6.1 (Sparsity Theorem).** If $R$ is acyclic on a finite type $V$ with
$n = |V|$, then
$$ 2\,|E| \;\le\; n(n-1), \qquad\text{equivalently}\qquad |E| \le \binom{n}{2} = \frac{n(n-1)}{2}. $$

*Proof.* Fix the rank function $f$ of Theorem 4.5. Partition the ordered pairs of
*distinct* vertices into
$$ A = \{(a,b) : f(a) < f(b)\}, \qquad B = \{(a,b) : f(b) < f(a)\}. $$
The map $(a,b) \mapsto (b,a)$ is a bijection between $A$ and $B$, so $|A| = |B|$.
Their disjoint union is exactly the set of ordered pairs $(a,b)$ with $a \neq b$ —
every such pair has $f(a) \ne f(b)$ or $f(a) = f(b)$; but pairs with distinct
vertices need not have distinct ranks in general, so more precisely $A$ and $B$ are
disjoint subsets of the $n(n-1)$ ordered pairs of distinct vertices, giving
$|A| + |B| \le n(n-1)$, hence $|A| \le n(n-1)/2$.

Now every edge $(a,b) \in E$ satisfies $f(a) < f(b)$ by Theorem 4.5, so
$E \subseteq A$. Therefore
$$ |E| \le |A| \le \frac{n(n-1)}{2}, $$
which rearranges to $2|E| \le n(n-1)$. $\square$

The bound is the directed analogue of the classical fact that a simple undirected
graph on $n$ vertices has at most $\binom{n}{2}$ edges. Here it expresses that a
*consistently directed* dependency structure cannot be dense: at most one of the two
possible arrows between any pair of statements can occur, so at least half of all
potential connections are necessarily absent. Reasoning is intrinsically economical.

---

## 7. Algorithms

The proofs above are constructive and translate directly into standard algorithms on
DAGs.

### 7.1 Rank by ancestor count

Theorem 4.5 defines $f(v) = |\mathrm{Anc}(v)|$. Computing all ancestor sets is a
reachability computation: form the transitive closure (e.g. by repeated
breadth-first search from each node, or by the Floyd–Warshall closure) and count, for
each $v$, the number of nodes reaching it. This runs in $O(n \cdot (n+m))$ time via
$n$ backward searches, where $m = |E|$.

### 7.2 Kahn's algorithm for topological ordering

For most applications the ancestor-count rank is more than needed; any linear
extension suffices. **Kahn's algorithm** repeatedly removes a source (a node of
in-degree $0$, guaranteed to exist by Theorem 5.1), appends it to the order, and
deletes its outgoing edges. It produces a topological order in $O(n+m)$ time and
*detects cycles*: if the graph is nonempty but no source exists, the relation is not
acyclic. This is the operational form of the Foundation Theorem.

### 7.3 Longest chain (proof depth / critical path)

Processing nodes in topological order and setting
$\mathrm{depth}(v) = 1 + \max\{\mathrm{depth}(u) : u \to v\}$ (with the max over the
empty set equal to $0$) computes the length of the longest dependency chain ending at
each node in $O(n+m)$ time. The global maximum is the **proof depth**, a measure of
how many layers of reasoning the deepest theorem requires — the critical path of the
proof.

---

## 8. Applications

The abstract model applies to any acyclic dependency structure.

- **Software builds.** Modules import other modules; the import graph is a proof DAG.
  Theorem 4.5 guarantees a valid compilation order exists; Kahn's algorithm produces
  it; a detected cycle is a build-breaking circular import. Sources are base
  libraries; sinks are top-level executables.
- **Spreadsheets.** Cell formulas depend on other cells. A circular reference is a
  cycle, and the evaluation engine's error message is a runtime detection of the
  violation of acyclicity. The topological order is the recomputation order.
- **Project scheduling (PERT/CPM).** Tasks depend on predecessors; a topological
  order is a feasible schedule, the sink is the final deliverable, and the longest
  weighted chain (Section 7.3) is the critical path fixing the minimum makespan.
- **Version control and data pipelines.** Commit graphs and data-transformation
  pipelines are acyclic by construction, and depend on the same ordering guarantees.
- **Curriculum design.** A syllabus is a topological numbering of a prerequisite
  graph: the rank function is a valid order in which to teach the material.

In every case the same minimal hypothesis — no cycles — yields the same dividends: a
consistent order, guaranteed endpoints, and a hard sparsity ceiling.

---

## 9. Discussion and future directions

We highlighted the *topological* structure forced by acyclicity. Several natural
extensions remain.

- **Antichains and Dilworth/Mirsky (proof depth).** The rank function partitions the
  DAG into layers, an antichain decomposition. Mirsky's theorem asserts the longest
  chain equals the minimum number of antichains needed to cover the graph,
  quantifying proof depth precisely.
- **Unique topological order.** A proof DAG has a *unique* topological numbering
  exactly when its reachability relation is a total order — equivalently when the DAG
  has a Hamiltonian path threading all statements in a single line of dependency.
- **Transitive reduction.** Every finite DAG has a unique minimal edge set with the
  same reachability — its *essential dependencies*. Isolating this set distinguishes
  the load-bearing steps of a proof from the redundant ones.
- **Weighted / cost DAGs.** Attaching proof-length weights to edges and studying the
  critical (longest weighted) path models the total verification cost of a body of
  work.
- **The spine of mathematics.** Extending to the global dependency graph, one
  conjectures that mathematics concentrates on a small *spine* of foundational hubs
  through which a large fraction of all reasoning passes. Combining the Foundation
  Theorem (existence of sources) with hub-fragility phenomena would formalize and
  test this "backbone" hypothesis.

## 10. Conclusion

From the single premise that proofs cannot be circular, we derived that every finite
body of mathematics can be ranked by an integer topological numbering, must possess
foundational and capstone statements, and can contain at most $n(n-1)/2$ direct
dependencies. These results are simultaneously statements about the architecture of
mathematical knowledge and about any acyclic dependency structure in computation and
planning. The prohibition on circular argument, far from being a mere hygienic rule,
is a powerful structural principle that shapes the whole edifice it governs.
