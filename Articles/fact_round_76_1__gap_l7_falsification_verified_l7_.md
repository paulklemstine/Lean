# The Order You Search In Is Not Your Choice — It Belongs to the Numbers

## A rule of thumb that turned out to be a theorem about somebody else

Suppose you are handed a number $N$ that you know is the product of two unknown primes, $N = pq$ with $p \le q$, and you are told something extra: the two primes are *balanced*, meaning $q < 2p$. They are not wildly different in size. That single promise is enormously informative. It confines the smaller prime to a narrow corridor:
$$\frac{\sqrt{N}}{\sqrt{2}} \;\le\; p \;\le\; \sqrt{N}.$$

The lower end comes from $p^2 \le pq = N$ combined with $q < 2p$, which gives $N = pq < 2p^2$; the upper end is $p \le \sqrt{N}$. So $p$ lives in a window of width about $0.29\sqrt{N}$, anchored at $\sqrt{N}$.

Now the practical question. You are going to walk through that window testing candidates one at a time. **Which end do you start from?**

For a long time the folklore answer was: start at $\sqrt{N}$ and walk *down*. Balanced primes cluster near $\sqrt N$, the reasoning goes, so the descending scan finds them fastest. The rule was even elevated to a proposed principle — call it the *extremal-order claim*: among all committed enumeration orders, the $\sqrt{N}$-descending one is optimal.

This article is the story of that claim being **false**, of what replaced it, and of a rather beautiful constant, $4 - 2\sqrt{2} \approx 1.1716$, that decides the matter in every case.

The punch line, stated plainly: **which end you should start from is not a fact about your algorithm. It is a fact about the population of numbers you are being handed.** Change the source of your inputs — not the algorithm, not the window, just the statistical law governing how balanced the primes are — and the winner flips. Two perfectly legitimate families of balanced semiprimes exist on which the *same two* strategies swap places. That makes "descending is optimal" not a theorem awaiting a proof, but a category error: it asserts about a strategy something that is only ever true of a distribution.

---

## Setting the stage: what a "committed order" is

To say anything precise we need to pin down the class of strategies. Call a strategy a **reordering policy** if it does exactly one thing: it commits, in advance, to an enumeration
$$a_0,\; a_1,\; a_2,\; \dots$$
of the candidate slots, and then probes them in that order until it hits. Three ground rules make the class honest.

* **Uniformity.** One computable rule produces the order for every input size; you cannot hand-tune a different order for each $N$.
* **Test-blindness.** The order is fixed before any probe is answered. The policy may not peek at the outcome of probe $3$ before deciding what to probe fourth.
* **Overhead accounting.** Any bookkeeping the policy performs is charged to its own budget.

Cost is the natural thing: if the hidden answer sits at slot $i$ and the policy visits $i$ on its $(k+1)$-st probe, the draw costs $k+1$. Averaged against the probability mass $w$ on slots, the **expected probe cost** of the enumeration $a$ is
$$C(a) \;=\; \sum_{k} (k+1)\, w\!\left(a_k\right).$$

That is the entire model. It is small enough to reason about completely — and, crucially, small enough that we can determine *exactly* which order-optimality statements it can and cannot support.

---

## The one theorem the model does support: sort by mass

**Exchange Theorem.** *Let $w$ assign a probability mass to each of $n$ slots. If an enumeration $a$ visits the slots in nonincreasing order of mass — that is, $w(a_0) \ge w(a_1) \ge \cdots$ — then for every other enumeration $b$ of the same slots, $C(a) \le C(b)$.*

The proof is the classic exchange argument. If some enumeration puts a lighter slot before a heavier one, swap them: the heavier mass moves earlier, the lighter one later, and the total strictly decreases (or stays equal). Any enumeration can be bubbled into mass-sorted order by such swaps, none of which increases the cost. Equivalently, the probe index $k+1$ and the mass $w(a_k)$ *antivary* under the sorted arrangement, and the rearrangement inequality does the rest.

Two things must be noticed about this theorem, and they are the hinge of the whole story.

The first: it is the *only* order-optimality statement the model supports. It exhausts the content of "which order is best."

The second: **it names no arithmetic order at all.** It says "sort by mass." It does not say "descend from $\sqrt N$." Whether descending from $\sqrt{N}$ *is* the mass-sorted order depends entirely on where the mass is — and the mass is put there by whoever generated the numbers.

A companion fact makes the point sharper still.

**No Free Lunch on Flat Priors.** *If the mass is uniform across $n$ slots, then every enumeration whatsoever costs exactly $(n+1)/2$.*

Against a featureless prior, cleverness in ordering is worth precisely nothing. Every gain a reordering policy ever books is a gain harvested from the *shape* of the prior. This reframes the whole subject: the question is never "what is the best order?" but "what shape does my input distribution have?"

---

## The sign-flip law

So let us measure the shape. Parametrise a draw by its **balance ratio** $r = q/p \ge 1$. Since $p = \sqrt{N}/\sqrt{r}$, the smaller prime sits at height $1/\sqrt{r}$ in units of $\sqrt{N}$. A generator promising $q < 2p$ delivers $r \in [1,2)$, and $1/\sqrt r$ ranges over $(1/\sqrt2, 1]$ — exactly the balance window.

Now the two candidate policies, both costs measured in units of $\sqrt N$:

* **Window-ascending** starts at the bottom of the window, $\sqrt{N}/\sqrt{2}$, and climbs. It pays $\;1/\sqrt{r} - 1/\sqrt{2}$.
* **Window-descending** starts at the top, $\sqrt{N}$, and falls. It pays $\;1 - 1/\sqrt{r}$.

Average both over the population and compare. Writing $m = \mathbb{E}[1/\sqrt{r}]$ for the population's mean height, ascending wins exactly when $m - 1/\sqrt 2 < 1 - m$, i.e.

**Sign-Flip Law (population form).** *For any population of balance ratios, window-ascending strictly beats window-descending if and only if*
$$\mathbb{E}\!\left[\tfrac{1}{\sqrt r}\right] \;<\; \frac{2+\sqrt{2}}{4} \;\approx\; 0.85355.$$
*Equivalently, in the reciprocal convention, if and only if the population passes the crossover constant*
$$\frac{2}{1 + 1/\sqrt{2}} \;=\; 4 - 2\sqrt{2} \;\approx\; 1.17157.$$

Look at what this criterion is made of. There is no $N$ in it. There is no algorithm in it. It is a single number computed from the *generator*. A population whose mean height sits low in the window — bottom-heavy — is served by ascending; a top-heavy population is served by descending; and $(2+\sqrt2)/4$ is the knife-edge.

---

## Where the knife-edge actually falls

Make it concrete with the simplest model: let the balance ratio be uniform on a band, $r \sim U[1, 1+\delta]$. Then a short integration of $r^{-1/2}$ gives an exact and memorable answer:
$$\mathbb{E}\!\left[\tfrac{1}{\sqrt r}\right] \;=\; \frac{1}{\delta}\int_1^{1+\delta} r^{-1/2}\,dr \;=\; \frac{2\left(\sqrt{1+\delta}-1\right)}{\delta} \;=\; \frac{2}{1+\sqrt{1+\delta}}.$$
The middle expression telescopes into the last one because $\delta = (\sqrt{1+\delta}-1)(\sqrt{1+\delta}+1)$. The mean is strictly decreasing in $\delta$: **wider bands are more bottom-heavy**, which is intuitively right, since widening the band admits more lopsided factorisations that push $p$ downwards.

Feed this into the sign-flip criterion and solve. The result is one of those constants that looks invented and isn't.

**Sign-Flip Law (uniform bands).** *On the band $r \sim U[1,1+\delta]$, window-ascending strictly beats window-descending if and only if*
$$\delta \;>\; \delta^{*} \;=\; 80 - 56\sqrt{2} \;\approx\; 0.80404.$$

Everything now falls out by arithmetic.

* **Hard balance** ($q < 2p$, i.e. $\delta = 1$). Here $\mathbb{E}[1/\sqrt r] = 2/(1+\sqrt2) = 2(\sqrt2-1) \approx 0.8284$, comfortably below the crossover. The population's **tilt** — its mean height rescaled so that $0$ is the window bottom and $1$ the window top — is exactly
$$z \;=\; \frac{2(\sqrt2-1) - 1/\sqrt2}{1 - 1/\sqrt2} \;=\; \sqrt{2}-1 \;\approx\; 0.41421.$$
Bottom-heavy. And the two costs stand in an exact ratio:
$$\frac{\text{descending}}{\text{ascending}} \;=\; \frac{1-m}{m - 1/\sqrt2} \;=\; \sqrt{2}.$$
Ascending wins, by a clean factor of $\sqrt 2$.

* **A narrow band** ($\delta = 1/2$). Now $\mathbb{E}[1/\sqrt r] = 2/(1+\sqrt{1.5}) \approx 0.89898$, *above* the crossover $0.85355$. Top-heavy. **Descending wins.**

Both bands are legitimate balanced-semiprime generators. Same two policies, opposite winners. That is the falsification, complete:

**Falsification of the Extremal-Order Claim.** *There exist two admissible balanced populations on which the same pair of committed reordering policies exchange winners. Hence no theorem of the reordering model can name a universal extremal arithmetic order.*

And this is not an artefact of the choice $q < 2p$. For a generator advertising $q < kp$, the window becomes $[\sqrt N/\sqrt k, \sqrt N]$ and the same computation gives the crossover
$$\delta^{*}(k) \;=\; \frac{8\sqrt{k}\,(\sqrt{k}-1)}{(\sqrt{k}+1)^{2}},$$
which at $k=2$ reduces to $80-56\sqrt2$. One checks that $\delta^{*}(k) < k-1$ for every $k > 1$: the crossover **always** lies strictly inside the range of admissible band widths. So for every advertised balance ratio there are both an ascending-extremal and a descending-extremal population. The sign flip is universal in the family; nothing about the convention $q<2p$ caused it.

---

## What the numbers said

Independent simulation over four large pools of generated semiprimes bears this out with slightly uncomfortable precision. Hard-balanced generators come out bottom-heavy with measured tilt $z$ between $0.4095$ and $0.4148$, straddling the analytic $\sqrt2 - 1 = 0.41421$. Narrow-band pools come out top-heavy at $z \approx 0.6466$, close to the value $0.655$ that $\delta = 1/2$ predicts, and there descending is extremal. Window-ascending beat window-descending on hard-balanced pools by a factor $1.58 \pm 0.03$ across two pools of $2400$ draws each — matching the two-stage refinement of the window model ($0.219/0.138 = 1.587$), with the pure one-shot model's exact $\sqrt2 \approx 1.414$ sitting underneath it as the idealised core.

There is a moral in that agreement. An earlier, smaller run had reported $1.71$–$1.91$; that turned out to be sampling inflation at $n=150$, while its own analytic prediction of $1.59$ had been right all along.

A previously published experiment reporting a descending win of $1.08\times$ on its own pool is likewise **refined rather than contradicted**: re-running its pool gives $1.078\times$, and that pool's tilt sits between the hard-balanced and narrow-band regimes. Its result was real and its conclusion locally correct. What was wrong was only the generalisation to *all* balanced generators. A further caveat has real operational teeth: the window policy is *undefined* on $21.6\%$ of that pool's draws, because those draws violate the balance promise that licenses the window in the first place. Advantage from the window is available only after you have verified that your generator actually enforces balance.

---

## Measurement becomes certification

If the winner is a property of the population, then choosing an order is a *measurement* problem, and measurements come with error bars. Define the **prior-shape gain factor** of a population with mean height $m$:
$$\Lambda(m) \;=\; \frac{1-m}{\,m - 1/\sqrt{2}\,},$$
the ratio of descending cost to ascending cost. It is strictly decreasing on the admissible range $1/\sqrt2 < m < 1$: the more bottom-heavy the population, the larger the ascending advantage. Monotonicity converts an interval estimate into an interval conclusion:

**Certification.** *If a measurement $\hat m$ with error bar $\varepsilon$ satisfies $\hat m + \varepsilon < (2+\sqrt2)/4$ and $\hat m - \varepsilon > 1/\sqrt2$, then window-ascending is certified extremal on that population, with gain factor bracketed between $\Lambda(\hat m + \varepsilon)$ and $\Lambda(\hat m - \varepsilon)$, and in particular strictly greater than $1$.*

Applied to the hard-balanced pool, whose measured mean is $\hat m = 0.8284$ with a conservative $\varepsilon = 0.01$: since $0.8384 < 0.85355$, ascending is certified. This is what it looks like to replace a folklore rule with a protocol.

---

## The ceiling: how much can reordering ever buy you?

Falsifying an optimality claim invites the next question: what is the most a reordering policy can win, over all populations and all orders? The answer is a cap with a pleasingly transparent structure. Let $S$ be the speedup a policy achieves against a full linear scan, let $\Lambda$ be the population's prior-shape factor, let $\mu$ be the fraction of candidates the policy's filter still leaves it to touch, and let $2^{k}$ be the number of buckets a $k$-bit filter can separate. Then
$$S \;\le\; \frac{4}{3}\cdot \frac{\min\!\left(1/\mu,\; 2^{k}\right)}{\Lambda}.$$

Its two branches are two independent accounting floors.

The **touch floor** is the honest one, and it is a theorem rather than a bookkeeping convention. If a filter leaves at least a $\mu$-fraction of $M$ candidates on the table, the policy must average at least $(\mu M + 1)/2$ probes against a uniform hit, versus $(M+1)/2$ for the full scan; hence $S \le 1/\mu$. No assumption about how the hits are distributed inside the surviving cells is needed. The **bit floor** says a $k$-bit filter cannot resolve more than $2^k$ buckets. The constant $4/3$ is a residue slack carried over from a separate line of analysis and is untouched here.

The calibration is the satisfying part. A mod-$M$ wheel — the standard trick of skipping candidates sharing a small factor with $M$ — leaves *exactly* $\varphi(M)\cdot m$ of the first $M m$ candidates, where $\varphi$ is Euler's totient. This is proved by induction on complete residue blocks, and, decisively, **reordering cannot change it**: a reordering is a bijection, so the number of surviving candidates it must touch is invariant. The keep fraction is therefore *extracted from the transcript*, not assumed. The touch floor then yields, with no further input,
$$S \;\le\; \frac{M}{\varphi(M)}.$$
At the standard wheel $M = 30$ we have $\varphi(30) = 8$, so $\mu = 8/30 = 4/15$ and the ceiling is $30/8 = 3.75$ exactly. Measured wheel speedups across the pools: $3.7331$, $3.741$, $3.7496$. The headline cell sits $0.24\%$ below the law, and the widest cell of the arm only $0.45\%$ below. A theoretical ceiling and a measurement agreeing to three digits is the kind of thing that makes you believe the model.

Across all policy arms and all four pools, the audited table of measured speedups shows **zero violations** of the cap. One caveat is load-bearing and worth stating out loud: on a *pure permutation* — no filter at all — the keep fraction is $\mu = 1$ and the cap degenerates to the constant $4/3$, saying nothing about the policy. It is only when $\mu$ is genuinely extracted from the structure that the cap has bite. The hybrid arm combining a window with a wheel shows exactly this: it achieves $S = 4.06$, which *breaks* the cap computed with $\mu$ booked at $1$ (that cap is $1.77$) and *satisfies* the cap computed with the structural wheel fraction $\mu = 4/15$. Extract the keep fraction and the inequality is real; book it and it is empty.

---

## Two witnesses that had to be retired

Honest ledgers include retractions, and two are worth telling because both illustrate the same trap: **a statistic that looks informative because it is degenerate.**

The first was a proposed *Jacobi witness*: evaluate the Jacobi symbol $\left(\frac{N}{x}\right)$ at candidate $x$ and promote candidates whose symbol behaves distinctively. It seemed to fire at the factor with impressive reliability. It does — for the emptiest possible reason. If $N = pq$ and $x = p$, then $p \mid N$, so $\gcd(N,p) = p \ne 1$ and the Jacobi symbol is *identically zero*. Not usually zero; always zero, for every $p$ and $q$. A statistic whose value at the target is the same constant across all draws separates nothing. It is not measuring prior shape; it is measuring "$p$ divides $N$", which is precisely the fact you were trying to discover. Away from the factor, when $\gcd(N,x)=1$, the symbol is nonzero — confirming that the vanishing is a degeneracy of the witness, not a feature of the symbol.

Its replacement is a properly controlled experiment: a **keyed-versus-fixed residue control**. Compare an arm selecting a residue class mod $3$ by a key derived from $N$ against one using a fixed class. If residue couplings carried information about the factorisation, the keyed arm would win. It does not: the arms are statistically identical ($0.6366$ vs $0.6537$ on one pool, $0.684$ vs $0.660$ on another), with hit-enrichment a fair coin in *both*.

There is a clean combinatorial reason, and it holds at every modulus. Among the first $Mm$ candidates, each residue class mod $M$ contains exactly $m$ of them, and exactly $\varphi(M) m$ are coprime to $M$. Therefore selecting a class promotes exactly the same number of candidates *no matter how the class is chosen* — the promoted count is independent of the key, hence independent of $N$. Any promotion rule keyed on $N$ is statistically indistinguishable from a fixed one; the promoted share among the wheel's survivors is exactly $1/\varphi(M)$ in every arm. Residue promotion is **factor-blind**, unconditionally, at every modulus. Whatever gains such arms appear to show are prior-shape leakage on the marginals, nothing more.

Finally, one transfer claim was bounded rather than retracted. A separate line of work observed an "early-fire" phenomenon that it was tempting to import as support for descending scans. What actually transfers is a general law:

**Head-Domination.** *If two enumerations carry the same total mass and one of them has at least as much mass in every prefix, then it costs no more.*

The proof is a one-line Abel summation: expected probe cost equals the sum of the survival (tail) masses, $\sum_j \sum_{k \ge j} w_k$, and dominating every prefix means being dominated in every tail. Front-loading wins. But this says nothing about *which arithmetic order front-loads* — that, once again, is the population question. Surrogate experiments confirm the distinction sharply: an enumeration front-loaded at $\sqrt N$ costs $948$, an aligned one $1493$, and a naive one $3149$; move the front-loading to the low end and the ordering flips outright.

---

## What is left standing

Strip everything down and the picture is simple, and I think genuinely instructive beyond this corner of number theory.

A reordering policy has exactly one lever: put probable things first. That is the Exchange Theorem, and against a flat prior the lever does nothing at all. Everything else — which end of a window to start from, whether a wheel helps, whether a residue trick pays — is determined not by the policy but by the distribution that feeds it. The extremal order is not a property of the algorithm. It is a property of the numbers.

That is why the crossover constant $4 - 2\sqrt{2}$ deserves a name. It is the exact point at which a population's mean height stops recommending one strategy and starts recommending its opposite. Above it, descend; below it, ascend; the algorithm has no opinion in the matter and never did.

The general lesson is one that recurs wherever search meets statistics: **before you optimise the order, measure the population.** A heuristic that works is often a heuristic that is quietly reporting a fact about your inputs — and heuristics like that stop working, silently, the moment your inputs change.
