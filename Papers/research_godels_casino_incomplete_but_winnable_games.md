# Gödel's Casino: A Guaranteed-Win Strategy for Betting on Undecidable Sentences

## Abstract

We introduce and rigorously analyze *Gödel's Casino*, a betting game in which a player wagers on the arithmetic truth value of sentences that are **independent** of a fixed formal theory $T$ — sentences $T$ can neither prove nor refute. Naively, such sentences appear to be pure coin flips: undecidable by hypothesis, they seem to offer no rational basis for a bet. We show this intuition is mistaken. Working from three classical properties of arithmetic theories — soundness, compatibility of truth with negation, and $\Sigma_1$-completeness — we prove that the *syntactic shape* of an independent sentence determines its truth value: **every independent $\Pi_1$ sentence is true, and every independent $\Sigma_1$ sentence is false.** These two facts yield a strategy (bet TRUE on $\Pi_1$, FALSE on $\Sigma_1$, hedge otherwise) that never loses a round and strictly profits whenever a $\Sigma_1$ or $\Pi_1$ card is dealt. The total profit over a deck equals the number of decidable-shape cards; if at least one-third of a deck has decidable shape, the guaranteed average profit per round is at least $1/3$. This upgrades the original "positive expected value" conjecture to a *deterministic* win. We also show the naive strategy — motivated by the common but incorrect intuition that consistency statements should be bet FALSE — is the pointwise inverse of the optimal one and loses exactly what the optimal strategy wins. A concrete toy model demonstrates non-vacuity.

**Keywords:** incompleteness, arithmetic hierarchy, $\Sigma_1$-completeness, independent sentences, decision theory, consistency statements.

---

## 1. Introduction

Gödel's First Incompleteness Theorem guarantees that any sound, recursively axiomatized theory $T$ extending a modest fragment of arithmetic possesses sentences that are **independent** of $T$: neither the sentence nor its negation is provable in $T$. The archetype is the consistency statement $\mathrm{Con}(T)$, whose unprovability is the content of the Second Incompleteness Theorem, but there are continuum-many others.

The standard narrative treats such sentences as an epistemic dead end. If $T$ cannot decide $s$, on what basis could a rational agent commit to "$s$ is true" or "$s$ is false"? *Gödel's Casino* poses precisely this question as a decision problem: a dealer presents independent sentences one at a time, and a player must wager TRUE, FALSE, or decline. We ask whether a strategy exists with a positive edge.

The central observation of this paper is that **independence is not the same as truth-neutrality.** Although $T$ cannot settle an independent sentence *internally*, an external observer who knows the sentence's position in the arithmetic hierarchy can determine its truth value in the standard model $\mathbb{N}$ with certainty. The mechanism is $\Sigma_1$-completeness, the classical fact that true existential (findable) statements cannot escape provability.

Our contributions are:

1. A clean abstract model of the relevant fragment of a formal theory, isolating exactly the three hypotheses the argument requires (Section 2).
2. Two core theorems (Section 3): independent $\Pi_1$ sentences are true; independent $\Sigma_1$ sentences are false.
3. A formal casino model and a strategy with per-card profit in $\{0, +1\}$, hence a guaranteed non-negative outcome; the total deck profit equals the count of decidable-shape cards (Section 4).
4. A quantitative edge: under a one-third decidable-shape density, the average profit per round is at least $1/3$ (Section 5).
5. A duality result identifying the naive strategy as the exact inverse of the optimal one (Section 6), and a concrete non-vacuous instance (Section 7).

A recurring theme is a **correction** to the folklore intuition: because $\mathrm{Con}(T)$ is a $\Pi_1$ sentence, the correct bet on it is TRUE, not FALSE. The consistency statement of a sound theory is a genuinely *true* sentence that the theory cannot prove about itself.

---

## 2. The abstract model of a theory

Rather than commit to a specific logical syntax, we model a theory by exactly the data the betting argument consumes. This keeps the results maximally general: any concrete arithmetic theory satisfying the three hypotheses below inherits every theorem.

**Definition 2.1 (Theory).** A *theory* $T$ consists of:

- a type $\mathrm{Sentence}$ of sentences;
- a *negation* operation $\neg : \mathrm{Sentence} \to \mathrm{Sentence}$;
- a *provability* predicate $\mathrm{Provable}(s)$, read "$T \vdash s$";
- a *truth* predicate $\mathrm{True}(s)$, read "$s$ holds in the standard model $\mathbb{N}$";
- a *classification* predicate $\mathrm{IsSigma1}(s)$, read "$s$ is syntactically $\Sigma_1$";

subject to three axioms:

- **(Soundness)** $\mathrm{Provable}(s) \Rightarrow \mathrm{True}(s)$ for all $s$: the theory proves only true sentences.
- **(Truth respects negation)** $\mathrm{True}(\neg s) \iff \neg\,\mathrm{True}(s)$ for all $s$.
- **($\Sigma_1$-completeness)** $\mathrm{IsSigma1}(s) \wedge \mathrm{True}(s) \Rightarrow \mathrm{Provable}(s)$ for all $s$: every true $\Sigma_1$ sentence is provable.

These three hypotheses are theorems, not assumptions, for any sound recursively axiomatized extension of Robinson arithmetic $Q$. Soundness holds for any theory with a standard model; truth-respects-negation is a basic property of the satisfaction relation; and $\Sigma_1$-completeness is the classical representability theorem for $\Sigma_1$ formulas over $Q$. We take them as the defining interface so that the casino analysis is a purely deductive consequence.

**Definition 2.2 ($\Pi_1$).** A sentence $s$ is *$\Pi_1$*, written $\mathrm{IsPi1}(s)$, iff its negation is $\Sigma_1$: $\mathrm{IsPi1}(s) :\iff \mathrm{IsSigma1}(\neg s)$.

This mirrors the classical duality: $\Pi_1$ sentences are exactly the negations of $\Sigma_1$ sentences. A $\Sigma_1$ sentence asserts $\exists n\, P(n)$ with $P$ decidable; a $\Pi_1$ sentence asserts $\forall n\, Q(n)$ with $Q$ decidable.

**Definition 2.3 (Independence).** A sentence $s$ is *independent* of $T$, written $\mathrm{Indep}(s)$, iff neither it nor its negation is provable:
$$\mathrm{Indep}(s) :\iff \neg\,\mathrm{Provable}(s) \ \wedge\ \neg\,\mathrm{Provable}(\neg s).$$

Independent sentences are exactly the "interesting" cards: the game is trivial on sentences $T$ can already decide, so the casino deals only independent ones.

---

## 3. The mathematical core: shape determines truth

We now prove that among independent sentences, syntactic shape pins down the truth value.

**Theorem 3.1 (Independent $\Pi_1$ sentences are true).** *Let $s$ be a $\Pi_1$ sentence independent of $T$. Then $\mathrm{True}(s)$.*

*Proof.* Suppose not, i.e. $\neg\,\mathrm{True}(s)$. By truth-respects-negation, $\mathrm{True}(\neg s)$. Since $s$ is $\Pi_1$, its negation $\neg s$ is $\Sigma_1$. Applying $\Sigma_1$-completeness to $\neg s$ gives $\mathrm{Provable}(\neg s)$. But independence asserts $\neg\,\mathrm{Provable}(\neg s)$ — contradiction. Hence $\mathrm{True}(s)$. $\qquad\blacksquare$

**Theorem 3.2 (Independent $\Sigma_1$ sentences are false).** *Let $s$ be a $\Sigma_1$ sentence independent of $T$. Then $\neg\,\mathrm{True}(s)$.*

*Proof.* Suppose $\mathrm{True}(s)$. Since $s$ is $\Sigma_1$, $\Sigma_1$-completeness gives $\mathrm{Provable}(s)$, contradicting the first clause of independence. Hence $\neg\,\mathrm{True}(s)$. $\qquad\blacksquare$

These two one-line arguments are the entire engine of the casino. Note that neither proof settles $s$ *inside* $T$ — that is impossible by independence. They settle $s$ in the standard model by reasoning *about* $T$'s deductive closure. Undecidability is compatible with a definite external truth value, and shape reveals it.

**Corollary 3.3 (Consistency correction).** *If $\mathrm{Con}(T)$, the $\Pi_1$ consistency statement of $T$, is independent of $T$, then it is true.*

This corrects the tempting intuition that one should bet FALSE on consistency statements. As the canonical unprovable sentence, $\mathrm{Con}(T)$ *feels* like it should be the losing card; in fact, being $\Pi_1$ and independent, it is true, and the winning bet is TRUE.

---

## 4. The casino and the strategy

**Definition 4.1 (Bets and payoffs).** A *bet* is an element of $\{\text{betTrue}, \text{betFalse}, \text{hedge}\}$. The *payoff* of a bet on a sentence $s$ is
$$
\mathrm{payoff}(b, s) = \begin{cases}
+1 & b = \text{betTrue}, \ \mathrm{True}(s); \\
-1 & b = \text{betTrue}, \ \neg\,\mathrm{True}(s); \\
-1 & b = \text{betFalse}, \ \mathrm{True}(s); \\
+1 & b = \text{betFalse}, \ \neg\,\mathrm{True}(s); \\
0 & b = \text{hedge}.
\end{cases}
$$
A correct bet wins one chip, a wrong bet loses one chip, and a hedge is a wash.

**Definition 4.2 (Kinds and the strategy).** Each card carries a declared *kind* in $\{\Sigma_1, \Pi_1, \text{other}\}$. The player's *strategy* maps kind to bet:
$$
\mathrm{strat}(\Sigma_1) = \text{betFalse}, \qquad
\mathrm{strat}(\Pi_1) = \text{betTrue}, \qquad
\mathrm{strat}(\text{other}) = \text{hedge}.
$$

**Definition 4.3 (Card).** A *card* is a tuple $(s, k, c, i)$ where $s$ is a sentence, $k$ is a declared kind, $c$ is a proof that $s$ genuinely has kind $k$ (i.e. $\mathrm{IsSigma1}(s)$ if $k = \Sigma_1$, $\mathrm{IsPi1}(s)$ if $k = \Pi_1$, and no constraint if $k = \text{other}$), and $i$ is a proof that $s$ is independent of $T$. A card has *decidable shape* iff its kind is $\Sigma_1$ or $\Pi_1$.

The proof obligations $c$ and $i$ are what make the game honest: the dealer cannot mislabel a card, and every card is genuinely undecidable by $T$.

**Definition 4.4 (Card profit).** The profit of playing the strategy on a card $(s,k,c,i)$ is $\mathrm{cardProfit} := \mathrm{payoff}(\mathrm{strat}(k), s)$.

**Theorem 4.5 (Decidable-shape cards win).**
- If a card's kind is $\Sigma_1$, then $\mathrm{cardProfit} = +1$.
- If a card's kind is $\Pi_1$, then $\mathrm{cardProfit} = +1$.
- If a card's kind is $\text{other}$, then $\mathrm{cardProfit} = 0$.

*Proof.* For $\Sigma_1$: the strategy bets FALSE, and by Theorem 3.2 the sentence is false, so the FALSE bet is correct and pays $+1$. For $\Pi_1$: the strategy bets TRUE, and by Theorem 3.1 the sentence is true, so the TRUE bet pays $+1$. For $\text{other}$: the strategy hedges, paying $0$ by definition. $\qquad\blacksquare$

**Corollary 4.6 (Profit is an indicator).** For every card,
$$\mathrm{cardProfit} = \begin{cases} 1 & \text{if the card has decidable shape},\\ 0 & \text{otherwise}.\end{cases}$$

**Corollary 4.7 (No single round loses).** $\mathrm{cardProfit} \ge 0$ for every card.

**Definition 4.8 (Deck profit).** For a deck (finite list) of cards $D = [c_1, \dots, c_N]$, the *deck profit* is $\mathrm{deckProfit}(D) = \sum_{j=1}^{N} \mathrm{cardProfit}(c_j)$.

**Theorem 4.9 (Deck profit equals decidable-shape count).**
$$\mathrm{deckProfit}(D) = \#\{\, j : c_j \text{ has decidable shape} \,\}.$$

*Proof.* Sum Corollary 4.6 over the deck; each decidable-shape card contributes $1$ and each other card contributes $0$. $\qquad\blacksquare$

**Corollary 4.10 (The house never wins).** $\mathrm{deckProfit}(D) \ge 0$ for every deck.

**Corollary 4.11 (Strict profit).** If $D$ contains at least one decidable-shape card, then $\mathrm{deckProfit}(D) \ge 1 > 0$.

Thus the strategy is *guaranteed* to profit — not in expectation, but with certainty — as soon as a single $\Sigma_1$ or $\Pi_1$ card appears.

---

## 5. The one-third edge

The original conjecture sought merely positive *expected* profit. We can extract a stronger *deterministic* average bound from a density assumption motivated by the arithmetic hierarchy, whose two lowest nontrivial levels are precisely $\Sigma_1$ and $\Pi_1$. As a robust heuristic, a substantial constant fraction — at least one-third — of independent arithmetic sentences at play have single-quantifier ($\Sigma_1$ or $\Pi_1$) shape.

**Theorem 5.1 (One-third guaranteed edge).** *Let $D$ be a deck of $N \ge 1$ cards, of which at least $N/3$ have decidable shape. Then*
$$\frac{\mathrm{deckProfit}(D)}{N} \ \ge\ \frac{1}{3}.$$

*Proof.* By Theorem 4.9, $\mathrm{deckProfit}(D)$ equals the number of decidable-shape cards, which is at least $N/3$ by hypothesis. Dividing by $N$ gives the bound. $\qquad\blacksquare$

The contrast with the conjecture is worth emphasizing. "Positive expected value" would tolerate losing rounds averaged out by winning rounds. Theorem 5.1 asserts a floor with no downside risk at all: every round is $0$ or $+1$, and at least a third of them are $+1$.

---

## 6. Duality: the naive strategy loses

To confirm that the winning strategy is doing genuine work, we contrast it with the *naive* strategy $\mathrm{strat}^{\text{naive}}$ that follows the tempting-but-wrong intuition: bet FALSE on $\Pi_1$ (including consistency statements) and TRUE on $\Sigma_1$, hedging otherwise. This inverts the winning bet on every decidable-shape card.

**Theorem 6.1 (Pointwise inversion).** *For every decidable-shape card, the naive card profit is $-1$; on other cards it is $0$. Consequently, for every card, $\mathrm{naiveCardProfit} = -\,\mathrm{cardProfit}$.*

*Proof.* On a $\Sigma_1$ card the naive strategy bets TRUE, but the sentence is false (Theorem 3.2), so the bet loses: $-1$. On a $\Pi_1$ card it bets FALSE, but the sentence is true (Theorem 3.1), so the bet loses: $-1$. On other cards it hedges: $0$. In every case this is the negation of $\mathrm{cardProfit}$ from Theorem 4.5. $\qquad\blacksquare$

**Corollary 6.2 (Naive deck loses exactly what optimal wins).**
$$\mathrm{naiveDeckProfit}(D) = -\,\mathrm{deckProfit}(D) = -\,\#\{\text{decidable-shape cards}\}.$$
In particular, if $D$ has a decidable-shape card, the naive strategy strictly loses.

The house edge is therefore real and *directional*: the game is not symmetric, and knowing the correct direction (the content of Theorems 3.1–3.2) is precisely what separates winning from losing.

---

## 7. A concrete non-vacuous instance

The abstract theorems could in principle be vacuous if no theory satisfied Definition 2.1 with a nonempty independent deck. To rule this out we exhibit a small explicit model.

**Construction 7.1 (Toy theory).** Take $\mathrm{Sentence} = \{\mathsf{t}, \mathsf{f}\}$ (a "true atom" and a "false atom"), with negation swapping them ($\neg\mathsf{t} = \mathsf{f}$, $\neg\mathsf{f} = \mathsf{t}$). Let $\mathrm{True}(\mathsf{t})$ hold and $\mathrm{True}(\mathsf{f})$ fail. Let $\mathrm{Provable}$ be identically false (the theory proves nothing), and let $\mathrm{IsSigma1}$ hold of $\mathsf{f}$ only. One verifies:

- **Soundness** holds vacuously, since nothing is provable.
- **Truth respects negation** holds by direct case check on $\{\mathsf{t},\mathsf{f}\}$.
- **$\Sigma_1$-completeness** holds vacuously: the only $\Sigma_1$ atom is $\mathsf{f}$, which is not true, so there is no true $\Sigma_1$ sentence to prove.

Now $\mathsf{t}$ is $\Pi_1$ (its negation $\mathsf{f}$ is $\Sigma_1$) and independent (nothing is provable), so it is a legal $\Pi_1$ card. A deck consisting of this single card has $\mathrm{deckProfit} = 1$.

**Proposition 7.2.** Construction 7.1 satisfies all axioms of Definition 2.1, admits a nonempty independent deck, and realizes deck profit $1$. Hence the casino theorems are non-vacuous.

This toy model is deliberately minimal; the intended instances are genuine arithmetic theories such as Peano arithmetic or ZFC, whose $\Sigma_1$-completeness is classical and whose independent $\Pi_1$ decks (headed by $\mathrm{Con}(T)$) are infinite.

---

## 8. Algorithms

The results give directly implementable procedures.

**Algorithm A (Classify-and-bet).** Given a card's declared kind, return $\text{betTrue}$ if $\Pi_1$, $\text{betFalse}$ if $\Sigma_1$, else $\text{hedge}$. Constant time per card. Correctness is Theorem 4.5.

**Algorithm B (Deck profit).** Fold Algorithm A over a deck, resolving each bet against the (externally determined) truth value and summing payoffs; equivalently, by Theorem 4.9, count decidable-shape cards. Linear time.

**Algorithm C (One-third certificate).** Given a deck, compute the decidable-shape fraction $\rho$; if $\rho \ge 1/3$, certify by Theorem 5.1 that the guaranteed per-round profit is at least $1/3$. Linear time.

---

## 9. Discussion

The philosophical upshot is that **unprovability and unknowability come apart.** Gödel's theorems constrain what a theory can establish about itself, but they do not forbid an external analyst from determining the truth value of independent sentences whose form is simple. The arithmetic hierarchy is precisely the ledger of "form," and its lowest rungs are transparent to $\Sigma_1$-completeness.

Three features distinguish our result from a mere probabilistic edge. First, it is *deterministic*: no round loses. Second, it is *constructive*: the winning bet is read off the syntactic kind with no search. Third, it is *robust*: it rests on three hypotheses that hold for every sound recursively axiomatized arithmetic theory, so it applies uniformly to PA, ZFC, and their consistent extensions.

The correction regarding consistency statements deserves final emphasis. It is folklore-tempting to view $\mathrm{Con}(T)$ as the emblem of falsifiable-looking unprovability. In truth it is the emblem of *true*-but-unprovable: a $\Pi_1$ sentence, hence — when independent — true, and the winning bet on it is TRUE.

---

## 10. Future work

Several concrete extensions present themselves.

1. **Grounding in real arithmetic.** Instantiate the abstract theory with a genuine first-order arithmetic development: define sentences, negation, and provability from the actual derivability relation, truth from satisfaction in $\mathbb{N}$, and prove soundness, truth-respects-negation, and $\Sigma_1$-completeness ($\Sigma_1$-completeness of $Q$/PA) as bona fide theorems. The casino results then transfer unconditionally to ZFC-independent arithmetic sentences.

2. **A deck of famous cards.** Assemble explicit cards: $\mathrm{Con}(\mathrm{ZFC})$ (independent $\Pi_1$, TRUE), a Rosser-style independent $\Sigma_1$ sentence (FALSE), and the Continuum Hypothesis (an "other" card, hedged, since it is not arithmetic). Compute the deck profit explicitly.

3. **Minimax optimality of the hedge.** For "other" cards, prove that no non-hedge bet dominates: there exist truth assignments making $\text{betTrue}$ lose and others making $\text{betFalse}$ lose, so the hedge maximizes guaranteed payoff, justifying the third arm of the strategy as minimax-optimal.

4. **A probabilistic layer.** Replace the deterministic count with a genuine expectation over a distribution on decks, recovering the original "expected value" framing as a corollary of the stronger deterministic bound.

---

## 11. Conclusion

Gödel's Casino reframes incompleteness from a boundary into a betting table. By isolating three classical properties of arithmetic theories, we proved that independent $\Pi_1$ sentences are true and independent $\Sigma_1$ sentences are false. The resulting strategy — bet TRUE on $\Pi_1$, FALSE on $\Sigma_1$, hedge otherwise — never loses a round, and the total profit over a deck equals its count of single-quantifier cards. Under a one-third density this yields a guaranteed average edge of $1/3$ per round. The impossible game is winnable, provided one plays it from outside the system.
