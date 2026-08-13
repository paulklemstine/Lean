# The Certificate That Says Nothing

### A free consistency test for factoring turns out to be perfectly honest, perfectly half-sized, and perfectly useless

---

## A hint from nowhere

Imagine someone hands you a $48$-bit number $N$ — say $N = 139{,}732{,}124{,}550{,}503$ — and tells you it is the product of two primes, $N = pq$. Your job is to find them. This is the oldest hard problem in computational number theory, and the one that quietly protects a large fraction of the world's encrypted traffic.

Now imagine a second gift. A whisper, an oracle, a side channel, a leaked timing measurement: *the sum $s = p + q$ lies somewhere in the interval $[s_0 - E,\, s_0 + E]$*. You are given a window of $8001$ consecutive integers, and you are promised that the true $s$ is one of them.

That whisper is enormously valuable. Knowing $s$ and $N$ hands you the factorization instantly: $p$ and $q$ are the two roots of $x^2 - sx + N = 0$. So the whole problem collapses to finding one integer in a window of $8001$ candidates. Eight thousand guesses is nothing — you could do it before finishing this sentence.

But real hints are not that narrow. Real hints have width $2^{20}$, $2^{40}$, $2^{60}$. And the question that matters is not "can I brute-force $8001$ candidates" — of course you can — but: **can I use free arithmetic structure to shrink the window faster than I can walk it?**

There is a beautiful candidate for that free structure. It costs almost nothing to compute. It never lies. And the story of this article is the discovery that it is, in a precise and quantifiable sense, incapable of telling you anything at all.

---

## The trace and its shadow

Call $s = p + q$ the **trace** of the factorization $N = pq$. (The name comes from linear algebra: $p$ and $q$ are the eigenvalues of a $2\times 2$ matrix with determinant $N$ and trace $s$.)

Here is the free test. Pick a small prime $m$ — say $m = 13$ — that does not divide $N$. Reduce everything modulo $m$. Whatever $p$ and $q$ are, their residues $\bar p, \bar q$ must satisfy $\bar p \bar q \equiv N$, and $\bar p$ cannot be zero. So $\bar q = N/\bar p$ in the field $\mathbb{Z}/m$, and the trace of the pair must be
$$\bar s = \bar p + \frac{N}{\bar p}.$$

That is a *severe* restriction. As $x$ ranges over the $m-1$ nonzero residues, the expression $x + N/x$ sweeps out a set

$$T_m(N) \;=\; \Big\{\, x + \tfrac{N}{x} \;:\; x \in (\mathbb{Z}/m)^\times \Big\} \;\subseteq\; \mathbb{Z}/m,$$

which I will call the **trace set** of $N$ mod $m$. Any candidate $s'$ whose residue mod $m$ falls outside $T_m(N)$ is *provably* not the trace of any factorization. Cross it off. And the test is free: computing $T_m(N)$ for a handful of small primes takes microseconds, and testing a candidate is a table lookup.

So: how good is this filter? Two questions decide everything.

1. **Is it honest?** Does the true $s$ always survive? (A filter that occasionally discards the answer is worse than useless.)
2. **Is it sharp?** How many wrong candidates does it kill?

The answers turn out to be *exactly* computable, and their combination is a trap.

---

## Honest, exactly

**Theorem (Exactness).** *If $ab = N$ with $a \neq 0$ in a field, then $a + b$ lies in the trace set of $N$.*

The proof is one line: $b = N/a$, so $a + b = a + N/a$, which is by definition an element of the trace set. The true trace can never be filtered out — not at $m = 3$, not at $m = 10^{9}+7$, not at all $\omega$ primes simultaneously. Experimentally, across $400$ random semiprimes with $24$-bit factors and up to $20$ prime moduli each, the true trace survived every single time: $400/400$, at every $\omega \le 20$. That is not luck; it is a theorem with a one-line proof.

So the filter is *sound*. Now the harder question.

---

## Sharp, exactly — and exactly one bit

How big is $T_m(N)$? The map $x \mapsto x + N/x$ from the $m-1$ nonzero residues into $\mathbb{Z}/m$ is not injective. It has a symmetry, and the symmetry is the entire story.

**Theorem (Conjugate fibres).** *For nonzero $x, y$, we have $x + N/x = y + N/y$ if and only if $y = x$ or $y = N/x$.*

Two elements have the same trace exactly when they are the *same factorization written the other way round*. This is obvious in hindsight — swapping $p$ and $q$ doesn't change $p+q$ — but it is the precise reason the filter is exactly half-sized. The map is two-to-one everywhere except at the fixed points $x = N/x$, i.e. the square roots of $N$, where the two sheets collide.

Counting fibres gives the exact size:

**Theorem (Exact census).** *Over a finite field $K$ with $N \neq 0$,*
$$2\,\lvert T(N)\rvert \;=\; \big(\lvert K\rvert - 1\big) \;+\; \#\{x \in K : x^2 = N\}.$$

Since a quadratic has at most two roots, the correction term is $0$, $1$, or $2$, and therefore
$$\lvert K\rvert - 1 \;\le\; 2\,\lvert T(N)\rvert \;\le\; \lvert K\rvert + 1 .$$

Over $\mathbb{Z}/m$ for an odd prime $m$ this can be sharpened to a single elegant identity involving the Legendre symbol $\chi_m(N)$, which is $+1$ when $N$ is a nonzero square mod $m$ and $-1$ when it is not:
$$\boxed{\;2\,\lvert T_m(N)\rvert \;=\; m + \chi_m(N).\;}$$

Read that again, because it is the crux of the whole story. The trace set contains $(m + \chi)/2$ residues out of $m$. A *wrong* candidate — one whose residue mod $m$ is essentially random — survives the filter with probability
$$\frac{1}{2}\Big(1 + \frac{\chi_m(N)}{m}\Big) \;=\; \frac{1}{2} \pm \frac{1}{2m}.$$

Exactly one bit of information per prime. Not $0.9$ bits, not $1.1$ bits: one bit, up to a correction of order $1/m$ that vanishes as the primes grow.

The numbers bear this out with almost embarrassing precision. With $\omega = 3$ primes, wrong candidates were measured to survive at rate $0.1233$, against the idealized $2^{-3} = 0.125$. With $\omega = 6$: measured $0.0151$, idealized $2^{-6} = 0.0156$. The gaps are exactly the accumulated $\chi_m(N)/m$ corrections. The theory does not merely bound the experiment; it *predicts its third decimal place*.

---

## The trap

Here is where the free lunch evaporates.

With $\omega$ primes, the filter multiplies survival probability by $2^{-\omega}$. Marvellous. But the filter is *periodic*: it is defined purely by residues, so it accepts or rejects an integer based only on where that integer sits modulo $M = m_1 m_2 \cdots m_\omega$. A periodic set is *positionally blind*.

**Theorem (Positional blindness).** *A filter defined by a set of residues modulo $M$ accepts exactly the same number of integers in every window of $M$ consecutive integers, no matter where the window starts.*

Combine this with the Chinese remainder theorem, which says the filters for distinct primes are completely independent — the survivors modulo $M$ are precisely the CRT-combinations of local survivors — and you get an exact census:

**Theorem (Window census).** *In any window of $M = m_1\cdots m_\omega$ consecutive candidates, the number of survivors of all $\omega$ trace filters is exactly*
$$\prod_{i=1}^{\omega} \lvert T_{m_i}(N)\rvert \;=\; \frac{1}{2^{\omega}}\prod_{i=1}^{\omega}\big(m_i + \chi_{m_i}(N)\big),$$
*and in a window of $k$ full periods it is exactly $k$ times that.*

The count is exactly linear in the width of the window. The density is pinned at $2^{-\omega}$ and can never be converted into resolution. Wide windows stay proportionally wide.

The consequence is brutal and unconditional:

**Theorem (No amplification).** *If every modulus is at least $5$, then any window at least $M = m_1\cdots m_\omega$ wide retains at least $2^{\omega}$ surviving candidates — one of which is the true trace, and at least $2^{\omega} - 1$ of which are impostors.*

**Theorem (Isolation requires the primorial).** *If the filters leave at most one candidate in a window of width $W$, then necessarily $W < m_1 m_2 \cdots m_\omega$.*

To pin down a $k$-bit hint window you need a product of moduli exceeding $2^k$. With distinct primes, the smallest such product is a *primorial*, and the primorial of the first $\omega$ primes grows like $e^{\omega \log \omega}$. So you would need $\omega \approx k/\log k$ primes, and merely constructing and consulting their filters costs $2^{\Omega(k/\log k)}$ work. The pruning is real, the certificate is genuine, and the total effort still explodes.

You can watch this happen. Starting from a search range of $2^{24}$ candidate traces with no hint at all, the surviving population shrinks $2^{24} \to 2^{19} \to 2^{13.3} \to 2^{7.4}$ as $\omega$ goes $0 \to 6 \to 12 \to 18$. Perfect exponential decay — and perfectly matched by an exponential number of remaining candidates. The finish line recedes exactly as fast as you run.

---

## The accounting nobody does

There is a subtler point, and it is the one that separates an honest experiment from a hopeful one.

Suppose you use the hint window of $8001$ candidates. With $\omega = 6$ primes, the expensive step — the actual discriminant test that decides whether a candidate is the trace — is invoked on only $121.5$ candidates on average instead of $8001$. At $\omega = 12$: $2.9$ candidates. At $\omega = 18$: $1.1$, which is to say the true one and almost nothing else. A $7000$-fold reduction in expensive tests! Surely that is a win?

It is not, and the reason is that *you still iterated the full range*. To decide which $121.5$ candidates deserve the expensive test, you asked $\approx 1.9$ cheap membership questions about each of the $8001$ candidates — between $15{,}294$ and $15{,}550$ table lookups in total. The expensive tests you saved were traded, one for one, against cheap tests you performed. Cost parity, or worse. The filter reshuffles the work; it never reduces it.

This is the general shape of a *free-information mirage*: a test whose statistics look like a huge win right up until you count the cost of applying it.

---

## Could a cleverer test do better?

The obvious objection is that the trace set is only one filter among many. Perhaps some more ingenious residue-local consistency test prunes harder. Perhaps a test that *couples* the primes — that looks at all residues at once instead of one prime at a time — extracts correlations that the independent tests miss.

Both doors are closed, and closed by the same one-line observation.

Call a filter **exact** if it never rejects the truth: it accepts $a+b$ whenever $ab = N$. Exactness is the *minimum* requirement for a filter you intend to run inside a search — a filter that isn't exact can throw away the answer.

**Theorem (Minimality).** *Every exact filter contains the entire trace set.*

Why? Because for each nonzero residue $x$, the pair $(x, N/x)$ *is* a factorization of $N$ modulo $m$, so exactness forces the filter to accept its trace $x + N/x$. Every element of the trace set is the trace of some legitimate local factorization, and an exact filter must accept all of them. Hence every exact filter mod $m$ retains at least $(m-1)/2$ residues — at least half. **No residue-local consistency test whatsoever can prune a wrong candidate by more than one bit per prime.** The trace set is not merely a good filter; it is the *best possible* exact filter, and the best possible is one bit.

And coupling? A single filter living modulo the full product $M$, allowed to correlate all the primes arbitrarily, is still forced by exactness to contain the CRT-image of the product of the local trace sets — because a coordinate-wise choice of local factorizations glues, via the Chinese remainder theorem, into a genuine factorization mod $M$. So a coupled exact filter has at least $\prod_i \lvert T_{m_i}\rvert \geq 2^{\omega}$ elements, and the same isolation barrier applies verbatim. Cleverness buys nothing, because exactness has already spent the entire budget.

---

## Fermat, wearing a disguise

There is a final, deflating identification that explains *why* the trace filter cannot be a shortcut: it is not a new idea at all.

**Theorem (Fermat equivalence).** *An integer $s$ is the trace of an integer factorization $N = ab$ if and only if $s^2 - 4N$ is a perfect square. Moreover, if $d^2 = s^2 - 4N$, the factors are explicitly $a = \frac{s-d}{2}$ and $b = \frac{s+d}{2}$.*

And the local filter is the local shadow of exactly this statement:

**Theorem (Local discriminant test).** *In a field of characteristic other than $2$ with $N \neq 0$, a residue $t$ lies in the trace set of $N$ if and only if $t^2 - 4N$ is a square.*

So "is $s$ an admissible trace?" is literally the question "is $s^2 - 4N$ a square?", and scanning traces $s$ upward from $2\sqrt{N}$ *is* Fermat's difference-of-squares method, restated in different coordinates. The residue filters are precisely the classical statement "a perfect square must be a quadratic residue modulo every prime" — the same observation that powers Fermat sieves, and the same reason those sieves speed up the constant but not the exponent. A change of coordinates cannot create information.

---

## One more empty room

For completeness, one might hope for a *different* free filter: not on the trace $s = p+q$, but on the factor $p$ itself. Which residues mod $m$ can a factor of $N$ have?

**Theorem (The factor filter is empty).** *For $N \neq 0$ in a field, a residue $a$ is the residue of some factor of $N$ if and only if $a$ is invertible.*

Every unit works, because $a \cdot (N/a) = N$ always. So the admissible-factor set is *all of* $(\mathbb{Z}/m)^\times$, and the filter merely re-tests coprimality — which any prime candidate satisfies automatically. Measured survival rate: $1.0000$. Not $0.999$: exactly one. The room is not sparsely furnished; it is empty.

---

## What a negative result is worth

It is tempting to read all this as failure. It is the opposite.

Each of the statements above is an *exact identity*, not an estimate: the size of the filter is $m + \chi(N)$ over $2$, on the nose; the survivor count in any window of $M$ consecutive integers is $\prod(m_i + \chi_i)/2^{\omega}$, on the nose; every exact filter contains the trace set, no exceptions. Exact identities are how a research direction gets *closed* rather than merely discouraged. There is now no room left for a cleverer choice of primes, a smarter membership rule, or a subtler coupling: the barrier is not statistical, it is structural, and it follows from a two-to-one fibre count that fits in a paragraph.

Together with the parallel closures of the factor-residue and multiplicative-order filters, this seals the whole *residue-filter family* for the interval-hint problem. Free local consistency information about a semiprime — on the factor, on the order, or on the trace — is real, is exactly quantifiable at one bit per prime, and is exactly worthless for amplifying a hint, because a bit of pruning per prime costs a prime's worth of modulus and the two cancel identically.

The deeper moral generalizes past factoring. A test can be perfectly sound, perfectly sharp, and perfectly free, and still transmit no usable information — because *soundness itself* sets a floor on how much it can reject. The trace-set filter is a certificate that always verifies, always halves, and never points anywhere. It is a beautiful thing to hold in your hand and know, precisely, why it is empty.
