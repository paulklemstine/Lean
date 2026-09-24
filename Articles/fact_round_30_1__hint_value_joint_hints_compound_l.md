# Two Useless Clues, One Perfect Answer: How Hints Compound — and Why They Stop

*Two clues that tell you nothing separately can, taken together, tell you everything. A small result about factoring pins down exactly how far that effect goes: one bit per prime field, never more. The reason is a quadratic equation from school, and whether it has a solution is decided by a Legendre symbol.*

---

## A puzzle with two envelopes

Say someone has picked two numbers $p$ and $q$ and told you their product $N = pq$. You want to learn some secret label $T$ attached to the choice. Maybe $T$ says which of the two numbers is the smaller, or maybe it is some other property of the pair.

Now two sealed envelopes are offered. One holds the **sum** $s = p + q$. The other holds the **gap** $d = q - p$. How much is each one worth, and how much are both worth together?

A natural first guess is that the values just add up: open both envelopes and you get the value of the first plus the value of the second. Information theory warns early on that this guess is often wrong, in both directions. Two clues can be **redundant**, each telling you the same thing, so together they are worth less than the sum. Two clues can also be **synergistic**, each worthless alone but decisive together. The textbook case is a secret bit $T = A \oplus B$ hidden as the exclusive-or of two coin flips. Seeing $A$ alone tells you nothing about $T$, and neither does seeing $B$ alone. Seeing both tells you everything.

A large numerical experiment on factor residues (more on this below) reported that the sum and gap envelopes behave like the synergistic case, and strongly so. The experiment's verdict was that *hints compound*, and compound "like capacities", meaning without any evident limit.

This article is about what happens when that claim is tested exactly. The answer is that hints do compound. They compound by **exactly one bit per prime field** and no more, and that bit has a precise arithmetic identity: it is the answer to *"which square root?"*

## The setting: arithmetic that wraps around

The experiment does not work with ordinary integers. It works with **residues**, numbers reduced modulo a prime $p$, the way a clock reduces hours modulo 12. Residues are what cryptographers, error-correcting codes and number-theoretic algorithms actually handle. The residues modulo an odd prime form a *field*: you can add, subtract, multiply, and divide by anything nonzero. In particular you can divide by $2$.

Here is the setup in plain terms. We have a **battery**, a finite list of samples. Each sample carries a secret label $T$ and a pair of factor residues $(p, q)$. From each pair we can compute four **views**:

- the **product view** $N = pq$, which is the "hint-free" channel, the thing you are always given;
- the **sum view** $s = p + q$;
- the **gap view** $d = q - p$;
- the **joint view** $(s, d)$, both envelopes opened.

Since $2$ can be inverted, the joint view is as good as knowing $p$ and $q$ themselves: $p = (s-d)/2$ and $q = (s+d)/2$.

We measure how much a view tells us about the label with **mutual information**, counted in bits. For a finite population with every sample equally likely, the mutual information $I(T; V)$ between the label $T$ and a view $V$ is how much the uncertainty about $T$ goes down once $V$ is known. It is always between $0$ and the entropy $H(T)$ of the label.

## Measuring a hint the right way

Here is the key modelling choice. A hint is only worth what it adds **on top of what you already know**. You always hold $N$, so the value of the sum envelope is not $I(T; s)$ but the *conditional* gain

$$\text{sum hint} = I(T;\, N, s) - I(T;\, N).$$

In the same way,

$$\text{gap hint} = I(T;\, N, d) - I(T;\, N), \qquad \text{joint hint value} = I(T;\, s, d) - I(T;\, N).$$

The **hint synergy** is what the two envelopes are worth together, minus what each is worth alone:

$$\text{synergy} = \text{joint hint value} - \text{sum hint} - \text{gap hint}.$$

A positive synergy means the hints compound. A negative synergy means they overlap.

Three basic facts follow directly from the definitions. Each hint is non-negative, because more data never hurts. Each single hint is at most the joint hint value, because the joint view contains both. And the synergy is never more negative than minus the smaller of the two hints, so the overlap is bounded.

## First surprise: compounding is not a law

The slogan "hints compound" has an immediate counterexample. Work modulo $5$ and take a battery with just two samples, $(p, q) = (1, 1)$ with label $0$ and $(p, q) = (2, 3)$ with label $1$. Both have product $N \equiv 1$, so the product view tells us nothing. Their sums are $2$ and $0$, and their gaps are $0$ and $1$, so the sum alone already separates them, and so does the gap alone. Each hint is worth a full bit, and so is the joint view. The synergy is

$$1 - 1 - 1 = -1 \text{ bit}.$$

The two envelopes are perfectly redundant.

Now go to modulus $7$ and take four samples, all on the "hyperbola" $pq \equiv 1$:

$$(2,4),\quad (4,2),\quad (3,5),\quad (5,3),$$

labelled $0, 1, 1, 0$. The label records which way round the factors come. Check the views. The first two samples have the same sum ($6$) but different labels, and so do the last two (sum $1$), so the sum hint is **zero**. The gaps are $2, 5, 2, 5$, and each gap value is shared by one sample of each label, so the gap hint is also **zero**. The joint view $(s, d)$ separates all four samples, so the joint hint value is **one full bit**. The synergy is

$$1 - 0 - 0 = +1 \text{ bit}.$$

These two small batteries settle the qualitative question. **Hint synergy has no sign.** Hints can compound and hints can collide, and no general law of superadditivity or subadditivity holds.

## Second surprise: a hard ceiling of one bit

The mod-$7$ example gives exactly one bit of synergy. Could a cleverer battery, with more samples, more labels, or a larger prime, give two bits, or ten? If hints compounded "like capacities", the answer would be yes.

The answer is no. This is the **One-Bit Law**:

> **Over the residues modulo any odd prime, the conditional hint synergy of any battery is at most one bit.** More precisely, it is at most $1 - \max(\text{sum hint}, \text{gap hint})$.

The reason is a school identity:

$$d^2 = (q-p)^2 = (p+q)^2 - 4pq = s^2 - 4N.$$

Suppose you already know $N$ and $s$. Then you know $d^2$, so $d$ is fixed **up to sign**. The only thing the joint view can add on top of the hinted sum view $(N, s)$ is a choice between $d$ and $-d$. That choice is a single yes-or-no answer, and a yes-or-no answer carries at most one bit.

To turn this into mathematics you need a way to *name* the sign. Modulo an odd prime, call a residue "low" if its standard representative lies in the lower half $\{0, 1, \dots, (p-1)/2\}$ and "high" otherwise. For a nonzero residue $d$, exactly one of $d$ and $-d$ is low. So "is $d$ low?" separates the two square roots of $d^2$. Given $(N, s)$ plus this one bit, you recover $d$ exactly.

A general principle from information theory then finishes the argument: **if a view refines another view up to one extra yes-or-no answer, it carries at most one bit more information about anything.** So the joint hint value exceeds the sum hint by at most one bit. By the symmetric argument ($s^2 = d^2 + 4N$, so knowing $N$ and $d$ fixes $s$ up to sign), it also exceeds the gap hint by at most one bit. Subtracting both hints then gives the ceiling.

The mod-$7$ battery shows the ceiling is reached. The bound also gives an **all-or-nothing law**: synergy equals one full bit only when *both* single hints are exactly worthless and the joint value is exactly one bit. Two individually useful hints can never also compound to the maximum.

## Third surprise: the ceiling counts fields

This seemed to put the experiment in trouble. It reported a joint hint value of $+2.4291$ bits against a per-dial total of $+1.0288$, which is a synergy of about $+1.40$ bits. That is **above** the one-bit ceiling.

The explanation is in the modulus. The experiment did not work modulo one prime. It worked modulo a product of two primes, combined through the Chinese Remainder Theorem. Residues modulo $p_1 p_2$ behave like *pairs* of residues, one modulo $p_1$ and one modulo $p_2$. In each coordinate $d$ is fixed up to its own independent sign. So there are four possible sign patterns $(\pm, \pm)$, not two, and naming one takes two bits.

The general theorem is the **Orientation-Bit-per-Field Law**:

> **Over a product of $k$ odd prime fields, the conditional hint synergy of any battery is at most $k$ bits.**

It comes from a single principle. If the ring of residues has a "sign selector" with $F$ possible values, meaning a way to tell apart the square roots of every square using $F$ labels, then the synergy is at most $\log_2 |F|$ bits. Selectors multiply across products of rings, so $k$ prime fields give $2^k$ sign patterns and a ceiling of $\log_2 2^k = k$ bits.

The two-field ceiling is also reached exactly. Take the product of two copies of the mod-$7$ battery: sixteen samples over pairs of residues mod $7$, labelled by the *pair* of orientation bits. On this battery the sum hint and the gap hint are each **exactly zero**, and the joint hint value is **exactly two bits**. The synergy is $+2$.

So the experiment's $+1.40$ bits is **impossible over a single prime field and possible over two.** Taken literally, the claim that "hints compound like capacities" is too strong. Capacities in the earlier sense can grow without a ceiling. Hints hit a hard wall set by the number of fields in the modulus. A careful reading of the $+1.40$ also has to note that the experiment's per-dial rows need not be the conditional hints defined here. On a two-field modulus the conditional synergy can reach $2$ bits anyway, so the measured figure fits comfortably under the proved law.

## The bit has a name: it is a quadratic residue

So far the "orientation bit" has been an abstract yes-or-no. The last piece of the story gives it a concrete identity.

Fix a **cell** of the table: a product value $N$ and a sum value $s$. How many ordered factor pairs $(a, b)$ with $ab = N$ and $a + b = s$ does it contain? Substitute $b = s - a$. The condition $a(s - a) = N$ can be rearranged, using the invertibility of $2$, into

$$(2a - s)^2 = s^2 - 4N.$$

This is the quadratic formula in disguise. The number $\Delta = s^2 - 4N$ is the **discriminant** of the cell, and the factorisations of the cell correspond one-to-one to the **square roots of $\Delta$**. So there are three kinds of cell:

- if $\Delta$ is a **nonzero square**, the cell holds **two** factorisations, $(a, b)$ and $(b, a)$, and carries one orientation bit;
- if $\Delta = 0$, it holds exactly **one** factorisation, the "square" pair $a = b$, and no bit;
- if $\Delta$ is a **non-square**, it holds **none** at all.

Modulo a prime $p$ there is a classical way to decide which case you are in: the **Legendre symbol** $\left(\frac{\Delta}{p}\right)$, which is $+1$ for nonzero squares, $0$ for zero and $-1$ for non-squares. Euler's criterion computes it as $\Delta^{(p-1)/2} \bmod p$. The result is the **Legendre Law for Orientation**:

> **A cell $(N, s)$ with nonzero discriminant hosts two distinct factorisations, and hence an orientation bit, if and only if $\left(\frac{s^2 - 4N}{p}\right) = 1$.**

In the mod-$7$ compounding battery, the cell $(N, s) = (1, 6)$ has discriminant $36 - 4 = 32 \equiv 4 = 2^2$. That is a nonzero square, and the cell holds exactly the two pairs $(2,4)$ and $(4,2)$ whose orientation the label encodes. The cell $(N, s) = (1, 0)$ has discriminant $-4 \equiv 3$, and $3$ is not a square mod $7$. That cell holds no factorisation at all, so no battery supported there can compound.

Several consequences for information follow:

- **No orientation, no compounding.** If the hinted sum view $(N, s)$ already determines the gap, the joint view adds nothing to it. The joint hint value equals the sum hint, and the synergy is $\le 0$.
- **Squares cannot compound.** A battery made entirely of square factorisations $p = q$ has gap $0$ everywhere. Its orientation bit is empty and its synergy is $\le 0$.
- **Compounding needs a residue cell.** If the joint view beats the sum hint by any positive amount, some sample must have a nonzero gap $d$. Its cell then has discriminant $d^2 \neq 0$, which is a nonzero square.

Counting the cells modulo $7$ gives a tidy picture: of the $49$ cells, $21$ are residue cells with two factorisations, $7$ have zero discriminant and one factorisation, and $21$ are non-residue cells with none. (For each fixed $s$, the map $N \mapsto s^2 - 4N$ runs through every residue once, so this half-and-half split holds for every odd prime.)

So the phrase "hints compound" turns out, after all the information-theoretic bookkeeping, to be a statement about whether a quadratic congruence can be solved.

## Why it matters

**It is a clean example of synergy with a ceiling.** Synergy between information sources shows up in neuroscience, genetics, machine-learning feature selection and cryptanalysis, and it is often measured without any theoretical upper limit to compare against. Here the ceiling is exact, reachable, and has a structural explanation: the size of the sign group $\{\pm 1\}^k$ of the modulus.

**It connects directly to factoring.** Knowing $N$ together with $p+q$, or $N$ together with $q - p$, is exactly the extra information that makes factoring easy. Over the integers, $N$ and $s$ determine $p$ and $q$ through the quadratic formula; this is the idea behind Fermat's method of writing $N$ as a difference of squares. The result says that modulo primes the leftover ambiguity is *exactly* the choice of square root, one bit per prime, and nothing else.

**It is a lesson about measurement.** The same experiment also flagged a strange statistic: a "which-factor" signal of $0.9663$ bits in the $(s, d)$ view. That figure comes from about $508{,}000$ residue-pair cells estimated from only $30{,}000$ samples, a regime in which naive plug-in estimates of information are badly biased upward. Nothing here depends on that number, and it was deliberately left uninterpreted. There is also a structural reason for suspicion: $s$ and $d^2$ do not change when $p$ and $q$ are swapped, so any genuine "which-factor" leak would have to depend on orientation, and would be notable in its own right. The proper next step is a permutation test against a null model. Exact theorems like the ones above are what let us tell a real effect from an estimation artefact.

## What remains open

Three questions are left open:

- **Rings with extra square roots.** Modulo $9$, the equation $d^2 = 0$ has three solutions, $0$, $3$ and $6$. The natural conjecture is that the synergy ceiling over a finite ring is $\log_2$ of the largest number of square roots of any element. Modulo $9$ that would be $\log_2 3 \approx 1.585$ bits, strictly more than one bit on a single prime-power modulus.
- **Every number of fields.** The $k$-bit ceiling is proved for all $k$, and reached for $k = 1$ and $k = 2$. The $k$-fold product of the mod-$7$ battery should reach it for every $k$. What is missing is a short lemma saying that entropy adds up over product populations.
- **Population-weighted density.** Exactly half of the nonzero-discriminant cells are residue cells. How much of a *real* battery's population sits over residue cells, and how does that control the synergy you actually observe? Answering this would involve character sums of the kind that count points on curves over finite fields.

The short version is that hints do compound, the sum and gap together can be worth far more than either alone, but only up to the number of independent square-root sign choices in the modulus. Past that, extra hints only overlap.
