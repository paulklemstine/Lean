# What Does a Factoring Algorithm Actually *See*?

## A four-hundred-year-old method finally gets classified

Take a large number $N$ that you know is the product of two primes, $N = pq$, and try to find those primes. Everyone agrees this is hard. What almost nobody asks is a sharper question: hard *in terms of what*?

That question turns out to have a precise and surprisingly beautiful answer, and it splits the classical factoring methods into a small number of species. Some methods are hunting the **smaller prime factor** — their running time is a function of $p$ and of nothing else. One method is not hunting a factor at all. It is hunting a **gap**: the distance between the two primes. And once you see that distinction clearly, a table that looked like a grab-bag of tricks turns into a taxonomy.

This article is about the last entry in that taxonomy to be pinned down exactly — Fermat's method, the oldest of the lot — and about the exact law that governs it.

---

## Four methods, three ways of seeing

Here are the four classical workhorses, with the cost of each expressed in terms of the factorisation $N = pq$, with $p < q$ both prime.

**Trial division.** March $d = 3, 5, 7, \dots$ upward and test whether $d$ divides $N$. You stop at $d = p$. Cost: exactly $p$ operations. The method has no insight whatsoever into the structure of $N$; it simply scans the integers until one of them happens to be a factor. Call this the **$p$-linear** class.

**Pollard's rho.** Iterate a pseudorandom map modulo $N$ and watch for a collision modulo the unknown $p$. By the birthday paradox, a collision modulo $p$ appears after roughly $\sqrt{p}$ steps. Cost: about $\sqrt{p}$. Note what this depends on: $p$, and only $p$. The larger factor $q$ could be anything at all.

**The elliptic curve method (ECM).** Replace the multiplicative group modulo $p$ with the group of points on a random elliptic curve over $\mathbb{F}_p$, and hope for a smooth group order. Cost: sub-exponential in $p$ — again, in $p$ alone.

Rho and ECM are therefore both **factor-local**: they are searching for the smaller prime, and they find it at a price set by its size. If you double $q$ while holding $p$ fixed, their cost does not move.

**Fermat's method.** Now the odd one out. Write $N$ as a difference of two squares: if $N = a^2 - b^2$ then $N = (a-b)(a+b)$ and you have a factorisation. So start at the smallest $a$ with $a^2 > N$, namely $a = \lfloor\sqrt{N}\rfloor + 1$, and increment $a$ one step at a time, checking at each step whether $a^2 - N$ is a perfect square.

What does this method see? Not $p$. Something else entirely.

---

## The exact law

Here is the central result, and it is an *identity*, not an estimate.

> **The Gap-Local Identity.** Let $p < q$ be odd primes and let $N = pq$. Then Fermat's method performs exactly
> $$\frac{p+q}{2} \;-\; \lfloor\sqrt{N}\rfloor \;-\; 1$$
> iterations before it halts.

No big-O, no constant hidden in the wings. The count is the arithmetic mean of the two factors, minus the (floored) geometric mean, minus one. It is the **AM–GM gap** of the factor pair.

Why is it true? Because of a small miracle of bookkeeping. Every value of $a$ at which the scan can possibly stop corresponds to a way of writing $N$ as an ordered product $N = d \cdot e$ with $d \le e$; the stop happens at $a = (d+e)/2$. When $N$ is a product of two primes there are only *two* such factorisations: the trivial one $1 \times N$, which corresponds to $a = (1+N)/2$ — far away — and the real one $p \times q$, which corresponds to $a = (p+q)/2$. The scan starts just above $\sqrt{N} = \sqrt{pq}$, the geometric mean, and marches upward. The arithmetic mean $(p+q)/2$ is always at least the geometric mean, so the target lies ahead; the scan reaches it, and it reaches nothing else first. Hence the count is exactly the distance from start to target.

So Fermat is neither factor-local nor a scan. It is **gap-local**. The taxonomy now reads:

| method | what it sees | cost |
|---|---|---|
| trial division | nothing — it scans | $p$ |
| Pollard's rho | the factor | $\sqrt{p}$ |
| elliptic curve method | the factor | sub-exponential in $p$ |
| **Fermat** | **the gap** | $\dfrac{p+q}{2} - \sqrt{N}$ |

Four methods. Three ways of seeing.

---

## The classes really are different

It is one thing to write down different formulas; it is another to prove that they cannot be reconciled. They cannot, and the demonstration is startling.

Since $\frac{x+y}{2} - \sqrt{xy} = \frac{(\sqrt y - \sqrt x)^2}{2}$, the Fermat cost can be bounded above by
$$\frac{p+q}{2} - \sqrt{pq} \;\le\; \frac{(q-p)^2}{8p}.$$
Stare at that for a moment. The gap $g = q - p$ appears **squared in the numerator**, and $p$ appears in the **denominator**. For a fixed gap, Fermat gets *faster* as the primes get *bigger*. That is the exact opposite behaviour of every factor-local method.

Pushed to its limit, this gives a clean separation theorem:

> **Zero-cost semiprimes.** If the factor gap $g = q-p$ satisfies $(g-2)^2 \le 8p$, then Fermat's method halts with **zero** iterations — the very first trial value of $a$ succeeds — no matter how large $p$ is.

Take the twin primes $10007$ and $10009$. Their product is $100\,160\,063$. Trial division needs $10\,007$ divisions to crack it. Pollard's rho needs about $100$. Fermat needs **none**: the very first value it tries, $a = 10008$, gives $a^2 - N = 1 = 1^2$, and the factorisation drops out. You can make $p$ as large as you like and, as long as the twins stay twins, the Fermat cost stays at zero while the trial-division cost runs to infinity. The classes are genuinely distinct.

And the converse separation is just as sharp. Feed Fermat an odd **prime** $N$. There is now only one ordered factorisation, the trivial $1 \times N$, so the scan is forced to grind all the way up to $a = (N+1)/2$:

> **Worst case.** On an odd prime $N$, Fermat's method performs exactly $\frac{N - 2\lfloor\sqrt N\rfloor - 1}{2}$ iterations.

That is $\Theta(N)$ — *quadratically worse* than trial division, which certifies primality in $\sqrt{N}$ steps. The same method is unboundedly better than trial division on balanced semiprimes and quadratically worse on primes. This is what it means for a locality class to be a real distinction and not a bookkeeping convention.

---

## The balance ratio: one law for the whole grid

Suppose you fix $p$ and slide $q$ upward: $q \approx rp$ for a balance ratio $r = q/p$ running from $2$ to $64$. What does the cost curve look like?

Substituting $q = rp$ into the identity and simplifying gives a law of remarkable cleanliness:

> **Balance-Ratio Law.** In units of $p$, the cost of Fermat's method depends *only* on the balance ratio:
> $$\frac{p + rp}{2} - \sqrt{p \cdot rp} \;=\; p \cdot \frac{(\sqrt r - 1)^2}{2}.$$

The size of the primes drops out entirely. Only their *ratio* matters. At $r = 2$ the coefficient is $0.0858\ldots$; at $r = 4$ it is exactly $0.5$; at $r = 16$, exactly $4.5$; at $r = 64$, exactly $24.5$.

Here is the measured grid at $p = 101$, with $q$ the prime nearest $rp$:

| $q$ | $r = q/p$ | iterations | iterations$/p$ | $(\sqrt r-1)^2/2$ |
|---|---|---|---|---|
| 211 | 2.089 | 10 | 0.0990 | 0.0992 |
| 409 | 4.050 | 51 | 0.5050 | 0.5124 |
| 809 | 8.010 | 169 | 1.6733 | 1.6748 |
| 1619 | 16.030 | 455 | 4.5050 | 4.5111 |
| 3251 | 32.188 | 1102 | 10.9109 | 10.9206 |
| 6469 | 64.050 | 2476 | 24.5149 | 24.5217 |

The last two columns agree to three decimal places across a factor of $250$ in cost. The same law, run at a larger $p$, reproduces a cost grid climbing from $352$ to $100\,282$ iterations — a $285$-fold increase driven purely by the balance ratio, with the prime held fixed.

There is a second, more suggestive way to read the law. The "obvious" cost of an unbalanced semiprime is the cofactor-linear limit $(q-p)/2 = p(r-1)/2$: the distance from the small factor's half-sum to the large one's. How much of that does Fermat actually pay? Exactly:

> **Ratio Law.** Fermat's cost is the fraction
> $$\frac{\sqrt r - 1}{\sqrt r + 1}$$
> of the cofactor-linear limit $(q-p)/2$.

At $r = 4$ that fraction is $1/3$; at $r = 64$ it is exactly $7/9 = 0.777\ldots$ — and the measured value at $p = 101$, $r \approx 64$ is $0.7776$. The fraction climbs toward $1$ but never reaches it: Fermat is always strictly better than the cofactor-linear limit, approaching it only as the ratio blows up. In whole numbers, the sharp statement is
$$2 \cdot (\text{iterations}) + 2 \;\le\; q - p,$$
which pins the strictness down exactly.

---

## The square that isn't there

Testing a law across a grid is how you find out what it forgot. Setting $r = 1$ — that is, $q = p$, so $N = p^2$ — exposed something nobody had written down.

The gap-local formula predicts a cost of $\frac{p+p}{2} - p = 0$: with the factors perfectly balanced, Fermat should halt instantly. And morally it should: $N = p^2 = p^2 - 0^2$ is a difference of squares with $a = p$.

But the scan starts at $a = \lfloor\sqrt N\rfloor + 1 = p + 1$. The target $a = p$ is **one step behind the starting line**. Fermat's method, as classically stated, sails straight past the answer and never comes back.

> **The Square Defect.** On $N = n^2$, the difference-of-squares target $a = n$ lies strictly below the starting point $\lfloor\sqrt N\rfloor + 1$. On $N = p^2$ for an odd prime $p$, the scan therefore exits only at the *unrelated* trivial factorisation $a = (p^2+1)/2$, at a cost of $\frac{p^2+1}{2} - (p+1)$ iterations.

That is a quadratic blow-up on the most balanced input imaginable. In one measured instance, a prime square took $8\,372\,232$ iterations to exit — through a factorisation that reveals nothing but $1 \times N$. The method does not so much solve the prime square as stumble out of it by accident.

The fix is one character long. Start the scan at $a = \lfloor\sqrt N\rfloor$ instead of $\lfloor\sqrt N\rfloor + 1$. The repaired method halts immediately on *every* square, and costs exactly **one** extra iteration on every odd non-square. The defect was a boundary error, not a structural feature — but it was invisible until somebody put the method on a grid and ran the degenerate row. (The continued-fraction descendants of Fermat's method, which use a different search order, never had the bug.)

---

## Why Fermat is really *divisor*-local

Gap-locality is a statement about semiprimes. What is it a shadow of?

Run the same analysis on an arbitrary odd non-square $N$ and the answer appears. Every stopping point of the scan is the half-sum $(d + N/d)/2$ of an ordered factorisation. Among all such factorisations, which has the smallest half-sum? The function $d \mapsto d + N/d$ is decreasing on $d \le \sqrt N$, so the smallest half-sum belongs to the factorisation whose small factor $d$ is *largest* — the divisor closest to $\sqrt N$ from below. Hence:

> **Divisor-Locality at the Square Root.** For odd non-square $N$, Fermat's method halts exactly at the half-sum of the ordered factorisation $N = d \cdot e$ whose small factor $d$ is nearest $\sqrt N$ from below. Every other divisor of $N$ is completely invisible to the method.

That is the real theorem, and gap-locality is its semiprime special case: when $N = pq$ the only non-trivial small factor *is* $p$, so "nearest $\sqrt N$" and "the prime factor" coincide. It also explains the prime worst case in one line: on a prime, the only divisor below $\sqrt N$ is $1$, so the scan must go all the way to $(N+1)/2$.

---

## The locality is steerable

Here is the payoff of knowing precisely what a method sees: you can change what it sees.

Fermat only notices the divisor nearest $\sqrt N$. So change $N$. Run the scan on $kN$ for a small odd multiplier $k$; its divisors now include $kp$, and if $k \approx q/p$ then the pair $(kp, q)$ is far better balanced than $(p, q)$ ever was. Precisely: whenever $kp \le q$, the scan on $kN$ halts at or before $(kp+q)/2$, so its cost is at most the AM–GM gap of the *rebalanced* pair. Once it splits $kN$, one greatest-common-divisor computation recovers a factor of $N$.

The smallest honest example is charming. Take $N = 303 = 3 \times 101$ — badly unbalanced, $r \approx 34$. Plain Fermat grinds for $34$ iterations. Multiply by $k = 33$: now $33N = 9999 = 99 \times 101$, about as balanced as a number can be. Fermat halts on the **first trial value**, zero iterations, returning the factor $99$; and $\gcd(99, 303) = 3$ hands back the prime. Thirty-four iterations become zero, purchased with one multiplication and one gcd.

This is exactly the mechanism behind Lehman's classical improvement of Fermat's method, and the locality picture explains *why* it works: multipliers are not a hack, they are a steering wheel for divisor-locality. Choosing the best $k \le K$ is now a clean Diophantine question — find $k$ with $kp/q$ close to $1$ — which is continued fractions in disguise.

---

## What a taxonomy is for

The point of classifying the four methods is not tidiness. It is that the classes predict behaviour on inputs nobody has tested.

If you are generating an RSA-style modulus, the factor-local classes tell you to make $p$ large. The gap-local class tells you something independent: make $|q - p|$ large too. The zero-cost theorem is precise about how large — a gap below roughly $2\sqrt{2p}$ is fatal *regardless of the size of $p$*. A $2048$-bit modulus whose two primes agree in their top half of bits falls to a method invented in the seventeenth century, in an afternoon. This is not folklore; it is an identity with an exact threshold, and that threshold is $(q-p-2)^2 \le 8p$.

Read the other way, the taxonomy is a map of what the open problems are. If each classical method is really a *scan minimising a cost function over the divisors of $N$* — trial division minimising $d$, Fermat minimising $d + N/d$, a multiplier replacing $N$ by $kN$ before minimising — then the locality class ought to be a property of that cost function, provable once for the whole family rather than method by method. And the zero-cost criterion $\left(\frac{p+q}{2}-1\right)^2 \le pq$, which is exactly equivalent to a prime gap of size $O(\sqrt p)$, converts a question about algorithms into a question about the distribution of prime pairs — a question where heuristics are confident and theorems are scarce.

Fermat's method is nearly four centuries old. It took a grid, a degenerate row, and an exact identity to say precisely what it has been looking at all along: not the factor, and not the numbers in between, but the gap.
