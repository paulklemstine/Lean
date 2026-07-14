# When Geometry Learns to Count in Powers of Two

## A sequence that starts messy and ends perfectly

Some of the most beautiful stories in mathematics begin with a list of numbers that looks, at first glance, like it was scribbled down by accident. Consider this one:

$$6,\ 8,\ 12,\ 24,\ 40,\ 80,\ 128,\ 256,\ 512,\ 1024,\ 2048,\ 4096,\ 8192,\ \dots$$

Stare at the front of the list and you will feel your intuition slip. From $6$ to $8$ is a jump of $2$. From $8$ to $12$ is a jump of $4$. Then $12$ doubles to $24$, but $24$ does not double to $48$ — it becomes $40$. Then $40$ doubles to $80$. And then, from $80$, something clicks into place and never comes loose again. The next term is $128$, and after that every single value is exactly twice the one before it: $256$, $512$, $1024$, and onward, marching in flawless powers of two all the way up to $2097152 = 2^{21}$ and beyond.

This is the sequence that counts the **maximal number of "good" manifolds inside an $n$-nice polytope** — a quantity from high-dimensional geometry that measures how many well-behaved geometric pieces you can pack into a certain kind of idealized shape as the dimension $n$ climbs. The name is technical, but the phenomenon is universal: a system that behaves erratically while it is small, and then, past a certain size, settles into the cleanest possible law of growth.

The question this article answers is simple to state. *What is really going on in the tail of this sequence, and can we prove it beyond any doubt?* The answer is that from dimension seven onward, the count is exactly $2^n$ — no correction, no error term, no exceptions. Every added dimension doubles the number of good manifolds, forever.

## The shape of the problem

Let us name the sequence. Write $a(n)$ for the maximal number of good manifolds in an $n$-nice polytope. The tabulated data gives us

$$a(1)=6,\quad a(2)=8,\quad a(3)=12,\quad a(4)=24,\quad a(5)=40,\quad a(6)=80,$$

and then

$$a(7)=128,\quad a(8)=256,\quad a(9)=512,\quad \dots,\quad a(21)=2097152.$$

The first six values form what we will call the **head**: an irregular preamble where the count is still feeling out its own rules. Everything from $n=7$ onward is the **tail**, and the tail is where the magic lives.

The central claim is a genuine theorem, not a definition in disguise. If the closed form $2^n$ held for *every* dimension, it would be a tautology — we would simply have defined the sequence to be the powers of two. But it does not. At dimension five, for instance, $a(5) = 40$, while $2^5 = 32$. The head departs from the power law by a real, measurable amount. That departure is what turns "the tail is $2^n$" from a bookkeeping remark into a statement with content.

## The main theorem, stated plainly

**Closed form of the tail.** *For every dimension $n \ge 7$, the maximal number of good manifolds in an $n$-nice polytope is exactly $2^n$.*

From this single fact, a whole family of clean consequences unfolds — each one a different way of looking at the same underlying doubling.

**The doubling recurrence.** *For $n \ge 7$, we have $a(n+1) = 2\,a(n)$.* In words: each new dimension you add doubles the count. This is the sequence's engine. Once it turns over at dimension seven, it never stalls. The proof is a one-line consequence of the closed form, since $2^{n+1} = 2 \cdot 2^n$.

**Global strict monotonicity.** *The entire sequence — messy head and tidy tail together — is strictly increasing: $a(1) < a(2) < a(3) < \cdots$.* This is a subtler statement than the closed form, because it must span the ragged head, cross the junction at the seam between $n=6$ and $n=7$ (where $80 < 128$), and then ride the exponential tail upward. The head is checked value by value; the tail rises because doubling a positive number always makes it bigger. The two halves agree at the boundary, so the whole sequence climbs without a single misstep.

**Geometric partial sums.** *Summing the tail gives a geometric total:*
$$\sum_{k=7}^{m} a(k) = 2^{m+1} - 2^{7} = 2^{m+1} - 128 \qquad (m \ge 7).$$
This is the familiar fingerprint of a geometric series: add up powers of two and you land just shy of the next power of two. Adding $a(7)=128$ through $a(m)$ brings you to exactly $2^{m+1} - 128$.

## The arithmetic fingerprint

Here the story takes an unexpected turn, and combinatorics shakes hands with number theory. There is a way of measuring how deeply the number $2$ is woven into an integer, called the **$2$-adic valuation**. For a positive integer $N$, its $2$-adic valuation $v_2(N)$ is simply the number of times $2$ divides $N$ — the exponent of $2$ in its prime factorization. For example, $v_2(12) = 2$ because $12 = 2^2 \cdot 3$, and $v_2(40) = 3$ because $40 = 2^3 \cdot 5$.

Now apply this lens to the tail:

**Two-adic valuation equals dimension.** *For $n \ge 7$, we have $v_2\big(a(n)\big) = n$.*

This is striking. The count $a(n) = 2^n$ is a pure power of two, so its $2$-adic valuation is exactly $n$ — the dimension itself. The geometry of the polytope leaves an *arithmetic signature*: read off how many factors of two hide inside the count, and you recover the dimension you started from. A purely combinatorial quantity turns out to encode its own geometric origin in the language of prime factorization.

A gentler cousin of this observation is a fact that holds across the whole sequence, head included:

**Parity.** *Every positive-dimensional count $a(n)$ is even.* In the head this is checked directly ($6, 8, 12, 24, 40, 80$ are all even); in the tail it is automatic, since $2^n$ is even for $n \ge 1$.

## Why the head misbehaves — and why that is the point

It would be tempting to sweep the first six values under the rug as noise. But they are not noise; they are the visible edge of a deeper structure. Consider the **correction term**

$$d(n) = a(n) - 2^n.$$

By the closed-form theorem, $d(n) = 0$ for all $n \ge 7$. For the head, we compute

$$d(1)=4,\quad d(2)=4,\quad d(3)=4,\quad d(4)=8,\quad d(5)=8,\quad d(6)=16.$$

Look closely. The correction takes only the values $4$, $8$, and $16$ — themselves powers of two. And it holds each value over a contiguous block before jumping: $4$ appears three times, $8$ appears twice, $16$ appears once. The block lengths $3, 2, 1$ count down by one. The head, in other words, appears to be a *second, faster-decaying geometric layer* stacked underneath the dominant $2^n$ — a shadow that thins out and vanishes exactly when the main exponential term grows tall enough to overtake it. What looked like chaos is a smaller, quieter geometry hiding beneath a louder one.

This reframes the entire sequence. It is not "an exponential with some errors at the start." It is the sum of two competing exponential tendencies, one of which fades away, leaving the pure power law standing alone from dimension seven onward.

## The bigger picture

Why should anyone outside of polytope theory care that a particular geometric count doubles? Because the *pattern* is one of the most important in all of applied mathematics, and this sequence is a crisp, fully-proved instance of it.

Doubling is the mathematics of independent binary choices. If, in each new dimension, the geometry offers you a free two-way choice that does not interfere with the choices in other dimensions, the total count of configurations multiplies by two each time — and you get exactly $2^n$. The fact that the tail is *precisely* $2^n$, with no slack, is evidence that from dimension seven onward the choices decouple completely: each dimension contributes its own independent binary decision, uncorrelated with the rest. The messy head is the regime where the dimensions are still too few and too entangled for that clean independence to hold.

This suggests a bold organizing principle for the whole family of "nice" polytopes: **doubling is the fastest they can grow.** One expects that among all such families, the good-manifold count grows no faster than $2^n$ in the long run — that $\limsup a(n)^{1/n} = 2$ — with equality achieved by the very family studied here. A strictly faster rate would demand correlated choices across dimensions, precisely the kind of coordination that "niceness" is designed to rule out. The sequence we have dissected is, in this view, an extremal object: it grows as fast as the rules allow, and not one bit faster.

## The moral of the sequence

The story of $6, 8, 12, 24, 40, 80, 128, 256, \dots$ is the story of how order emerges from apparent disorder. A list that begins by breaking every pattern you try to impose on it turns out, past a modest threshold, to obey the simplest growth law there is. And the transition is not a fudge or an approximation — it is exact, provable, and permanent. From dimension seven to infinity, the count is $2^n$, it doubles each step, its running totals are geometric, and its prime factorization spells out the dimension in a code of nothing but twos.

Mathematics is full of sequences that flirt with regularity and never quite commit. This one commits. It reminds us that "irregular at first" and "perfectly regular forever after" are not contradictions but two chapters of a single, elegant tale — and that sometimes the most satisfying thing a wild sequence can do is, eventually, settle down and count in powers of two.
