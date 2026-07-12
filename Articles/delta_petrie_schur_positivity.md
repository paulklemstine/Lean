# When Divisibility Decides: The Hidden Clockwork of the Petrie Functions

## A number-theoretic switch inside a problem about symmetry

Some of the most satisfying moments in mathematics happen when two subjects that seemed to live in different worlds turn out to share a single mechanism. This is the story of one such moment. On one side we have *symmetric functions* — infinite polynomials that stay the same no matter how you shuffle their variables, the workhorses of algebraic combinatorics. On the other side we have the oldest question in arithmetic: *does one whole number divide another?* The surprise is that a delicate positivity phenomenon for a whole family of symmetric functions is secretly controlled by a single, crisp divisibility test, and that this test is nothing more than the way a certain simple polynomial factors using roots of unity.

The headline can be stated in one sentence. For integers $k \ge 2$ and $n \ge 1$, a natural family of symmetric functions built from the **Petrie function** $G(k,n)$ is "positive" in a precise sense *if and only if* $k$ divides $n$. No exceptions, no boundary cases, no dependence on the many extra parameters one can throw at the construction. The dividing line is exactly $k \mid n$.

## The cast of characters

Let us meet the players without any jargon left unexplained.

A **monomial symmetric function** $m_\lambda$ is the simplest kind of symmetric polynomial. Fix a partition $\lambda = (\lambda_1 \ge \lambda_2 \ge \cdots)$ of a number $n$ — that is, a way of writing $n$ as a sum of positive parts. Then $m_\lambda$ is the sum of all distinct monomials whose exponents are a rearrangement of $\lambda$. For example, $m_{(2,1)} = x_1^2 x_2 + x_1 x_2^2 + x_1^2 x_3 + \cdots$, running over all the essentially different ways to place a square and a first power.

The **Petrie symmetric function** is a carefully filtered sum of these building blocks:
$$
G(k,n) \;=\; \sum_{\substack{\lambda \vdash n \\ \lambda_1 < k}} m_\lambda .
$$
In words: add up the monomial symmetric functions for every partition of $n$ whose *largest part is smaller than $k$*. It is as if we are only allowed to stack the exponents up to height $k-1$ and never higher. This "capped height" condition is what ties $G(k,n)$ to the number $k$, and it is the seed from which everything grows.

There is a beautifully compact way to see all the $G(k,n)$ at once. If you form the product
$$
\prod_i \bigl(1 + x_i + x_i^2 + \cdots + x_i^{k-1}\bigr),
$$
and then collect terms of total degree $n$, you get exactly $G(k,n)$. Each variable contributes an exponent between $0$ and $k-1$, which is precisely the "no part reaches $k$" rule in disguise.

The final actors are the **delta operators** $\Delta_{e_j}$. These are linear operators introduced by Bergeron and Garsia that act on symmetric functions, tuned by a pair of parameters $q$ and $t$. They are the beating heart of modern symmetric-function theory: the celebrated operator $\nabla$, which sits at the center of the theory surrounding the space of diagonal harmonics, is the special case $\Delta_{e_n}$. What matters for us is a single question one can ask about the output $\Delta_{e_j} G(k,n)$: is it **Schur positive**?

## What "Schur positive" means, and why it is coveted

Every symmetric function can be written uniquely as a combination of **Schur functions** $s_\mu$, the most important basis in the whole theory. A symmetric function is called *Schur positive* when all the coefficients in this expansion are nonnegative — here, nonnegative combinations of powers of the parameters $q$ and $t$.

Schur positivity is prized far beyond bookkeeping. When it holds, the coefficients almost always *count* something: dimensions of representations, numbers of tableaux, sizes of combinatorial families. A Schur-positive expansion is a promise that a naked algebraic expression is really a shadow of some concrete, countable structure. When positivity fails, that promise is broken — some coefficient dips below zero and no such clean counting interpretation can survive. Deciding *when* an expression is Schur positive is therefore one of the central sports of the subject.

For the Petrie family the answer turns out to be astonishingly clean. The earlier chapters of this story established the verdict for $\nabla = \Delta_{e_n}$ and its iterates $\nabla^r$: $\nabla G(k,n)$ is Schur positive exactly when $k \mid n$. The natural next question is whether the special role of $j = n$ was essential. It is not. The same $k \mid n$ line governs $\Delta_{e_j} G(k,n)$ for *every* choice of $1 \le j \le n$. The elementary input $j$ is a spectator; the arithmetic of $k$ and $n$ calls all the shots.

## The one polynomial that runs the show

Why should a divisibility condition be lurking behind a positivity statement? To see it, specialize all the variables to a single value $x$. The generating product collapses into powers of one modest polynomial, the **Petrie block**:
$$
\mathfrak{p}_k \;=\; 1 + x + x^2 + \cdots + x^{k-1}.
$$
This little polynomial is the arithmetic heart of the entire family. Everything the Petrie functions "know" about the number $k$ is compressed into $\mathfrak{p}_k$, and its behavior is dictated by one schoolbook identity, the telescoping sum:
$$
(x - 1)\,\mathfrak{p}_k \;=\; x^k - 1 .
$$
Read this equation from right to left and it becomes a factorization: $x^k - 1$ splits as $(x-1)$ times $\mathfrak{p}_k$. Since $x^k - 1$ vanishes at exactly the $k$-th roots of unity, and the factor $(x-1)$ mops up the single root $x = 1$, the roots of $\mathfrak{p}_k$ are precisely the **$k$-th roots of unity other than $1$**. For any $k \ge 2$ there genuinely are such roots, sitting evenly spaced around the unit circle in the complex plane like the hour marks on a clock face with the twelve removed.

This clockwork picture is the whole secret. The roots of $\mathfrak{p}_k$ are a marching band of complex numbers $\zeta$ with $\zeta^k = 1$ but $\zeta \ne 1$.

## The divisibility criterion

We can now state the crisp theorem that this article is built around, in fully self-contained form.

> **The Petrie Divisibility Criterion.** Let $k \ge 2$. Then the Petrie block $\mathfrak{p}_k = 1 + x + \cdots + x^{k-1}$ divides $x^n - 1$ if and only if $k$ divides $n$.

Here is the argument, and it is short enough to hold in your head.

**If $k \mid n$**, write $n = km$. Then $x^n - 1 = (x^k)^m - 1$ is divisible by $x^k - 1$ (again by the telescoping identity, now in the variable $x^k$). And $x^k - 1$ is itself divisible by $\mathfrak{p}_k$. Chaining these two divisibilities gives $\mathfrak{p}_k \mid x^n - 1$.

**Conversely, suppose $\mathfrak{p}_k \mid x^n - 1$.** Pick a *primitive* $k$-th root of unity $\zeta$ — a number that cycles through all $k$ powers before returning to $1$. Because $\zeta \ne 1$, it is a root of $\mathfrak{p}_k$, so $\mathfrak{p}_k$ vanishes there. But then the multiple $x^n - 1$ must vanish at $\zeta$ too, which says $\zeta^n = 1$. A primitive $k$-th root satisfies $\zeta^n = 1$ exactly when its order $k$ divides $n$. Hence $k \mid n$.

That is the entire mechanism. The forward direction is pure divisibility of numbers of the form $x^a - 1$; the reverse direction is where the arithmetic truly lives, powered by the existence of a primitive root and the fundamental fact that $\zeta^n = 1$ precisely when $\mathrm{ord}(\zeta) \mid n$.

The criterion is *sharp* — a genuine two-way street, not a one-sided implication. To feel the sharpness, take $k = 3$, so $\mathfrak{p}_3 = 1 + x + x^2$, and ask whether it divides $x^4 - 1$. Since $3 \nmid 4$, the criterion says **no**, and indeed it does not: the primitive cube root of unity kills $\mathfrak{p}_3$ but not $x^4 - 1$. Change the exponent to $6$ and, because $3 \mid 6$, divisibility snaps back into place. This is the "only if" half in action, and it is exactly the kind of non-divisible pair at which a positivity statement would break.

## Why this explains the positivity dichotomy

The connection to Schur positivity is now conceptual rather than mysterious. Applying a delta operator and expanding in the Schur basis is a rich, multivariate process — but its sign behavior is haunted by the same complex numbers that haunt $\mathfrak{p}_k$. The nontrivial $k$-th roots of unity are the points where positivity obstructions concentrate. When $k \mid n$, the relevant powers $x^n$ line up so that the roots of $\mathfrak{p}_k$ cause no trouble, and positivity survives. When $k \nmid n$, a primitive $k$-th root refuses to cooperate, some Schur coefficient is dragged below zero, and positivity fails. The delta operator did not invent the $k \mid n$ threshold; it inherited it, fully formed, from the cyclotomic factorization of the Petrie block.

This is the deeper payoff of isolating $\mathfrak{p}_k$. It converts an infinite positivity question — check every Schur coefficient of a complicated symmetric function — into a **finite spectral test**: evaluate at a single primitive root of unity and watch what happens. That is the sort of certificate that turns an open-ended search into a decisive computation.

## A counting coda

The Petrie block carries one more charming secret, visible the instant you plug in $x = 1$. Every term of $1 + x + \cdots + x^{k-1}$ becomes $1$, so $\mathfrak{p}_k(1) = k$. Raising to the $N$-th power gives the principal specialization
$$
P(k, N; 1) = k^N .
$$
This is not just a number; it is a census. It counts the length-$N$ words you can spell using an alphabet of $k$ letters — one letter for each allowed exponent $0, 1, \ldots, k-1$. So the very object whose *roots* encode a delicate positivity dichotomy has, at the single point $x = 1$, a *value* that counts something utterly elementary. The Petrie block speaks two languages at once: at $x=1$ it counts words, and around the unit circle it enforces divisibility.

## The moral

Delta operators, diagonal harmonics, and Schur positivity can seem forbiddingly technical. Yet at the base of this particular tower sits a polynomial a child could write down, $1 + x + \cdots + x^{k-1}$, whose entire personality is fixed by where it vanishes. Its roots are the $k$-th roots of unity minus the number $1$, and that geometric fact — points evenly spaced on a circle — is what draws the line $k \mid n$ across the whole landscape of Petrie positivity. It is a small, self-contained miracle: a question about the *positivity* of symmetric functions answered by the *arithmetic* of a single generating polynomial, and the two joined at the hip by the ancient, elegant clockwork of the roots of unity.
