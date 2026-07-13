# Self-Quantifying Types and the Diagonal Core of Self-Reference

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

We study the possibility of a *self-quantifying type*: a type $T$ that is equivalent to
its own space of predicates, $T \simeq (T \to \mathrm{Prop})$. Such a type would name,
and reflect on, every property it possesses from within. We prove that no self-quantifying
type exists, and we show that this impossibility, together with the classical theorems of
Cantor, Tarski, and Gödel, all descend from a single structural root: **Lawvere's
fixed-point theorem**, which states that a point-surjective family $A \to (A \to B)$
forces every self-map of $B$ to have a fixed point. Instantiating the value space with the
two-element logic of propositions, whose negation operator has no fixed point, yields at
once Cantor's theorem, the nonexistence of the self-quantifying equivalence, and its
quantitative shadow $\#\,T < \#\,(T \to \mathrm{Prop})$. Turning to self-referential
systems equipped with internal truth and provability predicates and a *restricted*
diagonal operator, we isolate a single parameter — the **definability gate** governing
which predicates the system may name — and show that Gödel's incompleteness and Tarski's
undefinability of truth differ *only* in the setting of this parameter: negated
provability is nameable and yields a true-but-unprovable sentence, whereas negated truth
is provably *not* nameable, on pain of contradiction. We supply a concrete satisfying
model, establishing that the results are not vacuous. The upshot is a unified account in
which the presence or absence of self-reference is controlled entirely by the fixed-point
geometry of the value space and by a single, independently variable definability
parameter.

**Keywords:** self-reference, diagonal argument, Lawvere fixed-point theorem, Cantor's
theorem, Gödel incompleteness, Tarski undefinability, cardinal arithmetic, definability.

---

## 1. Introduction

Self-reference is the shared engine behind several of the deepest limitative results in
logic and mathematics. Cantor showed that no set surjects onto its power set; Russell
turned the same move into a paradox of naïve set theory; Gödel produced a true but
unprovable arithmetic sentence; Tarski proved that arithmetic truth is not
arithmetically definable. Lawvere (1969) observed that these are all instances of a
single categorical fact about cartesian closed categories, and Yanofsky (2003) recast
that observation in elementary terms accessible to a general mathematical audience.

This paper pursues one concrete organizing question. Consider the strongest possible form
of internal self-knowledge for a type $T$: an equivalence
$$T \;\simeq\; (T \to \mathrm{Prop}),$$
identifying each element of $T$ with a predicate about $T$ and vice versa. We call such a
$T$ a *self-quantifying type*, because it can quantify over — and name — every property of
itself. We prove no such type exists, and we thread the same diagonal argument through
Cantor, its cardinal form, Gödel, and Tarski, exhibiting exactly one structural root and
exactly one parameter (definability) that distinguishes consistency from paradox.

The contributions are:

1. A clean statement and proof of **Lawvere's fixed-point theorem** in fully general form
   (Section 3), used as the single ancestor of all subsequent results.
2. The nonexistence of a self-quantifying type, in surjective, injective, and
   equivalence forms (Section 4), together with its **quantitative shadow** as a strict
   cardinal inequality (Section 5).
3. An abstract model of a **self-referential system** with a *restricted* diagonal
   operator gated by definability, from which Gödel's incompleteness and Tarski's
   undefinability of truth are derived as two settings of one dial (Section 6), plus a
   concrete satisfying model witnessing non-vacuity (Section 7).

---

## 2. Preliminaries and notation

We work informally but rigorously in a type-theoretic setting; readers may equally read
$\mathrm{Prop}$ as a two-element type of truth values $\{\bot, \top\}$ and "type" as
"set." For a type $T$, we write $T \to \mathrm{Prop}$ for its **predicate space** (the
collection of all properties of elements of $T$). A map $f : A \to B$ is **surjective**
(point-surjective, when $B$ is itself a function space) if every $b \in B$ equals $f(a)$
for some $a$; **injective** if $f(a) = f(a')$ implies $a = a'$; and an **equivalence**
$A \simeq B$ if it is both. We write $\#\,T$ for the cardinality of $T$. A **fixed point**
of a self-map $g : B \to B$ is a $b$ with $g(b) = b$.

The single external fact we rely on about the value space $\mathrm{Prop}$ is:

> **Fact (No fixed point of negation).** There is no proposition $P$ with $\lnot P = P$;
> equivalently, $\lnot P \Leftrightarrow P$ is contradictory.

*Proof.* If $\lnot P \Leftrightarrow P$, then assuming $P$ gives $\lnot P$ hence a
contradiction, so $\lnot P$ holds; but then $P$ holds, contradiction. $\qquad\blacksquare$

---

## 3. Lawvere's fixed-point theorem: the structural root

**Theorem 3.1 (Lawvere).** *Let $A$ and $B$ be types and let $f : A \to (A \to B)$ be a
point-surjective family — that is, for every function $h : A \to B$ there is $a \in A$
with $f(a) = h$. Then every self-map $g : B \to B$ has a fixed point: there exists $b \in
B$ with $g(b) = b$.*

*Proof.* Define the diagonal function $h : A \to B$ by
$$h(x) \;=\; g\big(f(x)(x)\big).$$
By point-surjectivity there is $a \in A$ with $f(a) = h$. Evaluate both sides at $a$:
$$f(a)(a) \;=\; h(a) \;=\; g\big(f(a)(a)\big).$$
Setting $b = f(a)(a)$ gives $g(b) = b$, a fixed point. $\qquad\blacksquare$

The content is entirely in the *diagonal* substitution $x \mapsto f(x)(x)$: evaluating the
$a$-th function at the index $a$. This one construction is the common ancestor of every
result below. Contrapositively, **if $B$ admits even one fixed-point-free self-map, then
no family $A \to (A \to B)$ can be point-surjective.**

---

## 4. No type quantifies over itself

We now specialize the value space to $B = \mathrm{Prop}$ and the fixed-point-free self-map
to negation.

**Theorem 4.1 (Cantor / no self-quantifying surjection).** *For every type $T$, there is
no surjection $f : T \to (T \to \mathrm{Prop})$.*

*Proof.* Suppose $f$ were surjective. By Theorem 3.1 with $B = \mathrm{Prop}$ and
$g = \mathrm{Not}$, the map $\mathrm{Not}$ would have a fixed point — a proposition $P$
with $\lnot P = P$ — contradicting the Fact of Section 2. $\qquad\blacksquare$

**Theorem 4.2 (No retraction of predicates).** *For every type $T$, there is no injection
$g : (T \to \mathrm{Prop}) \to T$.*

*Proof (sketch).* This is the dual (injective) form of Cantor's theorem: an injection of
the predicate space into $T$ would yield, by a standard diagonal set
$\{\, t : t = g(\varphi) \text{ for some } \varphi \text{ with } t \notin \varphi \,\}$,
a predicate not in the image of any consistent labeling, a contradiction. Equivalently,
composing with a choice of left inverse contradicts Theorem 4.1. $\qquad\blacksquare$

**Theorem 4.3 (No self-quantifying type).** *For every type $T$, there is no equivalence
$T \simeq (T \to \mathrm{Prop})$.*

*Proof.* An equivalence is in particular a surjection $T \to (T \to \mathrm{Prop})$,
which Theorem 4.1 forbids. $\qquad\blacksquare$

**Corollary 4.4 (No self-quantifying bijection).** *No map $f : T \to (T \to
\mathrm{Prop})$ is bijective, since bijectivity entails surjectivity.*

Theorem 4.3 is the formal refutation of the "fully self-quantifying" dream $T \approx \Pi
(x : T),\, P\,x$, which under the standard reading is exactly $T \simeq (T \to
\mathrm{Prop})$. The obstruction is not the size of $T$; it is the fixed-point-free
operation $\mathrm{Not}$ on the value space.

---

## 5. The quantitative shadow: a strict cardinal gap

The qualitative impossibility has an exact numerical counterpart.

**Theorem 5.1 (Strict cardinal gap).** *For every type $T$,*
$$\#\,T \;<\; \#\,(T \to \mathrm{Prop}).$$

*Proof.* Since $\mathrm{Prop}$ has (at least) two elements, the predicate space
$T \to \mathrm{Prop}$ has the cardinality of the power set of $T$, namely $2^{\#\,T}$.
Cantor's cardinal theorem gives $\#\,T < 2^{\#\,T}$, and $\#\,(T \to \mathrm{Prop}) =
2^{\#\,T}$. $\qquad\blacksquare$

The logical and arithmetic statements are two readings of the *same* diagonal witness:
the predicate that no element can name (Theorem 4.1) is precisely the element of the
predicate space that no function $f$ can hit (Theorem 5.1). This is the first instance of
a general correspondence — every diagonal impossibility casts a strict cardinal shadow,
and conversely a strict gap $\#\,A < \#\,(A \to B)$ together with a fixed-point-free
self-map of $B$ reproduces an impossibility theorem.

---

## 6. Truth, provability, and the definability boundary

We now internalize self-reference. The following abstraction captures what is needed for
both Gödel's and Tarski's arguments, with the diagonal *restricted* to definable
predicates — the crucial design choice.

**Definition 6.1 (Self-referential system).** A *self-referential system* $M$ consists of:

- a type $\mathrm{Sentence}$ of sentences;
- a **truth** predicate $\mathrm{Tr} : \mathrm{Sentence} \to \mathrm{Prop}$;
- a **provability** predicate $\mathrm{Pr} : \mathrm{Sentence} \to \mathrm{Prop}$;
- a **soundness** guarantee: $\mathrm{Pr}(s) \Rightarrow \mathrm{Tr}(s)$ for all $s$;
- a **definability** predicate $\mathrm{Definable} : (\mathrm{Sentence} \to \mathrm{Prop})
  \to \mathrm{Prop}$ selecting which predicates the system can internally name;
- a **diagonal** operator $D : (\mathrm{Sentence} \to \mathrm{Prop}) \to \mathrm{Sentence}$;
- the **diagonal fixed-point property**, available *only for definable predicates*: for
  every $\varphi$ with $\mathrm{Definable}(\varphi)$,
  $$\mathrm{Tr}\big(D(\varphi)\big) \;\Longleftrightarrow\; \varphi\big(D(\varphi)\big);$$
- a **representability** assumption: the predicate $s \mapsto \lnot\,\mathrm{Pr}(s)$ is
  definable.

The restriction of the fixed-point property to *definable* predicates is what keeps the
system consistent. An unrestricted diagonal on the truth predicate would immediately
produce the Liar and derive falsehood; gating the diagonal by definability is exactly the
line separating Gödel's consistent gap from Tarski's collapse.

### 6.1 Gödel's incompleteness

**Definition 6.2 (Gödel sentence).** Let $G := D\big(s \mapsto \lnot\,\mathrm{Pr}(s)\big)$.
By representability the predicate is definable, so the diagonal property applies:
$$\mathrm{Tr}(G) \;\Longleftrightarrow\; \lnot\,\mathrm{Pr}(G).$$

**Theorem 6.3 (Unprovability of $G$).** $\lnot\,\mathrm{Pr}(G)$.

*Proof.* Suppose $\mathrm{Pr}(G)$. By soundness, $\mathrm{Tr}(G)$. By the fixed-point
property, $\mathrm{Tr}(G) \Rightarrow \lnot\,\mathrm{Pr}(G)$, hence $\lnot\,\mathrm{Pr}(G)$
— contradicting $\mathrm{Pr}(G)$. Therefore $\lnot\,\mathrm{Pr}(G)$. $\qquad\blacksquare$

**Theorem 6.4 (Truth of $G$).** $\mathrm{Tr}(G)$.

*Proof.* By the fixed-point property, $\lnot\,\mathrm{Pr}(G) \Rightarrow \mathrm{Tr}(G)$;
apply Theorem 6.3. $\qquad\blacksquare$

**Theorem 6.5 (Incompleteness).** *There exists a sentence $s$ with $\mathrm{Tr}(s)$ and
$\lnot\,\mathrm{Pr}(s)$.*

*Proof.* Take $s = G$ and combine Theorems 6.3 and 6.4. $\qquad\blacksquare$

### 6.2 Tarski's undefinability of truth

**Theorem 6.6 (Undefinability of truth).** *The predicate $s \mapsto \lnot\,\mathrm{Tr}(s)$
is not definable.*

*Proof.* Suppose it were. Then the diagonal property applies to it, giving a sentence
$L := D\big(s \mapsto \lnot\,\mathrm{Tr}(s)\big)$ with
$$\mathrm{Tr}(L) \;\Longleftrightarrow\; \lnot\,\mathrm{Tr}(L),$$
a fixed point of negation on the value space — impossible by the Fact of Section 2. Hence
$s \mapsto \lnot\,\mathrm{Tr}(s)$ is not definable. $\qquad\blacksquare$

### 6.3 The unifying observation

Theorems 6.5 and 6.6 are the *same* diagonal fixed point applied to two different
predicates. When the diagonalized predicate is negated **provability** — which the system
*can* name — soundness downgrades the resulting contradiction into a mere gap: a true but
unprovable sentence. When the diagonalized predicate is negated **truth** — which the
system *cannot* name without contradiction — the same construction would collapse the
system, so definability of that predicate is refuted outright. Consistency is therefore a
property not of the sentences a system proves but of the *predicates it is permitted to
name*: the fixed-point operator is always present; only the definability gate decides
whether its output is a theorem, an undecidable sentence, or a contradiction.

---

## 7. Non-vacuity: a concrete model

To ensure Definition 6.1 is satisfiable and Theorems 6.5–6.6 are not vacuous, we exhibit a
concrete system.

**Construction 7.1 (Example system).** Take $\mathrm{Sentence} = \{\mathrm{false},
\mathrm{true}\}$ (booleans); $\mathrm{Tr}(b) := (b = \mathrm{true})$; $\mathrm{Pr}(b) :=
\bot$ (nothing is provable); $\mathrm{Definable}(\varphi) := \varphi(\mathrm{true})$; and
$D(\varphi) := \mathrm{true}$.

*Verification.* Soundness holds vacuously since $\mathrm{Pr}$ is always false. For the
diagonal property, when $\varphi$ is definable we have $\varphi(\mathrm{true})$ true, and
$\mathrm{Tr}(D(\varphi)) = (\mathrm{true} = \mathrm{true})$ is true, so both sides of the
biconditional hold. Representability holds because $\lnot\,\mathrm{Pr}(\mathrm{true}) =
\lnot\bot = \top$, so the predicate $s \mapsto \lnot\,\mathrm{Pr}(s)$ is true at
$\mathrm{true}$ and hence definable. Thus all axioms are met, and Theorems 6.5–6.6 apply
with genuine content. $\qquad\blacksquare$

---

## 8. Algorithms

The results are non-constructive impossibility statements, but their combinatorial cores
are eminently computable on finite instances, which is useful for illustration and
testing.

**Algorithm 8.1 (Diagonal witness extraction).** Given a *finite* type $A$, a finite
value type $B$, a family $f : A \to (A \to B)$, and a self-map $g : B \to B$, either
return an $a$ realizing Lawvere's diagonal (so that $b = f(a)(a)$ is a fixed point of
$g$), or certify that $f$ is not point-surjective by exhibiting the diagonal function
$x \mapsto g(f(x)(x))$ that is missing from the family. Complexity $O(|A|^2)$ evaluations
to build the diagonal, plus $O(|A|^2)$ to search for it in the family.

**Algorithm 8.2 (Cantor diagonal predicate).** Given a finite $T$ and a candidate family
$f : T \to (T \to \mathrm{Bool})$, construct the predicate $d(x) = \lnot f(x)(x)$ and
verify $d$ differs from every row $f(a)$ at the point $a$, giving a constructive proof
that $f$ is not surjective. Complexity $O(|T|^2)$.

**Algorithm 8.3 (Cardinal gap counter).** Given $|T| = n$, report $|T| = n$ and $|T \to
\mathrm{Prop}| = 2^n$, confirming the strict gap $n < 2^n$ for all $n \ge 0$. Complexity
$O(1)$ arithmetic.

---

## 9. Applications and connections

- **Foundations.** Theorem 4.3 rules out any type-theoretic universe in which a type is
  literally its own predicate space, a common temptation in impredicative reflection
  proposals.
- **Cardinal arithmetic.** Theorem 5.1 recovers the entire Cantorian hierarchy: from any
  cardinal one obtains a strictly larger one, so there is no greatest cardinal.
- **Metamathematics.** Section 6 gives a uniform, assumption-light derivation of Gödel and
  Tarski that makes the definability gate an explicit parameter, clarifying textbook
  discussions of why incompleteness is consistent while the Liar is not.
- **Philosophy of mind and self-modeling systems.** The self-quantifying type is a formal
  proxy for "a system that fully models itself." Theorem 4.3 shows total internal
  self-reflection is impossible over two-valued truth, while Conjecture 3 (below) locates
  the escape route in the fixed-point geometry of the value space.

---

## 10. Discussion and future work

The unifying lesson is that *impossibility of self-reference is a property of the value
space, not of the reflecting system*. Two-valued logic carries a fixed-point-free
operation (negation), and Lawvere converts this single fact into all of the impossibility
theorems above. This suggests three lines of further work.

**Conjecture 1 — The definability gate governs the whole incompleteness spectrum.**
Between "nothing internal is nameable" (trivially consistent) and "everything is nameable"
(Tarski collapse) lies a monotone lattice of naming powers, and each level realizes a
sharply different incompleteness phenomenon (consistency, essential incompleteness,
$\omega$-incompleteness, outright inconsistency). Consistency is not a property of the
sentences a system proves but of the predicates it is allowed to name.

**Conjecture 2 — Every diagonal impossibility has a quantitative cardinal shadow.** Each
qualitative "no self-reflecting object" theorem is the boundary case of a strict size
inequality; conversely, any strict cardinal gap $\#\,A < \#\,(A \to B)$ with a
fixed-point-free self-map of $B$ yields a corresponding impossibility theorem. The
logical obstruction and the arithmetic gap are two readings of the same diagonal witness.

**Conjecture 3 — Fixed-point-free self-maps classify which structures resist
self-reference.** A value type $B$ admits a self-quantifying object built on it exactly
when $B$ carries no fixed-point-free self-map; the obstruction to self-reference is
precisely the existence of a fixed-point-free self-map such as negation. Replace
two-valued logic by a structure in which every self-map has a fixed point, and the
obstruction dissolves.

---

## References

1. F. W. Lawvere, *Diagonal arguments and cartesian closed categories*, Lecture Notes in
   Mathematics **92** (1969), 134–145.
2. N. S. Yanofsky, *A universal approach to self-referential paradoxes, incompleteness and
   fixed points*, Bulletin of Symbolic Logic **9** (2003), 362–386.
3. G. Cantor, *Über eine elementare Frage der Mannigfaltigkeitslehre* (1891).
4. K. Gödel, *Über formal unentscheidbare Sätze der Principia Mathematica und verwandter
   Systeme I* (1931).
5. A. Tarski, *Der Wahrheitsbegriff in den formalisierten Sprachen* (1936).
