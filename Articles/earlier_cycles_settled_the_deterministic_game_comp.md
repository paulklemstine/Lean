# Gödel’s Casino: When the Best Bet Is No Bet

Imagine a casino that does not spin roulette wheels or deal cards. Instead, it presents a statement that is either true or false. You may bet on truth, bet on falsehood, or—if the house permits it—walk away. A correct bet earns $a$ units; an incorrect bet loses $b$ units. You have a probability model for the possible worlds in which the statement might be evaluated, but no oracle telling you which world is actual.

This spare thought experiment captures a surprisingly broad family of decisions. A medical test predicts disease or no disease. A fraud detector accepts or rejects a transaction. A forecaster announces rain or no rain. A trader chooses whether an event will occur. In each case, being right and being wrong may have unequal consequences. The central question is not merely which outcome is more likely. It is whether the evidence is strong enough to justify acting at the offered odds.

The answer has a clean geometry. Every randomized strategy lies on a straight line between two pure bets. Consequently, randomization cannot outperform the better endpoint. Under normalized probabilities, profitable betting is possible exactly outside an explicit interval. Inside that interval, abstention is optimal.

## Worlds, truth, and two piles of probability

Let $W$ be a finite collection of possible worlds. In each world $\omega\in W$, a statement $s$ has a Boolean value $s(\omega)$: true or false. Assign a weight $\mu(\omega)$ to each world. For an ordinary probability model these weights are nonnegative and sum to $1$, though the basic algebraic identities need only finite rational weights.

All of the worlds can be sorted into two piles. Their total weights are

$$
T=\sum_{\omega:\,s(\omega)=\mathrm{true}}\mu(\omega),
\qquad
F=\sum_{\omega:\,s(\omega)=\mathrm{false}}\mu(\omega).
$$

These piles partition the entire model, so

$$
T+F=\sum_{\omega\in W}\mu(\omega).
$$

When the prior is normalized, $T+F=1$. Writing $\pi=T$, we then have $F=1-\pi$. The entire decision problem collapses to this single number $\pi$, the probability that the statement is true. The internal complexity of the worlds matters only through how much total probability falls on either side of the truth divide.

## Unequal rewards change the threshold

Suppose a correct bet earns $a$ and an incorrect bet loses $b$. If you always bet true, your expected payoff is

$$
V_{\mathrm{true}}=aT-bF.
$$

If you always bet false, it is

$$
V_{\mathrm{false}}=aF-bT.
$$

For a normalized prior, these become

$$
V_{\mathrm{true}}=(a+b)\pi-b,
\qquad
V_{\mathrm{false}}=a-(a+b)\pi.
$$

These formulas expose the break-even probabilities. Assume $a+b>0$. Betting true is profitable precisely when

$$
\pi>\frac{b}{a+b},
$$

while betting false is profitable precisely when

$$
\pi<\frac{a}{a+b}.
$$

The thresholds are not necessarily centered at $1/2$. If winning earns much more than losing costs, a bet can be worthwhile even when it is less likely to be correct. If errors are expensive, evidence must be correspondingly stronger.

This is a basic lesson of decision theory: probability is not action. A probability describes uncertainty; a payoff table converts uncertainty into a decision.

## The straight line behind every mixed strategy

Perhaps a clever player can improve matters by randomizing—betting true with probability $r$ and false with probability $1-r$, where $0\le r\le1$. In a world where the statement is true, the expected payoff is

$$
(a+b)r-b.
$$

In a world where it is false, the expected payoff is

$$
a-(a+b)r.
$$

After averaging over worlds, the randomized value is

$$
V(r)=\big((a+b)r-b\big)T+\big(a-(a+b)r\big)F.
$$

The key theorem is the **Affine Randomization Theorem**:

> For every finite weighted world model and every $r\in[0,1]$, the expected payoff of betting true with probability $r$ is
> $$
> V(r)=rV_{\mathrm{true}}+(1-r)V_{\mathrm{false}}.
> $$

The proof is direct: expand the right-hand side, collect the true-world and false-world terms, and recover the displayed formula for $V(r)$. But its meaning is more important than its algebra. As $r$ moves from $0$ to $1$, the expected payoff moves along the line segment joining the pure-false value and the pure-true value.

A point inside a line segment cannot sit above both endpoints. Therefore:

> **Pure-Strategy Optimality Theorem.** Every admissible randomized strategy satisfies
> $$
> V(r)\le \max\{V_{\mathrm{false}},V_{\mathrm{true}}\}.
> $$
> Thus randomization cannot beat the better pure strategy.

This does not say randomization is useless in every game. Mixed strategies are indispensable when an opponent reacts to predictable behavior. Here, however, the prior and payoff table are fixed, and the random choice merely averages two already available actions. There is no strategic opponent observing the coin toss and changing the world in response.

A sharper consequence follows immediately:

> **Edge Equivalence Theorem.** A randomized strategy with positive expected payoff exists if and only if at least one of the two pure bets has positive expected payoff.

If a pure bet has an edge, choose it. Conversely, if a randomized bet is positive, the line-segment bound forces at least one endpoint to be positive. Randomization cannot manufacture an advantage absent from both endpoints.

## The no-bet interval

Combining the endpoint formulas with edge equivalence gives the main threshold result:

> **Sharp Profitability Theorem.** For a normalized prior with $a+b>0$, some randomized Boolean bet has positive expected payoff if and only if
> $$
> \pi<\frac{a}{a+b}
> \quad\text{or}\quad
> \pi>\frac{b}{a+b}.
> $$

Equivalently, when both endpoints are ordered in the usual way, there is no profitable bet in the interval bounded by $a/(a+b)$ and $b/(a+b)$. More generally, the theorem’s disjunction is the exact statement and remains meaningful for any rational $a$ and $b$ satisfying $a+b>0$.

Consider symmetric stakes, $a=b=1$. Both thresholds equal $1/2$. Unless one side is more likely, neither bet has positive expectation. With $a=1$ and $b=2$, a correct prediction earns only one unit while an error costs two. Betting true requires $\pi>2/3$, and betting false requires $\pi<1/3$. The middle interval $[1/3,2/3]$ is a genuine region of inaction.

Now reverse the asymmetry: $a=2$ and $b=1$. Betting true is profitable for $\pi>1/3$, while betting false is profitable for $\pi<2/3$. In the overlap, both bets can have positive expectation. That is not a paradox: this payoff table is generous enough that a correct bet gains twice what an incorrect one loses. If the casino repeatedly offers such terms without hidden costs, the offer itself carries positive value.

## The mathematics of walking away

Real decision systems often include a third action: defer, reject, request more evidence, or simply pass. Give abstention payoff $0$. The optimal value is then

$$
V_{\mathrm{pass}}^*=\max\{0,V_{\mathrm{false}},V_{\mathrm{true}}\}.
$$

This yields the **Abstention Value Theorem**:

> Allowing a zero-payoff pass guarantees a nonnegative optimal value. If both pure bets have nonpositive expected payoff, abstention is optimal and the value is exactly $0$. Every randomized mixture of the two bets is bounded above by this abstention value.

The proof has three steps. First, $0$ is one of the candidates in the maximum, so the value cannot be negative. Second, if both betting values are at most $0$, their maximum with $0$ is $0$. Third, every randomized betting value is bounded by the better pure bet, which is itself bounded by the maximum that also includes abstention.

This simple theorem explains why selective prediction can outperform compulsory prediction. A classifier forced to label every ambiguous case may incur avoidable loss. A system allowed to defer uncertain cases can protect itself whenever neither label clears its payoff-adjusted threshold. The point is not that passing creates profit; it prevents a negative-value action from being mistaken for an obligation.

## Four snapshots

The formulas can be read without simulation.

With $a=b=1$ and $\pi=1/2$, both pure values are $0$, every mixture also has value $0$, and passing changes nothing.

With $a=2$, $b=1$, and $\pi=1/3$, the false bet has value

$$
2-3\cdot\frac13=1,
$$

while the true bet breaks even. The optimal action is false, with value $1$.

At $a=2$, $b=1$, and $\pi=2/3$, the roles reverse: false breaks even and true has value $1$.

Finally, with $a=1$, $b=2$, and $\pi=1/2$, both bets have value $-1/2$. Randomization only averages two losses, so abstention, worth $0$, is uniquely sensible in value terms.

## What the casino teaches

The model’s deepest insight is compression. A potentially intricate space of worlds is reduced to two masses, $T$ and $F$. A continuum of randomized strategies is reduced to two endpoint values. A difficult-sounding search for the best probability $r$ becomes a three-way comparison: bet false, bet true, or pass.

The result also clarifies the relation between information and incentives. Evidence supplies $\pi$. The contract supplies $a$ and $b$. Neither alone determines the decision. An apparent informational edge may be too weak for punitive odds, while favorable odds may justify action under substantial uncertainty.

In medicine, $b$ can represent the harm of a false diagnosis and $a$ the benefit of a correct intervention. In automated moderation, the two errors affect different people and carry different costs. In forecasting markets, quoted prices encode asymmetric gains and losses. In all these settings, the relevant question is not “Is the event more likely than not?” but “Does its probability cross the threshold implied by the consequences?”

Randomness does not blur that threshold into something better. It traces the straight line already determined by the two pure choices. And when neither endpoint is good enough, the mathematics gives a precise verdict that is easy to overlook in a culture of constant prediction: sometimes the optimal move is not to play.