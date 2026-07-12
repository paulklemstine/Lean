# Universal Mathematics and Alien Arithmetic: A Semantic Theory of the Truths Every Consistent Reasoner Must Accept

## Abstract

Would a non-human intelligence — extraterrestrial, artificial, or independently
evolved — discover the same mathematics we did? We give one precise reading of
this question and answer it. Working in a purely semantic framework of
structures, sentences, theories, and entailment, we define a sentence to be
**universal over a base theory** when it is entailed by *every* consistent
extension of that theory. This formalizes "a truth any sufficiently expressive,
consistent reasoner must reach." Our central metatheorem, the **Universality
Theorem**, shows that over a consistent base theory universality coincides
exactly with ordinary provability: the universal sentences are precisely the
theorems of the base theory. As corollaries we obtain (i) a monotonicity
principle establishing that a foundational theory's theorems are inherited by
every consistent extension — the sense in which basic arithmetic is universal;
(ii) an **Independence Defeats Universality** theorem showing that any sentence
with both a model and a countermodel is non-universal, together with its
negation — the abstract form of the non-universality of the parallel postulate,
instantiated concretely by the independence of commutativity from the group
axioms; and (iii) a **Decidability Reduction** proving that "$\varphi$ or
$\neg\varphi$ is universal" is equivalent to "$T$ decides $\varphi$," which
recasts the conjecture "the Riemann Hypothesis is universal" as the open problem
"arithmetic decides the Riemann Hypothesis." We then descend to concrete number
theory and prove that the prime numbers are a **definitional invariant** of
multiplicative structure: three independent characterizations (via the
divisibility order, via multiplicative indecomposability, and via the abstract
notions of prime and irreducible element) all isolate the identical set of
primes, a canonical prime-finding procedure always succeeds, and the classical
theorems of Euclid and the Fundamental Theorem of Arithmetic hold. The
conclusion is that while the *style* of a mathematics (which independent axioms
it adopts) is contingent, its arithmetic *core* is forced: any counting
intelligence discovers our primes.

**Keywords:** universal mathematics, semantic entailment, model theory,
independence, parallel postulate, prime numbers, Fundamental Theorem of
Arithmetic, Riemann Hypothesis, decidability.

---

## 1. Introduction

The question "would aliens do the same mathematics?" is usually treated as
philosophy or speculation. Our aim is to convert one sharp version of it into
mathematics and settle that version rigorously.

The intuition to formalize is: *a truth is universal if any sufficiently
expressive, self-consistent reasoner is forced to accept it.* "Forced" is the
operative word. A reasoner starts from some base commitments (axioms) and may
strengthen them arbitrarily, subject only to remaining consistent. A universal
truth is one that no such strengthening can escape.

We adopt a semantic viewpoint throughout: theories are sets of sentences,
sentences are properties of structures, and the fundamental relation is
entailment (truth in all models). This keeps the development elementary and
model-theoretic, and lets us prove exact characterizations rather than
approximations.

Our contributions are:

1. A minimal, self-contained semantic framework for **universality over a base
   theory** (Section 3).
2. The **Universality Theorem**: over a consistent base theory, universality =
   provability (Section 4).
3. **Independence Defeats Universality**, with a concrete group-theoretic
   instantiation serving as the algebraic mirror of the parallel postulate
   (Section 5).
4. The **Decidability Reduction**, which locates the "Riemann Hypothesis is
   universal" conjecture precisely as the open problem of whether arithmetic
   decides RH (Section 6).
5. A theory of **alien arithmetic** proving that primes are a definitional
   invariant recovered by any multiplicative intelligence, with the classical
   structural theorems (Section 7).

---

## 2. Related ideas and scope

The framework is deliberately semantic and finitary in its metatheory. It does
not, in its present form, contain a syntactic derivability relation, and so it
does not by itself invoke Gödel's incompleteness theorems; rather, it provides
the semantic scaffolding on which such phenomena can later be expressed (see
Future Directions). The point of this paper is not to reprove the classical
metatheorems of logic but to isolate the single notion — universality as
entailment by all consistent extensions — that makes the "alien mathematics"
question precise, and to determine its exact content.

---

## 3. The framework

Throughout, fix a type $M$ of **structures** or **worlds** — the possible
situations a theory can describe.

**Definition 3.1 (Sentence).** A *sentence* over $M$ is a predicate
$\varphi : M \to \{\text{true}, \text{false}\}$; equivalently, a property that is
either true or false in each world. We write $\varphi(m)$ for "$\varphi$ holds in
world $m$." The *negation* $\neg\varphi$ is defined by
$(\neg\varphi)(m) \iff \neg(\varphi(m))$.

**Definition 3.2 (Theory).** A *theory* $T$ is a set of sentences over $M$ — its
axioms.

**Definition 3.3 (Model).** A world $m$ is a *model* of $T$, written
$m \models T$, when every axiom of $T$ holds in $m$: for all $\varphi \in T$,
$\varphi(m)$.

**Definition 3.4 (Consistency).** $T$ is *consistent* when it has at least one
model: $\exists m,\ m \models T$.

**Definition 3.5 (Entailment).** $T$ *entails* $\varphi$, written
$T \models \varphi$, when $\varphi$ holds in every model of $T$: for all $m$, if
$m \models T$ then $\varphi(m)$.

**Definition 3.6 (Universality).** A sentence $\varphi$ is *universal over $T$*
when every consistent extension of $T$ entails it:
$$
\text{for all theories } T' \supseteq T,\quad
T' \text{ consistent} \implies T' \models \varphi.
$$

**Definition 3.7 (Decidability).** $T$ *decides* $\varphi$ when
$T \models \varphi$ or $T \models \neg\varphi$.

These seven definitions are the entire vocabulary. Everything below is derived.

---

## 4. Basic consequence and the Universality Theorem

We begin with the two structural facts that make the theory work.

**Lemma 4.1 (Axioms are entailed).** If $\varphi \in T$ then $T \models \varphi$.

*Proof.* If $m \models T$ then $m$ satisfies every axiom of $T$, in particular
$\varphi$. $\square$

**Lemma 4.2 (Monotonicity of consequence).** If $T \subseteq T'$ and
$T \models \varphi$, then $T' \models \varphi$.

*Proof.* Let $m \models T'$. Since $T \subseteq T'$, $m$ satisfies every axiom of
$T$, so $m \models T$. By hypothesis $\varphi(m)$. $\square$

Monotonicity is the exact content of the informal claim "a foundational theory's
theorems are a subset of the theorems of every consistent extension." A
foundational arithmetic, once its theorems are established, never loses them: any
larger consistent theory inherits them wholesale.

**Lemma 4.3 (Consistency forbids contradiction).** If $T$ is consistent, then not
both $T \models \varphi$ and $T \models \neg\varphi$.

*Proof.* Let $m \models T$ witness consistency. If both held, then $\varphi(m)$
and $\neg\varphi(m)$, a contradiction. $\square$

We can now state and prove the central result.

**Theorem 4.4 (Universality Theorem).** Let $T$ be consistent. Then $\varphi$ is
universal over $T$ if and only if $T \models \varphi$.

*Proof.* ($\Rightarrow$) A theory extends itself, $T \subseteq T$, and $T$ is
consistent by hypothesis; so applying universality to $T' = T$ gives
$T \models \varphi$. ($\Leftarrow$) Let $T' \supseteq T$ be any consistent
extension. By Monotonicity (Lemma 4.2), $T \models \varphi$ implies
$T' \models \varphi$. Hence $\varphi$ is universal. $\square$

Theorem 4.4 is deceptively strong. It says the seemingly exotic notion of
"survives every consistent strengthening" collapses to the everyday notion of
"is a theorem." Two immediate consequences:

**Corollary 4.5 (Axioms are universal).** If $\varphi \in T$ then $\varphi$ is
universal over $T$.

*Proof.* By Lemma 4.1 and Monotonicity. $\square$

**Corollary 4.6 (Universal core is entailed).** If $T$ is consistent and
$\varphi$ is universal over $T$, then $T \models \varphi$.

The universal sentences are also well-behaved as a collection.

**Proposition 4.7 (Closure).** The sentences universal over $T$ are closed under
conjunction and modus ponens:
- if $\varphi$ and $\psi$ are universal over $T$, so is $\varphi \wedge \psi$;
- if $\varphi \to \psi$ and $\varphi$ are universal over $T$, so is $\psi$.

*Proof.* Both follow by evaluating in an arbitrary consistent extension $T'$ and
an arbitrary model $m \models T'$: conjunction holds pointwise, and modus ponens
is pointwise implication. $\square$

Thus the universal fragment over $T$ is a deductively closed layer — precisely
the theorems of $T$, by Theorem 4.4.

---

## 5. Independence and the parallel postulate

Not every truth is universal. The historically decisive example is Euclid's
parallel postulate, which is independent of the remaining axioms of geometry:
spherical geometry has no parallels, hyperbolic geometry has infinitely many, and
both are consistent. We capture the phenomenon abstractly.

**Definition 5.1 (Independence).** A sentence $\varphi$ is *independent over $T$*
when $T$ has a model in which $\varphi$ holds and a model in which $\varphi$
fails:
$$
(\exists m,\ m \models T \wedge \varphi(m)) \ \wedge\
(\exists m,\ m \models T \wedge \neg\varphi(m)).
$$

**Lemma 5.2 (Countermodels block entailment).** If some model of $T$ falsifies
$\varphi$, then $T \not\models \varphi$.

*Proof.* Immediate from Definition 3.5. $\square$

**Theorem 5.3 (Independence Defeats Universality).** If $\varphi$ is independent
over $T$, then neither $\varphi$ nor $\neg\varphi$ is universal over $T$.

*Proof.* Let $m_1 \models T$ with $\varphi(m_1)$ and $m_2 \models T$ with
$\neg\varphi(m_2)$. Consider the extension $T \cup \{\neg\varphi\}$. It is
consistent, witnessed by $m_2$ (which satisfies $T$ and $\neg\varphi$), yet it
does not entail $\varphi$ (again by $m_2$). Since $T \cup \{\neg\varphi\}$ is a
consistent extension of $T$ that fails to entail $\varphi$, $\varphi$ is not
universal. Symmetrically, $T \cup \{\varphi\}$ is consistent via $m_1$ and does
not entail $\neg\varphi$, so $\neg\varphi$ is not universal. $\square$

An independent sentence, then, is one a consistent reasoner may freely affirm or
deny — the exact opposite of universality.

**Corollary 5.4 (At most one side is universal).** Over a consistent $T$, not
both $\varphi$ and $\neg\varphi$ are universal.

*Proof.* By Corollary 4.6 both would then be entailed, contradicting Lemma 4.3.
$\square$

### 5.1 A concrete instantiation: commutativity as the algebraic parallel postulate

To exhibit a genuine independent sentence we use group structures, where
commutativity plays the role of the parallel postulate.

Consider two concrete worlds:
- $\mathbb{Z}/2\mathbb{Z}$, the two-element group, which is commutative;
- $S_3$, the symmetric group on three letters (the six permutations of
  $\{1,2,3\}$), which is **not** commutative — for instance, a transposition and
  a 3-cycle do not commute.

Let the *theory of groups* over this class impose no additional axioms (both
worlds are already groups), and let $\mathsf{Comm}$ be the sentence "the group is
commutative," i.e. $\forall x, y,\ x \cdot y = y \cdot x$.

**Proposition 5.5.** $\mathbb{Z}/2\mathbb{Z} \models \mathsf{Comm}$ and
$S_3 \not\models \mathsf{Comm}$.

*Proof.* Both are finite checks on the multiplication tables. $\square$

**Theorem 5.6 (Commutativity is not universal).** Over the theory of groups,
neither $\mathsf{Comm}$ nor $\neg\mathsf{Comm}$ is universal.

*Proof.* By Proposition 5.5, $\mathsf{Comm}$ is independent over the theory of
groups; apply Theorem 5.3. $\square$

This is the algebraic mirror of "the parallel postulate is not universal":
abelian and non-abelian groups are the analogues of Euclidean and non-Euclidean
geometries. Yet universality is *relative*:

**Theorem 5.7 (Commutativity becomes universal once adopted).** Over the theory
of *abelian* groups (the theory of groups together with $\mathsf{Comm}$),
$\mathsf{Comm}$ is universal.

*Proof.* $\mathsf{Comm}$ is now an axiom, so it is universal by Corollary 4.5;
consistency of the theory of abelian groups is witnessed by
$\mathbb{Z}/2\mathbb{Z}$. $\square$

The lesson: universality is never absolute but always relative to the adopted
base. An alien algebra founded on commutative structures and ours founded on
general ones are both internally correct; neither can refute the other from
shared axioms.

---

## 6. The Riemann Hypothesis and the Decidability Reduction

Is the Riemann Hypothesis universal — is every sufficiently rich arithmetic
reasoner forced to accept it or its negation? The framework does not settle this
(no one can), but it pins down *exactly what is being asked*.

**Theorem 6.1 (Decidability Reduction).** Let $T$ be consistent. Then
$$
\big(\varphi \text{ universal over } T \ \vee\ \neg\varphi \text{ universal over }
T\big) \iff T \text{ decides } \varphi.
$$

*Proof.* Apply the Universality Theorem (4.4) to $\varphi$ and to $\neg\varphi$:
"$\varphi$ universal" $\iff$ "$T \models \varphi$" and "$\neg\varphi$ universal"
$\iff$ "$T \models \neg\varphi$." Disjoining the two equivalences yields the
claim, since $T$ decides $\varphi$ means precisely $T \models \varphi$ or
$T \models \neg\varphi$. $\square$

Reading $T$ as an arithmetic theory and $\varphi$ as the Riemann Hypothesis,
Theorem 6.1 says:

> "The Riemann Hypothesis (or its negation) is universal" **if and only if**
> "arithmetic decides the Riemann Hypothesis."

The right-hand side is a genuine open problem. Consequently the conjecture "RH is
universal" is, under this semantics, neither trivially true nor trivially false;
it is exactly as hard as deciding RH. This is why we advance it as a conjecture
and never assert it as a theorem. The value of the reduction is diagnostic: it
translates a nebulous worry about alien agreement into a precise mathematical
target.

---

## 7. Alien arithmetic: would aliens discover primes?

We now descend from metatheory to concrete number theory and ask the sharpest
version of the alien question: would a non-human intelligence discover the prime
numbers? Our thesis is that primes are not a human convention but a
**definitional invariant** of the multiplicative structure of the natural
numbers. Any intelligence possessing the divisibility relation — equivalently,
multiplication of counting numbers — is forced to the identical set of primes.

Recall that a natural number $p$ is *prime* when $p \ge 2$ and its only positive
divisors are $1$ and $p$. We show this notion is robust under three independent
routes of definition.

**Theorem 7.1 (Primes from the divisibility order).** For every natural number
$p$,
$$
p \text{ is prime} \iff p \ge 2 \ \wedge\ \forall d\ (d \mid p \to d = 1 \vee d
= p).
$$

This uses nothing beyond the relation "$\mid$." Any intelligence that can ask
"does $a$ divide $b$?" isolates the same primes.

**Theorem 7.2 (Primes as multiplicatively indecomposable numbers).** For every
$p \ge 2$,
$$
p \text{ is prime} \iff \neg\, \exists a, b\ (a \ge 2 \wedge b \ge 2 \wedge p = a
\cdot b).
$$

*Proof sketch.* If $p$ is prime and $p = ab$ with $a, b \ge 2$, then $a \mid p$
forces $a = 1$ or $a = p$; the first contradicts $a \ge 2$, the second forces
$b = 1$, contradicting $b \ge 2$. Conversely, if $p$ is not indecomposable it has
a divisor $d$ with $p = d \cdot c$; ruling out $d \in \{1, p\}$ (using $p \ge 2$
and that neither factor is $0$) yields $d, c \ge 2$, a nontrivial factorization.
$\square$

This is the characterization a mind reaches by *breaking numbers apart* under
multiplication.

**Theorem 7.3 (Primes as abstract atoms).** For every natural number $p$,
$$
p \text{ is prime} \iff \big(p \text{ is a prime element}\big) \ \wedge\ \big(p
\text{ is irreducible}\big),
$$
where a *prime element* is one that, whenever it divides a product, divides one
of the factors, and an *irreducible element* is a non-unit with no nontrivial
factorization. These notions are defined in *any* commutative monoid.

*Proof sketch.* In the natural numbers the arithmetic notion of prime coincides
with the algebraic prime-element notion; and in this setting prime and
irreducible elements agree. $\square$

The significance of Theorem 7.3 is that its definitions require only an abstract
multiplication. An alien who axiomatizes multiplication in the abstract, never
having seen our natural numbers, recovers exactly our primes.

Beyond definability, primes are *findable* by a canonical procedure.

**Theorem 7.4 (Canonical prime finder).** For every $n \ge 2$, the least divisor
of $n$ exceeding $1$ is prime and divides $n$.

*Proof sketch.* Any nontrivial divisor of the least such divisor would be a still
smaller divisor exceeding $1$, contradicting minimality. $\square$

This gives a universal algorithm producing a prime from any number, so every
counting intelligence converges on our primes not only in definition but in
construction.

Finally, the two classical theorems that make primes fundamental.

**Theorem 7.5 (Euclid: infinitude of primes).** For every $n$ there is a prime
$p \ge n$; equivalently, the set of primes is infinite.

*Proof sketch.* Any prime factor of $n! + 1$ exceeds $n$; hence primes are
unbounded. $\square$

**Theorem 7.6 (Fundamental Theorem of Arithmetic).**
*(Existence)* Every positive natural number is a product of primes.
*(Uniqueness)* Any two prime-factorization lists of the same number are
permutations of one another; the multiset of prime factors is an invariant of the
number, independent of how it was produced.

*Proof sketch.* Existence is by strong induction, splitting a composite via
Theorem 7.4. Uniqueness follows from the prime-element property (Theorem 7.3): a
prime dividing a product divides some factor, which lets one match factors across
two factorizations. $\square$

The uniqueness clause is the decisive point for the alien question. The prime
factorization of a number is not a description we impose but a fact about the
number itself. Two civilizations that never met would agree, factor for factor,
on the decomposition of any quantity. If the aliens count, they multiply; if they
multiply, they have divisibility; if they have divisibility, they have our
primes.

---

## 8. Discussion

The results split cleanly along the contingent/necessary divide the framework was
built to detect.

- **Necessary (universal) mathematics.** Over a fixed consistent base, the
  universal sentences are exactly the theorems (Theorem 4.4). A foundational
  arithmetic's theorems are inherited by every consistent extension (Lemma 4.2).
  The primes, their infinitude, and unique factorization are forced on any
  multiplicative intelligence (Section 7).

- **Contingent mathematics.** Independent sentences — commutativity, the parallel
  postulate — are non-universal (Theorem 5.3), and their status flips to universal
  only relative to a base that adopts them (Theorem 5.7). These are the loci where
  alien mathematics could legitimately diverge from ours.

- **Open frontier.** Whether deep arithmetic statements such as the Riemann
  Hypothesis are universal is *equivalent* to whether arithmetic decides them
  (Theorem 6.1) — an honest open problem, correctly left as a conjecture.

The framework's virtue is that it makes "would aliens agree?" answerable
result-by-result rather than as a monolith. Some mathematics is style; some is
structure. Our theorems draw the line.

---

## 9. Future directions

1. **Syntactic side and soundness/completeness.** The present model is purely
   semantic ($\models$). Adding a Hilbert- or sequent-style provability relation
   $\vdash$ and proving soundness ($\vdash \Rightarrow \models$) and, for
   suitable fragments, completeness ($\models \Rightarrow \vdash$) would tie
   "universal" to genuine derivability.

2. **Incompleteness as a universality obstruction.** Connecting to a
   formalization of the first incompleteness theorem would exhibit sentences
   decided in *no* recursively axiomatized consistent extension of arithmetic —
   the sharpest possible failure of universality.

3. **A genuine geometry instance.** Replacing the group analogue with an actual
   incidence/betweenness model of the parallel postulate — a Euclidean model and
   a non-Euclidean model fed into the independence machinery — would realize the
   historical example directly.

---

## 10. Conclusion

We defined universality as entailment by every consistent extension of a base
theory and proved it coincides with provability over any consistent base. This
single characterization organizes the alien-mathematics question: it makes
foundational arithmetic provably universal, makes independent axioms provably
non-universal while explaining how they become universal once adopted, and
reduces the universality of the Riemann Hypothesis to its decidability. Descending
to concrete arithmetic, we showed the primes are a definitional invariant of
multiplication, recoverable by three independent routes and a canonical
construction, with Euclid's theorem and unique factorization intact. The style of
a mathematics is contingent; its arithmetic core is not. Any consistent counting
intelligence — human, artificial, or alien — meets us at the primes.
