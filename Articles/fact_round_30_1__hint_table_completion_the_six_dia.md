# The Hint That Is Almost Universal: When Knowing More Can Cost You One Bit

*How a table of six positive numbers turned into a clean dividing line between odd and even arithmetic.*

---

## A table that looked like a law

Six dials were tested, and all six came back positive. Each dial is a small arithmetic instrument. It works modulo a fixed number $m$ (the moduli were $11, 5, 31, 23, 8$ and $9$) and carries a name taken from a finite group: $C_5$, $F_{20}$, two copies of $S_3$, $D_4$ and $A_4$. For every dial the experimenters measured one quantity, which they called the **hint value**. Its reading was positive on all six:

| dial | modulus | capacity (bits) | hint value (bits) |
|---|---|---|---|
| $C_5$ | $11$ | $1.2062$ | $+1.5896$ |
| $F_{20}$ | $5$ | $0.2920$ | $+0.9538$ |
| $S_3$ (a) | $31$ | $1.0011$ | $+0.5201$ |
| $S_3$ (b) | $23$ | $1.0008$ | $+0.5121$ |
| $D_4$ | $8$ | $1.9999$ | $+0.5032$ |
| $A_4$ | $9$ | $0.0015$ | $+0.0120$ |

The hint values add up to $4.0908$ bits, and the capacities add up to $5.5015$ bits. The verdict was written in capital letters: **THE HINT IS UNIVERSAL.**

Six positive numbers in a row make a tempting pattern. This article asks whether the pattern is a law, and it answers the question completely. The answer is "yes, exactly when the modulus is odd". It is a theorem for five of the six dials. The sixth dial, $D_4$ at modulus $8$, is the odd one out, and the reason is that $8$ is even. At every even modulus the hint can go negative, but never by more than one bit.

## What is a "hint"?

Picture a laboratory notebook. Each row is a **sample**, and a sample records two numbers $P$ and $Q$, both taken modulo $m$, together with a **label** $T$. The label might be a category, an outcome, or anything else you want to predict. Such a notebook is called a **battery**.

You can summarize each sample in two ways.

1. **The product reading.** Record only $N = P\cdot Q \pmod m$.
2. **The sum-and-difference reading.** Record the pair $s = P + Q$ and $d = P - Q$, both mod $m$.

We then ask how much each reading tells us about the label. The standard measure is Claude Shannon's **mutual information**. With samples drawn uniformly from the notebook, $I(T;X)$ counts in bits how much uncertainty about the label $T$ disappears once you learn the reading $X$. A reading with a single constant value tells you nothing and has mutual information $0$. A reading that pins down the label exactly recovers all of the label's entropy $H(T)$.

The **capacity** of a battery is $I(T;N)$, the information carried by the product. The **hint value** is how much more the sum-and-difference reading carries:

$$\text{hint} \;=\; I\big(T;(s,d)\big) \;-\; I(T;N).$$

Intuitively the hint should be nonnegative. Over the ordinary numbers you can rebuild $P$ and $Q$ from $s$ and $d$, since $P = (s+d)/2$ and $Q = (s-d)/2$, and then compute $N = PQ$. Processing data cannot create information. So if $N$ can be computed from $(s,d)$, the pair $(s,d)$ carries at least as much information as $N$, and the hint is at least zero.

The weak point is the **division by 2**.

## The trouble with two

Modulo an odd number such as $11$, dividing by $2$ is harmless. The number $2$ has an inverse ($2 \cdot 6 = 12 \equiv 1 \pmod{11}$), so "half of $x$" means $6x$. The recipe $P = (s+d)/2$ works, $N$ is a function of $(s,d)$, and the hint can never be negative.

Modulo $8$ this breaks down. We know $2P = s + d$, but that does not determine $P$, because $2\cdot 0 = 2 \cdot 4 = 0 \pmod 8$. Every equation $2P = c$ that has a solution has **two** solutions, $P$ and $P+4$. The sum and the difference together still leave one bit of ambiguity about the pair $(P,Q)$.

That lost bit can matter. Look at two samples modulo $8$:

- sample A: $(P,Q) = (0,1)$, so $s = 1$, $d = -1 \equiv 7$, and $N = 0$;
- sample B: $(P,Q) = (4,5)$, so $s = 9 \equiv 1$, $d = -1 \equiv 7$, and $N = 20 \equiv 4$.

Their sums and differences agree exactly, but their products differ. Label A with "0" and B with "1". The product reading now tells the two labels apart perfectly, so the capacity is one full bit. The sum-and-difference reading gives the same answer for both samples and carries zero information. The hint value is

$$0 - 1 = -1 \text{ bit}.$$

So the hint is **not** universal. At modulus $8$ you can build a two-row notebook in which the "richer" reading is one bit worse.

## The two-torsion floor

A single counterexample shows that a claim is false. It does not say how false. The central result here gives an exact bound on how negative the hint can be.

The idea is a **selector**. Suppose that alongside $s$ and $d$ someone also hands you a small extra tag $\sigma(P)$ that takes values in a finite set $F$. The tag must be able to tell apart any two numbers with the same double. That is, if $2a = 2b$ and $\sigma(a) = \sigma(b)$, then $a = b$.

With the tag, the ambiguity is gone. From $s$ and $d$ you know $2P$. From $2P$ and the tag you know $P$. Then $Q = s - P$ and $N = PQ$. Revealing a tag with $|F|$ possible values can add at most $\log_2 |F|$ bits of information. That gives the **two-torsion floor**:

> **Theorem (the two-torsion floor).** In any commutative ring that has a selector with values in a finite set $F$, every battery satisfies
> $$\text{hint} \;\ge\; -\log_2 |F|.$$

The name refers to the elements $a$ with $2a = 0$, which are called the *2-torsion*. These elements are exactly the source of the ambiguity. If the ring has no nonzero 2-torsion, you need no tag at all: a one-element set $F$ already works, and $\log_2 1 = 0$. This covers every odd modulus, and it also covers the ordinary integers.

> **Corollary (odd moduli).** If $2a = 0$ forces $a = 0$, and in particular modulo any odd number, the hint value of every battery is nonnegative.

For an even modulus $m = 2k$ there is a natural tag of size two: **"is $P$ in the lower half?"** Write each residue as an integer between $0$ and $2k-1$ and ask whether it is less than $k$. If $2a \equiv 2b \pmod{2k}$, then $a \equiv b \pmod k$. So $a$ and $b$ are either equal or exactly $k$ apart, which puts one in the lower half and the other in the upper half. The tag separates them.

> **Theorem (the one-bit floor).** Modulo any even number, every battery satisfies $\text{hint} \ge -1$ bit.

## The floor is reached everywhere

The one-bit floor is sharp at **every** even modulus, and not only at $8$. The construction depends on the parity of $k$ in $m = 2k$:

- if $k$ is even, take the samples $(0,1)$ and $(k, k+1)$;
- if $k$ is odd, take the samples $(0,0)$ and $(k,k)$.

In both cases the two samples have the same $(s,d)$. The products are $0$ and $k(k+1)$ in the first case, and $0$ and $k^2$ in the second. A short divisibility check shows that neither is a multiple of $2k$. With distinct labels, each notebook has a hint value of exactly $-1$. Modulo $6$, for example, the samples $(0,0)$ and $(3,3)$ have $s = 0$ and $d = 0$ but products $0$ and $9 \equiv 3$.

Together these results give a sharp answer to the question the table raised:

> **Theorem (the hint is universal exactly at odd moduli).** Working modulo $n$, every battery has nonnegative hint value **if and only if $n$ is odd**. When $n$ is even the best possible floor is exactly $-1$ bit, and the smallest possible notebook (two samples, two labels) already reaches it.

## What this says about the six dials

Now go back to the table. Five of the six moduli, $11, 5, 31, 23$ and $9$, are odd. For those dials the positive readings no longer need to be taken on trust, because no battery at those moduli could have produced a negative hint.

The sixth dial, $D_4$ at modulus $8$, is different. Its reading of $+0.5032$ is a true measurement, but it describes that particular battery. It is not a law. A different notebook at the same modulus could read as low as $-1$.

The analysis also gives an upper limit. The pair $(s,d)$ takes at most $m^2$ values, so it carries at most $2\log_2 m$ bits, and the hint can be no larger than that. Each dial therefore gets a proven **window**:

- the odd dials: $0 \le \text{hint} \le 2\log_2 m$;
- the $D_4$ dial: $-\min\big(1,\ I(T;N)\big) \le \text{hint} \le 6$.

The $-I(T;N)$ in the last window comes from a separate observation. A hint can never destroy more information than the product carried in the first place, because $I(T;(s,d)) \ge 0$. All six measured values fall inside their windows.

## Two even dials cost two bits

If one even modulus costs one bit, what about two at once? Take pairs of residues, working modulo $8$ in each coordinate. Tags combine: a tag for each coordinate gives a tag for the pair, with $2 \times 2 = 4$ values. So the floor becomes $-\log_2 4 = -2$ bits. This floor is reached too, by four samples:

$$P \in \{(0,0),(0,4),(4,0),(4,4)\},\qquad Q \in \{(1,1),(1,5),(5,1),(5,5)\},$$

taken in matching order. All four samples have the same sum $(1,1)$ and the same difference $(7,7)$. Their four products $(0,0),(0,4),(4,0),(4,4)$ are all different. With four distinct labels the capacity is $2$ bits and the hint is exactly $-2$ bits. The pattern of one negative bit per even factor mirrors a "one extra bit per field" phenomenon known on the upper side.

## Capacity and hint are genuinely independent

The experiment made a second observation. Across the six dials, the correlation between capacity and hint value was only about $r = 0.256$. Recomputing it from the table gives $0.255 < r < 0.257$, so $r^2 < 0.07$: capacity explains less than $7\%$ of the variation in hint. The experimenters concluded that the two quantities are independent properties of a dial.

Six data points cannot establish that, but a small exact construction can. Work modulo $5$ with four samples:

| labels | samples $(P,Q)$ | capacity | hint |
|---|---|---|---|
| all the same | $(1,1),(1,2),(2,3),(2,1)$ | $0$ | $0$ |
| $0,0,1,1$ | $(1,1),(1,2),(2,3),(2,1)$ | $0$ | $1$ |
| $0,0,1,1$ | $(1,1),(1,1),(1,2),(1,2)$ | $1$ | $0$ |
| $0,1,2,3$ | $(1,1),(1,2),(2,3),(2,1)$ | $1$ | $1$ |

All four corners of the unit square are reached. So the hint is **not a function** of capacity, and capacity is not a function of the hint. Knowing one tells you nothing definite about the other.

The two quantities are linked in only one way, through a shared budget. Capacity plus hint equals the sum-and-difference information, and that can never exceed the entropy of the labels:

$$I(T;N) + \text{hint} \;=\; I\big(T;(s,d)\big) \;\le\; H(T).$$

The mechanism is clear. Capacity measures how the **product** sorts the samples. The hint measures how much **finer** the sum-and-difference sorting is than the product sorting. These are two different features of how a battery is arranged.

## Why this is geometry

A pair $(P,Q)$ is a point on a grid of $m \times m$ points. The map $(P,Q)\mapsto (P+Q, P-Q)$ rotates the grid by $45°$ and stretches it. The product $PQ$ is constant along hyperbolas. Over the real numbers the rotation can be undone, and the hyperbola $PQ = N$ is the same as $s^2 - d^2 = 4N$.

Modulo an odd number the same picture holds: the rotated grid carries all the original information. Modulo an even number the rotation **folds** the grid. Pairs that differ by $(t,t)$ with $2t = 0$ land on top of each other. The product then changes as

$$N \mapsto N + t\,s + t^2,$$

and whenever that change is nonzero, the fold has merged two points that the product keeps apart. This merging is what produces a negative hint.

## What we learned, and what is still open

The positive table has been replaced by a complete account:

1. **Odd moduli:** the hint is always $\ge 0$. For five of the six dials, positivity is a theorem.
2. **Even moduli:** the hint is always $\ge -1$ bit, and $-1$ is reached at every even modulus.
3. **In general:** the hint is at least $-\log_2$ of the size of any tag that resolves the doubling ambiguity. Products of two even cyclic factors cost $-2$ bits, and that is reached.
4. **Ceiling and budget:** the hint is at most $2\log_2 m$, capacity plus hint is at most $H(T)$, and the hint is never below minus the capacity.
5. **Independence:** capacity and hint reach all four corners of $\{0,1\}^2$, so neither determines the other.

Several natural conjectures remain. The first is a **torsion floor law**: for every finite commutative ring $R$, the lowest possible hint should be exactly $-\log_2 |R[2]|$, where $R[2]$ is the set of elements killed by doubling. The second is that a product of $k$ even cyclic rings should cost exactly $k$ bits. The third concerns the **exact ceiling**. Computations suggest the largest possible hint modulo $n$ is $\log_2 M(n)$, where $M(n)$ is the size of the largest set of pairs sharing a single product. Examples are $M(p) = 2p-1$ for a prime $p$, $M(8) = 20$ and $M(9) = 21$. The fourth asks for the exact shape of the region of achievable (capacity, hint) pairs. It is conjectured to be a triangle bounded by the label budget.

In short, the hint really is universal at odd moduli. At even moduli the division by two costs at most one bit, and there is a construction that costs exactly that bit.
