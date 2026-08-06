# The Number That Refuses to Say Where It Is

## A journey into constructive analysis, where every real number carries its own instruction manual

---

### A question with no answer

Here is a question that sounds trivial. I hand you a real number $x$ and ask: **is $x$ bigger than zero, or is it zero, or is it less than zero?**

Classically, exactly one of the three holds. This *trichotomy law* is as basic to the real numbers as anything can be. But suppose I hand you $x$ not as a Platonic object but as a *process*: a machine that, when you ask for the $n$-th digit, computes it and hands it over.

$$0.000000\ldots000\ldots$$

Every digit so far is zero. Is the number zero? Or is it $10^{-10^{100}}$? No finite inspection can tell you. If the machine's digits encode "the first place where some famous conjecture fails", then deciding the sign of $x$ means settling the conjecture. Trichotomy, applied to numbers-as-processes, is not a law of arithmetic. It is a demand for an oracle.

This is the fault line that Errett Bishop walked up to in 1967 and, instead of stepping back, walked straight across. His *Foundations of Constructive Analysis* rebuilt real analysis — limits, continuity, roots, integration — with every existence claim backed by a construction. Not a crippled analysis: a *sharper* one. This article follows that rebuilding down to the arithmetic, and to the quantitative facts that emerge when you insist on being explicit — how fast things converge, which constants are optimal, and where the classical theorems break.

---

### Numbers that know their own error bars

Bishop's first move is disarmingly simple. A real number, he says, *is* a sequence of rational approximations — but a sequence that comes with a promise about its own accuracy.

> **Definition.** A **regular sequence of rationals** is a sequence $x_0, x_1, x_2, \ldots$ of rationals satisfying
> $$|x_m - x_n| \;\le\; \frac{1}{m+1} + \frac{1}{n+1} \qquad \text{for all } m, n .$$

Read that as a labelling scheme. The term $x_n$ is *asserted* to be accurate to within $1/(n+1)$; the condition says the assertions are mutually consistent — two approximations claiming those accuracies had better not differ by more than the sum of their error bars.

The difference from the usual Cauchy definition is not cosmetic. A Cauchy sequence says: *for every $\varepsilon$ there exists some $N$ beyond which terms are within $\varepsilon$.* That existential $N$ — the **modulus of convergence** — is exactly the information a computer needs and a classical proof does not supply. Bishop's condition doesn't merely assert a modulus exists; it *fixes* it, once and for all, at $n \mapsto 1/(n+1)$.

And the promise is kept. Writing $\hat x$ for the ordinary real number the sequence converges to:

> **Theorem (explicit modulus).** For every regular sequence and every index $n$,
> $$|\hat x - x_n| \;\le\; \frac{1}{n+1}.$$

The proof is one line: fix $n$ and let $j \to \infty$ in $|x_j - x_n| \le \frac{1}{j+1} + \frac{1}{n+1}$. Want $\pi$ to twelve decimal places? Ask for the $10^{12}$-th term. No search, no waiting, no "eventually". **The index is the precision.**

Two regular sequences denote the same number when their approximations stay within the sum of their error bars: $|x_n - y_n| \le \frac{2}{n+1}$ for all $n$. Something subtle is happening. Constructively you cannot define equality as "the limits coincide", because you have no prior access to the limits — only to the sequences. Equality must be a condition on the *data*, and transitivity becomes a theorem requiring proof. It does hold, because the condition is equivalent to $\hat x = \hat y$. Add that **every** classical real is denoted by some regular sequence — approximate it to within $\frac{1}{2(n+1)}$ and regularity falls out — and you get the reconciliation:

> **Theorem.** Regular sequences of rationals, taken modulo Bishop equality, are in canonical bijection with the classical real numbers.

Constructive analysis is not a *smaller* theory about *fewer* numbers. It is the same numbers, presented with more information. What changes is what you are allowed to *do* with them — and what you get out.

---

### The diagonal that has to be shifted

Completeness is where the bookkeeping starts to bite, and to pay.

Suppose you have a sequence of Bishop reals $x^{(0)}, x^{(1)}, \ldots$, itself regular in the sense that $|\hat x^{(k)} - \hat x^{(l)}| \le \frac{1}{k+1} + \frac{1}{l+1}$. Classically, completeness hands you a limit and says nothing about finding it. Constructively the limit must be *built*, and the natural candidate is the diagonal: the $n$-th approximation of the $n$-th number. It fails. Let
$$x^{(k)}_n \;=\; \frac{1}{k+1} \;+\; (-1)^k \cdot \frac{1}{n+1}.$$
Each $x^{(k)}$ is a perfectly good regular sequence denoting $1/(k+1)$, and these reals form a regular sequence of reals. But the raw diagonal is a wreck: at $n = 0$ it gives $1 + 1 = 2$; at $n = 1$ it gives $\tfrac12 - \tfrac12 = 0$. Those differ by $2$, while regularity permits at most $\frac{1}{1} + \frac{1}{2} = \frac{3}{2}$. The alternating sign has arranged for individually legal errors to conspire.

The fix is to run the diagonal at double speed:

> **Theorem (constructive completeness).** Given a regular sequence of Bishop reals, the sequence $n \mapsto x^{(2n+1)}_{\,2n+1}$ is again regular, and the real $L$ it denotes satisfies
> $$|L - \hat x^{(k)}| \;\le\; \frac{1}{k+1} \qquad \text{for every } k.$$

The shift halves both error contributions — the error of $x^{(2n+1)}$ as a member of the sequence, and the error of its own $(2n+1)$-st approximation — so together they fit the budget $1/(n+1)$. On the alternating family above, the shifted diagonal converges to $0$, the correct limit.

The moral recurs throughout: a classical theorem asserts a limit *exists*; its constructive counterpart is a *formula*, and formulas have to get the constants right.

---

### An order you have to earn

We began with trichotomy. Bishop's replacement makes positivity carry evidence:

> **Definition.** $x > 0$ means: **there exists an index $n$ with** $x_n > \frac{1}{n+1}$. And $x < y$ means: there exists $n$ with $x_n + \frac{2}{n+1} < y_n$.

A proof of $x < y$ is not a bare truth-value. It is a *number* $n$ — a certificate — together with a rational inequality you can check by hand. From it you read a rational lower bound on the gap, $g = y_n - x_n - \frac{2}{n+1} > 0$.

Reassuringly, this witnessed relation agrees exactly with the classical one: $x < y$ in Bishop's sense iff $\hat x < \hat y$. Nothing has been weakened. But the certificate cannot be dispensed with, nor even bounded in advance:

> **Theorem (no uniform witness bound).** For every precision $N$, however large, there are Bishop reals $x < y$ for which **no** index $n \le N$ witnesses the inequality.

The example is embarrassingly simple: $x = 0$ and $y = 1/(N+1)$. At every index $n \le N$ the sequences are closer than the required margin $2/(n+1)$. So the order, though extensionally classical, is not a decidable function of any bounded amount of the approximating data — the digits-of-a-conjecture story, made rigorous.

What replaces trichotomy is **cotransitivity**, and in explicit form it is a genuine algorithm:

> **Theorem (cotransitivity).** Suppose the index $n$ witnesses $x < y$, with rational gap $g$. Let $m$ be *any* index with $\frac{1}{m+1} \le \frac{g}{8}$. Then for **every** third real $z$, a single comparison of the rational $z_m$ against the midpoint $\frac{x_m + y_m}{2}$ decides between $x < z$ and $z < y$ — and the branch you land in is a correct certificate.

Two estimates do the work: at the finer index the approximations have spread out to $y_m - x_m \ge \frac{3g}{4}$, while the required margin $\frac{2}{m+1}$ is at most $\frac{g}{4}$. Whichever side of the midpoint $z_m$ falls, the margin is beaten.

Look at what has happened. Classically, "$x < z$ or $z < y$" is a triviality with no content. Constructively it is a procedure. And the disjunction is *overlapping* — both branches may be true — which is precisely what makes it decidable. Insisting on the exclusive version is what costs you the oracle.

The same pattern gives a *location* principle: for rationals $a < b$, choose $n$ with $\frac{4}{n+1} \le b - a$ and compare $x_n$ with the midpoint; you learn either $a < x$ or $x < b$. The classically trivial exclusive alternative is unavailable; this overlapping version replaces it, with an algorithm attached.

---

### Arithmetic with index shifts, and a computable $\sqrt2$

If reals are sequences, arithmetic is sequence manipulation — and every operation needs a shift to balance the error budget. Addition uses the same trick as the limit, $(x + y)_n = x_{2n+1} + y_{2n+1}$, because two errors of size $\frac{1}{2(n+1)}$ sum to the allotted $\frac{1}{n+1}$.

Multiplication is harder, because errors are amplified by the size of the factors. One first extracts a crude bound from the data itself: since $|x_n - x_0| \le 2$, the integer $B(x) = \lceil |x_0| \rceil + 2$ dominates every $|x_n|$. The product then evaluates both factors at the finer index $M(n+1)$, with $M = B(x) + B(y)$ — a shift proportional to the magnitudes, exactly right since big numbers need more digits before their product is trustworthy.

These are genuinely computable — no oracle, no choice. Here is a real number you can run:
$$\sqrt2_n \;=\; \frac{\lfloor \sqrt{2(n+1)^2} \rfloor}{n+1},$$
with the square root taken as the integer square root. Term $4$ is $7/5$; term $99$ is $141/100$. Each is a rational you can print. The sequence is regular, and the real it denotes squares to $2$. An irrational number, entirely as data.

---

### The intermediate value theorem, and how it really fails

Now the crown jewel — and the classic casualty. The intermediate value theorem says a continuous $f$ with $f(a) \le 0 \le f(b)$ has a root. Constructively this is false, for an interesting reason. Consider the **shelf family** on $[0,3]$, with parameter $t \in [-1,1]$:
$$\mathrm{shelf}_t(x) \;=\; \min\bigl(x - 1,\; \max(t,\; x - 2)\bigr).$$

Every member is $1$-Lipschitz and satisfies $\mathrm{shelf}_t(0) \le 0 \le \mathrm{shelf}_t(3)$, so every member has roots. But *where*? At $t = 1$ the unique root is $x = 1$; at $t = -1$ it is $x = 2$; at $t = 0$ the function vanishes on the whole shelf $[1,2]$.

> **Theorem (Brouwerian counterexample).** There is no continuous $t \mapsto r(t)$ on $[-1,1]$ with $\mathrm{shelf}_t(r(t)) = 0$ for all $t$.

The proof is a two-line trap. A continuous $r$ with $r(1) = 1$ and $r(-1) = 2$ would, by the classical intermediate value theorem applied to $r$ itself, hit both $3/2$ and $7/4$. But a root strictly between $1$ and $2$ forces $t = 0$, so $r(0)$ would have to equal both. Contradiction.

Since every constructively definable function on the reals is continuous, no constructive proof of the exact theorem can exist. And the failure is as bad as the geometry allows:

> **Theorem (quantitative failure).** For **any** assignment of a root to each parameter — continuous or not — and every $\eta > 0$, its oscillation over $|t| \le \eta$ is at least $1$.

Indeed $r(t) = 1$ is forced for $t > 0$ and $r(t) = 2$ for $t < 0$: the values straddle a gap of width $1$ in every neighbourhood of the origin. There is no approximate continuity to salvage.

**What works, first flavour: you can always compute an approximate root.** Suppose $f$ carries a **modulus of uniform continuity** $\omega$ — an explicit function converting a target accuracy into a spatial tolerance, so that $|x - y| \le \omega(\varepsilon)$ guarantees $|f(x) - f(y)| \le \varepsilon$. This is the constructive definition of continuity: not a promise that a tolerance exists, but a formula producing it.

> **Theorem (approximate IVT).** With $f(a) \le 0 \le f(b)$, fix $\varepsilon > 0$ and any $N \ge 1$ with mesh $\frac{b-a}{N} \le \omega(\varepsilon)$. Among the $N+1$ grid points $a + k\frac{b-a}{N}$, the **largest** index $k$ with $f \le 0$ satisfies $|f| \le \varepsilon$ there.

A finite scan, and a two-case argument: if the scan runs to the right endpoint then $f(b)$ is squeezed to zero; otherwise the next grid point has $f > 0$ one mesh away, so the modulus caps the jump at $\varepsilon$.

**Second flavour: with a non-degeneracy hypothesis you get the exact root.** The obstruction in the shelf family was flatness — $\mathrm{shelf}_0$ is constant across $[1,2]$, and admits *no* positive slope bound. So rule flatness out: say $f$ has **slope bound** $c > 0$ if $c(y - x) \le f(y) - f(x)$ whenever $x \le y$.

> **Theorem (constructive IVT).** Then $f$ has a unique root $r$, and for every accuracy $\delta > 0$ the grid search at any mesh $\le \omega(c\delta)$ returns a point within $\delta$ of $r$. The modulus of the root is $\delta \mapsto \omega(c\,\delta)$.

The engine is a one-line estimate: $|f(x)| \le \varepsilon$ implies $|x - r| \le \varepsilon/c$. A small *value* becomes a small *distance*, at exchange rate $1/c$ — and the rate is exactly right: for $f(x) = cx$ on $[-1,1]$, the point $x = \varepsilon/c$ has $|f(x)| = \varepsilon$ and sits at distance *precisely* $\varepsilon/c$ from the root. No constant $\kappa < 1$ can replace the $1$.

---

### Bracketing beats bounding

Here is the twist most treatments skip. The slope bound converts "$|f(x)|$ is small" into "$x$ is near a root" — but that is not what the grid search actually produces, nor what it needs.

> **Theorem (bracketing).** With **no** non-degeneracy hypothesis at all, the sign-change grid search returns a grid point within **one mesh** of a genuine root.

Why? The largest index $k$ with $f \le 0$ has a *bracket*: $f(\text{grid}_k) \le 0 < f(\text{grid}_{k+1})$. A root lives in that interval of width one mesh. The location comes from the **sign change**, not from the smallness of $|f|$.

That distinction is real. The weakest useful non-degeneracy hypothesis is *local non-constancy*: on every interval of length $h$ the function attains absolute value at least $\nu(h)$, for an explicit $\nu$. Consider
$$\mathrm{dip}_\eta(x) \;=\; \min\bigl(x - 1,\; |x - 3| + \eta\bigr) \qquad \text{on } [0,4].$$
It is $1$-Lipschitz, its unique root is $x = 1$, and it satisfies local non-constancy with modulus $\nu(h) = h/8$. Yet at $x = 3$ it dips to $\eta$ — as small as you please — while sitting a full distance $2$ from the only root. **No implication of the form "$|f(x)|$ small $\Rightarrow$ $x$ near a root" follows from local non-constancy alone.** A small value is weak evidence; a sign change is strong evidence. Cash in the bracket.

---

### Suprema, and the price of an oracle

Every nonempty bounded set of reals has a supremum. The classical proof asks, for rational $q$, "is $q$ an upper bound?" — exactly the undecidable question. The constructive move is to *assume the oracle as data*. A set $S$ is **located** if it comes with a procedure $L$ such that for rationals $p < q$: a `true` answer certifies $q$ as an upper bound; a `false` answer produces a member of $S$ above $p$. Both may hold — the gap between $p$ and $q$ gives room — and that overlap is what makes locatedness obtainable in practice.

With this datum the supremum is computed by a **trisection search**: from $[p,q]$, query at $m_1 = p + \frac{q-p}{3}$ and $m_2 = p + \frac{2(q-p)}{3}$, keeping $[p, m_2]$ on `true` and $[m_1, q]$ on `false`. Either way the width shrinks by exactly $2/3$.

> **Theorem (constructive least upper bound).** A nonempty, bounded, located set has a least upper bound, enclosed at stage $n$ by explicitly computed rationals whose separation is exactly $\left(\frac{2}{3}\right)^n (b_0 - a_0)$; and the supremum is itself a Bishop real.

The accounting is honest: the classical decision "is $q$ an upper bound?" manufactures a located datum for free, so the constructive principle is classically equivalent to ordinary completeness. Its entire content is the extra datum — stated openly rather than smuggled in.

**Is $2/3$ any good?** No. Generalise the step: query at fractions $\alpha < \beta$, keeping $[p, p + \beta(q-p)]$ on `true` and $[p + \alpha(q-p), q]$ on `false`. The enclosure invariant survives for every $0 < \alpha < \beta < 1$, with contraction factor exactly $\max(\beta, 1 - \alpha)$. Trisection is $\alpha = \frac13, \beta = \frac23$, giving $\frac23$; but $\alpha = \frac25$, $\beta = \frac12$ gives $\frac35$.

> **Theorem (optimal one-query contraction).** Every one-query scheme has contraction factor strictly greater than $\frac12$; and for every $\eta > 0$ some scheme achieves a factor below $\frac12 + \eta$.

The lower bound is a two-line pigeonhole: if $\beta \le \frac12$ then $\alpha < \frac12$, so $1 - \alpha > \frac12$; otherwise $\beta > \frac12$. Near-optimal schemes crowd both query points symmetrically around the midpoint. The infimum $\frac12$ is the information-theoretic limit — one bit per query, one halving per bit — and it is not attained, because the two query points must be *distinct*: the oracle needs a gap to be honest about. The algorithm pays a strictly positive, arbitrarily small tax for the very ambiguity that makes it implementable.

---

### What it all adds up to

Strip away the philosophy and constructive analysis is a discipline of *bookkeeping*. Classical analysis proves things exist. Constructive analysis proves them with a receipt: here is the sequence, here is the modulus, here is the index at which you may stop.

It is not free. Equality becomes a definition on data. Trichotomy is downgraded to an overlapping cotransitivity. The intermediate value theorem splits into an approximate half that is always true and an exact half paid for with a slope bound. Suprema demand a locatedness oracle that classical mathematics hands out invisibly.

But the payoff is not merely philosophical purity. It is *sharpness*. Because the constants are on the table, you can ask whether they are the right ones — and get answers. The factor $\varepsilon/c$ is attained and cannot be improved. The diagonal shift $n \mapsto 2n+1$ cannot be dropped. The trisection ratio $2/3$ can be improved to anything above $1/2$ but not to $1/2$ itself. The sign-change bracket beats the value bound, and an explicit function proves it.

None of these questions is even *expressible* in a development that only asserts existence. That is the dividend of insisting that every number know where it is — and how well it knows it. Numbers, on this view, are not discovered in a Platonic warehouse; they are made. And a thing that is made can be inspected, measured, optimised — and improved.
