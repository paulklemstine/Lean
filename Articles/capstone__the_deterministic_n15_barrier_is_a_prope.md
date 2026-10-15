# Three Roads to One-Fifth

### Why the best deterministic factoring exponent is stuck where it is, and the one door that might still be open

Take a large whole number $N$ and ask for its factors. It sounds like a schoolroom exercise, but the security of a good part of the internet rests on how hard it is. You are not allowed to flip coins: the method must be **deterministic**, the same steps every time, guaranteed to finish. How fast can it be?

Trial division checks every candidate up to $\sqrt N$, so it costs about $N^{1/2}$ steps. In the 1970s Pollard and Strassen brought this down to roughly $N^{1/4}$. Decades later the deterministic record dropped to $N^{1/5}$, up to logarithmic factors. That fraction, one-fifth, is what this article is about.

Before going on, one clarification. $N^{1/5}$ is an **upper bound**: it is what the best known deterministic method achieves. It is not a proven floor. Nobody can currently prove that factoring needs more than polynomial time in any reasonable model of computation. What follows is not a lower bound for factoring. It is a careful explanation of why one family of methods cannot get past one-fifth, together with a precise description of the single exit from that family that is still open.

---

## The motif: baby steps and giant steps

Many of the best deterministic algorithms share one pattern, older than any of them: the **baby-step/giant-step** trick. Suppose you need to find a hidden number $x$ between $0$ and $k^2$. Checking every value costs $k^2$ steps. Instead, write $x = kj + r$ with $0 \le r < k$ and $0 \le j < k$. List the $k$ "baby steps" $r$ and the $k$ "giant steps" $kj$, then look for the matching pair. Two lists of length $k$ do the work of one list of length $k^2$, so a square root of the work disappears.

Factoring algorithms in this family use the trick in a more elaborate form, and their cost reduces to a contest among three terms. Measure everything as a power of $N$. The algorithm chooses two dials:

* $a$, where $r = N^a$ is the number of "pairs" it processes in the interior of the computation;
* $b$, where $m = N^b$ is the length of a list it builds and stores.

The three costs are then

$$
\underbrace{a}_{\text{interior work}},\qquad \underbrace{b}_{\text{building the list}},\qquad \underbrace{\tfrac12 - \tfrac a2 - b}_{\text{the leftover search}} .
$$

The first two terms grow as you turn the dials up. The third, the search that remains, shrinks. The running time is governed by the **largest** of the three:

$$
E(a,b) \;=\; \max\Bigl(a,\; b,\; \tfrac12 - \tfrac a2 - b\Bigr).
$$

Minimising this is a short exercise. Add the three legs with weights $\tfrac12$, $1$ and $1$:

$$
\tfrac12\cdot a \;+\; 1\cdot b \;+\; 1\cdot\Bigl(\tfrac12 - \tfrac a2 - b\Bigr) \;=\; \tfrac12 .
$$

The dials cancel and leave a constant. The weights add up to $\tfrac52$, so a weighted average of the three legs equals $\tfrac12 \div \tfrac52 = \tfrac15$, and the largest leg must be at least that. Setting $a = b = \tfrac15$ makes all three legs equal to exactly $\tfrac15$. That is where one-fifth comes from.

**Theorem (the floor and its unique optimiser).** For all real $a, b$ we have $E(a,b) \ge \tfrac15$. Equality holds if and only if $a = b = \tfrac15$, and then all three legs are equal to $\tfrac15$.

Uniqueness follows from the same identity. If the maximum is exactly $\tfrac15$, each leg is at most $\tfrac15$, and the weighted sum forces every inequality to be an equality.

So far this is just a small optimisation problem. The interesting question is the next one: **which features of the problem are actually responsible for the $\tfrac15$?** If you want to improve an algorithm, you need to know which term to attack. The answer is that one-fifth belongs to the motif as a whole and not to any single term, and three separate arguments lead to it.

---

## Road I: the constraint that wasn't pulling

A recent result changed how order-finding fits into these algorithms. Order-finding means computing the smallest $t$ with $x^t \equiv 1$. The algorithms in this family need to know such an order, and this work removed an assumption that had been made about it. It looked like progress, so it was natural to ask whether it could lower the exponent.

It cannot, and the reason is general. Picture a ball resting at the bottom of a valley, with a fence somewhere on the hillside. The fence changes where the ball comes to rest only if it actually touches the ball. Optimisation works the same way.

**Lemma (slack constraint).** Let $f$ be any objective whose minimum value is $v$, attained at some point $x_0$, with values in any totally ordered set. Add another cost $g$ and minimise $\max(f, g)$ instead.

1. The new minimum is never below $v$.
2. If $g(x_0) \le v$, the new problem still attains $v$ at $x_0$, so the optimum does not move.
3. Conversely, if the new problem stays strictly above $v$ everywhere, then $g$ must exceed $v$ at **every** minimiser of $f$. A constraint can raise the optimum only if it is active wherever the old optimum was attained.

The order-finding cost is only a power of $\log N$. As a power of $N$, its exponent is $0$, while the optimum is $\tfrac15$. Even when we keep track of logarithmic factors, comparing first the power of $N$ and then the power of $\log N$, a cost of $N^0(\log N)^k$ is smaller than $N^{1/5}(\log N)^{\ell}$ for **every** $k$ and $\ell$. The slack is unlimited. In the concrete accounting the order term sits below the optimum by a factor of about $(\log_2 N)^{0.8}$, which is already about $256$ for a 1024-bit number and keeps growing. Removing the assumption is real progress, but it cannot affect $\tfrac15$.

The same lemma disposes of a fourth cost in the model, the "$M$-leg". At the optimum its exponent is at most $\tfrac15$, so adding or removing it changes nothing.

---

## Road II: delete a term, and find that every term matters

The second argument asks what happens if one of the three legs is removed, or if the coefficients of the model are changed.

Consider the general three-leg shape

$$
\max\bigl(a,\; c\,b,\; \gamma - u\,a - w\,b\bigr),
$$

where $c$ is the price of the list per unit of $b$, $w$ is the benefit the list gives to the search, $u$ is the benefit of the interior work, and $\gamma$ is the starting size of the search. The same balancing argument gives a closed formula.

**Theorem (general three-leg optimum).** If $u, w \ge 0$ and $c > 0$, the minimum is exactly

$$
\frac{\gamma}{1 + u + w/c},
$$

attained when all three legs are equal.

The list's parameters enter **only through the ratio $w/c$**, its benefit divided by its cost. Rescaling the list's unit (replacing $b$ by $b/\lambda$, $c$ by $\lambda c$ and $w$ by $\lambda w$) changes nothing. We call this a *closed variable*: you cannot make it cheaper by measuring it differently.

Now put in the true constraints of the motif. Building $m$ distinct outputs costs at least $m$ steps, since every output has to be written down, so $c \ge 1$. Each output can remove at most one candidate from the search because the list is injective, so $w \le 1$. Hence $w/c \le 1$, and with $\gamma = u = \tfrac12$:

$$
\frac{1/2}{1 + 1/2 + w/c} \;\ge\; \frac{1/2}{5/2} \;=\; \frac15 .
$$

To reach $\tfrac16$ the formula requires $w/c = \tfrac32$ **exactly**. Each list entry would have to remove one and a half candidates, which injectivity rules out.

Next delete each leg in turn. With both dials between $0$ and $\tfrac12$:

* Drop the interior leg. At $a = \tfrac12$, $b = \tfrac18$ the other two legs are both $\tfrac18$.
* Drop the list leg. At $a = 0$, $b = \tfrac12$ the other two are both $0$.
* Drop the search leg. At $a = b = 0$ everything is $0$.

Each deletion drops the optimum strictly below $\tfrac15$. All three legs are **co-binding**: the barrier is held up by all three together, and each of them is needed for it. So an attack on any single term, or any improvement by logarithmic factors, cannot move the exponent.

---

## Road III: space, time, and an invariant

The third argument changes how the terms are read. The list is **memory**: storing $m = N^b$ entries uses space $N^b$. The interior work and the residual search are **time**. Write

$$
A = \max\Bigl(a,\ \tfrac12 - \tfrac a2 - b\Bigr)\quad\text{(time)},\qquad C = b\quad\text{(space)}.
$$

**Theorem (space–time invariant).** For every choice of dials,

$$
3A + 2C \;\ge\; 1, \qquad\text{equivalently}\qquad \text{Time}^3\cdot\text{Space}^2 \;\ge\; N .
$$

The bound is tight: along $a = (1-2b)/3$ it holds with equality for every $b$.

The proof is one line: $A \ge a$ and $A \ge \tfrac12 - \tfrac a2 - b$, so $3A \ge a + 2(\tfrac12 - \tfrac a2 - b) = 1 - 2b$.

The invariant has three consequences:

* **Limiting memory slows the method.** If space is at most $N^\sigma$, time is at least $N^{(1-2\sigma)/3}$.
* **Faster time needs more memory.** Time below $N^{1/5}$ forces space above $N^{1/5}$. Changing how memory is used, for example by putting a floor under it, cannot lower the time.
* **The invariant alone gives one-fifth.** If both $A$ and $C$ were below $\tfrac15$, then $3A + 2C < 1$. So $\max(A, C) \ge \tfrac15$, and this maximum is exactly $E(a,b)$.

This explains why every escape tried inside the motif goes in a circle. Easing the space term is a memory optimisation and does not lower the time. Lowering the time requires lowering $A$, which the invariant ties down. The remaining option is to supply the hidden structure some other way, and that means solving a discrete logarithm or finding an order. Those problems are known to be equivalent to factoring under randomised reductions, so for a deterministic factoring method this is circular.

---

## The door: from searching to covering

All three arguments reach the same conclusion. **One-fifth is a property of the baby-step/giant-step motif itself**, so the only non-circular way past it is to leave the motif. A recent proposal by Umans and Wang does exactly that. In place of a search it uses a *covering*.

**Definition.** Two finite sets of integers $S$ and $T$ form a **divisibility covering** of $\{1, 2, \dots, n\}$ if every $i$ in that range divides at least one difference $s - t$ with $s \in S$ and $t \in T$.

There is a hidden trap. If $S$ and $T$ share an element, then $s - t = 0$ is divisible by everything and the problem becomes trivial. We therefore require $S$ and $T$ to be **disjoint**. The aim is to keep the sets small, $|S|, |T| \le n^\beta$, and their elements not too large, $\log(\text{largest element}) \le n^\alpha$. How small can $\alpha$ and $\beta$ both be?

**Theorem (the counting wall).** If disjoint sets $S, T$ with all elements in $[0, M]$ form a divisibility covering of $\{1, \dots, 2n\}$, then

$$
4^n \;\le\; (2n+1)\, M^{|S|\cdot|T|}.
$$

*Why it holds.* Multiply all the differences together to get $X = \prod (s - t)$. Disjointness makes $X$ nonzero. Each $|s-t|$ is at most $M$, so $|X| \le M^{|S||T|}$. Every $i \le 2n$ divides some factor and therefore divides $X$. Now use a classical fact about the central binomial coefficient $\binom{2n}{n}$: for each prime $p$, the largest power of $p$ dividing it is at most $2n$, so that power appears among the numbers $1, \dots, 2n$. As a result $\binom{2n}{n}$ divides $X$. Finally $\binom{2n}{n} \ge 4^n/(2n+1)$, because it is the largest of the $2n+1$ terms adding up to $4^n$.

Taking logarithms and letting $n$ grow turns this into a statement about exponents. **Any family of such coverings must satisfy $\alpha + 2\beta \ge 1$.** More precisely, $\alpha + \beta_S + \beta_T \ge 1$ when the two sets have different size exponents. If one side has a single "anchor" element, the bound becomes the much worse $\alpha + \beta \ge 1$.

Both ends of this line can be reached explicitly:

* **The lcm pair** $(\alpha, \beta) = (1, 0)$. Take $S = \{\operatorname{lcm}(1, \dots, n)\}$ and $T = \{0\}$. Every $i \le n$ divides the single difference. This is the best possible single pair: if one nonzero difference is divisible by $1, \dots, n$, then it is at least $\operatorname{lcm}(1,\dots,n)$. Putting this pair into the wall gives back the classical inequality $4^n \le (2n+1)\operatorname{lcm}(1,\dots,2n)$.
* **Baby steps and giant steps** $(\alpha, \beta) = (0, \tfrac12)$. Take giant steps $S = \{k^2 + kj : 0 \le j < k\}$ and baby steps $T = \{0, 1, \dots, k-1\}$. Their differences run through every integer from $k^2 - k + 1$ to $2k^2 - k$, which is $k^2$ consecutive integers. Any run of $i$ consecutive integers contains a multiple of $i$, so the sets cover $\{1, \dots, k^2\}$ using $k$ elements each, all smaller than $2k^2$.

The second construction shows that the motif itself is a divisibility covering, located at the edge of the wall.

The middle of the line is where things get interesting. At $\alpha = \beta = \tfrac13$,

$$
\alpha + 2\beta \;=\; \tfrac13 + \tfrac23 \;=\; 1,
$$

so there is **exactly zero slack**. According to the covering approach, this point corresponds to improving the deterministic exponent from $\tfrac15$ to $\tfrac16$, and it lies exactly on the wall. The counting argument does not rule it out, but it leaves no margin at all. A known lemma about primorial arithmetic progressions supplies one building block. Another known lemma rules out *generic* constructions, so only highly structured ones could reach the point. Nobody has yet built a covering with $(\alpha, \beta) = (\tfrac13, \tfrac13)$, and the question is open.

---

## What a negative result is good for

It would be easy to see all this as a list of failures: three promising ideas, three closed doors. That reading misses the point. The ideas failed for **general, reusable reasons**, and those reasons now work as screening tests:

* *Slack-constraint test:* does the new idea affect a term that is active at the optimum?
* *Delete-a-term test:* which legs actually hold the barrier up? (All three do.)
* *Three-way balance:* the optimum $\gamma/(1+u+w/c)$ shows exactly which ratio would have to change.
* *Closed-variable test:* is the benefit-to-cost ratio limited by injectivity and by the need to write every output?
* *Space–time invariant:* is the idea really a memory optimisation in disguise?

Any future proposal to factor faster by improving order-finding, filtering pairs, re-splitting the list, or using a side channel can be checked against these tests in minutes. And the one door they leave open has a precise description: a divisibility covering of $\{1,\dots,n\}$ with sets of size about $n^{1/3}$ and elements with about $n^{1/3}$ digits, sitting exactly on a wall with no slack. Whether such coverings exist, and whether some structured construction can reach the wall's interior, is a clean, concrete question in elementary number theory. It is also the remaining non-circular route below one-fifth.
