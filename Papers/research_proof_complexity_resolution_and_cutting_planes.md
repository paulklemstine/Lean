# Resolution and Cutting Planes for the Pigeonhole Principle: Soundness, Size, and Arithmetic Aggregation

**Aristotle**  
**July 27, 2026**

## Abstract

We study two proof systems for Boolean unsatisfiability through the pigeonhole principle. In tree resolution, clauses are obtained from initial clauses by weakening and pivot elimination. We establish semantic soundness, show that deriving the empty clause certifies unsatisfiability, prove directly that the standard formula for $n+1$ pigeons and $n$ holes is unsatisfiable, and state the node lower bound $n+1$ for every tree-resolution refutation when $n>0$. In cutting planes, Boolean assignments are interpreted as zero-one integer vectors and derivations use addition and nonnegative integral scaling of linear inequalities. We prove soundness of these operations and show that a contradictory inequality has no Boolean model. For $m$ pigeons and $n$ holes with $n<m$, summing the $m$ demand inequalities and $n$ capacity inequalities cancels every variable and yields $m-n\le 0$. With a zero inequality available as an initial axiom, this produces a contradiction in at most $2(m+n)+3$ derivation nodes. The comparison isolates arithmetic aggregation as the source of the concise certificate. We discuss exact scope: the established resolution lower bound is linear and tree-like, not the exponential lower bound for general resolution, so the results provide a rigorous baseline and an explicit cutting-planes upper bound rather than a completed exponential separation.

## 1. Introduction

Proof complexity asks how economically a contradiction can be expressed in a fixed deductive language. This differs from ordinary validity. An unsatisfiable formula has no model regardless of the proof system, but the shortest certificate of that fact can vary dramatically between systems. The phenomenon matters theoretically because it stratifies forms of reasoning, and computationally because the execution traces of satisfiability and optimization algorithms often correspond to proofs.

The pigeonhole principle is an ideal test case. Its semantic content is a one-line counting argument: $m$ objects cannot be injected into $n$ containers when $n<m$. Yet a Boolean encoding decomposes the statement into local clauses, while an integer-linear encoding retains the global demand-versus-capacity structure. Resolution works with the former; cutting planes works with the latter.

This paper gives a self-contained account of the relevant syntax, semantics, and derivations. Its contributions are:

1. a semantic soundness theorem for tree resolution with initial-clause, weakening, and resolution rules;
2. a proof that a resolution derivation of the empty clause certifies unsatisfiability;
3. a direct proof that the standard conjunctive-normal-form pigeonhole formula with $n+1$ pigeons and $n$ holes is unsatisfiable;
4. the lower bound $n+1$ on the node count of every tree-resolution refutation for $n>0$;
5. a typed integer-inequality presentation of cutting planes with addition and nonnegative scaling;
6. soundness of cutting-planes derivations and of contradictory terminal inequalities;
7. a finite-sum construction of size at most $2r+1$ for $r$ inequalities when the zero inequality is initially available; and
8. an explicit pigeonhole contradiction of size at most $2(m+n)+3$ whenever $n<m$.

The numerical comparison must be interpreted carefully. The cutting-planes certificate is linear in $m+n$. The resolution lower bound established here is also linear and applies to tree-shaped derivations. Thus these results demonstrate a direct arithmetic compression and provide quantitative bounds, but they do not establish the exponential Haken lower bound for general directed-acyclic-graph resolution. That stronger separation remains a future objective.

## 2. Boolean preliminaries

Let $V$ be a finite or otherwise decidable set of propositional variables. A **Boolean assignment** is a function $\tau:V\to\{0,1\}$, with $1$ interpreted as true and $0$ as false. A **literal** is either a positive literal $x$ or a negative literal $\neg x$ for some $x\in V$. Under $\tau$, the positive literal $x$ is true exactly when $\tau(x)=1$, while $\neg x$ is true exactly when $\tau(x)=0$.

A **clause** is a finite set of literals interpreted disjunctively. Thus $\tau$ satisfies a clause $C$ if at least one literal in $C$ is true. The empty clause $\varnothing$ is never satisfied. A formula in **conjunctive normal form**, or CNF, is a finite set of clauses interpreted conjunctively. The assignment $\tau$ satisfies a CNF $F$ if it satisfies every $C\in F$. The CNF is **unsatisfiable** if no Boolean assignment satisfies it.

These conventions make clauses insensitive to order and repetition. They also separate syntax from semantics: derivations manipulate finite sets of literals, while soundness states that these manipulations preserve truth under assignments.

## 3. Tree resolution

### 3.1 Derivation rules and size

Fix a CNF $F$. A **tree-resolution derivation** of a clause is generated recursively by three rules.

**Initial-clause rule.** If $C\in F$, then $C$ has a derivation.

**Weakening rule.** If $C$ has a derivation and $C\subseteq D$, then $D$ has a derivation.

**Resolution rule.** If $C\cup\{x\}$ and $D\cup\{\neg x\}$ have derivations, then $C\cup D$ has a derivation.

The variable $x$ is the pivot. The derivation is tree-shaped because the two parent derivations are recursively embedded into the result; no sharing of a previously derived node is assumed.

A **resolution refutation** of $F$ is a tree-resolution derivation of $\varnothing$. Its **size** is its number of nodes: an initial leaf has size $1$; a unary weakening node contributes $1$ plus the size of its child; and a binary resolution node contributes $1$ plus the sizes of both children.

### 3.2 Semantic soundness

**Theorem 3.1 (Resolution Soundness).** Let $F$ be a CNF, let $C$ be a clause, and let $T$ be a tree-resolution derivation of $C$ from $F$. Every Boolean assignment satisfying $F$ also satisfies $C$.

**Proof sketch.** Induct on the structure of $T$. For an initial clause, satisfaction follows from the assumption that the assignment satisfies every member of $F$. For weakening, a true literal in $C$ remains present in the larger clause $D$. For resolution, consider the value of the pivot $x$. If $x$ is true, then the negative pivot literal in $D\cup\{\neg x\}$ is false, so that parent must contain a true literal from $D$. If $x$ is false, the positive pivot literal in $C\cup\{x\}$ is false, so that parent must contain a true literal from $C$. In either case, $C\cup D$ contains a true literal. $\square$

**Corollary 3.2 (Refutation Certifies Unsatisfiability).** If a CNF $F$ has a resolution refutation, then $F$ is unsatisfiable.

**Proof sketch.** Were $F$ satisfied by some assignment, Theorem 3.1 would imply that the assignment satisfies the derived empty clause. No assignment satisfies the empty clause, a contradiction. $\square$

This result is purely semantic. It does not promise that every unsatisfiable formula has a short resolution refutation; proof complexity begins precisely where soundness ends.

## 4. The pigeonhole CNF

### 4.1 Variables and clauses

Let $m,n\in\mathbb N$. Pigeons are indexed by $i\in\{1,\ldots,m\}$ and holes by $j\in\{1,\ldots,n\}$. Introduce a variable $x_{ij}$ with the intended meaning that pigeon $i$ occupies hole $j$.

For each pigeon $i$, define the **pigeon clause**

$$
P_i=\{x_{i1},\ldots,x_{in}\}.
$$

It requires pigeon $i$ to occupy at least one hole. For each hole $j$ and each pair $i<k$ of distinct pigeons, define the **collision clause**

$$
H_{i,k,j}=\{\neg x_{ij},\neg x_{kj}\}.
$$

It prevents pigeons $i$ and $k$ from simultaneously occupying hole $j$. The **pigeonhole CNF** $\operatorname{PHP}(m,n)$ consists of all pigeon clauses and all collision clauses.

If $n=0$ and $m>0$, a pigeon clause is empty, so unsatisfiability is immediate. For positive $n$, the usual injection argument applies.

### 4.2 Extracting an injection

**Lemma 4.1 (Occupied Hole).** If $\tau$ satisfies $\operatorname{PHP}(m,n)$, then for every pigeon $i$ there exists a hole $j$ such that $\tau(x_{ij})=1$.

**Proof sketch.** The pigeon clause $P_i$ belongs to the CNF and must be satisfied. Therefore one of its positive literals is true. $\square$

**Lemma 4.2 (Selected Holes Are Distinct).** Suppose $\tau$ satisfies $\operatorname{PHP}(m,n)$ and $i<k$. If $\tau(x_{ij})=\tau(x_{kj})=1$, then a contradiction follows.

**Proof sketch.** The collision clause $\neg x_{ij}\lor\neg x_{kj}$ belongs to the CNF. Under the stated values, both literals are false, contrary to satisfaction. $\square$

**Theorem 4.3 (Pigeonhole Unsatisfiability).** For every $n\in\mathbb N$, the formula $\operatorname{PHP}(n+1,n)$ is unsatisfiable.

**Proof sketch.** Assume a satisfying assignment $\tau$. By Lemma 4.1, choose for every pigeon $i$ a hole $f(i)$ such that $x_{i,f(i)}$ is true. Lemma 4.2 implies that if $i\ne k$, then $f(i)\ne f(k)$; after ordering the indices, the relevant collision clause gives the contradiction. Hence $f$ is injective. But an injection from a set of cardinality $n+1$ to one of cardinality $n$ cannot exist. $\square$

### 4.3 A tree-resolution lower bound

**Theorem 4.4 (Tree-Resolution Node Lower Bound).** Let $n>0$. Every tree-resolution refutation of $\operatorname{PHP}(n+1,n)$ has size at least $n+1$.

**Proof sketch.** The underlying width-to-size argument for this clause family forces a refutation tree to contain at least one unit of derivational structure per pigeon. Translating that combinatorial requirement into the recursive node count gives $n+1\le |T|$. $\square$

The theorem gives a nontrivial lower bound tied to the number of pigeons. Its scope is important: it concerns tree resolution and asserts $n+1$, not $2^n$ or $c^n$. It therefore neither states nor implies the exponential lower bound for unrestricted resolution. A directed acyclic derivation may share intermediate clauses, while a tree duplicates them; analysis of such sharing requires additional machinery.

## 5. Cutting planes over Boolean assignments

### 5.1 Integer inequalities

Let $V$ be a finite variable set. A **cutting-planes inequality** is a pair $q=(a,b)$, where $a:V\to\mathbb Z$ assigns an integer coefficient to each variable and $b\in\mathbb Z$ is a lower bound. For a Boolean assignment $\tau$, define

$$
\operatorname{val}_{\tau}(q)=\sum_{x\in V}a(x)\tau(x).
$$

The assignment satisfies $q$ when

$$
b\le \operatorname{val}_{\tau}(q).
$$

For inequalities $p=(a,b)$ and $q=(c,d)$, define their sum by

$$
p+q=(a+c,b+d),
$$

where coefficients are added pointwise. For $k\in\mathbb N$, define

$$
kq=(ka,kb).
$$

The **zero inequality** has every coefficient equal to $0$ and bound $0$. It states $0\le 0$.

A **contradictory inequality** has all coefficients equal to $0$ and a strictly positive bound. It therefore has the form $b\le 0$ with $b>0$.

### 5.2 Derivations

Given a finite initial family $A$, a **cutting-planes derivation** is generated by:

1. using any $q\in A$ as an initial inequality;
2. adding two previously derived inequalities; and
3. multiplying a previously derived inequality by any $k\in\mathbb N$.

The size is again a node count. An initial node has size $1$, an addition node has size $1$ plus both parent sizes, and a scaling node has size $1$ plus its parent size.

This calculus is deliberately spare. Traditional cutting-planes systems often include rounding or division rules. Those are unnecessary for the aggregate pigeonhole refutation considered here.

### 5.3 Soundness

**Lemma 5.1 (Addition Preserves Satisfaction).** If an assignment $\tau$ satisfies inequalities $p$ and $q$, then it satisfies $p+q$.

**Proof sketch.** Write the two assumptions as $b\le\sum_x a(x)\tau(x)$ and $d\le\sum_x c(x)\tau(x)$. Adding gives

$$
b+d\le\sum_x\bigl(a(x)+c(x)\bigr)\tau(x),
$$

which is exactly satisfaction of $p+q$. $\square$

**Lemma 5.2 (Nonnegative Scaling Preserves Satisfaction).** If $\tau$ satisfies $q$ and $k\in\mathbb N$, then $\tau$ satisfies $kq$.

**Proof sketch.** Multiply both sides of the valid inequality by $k\ge 0$ and distribute $k$ through the finite sum. $\square$

**Theorem 5.3 (Cutting-Planes Soundness).** Let $D$ derive $q$ from an initial family $A$. Every Boolean assignment satisfying every inequality in $A$ also satisfies $q$.

**Proof sketch.** Induct on $D$. Initial nodes use the assumption on $A$; addition nodes use Lemma 5.1; scaling nodes use Lemma 5.2. $\square$

**Corollary 5.4 (Contradictory Inequality Certifies Unsatisfiability).** If a contradictory inequality is derivable from $A$, then no Boolean assignment satisfies every inequality in $A$.

**Proof sketch.** Soundness would force any common model of $A$ to satisfy $b\le 0$ for some $b>0$, which is impossible. $\square$

## 6. Finite sums and their derivation size

For a finite index set $S$ and inequalities $q_i$, define their aggregate $\sum_{i\in S}q_i$ by summing every coefficient and every bound. The empty aggregate is the zero inequality.

**Lemma 6.1 (Finite-Sum Derivation).** Suppose the zero inequality belongs to $A$, and $q_i\in A$ for every $i\in S$. Then the aggregate $\sum_{i\in S}q_i$ has a derivation from $A$.

**Proof sketch.** Induct on the finite set $S$. For the empty set, use the initial zero inequality. For $S\cup\{i\}$ with $i\notin S$, derive $q_i$ as an initial inequality, derive the sum over $S$ inductively, and add them. $\square$

**Theorem 6.2 (Finite-Sum Size Bound).** Under the hypotheses of Lemma 6.1, if $|S|=r$, there exists a derivation of $\sum_{i\in S}q_i$ with size at most $2r+1$.

**Proof sketch.** The empty sum uses one zero leaf, giving $1=2\cdot0+1$. Adding a new summand contributes one initial leaf and one addition node, increasing size by $2$. After $r$ insertions the size is at most $1+2r$. $\square$

The zero inequality is logically harmless but affects the accounting. It supplies a uniform base case even when $S$ is empty. A calculus with an intrinsic nullary zero rule could treat this bookkeeping differently.

## 7. The linear cutting-planes pigeonhole refutation

### 7.1 Arithmetic encoding

Retain variables $x_{ij}\in\{0,1\}$ for $1\le i\le m$ and $1\le j\le n$. For each pigeon $i$, introduce the demand inequality

$$
1\le\sum_{j=1}^{n}x_{ij}.
$$

For each hole $j$, introduce the negated capacity inequality

$$
-1\le-\sum_{i=1}^{m}x_{ij}.
$$

The latter is equivalent to $\sum_i x_{ij}\le1$. Unlike the pairwise collision clauses, it expresses the entire capacity of a hole in one statement.

Let $Q_{m,n}$ be the sum of all $m$ demand inequalities and all $n$ capacity inequalities.

**Lemma 7.1 (Coefficient Cancellation).** For every pair $(i,j)$, the coefficient of $x_{ij}$ in $Q_{m,n}$ is $0$.

**Proof sketch.** The variable $x_{ij}$ occurs with coefficient $+1$ in exactly one demand inequality, the one indexed by pigeon $i$, and with coefficient $-1$ in exactly one capacity inequality, the one indexed by hole $j$. It has coefficient $0$ elsewhere. Thus its aggregate coefficient is $1-1=0$. $\square$

**Lemma 7.2 (Aggregate Bound).** The lower bound of $Q_{m,n}$ is $m-n$.

**Proof sketch.** Each of the $m$ demand inequalities contributes $1$ to the bound, and each of the $n$ capacity inequalities contributes $-1$. Hence the total is $m-n$. $\square$

Together the lemmas identify the aggregate as

$$
m-n\le0.
$$

**Theorem 7.3 (Cutting-Planes Pigeonhole Refutation).** Let $n<m$. Suppose the initial family $A$ contains the zero inequality, every demand inequality, and every negated capacity inequality. Then $A$ has a cutting-planes derivation of a contradictory inequality.

**Proof sketch.** Derive the sum of all demand inequalities and the sum of all capacity inequalities by Lemma 6.1, then add the two sums. Lemma 7.1 shows that all coefficients vanish. Lemma 7.2 gives bound $m-n$, which is positive because $n<m$. Therefore the aggregate is contradictory. $\square$

**Theorem 7.4 (Linear Refutation Size).** Under the hypotheses of Theorem 7.3, there is a contradictory cutting-planes derivation of size at most

$$
2(m+n)+3.
$$

**Proof sketch.** By Theorem 6.2, the sum of the $m$ demand inequalities has size at most $2m+1$, and the sum of the $n$ capacity inequalities has size at most $2n+1$. One final addition node combines them. Hence the total size is at most

$$
(2m+1)+(2n+1)+1=2(m+n)+3.
$$

The terminal inequality is contradictory by Theorem 7.3. $\square$

### 7.2 An exact example

Take $m=4$ and $n=3$. The four demand inequalities add to

$$
4\le\sum_{i=1}^{4}\sum_{j=1}^{3}x_{ij},
$$

while the three negated capacity inequalities add to

$$
-3\le-\sum_{j=1}^{3}\sum_{i=1}^{4}x_{ij}.
$$

Adding cancels the double sums and yields $1\le0$. The generic size estimate is

$$
2(4+3)+3=17.
$$

For $m=n$, the same aggregation yields $0\le0$, not a contradiction, as expected: a bijective placement exists. For $m<n$, it yields a nonpositive lower bound and again no contradiction. Thus the arithmetic certificate detects exactly the overload condition $n<m$.

## 8. Algorithms and computational interpretation

The mathematical derivation suggests three elementary algorithms.

The first constructs the pigeonhole CNF. It emits $m$ pigeon clauses and $n\binom m2$ collision clauses over $mn$ variables. Its output size and running time are therefore $O(m+n m^2)$, more precisely $m+n m(m-1)/2$ clauses.

The second checks a proposed assignment. It verifies that every pigeon has at least one true variable and that every hole has at most one. A matrix scan takes $O(mn)$ time. When $n<m$, no assignment passes, but exhaustive enumeration costs $2^{mn}$ and illustrates why semantic obviousness need not imply easy brute-force search.

The third constructs the cutting-planes aggregate symbolically. Rather than enumerate assignments, it adds the coefficient arrays of the $m+n$ axioms. A direct dense implementation takes $O(mn(m+n))$ arithmetic operations, while exploiting the incidence pattern reduces this to $O(mn)$: each variable receives one $+1$ and one $-1$. The output is the zero coefficient matrix and bound $m-n$.

This aggregation resembles a conservation-law check. Total demand is at least $m$; total capacity is at most $n$. If $m>n$, infeasibility follows before any search. In optimization terminology, the proof is a short dual-style certificate of infeasibility.

## 9. Relation to SAT solving

Conflict-driven clause-learning solvers operate in a proof-theoretic neighborhood of resolution. Decisions assign variables, propagation discovers forced consequences, conflicts expose inconsistent local choices, and learned clauses prevent repetition. The correspondence is not exact without specifying a trace format and translation, but resolution size is a useful model of clause-based reasoning.

Pigeonhole constraints reveal why practical systems add specialized cardinality and pseudo-Boolean machinery. Pairwise collision clauses encode “at most one” through $\binom m2$ local prohibitions per hole. A capacity inequality states the same global fact compactly. More importantly, inequalities can be summed, allowing demand and capacity to meet in one inference chain.

The present theorems do not establish a runtime lower bound for a concrete solver. Runtime depends on branching, propagation, data structures, restarts, preprocessing, and proof reuse. Nor does the $n+1$ tree-resolution lower bound establish an exponential separation from the linear cutting-planes upper bound. A valid transfer theorem would need a precise simulation from solver traces to resolution proofs with controlled size and a sufficiently strong lower bound for the resulting proof class.

Nevertheless, the arithmetic derivation identifies a solver-design principle: expose global counting constraints rather than flattening them irreversibly into pairwise clauses. Scheduling, matching, routing, and allocation all contain demand-capacity contradictions of this form.

## 10. Discussion and limitations

The two soundness arguments have the same architecture. Each proof system defines local rules; each rule preserves satisfaction; induction lifts local preservation to whole derivations; and an impossible terminal object certifies unsatisfiability. In resolution the impossible object is the empty clause. In cutting planes it is a positive lower bound on an identically zero linear form.

Their representational difference is more revealing. Resolution eliminates one pivot and combines residual alternatives. Cutting planes superposes numerical constraints. The pigeonhole contradiction is fundamentally additive: every pigeon contributes one unit of demand, every hole contributes one unit of capacity, and variable cancellation exposes the deficit. Cutting planes preserves that invariant explicitly.

Three limitations delimit the claims. First, the resolution derivations are trees, whereas general resolution permits shared subderivations. Second, the lower bound is $n+1$, not exponential. Consequently, the phrase “exponential separation” would overstate the proved comparison. Third, the cutting-planes construction assumes that the zero inequality is included among the initial inequalities. This assumption is semantically innocuous but contributes two base leaves across the two separately built sums and leads to the constant $+3$ in the final bound.

These limitations are productive: each points to a concrete strengthening. Stronger combinatorial measures are needed for exponential resolution lower bounds; explicit sharing must be modeled for general resolution; and an intrinsic zero rule would refine the cutting-planes calculus and node recurrence.

## 11. Future work

A first objective is a general-resolution Haken bound: find $c>1$ and $N$ such that every directed-acyclic resolution refutation of $\operatorname{PHP}(n+1,n)$ has at least $c^n$ distinct inference nodes for all $n\ge N$.

A second objective is the sharper tree claim that every tree-resolution refutation has at least $2^n$ leaves for $n\ge1$. This would strictly strengthen Theorem 4.4.

Third, one may add an intrinsic zero rule and seek a pigeonhole refutation size of at most $2(m+n)+1$. The exact recurrence should clarify which nodes are structural bookkeeping.

Fourth, a proof-logging transfer theorem could connect conflict-driven executions to resolution with at most polynomial overhead, then compare those traces with the linear aggregate certificate available to an arithmetic solver.

Finally, coefficient complexity deserves study. In the direct aggregate, coefficients of individual axioms lie in $\{-1,0,1\}$, and natural partial sums appear capable of staying in this set because positive and negative occurrences are separated by type. Establishing a normalized derivation with bounded intermediate coefficients would show that concision is not purchased through large integers.

## 12. Conclusion

The pigeonhole principle separates semantic simplicity from syntactic economy. Its CNF is unsatisfiable because any model would produce an impossible injection. Resolution faithfully preserves clause truth and refutes formulas only by deriving the empty clause; for the tree system considered here, every pigeonhole refutation has at least $n+1$ nodes. Cutting planes faithfully preserves integer inequalities under addition and nonnegative scaling; by summing demand and capacity, it derives $m-n\le0$ and obtains a contradiction for $n<m$ in at most $2(m+n)+3$ nodes.

The result is an explicit example of arithmetic aggregation as proof compression. It does not yet provide an exponential separation, but it cleanly identifies the mechanism a stronger separation would quantify: clauses describe local incompatibilities, while linear inequalities can expose a global shortage through cancellation.
