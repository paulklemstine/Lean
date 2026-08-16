# The Primes Through a Logarithmic Lens: A Fractal That Isn't

## A tempting picture

Take the prime numbers $2, 3, 5, 7, 11, 13, \dots$ and squint at them from far away. They thin out: by the Prime Number Theorem, the number of primes below $x$ is about $x/\log x$, so among the first million integers only about $7.2\%$ are prime, and among the first $10^{12}$ only about $3.6\%$. In the usual sense of "density," the primes vanish. They occupy zero proportion of the number line.

But zero density is a blunt instrument. Fractal geometry offers a finer one. A Cantor set also has zero density in the interval, yet it has a rich internal structure captured by its *dimension* — a number, often not a whole number, that measures how a set fills space at ever smaller scales. The Cantor middle-thirds set has dimension $\log 2/\log 3 \approx 0.631$: more than a scatter of points, less than a line.

So: what is the fractal dimension of the primes?

Asked naively the question is empty, because the primes sit inside the integers as an infinite, spread-out set, and dimension is a statement about small scales, not large ones. To make it meaningful, we need a lens that pulls the primes *together* — that compresses the infinite tail of large primes into a finite window, so that "small scale" starts to mean something.

Here is the lens. Send each prime $p$ to the real number
$$\iota(p) = \frac{1}{\log p},$$
and measure the distance between two primes by
$$d(p,q) = \left|\frac{1}{\log p} - \frac{1}{\log q}\right|.$$

This is a beautiful choice. It maps every prime into the interval $(0,\, 1/\log 2\,]$, with $2 \mapsto 1.4427$, $3 \mapsto 0.9102$, $5 \mapsto 0.6213$, $101 \mapsto 0.2167$, $10^{9}+7 \mapsto 0.0483$. Big primes crowd toward $0$; the point $0$ itself is "the prime at infinity." And twin primes such as $(101,103)$ end up genuinely close: their $d$-distance is about $0.0004$. The picture is irresistible — a self-similar-looking dust accumulating at the origin, thickened wherever primes come in tight pairs. Call the resulting set of points

$$\mathcal{P} = \left\{ \tfrac{1}{\log p} : p \ \text{prime} \right\} \subset \mathbb{R},$$

the **prime fractal**.

The natural conjecture, and the one that launched this investigation, was that $\mathcal{P}$ has fractal dimension $1 + \varepsilon$, where $\varepsilon > 0$ is a number secretly measuring the abundance of twin primes. The reasoning went: the total length of the primes in this metric is $\sum_p 1/(p \log p) \sim \log\log x$, which diverges, so the primes are "long enough" to be at least one-dimensional; and twin pairs, sitting at distance $\sim 1/(p\log p)$ from each other, add wrinkles that push the dimension above $1$. If twins are infinite, the primes are more than a line.

Every clause of that conjecture turns out to be false — and the reasons why are more interesting than the conjecture.

## Result 1: the length is finite, and equals $1/\log 2$

Start with the length. Walk along the primes in order, $2 \to 3 \to 5 \to 7 \to \cdots$, and add up the $d$-distances travelled. Because $\iota(p) = 1/\log p$ is *decreasing* in $p$, the walk is monotone: every step moves left, toward $0$. So the sum telescopes.

**Total Length Theorem.** *Let $p_0 = 2 < p_1 = 3 < p_2 = 5 < \cdots$ be the primes in increasing order. Then for every $n$,*
$$\sum_{i=0}^{n-1} d(p_i, p_{i+1}) = \frac{1}{\log 2} - \frac{1}{\log p_n},$$
*and as $n \to \infty$ this converges to $1/\log 2 \approx 1.4427$. More generally, any strictly increasing sequence of integers $\ge 2$ has total $d$-length at most $1/\log 2$.*

The proof is one line: consecutive terms cancel, and $1/\log p_n \to 0$. The prime fractal is not a divergent, space-filling object; it is a *rectifiable* set of finite length, and the length is a universal constant that doesn't even know about primality. Every increasing sequence starting at $2$ — the primes, the integers, the powers of two — has $d$-length at most $1.4427$.

The heuristic behind the conjecture was doubly mistaken: the steps of the walk do not sum to $\sum_p 1/(p\log p)$, and that series converges anyway. The sum that grows like $\log\log x$ is $\sum_{p \le x} 1/p$; inserting the extra factor $1/\log p$ makes it convergent.

## Result 2: the Hausdorff dimension is exactly $0$

Now for the dimension itself. The classical notion, due to Hausdorff, measures a set by covering it with tiny pieces and asking how the total $s$-th power of the diameters behaves. The dimension is the critical exponent $s$ at which the answer flips from $\infty$ to $0$.

**Hausdorff Dimension Theorem.** *The prime fractal has Hausdorff dimension $0$. So does the closure $\{0\} \cup \mathcal{P}$, which is a genuine compact subset of the line. So does the image of any subfamily of primes whatsoever — twin primes, Sophie Germain primes, primes of the form $n^2+1$.*

The reason is soft and completely decisive: the set is countable, and every countable subset of a metric space has Hausdorff dimension $0$. You can cover the $n$-th point by an interval of length $\delta 2^{-n}$; for any exponent $s > 0$ the total $\sum (\delta 2^{-n})^s$ is as small as you like.

That single observation kills the conjecture at the root. Not only is the dimension not $1 + \varepsilon$; it is not even $1$. And crucially, *no arithmetic fact can change this*. The twin prime conjecture — one of the most famous open problems in mathematics — is irrelevant here, because the twin primes form a countable set no matter how many of them there are. There is no route from Hausdorff dimension back to arithmetic.

## Result 3: there is no dust

One might hope the dust is still there, just invisible to Hausdorff dimension. It is not there at all.

**Isolation Theorem.** *Every point of the prime fractal is isolated: around each $1/\log p$ there is a positive radius containing no other point of $\mathcal{P}$. The only accumulation point of $\mathcal{P}$ is $0$, which is not itself in $\mathcal{P}$.*

The reason: above any height $t > 0$ there are only finitely many primes with $1/\log p \ge t$, namely those with $p \le e^{1/t}$. Finitely many points can always be separated. So the prime fractal is a discrete sequence marching monotonically down to $0$ — topologically as simple as $\{1, 1/2, 1/3, \dots\}$. There is nothing fractal about it in the local sense at all.

The twin primes, meanwhile, retain exactly one metric shadow:

**Twin Primes as a Metric Statement.** *There are infinitely many twin primes if and only if $0$ lies in the closure of the twin subfractal $\{1/\log p : p, p+2 \text{ both prime}\}$.*

That is a genuine reformulation — but of an entirely topological kind, concerning a single point. And a single point contributes nothing to any dimension. On top of that, the conjecture's estimate of the twin scale was off:

**Twin Scale Theorem.** *For a twin pair $(p, p+2)$ with $p \ge 2$,*
$$d(p, p+2) \le \frac{2}{p (\log p)^2}.$$

Not $\sim 1/(p\log p)$ as the heuristic assumed: an extra factor of $\log p$ smaller. Twins are even closer together than advertised, which makes them even less able to spread the set out.

## Result 4: but the box dimension really is $1$

Here the story turns. There is a second, coarser notion of dimension — the *box-counting*, or Minkowski, dimension. Rather than allowing clever covers of wildly different sizes, it insists on a uniform grid: chop the line into boxes of width $1/m$, count how many boxes $N(m)$ the set meets, and set
$$\dim_{\mathrm{box}} = \lim_{m\to\infty} \frac{\log N(m)}{\log m}.$$
For a line segment $N(m) \asymp m$ and the dimension is $1$; for a single point $N(m) = 1$ and it is $0$; for the Cantor set the count grows like $m^{0.631}$.

Box dimension is famously *not* insensitive to countability: countable sets can have positive box dimension, because the uniform grid cannot chase a set into a cleverly chosen cover. And that is exactly what happens here. Concretely, the box at scale $1/m$ containing the prime $p$ has index $\lfloor m/\log p \rfloor$, and $N(m)$ is the number of distinct such indices.

**Box Dimension Theorem.** *For the prime fractal, $\log N(m)/\log m \to 1$. Both the upper and lower box dimensions equal $1$ exactly.*

Two halves make this work.

The **upper bound** is free and structural: $\mathcal{P}$ lives inside $[0,2]$, so it can meet at most $2m+1$ boxes of size $1/m$, giving $\log N(m)/\log m \le 1 + O(1/\log m)$. In fact the same argument shows something worth stating on its own:

**Universal Ceiling.** *Any bounded subset of the real line has box dimension at most $1$.*

So the conjectured value $1 + \varepsilon$ was never available to any set on the line — not because of the primes, but because of the ambient dimension. No configuration of twin primes, however dense, could ever have produced it.

The **lower bound** is where arithmetic enters. Here one needs to know that the primes below some height $Y$ genuinely land in *different* boxes, and that there are many of them. The separation is elementary calculus: for integers $2 \le p < q$ one has $\log q - \log p \ge 1/(2p)$, and running this through the map $t \mapsto 1/\log t$ shows that whenever $2Y(\log Y)^2 \le m$, distinct primes $p \le Y$ occupy distinct boxes of width $1/m$. So $N(m) \ge \pi(Y)$, the number of primes below $Y$.

To make that useful one needs a lower bound on $\pi(Y)$ — a Chebyshev-type estimate. The classical route works: the central binomial coefficient $\binom{2n}{n}$ exceeds $4^n/n$ and factors into primes below $2n$, each appearing to a power whose contribution is at most $2n$, so $4^n/n \le (2n)^{\pi(2n)}$. Taking logarithms gives
$$\pi(n) \ \ge\ \frac{n}{8\log n} \qquad (n \ge 8).$$
Choosing $Y \approx m/(\log m)^3$ — the largest value the separation condition allows — yields
$$N(m) \ \ge\ \frac{m}{16 (\log m)^4},$$
and combined with the ceiling $N(m) \le 2m+1$ this forces $\log N(m)/\log m \to 1$.

So the prime fractal is a **dimension-irregular** set: its Hausdorff dimension is $0$ and its box dimension is $1$, the maximum possible gap for a subset of the line. That gap is itself the punchline. Self-similar fractals — Cantor sets, Sierpiński gaskets, Koch curves — have equal Hausdorff and box dimensions. The primes under the logarithmic lens do not, which is a precise way of saying they are *not* self-similar, not a fractal curve, not a wrinkled line. They are a thin sequence that a rigid grid overestimates and a flexible cover sees through.

The value $1$ is also robust: it is not an artefact of using grid boxes. Any interval of length $1/m$ meets at most two grid boxes, so any cover of $\mathcal{P}$ by intervals of length $1/m$ needs at least $N(m)/2$ of them. However cleverly you cover the primes by equal small intervals, you need $m^{1-o(1)}$ of them.

## Result 5: how thin the line really is, and the blind spot

Chebyshev's *upper* bound $\pi(x) \le 2.4\,x/\log x$ (valid for large $x$) can be pushed through the same machinery, splitting the primes at $p \le m$ and $p > m$, to give a matching ceiling:

**Logarithmic Defect Theorem.** *Eventually, $N(m) \le 5m/\log m$; consequently $N(m)/m \to 0$.*

So although the box dimension is exactly $1$, the prime fractal has **zero one-dimensional Minkowski content**: it occupies a vanishing fraction of the boxes a real interval would occupy. The primes "fill out a line" only up to a logarithmic factor, and they carry no length in the box-counting sense. The dimension $1$ is real, but it approaches $1$ from below at a rate $\log N(m)/\log m \approx 1 - \log\log m/\log m$ — and that *rate*, invisible to the dimension itself, is the arithmetic signal.

Which brings the final blow to the original programme:

**Dimension Blindness.** *Apply the same construction to all integers $\ge 2$, forming $\{1/\log n : n \ge 2\}$. It has Hausdorff dimension $0$ and box dimension $1$ — exactly the same two numbers as the primes.*

For the integers, the lower bound is even easier: no Chebyshev theorem is needed, since one may simply count the $Y-1$ integers below $Y$. The conclusion is stark. Neither dimension of the logarithmic embedding can tell the primes from *all the integers*. A quantity that cannot distinguish $\{2,3,4,5,6,\dots\}$ from $\{2,3,5,7,11,\dots\}$ certainly cannot encode the twin prime conjecture.

## What survives

The dream — read the twin prime conjecture off a fractal dimension — is dead, and provably so. What replaced it is a sharp, complete description of a natural object:

| quantity | value |
|---|---|
| Hausdorff dimension of $\mathcal{P}$ (and of its closure) | $0$ |
| box-counting dimension of $\mathcal{P}$ | $1$ |
| one-dimensional Minkowski content | $0$, since $N(m) = O(m/\log m)$ |
| total $d$-length of the primes | $1/\log 2 \approx 1.4427$ |
| twin-pair scale | $d(p,p+2) \le 2/(p(\log p)^2)$ |
| the same for all integers | identical: $0$ and $1$ |

And the arithmetic has not disappeared; it has moved one order down. The bracket
$$\frac{m}{16(\log m)^4} \ \le\ N(m) \ \le\ \frac{5m}{\log m}$$
strongly suggests the exact asymptotic $N(m) \sim m/\log m$ — the same shape as the Prime Number Theorem itself, with the constant $1$ coming not from the primes' density but from the tail of enormous primes filling every box below index $m/\log X$. Numerically, $N(m)\log m / m$ sits around $1.3$–$1.7$ and drifts downward, consistent with a limit of $1$. Proving that limit needs only a guarantee that the intervals $(e^{m/(k+1)}, e^{m/k}]$ contain primes — the province of short-interval prime existence results.

That, in the end, is what the logarithmic lens teaches. It does not reveal a hidden fractal in the primes. It reveals that "dimension" is a very lossy compression of arithmetic: two of them, honestly computed, return $0$ and $1$, and both numbers are the same for the primes and for the integers. The information is not in the dimension. It is in the constant, and in the rate.
