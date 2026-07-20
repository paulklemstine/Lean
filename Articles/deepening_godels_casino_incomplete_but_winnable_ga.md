# Gödel’s Casino: Incomplete but Winnable Games

Imagine a casino with no dice, roulette wheels, or shuffled cards. Instead, each card bears a mathematical sentence. The card is either true or false, and the player must bet on which. Some cards may describe ordinary arithmetic facts; others may be chosen because a favored axiomatic theory can neither prove nor refute them. The room seems to promise a paradoxical advantage: if the house cannot settle a sentence by proof, perhaps the uncertainty itself can be exploited.

The mathematics says something subtler. Logical independence does not by itself create a profitable bet. Profit comes from probability, and specifically from bias away from an even chance. Once that distinction is made, the casino admits a complete theory: an optimal rule, an exact formula for its value, a precise price for every mistake, and a worst-case theorem showing that no randomized player can win in every possible world.

## The rules of the room

Take a finite deck of $n$ cards. A **world** assigns each card a truth value, true or false. A **deterministic strategy** predicts one of those two values for every card. Every wager has unit stake: a correct prediction pays $+1$, while an incorrect prediction pays $-1$. Thus, if $s_i$ is the prediction and $t_i$ is the truth on card $i$, the one-card payoff is

$$
u(s_i,t_i)=\begin{cases}1,&s_i=t_i,\\-1,&s_i\ne t_i.\end{cases}$$

The total payoff is the additive score

$$T(s,t)=\sum_{i=1}^{n}\nu(s_i,t_i).$$

A world has a natural mirror image: its **complement**, denoted $\bar t$, reverses every truth value. This simple symmetry will eventually defeat every claim of a guaranteed win.

There are two different ways to understand the game. In the Bayesian version, each card $i$ has a rational probability $q_i$ of being true. These numbers are marginal probabilities: they say how likely each individual card is to be true, without asserting that different cards are independent. In the adversarial version, no probability law over worlds is assumed; the player asks whether one strategy can profit whatever the truths turn out to be.

For one Bayesian card, predicting true gives expected payoff

$$q_i-(1-q_i)=2q_i-1,$$

while predicting false gives

$$(1-q_i)-q_i=1-2q_i.$$

Call this quantity $E(q_i,b)$ when the prediction is $b$. The expected deck payoff of a strategy $s$ is therefore

$$B(q,s)=\sum_{i=1}^{n}E(q_i,s_i).$$

The **Bayes strategy** predicts true exactly when $q_i\geq \tfrac12$ and predicts false otherwise. At a tie, it predicts true, although either choice has the same value.

## The absolute-bias law

The central observation is visible on one card. The two possible expected returns are opposites, $2q-1$ and $-(2q-1)$. Choosing the larger one produces their absolute magnitude.

**One-Card Value Theorem.** For every rational $q$, the Bayes prediction has expected payoff $|2q-1|$. No deterministic prediction has expected payoff greater than $|2q-1|$.

The proof is a two-case comparison. If $q\geq \tfrac12$, predicting true earns $2q-1=|2q-1|$. If $q<\tfrac12$, predicting false earns $1-2q=|2q-1|$. The alternative prediction earns the negative of that amount.

Because deck payoffs add, the one-card law immediately scales up.

**Exact Bayesian Value Theorem.** For a finite deck with truth probabilities $q_1,\ldots,q_n$, the maximum expected payoff among deterministic strategies is

$$V(q)=\sum_{i=1}^{n}|2q_i-1|,$$

and the Bayes strategy attains it.

**Optimality Theorem.** For every deterministic strategy $s$,

$$B(q,s)\leq B(q,s^{\star}),$$

where $s^{\star}$ is the Bayes strategy.

The proof needs no global search through the $2^n$ possible strategies. The one-card upper bounds can simply be summed. This makes the optimal decision local: inspect each $q_i$, compare it with $\tfrac12$, and choose the more likely truth value. The resulting algorithm takes linear time in the number of cards and constant extra space beyond its output.

This formula also identifies exactly when the casino has value.

**Fair-Deck Theorem.** The optimal expected payoff is zero if and only if every card is fair, meaning $q_i=\tfrac12$ for all $i$.

Every term $|2q_i-1|$ is nonnegative. Their sum can vanish only when each term vanishes, which is precisely the fair-card condition.

**Positive-Edge Theorem.** The optimal expected payoff is strictly positive if and only if at least one card satisfies $q_i\ne\tfrac12$.

This is the same argument viewed from the other side: one positive absolute bias makes the whole nonnegative sum positive.

Here lies the lesson for incompleteness. A sentence may be undecidable in a chosen theory, yet that syntactic fact does not assign it a probability. Even after a probability is supplied by some external model of belief or uncertainty, the sentence offers no expected edge when its probability is exactly one half. An edge appears only after a genuine probabilistic asymmetry has been justified.

## The exact cost of being wrong

Optimality tells us which strategy wins, but a stronger result measures every departure from it. On a card with probability $q$, agreeing with the Bayes prediction costs nothing. Disagreeing flips the expected return from $|2q-1|$ to $-|2q-1|$, a loss of twice the bias.

**One-Card Regret Theorem.** If $b^{\star}$ is the Bayes prediction, then

$$E(q,b^{\star})-E(q,b)=\begin{cases}0,&b=b^{\star},\\2|2q-1|,&b\ne b^{\star}.
\end{cases}$$

Summing this identity gives a complete error ledger.

**Exact Regret Decomposition.** For every strategy $s$,

$$B(q,s^{\star})-B(q,s)=\sum_{i:s_i\ne s_i^{\star}}2|2q_i-1|.$$

The proof is simply the one-card identity summed over the deck. Yet the interpretation is rich. Mistakes near a tie are cheap, because little probabilistic information separates the choices. Mistakes on highly biased cards are expensive. The decomposition resembles weighted classification loss: the decision boundary is $\tfrac12$, and confidence determines the penalty.

It also settles uniqueness.

**Unique-Optimum Theorem.** If no card is fair, so $q_i\ne\tfrac12$ for every $i$, then the Bayes strategy is the unique deterministic strategy attaining the maximum expected payoff.

Indeed, any different strategy disagrees on at least one card. With no ties, that card has positive absolute bias, so the regret sum is strictly positive. If fair cards do exist, uniqueness can fail exactly there: either prediction on a fair card earns zero.

Consider the five-card deck

$$\left(\frac12,\frac23,\frac14,\frac9{10},0\right).$$

The Bayes predictions are true, true, false, true, false. The absolute biases are

$$0,\quad \frac13,\quad \frac12,\quad \frac45,\quad 1,$$

so the exact expected payoff is

$$0+\frac13+\frac12+\frac45+1=\frac{79}{30}.$$

The first card illustrates a tie; the final card is certain and contributes the maximum one unit of expected profit.

## Why randomization cannot conquer every world

Bayesian optimization assumes probabilities. What if the player seeks a strategy that wins regardless of the actual truth assignment? Allow the player every finite randomization: choose deterministic strategies $s^{(1)},\ldots,s^{(m)}$ with rational weights $w_1,\ldots,w_m$. For a world $t$, define the weighted mixed payoff

$$M(t)=\sum_{j=1}^{m}w_jT(s^{(j)},t).$$

Probability mixtures are included when the weights are nonnegative and sum to one, but the next symmetry does not even require those restrictions.

**Complement Reversal Theorem.** For every finite weighted mixture and every world $t$,

$$M(\bar t)=-M(t).$$

To prove it, observe that reversing a card’s truth changes a correct prediction into an incorrect one and vice versa. Therefore $\nu(b,\neg u)=-\nu(b,u)$. Summing first over cards and then over weighted strategies preserves the sign reversal.

**Mixed No-Free-Lunch Theorem.** Every finite weighted mixture of deterministic strategies has at least one world in which its mixed payoff is nonpositive.

Choose any world $t$ and pair it with $\bar t$. Their payoffs are $a$ and $-a$. At least one is at most zero. This proves the claim.

**No Uniform Strict-Win Corollary.** No finite randomized strategy can have strictly positive expected payoff in every possible truth assignment.

Randomization can manage risk under a distribution, but it cannot break complement symmetry. For every imagined world in which the strategy prospers, the fully reversed world carries the opposite payoff.

## The boundary between logic and probability

Gödel’s incompleteness theorem concerns what follows from axioms. The casino concerns how payoffs respond to beliefs or to adversarial worlds. Truth, provability, and probability are three distinct notions. A statement can be true but unprovable in a theory; a probability assessment can be well calibrated or poorly calibrated; a bet can be profitable or unprofitable under that assessment. None of these facts automatically substitutes for another.

That separation is the real architecture of Gödel’s Casino. Under stated marginal probabilities, the game is completely winnable in the Bayesian sense: predict the more likely value, and earn the sum of absolute biases in expectation. Without such probabilistic structure, the adversarial game is unwinnable in the strongest uniform sense: every mixed strategy meets a complementary world that denies it a strict gain.

The same mathematics appears far beyond foundational logic, and this is exactly why the little imagined casino matters. A medical test, a weather forecast, and a spam filter all force binary decisions under uncertainty. In each case the rational threshold is one half when rewards and penalties are symmetric, and the distance from that threshold measures the value of information. Gödel’s Casino gives this familiar decision rule an unusual stage, where the cards dramatize how little follows from uncertainty alone.

The casino is therefore not a machine for converting undecidability into money. It is a clean laboratory for seeing what information is worth. Bias has an exact price, error has an exact regret, ties explain nonuniqueness, and symmetry marks the limit of strategy. In a room decorated with the mysteries of logic, the final accounting is governed by a simple rule: uncertainty alone is not an edge.