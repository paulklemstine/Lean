# The Prime Number That Refuses to Cancel

## A hundred-year-old puzzle about roots of unity, and the modern mathematics it unlocked

### A question with no obvious answer

Take a prime number, say $p = 7$. Draw the seven points evenly spaced around the unit circle in the complex plane — the seventh roots of unity. Call the first one after $1$ by the name $\zeta = e^{2\pi i/7}$; the others are its powers $\zeta^0 = 1, \zeta, \zeta^2, \ldots, \zeta^6$.

Now write down the $7 \times 7$ table whose entry in row $j$ and column $k$ is $\zeta^{jk}$. This is the *discrete Fourier transform matrix* of order $7$, the machine that converts a signal defined on the seven residues modulo $7$ into its list of frequencies. It is the finite, discrete cousin of the Fourier transform that underlies every MP3 file, every JPEG, every MRI scan.

Here is the question. Cross out some rows and some columns of that table — any rows, any columns, as long as you keep the same number of each. What's left is a square block, a *minor*. Can that block be singular? Can its determinant be zero?

For a general matrix, of course it can. Most matrices have plenty of singular submatrices. But the DFT matrix is not a general matrix. In 1926 the Russian mathematician Nikolai Chebotarev asked exactly this question and conjectured the striking answer:

> **Chebotarev's Theorem.** Let $p$ be a prime and $\zeta$ a primitive $p$-th root of unity. Then *every* square submatrix of the $p \times p$ matrix $(\zeta^{jk})_{j,k=0}^{p-1}$ is nonsingular.

Every one. There are $\sum_n \binom{p}{n}^2$ of them, and not a single determinant vanishes. For $p = 7$ that's $3431$ minors; for $p = 101$ the count exceeds $10^{59}$. All nonzero.

This is a statement of extraordinary rigidity, and it is genuinely delicate: it is *false* for every composite modulus. Replace $7$ by $N = 4$ and consider $\zeta = i$, rows and columns $\{0, 2\}$. The block is
$$\begin{pmatrix} i^{0} & i^{0} \\ i^{0} & i^{4}\end{pmatrix} = \begin{pmatrix} 1 & 1 \\ 1 & 1 \end{pmatrix},$$
whose determinant is $0$. The same trick works for *any* composite $N$: write $N = de$ with $1 < d < N$, and take rows $\{0, e\}$ and columns $\{0, d\}$. The bottom-right entry is $\zeta^{ed} = \zeta^{N} = 1$, so all four entries equal $1$ and the determinant vanishes. Chebotarev's theorem therefore does not merely *happen* to hold at primes; nonsingularity of all square submatrices is a *characterization* of primality.

Why does the prime case behave so differently? Because when $p$ is prime, no nontrivial rational relation exists among the $p$-th roots of unity beyond the single relation $1 + \zeta + \cdots + \zeta^{p-1} = 0$. Algebraically: the $p$-th cyclotomic polynomial $\Phi_p(X) = 1 + X + \cdots + X^{p-1}$ is irreducible over the rationals. When $N$ is composite, $\Phi_N$ is still irreducible, but the *full set* of $N$-th roots of unity contains proper subgroups, each of which sums to zero, and each such hidden cancellation is exactly what makes a minor collapse.

### Frenkel's polynomial trick

Chebotarev's theorem has a handful of proofs. The one we follow, due to Péter Frenkel, is a magic trick that fits on a postcard, and it is a beautiful illustration of a general strategy: to prove that a complex number is nonzero, exhibit an integer it controls and show that a prime does not divide it.

Fix $n$ distinct residues $a_1, \dots, a_n$ (the rows) and $n$ distinct residues $b_1, \dots, b_n$ (the columns), all in $\{0, 1, \dots, p-1\}$. Suppose, for contradiction, that
$$\det\left(\zeta^{a_i b_j}\right) = 0 .$$

Frenkel's idea is to replace the number $\zeta$ by a *variable*. Consider the polynomial with integer coefficients
$$P(X) \;=\; \det\Big( (1+X)^{\,a_i b_j} \Big)_{i,j=1}^{n} \;\in\; \mathbb{Z}[X].$$
Substituting $X = \zeta - 1$ turns $(1+X)^{a_i b_j}$ into $\zeta^{a_i b_j}$, so our assumption says precisely that $\zeta - 1$ is a root of $P$.

Now two independent computations collide.

**First: $P$ vanishes to high order at $X=0$, and its first nonzero coefficient is prime to $p$.** Write $s_i = (1+X)^{a_i} - 1$; note that $s_i$ is divisible by $X$, with $s_i / X$ having constant term $a_i$. Then $(1+X)^{a_i b_j} = (1+s_i)^{b_j}$, and the binomial theorem expands each entry as
$$(1 + s_i)^{b_j} \;=\; \sum_{k=0}^{p-1} \binom{b_j}{k}\, s_i^{\,k}.$$
The determinant is multilinear in its rows, so expanding all rows at once gives
$$P(X) \;=\; \sum_{f} \left(\prod_{i=1}^{n} s_i^{\,f(i)}\right) \det\left( \binom{b_j}{f(i)} \right),$$
the sum running over all functions $f$ from row indices to $\{0,1,\dots,p-1\}$. If $f$ takes the same value twice, the determinant on the right has two equal rows and dies. So only injective $f$ survive — and for those, the exponents $f(1), \dots, f(n)$ are $n$ distinct nonnegative integers, hence sum to at least the *staircase number*
$$N \;=\; 0 + 1 + 2 + \cdots + (n-1) \;=\; \binom{n}{2}.$$
Since each $s_i$ is divisible by $X$, every surviving term is divisible by $X^{N}$: the polynomial $P$ vanishes to order at least $N$ at the origin.

What is the coefficient of $X^{N}$? Only the terms where the exponents are *exactly* $\{0, 1, \dots, n-1\}$ contribute, and for those the constant term of $s_i / X$ is $a_i$. Summing over all bijections and recognising the resulting expression as a matrix product gives the clean identity
$$[X^{N}]\,P \;=\; \det\!\left(a_i^{\,k}\right)_{i,k=0}^{n-1} \cdot \det\!\left(\binom{b_i}{k}\right)_{i,k=0}^{n-1}.$$
The first factor is a **Vandermonde determinant**, equal to $\prod_{i<j}(a_j - a_i)$. Each difference is a nonzero residue difference of two distinct elements of $\{0,\dots,p-1\}$, hence not divisible by $p$; so the Vandermonde is prime to $p$. The second factor, the determinant of binomial coefficients, satisfies the pretty identity
$$0!\,1!\cdots(n-1)!\;\cdot\;\det\!\left(\binom{b_i}{k}\right) \;=\; \prod_{i<j}(b_j - b_i),$$
because the binomial coefficients are the falling factorials $b(b-1)\cdots(b-k+1)/k!$ and those form a monic polynomial basis. The right side is again prime to $p$, so the binomial determinant is too. **Conclusion: $[X^N]P$ is an integer not divisible by $p$** — in particular nonzero, so the order of vanishing at $0$ is *exactly* $N$.

**Second: the assumption forces $p$ to divide that very coefficient.** If $\zeta - 1$ is a root of $P$, then $\zeta$ is a root of $P(X - 1)$, and since $\zeta$ is an algebraic integer whose minimal polynomial is the irreducible cyclotomic polynomial $\Phi_p$, we get $\Phi_p(X) \mid P(X-1)$, that is,
$$\Phi_p(X+1) \mid P(X).$$
Now look at the shifted cyclotomic polynomial. From $X \cdot \Phi_p(X+1) = (1+X)^p - 1$ one reads off its coefficients:
$$\Phi_p(X+1) \;=\; \sum_{k=0}^{p-1} \binom{p}{k+1} X^{k} \;=\; p + \binom{p}{2}X + \cdots + \binom{p}{p-1}X^{p-2} + X^{p-1}.$$
Every coefficient except the leading one is divisible by $p$; the constant term is exactly $p$. This is the classical Eisenstein pattern that proves $\Phi_p$ irreducible, and here it does a second job. Write $P = \Phi_p(X+1)\, Q$. Because $P$ has no terms below degree $N$, one can peel off the low coefficients of $Q$ one at a time: dividing repeatedly by the constant term $p$ shows $Q$ has no terms below degree $N - (p-1)$ either. Feeding this back into the coefficient formula for a product, every contribution to $[X^N]P$ is divisible by $p$ — either it uses a non-leading coefficient of $\Phi_p(X+1)$, all of which are multiples of $p$, or it uses the leading term $X^{p-1}$ paired with a coefficient of $Q$ that we just showed is zero.

So $p \mid [X^N]P$, contradicting the first computation. Hence $\det(\zeta^{a_ib_j}) \ne 0$. $\blacksquare$

The whole argument is a beautiful example of a *deformation* proof: the vanishing of a single complex determinant is smuggled into an integrality statement about a polynomial, where the prime $p$ can be interrogated directly.

### From algebra to signals: the uncertainty principle

Chebotarev's theorem sounds like a curiosity of cyclotomic algebra. It is in fact a very sharp tool, and Terence Tao showed in 2005 what it is a tool *for*.

The Heisenberg uncertainty principle says a signal cannot be simultaneously concentrated in time and in frequency. Over the cyclic group $\mathbb{Z}/p$ this becomes a clean combinatorial statement about *supports* — the sets of positions where a function is nonzero. Write $\widehat{f}$ for the discrete Fourier transform of $f : \mathbb{Z}/p \to \mathbb{C}$.

> **Uncertainty Principle (prime order).** For every nonzero $f : \mathbb{Z}/p \to \mathbb{C}$ with $p$ prime,
> $$\#\{x : f(x) \ne 0\} \;+\; \#\{t : \widehat{f}(t) \ne 0\} \;\ge\; p+1 .$$

The derivation is a two-line consequence of Chebotarev. Let $A$ be the support of $f$, of size $k$, and suppose the transform vanished on more than $p - k$ frequencies; then we could pick a set $B$ of $k$ frequencies on which $\widehat f$ vanishes. Restricting $f$ to $A$ gives a nonzero vector $v$ with $v^{\mathsf T} M = 0$, where $M$ is the $k \times k$ submatrix of the DFT matrix with rows $A$ and columns $B$. Chebotarev says $M$ is invertible, so $v = 0$ — contradiction. Hence at most $p - k$ frequencies vanish, i.e. $\#\mathrm{supp}\,\widehat f \ge p - k + 1$.

Compare this with the classical, group-theoretic bound $\#\mathrm{supp}\, f \cdot \#\mathrm{supp}\,\widehat f \ge p$, valid for all $p$: at prime order the additive bound is strictly stronger whenever both supports are small, and it is *sharp*. The Dirac spike $\delta_0$, with a single nonzero value, has a transform that is constant and never zero, giving $1 + p = p+1$ exactly.

Far more surprising is that the sharpness is not an accident of the Dirac spike:

> **Sharpness on every support.** For every nonempty $A \subseteq \mathbb{Z}/p$ there exists $f$ whose support is *exactly* $A$ and for which $\#\mathrm{supp} f + \#\mathrm{supp}\widehat f = p+1$.

The construction is pure linear algebra: prescribe an arbitrary set $S$ of $\#A - 1$ frequencies and solve the homogeneous system asking for a function supported in $A$ whose transform kills $S$. There are $\#A$ unknowns and $\#A - 1$ equations, so a nonzero solution exists; the uncertainty principle then forces the solution to have full support $A$ and forces $\widehat f$ to vanish on $S$ and nowhere else. One even gets **rigidity**: when $\#A = \#S + 1$, the space of functions supported in $A$ whose transform vanishes on $S$ is exactly a line — any two such functions are scalar multiples of one another. The extremal configurations of the uncertainty principle are as constrained as they could possibly be.

### Compressed sensing, with no error bars

Modern signal processing is obsessed with the question: how few measurements do I need to reconstruct a signal that is *sparse*? The answers in the continuous world are probabilistic and approximate: with high probability, with random measurement matrices, with some distortion. Over $\mathbb{Z}/p$ Chebotarev gives an answer with no adjectives at all.

> **Exact sparse recovery.** Let $p$ be prime. A $k$-sparse signal on $\mathbb{Z}/p$ — one with at most $k$ nonzero entries — is uniquely determined by its Fourier coefficients on *any* set of $2k$ frequencies.

The proof: if two $k$-sparse signals agree on $2k$ frequencies, their difference is $2k$-sparse and its transform vanishes on $2k$ frequencies, so support sizes total at most $2k + (p - 2k) = p < p+1$, contradicting the uncertainty principle unless the difference is zero.

Note the word *any*. There is no random design, no restricted isometry hypothesis, no failure probability: an adversary may choose the $2k$ frequencies you observe, and the reconstruction is still unique. This is the sharpest possible form of a compressed sensing guarantee.

And $2k$ cannot be improved: with only $2k-1$ prescribed frequencies one can always manufacture two distinct $k$-sparse signals with identical measurements. Take a set $A$ of $2k$ positions, build (by the construction above) a nonzero function $h$ supported in $A$ whose transform vanishes on the given $2k-1$ frequencies, and split $A$ into halves $A_1, A_2$ of size $k$. The signals $h|_{A_1}$ and $-h|_{A_2}$ are $k$-sparse, distinct, and their difference $h$ has vanishing measurements. The information-theoretic threshold sits exactly at $2k$.

### And finally, a classical theorem of additive combinatorics

The last stop on this tour is a theorem from a completely different world. Given two nonempty sets of residues $A, B \subseteq \mathbb{Z}/p$, their sumset $A + B = \{a + b\}$ cannot be too small:

> **Cauchy–Davenport Theorem.** For $p$ prime and nonempty $A, B \subseteq \mathbb{Z}/p$,
> $$\#(A+B) \;\ge\; \min\big(p,\ \#A + \#B - 1\big).$$

This is the founding theorem of additive combinatorics, dating to Cauchy in 1813 and rediscovered by Davenport in 1935. It is usually proved by a clever combinatorial transform or by the polynomial method. Here it drops out of the same Fourier machinery.

Suppose $\#A + \#B \le p+1$ (otherwise a direct pigeonhole argument shows $A+B$ is all of $\mathbb{Z}/p$). Choose a set $T$ of $\#A + \#B - 2$ frequencies and split it as $T = S_A \sqcup S_B$ with $\#S_A = \#A - 1$ and $\#S_B = \#B - 1$. Using the extremal construction, build $f$ supported in $A$ with $\widehat f$ vanishing on $S_A$, and $g$ supported in $B$ with $\widehat g$ vanishing on $S_B$. Their convolution $f * g$ is supported inside $A + B$, and by the convolution theorem $\widehat{f*g} = \widehat f \cdot \widehat g$ vanishes on all of $T$.

Is $f*g$ nonzero? Yes — and here the uncertainty principle does the work twice. Each of $\widehat f$ and $\widehat g$ has support of size at least $p + 1 - \#A$ and $p+1-\#B$ respectively; those two numbers sum to more than $p$, so the supports must intersect. At a common frequency $t$ we have $\widehat{f*g}(t) = \widehat f(t)\widehat g(t) \ne 0$.

Apply the uncertainty principle a third time, now to $h = f*g$:
$$p + 1 \;\le\; \#\mathrm{supp}\, h + \#\mathrm{supp}\, \widehat h \;\le\; \#(A+B) \;+\; \big(p - (\#A + \#B - 2)\big),$$
which rearranges exactly to $\#(A+B) \ge \#A + \#B - 1$. $\blacksquare$

### What the chain of ideas means

Follow the arrows: the irreducibility of a cyclotomic polynomial $\Rightarrow$ no vanishing minors in a Fourier matrix $\Rightarrow$ a sharp uncertainty principle $\Rightarrow$ exact, adversary-proof sparse recovery, and $\Rightarrow$ a cornerstone of additive combinatorics. A fact about how prime-order roots of unity refuse to cancel becomes, three steps later, a statement about how many samples an engineer needs.

That is not a coincidence; it is a recurring pattern. Rigidity in arithmetic — the absence of unexpected algebraic relations — translates into rigidity in analysis, which translates into optimality in computation. When the modulus is composite the whole chain snaps at the first link, and rightly so: composite moduli have subgroups, subgroups produce vanishing sums of roots of unity, and those cancellations are precisely the aliasing that makes signal reconstruction ambiguous. Primality is not a technical hypothesis here. It is the mathematics.

There is one more moral worth recording. Chebotarev's statement concerns exponentially many determinants, each an inscrutable sum of complex numbers, and the proof handles all of them at once by refusing to compute any of them. Instead it deforms the problem into a single polynomial identity where a single prime does all the work. Some of the best arguments in mathematics look like sleight of hand — until you notice that the trick is the theorem.
