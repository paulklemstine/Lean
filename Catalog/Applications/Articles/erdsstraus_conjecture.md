# Three Slices and a Stubborn Number: The Erdős–Straus Conjecture

## A children's question that grew teeth

Imagine you have a single chocolate bar and you want to give an equal share to four friends. Each friend gets one quarter — the fraction $\frac{1}{4}$. Easy. Now flip the puzzle around. Suppose you want to give *four* identical shares using a strange rule: every share you hand out must be a *unit fraction*, a piece of the form $\frac{1}{x}$ — one whole bar split into $x$ equal pieces, of which you take exactly one. And you are only allowed to use **three** such pieces, total.

Concretely: can you always write

$$\frac{4}{n} = \frac{1}{x} + \frac{1}{y} + \frac{1}{z}$$

for *every* whole number $n \ge 2$, where $x$, $y$, and $z$ are positive whole numbers?

This is the **Erdős–Straus conjecture**, posed by Paul Erdős and Ernst Straus in 1948. It is one of those deceptively innocent statements that a curious teenager can understand in a minute, yet which has resisted the full force of professional mathematics for more than seventy-five years. Numerical searches have verified it for every $n$ up to astronomically large bounds — well past $10^{17}$ — and yet no one has produced a complete proof. It sits, quietly unsolved, in the same family of "easy to state, brutally hard to prove" problems as the twin prime conjecture and the Collatz problem.

What makes the conjecture so seductive is that *most* cases are genuinely easy. The difficulty hides in a single, narrow corner of the number line. This article tells the story of how almost the entire problem collapses into that one corner — and exactly which corner it is.

## Unit fractions: the oldest arithmetic

Before we attack the conjecture, it's worth pausing on the strange constraint that every piece must be a unit fraction. This is not a modern affectation. It is one of the oldest ideas in mathematics. The ancient Egyptians, writing on papyrus more than 3,500 years ago, expressed *all* their fractions (with the lone exception of $\frac{2}{3}$) as sums of distinct unit fractions. To them, $\frac{3}{4}$ was not a single object but the sum $\frac{1}{2} + \frac{1}{4}$. Their scribes carried lookup tables — the famous Rhind Mathematical Papyrus contains a table for $\frac{2}{n}$ — precisely because doing arithmetic in this system required knowing these decompositions by heart.

The Erdős–Straus conjecture is, in this light, a very Egyptian question with a modern twist: it fixes the numerator at $4$, fixes the number of pieces at exactly $3$, and asks whether the decomposition is *always* possible. (The pieces are allowed to repeat, unlike in strict Egyptian fractions — a subtlety that, as we'll see, the easy constructions exploit freely.)

## The trick that clears the denominators

The first move any number theorist makes is to get rid of the fractions. Suppose we have positive whole numbers $x$, $y$, $z$ satisfying

$$\frac{4}{n} = \frac{1}{x} + \frac{1}{y} + \frac{1}{z}.$$

Multiply both sides by the common denominator $n \cdot x \cdot y \cdot z$. The fractions vanish and we are left with a clean statement about whole numbers:

$$4 \cdot x y z = n \cdot (xy + yz + zx).$$

This is the heart of the whole subject. The conjecture is true for a given $n$ precisely when this single polynomial equation has a solution in positive integers $x, y, z$. The advantage is enormous: instead of reasoning about delicate rational identities, we can hunt for whole-number solutions and *verify* any candidate by a single multiplication. If someone hands you a triple, checking it is trivial; the art is in *producing* it.

We give this bridge a name. The principle "a positive integer triple satisfying $4xyz = n(xy+yz+zx)$ produces a genuine three-unit-fraction decomposition of $\frac{4}{n}$" is the engine behind every construction below. Once you have the integer identity, the fraction decomposition follows automatically.

## Conquering the easy cases

Here is the surprising part: vast swaths of the number line fall to a single clever guess each. Let me walk through four families that, together, handle *almost every* number.

### Even numbers fall instantly

Suppose $n$ is even, say $n = 2m$. Then there is a beautiful identity that works for every single even number at once. Set

$$x = m, \qquad y = m+1, \qquad z = m(m+1).$$

Then

$$\frac{1}{m} + \frac{1}{m+1} + \frac{1}{m(m+1)} = \frac{2m+1}{m(m+1)} + \frac{1}{m(m+1)} = \frac{2m+2}{m(m+1)} = \frac{2(m+1)}{m(m+1)} = \frac{2}{m} = \frac{4}{2m} = \frac{4}{n}.$$

Done. Every even number is solved by one formula. The third term, $\frac{1}{m(m+1)}$, is the "telescoping fudge factor" — a tiny sliver that patches the gap between $\frac{1}{m}+\frac{1}{m+1}$ and the target. This pattern, where two natural pieces almost work and a third tiny piece closes the gap, recurs throughout the subject.

### Multiples of three fall too

If $3$ divides $n$, write $n = 3m$. A close cousin of the even identity does the job:

$$\frac{4}{3m} = \frac{1}{m+1} + \frac{1}{m(m+1)} + \frac{1}{3m}.$$

You can verify this the same way: combine the first two terms into $\frac{1}{m}$, and then $\frac{1}{m} + \frac{1}{3m} = \frac{3}{3m} + \frac{1}{3m} = \frac{4}{3m}$. Another infinite family, gone in one line.

### Sierpiński's family: numbers that leave remainder 3 after division by 4

Now we reach the genuinely clever constructions. The Polish mathematician Wacław Sierpiński observed that whenever $n$ leaves a remainder of $3$ when divided by $4$ — that is, $n \equiv 3 \pmod 4$ — we can write $n + 1 = 4k$ for some whole number $k$, and then

$$\frac{4}{n} = \frac{1}{k} + \frac{1}{2kn} + \frac{1}{2kn}.$$

The same two-tiny-pieces idea appears again: one "large" piece $\frac{1}{k}$ does the bulk of the work, and two equal slivers $\frac{1}{2kn}$ correct the small discrepancy. The verification reduces to the algebraic identity $4 \cdot 2kn = n(2kn + \ldots)$ — a polynomial fact that follows directly from $n + 1 = 4k$.

### Komornik's family: numbers that leave remainder 5 after division by 8

Pushing further, one can handle numbers congruent to $5$ modulo $8$. Writing $n + 3 = 8b$, the decomposition

$$\frac{4}{n} = \frac{1}{2b} + \frac{1}{2bn} + \frac{1}{bn}$$

does the trick. Again it is a single, checkable polynomial identity, this time flowing from $n + 3 = 8b$.

## The great collapse: down to one residue class

Now comes the punchline that makes the whole subject tick. Let me assemble what we have.

**First, a reduction to primes.** Two facts conspire. The decomposition behaves beautifully under *divisibility*: if you can solve $\frac{4}{m}$ and $m$ divides $n$, then you can solve $\frac{4}{n}$ by simply scaling every denominator by the factor $n/m$. (If $\frac{4}{m} = \frac{1}{x}+\frac{1}{y}+\frac{1}{z}$ and $n = km$, then $\frac{4}{n} = \frac{1}{kx}+\frac{1}{ky}+\frac{1}{kz}$.) So a solution for any *divisor* of $n$ automatically lifts to $n$ itself.

This single observation lets us throw away all composite numbers. Given any $n \ge 2$, look at its smallest prime factor $p$. If we can solve $\frac{4}{p}$, we can lift that solution to $\frac{4}{n}$. **Therefore it suffices to prove the conjecture for prime denominators.**

*(A word of caution, because it is instructive: the divisibility trick only runs in one direction. Solving $\frac{4}{m}$ lets you solve $\frac{4}{n}$ for multiples $n$ of $m$ — but knowing $\frac{4}{n}$ is solvable does **not** let you conclude $\frac{4}{(n/d)}$ is solvable for divisors. The cautionary example is $n = 4$, $d = 4$: then $n/d = 1$, and $\frac{4}{1} = 4$ cannot possibly be three unit fractions, since the largest such sum, $\frac{1}{1}+\frac{1}{1}+\frac{1}{1}$, is only $3$. Direction matters.)*

**Second, sort the primes by remainder.** Every prime $p > 2$ leaves a remainder of $1$, $3$, $5$, or $7$ when divided by $8$. Watch how our four families devour them:

- $p = 2$ is even — solved by the **even** family.
- $p \equiv 3 \pmod 8$ means $p \equiv 3 \pmod 4$ — solved by **Sierpiński**.
- $p \equiv 7 \pmod 8$ also means $p \equiv 3 \pmod 4$ — solved by **Sierpiński** again.
- $p \equiv 5 \pmod 8$ — solved by **Komornik**.
- $p \equiv 1 \pmod 8$ — **nobody knows in general.**

This is the great collapse. Of the four possible odd-prime remainders modulo $8$, three are completely handled by elementary, explicit formulas. The *entire* unsolved content of the Erdős–Straus conjecture — every drop of its seventy-five-year difficulty — is concentrated in a single arithmetic progression:

$$p \equiv 1 \pmod 8: \qquad p = 17,\ 41,\ 73,\ 89,\ 97,\ 113,\ \ldots$$

**If someone finds a construction that works for every prime $p \equiv 1 \pmod 8$, the Erdős–Straus conjecture is proved, completely and unconditionally.** Everything else is already done.

## What "verified to large bounds" really means

It is one thing to say "checked by computer up to $10^{17}$." It is another to make that checking airtight. The reduction above turns a daunting infinite search into a tidy finite one. To confirm the conjecture for *all* $n$ below some bound $N$, you do not need to examine every $n$. You only need to examine the primes $p \equiv 1 \pmod 8$ below $N$ — for each, exhibit one triple $(x, y, z)$ and verify the single identity $4xyz = p(xy+yz+zx)$. Everything else is handled by the four families and the divisor-lifting principle.

This is exactly how the conjecture has been confirmed for every $n$ from $2$ up to $1000$, and far beyond: a finite, mechanical verification, where each of the genuinely hard primes is dispatched by an explicitly tabulated witness, and all other cases follow from general structural theorems. The witnesses for the $1 \pmod 8$ primes are found by a short computer search — but once found, each one is a permanent, self-certifying certificate. The conjecture, for any *specific* number, is never in doubt; only its universal truth remains open.

## Why a child's puzzle resists the masters

Why is the $1 \pmod 8$ case so hard? The honest answer is that nobody fully knows. The deeper structure connects to *quadratic residues* — the question of which numbers are perfect squares modulo $p$ — and ultimately to the celebrated law of quadratic reciprocity, one of the jewels of number theory. The residue $1 \pmod 8$ is special precisely because it is the case where $2$ becomes a quadratic residue, subtly changing the solvability of the congruences that govern whether a clean construction exists. The elementary families exploit cheap algebraic coincidences; the $1 \pmod 8$ primes seem to have exhausted those coincidences, leaving only obstructions that current methods cannot uniformly defeat.

There is something profound in this. A problem a child can pose has been compressed, by clean and elementary reasoning, into the single hardest residue class — and there it waits. The collapse from "all integers $\ge 2$" to "primes $\equiv 1 \pmod 8$" is not a partial result to be apologized for. It is the precise anatomy of the difficulty: a map showing exactly where the dragon sleeps.

## The takeaway

The Erdős–Straus conjecture teaches a lesson that runs through all of mathematics: behind a simple question often lies a hidden landscape, mostly gentle, with the entire challenge concentrated in one sharp peak. Four short formulas — for even numbers, multiples of three, and primes of certain remainders — sweep away the overwhelming majority of cases. A single structural principle, divisor lifting, reduces everything to primes. And then, at $p \equiv 1 \pmod 8$, the trail goes cold.

For now, $\frac{4}{n} = \frac{1}{x} + \frac{1}{y} + \frac{1}{z}$ remains true everywhere we look, proven in vast swaths, and conjectured everywhere else. Three slices of chocolate, one stubborn number, and a puzzle that has outlasted three generations of mathematicians — and may yet outlast a fourth.
