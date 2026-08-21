# The Eleven Percent Problem

## How a 4102-digit integer and a fraction nobody had heard of pinned down quantum cryptography's most famous number to thirteen decimal places

---

### A number everyone quotes and nobody knows

Open almost any textbook on quantum key distribution and you will meet the same
sentence: *the BB84 protocol tolerates a quantum bit error rate of up to about
11%.* Below 11%, Alice and Bob can distill a provably secret key from their noisy
quantum channel. Above it, the eavesdropper may know too much, and the protocol
returns nothing.

That number, $11\%$, is a boundary between security and silence. It is quoted in
lecture notes, in funding proposals, in the specification documents of commercial
quantum-cryptography hardware. And yet, in a precise sense, it is not a number at
all. It is a rounded shadow of a number — the solution of a transcendental
equation that has no closed form, computed by someone, once, in floating-point
arithmetic, and copied ever since.

This article is about what happens when you refuse to accept the shadow, and
insist on the number. The answer, established here with complete rigour, is

$$p_\star = 0.1100278644383\ldots$$

and every one of those thirteen decimals is *certified*: it follows from a chain
of proved inequalities, not from a floating-point computation that anyone has to
trust. Along the way, the number $11\%$ turns out to be far more interesting than
it looks. It is not merely a rounding of $p_\star$; it is, in a technical sense
we will make precise, the **best possible** rational approximation of $p_\star$
with a denominator below $309$. The textbook was smarter than it knew.

---

### Where the threshold comes from

The BB84 protocol has Alice send single photons in randomly chosen polarization
bases and Bob measure in randomly chosen bases. When their bases agree, they
should get the same bit. Noise — and eavesdropping, which is indistinguishable
from noise — makes some of these agreements disagree. The fraction of
disagreements is the **quantum bit error rate**, $Q$.

The celebrated security analysis of the protocol says that the asymptotic rate at
which secret key bits can be extracted per sifted bit is governed by the quantity

$$r(Q) \;=\; \log 2 \;-\; 2\,H_2(Q),$$

measured in *nats* (natural-logarithm units), where $H_2$ is the **binary entropy
function**

$$H_2(p) \;=\; -p\log p \;-\; (1-p)\log(1-p), \qquad 0 < p < 1 .$$

The interpretation is a tug of war. The term $\log 2$ is one full bit of raw
randomness per sifted position. One factor of $H_2(Q)$ is what Alice and Bob must
sacrifice to *reconcile* their strings — to fix the errors. The other factor of
$H_2(Q)$ is what they must sacrifice to *privacy-amplify* — to squeeze out
whatever the eavesdropper learned. When the two sacrifices together consume the
whole bit, nothing is left.

So the threshold $p_\star$ is the smallest positive solution of

$$H_2(p) \;=\; \tfrac{1}{2}\log 2,$$

or, in the more familiar base-2 language, the error rate at which the binary
entropy equals exactly one half of a bit. Because $H_2$ is continuous, vanishes
at $0$, increases strictly on $[0,\tfrac12]$, and reaches $\log 2 > \tfrac12\log
2$ at $p=\tfrac12$, the intermediate value theorem guarantees exactly one such
$p_\star$ in $(0,\tfrac12)$. Everything else is a question of *where*.

A crude argument — comparing $H_2$ against the elementary bounds available for
the logarithm — localizes $p_\star$ somewhere between $6.25\%$ and $12.5\%$. That
is honest but useless: the whole interesting question lives inside that window.

---

### The trick: turn a transcendental into an integer

Here is the first surprise. The equation $H_2(p) = \tfrac12\log 2$ is
transcendental, but the *question of which side of it a given rational number
lies on* is a question about integers, and only about integers.

Write a rational error rate as $p = \dfrac{a}{a+c}$ with $a$ and $c$ positive
whole numbers. (Think of $a$ errors out of $a+c$ transmissions.) Substituting
into the definition and clearing the denominator gives an exact identity with no
fractions inside a logarithm:

$$2(a+c)\,H_2\!\left(\frac{a}{a+c}\right) \;=\; 2(a+c)\log(a+c) \;-\; 2a\log a \;-\; 2c\log c .$$

Now compare that with $2(a+c)\cdot\tfrac12\log 2 = (a+c)\log 2$ and exponentiate.
Every logarithm disappears, and the comparison becomes:

> **The Rational Sign Criterion.** For positive integers $a, c$,
> $$H_2\!\left(\frac{a}{a+c}\right) < \frac{\log 2}{2}
> \quad\Longleftrightarrow\quad
> (a+c)^{2(a+c)} \;<\; 2^{\,a+c}\, a^{2a}\, c^{2c},$$
> and the reverse inequality holds in the reverse direction. Equivalently, the
> key rate $r$ at error rate $a/(a+c)$ is positive precisely when the left-hand
> integer is the smaller one.

This is an *equivalence*, not an estimate. It is a complete decision procedure:
feed it any rational number, and one comparison of two whole numbers tells you,
with certainty, whether that error rate is safe or unsafe. No approximation of
$\log 2$ is involved. No floating point is involved. The transcendence of the
problem has been quarantined.

Applying it at $a/(a+c) = 11/100$ requires comparing
$$100^{200} \quad\text{against}\quad 2^{100}\cdot 11^{22}\cdot 89^{178},$$
two 823-digit integers. The left one is smaller, so $11\%$ is strictly *below*
threshold — the protocol survives there. Applying it at $1101/10000$ requires
80 000-digit integers; that comparison goes the other way, so $11.01\%$ is above
threshold. Together:

$$0.1100 \;<\; p_\star \;<\; 0.1101 .$$

Four decimals, certified, by pure arithmetic.

---

### The wall

The obvious next move is to push the denominator up: $10^5$, $10^6$, $10^7$, one
new decimal each time. This fails, and the way it fails is instructive.

The integers in the criterion at denominator $b$ have roughly $2b\log_{10} b$
digits. At $b = 10^4$ that is already 80 000 digits — big, but manageable. At
$b = 10^7$ it would be about $10^8$ digits: a single number filling a hundred
megabytes, and the comparison requires several of them. The obstruction is not
mathematical — the criterion is still an exact equivalence — but it is absolute
in practice. Brute force stops at four or five decimals.

To go further, one has to stop asking *what side of the threshold is this point
on?* and start asking *how far from the threshold is it?*

---

### From sign to distance: the value certificate

The same algebra that produced the sign criterion produces something stronger.
For any rational $a/(a+c)$, the key rate there is *exactly* a logarithm of a
rational number:

$$r\!\left(\frac{a}{a+c}\right) \;=\; \frac{1}{a+c}\,\log\!\left(\frac{2^{\,a+c}\,a^{2a}\,c^{2c}}{(a+c)^{2(a+c)}}\right).$$

Call that big rational ratio $R$. It is bigger than $1$ exactly when the point is
below threshold. To turn this exact formula into certified numerical bounds, one
needs certified bounds on $\log R$ — and here elementary calculus does the job,
provided one chooses the right elementary bounds.

The naive bounds $1 - x^{-1} \le \log x \le x - 1$ have error quadratic in
$x - 1$, and near our $R \approx 1.0000279$ that costs about half of the
available precision. The **Padé bounds of order $(1,1)$**,

$$\frac{2(x-1)}{x+1} \;\le\; \log x \;\le\; \frac{x - x^{-1}}{2}
\qquad \text{for } x \ge 1,$$

have error *cubic* in $x-1$, and are elementary to prove: the differences
$\log x - \frac{2(x-1)}{x+1}$ and $\frac{x-x^{-1}}{2} - \log x$ vanish at $x=1$
and have derivatives $\frac{(x-1)^2}{x(x+1)^2}$ and $\frac{(x-1)^2}{2x^2}$
respectively, both manifestly non-negative. So both differences increase from
zero. That is the whole proof.

Combining the exact formula with the Padé bounds, a *pair* of integer comparisons
— pinning $R$ between two explicit rationals — yields a certified two-sided
numerical bracket for the key rate at the chosen point. The transcendental
function has been replaced, with proof, by two whole-number comparisons and a
rational function.

---

### One step of Newton, made honest

Knowing the value of $r$ at a point $q_0$ near the root, and knowing how steeply
$r$ is falling, tells you where the root is. This is Newton's method — but
Newton's method as usually practised produces an *estimate*, not a *proof*. The
mean value theorem upgrades it.

The derivative of the binary entropy is
$H_2'(x) = \log(1-x) - \log x = \log\frac{1-x}{x}$, a decreasing function. If
$q_0 < p_\star < q_1$ and we can certify

* a numerical bracket $A_1 < \tfrac12 r(q_0) < A_2$ for the entropy defect at the
  anchor, and
* a numerical bracket $L \le H_2'(x) \le U$ valid for *all* $x$ in $[q_0,q_1]$,
  with $L > 0$,

then the mean value theorem, applied to $H_2$ on the interval from $q_0$ to
$p_\star$, produces a point $\xi$ strictly between them with
$H_2'(\xi)\,(p_\star - q_0) = H_2(p_\star) - H_2(q_0) = \tfrac12 r(q_0)$. Since
$\xi$ lies in $[q_0,q_1]$, its derivative is trapped between $L$ and $U$, and
dividing gives:

> **The Refinement Step.** Under the hypotheses above,
> $$q_0 + \frac{A_1}{U} \;<\; p_\star \;<\; q_0 + \frac{A_2}{L}.$$

The width of the new enclosure is $A\left(\frac1L - \frac1U\right) \approx
(p_\star - q_0)\cdot\frac{U-L}{L}$. And since the derivative bracket has to cover
the interval between the anchor and the root, $U - L$ is itself proportional to
$|p_\star - q_0|$. The conclusion is a *quadratic law*: an anchor at distance
$\delta$ from the root yields a certified enclosure of width roughly $5\delta^2$.

Anchoring at $11/100$, whose distance from the root is
$\delta \approx 2.79 \times 10^{-5}$, this predicts a final width around
$4\times 10^{-9}$ — and indeed a careful execution of the step lands on

$$0.11002786 \;<\; p_\star \;<\; 0.11002787,$$

eight certified decimals. To do better one needs a better anchor. And *that*
is where the story takes its unexpected turn.

---

### Why decimals are the wrong numbers

The quadratic law says: halve the anchor's distance to the root, and you quarter
the final width. The problem is that improving a *decimal* anchor from $10^{-5}$
accuracy to $10^{-7}$ accuracy requires a certificate at denominator $10^7$ —
the hundred-megabyte integers we already ruled out.

But nothing in the argument requires the anchor to be a decimal. *Any* rational
number works. And rational numbers, it turns out, are wildly unequal in how much
accuracy they buy per unit of denominator.

This is the domain of **Diophantine approximation**, and its central tool is the
continued fraction expansion. Every real number $x$ has a unique expansion

$$x \;=\; a_0 + \cfrac{1}{a_1 + \cfrac{1}{a_2 + \cfrac{1}{a_3 + \ddots}}}$$

with integer coefficients, and truncating it produces the **convergents** — a
sequence of fractions $p_k/q_k$ that are provably the *best rational
approximations* to $x$: no fraction with a smaller denominator comes closer. Each
convergent satisfies $|x - p_k/q_k| < 1/q_k^2$, and often does far better.

The continued fraction of the BB84 threshold begins
$$p_\star \;=\; [\,0;\,9,\,11,\,3,\,2,\,208,\,2,\,12,\ldots\,],$$
and its convergents are
$$\frac{0}{1},\quad \frac{1}{9},\quad \frac{11}{100},\quad \frac{34}{309},\quad
\frac{79}{718},\quad \frac{16466}{149653},\quad \frac{33011}{300024},\ \ldots$$

Stop and look at the third one. It is $11/100$. **The textbook value is a
continued-fraction convergent of the threshold** — which means, by the best-
approximation theorem, that $11/100$ is the closest any fraction with denominator
at most $308$ ever gets to $p_\star$. The folk value $11\%$ is not a lazy
rounding; it is optimal for its size. Its error is
$$p_\star - \tfrac{11}{100} \;=\; 2.7864438\ldots\times 10^{-5},$$
and this too is now certified: rigorously, $2.786\times10^{-5} <
|p_\star - 0.11| < 2.787\times 10^{-5}$.

Now look at the fifth convergent, $79/718 = 0.110027855\ldots$. Its denominator
is a mere three digits — smaller than the $10^4$ we already used successfully —
yet
$$\left|\frac{79}{718} - p_\star\right| \;=\; 9.285\times 10^{-9},$$
three thousand times closer to the root than $11/100$. The certificate for this
anchor involves integers with $4102$ digits: *twenty times smaller* than the
80 000-digit certificate of the four-decimal stage, and yielding an anchor
three thousand times better. That is the whole idea of this work in one
sentence.

---

### The payoff

Executing the plan at the anchor $79/718$ requires three ingredients, each
certified.

**First**, the position of the anchor. Comparing
$718^{1436}$ against $2^{718}\cdot 79^{158}\cdot 639^{1278}$ shows the anchor is
below threshold. Sharpening it, the two comparisons
$$100002787345813950188 \cdot 718^{1436}
\;<\; 10^{20}\cdot 2^{718}\, 79^{158}\, 639^{1278}
\;<\; 100002787345813950189\cdot 718^{1436}$$
pin the ratio $R$ to twenty significant figures, and through the Padé bounds this
gives
$$3.882043130930\times 10^{-8} \;<\; r\!\left(\tfrac{79}{718}\right) \;<\; 3.882043131686\times 10^{-8}.$$

**Second**, the derivative bracket. On the interval
$[79/718,\ 0.11002787]$ — whose right endpoint comes from the eight-decimal
enclosure — monotonicity of $\log\frac{1-x}{x}$ reduces the bracket to two
logarithms of explicit rationals, $\log(639/79)$ and
$\log(88997213/11002787)$. Splitting off a factor of $8$ (whose logarithm is
$3\log 2$) and applying the Padé bounds to what remains yields
$$2.0904563381 \;\le\; H_2'(x) \;\le\; 2.0904568254
\qquad\text{for all } x \in [\tfrac{79}{718},\, 0.11002787],$$
a bracket of width under $5\times 10^{-7}$.

**Third**, the refinement step, applied once. The result:

> **Thirteen Certified Decimals.** The unique quantum bit error rate at which the
> asymptotic one-way BB84 secret-key rate vanishes satisfies
> $$0.1100278644383 \;<\; p_\star \;<\; 0.1100278644384 .$$
> Equivalently, $\lfloor 10^{13} p_\star \rfloor = 1100278644383$.

The certified interval actually has width $2.17\times 10^{-15}$ — comfortably
inside the stated decimals with two orders of magnitude to spare. The certified
digit count across the four stages of this development ran $4 \to 6 \to 8 \to
13$.

---

### The economics of certainty

Step back and the structure is a clean trade-off between two exponents.

The **cost** of a certificate at denominator $q$ grows like $q^2$: the integers
have $O(q\log q)$ digits, and comparing them takes about that long, with the
practical constant governed by how the arithmetic is carried out.

The **precision** delivered by a convergent of denominator $q$ is governed by the
quadratic refinement law applied to $\delta \approx q^{-2}$, giving a final width
of order $\delta^2 \approx q^{-4}$.

So precision improves like $q^{-4}$ while cost grows like $q^{2}$: to buy a
certified enclosure of width $\varepsilon$ costs about $\varepsilon^{-1/2}$
arithmetic, rather than the $\varepsilon^{-1}$ that naive digit-by-digit
certification demands. The exponents conspire to halve the cost. This is why a
$718$-denominator anchor beats a $10^4$-denominator one so decisively, and why
the next convergent, $16466/149653$, would in principle reach about $10^{-21}$.

There is a satisfying moral here about *what a hard number actually costs*. The
brute-force route — more digits, bigger integers — hits a wall that is
essentially about memory. The clever route recognizes that the difficulty is not
in the arithmetic but in the *choice of the point at which to do the arithmetic*,
and that this is a question in number theory, not in computation. Diophantine
approximation, a subject born from questions about how well irrational numbers
can be mimicked by fractions, turns out to be the natural resource for
certifying a constant of quantum cryptography.

---

### Why anyone should care

One could reasonably ask whether thirteen decimals of a security threshold is
useful. No experimentalist will ever measure a quantum bit error rate to
$10^{-13}$; real devices struggle to know their $Q$ to three significant figures.

But that is not the point, in two ways.

The first is about *the value itself as a reference*. Security parameters get
compared, composed, and propagated through finite-key analyses, decoy-state
estimates, and composability arguments. A threshold known only as "about $11\%$"
introduces an error of $2.8\times10^{-5}$ into every downstream statement that
uses it — small, but unquantified, and unquantified error is the enemy of a
security proof. Now it is quantified exactly: the classical figure $11\%$
*understates* the tolerable error rate by $2.7864438\ldots\times 10^{-5}$, and
anyone who wants to know whether that matters for their analysis can simply look
it up.

The second, larger point is about *method*. The pipeline assembled here —
reduce a transcendental comparison to an exact integer criterion; sharpen the
value with rational-function bounds proved from monotonicity; anchor at a
continued-fraction convergent rather than a decimal; take one mean-value step —
is not specific to the binary entropy. It applies verbatim to any real-analytic
function with a simple root whose sign at rationals is decidable by an integer
comparison, and there are many such constants throughout information theory:
capacity thresholds, cutoff rates, percolation and phase-transition constants,
the fixed points of entropy inequalities. Each of them is currently known the way
$11\%$ was known — as a floating-point number someone once computed.

The threshold at which quantum cryptography stops working is
$0.1100278644383\ldots$, and now we know it, rather than merely believing it.
The interesting part was never the digits. It was discovering that the fastest
route to them ran through the theory of continued fractions — and that the
number the textbooks had been quoting all along was, quietly, the best fraction
of its size.
