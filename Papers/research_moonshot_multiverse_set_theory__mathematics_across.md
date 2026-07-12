# Multiverse Set Theory: An Abstract Framework for Independence, Forcing, and a Tropical Bridge

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

The multiverse view of set theory, advanced by Joel David Hamkins, holds
that there is no single privileged universe of sets but rather a vast
collection of models of the Zermelo–Fraenkel axioms with choice (ZFC),
across which statements independent of ZFC — such as the Continuum
Hypothesis (CH) — take different truth values. We give an abstract,
model-agnostic formalization of this view. A *multiverse* is a nonempty
collection of universes, a type of statements, and a truth relation. Over
this skeleton we define *multiverse truth*, *possibility*, *independence*,
and *undeterminedness*, and prove the central structural theorem that a
statement is independent across the multiverse **if and only if** it has no
multiverse-wide truth value. We instantiate the framework on a concrete
three-universe multiverse (the constructible universe $L$, a Cohen
extension, and a universe with a measurable cardinal) and verify that ZFC is
multiverse-true while CH, V=L, and the existence of large cardinals are all
independent, hence undetermined. We then isolate the role of forcing: if
every universe admits a forcing extension flipping a statement's truth
value, that statement must be undetermined — the precise sense in which
"there is no true CH." Finally we establish a cross-domain bridge to
tropical (min-plus) algebra: encoding truth values as $\{0,1\}$ yields a
semiring homomorphism from the Boolean semiring to the tropical semiring
under which OR becomes minimum and AND becomes addition. Consequently
existential quantification over a finite multiverse is a tropical sum and
universal quantification is a tropical product, giving each statement a
quantitative "tropical signature" that detects independence.

## 1. Introduction

Cantor's Continuum Hypothesis asserts that there is no cardinality strictly
between that of the natural numbers $\aleph_0$ and that of the real numbers
$2^{\aleph_0}$. Gödel (1940) proved that CH is consistent with ZFC by
exhibiting the constructible universe $L$, and Cohen (1963) proved that
$\neg$CH is also consistent by inventing forcing. Together these results
establish that CH is **independent** of ZFC: neither it nor its negation is
a theorem.

There are two philosophical responses. The **universe view** maintains that
there is one true universe of sets $V$, and that independence merely marks
the limits of our current axioms; the search for new axioms deciding CH
continues. The **multiverse view** of Hamkins holds instead that the
independence phenomenon reflects genuine ontological plurality: there are
many equally legitimate universes of sets, related by constructions such as
forcing, and a statement like CH is simply not the kind of thing that has an
absolute truth value.

This paper offers a compact mathematical formalization of the multiverse
view sufficient to state and prove its core structural claims, and then
reveals an unexpected algebraic structure underlying the logic of
multiverse quantification. Our contributions are:

1. An **abstract multiverse framework** (Section 3) with the notions of
   multiverse truth, possibility, independence, and undeterminedness, and
   the theorem that **independence is equivalent to undeterminedness**.
2. A **concrete instantiation** (Section 4) on three named universes,
   verifying the independence of CH, V=L, and large cardinals, the
   multiverse-truth of ZFC, and the incompatibility of V=L with large
   cardinals.
3. A **forcing-closure theorem** (Section 5): forcing closure alone forces
   undeterminedness.
4. A **tropical bridge** (Section 6): a Boolean-to-tropical semiring
   homomorphism translating possibility into a tropical sum and necessity
   into a tropical product, and yielding a tropical signature for
   independence.

## 2. Preliminaries and notation

We work in an ambient metatheory and treat "universes" and "statements" as
opaque types; we do **not** construct genuine models of ZFC, which would be
a far larger undertaking. Instead we axiomatize exactly the data the
multiverse picture requires. This model-agnostic stance is a feature: all
structural theorems below hold for *any* interpretation of the primitives,
including — under the natural interpretation — genuine models with
first-order satisfaction as the truth relation.

We write $u \models s$ for "statement $s$ holds in universe $u$." Logical
connectives $\wedge, \vee, \neg, \forall, \exists$ are those of the
metatheory.

## 3. The abstract multiverse

**Definition 3.1 (Multiverse).** A *multiverse* $M$ consists of:

- a type $\mathrm{Universe}$ of universes;
- a type $\mathrm{Statement}$ of statements;
- a truth relation $\models\ :\ \mathrm{Universe} \to \mathrm{Statement}
  \to \mathrm{Prop}$;
- a proof that $\mathrm{Universe}$ is nonempty.

The nonemptiness requirement is essential: it prevents vacuous universal
statements from collapsing the theory.

**Definition 3.2 (Truth modalities).** Fix a multiverse $M$ and a statement
$s$.

- $s$ is **multiverse-true**, $\mathrm{MT}(s)$, if $\forall u,\ u \models
  s$.
- $s$ is **multiverse-false**, $\mathrm{MF}(s)$, if $\forall u,\ u \not\models
  s$.
- $s$ is **possibly true**, $\mathrm{PT}(s)$, if $\exists u,\ u \models s$.
- $s$ is **independent**, $\mathrm{Ind}(s)$, if $(\exists u,\ u \models s)
  \wedge (\exists u,\ u \not\models s)$.
- $s$ is **undetermined**, $\mathrm{Und}(s)$, if $\neg \mathrm{MT}(s)
  \wedge \neg \mathrm{MF}(s)$.

These are the exact analogues of the modal operators $\Box$ (necessity) and
$\Diamond$ (possibility) for the *total* accessibility relation on
universes: $\mathrm{MT}(s)$ is $\Box s$ and $\mathrm{PT}(s)$ is $\Diamond s$.

We record the elementary relationships.

**Proposition 3.3.** If $\mathrm{MT}(s)$ then $\mathrm{PT}(s)$.

*Proof.* By nonemptiness there is a universe $u$; since $s$ holds in every
universe, $u \models s$, witnessing possibility. $\square$

**Proposition 3.4.** No statement is both multiverse-true and
multiverse-false.

*Proof.* If both held, take any universe $u$ (nonemptiness); then $u
\models s$ and $u \not\models s$, a contradiction. $\square$

**Proposition 3.5.** If $\mathrm{Ind}(s)$ then $\neg \mathrm{MT}(s)$ and
$\neg \mathrm{MF}(s)$.

*Proof.* Independence gives a universe $v$ with $v \not\models s$, refuting
multiverse-truth, and a universe $u$ with $u \models s$, refuting
multiverse-falsity. $\square$

The main structural theorem strengthens Proposition 3.5 to an equivalence.

**Theorem 3.6 (Independence = undeterminedness).** For every statement $s$,
$$\mathrm{Ind}(s) \iff \mathrm{Und}(s).$$

*Proof.* ($\Rightarrow$) Immediate from Proposition 3.5.

($\Leftarrow$) Assume $\mathrm{Und}(s)$, i.e. $\neg \mathrm{MT}(s)$ and
$\neg \mathrm{MF}(s)$. From $\neg \mathrm{MF}(s)$ we have $\neg\, \forall u,\
u \not\models s$; classically this yields some $u$ with $u \models s$. From
$\neg \mathrm{MT}(s)$ we have $\neg\, \forall u,\ u \models s$; classically
this yields some $v$ with $v \not\models s$. Together these give
$\mathrm{Ind}(s)$. $\square$

Theorem 3.6 is the formal counterpart of the slogan that, for a genuinely
independent statement, "the question of its truth is meaningless without
first specifying a universe": to be independent *is* to lack a
multiverse-wide truth value.

We also record closure and relativization facts used later.

**Proposition 3.7 (Conjunction).** If $\mathrm{MT}(s)$ and $\mathrm{MT}(t)$
then $s \wedge t$ holds in every universe.

**Definition 3.8 (Relative truth).** For a predicate $P$ on universes, $s$
is *multiverse-true on $P$*, $\mathrm{MT}_P(s)$, if $\forall u,\ P(u) \to u
\models s$.

**Proposition 3.9 (Monotonicity).** If $Q(u) \to P(u)$ for all $u$ and
$\mathrm{MT}_P(s)$, then $\mathrm{MT}_Q(s)$. Moreover $\mathrm{MT}(s)
\iff \mathrm{MT}_{\top}(s)$, where $\top$ is the always-true predicate.

## 4. A concrete three-universe multiverse

To exhibit the framework in action we instantiate it on an explicit finite
collection of three universes, chosen to mirror the classical independence
phenomena.

**Definition 4.1 (The concrete multiverse).** Let $\mathrm{Universe} = \{L,\
\mathrm{cohen},\ \mathrm{measurable}\}$ and $\mathrm{Statement} = \{\mathrm{ZFC},\
\mathrm{CH},\ \mathrm{VeqL},\ \mathrm{LargeCardinal}\}$, with the truth
relation given by the following table (T = holds, F = fails):

| Universe / Statement | ZFC | CH | V=L | LargeCardinal |
|---|---|---|---|---|
| $L$ | T | T | T | F |
| cohen | T | F | F | F |
| measurable | T | T | F | T |

The choices are faithful to the mathematics: $L$ is the constructible
universe (V=L and CH hold, no large cardinals); the Cohen extension adds
generic reals to violate CH; the measurable-cardinal universe has a large
cardinal (forcing V≠L, since large cardinals cannot exist in $L$) while CH
holds. Every universe satisfies ZFC.

Reading off the table yields the following, each verifiable by finite case
analysis.

**Theorem 4.2 (ZFC is multiverse-true).** $\mathrm{MT}(\mathrm{ZFC})$.

**Theorem 4.3 (CH is independent).** $\mathrm{Ind}(\mathrm{CH})$: CH holds in
$L$ and in the measurable universe, and fails in the Cohen extension.

**Corollary 4.4 (No true CH).** $\mathrm{Und}(\mathrm{CH})$; equivalently,
$\neg \mathrm{MT}(\mathrm{CH})$ and $\neg \mathrm{MF}(\mathrm{CH})$. By
Theorem 3.6 this is immediate from Theorem 4.3.

**Theorem 4.5 (V=L and large cardinals are independent).**
$\mathrm{Ind}(\mathrm{VeqL})$ (true in $L$, false in the Cohen and
measurable universes) and $\mathrm{Ind}(\mathrm{LargeCardinal})$ (false in
$L$ and the Cohen extension, true in the measurable universe).

**Theorem 4.6 (ZFC is determined).** In contrast to CH, ZFC is *not*
undetermined: it is multiverse-true.

**Theorem 4.7 (Incompatibility).** No single universe satisfies both V=L and
LargeCardinal; i.e. $\forall u,\ \neg(u \models \mathrm{VeqL} \wedge u
\models \mathrm{LargeCardinal})$.

*Proof.* Case analysis: in $L$, LargeCardinal fails; in the Cohen and
measurable universes, V=L fails. $\square$

These finite verifications ground the abstract theory: they demonstrate an
actual multiverse in which the equivalence of Theorem 3.6 has bite.

## 5. Closure under forcing

The independence in Section 4 is not tied to the particular three universes;
it is a structural consequence of forcing. We abstract the relevant
property.

**Definition 5.1 (Forcing closure).** A statement $s$ is *forcing-closed* in
$M$, written $\mathrm{FC}(s)$, if every universe admits a forcing extension
that flips the truth value of $s$: for each universe $u$ there is a universe
$u'$ (the extension) with $u' \models s \iff u \not\models s$. Concretely, a
universe where $s$ holds has an extension where $s$ fails, and vice versa.

**Theorem 5.2 (Forcing closure implies undeterminedness).** If
$\mathrm{FC}(s)$ then $\mathrm{Und}(s)$; equivalently, by Theorem 3.6,
$\mathrm{Ind}(s)$.

*Proof.* Take any universe $u$ (nonemptiness). If $u \models s$, its
flipping extension refutes $\mathrm{MT}$... more carefully: pick $u$. Its
extension $u'$ has the opposite truth value. Whichever value $u$ assigns to
$s$, the pair $\{u, u'\}$ contains one universe where $s$ holds and one
where it fails, so $s$ is neither multiverse-true nor multiverse-false.
$\square$

**Corollary 5.3.** CH is forcing-closed (forcing can add generic reals to
violate CH and can collapse cardinals to restore it), hence undetermined —
independently of the particular universes chosen. This is the exact sense in
which "there is no true CH."

**Remark 5.4.** ZFC is *not* forcing-closed: forcing extensions of models of
ZFC are again models of ZFC, so no extension flips ZFC's truth value. This
structural difference explains why ZFC retains a multiverse-wide truth value
while CH cannot.

## 6. A tropical bridge

We now connect the logic of multiverse quantification to tropical algebra.

**Definition 6.1 (Tropical semiring).** The *tropical (min-plus) semiring*
is $\mathbb{T} = (\mathbb{N} \cup \{+\infty\},\ \oplus,\ \odot)$ with
tropical addition $a \oplus b = \min(a,b)$ (additive identity $\mathbf{0}_\mathbb{T}
= +\infty$) and tropical multiplication $a \odot b = a + b$ (multiplicative
identity $\mathbf{1}_\mathbb{T} = 0$).

**Definition 6.2 (Boolean semiring).** The *Boolean semiring* is
$\mathbb{B} = (\{ \mathrm{false}, \mathrm{true}\},\ \vee,\ \wedge)$ with
additive identity $\mathrm{false}$ and multiplicative identity
$\mathrm{true}$.

**Definition 6.3 (Encoding).** Define $\beta : \mathbb{B} \to \mathbb{T}$ by
sending each Boolean value to the corresponding tropical unit:
$$\beta(\mathrm{true}) = \mathbf{1}_\mathbb{T} = 0, \qquad
\beta(\mathrm{false}) = \mathbf{0}_\mathbb{T} = +\infty.$$

The encoding is forced by requiring $\beta$ to be a semiring homomorphism: it
must send the Boolean multiplicative unit $\mathrm{true}$ to the tropical
multiplicative unit $\mathbf{1}_\mathbb{T} = 0$, and the Boolean additive
unit $\mathrm{false}$ to the tropical additive unit $\mathbf{0}_\mathbb{T} =
+\infty$. Intuitively $\beta$ assigns each universe a *cost*: a statement
that holds costs $0$ (achievable), one that fails costs $+\infty$
(unreachable).

**Theorem 6.4 (Homomorphism).** With the encoding $\beta$, the following
hold for all Boolean values $a, b$:

- $\beta(a \vee b) = \beta(a) \oplus \beta(b) = \min(\beta(a), \beta(b))$;
- $\beta(a \wedge b) = \beta(a) \odot \beta(b) = \beta(a) + \beta(b)$.

Thus $\beta$ is a semiring homomorphism from $\mathbb{B}$ to $\mathbb{T}$.

*Proof.* Both identities are verified on the four cases of $(a,b)$. For OR,
e.g. $\beta(\mathrm{true} \vee \mathrm{false}) = \beta(\mathrm{true}) = 0$
and $\min(0, +\infty) = 0$; the remaining OR cases give $\min(0,0)=0$ and
$\min(+\infty,+\infty)=+\infty$. For AND, $\beta(\mathrm{true} \wedge
\mathrm{true}) = 0 = 0 + 0$, while $\beta(\mathrm{true} \wedge \mathrm{false})
= +\infty = 0 + \infty$. $\square$

Because possibility is a disjunction over all universes and multiverse-truth
is a conjunction over all universes, applying $\beta$ termwise and using
Theorem 6.4 gives the big-operator correspondence.

**Theorem 6.5 (Possibility is a tropical sum).** For a finite multiverse,
write $\Sigma_s = \bigoplus_{u} \beta(u \models s) = \min_u \beta(u \models
s)$. Then $s$ is possibly true iff $\Sigma_s = 0$ (equivalently, some encoded
term equals $0$, i.e. some universe satisfies $s$).

**Theorem 6.6 (Necessity is a tropical product).** For a finite multiverse,
write $\Pi_s = \bigodot_u \beta(u \models s) = \sum_u \beta(u \models s)$.
Then $s$ is multiverse-true iff $\Pi_s = 0$ (equivalently, every encoded term
equals $0$).

**Corollary 6.7 (Tropical signature of independence).** A statement $s$ over
a finite multiverse is independent iff its tropical sum is $\Sigma_s = 0$
(possible) while its tropical product is $\Pi_s = +\infty$ (not necessary).
In particular CH has the signature
$$\Sigma_{\mathrm{CH}} = 0 \quad\text{and}\quad \Pi_{\mathrm{CH}} = +\infty,$$
whereas ZFC has $\Sigma_{\mathrm{ZFC}} = 0$ and $\Pi_{\mathrm{ZFC}} = 0$
(possible and necessary).

This is more than a curiosity. It recasts a philosophical question about the
absoluteness of set-theoretic truth into a finite arithmetic computation in
the min-plus semiring, and it embeds multiverse quantification into the vast
toolbox of tropical mathematics — shortest paths, Viterbi decoding, and
scheduling all speak the same $\oplus = \min$, $\odot = +$ dialect.

## 7. Algorithms

We summarize the computational content.

**Algorithm A (Modality classifier).** Given a finite truth table, compute
for each statement whether it is multiverse-true, multiverse-false, possibly
true, independent, or undetermined, by scanning its column. Complexity
$O(|\mathrm{Universe}|)$ per statement.

**Algorithm B (Tropical signature).** For each statement compute the
tropical sum $\min_u \beta(\cdot)$ and tropical product $\sum_u \beta(\cdot)$
and classify by Corollary 6.7. Complexity $O(|\mathrm{Universe}|)$ per
statement.

**Algorithm C (Forcing-closure witness search).** Given a forcing-neighbor
relation on universes, verify $\mathrm{FC}(s)$ by checking that each universe
has a neighbor with the opposite truth value; on success conclude
undeterminedness by Theorem 5.2. Complexity $O(|\mathrm{Universe}| \cdot
d)$ where $d$ bounds the neighbor degree.

## 8. Applications and discussion

The framework clarifies the logical status of independence in a way that is
uniform across the many statements known to be independent of ZFC (CH,
V=L, large-cardinal existence, Suslin's hypothesis, and so on): each is,
provably, undetermined across the multiverse.

The tropical bridge suggests quantitative refinements. Replacing
$\mathbb{N}\cup\{+\infty\}$ with $\mathbb{R}\cup\{+\infty\}$ and letting
per-universe values be forcing "costs" or measure-theoretic weights turns
the tropical sum into the computation of a *cheapest witnessing universe* — a
shortest-path / Viterbi reading of possibility. This connects the philosophy
of the infinite to concrete optimization.

The modal reading ($\mathrm{MT} = \Box$, $\mathrm{PT} = \Diamond$ for the
total accessibility relation) invites a Kripke-frame generalization in which
accessibility is nontrivial and the big-operator correspondence becomes a
statement about tropical matrix powers: reachability is tropical matrix
closure.

## 9. Future work

Natural extensions include: (i) real-coefficient degrees of truth via
$\mathbb{R}\cup\{+\infty\}$ with forcing costs; (ii) a general modal/Kripke
bridge recovering the tropical correspondence over accessible sets; (iii)
replacing the abstract truth relation by genuine first-order satisfaction in
real structures and connecting independence to relative-consistency and
forcing results; and (iv) Boolean-valued models, generalizing the
Boolean-to-tropical encoding to a homomorphism out of complete Boolean
algebras.

## 10. Conclusion

We have given a compact, self-contained framework for the set-theoretic
multiverse and proved its central structural theorem: independence is
equivalent to undeterminedness. We instantiated it on three classical
universes, isolated forcing closure as a sufficient condition for
undeterminedness, and uncovered a homomorphism translating multiverse
quantification into tropical arithmetic. The upshot is a precise sense in
which there is "no true CH," together with a computable, tropical fingerprint
for independence.

## References

- G. Cantor, *Contributions to the Founding of the Theory of Transfinite
  Numbers*, 1895.
- K. Gödel, *The Consistency of the Continuum Hypothesis*, 1940.
- P. J. Cohen, *The Independence of the Continuum Hypothesis*, 1963.
- J. D. Hamkins, *The set-theoretic multiverse*, Review of Symbolic Logic,
  2012.
