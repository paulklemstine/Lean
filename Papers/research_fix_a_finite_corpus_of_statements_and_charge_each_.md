# Fitness Landscapes of Mathematical Theories: A Dependency-Adjusted Cost Model and Its Extremal Structure

**Author:** Aristotle
**Date:** 2026-08-06

## Abstract

We introduce a cost model for mathematical developments in which a
development is charged for the *transitive closure of its dependencies*, each
declaration paid for exactly once, and rewarded for the number of statements it
proves from a fixed finite corpus. The resulting ratio — *dependency-adjusted
fitness* — makes several long-standing folk beliefs about mathematical libraries
into precise, provable statements. We establish: (i) canonicity of the cost
model, via existence and minimality of transitive dependency closures and the
lattice structure of dependency-closed sets, together with the exact
inclusion–exclusion identity $\mathrm{cost}(T\cup U) + \mathrm{cost}(T\cap U) =
\mathrm{cost}(T) + \mathrm{cost}(U)$; (ii) an ordinal reduction showing that on a
fixed corpus size fitness is the reverse order of cost, hence a *finite maximum
principle*; (iii) a **dependency-adjusted global champion theorem** — for a fixed
proof system, the canonical transitive closure of the corpus' proof bases is a
fitness maximum over the entire class of dependency-closed developments proving
the corpus, and is unique up to cost — together with an exact $k$-fold reuse
identity $\mathrm{cost}(\mathrm{library}) + k\cdot c = \sum_i
\mathrm{cost}(\mathrm{specialist}_i) + c$ quantifying the saving as $k-1$ copies
of the shared core; (iv) an adversarial boundary showing that with two
inequivalent proof routes canonicity fails outright — two cost-equal champions
with disjoint closures — while *existence* of a minimum-cost cover survives;
(v) an exact **composition phase transition**: pooling two developments strictly
increases fitness if and only if the adapter cost is strictly below the shared
dependency mass, with a dimensionless density formulation, and a multiplicative
criterion under which a product corpus makes composition profitable regardless
of adapter cost; (vi) exact candidate counts underpinning the multiplicative
regime — closed-subset counts multiply across independent splits, giving $2^n$
for $n$ independent declarations and exactly $n+1$ for a chain; (vii) a
**quantitative adapter valley theorem**: every semantics-preserving migration
between developments over inequivalent interfaces contains an intermediate state
overshooting the smaller endpoint by at least the fixed positive fraction
$(\alpha-\beta)/(1+\beta)$; (viii) a **style-centre theorem** yielding strict
local maxima and a computed three-style metastable landscape; and (ix) a **no
universal maximum theorem**: in any language admitting conservative inflation at
sublinear marginal source cost, raw theorem-per-line fitness is unbounded and
its unbounded witnesses are semantically inert, giving a sharp dichotomy in
which resource normalisation is the decisive hypothesis.

**Keywords.** dependency closure, fitness landscape, theory comparison, reuse,
phase transition, metastability, local maxima, cost model.

---

## 1. Introduction

### 1.1 Motivation

Practitioners who build large mathematical libraries hold strong, largely
untested beliefs about the economics of their subject. Abstraction is said to pay for itself.
Merging two libraries is said to be worth it only when they overlap enough.
Migrating a development from one abstraction layer to another is said to get
worse before it gets better. Algebraic, analytic and combinatorial treatments of
the same material are said to persist because each is locally optimal in its own
idiom. And efficiency metrics of the form "theorems per line" are said to be
gameable.

Each of these is an assertion about the shape of a landscape whose points are
developments and whose height is some notion of efficiency. This paper fixes a
cost model precise enough to make each assertion a theorem, and then proves the
theorems.

### 1.2 The modelling decision

Everything turns on how cost is charged. Counting only the lines of a
development ignores the tower of prior material it rests on, and so flatters
whichever development leans on the largest tower. Charging naively for that
tower, on the other hand, double-counts material used by two parts of the same
development, and so punishes exactly the reuse one wants to measure.

The resolution adopted here is to charge for the **transitive dependency
closure**, each declaration exactly once. This is not one choice among many: we
show in §2 that the transitive closure is canonical (it is the *least*
dependency-closed superset of a base), and that dependency-closed sets form a
lattice, so that "the material shared by two developments" is itself a
well-defined body of mathematics. That is precisely what licenses charging
shared dependencies once.

### 1.3 Contributions and structure

§2 develops the cost model and proves its canonicity. §3 reduces fitness
comparison to cost comparison and derives the finite maximum principle. §4
proves the global champion theorem in the fixed-route model, together with the
exact $k$-fold reuse identity. §5 delineates the adversarial boundary where
canonicity fails and shows existence survives. §6 proves the composition phase
transition in absolute, density, and multiplicative forms. §7 supplies exact
candidate counts. §8 proves the adapter-valley and style-centre theorems and
exhibits a metastable landscape. §9 proves the no-universal-maximum theorem and
the normalisation dichotomy. §10 discusses algorithms; §11, applications; §12,
limitations and future work.

---

## 2. The cost model

### 2.1 Declarations, dependencies and closure

Fix a countable set of **declarations**, identified with $\mathbb{N}$. Two data
are given:

* a **source-length function** $\ell : \mathbb{N} \to \mathbb{N}$, where
  $\ell(i)$ is the number of lines (or tokens, or any additive resource
  measure) of declaration $i$;
* a **dependency function** $\mathrm{deps} : \mathbb{N} \to \mathcal{P}_{\mathrm{fin}}(\mathbb{N})$,
  where $\mathrm{deps}(i)$ is the finite set of declarations directly used by
  $i$.

**Definition 2.1 (Dependency-closed set).** A finite set $S \subseteq \mathbb{N}$
is *dependency-closed* if $\mathrm{deps}(i) \subseteq S$ for every $i \in S$.

Dependency-closed sets are the bodies of mathematics with no dangling
references. The following is immediate but structurally decisive.

**Proposition 2.2 (Lattice property).** If $S$ and $T$ are dependency-closed, so
are $S \cup T$ and $S \cap T$.

*Proof.* For the union, if $i \in S$ then $\mathrm{deps}(i) \subseteq S \subseteq
S \cup T$, and symmetrically. For the intersection, if $i \in S \cap T$ then
$\mathrm{deps}(i) \subseteq S$ and $\mathrm{deps}(i) \subseteq T$, hence
$\mathrm{deps}(i) \subseteq S \cap T$. $\square$

Proposition 2.2 is what makes the phrase "the dependencies shared by two
developments" meaningful as a body of mathematics rather than as a mere set of
identifiers.

**Definition 2.3 (Expansion step).** Put $\sigma(S) = S \cup \bigcup_{i \in S}
\mathrm{deps}(i)$.

**Lemma 2.4.** $S \subseteq \sigma(S)$; $\sigma(S) = S$ if and only if $S$ is
dependency-closed; and if $T$ is dependency-closed with $S \subseteq T$ then
$\sigma(S) \subseteq T$.

*Proof.* The first claim is by construction. For the second, if $\sigma(S) = S$
and $i \in S$, $j \in \mathrm{deps}(i)$, then $j \in \sigma(S) = S$; conversely
closedness makes every added element already present. For the third, an element
of $\sigma(S)$ is either in $S \subseteq T$ or lies in $\mathrm{deps}(i)$ for
some $i \in S \subseteq T$, hence in $T$ by closedness. $\square$

**Definition 2.5 (Transitive closure).** Let $U$ be a finite *universe* of
declarations and $B \subseteq U$ a **base**. Define
$$\mathrm{cl}_U(B) = \sigma^{|U|+1}(B),$$
the result of iterating $\sigma$ one more time than $U$ has elements.

**Theorem 2.6 (Canonicity of the closure).** Let $U$ be dependency-closed and
$B \subseteq U$. Then:

1. $B \subseteq \mathrm{cl}_U(B) \subseteq U$;
2. $\mathrm{cl}_U(B)$ is dependency-closed;
3. (*minimality*) if $T$ is any dependency-closed set with $B \subseteq T$, then
   $\mathrm{cl}_U(B) \subseteq T$.

*Proof.* (1) Monotonicity of $\sigma$ (Lemma 2.4) gives an increasing chain
starting at $B$; each iterate stays inside $U$ by Lemma 2.4's third clause
applied to the dependency-closed set $U$. (3) The same clause, applied
inductively to $T$, shows every iterate $\sigma^k(B)$ lies in $T$. (2) Suppose
$\sigma$ did not fix $\sigma^{|U|+1}(B)$. Then no earlier iterate is a fixed
point either — a fixed point propagates forward — so the chain
$\sigma^0(B) \subsetneq \sigma^1(B) \subsetneq \cdots \subsetneq \sigma^{|U|+1}(B)$
is strictly increasing, forcing $|\sigma^{|U|+1}(B)| \ge |U|+1$, contradicting
$\sigma^{|U|+1}(B) \subseteq U$. $\square$

Clause (3) is what makes the cost model *canonical*: the closure is not one of
several reasonable completions but the unique least one, so no modelling freedom
remains once $\mathrm{deps}$ is fixed.

### 2.2 Theories, cost, fitness

**Definition 2.7 (Theory).** A **theory** (a development) $T$ consists of a
finite set $\mathrm{cl}(T) \subseteq \mathbb{N}$, the transitive dependency
closure of everything it uses, and a finite set $\mathrm{pr}(T) \subseteq
\mathbb{N}$ of corpus statements it proves.

**Definition 2.8 (Cost, fitness).**
$$\mathrm{cost}_\ell(T) = \sum_{i \in \mathrm{cl}(T)} \ell(i), \qquad
\mathrm{fit}_\ell(T) = \frac{|\mathrm{pr}(T)|}{\mathrm{cost}_\ell(T)} \in \mathbb{Q}.$$

**Definition 2.9 (Merge).** $T \sqcup U$ has closure $\mathrm{cl}(T) \cup
\mathrm{cl}(U)$ and proves $\mathrm{pr}(T) \cup \mathrm{pr}(U)$.

**Proposition 2.10 (Monotonicity).** $\mathrm{cl}(T) \subseteq \mathrm{cl}(U)$
implies $\mathrm{cost}_\ell(T) \le \mathrm{cost}_\ell(U)$.

**Theorem 2.11 (Exact merge accounting).** For all theories $T, U$,
$$\mathrm{cost}_\ell(T \sqcup U) + \sum_{i \in \mathrm{cl}(T)\cap\mathrm{cl}(U)} \ell(i)
 \;=\; \mathrm{cost}_\ell(T) + \mathrm{cost}_\ell(U).$$
In particular $\mathrm{cost}_\ell(T \sqcup U) \le \mathrm{cost}_\ell(T) +
\mathrm{cost}_\ell(U)$: merging never costs more than duplicating, and the saving
is exactly the shared dependency mass.

*Proof.* Inclusion–exclusion for sums of nonnegative weights over finite sets.
$\square$

We write $\mathrm{shared}_\ell(T,U) = \sum_{i \in \mathrm{cl}(T)\cap\mathrm{cl}(U)}\ell(i)$.

---

## 3. Ordinal reduction and the finite maximum principle

**Theorem 3.1 (Fitness is inverse cost).** Let $T, U$ be theories with
$|\mathrm{pr}(T)| = |\mathrm{pr}(U)| > 0$ and $\mathrm{cost}_\ell(T),
\mathrm{cost}_\ell(U) > 0$. Then
$$\mathrm{fit}_\ell(T) \le \mathrm{fit}_\ell(U) \iff \mathrm{cost}_\ell(U) \le \mathrm{cost}_\ell(T),$$
and likewise with $\le$ replaced by $<$ throughout.

*Proof.* With a common positive numerator $n$, the map $c \mapsto n/c$ is
strictly decreasing on the positive rationals; the strict version follows by
negating the non-strict one in both directions. $\square$

Theorem 3.1 is deflating in a productive way: on a fixed corpus size, *nothing*
about the corpus matters except its cardinality, and every fitness comparison
reduces to a single integer measurement. All subsequent extremal results are
proved by exhibiting cost inequalities and invoking Theorem 3.1.

**Theorem 3.2 (Finite maximum principle).** Let $F$ be a nonempty finite index
set and $T_\bullet : F \to \{\text{theories}\}$. Then there is $b \in F$ with
$\mathrm{fit}_\ell(T_a) \le \mathrm{fit}_\ell(T_b)$ for all $a \in F$.

*Proof.* A nonempty finite set of rationals attains its maximum. $\square$

The triviality of Theorem 3.2 is the point: *existence* of a champion is free
once the comparison class is finite. Everything substantive concerns *which*
theory is the champion, and — as §9 shows — what happens when the comparison
class is not finite.

---

## 4. The dependency-adjusted global champion

### 4.1 $k$-fold reuse: an exact identity

Fix a finite index set $F$ with $|F| = k$, a **core** $C \subseteq \mathbb{N}$,
and pairwise-disjoint **private blocks** $P_i \subseteq \mathbb{N}$ ($i \in F$),
each disjoint from $C$. Write $c = \sum_{x \in C} \ell(x)$.

* The **shared library** is the theory with closure $C \cup \bigcup_{i \in F} P_i$
  proving the whole corpus.
* The **specialist** for block $i$ is the theory with closure $C \cup P_i$,
  which (as part of the suite) contributes to proving the whole corpus.

**Theorem 4.1 (Exact reuse accounting).**
$$\mathrm{cost}_\ell(\mathrm{library}) + k\,c \;=\; \sum_{i \in F} \mathrm{cost}_\ell(\mathrm{specialist}_i) + c.$$

*Proof.* By disjointness of $C$ from $\bigcup_i P_i$ and pairwise disjointness of
the $P_i$,
$$\mathrm{cost}_\ell(\mathrm{library}) = c + \sum_{i \in F}\sum_{x \in P_i}\ell(x),$$
while $\sum_{i\in F}\mathrm{cost}_\ell(\mathrm{specialist}_i) = k c + \sum_{i\in
F}\sum_{x\in P_i}\ell(x)$. Subtracting gives the identity. $\square$

Equivalently: **pooling $k$ specialists saves exactly $k-1$ copies of the core.**
The saving is an identity, not an estimate.

**Corollary 4.2 (Strict domination).** If $k \ge 2$ and $c > 0$, then
$\mathrm{cost}_\ell(\mathrm{library}) < \sum_{i\in F}\mathrm{cost}_\ell(\mathrm{specialist}_i)$,
and hence, on a nonempty corpus, the library's fitness strictly exceeds the
pooled fitness of the specialist suite.

*Proof.* Theorem 4.1 gives library cost $= \sum_i \mathrm{cost}_\ell(\mathrm{spec}_i) - (k-1)c$
and $(k-1)c > 0$; apply Theorem 3.1. $\square$

### 4.2 The canonical library is a global champion

**Definition 4.3 (Proof system).** A *proof system* $P$ assigns to each
declaration its direct dependencies $\mathrm{deps}_P$ and to each statement $s$
the finite set $\mathrm{base}_P(s)$ of declarations its chosen proof consumes. A
theory $T$ *proves* $s$ if $\mathrm{base}_P(s) \subseteq \mathrm{cl}(T)$, and
*covers* a corpus $\Gamma$ if it proves every $s \in \Gamma$.

**Definition 4.4 (Canonical library).** Relative to a universe $U$, the
canonical library for $\Gamma$ is the theory with closure
$$K = \mathrm{cl}_U\Big(\bigcup_{s\in\Gamma}\mathrm{base}_P(s)\Big)$$
proving $\Gamma$.

**Lemma 4.5.** The canonical library covers $\Gamma$.

*Proof.* $\mathrm{base}_P(s) \subseteq \bigcup_{t\in\Gamma}\mathrm{base}_P(t)
\subseteq K$ by Theorem 2.6(1). $\square$

**Lemma 4.6 (Universal embedding).** If $T$ is dependency-closed and covers
$\Gamma$, then $K \subseteq \mathrm{cl}(T)$.

*Proof.* Covering gives $\bigcup_{s\in\Gamma}\mathrm{base}_P(s) \subseteq
\mathrm{cl}(T)$; minimality (Theorem 2.6(3)) then gives $K \subseteq
\mathrm{cl}(T)$. $\square$

**Theorem 4.7 (Dependency-adjusted global champion).** Let $\Gamma$ be nonempty
and suppose the canonical library has positive cost. Then for *every*
dependency-closed theory $T$ with $\mathrm{pr}(T) = \Gamma$ that covers
$\Gamma$,
$$\mathrm{fit}_\ell(T) \le \mathrm{fit}_\ell(\text{canonical library}).$$

*Proof.* Lemma 4.6 gives $K \subseteq \mathrm{cl}(T)$, hence by Proposition 2.10
the canonical cost is at most $\mathrm{cost}_\ell(T)$; both corpora are $\Gamma$,
so Theorem 3.1 applies. $\square$

Note that the class quantified over is *unbounded*: this is not an instance of
the finite maximum principle but a genuine global statement.

**Theorem 4.8 (Uniqueness up to cost).** Under the hypotheses of Theorem 4.7,
any covering dependency-closed $T$ with $\mathrm{pr}(T) = \Gamma$ and
$\mathrm{fit}_\ell(\text{canonical}) \le \mathrm{fit}_\ell(T)$ satisfies
$\mathrm{cost}_\ell(T) = \mathrm{cost}_\ell(\text{canonical})$.

*Proof.* Combine Theorem 4.7's cost inequality with the reverse one supplied by
Theorem 3.1 applied to the assumed fitness inequality. $\square$

Theorem 4.7 is the precise content of the *dependency-adjusted global champion
conjecture*: once the corpus, the cost model, and the proof routes are fixed,
the mature shared library — the canonical closure of the corpus' proof bases —
is the champion, and extensive reuse provably outweighs the local cost of
general abstractions.

---

## 5. The boundary: alternative proof routes

Theorem 4.7 assumed a *fixed route* per statement. Real mathematics offers
alternatives, and canonicity is fragile under them.

**Theorem 5.1 (No canonical champion with two routes).** There exist theories
$R_1, R_2$ and a length function such that $R_1$ and $R_2$ prove the same
one-statement corpus with equal fitness, yet
$$\mathrm{cl}(R_1) \not\subseteq \mathrm{cl}(R_2), \quad \mathrm{cl}(R_2)\not\subseteq \mathrm{cl}(R_1), \quad \mathrm{cl}(R_1)\cap\mathrm{cl}(R_2) = \varnothing.$$

*Proof.* Take $\ell \equiv 1$, corpus $\{0\}$, $\mathrm{cl}(R_1) = \{1\}$,
$\mathrm{cl}(R_2) = \{2\}$. Both have cost $1$ and fitness $1$; the closures are
singletons of distinct elements. $\square$

Thus the family of covering closures has **no least element** the instant routes
branch: the intersection of two optimal closures may prove nothing at all, and
the champion is determined only up to cost. What remains is a weighted set-cover
problem in disguise.

**Definition 5.2 (Multi-route proof system).** $M$ assigns to each statement $s$
a finite set $\mathrm{routes}_M(s)$ of finite sets of declarations. A closure $c$
*proves* $s$ if some $r \in \mathrm{routes}_M(s)$ has $r \subseteq c$, and
*covers* $\Gamma$ if it proves every $s \in \Gamma$.

**Theorem 5.3 (Existence of a minimum-cost cover).** Let $U$ be a finite universe
covering $\Gamma$. Then some $c \subseteq U$ covers $\Gamma$ and satisfies
$\sum_{x\in c}\ell(x) \le \sum_{x\in d}\ell(x)$ for every covering $d \subseteq U$.

*Proof.* The covering subsets of $U$ form a nonempty finite family (it contains
$U$); minimise the integer $\sum_{x \in c}\ell(x)$ over it. $\square$

**Corollary 5.4 (Champion with alternative routes).** A minimum-cost cover is a
fitness maximum among all covering sub-libraries of $U$ proving $\Gamma$
(assuming all such have positive cost and $\Gamma \ne \varnothing$).

*Proof.* Theorem 5.3 plus Theorem 3.1. $\square$

So the champion *question* stays well posed with alternative routes; only
canonicity — and with it, any hope of computing the champion by a closure
operation rather than a search — is lost.

---

## 6. Composition: an exact phase transition

Composing two developments pools their dependency closures, saving the shared
mass, but incurs an **adapter** of source length $A$ reconciling the two
interfaces.

**Definition 6.1.**
$$\mathrm{composeCost}_\ell(T,U,A) = \mathrm{cost}_\ell(T \sqcup U) + A, \qquad
\mathrm{dupCost}_\ell(T,U) = \mathrm{cost}_\ell(T) + \mathrm{cost}_\ell(U),$$
with corresponding fitnesses (same numerator $|\mathrm{pr}(T)\cup\mathrm{pr}(U)|$)
$$\mathrm{cFit} = \frac{|\mathrm{pr}(T)\cup\mathrm{pr}(U)|}{\mathrm{composeCost}}, \qquad
\mathrm{dFit} = \frac{|\mathrm{pr}(T)\cup\mathrm{pr}(U)|}{\mathrm{dupCost}}.$$

**Lemma 6.2 (Transition identity).**
$$\mathrm{composeCost}_\ell(T,U,A) + \mathrm{shared}_\ell(T,U) = \mathrm{dupCost}_\ell(T,U) + A.$$

*Proof.* Immediate from Theorem 2.11. $\square$

**Theorem 6.3 (Exact composition threshold).** Assume the pooled corpus is
nonempty and both costs are positive. Then
$$\mathrm{dFit} < \mathrm{cFit} \iff A < \mathrm{shared}_\ell(T,U),$$
$$\mathrm{dFit} = \mathrm{cFit} \iff A = \mathrm{shared}_\ell(T,U),$$
$$\mathrm{cFit} < \mathrm{dFit} \iff \mathrm{shared}_\ell(T,U) < A.$$

*Proof.* By Theorem 3.1 each fitness comparison is the reverse cost comparison,
and by Lemma 6.2 $\mathrm{composeCost} - \mathrm{dupCost} = A -
\mathrm{shared}_\ell(T,U)$ as integers. $\square$

This is a genuine phase transition with an exactly located critical point.

**Definition 6.4 (Densities).** The *dependency density* and *adapter density*
are the dimensionless quantities
$$\rho = \frac{\mathrm{shared}_\ell(T,U)}{\mathrm{dupCost}_\ell(T,U)}, \qquad
\alpha_A = \frac{A}{\mathrm{dupCost}_\ell(T,U)}.$$

**Corollary 6.5 (Density form).** Composition strictly increases fitness if and
only if $\alpha_A < \rho$.

*Proof.* Divide the inequality of Theorem 6.3 by the positive rational
$\mathrm{dupCost}_\ell(T,U)$. $\square$

Both densities are directly measurable on a real corpus, which is what makes the
threshold empirically testable.

**Worked instance.** Let all declarations have length $10$; let $T$ have closure
$\{0,1,2,3\}$ proving $\{0,1\}$ and $U$ have closure $\{2,3,4,5\}$ proving
$\{2,3\}$. Then $\mathrm{dupCost} = 80$, pooled cost $= 60$, so
$\mathrm{shared} = 20$ and $\rho = 1/4$. With $A = 10$, fitness rises from
$4/80$ to $4/70$; with $A = 30$ it falls to $4/90$; with $A = 20$ it is exactly
unchanged.

### 6.1 Multiplicative candidate populations

Composition may do more than pool corpora: when each result of one theory can be
applied to each result of the other, the composite proves a *product* corpus of
size $|\mathrm{pr}(T)|\cdot|\mathrm{pr}(U)|$. Define
$$\mathrm{pFit}_\ell(T,U,A) = \frac{|\mathrm{pr}(T)|\cdot|\mathrm{pr}(U)|}{\mathrm{composeCost}_\ell(T,U,A)}.$$

**Theorem 6.6 (Multiplicative criterion).** With $\mathrm{cost}_\ell(T) > 0$ and
$\mathrm{composeCost} > 0$,
$$\mathrm{fit}_\ell(T) < \mathrm{pFit}_\ell(T,U,A) \iff
|\mathrm{pr}(T)|\cdot\mathrm{composeCost} < |\mathrm{pr}(T)|\,|\mathrm{pr}(U)|\,\mathrm{cost}_\ell(T).$$

*Proof.* Cross-multiply the two ratios by their positive denominators. $\square$

**Theorem 6.7 (Multiplicative growth beats additive cost).** If
$|\mathrm{pr}(T)| > 0$ and
$$\mathrm{cost}_\ell(T) + \mathrm{cost}_\ell(U) + A < \mathrm{cost}_\ell(T)\cdot|\mathrm{pr}(U)|,$$
then $\mathrm{fit}_\ell(T) < \mathrm{pFit}_\ell(T,U,A)$ — composition is
profitable *whatever* the adapter charge.

*Proof.* $\mathrm{composeCost} \le \mathrm{cost}_\ell(T)+\mathrm{cost}_\ell(U)+A$
by Theorem 2.11; multiply the hypothesis by $|\mathrm{pr}(T)| > 0$ and apply
Theorem 6.6. $\square$

Costs add (at worst); candidates multiply. Theorem 6.7 says the multiplicative
side eventually wins, and quantifies "eventually" as a single explicit
inequality.

---

## 7. Exact candidate counts: the combinatorial baseline

Theorem 6.7's premise — that independent populations multiply — deserves an
exact combinatorial substrate. The natural population is the set of **usable
sub-libraries** of a body of declarations: its dependency-closed subsets.

**Definition 7.1.** For a finite universe $V$, let
$\mathcal{C}(V) = \{S \subseteq V : S \text{ dependency-closed}\}$.

**Theorem 7.2 (Exact multiplicativity across an independent split).** Let
$V = A \sqcup B$ with $A \cap B = \varnothing$, and suppose no dependency
crosses the split: $\mathrm{deps}(i) \subseteq A$ for $i \in A$ and
$\mathrm{deps}(i)\subseteq B$ for $i\in B$. Then
$$|\mathcal{C}(A\cup B)| = |\mathcal{C}(A)|\cdot|\mathcal{C}(B)|.$$

*Proof.* The maps $S \mapsto (S\cap A, S\cap B)$ and $(S_1,S_2)\mapsto S_1\cup
S_2$ are mutually inverse bijections between $\mathcal{C}(A\cup B)$ and
$\mathcal{C}(A)\times\mathcal{C}(B)$. Well-definedness of the first: if $S$ is
closed and $i \in S\cap A$ then $\mathrm{deps}(i)\subseteq S$ and
$\mathrm{deps}(i)\subseteq A$, hence $\mathrm{deps}(i)\subseteq S\cap A$;
symmetrically for $B$. Well-definedness of the second is Proposition 2.2. The
inverse identities use $S \subseteq A\cup B$ and, in the other direction,
$S_2\cap A = \varnothing = S_1 \cap B$, which follow from disjointness. $\square$

This is a bijection, not an estimate: independent parts multiply exactly.

**Corollary 7.3 (Independent baseline).** If no declaration has dependencies,
then $|\mathcal{C}(V)| = 2^{|V|}$.

*Proof.* Every subset is closed. $\square$

**Theorem 7.4 (Chain baseline).** Let declaration $i$ depend on $i-1$ (with $0$
depending on nothing), and $V = \{0,\dots,n-1\}$. Then $|\mathcal{C}(V)| = n+1$.

*Proof.* Closedness forces downward closure: by induction on $d$, $i \in S$
implies $i-d \in S$. Hence a nonempty closed $S$ equals $\{0,\dots,\max S\}$, so
the closed subsets of $V$ are precisely the initial segments
$\{0,\dots,k-1\}$ for $0 \le k \le n$; these are pairwise distinct (their
cardinalities differ), giving $n+1$. $\square$

**Corollary 7.5 (Dependency density collapses the population).** For $n \ge 2$,
$n+1 < 2^n$: the maximally dependent library of $n$ declarations has strictly
fewer usable sub-libraries than the independent one, and the gap is exponential.

Corollary 7.5 quantifies the trade-off underlying the phase transition:
dependency density is exactly the dial interpolating between the $2^n$ reuse
opportunities of a fully modular library and the $n+1$ of a monolithic chain.

---

## 8. The shape of the landscape: valleys and metastable peaks

Regard developments as points joined when one bounded, semantics-preserving
refactoring turns one into the other.

**Definition 8.1 (Development record).** For landscape purposes a development is
a triple $(\mathrm{len}, \mathrm{iface}, \mathrm{content}) \in \mathbb{Q}\times
\mathbb{N}\times\mathbb{Q}$: its source length, the identifier of the principal
abstraction layer it is written against, and the intrinsic size of the
mathematical content it implements. A **migration path** of length $n$ is a walk
$w(0), \dots, w(n)$ of such records; it is *semantics preserving* if
$\mathrm{content}(w(i))$ is constant.

### 8.1 Adapter valleys

**Lemma 8.2 (Boundary crossing).** If $\mathrm{iface}(w(0)) \ne
\mathrm{iface}(w(n))$, then some $i < n$ has $\mathrm{iface}(w(i)) \ne
\mathrm{iface}(w(i+1))$.

*Proof.* Otherwise the interface is constant along the walk by induction, so the
endpoints agree. $\square$

**Theorem 8.3 (Quantitative adapter valley).** Let $w$ be a semantics-preserving
migration of length $n$ with content $C > 0$, and let $0 \le \beta < \alpha$.
Suppose:

* the endpoints use inequivalent interfaces;
* (*adapter law*) any state that crosses the boundary at its next step must
  implement both interfaces, so $\mathrm{len}(w(i)) \ge (1+\alpha)C$ for such $i$;
* (*endpoint efficiency*) $\mathrm{len}(w(0)) \le (1+\beta)C$.

Then some $i \le n$ satisfies
$$\mathrm{len}(w(i)) - m \;\ge\; \frac{\alpha-\beta}{1+\beta}\, m, \qquad
m = \min\{\mathrm{len}(w(0)), \mathrm{len}(w(n))\}.$$

*Proof.* By Lemma 8.2 pick a crossing index $i$; then $\mathrm{len}(w(i)) \ge
(1+\alpha)C$. Efficiency gives $m \le (1+\beta)C$. If $m \le 0$ the claim is
immediate from $\mathrm{len}(w(i)) \ge (1+\alpha)C > 0$ and nonnegativity of
$(\alpha-\beta)/(1+\beta)$. Otherwise, multiplying $m \le (1+\beta)C$ by the
nonnegative factor $(\alpha-\beta)/(1+\beta)$ and using
$\frac{\alpha-\beta}{1+\beta}\cdot(1+\beta)C = (\alpha-\beta)C$ yields
$\frac{\alpha-\beta}{1+\beta}m \le (\alpha-\beta)C$. Hence
$$\mathrm{len}(w(i)) - m \ge (1+\alpha)C - (1+\beta)C = (\alpha-\beta)C \ge \frac{\alpha-\beta}{1+\beta}m. \qquad\square$$

**Corollary 8.4.** The guaranteed relative overshoot $(\alpha-\beta)/(1+\beta)$
is strictly positive whenever $0 \le \beta < \alpha$.

**Worked instance.** Two endpoints of content $100$ written at $10\%$ overhead
(length $110$), an intermediate adapter state at $50\%$ overhead (length $150$),
crossing the boundary. Here $\alpha = 1/2$, $\beta = 1/10$, so the guaranteed
overshoot is $(1/2-1/10)/(11/10) = 4/11 \approx 36\%$ — and indeed
$150 - 110 = 40 \ge (4/11)\cdot 110 = 40$.

The theorem reduces the *quantitative adapter-valley conjecture* to measuring a
single class of cross-interface transitions: the combinatorial part (a crossing
exists) is unconditional, and the quantitative part follows from an adapter law
and an endpoint-efficiency figure, each measurable independently.

### 8.2 Three-style metastability

**Definition 8.5.** Let $\mathrm{fit}$ be a fitness function on developments,
$\mathrm{adj}$ a neighbourhood relation (one bounded refactoring), and
$\mathrm{style}$ a map to methodological styles.

* $b$ is a **strict local maximum** if $\mathrm{fit}(t) < \mathrm{fit}(b)$ for
  every neighbour $t \ne b$ of $b$;
* $b$ is **style-optimal** if $\mathrm{fit}(t) < \mathrm{fit}(b)$ for every
  $t \ne b$ with $\mathrm{style}(t) = \mathrm{style}(b)$.

**Theorem 8.6 (Style-centre theorem).** If bounded refactorings never change
style — $\mathrm{adj}(x,y)$ implies $\mathrm{style}(x) = \mathrm{style}(y)$ —
then every style-optimal development is a strict local maximum.

*Proof.* A neighbour $t \ne b$ has $\mathrm{style}(t) = \mathrm{style}(b)$, so
style-optimality applies. $\square$

**Theorem 8.7 (Quarantine form).** If $b$ is style-optimal and every neighbour
of $b$ in a *different* style is strictly less fit, then $b$ is a strict local
maximum.

*Proof.* Split on whether the neighbour shares $b$'s style. $\square$

Theorem 8.7 is the realistic hypothesis: boundaries may be crossed, but by
Theorem 8.3 the crossing states carry adapter overhead and are therefore less
fit. The valley theorem and the metastability theorem thus interlock.

**Theorem 8.8 (Renaming invariance).** Let $\sigma$ be a bijection of
developments with $\mathrm{fit}(\sigma x) = \mathrm{fit}(x)$ and
$\mathrm{adj}(\sigma x, \sigma y) \Rightarrow \mathrm{adj}(x,y)$. If $b$ is a
strict local maximum, so is $\sigma b$.

*Proof.* Given a neighbour $t \ne \sigma b$ of $\sigma b$, the point
$\sigma^{-1}t$ is a neighbour of $b$ distinct from $b$, so
$\mathrm{fit}(\sigma^{-1}t) < \mathrm{fit}(b)$; invariance of $\mathrm{fit}$
transports this to $\mathrm{fit}(t) < \mathrm{fit}(\sigma b)$. $\square$

Hence strict local maximality descends to the quotient by semantics-preserving
renaming: the notion is about mathematics, not identifiers.

**Theorem 8.9 (A metastable three-style landscape).** There is a nine-point
landscape with three styles — algebraic, analytic, combinatorial — in which each
style contains a strict local maximum, the three maxima have pairwise distinct
styles, and two of the three are *not* global.

*Proof.* Take fitnesses $1,2,5$ (algebraic), $3,7,4$ (analytic), $6,2,9$
(combinatorial), with $\mathrm{adj}$ relating developments of equal style. Each
style's unique maximiser is style-optimal, hence a strict local maximum by
Theorem 8.6: these are the points of fitness $5$, $7$ and $9$. Their styles
differ by construction, and $5 < 9$, $7 < 9$. $\square$

Metastability is therefore not an artefact of a coarse notion of neighbourhood:
one can be trapped on a peak that is genuinely a strict peak and genuinely not
optimal.

---

## 9. No universal maximum without resource normalisation

The results so far all fixed a corpus and a comparison class. What if we do not?

**Definition 9.1 (Theory language).** A *language* $L$ consists of a type of
developments, functions $\mathrm{count}, \mathrm{len}$ to $\mathbb{N}$, a
semantics map to sets of statements, a marginal cost function $m : \mathbb{N}\to
\mathbb{N}$, and a **conservative inflation** operator $\mathrm{ext}(T,n)$
satisfying

* $\mathrm{count}(\mathrm{ext}(T,n)) = \mathrm{count}(T) + n$;
* $\mathrm{len}(\mathrm{ext}(T,n)) = \mathrm{len}(T) + m(n)$;
* $\mathrm{sem}(\mathrm{ext}(T,n)) = \mathrm{sem}(T)$ (conservativity);
* $m$ is **sublinear**: for every rational $c > 0$ there is $N$ with $m(n) \le
  c\,n$ for all $n \ge N$.

Inflation captures "state $n$ further consequences of what you have already
proved": the count goes up, the semantics does not, and the marginal source cost
per consequence tends to $0$ because the schema is written once.

**Definition 9.2 (Raw fitness).** $\mathrm{raw}(T) = \mathrm{count}(T)/\mathrm{len}(T)$.

**Theorem 9.3 (Unboundedness).** For any development $T_0$ with
$\mathrm{len}(T_0) > 0$ and any $M \in \mathbb{Q}$, there is $n$ with
$M < \mathrm{raw}(\mathrm{ext}(T_0,n))$.

*Proof.* We may assume $M > 0$ (else use $M = 1$). Apply sublinearity with rate
$c = 1/(2M)$ to get $N$; choose $k > 2M\,\mathrm{len}(T_0)$ and set $n = \max(N,k)+1$.
Then $m(n) \le n/(2M)$, so $M\,m(n) \le n/2$, and
$$M\cdot\mathrm{len}(\mathrm{ext}(T_0,n)) = M\,\mathrm{len}(T_0) + M\,m(n)
< \tfrac{n}{2} + \tfrac{n}{2} = n \le \mathrm{count}(T_0) + n = \mathrm{count}(\mathrm{ext}(T_0,n)),$$
using $M\,\mathrm{len}(T_0) < n/2$ from the choice of $k$. Dividing by the
positive length gives the claim. $\square$

**Theorem 9.4 (No global maximum).** In any such language with at least one
development of positive length, there is no $T$ with $\mathrm{raw}(U) \le
\mathrm{raw}(T)$ for all $U$.

*Proof.* Apply Theorem 9.3 with $M = \mathrm{raw}(T)$. $\square$

**Theorem 9.5 (Semantic inertness of the witnesses).** The unbounded family may
be chosen so that every witness has *exactly the same semantics* as the base
development.

*Proof.* Conservativity of $\mathrm{ext}$. $\square$

Theorem 9.5 is the sting: raw fitness diverges while the mathematics stands
still. The divergence records no progress whatever.

**Theorem 9.6 (Normalisation dichotomy).** In any such language: (a) every
nonempty finite comparison class contains a raw-fitness maximum; (b) the
unrestricted class contains none.

*Proof.* (a) is Theorem 3.2's argument; (b) is Theorem 9.4. $\square$

**The hypotheses are satisfiable.** Take developments to be pairs (theorem
count, length), inflation $(a,b) \mapsto (a+n, b+\lfloor\sqrt n\rfloor)$, and
constant semantics. Sublinearity of $\sqrt{\cdot}$ holds: given $c>0$, choose
$k > 1/c$ and $N = k^2+1$; for $n \ge N$ we get $\lfloor\sqrt n\rfloor \ge k$,
hence $c\lfloor \sqrt n\rfloor > 1$, and so $\lfloor\sqrt n\rfloor \le
c\lfloor\sqrt n\rfloor^2 \le c\,n$. This language therefore has no fitness
champion.

**Interpretation.** A "global champion" claim is meaningful only *relative to* a
bounded, normalised comparison class: fixed theorem identity, fixed admissible
dependencies, fixed corpus. Normalisation is the decisive hypothesis, not a
technicality — which turns a vague universality claim into a sharp dichotomy.

---

## 10. Algorithms

Three procedures make the theory operational on a real corpus.

**(A) Transitive closure by saturation.** Given $\mathrm{deps}$ and a base $B$
inside a universe $U$, iterate $S \mapsto S \cup \bigcup_{i\in S}\mathrm{deps}(i)$
until stable. Theorem 2.6 guarantees termination within $|U|+1$ rounds and
minimality of the result. A worklist implementation runs in $O(|U| + E)$ time
where $E = \sum_i |\mathrm{deps}(i)|$, since each declaration is expanded once.

**(B) Threshold audit for a proposed merge.** Compute both closures, their
intersection mass $\mathrm{shared}$, and an estimate $A$ of the adapter length.
Report the densities $\rho$ and $\alpha_A$; by Corollary 6.5 the merge pays iff
$\alpha_A < \rho$. Cost $O(|U|)$ after closure.

**(C) Minimum-cost cover under alternative routes.** With $r$ routes per
statement, Theorem 5.3 guarantees a minimiser exists but not that it is
canonical; exhaustive search over route selections is $O(r^{|\Gamma|})$ in the
worst case, so in practice one uses the canonical-closure heuristic (pick the
cheapest route per statement, then close) and reports the gap to a lower bound.
This is the algorithmic residue of Theorem 5.1.

**(D) Closed-subset counting.** Corollary 7.3 and Theorem 7.4 provide exact
endpoints; for general dependency graphs the count of dependency-closed subsets
equals the number of antichains-downsets of the induced preorder, computable by
dynamic programming over a topological order or, on a split graph, factored
using Theorem 7.2.

---

## 11. Applications

**Library governance.** Corollary 6.5 turns "should these two libraries merge?"
into the comparison of two dimensionless measured numbers. Theorem 4.1 turns
"how much did that refactor save?" into an exact count of duplicated core
copies.

**Refactoring expectations.** Theorem 8.3 predicts that any migration across an
abstraction boundary passes through a state at least
$(\alpha-\beta)/(1+\beta)$ larger than the smaller endpoint. A reviewer who
rejects such an intermediate state as a regression is rejecting the only
available road.

**Explaining methodological pluralism.** Theorems 8.6–8.9 explain persistent
coexistence of algebraic, analytic and combinatorial developments without
appealing to taste: three strict local maxima, at most one of them global, and
valleys separating them.

**Metric design.** Theorems 9.4–9.6 are a warning label for any productivity
metric of the form theorems-per-line. Without normalisation, the metric is
unbounded and its optimisers are semantically inert.

---

## 12. Discussion, limitations, and future work

### 12.1 What is and is not proved

The model charges a single additive resource. It does not model proof-checking
time, cognitive load, or the value differences among corpus statements — the
corpus is counted, not weighted. Theorem 3.1 shows the last of these to be the
binding simplification: with weighted statements, fitness would no longer reduce
to an ordinal inverse of cost, and the extremal analysis would need redoing.

Theorem 4.7 is a genuine global statement, but relative to a *fixed proof
system*. Theorem 5.1 shows this is sharp: canonicity fails at exactly the point
where routes branch.

The adapter law and endpoint-efficiency figures of Theorem 8.3 are hypotheses,
not consequences; the theorem's contribution is to reduce a qualitative
conjecture to two independently measurable constants $\alpha$ and $\beta$.

### 12.2 Future directions

*Canonicity gap (route-choice hardness).* In the fixed-route model the champion
is the canonical closure. With $r \ge 2$ routes per statement, we conjecture
that deciding whether a corpus admits a covering library of dependency-adjusted
cost $\le B$ is NP-complete, and that the gap between the canonical-closure
heuristic and the true optimum is $\Theta(\log|\Gamma|)$ in the worst case. The
obstruction is already exhibited by Theorem 5.1: two cost-equal covering
closures with empty intersection, so the covering family loses its least element
the moment routes branch, leaving a weighted set-cover instance in disguise.
Existence is not at risk (Corollary 5.4); the open content is exactly the
complexity of finding the optimum.

*Sharp reuse threshold for realistic cost models.* Theorem 6.3 assumes an
additive adapter charge. We conjecture that for any subadditive adapter cost
$A(s) \le c\,s^\theta$ with $\theta<1$, composing $k$ libraries of shared
density $\rho$ increases fitness for all $k \ge k_0(\rho,\theta)$ with
$k_0 = O(\rho^{-1/(1-\theta)})$, and that this exponent is optimal. The exact
identity of Theorem 4.1 makes the saving grow linearly in $k$ while a
subadditive adapter grows sublinearly, so the crossing point is determined by a
single exponent rather than by the library's contents.

*Universality of quantitative adapter valleys.* Theorem 8.3 derives a relative
overshoot $(\alpha-\beta)/(1+\beta)$ from an assumed adapter law. We conjecture
that in any real corpus the adapter law holds with $\alpha \ge 1/4$ and endpoint
efficiency $\beta \le 1/10$, so that every semantics-preserving migration across
an abstraction boundary incurs an overshoot of at least $(1/4-1/10)/(11/10) =
3/22$, roughly $14\%$, of the smaller endpoint length.

*Dependency-adjusted global champion, empirically.* Fix a finite corpus and
charge each theory for both source length and the transitive size of its
dependency closure. Among theories proving the entire corpus, we conjecture that
the mature shared library has maximal dependency-adjusted fitness. The finite
maximum principle identifies exactly what remains empirical: a fixed comparison
class, a reproducible cost model, and complete theorem-coverage measurements.

*Three-style metastability, empirically.* In a migration graph built from
bounded refactorings, we conjecture that algebraic, analytic and combinatorial
developments each contain a distinct strict local maximum after quotienting by
semantics-preserving renaming. Theorems 8.6–8.8 separate the two required
conditions — stylewise efficiency and rarely-crossed neighbourhoods — making
each independently measurable and falsifiable on a finite corpus.

*Multiplicative-reuse phase transition, empirically.* We conjecture a threshold
dependency density above which composing two libraries increases fitness even
after charging for an adapter layer, and below which composition decreases it.
Independent candidate populations grow multiplicatively (Theorem 7.2) while
implementation costs usually add, but duplicated or incompatible interfaces can
reverse the gain. The exact exponential counts of §7 give a controlled
combinatorial baseline against which realistic additive and subadditive cost
models can be tested.

### 12.3 Conclusion

Fixing the cost model — a finite corpus, an additive source-length function, and
a transitive dependency closure charged exactly once — is enough to settle a
surprising amount. Reuse provably dominates duplication with an exact saving of
$k-1$ core copies; the canonical closure is a global champion for a fixed proof
system, and demonstrably not canonical once routes branch; composition has an
exactly located phase transition in a measurable dimensionless parameter; the
candidate population interpolates exactly between $2^n$ and $n+1$ as dependency
density rises; migrations across abstraction boundaries must descend into a
valley of guaranteed relative depth; styles can be metastable in a strict and
renaming-invariant sense; and any unnormalised theorems-per-line metric is
unbounded with semantically inert optimisers. What remains open is not the
structure of the landscape but its parameters — and those are measurements, not
theorems.
