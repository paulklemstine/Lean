# Fifteen Number Fields, One Measurement, and an Error Smaller Than a Thousandth of a Bit

*How a whole table of prime-number "channels" was measured again in one pass, and why the single number that looked wrong was never really there.*

---

## A laboratory made of primes

Pick a polynomial with integer coefficients, for example $x^3 - x - 1$. Then pick a prime $p$ and ask how the polynomial factors when you only do arithmetic modulo $p$.

Modulo $2$, the polynomial has no roots at all, so it stays irreducible. Modulo $5$ it has exactly one root, so it breaks into a linear factor times a quadratic. Modulo $59$ it has three roots and splits completely. Every prime that does not divide the discriminant (here $-23$) gives one of these three outcomes. Which one you get looks almost random from prime to prime.

It is not random, and the reason is one of the great structures of number theory. Every such polynomial has a **Galois group** $G$, a finite group that permutes its roots. Each prime $p$ picks out an element of $G$, its **Frobenius element** (strictly speaking a conjugacy class), and the way the polynomial factors mod $p$ is the cycle structure of that permutation. A 3-cycle means "no roots", a transposition means "one root plus a quadratic", and the identity means "three roots".

The **Chebotarev density theorem** describes how often each permutation turns up. As $p$ runs through the primes, the Frobenius elements become *equidistributed*: each element of $G$ appears with frequency $1/|G|$. The primes behave like a perfectly fair die whose faces are the elements of the Galois group.

This gives a remarkable laboratory. Choose a few million primes, and you are rolling that die a few million times.

## Dials, types, and the channel between them

The research programme behind this article asks an information-theoretic question about this die. Each prime can be observed in two quite different ways.

1. **The type**, written $T$. This is how the polynomial factors mod $p$: how many roots there are mod $p$, how many more appear over the field with $p^2$ elements, and so on. Type is a "non-linear" observation, since you have to actually factor something.

2. **The dial**, written $r$. This is just the residue of $p$ modulo some fixed number $N$. You can read it off with one division and never touch the polynomial.

How much does the cheap observation tell you about the expensive one? Information theory has an exact answer: the **mutual information** $I(r;T)$, measured in bits. It is the average amount by which knowing $r$ reduces your uncertainty about $T$. We call it the **type channel**.

Here the deep theory comes in. **Class field theory** says that the residue of $p$ "sees" exactly one part of the Frobenius element, namely its image in the *abelianization* $G/G'$, where $G'$ is the commutator subgroup. Everything abelian about the Frobenius can be read off from congruences, and nothing else can. For $x^3 - x - 1$, with group $S_3$, the abelianization is just the sign of the permutation. Whether $p$ is a square modulo $23$ tells you exactly whether the Frobenius is even (identity or 3-cycle) or odd (a transposition). The table below lists some primes $p$:

| $p$ | $p$ mod 23 a square? | roots of $x^3-x-1$ mod $p$ |
|---|---|---|
| 2 | yes | 0 (3-cycle) |
| 5 | no | 1 (transposition) |
| 59 | yes | 3 (identity) |

Because of this, the dial-type channel should have a **law value**, an exact number computed purely from the finite group. You take $G$ with the uniform distribution, read off the coset $gG'$ and the cycle type of $g$, and compute the mutual information
$$I_{\text{law}} = I(\,gG'\,;\,\text{type}(g)\,).$$

For $S_3$ the answer is exactly **1 bit**. The sign is determined by the cycle type, and the sign is a fair coin. For the dihedral group $D_4$ of the polynomial $x^4 - 2$ it is $\tfrac94 - \tfrac38\log_2 3 \approx 1.655639$ bits. For the alternating group $A_4$ it is $\log_2 3 - \tfrac23 \approx 0.918296$ bits. Over about 128 earlier studies, a whole **master table** of such values had been built up and compared with measurements on real primes, one field at a time.

## The audit: everything at once

Measurements made one at a time can drift. Each was done on a different day, with different code, a different random seed and a different range of primes. Small inconsistencies can pile up into a quiet folk belief that is slightly wrong. So the experiment described here did the obvious hard thing and **measured the entire master table again, simultaneously**:

- 15 canonical number fields,
- one protocol and one random seed,
- the same 295,946 unramified primes below $2^{22}$ for every field,
- law values computed fresh from explicit permutation groups, not copied from old papers.

Before looking at any data, the team wrote down a budget: every field had to land within $0.01$ bits of its law value.

**The result: the largest deviation in the whole table was $0.00048$ bits.** That is twenty times inside the budget, and no field was flagged. The roughly 128 earlier measurements are consistent with each other to about five ten-thousandths of a bit.

## Why "simultaneous" is allowed to mean anything

There is a subtle worry here. When you measure fifteen fields on the *same* primes, you have built one giant joint experiment. Could the fields interfere with each other? Could measuring $S_3$ and $D_4$ together leak information between them, or change the value each one reads?

The mathematics behind the audit answers this with three exact theorems. Each one says what a perfectly Chebotarev-distributed population *must* show.

**The thickening theorem.** Copy every element of the population the same number of times, so that each Galois element now carries $m$ points instead of one. No entropy changes, and no channel changes. In fact a stronger statement holds. If a population sits over the group $G$ so that each group element has the same number $m>0$ of points above it, then every observation that depends only on the Frobenius has exactly the same distribution as on $G$ itself. The experiment checked this directly with a "thickening control" and measured a change of $-0.00044$ bits, which is zero to within the precision of the run.

**The coprime flatness theorem.** Take two fields whose Galois extensions are linearly disjoint, meaning they share no common subfield beyond the rationals. By Chebotarev, the joint Frobenius is then uniform on the product $G_A \times G_B$. On a product population, *any* observation of the first factor and *any* observation of the second share exactly **zero** bits. The proof is one line of information theory: on a product, entropies add.

**Simultaneous-measurement invariance.** Put the first two theorems together and you get the statement the audit needed. In a joint measurement of two disjoint fields, each field's channel equals its own law value, and every cross-field channel is exactly zero. So measuring $S_3$ and $D_4$ together gives $1$ and $\tfrac94 - \tfrac38\log_2 3$, with no crosstalk at all. Measuring all fifteen at once is, in law, the same as measuring them one at a time.

## The fine-dial reduction: why the number of classes cannot matter

The central theorem of this work answers a question that had quietly bothered the programme. Real experiments use dials of very different sizes. Some read $p$ mod $4$, some read $p$ mod $23$, and one field, nicknamed **S3d**, used a sparse dial with about $229$ residue classes. Does a finer dial "see more"?

**Fine-dial reduction theorem.** Model the joint distribution of the residue class $r$ and the Frobenius $g$ as class field theory and Chebotarev predict. The pair $(g,r)$ is uniform on the set of pairs with $gG' = \varphi(r)$, where $\varphi$ is the Artin map from residue classes to the abelianization, and every coset receives the same number of residue classes. Then, for every type observation $T$,
$$I(r\,;\,T) \;=\; I(gG'\,;\,T).$$
However many residue classes the dial has, it carries **exactly** the coset law. Not approximately, and not in a limit: exactly.

The proof is a short and pleasing information-theoretic argument. The information flows along a chain
$$r \;\longrightarrow\; \text{coset} \;\longrightarrow\; T.$$
First, the residue determines its coset, so knowing $r$ is the same as knowing the pair (coset, $r$). Second, the chain rule splits the information in that pair into the coset's contribution plus whatever $r$ adds *given* the coset. Third, the coset's contribution equals its value on the bare group $G$; this is the uniform-projection theorem again. Fourth, once you fix a coset, the population over it is a *product*: Frobenius elements in that coset times the residues mapping to it. By coprime flatness, $r$ then adds exactly zero bits.

Three consequences follow at once.

- **Dial independence.** Two different uniform dials over the same field (say mod $23$ and mod $229$) always have identical law values.
- **The abelian cap.** No dial can ever exceed $\log_2 [G:G']$ bits. For $S_3$ that cap is $1$ bit.
- **Coprime residues add nothing.** Attach to the dial an extra residue modulo something coprime to the field. That residue is independent of Frobenius, and the channel stays exactly at the coset law. Coprime information is not just useless on its own; it adds nothing even on top of the informative dial.

## The one anomaly, and why it was never physics

The audit did find one thing that looked like a discrepancy. Field S3d, a cubic field with Galois group $S_3$, had a historical channel value of **$1.0078$ bits**. Its exact law is $1$. The simultaneous re-measurement gave **$0.9998 \pm 0.001$**.

Was the old number a sign of new structure, perhaps a hidden correlation or a broken dictionary between residues and splitting types? The theorems settle it.

**It is not a law value of anything.** By the fine-dial reduction, *every* uniform dial over $S_3$, of any size, has population channel exactly $1$ bit. So $1.0078$ exceeds every possible law value by more than $0.0075$ bits, while the new value $0.9998$ lies within three standard errors of the truth.

**It is what small samples do on sparse dials.** The "plug-in" estimator counts frequencies in a finite sample and computes the mutual information of those frequencies. On a fine dial it is biased *upwards*: with many sparsely filled residue classes, chance coincidences look like information. The extreme case can be proved. If a sample is so sparse that every residue class is seen at most once, the plug-in channel equals the full plug-in entropy of the types, *whatever the true law is*. Here is a three-prime example for $x^3-x-1$ with the mod-23 dial. The primes $2, 5, 59$ fall in three different residue classes and show three different splitting types (inert, one root, three roots). Their plug-in channel is
$$\log_2 3 \approx 1.585 \text{ bits},$$
well above the law cap of $1$ bit and above the historical $1.0078$. The same dial reads exactly $1$ bit on the Chebotarev population.

A quick simulation in the companion code backs this up. Draw $10{,}000$ ideal Chebotarev samples through a dial with $228$ classes; the average plug-in channel overshoots the law by about $0.008$ bits. That is the size of the historical anomaly. With the full $295{,}946$ primes the bias shrinks to a few ten-thousandths of a bit, which is exactly where the re-measurement landed.

The diagnosis is: **small-population plug-in bias on a sparse dial — not physics, and not dictionary drift.** As a further check, the dictionary itself was verified directly. For every unramified prime below $100$ (and, in the companion code, below $20{,}000$), $x^3-x-1$ has $0$, $1$ or $3$ roots mod $p$, and it has exactly one root precisely when $p$ is a non-square modulo $23$.

## Ten constants to six decimals

A simultaneous audit is only as good as its reference values. So the law constants were recomputed from explicit permutation groups and checked against the hand-derived six-decimal values. All ten agree to within $5\times 10^{-7}$:

| group | law value (bits) | closed form |
|---|---|---|
| $S_3$, $S_4$ | $1$ | sign fixed by cycle type |
| $A_4$ | $0.918296$ | $\log_2 3 - \tfrac23$ |
| $D_4$ | $1.655639$ | $\tfrac94 - \tfrac38\log_2 3$ |
| $V_4$ | $0.811278$ | $2 - \tfrac34\log_2 3$ |
| $C_4$ | $1.5$ | exact |
| $D_6$ (full cycle type) | $1.729574$ | |
| $D_6$ (coarse splitting) | $1.396241$ | |
| $S_3$ acting regularly | $1$ | |
| $F_{20}$ | $1.5$ | exact |

Certifying six decimals rigorously needs $\log_2 3$ pinned down tightly. Two integer inequalities do it, both coming from continued-fraction approximations:
$$2^{1054} < 3^{665} \qquad\text{and}\qquad 3^{2301} < 2^{3647},$$
which give $1054/665 < \log_2 3 < 3647/2301$, an interval of width about $6.5\times 10^{-7}$.

The newest row belongs to the **Frobenius group** $F_{20}$, the Galois group of $x^5 - 2$. It is made of the twenty affine maps $x \mapsto ax+b$ of $\mathbb{Z}/5$. Its law is exactly $\tfrac32$ bits, the same as the cyclic group $C_4$, which is five times smaller and abelian. This is a **law collision**: a single scalar channel cannot tell these two groups apart. The explanation is that a channel only "sees" the joint distribution of (coset, type). In $F_{20}$ the abelianization is $C_4$, and the only confusion is between the two cosets whose elements are all 4-cycles. That costs exactly half a bit of the available two bits.

## The catches: errors found before the results

Seven errors were caught in the experiment's code, and every one was caught *before* any result was unblinded. Two of them show how valuable exact constants are.

- **The $D_4$ generator.** Someone built "$D_4$" from a 4-cycle and the *adjacent* transposition $(0\,1)$. But a 4-cycle and an adjacent transposition generate all of $S_4$, all $24$ permutations, whose law is $1$ bit. The true $D_4$ contains the 4-cycle and the *diagonal* transposition $(0\,2)$, and its law is $1.655639$. The gap is more than half a bit, fifty times the budget, and the hand-derived constant exposed it immediately.
- **$F_{20}$ seeded as $C_5$.** The cyclic group $C_5$ has law $\log_2 5 - \tfrac85 \approx 0.722$, more than three quarters of a bit away from $F_{20}$'s $1.5$. A wrong seed cannot hide behind numbers that far apart.

## What it means

The headline is about trust. A long run of measurements on primes, spread over many papers, turns out to be consistent with itself to a few ten-thousandths of a bit when it is all redone at once. Each piece of that statement is backed by exact mathematics. Joint measurement does not change any channel. Disjoint fields cannot talk to each other. Fine dials cannot see past the abelianization. The one stubborn outlier is what a finite sample must produce on a sparse dial.

There is a further lesson about where structure hides. Primes are the most famous source of apparent randomness in mathematics, and Chebotarev's theorem says their randomness has exactly the shape of a finite group. The type-channel programme turns that shape into numbers measured in bits. This audit shows that the numbers can be measured, re-measured and certified to six decimals, so that what is left over is honest statistical noise and nothing hidden.

The open questions are now quantitative. Can the plug-in bias on a $K$-class dial be predicted cell by cell, in the manner of the classical Miller–Madow correction? Which pairs of groups collide, as $F_{20}$ and $C_4$ do? Those are questions for the next round of the laboratory.
