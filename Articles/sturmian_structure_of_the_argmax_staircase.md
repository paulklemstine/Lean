# The Secret Rhythm of Pascal's Peaks

## Where does a binomial distribution peak — and how does the peak move?

Flip a biased coin $n$ times. The chance of seeing exactly $k$ heads is proportional to

$$b_{n,k} \;=\; \binom{n}{k}\, p^{k} q^{\,n-k},$$

where $p$ is the weight of heads and $q$ the weight of tails. Everyone knows the shape of this sequence: it rises, reaches a peak, and falls. It is the bell curve in its most elementary, discrete incarnation.

But here is a question almost nobody asks. As $n$ increases by one — as you add one more coin flip to the experiment — *where does the peak go?*

The answer turns out to be a small miracle of arithmetic. The peak never jumps. It either stays exactly where it was, or it slides forward by exactly one. And the resulting sequence of stays and slides — an infinite string of $0$s and $1$s — is not a random-looking mess, nor a boring periodic pattern. It is one of the most celebrated objects in the theory of infinite words: a *Sturmian word*, the symbolic shadow of a point going round and round a circle.

This article is the story of that word: what it is, why it appears, and what it tells you about the peak of a binomial distribution that a purely probabilistic argument would never reveal.

---

## Step one: pin down the peak exactly

Let $p, q > 0$ be arbitrary positive weights (they need not sum to $1$; only their ratio matters). Write

$$\alpha \;=\; \frac{p}{p+q} \;\in\; (0,1)$$

for the *slope* attached to the weights.

The weights $b_{n,0}, b_{n,1}, \dots, b_{n,n}$ are unimodal: they increase up to a point and decrease afterwards. Sometimes the maximum is achieved twice — at two neighbouring indices — so to have a single well-defined answer we always take the *largest* maximiser and call it $M_n$, the **mode** of row $n$.

> **Theorem (The Argmax Staircase).** For all $p, q > 0$ and every $n \ge 0$,
> $$M_n \;=\; \big\lfloor (n+1)\alpha \big\rfloor, \qquad \alpha = \frac{p}{p+q}.$$

The proof is a one-line ratio test. The weights satisfy

$$\frac{b_{n,k}}{b_{n,k-1}} \;=\; \frac{n-k+1}{k}\cdot\frac{p}{q},$$

which is $\ge 1$ precisely when $k \le (n+1)\alpha$. So the weights climb for every index at or below $(n+1)\alpha$ and fall strictly after it: the last index still climbing to is exactly $\lfloor (n+1)\alpha \rfloor$.

This formula is textbook, but read it again with fresh eyes. The mode is not "approximately $n\alpha$", not "$n\alpha$ plus an error term of size $O(1)$" — it is *exactly* the integer part of $(n+1)\alpha$. There is no probability left in the statement. It is a statement about floors of multiples of a real number: a **Beatty sequence**.

For $p = q$ (a fair coin, $\alpha = 1/2$) the staircase reads

$$0,\;1,\;1,\;2,\;2,\;3,\;3,\;4,\dots$$

For $p = \sqrt 2, q = 1$, where $\alpha = 2 - \sqrt 2 = 0.5857\ldots$, it reads

$$0,\;1,\;1,\;2,\;2,\;3,\;4,\;4,\;5,\;5,\;6,\;7,\;7,\dots$$

Something is clearly going on in the second list — a pattern of "double steps" and "single steps" that repeats without ever quite repeating.

---

## Step two: differentiate the staircase

Since $0 < \alpha < 1$, adding one to $n$ increases $(n+1)\alpha$ by less than one, so the floor increases by $0$ or $1$ — never more. Define the **increment word**

$$w_\alpha(n) \;=\; M_{n+1} - M_n \;\in\; \{0,1\}.$$

Then the whole staircase is recovered from the word by summation, and the following holds for every choice of positive weights.

> **Theorem (One letter per row).** Passing from row $n$ to row $n+1$ of the binomial weights, the mode advances by exactly the letter $w_\alpha(n) \in \{0,1\}$.

For $\alpha = 1/2$ the word is $1\,0\,1\,0\,1\,0\cdots$. For $\alpha = 2-\sqrt2$ it begins

$$1\,0\,1\,0\,1\,1\,0\,1\,0\,1\,1\,0\,1\,0\,1\,0\,1\,1\,0\,1\cdots$$

Rows where the peak moves are marked $1$; rows where it stalls are marked $0$. Notice: the $1$s are *not* clumped, and the $0$s are not clumped. The word never contains $00$ (because $\alpha > 1/2$ here) and never contains $111$. That is not an accident — it is *balance*, and it is the first of the two defining properties of Sturmian words.

---

## Step three: the word is balanced

Take any window of $L$ consecutive letters and count the $1$s inside. Call this count $W(m,L)$, the total rise of the staircase over the window starting at position $m$. Telescoping the definition,

$$W(m,L) \;=\; \big\lfloor (m+1)\alpha + L\alpha \big\rfloor - \big\lfloor (m+1)\alpha \big\rfloor,$$

and the elementary sandwich $\lfloor x\rfloor + \lfloor y\rfloor \le \lfloor x + y \rfloor \le \lfloor x \rfloor + \lfloor y\rfloor + 1$ delivers, in one stroke:

> **Theorem (Window bound).** For every position $m$ and every length $L$,
> $$\big\lfloor L\alpha \big\rfloor \;\le\; W(m,L) \;\le\; \big\lfloor L\alpha \big\rfloor + 1 .$$

Two consequences fall out immediately.

**Balance.** Any two windows of the same length contain numbers of $1$s differing by at most one:
$$\big| W(m,L) - W(m',L) \big| \;\le\; 1 \quad\text{for all } m, m', L.$$
No stretch of the staircase is ever "busier" than another by more than a single step. Whatever else is happening, the peak advances with a rigidly even rhythm.

**Frequency.** Since $W(m,L)$ differs from $L\alpha$ by less than $2$ *uniformly in $m$*, the density of $1$s is exactly $\alpha$:
$$\lim_{L\to\infty}\frac{W(m,L)}{L} \;=\; \alpha \;=\; \frac{p}{p+q}, \qquad \text{for every } m.$$
Over the long run the mode of a binomial distribution advances at rate $p/(p+q)$ — which is the law of large numbers, but here obtained with no probability whatsoever, and with an explicit error bound of $2$ rather than a limit theorem.

---

## Step four: periodic or aperiodic? The great dichotomy

When is the peak pattern eventually a repeating loop? The answer is as clean as one could hope.

> **Theorem (Periodicity dichotomy).** The increment word is periodic — meaning $w_\alpha(n+T) = w_\alpha(n)$ for all $n$ and some $T \ge 1$ — if and only if $\alpha$ is rational.

One direction is easy: if $T\alpha$ is an integer $c$, then $\lfloor (n+T+1)\alpha\rfloor = \lfloor (n+1)\alpha\rfloor + c$, so the staircase repeats with a vertical shift and the word repeats exactly.

The other direction is more delicate and is the heart of the matter. Suppose the word has period $T$. Then the staircase satisfies $M_{n+T} = M_n + c$ for the fixed integer $c = M_T - M_0$, so after $k$ periods $M_{kT} = M_0 + kc$. But $M_{kT} = \lfloor (kT+1)\alpha\rfloor$ grows like $kT\alpha$. If $T\alpha \ne c$ the two growth rates differ by a fixed nonzero amount per period, and after enough periods the discrepancy exceeds $1$ — impossible, since both quantities agree to within one unit for all $k$. Hence $T\alpha = c$ exactly and $\alpha = c/T$ is rational.

This is a version of the classical Morse–Hedlund principle: *aperiodicity is exactly irrationality*. For a biased coin whose weight ratio $p:q$ is a ratio of integers, the pattern of peak movements is eventually a loop. For a coin with, say, $p = \sqrt2$ and $q=1$, the pattern never repeats — no matter how far you look.

For the rational case one can say precisely how long the loop is.

> **Theorem (Exact period).** For integer weights $P, Q \ge 1$ (so $\alpha = P/(P+Q)$), the word is periodic with period $P + Q$, and *every* window of length $P+Q$ contains exactly $P$ ones.

Every $P+Q$ rows, the mode advances by exactly $P$ — on the nose, with no error term at all.

---

## Step five: counting patterns — the Sturmian signature

The real fingerprint of a Sturmian word is not balance but *complexity*. For a length $L$, let $p(L)$ be the number of distinct blocks (factors) of $L$ consecutive letters occurring anywhere in the word. A random binary sequence has $p(L) = 2^L$: every pattern occurs. An eventually periodic sequence has $p(L)$ bounded. Sturmian words sit exactly at the boundary between these regimes, at the *slowest possible aperiodic growth*:

$$p(L) \;=\; L + 1 .$$

That this is the minimum for an aperiodic word is a theorem of Morse and Hedlund: if $p(L) \le L$ for even a single $L$, the word must be eventually periodic. So $L+1$ is as close to periodic as an aperiodic word can get, and Sturmian words are, by definition, the words that achieve it.

The peak word achieves it.

> **Theorem (Complexity upper bound).** For every real slope $\alpha$ and every $L$, the increment word has at most $L+1$ distinct factors of length $L$.
>
> **Theorem (Exact complexity, irrational slope).** If $\alpha$ is irrational, the increment word has exactly $L+1$ distinct factors of length $L$, for every $L$. In particular, for weights $p = \sqrt2$, $q = 1$ the pattern of binomial peak movements is a genuine Sturmian word.
>
> **Theorem (Exact complexity, rational slope).** If $P$ and $Q$ are coprime positive integers, the increment word of slope $P/(P+Q)$ has exactly
> $$p(L) \;=\; \min\{\,L+1,\; P+Q\,\}$$
> factors of length $L$: it grows like a Sturmian word until it hits the period, then stops.

The mechanism behind the upper bound is beautifully simple, and worth spelling out because it explains *why* circles are involved. The block read at position $m$ depends on $m$ only through the fractional part $x_m = \{(m+1)\alpha\}$ — a point on the circle $\mathbb{R}/\mathbb{Z}$. Indeed the cumulative rises satisfy

$$M_{m+j} - M_m \;=\; \big\lfloor x_m + j\alpha \big\rfloor,$$

so the block is determined by where $x_m$ sits relative to the $L$ thresholds $1-\{j\alpha\}$, $j = 1, \dots, L$. Those $L$ thresholds cut the circle into at most $L+1$ arcs, and two positions in the same arc read the same block. Hence at most $L+1$ blocks. For irrational $\alpha$ the orbit $\{j\alpha\}$ is dense (Dirichlet's approximation theorem), so every arc really is visited and all $L+1$ blocks genuinely occur. For rational $\alpha = a/b$ in lowest terms, the orbit is the finite set $\{0, 1/b, \dots, (b-1)/b\}$, which still hits every arc as long as $L < b$, and cannot produce more than $b$ distinct blocks in total.

**The peak of a binomial distribution is a rotation of a circle in disguise.** That is the entire content of the result. Each new row of Pascal's triangle rotates a hidden point by $\alpha$ of a full turn; when the point crosses the seam, the peak moves.

---

## Step six: the $+1$ that refuses to go away

There is a twist, and it is a genuinely interesting one.

The textbook Sturmian word of slope $\alpha$ — the *lower mechanical word* — is

$$s_\alpha(m) \;=\; \lfloor (m+1)\alpha\rfloor - \lfloor m\alpha\rfloor, \qquad m \ge 0.$$

The peak word is $w_\alpha(n) = \lfloor (n+2)\alpha \rfloor - \lfloor (n+1)\alpha\rfloor$. Comparing, one sees at once

$$w_\alpha(n) \;=\; s_\alpha(n+1),$$

so the peak word is the mechanical word **shifted left by one letter**. That extra $+1$, born from the ratio test's $(n+1)\alpha$ rather than $n\alpha$, is not cosmetic:

> **Theorem (The shift is real).** For every $\alpha \in (0,1)$ the peak word differs from the lower mechanical word of the same slope: there is always a position $n$ with $w_\alpha(n) \ne s_\alpha(n)$.

The proof is a small gem. Suppose the two words agreed everywhere. Then $s_\alpha(n+1) = w_\alpha(n) = s_\alpha(n)$ for all $n$, so $s_\alpha$ is constant; its value at $m=0$ is $\lfloor\alpha\rfloor = 0$ since $0<\alpha<1$; hence $s_\alpha \equiv 0$ and, by the shift identity, $w_\alpha \equiv 0$ too. But the letter $1$ must occur in $w_\alpha$: if it never did, the mode would be frozen forever, while the window bound forces $W(0,L) \ge \lfloor L\alpha\rfloor \ge 1$ as soon as $L > 1/\alpha$. Contradiction.

So the peak word is Sturmian, but it is *not the standard representative* — it is the shift by one. It has the same set of factors, the same complexity, the same balance, and yet at position $0$ it can already disagree: for any $\alpha \in [1/2,1)$ the peak word begins with $1$ while the mechanical word begins with $0$. The moral: "the mode of the binomial is Sturmian" is a true statement, but only once one is careful to say *which* Sturmian word. Extra arithmetic hides in an innocuous $+1$.

---

## Why this matters beyond Pascal's triangle

**A bridge between two toolkits.** Once the peak word is identified as Sturmian, the entire machinery developed for Sturmian words over the last century becomes available for statements about binomial modes: continued fractions, Christoffel words, the three-distance theorem, Ostrowski numeration, palindromic structure. For instance, the three-distance (Steinhaus) theorem says that the gaps between consecutive $1$s — that is, the waiting times between successive advances of the peak — take at most three distinct values at any scale, and those values are governed by the continued-fraction convergents of $\alpha$. A statement about coin flips becomes a statement about number theory.

**Digital lines and computer graphics.** The word $\lfloor (n+1)\alpha\rfloor$ is exactly the sequence a computer draws when it renders a straight line of slope $\alpha$ on a pixel grid — Bresenham's algorithm. The blocky staircase you see when you zoom into a diagonal line on a screen is, letter for letter, the pattern of binomial peak movements. Balance is the reason the rendered line looks straight; complexity $L+1$ is the reason it never looks periodic when the slope is irrational.

**Fair scheduling and quantization.** "Serve $p$ requests of type A for every $q$ of type B, as evenly as possible" has a unique optimally-balanced answer, and it is this word. Round-robin schedulers, dithering algorithms in image processing, and pulse-density modulation in signal processing all rediscover the same sequence. The theorem above says that the mode of a binomial distribution schedules its own advances optimally fairly, whether it wants to or not.

**Exactness in place of asymptotics.** Probabilistic estimates of a binomial mode typically come with $O(1)$ or $O(\sqrt n)$ error terms. Here the answer is an exact integer formula, and the fluctuation of the peak away from the ideal line $n\alpha$ is bounded by an absolute constant — forever, uniformly, for every $n$. When a model's prediction is the $\arg\max$ of a discrete distribution — a predicted class, a quantization level, a discretized index — knowing exactly when the $\arg\max$ jumps, rather than merely where it is on average, is the difference between a bound and an algorithm.

---

## The picture to keep

Imagine a point on a circle of circumference $1$, starting a hair past the origin, and imagine giving it a push of $\alpha$ of a full turn each time you add a row to Pascal's triangle. Draw a seam at the top of the circle. Every time the point crosses the seam, the binomial peak takes a step forward; every time it does not, the peak waits.

That is the whole theorem. The bell curve's summit does not wander. It marches to the rhythm of an irrational rotation — the most perfectly balanced rhythm there is.
