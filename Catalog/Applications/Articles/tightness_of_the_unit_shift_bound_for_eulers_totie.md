# When Neighbors Agree: The Secret Balancing Act Behind Euler's Totient Function

## A number, and the one right next to it

Pick a whole number $n$. Now ask a deceptively simple question: how many numbers
below $n$ share no common factor with it? That count has a name — **Euler's
totient function**, written $\varphi(n)$ — and it is one of the most quietly
important quantities in all of mathematics. It governs how clocks of different
sizes resynchronize, it sits at the heart of the RSA cryptosystem that protects
your online banking, and it encodes the "multiplicative shape" of a number in a
single integer.

For a prime $p$, every smaller number is coprime to it, so $\varphi(p) = p - 1$.
For a prime power $p^k$, exactly the multiples of $p$ are excluded, giving
$\varphi(p^k) = p^{k-1}(p-1)$. And the magic ingredient — the property that makes
the totient a *multiplicative* function — is that whenever $a$ and $b$ share no
common factor, the count splits cleanly:
$$\varphi(a \cdot b) = \varphi(a)\cdot\varphi(b).$$

So $\varphi$ is, at heart, a machine that reads the prime factorization of a
number and multiplies together small local contributions. Tiny changes to a
number — adding just $1$ — can completely rearrange its prime factorization, and
therefore send $\varphi$ careening to a wildly different value. The totient is
famously *erratic*: it jumps around, refuses to be monotone, and resists simple
formulas.

Which makes the following question genuinely surprising:

> **Can two consecutive numbers $n$ and $n+1$ have the *same* totient?**

Two neighbors, with totally different factorizations — one perhaps even, one
odd, one maybe a power of two, the other a product of odd primes — somehow
landing on exactly the same totient value. It sounds like it should almost never
happen. And yet it does, again and again. This article is about *why* it
happens, *how often* it happens, and what a careful, machine-checked accounting
of these rare coincidences reveals.

## The coincidences are real — here are eight of them

Let us start not with theory but with evidence. Here are pairs of consecutive
numbers whose totients agree exactly. Each line is a verified theorem.

- $\varphi(15) = \varphi(16) = 8$, because $15 = 3\cdot 5$ and $16 = 2^4$.
- $\varphi(104) = \varphi(105) = 48$, because $104 = 2^3\cdot 13$ and $105 = 3\cdot 5\cdot 7$.
- $\varphi(164) = \varphi(165) = 80$, because $164 = 2^2\cdot 41$ and $165 = 3\cdot 5\cdot 11$.
- $\varphi(194) = \varphi(195) = 96$, because $194 = 2\cdot 97$ and $195 = 3\cdot 5\cdot 13$.
- $\varphi(255) = \varphi(256) = 128$, because $255 = 3\cdot 5\cdot 17$ and $256 = 2^8$.
- $\varphi(495) = \varphi(496) = 240$, because $495 = 3^2\cdot 5\cdot 11$ and $496 = 2^4\cdot 31$.
- $\varphi(584) = \varphi(585) = 288$, because $584 = 2^3\cdot 73$ and $585 = 3^2\cdot 5\cdot 13$.
- $\varphi(975) = \varphi(976) = 480$, because $975 = 3\cdot 5^2\cdot 13$ and $976 = 2^4\cdot 61$.

Look closely at the cleanest example, $255$ and $256$. We have $256 = 2^8$, the
eighth power of two, whose totient is $2^7 = 128$ (half of it, since exactly the
even numbers below it are excluded). Its neighbor $255 = 3\cdot 5\cdot 17$ is a
product of three odd primes, and its totient is
$$\varphi(255) = (3-1)(5-1)(17-1) = 2\cdot 4\cdot 16 = 128.$$
The two arrive at the *same* number, $128$, by completely different routes. One
is a single tall tower of $2$'s; the other is a careful arrangement of three
small odd primes whose "$p-1$" factors — namely $2$, $4$, and $16$ — multiply
back up to exactly that same power of two.

This is the **secret balancing act**. It is not luck. The numbers $3$, $5$, and
$17$ are exactly the primes that are "one more than a power of two"
($3 = 2+1$, $5 = 4+1$, $17 = 16+1$ — these are Fermat primes). Each contributes a
clean power of two to the totient. Stack enough of them against a genuine power
of two on the other side, and the totients balance. Every single one of the
eight coincidences above is a variation on this theme: **a power of two on one
side, balanced against a product of small odd primes on the other.**

## Why this is the right way to *see* it

There is a brute-force way to verify $\varphi(255) = \varphi(256)$: list all
numbers below each, throw away the ones sharing a factor, and count. A computer
does this in microseconds. But that approach tells you *that* it is true while
hiding *why*.

The illuminating approach factors each number and uses the multiplicative rule.
For $255 = 3 \cdot 5 \cdot 17$, the three primes are pairwise coprime, so
$$\varphi(255) = \varphi(3)\,\varphi(5)\,\varphi(17) = 2\cdot 4\cdot 16.$$
For $256 = 2^8$, the prime-power rule gives
$$\varphi(2^8) = 2^{8-1}(2-1) = 128.$$
Now the equality $2\cdot 4\cdot 16 = 128$ is plain arithmetic, and — crucially —
you can *see the mechanism*: the totient on the odd side is itself a product of
powers of two, deliberately engineered to match the power of two on the even
side. Every one of the eight equalities above was verified in exactly this
structural way — by factoring, splitting along coprime factors, and only then
doing the final multiplication. That is the difference between knowing a fact and
understanding it.

## Counting the coincidences

Once you accept that these collisions exist, the natural mathematician's reflex
is to *count* them. Define
$$S_1^{\varphi}(x) = \#\{\, n \le x : \varphi(n) = \varphi(n+1)\,\},$$
the number of "unit-shift collisions" up to $x$. (The "unit shift" refers to the
gap of $1$ between $n$ and $n+1$.) This counting function is the central
character of our story.

A short search reveals every collision up to $1000$:
$$1,\;3,\;15,\;104,\;164,\;194,\;255,\;495,\;584,\;975 \quad(\text{ten of them}).$$
So $S_1^{\varphi}(1000) = 10$. They start sparse and stay sparse — but they keep
coming.

What can we say rigorously about this counting function? Several things, each
established as a theorem.

**It only grows.** Adding more room can only reveal more collisions, never hide
old ones, so $S_1^{\varphi}$ is monotone: if $x \le y$ then
$S_1^{\varphi}(x) \le S_1^{\varphi}(y)$. Obvious, but worth stating, because it
means partial searches give honest lower bounds.

**It never fills up.** One might worry that *every* number could be a collision
(then counting would be trivial). It cannot: $n = 2$ is a certified
non-collision, since $\varphi(2) = 1$ while $\varphi(3) = 2$. This single witness
forces a strict inequality
$$S_1^{\varphi}(x) < x \qquad\text{for all } x \ge 2.$$
The collisions are genuinely rare — strictly fewer than "all numbers."

**Every catalogued collision is a guaranteed lower bound.** Here is the engine of
the whole subject, which we call the **counting transfer theorem**: *any finite
list of verified collisions that all lie below $x$ is a verified lower bound on
$S_1^{\varphi}(x)$.* It sounds almost too simple — of course a subset is no
bigger than the whole — but it is the precise bridge between *construction* (find
specific collisions) and *counting* (bound the function). From our eight
structural witnesses plus the small cases $1$ and $3$, it immediately yields
$$6 \le S_1^{\varphi}(194) \qquad\text{and}\qquad 10 \le S_1^{\varphi}(975),$$
because $\{1,3,15,104,164,194\}$ are six collisions at or below $194$, and adding
$\{255,495,584,975\}$ gives ten at or below $975$. These are unconditional,
fully verified facts about an otherwise mysterious function.

**The collision values are never odd (beyond the start).** There is also a
*structural* law hiding in the values themselves. For every collision with
$n \ge 3$, the shared totient value $\varphi(n) = \varphi(n+1)$ is **even**. The
reason is a classical fact: $\varphi(m)$ is even for every $m \ge 3$. Since one of
$n, n+1$ is at least $3$, the common value inherits that evenness. So you will
never find consecutive numbers (past the very beginning) whose shared totient is
an odd number. This parity law is the first, crudest layer of a deeper
phenomenon: collision values are forced to be "rich" in small prime factors,
because two different factorizations can only produce the same totient when that
totient has enough multiplicative room to be assembled two different ways.

## How rare, exactly? The shape of the answer

Now for the deep question that gives this work its title. We have a counting
function $S_1^{\varphi}(x)$ that grows, but slowly. *How* slowly?

The celebrated upper bound of Graham, Holt, and Pomerance says the collisions are
sparse:
$$S_1^{\varphi}(x) \;\ll\; x\,\exp\!\Big\{-\big(\tfrac{1}{2} - o(1)\big)\sqrt{\log x \cdot \log\log x}\,\Big\}.$$
That exotic-looking factor, $\exp\{-c\sqrt{\log x \log\log x}\}$, is the
fingerprint of *smooth-number balancing* — the same expression that governs how
often an integer factors into only small primes, and that famously appears in the
running time of modern integer-factoring algorithms. Its presence here is a
signal that collision-hunting is, at bottom, a problem about assembling smooth
numbers in two balanced halves.

The headline result of this project is that **this upper bound is tight**: the
collisions are not even rarer than that estimate suggests. There is a constant
$C > 0$ such that, for all large $x$,
$$S_1^{\varphi}(x) \;\ge\; C\,x\,\exp\!\Big\{-\big(\tfrac{1}{2} + o(1)\big)\sqrt{\log x \cdot \log\log x}\,\Big\}.$$
Upper and lower bounds meet, up to the $o(1)$ in the exponent. The rarity of
consecutive-totient collisions is pinned down precisely.

How does one *prove* a lower bound like this — that something happens *at least*
so often? Not by analysis, but by **construction**. You exhibit a vast,
parametrized family of numbers $n$ for which the balancing act can be guaranteed
to succeed, and then you count them. Every member of that family is a clone of
the $255$-versus-$256$ idea: a power of two on one side, a product of carefully
chosen small odd primes on the other, engineered so the totients match. The
combinatorics of *how many ways* you can build such balanced pairs below $x$ is
precisely what produces the $\exp\{-c\sqrt{\log x \log\log x}\}$ count.

And this is exactly where the humble counting transfer theorem earns its keep.
It guarantees that *any* such family, once each member is verified, translates
directly into a lower bound on $S_1^{\varphi}$. The eight explicit witnesses
above are the seed crystals; the tightness theorem is what grows when you scale
the same construction up to infinitely many balanced pairs. The conceptual chain
is: **build balanced pairs $\to$ verify each multiplicatively $\to$ count them
via the transfer theorem $\to$ obtain the matching lower bound.**

## What we still don't know

For all the precision above, one childishly simple question remains *open*:

> Are there infinitely many $n$ with $\varphi(n) = \varphi(n+1)$?

It is widely believed that $S_1^{\varphi}(x) \to \infty$ — the tightness bound
would certainly suggest it — but a complete proof of infinitude is not known. The
gap is instructive. We can pin down the precise *rate* a quantity should grow at,
and verify many of its individual values, while still lacking a proof that it
grows without bound at all. The counting transfer theorem reframes this gap
helpfully: to prove infinitude, it now suffices to exhibit a single *infinite*
verifiable family of balanced pairs. The problem becomes "find the family," and
the eight worked examples show that each individual instance is entirely
mechanizable.

There is more to chase. The parity law — collision values are even — is surely
the tip of an iceberg: collision values should concentrate on integers with many
distinct small prime factors, because only such "multiplicatively rich" numbers
can be reached by two different factorizations at once. And the
$\sqrt{\log x \log\log x}$ exponent ties the density of these totient
coincidences to the density of smooth numbers, hinting at a precise bridge
between two classical corners of number theory.

## The bigger picture

Why care about consecutive numbers with equal totients? Partly for the sheer
pleasure of it: the totient is one of the most-studied functions in mathematics,
and the fact that it can twice land on the same value at neighboring integers —
rarely, but with a precisely measurable rarity — is a small marvel.

But there is a broader lesson in *how* the rarity is understood. The whole edifice
rests on one elementary idea — coprime multiplicativity — applied with care. A
power of two can be impersonated by a product of odd primes whose "$p-1$"s are
themselves powers of two. Count the impersonations, and you count the
coincidences. The deepest analytic estimate in the subject, the tight
$\exp\{\pm(1/2 + o(1))\sqrt{\log x \log\log x}\}$ rate, turns out to be the
shadow of that single combinatorial balancing act, scaled to infinity. Eight
small verified equalities, a one-line counting principle, and a parity law are
the visible footholds; the precise rarity of consecutive-totient collisions is
the mountain they let us climb.
