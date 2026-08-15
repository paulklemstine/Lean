# The Primes That Weren't Supposed to Be There

## A conjecture about elliptic curves, a fraction with a $7$ in the wrong place, and why it matters

### A denominator with a story

Take the curve
$$E_{55} : \quad y^2 = x^3 + 55,$$
and the point $P = (9, 28)$ sitting on it — you can check it in your head: $28^2 = 784$ and $9^3 + 55 = 729 + 55 = 784$.

Elliptic curves have a magical property: you can *add* their points. Draw the tangent line at $P$, see where it meets the curve again, reflect across the $x$-axis, and you land on a new rational point called $2P$. Do it again to get $3P$, $4P$, and so on. This is the group law, and it is the engine behind elliptic-curve cryptography, Wiles's proof of Fermat's Last Theorem, and a large part of modern number theory.

The new points are rational, but they are not pretty. For our curve the doubling formula gives
$$x(2P) = \frac{x^4 - 8Nx}{4(x^3 + N)} \Big|_{x = 9,\, N = 55} = \frac{9^4 - 8 \cdot 55 \cdot 9}{4(9^3 + 55)} = \frac{2601}{3136}.$$

Now factor that denominator:
$$3136 = 2^6 \cdot 7^2.$$

And there is the anomaly. A **$7$**.

### Why a $7$ is surprising

Every elliptic curve has a *discriminant*, a single integer that records where the curve misbehaves. For the family $E_N : y^2 = x^3 + N$ it is
$$\Delta = -432 N^2.$$
The primes dividing $\Delta$ are called the **bad primes** of the curve; for $N = 55 = 5 \cdot 11$ they are exactly $2$, $3$, $5$, and $11$ (since $432 = 2^4 \cdot 3^3$). Every other prime is a **good prime**: modulo such a prime the curve stays a genuine smooth curve, and everything about it behaves as nicely as one could ask.

There is a long-standing piece of folklore — and, in the factoring-algorithm community, an occasionally stated *conjecture* — that the denominators appearing in the orbit $P, 2P, 3P, \dots$ should be built only out of bad primes. The intuition is seductive: denominators are where a point "blows up", blowing up is a form of degeneracy, and degeneracy should only happen where the curve is degenerate. If true, this would be spectacular news for cryptanalysis: given a semiprime $N = pq$, you would only need to compute a single denominator and factor a number whose prime divisors are forced to be $\{2, 3, p, q\}$ — you would read $p$ and $q$ straight off the page.

The $7$ in $3136$ kills that hope. Seven does not divide $-432 \cdot 55^2$. Seven is a prime of **good** reduction, and it is sitting inside the denominator of the very first doubling of the very first point you would try.

That is a counterexample. What follows is the theory that explains why counterexamples are not an accident but the rule — in fact, why *every* good prime is a counterexample, why it shows up *early*, and why it shows up *often*.

### The right way to think about denominators

Here is the key reframing. A prime $\ell$ divides the denominator of $x(Q)$ precisely when the point $Q$, viewed modulo $\ell$, is the **point at infinity**.

Why? A rational point $Q = (a/d, b/f)$ in lowest terms sits on the curve, and if $\ell \nmid d$ we can simply reduce all its coordinates modulo $\ell$ and get an honest point of the curve over the finite field $\mathbb{F}_\ell$. But if $\ell \mid d$, the $x$-coordinate has a pole: in the projective picture the point runs off to infinity, and reduction sends it to $O$, the identity of the group.

So the question "which primes divide which denominators?" becomes a question about group theory:

> **For which $n$ does $nP$ reduce to the identity modulo $\ell$?**

And group theory answers instantly. Reduction modulo $\ell$ is a group homomorphism; the points that reduce to the identity form a subgroup; the set of integers $k$ with $kP$ in that subgroup is a subgroup of $\mathbb{Z}$; and every subgroup of $\mathbb{Z}$ is $m\mathbb{Z}$ for a single integer $m$.

This is the **apparition law**: for each prime $\ell$ there is a modulus $m$ such that
$$\ell \mid \operatorname{den} x(kP) \iff m \mid k.$$
The number $m$ is the *apparition index* of $\ell$: the first index at which $\ell$ appears, after which it reappears with perfect periodicity, forever.

Two things now become obvious that were invisible before. First, whether $\ell$ appears has nothing to do with whether $\ell$ divides $\Delta$; it depends only on whether the reduced point $\bar{P}$ has finite order in the group $E(\mathbb{F}_\ell)$ — and over a finite field, *every* element has finite order. Second, once $\ell$ appears at all, it appears infinitely often, at a fixed arithmetic progression of indices.

For $E_{55}$ with $P = (9,28)$, the prime $7$ has apparition index $2$. That is exactly the $7$ in $3136$. It will reappear in the denominators of $x(4P)$, $x(6P)$, $x(8P)$, $\dots$, and it does.

### Every good prime, and soon

The apparition law says the violations are periodic *if they happen at all*. The heart of the matter is showing that they always happen, and quickly. That is the following theorem.

> **Effective Apparition Theorem.** Let $N \neq 0$ be an integer, let $\ell \geq 5$ be a prime not dividing $N$ — that is, any good prime beyond $2$ and $3$ — and let $P$ be any rational point of $E_N : y^2 = x^3 + N$. Then there is an index $n$ with $0 < n \leq 4\ell$ such that $\ell$ divides the denominator of $x(nP)$ (or $nP$ is the point at infinity, which cannot happen if $P$ has infinite order).

The proof is a two-line idea dressed in careful algebra. Suppose no index in $\{1, 2, \dots, 2\ell + 1\}$ works. Then all of $P, 2P, \dots, (2\ell+1)P$ have denominators prime to $\ell$, so all of them reduce to honest points of the curve over $\mathbb{F}_\ell$. But that curve has at most $2\ell$ points: each of the $\ell$ possible $x$-values admits at most two square roots for $y$. Pigeonhole: two of our $2\ell+1$ reductions must coincide, say $mP$ and $nP$ with $m < n$.

Now the punchline — call it the **Collision Lemma**:

> **Collision Lemma.** If two rational points $P_1, P_2$ of $E_N$ have denominators prime to $\ell$ and reduce to the *same* point modulo $\ell \geq 5$ (with $\ell \nmid N$), then $2(P_1 - P_2)$ reduces to the point at infinity — that is, $\ell$ divides the denominator of $x\big(2(P_1-P_2)\big)$, unless that point is at infinity outright.

Applying this to $P_1 = nP$ and $P_2 = mP$ gives $\ell$ in the denominator at index $2(n-m) \le 4\ell$, contradicting our assumption. So a good index $n \le 4\ell$ exists after all.

Why is the Collision Lemma true? Pure chord arithmetic. If $P_1 = (x_1, y_1)$ and $P_2 = (x_2, y_2)$ have $x_1 \neq x_2$, then the group law gives the elegant formula
$$x(P_1 - P_2) = \frac{x_1 x_2 (x_1 + x_2) + 2N + 2y_1y_2}{(x_1 - x_2)^2}.$$
If the two points have the same reduction $(\bar{x}, \bar{y})$ modulo $\ell$, then the denominator $(x_1 - x_2)^2$ is divisible by $\ell^2$. What about the numerator? Reduce it: it becomes
$$\bar{x}\cdot\bar{x}\cdot 2\bar{x} + 2N + 2\bar{y}^2 = 2(\bar{x}^3 + N) + 2\bar{y}^2 = 4\bar{y}^2,$$
using the curve equation $\bar y^2 = \bar x^3 + N$ itself. So the numerator reduces to $4\bar{y}^2$ — nonzero as long as $\ell \geq 5$ (so that $4$ is invertible) and $\bar y \ne 0$. Denominator divisible by $\ell$, numerator not: the fraction has $\ell$ in its denominator, exactly as claimed. And if $\bar{y} = 0$ instead, the doubling formula $x(2Q) = (x^4 - 8Nx)/(4y^2)$ handles it — the denominator $4y^2$ picks up the $\ell$ hidden in $y$, while the numerator reduces to $-9N\bar{x} \neq 0$. That last case is why the lemma has a factor of $2$ in front.

The whole argument is elementary: no deep machinery, no Hasse bound, nothing but the addition formula and a counting argument. It also explains the shape of the constant. The bound $4\ell$ is $2 \times 2\ell$: the $2\ell$ is the crude point count on the reduced curve, and the extra $2$ is the price of the $\bar y = 0$ branch.

### From "sometimes" to "half the time"

Combine the apparition law with the effective bound and something quantitative falls out. The apparition index $m$ of a good prime $\ell$ is positive and at most $4\ell$. Therefore, among the first $K$ multiples of $P$, the number of indices at which $\ell$ pollutes the denominator is *exactly* $\lfloor K/m \rfloor$, and hence at least $\lfloor K/(4\ell) \rfloor$.

> **Density Theorem.** For every good prime $\ell \geq 5$ and every rational point $P$ of $E_N$, the set of indices $n$ at which $\ell$ divides $\operatorname{den} x(nP)$ is an arithmetic progression of modulus $m \le 4\ell$, and so has density $1/m \geq 1/(4\ell) > 0$.

The conjecture doesn't merely fail on a sparse, exotic set of indices. It fails at a *positive proportion* of them, for *every* good prime, with an explicit lower bound on the proportion.

For $E_{55}$ and $P = (9,28)$: the prime $7$ has index $2$, so it appears in half of all denominators. The prime $13$ has index $3$: a third. The prime $17$: index $6$. The prime $73$: index $3$. The prime $43$: index $7$. None of them is anywhere near the theoretical worst case $4\ell$ — the bound is a guarantee, not a prediction.

And these violations conspire. Because different primes have coprime-or-not but independent progressions, a whole finite set of good primes will appear *simultaneously* along the progression given by the least common multiple of the individual indices.

> **Simultaneous Apparition Theorem.** For any finite set $S$ of good primes $\ell \geq 5$, there is a modulus $M \le \prod_{\ell \in S} 4\ell$ such that $\prod_{\ell \in S} \ell$ divides $\operatorname{den} x(kP)$ exactly when $M \mid k$.

On $E_{55}$: since $7$ has index $2$ and $13$ has index $3$, the composite $91 = 7 \cdot 13$ divides $\operatorname{den} x(kP)$ precisely when $6 \mid k$. And indeed the denominator of $x(6P)$ factors as $2^6 \cdot 3^6 \cdot 7^2 \cdot 13^2 \cdot 17^4 \cdot 73^2 \cdot 179^2 \cdots$ — a parade of good primes, none of which was supposed to be there.

### The verdict on the conjecture

Pushing this to its conclusion, the refutation is total rather than anecdotal.

> **Refutation Theorem.** Let $N \neq 0$ and let $P$ be a rational point of $E_N : y^2 = x^3 + N$ of infinite order. Then there exist a prime $\ell \geq 5$ with $\ell \nmid N$, an index $n > 0$, and an affine point $nP$ whose $x$-coordinate has $\ell$ in its denominator. In fact infinitely many such good primes occur, and the denominators grow unboundedly on account of good primes alone.

And here is the pleasing reversal. The conjecture claimed an inclusion:
$$\{\text{primes dividing some denominator}\} \subseteq \{2, 3\} \cup \{p : p \mid N\}.$$
The truth is the *opposite* inclusion:
$$\{\text{primes dividing } \textbf{no} \text{ denominator}\} \subseteq \{2, 3\} \cup \{p : p \mid N\}.$$
Every prime other than $2$, $3$, and the divisors of $N$ *must* occur. The bad primes are not the ones that show up; they are the only ones with permission to hide.

### What this means for factoring

The original motivation was cryptanalytic. Given a semiprime $N = pq$, could the denominators of a Mordell-curve orbit hand you $p$ and $q$? The theory above says no, and computational surveys confirm it in the bluntest terms. Across samples of a dozen semiprimes with rational points of infinite order, whether a given factor of $N$ shows up in the early denominators is erratic — the smaller factor appears in roughly half to five-sixths of the cases depending on which point one starts from, the larger factor much more rarely — while the property the conjecture asserts, that *only* $\{2,3,p,q\}$ occur, held in $0\%$ of the cases examined. Each denominator is a jumble of good primes, and picking out the two that matter is no easier than factoring $N$ directly.

There is a deeper structural reason. The apparition index of a prime $\ell$ is the order of the reduced point $\bar{P}$ in $E(\mathbb{F}_\ell)$ — an object that depends on $N$ and $P$ only through their reductions modulo $\ell$. Nothing in this data knows about the *multiplicative decomposition* $N = pq$. The denominator sequence is a function of $N$ as a whole; it is not sensitive to how $N$ splits. That is a genuine barrier, and identifying it precisely is worth more than a hundred failed attempts at the same idea.

### The consolation prize is a theorem

What began as a hoped-for factoring shortcut ends as a clean, complete description of a natural arithmetic phenomenon: the denominators of an elliptic orbit are governed by the orders of reductions, every good prime appears with positive density within an explicit window of length $4\ell$, arbitrary finite sets of good primes appear together along arithmetic progressions, and the only primes allowed to be absent are the bad ones.

There is a satisfying analogy in the classical world. In the Fibonacci sequence $1, 1, 2, 3, 5, 8, 13, \dots$, every prime $\ell$ divides some Fibonacci number, and the indices at which it does form the multiples of a single number — its *rank of apparition*. The story here is the same story, told for elliptic curves: an elliptic divisibility sequence with its own law of apparition, its own periodicity, and its own effective bound. The $7$ hiding in $3136$ isn't a bug in the conjecture. It is the first visible term of a beautiful and completely deterministic pattern.
