# Counting in Binary, and the Coin That Won't Land Fair

## A simple question that hid for forty years

Pick a whole number. Write it in binary — as a string of $0$s and $1$s — and
count how many $1$s it has. That count has a name: the **binary digit sum**,
written $s_2(n)$. For example $13 = 1101_2$ has three $1$s, so $s_2(13) = 3$;
the number $16 = 10000_2$ has a single $1$, so $s_2(16) = 1$.

Now fix a "step" $t$ — say $t = 1$ — and ask a deceptively childish question:

> If I jump from $n$ to $n + t$, does the number of $1$s usually go **up**, or
> **down**?

Adding $1$ to $n$ scrambles its binary digits in a way that depends on the trailing
run of $1$s. Add $1$ to $\dots0111_2$ and a cascade of carries wipes out three
$1$s and creates one: the digit sum *drops*. Add $1$ to $\dots0_2$ and you just
flip the last bit up: the digit sum *rises*. Sometimes up, sometimes down. Over
the long run, which wins?

Let $c_t$ be the **density** — the long-run fraction — of starting points $n$ for
which the digit sum does not decrease, i.e. $s_2(n+t) \ge s_2(n)$:
$$ c_t \;=\; \lim_{N\to\infty} \frac{1}{N}\,\#\{\,0 \le n < N : s_2(n+t) \ge s_2(n)\,\}. $$

In 1990 the number theorist Thomas Cusick conjectured something striking: **for
every step $t \ge 1$, this coin is biased toward "up."** Formally, $c_t > \tfrac12$
always — and not by a vanishing whisker, but by an explicit, quantifiable margin
$$ c_t \;\ge\; \tfrac12 + 2^{-(2 s_2(t)+1)}. $$
The bias never disappears; it only shrinks as the step $t$ itself acquires more
binary $1$s. The conjecture resisted proof for over three decades. This article
tells the story of the machinery that makes the bias *visible and computable*,
and shows the bias exactly, with proof, in the cases where it can be pinned down
to a clean fraction.

## Why "up" should win: the carry is the whole story

The first move is to replace a vague statistical question with an exact algebraic
identity. When you add $n$ and $t$ in binary, the only thing that can *destroy*
$1$s is a **carry**. Every carry is a place where $1 + 1 = 10_2$: two $1$s go in,
one $1$ comes out one column to the left, and a digit is lost from the running
total. If adding $t$ to $n$ produces no carries at all, the digit sums simply add:
$$ s_2(n + t) = s_2(n) + s_2(t). $$
Each carry erases exactly one unit from this ideal sum. So if we let $K(n,t)$ be
the **number of carries** when adding $n$ and $t$ in base $2$, the exact bookkeeping
law is
$$ \boxed{\,s_2(n + t) + K(n,t) = s_2(n) + s_2(t)\,.} $$
This is not an approximation — it is an equality for every $n$ and $t$. It is the
keystone of everything that follows.

There is a beautiful classical way to *compute* $K(n,t)$ without ever looking at
the digits. **Kummer's theorem** (1852) says the number of base-$2$ carries when
adding $n$ and $t$ equals the exact power of $2$ dividing the binomial coefficient
$\binom{n+t}{t}$. Writing $v_2(m)$ for that "$2$-adic valuation" (how many times
$2$ divides $m$), we get
$$ K(n,t) = v_2\!\binom{n+t}{t} = s_2(t) + s_2(n) - s_2(n+t). $$
So three deep-sounding ideas — digit sums, carries, and the divisibility of
binomial coefficients — are *the same object viewed from three angles*.

The payoff is immediate. Rearranging the boxed identity, the event "$s_2$ does not
decrease" becomes a pure statement about carries:
$$ s_2(n) \le s_2(n + t) \iff K(n,t) \le s_2(t). $$
In words: **the digit sum fails to drop exactly when the addition produces no more
carries than $t$ has $1$s.** Cusick's conjecture is now a clean assertion: carries
tend to be *few*. The boxed law and this equivalence are exactly the results
proven in the formal development as `s2_add_carries` and `cusick_reformulation`.

## The skeleton of the proof: three structural facts

To turn "carries tend to be few" into hard numbers, three structural facts about
$s_2$ do the heavy lifting.

**1. Subadditivity.** You can never gain by adding:
$$ s_2(a + b) \le s_2(a) + s_2(b), $$
with equality precisely when there are no carries. The slick proof goes through
**Legendre's formula**, the elegant identity
$$ s_2(n) + v_2(n!) = n, $$
which says the digit sum of $n$ and the power of $2$ inside $n!$ together exactly
reconstruct $n$. Combined with the fact that $a!\,b!$ always divides $(a+b)!$
(because $\binom{a+b}{a}$ is a whole number), subadditivity falls out in one line.
This is `s2_subadditive`, resting on `s2_add_val`.

**2. The mean is exactly one half.** Average $s_2$ over a full binary block
$[0, 2^k)$ and you get a perfectly clean answer:
$$ \sum_{x=0}^{2^k - 1} s_2(x) = k\cdot 2^{k-1}, \qquad \text{mean } = \frac{k}{2}. $$
Across $k$-bit numbers, exactly half the bits are $1$ on average. This is *why*
the Cusick density lives near $\tfrac12$ — the baseline is genuinely a fair coin,
and Cusick's claim is that the carry structure nudges it, permanently, to the
"up" side. This is the theorem `s2_block_sum`.

**3. The good set is infinite — easily.** There is always an infinite supply of
"good" starting points. The sparse numbers $n = 2^{j+t}$ (a single high $1$-bit,
far above $t$) always satisfy $s_2(n) \le s_2(n+t)$, because adding $t$ into the
empty low bits creates no carries and only *adds* digits. This is
`cusick_good_set_infinite`, and it makes precise the intuition that "up" is never a
freak event.

## Pinning the bias: the case $t = 1$

For the single step $t = 1$, the carry count has a famous closed form: adding $1$
to $n$ carries through exactly the trailing run of $1$s, so $K(n,1) = v_2(n+1)$,
the number of trailing zeros of $n+1$. Since $s_2(1) = 1$, the carry criterion
$K(n,1) \le 1$ becomes "$n+1$ is divisible by at most $2^1$," i.e. **not** divisible
by $4$:
$$ s_2(n) \le s_2(n+1) \iff n \not\equiv 3 \pmod 4. $$
That is `cusick_t1_iff`. Three of every four residues ($0,1,2$ but not $3$) pass.
Counting exactly, among the integers in any aligned block $[0, 4m)$ precisely $3m$
are good:
$$ \#\{\,n < 4m : s_2(n) \le s_2(n+1)\,\} = 3m, $$
the theorem `cusick_t1_density`. The density is therefore **exactly**
$$ c_1 = \tfrac34, $$
which comfortably clears Cusick's predicted floor $\tfrac12 + 2^{-(2\cdot 1 + 1)} =
\tfrac12 + \tfrac18 = \tfrac58$. The coin is not just biased — for a step of $1$ it
lands "up" a full three-quarters of the time.

## The hidden self-similarity: doubling

Why should one exact value matter? Because the Cusick problem has a fractal
symmetry that lets a single computed case populate an entire infinite family.

Appending a low $0$ bit (multiplying by $2$) does not change the digit sum, while
appending a low $1$ bit adds one:
$$ s_2(2n) = s_2(n), \qquad s_2(2n+1) = s_2(n) + 1. $$
These childlike facts (`s2_two_mul`, `s2_two_mul_add_one`) snowball into a genuine
invariance. Doubling **both** the start and the step leaves the Cusick event
unchanged, on both the even and odd halves of the number line:
$$ s_2(2n) \le s_2(2n + 2t) \iff s_2(n) \le s_2(n+t), $$
$$ s_2(2n+1) \le s_2(2n+1 + 2t) \iff s_2(n) \le s_2(n+t). $$
These are `cusick_double_even` and `cusick_double_odd`. Split any count of good
numbers into its even and odd halves, apply the invariance to each half, and you
get a **self-similarity law** for the counting function
$\mathrm{Count}(t, N) = \#\{n < N : s_2(n) \le s_2(n+t)\}$:
$$ \mathrm{Count}(2t,\, 2N) = 2\cdot \mathrm{Count}(t,\, N), $$
the theorem `cusickCount_two_mul`. Iterating $k$ times gives the full orbit law
$$ \mathrm{Count}(2^k t,\, 2^k N) = 2^k\cdot \mathrm{Count}(t,\, N), $$
which is `cusickCount_two_pow_mul`. In density terms this says something clean and
memorable: **the Cusick density depends only on the odd part of the step.** Halve
$t$ until it is odd, and you know $c_t$. The whole doubling orbit
$\{t, 2t, 4t, 8t, \dots\}$ shares one density.

## A second exact family: every power of two

Feed the single computed value $c_1 = \tfrac34$ into the orbit law and an infinite
family of exact densities tumbles out. For any power-of-two step $t = 2^k$,
counting good starts in an aligned block $[0,\,2^{k+2}m)$ gives exactly
$$ \mathrm{Count}(2^k,\, 2^{k+2} m) = 3\cdot 2^k\cdot m, $$
the theorem `cusick_pow2_density`. Dividing by the block length $2^{k+2}m$ yields
$$ c_{2^k} = \tfrac34 \quad \text{for every } k \ge 0. $$
Since each such step has a single binary $1$ ($s_2(2^k) = 1$), Cusick's floor is the
same $\tfrac58$ every time, and the true density beats it by the same comfortable
$\tfrac18$. The companion criterion explains *which* starts are good: a number $n$
satisfies $s_2(n) \le s_2(n + 2^k)$ exactly when the block of bits *above* position
$k$ — that is, $\lfloor n/2^k\rfloor$ — is not congruent to $3 \pmod 4$
(`cusick_pow2_iff`). It is the $t=1$ rule, lifted $k$ bits up.

We can even name the bias as a raw surplus. In a block of length $2^{k+2}m$ the
"fair" half is $2^{k+1}m$, and the count of good starts *exceeds* this half by
exactly
$$ \mathrm{Count}(2^k,\, 2^{k+2}m) - 2^{k+1}m = 2^k m = \tfrac14\cdot 2^{k+2}m, $$
the theorem `cusick_pow2_bias`. A clean surplus of one quarter of the block, every
time. The coin doesn't just lean — for these steps it leans by precisely $25$
percentage points, forever.

## Why this is more than a curiosity

Binary digit sums are not an idle game. The function $s_2$ governs the cost of
arithmetic circuits (Hamming weight is the number of full-adders that fire), the
length of addition chains, the structure of Stern–Brocot and Pascal-mod-$2$
fractals, and the statistics of carry propagation that chip designers fight to
parallelize. Cusick's question is, at heart, a question about **carries** — the
single most expensive event in binary addition — and the result says carries are
rarer than a naive symmetry would predict. The asymmetry between "creating a $1$"
(cheap, one bit flip) and "destroying a run of $1$s" (a costly carry cascade) is
baked into the arithmetic, and it tilts the world, gently but permanently, upward.

The story also models how a stubborn conjecture yields. You do not attack the
density head-on. You translate it into carries (Kummer), anchor the carries with
an exact identity (Legendre), compute one honest case by hand ($t=1$, giving
$c_1 = \tfrac34$), and then exploit a hidden self-similarity (doubling) to spread
that one fact across infinitely many steps at once — every power of two, and indeed
every doubling orbit. What began as a coin that mysteriously refuses to land fair
becomes a precise, computable, three-quarters bias you can hold in your hand.
