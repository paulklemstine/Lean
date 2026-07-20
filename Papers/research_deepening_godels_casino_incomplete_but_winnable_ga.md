# Gödel’s Casino: Exact Bayesian Value, Regret, and a Finite No-Free-Lunch Theorem

**Aristotle**  
**July 20, 2026**

## Abstract

We study a finite Boolean betting game motivated by the distinction between logical undecidability and probabilistic uncertainty. A deck consists of statements with Boolean truth values; a player predicts each truth value and receives $+1$ for a correct prediction and $-1$ for an incorrect one. In the Bayesian model, card $i$ has rational marginal probability $q_i$ of being true. We prove that the cardwise threshold rule—predict true exactly when $q_i\geq \tfrac12$—is optimal and has exact expected value $\sum_i|2q_i-1|$. Hence the value is zero exactly for an entirely fair deck and is positive exactly when at least one marginal differs from one half. We derive an exact regret formula: disagreement with the threshold rule on card $i$ costs $2|2q_i-1|$, and this yields uniqueness whenever there are no ties. We then remove the probability model and allow arbitrary finite weighted mixtures of deterministic strategies. Complementing every truth value negates the mixed payoff, so every mixture has a world with nonpositive payoff; in particular, no randomized strategy guarantees a strict win in all worlds. The results require only additive payoffs and marginal probabilities, not independence. They clarify the roles of semantic truth, formal provability, subjective probability, and adversarial robustness in games built from undecidable statements.

## 1. Introduction

A mathematical statement may be true or false, provable or unprovable relative to a specified theory, and assigned a high or low probability by an agent. These classifications are related in practice but conceptually distinct. A betting game built from statements that are independent of a formal theory can easily blur them: the inability of the theory to settle a card may look like randomness, while randomness may look like an opportunity for profit.

This paper isolates the decision-theoretic core of such a game. The finite setting is deliberately elementary. Each card has a Boolean truth value. The player places a unit bet on every card, winning one unit for a correct prediction and losing one for an incorrect prediction. Two regimes are considered.

In the **Bayesian regime**, each card has a stated rational marginal probability of truth. The objective is to maximize expected additive payoff. Since expectation is additive, only the individual marginals matter: no independence hypothesis is used. The optimal strategy is a coordinatewise threshold rule, and its value is exactly the sum of the cards’ absolute biases. Beyond optimality, an exact regret identity records the cost of every nonoptimal choice.

In the **adversarial regime**, no probability law governs the world. The player may randomize among finitely many deterministic strategies, and we ask whether positive payoff can be guaranteed against every possible assignment of truth values. A complement symmetry makes this impossible. Every world is paired with the world obtained by reversing all truths, and the two payoffs are negatives of one another.

The central conclusions are:

1. logical independence alone does not imply a betting edge;
2. under given marginals, the exact edge is $\sum_i|2q_i-1|$;
3. nonoptimal decisions incur a completely additive, confidence-weighted regret;
4. without a probabilistic model, no finite randomized strategy wins strictly in every world.

The treatment is self-contained and uses finite sums over rational quantities throughout.

## 2. The finite Boolean casino

### 2.1. Decks, worlds, and strategies

Fix a nonnegative integer $n$. The deck has index set

$$I=\{1,2,\ldots,n\}.$$

A **world** is a function $t:I\to\{0,1\}$, where $t_i=1$ means card $i$ is true and $t_i=0$ means it is false. A **deterministic strategy** is a function $s:I\to\{0,1\}$, interpreted as a prediction for every card.

The unit payoff is

$$\nu(b,u)=\begin{cases}
1,&b=u,\\
-1,&b\ne u,
\end{cases}$$

for prediction $b$ and truth $u$. The total unit-stake payoff in world $t$ is

$$T(s,t)=\sum_{i\in I}\nu(s_i,t_i).$$

Thus $T(s,t)$ equals the number of correct predictions minus the number of incorrect predictions. If $k$ out of $n$ predictions are correct, then $T(s,t)=2k-n$.

The **complementary world** $\bar t$ is defined coordinatewise by

$$\bar t_i=1-t_i.$$

No logical relation among the cards is assumed in the abstract game. If a particular application imposes consistency constraints, the unrestricted world set can be replaced by an admissible subset, although the complement argument later requires that the relevant subset be closed under complementation.

### 2.2. Bayesian marginals

In the Bayesian model, card $i$ is assigned a rational number $q_i$, interpreted as its probability of being true. For a genuine probability interpretation one assumes $0\leq q_i\leq1$, although the algebraic identities below remain valid for rational inputs beyond this interval.

For one card with truth probability $q$, the expected payoff from predicting true is

$$q\cdot1+(1-q)(-1)=2q-1,$$

while the expected payoff from predicting false is

$$(1-q)\cdot1+q(-1)=1-2q.$$

Accordingly, define

$$E(q,b)=\begin{cases}
2q-1,&b=1,\\
1-2q,&b=0.
\end{cases}$$

For a vector $q=(q_i)_{i\in I}$ and strategy $s$, define the Bayesian expected payoff

$$B(q,s)=\sum_{i\in I}E(q_i,s_i).$$

This formula depends only on marginals. If the truths have any joint distribution with $\Pr(t_i=1)=q_i$, linearity of expectation gives the same expression, regardless of dependence among cards.

### 2.3. The Bayes threshold strategy

Define the **Bayes strategy** $s^{\star}$ by

$$s_i^{\star}=\begin{cases}
1,&q_i\geq\tfrac12,\\
0,&q_i<\tfrac12.
\end{cases}$$

The convention at $q_i=\tfrac12$ selects true, but both choices have expected payoff zero. The threshold divides positive from negative signed bias. Write

$$\beta_i=2q_i-1.$$

Then predicting true earns $\beta_i$ and predicting false earns $-\beta_i$.

## 3. One-card optimization

### Theorem 1 (one-card absolute-bias value)

For every rational $q$, the Bayes prediction has expected payoff

$$E(q,b^{\star})=|2q-1|.$$

Moreover, for each prediction $b\in\{0,1\}$,

$$E(q,b)\leq |2q-1|.$$

#### Proof sketch

If $q\geq\tfrac12$, then $2q-1\geq0$ and the Bayes prediction is true. Its payoff is $2q-1=|2q-1|$, whereas predicting false gives $1-2q=-|2q-1|$. If $q<\tfrac12$, then $2q-1<0$ and the Bayes prediction is false. Its payoff is $1-2q=|2q-1|$, while predicting true gives $-|2q-1|$. In either case, the larger of the two opposite quantities is the absolute value. $\square$

The theorem identifies $|2q-1|$ as the economically available information in a unit-stake Boolean card. It ranges from $0$ at a fair card to $1$ at certainty.

### Lemma 2 (one-card regret)

For every rational $q$ and prediction $b$, the regret relative to the Bayes prediction is

$$E(q,b^{\star})-E(q,b)=
\begin{cases}
0,&b=b^{\star},\\
2|2q-1|,&b\ne b^{\star}.
\end{cases}$$

#### Proof sketch

Agreement makes the two expected payoffs identical. Under disagreement there are only two predictions, so the alternative to the Bayes payoff $|2q-1|$ is its negative. The difference is therefore $|2q-1|-(-|2q-1|)=2|2q-1|$. $\square$

This lemma strengthens an inequality into an exact identity. It also shows that a wrong choice at a nearly fair card is less costly than a wrong choice at a strongly biased card.

## 4. Exact value of a finite deck

### Theorem 3 (exact Bayesian value)

For a finite deck with rational truth marginals $q_1,\ldots,q_n$, the Bayes strategy satisfies

$$B(q,s^{\star})=\sum_{i=1}^{n}|2q_i-1|.$$

This quantity is the maximum of $B(q,s)$ over all deterministic strategies $s$.

#### Proof sketch

Apply Theorem 1 separately to each card. The Bayes contribution on card $i$ is $|2q_i-1|$, so summing gives the displayed equality. For an arbitrary strategy $s$, Theorem 1 gives $E(q_i,s_i)\leq|2q_i-1|$ card by card. Summing these inequalities yields

$$B(q,s)\leq\sum_i|2q_i-1|=B(q,s^{\star}).$$

Thus the threshold strategy attains the global maximum. $\square$

The result reduces an optimization over $2^n$ strategies to $n$ independent sign tests. It also confirms that dependence among cards is immaterial for additive expected value: the proof uses no products of probabilities and no factorization of a joint law.

### Corollary 4 (zero-value characterization)

The optimal Bayesian value is zero if and only if every card is fair:

$$B(q,s^{\star})=0\quad\Longleftrightarrow\quad q_i=\frac12\text{ for every }i.$$

#### Proof sketch

Every summand $|2q_i-1|$ is nonnegative. A finite sum of nonnegative rational numbers is zero exactly when every summand is zero. The equation $|2q_i-1|=0$ is equivalent to $q_i=\tfrac12$. $\square$

### Corollary 5 (positive-edge characterization)

The optimal Bayesian value is strictly positive if and only if at least one card is biased:

$$B(q,s^{\star})>0\quad\Longleftrightarrow\quad \exists i\text{ such that }q_i\ne\frac12.$$

#### Proof sketch

If every card is fair, Corollary 4 gives value zero. If some card is biased, its absolute-bias term is strictly positive, while all other terms are nonnegative; hence the sum is positive. $\square$

These two corollaries express the main conceptual boundary. Undecidability relative to an axiom system is not one of the hypotheses and cannot replace a marginal probability. Once probabilities are specified, an expected advantage exists precisely when some probability departs from one half.

## 5. Exact regret and uniqueness

### Theorem 6 (exact deck regret decomposition)

For every deterministic strategy $s$,

$$B(q,s^{\star})-B(q,s)
=\sum_{i:s_i\ne s_i^{\star}}2|2q_i-1|.$$

Equivalently, with indicator notation,

$$B(q,s^{\star})-B(q,s)
=\sum_{i=1}^{n}2|2q_i-1|\,\mathbf 1\{s_i\ne s_i^{\star}\}.$$

#### Proof sketch

Subtract the two additive payoff expressions card by card. Lemma 2 says that each difference is zero on agreement and $2|2q_i-1|$ on disagreement. Summing these exact local differences proves the identity. $\square$

This formula gives more than the fact that regret is nonnegative. It identifies all sources of regret and assigns each a weight. If a strategy differs from the optimum on a set $D\subseteq I$, its regret is exactly

$$2\sum_{i\in D}|2q_i-1|.$$

Thus Hamming distance from the optimum is insufficient by itself: two strategies can disagree on the same number of cards while having very different regret because the cards carry different biases.

### Theorem 7 (uniqueness without ties)

Assume $q_i\ne\tfrac12$ for every card $i$. Then the Bayes strategy is the unique deterministic strategy maximizing expected payoff.

#### Proof sketch

Let $s\ne s^{\star}$. Then there is at least one index $i$ with $s_i\ne s_i^{\star}$. Since $q_i\ne\tfrac12$, the corresponding term $2|2q_i-1|$ in Theorem 6 is strictly positive. Every other regret term is nonnegative, so

$$B(q,s^{\star})-B(q,s)>0.$$

Hence $s$ is not optimal. $\square$

The no-tie condition is sharp. If $q_i=\tfrac12$, either prediction on card $i$ contributes zero, so changing only that coordinate creates another optimum. More generally, all optimal strategies agree with the Bayes strategy on biased cards and may choose freely on fair cards.

## 6. Numerical illustration

Consider five cards with marginal probabilities

$$q=\left(\frac12,\frac23,\frac14,\frac9{10},0\right).$$

The threshold strategy is

$$s^{\star}=(1,1,0,1,0).$$

The signed biases $2q_i-1$ are

$$0,\quad \frac13,\quad -\frac12,\quad \frac45,\quad -1,$$

and the absolute biases are

$$0,\quad \frac13,\quad \frac12,\quad \frac45,\quad 1.$$

The exact optimal value is

$$V(q)=\frac13+\frac12+\frac45+1=\frac{79}{30}.$$

Suppose a player instead uses

$$s=(0,1,1,1,0).$$

This differs from $s^{\star}$ on cards $1$ and $3$. Card $1$ is fair and contributes no regret. Card $3$ has absolute bias $\tfrac12$, so the regret is

$$2\cdot0+2\cdot\frac12=1.$$

Consequently the alternative strategy has expected payoff

$$\frac{79}{30}-1=\frac{49}{30}.$$

This example demonstrates both tie freedom and confidence-weighted error.

## 7. Algorithms

### 7.1. Optimal strategy and exact value

Given rational marginals $q_1,\ldots,q_n$, inspect each card once. Predict true when $q_i\geq\tfrac12$ and false otherwise; add $|2q_i-1|$ to an accumulator. This returns both an optimal strategy and its exact expected payoff.

The running time is $O(n)$ arithmetic comparisons and additions. The strategy output occupies $O(n)$ space; excluding output, the value accumulator requires $O(1)$ storage. With exact rational arithmetic, bit complexity also depends on numerator and denominator sizes, but the number of cardwise operations remains linear.

### 7.2. Exact regret audit

Given $q$ and a candidate strategy $s$, reconstruct the threshold decision on each card. Whenever $s_i$ differs, add $2|2q_i-1|$. The result equals the difference between optimal and candidate expected payoff by Theorem 6. The algorithm runs in $O(n)$ cardwise operations and can additionally report a per-card regret table.

### 7.3. Complement witness against uniform victory

Given any finite weighted mixture and any chosen world $t$, evaluate its mixed payoff $M(t)$. If $M(t)\leq0$, return $t$ as a witness. Otherwise return $\bar t$, whose payoff is $-M(t)<0$. This witness procedure does not search the $2^n$ worlds; after one evaluation, it uses a single coordinatewise complement.

## 8. Finite mixtures and adversarial worlds

### 8.1. Weighted mixed strategies

Let $s^{(1)},\ldots,s^{(m)}$ be deterministic strategies and let $w_1,\ldots,w_m$ be rational weights. Define the weighted mixed payoff in world $t$ by

$$M(t)=\sum_{j=1}^{m}w_jT(s^{(j)},t).$$

When $w_j\geq0$ and $\sum_jw_j=1$, this is the expected payoff of a randomized strategy that chooses $s^{(j)}$ with probability $w_j$. The algebraic symmetry below is stronger: it holds for arbitrary rational weights, without positivity or normalization.

### Lemma 8 (unit complement reversal)

For every prediction $b$ and truth value $u$,

$$\nu(b,1-u)=-\nu(b,u).$$

#### Proof sketch

If $b=u$, the original payoff is $1$, while $b\ne1-u$, so the complemented payoff is $-1$. If $b\ne u$, then for Boolean values $b=1-u$, and the payoffs reverse in the other direction. $\square$

### Theorem 9 (mixed-payoff complement reversal)

For every finite weighted mixture and every world $t$,

$$M(\bar t)=-M(t).$$

#### Proof sketch

Lemma 8 implies

$$T(s^{(j)},\bar t)=\sum_i\nu(s_i^{(j)},1-t_i)
=-\sum_i\nu(s_i^{(j)},t_i)
=-T(s^{(j)},t).$$

Multiplying by $w_j$ and summing over $j$ gives

$$M(\bar t)=\sum_jw_j[-T(s^{(j)},t)]=-M(t).$$

No assumption on the signs or sum of the weights enters the calculation. $\square$

### Theorem 10 (finite mixed no-free-lunch theorem)

For every finite weighted mixture of deterministic strategies, there exists a world $t$ such that

$$M(t)\leq0.$$

#### Proof sketch

Choose any world $u$. By Theorem 9, the paired payoffs are $M(u)$ and $M(\bar u)=-M(u)$. If $M(u)\leq0$, take $t=u$. Otherwise $M(u)>0$, and then $M(\bar u)<0$, so take $t=\bar u$. $\square$

### Corollary 11 (impossibility of a uniform strict win)

No finite randomized strategy satisfies

$$M(t)>0$$

for every possible world $t$.

#### Proof sketch

A randomized strategy is a special case of a finite weighted mixture. Theorem 10 supplies a world with nonpositive payoff, contradicting uniform strict positivity. $\square$

The theorem establishes an upper-bound obstruction in a minimax interpretation. If the player is evaluated against all Boolean worlds, no randomization guarantees a positive amount. A normalized adversary can realize zero expected payoff by placing equal probability on a world and its complement, because their mixed payoffs average to zero.

## 9. Interpretation and applications

### 9.1. Logical independence is not probabilistic fairness

Suppose a card carries a sentence independent of a chosen formal theory. Independence means neither the sentence nor its negation is derivable in that theory, under suitable consistency assumptions. It does not mean that the sentence is generated by a fair coin, nor does it entail $q=\tfrac12$. Assigning a probability requires an additional epistemic or statistical model.

The exact value theorem therefore separates two claims that are often conflated. “The theory cannot decide this sentence” is syntactic. “My probability that the sentence is true is $q$” is probabilistic. “Predicting true has positive expected return” is decision-theoretic and follows exactly when $q>\tfrac12$ under the stated payoff rule.

### 9.2. Binary classification

The game is mathematically identical to cost-symmetric binary classification with known class probabilities. The Bayes classifier thresholds posterior probability at one half. Its cardwise advantage is the absolute margin $|2q_i-1|$, and the regret of choosing the wrong label is twice that margin. The decomposition explains why errors on confident examples matter more than errors near the decision boundary.

### 9.3. Forecast aggregation and correlated events

Because the objective is additive, expected payoff can be calculated from marginal probabilities even when events are highly correlated. This is useful in forecast portfolios: if each binary forecast is scored independently by the symmetric unit payoff and stakes are fixed, dependence changes the variance and tail behavior of total payoff but not its expectation. Risk-sensitive objectives would require the joint distribution, whereas the present value theorem does not.

### 9.4. Robust decision-making

The complement theorem is a finite robust-optimization principle. If the uncertainty set contains every Boolean world and is closed under global complementation, an antisymmetric payoff cannot be strictly positive throughout that set. Similar arguments arise whenever an involution sends gains to losses. The proof is elementary but structurally powerful: it replaces exhaustive adversarial search by pairing.

## 10. Limitations

The model uses unit stakes and additive payoff. Unequal stakes change the value to a weighted sum of absolute biases. Transaction costs introduce an abstention region. Proper scoring rules permit probability reports rather than Boolean predictions and lead to different regret geometries.

The Bayesian results optimize expected payoff, not variance, drawdown, or utility. Correlations among cards do not affect expectation, but they can strongly affect risk. A risk-averse player may therefore need a joint law even though the expected-value optimizer does not.

The adversarial theorem ranges over all Boolean worlds. In logical applications, not every assignment of truth values to related sentences is semantically possible. Complement closure can also fail. A restricted-world analysis must account for consistency relations and may have a different minimax value.

Finally, the game treats probabilities as inputs. It does not prescribe how probabilities for undecidable statements should be elicited, calibrated, or justified.

## 11. Future work

Several extensions follow naturally. First, one can place the cards on a finite joint probability space and prove directly that additive expected payoff depends only on marginals, while studying how dependence affects risk. Second, Boolean bets can be replaced by probability reports scored with Brier or logarithmic rules, making truthful reporting optimal and regret a divergence. Third, a sequential model can reveal proofs or refutations between rounds and compare adapted strategies using conditional probabilities.

Abstention and transaction costs should create a threshold condition of the form $|2q_i-1|>c$, where $c$ is the cost of wagering. A more explicit logical interface should separately encode truth, provability, and probability, identifying exactly which assumptions provide undecidable cards and which provide an edge. On the adversarial side, probability simplices for both players and worlds can yield a full finite minimax equality, with a uniform distribution over a complementary pair attaining zero against any fixed mixture. Finally, countably infinite decks require summability and integrability conditions for the exact value and regret formulas.

## 12. Reproducibility of the calculations

All numerical claims in this model can be reproduced with exact rational arithmetic. For each card, one computes the signed bias $2q_i-1$, selects its sign, and adds its absolute value. Candidate-strategy regret is obtained by adding twice the absolute bias only at mismatched coordinates. Mixed-strategy complement checks require evaluating one world and then negating the result for its complement. These procedures avoid floating-point ambiguity and scale linearly with the deck size, apart from the cost of exact integer arithmetic in rational numerators and denominators.

## 13. Conclusion

The finite Boolean casino has two sharply different answers, depending on what information is available. Given marginal probabilities, it is solvable card by card: predict the more likely truth value, obtain exact expected value

$$\sum_{i=1}^{n}|2q_i-1|,$$

and pay exact regret

$$\sum_{i:s_i\ne s_i^{\star}}2|2q_i-1|$$

for deviations. The edge vanishes precisely on an entirely fair deck, becomes positive as soon as one card is biased, and determines a unique strategy when no card is tied.

Without a probability model, randomization cannot force profit against all worlds. Global complementation negates every mixed payoff, ensuring a nonpositive witness for every finite mixture. The combined theory gives a precise account of what incompleteness does and does not buy: undecidability supplies an interesting source of cards, but only probabilistic bias supplies expected value, while adversarial symmetry blocks a universal win.