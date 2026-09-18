# The Arithmetic of Instruments: Why Two Measurements Are Never Just Two Measurements

## A bet that was lost at the first roll

Here is a hypothesis that sounds almost too reasonable to test.

You have a population of objects — think of pairs of integers $(p, q)$, or customers, or images — and a hidden **label** $L$ attached to each object that you would like to learn. You also have **dials**: simple instruments, each of which looks at an object and returns a small readout. One dial reports a residue modulo $31$. Another reports a residue modulo $23$. Each dial, on its own, tells you a certain number of bits about the hidden label. Call that number the dial's **capacity**.

Now bolt two dials together into a **battery** and read them at once. How much do you learn?

The obvious guess — so obvious it usually goes unstated — is: *the sum*. Two dials with unrelated moduli should be looking at unrelated aspects of the object. Their moduli are coprime; by the Chinese Remainder Theorem they slice the population along transverse directions; surely the information adds. Two independent questions, two independent answers, capacities $I_1 + I_2$.

This is exactly the hypothesis that was put on the table before the measurements were taken, and it was refuted at the very first pair. And the refutation was not a near miss in one direction. It failed in **both** directions at once:

| battery | joint capacity | additive prediction $I_1 + I_2$ | discrepancy $\Delta$ |
|---|---|---|---|
| a cubic dial at $31$ paired with a cubic dial at $23$ | $2.1314$ | $2.0024$ | $+0.129$ — **synergy** |
| a quartic dial at $9$ paired with a dihedral dial at $8$ | $1.9125$ | $1.9076$ | $+0.005$ — near-additive |
| two cubic dials sharing the discriminant $-23$ | $1.0104$ | $2.0024$ | $-0.992$ — **overlap** |

(All numbers in bits.)

The first row says the pair delivered *more* than the sum of its parts: $0.129$ bits materialised out of nowhere. The third row says a different pair delivered barely half of what the sum promised: almost a full bit evaporated. And the middle row shows a pair sitting, almost exactly, on the additive knife edge.

So the question is not "is the additive law true or false?". It is: **what exactly governs the discrepancy?** That question turns out to have a clean, exact, completely general answer — and the answer is the subject of this article.

## The bug in the reasoning, located precisely

The additivity argument has a hidden step. It says: dial one reads $p \bmod 31$, dial two reads $q \bmod 23$; these are independent draws, so their informations add.

But they are *not* independent draws. Both dials are pointed at **the same object**. When you sample an individual from the population, you sample *one* pair $(p,q)$, and both dials then read that same pair. Their readouts are statistically coupled through the population, and — crucially — reading both at once lets you see combinations, $p \bmod m_1$ **and** $q \bmod m_2$ simultaneously, that neither dial alone can express.

That coupling has two faces, and they push in opposite directions.

**Face one: shared channel.** If the two dials partly duplicate each other, then part of what the second dial tells you, the first already told you. The additive prediction double-counts that part. This is *overlap*, and it is why two cubic fields sharing the discriminant $-23$ behave almost like a single dial: they communicate through their common quadratic character, essentially the same channel, so the second one adds almost nothing. Nearly a full bit of the additive prediction is a bookkeeping error.

**Face two: conditional coupling.** Here is the subtle one. Two dials can be completely independent when you look at the whole population, and yet become tightly coupled once you fix the label. The canonical toy example: let each object carry two random bits, let dial $A$ read the first bit, dial $B$ read the second, and let the hidden label be their **parity**. Marginally, the two bits are independent — knowing one tells you nothing about the other. Marginally, each bit tells you nothing about the parity either: both capacities are exactly zero. But read them together, and you know the parity perfectly. One entire bit appears out of a pair of individually worthless instruments.

The reason, in the language above: *inside a parity class*, the two bits determine each other. Fix the label and the independence collapses into perfect dependence. That conditional dependence is precisely the raw material of synergy.

## The exact law

These two faces are not vague forces; they are two numbers, and the discrepancy is exactly their difference.

For a hidden label $L$ and two dials $f$ and $g$ read on the same finite population, define the **pair synergy**
$$\Delta(L; f, g) \;=\; I(L; (f,g)) \;-\; I(L; f) \;-\; I(L; g),$$
the amount by which the joint battery beats the additive prediction. (Positive means synergy; negative means overlap.)

> **Co-information Identity.** For any finite population, any label, and any two dials,
> $$\Delta(L; f, g) \;=\; I(f;g \mid L) \;-\; I(f;g).$$

In words: **the failure of additivity is exactly the amount by which the two instruments are more dependent inside the label classes than they are overall.** The term $I(f;g\mid L)$ is the conditional coupling — synergy's engine. The term $I(f;g)$ is the shared channel — overlap's engine. Synergy is the surplus of the first over the second.

The identity itself is a two-line computation once every quantity is written in terms of entropies: both sides expand into the same alternating sum of the entropies of $L$, of $f$, of $g$, of each pair, and of the triple $(L,f,g)$, and everything cancels. Its power is not in the difficulty of its proof but in what it makes inevitable.

And it makes the whole table inevitable. The additive argument amounts to setting *both* dependence terms to zero. That is two independent assumptions, not one, and coprimality of the conductors buys you at most one of them.

## Six consequences, and a knife edge

Once the identity is in hand, everything else follows by pushing on one term or the other.

**1. Conditional coupling is never negative.** Learning one dial's readout can only reduce your remaining uncertainty about the other, even inside a fixed label class: $I(f;g\mid L) \ge 0$. (This is the data-processing principle in disguise: a coarser view — the label alone — leaves at least as much residual uncertainty as the finer view of label-plus-first-dial.)

**2. Overlap is capped by the shared channel.** Combining (1) with the identity:
$$I_1 + I_2 - I(\text{joint}) \;\le\; I(f;g).$$
Two dials can double-count at most as much as their readouts have in common. The two $-23$ cubics can lose $0.992$ bits *only because their readouts share at least that much*. Overlap is not a mystery; it is a receipt.

**3. Genuinely independent dials can only help.** If $I(f;g) = 0$ — the situation the coprime-conductor hypothesis imagined — then $\Delta = I(f;g\mid L) \ge 0$. Independent readouts are *super*-additive, never sub-additive. So the hypothesis was not merely wrong: even on its own terms it predicted the wrong inequality. The observed $+0.129$ is the generic outcome, not an anomaly.

**4. Additivity is a coincidence, not a law.** Exact additivity holds **if and only if** $I(f;g\mid L) = I(f;g)$: the two forms of dependence must cancel to the last bit. That is a single equation on the joint distribution — a measure-zero condition. Nothing about coprime conductors forces it. This is why the pre-stated hypothesis failed at the first pair, and why the $+0.005$ row is best read not as "additivity confirmed" but as "a pair that happened to land near the knife edge".

**5. Overlap never exceeds the smaller marginal.** Because the joint battery is at least as informative as either dial alone, $\Delta \ge -\min(I_1, I_2)$. In the table, $I_1 = I_2 = 1.0012$ and the observed overlap is $0.992$ — the two $-23$ cubics realise $99.1\%$ of the theoretical maximum redundancy. They are, to within a percent, literally the same instrument.

**6. "Same subfield = same dial", made exact.** If the second dial's readout is a function of the first — if it is pure post-processing, as for two cubic fields sharing their quadratic resolvent — then the joint battery equals the first dial and the discrepancy is the *entire* marginal of the redundant dial: $\Delta = -I(L;g)$. Both bounds above are then attained simultaneously with equality.

There is also a ceiling on the other side: synergy cannot exceed the smaller of the two readout entropies. You cannot conjure more information than your instruments have room to encode.

## A four-element universe containing all three rows

Abstract inequalities are cheap; the interesting question is whether the whole *range* of behaviour is real. It is — and spectacularly so, in a universe with four inhabitants.

Take the population to be pairs of bits: four individuals. Install three dials. Dial $0$ reads the first bit. Dial $1$ reads the second bit. Dial $2$ is a deliberate duplicate of dial $0$ — the "shared conductor" instrument, same subfield, same dial. And consider two possible hidden labels: the **parity** of the two bits, and the **first bit** itself.

Then, all within this one tiny system:

- Against the parity label, dials $0$ and $1$ have capacity zero each and joint capacity one full bit: $\Delta = +1$, **pure synergy**, and the maximum the label entropy allows.
- Against the first-bit label, those same two dials are **exactly additive**: $\Delta = 0$. Dial $0$ carries the whole bit, dial $1$ carries nothing, the joint carries the bit.
- Against the first-bit label, dials $0$ and $2$ — the duplicate pair — give $\Delta = -1$: **total overlap**, an entire bit of double-counting.

And the identity accounts for each sign in the right way. In the $+1$ row the unconditional dependence of the two readouts is exactly zero while the conditional dependence is exactly one bit: all engine, no brake. In the $-1$ row it is precisely reversed — one bit of unconditional dependence, zero conditional dependence: all brake, no engine.

The conclusion is sharp. **No inequality of the form $\Delta \ge 0$ can hold, and no inequality of the form $\Delta \le 0$ can hold** — not even after fixing the population and the set of dials, since the same pair of dials flips from synergistic to additive when you merely change which label you are trying to learn. The space of batteries is neither additive nor comonotone. The measured table was not a collection of exceptions; it was a sample from a genuinely two-sided world.

## Widening: what happens with $k$ dials?

The natural worry is that the pair law is an artifact of pairs, and that arbitrary batteries obey something messier. They do not. The law widens exactly.

For a battery $S$ of any number of dials, the right generalisation of "how much do the readouts share?" is the **total correlation**
$$\mathrm{TC} \;=\; \sum_{i\in S} H(f_i) \;-\; H(\text{joint readout}),$$
the gap between the cost of transmitting all readouts separately and the cost of transmitting them together. It is zero exactly when the readouts are jointly independent. Measuring the same quantity *inside* the label classes gives the conditional total correlation $\mathrm{TC}(\cdot \mid L)$.

> **Width-$k$ Co-information Law.** For a battery of any width,
> $$I(L;\text{joint}) - \sum_{i\in S} I(L;f_i) \;=\; \mathrm{TC}(\text{readouts}\mid L) \;-\; \mathrm{TC}(\text{readouts}).$$

For two dials this is the identity we started with. Both correlation terms are nonnegative, proved by induction along the battery: adding one dial at a time, the joint code is subadditive, and it stays subadditive after conditioning on the label. Hence:

- **The $k$-dial overlap bound.** A battery of any width can undershoot the additive prediction by at most the total correlation of its readouts: $\Delta \ge -\mathrm{TC}$. Overlap is always paid for out of structure the dials share.
- **Independent dials are super-additive at every width.** If $\mathrm{TC} = 0$, then $\Delta \ge 0$. However wide the battery, truly independent instruments can only add value.
- **The bound is sharp at every width.** Take $k$ copies of one dial and read them against that dial's own readout: the total correlation is exactly $(k-1)H$ and the synergy is exactly $-(k-1)H$. The bound is attained with equality for every $k$ — the width-$k$ form of "same subfield = same dial", with $k-1$ redundant instruments each costing you a full marginal.

Synergy has a matching ceiling: it can never exceed the conditional total correlation. The joint readout can only extract what the label classes still correlate.

## Why this matters beyond the number fields

The setting that produced the measurements is arithmetic — number fields, conductors, splitting behaviour of primes — but nothing in the law is arithmetic. It holds for any finite population, any label, any instruments. And the same reasoning error it corrects is endemic wherever people combine information sources.

- **Feature selection.** The single most common heuristic in applied machine learning is to score each feature by how much it tells you about the target and keep the top $k$. The identity says this is doubly wrong: it double-counts redundant features (the overlap term) and it discards, with prejudice, features that are individually worthless but jointly decisive (the synergy term). The parity example is the minimal counterexample, and it is not exotic — XOR-like structure is everywhere in interactions, in cryptography, in genetics.
- **Sensor fusion and experiment design.** The overlap bound gives a budget: before combining instruments, measure how much their raw readouts share, and you have an a-priori ceiling on how much you can be double-counting. The marginal bound gives the cruder but always-available version: a redundant sensor costs you at most one full marginal.
- **Epistasis and interaction effects.** "Neither gene matters alone, both together matter" is the biologist's phrasing of $\Delta > 0$. The identity locates the effect precisely: conditional dependence inside the phenotype classes exceeding unconditional dependence in the population.
- **Ensemble diversity.** The folklore that ensembles want "diverse" members is the statement $\mathrm{TC} \approx 0$, and the theorem says what diversity buys you: super-additivity at every width, guaranteed.

## The moral

The prediction that failed was not careless. It was the natural consequence of an unexamined picture — dials as independent oracles, information as a substance that pours into a bucket. The correction is not "additivity fails sometimes". It is that the failure of additivity is *itself* an exact, computable quantity, with a name, a sign, two competing sources, and sharp bounds in both directions.

Two instruments pointed at the same world are never two independent instruments. Sometimes they say the same thing twice, and you must subtract. Sometimes they say, together, something neither could say alone, and you must add. The difference between those two amounts is the whole story — and now it is a theorem rather than an intuition.
