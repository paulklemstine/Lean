# The Crossing Law: Why a Narrower Hint Can Never Make Up for an Unreliable One

*A target hides in one of many boxes, and someone offers you a tip about where it is. One clean formula tells you which tips are worth taking.*

---

## A tip at the door

Picture a long corridor of $M$ lockers. One of them holds what you want: a misplaced file, a faulty component on a circuit board, the line of code that introduced a bug. Opening a locker costs one unit of effort. Your score is the expected number of lockers you open before you find the right one.

You do have some prior knowledge. The target is more likely to be near the start of the corridor. Concretely, its position behaves like the *smaller* of two independent, uniformly random locker numbers. This "min-law" puts more weight on early lockers, and a sensible searcher who knows nothing else opens lockers from the front. Their expected cost is exactly

$$
B_M \;=\; \frac{(M+1)(2M+1)}{6M} \;\approx\; \frac{M}{3}.
$$

Now an oracle shows up: a heuristic, a machine-learning model, an experienced colleague. It points at a stretch of $W$ lockers and says: *"It's in here. I'm right a fraction $\alpha$ of the time."*

That tip carries two numbers. The **width** $W$ (or the fraction $w = W/M$ of the corridor) says how sharp the tip is. The **reliability** $\alpha$ says how much you can trust it. Both seem to matter, and you might expect them to trade off: a very sharp tip should be worth something even if it is somewhat less trustworthy.

This article explains why that expectation is wrong in a precise sense. Past a certain point, sharpness cannot buy speed at all. The relationship is captured in a single inequality that we call **the crossing law**.

## Step one: what is the best way to use a tip?

Before asking what a tip is worth, we need the best way to search once we have it. If the oracle spreads its confidence evenly, then each locker inside the window holds the target with probability $a = \alpha/W$ and each locker outside holds it with probability $b = (1-\alpha)/(M-W)$. A belief that takes just two values like this is called a *two-valued posterior*.

A search strategy is just an order in which to open the lockers. With $M$ lockers there are $M!$ orders, which is astronomically many even for modest $M$. One might expect clever orders to help: hedging by alternating between the window and the outside, or starting just outside the window in case the oracle is slightly off.

**None of that helps.** There is an exact accounting identity, which we call the **displacement law**. Number the opening slots $1, 2, \dots, M$. For any order, add up the slot numbers in which a window locker is opened. The smallest this sum can be is $1 + 2 + \dots + W = W(W+1)/2$, which happens when all window lockers are opened first. The displacement law says:

> **Displacement law.** For every one of the $M!$ orders, the extra expected cost compared with opening the window first is exactly
> $$ (a-b)\times\Big(\text{sum of the window slots} \;-\; \tfrac{W(W+1)}{2}\Big). $$

This is an equality, not an estimate, and it holds for every order. It turns a search over $M!$ strategies into a single number per strategy: how far the window was pushed back. When $a \ge b$, each window locker pushed past slot $W$ costs at least $a-b$ extra, and the optimum is reached by the window-first ("committed") scan. When $a > b$ strictly, we get a sharp characterization:

> **Bayes equals committed.** The Bayes-optimal searcher, the one who minimizes expected cost over all $M!$ orders, does exactly what the naive committed searcher does: open the whole window first, then the rest. When the window is strictly more probable per locker, the optimal orders are *exactly* the window-first orders and no others.

The proof rests on a small combinatorial fact, an **exchange lemma**. If you pick any $W$ of the slots, their sum is at least $W(W+1)/2$, and it grows by at least one for every chosen slot beyond the first $W$. Swapping a late slot for an early one always lowers the sum.

What about hedging? Take the "interleaved" strategy: window, outside, window, outside, and so on. The window lockers then sit in slots $1, 3, 5, \dots, 2W-1$, whose sum is $W^2$. By the displacement law, interleaving costs exactly

$$
(a-b)\cdot\frac{W(W-1)}{2}
$$

more than committing. That is strictly worse whenever $W \ge 2$ and $a > b$. Hedging against your own tip is always a mistake here.

## Step two: pricing the tip

With the search settled, the cost of a tip has a closed form. The committed searcher's expected cost is

$$
C_M(W,\alpha) \;=\; \frac{W + 1 + (1-\alpha)M}{2}.
$$

This formula is easy to read. With probability $\alpha$ the target is in the window, and you pay about half the window on average. With probability $1-\alpha$ you work through the whole window and then about half of the outside. The **priced speedup** of a tip compares this with the blind searcher:

$$
S_M(W,\alpha) \;=\; \frac{B_M}{C_M(W,\alpha)} \;=\; \frac{(M+1)(2M+1)}{3M\big((1-\alpha)M + W + 1\big)}.
$$

For a large corridor, write $w = W/M$ and let $M$ grow. The formula simplifies to

$$
S(\alpha, w) \;=\; \frac{2}{3(1-\alpha+w)}.
$$

The denominator $1-\alpha+w$ contains the whole story. The unreliability $1-\alpha$ and the width $w$ enter *additively*. Shrinking the window helps, but only by removing the $w$ term. Once $w$ is essentially zero, the speedup is capped by $1-\alpha$ alone.

## Step three: the crossing law

Suppose you want a speedup of at least $s$. Rearranging gives:

> **The Crossing Law.** For $s > 0$, a tip of width fraction $w$ and reliability $\alpha$ achieves speedup at least $s$ if and only if
> $$ w \;\le\; \alpha - \alpha_{\min}(s), \qquad\text{where}\qquad \alpha_{\min}(s) = 1 - \frac{2}{3s}. $$

Read it as a gate followed by a budget. First, the reliability must exceed the threshold $\alpha_{\min}(s)$. Second, once it does, the surplus $\alpha - \alpha_{\min}(s)$ is your *width budget*: the window may be as wide as that fraction of the corridor and no wider. The boundary is a straight line in the $(w, \alpha)$ plane. Curves of equal speedup are parallel lines of slope one:

$$
S(\alpha, w) = s \quad\Longleftrightarrow\quad w = \alpha - \alpha_{\min}(s).
$$

The most important consequence follows immediately:

> **Width can never substitute for reliability.** If $\alpha \le \alpha_{\min}(s)$, then *every* tip with positive width has speedup strictly less than $s$, no matter how narrow it is.

You can make the window one locker wide, or a millionth of the corridor, and it does not matter. At reliability exactly $\alpha_{\min}(5)$, a window of $w = 0.001$ gives $4.963\times$ and a window of $w = 10^{-6}$ gives $4.99996\times$. The speedup approaches $5\times$ but never reaches it. The gate is a hard wall.

## A worked example: decoding a $5.19\times$ speedup

Suppose a hinted search method has been measured to run $5.19$ times faster than blind search. What does that tell you about the tips it uses?

The crossing law answers precisely. The gate is

$$
\alpha_{\min}(5.19) = 1 - \frac{2}{15.57} = 0.87154\ldots,
$$

strictly between $0.87154$ and $0.87155$. So **the tips must be right more than 87.15% of the time**, whatever their width. If they are right, say, 90% of the time, the crossing width is

$$
\frac{\mu}{M} = 0.90 - 0.87155 \approx 0.02845,
$$

so the windows cover just under 3% of the corridor. A measured speedup can therefore be translated back into an "effective interval quality": roughly 90% reliability with windows about 2.8% wide. That matches what a separate numerical fit had estimated for the same measurement.

Corridors in practice are finite, so it matters that the gate is not just an artifact of the large-$M$ limit. At every finite size the same gate exists in the form

$$
\alpha_{\min}^{M}(s) = 1 - \frac{(M+1)(2M+1)}{3M^2 s},
$$

and reaching speedup $s$ at size $M$ forces $\alpha > \alpha_{\min}^M(s)$ for every width. As $M \to \infty$ this tends to $1 - 2/(3s)$: for $s = 5.19$ it is $0.87090$ at $M=300$ and $0.87153$ at $M=10{,}000$. The finite formulas are exact. At $M = 300$, $W = 9$, $\alpha = 0.9$, the closed form gives $S = 5.02503$, and summing the expected cost locker by locker gives exactly the same number.

## A twist: the lying oracle

A natural next guess was that the gate survives even for the fully Bayes-optimal searcher, the one free to choose any of the $M!$ orders given what the oracle said. That guess is **false**, and the reason is instructive.

Imagine an oracle that is almost always *wrong*: $\alpha$ is close to zero. Its tip is useless as stated, but it is excellent information about the *complement*. "It's in lockers 1–2" coming from a reliably wrong oracle means "it's in lockers 3 onward." A Bayes-optimal searcher exploits this by opening the outside first.

The exact optimal cost confirms it. For the two-valued posterior it is

$$
\min\left(\frac{W+1+(1-\alpha)M}{2},\; \frac{M-W+1+\alpha M}{2}\right),
$$

the better of "window first" and "outside first." So the Bayes gate is **two-sided**: reaching speedup $s$ requires

$$
\alpha > \alpha_{\min}^M(s) \qquad\text{or}\qquad 1-\alpha > \alpha_{\min}^M(s).
$$

A tiny example shows that the one-sided version really fails. With $M=4$ lockers, a window of $W=2$, and $\alpha = 0$ (the oracle is always wrong), the Bayes searcher reaches speedup $5/4$. Yet the one-sided gate would require $\alpha > 1/4$. In the "trusted" regime, where the window is at least as likely per locker as average ($\alpha \ge W/M$), the gate is one-sided again, exactly as the crossing law states.

## Is the price fair? It errs on the side of caution

So far each tip was priced by assuming the oracle's confidence is spread evenly inside and outside the window. Real tips are rarely so uniform. Inside the window the target may be more likely near one end, and the prior itself may tilt. Does the crossing law then overstate what tips are worth?

It does the opposite. Take any belief at all over the lockers that gives the window total probability $\alpha$. Compare two specific orders: the committed scan, and its **block reversal**, which opens the window backward and then the outside backward. A pairing identity holds: the two costs always add up to exactly

$$
W + 1 + (1-\alpha)M,
$$

which is twice the stipulated cost. Each locker's two slot numbers sum to a constant within its block. So at least one of the two orders costs no more than the stipulated price, and the Bayes optimum costs no more than either. Therefore:

> **Conservative pricing.** For every belief with window mass $\alpha$, the true Bayes-optimal speedup is at least the stipulated speedup $S_M(W,\alpha)$.

In 300 random beliefs on six lockers, the true optimal cost never exceeded the stipulated cost; its largest ratio was about $0.96$–$0.98$. In a related experiment, letting the belief follow the shape of the prior inside the window raised an estimated speedup from about $5.56\times$ to $7.62\times$. The crossing law is therefore a *floor* on what reliable tips buy. It is a benchmark, not a ceiling.

## Why this matters

The crossing law describes any search with a fallible guide:

- **Debugging and fault localization.** A tool that flags "the bug is in these 30 lines" is only useful beyond a certain speedup if it is right often enough. Making the flagged region smaller cannot fix a tool that is wrong too often.
- **Database and index lookups.** A learned index predicts a position plus an error band. The band is the width and the coverage is the reliability, and the gate tells you what coverage is needed for a target speedup.
- **Medical triage and inspection.** A screening test that narrows the suspects to a small group is worth less than it looks if its hit rate is below the gate for the speedup you need.

The general lesson is that *precision and accuracy are not interchangeable currencies.* In this model accuracy works as a gate and precision as a budget, and a budget cannot open a gate.

## The shape of the argument

All of this rests on a few ideas:

1. An **exchange lemma** about sums of slot numbers: early slots beat late slots, one unit at a time.
2. The **displacement law**, which gives the exact cost of every one of $M!$ orders using a single number.
3. **Bayes equals committed**, which makes optimal search under a two-valued belief explicit.
4. A **closed-form price**, whose large-$M$ limit $2/(3(1-\alpha+w))$ makes unreliability and width additive.
5. The **crossing law**, an exact equivalence, together with its finite-$M$ version, the two-sided correction for anti-reliable oracles, and a pairing argument that makes the whole pricing conservative.

Several questions remain open. Is the conservative price *strictly* beaten, by a margin proportional to $M$, for realistic prior-shaped beliefs? Does the crossing law extend to oracles that name several nested windows, each with its own reliability? And if an oracle *misstates* its reliability, does only the true reliability enter the gate? (The committed order never looks at the claimed number, so the answer is expected to be yes.)

What is settled is this: an oracle must first be right often enough to reach the speedup you want, and only after that does a narrower window help.
