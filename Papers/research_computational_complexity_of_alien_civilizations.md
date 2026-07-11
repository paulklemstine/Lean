# The Substrate-Independent Structure of Computation: A Universal Complexity Hierarchy and the Diagonal Core of Impossibility

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

We isolate the single mathematical fact that underlies every classical
obstruction in the theory of computation and show that, because it is a statement
of pure function theory, it is forced upon *any* civilization capable of
expressing the notion of a function — independently of biology, physics, or
machine model. The fact is Lawvere's fixed-point theorem: if a type $A$ admits a
*point-surjective* indexing $\varphi : A \to (A \to B)$ of its own $B$-valued
functions, then every endofunction $f : B \to B$ has a fixed point. From its
contrapositive we recover, uniformly, Cantor's theorem, the undecidability of the
halting problem, Gödel's first incompleteness theorem, Tarski's undefinability of
truth, and Russell's paradox, each obtained by choosing the answer type $B$ and a
fixed-point-free $f$. We then develop three consequences. First, we model an
arbitrary notion of computation as a bare *computation model* — a type of
programs with a Boolean acceptance relation — and prove **substrate
independence**: every such model contains a decision behavior no program
realizes, with no hypotheses whatsoever. Second, we relativize this to an
arbitrary oracle and prove the **hypercomputation barrier**: even granted an
unrestricted, possibly non-computable oracle, no oracle-program decides the
model's own jump; adding power relocates the obstruction one level up rather than
removing it. Third, we build the **universal complexity hierarchy** — the tower
$\mathrm{Level}\,0 = A$, $\mathrm{Level}\,(n+1) = (\mathrm{Level}\,n \to
\mathrm{Bool})$ — and prove it strictly increases at every step (an injection but
no surjection between consecutive levels, equivalently strictly increasing
cardinality) and has no maximal level. Finally we exhibit the positive face of
the same theorem: Kleene's recursion theorem and the existence of quines in any
complete programming system, together with the duality that a system complete for
its own program-transformations is never complete for its own Boolean decisions.
Every result is elementary and hypothesis-free at its core, making the entire
edifice a genuinely universal, discovered-not-invented feature of computation.

## 1. Introduction

A recurring thesis in the philosophy of computation holds that any technological
civilization — regardless of its biological or physical substrate — must
rediscover the same structural obstructions to computation. The thesis is
usually argued informally. Our aim is to give it a precise mathematical spine: to
identify the exact statement responsible for the obstructions, to verify that it
refers to no machine model or physical resource, and to derive from it, with full
rigor, the universal facts that any computing civilization must confront.

The organizing observation is that the classical impossibility results — Cantor's
theorem on the sizes of power sets, Turing's undecidability of the halting
problem, Gödel's first incompleteness theorem, Tarski's undefinability of truth,
and Russell's paradox — are not independent. They are instances of a single
theorem of elementary category/function theory: **Lawvere's fixed-point
theorem**. Because that theorem speaks only of types, functions, and fixed
points, it is available to any civilization that can express the notion of a
function. This is the precise content of the slogan "computational complexity is
discovered, not invented."

The paper is organized around four movements:

1. **The diagonal core** (§3): Lawvere's theorem, its contrapositive, and the
   Boolean special case (Cantor's theorem with its accompanying strict
   embedding).
2. **Substrate-independent uncomputability** (§4): an assumption-free model of
   computation, in which the diagonal behavior is provably unrealizable.
3. **The hypercomputation barrier** (§5): relativization to an arbitrary oracle,
   showing the obstruction is invariant under unrestricted added power.
4. **The universal hierarchy and the positive face** (§6–§7): an infinite,
   strictly increasing tower of decision-power levels with no top, and Kleene's
   recursion theorem with quines, exhibiting the creativity/limitation duality.

## 2. Preliminaries and notation

We work in a standard type-theoretic setting. For types $A$ and $B$ we write $A
\to B$ for the type of functions from $A$ to $B$. We write $\mathrm{Bool} =
\{\text{true}, \text{false}\}$ for the two-element type and $!\,{\cdot}$ for
Boolean negation. A function $f : X \to Y$ is *injective* if $f(x) = f(x')$
implies $x = x'$, and *surjective* if every $y : Y$ equals $f(x)$ for some $x$.
For a type $X$ we write $\lvert X \rvert$ for its cardinality; $2^{\kappa}$
denotes the cardinality of $X \to \mathrm{Bool}$ when $\lvert X \rvert = \kappa$.
We use throughout the trivial but load-bearing fact:

**Lemma 2.1 (Negation is fixed-point free).** *For every $b : \mathrm{Bool}$,
$b \neq \,!\,b$.*

*Proof.* Both cases $b = \text{true}$ and $b = \text{false}$ are checked
directly: $\text{true} \neq \text{false}$ and $\text{false} \neq \text{true}$.
$\qquad\blacksquare$

This single asymmetry — that a two-valued negation has no fixed point — is the
only "substrate input" the entire theory requires.

## 3. The diagonal core: Lawvere's fixed-point theorem

The central definition abstracts the idea of a coding scheme that names functions.

**Definition 3.1 (Point-surjectivity).** Let $A$ and $B$ be types. A map
$\varphi : A \to (A \to B)$ is **point-surjective** if for every $g : A \to B$
there exists $a : A$ with $\varphi(a) = g$. Intuitively, $\varphi$ assigns to
each *code* $a$ an $A$-parameterized *answer-function* $\varphi(a)$, and
point-surjectivity says every such answer-function is named by some code — "the
coding scheme is complete."

**Theorem 3.2 (Lawvere's fixed-point theorem).** *If $\varphi : A \to (A \to B)$
is point-surjective, then every $f : B \to B$ has a fixed point: there exists
$b : B$ with $f(b) = b$.*

*Proof.* Consider the diagonal function $d : A \to B$ defined by
$d(x) = f(\varphi(x)(x))$. By point-surjectivity there is a code $a$ with
$\varphi(a) = d$. Evaluating at $a$,
$$\varphi(a)(a) = d(a) = f\big(\varphi(a)(a)\big).$$
Hence $b := \varphi(a)(a)$ satisfies $f(b) = b$. $\qquad\blacksquare$

The theorem's power comes from reading it in contrapositive.

**Theorem 3.3 (Abstract diagonal argument).** *If $f : B \to B$ has no fixed
point (i.e. $f(b) \neq b$ for all $b$), then no $\varphi : A \to (A \to B)$ is
point-surjective.*

*Proof.* Immediate from Theorem 3.2: a point-surjective $\varphi$ would produce a
fixed point of $f$, a contradiction. $\qquad\blacksquare$

Choosing $B = \mathrm{Bool}$ and $f = \,!\,{\cdot}$ (fixed-point free by Lemma
2.1) yields the Boolean incarnation. Since any surjective $\varphi$ is in
particular point-surjective, we obtain:

**Theorem 3.4 (Cantor's theorem, Boolean form).** *For every type $A$, no map
$\varphi : A \to (A \to \mathrm{Bool})$ is surjective. The space of decision
procedures on $A$ is strictly richer than $A$ itself.*

*Proof.* If $\varphi$ were surjective it would be point-surjective, and by
Theorem 3.3 the fixed-point-free negation $!\,{\cdot}$ could not exist — a
contradiction with Lemma 2.1. Concretely, the "anti-diagonal" $g(x) = \,!\,
\varphi(x)(x)$ differs from every $\varphi(a)$ at $a$, so $g$ is not in the range
of $\varphi$. $\qquad\blacksquare$

Cantor's theorem also has a *positive* half: while $A \to \mathrm{Bool}$ cannot
be covered from $A$, it always *contains* a copy of $A$.

**Theorem 3.5 (The strict Boolean-power step).** *For every type $A$ there is an
injection $A \hookrightarrow (A \to \mathrm{Bool})$, but no surjection $A \to (A
\to \mathrm{Bool})$.*

*Proof.* For the injection, send $a$ to its indicator $\mathbf{1}_a(x) =
[\,x = a\,]$ (true exactly when $x = a$). If $\mathbf{1}_a = \mathbf{1}_b$ then
evaluating at $b$ gives $[\,b = a\,] = [\,b = b\,] = \text{true}$, so $b = a$.
Non-surjectivity is Theorem 3.4. $\qquad\blacksquare$

**Instantiation table.** Every classical obstruction is Theorem 3.3 with a choice
of $B$ and $f$:

| Result | Answer type $B$ | Fixed-point-free $f$ | Reading of $\varphi(a)(x)$ |
|---|---|---|---|
| Cantor | $\mathrm{Bool}$ | negation | "$x$ is in the set coded by $a$" |
| Halting problem | $\mathrm{Bool}$ | negation | "program $a$ accepts program $x$" |
| Gödel incompleteness | sentences | "prepend $\neg$" (up to provability) | "$a$ is the code of a formula about $x$" |
| Tarski undefinability | truth values | negation | truth predicate applied to codes |
| Russell's paradox | $\mathrm{Bool}$ | negation | set membership |

No entry mentions a machine. This is the sense in which the diagonal argument is
*universal*.

## 4. Substrate-independent uncomputability

To formalize "any notion of computation" without importing a specific machine
model, we take the weakest possible structure.

**Definition 4.1 (Computation model).** A **computation model** consists of a type
$\mathrm{Pgm}$ of *programs* (equivalently, codes) together with a Boolean
*acceptance* relation $\mathrm{acc} : \mathrm{Pgm} \to \mathrm{Pgm} \to
\mathrm{Bool}$, where $\mathrm{acc}(p)(q)$ reads "program $p$ halts and accepts
the code of program $q$." No computability, finiteness, or structural assumption
is placed on $\mathrm{Pgm}$ or $\mathrm{acc}$.

**Definition 4.2 (Diagonal behavior).** The **diagonal behavior** of a model is
$\mathrm{diag} : \mathrm{Pgm} \to \mathrm{Bool}$, $\mathrm{diag}(q) = \,!\,
\mathrm{acc}(q)(q)$: on input $q$, return the opposite of what $q$ does on its
own code.

**Theorem 4.3 (Abstract undecidability).** *In every computation model, no program
realizes the diagonal behavior: for all $p$, $\mathrm{acc}(p) \neq
\mathrm{diag}$.*

*Proof.* If $\mathrm{acc}(p) = \mathrm{diag}$ then evaluating at $p$ gives
$\mathrm{acc}(p)(p) = \,!\,\mathrm{acc}(p)(p)$, contradicting Lemma 2.1.
$\qquad\blacksquare$

**Corollary 4.4 (Substrate independence).** *For every computation model there
exists a decision behavior $g : \mathrm{Pgm} \to \mathrm{Bool}$ outside the range
of $\mathrm{acc}$ — a "problem" no program solves. The statement holds with no
hypotheses on the model.*

*Proof.* Take $g = \mathrm{diag}$ and apply Theorem 4.3. $\qquad\blacksquare$

The complete absence of hypotheses is the point: the obstruction depends only on
the shape "programs acting on the codes that name them," never on what the
programs are made of. Instantiating $\mathrm{acc}$ with the halting-decider gives
the classical undecidability of the halting problem, but the statement itself is
model-free and therefore identical across all civilizations.

## 5. The hypercomputation barrier

One might hope to escape §4 by enlarging the model's power. We formalize
unrestricted added power as an arbitrary oracle.

**Definition 5.1 (Oracle model).** An **oracle model** consists of a type
$\mathrm{Pgm}$, an *arbitrary* function $\mathrm{oracle} : \mathrm{Pgm} \to
\mathrm{Bool}$ (a stand-in for an unrestricted, possibly non-computable resource),
and an oracle-relative acceptance relation $\mathrm{acc} : \mathrm{Pgm} \to
\mathrm{Pgm} \to \mathrm{Bool}$. The oracle is completely unconstrained; that
programs may consult it in any manner is already subsumed by allowing
$\mathrm{acc}$ to be arbitrary.

**Definition 5.2 (Jump).** The **jump** of an oracle model is
$\mathrm{jump}(q) = \,!\,\mathrm{acc}(q)(q)$, the diagonal behavior of the
enriched model.

**Theorem 5.3 (Oracle barrier).** *In every oracle model, no program decides the
model's own jump: for all $p$, $\mathrm{acc}(p) \neq \mathrm{jump}$.*

*Proof.* Identical to Theorem 4.3; the oracle plays no role in the diagonal.
$\qquad\blacksquare$

**Theorem 5.4 (Hypercomputation barrier, universal form).** *For every program
type $\mathrm{Pgm}$, every oracle $\mathrm{oracle} : \mathrm{Pgm} \to
\mathrm{Bool}$ whatsoever, and every acceptance relation $\mathrm{acc}$, there is
a decision behavior $g$ such that $\mathrm{acc}(p) \neq g$ for all $p$.*

*Proof.* Assemble the oracle model $(\mathrm{Pgm}, \mathrm{oracle},
\mathrm{acc})$ and take $g = \mathrm{jump}$; apply Theorem 5.3.
$\qquad\blacksquare$

Adding hypercomputational power does not dissolve the diagonal; it merely
relocates it one level up. The jump of a class is never internal to the class.
Consequently a civilization wielding hypercomputers meets an exact analog of the
halting problem: a question its enhanced machines cannot settle, answerable only
by a still-stronger machine that will, in turn, have its own jump. This is the
abstract seed of the relativization phenomenon (in the vein of Baker–Gill–Solovay)
and the reason diagonalization alone cannot resolve questions like P vs NP that
must distinguish oracle worlds.

## 6. The universal complexity hierarchy

A single Cantor step (Theorem 3.5) lifts a type to the strictly larger type of
its decision procedures. Iterating yields an unbounded tower.

**Definition 6.1 (Level tower).** For a base type $A$ define
$$\mathrm{Level}\,0 = A, \qquad \mathrm{Level}\,(n+1) = (\mathrm{Level}\,n \to
\mathrm{Bool}).$$
Level $n+1$ is the type of Boolean decision procedures over level $n$ — the
"problems about problems about $\cdots$ about $A$."

**Theorem 6.2 (Strict step).** *For every $n$ there is an injection
$\mathrm{Level}\,n \hookrightarrow \mathrm{Level}\,(n+1)$, and no surjection
$\mathrm{Level}\,n \to \mathrm{Level}\,(n+1)$.*

*Proof.* Both halves are Theorem 3.5 applied to $X = \mathrm{Level}\,n$: the
indicator embedding provides the injection, and Cantor's theorem forbids
surjection. $\qquad\blacksquare$

**Theorem 6.3 (Cardinal strict monotonicity).** *For every $n$,
$\lvert \mathrm{Level}\,n \rvert < \lvert \mathrm{Level}\,(n+1) \rvert$; more
generally $m < n$ implies $\lvert \mathrm{Level}\,m \rvert < \lvert
\mathrm{Level}\,n \rvert$.*

*Proof.* Since $\mathrm{Level}\,(n+1) = \mathrm{Level}\,n \to \mathrm{Bool}$, its
cardinality is $2^{\lvert \mathrm{Level}\,n \rvert}$, and Cantor's cardinal
inequality gives $\kappa < 2^{\kappa}$. The general case follows because a
strictly increasing step yields a strictly monotone sequence. $\qquad\blacksquare$

**Theorem 6.4 (No maximal level).** *For every $n$ there exists $m > n$ with
$\lvert \mathrm{Level}\,n \rvert < \lvert \mathrm{Level}\,m \rvert$. The
universal hierarchy has no top.*

*Proof.* Take $m = n+1$ and apply Theorem 6.3. $\qquad\blacksquare$

Because the construction and both proofs are pure function theory — no machine
model, no physics — this hierarchy is forced on every civilization. Whatever
decision-power a civilization attains (any finite level), a strictly greater level
provably exists, admitting the current level as a sub-power but not itself
reachable from it. This is the abstract skeleton onto which honest resource
hierarchies (time, space) can later be grafted by instantiating the levels with
an explicit resource measure.

## 7. The positive face: recursion, quines, and a duality

Read forward rather than backward, Theorem 3.2 becomes an existence principle for
self-reference.

**Definition 7.1 (Programming system).** A **programming system** consists of a
type $\mathrm{Pgm}$ of programs and a map $\mathrm{build} : \mathrm{Pgm} \to
(\mathrm{Pgm} \to \mathrm{Pgm})$ that indexes program-transformations by
programs, such that $\mathrm{build}$ is point-surjective — every transformation
$\mathrm{Pgm} \to \mathrm{Pgm}$ is named by some program. This is the abstract
content of an *acceptable programming system* (closure under the $s$-$m$-$n$
theorem).

**Theorem 7.2 (Kleene's recursion theorem, abstract form).** *In a programming
system, every transformation $f : \mathrm{Pgm} \to \mathrm{Pgm}$ has a fixed
program $e$ with $f(e) = e$.*

*Proof.* Apply Theorem 3.2 with $A = B = \mathrm{Pgm}$ and $\varphi =
\mathrm{build}$. $\qquad\blacksquare$

**Corollary 7.3 (Existence of quines).** *Reading $\mathrm{printer} :
\mathrm{Pgm} \to \mathrm{Pgm}$ as "the program a given program becomes when asked
to describe itself," there is a program $e$ with $\mathrm{printer}(e) = e$: a
self-reproducing program. Every complete programming system possesses quines.*

*Proof.* Instantiate Theorem 7.2 with $f = \mathrm{printer}$. $\qquad\blacksquare$

**Theorem 7.4 (No complete self-semantics — the duality).** *Even in a
programming system that is complete for its own transformations, there is no
complete Boolean self-semantics: for every assignment $\mathrm{sem} :
\mathrm{Pgm} \to (\mathrm{Pgm} \to \mathrm{Bool})$ of decision behaviors to
programs there is a behavior $g$ with $\mathrm{sem}(p) \neq g$ for all $p$.*

*Proof.* Take $g(q) = \,!\,\mathrm{sem}(q)(q)$; evaluating any putative
$\mathrm{sem}(p) = g$ at $p$ contradicts Lemma 2.1. $\qquad\blacksquare$

Theorems 7.2 and 7.4 coexist in a single system: completeness *for
transformations* (answer type $\mathrm{Pgm}$) and incompleteness *for decisions*
(answer type $\mathrm{Bool}$) are both Lawvere's theorem, differing only in the
answer type. Creativity (self-reference, quines, self-modifying and
self-compiling systems) and limitation (uncomputability) are not opposing forces
but two readings of one theorem.

**On non-vacuity.** In the full set-theoretic universe, a system complete for
*all* its transformations $\mathrm{Pgm} \to \mathrm{Pgm}$ is forced to have a
subsingleton program type (another shadow of the diagonal), so the pure-set
instance of Theorem 7.2 is degenerate; the non-degenerate instances live in the
computable category, where acceptable programming systems satisfy
point-surjectivity via the $s$-$m$-$n$ theorem — the classical Kleene setting.
The uncomputability theorems of §4–§6, by contrast, are non-vacuous already for
concrete models (e.g. $\mathrm{Pgm} = \mathbb{N}$ with any acceptance relation).

## 8. Algorithms

Although the results are impossibility theorems, they are constructive: each
supplies an explicit *witness* — a behavior demonstrably outside a given range —
computed by a short algorithm.

**Algorithm A (Anti-diagonal witness).** Given a finite tabulation of a candidate
enumeration $\varphi$ of decision procedures on a finite domain, produce the
decision procedure $g(x) = \,!\,\varphi(x)(x)$ and verify it differs from every
$\varphi(a)$ at the point $a$. Complexity: $O(n)$ evaluations for a domain of
size $n$; the verification is $O(n)$ point checks.

**Algorithm B (Level cardinality).** Given a finite base of size $k$ and a level
index $n$, compute $\lvert \mathrm{Level}\,n \rvert$ by the recurrence
$c_0 = k$, $c_{i+1} = 2^{c_i}$, exhibiting the tower-of-exponentials growth that
witnesses strict monotonicity.

**Algorithm C (Fixed program / quine search).** In a finite complete system given
by a table $\mathrm{build}$, and a transformation $f$, find a fixed program by
forming the diagonal code and reading off Lawvere's witness $\varphi(a)(a)$;
verify $f(e) = e$.

Pseudocode and typed implementations of all three accompany this work.

## 9. Applications and discussion

**Why this matters for the "alien" thesis.** The results give a mathematically
exact form to the claim that computational limits are universal. Any civilization
able to form the concept of a function from codes to answers possesses Lawvere's
theorem; from it, Cantor, the halting problem, the endless hierarchy, the oracle
barrier, and Kleene's recursion theorem follow without any further assumptions.
The limits are therefore *discovered* features of an abstract structure, not
*invented* features of a particular technology.

**Relation to P vs NP.** The framework suggests treating resource-bounded
complexity classes as closure operators on decision behaviors and phrasing
separations as properties of the resulting closure lattice. The oracle barrier
(Theorem 5.4) is the abstract seed of relativization: because the diagonal
survives every oracle, diagonalization alone cannot separate classes that behave
differently across oracle worlds. This is the structural reason a resolution of P
vs NP must go beyond pure diagonal methods — a substrate-independent meta-fact.

**Relation to physics and hypercomputation.** The oracle formalizes any
physical resource, however exotic, as an arbitrary Boolean function. Theorem 5.4
then says that no proposed hypercomputer removes the diagonal obstruction; it
merely defines a new, higher jump. Impossibility is stable under physical
augmentation.

## 10. Future work

Several directions extend the present development:

1. **P vs NP as structure, not model.** Formalize abstract resource-bounded
   classes as closure operators on decision behaviors and state
   P-vs-NP-type separations as properties of the closure lattice. The oracle
   barrier is the seed of a Baker–Gill–Solovay-style theorem: construct oracles
   $A, B$ with $\mathrm{P}^A = \mathrm{NP}^A$ and $\mathrm{P}^B \neq
   \mathrm{NP}^B$, proving that diagonalization alone cannot settle P vs NP.

2. **A concrete time/space hierarchy theorem.** Instantiate the abstract level
   tower with an explicit resource measure (step counts of a universal
   simulator) and prove $\mathrm{DTIME}(f) \subsetneq \mathrm{DTIME}(g)$ for
   $f = o(g/\log g)$ via the same diagonal, connecting the cardinal hierarchy to
   an honest complexity hierarchy.

3. **Kleene's recursion theorem in the computable category.** Replace the
   set-theoretically degenerate point-surjectivity hypothesis with an acceptable
   programming system, recovering the classical non-degenerate recursion theorem
   and its constructions.

## 11. Conclusion

A single line of pure function theory — Lawvere's fixed-point theorem — organizes
the entire landscape of computational impossibility. Read backward it yields
Cantor's theorem, the halting problem, Gödel's incompleteness, and an infinite
strictly increasing hierarchy with no top; relativized it yields a barrier that
survives arbitrary oracles; read forward it yields Kleene's recursion theorem and
quines. None of these results mentions a machine, a bit, or a physical resource.
They are theorems about the shape of computation itself and are therefore forced
on every possible computing civilization. In the deepest sense, the mathematics
of computation is the same across all worlds: it is discovered, not invented.
