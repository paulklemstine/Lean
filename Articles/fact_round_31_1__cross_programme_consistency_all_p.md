# When Every Check Passes: What Can a Table of Numbers Actually Promise?

*An audit of recorded information values can only ever fail to find a mistake. A handful of iron laws of information theory turn "all checks pass" into a statement with real content — and one of those laws caught a mislabelled column.*

---

## A ledger of bits

Imagine a long research programme, spread over dozens of papers, that keeps measuring the same kinds of quantities: how many *bits* of information some observable carries about some target. In the programme we have in mind the sample points are prime numbers, and the observables — we will call them **dials** — record how each prime splits in a fixed number field. Some dials come from fields whose symmetry group is $S_3$ (the symmetries of a triangle), others from fields with symmetry group $A_4$ (rotations of a tetrahedron) or $D_4$ (symmetries of a square). A dial is read on each prime, and we ask how much it tells us about a fixed **label**, the thing we are trying to predict.

Over twenty-seven papers the programme wrote such numbers into its ledger again and again. Then came the inevitable accountant's question: *do the numbers agree with each other?*

The audit picked eight quantities that had been recorded more than once and compared the recordings:

| quantity | first recording | second recording | spread |
|---|---|---|---|
| $S_3$ field "a" — marginal | $1.0012$ | $1.0012$ | $0.0000$ |
| $S_3$ field "b" — marginal | $1.0008$ | $1.0012$ | $0.0004$ |
| $A_4$ field — marginal | $0.4733$ | $0.4733$ | $0.0000$ |
| $D_4$ field — marginal | $1.4302$ | $1.4342$ | $0.0040$ |
| $S_3$a $\times$ $S_3$b — joint | $2.1314$ | $2.1314$ | $0.0000$ |
| $A_4 \times D_4$ — joint | $1.9125$ | $1.9125$ | $0.0000$ |
| $S_3$a $\times$ $S_3$b — overlap | $0.9919$ | $0.9919$ | $0.0000$ |
| four-field battery capacity | $8.2246$ | $8.2246$ | $0.0000$ |

All values are in bits. Zero inconsistencies; the largest disagreement is $0.0040$ bits, about four thousandths of a coin flip. Verdict: **all checks pass**.

That sounds reassuring. But pause for a moment and ask what it actually *means*. Two recordings that agree could both be wrong in the same way. A recording that agrees with itself could still be impossible. Comparing numbers against each other only detects *disagreement*; it cannot detect *nonsense*. To say anything stronger you need laws — statements that every honest table of information values must satisfy, whatever the underlying data happen to be. This article is about those laws.

## The setting: counting, not measuring

Everything here lives on a finite sample. Take a finite set $\Omega$ of $N$ points — say, the primes up to some bound — each with weight $1/N$. A **statistic** is any function $f$ from $\Omega$ to some set of values. Its **entropy** is the familiar Shannon quantity

$$H(f) = -\sum_{a} \frac{c_a}{N}\log\frac{c_a}{N},$$

where $c_a$ is the number of sample points on which $f$ takes the value $a$. Everything is just counting. Reading two statistics together gives the pair $(f,g)$, with its own entropy. The **mutual information** between the label $L$ and a statistic $f$ is

$$I(L;f) = H(L) + H(f) - H(L,f),$$

and the **residual entropy** of $f$ given $L$ is $H(f\mid L) = H(f,L) - H(L)$: the uncertainty in the dial that the label cannot explain. Dividing by $\log 2$ converts natural units into bits.

A **battery** is a finite collection of dials $F_i$. For any sub-collection $S$ we may read all dials in $S$ at once; the **capacity** of $S$ is how much that joint reading tells us about the label:

$$\mathrm{cap}(S) = I(L;\ F|_S).$$

The "four-field battery capacity" of $8.2246$ bits in the table is exactly such a number, for a battery of four dials.

## Law one: the capacity lattice

The first family of laws describes how capacity behaves as a battery grows.

**Monotonicity.** If $S \subseteq T$ then $\mathrm{cap}(S) \le \mathrm{cap}(T)$. Adding dials never destroys information. The reason is the *data-processing principle*: the reading of $S$ is a function of the reading of $T$ (just forget some coordinates), and post-processing can only lose information.

**Floor and ceiling.** The empty battery reads a constant, so $\mathrm{cap}(\varnothing) = 0$. And no battery can tell you more about the label than the label's own entropy: $\mathrm{cap}(S) \le H(L)$.

**The incremental law.** Here is the less obvious one. Add a single dial $j$ to a battery $S$. The capacity can go up — but by at most the entropy of the new dial:

$$\mathrm{cap}(S \cup \{j\}) \le \mathrm{cap}(S) + H(F_j).$$

Intuitively, a dial cannot carry more news than it has room for. Apply this one dial at a time and you get the general form: adjoining a whole set $T$ of dials raises capacity by at most $\sum_{i\in T} H(F_i)$. In particular (starting from the empty battery) the capacity of any battery is at most the sum of its dials' entropies.

Put together, these give a *sandwich* that any recorded pair of nested batteries $S \subseteq T$ must satisfy:

$$0 \;\le\; \mathrm{cap}(S) \;\le\; \mathrm{cap}(T) \;\le\; \min\Big(H(L),\ \mathrm{cap}(S) + \sum_{i \in T\setminus S} H(F_i)\Big).$$

This is the **capacity-lattice consistency theorem**. A table that violated it would be impossible — not merely suspicious, but impossible for *any* sample.

## Law two: synergy, and its sandwich

The most interesting quantity in the table is hidden. The two $S_3$ dials have marginals $1.0012$ bits each, but together they carry $2.1314$ bits. That is *more* than the sum. The extra

$$\mathrm{Syn}(f,g) = I(L;f,g) - I(L;f) - I(L;g)$$

is called the **synergy** of the two dials about the label. Here it is $2.1314 - 2.0024 = 0.1290$ bits.

Is positive synergy weird? Not at all, and the cleanest way to see this is an exact identity:

$$\mathrm{Syn}(f,g) = I(f;g \mid L) - I(f;g).$$

Synergy is the difference between how much the two dials know about *each other once the label is known*, and how much they know about each other outright. If the dials are redundant — they overlap — the second term dominates and synergy is negative. If the dials look independent but become entangled once you know the label, synergy is positive. This quantity is known in the literature as *interaction information*, and the identity above is a short piece of algebra once everything is written in terms of entropies.

How big can synergy be? The **synergy sandwich** answers:

$$-\min\big(I(L;f),\,I(L;g)\big) \;\le\; \mathrm{Syn}(f,g) \;\le\; \min\big(H(f\mid L),\,H(g\mid L)\big).$$

The lower bound says the pair knows at least as much as its better member (monotonicity again). The upper bound says that synergy must be *paid for* by residual entropy: the "spare room" in a dial that the label does not explain is the only place where extra joint information can live.

## The XOR battery: a secret split in two

Is the upper bound ever reached? Yes — by the oldest trick in cryptography.

Flip two fair coins, $x_1$ and $x_2$. Let the label be their exclusive-or, $L = x_1 \oplus x_2$ (heads if they differ). Let the two dials be the coins themselves. Then:

- Knowing $x_1$ alone tells you **nothing** about $L$: $I(L;x_1) = 0$.
- Knowing $x_2$ alone tells you **nothing** either: $I(L;x_2) = 0$.
- Knowing both tells you **everything**: $I(L;x_1,x_2) = 1$ bit.

The synergy is one full bit, and the residual entropies are $H(x_1\mid L) = H(x_2\mid L) = 1$ bit. The upper bound is attained exactly. This is the principle behind *secret sharing*: split a secret into two shares, each individually useless, jointly decisive. It also proves the synergy sandwich cannot be improved in general.

The XOR battery delivers a second lesson. In optimisation, a set function $\phi$ is *submodular* if adding an element helps less when you already have more — the mathematical form of "diminishing returns". Submodularity is what makes greedy algorithms provably good for choosing which sensors to deploy, which features to measure, which dials to read. For the XOR battery, the second difference

$$\mathrm{cap}(\{1,2\}) - \mathrm{cap}(\{1\}) - \mathrm{cap}(\{2\}) + \mathrm{cap}(\varnothing) = \log 2 > 0.$$

The second coin is worth nothing on its own and everything once you have the first. **Battery capacity is monotone but not submodular.** Picking dials greedily, one at a time by individual merit, carries no general guarantee — you could skip exactly the pair that matters.

### XOR in the primes

This is not merely a toy. Take the cubic polynomials $x^3 - x - 1$ and $x^3 + x + 1$, which define number fields with symmetry group $S_3$ and discriminants $-23$ and $-31$. For each prime $p$, count the roots of each polynomial modulo $p$: $0$, $1$ or $3$. Those counts are two dials. For the label, take the product of the two Legendre symbols $\left(\frac{-23}{p}\right)\left(\frac{-31}{p}\right)$. Each root count determines its own Legendre symbol (it detects whether the prime's Frobenius permutation is even or odd) — but says almost nothing about the *other* field's symbol, so almost nothing about the product. Over the $546$ primes up to $4000$ (excluding $2, 3, 23, 31$), a direct count gives about $0.002$ bits for each dial alone, $0.997$ bits for the pair, and a synergy of $0.993$ bits — an XOR battery made by arithmetic. (This label is our own choice, made to show the phenomenon; it is not one of the programme's recorded rows.)

## The critic's catch: a column that could not be entropies

Now back to the ledger — and the most useful finding of the audit.

Entropy obeys a law that information does not: **subadditivity**. For any two statistics,

$$H(f,g) \le H(f) + H(g).$$

Two dials together are never more uncertain than their uncertainties added up. So if a table lists marginals $a$ and $b$ and a joint $c$ that are all supposed to be *entropies*, it must satisfy $c \le a + b$. Call this the **entropy-column obstruction**.

Look at the $S_3$ row: marginals $1.0012$ and $1.0012$, joint $2.1314$. Since $2.1314 > 2.0024$, **no pair of statistics on any finite sample can have these as its marginal and joint entropies.** The numbers are perfectly consistent with each other, recording to recording — and yet, read as entropies, they are impossible.

Read as *informations about a label*, however, they are completely admissible: the synergy sandwich allows the joint to exceed the sum, with the excess $0.1290$ bits funded by the dials' residual entropy. So the law does real work. It settles what kind of numbers the "joint" column contains: trace informations, not entropies. (The $A_4 \times D_4$ row tells the same story more quietly: $1.9125 > 0.4733 + 1.4342 = 1.9075$.) A pure consistency audit, comparing numbers only with each other, could never have told you that.

Checked against every necessary law, the recorded table passes:

- every marginal is at most the corresponding joint ($1.0012 \le 2.1314$; $0.4733$ and $1.4342 \le 1.9125$);
- both two-field joints are at most the four-field capacity ($2.1314,\ 1.9125 \le 8.2246$);
- the four-field capacity is at most the label-entropy ceiling of $9.5276$ bits used in the audit;
- both implied synergies ($+0.1290$ and $+0.0050$ bits) respect the lower bound $-\min$;
- every spread is at most $0.0040$ bits.

## A prediction you can go and test

The best laws do more than forbid; they predict. Sum the synergy sandwich over a whole battery and you get the **battery synergy budget**:

$$\mathrm{cap}(T) - \sum_{i\in T} I(L;F_i) \;\le\; \sum_{i \in T} H(F_i\mid L).$$

Whatever a battery knows beyond the sum of its individual dials must be financed by the dials' residual entropies. The proof is almost a one-liner once you notice that every dial's entropy splits as $H(F_i) = I(L;F_i) + H(F_i\mid L)$ and that capacity is at most the sum of dial entropies.

Feed in the four-field battery: capacity $8.2246$ bits, while the four dials' individual informations add up to $3.9099$ bits. The budget then **forces**

$$\sum_{i} H(F_i\mid L) \;\ge\; 8.2246 - 3.9099 = 4.3147 \text{ bits}.$$

That is a statement about a quantity *nobody has recorded yet*. Measure the four residual entropies; if they add up to less than $4.3147$ bits, some number in the ledger is wrong. A capacity recording has become a falsifiable claim about something else.

## What "all checks pass" now means

Before these laws, "all checks pass" meant: *repeated recordings agree to within $0.004$ bits.* That is a statement about bookkeeping.

After them, it means something sturdier: the recorded marginals, joints and capacity are simultaneously consistent with **every** necessary law of finite information — monotonicity, the incremental bound, the label ceiling, the synergy lower bound — and one column has been correctly identified as informations rather than entropies, because as entropies it would be impossible. A new, independent measurement has been predicted.

There are honest limits. Necessary laws can refute a table but never certify it; a table can satisfy every inequality and still be wrong. The "overlap" row, for instance, is not constrained by any of the laws discussed here. And the question of whether the *actual* four-field battery, not just the toy XOR, fails submodularity remains open — as do sharper questions, like how much a single changed prime can move an empirical information value.

But the shift in perspective is the point. An audit that compares numbers to numbers is a mirror. An audit that compares numbers to laws is a window.
