# The Shapes That a Blurry Camera Cannot See

## A story about moments, differences, and the arithmetic of near misses

Imagine a measuring device so crude that it reports only a handful of numbers about
whatever you put in front of it. You place a distribution of masses along a ruler — some
positive, some negative, sitting at the integer marks $0, 1, 2, \dots, N$ — and the device
reports the total mass, then the total moment (mass times position), then the total second
moment (mass times position squared), and so on, but only up to some cut-off. It sees the
first $K$ numbers
$$m_0, m_1, \dots, m_{K-1}, \qquad m_k = \sum_{j=0}^{N} e_j\, j^k,$$
and then it stops.

A natural question, and one with a surprising amount of structure hiding behind it: **what
can such a device not see?** Which configurations $e = (e_0, e_1, \dots, e_N)$ are
*invisible*, in the sense that every one of the measurements $m_0, \dots, m_{K-1}$ comes
back as exactly zero, even though the configuration itself is not zero at all?

This is not an idle question. The same equations turn up when you ask whether two different
collections of whole numbers can have the same sum, the same sum of squares, the same sum
of cubes, and so on — the classical *Prouhet–Tarry–Escott problem*, which has occupied
number theorists since the nineteenth century. It turns up in numerical analysis, where the
vanishing of low-order moments is exactly the condition that makes a finite-difference
formula accurate to high order. It turns up in signal processing, where a filter with
vanishing moments is a filter that annihilates polynomial trends — the defining property of
a wavelet. And it turns up in coding and design theory, where "invisible to $K$ moments"
becomes "indistinguishable to a $K$-dimensional test".

The answer, it turns out, can be written down completely, and it is beautiful.

---

## The first thing you notice: there is nothing invisible if the camera is good enough

If the device measures moments $m_0$ through $m_N$ — as many as there are positions on the
ruler — then nothing is invisible. This is the classical Vandermonde/Lagrange fact: the
matrix whose $(k,j)$ entry is $j^k$ has nonzero determinant, so the only configuration with
all $N+1$ moments zero is the empty one. Call this the *rigidity principle*: a full window
sees everything.

So invisibility is entirely a phenomenon of **truncation**. The interesting regime is
$K \le N$: fewer measurements than positions. The number of degrees of freedom left over is
$N + 1 - K$, and one might hope that the invisible configurations form a space of exactly
that dimension. They do — and, remarkably, they do so in a way that respects the integers.

---

## The building block: alternating binomial spikes

Here is the fundamental invisible configuration. Fix a window length $K$ and a starting
position $i$. Put the weights
$$(-1)^K,\ (-1)^{K-1}\binom{K}{1},\ (-1)^{K-2}\binom{K}{2},\ \dots,\ \binom{K}{K-1}\cdot(-1),\ 1$$
at the positions $i, i+1, \dots, i+K$, and nothing anywhere else. Call this configuration
$b^{(K,i)}$; its weight at position $i + d$ is $(-1)^{K-d}\binom{K}{d}$.

For $K = 2$ starting at $i = 0$, this is the pattern $(1, -2, 1)$ — the familiar second
difference. For $K = 3$ it is $(-1, 3, -3, 1)$. These are exactly the coefficients of the
$K$-th *forward difference operator*
$$(\Delta^K f)(i) = \sum_{d=0}^{K} (-1)^{K-d}\binom{K}{d} f(i+d),$$
and there is a fact every numerical analyst knows in their bones: **the $K$-th difference
annihilates every polynomial of degree less than $K$.** Since the device's $k$-th
measurement of $b^{(K,i)}$ is precisely $(\Delta^K x^k)(i)$, and $x^k$ has degree $k < K$,
every measurement in the window returns zero. The spike is invisible.

What happens one step past the window is just as clean. The $K$-th difference of $x^K$ is
the constant $K!$, so
$$m_K\big(b^{(K,i)}\big) = K!$$
— *independently of where the spike is placed*. Every one of these building blocks hides
perfectly inside the window and then announces itself, one step later, with exactly the same
signal strength. There is a slick way to see all of this at once: encode a configuration
$e$ as the polynomial $E(X) = \sum_j e_j X^j$. Then $b^{(K,i)}$ has generating polynomial
$X^i (X-1)^K$, and the factor $(X-1)^K$ is precisely a $K$-fold root at $1$ — the algebraic
avatar of $K$ vanishing moments.

---

## The structure theorem: that is all there is

Between position $0$ and position $N$ there is room for exactly $N + 1 - K$ of these spikes:
they can start at $i = 0, 1, \dots, N-K$. The main theorem says that they generate
everything.

> **Structure Theorem.** Let $K \le N$. A configuration $e$ on the nodes $\{0,\dots,N\}$ is
> invisible to the window $k < K$ if and only if it is a linear combination
> $$e = \sum_{i=0}^{N-K} c_i\, b^{(K,i)}$$
> of the shifted binomial spikes. The coefficients $c_i$ are unique. Moreover — and this is
> the sharp part — **if $e$ has integer entries, the $c_i$ are integers too.**

Equivalently, in the polynomial language: $e$ is invisible to the window $k < K$ exactly
when $(X-1)^K$ divides $E(X)$. The invisible configurations form a free module of rank
$N+1-K$ with an explicit basis; over the rationals, the space of invisible vectors has
dimension exactly $N + 1 - K$, dropping by one each time the window widens by one, until at
$K = N$ it is a single line — the classical alternating binomial vector
$\big((-1)^N\binom{N}{0}, \dots, \binom{N}{N}\big)$ — and at $K = N+1$ it collapses to zero,
recovering the rigidity principle.

The integrality claim deserves a moment. Rational statements about kernels rarely descend to
the integers; usually you clear denominators and pick up a factor. Here the descent is free,
and the reason is visible in the proof. Work downward from the top node. The only spike that
reaches position $N$ is the last one, $b^{(K,N-K)}$, and its weight there is $1$ — not
$\pm K!$, not a binomial coefficient, but exactly $1$. So the coefficient $c_{N-K}$ must
equal $e_N$; subtract $e_N \cdot b^{(K,N-K)}$ and you have an invisible configuration living
on $\{0,\dots,N-1\}$. Induct. **The induction never divides by anything.** The rigidity
principle is used only in the base case, when the ruler has become shorter than the window
and only the zero configuration survives.

---

## Near misses: the same theorem in the language of number theory

Now translate. An integer configuration splits into its positive and negative parts: read
$e_j > 0$ as "put $e_j$ copies of the number $j$ into the bag $S$", and $e_j < 0$ as "put
$|e_j|$ copies of $j$ into the bag $T$". Then $m_k(e) = 0$ says exactly
$$\sum_{x \in S} x^k = \sum_{x \in T} x^k .$$
Two different bags of whole numbers with the same sum, the same sum of squares, ..., the
same sum of $(K-1)$-st powers. That is a **near miss** of order $K$ — a Prouhet–Tarry–Escott
solution.

The structure theorem now becomes a complete classification: *every* near miss on the range
$\{0,\dots,N\}$ that survives $K$ power-sum tests is an integer combination of the shifted
binomial pairs, and every such combination is a near miss. The smallest example is the
translate pair itself. Take $K = 2$, positions $1,2,3$: the spike $(1,-2,1)$ says
$$\{1, 3\} \ \text{versus}\ \{2, 2\}: \qquad 1 + 3 = 2 + 2, \qquad 1^0+3^0 = 2^0+2^0,$$
and the two bags first diverge at squares, $1 + 9 = 10$ against $4 + 4 = 8$, with difference
$2 = 2!$. Exactly the predicted first visible moment.

Two further consequences fall out of the dictionary with no extra work. First, two bags with
equal power sums up to order $K$ must have the same cardinality (that is just the $k=0$
equation). Second — a genuinely arithmetic corollary — the alternating counts of the two
bags must agree modulo $2^K$:
$$\sum_{x \in S} (-1)^x \equiv \sum_{x \in T} (-1)^x \pmod{2^K},$$
because evaluating the divisibility $(X-1)^K \mid E(X)$ at $X = -1$ yields a factor
$(-2)^K$.

---

## How cheap can invisibility be?

If you must hide from $K$ measurements, how much *stuff* do you need? Two natural cost
measures: the number of positions you occupy, and the total absolute weight
$\ell^1(e) = \sum_j |e_j|$ — for near misses, the total number of integers in the two bags.

**Occupied positions.** You need at least $K+1$. Fewer would give a nonzero configuration on
$K$ or fewer nodes killed by $K$ moment equations, contradicting rigidity on that smaller
node set. The bound is sharp: the binomial spike occupies exactly $K+1$ positions. And the
extremal case is completely rigid: if an invisible configuration sits on exactly $K+1$ nodes
$S$, then its weights are forced, up to scale, to be the *divided-difference* weights
$$e_i \prod_{j \in S,\, j \ne i} (i - j) = m_K(e).$$
In particular no weight can vanish, the top moment $m_K(e)$ is nonzero (a minimal
configuration is always visible immediately after the window), the signs alternate as you
walk along the nodes, and any two invisible configurations supported on the same $K+1$ nodes
are proportional. Minimality forces uniqueness.

**Total weight.** Since $\ell^1(e) \ge \#\{j : e_j \ne 0\}$, the same bound gives
$\ell^1(e) \ge K+1$. But there is a parity phenomenon: for $K \ge 1$ the equation $m_0 = 0$
forces the positive and negative masses to be equal, so $\ell^1(e)$ is always **even**. That
upgrades the bound to $K+2$ whenever $K$ is even, and a finer argument — ruling out the
rigid divided-difference configuration by showing its weights cannot all be small — pushes
it to $K+2$ for every $K \ge 2$ and to $K+3$ for odd $K \ge 3$. These are sharp at
$K = 1, 2, 3$: at $K = 3$ the configuration $(-1, 2, 0, -2, 1)$ on $\{0,1,2,3,4\}$ has total
weight $6$, and as a near miss it is the classical
$$\{1, 1, 4\} \quad \text{versus} \quad \{0, 3, 3\}, \qquad 1+1+4 = 0+3+3 = 6, \qquad
1+1+16 = 0+9+9 = 18 .$$

## The exponential conjecture, and why it is false

Here is where the story takes a turn. The obvious invisible configuration at window $K$ is
the binomial spike, and its total weight is $\sum_d \binom{K}{d} = 2^K$. It is tempting —
and it was conjectured — that this is optimal: that hiding from $K$ measurements should cost
exponentially much.

**It is not.** The bound $\ell^1 \ge 2^K$ does hold for $K \le 2$, where $2^K$ is $2$ and
$4$ and coincides with the linear bounds. But it fails for **every** $K \ge 3$, and it fails
by an exponentially large factor. The mechanism is a *convolution* principle, and it is
worth stating because it is the engine of the whole construction:

> **Convolution Theorem.** If $e$ is invisible to the window $K_e$ and $w$ is invisible to
> the window $K_w$, then the convolution $(w * e)_j = \sum_a w_a\, e_{j-a}$ is invisible to
> the window $K_e + K_w$; its first visible moment obeys the Leibniz-type rule
> $$m_{K_e + K_w}(w * e) = \binom{K_e + K_w}{K_e}\, m_{K_e}(e)\, m_{K_w}(w) \ne 0,$$
> and its total weight satisfies $\ell^1(w * e) \le \ell^1(w)\, \ell^1(e)$.

Windows **add**; costs **multiply**. So start from the cheap $K = 3$ witness of weight $6$
and convolve it with itself $n$ times: you get a configuration invisible to a window of
length $3n$ whose total weight is at most $6^n$. Compare with the conjectured floor
$2^{3n} = 8^n$. The ratio $(6/8)^n = (3/4)^n$ goes to zero: the true cost is not merely below
$2^K$, it is below it by a factor that decays exponentially in $K$. Even the crude
single-step version of the trick — the shift-difference $(\delta e)_j = e_{j-1} - e_j$, which
widens the window by one and at most doubles the weight — already gives configurations of
weight at most $6 \cdot 2^{K-3}$ at every window $K \ge 3$, comfortably under $2^K$.

The moral is that *invisibility composes*. Whatever economy you can find at one scale, you
can tensor it up; the exponent of the true growth rate is determined by the best small
example you can find, not by the naive binomial one.

---

## What we now know, and what we do not

Put together, the picture is this. The invisible configurations at window $K$ on $N+1$ nodes
form a lattice of rank exactly $N + 1 - K$, freely generated by translates of a single
object — the $K$-th difference stencil — with the integral structure coming for free. Every
near miss in the Prouhet–Tarry–Escott sense on a bounded range is an integer combination of
translates of a single binomial pair. Configurations of minimal support are completely rigid
and are divided differences. And the cost of invisibility is at least linear in the window
($\ell^1 \ge K + 2$, or $K + 3$ for odd $K \ge 3$, always even) and at most exponential with
base strictly below $2$ (weight $\le 6^{K/3} \approx 1.817^K$).

Between $K + 3$ and $1.817^K$ lies the real question. The evidence points to a startlingly
simple answer: that the true minimum is exactly $2K$ — twice the window. The proved bounds
already coincide with $2K$ at $K = 1, 2, 3$, and the first genuine test is $K = 4$, where the
truth appears to be $8$ against a proved floor of $6$. The upper half of that conjecture is
equivalent to a famous open problem: the existence of *ideal* Prouhet–Tarry–Escott solutions
of every degree, sought since 1851 and known only up to degree $12$.

That is a good place for a theory to arrive. What began as a question about a blurry
camera — which mass distributions does it fail to register? — has an exact, integral,
finitely-generated answer, and the answer reduces a century-old open problem in number theory
to a statement about the cheapest possible element of an explicitly described lattice. The
structure is fully understood; what remains is a search for the most economical point inside
it.
