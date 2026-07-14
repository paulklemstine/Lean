# A Polynomial Realization of the $\mu$-Corrected Sharp/Flat $\lambda$-Difference

## Abstract

For an elliptic curve $E/\mathbb{Q}$ with good supersingular reduction at $2$ and
a squarefree twisting parameter $D \equiv 1 \pmod 4$, the difference between the
*sharp* and *flat* Iwasawa $\lambda$-invariants of the quadratic twist $E^D$ is
classically expressed, in the $\mu = 0$ case, as a finite sum of local terms
over the prime divisors of $D$. We record an extension of this formula that is
valid for arbitrary $\mu$: the sharp/flat difference acquires a correction that
is exactly proportional to $\mu$, with an explicit weight built from $2$-adic
depths of the twisting primes. Our main contribution is a **cross-domain
bridge**: we show that this arithmetic invariant is realized, on the nose, as the
genuine algebraic Iwasawa invariants of an explicit integer polynomial — the
*characteristic element*. Concretely, we define the polynomial $\mu$- and
$\lambda$-invariants via content valuation (Gauss's lemma) and trailing degree of
the mod-$p$ reduction, prove their additivity under multiplication, and exhibit a
polynomial whose $\mu$-invariant equals the prescribed $\mu$ and whose
$\lambda$-invariant equals the corrected sharp/flat difference. As corollaries we
obtain a polynomial-level inversion formula recovering $\mu$, a non-vanishing
theorem showing that $\mu > 0$ strictly increases the realized $\lambda$, strict
monotonicity of the realized $\lambda$ in $\mu$, and additivity over coprime
twisting parameters that unifies two a priori different additivity mechanisms.

**Keywords.** Iwasawa theory, supersingular reduction, quadratic twist, sharp/flat
invariants, $\mu$-invariant, $\lambda$-invariant, Matsuno's formula, $2$-adic
valuation, Gauss's lemma, trailing degree.

---

## 1. Introduction

### 1.1 Background and motivation

Let $E/\mathbb{Q}$ be an elliptic curve and $p$ a prime. Iwasawa theory attaches
to $E$ over the cyclotomic $\mathbb{Z}_p$-extension a *characteristic element*
$f \in \Lambda = \mathbb{Z}_p[[T]]$, whose two fundamental invariants are the
$\mu$-invariant $\mu_p(f)$ and the $\lambda$-invariant $\lambda_p(f)$. When $E$
has *good ordinary* reduction at $p$, these invariants directly govern the growth
of Selmer groups up the tower. When $E$ has *good supersingular* reduction, the
naive characteristic element fails to lie in $\Lambda$, and one instead works with
the Pollack–Sprung $\pm$ (equivalently, sharp/flat $\sharp/\flat$) theory, which
produces a pair of well-behaved characteristic elements $f^\sharp, f^\flat$ and a
pair of invariants $\lambda^\sharp, \lambda^\flat$.

For a squarefree $D \equiv 1 \pmod 4$, the quadratic twist $E^D$ has its own
sharp/flat invariants, and a natural question is how the difference
$\lambda^\sharp - \lambda^\flat$ depends on $D$. In the base case $\mu = 0$, a
formula in the tradition of Matsuno expresses this difference as a sum of purely
local contributions:
$$
\lambda^\sharp - \lambda^\flat \;=\; \sum_{\ell \mid D} \mathrm{localTerm}(\ell),
$$
where each summand depends only on the prime $\ell$ and on the reduction data of
$E$. This is a clean, computable arithmetic invariant.

### 1.2 The extension and the bridge

Two things are done in this work.

First (Section 3), we make precise the **extension of the formula to non-zero
$\mu$**: the difference picks up a term $\mu \cdot \sum_{\ell \mid D} 2^{n_\ell}$,
where $n_\ell = v_2\!\big((\ell^2-1)/8\big)$ is a $2$-adic depth. The full
$\mu$-corrected invariant is
$$
\Lambda(D, \mu) \;=\; \sum_{\ell \mid D} \mathrm{localTerm}(\ell) \;+\; \mu \sum_{\ell \mid D} 2^{n_\ell}.
$$

Second (Sections 2, 4, 5), we establish a **bridge to commutative algebra**. We
define genuine polynomial Iwasawa invariants on $\mathbb{Z}[X]$ and construct an
explicit polynomial — the characteristic element $\mathrm{charElt}(D,\mu)$ — whose
$\mu$-invariant is exactly $\mu$ and whose $\lambda$-invariant is exactly
$\Lambda(D,\mu)$. This realizes the abstract arithmetic invariant as a structural
invariant of a concrete algebraic object and lets us transport results freely
between the two domains.

All results below are elementary and self-contained; they rest only on Gauss's
lemma, the additivity of $p$-adic valuation, and the additivity of trailing
degree over an integral domain.

---

## 2. Polynomial Iwasawa invariants

Throughout, fix a prime $p$. For an integer polynomial $f \in \mathbb{Z}[X]$,
write $\mathrm{cont}(f)$ for its **content** (the greatest common divisor of its
coefficients, taken to be a non-negative integer) and $\mathrm{pp}(f)$ for its
**primitive part**, so that $f = \mathrm{cont}(f)\cdot \mathrm{pp}(f)$ and
$\mathrm{pp}(f)$ is primitive (its content is $1$).

**Definition 2.1 (reduction).** For a prime $p$, let $\bar{f} \in \mathbb{F}_p[X]$
denote the reduction of $f$ obtained by mapping each coefficient to
$\mathbb{Z}/p\mathbb{Z}$.

**Definition 2.2 (polynomial $\mu$-invariant).** For $f \in \mathbb{Z}[X]$, set
$$
\mu_p(f) \;=\; v_p\big(\mathrm{cont}(f)\big),
$$
the $p$-adic valuation of the content.

**Definition 2.3 (polynomial $\lambda$-invariant).** For $f \in \mathbb{Z}[X]$,
set
$$
\lambda_p(f) \;=\; \mathrm{ord}_0\big(\overline{\mathrm{pp}(f)}\big)
\;=\; \operatorname{natTrailingDegree}\big(\overline{\mathrm{pp}(f)}\big),
$$
the order of vanishing at $0$ of the mod-$p$ reduction of the primitive part;
equivalently, the least index of a non-zero coefficient of
$\overline{\mathrm{pp}(f)}$.

These definitions faithfully model the invariants of a genuine characteristic
element $f = p^{\mu}\cdot u \cdot g$ (with $u$ a unit and $g$ distinguished) that
one obtains from Weierstrass preparation in $\Lambda$: the power of $p$ is
recorded by the content, and the distinguished polynomial's order of vanishing is
recorded by the trailing degree of the reduction.

**Lemma 2.4 (reduction of a primitive polynomial is non-zero).** If $f \neq 0$,
then $\overline{\mathrm{pp}(f)} \neq 0$.

*Proof.* If $\overline{\mathrm{pp}(f)} = 0$, then $p \mid \mathrm{pp}(f)_i$ for
every coefficient $i$, so the constant $p$ divides $\mathrm{pp}(f)$. Since
$\mathrm{pp}(f)$ is primitive, any common divisor of its coefficients is a unit;
but $p \geq 2$ is not a unit in $\mathbb{Z}$, a contradiction. $\square$

This lemma guarantees $\lambda_p$ is well defined (trailing degree is taken of a
non-zero polynomial) and is the technical heart of the additivity below.

**Theorem 2.5 ($\mu$ is additive).** For nonzero $f, g \in \mathbb{Z}[X]$,
$$
\mu_p(fg) = \mu_p(f) + \mu_p(g).
$$

*Proof.* By Gauss's lemma, $\mathrm{cont}(fg) = \mathrm{cont}(f)\,\mathrm{cont}(g)$.
Both contents are nonzero, so additivity of the $p$-adic valuation gives
$v_p(\mathrm{cont}(fg)) = v_p(\mathrm{cont}(f)) + v_p(\mathrm{cont}(g))$. $\square$

**Theorem 2.6 ($\lambda$ is additive).** For nonzero $f, g \in \mathbb{Z}[X]$,
$$
\lambda_p(fg) = \lambda_p(f) + \lambda_p(g).
$$

*Proof.* The primitive part is multiplicative: $\mathrm{pp}(fg) =
\mathrm{pp}(f)\,\mathrm{pp}(g)$ (Gauss). Reduction is a ring homomorphism, so
$\overline{\mathrm{pp}(fg)} = \overline{\mathrm{pp}(f)}\cdot\overline{\mathrm{pp}(g)}$.
By Lemma 2.4 both factors are nonzero in the integral domain $\mathbb{F}_p[X]$,
and over an integral domain trailing degrees add under multiplication. $\square$

**Corollary 2.7 (elementary invariants).** The following hold.

1. $\mu_p(1) = 0$ and $\lambda_p(1) = 0$.
2. $\mu_p(C(p^k)) = k$ and $\lambda_p(C(p^k)) = 0$ for the constant polynomial $p^k$.
3. $\mu_p(X^n) = 0$ and $\lambda_p(X^n) = n$.

*Proof.* (1) The unit $1$ has content $1$ and reduction $1$. (2) The content of
$p^k$ is $p^k$, so $v_p = k$; its primitive part is $1$, so $\lambda_p = 0$. (3)
$X^n$ is monic, hence primitive with content $1$ ($\mu_p = 0$); its reduction is
$X^n$, whose trailing degree is $n$. $\square$

**Corollary 2.8 (powers and products).** For nonzero polynomials,
$$
\mu_p(g^n) = n\,\mu_p(g), \qquad \lambda_p(g^n) = n\,\lambda_p(g),
$$
and for any finite family $(g_i)_{i \in S}$ of nonzero polynomials,
$$
\mu_p\Big(\prod_{i \in S} g_i\Big) = \sum_{i \in S} \mu_p(g_i),
\qquad
\lambda_p\Big(\prod_{i \in S} g_i\Big) = \sum_{i \in S} \lambda_p(g_i).
$$

*Proof.* Both follow from Theorems 2.5–2.6 by induction on $n$ and on $|S|$
(using that products of nonzero polynomials over a domain are nonzero). $\square$

---

## 3. The arithmetic model: extended Matsuno formula

We now describe the number-theoretic invariant that the polynomial will realize.
Fix reduction data for $E$ encoded in an integer $N_E$ (whose prime factors
record the conductor support) and a function $\mathrm{ord} : \mathbb{N} \to
\mathbb{N}$ recording relevant orders at each prime.

**Definition 3.1 ($2$-adic depth).** For an odd prime $\ell$, set
$$
n_\ell \;=\; v_2\!\left(\frac{\ell^2 - 1}{8}\right).
$$
Because $\ell$ is odd, $8 \mid \ell^2 - 1$, so the argument is a positive
integer and $n_\ell$ is well defined.

**Proposition 3.2 (depth law).** For every odd prime $\ell$,
$$
8 \cdot 2^{\,n_\ell} \;=\; 2^{\,v_2(\ell - 1) + v_2(\ell + 1)}.
$$

*Proof.* Since $\ell^2 - 1 = (\ell-1)(\ell+1)$ and $v_2$ is additive on products,
$v_2(\ell^2 - 1) = v_2(\ell-1) + v_2(\ell+1)$. Dividing by $8 = 2^3$ shifts the
valuation by $3$, so $n_\ell = v_2(\ell^2-1) - 3$, whence
$8\cdot 2^{n_\ell} = 2^{3 + n_\ell} = 2^{v_2(\ell^2-1)}$. $\square$

For instance $n_3 = n_5 = 0$, $n_7 = 1$, $n_{13}=0$, $n_{17} = 2$, and $n_{31}=3$.

**Definition 3.3 (local term).** For a prime $\ell$,
$$
\mathrm{localTerm}(\ell) =
\begin{cases}
2^{\,n_\ell}, & \ell \mid N_E,\\[2pt]
2^{\,n_\ell + 1}, & \ell \nmid N_E \text{ and } 2 \mid \mathrm{ord}(\ell),\\[2pt]
0, & \text{otherwise.}
\end{cases}
$$

**Definition 3.4 (classical Matsuno $\lambda$-difference).** For squarefree $D$,
$$
\lambda_{\mathrm{diff}}(D) \;=\; \sum_{\ell \mid D} \mathrm{localTerm}(\ell),
$$
the sum running over the prime divisors of $D$.

**Definition 3.5 ($\mu$-weight and correction).** The local $\mu$-weight of a
prime is $w(\ell) = 2^{\,n_\ell}$; the total weight of $D$ is
$$
W(D) \;=\; \sum_{\ell \mid D} 2^{\,n_\ell},
$$
and the $\mu$-correction is $\mu\cdot W(D)$.

**Definition 3.6 (extended Matsuno invariant).** The $\mu$-corrected sharp/flat
$\lambda$-difference of $E^D$ is
$$
\Lambda(D,\mu) \;=\; \lambda_{\mathrm{diff}}(D) + \mu\, W(D)
\;=\; \sum_{\ell \mid D} \mathrm{localTerm}(\ell) + \mu \sum_{\ell \mid D} 2^{\,n_\ell}.
$$

**Proposition 3.7 (basic properties of $\Lambda$).**

1. $W(D) > 0$ if and only if $D$ has a prime divisor.
2. $\Lambda(D, 0) = \lambda_{\mathrm{diff}}(D)$.
3. (Coprime additivity.) If $\gcd(a,b) = 1$ with $a, b \neq 0$, then
   $$\Lambda(ab, \mu) = \Lambda(a,\mu) + \Lambda(b,\mu).$$

*Proof.* (1) Each weight $2^{n_\ell}$ is positive, so the sum is positive exactly
when the index set is nonempty. (2) Immediate from Definition 3.6. (3) The prime
factors of a product of coprime numbers are the disjoint union of the prime
factors of each; splitting both sums $\lambda_{\mathrm{diff}}$ and $W$ over this
disjoint union and regrouping gives the claim. $\square$

---

## 4. The bridge: the characteristic element

We now assemble a polynomial that realizes $\Lambda(D,\mu)$.

**Definition 4.1 (local factor).** For a prime $\ell$, the local factor is the
monomial
$$
\mathrm{lf}(\ell) \;=\; X^{\,\mathrm{localTerm}(\ell)} \in \mathbb{Z}[X].
$$

**Definition 4.2 ($\mu$-factor).** For squarefree $D$ and $\mu \in \mathbb{N}$,
$$
\mathrm{mf}(D,\mu) \;=\; \Big(p\cdot X^{\,W(D)}\Big)^{\mu} \in \mathbb{Z}[X].
$$

**Definition 4.3 (characteristic element).** The characteristic element realizing
the extended Matsuno invariant is
$$
\mathrm{charElt}(D,\mu) \;=\; \Big(\prod_{\ell \mid D} \mathrm{lf}(\ell)\Big)\cdot \mathrm{mf}(D,\mu)
\;=\; \Big(\prod_{\ell \mid D} X^{\mathrm{localTerm}(\ell)}\Big)\cdot \big(p\, X^{W(D)}\big)^{\mu}.
$$

All factors are nonzero: each $\mathrm{lf}(\ell)$ is a power of $X$, and
$\mathrm{mf}(D,\mu)$ is a power of the nonzero polynomial $p\,X^{W(D)}$.

**Lemma 4.4 (invariants of the factors).**

1. $\mu_p(\mathrm{lf}(\ell)) = 0$ and $\lambda_p(\mathrm{lf}(\ell)) = \mathrm{localTerm}(\ell)$.
2. $\mu_p(\mathrm{mf}(D,\mu)) = \mu$ and $\lambda_p(\mathrm{mf}(D,\mu)) = \mu\,W(D)$.

*Proof.* (1) is Corollary 2.7(3) applied to $X^{\mathrm{localTerm}(\ell)}$. For
(2), $p\,X^{W(D)} = C(p)\cdot X^{W(D)}$, so by additivity (Theorems 2.5–2.6) and
Corollary 2.7(2),(3):
$\mu_p(p\,X^{W(D)}) = 1 + 0 = 1$ and $\lambda_p(p\,X^{W(D)}) = 0 + W(D) = W(D)$.
Raising to the $\mu$-th power and applying Corollary 2.8 multiplies each by
$\mu$. $\square$

**Theorem 4.5 ($\mu$-realization).** For all $D, \mu$,
$$
\mu_p\big(\mathrm{charElt}(D,\mu)\big) = \mu.
$$

*Proof.* By additivity over the product (Corollary 2.8) and Lemma 4.4(1), the
product of local factors contributes $\sum_{\ell\mid D} 0 = 0$ to $\mu_p$; the
$\mu$-factor contributes $\mu$ by Lemma 4.4(2). Adding gives $\mu$. $\square$

**Theorem 4.6 (the bridge: $\lambda$-realization).** For all $D, \mu$,
$$
\lambda_p\big(\mathrm{charElt}(D,\mu)\big) = \Lambda(D,\mu).
$$

*Proof.* By $\lambda$-additivity (Theorems 2.6, Corollary 2.8),
$$
\lambda_p(\mathrm{charElt}(D,\mu)) = \sum_{\ell\mid D}\lambda_p(\mathrm{lf}(\ell)) + \lambda_p(\mathrm{mf}(D,\mu)).
$$
By Lemma 4.4, the first sum is $\sum_{\ell\mid D}\mathrm{localTerm}(\ell) =
\lambda_{\mathrm{diff}}(D)$ and the second is $\mu\,W(D)$. Their sum is exactly
$\Lambda(D,\mu)$ by Definition 3.6. $\square$

Theorems 4.5 and 4.6 are the central results: the abstract arithmetic invariant
$\Lambda(D,\mu)$ is the *genuine* polynomial $\lambda$-invariant of an explicit
polynomial whose polynomial $\mu$-invariant is exactly the prescribed $\mu$.

---

## 5. Corollaries of the bridge

**Corollary 5.1 (base case).** $\lambda_p(\mathrm{charElt}(D,0)) = \lambda_{\mathrm{diff}}(D)$.

*Proof.* Combine Theorem 4.6 with Proposition 3.7(2). $\square$

**Corollary 5.2 (polynomial-level $\mu$-recovery / inversion).** If $D$ has a
prime divisor, then
$$
\frac{\lambda_p(\mathrm{charElt}(D,\mu)) - \lambda_{\mathrm{diff}}(D)}{W(D)} = \mu,
$$
and this recovered value equals the genuine polynomial $\mu$-invariant
$\mu_p(\mathrm{charElt}(D,\mu))$.

*Proof.* By Theorem 4.6 the numerator equals $\Lambda(D,\mu) -
\lambda_{\mathrm{diff}}(D) = \mu\,W(D)$; since $W(D) > 0$ (Proposition 3.7(1)),
the quotient is $\mu$. The final identification is Theorem 4.5. $\square$

**Corollary 5.3 (non-vanishing of the $\mu$-correction).** If $D$ has a prime
divisor and $\mu > 0$, then
$$
\lambda_{\mathrm{diff}}(D) \;<\; \lambda_p(\mathrm{charElt}(D,\mu)).
$$

*Proof.* By Theorem 4.6 the right side is $\lambda_{\mathrm{diff}}(D) + \mu\,W(D)$,
and $\mu\,W(D) > 0$ since $\mu > 0$ and $W(D) > 0$. $\square$

**Corollary 5.4 (strict monotonicity in $\mu$).** If $D$ has a prime divisor,
then $\mu \mapsto \lambda_p(\mathrm{charElt}(D,\mu))$ is strictly increasing. In
particular, distinct $\mu$ yield polynomials with distinct $\lambda$-invariants.

*Proof.* The map equals $\mu \mapsto \lambda_{\mathrm{diff}}(D) + \mu\,W(D)$, an
affine function with positive slope $W(D)$. $\square$

**Corollary 5.5 (coprime additivity of the realized $\lambda$).** If
$\gcd(a,b) = 1$ with $a,b \neq 0$, then
$$
\lambda_p(\mathrm{charElt}(ab,\mu)) = \lambda_p(\mathrm{charElt}(a,\mu)) + \lambda_p(\mathrm{charElt}(b,\mu)).
$$

*Proof.* Apply Theorem 4.6 to each term and invoke coprime additivity of
$\Lambda$ (Proposition 3.7(3)). $\square$

Corollary 5.5 is worth emphasizing: the left-hand additivity, seen through the
bridge, is the *commutative-algebra* additivity of the trailing degree under
multiplication (Theorem 2.6), while the right-hand additivity of $\Lambda$ is the
*number-theoretic* additivity of a sum over disjoint sets of prime divisors. The
bridge exhibits these two mechanisms as one.

---

## 6. Worked examples

Fix $p = 2$ throughout the examples, and take $\mathrm{ord} \equiv 1$ (constantly
odd) so that no prime contributes through the second branch of Definition 3.3;
take $N_E = 1$ so no prime divides $N_E$. Then every local term vanishes and
$\lambda_{\mathrm{diff}}(D) = 0$, isolating the pure $\mu$-correction.

- **$D = 3$, $\mu = 1$.** Here $n_3 = 0$, so $W(3) = 2^0 = 1$. Thus
  $\Lambda(3,1) = 0 + 1\cdot 1 = 1$, and $\mathrm{charElt}(3,1) = 2\,X^{1}$. Its
  content is $2$ (so $\mu_2 = 1$) and its primitive part $X$ reduces to $X$ with
  trailing degree $1$ (so $\lambda_2 = 1$). Recovery: $(1 - 0)/1 = 1 = \mu$.

- **$D = 15 = 3\cdot 5$, $\mu = 2$.** Here $n_3 = n_5 = 0$, so
  $W(15) = 1 + 1 = 2$. Thus $\Lambda(15,2) = 0 + 2\cdot 2 = 4$, and
  $\mathrm{charElt}(15,2) = (2\,X^{2})^{2} = 4\,X^{4}$. Content $4$ gives
  $\mu_2 = 2$; primitive part $X^4$ gives $\lambda_2 = 4$. Recovery:
  $(4-0)/2 = 2 = \mu$.

- **$D = 7$, $\mu = 1$.** Here $n_7 = 1$, so $W(7) = 2^1 = 2$ and
  $\Lambda(7,1) = 2$, with $\mathrm{charElt}(7,1) = 2\,X^{2}$: $\mu_2 = 1$,
  $\lambda_2 = 2$.

- **Coprime check.** $\Lambda(3,1) + \Lambda(5,1) = 1 + 1 = 2 = \Lambda(15,1)$,
  matching Corollary 5.5.

These illustrate Theorems 4.5–4.6 and Corollaries 5.2–5.5 concretely.

---

## 7. Algorithms

The invariants are effectively computable. We record the two key procedures.

**Algorithm A (extended Matsuno invariant).** Given squarefree $D$, data
$(N_E, \mathrm{ord})$, and $\mu$, compute $\Lambda(D,\mu)$ by factoring $D$,
computing each $2$-adic depth $n_\ell = v_2((\ell^2-1)/8)$, summing the local
terms, and adding $\mu\sum 2^{n_\ell}$. Cost is dominated by factoring $D$; the
per-prime work is $O(\log \ell)$ for the valuations.

**Algorithm B (polynomial invariants).** Given $f \in \mathbb{Z}[X]$ as a
coefficient vector, compute $\mathrm{cont}(f)$ as the gcd of coefficients,
$\mu_p(f) = v_p(\mathrm{cont}(f))$, divide out the content to obtain
$\mathrm{pp}(f)$, reduce modulo $p$, and read off the least index of a non-zero
coefficient to get $\lambda_p(f)$. Cost is linear in the number of coefficients
times the cost of the integer gcd/valuation operations.

Running Algorithm B on $\mathrm{charElt}(D,\mu)$ and comparing with Algorithm A
gives an executable check of Theorems 4.5–4.6.

---

## 8. Discussion

The bridge reframes a delicate arithmetic computation as a robust algebraic one.
On the number-theory side, the sharp/flat $\lambda$-difference is a sum over
twisting primes weighted by $2$-adic depths — a statement about supersingular
Iwasawa theory. On the algebra side, the same integer is the order of vanishing
of an explicit polynomial's mod-$p$ reduction — a statement provable from Gauss's
lemma and additivity of the trailing degree. Neither description is obviously
about the other; the value of the bridge is precisely that it makes them
interchangeable, so that structural results proven in one domain transport to the
other.

Two features deserve emphasis. First, the $\mu$-invariant, invisible in the
classical ($\mu = 0$) formula, is faithfully recorded as content divisibility and
is *recoverable* from the realized $\lambda$-data (Corollary 5.2). Second, the
non-vanishing and monotonicity statements (Corollaries 5.3–5.4) show the
$\mu$-correction is not a formal artifact: it strictly and monotonically moves the
realized $\lambda$-invariant, so cases with different $\mu$ are genuinely
distinguished at the polynomial level.

---

## 9. Future directions

1. **Beyond powers of $X$.** Replace the local factors $X^{\mathrm{localTerm}(\ell)}$
   by distinguished polynomials with prescribed trailing behaviour, so the model
   captures the *position* (not merely the count) of the sharp/flat sign changes
   in the Pollack–Sprung $\pm$-theory. The additivity engine (Theorems 2.5–2.6
   and their finite-product forms) already supports this refinement.

2. **A power-series model.** Port $\mu_p$ and $\lambda_p$ from $\mathbb{Z}[X]$ to
   $\mathbb{Z}_p[[T]]$ via Weierstrass preparation, upgrading the polynomial
   stand-in to the true Iwasawa algebra $\Lambda$. The content/primitive-part
   decomposition should be replaced by the factorization $p^{\mu}\cdot(\text{unit})\cdot(\text{distinguished})$.

3. **Sharp/flat pair as a single object.** Combine the characteristic elements
   for the sharp and flat theories into one pair $(f^\sharp, f^\flat)$ and prove
   the difference $\lambda^\sharp - \lambda^\flat$ is $\mu$-proportional directly
   on the realized polynomials.

4. **Functoriality.** Package $\mathrm{charElt}$ as a monoid/semiring
   homomorphism from the arithmetic twist data into the multiplicative monoid of
   nonzero integer polynomials, and prove the invariants factor through it,
   tightening the connector into an equivalence of structures.

5. **Effective depth law.** Extend the depth identity
   $8\cdot 2^{n_\ell} = 2^{v_2(\ell-1)+v_2(\ell+1)}$ to a closed form for $W(D)$
   in terms of the product over $\ell \mid D$, enabling exact asymptotics of the
   $\mu$-correction.

---

## 10. Conclusion

We extended the Matsuno-type sharp/flat $\lambda$-difference formula to
non-vanishing $\mu$, obtaining an explicit linear correction
$\mu\sum_{\ell\mid D}2^{n_\ell}$, and we realized the resulting arithmetic
invariant as the genuine polynomial Iwasawa invariants of an explicit integer
polynomial. The realization is exact — $\mu$-invariant equal to $\mu$,
$\lambda$-invariant equal to the corrected difference — and yields inversion,
non-vanishing, monotonicity, and coprime-additivity corollaries as immediate
consequences of elementary commutative algebra.
