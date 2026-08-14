# The Number Hidden in a Puff of Smoke

## How a single measurement of a diffusing cloud can reveal a secret exponent — and why that is both wonderful and useless

Imagine a circular racetrack divided into $r$ equally spaced lanes, numbered $0, 1, 2, \dots, r-1$, with lane $r$ wrapping back to lane $0$. You drop a single grain of dust at lane $0$ and let it wander. At each tick of the clock the grain either stays put — with probability $1/2$, it is a lazy grain — or it jumps. When it jumps, it does not shuffle politely to a neighbouring lane. It teleports by a power of two: forward or backward by $1$, or by $2$, or by $4$, by $8$, by $16$, and so on, up to some largest jump $2^M$, each of these $2(M+1)$ options equally likely.

Let the grain wander for a while. Now ask one single question, and only one:

> **What is the probability that the grain is back at lane $0$?**

Call that number $p_n(e)$, where $n$ is the number of ticks. It is one real number. It carries no direct information about *where* the grain has been, no trajectory, no histogram — just the mass that has returned home.

The claim of this article is that if you wait exactly $n = 8(M+1)^2$ ticks, then

$$\left\lfloor \frac{1}{p_n(e)} \right\rceil = r,$$

where $\lfloor \cdot \rceil$ denotes rounding to the nearest integer. That is, **one scalar measurement of a diffusion, rounded, tells you the exact length of the track.** Not approximately. Exactly, with a proof.

And here is where it becomes interesting rather than merely cute: in the right disguise, the length of the track is a cryptographic secret.

---

## Part I: Why the track length is a secret

Fix a large integer $N = pq$, the product of two unknown primes, and a base $b$ coprime to $N$. The powers of $b$ modulo $N$,
$$b, \; b^2, \; b^3, \dots$$
eventually cycle. The length of that cycle is the **multiplicative order** $r = \operatorname{ord}_N(b)$: the least positive integer with $b^r \equiv 1 \pmod N$.

The set of powers $\{1, b, b^2, \dots, b^{r-1}\}$ is a cyclic group of size $r$ — a circular racetrack with $r$ lanes, where "moving forward by $s$ lanes" means "multiply by $b^s$". So the abstract track above is not an analogy; it is exactly the multiplicative cycle of $b$ modulo $N$, and $r$ is its length.

Knowing $r$ is very nearly the same as knowing $p$ and $q$. Here is the classical one-line reduction, which we will state precisely later. Suppose $r$ is even, write $r = 2m$, and put $y = b^m \bmod N$. Then
$$y^2 \equiv b^r \equiv 1 \pmod N,$$
so $N$ divides $(y-1)(y+1)$. If $y \not\equiv \pm 1$, then $N$ divides the product but neither factor, and $\gcd(y-1, N)$ is forced to be a proper divisor of $N$. One greatest common divisor — cost negligible — and the factorisation falls out.

A concrete case: take $N = 143$ and $b = 2$. The order of $2$ modulo $143$ is $r = 60$. Halving, $m = 30$, and $2^{30} \equiv 12 \pmod{143}$, which is neither $1$ nor $-1$. Then $\gcd(12 - 1, 143) = \gcd(11, 143) = 11$, and indeed $143 = 11 \times 13$. The secret was the number $60$, and the diffusion above hands it to you as a single rounded reciprocal.

This is why order-finding is the beating heart of Shor's algorithm, and why any classical machine that finds orders cheaply would be extraordinary news. Hold that thought; the punchline of this article is that the diffusion, beautiful as it is, is *not* that machine — and understanding precisely why it is not is as valuable as the mechanism itself.

---

## Part II: Powers of two are a battering ram

Why should the return probability know anything at all? The mechanism is spectral, and it rests on a small combinatorial miracle about doubling on a circle.

A random walk on a cycle of length $r$ is diagonalised by the characters $\chi_k(x) = e^{2\pi i k x / r}$, for $k = 0, 1, \dots, r-1$. Each character is an eigenvector of the one-step averaging operator, and for our lazy dyadic walk the eigenvalue attached to frequency $k$ is
$$\mu_k = \frac{1}{2}\left(1 + \lambda_k\right), \qquad \lambda_k = \frac{1}{M+1}\sum_{t=0}^{M} \cos\!\left(\frac{2\pi k 2^t}{r}\right).$$
The frequency $k = 0$ always gives $\mu_0 = 1$; that eigenvalue represents the conserved total probability. Every other frequency contributes a mode that decays like $\mu_k^n$. Because the walk started as a point mass at $0$ and the characters are an orthogonal basis, the return probability is nothing but the average of the $n$-th powers of the eigenvalues:
$$p_n(e) = \frac{1}{r} \sum_{k=0}^{r-1} \mu_k^{\,n} = \frac{1}{r} + \frac{1}{r}\sum_{k \ne 0}\mu_k^{\,n}.$$

So the return probability is $1/r$ **plus a decaying error**. The whole game is to force that error below the resolution needed to round $1/p_n(e)$ correctly, and to do it fast.

The error is small exactly when every nontrivial eigenvalue is bounded away from $1$. And here is where the powers of two do their work. A single generator $\pm 1$ (the ordinary lazy walk) is a disaster: the low frequency $k=1$ gives $\cos(2\pi/r) \approx 1 - 2\pi^2/r^2$, so the slowest mode decays only after $\Theta(r^2)$ steps — for $r$ of cryptographic size, that is forever. Lacunary dyadic generators fix this at a stroke.

**The doubling lemma.** *Let $r \le 2^M$, and let $k$ be any frequency that is not a multiple of $r$. Then there exists a shift $t \le M$ such that $2^t k$, reduced modulo $r$, lies in the "far arc" $[r/4, 3r/4]$.*

The proof is an escape argument that a child can follow. Measure how close a point $x$ is to the origin of the circle by
$$d(x) = \min\!\left(x \bmod r, \; r - (x \bmod r)\right),$$
the *circle distance*: it is $0$ at the origin and maximal, $\approx r/2$, at the antipode. The far arc is precisely the set of $x$ with $d(x) \ge r/4$. Now observe: **while a point is closer to the origin than a quarter of the circle, doubling it exactly doubles its circle distance.** ($d(2x) = 2d(x)$ whenever $4d(x) < r$; you can see this by looking at the two cases, $x$ near the origin from the left and from the right — no wrap-around can occur, because $2d(x) < r/2$.)

Suppose, then, that *no* dyadic shift ever reaches the far arc. Then the doubling identity applies at every step, and by induction
$$d(2^M k) = 2^M \, d(k) \ge 2^M \ge r,$$
using $d(k) \ge 1$ (the frequency is not $0$ modulo $r$) and the assumption $r \le 2^M$. But the circle distance can never exceed $r/2$. Contradiction. Some shift must have crossed into the far arc.

That is the whole idea, and it is remarkably robust: *the doubling orbit of any nonzero point cannot stay near the origin for $\log_2 r$ consecutive steps, because staying near means growing geometrically, and growth on a circle is self-limiting.*

The spectral consequence is immediate. If $2^{t_0}k$ lies in the far arc, then the angle $2\pi \cdot 2^{t_0} k / r$ lies between $\pi/2$ and $3\pi/2$, so that cosine is $\le 0$. Every other cosine in the sum is at most $1$, and there are $M$ of them. Hence
$$\lambda_k \le \frac{M \cdot 1 + 0}{M+1} = 1 - \frac{1}{M+1}, \qquad \mu_k \le 1 - \frac{1}{2(M+1)}.$$
Laziness (the $1/2$ chance of staying put) also guarantees $\mu_k \ge 0$, ruling out the opposite failure of the walk oscillating forever between odd and even lanes.

So **every** nontrivial mode decays by a constant factor per $2(M+1)$ steps, with $M \approx \log_2 N$. One frequency, one crossing, one negative cosine — and the whole spectrum is tamed.

---

## Part III: Two lines of arithmetic finish it

Write $\beta = 1 - \frac{1}{2(M+1)}$. Since $0 \le \mu_k \le \beta$ for every $k \ne 0$, the error term is squeezed:
$$\frac{1}{r} \;\le\; p_n(e) \;\le\; \frac{1}{r} + \beta^{\,n}.$$
The lower bound is free (all the terms are nonnegative); the upper bound uses that there are $r - 1$ nontrivial modes, each at most $\beta^n$, divided by $r$.

Now choose $n = 8(M+1)^2$. Using $1 - \delta \le e^{-\delta}$,
$$\beta^{\,n} \le \exp\!\left(-\frac{8(M+1)^2}{2(M+1)}\right) = e^{-4(M+1)} \le 4^{-(M+1)} = \frac{1}{4 \cdot 4^{M}} \le \frac{1}{4N^2},$$
the last step because $N \le 2^M$, so $N^2 \le 4^M$. The whole nontrivial spectrum has been crushed to $1/(4N^2)$ after a number of steps quadratic in the bit-length of $N$.

Finally, rounding. Suppose $1/r \le p \le 1/r + \varepsilon$ with $2r^2\varepsilon < 1$. Then $1/p \le r$, and a short computation gives $1/p > r - 1/2$, so $1/p$ lies in the half-open window that rounds to $r$. With $\varepsilon = 1/(4N^2)$ and $r \le N$, we have $2r^2 \varepsilon = r^2/(2N^2) \le 1/2 < 1$, comfortably inside the margin. Hence:

> **Heat-Kernel Order Recovery Theorem.** *Let $0 < r \le N \le 2^M$ and let $n = 8(M+1)^2$. Then the return probability of the half-lazy lacunary dyadic walk on the cycle of length $r$ satisfies*
> $$\left\lfloor \frac{1}{p_n(e)} \right\rceil = r.$$
> *In particular, for any unit $b$ modulo $N$, the walk built from the cycle of $b$ recovers the multiplicative order $\operatorname{ord}_N(b)$ exactly.*

Numerically, this is not delicate. For $N = 143$, $b = 2$ ($r = 60$, $M = 8$, $n = 648$) the reciprocal of the return probability comes out as $60.000000$; for $N = 899$, $b = 3$ ($r = 420$, $M = 10$, $n = 968$) it comes out as $419.99999999999994$. Rounding is not even close to a judgement call — the theorem leaves a full factor-of-two safety margin, and the numerics reflect it.

---

## Part IV: The measurement is real, not a formula

It is fair to object that $p_n(e) = \frac{1}{r}\sum_k \mu_k^n$ is a *spectral formula*, and that writing it down already presumes knowledge of $r$. So the claim would be circular if the formula were the definition of the quantity being measured.

It is not. Define the diffusion operator directly, on functions $f$ on the cycle:
$$(Wf)(x) = \frac{f(x)}{2} + \frac{1}{4(M+1)}\sum_{t=0}^{M}\Big( f(x + 2^t) + f(x - 2^t)\Big).$$
This is a completely explicit, local, physical rule: keep half the mass, spread the rest equally over the $2(M+1)$ dyadic neighbours. Start with a unit mass at the origin — the periodic delta function $\delta$ — apply $W$ exactly $n$ times, and read off the mass at the origin.

Two facts, both elementary and both essential, connect the physics to the algebra. First, **the characters are exactly the eigenvectors**: $W \chi_k = \mu_k \chi_k$, with $\mu_k$ the eigenvalue written above; this is just the identity $\chi_k(x+m) + \chi_k(x-m) = 2\cos(2\pi k m/r)\chi_k(x)$. Second, **character orthogonality on the cycle**: $\sum_{k=0}^{r-1}\chi_k(x) = r\,\delta(x)$, a geometric-series computation. Expanding $\delta$ in the character basis and pushing $W^n$ through the sum then yields
$$\big(W^n \delta\big)(0) = \frac{1}{r}\sum_{k=0}^{r-1}\mu_k^{\,n} = p_n(e).$$

So the quantity being rounded is a genuine, operationally defined return probability of a diffusion you could run on a physical device, and the spectral sum is a theorem about it, not its definition. **Operationally: measure the mass at the origin once, after $8(M+1)^2$ ticks, invert, round — and out comes the order.**

---

## Part V: The catch, stated honestly

Nothing in the preceding argument beats anything. Let us be exact about why, because that is where the mathematics gets sharp.

**The number of ticks is provably quadratic, not linear.** One might hope the analysis is lossy and that $O(\log N)$ steps suffice. It does not. For the extremal *Mersenne* cycle length $r = 2^M - 1$, the top nontrivial eigenvalue satisfies
$$\lambda_1 \ge 1 - \frac{106}{M+1},$$
so the spectral gap of the lacunary dyadic walk is $\Theta(1/M)$ — the upper bound $1 - 1/(M+1)$ and this lower bound differ only by an absolute constant. The reason is transparent once seen: for $r = 2^M-1$, the dyadic orbit $\{2^t \bmod r\}$ is precisely the set of binary place values $1, 2, 4, \dots, 2^{M-1}$, so all but a handful of the frequencies $2^t/r$ are *tiny*, and their cosines are essentially $1$. Only the last few terms contribute any deficiency at all. Consequently the diffusion genuinely needs quadratically many steps: for $M \ge 106$ and any $n$ with $154\,n \le M(M+1)$, the rounding **fails** — the recovered value is not $r$. Upper and lower bound together pin the diffusion time at exactly $\Theta((\log N)^2)$.

**The measurement is an aggregate of $r$ modes.** To evaluate $p_n(e)$ by the spectral formula, you sum over all $r$ eigenvalues. To evaluate it by simulating $W$, you carry a vector of length $r$. Either way, the cost of the *aggregation* is $\Theta(r)$, and $r$ divides $\varphi(N)$ and is typically of size comparable to $N$. The scalar you extract is cheap to *use* and expensive to *produce*. A physical diffuser whose wall-clock time does not grow with the state space does not escape this: its area, its energy, or its mode count must scale with $r$. The $r$ cells *are* the cost. There is no free lunch hiding in the analog domain — only a relocation of the bill from time to hardware.

**The witness value is essentially $1/r$, so it is "multiplicative" after all.** This deserves an honest correction of a tempting slogan. One might advertise the heat-kernel witness as a fundamentally *non-multiplicative* invariant, in contrast to the local, Chinese-Remainder-style counting statistics that dominate this landscape. But the theorem above says $p_n(e)$ agrees with $1/r$ to within $1/(4N^2)$, and $1/r$ is a perfectly multiplicative function of the order: whenever $r_1 r_2 \le N$,
$$\Big| p_n^{(r_1 r_2)} - p_n^{(r_1)} p_n^{(r_2)} \Big| \le \frac{1}{N^2}.$$
So the *value* of the witness is multiplicative up to negligible error. What is genuinely non-multiplicative is the **mechanism**: the value is produced as a spectral aggregate over all $r$ eigenvalues of a graph built from $N$, not as a local count with multiplicative weights. That distinction — new mechanism, familiar coordinate — is the precise content of the extension.

There is a pleasant rigidity statement lurking here too. Since rounding recovers $r$ exactly, the map $r \mapsto p_n(e)$ is **injective** on the range $1 \le r \le N$: two cycle lengths bounded by $N$ with the same heat-kernel value are equal. The single scalar is not merely a good estimator of $r$; it is a complete invariant of $r$ in that range.

---

## Part VI: What the result actually teaches

Strip away the cryptographic framing and something clean remains: a general and reusable design principle for diffusion on abelian groups.

*Lacunary dyadic generators buy you a spectral gap that no bounded generating set can.* The nearest-neighbour walk on a cycle of length $r$ mixes in $\Theta(r^2)$ steps; adding all $\log r$ dyadic jumps drops that to $O((\log r)^2)$ — an exponential improvement — and the proof is the single escape argument of Part II, not any deep harmonic analysis. The doubling lemma is the entire engine, and it says something memorable in its own right: *you cannot repeatedly double a nonzero point on a circle and always land near the origin.*

And the negative half of the story is just as instructive. When a quantity that looks impossibly cheap — one number! — hands you something expensive, the accounting has to balance somewhere. Here it balances in the aggregation: producing that one number requires touching $\Theta(r)$ modes. The heat-kernel witness is a beautifully clean example of a phenomenon worth naming: an invariant that is *informationally free* and *computationally sealed*. It recovers the secret coordinate perfectly, in a way that is fully proved, fully explicit, and completely honest about not being a shortcut.

That, in the end, is the pleasure of it. A grain of dust hops by powers of two around an invisible circle. After $8(M+1)^2$ ticks you ask how much of it came home, take the reciprocal, and round. Out comes an integer — the exact circumference of a circle you never saw. The mathematics is airtight, the constant is sharp, the mechanism generalises, and the shortcut it seems to promise is precisely, provably, the one it does not deliver.
