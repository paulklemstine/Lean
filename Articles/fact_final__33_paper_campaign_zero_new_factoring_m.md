# Four Walls Around Factoring: What a Campaign That Found No New Algorithm Actually Learned

*Thirty-three papers set out to find a new way to factor large numbers. None succeeded. This is the story of why that failure was precise enough to be worth writing down.*

---

## The oldest hard problem in your pocket

Take two large primes $p$ and $q$, multiply them, and publish the product $N = pq$. Multiplying is easy: a phone does it for 300-digit numbers in microseconds. Undoing it, recovering $p$ and $q$ from $N$ alone, is believed to be very hard. Much of internet security has rested on that asymmetry for half a century.

What is strange is how little we can prove about it. Nobody has shown that factoring is hard. No unconditional superpolynomial lower bound on factoring is known in any general model of computation. What we have are *upper* bounds, algorithms that are known to work, and a long list of clever ideas that turned out not to help.

Among the deterministic algorithms, the ones that use no random coin flips and are guaranteed to finish, the best known running time is roughly $N^{1/5}$ arithmetic operations, up to logarithmic factors. That is far better than trial division's $N^{1/2}$. It is also far worse than the subexponential running times that randomised and heuristic methods such as the quadratic sieve and the number field sieve reach in practice. The exponent $1/5$ is a ceiling that someone has reached. It is not a floor that anyone has proved.

A research campaign of 33 papers asked a blunt question: **can any of the known families of ideas push below that ceiling, or give a new kind of factoring method at all?** The answer was no, in every case. The useful part is *how* each "no" was obtained. Where possible, a vague failure was replaced by a theorem that says exactly why an idea cannot work.

This article is about four of those theorems. Each is short, each is elementary once you see it, and each rules out a tempting idea for good.

---

## Wall 1: Changing the polynomial doesn't change the primes

### How the quadratic sieve thinks

The quadratic sieve looks for many integers $x$ for which the number
$$Q(x) = x^2 - N$$
breaks completely into small primes. Each such $x$ is called a *relation*. Collect enough of them, combine them with linear algebra over the two-element field, and you get a congruence $X^2 \equiv Y^2 \pmod N$. From that, $\gcd(X - Y, N)$ has a good chance of being a nontrivial factor.

The small primes used for this are called the *factor base*, and each one is a *column* of the linear-algebra matrix. Not every prime can appear. A prime $p$ divides some value $x^2 - N$ exactly when $x^2 \equiv N \pmod p$ has a solution, that is, when $N$ is a *quadratic residue* (a perfect square) modulo $p$. Roughly half of all primes pass this test. They form what we will call the *split set* of $N$.

### The multiple-polynomial trick

In practice, sieving a single polynomial runs out of steam, because $x^2 - N$ grows as $x$ grows. The standard fix, the *multiple-polynomial quadratic sieve*, switches between many polynomials of the form
$$(ax + b)^2 - N \qquad\text{or equivalently}\qquad a x^2 + 2bx + c \quad\text{with } b^2 - ac = N.$$
The two forms are linked by the identity $a\,(ax^2 + 2bx + c) = (ax+b)^2 - N$.

At one point the campaign's record claimed that this trick does something more drastic: that it confines the relations to a column set about a *quarter* the size of the factor base, half of what one polynomial gives. If true, that would shrink the matrix and change the cost accounting. Measurement said otherwise. The observed column density was between $0.487$ and $0.505$, which is the same one-half as before.

### The theorem

The explanation turned out to be a clean theorem.

> **Split-Set Theorem.** Let $p$ be a prime that does not divide $a$. Then $p$ divides some value $(ax+b)^2 - N$ if and only if $N$ is a square modulo $p$. The same holds for $ax^2 + 2bx + c$ whenever $b^2 - ac = N$.

The proof takes a few lines. If $p \mid (ax+b)^2 - N$, then $y = ax + b$ is a square root of $N$ modulo $p$. Conversely, if $y^2 \equiv N \pmod p$, then because $a$ is invertible modulo $p$ we can solve $ax + b \equiv y$ for $x$, and that $x$ works. Changing the polynomial only *shifts and rescales* where the roots sit. It cannot create or destroy them.

From this it follows that **no family of polynomials, however large or cleverly chosen, changes the column set.** For a prime coprime to all the leading coefficients, being a column of *some* member of the family is the same as being in the split set. There is also an exact count: for an odd prime $p$, exactly $(p-1)/2$ of the $p - 1$ nonzero residues $N \bmod p$ make $p$ a column. That is a density of exactly one-half, not one-quarter.

A small example: take $p = 7$ and the polynomial $(3x+5)^2 - N$. For $N = 2$, which is a square modulo 7 because $3^2 = 9 \equiv 2$, there are two roots per period, at $x = 2$ (where $11^2 - 2 = 119 = 7 \cdot 17$) and $x = 4$ (where $17^2 - 2 = 287 = 7 \cdot 41$). For $N = 3$, a non-residue, the value is never divisible by 7, whatever $x$ is.

The incorrect "one-quarter" claim was corrected in place in the record. The theorem explains why the measurement came out the way it did.

---

## Wall 2: The Pythagorean shortcut is a loop

### A beautiful tree

Every primitive Pythagorean triple, such as $3^2 + 4^2 = 5^2$ or $5^2 + 12^2 = 13^2$, sits in a single infinite ternary tree discovered by Berggren. Three fixed matrices generate the whole tree from $(3,4,5)$. People have long wondered whether this structure could be used for factoring: put $N$ in a triple, walk the tree, and hope a factor appears along the way.

### The theorem

The campaign proved that the information-carrying part of any such scheme reduces to a single greatest common divisor, and that finding the triple is as hard as factoring.

> **Leg-Channel Theorem.** Let $N > 1$. If $N^2 + b^2 = c^2$ with $b > 0$ and $c - b \neq 1$, then $\gcd(c - b, N)$ is a nontrivial divisor of $N$, strictly between $1$ and $N$.

Here is why. Rewrite the triple as $(c - b)(c + b) = N^2$. Put $u = c - b$ and $v = c + b$, so $u < v$ and $uv = N^2$, which forces $u < N$. If $\gcd(u, N)$ were $1$, then $u$ would be coprime to $N^2$ while dividing it, so $u = 1$, which is excluded. And $\gcd(u, N) \le u < N$. So the gcd lies strictly between $1$ and $N$.

The excluded case $c - b = 1$ is a real triple. For every odd $N = 2k+1$,
$$N^2 + (2k^2+2k)^2 = (2k^2+2k+1)^2,$$
and it tells you nothing. In the other direction, any factorization hands you a nontrivial triple. If $N = de$ with $e = 2m + 1$, then scaling the trivial triple of $e$ by $d$ gives a triple on leg $N$ with $c - b = d$. Putting the two directions together:

> **For odd $N > 1$: $N$ is composite if and only if $N$ is a leg of a Pythagorean triple with $b > 0$ and $c - b \ne 1$.**

So finding a useful triple *is* factoring, in a different form. With $N = 15$ there are four triples:
$$15^2 + 112^2 = 113^2,\quad 15^2 + 36^2 = 39^2,\quad 15^2 + 20^2 = 25^2,\quad 15^2 + 8^2 = 17^2.$$
Their differences $c - b$ are $1, 3, 5, 9$, and the gcds with 15 are $1, 3, 5, 3$. The trivial triple gives nothing, and each of the others gives a factor. Whatever walk through Berggren's tree reaches one of those triples has done the work of factoring along the way. The tree adds no shortcut.

---

## Wall 3: You cannot tell which factor is which

### The "first factor" fallacy

Some proposed side channels aim not to find the factors themselves but to learn *something* about them, such as which one is "first", or which one has a certain Galois or Frobenius property. Under the hood, many such proposals ask a public quantity to distinguish the ordered pair $(p, q)$ from $(q, p)$. But every public quantity computed from $N$ alone is the same for both orderings, since $N = pq = qp$.

### The theorem

The campaign turned this observation into an exact counting theorem.

> **Which-Factor Wall.** Let $S$ be a finite set of secrets with an involution $\sigma$ (a map with $\sigma(\sigma(x)) = x$ that sends $S$ to itself). Let $R$ be a "readout" with $R(\sigma x) = R(x)$, and let $L$ be a "label" with $L(\sigma x) \ne L(x)$ for all $x$ in $S$. Then for **every** decoder $D$, the number of secrets with $D(R(x)) = L(x)$ is at most $|S|/2$.

The proof is a pairing argument. If $D$ is correct on $x$, it is wrong on $\sigma x$: both have the same readout, so $D$ gives the same answer for both, but their labels differ. So $\sigma$ maps the set where $D$ is correct one-to-one into the set where it is wrong. Hence at most half of $S$ can be correct.

In the factoring setting, take $S$ to be the ordered pairs $(p,q)$ of distinct primes from some finite list, $R(p,q) = pq$, and $L(p,q) = p$. **No algorithm, of any running time, can name the first factor correctly on more than half of the pairs.** The bound is also sharp. The decoder "output the least prime factor of $N$" is correct on exactly the pairs with $p < q$, which is exactly half.

The point is that a side channel whose target is order-sensitive while its input is symmetric is blind by construction. Computing harder does not help. The campaign used this, together with an abelianization cap and a "no-pruning" argument for torsors, to close the Galois side-channel family in three independent ways.

---

## Wall 4: Pairs of sets with prime differences

### The open door

One of the campaign's three remaining open questions comes from a divisor-covering approach. The one-dimensional version of that approach was refuted by a published theorem of He and Sahai. The *rank-two* version is still open. Roughly, it asks for two sets $A$ and $B$, each of size about $n^{1/3}$, such that the differences $a - b$ produce about $n^{2/3}$ distinct primes.

No such construction is known. What the campaign proved are two unconditional constraints that any construction must satisfy.

### No slack

> **Capacity.** If every element of a target set $T$ has the form $|a - b|$ with $a \in A$ and $b \in B$, then $|T| \le |A|\cdot|B|$. If equality holds, distinct pairs $(a, b)$ give distinct differences.

With $|A| = |B| = n^{1/3}$ and $|T| = n^{2/3}$, equality holds, so **every pair has to contribute a different prime**. There is no room for even one repeat.

### Residue rigidity

> **Local Residue Budget.** Suppose every difference $a - b$ (with $a \in A$, $b \in B$) is a prime larger than $m$. Then for every prime $\ell \le m$, the residues of $A$ modulo $\ell$ and the residues of $B$ modulo $\ell$ are disjoint, so
> $$\#(A \bmod \ell) + \#(B \bmod \ell) \le \ell.$$

The reason is short: if some $a \equiv b \pmod \ell$, then $\ell$ divides the prime $a - b$, which is larger than $\ell$, and that is impossible. The case $\ell = 2$ is already strong. All of $A$ has one parity and all of $B$ has the other.

For example, $A = \{0, 6\}$ and $B = \{-5, -11\}$ give differences $5, 11, 11, 17$, all prime. Modulo 2, $A$ lands on $\{0\}$ and $B$ on $\{1\}$. Modulo 3, $A$ lands on $\{0\}$ and $B$ on $\{1\}$. The residues are disjoint, as the theorem requires. The prime 11 appears twice, so this small cover is not injective and would fail the capacity condition at full size. A computer search does find tight examples at small scale. One pair of five-element sets produces 25 differences, all distinct primes. Its residue classes are confined exactly as the budget predicts: modulo 7, the two sets together occupy only 6 of the 7 classes.

These constraints together say that a rank-two construction must sit inside a product of "residue boxes" that avoid the diagonal at every small prime, and must also be perfectly injective. That is exactly the setting of a two-dimensional sieve, and it points to the next step: a global sieve bound that might close this door as well.

---

## The rest of the map

These four theorems are the newly proved part of a larger picture. In the campaign's own summary:

- The deterministic $N^{1/5}$ bound was re-derived three independent ways. In each derivation, the bound comes from the core "motif" of the algorithm. Constraints on the other parts are *slack*, meaning they are not active at the optimum. A general lesson came out of this, the **slack-constraint principle**: tightening a hypothesis moves an exponent only if the corresponding constraint is active at the unconstrained optimum.
- Smoothness-based ideas turned out to be deep, but *orthogonal* to the $N^{1/5}$ record, which contains no smoothness term.
- Transcendence methods (Baker-type bounds on linear forms in logarithms) were closed because of an object mismatch: those bounds never see $N$.
- The class-group route turned out to be priced by the Extended Riemann Hypothesis rather than by Cohen–Lenstra heuristics. A transfer from families to subfamilies that would have helped was measured to fail by a wide margin (a $z$-score of $-41.4$).
- For the quadratic sieve, a **complete-cost rule** reversed an earlier conclusion. You have to count the sieve *plus* the linear algebra. Counting the sieve alone gets the sign of a key trade-off wrong.

The campaign also corrected its own record. A claimed "absolute" density barrier was downgraded to a conjecture. A claim that a certain 2-torsion group is always $C_2$ turned out to be false when $N \equiv 1 \pmod 4$. An inequality had been used in the wrong direction. One of the campaign's own posts was retracted because its numbers had been published before adversarial checking.

---

## Why a negative result can be the right result

It is tempting to treat "no new algorithm" as a non-result. But compare the two possible end states. In one, a dozen ideas have been tried and abandoned, and nobody can say whether they failed for a deep reason or for lack of effort. In the other, each idea is matched with a short theorem showing exactly where it breaks:

- the polynomial family cannot move the column set;
- the Pythagorean triple *is* the factorization;
- no symmetric readout can tell the factors apart better than a coin flip;
- a prime-difference cover must be perfectly injective and residue-rigid.

The second state is much more useful to the next researcher. It shows which doors are closed, why they are closed, and which three are still open: a rank-two separability construction, an upper bound on smooth values of structured polynomial forms, and a class-number bound for a single imaginary quadratic field $\mathbb{Q}(\sqrt{-pq})$.

The deterministic exponent $1/5$ is still where it was. The map of what lies around it is now considerably more detailed.
