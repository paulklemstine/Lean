# Where Do the Fibonacci Numbers First Meet a Prime?

## A hidden clock inside the rabbits

Everyone meets the Fibonacci numbers eventually. You start with $0$ and $1$, and
from then on each number is the sum of the two before it:

$$0,\; 1,\; 1,\; 2,\; 3,\; 5,\; 8,\; 13,\; 21,\; 34,\; 55,\; 89,\; 144,\; 233,\; \dots$$

Formally, $F_0 = 0$, $F_1 = 1$, and $F_{n+2} = F_{n+1} + F_n$. They show up in
sunflower spirals, pinecones, the breeding of Fibonacci's idealized rabbits, and
in a thousand classroom puzzles. But there is a deeper, stranger pattern hiding
inside them — one that connects Fibonacci's rabbits to the prime numbers, the
indivisible atoms of arithmetic.

Pick a prime, say $p = 7$. Walk down the Fibonacci list and ask: *when does $7$
first divide one of these numbers?* You find $F_8 = 21 = 3 \times 7$. So $7$
first "appears" at index $8$. Try $p = 11$: the first multiple of $11$ is
$F_{10} = 55 = 5 \times 11$, so $11$ appears at index $10$. Try $p = 13$:
$F_7 = 13$, so $13$ appears at index $7$.

This first index has a wonderfully old-fashioned name: the **rank of
apparition** of $p$, written $\alpha(p)$. It is the smallest positive $k$ for
which $p$ divides $F_k$. (The word "apparition" is no accident — number
theorists from the nineteenth century onward really did speak of a prime
*appearing* in the Fibonacci sequence, like a ghost finally showing itself.)

So we have a table:

| prime $p$ | rank $\alpha(p)$ | $p-1$ | $p+1$ |
|:---:|:---:|:---:|:---:|
| $7$  | $8$  | $6$  | $8$  |
| $11$ | $10$ | $10$ | $12$ |
| $13$ | $7$  | $12$ | $14$ |
| $17$ | $9$  | $16$ | $18$ |
| $19$ | $18$ | $18$ | $20$ |
| $23$ | $24$ | $22$ | $24$ |

Stare at this table for a moment. Something quietly remarkable is going on. The
rank of $7$ is $8$, which divides $p+1 = 8$. The rank of $11$ is $10$, which
divides $p-1 = 10$. The rank of $13$ is $7$, which divides $p-1 = 12$. The rank
of $23$ is $24$, which divides $p+1 = 24$. In every single row, the mysterious
rank $\alpha(p)$ — a number that *a priori* could be anything — turns out to
divide one of the two numbers sitting right next door to the prime: either
$p - 1$ or $p + 1$.

This is the **law of apparition**, and it is the subject of this article. The
result we have formally established is precise:

> **Theorem (Law of Apparition).** For every prime $p \ge 7$, the rank of
> apparition $\alpha(p)$ divides $p - 1$ or divides $p + 1$.

It sounds like a small curiosity. It is in fact the key that turns an apparently
hopeless search into a fast computation, and its proof is a miniature tour of
some of the most beautiful machinery in modern number theory.

## Why this is more than a curiosity

Imagine you are handed an enormous prime — hundreds of digits long — and asked
for its rank of apparition. The naive method is brutal: compute Fibonacci
numbers one by one, reduce each modulo $p$, and wait until you hit zero. For a
large prime, the rank can itself be astronomically large, and you have no idea
in advance how long to wait. It is like being told a treasure is buried
*somewhere* on an infinite beach and being handed a shovel.

The law of apparition changes the game completely. It promises that the rank is
not lurking somewhere out on the infinite number line: it must be a **divisor**
of either $p-1$ or $p+1$. These two numbers are sitting right in front of you,
and a number has only finitely many divisors — usually just a handful. So the
search collapses to:

```
to compute the rank of apparition of a prime p ≥ 7:
    list every divisor d of p − 1 and every divisor d of p + 1
    test them in increasing order
    the first d with p | F_d is the rank α(p)
```

Instead of scanning an unbounded ocean of indices, you check a short, explicit
list. The map has replaced the infinite beach. This is exactly the kind of
theorem that working mathematicians treasure: it converts an existence question
("the rank exists somewhere") into an algorithm ("here is precisely where to
look").

And the reason the *first* divisor you find is genuinely the rank, and not some
later coincidence, is a companion fact we also establish — call it **the
spine**:

> **Theorem (The Spine).** A prime $p$ divides $F_k$ **if and only if**
> $\alpha(p)$ divides $k$.

In words: the indices at which $p$ shows up in the Fibonacci sequence are exactly
the multiples of the rank. The rank is the fundamental period of the prime's
appearances; everything else is an echo. Combined with the law of apparition,
the spine guarantees the little algorithm above is correct: the smallest divisor
of $p \mp 1$ that works is the true rank.

## The trap of circular reasoning

Here is where the story gets subtle, and where a careless proof falls apart.

The natural way a mathematician first tries to prove the law of apparition is to
reach for the **golden ratio**. The Fibonacci numbers have a famous closed form,
Binet's formula:

$$F_n = \frac{\varphi^n - \psi^n}{\sqrt 5}, \qquad
  \varphi = \frac{1 + \sqrt 5}{2}, \qquad \psi = \frac{1 - \sqrt 5}{2}.$$

The two numbers $\varphi$ and $\psi$ are the roots of $x^2 - x - 1 = 0$. The rank
of apparition is intimately tied to the *multiplicative order* of $\varphi$ when
you do arithmetic modulo $p$ — roughly, how many times you must multiply
$\varphi$ by itself before you cycle back to where you started.

But here is the trap. That "order of $\varphi$ modulo $p$" is itself usually
*defined through the rank of apparition*. If you try to bound the rank by
reasoning about the order, and the order is only meaningful because of the rank,
you are chasing your own tail. The argument looks like a proof but proves
nothing. This circularity is a genuine pitfall, and many informal write-ups
quietly fall into it.

## Breaking the circle with the Frobenius map

The escape is elegant. Instead of reasoning about a quantity tangled up with the
rank, we compute the *one* Fibonacci residue that can be pinned down **with no
reference to the rank at all**: the value of $F_p$ modulo $p$.

The tool is the **Frobenius endomorphism**, one of the quiet miracles of
arithmetic in "characteristic $p$" — the world where you do all your sums and
products modulo a prime $p$. In that world, raising to the $p$-th power behaves
like a *linear* operation. The schoolchild's dream identity, usually wrong,
becomes true:

$$(x + y)^p \equiv x^p + y^p \pmod{p}.$$

This is sometimes affectionately called the "freshman's dream," and modulo a
prime it is a theorem, not a mistake, because every binomial coefficient in
between is divisible by $p$.

Apply this to the golden-ratio world. Work in the small algebraic system you get
by adjoining a root of $x^2 - x - 1$ to the integers modulo $p$. There the two
roots $\varphi$ and $\psi$ live happily, and the Frobenius map hands us, for
free:

$$\varphi^p + \psi^p = (\varphi + \psi)^p = 1^p = 1,$$
$$\varphi^p \cdot \psi^p = (\varphi \psi)^p = (-1)^p = -1.$$

From these two innocent equations a short computation gives
$(\varphi^p - \psi^p)^2 = 5$. Translating back through Binet's formula, this says
exactly that

$$(F_p)^2 \cdot 5 = 5,$$

and since $p$ does not divide $5$ (for any prime $p \neq 5$), we may cancel and
conclude:

$$(F_p)^2 \equiv 1 \pmod p, \qquad \text{i.e.} \qquad F_p \equiv \pm 1 \pmod p.$$

This is the engine of the whole proof, and notice what just happened: we
determined $F_p \bmod p$ using only Fermat's little theorem in disguise — the
fact that $5^{(p-1)/2} \equiv \pm 1 \pmod p$, the so-called Legendre symbol of
$5$ — **without ever mentioning the rank $\alpha(p)$.** The circle is broken.

## Cassini's identity closes the deal

We are one classical gem away from the finish line: **Cassini's identity**, known
since the seventeenth century. It says that for every $n$,

$$F_{n+1}^2 - F_{n+2} \, F_n = (-1)^n.$$

It is the statement that consecutive Fibonacci numbers are always "almost"
coprime in a perfectly controlled way; geometrically it underlies the famous
"missing square" puzzle where a rearranged $8\times 8$ chessboard appears to gain
a unit of area.

Set $n = p - 1$. Since $p$ is an odd prime, $p - 1$ is even, so $(-1)^{n} = 1$,
and Cassini becomes

$$F_p^2 = F_{p+1}\, F_{p-1} + 1.$$

We already know $F_p^2 \equiv 1 \pmod p$. Subtracting, we get

$$F_{p+1}\, F_{p-1} \equiv 0 \pmod p.$$

Now the defining property of a prime takes over: if a prime divides a product, it
divides one of the factors. Therefore

$$p \mid F_{p-1} \quad \text{or} \quad p \mid F_{p+1}.$$

This is the **Fibonacci–Fermat law**: every prime $p \ge 7$ divides either the
Fibonacci number one step "before" it, $F_{p-1}$, or the one "after" it,
$F_{p+1}$. Look back at the opening table and you will see it confirmed in every
row.

Finally, the spine snaps the pieces together. If $p \mid F_{p-1}$, then because
$p$ divides $F_k$ exactly when $\alpha(p)$ divides $k$, we get
$\alpha(p) \mid p - 1$. If instead $p \mid F_{p+1}$, then $\alpha(p) \mid p+1$.
Either way:

$$\boxed{\;\alpha(p) \mid p - 1 \quad \text{or} \quad \alpha(p) \mid p + 1.\;}$$

The law of apparition is proved.

## The shape of the argument

Step back and admire the architecture, because it is a beautiful example of how
modern number theory works.

- **A recurrence becomes algebra.** The Fibonacci rule $F_{n+2} = F_{n+1} + F_n$
  is repackaged as a single clean identity in any commutative ring: if an element
  $a$ satisfies $a^2 = a + 1$, then $a^{n+1} = F_{n+1}\,a + F_n$. This is Binet's
  formula stripped of square roots so that it works *verbatim* modulo $p$.
- **The freshman's dream becomes a theorem.** The Frobenius map turns the
  intractable expression $(1+\sqrt5)^p$ into something we can evaluate by hand,
  and routes the whole question through a single Legendre symbol — a fingerprint
  of $p$ modulo $5$.
- **A seventeenth-century identity finishes the job.** Cassini, plus the
  primality of $p$, converts "$F_p^2 \equiv 1$" into the dichotomy
  "$p$ divides $F_{p-1}$ or $F_{p+1}$."

Each ingredient is independently classical; the art is in assembling them so that
nothing refers back to the rank we are trying to bound.

## What we still don't know

A good theorem opens more doors than it closes, and this one is no exception.

**Which side?** The law says $\alpha(p)$ divides $p-1$ *or* $p+1$, but our proof
already whispers the answer to *which*: it produces $F_p \equiv 5^{(p-1)/2}
\pmod p$, and that exponent is exactly the Legendre symbol $(5 \mid p)$, which
depends only on $p$ modulo $5$. The refined conjecture is that
$\alpha(p) \mid p - 1$ when $p \equiv \pm 1 \pmod 5$ and $\alpha(p) \mid p + 1$
when $p \equiv \pm 2 \pmod 5$. Heuristically and computationally each case
happens for half of all primes.

**Higher powers.** What about the rank of $p^2$, or $p^3$? It is conjectured that
$\alpha(p^k) = p^{k-1}\,\alpha(p)$, with a single shadowy class of possible
exceptions: the **Wall–Sun–Sun primes**, for which $p^2$ would divide
$F_{\alpha(p)}$. Despite enormous searches, *not one such prime has ever been
found.* Whether they exist at all is a famous open problem, connected
historically even to attacks on Fermat's Last Theorem.

**The statistics.** How often is the rank as large as it can possibly be,
$\alpha(p) = p - 1$ or $p + 1$? How are the ranks distributed as $p$ ranges over
all primes? These questions remain largely conjectural, accessible today mostly
through computation — and computation is now cheap, precisely because the law of
apparition tells us exactly where to look.

From a children's puzzle about rabbits to the Frobenius map and the frontier of
prime distribution — the rank of apparition is a reminder that the most elementary
sequences hide the deepest clocks. We now know, with certainty, where the
Fibonacci numbers first meet each prime: never far from the prime itself, always
within one step of $p$, divisor of $p-1$ or $p+1$, every single time.
