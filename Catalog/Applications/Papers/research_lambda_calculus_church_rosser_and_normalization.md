# Confluence and Normalization in the Untyped Lambda Calculus: A Verified Development via Parallel Reduction and Complete Developments

**Author:** Aristotle

**Date:** 2026-06-26

## Abstract

We present a self-contained, machine-verified development of the
metatheory of the untyped lambda calculus, organized around the
Church–Rosser theorem (confluence of beta reduction). The development
uses the Tait/Martin-Löf method of *parallel reduction* together with
Takahashi's *complete development*, a deterministic function that
contracts every redex present in a term in a single sweep. The
load-bearing result is the **triangle property**: every parallel reduct
of a term $t$ parallel-reduces to the complete development
$\mathrm{cd}(t)$. From the triangle property the **diamond property** of
parallel reduction follows in one line, with the common reduct given
explicitly as $\mathrm{cd}(t)$; and because the reflexive–transitive
closures of single-step beta reduction and of parallel reduction
coincide, the diamond property lifts to full **confluence of beta
reduction**. We complement the confluence theory with a treatment of
non-termination and finite Böhm-tree approximants, proving in particular
that the canonical divergent term $\Omega$ approximates to $\bot$ at every
depth. We discuss the syntactic infrastructure (de Bruijn indices,
lifting, substitution and their commutation laws) on which the proofs
rest, give algorithmic descriptions suitable for implementation, and
survey applications to programming-language semantics and the
undecidability of lambda-term equivalence.

**Keywords:** lambda calculus, beta reduction, Church–Rosser theorem,
confluence, parallel reduction, complete development, Takahashi triangle,
de Bruijn indices, normalization, Böhm tree.

---

## 1. Introduction

The untyped lambda calculus is the canonical model of higher-order
computation: a minimal language of variables, abstraction, and
application, with a single computation rule, beta reduction. Its
expressive power is total — it captures exactly the computable functions
— and yet its syntax is small enough that its metatheory can be developed
with complete rigor.

The central structural fact about beta reduction is *confluence*, the
property that the order in which redexes are contracted does not affect
the final result. Confluence underlies the well-definedness of functional
program evaluation and the uniqueness of normal forms. Historically it is
also notorious: the naive strategy of proving a one-step diamond property
and iterating fails, because beta reduction does not enjoy the diamond
property — contracting a redex can duplicate other redexes, so two
one-step reducts of a fork cannot in general be rejoined in one step
each.

The standard resolution, originating with Tait and Martin-Löf and refined
by Takahashi, introduces **parallel reduction**, a relation that contracts
an arbitrary set of *currently present* redexes simultaneously. Parallel
reduction has the diamond property, and its reflexive–transitive closure
coincides with that of beta reduction, so its confluence transfers.
Takahashi's contribution was to make the diamond proof entirely explicit:
she defined a function, the **complete development**, that contracts *all*
present redexes, and proved that every parallel reduct of $t$
parallel-reduces to this single canonical term. The diamond property then
becomes a trivial corollary.

This paper records a fully formalized version of this development, in
which every lemma is mechanically checked from first principles, together
with a treatment of non-termination via Böhm-tree approximants. The
contributions are:

1. A clean axiomatization of parallel reduction and a structural-recursive
   definition of the complete development for de Bruijn syntax
   (Section 3).
2. The substitution-commutation lemmas for parallel reduction that make
   the triangle property provable (Section 4).
3. The triangle property, the diamond property, the
   beta/parallel closure equivalence, and the Church–Rosser theorem
   (Section 5).
4. Finite Böhm-tree approximants, with the divergence of $\Omega$
   captured as $\bot$ at every depth, and basic properties of bounded
   reduction sets (Section 6).
5. Algorithmic and numerical illustrations (Sections 7–8).

---

## 2. The syntax of terms

We use **de Bruijn indices**, which represent a bound variable by the
number of enclosing abstractions between the variable and its binder.
This eliminates named-variable capture issues and makes substitution a
purely arithmetic operation, which is essential for a formal treatment.

**Definition 2.1 (Terms).** The set $\Lambda$ of lambda terms is generated
by
$$t ::= \mathrm{var}\,n \;\mid\; \mathrm{lam}\,t \;\mid\; \mathrm{app}\,t\,t,
\qquad n \in \mathbb{N}.$$
Here $\mathrm{var}\,n$ is the variable with de Bruijn index $n$,
$\mathrm{lam}\,t$ is the abstraction $\lambda.\,t$ (the bound variable is
positional, hence nameless), and $\mathrm{app}\,a\,b$ is application,
written $a\,b$.

To define substitution we need two auxiliary operations.

**Definition 2.2 (Lifting).** The *lift* (or shift) operation
$\mathrm{lift}\,c\,t$ increments every free variable of $t$ whose index is
$\geq c$:
$$
\mathrm{lift}\,c\,(\mathrm{var}\,n) =
\begin{cases} \mathrm{var}\,(n+1) & n \geq c\\ \mathrm{var}\,n & n < c\end{cases},
\quad
\mathrm{lift}\,c\,(\mathrm{lam}\,t) = \mathrm{lam}\,(\mathrm{lift}\,(c{+}1)\,t),
$$
$$
\mathrm{lift}\,c\,(\mathrm{app}\,a\,b) = \mathrm{app}\,(\mathrm{lift}\,c\,a)\,(\mathrm{lift}\,c\,b).
$$
The cutoff $c$ is incremented under a binder because that binder shields
one more index.

**Definition 2.3 (Substitution).** The operation $\mathrm{subst}\,j\,s\,t$
replaces the free variable $j$ of $t$ by $s$, lowering the indices of the
variables above the hole and lifting $s$ as it crosses binders:
$$
\mathrm{subst}\,j\,s\,(\mathrm{var}\,n) =
\begin{cases}
s & n = j\\
\mathrm{var}\,(n-1) & n > j\\
\mathrm{var}\,n & n < j
\end{cases},
$$
$$
\mathrm{subst}\,j\,s\,(\mathrm{lam}\,t) = \mathrm{lam}\,(\mathrm{subst}\,(j{+}1)\,(\mathrm{lift}\,0\,s)\,t),
$$
$$
\mathrm{subst}\,j\,s\,(\mathrm{app}\,a\,b) = \mathrm{app}\,(\mathrm{subst}\,j\,s\,a)\,(\mathrm{subst}\,j\,s\,b).
$$
The single-variable case used by beta contraction is
$$\mathrm{subst}_0\,u\,t := \mathrm{subst}\,0\,u\,t.$$

These operations satisfy the usual commutation laws — in particular a
lift/substitution interchange law (`lift_subst_ge`) and a
substitution/substitution interchange law (`subst0_subst`) — which are the
arithmetic backbone of every congruence proof below.

**Definition 2.4 (Beta reduction).** Single-step beta reduction
$\mathrm{Beta} \subseteq \Lambda \times \Lambda$ is the compatible closure
of the contraction rule:
$$
\frac{}{(\mathrm{lam}\,t)\,u \;\to\; \mathrm{subst}_0\,u\,t}\;(\beta)
\qquad
\frac{a \to a'}{a\,b \to a'\,b}
\qquad
\frac{b \to b'}{a\,b \to a\,b'}
\qquad
\frac{t \to t'}{\mathrm{lam}\,t \to \mathrm{lam}\,t'}.
$$
Its reflexive–transitive closure is written $\mathrm{BetaStar}$, i.e.
$\twoheadrightarrow_\beta \;=\; \mathrm{Beta}^{*}$. A term is in
**normal form** if it has no beta reduct.

---

## 3. Parallel reduction and complete developments

**Definition 3.1 (Parallel reduction).** The relation
$\mathrm{Par} \subseteq \Lambda \times \Lambda$, written
$t \Rightarrow u$, is defined inductively by
$$
\frac{}{\mathrm{var}\,n \Rightarrow \mathrm{var}\,n}
\qquad
\frac{t \Rightarrow t'}{\mathrm{lam}\,t \Rightarrow \mathrm{lam}\,t'}
\qquad
\frac{a \Rightarrow a' \quad b \Rightarrow b'}{a\,b \Rightarrow a'\,b'}
$$
$$
\frac{t \Rightarrow t' \quad u \Rightarrow u'}
{(\mathrm{lam}\,t)\,u \;\Rightarrow\; \mathrm{subst}_0\,u'\,t'}\;(\beta_{\Rightarrow}).
$$
Intuitively, a single parallel step contracts an arbitrary subset of the
redexes *already present* in the source, reducing congruently everywhere
else.

**Lemma 3.2 (Reflexivity, `par_refl`).** For every $t$, $t \Rightarrow t$.
*Proof.* Structural induction on $t$, using the variable, lambda, and
application clauses. $\square$

**Lemma 3.3 (Beta is parallel, `par_of_beta`).** If $t \to_\beta u$ then
$t \Rightarrow u$.
*Proof.* Induction on the derivation of $t \to_\beta u$. The contraction
rule maps to $\beta_{\Rightarrow}$ with reflexive premises; the three
congruence rules map to the corresponding parallel clauses with a
reflexive sibling. $\square$

**Definition 3.4 (Complete development, `cd`).** The function
$\mathrm{cd} : \Lambda \to \Lambda$ contracts every redex present in its
argument:
$$
\mathrm{cd}(\mathrm{var}\,n) = \mathrm{var}\,n,
\qquad
\mathrm{cd}(\mathrm{lam}\,t) = \mathrm{lam}\,(\mathrm{cd}\,t),
$$
$$
\mathrm{cd}\big((\mathrm{lam}\,t)\,u\big) = \mathrm{subst}_0\,(\mathrm{cd}\,u)\,(\mathrm{cd}\,t),
\qquad
\mathrm{cd}(a\,b) = (\mathrm{cd}\,a)\,(\mathrm{cd}\,b)\ \text{otherwise.}
$$
The third clause fires the head redex while developing both of its
constituents; the fourth applies when the operator $a$ is not an
abstraction.

---

## 4. Parallel reduction respects substitution

The triangle property requires that parallel reduction be a congruence
for the substitution algebra. These are the technically delicate lemmas,
each proved by induction with the de Bruijn arithmetic laws of Section 2.

**Lemma 4.1 (Commutation with lifting, `par_lift`).** If $t \Rightarrow t'$
then $\mathrm{lift}\,c\,t \Rightarrow \mathrm{lift}\,c\,t'$ for every
cutoff $c$.
*Proof.* Induction on $t \Rightarrow t'$, generalizing over $c$. The only
non-routine case is $\beta_{\Rightarrow}$, which is reconciled with the
lift via the lift/substitution interchange law `lift_subst_ge`. $\square$

**Lemma 4.2 (Congruence for substitution, `par_subst`).** If
$s \Rightarrow s'$ and $t \Rightarrow t'$ then
$\mathrm{subst}\,j\,s\,t \Rightarrow \mathrm{subst}\,j\,s'\,t'$ for every
$j$.
*Proof.* Induction on $t \Rightarrow t'$, generalizing over $j$, $s$, $s'$.
The variable case splits on equality with $j$ and uses reflexivity; the
lambda case crosses a binder using `par_lift` on the substituted term; the
$\beta_{\Rightarrow}$ case is closed by the substitution interchange law
`subst0_subst`. $\square$

**Corollary 4.3 (Congruence for beta contraction, `par_subst0`).** If
$u \Rightarrow u'$ and $t \Rightarrow t'$ then
$\mathrm{subst}_0\,u\,t \Rightarrow \mathrm{subst}_0\,u'\,t'$.
*Proof.* The case $j = 0$ of Lemma 4.2. $\square$

---

## 5. The triangle, the diamond, and Church–Rosser

**Theorem 5.1 (Triangle property, `par_triangle`).** If $t \Rightarrow u$
then $u \Rightarrow \mathrm{cd}(t)$.

*Proof sketch.* Structural induction on $t$, with the parallel step $u$
generalized.
- **Variable.** $t = \mathrm{var}\,n$ forces $u = \mathrm{var}\,n$ and
  $\mathrm{cd}(t) = \mathrm{var}\,n$; apply reflexivity.
- **Abstraction.** $t = \mathrm{lam}\,s$. The only way $t \Rightarrow u$ is
  $u = \mathrm{lam}\,s'$ with $s \Rightarrow s'$; the induction hypothesis
  gives $s' \Rightarrow \mathrm{cd}(s)$, and the lambda clause concludes.
- **Application $t = a\,b$.** Case on whether the operator $a$ is an
  abstraction.
  - If $a$ is *not* an abstraction, then $u = a'\,b'$ with
    $a \Rightarrow a'$, $b \Rightarrow b'$; the induction hypotheses give
    $a' \Rightarrow \mathrm{cd}(a)$, $b' \Rightarrow \mathrm{cd}(b)$, and
    the application clause yields
    $u \Rightarrow \mathrm{cd}(a)\,\mathrm{cd}(b) = \mathrm{cd}(t)$.
  - If $a = \mathrm{lam}\,s$, the redex case, then $t \Rightarrow u$ arises
    in one of two ways. Either $u = (\mathrm{lam}\,s')\,b'$ was obtained
    *without* firing the head redex (congruence), in which case inverting
    the induction hypothesis on $\mathrm{lam}\,s$ and applying
    $\beta_{\Rightarrow}$ contracts it now to reach
    $\mathrm{subst}_0\,(\mathrm{cd}\,b)\,(\mathrm{cd}\,s) = \mathrm{cd}(t)$;
    or $u = \mathrm{subst}_0\,b''\,s''$ was obtained *by* firing the head
    redex, in which case Corollary 4.3 (`par_subst0`) joins the developed
    parts to the same target $\mathrm{cd}(t)$.

In every case $u \Rightarrow \mathrm{cd}(t)$. $\square$

**Theorem 5.2 (Diamond property, `par_diamond`).** If $t \Rightarrow u$
and $t \Rightarrow v$ then there exists $w$ with $u \Rightarrow w$ and
$v \Rightarrow w$.
*Proof.* Take $w := \mathrm{cd}(t)$. By the triangle property
$u \Rightarrow \mathrm{cd}(t)$ and $v \Rightarrow \mathrm{cd}(t)$. $\square$

The diamond witness is *explicit and canonical*: it is the complete
development of the common source, computed once, independent of the two
branches. This is the conceptual payoff of Takahashi's method.

To transfer confluence to beta reduction we relate the two
reflexive–transitive closures. Three congruence lemmas for
$\mathrm{BetaStar}$ are needed.

**Lemma 5.3 (BetaStar congruences, `betaStar_lam`, `betaStar_appL`,
`betaStar_appR`).** $\twoheadrightarrow_\beta$ is closed under
$\mathrm{lam}(\cdot)$, under $(\cdot)\,b$, and under $a\,(\cdot)$.
*Proof.* Each by induction on the closure, prefixing a single congruent
beta step at each tail. $\square$

**Lemma 5.4 (Parallel splits into beta, `betaStar_of_par`).** If
$t \Rightarrow u$ then $t \twoheadrightarrow_\beta u$.
*Proof.* Structural induction on $t$, inverting the parallel step. The
congruence cases are assembled from Lemma 5.3. The $\beta_{\Rightarrow}$
case first reduces operator and operand congruently to the developed
forms, then fires the head redex with a single $\beta$ step. $\square$

**Proposition 5.5 (Closures coincide, `reflTransGen_beta_iff_par`).** For
all $t, u$,
$$t \twoheadrightarrow_\beta u \iff t \Rightarrow^{*} u.$$
*Proof.* ($\Rightarrow$) Monotonicity: every beta step is a parallel step
(Lemma 3.3). ($\Leftarrow$) Induction on the parallel closure, expanding
each parallel step into a beta sequence via Lemma 5.4. $\square$

**Theorem 5.6 (Church–Rosser / confluence of beta, `church_rosser_beta`).**
If $t \twoheadrightarrow_\beta u$ and $t \twoheadrightarrow_\beta v$ then
there exists $w$ with $u \twoheadrightarrow_\beta w$ and
$v \twoheadrightarrow_\beta w$.
*Proof.* By Proposition 5.5, $t \Rightarrow^{*} u$ and
$t \Rightarrow^{*} v$. The diamond property (Theorem 5.2) says
$\mathrm{Par}$ has the diamond, and any relation with the diamond property
has a confluent reflexive–transitive closure (the standard
strip/tile lemma). Hence there is $w$ with $u \Rightarrow^{*} w$ and
$v \Rightarrow^{*} w$; translating back by Proposition 5.5 gives
$u \twoheadrightarrow_\beta w$ and $v \twoheadrightarrow_\beta w$.
$\square$

**Corollary 5.7 (Uniqueness of normal forms).** If
$t \twoheadrightarrow_\beta u$ and $t \twoheadrightarrow_\beta v$ with $u$
and $v$ in normal form, then $u = v$.
*Proof.* By Theorem 5.6 there is a common reduct $w$; since $u$ and $v$
are normal they each equal $w$. $\square$

---

## 6. Non-termination and Böhm-tree approximants

Confluence guarantees uniqueness of normal forms but not their existence.
The canonical counterexample is built from self-application.

**Definition 6.1 (Combinators).** Write $I := \mathrm{lam}\,(\mathrm{var}\,0)$
for the identity, $\delta := \mathrm{lam}\,(\mathrm{app}\,(\mathrm{var}\,0)\,(\mathrm{var}\,0))$
for the self-applicator, and
$$\Omega := \mathrm{app}\,\delta\,\delta = (\lambda x.\,x\,x)(\lambda x.\,x\,x).$$
Beta-contracting the single redex of $\Omega$ returns $\Omega$, so $\Omega$
has no normal form.

To analyze such terms we use finite Böhm-tree approximants.

**Definition 6.2 (Approximants, `BTApprox`).** A *Böhm-tree approximant*
is
$$b ::= \bot \;\mid\; \mathrm{node}\,n\,[\,b_1, \dots, b_k\,],$$
where $\bot$ denotes divergence/undefined and $\mathrm{node}\,n\,\vec{b}$
denotes a head variable $n$ applied to approximated arguments.

**Definition 6.3 (Head reduction, head normal form, head extraction).**
- $\mathrm{headReduce}\,t$ fires the *head* redex if present:
  $\mathrm{headReduce}\big((\mathrm{lam}\,t)\,u\big) = \mathrm{some}\,(\mathrm{subst}_0\,u\,t)$,
  it recurses into the operator of a non-redex application, and is
  $\mathrm{none}$ otherwise.
- $\mathrm{isHNF}\,t$ tests for a head normal form (no head redex).
- $\mathrm{extractHead}\,t$ returns the head variable and the spine of
  arguments of a head normal form.

**Definition 6.4 (Bounded approximant, `bohmApprox`).** With a fuel
parameter $n$,
$$
\mathrm{bohmApprox}\,0\,t = \bot,
$$
$$
\mathrm{bohmApprox}\,(n{+}1)\,t =
\begin{cases}
\mathrm{bohmApprox}\,n\,t' & \text{if } \mathrm{headReduce}\,t = \mathrm{some}\,t'\\
\mathrm{node}\,h\,(\mathrm{map}\,(\mathrm{bohmApprox}\,n)\,\vec{a}) & \text{if } \mathrm{extractHead}\,t = \mathrm{some}\,(h,\vec{a})\\
\bot & \text{otherwise.}
\end{cases}
$$
The function first drives $t$ to head normal form by head reduction
(consuming fuel), then records the head and recursively approximates the
spine.

**Theorem 6.5 (Divergence of $\Omega$, `omega_bohmApprox_bot`).** For
every $n$, $\mathrm{bohmApprox}\,n\,\Omega = \bot$.
*Proof.* Induction on $n$. The base case is immediate. In the step,
$\mathrm{headReduce}\,\Omega = \mathrm{some}\,\Omega$, so
$\mathrm{bohmApprox}\,(n{+}1)\,\Omega = \mathrm{bohmApprox}\,n\,\Omega$,
which is $\bot$ by the induction hypothesis. $\square$

**Proposition 6.6 (Identity, `I_bohmApprox`).** For every $n$,
$\mathrm{bohmApprox}\,(n{+}1)\,I = \bot$.
*Proof.* $I = \mathrm{lam}\,(\mathrm{var}\,0)$ has no head redex and
$\mathrm{extractHead}$ returns $\mathrm{none}$ under a lambda, so the
"otherwise" branch yields $\bot$ by definitional reduction. $\square$

*Remark (stability is delicate).* A naive "approximants of a normal form
stabilize" statement is **false**: $\mathrm{app}\,(\mathrm{var}\,0)\,(\mathrm{var}\,0)$
is a normal form yet $\mathrm{bohmApprox}\,1$ gives
$\mathrm{node}\,0\,[\bot]$ while $\mathrm{bohmApprox}\,2$ gives
$\mathrm{node}\,0\,[\mathrm{node}\,0\,[]]$. A correct stability statement
must bound the term's depth. The formalization records this counterexample
explicitly rather than asserting a false lemma.

Finally, the development records elementary facts about *bounded reduction
sets*, used to reason about reachable terms.

**Definition 6.7 (Reducts up to depth, `reductsUpToDepth`).**
$\mathrm{reductsUpToDepth}\,t\,0 = \{t\}$ and
$\mathrm{reductsUpToDepth}\,t\,(d{+}1)$ is the union of
$\mathrm{reductsUpToDepth}\,t\,d$ with the one-step beta reducts of all its
members.

**Proposition 6.8 (`mem_reductsUpToDepth_self`,
`reductsUpToDepth_mono`, `reductsUpToDepth_nf`).** A term lies in its own
reduct set at every depth; the reduct set is monotone in depth; and for a
normal form $t$, $\mathrm{reductsUpToDepth}\,t\,d = \{t\}$ for all $d$.
*Proof.* Each by induction on $d$, using that a normal form has no
one-step reducts. $\square$

---

## 7. Algorithms

The constructive content of the development yields directly executable
procedures.

**Algorithm A (Complete development).** `cd` is a structural recursion on
the term (Definition 3.4). Each application node performs at most one
substitution, so on a term of size $s$ it runs in $O(s)$ recursive
calls plus the cost of the substitutions it triggers; substitution is
linear in the size of the body, giving an $O(s^2)$ worst case for
duplicating redexes. Iterating $\mathrm{cd}$ realizes the *Gross–Knuth*
(full-development) reduction strategy, which reaches the normal form (when
one exists) in a number of rounds equal to the developmental depth of the
term.

**Algorithm B (Confluence joiner).** Given two reduction sequences
$t \twoheadrightarrow_\beta u$ and $t \twoheadrightarrow_\beta v$, the
proof of Theorem 5.6 is constructive: reinterpret both sequences as
parallel reductions, and tile the resulting grid using the explicit
diamond witness $\mathrm{cd}(\cdot)$ at each cell. The common reduct $w$ is
produced together with the two joining sequences. The number of tiles is
bounded by the product of the two sequence lengths.

**Algorithm C (Böhm approximant).** `bohmApprox` (Definition 6.4) is a
fuel-bounded head-reduction-then-recurse procedure. With fuel $n$ it
performs at most $n$ head reductions before recording a node or $\bot$,
guaranteeing termination even on divergent input; the fuel parameter is
precisely what makes a partial-by-nature computation total.

---

## 8. Numerical and symbolic illustrations

The companion program (`demo.py`) implements the de Bruijn syntax,
substitution algebra, single-step and parallel reduction, the complete
development, and Böhm approximants exactly as above, and checks the
theorems on concrete terms.

- **Confluence.** For
  $t = \big((\lambda x.\,x)\,((\lambda x.\,x)\,y)\big)\,\big((\lambda x.\,x)\,z\big)$
  the program enumerates the distinct one-step reducts, computes
  $\mathrm{cd}(t)$, and verifies that all branches normalize to the same
  term, illustrating Theorem 5.6 and Corollary 5.7.
- **Triangle.** For a term with nested redexes the program enumerates
  *every* parallel reduct $u$ and confirms that $\mathrm{cd}(t)$ is among
  the parallel reducts of each $u$, i.e. $u \Rightarrow \mathrm{cd}(t)$
  (Theorem 5.1).
- **Diamond.** It checks that the explicit witness $\mathrm{cd}(t)$ joins
  every pair of parallel reducts (Theorem 5.2).
- **Normalization vs. divergence.** It reduces $S\,K\,K\,x$ to $x$, and
  shows $\Omega \to \Omega$; the Böhm approximant of $\Omega$ is $\bot$ at
  every depth (Theorem 6.5).

---

## 9. Applications and discussion

**Programming-language semantics.** Confluence is the formal guarantee
that the *result* of a functional program is independent of evaluation
order, justifying the freedom compilers and runtimes take in scheduling
reductions (call-by-name, call-by-value, lazy graph reduction). Uniqueness
of normal forms (Corollary 5.7) is the semantic bedrock on which
referential transparency rests.

**Proof assistants and type theory.** Dependently typed proof assistants
rely on confluence (and, in their typed cores, strong normalization) to
make definitional equality decidable, which is exactly what makes type
checking — and hence machine-checked proof — possible. The
parallel-reduction/complete-development technique formalized here is the
standard route to confluence for the calculi underlying such systems, and
generalizes smoothly to richer rewriting systems with the same triangle
skeleton.

**The horizon: undecidability.** Böhm trees (Section 6) are the gateway to
the semantic theory of the lambda calculus. Two closed terms are
observationally interchangeable precisely when their Böhm trees agree
(modulo the appropriate notion of equivalence), and Böhm's separation
theorem shows that distinct normal-form Böhm trees can always be told
apart by some applicative context. The flip side, established through this
same theory, is that *equivalence of lambda terms is undecidable*: no
algorithm decides, for arbitrary $M$ and $N$, whether $M$ and $N$ denote
the same function. The divergence analysis of $\Omega$ — the fact that it
reveals nothing, approximating to $\bot$ everywhere — is the simplest
instance of the phenomenon that makes this undecidability unavoidable.

**On the formalization.** Working with de Bruijn indices trades the
intuitive readability of named variables for arithmetic precision: the
lift/substitution and substitution/substitution interchange laws
(Section 2) carry the entire weight that informal "without loss of
generality, rename bound variables" hand-waving usually hides. Concentrating
that difficulty into a handful of named, reusable commutation lemmas
(`par_lift`, `par_subst`, `par_subst0`) is what makes the headline proofs
(Sections 5–6) short and transparent.

---

## 10. Future directions

The development invites several extensions, in increasing order of ambition:

1. **Strong normalization for the simply typed calculus.** Layer a typing
   judgment over the present syntax and prove, via a logical-relations /
   reducibility-candidates argument, that every typable term is strongly
   normalizing. Combined with confluence this gives decidability of
   beta-equivalence on typable terms.

2. **Standardization and leftmost-outermost normalization.** Prove the
   standardization theorem and the corollary that the leftmost-outermost
   strategy is normalizing — if a normal form exists, this strategy finds
   it. The complete-development machinery here is the natural starting
   point.

3. **Full Böhm-tree theory and separation.** Extend the finite
   approximants to (coinductive) Böhm trees, prove monotonicity and limit
   properties, and formalize Böhm's separation theorem, en route to a
   rigorous account of the undecidability of lambda-term equivalence.

4. **Confluence transfer to extended calculi.** Reuse the triangle
   skeleton for $\beta\eta$-reduction, for calculi with constants and
   pattern matching, and for explicit-substitution calculi, demonstrating
   the modularity of the method.

---

## References (textbook background, for orientation only)

The results developed here are classical. The parallel-reduction method is
due to W. W. Tait and P. Martin-Löf; the complete-development streamlining
is due to M. Takahashi, *Parallel reductions in λ-calculus* (1995). De
Bruijn indices are from N. G. de Bruijn (1972). Böhm trees and the
separation theorem are due to C. Böhm; comprehensive treatments appear in
H. P. Barendregt, *The Lambda Calculus: Its Syntax and Semantics* (1984).
This paper is self-contained and does not depend on these sources for any
of its statements or proofs.
