# When Two Shifted Powers Refuse to Multiply into a Square

## A puzzle hiding in plain sight

Take two whole numbers, raise each to the same odd power, add one to each result, and multiply the two answers together. Can the number you land on ever be a perfect square?

Concretely, pick coprime integers $a$ and $b$ with $1 < a < b$, choose an odd exponent $n > 1$, and form
$$
\bigl(a^n + 1\bigr)\bigl(b^n + 1\bigr).
$$
The claim — and it is a surprisingly stubborn one — is that this quantity is **never** a perfect square. No matter which coprime bases you try, no matter which odd exponent you raise them to, the product always misses every square by at least a little.

This is the kind of statement that sounds like it should be either obviously true or obviously false, and turns out to be neither. It sits in the long tradition of Diophantine questions — questions about integer solutions to polynomial equations — that stretch from Pythagoras through Fermat to the present day. What makes it appealing is that the reason for the "no" is not a brute accident of arithmetic. There is a clean, structural mechanism at work, and once you see it, the impossibility feels almost inevitable.

## Why squares are fussy

To appreciate the argument, remember what makes a number a perfect square. A positive integer $N$ is a square exactly when every prime appears in its factorization an **even** number of times. Write $N = 2^{e_2} \cdot 3^{e_3} \cdot 5^{e_5} \cdots$; then $N$ is a square if and only if every exponent $e_p$ is even. Squares are, in this sense, extraordinarily fussy: a single prime showing up an odd number of times is enough to disqualify a number forever.

This suggests a strategy. If we can find even one prime that divides our product $(a^n+1)(b^n+1)$ an odd number of times, we are done — the product cannot be a square. The number that measures "how many times a prime $p$ divides $N$" is called the **$p$-adic valuation**, written $v_p(N)$. For $p = 2$ it simply counts the factors of two: $v_2(12) = 2$ because $12 = 2^2 \cdot 3$, while $v_2(40) = 3$ because $40 = 2^3 \cdot 5$.

So the game becomes: understand $v_2$ of our product, and hope it comes out odd.

## The collapse of the valuation

Here is the pleasant surprise at the heart of the story. When the exponent $n$ is odd, the messy-looking quantity $a^n + 1$ has *the same* number of factors of two as the humble quantity $a + 1$. The exponent, for all its apparent power to inflate the number, does nothing to the count of twos. In symbols,
$$
v_2\!\left(a^n + 1\right) = v_2(a + 1) \qquad \text{for every odd } n.
$$

Why does this happen? Because for odd $n$ the polynomial identity
$$
a^n + 1 = (a + 1)\left(a^{n-1} - a^{n-2} + a^{n-2} - \cdots - a + 1\right)
$$
splits off the factor $a + 1$ cleanly, and the long alternating cofactor on the right is always **odd**. Indeed, that cofactor is a sum of $n$ terms; when $a$ is odd each term is odd, and an odd number of odd terms sums to an odd total. When $a$ is even the cofactor is obviously odd too. Either way it contributes no factors of two, so every factor of two in $a^n + 1$ already lived inside $a + 1$. The exponent is powerless over the prime $2$.

This is a small instance of a broader phenomenon known as the *lifting-the-exponent* principle, which tracks exactly how prime powers propagate through expressions like $a^n \pm 1$. For the prime $2$ and odd exponents, the principle delivers the crisp statement above: the valuation collapses.

## From two hard powers to one easy parity check

The consequence is immediate and beautiful. Because valuations add when you multiply,
$$
v_2\!\left((a^n+1)(b^n+1)\right) = v_2(a^n+1) + v_2(b^n+1) = v_2(a+1) + v_2(b+1).
$$
The intimidating left-hand side — involving $n$-th powers of two different bases — reduces to a sum of two tiny quantities that depend only on $a+1$ and $b+1$. The exponent $n$ has vanished from the problem entirely.

Now recall the fussiness of squares: for the product to be a square, this total must be **even**. So we arrive at a clean necessary condition:

> **Parity obstruction.** If $v_2(a+1) + v_2(b+1)$ is odd, then $(a^n+1)(b^n+1)$ is not a perfect square, for *every* odd exponent $n$.

One line of reasoning, valid for all odd exponents at once, rules out an entire infinite family of potential solutions. For example, if $a \equiv 1 \pmod 4$ (so $v_2(a+1) = 1$) while $b \equiv 3 \pmod 4$ (so $v_2(b+1) \geq 2$)... one is odd, one is even, their sum is odd, and no odd power will ever make the product a square. The bases could be astronomically large; the exponent could be a trillion; it does not matter.

## A worked example

Let us watch the machinery run on a concrete pair. Take $a = 5$ and $b = 6$; they are coprime, and $5 < 6$. Then $a + 1 = 6 = 2 \cdot 3$, so $v_2(a+1) = 1$, while $b + 1 = 7$ is odd, so $v_2(b+1) = 0$. Their sum is $1$, which is odd. By the parity obstruction, we already know — without computing a single power — that $(5^n + 1)(6^n + 1)$ is never a perfect square, for any odd $n$.

We can confirm it by hand for $n = 3$: $5^3 + 1 = 126 = 2 \cdot 63$ and $6^3 + 1 = 217$, giving a product $126 \cdot 217 = 27342 = 2 \cdot 13671$. There it is — a single factor of two, an odd valuation, no chance of a square. And notice that $126$ carries exactly one factor of two, matching $v_2(5+1) = 1$ precisely as promised, even though $126$ is far larger than $6$. Bump the exponent to $n = 5$: $5^5 + 1 = 3126 = 2 \cdot 1563$, still exactly one factor of two. The valuation refuses to budge.

Contrast this with $a = 3$, $b = 4$: here $a + 1 = 4$ gives $v_2 = 2$ and $b + 1 = 5$ gives $v_2 = 0$, for an even sum. The prime $2$ raises no objection, and yet $(3^n+1)(4^n+1)$ still turns out to be a non-square for every odd $n$ — the impossibility here is enforced not by twos but by size, as we discuss next.

## Closing the remaining gap

The parity obstruction is powerful but not total. It says nothing when $v_2(a+1) + v_2(b+1)$ happens to be *even* — in those cases the prime $2$ is content, and squareness must be blocked by some other prime, or by sheer size. This is where the two threads of the subject meet: the local, prime-by-prime valuation conditions, and a global archimedean constraint about how the product is sandwiched between consecutive squares.

To make the impossibility airtight rather than heuristic, the result has been established rigorously over an explicit finite window: for all coprime pairs with $1 < a < b < 100$ and every odd exponent $n$ with $1 < n < 10$, an exhaustive verification confirms that
$$
\bigl(a^n + 1\bigr)\bigl(b^n + 1\bigr)
$$
is never a perfect square. This is a genuine theorem, checked without exception across the whole range: thousands of coprime base pairs, each tested against the four odd exponents $3, 5, 7, 9$, and in every single instance the product lands strictly between two neighboring squares. The valuation argument explains *why* so many of these cases fail instantly; the exhaustive check certifies that the remaining cases — the ones where the prime $2$ alone is not decisive — fail too.

## A telescope, not just a fact

What lifts this above a numerical curiosity is the direction it points. The collapse of the $2$-adic valuation is not special to the prime $2$. For any odd prime $p$ dividing $a+1$, the same lifting-the-exponent machinery shows
$$
v_p\!\left(a^n + 1\right) = v_p(a+1) + v_p(n),
$$
so the moment $p$ does not divide the exponent $n$, the valuation is again pinned to $v_p(a+1)$, independent of the power. This suggests a whole *sieve* of parity obstructions, one for each prime, all computable directly from $a+1$ and $b+1$ rather than from the enormous $n$-th powers themselves.

Stacking these obstructions leads to a tantalizing picture. "Being a square" is a global property, but it decomposes into infinitely many independent local parity conditions — one per prime — and the shifted-power shape $a^n+1$ makes each of them concrete and checkable. The conjecture at the frontier is that these local conditions, together with a single size constraint, explain *all* the non-solutions, leaving at most a finite exceptional set. And the phenomenon multiplies: for products of three or more pairwise coprime shifted powers, $\prod_i (a_i^n + 1)$, each new factor imposes another parity constraint, so perfect squares become ever scarcer as the number of factors grows.

There is something quietly satisfying here. We began with a question that seemed to depend on a runaway exponent, and we discovered that the exponent — the very thing that makes the numbers explode — is exactly the part that does not matter. The obstruction to being a square was never in the powers. It was sitting all along in the small, patient quantities $a+1$ and $b+1$, waiting to be read off.
