# Torsionness of Iwasawa Modules That Are Finitely Generated Over the Coefficient Ring

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Applications (Iwasawa theory / commutative algebra)

---

## Abstract

Let $R$ be an integral domain and let $R[[X]]$ denote its ring of formal power series in one variable. The ring $R[[X]]$ is the prototype of an *Iwasawa algebra*: when $R = \mathbb{Z}_p$ is the ring of $p$-adic integers, $\Lambda := \mathbb{Z}_p[[T]]$ is the completed group ring $\mathbb{Z}_p[[\mathrm{Gal}(N_\infty/k)]]$ of the Galois group of a $\mathbb{Z}_p$-extension $N_\infty/k$, and the *unramified Iwasawa module* $X_\Sigma(N_\infty)$ is a finitely generated $\Lambda$-module whose torsionness is a central conjecture generalizing Greenberg's conjecture. We isolate, prove, and formalize the algebraic engine underlying the torsionness statement in the bounded-rank regime. Concretely, we prove that **any module $M$ over $R[[X]]$ which is finitely generated as a module over the coefficient ring $R$ is $\Lambda$-torsion**: there exists a single nonzero power series $s \in R[[X]]$ annihilating every element of $M$. The proof reduces the infinite-dimensional structure of $M$ over $R[[X]]$ to a finite-dimensional linear-algebra fact about the $R$-linear endomorphism $\varphi$ "multiplication by $X$," via the Cayley–Hamilton theorem. We carefully delineate the correct hypothesis (finite generation over $R$, not over $R[[X]]$), exhibit the standard counterexample $M = R[[X]]$ for the naive formulation, and discuss how the resulting characteristic element feeds the structure theory of Iwasawa modules and the invariants $\mu$ and $\lambda$.

**Keywords:** Iwasawa algebra, power series ring, torsion module, Cayley–Hamilton, characteristic ideal, $\mathbb{Z}_p$-extension, Greenberg's conjecture, $\lambda$-invariant.

---

## 1. Introduction

### 1.1 Background and motivation

Iwasawa theory studies the arithmetic of a number field $k$ along an infinite tower

$$k = k_0 \subset k_1 \subset k_2 \subset \cdots \subset N_\infty = \bigcup_{n} k_n,$$

a **$\mathbb{Z}_p$-extension**: a Galois extension $N_\infty/k$ whose Galois group $\Gamma := \mathrm{Gal}(N_\infty/k)$ is topologically isomorphic to the additive group of $p$-adic integers $\mathbb{Z}_p$. The completed group ring

$$\Lambda := \mathbb{Z}_p[[\Gamma]] \;\cong\; \mathbb{Z}_p[[T]]$$

is the **Iwasawa algebra**; the isomorphism sends a topological generator $\gamma$ of $\Gamma$ to $1 + T$, so that the augmentation element $\gamma - 1$ corresponds to the indeterminate $T$. The ring $\mathbb{Z}_p[[T]]$ is a complete, regular, local, two-dimensional unique factorization domain, with maximal ideal $(p, T)$.

The principal objects of study are **Iwasawa modules**: finitely generated $\Lambda$-modules arising as inverse limits of arithmetic data up the tower. The most important is the *unramified Iwasawa module*

$$X_\Sigma(N_\infty) = \mathrm{Gal}\!\left(M_\Sigma(N_\infty)/N_\infty\right),$$

where $M_\Sigma(N_\infty)$ is the maximal abelian pro-$p$ extension of $N_\infty$ unramified outside a prescribed set $\Sigma$ of $p$-adic primes. A foundational conjecture — a precise, falsifiable generalization of **Greenberg's conjecture** to arbitrary $\Sigma$-ramified $\mathbb{Z}_p$-extensions — asserts:

> **Conjecture.** $X_\Sigma(N_\infty)$ is a torsion $\Lambda$-module; equivalently, $\operatorname{rank}_\Lambda X_\Sigma(N_\infty) = 0$.

Torsionness is the gateway to the entire structure theory. Only for torsion modules can one define the **characteristic ideal**, decompose the module (up to finite kernel and cokernel) into elementary pieces $\Lambda/(f_i^{e_i})$, and extract the Iwasawa invariants $\mu$ and $\lambda$ governing the growth law

$$\operatorname{ord}_p\!\big(\#\,\mathrm{Cl}(k_n)\big) = \mu\, p^n + \lambda\, n + \nu \qquad (n \gg 0).$$

### 1.2 The algebraic engine

This paper isolates and formalizes the purely algebraic core of torsionness in the regime where the module is, in addition, **finitely generated over $\mathbb{Z}_p$** — the case $\mu = 0$, $\lambda < \infty$ of "bounded rank." We work in maximal generality, replacing $\mathbb{Z}_p$ by an arbitrary integral domain $R$ and $\Lambda$ by $R[[X]]$. The result is:

> **Main Theorem (informal).** Let $M$ be a module over the power-series ring $R[[X]]$ which is finitely generated as an $R$-module. Then $M$ is $\Lambda$-torsion: there is a nonzero $s \in R[[X]]$ with $s \cdot x = 0$ for all $x \in M$.

The proof is a translation, via the Cayley–Hamilton theorem, of a finite-dimensional linear-algebra fact about the operator "multiply by $X$" into a statement about annihilators in $R[[X]]$. The argument has been fully formalized in Lean 4 on top of Mathlib; the present paper gives the mathematics and the proof sketches.

### 1.3 Organization

Section 2 fixes notation and recalls the needed background. Section 3 states the definitions and the main results. Section 4 gives the proofs. Section 5 discusses the indispensable hypothesis and the standard counterexample. Section 6 places the result in the context of Iwasawa theory. Section 7 presents algorithms and numerical illustration. Section 8 discusses applications, and Section 9 future work.

---

## 2. Preliminaries

Throughout, $R$ is a commutative ring; from Section 3.2 onward we assume $R$ is an **integral domain** (so $R$ is nonzero and has no zero divisors). We write $R[X]$ for the polynomial ring and $R[[X]]$ for the formal power-series ring. There is a canonical injective $R$-algebra homomorphism

$$\iota : R[X] \hookrightarrow R[[X]], \qquad \textstyle\sum_i a_i X^i \mapsto \sum_i a_i X^i,$$

(a polynomial is a power series with finitely many nonzero terms). Injectivity of $\iota$ is the statement `Polynomial.coe_injective` and is used decisively below.

**Modules and scalar towers.** We consider an abelian group $M$ equipped with *two* compatible module structures: a module structure over $R$ and a module structure over $R[[X]]$. Compatibility is the **scalar-tower** axiom: the $R$-action factors through the $R[[X]]$-action along the structure map $R \to R[[X]]$, i.e. for $a \in R$, $x \in M$,

$$a \cdot x = \iota_0(a) \cdot x, \qquad \iota_0 : R \to R[[X]] \text{ the constant embedding.}$$

In Lean this is `[IsScalarTower R (PowerSeries R) M]`.

**Finite generation.** $M$ is *finite over $R$* (written `Module.Finite R M`) if there is a finite subset of $M$ generating $M$ as an $R$-module. Equivalently $M$ is a quotient of $R^n$ for some $n$.

**Cayley–Hamilton over a commutative ring.** We use the following form, available in Mathlib as `LinearMap.exists_monic_and_aeval_eq_zero`:

> **Theorem (Cayley–Hamilton, monic form).** Let $R$ be a commutative ring and $M$ a finite $R$-module. For every $R$-linear endomorphism $\psi \in \operatorname{End}_R(M)$ there exists a **monic** polynomial $q \in R[X]$ with $q(\psi) = 0$ in $\operatorname{End}_R(M)$.

Here $q(\psi)$ denotes the evaluation of $q$ at $\psi$ in the (noncommutative) $R$-algebra $\operatorname{End}_R(M)$, formally the $R$-algebra map $\mathrm{aeval}_\psi : R[X] \to \operatorname{End}_R(M)$ sending $X \mapsto \psi$.

**Torsion.** For our purposes, $M$ is **$R[[X]]$-torsion** (or *$\Lambda$-torsion*) if there exists a *single* nonzero $s \in R[[X]]$ annihilating all of $M$:

$$\exists\, s \in R[[X]],\ s \neq 0 \ \wedge\ \forall x \in M,\ s \cdot x = 0.$$

When $R[[X]]$ is a domain (which holds whenever $R$ is a domain), this is equivalent to the annihilator ideal $\operatorname{Ann}_{R[[X]]}(M)$ being nonzero, hence to $M$ having $R[[X]]$-rank $0$.

---

## 3. Definitions and statement of results

### 3.1 The endomorphism "multiply by $X$"

**Definition 3.1 (`phiT`).** Let $M$ be an $R[[X]]$-module that is also an $R$-module via a scalar tower. Define the $R$-linear endomorphism

$$\varphi := \texttt{phiT} \;:=\; \operatorname{lsmul}_R(X) \in \operatorname{End}_R(M), \qquad \varphi(x) = X \cdot x,$$

i.e. $\varphi$ is multiplication by the power series $X \in R[[X]]$, regarded as an $R$-linear map by the scalar tower. (That $\varphi$ is $R$-linear is exactly the scalar-tower compatibility: $\varphi(a x) = X\cdot(a x) = a\cdot(X x) = a\,\varphi(x)$.)

This $\varphi$ is the algebraic avatar of "climb one level in the tower": under $\Lambda \cong \mathbb{Z}_p[[T]]$, multiplication by $T = \gamma - 1$ records the action of a topological generator of $\Gamma$.

### 3.2 Main results

Assume from now on that $R$ is an integral domain.

**Lemma 3.2 (`aeval_phiT_eq`).** The two $R$-algebra homomorphisms $R[X] \to \operatorname{End}_R(M)$

$$\mathrm{aeval}_\varphi \qquad\text{and}\qquad \operatorname{lsmul}_R \circ \iota$$

coincide, where $\iota : R[X] \to R[[X]]$ is the canonical inclusion and $\operatorname{lsmul}_R : R[[X]] \to \operatorname{End}_R(M)$ is the action map. Equivalently, evaluating a polynomial at $\varphi$ is the same as acting by its image power series.

**Lemma 3.3 (`aeval_phiT_apply`).** For every $q \in R[X]$ and $x \in M$,

$$q(\varphi)(x) = \iota(q) \cdot x = q(X)\cdot x,$$

where $q(X) = \iota(q) \in R[[X]]$ is the power series obtained from $q$.

**Lemma 3.4 (`exists_monic_aeval_phiT_eq_zero`).** If $M$ is finite over $R$, there exists a **monic** polynomial $q \in R[X]$ with $q(\varphi) = 0$.

**Theorem 3.5 (`exists_ne_zero_aeval_phiT_eq_zero`).** If $M$ is finite over $R$, there exists a **nonzero** polynomial $q \in R[X]$ with $q(\varphi) = 0$.

**Theorem 3.6 (Main Theorem, `isTorsion_of_finite`).** Let $R$ be an integral domain and $M$ an $R[[X]]$-module that is finite over $R$. Then $M$ is $\Lambda$-torsion: there exists a nonzero power series $s \in R[[X]]$ with $s \cdot x = 0$ for every $x \in M$. One may take $s = \iota(q) = q(X)$ for the polynomial $q$ of Theorem 3.5.

---

## 4. Proofs

### 4.1 Proof of Lemma 3.2 (`aeval_phiT_eq`)

Both sides are $R$-algebra homomorphisms out of the polynomial ring $R[X]$. By the universal property of $R[X]$ (the functor $A \mapsto \operatorname{Hom}_{R\text{-alg}}(R[X], A) \cong A$ given by evaluation at $X$), two $R$-algebra maps out of $R[X]$ are equal iff they agree on the generator $X$. Hence it suffices to check both maps send $X$ to the same endomorphism. The left map sends $X \mapsto \varphi = \operatorname{lsmul}_R(X)$ by definition of $\mathrm{aeval}$. The right map sends $X \mapsto \operatorname{lsmul}_R(\iota(X)) = \operatorname{lsmul}_R(X) = \varphi$, since $\iota(X) = X$. They agree, so the maps are equal. (In Lean: `Polynomial.algHom_ext` followed by `simp [phiT]`.) $\qquad\blacksquare$

### 4.2 Proof of Lemma 3.3 (`aeval_phiT_apply`)

Apply both sides of Lemma 3.2 to $q$, then evaluate at $x$:

$$q(\varphi)(x) = \big(\mathrm{aeval}_\varphi\, q\big)(x) = \big((\operatorname{lsmul}_R \circ \iota)(q)\big)(x) = \operatorname{lsmul}_R(\iota(q))(x) = \iota(q)\cdot x.$$

(In Lean the final identification is definitional, `rfl`, once `aeval_phiT_eq` is rewritten.) $\qquad\blacksquare$

### 4.3 Proof of Lemma 3.4 (`exists_monic_aeval_phiT_eq_zero`)

Immediate from Cayley–Hamilton (Section 2) applied to the finite $R$-module $M$ and the endomorphism $\psi = \varphi$: it yields a monic $q \in R[X]$ with $q(\varphi) = 0$. $\qquad\blacksquare$

### 4.4 Proof of Theorem 3.5 (`exists_ne_zero_aeval_phiT_eq_zero`)

Let $q$ be the monic polynomial from Lemma 3.4. A monic polynomial over a *nonzero* ring is nonzero: its leading coefficient is $1 \neq 0$, so $q \neq 0$. Since $R$ is a domain it is in particular nonzero, hence $q \neq 0$ and $q(\varphi) = 0$. $\qquad\blacksquare$

### 4.5 Proof of Theorem 3.6 (Main Theorem, `isTorsion_of_finite`)

Let $q \in R[X]$ be the nonzero polynomial from Theorem 3.5 with $q(\varphi) = 0$. Set $s := \iota(q) = q(X) \in R[[X]]$.

*$s$ is nonzero.* The inclusion $\iota : R[X] \to R[[X]]$ is injective (`Polynomial.coe_injective`). If $s = \iota(q) = 0 = \iota(0)$, then injectivity forces $q = 0$, contradicting $q \neq 0$. Hence $s \neq 0$.

*$s$ annihilates $M$.* Fix $x \in M$. By Lemma 3.3,

$$s \cdot x = \iota(q)\cdot x = q(\varphi)(x).$$

But $q(\varphi) = 0$ as an endomorphism, so $q(\varphi)(x) = 0$. Therefore $s\cdot x = 0$.

Since $x \in M$ was arbitrary, the single nonzero element $s \in R[[X]]$ annihilates all of $M$, so $M$ is $\Lambda$-torsion. $\qquad\blacksquare$

The proof is constructive: it produces the annihilator explicitly as the image in $R[[X]]$ of the Cayley–Hamilton polynomial of the operator $\varphi = $ "multiply by $X$."

---

## 5. The hypothesis is essential

A frequent informal misstatement asserts that "any finitely generated module over $R[[X]]$ is torsion." This is **false**, and the failure pinpoints exactly which finiteness matters.

**Counterexample 5.1.** Take $M = R[[X]]$ as a module over itself. It is generated by the single element $1$, hence finitely generated *over $R[[X]]$*. Yet $M$ is **not** torsion: for any nonzero $s \in R[[X]]$ we have $s \cdot 1 = s \neq 0$, so no nonzero element annihilates $M$. Indeed $\operatorname{Ann}_{R[[X]]}(R[[X]]) = (0)$, and $R[[X]]$ has $R[[X]]$-rank $1$, not $0$.

The point is that $R[[X]]$ is **not** finite over $R$: as an $R$-module it is the infinite product $\prod_{i \ge 0} R$, with the linearly independent family $1, X, X^2, \dots$. The operator $\varphi$ = "multiply by $X$" on $R[[X]]$ is the shift, which satisfies *no* nonzero polynomial (it is injective with no eigenvalues), so Cayley–Hamilton has nothing to say. The genuine, load-bearing hypothesis is

$$\boxed{\;M \text{ is finitely generated \emph{over the coefficient ring} } R.\;}$$

This matches the standard slogan of Iwasawa theory: *a finitely generated $\Lambda$-module that is in addition finitely generated over $\mathbb{Z}_p$ is automatically $\Lambda$-torsion* (the case $\mu = 0$, $\lambda < \infty$). The naive "over $\Lambda$" hypothesis is vacuous; the "over $\mathbb{Z}_p$" hypothesis is the real one.

---

## 6. Significance in Iwasawa theory

### 6.1 From torsion to characteristic ideal

Because $R[[X]]$ (with $R = \mathbb{Z}_p$, so $\Lambda = \mathbb{Z}_p[[T]]$) is a Noetherian, integrally closed, two-dimensional regular local UFD, the theory of finitely generated torsion $\Lambda$-modules is especially clean. Once $M$ is known to be torsion, its **characteristic ideal**

$$\operatorname{char}_\Lambda(M) = \prod_{\mathfrak{p}} \mathfrak{p}^{\,\ell_{\mathfrak p}(M_{\mathfrak p})}$$

(product over height-one primes $\mathfrak p$, with $\ell$ the length of the localization) is a well-defined nonzero principal ideal. The Main Theorem provides an explicit nonzero element of the annihilator, hence a concrete witness that $\operatorname{char}_\Lambda(M) \neq (0)$ and a starting point for computing a generator.

### 6.2 The invariants $\mu$ and $\lambda$

A generator $g$ of $\operatorname{char}_\Lambda(M)$ factors, by the **Weierstrass preparation theorem** in $\mathbb{Z}_p[[T]]$, as

$$g = p^{\mu}\cdot U \cdot P,$$

with $U \in \Lambda^\times$ a unit and $P(T) = T^{\lambda} + \cdots$ a **distinguished** (Weierstrass) polynomial of degree $\lambda$ — monic with non-leading coefficients in $p\mathbb{Z}_p$. The exponent $\mu = \mu(M)$ and the degree $\lambda = \deg P$ are the Iwasawa invariants. In the bounded-rank regime of this paper $\mu = 0$, and when $M$ is *free* of rank $r$ over $\mathbb{Z}_p$ the characteristic polynomial $\det(T\cdot\mathrm{Id} - \varphi)$ furnished by Cayley–Hamilton is (after unit normalization) exactly $P$, with $\lambda = r = \operatorname{rank}_{\mathbb{Z}_p} M$.

### 6.3 Growth of class numbers

For $M = X_\Sigma(N_\infty)$ torsion with $\operatorname{char}_\Lambda(M)$ coprime to $\omega_n := (1+T)^{p^n} - 1$, a control theorem identifies the $n$-th layer $M/\omega_n M$ with a finite $\mathbb{Z}_p$-module of order $p^{e_n}$, and

$$e_n = \mu\, p^n + \lambda\, n + \nu \qquad (n \gg 0).$$

Thus the algebraic torsionness theorem ultimately governs the arithmetic growth of class numbers in the tower — the phenomenon Iwasawa discovered. The conjecture that $X_\Sigma(N_\infty)$ is torsion (generalizing Greenberg) is precisely the assertion that this regular growth law holds for $\Sigma$-ramified $\mathbb{Z}_p$-extensions.

---

## 7. Algorithms and computation

While the Main Theorem concerns abstract modules, the bounded-rank case is fully computable: when $M$ is free of rank $r$ over $\mathbb{Z}_p$ (mod $p^N$, a finite ring), the operator $\varphi$ is an $r\times r$ matrix, and the entire pipeline is linear algebra.

### 7.1 Algorithm A — Characteristic annihilator via Cayley–Hamilton

**Input:** an $r\times r$ matrix $\Phi$ over a (computable) commutative ring $R$ representing $\varphi$ in a basis of the finite free module $M$.
**Output:** a nonzero polynomial $q \in R[X]$, namely $\chi_\Phi(X) = \det(X I - \Phi)$, with $q(\Phi) = 0$; the power series $q(X) = \iota(q) \in R[[X]]$ then annihilates $M$.

```
function characteristic_annihilator(Phi):
    r <- number_of_rows(Phi)
    chi <- det(X * Identity(r) - Phi)        # monic of degree r in X
    assert chi.leading_coefficient == 1       # monic, hence nonzero
    return chi                                 # q(X) annihilates M
```

Complexity: $O(r^3)$ ring operations for the determinant (Bareiss/Faddeev–LeVerrier).

### 7.2 Algorithm B — Weierstrass extraction of $(\mu, \lambda)$

**Input:** a nonzero element $g \in \mathbb{Z}_p[[T]]$ given to $p$-adic precision $p^N$ and $T$-degree $D$.
**Output:** $\mu = \min_i v_p(a_i)$ and $\lambda = \min\{ i : v_p(a_i) = \mu \}$, the Iwasawa invariants read off from the Newton data.

```
function weierstrass_invariants(coeffs a_0..a_D, prime p):
    mu     <- min over i of v_p(a_i)
    lambda <- least i with v_p(a_i) == mu
    return (mu, lambda)        # g = p^mu * unit * distinguished_poly(deg lambda)
```

### 7.3 Numerical illustration

`demo.py` accompanies this paper. It (i) builds explicit finite $\mathbb{Z}/p^N$-models of $\Lambda$-modules, (ii) computes the Cayley–Hamilton annihilator and verifies it kills the module, (iii) contrasts this with the free module $\Lambda$ itself (no nonzero annihilator), and (iv) extracts $(\mu,\lambda)$ via Weierstrass data. The demo numerically confirms the Main Theorem and the counterexample of Section 5.

---

## 8. Applications

1. **Greenberg-type conjectures.** The Main Theorem is the algebraic certificate of torsionness whenever one can show the relevant unramified module is finite over $\mathbb{Z}_p$ — a hypothesis verifiable in many CM and abelian cases, where it yields unconditional torsionness.

2. **Effective characteristic ideals.** The constructive annihilator (the image of the Cayley–Hamilton polynomial) gives an explicit nonzero element of $\operatorname{char}_\Lambda(M)$, a computational handle on $p$-adic $L$-function comparisons via the Main Conjecture.

3. **General base rings.** Because the result is stated over an arbitrary integral domain $R$, it applies verbatim to Iwasawa algebras over the ring of integers $\mathcal{O}$ of a finite extension of $\mathbb{Q}_p$, i.e. $\mathcal{O}[[T]]$, covering modules with coefficients in larger $p$-adic fields.

4. **Pedagogy and verification.** The reduction "torsion $\Leftarrow$ Cayley–Hamilton" cleanly separates the soft commutative algebra from the hard arithmetic input (finiteness over $\mathbb{Z}_p$), clarifying exactly where deep number theory is needed.

---

## 9. Discussion and future work

The result formalized here is the algebraic engine of torsionness in the bounded-rank regime ($\mu = 0$, $\lambda < \infty$): a $\Lambda$-module finite over $\mathbb{Z}_p$ is annihilated by a single nonzero element of $\Lambda$. The following are concrete, falsifiable next targets.

- **$\lambda$-invariant as a degree.** For $M$ free of finite rank over $\mathbb{Z}_p$, show $\operatorname{char}_\Lambda(M)$ is generated by the (unit-normalized distinguished) characteristic polynomial of $\varphi$, of degree exactly $\lambda = \operatorname{rank}_{\mathbb{Z}_p} M$.

- **Weierstrass form of the characteristic element.** Formalize Weierstrass preparation for $\mathbb{Z}_p[[T]]$ (or for a complete DVR base) and canonically rewrite the annihilator as $p^\mu \cdot U \cdot P$, exposing both $\mu$ and $\lambda$.

- **Control theorem / finite coinvariants.** Prove finiteness of $M/\omega_n M$ for $M$ finite over $\mathbb{Z}_p$, and the asymptotic $e_n = \lambda n + \nu$ in the $\mu = 0$ case.

- **Structure theorem.** Prove that every finitely generated torsion $\Lambda$-module is pseudo-isomorphic to $\bigoplus_i \Lambda/(f_i^{e_i})$ over the regular local UFD $\Lambda = \mathbb{Z}_p[[T]]$.

- **Sharp characterization.** Show that a finitely generated $\Lambda$-module $M$ is torsion **iff** its $\Lambda$-rank is $0$, connecting the sufficient finiteness-over-$\mathbb{Z}_p$ condition of this paper to the rank-zero criterion.

---

## Appendix A. Summary of formalized statements

| Name | Statement |
|---|---|
| `phiT` | The $R$-linear endomorphism $\varphi(x) = X\cdot x$ of $M$. |
| `aeval_phiT_eq` | $\mathrm{aeval}_\varphi = \operatorname{lsmul}_R \circ \iota$ as algebra maps $R[X]\to\operatorname{End}_R M$. |
| `aeval_phiT_apply` | $q(\varphi)(x) = \iota(q)\cdot x$ for $q\in R[X],\ x\in M$. |
| `exists_monic_aeval_phiT_eq_zero` | If $M$ finite over $R$, some monic $q$ has $q(\varphi)=0$. |
| `exists_ne_zero_aeval_phiT_eq_zero` | If $M$ finite over $R$, some nonzero $q$ has $q(\varphi)=0$. |
| `isTorsion_of_finite` | If $M$ finite over the domain $R$, some nonzero $s\in R[[X]]$ kills $M$. |

All statements are theorems over an integral domain $R$ (the lemmas not needing the domain hypothesis are stated for a general commutative ring), and the chain culminates in the Main Theorem `isTorsion_of_finite`.
