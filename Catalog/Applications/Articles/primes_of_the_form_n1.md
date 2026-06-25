# The Primes That Hide Inside a Parabola

## A question a child could ask

Square a whole number and add one. Do it for $n = 1$ and you get $2$. For $n = 2$
you get $5$. For $n = 4$ you get $17$. For $n = 6$ you get $37$. Every one of
those — $2, 5, 17, 37$ — is a prime number, divisible by nothing but itself and
one.

Keep going and the primes keep appearing: $n = 10$ gives $101$, $n = 14$ gives
$197$, $n = 16$ gives $257$. Plot the values $n^2 + 1$ and you are walking along a
parabola, and scattered along that gentle curve, like lampposts in a fog, the
prime numbers refuse to stop showing up.

So here is the question, asked first in a precise form by Edmund Landau in 1912
and still unanswered today:

> **Are there infinitely many primes of the form $n^2 + 1$?**

Almost everyone who has thought about it believes the answer is *yes*. The
numbers practically scream it. And yet, more than a century later, nobody has
been able to prove it. It sits on Landau's famous list of four "unattackable"
problems about primes, problems he singled out precisely because they look easy
and turn out to be brutally hard.

This article is about what we *can* prove — rigorously, completely, with no
hand-waving — about the primes hiding inside that parabola. It turns out that
even though the headline question is open, the *local* structure of $n^2 + 1$ is
something we understand exactly. And that local structure is not a curiosity: it
is the engine behind one of the deepest theorems of twentieth-century number
theory, and it has a surprisingly concrete relevance to modern cryptography.

## The one law that governs everything

Start with a single, beautiful fact. Pick a prime number $p$ and ask: *can
$n^2 + 1$ ever be a multiple of $p$?* In other words, is there some $n$ with

$$n^2 + 1 \equiv 0 \pmod p,$$

which is the same as asking whether $-1$ is a perfect square in the world of
arithmetic-modulo-$p$.

The answer is governed by a single, astonishingly clean rule. Divide $p$ by $4$
and look at the remainder:

- If the remainder is $1$ (primes like $5, 13, 17, 29, \dots$), then **yes** —
  there is a solution.
- If the remainder is $3$ (primes like $3, 7, 11, 19, \dots$), then **no** — there
  is never a solution.
- The prime $2$ is a special small case (with $n = 1$, $n^2 + 1 = 2$).

That is the whole law. Whether a prime can divide a value of $n^2+1$ is decided
entirely by its remainder when divided by four. In formal terms, the congruence
$x^2 + 1 \equiv 0 \pmod p$ is solvable **if and only if** $p \not\equiv 3
\pmod 4$. This is a classical consequence of Gauss's theory of quadratic
residues, and it has been verified here down to the last logical step.

A worked example makes it vivid. Take $p = 13$, which leaves remainder $1$. The
law promises a solution, and indeed $5^2 + 1 = 26 = 2 \cdot 13$. Now take
$p = 7$, which leaves remainder $3$. The law forbids a solution, and sure enough,
running through $n = 0, 1, 2, 3, 4, 5, 6$ gives $n^2 + 1 = 1, 2, 5, 10, 17, 26,
37$, and none of those is divisible by $7$. The prime $7$ — and every prime like
it — is simply locked out of the parabola.

## Exactly two doors, or none at all

The law has a sharper edge. When a prime $p$ (other than $2$) *does* admit
solutions, how many are there? The answer is always **exactly two**.

This is not an accident; it is the algebraic shadow of an everyday fact about
square roots. Over the ordinary numbers, a positive quantity has two square
roots, one positive and one negative — $\sqrt{9} = \pm 3$. In modular
arithmetic the same thing happens: if $i$ is a solution of $x^2 = -1$, then so is
$-i$, and (because $p$ is odd) these two are genuinely different. There can be no
third, because a quadratic equation cannot have three roots in this kind of
arithmetic.

So for every prime, the door to the parabola is in one of exactly two states:

- **$p \equiv 1 \pmod 4$:** two doors open — precisely two residues $n$ modulo
  $p$ make $p$ divide $n^2 + 1$.
- **$p \equiv 3 \pmod 4$:** no doors at all — zero residues work.

Both halves of this dichotomy have been proven exactly: the count is $2$ in the
first case and $0$ in the second. There is no "sometimes," no exception buried in
the large primes. The behavior is rigid, and it is total.

## The Legendre symbol: bookkeeping for square roots

Mathematicians have a compact piece of notation for "is $-1$ a square modulo
$p$?" It is the **Legendre symbol**, written $\left(\frac{-1}{p}\right)$, and it
takes the value $+1$ when $-1$ is a square and $-1$ when it is not. Our law,
re-expressed in this language, becomes a slogan:

$$\left(\frac{-1}{p}\right) = +1 \iff p \equiv 1 \pmod 4, \qquad
\left(\frac{-1}{p}\right) = -1 \iff p \equiv 3 \pmod 4.$$

This is more than a change of clothes. The Legendre symbol is the basic atom of
*quadratic reciprocity*, the deep symmetry Gauss called his "golden theorem," and
phrasing the parabola's law in this currency connects our humble $n^2 + 1$ to the
entire edifice of modern algebraic number theory. Both directions of this
equivalence have been formally checked.

## The Great Filter

Now comes the payoff — the single most useful consequence, and the one with
teeth. Combine the pieces: a prime $p \equiv 3 \pmod 4$ can *never* divide
$n^2 + 1$, for *any* $n$ whatsoever. Not for small $n$, not for large $n$, not
ever. We can state it as a clean, universal theorem:

> For every prime $p$ with $p \equiv 3 \pmod 4$ and every whole number $n$, the
> number $p$ does **not** divide $n^2 + 1$.

Think about what this means. Roughly half of all primes — $3, 7, 11, 19, 23, 31,
\dots$ — are *categorically banned* from appearing as factors of $n^2 + 1$. The
sequence $n^2 + 1$ is built only from the prime $2$ and the primes that leave
remainder $1$ modulo $4$. It is as if half the alphabet were forbidden, and every
word in the language had to be spelled with the remaining letters.

This is what we call **the Great Filter**, and it has a striking quantitative
form. Ask: among all the numbers $n$ below some huge bound $X$, how many have an
$n^2 + 1$ that is divisible by *some* prime congruent to $3$ modulo $4$? The
filter says the answer is **exactly zero** — not "vanishingly few," not
"asymptotically negligible," but precisely $0$, for every $X$ you choose. This
has been proven outright, and crucially it required *no* heavy analytic
machinery, no prime number theorem, no estimates. It falls out of the divisibility
law alone, like a key turning a lock.

## Why this is hard — and why the filter matters

If half the primes are banned, you might think proving infinitely many $n^2 + 1$
are themselves prime would be easy. It is not, and the reason is instructive.

The difficulty is one of *density*. The values $n^2 + 1$ are sparse: by the time
you reach $X$, you have only about $\sqrt{X}$ of them, because they grow
quadratically. The primes are also thinning out. Asking whether a sparse sequence
keeps hitting another sparse sequence infinitely often is exactly the kind of
question where our tools run dry. The standard sieve methods — the mathematical
nets we use to catch primes — lose their grip when the sequence is this thin.

This is where the local structure earns its keep. Heuristically, the density of
primes in the sequence $n^2+1$ is predicted by multiplying together a "local
factor" for each prime, measuring how the parabola interacts with that prime.
That product is called the *singular series*. The conjectured count of primes
$n^2 + 1$ up to $X$ has the shape

$$\#\{n \le X : n^2 + 1 \text{ prime}\} \approx C \cdot \frac{X}{\sqrt{\log X}}$$

for an explicit constant $C$. **This asymptotic is a conjecture, not a theorem**
— it is the Bateman–Horn / Hardy–Littlewood prediction, and proving it would
settle Landau's problem. What is rigorous, and what we have nailed down exactly,
are the *individual local factors* that go into it.

For each prime $p$, define $\nu_p(n)$ to be the number of solutions to
$x^2 + 1 \equiv 0 \pmod p$ that are also coprime to $n$ — the "useful" roots. Two
facts about it are proven exactly. First, at any odd prime, $\nu_p(n)$ is **at
most two** (it is counting a subset of those two doors). Second, at any prime
$p \equiv 3 \pmod 4$, the factor **vanishes completely**: $\nu_p(n) = 0$. The
local density is honest about the Great Filter — it goes to zero at precisely the
banned primes, which is exactly why those primes contribute nothing to the count.

## From a parabola to a fourth power: Friedlander and Iwaniec

The story does not end in defeat. In 1978 Henryk Iwaniec proved something
remarkable: although we cannot show $n^2 + 1$ is prime infinitely often, we *can*
show it is **almost prime** infinitely often. Specifically, there are infinitely
many $n$ for which $n^2 + 1$ has at most two prime factors — a so-called
$P_2$ number, either a prime or a product of two primes. The Great Filter is the
opening move in that proof: it tells the sieve, before any analysis begins, which
primes it never has to worry about.

Then, in 1998, John Friedlander and Henryk Iwaniec achieved one of the landmark
results of modern number theory. They proved that there are infinitely many
primes of the form

$$a^2 + b^4.$$

This is astonishing because the values $a^2 + b^4$ are even *sparser* than
$n^2 + 1$ — there are only about $X^{3/4}$ of them up to $X$ — and capturing
primes in so thin a sequence had been thought beyond reach. Their proof
introduced entirely new "asymmetric" sieve ideas that have reshaped the field.

And here is the bridge back to our parabola: if you set $b = 1$ in $a^2 + b^4$,
you get exactly $a^2 + 1$. The Landau sequence is the thinnest slice of the
Friedlander–Iwaniec sequence. The two problems are not cousins; one literally
contains the other. Friedlander and Iwaniec could not resolve Landau's problem —
fixing $b=1$ throws away the very flexibility their method needs — but they
conquered the larger, richer set in which it lives.

## What this has to do with keeping secrets

Why should a cryptographer care which primes can divide $n^2 + 1$?

Modern public-key cryptography runs on prime numbers and on arithmetic modulo
primes. Whether $-1$ is a square modulo $p$ — the exact question our law
answers — controls the shape of finite fields, the existence of square roots used
in signature schemes, and the structure of the elliptic curves that secure much
of the internet. A prime $p \equiv 1 \pmod 4$ has a square root of $-1$ and
behaves very differently from a prime $p \equiv 3 \pmod 4$, where taking square
roots is famously easy (a fact exploited in the Rabin cryptosystem and in fast
square-root algorithms).

When systems need primes with special structure — primes of a prescribed form,
primes built to make certain attacks impossible or certain operations fast — they
lean on exactly the kind of local analysis described here. Knowing *for certain*,
and not merely heuristically, which primes are admissible factors of a structured
sequence is the difference between a parameter choice you can trust and one you
merely hope is safe. The Great Filter is a guarantee, and in cryptography
guarantees are the whole game.

## The honest ledger

It is worth being precise about what is settled and what is not, because the line
between them is the most interesting thing in this story.

**Proven, exactly and unconditionally:**

- A prime $p$ divides some value of $n^2 + 1$ if and only if $p \not\equiv 3
  \pmod 4$.
- When it can, there are exactly two residues that work; when it cannot, there are
  zero.
- The Legendre symbol $\left(\frac{-1}{p}\right)$ equals $+1$ exactly for
  $p \equiv 1 \pmod 4$ and $-1$ exactly for $p \equiv 3 \pmod 4$.
- No prime $p \equiv 3 \pmod 4$ ever divides $n^2 + 1$ — so the count of $n < X$
  with such a factor is exactly $0$.
- The local density factor $\nu_p(n)$ is at most $2$ at odd primes and is $0$ at
  primes $p \equiv 3 \pmod 4$.

**Still open, after more than a century:**

- Whether there are infinitely many $n$ with $n^2 + 1$ itself prime (Landau).
- The precise asymptotic $C \cdot X / \sqrt{\log X}$ for how many there are.

That gap — between the local structure we command completely and the global
question we cannot yet touch — is where number theory lives. The parabola keeps
its lampposts lit. We can prove, with total certainty, which lamps are even
allowed to exist. Whether they shine on forever, the numbers insist they do; the
proof, for now, waits.
