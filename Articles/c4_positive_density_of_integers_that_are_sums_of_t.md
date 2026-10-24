# The Vanishing Sums: How a Humble Number Sequence Hides a 400-Year-Old Theorem

*Almost no integer is the sum of two "anti-Fibonacci" numbers. Exactly how rarely they occur is a question Fermat would have recognised.*

---

## A sequence that adds the wrong thing

Everyone knows the Fibonacci rule: to get the next number, add the two before it. $1, 1, 2, 3, 5, 8, 13, \dots$ The numbers grow exponentially, roughly by the golden ratio $\varphi \approx 1.618$ at each step.

Now change one detail. Instead of adding the previous *term*, add the current *position*. Start at $A_0 = 1$ and set $A_n = A_{n-1} + n$:

$$1,\; 2,\; 4,\; 7,\; 11,\; 16,\; 22,\; 29,\; 37,\; 46,\; 56,\; 67,\; \dots$$

We call these the **anti-Fibonacci numbers**. Where Fibonacci explodes, this sequence creeps along quadratically. It has the closed form

$$A_n = \frac{n(n+1)}{2} + 1,$$

which is one more than a triangular number. (Recreational mathematicians know it as the "lazy caterer's sequence": $A_n$ is the largest number of pieces you can cut a pancake into with $n$ straight cuts.)

Here is the question this article answers. Take any two anti-Fibonacci numbers, repeats allowed, and add them. Which integers do you get?

$$A_0 + A_0 = 2,\quad A_0 + A_1 = 3,\quad A_1 + A_1 = 4,\quad A_0 + A_2 = 5,\quad A_1 + A_2 = 6,\quad A_0 + A_3 = 8, \dots$$

Write out every such sum up to $40$ and you get

$$2, 3, 4, 5, 6, 8, 9, 11, 12, 13, 14, 15, 17, 18, 20, 22, 23, 24, 26, 27, 29, 30, 31, 32, 33, 36, 38, 39, 40.$$

The numbers $7, 10, 16, 19, 21, 25, 28, 34, 35, 37$ are missing. At first glance the list looks random. It is not. The missing numbers follow a rule that goes back to Pierre de Fermat, and that rule settles how common these sums are.

## The magic identity

The whole story starts from one line of algebra. Multiply an anti-Fibonacci number by $8$:

$$8A_n = 4n(n+1) + 8 = (2n+1)^2 + 7.$$

So every anti-Fibonacci number is an odd square plus seven, divided by eight. Add two of them, $m = A_a + A_b$:

$$8m = (2a+1)^2 + (2b+1)^2 + 14, \qquad\text{that is,}\qquad 8m - 14 = (2a+1)^2 + (2b+1)^2.$$

So a sum of two anti-Fibonacci numbers produces a **sum of two squares**. The converse also holds, and that is the key result.

> **Reduction Theorem.** An integer $m$ is a sum of two anti-Fibonacci numbers if and only if $8m - 14$ is a sum of two perfect squares. Equivalently, if and only if $m \ge 2$ and $4m - 7$ is a sum of two perfect squares.

The converse uses a small fact about remainders. Squares leave remainder $0$, $1$ or $4$ when divided by $8$, and only odd squares leave remainder $1$. The number $8m - 14$ leaves remainder $2$ on division by $8$, and the only way to make $2$ from two of those remainders is $1 + 1$. So any way of writing $8m - 14$ as $x^2 + y^2$ must use two **odd** squares. Then $x = 2a+1$ and $y = 2b+1$, and running the identity backwards gives $m = A_a + A_b$.

The second form follows from a fact as old as Diophantus: a number is a sum of two squares exactly when twice the number is, because

$$(u+v)^2 + (u-v)^2 = 2(u^2+v^2).$$

There is even an explicit formula. If $m = A_a + A_b$, then

$$4m - 7 = (a+b+1)^2 + (a-b)^2.$$

For example, $38 = A_0 + A_8 = 1 + 37$, so $4\cdot 38 - 7 = 145 = 9^2 + 8^2$, and indeed $(0+8+1)^2 + (0-8)^2 = 81 + 64$.

## Fermat enters

Which numbers are sums of two squares? Fermat stated the answer in a letter of 1640, and Euler proved it a century later.

> **Fermat's Two-Squares Theorem.** A positive integer is a sum of two squares if and only if every prime of the form $4k+3$ (that is, $3, 7, 11, 19, 23, 31, \dots$) appears in its prime factorisation an **even** number of times.

So $45 = 3^2 \cdot 5$ is a sum of two squares ($6^2 + 3^2$), but $21 = 3 \cdot 7$ is not.

Combining this with the Reduction Theorem gives a test that needs no search at all:

> **Fermat-type Criterion.** An integer $m$ is a sum of two anti-Fibonacci numbers if and only if $m \ge 2$ and every prime $q \equiv 3 \pmod 4$ divides $4m - 7$ an even number of times.

Try it on the missing number $37$: $4 \cdot 37 - 7 = 141 = 3 \cdot 47$. The prime $3$ is of the form $4k+3$ and appears once, an odd number of times, so $37$ is out. Now try $38$: $145 = 5 \cdot 29$, and both primes have the form $4k+1$, so $38$ is in.

The question about an odd quadratic sequence has become a question about the **prime factorisation** of $4m - 7$.

## A first crack: two-ninths of everything is missing

The prime $3$ already removes a fixed fraction of all integers. Suppose $m$ leaves remainder $1$ or $7$ on division by $9$. Then $4m - 7$ leaves remainder $6$ or $3$ on division by $9$. In either case $4m-7$ is divisible by $3$ but not by $9$. The prime $3$ appears exactly once, which is an odd number of times, so $m$ cannot be a sum of two anti-Fibonacci numbers.

> **The Two-Ninths Theorem.** No integer congruent to $1$ or $7$ modulo $9$ is a sum of two anti-Fibonacci numbers. Consequently, among $0, 1, \dots, 9k-1$, at least $2k$ integers are not representable.

That is a guaranteed gap of at least $22\%$, from one prime alone. And $3$ is only the first prime of the form $4k+3$. The prime $7$ removes another slice: if $7$ divides $4m-7$ but $49$ does not, $m$ is excluded. So do $11$, $19$, $23$, and infinitely many more.

## Sieving like Eratosthenes

The Greek sieve of Eratosthenes removes multiples of $2$, then of $3$, then of $5$, and what survives are the primes. We can do the same here, with a local test at each prime $p \equiv 3 \pmod 4$:

> **The local test at $p$.** If $p$ divides $4m - 7$, then $p^2$ must also divide $4m - 7$.

Every representable $m$ passes every such test. How many integers pass the test at a single prime $p$? The test depends only on the remainder of $m$ modulo $p^2$, so it suffices to count over one block of $p^2$ consecutive integers. As $m$ runs through such a block, $4m - 7$ is divisible by $p$ exactly $p$ times and by $p^2$ exactly once. So exactly $p - 1$ values fail and

$$p^2 - p + 1 \quad\text{out of every}\quad p^2$$

pass. For $p = 3$ that is $7$ out of $9$, which matches the Two-Ninths Theorem. For $p = 7$ it is $43$ out of $49$.

Because the tests at different primes involve coprime moduli, the Chinese Remainder Theorem makes them behave independently:

> **Exact Sieve Count.** For any finite set $S$ of primes $\equiv 3 \pmod 4$, the number of residues modulo $Q = \prod_{p \in S} p^2$ that pass every local test is exactly
> $$C = \prod_{p\in S} (p^2 - p + 1).$$

For $S = \{3, 7, 11\}$ this gives $33{,}411$ survivors out of $53{,}361$, or $62.6\%$. Counting full blocks of length $Q$ gives an explicit bound on the number $R(N)$ of representable integers below $N$:

$$R(N) \;\le\; \Bigl(\frac{N}{Q} + 1\Bigr)\cdot C.$$

## Why the sieve eventually removes almost everything

Each prime keeps a fraction $1 - \frac{p-1}{p^2}$ of the integers. That is close to $1$, roughly $1 - \frac{1}{p}$, so each individual prime removes very little. Do the losses add up to everything? A short inequality answers this:

$$\prod_{p \in S}\Bigl(1 - \frac{p-1}{p^2}\Bigr) \;\le\; \frac{1}{1 + \tfrac12 \sum_{p\in S} \tfrac1p}.$$

The proof uses only $1 - x \le \frac{1}{1+x}$, the fact that a product $\prod(1 + x_i)$ is at least $1 + \sum x_i$, and the bound $\frac{p-1}{p^2} \ge \frac{1}{2p}$.

So the whole question reduces to this: **does the sum of $1/p$ over primes $p \equiv 3 \pmod 4$ diverge?** If it does, we can make the right-hand side as small as we like.

It does. This is a version of Dirichlet's celebrated 1837 theorem on primes in arithmetic progressions. Dirichlet showed that each admissible remainder class contains infinitely many primes. The stronger statement needed here is that the reciprocals of those primes have an infinite sum. Our derivation runs through the weighted sum $\sum \log p / p^{x}$, which is known to grow like $\frac{1/\varphi(q)}{x-1}$ as $x$ decreases to $1$. Since $\log p / p^x \le \frac{1}{(x-1)p}$, a finite reciprocal sum would make the weighted sum grow too slowly. That is a contradiction.

Combining these pieces gives the main theorem.

> **Density Zero Theorem.** The proportion of integers in $[0, N)$ that are sums of two anti-Fibonacci numbers tends to $0$ as $N \to \infty$. Equivalently, almost every integer is **not** a sum of two anti-Fibonacci numbers.

The argument is short. Pick a tolerance $\varepsilon$. Choose finitely many primes $\equiv 3 \pmod 4$ whose reciprocals add up to more than $4/\varepsilon$. Then the surviving fraction $C/Q$ is below $\varepsilon/2$. For $N$ large, the extra term $C/N$ is also below $\varepsilon/2$, so $R(N)/N < \varepsilon$.

## The surprise: zero density, but not by much

"Density zero" might suggest the representable numbers are as rare as the perfect squares, which become sparse very fast. They are not. Here are the counts:

| $N$ | representable $m \le N$ | fraction |
|---:|---:|---:|
| $100$ | $65$ | $65.0\%$ |
| $10{,}000$ | $4{,}834$ | $48.3\%$ |
| $1{,}000{,}000$ | $399{,}341$ | $39.9\%$ |
| $4{,}000{,}000$ | $1{,}526{,}291$ | $38.2\%$ |

The fraction does fall, but very slowly. This is typical of sums of two squares. In 1908 Edmund Landau proved that the number of integers up to $x$ that are sums of two squares is about

$$b\,\frac{x}{\sqrt{\log x}}, \qquad b = \frac{1}{\sqrt2}\prod_{p\equiv 3\ (4)}\Bigl(1-\frac1{p^2}\Bigr)^{-1/2} \approx 0.7642.$$

The number $b$ is the **Landau–Ramanujan constant**. Ramanujan found the same law independently and described it in his first letter to Hardy.

Through the Reduction Theorem, the anti-Fibonacci problem inherits Landau's law. Here is how. A number is a sum of two squares exactly when twice it is. So the even sums of two squares up to $x$ correspond one-to-one with all sums of two squares up to $x/2$. Subtracting, the **odd** sums of two squares up to $x$ number about $\frac{b}{2}\cdot\frac{x}{\sqrt{\log x}}$. The map $m \mapsto 4m - 7$ matches representable $m \le N$ one-to-one with odd sums of two squares up to $4N - 7$. (Odd sums of two squares always leave remainder $1$ mod $4$, just like $4m-7$.) Setting $x = 4N$:

$$R(N) \;\sim\; K\,\frac{N}{\sqrt{\log N}}, \qquad K = 2b \approx 1.5284.$$

The test proposed for this law was that the ratio $R(N)\sqrt{\log N}/N$ should settle down rather than drift to $0$ or to infinity. It does:

| $N$ | $R(N)\sqrt{\log N}/N$ |
|---:|---:|
| $10^2$ | $1.395$ |
| $10^4$ | $1.467$ |
| $10^6$ | $1.484$ |
| $4\cdot 10^6$ | $1.488$ |

The ratio rises slowly toward $1.528$. The lag is the familiar lower-order correction of size about $1/\log N$, which also makes Landau's original count converge slowly. So the representable numbers have density zero, but only barely: they thin out only by a factor of $1/\sqrt{\log N}$. Even at $N = 10^{100}$ that factor is only about $1/15$.

## What the sieve can and cannot see

The elementary sieve proves that the density is zero, but it cannot by itself find the correct rate $1/\sqrt{\log N}$. The trouble is that the modulus $Q = \prod p^2$ grows so fast that, for realistic $N$, only a few primes can be used before the "$+1$" term in the bound swamps everything. With $N = 10^6$, the sieve over $\{3, 7, 11\}$ gives the bound $634{,}809$, against a true count of $399{,}341$. Adding $19$ to the set makes the bound *worse*, $11{,}459{,}973$, because $Q$ has passed $N$. Getting to $1/\sqrt{\log N}$ requires the heavier tools of analytic number theory: Selberg's upper-bound sieve, Mertens' product formula for primes in progressions, and ultimately the Selberg–Delange method behind Landau's theorem.

## Why it matters

Three things make this small problem worth telling.

First, it shows how a question can change shape. A question about a quadratic sequence became a question about sums of squares, then a question about prime factorisations, and finally a question about the distribution of primes in arithmetic progressions. Each step is elementary. The chain links a pancake-cutting sequence to Fermat, Dirichlet, Landau and Ramanujan.

Second, it corrects a natural guess. Numerically the representable numbers look like they have positive density, since nearly $40\%$ of integers up to a million are representable. The truth is that the density is zero, and the correct scale is $N/\sqrt{\log N}$, with constant twice the Landau–Ramanujan constant.

Third, it gives the problem a concrete shape. There is an explicit test for each $m$ (factor $4m-7$), an exact count of survivors for every finite sieve, and an explicit, elementary inequality that turns divergence of $\sum 1/p$ into vanishing density. Each piece can be checked by hand, and together they show that the proportion of anti-Fibonacci sums tends to zero.

The anti-Fibonacci numbers add the wrong thing, yet their pairwise sums turn out to be governed by Fermat's two-squares theorem and Landau's counting law.
