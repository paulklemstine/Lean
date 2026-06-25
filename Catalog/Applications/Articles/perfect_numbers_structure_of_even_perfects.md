# The Loyalty Index of Numbers: How Divisors Reveal Perfection

## A number that adds up to itself

Pick a number — say $6$. Now list every number that divides it evenly, but
stop short of $6$ itself: $1$, $2$, and $3$. Add them: $1 + 2 + 3 = 6$. The
parts reconstitute the whole. The ancient Greeks found this so striking that
they called such numbers **perfect**.

The next perfect number is $28$: its proper divisors $1, 2, 4, 7, 14$ sum to
$28$. After that comes $496$, then $8128$, and then a yawning gap — the fifth
perfect number, $33{,}550{,}336$, was not written down until the fifteenth
century. Perfect numbers are rare, beautiful, and — even after twenty-three
centuries — still wrapped in unsolved mystery. We do not know whether there
are infinitely many. We do not know whether a single *odd* one exists.

This article is about the simple, powerful idea that turns these questions from
mysticism into mathematics: the **abundancy index**. It is a single rational
number attached to every integer that measures how generous that integer is
with its divisors — and once you have it, perfect numbers stop being a curiosity
and become the solution of a clean equation.

## From "sum of proper divisors" to one clean ratio

The Greek definition compares a number to the sum of its *proper* divisors. A
slicker bookkeeping move is to include the number itself in the sum. Define the
**sum-of-divisors function** $\sigma(n)$ to be the total of *all* positive
divisors of $n$, the number itself included:
$$\sigma(n) = \sum_{d \mid n} d.$$

For example $\sigma(6) = 1 + 2 + 3 + 6 = 12$ and $\sigma(28) = 1+2+4+7+14+28 = 56$.

Notice that $12 = 2 \times 6$ and $56 = 2 \times 28$. That is not a coincidence:
a number is perfect exactly when its proper divisors sum to itself, which — once
you fold the number into the sum — is the same as saying $\sigma(n) = 2n$.

This invites a normalization. Divide $\sigma(n)$ by $n$ to get the **abundancy
index**:
$$A(n) = \frac{\sigma(n)}{n}.$$

The abundancy index is a kind of *loyalty score* for a number: it asks "relative
to your own size, how much do your divisors add up to?" With this single ratio,
the whole vocabulary of antiquity collapses into arithmetic on the number line:

- $A(n) < 2$: the number is **deficient** (its divisors fall short). All primes
  are deficient — a prime $p$ has $A(p) = (1 + p)/p$, just a hair above $1$.
- $A(n) = 2$: the number is **perfect**. This is the entire definition.
- $A(n) > 2$: the number is **abundant** (its divisors overflow). The smallest
  example is $12$, with $A(12) = 28/12 = 7/3 \approx 2.33$.

So a **perfect number is precisely a number whose abundancy index equals $2$.**
Everything interesting about perfection is now a question about where a single
function lands relative to the value $2$.

## Two rules that govern the index

Once you have a quantity like $A(n)$, the natural question is: how does it
behave? Does it grow predictably? Does it respect multiplication? The heart of
this work is a pair of structural laws — proved rigorously and independently of
one another — that pin down exactly how the abundancy index moves.

### Rule 1: Bigger numbers (that contain you) are at least as loyal

The first law is a **monotonicity** principle:

> **If $d$ divides $n$, then $A(d) \le A(n)$. And if $d$ is a *proper*
> divisor — strictly smaller than $n$ — then $A(d) < A(n)$ strictly.**

In words: enlarging a number by absorbing it as a factor of a bigger number can
only raise its abundancy index, never lower it. Divisors are loyal to their
multiples.

Here is the picture behind the proof, and it is wonderfully concrete. Suppose
$d$ divides $n$, and write $q = n/d$ for the "stretch factor." Take any divisor
$e$ of $d$ and multiply it by $q$: the result $e \cdot q$ is automatically a
divisor of $n$. This little map — "scale every divisor of $d$ by $q$" — sends
distinct divisors to distinct divisors (if $e_1 q = e_2 q$ then $e_1 = e_2$),
so it plants a faithful copy of $d$'s divisors inside the divisors of $n$.

Summing along this copy gives exactly $q \cdot \sigma(d)$, and since these are
just *some* of $n$'s divisors, that sum cannot exceed the total $\sigma(n)$:
$$\sigma(d) \cdot \frac{n}{d} \le \sigma(n).$$

That is the engine of the whole argument — in the formal development it is the
lemma stating $\sigma(d)\cdot(n/d) \le \sigma(n)$. Cross-multiplying turns it
into $\sigma(d)\cdot n \le \sigma(n)\cdot d$, which is literally the statement
$A(d) \le A(n)$ after dividing by $dn$.

Why is the inequality *strict* when $d < n$? Because then the stretch factor
$q = n/d$ is at least $2$, and the number $1$ — which is always a divisor of
$n$ — can never be of the form $e \cdot q$ with $q \ge 2$. So the divisor $1$
sits in $n$'s divisor list but is missing from our planted copy. One genuine
term is left over, and a sum of positive numbers with an extra positive term is
strictly larger. Hence $A(d) < A(n)$.

This strictness has a striking consequence for perfection. A perfect number sits
exactly at $A(n) = 2$. If $d$ is any proper divisor of a perfect number, then
$A(d) < 2$, so $d$ is strictly deficient. And if a perfect number $n$ properly
divided some larger $m$, then $A(m) > A(n) = 2$, so $m$ would be abundant. In
other words: **no perfect number can divide another.** Perfect numbers are, in
this precise sense, incompressible — they never nest.

### Rule 2: Coprime pieces multiply

The second law concerns how the index interacts with multiplication. It does not
behave well for *all* products — but it behaves perfectly for **coprime** ones
(numbers sharing no common prime factor):

> **If $m$ and $n$ share no common factor, then**
> $$A(m \cdot n) = A(m) \cdot A(n).$$

For example $A(12) = A(4) \cdot A(3)$ because $4 = 2^2$ and $3$ share nothing:
$A(4) = 7/4$, $A(3) = 4/3$, and indeed $7/4 \cdot 4/3 = 7/3 = A(12)$. Try it
with $A(45) = A(9)\cdot A(5)$: $A(9) = 13/9$, $A(5) = 6/5$, product $78/45 =
26/15 = A(45)$. It always works, as long as the pieces are coprime.

The reason is that the divisors of a coprime product $m \cdot n$ are exactly the
products $a \cdot b$ where $a$ runs over the divisors of $m$ and $b$ over those
of $n$, each pairing occurring once. The sum-of-divisors function therefore
factors, $\sigma(mn) = \sigma(m)\sigma(n)$, and dividing by $mn = m \cdot n$
splits cleanly into $A(m) \cdot A(n)$.

Crucially, this multiplicativity is established *on its own footing*, directly
from the multiplicative structure of $\sigma$ — not by smuggling in the
monotonicity argument, and not the other way around. The two laws are proved as
genuinely independent pillars. That matters because it is exactly the kind of
hidden circular reasoning ("A because B, and B because A") that a careful
foundation must avoid.

## Why these two rules are the right tools

Together, monotonicity and multiplicativity turn the abundancy index into a
*calculator* for abundance. Every whole number factors uniquely into prime
powers $p_1^{a_1} p_2^{a_2}\cdots$, and those prime-power blocks are automatically
coprime. So multiplicativity lets you compute $A(n)$ one prime at a time and
multiply the answers:
$$A\bigl(p_1^{a_1}\cdots p_k^{a_k}\bigr) = A(p_1^{a_1})\cdots A(p_k^{a_k}).$$

For a single prime power, the geometric series gives a clean closed form,
$$A(p^a) = \frac{1 + p + p^2 + \cdots + p^a}{p^a} = \frac{p^{a+1}-1}{p^a(p-1)},$$
which is always strictly less than $\dfrac{p}{p-1}$. So each prime $p$ can push a
number's abundancy index up by a factor of at most $p/(p-1)$: the prime $2$
contributes up to $2$, the prime $3$ up to $3/2$, the prime $5$ up to $5/4$, and
so on, with the leverage of large primes fading fast.

This is the lever that constrains perfect numbers. To reach $A(n) = 2$ you need
your primes to supply, multiplicatively, a total of exactly $2$. Small primes
are powerful; the prime $2$ alone can almost get you there. Large primes are
nearly useless — a prime in the millions barely nudges the index above $1$. This
is the quantitative reason perfect numbers are dominated by powers of $2$, and
the reason any hypothetical *odd* perfect number — barred from using the prime
$2$ at all — would need to assemble its abundancy from a vast crowd of small odd
primes. That intuition is exactly what powers the famous results bounding odd
perfect numbers: Sylvester showed in 1888 that an odd perfect number must have at
least three distinct prime factors, and modern work (Nielsen, 2015) has pushed
that to at least $101$. Each such bound is, at bottom, a careful accounting of
how much abundancy a fixed set of primes can manufacture — precisely the
arithmetic that monotonicity and multiplicativity govern.

## The classical payoff: Euclid and Euler

The abundancy framework also illuminates the one place where perfect numbers are
*completely* understood: the even case. Over two millennia, two giants closed the
book on even perfect numbers.

Euclid noticed that whenever $2^p - 1$ is a prime (a so-called **Mersenne
prime**), the number $2^{p-1}(2^p - 1)$ is perfect. You can see why through the
index: the two factors $2^{p-1}$ and the prime $2^p-1$ are coprime, so
$$A\bigl(2^{p-1}(2^p-1)\bigr) = A(2^{p-1}) \cdot A(2^p-1) = \frac{2^p - 1}{2^{p-1}} \cdot \frac{2^p}{2^p-1} = 2.$$
The Mersenne prime is engineered precisely so its single extra factor of
$2^p/(2^p-1)$ cancels the small deficit $\,(2^p-1)/2^{p-1}\,$ of the power of two,
landing the product exactly on $2$. With $p = 2$ this gives $6$; with $p=3$,
$28$; with $p = 5$, $496$.

Two thousand years later, Euler proved the converse: *every* even perfect number
arises this way. So the even perfect numbers are in exact, one-to-one
correspondence with the Mersenne primes — a result now called the **Euclid–Euler
theorem**. To this day only about fifty Mersenne primes are known, each one
hunted down by enormous distributed computations, and each one minting a fresh
perfect number of staggering size.

## What perfection teaches us

There is a lesson here that reaches beyond perfect numbers. A vague, almost
poetic idea — "a number equal to the sum of its parts" — became tractable the
moment it was attached to a *quantity*, the abundancy index $A(n) = \sigma(n)/n$.
Once you can measure something, you can ask how the measurement behaves; and the
two behaviors that matter most, **monotonicity under divisibility** and
**multiplicativity over coprime factors**, are exactly the structural laws proved
here. Monotonicity tells us perfect numbers are incompressible and that their
proper divisors are all deficient. Multiplicativity reduces every abundancy
question to a calculation prime by prime, where each prime contributes a precise,
bounded amount of "abundance."

The Greeks thought $6$ and $28$ were perfect because the universe favored them.
We now know something better: they are perfect because their divisors balance an
equation, and the scales that weigh that balance obey laws we can prove. The
mystery of whether an odd perfect number exists remains open — but every step
toward it is taken with these same two rules in hand.
