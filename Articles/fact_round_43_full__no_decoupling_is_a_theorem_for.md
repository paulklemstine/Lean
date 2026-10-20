# The Sieve That Cannot Be Fooled: Why Three Clever Tricks All Hit the Same Wall

*How a single line of high-school algebra closes three doors at once in the quadratic sieve — and why the honest price tag of an algorithm must include its last step.*

---

## A machine for finding squares

Suppose someone hands you a 41-bit number $N$ — say $N = 1{,}099{,}515{,}822{,}059$ — and tells you it is the product of two primes. How do you find them?

One of the most successful answers of the twentieth century is the **quadratic sieve**, invented by Carl Pomerance in the early 1980s. Its goal is to manufacture a *congruence of squares*: two numbers $X$ and $Y$ with

$$X^2 \equiv Y^2 \pmod N, \qquad X \not\equiv \pm Y \pmod N.$$

Once you have that, $N$ divides $(X-Y)(X+Y)$ without dividing either factor, so $\gcd(X-Y, N)$ is a proper factor. The whole art is producing $X$ and $Y$.

The sieve does it by looking at the values

$$Q(x) = x^2 - N$$

for $x$ slightly larger than $\sqrt N$. These values are fairly small, and modulo $N$ each one is congruent to a perfect square, namely $x^2$. If we can multiply a selection of the $Q(x)$ together so that the product is a perfect integer square $Y^2$, then taking $X$ to be the product of the corresponding $x$'s gives our congruence.

To find such a selection, the sieve only keeps values that factor completely over small primes — primes up to some bound $B$. These are called *smooth* values. Each smooth value is recorded as a vector of exponents, reduced modulo 2: a "1" in position $p$ means $p$ appears to an odd power. A product is a square exactly when the vectors add to zero modulo 2. So the problem becomes linear algebra over the two-element field: collect more vectors (**rows**) than there are coordinates (**columns**), and a dependency is guaranteed.

That framing — rows versus columns — is the lens for everything that follows.

## The hidden half

Here is the first surprise, and it is old and beautiful. Not every prime can ever appear as a column.

If a prime $p$ divides $x^2 - N$, then $x^2 \equiv N \pmod p$. In words: **$N$ is a perfect square modulo $p$**. Roughly half of all primes have this property for a given $N$; the others can *never* divide any value $x^2-N$, no matter how long you sieve. Number theorists call the good primes the ones at which $N$ *splits*. So the real column space of the quadratic sieve is not "all primes up to $B$" but the **split set**: the primes $p \le B$ at which $N$ is a square.

For our 41-bit example with $B = 400$, there are 78 primes below 400, and exactly 41 of them are in the split set — a fraction of $0.526$. Sieve as long as you like: the other 37 never show up.

This halving is not a defect; it is free. The linear algebra only ever needs to handle about half of the primes. But it raises a tantalising question that practitioners and theorists keep returning to.

## The dream of decoupling

Every serious implementation of the quadratic sieve has three standard enhancements:

1. **Large primes.** Keep values that are smooth *except* for one larger prime $r$. When two such "partial relations" share the same $r$, multiply them: $r$ appears squared and drops out of the parity vector.
2. **Multiple polynomials.** Instead of one polynomial $x^2-N$, sieve many quadratic polynomials $A x^2 + Bx + C$, each producing small values over a short interval. This is Robert Silverman's multi-polynomial quadratic sieve.
3. **Adaptive smoothness bound.** Tune $B$ instance by instance.

Each of these looks, at first glance, as if it might change *which* columns you have to deal with. Maybe the large primes open up new columns outside the split set. Maybe different polynomials see different halves of the primes, so that a clever combination shrinks the column space. Maybe adjusting $B$ moves you off the usual trade-off curve between columns and smoothness. If any of these "decoupled" the column space from the split set, it would be a genuine new lever on the cost of factoring.

The result described here is that **none of them can**. And remarkably, it is not a statistical observation. It is a theorem, and all three cases follow from one identity.

## One line of algebra

Take any quadratic polynomial $f(x) = Ax^2 + Bx + C$ and define its **discriminant** $D = B^2 - 4AC$. Completing the square — the same manoeuvre that gives the quadratic formula — produces

$$4A \cdot f(x) = (2Ax + B)^2 - D.$$

That is all. But read it the way the sieve does. If a prime $p$ divides $f(x)$, then $p$ divides the right-hand side, so

$$(2Ax+B)^2 \equiv D \pmod p.$$

**The discriminant is a square modulo $p$.** This holds for every prime whatsoever, even primes dividing $A$ and even $p=2$. Every column that any quadratic polynomial can ever produce lies in the split set of its discriminant.

The converse is just as clean. If $p$ is an odd prime not dividing $A$, and $D \equiv r^2 \pmod p$, then choosing $x \equiv (r - B)(2A)^{-1} \pmod p$ makes $2Ax + B \equiv r$, so the right side vanishes modulo $p$, and since $4A$ is invertible modulo $p$, $p$ divides $f(x)$. Together:

> **Column Theorem.** For an odd prime $p$ not dividing $A$, the prime $p$ divides some value of $f$ if and only if the discriminant of $f$ is a square modulo $p$. In other words, the column set of a quadratic polynomial *is* the split set of its discriminant.

The column space and the split set are not two things that happen to coincide. They are the same object.

## Door one: multiple polynomials

Silverman's polynomials are built so that every one of them has discriminant $4N$ (or $kN$ times a square, with a small multiplier $k$). Concretely, one picks $A = q^2$ for a prime $q$ at which $N$ splits, finds $b$ with $b^2 \equiv N \pmod{q^2}$, sets $c = (b^2-N)/A$, and sieves $f(x) = Ax^2 + 2bx + c$. Then $(2b)^2 - 4Ac = 4N$, always.

Plug that into the Column Theorem. Every polynomial in the family has the same discriminant, so at every odd prime not dividing the leading coefficients, they all have *exactly the same* columns. A prime that is a column for one is a column for all. The intersection of the column sets equals the union equals the split set of $N$. And multiplying a discriminant by a square $s^2$ changes nothing at primes not dividing $s$ — so $kN$ and $4kN$ have the same split set too.

This corrects a tempting mistake, one that was actually made in an earlier report in this line of work. The reasoning went: "each polynomial sees about half the primes; two polynomials together constrain the columns to a quarter." That is what happens for **two unrelated discriminants** — two independent coin flips, each landing heads half the time, land heads together about a quarter of the time. In measurements the intersection for unrelated discriminants came out between $0.244$ and $0.317$ of the primes. But Silverman's forms are not unrelated: they share one discriminant, so the "two constraints" are literally the same constraint stated twice. The measured column fraction for the multi-polynomial sieve is $0.487$ to $0.505$ of the primes up to $B$ — the same as for a single polynomial. The conclusion that multiple polynomials cannot decouple the columns survives; the proposed mechanism and the number did not.

## Door two: large primes

The large-prime trick fares no better, and for the same reason. If $x^2 - N = s \cdot r$ with $r$ a prime of any size, then $r$ divides a value of $x^2-N$, so $N$ is a square modulo $r$: **the large prime itself lies in the split set** (at any bound at least $r$). There is no such thing as a non-split large prime in the quadratic sieve. Indeed, the classical analyses of large-prime variations define their prime sets as exactly the primes $q$ with $N$ a square modulo $q$ — the theorem is already baked into the definitions. In experiments, the number of large-prime columns equalled the number predicted by the split set on all 68 of 68 test instances.

What about combining two partial relations that share $r$? The product $(s_1 r)(s_2 r)$ has $r$ to an even power, so $r$ vanishes from the parity vector. Every prime that survives to an odd power divides $s_1$ or $s_2$, hence divides a value of $x^2-N$, hence is a small split prime. **A large-prime pair adds no new column at all.** Raising the bound from $B$ to a larger $L$ simply enlarges the split set monotonically: the small split set sits inside the large one.

So the large-prime variation is not a discovery about column space; it is a *monotonicity identity*. That is precisely why every production quadratic sieve ships it: it is free rows, and it costs nothing structurally.

## Door three: adaptive bounds

The third channel — choosing $B$ per instance — was tested by watching how the number of columns $Q$ scales with the number of primes $m$ below $B$. If adaptivity bought a second degree of freedom, $Q$ would move off the line $Q \approx m/2$. Instead the measured log-log slope was

$$\frac{d \log Q}{d \log m} = 0.99718 \pm 0.03722.$$

Slope one. Changing $B$ slides you *along* the ray $Q \approx m/2$, never off it. The bound is a reparametrisation, not a new knob.

## The real lesson: pay the whole bill

The most transferable lesson of this work is not about number theory at all. It is about accounting.

An earlier analysis of adaptive $B$ priced only the **sieve** — the work of scanning values and testing them for smoothness. On that metric, increasing the number of columns looked like a win: the measured elasticity was

$$\frac{d \log(\text{sieve cost})}{d \log Q} = -0.1490 \pm 0.1299,$$

negative on 73 of 80 instances. More columns, cheaper sieving. That analysis even announced an optimum and an oracle saving of about 5%.

But factoring is not finished when sieving is. The rows must be reduced by Gaussian elimination over the two-element field, and that cost grows with the number of columns $Q$ — in the experiments, the linear-algebra term grew by factors from 146 to 3981 while the sieve term was flat above $B = 2400$. Priced on the **complete** cost, the sign flips:

$$\frac{d \log(\text{sieve} + \text{linear algebra})}{d \log Q} = +0.0787 \pm 0.1472,$$

positive on 60 of 80 instances, with a $t$-statistic near $+4.8$. The announced optimum and the 5% prize evaporate.

Why can a sign simply invert? There is a crisp theorem behind it. Write the total cost as $S + L$ (sieve plus linear algebra), both depending on $u = \log Q$. Then the elasticity of the total is a weighted average of the separate elasticities, with weights equal to each term's share of the bill:

$$\frac{d}{du}\log(S+L) = \frac{S}{S+L}\cdot\frac{S'}{S} + \frac{L}{S+L}\cdot\frac{L'}{L} = \frac{S' + L'}{S+L}.$$

The total elasticity is therefore always between the two separate elasticities, and it is positive **exactly when** $L' > -S'$ — when the absolute growth of the linear algebra beats the absolute decline of the sieve. Nothing prevents a negative sieve elasticity from coexisting with a positive total one; in fact, as soon as the elimination work starts to matter, that is the expected situation.

The rule this earns is simple enough to put on an index card: **a per-instance lever on factoring cost must be priced against the complete cost of reaching a factor. Pricing one stage alone can invert the sign.** Any report of how cost responds to a parameter must say which terms are in the cost. Readers who work on compilers, databases or machine-learning pipelines will recognise the pattern: optimising one stage while another stage silently absorbs the cost.

## The one door left ajar

Is anything left? Yes — one lever, and it lives on the *other* side of the matrix.

Because the column set depends only on the shared discriminant $kN$, adding one more Silverman polynomial costs **zero** new columns. It only adds rows. This gives the cleanest statement of what multi-polynomial sieving actually buys:

> **Row-Side Lever.** Use any number $T$ of quadratic polynomials sharing the discriminant $D$. As soon as you have collected more nonzero $B$-smooth values than there are split primes of $D$ up to $B$, some nonempty sub-product of them is a perfect square. The threshold does not depend on $T$.

In our demonstration with $B = 120$, the split set has 15 primes, so 16 smooth values always suffice. With one polynomial on an interval of 40,000 points we found only 4 smooth values; with two polynomials, 6; with four, 13; with eight, 33 — and a square emerged from the first 16, using values drawn from four different polynomials. The columns touched never exceeded 15.

There is a catch, and it is quantitative. A Silverman polynomial on an interval $[-M, M]$ takes values ranging from about $-N/A$ at the centre to $AM^2 - N/A$ at the ends. Balancing the two gives a clean minimax theorem: for every leading coefficient $A > 0$,

$$\max\left(\frac{N}{A},\ AM^2 - \frac{N}{A}\right) \ \ge\ M\sqrt{N/2},$$

with equality exactly at $A = \sqrt{2N}/M$, where the values are about $0.707\, M\sqrt N$. But the leading coefficient must be $q^2$ for a prime $q$ larger than $B$, so $A \gtrsim B^2$. Asking for the ideal $A$ to be available therefore imposes a **gate**, roughly $B^2 M \lesssim \sqrt{N/2}$. At 41–42 bits, with realistic $B, M \ge 1000$, this gate fails badly: for every $N < 2^{42}$, one has $B^2 M > 600\sqrt{N/2}$. That is nearly three orders of magnitude. This explains the measured saturation: as $T$ grows, the forms are pushed to leading coefficients far from ideal (the ratio of actual to ideal $A$ ran from 13.8 to 1477), their values grow, smoothness becomes rarer, and the gain flattens out at about four polynomials.

## Where the wall ends

Every theorem has a boundary, and this one is precise. The no-decoupling argument is a theorem about **differences of squares**: the sieved values are of the form $(\text{something})^2 - D$ with $D$ tied to $N$. Leave that world and the wall disappears.

The smallest example fits in a sentence: $3^3 - 2 = 25$ is divisible by $5$, yet $2$ is not a square modulo $5$ (the squares modulo 5 are $0, 1, 4$). For cubic values $x^3 - N$, non-split primes appear as columns immediately; for our 41-bit $N$, eleven non-split primes below 200 divide some $x^3 - N$ within a short range.

That is the only route by which any of these three channels could ever buy something new. And it is not the quadratic sieve anymore — it is the direction of the number field sieve, where the governing object is no longer a quadratic discriminant but the arithmetic of a higher-degree number field. There, which primes appear is controlled by how the prime factors in that field — a question whose answer is governed by the Chebotarev density theorem rather than by a single square root.

## The takeaway

For quadratic-form sieving, the question "can large primes, multiple polynomials, or adaptive bounds decouple the column space from the split set?" is closed: **no**, by a theorem, for one reason — every form whose discriminant is tied to $N$ turns a prime divisor of its value into a square root of that discriminant. One genuine lever survives, the row-side gain of extra polynomials, and it is strangled at small sizes by an explicit gate. And underneath it all is a lesson worth more than any one algorithm: **count the whole cost, or the sign of your conclusion may be wrong.**
