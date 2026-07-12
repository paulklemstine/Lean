# The Metabolic Law of Large Numbers: Why Brains Spend Almost Exactly Half Their Spikes

Every thought you have costs energy. When a population of neurons represents a smell, a face, or a decision, some of its cells fire and others stay silent, and each firing cell burns metabolic fuel. The brain is one of the most energy-hungry organs in the body, so a natural question hangs over all of neuroscience: *how much does a single pattern of activity cost, and how predictable is that cost?*

This article tells the story of a small but sharp mathematical result about that question. Picture a group of $N$ neurons, each of which can be either active or silent at a given instant. A snapshot of who is firing and who is quiet is a **code** — a string of $N$ ones and zeros. The number of active neurons in a code is its **weight**, and because each spike costs energy, the weight is literally the metabolic price tag of that pattern. The punchline we will arrive at is this: if you regard all possible patterns as equally likely, then almost every pattern costs almost exactly the same amount — half the neurons active — with astonishingly little variation. Dense neural activity obeys its own *law of large numbers*.

## Counting the patterns

Start with the simplest fact, the one every information theorist knows. If each of $N$ neurons is independently either on or off, the number of distinct patterns is
$$2^N.$$
This is the **capacity** of the population: with just $N$ cells you can distinguish an exponential number of situations. Ten neurons already give you more than a thousand patterns; thirty give you more than a billion. Each neuron you add *doubles* the repertoire — the per-neuron doubling law that makes neural codes so expressive.

But capacity alone says nothing about cost. A pattern with all $N$ neurons blazing costs $N$ spikes; a pattern with a single neuron costs one. How is the metabolic budget distributed across the $2^N$ patterns?

There is a tidy bookkeeping fact hiding here. The number of patterns that use *exactly* $k$ active neurons is the binomial coefficient
$$\binom{N}{k} = \frac{N!}{k!\,(N-k)!},$$
since choosing which $k$ of the $N$ neurons fire is exactly the same as choosing a $k$-element subset. These counts are the *sparse code counts*: there is only one all-silent pattern and only one all-blazing pattern, a handful of very sparse patterns, and an enormous pile of middling ones. Adding up $\binom{N}{k}$ over all $k$ recovers the capacity $2^N$, and the way these counts swell toward the middle and collapse at the edges is precisely what will make the metabolic cost so predictable. The shape of this pile — sharply peaked at $k = N/2$ — is the object we now dissect.

## The average cost

The first piece of the answer is an elegant symmetry. Fix one particular neuron and ask: in how many of the $2^N$ codes is *that* neuron active? Freezing it "on" and letting the other $N-1$ neurons range freely gives exactly
$$2^{N-1}$$
patterns — precisely half of them. Summing this over all $N$ neurons counts every active spike in every code exactly once, so the total number of spikes across the entire repertoire is $N \cdot 2^{N-1}$. Dividing by the $2^N$ patterns gives the **average weight**:
$$\text{average cost} = \frac{N}{2}.$$
On average, a pattern lights up half the population. That is intuitive: each neuron is on in half the codes, so on average half of them are on at once. But an average can hide a multitude of sins. Maybe patterns cluster at the extremes — many very cheap codes and many very expensive ones — averaging out to $N/2$ without any individual code actually costing $N/2$. To rule this out we need to measure the *spread*.

## The second moment, and a hidden pair symmetry

To measure spread you need the *second moment*: the average of the squared weight. This is where the arithmetic gets interesting, because the square of the weight opens up into a sum over *pairs* of neurons. Writing the weight as a sum of indicator variables — a $1$ for each active neuron, a $0$ for each silent one — its square becomes a double sum over all ordered pairs $(i,j)$ of neurons, each term recording whether both neuron $i$ and neuron $j$ are firing.

So we need to count, for a fixed pair of *distinct* neurons $i \neq j$, how many codes have both of them active. Freeze both "on" and let the remaining $N-2$ neurons range freely: there are exactly
$$2^{N-2}$$
such codes. This is the **second-order symmetry**, the natural sequel to the first-order fact that a single neuron is active in $2^{N-1}$ codes.

Assembling the double sum from these two symmetries — the diagonal terms $(i,i)$ each contributing $2^{N-1}$ and the $N(N-1)$ off-diagonal pairs each contributing $2^{N-2}$ — yields a strikingly compact closed form. Summed over all $2^N$ codes,
$$\sum_{\text{codes}} (\text{weight})^2 \;=\; 2^N \cdot \frac{N(N+1)}{4}.$$
Remarkably, this formula is exact for *every* $N$, including the degenerate cases $N = 0$ and $N = 1$ where there are no pairs at all — the $N(N-1)$ prefactor politely vanishes exactly when it must.

## The variance: the fingerprint of independence

With the first two moments in hand, the spread falls out. The total squared deviation of the weight from its mean $N/2$, summed over all codes, works out to
$$\sum_{\text{codes}} \left(\text{weight} - \tfrac{N}{2}\right)^2 \;=\; \frac{N \cdot 2^N}{4}.$$
Dividing by the $2^N$ codes gives the **variance**:
$$\text{variance} = \frac{N}{4}.$$
Anyone who has met the binomial distribution will recognize this instantly. A sum of $N$ independent fair coin flips — a Binomial$(N, \tfrac12)$ random variable — has variance $Np(1-p) = N \cdot \tfrac12 \cdot \tfrac12 = N/4$. The weight of a random neural code *is* a binomial variable in disguise, and the value $N/4$ is the algebraic fingerprint of the independence of the $N$ neurons. The standard deviation is therefore $\sqrt{N}/2$: the typical wobble of the metabolic cost grows like $\sqrt N$, not like $N$.

## Concentration: almost all codes are typical

Here is where the story turns from arithmetic into a genuine law of nature. A variance of $N/4$ means that, relative to the mean $N/2$, the fluctuations are tiny: the *relative* spread is $\frac{\sqrt N / 2}{N/2} = \frac{1}{\sqrt N}$, which shrinks to zero as the population grows. This is the mathematical heart of concentration.

Making it quantitative requires only Chebyshev's inequality, the workhorse that converts a variance into a tail bound. It says the fraction of codes whose weight strays from $N/2$ by at least a threshold $t$ can be no larger than the variance divided by $t^2$:
$$\frac{\#\{\text{codes with } |\text{weight} - N/2| \ge t\}}{2^N} \;\le\; \frac{N}{4\,t^2}.$$
Choose the threshold to be one standard-deviation-scale window, $t = \sqrt N$. Then the bound becomes $\frac{N}{4N} = \frac14$: at most a quarter of all codes stray by more than $\sqrt N$ from the mean. Turning it around gives the headline result:

> **At least three quarters of all $2^N$ neural codes have weight within $\sqrt N$ of $N/2$.**

Think about what this means. As $N$ grows, the window $\sqrt N$ becomes vanishingly small compared to the range $[0, N]$ of possible costs — it is a razor-thin equatorial band around the "half-active" state. Yet the overwhelming majority of all conceivable patterns crowd into that band. The extremes — the nearly-silent and the nearly-saturated patterns — are astronomically rare. A random pattern is not just *on average* half-active; it is *almost certainly* half-active, to within a $\sqrt N$ sliver.

## Why this matters

This is a **metabolic law of large numbers** for neural populations. Dense coding does not merely spend $N/2$ spikes on average; it spends essentially that amount every single time, with a relative fluctuation that vanishes like $1/\sqrt N$. For a brain trying to budget energy, that predictability is a feature: the metabolic demand of a dense representation is sharply forecastable, not a wild lottery.

It also frames a fundamental trade-off in the design of neural codes. If the vast majority of patterns are locked into a thin equatorial shell near half-activity, then any coding scheme that wants to be *sparse* (few active neurons, saving energy) or wants to spread its codewords far apart (for noise tolerance) must fight against the overwhelming statistical gravity of that shell. The concentration result quantifies the tension between spending little energy, tolerating noise, and using the full expressive capacity of the population.

Finally, the same $\sqrt N$ scale that appears here is the scale that governs how precisely a population of neurons can estimate a stimulus — the celebrated $1/\sqrt N$ precision law of population coding. That is no coincidence. Both are shadows of the same underlying fact: independent contributions from $N$ units fluctuate on the scale of $\sqrt N$, and so their averages sharpen at the rate $1/\sqrt N$. The metabolic concentration of neural codes and the statistical precision of neural estimates are two faces of a single, elegant principle.

From a bare count of $2^N$ patterns to a razor-sharp concentration of energy, the mathematics of neural coding reveals a population that is, in a precise sense, remarkably well-behaved: expensive to a completely predictable degree, and typical almost all of the time.
