# Exactly One Bit: What Two Number Fields Know About Each Other

*Pick a prime and read it on two dials at once. How much does one dial tell you about the other? For dials that share a hidden square root, the answer is exactly one bit, no more and no less.*

---

## Dials that read primes

Take a cubic polynomial with integer coefficients, say

$$f(x) = x^3 - 5x - 5.$$

Pick a prime $p$ and ask how many solutions $f(x) \equiv 0 \pmod p$ has among the residues $0, 1, \dots, p-1$. A cubic can have three roots mod $p$, exactly one, or none. (Two is impossible for a cubic with no repeated factor: once two roots are known, the third is forced.) For $p = 13$ there is exactly one root ($x = 4$). For $p = 11$ there are none. For $p = 53$ there are three ($x = 17, 44, 45$).

Number theorists call this the **splitting type** of $p$, and write it as a little code:

- **111**: three roots. The prime splits completely into three pieces.
- **12**: one root. The prime breaks into a piece of size 1 and a piece of size 2.
- **3**: no roots. The prime stays in one piece of size 3.

Think of the polynomial as a **dial**. You feed it a prime and the needle settles on 111, 12 or 3. Feed it the next prime and the needle moves again, apparently at random. It is not random, of course: everything is fixed by arithmetic. But it behaves *statistically* like a random process with known odds. That fact is one of the crown jewels of number theory, **Chebotarev's density theorem**.

For a "generic" cubic, whose symmetry group is the full symmetric group $S_3$ on its three roots, the odds come from counting permutations. $S_3$ has six elements: the identity, two 3-cycles and three transpositions. The theorem says the dial shows 111 with frequency $1/6$, shows 3 with frequency $2/6$, and shows 12 with frequency $3/6$. The rule is that each prime gets assigned a "Frobenius" permutation, every permutation is equally likely, and the splitting type is just the cycle shape of that permutation.

In the language of information theory, one reading of the dial carries an entropy of

$$H(T) = \tfrac16\log_2 6 + \tfrac13\log_2 3 + \tfrac12\log_2 2 = \tfrac23 + \tfrac12\log_2 3 \approx 1.459 \text{ bits}.$$

## Two dials, one prime

Now build two dials from two different cubics and feed both the *same* prime. Do the needles move together?

That depends on how the two fields are related. Over the course of the research programme behind this work, two extremes had already been charted.

- **Unrelated dials.** If the two cubics have nothing in common (technically, their splitting fields are *linearly disjoint*), the needles are independent. Knowing one tells you nothing about the other: the shared information is $0$ bits.
- **The same dial in disguise.** If the two cubics define the *same* field (for instance one is a change of variables of the other), the needles always agree. The shared information is the full $1.459$ bits.

Between these two lay an open case. What if two cubics define *genuinely different* fields that still share some structure?

## The hidden square root

Every cubic carries a hidden square root. The **discriminant** of $x^3 + ax + b$ is $-4a^3 - 27b^2$. For $x^3 - 5x - 5$ it is

$$-4(-5)^3 - 27(-5)^2 = 500 - 675 = -175 = -7 \cdot 5^2.$$

The splitting field of the cubic, the smallest field containing all three roots, always contains $\sqrt{\text{discriminant}}$. Here that is $\sqrt{-175} = 5\sqrt{-7}$, so it contains the quadratic field $\mathbb{Q}(\sqrt{-7})$.

Now look at a second cubic, $x^3 - 3x - 5$. Its discriminant is $108 - 675 = -567 = -7 \cdot 9^2$. It is a different number and a different field, but **the same hidden square root**: $\sqrt{-567} = 9\sqrt{-7}$.

These two dials are partners. They do not define the same cubic field, yet both of them "contain" $\mathbb{Q}(\sqrt{-7})$. A scan of 56,410 cubics turned up exactly such pairs. One pair is the one above, over $\sqrt{-7}$. The other is $x^3 - 6x - 6$ (discriminant $-108 = -3\cdot 6^2$) with $x^3 - 3$ (discriminant $-243 = -3 \cdot 9^2$), both over $\sqrt{-3}$.

A small trap is hiding here. A discriminant is only a *field* invariant up to square factors: $-175$ and $-567$ look different but encode the same quadratic field. Arguing from raw discriminant values instead of from fields is a classic mistake, and this project caught it in the act.

## The answer: exactly one bit

Feed the first 6,053 primes above 7 to both dials of the $\sqrt{-7}$ pair and measure their mutual information. The result is

$$I(T_1 ; T_2) = 1.0000 \text{ bits}.$$

The $\sqrt{-3}$ pair gives $1.0000$ as well. Earlier runs gave $0.9998$, $0.9998$ and $1.0000$. Numbers this close to a whole number are begging for a theorem, and there is one.

> **The Partial-Overlap Law.** Two fields whose Galois groups share a quadratic quotient (that is, two fields containing the same quadratic subfield, with nothing else in common) have splitting-type dials that share **exactly one bit** of information. Furthermore, *no* readouts of the two fields whatsoever can share more than one bit.

Why one bit? Because one bit is precisely what a square root knows. Whether $p$ splits in $\mathbb{Q}(\sqrt{-7})$ is a yes-or-no question, and the two answers are equally likely. Both dials can see that answer: an S₃ cubic shows type 12 exactly when $p$ is inert in the quadratic field. So both dials learn the same coin flip. The surprise is that **this is the only thing they share.** Once you know the coin flip, the remaining randomness on the two dials is perfectly independent.

## The mechanism: a product hiding inside a fibre product

Here is the structural reason, and it is pretty.

When two fields $L_1$ and $L_2$ with Galois groups $G$ and $H$ share a subfield whose Galois group is $C$, the combined field $L_1L_2$ has Galois group

$$G \times_C H = \{(g, h) \in G \times H : \chi_1(g) = \chi_2(h)\},$$

where $\chi_1$ and $\chi_2$ restrict each symmetry to the shared subfield. This is the **fibre product**: all pairs of symmetries that *agree* on what they do to the common part. For two S₃ cubics sharing a quadratic field, $\chi$ is the sign of a permutation, and the fibre product consists of the pairs of permutations with equal signs. There are $3\cdot3 + 3\cdot 3 = 18$ of them: even with even, odd with odd. This agrees with a general order formula,

$$|C| \cdot |G \times_C H| = |G| \cdot |H|, \qquad 2 \cdot 18 = 6 \cdot 6.$$

Chebotarev's theorem now says that the *pair* of Frobenius permutations attached to a prime is uniformly distributed over these 18 pairs.

Slice the fibre product by the value $c$ of the shared character, and it falls apart into honest rectangles:

$$\{(g,h) \in G\times_C H : \chi_1(g) = c\} = \{g : \chi_1(g) = c\} \times \{h : \chi_2(h) = c\}.$$

On each slice the two coordinates are *independent*. All the coupling between the two dials is in the choice of slice. If you know which slice you are on, they have nothing more to say to each other.

That is the whole proof, in outline. Information theory adds the bookkeeping. Each dial determines the slice, because the splitting type tells you the sign. A short calculation with the chain rule for entropy then gives

$$I(T_1;T_2) = H(\text{slice}) = \log_2 |C|.$$

For a quadratic overlap $|C| = 2$, and $\log_2 2 = 1$.

## The fingerprint in the data

The theorem also predicts the full **joint table**: how often each pair of splitting types appears. Out of the 18 equally likely Frobenius pairs it gives:

| | dial 2: 111 | dial 2: 3 | dial 2: 12 |
|---|---|---|---|
| **dial 1: 111** | 1 | 2 | 0 |
| **dial 1: 3** | 2 | 4 | 0 |
| **dial 1: 12** | 0 | 0 | 9 |

In ratio form this is $1 : 2 : 2 : 4 : 9$, with four cells that are *structurally zero*: a prime can never be type 12 on one dial and something else on the other. For 6,053 primes the law predicts counts near 336, 673, 673, 1345 and 3027. The primes actually gave **329, 664, 658, 1369 and 3033**, and every one of the four forbidden cells was empty.

Two more features stand out:

- On the "odd" slice (the prime is inert in the quadratic field) both dials always read 12, so they agree $9/9$ of the time.
- On the "even" slice (the prime splits in the quadratic field) each dial reads 111 or 3 *independently*, with odds $1/3$ and $2/3$. They agree with probability $(1/3)^2 + (2/3)^2 = 5/9$, which is exactly the independent rate. No hidden correlation remains.

Overall the dials agree $14/18 = 7/9 \approx 0.778$ of the time. The primes measured $0.7816$ and $0.7785$.

## A ladder with three rungs

The two old extremes and the new middle case now line up as a ladder:

| Relationship | Combined group | Shared information | Type agreement |
|---|---|---|---|
| Coprime (nothing shared) | $S_3 \times S_3$, order 36 | $0$ bits | $7/18 \approx 0.389$ |
| Shared quadratic subfield | $S_3 \times_{C_2} S_3$, order 18 | **exactly 1 bit** | $7/9 \approx 0.778$ |
| Same field | diagonal, order 6 | $1.459$ bits | $1$ |

Each rung was checked on real primes. A coprime control pair, $x^3+x+1$ and $x^3-x-1$, gave $0.0001$ bits and agreement $0.3889$. The same cubic read twice gave $1.4559$ bits against a predicted $1.4591$.

The general law covers the whole ladder at once. Whatever the groups, two fields share at most $\log_2|C|$ bits, where $C$ is the Galois group of their common subfield. Readouts that can see $C$ achieve the maximum. If $C$ is trivial (coprime fields), no readouts share anything. If the two fields coincide, full Frobenius readouts share $\log_2|G|$ bits.

## A warning: information is not identity

Here is a twist that matters for anyone doing data analysis. Suppose you could only see the *sign* of each Frobenius, meaning whether $p$ splits in the quadratic field. This "residue-visible" signal is what a Legendre symbol computes. Then the partial-overlap pair and the same-field pair look **identical**: in both cases the two sign readings share exactly 1 bit.

So a mutual-information signature *alone* cannot tell "these two fields overlap partially" from "these two fields are the same". You need other statistics:

- **Type agreement**: $7/9$ for partial overlap versus $1$ for the same field.
- **Full-type redundancy**: $1$ bit versus $1.459$ bits.
- **Off-diagonal mass**: the fraction $4/18 = 2/9$ of primes where the types disagree, which is zero for the same field. The primes gave 34,375 disagreements against a predicted 34,307 in the full simulation.

There is also a statistical warning. Mutual information estimated by simply plugging observed frequencies into the formula is biased upward when the joint table is sparse. With only a couple of samples per cell, the estimate can be off by roughly half a bit even for independent variables. The shared-subfield table escapes this problem because it has only five non-zero cells. Larger joint tables need on the order of a hundred samples per cell, or an explicit model of the bias.

## Beyond cubics

None of this depends on cubics. The same law covers:

- **Any two symmetric groups.** Fields with groups $S_n$ and $S_m$ sharing a quadratic subfield have cycle-type dials that share exactly one bit, for every $n, m \ge 2$.
- **Cyclic quartic fields.** Two degree-4 cyclic fields sharing their quadratic subfield have group $C_4 \times_{C_2} C_4$ of order 8. Read the residue degree of a prime (1, 2 or 4). Each dial carries $3/2$ bits, the uncertainty left about one dial after reading the other is $1/2$ bit, and the difference is again $3/2 - 1/2 = 1$.
- **Three dials over one subfield.** Every pair shares exactly $\log_2|C|$ bits, and so does each dial with the other two *jointly*. The total correlation is exactly $2\log_2|C|$. The three-way co-information is $+\log_2|C|$: pure redundancy, with no synergy at all. For three S₃ cubics over a common quadratic field that is 2 bits and $+1$ bit.

## Why it matters

The result is a small but clean piece of a bigger picture. Galois theory describes how fields fit together, and information theory measures how signals overlap. The overlap law says that for prime-reading dials these two descriptions agree: **the redundancy between two number fields is the entropy of what they have in common, and nothing else.** A shared square root is worth exactly one bit. A shared cyclic cubic subfield, with Galois group of order 3, would be worth exactly $\log_2 3$ bits to readouts that can see it. Anything the fields don't share is invisible to correlation.

The same pattern appears far from number theory. Whenever two random systems are built as a fibre product, coupled only through a common "label" and otherwise free, the information they share is exactly the entropy of the label. Two sensors that both read a shared hidden switch but otherwise run on independent noise are an example. So are two genes regulated by one common factor, and two codes that agree on a parity bit. The arithmetic of primes just happens to give a perfect, exactly computable example, checked on thousands of primes, where the answer comes out as a whole number.
