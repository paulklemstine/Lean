# Transreal Arithmetic: The Exact Algebraic Cost of Total Division

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

We study the *transreal numbers*, the extension $\mathbb{T} = \mathbb{R} \cup \{+\infty, -\infty, \Phi\}$ of the real line by two signed infinities and a distinguished element $\Phi$ ("nullity"), the canonical value of the indeterminate quotient $0/0$. The system is designed so that addition, multiplication, and division are all **total** — defined for every input without exception — with $\Phi$ serving as a global, self-propagating error element. We give a complete algebraic classification of the resulting structure. On the positive side, we prove that $(\mathbb{T}, +, 0)$ and $(\mathbb{T}, \cdot, 1)$ are each commutative monoids, that $\Phi$ is a two-sided absorbing element for both operations, that the finite reals embed as a submonoid preserving all classical identities, and that division is total with Anderson's defining identity $0/0 = \Phi$ holding exactly. On the negative side, we prove that $\mathbb{T}$ is not a ring — $+\infty$ has no additive inverse, the annihilator law $0 \cdot x = 0$ fails at infinity, distributivity fails, and additive cancellation fails — and, more surprisingly, that $\mathbb{T}$ is not a wheel either: the wheel's modified distributive law fails and the reciprocal is not an involution. We conclude that the transreals are precisely *a pair of commutative monoids sharing a global absorbing element, equipped with a total but non-involutive division* — a structure strictly weaker than both a ring and a wheel. We locate the failures at a single mechanism, the "poisoning" of computations by $0 \cdot \infty = \Phi$ and by the sign split of $\pm\infty$, and we discuss the relationship to IEEE 754 floating-point arithmetic.

## 1. Introduction

The impossibility of division by zero is a structural fact about fields: adjoining a value for $1/0$ to any ring in which $1 \neq 0$ forces a contradiction. Yet the practical desire for *total* arithmetic — where no operation ever raises an exception — recurs throughout computing and, historically, in attempts to give meaning to the "points at infinity" of projective geometry. Two broad strategies exist. The first, the classical *projective line*, adjoins a single unsigned point $\infty$ and yields, after suitable axiomatization, a **wheel** (Setzer; Carlström). The second, championed by J. A. Anderson under the name **transreal arithmetic**, adjoins *two signed* infinities together with a nullity element $\Phi = 0/0$, and is the closest algebraic model of the IEEE 754 floating-point system with its $\pm\infty$ and `NaN`.

This paper answers a precise structural question about the second strategy: **exactly which algebraic laws survive the transreal extension, and which collapse?** Our contribution is a complete and rigorous classification. We show that the transreal system retains two commutative-monoid skeletons glued at an absorbing error element, but satisfies *neither* the ring axioms *nor* the wheel axioms, and we identify the single mechanism responsible for each failure.

## 2. The transreal numbers

### 2.1 Carrier

**Definition 2.1 (Transreal numbers).** The set of *transreal numbers* is the disjoint union
$$\mathbb{T} = \mathbb{R} \ \sqcup\ \{+\infty,\ -\infty,\ \Phi\},$$
consisting of an embedded copy of each real number $r$ (written $\underline{r}$ when the embedding must be emphasized, and $r$ otherwise), together with three new elements: *positive infinity* $+\infty$, *negative infinity* $-\infty$, and *nullity* $\Phi$. We write $0 = \underline{0}$ and $1 = \underline{1}$.

### 2.2 Operations

**Definition 2.2 (Addition).** Addition $+ : \mathbb{T} \times \mathbb{T} \to \mathbb{T}$ is defined by:
- $\Phi + x = x + \Phi = \Phi$ for all $x$ (nullity absorbs);
- $(+\infty) + (-\infty) = (-\infty) + (+\infty) = \Phi$;
- $(+\infty) + (+\infty) = +\infty$, and $(+\infty) + \underline{r} = \underline{r} + (+\infty) = +\infty$;
- $(-\infty) + (-\infty) = -\infty$, and $(-\infty) + \underline{r} = \underline{r} + (-\infty) = -\infty$;
- $\underline{a} + \underline{b} = \underline{a + b}$ for finite reals.

**Definition 2.3 (Multiplication).** Multiplication $\cdot : \mathbb{T} \times \mathbb{T} \to \mathbb{T}$ is defined by:
- $\Phi \cdot x = x \cdot \Phi = \Phi$ for all $x$;
- $(+\infty)(+\infty) = (-\infty)(-\infty) = +\infty$ and $(+\infty)(-\infty) = (-\infty)(+\infty) = -\infty$;
- for a finite real $b$: $(+\infty)\cdot \underline{b}$ equals $\Phi$ if $b = 0$, equals $+\infty$ if $b > 0$, and equals $-\infty$ if $b < 0$; symmetrically for $\underline{b}\cdot(+\infty)$, and with signs reversed for $\pm\infty$ against $-\infty$;
- $\underline{a}\cdot\underline{b} = \underline{a\cdot b}$ for finite reals.

In particular $0 \cdot (\pm\infty) = \Phi$: the indeterminate product is routed to nullity.

**Definition 2.4 (Negation).** $-\Phi = \Phi$, $-(+\infty) = -\infty$, $-(-\infty) = +\infty$, and $-\underline{a} = \underline{-a}$.

**Definition 2.5 (Reciprocal and division).** The *reciprocal* is
$$\tfrac{1}{\Phi} = \Phi, \qquad \tfrac{1}{+\infty} = \tfrac{1}{-\infty} = 0, \qquad \tfrac{1}{\underline{a}} = \begin{cases} +\infty & a = 0 \\ \underline{a^{-1}} & a \neq 0.\end{cases}$$
*Division* is then $x / y = x \cdot (1/y)$, a total binary operation on $\mathbb{T}$.

A convenient tool for case analysis is the following six-way classification, which distinguishes finite reals by sign because the singular products depend on it.

**Lemma 2.6 (Six-way split).** Every $t \in \mathbb{T}$ satisfies exactly one of: $t = \Phi$; $t = +\infty$; $t = -\infty$; $t = \underline{r}$ with $r > 0$; $t = \underline{0}$; or $t = \underline{r}$ with $r < 0$.

*Proof.* Immediate from the definition of the carrier together with the trichotomy of the reals. $\square$

## 3. What survives

### 3.1 Nullity is absorbing

**Theorem 3.1 (Global absorption).** For all $x \in \mathbb{T}$,
$$\Phi + x = x + \Phi = \Phi, \qquad \Phi \cdot x = x \cdot \Phi = \Phi.$$
Moreover $1/\Phi = \Phi$, so $\Phi$ is a fixed point of the reciprocal, and $\Phi / y = \Phi$ for all $y$.

*Proof.* Each identity is immediate from Definitions 2.2, 2.3, and 2.5 by inspection of the defining clause with $\Phi$ in the relevant position; the clauses were chosen so that $\Phi$ appears on the right whenever it appears as an argument. The division identity follows since $\Phi / y = \Phi \cdot (1/y) = \Phi$. $\square$

This absorption is the linchpin of the whole system: it is why the "dangerous" cases can be quarantined and why associativity survives (Section 3.3).

### 3.2 The reals embed conservatively

**Theorem 3.2 (Conservative embedding).** The map $r \mapsto \underline{r}$ is an injection $\mathbb{R} \hookrightarrow \mathbb{T}$ satisfying, for all finite $a, b$,
$$\underline{a} + \underline{b} = \underline{a+b}, \qquad \underline{a}\cdot\underline{b} = \underline{a \cdot b}, \qquad -\underline{a} = \underline{-a}.$$
Thus every first-order identity of the reals that does not mention the singular values holds verbatim in $\mathbb{T}$, and $\underline{\mathbb{R}}$ is a subring of nothing larger only because $\mathbb{T}$ itself is not a ring (Section 4).

*Proof.* The three identities are the finite clauses of Definitions 2.2, 2.3, 2.4, holding by definition. Injectivity is clear. $\square$

### 3.3 Two commutative monoids

**Theorem 3.3 (Additive commutative monoid).** $(\mathbb{T}, +, 0)$ is a commutative monoid:
$$x + y = y + x, \qquad (x+y)+z = x+(y+z), \qquad 0 + x = x + 0 = x.$$

*Proof sketch.* Commutativity and the identity laws follow by a finite case split over the four constructors (with the finite–finite case reducing to real commutativity). Associativity is proved by the same exhaustive case analysis. The only interactions that could threaten associativity involve $+\infty + (-\infty) = \Phi$; but whenever such a cancellation occurs in a grouped sum, the result is $\Phi$, and by Theorem 3.1 every subsequent addition preserves $\Phi$ regardless of grouping. Hence both groupings agree. $\square$

**Theorem 3.4 (Multiplicative commutative monoid).** $(\mathbb{T}, \cdot, 1)$ is a commutative monoid:
$$x \cdot y = y \cdot x, \qquad (x \cdot y)\cdot z = x \cdot (y \cdot z), \qquad 1 \cdot x = x \cdot 1 = x.$$

*Proof sketch.* Commutativity and the identity laws follow by case split, the finite–finite case reducing to real commutativity. For associativity we use the six-way split of Lemma 2.6 on each of $x, y, z$, giving $6^3 = 216$ cases. The products with singular values have the closed forms recorded in Definition 2.3 (a positive real preserves the sign of an infinity, a negative real flips it, and a zero real produces $\Phi$); with these the sign bookkeeping is settled by the multiplicative sign rules $\operatorname{sgn}(ab) = \operatorname{sgn}(a)\operatorname{sgn}(b)$ for reals, and any occurrence of $0 \cdot \infty = \Phi$ is preserved across regroupings by absorption. $\square$

Together, Theorems 3.1–3.4 establish the positive half of the classification: $\mathbb{T}$ is two commutative monoids sharing the absorbing element $\Phi$, over a conservatively embedded $\mathbb{R}$.

### 3.4 Total division and Anderson's identity

**Theorem 3.5 (Totality and $0/0 = \Phi$).** Division $x/y = x\cdot(1/y)$ is defined for all $x, y \in \mathbb{T}$. In particular the reciprocal of $0$ is $1/0 = +\infty$, so $1/0 = +\infty$ and $0/0 = 0 \cdot (+\infty) = \Phi$.

*Proof.* Totality is immediate since both $\cdot$ and $1/(\cdot)$ are total. By Definition 2.5, $1/0 = 1/\underline{0} = +\infty$; hence $0/0 = \underline{0}\cdot(+\infty) = \Phi$ by the zero clause of Definition 2.3, and $1/0 = \underline{1}\cdot(+\infty) = +\infty$ by the positive clause. $\square$

Anderson's defining identity thus holds "on the nose," and $\Phi$ is exactly the value of the otherwise-undefined $0/0$.

## 4. What collapses: the ring axioms

**Theorem 4.1 (No additive inverse for $+\infty$).** There is no $y \in \mathbb{T}$ with $(+\infty) + y = 0$. Hence $(\mathbb{T}, +)$ is not a group and $\mathbb{T}$ is not a ring.

*Proof.* By Definition 2.2, $(+\infty) + y$ equals $+\infty$ when $y$ is finite or $+\infty$, and equals $\Phi$ when $y \in \{-\infty, \Phi\}$. In no case is the result $\underline{0}$. $\square$

**Theorem 4.2 (Annihilator law fails).** $0 \cdot (+\infty) = \Phi \neq 0$.

*Proof.* The zero clause of Definition 2.3 gives $\underline{0}\cdot(+\infty) = \Phi$, and $\Phi \neq \underline{0}$ since they are distinct constructors. $\square$

**Theorem 4.3 (Distributivity fails).** With $x = \underline{2}$, $y = \underline{-1}$, $z = +\infty$,
$$(x + y)\cdot z = \underline{1}\cdot(+\infty) = +\infty, \quad\text{but}\quad x\cdot z + y \cdot z = (+\infty) + (-\infty) = \Phi,$$
so $(x+y)z \neq xz + yz$.

*Proof.* Direct computation using Definitions 2.2 and 2.3. $\square$

The mechanism is structural: distributing over a sum whose expansion produces $+\infty$ and $-\infty$ forces their sum, which is $\Phi$, whereas the unexpanded product never triggers the indeterminate sum.

**Theorem 4.4 (Cancellation fails).** $(+\infty) + \underline{1} = (+\infty) + \underline{2}$ while $\underline{1} \neq \underline{2}$.

*Proof.* Both sums equal $+\infty$ by Definition 2.2; $\underline{1} \neq \underline{2}$ by injectivity of the embedding. $\square$

Thus $\mathbb{T}$ fails to be a ring in four independent ways: missing additive inverses, a broken annihilator, broken distributivity, and broken cancellation.

## 5. What collapses: the wheel axioms

A **wheel** (in the sense of Carlström) is an algebraic structure that totalizes division by adjoining a reciprocal operator $/(\cdot)$ satisfying, among others, (W1) the involution law $//x = x$ and (W2) a modified distributive law $(x + y)z + 0z = xz + yz$ that carries the correction term $0z$. The one-point projective completion of $\mathbb{R}$ is a wheel. One might hope the transreals are too. They are not.

**Theorem 5.1 (Wheel distributive law fails).** With $x = \underline{2}$, $y = \underline{3}$, $z = +\infty$,
$$(x+y)z + 0z = \underline{5}\cdot(+\infty) + \Phi = (+\infty) + \Phi = \Phi,$$
whereas $xz + yz = (+\infty) + (+\infty) = +\infty$. Since $\Phi \neq +\infty$, axiom (W2) fails.

*Proof.* Direct computation: $0 \cdot (+\infty) = \Phi$ (Theorem 4.2) poisons the left-hand side by absorption (Theorem 3.1), while the right-hand side is a genuine infinity. $\square$

**Theorem 5.2 (Reciprocal is not an involution).** $\frac{1}{1/(-\infty)} = \frac{1}{0} = +\infty \neq -\infty$, so axiom (W1) fails.

*Proof.* $1/(-\infty) = 0$ by Definition 2.5, and $1/0 = +\infty$; the result $+\infty$ differs from $-\infty$. $\square$

**Corollary 5.3 (Strict position of the transreals).** $\mathbb{T}$ is neither a ring nor a wheel. Both wheel failures are traceable to the *sign split* of $\pm\infty$: the correction term $0z$ becomes $\Phi$ precisely because the two signed infinities force $0\cdot\infty$ to be indeterminate, and the reciprocal fails to be an involution precisely because $-\infty$ and $+\infty$ share the single reciprocal-of-zero image $+\infty$. A one-point (unsigned) projective completion has neither problem, which is why it *is* a wheel.

## 6. The classification theorem

Collecting the results:

**Theorem 6.1 (Structure of the transreals).** The transreal system $(\mathbb{T}, +, \cdot, -, 1/(\cdot), 0, 1)$ is:
1. a commutative monoid under $+$ with identity $0$ (Thm 3.3);
2. a commutative monoid under $\cdot$ with identity $1$ (Thm 3.4);
3. sharing a single two-sided absorbing element $\Phi$ for both operations (Thm 3.1);
4. containing $\mathbb{R}$ as a conservatively embedded submonoid for each operation (Thm 3.2);
5. equipped with a total division for which $1/0 = +\infty$ and $0/0 = \Phi$ (Thm 3.5);

but is **not** a ring (Thms 4.1–4.4) and **not** a wheel (Thms 5.1–5.2). Equivalently, $\mathbb{T}$ is *a pair of commutative monoids sharing a global absorbing element, equipped with a total but non-involutive division* — strictly weaker than both a ring and a wheel.

## 7. Algorithms

The finite, constructor-based definitions make every transreal operation directly computable. We describe the two core routines.

**Algorithm A (Transreal evaluation).** Given a symbolic expression tree with leaves in $\mathbb{T}$ and internal nodes in $\{+, \cdot, /, -\}$, evaluate bottom-up using the clause tables of Definitions 2.2–2.5. Because $\Phi$ is absorbing, one may short-circuit: as soon as any subexpression evaluates to $\Phi$, the whole containing sum/product is $\Phi$. Complexity is linear in the size of the tree.

**Algorithm B (Axiom stress-tester).** To decide whether a candidate identity holds on $\mathbb{T}$, enumerate all assignments of the free variables over a *representative set* — the three singular values together with one negative, one zero, and one positive real (justified by Lemma 2.6, since products with infinities depend only on the sign of the real factor) — and evaluate both sides with Algorithm A. An identity involving $k$ variables requires $6^k$ evaluations. This finite test faithfully detects the failures of distributivity, cancellation, and the wheel axioms.

## 8. Applications

**IEEE 754 floating point.** The transreal design is the closest clean algebraic model of the floating-point arithmetic implemented in virtually all modern hardware: $\pm\infty$ correspond to signed overflow/`inf`, and $\Phi$ corresponds to `NaN` ("not a number"). The facts that `NaN` is produced by $0/0$, that it is sticky (`NaN` $+ x = $ `NaN`), and that it propagates as a self-flagging error are exactly Theorems 3.5 and 3.1. Our negative results explain, as theorems rather than engineering lore, *why* floating-point arithmetic cannot be a ring: totality and the ring axioms are incompatible.

**Total functional semantics.** In languages or proof systems that demand every function be total, $\Phi$ furnishes a canonical "error monad" value for otherwise-partial arithmetic, letting expression evaluation proceed without exceptions while remaining auditable.

**Projective geometry contrast.** The comparison with wheels clarifies the algebraic difference between the *two-point* (signed) and *one-point* (unsigned) completions of the real line, quantifying exactly which axioms distinguish them.

## 9. Discussion

The classification pinpoints a single culprit behind every collapse: the indeterminate value $\Phi$ produced by $0 \cdot \infty$ and by $\infty - \infty$, together with the sign split of $\pm\infty$. The very absorption that makes the monoid laws robust is what makes distributivity and the wheel correction term fail — the correction is meant to be benign but is instead poisoned. Meanwhile the involution law is broken not by a poor choice of reciprocal but by the irreducible fact that two signed infinities cannot both be the involutive image of the unique zero. These are not fixable by re-tuning the tables; they are forced by the design goals of totality plus signed infinity.

## 10. Future directions

**Impossibility of a distributive total division ring.** *Conjecture.* Any structure that (i) contains $\mathbb{R}$ as a sub-semiring, (ii) makes division total by adjoining finitely many "infinite/undefined" symbols, and (iii) retains both left and right distributivity, must identify $1$ with $0$ and hence collapse to a point. The intuition: once $0$ acquires a two-sided partner $\infty$ with $0\cdot\infty$ forced away from $0$, the correction term needed to save distributivity is itself absorbed by the error element, so distributivity survives only if $0$ annihilates everything — forcing $1 = 0$.

**Wheel-ness controlled by the number of signs at infinity.** *Conjecture.* The projective completion of $\mathbb{R}$ with $k$ distinguishable infinite elements is a wheel iff $k \le 1$; for $k \ge 2$ at least one wheel axiom (involution or modified distributivity) must fail. The transreal line is the $k=2$ case (shown here to break both), and the classical one-point projective line is the $k=1$ case (a wheel), giving both endpoints of the threshold.

**A real-analysis transfer principle keyed to the singular set.** *Conjecture.* A first-order theorem of real analysis extends verbatim to transreal-valued functions precisely when its statement never quantifies a limit, sum, or product across the singular set $\{+\infty, -\infty, \Phi\}$; statements that do (e.g. the intermediate value theorem over all of $\mathbb{T}$) fail, with the failure always witnessed near $\Phi$. Since $\Phi$ is an absorbing fixed point with no order relation to the reals, any statement whose truth depends on comparing values becomes vacuous or false exactly where $\Phi$ enters.

**Nullity as a universal error monad.** *Conjecture.* The transreal multiplicative monoid is, in a suitable sense, the free commutative monoid on the reals extended by signed infinities and a universal absorbing error element — a "free error monad" for partial algebra.

## 11. Conclusion

Transreal arithmetic buys total division at an exactly measurable price. What survives are two commutative monoids sharing an absorbing error element $\Phi$, with $\mathbb{R}$ embedded conservatively and division total. What collapses are the ring axioms (inverses, annihilation, distributivity, cancellation) and the wheel axioms (modified distributivity, involutive reciprocal). The transreals therefore occupy a precise, previously under-appreciated slot in the algebraic landscape: strictly weaker than a ring, strictly weaker than a wheel, and the faithful algebraic shadow of the floating-point arithmetic that computes our world.
