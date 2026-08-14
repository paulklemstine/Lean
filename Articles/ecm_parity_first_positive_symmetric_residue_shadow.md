# The Coin Hidden Inside a Cubic

## How a single congruence can tell you that a factoring attack will get lucky — and why it still can't factor anything

### A game of chance played with prime numbers

Suppose someone hands you a large number $N$ and tells you it is a product of two primes, $N = pq$, but refuses to say which two. This is the setting of nearly every act of digital secrecy performed on Earth today. It is also the setting of one of the most elegant algorithms in computational number theory: Hendrik Lenstra's **elliptic curve method** of factorization, or ECM.

The idea behind ECM is a kind of gambling. You pick an elliptic curve — a curve of the form
$$y^2 = x^3 + Ax + B$$
— and pretend to do arithmetic on it "modulo $N$", even though $N$ is not prime and the arithmetic is therefore not quite legal. What is really happening is that you are secretly doing arithmetic on two curves at once: one over the field $\mathbb{F}_p$ with $p$ elements, and one over $\mathbb{F}_q$. Each of those curves has a finite number of points, $\#E(\mathbb{F}_p)$ and $\#E(\mathbb{F}_q)$, and these two numbers are, in general, completely different. If you multiply your starting point by a very smooth integer $k$ — one built out of many small prime factors — you will hit the identity on one curve before the other, exactly when $k$ happens to be a multiple of one of the two orders. At that moment the illegal arithmetic breaks down in a way that spits out $\gcd(\text{something}, N) = p$. The factor falls out.

So ECM lives or dies on the arithmetic of the two numbers $\#E(\mathbb{F}_p)$ and $\#E(\mathbb{F}_q)$. And the most basic question you can ask about a number is whether it is even.

That question — *is the order of the curve even?* — turns out to have a shockingly clean answer, one that reaches all the way from a $19$th-century reciprocity law to the class field theory of imaginary quadratic fields. This article is about that answer, and about the sharp limit on what it can be used for.

### Even or odd: the whole story is in a cubic

Fix an odd prime $p$ and a curve $y^2 = x^3 + Ax + B$ over $\mathbb{F}_p$. Assume the cubic on the right has no repeated roots, which is the condition
$$\Delta = -4A^3 - 27B^2 \neq 0 .$$
Count points the naive way: for each of the $p$ possible values of $x$, look at $f(x) = x^3 + Ax + B$ and ask how many $y$ satisfy $y^2 = f(x)$. The answer is $2$ if $f(x)$ is a nonzero square, $0$ if it is a non-square, and — crucially — exactly $1$ if $f(x) = 0$. Add one more point "at infinity", the identity of the group law, and you have the order $\#E(\mathbb{F}_p)$.

Now count modulo $2$. Every $x$ contributes an even number of points except the ones where the cubic vanishes; and there is the single point at infinity. Therefore

> **The Parity Dichotomy.** *For an odd prime $p$ and a separable cubic $x^3+Ax+B$ over $\mathbb{F}_p$, the order $\#E(\mathbb{F}_p)$ is even if and only if the cubic has a root in $\mathbb{F}_p$.*

Geometrically this is the familiar statement that a point of order two on a Weierstrass curve is a point $(a,0)$ with $f(a) = 0$. But the counting proof needs no group law at all — just the observation that square roots come in pairs unless they are zero. One tiny extra ingredient completes the picture: a separable cubic over a field can have $0$, $1$, or $3$ roots, but never exactly $2$, because knowing two roots $a \ne b$ forces the third to be $-(a+b)$ (the roots of a depressed cubic sum to zero). So "has a root" is the same as "has an odd number of roots", and the parity bookkeeping closes.

### Frobenius, the three-card shuffle

Behind the count sits a permutation. The cubic $x^3+Ax+B$ always has three roots somewhere — in the algebraic closure of $\mathbb{F}_p$ — and the Frobenius map $x \mapsto x^p$ shuffles them. Because it is a field automorphism, it permutes the three roots among themselves, and there are only three possibilities for how:

- **the identity**, in which case all three roots are already in $\mathbb{F}_p$: cycle type $[1,1,1]$;
- **a transposition**, fixing exactly one root: cycle type $[1]$, one rational root;
- **a $3$-cycle**, fixing none: cycle type $[3]$, no rational root.

For the "generic" cubic — one whose Galois group over $\mathbb{Q}$ is the full symmetric group $S_3$ — Chebotarev's density theorem says these occur with the densities of the corresponding conjugacy classes in $S_3$: $1/6$, $1/2$, $1/3$. Combining with the parity dichotomy:
$$\Pr\bigl[\,2 \mid \#E(\mathbb{F}_p)\,\bigr] = \tfrac16 + \tfrac12 = \tfrac23 ,$$
the complement of the $1/3$ chance that the Frobenius is a $3$-cycle. A numerical count over all primes below $20{,}000$ for the curve $y^2 = x^3 + x + 1$ gives $0.6668$. The theory is not being coy.

### The half of the primes where the coin is not a coin

Here is where it becomes interesting. There is a classical way to detect *half* of a permutation's identity without solving anything: its **sign**. And for a cubic, the sign of the Frobenius permutation is visible in the discriminant.

> **The Cubic Parity Law.** *For a separable cubic over $\mathbb{F}_p$ ($p$ odd), the discriminant $\Delta$ is a non-square modulo $p$ exactly when the Frobenius is a transposition — that is, exactly when the cubic has precisely one root in $\mathbb{F}_p$.*

The delicate half of this is that a rootless cubic must have square discriminant. The proof is a small gem. If the cubic has no root, it is irreducible, so $K = \mathbb{F}_p[x]/(f)$ is the field with $p^3$ elements, and inside it the three roots are $a$, $a^p$, $a^{p^2}$, cyclically permuted by Frobenius. The product of root differences
$$\delta = (a - b)(b - c)(c - a)$$
is unchanged by a *cyclic* rotation of the three roots, so $\delta^p = \delta$, which means $\delta$ lives in the prime field $\mathbb{F}_p$ — and $\delta^2 = \Delta$. Square, as claimed.

Now put the two theorems together. If $\Delta$ is a non-square mod $p$, the Frobenius is a transposition, so the cubic has a root, so the order is even. Not "probably even". **Even, always.**

> **The pinned face.** *If $\Delta$ is a quadratic non-square modulo $p$, then $2 \mid \#E(\mathbb{F}_p)$ — with probability exactly $1$.*

On the other half of the primes, where $\Delta$ *is* a square, the Frobenius lies in the alternating subgroup $A_3 = \{\text{identity}, \text{two } 3\text{-cycles}\}$, and the chance of an even order collapses from $2/3$ to $1/3$. The global average $2/3$ is a blend of a certainty and a long shot.

### Turning it into a congruence

For a curve you can read a Legendre symbol; but the whole point of the factoring setting is that you do not know $p$. What you know is $N$. Can the pinned face be detected from $N$?

For the curve $y^2 = x^3 + x + 1$ — a standard first choice in ECM implementations — the discriminant is
$$\Delta = -4 - 27 = -31 ,$$
a negative prime, and $31 \equiv 3 \pmod 4$. That is precisely the situation in which Gauss's law of quadratic reciprocity is at its cleanest: for any odd prime $p \ne 31$,
$$\left(\frac{-31}{p}\right) = \left(\frac{p}{31}\right).$$
The left side is a fact about the curve over $\mathbb{F}_p$; the right side depends on nothing but the residue of $p$ modulo $31$. A statement about elliptic curves has become a statement about a two-digit congruence.

And Jacobi symbols multiply. For a semiprime $N = pq$,
$$\left(\frac{N}{31}\right) = \left(\frac{p}{31}\right)\left(\frac{q}{31}\right),$$
and this is computable from $N$ alone — indeed from $N \bmod 31$ alone. If the product is $-1$, then one of the two factors must be a non-residue mod $31$, and for that factor the discriminant is a non-square, and the curve order there is even. Hence:

> **The symmetric residue shadow.** *Let $N = pq$ with $p, q$ odd primes different from $31$. If the Jacobi symbol $(N \mid 31) = -1$, then the order of $y^2 = x^3+x+1$ is even over $\mathbb{F}_p$ or over $\mathbb{F}_q$.*

Half of all $N$ pass this test, and for every one of them a fact about the hidden factorization is certain. Read one residue; learn something guaranteed about primes you cannot see.

### The catch, and it is fatal

The theorem says "$p$ **or** $q$". It does not say which. And that word is the entire difference between an amusing structure and a factoring attack.

The situation is exactly measurable in bits. Model the two Legendre symbols $(p \mid 31)$ and $(q \mid 31)$ as fair independent coins. Let $Y$ be the event "the order is even at $p$, or at $q$, or both". Conditioned on the Jacobi symbol being $-1$ (one factor a residue, one not), $\Pr[Y] = 1$. Conditioned on $+1$, the two symbols agree: either both are $-1$, in which case $Y$ is again certain, or both are $+1$, in which case each factor independently has an even order with probability $1/3$ and $\Pr[Y] = 1 - (2/3)^2 = 5/9$. Averaging, $\Pr[Y \mid +1] = \tfrac12\cdot 1 + \tfrac12\cdot\tfrac59 = \tfrac79$. The mutual information between the observable residue and the event is then
$$I = H\!\left(\tfrac89\right) - \tfrac12 H\!\left(\tfrac79\right) = 0.1212\ \text{bits},$$
where $H$ is the binary entropy function; a simulation over $40{,}000$ random semiprimes returns $0.125$ bits, and confirms that essentially all of it — to within $0.0003$ bits — is carried by the Jacobi symbol rather than by the finer residue $N \bmod 31$.

An eighth of a bit is real: it is orders of magnitude above the statistical noise floor for such an experiment, and it is *structural*, not a fluctuation. If, instead, you were allowed to see the individual prime $p$, the same channel would carry $H(2/3) - \tfrac12 H(1/3) = 0.459$ bits — almost four times as much. That collapse from $0.459$ to $0.121$ is the arithmetic cost of the symmetry: the Jacobi symbol is a product, and a product is blind to the order of its factors. The shadow is real; it is a shadow of both factors at once, and no amount of squinting separates them. As a factoring tool, therefore, the whole structure is **useless** — a clean negative result of the sort that maps out where the boundary between "visible" and "hidden" actually runs.

It is worth stressing that the gain being wasted is not imaginary. Among the $2{,}260$ primes below $20{,}000$ (excluding $2$ and $31$), the pinned half — those $p$ that are non-residues mod $31$ — has an average of $2.00$ factors of $2$ in the order of $y^2 = x^3+x+1$, against $1.08$ on the free half, and its orders are $60$-smooth $31.0\%$ of the time against $29.3\%$. Those are exactly the numbers a factoring algorithm would like to exploit. It simply has no way to aim them.

### Two finer structures, one of them a surprise

Once you know the order is even, you can ask for more: is it divisible by $4$? Here the count has to be refined, and the tool is an involution. If $a$ is a rational root of the cubic, the map
$$\tau_a(x) = a + \frac{k}{x - a}, \qquad k = 3a^2 + A,$$
is translation by the two-torsion point $(a,0)$, read off on $x$-coordinates alone. It shuffles the set of $x$ whose fibre has two points, and pairs its elements up — so the *parity* of that set is exactly the number of $\tau_a$-fixed points, i.e. the number of solutions of $(x-a)^2 = k$. That is a Legendre symbol.

The outcome:

> **Split face.** *If the cubic has all three roots in $\mathbb{F}_p$ — full rational two-torsion — then $4 \mid \#E(\mathbb{F}_p)$.*

> **One-root face.** *If the cubic has the unique root $a$, then $\#E(\mathbb{F}_p) \equiv 2 \pmod 4$ if and only if $k = 3a^2 + A$ is a non-square modulo $p$; otherwise $4 \mid \#E(\mathbb{F}_p)$.*

The second statement corrects a natural guess. It is tempting to believe that a transposition Frobenius always yields exactly one factor of $2$ — one rational two-torsion point, order $\equiv 2 \pmod 4$. It is false, and the smallest witness is charming: at $p = 23$, the cubic $x^3+x+1$ has the single root $a = 4$, yet $\#E(\mathbb{F}_{23}) = 28$, divisible by $4$. The reason is exactly the criterion: $k = 3\cdot 16 + 1 = 49 \equiv 3 \pmod{23}$, and $3 = 7^2$ is a square mod $23$, so the two-torsion point $(4,0)$ is itself divisible by $2$ in the group — there is a point of order $4$ sitting above it, invisible to the cycle type of the Frobenius.

That difference matters for ECM, because the algorithm cares about smoothness, and a guaranteed factor of $4$ is twice as valuable as a guaranteed factor of $2$.

### And a nineteenth-century mirror

Finally, the deepest of the three faces. When does the cubic split completely — when is the Frobenius the identity? The splitting field of $x^3+x+1$ is an $S_3$-extension of $\mathbb{Q}$ containing $\mathbb{Q}(\sqrt{-31})$, and that quadratic field has class number $3$. Class field theory identifies the $S_3$-field as the **Hilbert class field** of $\mathbb{Q}(\sqrt{-31})$; splitting completely there is the same as the prime ideal above $p$ being principal, which for an imaginary quadratic field is the same as $p$ being represented by the principal binary quadratic form. Concretely:

> *The cubic $x^3+x+1$ splits into three linear factors modulo $p$ if and only if $4p = A^2 + 31B^2$ for integers $A \equiv B \pmod 2$.*

The smallest example is $p = 47$: $4\cdot 47 = 188 = 8^2 + 31\cdot 2^2$, and indeed $x^3+x+1$ has three roots mod $47$ and $\#E(\mathbb{F}_{47}) = 60$, divisible by $4$. A test over all $2{,}260$ good primes below $20{,}000$ produces zero mismatches. Combined with the mod-$4$ results, this gives a purely classical criterion with an elliptic consequence:

> *If $4p = A^2 + 31B^2$, then $\#E(\mathbb{F}_p)$ is never congruent to $2$ modulo $4$: it is either odd or divisible by $4$.*

Two centuries of quadratic forms, and the payoff is a statement about the two-part of a group of points.

### The moral

There is a temptation, when a structure this exact appears in a cryptographic setting, to expect a crack. Here the exactness is total — conditional probability $1$, not $0.9999$ — and the crack does not appear. The reason is a symmetry that is easy to state and impossible to evade: the observable, the Jacobi symbol of $N$, is a *product* over the hidden factors, and it therefore knows only symmetric functions of what happens at $p$ and at $q$. Factoring needs an asymmetric fact. The channel delivers $0.12$ bits of perfectly reliable symmetric information, and $0$ bits of the asymmetric kind.

That is worth knowing precisely because it is the shape of most near-misses in this subject. A residue dial that pins an elliptic invariant with certainty, a class field lurking behind a quadratic form, an involution that computes a group's two-part without ever invoking the group law — all real, all beautiful, and all firmly on the safe side of the line.
