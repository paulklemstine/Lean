# Gödel’s Casino: Incomplete but Winnable Games?

## The wager behind undecidability

Imagine a casino with no roulette wheel, no cards in the ordinary sense, and no croupier calling red or black. Instead, the house displays a mathematical sentence. You must bet **true** or **false**. If your prediction agrees with the world in which the sentence is evaluated, you win one unit; otherwise, you lose one.

The first card might bear the Continuum Hypothesis, the famous claim that there is no size of infinity strictly between the integers and the real numbers. Standard set theory cannot decide it: there are mathematical universes in which it holds and others in which it fails. Later cards might concern consistency statements or other propositions whose status is not settled by a chosen collection of axioms.

It is tempting to see a loophole. If incompleteness leaves so many propositions unsettled, perhaps a clever bettor could turn that uncertainty into profit. One might classify statements by logical form, trust provable existential claims, oppose certain universal claims, and favor conservative extensions when neither side is derivable. Could undecidability itself become an edge?

The answer is both sharper and more useful than a simple yes or no. **Logical independence alone creates no profit.** A positive expected return appears exactly when the bettor predicts correctly more than half the time, after probabilities are supplied. If every card can be predicted with probability at least $2/3$, then the expected profit is at least $1/3$ per card. But independence, by itself, does not provide that $2/3$ accuracy.

That distinction—between logical uncertainty and probabilistic advantage—is the central lesson of Gödel’s Casino.

## The simplest possible betting table

A card has a truth value, either true or false. A strategy assigns a prediction to every card. For a unit bet, define the payoff by

$$
X=\begin{cases}
+1,&\text{if the prediction is correct},\\
-1,&\text{if the prediction is incorrect}.
\end{cases}
$$

For $n$ cards, the total payoff is the sum

$$
T=X_1+X_2+\cdots+X_n.
$$

This innocent definition immediately exposes a no-free-lunch principle. Fix any deterministic strategy and any possible world—that is, any assignment of true or false to all $n$ cards. Now construct the complementary world by reversing every truth value. Every prediction that was right becomes wrong, and every prediction that was wrong becomes right. Therefore every $+1$ becomes $-1$, and vice versa.

The **Complementary-World Theorem** says that if the strategy earns $T$ in one world, then it earns exactly $-T$ in the complementary world.

That symmetry has several consequences. No fixed deterministic strategy can earn a strictly positive amount in both a world and its complement. Hence every strategy has at least one possible world in which its payoff is nonpositive. More dramatically, the house can choose each truth value to be the opposite of the corresponding prediction, forcing the exact worst-case payoff $-n$. Conversely, if every truth value agrees with the predictions, the payoff is the exact best case $n$.

Averaging a world and its complement always gives zero:

$$
\frac{T+(-T)}{2}=0.
$$

So if the casino treats complementary worlds symmetrically, no deterministic prediction rule has an automatic advantage. The range from $-n$ to $n$ is not a technical nuisance; it is the full geometry of the game.

## Where expectation enters

Real casinos are not judged by whether one lucky path exists. They are judged by expectation. Suppose the bettor’s prediction on card $i$ is correct with probability $p_i$. The expected payoff on that card is

$$
p_i(+1)+(1-p_i)(-1)=2p_i-1.
$$

For $n$ cards, linearity of expectation gives the **Expected-Payoff Formula**:

$$
\mathbb{E}[T]=\sum_{i=1}^{n}(2p_i-1)
=2\sum_{i=1}^{n}p_i-n.
$$

No independence assumption is required for this formula. The cards may be correlated in elaborate ways; only their individual success probabilities matter for the mean.

The formula yields the sharp criterion for a favorable game:

$$
\mathbb{E}[T]>0
\quad\Longleftrightarrow\quad
\sum_{i=1}^{n}p_i>\frac{n}{2}.
$$

In words, **expected profit is positive exactly when aggregate predictive accuracy exceeds one half**. Not when the statements are profound. Not when they are independent of an axiom system. Not when their logical forms look promising. The threshold is a familiar one: the bettor must possess information that beats a fair guess.

This is the casino’s break-even line. Every proposed strategy must eventually answer one empirical or mathematical question: why should its total success probability exceed $n/2$?

## The one-third promise—and its real assumption

Suppose each card can be predicted correctly with probability at least some common value $q$. Then

$$
\sum_{i=1}^{n}p_i\ge nq,
$$

so the expected payoff obeys the **Uniform-Accuracy Bound**

$$
\mathbb{E}[T]\ge n(2q-1).
$$

Set $q=2/3$. The bound becomes

$$
\mathbb{E}[T]\ge \frac{n}{3}.
$$

This is the mathematically sound version of the casino’s enticing promise: accuracy of at least $2/3$ on every card guarantees expected profit of at least $1/3$ per round. For $1{,}000$ cards, the expected profit is at least

$$
\frac{1000}{3}\approx333.33.
$$

If every card has success probability exactly $2/3$, then the expected profit is exactly $1000/3$, not merely bounded below by it.

The arithmetic is impeccable, but its interpretation matters. The conclusion is conditional. It begins with a $2/3$ prediction guarantee; it does not manufacture that guarantee from incompleteness. To claim that one third of all arithmetic statements are decidable would require a precise encoding of formulas, a notion of formula size, a sampling distribution, and a proved density theorem. The arithmetic hierarchy classifies formulas by quantifier complexity, but classification alone supplies no universal fraction of decidable cases.

## Known cards, unresolved cards

A second calculation makes the distinction vivid. Suppose $d$ cards are known with certainty, while $u$ unresolved cards are guessed fairly. A known card has $p_i=1$ and expected payoff $1$. A fair guess has $p_i=1/2$ and expected payoff $0$. Thus

$$
\mathbb{E}[T]
=d\cdot1+u\cdot0=d.
$$

This is the **Known-and-Fair Theorem**: certain knowledge contributes one expected unit per card, while unresolved fair guesses contribute nothing.

Uncertainty is therefore not a resource by itself. It is more like empty space in a balance sheet: it may conceal opportunity, but it records no profit until some asymmetry is identified. If a theorem, heuristic, data source, or structural principle raises the chance of a correct prediction above $1/2$, then the uncertainty becomes actionable. Without such an edge, it remains neutral.

The same point appears in a finite space of possible worlds. A statement true in every world can safely be backed as true, earning one unit. A statement false in every world can safely be backed as false, also earning one unit. But a balanced statement—true in exactly half the equally weighted worlds and false in the other half—has optimal expected profit zero. On a two-world space, the simplest statement that is true in one world and false in the other already defeats any universal claim of a $1/3$ expected return.

## Independence is not probability

Why is the original intuition so seductive? Because “undecidable” sounds like “random.” Yet the words belong to different languages.

Logical independence is relative to an axiom system. It says that neither a statement nor its negation can be derived from those axioms, assuming the usual consistency conditions. Probability requires additional structure: a sample space, a distribution, and a rule explaining what counts as the realized outcome. A proposition may vary between models without those models arriving with natural numerical weights.

Even settlement needs care. If a statement is true in one mathematical universe and false in another, which universe determines the casino’s payout? A distinguished intended model would answer that question, but then the distribution of cards and the bettor’s information about that model must still be specified. Alternatively, one can average over a finite collection of worlds, but the chosen weights become part of the game’s rules.

This is not a defect. It is a blueprint. The casino becomes mathematically meaningful as soon as three ingredients are declared:

1. a collection of statements and a method for sampling them;
2. a semantics assigning truth values in specified worlds;
3. a strategy whose predictive probabilities can be analyzed.

Once those exist, the expected-payoff formula provides an exact audit.

## A practical simulation

A numerical demonstration can model $1{,}000$ cards, each correctly predicted with probability $2/3$. Repeating the experiment many times produces a cloud of total payoffs centered near $1000/3$. Individual sessions fluctuate: some earn less, some more, and rare losses remain possible. The theorem concerns the mean, not a guaranteed realized profit.

A complementary-world demonstration is even simpler. Generate any sequence of predictions and any truth assignment. Compute the payoff, flip every truth value, and compute again. The two totals sum to zero exactly. Generate instead the adversarial assignment opposite every prediction, and the payoff is always $-1000$.

These experiments illustrate three distinct notions that are often blurred together:

- **worst-case guarantee**, which is impossible here without restrictions on worlds;
- **expected advantage**, which requires average accuracy above $1/2$;
- **realized profit**, which fluctuates around its expectation.

## What the casino really teaches

Gödel’s Casino does not turn incompleteness into free money. It does something more illuminating: it reveals precisely what incompleteness fails to provide.

The no-free-lunch theorem says that a deterministic bettor cannot dominate all possible truth assignments. Complement symmetry cancels every triumph with an equal defeat. The expected-payoff theorem then identifies the missing ingredient: information strong enough to push aggregate accuracy beyond chance. The $2/3$ strategy wins $1/3$ per card in expectation, but only because the predictive edge was explicitly assumed. Known propositions produce profit; balanced unresolved propositions do not.

That lesson reaches beyond mathematical logic. In forecasting, medicine, finance, and machine learning, uncertainty is routinely mistaken for opportunity. Yet volatility does not imply predictability, and ambiguity does not imply bias. A useful forecast must beat its baseline. A classifier must outperform chance under a defined distribution. A trading signal must survive an accounting of both correct and incorrect positions.

The deepest card in Gödel’s Casino is therefore not the Continuum Hypothesis. It is the distinction between **not knowing** and **knowing how likely**. Incompleteness opens many doors, but probability decides whether any of them leads to a favorable bet.