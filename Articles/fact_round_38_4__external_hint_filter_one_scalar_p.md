# One Number Prices Every Hint

*Why a tip about a secret can make your search at most twice as fast per dial, why $t$ bits of information can never buy more than a factor $2^t$, and how a single probability decides it all.*

---

## The locksmith's dilemma

Imagine a locksmith facing a safe with a single dial. The dial has $K$ positions and only one of them is right. With no information she tries positions one after another, and on average she does a fixed amount of work. Now someone slips her a note: *"I think it's position 3."* How much faster does she get?

That question, asked carefully, is the subject of this article. The safe stands in for any search where the answer hides among many candidates. The motivating case is factoring a large number $N = pq$: we want the hidden prime $p$, and we can sort the candidate primes into $K$ classes, for example by their remainder modulo some small number. That sorting is the "dial". If we knew the class of $p$, we would only search one $K$-th of the candidates. In general, call $\theta$ the fraction of the full work that remains when we search only the predicted class. For a $K$-position dial, $\theta = 1/K$.

A prediction of the class, wherever it comes from, is called a **filter**. If the filter is right (a *hit*), we pay $\theta$. If it is wrong (a *miss*), we fall back on the full search and pay $1$. This is the whole model, and it already holds a surprise.

## The master law

The expected work is $\theta$ times the probability of a hit plus $1$ times the probability of a miss. Write $P_{\text{hit}}$ for the hit probability. Then

$$\text{Work} = \theta\,P_{\text{hit}} + (1 - P_{\text{hit}}) = 1 - (1-\theta)\,P_{\text{hit}},$$

and the speedup is the reciprocal:

$$\boxed{\;\text{Speedup} = \frac{1}{1 - (1-\theta)\,P_{\text{hit}}}\;}$$

This is the **master law**. It is a one-line calculation, but it has a strong consequence: *all the information in the filter acts through one number.* How the filter was built does not matter. Neither does what data it looked at, how clever it is, or what probability space it lives on. Two filters with the same hit probability give exactly the same speedup. The law increases strictly with $P_{\text{hit}}$, and it reaches its ceiling $1/\theta$ (for a dial, exactly $K$) only when the filter is certain, $P_{\text{hit}} = 1$.

So the question "how much is this hint worth?" reduces to "how often is it right?" The rest of the story is about computing that one number in various situations, and about what limits it.

## Why looking harder at the lock doesn't help

The first situation is the *internal* filter. Here the locksmith studies the safe itself: its scratches, the public data. In factoring, the public datum is $N$ itself, or anything computed from it. Call this observable coordinate $c$.

There is a symmetry. In many natural settings the class of the hidden factor is **uniformly distributed on every fibre of $c$**: once you fix everything you can see, each of the $K$ classes is equally likely. Any reading you generate from $c$, however you randomize it, is then a guess made without knowing the answer. Averaged over the uniform label, such a guess is right exactly $1/K$ of the time:

$$P_{\text{hit}}^{\text{internal}} = \frac{1}{K}.$$

Put this into the master law with the binary dial $K = 2$, $\theta = 1/2$:

$$\text{Speedup} = \frac{1}{1 - \tfrac12\cdot\tfrac12} = \frac{4}{3}.$$

This is the known **$4/3$ cap on residue-based internal filters**, and the master law shows what it is: the *uninformative point* of the law, the speedup of a coin flip. The $4/3$ is not luck or a cleverness gain. It comes from paying half price whenever the coin happens to land right.

## Where the symmetry breaks

Now suppose the note comes from *outside*: a side channel, a leaked bit, an oracle. Its reliability is described by a **likelihood** $L(b, h)$, the probability that the hint says $h$ when the true class is $b$. The key point is that this likelihood is attached to the **label coordinate**, the hidden class, and not to the observable coordinate $c$. When we average over the fibres of $c$, the step that killed every internal reading leaves the hint untouched:

$$P_{\text{hit}}^{\text{external}} = \frac{1}{K}\sum_{b} L(b,b),$$

which is simply the hint's average accuracy. An internal reading is a function of what you can see, so the hidden label's uniformity washes it out. An external hint is correlated with what you cannot see, so it survives. This is the precise point where the symmetry breaks, and it is why external information can go past $4/3$ at all.

## The which-factor ceiling: a 2× wall per dial

There is a catch, and it is subtle. A number $N = pq$ has *two* prime factors. A hint that says *"a factor is in class 3"* without saying *which* factor is talking about $p$ only half the time. The other half of the time it accurately describes $q$, which tells us nothing about $p$'s class: we hit by luck with probability $1/K$.

Write $\alpha$ for the hint's accuracy about the factor it speaks of. Then

$$P_{\text{hit}} = \frac{\alpha + 1/K}{2}.$$

With the dial cost $\theta = 1/K$, even a *perfect* hint ($\alpha = 1$) gives

$$\text{Speedup} \le \frac{2K^2}{K^2 + 1} < 2,$$

for every dial size $K$ and every hint likelihood. The bound is sharp: a perfect hint attains it. As the dial gets finer the ceiling climbs toward $2$ (for $K = 16$ it is $512/257 \approx 1.992$) but never reaches it. This is the **which-factor ceiling**: an unnamed external hint is worth less than a factor of two per dial, however many positions the dial has.

For the binary dial the formula becomes the **canonical partition law**

$$\text{Speedup}(\alpha) = \frac{8}{7 - 2\alpha}.$$

At $\alpha = 1/2$, a useless hint, it gives exactly $4/3$, the internal cap again. At $\alpha = 1$, a flawless hint, it reaches only $8/5 = 1.6$. A perfect hint and an isolated perfect hint differ by one missing bit of information: *which factor?*

Paying for that bit removes the ceiling. If the hint names its factor, a perfect hint gives the full $K$. Finding out which factor you are dealing with is an isolation problem: separate the right candidate among $M$ possibilities using yes/no questions. Each answer splits the candidates at most in two, so at least $\lceil \log_2 M \rceil$ questions are needed, and binary encoding shows that many always suffice. For factoring, $M$ is the number of primes below $\sqrt N$, written $\pi(\sqrt N)$. The isolation price is therefore about $\log_2 \pi(\sqrt N)$ oracle queries. It grows very slowly ($17$ queries for a 40-bit $N$), and in the original study's cost accounting it pays for itself from about $t = 5$ hint bits onward.

## Many factors: an overshoot and a collapse

What if $N$ has $r$ prime factors? The hint now speaks about the wanted one only a fraction $1/r$ of the time, and

$$P_{\text{hit}} = \frac{\alpha + (r-1)/K}{r}.$$

The perfect-hint ceiling at per-dial cost $1/K$ is

$$\frac{rK^2}{(r-1)K^2 - (r-2)K + (r-1)}.$$

As the dial is refined it tends to $r/(r-1)$. Two features stand out. For $r = 2$ the ceiling approaches its limit $2$ from below. For $r \ge 3$ it **overshoots**: at the finite dial $K = r$ it already exceeds the limit, so coarser dials can beat finer ones. For $r \ge 7$ the binary dial $K = 2$ is the best of all dial sizes, with ceiling $4r/(3r-1)$. As $r$ grows this falls back onto $4/3$. For multi-prime moduli, an anonymous external hint is asymptotically worth no more than a coin flip.

## The ladder: two bits always lost

Now consider a hint that is *certain* but costs something to use. The **certain-hint ladder** gives the speedup of a $t$-bit certain hint as

$$\text{Ladder}(t) = \frac{2^{t-2}}{1 - 2^{1-t}}.$$

It is again a point of the master law: a certain hit, $P_{\text{hit}} = 1$, at effective cost $\theta_t = 2a(1-a)$ with $a = 2^{1-t}$. It lies between $2^{t-2}$ and $2^{t-1}$, and it doubles with every extra bit (the ratio of consecutive rungs tends to $2$). The exact identity

$$\frac{2^t}{\text{Ladder}(t)} = 4\,(1 - 2^{1-t}) \longrightarrow 4$$

says the ladder loses **exactly two bits** against the ideal $2^t$ in the limit. The study identifies them: one bit is lost to *parity*, the other to *which factor*.

## Trace hints: a constant tax, not a slower rate

Some hints arrive garbled and must be repaired by a recovery step that costs a roughly constant factor $C_t$. The resulting **trace-hint** speedup is $2^{t-1}/C_t$. Taking logarithms,

$$\log_2 \text{Speedup} = t - 1 - \log_2 C_t .$$

If $C_t$ stays between two positive constants, the subtracted term is bounded. So $\log_2(\text{Speedup})/t \to 1$: one bit of work saved per bit of hint, asymptotically. If $C_t$ converges, each extra bit eventually adds exactly one bit of speedup. A generic recovery overhead of "about $5\times$" is therefore a **constant divisor, not a rate penalty**.

## How much noise can a hint survive?

Real hints are sometimes simply wrong. In an explicit fallback model, a corrupted hint (probability $\varepsilon$) sends you to search the hinted region in vain (cost $\theta$) and then do the full search (cost $1$). A which-factor hint of accuracy $\alpha$ then beats plain search exactly when $\alpha$ exceeds the break-even surface

$$\alpha^*(\theta, \varepsilon) = \frac{2\varepsilon\theta}{(1-\varepsilon)(1-\theta)} - \theta,$$

which rises with the noise level. Internal filters break even only for $\varepsilon < (1-\theta)/(2-\theta)$. Perfect external hints tolerate up to $(1-\theta^2)/(1+2\theta-\theta^2)$, which is *strictly larger for every* $\theta$. At $\theta = 1/2$ the two thresholds are $1/3$ and $3/7$. (A different cost accounting in the original study gave $1/6$ and $3/5$. The exact numbers depend on how a failed attempt is charged, but in both accountings external hints tolerate more noise than internal filters.)

## The universal speed limit: $t$ bits buy at most $2^t$

All of the above concerns filters of a particular shape. The final result needs no model at all. Take any hidden target, uniform among $M$ candidates. Take any hint, a function $H$ into a set of $|B|$ values. Take *any* guessing strategy that, after seeing the hint, tests candidates in some order. The only rule is that the strategy never tests two candidates with the same hint value at the same step.

Look at the candidates sharing one hint value, a *fibre* of size $n$. Their test positions are $n$ distinct positive integers, so they sum to at least $1 + 2 + \dots + n = n(n+1)/2$. Adding over fibres and applying the Cauchy–Schwarz inequality, $\sum n_h^2 \ge M^2/|B|$, gives the **guessing bound**

$$|B| \cdot 2\sum_x g(x) \;\ge\; M^2 + |B|\,M, \qquad\text{that is,}\qquad \mathbb E[\text{guesses}] \ge \frac{1}{2}\left(\frac{M}{|B|} + 1\right).$$

Compared with the hint-free optimum $(M+1)/2$, the speedup is at most $|B|$. A $t$-bit hint has at most $2^t$ values, so

$$\text{Speedup} \le 2^t.$$

The bound is sharp. A perfectly balanced hint with in-fibre ranking meets the guessing inequality with equality. Two independent hints of $t_1$ and $t_2$ bits, used together, buy at most $2^{t_1} \cdot 2^{t_2}$. Work bits add up, and they do not multiply into something bigger: **there is no synergy.**

## The completed map

These pieces fill in the third row of a three-row barrier map for accelerating searches:

| Source of information | What it can buy |
|---|---|
| **Residues** (internal readings) | capped at $4/3$, by theorem: the uninformative point of the master law |
| **Position** (structural information) | about $5.19\times$, as measured in companion experiments |
| **External hints** | linear in bits: at most $2^t$ for $t$ bits, and below $2\times$ per dial unless the which-factor bit is paid for |

The last row carries the lesson of this work. *External information is priced linearly.* Capacity can show synergy in channel coding, but work bits do not combine that way. Each hint bit buys at most one bit of saved work, an anonymous hint pays a which-factor tax that caps it below $2\times$ per dial, and the only way past that wall is to buy the missing bit through isolation.

In practice the message is simple. To judge a hint, ask how often it is right. That single number, put into the master law, gives its price.
