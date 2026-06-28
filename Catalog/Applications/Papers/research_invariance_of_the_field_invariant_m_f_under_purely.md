# Invariance of the Separable Invariant $m_f$ under Purely Inseparable Base Change

**Author:** Aristotle (Harmonic)
**Date:** 2026-06-28
**Domain:** Applications (Field Theory / Algebra)

## Abstract

Let $K$ be a field of characteristic $p > 0$ and let $L = K(\theta)$ be a simple
algebraic extension with minimal polynomial $f = \operatorname{minpoly}_K(\theta)
\in K[X]$. Attached to $f$ is a numerical invariant $m_f$, the *separable degree*
of $f$ — equivalently the number of distinct roots of $f$ in an algebraic
closure, or $\deg g$ where $f(X) = g(X^{p^e})$ with $g$ separable. We prove that
$m_f$ is invariant under arbitrary purely inseparable base change: for any purely
inseparable extension $N/K$ realized inside a common overfield $M$ and any
$\theta \in M$ algebraic over $K$, the invariant computed over $N$ equals the one
computed over $K$, $m_{f,N} = m_f$. We deduce that the purely-inseparable/separable
*splitting type* of the simple compositum $N(\theta)/N$ depends only on $L/K$ and
not on the choice of $N$; in particular $N(\theta)/N$ is purely inseparable if and
only if $K(\theta)/K$ is. We further record that $m_f$ divides $\deg f$ (so
$\deg f / m_f$ is the inseparable degree, a power of $p$), and that when $\theta$
is separable the *full* degree is preserved, $[N(\theta):N] = [K(\theta):K]$ —
in sharp contrast to the inseparable case, where the degree can strictly collapse
(e.g. from $p$ to $1$). All results have been formally verified. We accompany the
theory with exact symbolic algorithms over $\mathbb{F}_p(t)$ that compute $m_f$
and exhibit its invariance on worked examples.

**Keywords:** separable degree, purely inseparable extension, base change,
minimal polynomial, characteristic $p$, Frobenius, function field, splitting
criterion.

---

## 1. Introduction

The arithmetic of fields of positive characteristic is split by a fault line
absent in characteristic zero: the distinction between *separable* and
*inseparable* algebraic elements. An element $\theta$ algebraic over $K$ is
separable if its minimal polynomial has no repeated roots, and inseparable
otherwise. Over a perfect field (such as a finite field or any field of
characteristic $0$) every algebraic element is separable, and the distinction is
vacuous. Over an imperfect field — the most familiar being the rational function
field $\mathbb{F}_p(t)$ — inseparability is pervasive and structurally
consequential.

The basic invariant of a simple extension $L = K(\theta)/K$ is its degree
$[L:K] = \deg f$, where $f = \operatorname{minpoly}_K(\theta)$. This degree
factors canonically as
$$[L:K] \;=\; [L:K]_s \cdot [L:K]_i,$$
the product of a *separable degree* $[L:K]_s$ and an *inseparable degree*
$[L:K]_i$, the latter always a power of $p$. The separable degree counts the
distinct roots of $f$; the inseparable degree measures how deeply those roots are
stacked as repeated factors.

This paper concerns the behaviour of these two pieces under a specific and
drastic operation: **purely inseparable base change**. Given a purely inseparable
extension $N/K$, we may form the compositum $NL = N(\theta)$ and ask how its
invariants relate to those of $L/K$. Our main theorem is that the separable part
is *rigid*:
$$[N(\theta):N]_s \;=\; [K(\theta):K]_s,$$
or in the polynomial language we will adopt, $m_{f,N} = m_f$. The inseparable
part, by contrast, is *soft*: it can be partially or wholly absorbed by $N$, so
that the total degree strictly drops. The cleanest witness is $f = X^p - t$ over
$K = \mathbb{F}_p(t)$, whose degree collapses from $p$ to $1$ upon adjoining
$t^{1/p}$, while $m_f$ remains $1$ throughout.

The motivation is structural. Criteria for a compositum to split as the product
of its maximal purely inseparable and maximal separable subextensions — written
schematically $NL = (NL)^{\mathrm{pi}}(NL)^{\mathrm{sep}}$ — are naturally phrased
in terms of $N$. The invariance of $m_f$ shows that any such criterion expressed
through $m_f$ is in fact *intrinsic* to $L/K$: the auxiliary field $N$ does not
enter the answer. This is the precise sense in which "the criterion depends only
on $L/K$."

### 1.1 Contributions

1. A definition of the base-change-invariant separable invariant
   $m_f := \operatorname{natSepDegree}(\operatorname{minpoly}_K \theta)$
   (Definition 3.1).
2. The **Main Theorem** $m_{f,N} = m_f$ for arbitrary purely inseparable base
   change (Theorem 4.1), with the equivalent separable-degree phrasing
   (Corollary 4.2).
3. The intrinsic **Criterion Invariance**: $N(\theta)/N$ is purely inseparable
   iff $K(\theta)/K$ is (Theorem 5.2), via the characterisation $m_f = 1$
   (Proposition 5.1).
4. The divisibility $m_f \mid \deg f$ exhibiting $\deg f / m_f$ as the
   inseparable degree (Proposition 5.3), and preservation of the full degree in
   the separable case (Theorem 5.4), with an explicit counterexample showing the
   separability hypothesis is load-bearing.
5. Exact symbolic algorithms over $\mathbb{F}_p(t)$ computing $m_f$ and verifying
   its invariance (Section 6).

All theorems have been formally verified in a proof assistant; the present paper
gives self-contained mathematical statements and proof sketches.

---

## 2. Background and Notation

Throughout, $K$ is a field of characteristic $p > 0$, $\overline{K}$ a fixed
algebraic closure, and all extensions are taken inside a common overfield $M$
when compositums are formed. For $\theta \in M$ algebraic over $K$ we write
$f = \operatorname{minpoly}_K(\theta) \in K[X]$ for its minimal polynomial, a
monic irreducible polynomial, and $K(\theta) = K\langle\theta\rangle$ for the
simple extension it generates.

### 2.1 The Frobenius and the freshman's dream

In characteristic $p$ the binomial coefficients $\binom{p}{k}$ for $0 < k < p$
are divisible by $p$, hence vanish, giving the identity
$$(a + b)^p = a^p + b^p \qquad \text{for all } a, b.$$
Consequently the $p$-power map $\operatorname{Frob}: a \mapsto a^p$ is a ring
homomorphism, the **Frobenius endomorphism**. A field $K$ is **perfect** if
Frobenius is surjective (equivalently bijective); otherwise it is **imperfect**.
The function field $\mathbb{F}_p(t)$ is imperfect: $t$ has no $p$-th root in it.

### 2.2 Separable and inseparable polynomials

A nonzero polynomial $h \in K[X]$ is **separable** if it has no repeated root in
$\overline{K}$, equivalently $\gcd(h, h') = 1$. For an *irreducible* $h$ this is
equivalent to $h' \neq 0$, i.e. to $h$ not being a polynomial in $X^p$.

**Structure of irreducible polynomials.** For any monic irreducible
$f \in K[X]$ in characteristic $p$ there is a unique $e \ge 0$ and a unique monic
*separable* irreducible $g \in K[X]$ with
$$f(X) = g\big(X^{p^e}\big).$$
The integer $e$ is the **inseparable exponent**; $p^e$ is the inseparable degree;
and $\deg g$ is the **separable degree**, equal to the number of distinct roots
of $f$ in $\overline{K}$. We have $\deg f = (\deg g)\, p^e$.

### 2.3 Separable and purely inseparable extensions

An algebraic extension $L/K$ is **separable** if every element of $L$ is
separable over $K$, and **purely inseparable** if every element of $L$ is purely
inseparable over $K$ — meaning each $\alpha \in L$ satisfies $\alpha^{p^n} \in K$
for some $n$, so that its minimal polynomial has the form $X^{p^n} - c$ and has a
single distinct root. The maximal separable subextension $L^{\mathrm{sep}}$ and
the role of the purely inseparable part organize the structure theory of $L/K$.

### 2.4 Separable degree of an extension

For a finite extension $L/K$ the **separable degree** $[L:K]_s$ (Mathlib:
`Field.finSepDegree`) is the number of $K$-embeddings of $L$ into $\overline{K}$.
For a simple extension it equals the separable degree of the minimal polynomial:
$$[K(\theta):K]_s \;=\; \operatorname{natSepDegree}\big(\operatorname{minpoly}_K \theta\big).$$
This identity is the bridge between the "extension" and "polynomial" formulations
of our invariant.

---

## 3. The Invariant $m_f$

> **Definition 3.1 (`InseparableBaseChange.mInvariant`).**
> For $\theta$ algebraic over $K$, define
> $$m_f \;:=\; m(K, \theta) \;:=\; \operatorname{natSepDegree}\big(\operatorname{minpoly}_K \theta\big),$$
> the separable degree of the minimal polynomial of $\theta$.

Equivalently, writing $f = g(X^{p^e})$ with $g$ separable irreducible, $m_f = \deg g$;
equivalently still, $m_f$ is the number of distinct roots of $f$ in $\overline{K}$.

**Worked computation.** Over $K = \mathbb{F}_2(t)$ take $f = X^4 + tX^2 + t$.
Here $f = g(X^2)$ with $g(Y) = Y^2 + tY + t$; since $g'(Y) = t \neq 0$, $g$ is
separable, so $e = 1$, $p^e = 2$, and $m_f = \deg g = 2$. The total degree
$\deg f = 4 = 2 \cdot 2$ factors as separable degree $2$ times inseparable degree
$2$. A purely syntactic route to the same answer: the $X$-exponents of $f$ are
$\{4, 2, 0\}$; the largest power of $2$ dividing all of them is $2^1$, so
$m_f = 4 / 2 = 2$.

---

## 4. The Main Theorem

> **Theorem 4.1 (Invariance; `InseparableBaseChange.mInvariant_base_change`).**
> Let $K$ have characteristic $p > 0$, let $N/K$ be a purely inseparable extension
> realized inside a common overfield $M$ (so $K \to N \to M$ is a tower with $N/K$
> purely inseparable), and let $\theta \in M$ be algebraic over $K$. Then
> $$m(N, \theta) \;=\; m(K, \theta), \qquad \text{i.e.} \qquad m_{f,N} = m_f.$$

**Proof sketch.** The argument runs through the separable degree of the simple
extensions and combines three facts.

1. *Polynomial vs. extension form.* For the simple extension $K(\theta)/K$ the
   separable degree of the extension equals the separable degree of the minimal
   polynomial (Section 2.4):
   $$[K(\theta):K]_s = \operatorname{natSepDegree}(\operatorname{minpoly}_K \theta) = m(K,\theta),$$
   and identically $[N(\theta):N]_s = m(N,\theta)$ (Mathlib:
   `IntermediateField.finSepDegree_adjoin_simple_eq_natSepDegree`, together with
   `Field.finSepDegree_eq` reconciling the finite and cardinal-valued separable
   degrees for algebraic extensions).

2. *Separable degree is preserved by purely inseparable base change.* The
   separable degree of an adjunction is unchanged when the base is enlarged by a
   purely inseparable extension (Mathlib:
   `IntermediateField.sepDegree_adjoin_eq_of_isAlgebraic_of_isPurelyInseparable'`).
   Concretely, the $K$-embeddings of $K(\theta)$ into $\overline K$ are in
   canonical bijection with the $N$-embeddings of $N(\theta)$ into $\overline K$:
   $$[N(\theta):N]_s = [K(\theta):K]_s.$$

3. *Conclusion.* Chaining the two identities,
   $$m(N,\theta) = [N(\theta):N]_s = [K(\theta):K]_s = m(K,\theta). \qquad \square$$

**The geometric heart.** The number $m_f$ is the count of *distinct* roots of
$f$, all of which live in the single fixed closure $\overline K = \overline N$.
Over $N$, the minimal polynomial of $\theta$ satisfies
$f = (\operatorname{minpoly}_N \theta)^{p^j}$ for some $j \ge 0$ — purely
inseparable base change can only *fuse* the equal copies of a repeated root, never
create new roots or split existing ones. Since taking a $p^j$-th power leaves the
*set* of roots unchanged, $\operatorname{minpoly}_N \theta$ and $f$ have exactly
the same distinct roots, and counting them yields the same $m$. This is why the
separable part is rigid while the inseparable part $p^e$ is malleable.

> **Corollary 4.2 (`InseparableBaseChange.finSepDegree_simple_base_change`).**
> Under the hypotheses of Theorem 4.1,
> $$[N(\theta):N]_s = [K(\theta):K]_s,$$
> i.e. `Field.finSepDegree N N⟮θ⟯ = Field.finSepDegree K K⟮θ⟯`.

This is precisely step 1↔3 of the proof read as a statement about extensions
rather than polynomials; it is the form most directly comparable to classical
separable-degree multiplicativity.

---

## 5. Consequences: the Splitting Criterion is Intrinsic

> **Proposition 5.1
> (`InseparableBaseChange.mInvariant_eq_one_iff_isPurelyInseparable`).**
> For $\theta$ algebraic over $K$,
> $$m(K,\theta) = 1 \iff K(\theta)/K \text{ is purely inseparable}.$$

**Proof sketch.** $K(\theta)/K$ is purely inseparable iff $\theta$ has a single
distinct conjugate iff $f$ has a single distinct root iff
$\operatorname{natSepDegree}(f) = 1$. (Mathlib:
`IntermediateField.isPurelyInseparable_adjoin_simple_iff_natSepDegree_eq_one`.)
$\square$

Combining Proposition 5.1 with the Main Theorem yields the headline structural
consequence: a one-line rewrite collapses the dependence on $N$.

> **Theorem 5.2 (Criterion Invariance;
> `InseparableBaseChange.isPurelyInseparable_simple_base_change_iff`).**
> Let $N/K$ be purely inseparable inside $M$ and $\theta \in M$ algebraic over
> $K$. Then
> $$N(\theta)/N \text{ is purely inseparable} \iff K(\theta)/K \text{ is purely inseparable}.$$

**Proof sketch.** Rewrite both sides via Proposition 5.1 (over $N$ and over $K$
respectively) to reduce to $m(N,\theta) = 1 \iff m(K,\theta) = 1$, then apply
Theorem 4.1, which gives $m(N,\theta) = m(K,\theta)$. $\square$

Thus the purely-inseparable/separable *splitting type* of the simple compositum
is decided by $L = K(\theta)/K$ alone; the auxiliary purely inseparable extension
$N$ never enters. This is the rigorous content of "the criterion
$NL = (NL)^{\mathrm{pi}}(NL)^{\mathrm{sep}}$ depends only on $L/K$."

> **Proposition 5.3 (`InseparableBaseChange.mInvariant_dvd_natDegree`).**
> For $\theta$ algebraic over $K$,
> $$m(K,\theta) \mid \deg\big(\operatorname{minpoly}_K \theta\big).$$
> Consequently $\deg f / m_f = p^e$ is the inseparable degree, a power of $p$.

**Proof sketch.** Apply the structure theorem $f = g(X^{p^e})$ to the irreducible
$f$: then $m_f = \deg g$ and $\deg f = (\deg g) p^e$, so $m_f$ divides $\deg f$
with quotient $p^e$. In Mathlib this is `natSepDegree_dvd_natDegree` specialised
to the irreducible minimal polynomial. $\square$

This proposition makes precise the decomposition "degree = (rigid separable part)
$\times$ (soft inseparable part)" that underlies the entire analysis.

> **Theorem 5.4 (Separable case preserves full degree;
> `InseparableBaseChange.natDegree_minpoly_base_change_of_separable`).**
> If $\theta$ is *separable* over $K$ and $N/K$ is purely inseparable inside $M$,
> then
> $$\deg\big(\operatorname{minpoly}_N \theta\big) = \deg\big(\operatorname{minpoly}_K \theta\big),
> \qquad\text{i.e.}\qquad [N(\theta):N] = [K(\theta):K].$$

**Proof sketch.** When $\theta$ is separable over $K$ and $N/K$ is purely
inseparable, the minimal polynomial simply base-changes without factoring: the
canonical comparison map sends $\operatorname{minpoly}_K \theta$ to
$\operatorname{minpoly}_N \theta$ (Mathlib:
`minpoly.map_eq_of_isSeparable_of_isPurelyInseparable`). Since the degree of a
polynomial is preserved under coefficient extension (`natDegree_map`), the degrees
agree. $\square$

**The hypothesis is load-bearing.** Separability cannot be dropped. Take
$K = \mathbb{F}_p(a)$, $\theta = a^{1/p}$, and $N = K(a^{1/p}) = K(\theta)$. Then
$f = \operatorname{minpoly}_K \theta = X^p - a$ has $[K(\theta):K] = p$, but
$\theta \in N$, so $\operatorname{minpoly}_N \theta = X - \theta$ has
$[N(\theta):N] = 1$. The degree collapses $p \to 1$. Throughout, $m_f = 1$
(Theorem 4.1 still holds), confirming that it is the *separable* part that is
invariant, never the raw degree.

### 5.5 The trichotomy

The two extreme values of $m_f$ delimit the trivial regimes:

- $m_f = 1$: $K(\theta)/K$ is purely inseparable (Proposition 5.1); the splitting
  criterion holds automatically.
- $m_f = \deg f$: $\theta$ is separable; again the criterion holds automatically
  and the full degree is base-change invariant (Theorem 5.4).
- $1 < m_f < \deg f$: the genuinely *mixed* regime, where the criterion has
  nontrivial content.

Because $m_f$ is base-change invariant (Theorem 4.1), this trichotomy is
intrinsic to $L/K$.

---

## 6. Algorithms

We give exact, finite algorithms over $\mathbb{F}_p$ that realize the invariant
and demonstrate its base-change behaviour. We model $K = \mathbb{F}_p(t)$ and a
purely inseparable extension $N = K(t^{1/p^k}) = \mathbb{F}_p(u)$ with
$u^{p^k} = t$. A polynomial $f \in K[X]$ is represented by its $X$-exponents,
each carrying a coefficient that is itself a polynomial in $t$ over $\mathbb F_p$.

### 6.1 Computing $m_f$ from $X$-exponents

For an irreducible $f$, $m_f = \deg f / p^e$ where $p^e$ is the largest power of
$p$ dividing every nonzero $X$-exponent of $f$. This is a purely syntactic read
of the exponent set, mirroring `Polynomial.natSepDegree` on irreducible inputs.

```
function NAT_SEP_DEGREE(f, p):
    E <- { x-exponent of each nonzero term of f }   # excluding 0
    g <- gcd(E)                                      # gcd of all exponents
    e <- 0
    while g > 0 and (g mod p == 0):
        g <- g / p ;  e <- e + 1
    return deg_X(f) / p^e
```

Complexity: $O(t)$ gcd operations on integers bounded by $\deg f$, where $t$ is
the number of terms; effectively $O(t \log \deg f)$.

### 6.2 Minimal polynomial over $N$ via $p$-th root extraction

Under base change $t \mapsto u^{p^k}$, the image $\tilde f$ factors as
$(\operatorname{minpoly}_N \theta)^{p^j}$. We recover $\operatorname{minpoly}_N
\theta$ by repeatedly extracting $p$-th roots. A polynomial over $\mathbb F_p(u)$
is a perfect $p$-th power iff every $X$-exponent and every $u$-exponent is
divisible by $p$ (the $p$-th root of a scalar in $\mathbb F_p$ is itself, since
$a^p = a$). Each extraction divides all exponents by $p$.

```
function MINPOLY_OVER_N(f, p, k):
    g <- substitute t := u^(p^k) in f          # multiply every u-exponent by p^k
    j <- 0
    while IS_PERFECT_PTH_POWER(g, p):
        g <- PTH_ROOT(g, p) ;  j <- j + 1       # divide all X- and u-exponents by p
    return (g, j)                               # g = minpoly_N(theta), f~ = g^(p^j)
```

The invariant $m_{f,N} = \operatorname{NAT\_SEP\_DEGREE}(g, p)$, and the Main
Theorem asserts this equals $\operatorname{NAT\_SEP\_DEGREE}(f, p)$. Complexity is
$O(j)$ passes over the polynomial, $j \le e + k$.

### 6.3 Verification harness

For each example we compute $m_f$ over $K$, the base-changed minimal polynomial
and its degree over $N$, and $m_{f,N}$, then assert $m_{f,N} = m_f$ and
$m_f \mid \deg f$. The companion `demo.py` runs five examples spanning the purely
inseparable, mixed, separable, higher-characteristic, and deep-inseparability
cases.

---

## 7. Worked Examples

All computations below are produced exactly by the algorithms of Section 6.

| Example | $p$ | $f$ over $K=\mathbb F_p(t)$ | $\deg f$ | $m_f$ | base change | $\deg$ over $N$ | $m_{f,N}$ |
|---|---|---|---|---|---|---|---|
| 1 (purely insep.) | 2 | $X^2 + t$ | 2 | 1 | $t^{1/2}$ | 1 | **1** |
| 2 (mixed) | 2 | $X^4 + tX^2 + t$ | 4 | 2 | $t^{1/2}$ | 2 | **2** |
| 3 (separable) | 2 | $X^2 + tX + t$ | 2 | 2 | $t^{1/2}$ | 2 | **2** |
| 4 (mixed) | 3 | $X^9 + tX^3 + t$ | 9 | 3 | $t^{1/3}$ | 3 | **3** |
| 5 (deep insep.) | 2 | $X^8 + t$ | 8 | 1 | $t^{1/4}$ | 2 | **1** |

In every row $m_{f,N} = m_f$ (Theorem 4.1) while the raw degree drops in the
inseparable rows (1, 2, 4, 5). Row 3 illustrates Theorem 5.4: $\theta$ separable,
full degree preserved. Row 1 is the collapsing witness of Section 5.4
($X^2+t$ becoming $(X+u)^2$ over $N$). Row 5 shows two of three inseparable
layers absorbed at once, degree $8 \to 2$, with $m_f$ fixed at $1$.

---

## 8. Applications and Discussion

**Well-posedness of splitting criteria.** The structure theory of inseparable
extensions repeatedly asks whether a compositum splits as the product of its
maximal purely inseparable and maximal separable parts. When such a criterion is
written through $m_f$, Theorem 4.1 guarantees the answer is independent of the
auxiliary purely inseparable base $N$. Theorem 5.2 is the cleanest instance:
purely inseparability of $N(\theta)/N$ is decided by $K(\theta)/K$ alone.

**Separating the rigid from the soft.** Proposition 5.3 exhibits the degree as a
product of a rigid separable factor and a soft inseparable factor. The Main
Theorem says only the rigid factor survives base change; the explicit collapse in
Section 5.4 shows the soft factor genuinely moves. This dichotomy explains *why*
the literature's criteria are stated with the separable degree rather than the raw
degree: the separable degree is the unique base-change-invariant numerical datum
of a simple extension.

**Computational tractability.** The invariant is computable by elementary
exponent arithmetic (Section 6.1), with no factorization required, making it cheap
to evaluate even in large characteristic and high degree. Base-change behaviour is
likewise computable by $p$-th root extraction (Section 6.2).

**Relation to perfect fields.** Over a perfect field all extensions are
separable, $m_f = \deg f$ always, and the theorem degenerates to the (trivial)
statement that there is nothing inseparable to absorb. The content of the result
is genuinely a phenomenon of imperfect fields such as $\mathbb F_p(t)$.

---

## 9. Future Directions

**Conjecture 1 — Invariance for arbitrary finite extensions.** For every finite
extension $L/K$ (not necessarily simple) and every purely inseparable $N/K$, the
separable degree is preserved: $[NL:N]_s = [L:K]_s$. The key insight is that the
separable closure $L_s$ of $K$ in $L$ is linearly disjoint from any purely
inseparable $N$, so $N \cdot L_s / N$ has the same degree as $L_s/K$, and the
inseparable tail contributes separable degree $1$ on both sides.

**Conjecture 2 — The inseparable exponent is invariant iff $N$ is independent of
$L$.** For $L = K(\theta)$ with $f(X) = g(X^{p^e})$, the inseparable exponent over
$N$ equals $e$ if and only if the maximal purely inseparable subextension of
$L/K$ is linearly disjoint from $N$ over $K$; otherwise it strictly drops. Purely
inseparable base change can only absorb the part of the inseparable tower of
$\theta$ that already lies in $N$.

**Conjecture 3 — $m_f \in \{1, \deg f\}$ is the exact obstruction to triviality.**
The simple compositum satisfies $NL = (NL)^{\mathrm{pi}}(NL)^{\mathrm{sep}}$
automatically whenever $m_f = 1$ (purely inseparable) or $m_f = \deg f$
(separable); the only extensions where the criterion has nontrivial content are
the genuinely mixed ones with $1 < m_f < \deg f$. Base-change invariance of $m_f$
shows this trichotomy is intrinsic to $L/K$.

**Conjecture 4 — Invariance of the whole factorization type.** Not only $m_f$ but
the entire multiset of separable degrees of the irreducible factors of
$f$ mapped into $N[X]$ is determined by $f$ and is invariant as $N$ ranges over
purely inseparable extensions.

---

## 10. Conclusion

The separable degree $m_f$ of a simple algebraic extension in characteristic $p$
is the unique base-change-invariant numerical datum: it is rigid under arbitrary
purely inseparable base change (Theorem 4.1), even as the total degree collapses.
This rigidity makes every $m_f$-based splitting criterion intrinsic to $L/K$
(Theorem 5.2), cleanly separates the degree into a rigid separable part and a
soft inseparable part (Proposition 5.3), and preserves the full degree precisely
when the extension is separable to begin with (Theorem 5.4). The phenomenon is a
genuine feature of imperfect fields and is exactly computable by elementary
exponent arithmetic.
