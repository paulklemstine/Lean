# The Pole You Cannot Hide

## How one integer survives every disguise you can put on a power series

### A number that refuses to be erased

Imagine you are handed a mathematical object that has been deliberately disguised. Someone has scrambled it, multiplied it by noise, added junk to it, raised it to a large power — everything short of destroying it outright. You are asked: can you still say something certain about what you were given?

Usually the answer is no. Disguise is cheap; certainty is expensive. But there are rare situations in mathematics where a single number clings to an object through every transformation of a whole family, like a watermark that survives photocopying. This article is about one such number, and about a place where it shows up in spectacular fashion: the arithmetic of *moonshine*, the strange bridge between the largest sporadic finite simple group and the theory of modular functions.

The number in question is called the **order of a pole**, and the punchline is easy to state. Take $194$ specially normalized series — one for each conjugacy class of the Monster group — and multiply them together. The result has a pole of order exactly $194$: it blows up like $q^{-194}$ as $q \to 0$. Not approximately $194$. Not "at most" $194$. Exactly $194$. And no amount of blinding, masking, noise, or exponentiation can shift that number by even one. To remove it you must multiply by $q^{194}$, and that is the *only* monomial that will do it.

That rigidity is what makes the story interesting — and what makes it read, unexpectedly, like cryptography.

### The playground: formal Laurent series

Everything happens in the world of **formal Laurent series** in a variable $q$: expressions
$$f = \sum_{n \ge n_0} a_n q^n,$$
where $n_0$ is any integer, possibly negative, and the coefficients $a_n$ are complex numbers. "Formal" means we never worry about convergence; we treat these as algebraic bookkeeping devices. They can be added, multiplied, and — crucially — divided, provided they are not zero. The collection of all of them forms a field, written $\mathbb{C}(\!(q)\!)$.

Every nonzero Laurent series has an **order**: the smallest exponent $n$ that actually appears with a nonzero coefficient. A series with order $-3$ has a pole of order $3$ at $q = 0$; a series with order $+5$ has a zero of order $5$; a series with order $0$ is finite and nonzero there. The single most important fact about order is that it turns multiplication into addition:
$$\operatorname{ord}(fg) = \operatorname{ord}(f) + \operatorname{ord}(g).$$
This is exactly the behaviour of a logarithm, and it is the source of everything that follows. Order is a *valuation*: an algebraic ruler measuring how singular a series is at the origin.

### Normalized series and the moonshine convention

In moonshine one deals with the **McKay–Thompson series** $T_g$, one for each element $g$ of the Monster group $\mathbb{M}$ — the largest of the $26$ sporadic finite simple groups, an object with roughly $8 \times 10^{53}$ elements and exactly $194$ conjugacy classes. Each $T_g$ depends only on the conjugacy class of $g$, so there are $194$ of them, and each is *normalized* in a specific way: it begins
$$T_g = q^{-1} + a_g(0) + a_g(1)\,q + a_g(2)\,q^2 + \cdots ,$$
with leading term exactly $q^{-1}$ and coefficient exactly $1$. In the standard convention the constant term $a_g(0)$ is set to zero, so $T_g = q^{-1} + O(q)$.

The most famous of these is $T_{1A} = J$, the normalized modular $j$-function:
$$J = q^{-1} + 196884\,q + 21493760\,q^2 + 864299970\,q^3 + \cdots$$
The coefficient $196884 = 196883 + 1$ is the numerical coincidence that launched moonshine: $196883$ is the dimension of the smallest nontrivial representation of the Monster. Two more members of the family, associated with elements of order $2$ and $3$, begin
$$T_{2A} = q^{-1} + 4372\,q + 96256\,q^2 + 1240002\,q^3 + \cdots,$$
$$T_{3A} = q^{-1} + 783\,q + 8672\,q^2 + 65367\,q^3 + \cdots.$$
Call any Laurent series of this shape — leading term precisely $q^{-1}$ and nothing more singular — a **normalized series**.

### The obstruction

Now the basic theorem.

> **Pole-Order Theorem.** If $f_1, \dots, f_m$ are normalized series, their product $f_1 f_2 \cdots f_m$ has order exactly $-m$: it has a pole of order $m$ at $q=0$, with leading coefficient $1$. Consequently $q^m f_1 \cdots f_m$ has order $0$, and no smaller power of $q$ suffices.

The proof is a two-line consequence of the additivity of order — each factor contributes $-1$ — but its meaning is not trivial. It says that the class of normalized series is *not* closed under multiplication, and it quantifies the failure precisely: multiplying $m$ of them overshoots the target by exactly $m-1$ powers. Applied to moonshine:

> **Monster Corollary.** The product of all $194$ McKay–Thompson series has a pole of order exactly $194$, and $q^{194}$ times that product is a genuine power series with constant term $1$.

There is a pleasant refinement. If you want the product to be *normalized again*, rather than merely regular, you should multiply by one power less:

> **Renormalization Theorem.** For $m \ge 1$ normalized series, $q^{m-1} f_1 \cdots f_m$ is once more a normalized series. In the Monster case, $q^{193}$ times the $194$-fold product is again a series of McKay–Thompson shape.

So normalized series form a system closed not under plain multiplication but under the "corrected" product $(f,g) \mapsto q\,fg$.

### Why the leak cannot be plugged

The claim I made at the start was much stronger than "the order is $-194$". It was that this number is *unremovable*. Making that precise is where the structure theory comes in, and where the cryptographic flavour appears.

Think of a Laurent series as a message and of multiplication by an invertible power series — a series $u = u_0 + u_1 q + u_2 q^2 + \cdots$ with $u_0 \ne 0$ — as a *blinding operation*: it scrambles infinitely many coefficients at once but leaves the order untouched, since $\operatorname{ord}(u) = 0$. So:

> **Blinding Invariance.** For every invertible power series $u$, $\operatorname{ord}(uf) = \operatorname{ord}(f)$. No power-series blinding can hide the pole.

The remarkable fact is the converse: these are the *only* things you can multiply by without moving the order.

> **Splitting Theorem.** The group of nonzero Laurent series factors canonically as
> $$\mathbb{C}(\!(q)\!)^\times \;\cong\; \mathbb{C}[\![q]\!]^\times \times \mathbb{Z},$$
> the isomorphism sending a pair $(u, k)$ to $u\,q^k$. Every nonzero Laurent series is uniquely an invertible power series times an integer power of $q$, and the integer is precisely its order.

Two consequences. First, order is a **complete invariant** of the "blinding class": two Laurent series differ by multiplication by an invertible power series *if and only if* they have the same order. Second, shifting by $q^k$ moves the order by exactly $k$, and for any target value there is exactly one $k$ that achieves it. This is a perfect one-time pad over the integers: the pole order is unmaskable by blinding and perfectly randomizable by monomial shifts, and the two operations are cleanly separated.

Might there be some *other* clever invariant, immune to blinding, that sees more than the order does? No.

> **Rigidity Theorem.** Every homomorphism from the group of nonzero Laurent series to the integers that vanishes on all invertible power series is an integer multiple of the order. In particular, two such invariants agreeing on $q$ agree everywhere.

So up to scaling, the pole order is not merely *an* invariant insensitive to blinding — it is *the* one.

Nor can one destroy it by raising to powers. Since order is additive, $\operatorname{ord}(f^n) = n\operatorname{ord}(f)$, and $n \cdot k = 0$ forces $k = 0$ for $n \ge 1$: the invariant group $\mathbb{Z}$ is torsion-free.

> **No-Root Theorem.** If some positive power of a Laurent series is an invertible power series, then the series itself already was. In particular, no power whatsoever of the $194$-fold moonshine product is a power series: the $n$-th power has a pole of order exactly $194n$.

Finally, the obstruction survives *additive* noise too.

> **Additive Robustness.** Add to a product of $m$ normalized series any Laurent series whose own order is greater than $-m$ — any power series, any polynomial in $q$, any finite sum of less singular things. The order of the sum is still exactly $-m$.

Put the four together and the picture is complete: the pole-order leak is **complete** (it classifies blinding classes exactly), **unique** (no other integer invariant is insensitive to blinding), **indestructible** (immune to powers and to additive masking), and **repairable in exactly one way** (multiply by $q^{194}$, or by $q^{193}$ if you want a normalized series back).

### Below the leading term: a hierarchy of identities

The order is the leading-order information. What happens just beneath it is a beautiful combinatorial cascade.

Write the product of $m$ normalized series with the correction applied: $q^m f_1 \cdots f_m$ is a power series starting with $1$. What are its coefficients in terms of the coefficients $a_i(0), a_i(1), a_i(2), \ldots$ of the individual factors? There is an exact answer at every degree — a convolution over all ways to split $n$ among the $m$ factors:
$$[q^{\,n-m}]\ \prod_{i=1}^m f_i \;=\; \sum_{\nu_1 + \cdots + \nu_m = n} \ \prod_{i=1}^m a_i(\nu_i - 1),$$
where $a_i(-1) = 1$ records the leading $q^{-1}$ of each factor. This general formula is exact but unwieldy. Its power is that under the moonshine normalization $a_i(0) = 0$ it *collapses*, and the way it collapses is the punchline of the story.

Because each corrected factor is $q f_i = 1 + a_i(1)q^2 + a_i(2)q^3 + \cdots$ — note the missing $q^1$ term, which is exactly the vanishing constant term of $f_i$ — two different factors cannot interact until degree $4$. The lowest cross term you can build from two factors is $a_i(1)a_j(1)q^4$. Therefore:

| degree | coefficient of the $m$-fold product |
|---|---|
| $-m$ | $1$ |
| $1-m$ | $0$ |
| $2-m$ | $\sum_i a_i(1)$ |
| $3-m$ | $\sum_i a_i(2)$ |
| $4-m$ | $\sum_i a_i(3) + e_2\big(a_1(1),\dots,a_m(1)\big)$ |

Here $e_2$ is the second elementary symmetric function, $e_2(x_1,\dots,x_m) = \sum_{i<j} x_i x_j$, which can be written division-free as $\tfrac12\big[(\sum_i x_i)^2 - \sum_i x_i^2\big]$.

Three degrees of *pure additivity*, and then, at the fourth, the factors finally notice each other. The first three rows are "Newton identities" in the sense that only power sums appear; the fourth row is the first genuinely symmetric-function-theoretic correction. The pattern is a sharp quantitative expression of a soft idea: normalization pushes interaction downstream.

### The identities in action

These are not abstractions; they compute. Take the three series $T_{1A}, T_{2A}, T_{3A}$ above and multiply them. Their product has a pole of order $3$, and the identities predict its first four coefficients without ever performing the convolution:

- **Degree $-3$:** the coefficient is $1$.
- **Degree $-2$:** it is $0$.
- **Degree $-1$:** $196884 + 4372 + 783 = 202039$.
- **Degree $0$:** $21493760 + 96256 + 8672 = 21598688$.
- **Degree $1$:** here the cross terms arrive. The sum of cubic coefficients is $864299970 + 1240002 + 65367 = 865605339$, and
$$e_2(196884,\,4372,\,783) = 196884\cdot 4372 + 196884 \cdot 783 + 4372 \cdot 783 = 1018360296,$$
giving $865605339 + 1018360296 = \mathbf{1883965635}$.

Direct multiplication of the three series confirms every one of these numbers. The jump from $2\times 10^7$ to $1.9 \times 10^9$ between degrees $0$ and $1$ is the cross terms announcing themselves: at degree $1$ the interaction contributes more than the individual factors do.

### Positivity, and why moonshine cares

There is one last structural feature that ties the arithmetic back to representation theory. The coefficients of genuine McKay–Thompson series are traces of group elements acting on graded pieces of an infinite-dimensional representation; for the identity element they are honest dimensions, hence non-negative integers. That positivity propagates:

> **Positivity Theorem.** If every factor of such a product has non-negative real coefficients, then so does the product, in every degree.

> **Domination Theorem.** Moreover, the coefficient of the product at degree $n-m$ is at least the degree-$(n-1)$ coefficient of *every single factor*.

The second statement says the corrected product never loses sight of its constituents: it grows at least as fast as the fastest-growing McKay–Thompson series in it. The proof is not analytic; it comes straight out of the convolution formula, because that formula expresses each coefficient as a sum of products of coefficients, with one term of the sum being exactly the chosen factor's coefficient multiplied by ones. A combinatorial identity yields an inequality — a small but satisfying example of how the right bookkeeping makes an estimate obvious.

### What to take away

The essential lesson is that valuations — algebraic rulers for singularity — behave like perfect information channels. They are logarithms: they turn products into sums, so their values add up predictably; they are blind to everything except the leading behaviour, so they cannot be confused by noise in the tail; and, in a precise sense, they are *unique* with those properties.

The Monster's $194$ conjugacy classes then supply a memorable emblem. The product of all $194$ McKay–Thompson series carries the number $194$ on its face as the order of its pole, and the number is welded on: you can blind it, mask it, exponentiate it, add to it, and the $194$ stays. The only way to remove it is the honest one: divide by $q^{194}$, the unique correction — the mathematical equivalent of returning the key rather than picking the lock.

Beneath that leading term, the coefficients tell a second story, of factors that stay stubbornly independent for three whole degrees before their first interaction appears as a sum of pairwise products. It is a small window into why moonshine's normalizations are chosen as they are: they are exactly the conventions that keep the arithmetic additive for as long as possible.
