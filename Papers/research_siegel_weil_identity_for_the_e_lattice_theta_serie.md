# The Siegel–Weil Identity for the $E_8$ Theta Series: Möbius Inversion, Closed Forms, and the Eigenform Boundary

## Abstract

The Siegel–Weil identity in rank $8$ asserts that the theta series of the even unimodular lattice $E_8$ coincides with the weight-$4$ Eisenstein series $E_4$. On the level of Fourier coefficients this is the arithmetic statement
$$r(n) = 240\,\sigma_3(n), \qquad \sigma_3(n) = \sum_{d\mid n} d^3,$$
where $r(n)$ counts the vectors of $E_8$ of squared length $2n$. We take this identity as a starting point and develop the arithmetic structure of the coefficient system $240\,\sigma_3$ — and, more generally, of the divisor-power sum $\sigma_s$, the coefficient system of the weight-$(s+1)$ Eisenstein series. We establish three independent structural results: (1) a *division-free closed form* for $\sigma_s$ on prime powers, $\sigma_s(p^r)(p^s-1) = p^{s(r+1)}-1$, which is the coefficient shadow of the Euler-factor factorization of the Eisenstein $L$-function; (2) a *Möbius inversion* $n^s = \sum_{de=n}\mu(d)\sigma_s(e)$, recovering pure powers from the divisor sum via the incidence algebra of the divisor lattice, and its transport $\sum_{de=n}\mu(d)r(e)=240\,n^3$ to the $E_8$ counts; and (3) an *eigenform boundary* result, the Hecke correction $\sigma_s(p^2)+p^s=\sigma_s(p)^2$ and the resulting strict inequality $\sigma_s(p^2)<\sigma_s(p)^2$, exhibiting the precise defect that separates the Eisenstein coefficient system from a completely multiplicative character. All results are corroborated against the known low-order $E_8$ vector counts $240, 2160, 6720, 17520, 30240$.

## 1. Introduction

### 1.1 The $E_8$ lattice and its theta series

A lattice $L \subset \mathbb{R}^n$ is **even** if $\langle x, x\rangle \in 2\mathbb{Z}$ for all $x \in L$, and **unimodular** if it equals its own dual (equivalently, its Gram determinant is $1$). Even unimodular lattices exist only in dimensions divisible by $8$, and in dimension exactly $8$ there is, up to isometry, a *unique* one: the $E_8$ lattice, the densest sphere packing in eight-dimensional space and one of the most symmetric objects in mathematics.

The **theta series** of a lattice $L$ encodes its geometry as a $q$-series,
$$\theta_L(\tau) = \sum_{x \in L} q^{\langle x,x\rangle/2}, \qquad q = e^{2\pi i \tau},$$
so that the coefficient of $q^n$ is the number of lattice vectors of squared length $2n$. For an even unimodular lattice of rank $8$, $\theta_L$ is a modular form of weight $4$ for the full modular group $\mathrm{SL}_2(\mathbb{Z})$.

### 1.2 The Siegel–Weil identity in rank 8

The space of weight-$4$ modular forms for $\mathrm{SL}_2(\mathbb{Z})$ is one-dimensional, spanned by the normalized Eisenstein series
$$E_4(\tau) = 1 + 240 \sum_{n=1}^{\infty} \sigma_3(n)\, q^n.$$
Since $\theta_L$ has constant term $1$ (the zero vector) and lives in this one-dimensional space, it must equal $E_4$. Comparing coefficients gives the foundational special case of the Siegel–Weil formula:
$$r(n) = 240\,\sigma_3(n), \qquad \sigma_3(n) = \sum_{d\mid n} d^3. \tag{$\star$}$$
This identity is the ground on which the present paper builds. Rather than re-deriving $(\star)$, we investigate the *arithmetic character* of the coefficient system it produces. Our thesis is that $240\,\sigma_3$ is not merely a formula but an arithmetic object bearing three independent structural fingerprints, each of which is a coefficient-level manifestation of the fact that $\theta_{E_8} = E_4$ is a Hecke eigenform.

### 1.3 The general divisor-power sum

Throughout we work with the general divisor-power sum
$$\sigma_s(n) = \sum_{d \mid n} d^s,$$
the coefficient system of the weight-$(s+1)$ Eisenstein series. The case $s = 3$ specializes to $E_8$. Working with general $s$ makes the structural results transparent and shows they are not accidents of the specific weight.

## 2. Prime-power structure and the division-free closed form

Because $\sigma_s$ is multiplicative, its values are determined by its values on prime powers. We begin there.

**Lemma 2.1 (Geometric form on prime powers).** *For a prime $p$ and integers $s, r \ge 0$,*
$$\sigma_s(p^r) = \sum_{i=0}^{r} p^{s i} = 1 + p^s + p^{2s} + \cdots + p^{rs}.$$

*Proof sketch.* The divisors of $p^r$ are exactly $1, p, p^2, \dots, p^r$. Summing their $s$-th powers gives $\sum_{i=0}^r (p^i)^s = \sum_{i=0}^r p^{si}$. $\qquad\blacksquare$

**Corollary 2.2 (Value at a prime).** *For a prime $p$, $\sigma_s(p) = 1 + p^s$.*

*Proof sketch.* Set $r = 1$ in Lemma 2.1. $\qquad\blacksquare$

The geometric sum of Lemma 2.1 telescopes when multiplied by $p^s - 1$, yielding a closed form that involves no division.

**Theorem 2.3 (Division-free Euler-factor closed form).** *For a prime $p$ and integers $s, r \ge 0$,*
$$\sigma_s(p^r)\,\bigl(p^s - 1\bigr) = p^{s(r+1)} - 1.$$

*Proof sketch.* By Lemma 2.1, $\sigma_s(p^r) = \sum_{i=0}^r (p^s)^i$. The elementary geometric-series identity $\bigl(\sum_{i=0}^r x^i\bigr)(x - 1) = x^{r+1} - 1$ with $x = p^s$ gives $\sigma_s(p^r)(p^s-1) = (p^s)^{r+1} - 1 = p^{s(r+1)} - 1$. $\qquad\blacksquare$

**Interpretation.** Theorem 2.3 is the coefficient-level statement that the local Euler factor of the Eisenstein $L$-function at $p$ is
$$\sum_{r=0}^{\infty} \sigma_s(p^r)\, p^{-rw} = \frac{1}{(1 - p^{-w})(1 - p^{s-w})},$$
the shadow of the global factorization $\sum_{n\ge 1} \sigma_s(n)\,n^{-w} = \zeta(w)\,\zeta(w-s)$. The two zeta factors correspond to the two roots $p^0$ and $p^s$ of the quadratic $X^2 - \sigma_s(p) X + p^s$; the division-free form makes the cancellation explicit without ever inverting $p^s - 1$.

## 3. Möbius inversion: recovering pure powers

The divisor-power sum is a Dirichlet convolution of the constant function $\mathbf 1$ with the pure-power function:
$$\sigma_s = \mathbf{1} \star \mathrm{pow}_s, \qquad \mathrm{pow}_s(n) = n^s,$$
because $(\mathbf 1 \star \mathrm{pow}_s)(n) = \sum_{d\mid n} 1\cdot(n/d)^s = \sum_{e\mid n} e^s = \sigma_s(n)$. Since the constant function $\mathbf 1$ is invertible in the Dirichlet ring with inverse the Möbius function $\mu$ (that is, $\mathbf 1 \star \mu = \delta$, the multiplicative identity), we may solve for $\mathrm{pow}_s$.

**Theorem 3.1 (Möbius inversion of the divisor-power sum).** *For every integer $n \ge 1$,*
$$n^s = \sum_{d \cdot e = n} \mu(d)\,\sigma_s(e),$$
*where the sum ranges over all ordered factorizations $n = d\cdot e$ into positive integers.*

*Proof sketch.* The defining relation $\sigma_s(n) = \sum_{d\mid n} d^s$ says $\mathrm{pow}_s \star \mathbf 1 = \sigma_s$. Möbius inversion — equivalently, convolving both sides with $\mu$ and using $\mathbf 1 \star \mu = \delta$ — gives $\mathrm{pow}_s = \sigma_s \star \mu$, which is exactly the displayed identity. The single nonelementary ingredient is the incidence-algebra fact $\mathbf 1 \star \mu = \delta$ over the divisor lattice. $\qquad\blacksquare$

**Remark.** Theorem 3.1 is the coefficient-level incarnation of *dividing* the Eisenstein $L$-function by $\zeta$: from $\sum \sigma_s(n) n^{-w} = \zeta(w)\zeta(w-s)$ one recovers $\sum n^s\, n^{-w} = \zeta(w-s)$ by dividing by $\zeta(w)$, and dividing by $\zeta$ is multiplication by $\mu$ on coefficients. Unlike the results of Section 2, this identity is genuinely non-formal: it rests on the structure of the divisor lattice rather than on geometric-series algebra.

Transporting Theorem 3.1 to the $E_8$ counts via $(\star)$ gives the following.

**Corollary 3.2 (Möbius inversion of the $E_8$ counts).** *For every $n \ge 1$,*
$$\sum_{d \cdot e = n} \mu(d)\, r(e) = 240\, n^3.$$

*Proof sketch.* Substitute $r(e) = 240\,\sigma_3(e)$, factor out the constant $240$, and apply Theorem 3.1 with $s = 3$. $\qquad\blacksquare$

Thus a signed sum of the raw geometric vector counts reconstructs the pure cube $240\,n^3$ exactly — a rigidity that no completely multiplicative correction of the counts could reproduce.

## 4. The eigenform boundary

We now isolate the feature that distinguishes the Eisenstein coefficient system from a mere multiplicative character.

**Theorem 4.1 (Quadratic Hecke correction).** *For every prime $p$ and integer $s \ge 0$,*
$$\sigma_s(p^2) + p^s = \sigma_s(p)^2.$$

*Proof sketch.* By Lemma 2.1, $\sigma_s(p^2) = 1 + p^s + p^{2s}$ and $\sigma_s(p) = 1 + p^s$. Then $\sigma_s(p)^2 = 1 + 2p^s + p^{2s} = \sigma_s(p^2) + p^s$. $\qquad\blacksquare$

**Interpretation.** The correction term $p^s$ is the **eigenform defect**. For the weight-$k = s+1$ Eisenstein series, the Hecke operators satisfy $T_{p^2} = T_p^2 - p^{k-1}$; on Fourier coefficients this is precisely $\sigma_s(p^2) = \sigma_s(p)^2 - p^{s}$. The nonzero term $p^s$ certifies the coefficient system as a genuine Hecke eigenform rather than a completely multiplicative function.

**Theorem 4.2 (The eigenform is not a character).** *For every prime $p$ and integer $s \ge 0$,*
$$\sigma_s(p^2) < \sigma_s(p)^2.$$
*Equivalently, $\sigma_s$ is multiplicative but strictly fails to be completely multiplicative.*

*Proof sketch.* By Theorem 4.1, $\sigma_s(p)^2 - \sigma_s(p^2) = p^s \ge 1 > 0$. $\qquad\blacksquare$

Transported to the $E_8$ counts, Theorems 4.1 and 4.2 read as follows.

**Corollary 4.3 (Hecke correction for $E_8$).** *For every prime $p$,*
$$240\, r(p^2) + 240^2\, p^3 = r(p)^2.$$

**Corollary 4.4 (The $E_8$ counts are not completely multiplicative).** *For every prime $p$,*
$$240\, r(p^2) < r(p)^2.$$

*Proof sketches.* Substitute $r = 240\,\sigma_3$ into Theorems 4.1 and 4.2 respectively with $s = 3$, and simplify. $\qquad\blacksquare$

## 5. Low-order corroboration

The known vector counts of $E_8$ in the first five shells are
$$r(1) = 240,\ r(2) = 2160,\ r(3) = 6720,\ r(4) = 17520,\ r(5) = 30240,$$
matching $240\,\sigma_3(n)$ with $\sigma_3(1)=1$, $\sigma_3(2)=9$, $\sigma_3(3)=28$, $\sigma_3(4)=73$, $\sigma_3(5)=126$. These provide independent numerical checks of the structural theorems:

- **Closed form (Theorem 2.3):** $\sigma_3(4) = \sigma_3(2^2) = 1 + 8 + 64 = 73$, and indeed $73\cdot(2^3 - 1) = 73\cdot 7 = 511 = 2^{3\cdot 3} - 1 = 512 - 1$.
- **Hecke correction (Theorem 4.1):** $\sigma_3(2^2) + 2^3 = 73 + 8 = 81 = 9^2 = \sigma_3(2)^2$. The strict gap is $\sigma_3(2)^2 - \sigma_3(2^2) = 8 = 2^3 > 0$.
- **Möbius inversion (Theorem 3.1):** for $n = 4$, $\sum_{de=4}\mu(d)\sigma_3(e) = \mu(1)\sigma_3(4) + \mu(2)\sigma_3(2) + \mu(4)\sigma_3(1) = 73 - 9 + 0 = 64 = 4^3$.

## 6. Algorithms

The structural results translate directly into computation. We highlight three procedures.

**(A) Divisor-power sum by factorization.** Given the prime factorization $n = \prod_i p_i^{a_i}$, compute $\sigma_s(n) = \prod_i \sigma_s(p_i^{a_i})$ using the closed form of Theorem 2.3: $\sigma_s(p^a) = (p^{s(a+1)}-1)/(p^s - 1)$ when $p^s \ne 1$, and $a+1$ otherwise. This is exponentially faster than enumerating divisors.

**(B) Möbius inversion check.** For a given $n$, enumerate the ordered factorizations $n = d\cdot e$, weight $\sigma_s(e)$ by $\mu(d)$, and verify the sum equals $n^s$ (Theorem 3.1).

**(C) Eigenform-defect audit.** For each prime $p$, compute $\sigma_s(p)^2 - \sigma_s(p^2)$ and confirm it equals exactly $p^s$ (Theorem 4.1), certifying the failure of complete multiplicativity.

## 7. Applications and discussion

The identity $(\star)$ and its structural refinements sit at a crossroads of geometry, number theory, and physics.

- **Sphere packing.** $E_8$ is the densest lattice packing in dimension $8$; the vector counts $r(n)$ are the shell-by-shell census of that packing, and $(\star)$ gives them in closed arithmetic form.
- **Modular forms and $L$-functions.** The three fingerprints are coefficient-level manifestations of the Euler-product factorization, the $\zeta$-division, and the Hecke eigenvalue relation for $E_4$. They make concrete, at the level of integer sequences, the analytic statements about the associated $L$-function $\zeta(w)\zeta(w-3)$.
- **Physics.** $E_8$ appears in heterotic string theory and in the classification of exceptional Lie groups; the arithmetic of its theta series governs degeneracies that recur in these settings.

The conceptual payoff is that $240\,\sigma_3$ is *demonstrably* an arithmetic eigenform: it has the Eisenstein Euler factor as its prime-power closed form, it inverts against the divisor lattice to return pure cubes, and it carries a strictly nonzero eigenform defect at prime squares. These are three independent certificates of the identity $\theta_{E_8} = E_4$.

## 8. Future work

Several directions extend naturally from the present results.

1. **Self-convolution and weight 8.** Squaring $\theta_{E_8}$ is the theta series of $E_8 \oplus E_8$, again an Eisenstein series (of weight $8$). Matching coefficients should yield an explicit convolution law expressing $\sigma_7(n)$ via a finite convolution of $\sigma_3$ against itself.
2. **Congruence fingerprints.** Because Möbius inversion recovers $n^3$ exactly, the residues of $r(n)$ modulo classical moduli (e.g. $504$) are locked to those of $240\,n^3$, a rigidity worth developing into a full congruence characterization.
3. **Monotonicity of the eigenform defect.** The relative defect $\sigma_s(p^2)/\sigma_s(p)^2$ should be strictly increasing in $s$, quantifying how the weight-$(s+1)$ Eisenstein series becomes "less character-like" as the weight grows.
4. **Genus rigidity.** One expects that any even unimodular rank-$8$ lattice whose representation numbers satisfy the division-free closed form at every prime is forced to be $E_8$, turning the local Euler factors into a global uniqueness statement.

## 9. Conclusion

Starting from the rank-$8$ Siegel–Weil identity $r(n) = 240\,\sigma_3(n)$, we have exhibited three independent arithmetic fingerprints of the $E_8$ coefficient system: a division-free Euler-factor closed form on prime powers, a Möbius inversion recovering pure cubes from the divisor sum, and an eigenform defect $p^s$ certifying the strict failure of complete multiplicativity. Together they show that the census of the densest eight-dimensional packing is not merely computed by a divisor sum but *is*, in every measurable arithmetic respect, the Fourier coefficient system of a weight-$4$ Hecke eigenform.
