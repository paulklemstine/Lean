# Self-Application, Least Fixed Points, and Reachable Invariant Regions

**Aristotle**  
**July 21, 2026**

## Abstract

We give a self-contained order-theoretic model of a system whose candidate laws may be supplied as inputs to its own simulator. For a monotone binary simulator on a complete lattice, we prove that nested least-fixed-point semantics agrees with direct diagonal self-application. This yields a canonical least self-consistent law. We then specialize to laws represented by subsets of a state space. Given initial conditions $I\subseteq X$ and a deterministic transition $s:X\to X$, the associated closure operator $F(R)=I\cup s[R]$ has a least fixed point. We prove that this point is the unique least forward-invariant region containing $I$, and that membership in it is equivalent to reachability from $I$ after finitely many transitions. These results unify denotational fixed-point semantics, operational iteration, and the geometry of invariant regions. We also give terminating finite-state algorithms, distinguish least-solution uniqueness from unrestricted uniqueness, and explain why no numerical physical constant follows from the order-theoretic assumptions alone.

## 1. Introduction

A simulator is usually presented with two conceptually different ingredients: a rule and a state to which the rule is applied. Self-application removes that separation. A candidate law may itself be treated as an input, leading to an equation of the form

$$
U(L,L)=L,
$$

where $U$ is a binary simulator and $L$ is a self-consistent law. Such an equation is suggestive but incomplete. Existence need not hold in an arbitrary space; several solutions may coexist; and the relationship between a static fixed point and iterative dynamics is not automatic.

The appropriate setting is a complete lattice. Its order represents approximation, information content, permissiveness, or inclusion. Completeness supplies arbitrary meets and joins, while monotonicity ensures that improved inputs cannot produce a degraded output. These hypotheses lead to a least fixed point. Leastness is crucial: it selects a canonical solution even when many fixed points exist.

There are two natural semantics for a binary simulator. In **nested semantics**, one fixes a proposed law, resolves the simulated object by a least fixed point, and then resolves the law itself by another least fixed point. In **diagonal semantics**, one identifies the two inputs immediately and takes the least fixed point of $a\mapsto U(a,a)$. Our first main result states that these constructions coincide.

The abstract theorem has a concrete dynamical specialization. Let $X$ be a state space, $I\subseteq X$ a set of initial states, and $s:X\to X$ a one-step transition. Candidate laws are regions $R\subseteq X$, ordered by inclusion, and the evolution operator is

$$
F(R)=I\cup s[R].
$$

The least fixed point of $F$ is exactly the smallest region that contains $I$ and is closed under $s$. It is also exactly the set of points $s^n(i)$ obtained from some $i\in I$ after finitely many steps. This equivalence links three perspectives:

1. **Denotational:** a law is a least fixed point in a complete lattice.
2. **Operational:** a state belongs to the law exactly when a finite execution reaches it.
3. **Geometric:** a law is the least forward-invariant region containing the initial conditions.

The results are structural rather than model-specific. They apply to deterministic transition systems, program loops, state-space exploration, and invariant-set constructions. Their limitations are equally important. A monotone map can have many fixed points, so uniqueness is asserted only under least or generated semantics. Reachability does not imply attraction without metric or topological assumptions. Finally, the framework contains no map from fixed points to dimensionless physical constants, and therefore yields no numerical prediction for such constants.

## 2. Order-theoretic preliminaries

### 2.1 Complete lattices and monotone maps

A **partially ordered set** is a pair $(A,\leq)$ in which $\leq$ is reflexive, antisymmetric, and transitive. A **complete lattice** is a partially ordered set in which every subset $S\subseteq A$ has an infimum $\bigwedge S$ and a supremum $\bigvee S$. In particular, it has a least element $\bot=\bigvee\varnothing$ and a greatest element $\top=\bigwedge\varnothing$.

A function $f:A\to B$ between partially ordered sets is **monotone** if

$$
a\leq a'\quad\Longrightarrow\quad f(a)\leq f(a').
$$

For $f:A\to A$, an element $a$ is a **pre-fixed point** if $f(a)\leq a$, a **post-fixed point** if $a\leq f(a)$, and a **fixed point** if $f(a)=a$.

### 2.2 Least fixed points

For a monotone endomorphism $f:A\to A$ of a complete lattice, define

$$
\mu f=\bigwedge\{a\in A:f(a)\leq a\}.
$$

The symbol $\mu f$ denotes the least fixed point.

**Theorem 2.1 (Least Fixed-Point Theorem).**  
Let $A$ be a complete lattice and let $f:A\to A$ be monotone. Then $\mu f$ is a fixed point of $f$. Moreover, if $f(a)=a$, or more generally if $f(a)\leq a$, then $\mu f\leq a$. Hence $\mu f$ is the unique least fixed point of $f$.

**Proof sketch.** By definition, $\mu f$ lies below every pre-fixed point. Monotonicity shows that $f(\mu f)$ lies below $f(a)\leq a$ for every pre-fixed point $a$, so $f(\mu f)\leq\mu f$. Thus $\mu f$ is itself pre-fixed. Applying monotonicity to this inequality gives $f(f(\mu f))\leq f(\mu f)$, making $f(\mu f)$ pre-fixed. Minimality then yields $\mu f\leq f(\mu f)$. Antisymmetry gives equality. The comparison with every pre-fixed point is built into the defining infimum. $\square$

The theorem requires neither finiteness nor continuity. Continuity becomes relevant when one wants to compute the least fixed point as the supremum of a countable approximation chain, but existence itself follows from completeness and monotonicity.

### 2.3 Monotone binary simulators

Let $A$ be a complete lattice. A **monotone binary simulator** is a map

$$
U:A\times A\to A
$$

such that

$$
a\leq a'\ \text{and}\ b\leq b'
\quad\Longrightarrow\quad
U(a,b)\leq U(a',b').
$$

For each $a\in A$, the section $U_a:A\to A$ defined by $U_a(b)=U(a,b)$ is monotone. We may therefore define its least fixed point

$$
H(a)=\mu(b\mapsto U(a,b)).
$$

The map $H:A\to A$ is itself monotone. Indeed, if $a\leq a'$, then $U(a,b)\leq U(a',b)$ for every $b$. In particular, $H(a')$ is a pre-fixed point of $U_a$ because

$$
U(a,H(a'))\leq U(a',H(a'))=H(a').
$$

By leastness, $H(a)\leq H(a')$.

Two candidate self-application semantics now arise:

$$
N=\mu H
=\mu\!\left(a\mapsto\mu(b\mapsto U(a,b))\right)
$$

and

$$
D=\mu\Delta_U,
\qquad
\Delta_U(a)=U(a,a).
$$

The map $\Delta_U$ is monotone because $U$ is monotone in both arguments.

## 3. The fixed-point diagonal rule

**Theorem 3.1 (Fixed-Point Diagonal Theorem).**  
Let $A$ be a complete lattice and $U:A\times A\to A$ a monotone binary simulator. Then nested least-fixed-point semantics and diagonal least-fixed-point semantics agree:

$$
\mu\!\left(a\mapsto\mu(b\mapsto U(a,b))\right)
=
\mu(a\mapsto U(a,a)).
$$

**Proof sketch.** Let

$$
N=\mu H,
\qquad H(a)=\mu(b\mapsto U(a,b)).
$$

Since $N=H(N)$ and $H(N)$ is the least fixed point of $b\mapsto U(N,b)$,

$$
N=H(N)=U(N,H(N))=U(N,N).
$$

Thus $N$ is a fixed point of the diagonal map, and consequently $D\leq N$.

For the reverse inequality, the diagonal least fixed point satisfies $D=U(D,D)$. Hence $D$ is a fixed point, and therefore a pre-fixed point, of the section $b\mapsto U(D,b)$. Its least fixed point obeys

$$
H(D)\leq D.
$$

Thus $D$ is a pre-fixed point of $H$, so the least fixed point $N=\mu H$ satisfies $N\leq D$. Antisymmetry gives $N=D$. $\square$

The argument actually reveals the order-theoretic mechanism. A fixed point of the nested construction is diagonal because the outer and inner solutions coincide there. Conversely, a diagonal pre-fixed point bounds the inner least solution at its own first coordinate, and therefore bounds the outer least solution.

**Corollary 3.2 (Canonical self-consistent law).**  
Under the hypotheses of Theorem 3.1, there exists a canonical least element $L\in A$ satisfying

$$
U(L,L)=L.
$$

It is given equally by diagonal or nested least-fixed-point semantics.

**Proof sketch.** Take $L=D=N$ in Theorem 3.1. The least-fixed-point theorem gives $U(L,L)=L$, while leastness gives $L\leq L'$ for every diagonal fixed point $L'$ satisfying $U(L',L')=L'$. $\square$

### 3.1 Scope of uniqueness

The corollary does not state that $L$ is the only diagonal fixed point. It states that $L$ is the unique **least** one. This distinction cannot be removed under monotonicity alone.

For example, on the two-element lattice $A=\{0,1\}$, let $U(a,b)=a$. Then $U(0,0)=0$ and $U(1,1)=1$. Both elements are diagonal fixed points, while $0$ is the least. More generally, the identity map on any nontrivial complete lattice is monotone and every element is fixed.

Thus any claim of unrestricted uniqueness needs extra structure: a contraction principle, an order condition forcing all fixed points to coincide, or a quotient identifying behaviorally equivalent points. Least-solution semantics is the strongest general canonical selection available from the present assumptions.

## 4. Regions as laws

### 4.1 The lattice of regions

Let $X$ be an arbitrary set. Its power set $\mathcal P(X)$, ordered by inclusion, is a complete lattice. For a family $\mathcal S\subseteq\mathcal P(X)$,

$$
\bigwedge\mathcal S=\bigcap_{R\in\mathcal S}R,
\qquad
\bigvee\mathcal S=\bigcup_{R\in\mathcal S}R.
$$

The bottom element is $\varnothing$ and the top element is $X$.

Fix initial conditions $I\subseteq X$ and a deterministic one-step transition $s:X\to X$. For $R\subseteq X$, write

$$
s[R]=\{s(x):x\in R\}.
$$

Define the **one-step generation operator** $F:\mathcal P(X)\to\mathcal P(X)$ by

$$
F(R)=I\cup s[R].
$$

The operator is monotone: if $R\subseteq S$, then $s[R]\subseteq s[S]$, and therefore $F(R)\subseteq F(S)$.

A region $R$ is **forward invariant** under $s$ if

$$
s[R]\subseteq R,
$$

or equivalently, if $x\in R$ implies $s(x)\in R$. A region is **admissible** for $(I,s)$ if it contains the initial conditions and is forward invariant:

$$
I\subseteq R
\quad\text{and}\quad
s[R]\subseteq R.
$$

Observe that admissibility is equivalent to the pre-fixed-point condition

$$
F(R)\subseteq R.
$$

### 4.2 Least invariant region

**Theorem 4.1 (Least Invariant Region Theorem).**  
For every set $X$, initial region $I\subseteq X$, and transition $s:X\to X$, the operator $F(R)=I\cup s[R]$ has a least fixed point $R_*$. This region is admissible, and for every admissible region $R$,

$$
R_*\subseteq R.
$$

Consequently, $R_*$ is the unique least forward-invariant region containing $I$.

**Proof sketch.** The power set is a complete lattice and $F$ is monotone, so Theorem 2.1 supplies the least fixed point $R_*$. Since $F(R_*)=R_*$, one has $I\subseteq R_*$ and $s[R_*]\subseteq R_*$. If $R$ is admissible, then $F(R)\subseteq R$, so the least-fixed-point comparison gives $R_*\subseteq R$. If two regions were both least admissible regions, each would be contained in the other and antisymmetry would make them equal. $\square$

An equivalent closed-form description is

$$
R_*=\bigcap\{R\subseteq X:I\subseteq R\ \text{and}\ s[R]\subseteq R\}.
$$

This intersection is admissible: every member contains $I$, so the intersection does; and if a point belongs to every admissible region, its successor belongs to every such region as well.

The theorem is geometric in the broad sense that it constructs a distinguished region of state space. No topology is assumed. If one requires $R_*$ to be closed, measurable, compact, or smooth, the collection of candidate regions and the transition must satisfy additional closure conditions.

## 5. Operational reachability

### 5.1 Iteration

Define the iterates of $s$ recursively by

$$
s^0(x)=x,
\qquad
s^{n+1}(x)=s(s^n(x)).
$$

A state $x\in X$ is **finitely reachable from $I$** if there exist $i\in I$ and $n\in\mathbb N$ such that

$$
x=s^n(i).
$$

The reachable region is

$$
\operatorname{Reach}(I,s)
=
\{x\in X:\exists i\in I,\ \exists n\in\mathbb N,\ x=s^n(i)\}.
$$

Equivalently,

$$
\operatorname{Reach}(I,s)=\bigcup_{n\in\mathbb N}s^n[I].
$$

### 5.2 Equivalence of fixed-point and operational semantics

**Lemma 5.1 (Reachability is admissible).**  
The region $\operatorname{Reach}(I,s)$ contains $I$ and is forward invariant under $s$.

**Proof sketch.** If $i\in I$, then $i=s^0(i)$, so $i$ is reachable. If $x=s^n(i)$ is reachable, then $s(x)=s^{n+1}(i)$ is reachable. $\square$

**Lemma 5.2 (Every admissible region contains every finite orbit).**  
If $R$ contains $I$ and is forward invariant, then for every $i\in I$ and $n\in\mathbb N$,

$$
s^n(i)\in R.
$$

**Proof sketch.** Induct on $n$. The case $n=0$ follows from $I\subseteq R$. For the inductive step, forward invariance sends $s^n(i)\in R$ to $s^{n+1}(i)\in R$. $\square$

**Theorem 5.3 (Finite Reachability Theorem).**  
The least invariant region and the finitely reachable region coincide:

$$
R_*=\operatorname{Reach}(I,s).
$$

Equivalently, for every $x\in X$,

$$
x\in R_*
\quad\Longleftrightarrow\quad
\exists i\in I,\ \exists n\in\mathbb N,\ x=s^n(i).
$$

**Proof sketch.** Lemma 5.1 makes the reachable region admissible, so Theorem 4.1 gives $R_*\subseteq\operatorname{Reach}(I,s)$. Conversely, $R_*$ is admissible. Lemma 5.2 therefore puts every finite iterate of every initial state in $R_*$, proving $\operatorname{Reach}(I,s)\subseteq R_*$. $\square$

**Corollary 5.4 (Generated-solution uniqueness).**  
A region $R\subseteq X$ is the canonical generated law for $(I,s)$ if and only if it is the set of all finite iterates of initial states. In particular, the generated law is unique.

**Proof sketch.** Theorem 5.3 gives the explicit region, and extensionality of sets gives uniqueness. $\square$

The corollary clarifies the status of “unique up to computational behavior.” No equivalence relation on programs or simulations has yet been imposed, so a general theorem about computational equivalence would be premature. What is proved is stronger and cleaner at the extensional state-set level: generated semantics determines one region exactly. A future computability-enriched model could quotient implementations by mutual simulation or bisimulation.

## 6. Approximation chains and algorithms

### 6.1 Finite-stage approximants

Starting from no known states, define

$$
R_0=\varnothing,
\qquad
R_{n+1}=F(R_n)=I\cup s[R_n].
$$

A direct induction gives

$$
R_{n+1}=\bigcup_{k=0}^{n}s^k[I].
$$

Thus each stage records states reachable within a bounded number of transitions. Their union is

$$
\bigcup_{n\in\mathbb N}R_n
=
\operatorname{Reach}(I,s)
=R_*.
$$

For this particular operator, the equality follows directly from the explicit reachability description. For arbitrary monotone operators, the supremum of the finite chain need not be fixed without an additional continuity condition.

### 6.2 Saturation algorithm on a finite state space

Suppose $X$ is finite and membership and transition evaluation are effective. The most literal algorithm repeatedly applies $F$ until stabilization.

**Algorithm 6.1 (Monotone invariant-region saturation).**

1. Set $R\leftarrow\varnothing$.
2. Compute $R'\leftarrow I\cup\{s(x):x\in R\}$.
3. If $R'=R$, return $R$.
4. Otherwise set $R\leftarrow R'$ and repeat from step 2.

**Proposition 6.2 (Termination and correctness).**  
On a finite state space, Algorithm 6.1 terminates and returns $R_*$. If $N=|X|$, there are at most $N$ strict-growth rounds.

**Proof sketch.** The sequence of regions is increasing. Every nonterminal round adds at least one state, and no region contains more than $N$ states, so strict growth cannot continue beyond $N$ rounds. On termination, $R=F(R)$, hence $R$ is a fixed point. Because the iteration began at the least region and $F$ is monotone, every approximant lies inside every pre-fixed point; the returned fixed point is therefore least. Equivalently, the finite-stage formula shows that the output consists exactly of reachable states. $\square$

With bit-set regions and a transition table, a straightforward full scan costs $O(N^2)$ time in the worst case and $O(N)$ space: up to $N$ rounds each inspect up to $N$ states.

### 6.3 Queue-based orbit exploration

A more efficient method maintains a frontier of newly discovered states.

**Algorithm 6.3 (Frontier exploration of deterministic reachability).**

1. Initialize a set $R$ with all states in $I$.
2. Initialize a queue with all states in $I$.
3. While the queue is nonempty, remove a state $x$.
4. Compute $y=s(x)$.
5. If $y\notin R$, insert $y$ into $R$ and append $y$ to the queue.
6. Return $R$.

**Proposition 6.4 (Frontier complexity and correctness).**  
For finite $X$, Algorithm 6.3 returns $R_*$. With constant-time hashing and transition evaluation, it runs in expected time $O(|R_*|+|I|)$ and uses $O(|R_*|)$ space.

**Proof sketch.** Every inserted state is either initial or the successor of an already reachable state, so it is reachable. Conversely, induction on path length shows that every reachable state is eventually inserted: its predecessor is processed after insertion and generates it. Each discovered state is enqueued at most once, so the transition is evaluated once per reachable state. Theorem 5.3 identifies the returned set with $R_*$. $\square$

### 6.4 Checking a proposed invariant

Given a finite candidate region $R$, admissibility can be checked by testing $I\subseteq R$ and $s(x)\in R$ for every $x\in R$. This costs $O(|I|+|R|)$ expected time with hashed membership. If the test passes, Theorem 4.1 guarantees $R_*\subseteq R$. Equality additionally requires that every member of $R$ be reachable, which frontier exploration decides.

## 7. Example

Let

$$
X=\{0,1,2,3,4,5,6,7\},
\qquad I=\{0\},
\qquad s(x)=(2x+1)\bmod 8.
$$

The orbit is

$$
0\mapsto1\mapsto3\mapsto7\mapsto7.
$$

Therefore

$$
R_*=\{0,1,3,7\}.
$$

The saturation chain is

$$
R_0=\varnothing,
$$

$$
R_1=\{0\},
$$

$$
R_2=\{0,1\},
$$

$$
R_3=\{0,1,3\},
$$

$$
R_4=\{0,1,3,7\}=R_5.
$$

The full state space $X$ is also forward invariant and contains $I$, but it is not least. This example simultaneously illustrates finite operational reachability, convergence of the approximation chain, and the distinction between a canonical least solution and unrestricted uniqueness.

For multiple initial conditions, take $I=\{0,2\}$. The second orbit is

$$
2\mapsto5\mapsto3\mapsto7,
$$

so the least region becomes

$$
R_*=\{0,1,2,3,5,7\}.
$$

The closure is the union of the finite forward orbits of all initial states.

## 8. Applications

### 8.1 Program semantics

A loop or recursive definition often denotes the least solution of a monotone equation. The least solution excludes behavior not generated by finite unfolding. The Fixed-Point Diagonal Theorem shows that a two-level recursive specification, in which a program parameter and its execution are each resolved by least semantics, agrees with direct diagonal self-application when the simulator is jointly monotone.

### 8.2 Safety and model checking

In finite-state verification, $R_*$ is the exact reachable set. If $B\subseteq X$ is a set of forbidden states, safety is equivalent to

$$
R_*\cap B=\varnothing.
$$

Frontier exploration either exhausts the reachable region or finds a finite witness path to a bad state. The least-region characterization also supports invariant proofs: any admissible $R$ disjoint from $B$ contains all reachable states and therefore certifies safety.

### 8.3 Dynamical systems and control

Forward-invariant regions are central to safety constraints. The construction here gives the smallest set-theoretic invariant containing specified initial conditions. It should not be confused with a topological closure, a viability kernel, or an attractor. Those concepts incorporate neighborhoods, control choices, limiting behavior, or backward conditions absent from the present model.

### 8.4 Geometry of generated regions

The power-set lattice treats regions extensionally. If $X$ carries additional geometry, one may instead study closed, measurable, convex, or otherwise structured regions. The operator $R\mapsto I\cup s[R]$ need not preserve such classes. One may have to replace it with a closure-enhanced operator, for example

$$
F_{\mathrm{cl}}(R)=\overline{I\cup s[R]},
$$

and then prove monotonicity and preservation in the chosen lattice. The abstract least-fixed-point theorem remains applicable once completeness is established.

## 9. Limitations and interpretation

The mathematical results isolate a valid core of self-simulation, but they do not establish that actual physical laws arise this way. To make that claim, one must specify what the elements of $A$ represent, why their order is physically meaningful, how $U$ is derived from a physical theory, and why least-solution semantics is empirically appropriate.

Three limitations deserve emphasis.

First, monotonicity does not imply a unique fixed point. The canonical object is the least fixed point, unique under generated semantics. Unrestricted uniqueness requires stronger hypotheses.

Second, finite reachability is not asymptotic attraction. A state may be reachable without nearby states converging toward it; an invariant region may contain several disconnected cycles. Attraction requires a topology or metric and a convergence notion.

Third, the framework supplies no equation for the fine-structure constant or any other measured dimensionless constant. In particular, the approximate value $\alpha\approx1/137.036$ cannot be inferred from the existence or minimality of a lattice fixed point. A valid prediction would require an independently motivated map from self-consistent laws to observables and a derivation showing that the observable is uniquely determined.

These limitations are not defects in the theorems. They separate what follows from order theory from what must come from physics.

## 10. Future directions

Several extensions would deepen the bridge among semantics, dynamics, and geometry.

1. Replace arbitrary subsets by closed or measurable regions and identify hypotheses under which the transition preserves the relevant structure.
2. Develop an $\omega$-continuous setting in which the least law is the supremum of the finite approximation chain for general simulators.
3. Replace the deterministic map $s:X\to X$ by a nondeterministic transition relation and identify the least invariant region with reflexive-transitive reachability.
4. Add computability structure and define computational equivalence by mutual simulation or bisimulation.
5. Study contractions, antisymmetric simulation quotients, and other conditions that yield unrestricted fixed-point uniqueness.
6. Relate invariant regions to attractors only after adding metric or topological assumptions sufficient for asymptotic conclusions.
7. Connect dimensionless physical constants to the framework only through an independently justified physical model mapping lattice semantics to measurable quantities.

## 11. Conclusion

A monotone binary simulator on a complete lattice possesses a canonical least self-consistent law. Resolving simulation in two nested stages gives exactly the same least law as diagonal self-application. When laws are subsets of a state space and evolution is generated by a deterministic transition, the canonical law is the unique least forward-invariant region containing the initial conditions. A state belongs to this region exactly when some finite execution reaches it.

The resulting picture is unified and precise: fixed points provide denotational meaning, finite iteration provides operational meaning, and invariant regions provide geometric meaning. The framework validates a disciplined mathematical form of self-computation while sharply separating least-solution existence from unrestricted uniqueness and abstract semantics from numerical physical prediction.
