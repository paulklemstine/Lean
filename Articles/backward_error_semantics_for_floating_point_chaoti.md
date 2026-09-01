# The Computer Was Never Wrong — It Was Solving a Different Problem

## A folk theorem, and why it is only half true

Ask a working scientist what happens when you simulate a chaotic system on a computer and you will hear some version of the same story. Chaos amplifies errors exponentially. Your computer stores numbers only to about sixteen decimal digits. Therefore, after a few dozen steps, the trajectory on your screen has nothing whatsoever to do with the trajectory you asked for. The picture is pretty, but it is a picture of rounding noise.

This story is not wrong. But it hides a beautiful and much sharper fact, and the sharper fact is the subject of this article.

The rounding is not noise. It is not random, it is not a fog, it is not an unmodelled disturbance. **A floating-point run of a polynomial iteration is an exact, error-free run of a slightly different polynomial iteration.** Not approximately. Exactly. The machine did not make a mistake. It solved a neighbouring problem, perfectly.

Once you say it that way, the analysis splits cleanly into two independent halves that the folk theorem tangles together:

1. **Semantics.** *Which* neighbouring problem did the machine solve, and how near is it to the one you asked for? This question has nothing to do with chaos. It is a question about arithmetic, and the answer is a clean formula in the machine's precision and the sizes of the intermediate numbers.
2. **Dynamics.** Given that the machine solved a neighbouring problem, how far can its answer drift from yours? *This* is where chaos lives, and only here.

The rest of this article is a tour of what happens when you insist on that separation and follow it all the way to explicit, checkable numbers.

---

## What a computer actually does to a number

Fix a machine. When it adds two numbers it does not return $a+b$; it returns the nearest representable number to $a+b$. The classical way to model this — the model that has underpinned numerical analysis since the 1960s and which is exactly right for IEEE-754 arithmetic as long as no result overflows, underflows, or produces an infinity or a NaN — is to say that every arithmetic operation returns

$$\mathrm{fl}(a \circ b) = (a \circ b)(1 + e), \qquad |e| \le u,$$

where $\circ$ is $+$, $-$, or $\times$, and $u$ is a single number called the **unit roundoff**: $u = 2^{-24}$ for single precision, $u = 2^{-53} \approx 1.1 \times 10^{-16}$ for the double precision that most scientific code uses.

That inequality $|e| \le u$ is the *entire* content of the hypothesis "the execution avoided overflow and exceptional values." Nothing else about bit layouts, exponent ranges, or subnormals is needed. Everything below therefore applies verbatim to single precision, double precision, quad precision, and to any arithmetic that rounds faithfully.

Errors do not add; they compound. If a computation performs $k$ roundings in sequence, the accumulated distortion factor is a product $(1+e_1)\cdots(1+e_k)$, which sits within

$$\gamma_k(u) := (1+u)^k - 1$$

of $1$. This quantity is the accountant of the whole theory. It is nonnegative, increases with $k$, and — when $ku < 1$, which is essentially always in practice — obeys the classical estimate $\gamma_k(u) \le ku/(1-ku)$, so for realistic $k$ it is simply "$ku$, give or take." For double precision and $k = 6$ this is about $6.7 \times 10^{-16}$.

---

## The first theorem: your polynomial was never the one you typed

Almost every scientific computation of a polynomial uses Horner's rule, the nested form
$$a_0 + x\,(a_1 + x\,(a_2 + \cdots)).$$
It is the standard because it uses the fewest operations. Each of the $n$ nesting levels costs one multiplication and one addition: two roundings per level.

Here is the central result.

> **Backward-Error Semantics for Rounded Horner Evaluation.** Let $p(x) = a_0 + a_1x + \cdots + a_{n-1}x^{n-1}$ and let $\widehat{p}(x)$ be the value produced by evaluating $p$ at $x$ by Horner's rule in floating-point arithmetic with unit roundoff $u$, in a run free of overflow and exceptional values. Then there exist *real* numbers $b_0, \dots, b_{n-1}$ with
> $$|b_i - a_i| \le \gamma_{2n}(u)\,|a_i| \quad \text{for every } i,$$
> such that
> $$\widehat{p}(x) = b_0 + b_1 x + \cdots + b_{n-1}x^{n-1} \quad \textbf{exactly}.$$

Read that again slowly. There is no error term, no inequality, no "approximately." The number your machine printed is the *exact* value, at the *exact* point you supplied, of a polynomial whose coefficients agree with yours to fifteen or sixteen significant digits each.

The proof is an induction that peels off one Horner level at a time. At the outermost level the machine computes $\mathrm{fl}(a_0 + x \otimes v)$ where $v$ is whatever the inner levels returned. Two roundings occur: one in the multiplication, contributing a factor $1+e_2$, and one in the addition, contributing $1+e_1$. Expanding, the result equals
$$a_0(1+e_1) + x \cdot v \cdot (1+e_1)(1+e_2).$$
So the constant coefficient acquires the factor $1+e_1$ — a relative distortion of at most $u$ — while *every* coefficient inherited from the inner polynomial acquires the common factor $(1+e_1)(1+e_2)$, which lies within $\gamma_2(u) = 2u + u^2$ of $1$. Since relative distortions compose — a factor within $\gamma_a$ of $1$ times a factor within $\gamma_b$ of $1$ is within $\gamma_{a+b}$ of $1$ — the inductive bound $\gamma_{2(n-1)}$ on the inner coefficients upgrades to $\gamma_{2n}$ on the outer ones. Two roundings per level, $n$ levels, exponent $2n$. The bookkeeping is forced.

Notice what the theorem does *not* say. It does not say the answer is close to $p(x)$ — that depends on how sensitive $p$ is at $x$, and near a root of a badly conditioned polynomial a fifteenth-digit change in the coefficients can move the value by a hundred percent. The backward statement is strictly stronger and more honest: it tells you exactly what problem was solved, and lets you decide separately whether that problem was close enough to yours.

Indeed, the familiar forward bound *follows* from it in three lines. Coefficientwise closeness plus the triangle inequality gives

> **Local Defect Certificate.** $\ \bigl|\widehat{p}(x) - p(x)\bigr| \le \gamma_{2n}(u)\displaystyle\sum_{i} |a_i|\,|x|^i.$

The right-hand side is exactly the "compositional expression in the unit roundoff and the intermediate magnitudes" one wants: precision on the left factor, geometry of the data on the right. And it cannot be improved in order: in the adversarial arithmetic where every operation rounds up by exactly $u$, evaluating the constant polynomial $a$ produces a defect of precisely $u|a|$, at least a third of the certified bound. No cleverness will replace the first-order term in $u$ by something of order $u^2$.

---

## The second theorem: an execution is a pseudo-orbit, on the nose

Now iterate. You want the orbit $x_0, p(x_0), p(p(x_0)), \dots$ of a polynomial map. Your program computes $x_{n+1} = \widehat{p}(x_n)$, feeding rounded output back in as input.

Dynamicists have a name for a sequence that *almost* follows a map: a **$\delta$-pseudo-orbit**, meaning $|x_{n+1} - p(x_n)| \le \delta$ for each step. Pseudo-orbits are the input to a whole industry of shadowing theorems. What the backward result buys us is a certificate that a real program produces one, with a $\delta$ you can compute:

> **Semantic Translation Theorem.** Let a program iterate $p$ by Horner's rule in floating-point arithmetic with unit roundoff $u$, and suppose it is *observed* that every iterate satisfies $|x_k| \le B$ for $k \le N$. Then $(x_k)_{k \le N}$ is an exact $\delta$-pseudo-orbit of the exact real map $p$, with
> $$\delta = \gamma_{2n}(u) \sum_i |a_i| B^i.$$
> Moreover each step is *exactly* a step of some polynomial map whose coefficients lie within relative distance $\gamma_{2n}(u)$ of the nominal ones: the execution is the exact orbit of a nonautonomous perturbation of your system.

Two things deserve emphasis. First, no hypothesis about the dynamics appears — no Lyapunov exponent, no hyperbolicity, no chaos. The semantics layer is unconditional. Second, the hypothesis that *is* used, "the iterates were observed to stay within $B$," is not an assumption about the world; it is a runtime check your program can test while running, and passing it is precisely the certificate that no overflow occurred.

---

## The third theorem: now, and only now, let chaos in

With a certified $\delta$ in hand, we hand the problem to dynamics.

> **Finite-Time Shadowing.** If $f$ is $L$-Lipschitz on a region containing both a $\delta$-pseudo-orbit $(x_k)$ and the true orbit through $x_0$, then for all $n \le N$,
> $$\bigl|x_n - f^{\,n}(x_0)\bigr| \le \delta\,(1 + L + \cdots + L^{n-1}) = \delta\,\frac{L^n - 1}{L - 1}.$$

The proof is the obvious induction: each new step adds a fresh defect $\delta$ and multiplies the accumulated discrepancy by at most $L$.

This is where the exponential enters, and the theorem is exactly as pessimistic as reality allows:

> **Sharpness.** For every $L \ge 0$ and $\delta \ge 0$ there exist a map that is exactly $L$-Lipschitz (indeed $|f(a) - f(b)| = L|a-b|$ for all $a,b$) and a sequence whose defect is exactly $\delta$ at every step, for which $|x_n - f^{\,n}(x_0)|$ *equals* $\delta(L^n-1)/(L-1)$ for every $n$.

The witness is disarmingly simple: take $f(z) = Lz$ and $x_{n+1} = Lx_n + \delta$ from $x_0 = 0$. The true orbit stays at $0$, the pseudo-orbit is the geometric sum. So the exponential blow-up is *not* an artifact of the arithmetic model or of sloppy estimation. Even a machine whose only sin is a constant defect $\delta$ per step is displaced by exactly that much. Chaos really does what it is accused of — but it does it in the dynamics layer, downstream of anything to do with floating point.

### The logistic map, with real numbers attached

Put the layers together on the standard poster child of chaos, $f(z) = 4z(1-z)$ on $[0,1]$, computed by Horner from the coefficient list $(0, 4, -4)$ in IEEE double precision.

The semantics layer: three coefficients, so $2n = 6$ roundings' worth of distortion; the magnitude functional at $B=1$ is $|0| + |4| + |-4| = 8$; and $\gamma_6(2^{-53}) \le 12 \cdot 2^{-53}$, so
$$\delta \le 2^{-46} \approx 1.4 \times 10^{-14}.$$
The dynamics layer: $f$ is $4$-Lipschitz on $[0,1]$. Composing:

> **Certified Shadowing of a Double-Precision Logistic Run.** Let $x_0 \in [0,1]$ and let $(x_k)$ be the floating-point orbit; suppose the run is observed to remain in $[0,1]$ for $N$ steps. Then for all $n \le N$,
> $$\bigl|x_n - f^{\,n}(x_0)\bigr| \le 2^{-46}\,\frac{4^n - 1}{3}.$$

Everything in that bound is explicit and everything is attributable. The $2^{-46}$ came only from the arithmetic. The $(4^n-1)/3$ came only from the dynamics. They never mixed.

Set the bound equal to $1$ — the diameter of the state space, beyond which the certificate says nothing — and it goes vacuous at about $n = 23$ steps, matching the practitioners' rule of thumb that one loses a decimal digit every $0.6$ iterations at this Lyapunov exponent.

---

## Two ways to do better

Twenty-three steps is a discouraging horizon. The layered picture says where to push, and both pushes work.

### Push one: stop insisting on the same starting point

The bound above tracks *forward* from a fixed initial condition, and asks the true orbit to start at exactly the point the program started at. That is a demand, not a necessity. Classical hyperbolic dynamics lets you build the shadowing orbit *backwards* along inverse branches, letting the initial condition move a little — and then the contraction of the inverse branches beats the accumulation of defects.

> **Uniform-in-Time Shadowing for Expanding Maps.** Suppose $f$ admits inverse branches $g_n$ (so $f(g_n(z)) = z$) each contracting by $1/\lambda$ with $\lambda > 1$, and compatible with the pseudo-orbit in the sense $g_n(f(x_n)) = x_n$. Then every $\delta$-pseudo-orbit of $f$ of length $N$ is shadowed by a *genuine* orbit $(y_n)$ of $f$ with
> $$|y_n - x_n| \le \frac{\delta}{\lambda - 1} \quad \text{for all } n \le N,$$
> **independently of $N$.**

The proof runs the induction backwards along the horizon: if the tail from time $1$ is already shadowed to within $E$, then pulling back through one inverse branch gives an error at time $0$ of at most $(\delta + E)/\lambda$, and the fixed point of $E \mapsto (\delta+E)/\lambda$ is $\delta/(\lambda-1)$. The exponential vanishes because the induction *contracts* instead of expanding.

Instantiate it on the expanding cubic $p(z) = z^3 + 2z$, which satisfies $|p(a)-p(b)| \ge 2|a-b|$ everywhere, is therefore injective, and is surjective by the intermediate value theorem, so it has a global inverse that is $\frac12$-Lipschitz. Then:

> Any finite double-precision run of $z \mapsto z^3 + 2z$ by Horner's rule, observed to stay within magnitude $B$, is shadowed by an *exact* real orbit of the same map with error at most $\gamma_8(u)\,(2B + B^3)$ at every step — a bound that does not grow with the number of steps.

For $B=1$ and double precision that is about $1.8 \times 10^{-15}$, forever. Ten billion iterations, same bound. The exponential catastrophe was never about floating point; it was the price of a needlessly rigid question.

Expansivity is genuinely required and the theorem does not quietly subsume the logistic case: $4z(1-z)$ has a critical point at $z=\frac12$ where the derivative vanishes, so it admits no uniformly contracting global inverse branch.

### Push two: use what the run actually did

The constant $L=4$ for the logistic map is the *worst* expansion over $[0,1]$, achieved only at the endpoints. A run that spends most of its time near the middle expands far less. The local factor at a point $a$ is $|f'(a)| = |4-8a|$, and one has, for all comparison points $b \in [0,1]$,
$$|f(a) - f(b)| \le 4\max(a,\,1-a)\,|a-b|,$$
a quantity lying in $[2,4]$ and computable *from the numbers on your screen*.

> **Nonautonomous (A-Posteriori) Shadowing.** With observed local expansion factors $L_0, L_1, \dots$, the shadowing error obeys the explicit recursion
> $$E_0 = 0, \qquad E_{n+1} = \delta + L_n E_n,$$
> and $|x_n - f^{\,n}(x_0)| \le E_n$ for all $n \le N$. When all $L_k$ equal a constant $L$ this recursion reproduces $\delta(L^n-1)/(L-1)$ exactly, so nothing is lost — but when they vary, everything local is gained.

Applied to a double-precision logistic run staying in $[0,1]$, this gives $|x_n - f^{\,n}(x_0)| \le E_n$ with $\delta = 2^{-46}$ and $L_k = 4\max(x_k, 1-x_k)$. This is an *a-posteriori* certificate: it is not a theorem you prove in advance about all runs, it is a number your program computes about *its own* run, alongside the run. For an orbit equidistributed with respect to the natural invariant measure of the logistic map, the typical local factor is well below $4$, and the certified horizon extends.

---

## An unexpected corollary: the program, not the function

Here is a fact that shows the backward viewpoint is about *code*, not mathematics. Consider the same logistic map written the way a programmer would naturally write it:

```
y = r * (x * (1 - x))
```

Three operations, three roundings. Trace them: the subtraction contributes $1+e_1$, the inner multiplication $1+e_2$, the outer one $1+e_3$, and the output is

$$r\,(1+e_1)(1+e_2)(1+e_3)\cdot x(1-x).$$

All three distortions collect onto the single parameter $r$.

> **Structural Backward Error.** The floating-point evaluation of $r \otimes (x \otimes (1 \ominus x))$ is *exactly* the logistic map of the same family at a detuned parameter $r'$ with $|r' - r| \le \gamma_3(u)|r|$. Consequently a whole floating-point logistic run is the exact orbit of a nonautonomous logistic family whose parameters all lie within relative distance $\gamma_3(u)$ of the nominal $r$.

Your simulation of the logistic map at $r = 3.9$ is not a noisy logistic map. It is a perfectly clean logistic map whose knob wobbles in the sixteenth digit. That is a far more informative statement, and it is not a property of the *function* $r x(1-x)$ — it is a property of the *expression* you wrote. Expand the same function as $rx - rx^2$ and the parameter $r$ appears twice, receiving two independent distortions that need not agree; the result is generally not any logistic map at all. The evaluation scheme, not the polynomial, decides whether structural backward error is available. That observation — that structural backward error is a syntactic invariant of the expression graph, governed by how many times each parameter appears — is one of the sharp questions this line of work leaves open.

There is a warning attached, and it is the reason the runtime check is load-bearing. If $r$ wobbles *up* past $4$, the unit interval stops being invariant: the midpoint maps to $r/4 > 1$ and escapes. So arbitrarily small parameter detuning can change the qualitative global behaviour, and no purely a-priori argument can dispense with the observed hypothesis "the run stayed in $[0,1]$."

---

## What to take away

The received wisdom says numerical simulation of chaos is untrustworthy. The refined statement is more interesting and more useful:

- Floating-point execution of a polynomial iteration is **not** an approximation. It is an exact computation on perturbed data, and the perturbation is bounded by an explicit expression in the machine precision and the observed magnitudes.
- The resulting pseudo-orbit certificate is **unconditional**: it needs nothing about the dynamics.
- Chaos then enters through a single, isolated, and *sharp* dynamical factor: $(L^n-1)/(L-1)$ forward, or nothing at all if you allow the shadowing orbit to start elsewhere and the map expands.
- Whether your program admits a *structural* backward error — an exact member of the intended family, at a detuned parameter — depends on how you wrote the expression, not on which function it computes.

The machine, in short, was never lying to you. It was answering a slightly different question, and the whole content of the theory is that you can say precisely which one. Once you know that, deciding whether to trust the picture on your screen stops being folklore and becomes arithmetic.
