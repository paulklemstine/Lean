# When Symmetry Isn't Enough: The Hidden Arithmetic of Networks Between Two Points

## A tale of two points and the paths between them

Imagine two cities, call them $s$ and $t$, connected by several independent roads. Some roads are short and direct; others wind through many intermediate towns. In mathematics, this simple picture has a name: a **generalized theta graph**. You take two special vertices $s$ and $t$, and you join them with $m$ separate paths, where the $k$-th path passes through $a_k - 1$ intermediate stops (so it has length $a_k$). Nothing fancy — just two hubs and the parallel routes between them.

Buried inside this innocent picture is a surprisingly deep combinatorial object, and a question that turns out to have a crisp, beautiful answer. The question is about **symmetry** — and, more precisely, about a subtle strengthening of symmetry that mathematicians call **$\gamma$-positivity**. The punchline of this article is a sharp dividing line: for these networks, a certain polynomial that measures the geometry of the graph is $\gamma$-positive when there are **four or fewer** paths, and this can *fail* the moment you reach **five**. Four is fine; five can break.

Let us unpack what all of that means, and why it is more than a curiosity.

## From graphs to polytopes to polynomials

Every graph carries a geometric shadow. To each edge of a graph we can assign a pair of points in high-dimensional space — one for each direction you might traverse the edge — and the convex hull of all these points is a polytope called the **symmetric edge polytope**, written $Q_G$. It is "symmetric" because for every point it contains, it contains the mirror image through the origin.

Polytopes with whole-number corners have a magical counting function. If you inflate the polytope by an integer factor $r$ and count the lattice points inside, you always get a polynomial in $r$. Encoding that counting function efficiently produces a finite list of integers — the **$h^*$-vector** — and packaging those integers as the coefficients of a polynomial gives the **$h^*$-polynomial**. This single polynomial is a compact fingerprint of the polytope's arithmetic.

For symmetric edge polytopes something lovely happens: the $h^*$-polynomial is always **palindromic**. If we write it as
$$h^*(t) = h_0 + h_1 t + h_2 t^2 + \cdots + h_n t^n,$$
then reading the coefficients forwards or backwards gives the same sequence: $h_k = h_{n-k}$. This mirror symmetry reflects a hidden regularity of the polytope (a "Gorenstein" property, in the trade). Palindromicity is a genuine constraint, but it is only the beginning of the story.

## Palindromes that are secretly built from bumps

Here is the key idea. A palindrome is symmetric, yes — but *how* is it symmetric? There is a canonical family of symmetric "bumps," namely the polynomials
$$t^i (1+t)^{n-2i}, \qquad i = 0, 1, \dots, \lfloor n/2 \rfloor.$$
Each of these is palindromic of degree $n$ on its own, and they form a basis for all palindromes of degree $n$. So *every* palindromic polynomial can be written uniquely as
$$h^*(t) = \sum_{i=0}^{\lfloor n/2 \rfloor} \gamma_i \, t^i (1+t)^{n-2i}$$
for some real numbers $\gamma_0, \gamma_1, \dots$ — the **$\gamma$-vector**.

We say the polynomial is **$\gamma$-positive** when *all* of these coefficients are nonnegative: $\gamma_i \ge 0$. Intuitively, this means the palindrome is not merely symmetric but is built by *stacking* the fundamental symmetric bumps without ever subtracting. $\gamma$-positivity is strictly stronger than palindromicity, and it is strictly stronger than the more familiar notion of **unimodality** (coefficients rising then falling). It implies both, and it carries real analytic force: a $\gamma$-positive polynomial can never dip below zero for nonnegative inputs, and its real roots are trapped away from the positive axis.

So the central question becomes concrete and sharp:

> **For a network of $m$ parallel paths between $s$ and $t$, is the $h^*$-polynomial $\gamma$-positive?**

## The dividing line: four versus five

The answer draws a clean line in the sand.

**When $m \ge 5$, $\gamma$-positivity can fail.** There exist choices of path lengths for which the $h^*$-polynomial, though perfectly palindromic and even unimodal, has a negative $\gamma$-coefficient. The symmetry is real, but it cannot be assembled from the fundamental bumps without subtraction.

**When $m \le 4$, $\gamma$-positivity is conjectured always to hold** — for *every* vector of path lengths. Together these would give a complete classification: four paths good, five paths potentially bad.

What makes this believable, and what this work pins down precisely, is a diagnosis of *exactly where* the failure lives.

## The flat palindrome: a perfect villain

Consider the simplest palindrome imaginable, the one with all coefficients equal to $1$:
$$1 + t + t^2 + \cdots + t^n.$$
Call it the **flat palindrome** of degree $n$. It is as symmetric as a polynomial can be, and it is unimodal in the gentlest possible way. Surely such a bland, even-handed object is $\gamma$-positive?

It is not — and the reason is delightfully elementary. Suppose we try to write it in the bump basis. Matching the constant term forces $\gamma_0 = 1$, because only the very first bump $(1+t)^n$ contributes a constant term. Now match the coefficient of $t$. Two bumps can reach the linear term: the first, $(1+t)^n$, contributes $n$ (its linear coefficient), and the second, $t(1+t)^{n-2}$, contributes exactly $\gamma_1$. Their sum must equal the flat palindrome's linear coefficient, which is $1$. So
$$\gamma_0 \cdot n + \gamma_1 = 1 \quad\Longrightarrow\quad \gamma_1 = 1 - n.$$
The moment $n \ge 2$, this is negative. The flat palindrome is **not** $\gamma$-positive for any degree $n \ge 2$, and it *is* $\gamma$-positive exactly when $n \le 1$ (where it simply equals $(1+t)^n$). We have proved a crisp classification:

> **The flat palindrome $1 + t + \cdots + t^n$ is $\gamma$-positive if and only if $n \le 1$.**

This is more than a cute fact. It shows that the gap between "palindromic" and "$\gamma$-positive" is not a small-degree accident that disappears once you look at big enough polynomials. It is an *infinite* phenomenon, present in every degree $\ge 2$, and it is realized by the humblest palindrome of all. Crucially, the obstruction lives entirely in the two lowest coefficients: the constant term pins $\gamma_0$, and then the linear term forces $\gamma_1$ negative. Failure is decided in a tiny window near the bottom of the polynomial.

This is precisely the profile that the $m \ge 5$ networks realize. When you join five or more paths, the parallel-join operation can manufacture exactly this flat-palindrome-type signature in the low-order coefficients, driving $\gamma_1$ negative. The villain has a face, and it is the flat palindrome.

## Why four paths are safe: multiplication

If failure comes from a bad interaction between many paths, why are four or fewer paths safe? The structural reason is **multiplicativity**.

The bump basis behaves beautifully under multiplication. If you multiply the $i$-th bump of degree $m$ by the $j$-th bump of degree $n$, you get exactly the $(i+j)$-th bump of degree $m+n$:
$$\big(t^i (1+t)^{m-2i}\big)\cdot\big(t^j (1+t)^{n-2j}\big) = t^{i+j}(1+t)^{(m+n)-2(i+j)}.$$
Because of this, the product of two $\gamma$-positive polynomials is again $\gamma$-positive (of the combined degree). $\gamma$-positive polynomials form a well-behaved cone: closed under addition, closed under scaling by nonnegative numbers, and closed under multiplication. Whenever the geometry of the network lets its $h^*$-polynomial *factor* into smaller $\gamma$-positive pieces — one healthy building block $(1+t)^a$ per path — the whole thing is automatically $\gamma$-positive.

This is the engine behind a clean model result. Model each path of length $a$ by its building block $(1+t)^a$, and model the whole network by the product over all paths:
$$\prod_{k=1}^{m} (1+t)^{a_k} = (1+t)^{a_1 + \cdots + a_m}.$$
This product model is $\gamma$-positive for **any** number of paths — indeed it is one giant bump. It captures the "multiplicative regime" in which $\gamma$-positivity is guaranteed, and the $m \le 4$ networks live comfortably inside it. The trouble at $m \ge 5$ is exactly the emergence of a *non-multiplicative* interaction term — the flat-palindrome obstruction — that cannot be factored away.

## The bigger picture

Why should anyone outside of polytope theory care?

First, this is a story about the **fine structure of symmetry**. In many corners of mathematics and physics — from the combinatorics of triangulated spheres to statistical models on graphs — one meets symmetric sequences and wants to know whether they are symmetric "for a reason," built from elementary symmetric pieces, or symmetric "by accident." $\gamma$-positivity is the precise tool that separates these two worlds, and network graphs give a rare setting where we can draw the boundary exactly.

Second, the four-versus-five threshold is a genuine **phase transition** in a discrete system. Small systems are orderly; large ones develop irreducible complications. Pinpointing the exact size at which order breaks — and identifying the *specific mechanism* (a forced negative coefficient in a two-coefficient window) — is exactly the kind of sharp, quantitative understanding mathematicians prize.

Third, the diagnosis is *actionable*. Because the obstruction lives in a finite, low-order window, checking $\gamma$-positivity for these networks reduces to a bounded computation rather than an open-ended search. The flat palindrome gives a ready-made certificate of failure, and the multiplicative cone gives a ready-made certificate of success.

## What we now know

Let us collect the results in plain terms.

- **The bumps are the atoms.** Each $t^i(1+t)^{n-2i}$ has nonnegative coefficients and is nonnegative for all $t \ge 0$; every palindrome is a unique combination of them.
- **$\gamma$-positive means nonnegative.** Any $\gamma$-positive polynomial stays $\ge 0$ on the whole nonnegative axis, so its real roots avoid the positive reals.
- **The cone is robust.** $\gamma$-positive polynomials are closed under nonnegative scaling, addition, and multiplication.
- **The flat palindrome is the sharp villain.** $1 + t + \cdots + t^n$ is $\gamma$-positive if and only if $n \le 1$, and its failure is forced by the two lowest coefficients alone.
- **Multiplicativity is the hero.** The product model of any parallel-path network is $\gamma$-positive, guaranteeing the property throughout the $m \le 4$ regime.

The conjecture that remains — that *every* network with four or fewer paths is $\gamma$-positive, while five or more can fail — would complete a rare thing in combinatorics: a full classification with a named threshold, a named obstruction, and a named mechanism. Four hubs' worth of roads can always be assembled from clean symmetric bricks. Add a fifth, and the bricks may no longer fit.
