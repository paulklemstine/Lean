# The Battery Effect: Why Four Weak Measurements Can Know More Than Four Times as Much

## A dashboard of nearly useless dials

Imagine you are handed a very large number $N$ and told only that it is the product of two unknown primes, $N = pq$. You are not allowed to factor it. You are allowed to read, off a little dashboard, four dials. The first shows $N \bmod 31$. The second shows $N \bmod 23$. The third shows $N \bmod 9$. The fourth shows $N \bmod 8$. That's all.

Now someone asks you a question about the *hidden* structure: for each of those four moduli, what is the unordered pair of residues $\{p \bmod m,\ q \bmod m\}$ that the two secret primes leave behind? Call that four-part answer the **label**. It is a genuinely hidden quantity — the dials show you what the *product* does modulo each $m$; the label is about what the *factors* do.

Each single dial is close to useless. Knowing $N \bmod 31$ tells you the product of the two residues modulo $31$, which is consistent with many pairs; across a large population of such numbers it pins down only a fraction of a bit about the label. Add up the four dials' individual contributions and you get, in one carefully measured population of thirty thousand semiprimes, a total of $3.9099$ bits.

Then read all four dials *at once* — that is, read the single combined number
$$N \bmod (31 \cdot 23 \cdot 9 \cdot 8) = N \bmod 51{,}336,$$
which by the Chinese Remainder Theorem is exactly the four residues bundled together. The information this joint reading carries about the label is not $3.9099$ bits. It is
$$I = 8.2246 \text{ bits}.$$

The whole is more than **twice** the sum of its parts. The excess,
$$\text{synergy} \;=\; 8.2246 - 3.9099 \;=\; +4.3147 \text{ bits},$$
is larger than the entire additive prediction. And the joint reading is now within $1.3$ bits of the absolute maximum any measurement could achieve: the label itself only has $9.5276$ bits of entropy in this population, so there is simply not more than $9.5276$ bits to be had.

That is the phenomenon this article is about, and the mathematics below turns it from an observation into a theorem-backed theory. We call it **synergy compounding**, and its punchline is blunt: *capacity arithmetic must be done jointly, never marginally.*

## Bits, formally but gently

Everything here happens on a finite population $\Omega$ — say the $30{,}000$ semiprimes we sampled. A **statistic** is any function $f$ on that population; it partitions $\Omega$ into cells, one per value it takes. Its **empirical entropy** is
$$H(f) \;=\; \sum_{a} \frac{c_a}{N}\,\log_2\!\frac{N}{c_a},$$
where $N = |\Omega|$ and $c_a$ is the number of individuals with $f = a$. This is just the average number of bits it takes to name which cell an individual fell into. A statistic that separates everybody has entropy $\log_2 N$; a constant statistic has entropy $0$.

Given a label $L$ (another statistic, the thing we want to know), the **trace information** of $f$ about $L$ is
$$I(L;f) \;=\; H(L) + H(f) - H(L,f),$$
where $H(L,f)$ is the entropy of the paired statistic $x \mapsto (L(x), f(x))$. Equivalently, $I(L;f) = H(L) - H(L \mid f)$: it is how much of the label's uncertainty the reading destroys. This quantity is always between $0$ and $\min\{H(L), H(f)\}$.

A **dial** is a statistic of a special shape: it reads an individual as a residue modulo some fixed modulus $m$. A **battery** is a finite family of dials $d_1,\dots,d_k$. For a subset $S$ of the dials, the **joint reading** is the tuple of the readings of the dials in $S$, and the **joint capacity** of that sub-battery is
$$\mathrm{info}(S) \;=\; I\big(L;\ (d_i)_{i \in S}\big).$$
Finally, the **synergy** of a sub-battery is its capacity minus the naive additive prediction:
$$\mathrm{syn}(S) \;=\; \mathrm{info}(S) \;-\; \sum_{i \in S} \mathrm{info}(\{i\}).$$
Positive synergy means the dials help each other; negative synergy means they duplicate each other's work.

## Four things that are always true

Before any experiment, the definitions already force a rigid skeleton. Four facts hold for *every* population, *every* label, and *every* battery.

**The empty battery knows nothing.** A constant statistic has zero entropy and zero trace information, so $\mathrm{info}(\emptyset) = 0$. Every bit a battery carries was built up by adding dials — there is no free capacity baked into the frame.

**Capacity is monotone.** If $S \subseteq T$ then $\mathrm{info}(S) \le \mathrm{info}(T)$. Adding a dial can never *lower* what you know. This looks obvious and is not: it is a genuine *data processing inequality*, and the short proof is the interesting part. The joint reading of the smaller battery is a function of the joint reading of the larger one — you get it by throwing away coordinates. Throwing information away merges cells of the partition, and the counting form of the log-sum inequality (itself a two-line consequence of $\log t \le t - 1$) says that merging cells can only increase the leftover uncertainty about the label. So coarsening never raises capacity; equivalently, enlarging a battery never lowers it.

**There are two ceilings.** No battery can carry more about the label than the label has to give:
$$\mathrm{info}(S) \le H(L),$$
the **label-entropy ceiling** — the $9.5276$ bits in our experiment. And no battery can carry more than its own reading can express:
$$\mathrm{info}(S) \le H\big((d_i)_{i \in S}\big) \le \log_2 \prod_{i \in S} m_i,$$
the **code ceiling**. For our four dials the code ceiling is $\log_2 51{,}336 \approx 15.65$ bits. There is a third, often forgotten version: since a statistic on $N$ individuals has at most $N$ non-empty cells, $\mathrm{info}(S) \le \log_2 N$ always. With $30{,}000$ samples that is about $14.9$ bits — and this is why one must be suspicious of any measurement made on a code with tens of thousands of columns and only tens of thousands of samples.

**Synergy is trapped between two walls.** Upward, super-additivity is capped by the label entropy: $\mathrm{syn}(S) \le H(L)$, because the capacity is and the marginals are nonnegative. Downward, redundancy is capped by the marginal bookkeeping it defeats: for any dial $i \in S$,
$$\mathrm{info}(\{i\}) - \sum_{j \in S}\mathrm{info}(\{j\}) \;\le\; \mathrm{syn}(S),$$
because the battery is at least as good as its best member. Sharper still is the **synergy budget**: synergy is paid for out of unused code capacity,
$$\mathrm{syn}(S) \;\le\; \sum_{i \in S}\Big( H(d_i) - \mathrm{info}(\{i\}) \Big),$$
a dial that is already saturated as a label-predictor has nothing left to contribute jointly. For the experiment the budget is roughly $15.65 - 3.91 \approx 11.7$ bits, comfortably above the measured $+4.31$ — the observation is consistent with the theory, not straining against it.

There is also a clean regime at the far end: if every dial is individually blind, so all the marginals are zero, then the synergy *equals* the capacity. All of the knowledge is emergent.

## The order decomposition: synergy that isn't pairwise

Here is where the story gets sharper. Faced with super-additivity, the standard move is to tabulate **pairwise** interactions: for each of the six pairs of dials, how much more do the two together know than they do separately? That table is what an earlier round of this work produced, and it was believed to be the substance of the effect.

It isn't. The order-by-order decomposition of the measured battery reads:

| order $k$ | what it comprises | total synergy |
|---|---|---|
| $2$ | six pairs | $+0.244$ bits |
| $3$ | four triples | $+3.822$ bits |
| $4$ | the whole battery | $+4.315$ bits |

The pairwise interactions account for **6%** of the total. Almost all of the synergy first appears at order three and four. The mechanism is transparent once you see it: $N \bmod 31$ reveals one residue of the product. Two dials reveal two. Only when all four residues arrive together does the combined code — $15.8$ binary units' worth of distinct columns — become fine enough that each dial's residue-pair label becomes nearly determined. The dials do not help each other in pairs; they help each other *collectively*.

## The extreme point: a battery that is pure synergy

Is compounding a quirk of these particular moduli, or is it structural? The answer is that it is structural in the strongest possible sense, and the cleanest way to see it is a toy example you can check by hand.

Take the population to be the eight triples of bits $(x_1,x_2,x_3)$, each equally likely. The battery is three dials, each of modulus $2$: dial $i$ reads bit $x_i$. The label is the parity $x_1 \oplus x_2 \oplus x_3$.

* **Every single dial carries exactly $0$ bits.** Knowing $x_1$ leaves parity a perfect coin flip.
* **Every *pair* of dials carries exactly $0$ bits.** Knowing $x_1$ and $x_2$ still leaves $x_3$, hence the parity, uniformly undecided. So every pairwise synergy is zero, and the entire pairwise table is a table of zeros.
* **All three dials together carry exactly $1$ bit** — which is precisely the label entropy $H(L) = 1$. The battery saturates its ceiling.

So the additive prediction is $0$, the measurement is at the maximum, and $100\%$ of the capacity is order-three synergy. No inequality of the form $\mathrm{info} \le c \cdot \sum_i \mathrm{info}(\{i\})$ can hold for any constant $c$, however large: the right-hand side is zero and the left is one. And no bound on pairwise synergies constrains the joint synergy at all.

The same construction runs at every width. For any $k$, take the population $\{0,1\}^k$, the $k$ coordinate dials, and the parity of all $k$ bits as the label. Then **every proper sub-battery — of any size up to $k-1$ — carries exactly zero bits**, while the full battery carries exactly $1$ bit, its ceiling. So for every $k$ there are batteries whose capacity is entirely order-$k$ synergy. Bookkeeping over interactions of bounded order can never, in principle, predict the capacity of a battery.

The proof of the general case is a satisfying piece of counting. The cell of individuals agreeing with a given $x$ on the dials of a set $S$ has exactly $2^{\,k - |S|}$ members. If some coordinate $j$ is missing from $S$, flipping bit $j$ is an involution of that cell that toggles the parity, so it splits the cell exactly in half by label: the label is uniform inside every cell, and the reading tells you nothing. If nothing is missing, the reading is the individual, and the label is determined.

## The same story, computed exactly

The semiprime measurement was made on a sample, but the phenomenon is not a sampling effect, and one can watch it happen on a population small enough to enumerate completely. Take *all* $34{,}191$ products $N = pq$ with $p$ and $q$ distinct primes between $1000$ and $3000$, keep the same four dials, and let the hidden label be the smaller prime factor. Then, exactly:

the four dials individually carry $0.0574$, $0.0585$, $0.0157$ and $0.0013$ bits about that factor — a total of $0.1328$ bits, essentially nothing. Together they carry $6.2828$ bits, a synergy of $+6.15$ bits, forty-seven times the additive prediction, and within $1.47$ bits of the $7.7520$-bit label-entropy ceiling. The average synergy of a pair of dials is $0.59$ bits; of a triple, $3.03$ bits; of the whole battery, $6.15$ bits. Synergy compounds with order, visibly and exactly. The reason is the one the general theory predicts: each single residue leaves the factor pair almost unconstrained, while the combined Chinese-Remainder code, with $15.65$ bits of resolution, very nearly pins the product itself.

## Why this matters beyond the dials

Three consequences travel well beyond semiprimes.

**For measurement design.** If you are choosing which sensors, features, or probes to deploy, ranking them by individual informativeness can be arbitrarily wrong. The parity battery is the caricature: every candidate scores zero on its own, and the right choice is to take all of them. Real systems sit between the caricature and the additive ideal, and the only honest way to score a set is to evaluate the set.

**For auditing claims of information leakage.** The ceilings do real work here. If a measurement on $N$ individuals reports a small but nonzero signal through a code with far more columns than you have samples, the report is under suspicion before you even look at the mechanism: entropy estimates from sparse contingency tables are biased upward. In the experiment behind this article, one such statistic — a *which-factor* reading on the full joint code — came out at $0.0469$ bits, above every pairwise threshold. Tens of thousands of residue columns against thirty thousand samples is exactly the regime where plug-in estimation manufactures bits out of nothing, and the honest verdict is that this number is suspected bias rather than signal. The substantive claim of factor-blindness rests on the well-conditioned strata and on the ceiling arithmetic, not on that one number.

**For how we talk about "how much a system knows."** There is a temptation to treat information as an additive resource: each component contributes its share, the whole is the sum. The results here say that batteries are super-additive systems, unboundedly so, whose capacity grows toward the label-entropy ceiling with dominant higher-order terms. The only universal constraints — the only things you get for free — are monotonicity, the two ceilings, and the synergy budget. Everything else must be measured jointly.

## What's next

The obvious open question is the *rate* at which a battery climbs toward its ceiling. The capacity deficit $H(L) - \mathrm{info}(S)$ is exactly the residual conditional entropy of the label given the reading, and each new dial refines the partition, so the deficit decreases. The conjecture is that when each added dial separates a constant fraction of the still-confused pairs, the deficit decays geometrically:
$$H(L) - \mathrm{info}(S \cup \{i\}) \;\le\; (1-c)\,\big(H(L) - \mathrm{info}(S)\big).$$
Our four-dial measurement — $8.2246$ bits against a $9.5276$ ceiling — is precisely a measurement of that rate, and the theory currently gives the monotone decay but not its speed.

A second question is rigidity of the *order profile*: given a target list of how much synergy should appear at each order, can one always build a battery of binary dials realizing it, subject only to the total being under the label entropy? The parity family realizes the extreme profiles; the general construction is open.

Either way, the lesson of the four dials stands. Ask each of them what it knows and you will be told, truthfully, "almost nothing." Ask them together and they will tell you nearly everything there is to know.
