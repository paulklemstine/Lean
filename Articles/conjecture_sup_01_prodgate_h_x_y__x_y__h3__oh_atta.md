# The Ghost in the Multiplier

## How two exponentials learn to multiply — and exactly how badly they fail

### A machine that cannot multiply

Here is a fact that surprises almost everyone who meets it for the first time: the standard building block of a neural network cannot multiply.

A neural network layer computes a weighted sum of its inputs and then applies a fixed one-dimensional function — a *nonlinearity* — to the result. It can add. It can scale. It can bend. What it cannot do, in one step, is take two numbers $x$ and $y$ and hand you back $x\cdot y$. Multiplication is the fundamental *bilinear* operation, and a layer of the form "sum, then squash" is stubbornly univariate: whatever nonlinearity you choose, it only ever sees one number at a time.

And yet multiplication is everywhere in the things we ask networks to model. The kinetic energy $\tfrac12 mv^2$, the gravitational force $Gm_1m_2/r^2$, the attention score $\langle q, k\rangle$ inside a transformer, the covariance $\mathbb{E}[XY]$, the interaction term between two features in a physical law — all products. A network that has to *learn* multiplication from scratch spends much of its capacity approximating something a pocket calculator does exactly.

There is a beautiful trick that gets you out of this bind, and it is nearly two thousand years old in spirit. It is called **polarisation**, and it rests on the schoolboy identity
$$xy = \frac{(x+y)^2 - (x-y)^2}{4}.$$
If your network can square, it can multiply. Squaring is univariate. So: form the sum $x+y$ and the difference $x-y$ with the linear part of the layer, square each with the nonlinearity, subtract, divide by four. Four numbers in, one product out.

This is exactly how a modern class of architectures — networks whose activation is the plain exponential $u \mapsto e^u$, sometimes with a logarithm on the way out — synthesise products. They cannot square exactly, because their nonlinearity is $e^u$, not $u^2$. But they can *approximate* squaring, and beautifully. Take a small scale parameter $h > 0$ and build
$$S_h(u) \;=\; \frac{e^{hu} + e^{-hu} - 2}{h^2}.$$
Two exponential units, two weights, one subtraction. Expand the exponentials as power series and the constants cancel, the linear terms cancel, and what is left is
$$S_h(u) \;=\; u^2 \;+\; \frac{h^2 u^4}{12} \;+\; \frac{h^4 u^6}{360} \;+\; \cdots$$
As $h \to 0$ this converges to the square. It is a *soft* squaring unit — an $\varepsilon$-approximate parabola built out of exponentials.

Feed it into the polarisation identity and you get the **product gate**
$$P_h(x,y) \;=\; \frac{S_h(x+y) - S_h(x-y)}{4},$$
a width-four network that computes $x\cdot y$ to within $O(h^2)$. The natural question — the question this article is about — is: *exactly* how wrong is it?

### Two wrongs that partly cancel

Naively the answer looks easy. The gate has two branches. The branch that squares $x+y$ makes an error of roughly $h^2(x+y)^4/12$ before dividing by four; the branch that squares $x-y$ makes an error of roughly $h^2(x-y)^4/12$. Apply the triangle inequality and you get
$$\bigl|P_h(x,y) - xy\bigr| \;\le\; \frac{h^2\left[(x+y)^4 + (x-y)^4\right]}{24}.$$
Correct, safe — and *wrong in shape*. The tell-tale sign is what happens on the axes. Put $y = 0$. The gate becomes $\bigl(S_h(x) - S_h(-x)\bigr)/4$, and $S_h$ is an even function, so this is **exactly zero** — the gate multiplies by zero perfectly, as it must. But the bound above predicts an error of $h^2 \cdot 2x^4/24 = h^2x^4/12$, which is not zero. The estimate has failed to notice that the two branches make the *same* mistake and cancel it.

That cancellation is the heart of the matter, and it is why the sum $(x+y)^4 + (x-y)^4$ is the wrong quantity. The right one is the **difference**:
$$\text{error} \;\approx\; \frac{h^2\left[(x+y)^4 - (x-y)^4\right]}{48} \;=\; \frac{h^2\,xy\,(x^2+y^2)}{6}.$$
This vanishes on both axes, as it should. It is symmetric in $x$ and $y$, as it should be. And it grows to its largest value at the corner $(1,1)$ of the unit square, where it equals $h^2/3$.

Proving that this is really the truth, and not just a plausible guess, turns out to require a genuinely different idea — and the idea is worth the price of admission.

### Cancellation is not a size statement

Here is the trap. The error of the gate can be written down exactly. Define the *remainder of the hyperbolic cosine*,
$$\gamma(t) \;=\; e^t + e^{-t} - 2 - t^2 \;=\; \frac{t^4}{12} + \frac{t^6}{360} + \frac{t^8}{20160} + \cdots,$$
the part of $2\cosh$ left over after you subtract its quadratic Taylor polynomial. Every coefficient is positive; $\gamma$ is even; $\gamma(0) = 0$. A short computation gives the exact identity
$$P_h(x,y) - xy \;=\; \frac{\gamma\bigl(h(x+y)\bigr) - \gamma\bigl(h|x-y|\bigr)}{4h^2}.$$
No approximation has been made yet. The whole error is a *difference of two values of one function*.

Now, the tempting move: bound $\gamma(a)$ from above by $a^4/6$, bound $\gamma(b)$ from below by $b^4/12$, subtract. This gives $\gamma(a) - \gamma(b) \le a^4/6 - b^4/12$ — and that is not the shape we want, because the two constants don't match. Worse, any strategy of this kind is *provably* doomed. Set $x = y$. Then $a = b$, the difference $\gamma(a) - \gamma(b)$ is exactly zero, and any estimate that bounds the two branches separately with a non-matching pair of constants will report a spurious positive error. You cannot see cancellation by measuring the two things being cancelled.

The escape is to stop asking how *big* $\gamma$ is and start asking how it *moves*. Consider the two "slack functions"
$$t \mapsto \frac{t^4}{6} - \gamma(t) \qquad\text{and}\qquad t \mapsto \gamma(t) - \frac{t^4}{12}.$$
Both turn out to be **increasing** on $[0,1]$. That single fact is enough. If $0 \le b \le a \le 1$, then increasingness of the first says $a^4/6 - \gamma(a) \ge b^4/6 - \gamma(b)$, i.e. $\gamma(a) - \gamma(b) \le (a^4 - b^4)/6$; the second gives the matching lower bound $(a^4-b^4)/12$. Both inequalities now involve the *difference of fourth powers* — exactly the shape the axis test demanded. Cancellation has been captured, not by comparing sizes, but by comparing rates of change.

Proving the two slack functions increase is itself a nice exercise: differentiate, and it reduces to sandwiching the hyperbolic sine, $t^3/3 \le e^t - e^{-t} - 2t \le t^3/2$ on $[0,1]$.

Substituting back into the exact identity with $a = h(x+y)$ and $b = h|x-y|$ yields, for $0 < h \le \tfrac12$ and $x,y$ in the unit square, a clean two-sided statement:
$$\frac{h^2\left[(x+y)^4 - (x-y)^4\right]}{48} \;\le\; P_h(x,y) - xy \;\le\; \frac{h^2\left[(x+y)^4 - (x-y)^4\right]}{24}.$$
Notice something the older estimate could never express: the error is always **non-negative**. The gate never undershoots. On the positive quadrant it always returns slightly *more* than the true product. That one-sidedness will matter later.

A sharper local analysis pins the constant down exactly: the true leading term is the *lower* end of that sandwich,
$$\left| P_h(x,y) - xy - \frac{h^2\,xy\,(x^2+y^2)}{6} \right| \;\le\; \frac{h^4}{21}.$$

### The corner theorem, and why no Taylor series is needed

The pleasant surprise is that the supremum over the unit square can be computed *exactly*, for every $h > 0$, with no series expansion whatsoever.

Go back to the identity: the error is $\bigl[\gamma(h(x+y)) - \gamma(h|x-y|)\bigr]/(4h^2)$. And $\gamma$ is increasing on $[0,\infty)$ — a fact equivalent to nothing more exotic than $\sinh t \ge t$. So the error is largest exactly where the first argument $h(x+y)$ is largest and the second $h|x-y|$ is smallest. On $[0,1]^2$ that is the single point $(1,1)$: the sum is maximal at $2$, the difference is minimal at $0$. Therefore, for every $h>0$,
$$\sup_{(x,y)\in[0,1]^2}\bigl|P_h(x,y) - xy\bigr| \;=\; \frac{\gamma(2h)}{4h^2} \;=\; \frac{e^{2h} + e^{-2h} - 2 - 4h^2}{4h^2},$$
and the supremum is genuinely attained, at the corner. Expanding, this is
$$\frac{h^2}{3} + \frac{2h^4}{45} + \frac{h^6}{315} + \cdots$$
So the leading constant is $1/3$; and the $O(h^4)$ correction, far from being an unavoidable smudge, is a completely explicit convergent series. The original conjecture — supremum $= h^2/3 + O(h^4)$, attained at $(1,1)$ — is not merely true; it is a shadow of an identity.

### The obstruction: you cannot patch it up

Once you know the error is $h^2 xy(x^2+y^2)/6$, an engineer's instinct kicks in: *calibrate it away*. Multiply the gate's output by a well-chosen gain $\lambda$ slightly below one and the systematic overshoot should vanish.

It does not. The reason is one factor: $x^2 + y^2$. The error is not proportional to $xy$, so no single multiplicative constant can absorb it. Probe the gate at $(1,1)$, where the leading error is $h^2/3$ relative to a true product of $1$, and at $(1,\tfrac12)$, where the leading error is $5h^2/48$ relative to a true product of $\tfrac12$. The relative errors are $h^2/3$ and $5h^2/24$ — different numbers. A gain that fixes one ruins the other. Quantitatively: for every $h \in (0,\tfrac12]$ and every real $\lambda$ whatsoever, including one allowed to depend on $h$,
$$\max\Bigl\{\ \bigl|\lambda P_h(1,1) - 1\bigr|,\ \bigl|\lambda P_h(1,\tfrac12) - \tfrac12\bigr|\ \Bigr\} \;\ge\; \frac{h^2}{100}.$$

The obvious next thought is more ambitious. The gate already *contains* two soft-squaring units, $S_h(x)$ and $S_h(y)$ — why not reuse them as a correction term? Build the read-out
$$N(x,y) \;=\; \lambda\, P_h(x,y) \;+\; \mu\, S_h(x) \;+\; \nu\, S_h(y) \;+\; \kappa,$$
tune all four coefficients, and hope the $h^2$ term dies. This is a genuinely free lunch if it works: no new units, no new depth, just a smarter linear read-out.

It does not work either, and the proof is a small gem. Take any function $F$ of two variables and any axis-parallel rectangle with corners $(a,b), (a,c), (d,b), (d,c)$, and form the **mixed second difference**
$$D[F] \;=\; F(a,b) - F(a,c) - F(d,b) + F(d,c).$$
This functional annihilates every function of $x$ alone, every function of $y$ alone, and every constant — no estimates involved, just algebra. So applying $D$ to the error of $N$ makes $\mu$, $\nu$ and $\kappa$ vanish *identically*. They were never going to help.

Apply $D$ on the rectangle with corners $(1,1), (1,0), (0,1), (0,0)$. Three of those four points lie on an axis, where the gate is exactly right and $S_h(0) = 0$; only the corner survives. The result is the single scalar equation $\lambda P_h(1,1) - 1$. Do the same on the rectangle anchored at $(\tfrac12,\tfrac12)$ and you get $\lambda P_h(\tfrac12,\tfrac12) - \tfrac14$. Now the two probes disagree: $P_h(1,1) \approx 1 + h^2/3$ while $4P_h(\tfrac12,\tfrac12) \approx 1 + h^2/12$. The combination that would have to vanish for both equations to be small sees a gap of order $h^2/4$, forcing $|\lambda| < \tfrac12$ — at which point the first equation is nowhere near zero. Conclusion: for every $h \in (0,\tfrac12]$ and *all* real $\lambda,\mu,\nu,\kappa$, the error of $N$ is at least $h^2/210$ somewhere on the unit square. In asymptotic terms, no affine read-out is ever $O(h^4)$.

The $\Theta(h^2)$ rate is not a normalisation artefact. It is the architecture speaking.

### Universality: the constant $1/3$ was never about exponentials

Here is where the story turns from an audit of one gadget into a small theory.

Nothing in the corner argument used the exponential. Call $g$ an **even generator** if it has the form $g(t) = t^2 + \gamma_g(t)$ where the remainder $\gamma_g$ is even, vanishes at the origin, and is non-decreasing on $[0,\infty)$. Any power series $\sum_{k\ge2} c_{2k}t^{2k}$ with non-negative coefficients qualifies. Build the corresponding polarisation gate
$$G_h(x,y) \;=\; \frac{g\bigl(h(x+y)\bigr) - g\bigl(h(x-y)\bigr)}{4h^2}.$$
Then, for every such generator and every $h > 0$: the gate never undershoots on the positive quadrant, and
$$\max_{[0,1]^2}\bigl|G_h(x,y) - xy\bigr| \;=\; \frac{\gamma_g(2h)}{4h^2} \;=\; \frac{g(2h) - 4h^2}{4h^2},$$
attained at $(1,1)$. Monotonicity alone does all the work.

Three consequences follow immediately, and they read like design rules.

**A monotone design criterion.** If one generator's remainder is pointwise below another's, its gate is uniformly better on the square. Minimising the remainder really does minimise the worst-case error — no trade-off, no hidden regime where the ranking flips.

**A universal constant.** If $\gamma_g(t) = c\,t^4 + O(t^6)$, the maximal error is $4c\,h^2 + O(h^4)$. The famous $1/3$ is nothing but $4c$ with $c = 1/12$, the quartic Taylor coefficient of $2\cosh$. Change the activation and the constant changes in exactly one place.

**A sanity check at the edges.** For the pure quartic generator $g(t) = t^2 + c\,t^4$ the maximum is *exactly* $4ch^2$, with no remainder at all — proving that the $O(h^4)$ in the exponential case comes entirely from the sextic and higher Taylor coefficients of $2\cosh$. And at $c = 0$, $g(t) = t^2$, the gate is exact: the square activation multiplies perfectly, which is the polarisation identity itself.

Is the monotonicity hypothesis really needed, or is it a technical convenience? It is needed. Take $g(t) = t^2 - t^4$, whose remainder $-t^4$ decreases on $[0,\infty)$. The closed-form recipe would predict a maximum of $-4h^2$ — negative, and therefore not the maximum of an absolute value. The true maximum is $+4h^2$, still at the corner but with the opposite sign, since this gate systematically *under*shoots. The hypothesis is load-bearing, and the counterexample shows precisely what breaks.

### Consequences you can build on

Two applications make the sharp constant pay for itself.

**Quadratic forms, threefold cheaper.** Any quadratic form $\sum_{i,j} A_{ij}x_ix_j$ on $[0,1]^n$ can be computed by one layer of these gates. Summing the sharp pointwise bound gives a total error of at most $\bigl(h^2/3 + h^4/21\bigr)\lVert A\rVert_1$, where $\lVert A\rVert_1 = \sum_{i,j}|A_{ij}|$ — a threefold improvement over the crude $h^2\lVert A\rVert_1$, uniformly in the dimension. Since $h$ controls the dynamic range of the exponentials (and hence the numerical conditioning of the whole layer), a factor of three in the constant is a factor of $\sqrt3$ in the $h$ you can afford.

**Errors add; they do not compound.** Chain gates into a tree to compute a monomial $xyz$ and the obvious worry is multiplicative blow-up: each gate overshoots, the next gate amplifies the overshoot, and the error compounds like $(1+h^2/3)^d - 1$. It does not. The key is a *box* version of the corner theorem: on any square $[0,M]^2$ with $2Mh \le 1$, the error is at most $M^4h^2/3 + M^6h^4/22$ — the $M^4$ scaling is exactly what makes chaining tractable. A gate maps $[0,1]^2$ into $[0,\tfrac{33}{32}]$ for $h \le \tfrac14$, a mere $3\%$ overshoot, and feeding that range into the box bound for the second gate gives a total two-gate error of at most $\tfrac34 h^2$ — against a purely additive prediction of $\tfrac23 h^2$. Within $13\%$ of pure additivity, with no compounding term in sight. And because every gate overshoots, the errors in a product tree can never conspire adversarially; they accumulate in one direction, which is exactly the mechanism behind linear rather than geometric growth.

### What the story is really about

Strip away the architecture and a single idea remains. A polarisation gate makes two errors, and asking how large each one is tells you nothing, because they largely cancel. The cancellation is invisible to any argument that estimates the branches separately — a fact one can make precise: on the diagonal $x=y$ the cancellation is total, so any separate-branch bound must be exact there, and none is.

What *is* visible is monotonicity. The error is the increment of a single increasing function between two points, $h|x-y|$ and $h(x+y)$. Once you see it that way, the location of the maximum is obvious, the closed form is free, the universality across activations is automatic, and the necessity of the monotonicity hypothesis comes with its own counterexample.

There is a general lesson in that, and it is not confined to neural networks. Whenever an approximation scheme is built by polarising a univariate approximant — and this includes a great many numerical-differentiation stencils, kernel expansions, and finite-difference schemes — the error is a *difference*, not a *sum*, of remainders. Estimating it as a sum is safe and lossy, and the loss is not a constant factor: it is the difference between an error that vanishes on the axes and one that does not. The cure is always the same. Do not measure the remainder. Watch it move.

