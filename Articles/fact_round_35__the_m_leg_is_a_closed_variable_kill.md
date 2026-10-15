# The Knob That Was Never There: How a Five-Line Inequality Closed a Door in Factoring

*Why one dial of the fastest known deterministic factoring algorithm cannot be turned, and why the lever that is left is, in disguise, a lever we already knew about.*

---

## A lock with three tumblers

Say you want to factor a large integer $N$. You are not allowed to guess with random numbers. You have to follow a fixed recipe that is guaranteed to work. For most of the twentieth century the best guaranteed recipes needed about $N^{1/4}$ steps; Pollard and Strassen's methods are the classic examples. In 2021 David Harvey published a deterministic algorithm that runs in roughly $N^{1/5}$ steps, up to logarithmic factors. That is the best exponent anyone has proved for deterministic factoring.

If you squint at Harvey's analysis and ignore the logarithmic factors, the running time comes down to the largest of three numbers:

$$
\text{cost} \;=\; \max\Big\{\; \underbrace{\frac{N^{1/2}}{r^{1/2}\,m}}_{A:\ \text{the interior}},\;\; \underbrace{r}_{B:\ \text{the pair leg}},\;\; \underbrace{m}_{C:\ \text{the baby-step leg}} \;\Big\}.
$$

Here $r$ and $m$ are two parameters you are free to choose:

- **$B = r$** is the cost of a search over pairs of small integers, in the spirit of Lehman's classical method. Searching further costs more, but it also shrinks what remains to be done.
- **$C = m$** is the cost of building a table of "baby steps": the powers $\alpha, \alpha^2, \dots, \alpha^m$ of some fixed number $\alpha$ modulo $N$.
- **$A = N^{1/2}/(r^{1/2} m)$** is the cost of the "interior", the matching phase. Each candidate gets compared against the baby-step table, and the bigger the table, the less matching is left.

It works like a lock with three tumblers. Lowering one tends to raise another. You win by setting all three to the same height. Write $r = N^a$ and $m = N^b$, and the cost becomes $N$ raised to the exponent

$$
E(a,b) \;=\; \max\Big\{\, a,\;\; b,\;\; \tfrac12 - \tfrac a2 - b \,\Big\}.
$$

Setting all three terms equal gives $a = b = \tfrac15$, where all three equal $\tfrac15$. That is where Harvey's $N^{1/5}$ comes from.

## How do you know you can't do better?

Showing that $\tfrac15$ can be reached is easy: plug in $a = b = \tfrac15$. Showing that nothing in this model goes lower needs a different tool, and it is a short one. Give the three terms the weights $\tfrac15$, $\tfrac25$, $\tfrac25$ and add:

$$
\tfrac15\cdot a \;+\; \tfrac25\cdot b \;+\; \tfrac25\cdot\Big(\tfrac12 - \tfrac a2 - b\Big) \;=\; \tfrac15 .
$$

Everything involving $a$ and $b$ cancels, and the constant $\tfrac15$ is left. A weighted average of three numbers can never be larger than the largest of them, so the maximum is at least $\tfrac15$ whatever you pick. In linear programming these weights are called a **dual certificate**. They also carry a second piece of information that turns out to matter a great deal. They are the **shadow prices** of the three terms: they say exactly how much the final exponent falls if you make one term cheaper.

## The tempting target

Researchers on this problem had spent a long time trying to improve one term at a time. Make the pair search cheaper. Make the matching cheaper. The question for this round was the baby-step leg $C$ together with the interior $A$ it feeds into. Could the baby steps be built more cleverly, or could the matching be organized differently, to get a power-of-$N$ improvement?

This time the team made a rule for itself: *before spending a round searching, run a quick screen that asks what the answer would be worth.* The screen did more than put a price on the question. It closed it, by proving that no gain exists. Three separate facts, which we can call **pins**, hold the baby-step leg in place.

## Pin 1: two halves of one quantity

Multiply the interior by the baby-step leg:

$$
A \cdot C \;=\; \frac{N^{1/2}}{r^{1/2}\, m}\cdot m \;=\; \frac{N^{1/2}}{r^{1/2}}.
$$

The parameter $m$ cancels. However you choose the table size, the product of these two costs stays the same. Now use the fact that the larger of two positive numbers is at least their geometric mean:

$$
\max\{A, C\} \;\ge\; \sqrt{A\cdot C} \;=\; \Big(\frac{N}{r}\Big)^{1/4},
$$

with equality exactly when $A = C$. So $A$ and $C$ are not two independent costs. They are two halves of one cost, and Harvey's choice of $m$ already splits it perfectly. Making one half cheaper only makes the other half more expensive.

This also explains something seen in earlier rounds. When you optimize $m$ away, the three-term cost turns into a two-term cost:

$$
\min_{b}\,E(a,b) \;=\; \max\Big\{\, a,\;\; \tfrac{1-a}{4}\,\Big\}.
$$

The term $(N/r)^{1/4}$ is exactly the cost of a step in Harvey's own refined algorithm, called the "$M$-leg". The exponent $\tfrac15$ had appeared with two different-looking certificates, one involving the $M$-leg and one involving the interior together with the baby steps. They are the same certificate, before and after you remove $m$.

## Pin 2: you can't print more than you compute

Could the table $\alpha, \alpha^2, \dots, \alpha^m$ be built in fewer than about $m$ steps? Consider any *straight-line program*: a fixed list of instructions, each of which multiplies two values already computed and writes down the result. Start from one input. After $t$ multiplications you have written down exactly $t+1$ values. So:

> **Output counting.** A straight-line program with $t$ multiplications produces at most $t+1$ distinct elements. Producing $m$ distinct group elements takes at least $m-1$ multiplications.

The obvious chain $\alpha \to \alpha^2 \to \alpha^3 \to \cdots \to \alpha^m$, which multiplies by $\alpha$ each time, uses exactly $m-1$ multiplications. It already meets the lower bound. Within this model of computation there is nothing left to save.

## Pin 3: distinctness is what makes the algorithm correct

One possible loophole remains. Perhaps each baby step could be made to "count for more", so that one table entry handles several candidates and the interior shrinks faster than $1/m$. In the exponent model that would mean giving the baby-step parameter a weight larger than $1$ in the interior.

Harvey's own correctness argument rules this out. In his paper's words, the powers $\alpha_i$ in the first list are distinct *thanks to the hypothesis* $\operatorname{ord}_N(\alpha) \ge m$, so each candidate is equal to at most one $\alpha_i$. The underlying fact is short:

> **Injectivity, with a sharp boundary.** If $m \le \operatorname{ord}(\alpha)$, the baby steps $\alpha^1, \dots, \alpha^m$ are pairwise distinct. If $0 < \operatorname{ord}(\alpha) < m$, two of them coincide, namely $\alpha^1 = \alpha^{\operatorname{ord}(\alpha)+1}$.

For example, take $N = 1001 = 7\cdot 11\cdot 13$ and $\alpha = 10$. Then $10^6 = 1{,}000{,}000 = 999\cdot 1001 + 1$, so the order of $10$ is $6$. With $m = 6$ the table is $10, 100, 1000, 991, 901, 1$, six distinct values. With $m = 7$ the seventh entry is $10^7 \equiv 10$, a repeat. So the weight of $1$ is not slack in the analysis. It is the condition that makes the algorithm correct, and pushing past it breaks the algorithm.

## Putting the pins together: the shadow prices

The three pins combine neatly with the dual certificate. Suppose some new idea made the pair leg cheaper by a factor $N^{\varepsilon_1}$, the baby-step leg by $N^{\varepsilon_2}$, and the interior by $N^{\varepsilon_3}$. Then the best exponent becomes exactly

$$
\frac15 \;-\; \frac{\varepsilon_1 + 2\varepsilon_2 + 2\varepsilon_3}{5}.
$$

It can never be lower than this, and suitable choices of $r$ and $m$ reach it. The shadow prices are $(\tfrac15, \tfrac25, \tfrac25)$. The baby-step leg and the interior together carry $\tfrac45$ of the total price, so this looked like the place to attack. But Pin 2 says $\varepsilon_2 \le 0$, and Pin 3 says the interior cannot gain from the baby steps beyond weight $1$. Together they leave only the pair leg, at price $\tfrac15$. The baby-step leg is a **closed variable**.

The conclusion is short: **no power-of-$N$ gain is possible from the baby-step leg or the interior.** Finding that out took one inequality instead of a long search.

## The lever nobody had pulled: add a floor

Here is the second idea of the round. For thirty-four rounds every attack had tried to make an existing term cheaper. Nobody had tried to change the shape of the cost by adding a new term, a "floor", that is small at the current optimum but becomes the binding term after everything is rebalanced.

It sounds odd at first, because adding a term to a maximum can never lower it. If $L$ is a lower bound for $\max\{x_1, \ldots, x_k\}$, it is also a lower bound for $\max\{x_1, \ldots, x_k, y\}$. A floor that just sits beside the other terms is useless.

A floor helps only if it comes with a new parameter that **also reduces the interior**. Suppose a new search parameter $s = N^{c}$ costs $c$ in the exponent, divides the interior by $s^{w}$ for some weight $w$, and costs a small overhead $N^{\delta}$ on top. In general form, with an interior $N^{\gamma}$ divided by $r^{\alpha}$, the exponent cost is

$$
\max\Big\{\, a,\;\; b,\;\; c,\;\; \gamma + \delta - \alpha a - b - w c \,\Big\}.
$$

The same weighted-average argument as before gives the answer exactly:

> **The add-a-floor law.** For $\alpha, w \ge 0$ the optimum is exactly
> $$\frac{\gamma + \delta}{2 + \alpha + w},$$
> and it is reached when all four terms are equal. The new optimum beats the old one, $\gamma/(2+\alpha)$, exactly when $\delta\,(2 + \alpha) < \gamma\, w$.

For Harvey's cost, $\gamma = \alpha = \tfrac12$, so the condition becomes very simple:

$$
\text{a new floor beats } N^{1/5} \iff \delta < \frac{w}{5}.
$$

A floor with interior weight $w = \tfrac12$ and no overhead would lower the exponent to exactly $\tfrac16$. A floor with $w = 0$ helps by nothing at all, whatever it costs.

This is the twist. "Add a floor" turned out not to be a new kind of lever. **Its only effect is to add $w$ to the denominator** of the weighted-average bound. It is the old weight lever under another name. The new term matters only through how much it cuts the interior.

## The faithful model: a floor has to enter two places

Harvey's actual refined algorithm contains the $M$-leg $(N/r)^{1/4}$ as an explicit step, so a realistic floor has to deal with it as well. Let the new parameter shrink the $M$-leg with weight $\theta$ as well as the interior with weight $w$. The cost exponent is then

$$
\max\Big\{\,\tfrac{1-a}{4} - \theta c,\;\; a,\;\; b,\;\; c,\;\; \tfrac12 - \tfrac a2 - b - w c\,\Big\}.
$$

Two different weighted averages give two lower bounds at once:

$$
\text{cost} \;\ge\; \max\Big\{\, \frac{1}{5 + 4\theta},\;\; \frac{1}{5 + 2w}\,\Big\}.
$$

The consequences are concrete:

- To get **anywhere below $\tfrac15$**, you need both $\theta > 0$ and $w > 0$. A floor that helps only one of the two certificates is blocked by the other.
- To reach **$\tfrac16$**, you need $\theta \ge \tfrac14$ **and** $w \ge \tfrac12$. These thresholds are attained: with $\theta = \tfrac14$, $w = \tfrac12$ and $a = b = c = \tfrac16$, all five terms equal $\tfrac16$.

So the vague hope for "a new idea" becomes a specific target: find an arithmetic search parameter $s$ that shrinks the $M$-leg by $s^{1/4}$ and the interior by $s^{1/2}$, with overhead below $s^{1/10}$. Nobody knows whether such a parameter exists. What has changed is that we now know exactly which numbers it would have to achieve.

## Why a closed door is good news

None of this gives a faster factoring algorithm, and it does not claim to. $N^{1/5}$ remains an **upper bound** on deterministic factoring, not a proven lower bound. Nobody has shown that $\tfrac15$ is optimal in general. What this round showed is that one family of ideas cannot get below it.

What is valuable is the method. One afternoon with a weighted average and two counting arguments did the work of a long, multi-person search. Instead of ending with a vague failure, the round ended with a theorem that closes the baby-step door permanently, and with a precise description of what any successful idea would need: two numbers, $\theta \ge \tfrac14$ and $w \ge \tfrac12$.

Every optimization problem shaped like a maximum has this structure. The dual weights say where the value is. Counting arguments say which terms are already as cheap as possible. Correctness conditions say which weights cannot be stretched. When all three agree, you have proved that the knob you wanted to turn is not really there, and that makes it much clearer where to look next.
