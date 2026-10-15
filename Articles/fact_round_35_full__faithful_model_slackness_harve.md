# The Leg That Was Missing: Why the One-Fifth Barrier in Factoring Has Two Locks

*When you simplify a cost model and the optimum comes out right, it is easy to think you have found the parts that matter. A closer look at the best known deterministic factoring algorithm shows how that can go wrong, and what it changes about where to look for the next improvement.*

---

## A number, a clock, and a speed limit

Pick a large integer $N$ and ask for one of its factors. If you are allowed to flip coins, modern algorithms such as the number field sieve do this in time that grows more slowly than any fixed power of $N$. If you insist that the algorithm be **deterministic**, with no randomness and a guaranteed answer, the story is very different. For decades the best deterministic running times were plain powers of $N$:

- trial division takes about $N^{1/2}$ steps;
- Lehman's method (1974) takes about $N^{1/3}$;
- the Pollard–Strassen method takes about $N^{1/4}$, up to logarithmic factors.

In 2021 David Harvey broke the quarter barrier with a deterministic algorithm running in about $N^{1/5}$ steps, again up to logarithmic factors. Going from $1/4$ to $1/5$ in the exponent sounds small. For a 60-digit number it is the difference between roughly $10^{15}$ and $10^{12}$ operations, a factor of a thousand.

The obvious next question is whether the exponent can go down again, to $1/6$ or lower. Before working on an improvement, you have to know which part of the algorithm is holding the exponent at $1/5$. This article is about how that question was first answered wrongly, and what the correct answer turns out to be.

## How an algorithm's cost becomes a game of exponents

Algorithms like Harvey's have tunable parameters. Two matter here:

- a **pair floor** $r$: the algorithm handles a family of about $r$ candidate pairs one by one, so it pays about $r$ for this;
- a **baby-step budget** $m$: like the classical *baby-step giant-step* method, it precomputes a table of $m$ small steps so that later big jumps can be checked against the table quickly.

Each part of the algorithm is a **leg** of the cost, and the total running time is set by the most expensive leg. Bigger parameters make some legs more expensive and others cheaper. Tuning the algorithm is a balancing act.

The cleanest way to see the balance is to write everything as a power of $N$. Put $r = N^a$ and $m = N^b$. Each leg is then $N$ raised to some simple linear expression in $a$ and $b$, and the running time is $N^{E}$, where $E$ is the **largest** of those expressions. Finding the best parameters means making the largest exponent as small as possible. That is a small linear program, which you can solve on a napkin.

## The three-leg picture

The simplified picture people had been using has three legs:

1. the pair floor, cost $r$, exponent $a$;
2. the baby steps, cost $m$, exponent $b$;
3. the **interior** search, the giant steps through what is left of the search space. Its cost is $N^{1/2}/(r^{1/2} m)$, with exponent $\tfrac12 - \tfrac a2 - b$.

There is a short argument that you cannot go below $1/5$ here. Suppose all three exponents were below some number $t$. Add the interior exponent, half the pair exponent and the full baby-step exponent:

$$\Big(\tfrac12 - \tfrac a2 - b\Big) + \tfrac12 a + b = \tfrac12 .$$

The left side is less than $t + \tfrac12 t + t = \tfrac52 t$, so $\tfrac52 t > \tfrac12$, which means $t > \tfrac15$. Setting $a = b = 1/5$ makes all three legs equal $N^{1/5}$ at once. So the optimum is exactly $1/5$, the same exponent Harvey's analysis gives.

This model suggested a plan. It reads as if three legs are balanced against each other: the interior, the baby steps and the pair floor. Weaken any one of them and the balance should shift. One proposal in this spirit was to make the baby-step table cheaper with fast batched polynomial evaluation. Another was to restructure the interior search. A third was to add a fourth parameter, a new search dimension that shrinks the interior further.

## The leg that was missing

The three-leg picture leaves out a step that Harvey's algorithm actually performs. One stage of the algorithm fixes an auxiliary length

$$M = \big\lceil (N/r)^{1/2} \big\rceil ,$$

and computing with $M$ terms costs about $(N/r)^{1/4}$, again up to logarithms. That is a **fourth leg**, which we will call the **$M$-leg**. Its exponent is $(1-a)/4$. The **faithful** cost model, meaning the one that counts every step the algorithm pays for, is

$$T(r, m) \;=\; \max\Big\{\, (N/r)^{1/4},\;\; \frac{N^{1/2}}{r^{1/2} m},\;\; r,\;\; m \,\Big\}.$$

Adding a leg can only make the cost larger. Since $a = b = 1/5$ also gives $(1 - 1/5)/4 = 1/5$, the optimum is still exactly $1/5$, and all **four** legs tie there. So the answer has not changed. The explanation of the answer has.

There is a short reason the three-leg picture got the right number. Multiply the interior cost by the baby-step cost: $\frac{N^{1/2}}{r^{1/2}m}\cdot m = (N/r)^{1/2}$. The square root of that product is exactly the $M$-leg:

$$(N/r)^{1/4} = \sqrt{\text{interior}\times\text{baby steps}} .$$

A geometric mean is never larger than the bigger of its two inputs, so for the algorithm exactly as it stands, the $M$-leg can never be the single most expensive leg. At most it ties. As long as the interior and the baby steps keep their costs, dropping the $M$-leg changes nothing, and the three-leg model is not wrong about the running time. The trouble starts when you try to *improve* the algorithm. If the interior or the baby steps get cheaper, their geometric mean, the $M$-leg, does not automatically get cheaper with them, because it is a separate step with its own cost. It stays where it is and becomes the bottleneck.

## Slackness: two of the legs are not needed

Look at only two legs: the new $M$-leg and the pair floor $r$.

> **Faithful slackness theorem.** For every $N > 0$, every $r > 0$, and *any* numbers $f$ and $g$ at all,
> $$\max\Big\{ (N/r)^{1/4},\; f,\; r,\; g \Big\} \;\ge\; N^{1/5}.$$

Put the interior cost in place of $f$ and the baby-step cost in place of $g$, or put anything else there, even very negative numbers, which amounts to deleting those legs. The total still cannot fall below $N^{1/5}$.

The proof takes one line. If both $(N/r)^{1/4} < N^{1/5}$ and $r < N^{1/5}$, then raising the first to the fourth power gives $N/r < N^{4/5}$, so $N < N^{4/5} \cdot r < N^{4/5} \cdot N^{1/5} = N$. That is a contradiction. In exponent form: one leg goes down as $a$ grows and the other goes up, and they cross at $(1-a)/4 = a$, which means $a = 1/5$.

So in the model of what the algorithm actually pays for, the interior and the baby-step legs are **slack**. They tie at the optimum, but the bound does not depend on them. Making them cheaper, by any amount and with any technique, leaves the exponent at $1/5$.

That closes off the improvement plans that targeted the interior or the baby steps. Fast batched evaluation of the baby-step table does not help. A better design for the interior does not help. Three separate investigations had been aimed at legs that do not bind.

## Two locks on one door

The interior and baby-step legs are not useless, though. The three-leg argument above shows that those legs **together with** the pair floor *also* force $1/5$, without the $M$-leg. So the value $1/5$ has **two certificates**:

- **Certificate A:** the $M$-leg plus the pair floor;
- **Certificate B:** the interior plus the baby steps plus the pair floor.

They share only the pair floor, and each one is enough to force $1/5$ by itself. Picture a door with two locks: picking one lock does not open it.

> **Both locks theorem.** Suppose some redesign changes the $M$-leg, the interior and the baby-step legs to anything you like, while the pair floor still costs $r$. If the new cost has exponent below $1/5$, then the redesign has **both** made the $M$-leg cheaper than $(1-a)/4$ **and**, for every choice of baby-step exponent $b$, made either the interior cheaper than $\tfrac12 - \tfrac a2 - b$ or the baby steps cheaper than $b$.

Improving one family of legs by itself provably does nothing. A further fact makes the picture tidy: both the faithful model and the three-leg relaxation have the **same unique** best parameter choice, $r = m = N^{1/5}$. No other setting of the parameters reaches $1/5$ in either model.

## Getting the attribution right: $1/20$ versus $2/15$

The four-leg model also clears up a bookkeeping mistake. Ask what happens if a floor is **deleted**, meaning its parameter is fixed at the trivial value instead of tuned.

- **Delete the baby-step floor** ($m = 1$, so $b = 0$). The legs become $(1-a)/4$, $a$ and $\tfrac12 - \tfrac a2$. The interior and pair legs cross at $a = 1/3$, and the best exponent is $1/3$. That is worse by $2/15$.
- **Delete the pair floor** ($r = 1$, so $a = 0$). The $M$-leg is stuck at $1/4$, and the best exponent is $1/4$, the old Pollard–Strassen exponent. That is worse by $1/20$.

An earlier experiment had linked a penalty of $N^{1/20}$ to deleting the baby-step floor. The exact computation shows that $1/20$ belongs to the **pair floor**. Deleting the baby-step floor costs $2/15$. The two deletions had been mixed up.

## Does the fourth-dimension idea survive?

Now consider the most promising plan: add a new search dimension, a "fourth floor": a new parameter $N^c$ that costs $N^c$ to set up and, with some weight $w$, divides the interior cost by $N^{wc}$. In the three-leg relaxation this works well. The same weighted-sum argument as before shows the optimum becomes

$$E = \frac{1}{5 + 2w},$$

so weight $w = 1/2$ gives $1/6$, and $w = 1$ gives $1/7$.

In the faithful model **it does nothing**. The new floor shrinks the interior, but the $M$-leg never involves it, and Certificate A, the $M$-leg plus the pair floor, still forces $1/5$ for every weight and every value of the new parameter. The idea works only in a model that leaves out the $M$-leg.

What would rescue it? Suppose the $M$-leg could be **coupled** to the baby steps, by reusing the precomputed table to shorten the $M$-stage, so that its cost becomes $(N/r)^{1/4}/m^{\theta}$. The analysis then has a sharp threshold:

> **Coupling threshold theorem.** Coupling by itself never beats $1/5$, because Certificate B is untouched. Combined with a fourth floor of weight $1/2$, the exponent $1/6$ is reachable **if and only if** $\theta \ge 1/4$.

For example, coupling with $\theta = 1/5$ together with the new floor gets only to $5/29 \approx 0.172$, which is still above $1/6$.

## A general rule: the worse certificate wins

All of these calculations come from one formula. Generalise the four legs to

$$\max\Big\{ (N/r)^{\mu},\;\; \frac{N^{\gamma}}{r^{\alpha} m},\;\; r,\;\; m \Big\}, \qquad \mu > 0,\; \alpha \ge 0.$$

> **Independent certificate law.** The optimal exponent is exactly
> $$\max\Big( \frac{\mu}{1+\mu},\;\; \frac{\gamma}{2+\alpha} \Big),$$
> and it is attained.

The first term is what Certificate A forces, and the second is what Certificate B forces. The two do not interact: the answer is just the larger of the two. For Harvey's parameters, $\mu = 1/4$, $\gamma = 1/2$, $\alpha = 1/2$, both terms equal $1/5$. That coincidence is why the four legs tie. It also explains why improving either side alone is useless: you are lowering the smaller of two numbers whose maximum is the answer. The formula also shows that getting the $M$-certificate down to $1/6$ needs $\mu \le 1/5$.

## A note on splitting the search into levels

A related idea is to split the baby-step giant-step search into several levels, each with its own table. One lemma rules this out, and it holds well beyond factoring:

> **Partition lemma.** Split a search pool of size $S$ into parts $S_1, \dots, S_k$. For each part use $L_i$ baby steps and $T_i$ giant steps with $L_i T_i \ge S_i$. Then
> $$\sum_i L_i + \sum_i T_i \;\ge\; 2\sqrt{S},$$
> and the inequality is **strict** as soon as two different levels each handle part of the pool.

Proof: $(\sum_i (L_i+T_i))^2 \ge \sum_i (L_i+T_i)^2 \ge \sum_i 4 L_i T_i \ge 4S$. The first inequality drops the cross terms, which are positive when two levels are active. That is where strictness comes from. Splitting evenly into $k$ levels costs exactly $\sqrt{k}$ times as much as using one level. Multi-level baby-step schemes are therefore ruled out by a theorem, not just by experiment.

## What this means

None of this shows that $N^{1/5}$ is a lower bound for factoring. The opposite is true: it is an upper bound that an algorithm actually reaches, and all the results here hold inside a cost model whose form is *assumed*, not derived from first principles. What the results do is narrow where to look.

- Any improvement has to get past **both** certificates. In particular it has to deal with the $M$-leg $(N/r)^{1/4}$, which the simplified picture left out.
- Making the interior or the baby steps cheaper, by itself, is provably useless.
- The fourth-dimension idea needs a partner: a way to make the $M$-stage benefit from the baby steps by at least the exponent $1/4$.
- Splitting the search into several levels never helps.

There is also a general point. A simplified model that gives the right optimum is not thereby a correct explanation. The three-leg model reproduced Harvey's exponent exactly, and that made it easy to trust its account of what was binding. But the legs that produce the bound in a simplified model need not be the ones the real algorithm pays for. Before trying to improve an algorithm, write down every step it pays for and check which constraints actually force the bound.
