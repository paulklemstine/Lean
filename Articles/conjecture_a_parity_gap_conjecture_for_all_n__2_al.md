# The Gap That Never Closes

## A parity contest among permutations, and why prime numbers always break the tie

Fix a prime $p$ — say $p = 7$ — and two lists of distinct residues modulo $p$, each of length $n$. Call them $S$ and $T$; say $n = 3$, $S = (1, 2, 4)$, $T = (0, 1, 3)$.

Match the entries of $S$ against the entries of $T$ in every possible way. Each matching is a permutation $\sigma$ of $\{1, \dots, n\}$, and each carries a single number, its **exponent**:

$$E_\sigma \;=\; \sum_{j=1}^{n} S(\sigma(j)) \cdot T(j) \pmod p .$$

There are $n!$ permutations but only $p$ possible values, so when $n!$ exceeds $p$ the exponents pile up: many matchings share a residue.

Here is the scoring rule. Every permutation has a **sign**: $+1$ if built from an even number of swaps, $-1$ if from an odd number. For each residue $r$, add up the signs of the permutations landing on $r$:

$$c_{S,T}(r) \;=\; \sum_{\substack{\sigma \\ E_\sigma = r}} \operatorname{sgn}(\sigma).$$

This integer measures the *parity imbalance* at $r$. Call $c_{S,T}$ the **parity-weighted exponent counter**.

Since exactly half of all permutations are even once $n \geq 2$, the total imbalance is zero:

$$\sum_{r \in \mathbb{Z}/p} c_{S,T}(r) = 0 .$$

Even and odd matchings are in perfect *global* balance. So one might imagine perfect *local* balance too: cancellation at every single residue, $c_{S,T}$ identically zero. We would say the **parity gap has closed**.

**Conjecture A**, now a theorem, says this never happens when $p$ is prime.

> **Theorem (the parity gap never closes).** Let $p$ be prime and let $S, T \colon \{1, \dots, n\} \to \mathbb{Z}/p$ be injective. Then some residue $r$ has $c_{S,T}(r) \neq 0$, hence $|c_{S,T}(r)| \geq 1$. Moreover $\max_r |c_{S,T}(r)|$ is attained at a residue of the form $E_\sigma$ for a permutation $\sigma$ of *minimal Coxeter length* — fewest inversions — among all permutations with that exponent.

Global cancellation is forced; local cancellation is impossible. That tension is the story.

---

## The determinant in disguise

The counter looks combinatorial, but it is a determinant in costume. Let $\zeta$ be a primitive $p$-th root of unity and set

$$M \;=\; \bigl( \zeta^{\,S(j) \cdot T(k)} \bigr)_{1 \le j, k \le n}.$$

This is a *minor* of the discrete Fourier matrix $(\zeta^{ab})_{a,b}$ of $\mathbb{Z}/p$, carved out by the rows in $S$ and columns in $T$. By the Leibniz formula,

$$\det M \;=\; \sum_{\sigma} \operatorname{sgn}(\sigma)\, \zeta^{E_\sigma} \;=\; \sum_{r \in \mathbb{Z}/p} c_{S,T}(r)\, \zeta^{r}.$$

The parity counter is exactly the coefficient list of the determinant in the basis of powers of $\zeta$. Hence:

**the parity gap stays open $\iff$ $\det M \neq 0$ $\iff$ every square minor of the Fourier matrix of $\mathbb{Z}/p$ is nonsingular.**

That last statement is **Chebotarev's theorem on roots of unity**: *for prime $p$, every square submatrix of the $p \times p$ Fourier matrix is invertible.* A generic matrix has singular minors almost by accident; the Fourier matrix of a prime cyclic group has none, in any size, for any rows and columns. Chebotarev proved it in the 1920s, and it has been reproved many ways. What follows is a self-contained route using only the arithmetic of $\mathbb{Z}[\zeta]$ and one fact about sparse polynomials in characteristic $p$.

---

## The one prime that ramifies

Everything hinges on a single arithmetic accident. In $\mathbb{Z}[\zeta]$ the rational prime $p$ is no longer prime: setting

$$\pi = \zeta - 1 ,$$

one finds that $\pi$ divides $p$, and $p$ is — up to a unit — the $(p-1)$-st power of $\pi$. There is exactly one prime above $p$, and it is *totally ramified*. Reduction modulo $\pi$ is a ring homomorphism

$$\mathrm{red} \colon \mathbb{Z}[\zeta] \longrightarrow \mathbb{F}_p, \qquad \zeta \longmapsto 1,$$

whose kernel is the set of multiples of $\pi$.

This map is a brutal simplification: it collapses *every* power of $\zeta$ to $1$. That is exactly why it helps. Push a linear relation among the columns of $M$ through it, and all the distinct roots of unity that carried the Fourier information fuse into the single value $1$. Whatever survives such a collapse is structure of the crudest, most countable kind.

---

## The proof, in four moves

Suppose, for contradiction, that $\det M = 0$.

**Move 1: a primitive kernel vector.** Since $\mathbb{Z}[\zeta]$ is an integral domain, a vanishing determinant gives a nonzero $v$ with $Mv = 0$. Its coordinates may all be divisible by $\pi$; if so, divide through. This terminates, because no nonzero element of $\mathbb{Z}[\zeta]$ is divisible by arbitrarily high powers of $\pi$ (Krull's intersection theorem: in a Noetherian domain the intersection of the powers of a proper ideal is zero). So $v = \pi^m w$ for a largest $m$, and some $\mathrm{red}(w_k) \neq 0$. Being in a domain, $w$ is still a kernel vector.

**Move 2: a sparse polynomial.** Define

$$f(X) \;=\; \sum_{k=1}^{n} w_k \, X^{\,T(k)} \;\in\; \mathbb{Z}[\zeta][X],$$

with $T(k)$ read as an integer in $\{0, \dots, p-1\}$. The relation $Mw = 0$ says precisely that for each row $j$,

$$f\bigl(\zeta^{\,S(j)}\bigr) \;=\; \sum_k w_k \, \zeta^{\,S(j) T(k)} \;=\; 0 .$$

Since $S$ is injective and $\zeta$ has order $p$, the $n$ points $\zeta^{S(j)}$ are pairwise distinct, and over an integral domain distinct roots give distinct linear factors:

$$\prod_{j=1}^{n} \bigl(X - \zeta^{S(j)}\bigr) \quad \text{divides} \quad f(X).$$

So far there is no contradiction: a polynomial with $n$ terms can have $n$ roots. The contradiction appears only after the collapse.

**Move 3: collapse modulo $\pi$.** Apply $\mathrm{red}$ coefficientwise. Every root $\zeta^{S(j)}$ maps to $1$, so the product of linear factors becomes $(X-1)^n$: $n$ distinct roots fuse into one root of multiplicity $n$. Writing $\bar f \in \mathbb{F}_p[X]$ for the reduction,

$$(X-1)^n \ \big| \ \bar f, \qquad \bar f \neq 0, \qquad \bar f \text{ has at most } n \text{ terms}, \qquad \deg \bar f < p .$$

Nonvanishing of $\bar f$ is exactly what the normalisation in Move 1 bought; the degree bound holds because the exponents $T(k)$ are residues.

**Move 4: sparse polynomials cannot be that degenerate.**

> **Sparse-multiplicity lemma.** Let $f \in \mathbb{F}_p[X]$ be nonzero with $\deg f < p$. If $(X-1)^n$ divides $f$, then $f$ has **strictly more than $n$** nonzero coefficients.

Over $\mathbb{C}$ this is classical; over $\mathbb{F}_p$ the degree hypothesis is essential. The proof is a descent on $n$. First divide out the largest power of $X$: this changes neither the term count nor divisibility by $(X-1)^n$, since $X$ and $X-1$ are coprime. So $f$ has a nonzero constant term. Now differentiate: $f'$ is divisible by $(X-1)^{n-1}$, it has lost the constant term, and it has lost nothing else, since $c X^{e} \mapsto e c X^{e-1}$ with $e \not\equiv 0 \pmod p$ — here $\deg f < p$ does its work. So $f'$ has exactly one term fewer, and induction applies.

**The contradiction.** Move 3 gives $\bar f$ with at most $n$ terms; Move 4 demands more than $n$. Hence $\det M \neq 0$: the parity gap never closes. $\blacksquare$

What makes the argument work is the ramification. The single prime $\pi$ crushes $n$ separated Fourier frequencies into one root of multiplicity $n$, turning a statement about separation into a statement about concentration — and concentration is what sparse polynomials cannot afford.

---

## The minimal-length witness

Conjecture A asked for a canonical witness. Each permutation has a **Coxeter length** $\ell(\sigma)$: the number of inversions, equivalently the least number of adjacent transpositions building $\sigma$. Length and sign are linked by $\operatorname{sgn}(\sigma) = (-1)^{\ell(\sigma)}$, and $\ell(\sigma) = 0$ exactly for the identity.

The refinement follows from nonvanishing. Choose $r_{\max}$ maximising $|c_{S,T}(r)|$; the maximum is at least $1$, so the fibre of permutations with exponent $r_{\max}$ is nonempty, and a nonempty finite set of permutations contains one of least length. That $\sigma$ meets all three demands: its exponent carries an imbalance of size $\geq 1$, that imbalance is the largest anywhere, and nothing shorter shares its exponent.

---

## Why primality is the whole point

One might guess the gap stays open for combinatorial reasons — that $n!$ signs cannot conspire to cancel everywhere. They can, and over composite moduli they do.

Take $m = 4$, $S = T = (0, 2)$, both injective in $\mathbb{Z}/4$. Every product $S(i)T(j)$ is $0$ or $4 \equiv 0$, so every permutation has exponent $0$; the two permutations have signs $+1$ and $-1$ and cancel. The gap has closed.

Generally, if $m = ab$ with $a, b \geq 2$, the progressions $S(i) = a i$ and $T(j) = b j$ annihilate each other modulo $m$, so all exponents vanish and the signed count cancels at every width $2 \le n \le \min(a,b)$. With Chebotarev's theorem this gives a clean characterisation:

> **Theorem (the parity gap detects primality).** For $m \geq 2$, some injective pair $S, T$ of some width $n \geq 2$ has identically vanishing counter **if and only if $m$ is composite.**

---

## How wide can a closed gap be?

The annihilating-progressions construction caps out near $\sqrt m$. A far more efficient mechanism reaches much further, and it is pure combinatorics.

> **Pigeonhole cancellation criterion.** Suppose a set $J$ of row indices and a subgroup $B \leq \mathbb{Z}/m$ satisfy: the $S$-values indexed by $J$ annihilate $B$, and the $T$-values fall into strictly fewer than $|J|$ classes modulo $B$. Then $c_{S,T} \equiv 0$.

The proof is a sign-reversing involution. For any $\sigma$, pigeonhole forces two columns in the same class mod $B$ to be matched with rows from $J$. Swapping them changes the exponent by $(S(\sigma j_1) - S(\sigma j_2))(T(j_1) - T(j_2))$, which vanishes since the $T$-difference lies in $B$. The swap preserves the exponent and flips the sign, so every fibre pairs off — and here, unlike before, the exponent map is wildly non-constant. This yields closure at every width $2 \leq n \leq m - a$ whenever $m = ab$, in particular up to $m-2$ for even $m$.

Conversely the gap never closes at the top two widths, over *any* modulus. At $n = m$ the matrix is a Vandermonde matrix in $m$ distinct roots of unity. At $n = m-1$ a vanishing counter would give a nonzero function supported on $m-1$ points whose Fourier transform lives at a single point — but a one-point spectrum means a multiple of a character, which has full support. Hence:

> **Theorem (maximal width for even moduli).** For even $m \geq 4$ and $n \geq 2$, the parity gap closes at width $n$ over $\mathbb{Z}/m$ **if and only if** $n \leq m - 2$.

Primes admit no closure at any width; even composites admit closure at exactly widths $2$ through $m-2$; general composites admit closure at least up to $m - q$ for $q$ the least prime factor, and never at $m-1$ or $m$.

---

## Uncertainty, and why you should care

Chebotarev's theorem is prized far outside number theory because of a consequence phrased in signal processing.

The **support** of $f \colon \mathbb{Z}/p \to \mathbb{C}$ is the set where it is nonzero; $\hat f$ is its Fourier transform. Uncertainty principles say a signal and its spectrum cannot both be concentrated: the Donoho–Stark bound gives $|\mathrm{supp}\, f| \cdot |\mathrm{supp}\, \hat f| \geq p$ over any cyclic group. For primes something stronger holds:

> **Additive uncertainty principle.** For prime $p$ and nonzero $f \colon \mathbb{Z}/p \to \mathbb{C}$,
> $$|\mathrm{supp}\, f| + |\mathrm{supp}\, \hat f| \;\geq\; p + 1 .$$

This is exactly equivalent to Chebotarev's theorem. Indeed, $f$ supported in $A$ with $\hat f$ supported in $B$ and $|A| + |B| \le p$ is the same as singularity of a certain $|A| \times |A|$ Fourier minor indexed by $A$ and the complement of $B$; nonsingularity of all minors kills every such $f$. Since $ab + 1 \geq a + b$, the additive bound implies the multiplicative one.

The consequence is striking: a signal with $k$ nonzero samples has a spectrum missing at most $k - 1$ frequencies. Hence a $k$-sparse signal on $\mathbb{Z}/p$ is reconstructed *exactly* from any $2k$ Fourier samples — two distinct $k$-sparse signals agreeing on $2k$ frequencies would differ by a $2k$-sparse signal with $2k$ vanishing Fourier coefficients, which the theorem forbids. Over composite moduli this fails, and the failures are the closed parity gaps above: for $m = ab$, the indicator of the subgroup of order $a$ has support $a$ and spectrum of support $b$.

---

## Depth and rigidity

How close to zero is $\det M$? The natural measure is its $\pi$-adic order. Writing $\zeta^{S(j)} = 1 + u_j$ with each $u_j$ divisible by $\pi$ and expanding the rows multilinearly, the alternating property kills every term expanding two rows to the same Taylor order; surviving terms carry distinct orders and hence at least $0 + 1 + \dots + (n-1) = \binom n 2$ factors of $\pi$. So

$$\pi^{\binom n 2} \ \big| \ \det M ,$$

with finite order by Chebotarev. For $n = 2$ the order is exactly $1$, and $\binom n2$ is conjecturally exact for all $n \le p$.

This has a disorienting consequence. Since $p$ is a unit times $\pi^{p-1}$, once $\binom{n}{2} \geq p - 1$ the whole minor is divisible by $p$, and the counter becomes rigid:

> **Rigidity theorem.** If $\binom n 2 \geq p-1$, then $c_{S,T}(r)$ is the *same modulo $p$* for every residue $r$.

The reason: $\det M$ is the image of $\sum_r c_{S,T}(r) X^r$ in $\mathbb{Z}[X]/(\Phi_p)$, and divisibility by $\pi^{p-1}$ becomes divisibility of the mod-$p$ reduction by $(X-1)^{p-1} = 1 + X + \dots + X^{p-1}$. A polynomial of degree below $p$ divisible by that geometric sum is a constant multiple of it.

With the sum rule and nonvanishing, rigidity forces a dichotomy: in the regime $\binom n 2 \ge p-1$, either the counter is nonzero at **every** residue, or it reaches absolute value at least $p$ somewhere. More generally, for any $n$, the counter is supported on more than $\min\bigl(\binom n2, p-1\bigr)$ residues or attains absolute value at least $p$.

The moral is that the phenomenon making Chebotarev's theorem hard is the one producing rigidity: one cannot prove nonvanishing by reducing modulo $p$, because for large $n$ the determinant *is* divisible by $p$. The proof must live in $\mathbb{Z}[\zeta]$.

---

## What is left

**Exact depth.** Is the $\pi$-adic order exactly $\binom n 2$ for every $n \le p$? In the multilinear expansion the unique minimal term has Taylor orders $\{0, 1, \dots, n-1\}$, with coefficient the bialternant

$$\frac{\prod_{i<j}\bigl(S(j)-S(i)\bigr)\bigl(T(j)-T(i)\bigr)}{\prod_{k<n} k!},$$

whose denominator is invertible modulo $p$ exactly when $n \leq p$. The conjecture reduces to a finite identity about determinants of binomial-coefficient matrices.

**Exact rigidity.** Is the counter constant modulo $p^m$ whenever $\binom n 2 \geq m(p-1)$, with $\lfloor \binom n2 / (p-1) \rfloor$ the largest such $m$? The case $m = 1$ is settled.

---

## Coda

The parity-gap question sounds combinatorial: can even and odd matchings cancel at every residue? For primes the answer is no, and the reason is not combinatorial at all. It is that $p$ ramifies completely in the cyclotomic field, that reduction at the ramified prime fuses $n$ distinct roots of unity into one root of multiplicity $n$, and that a polynomial with few terms cannot afford a root of high multiplicity in characteristic $p$. That same chain underwrites the sharpest uncertainty principle known for finite cyclic groups, and with it the exact-recovery guarantees of sparse Fourier sampling. Primes leave no room to hide.
