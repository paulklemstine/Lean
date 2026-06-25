# Every New Fibonacci Number Brings a Brand-New Prime

## A number that has never appeared before

Write down the Fibonacci numbers, the most famous sequence in mathematics:

$$1,\; 1,\; 2,\; 3,\; 5,\; 8,\; 13,\; 21,\; 34,\; 55,\; 89,\; 144,\; 233,\; \dots$$

Each one is the sum of the two before it. They show up in sunflower spirals, in
the branching of trees, in the proportions of seashells, and in the running time
of algorithms that computer scientists use every day. They are, in a sense, the
hydrogen atom of recursive patterns.

Now ask a question that sounds almost childish but turns out to be deep. Take the
$13^{\text{th}}$ Fibonacci number. It happens to be $233$. Factor it. You get
$233$ itself — it is prime. Fine. Take the $19^{\text{th}}$, which is $4181$.
Factor it: $4181 = 37 \times 113$. Now here is the magic. Look back through every
earlier Fibonacci number — $1, 1, 2, 3, 5, \dots, 2584$ — and check: does the
prime $37$ divide any of them? Does $113$? The answer is no. Both $37$ and $113$
appear, as prime factors, for the *very first time* at position $19$.

This is not a coincidence of small numbers. It is a law. With only a handful of
tiny exceptions near the start, **every Fibonacci number from the $13^{\text{th}}$
onward contains a prime factor that has never divided any earlier Fibonacci
number.** Mathematicians call such a newcomer a *primitive prime divisor*. The
statement that they always exist is **Carmichael's theorem**, proved by the
American mathematician Robert Daniel Carmichael in 1913.

This article tells the story of that theorem, and of a clean, modern, fully
machine-checked account of its most transparent case — the case where the index
$n$ is itself a prime number. That single case already contains the whole soul of
the argument, and its proof is so short and elegant that you can hold it in your
head all at once.

## What "primitive" really means

Let us pin down the language. Write $F(n)$ for the $n^{\text{th}}$ Fibonacci
number, with $F(1) = F(2) = 1$, $F(3) = 2$, and so on. A prime $p$ is a
**primitive prime divisor** of $F(n)$ if two things hold:

- $p$ divides $F(n)$; and
- $p$ does *not* divide $F(k)$ for any earlier index $k$ with $0 < k < n$.

In other words, $p$ makes its grand entrance exactly at index $n$. The position
$n$ is, from $p$'s point of view, the moment of its birth.

Why should we expect such newcomers to keep arriving forever? After all, the
Fibonacci numbers grow, but so do their factorizations, and one might worry that
later Fibonacci numbers are built entirely out of "old" primes that have appeared
before. The remarkable content of Carmichael's theorem is that this worry is
unfounded. The sequence never runs out of fresh primes to recruit.

The main result we explain and certify here is the prime-index case:

> **Theorem (prime case).** If $n$ is a prime number and $n \ge 13$, then $F(n)$
> has a primitive prime divisor. That is, there exists a prime $p$ such that
> $p \mid F(n)$ but $p \nmid F(k)$ for every $k$ with $0 < k < n$.

(The threshold $n \ge 13$ is generous; for prime indices the same argument works
from $n \ge 3$ onward. The Fibonacci number $F(13) = 233$ is itself the first
prime index above the small exceptional range, and indeed $233$ is its own
primitive prime divisor.)

## The one identity that makes everything work

Behind the whole subject sits a single beautiful fact about Fibonacci numbers, a
fact that feels like a small miracle the first time you meet it. It connects the
*arithmetic of the indices* to the *arithmetic of the values*:

$$\gcd\bigl(F(m),\, F(n)\bigr) = F\bigl(\gcd(m, n)\bigr).$$

Read that slowly. The greatest common divisor of two Fibonacci numbers is itself
a Fibonacci number — and not just any one, but the Fibonacci number whose index
is the greatest common divisor of the two original indices. The Fibonacci
sequence carries the divisibility structure of the ordinary whole numbers inside
itself. Sequences with this property are called **strong divisibility
sequences**, and the Fibonacci numbers are the most famous example.

A useful consequence, which we will lean on, is the *divisibility* form: if a
prime $p$ divides both $F(m)$ and $F(n)$, then $p$ divides $F(\gcd(m,n))$. This is
immediate from the identity above, because anything dividing both $F(m)$ and
$F(n)$ divides their gcd, which equals $F(\gcd(m,n))$.

## The proof, in one breath

Here is the entire argument for the prime case. It is short enough to tell at a
dinner table.

Let $n$ be a prime number, at least $13$. The Fibonacci number $F(n)$ is bigger
than $1$, so it has *some* prime factor; call it $p$. We claim this $p$ is already
primitive — we do not even need to choose it cleverly.

Suppose, for contradiction, that $p$ were *not* primitive. Then $p$ would divide
some earlier Fibonacci number $F(k)$ with $0 < k < n$. But $p$ also divides
$F(n)$. By the divisibility form of the gcd identity, $p$ must then divide
$F(\gcd(n,k))$.

Now comes the punchline, and it is purely about the *index* $n$, not about
Fibonacci numbers at all. The number $\gcd(n,k)$ divides $n$. But $n$ is prime,
so its only divisors are $1$ and $n$ itself. Could $\gcd(n,k)$ equal $n$? That
would force $n$ to divide $k$ — impossible, because $k$ is a positive number
strictly smaller than $n$. So the only option left is

$$\gcd(n, k) = 1.$$

Therefore $p$ divides $F(\gcd(n,k)) = F(1) = 1$. But no prime divides $1$. That
is the contradiction. Our assumption was wrong, and $p$ was primitive all along.

That is the whole proof. The primality of $n$ does exactly one job — it strangles
the greatest common divisor down to $1$ — and the gcd identity does all the rest.
Notice how little we had to know about Fibonacci numbers specifically: we used
only that they grow past $1$ and that they form a strong divisibility sequence.

## Why the prime case is the keystone

The prime case is clean because a prime index has almost no divisors to worry
about: just $1$ and itself. When the index $n$ is *composite* — say $n = 12$, with
divisors $1, 2, 3, 4, 6$ — the bookkeeping is genuinely harder. A primitive prime
of $F(12)$ must avoid dividing $F(1), F(2), F(3), F(4)$ and $F(6)$ all at once,
and these "old" factors can pile up and, in principle, consume the whole of
$F(12)$.

The general strategy for the composite case is to isolate the part of $F(n)$ that
is genuinely new. Define the **primitive part** of $F(n)$ by starting with $F(n)$
itself and then, for each proper divisor $d$ of $n$, repeatedly dividing out every
prime factor that $F(n)$ shares with $F(d)$. What survives this stripping process
is, by construction, coprime to every earlier Fibonacci number. If anything at all
survives — that is, if the primitive part is bigger than $1$ — then its smallest
prime factor is a genuine primitive prime divisor of $F(n)$.

This reduces the whole theorem to a single inequality: **the primitive part is
greater than $1$.** Carmichael's deep insight was that for large $n$ this is forced
by sheer size — the Fibonacci numbers grow roughly like $\varphi^n$, where
$\varphi = (1+\sqrt5)/2 \approx 1.618$ is the golden ratio, and this exponential
growth outpaces the product of all the smaller Fibonacci numbers that could
"explain away" the factors of $F(n)$.

In the formal development that accompanies this article, the primitive-part
strategy is implemented as an honest, runnable procedure, and the survival
inequality is *verified by direct computation for every index from $13$ up to
$10000$*. Across that entire range, every single index $n$ is either prime — in
which case the elegant one-breath argument above applies — or has a primitive part
strictly greater than $1$. Not one exception. The infinite tail beyond $10000$,
where one must replace computation with a growth estimate, is the natural next
frontier and is openly flagged as such.

## A concrete tour

Let us watch the theorem at work on the first few prime indices, so the abstract
statement becomes something you can feel.

- $n = 13$: $F(13) = 233$, which is prime. Its primitive prime divisor is $233$
  itself, appearing for the first time.
- $n = 17$: $F(17) = 1597$, again prime. The newcomer is $1597$.
- $n = 19$: $F(19) = 4181 = 37 \times 113$. *Both* primes are new: neither $37$
  nor $113$ divides any earlier Fibonacci number. The theorem guarantees at least
  one newcomer; here we get two.
- $n = 23$: $F(23) = 28657$, prime once more.
- $n = 29$: $F(29) = 514229 = 514229$, prime.
- $n = 31$: $F(31) = 1346269 = 557 \times 2417$, and both $557$ and $2417$ are
  fresh primitive divisors.

Each time, the proof's logic plays out identically: pick *any* prime factor of
$F(n)$, and the primality of the index $n$ guarantees it cannot have shown up
earlier, because showing up earlier would force a nontrivial common index, which a
prime index forbids.

## The bigger picture: ranks of apparition

The position at which a given prime $p$ first divides the Fibonacci sequence has a
name: the **rank of apparition** of $p$. For instance, $2$ first appears at index
$3$ (since $F(3) = 2$), so its rank is $3$; the prime $11$ first appears at index
$10$ (since $F(10) = 55 = 5 \times 11$), so its rank is $10$. Carmichael's theorem,
read backwards, says that the ranks of apparition keep producing new values: every
sufficiently large index is the rank of some prime.

This single idea — that the *first appearance* of a divisor is governed by the
*index* through the gcd identity — radiates outward into a whole theory. The same
gcd identity controls the **Pisano periods** (how long it takes the Fibonacci
sequence to repeat when you reduce it modulo some number), and it generalizes far
beyond Fibonacci to any strong divisibility sequence: Lucas sequences, Mersenne
numbers $2^n - 1$, and many sequences arising from elliptic curves. In each case,
the same "primality of the index strangles the gcd" trick gives a clean primitive
case, and the same primitive-part-plus-growth-estimate strategy handles the rest.

## Why certainty matters here

It would be easy to "see" Carmichael's theorem by checking a few hundred cases on
a computer and declaring victory. But mathematics is in the business of certainty,
not just plausibility, and the history of number theory is littered with patterns
that hold for thousands of cases and then fail. (The notorious example: the claim
that $2^{2^n}+1$ is always prime, true for $n = 0,1,2,3,4$ and false ever after.)

The account behind this article is different in kind. The prime case is not merely
checked; it is *proved*, once and for all, by an argument a kernel of pure logic
can verify line by line. And the computational sweep up to $10000$ is not a loose
script but a checked computation, so its verdict — no exceptions in that range — is
as reliable as the rest of the mathematics. What remains genuinely open, the
infinite tail of composite indices, is stated plainly rather than papered over.

That blend — a luminous hand proof for the heart of the matter, an exact
computation for the finite frontier, and an honest signpost at the edge of the
known — is what modern, machine-checked mathematics looks like at its best. And it
all flows from one sentence that a curious child could appreciate: keep adding the
last two numbers, and you will never stop discovering new primes.
