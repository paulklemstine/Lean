# The Hidden Arithmetic of Repeating Decimals

## A number everyone has seen

Divide one by seven and you get a curious thing:

$$\frac{1}{7} = 0.142857\,142857\,142857\ldots$$

The block $142857$ repeats forever. Most of us met this in school, shrugged, and moved on. But look a little closer and the block starts whispering. Its six digits are $1, 4, 2, 8, 5, 7$. Add them up: $1+4+2+8+5+7 = 27$. Split the block in half — $142$ and $857$ — and add: $142 + 857 = 999$. Pair the digits from the two halves — $1{+}8$, $4{+}5$, $2{+}7$ — and each pair makes $9$.

None of this is a coincidence, and none of it is special to seven. Behind every repeating decimal — and, more generally, behind the repeating expansion of $1/p$ in *any* base $b$ — there is a rigid arithmetic skeleton. This article is about that skeleton, and about a single clean formula that predicts not just the *average* of the repeating digits but their *spread* — their variance — for every prime, every base, and every possible length of the repeating block.

## Long division, seen as a machine

To find the digits of $1/p$ in base $b$, you run long division. Start with a remainder of $1$. At each step you multiply the current remainder by the base, divide by $p$, write down the quotient as the next digit, and keep the new remainder. In symbols, with $r_0 = 1$,

$$r_{n+1} = (b \cdot r_n) \bmod p, \qquad d_n = \left\lfloor \frac{b \cdot r_n}{p} \right\rfloor.$$

The remainders can only take values between $0$ and $p-1$, so eventually one of them repeats and the whole process cycles. The length $\ell$ of that cycle is the length of the repeating block — the *repetend*. For $1/7$ in base $10$ the remainders run $1, 3, 2, 6, 4, 5$ and then back to $1$: six of them, matching the six-digit block.

The one identity that makes the machine tick is the definition of quotient and remainder itself:

$$b \cdot r_n = p \cdot d_n + r_{n+1}.$$

That's it. Every result below is squeezed out of this single equation by summing it, squaring it, and summing again. What makes the subject beautiful is how much structure hides inside something so plain.

## From digits to remainders

Here is the key move. Questions about the *digits* are hard, because digits are floor functions — jagged, unpredictable objects. But the *remainders* are smooth: they are just the successive powers of $b$ reduced modulo $p$. So the strategy is to translate every statement about digits into a statement about remainders.

Fix one full period of length $\ell$ and define five running totals:

- $S = \sum d_n$, the sum of the digits;
- $T = \sum d_n^2$, the sum of the squares of the digits;
- $R = \sum r_n$, the sum of the remainders;
- $Q = \sum r_n^2$, the sum of the squares of the remainders;
- $C = \sum r_n \, r_{n+1}$, the sum of neighboring remainder products.

Now sum the master identity $b r_n = p d_n + r_{n+1}$ across one whole period. Because the remainders just cycle, the shifted sum $\sum r_{n+1}$ equals $\sum r_n = R$. The terms rearrange into a startlingly simple law:

$$\boxed{\,p \cdot S = (b-1)\cdot R\,.}$$

The sum of the digits is completely determined by the sum of the remainders. For $1/7$ in base $10$: $R = 1+3+2+6+4+5 = 21$, and indeed $7 \cdot 27 = 189 = 9 \cdot 21 = (10-1)\cdot 21$. The mysterious digit-sum $27$ was never mysterious; it was $R$ in disguise.

## Squaring the machine

To reach the *variance* we need the sum of the *squares* of the digits, $T$. So we square the master identity and sum again. Squaring $b r_n = p d_n + r_{n+1}$ and adding over a period, the cross terms telescope just as before, and out drops a second exact law:

$$\boxed{\,p^2 \cdot T + 2b\cdot C = (b^2+1)\cdot Q\,.}$$

Two identities, two unknowns among the digit quantities $S$ and $T$, all expressed through the three remainder totals $R$, $Q$, $C$. The variance of the digits is, by definition,

$$V = \frac{T}{\ell} - \left(\frac{S}{\ell}\right)^2 = \frac{\ell\,T - S^2}{\ell^2}.$$

Substitute the two boxed laws and clear denominators. Everything collapses to a single closed form — the centerpiece of this work:

$$\boxed{\;p^2\,(\ell\,T - S^2) \;=\; \ell\big((b^2+1)\,Q - 2b\,C\big) \;-\; (b-1)^2\,R^2\;.}$$

Read it slowly. On the left is the variance of the repeating digits (up to the harmless factor $\ell^2$). On the right there is not a single digit — only the three remainder sums $R$, $Q$, $C$, the prime $p$, the base $b$, and the block length $\ell$. The unruly digits have been completely eliminated. To know how spread out the digits of $1/p$ are, you never need to look at the digits at all. You need only the geometry of the remainder orbit.

For $1/7$ in base $10$: $R = 21$, $Q = 91$, $C = 70$, $\ell = 6$. The right side is $6\,(101\cdot 91 - 20\cdot 70) - 81\cdot 441 = 6\cdot 7791 - 35721 = 46746 - 35721 = 11025$, and the left side is $49\,(6\cdot 159 - 27^2) = 49\cdot 225 = 11025$. They match to the last digit. The variance itself is $225/36 = 25/4 = 6.25$.

Crucially, this formula holds for **any** period length $\ell$ — not just the maximal one. That generality is the whole point.

## Why length matters: the twist

For centuries the folklore fixed on the most photogenic case: primes like $7$ for which the base is a *primitive root*, so the block is as long as it can possibly be, $\ell = p-1$. There the digits are so evenly balanced that their mean is exactly $\frac{b-1}{2}$ — for base ten, a mean of $4.5$. It is tempting to conjecture that this is a universal law: that the digits of $1/p$ always average $\frac{b-1}{2}$.

They do not.

The cleanest way to see it is to leave base ten. In base two, $1/7 = 0.\overline{001}$. The repeating block is just $0, 0, 1$ — three digits, summing to $1$, averaging $\tfrac{1}{3}$. That is nowhere near $\frac{b-1}{2} = \tfrac{1}{2}$. The naive "always half" conjecture is false, and the counterexample is as small as it gets.

What went wrong? In base two the order of $2$ modulo $7$ is only $3$, not $6$; the base is *not* a primitive root, so the repeating block is short, and short blocks need not balance. The digit-sum law $pS = (b-1)R$ still holds perfectly — it always does — but the remainder sum $R$ is no longer the neat value $\tfrac{p(p-1)}{2}$ that forces the mean to be a half. The average is a hostage of $R$, and $R$ depends on the length.

This is exactly why a formula that works for *arbitrary* block length is worth having. The classical results are the special case $\ell = p-1$ (full-length blocks) and $\ell = \frac{p-1}{2}$ (half-length blocks). The identity above covers every divisor of $p-1$ at once, with no case analysis.

## The mirror trick

There is one more piece of the skeleton, older and more famous. Return to $1/7 = 0.\overline{142857}$ and recall that the two halves $142$ and $857$ add to $999$. This is *Midy's theorem*, and it too falls straight out of the master identity.

Suppose the remainder orbit is a mirror: pairing each remainder $r_n$ with its partner $\ell/2$ steps later, the two add up to exactly $p$, so $r_{n+\ell/2} + r_n = p$, and the same holds one step further along. Then the corresponding digits are forced to be complementary:

$$d_n + d_{n+\ell/2} + 1 = b, \qquad\text{i.e.}\qquad d_n + d_{n+\ell/2} = b-1.$$

For base ten that says the paired digits sum to $9$: $1{+}8 = 4{+}5 = 2{+}7 = 9$. The "casting out nines" folklore of repeating decimals is nothing but this reflection symmetry of the remainder orbit, and it holds in every base whenever the orbit is a mirror.

## What the skeleton reveals

Step back and the picture is unified and clean. The digits of a repeating fraction look random, but they are marionettes; the strings are the remainder sums $R$, $Q$, and $C$. Three elementary identities — one from summing, one from squaring, one from combining — pull the mean and the variance of the digits directly out of those three numbers, for every prime, every base, and every possible block length. The classical mean $\frac{b-1}{2}$ and Midy's complementary halves emerge as special cases, and the tempting false generalization ("the mean is always half") is exposed by the tiny witness $1/7$ in base two.

And the story points onward. The three remainder sums are themselves sums over a multiplicative subgroup — the powers of $b$ modulo $p$. Such subgroup sums are the natural home of *Dirichlet characters* and the *generalized Bernoulli numbers* attached to them. The conjecture that motivates this whole program is that $R$, $Q$, and $C$ expand as tidy combinations of these Bernoulli numbers, indexed by the characters whose order divides $d = (p-1)/\ell$. If so, the variance of the digits of $1/p$ — a fact about grade-school long division — would be a shadow of the deep analytic arithmetic of $L$-functions. The character-free skeleton proved here is the exact bridge to that far side.

The next time a decimal repeats, remember: those digits are not wandering. They are dancing on a very short leash.
