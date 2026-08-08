# The Constant That Refuses to Be a Fraction

## A hunt for $\gamma$, in which information theory, a nineteenth-century series, and a finite arithmetic check all meet

There are three great constants in mathematics that everyone meets sooner or later. Two of them, $\pi$ and $e$, have been thoroughly interrogated: both are known to be irrational, both are known to be transcendental, and the proofs are classics. The third one is the odd one out.

It is called the **Euler–Mascheroni constant**, written $\gamma$, and it is defined by one of the most innocent-looking limits in all of analysis:

$$\gamma \;=\; \lim_{n\to\infty}\left(1 + \frac12 + \frac13 + \cdots + \frac1n \;-\; \log n\right) \;=\; 0.5772156649\ldots$$

The harmonic sum $H_n = 1 + \frac12 + \cdots + \frac1n$ grows without bound, but only barely — it creeps upward like $\log n$. The constant $\gamma$ measures the permanent gap between the staircase and the curve it is shadowing.

Here is the scandal: **nobody knows whether $\gamma$ is rational.** Not whether it is transcendental — whether it is a *fraction*. Three centuries after Euler introduced it, we cannot rule out the possibility that $\gamma$ is some enormous ratio of two integers. It is one of the most embarrassing open questions in elementary mathematics.

This article is about what you *can* prove, and about a rather satisfying way of getting there: by reading $\gamma$ as an accumulation of *information*, squeezing that accumulation between two simple rational functions, and then converting the squeeze into a hard arithmetic statement about which fractions $\gamma$ is definitely not.

---

## $\gamma$ as accumulated surprise

Start with a change of viewpoint. Rather than treating $\gamma$ as a limit of differences, write it as a sum of small positive pieces. Define the **approximants**

$$g_n \;=\; H_n - \log(n+1),$$

which climb steadily up towards $\gamma$ from below. The increments are

$$t_k \;=\; g_{k+1} - g_k \;=\; \frac{1}{k+1} - \log\!\frac{k+2}{k+1}, \qquad k = 0, 1, 2, \dots$$

and telescoping gives

$$\gamma \;=\; \sum_{k=0}^{\infty} t_k, \qquad t_k > 0 .$$

Now the surprise. These increments are not just some algebraic residue. Each one is a **Kullback–Leibler divergence** — the standard information-theoretic measure of how distinguishable two probability distributions are.

Take the exponential distribution with rate $a$: the waiting-time law with density $a e^{-ax}$. The information gained by learning that your data came from rate $a$ when you had been assuming rate $b$ is

$$D(a\,\|\,b) \;=\; \log\frac{a}{b} + \frac{b}{a} - 1 \;\ge\; 0,$$

with equality exactly when $a = b$. Plug in $a = k+1$ and $b = k+2$:

$$D(k+1 \,\|\, k+2) \;=\; \log\frac{k+1}{k+2} + \frac{k+2}{k+1} - 1 \;=\; \frac{1}{k+1} - \log\frac{k+2}{k+1} \;=\; t_k .$$

So

$$\boxed{\;\gamma \;=\; \sum_{k=0}^{\infty} D\big(\mathrm{Exp}(k+1)\,\big\|\,\mathrm{Exp}(k+2)\big).\;}$$

**Euler's constant is the total information separating a chain of exponential waiting-time laws with rates $1, 2, 3, 4, \dots$** Each step you climb the ladder of rates you gain a little information; the total gained over the infinite ladder is $0.5772\ldots$. That the answer is finite is precisely the statement that the harmonic staircase stays a bounded distance from the logarithm.

---

## Squeezing every step

If you want to know $\gamma$ precisely, you need to know each $t_k$ precisely — and in a form you can compute with. Logarithms are awkward; rational functions are not. So the first result is a **purely rational squeeze**:

> **Theorem (rational squeeze of the summands).** For every $k \ge 0$,
> $$\frac{1}{2(k+2)^2} \;\le\; \frac{1}{2(k+1)(k+2)} \;\le\; t_k \;\le\; \frac{1}{2(k+1)^2}.$$

The two outer bounds pinch $t_k$ to within a factor that tends to $1$: both ends behave like $\tfrac12 k^{-2}$. At $k=4$, for instance, the bounds read $0.01389 \le 0.01667 \le t_4 = 0.017678 \le 0.02$.

Where does such a squeeze come from? Not from Taylor series with remainder terms — those are painful to make effective. It comes from a trick that is almost embarrassingly simple, and which powers everything else in this story.

Consider the **logarithmic ratio function**

$$\Lambda(z) \;=\; \log\frac{1+z}{1-z}, \qquad 0 \le z < 1.$$

Its derivative is $\Lambda'(z) = \frac{2}{1-z^2}$ — a rational function, exactly. Now suppose you want to prove $\Lambda(z) \le U(z)$ for some candidate rational $U$. Check that $U(0) = \Lambda(0) = 0$, then differentiate the difference and check that $U'(z) - \Lambda'(z) \ge 0$. Both are rational functions, so the check is pure algebra — clear denominators and confirm a polynomial is nonnegative. No estimates, no error terms, no hand-waving. The derivative *is* the certificate.

Three certificates suffice:

- **Lower:** $\;2z + \tfrac{2}{3}z^3 \le \Lambda(z)$, because $\Lambda'(z) - (2 + 2z^2) = \dfrac{2z^4}{1-z^2} \ge 0.$
- **Crude upper:** $\;\Lambda(z) \le \dfrac{2z}{1-z^2}$, because $\dfrac{d}{dz}\dfrac{2z}{1-z^2} - \Lambda'(z) = \dfrac{4z^2}{(1-z^2)^2} \ge 0.$
- **Sharp upper:** $\;\Lambda(z) \le 2z + \tfrac23 z^3 + \dfrac{2z^5}{5(1-z^2)}$, because the difference of derivatives is $\dfrac{4z^6}{5(1-z^2)^2} \ge 0.$

Now the magic substitution. For a positive integer $m$, set $z = \frac{1}{2m+1}$. Then $\frac{1+z}{1-z} = \frac{m+1}{m}$ exactly, so every certificate above becomes a *rational* two-sided bound on $\log\frac{m+1}{m}$:

$$\frac{2}{2m+1} + \frac{2}{3(2m+1)^3} \;\le\; \log\frac{m+1}{m} \;\le\; \frac{2m+1}{2m(m+1)} .$$

Substituting these into $t_k = \frac1m - \log\frac{m+1}{m}$ with $m = k+1$ gives the squeeze. Everything that follows is bookkeeping with these bounds — but bookkeeping done carefully enough to produce genuinely new arithmetic.

---

## The tail, and how to shortcut it

Knowing the individual terms is one thing; knowing the *remaining* sum is what turns approximation into certainty. Summing the squeeze cleverly — against telescoping comparison series of the shape $F_c(m) = \frac{1}{2m} + \frac{1}{cm^2}$ — yields a two-sided estimate for the error of the $n$-th approximant:

> **Theorem (sharp tail bound).** For every $n \ge 0$,
> $$\frac{1}{2(n+1)} + \frac{1}{14(n+1)^2} \;\le\; \gamma - g_n \;\le\; \frac{1}{2(n+1)} + \frac{1}{12(n+1)^2}.$$
> In particular $g_n < \gamma$ always, and $\gamma - g_n \le \frac{1}{2n}$ for $n \ge 1$.

Look at what this says. The convergence of $H_n - \log(n+1)$ to $\gamma$ is *maddeningly slow* — to get three decimals you need about a thousand terms, because the error is roughly $\frac{1}{2n}$. But we now know the leading error term *exactly*. So subtract it! Define the **midpoint-accelerated approximants**

$$a_n \;=\; g_n + \frac{1}{2(n+1)} \;=\; H_n - \log(n+1) + \frac{1}{2(n+1)}.$$

Then the tail bound instantly upgrades to a two-sided inverse-square statement:

> **Theorem (the acceleration is exactly quadratic).** For every $n \ge 0$,
> $$\frac{1}{14(n+1)^2} \;\le\; \gamma - a_n \;\le\; \frac{1}{12(n+1)^2}.$$

One free division has turned an $n^{-1}$ method into an $n^{-2}$ method — at $n = 1000$ the raw error is $5\cdot 10^{-4}$ while the accelerated error is $8\cdot 10^{-8}$. Note the constant: the upper coefficient $\frac{1}{12}$ is the *exact* asymptotic constant (it is the first Euler–Maclaurin correction coefficient), which is why numerically $(n+1)^2(\gamma - a_n)$ converges to $0.08333\ldots = \frac{1}{12}$.

The lower bound is not decoration. It is the part that says *you cannot do better with this correction*. The scaled error $(n+1)^2(\gamma - a_n)$ is trapped in $[\frac1{14}, \frac1{12}]$ forever; it never approaches zero. We will cash that in shortly.

---

## Sixteen is a lucky number

Effective bounds are worth having because they can be *evaluated*. But there is a catch: $g_n = H_n - \log(n+1)$ contains a logarithm, and to turn the bound into an explicit interval of rationals you must know $\log(n+1)$ to high precision from an independent source.

There is a shortcut. If $n+1$ happens to be a power of two, then $\log(n+1)$ is an exact integer multiple of $\log 2$ — and $\log 2$ is one of the most thoroughly tabulated numbers in existence. Take $n = 15$. Then $n + 1 = 16 = 2^4$, and the harmonic number is an exact fraction:

$$g_{15} \;=\; H_{15} - \log 16 \;=\; \frac{1195757}{360360} \;-\; 4\log 2 .$$

Feed this into the tail bound at $n = 15$, together with the classical decimal enclosure $0.6931471803 < \log 2 < 0.6931471808$, and you get an unconditional interval:

> **Theorem (certified enclosure).** $\;0.5771692 \;<\; \gamma \;<\; 0.5772158.$

The interval has width $4.66 \times 10^{-5}$, and it is honest to seven decimals on the upper side — the true value $0.5772156649\ldots$ sits just $1.4\times 10^{-7}$ below the upper endpoint. That lopsidedness is a fingerprint of the method: the coefficient $\frac{1}{12}$ in the upper tail bound is the true asymptotic constant, whereas $\frac{1}{14}$ in the lower bound is merely the largest denominator for which the certificate's polynomial nonnegativity check goes through. The upper wall is the real wall; the lower wall is a safe overestimate.

---

## Which fractions is $\gamma$ not?

Now for the payoff, and the reason to care about *explicit* enclosures rather than asymptotic ones.

We cannot prove $\gamma$ is irrational. But irrationality is, in a precise sense, an infinite conjunction of finite statements: *$\gamma \ne p/q$ for every denominator $q$*. Each individual denominator can be checked, if your enclosure is tight enough — because a fraction with small denominator cannot hide in a small interval.

The reasoning takes one line. If $\gamma = p/q$ with $\frac{L}{10^7} < \frac{p}{q} < \frac{U}{10^7}$ where $L = 5771692$ and $U = 5772158$, then multiplying through by $10^7 q$ shows that the integer $10^7 p$ lies strictly between $Lq$ and $Uq$. So the open interval $(Lq,\, Uq)$ — of length $466q$, sitting inside a range of size $10^7 q$ — must contain a multiple of $10^7$. For each fixed $q$ that is a finite integer question, and it can simply be checked.

Running the check for every $q$ from $1$ to $148$: no multiple of $10^7$ ever lands in the window. Hence:

> **Theorem (small-denominator obstruction).** $\gamma$ is not equal to $p/q$ for any integer $p$ and any integer $q$ with $1 \le q \le 148$. Equivalently, no rational number whose reduced denominator is at most $148$ equals $\gamma$.

And the threshold is not arbitrary — it is *exactly* where this enclosure runs out of power. At $q = 149$ the window opens up just enough: the fraction

$$\frac{86}{149} = 0.5771812\ldots$$

lies inside $(0.5771692,\, 0.5772158)$. So $148$ is optimal for this interval; excluding $149$ requires a genuinely narrower enclosure, not a cleverer argument.

This is a modest theorem with an appealing shape. It is a *finite, falsifiable* step towards an open problem: sharpen the enclosure and the threshold rises. Push the enclosure width below $\varepsilon$ and every denominator up to roughly $1/\sqrt{\varepsilon}$ falls. Irrationality of $\gamma$ is the assertion that this process never terminates — but no finite amount of it will ever prove that. Something structurally different is needed.

---

## Why the shortcut cannot become a proof

What would that "something different" be? The classical template is **Apéry's theorem** — the 1978 proof that $\zeta(3) = \sum n^{-3}$ is irrational. Apéry's method is a general principle:

> **Criterion (linear forms).** Let $x$ be a real number. Suppose there are integer sequences $A_n, B_n$ such that $A_n + B_n x \ne 0$ for every $n$, and $|A_n + B_n x| \to 0$. Then $x$ is irrational.

The proof is a two-line pigeonhole. If $x = p/q$, then $A_n + B_n x = \frac{A_n q + B_n p}{q}$ is a nonzero integer over $q$, hence at least $\frac1q$ in absolute value — so the forms cannot shrink below $\frac{1}{q}$, let alone tend to zero. Contrapositive: shrinking forms force irrationality. Any concrete construction just needs approximants good enough to build such forms, typically with geometric decay $|A_n + B_n x| \le Cr^n$, $r < 1$.

So: can the midpoint-accelerated approximants $a_n$ supply them? They converge much faster than the raw $g_n$. Might they be fast enough?

No — and the *lower* half of the tail bound is exactly the obstruction. Since $\gamma - a_n \ge \frac{1}{14(n+1)^2}$, the rescaled error $(n+1)^2(\gamma - a_n)$ is bounded below by $\frac1{14}$ and never tends to $0$. The accelerated family converges at rate exactly $n^{-2}$ — polynomially — while a linear-forms attack needs something in the neighbourhood of exponential accuracy. The family is disqualified, provably, once and for all.

That is a small but genuinely useful piece of information. Negative results of this kind mark off the terrain: any successful attack on the irrationality of $\gamma$ must involve approximants of a fundamentally different nature, not a smarter correction term appended to $H_n - \log n$.

---

## A coda on symmetry

Return to the information-theoretic picture for one last observation. Kullback–Leibler divergence is famously *asymmetric*: $D(a\|b) \ne D(b\|a)$. Its symmetrization, the Jeffreys divergence $D(a\|b) + D(b\|a)$, is much better behaved. For exponential laws the logarithms cancel outright, leaving a perfect square:

> **Theorem (symmetrization identity).** For positive rates $a, b$,
> $$D(a\|b) + D(b\|a) = \frac{a}{b} + \frac{b}{a} - 2 = \frac{(a-b)^2}{ab} = \frac{(\rho-1)^2}{\rho}, \quad \rho = \frac{b}{a}.$$

All transcendence has vanished; the symmetrized information depends only on the *ratio* of the rates. This gives a clean and complete criterion for infinite chains of rates $r_0, r_1, r_2, \dots$: if the successive ratios $\rho_n = r_{n+1}/r_n$ stay in a fixed band $[c, C]$ with $c > 0$, then the total symmetrized information $\sum_n \big(D(r_n\|r_{n+1}) + D(r_{n+1}\|r_n)\big)$ is finite **if and only if** $\sum_n (\rho_n - 1)^2 < \infty$. Convergence is entirely a question of how fast consecutive rates come to agree.

Two chains illustrate the dichotomy sharply. For the arithmetic chain $1, 2, 3, 4, \dots$ the symmetrized terms telescope and the total is *exactly* $1$:

$$\sum_{n=0}^\infty \frac{\big((n+1)-(n+2)\big)^2}{(n+1)(n+2)} = \sum_{n=0}^\infty\left(\frac{1}{n+1}-\frac{1}{n+2}\right) = 1.$$

For a geometric chain $1, r, r^2, \dots$ with $r \ne 1$, the ratio is *always* $r$, so every term equals the same positive constant $\frac{(1-r)^2}{r}$ — the sum diverges no matter how close $r$ is to $1$. Multiplicative growth carries an infinite information tail; additive growth carries exactly one unit.

The contrast is the moral of the whole story. Euler's constant lives on the additive side, at the delicate boundary where a divergent staircase and a divergent curve part company by a finite amount. Every quantitative fact we now know about it — the rational squeeze, the exact quadratic acceleration, the certified interval, the excluded fractions — flows from taking that finite amount seriously and refusing to lose a single decimal along the way.

Whether $\gamma$ is a fraction remains open. But we now know, unconditionally, that it is not any fraction whose denominator is smaller than $149$ — several thousand candidates eliminated in a single finite sweep. Only infinitely many to go.
