# Half the Bits: Why a Sum Hint Knows Less Than It Seems

*An experiment about secret primes found a striking pattern. The explanation offered for it was wrong. The correct explanation is a small, sharp law about how precision is lost when you try to recover two numbers from their sum and product.*

---

## Two secret primes and a single public number

RSA-style cryptography rests on a simple asymmetry. Multiplying two large primes $p$ and $q$ to get $N = pq$ is easy. Going back from $N$ to $p$ and $q$ is believed to be infeasibly hard. Everyone sees $N$; the factors are the secret.

Suppose, though, that an attacker gets a little more than $N$. Perhaps a side channel leaks partial information about the **sum** $s = p + q$, or about the **difference** $d = q - p$. These quantities are not arbitrary. If you knew $s$ exactly, you could recover the primes by solving a quadratic equation, since $p$ and $q$ are the roots of

$$X^2 - sX + N = 0 .$$

This is Vieta's formula from school algebra: a quadratic's roots are determined by their sum and product. So a *partial* leak of $s$ is a genuine threat. The question is how much of the secret a partial leak exposes, and through which route.

A research program studying such "hints" probes the factors through **dials**. A dial is a fixed number field together with a prime-dependent rule that assigns each prime a *splitting type*, meaning the way the prime factors in that field. The dial is labelled by the field's symmetry group (its Galois group) and a modulus. For example, "$D_4@8$" is a dial built on the eighth roots of unity, whose type depends only on $p \bmod 8$. "$S_3@23$" is a cubic field whose type involves a quadratic residue symbol.

The experiment asked, for each dial, how much of the information about the unordered pair of types $\{\text{type}(p), \text{type}(q)\}$ is carried by the sum alone, how much by the difference alone, and how much appears only when both are combined (the *synergy*).

## The pattern: routing depends on the dial

An earlier study had found that sum and difference had to be *combined* to reveal the types, with neither channel carrying much on its own. It was natural to guess that this holds for every dial. The new experiment refuted that guess:

| dial | carried by sum | carried by difference | sum–difference synergy | structure |
|---|---|---|---|---|
| $S_3$ at $31$ | $4.0\%$ | $3.8\%$ | $+1.44$ | combination required |
| $S_3$ at $23$ | $5.2\%$ | $5.1\%$ | $+1.41$ | combination required |
| $A_4$ at $9$ | $161.6\%$ | $213.9\%$ | $+0.01$ | noise on a near-zero channel |
| $D_4$ at $8$ | $100.0\%$ | $75.2\%$ | $-1.00$ | **sum is sufficient** |
| $F_{20}$ at $5$ | $165.0\%$ | $122.2\%$ | $+0.41$ | both exceed |
| $C_5$ at $11$ | $77.8\%$ | $55.7\%$ | $+1.18$ | combination required |

The standout row is $D_4@8$. There the sum alone carried $100\%$ of the information, and adding the difference contributed nothing new. For the two $S_3$ dials, neither channel alone carried more than about $5\%$. The information **routes** differently depending on the dial.

That finding stands. The trouble started with the explanation.

## A tempting explanation

The proposed explanation for the $D_4$ row went like this. The $D_4@8$ type of a prime is a function of $p \bmod 8$. Knowing $N$, the partner residue is $q \equiv N p^{-1} \pmod 8$, so

> "$(p+q) \bmod 8$ determines $p \bmod 8$ and $q \bmod 8$ uniquely."

If that were true, the sum modulo $8$ would hand over the type pair on its own, and the $100\%$ figure would be explained.

It is false, and badly so.

## Every odd number mod 8 is its own inverse

The units modulo $8$ are $1, 3, 5, 7$. Square each one:

$$1^2 = 1,\quad 3^2 = 9 \equiv 1,\quad 5^2 = 25 \equiv 1,\quad 7^2 = 49 \equiv 1 \pmod 8 .$$

Each unit is its own inverse. Algebraically, the unit group mod $8$ is the Klein four-group $C_2 \times C_2$, not a cyclic group. This one fact breaks the claimed explanation.

Write $c = N \bmod 8$ and $u = p \bmod 8$. The partner is $q \equiv c\,u^{-1} = c\,u$, so the observable sum is

$$u + c\,u^{-1} \;=\; u + c\,u \;=\; u\,(1 + c) \pmod 8 .$$

Since $c$ is odd, $1 + c$ is even. Multiplying by an even number mod $8$ loses at least one full bit. Here is the complete table:

| $N \bmod 8$ | $p\equiv1$ | $p\equiv3$ | $p\equiv5$ | $p\equiv7$ |
|---|---|---|---|---|
| $1$ | $2$ | $6$ | $2$ | $6$ |
| $3$ | $4$ | $4$ | $4$ | $4$ |
| $5$ | $6$ | $2$ | $6$ | $2$ |
| $7$ | $0$ | $0$ | $0$ | $0$ |

Four facts can be read off the table, and each has been proved in general.

1. **The ordered claim fails for every $N$.** Replacing $u$ by $5u$, which mod $8$ is the same as $u + 4$, never changes the sum, because $4(1+c) \equiv 0$. Each row therefore repeats with period two. $p \bmod 8$ is never determined.
2. **Zero information when $N \equiv 3 \pmod 4$.** The rows for $N \equiv 3$ and $N \equiv 7$ are constant. The sum mod $8$ is then a function of $N$ and tells you nothing.
3. **Even the unordered pair is determined in only one class out of four.** The sum mod $8$ determines the *unordered* pair $\{p \bmod 8,\ q \bmod 8\}$ exactly when $N \equiv 5 \pmod 8$. In the row for $N \equiv 5$, sum $6$ means $\{1, 5\}$ and sum $2$ means $\{3, 7\}$. In the row for $N \equiv 1$, sum $2$ could mean $\{1,1\}$ or $\{5,5\}$.
4. **Real primes do it.** Take $N_1 = 17 \cdot 41 = 697$ and $N_2 = 5 \cdot 13 = 65$. Both have $N \equiv 1 \pmod 8$ and $p + q \equiv 2 \pmod 8$, since $58 \equiv 18 \equiv 2$. But the factor classes are $\{1,1\}$ for the first and $\{5,5\}$ for the second. These have different splitting behaviour in the $D_4@8$ field: a prime $\equiv 1 \pmod 8$ splits completely in the field of eighth roots of unity, and a prime $\equiv 5$ does not. The two moduli are distinguished mod $32$ ($697 \equiv 25$ versus $65 \equiv 1$), but not mod $8$.

The contrast drawn with the $S_3$ dials also runs backwards. The explanation said that for $S_3$ both residues are needed, because the Legendre symbol $(\Delta \mid p)$ is not determined by $(\Delta\mid p) + (\Delta\mid q)$. But the symbols take only the values $\pm 1$, and for such values the sum does determine the unordered pair: $-2$ means $\{-1,-1\}$, $0$ means $\{-1,+1\}$, and $+2$ means $\{+1,+1\}$. As an explanation of *why* the dials differ, the symbol argument proves the opposite of what it was meant to show.

## What is actually going on: a precision-halving law

If mod-$8$ arithmetic cannot explain the result, what can? The replacement is a law about how precisely you can recover two numbers from their sum and product when both are known only modulo a prime power. It holds for every prime $\ell$.

> **The Precision Law.** Let $\ell$ be a prime and $k \ge 0$. If $p + q \equiv p' + q'$ and $pq \equiv p'q' \pmod{\ell^k}$, then the unordered pairs $\{p, q\}$ and $\{p', q'\}$ agree modulo $\ell^{\lceil k/2 \rceil}$.

In words: **sum and product mod $\ell^k$ determine the unordered pair to only half the precision.** The proof uses one identity. Evaluate the difference of the two quadratics $(X-p)(X-q)$ and $(X-p')(X-q')$ at $X = p$:

$$(p - p')(p - q') \;=\; p\bigl[(p+q) - (p'+q')\bigr] + \bigl[p'q' - pq\bigr].$$

Both brackets on the right are divisible by $\ell^k$, so the product on the left is too. Now apply a pigeonhole principle for valuations: if $\ell^{a+b+1}$ divides $xy$, then $\ell^{a+1}$ divides $x$ or $\ell^{b+1}$ divides $y$, because the exponents of $\ell$ in $x$ and $y$ cannot both be small. With $a = b = \lceil k/2 \rceil - 1$, one of the two factors $p - p'$ or $p - q'$ is divisible by $\ell^{\lceil k/2\rceil}$. Knowing one root to that precision gives the other through the sum.

**The law is sharp.** Take $p = 1$, $q = 1 - 2\ell^c$ and $p' = q' = 1 - \ell^c$. The sums are exactly equal. The products differ by $\ell^{2c}$, so they agree mod $\ell^{2c}$. Yet $p - p' = \ell^c$ is not divisible by $\ell^{c+1}$. Half the precision is really lost. In the geometric picture, the two roots of $X^2 - sX + N$ sit close together, and small perturbations of the coefficients move them by the *square root* of the perturbation.

**The exception: separated roots.** If $\ell$ does not divide $p - q$, so the two roots are distinct mod $\ell$, then nothing is lost. The unordered pair is determined at the full precision $\ell^k$. This is the Hensel regime familiar from $p$-adic analysis: simple roots lift without loss. At infinite precision there is no loss either. Over any integral domain, exact sum and product determine the unordered pair exactly, which is Vieta once more.

**The catch at $\ell = 2$.** Odd numbers are never separated modulo $2$, because $p - q$ is always even. RSA primes are odd, so the $2$-adic dials are permanently in the half-precision regime.

## Back to $D_4$

The $D_4@8$ type reads $p \bmod 8 = p \bmod 2^3$. To pin the unordered type pair you need $\lceil k/2\rceil \ge 3$, that is $k \ge 5$. So:

- **Sum and $N$ modulo $32$ determine the $D_4@8$ type pair.**
- **Modulo $16$ they do not.** The odd pairs $(1, 9)$ and $(13, 13)$ have the same sum ($10 \equiv 26$) and the same product ($9 \equiv 169$) modulo $16$, yet reduce to $\{1,1\}$ and $\{5,5\}$ mod $8$.

A quick simulation with a few thousand random 20-bit semiprimes illustrates the threshold. With sum and $N$ known mod $8$, only about a quarter of the type pairs are pinned down. Mod $16$, about three quarters are. Mod $32$ and beyond, all of them are. The count below $32$ depends on the sample, but $100\%$ at $32$ is guaranteed by the theorem.

This changes the reading of the experiment. The measured $100\%$ sum-carried figure for $D_4@8$ **cannot** come from mod-$8$ arithmetic. It has to come from sum information finer than mod $8$, at least mod $32$, and most likely from the exact integer sum. The routing structure really does depend on the dial. But the mechanism is not "the $D_4$ type map is a function of a residue that the sum pins down." It is the precision law, with the dial's modulus deciding which regime applies.

## Why this matters

For cryptanalysis, the lesson is to count bits carefully. An intuitive argument like "$q = N p^{-1}$, so the sum fixes everything" hides a square-root loss of precision whenever the two unknowns agree modulo the prime you are working at. For odd primes at powers of two, that is every time. A side channel that leaks $s \bmod 2^k$ gives you the factor pair only mod $2^{\lceil k/2 \rceil}$, not mod $2^k$.

For the research program, the lesson points to new experiments. The precision law predicts that the $D_4@8$ sum channel is below $100\%$ when the sum is truncated to $k \le 4$ bits and exactly $100\%$ for $k \ge 5$. It predicts that at odd-prime dials such as $S_3@23$, $C_5@11$ or $F_{20}@5$, the sum is already complete on "separated" pairs with $p \not\equiv q \pmod \ell$, so any leftover synergy must live on the diagonal $p \equiv q$, a set of density about $1/\ell$. And it suggests that what really separates $D_4@8$ from $S_3@23$ may be the modulus, a power of two versus an odd prime, rather than the Galois group. Building a $D_4$ dial at an odd conductor, or an $S_3$ dial at a power of two, would settle the question.

One line of algebra, $(p-p')(p-q') = p\,\Delta s - \Delta N$, together with one pigeonhole principle for divisibility, is enough to replace a plausible but false explanation with a sharp and testable law.
