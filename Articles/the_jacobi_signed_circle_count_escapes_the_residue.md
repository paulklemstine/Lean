# A Circle That Refuses to Tell You Its Secret

## The dream of a cheap witness

Suppose someone hands you a very large odd number $N$ and tells you it is the product of two primes, $N = pq$, but refuses to say which ones. Factoring $N$ is, as far as anyone knows, hard. But hardness is a statement about *all* methods, and mathematicians are professional optimists. So we ask a narrower question: is there some cheap, natural quantity attached to $N$ — a count, a sum, a statistic — that quietly *knows* something about $p$ and $q$?

This is the story of one such candidate, and of exactly how, and exactly why, it fails. The failure turns out to be far more interesting than a success would have been suspenseful, because it is not a failure of ingenuity. It is a wall built out of a hundred-year-old theorem about counting points on curves, and the wall is *exactly* the right height.

## Circles in clock arithmetic

Start with something familiar: the unit circle $x^2 + y^2 = 1$. Now do arithmetic modulo $N$ — clock arithmetic, where numbers wrap around after $N$. The "circle" becomes a finite set of points,
$$S(N) = \{(x,y) : x,y \in \mathbb{Z}/N\mathbb{Z},\ x^2 + y^2 = 1\}.$$
It is not round; it is a scatter of dots. But it inherits a startling amount of the real circle's structure — it has a group law (the addition formulas for sine and cosine still work), and its size is governed by beautiful arithmetic rules.

Counting the dots is the obvious first move, and it has been tried. The trouble is that the raw count $|S(N)|$ is a **residue dial**: for $N = pq$ it works out to something like $(p - \varepsilon_p)(q - \varepsilon_q)$ where each $\varepsilon$ is determined by whether the prime is $1$ or $3$ modulo $4$. So the count tells you $N$, which you already knew, times a tiny correction determined by $N \bmod 4$ — which you also already knew. Everything you can read off the dial, you could have read off the number itself. A dial is a witness that only repeats your own question back to you.

Several natural refinements — counting points of binary quadratic forms, counting Gaussian-integer solutions, various weighted point counts — all collapsed the same way, into functions of $N \bmod 4$ or $N \bmod 8$. The dial seemed inescapable.

## Adding a sign

Here is the idea that breaks the dial. Instead of counting each point of the circle as $1$, count it with a **sign** determined by its $x$-coordinate. The sign is the Jacobi symbol $\left(\frac{x}{N}\right)$, which is $+1$ or $-1$ according to a subtle multiplicative rule and which, for a prime modulus $p$, simply records whether $x$ is a perfect square modulo $p$ (a *quadratic residue*, sign $+1$) or not (sign $-1$), with the value $0$ when $x \equiv 0$.

So define the **Jacobi-signed circle count**
$$W(N) = \sum_{(x,y)\,\in\, S(N)} \left(\frac{x}{N}\right).$$

Massive cancellation is now built in: roughly half the points get $+1$ and half get $-1$, and what survives is a delicate residue of arithmetic bias. The question is whether that residue remembers $p$ and $q$.

## First surprise: the circle collapses to a curve

The two-dimensional sum is really one-dimensional. Fix $x$ and ask how many $y$ satisfy $y^2 = 1 - x^2$ modulo a prime $p$. The answer is $\chi(1-x^2) + 1$, where $\chi$ is the sign function above: two roots if $1-x^2$ is a nonzero square, none if it is a nonsquare, one if it is zero. Summing $y$ away and using the fact that the signs of all residues cancel ($\sum_x \chi(x) = 0$), the circle count becomes a **cubic character sum**:

> **Theorem (Collapse to a cubic sum).** For every odd prime $p$,
> $$W(p) = \sum_{x \bmod p} \chi\bigl(x(1-x^2)\bigr).$$

The right-hand side is, up to sign, the trace of Frobenius of the elliptic curve $y^2 = x - x^3$. Our innocent signed dot-count on a circle is secretly counting points on a curve of genus one — and that is the first hint of the wall to come, because point counts on such curves are governed by one of the sharpest estimates in number theory.

## Second surprise: it factors

Now the Chinese Remainder Theorem enters. A point on the circle mod $pq$ is exactly a pair consisting of a point mod $p$ and a point mod $q$; and the Jacobi symbol mod $pq$ is the product of the Legendre symbols mod $p$ and mod $q$. Multiply and sum:

> **Theorem (Multiplicativity).** If $m$ and $n$ are coprime then $W(mn) = W(m)\,W(n)$. In particular, for a semiprime $N = pq$ with $p \neq q$,
> $$W(N) = W(p)\cdot W(q).$$

This is genuinely good news and genuinely bad news at once. Good: the statistic is *factor-dependent* — it is literally built out of data belonging to $p$ and to $q$ separately, which the raw dial never was. Bad: it is a **symmetric product**. Knowing the number $W(N) = W(p)W(q)$ is like knowing the product of two unknown integers. You have merely traded one factoring problem for another, in a smaller and noisier arena.

## Third surprise: half the primes say nothing at all

Replace $x$ by $-x$ in the cubic sum. The term $x(1-x^2)$ becomes $-x(1-x^2)$, so the whole sum gets multiplied by $\chi(-1)$. When $p \equiv 3 \pmod 4$, $-1$ is a nonsquare and $\chi(-1) = -1$, so $W(p) = -W(p)$:

> **Theorem (Vanishing).** If $p \equiv 3 \pmod 4$ then $W(p) = 0$. Consequently $W(N) = 0$ for every $N$ divisible by such a prime.

Three quarters of all semiprimes — every one with at least one factor $\equiv 3 \pmod 4$ — return exactly zero. On these, the statistic is stone blind. There is an infinite family, $N = 3q$, on which the answer is $0$ no matter how large $q$ gets; $W(15) = W(21) = 0$, so two different semiprimes already collide. Whatever information exists, it lives on the quarter of semiprimes with both factors $\equiv 1 \pmod 4$.

## The dial is broken — and it doesn't help

Here is the moment the experiment was designed for. Is $W$ just another dial in disguise? No, and one can see it by hand. Both $17$ and $41$ are $\equiv 1 \pmod 8$, yet
$$W(17) = -2, \qquad W(41) = -10.$$
No function of $p \bmod 8$ can produce both. Similarly $W(13) = -6$ but $W(17) = -2$, killing the mod-$4$ dial; and at composite level, $21$ and $85$ are both $\equiv 5 \pmod 8$ while $W(21) = 0$ and $W(85) = -4$. The values on primes $\equiv 1 \pmod 8$ run $-2, -10, 6, -18, 14, 22, \ldots$ — visibly not a constant.

**The character weight escapes the dial collapse.** For the first time in this family of witnesses, the statistic sees something beyond the residue class of $N$.

And yet: it sees nothing *useful*. Across forty semiprimes with both factors $\equiv 1 \pmod 4$, the correlation of $W(N)$ with $p$, with $q$, with $p+q$ and with $|p-q|$ sits comfortably inside the permutation null distribution — observed magnitudes well under $0.25$ against a $95$th-percentile threshold near $0.30$. Factor-dependent, yes. Structured, no. The signal is *there* and it is *noise*.

## The wall: why the noise floor is exactly $\sqrt{N}$

Why should this be? Because of a bound, and — more beautifully — because of an identity that the bound is a shadow of.

For each $d$, consider the twisted sum $A(d) = \sum_x \chi(x^3 - dx)$; our statistic is $A(1)$ when $p \equiv 1 \pmod 4$. A short computation with quadratic character sums gives an **exact second moment**:
$$\sum_{d \bmod p} A(d)^2 = 2p(p-1).$$
Since scaling $d$ by a square barely changes $A(d)$ — precisely, $A(c^2 d) = \chi(c) A(d)$ — the $p-1$ nonzero scalings all contribute the same square, and comparing with the moment yields

> **Theorem (Weil floor).** For every odd prime $p$, $\;W(p)^2 \le 4p$, that is $|W(p)| \le 2\sqrt{p}$. Hence for a semiprime $N = pq$,
> $$|W(N)| \le 4\sqrt{N}.$$

This is the Weil bound for the curve, obtained here by pure averaging, and it is not slack: $W(173) = 26$ against $2\sqrt{173} \approx 26.3$, and $W(293) = 34 = 2\cdot 17$ against $2\sqrt{293} \approx 34.2$. No constant better than $0.977 \times 4$ can replace the $4$.

The real reason the bound is tight is an exact identity. Let $\nu$ be any nonsquare modulo $p$. Then, for $p \equiv 1 \pmod 4$,
$$A(1)^2 + A(\nu)^2 = 4p.$$
The residue twist and the nonresidue twist are the two legs of a right triangle with hypotenuse $2\sqrt{p}$. This is a form of the classical Jacobsthal identity, and it does something lovely: since $W(p) = A(1)$ is even, and so is $A(\nu)$, dividing by $2$ gives

> **Theorem (Fermat's two-square theorem, with explicit witnesses).** For $p \equiv 1 \pmod 4$, writing $a = W(p)/2$ and $b = A(\nu)/2$,
> $$p = a^2 + b^2,$$
> and moreover $a$ is odd — indeed $W(p) \equiv 2 \pmod 4$ always.

So the mysterious, erratic statistic is nothing other than **twice the odd leg of the Gaussian-integer decomposition of $p$**. Check it: $17 = 1^2 + 4^2$ and $W(17) = -2$; $41 = 5^2 + 4^2$ and $W(41) = -10$; $173 = 13^2 + 2^2$ and $W(173) = 26$; $293 = 17^2 + 2^2$ and $W(293) = 34$. Every value in the data set is $2a$ with $p = a^2 + b^2$, $a$ odd.

## The shape of the failure

Now the whole picture snaps into focus, and it is a picture of three walls stacked in a row.

**The cost wall.** Evaluating $W(N)$ honestly requires walking through the residues modulo $N$: about $N$ operations. Any witness that costs $N$ to read has already lost to trial division, which costs $\sqrt{N}$.

**The symmetry wall.** $W(N) = W(p)W(q)$ is a symmetric product. The statistic never sees $p$ and $q$ apart; it sees only their entangled product. Extracting the factors from the product is the original problem, in miniature.

**The Weil floor.** The value lives in a window of width $O(\sqrt{N})$ inside a search space of size $N$. Its *relative* information density is $N^{-1/2}$ — vanishing. And the two-leg identity explains why no clever rescaling helps: $a^2 + b^2 = p$ is a conservation law, and a witness reading only one leg is reading a projection of a conserved quantity. A big signal in $a$ is compensated by a small one in $b$, always, with $4p$ fixed. There is no direction in which the signal grows.

## Why a negative result is worth telling

The verdict on the Jacobi-signed circle count as a factoring aid is: refuted. But the *manner* of refutation is a new entry in a taxonomy of failures, and taxonomies are how a field learns where not to dig.

Earlier weighted counts died of dial collapse: they were functions of $N \bmod 8$, carrying literally zero new information. This one does not die that way. It genuinely escapes the dial — and then dies of something deeper and much harder to argue with. It hits the square-root barrier of character sums, the same barrier that makes Legendre symbols look random, that underwrites the pseudorandomness of quadratic residues, that makes elliptic-curve cryptography plausible.

There is a general principle lurking here, and it is worth stating plainly. Summing $y$ away turns *any* character-weighted circle count into a Jacobi-type sum, and Jacobi sums have absolute value exactly $\sqrt{p}$. The square-root floor is a property **of the circle**, not of the weight you choose. Changing the sign function is rearranging deck chairs; the ship is the geometry.

And the consolation prize is genuinely charming: in trying to build a factoring witness, we ended up with a clean, self-contained proof that every prime $p \equiv 1 \pmod 4$ is a sum of two squares — with the odd leg handed to us explicitly as half a signed count of lattice points on a circle. Fermat would, I think, have enjoyed that. The circle would not give up the secret we asked for. It gave up a better-known one instead, and told us, in the sharpest possible terms, exactly why the first secret is safe.
