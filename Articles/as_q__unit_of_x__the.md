# The Arithmetic of a Pole

## How one missing power of $q$ organizes an entire theory of coefficients

There is a certain kind of function that appears again and again at the border between number theory, group theory and mathematical physics. It looks like this:

$$f(q) = \frac{1}{q} + a_0 + a_1 q + a_2 q^2 + a_3 q^3 + \cdots$$

One negative power of $q$, with coefficient exactly $1$, and then an infinite tail of ordinary powers. Series of this shape are everywhere. The most famous of them is the modular $j$-function with its constant term removed,

$$j(q) - 744 = \frac{1}{q} + 196884\,q + 21493760\,q^2 + \cdots,$$

whose coefficients famously encode the dimensions of the representations of the Monster — the largest sporadic finite simple group, an object with roughly $8 \times 10^{53}$ elements. That coincidence, spotted by John McKay in the 1970s and explained by Borcherds two decades later, is *monstrous moonshine*. The Monster has $194$ conjugacy classes, and to each class $g$ moonshine attaches its own series of exactly this shape, the *McKay–Thompson series*

$$T_g(q) = \frac{1}{q} + 0 + c_g(1)\, q + c_g(2)\, q^2 + \cdots.$$

Now ask a question that sounds almost naive. What happens if you **multiply** such series together? Not two of them — all $194$ of them at once. What do the coefficients of the product look like?

At first glance this looks hopeless. A product of $194$ infinite series is a combinatorial explosion: to compute a single coefficient you seem to need to sum over an astronomical number of ways of choosing one term from each factor. And yet the answer turns out to be strikingly, almost embarrassingly, structured. The purpose of this article is to explain why.

---

## The pole is a coordinate system

Everything begins with a change of viewpoint so small it barely deserves the name.

Multiply $f$ by $q$. The pole disappears:

$$u_f(q) := q\, f(q) = 1 + a_0 q + a_1 q^2 + a_2 q^3 + \cdots.$$

What remains is an ordinary power series whose constant term is $1$ — and a power series with nonzero constant term is *invertible*. It is a **unit** in the ring of formal power series. So every one of our series factors, uniquely, as

$$f = q^{-1} \cdot (\text{a unit}).$$

That is the whole idea. A single pole is not a pathology; it is a *coordinate*. It separates cleanly from the rest of the series, and everything genuinely interesting lives in the unit that remains.

The consequences are immediate. If you multiply $m$ such series together, the poles simply add:

$$\prod_{i=1}^{m} f_i = q^{-m} \prod_{i=1}^{m} u_i,$$

and the second factor is again a unit, because a product of units is a unit. So the product of $m$ normalized series has a pole of order **exactly** $m$ — never more, never less, no matter how wild the tails are. The leading coefficient, the one attached to $q^{-m}$, is always $1$.

This gives us a natural way to index the coefficients of the product. Define the **level-$k$ coefficient**

$$c_k := \big[q^{\,k-m}\big] \prod_{i=1}^{m} f_i,$$

the coefficient of $q^{k-m}$. Level $0$ is the pole itself, and we have just seen $c_0 = 1$. Level $1$ is the next one down, and so on. Because the pole factors out, these are exactly the ordinary power-series coefficients of the unit part:

$$c_k = \big[q^{k}\big] \prod_{i=1}^{m} u_i.$$

The question "what are the coefficients of a product of moonshine-shaped series?" has become "what are the coefficients of a product of units?"

---

## The master formula, and why it needs no special cases

Here is the answer, and it is a single line.

> **Master Formula (level $k$).** Let $f_1, \dots, f_m$ each be of the form $q^{-1} + a_0 + a_1 q + \cdots$. Then for every $k \geq 0$,
> $$\big[q^{\,k-m}\big] \prod_{i=1}^{m} f_i \;=\; \sum_{\substack{\nu_1 + \cdots + \nu_m = k \\ \nu_i \geq 0}} \; \prod_{i=1}^{m} \big[q^{\,\nu_i - 1}\big] f_i .$$

Read it as a rule for distributing a budget. You have $k$ units of "excitation" to hand out among the $m$ factors; a factor receiving $\nu_i$ units contributes its coefficient in degree $\nu_i - 1$; multiply, and sum over every way of dividing the budget.

The elegance is in what is *absent*: there is no case distinction. A factor receiving nothing, $\nu_i = 0$, is asked for its coefficient in degree $-1$ — and that is exactly the pole coefficient, which is exactly $1$. The normalization that seemed like an arbitrary convention turns out to be the multiplicative identity in disguise. A factor that does not participate contributes the neutral element automatically. One formula covers everything.

Let us see it work. Take just two factors, $f = q^{-1} + 2 + 3q$ and $g = q^{-1} + 5 + 7q$, and ask for the coefficient of $q$, which is level $k = 3$ since the pole has order $2$. There are four ways to split a budget of $3$ between two factors:

$$\underbrace{1 \cdot 0}_{(0,3)} \;+\; \underbrace{2 \cdot 7}_{(1,2)} \;+\; \underbrace{3 \cdot 5}_{(2,1)} \;+\; \underbrace{0 \cdot 1}_{(3,0)} \;=\; 29.$$

Multiply the two series out by hand and you will indeed find $29\,q$.

---

## Locality: most of the Monster is asleep

The master formula is exact, but as written it still sums over an enormous set. Here the structure bites.

A budget of $k$ handed out in nonnegative whole units can excite **at most $k$ factors**, for the trivial reason that every excited factor consumes at least one unit. Combined with the observation that unexcited factors contribute $1$, this yields:

> **Locality.** The level-$k$ coefficient of a product of $m$ normalized series depends on at most $k$ of the factors at a time. Precisely, it decomposes as a sum over subsets $T$ of the index set with $|T| \leq k$, the term attached to $T$ involving only the tails of the factors in $T$.

For the Monster this is dramatic. To know the coefficient at level $3$ of a product of $194$ series, you never need to consider more than three of them simultaneously. The naive count of interactions collapses from "all $194$ at once" to "triples". And the phenomenon is not new — it is the exact generalization of something classical. If you take the simplest possible tails, $f_i = q^{-1} + a_i$ with nothing beyond the constant, then the master formula forces every $\nu_i$ to be $0$ or $1$, and what comes out is

$$c_k = \sum_{|T| = k} \prod_{i \in T} a_i = e_k(a_1, \dots, a_m),$$

the $k$-th **elementary symmetric function**. "$e_k$ only sees $k$-element subsets" is the shadow, in the degenerate case, of locality in general.

There is a companion statement, equally useful and equally simple to see once the master formula is in hand:

> **Truncation.** The level-$k$ coefficient depends only on the coefficients $a_0, a_1, \dots, a_{k-1}$ of the factors. Everything deeper in the tails is invisible.

The reason is that a factor receiving $\nu_i \leq k$ units is queried in degree $\nu_i - 1 \leq k - 1$. So the first few coefficients of a gigantic product are computable from the first few coefficients of the ingredients — a finite computation, exactly.

And for genuine McKay–Thompson series the bound improves by a factor of two. Those series have *vanishing constant term*: $T_g = q^{-1} + 0 + c_g(1)q + \cdots$. In the master formula, a factor receiving exactly one unit is queried in degree $0$ — and returns zero. So every surviving term has all exponents $0$ or $\geq 2$, which forces

$$2 \cdot \#\{\text{excited factors}\} \le k.$$

> **Half Locality.** If every factor has vanishing constant term, then the level-$k$ coefficient depends on at most $k/2$ of the factors at a time.

Watch it in a tiny example. With $f = q^{-1} + 3q + 4q^2$ and $g = q^{-1} + 7q + 9q^2$, the level-$3$ coefficient has four candidate terms, and the two "mixed" ones, $(1,2)$ and $(2,1)$, are both annihilated by a zero constant term. What survives is $9 + 4 = 13$: one factor excited at a time, never both.

A third corollary comes for free. The master formula expresses each coefficient of the product as a **sum of products of coefficients of the factors** — no division, no subtraction of anything not already present. So whatever ring the tails live in, the answer stays there.

> **Integrality Transfer.** If all coefficients of all factors lie in a subring $R$ of $\mathbb{C}$, then so do all coefficients of the product. In particular, integrality of moonshine coefficients propagates to the whole product.

---

## Newton, hiding in a logarithm

The master formula is a *closed* expression: it tells you the answer level by level, independently. But experience with symmetric functions suggests there should also be a *recursive* one — the coefficients ought to feed each other. There is, and it comes from calculus.

The trick is the logarithmic derivative. For a power series $u$ with nonzero constant term, write $\mathcal{L}(u) := u'/u$. The point of $\mathcal{L}$ is that it converts multiplication into addition, and it does so at the level of formal series with no analysis required: differentiating a product by the Leibniz rule and dividing by the product itself gives

$$\Big(\prod_{i=1}^m u_i\Big)' \;=\; \Big(\prod_{i=1}^m u_i\Big) \cdot \sum_{i=1}^m \frac{u_i'}{u_i}.$$

Now compare coefficients on both sides. Define the **logarithmic power sums**

$$p_r := \big[q^r\big] \sum_{i=1}^{m} \frac{u_i'}{u_i},$$

one number for each $r \ge 0$, gathering the whole family into a single sequence. Reading off the coefficient of $q^k$ in the displayed identity — the left side gives $(k+1)c_{k+1}$ because differentiation shifts and multiplies by the exponent, the right side is a Cauchy convolution — produces:

> **Newton Recursion.** With $c_k$ the level-$k$ coefficients of $\prod f_i$ and $p_r$ the logarithmic power sums,
> $$(k+1)\, c_{k+1} \;=\; \sum_{j=0}^{k} c_j \, p_{k-j}, \qquad c_0 = 1.$$

This is a genuine Newton identity, valid for arbitrary tails. The classical statement about symmetric functions, $k e_k = \sum_j (-1)^{j-1} e_{k-j} p_j$, is the special case — and not by analogy. Take the linear series $f_i = q^{-1} + a_i$ again. Its unit part is $1 + a_i q$, whose logarithmic derivative is a geometric series:

$$\frac{a_i}{1 + a_i q} = \sum_{r \geq 0} (-1)^r a_i^{\,r+1} q^r .$$

So $p_r = (-1)^r \sum_i a_i^{r+1}$ is, up to sign, the classical power sum $p_{r+1}^{\text{classical}}$; and $c_j = e_j$. Substituting into the recursion gives exactly

$$(k+1)\, e_{k+1} \;=\; \sum_{j=0}^{k} (-1)^{k-j}\, e_j\, p_{k-j+1},$$

Newton's identities for arbitrary finite families of complex numbers, derived without ever touching a symmetric-function combinatorial argument. The low cases fall out as they should: $e_1 = p_1$, and $2e_2 = p_1^2 - p_2$.

So the pole machinery does not merely *resemble* symmetric function theory. It contains it.

---

## Running the recursion backwards

The recursion has a feature the closed formula does not: it can be inverted. Over the complex numbers the factor $k+1$ is never zero, so we may divide by it and read the identity as a definition of $c_{k+1}$ in terms of $c_0, \dots, c_k$ and $p_0, \dots, p_k$. Since the induction starts from the universal value $c_0 = 1$, the power sums determine everything downstream.

> **Rigidity.** If two families of normalized series — of possibly *different sizes* — have the same logarithmic power sums $p_0, \dots, p_{K-1}$, then their products have the same coefficients at every level $j \leq K$.

Note carefully what has vanished from the statement: the number of factors. Two products may have poles of wildly different orders, yet if their power sums agree, their heads agree once you index coefficients by level rather than by absolute degree. The individual factors are irrelevant; only the aggregate sequence $p_0, p_1, p_2, \dots$ matters. In the language of physics, the power sums are a *complete set of observables* for the head of the product.

Specializing to linear series turns this into a classical theorem obtained by an unclassical route:

> **Power sums determine elementary symmetric functions.** If two finite families of complex numbers have equal power sums $p_1, \dots, p_K$, then they have equal elementary symmetric functions $e_0, \dots, e_K$.

This is the invertibility of Newton's identities in characteristic zero — here a corollary of a statement about poles of Laurent series. And it is sharp in the obvious way: the families $\{2\}$ and $\{1,1\}$ share $p_1 = 2$ but differ at $p_2$ ($4$ versus $2$), and correspondingly their $e_2$ differ ($0$ versus $1$). Knowing the power sums below degree $K$ buys you exactly the levels up to $K$, no more.

---

## What this buys you

Put the pieces together and a computational picture emerges that is genuinely practical.

Suppose you want the first few coefficients of the full $194$-fold moonshine product. Naively that is a product of $194$ infinite series. In fact:

- The pole order is known in advance and exactly: $194$.
- The coefficient at level $0$ is $1$, always.
- The coefficient at level $k$ requires only the first $k$ tail coefficients of each factor (truncation), and only $k$ factors interact at a time (locality) — or $k/2$ for genuine McKay–Thompson series (half locality).
- If you prefer, compute the $194$ logarithmic derivatives once, add them into a single sequence of power sums, and run the recursion: the cost of a level then no longer grows with the number of factors at all.
- Every coefficient you obtain is an integer, guaranteed, whenever the inputs are.

There are two complementary algorithms here — an explicit sum for structural reasoning and small levels, and a linear recursion for actual computation — and they agree, which is itself a useful correctness check.

More broadly, the moral is one that recurs across mathematics: **a controlled singularity is a form of information, not a defect**. The single pole with residue $1$ is what makes all of this run. It supplies the unit factorization, it supplies the neutral element that removes case distinctions from the master formula, it supplies the base case $c_0 = 1$ that anchors the recursion, and it is what makes "level" the right way to index coefficients across products of different sizes.

Monstrous moonshine is a story about a coincidence of numbers becoming a theory. The structure described here is more modest but points the same direction: once you look at moonshine-shaped series through the lens of their pole, the coefficients of their products stop being an inscrutable combinatorial mass and become an ordinary, well-behaved, thoroughly computable object — one governed by the same identities Newton wrote down for the roots of a polynomial, three and a half centuries ago.
