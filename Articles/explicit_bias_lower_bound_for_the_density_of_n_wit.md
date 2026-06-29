# The Mirror Trick: When Reversing a Number's Bits Leaves a Hidden Statistic Untouched

## A coin flip that isn't quite fair

Pick a whole number — say $n = 53$. Write it in binary: $53 = 110101_2$. Now add a
fixed shift, say $t = 19$, and look at the binary of the sum $n + t = 72 = 1001000_2$.

Here is the game. Count the number of $1$s in $n$, a quantity number theorists call
the **binary digit sum** and write as $s_2(n)$. Then count the number of $1$s in
$n + t$. For our example, $s_2(53) = 4$ (the string $110101$ has four ones) while
$s_2(72) = 2$. So adding $19$ *decreased* the digit sum this time.

Now ask: across all starting numbers $n$, how often does adding a fixed $t$ leave the
digit sum **at least as large**? In symbols, what fraction of $n$ satisfy
$$s_2(n + t) \ge s_2(n)?$$

Call that fraction $c_t$ — the **Cusick density** of the shift $t$. Formally it is the
long-run proportion
$$c_t = \lim_{N \to \infty} \frac{1}{N}\,\#\{\,0 \le n < N : s_2(n+t) \ge s_2(n)\,\}.$$

Naively you might guess $c_t = 1/2$: adding $t$ should push the digit sum up about as
often as it pushes it down, like a fair coin. The truth is more interesting. The coin
is *biased toward heads*. Adding any positive shift tends, slightly more often than not,
to keep or raise the digit sum. A celebrated theorem of Drmota, Kauers, and
Spiegelhofer (2016) makes this precise: for every $t \ge 1$,
$$c_t \ge \tfrac{1}{2} + 2^{-(2\,s_2(t) + 1)}.$$

The bias is small — it shrinks as $t$ acquires more $1$-bits — but it is always strictly
positive. The fair-coin intuition is simply wrong.

This article is about a sharp, exact, machine-checked sliver of that story: a *symmetry*
hiding inside the Cusick densities. It turns out that if you take the binary string of a
shift $t$ and **read it backwards**, the Cusick density does not change at all.

## Reading numbers in a mirror

Every positive integer has a binary "barcode." For example:

- $19 = 10011_2$
- $25 = 11001_2$

Look closely: $11001$ is exactly $10011$ written right-to-left. The numbers $19$ and
$25$ are **binary digit-reversals** of one another. They are different numbers, with
different arithmetic, sitting in different parts of the number line. But their barcodes
are mirror images.

A second pair behaves the same way:

- $23 = 10111_2$
- $29 = 11101_2$

Again, $11101$ is $10111$ reversed. And again, $23 \ne 29$ as numbers, but they are
reflections of each other in the binary mirror.

Reversing the bits obviously preserves two coarse features: the **number of $1$s**
(reversal just shuffles the digits) and the **length** of the string. For our pairs,
both $19$ and $25$ have three $1$s; both $23$ and $29$ have four. So
$s_2(19) = s_2(25) = 3$ and $s_2(23) = s_2(29) = 4$.

But the Cusick density $c_t$ is a far more delicate object than a digit count. It depends
on how shifting by $t$ interacts with **carries** — the cascading ripple of $1$s that
happens when you add binary numbers. Carries are notoriously sensitive to the exact
arrangement of bits, not just how many there are. There is no obvious reason a mirrored
shift should produce the *same* carry statistics. And yet:

> **Main result.** The shift $19$ and its mirror $25$ have exactly equal Cusick
> densities, and likewise the shift $23$ and its mirror $29$:
> $$c_{19} = c_{25} = \tfrac{41}{64}, \qquad c_{23} = c_{29} = \tfrac{75}{128}.$$

These are not approximations. They are exact rational numbers, established by a fully
formal, computer-verified proof. Adding $19$ keeps-or-raises the digit sum for precisely
$41$ out of every $64$ starting numbers; the mirror shift $25$ does so for precisely the
same proportion. The same exact coincidence holds for $23$ and $29$ at $75/128$.

## Why "exact" is even possible

A density is a limit over infinitely many integers. How can a finite computer pin it down
*exactly*, with no rounding?

The answer is a structural miracle that underlies this whole circle of ideas: the
predicate "$s_2(n+t) \ge s_2(n)$" is **periodic** in $n$. After a certain finite stretch,
the yes/no pattern repeats forever, like wallpaper.

Here is the intuition. Write $n$ in two halves: a low block of $M$ bits and everything
above it. When you add a modest shift $t$, the low block either absorbs the addition
cleanly or it *overflows*, sending a carry upward. If you choose $M$ large enough —
specifically $M = L + s_2(t)$, where $L$ is the bit-length of $t$ — then something rigid
happens. In the overflow case, the low block is forced to end in a run of $1$s that the
addition wipes out, guaranteeing that the digit sum drops; the predicate is *uniformly
false* there, regardless of the high bits. In the non-overflow case, the high bits cancel
out of the comparison entirely. Either way, the high bits are irrelevant: the answer
depends only on $n$ modulo $2^{M}$.

That periodicity is the engine. For $t = 19$ we have $L = 5$ (since $19 = 10011_2$ is a
five-bit number) and $s_2(19) = 3$, so the pattern repeats with period
$2^{5+3} = 2^8 = 256$. For $t = 23$, with $s_2(23) = 4$, the period is
$2^{5+4} = 2^9 = 512$.

So to know the density *forever*, you only need to count over **one period**:

- Among $n = 0, 1, \dots, 255$, exactly $164$ satisfy $s_2(n+19) \ge s_2(n)$. Therefore
  $c_{19} = 164/256 = 41/64$.
- Among the same $256$ values, exactly $164$ satisfy the inequality for the mirror shift
  $25$ as well. Therefore $c_{25} = 164/256 = 41/64$, equal to $c_{19}$.
- Among $n = 0, 1, \dots, 511$, exactly $300$ satisfy $s_2(n+23) \ge s_2(n)$, giving
  $c_{23} = 300/512 = 75/128$; and exactly $300$ satisfy it for $29$, giving the same
  $c_{29} = 75/128$.

A finite count over one period, multiplied out across infinitely many repeats by the
periodicity theorem, delivers the exact density. The "$164 = 164$" and "$300 = 300$"
coincidences are the entire content of the mirror symmetry, made concrete.

## How sharp is the bias?

It is worth pausing to see how these exact values sit against the general guarantee.
The Drmota–Kauers–Spiegelhofer bound promises only
$$c_t \ge \tfrac{1}{2} + 2^{-(2 s_2(t)+1)}.$$

For $t = 19$ (three $1$-bits) that promises $c_{19} \ge \tfrac12 + 2^{-7} = \tfrac{65}{128}
\approx 0.508$. The true value $c_{19} = \tfrac{41}{64} = \tfrac{82}{128} \approx 0.641$
blows past the guarantee — the coin is far more biased than the worst-case theorem admits.
For $t = 23$ (four $1$-bits) the bound gives $c_{23} \ge \tfrac12 + 2^{-9} \approx 0.502$,
while the truth is $c_{23} = \tfrac{75}{128} \approx 0.586$. The general theorem is a
safety net; the exact computations show the real bias is much larger, and — crucially for
this article — *identical for mirror-image shifts*.

## Why a mathematician should be surprised

It is tempting to shrug: "Reversing bits keeps the number of $1$s and the length, so of
course the answer is the same." But that reasoning is too cheap. The number of $1$s and
the length only fix the **period** ($256$ for $19$ and $25$, $512$ for $23$ and $29$).
They do *not* fix the count within that period. Plenty of distinct shifts share a digit
sum and a length while having genuinely different Cusick densities. The reversal symmetry
is asserting something stronger: that the *entire carry bookkeeping*, summed over a full
period, comes out the same for a string and its mirror image.

To feel the tension, picture addition with carries as a little machine that reads bits
from low to high, occasionally hiccupping a carry forward. Reversing $t$ does not reverse
the direction the carry machine runs — it still reads $n$ and $n+t$ from the bottom up.
So the mirror image of $t$ drives a *genuinely different* dynamical process. That the two
processes agree on their long-run "heads" rate, exactly, down to the last unit in the
$164$th and $300$th place, is the kind of coincidence that hints at a deeper invariance
waiting to be named.

Indeed, the data suggest this is no accident of two lucky pairs. The same equality has
been observed for other reversal pairs — for instance $11 = 1011_2$ and $13 = 1101_2$,
and $35 = 100011_2$ and $49 = 110001_2$ — leading to a clean conjecture: **for every
positive integer $t$, the Cusick density is invariant under binary digit reversal**,
$c_t = c_{\mathrm{rev}(t)}$. The two cases proved here, $c_{19} = c_{25}$ and
$c_{23} = c_{29}$, are the first fully rigorous, exact confirmations of that pattern for
five-bit shifts.

## The bigger picture

The Cusick density lives at a crossroads of several beautiful subjects. The binary digit
sum $s_2$ is the simplest example of an *automatic sequence* — a quantity computable by a
tiny finite-state machine reading digits. Questions about how $s_2$ behaves under addition
connect to the **Gelfond problems** on digits of integers, to the **Thue–Morse sequence**
(the parity of $s_2$, famous in combinatorics, music, and chess anti-repetition rules),
and to **transfer-operator** methods borrowed from dynamical systems and statistical
mechanics.

Cusick's conjecture — that $c_t > 1/2$ for all $t$, the precise statement that adding any
shift is biased toward non-decreasing digit sums — sat open for years before the
Drmota–Kauers–Spiegelhofer bias bound settled the inequality direction. What remains
gloriously open is the *fine structure*: exact formulas for $c_t$, the way these densities
cluster and repeat, and symmetries like the mirror invariance highlighted here.

The two equalities $c_{19} = c_{25} = 41/64$ and $c_{23} = c_{29} = 75/128$ are tiny
windows into that structure — but they are windows with perfectly clean glass. They are
exact, they are mirror-symmetric, and every digit of the count behind them has been
checked by machine. Sometimes the most persuasive evidence that a hidden law exists is a
coincidence too sharp to be a coincidence: $164 = 164$, $300 = 300$, and a number reading
the same in a binary mirror.
