# The Mirror in the Data: How a Promising Signal Turned Out to Be Just the Size of a Number

## A channel that wasn't there

Every so often a search for structure finds something that looks like a discovery, and the only honest thing left to do is to take it apart. This is the story of one such moment — and of what was left standing afterwards, which turned out to be more interesting than the thing that fell.

The setting is one of the oldest games in arithmetic: given a large integer $N$, find a nontrivial factor. Pierre de Fermat's method is the classical starting point. If $N = u \cdot v$ with $u \le v$, then writing $a = (u+v)/2$ and $b = (v-u)/2$ gives
$$N = a^2 - b^2, \qquad \text{i.e.} \qquad a^2 - N = b^2 .$$
So define the **energy**
$$E(a) = a^2 - N .$$
Fermat's algorithm starts at $a = m := \lfloor \sqrt N \rfloor$, the *anchor*, and walks upward through $a_j = m + j$ for $j = 0, 1, 2, \dots$, testing at each step whether the energy $E(a_j)$ is a perfect square. When it is — a **hit** — the factorization drops out immediately: $N = (a-b)(a+b)$.

Recent work in this line proposed something more ambitious than the hit itself. It suggested that the *shape* of the energy along the window — its sign pattern, its bracketing behaviour, cheap "sensors" that count crossings — carried usable information about where the factors of $N$ actually lie. If true, that would be remarkable: it would mean the walk leaks information about the answer long before it arrives at the answer.

It is not true. And the reason it is not true is embarrassingly clean.

## The energy has nowhere to hide

Look at the anchor. By the definition of the integer square root, $m^2 \le N$, so
$$E(a_0) = m^2 - N \le 0 .$$
Now look one step up. Again by definition of the integer square root, $N < (m+1)^2$, so $E(a_1) = (m+1)^2 - N > 0$, and since $E$ is strictly increasing along the window, $E(a_j) > 0$ for *every* $j \ge 1$.

That is the whole argument, and it kills the mechanism. The energy crosses zero **exactly once**, and it crosses between $j = 0$ and $j = 1$ — at $\sqrt N$, where it must, by the definition of $\sqrt N$. There is no sign change at $j = d$ for a divisor $d$; there is no sign change anywhere except at the very first step. The proposed mechanism located an event "at the divisor offset" that provably does not exist.

Worse (for the mechanism) and better (for clarity), this has an information-theoretic consequence that is not approximate. For a non-square modulus $N$, the sign vector of the anchored window of any length $L$ is
$$\bigl(\operatorname{sgn} E(a_0), \operatorname{sgn} E(a_1), \dots, \operatorname{sgn} E(a_{L-1})\bigr) = (-1, +1, +1, \dots, +1),$$
*the same vector for every $N$*. Likewise the count of negative-energy window positions is $1$, always. A statistic that takes the same value on every instance in your data set cannot distinguish between instances; its mutual information with any secret — the smallest prime factor, a bit of a factor, anything — is exactly zero. Not "small". Not "not significant at $p<0.05$". Exactly $0$.

That is the formal content of a measured mutual information of $0.000000$ bits across twenty independent blocks of instances. The measurement was not noisy; it was an identity being reported back to us in decimal.

The real event on the window is the *hit*, and only the hit. Here the theorem is a clean equivalence: if $b \le a$ and $E(a) = b^2$, then $(a-b)(a+b) = N$, and conversely every factorization $N = u(u+2k)$ produces the hit $E(u+k) = k^2$. The special case $b = 0$ — a hit right at the anchor — happens precisely when $N$ is a perfect square. Signs tell you nothing; squares tell you everything.

## The mirror

The second, subtler failure is more instructive, because it is a mistake that any data-driven search for structure can make, in any field.

A second family of probes computed "spectral summaries" of the window: smooth, aggregate, real-valued features of the energy profile. These *did* show a signal. Against a secret bit of a factor, the measured mutual information was $0.1836$ bits, comfortably above the noise floor of the standard null model, which reshuffles the rows of the data table and recomputes.

Then someone computed the mutual information of the crudest imaginable feature: $\log N$. The number came back $0.1836$ bits. Identically. And inside fine cells of the instance parameters, both gave $0.0629$. And when the analysis conditioned on deciles of $\log N$ — comparing only instances of comparable size — the spectral feature's information collapsed to $0.0000$ bits, with standard deviation zero across replicates.

Zero with standard deviation zero is not a statistical result. It is a structural one, and here is the structure.

Call a feature $\Phi$ a **magnitude mirror** on a set of instances if there is a function $g$ with $\Phi(w) = g(M(w))$ for every instance $w$, where $M$ is the magnitude — the size of $N$, or any bucketing of it. A mirror is a deterministic function of how big $N$ is, and nothing more. Three facts about mirrors settle the case:

1. **Relabelling is free.** If two features differ by an injective recoding — in particular, if one is a strictly increasing function of the other — they have *exactly* the same fibre counts and therefore exactly the same mutual information with everything. This is why $\log N$ and the spectral summary reported the identical $0.1836$: they are the same channel wearing different clothes.

2. **Inside a magnitude cell, a mirror is a constant.** By definition. And a constant carries exactly zero information, about any secret whatsoever. That is the measured $0.0000$, again as an identity rather than an estimate.

3. **The collapse is a characterization, not just a symptom.** A feature has exactly zero information about *every* secret inside *every* magnitude cell **if and only if** it is a magnitude mirror. So an exact conditional null is not a failure to reject a hypothesis: it is a proof of determinism.

The class of mirrors is also robustly closed. Constants are mirrors; any post-processing of a mirror is a mirror; two mirrors read jointly are a mirror; any finite battery of mirrors, tupled together and fed into an arbitrary function — a hash, a neural net, a hand-designed score — is still a mirror; and a mirror of a coarse magnitude is a mirror of any finer one. So there is no rescue by combination. The whole realized probe battery, read jointly and post-processed however you like, is a single mirror, and inside every magnitude cell its information about every secret is exactly zero.

## Why the null model lied

If the signal is fake, why did the standard null model wave it through with a $z$-score far above $3$?

Because the null model tested the wrong hypothesis, and there is a theorem that says exactly which one.

A row shuffle destroys the pairing between feature and secret while preserving both marginals. It asks: *is the feature associated with the secret?* But a mirror can be associated with the secret for a completely uninteresting reason — because the secret's own distribution drifts with the size of $N$. Big numbers have big factors; the marginal distribution of "the smallest prime factor exceeds $B$" is not the same at $10^{20}$ as at $10^{40}$. A feature that tracks size will track anything else that tracks size.

The theorem that makes this precise runs in both directions. First, if a mirror shows *any* unconditional dependence on the secret, then the secret's own distribution provably differs between magnitude cells. Rejecting a shuffle null therefore *certifies scale stratification* — it can never certify transfer. Second, conversely, if the secret's distribution is homogeneous across magnitude cells, a mirror is unconditionally uninformative too.

And the phenomenon is not hypothetical: one can write down a three-line example — two instances, a magnitude, a strictly monotone feature of it, and a secret — where the feature has strictly positive unconditional information and exactly zero information inside every magnitude cell. Marginal signal from a deterministic function of $N$ is stratification, not transfer.

The methodological lesson generalizes far beyond factoring, and deserves to be stated plainly: **row-shuffle permutation nulls are the wrong null for deterministic functions of a covariate.** Any sufficiently fine monotone function of $N$ inherits scale stratification and will flag as significant. The correct controls condition on magnitude, or test whether the feature adds anything to simply knowing $N$.

## What survived

The demolition was thorough, and it re-sealed the structure against every probe class that anyone has actually implemented: residue-based probes, magnitude-of-Gauss-sum probes (which turn out to be residue dials in disguise), bracket sensors (structurally constant, as above), and spectral summaries (magnitude mirrors, exact null given the size of $N$).

But one channel is genuinely different, and it is worth being precise about why.

Consider the **positional oracle**: the single bit $\mathbb{1}\{d \le B\}$, where $d$ is the smallest nontrivial factor of $N$ and $B$ is a threshold you choose. This bit is *not* a magnitude mirror — two instances of exactly the same size can have wildly different smallest factors, and one can exhibit a magnitude cell on which the oracle bit has strictly positive information. The collapse argument simply does not reach it.

Its behaviour as $B$ varies is fully determined by a clean geometry. Let $p(B)$ be the fraction of instances with $d \le B$. Then $p$ is monotone increasing in $B$, and the capacity of the bit is the binary entropy $H(p(B))$, which

* never exceeds $1$ bit (equivalently, one Boolean read can at best halve your candidate set — and reading $L$ bits still leaves a class of at least $|\Omega|/2^L$ mutually indistinguishable instances);
* increases with $B$ as long as $p(B) \le 1/2$, and decreases once $p(B) \ge 1/2$;
* attains its maximum exactly when $B$ splits the instance set into two equal halves;
* has interval superlevel sets — so "the smallest $B$ reaching 90% of the peak" is a genuine, well-defined threshold, not an artifact of whichever grid the search happened to use.

Empirically, on the tested family, the profile peaks at $0.4798$ bits near $B \approx 22758$, with the 90%-of-peak threshold at $B^* = 10420$ and a median smallest factor of $215782$. That is real geometry — and, so far, geometry that no realized probe has managed to touch.

## The cost of the only real channel

There is a second survivor: the cost law of the Fermat ascent itself, which the sign-change story had been mistaking for a channel.

Write $N = u(u+2k)$, so $k$ measures the *imbalance* of the factorization: $k = (v-u)/2$ is half the gap between the two factors. The hit sits at $a = u+k$, and its offset from the anchor is $j = (u+k) - \lfloor\sqrt N\rfloor$. Two inequalities pin it down from both sides:
$$2m\,j \le k^2 + 2m \qquad\text{and}\qquad k^2 \le 2(u+k)\,j ,$$
where $m = \lfloor\sqrt N\rfloor$. The first gives the practical cost bound $j \le k^2/(2m) + 1$; the second gives a matching lower bound. Together they say
$$j = \Theta\!\left(\frac{k^2}{\sqrt N}\right).$$
The frontier distance is a pure function of the imbalance — no residues, no spectra, no window length. Balanced semiprimes are found instantly; unbalanced ones are not found at all. And the imbalance $k$ is exactly the quantity the positional oracle reads, and exactly the quantity no realized probe reads.

## Where the geometry lives: a Pythagorean tree

Finally, a pleasing structural coincidence closes the circle.

Restrict the square-hit window to *square* moduli. A factorization $s^2 = u(u+2k)$ says precisely that
$$k^2 + s^2 = (u+k)^2,$$
which is to say: **$(k,\; s,\; u+k)$ is a Pythagorean triple**, with the two constructions inverse to each other. The Fermat window over square moduli literally enumerates Pythagorean triples.

More: for $N = s^2$ the anchor *is* $s$, the Fermat centre is the hypotenuse $c = u+k$, and the frontier offset obeys the exact identity
$$(c - s)(c + s) = k^2 .$$
The ascent distance is the square of a leg divided by $c + s$. And every such hit sits above a strictly smaller one in the classical Barning–Hall descent on primitive triples: the parent hypotenuse $-2k - 2s + 3c$ is strictly less than $c$. The hits are the nodes of the Pythagorean tree, and the Fermat frontier ascent is a walk in that tree.

The concrete case: $144 = 12^2 = 8 \cdot 18 = 8 \cdot (8 + 2\cdot 5)$, giving the triple $(5, 12, 13)$, frontier offset $13 - 12 = 1$, and the identity $1 \cdot 25 = 5^2$. The oldest triple in mathematics, sitting inside a modern factoring window.

## The lesson

Three things happened here, and all three are worth carrying away.

A mechanism was refuted not by a better experiment but by a definition: $\lfloor\sqrt N\rfloor$ is *defined* to be where the energy crosses zero, so of course the crossing is there and nowhere else. When your measured mutual information is $0.000000$, ask whether you have measured a constant.

A signal was refuted by a comparison: the cheapest possible feature, $\log N$, matched the sophisticated one to four decimals. When a feature is a monotone function of a covariate, it is that covariate, and testing it against a shuffle null tells you about the covariate's stratification, not about your feature.

And what survived survived for a reason you can state: the positional oracle is provably outside the sealed class, its capacity profile is unimodal with an exactly characterized peak, and the ascent cost is $\Theta(k^2/\sqrt N)$ in the imbalance. The tree stands sealed against everything anyone has built — and the one crack that is genuinely there has been measured, bounded, and named.

Retractions are not failures of a research programme. They are the programme working.
