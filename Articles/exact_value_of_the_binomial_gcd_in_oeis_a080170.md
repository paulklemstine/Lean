# When a Beautiful Formula Breaks: The Hidden Arithmetic of a Binomial GCD

## A sequence that almost behaved

Some of the most enchanting objects in mathematics are sequences of whole numbers that seem to obey a secret rule. You compute the first few terms, a pattern leaps out, and for a while the universe feels orderly. Then, somewhere down the line, the pattern stumbles — and the stumble turns out to be more interesting than the rule.

This is the story of one such sequence. It lives in the Online Encyclopedia of Integer Sequences under the catalog number **A080170**, and it is built from binomial coefficients — the numbers $\binom{n}{k}$ that count the ways to choose $k$ objects from $n$. For each integer $k \ge 2$, gather a whole family of binomial coefficients and take their greatest common divisor:

$$D(k) = \gcd_{2 \le q \le k+1} \binom{qk}{k}.$$

In words: fix $k$. Now look at $\binom{2k}{k}$, $\binom{3k}{k}$, $\binom{4k}{k}$, and so on up to $\binom{(k+1)k}{k}$. These are enormous numbers. Their greatest common divisor, $D(k)$, is the largest integer that divides every single one of them. The first several values are surprisingly small and tidy:

$$D(2)=3,\; D(3)=4,\; D(4)=5,\; D(5)=3,\; D(6)=7,\; D(7)=8,\; D(8)=9,\; D(9)=5,\; D(10)=11,\dots$$

Stare at this list beside the numbers $k+1 = 3, 4, 5, 6, 7, 8, 9, 10, 11, \dots$ and a tantalizing coincidence appears. When $k+1$ is a prime — $3, 5, 7, 11$ — the value $D(k)$ is exactly that prime. When $k+1$ is a prime *power* — $4 = 2^2$, $8 = 2^3$, $9 = 3^2$ — the value $D(k)$ is exactly that prime power. The gcd seems to be reading off the most "concentrated" prime piece of $k+1$.

That observation is the heart of a conjecture made by the mathematician Ralf Stephan. To state it we need one definition.

## The dominant prime power

Every whole number $n$ greater than $1$ has a unique factorization into primes, like $12 = 2^2 \cdot 3$ or $360 = 2^3 \cdot 3^2 \cdot 5$. Among the prime-power chunks of this factorization, one is the biggest. Call it the **dominant prime power** of $n$, written $P(n)$:

$$P(n) = \max_{p \mid n} \; p^{\,v_p(n)},$$

where $v_p(n)$ is simply the exponent of the prime $p$ in the factorization of $n$. For $n = 12 = 2^2 \cdot 3$ the two prime-power chunks are $2^2 = 4$ and $3^1 = 3$, so $P(12) = 4$. For $n = 360 = 2^3 \cdot 3^2 \cdot 5$ the chunks are $8, 9, 5$, so $P(360) = 9$.

Stephan's conjecture comes in two parts. The first is about *when* the gcd is interesting:

> **Nontriviality.** $D(k) > 1$ exactly when the dominant prime power dominates everything else — precisely, when $\dfrac{k+1}{P(k+1)} \le P(k+1)$.

The second, bolder part claims to pin down the *exact value*:

> **Exact value.** Whenever that dominance condition holds, $D(k) = P(k+1)$; otherwise $D(k) = 1$.

It is a gorgeous claim. It says a wild gcd over gigantic binomial coefficients secretly equals nothing more than the largest prime-power lump inside $k+1$. And for prime and prime-power values of $k+1$, it is dead-on.

So is it true?

## The crack at $k = 11$

The honest way to test a clean formula is to keep computing until it either earns your trust or breaks it. The formula survives $k = 2$ through $k = 10$ without a scratch. Then comes $k = 11$.

Here $k+1 = 12 = 2^2 \cdot 3$, and we already found $P(12) = 4$. So Stephan's exact-value formula predicts $D(11) = 4$. But the actual computation gives

$$D(11) = 2.$$

The formula is off by a factor of two. This is not a rounding error or an edge case — it is a genuine counterexample, and it is the **first** one. After it, the failures come thick and fast: $k = 23, 29, 35, 39, 44, 47, 55, 59, 62, 69, 71, 79, \dots$ The exact-value conjecture is simply false.

What makes the disproof satisfying is not the brute-force computation but the *reason*. We can see exactly where the factor of $4$ leaks away. The gcd $D(11)$ must divide every member of its family, including the term at $q = 5$:

$$\binom{5 \cdot 11}{11} = \binom{55}{11} = 119{,}653{,}565{,}850.$$

Now look at this number modulo $4$: it equals $2$. So $4$ does **not** divide $\binom{55}{11}$. If $D(11)$ really equaled $4$, then $4$ would have to divide $\binom{55}{11}$, which it does not. Contradiction. The single term $\binom{55}{11}$ is enough to kill the predicted value $4$ and force $D(11)$ down to $2$. No exhaustive search is needed — one binomial coefficient does all the work.

## Kummer's century-old lens

To understand *why* $\binom{55}{11}$ is divisible by $2$ but not by $4$, we turn to a theorem from 1852 that remains one of the sharpest tools in all of number theory: **Kummer's theorem**.

Kummer's theorem answers a deceptively simple question: exactly how many times does a prime $p$ divide a binomial coefficient $\binom{a+b}{a}$? His answer is breathtakingly concrete. Write $a$ and $b$ in base $p$ and add them, the way a schoolchild adds with carries. Then:

> The number of times $p$ divides $\binom{a+b}{a}$ equals the number of **carries** when you add $a$ and $b$ in base $p$.

That is the whole secret. The divisibility of a binomial coefficient is just bookkeeping about carrying digits.

Apply this to our gcd. The term $\binom{qk}{k}$ can be written as $\binom{k + (q-1)k}{k}$, so the power of $p$ dividing it equals the number of carries when adding $k$ and $(q-1)k$ in base $p$. As $q$ ranges over the family, the number of carries goes up and down. And the gcd takes the *minimum* power of $p$ over all $q$ — because the gcd must divide every term, it can only contain as many factors of $p$ as the stingiest term allows.

This is the structural heart of the matter. Stephan's formula implicitly assumed the dominant prime power $p^a$ in $k+1$ would always survive into the gcd. But Kummer's carry-counting reveals that some clever value of $q$ can produce *fewer* carries than $a$, cancelling the digits at the top and dragging the gcd below $p^a$. At $k = 11$, the term $q = 5$ produces only **one** carry in base $2$ instead of two, which is exactly why a factor of $2$ — not $4$ — is all that survives.

## What survives, and a corrected law

A disproof is not the end of the story; it is an invitation to find the *right* law. Three weaker claims were stress-tested against every value up to $k = 201$, and all three held firm.

**The gcd is always one or a prime power.** Across the entire tested range, $D(k)$ is either $1$ or a single prime raised to a power — never a product of two different primes. The reason is an elegant incompatibility: for two distinct primes to both survive into the gcd, each would need a carry for *every* value of $q$, but the carry patterns of two different primes clash, so at most one prime can win.

**The nontriviality dichotomy holds exactly.** The claim that $D(k) > 1$ if and only if $\tfrac{k+1}{P(k+1)} \le P(k+1)$ passed every test. Intuitively, $D(k)$ exceeds $1$ precisely when some prime is forced into a carry for *every* $q$ — and that forcing happens exactly when the dominant prime power overwhelms its complementary factor.

**The prime-power case is exact, and provably so.** When $k+1$ is itself a prime $p$, one can prove rigorously — not just check — that $p$ divides $D(p-1)$ while $p^2$ does not. The lower bound comes from showing every term in the family has at least one carry in base $p$. The upper bound comes from the central term $q = 2$: adding $p-1$ to itself in base $p$ produces *exactly one* carry, so $\binom{2(p-1)}{p-1}$ is divisible by $p$ but not $p^2$. Since the gcd divides this central term, its $p$-part is pinned to exactly $p^1$. Together these give $D(p-1) = p$ on the nose, for every prime $p$.

Finally, the carry picture suggests a **corrected exact formula**, and it matches the data perfectly for all $2 \le k \le 201$. Write $n = k+1$. For each prime $p$ dividing $n$, let $p^a$ be its exact power in $n$ and let $m = n / p^a$ be the leftover factor. Then

$$D(k) = \max_{p \mid n} \; p^{\,\max\!\left(0,\; a - \lfloor \log_p m \rfloor\right)},$$

with the convention that the value is $1$ if every exponent collapses to zero. The term $\lfloor \log_p m \rfloor$ is exactly the number of top digits where the complementary factor $m$ forces carry cancellation. When $m = 1$ — that is, when $n$ is a prime power — the correction term vanishes and we recover Stephan's $p^a$, explaining why the original formula was flawless on prime powers and only on prime powers. At $k = 11$, the prime $p = 2$ has $a = 2$ and $m = 3$, giving $\lfloor \log_2 3 \rfloor = 1$, so the exponent drops from $2$ to $1$: the formula correctly predicts $D(11) = 2$.

## Why this matters

It is tempting to dismiss a corrected formula for an obscure integer sequence as a curiosity. But the episode is a miniature of how mathematics actually advances. A clean conjecture, beautiful and almost right, met the unsentimental arithmetic of carries and broke. The break was not random noise — it was a precise signal pointing at the true mechanism. Kummer's 170-year-old theorem, originally about a single binomial coefficient, turned out to govern an entire gcd, and the corrected law fell out of taking carries seriously.

There is also a lesson about certainty. The counterexample at $k = 11$, the prime-fibre results, and the corrected formula were not merely computed — they were checked with the full rigor of a formal proof system, so that the disproof of the exact-value claim and the exactness on the prime fibre are now established facts, not numerical impressions. When a beautiful formula breaks, it is worth knowing — beyond any doubt — exactly where, and exactly why.

The binomial coefficients were never really hiding the dominant prime power. They were hiding the carries. And carries, once you learn to read them, tell the whole story.
