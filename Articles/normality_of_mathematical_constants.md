# The Democracy of Digits: What It Means for a Number to Be "Normal"

## A simple question with a surprisingly deep answer

Write down the decimal expansion of a number — say $1/7 = 0.142857142857\ldots$ — and start counting. How often does the digit $7$ appear? How about $3$? If you keep going forever, do all ten digits $0,1,2,\ldots,9$ show up *equally often*, each grabbing exactly a tenth of the slots? For $1/7$ the answer is no: the block $142857$ repeats forever, so the digits $0$ and $3$ and $6$ and $9$ never appear at all, while $1,4,2,8,5,7$ split the expansion six ways.

Now try $\pi = 3.14159265\ldots$. As far as anyone has computed — trillions of digits deep — each of the ten digits appears almost exactly one-tenth of the time. The same seems true for $e$, for $\sqrt{2}$, for nearly every "natural" constant mathematicians stumble across. A number whose digits are perfectly democratic in this way — every digit appearing with limiting frequency exactly $1/b$ in base $b$ — is called **simply normal**.

Here is the scandal at the heart of the subject: despite overwhelming numerical evidence, *nobody has ever proved that $\pi$, $e$, or $\sqrt{2}$ is simply normal in any base.* These are among the most famous open problems in mathematics. We can compute the digits, we can stare at them, we can run statistical tests that all come back clean — but a proof remains utterly out of reach.

This article is about what we *can* prove. Rather than chasing the elusive normality of a single celebrity constant, we step back and build the *theory* of normality from the ground up: what is the right mathematical object to study, what laws does it obey, and what can we say with complete certainty about which sequences are normal and which are not? Along the way we'll uncover a clean structural surprise that overturns a piece of mathematical folklore.

## Stripping away the analysis

A real number's base-$b$ expansion is a slightly awkward thing. The same number can have two expansions ($0.4999\ldots = 0.5000\ldots$), and the machinery of infinite series tends to obscure what's really going on. So the first move — the one that makes everything else clean — is to throw away the real number entirely and keep only its **digit stream**.

A digit stream in base $b$ is just an infinite sequence
$$s : \mathbb{N} \to \{0, 1, \ldots, b-1\}$$
that hands you a digit for every position. Whether this stream came from $\pi$ or from a coin-flipping robot is irrelevant; normality is a property of the *stream*, not of its origin story. This is the central conceptual choice of the whole development, and it pays off immediately: every question becomes combinatorial.

With the stream in hand, define three quantities. First, the **count** of a digit $d$ among the first $n$ positions:
$$\operatorname{countDigit}(s, d, n) = \#\{k < n : s(k) = d\}.$$
This is honest bookkeeping — how many of the first $n$ digits equal $d$. Second, the **empirical frequency**:
$$\operatorname{freq}(s, d, n) = \frac{\operatorname{countDigit}(s, d, n)}{n},$$
the *fraction* of the first $n$ digits equal to $d$. And finally, the definition we've been building toward. A stream $s$ is **simply normal** when, for every digit $d$,
$$\lim_{n \to \infty} \operatorname{freq}(s, d, n) = \frac{1}{b}.$$
Every digit, in the long run, claims exactly its fair share.

That's it. No measure theory, no series, no two-expansions ambiguity — just counting and a limit.

## The conservation law: digits add up to one

The first thing any good theory needs is a law of conservation, and normality has a beautiful one. Fix any window — the first $n$ positions of the stream. Each of those $n$ positions holds exactly one digit, so if you count how many positions go to digit $0$, how many to digit $1$, and so on, and then add up all those counts, you must get back $n$. Nothing is created or destroyed; every position is claimed by exactly one digit.

In symbols, this is the **conservation law**:
$$\sum_{d=0}^{b-1} \operatorname{countDigit}(s, d, n) = n.$$

It looks almost too obvious to mention, but it is the load-bearing wall of the entire subject. Divide both sides by $n$ and it says something striking about the frequencies. For any window size $n > 0$,
$$\sum_{d=0}^{b-1} \operatorname{freq}(s, d, n) = 1.$$

In other words: *at every single stage*, the empirical frequencies form a genuine probability distribution. They are non-negative and they sum to one. Geometrically, the vector $\big(\operatorname{freq}(s,0,n), \ldots, \operatorname{freq}(s,b-1,n)\big)$ is a point living on the **probability simplex** $\Delta^{b-1}$ — the triangle (in base $3$), tetrahedron (base $4$), or higher-dimensional analogue of all the ways to split a pie among $b$ digits.

This reframes normality entirely. A digit stream is not just spitting out symbols; it is tracing a *path* of probability vectors wandering around the simplex as $n$ grows. And simple normality is exactly the statement that this path converges to the dead center of the simplex — the uniform distribution $(1/b, 1/b, \ldots, 1/b)$, the point of perfect equality. The number-theoretic question "is this number normal?" has become a question in the topology of a triangle: "does this path land at the center?"

## What goes wrong, and what must go right

The conservation law has an immediate and powerful consequence: it tells you exactly how normality can *fail*. Because the frequencies always sum to $1$, if even a single digit's frequency converges to the wrong value — anything other than $1/b$ — the stream cannot be normal. One coordinate misbehaving is a fatal obstruction. There is nowhere to hide: the budget of total frequency is fixed at $1$, so a digit that hogs more than its share, or starves below it, breaks the whole balance.

There's a complementary positive fact about digits that *do* show up. Suppose a digit $d$ appears **infinitely often** — that is, no matter how far out you look, there's always another occurrence of $d$ still ahead. Common sense says its running count should march off to infinity, and indeed it does:
$$\text{if } d \text{ occurs infinitely often, then } \operatorname{countDigit}(s, d, n) \to \infty.$$

This is true for a clean structural reason. The count function $n \mapsto \operatorname{countDigit}(s, d, n)$ is **monotone** — it never decreases, because widening the window can only add occurrences, never remove them. And a monotone sequence of natural numbers faces a stark dichotomy: either it is bounded (and eventually constant), or it is unbounded (and marches to infinity). A digit appearing infinitely often forces the count past every threshold, ruling out the bounded option. So the count *must* diverge. This monotone-divergence principle is the engine that connects "appears infinitely often" to genuine, quantitative growth — and it is exactly the kind of order-theoretic dichotomy that recurs throughout combinatorics.

Together these two facts bracket the whole landscape. The conservation law caps the frequencies from above and pins their total; the monotone-divergence principle guarantees that any digit pulling its weight contributes real, unbounded count. Normality lives in the narrow channel between these constraints.

## A periodic number that is perfectly normal

Now for the surprise. There is a widespread piece of folklore — repeated in popular accounts and even whispered among working mathematicians — that normality and *transcendence* (being non-algebraic, like $\pi$ and $e$, rather than a root of a polynomial with integer coefficients) are somehow two faces of the same deep complexity. The intuition runs: a normal number's digits look random, random-looking numbers are "complicated," and complicated numbers are transcendental. So surely **normal implies irrational, even transcendental**?

This intuition is *false*, and we can pin down the exact witness that kills it.

Consider the most boring digit stream imaginable — the **cyclic** or round-robin stream that just counts up and wraps around:
$$\operatorname{cyc}_b(k) = k \bmod b.$$
In base $10$ this is $0,1,2,3,4,5,6,7,8,9,0,1,2,3,\ldots$ repeating forever. It is the digit equivalent of a metronome: utterly predictable, with period exactly $b$.

Because it repeats with period $b$, this stream is the digit expansion of a **rational number** — and rational numbers are about as far from transcendental as you can get; they're not even irrational. Yet this metronome stream is *simply normal*.

Why? Count any digit $d$ in the first $n$ positions. Every complete block of $b$ consecutive positions contributes exactly one occurrence of $d$. So after $\lfloor n/b \rfloor$ full blocks, you've seen $d$ exactly $\lfloor n/b \rfloor$ times, plus possibly one more if $d$ happens to fall in the leftover partial block at the end. This gives the exact formula
$$\operatorname{countDigit}(\operatorname{cyc}_b, d, n) = \left\lfloor \frac{n}{b} \right\rfloor + \big[\,d < n \bmod b\,\big],$$
where the bracket is $1$ if the condition holds and $0$ otherwise. The count is squeezed tightly between $\lfloor n/b \rfloor$ and $\lfloor n/b \rfloor + 1$. Dividing by $n$, both the floor $\lfloor n/b\rfloor / n$ and the $+1/n$ correction settle the frequency onto $1/b$ as $n \to \infty$. The boundary correction is never worth more than a single digit — a *bounded* error — so it vanishes once you divide by a growing $n$.

The conclusion is sharp and clean: **simple normality does not imply irrationality, let alone transcendence.** The cyclic stream is rational, periodic, dead simple — and perfectly democratic in its digits. The folklore equivalence is broken, and the metronome is the hammer.

What makes the cyclic example so illuminating is *why* it works. Its discrepancy — the gap between the actual count and the ideal count $n/b$ — never exceeds $1$. This is the gold standard of equidistribution: an $O(1)$ error, the best possible. The deterministic block structure forces the digits into line with surgical precision. By contrast, the conjectured normality of $\pi$ would be a far more delicate, "statistical" kind of balance, with no such rigid structure to lean on. The cyclic number shows that the *destination* (uniform frequencies) can be reached by a road far smoother than randomness.

## What this buys us

Step back and look at what the digit-stream viewpoint has accomplished. By refusing to get tangled in real-analytic expansions and instead treating normality as a frequency statement about a sequence of symbols, three things fall out almost for free:

- **A conservation law** that turns the frequency vector into a point on the probability simplex at every stage, reframing normality as convergence to the simplex's center.
- **A precise obstruction theorem**: a single misbehaving coordinate destroys normality, because the total frequency budget is locked at $1$.
- **A clean separation theorem**: the periodic cyclic stream is rational yet simply normal, severing normality from transcendence and refuting a common folklore belief.

None of this resolves the grand open problems — $\pi$, $e$, and $\sqrt{2}$ keep their secrets. But it builds the scaffolding on which such questions can even be precisely posed. It tells us what kind of object normality really is (a statement about a path on a simplex), what its conservation laws are, and which intuitions about it are simply wrong.

## The road ahead

The digit-stream framework suggests its own next questions, each now sharp enough to attack head-on.

The first is whether the simplex picture is the *whole* story: is a stream simply normal **if and only if** its empirical distribution vectors converge to the uniform point, with partial convergence of even one coordinate to a wrong value forbidding normality? The conservation law already supplies the simplex constraint; closing the loop needs a compactness argument about measures on the simplex.

The second is *quantitative*. The cyclic stream achieves the extreme $O(1)$ discrepancy. What if a stream merely keeps its discrepancy below $C \cdot n^{1-\varepsilon}$ for some $\varepsilon > 0$ — does that guarantee normality, with a convergence rate of $O(n^{-\varepsilon})$? This would place simple normality at the boundary of an entire hierarchy of "how equidistributed" a stream can be, with the metronome sitting at the perfect endpoint.

The third sharpens the independence we just demonstrated. We proved normality does not imply transcendence; the conjectured converse is that there exist *transcendental non-normal* numbers too — for instance, sparse "Liouville-like" streams supported on the factorials $\{k! : k \in \mathbb{N}\}$, whose digits are so thinly spread (a counting function of size $O(\log n)$) that no digit can reach its fair frequency. If both directions hold, "normal" and "transcendental" are genuinely *independent* properties — neither implies the other.

And the deepest bridge of all connects back to dynamics: a real number $x$ should be simply normal in base $b$ **exactly when** the orbit of points $b^n x \bmod 1$ is *equidistributed* on the interval $[0,1)$. The reason is gorgeous — the $n$-th base-$b$ digit of $x$ is literally read off from where $b^{n} x$ lands modulo $1$, so the digit count is a running average (a "Birkhoff sum") of an indicator function along the multiply-by-$b$ map. Through this lens, the question "is $\pi$ normal?" becomes "is the orbit of $\pi$ under multiplication by $10$ equidistributed?" — and the entire arsenal of dynamical systems and ergodic theory comes into play.

The democracy of digits, it turns out, is not really about digits at all. It is about whether a simple dynamical process spreads its orbit evenly across a circle — one of the oldest and richest themes in all of mathematics. We have built the combinatorial foundation. The constants are still keeping their secrets. But now, at least, we know exactly what we are asking.
