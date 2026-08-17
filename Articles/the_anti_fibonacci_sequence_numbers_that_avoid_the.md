# The Anti-Fibonacci Sequence: Numbers That Refuse the Golden Ratio

## A sequence that forgets

Everyone knows the Fibonacci numbers. Start with $1, 1$ and let every term be the sum of the two before it:

$$1,\; 1,\; 2,\; 3,\; 5,\; 8,\; 13,\; 21,\; 34,\; \ldots$$

The Fibonacci sequence has a memory. To make the next number, it reaches back two steps and adds. That backward reach is what makes it explode: each term is roughly $1.618\ldots$ times the last, and the ratio $F_{n+1}/F_n$ converges to the golden ratio
$$\varphi = \frac{1+\sqrt{5}}{2}.$$
The golden ratio is the fingerprint of self-reference. Wherever a quantity is built by adding its own recent past, $\varphi$ shows up.

Now cripple that memory. Keep the *shape* of the recurrence — "add something to the previous term" — but let the sequence forget the value it is supposed to add, and remember only *how many steps it has taken*. Define

$$a_0 = 1, \qquad a_{n+1} = a_n + n.$$

This is the **anti-Fibonacci sequence**. It begins

$$1,\; 1,\; 2,\; 4,\; 7,\; 11,\; 16,\; 22,\; 29,\; 37,\; 46,\; 56,\; \ldots$$

At first glance it looks like a shy cousin of Fibonacci: same start, same "add and move on" rhythm, but the increments are $0, 1, 2, 3, 4, 5, \ldots$ instead of previous terms. And the result is a completely different animal. Summing $0 + 1 + \cdots + (n-1)$ gives the exact formula

$$\boxed{\,a_n = \frac{n(n-1)}{2} + 1\,}$$

or, in the subtraction-free form that will turn out to be the master key,

$$2a_n + n = n^2 + 2.$$

So the anti-Fibonacci numbers grow **quadratically**, like $n^2/2$, not exponentially. The consecutive ratio $a_{n+1}/a_n = 1 + n/a_n$ tends to $1$. The golden ratio never appears — not in the limit, not asymptotically, not anywhere. Forgetting kills $\varphi$.

You have almost certainly met these numbers before without knowing it. Draw $n-1$ straight lines across a pizza, in general position so that no two are parallel and no three meet at a point. The number of pieces you get is exactly $a_n$. One line makes $2$ pieces, two lines make $4$, three lines make $7$, four lines make $11$. This is the classic "lazy caterer" count. The anti-Fibonacci sequence is the sequence of *maximal regions cut from the plane by lines* — a purely geometric object that has wandered into number theory.

And once it is in number theory, something remarkable happens. The tame quadratic sequence turns out to be a machine for generating hard classical problems, and each one of them can be solved exactly.

## The master identity

Multiply the closed form by $8$ and complete the square:

$$8a_n = 4n^2 - 4n + 8 = (2n-1)^2 + 7.$$

Every anti-Fibonacci number, scaled by $8$, is an **odd square plus seven**. That single line is the hinge on which everything below turns. Questions about the anti-Fibonacci sequence — is a term a square? do three terms form an arithmetic progression? which primes divide some term? — become questions about the binary quadratic form $x^2 + 7$, one of the most beautiful objects in classical number theory. The discriminant $-7$ belongs to the imaginary quadratic field $\mathbb{Q}(\sqrt{-7})$, one of the nine fields of class number one, which is why the answers come out clean rather than approximate.

Here is what the identity buys.

## How many anti-Fibonacci numbers are there, really?

Let $C(N)$ count the indices $k$ with $a_k \le N$. Because the sequence is (weakly) increasing, this index set is an unbroken initial segment $\{0, 1, \ldots, Q-1\}$, and the master identity pins down $Q$ exactly:
$$a_k \le N \iff (2k-1)^2 \le 8N - 7.$$
Solving for $k$ gives a **constant-time counting formula**:

> **Counting Theorem.** For every $N \ge 1$,
> $$C(N) = \left\lfloor \frac{\lfloor \sqrt{8N-7} \rfloor + 1}{2} \right\rfloor + 1.$$

No scan, no loop: one integer square root. Compare with the naive method, which must test every $k$ up to $N$. And the formula immediately yields sharp two-sided integer inequalities,
$$2N + C(N) \le C(N)^2 + 1 \qquad\text{and}\qquad C(N)^2 + 4 \le 2N + 3\,C(N),$$
the second of which is an equality precisely when $N$ is itself a term of the sequence ($N = 1, 2, 4, 7, 11, 16, \ldots$). Squeezing these gives
$$\sqrt{2N} \;\le\; C(N) \;\le\; \sqrt{2N} + 3,$$
hence the asymptotics
$$C(N) \sim \sqrt{2N}, \qquad \frac{C(N)}{N} \longrightarrow 0.$$

That last limit is the precise sense in which the anti-Fibonacci numbers are **rare**: they have natural density zero. Below one million there are just $1415$ of them, against a prediction of $\sqrt{2\cdot 10^6} = 1414.21\ldots$. Below ten thousand there are $142$, against $141.42\ldots$. The error never leaves the interval $[0,3]$ guaranteed by the theorem; empirically it hovers between $1/2$ and $3/2$.

The same identity gives an $O(1)$ **membership test**: a positive integer $m$ is an anti-Fibonacci number if and only if $8m - 7$ is a perfect square. Try $m = 46$: $8 \cdot 46 - 7 = 361 = 19^2$. Yes. Try $m = 47$: $369$ is not a square. No. That is the whole algorithm.

## Squares hiding in the sequence

The Fibonacci sequence contains exactly three perfect squares: $0$, $1$, and $144$. That is a hard theorem, proved only in 1964. What about the anti-Fibonacci sequence?

Asking for $a_n = y^2$ means, by the master identity, $(2n-1)^2 + 7 = 8y^2$. Writing $x = 2n-1$, we must solve the **Pell-type equation**
$$x^2 + 7 = 8y^2$$
in positive integers. This equation has two "seed" solutions, $(x,y) = (1,1)$ and $(5,2)$, and the fundamental unit $3 + \sqrt{8}$ of the ring $\mathbb{Z}[\sqrt{8}]$ acts on solutions by
$$(x, y) \longmapsto (3x + 8y,\; x + 3y).$$
A descent argument — bounding any solution with $y \ge 3$ by $2y < x < 3y$ and $8y \le 3x$, then running the automorphism backwards to a strictly smaller solution — shows that *every* solution arises this way.

> **Square Classification Theorem.** For $n \ge 1$, the anti-Fibonacci number $a_n$ is a perfect square if and only if $(2n-1, y)$ lies in the orbit of $(1,1)$ or $(5,2)$ under $(x,y) \mapsto (3x+8y, x+3y)$. In particular the sequence contains **infinitely many** perfect squares.

The squares are
$$a_1 = 1,\quad a_3 = 4,\quad a_6 = 16,\quad a_{16} = 121,\quad a_{33} = 529,\quad a_{91} = 4096,\quad a_{190} = 17956,\ \ldots$$
that is $1^2, 2^2, 4^2, 11^2, 23^2, 64^2, 134^2, \ldots$, thinning out geometrically but never stopping. Where Fibonacci allows three squares, the anti-Fibonacci sequence allows infinitely many — and, unlike Fibonacci's, they can all be listed by a two-line recursion.

## Three terms in a row: Pythagoras appears

When do three anti-Fibonacci numbers form an arithmetic progression, $a_a + a_c = 2a_b$? Substituting the master identity and cancelling the sevens gives
$$(2a-1)^2 + (2c-1)^2 = 2(2b-1)^2,$$
and the standard rotation $u^2 + v^2 = 2w^2 \iff \left(\frac{u+v}{2}\right)^2 + \left(\frac{v-u}{2}\right)^2 = w^2$ converts this into a Pythagorean equation.

> **Progression–Triple Correspondence.** For all indices $a, b, c$,
> $$a_a + a_c = 2\,a_b \iff (a + c - 1)^2 + (c - a)^2 = (2b-1)^2.$$
> Three-term progressions in the anti-Fibonacci sequence are **exactly** Pythagorean triples with odd hypotenuse.

Since there are infinitely many such triples, there are infinitely many progressions, and they can be written down. The triple $(2k+1,\; 2k^2+2k,\; 2k^2+2k+1)$ — the family that contains $(3,4,5)$, $(5,12,13)$, $(7,24,25)$ — translates into the elegant identity

$$a_{k^2} + a_{(k+1)^2} = 2\, a_{k^2+k+1} \qquad \text{for every } k,$$

with the three indices genuinely increasing, $k^2 < k^2+k+1 < (k+1)^2$. Even the common difference has a name: it equals
$$3\left(1^2 + 2^2 + \cdots + k^2\right),$$
three times a square-pyramidal number — the number of cannonballs in a square pyramid $k$ layers deep. For $k = 1$ we get $a_1 = 1$, $a_3 = 4$, $a_4 = 7$: the progression $1, 4, 7$ with difference $3$, born from the $(3,4,5)$ triangle.

The contrast with Fibonacci could not be sharper. In the Fibonacci sequence, arithmetic progressions are essentially forbidden: for $3 \le a < b < c$, the equation $F_a + F_c = 2F_b$ forces $c = b+1$ and $a = b-2$ — a single rigid pattern, coming from $F_{b-2} + F_{b+1} = 2F_b$, and nothing else. Exponential growth leaves no room for arithmetic. Quadratic growth is roomy, and the room is precisely the shape of a right triangle.

## Which numbers are sums of anti-Fibonacci numbers?

Add two terms, $a_a + a_b = m$. Multiply by $8$: the master identity turns this into
$$8m - 14 = x^2 + y^2$$
for odd $x, y$ — and it turns out the oddness is automatic. So:

> **Two-Summand Criterion.** For $m \ge 2$, $m$ is the sum of two anti-Fibonacci numbers if and only if $8m - 14$ is a sum of two squares — equivalently (by Fermat's two-squares theorem) if and only if every prime $q \equiv 3 \pmod 4$ divides $8m-14$ to an even power.

This makes the *non*-representable numbers computable too. If $m \equiv 1$ or $7 \pmod 9$, then $8m - 14$ is divisible by $3$ but not by $9$; a sum of two squares divisible by $3$ must have both squares divisible by $3$, hence be divisible by $9$. Contradiction. So two residue classes in nine are permanently locked out:

> No integer congruent to $1$ or $7$ modulo $9$ is a sum of two anti-Fibonacci numbers.

Among the first $9K+10$ integers, at least $2K$ are non-representable: the exceptional set has density at least $2/9$. Two summands are genuinely not enough.

Four summands are. Here the argument runs through Lagrange's four-square theorem, in the sharpened form that **every integer of the shape $8k+4$ is a sum of four odd squares**. Given $m \ge 4$, write $m = k + 4$ and apply this to $8k + 4 = 8m - 28$; pulling each of the four odd squares back through $8a_{p+1} = (2p+1)^2 + 7$ yields four indices whose terms sum to $m$.

> **Additive Basis Theorem.** An integer $m$ is a sum of four anti-Fibonacci numbers if and only if $m \ge 4$. The anti-Fibonacci sequence is an additive basis of order $4$, and the order cannot be lowered to $2$.

Three summands sit exactly on the boundary of what classical theory decides: $m \ge 3$ is a sum of three anti-Fibonacci numbers if and only if $8m - 21$ is a sum of three squares, which by Gauss' three-squares theorem means $8m-21$ is not of the form $4^s(8t+7)$. So the order is $3$ for all but a thin, explicitly described set.

## Which primes ever divide a term?

Every prime divides some Fibonacci number — that is a classical fact, and it makes the Fibonacci sequence *universal* for divisibility. The anti-Fibonacci sequence is not universal, and one can say exactly how it fails. A prime $p$ divides some $a_n$ precisely when $(2n-1)^2 \equiv -7 \pmod{p}$ is solvable, i.e. when $-7$ is a quadratic residue mod $p$. Quadratic reciprocity for the discriminant $-7$ then gives a crisp congruence answer.

> **Prime Divisor Law.** For a prime $p$, some anti-Fibonacci number is divisible by $p$ if and only if
> $$p = 7 \quad\text{or}\quad p \equiv 1, 2, 4 \pmod 7.$$

The list of "good" primes starts $2, 7, 11, 23, 29, 37, 43, 53, \ldots$; the "bad" primes — those that never divide any term — start $3, 5, 13, 17, 19, 31, 41, \ldots$, namely $p \equiv 3, 5, 6 \pmod 7$. Both lists are infinite, by Dirichlet's theorem on primes in arithmetic progressions. The set $\{1,2,4\}$ is exactly the set of nonzero squares modulo $7$, and its appearance here is no coincidence: it *is* the splitting law for the field $\mathbb{Q}(\sqrt{-7})$.

A refinement counts residues rather than zeros. Modulo an odd prime $p$, the residue $m$ is attained by some $a_n$ if and only if $8m - 7$ is a square in $\mathbb{Z}/p$. Since a field with $p$ elements has exactly $(p+1)/2$ squares (the squaring map is two-to-one away from zero), and $m \mapsto 8m-7$ is a bijection:

> **Residue Spectrum Theorem.** Modulo an odd prime $p$, the anti-Fibonacci sequence attains exactly $(p+1)/2$ of the $p$ residue classes. In particular, at least one class is *never* attained.

Just over half of all residues, always — never all of them. Modulo $13$, for example, the sequence hits only $\{1,2,3,4,7,9,11\}$, seven classes out of thirteen, and $0, 5, 6, 8, 10, 12$ are unreachable forever.

## Two more fingerprints

**The period.** Reduce the Fibonacci sequence modulo $m$ and it repeats with the celebrated Pisano period, an erratic function of $m$ with no closed formula. Reduce the anti-Fibonacci sequence modulo $m$ and the answer is embarrassingly simple. A positive integer $p$ is a period if and only if two conditions hold: $m \mid p$, and $a_p \equiv 1 \pmod m$. (Infinitely many congruences collapse to two, because the difference $a_{n+p} - a_n = np + (a_p - 1)$ is *linear* in $n$.) Chasing the parity gives:

> **Minimal Period Theorem.** For $m > 0$, the minimal period of the anti-Fibonacci sequence modulo $m$ is
> $$\pi(m) = \begin{cases} m, & m \text{ odd},\\ 2m, & m \text{ even}.\end{cases}$$

For even $m$, the period $m$ itself fails for a single, identifiable parity reason. This $\pi$ is multiplicative on coprime arguments, just like the Pisano period — and coprimality cannot be dropped, since $\pi(4) = 8 \ne 4 = \pi(2)\pi(2)$.

**The gcd.** Consecutive Fibonacci numbers are always coprime. Consecutive anti-Fibonacci numbers are *almost* always coprime, and the failure is perfectly periodic. Since $a_{n+1} = a_n + n$, any common divisor of $a_n$ and $a_{n+1}$ divides $n$, and then divides $2a_n + n - n^2 = 2$. So the gcd is $1$ or $2$, and a short parity computation using $a_{4k+2} = 8k^2 + 6k + 2$ decides which:

> **Consecutive GCD Law.** $\gcd(a_n, a_{n+1}) = 2$ if $n \equiv 2 \pmod 4$, and $= 1$ otherwise.

Read off the gcds for $n = 0, 1, 2, \ldots$: $1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, \ldots$ — a metronome of period four. The first failure is $\gcd(a_2, a_3) = \gcd(2,4) = 2$, whereas the corresponding Fibonacci pair $(1,2)$ is coprime.

## Why this matters

There is a temptation to see the anti-Fibonacci sequence as a joke: the lazy caterer's numbers, dressed up. But the structure it reveals is real, and it is a lesson about where difficulty lives in mathematics.

The Fibonacci sequence is *analytically* rich and *arithmetically* opaque. Its growth constant is the golden ratio, its identities are gorgeous, and yet the simplest arithmetic questions about it — which terms are squares? which are primes? — are either deep theorems or open problems. The anti-Fibonacci sequence is the mirror image. Analytically it is trivial: a parabola. Arithmetically it is *exactly as rich as the quadratic form $x^2 + 7$*, which means every question about it is a classical question in disguise, and classical answers apply verbatim. Squares become Pell's equation. Progressions become Pythagorean triples. Sums of two terms become Fermat's two-squares theorem. Sums of four terms become Lagrange. Divisibility becomes quadratic reciprocity. Nine centuries of number theory, all keyed to one identity:
$$8a_n = (2n-1)^2 + 7.$$

That is the real payoff of taking a famous recurrence and breaking it in the gentlest possible way. Fibonacci's memory produced the golden ratio and a fortress of unsolved problems. Forgetting produced a parabola — and a parabola, it turns out, is a doorway to everything.

Between exponential growth and quadratic growth there is no smooth interpolation; there is a phase transition. On one side, self-reference, irrational limits, and rigidity: Fibonacci has essentially one arithmetic progression, no square beyond $144$, and no prime it misses. On the other side, forgetfulness, rational asymptotics, and abundance: the anti-Fibonacci sequence has infinitely many progressions, infinitely many squares, and infinitely many primes it never touches. Which is the more interesting sequence? The honest answer is that they are interesting for opposite reasons — and that is worth knowing.
