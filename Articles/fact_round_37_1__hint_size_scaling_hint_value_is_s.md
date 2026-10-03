# The Hint That Doesn't Care How Big You Are

*Why a clue about the factors of a number is worth exactly the same whether the primes have fourteen bits or twenty-two — and what happens at the one place it seems not to be.*

---

## A game of twenty questions with a semiprime

Suppose a friend picks two primes $p$ and $q$, multiplies them, and hands you only the product $N = pq$. Factoring $N$ is the classic hard problem behind much of modern cryptography, so you cannot simply read off $p$ and $q$. But some things about $p$ and $q$ are *not* hidden. Reduce $N$ modulo a small number $m$, and you learn the product of the residues $(p \bmod m)(q \bmod m)$. That is a little information about the factors, leaking through the product for free.

Now imagine that your friend, feeling generous, offers you a **hint**: the individual residues $p \bmod m$ and $q \bmod m$, not just their product. How much more do you learn?

That question needs a target. Here the target is a *label*: some arithmetic fact about the primes. A good example is the pair of root counts of a fixed polynomial. Take the cubic $x^3 + x + 1$. Modulo a prime $p$ it has either $0$, $1$, or $3$ roots, and which one happens depends on $p$ in a subtle way. The label of the semiprime $N = pq$ is the unordered pair of root counts, one modulo $p$ and one modulo $q$.

The **hint value** is the extra information, measured in bits, that the residue pair carries about the label beyond what $N \bmod m$ already carries:

$$\text{hint} \;=\; I\big(L;\ (p \bmod m,\ q \bmod m)\big) \;-\; I\big(L;\ N \bmod m\big).$$

Here $I(X;Y)$ is Shannon's mutual information, the average number of bits that $Y$ tells you about $X$.

The hint value measures how much a factor-level clue is worth compared with the information the product already gives away. It is a natural yardstick for a programme that studies exactly which kinds of information about the factors are available "for free" and which are walled off.

## The experiment: a 16,384-fold zoom

The experiment behind this story was simple to describe. Pick four "dials", meaning four combinations of a polynomial and a modulus:

- **$S_3$ at 31**: root counts of $x^3+x+1$, whose discriminant is $-31$, with residues mod $31$;
- **$C_3$ at 7**: splitting degrees in the cubic subfield of the 7th roots of unity, residues mod $7$;
- **$D_4$ at 8**: root counts of $x^4 - 2$, residues mod $8$;
- **$C_5$ at 11**: splitting degrees in the quintic subfield of the 11th roots of unity, residues mod $11$.

For each dial, draw 15,000 random semiprimes whose factors have $k$ bits. Estimate the hint value from the sample, and repeat for $k = 14$, $18$ and $22$. The three sizes together cover a $16{,}384$-fold span of scale.

The readings, in bits:

| dial | $k=14$ | $k=18$ | $k=22$ |
|---|---|---|---|
| $S_3$ at 31 | 0.5584 | 0.5425 | 0.5415 |
| $C_3$ at 7 | 0.9115 | 0.9140 | 0.9169 |
| $D_4$ at 8 | 1.0540 | 1.0536 | 1.0507 |
| $C_5$ at 11 | 0.9030 | 0.9190 | 0.9268 |

Each row is flat. Across the whole 16,384-fold span the readings stayed within about $5\%$ of each other. The two abelian dials ($C_3$ and $C_5$) behaved especially tamely. In those dials the label is literally a function of the residues, and the leftover uncertainty about the label, once you know the residue pair, was exactly zero at every size.

A flat row in a table is an observation. The question is whether it is a *law*. This is the gap the mathematics fills: the flatness turns out to be a theorem, not luck.

## Theorem 1: there is no size law to find

The key observation is almost embarrassingly simple once said out loud. In the idealised population of semiprimes, the actual size of the primes never enters. What matters is the **class-level law**: how the residues $p \bmod m$, $q \bmod m$ and the "Frobenius coin" that decides the root count are distributed. By the theorems of Dirichlet and Chebotarev, these are uniform and independent of size.

Going from small primes to large primes is like taking every residue class and filling it with more prime "identities" (more actual primes in that class), all carrying the same class-level behaviour. Mathematically, you replace the sample space $\Omega$ of classes by $\Omega \times F$, where $F$ is any finite set of copies, and every view ignores the copy.

> **Size-Stability Theorem.** Replicating every class of a finite population by the same number $|F| \ge 1$ of identities leaves every mutual information, and therefore the hint value, exactly unchanged.

The proof rests on a clean principle called **uniform-fibre transport**. Mutual information can be written as an average of a pointwise quantity, the logarithm of a ratio of counts:

$$I(X;Y) \;=\; \frac{1}{|\Omega|}\sum_{\omega\in\Omega} \log_2 \frac{|\Omega|\cdot \#\{X = X(\omega),\, Y = Y(\omega)\}}{\#\{X = X(\omega)\}\cdot\#\{Y=Y(\omega)\}}.$$

Suppose a map squashes $\Omega$ onto a smaller space so that every point upstairs has the same number $K$ of preimages. Then every count in that ratio gets multiplied by the same $K$, the factors of $K$ cancel inside the logarithm, and the average does not move. Replication is the simplest map of this kind, with $K = |F|$.

So the hint value is a functional of the class law alone. There is *no* size law hiding in the data, waiting to be measured. Every extrapolation from toy-sized primes to cryptographic-sized primes is safe, as long as the population really does follow the class law.

## Theorem 2: the hint lives in a tiny box

The same transport principle gives a second surprise. The $S_3$ dial lives on residues mod $31$, a group with $30$ elements. A pair of residues plus two Frobenius coins gives a space of $30 \times 30 \times 3 \times 3 = 8100$ points. But the root count of $x^3+x+1$ modulo $p$ does not care about $p \bmod 31$ in detail. It only cares whether $p$ is a square mod 31. That is a single sign, the Legendre symbol, which we call the **dial**.

> **Residue-Lift Theorem.** Let $G$ be any finite abelian group of residues, and let $\psi: G \to H$ be any surjective homomorphism (the dial). Suppose the label sees the residues only through $\psi$, together with an independent coin. Then the hint value computed on the full residue space equals the hint value computed on the small *dial box* $(H\times H)\times C$.

For $S_3$ the dial box has just $2 \times 2 \times 9 = 36$ points, and on it everything can be computed by hand. The map from the big space to the box has uniform fibres. That much is immediate for the pair of residues. For the product $N$, the key count is that the number of ways to write a given residue $n$ as $a\cdot b$ with prescribed dial values is always exactly the size of the kernel of $\psi$. Uniform fibres again, so transport applies again.

The consequence is striking. **The plateau value does not depend on the conductor either.** Swap $31$ for any other modulus with a surjective quadratic dial, and the $S_3$ hint value is identical.

## The exact plateaus

With the problem shrunk to tiny boxes, the four plateaus can be computed exactly:

| dial | exact hint value | numerically | experiment ($k=22$) |
|---|---|---|---|
| $S_3$ at 31 | $\tfrac12$ | 0.50000 | 0.5415 |
| $C_3$ at 7 | $\log_2 3 - \tfrac23$ | 0.91830 | 0.9169 |
| $D_4$ at 8 | $\tfrac32 - \tfrac{9}{32}\log_2 3$ | 1.05423 | 1.0507 |
| $C_5$ at 11 | $\log_2 5 - \tfrac{12}{25}\log_2 3 - \tfrac{16}{25}$ | 0.92115 | 0.9268 |

The $S_3$ answer, exactly half a bit, can be checked on the back of an envelope. A prime that is a non-square mod 31 always gives exactly one root, because its Frobenius is a transposition. A prime that is a square gives $3$ roots with probability $1/3$ and $0$ roots with probability $2/3$. If you work through the conditional entropies:

- Knowing only the product's sign leaves $\log_2 3 - \tfrac{5}{18} \approx 1.307$ bits of uncertainty about the label.
- Knowing both signs leaves $\log_2 3 - \tfrac{7}{9} \approx 0.807$ bits.
- The difference is $\tfrac{7}{9} - \tfrac{5}{18} = \tfrac{1}{2}$.

The $C_3$ value has an equally pretty reading: $\log_2 3 - \tfrac23$ is the entropy of a coin that lands heads with probability $1/3$. Whatever $N \bmod 7$ is, the label comes down to one such coin.

One puzzle remains: the $S_3$ experiment reads about $0.54$, not $0.50$. The theorem says the population value is exactly $\tfrac12$, so the gap must come from the *estimator*. Estimating entropy from finite samples is biased upward whenever many cells are sparsely filled, and the pair view has $900$ residue cells. A standard bias estimate gives

$$\frac{840}{2\cdot 15000\cdot \ln 2} \approx 0.040 \text{ bits,}$$

which matches the gap almost exactly. In other words, the plateau is size-stable, but the number written on it is "one half, plus sampling bias".

## Theorem 3: the exception that proves the rule

There was one anomaly. At $k = 10$ the $S_3$ dial read $0.7423$, far above the plateau. Does that break size-stability?

No. There are only $75$ primes with 10 bits in the relevant range, which works out to about $2.5$ primes per residue class mod 31. With so few primes, knowing $p \bmod 31$ nearly *tells you which prime $p$ is*. Knowing the prime tells you its root count outright. The residue channel leaks the prime's identity, and the identity leaks the label.

The mathematics captures this exactly through one identity:

$$\text{hint} \;=\; H(L \mid N \bmod m) \;-\; H(L \mid p \bmod m,\ q \bmod m).$$

The second term, the **residual**, is the uncertainty about the label left once you know the residue pair. It can never be negative, which gives a ceiling:

> **Pool-Floor Theorem.** Whatever the population, the hint value never exceeds $H(L\mid N \bmod m)$. A thin pool can only *inflate* the hint value, and only by as much as the residual it destroys. If each residue class holds just one prime, then the residue pair identifies the primes completely, the residual is zero, and the hint value hits the ceiling for *every* label.

For $S_3$ the population plateau is $0.5$ and the ceiling is $\log_2 3 - 5/18 \approx 1.307$. The rogue reading $0.7423$ sits strictly between the two, exactly where an under-resolved pool should land. The mechanism also explains why the abelian dials were immune. There the label is already a function of the residues, so the residual is zero at every size, and there is nothing left to leak.

## Theorem 4: the wall that only the right instrument sees

The experiment also tested a "which-factor wall". The claim is that nothing symmetric in $p$ and $q$ can tell you which factor is which. Write $O$ for an orientation bit, for instance "is $p < q$?". Write $V$ for any view that is unchanged when $p$ and $q$ are swapped, such as $N \bmod m$ together with the *unordered* pair of residues.

> **Which-Factor Wall.** If the population is invariant under swapping the two factors, then for every orientation bit $O$ and every swap-symmetric view $V$, the mutual information $I(O;V)$ is exactly zero.

The proof is a pairing argument. The swap matches each sample with $O=0$ to a sample with $O=1$ and the same value of $V$. So within every slice of $V$, the orientation is a perfectly fair coin.

Across all 16 combinations of dial and size, the experiment's conditional test held: the largest deviation from the null was $|z| = 1.55$. But a naive, *unconditional* version of the test would have raised false alarms at up to $|z| = 4.7$. The mathematics shows why this has to happen. Take the two-sample population $\{(2,3),(3,2)\}$ and the orientation bit $[p<q]$. The asymmetric statistic $I(O;\ p \bmod 5)$ is a full **1 bit**. The conditional statistic, which holds the symmetric data fixed, is exactly **0**. The wall is real, but only an instrument that respects its symmetry can see it.

## Why this matters

The take-home is a kind of permission slip. Information-theoretic quantities like the hint value are expensive to measure at cryptographic sizes and cheap to measure at toy sizes. These theorems say the cheap measurements are faithful, under two conditions:

1. the population follows the class law (uniform residues, Chebotarev coins), and
2. the prime pool is rich enough to fill the residue classes. In practice that meant about 30 primes per class.

When either condition fails, the theorems say exactly *which direction* the error goes (upward), and how far it can go (at most the residual entropy).

The broader point concerns the step from observation to explanation. A table that looks flat could hide a slow drift. Proving that the value is an exact invariant (of size, and even of the modulus) turns a reassuring pattern into a guarantee, and turns the remaining deviations into something measurable: sampling bias that can itself be predicted. The next questions are already sharp. Is the $S_3$ bias exactly $840/(2n\ln 2)$ to first order? Does every dihedral family have a universal hint value? How fast does pool leakage fade as the number of primes per class grows? These are the threads for the next round.
