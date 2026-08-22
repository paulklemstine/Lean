# Where Can a Signal Hide?

A signal on the clock $\mathbb{Z}/n\mathbb{Z} = \{0,1,\dots,n-1\}$ is just a list of $n$ complex numbers $f(0),\dots,f(n-1)$. Its **spectrum** is the list
$$\hat f(k) \;=\; \sum_{x=0}^{n-1} e^{-2\pi i kx/n}\, f(x), \qquad k = 0,1,\dots,n-1,$$
which measures how much of the pure frequency $k$ the signal contains. No information is lost: $f$ can be reconstructed from $\hat f$.

Call $|\operatorname{supp} f|$ the number of times $f$ is nonzero, and $|\operatorname{supp}\hat f|$ the number of frequencies actually used. The whole story of this page is a single question:

> **How small can $|\operatorname{supp} f| + |\operatorname{supp}\hat f|$ be?**

Play with the sandbox below before reading any further. Switch the modulus to a prime, try to make the total small, and see how the bound $n+1$ resists every attempt. Then set the modulus to a composite number and press *subgroup indicator*.

{{interactive_demo:0}}

<details>
<summary><strong>Why does the spike have a flat spectrum?</strong> (click to expand)</summary>

If $f = \delta_c$ is $1$ at $c$ and $0$ elsewhere, then $\hat f(k) = e^{-2\pi ikc/n}$, a number of modulus $1$ — never zero. So one nonzero sample forces all $n$ frequencies: total $1 + n = n+1$.

Conversely, if $f \equiv 1$ then $\hat f(k) = \sum_x e^{-2\pi ikx/n}$, which is a geometric series equal to $n$ when $k = 0$ and $0$ otherwise. Total $n + 1$ again. These two examples show that $n+1$ is the best constant one could hope for — the surprise is that it is actually achieved as a *lower bound* when $n$ is prime.
</details>

---

## 1. Two uncertainty principles

The classical bound, valid for **every** modulus $n$ and every nonzero $f$, is multiplicative:
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \;\ge\; n .$$

For **prime** modulus $p$ something much stronger holds.

> **Additive uncertainty principle.** For $p$ prime and $f \ne 0$,
> $$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \;\ge\; p + 1 .$$

The additive bound implies the multiplicative one — if $\alpha,\beta \ge 1$ and $\alpha+\beta \ge p+1$ then $\alpha\beta \ge \alpha+\beta-1 \ge p$ — but not conversely. On $\mathbb{Z}/13\mathbb{Z}$, a signal with $4$ nonzero samples whose spectrum uses $4$ frequencies passes the product test ($16 \ge 13$) and is nevertheless **impossible**, because $4+4 = 8 < 14$.

The picture below shows the two boundaries in the plane of support pairs, and highlights the lattice points that the product bound allows and the sum bound forbids.

{{visualization:0}}

---

## 2. Why primes? Subgroups are hiding places

Suppose $n = de$ with $d, e \ge 2$, and let $f$ be the indicator of the subgroup $d\mathbb{Z}/n\mathbb{Z}$ — the multiples of $d$, of which there are $e$. A geometric-series computation (finite Poisson summation) gives
$$\hat f(k) = \begin{cases} e, & e \mid k,\\ 0, & \text{otherwise,}\end{cases}$$
so the spectrum is supported exactly on the annihilator subgroup, of size $d$. The total is $d + e \le de = n$: the additive bound fails, by exactly $(d-1)(e-1)$.

> **Primality criterion.** For $n \ge 2$, the bound $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \ge n+1$ holds for every nonzero signal on $\mathbb{Z}/n\mathbb{Z}$ **if and only if** $n$ is prime.

A prime cyclic group has no proper nontrivial subgroup, hence no place where a signal and its spectrum can be simultaneously sparse. Go back to the sandbox and try $n = 12$, $n = 15$, $n = 16$ — the counterexample is always a subgroup.

---

## 3. The engine: every minor of the prime Fourier matrix is invertible

Write $\zeta = e^{-2\pi i/n}$ and form the $n\times n$ matrix with entries $\zeta^{kx}$. Choose any $m$ rows and any $m$ columns.

> **Chebotarev's theorem (1926).** If $n = p$ is prime, then **every** square submatrix of $(\zeta^{kx})$ has nonzero determinant.

Try to break it. The explorer below lets you select any block you like and computes its determinant on the spot; for composite moduli it will hunt down a singular block for you.

{{interactive_demo:1}}

<details>
<summary><strong>From total nonsingularity to the uncertainty principle</strong> — the three-line proof</summary>

Suppose $f \ne 0$ and $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \le p$. Put $A = \operatorname{supp} f$ and let $B = \operatorname{supp}\hat f$. Then the complement of $B$ has $p - |B| \ge |A|$ elements, so we may pick a set $R$ of exactly $|A|$ frequencies where $\hat f$ vanishes. For every $k \in R$,
$$0 = \hat f(k) = \sum_{x \in A}\zeta^{kx}f(x),$$
i.e. the vector $(f(x))_{x\in A}$ is in the kernel of the square block with rows $R$ and columns $A$. Chebotarev says that block is invertible, so $f$ vanishes on $A$ — that is, $f = 0$. Contradiction. $\blacksquare$
</details>

Here is the same statement rendered as a picture: the modulus of every $2\times 2$ minor, for a prime and for a composite modulus side by side. The black cells on the right are the degeneracies; they never appear on the left.

{{visualization:1}}

---

## 4. Frenkel's proof of Chebotarev's theorem

This is the mathematical heart of the page, and it is completely elementary. Fix distinct residues $a_1,\dots,a_k$ and $b_1,\dots,b_k$ in $\{0,\dots,p-1\}$ and *promote $\zeta$ to a variable*:
$$F(X) = \det\big(X^{a_ib_j}\big) \in \mathbb{Z}[X], \qquad G(X) = F(X+1).$$

<details>
<summary><strong>Step 1 — $G$ vanishes to order at least $N = \binom k2$ at the origin</strong></summary>

By the Leibniz formula, $G(X) = \sum_\sigma \operatorname{sgn}(\sigma)(X+1)^{s_\sigma}$ with $s_\sigma = \sum_i a_{\sigma(i)}b_i$, so the coefficient of $X^d$ is a signed sum of binomial coefficients $\binom{s_\sigma}{d}$. Using the falling factorial $D_d(X) = X(X-1)\cdots(X-d+1)$ to convert binomials into powers, that coefficient is a combination of the *alternating power sums*
$$T_r = \sum_\sigma \operatorname{sgn}(\sigma)\, s_\sigma^{\,r}.$$
Expanding $T_r$ multinomially yields a sum over exponent vectors $m$ with $\sum_i m_i = r$, each term containing $\det(a_i^{m_j})$. If two entries of $m$ agree, two columns of that matrix agree and the term dies. Injective vectors of nonnegative integers have sum at least $0+1+\cdots+(k-1) = N$. Hence $T_r = 0$ for $r < N$, and $G$ has no terms below degree $N$.
</details>

<details>
<summary><strong>Step 2 — the first surviving coefficient is a product of two Vandermonde determinants</strong></summary>

At $r = N$ only permutations of $(0,1,\dots,k-1)$ survive. Each contributes $\pm$ the Vandermonde determinant $V(a) = \prod_{i<j}(a_j-a_i)$, the multinomial coefficients are all equal to $N!/\prod_{j<k}j!$, and the alternating sum over the $b$-side reassembles $V(b)$. The bookkeeping ends at
$$\Big(\prod_{j<k}j!\Big)\,G_N \;=\; V(a)\,V(b).$$
</details>

<details>
<summary><strong>Step 3 — the arithmetic contradiction</strong></summary>

Suppose the minor vanishes, i.e. $F(\zeta) = 0$. The minimal polynomial of $\zeta$ is $\Phi_p(X) = 1 + X + \cdots + X^{p-1}$, so $\Phi_p \mid F$ and therefore $\Phi_p(X+1) \mid G(X)$. The constant term of $\Phi_p(X+1)$ is $\Phi_p(1) = p$. Trailing coefficients multiply and $G$'s trailing term sits in degree exactly $N$, so $p \mid G_N$ and hence $p \mid V(a)V(b)$. But $V(a)$ is a product of differences of *distinct* residues in $\{0,\dots,p-1\}$, each nonzero and of absolute value $< p$, so $p$ divides neither factor. Contradiction. $\blacksquare$
</details>

The identity of Step 2 is a purely combinatorial statement — no roots of unity in sight — and it can be checked numerically. The demonstration below does exactly that, together with all the other results on this page.

{{demo:0}}

---

## 5. The bound is sharp — in the strongest possible sense

An inequality is *tight* if some example attains it. This one is far better than tight.

> **Exact converse.** For $p$ prime and **any** two sets $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$ with $|A| + |B| = p+1$, there is a signal $f$ with $\operatorname{supp} f = A$ and $\operatorname{supp}\hat f = B$ exactly.

Every point of the boundary line, and every placement of the two supports, is realised. The construction is explicit and is packaged in the algorithm below: take the $(|A|-1)\times|A|$ Fourier block with rows outside $B$, and read off its signed maximal minors. They form a kernel vector, and Chebotarev guarantees that not one of them is zero.

{{algorithm:1}}

{{demo:1}}

---

## 6. From a prohibition to a recovery guarantee

Uncertainty principles forbid information from hiding — which means information can be *found*.

> **Sparse recovery.** Let $p$ be prime and let $f, g$ be signals with at most $k$ nonzero entries each. If $\hat f$ and $\hat g$ agree on **any** set of $2k$ frequencies, then $f = g$.

*Proof.* The difference $h = f-g$ has at most $2k$ nonzero entries and a spectrum vanishing at $2k$ points, so $|\operatorname{supp} h| + |\operatorname{supp}\hat h| \le 2k + (p-2k) = p$, which the additive bound forbids unless $h = 0$. $\blacksquare$

The word *any* is what distinguishes this from mainstream compressed sensing: no random sampling, no incoherence condition, no failure probability. And the threshold cannot be lowered — for **every** set of $2k-1$ frequencies there are two distinct $k$-sparse signals with identical data there. (Related reading: [compressed sensing](https://en.wikipedia.org/wiki/Compressed_sensing), [Prony's method](https://en.wikipedia.org/wiki/Prony%27s_method), [uncertainty principles on finite groups](https://en.wikipedia.org/wiki/Uncertainty_principle).)

{{algorithm:2}}

<details>
<summary><strong>Why is $2k-1$ never enough?</strong></summary>

Given any set $S$ of $2k-1$ frequencies, choose a set $A$ of $2k$ positions. The $|S| \times |A|$ block has more columns than rows, so it has a nonzero kernel vector $h$; by Chebotarev *all* of $h$'s coordinates are nonzero. Split $A$ into halves $A_1, A_2$ of size $k$ and set $f = h\mathbf 1_{A_1}$ and $g = -h\mathbf 1_{A_2}$. Then $f \ne g$, both are $k$-sparse, and $\hat f - \hat g = \hat h$ vanishes on $S$.
</details>

---

## 7. Interpolation, rank, and a "fundamental theorem of algebra"

Total nonsingularity has a clean linear-algebraic face.

> **Fourier interpolation.** For $p$ prime and any $A, B$ with $|A| = |B|$, and any prescribed values on $B$, there is exactly one signal vanishing outside $A$ whose spectrum takes those values on $B$.

{{algorithm:0}}

Two consequences: **every** rectangular $A\times B$ block of the prime Fourier matrix has the maximum possible rank $\min(|A|,|B|)$; and for nonzero $f$, the spectrum $\hat f$ vanishes at strictly fewer than $|\operatorname{supp} f|$ frequencies — a $k$-sparse signal has a spectrum with at most $k-1$ zeros, exactly as a nonzero polynomial of degree $k-1$ has at most $k-1$ roots. The analogy is exact, because the spectrum of a $k$-sparse signal is a $k$-term exponential polynomial evaluated at the $p$-th roots of unity.

---

## 8. What to remember

1. **Arithmetic controls analysis.** Whether a signal can be sparse in both domains depends on whether the modulus factors; subgroups are the only hiding places, and primes have none.
2. **Rigidity is a resource.** "Every minor is invertible" is exactly why $2k$ arbitrary frequency measurements determine a $k$-sparse signal — deterministically.
3. **Sharpness at every boundary point.** Every admissible pair of support sets, in every position, actually occurs, so the additive inequality captures the phenomenon precisely.

Go back to the sandbox one more time and try to beat $n+1$ on a prime modulus. You now know why you cannot.
