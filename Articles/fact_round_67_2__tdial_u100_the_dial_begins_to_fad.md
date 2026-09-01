# The Dial That Faded

## How a fraction, $6/7$, cleared the dice of suspicion

There is a moment in every measurement program when the instrument stops agreeing with itself. A quantity you have tracked for months, comfortably inside its expected range, drifts to the edge. Then the error bar straddles the boundary: part of it inside, part outside. The reading no longer says *yes*, and it does not yet say *no*. It says: **I can no longer tell.**

This is the story of one such moment, and of the piece of number theory that told us where to look for the cause — and, more importantly, where *not* to look.

---

## A dial made of trailing zeros

Start with an integer $x$, written in binary. Count the zeros at its right-hand end before the first $1$. That count is the **trailing-zero statistic**, written $T(x)$, and mathematicians know it as the *2-adic valuation* $v_2(x)$: the largest power of $2$ dividing $x$.

$$T(12) = T(1100_2) = 2, \qquad T(7) = 0, \qquad T(96) = 5.$$

It is a humble quantity, but it is a remarkably good *dial*: in a variety of settings, $T(x)$ predicts something else about $x$ — call it the response, or the rate — better than the more obvious summary statistics do. Over a long sequence of experiments the strength of this prediction was measured by **Spearman's rank correlation** $\rho$ between $T$ and the rate: a number between $-1$ and $1$ that asks not "do these grow together linearly?" but "do they *order* the same way?"

The dial worked. At inputs of 76 binary digits — bitlen 76 — the correlation sat at $\rho \approx 0.608$. The program declared a validated band: as long as $\rho \ge 0.55$, the dial is trustworthy. For a long time it was.

Then came bitlen 100. Three independent runs returned $0.546$, $0.528$, $0.549$; pooled, $\rho = 0.544$, with a confidence interval $[0.498, 0.588]$. For the first time on uniform draws, the interval **straddled** the floor $0.55$ — one end above, one end below, the point estimate just underneath. The dial had begun to fade.

---

## The suspect: the dice

Before you conclude that a signal is decaying, you check the instrument. And here there was an obvious suspect.

Trailing zeros are *massively tied*. Among the integers, about half have $T=0$, a quarter have $T=1$, an eighth have $T=2$, and so on: the tie blocks form a geometric cascade of sizes roughly $n/2, n/4, n/8, \dots$ for a sample of size $n$. Spearman's correlation is built from ranks, and tied values must all share the same average rank. Ties therefore impose a hard **ceiling**: no matter how perfectly the response tracks $T$, the correlation cannot reach $1$, because within each tie block the statistic contains no information at all.

The ceiling is computable. If the tie blocks have sizes $m_0, m_1, m_2, \dots$ summing to $n$, the largest squared Spearman correlation achievable by any response that respects and refines the tie structure is
$$\rho^2_{\max} = 1 - \frac{\sum_i (m_i^3 - m_i)}{n^3 - n}.$$
The cubes are the signature of rank statistics: a tie block of size $m$ destroys exactly $(m^3 - m)/12$ units of the available rank variance.

Now the suspicion. Feed in the perfect geometric cascade $m_i = n/2^{i+1}$ and the cubes sum to a geometric series with ratio $1/8$:
$$\sum_i \frac{n^3}{8^{i+1}} = \frac{n^3}{7}.$$
That $7$ in the denominator — from $1 + 1/8 + 1/64 + \cdots = 8/7$ — propagates straight through to the ceiling:
$$\rho^2_{\max} \approx 1 - \frac{1}{7} = \frac{6}{7} \approx 0.857.$$

But real samplers do not draw from $\{0, 1, \dots, 2^b - 1\}$ exactly. They draw from a rejection window, or a residue class, or a truncated stream, or — most commonly at bitlen 100 — the *offset* window $[2^{99}, 2^{100})$ of numbers with exactly 100 binary digits. In such a sample the tie blocks are no longer exactly geometric; they wobble. And if the blocks wobble, so does the ceiling. Perhaps the fade at bitlen 100 was never a fade at all. Perhaps the sampler moved the ceiling, and the measurement obediently followed it down.

That is the objection this work answers. The answer is: **no. The ceiling does not move. Not for any sampler.**

---

## The halving recursion

Begin with the simplest generalisation: draw uniformly from $\{0, 1, \dots, n-1\}$ for an arbitrary $n$, not necessarily a power of two. What is the tie profile?

Among the numbers below $n$, exactly $\lfloor n/2 \rfloor$ are odd — those are the ones with $T=0$. The even ones are $2y$ with $y < \lceil n/2 \rceil$, and $T(2y) = T(y) + 1$. So the profile of $n$ is the number $\lfloor n/2 \rfloor$ followed by the profile of $\lceil n/2 \rceil$:
$$B(n) = \left\lfloor \tfrac n2 \right\rfloor \ \Vert \ B\!\left(\left\lceil \tfrac n2 \right\rceil\right), \qquad B(1) = (1).$$

That single recursion is the engine of everything that follows. Iterate it on $n = 11$ and you get $(5,3,1,1,1)$ — a cascade that is *approximately* but not exactly geometric.

To measure the discrepancy, define the **ceiling defect**
$$E(n) = \sum_i m_i^3 - \frac{n^3}{7},$$
the gap between the actual sum of cubes and the idealised geometric value. The behaviour of $E$ is where the mathematics turns beautiful.

**First, $E$ is blind to doubling.** For every $m \ge 1$, $E(2m) = E(m)$. The proof is two lines of the recursion: the leading block of $2m$ has size exactly $m$, the tail is the profile of $m$ itself, and $m^3 + (m^3/7) = (2m)^3/7$ exactly. Doubling costs nothing.

Consequently $E$ depends only on the **odd part** of $n$. Strip out all the factors of $2$ and $E$ is unchanged. This is the fingerprint of a genuinely self-similar, digit-theoretic object — the same family as the nowhere-differentiable Takagi function and the Trollope–Delange fluctuations of binary digit sums.

**Second, the odd step is an exact quadratic.** For $a \ge 1$,
$$E(2a+1) = E(a+1) - \frac{9a^2 + 3a}{7}.$$

**Third, at every power of two the defect is the same rational number.** Since $E(1) = 1 - 1/7 = 6/7$ and doubling is free,
$$E(2^b) = \frac{6}{7} \quad \text{for every } b.$$

And now the universal law. Substituting $\sum m_i^3 = n^3/7 + E(n)$ into the ceiling formula gives, for every $n \ge 2$,
$$\boxed{\ \rho^2_{\max}(n) \;=\; \frac67 \;+\; \frac{\tfrac67 n - E(n)}{n^3 - n}. \ }$$

One formula, every sample size. And because $-\tfrac37 n^2 \le E(n) \le \tfrac67$ for all $n$ — the upper bound attained *exactly* at the powers of two, the lower one approached along a specific family — the correction term is squeezed:
$$\frac67 \;<\; \rho^2_{\max}(n) \;\le\; \frac67 + \frac{1}{n-1}.$$

Every draw range in existence has tie ceiling $6/7 + O(1/n)$, and always **above** $6/7$, never below.

---

## Powers of two are the hardest case

Two refinements make the picture sharp, and both are pleasing.

The maximum $E(n) = 6/7$ is attained *if and only if* $n$ is a power of two. The argument is a clean induction: an even $n$ inherits its defect from $n/2$; an odd $n = 2a+1$ with $a \ge 1$ pays the quadratic penalty $(9a^2+3a)/7$ and therefore falls strictly short. So powers of two are precisely the **unique minimisers of the ceiling** — the worst case for the dial, and the one every previous analysis had assumed.

How far can the defect swing the other way? The sharp bound is $E(n) \ge -\tfrac37 n^2$, and the constant $3/7$ cannot be improved. To see it realised, follow the family $n_j = 2^{j+1}+1$, chosen so that the halving chain $n \mapsto (n+1)/2$ stays odd all the way down and the quadratic penalty is paid at every single rung. Summing the penalties gives a geometric series of ratio $1/4$:
$$\frac{9}{28}\left(1 + \frac14 + \frac1{16} + \cdots\right) = \frac{9}{28}\cdot\frac43 = \frac37.$$
Along that family, $E(n_j)/n_j^2 \to -3/7$, and the ceiling excess $\rho^2_{\max}(n) - 6/7$ is $\Theta(1/n)$ — whereas for $n = 2^b$ it is only $\Theta(1/n^2)$.

At bitlen 100 this **dichotomy** is spectacular: the excess for the odd range $\{0,\dots,2^{100}-2\}$ exceeds the excess for the power-of-two range $\{0,\dots,2^{100}-1\}$ by a factor of more than $10^{28}$. The parity structure of the sample size matters enormously — in relative terms.

And it matters not at all in absolute terms. Both excesses are unimaginably small. For every $n \ge 2^{100}$,
$$\frac67 < \rho^2_{\max}(n) < \frac67 + 10^{-29}.$$
The entire admissible spread of tie ceilings across all bitlen-100 samplers has width below $10^{-29}$, while the observed four-bit erosion step is $0.030$. Range shape is smaller than the observed effect by twenty-seven orders of magnitude.

---

## Removing the last assumption

All of this still assumes the sampler starts at zero. The final step removes even that, by abstracting the only property of the geometric cascade that the argument ever used.

Call a tie profile **dyadically dominated at scale $x$ with slack $C$** if its $i$-th block obeys
$$m_i \;\le\; \frac{x}{2^{i+1}} + C.$$
No exact recursion, no exact geometry: just an upper envelope. The key theorem is that domination alone forces the cube sum down:
$$\sum_i m_i^3 \;\le\; \frac{x^3}{7} + Cx^2 + 3C^2 x + C^3 K,$$
where $K$ is the number of blocks. The induction is a small marvel of bookkeeping — peel off the head block, bounded by $x/2 + C$, apply the hypothesis to the tail at scale $x/2$, and watch all four coefficients balance exactly:
$$\frac18 + \frac1{56} = \frac17, \qquad \frac{3C}{4} + \frac{C}{4} = C, \qquad \frac{3C^2}{2} + \frac{3C^2}{2} = 3C^2.$$
The $1/7$ is the geometric fixed point; the other three are the error terms, and they close on the nose.

Why is domination automatic? Because of a piece of elementary arithmetic. If $v_2(x) = k$ then $x \equiv 2^k \pmod{2^{k+1}}$ — the numbers of valuation exactly $k$ are $2^{k+1}$-separated on the number line. So any window $[A, A+n)$ of length $n$ contains at most $n/2^{k+1} + 2$ of them. Every offset window is dominated with slack $C = 2$; every zero-based range with slack $C = 1$.

The conclusion is sampler-free. **Any** dyadically dominated profile at bitlen 100 with slack $C \le 4$ has ceiling above $6/7 - 1/100 > 0.85$. The measured reading squares to $0.544^2 \approx 0.296$. It is not close. It is not within a factor of two. Whatever caused the fade, it did not come from the shape of the draws.

The dice are exonerated.

---

## The base that drifts

If the sampler is innocent, what *is* going on? A striking numerical coincidence supplies a language for the answer.

Repeat the whole cascade analysis in base $p$ instead of base $2$: the tie blocks of the $p$-adic valuation have sizes $\approx n(p-1)/p^{i+1}$, the cubes sum to $\frac{(p-1)^3}{p^3-1}n^3$, and the ceiling becomes
$$\frac{3p}{p^2+p+1},$$
thanks to the identity $1 - \frac{(p-1)^3}{p^3-1} = \frac{3p}{p^2+p+1}$. At $p=2$ this returns $6/7$, as it must. And the same domination argument works verbatim in base $p$, so this ceiling too is a fact about envelopes, not about sample sizes.

Now invert. Which base $p$ has ceiling matching the *measured* correlation? At bitlen 76, with $\rho \approx 0.608$ and $\rho^2 \approx 0.370$, the unique integer answer is $p = 7$: $\ 3\cdot7/57 = 7/19 \approx 0.368$. At bitlen 100, with the three seeds giving $\rho^2$ between $0.528^2 = 0.279$ and $0.549^2 = 0.301$, the unique integer answer is $p = 9$: $\ 27/91 \approx 0.2967$. No other base fits either window — base $8$ gives $24/73 \approx 0.329$, too high; base $10$ gives $30/111 \approx 0.270$, too low.

The dial does not have a broken base. Its statistic is, and remains, 2-adic. But its *effective* base — the base whose ideal ceiling reproduces what the instrument actually reads — has drifted from $7$ to $9$ over twenty-four bitlens. And the drift accounts for the loss quantitatively: the gap between the two ceilings is
$$\frac{7}{19} - \frac{27}{91} = \frac{124}{1729} \approx 0.0717,$$
while the measured drop in $\rho^2$ is $0.608^2 - 0.544^2 \approx 0.0737$. They agree to within $0.003$. One unit of effective base per twelve bitlens.

That calibration makes a **falsifiable forecast**. Extend the ceiling $3t/(t^2+t+1)$ from integer to real bases: the resulting function is continuous and strictly decreasing for $t \ge 1$, so there is exactly one real base $t^\star$ at which the ceiling equals the squared band floor $0.55^2 = 121/400$. Solving (via the intermediate value theorem on $[8.80, 8.81]$ and uniqueness from monotonicity) brackets it: $8.80 < t^\star < 8.81$. Push $t^\star$ through the linear calibration $t \mapsto 76 + 12(t-7)$ and the model predicts the first band miss at bitlen
$$97.6 \;<\; 76 + 12(t^\star - 7) \;<\; 97.8.$$
The rungs of the experiment are spaced four bitlens apart. A crossing at $97.7$ means: last clean rung at $96$, first miss at $100$. That is exactly what was recorded. And note the crossing base is strictly between $8$ and $9$: no *integer* effective base ever sits on the floor, so the fade crosses the boundary at a point that arithmetic itself does not mark.

---

## What a straddle can and cannot decide

One last piece of the picture is not about number theory at all but about the logic of measurement — and it turns out to be equally sharp.

Say an interval of half-width $w$ centred at $c$ **straddles** a threshold $B$ if $c - w < B < c + w$, and **resolves** it if it lies entirely on one side. Suppose a sequence of readings erodes by at least $d$ per rung. Then a simple descent estimate shows any two rungs whose intervals both straddle the *same* threshold are fewer than $2w/d$ rungs apart. Ambiguity is not a permanent condition; it is a bounded window.

With the recorded half-width $w = 0.046$ and four-bit step $d = 0.030$, that window is at most **three rungs — twelve bitlens**. Outside it the answer is definite. Moreover, once the top of an interval is within $k\cdot d$ of the threshold, the whole interval is below it $k$ rungs later; from the bitlen-100 data alone this guarantees a complete exit by bitlen 108. The recorded bitlen-104 interval was already entirely below the floor — the exit came a rung *early*, which is the precise quantitative content of the observation that the fade accelerates.

And here is the sharpest way to say what "the dial begins to fade" means. At bitlen 100 the advantage of the trailing-zero statistic over the naive count baseline is $+0.098$, which exceeds the full interval width $2w = 0.092$. The four-bit erosion step is $0.030$, which does not. So the experiment can still resolve **which statistic is better**; it can no longer resolve **how fast the signal is decaying**. The signal is still there. The instrument has simply run out of resolution to watch it go.

---

## The shape of the conclusion

A number, $6/7$, arising from a geometric series with ratio $1/8$, turns out to be immovable. It survives every sample size, every offset window, every residue class, every approximately geometric stream. It fluctuates — self-similarly, with sharp amplitude $3/7$, in the odd part of $n$, in a way that would delight anyone who has met the Takagi function — but at the scale of a hundred-bit measurement the fluctuation is $10^{-29}$ and the effect under investigation is $0.03$.

The value of that immovability is entirely negative, and entirely decisive. It rules out an explanation. When your instrument starts to fade, the first thing to establish is that the ruler has not moved. Here the ruler is a fraction, and fractions do not move.

Which leaves exactly one place for the erosion to live: the response channel. That is where the search continues.
