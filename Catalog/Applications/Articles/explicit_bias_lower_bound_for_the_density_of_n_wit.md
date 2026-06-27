# The Stubborn Half: Why Adding a Number Usually Adds Weight

## A puzzle hiding in plain sight

Pick a whole number — say $n = 22$. Write it in binary: $22 = 10110_2$. Count
the ones: there are three of them. Mathematicians call this count the **binary
digit sum**, written $s_2(n)$. So $s_2(22) = 3$.

Now add a small fixed amount, say $t = 1$, and look again: $23 = 10111_2$, which
has four ones, so $s_2(23) = 4$. The digit sum went *up*. Try $n = 23$ instead:
$24 = 11000_2$ has only two ones, so adding one *dropped* the digit sum from four
to two. Sometimes addition piles on more ones; sometimes a cascade of carries
sweeps a whole run of them away.

Here is the natural question, first asked by Thomas Cusick around 2010. Fix the
shift $t$. Among all the integers $n$, what *fraction* of them satisfy

$$ s_2(n+t) \ge s_2(n)\,? $$

That is, how often does adding $t$ leave you with at least as many binary ones as
you started with? Call this fraction $c_t$ — the **Cusick density** of the shift
$t$.

If carries were a perfect coin flip — half the time you gain ones, half the time
you lose them — you would expect $c_t = 1/2$. Cusick's startling conjecture,
proved in 2016 by Michael Drmota, Manuel Kauers, and Lukas Spiegelhofer, is that
the coin is **always biased toward gaining**. No matter what $t$ you choose, more
than half of all integers come out ahead:

$$ c_t \;\ge\; \frac12 + \frac{1}{2^{\,2\,s_2(t)+1}}. $$

The bias is small when $t$ itself is "heavy" (has many binary ones), but it is
*never zero*. Adding a number is never a fair game. It always, ever so slightly,
favors growth.

This article tells the story of a fully machine-checked development that nails
down this phenomenon: it pins the bias *exactly* for infinitely many shifts,
explains *why* the densities are always clean fractions like $3/4$ and $11/16$,
and reveals the hidden engine — the arithmetic of carries — that drives the whole
thing.

## The weight of a number

The digit sum $s_2$ looks innocent, but it is the secret heartbeat of binary
arithmetic. Three facts about it do almost all the work.

**It is at most the number itself.** Obviously $s_2(n) \le n$: you can't have more
ones than the number is big. A tiny remark, but it anchors everything.

**It is subadditive.** Adding two numbers can only *destroy* ones, never create
them out of nothing:

$$ s_2(a+b) \;\le\; s_2(a) + s_2(b). $$

Why? Because when you add in binary, each carry merges two ones into a single
higher one — a net loss of weight. The cleanest proof routes through a
two-and-a-half-century-old gem, **Legendre's formula**. It says that the digit sum
and the number of factors of two in the factorial $n!$ together reconstruct $n$
exactly:

$$ s_2(n) + v_2(n!) = n, $$

where $v_2(m)$ is the highest power of $2$ dividing $m$. Combine this with the fact
that $a!\,b!$ always divides $(a+b)!$ (because the binomial coefficient
$\binom{a+b}{a}$ is a whole number), and subadditivity drops out in a single line.

**Its average is exactly one-half per bit.** Over a clean dyadic block — all the
numbers from $0$ up to $2^k - 1$ — the digit sums add up to precisely

$$ \sum_{x=0}^{2^k-1} s_2(x) = k\cdot 2^{\,k-1}, $$

which means the *average* number of ones is $k/2$: exactly half the bits are on,
on average. This is the deep reason the Cusick density hovers around $1/2$ in the
first place. The whole drama is about the *bias* away from this perfectly balanced
baseline.

## Carries are the whole story

The decisive move — the one that turns a fuzzy question about digit sums into a
crisp, countable one — is an idea from **Kummer's theorem** of 1852. Kummer
discovered that the number of carries you generate when adding two numbers in base
$p$ is recorded, exactly, in how many times $p$ divides their binomial
coefficient.

Apply this with $p = 2$. Define the carry count when adding $n$ and $t$ as

$$ \mathrm{carries}(t,n) \;=\; v_2\!\binom{n+t}{t}. $$

Kummer's theorem then hands us a beautiful bookkeeping identity:

$$ s_2(n+t) \;+\; \mathrm{carries}(t,n) \;=\; s_2(n) + s_2(t). $$

In words: the ones you start with ($s_2(n)+s_2(t)$, if nothing collided) minus the
ones eaten by carries equals the ones you end with. Rearranged, the Cusick
inequality becomes something you can *count*:

$$ s_2(n+t) \ge s_2(n) \quad\Longleftrightarrow\quad \mathrm{carries}(t,n) \le s_2(t). $$

Adding $t$ keeps your weight if and only if the addition triggers **no more
carries than $t$ has ones**. The fuzzy digit-sum question has become a precise
carry-budget question. And in the extreme "no-carry" case the digit sum is
perfectly additive, $s_2(n+t) = s_2(n)+s_2(t)$, the maximal possible gain — the
witness we will use to show solutions are everywhere.

## First exact value: the shift $t = 1$ and the density $3/4$

Start with the simplest shift, $t = 1$, where $s_2(1) = 1$. Adding one to $n$ in
binary flips the trailing run of ones to zeros and turns the next zero into a one.
The carry count is exactly $v_2(n+1)$, the number of trailing ones. The Cusick
condition "$\mathrm{carries} \le 1$" therefore says: $n$ ends in **at most one**
binary one. A short calculation with the $2$-adic valuation shows this is the same
as

$$ s_2(n) \le s_2(n+1) \quad\Longleftrightarrow\quad n \bmod 4 \ne 3. $$

Only residue $3 \pmod 4$ — numbers ending in two ones, like $\ldots 011_2$ —
fails. That is exactly one residue class out of four. So three out of every four
integers succeed, and we get our first exact density, on the nose:

$$ c_1 = \frac34 = \frac12 + \frac14. $$

This already crushes the conjectured floor of $1/2 + 1/8 = 5/8$ with room to
spare. And notice the *shape* of the argument: the success of $n$ depends only on
$n \bmod 4$. The predicate is **periodic**. That single observation, generalized,
turns out to be the master key.

## One shift becomes infinitely many: doubling

Here is a structural surprise. The digit sum doesn't care about trailing zeros:
appending a $0$ bit leaves it alone, $s_2(2n) = s_2(n)$, while appending a $1$ bit
bumps it by one, $s_2(2n+1) = s_2(n)+1$. Feed this into the Cusick predicate and a
clean **doubling invariance** appears. Doubling both the number and the shift
changes nothing:

$$ s_2(n) \le s_2(n+t) \quad\Longleftrightarrow\quad s_2(2n) \le s_2(2n+2t), $$

and the same equivalence holds on the odd numbers $2n+1$. Each parity half folds
back onto the *same* base predicate at $t$. Counting, this means the number of
successes exactly doubles when you double both shift and window:

$$ \#\{\,n < 2N : s_2(n) \le s_2(n+2t)\,\} \;=\; 2\cdot \#\{\,n < N : s_2(n) \le s_2(n+t)\,\}. $$

The density is therefore **constant along the doubling orbit** $\{t, 2t, 4t,
\dots\}$ — it depends only on the odd part of $t$. Iterating from $t = 1$ instantly
gives the density of *every* power of two:

$$ c_{2^k} = \frac34 \quad\text{for all } k. $$

One hard-won computation, $c_1 = 3/4$, propagates for free to an entire infinite
family, with the crisp pointwise rule $s_2(n) \le s_2(n+2^k) \iff (n / 2^k) \bmod
4 \ne 3$. The bias $1/4$ never decays along this family.

## The genuinely harder world: $t = 3$ and the density $11/16$

Powers of two are easy because they have a single binary one. The real difficulty
begins when $t$ has *two or more* ones, where a carry out of the low bits can
collide with the upper bits of $t$ and trigger a cascade. The smallest such shift
is $t = 3 = 11_2$, with $s_2(3) = 2$.

Repeat the periodicity strategy, but now the relevant window is wider — the period
jumps from $4$ to $16$. Splitting $n = 16b + a$ with $a = n \bmod 16$, the digit
sum splits cleanly, $s_2(n) = s_2(b) + s_2(a)$, by a **concatenation** law: a low
block sitting below a high block just adds its weight. For the low residues
$a \le 12$ the predicate depends only on $a$. For the three top residues
$a \in \{13, 14, 15\}$ — where adding $3$ overflows the $16$-block — the addition
*always* loses, no matter the high part $b$, because subadditivity guarantees the
high part can recover at most one of the ones the carry destroyed. Tallying the
survivors, exactly five residues mod $16$ fail: $\{5, 7, 13, 14, 15\}$. Eleven
succeed. So

$$ c_3 = \frac{11}{16}, $$

comfortably above the conjectured floor $1/2 + 1/32 = 17/32$. By the doubling
orbit, the entire family $\{3, 6, 12, 24, \dots\}$ shares this value. And here is a
subtlety worth savoring: $c_3 = 11/16$ while $c_1 = 3/4 = 12/16$ — two shifts with
*different* numbers of ones give *different* densities, and even two shifts with
the *same* number of ones need not agree. The density is not a simple function of
$s_2(t)$ alone; the fine pattern of the bits matters.

## Why the densities are always clean fractions

Both worked cases shared a feature that turned out to be no accident: the success
of $n$ depended only on $n$ modulo a power of two. The crowning structural result
proves this holds **for every shift $t$**. For any $t \ge 1$, choosing $L$ large
enough that $t < 2^L$, the Cusick predicate is *purely periodic* with period

$$ P \;=\; 2^{\,L + s_2(t)}. $$

That is, whether $s_2(n) \le s_2(n+t)$ holds depends only on $n \bmod P$. The proof
is a careful carry analysis. In the "non-overflow" regime the low window simply
carries the verdict, independent of the high bits. In the "overflow" regime — when
the low $P$-block spills over — the overflow forces the window's top $s_2(t)$ bits
to all be ones, and adding $t$ annihilates exactly those, a loss too large for the
high part to ever repair. So overflow *always* fails, regardless of high bits. The
verdict cannot depend on anything above the period.

The consequence is decisive. Because the predicate repeats with period $P$, the
count over $m$ consecutive periods is exactly $m$ times the count over one:

$$ \#\{\,n < P\cdot m : s_2(n) \le s_2(n+t)\,\} \;=\; m \cdot \#\{\,n < P : s_2(n) \le s_2(n+t)\,\}. $$

The density $c_t$ is therefore always a **dyadic rational** — a fraction with a
power of two in the denominator — equal to (the one-period count) divided by $P$.
This is exactly why $3/4$, $11/16$, $5/8$, and their kin keep appearing, and never
anything messier.

## The propagation engine: finite input, infinite conclusion

This periodicity is more than an explanation; it is a reusable machine. Suppose
that, for some shift $t$, you have checked a *single finite fact*: over one period
$P$, the number of successes beats the halfway mark by some surplus $d$,

$$ 2\cdot(\text{one-period count}) \;\ge\; P + 2d. $$

Multiply the period-scaling identity by $m$ and you instantly get, for **every**
window of $m$ periods,

$$ 2\cdot(\text{count over } Pm) \;\ge\; Pm + 2dm, $$

which is precisely the explicit bias statement $c_t \ge 1/2 + d/P$, uniform across
all window sizes. The hard, infinite part — proving the bound holds asymptotically
— is reduced to a *finite* per-shift computation of the surplus $d$, plus this
one-time, shift-independent propagation step.

Run the engine on the cases we have pinned down and the explicit biases tumble
out: $t = 1$ gives surplus $d = 1$ over period $4$, i.e. bias $1/4$; $t = 3$ gives
$d = 3$ over period $16$, bias $3/16$. Each is a one-line corollary of a single
finite check feeding a single universal lemma. The separation of concerns is the
whole point: a finite residue count for each shift, and an eternal periodicity
theorem proved once for all shifts.

## Why it matters

At first glance this is a curiosity about binary digits. But the digit-sum
function sits at a crossroads of mathematics. It governs the behavior of the
**Thue–Morse sequence**, the prototypical "fair but unpredictable" infinite word
that turns up in combinatorics, dynamics, and even chess endgame rules. It
controls the distribution of integers in **arithmetic progressions weighted by
digit parity**, a theme running from Gelfond's classical work to modern results on
primes with prescribed digit sums. Carry propagation — the engine here — is the
same phenomenon that makes binary addition circuits slow, and understanding its
statistics is genuinely useful in the analysis of algorithms.

The deeper charm is the *inevitability* of the bias. One might guess that, summed
over all integers, the gains and losses of adding $t$ would cancel into a perfect
$1/2$. They never do. There is a permanent, quantifiable thumb on the scale,
pushing the digit sum to grow more often than it shrinks — and its exact weight,
$1/2 + 2^{-(2 s_2(t)+1)}$ and better, can be computed, family by family, from
nothing more than the arithmetic of carries.

What began as a coin-flip question turns out to have a rigid, beautiful skeleton:
Legendre's centuries-old factorial formula, Kummer's carry theorem, a doubling
symmetry, and a periodicity that makes every density a clean dyadic fraction. The
coin was never fair. It was always, quietly, loaded toward growth.
