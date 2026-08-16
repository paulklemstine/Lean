# The Shape of Randomness: Why Random Matrices Draw a Semicircle

## A physicist's desperate guess

In the early 1950s, Eugene Wigner faced a problem that looked hopeless. Physicists were bombarding heavy nuclei — uranium, thorium — with slow neutrons, and the nuclei were responding with a forest of sharp resonances: hundreds of energy levels, packed close together, apparently without pattern. In quantum mechanics, those energy levels are the eigenvalues of a Hermitian operator, the Hamiltonian. For a uranium nucleus with 238 interacting nucleons, nobody knew the Hamiltonian, and nobody was going to.

Wigner made a move that still feels audacious. If we cannot know the matrix, he said, let us replace it by a *random* one: a large symmetric matrix whose entries are independent coin flips. This is surely wrong in every detail. And yet, he suggested, the *statistics* of its eigenvalues might be right — because when a matrix is large enough, the fine print of the entries may stop mattering.

He was right, and the payoff was a shape. Take an $N \times N$ symmetric matrix $W$ whose off-diagonal entries are independent $\pm 1$ coin flips (with $W_{ji} = W_{ij}$, and zeros on the diagonal). Compute its $N$ eigenvalues, divide them by $\sqrt{N}$, and draw a histogram. For $N = 10$ the picture is ragged. For $N = 100$ it has a suspicious bulge. For $N = 2000$ it is unmistakable: a smooth arc, hugging the interval $[-2,2]$, with density

$$\varrho(x) = \frac{1}{2\pi}\sqrt{4 - x^2}, \qquad -2 \le x \le 2.$$

A semicircle. Not a bell curve — the Gaussian's famous tails are gone, replaced by a hard edge at $\pm 2$. And here is the part that makes it a law of nature rather than a curiosity: replace the coin flips by Gaussians, or by any other independent, centred, unit-variance random entries, and the same arc appears. This is *universality*, and it is the reason random matrices now model everything from nuclear spectra to the zeros of the Riemann zeta function to the loss landscapes of neural networks.

This article is about how one actually proves such a thing, and about a suite of precise results — exact finite-size formulas, uniform bounds, and an exact combinatorial dichotomy — that make the classical argument fully rigorous, quantitative, and, in several places, sharper than the textbook version.

## Turning a spectrum into a walk

The eigenvalues of a large random matrix are not something you can write down. Traces, on the other hand, are easy. The bridge between the two is a single identity from the spectral theorem: for any Hermitian matrix $A$ with eigenvalues $\lambda_1,\dots,\lambda_N$,

$$\operatorname{tr}(A^k) = \sum_{i=1}^N \lambda_i^{\,k}.$$

So if we set $M = W/\sqrt{N}$ and define the $k$-th *spectral moment*

$$m_k(W) \;=\; \frac1N \sum_{i=1}^N \left(\frac{\lambda_i}{\sqrt N}\right)^{k} \;=\; \frac1N \operatorname{tr}\!\big(M^k\big),$$

then knowing all the $m_k$ is morally the same as knowing the histogram. The strategy — the *moment method* — is: compute $\lim_{N\to\infty} \mathbb{E}[m_k(W)]$, check it equals the $k$-th moment of the semicircle, and conclude.

Now expand the trace. Multiplying matrices means summing over intermediate indices, so

$$\operatorname{tr}(W^{m+1}) \;=\; \sum_{i_0,i_1,\dots,i_m} W_{i_0 i_1} W_{i_1 i_2}\cdots W_{i_m i_0}.$$

Each term is a **closed walk** of $m+1$ steps on the vertex set $\{1,\dots,N\}$: start at $i_0$, hop to $i_1$, and so on, returning home. The trace of a power of a random matrix is a sum over closed walks, and each walk contributes the product of the coin flips it steps on. A spectral question has become a counting question about walks on the complete graph. That is the whole trick, and everything else is bookkeeping.

## The dichotomy: which walks survive

Here is where the coin flips do something beautiful. Take any closed walk, and look at the product of entries it collects. Suppose some edge $\{i,j\}$ is traversed an *odd* number of times. Flip that single coin: $W_{ij} \mapsto -W_{ij}$. This is a perfect pairing of the configurations of the ensemble with themselves, and it negates the product. Summing a quantity over a set on which an involution reverses its sign gives zero. So the walk contributes **nothing**.

Suppose instead the walk uses a self-loop, stepping from $i$ back to $i$. Then it collects a diagonal entry, which is zero.

What remains? Walks that are loop-free and traverse every edge an even number of times — call these **even closed walks**. On those, every factor appears an even number of times, and $(\pm1)^{\text{even}} = 1$; the product is identically $1$, whatever the coins say. So the average is exactly $1$.

This is an exact dichotomy, with no approximation anywhere:

> **Walk dichotomy.** For the symmetric sign ensemble, the ensemble average of the product of entries along any family of steps is $1$ if the family is loop-free with all edge multiplicities even, and $0$ otherwise.

The consequence is immediate and, at first sight, startling:

> **Moments count walks.** For every $N$ and every $m$, $\mathbb{E}\big[\operatorname{tr}(W^{m+1})\big]$ equals *exactly* the number of even closed $(m+1)$-walks on $N$ vertices.

An analytic quantity — an average over $2^{N(N-1)/2}$ sign patterns of a spectral functional — has become an integer, computable by enumeration. For instance, on $3$ vertices there are $18$ even closed $4$-walks, so $\mathbb{E}[\operatorname{tr}(W^4)] = 18$ exactly; on $4$ vertices there are $60$; on $2$ vertices there are $2$ even closed $6$-walks, and on $3$ vertices there are $66$.

And the parity statement falls out for free. A walk of odd length has an odd total number of steps, so its edge multiplicities cannot all be even — some edge is used an odd number of times. Hence:

> **All odd moments vanish exactly.** For every dimension $N$ and every odd $k$, $\mathbb{E}\big[\operatorname{tr}(W^{k})\big] = 0$.

Note the word *exactly*. This is not "vanishes in the limit" or "is $O(N^{-1})$". It is zero at $N = 7$, at $N = 10^{9}$, at every finite size. The semicircle is symmetric, and the matrix ensemble knows it from the start.

## Counting the survivors: why the edge is hard

The surviving walks now have to be counted, and their number is what decides the shape of the histogram. The key is a piece of pure graph theory. Take an even closed walk of length $2k$. Every edge it uses is used at least twice, so it uses at most $k$ *distinct* edges. A walk is a connected object: each new vertex must be reached by a new edge. So the number of distinct vertices it visits is at most one more than the number of distinct edges — at most $k+1$. (The extremal case is a tree traversed twice in each direction, which is exactly where the Catalan numbers come from.)

Counting walks that visit at most $k+1$ vertices is then easy: choose the vertices ($N^{k+1}$ ways, generously) and choose which of them occupies each of the $2k$ positions ($(k+1)^{2k}$ ways). Therefore

$$\mathbb{E}\big[\operatorname{tr}(W^{2k})\big] \;\le\; N^{k+1}\,(k+1)^{2k}, \qquad\text{so}\qquad \mathbb{E}\big[m_{2k}(W)\big] \;\le\; (k+1)^{2k}$$

*uniformly in $N$*. The dimension has dropped out. This is exactly the right scaling: the normalisation by $\sqrt N$ was chosen so that $N^{k+1}$ walks, divided by $N \cdot N^{k}$, give something of order one.

There is a matching bound from below, and it comes from an unexpectedly rigid fact. For the sign ensemble, $\operatorname{tr}(W^2) = \sum_{i \ne j} W_{ij}^2 = N(N-1)$ — the same value for *every* realisation, since every squared entry is $1$. The second moment does not fluctuate at all; it is perfectly self-averaging. Feeding this into the power-mean inequality applied to the eigenvalues gives, again for every single realisation,

$$\operatorname{tr}(W^{2k}) \;\ge\; N (N-1)^k .$$

Putting the two together yields a clean sandwich valid at every dimension and every order $k \ge 1$:

$$\Big(1 - \tfrac1N\Big)^{k} \;\le\; \mathbb{E}\big[m_{2k}(W)\big] \;\le\; (k+1)^{2k}.$$

The even spectral moments neither collapse nor explode. And the sandwich has a physical reading: it says the spectrum genuinely spreads out to scale $\sqrt N$ (bottom) but not further than a bounded window (top).

## The edge, the bulk, and where the eigenvalues live

Uniform moment bounds are more than bookkeeping — they control where the eigenvalues actually are.

Apply Markov's inequality *inside* a single matrix, to its own eigenvalue histogram: for any symmetric $A$ and any threshold $t>0$, the fraction of eigenvalues of $A/\sqrt N$ with modulus at least $t$ is at most $m_{2k}(A)/t^{2k}$. Nothing random has happened yet; this holds matrix by matrix. Averaging over the ensemble and inserting the uniform bound gives, for every $k \ge 1$,

$$\mathbb{E}\left[\frac{\#\{i : |\lambda_i|/\sqrt{N} \ge t\}}{N}\right] \;\le\; \frac{(k+1)^{2k}}{t^{2k}},$$

a bound that does not depend on the dimension at all. Optimising over $k$ gives **tightness**: for every $\varepsilon > 0$ there is a window $[-t,t]$ that, in *every* dimension, contains all but an $\varepsilon$-fraction of the spectrum on average. Tightness is precisely the analytic ingredient that lets convergence of moments be upgraded to convergence of the histogram itself; it is the half of the moment method that combinatorics alone cannot supply.

Applied to the extreme eigenvalues instead of the bulk, the same estimate gives a spectral-edge bound: the probability that *some* eigenvalue of $W/\sqrt N$ exceeds $t$ in modulus is at most $N (k+1)^{2k} / t^{2k}$.

From the other side, the self-averaging second moment gives something remarkably strong. Since the average of $(\lambda_i/\sqrt N)^2$ over the spectrum equals $1 - 1/N$ exactly, some eigenvalue must be at least that large:

> **Deterministic edge bound.** *Every* sign matrix $W$ — with no exceptional configurations, no probability caveat — has an eigenvalue with $|\lambda|/\sqrt{N} \ge \sqrt{1 - 1/N}$.

The spectrum always reaches out to distance essentially $1$ from the origin. (The true edge is at $2$; getting there requires the higher moments.)

## Universality: the entries really don't matter

So far the coin flips have been doing specific work — the sign-flip involution is a symmetry of the $\pm1$ ensemble. What happens for a general entry distribution: centred, variance one, arbitrary otherwise?

The involution is replaced by independence. The expected product over a walk factorises over edges, so a walk contributes the product, over the edges it uses, of the entry law's moment of that multiplicity. If some edge is used *exactly once*, its factor is the mean, which is zero — the walk dies. That is the general-law replacement for the sign flip, and it again kills all the odd moments in the limit and leaves only the walks that pair up their edges.

The fourth moment shows the mechanism in miniature. For any centred, unit-variance entry law with fourth moment $m_4$,

$$\mathbb{E}\big[\operatorname{tr}(W^4)\big] \;=\; 2N(N-1)^2 - 2N(N-1) + m_4\, N(N-1).$$

The distribution of the entries appears exactly once, in the $m_4$ term — which counts the degenerate walks that run back and forth along a *single* edge four times. There are only $O(N^2)$ of those, while the dominant term is of order $N^3$. Dividing by $N^3$:

$$\mathbb{E}\big[m_4(W)\big] \;=\; \frac{(N-1)(2N-4+m_4)}{N^2} \;\xrightarrow[N\to\infty]{}\; 2,$$

no matter what $m_4$ was. Universality is not magic; it is the statement that the entry law only reaches the walks that reuse an edge more than twice, and those walks are too few to see. For the sign ensemble $m_4 = 1$ and the formula collapses to the exact $\mathbb{E}[m_4(W)] = (N-1)(2N-3)/N^2$.

## Not just on average

Averages are not distributions. Does the histogram of a *typical* matrix look like the semicircle, or only the histogram averaged over all matrices?

For the second moment the answer is as strong as it can be. Its variance is exactly

$$\operatorname{Var}\big(m_2(W)\big) \;=\; \frac{2(m_4-1)(N-1)}{N^3},$$

which is $O(N^{-2})$ — so Chebyshev's inequality gives, for every threshold $t>0$ and every finite $N$,

$$\mathbb{P}\Big[\big|m_2(W) - (1 - \tfrac1N)\big| \ge t\Big] \;\le\; \frac{2(m_4-1)(N-1)}{N^3 t^2},$$

a rate, not merely a limit. Mean-square convergence follows: $\mathbb{E}\big[(m_2(W) - 1)^2\big] = 2(m_4-1)(N-1)/N^3 + 1/N^2 \to 0$, the second term being the squared bias. And for the sign ensemble, where $m_4 = 1$, the variance is *identically zero*: the second spectral moment is not just concentrated, it is constant.

## Why the semicircle, and why it matters

The limit shape itself is the last piece. The semicircle's odd moments vanish and its even moments are the **Catalan numbers**:

$$\frac{1}{2\pi}\int_{-2}^{2} x^{2k}\sqrt{4-x^2}\,dx \;=\; C_k \;=\; \frac{1}{k+1}\binom{2k}{k} \;=\; 1, 1, 2, 5, 14, 42, \dots$$

The substitution $x = 2\sin t$ turns the integral into a Wallis integral, whose recursion $\int \sin^{m+2} = \frac{m+1}{m+2}\int \sin^m$ matches the Catalan recursion $(k+2)C_{k+1} = 2(2k+1)C_k$ exactly. The Catalan numbers also satisfy the convolution recursion $C_{k+1} = \sum_{i=0}^{k} C_i C_{k-i}$, and that recursion together with $C_0 = 1$ pins the sequence down uniquely — which is why an argument that produces *any* sequence obeying it has produced the semicircle.

Catalan numbers count balanced bracketings, and balanced bracketings are exactly the walks that survive: a walk of length $2k$ that visits $k+1$ vertices must traverse a tree, going out and coming back, out and back — an opening and closing bracket for every edge. The semicircle law is, at bottom, the statement that *the shape of a random spectrum is the shape of the set of ways to balance parentheses*. The hard edge at $\pm 2$ is the growth rate $4^k$ of the Catalan numbers; the absence of Gaussian tails is the absence of walks that stray.

Why should anyone outside random matrix theory care? Because the same arc keeps appearing where no one put it. The spacings between nuclear resonance levels follow random-matrix statistics; so, to an accuracy that remains unexplained, do the spacings between zeros of the Riemann zeta function. The eigenvalues of the correlation matrix of a stock portfolio follow a close cousin of the semicircle — the Marchenko–Pastur law — and the eigenvalues that stick out of it are the real market factors, the rest being noise. The Hessians and weight matrices of deep neural networks show semicircular bulks, and the position of the spectral edge governs how fast gradient descent can safely step. In every case the useful content is the same: universality means you can predict the *noise floor* without knowing the mechanism that generated it, and anything poking out of the semicircle is signal.

Wigner's guess was that a matrix he could not know would behave like a matrix he chose at random. What the walk expansion shows is why that is not really a guess at all. Once you have divided by $\sqrt N$, the spectrum of a large symmetric random matrix has forgotten everything about its entries except their variance — and what it remembers is a semicircle.
