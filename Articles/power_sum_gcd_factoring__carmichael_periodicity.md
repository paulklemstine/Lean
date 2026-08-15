# The Number That Counts Itself: How a Single Sum Betrays a Secret Factor

## A very old question, asked a very new way

Take a number. Say $35$. You know instantly that it is $5 \times 7$. Now take
$8633$. A little slower, but you get there: $89 \times 97$. Now take a number
with six hundred digits, formed by multiplying two three-hundred-digit primes
that nobody has written down. Suddenly there is no "a little slower." There is
only silence. The security of a great deal of the world's digital
infrastructure rests on exactly that silence.

The usual way to attack the problem is to *probe*. You pick a number $a$, raise
it to some enormous power modulo $N$, and see whether the result accidentally
collides with something that betrays a factor. Pollard's classic $p-1$ method
works this way: pick a base $a$, compute $\gcd(a^M - 1, N)$, and hope. The
"hope" is doing real work in that sentence. A bad base tells you nothing, and
you must try again.

This article is about a different kind of probe — one with no base to choose at
all. Instead of interrogating one residue, we interrogate *all of them at
once*, by adding them up.

Define, for a modulus $N$ and an exponent $k$, the **power sum**

$$F(k) \;=\; \sum_{a=1}^{N} a^{k}.$$

That is: take every number from $1$ to $N$, raise each to the $k$-th power, and
add. Then compute $\gcd(F(k), N)$.

What comes out is not noise. It is a clean, completely predictable signal whose
rhythm encodes the factorization of $N$.

## The signal

Let us look at $N = 35$. Compute $\gcd(F(k), 35)$ for $k = 1, 2, 3, \dots$ and
you get:

$$35,\ 35,\ 35,\ \mathbf{7},\ 35,\ \mathbf{5},\ 35,\ \mathbf{7},\ 35,\ 35,\ 35,\ \mathbf{1},\ 35,\ 35, \dots$$

Look at position $4$. The answer is $7$ — a genuine, nontrivial factor of $35$,
handed over without ceremony. Look at position $6$: the other factor, $5$. And
look at position $12$: the value collapses to $1$, and then the whole pattern
repeats from the beginning, forever, with period exactly $12$.

Now notice: $35 = 5 \times 7$, and $4 = 5 - 1$, and $6 = 7 - 1$, and
$12 = \operatorname{lcm}(4, 6)$. Every landmark of the sequence is a shadow of
the factorization.

Here is $N = 15 = 3 \times 5$:

$$15,\ \mathbf{5},\ 15,\ \mathbf{1},\ 15,\ \mathbf{5},\ 15,\ \mathbf{1}, \dots$$

Same story: the factor $5$ appears at $k = 2 = 3-1$, and the period is
$\operatorname{lcm}(2, 4) = 4$.

This is not a coincidence, and it is not a heuristic. It is a theorem, and the
theorem gives the value of $\gcd(F(k), N)$ for *every* $k$ with no exceptions.

## The master formula

**Theorem (the value table).** Let $N = pq$ where $p$ and $q$ are distinct
primes, and let $k \ge 1$. Then

$$\gcd\!\big(F(k),\, N\big) \;=\; \Big(\text{$1$ if $(p-1) \mid k$, else $p$}\Big)\;\times\;\Big(\text{$1$ if $(q-1) \mid k$, else $q$}\Big).$$

Read that carefully, because it says something startling: the gcd depends on
the exponent $k$ **only through two yes/no questions** — does $p-1$ divide $k$,
and does $q-1$ divide $k$? Four possible answers, four possible values of the
gcd: $N$, $p$, $q$, or $1$. Nothing else can ever happen.

The four cases:

- Neither divides $k$: the gcd is $N$ itself. Useless — the sum is divisible by
  everything.
- Exactly one divides $k$: the gcd is the *other* prime. **A factor falls out.**
- Both divide $k$: the gcd is $1$. Also useless — but, as we will see, this is
  where the deepest information hides.

## Why it is true: residues in ranks, then Fermat

The proof is two moves, and both are the kind of thing you can see in your head.

**Move one: the residues march in formation.** The numbers $1, 2, \dots, N$
with $N = pq$ hit every residue class modulo $p$ exactly $q$ times. So when we
reduce $F(k)$ modulo $p$, the sum collapses:

$$F(k) \;\equiv\; q \cdot \sum_{x \bmod p} x^{k} \pmod p.$$

All the arithmetic complexity of the interval $[1, N]$ evaporates; what is left
is a single sum over the residues mod $p$, weighted by how many times the
interval wraps around.

**Move two: Fermat's little theorem decides the inner sum.** For a prime $p$
and any $k \ge 1$,

$$\sum_{x \bmod p} x^{k} \;=\; \begin{cases} -1 & \text{if } (p-1) \mid k,\\[2pt] 0 & \text{otherwise.}\end{cases}$$

The reason is beautifully simple. The nonzero residues form a cyclic group of
order $p-1$. If $(p-1) \mid k$, then $x^k = 1$ for every one of them, so the sum
is $p - 1 \equiv -1$. If not, pick a generator $g$; multiplying the whole sum by
$g^k \neq 1$ permutes the terms and so leaves the sum unchanged, which forces
the sum to be $0$.

Put the moves together. Since $p \nmid q$, we get $p \mid F(k)$ exactly when
$(p-1) \nmid k$. Symmetrically for $q$. And $\gcd$ splits across the coprime
factors $p$ and $q$. That is the master formula, complete.

Specialising to $k = p-1$ gives the headline: **one gcd computation at exponent
$p-1$ returns the factor $q$**, provided $(q-1) \nmid (p-1)$. And when $p < q$
that side condition is *automatic* — a number bigger than $p-1$ cannot divide
$p-1$ — so for $p < q$ the reveal is unconditional:

$$\gcd\Big(\textstyle\sum_{a=1}^{N} a^{\,p-1},\; N\Big) \;=\; q \qquad (p < q).$$

## No bad bases, ever

Pollard's $p-1$ method can be defeated by an unlucky base. Can the power sum?

It cannot, and the contrast is sharp enough to state as a theorem. Consider the
base $a = N - 1$. It is a perfectly respectable base: it satisfies
$1 < N-1 < N$, and it is coprime to $N$. But $N - 1 \equiv -1$ modulo every
prime factor of $N$, so $(N-1)^M - 1$ is congruent to $0$ modulo *every* factor
when $M$ is even, and to $-2$ modulo every odd prime factor when $M$ is odd.
Therefore:

**Theorem (a universally bad base).** For $N = pq$ with $p \ne q$ distinct odd
primes, and *every* exponent $M$,

$$\gcd\big((N-1)^M - 1,\ N\big) = \begin{cases} N & M \text{ even},\\ 1 & M \text{ odd}.\end{cases}$$

It is never a proper factor. Not for one exponent. Not for any exponent. This
base is a dead end forever.

Now take $N = 35$ and the exponent $M = 4$. Pollard with base $6 = N-1$ returns
$35$: total failure. The power sum at the same exponent returns $7$: total
success. The power sum cannot have a bad base for the simple reason that it has
no base — it averages over all of them simultaneously, and the averaging is
exactly what Fermat's theorem knows how to evaluate.

## The rhythm: Carmichael periodicity

Return to the sequence $k \mapsto \gcd(F(k), N)$. Because the master formula
depends only on the divisibility of $k$ by $p-1$ and by $q-1$, the sequence is
*periodic*, and its period is the least common multiple

$$\lambda(N) \;=\; \operatorname{lcm}(p-1,\, q-1),$$

the **Carmichael function** of $N$: the exponent of the group of units modulo
$N$.

More than that, the period is *exactly* $\lambda(N)$ — nothing smaller works —
and there is a clean way to see it in the data:

**Theorem (periodicity and its sharpness).** For $k \ge 1$,
$\gcd(F(k+\lambda(N)), N) = \gcd(F(k), N)$; and
$$\gcd(F(k), N) = 1 \iff \lambda(N) \mid k.$$
Consequently $\lambda(N)$ is the *least* positive $k$ at which the sequence
takes the value $1$, and no positive integer smaller than $\lambda(N)$ is a
period of the sequence.

So $\lambda(N)$ is not merely a period; it is legible. Read down the sequence
until you see your first $1$, and the position where it occurs *is* the
Carmichael number of $N$. For $N=35$ the first $1$ appears at $k=12$, and
indeed $\lambda(35)=\operatorname{lcm}(4,6)=12$.

## A tempting formula, and why it is wrong

Suppose you have read off $\lambda(N)$. Do you now know the factorization?

The tempting move is: "$\lambda(N)$ is essentially the totient, and
$\varphi(N) = (p-1)(q-1) = N - (p+q) + 1$, so $p + q = N - \lambda(N) + 1$, and
knowing the sum and product of $p$ and $q$ we recover them by solving a
quadratic." Clean, quick, and false.

The error is the word "essentially." The Carmichael function is the *least
common multiple* of $p-1$ and $q-1$; the totient is their *product*. They agree
only when $p-1$ and $q-1$ are coprime.

**Counterexample.** Take $p = 5$, $q = 13$, so $N = 65$. Then
$\lambda(65) = \operatorname{lcm}(4, 12) = 12$, and the tempting formula
predicts $p + q = 65 - 12 + 1 = 54$. The truth is $p+q = 18$. The formula is off
by a factor that is not small.

Where did it go? Into the greatest common divisor. Since
$\gcd(m,n)\cdot\operatorname{lcm}(m,n) = mn$ always, the honest identity is:

**Theorem (corrected recovery identity).** For all integers $p, q \ge 1$, with
$\lambda = \operatorname{lcm}(p-1, q-1)$,

$$\gcd(p-1,\,q-1)\;\cdot\;\lambda \;+\; (p+q) \;=\; pq \;+\; 1.$$

Check it on the counterexample: $\gcd(4,12) = 4$, and $4 \cdot 12 + 18 = 66 = 65 + 1$. ✓

The naive formula is the special case $\gcd(p-1, q-1) = 1$ — and under exactly
that guard, recovery does work:

**Theorem (recovery under the coprimality guard).** Let $N = pq$ with $p < q$
distinct primes and $\gcd(p-1, q-1) = 1$. If $(a, b)$ is any ordered pair of
non-negative integers with $a \le b$, $ab = N$, and
$a + b = N + 1 - \lambda(N)$, then $a = p$ and $b = q$.

The uniqueness is Vieta's: two numbers are determined by their sum and product
once you fix which is which. So under the guard, the *period alone* determines
the factorization.

That is the arc: the sequence's values leak factors directly, and the
sequence's *period* leaks the factorization wholesale. This is not an
approximation or a heuristic. It is an exact structural statement about a
completely explicit sequence of integers.

## So why is $N$ still safe?

Here is the honest accounting, and it is the most interesting part of the story.

The first exponent at which anything interesting happens is
$k^* = \min(p-1, q-1)$. It is a theorem that this is *exactly* the least $k \ge 1$
at which the gcd departs from the trivial value $N$, and that at that exponent
the gcd is already a proper factor. It is also a theorem that
$(k^*+1)^2 \le N$, i.e. $k^* < \sqrt{N}$. So the first hit occurs below the
square root of $N$ — and no sooner, in general.

Meanwhile, computing $F(k)$ from its definition costs $O(N)$ modular
operations. Total work to reach the first hit: $O(N^{3/2})$. Trial division
finds the factor in $O(\sqrt{N})$. The power-sum method is, as an algorithm on
a classical computer, *worse than the most naive method there is*.

And the periodicity does not rescue it. Inside one period $\lambda$, the number
of exponents that reveal a proper factor is exactly

$$\frac{\lambda}{p-1} + \frac{\lambda}{q-1} - 2,$$

a $\big(\tfrac{1}{p-1} + \tfrac{1}{q-1}\big)$-fraction of the period. For
cryptographic sizes, that fraction is astronomically tiny. Blind search is
hopeless; you must *know where to look*, and knowing where to look means
knowing $p-1$ or $q-1$, which means knowing the answer.

This is worth dwelling on, because it is exactly the shape of the modern
theory of factoring. The information is *there*, sitting in plain sight in an
explicitly defined integer sequence, perfectly structured, perfectly periodic.
The obstruction is not secrecy. The obstruction is that finding the period of a
sequence you can only sample point by point is expensive — and each sample is
itself expensive.

That is precisely the wall a quantum computer walks through. Shor's algorithm
is, at heart, a period-finding machine: it extracts the period of a
modular-exponential sequence in polynomial time using the quantum Fourier
transform. The power-sum sequence is a different sequence with the same
signature — an explicit function of $k$ whose period is the Carmichael number
and whose period therefore yields the factorization. The mathematics here makes
the classical/quantum boundary unusually vivid: same structure, same
period-encodes-the-secret phenomenon, and the entire difficulty concentrated in
one operation.

## Beyond semiprimes

The story does not stop at $N = pq$. Nothing in the argument used the number of
prime factors:

**Theorem (squarefree case).** Let $N$ be squarefree, $p$ a prime factor, and
$k \ge 1$. Then $p \mid F(k)$ if and only if $(p-1) \nmid k$. Consequently
$\gcd(F(k), N) = 1$ exactly when $\lambda(N) \mid k$, where now
$\lambda(N) = \operatorname{lcm}_{p \mid N}(p-1)$.

This produces an unexpected connection to a classical object. A **Carmichael
number** is a composite $N$ that fools the Fermat primality test: $a^{N-1}
\equiv a \pmod N$ for all $a$. Korselt's criterion says a squarefree $N$ is
Carmichael exactly when $(p-1) \mid (N-1)$ for every prime $p \mid N$. That
condition is *precisely* the condition $\lambda(N) \mid N - 1$. So:

**Theorem (Korselt bridge).** A squarefree $N \ge 2$ satisfies Korselt's
criterion if and only if $\gcd(F(N-1), N) = 1$.

In words: **Carmichael numbers are exactly the squarefree moduli on which the
power-sum reveal, at the one exponent you would naturally try, tells you
absolutely nothing.** The smallest, $561 = 3 \cdot 11 \cdot 17$, has
$\lambda = \operatorname{lcm}(2, 10, 16) = 80$, which divides $560$; and indeed
$\gcd(F(560), 561) = 1$. Carmichael numbers are the blind spot of this method
for exactly the reason they are the blind spot of the Fermat test — the same
divisibility condition, seen from a new angle.

## When squares creep in

What if $N$ is not squarefree? Here a genuine surprise appears, and it is worth
telling because the *obvious* guess is wrong.

You would expect the relevant exponent condition at a prime power $p^e$ to
involve $\lambda(p^e) = p^{e-1}(p-1)$, the exponent of the unit group. It does
not. Consider $p^e = 9$: the sum $\sum_{a<9} a^k$ is $\equiv -3 \pmod 9$ for
*every even* $k$, not just for $k$ divisible by $\lambda(9) = 6$. The $p$-part
of the unit group is invisible to the power sum.

**Theorem (prime-power evaluation).** Let $p$ be an odd prime, $e \ge 1$,
$k \ge 1$. Then

$$\sum_{a < p^{e}} a^{k} \;\equiv\; \begin{cases} -p^{\,e-1} \pmod{p^{e}} & \text{if } (p-1) \mid k,\\[2pt] 0 \pmod{p^{e}} & \text{otherwise.}\end{cases}$$

Consequently, if $N = p^e m$ with $p \nmid m$, then

$$\gcd\big(F(k),\, p^{e}\big) = \begin{cases} p^{\,e-1} & \text{if } (p-1) \mid k,\\ p^{e} & \text{otherwise.}\end{cases}$$

So a prime power dividing $N$ is revealed *in full* unless $(p-1) \mid k$, in
which case exactly one power of $p$ is lost — never more.

The proof turns on a lift-the-exponent trick. Write each $a < p^e$ as
$a = p^{e-1} j + r$ with $r < p^{e-1}$ and $j < p$. Expanding
$(r + p^{e-1}j)^k$ binomially, every term with $(p^{e-1})^2$ dies modulo $p^e$,
so only the constant and linear terms survive. Summing the linear terms over
$j$ produces the Gauss sum $\sum_{j<p} j = p(p-1)/2$, which is divisible by $p$
— and this is the one and only place oddness of $p$ is used. What remains is
the clean recursion $\sum_{a<p^e} a^k \equiv p \sum_{a<p^{e-1}} a^k \pmod{p^e}$,
which unwinds to the stated formula by induction with the Fermat evaluation as
the base case.

The prime $2$ genuinely is exceptional. For $N = 8$, and $k \ge 2$, the gcd is $4$ when $k$ is even and $8$ when $k$ is
odd; pinning down the $2$-part of the answer in general remains open.

## What to take away

We started with an algorithm and ended with a structure theorem. The
computation $\gcd\big(\sum_{a=1}^{N} a^k,\, N\big)$ is not a heuristic that
sometimes works; it is a function of $k$ whose value is known in closed form,
whose zeros and ones are dictated by Fermat's little theorem, whose period is
the Carmichael function, and whose blind spots are precisely the Carmichael
numbers. It repairs a false folklore recovery formula along the way and shows
what the correct one is.

As a factoring algorithm it loses to trial division. As a lens, it is
excellent. It shows the secret is not hidden — it is written down, in order, in
an integer sequence anyone can define in one line. It is just written in a
rhythm too slow to hear.

That gap between *encoded* and *accessible* is the whole subject.
