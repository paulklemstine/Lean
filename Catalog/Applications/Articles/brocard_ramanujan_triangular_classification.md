# The Factorials That Almost Became Squares

## A number that refuses to be a perfect square

Start multiplying. $1$, then $1 \times 2 = 2$, then $2 \times 3 = 6$, then $6 \times 4 = 24$, then $24 \times 5 = 120$. These are the **factorials**, written $n!$ — the product of every whole number from $1$ up to $n$. They are the engine room of counting: $n!$ is exactly the number of ways to shuffle a deck of $n$ distinct cards. By the time you reach $13!$ you have passed six billion, and the numbers keep galloping off toward infinity.

Now ask a deceptively simple question. Among all these factorials, how many are **perfect squares** — numbers like $1, 4, 9, 16, 25, 36$ that are some whole number multiplied by itself?

The first two factorials cheat their way in. We define $0! = 1$ (the empty product), and $1! = 1$, and $1 = 1^2$ is a square. After that, the door slams shut. $2! = 2$ is not a square. $6$, $24$, $120$, $720$ — none of them. And it is not a coincidence, nor a stroke of luck that runs out at some huge value you'd need a supercomputer to find. The result is total and forever:

> **The factorial $n!$ is a perfect square if and only if $n \le 1$.**

That single, clean sentence is the heart of this story. It is the kind of statement that sounds like it might require a deep and delicate argument, or worse, an infinite amount of checking. In fact it follows from one of the most charming ideas in number theory — a theorem with a bet attached to its name.

## Bertrand's bet

In 1845 the French mathematician Joseph Bertrand made a conjecture and checked it by hand up to three million: between any whole number and its double, there is always a prime. More precisely, for every $n \ge 1$ there exists a prime $p$ with $n < p \le 2n$. Pafnuty Chebyshev proved it a few years later, and it has been called **Bertrand's postulate** ever since, though "postulate" undersells it — it is a theorem.

It is easy to state and easy to test: between $10$ and $20$ sits the prime $11$ (and $13$, $17$, $19$). Between $100$ and $200$ there are plenty. The primes, scattered though they seem, never leave a gap as wide as a doubling.

We will use a mirror-image version of the same fact. For any $n \ge 2$ there is always a prime $p$ sitting in the *upper half* of the range up to $n$:
$$\frac{n}{2} < p \le n.$$
For $n = 10$ that prime could be $7$; for $n = 24$ it could be $13$; for $n = 100$ it could be $53$. Such a prime is big — more than half of $n$ — but still no larger than $n$ itself. That double-sided squeeze, $n/2 < p \le n$ (equivalently $p \le n < 2p$), is exactly the lever we need.

## Why a single big prime breaks the square

Here is the idea that makes everything click. A perfect square has a beautifully rigid internal structure. If you break any square into its prime building blocks — its prime factorization — every single prime must appear an **even** number of times. Think of $36 = 2^2 \cdot 3^2$ or $900 = 2^2 \cdot 3^2 \cdot 5^2$: twos in pairs, threes in pairs, fives in pairs. That is what "being a square" *means* at the atomic level. To split a number into two identical halves, each prime's supply has to divide evenly in two.

So to prove $n!$ is *not* a square, we only need to find **one** prime that divides it an **odd** number of times. One misfit prime poisons the whole well.

That misfit is exactly the Bertrand prime $p$ with $n/2 < p \le n$. Let's count how many times $p$ divides $n!$. Remember that $n! = 1 \times 2 \times \cdots \times n$. Which of these factors contribute a copy of $p$? Only the multiples of $p$. The first multiple of $p$ is $p$ itself, and since $p \le n$, it is in the product — good, that's one copy. But the *next* multiple of $p$ is $2p$, and our prime satisfies $2p > n$. So $2p$ is too big to appear in the product at all. There is exactly **one** multiple of $p$ among $1, 2, \dots, n$, and (because $p$ is prime and large) it carries exactly **one** factor of $p$.

Conclusion: the prime $p$ divides $n!$ precisely **once**. One is odd. A square needs every exponent even. Therefore $n!$ cannot be a square. The argument is airtight for every $n \ge 2$, all the way to infinity, in a single stroke — no computer search required.

There is a classical bookkeeping tool lurking here, **Legendre's formula**, which says the exact number of times a prime $p$ divides $n!$ is
$$\left\lfloor \frac{n}{p} \right\rfloor + \left\lfloor \frac{n}{p^2} \right\rfloor + \left\lfloor \frac{n}{p^3} \right\rfloor + \cdots,$$
where $\lfloor x \rfloor$ means "round down." For our big prime, $\lfloor n/p \rfloor = 1$ (there's one multiple of $p$) and every later term is $0$ (since $p^2 > n$). The formula returns exactly $1$, confirming the count.

## Triangles enter the picture

Squares are not the only special shapes numbers can take. The **triangular numbers** $1, 3, 6, 10, 15, 21, \dots$ count how many bowling pins, billiard balls, or cannonballs you can pack into a perfect triangle. The $t$-th triangular number is
$$T_t = \frac{t(t+1)}{2}.$$
Ten pins ($T_4 = 10$) make a bowling rack; fifteen balls ($T_5 = 15$) make a billiards break.

A natural follow-up question: can a factorial be **both** a square *and* a triangular number at the same time? Some numbers manage this rare double life — $1$ and $36$ and $1225$ are simultaneously square and triangular. Could a factorial join that exclusive club?

The answer is again a flat no, and it comes for free from the work we have already done:

> **The factorial $n!$ is simultaneously a perfect square and a triangular number if and only if $n \le 1$.**

The logic is almost cheeky. To be *both* shapes, $n!$ must in particular be a square. But we just proved that for $n \ge 2$ it never is. So the "square" half of the requirement already fails, and the triangular condition never even gets a chance to be tested. The only survivors are $0! = 1$ and $1! = 1$, and indeed $1 = 1^2 = T_1$ is both a square and a triangle. The intersection is as small as it could possibly be.

## The romantic cousin: Brocard's problem

Our clean theorem has a famous, far more stubborn relative — and this is where the story turns mysterious.

Around 1876, Henri Brocard (and later, independently, the legendary Srinivasa Ramanujan) asked: for which $n$ is $n! + 1$ a perfect square? That is, when does
$$n! + 1 = m^2$$
have a solution in whole numbers? The values of $n$ that work are called **Brown numbers**, and only three are known:
$$4! + 1 = 25 = 5^2, \qquad 5! + 1 = 121 = 11^2, \qquad 7! + 1 = 5041 = 71^2.$$
So $(n, m) = (4, 5)$, $(5, 11)$, and $(7, 71)$. Searches have since pushed past a trillion without finding a fourth. Almost everyone believes these three are the *only* Brown numbers — but **nobody has proved it.** Brocard's problem is open to this day, one of those tantalizing questions that a curious teenager can understand and no living mathematician can settle.

There is a lovely way to see Brocard's question as a *triangular* question, which is where our cast of characters reunites. A short calculation shows that $n!/8$ is a triangular number exactly when $n! + 1$ is an odd perfect square. Indeed, if $n!/8 = T_y = y(y+1)/2$, then
$$n! = 4y(y+1) = (2y+1)^2 - 1, \quad\text{so}\quad n! + 1 = (2y+1)^2.$$
So the three Brown numbers correspond to three triangular factorials-over-eight:
$$\frac{4!}{8} = 3 = T_2, \qquad \frac{5!}{8} = 15 = T_5, \qquad \frac{7!}{8} = 630 = T_{35}.$$
The Brocard–Ramanujan conjecture, restated, is the claim that these are the *only* times $n!/8$ lands on a triangular number. It is the shimmering, unproven counterpart to the theorem we *can* prove.

## Two faces of the same coin

It is worth pausing on why one question is settled and its near-twin is a famous open problem. Both ask whether a factorial-flavored quantity is a perfect square. The difference is the "$+1$."

When we ask about $n!$ itself, the prime-factorization structure of $n!$ is laid bare. We *built* $n!$ by multiplying, so we know its prime anatomy intimately, and Bertrand's lone prime is sitting right there to sabotage any squareness. The proof is short because the structure is transparent.

Add $1$, and the spell breaks. The number $n! + 1$ shares **no** prime factors with $n!$ at all — adding one scrambles the factorization beyond recognition. Suddenly the Bertrand prime tells us nothing, and the transparent structure is gone. That single $+1$ is the entire difference between a one-paragraph proof and a 150-year-old enigma.

This is a recurring drama in number theory: a tiny perturbation turns a tractable problem into an intractable one. The factorial knows exactly what it is made of; $n! + 1$ guards its secrets.

## What we have actually pinned down

Let us collect the cast and the verdict, because the precise statements are the point.

- A number is a **perfect square** if it equals $k^2$ for some whole number $k$.
- A number is **triangular** if it equals $t(t+1)/2$ for some whole number $t$.
- **Bertrand's postulate** guarantees, for every $n \ge 2$, a prime $p$ with $n/2 < p \le n$, i.e. $p \le n < 2p$.
- **The exact-multiplicity lemma:** for such a prime, $p$ divides $n!$ exactly once, so $p^2$ does *not* divide $n!$.
- **The square obstruction:** if a prime divides a number once but its square does not, the number cannot be a perfect square.
- **Main theorem:** $n!$ is a perfect square if and only if $n \le 1$ — that is, only for $n = 0$ and $n = 1$, where $n! = 1$.
- **Double-shape theorem:** $n!$ is simultaneously square and triangular if and only if $n \le 1$.

Each link in this chain is elementary, and yet together they deliver a sweeping, exception-free statement about an infinite family of enormous numbers. No matter how far you march along the factorials — past the number of atoms in the universe, past any bound you care to name — you will never again stumble on a perfect square. The proof guarantees it with the certainty of pure logic, not the hopefulness of a search.

## Why this kind of result matters

It would be easy to file this away as a curiosity, but the underlying technique is a workhorse. The strategy — "find one prime that occurs to an odd or otherwise forbidden power, and use it to rule out an entire shape" — generalizes far beyond squares. The same Bertrand prime that appears exactly once in $n!$ instantly shows that $n!$ is never a perfect cube, never a fifth power, never any higher perfect power for $n$ large enough: a single odd exponent is incompatible with *all* of them at once. With a little more care, the method rules out other rigid "figurate" shapes — pentagonal numbers, hexagonal numbers, and their kin — whose definitions impose congruence constraints that one stubborn prime can violate.

More broadly, this is a parable about **structure versus disguise**. The factorial wears its prime factorization on its sleeve, and that honesty is its undoing as a would-be square. Cryptography, by contrast, is built on the opposite principle: hide a number's factorization well enough and it becomes a vault. The same prime-counting instincts that crack open $n!$ are the ones that, turned around, secure the messages you send every day.

And then there is Brocard's problem, still glittering on the horizon — three known solutions, a trillion-strong silence beyond them, and a conjecture that the silence is total. We have proved the clean theorem about $n!$. Its mischievous cousin $n! + 1$ waits, with that maddening little $+1$, for someone to finish the story.
