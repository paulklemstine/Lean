# When Counting Becomes a Proof: Pigeons, SAT Solvers, and Two Languages of Contradiction

## A tiny puzzle with a large computational shadow

Imagine checking coats at a theater with fewer hooks than coats. No matter how cleverly the attendant works, two coats must share a hook. This is the pigeonhole principle, usually taught as an almost embarrassingly obvious fact: if $m$ objects are placed into $n$ containers and $n<m$, some container receives at least two objects.

Now ask a different question. Not *is the statement true?*, but *how difficult is it to certify that every proposed exception fails?* That change of viewpoint leads to proof complexity, a meeting point of logic, combinatorics, optimization, and the design of modern satisfiability solvers.

A contradiction may be mathematically simple yet awkward in a particular proof language. Here we compare two such languages. **Resolution** manipulates clauses—lists of alternatives joined by “or”—and reasons locally by eliminating one Boolean variable at a time. **Cutting planes** translates Boolean choices into the integers $0$ and $1$, then adds and rescales linear inequalities. The pigeonhole principle reveals their personalities vividly: resolution sees many local conflicts, while cutting planes sees one global shortage.

The results developed here establish the semantic soundness of both systems, prove that the standard pigeonhole formulas are unsatisfiable, give a guaranteed lower bound of $n+1$ nodes for tree-like resolution refutations with $n+1$ pigeons and $n$ holes, and construct a cutting-planes refutation with at most $2(m+n)+3$ nodes whenever $n<m$. This is a concrete efficiency contrast, although the stated resolution bound is linear rather than the celebrated exponential lower bound known for stronger formulations of the comparison.

## Turning pigeons into Boolean logic

For every pigeon $i$ and hole $j$, introduce a Boolean variable $x_{ij}$. It is true when pigeon $i$ occupies hole $j$. Two kinds of constraints express the puzzle.

First, every pigeon must occupy at least one hole. For a fixed pigeon $i$, this becomes the clause

$$
x_{i1}\lor x_{i2}\lor\cdots\lor x_{in}.
$$

Second, no hole may contain two distinct pigeons. For pigeons $i<k$ and a hole $j$, this becomes

$$
\neg x_{ij}\lor\neg x_{kj}.
$$

The conjunction of all these clauses is the pigeonhole formula. A satisfying assignment would choose at least one hole for each pigeon while forbidding any collision.

Why can no such assignment exist when there are $n+1$ pigeons and $n$ holes? Suppose one did. For each pigeon, select one hole whose variable is true. The collision clauses ensure that distinct pigeons receive distinct selected holes. We would therefore obtain an injection from a set of size $n+1$ into a set of size $n$, which is impossible. This gives the **Pigeonhole Unsatisfiability Theorem**: for every natural number $n$, the clause system for $n+1$ pigeons and $n$ holes has no satisfying Boolean assignment.

Notice what this proof does. It extracts a global map from many local truth values, then defeats that map by counting. The tension between local syntax and global counting will drive everything that follows.

## Resolution: contradiction one variable at a time

A literal is either a variable $x$ or its negation $\neg x$. A clause is a finite disjunction of literals, and a conjunctive normal form formula is a finite conjunction of clauses. Resolution uses three operations in a tree-shaped derivation.

* An initial-clause step may use any clause from the formula.
* A weakening step may enlarge a previously derived clause by adding alternatives.
* A resolution step combines $x\lor C$ with $\neg x\lor D$ and derives $C\lor D$.

The last rule is easy to justify. If $x$ is false, then the first parent must be satisfied by $C$; if $x$ is true, the second must be satisfied by $D$. Either way, $C\lor D$ holds.

This case split proves the **Resolution Soundness Theorem**: every assignment satisfying all initial clauses also satisfies every clause derived by a resolution tree. The proof follows the tree from its leaves upward. Initial clauses are true by assumption; weakening cannot destroy truth; and the two cases for the pivot variable validate resolution.

A resolution refutation is a derivation of the empty clause. The empty clause has no literal that could make it true. Soundness therefore immediately yields the **Resolution Refutation Theorem**: if a conjunctive normal form formula has a resolution refutation, it is unsatisfiable.

Proof size matters. Count one node for each initial clause, weakening, or resolution inference in the derivation tree. For the pigeonhole formula with $n+1$ pigeons and $n$ holes, every tree-resolution refutation has at least $n+1$ nodes whenever $n>0$. This **Tree-Resolution Size Bound** is modest but unconditional: the proof cannot be smaller than the number of pigeons. It should not be mistaken for an exponential Haken bound. Rather, it is the precise lower bound supplied by the present development and a baseline against which richer lower-bound methods can be measured.

The deeper lesson is that resolution’s unit of thought is a clause. Counting is represented only indirectly through a potentially large web of clauses. A solver based on resolution may learn powerful clauses, but each learned statement is still a disjunction describing a local obstruction.

## Cutting planes: make the shortage visible

Cutting planes changes the language. A Boolean assignment is viewed as a vector with coordinates in $\{0,1\}$. An inequality consists of integer coefficients $a_x$ and an integer bound $b$, and means

$$
b\le \sum_x a_x x.
$$

Two inference rules suffice for the results here. Valid inequalities may be added, and a valid inequality may be multiplied by any nonnegative integer $k$. Both rules are sound: adding two true lower bounds gives another true lower bound, and multiplying by $k\ge 0$ preserves order.

A cutting-planes derivation starts from a finite family of inequalities and repeatedly applies these rules. A contradiction is an inequality whose coefficients are all zero but whose bound is positive. Such a statement says

$$
b\le 0\qquad\text{with }b>0,
$$

which no assignment can satisfy. Thus the **Cutting-Planes Soundness Theorem** says that every derived inequality is satisfied by every Boolean assignment satisfying the initial family; consequently, deriving a contradictory inequality proves that the family has no Boolean solution.

The pigeonhole constraints have a particularly clean linear form. For each pigeon $i$ require

$$
1\le \sum_{j=1}^{n}x_{ij}.
$$

For each hole $j$, write the capacity condition with negative coefficients:

$$
-1\le -\sum_{i=1}^{m}x_{ij},
$$

which is equivalent to $\sum_i x_{ij}\le 1$.

Now add every pigeon inequality and every hole inequality. Each variable $x_{ij}$ appears once with coefficient $+1$ and once with coefficient $-1$, so every variable cancels. The bounds add to $m-n$. The aggregate statement is

$$
m-n\le 0.
$$

If $n<m$, then $m-n>0$, and the aggregate is contradictory. The entire impossibility has collapsed into one subtraction.

This gives the **Linear Cutting-Planes Pigeonhole Refutation Theorem**: assume the initial family contains the zero inequality, all $m$ pigeon inequalities, and all $n$ hole inequalities. If $n<m$, there is a cutting-planes derivation of a contradiction with at most

$$
2(m+n)+3
$$

nodes. A finite sum of $r$ inequalities can be built with at most $2r+1$ nodes using the zero inequality as the empty starting sum; constructing the two sums and adding them gives the displayed bound.

## Why proof language matters to computation

SAT solvers are engines for deciding whether enormous Boolean formulas have satisfying assignments. They schedule airline crews, check hardware designs, solve planning problems, and search combinatorial spaces. Many successful solvers are closely related to resolution: when a tentative assignment causes conflict, the solver analyzes the conflict and learns a new clause.

The pigeonhole example warns that local clause learning and global arithmetic reasoning are not interchangeable. An arithmetic solver can sum capacities and demands directly. A purely clause-oriented solver must reconstruct that counting insight through clauses. The present bounds do not by themselves prove an exponential runtime separation for practical solvers: the resolution result here is tree-like and only $n+1$, while real solvers reuse learned information in a directed acyclic graph. Still, the explicit linear cutting-planes certificate illustrates why modern solving systems often combine Boolean search with cardinality constraints, pseudo-Boolean reasoning, integer programming, or specialized propagators.

Consider resource allocation. Variables may say whether job $i$ uses machine $j$. “Every job gets a machine” resembles the pigeon axioms; “each machine handles at most one job” resembles the hole axioms. Summing all demands and capacities immediately detects overload. Similar patterns appear in matching, timetabling, register allocation, packet routing, and bounded scheduling. Whenever a problem says “everyone needs one” and “each resource supplies at most one,” the aggregate inequality is the natural global invariant.

## A map of what is proved—and what remains

Four conclusions form the core story.

First, resolution is semantically reliable: derived clauses preserve truth, so the empty clause certifies unsatisfiability. Second, the standard pigeonhole clause system is genuinely impossible, because any satisfying assignment would induce an injection from $n+1$ pigeons to $n$ holes. Third, a tree-resolution refutation requires at least $n+1$ nodes for $n>0$. Fourth, cutting planes is sound and admits an explicit pigeonhole refutation of size at most $2(m+n)+3$ for $n<m$, provided the harmless zero inequality is among the initial statements.

Several enticing steps lie beyond these conclusions. One is the full exponential lower bound for general directed-acyclic-graph resolution, traditionally associated with Haken’s theorem. Another is an exponential strengthening for tree resolution. A third is to build the empty-sum or zero rule intrinsically, shaving the bookkeeping from the cutting-planes bound. Further work could precisely connect proof lengths to logged executions of conflict-driven solvers and study whether the cutting-planes derivation can always keep coefficients inside $\{-1,0,1\}$.

The pigeonhole principle began as a child’s counting puzzle. In proof complexity it becomes a microscope: it shows that difficulty belongs not only to a statement, but also to the language in which one is required to explain it. Resolution asks a sequence of local either-or questions. Cutting planes adds the ledger and discovers that demand exceeds capacity. Both are sound. But one of them can see the shortage at a glance.
