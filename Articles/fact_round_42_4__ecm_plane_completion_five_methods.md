# The Leaderboard Has a Shape

## What a min-plus picture of five factoring algorithms reveals about the ones that never win

Suppose you are handed a large number and told that it is the product of two primes. Your job is to find the smaller one. You have a shelf of tools: the brute-force sweep of trial division; Fermat's difference-of-squares trick; Pollard's rho, which finds factors by looking for accidental collisions; and the elliptic curve method (ECM), the most sophisticated of the classical bunch. Which one should you reach for?

The honest answer is: it depends on how big the hidden prime is. And that dependence, it turns out, has a shape — a precise geometric shape, with corners and edges and vertices — and once you see the shape you can say something surprisingly harsh about certain algorithms: *they never win, at any size, ever.* Not "they are rarely optimal." Never. They are dead arms of the plane.

This article is about that shape, how to compute it, and what happened when five factoring methods were run on one population of test numbers with one honest measure of cost.

---

## Everything is a straight line, if you take logarithms twice

Start with the standard folk knowledge. Trial division finds a prime $p$ after roughly $p$ steps. Pollard's rho finds it after roughly $\sqrt{p}$ steps — the birthday paradox at work. The elliptic curve method, in the toy regime we will care about, sits somewhere in between.

Those are all *powers of $p$*. So let us change coordinates. Write
$$k = \log_2 p$$
for the size of the hidden prime in bits, and measure the cost of an algorithm not in operations but in **bits of work**, $\log_2(\text{operations})$. In these doubly-logarithmic coordinates, "cost $\approx p^{\alpha}$" becomes the perfectly straight line
$$\mathrm{work}(k) = c + \alpha k .$$

Every algorithm is now a point $(\alpha, c)$ in a plane: a **slope** $\alpha$, the growth exponent, and an **intercept** $c$, the constant overhead measured in bits. Trial division is $\alpha = 1$. Rho and Fermat are $\alpha = 1/2$. And a whole family of methods can be plotted at once.

Two things you can do with algorithms correspond to two things you can do with these lines.

**Run one after the other.** If you compose two methods, or repeat one, the operation counts multiply, so the bit-costs *add*: the profiles add coordinatewise, $(\alpha_1 + \alpha_2,\; c_1 + c_2)$.

**Race them.** If you run two methods in parallel and keep whichever finishes first, the cost is the *minimum* of the two lines.

Addition and minimum. That pair of operations — where $\min$ plays the role of "plus" and $+$ plays the role of "times" — is a genuine algebraic structure called the **tropical semiring**, or min-plus algebra. It shows up in scheduling, in optimal control, in the combinatorics of algebraic curves. And here it shows up in a place nobody put it deliberately: the performance table of a factoring benchmark.

In this dictionary, an algorithm is a *tropical monomial*, $c \odot k^{\odot \alpha}$. A shelf of algorithms, raced against each other, is a **tropical polynomial**:
$$E(k) \;=\; \min_i \,(c_i + \alpha_i k).$$
This function $E$ — the **lower envelope** — is the honest cost of "always use the best available method at this size." Everything interesting is a statement about $E$.

The dictionary is not decoration. Min-plus distributivity really holds: composing every arm with a common post-processing step $P$ and then racing gives the same answer as racing first and then composing, because $\min(a,b) + p = \min(a+p, b+p)$. And the envelope of any finite family is a **concave, piecewise-linear function** of $k$: it is a finite minimum of straight lines, and each of its corners is a size at which the best algorithm changes hands.

---

## Five arms, one population, one currency

The numbers in this story come from a controlled experiment. Five factoring arms were run against **one** population of semiprimes and scored with **one** cost functional, so the comparison is apples to apples down to the last bit. Fitting a straight line to bits-of-work against $k = \log_2 p$ gave:

| Method | exponent $\alpha$ |
|---|---|
| trial division (uniform-size factors) | $1.00$ |
| trial division (balanced factors) | $1.14$ |
| Fermat | $0.50$ |
| Pollard rho | $0.512$ |
| ECM, stage-one bound $B_1 = 250$ | $0.718$ |
| ECM, stage-one bound $B_1 = 50$ | $0.761$ |

Three things jump out.

**First: the ECM column lands strictly inside the bracket.** $0.512 < 0.718 \le 0.761 < 1.00$. ECM is genuinely intermediate between the birthday methods and brute force — not a faster rho, not a smarter trial division, but an interpolation.

**Second: factor locality is sharp.** The population can be drawn two ways: hidden primes of *uniform* size, or *balanced* semiprimes where the two factors are comparable. Changing the draw moves rho's and ECM's exponents by at most $0.03$ — inside measurement noise. Only their intercepts shift. Trial division is the exception: its exponent moves from $1.00$ to $1.14$, replicating an earlier independent measurement of $1.09$.

**Third: ECM pays for its exponent.** In the common currency of bits, ECM's intercept exceeds rho's by $c_{\mathrm{ECM}} - c_{\rho} = +3.04$ bits, against a measured $10.29\times$ wall-clock ratio. Since $3 < \log_2 10.29 < 4$, the two independent accountings — abstract operation counts and physical seconds — agree to within a single bit. That is a nontrivial consistency check on the whole measurement.

---

## Corners, and the algebra of "does it matter?"

Here is where the tropical picture starts paying rent.

Take two arms with profiles $(\alpha_M, c_M)$ and $(\alpha_N, c_N)$. Their race $\min(c_M + \alpha_M k,\ c_N + \alpha_N k)$ is *again a single straight line* precisely when $\alpha_M = \alpha_N$. Otherwise the two lines cross exactly once, at
$$k^\star = \frac{c_M - c_N}{\alpha_N - \alpha_M},$$
and the envelope has a genuine corner there: below $k^\star$ one arm leads, above it the other does.

So "does changing the population change the algorithm's scaling?" becomes a question of tropical geometry: **does the two-regime tropical polynomial have a corner?** For rho and ECM, the two regimes have the same exponent, so the answer is no — the race is again a single line, and factor locality is exactly the statement that the corner locus is empty. For trial division, $1.00$ versus $1.14$, there is a corner, at $k^\star = (c_{\text{unif}} - c_{\text{bal}})/0.14$.

Measurement never gives exact equality, of course, so there is a quantitative version. If two exponents differ by at most $\varepsilon$ while their intercepts differ by at least $\delta$, then any corner they have must sit at $|k^\star| \ge \delta/\varepsilon$. With $\varepsilon = 0.03$, a one-bit intercept gap already pushes any hidden corner past $k = 33$ — far outside the toy window. "No corner" and "a corner beyond the horizon" are not distinguishable, and the bound says exactly how far the horizon is.

---

## Where $0.761$ comes from — it isn't a fit

The most satisfying part of the story is that ECM's intermediate exponent is *derivable*, not merely observed.

ECM tries curve after curve. On each curve, with stage-one bound $B$, the group order must be $B$-smooth for the attempt to succeed, and the set of group orders the method can see has size at most $B^2$ inside a group of order about $p$. So a single curve succeeds with probability at most $B^2/p$. To reach even a coin-flip chance of success you therefore need at least about $p/(2B^2)$ curves, and each curve costs about $B$ point operations. Multiply:

> **Theorem (ECM work lower bound).** If each curve succeeds with probability at most $B^2/p$ and the campaign reaches overall success probability $1/2$, then the total number of point operations is at least $p/(2B)$.

Now let the stage-one bound scale as a power of the target, $B = p^{\beta}$. Then $p/(2B) = p^{1-\beta}/2$ exactly, so the exponent is
$$\boxed{\alpha = 1 - \beta.}$$

This is a straight line in the $(\beta, \alpha)$ plane joining the two classical extremes: $\beta = 0$ (no smoothness budget at all) gives $\alpha = 1$, which is trial division; $\beta = 1/2$ gives $\alpha = 1/2$, which is the birthday rate of rho and Fermat. Everything in between — for $0 < \beta < 1/2$, strictly between $p^{1/2}$ and $p$ — is the ECM interpolation. The measured $0.718$ and $0.761$ are not mysterious constants; they are readings of $1 - \beta$ for a stage-one bound tuned to a toy window.

The implication runs backwards too, and this is a genuine calibration tool: if a campaign reaches success probability $1/2$ with total work at most $p^a$, then its stage-one bound must satisfy $B \ge p^{1-a}/2$. Applied to the measured $\alpha = 0.761$ at $20$-bit targets, that forces $B \ge 2^{20 \times 0.239}/2 \le 16$ — comfortably consistent with the $B_1 = 50$ that was actually used. A measured exponent strictly below $1$ *certifies* a smoothness budget growing like a positive power of $p$.

---

## The bug that ate the square root

Buried in the experiment's ledger is a cautionary tale worth its own theorem.

Pollard's rho detects a factor by computing a greatest common divisor. Computing a gcd every iteration is expensive, so implementations batch: accumulate a product over a block of $m$ iterations and take one gcd at the end. The cost is that you only ever *observe* success at multiples of $m$. The true detection time $T$ is replaced by
$$\mathrm{batch}(m, T) = m\lceil T/m\rceil.$$

This quantisation obeys a clean sandwich: $T \le \mathrm{batch}(m,T) < T + m$. And it produces a stark dichotomy.

*If $T \le m$* — the detection fits inside a single block — then $\mathrm{batch}(m,T) = m$ exactly, **independent of $T$**. All $p$-dependence is erased and the measured exponent is $0$.

*If $m \le T$* — the detection spans several blocks — then $\mathrm{batch}(m,T) \le 2T$, so the measured ratio between two sizes is within a factor of $2$ of the true ratio: the exponent survives, and only the intercept moves by at most one bit.

At toy scale, with block size $m = 2048$, rho's detection times at $k = 16$ and $k = 20$ bits are $\sqrt{p} = 256$ and $1024$. Both are below $2048$. Both get reported as $2048$. The two-point slope comes out as exactly $0$, even though the underlying times differ by a factor of four. Unbatched, the same two points give $(\log_2 1024 - \log_2 256)/(20-16) = (10-8)/4 = 1/2$ — the square-root law, on the nose, matching the measured $0.512$.

An earlier run of this experiment had the batched gcd in place and reported a rho exponent that had lost the $\sqrt{p}$ law entirely. The theorem above says this was not noise; it was a forced consequence of quantisation, and the fix (per-iteration gcd at toy sizes) restores $\alpha = 0.512$ exactly as predicted.

---

## Dead arms: the Newton polygon of a benchmark

Now the punchline.

Plot all five arms as points $(\alpha_i, c_i)$. The envelope $E(k) = \min_i(c_i + \alpha_i k)$ is concave and piecewise linear, and at every size *some* arm leads. Which ones?

**The leaderboard is sorted by exponent.** If arm $i$ leads at some size and arm $j$ leads at a larger size, then $\alpha_j \le \alpha_i$. Exponents can only go down as targets grow; dually, intercepts can only go up. The order in which methods take the crown is forced.

**An arm above the hull is dead.** Suppose arm $i$'s exponent is a weighted average of two other arms' exponents, $\alpha_i = t\alpha_j + s\alpha_l$ with $t, s \ge 0$, $t + s = 1$, but its intercept is strictly *above* the corresponding average, $c_i > t c_j + s c_l$. Then arm $i$ never leads — at any size at all. Its point lies strictly above the segment joining the other two, and the minimum of those two lines undercuts it everywhere.

**And an arm on or below the hull is alive.** Conversely, if the middle arm's point sits on or below the segment, it does lead — precisely at the crossing point of its two neighbours. So hull membership is not merely sufficient for irrelevance; it is the *exact* criterion for relevance. This is the classical Newton-polygon duality, transplanted from tropical curves onto a benchmark table: **the set of methods that ever win equals the vertex set of the lower convex hull of the $(\alpha, c)$ points.**

Apply it. The $B_1 = 50$ ECM column has both a larger exponent than rho ($0.761$ vs $0.512$) *and* a larger intercept ($+3.04$ bits). It is dominated in both coordinates, so it never leads at any physical size $k \ge 0$. Its interior exponent is real; its operational relevance is nil. Having a slope between two others buys you nothing if you sit above the hull.

The $B_1 = 250$ column is more delicate, and it yields a genuinely falsifiable prediction. Astonishingly, the three measured exponents are *exactly* collinear with rational weights:
$$0.718 \;=\; \frac{43 \cdot 0.512 + 206 \cdot 0.761}{249}.$$
So the $B_1 = 250$ column sits precisely on the line through rho and $B_1 = 50$ in exponent coordinates: it is not an independent measurement but a one-parameter family, and *only its intercept* decides its fate. The hull criterion collapses to a single scalar threshold:

> The $B_1 = 250$ column is a vertex of the hull — hence leads at some size — **if and only if** its common-currency overhead over rho is at most $3.04 \times \tfrac{206}{249} \approx 2.515$ bits.

Measure that overhead. If it comes in below $2.515$ bits, the column is a genuine vertex; above it, the column is dead forever, however attractive its exponent looks. That is a sharp, cheap, decisive experiment, and it is the natural next run.

One caveat keeps the geometry honest. The witness that the hull criterion supplies — the size at which the middle arm leads — can sit at a *negative* $k$, which is not a real prime size. On the physically accessible half-line $k \ge 0$, any positive overhead at all already makes rho strictly cheaper than the $B_1 = 250$ column everywhere. Hull membership is the right criterion on the whole line; **domination** is the right criterion on the half-line we actually inhabit.

---

## The exponent that isn't there

There is a final twist, and it dissolves the whole affine picture at large scale.

ECM's true asymptotic cost is not a power of $p$ at all. It is *subexponential*:
$$L_p(1/2, c) = \exp\!\big(c\sqrt{\log p \cdot \log\log p}\big),$$
which grows faster than any polynomial in $\log p$ but slower than any power of $p$. Concretely: for every $c > 0$ and every $a > 0$, however tiny, eventually $\log L_p < a \log p$.

Consequences follow immediately. The fitted exponent of the true ECM arm, $\log L_p / \log p$, tends to **zero**. So does the two-point chord slope actually used by the experiment, even measured over a doubling window in $k$. Every affine arm with a positive exponent — trial division, Fermat, rho, both ECM columns as fitted — is eventually beaten by the true subexponential arm, which is thus the unique eventual leader of the whole table.

And yet the subexponential arm is *not* the exponent-zero arm either: its bit-cost diverges to infinity, whereas a genuine slope-zero straight line is a constant. The subexponential cost is squeezed strictly between "exponent $0$" and "every positive exponent," and the affine plane simply has no point there. **No straight line represents ECM asymptotically.**

That is the structural explanation of everything measured. The $0.761$ is not a constant of the elliptic curve method. It is a coordinate of the *window* in which the method was observed — with a fixed stage-one bound, on toy-sized primes. Push the window out and, with the bound allowed to grow, the exponent must drift toward $0$; hold the bound fixed and the proved lower bound $p/(2B)$ pushes the fitted exponent up toward $1$ instead, like $1 - \log_2 B_1 / k$. Either way, the number on the table is a property of where you looked.

---

## Why this matters beyond factoring

The specific arms here are toy-scale, but the machinery is not.

Any time you benchmark a family of algorithms and fit power laws, you are producing a set of points $(\alpha_i, c_i)$, and the tropical geometry above applies verbatim. The lower convex hull tells you which of your methods will ever be optimal; everything above the hull is decoration. The leaderboard-is-sorted theorem tells you the order in which they must take over. The quantisation dichotomy tells you when your instrumentation, rather than your algorithm, is setting the exponent — a failure mode that here silently erased a square-root law and would have gone unnoticed without the theorem. And the subexponential result is a standing warning that a fitted exponent may be a fact about your measurement window and nothing else.

Perhaps the loveliest thing is the collinearity. Three exponents, measured independently on a noisy toy population, land exactly on a line with denominators $43$ and $206$ over $249$. That is either a coincidence or a signal that the ECM column is genuinely a one-parameter family in disguise. The hull criterion turns that observation into a single number, $2.515$ bits, that the next experiment can measure and that will settle the question one way or the other.

A leaderboard, it turns out, is a convex hull. And convex hulls have vertices — and everything else.
