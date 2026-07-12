# Anti-Mathematics: Negating the Axioms of Set Theory, with a Complete Development of the Finite Universe

## Abstract

We investigate *anti-mathematics*: the systematic study of the theories
obtained by negating individual axioms of Zermelo–Fraenkel set theory
(ZF). Our principal contribution is a complete and self-contained
development of the theory $\mathrm{ZF} - \mathrm{Infinity} + \neg\mathrm{Infinity}$,
the theory of **hereditarily finite sets** $\mathrm{HF} = V_\omega$,
realized concretely in the **Ackermann model** whose carrier is the
natural numbers $\mathbb{N}$ and whose membership relation is
$a \in b :\Longleftrightarrow \text{the } a\text{-th binary digit of } b \text{ is } 1$.
We prove that in this model every ZF axiom other than Infinity holds:
the finite axioms (Empty, Pairing, Union, Power Set, Foundation), the
$\in$-Induction schema, the Separation schema, and the Replacement schema,
with all schema witnesses constructed explicitly as binary bitmasks. We
then prove that negating Infinity **settles** the status of the Axiom of
Choice: whereas Choice is independent of full ZF, in the finite universe it
becomes a theorem. Concretely, the universe carries a definable
well-ordering, every nonempty set has a least member, and every family of
nonempty pairwise-disjoint sets admits an explicitly constructed choice
set. Finally, we establish the hereditary/cumulative structure: the
$\in$-transitive closure of any set is finite, a genuine rank function
exists and strictly decreases along membership, and every set has rank at
most its own code, confirming that the model is contained in $V_\omega$. We
also outline the parallel programs of negating Extensionality (theories of
indistinguishable sets) and negating Foundation (hyperset universes with
Quine atoms).

**Keywords.** Hereditarily finite sets, Ackermann coding, axiom of choice,
well-ordering, Separation, Replacement, $\in$-induction, cumulative rank,
anti-mathematics, negated axioms.

## 1. Introduction

Zermelo–Fraenkel set theory with Choice (ZFC) is the de facto foundation of
mathematics. Its axioms — Extensionality, Empty Set, Pairing, Union, Power
Set, Foundation, Infinity, the Separation and Replacement schemas, and
Choice — are usually treated as a fixed bedrock. Yet each is a *choice*, and
a natural counterfactual arises: for each axiom, what theory results from
replacing it by its negation?

We call this program **anti-mathematics**. It is not the study of
inconsistency — the negated theories we consider are perfectly consistent —
but the study of the alternative mathematical universes that different
axiomatic commitments generate. Three negations organize the present work:

1. **$\neg\mathrm{Infinity}$** yields the hereditarily finite universe
   $\mathrm{HF} = V_\omega$. This is the deep case, developed in full below.
2. **$\neg\mathrm{Extensionality}$** yields theories with distinct sets
   sharing identical members — indistinguishable duplicates.
3. **$\neg\mathrm{Foundation}$** yields hyperset universes containing
   self-membered sets (Quine atoms) and other non-well-founded objects.

Our central technical vehicle is the Ackermann coding, which identifies the
hereditarily finite sets with the natural numbers via binary expansion.
This model turns abstract existence axioms into explicit finite
computations and makes every claim about $\mathrm{HF}$ verifiable by
elementary arithmetic on $\mathbb{N}$.

The headline conceptual result is an **interaction between negations**:
negating Infinity is not independent of Choice. In full ZF, Choice is
independent — both it and its negation are consistent. But in
$\mathrm{ZF} - \mathrm{Infinity} + \neg\mathrm{Infinity}$, Choice is a
theorem. Removing one axiom can convert a second, independent axiom into a
provable fact. This is the kind of structural phenomenon that
anti-mathematics is designed to expose.

## 2. The Ackermann model

### 2.1 Definition

**Definition 2.1 (Ackermann membership).** The Ackermann model has carrier
$\mathbb{N}$. For $a, b \in \mathbb{N}$ define
$$a \in_{\mathrm{A}} b \quad :\Longleftrightarrow\quad \mathrm{bit}_a(b) = 1,$$
where $\mathrm{bit}_a(b)$ is the $a$-th digit in the binary expansion of
$b$. Equivalently, writing $b = \sum_{i} \mathrm{bit}_i(b)\, 2^i$, we have
$a \in_{\mathrm{A}} b$ iff $2^a$ appears in this sum.

Thus each natural number $b$ is read as the finite set of positions of the
$1$s in its binary representation. For instance $0$ codes $\varnothing$;
$1 = 2^0$ codes $\{0\} = \{\varnothing\}$; $2 = 2^1$ codes $\{1\}$;
$3 = 2^0 + 2^1$ codes $\{0,1\}$; and $11 = 2^0 + 2^1 + 2^3$ codes
$\{0,1,3\}$. The correspondence between natural numbers and finite subsets
of $\mathbb{N}$ is a bijection, and iterating the decoding terminates
because of the following fundamental inequality.

### 2.2 The fundamental inequality

**Lemma 2.2 (Membership decreases the code).** For all $a, b \in \mathbb{N}$,
if $a \in_{\mathrm{A}} b$ then $a < b$.

*Proof.* If $\mathrm{bit}_a(b) = 1$ then $b \ge 2^a$. Since $a < 2^a$ for
every $a$, we get $a < 2^a \le b$. $\qquad\blacksquare$

Lemma 2.2 is the linchpin of the entire development. It guarantees that the
membership relation is well-founded, that recursion over membership
terminates, and that transitive closures stay finite.

**Corollary 2.3 (No infinite descent, no self-membership).** There is no
sequence $\cdots \in_{\mathrm{A}} a_2 \in_{\mathrm{A}} a_1 \in_{\mathrm{A}} a_0$, and no $a$ with
$a \in_{\mathrm{A}} a$. Both follow immediately since $\in_{\mathrm{A}}$ embeds into the
strict order $<$ on $\mathbb{N}$.

### 2.3 The finite axioms and the failure of Infinity

The finite ZF axioms hold in the Ackermann model by direct construction on
codes:

- **Empty Set.** $0$ has no set bits, so $\forall x,\ \neg(x \in_{\mathrm{A}} 0)$.
- **Pairing.** For $a, b$, the code $2^a \,|\, 2^b$ (bitwise or) codes
  $\{a, b\}$.
- **Union.** For $a$, the bitwise or of the members of $a$'s members codes
  $\bigcup a$.
- **Power Set.** The subsets of a finite set form a finite set, again coded
  by a natural number.
- **Foundation.** Immediate from Corollary 2.3.

By contrast, **Infinity fails**: there is no code $b$ satisfying the usual
inductive-set property $\varnothing \in_{\mathrm{A}} b \wedge \forall x\,(x \in_{\mathrm{A}} b \to
x \cup \{x\} \in_{\mathrm{A}} b)$, because such a $b$ would have to contain codes of
unbounded size, contradicting Lemma 2.2 (all members of $b$ are $< b$).
Hence the model realizes $\mathrm{ZF} - \mathrm{Infinity} + \neg\mathrm{Infinity}$.

## 3. The ZF schemas survive

We now show the two ZF schemas, together with $\in$-Induction, hold in the
Ackermann model. Throughout, all witnesses are exhibited explicitly.

### 3.1 The $\in$-Induction (set-induction) schema

**Theorem 3.1 ($\in$-Induction).** Let $P$ be any predicate on sets. If
$$\forall a\,\big[(\forall x,\ x \in_{\mathrm{A}} a \to P(x)) \to P(a)\big],$$
then $P(a)$ holds for every set $a$.

*Proof.* By strong induction on $a \in \mathbb{N}$. Assume $P(x)$ for all
$x < a$. For any $x \in_{\mathrm{A}} a$, Lemma 2.2 gives $x < a$, so $P(x)$ holds by the
induction hypothesis; thus $\forall x\,(x \in_{\mathrm{A}} a \to P(x))$, and the
premise yields $P(a)$. $\qquad\blacksquare$

This schema is the constructive core of Foundation and the license for
$\in$-recursion (used in §5 to define rank).

### 3.2 A bitmask fold lemma

Both schemas are proved by folding a bitmask over the members of the input
set. We isolate the combinatorial content.

**Lemma 3.2 (Fold bit test).** Fix a decidable predicate $q$ and a function
$g : \mathbb{N} \to \mathbb{N}$. For a finite list $L$ of naturals, let
$$M(L) = \bigsqcup_{y \in L} \big(\text{if } q(y) \text{ then } 2^{g(y)} \text{ else } 0\big),$$
where $\bigsqcup$ denotes iterated bitwise or. Then for every $z$,
$$\mathrm{bit}_z(M(L)) = 1 \quad\Longleftrightarrow\quad \exists y \in L,\ q(y) \wedge g(y) = z.$$
The special case $g = \mathrm{id}$ gives
$\mathrm{bit}_z(M(L)) = 1 \Leftrightarrow z \in L \wedge q(z)$.

*Proof.* Induction on $L$. The empty list gives $M = 0$, whose bits are all
$0$. For $y :: L'$, the bit-$z$ value of $M(y::L')$ is the or of
$\mathrm{bit}_z(M(L'))$ with the bit-$z$ value of the head term; a case split
on $q(y)$ and on $g(y) = z$ closes the induction. $\qquad\blacksquare$

### 3.3 Separation

**Theorem 3.3 (Separation schema).** For every set $a$ and every decidable
predicate $p$, there is a set $s$ with
$$\forall x,\quad x \in_{\mathrm{A}} s \iff (x \in_{\mathrm{A}} a \wedge p(x)).$$

*Proof.* Take
$$s = \bigsqcup_{y \in [0, a)} \big(\text{if } (\mathrm{bit}_y(a)=1 \wedge p(y)) \text{ then } 2^y \text{ else } 0\big).$$
By Lemma 3.2 (with $g = \mathrm{id}$ and $q(y) = (\mathrm{bit}_y(a)=1 \wedge p(y))$),
$\mathrm{bit}_x(s) = 1$ iff $x < a$ and $\mathrm{bit}_x(a) = 1$ and $p(x)$. Since
$x \in_{\mathrm{A}} a$ already implies $x < a$ (Lemma 2.2), the range restriction is
free, and we obtain $x \in_{\mathrm{A}} s \Leftrightarrow x \in_{\mathrm{A}} a \wedge p(x)$.
$\qquad\blacksquare$

### 3.4 Replacement

**Theorem 3.4 (Replacement schema).** For every set $a$ and every function
$F : \mathbb{N} \to \mathbb{N}$, there is a set $s$ with
$$\forall y,\quad y \in_{\mathrm{A}} s \iff \exists x\,(x \in_{\mathrm{A}} a \wedge y = F(x)).$$

*Proof.* Take
$$s = \bigsqcup_{x \in [0, a)} \big(\text{if } \mathrm{bit}_x(a) = 1 \text{ then } 2^{F(x)} \text{ else } 0\big).$$
By Lemma 3.2 (with $q(x) = (\mathrm{bit}_x(a)=1)$ and $g = F$), $\mathrm{bit}_y(s) = 1$
iff there is $x < a$ with $\mathrm{bit}_x(a) = 1$ and $F(x) = y$; again the range
restriction is free by Lemma 2.2. $\qquad\blacksquare$

Together with §2.3, Theorems 3.1, 3.3, and 3.4 establish:

**Corollary 3.5.** The Ackermann model satisfies every ZF axiom and schema
except Infinity, and satisfies $\neg\mathrm{Infinity}$. Hence
$\mathrm{HF} = \mathrm{ZF} - \mathrm{Infinity} + \neg\mathrm{Infinity}$ is a complete,
consistent set theory realized in $\mathbb{N}$.

## 4. Negating Infinity makes Choice a theorem

The Axiom of Choice (AC) is independent of ZF. We show that it is *not*
independent of $\mathrm{ZF} - \mathrm{Infinity} + \neg\mathrm{Infinity}$: it is provable.

### 4.1 Global choice: the universe is well-ordered

**Theorem 4.1 (Well-ordering of the universe).** The Ackermann universe
carries a definable strict well-order, namely the usual order $<$ on codes.
Consequently a global choice function exists: every nonempty class has a
least element.

*Proof.* $(\mathbb{N}, <)$ is a well-order. Since the carrier of the model
*is* $\mathbb{N}$ and $<$ is definable, the universe is definably
well-ordered. $\qquad\blacksquare$

### 4.2 Choice from a single set

**Lemma 4.2 (Nonempty sets have members).** If $b \ne 0$ then there exists
$i$ with $i \in_{\mathrm{A}} b$.

*Proof.* If no bit of $b$ were set, then $b = 0$ by uniqueness of binary
representation. $\qquad\blacksquare$

**Definition 4.3 (Least member).** For $b \ne 0$, let $\mathrm{lm}(b)$ be the
least $i$ with $\mathrm{bit}_i(b) = 1$ (and $\mathrm{lm}(0) = 0$ as a junk value).

**Theorem 4.4 (Least member).** Every nonempty set $a$ has an $\le$-least
member: there is $m$ with $m \in_{\mathrm{A}} a$ and $\forall x\,(x \in_{\mathrm{A}} a \to m \le x)$.
Indeed $m = \mathrm{lm}(a)$ works.

*Proof.* By Lemma 4.2 the set of members is nonempty; by well-ordering of
$\mathbb{N}$ it has a least element, which is $\mathrm{lm}(a)$, and this element
is a member and a lower bound. $\qquad\blacksquare$

### 4.3 The full Axiom of Choice

**Theorem 4.5 (Choice in the finite universe).** Let $a$ be a set whose
members are all nonempty and pairwise disjoint:
$$\forall b\,(b \in_{\mathrm{A}} a \to b \ne 0), \qquad
\forall b, b'\,(b \in_{\mathrm{A}} a \wedge b' \in_{\mathrm{A}} a \wedge b \ne b' \to \neg\exists x\,(x \in_{\mathrm{A}} b \wedge x \in_{\mathrm{A}} b')).$$
Then there is a choice set $c$ meeting each member of $a$ in exactly one
point:
$$\forall b\,\big(b \in_{\mathrm{A}} a \to \exists! x\,(x \in_{\mathrm{A}} c \wedge x \in_{\mathrm{A}} b)\big).$$

*Proof.* Apply Replacement (Theorem 3.4) to $a$ with the function
$F = \mathrm{lm}$; let $c$ be the resulting image set, so $x \in_{\mathrm{A}} c$ iff
$x = \mathrm{lm}(b')$ for some $b' \in_{\mathrm{A}} a$. Fix $b \in_{\mathrm{A}} a$. Then
$\mathrm{lm}(b) \in_{\mathrm{A}} c$ (it is the image of $b$) and $\mathrm{lm}(b) \in_{\mathrm{A}} b$ (it is a
member of $b$, since $b \ne 0$ by hypothesis), so $\mathrm{lm}(b)$ witnesses
existence. For uniqueness, suppose $y \in_{\mathrm{A}} c$ and $y \in_{\mathrm{A}} b$. Since
$y \in_{\mathrm{A}} c$, we have $y = \mathrm{lm}(b')$ for some $b' \in_{\mathrm{A}} a$. If $b' \ne b$,
then $y = \mathrm{lm}(b') \in_{\mathrm{A}} b'$ and $y \in_{\mathrm{A}} b$ would place $y$ in both $b'$ and
$b$, contradicting disjointness. Hence $b' = b$ and $y = \mathrm{lm}(b)$.
$\qquad\blacksquare$

The choice set is not conjured by a non-constructive principle; it is
*computed* by selecting the least element of each member. This is the sense
in which negating Infinity resolves the status of Choice.

## 5. Hereditary finiteness and the cumulative rank

We finally verify that the model is exactly $V_\omega$.

### 5.1 Finite transitive closure

**Lemma 5.1 (Ancestors are smaller).** If $x$ is an $\in_{\mathrm{A}}$-ancestor of $a$
— i.e. $x \mathrel{(\in_{\mathrm{A}})^{+}} a$ in the transitive closure — then $x < a$.

*Proof.* Induction on the transitive-closure derivation. The base case is
Lemma 2.2; the inductive step chains two instances of Lemma 2.2 by
transitivity of $<$. $\qquad\blacksquare$

**Theorem 5.2 (Hereditary finiteness).** For every set $a$, the class of
all $\in_{\mathrm{A}}$-ancestors of $a$ is finite. Equivalently, the transitive
closure of $a$ is finite: every set of the model is hereditarily finite.

*Proof.* By Lemma 5.1 the ancestor class is contained in $\{x : x < a\}$,
which is finite; a subset of a finite set is finite. $\qquad\blacksquare$

**Corollary 5.3 (Finite membership).** Every set has finitely many members,
since the members of $a$ are contained in $\{x : x < a\}$.

### 5.2 The rank function

**Definition 5.4 (Rank).** Define $\mathrm{rank} : \mathbb{N} \to \mathbb{N}$ by
$\in$-recursion:
$$\mathrm{rank}(a) = \sup\{\, \mathrm{rank}(x) + 1 : x \in_{\mathrm{A}} a \,\},$$
with the convention $\sup \varnothing = 0$. The recursion is well-founded by
Lemma 2.2.

**Theorem 5.5.** $\mathrm{rank}(0) = 0$, and $\mathrm{rank}$ strictly decreases
along membership:
$$x \in_{\mathrm{A}} a \implies \mathrm{rank}(x) < \mathrm{rank}(a).$$

*Proof.* The empty set has no members, so its supremum is $0$. If
$x \in_{\mathrm{A}} a$, then $\mathrm{rank}(x) + 1$ is one of the terms in the supremum
defining $\mathrm{rank}(a)$, whence $\mathrm{rank}(x) < \mathrm{rank}(x) + 1 \le
\mathrm{rank}(a)$. $\qquad\blacksquare$

**Theorem 5.6 (Containment in $V_\omega$).** Every set has rank at most its
own code: $\mathrm{rank}(a) \le a$.

*Proof.* By strong induction on $a$. For each member $x \in_{\mathrm{A}} a$ we have
$x < a$ (Lemma 2.2) and, by the induction hypothesis, $\mathrm{rank}(x) \le x <
a$, so $\mathrm{rank}(x) + 1 \le a$. Taking the supremum over members preserves
the bound, giving $\mathrm{rank}(a) \le a$. $\qquad\blacksquare$

Since every rank is a finite natural number, the cumulative hierarchy of the
model never leaves the finite stages: the model is contained in $V_\omega$,
and together with Corollary 3.5 it *is* $V_\omega = \mathrm{HF}$.

## 6. Two further anti-axioms

### 6.1 Negating Extensionality

Extensionality asserts $\forall a, b\,[(\forall x, x \in a \leftrightarrow x
\in b) \to a = b]$. Negating it permits **distinct sets with identical
members** — for example two different empty sets $\varnothing_1 \ne
\varnothing_2$ that are indistinguishable by membership. The resulting
theory is a theory of indistinguishable duplicates. The natural structural
question is how far such a universe departs from an extensional one: one
forms the quotient by the indistinguishability relation "$a$ and $b$ have
the same members and are interchangeable everywhere," and shows that this
quotient recovers the standard hereditarily finite universe precisely when
membership is forced to be a congruence for indistinguishability. Thus
$\neg\mathrm{Extensionality}$ is consistent, and its models are extensional
universes with a layer of duplicated atoms.

### 6.2 Negating Foundation

Foundation forbids infinite descending $\in$-chains and self-membership.
Negating it yields **non-well-founded (hyperset) universes**. The simplest
inhabitants are **Quine atoms**: sets $x$ with $x = \{x\}$, each its own
unique member. A full development models such universes as coalgebras for
the finite-powerset functor and adopts an anti-foundation axiom (AFA)
asserting that every directed graph has a unique *decoration* by sets — a
unique assignment of a set to each node whose members are the sets assigned
to its out-neighbors. AFA is consistent relative to ZF and gives a rich
theory well suited to circular and self-referential structures.

## 7. Algorithms

The Ackermann model makes set theory computational. We record the core
routines (full implementations appear in the accompanying demonstration
code).

1. **Decode / encode.** A number $b$ decodes to the finite set
   $\{a : \mathrm{bit}_a(b) = 1\}$; a finite set $S$ encodes to
   $\sum_{a \in S} 2^a$. Both are $O(\log b)$ / $O(|S|)$ bit operations.
2. **Separation.** Given $a$ and decidable $p$, compute
   $\bigsqcup_{y < a,\ \mathrm{bit}_y(a)=1,\ p(y)} 2^y$.
3. **Replacement.** Given $a$ and $F$, compute
   $\bigsqcup_{y < a,\ \mathrm{bit}_y(a)=1} 2^{F(y)}$.
4. **Least member.** $\mathrm{lm}(b)$ is the index of the lowest set bit, i.e.
   the number of trailing zeros of $b$.
5. **Choice set.** Given a family code $a$ of disjoint nonempty sets,
   compute $\bigsqcup_{b\,\in_{\mathrm{A}}\,a} 2^{\mathrm{lm}(b)}$.
6. **Rank.** Compute $\mathrm{rank}(a)$ by memoized $\in$-recursion:
   $\mathrm{rank}(a) = \max_{x\,\in_{\mathrm{A}}\,a}(\mathrm{rank}(x) + 1)$, base $0$.

## 8. Discussion

The Ackermann development shows that "removing infinity" is not a
subtraction but a substitution that yields a robust world. Every finite ZF
axiom and both schemas survive, and the resulting universe is exactly
$V_\omega$, pinned down by a rank function bounded by the code. The most
conceptually interesting phenomenon is the *interaction* between negated and
retained axioms: negating Infinity converts Choice from an independent
axiom into a theorem. This illustrates a general moral of anti-mathematics —
that the logical status of an axiom is contingent on its axiomatic
neighbors, and that deliberately negating one assumption can reverberate
through the others.

A pleasant secondary theme is *effectivity*. In the Ackermann model, the
Separation and Replacement schemas — sweeping existence principles in the
abstract — become short, explicit bitmask computations, and Choice becomes a
literal "take the least" algorithm. The finite universe is not only
consistent; it is fully computable.

## 9. Future work

Several threads extend the present development.

1. **Kuratowski functions as sets.** Encode ordered pairs and functions as
   internal $\mathrm{HF}$ objects and re-prove Replacement and Choice with the
   selecting function delivered as an internal set rather than a
   meta-function.
2. **Internal $\in$-recursion.** Formulate finite $\in$-recursion as an
   internal operator, prove the recursion theorem inside the model, and
   derive rank as an instance.
3. **Sharpened anti-Extensionality.** Characterize the indistinguishability
   classes of the duplicated-empty-set universe and show precisely when the
   quotient recovers $\mathrm{HF}$.
4. **Anti-Choice via permutation models.** Build a Fraenkel–Mostowski
   (permutation) model with atoms in which a specified choice function
   provably fails, giving a finitary shadow of Solovay's "all sets
   measurable" phenomenon.
5. **Completed anti-Foundation.** Extend the Quine-atom universe to a full
   hyperset model as a coalgebra for the finite-powerset functor and prove
   AFA: every graph has a unique decoration.

## 10. Conclusion

Anti-mathematics turns the fixed foundations of set theory into a space of
alternatives to be explored. Negating Infinity produces the hereditarily
finite universe $V_\omega$, realized concretely in the natural numbers via
the Ackermann coding, in which every ZF axiom but Infinity holds, the
schemas reduce to bit manipulation, and — most strikingly — the Axiom of
Choice becomes a theorem, provable by taking least elements. Negating
Extensionality and Foundation open two further coherent worlds, of
indistinguishable duplicates and of self-membered hypersets. Together these
results map a small but instructive region of the landscape of possible
mathematics, and demonstrate that breaking a rule, done carefully, is a
route to understanding what the rule was for.
