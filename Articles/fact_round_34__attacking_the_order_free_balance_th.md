# The Biggest Term in the Room: How to Tell Which Costs Really Matter

*A story about factoring large numbers, a sieve that looked important and wasn't, a reuse trick that looked like slack and wasn't, and a one-line test that tells them apart.*

---

## A number with two secret halves

Choose two large primes, $p$ and $q$, and multiply them: $N = pq$. Multiplying takes a fraction of a second. Going backwards, from $N$ to $p$ and $q$, is a famously hard problem. Much of the public-key cryptography in use today assumes that it stays hard.

That assumption has never been proved. No one has shown that factoring needs superpolynomial time in any reasonable model of computation. What we do have are **upper bounds**: concrete algorithms with concrete running times. One way to keep score is to look at algorithms that are *deterministic*, meaning they use no randomness and no unproved conjectures. For these, the score is the exponent $e$ in a running time of roughly $N^{e}$:

- Trial division tries every candidate up to $\sqrt N$, so $e = 1/2$.
- Lehman's method (1974) gets $e = 1/3$.
- Pollard and Strassen, using fast polynomial arithmetic, got $e = 1/4$.
- In 2021 David Harvey brought the exponent down to $e = 1/5$.

That last step took nearly half a century. This article is about what holds Harvey's $1/5$ in place, and about a simple, general question that turns out to be very useful:

> When a running time is the maximum of several costs, which of those costs actually decide the answer?

## The anatomy of a balance

Many clever algorithms share a basic shape. You pick some tuning knobs, and the total cost is set by whichever part of the work is slowest. Turning a knob makes one part cheaper and another part more expensive. The best setting is the point where the slowest parts are exactly level, like a mobile hanging perfectly still.

Harvey's algorithm can be described this way. Simplified to its exponents, it has two knobs. One is the size $r = N^{a}$ of a family of candidate "pairs". The other is the length $m = N^{b}$ of a list of precomputed "baby steps", the stored powers you build once and look up repeatedly in the classic *baby-step giant-step* strategy. Ignoring logarithmic factors, three costs compete:

- the **pair family**, which costs about $r$, exponent $a$;
- the **baby-step list**, which costs about $m$, exponent $b$;
- the **interior search** that remains, which costs about $N^{1/2}/(r^{1/2}m)$, exponent $\tfrac12 - \tfrac a2 - b$.

The total exponent is the largest of the three:

$$\text{cost}(a,b) \;=\; \max\Big\{\, a,\;\; b,\;\; \tfrac12 - \tfrac a2 - b \,\Big\}.$$

The first two terms want $a$ and $b$ small. The third wants them large. The balance point is where all three are equal. Setting $a = b = t$ and $t = \tfrac12 - \tfrac t2 - t$ gives $t = \tfrac15$. So the knobs settle at $a = b = 1/5$, and Harvey's exponent comes out of three equal weights.

It is also easy to see that nothing in this model does better. Add the three terms with weights $\tfrac15, \tfrac25, \tfrac25$:

$$\tfrac15\cdot a + \tfrac25\cdot b + \tfrac25\cdot\Big(\tfrac12 - \tfrac a2 - b\Big) \;=\; \tfrac15 .$$

A weighted average of three numbers can't exceed their maximum, so the maximum is always at least $1/5$. The same argument shows the optimum is **unique**: the cost equals $1/5$ only when $a = b = 1/5$.

## The suspicious fourth term

A fuller account of the algorithm includes a fourth cost, a *smoothness sieve*. Its size is roughly $M^{1/2} = (N/r)^{1/4}$, which has exponent $\tfrac14(1-a)$. In practical terms it is not small. At realistic sizes such as $N \approx 2^{100}$, once the logarithmic factors are put back, this "M-leg" was estimated to take about a quarter of the total budget. An earlier analysis listed it as one of three co-leading terms that hold up the exponent.

So it seems like an obvious target. If you could make the sieve cheaper, surely the exponent would drop.

It wouldn't. The main finding of this work is a correction:

> **The M-leg is exponent-redundant.** Adding the term $(N/r)^{1/4}$, deleting it, or making it *completely free* leaves the optimal exponent at exactly $1/5$.

The check is short. At the balance point $a = 1/5$, the M-leg has exponent $\tfrac14\big(1-\tfrac15\big) = \tfrac15$. That matches the other three exactly, so adding it can't raise the optimum. Removing it can't lower the optimum either, because the other three already force $1/5$ on their own. The sieve looks expensive and sits right at the level of the balance, but it has no effect on the answer.

There is more. Generalize the M-leg to $(N/r)^{\theta}$ for any exponent $\theta \ge 0$, and the optimal exponent becomes the exact function

$$V(\theta) \;=\; \max\Big\{\tfrac15,\; \tfrac{\theta}{1+\theta}\Big\}.$$

The graph is flat at $1/5$ until $\theta = 1/4$, and from there it rises. The real sieve has $\theta = 1/4$, which is precisely the corner. It is **active but redundant**: it touches the maximum at the optimum, yet deleting it changes nothing. For any $\theta > 1/4$, though, no setting of the knobs reaches $1/5$, and the term would start to matter.

The lesson here is uncomfortable. A term can be big, and can even be tight at the optimum, and still have no leverage at all.

## A one-line test that anyone can run

This leads to the most reusable idea of the work. Suppose a cost is a maximum, $\max\{T_1, \dots, T_k\}$, minimized over some parameters. Which of the $T_i$ are worth trying to improve?

> **The delete-a-term screen.** A term is worth optimising if and only if deleting it, or making it free, changes the minimax value.

The proof is about as short as proofs get. Write $F$ for the maximum of all the terms *except* $T$. Any improved version $T'$ of the term satisfies $\max\{F, T'\} \ge F$, so no improvement can push the value below the minimum of $F$ alone. Deleting $T$ is the most extreme improvement possible. So if deleting it doesn't lower the value, nothing else will. In the other direction, if deleting it does lower the value, then a "free" version of $T$ is a modification that gets there.

The value of the screen is its cost. It is a small linear program that takes an afternoon to set up, and running it before spending months on a term can save those months. Applied to Harvey's four terms, it gives a clean classification:

- Remove the M-leg: the value stays at $1/5$. **Redundant.**
- From the three that remain, delete the interior, the pair family, or the baby-step list: the value **drops to $0$** (over the natural range $1 \le r, m \le N$). Each of the three is **load-bearing**.

So exactly three of the four terms carry the exponent. The M-leg counts as a "co-leader" only by size, never by exponent.

One caution matters in practice. Redundancy is always measured relative to the terms you keep. With the M-leg still present, deleting the interior *alone* leaves the value at $1/5$, because the M-leg steps in and becomes the binding term. Screening is a question you ask about one term against a fixed set of others. You run it, prune, and then run it again.

## The reuse that looked like slack

The second main result runs the other way. It starts with something that looked like waste and shows that it is essential.

The baby-step list is a reuse trick. You compute the $m$ stored powers once, then consult them over and over while searching the interior. A natural question is whether the reuse is really needed. Could a cleverer arrangement drop the baby-step split altogether and sweep the whole search space in one go?

One proposal did exactly that. It merged the grid of pairs and the interior into a single product tree, the fast polynomial machinery behind the classical $N^{1/4}$ algorithm. In the exponent model the merged sweep costs the square root of the joint search space, $\sqrt{r\cdot N^{1/2}/r^{1/2}}$, which has exponent $\tfrac14 + \tfrac a4$. Together with the cost $a$ of enumerating pairs, the total is

$$\max\Big\{a,\; \tfrac14 + \tfrac a4\Big\},$$

and its smallest possible value is $1/4$, at $a = 0$.

So removing the baby-step split deletes the $m$ term entirely. A three-term balance with value $1/5$ becomes a two-term balance with value $1/4$. The penalty is exactly

$$\tfrac14 - \tfrac15 = \tfrac{1}{20},$$

which means the merged method is slower by a factor of $N^{1/20}$.

This was also tested in practice. A working implementation was built, with genuine number-theoretic transforms for the product trees and remainder trees for evaluating polynomials at many points. It is a *correct* factoring algorithm. Fitting how its running time grows with the size of the input gave a dominant exponent of $0.2500$, and the fitted penalty slope came out between $0.046$ and $0.052$, against the predicted $1/20 = 0.050$. The experiment agrees with the theory, and an optimistic table of constants that had been circulating does not survive the fit.

Two simple limits confirm the picture:

- **No split at all** ($m = 1$, so $b = 0$): the cost becomes $\max\{a, \tfrac12 - \tfrac a2\}$, whose minimum is $1/3$, Lehman's exponent from fifty years ago.
- **Any unbalanced split**: if $b \ne 1/5$, then *every* choice of $a$ gives a cost strictly above $1/5$. The baby-step list has to be exactly balanced, not just roughly right.

So the reuse of $m$ is not slack. It is a load-bearing part of the record.

## Where to aim next

The screen does more than reject targets. It also prices them before any work is done. Suppose someone could build the baby-step table faster, in $m^{1-\varepsilon}$ operations instead of $m$. The model then gives the exact new exponent:

$$\frac{1-\varepsilon}{5-3\varepsilon} \;<\; \frac15 \quad\text{for every } \varepsilon > 0.$$

For example, $\varepsilon = 1/4$ would give $3/17 \approx 0.176$. Alternatively, suppose someone shrank the interior search by a factor of $N^{\delta}$. The exponent would become exactly $(1-2\delta)/5$. Setting the two equal gives an *exchange rate* between the two levers: a discount of $\varepsilon$ on the table is worth exactly the same as an interior gain of $\delta = \varepsilon/(5-3\varepsilon)$.

The same arithmetic caught an error. A target that had been proposed, $N^{(1/2-\delta)/5}$, is off by a factor of two. At $\delta = 0$ it would claim exponent $1/10$, below the floor of $1/5$ that the model itself proves. The correct value is $(1-2\delta)/5$. The general principle: check the arithmetic of a target before committing effort to it.

After this round, the map is short. The pair family was attacked earlier and ruled out. The M-leg is now known to be redundant. That leaves the **baby-step list and the interior search that depends on it**, the only load-bearing terms never attacked with a power-of-$N$ mechanism.

## A side road: when the gcd trick gives itself away

The work also extends an older counting result about a classic factoring trick. Pick a random $a$ and an exponent $E$, and compute $\gcd(a^{E} - 1,\, N)$. If $a^{E} \equiv 1$ holds modulo exactly one of the two primes, the gcd is that prime, and $N$ is factored.

How many $a$ make this work? By the Chinese remainder theorem, $a$ corresponds to a pair of residues, one modulo $p$ and one modulo $q$. Modulo $p$, exactly $d_p = \gcd(E, p-1)$ nonzero residues satisfy $x^{E} = 1$, and similarly $d_q = \gcd(E, q-1)$ modulo $q$. Counting the pairs where exactly one side works gives the **general-exponent reveal identity**:

$$R(E) \;=\; d_p\,(q-1) \;+\; d_q\,(p-1) \;-\; 2\,d_p\,d_q .$$

It holds for *every* exponent $E$. For the classic choice $E = N-1$, both gcds become the same number $g = \gcd(p-1, q-1)$, and the formula reduces to the earlier count $g(q-1) + g(p-1) - 2g^{2}$. It also fits a neat four-way bookkeeping: "fails on both sides", "succeeds on exactly one side" and "succeeds on both sides" together account for all $(p-1)(q-1)$ units.

There is a twist at the extreme. The trick works best when $g$ is as large as possible, which happens when $p - 1$ divides $q - 1$, i.e. $q = k(p-1) + 1$. Then the revealing fraction is $1 - 1/k$, close to $1$. But in that same situation $N = pq$ satisfies the quadratic

$$k\,p^{2} - (k-1)\,p - N = 0,$$

and its discriminant is a perfect square:

$$(k-1)^{2} + 4kN \;=\; \big(2kp - (k-1)\big)^{2}.$$

So for small $k$ a single integer square root gives $p$, and no randomness is needed. The case $q = k(p-1) - 1$ works the same way. The cases where this family of tricks works best are exactly the cases already solved by high-school algebra.

## What a "kill" is worth

None of this lowers the exponent. Harvey's $1/5$ still stands, and it is still only an upper bound; no one knows how far below it the truth lies. Still, the effort was not wasted. The record now has fewer false leads. The sieve that looked important has no leverage. The reuse that looked dispensable is essential, by exactly $N^{1/20}$. And there is a screening test, "delete it and see if the answer moves", that applies to any problem whose cost is the maximum of several competing terms, in cryptography or anywhere else.

So the remaining question is concrete: can a table of $m$ stored powers be built, in a way that still supports fast lookups, in fewer than about $m$ operations? The model says that any genuine saving there would go straight into the exponent.
