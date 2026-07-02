# The Sequence That Counts, Divides, and Remembers Fibonacci

## A number hidden in every fraction

Ask a child to list the fractions between $0$ and $1$ and you will quickly run into trouble: which ones, in what order, and how do you promise to hit every single one exactly once, never repeating $\tfrac12$ as $\tfrac24$? For centuries this innocent-looking bookkeeping problem sat at the crossroads of arithmetic, geometry, and computation. Remarkably, a single, almost childishly simple sequence of integers answers it — and along the way it turns out to secretly encode the Fibonacci numbers.

That sequence is **Stern's diatomic sequence**. It begins

$$0,\ 1,\ 1,\ 2,\ 1,\ 3,\ 2,\ 3,\ 1,\ 4,\ 3,\ 5,\ 2,\ 5,\ 3,\ 4,\ 1,\ 5,\ 4,\ 7,\ \dots$$

and it is built from a rule so short you could whisper it: start with $s(0)=0$ and $s(1)=1$, then decree that the value at an **even** position $2n$ simply copies the value at position $n$, while the value at an **odd** position $2n+1$ is the **sum** of its two "parents" $s(n)$ and $s(n+1)$. In symbols,

$$s(2n) = s(n), \qquad s(2n+1) = s(n) + s(n+1).$$

Every term is manufactured from earlier terms by either copying or adding. Nothing else. And yet, as we will see, this modest recipe produces a sequence with three surprising and provable personalities: it *counts*, it *divides perfectly*, and it *remembers Fibonacci*.

## The copy-and-add machine

Before the surprises, let us get a feel for the machine. To find $s(9)$, note that $9 = 2\cdot 4 + 1$ is odd, so $s(9) = s(4) + s(5)$. Now $s(4) = s(2) = s(1) = 1$ (three even steps, each a copy), and $s(5) = s(2)+s(3) = 1 + 2 = 3$. Hence $s(9) = 1 + 3 = 4$. Every value can be unwound this way, descending toward the seed values $s(0)$ and $s(1)$ by repeatedly halving the index.

A useful mental picture is a binary tree. Write the index in base two; reading its bits tells you exactly which copy-or-add steps to perform. A trailing $0$ means "copy the value from the number with that last bit removed"; a trailing $1$ means "add together two neighbors." The **binary expansion of the index is the sequence's genetic code.** This is why the interesting behavior of Stern's sequence always shows up at indices with especially clean binary patterns — all ones, a single one, or alternating ones and zeros.

## Personality one: it divides perfectly

Here is the first miracle. Take any two *neighboring* values in the list, say $s(9)=4$ and $s(10)=3$, or $s(19)=7$ and $s(20)=?$. Compute their greatest common divisor. You will always get $1$. Neighbors in Stern's sequence share no common factor other than $1$; they are **coprime**, forever, without exception.

> **Theorem (Coprime neighbors).** For every $n$, the values $s(n)$ and $s(n+1)$ have greatest common divisor $1$.

Why should copying and adding preserve coprimality so faithfully? The proof is a clean induction that mirrors the sequence's own construction. Suppose neighbors were always coprime up to some point. A pair of neighbors at the next level is one of two shapes. Either it is $\big(s(2n), s(2n+1)\big) = \big(s(n),\, s(n)+s(n+1)\big)$, or it is $\big(s(2n+1), s(2n+2)\big) = \big(s(n)+s(n+1),\, s(n+1)\big)$. In both cases the pair is obtained from an earlier pair $\big(s(n), s(n+1)\big)$ by the operation "keep one entry, replace the other by the sum." But adding one number to another never changes their greatest common divisor — $\gcd(a, a+b) = \gcd(a,b)$ — so the new pair is coprime precisely because the old one was. The seed pair $(0,1)$ is coprime, and the property cascades up the entire tree.

This is not a mere curiosity. It is the engine behind the fraction-listing problem from the opening. Form the running ratios

$$\frac{s(0)}{s(1)},\ \frac{s(1)}{s(2)},\ \frac{s(2)}{s(3)},\ \frac{s(3)}{s(4)},\ \dots = \frac{0}{1},\ \frac{1}{1},\ \frac{1}{2},\ \frac{2}{1},\ \frac{1}{3},\ \frac{3}{2},\ \dots$$

Because consecutive values are coprime, **every one of these fractions is automatically in lowest terms** — no reducing required. It is a longstanding and beautiful fact that this list marches through *every* nonnegative rational number exactly once. Coprimality is the reason there is never a duplicate in disguise. The humble copy-and-add rule turns out to be a perfect, dictionary-order enumeration of the rationals.

## Personality two: it counts

The second personality reveals itself at the "extreme" binary indices. Consider the numbers whose binary form is all ones: $1 = 1_2$, $3 = 11_2$, $7 = 111_2$, $15 = 1111_2$, and in general $2^n - 1$, a string of $n$ ones. Evaluate Stern's sequence there:

$$s(2^1 - 1) = s(1) = 1,\quad s(2^2-1)=s(3)=2,\quad s(2^3-1)=s(7)=3,\quad s(2^4-1)=s(15)=4.$$

The pattern is unmistakable and exact.

> **Theorem (All-ones indices count).** For every $n$, $s(2^n - 1) = n$.

The all-ones index of length $n$ has Stern value exactly $n$. The sequence literally counts the number of ones in these maximal binary strings. The proof is a short induction: an all-ones number of length $n+1$ is odd, so the odd rule splits it as a sum $s(2^n - 1) + s(2^n)$, and one checks separately that at a pure power of two the value is pinned to $1$:

> **Companion fact (Powers of two are fixed at one).** For every $n$, $s(2^n) = 1$.

Indeed $2^n$ is even, so the even rule copies $s(2^n) = s(2^{n-1}) = \dots = s(1) = 1$. Feeding this back in, $s(2^{n+1}-1) = s(2^n - 1) + s(2^n) = n + 1$, completing the count. Two of the cleanest binary patterns — a lone one, and a solid block of ones — give the two simplest possible answers: the constant $1$, and the counting numbers $1, 2, 3, \dots$.

## Personality three: it remembers Fibonacci

Now for the showpiece. We have looked at indices that are all ones and indices that are a single one. What happens at indices with **alternating** bits — $1, 101, 10101, 1010101$ in binary?

These are the **Jacobsthal numbers**,

$$J(n) = \frac{4^n - 1}{3} = 0,\ 1,\ 5,\ 21,\ 85,\ 341,\ \dots$$

Each $J(n)$ is exactly the number whose binary expansion is $n$ ones interleaved with zeros. And each satisfies the tidy relation $J(n+1) = 4\,J(n) + 1$, which in binary just tacks another "01" onto the front.

Read Stern's sequence along these sparse, alternating-bit landmarks and something extraordinary emerges:

$$s(J(n)) = 0,\ 1,\ 3,\ 8,\ 21,\ 55,\ 144,\ 377,\ \dots$$

These are the **Fibonacci numbers at even positions**: $F(0), F(2), F(4), F(6), \dots$. A binary-recursive copying machine, born from an entirely different world than the additive Fibonacci recurrence $F(k+1) = F(k) + F(k-1)$, reproduces Fibonacci exactly.

> **Theorem (The Stern–Fibonacci bridge).** For every $n$, $s(J(n)) = F(2n)$, where $J(n) = (4^n-1)/3$ and $F$ is the Fibonacci sequence.

How can two such different sequences meet? The secret is to watch **two** landmarks at once. Alongside $J(n)$, track the index $2J(n)+1$. Stern's value there turns out to be the *odd*-position Fibonacci numbers:

$$s(2J(n)+1) = 1,\ 2,\ 5,\ 13,\ 34,\ 89,\ 233,\ 610,\ \dots = F(2n+1).$$

Neither of these two facts can be proved alone — each step in the induction needs the other. But together they lock into a self-perpetuating pair. Writing $a_n = s(J(n))$ and $b_n = s(2J(n)+1)$, the copy-and-add rules unwind the relation $J(n+1) = 4J(n)+1$ into

$$a_{n+1} = a_n + b_n, \qquad b_{n+1} = a_{n+1} + b_n.$$

Compare this with the Fibonacci numbers grouped in even/odd pairs: $F(2n+2) = F(2n) + F(2n+1)$ and $F(2n+3) = F(2n+2) + F(2n+1)$. **The two coupled pairs obey the very same recurrence and start from the same seed** $(a_0, b_0) = (0,1) = (F(0), F(1))$. By induction they are equal at every step, and in particular $a_n = s(J(n)) = F(2n)$. The bridge is built.

## Why it matters

It is tempting to file all this under "recreational." But each personality points at something structural.

The coprimality result is the backbone of one of the most elegant enumerations of the rational numbers ever discovered — a single, deterministic, division-free way to list every fraction once. In an age when we ask computers to generate, hash, and address unbounded streams of data, a rule that walks through all rationals with no collisions and no wasted work is genuinely useful, not merely pretty.

The counting result shows that Stern's sequence is, in a precise sense, *reading the binary expansion of its index* — it is a bridge between how we write numbers and how numbers behave. Sequences that respond so cleanly to base-two structure are exactly the ones that appear in the analysis of algorithms, in the theory of continued fractions, and in the geometry of the Stern–Brocot tree.

And the Fibonacci bridge is a reminder that the great sequences of mathematics are not islands. Fibonacci numbers, famous from sunflowers and spirals and the golden ratio, turn up unbidden inside a completely unrelated copy-and-add machine, visible only if you know to look along the alternating-bit indices. Coincidences like this are how mathematicians discover that two theories are secretly the same theory in disguise.

Three theorems, one four-line rule. Stern's diatomic sequence counts the ones in a binary string, keeps every neighboring pair perfectly coprime, and — along the alternating-bit landmarks — quietly recites Fibonacci. Not bad for a sequence you can teach to a child in a single sentence.
