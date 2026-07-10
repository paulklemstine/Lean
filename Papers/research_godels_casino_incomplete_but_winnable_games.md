# Gödel's Casino: A Game-Theoretic Analysis of Betting on Undecidable Statements

## Abstract

We introduce and rigorously analyze *Gödel's Casino*, a betting game in which a player wagers on the truth value of statements — including statements that are independent of a background theory in the sense of holding in some models and failing in others. Motivated by the provocative conjecture that undecidability can be monetized (that each undecidable statement is individually winnable with strictly positive expected value, subject to a universal per-round lower bound of $1/3$), we build a fully self-contained finite model and settle the conjecture in the negative. We prove that the game is zero-sum with no house edge; that decidable statements (valid or unsatisfiable) are winnable with maximal expected profit $1$; that any *independent* statement suffers a worst-case payoff of $-1$ regardless of the bet; and, decisively, that a *balanced* statement (true in exactly half the worlds) yields expected profit exactly $0$ for every bet. We exhibit an explicit independent statement on which no bet has positive expected value, refuting the individual-winnability claim, and a deck of balanced cards whose average optimal profit is $0$, refuting the $1/3$ bound. The honest positive theory is that optimal profit is nonnegative, that a deck of decidable cards is won every round, and that a mixed deck with a fraction $f$ of decidable cards has average optimal profit exactly $f$. The player's entire edge derives from the decidable fragment; genuine incompleteness contributes exactly zero in expectation and $-1$ in the worst case. In this precise game-theoretic sense, incompleteness is a barrier, not a free lunch.

**Keywords:** undecidability, independence, incompleteness, zero-sum game, expected value, model theory, decision theory.

## 1. Introduction

Gödel's incompleteness theorems and the subsequent independence results of Cohen and others established that formal mathematics is permanently haunted by statements it can neither prove nor refute. The Continuum Hypothesis is the canonical example: it is *independent* of the standard axioms, holding in some models of set theory and failing in others. A recurring popular intuition holds that this multiplicity of models is not merely a limitation but a resource — that if a statement is "right in some model," then a gambler betting on its truth ought to be able to profit.

This paper takes that intuition seriously and tests it inside a precise decision-theoretic model. We formalize a betting game — *Gödel's Casino* — and evaluate a specific optimistic conjecture drawn from the informal literature:

> **Conjecture (Monetizable Undecidability).** There is a betting strategy on statements independent of a theory that guarantees strictly positive expected profit, with each undecidable bet individually winnable and a universal lower bound of $1/3$ expected profit per round.

Our contribution is to show that this conjecture is *false*, to prove exactly which parts of the intuition survive, and to isolate the source of any genuine edge. The analysis is elementary and self-contained: it requires only finite sums of rational numbers and does not depend on any formalization of the arithmetic hierarchy or of set theory. Its purpose is to capture the *game-theoretic content* of the conjecture faithfully, and in that arena the verdict is unambiguous.

## 2. The Model

### 2.1 Worlds, statements, and bets

Fix a finite, nonempty set $\Omega$ of *worlds* (intuitively, the models of the background theory). A **statement** is a function

$$s : \Omega \to \{\text{true}, \text{false}\},$$

recording the truth value of $s$ in each world. A **bet** is an element $b \in \{\text{true}, \text{false}\}$. This identification is deliberate: for betting purposes a statement is exactly its pattern of truth values across worlds, and nothing more.

### 2.2 Payoffs

The per-world **payoff** of betting $b$ on statement $s$ in world $\omega$ is

$$\mathrm{payoff}(s, b, \omega) = \begin{cases} +1 & \text{if } b = s(\omega), \\ -1 & \text{if } b \neq s(\omega). \end{cases}$$

This is a scrupulously symmetric, fair-odds rule: a correct call earns one unit, an incorrect call loses one.

### 2.3 Two evaluations of a bet

Under the uniform prior over $\Omega$, the **expected profit** of a bet is

$$\mathrm{expProfit}(s, b) = \frac{1}{|\Omega|} \sum_{\omega \in \Omega} \mathrm{payoff}(s, b, \omega).$$

Against an adversarial house that reveals the least favorable world, the **worst-case profit** is $\min_{\omega} \mathrm{payoff}(s, b, \omega)$. A genuinely winning strategy should perform well under both.

### 2.4 Classes of statements

Let $\mathrm{trueCount}(s) = |\{\omega \in \Omega : s(\omega) = \text{true}\}|$ be the number of worlds in which $s$ holds. We distinguish:

- $s$ is **valid** if $s(\omega) = \text{true}$ for all $\omega$ (a decidable truth);
- $s$ is **unsatisfiable** if $s(\omega) = \text{false}$ for all $\omega$ (a decidable falsehood);
- $s$ is **independent** if $s(\omega) = \text{true}$ for some $\omega$ and $s(\omega') = \text{false}$ for some $\omega'$;
- $s$ is **balanced** if $2\,\mathrm{trueCount}(s) = |\Omega|$ (true in exactly half the worlds).

Every balanced statement (in a nonempty world set) is independent; the converse fails.

### 2.5 The optimal bet and decks

The **optimal expected profit** of a statement is the better of the two available bets:

$$\mathrm{optProfit}(s) = \max\bigl(\mathrm{expProfit}(s, \text{true}),\ \mathrm{expProfit}(s, \text{false})\bigr).$$

A **deck** is a finite list of statements $D = [s_1, \dots, s_n]$; one round is played per card, and the deck's average optimal profit is

$$\mathrm{deckOptProfit}(D) = \frac{1}{n} \sum_{i=1}^{n} \mathrm{optProfit}(s_i).$$

## 3. Structural Results

### 3.1 The game is zero-sum

**Lemma 1 (Pointwise zero-sum).** For every statement $s$ and world $\omega$,
$$\mathrm{payoff}(s, \text{true}, \omega) + \mathrm{payoff}(s, \text{false}, \omega) = 0.$$

*Proof sketch.* In each world exactly one of the two bets matches $s(\omega)$, paying $+1$, while the other pays $-1$. The two cases $s(\omega) = \text{true}$ and $s(\omega) = \text{false}$ both give $(+1) + (-1) = 0$. $\square$

**Theorem 2 (Zero-sum game).** For every statement $s$,
$$\mathrm{expProfit}(s, \text{true}) + \mathrm{expProfit}(s, \text{false}) = 0.$$

*Proof sketch.* Summing Lemma 1 over all worlds gives a total of $0$; dividing by $|\Omega|$ preserves it. Linearity of the finite sum is all that is needed. $\square$

The interpretation is central to everything that follows: the casino has *no built-in edge* in either direction. Any positive expected profit a player achieves must arise entirely from *information* about the card — specifically, from the card being decided one way or the other.

### 3.2 A closed form for expected profit

**Lemma 3 (Total TRUE-payoff).** For every statement $s$,
$$\sum_{\omega \in \Omega} \mathrm{payoff}(s, \text{true}, \omega) = 2\,\mathrm{trueCount}(s) - |\Omega|.$$

*Proof sketch.* Partition $\Omega$ into the worlds where $s$ is true (each contributing $+1$) and where $s$ is false (each contributing $-1$). The true worlds number $\mathrm{trueCount}(s)$ and the false worlds number $|\Omega| - \mathrm{trueCount}(s)$, so the sum is $\mathrm{trueCount}(s) - (|\Omega| - \mathrm{trueCount}(s)) = 2\,\mathrm{trueCount}(s) - |\Omega|$. $\square$

**Theorem 4 (Expected-profit formula).** For every statement $s$,
$$\mathrm{expProfit}(s, \text{true}) = \frac{2\,\mathrm{trueCount}(s) - |\Omega|}{|\Omega|}.$$

This single formula drives the entire analysis. Expected profit on the TRUE bet is a strictly increasing affine function of the fraction of worlds in which the statement holds: it ranges from $-1$ (never true) through $0$ (true in exactly half the worlds) to $+1$ (always true).

## 4. Decidable Statements Are Winnable

**Theorem 5 (Valid statements pay the maximum).** If $s$ is valid, then $\mathrm{expProfit}(s, \text{true}) = 1$.

*Proof sketch.* Validity means $s(\omega) = \text{true}$ in every world, so every payoff for the TRUE bet is $+1$; the average of a constant $1$ is $1$. (Equivalently, $\mathrm{trueCount}(s) = |\Omega|$ in Theorem 4.) $\square$

**Theorem 6 (Unsatisfiable statements pay the maximum).** If $s$ is unsatisfiable, then $\mathrm{expProfit}(s, \text{false}) = 1$.

*Proof sketch.* Symmetric to Theorem 5: every FALSE bet matches, so every payoff is $+1$. $\square$

**Corollary 7.** A valid statement has $\mathrm{optProfit}(s) = 1$ (and, by the zero-sum law, the TRUE bet beats the FALSE bet, which returns $-1$).

These theorems locate the source of all winnings. Decidable statements — those settled in every world — are perfectly winnable, and they are precisely the statements that are *not* undecidable.

## 5. Independence Cannot Be Beaten

We now turn to the cards the conjecture actually cares about.

**Theorem 8 (Guaranteed worst-case loss on independent cards).** If $s$ is independent, then for every bet $b$ there exists a world $\omega$ with $\mathrm{payoff}(s, b, \omega) = -1$.

*Proof sketch.* Independence supplies a world $\omega_T$ with $s(\omega_T) = \text{true}$ and a world $\omega_F$ with $s(\omega_F) = \text{false}$. If $b = \text{true}$, then in $\omega_F$ the bet mismatches and pays $-1$; if $b = \text{false}$, then in $\omega_T$ the bet mismatches and pays $-1$. $\square$

Consequently the worst-case (adversarial) profit on any independent statement is $\leq -1 < 0$: against a house that reveals the cruelest world, independence is a strict loss no matter how you bet. Dually, one shows that every independent card also has *some* winning world — independence cuts both ways — but this offers no protection against an adversary.

**Theorem 9 (Balanced statements have no edge).** If $s$ is balanced, then $\mathrm{expProfit}(s, b) = 0$ for every bet $b$.

*Proof sketch.* Balancedness means $2\,\mathrm{trueCount}(s) = |\Omega|$, so the numerator $2\,\mathrm{trueCount}(s) - |\Omega|$ in Theorem 4 vanishes and $\mathrm{expProfit}(s, \text{true}) = 0$. By the zero-sum law (Theorem 2), $\mathrm{expProfit}(s, \text{false}) = 0$ as well. $\square$

**Corollary 10.** A balanced statement has $\mathrm{optProfit}(s) = 0$: it is not winnable even in the optimistic, expected-value sense. A balanced independent card is, in every measurable respect, a fair coin.

## 6. Refuting the Conjecture

**Theorem 11 (An explicit unwinnable independent card).** There exists a statement that is independent yet on which every bet has expected profit exactly $0$.

*Proof sketch.* Take $\Omega = \{\text{true}, \text{false}\}$ (a two-world universe) and let $s$ be the identity, i.e. $s$ reads TRUE in the world "true" and FALSE in the world "false." Then $s$ is independent (it takes both values) and balanced ($\mathrm{trueCount}(s) = 1 = |\Omega|/2$), so by Theorem 9 every bet returns $0$. $\square$

This is the miniature Continuum-Hypothesis card: "right in some model, wrong in another." It is genuinely undecidable in the model-theoretic sense that matters, and it is worth *nothing*. This directly refutes the claim that each undecidable statement is individually winnable with strictly positive expected value.

**Theorem 12 (The $1/3$ bound fails).** There exists a nonempty deck $D$ with $\mathrm{deckOptProfit}(D) = 0$, hence $\mathrm{deckOptProfit}(D) < 1/3$.

*Proof sketch.* Let $D$ consist of a single balanced card (e.g. the identity card of Theorem 11). By Corollary 10 its optimal profit is $0$, so the deck average is $0 < 1/3$. $\square$

The claimed universal lower bound of $1/3$ expected profit per round is therefore not merely loose but false.

## 7. The Honest Positive Theory

The refutation does not leave the player destitute; it relocates the profit to its true source.

**Theorem 13 (Optimal profit is nonnegative).** For every statement $s$, $\mathrm{optProfit}(s) \geq 0$.

*Proof sketch.* By the zero-sum law the two bets sum to $0$, so at least one of them is $\geq 0$; the maximum is therefore $\geq 0$. $\square$

**Theorem 14 (Decidable decks are won every round).** If a nonempty deck $D$ consists entirely of valid statements, then $\mathrm{deckOptProfit}(D) = 1$.

*Proof sketch.* By Corollary 7 each card has optimal profit $1$; the average of constants equal to $1$ is $1$. $\square$

More generally, a mixed deck in which a fraction $f$ of the cards are decidable (each paying $1$) and the remaining fraction $1 - f$ are balanced (each paying $0$) has average optimal profit exactly $f$. Every unit of long-run profit is contributed by a decidable card; the undecidable cards contribute exactly zero.

**Theorem 15 (Soundness yields a real edge — on decidable cards).** Let $\mathrm{Prov}$ be any predicate on statements such that $\mathrm{Prov}(s)$ implies $s$ is valid (a *sound* proof system proves only validities). Then for any provable statement $s$, $\mathrm{expProfit}(s, \text{true}) = 1$.

*Proof sketch.* If $\mathrm{Prov}(s)$ holds then $s$ is valid by soundness, and Theorem 5 applies. $\square$

Theorem 15 is the rigorous form of the intended sub-strategy "bet TRUE on provable statements." It genuinely wins — but the analysis makes transparent *why*: a provable statement is, by soundness, decidable-true, not independent. The strategy exploits the decidable fragment and touches undecidability not at all.

## 8. Discussion

The results assemble into a single clean dichotomy for the value of a card:

| Card type | Expected profit (optimal bet) | Worst-case profit |
|---|---|---|
| Valid / unsatisfiable (decidable) | $+1$ | $+1$ |
| Balanced (independent) | $0$ | $-1$ |
| General independent | $\in [0, 1)$ | $-1$ |

The optimistic conjecture conflated two very different phenomena: the genuine winnability of *decidable* statements and the supposed winnability of *undecidable* ones. The formula of Theorem 4 shows expected profit is governed solely by the *fraction of worlds in which a statement holds*. Decidable statements sit at the extremes of this scale (fraction $0$ or $1$) and pay the maximum. Independent statements sit strictly inside, and balanced ones sit at the exact center, worth nothing. No amount of cleverness moves a card along this scale; the scale is fixed by the statement's semantics.

The worst-case result (Theorem 8) is if anything more damning for the conjecture: independence is not merely a break-even proposition but a strict loss against an adversary. The "right in some model" property that makes independence sound like an opportunity is exactly the property — being true in some world and false in another — that guarantees a losing world exists.

The verdict, stated carefully, is: *you can win at the decidable fragment; the undecidable fragment is exactly a fair coin (expected $0$) or an adversarial loss ($-1$).* Incompleteness, in this precise game-theoretic sense, is a barrier and not a free lunch. This is a contrarian conclusion relative to the romantic hope that motivated the casino, but it is a sharper and more useful truth: it tells the gambler exactly where value lives (in what can be decided) and exactly where it does not (in what cannot).

## 9. Future Directions

Several extensions suggest themselves. One may replace the uniform prior over worlds with an arbitrary probability measure, asking how a bettor's subjective credences interact with the zero-sum structure; the expected-profit formula generalizes to $2\,\mathbb{P}[s] - 1$ for the TRUE bet, so the qualitative dichotomy persists but the "balanced" boundary shifts to $\mathbb{P}[s] = 1/2$. One may study *sequential* play in which the revealed world constrains future cards, connecting the casino to online learning and regret minimization. One may allow *fractional* or *hedged* bets and continuous payoffs, recovering a proper scoring-rule perspective. Finally, one may attempt to align the abstract world-model more tightly with genuine proof-theoretic strength — replacing "valid" with "provable in a fixed sound theory" and studying how enlarging the theory (adding independent axioms) migrates cards from the balanced center toward the winnable extremes, quantifying the marginal betting value of each new axiom.
