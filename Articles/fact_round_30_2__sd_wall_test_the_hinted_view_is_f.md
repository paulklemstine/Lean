# The Measurement That Was Measuring Itself

## How a "0.97-bit leak" turned out to be a shadow cast by the ruler

### A number that looked like a secret

Imagine you are handed a large number $N$ that you know is the product of two primes, $N = p\,q$, and someone offers you a side channel: not the factors themselves, but a *view* — a short summary code computed from the pair, say the remainder of $N$ modulo a small modulus, or a pair of statistics like the sum $s = p+q$ and the difference $d = |p-q|$ reduced somehow. The question that matters for cryptography, and for a long tradition of "does this transform leak?" experiments, is simple: **does the view tell you which factor is which?**

There is a clean way to ask this quantitatively. Attach to each sample a binary label $\ell$ — a which-factor bit, say "the smaller prime came first" — and ask how many bits of $\ell$ you can predict from the view code $c$. The standard instrument is the empirical mutual information, the *plug-in reading*
$$\hat{I}(\ell, c) \;=\; \sum_{a,k} \hat p(a,k)\,\log_2\frac{\hat p(a,k)}{\hat p_\ell(a)\,\hat p_c(k)},$$
where $\hat p(a,k)$ is simply the fraction of your $n$ samples that have label $a$ and view code $k$. Zero means "the view is blind to the label"; positive means "the view sees something".

In one such experiment a battery of views was scanned across thousands of prime pairs. Most views read essentially zero. One did not. A view built out of the factor residues — call it the $(s,d)$ **hint view** — came back reading $0.9663$ bits. Against a label entropy of about one bit, that is *everything*. The view appeared to have read the which-factor bit off the page.

It had not. This article is about why, and about the theorems that make the "why" inevitable rather than anecdotal.

### The permutation test, and its unpleasant surprise

The standard defence against a spurious reading is a **permutation null**. Keep the view codes exactly where they are, shuffle the labels at random, recompute the reading, and do it a couple of hundred times. If the real reading sits far above this cloud of surrogates, the dependence is real. If it sits inside the cloud, it is an artefact of the estimator.

Here is what the shuffles said:

| view | observed | null mean | null sd | $z$ |
|---|---|---|---|---|
| product view ($N \bmod 713$) | $0.0153$ | $0.0162$ | $0.0008$ | $-1.04$ |
| **$(s,d)$ hint view** | **$0.9663$** | $0.9648$ | $0.0011$ | $+1.36$ |
| joint labels | $0.0011$ | $0.0008$ | $0.0002$ | $+1.44$ |

Every reading is inside its own null. The hint view's $0.9663$ bits are matched, to within a thousandth of a bit, by a null in which the labels have been *destroyed by shuffling*. Whatever those $0.97$ bits measure, it survives the annihilation of all label information. It is not information about the factors. It is information about the **shape of the view**.

### Where the phantom bits come from

The mechanism is easy to see once you decompose the reading the right way. Group the samples into *fibers*: the fiber over a code $k$ is the set of samples whose view happens to equal $k$. Write $f_k$ for the size of that fiber. Then the gap between the label entropy and the reading factorises perfectly:
$$H(\ell) - \hat I(\ell,c) \;=\; \sum_k \frac{f_k}{n}\, H\!\left(\ell \,\middle|\, \text{fiber } k\right),$$
where the inner quantity is the entropy of the labels *inside* that fiber.

Read that identity slowly, because it contains the whole story. A fiber of size one contributes **exactly zero**: one sample has one label, and one label has no entropy. So if the view is injective — every sample gets its own code — the sum is empty and
$$\hat I(\ell, c) \;=\; H(\ell)$$
*exactly*, regardless of whether the view has the faintest relationship to the label. A fine enough view always reads the full label entropy. It is not seeing; it is memorising.

This is the classic sparse plug-in bias, but here it is a *theorem with a name and a constant*, not an asymptotic. Call a sample **colliding** if it shares its code with at least one other sample, and let $C$ be the number of colliding samples. Because only colliding fibers contribute to the gap, and each contributes at most $\log_2|L|$ bits weighted by its share of the sample,

> **The Collision Sandwich.** For any labelled sample of size $n$, any label alphabet $L$ and any view $c$,
> $$H(\ell) - \frac{C}{n}\log_2|L| \;\le\; \hat I(\ell, c) \;\le\; H(\ell).$$

The reading is trapped in a band around the label entropy, and the width of that band is the **collision fraction** $C/n$ — a property of the view's granularity alone, with no reference whatsoever to dependence.

### The null cannot escape the band either

Now the punchline for the permutation test. Shuffling the labels permutes the labels, which changes nothing about the fibers and nothing about the label counts. So the shuffled sample has the same label entropy $H(\ell)$ and the same collision count $C$ — and therefore it is trapped in *exactly the same band*. Hence:

> **The Null Has No Range.** Every label-permuted surrogate reading lies within $\frac{C}{n}\log_2|L|$ of the observed reading, and any two surrogates lie within that distance of each other. In particular the observed reading and the mean of the full permutation null differ by at most $\frac{C}{n}\log_2|L|$.

> **The Hinted View Is Blind.** If a view's collision fraction satisfies $\frac{C}{n}\log_2|L| \le \delta$, then the observed reading, every surrogate, and the null mean all lie inside one common interval of width $\delta$. A permutation test on such a view has no resolution at all.

That is the theorem the experiment was living inside. A view fine enough to be *interesting* is automatically fine enough to be *untestable by shuffling*. The $z$-scores in the table above — $-1.04$, $+1.36$, $+1.44$ — were not weak evidence of leakage. They were the only numbers such a test was capable of producing.

### Sharpening the band: two samples can only hide one bit

The alphabet factor $\log_2|L|$ is wasteful. If a fiber has only two samples in it, those two samples carry at most two distinct labels between them, so the entropy inside the fiber is at most $\log_2 2 = 1$ bit — no matter how vast the label alphabet is. Replacing the alphabet by the *realised support* inside each fiber gives a bound with the alphabet eliminated entirely:
$$H(\ell) - \hat I(\ell,c) \;\le\; \frac1n \sum_{k \,:\, f_k \ge 2} f_k \log_2 f_k.$$

And when no code is shared by more than two samples — which is precisely what happens for a view that is injective on *unordered* pairs $\{p,q\}$ —

> **The One-Bit Window.** If every fiber has at most two elements, then $H(\ell) - 1 \le \hat I(\ell,c) \le H(\ell)$, and every label-permuted surrogate is within one bit of the observed reading.

This is the quantitative form of the experimental table. When a run reports a hint view carrying $4.56$ bits against a label entropy of $4.60$, that is not a measurement. It is an identity, forced by fiber sizes alone.

### "The hint view sees more" is a theorem about estimators

A separate seduction in such experiments is *hint compounding*: the reported readings were $0.0153$ for the coarse product view and $0.9663$ for the finer hint view, and it is tempting to read the increase as "the hint adds information".

It does not, necessarily. Refining a view means composing: a coarse view is a fine view followed by a merging map $\varphi$. The plug-in functional is **monotone under refinement** — this is a data-processing inequality for empirical tables, proved directly from the log-sum inequality
$$\Big(\textstyle\sum_i a_i\Big)\log \frac{\sum_i a_i}{\sum_i b_i} \;\le\; \sum_i a_i \log \frac{a_i}{b_i},$$
with no probabilistic hypothesis at all. Merging columns of a contingency table can only lower the reading. So a finer view *always* reads at least as much as a coarser one; the observed ordering was forced.

Better still, the gain is capped by the sandwich: the fine reading is at most $H(\ell)$ and the coarse reading is at least $H(\ell)$ minus the coarse collision term, so

> **Hint Compounding Is Bias Compounding.** For any view $c'$ and any merging map $\varphi$,
> $$0 \;\le\; \hat I(\ell, c') - \hat I(\ell, \varphi\circ c') \;\le\; \frac{C(\varphi \circ c')}{n}\,\log_2|L|.$$
> Whatever a hint appears to add, the coarse view's sparsity deficit already accounted for it.

The inequality is not vacuous: collapsing a perfectly informative binary readout to a constant drops the reading from a full bit to zero. Refinement genuinely can move the number — which is exactly the problem.

### The dichotomy: two regimes that never meet

At this point a genuine tension appears. There is a second, older half of this story: an exact result saying that a *symmetric* readout on a population closed under swapping the two factors leaks **exactly zero** which-factor bits. Zero, not "statistically indistinguishable from zero". And yet the hint view reads $0.97$. Both statements cannot be describing the same situation — so which is it?

The resolution is a single structural theorem, and it is the cleanest thing in this circle of ideas.

Call a sample **swap-closed** if it carries a permutation $\sigma$ of the samples with three properties: $\sigma$ is an involution ($\sigma\sigma = \mathrm{id}$), it has no fixed points ($\sigma i \ne i$ for every $i$ — no sample of the form $(p,p)$), the view is constant along it ($c(\sigma i) = c(i)$, i.e. the view is symmetric), and the which-factor label flips along it ($\ell(\sigma i) \ne \ell(i)$). This is exactly the precise version, at the level of a finite sample, of "my dataset contains both $(p,q)$ and $(q,p)$, my view cannot tell them apart, and the label does".

From that one structure both halves of the dichotomy fall out.

**First half.** For every sample $i$, the fiber over $c(i)$ contains both $i$ and $\sigma i$, which are distinct. So *every* fiber has at least two elements, every sample collides, and
$$C = n, \qquad \frac{C}{n} = 1.$$
The collision fraction is maximal. The sandwich degenerates to $H(\ell) - 1 \le \hat I \le H(\ell)$, which for a binary label says nothing whatsoever.

**Second half.** The involution is a bijection between the two label cells of each fiber: it carries the samples in fiber $k$ with label $b$ onto the samples in fiber $k$ with label $\lnot b$. Hence each fiber splits exactly in half, $2\,N_{b,k} = f_k$, and summing over $k$, each label carries exactly half the sample, $2\,|\ell^{-1}(b)| = n$. Combining,
$$|\ell^{-1}(b)|\cdot f_k \;=\; N_{b,k}\cdot n \qquad \text{for all } b, k,$$
which is precisely the statement that the contingency table is a **product table** — the empirical label and view distributions are exactly independent. Therefore
$$\hat I(\ell, c) \;=\; 0$$
exactly, with no null calibration, no sensitivity floor, and no asymptotics.

Put the halves together:

> **The Blindness–Sparsity Dichotomy.** On a swap-closed sample the reading is exactly $0$ bits *and* the collision fraction is exactly $1$, so the sandwich's guaranteed band is the whole of $[H(\ell)-1, H(\ell)]$. Contrapositively, a sample on which the view fails to collide even once — $C < n$ — cannot be swap-closed at all.

The two regimes are **disjoint**. Where the exact-zero wall applies, the sandwich is vacuous; where the sandwich is informative, the wall does not apply. The $0.97$-bit reading was taken in the sparse regime, where the statistic provably has no resolution; the exact-zero theorem lives in the symmetric regime, where the collision fraction is pinned at $1$. They were never in conflict, and neither was ever evidence about the other.

And the hypotheses are not empty: the two-element sample $\{(p,q),(q,p)\}$ with a constant view and the swap involution satisfies all four conditions at once.

### Why the null was *above* the data

One last twist that this framework explains for free. In a controlled run on $3906$ ordered pairs drawn from $63$ primes, the observed readings were exactly $0.0000$ for every view — product view, hint view, residue view — while the permutation nulls sat at $0.1363$, $0.4990$ and $0.0004$ respectively. The nulls were *higher* than the data.

Of course they were. The observed sample is swap-closed, so its reading is exactly zero by the theorem. A label shuffle destroys the involution: the surrogate no longer has the property that the label flips along $\sigma$, so its table is no longer a product table, and its reading drifts upward by ordinary sampling noise. **The permutation null of a symmetric view on a swap-closed sample is systematically biased upward away from an exactly-zero observation.** A programme that flags "observed exceeds null" as evidence of leakage will, in this setting, never flag anything — and a programme that reads a large positive number off a fine view is reading the null's own inflation seen from below.

### The moral

There is a general lesson here that reaches well past factoring. Empirical mutual information on a fine-grained view is not a measurement of dependence; in the limit of a distinct code per sample it is *identically the label entropy*, by a two-line argument. The permutation test, the standard remedy, inherits the same defect: shuffling preserves fibers and label counts, hence preserves the band, hence cannot see past it. Any pipeline that computes an information score on a high-cardinality feature and calibrates it by shuffling is, in the sparse regime, a very expensive way of recomputing the entropy of its own labels.

The cure is not a better null. It is to report the collision fraction alongside the reading — because that single number is a certificate of how much resolution the test had to begin with. In the case at hand the certificate read $1$: no resolution at all. The hinted view, carrying $4.56$ of $4.60$ bits of label entropy, is blind to which factor is which, at the finest sensitivity the instrument can offer. The chain is closed with no loose ends.
