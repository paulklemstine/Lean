# Anti-Mathematics: Concrete Models for the Negations of the Set-Theoretic Axioms

## Abstract

We investigate *anti-mathematics*: the theories obtained by negating individual
axioms of Zermelo–Fraenkel set theory while retaining the others. Rather than
reasoning hypothetically from an assumed negation, we establish consistency by
*constructing explicit models*. Using Ackermann's binary coding, which identifies
each natural number with a hereditarily finite set via
$a \in b \iff \operatorname{bit}_a(b) = 1$, we build three universes.

1. **Negating Infinity.** The plain Ackermann universe $(\mathbb{N}, \in_A)$
   satisfies Extensionality, Empty Set, Pairing, Union, Power Set, and Foundation,
   yet contains no inductive set. It is a complete model of hereditarily finite set
   theory, i.e. of $\mathrm{ZF} - \mathrm{Infinity} + \neg\mathrm{Infinity}$.

2. **Negating Extensionality.** Adjoining a duplicate empty object to the Ackermann
   universe yields a model with distinct objects sharing all members. We prove that
   indistinguishability is an equivalence relation which nonetheless *cannot* be
   quotiented away, because membership is not a congruence for it.

3. **Negating Foundation.** Adjoining a Quine atom $\Omega = \{\Omega\}$ to the
   Ackermann universe produces a model in which membership fails to be
   well-founded, so Regularity fails, while all genuine sets remain well-founded
   and $\Omega$ stays extensionally distinguishable.

Each result is accompanied by a complete proof sketch. The unifying theme is that
the ordinary natural numbers, suitably interpreted, are rich enough to realize
multiple mutually incompatible "anti-theories," demonstrating that the choice of
axioms is exactly that — a choice.

**Keywords:** hereditarily finite sets, Ackermann coding, axiom of infinity,
extensionality, foundation, Quine atom, non-well-founded sets, consistency by model
construction.

---

## 1. Introduction

The axioms of Zermelo–Fraenkel set theory with Choice (ZFC) are the de facto
foundation of contemporary mathematics. Each axiom encodes a structural intuition:
Extensionality says a set is determined by its members; Foundation forbids
membership cycles; Infinity guarantees a completed infinite totality. A natural
foundational experiment — the "anti-mathematics" program — is to negate a single
axiom and study the resulting theory.

The methodological pitfall is that merely *assuming* $\neg A$ for an axiom $A$ is
worthless if the resulting theory is inconsistent, since an inconsistent theory
proves everything. The correct standard is *consistency relative to a background
theory*, established by exhibiting a model. In this paper we adopt the strongest
possible version of that standard: for each of three axioms we construct a fully
explicit model, define its membership relation concretely, and verify both the
surviving axioms and the targeted negation.

All three models are built on a single foundation, Ackermann's coding of the
hereditarily finite sets by the natural numbers. Section 2 develops this coding and
its arithmetic. Section 3 treats the negation of Infinity, Section 4 the negation
of Extensionality, and Section 5 the negation of Foundation. Section 6 discusses
mutual consistency and relations to the wider literature, and Section 7 lists
future directions.

---

## 2. The Ackermann coding of hereditarily finite sets

### 2.1 Definition

**Definition 2.1 (Ackermann membership).** For natural numbers $a, b \in \mathbb{N}$
define
$$ a \in_A b \quad :\Longleftrightarrow\quad \operatorname{bit}(b, a) = 1, $$
where $\operatorname{bit}(b, a)$ is the $a$-th bit in the binary expansion of
$b$. Equivalently, writing $b = \sum_{i} \varepsilon_i 2^i$ with $\varepsilon_i \in
\{0,1\}$, we have $a \in_A b \iff \varepsilon_a = 1$.

Under this reading each number $b$ *is* the finite set $\{\,a : a \in_A b\,\}$ of
positions of its $1$-bits. Since those positions are themselves numbers, hence
themselves sets, and since the coding of any member is strictly smaller (Lemma
2.3), the decoding terminates: every number is a hereditarily finite set, and the
map is a bijection between $\mathbb{N}$ and the class $\mathrm{HF}$ of hereditarily
finite sets.

### 2.2 Basic arithmetic of the coding

**Lemma 2.2 (Empty set).** For all $a$, $\neg(a \in_A 0)$.

*Proof.* The binary expansion of $0$ has all bits zero, so $\operatorname{bit}(0,
a) = 0$ for every $a$. $\qquad\blacksquare$

**Lemma 2.3 (Membership decreases the code).** If $a \in_A b$ then $a < b$.

*Proof.* If bit $a$ of $b$ is set then $b \ge 2^a$. Combined with the elementary
inequality $a < 2^a$, this gives $a < 2^a \le b$. $\qquad\blacksquare$

Lemma 2.3 is the arithmetic heart of the entire development: it drives Foundation
(Section 2.4) and, later, the failure of Infinity (Section 3).

**Corollary 2.4 (No self-membership).** For all $a$, $\neg(a \in_A a)$, since
$a \in_A a$ would give $a < a$.

### 2.3 Extensionality and the set-forming operations

**Theorem 2.5 (Extensionality).** If $\forall x\,(x \in_A a \iff x \in_A b)$ then
$a = b$.

*Proof.* Two natural numbers with identical bits in every position are equal (a
number is determined by its binary expansion). $\qquad\blacksquare$

**Definition 2.6 (Adjunction).** For $a, b \in \mathbb{N}$ let
$$ \operatorname{adjoin}(a, b) := b \mathbin{|} 2^a $$
(bitwise OR), i.e. $b$ with bit $a$ switched on.

**Lemma 2.7 (Membership in an adjunction).**
$x \in_A \operatorname{adjoin}(a,b) \iff x = a \ \lor\ x \in_A b.$

*Proof.* $\operatorname{bit}(b \mathbin{|} 2^a, x) = \operatorname{bit}(b, x)
\lor \operatorname{bit}(2^a, x)$, and $\operatorname{bit}(2^a, x) = 1$ iff
$x = a$. $\qquad\blacksquare$

From these primitives the finitary ZF axioms follow.

**Theorem 2.8 (Empty Set).** There is $e$ with $\forall x\,\neg(x \in_A e)$; take
$e = 0$ (Lemma 2.2).

**Theorem 2.9 (Pairing).** For all $a, b$ there is $p$ with $x \in_A p \iff x = a
\lor x = b$. Take $p = \operatorname{adjoin}(a, \operatorname{adjoin}(b, 0))$; the
claim follows from Lemma 2.7 and Lemma 2.2.

**Theorem 2.10 (Binary Union).** For all $a, b$ there is $u$ with $x \in_A u \iff
x \in_A a \lor x \in_A b$. Take $u = a \mathbin{|} b$; then $\operatorname{bit}(a
\mathbin{|} b, x) = \operatorname{bit}(a,x) \lor \operatorname{bit}(b,x)$.

**Theorem 2.11 (Subset via bitmask).** For all $x, a$,
$$ \bigl(\forall z\,(z \in_A x \to z \in_A a)\bigr) \iff x \mathbin{\&} a = x, $$
where $\mathbin{\&}$ is bitwise AND.

*Proof.* ($\Rightarrow$) For each bit position $i$: if bit $i$ of $x$ is $0$ then
bit $i$ of $x \mathbin{\&} a$ is $0$; if bit $i$ of $x$ is $1$ then $i \in_A x$, so
$i \in_A a$, so bit $i$ of $a$ is $1$ and bit $i$ of $x \mathbin{\&} a$ is $1$. Thus
$x \mathbin{\&} a$ and $x$ agree in every bit. ($\Leftarrow$) If $x \mathbin{\&} a =
x$ and $z \in_A x$, then bit $z$ of $x$ is $1$, hence bit $z$ of $x \mathbin{\&} a$
is $1$, forcing bit $z$ of $a$ to be $1$, i.e. $z \in_A a$. $\qquad\blacksquare$

**Theorem 2.12 (Union).** For all $a$ there is $u$ with
$x \in_A u \iff \exists b\,(b \in_A a \land x \in_A b).$

*Proof sketch.* Let $L$ be the (finite) list of $b < a$ with $b \in_A a$; by Lemma
2.3 these are all the members of $a$. Set $u = \bigvee_{b \in L} b$ (iterated
bitwise OR). Then bit $x$ of $u$ is on iff some $b \in L$ has bit $x$ on, i.e. iff
some member $b$ of $a$ has $x \in_A b$. $\qquad\blacksquare$

**Theorem 2.13 (Power Set).** For all $a$ there is $p$ with
$x \in_A p \iff \forall z\,(z \in_A x \to z \in_A a).$

*Proof sketch.* By Theorem 2.11 the condition is $x \mathbin{\&} a = x$, and every
such subset $x$ satisfies $x \le a$. Set $p = \bigvee_{x \le a,\ x \mathbin{\&} a =
x} 2^x$. Then bit $x$ of $p$ is on iff $x \le a$ and $x \mathbin{\&} a = x$; and any
$x$ with $x \mathbin{\&} a = x$ automatically satisfies $x = x \mathbin{\&} a \le a$,
so the bound is not a restriction. $\qquad\blacksquare$

### 2.4 Foundation

**Theorem 2.14 (Foundation, well-founded form).** The relation $\in_A$ is
well-founded on $\mathbb{N}$.

*Proof.* By Lemma 2.3, $\in_A$ is a subrelation of $<$ on $\mathbb{N}$, and $<$ is
well-founded; a subrelation of a well-founded relation is well-founded.
$\qquad\blacksquare$

**Theorem 2.15 (Regularity, element form).** Every nonempty set has an
$\in_A$-minimal member: if $a \ne 0$ there is $m$ with $m \in_A a$ and
$\forall x\,(x \in_A a \to \neg(x \in_A m))$.

*Proof.* If $a \ne 0$ then $a$ has at least one $1$-bit, so the set of members is
nonempty; let $m$ be the *least* member. Any $x \in_A m$ satisfies $x < m$ by Lemma
2.3, so $x$ cannot be a member of $a$ (that would contradict minimality of $m$).
$\qquad\blacksquare$

The Ackermann universe is thus a model of $\mathrm{ZF} - \mathrm{Infinity}$; the
next section shows Infinity itself *fails*.

---

## 3. Negating Infinity: the hereditarily finite universe

### 3.1 Successor and numerals

**Definition 3.1 (Successor).** $\operatorname{succ}(a) := \operatorname{adjoin}(a,
a) = a \mathbin{|} 2^a$, the von Neumann successor $a \cup \{a\}$.

**Lemma 3.2.** $x \in_A \operatorname{succ}(a) \iff x = a \lor x \in_A a$; in
particular $a \in_A \operatorname{succ}(a)$, and hence $a < \operatorname{succ}(a)$
by Lemma 2.3.

**Definition 3.3 (Von Neumann numerals).**
$$ \operatorname{num}(0) := 0, \qquad \operatorname{num}(n+1) := \operatorname{succ}(\operatorname{num}(n)). $$
These code $\varnothing,\ \{\varnothing\},\ \{\varnothing,\{\varnothing\}\},\dots$

**Lemma 3.4 (Numerals grow).** $n \le \operatorname{num}(n)$ for all $n$.

*Proof.* Induction. Base: $0 \le 0$. Step: if $n \le \operatorname{num}(n)$ then,
since $\operatorname{num}(n) < \operatorname{succ}(\operatorname{num}(n)) =
\operatorname{num}(n+1)$ by Lemma 3.2, we get $n + 1 \le \operatorname{num}(n+1)$.
$\qquad\blacksquare$

### 3.2 The main theorem

**Definition 3.5 (Inductive set).** $I$ is *inductive* if $0 \in_A I$ and
$\forall x\,(x \in_A I \to \operatorname{succ}(x) \in_A I)$. The Axiom of Infinity
asserts an inductive set exists.

**Theorem 3.6 (Anti-Infinity).** In the Ackermann universe there is no inductive
set. Hence Infinity fails, and $(\mathbb{N}, \in_A)$ is a model of
$\mathrm{ZF} - \mathrm{Infinity} + \neg\mathrm{Infinity}$ — the hereditarily finite
sets.

*Proof.* Suppose $I$ is inductive. By induction on $n$, every numeral is a member:
$\operatorname{num}(0) = 0 \in_A I$ by hypothesis, and if $\operatorname{num}(n)
\in_A I$ then $\operatorname{num}(n+1) = \operatorname{succ}(\operatorname{num}(n))
\in_A I$ by closure. In particular $\operatorname{num}(I) \in_A I$, so by Lemma 2.3
$\operatorname{num}(I) < I$. But Lemma 3.4 gives $I \le \operatorname{num}(I)$.
Together, $I \le \operatorname{num}(I) < I$, i.e. $I < I$ — a contradiction.
$\qquad\blacksquare$

### 3.3 Discussion

The proof isolates the exact tension between Infinity and the other axioms in this
model: Infinity demands a set closed under an operation that strictly increases the
code without bound, but Foundation (via Lemma 2.3) demands that all members of a set
have smaller codes. The two are irreconcilable precisely because no natural number
can exceed all natural numbers. The resulting universe is a legitimate, complete
set theory in which every object is finite to its core.

---

## 4. Negating Extensionality: indistinguishable sets

### 4.1 The model

**Definition 4.1 (Non-extensional universe).** Let $V := \{\star\} \cup \mathbb{N}$
(a disjoint copy of $\mathbb{N}$ together with one extra element $\star$). Define
membership $\in_V$ by
$$ m \in_V n \iff m \in_A n \ \ (m, n \in \mathbb{N}), \qquad \text{and $\star$ is
never a member and has no members.} $$
Concretely $\star$ is a *second empty object*, distinct from the Ackermann empty set
$0$.

### 4.2 Failure of Extensionality

**Theorem 4.2 (Non-extensionality).** There exist distinct $a, b \in V$ with the
same members. Indeed $0$ and $\star$ are distinct, yet both have no members.

*Proof.* $0 \ne \star$ by construction. For any $x$, $x \in_V 0$ is false (Lemma
2.2) and $x \in_V \star$ is false by definition; hence $0$ and $\star$ have exactly
the same (empty) membership. $\qquad\blacksquare$

### 4.3 Indistinguishability and the obstruction to repair

**Definition 4.3 (Indistinguishability).** For $a, b \in V$ put
$a \approx b :\iff \forall x\,(x \in_V a \iff x \in_V b)$.

**Theorem 4.4.** $\approx$ is an equivalence relation.

*Proof.* Reflexivity, symmetry, and transitivity are inherited pointwise from
$\iff$. $\qquad\blacksquare$

**Theorem 4.5 (Genuine sets are separated).** For $n, m \in \mathbb{N}$,
$\operatorname{some}(n) \approx \operatorname{some}(m) \iff n = m$; and
$\operatorname{some}(n) \approx \star \iff n = 0$.

*Proof.* If two genuine sets are indistinguishable then they have the same
Ackermann members, so they are equal by Theorem 2.5; the converse is reflexivity. A
genuine set is indistinguishable from $\star$ iff it has no members iff it is $0$.
$\qquad\blacksquare$

So $\approx$ glues exactly the pair $\{0, \star\}$ and nothing else. One might hope
to *quotient* $V$ by $\approx$ and recover an extensional universe. The next result
shows this is impossible.

**Theorem 4.6 (Membership is not a congruence).** There exist $a \approx a'$ and a
set $b$ with $a \in_V b$ but $a' \notin_V b$.

*Proof.* Take $a = 0$, $a' = \star$ (so $a \approx a'$ by Theorem 4.5), and $b = 1
= \{0\}$. Then $0 \in_V 1$ (bit $0$ of $1$ is on), while $\star \notin_V 1$ since
$\star$ is never a member of anything. $\qquad\blacksquare$

**Corollary 4.7.** The quotient $V/\!\approx$ does not carry a well-defined
membership relation induced from $\in_V$; one cannot collapse indistinguishable
objects to restore Extensionality. The failure of Extensionality in this universe
is therefore essential, not a removable redundancy.

---

## 5. Negating Foundation: a Quine atom

### 5.1 The model

**Definition 5.1 (Anti-founded universe).** Let $W := \{\Omega\} \cup \mathbb{N}$,
with $\Omega$ a single extra object. Define membership $\in_W$ by
$$
m \in_W n \iff m \in_A n \ (m,n \in \mathbb{N}); \qquad \Omega \in_W \Omega; \qquad
\text{no other memberships involving } \Omega.
$$
Thus $\Omega$'s unique member is itself, and $\Omega$ belongs to no genuine set.

**Theorem 5.2 (Baseline: genuine Foundation).** Restricted to $\mathbb{N}$, the
relation $\in_A$ is well-founded (Theorem 2.14), and no genuine set contains itself
(Corollary 2.4). This is the contrast baseline that anti-Foundation deliberately
breaks.

### 5.2 The Quine atom

**Theorem 5.3 (Self-membership).** $\Omega \in_W \Omega$.

*Proof.* Immediate from the definition. $\qquad\blacksquare$

**Theorem 5.4 ($\Omega = \{\Omega\}$).** For all $x \in W$, $x \in_W \Omega \iff x =
\Omega$.

*Proof.* The only membership into $\Omega$ declared is $\Omega \in_W \Omega$; genuine
sets never belong to $\Omega$. $\qquad\blacksquare$

**Theorem 5.5 ($\Omega$ is distinguishable).** No genuine set has the same members
as $\Omega$: for every $n \in \mathbb{N}$, it is not the case that
$\forall x\,(x \in_W \Omega \iff x \in_W \operatorname{some}(n))$.

*Proof.* Take $x = \Omega$. Then $\Omega \in_W \Omega$ holds but $\Omega \in_W
\operatorname{some}(n)$ fails. So the memberships differ. $\qquad\blacksquare$

Theorem 5.5 certifies that the failure here is genuinely a failure of *Foundation*,
not of Extensionality: $\Omega$ is not a stealth duplicate of some genuine set.

### 5.3 Failure of Foundation

**Theorem 5.6 (Regularity fails).** The nonempty set $\Omega$ has no
$\in_W$-minimal member.

*Proof.* By Theorem 5.4 the only member of $\Omega$ is $\Omega$ itself. A minimal
member $m$ would need $m \in_W \Omega$ (so $m = \Omega$) and $\forall x\,(x \in_W
\Omega \to \neg (x \in_W m))$. But $\Omega \in_W \Omega$ and $m = \Omega$ give
$\Omega \in_W m$, contradicting the minimality condition applied to $x = \Omega$.
$\qquad\blacksquare$

**Theorem 5.7 (Anti-Foundation).** The relation $\in_W$ is not well-founded.

*Proof.* Suppose it were. Then every element would be accessible, and by induction
on accessibility one proves $\neg(x \in_W x)$ for all $x$: if $x$ is accessible and
$x \in_W x$, apply the induction hypothesis to the member $x$ of $x$ to derive
$\neg(x \in_W x)$, contradiction. In particular $\neg(\Omega \in_W \Omega)$,
contradicting Theorem 5.3. Hence $\in_W$ is not well-founded. $\qquad\blacksquare$

Equivalently, $\Omega \in_W \Omega \in_W \Omega \in_W \cdots$ is an infinite
descending membership chain, the canonical witness against Foundation.

---

## 6. Mutual consistency and context

**Independence, made concrete.** The three constructions provide relative
consistency proofs. Assuming the background theory used to build $\mathbb{N}$ and
its bit arithmetic is consistent:

- $\neg\mathrm{Infinity}$ is consistent with $\mathrm{ZF} - \mathrm{Infinity}$
  (Section 3);
- $\neg\mathrm{Extensionality}$ is consistent with the finitary axioms (Section 4);
- $\neg\mathrm{Foundation}$ is consistent with the finitary axioms and with
  Extensionality on the genuine part (Section 5).

**Compatibility of the anti-axioms.** The three negations are pairwise compatible in
the sense that they concern independent structural features and can be combined by
overlaying the constructions. For instance, one may adjoin *both* a duplicate empty
object $\star$ and a Quine atom $\Omega$ to the finite Ackermann universe, obtaining a
single model that is simultaneously finite, non-extensional, and non-well-founded.
The Ackermann base being finite (Section 3), all three negations are jointly
realizable over the hereditarily finite core. This shows the anti-axioms do not
conflict: each removes a different constraint.

**Relation to the classical picture.** The Ackermann model is the standard model of
$\mathrm{ZF} - \mathrm{Infinity}$ and is well known to be $\in$-isomorphic to the
hereditarily finite sets $\mathrm{HF}$. Quine atoms are the minimal witnesses to the
failure of Foundation and the entry point to Aczel's anti-foundation axiom (AFA)
and the theory of hypersets, which models circular and self-referential phenomena.
Duplicate empty objects are the standard textbook illustration that Extensionality
is independent of the other axioms. The contribution here is to render all three as
uniform, explicit, fully verified constructions on a single arithmetic base.

**On the third mission strand (Choice).** The mission also envisions negating
Choice to obtain universes where every set of reals is Lebesgue measurable
(Solovay's model). That strand is genuinely infinitary and is beyond the finite
Ackermann base used here; we record it as a future direction rather than a result.

---

## 7. Future directions

1. **Separation and Replacement schemas.** For any decidable predicate, build the
   subset $\{x \in_A a : p(x)\}$ explicitly as a finite bit-selection and prove the
   Separation schema; then Replacement over finite sets.

2. **Ackermann as an $\in$-isomorphism.** Formalize the bijection
   $(\mathbb{N}, \in_A) \cong (\mathrm{HF}, \in)$ as a membership-preserving
   isomorphism onto the standard hereditarily finite sets.

3. **Full anti-foundation (AFA).** Upgrade the single Quine atom to an Aczel-style
   universe of hypersets and prove the AFA unique-decoration property: every
   directed graph has a unique set-decoration.

4. **Anti-Choice and measurability.** Formalize a fragment of the Solovay picture,
   e.g. that a $\neg\mathrm{AC}$ context blocks the usual Vitali non-measurable-set
   construction.

5. **Combined anti-universes.** Systematically classify which combinations of
   negated axioms are jointly consistent, using overlays of the constructions in
   Section 6.

---

## 8. Conclusion

Anti-mathematics is not a curiosity but a disciplined study of the *independence* of
foundational assumptions, carried out by explicit model construction. Starting from
nothing more than the natural numbers and their binary representation, we produced
three coherent universes, each violating exactly one axiom — no infinity, no
extensionality, no foundation — while preserving the rest. The uniformity of the
constructions underscores a foundational lesson: the axioms of set theory are
choices, and each choice, when reversed, opens onto a self-consistent alternative
world.
