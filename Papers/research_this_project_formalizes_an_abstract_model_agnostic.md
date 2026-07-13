# A Tropical Calculus for the Set-Theoretic Multiverse

## Abstract

We develop an abstract, model-agnostic formalization of Hamkins' set-theoretic
multiverse and establish a cross-domain bridge connecting quantification over
universes to tropical (min-plus) algebra. On the logical side, we axiomatize a
multiverse as a nonempty collection of universes together with a truth relation on
a type of statements, and we define the modes of multiverse truth: *multiverse-true*,
*multiverse-false*, *possibly true*, *independent*, and *undetermined*. Our first
structural result is that a statement is independent if and only if it is
undetermined — it has no multiverse-wide truth value. We show that closure under
forcing alone forces a statement to be undetermined, giving a precise formal sense
to the slogan "there is no true Continuum Hypothesis." On the algebraic side, we
prove that the map sending Boolean truth values into the tropical semiring
($\mathrm{true}\mapsto 1$, $\mathrm{false}\mapsto 0$) is a semiring homomorphism
from the Boolean semiring to the min-plus semiring, whence existential
quantification over a finite multiverse is a tropical sum and universal
quantification is a tropical product. Independence of a statement acquires the
tropical signature "sum $=1$ and product $\neq 1$." Finally we lift the bridge to a
quantitative shortest-path calculus in which each universe carries a real cost: the
tropical sum computes the cheapest witnessing universe (attained at an explicit
cost-minimal witness) and the tropical product computes the aggregate cost of a
multiverse-truth, with the Boolean theory recovered as the zero-cost slice. A
concrete three-universe multiverse ($L$, a Cohen extension, a measurable-cardinal
universe) illustrates every result on the statements ZFC, CH, $V=L$, and the
existence of a large cardinal.

**Keywords.** set-theoretic multiverse, Continuum Hypothesis, forcing, independence,
tropical semiring, min-plus algebra, modal logic, shortest path.

## 1. Introduction

Cantor's Continuum Hypothesis (CH) asserts that there is no cardinality strictly
between that of the natural numbers and that of the real line. The combined work of
Gödel (consistency of CH with ZFC, via the constructible universe $L$) and Cohen
(consistency of $\neg$CH, via forcing) established that CH is *independent* of the
standard axioms: neither it nor its negation is provable. This is the paradigmatic
example of a mathematical statement without a truth value in the usual absolute
sense.

Hamkins' *set-theoretic multiverse* offers a philosophical stance toward such
statements: rather than a single privileged universe of sets, there is a plurality
of universes, and independent statements are simply true in some and false in
others. A defining structural feature is closure under forcing — every universe has
forcing extensions, and forcing can flip the truth value of an independent
statement.

This paper has two goals. The first is to make the multiverse picture precise
enough to *prove* its central slogans while remaining model-agnostic: we do not
build models of ZFC, but axiomatize exactly the data the multiverse view uses. The
second, and the technical novelty, is a bridge to **tropical algebra**. Existential
and universal quantification over a finite family of universes are, respectively, an
iterated logical OR and AND. Under a simple homomorphism into the min-plus semiring,
these become a tropical sum and a tropical product, so that possibility and
necessity are read off two big operators, and independence has a clean tropical
signature. We then promote the bridge to a *quantitative* calculus: with real costs
on universes, the same operators solve shortest-path and total-cost optimization
problems, recovering the Boolean theory at zero cost.

Throughout, all results are stated for a general abstract multiverse and instantiated
on an explicit three-universe example.

## 2. The abstract multiverse

### 2.1 Definition

**Definition 2.1 (Multiverse).** A *multiverse* $M$ consists of:
a type $\mathcal{U}$ of *universes*; a type $\mathcal{S}$ of *statements*; a truth
relation $\mathrm{holds} : \mathcal{U} \to \mathcal{S} \to \mathrm{Prop}$, where
$\mathrm{holds}(u,s)$ means "$s$ is true in universe $u$"; together with a proof
that $\mathcal{U}$ is nonempty.

We write $u \models s$ for $\mathrm{holds}(u,s)$. No further structure is assumed;
in particular universes are opaque tokens and statements need not be closed under
logical connectives. This is deliberate: the results below depend only on the
truth relation.

### 2.2 Modes of multiverse truth

**Definition 2.2.** For a statement $s$ of a multiverse $M$:

- $s$ is **multiverse-true**, $\mathrm{MTrue}(s)$, if $\forall u,\; u \models s$;
- $s$ is **multiverse-false**, $\mathrm{MFalse}(s)$, if $\forall u,\; u \not\models s$;
- $s$ is **possibly true**, $\mathrm{Poss}(s)$, if $\exists u,\; u \models s$;
- $s$ is **independent**, $\mathrm{Indep}(s)$, if
  $(\exists u,\; u \models s) \wedge (\exists u,\; u \not\models s)$;
- $s$ is **undetermined**, $\mathrm{Undet}(s)$, if
  $\neg\mathrm{MTrue}(s) \wedge \neg\mathrm{MFalse}(s)$.

### 2.3 Basic structural facts

**Proposition 2.3.** Let $s$ be a statement of a multiverse $M$.

1. If $\mathrm{MTrue}(s)$ then $\mathrm{Poss}(s)$ (using nonemptiness).
2. If $\mathrm{Indep}(s)$ then $\neg\mathrm{MTrue}(s)$ and $\neg\mathrm{MFalse}(s)$.
3. No statement is both multiverse-true and multiverse-false.

*Proof.* (1) Choose any universe $u$ (nonemptiness); if $s$ holds everywhere it
holds at $u$. (2) An independent statement has a failing witness $v$ (so it is not
multiverse-true) and a holding witness $u$ (so it is not multiverse-false). (3) If
$s$ held everywhere and nowhere, then at any universe $u$ we would have both
$u\models s$ and $u\not\models s$, a contradiction. $\square$

The central structural theorem identifies independence with the absence of a
truth value.

**Theorem 2.4 (Independence = undeterminedness).** For every statement $s$,
$$
\mathrm{Indep}(s) \iff \mathrm{Undet}(s).
$$

*Proof.* ($\Rightarrow$) Suppose $s$ holds at $u$ and fails at $v$. Then $s$ is not
multiverse-true (it fails at $v$) and not multiverse-false (it holds at $u$), i.e.
$\mathrm{Undet}(s)$. ($\Leftarrow$) Suppose $\neg\mathrm{MTrue}(s)$ and
$\neg\mathrm{MFalse}(s)$. From $\neg\mathrm{MFalse}(s)$, i.e.
$\neg\forall u,\; u\not\models s$, classical logic yields a universe where $s$
holds; from $\neg\mathrm{MTrue}(s)$ it yields a universe where $s$ fails. Hence
$\mathrm{Indep}(s)$. $\square$

Theorem 2.4 is the formal counterpart of the slogan: *for a genuinely independent
statement, the question of its truth is meaningless without first specifying a
universe.*

**Remark 2.5 (relativization).** One may relativize truth to a sub-multiverse cut
out by a predicate $P$ on universes: $\mathrm{MTrueOn}(P, s) := \forall u,\, P(u)
\to u\models s$. This is monotone (truth on a larger sub-collection implies truth
on a smaller one), and $\mathrm{MTrue}(s)$ is exactly truth on the full
sub-collection $P \equiv \top$.

## 3. A concrete multiverse

We instantiate Definition 2.1 on three named universes chosen to mirror the
standard independence phenomena.

**Definition 3.1.** Let $\mathcal{U} = \{L,\; \mathrm{Cohen},\; \mathrm{Meas}\}$ and
$\mathcal{S} = \{\mathrm{ZFC},\; \mathrm{CH},\; V{=}L,\; \mathrm{LC}\}$, where $\mathrm{LC}$
abbreviates "there exists a large cardinal." Truth is given by the table

| universe \ statement | ZFC | CH | $V{=}L$ | LC |
|---|---|---|---|---|
| $L$ (constructible universe) | T | T | T | F |
| Cohen (forcing extension) | T | F | F | F |
| Meas (measurable-cardinal universe) | T | T | F | T |

with $\mathrm{holds}(u,s)$ defined to be "the table entry is T."

The table encodes standard facts: $L$ satisfies $V=L$ and CH but carries no large
cardinals; a Cohen extension makes CH fail; an inner model with a measurable
cardinal satisfies CH but not $V=L$.

**Theorem 3.2 (results on the concrete multiverse).**

1. **ZFC is multiverse-true.**
2. **CH is independent**, hence undetermined: there is *no true CH*. Explicitly,
   $\neg\mathrm{MTrue}(\mathrm{CH})$ and $\neg\mathrm{MFalse}(\mathrm{CH})$, while
   $\mathrm{Poss}(\mathrm{CH})$ holds (witnessed by $L$).
3. **$V=L$ is independent** and **the existence of a large cardinal is independent.**
4. **ZFC is determined** (not undetermined), distinguishing settled from open
   statements.
5. **$V=L$ and large cardinals are incompatible in every single universe**: no $u$
   satisfies both $V=L$ and LC.

*Proof.* Each item is a finite check against the table. (1) Every column-ZFC entry
is T. (2) CH is T at $L$ and F at Cohen, giving both witnesses; independence and
undeterminedness follow from Theorem 2.4, and possibility from the $L$-witness. (3)
$V=L$ is T at $L$, F at Cohen; LC is T at Meas, F at $L$. (4) ZFC is multiverse-true
by (1), so by Proposition 2.3(1)–(2) it is not undetermined. (5) $V=L$ and LC are
never simultaneously T in any row. $\square$

## 4. Forcing closure

Hamkins' multiverse is closed under forcing: from any universe one can force to an
extension that flips the truth value of an independent statement. We localize this
to a single statement.

**Definition 4.1 (forcing closure).** A statement $s$ is **forcing-closed**,
$\mathrm{FC}(s)$, if
$$
\forall u,\ \exists v,\ \big(v \models s \iff \neg(u \models s)\big).
$$
That is, from every universe $u$ there is a universe $v$ (its forcing extension) in
which $s$ has the opposite truth value.

**Theorem 4.2 (forcing closure entails independence).** If $\mathrm{FC}(s)$ then
$\mathrm{Indep}(s)$.

*Proof.* Take any universe $u_0$ (nonemptiness) and its flip $v$. If $u_0 \models s$
then $s$ holds at $u_0$ and, since $v$ disagrees, fails at $v$. If $u_0 \not\models
s$ then $s$ holds at $v$ and fails at $u_0$. Either way $s$ has a holding and a
failing witness. $\square$

**Theorem 4.3 (forcing closure kills multiverse truth).** If $\mathrm{FC}(s)$ then
$\mathrm{Undet}(s)$; in particular $\neg\mathrm{MTrue}(s)$.

*Proof.* Immediate from Theorems 4.2 and 2.4. $\square$

Theorem 4.3 is the precise formal content of "there is no true CH": closure under
forcing *alone* precludes any multiverse-wide answer, independently of any specific
model.

**Theorem 4.4 (concrete forcing facts).** In the concrete multiverse of Section 3,
CH is forcing-closed while ZFC is not.

*Proof.* For CH: from $L$ (CH true) and from Meas (CH true), the Cohen extension
(CH false) is the required flip; from Cohen (CH false), $L$ (CH true) is the flip.
Hence $\mathrm{FC}(\mathrm{CH})$, and Theorem 4.3 re-derives the undeterminedness of
CH. For ZFC: were it forcing-closed, from $L$ (ZFC true) there would be a universe
with ZFC false; but ZFC is true in all three universes, a contradiction. $\square$

## 5. The tropical bridge

We now connect quantification over a *finite* multiverse to the tropical semiring.

### 5.1 The tropical (min-plus) semiring

**Definition 5.1.** The *tropical semiring* on $\overline{\mathbb{N}} =
\mathbb{N}\cup\{\infty\}$ (and analogously on $\overline{\mathbb{R}}$) has underlying
carrier the tropicalized values $\mathrm{trop}(x)$, addition $\oplus$ given by
$\min$, and multiplication $\odot$ given by ordinary $+$. Its additive unit is
$0_{\mathrm{trop}} = \mathrm{trop}(\infty)$ and its multiplicative unit is
$1_{\mathrm{trop}} = \mathrm{trop}(0)$. We write $\bigoplus$ for tropical sums
(iterated $\min$) and $\bigodot$ for tropical products (iterated $+$).

### 5.2 The Boolean-to-tropical homomorphism

**Definition 5.2.** Define $\beta : \mathrm{Bool} \to \mathrm{Trop}(\overline{\mathbb{N}})$
by
$$
\beta(\mathrm{true}) = 1_{\mathrm{trop}} = \mathrm{trop}(0), \qquad
\beta(\mathrm{false}) = 0_{\mathrm{trop}} = \mathrm{trop}(\infty).
$$

**Theorem 5.3 ($\beta$ is a semiring homomorphism).** For all $a,b \in \mathrm{Bool}$,
$$
\beta(a \vee b) = \beta(a) \oplus \beta(b) = \min(\beta a, \beta b),
\qquad
\beta(a \wedge b) = \beta(a) \odot \beta(b) = \beta a + \beta b.
$$
Moreover $1_{\mathrm{trop}} \le \beta(b)$ for every $b$, and $\beta(b) =
1_{\mathrm{trop}} \iff b = \mathrm{true}$.

*Proof.* All identities are verified by exhausting the four cases of $(a,b)$; the
order and unit facts by the two cases of $b$. $\square$

Disjunction maps to tropical addition and conjunction to tropical multiplication.
Since existential quantification over a finite type is an iterated disjunction and
universal quantification an iterated conjunction, $\beta$ transports quantifiers to
big operators.

### 5.3 Quantifiers as big operators

**Theorem 5.4 (quantifier–big-operator correspondence).** Let $\iota$ be a finite
type and $p : \iota \to \mathrm{Prop}$ decidable. Then
$$
\Big(\bigodot_{i} \beta(\llbracket p\, i\rrbracket)\Big) = 1_{\mathrm{trop}}
\iff \forall i,\ p\,i,
\qquad
\Big(\bigoplus_{i} \beta(\llbracket p\, i\rrbracket)\Big) = 1_{\mathrm{trop}}
\iff \exists i,\ p\,i,
$$
where $\llbracket\cdot\rrbracket$ denotes the Boolean decision of a proposition.

*Proof.* For the product: since each factor satisfies $1_{\mathrm{trop}} \le
\beta(\cdot)$, a tropical product equals the unit iff every factor equals the unit
(the min-plus analogue of "a product of terms $\ge 1$ equals $1$ iff each is $1$"),
and $\beta(\cdot) = 1_{\mathrm{trop}}$ iff the corresponding proposition holds; hence
the product equals $1_{\mathrm{trop}}$ iff all $p\,i$ hold. For the sum: untropicalize
via $\bigoplus \mapsto \inf$ over $\overline{\mathbb{N}}$. The infimum of the values
(each $0$ where $p$ holds, $\infty$ where it fails) equals $0$ iff at least one value
is $0$, i.e. iff some $p\,i$ holds; and $\bigoplus \cdot = 1_{\mathrm{trop}}$
corresponds to this infimum being $0$. $\square$

Reading this through Sections 2–3 gives the semantic statement.

**Corollary 5.5 (multiverse quantifiers are tropical operations).** For a finite
multiverse $M$ and a statement $s$ with decidable per-universe truth,
$$
\mathrm{MTrue}(s) \iff \Big(\bigodot_{u} \beta(\llbracket u\models s\rrbracket)\Big)
= 1_{\mathrm{trop}},
\qquad
\mathrm{Poss}(s) \iff \Big(\bigoplus_{u} \beta(\llbracket u\models s\rrbracket)\Big)
= 1_{\mathrm{trop}}.
$$

*Multiverse-truth is the tropical product of truth values; possibility is the
tropical sum.*

### 5.4 The tropical signature of independence

**Theorem 5.6 (tropical signature of CH).** In the concrete multiverse,
$$
\bigoplus_{u} \beta(\llbracket u\models \mathrm{CH}\rrbracket) = 1_{\mathrm{trop}}
\qquad\text{and}\qquad
\bigodot_{u} \beta(\llbracket u\models \mathrm{CH}\rrbracket) \neq 1_{\mathrm{trop}}.
$$
By contrast, ZFC has both its tropical sum and tropical product equal to
$1_{\mathrm{trop}}$.

*Proof.* CH holds at $L$, so the tropical sum is $1_{\mathrm{trop}}$ by
Theorem 5.4; CH fails at Cohen, so not all factors are the unit and the tropical
product is not $1_{\mathrm{trop}}$. ZFC holds at all three universes, making both
operators the unit. $\square$

Thus independence has the tropical signature $\Sigma = 1 \wedge \Pi \neq 1$ (sum is
the unit, product is not); multiverse-truth is $\Sigma = 1 \wedge \Pi = 1$; and
multiverse-falsehood is $\Sigma \neq 1$.

## 6. The weighted (quantitative) calculus

We now attach a real cost to each universe and turn the two big operators into
optimization problems over the min-plus semiring on $\overline{\mathbb{R}}$. Think
of the cost of a universe as its forcing complexity, the length of a forcing
iteration, or a measure-theoretic weight.

**Definition 6.1 (weighted value).** Let $\iota$ be a type, $p : \iota \to
\mathrm{Prop}$ decidable, and $c : \iota \to \mathbb{R}$ a cost. The *weighted cost*
of $i$ is
$$
\mathrm{wcost}(i) = \begin{cases} c(i) & \text{if } p\,i, \\ \infty & \text{otherwise,}\end{cases}
\in \overline{\mathbb{R}},
$$
and its *weighted value* is $\mathrm{wval}(i) = \mathrm{trop}(\mathrm{wcost}(i))$. For
finite $\iota$ define
$$
\mathrm{cheapest}(p,c) = \bigoplus_i \mathrm{wval}(i), \qquad
\mathrm{necessityCost}(p,c) = \bigodot_i \mathrm{wval}(i).
$$

**Proposition 6.2 (untropicalizations).**
$$
\mathrm{untrop}\,\mathrm{cheapest}(p,c) = \inf_{i} \mathrm{wcost}(i),
\qquad
\mathrm{untrop}\,\mathrm{necessityCost}(p,c) = \sum_{i} \mathrm{wcost}(i).
$$

*Proof.* The tropical sum untropicalizes to an infimum of the values and the
tropical product to a sum. $\square$

**Theorem 6.3 (Boolean bridge = zero-cost slice).** With $c \equiv 0$,
$\mathrm{wval}(i) = \beta(\llbracket p\,i\rrbracket)$ for every $i$. Consequently
possibility/necessity reduce to the pure finiteness statements below.

**Theorem 6.4 (possibility = finite cheapest cost).**
$$
\mathrm{untrop}\,\mathrm{cheapest}(p,c) = \infty \iff \forall i,\ \neg p\,i,
$$
equivalently $(\exists i,\ p\,i) \iff \mathrm{untrop}\,\mathrm{cheapest}(p,c) \neq
\infty$.

*Proof.* The infimum of the $\mathrm{wcost}$ values is $\infty$ iff every value is
$\infty$, i.e. iff $p$ holds nowhere. $\square$

**Theorem 6.5 (attained cheapest witness).** If $\exists i,\ p\,i$, then there is a
universe $i_0$ with $p\,i_0$,
$$
\mathrm{untrop}\,\mathrm{cheapest}(p,c) = c(i_0),
\qquad\text{and}\qquad
\forall j,\ p\,j \Rightarrow c(i_0) \le c(j).
$$
That is, the cheapest cost is realized at an actual, cost-minimal witnessing
universe — the shortest-path/Viterbi reading of possibility.

*Proof.* Restrict to the nonempty finite set $S$ of witnesses. An $\mathrm{argmin}$
of $c$ over $S$ exists; call it $i_0$. Non-witnesses contribute $\infty$ and do not
lower the infimum, so $\inf_i \mathrm{wcost}(i) = \min_{j \in S} c(j) = c(i_0)$, and
$i_0$ is minimal among witnesses by construction. $\square$

**Theorem 6.6 (monotonicity).** If $c(i) \le c'(i)$ for all $i$, then
$\mathrm{untrop}\,\mathrm{cheapest}(p,c) \le \mathrm{untrop}\,\mathrm{cheapest}(p,c')$.

*Proof.* The infimum is monotone in each pointwise-smaller weighted cost; where $p$
fails both sides are $\infty$. $\square$

**Theorem 6.7 (necessity = finite aggregate; total cost).**
$(\forall i,\ p\,i) \iff \mathrm{untrop}\,\mathrm{necessityCost}(p,c) \neq \infty$, and
when $p$ holds everywhere,
$$
\mathrm{untrop}\,\mathrm{necessityCost}(p,c) = \sum_i c(i).
$$

*Proof.* A finite sum in $\overline{\mathbb{R}}$ is $\infty$ iff some summand is
$\infty$, i.e. iff some $\mathrm{wcost}(i) = \infty$, i.e. iff $p$ fails somewhere.
When $p$ holds everywhere every $\mathrm{wcost}(i) = c(i)$, so the sum is the plain
$\sum_i c(i)$. $\square$

**Example 6.8 (costed CH).** Take universes $\{L,\ \mathrm{Cohen},\ \mathrm{Meas}\}$
with CH true at $L$ and Meas and false at Cohen, and costs $c(L)=0$,
$c(\mathrm{Cohen})=1$, $c(\mathrm{Meas})=5$. Then CH is possible, its cheapest
witnessing cost is $0$ (attained at the zero-cost ground model $L$), yet CH is not
multiverse-true because it fails at the Cohen extension. Possibility here has a
magnitude — the price $0$ of its cheapest witness — rather than a bare truth value.

## 7. Algorithms

The tropical bridge is constructive on finite multiverses. We record the natural
algorithms; complexities are for $n = |\mathcal{U}|$ universes.

- **Boolean signature.** Compute $\Sigma = \bigoplus_u \beta(\llbracket u\models
  s\rrbracket)$ and $\Pi = \bigodot_u \beta(\cdot)$ in $O(n)$ time; classify $s$ as
  multiverse-true ($\Sigma = \Pi = 1$), independent ($\Sigma = 1,\ \Pi \neq 1$), or
  multiverse-false ($\Sigma \neq 1$).
- **Cheapest witness.** Compute $\min$ over witnessing universes with an
  $\mathrm{argmin}$ scan, $O(n)$ time, returning the optimal witness and its cost;
  $\infty$ signals impossibility.
- **Independence price.** For a statement $s$ paired with its negation, compute the
  cheapest witnessing cost of each; independence corresponds to both being finite,
  and their maximum is a scalar invariant.

## 8. Applications and connections

**Modal logic.** $\mathrm{MTrue}$ and $\mathrm{Poss}$ are exactly the modal
operators $\Box$ and $\Diamond$ for the total accessibility relation on universes.
Under $\beta$, $\Box$ and $\Diamond$ become tropical matrix–vector products; over a
general Kripke frame with edge costs, iterated modalities become min-plus matrix
powers and "eventually accessible" becomes the tropical matrix star (Kleene star) —
the same computation as all-pairs shortest paths.

**Optimization.** The cheapest-witness operator is a shortest-path / Viterbi
functional; the monotonicity principle is the standard comparison principle for
shortest paths (cheaper edges, cheaper path). The aggregate-cost operator is a
total-budget sum.

**Foundations.** Independence is upgraded from a bare impossibility (no proof of $s$
or $\neg s$) to a *quantity*: the cheapest world realizing $s$ against the cheapest
world realizing $\neg s$.

## 9. Discussion

The development is deliberately model-agnostic: we axiomatize only the truth
relation, so the logical theorems (Sections 2, 4) are robust to any interpretation
of "universe," and the tropical theorems (Sections 5, 6) require only finiteness and
decidability. The results are non-vacuous: the concrete multiverse exhibits genuine
independence, the forcing theorem derives undeterminedness from closure alone, and
the weighted calculus produces explicit optimal witnesses and minimality
inequalities rather than definitional trivialities. The one structural subtlety is
that $\infty$-costs (statement failing) must be excluded from the argmin, which is
why the attainment theorem takes a possibility hypothesis: without it the infimum is
$\infty$ and no real witness exists — precisely the finiteness criterion of
Theorem 6.4.

## 10. Future directions

**Conjecture 1 — Independence has a strictly positive optimality gap.** For a
statement independent across a costed multiverse, the cheapest cost of the statement
and the cheapest cost of its negation are both finite, and their maximum is a genuine
numerical invariant — the *independence price* — invariant under cost-preserving
isomorphisms of the multiverse. Independence is not merely the coexistence of a true
and a false universe, but the coexistence of two *finite* min-plus witnesses, so the
phenomenon acquires a scalar magnitude rather than a yes/no answer.

**Conjecture 2 — Modal accessibility is tropical matrix reachability.** Replace the
total accessibility relation by a Kripke frame with edge costs. Then
necessity/possibility over the accessible set are entries of min-plus matrix powers
of the weighted adjacency matrix, and the reachability closure ($\Diamond$ iterated)
equals the tropical matrix star. $\Box$ and $\Diamond$ are min-plus matrix–vector
products, so iterating modalities is iterating a min-plus matrix, making the Kleene
star of tropical linear algebra the exact semantics of "eventually accessible."

**Conjecture 3 — The cheapest-witness map is a valuation.** The assignment sending a
costed statement to its cheapest witnessing cost is a min-plus valuation: the cost of
a disjunction is the minimum of the costs, and the cost of a conjunction is bounded
below by their maximum, with equality characterized by a shared optimal universe. The
Boolean-to-tropical homomorphism laws ($\vee \mapsto \min$, $\wedge \mapsto +$)
survive weighting in a one-sided form, turning the truth functor into a
submodular-style cost functor whose failure of exactness measures how far two
statements are from sharing an optimal witness.

Further natural extensions include real-coefficient degrees of truth (per-universe
forcing costs or measure-theoretic weights); a full Kripke-frame modal bridge to
min-plus matrix closure; genuine ZFC models replacing the abstract truth relation by
satisfaction in first-order structures; Boolean-valued models generalizing $\beta$ to
a homomorphism out of an arbitrary complete Boolean algebra; and larger multiverses
indexed by a finite family of forcing iterations, with the tropical signature of a
statement studied as an invariant of its independence pattern.

## 11. Conclusion

We have given a compact, model-agnostic account of the set-theoretic multiverse in
which independence is provably equivalent to the absence of a multiverse truth value,
and closure under forcing alone forces undeterminedness. We then bridged multiverse
quantification to tropical algebra: possibility is a tropical sum, necessity a
tropical product, and independence has the signature $\Sigma = 1 \wedge \Pi \neq 1$.
Weighting the universes turns these operators into a genuine shortest-path calculus,
with the Boolean theory recovered at zero cost. The bridge places independence
phenomena inside the same min-plus framework used for dynamic programming and
shortest paths, and suggests a quantitative theory of independence organized around
the *price* of a witnessing universe.
