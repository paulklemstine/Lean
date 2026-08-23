# The Threshold That Lies

### Why quantum cryptography's most famous number is the wrong thing to measure

---

There is a number that every student of quantum key distribution learns by heart: **eleven percent**. It is the noise level at which the BB84 protocol — the first, and still the most widely deployed, scheme for generating a shared secret key from single photons — is said to break down. Below eleven percent, secure keys. Above eleven percent, nothing. The number appears on conference slides, in funding proposals, in the specification sheets of commercial hardware.

It is a real number, and the mathematics behind it is correct. The trouble is what people do with it. Engineers use it as a pass/fail criterion: *our link runs at nine percent error, comfortably below threshold, so we are fine.* This article is about a family of results showing, with certified constants, that this reasoning is quantitatively wrong — and about *how wrong*, as an exact law.

The punchline, stated once and then unpacked: if your error rate sits a distance $\delta$ below the threshold, the number of raw bits you must exchange before you extract even one secret bit grows like $\delta^{-2}$, and this is tight from both sides. Being "just below threshold" is not a safety margin. It is a cliff.

---

## Where eleven percent comes from

Alice sends photons; Bob measures them; they publicly compare a sample of their outcomes and find that a fraction $Q$ of the bits disagree. This $Q$ is the **quantum bit error rate**, or QBER. Some of that disagreement is honest noise in the fibre. Cryptographic paranoia demands they assume all of it is Eve.

The classic Shor–Preskill analysis says that in the limit of infinitely long transmissions, the fraction of the sifted bits that can be turned into secret key is

$$r(Q) \;=\; 1 - 2h(Q), \qquad h(Q) = -Q\log_2 Q - (1-Q)\log_2(1-Q).$$

Two copies of the binary entropy $h$: one is the price of reconciling Alice's and Bob's strings over a public channel, the other is the price of scrubbing out whatever Eve learned. The rate is positive exactly when $h(Q) < 1/2$, which happens below

$$Q^\ast = 0.1100278644\ldots$$

That is the eleven percent. It is a transcendental-looking constant with no closed form, defined implicitly as the solution of $h(Q^\ast) = 1/2$.

Two things about it deserve suspicion. First, $r(Q)$ approaches zero *continuously* as $Q \to Q^\ast$: at $Q = 11\%$ exactly, the asymptotic rate is a positive but minuscule $0.000168$ bits per sifted bit. You would need six thousand transmitted bits to earn one secret bit — before paying any other costs. Second, and much more seriously: the word *asymptotic*.

---

## The tax on being finite

Real protocols do not run forever. They run on a block of $n$ sifted bits, and every statistical estimate made from a finite sample carries an error bar. The standard finite-key accounting subtracts a fluctuation term of order $\sqrt{n}$ from the asymptotic budget. Writing $\rho$ for the guaranteed rate in bits per sifted bit, $\varepsilon$ for the security parameter (the maximum tolerable deviation from a perfect key), and $C$ for a constant absorbing the details of the entropy estimation, the usable length is

$$L(n) \;=\; n\rho \;-\; C\sqrt{n \ln(1/\varepsilon)}.$$

The first term is linear in $n$; the second is only a square root. So for large $n$ the linear term wins and everything is fine. The question is *how large*.

Setting $L(n) = 0$ and solving gives the **break-even block size**

$$n^\ast \;=\; \frac{C^2 \ln(1/\varepsilon)}{\rho^2}.$$

Look at that denominator. The break-even size scales as the *inverse square* of the rate. Halving your key rate quadruples the block size you need before you get anything at all. And near the threshold, $\rho$ is tiny.

Put in the numbers for $Q = 11\%$, with the standard choices $C = 10$ and $\varepsilon = 2^{-50}$ (so $\ln(1/\varepsilon) = 50\ln 2 \approx 34.66$). One obtains

$$n^\ast \;\approx\; 1.25 \times 10^{11}.$$

A hundred and twenty-five billion sifted bits. At a megahertz sifted rate — generous for real hardware — that is about four years of continuous operation to produce the *first* secret bit. The asymptotic theory says the link is secure and productive. The finite-key arithmetic says nothing comes out.

This can be stated as a theorem with certified constants rather than a numerical observation:

> **Theorem (the guarantee is empty at realistic block sizes).** At a measured QBER of exactly $11\%$, with $C = 10$ and $\varepsilon = 2^{-50}$, the finite-key length is non-positive for **every** block size $n \le 10^{11}$. For $n \ge 10^{12}$, by contrast, at least half the asymptotic budget survives: the finite-key length is at least $n/12000$ bits.

---

## Arithmetic you can trust

There is a subtlety in even *stating* such a theorem rigorously, and it is worth dwelling on, because it drove the technique.

The rate $r(0.11)$ is a difference of logarithms. Its numerical value, $0.000168$ bits, is the difference of two numbers each near $0.5$ — a catastrophic cancellation. Any claim of the form "$r(0.11) > 0$" evaluated in floating-point arithmetic is a claim about the last few bits of a double-precision computation. That is not a proof. It is a hope.

The remedy is to eliminate real numbers from the certificate entirely. At a *rational* error rate $Q = a/(a+c)$ with $a$ and $c$ positive integers, there is an exact identity:

$$(a+c)\, r_{\mathrm{nats}}\!\left(\frac{a}{a+c}\right) \;=\; \log\frac{N}{D}, \qquad N = 2^{a+c}\, a^{2a}\, c^{2c}, \quad D = (a+c)^{2(a+c)}.$$

Both $N$ and $D$ are honest integers. At $Q = 11/100$ they have four hundred digits apiece. The sign of the key rate is now the sign of $\log(N/D)$, which is just the question of whether $N > D$ — a single integer comparison, decidable exactly.

But a *sign* is not a *rate*. To go from "positive" to "at least this much", one needs a lower bound on $\log x$ that is valid for all $x \ge 1$ and *rational* when $x$ is. The naive choice, $\log x \ge 1 - 1/x$, is the tangent-line bound; it is correct but wasteful. The better choice is the **Padé $[1/1]$ approximant**,

$$\log x \;\ge\; \frac{2(x-1)}{x+1}, \qquad x \ge 1,$$

whose proof is a two-line exercise: the difference $f(x) = \log x - 2(x-1)/(x+1)$ vanishes at $x=1$ and has derivative $f'(x) = (x-1)^2 / \big(x(x+1)^2\big) \ge 0$. A perfect square in the numerator, so the sign is never in doubt.

Why does this matter? Because at $Q = 11\%$ we have $N/D = 1.0117188\ldots$, and the two bounds give
- naive: $r \ge 1.15831 \times 10^{-4}$ nats,
- Padé: $r \ge 1.16505 \times 10^{-4}$ nats,
- truth: $r = 1.16507 \times 10^{-4}$ nats.

The Padé bound recovers almost all of the deficit. Converted to bits, it clears the clean rational value $1/6000$ with room to spare; the naive bound clears it by only a quarter of a percent — too thin to be worth certifying. The sharper approximant is what makes the whole chain go through with a memorable constant.

The resulting scheme is completely mechanical. Choose integers $\mathrm{num}$ and $\mathrm{den}$; check the single integer inequality

$$(\mathrm{den} + \mathrm{num})\, D \;\le\; \mathrm{den}\, N;$$

conclude

$$r\!\left(\frac{a}{a+c}\right) \;\ge\; \frac{2\,\mathrm{num}}{(a+c)(2\,\mathrm{den} + \mathrm{num})} \ \text{ nats per sifted bit}.$$

At $Q = 11\%$, taking $\mathrm{den} = 10^4$ and $\mathrm{num} = 117$ — an 823-digit comparison — certifies $r \ge 1/6000$ bits. No floating-point number appears anywhere in the chain.

Away from the threshold a cruder and even simpler certificate suffices. If $2^m D \le N$ then $r \ge m/(a+c)$ **bits**, with no logarithm constants at all, because $m$ is literally a certified lower bound for $\log_2(N/D)$. And the two schemes turn out to be the two faces of one hybrid: writing $y = N/(2^m D)$ for the residual after $m$ dyadic steps,

$$\log \frac{N}{D} \;=\; m\log 2 + \log y \;\ge\; m \log 2 + \frac{2(y-1)}{y+1}.$$

The dyadic part carries the bulk of the signal away from threshold; the Padé part carries all of it at threshold. At $Q = 10\%$ the optimal dyadic exponent is $m = 6$, leaving $y = 1.14940\ldots$, and the hybrid certifies $0.0620$ bits per sifted bit against the dyadic scheme's $0.0600$ — the true value being $0.0620088$. The raw hybrid bound is $0.0620043$, so the residual error drops from $2.0\times 10^{-3}$ to $4.5\times 10^{-6}$ — and even after rounding down to the clean rational $62/1000$ the error is only $8.8\times 10^{-6}$. The required block size falls by six percent.

---

## A law, not an anecdote

So far this is one embarrassing data point at one error rate. The real content is that it is a structural law, and that it is *tight*.

The argument has two halves, and they are the same argument run in opposite directions.

**Half one: the rate cannot vanish too slowly.** The derivative of the binary entropy is $\log\frac{1-p}{p}$, a decreasing function of $p$. On the interval $[1/10, 1/2]$ its largest value is $\log 9$ (attained at the left endpoint), so the entropy is Lipschitz there with constant $\log 9$. Since $r(Q^\ast) = 0$ by definition of the threshold, we get, for every $Q \in [1/10, Q^\ast]$,

$$r(Q) \;\le\; 2\log 9 \cdot (Q^\ast - Q).$$

The rate vanishes *at most linearly*. Now feed this into the break-even formula $n^\ast = C^2\ln(1/\varepsilon)/\rho^2$: any legitimate rate certificate $\rho$ at $Q$ is bounded by $r(Q)/\log 2 \le 6.6\,(Q^\ast - Q)$ bits, hence

> **Theorem (break-even from below).** Let $Q \in [10\%, Q^\ast)$, and let $\rho$ be *any* valid rational rate certificate at $Q$. Then every block size $n$ at which the finite-key length is positive satisfies
> $$n \;\ge\; \frac{C^2 \ln(1/\varepsilon)}{44\,(Q^\ast - Q)^2}.$$

The quantifier is what matters: *any* certificate. This is not a statement about a particular proof technique being lossy. No cleverness in bounding the rate can rescue you, because the rate itself is small.

**Half two: the rate cannot vanish too fast, either.** On its own, half one leaves open a disturbing possibility. Perhaps the break-even size is not merely at least $\delta^{-2}$ but vastly larger — exponential, say — in which case the inverse-square shape would be an artifact of a lossy estimate rather than a real law. Ruling this out requires a bound in the *other* direction, and the same monotonicity template supplies it. The derivative $\log\frac{1-p}{p}$ attains its *minimum* over $[Q, Q^\ast]$ at the right endpoint $Q^\ast$, and provided $Q^\ast \le 1/5$ — which the certified enclosure $Q^\ast < 0.1101$ comfortably guarantees — that minimum is at least $\log 4 = 2\log 2$. Hence for every $0 < Q \le Q^\ast$,

$$r(Q) \;\ge\; 4\log 2 \cdot (Q^\ast - Q) \ \text{nats} \;=\; 4\,(Q^\ast - Q) \ \text{bits}.$$

The rate is now sandwiched linearly on both sides. To make this into an *upper* bound on the break-even size one needs a rational certificate capturing a fixed fraction of the true rate, and any rational number in the interval $\big(3\delta,\, 4\delta\big]$ — where $\delta = Q^\ast - Q$ — will do; such a rational always exists.

> **Theorem (break-even from above).** For every $Q \in (0, Q^\ast)$ with $Q^\ast \le 1/5$ there exists an explicit positive **rational** rate certificate $\rho$, valid at $Q$, whose break-even block size is at most
> $$\frac{C^2\ln(1/\varepsilon)}{9\,(Q^\ast - Q)^2}.$$

Putting the halves together:

> **The two-sided inverse-square law.** For every $Q \in [10\%, Q^\ast)$,
> $$\frac{C^2 \ln(1/\varepsilon)}{44\,(Q^\ast - Q)^2} \;\le\; n^\ast(Q) \;\le\; \frac{C^2 \ln(1/\varepsilon)}{9\,(Q^\ast - Q)^2}.$$
> That is, $n^\ast(Q) = \Theta\big((Q^\ast - Q)^{-2}\big)$, with a certified constant ratio of $44/9 < 5$.

The exponent $2$ is exact. It is forced by the $\sqrt{n}$ shape of the statistical correction alone; the entropy function only fixes the constant. That separation is why the law is protocol-independent: change the details of the entropy estimation and you change $C$, but the shape of the divergence survives.

Concretely, at $Q = 11\%$ the certified enclosure of the threshold gives a gap below $10^{-4}$, and the lower half of the law forces $n \ge 7\times 10^9$ sifted bits *for any rate certificate whatsoever*. At $Q = 10\%$ the gap exceeds $1/100$, and the upper half produces an explicit rational certificate that breaks even below $4 \times 10^6$ bits.

---

## The full table

Assembling everything gives a parameter table in which every number is backed by an exact integer comparison. With $C = 10$ and $\varepsilon = 2^{-50}$:

| QBER $Q$ | certified rate (bits/sifted bit) | true rate | required block size $n$ | extractable secret bits |
|---|---|---|---|---|
| $1\%$ | $0.83$ | $0.8384$ | $2.5 \times 10^{4}$ | $\ge 0.415\,n - 101$ |
| $2\%$ | $0.71$ | $0.7171$ | $2.8 \times 10^{4}$ | $\ge 0.355\,n - 101$ |
| $5\%$ | $0.42$ | $0.4272$ | $7.9 \times 10^{4}$ | $\ge 0.21\,n - 101$ |
| $8\%$ | $0.19$ | $0.1956$ | $3.9 \times 10^{5}$ | $\ge 0.095\,n - 101$ |
| $10\%$ | $0.0620$ | $0.0620088$ | $3.7 \times 10^{6}$ | $\ge 0.031\,n - 101$ |
| $11\%$ | $1/6000$ | $0.000168$ | $10^{12}$ | $\ge n/12000 - 101$ |

Read the last two columns together. From $1\%$ to $11\%$ the asymptotic rate falls by a factor of five thousand. The required block size rises by a factor of forty *million*. That eight-orders-of-magnitude spread, against a five-thousand-fold change in the headline figure, is the quantitative content of the inverse-square law — and the reason the threshold is a poor guide to engineering.

The trailing $-101$ deserves a word. It is the constant price of the final step, **privacy amplification**: Alice and Bob hash their reconciled string down to a shorter one about which Eve knows essentially nothing. The classical guarantee is that if the string has $k$ bits of min-entropy from Eve's perspective and one hashes down to $\ell$ bits with $\ell + 2\log_2(1/\varepsilon) \le k$, then the output is within statistical distance $\varepsilon$ of a perfectly uniform key. At $\varepsilon = 2^{-50}$ this costs exactly $100$ bits, plus one more lost to rounding the length down to an integer.

---

## An honest hypothesis

One more episode is worth telling, because it illustrates a hazard that formal scrutiny is unusually good at catching.

The privacy amplification step is often stated in the following shape: *if the hashed key's collision probability satisfies $\sum_i p_i^2 \le 2^{-k}$, then it is close to uniform.* Here $p$ ranges over a distribution on the $2^\ell$ possible output strings, and $k$ is the min-entropy of the source. The statement is true. In the regime where it is advertised as strong — output shorter than the entropy, $\ell < k$ — it is also **vacuous**.

The reason is a one-line application of the Cauchy–Schwarz inequality: for any probability vector on $2^\ell$ points,

$$\sum_i p_i^2 \;\ge\; \frac{\big(\sum_i p_i\big)^2}{2^\ell} \;=\; 2^{-\ell},$$

with equality exactly for the uniform distribution. So when $\ell < k$, the hypothesis $\sum p_i^2 \le 2^{-k} < 2^{-\ell}$ is satisfied by *no distribution at all*. A theorem with no instances proves nothing, however true it is.

The repair is to use the quantity that two-universal hashing actually delivers, which is not $2^{-k}$ but

$$\sum_i p_i^2 \;\le\; 2^{-\ell} + 2^{-k}.$$

That hypothesis is satisfiable — the uniform distribution meets it — and it yields the *same* conclusion, because of a pleasing exact collapse:

$$2^\ell\big(2^{-\ell} + 2^{-k}\big) - 1 \;=\; 2^{\ell - k},$$

whose square root is $2^{(\ell-k)/2} \le \varepsilon$ precisely when $\ell + 2\log_2(1/\varepsilon) \le k$. The leftover-hash budget emerges from the algebra rather than being imposed on it. Nothing is lost and the statement acquires content.

---

## What to measure instead

The moral is not that BB84 is broken, nor that the eleven-percent threshold is wrong. It is that a threshold is an asymptotic object and deployment is a finite affair, and the two are related by a law with a punishing exponent.

If you are specifying a quantum link, the number to put in the requirements document is not "$Q < Q^\ast$". It is the break-even block size

$$n^\ast = \frac{C^2\ln(1/\varepsilon)}{\rho^2},$$

computed from a rate certificate $\rho$ you can actually defend, at the security parameter you actually need. And the two-sided law tells you what to expect before you compute anything: within a factor of five, $n^\ast$ is $C^2 \ln(1/\varepsilon)$ divided by roughly twenty times the square of your distance to threshold.

There is a broader methodological point too. The entire chain above — from a four-hundred-digit integer comparison, through a rational logarithm bound, through the finite-key accounting, to a numerical table — contains no floating-point arithmetic. That is not fastidiousness for its own sake. Near a threshold, a quantity of interest is a difference of large nearly-equal numbers, and floating-point evaluation of such a difference is exactly where confidence should be lowest. Replacing it with integer comparisons and rational bounds costs a little sharpness (our $1/6000$ against the true $1/5950$) and buys certainty.

Eleven percent is a fine number. It just is not the one to design around.
