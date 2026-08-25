# The Half-Step That Squares Your Accuracy

## A tale of a stubborn constant, a rectangle that's the wrong shape, and a chain of inequalities that never lies

There is a number that shows up whenever you count things one at a time and then try to compare the total with a smooth curve. It is called the **Euler–Mascheroni constant**, written $\gamma$, and it begins

$$\gamma = 0.5772156649015328606\ldots$$

You meet it the first time you add up the harmonic numbers
$$H_n = 1 + \frac{1}{2} + \frac{1}{3} + \cdots + \frac{1}{n}$$
and notice that they grow, but grow *slowly* — like the logarithm. Precisely, $H_n - \log n$ settles down to $\gamma$. That single fact quietly governs the running time of hash tables, the expected number of records in a random sequence, the density of prime factors of a typical integer, and the divergence of the sum of reciprocals of primes. It is one of the handful of constants that everyone in mathematics has to know.

And yet, after almost three centuries, nobody knows whether $\gamma$ is irrational.

This article is not about that mystery. It is about something more practical, and in its own way more satisfying: **how fast can you actually compute $\gamma$ from its definition, and can you prove — not estimate, not hand-wave, but prove with a certified inequality valid for every single index — exactly how close you are?**

The answer turns out to hinge on a single, almost childishly simple idea: *take a half step.*

---

## The problem: convergence at a crawl

Fix the sequence
$$s_n = H_n - \log(n+1), \qquad H_n = \sum_{k=1}^{n}\frac1k .$$

(The shift from $\log n$ to $\log(n+1)$ is a convenience — it makes $s_0 = 0$ and keeps everything defined from the very start.) This sequence converges to $\gamma$, and there is a beautiful reason why: it is a telescoping series in disguise. Each step forward adds
$$s_{k+1} - s_k = \frac{1}{k+1} - \log\!\left(1 + \frac{1}{k+1}\right),$$
which is the difference between a rectangle of width $1$ and height $1/m$ (with $m = k+1$) and the exact area $\int_m^{m+1} \frac{dx}{x} = \log(1 + 1/m)$ under the hyperbola across that same interval. So

$$\gamma - s_n = \sum_{m \ge n+1}\left[\frac{1}{m} - \log\!\left(1+\frac1m\right)\right],$$

the total area of all the little slivers between the staircase and the curve, from $m = n+1$ onward.

Here is the trouble. Each sliver has area about $\frac{1}{2m^2}$, so the tail is about $\sum_{m > n} \frac{1}{2m^2} \approx \frac{1}{2n}$. The error decays like $1/n$. To get ten decimal places of $\gamma$ this way you need roughly $10^{10}$ terms. To get twenty, you need $10^{20}$ — more additions than there are grains of sand on Earth. Direct summation is hopeless.

## The idea: the rectangle is the wrong shape

Look again at one sliver. You are approximating $\int_m^{m+1} dx/x$ by the rectangle of height $1/m$ — the value at the **left endpoint**. That is systematically too big, because $1/x$ is decreasing. The error is not random noise: it is a *bias*, and biases can be corrected.

The classical fix is to use the **midpoint** or, equivalently, the trapezoid: average the two ends. Summed over the whole tail, this correction telescopes into something breathtakingly simple. Half of the first rectangle sticks out and never gets cancelled, and everything else collapses. The leftover is exactly
$$\frac{1}{2(n+1)}.$$

So we define the **midpoint-corrected sequence**
$$A_1(n) = s_n + \frac{1}{2(n+1)} = H_n - \log(n+1) + \frac{1}{2(n+1)},$$
and the claim is that this humble half-step turns a $1/n$ error into a $1/n^2$ error.

**The Midpoint Acceleration Theorem.** *For every integer $n \ge 0$,*
$$A_1(n) < \gamma \qquad\text{and}\qquad \gamma - A_1(n) \le \frac{1}{12\,(n+1)^2}.$$
*In particular $\bigl|\gamma - A_1(n)\bigr| \le \dfrac{1}{12\,(n+1)^2}$.*

Notice what is *not* in that statement: there is no "for sufficiently large $n$", no unspecified constant, no hidden $O$-symbol. The inequality holds from the very first index. At $n = 0$, where $A_1(0) = 1/2$ and the bound reads $\gamma - 1/2 \le 1/12$, it is already true — the true error $0.07722$ sits at $92.66\%$ of the allowed $1/12 = 0.08333$. That is as tight as a bound can be without being false.

And the constant $1/12$ cannot be improved, because there is a matching lower bound:

**Sharpness.** *For every $n \ge 0$,*
$$\frac{1}{12(n+1)^2} - \frac{1}{36(n+1)^3} \;\le\; \gamma - A_1(n),$$
*and consequently*
$$12\,(n+1)^2\bigl(\gamma - A_1(n)\bigr) \longrightarrow 1 \quad\text{as } n \to \infty.$$

The error is not merely *at most* $\frac{1}{12(n+1)^2}$; asymptotically it *equals* it. The bound is exact in the limit.

Practically, this is a dramatic upgrade. Ten decimal places now cost about $10^5$ terms instead of $10^{10}$ — a hundred-thousand-fold speedup for one extra division.

---

## The trick: envelopes that telescope

How do you prove an inequality about an infinite sum of transcendental slivers, with a constant tight enough to be attained at $n = 0$?

The standard route is Euler–Maclaurin summation, which trades the sum for an integral plus a remainder involving Bernoulli polynomials. It works, but the remainder estimates are delicate, and it is easy to lose exactly the sharpness we want.

There is a cleaner route, and it is the technical heart of this work. It is best described as the **telescoping envelope method**, and it converts the whole problem from analysis into algebra.

Suppose you can find a single function $H(x)$, defined for $x \ge 1$, whose *one-step decrement* dominates a single sliver:
$$\frac{1}{m} - \log\!\left(1+\frac1m\right) \;\le\; H(m) - H(m+1) \qquad\text{for all real } m \ge 1,$$
and which is nonnegative. Then sum this from $m = n+1$ up to $m = N$. The right-hand side telescopes to $H(n+1) - H(N+1)$, and the left-hand side is exactly $s_N - s_n$. Let $N \to \infty$; the term $H(N+1)$ is nonnegative, so it can only help, and we conclude

$$\gamma - s_n \le H(n+1).$$

**Envelope Transfer Theorem (upper form).** *Let $H$ be nonnegative on $[1,\infty)$ and satisfy $\frac1m - \log(1+\frac1m) \le H(m) - H(m+1)$ for all $m \ge 1$. Then $\gamma - s_n \le H(n+1)$ for every $n \ge 0$.*

**Envelope Transfer Theorem (lower form).** *Let $H$ satisfy $H(m) \le \frac1m$ and $H(m) - H(m+1) \le \frac1m - \log(1+\frac1m)$ for all $m \ge 1$. Then $H(n+1) \le \gamma - s_n$ for every $n \ge 0$.*

This is the entire infinite-sum content of the subject, packaged once and reused forever. Everything after this point is a *finite* algebraic question: find good $H$'s.

For the midpoint theorem the two envelopes are
$$H_{\mathrm{up}}(x) = \frac{1}{2x} + \frac{1}{12x^2}, \qquad H_{\mathrm{lo}}(x) = \frac{1}{2x} + \frac{1}{12x^2} - \frac{1}{36x^3}.$$

Substituting $x = 1/m$, the two required step inequalities become statements about a *single real variable* — inequalities between $\log(1+x)$ and explicit rational functions:

$$\frac{12x + 18x^2 + 4x^3 - x^4}{12(1+x)^2} \;\le\; \log(1+x) \;\le\; \frac{36x + 90x^2 + 66x^3 + 12x^4 + x^6}{36(1+x)^3}, \qquad x \ge 0.$$

These are Padé-type rational approximations of the logarithm, adjusted so as to become genuine one-sided bounds. Each is proved by the oldest trick in calculus: form the difference, check that it vanishes at $x = 0$, and differentiate. The derivatives come out as

$$\frac{x^4}{6(1+x)^3} \qquad\text{and}\qquad \frac{x^3\,(12 + 12x + 6x^2 + 3x^3)}{36(1+x)^4},$$

both manifestly nonnegative for $x \ge 0$. A function that starts at zero and never decreases is nonnegative. Done.

That is the whole proof. Nothing about $\gamma$ was used except that $s_n$ converges to it. There is no integral remainder, no Bernoulli polynomial machinery, no asymptotic hand-waving — just two rational inequalities and a telescoping sum.

---

## Climbing the ladder: it keeps working

Now comes the part that makes the method feel less like a trick and more like a machine.

The midpoint theorem says the residual error of $A_1(n)$ is *asymptotically exactly* $\frac{1}{12(n+1)^2}$. So subtract it — that is, *add* it to the approximation:

$$A_2(n) = s_n + \frac{1}{2(n+1)} + \frac{1}{12(n+1)^2}.$$

If $\frac{1}{12(n+1)^2}$ really is the leading error, $A_2$ must be better. But how much better? Naively you would expect one more power of $n$. In fact you gain **two**, because the $n^{-3}$ coefficient of the tail vanishes identically. This is the ghost of the fact that odd Bernoulli numbers beyond the first are zero.

**The Quartic Acceleration Theorem.** *For every $n \ge 0$,*
$$\gamma < A_2(n) \qquad\text{and}\qquad A_2(n) - \gamma \le \frac{1}{120\,(n+1)^4},$$
*with the matching lower bound $\frac{1}{120(n+1)^4} - \frac{1}{300(n+1)^5} \le A_2(n) - \gamma$, so that*
$$120\,(n+1)^4\bigl(A_2(n) - \gamma\bigr) \longrightarrow 1.$$

The constant $1/120$ is sharp. And notice something lovely: $A_1$ approaches $\gamma$ **from below** while $A_2$ approaches it **from above**. Together they trap the constant:

**Certified Enclosure.** *For every $n \ge 0$,*
$$A_1(n) < \gamma < A_2(n), \qquad A_2(n) - A_1(n) = \frac{1}{12(n+1)^2}.$$

An interval of guaranteed width $\frac{1}{12(n+1)^2}$ containing $\gamma$, for free, at every index. Moreover $A_1$ is strictly increasing and $A_2$ is decreasing: the intervals are nested, a shrinking sequence of certified cages.

Evaluate the enclosure at the trivially cheap index $n = 0$, where $s_0 = 0$: it says
$$\tfrac12 < \gamma < \tfrac{7}{12} = 0.58333\ldots$$
with no computation at all beyond arithmetic on fractions. That already beats the bound $\gamma < 2/3$ found in textbooks.

Why stop? The next term of the pattern predicts

$$A_3(n) = s_n + \frac{1}{2(n+1)} + \frac{1}{12(n+1)^2} - \frac{1}{120(n+1)^4},$$

and indeed:

**The Sixth-Order Acceleration Theorem.** *For every $n \ge 0$,*
$$A_3(n) \le \gamma \qquad\text{and}\qquad \bigl|\gamma - A_3(n)\bigr| \le \frac{1}{252\,(n+1)^6}.$$

The three approximants interleave: $A_1(n) < A_3(n) \le \gamma < A_2(n)$.

And here is the punchline. Getting from fourth order to sixth order required *exactly one new ingredient*: a single further inequality between $\log(1+x)$ and a rational function, whose difference has derivative
$$\frac{63x^8 + 126x^9 + 98x^{10} + 35x^{11} + 5x^{12}}{210\,(1+x)^7} \;\ge\; 0.$$
The envelope transfer theorems were reused verbatim. Every other order will be the same: **one rational inequality per order, forever.**

---

## The numbers that were hiding

Look at the constants that have appeared: $\tfrac12$, $\tfrac1{12}$, $\tfrac1{120}$, $\tfrac1{252}$.

They are not arbitrary. Write $B_{2k}$ for the Bernoulli numbers — $B_2 = \tfrac16$, $B_4 = -\tfrac1{30}$, $B_6 = \tfrac1{42}$ — and compute $\frac{|B_{2k}|}{2k}$:
$$\frac{|B_2|}{2} = \frac{1}{12}, \qquad \frac{|B_4|}{4} = \frac{1}{120}, \qquad \frac{|B_6|}{6} = \frac{1}{252}.$$

The bounds are precisely the Bernoulli numbers, arriving one at a time as the sharp constant of each order. This is the Euler–Maclaurin asymptotic expansion of $\gamma - s_n$,
$$\gamma - s_n \sim \frac{1}{2m} + \frac{1}{12m^2} - \frac{1}{120m^4} + \frac{1}{252m^6} - \cdots \qquad (m = n+1),$$
appearing not as an asymptotic series with an unspecified remainder but as a **tower of two-sided inequalities, each valid at every index from zero**.

That distinction matters. An asymptotic series tells you the error is *eventually* small; it does not tell you when "eventually" starts, and famously such series diverge if you push them too far. What we have instead is a ladder of statements each of which you can *bank*: if you compute $A_3(999)$, you know — with the certainty of a proof, not a plausibility argument — that you are within $\frac{1}{252 \cdot 1000^6} \approx 4 \times 10^{-21}$ of $\gamma$.

Also worth pausing on: the shape of every derivative that appeared. $x^2$, $x^4$, $x^3(12+12x+6x^2+3x^3)$, $5x^6+5x^7+x^8$, $63x^8 + 126x^9 + 98x^{10}+35x^{11}+5x^{12}$. In every case a polynomial with **nonnegative coefficients**, whose lowest-order term has exactly the degree the Bernoulli expansion predicts. Positivity is never a hard fight; it is visible on the page. That is the structural reason the method scales.

---

## What this is really about

Three ideas are worth carrying away.

**First: bias, not noise.** The reason the harmonic sum converges so slowly is not that the approximation is bad; it is that it is *wrong in a consistent direction*. The left-endpoint rectangle always overshoots. Once you name the bias, you can subtract it, and the moment you subtract the leading bias the next one becomes visible. This is the same logic behind Richardson extrapolation, Romberg integration, and the control variates of Monte Carlo simulation. Systematic error is a gift: it is error you can predict, and predictable error can be removed.

**Second: replace an infinite process with a finite one.** The tail of the series is transcendental and infinite. The envelope transfer theorems say: never look at it. Instead find a function whose *single-step* behaviour dominates a *single* term, and the infinite sum takes care of itself by telescoping. What remains is a one-variable inequality between elementary functions — the kind of thing a first-year calculus student can verify by differentiating. Difficulty was not removed; it was *relocated* to where the tools are strong.

**Third: sharpness is a two-sided game.** It is easy to bound something from above and then wonder whether you were generous. The only honest way to know your constant is best possible is to prove a matching bound from below. Here that is what the correction terms $-\frac{1}{36m^3}$ and $+\frac{1}{300m^5}$ are for: they are deliberately slightly-worse lower envelopes, and the gap between the two envelopes, being of higher order, vanishes in the limit — which is precisely the statement that $12(n+1)^2(\gamma - A_1(n)) \to 1$. Upper bounds tell you what you have; lower bounds tell you what you cannot improve.

---

## Coda

Start with the harmonic numbers, subtract a logarithm, and you get a sequence crawling toward $\gamma$ at a rate that makes twenty decimal places physically impossible.

Add $\frac{1}{2(n+1)}$ — half a step — and the crawl becomes a walk. Add $\frac{1}{12(n+1)^2}$ and it becomes a run. Add $-\frac{1}{120(n+1)^4}$ and it becomes a sprint. Each new term costs one division and one further calculus exercise about the logarithm, and each one buys two more orders of accuracy, with an error constant that is exactly a Bernoulli number and is provably the best possible.

There is something quietly delightful about the fact that the difference between "computationally hopeless" and "twenty digits from a thousand terms" is a correction whose entire justification is: *the rectangle should have been a trapezoid.*
