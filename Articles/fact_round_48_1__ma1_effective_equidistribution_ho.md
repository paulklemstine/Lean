# The Price of Assuming the Primes Are Fair

## A measurement, a theorem, and the gap between them

Suppose you write down every prime below a billion and sort them by the remainder they leave when divided by $7$. There are six possible remainders for a prime that large — $1, 2, 3, 4, 5, 6$ — and the primes distribute themselves among these six boxes with uncanny even-handedness. This is one of the oldest empirical facts in number theory, and it has a name: *equidistribution in arithmetic progressions*. The number of primes up to $x$ leaving remainder $a$ modulo $m$, written $\pi(x; m, a)$, should be about $\mathrm{Li}(x)/\varphi(m)$, where $\mathrm{Li}(x) = \int_2^x dt/\log t$ counts primes overall and $\varphi(m)$ counts the admissible remainders.

"Should be about" is doing a lot of work in that sentence. And a great deal of modern number theory — and of the applied mathematics that borrows from it — is built on top of the assumption that "about" means "close enough not to matter."

This article is about what happens when you refuse to let "close enough" stay vague. We take a single measured number — the largest relative deviation from perfect equidistribution, observed across the moduli $m \in \{3,4,5,7,8,11,31\}$ at $x = 2^{30}$, which came out at
$$\varepsilon = 0.000446,$$
that is, $0.0446\%$ — and we ask: *exactly what does that number buy?* Not heuristically. Exactly.

The answer turns out to be surprisingly rich, and one of its punchlines is a small, precise disappointment: the honest cost of the equidistribution assumption is not $0.0446\%$ but $0.0892\%$, twice as large, because errors of this kind are two-sided and you pay on the way up *and* on the way down. Three significant figures of the downstream constant survive. Four provably do not.

## Certificates, not assumptions

The first move is to stop treating equidistribution as a belief and start treating it as a *document*. Fix a modulus $m$, let the classes be indexed by $a$, and let $N_a$ be the count in class $a$, with common target $\mu = \mathrm{Li}(x)/\varphi(m)$. An **$\varepsilon$-equidistribution certificate** is simply the assertion
$$|N_a - \mu| \le \varepsilon \mu \qquad \text{for every class } a.$$

That is all. It is a finite, checkable, falsifiable statement about a finite table of numbers. Everything that follows is deduced from it and nothing else — no Riemann Hypothesis, no Siegel zeros, no asymptotics hiding in an $O(\cdot)$.

The first consequence is a two-sided **ratio bound**. Since every count sits between $(1-\varepsilon)\mu$ and $(1+\varepsilon)\mu$, any two classes satisfy
$$N_a \le \frac{1+\varepsilon}{1-\varepsilon} \, N_b .$$
At $\varepsilon = 0.000446$ this says every class count is within a factor $1.001$ of every other. That factor $\frac{1+\varepsilon}{1-\varepsilon}$ is where the doubling comes from: to first order it equals $1 + 2\varepsilon$, not $1 + \varepsilon$. The certificate is a statement about *one* class at a time; comparing *two* classes costs twice as much.

And this is not slack in the argument. There is a genuine two-class configuration — one class at $(1+\varepsilon)\mu$, the other at $(1-\varepsilon)\mu$ — that satisfies the certificate exactly, conserves the total count exactly, and realizes the ratio $\frac{1+\varepsilon}{1-\varepsilon}$ on the nose. No cleverer argument can do better.

## The transfer principle

Here is the shape of the problem the certificate was built to solve. Somebody proves a clean inequality *under the assumption of exact equidistribution*: a bound of the form
$$\Phi \le \tfrac43 \, \Psi,$$
where $\Phi$ and $\Psi$ are two quantities read off the class counts. (The constant $\tfrac43$ is the one that matters for the application that motivated this work; nothing below depends on its particular value.) The proof is correct, but its hypothesis is false — the primes are only *nearly* equidistributed. What survives?

Everything survives, with a computable degradation, provided $\Phi$ and $\Psi$ are what we will call **monotone homogeneous readouts**: $\Phi$ increases when every count increases, and $\Phi(\lambda f) = \lambda\, \Phi(f)$ for $\lambda \ge 0$. Almost every natural summary statistic of a count vector is of this type: the maximum, the minimum, the total, any weighted sum with nonnegative weights, any quantile.

**Transfer Theorem.** *If $\Phi(\text{uniform}) \le \tfrac43\,\Psi(\text{uniform})$ for monotone homogeneous readouts $\Phi, \Psi$, then on any count vector carrying an $\varepsilon$-certificate,*
$$\Phi(N) \le \frac43 \cdot \frac{1+\varepsilon}{1-\varepsilon} \cdot \Psi(N).$$

The proof is three lines of bookkeeping: monotonicity plus homogeneity push $\Phi(N)$ up by at most $(1+\varepsilon)$ relative to its uniform value, and push $\Psi(N)$ down by at most $(1-\varepsilon)$; the ideal inequality is applied in between. The content is not the difficulty of the argument — it is that the *same* constant $\frac{1+\varepsilon}{1-\varepsilon}$ appears here as in the ratio bound, and the two-class configuration above shows it is attained by the maximum-over-minimum readout. Within this class of readouts, the degradation is exact, not merely an upper estimate.

## Three figures, not four

Now plug in the measurement. Write
$$C(\varepsilon) = \frac43 \cdot \frac{1+\varepsilon}{1-\varepsilon}.$$
At $\varepsilon = 0.000446$,
$$1.3345 < C(\varepsilon) < 1.3346 .$$
The ideal constant is $4/3 = 1.3333\ldots$; the effective one is $1.33452\ldots$. The relative perturbation is
$$\frac{C(\varepsilon) - 4/3}{4/3} = \frac{2\varepsilon}{1-\varepsilon} = 0.000892 = 0.0892\%,$$
comfortably under $0.1\%$. So the leading three significant figures, $1.33$, are certified: any conclusion drawn to that precision from the idealized cap is safe.

Four figures are not. The perturbation exceeds $\tfrac43 \cdot 10^{-4}$, so the fourth digit of the effective constant genuinely differs from the fourth digit of $4/3$. The recorded claim — "the constants hold to three significant figures" — is therefore not merely true but *sharp*: it is the best claim of its kind the data supports.

There is also a converse, which makes the dictionary two-way. If you ever *observe* two class counts in ratio $R \ge 1$, then no certificate better than
$$\varepsilon \ge \frac{R-1}{R+1}$$
can hold. Measured ratio and certified deviation determine each other exactly; an observed gap exceeding $2\varepsilon\mu$ between two classes refutes the $\varepsilon$-certificate outright.

## Failures never come alone

A pleasant structural fact falls out for free. Suppose the total count is exactly conserved, $\sum_a N_a = n\mu$ where $n$ is the number of classes — the situation when $\mu$ is defined as the empirical average. Then the deviations sum to zero, and two things follow immediately. First, no single class can deviate by more than half the total absolute deviation of the whole field. Second, and more vividly: if class $a$ runs an excess $N_a - \mu > 0$, then *some other class* runs a deficit of at least $(N_a - \mu)/(n-1)$. Equidistribution failures are never solitary. A surplus of primes in one residue class is a debt owed by the others.

## The harmonic-analysis side

Certificates have a dual life. Take any *test function* $f$ on the classes with mean zero, $\sum_a f_a = 0$, and values bounded by $1$. Then the correlation of $f$ with the count vector satisfies
$$\Big| \sum_a f_a N_a \Big| \le n \, \varepsilon \mu .$$
The proof is a one-liner: mean-zero test functions cannot see the common target $\mu$, so the correlation only ever touches the deviations, each of which is at most $\varepsilon\mu$. Remarkably, the converse also holds — a uniform bound $\delta$ on all such correlations forces every class to sit within $\delta$ of the empirical mean. Certificates and test-correlation bounds are the same information, up to the number of classes.

Specializing the test functions to Dirichlet characters gives the classical statement. For every nontrivial character $\chi$ modulo $m$,
$$\Big| \sum_a \chi(a) N_a \Big| \le \varphi(m)\, \varepsilon \mu = \varepsilon \, \mathrm{Li}(x),$$
because nontrivial characters have modulus one and sum to zero over the classes. In the other direction, the counts are fully reconstructible from their character sums:
$$\sum_{\chi} \overline{\chi(a)} \sum_b \chi(b) N_b = \varphi(m)\, N_a,$$
the finite Fourier inversion formula for the group of reduced residues. Passing to the dual side and back is lossy by exactly a factor $\varphi(m)-1$ — a precise accounting of what the character formulation costs relative to the raw certificate at a fixed modulus.

## What no statistical test can find

Here is a consequence with a slightly philosophical flavour. Suppose you dream up any feature $P$ of residue classes — quadratic residuosity, size, a hash, anything — and any threshold $t$, and you hope to split the classes into a "high" group with counts at least $\mu_0 + \delta$ and a "low" group with counts at most $\mu_0 - \delta$. The certificate caps the total sum of squares of the count field by $n(\varepsilon\mu)^2$, and a standard variance decomposition then forces the achievable margin to obey
$$\frac{4\delta^2 n_1 n_2}{n} \le n (\varepsilon\mu)^2 .$$
For a balanced split this reads $\delta \le \varepsilon\mu$. Uniformly over *all* criteria, no separation better than the certificate itself is available. An $\varepsilon$-equidistributed field is structureless in a quantifiable sense: there is nothing in it for a classifier to find.

## Two hypotheses, resolved

The experiment came with two informal observations. The first: *the worst-behaved residue class is stable as $x$ grows for some moduli ($3, 4, 7, 8, 11$) and unstable for others ($5, 31$).* It is tempting to read arithmetic significance into that split. The right reading is more prosaic. If the deviation field drifts by at most $\eta$ between two scales, and the worst class is $a$ at the first scale and $b$ at the second, then the two "top-two gaps" satisfy
$$(d_1(a) - d_1(b)) + (d_2(b) - d_2(a)) \le 2\eta .$$
Contrapositively: if the leader leads by a margin strictly greater than $2\eta$, the leader cannot change. **Instability certifies a near-tie**, nothing more. The observed split between stable and unstable moduli is a statement about how close the top two classes were, not about arithmetic.

The second observation: *deviations shrink at $6$ of the $7$ moduli as $x$ grows.* This upgrades to a genuine dynamical theorem. Aggregate over a family of moduli: if a subfamily shrinks by a factor $\rho$ and the rest merely do not grow, the aggregate deviation drops by at least $(1-\rho)$ times the shrinking subfamily's share — strictly, if $\rho < 1$ and that share is positive. And if the certificates decay geometrically across dyadic scales, $\varepsilon_{k+1} \le \rho\,\varepsilon_k$ with $\rho < 1$, then for every target accuracy $\delta$ there is an explicit scale index beyond which
$$C(\varepsilon_k) - \tfrac43 \le \delta .$$
**The effectivization is asymptotically free.** The three-figure agreement recorded at $2^{30}$ is not a coincidence of that scale; it is the beginning of a convergence.

## The information price

Finally, a change of currency. Instead of measuring the cost of the equidistribution assumption in multiplicative constants, measure it in *information*. Turn the counts into a probability distribution $p_a = N_a / \sum_b N_b$ over classes, and ask how far $p$ is from uniform in Kullback–Leibler divergence, $D(p \| u) = \sum_a p_a \log(n\, p_a)$ — the number of nats you lose by pretending the primes are perfectly fair.

A first pass gives the linear bound $D(p\|u) \le 2\varepsilon/(1-\varepsilon)$, which is *exactly* three quarters of the excess $C(\varepsilon) - \tfrac43$ of the cap constant. The order-theoretic price and the entropic price are literally the same number in different clothes. Equivalently, the Shannon entropy of the class distribution is within $2\varepsilon/(1-\varepsilon)$ of its maximum $\log \varphi(m)$.

But the linear bound is far from the truth. Kullback–Leibler divergence is dominated by chi-square divergence, and the certificate pins each class probability to within $2\varepsilon/(n(1-\varepsilon))$ of $1/n$. Squaring, the real price is **quadratic**:
$$D(p\|u) \le \left(\frac{2\varepsilon}{1-\varepsilon}\right)^2 \le 16\varepsilon^2 .$$
At the recorded $\varepsilon$ this is below $8 \times 10^{-7}$ nats — three orders of magnitude below the linear estimate of $9 \times 10^{-4}$. And the exponent $2$ is exact: the saturated two-class configuration costs at least $\varepsilon^2/4$ nats, so no bound of the form $C\varepsilon^3$ can hold for every certificate, whatever $C$ you choose.

Summed over *all* dyadic scales with geometrically halving certificates, the total information ever lost to the equidistribution assumption — the entire future cost of the idealization, for all $x$ — is at most $16\varepsilon_0^2/(1-\rho^2)$, which comes to under $4.3 \times 10^{-6}$ nats. The linear envelope gave $0.00357$; the quadratic one improves it by a factor of more than $800$.

## Linear or quadratic: what decides?

Why do some readouts pay $O(\varepsilon)$ and others only $O(\varepsilon^2)$? The natural guess is that the quadratic ones are exactly those that vanish on perfectly uniform fields — the ones that "only see deviations." Half of that guess is right. If $|\Phi(f)| \le L \sum_a (f_a - c)^2$ for every constant $c$ — call these *deviation-energy readouts* — then $\Phi$ certainly annihilates constants, and the certificate gives $|\Phi(N)| \le L\, n (\varepsilon\mu)^2$: quadratic. The empirical variance is such a readout, and at the recorded $\varepsilon$ it is bounded by $2\times 10^{-7}$ relative — five significant figures of accuracy on the quadratic side, against three on the linear side.

The other half of the guess is false, and instructively so. The coordinate difference $f \mapsto f_a - f_b$ annihilates every constant field, yet on the extremal certificate it equals $2\varepsilon\mu$ — dead linear. Vanishing on constants is not enough; you need control by the deviation *energy*, a genuinely quadratic quantity. The dichotomy is real, but the dividing line is drawn by the norm, not by the null space.

## What it all adds up to

One measured number, $\varepsilon = 0.000446$, and no other arithmetic input, simultaneously yields: every two residue classes within a factor $1.001$; a downstream cap constant pinned between $1.3345$ and $1.3346$, three significant figures certified and four refuted; every nontrivial character sum below $\varepsilon\,\mathrm{Li}(x)$; the class distribution within $8\times 10^{-7}$ nats of uniform; and no statistical criterion whatsoever able to separate the classes by a margin exceeding $\varepsilon\mu$.

The moral is not that the primes are fair — we knew that. It is that "fair enough" can be made into a currency, with an exchange rate you can compute, a bill you can pay, and a receipt you can check. An assumption is only a liability while nobody has priced it.
