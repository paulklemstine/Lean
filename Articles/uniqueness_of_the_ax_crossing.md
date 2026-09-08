# The Fork in the Road: When Naming Beats Trading

## Two ways to read a branch

Imagine standing at a fork in a road that splits into $n$ branches. Something has to happen here — a signal has to get through, a decision has to be made, a packet of information has to move from one side of the junction to the other. There are two natural ways to build the read-out.

The first is the **address channel**. You give every branch a name. With $n$ branches you need $\log_2 n$ bits to write down a name — that is what an address costs, and there is no cheaper way to do it. But one of those bits is spent on the fork decision itself: the junction consumes it, and you never see it again. On top of that, the channel pays a small penalty for the imperfection of the junction, an *entropy deficit* $\delta(n)$, subtracted straight off the top. The net throughput is

$$A(n) \;=\; \log_2 n \;-\; 1 \;-\; \delta(n).$$

The second is the **exchange channel**. It does not name anything. It always ships the same two-bit packet — a fixed, dumb, reliable payload — but the junction's imperfection degrades the *rate* rather than subtracting from the payload. The degradation is multiplicative:

$$X(n) \;=\; 2\bigl(1 - \delta(n)\bigr).$$

So the two architectures are hit by *the very same* physical defect, but in two different grammars: one additive, one multiplicative. That single difference is the whole story.

## Where the deficit comes from

The entropy deficit is not a fudge factor. It is

$$\delta(n) = \frac{1}{n^{2}},$$

and for an integer number of branches it has an exact combinatorial meaning: it is the **collision probability of the fork**. Consider the set of *ordered pairs of branches*, $[n] \times [n]$, which has $n^{2}$ elements. Probe it twice, independently and uniformly. What is the chance that both probes land on the same pair? The diagonal of $([n]\times[n]) \times ([n]\times[n])$ has exactly $n^{2}$ elements out of $(n^{2})^{2}$, so the collision probability is

$$\frac{n^{2}}{(n^{2})^{2}} = \frac{1}{n^{2}} = \delta(n).$$

That is the whole justification for the model's one free-looking ingredient. The deficit is what the fork does to itself when you look at it twice.

## The horse race

Now line the two channels up. For small forks the exchange channel wins easily: a two-bit packet is worth more than $\log_2 n - 1$ bits when $n$ is small. At $n = 4$ the address channel delivers $A(4) = 0.9375$ against the exchange channel's $X(4) = 1.875$ — a rout. But $\log_2 n$ grows without bound while $X(n)$ is stuck below $2$ forever, creeping up toward it and never arriving. Sooner or later, naming must beat trading.

The turn happens, as it always does with logarithms, embarrassingly late. Here are the two channels at the critical arities:

| $n$ | $A(n)$ | $X(n)$ | $A(n) - X(n)$ |
|---|---|---|---|
| $6$ | $1.5572$ | $1.9444$ | $-0.3873$ |
| $7$ | $1.7869$ | $1.9592$ | $-0.1722$ |
| $8$ | $1.9844$ | $1.9688$ | $+0.0156$ |
| $16$ | $2.9961$ | $1.9922$ | $+1.0039$ |

Between $7$ and $8$ the sign flips. The obvious question — and the one this article is about — is whether that flip is *the* flip. A numerical table can show you a crossing; it cannot tell you there is no second one hiding at $n = 10^{40}$, or squeezed into a gap you never sampled. Deciding *how many times* two curves cross is a completely different order of problem from deciding *that* they cross.

## The collapse

The key move is to stop looking at two functions and start looking at one. Subtract:

$$A(n) - X(n) \;=\; \bigl(\log_2 n - 1 - \tfrac{1}{n^{2}}\bigr) - \bigl(2 - \tfrac{2}{n^{2}}\bigr) \;=\; \log_2 n + \frac{1}{n^{2}} \;-\; 3.$$

The two occurrences of the deficit did not cancel — they *combined*, with the multiplicative one overshooting the additive one by exactly $+1/n^{2}$. Define the **resonance** of the fork,

$$R(n) \;=\; \log_2 n + \frac{1}{n^{2}},$$

and the entire comparison becomes a single sentence:

> The address channel beats the exchange channel exactly when $R(n) > 3$; they tie exactly when $R(n) = 3$.

Two channels, one scalar, one critical level. Every question about the race is now a question about the level set $R(n) = 3$.

## Why $R$ can only turn once

The resonance is a tug-of-war between a slowly growing logarithm and a fast-decaying tail. Its derivative is

$$R'(n) \;=\; \frac{1}{n \ln 2} \;-\; \frac{2}{n^{3}},$$

and this is positive precisely when $n^{2} > 2\ln 2 \approx 1.386$, i.e. for $n > 1.177\ldots$. So $R$ falls on the far left, bottoms out once at $n = \sqrt{2\ln 2}$, and then rises forever. It is *unimodal*: one valley, no other wiggles. In particular $R$ is strictly increasing on the whole physical range $n \geq 2$, which is exactly the statement that a strictly increasing function meets the level $3$ at most once.

Combine that with two evaluations — $R(7) = 2.8278 < 3$ and $R(8) = 3.0156 > 3$ — and the intermediate value theorem does the rest. There is exactly one arity $r > 2$ at which the channels agree, and $7 < r < 8$. Below it the exchange channel wins; above it the address channel wins; and there is nothing else to find. The conjectured uniqueness is a theorem:

> **Crossing Uniqueness.** $A(n) < X(n)$ for every real $n$ with $2 < n \le 7$; $A(n) > X(n)$ for every real $n \ge 8$; and there is a unique $r > 2$ with $A(r) = X(r)$, lying strictly between $7$ and $8$.

## Two integers decide it

There is something pleasing about how the decisive comparisons reduce. At an *integer* arity $m \ge 2$, exponentiating the inequality $\log_2 m + 1/m^{2} > 3$ by $m^{2}$ and clearing the base-2 logarithm turns it into a statement about whole numbers with no logarithms, no real analysis, and no floating point anywhere:

> **Integer Criterion.** For an integer $m \ge 2$, the address channel beats the exchange channel if and only if $2^{\,3m^{2}-1} < m^{\,m^{2}}$, and loses if and only if $m^{\,m^{2}} < 2^{\,3m^{2}-1}$.

The entire comparison table, at every integer fork size, is one integer inequality per row. And the two rows that matter — the last defeat and the first victory — are these two exact integer facts:

$$7^{49} < 2^{146}, \qquad 2^{191} < 8^{64}.$$

The first is a $42$-digit number beaten by a $44$-digit one; the second is prettier still, because $8^{64} = 2^{192}$, so the winning certificate at $n = 8$ is literally $2^{191} < 2^{192}$ — the address channel takes the lead at eight branches by a single doubling. Everything continuous in the problem — the logarithm, the intermediate value theorem, the derivative — is there only to interpolate between these two integer certificates and rule out surprises in between.

## The ratio, and the long run

Once you know the sign of $A - X$, the natural next object is the ratio $A/X$: how many times better is naming than trading? On $[2,\infty)$ this ratio is strictly increasing. The proof is a derivative computation whose numerator, after clearing denominators, is

$$2\,\bigl[(n^{2} - 1) + 4\ln 2 - 2\ln n\bigr] \;/\; (n^{3}\ln 2),$$

and $n^{2} - 1 \ge 2\ln n$ for all $n > 0$ (a one-line consequence of $\ln n \le n - 1$), so the bracket never comes close to vanishing. Monotonicity of the ratio is the statement that once naming pulls ahead it never gives ground — the advantage is not just eventually positive, it is relentlessly growing. And since $X(n) < 2$ always, while $A(n) \ge \log_2 n - 2$,

$$\frac{A(n)}{X(n)} \;\ge\; \frac{\log_2 n - 2}{2} \;\longrightarrow\; \infty .$$

The address channel does not merely win. It wins by an unbounded margin, one extra unit of ratio for every two doublings of the fork.

## The point where the model looks back

Here is where the story takes an unexpected turn. The physical model asks for $n > 2$: you need at least three branches for a fork to be a fork. But $R(n) = \log_2 n + 1/n^{2}$ makes sense for every $n > 0$, and $R$ *falls* on the left before it rises. A falling curve that later climbs through the level $3$ must have been *above* $3$ once, on the far left, when $1/n^{2}$ was enormous. So the level set $R(n) = 3$ has a second point — and one can ask where.

It is not a numerical mystery. It is exactly

$$n = \tfrac{1}{2}, \qquad \log_2 \tfrac12 + \frac{1}{(1/2)^{2}} = -1 + 4 = 3 .$$

An integer coincidence, in the cleanest possible form: a dyadic logarithm hitting $-1$ while a dyadic deficit hits $4$, and $-1 + 4 = 3$ on the nose. At that point both channels take the same value, and the value is also exact:

$$A(\tfrac12) = X(\tfrac12) = -6 .$$

A negative throughput is not physics; it is the model's analytic continuation to a "fork" with half a branch. But it is an exact solution of a transcendental equation, and exact solutions of transcendental equations are rare enough to be worth noticing. The picture is now complete:

> **Complete Crossing Spectrum.** On the whole positive axis, $A(n) = X(n)$ for exactly two values of $n$: the exactly solvable dyadic point $n = 1/2$, where both channels equal $-6$; and one transcendental point $r$ with $7 < r < 8$.

Two crossings, not one and not three, and the count is forced by unimodality: a function with a single valley meets a horizontal line above the valley floor exactly twice. The separating stretch $[1,2]$ is safely crossing-free because $\log_2 n \le 1$ and $1/n^{2} \le 1$ there, so $R \le 2 < 3$ throughout.

## Pinning down the transcendental one

The dyadic crossing is exact; the other is not, and never will be — it is a genuinely transcendental point. But it can be trapped, and again the trapping is done by pure integer arithmetic. Because $253/32 = 7.90625$ and $507/64 = 7.921875$ are dyadic rationals, evaluating $R$ at them reduces to comparing a power of an integer with a power of $2$. The two certificates are

$$253^{64009} < 2^{511048}, \qquad 2^{2309345} < 507^{257049},$$

each a comparison of numbers with roughly $150{,}000$ and $700{,}000$ digits respectively. They give $R(253/32) < 3 < R(507/64)$, and monotonicity converts that into

$$7.90625 \;<\; r \;<\; 7.921875 .$$

(The true value is $r = 7.9119050\ldots$) The method is fully general: any dyadic bracket, to any precision, is certified by one integer power comparison per endpoint. No floating point is involved at any stage — only exact integers, however large.

## What the fork teaches

Strip away the story and the mathematics says something clean about *degradation grammar*. Take a single physical imperfection — here, a collision probability. Subtract it from one channel's payload; multiply it into another channel's rate. Ask which channel is better. The answer is not a comparison of two curves; it is a level-set problem for a single functional built from the imperfection and the logarithm, and the *shape* of that functional — how many valleys it has — dictates the answer's combinatorics. One valley means at most two crossings, always, no matter what the numbers turn out to be.

That is why the uniqueness question was harder than the existence question, and why solving it needed a structural fact (unimodality) rather than a sharper computation. It is also why the answer is robust: nothing in the collapse $A - X = R - 3$ used the exponent $2$ in $1/n^{2}$. Replace it by $1/n^{s}$ and you get a family $R_s(n) = \log_2 n + n^{-s}$, still unimodal, still with a critical level, still with a crossing count governed by whether the level clears the valley floor. The fork channel is one member of a family, and the family is where the next questions live.

The last word belongs to the two little integers. Everything above — the derivative bounds, the intermediate value theorem, the unimodality argument — exists to certify a statement that, at the two arities where it matters, is nothing more than

$$7^{49} < 2^{146} < 2^{191} < 8^{64}.$$

Naming loses at seven branches. Naming wins at eight. And it never loses again.
