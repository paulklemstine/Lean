# Positive Expected Profit in Gödel's Casino: A Measure-Theoretic Theory of Betting on Undecidable Statements

**Author:** Aristotle
**Date:** 2026-07-09

## Abstract

Gödel's incompleteness theorems guarantee that any sufficiently expressive
axiomatic system harbors statements that can be neither proved nor disproved.
We recast this phenomenon as a game of chance — *Gödel's Casino* — in which a
player bets on the truth value of arithmetic statements, some of which are
independent of the ambient axioms. Fixing a probability measure on a space of
admissible models, each card (statement) acquires a *win-probability*
$p_\varphi \in [0,1]$: the measure of the set of models in which the player's
bet matches the statement's truth value. A correct bet pays $+1$ and an
incorrect bet pays $-1$, so a single card's expected payoff is $2p_\varphi - 1$.
We prove a small, self-contained theory around this payoff functional. A perfect
hedge ($p=\tfrac12$) breaks even; a card is strictly profitable if and only if
its win-probability exceeds $\tfrac12$; a finite deck in which every card is at
least break-even and at least one card is strictly profitable yields strictly
positive total expected profit; and a quantitative *fraction bound* states that
if a fraction $\alpha$ of the deck enjoys a uniform winning margin $\varepsilon$,
the total expected payoff is at least $\alpha \cdot n \cdot 2\varepsilon$ for a
deck of size $n$. As a corollary — the casino's signature *One-Third Theorem* —
any nonempty deck in which every card is at least break-even and at least a third
of the cards are strictly profitable produces strictly positive expected profit,
regardless of the remaining cards. Win-probabilities are shown to be honest
probabilities in $[0,1]$ by realizing them as measures of winning events inside a
genuine probability space. We also correct a subtle over-claim in the original
conjecture: no positive profit lower bound can depend on the winning fraction
$\alpha$ alone, and we make the winning margin an explicit hypothesis.

**Keywords:** incompleteness, undecidability, independence from ZFC, expected
payoff, win-probability, measure on models, arithmetic hierarchy, decision under
uncertainty.

---

## 1. Introduction

The incompleteness theorems of Gödel establish that formal mathematics is
permanently unfinished: there exist statements $\varphi$ such that neither
$\varphi$ nor its negation is provable from the axioms. The Continuum Hypothesis
(CH) is the paradigmatic example among set-theoretic statements — it is
*independent* of the standard axioms, consistent to assume and consistent to
deny. The usual narrative treats such independence as a limitation. We adopt the
opposite stance and ask a quantitative, game-theoretic question: **if you are
forced to bet on the truth of such statements, can you systematically win?**

To make "win" precise we replace the binary and often unanswerable question "is
$\varphi$ true?" with a measure-theoretic one. We posit a probability space
$(\Omega, \mathcal F, \mu)$ whose points $\omega$ are admissible models, each
assigning a definite truth value to every statement. A (possibly randomized)
betting strategy determines, for each statement $\varphi$, a **winning event**
$W_\varphi \subseteq \Omega$: the set of models in which the bet is correct. Its
win-probability is $p_\varphi := \mu(W_\varphi)$. This single number captures
everything the payoff calculus needs.

Our contribution is a compact, fully rigorous theory of when a finite deck of
such cards is profitable in expectation. The results are elementary in their
proofs but conceptually pointed: they show that undecidable cards, when hedged,
are *costless*, and that only a modest reservoir of genuine knowledge is needed
to guarantee profit. We also flag and repair an over-strong claim in the folklore
version of the conjecture.

### 1.1 Contributions

1. A definition of the expected-payoff functional $E(p) = 2p - 1$ on
   win-probabilities and of the total expected payoff of a finite deck.
2. Three foundational results: hedges break even; profitability is equivalent to
   $p > \tfrac12$; a deck of at-least-break-even cards with one strict winner is
   profitable.
3. A quantitative fraction bound relating total profit to the fraction of
   high-margin cards and the size of the deck.
4. The One-Third Theorem, a hypothesis-light corollary matching the concept's
   headline slogan.
5. A measure-theoretic layer certifying win-probabilities as honest elements of
   $[0,1]$, with the winnable ($p=1$) and hedge ($p=\tfrac12$) endpoints
   computed explicitly.
6. A faithfulness analysis correcting the claim that a positive lower bound can
   depend on the winning fraction alone.

---

## 2. Setup and Definitions

Throughout, $\mathbb R$ denotes the reals and $[0,1] = \{x \in \mathbb R : 0 \le
x \le 1\}$.

### 2.1 The probability space of models

**Definition 2.1 (Model space).** A *model space* is a probability space
$(\Omega, \mathcal F, \mu)$ — so $\mu(\Omega) = 1$ — whose points are to be
thought of as admissible mathematical universes. Each $\omega \in \Omega$ assigns
a truth value to every statement under consideration.

**Definition 2.2 (Card, bet, winning event).** A *card* is a statement
$\varphi$. A *strategy* commits, for each card, to a (possibly randomized) bet.
The *winning event* of the card is the set
$$W_\varphi := \{\omega \in \Omega : \text{the bet on } \varphi \text{ agrees
with the truth value of } \varphi \text{ in } \omega\} \in \mathcal F.$$

**Definition 2.3 (Win-probability).** The *win-probability* of a card with
winning event $W \subseteq \Omega$ is the real number
$$p := \mu(W) \in [0,1].$$
(Formally, if $\mu(W)$ is taken in the extended non-negative reals, $p$ is its
real value; Proposition 5.1 confirms $p \in [0,1]$.)

Two canonical values arise:

- A **winnable** card — one whose truth the player can determine — has a winning
  event of full measure, $p = 1$.
- A **hedged** card — one on which the player flips a fair coin — has $p =
  \tfrac12$, since the bet is correct on exactly half the models.

Because coin-flipping is always available, an optimal player attains
$p_\varphi \ge \tfrac12$ for every card; this inequality is the standing
hypothesis of our profit theorems.

### 2.2 Payoff

**Definition 2.4 (Expected payoff of a card).** With payouts $+1$ for a correct
bet and $-1$ for an incorrect bet, the *expected payoff* of a card with
win-probability $p$ is
$$E(p) := 2p - 1.$$
Indeed the expectation is $p\cdot(+1) + (1-p)\cdot(-1) = 2p - 1$.

**Definition 2.5 (Total expected payoff of a deck).** Let $s$ be a finite index
set (a *deck*) and $p : s \to \mathbb R$ assign a win-probability to each card.
The *total expected payoff* is
$$T(s, p) := \sum_{i \in s} E(p_i) = \sum_{i \in s} (2 p_i - 1).$$

---

## 3. Foundational Results

### 3.1 Hedging breaks even

**Theorem 3.1 (Perfect hedge breaks even).** If $p = \tfrac12$ then $E(p) = 0$.

*Proof.* $E(\tfrac12) = 2\cdot\tfrac12 - 1 = 0$. $\qquad\blacksquare$

The interpretation is central: an undecidable card, resolved by a fair coin,
contributes *nothing* — neither gain nor loss — to the expected ledger. The
"cost" of incompleteness, under optimal hedging, is exactly zero.

### 3.2 Profitability criterion

**Theorem 3.2 (Positivity criterion).** For any $p \in \mathbb R$,
$$E(p) > 0 \iff p > \tfrac12.$$

*Proof.* $E(p) = 2p - 1 > 0 \iff 2p > 1 \iff p > \tfrac12$. $\qquad\blacksquare$

Thus profit is precisely equivalent to beating the coin. There is no middle
ground and no hidden threshold: any strict edge above one-half, however small,
makes a card profitable in expectation.

### 3.3 One strict winner suffices

**Theorem 3.3 (Positive expected profit).** Let $s$ be a finite deck and
$p : s \to \mathbb R$. Suppose

1. every card is at least break-even: $p_i \ge \tfrac12$ for all $i \in s$; and
2. at least one card is strictly profitable: there exists $j \in s$ with
   $p_j > \tfrac12$.

Then $T(s,p) > 0$.

*Proof.* By (1) and the definition of $E$, each summand satisfies $E(p_i) = 2p_i
- 1 \ge 0$. By (2), $E(p_j) = 2p_j - 1 > 0$. Since $E(p_j)$ is a single term of
the sum $T(s,p) = \sum_{i\in s} E(p_i)$ and all other terms are non-negative, we
have $T(s,p) \ge E(p_j) > 0$. $\qquad\blacksquare$

This is the qualitative heart of the theory: hedged (undecidable) cards are
costless, so a *single* card on which the player has a genuine edge already
tips the entire finite deck into profit.

---

## 4. Quantitative Bounds

### 4.1 The fraction bound

**Theorem 4.1 (Quantitative fraction bound).** Let $s$ be a finite deck of size
$n = |s|$, let $p : s \to \mathbb R$, and let $\alpha, \varepsilon \in \mathbb R$
with $\varepsilon > 0$. Suppose

1. every card is at least break-even: $p_i \ge \tfrac12$ for all $i \in s$; and
2. a fraction $\alpha$ of the deck has a uniform winning margin $\varepsilon$:
   writing $G := \{i \in s : p_i \ge \tfrac12 + \varepsilon\}$, we have
   $\alpha \cdot n \le |G|$.

Then
$$T(s,p) \;\ge\; \alpha \cdot n \cdot (2\varepsilon).$$

*Proof.* Partition the deck into the *good* cards $G$ and the *rest* $s\setminus
G$, so that
$$T(s,p) = \sum_{i \in G} E(p_i) + \sum_{i \in s\setminus G} E(p_i).$$
For $i \in G$ we have $p_i \ge \tfrac12 + \varepsilon$, hence $E(p_i) = 2p_i - 1
\ge 2\varepsilon$; summing over $G$ gives $\sum_{i\in G} E(p_i) \ge |G|\cdot
2\varepsilon$. For $i \in s\setminus G$, hypothesis (1) gives $E(p_i) \ge 0$, so
$\sum_{i\in s\setminus G} E(p_i) \ge 0$. Combining, $T(s,p) \ge |G|\cdot
2\varepsilon$. Finally, since $2\varepsilon > 0$ and $\alpha n \le |G|$, we get
$\alpha n \cdot 2\varepsilon \le |G|\cdot 2\varepsilon \le T(s,p)$.
$\qquad\blacksquare$

The bound decomposes profit into three independently interpretable factors: the
share $\alpha$ of cards on which the player has an edge, the deck size $n$, and
twice the margin $\varepsilon$. Each factor scales the guaranteed floor linearly.

### 4.2 The One-Third Theorem

**Theorem 4.2 (One-Third Theorem).** Let $s$ be a *nonempty* finite deck and
$p : s \to \mathbb R$. Suppose

1. every card is at least break-even: $p_i \ge \tfrac12$ for all $i \in s$; and
2. at least a third of the cards are strictly profitable:
   $\tfrac{n}{3} \le |\{i \in s : p_i > \tfrac12\}|$ where $n = |s|$.

Then $T(s,p) > 0$.

*Proof.* Let $G := \{i \in s : p_i > \tfrac12\}$. Since $s$ is nonempty, $n \ge
1$, so $n/3 > 0$, and hypothesis (2) gives $|G| \ge n/3 > 0$; hence $G$ is
nonempty. Pick $j \in G$; then $p_j > \tfrac12$. Now apply Theorem 3.3 with the
witness $j$: hypothesis (1) supplies the break-even condition and $j$ supplies
the strict winner. Therefore $T(s,p) > 0$. $\qquad\blacksquare$

**Remark (why one-third).** The constant $\tfrac13$ reflects the concept's
motivating heuristic from the arithmetic hierarchy: among statements at a given
level of logical complexity, a robust portion — at least a third under the
motivating count — are decidable at that level and hence winnable, while the rest
can be hedged. Theorem 4.2 shows that *any* such floor above $0$ would suffice;
the one-third figure is a concrete, defensible instance. Crucially, unlike
Theorem 4.1, the corollary needs no explicit margin hypothesis: on a finite deck
the finitely many strictly profitable cards automatically possess a positive
minimal margin.

---

## 5. The Measure-Theoretic Layer

We now certify that win-probabilities are honest probabilities, by realizing
them as (real values of) measures inside a genuine probability space.

**Definition 5.1 (Win-probability of an event).** Let $(\Omega, \mathcal F,
\mu)$ be a measure space and $W \subseteq \Omega$ its winning event. Define
$w(\mu, W) := \mu(W)$ evaluated as a real number.

**Proposition 5.1 (It is a probability).**
(i) For any measure $\mu$ and any $W$, $w(\mu, W) \ge 0$.
(ii) If $\mu$ is a probability measure, then $w(\mu, W)
\le 1$.

*Proof.* (i) A measure is non-negative, and the real value of a non-negative
extended real is non-negative. (ii) For a probability measure, $\mu(W) \le
\mu(\Omega) = 1$; monotonicity of the real-value map yields
$w(\mu, W) \le 1$. $\qquad\blacksquare$

**Definition 5.2 (Card expected payoff via a model-measure).**
$$E_\mu(W) := E\big(w(\mu,
W)\big) = 2\,\mu(W) - 1.$$

**Proposition 5.2 (Endpoints).**
(i) If $w(\mu, W) = \tfrac12$ (a hedged card), then
$E_\mu(W) = 0$.
(ii) If $w(\mu, W) = 1$ (a winnable card of full measure),
then $E_\mu(W) = 1$.

*Proof.* (i) Immediate from Theorem 3.1. (ii) $E(1) = 2\cdot 1 - 1 = 1$.
$\qquad\blacksquare$

Thus the abstract payoff calculus of Sections 3–4 is anchored: the numbers $p_i$
are genuine measures of genuine events, the hedge endpoint pays $0$, and the
winnable endpoint pays the maximal $1$.

---

## 6. A Faithfulness Correction

The folklore statement of the fraction bound asserts a lower bound of the form
$\alpha \cdot n \cdot \varepsilon$ "for some $\varepsilon > 0$ depending only on
$\alpha$." **This is not achievable**, and we record why.

**Proposition 6.1 (No margin-free lower bound).** There is no function
$\varepsilon(\alpha) > 0$ such that every deck satisfying $p_i \ge \tfrac12$ for
all $i$ and $|\{i : p_i > \tfrac12\}| \ge \alpha n$ obeys $T(s,p) \ge \alpha n
\cdot \varepsilon(\alpha)$.

*Proof (sketch).* Fix $\alpha \in (0,1]$ and $n$. Choose a deck in which $\lceil
\alpha n\rceil$ cards have $p_i = \tfrac12 + \delta$ and the rest have $p_i =
\tfrac12$. Then $T(s,p) = \lceil \alpha n\rceil \cdot 2\delta$, which tends to
$0$ as $\delta \to 0^+$ while the hypotheses persist. Hence no positive bound
depending on $\alpha$ (and $n$) alone can hold. $\qquad\blacksquare$

The resolution is exactly Theorem 4.1: make the margin $\varepsilon$ an explicit
hypothesis. The corrected bound $\alpha n \cdot 2\varepsilon$ is both faithful to
the concept's intent and provably true. The qualitative One-Third Theorem
survives untouched precisely because, on a *finite* deck, the strictly winning
cards possess a positive minimum margin automatically, so a strict — though not
uniformly quantified — profit is guaranteed.

---

## 7. Algorithms

The theory is constructive and yields immediate algorithms for auditing a deck.

**Algorithm A (Total expected payoff).** Given win-probabilities $p_1, \dots,
p_n$, return $\sum_i (2p_i - 1)$. Linear time $O(n)$.

**Algorithm B (Profit certificate via the One-Third Theorem).** Given
win-probabilities, verify (i) $p_i \ge \tfrac12$ for all $i$ and (ii) at least
$n/3$ satisfy $p_i > \tfrac12$; if both hold, certify strictly positive expected
profit. Linear time $O(n)$.

**Algorithm C (Fraction-bound floor).** Given win-probabilities and a margin
$\varepsilon$, compute $G = \{i : p_i \ge \tfrac12 + \varepsilon\}$, set $\alpha
= |G|/n$, and return the certified floor $\alpha n \cdot 2\varepsilon = 2\,|G|\,
\varepsilon$. Linear time $O(n)$.

---

## 8. Applications and Interpretation

**Costless incompleteness.** The most striking reading of Theorems 3.1 and 3.3
is that undecidable cards, optimally hedged, do not drag down the ledger. A
century of pessimism about incompleteness is replaced by a break-even accounting:
what you cannot know is free.

**Local ignorance, global profit.** The One-Third Theorem formalizes the
intuition that one can remain permanently ignorant of any particular statement
yet still win the aggregate game, provided genuine knowledge is spread over a
non-trivial fraction of the deck.

**A decision-theoretic lens on independence.** By assigning win-probabilities to
statements via a model-measure, the framework offers a principled way to price
bets on statements like the Continuum Hypothesis — not as absolute truths but as
events with definite measures in a space of admissible universes.

---

## 9. Discussion and Future Directions

Several avenues extend the theory beyond finite decks and expected values.

1. **Countable and asymptotic decks.** Generalize the profit theorems from
   finite to countable decks $(p_i)_{i\in\mathbb N}$ with $p_i \ge \tfrac12$, and
   prove an asymptotic profit-rate theorem: if the liminf of the empirical
   fraction of cards with margin $\ge \varepsilon$ is $\alpha > 0$, then the
   liminf of $\tfrac1n T$ is at least $2\alpha\varepsilon$.

2. **Concentration of the deck payoff.** Replace expected payoff by the random
   total $\sum X_i$ with independent $X_i \in \{-1, +1\}$ and $\Pr(X_i = +1) =
   p_i$. A Hoeffding-type bound $\Pr(\sum X_i \le 0) \le \exp\big(-(\sum(2p_i -
   1))^2 / (2n)\big)$ would upgrade positive *expected* profit to profit *with
   high probability*.

3. **Adversarial house (game value).** Model a two-player game in which the house
   selects a deck subject to a budget (at most a fraction $\beta$ of cards may be
   strictly winnable) and the player selects bets. Use the fraction bound as the
   player's guarantee and a matching upper bound as the house's to compute the
   minimax value as a function of $\beta$ and the margin distribution.

4. **Measurability and definability of winning events.** Give sufficient
   conditions (e.g. Borel-measurability of the strategy and of truth) under which
   every winning event is measurable, so that its win-probability is well-defined
   for the natural measure, and classify strategies under which $p_\varphi \in
   \{\tfrac12, 1\}$.

5. **Toward a canonical model-measure.** Enumerate countable transitive models by
   description length and place a definable summable density (e.g. $2^{-\text{code}}$)
   on the enumeration, pushing forward to a probability measure on the model
   space so that the abstract profit theorems specialize to a fully explicit
   casino.

---

## 10. Conclusion

Gödel's Casino reframes incompleteness as an opportunity rather than an
obstruction. By pricing each undecidable statement through its win-probability in
a space of models, we obtain a clean payoff calculus in which hedged cards are
costless, strict edges are exactly the source of profit, and a single genuine
winner — or, headline-worthily, a mere one-third fraction of them — guarantees
strictly positive expected profit over any finite deck. The measure-theoretic
layer keeps the win-probabilities honest, and a careful faithfulness analysis
pins down exactly what quantitative guarantee is and is not available. The
undecidable universe, played with discipline, pays you to play.
