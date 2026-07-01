# The Hidden Arithmetic of Repeating Decimals

## A number you already know

Divide $1$ by $7$ and you meet one of the most famous patterns in elementary arithmetic:

$$\frac{1}{7} = 0.\overline{142857} = 0.142857\,142857\,142857\ldots$$

The block $142857$ repeats forever. Now do something that feels almost childish — add up the six digits of that repeating block:

$$1 + 4 + 2 + 8 + 5 + 7 = 27.$$

Try $1/17$, which repeats with a block of sixteen digits, $0588235294117647$. Add them:

$$0+5+8+8+2+3+5+2+9+4+1+1+7+6+4+7 = 72.$$

Try $1/19$: its eighteen-digit block sums to $81$. Something is going on. These are not random totals. $27 = 9 \cdot 3$, $72 = 9 \cdot 8$, $81 = 9 \cdot 9$. And $3, 8, 9$ are exactly $\frac{7-1}{2}, \frac{17-1}{2}, \frac{19-1}{2}$. In every one of these cases the digits of one full period of $1/p$ sum to precisely

$$\frac{9\,(p-1)}{2}.$$

The $9$ is not a coincidence either — it is one less than our base, $10$. This article is about *why* that clean formula holds, why it sometimes changes to a quarter instead of a half, and the single elegant idea that explains both.

## What a repeating expansion really is

Long division is a machine. To expand $1/p$ in base $b$ (base $10$ for ordinary decimals) you carry along a *remainder*. Start with remainder $1$. At each step you multiply the current remainder by $b$, divide by $p$, write down the quotient as the next digit, and keep the new remainder. Symbolically, if $r_k$ is the remainder after $k$ steps and $d_k$ is the digit produced, then

$$b \cdot r_k = p \cdot d_k + r_{k+1}, \qquad r_0 = 1.$$

The digit is $d_k = \lfloor b\,r_k / p \rfloor$ and the new remainder is $r_{k+1} = b\,r_k \bmod p$. Because each remainder is just the previous one multiplied by $b$ modulo $p$, we get the compact description

$$r_k = b^k \bmod p.$$

The expansion repeats as soon as a remainder returns to its starting value $1$. The first time $b^k \equiv 1 \pmod p$ happens is at $k$ equal to the **multiplicative order** of $b$ modulo $p$, written $\operatorname{ord}_p(b)$. That order is the length of one period.

For a prime $p$ the nonzero remainders live in a world of exactly $p-1$ residues, and a classical fact of number theory says the order always divides $p-1$. The two most beautiful cases are the extremes:

- **Full reptend primes**: $\operatorname{ord}_p(b) = p-1$. The base $b$ is a *primitive root*, and the period is as long as it can possibly be. ($10$ is a primitive root mod $7, 17, 19$.)
- **Half-period primes**: $\operatorname{ord}_p(b) = \tfrac{p-1}{2}$, exactly half the maximum.

## The main results

Here is the pair of theorems this article celebrates. Fix a prime $p$ and a base $b \ge 2$ that $p$ does not divide.

> **Full-Period Digit-Sum Theorem.** If the order of $b$ modulo $p$ equals $p-1$, then the digits of one period of the base-$b$ expansion of $1/p$ sum to
> $$\frac{(b-1)(p-1)}{2}.$$

> **Half-Period Digit-Sum Theorem.** If the order of $b$ modulo $p$ equals $\tfrac{p-1}{2}$ *and* $p \equiv 1 \pmod 4$, then the digits of one period sum to
> $$\frac{(b-1)(p-1)}{4}.$$

Our opening examples are the first theorem in base $b = 10$: the digit sum is $\frac{9(p-1)}{2}$, which gives $27, 72, 81$ for $p = 7, 17, 19$.

The second theorem is subtler and hides a lovely condition. Take $p = 13$ in base $10$. The powers of $10$ modulo $13$ cycle as $10, 9, 12, 3, 4, 1$ — six of them, and $6 = \tfrac{13-1}{2}$, so $10$ has half period. And $13 \equiv 1 \pmod 4$. The theorem predicts

$$\frac{(10-1)(13-1)}{4} = \frac{9 \cdot 12}{4} = 27.$$

Indeed $1/13 = 0.\overline{076923}$ and $0+7+6+9+2+3 = 27$. It works.

## One idea to rule them both

Why should adding up digits — a messy, base-dependent operation — produce such a tidy answer? The secret is to stop looking at the digits and look at the **remainders** instead.

Recall the division identity $b\,r_k = p\,d_k + r_{k+1}$. Sum it over one whole period of length $L$. On the left we get $b$ times the total of all the remainders. On the right we get $p$ times the total of all the digits, plus the total of the *shifted* remainders. But the shifted remainders are the same collection as the original ones — the cycle simply drops its first value and picks up its last, and both of those are $1$. So the shifted total equals the original total. Writing $S$ for the remainder total and $D$ for the digit total, the whole period collapses to a single equation:

$$b\,S = p\,D + S \quad\Longrightarrow\quad p\,D = (b-1)\,S.$$

This is the heart of the matter. **The digit sum is nothing more than a rescaled copy of the remainder sum.** All the base-dependent mess in $D$ is controlled by one purely number-theoretic quantity, $S$ — the sum of the remainders that appear in the cycle.

So everything reduces to computing $S$, the total of the residues $b^0, b^1, \dots, b^{L-1}$ taken modulo $p$.

**The full-period case.** When $b$ is a primitive root, its powers run through *every* nonzero residue $1, 2, \dots, p-1$ exactly once. The remainder cycle is just a scrambled list of all the nonzero residues, so their sum is the familiar triangular total

$$S = 1 + 2 + \cdots + (p-1) = \frac{p(p-1)}{2}.$$

Plug into $p\,D = (b-1)S$ and the factor of $p$ cancels beautifully:

$$D = \frac{(b-1)(p-1)}{2}.$$

**The half-period case.** Now the powers of $b$ cover only half of the nonzero residues — a subgroup $H$ of size $\tfrac{p-1}{2}$. The magic ingredient is a fact from the theory of quadratic residues: when $p \equiv 1 \pmod 4$, the number $-1$ is itself a square modulo $p$, which forces the half-size subgroup $H$ to be **symmetric under negation**. In plain terms, whenever a residue $x$ appears in the cycle, its complement $p - x$ appears too. The residues pair up, each pair summing to exactly $p$, and there are $\tfrac{1}{2} \cdot \tfrac{p-1}{2}$ such pairs:

$$S = p \cdot \frac{p-1}{4}.$$

Once more the $p$ cancels in $p\,D = (b-1)S$, leaving

$$D = \frac{(b-1)(p-1)}{4}.$$

The two theorems are the *same theorem*, differing only in how large the orbit of remainders is and whether it is negation-symmetric.

## Why $p \equiv 1 \pmod 4$ is essential

The congruence is not decoration. It is exactly the condition that makes $-1$ a square, and hence makes the half-period orbit closed under $x \mapsto p - x$. If instead $p \equiv 3 \pmod 4$, then $-1$ is a *non*-square, the half-size subgroup is not negation-symmetric, the residues refuse to pair up into totals of $p$, and the clean quarter formula breaks. The parity of $p$ modulo $4$ is precisely the switch that decides whether the pairing trick fires.

## The digit-complement echo

This pairing has a charming visible shadow. In the full-period case, split the period into two equal halves and add them column by column. For $1/7$: the halves are $142$ and $857$, and

$$142 + 857 = 999.$$

Every column sums to $9 = b - 1$. This is the classical "Midy" phenomenon, and it is the negation symmetry of the remainders wearing a disguise: the second half of the cycle is the first half reflected through $x \mapsto p - x$, so the corresponding digits are complements that add to $b - 1$. The digit-sum theorems and Midy's theorem are two faces of the same symmetry.

## The average digit

Divide the digit sum by the number of digits and something else pops out. In the full-period case the period has $p-1$ digits, so the average digit is

$$\frac{(b-1)(p-1)/2}{p-1} = \frac{b-1}{2}.$$

In base $10$ that is $4.5$ — the exact midpoint of the possible digits $0$ through $9$. The half-period case has $\tfrac{p-1}{2}$ digits summing to $\tfrac{(b-1)(p-1)}{4}$, and the average is again $\tfrac{b-1}{2}$. In both symmetric regimes the digits are, on average, dead center. That is the negation symmetry once more: each digit's complement also appears, so the mean is pinned to the middle value.

## A wider horizon

Step back and the picture becomes a single law. For *any* prime $p$ and base $b$ with $p \nmid b$, if $d = \operatorname{ord}_p(b)$ is the period and $s$ is the sum of the residues in the cyclic group generated by $b$, then the digit sum of one period is always

$$\frac{(b-1)\,s}{p}.$$

The two theorems are the special cases where the orbit is negation-symmetric, so that $s = \tfrac{p \cdot d}{2}$ and the formula collapses to $\tfrac{(b-1)d}{2}$. Whether the orbit is symmetric depends on a clean, checkable condition: whether $-1$ lies in the group generated by $b$. When it does, the digits balance perfectly; when it does not, a measurable bias appears.

From a single childlike act — adding the digits of a repeating decimal — we arrive at primitive roots, quadratic residues, and the deep symmetry of cyclic groups. The number $142857$ was never a curiosity. It was a message about the architecture of the integers, waiting for anyone willing to add it up.
