# When Calculus Casts a Shadow: The Tropical Geometry of Differential Equations

## A puzzle about the smallest term

Imagine you are handed an infinite polynomial — a *power series* — like

$$f(X) = a_0 + a_1 X + a_2 X^2 + a_3 X^3 + \cdots$$

Most of the time you cannot write down all of its coefficients. But there is one number you can almost always pin down quickly: **the index of the very first nonzero coefficient**. If $a_0 = 0$ but $a_1 \neq 0$, the series "starts at" $X^1$. If everything up to $X^4$ vanishes and $a_5 \neq 0$, it starts at $X^5$. We call this number the **order** of the series and write it $\operatorname{ord}(f)$. By convention the zero series — the series with no nonzero terms at all — has order $\infty$, because its first nonzero term never arrives.

The order is a humble quantity. It throws away almost all the information in $f$, keeping only the location of its leading edge. And yet, as this article will show, that single number obeys a beautiful arithmetic of its own — an arithmetic that turns the hard, continuous machinery of *differential equations* into a finite, combinatorial game. That game is called **tropical mathematics**, and the bridge between the two worlds is the subject of a small collection of theorems we will state precisely and explain in plain language.

## The min-plus world

Here is the first surprise. Watch what happens to the order under the basic operations on power series.

**Multiplication.** When you multiply two series, their leading terms multiply, so the leading edges *add*:

$$\operatorname{ord}(f \cdot g) = \operatorname{ord}(f) + \operatorname{ord}(g).$$

If $f$ starts at $X^2$ and $g$ starts at $X^3$, then $f \cdot g$ starts at $X^5$.

**Addition.** When you add two series, the result starts no earlier than the earlier of the two — but it can start *later*, if the two leading terms happen to cancel:

$$\operatorname{ord}(f + g) \ge \min\big(\operatorname{ord}(f), \operatorname{ord}(g)\big).$$

If $f = X^2 + \cdots$ and $g = -X^2 + \cdots$, the $X^2$ terms annihilate and the sum starts strictly later than $X^2$.

Put those two rules side by side:

- ordinary $\times$ becomes $+$,
- ordinary $+$ becomes $\min$.

This is exactly the **min-plus** (or **tropical**) **semiring** $(\mathbb{N} \cup \{\infty\}, \min, +)$, where "adding" two numbers means taking their minimum and "multiplying" them means adding them in the usual sense. The name *tropical* is a tribute to the Brazilian mathematician Imre Simon, who pioneered the min-plus algebra; there is nothing geographic about the mathematics. In this world the number $\infty$ plays the role of zero (because $\min(x, \infty) = x$) and the ordinary number $0$ plays the role of one (because $0 + x = x$).

The headline of this article is that **the order map is a dictionary translating calculus on power series into arithmetic in the tropical world.** And the most interesting word in that dictionary is the *derivative*.

## The derivative drops the leading edge by one

Differentiate a power series term by term:

$$f = a_0 + a_1 X + a_2 X^2 + a_3 X^3 + \cdots \quad\Longrightarrow\quad f' = a_1 + 2a_2 X + 3a_3 X^2 + \cdots.$$

Every exponent shifts down by one. So if $f$ started at $X^{k+1}$, its derivative $f'$ starts at $X^{k}$ — one step earlier. In symbols, **if $\operatorname{ord}(f) = k+1$ then $\operatorname{ord}(f') = k$.** This is our first theorem, and in the formal development it is named `order_derivativeFun_eq`.

There is a subtle catch hiding in the phrase "the coefficient does not vanish." When we differentiate the term $a_{k+1} X^{k+1}$ we get $(k+1)\,a_{k+1} X^{k}$. For this to be genuinely nonzero we need the *number* $k+1$ to be nonzero in our coefficient system. Over the rational, real, or complex numbers this is automatic — but over a field of *characteristic $p$* (where $p = 0$), the integer $p$ behaves like zero, and then $\frac{d}{dX}(X^p) = p\,X^{p-1} = 0$. The leading edge does not drop; it disappears entirely. For this reason the whole theory lives most comfortably over **characteristic-zero** fields such as $\mathbb{C}$, and that hypothesis is genuinely load-bearing, not a technicality we could wish away.

Apply the rule repeatedly and you get the **iterated derivative rule** (`order_iterate_derivativeFun`): if $f$ starts at $X^n$, then its $i$-th derivative starts at $X^{n-i}$, as long as $i \le n$:

$$\operatorname{ord}\!\left(\frac{d^i f}{dX^i}\right) = n - i.$$

Each differentiation peels one layer off the front of the series.

## The order of a differential monomial

In differential algebra the basic building blocks are not just powers of $f$, but powers of $f$ *and its derivatives* multiplied together — objects like

$$(f')^2 \cdot f'' \qquad\text{or, in general,}\qquad \prod_i \left(\frac{d^i f}{dX^i}\right)^{e_i}.$$

Such a product is called a **differential monomial**, and the list of exponents $e_i$ records how many copies of each derivative appear. Because order turns products into sums and sends the $i$-th derivative to $n - i$, the order of any differential monomial is an **affine** (straight-line) function of $n = \operatorname{ord}(f)$:

$$\operatorname{ord}\!\left(\prod_i \left(\frac{d^i f}{dX^i}\right)^{e_i}\right) = \sum_i e_i \,(n - i).$$

This is the theorem `order_diff_monomial`. Let us make it concrete. Take the monomial $(f')^2 f''$, with a series $f$ of order $n$. Here $e_1 = 2$ (two copies of the first derivative) and $e_2 = 1$ (one copy of the second). The formula predicts

$$\operatorname{ord}\big((f')^2 f''\big) = 2(n-1) + 1\,(n-2) = 3n - 4.$$

If $f$ starts at $X^5$, this monomial starts at $X^{11}$ — and you can check it by hand if you like, but you don't have to: the tropical dictionary computed it for you in one line, without ever touching a coefficient.

## Balancing: how a sum can vanish

Now we reach the heart of the matter. A differential *equation* asks a sum of differential monomials to equal zero:

$$\varphi_1 + \varphi_2 + \cdots + \varphi_t = 0.$$

In the tropical world, "equal to zero" is a strange request, because there is no real subtraction — the tropical sum of finitely many things is their *minimum*, and a minimum is rarely $\infty$. So how can a genuine sum of power series collapse all the way down to the zero series? Only by **cancellation**, and cancellation has a rigid combinatorial signature.

Suppose the terms $\varphi_j$ have orders $\operatorname{ord}(\varphi_1), \operatorname{ord}(\varphi_2), \dots$ Suppose, further, that **one** of them, say $\varphi_{i_0}$, starts strictly earlier than all the others. Then nothing can cancel its leading term — every other series is silent at that early position — and the whole sum must start exactly where $\varphi_{i_0}$ does:

$$\operatorname{ord}\!\left(\sum_j \varphi_j\right) = \operatorname{ord}(\varphi_{i_0}).$$

This is the theorem `order_sum_eq_of_unique_min`: **a unique earliest term dictates the order of the sum.** It rests on two smaller, intuitively obvious facts — that a common lower bound for all the terms bounds the sum (`le_order_sum`), and a strict version of the same for a nonempty collection (`lt_order_sum`).

Turn this around and you get the punchline. If a sum of power series is genuinely zero — order $\infty$ — then it *cannot* have a unique earliest term, because a unique earliest term would force the sum to start at a finite position. Therefore the minimum order must be achieved by **at least two** of the terms. Concretely: for any nonzero term $\varphi_{i_0}$ in a vanishing sum, there is a *different* term $\varphi_j$ that starts no later than $\varphi_{i_0}$:

$$\sum_j \varphi_j = 0 \quad\Longrightarrow\quad \text{the minimal order is attained at least twice.}$$

This is the **tropical balancing lemma**, named `tropical_balancing`, and it is the power-series incarnation of the single most important principle in all of tropical geometry: the **balancing condition**. Wherever a tropical object "vanishes," the minimum that defines it is achieved more than once. Here that abstract slogan becomes a concrete, provable fact about cancellation of leading terms in calculus.

One honest caveat lives inside the statement: we must insist that $\varphi_{i_0}$ is actually nonzero. A zero term has order $\infty$ and "balances" trivially against nothing at all, so balancing is a statement about the genuine, nonzero terms of the equation. Drop that hypothesis and the theorem is false — a subtlety the formal development records explicitly.

## A worked example: the monomial equation

Let us watch balancing happen in a real differential equation. Consider

$$X\,y' - 3\,y = 0.$$

Try the candidate solution $f = X^3$. Then $f' = 3X^2$, so $X f' = 3X^3$, while $3f = 3X^3$. The two terms are

$$\varphi_1 = X f' = 3X^3 \quad(\text{order } 3), \qquad \varphi_2 = -3f = -3X^3 \quad(\text{order } 3).$$

Their orders **tie** at $3$ — the minimum is attained twice, exactly as balancing demands — and their leading coefficients $+3$ and $-3$ cancel, so $\varphi_1 + \varphi_2 = 0$. The equation is solved.

Now notice *why* the order had to be $3$. For a general candidate $f = X^n$, the term $X f'$ contributes leading coefficient $n$ at $X^n$, and the term $-3f$ contributes $-3$ at $X^n$. The orders always tie at $n$, so the *tropical* condition (balancing) is satisfied for **every** $n$. But the coefficients cancel only when $n - 3 = 0$, that is $n = 3$. This is the crucial lesson: **balancing is necessary, but not always sufficient.** The tropical shadow tells you *which orders are even possible*; whether a classical solution actually exists at a balanced order is a finer, coefficient-level question. Capturing exactly that gap is the converse problem we return to at the end.

## The fundamental theorem, tropically

These pieces assemble into the centerpiece, a power-series analogue of a result known in the field as the **tropical fundamental theorem of differential algebra** (`tropical_FTDA`). Stated loosely: if you take a system of differential equations and look at the *orders* of its power-series solutions, those orders satisfy the tropical (balancing) version of the system. In the language of ideals — collections of equations closed under the natural operations — **the tropicalization of a differential ideal is contained in the tropical differential ideal of its tropicalization.** Every classical solution casts a tropical shadow, and that shadow is always a legal tropical solution.

There is a companion quantitative statement, `order_diffPoly_ge`: when you plug a power series $f$ into a differential polynomial $P$, the order of the result $P(f)$ is **at least** the tropical minimum computed from the orders alone. In plain terms, the tropical arithmetic gives a *guaranteed lower bound* on where the output series can possibly start — a bound you can read off combinatorially, before doing any real analysis. This is what people mean when they say tropical solutions "lower-bound the growth" of classical ones: the cheap, finite, min-plus computation fences in the behavior of the expensive, infinite, analytic object.

It is worth being precise about what is proved and what is not. The containment direction — *every classical solution is tropically legal* — is the theorem above. The **converse** — *every tropically legal order is actually realized by some genuine power-series solution* — is harder and, over a rich enough (algebraically closed, characteristic-zero) field, is expected to hold, upgrading the containment to a full equality. Our monomial example already shows the tension: balancing held for all $n$, yet only $n = 3$ gave a true solution. The converse asks for a recipe to *choose coefficients* that cancel the tied leading terms whenever balancing permits — a tropical Newton-polygon lifting argument. That remains a conjecture, and an inviting one, precisely because the obstruction has now been isolated so cleanly.

## Why this matters

Differential equations are the language in which physics, chemistry, biology, and engineering write down how things change. Solving them exactly is usually impossible; even deciding whether a power-series solution *exists*, and where it begins, can be delicate. Tropical mathematics offers a radically cheaper first pass. By replacing each operation with its min-plus shadow — multiply becomes add, add becomes minimum, differentiate becomes "subtract one from the leading edge" — an entire differential equation collapses to a finite combinatorial constraint on a handful of integers. The balancing condition then tells you which leading behaviors are even conceivable, pruning the search for genuine solutions before the hard analysis begins.

The same philosophy has reshaped algebraic geometry over the last two decades, where tropical curves — piecewise-linear "stick figures" of classical curves — capture deep enumerative information while being almost trivial to draw. Bringing that philosophy to *differential* algebra means that the stick-figure picture now applies to dynamics, to the growth rates of solutions, to the very equations that govern change. The order map is the projector that casts the picture; the balancing lemma is the law those shadows must obey.

What makes this story satisfying is how little machinery it needs. Three translation rules — for products, for sums, for derivatives — and one combinatorial principle — that a vanishing sum must tie for its minimum at least twice — are enough to build a working tropical calculus for differential equations, complete with exact formulas for the orders of arbitrary differential monomials and a guaranteed lower bound on the output of any differential polynomial. Humble as it is, the order of a power series turns out to remember exactly what tropical geometry wants to know.
