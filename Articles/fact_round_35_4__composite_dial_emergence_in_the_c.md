# The Whole Exceeds the Sum: When Every Piece Is Silent but the Composite Speaks

*How a lock with three dials, the Jacobi symbol of number theory, and a century-old inequality of statistical mechanics combine into one exact statement about emergence.*

---

## A lock that reveals nothing until the last dial turns

Picture a combination lock with three dials, each numbered $0$ to $9$. This lock is unusual. It does not open when each dial shows a particular digit. It opens when the **sum** of the three digits, taken modulo $10$, matches a secret value.

Suppose a thief can peek at one dial. What does that tell them about whether the lock will open? Nothing at all. Whatever digit the first dial shows, the other two dials can still make the sum anything. Peeking at two dials doesn't help either: the third dial can still push the total to any residue. Each dial, and each *pair* of dials, carries no information about the quantity that matters. Read all three together and the answer is fully determined.

This is the simplest case of a phenomenon that turns up in physics, biology, cryptography and number theory: **emergence**, where a property of the whole is not present, even partly, in any of its parts. The slogan is old ("the whole is greater than the sum of its parts"), but it is usually used loosely. This article explains how to make it exact. Information is measured in bits, the parts provably carry *zero* bits, the whole carries a definite number of bits, and that number is shown to be the most any observation could possibly extract.

The example that motivated the work comes from number theory: the Jacobi symbol of a whole number modulo a product of two primes. Before getting there, we need a ruler for information.

## Measuring "how much one thing tells you about another"

In 1948 Claude Shannon gave a precise answer to the question *how much does knowing $X$ tell me about $Y$?* The answer is the **mutual information**. Suppose $X$ and $Y$ take finitely many values, with joint probabilities $p(a,b) = \Pr[X=a,\,Y=b]$ and marginals $p_X(a)$ and $p_Y(b)$. Then

$$I(X;Y) \;=\; \sum_{a}\sum_{b} p(a,b)\,\log\frac{p(a,b)}{p_X(a)\,p_Y(b)}.$$

With base-2 logarithms the unit is the **bit**. The quantity has two properties that matter here:

- $I(X;Y) = 0$ exactly when $X$ and $Y$ are independent: learning $X$ leaves your beliefs about $Y$ unchanged.
- If $Y$ can take only $n$ values, then $I(X;Y) \le \log_2 n$. No observation can tell you more about a label than the label itself can hold. A yes/no label holds at most one bit, and a four-way label at most two.

For three parts $X_1, X_2, X_3$ and a label $L$, the **synergy** is the amount by which the whole beats the parts:

$$\text{synergy} \;=\; I\big((X_1,X_2,X_3);\,L\big) \;-\; \big[I(X_1;L) + I(X_2;L) + I(X_3;L)\big].$$

In ordinary situations the parts carry overlapping information, and the synergy can be negative or small. Emergence in the strong sense means the bracket is zero and the first term is not.

## The trick that proves blindness: swapping fibres

How do you *prove* that a part carries exactly zero information, as opposed to "very little"? The proofs here rest on a symmetry argument that we will call the **fibre-swap criterion**.

Collect all outcomes that share a label value $b$ and call that set the *fibre* over $b$. Suppose that for every pair of label values $b$ and $b'$ there is a rearrangement of the outcomes with three properties:

1. it preserves probabilities, so each outcome goes to an equally likely one;
2. it leaves the observed part $X$ unchanged;
3. it carries the fibre over $b$ exactly onto the fibre over $b'$.

**Fibre-swap criterion.** *If such rearrangements exist for every pair of label values, then $X$ carries exactly zero information about the label.*

The reason is short. For each value $a$ of $X$, the rearrangement matches the outcomes with $(X=a, L=b)$ one-to-one with the outcomes with $(X=a, L=b')$, and matched outcomes have equal probability. So the joint table $p(a,b)$ does not depend on $b$. Within each row the label is uniform, the same as it is overall, so $X$ and $L$ are independent and $I(X;L)=0$.

For the three-dial lock, the rearrangement is "turn dial 3 forward by $b'-b$ clicks." It does not touch dials 1 and 2, every combination is equally likely before and after, and it moves the sum from $b$ to $b'$. So dials 1 and 2 together are blind.

There is a companion result for the whole. **Determined-label law:** *if the label is a function of the observation, and the label fibres can be swapped as above, then the observation carries exactly $\log_2 n$ bits about an $n$-valued label.* The swaps force all $n$ label values to be equally likely, so the label's entropy is $\log_2 n$. An observation that determines the label recovers all of it.

## The general emergence theorem

These two tools handle a whole family of examples at once. Let $A$ be any finite abelian group: the integers mod $m$, a product of such groups, or anything else in which you can add and subtract. Draw $k$ elements $x_1,\dots,x_k$ of $A$ independently and uniformly at random, and define the **composite label** to be their sum

$$L \;=\; x_1 + x_2 + \cdots + x_k \in A.$$

**Theorem (The Whole Exceeds the Sum).** *Suppose $k \ge 2$ and $A$ has more than one element.*
- *Any proper sub-collection of the components, meaning any set of $x_i$'s that leaves at least one out, carries exactly $0$ bits about $L$.*
- *The full tuple $(x_1,\dots,x_k)$ carries exactly $\log_2|A|$ bits about $L$.*
- *So the synergy equals $\log_2|A| > 0$: every bit of information about the label is emergent.*

For the proof, pick a component $x_j$ that the sub-collection leaves out. Shifting $x_j$ by $b'-b$ swaps the fibres over $b$ and $b'$, preserves the uniform distribution, and leaves the sub-collection alone, so the fibre-swap criterion applies. The same shift shows the label is uniform, and since the whole tuple determines $L$, the determined-label law gives $\log_2|A|$.

The number of parts matters, and there is a sharp threshold. With a single component ($k=1$) the label *is* the component, which therefore carries all $\log_2|A|$ bits, and nothing emerges. The precise statement is an **emergence dichotomy**: *for a nontrivial group and $k\ge1$, a single component is blind to the sum label if and only if $k \ge 2$.* You need at least two irreducible pieces before the whole can know something that no piece knows.

## The ceiling: emergence at full strength

Could some cleverer observation of the components get *more* than $\log_2|A|$ bits about the label? The answer is no, and the proof goes back to an inequality that predates information theory.

**Gibbs' inequality.** *A probability distribution on $n$ outcomes has entropy at most $\log n$:*
$$-\sum_{b} q_b \log q_b \;\le\; \log n.$$

The proof uses only the elementary fact $\log t \le t-1$ for $t>0$. Apply it with $t = 1/(n q_b)$, multiply by $q_b$, and sum over $b$. The right-hand side then sums to $1 - 1 = 0$.

From this follows the **label-capacity bound**. *For any random observation $X$ and any label $Y$ with $n$ possible values,*
$$I(X;Y) \;\le\; H(Y) \;\le\; \log n.$$
The first inequality holds term by term, because a joint probability $p(a,b)$ can never exceed the marginal $p_X(a)$. The second is Gibbs' inequality.

Applied to the sum label: no observation of the components, however it is computed, can carry more than $\log_2|A|$ bits, and the full tuple achieves exactly that. We call this **saturated emergence**. The parts carry the minimum possible information (zero), the whole carries the maximum possible information (the label's full capacity), and the gap between them is as large as it can be.

## The arithmetic heart: the Jacobi symbol

Now the number theory. Fix an odd prime $p$. A number $a$ not divisible by $p$ is a **quadratic residue** mod $p$ if it is congruent to a perfect square mod $p$, and a **nonresidue** otherwise. The **Legendre symbol** $\left(\frac{a}{p}\right)$ is $+1$ for residues and $-1$ for nonresidues. Exactly half of the nonzero residues mod $p$ are squares, and multiplying by a nonresidue turns residues into nonresidues and back again.

For a squarefree odd modulus $N = p_1 p_2 \cdots p_k$, the **Jacobi symbol** is the product

$$\left(\frac{a}{N}\right) \;=\; \prod_{i=1}^{k}\left(\frac{a}{p_i}\right).$$

Writing $\left(\frac{a}{p}\right) = (-1)^{\beta_p(a)}$ with a **Legendre bit** $\beta_p(a) \in \{0,1\}$, the Jacobi symbol becomes a *sum mod 2*:

$$\left(\frac{a}{N}\right) = 1 \quad\Longleftrightarrow\quad \beta_{p_1}(a) + \cdots + \beta_{p_k}(a) \equiv 0 \pmod 2.$$

By the Chinese remainder theorem, choosing a uniformly random unit $a$ mod $N$ is the same as choosing its residues mod $p_1, \dots, p_k$ independently and uniformly. So the Jacobi symbol is a sum label: the components are the prime residues, and the label is the parity of their Legendre bits. The three-dial lock is hiding in the multiplicative arithmetic of $N$.

The groups involved are now multiplicative and the label lives in a different group (bits), so the shift trick needs adjusting. Instead of adding $b'-b$, **multiply one prime residue by a nonresidue**. That flips the Legendre bit at that prime, so it flips the Jacobi parity, while every other residue stays fixed and the uniform distribution is preserved. Every odd prime has a nonresidue, so the fibre-swap criterion applies again.

**Theorem (Jacobi emergence).** *Let $N$ be a product of $k \ge 2$ distinct odd primes, and let $a$ be a uniformly random unit modulo $N$.*
- *Any statistic of $a$ that depends only on its residues modulo a proper subset of the primes carries exactly $0$ bits about the Jacobi symbol $\left(\frac{a}{N}\right)$. This includes the complete residue modulo every prime but one.*
- *The full residue $a \bmod N$ carries exactly $1$ bit. So does the vector of Legendre bits alone.*
- *No statistic of $a$ whatsoever carries more than $1$ bit.*

Take the smallest case, $N = 15 = 3 \times 5$. There are eight units: $1, 2, 4, 7, 8, 11, 13, 14$. Tabulate the residue mod $3$ against the Jacobi symbol and every cell holds exactly $2$ units. Tabulate the residue mod $5$ against it and every cell holds exactly $1$. Both tables are flat, so neither prime tells you anything. Yet $a \bmod 15$ determines the symbol, and the symbol is $+1$ for exactly four of the eight units: one full bit, from two components that each carry nothing.

For $N = 105 = 3 \times 5 \times 7$ it gets stranger. Even knowing $a$ modulo $15$, the residues mod $3$ and mod $5$ *together*, leaves the symbol a fair coin. Each of the $15$ classes splits evenly between the two symbol values, and the $48$ units divide $24$ to $24$. Only the third prime completes the picture.

This explains why the Jacobi symbol is famously hard to read off from partial knowledge. Information about $a$ modulo some of the primes says literally nothing about the symbol. Cryptographers make related observations about quadratic residuosity modulo composite numbers, and the theorem above isolates the exact, information-theoretic core of that intuition.

## The puzzle of 1.8170 bits

The experiments that motivated this work reported a measured read of **1.8170 bits** carried by a composite label at the semiprime level, with each of the three irreducible components carrying approximately zero. The theory says two definite things about that number.

First, "approximately zero" should be *exactly* zero whenever the components are drawn uniformly. The fibre-swap criterion leaves no room for a small positive leak, so any residual measured value comes from sampling, not from structure.

Second, 1.8170 bits **cannot come from the Jacobi bit**, or from any two-valued label. The capacity bound caps a binary label at $1$ bit. It does not fit a three-valued label either, because

$$3^5 = 243 \;<\; 256 = 2^8 \quad\Longrightarrow\quad \log_2 3 \;<\; \tfrac{8}{5} = 1.6 \;<\; 1.8170.$$

**Four-types theorem.** *If some observation carries at least $1.8170$ bits of information about a label, then the label takes at least $4$ distinct values.*

So the measured composite label has at least four types. If it has exactly four, its capacity is $2$ bits and the measured read sits below that ceiling. For instance, a four-valued label observed through a symmetric channel that errs about $2\%$ of the time yields almost exactly $1.817$ bits. The measurement is consistent with genuine emergence, but it is a richer emergence than a single parity bit. One natural candidate is a sum label valued in a group of order at least four. For such labels the general theorem above guarantees zero bits per component and a whole worth $\log_2|A| \ge 2$ bits.

## Where emergence breaks

Every exact theorem should come with its boundaries, and this one has two.

- **One part is not enough.** With $k=1$ there is no emergence: the lone component carries everything.
- **The prime 2 is special.** Modulo $2$ there is only one unit and so no nonresidue to multiply by. The fibre swap that drives the Jacobi argument does not exist there, which is why the moduli are required to be odd.

## Why it matters

Emergence is often invoked and rarely measured. The results here give a template where the claim is exact:

1. a **symmetry**, the fibre swap, certifies that the parts carry exactly nothing;
2. a **determination** argument certifies that the whole carries the label's full entropy;
3. a **capacity** bound, Gibbs' inequality, certifies that nothing could carry more.

The template applies wherever a target is a sum of independent, uniformly distributed contributions: parity checks in error-correcting codes, secret sharing (where any proper subset of shares should reveal nothing about the secret), XOR-type interactions in genetics, and the Jacobi symbol of number theory. Each of these is "the whole exceeds the sum" in its strongest form, with zero information in the parts and the maximum possible information in the whole.
