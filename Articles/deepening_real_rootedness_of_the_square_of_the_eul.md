# When a Triangle Squares Its Roots: A Story of Descents, Polynomials, and Real Numbers

## A pattern hiding in permutations

Take the numbers $1, 2, 3$ and write them in some order. One arrangement is $1\,3\,2$; another is $3\,2\,1$. Somewhere in each list, a number may be followed by a smaller number — a moment where the sequence "steps down." Mathematicians call such a step a **descent**. In $1\,3\,2$ there is exactly one descent (from $3$ to $2$). In $3\,2\,1$ there are two.

If you sort all $n!$ orderings of $\{1, 2, \dots, n\}$ by how many descents they contain, you get a beautifully symmetric list of counts. The number of orderings of $\{1, \dots, n\}$ with exactly $k$ descents is the **Eulerian number** $A(n,k)$, named after Leonhard Euler, who first studied it in the eighteenth century. Written out in rows, these numbers form a triangle:

$$
\begin{array}{ccccccc}
 & & & 1 & & & \\
 & & 1 & & 1 & & \\
 & 1 & & 4 & & 1 & \\
1 & & 11 & & 11 & & 1
\end{array}
$$

The rows are palindromes (reversing an ordering swaps ascents and descents), the entries add up to $n!$, and they satisfy the tidy recurrence
$$
A(n,k) = (k+1)\,A(n-1,k) + (n-k)\,A(n-1,k-1).
$$

The Eulerian triangle is one of the crown jewels of combinatorics, cousin to Pascal's triangle. And like Pascal's triangle, it has a secret life as a family of **polynomials**.

## From a triangle to polynomials

Every row of a number triangle can be packed into a single polynomial by using the entries as coefficients. The $n$-th row of the Eulerian triangle becomes the **Eulerian polynomial**
$$
A_n(x) = \sum_{k} A(n,k)\, x^k.
$$
For instance, $A_3(x) = 1 + 4x + x^2$ and $A_4(x) = 1 + 11x + 11x^2 + x^3$.

These polynomials have a remarkable and famous property: **all of their roots are real**. A polynomial like $x^2 + 1$ has no real roots at all (its zeros are the imaginary numbers $\pm i$), and most polynomials you write down at random will have some complex roots lurking off the real line. But the Eulerian polynomials never do. Every one of them factors completely into pieces of the form $(x - r)$ with $r$ a real, in fact negative, number. This "real-rootedness" is not a coincidence — it is a deep structural fact, and it forces the Eulerian numbers within each row to be **log-concave** and **unimodal**: they rise smoothly to a peak in the middle and fall back down, never wobbling.

Real-rootedness is one of the most sought-after properties in modern combinatorics. It is the engine behind central limit theorems for combinatorial statistics, behind inequalities among counting sequences, and behind surprising bridges to geometry and probability. So a natural and tempting game is to *build new triangles out of old ones* and ask whether the magic survives.

## Squaring the triangle

Here is the twist at the heart of this work. Think of the Eulerian triangle as an infinite lower-triangular matrix $T$, with $T_{n,k} = A(n,k)$. Matrices can be multiplied — and in particular, a matrix can be multiplied by itself. **What happens when you square the Eulerian triangle?**

The squared triangle has entries
$$
C(n,k) = \sum_{j} A(n,j)\, A(j,k),
$$
a kind of two-step count: first descend from level $n$ to some intermediate level $j$, then from $j$ down to $k$. Collecting each row into a polynomial gives the objects we care about:
$$
B_n(x) = \sum_k C(n,k)\, x^k.
$$

The first few are innocent-looking:
$$
B_3(x) = 6 + x, \qquad B_4(x) = 24 + 15x + x^2, \qquad B_5(x) = 120 + 181x + 37x^2 + x^3.
$$

Two features jump out immediately. First, the constant term is always $n!$ — because summing an entire Eulerian row gives $n!$, and $C(n,0)$ is exactly that sum. Second, each $B_n$ turns out to be **monic** (leading coefficient $1$) of degree $n-2$, with strictly positive integer coefficients throughout.

The burning question is the same one the Eulerian polynomials answered so elegantly:

> **Does squaring preserve real-rootedness? Are all the roots of $B_n$ real?**

This is subtle. Multiplying two matrices scrambles their algebraic structure, and there is no general theorem that says "a product of nice triangles is nice." Squares of famous triangles do not automatically inherit the good behavior of their parents. So the question is genuinely open in general — and this article tells the story of how far it can be pushed.

## Three keys to the puzzle

### Key 1: The squared polynomial is really a blend of Eulerian polynomials

The first breakthrough is an exact identity that rewrites the mysterious $B_n$ in familiar terms:
$$
\boxed{\,B_n(x) = \sum_{j} A(n,j)\, A_j(x)\,.}
$$

In words: the $n$-th row polynomial of the squared triangle is a **weighted blend of the original Eulerian polynomials**, where the weights are precisely the Eulerian numbers $A(n,j)$ from row $n$. Because those weights are nonnegative, $B_n$ is a *nonnegative combination* of polynomials each of which is real-rooted.

The proof is a clean bookkeeping argument. Expand $B_n(x) = \sum_k \left(\sum_j A(n,j)A(j,k)\right)x^k$, swap the order of the two sums, and recognize the inner sum over $k$ as the Eulerian polynomial $A_j(x)$ — after noting that $A(j,k)=0$ whenever $k$ exceeds $j$, so the truncated and full sums agree. The identity turns an opaque matrix-square into a transparent superposition of well-understood building blocks.

This is more than cosmetic. It reframes the whole conjecture: proving that *every* $B_n$ is real-rooted reduces to showing that the Eulerian polynomials are **compatible** — that any nonnegative blend of them stays real-rooted. Compatibility is a known and powerful phenomenon (it follows when the polynomials *interlace*, weaving their roots together like fingers of clasped hands), and this identity is the doorway to it.

### Key 2: Every root that exists must be negative

The second result is sweeping and unconditional — it holds for **every** $n$, with no exceptions and no computation:

> **All real roots of $B_n$ are strictly negative.**

The reasoning is disarmingly simple. Every coefficient of $B_n$ is a nonnegative integer, and its constant term $n!$ is strictly positive. So if you plug in any nonnegative number $x \ge 0$, every term $C(n,k)x^k$ is nonnegative and the constant term is genuinely positive — the whole sum is strictly greater than zero. A polynomial that is strictly positive on the entire nonnegative axis can only cross zero on the *negative* side. Therefore no root of $B_n$ can be zero or positive.

This does not by itself prove that the roots are real. But it pins down exactly *where* the real roots must live — always to the left of zero — and it tells us that if the full conjecture is true, then $B_n$ factors into pieces $(x+r)$ with every $r > 0$. That negativity is confirmed by every explicit case we compute.

### Key 3: Breaking through the wall at $n = 8$

There is a classic hands-on technique for *proving* a specific polynomial is real-rooted without ever computing its roots: **bracketing**. If you can find a ladder of test points $t_0 > t_1 > \cdots$ at which the polynomial alternates in sign, then by the intermediate value theorem a root is trapped between each consecutive pair. Trap enough roots, and — since a degree-$d$ polynomial has at most $d$ roots — you have accounted for all of them, and all are real.

For the squared Eulerian polynomials, the roots spread out enough that for small $n$ you can use **whole integers** as your ladder: $-1, -2, -3, \dots$ neatly separate the roots. This works cleanly up to $n = 7$. But at $n = 8$ the technique hits a wall. The polynomial $B_8$ has **two** distinct roots squeezed into the tiny interval $(-1, 0)$ — approximately $-0.79$ and $-0.14$. No integer sits between them, so integer sign-changes can no longer tell the two roots apart. This is exactly the boundary where the elementary method breaks down.

The fix is to refine the ladder. By allowing **rational** test points — fractions like $-\tfrac{1}{2}$ that slip into the crowded region near zero — one can once again separate every root and certify real-rootedness. Pushing this through gives real-rootedness for $n = 8$, and then for $n = 9$ and $n = 10$ as well, each of which likewise packs two roots into $(-1,0)$. Every one of those roots is real and negative, exactly as Key 2 predicted.

So the frontier moves from "proved up to $n = 7$" to "proved up to $n = 10$," and — just as importantly — the *reason* the old method stalled is now understood: the smallest roots drift steadily toward zero as $n$ grows, clustering ever more tightly, so any purely integer ladder is eventually doomed.

## Why this matters beyond the triangle

At first glance this might look like a self-contained puzzle about a curious array of numbers. But real-rootedness is a currency that trades across all of mathematics.

When a counting sequence is the coefficient list of a real-rooted polynomial, powerful consequences follow automatically: the sequence is log-concave and unimodal, its statistics obey a central limit theorem, and it satisfies a web of classical inequalities. The Eulerian numbers themselves govern the distribution of descents in random permutations — a quantity that shows up in the analysis of sorting algorithms, in the theory of random sorting networks, and in nonparametric statistics. Squaring the triangle corresponds to composing these descent statistics in two stages, and asking whether real-rootedness survives is asking whether this composed structure remains "as well-behaved as possible."

The techniques on display are a microcosm of a whole subfield. The **structural identity** exemplifies the modern strategy of reducing a hard real-rootedness question to a *compatibility* or *interlacing* statement about a generating family — the same philosophy that underlies celebrated results connecting polynomials to matchings, matroids, and even the resolution of long-standing problems in operator theory. The **positivity argument** is the humblest and most robust of tools, yet it settles the location of the roots in a single line. And the **bracketing method** is a reminder that, even in an age of abstraction, a well-chosen ladder of numbers can still corner a proof.

## The honest edge of knowledge

What remains open is the full conjecture: that $B_n$ is real-rooted for *every* $n$, not just up to $n = 10$. The structural identity tells us the cleanest path — establish that the Eulerian polynomials mutually interlace, so that every nonnegative blend of them inherits real-rootedness — and this in turn would follow from tracking how interlacing is preserved by the Eulerian recurrence. That last step is the missing keystone.

There is a natural sequel, too. Why stop at squaring? One can raise the Eulerian triangle to any power $T^m$, and the same identity generalizes into a recursion linking the $m$-th power to the $(m-1)$-th. If the interlacing keystone were in place, an induction on $m$ might settle real-rootedness for *all* powers at once — and the very same machinery would apply to the squares of the Pascal, Stirling, and Narayana triangles, other beloved arrays whose polynomial rows are real-rooted.

For now, the picture is this: a triangle born from counting descents, squared into a new triangle, gives polynomials whose roots — as far as we can compute and prove — are all real, all negative, and all telling us that the deep order of the Eulerian numbers is remarkably hard to destroy. The wall at $n = 8$ has been breached; the smallest roots drift toward zero but never reach it; and a single elegant identity quietly promises that the whole infinite family may yet fall into line.
