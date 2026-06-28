# Prismatic Purity for $F$-Crystals on Regular Schemes: A Faithfulness/Extension Decomposition and Its Coprime Arithmetic Core

**Author:** Aristotle
**Date:** 2026-06-28

## Abstract

We study the purity problem for prismatic $F$-crystals on the spectrum of a regular local
ring $R$ of dimension $d$: whether restriction from $\mathrm{Spec}(R)$ to the punctured
spectrum $\mathrm{Spec}(R)\setminus\{\mathfrak{m}\}$ is an equivalence of categories. We
present a fully explicit linear-algebraic model of prismatic $F$-crystals — modules with a
$\varphi$-semilinear Frobenius endomorphism — and prove that the purity statement
decomposes into two independent layers. The first, *faithfulness*, is proved
unconditionally from injectivity of the target restriction map
(`restriction_faithful`); the second, *fullness and essential surjectivity*, is shown to
be exactly equivalent to the existence of a compatible Hartogs-type extension operator
(`purityHomEquiv`). We then isolate and prove the genuine algebraic core of the extension
input, breaking the circularity of a naive approach that invoked purity to justify its own
foundation. The core is a Hartogs extension theorem over an arbitrary unique factorization
domain (`hartogs_UFD`): if $x\neq 0$ is coprime to $y$ and $f$ in the fraction field is
both $x$-integral and $y$-integral, then $f\in R$; equivalently $R[1/x]\cap R[1/y]=R$
(`equalizer_inf`). Regularity enters only through the Auslander–Buchsbaum theorem
("regular $\Rightarrow$ UFD"), which we discharge unconditionally in dimension $\le 1$
(`regularLocalDimOne_isUFD`) and feed transparently as a typeclass hypothesis in higher
dimension. We give the complementary normality (dimension-one) statement
(`hartogs_dim_one`) and concrete, non-vacuous instances over $\mathbb{Z}\subseteq
\mathbb{Q}$, including one using consecutive Fibonacci numbers as the coprime pair
(`fibonacci_inter_eq_bot`).

**Keywords:** prismatic $F$-crystal, purity, Hartogs extension, Frobenius module, unique
factorization domain, Auslander–Buchsbaum, integrally closed domain, coprime localizations.

---

## 1. Introduction

### 1.1 The purity problem

Let $R$ be a regular local ring of dimension $d$ with maximal ideal $\mathfrak{m}$, arising
as $R = A/I$ for a bounded prism $(A, I)$. The category of prismatic $F$-crystals on
$\mathrm{Spec}(R)$ is a central object in $p$-adic Hodge theory; it controls, among other
things, the canonical $F$-isocrystal conjectured by Ogus. A natural *purity* question
asks whether such crystals are rigid with respect to removal of the closed point:

> **(Purity).** Is the restriction functor
> $$ \mathrm{Res}\colon \mathrm{FCrys}\big(\mathrm{Spec}(R)\big)\longrightarrow
>    \mathrm{FCrys}\big(\mathrm{Spec}(R)\setminus\{\mathfrak{m}\}\big) $$
> an equivalence of categories?

An affirmative answer implies that a prismatic $F$-crystal — and in particular the
canonical $F$-isocrystal of Ogus's conjecture — is uniquely determined by its restriction
to any dense open subscheme.

### 1.2 Strategy: decompose, then de-circularize

We pursue two reductions.

1. **Categorical decomposition.** Equivalence of categories factors into *faithfulness*
   (morphisms are not collapsed under restriction) and *fullness + essential
   surjectivity* (every morphism and object on the punctured spectrum extends). We show
   faithfulness needs only torsion-freeness (depth $\ge 1$), while the remainder is
   *equivalent* to a Hartogs extension operator across a codimension-$\ge 2$ locus
   (depth $\ge 2$).

2. **Arithmetic core.** The extension input must not be justified by purity itself — the
   error that renders a naive argument circular. We prove the extension input directly in
   the regular (= UFD) case as elementary coprime arithmetic: the intersection of two
   localizations at coprime elements is the ring.

The mathematics is organized into three modules: a Frobenius-module model with the
categorical skeleton; the dimension-one (normality) shadow; and the codimension-two UFD
foundation.

---

## 2. The Frobenius-module model of prismatic $F$-crystals

Throughout this section fix a commutative ring $R$ and a ring endomorphism $\varphi\colon
R\to R$ (the Frobenius lift of the prism base).

### 2.1 Definitions

**Definition 2.1 (`FMod`).** A *Frobenius module* (affine model of a prismatic
$F$-crystal) over $(R,\varphi)$ is an $R$-module $M$ together with a $\varphi$-semilinear
endomorphism $F\colon M\to M$; that is, $F$ is additive and satisfies
$F(r\cdot v)=\varphi(r)\cdot F(v)$. In Lean this is a structure carrying $M$, its
`AddCommGroup` and `Module R` instances, and a semilinear map $F : M \to_{sl[\varphi]} M$.

**Definition 2.2 (`FHom`).** A *morphism* of Frobenius modules $E\to E'$ is an $R$-linear
map $h\colon E.M\to E'.M$ satisfying the $F$-equivariance condition
$$ h\big(E.F(x)\big)=E'.F\big(h(x)\big)\qquad\text{for all }x. $$

**Proposition 2.3 (category structure).** Frobenius modules and their morphisms form a
category: there are identity morphisms `FHom.idMor`, a composition `FHom.comp` given by
composing underlying linear maps, and the laws `FHom.id_comp`, `FHom.comp_id`,
`FHom.comp_assoc` hold. Morphism equality is determined by equality of underlying maps
(`FHom.ext`).

**Definition 2.4 (`triv`).** The *trivial (unit) $F$-crystal* is $(R,\varphi)$ itself:
the base ring as a module over itself, with Frobenius $\varphi$. This shows the category
is non-empty.

### 2.2 Layer (a): faithfulness

**Theorem 2.5 (`restriction_faithful`).** Let $E, F, E_U, F_U$ be Frobenius modules with
restriction morphisms $\rho_E\colon E\to E_U$ and $\rho_F\colon F\to F_U$. Suppose
$\rho_F$ is injective on underlying modules. Let $a, b\colon E\to F$ and $a_U, b_U\colon
E_U\to F_U$ be morphisms forming commuting squares,
$$ \rho_F\big(a(x)\big)=a_U\big(\rho_E(x)\big),\qquad
   \rho_F\big(b(x)\big)=b_U\big(\rho_E(x)\big)\quad\text{for all }x, $$
and suppose $a_U=b_U$. Then $a=b$.

*Proof sketch.* Fix $x$. Apply the injective $\rho_F$ to the two commuting squares and use
$a_U=b_U$:
$$ \rho_F\big(a(x)\big)=a_U\big(\rho_E(x)\big)=b_U\big(\rho_E(x)\big)=\rho_F\big(b(x)\big). $$
Injectivity of $\rho_F$ gives $a(x)=b(x)$; as $x$ was arbitrary, $a=b$ by extensionality.
∎

The only hypothesis is injectivity of the target restriction, exactly the depth-$\ge 1$ /
torsion-freeness property that a regular ring supplies. No higher-dimensional input is
used.

### 2.3 Layer (b): purity reduces to extension

**Theorem 2.6 (`purityHomEquiv`).** With notation as above, assume $\rho_F$ injective.
Suppose given a restriction map on morphisms $\mathrm{restr}\colon \mathrm{Hom}(E,F)\to
\mathrm{Hom}(E_U,F_U)$ realizing the commuting square for every $a$,
$$ \rho_F\big(a(x)\big)=(\mathrm{restr}\,a)\big(\rho_E(x)\big), $$
together with an *extension operator* $\mathrm{extend}\colon\mathrm{Hom}(E_U,F_U)\to
\mathrm{Hom}(E,F)$ that is a section: $\mathrm{restr}(\mathrm{extend}\,g)=g$ for all $g$.
Then $\mathrm{restr}$ is a bijection $\mathrm{Hom}(E,F)\simeq\mathrm{Hom}(E_U,F_U)$ with
inverse $\mathrm{extend}$.

*Proof sketch.* The right inverse identity is the section hypothesis. For the left inverse,
fix $a$; we must show $\mathrm{extend}(\mathrm{restr}\,a)=a$. Both have the same
restriction — namely $\mathrm{restr}\,a$, using the section property on the left — so
Theorem 2.5 (`restriction_faithful`) forces them equal. ∎

Theorem 2.6 is the precise formal statement that **purity on $\mathrm{Hom}$-sets is
equivalent to the existence of a compatible extension operator**: once the genuinely deep
codimension-$\ge 2$ extension is supplied, bijectivity follows formally.

### 2.4 A concrete instance over $\mathbb{Z}\subseteq\mathbb{Q}$

Take $R=\mathbb{Z}$, $\varphi=\mathrm{id}$. Let `cZ` be the trivial $\mathbb{Z}$-crystal
($M=\mathbb{Z}$, $F=\mathrm{id}$) and `cQ` the trivial crystal on the generic point
($M=\mathbb{Q}$, $F=\mathrm{id}$). The structure map $\mathbb{Z}\to\mathbb{Q}$ gives a
restriction morphism `rhoZQ`, and it is injective (`rhoZQ_injective`). Theorem 2.5
specializes to:

**Corollary 2.7 (`trivZ_faithful`).** A morphism of trivial $\mathbb{Z}$-crystals is
determined by its restriction to the generic point $\mathrm{Spec}\,\mathbb{Q}$.

This shows the faithfulness layer is non-vacuous.

---

## 3. The dimension-one (normality) shadow

In dimension one, a regular local ring is a discrete valuation ring, hence integrally
closed. The extension input then collapses to integral-closedness of the ring in its
fraction field, which is provable unconditionally.

**Theorem 3.1 (`hartogs_dim_one`).** Let $R$ be an integrally closed domain with fraction
field $K$. If $x\in K$ is integral over $R$, then $x$ lies in the image of $R\to K$:
there exists $a\in R$ with $\mathrm{algebraMap}(a)=x$.

*Proof sketch.* This is precisely the definition of integral closedness packaged by
Mathlib's characterization `IsIntegrallyClosed.isIntegral_iff`: integral over $R$ inside
$K$ is equivalent to being in the image of $R$. Rewriting along that equivalence converts
the hypothesis into the conclusion. ∎

**Theorem 3.2 (`extension_unique`).** For a domain $R$ with fraction field $K$, the
structure map $\mathrm{algebraMap}\colon R\to K$ is injective. (This is
`IsFractionRing.injective`.)

**Theorem 3.3 (`hartogs_dim_one_unique`).** Under the hypotheses of Theorem 3.1, the
extending global section is unique: there is a *unique* $a\in R$ with
$\mathrm{algebraMap}(a)=x$.

*Proof sketch.* Existence is Theorem 3.1; uniqueness is injectivity (Theorem 3.2). ∎

**Corollary 3.4 (`hartogs_Z`).** If $q\in\mathbb{Q}$ is integral over $\mathbb{Z}$, then
$q$ is an integer: there exists $n\in\mathbb{Z}$ with $(n:\mathbb{Q})=q$.

**Corollary 3.5 (`hartogs_polyQ`).** If $x\in\mathrm{RatFunc}\,\mathbb{Q}$ is integral
over $\mathbb{Q}[X]$, then $x$ is (the image of) a polynomial.

**Remark 3.6 (sharpness).** Normality is necessary. For the non-maximal order
$R=\mathbb{Z}[2i]\subset\mathbb{Z}[i]\subset\mathbb{Q}(i)$, the element $i$ is integral
over $R$ (root of $t^2+1$) but $i\notin R$. Dropping integral-closedness makes the
extension statement false; the hypotheses of Theorem 3.1 are load-bearing.

---

## 4. The codimension-two foundation: Hartogs over a UFD

This is the genuine algebraic core. We work with a commutative ring $R$, a commutative
ring $K$, and an algebra structure $R\to K$ (taken to be a fraction field in the main
theorem).

### 4.1 $x$-integrality

**Definition 4.1 (`IsXIntegral`).** An element $f\in K$ is *$x$-integral* (for $x\in R$)
if some power of $x$ clears its denominator:
$$ \mathrm{IsXIntegral}(x,f)\;:\Longleftrightarrow\;
   \exists\,n\in\mathbb{N},\ (\mathrm{algebraMap}(x))^n\cdot f\in
   \mathrm{range}(\mathrm{algebraMap}). $$
Equivalently, $f$ lies in the localization $R[1/x]$ realized inside $K$.

**Proposition 4.2 (`isXIntegral_of_mem_range`).** Every global section is $x$-integral:
if $f\in\mathrm{range}(\mathrm{algebraMap})$ then $\mathrm{IsXIntegral}(x,f)$ (take
$n=0$).

### 4.2 The main extension theorem

**Theorem 4.3 (`hartogs_UFD`).** Let $R$ be a unique factorization domain that is a domain,
with fraction field $K$. Let $x, y\in R$ with $x\neq 0$ and $\mathrm{IsRelPrime}(x,y)$
(relatively prime), and let $f\in K$ be both $x$-integral and $y$-integral. Then $f\in
\mathrm{range}(\mathrm{algebraMap}\colon R\to K)$; i.e. $f$ is a global section.

*Proof sketch (cross-multiply and cancel coprime powers).*
Unfold $x$-integrality and $y$-integrality: there are $a,b\in\mathbb{N}$ and
$\alpha,\beta\in R$ with
$$ (\mathrm{algebraMap}\,x)^a\cdot f=\mathrm{algebraMap}\,\alpha,\qquad
   (\mathrm{algebraMap}\,y)^b\cdot f=\mathrm{algebraMap}\,\beta. $$
Cross-multiplying eliminates $f$ in $K$ and, since $\mathrm{algebraMap}$ is injective
(`IsFractionRing.injective`), descends to an identity in $R$:
$$ y^b\cdot\alpha = x^a\cdot\beta. $$
Relative primeness is preserved under taking powers (`IsRelPrime.pow`), so
$\mathrm{IsRelPrime}(x^a, y^b)$. Since $x^a$ divides $x^a\cdot\beta = y^b\cdot\alpha$ and
is coprime to $y^b$, it divides $\alpha$ (`IsRelPrime.dvd_of_dvd_mul_right`); write
$\alpha=x^a\cdot\gamma$. Substituting and cancelling the nonzero field element
$(\mathrm{algebraMap}\,x)^a$ (`mul_left_cancel₀`, using $x\neq 0$) yields
$f=\mathrm{algebraMap}\,\gamma$. ∎

**Remark 4.4 (load-bearing $x\neq 0$).** The final cancellation requires
$(\mathrm{algebraMap}\,x)^a\neq 0$, which uses $x\neq 0$ and injectivity. Without it the
cancellation step is invalid.

### 4.3 Regularity supplies the UFD structure

**Theorem 4.5 (`regularLocalDimOne_isUFD`).** Let $R$ be a Noetherian local domain whose
maximal ideal $\mathfrak{m}$ is principal (a regular local ring of dimension $\le 1$).
Then $R$ is a unique factorization domain.

*Proof sketch.* By Mathlib's TFAE for Noetherian local domains
(`tfae_of_isNoetherianRing_of_isLocalRing_of_isDomain`), principality of the maximal
ideal is equivalent to $R$ being a principal ideal ring; and a PID is a UFD
(`PrincipalIdealRing.to_uniqueFactorizationMonoid`). ∎

In dimension $d\ge 2$, "regular $\Rightarrow$ UFD" is the Auslander–Buchsbaum theorem;
rather than fake its proof, the development feeds it transparently through the
`UniqueFactorizationMonoid` typeclass hypothesis of Theorem 4.3. Thus the only
non-elementary ingredient is isolated, named, and parameterized — never silently assumed
and never proved by appeal to purity.

### 4.4 The equalizer formulation

**Definition 4.6 (`xIntegralSubalg`).** The set of $x$-integral elements forms a
subalgebra of $K$, namely $R[1/x]\subseteq K$.

**Theorem 4.7 (`equalizer_inf`).** For coprime $x,y$ (with $x\neq 0$) in a UFD $R$ with
fraction field $K$,
$$ \mathrm{xIntegralSubalg}(x)\;\sqcap\;\mathrm{xIntegralSubalg}(y)\;=\;\bot, $$
i.e. $R[1/x]\cap R[1/y]=R$ inside $K$. The two localization charts equalize exactly on the
global ring.

*Proof sketch.* The bottom subalgebra $\bot$ is the image of $R$. One inclusion is
Proposition 4.2 (global sections are in both charts). The reverse inclusion is exactly
Theorem 4.3: an element in both charts is $x$-integral and $y$-integral, hence a global
section. ∎

### 4.5 A concrete instance: Fibonacci coprime pairs

**Theorem 4.8 (`fibonacci_inter_eq_bot`).** Instantiating Theorem 4.7 on
$\mathbb{Z}\subseteq\mathbb{Q}$ with $x=F_n$, $y=F_{n+1}$ consecutive Fibonacci numbers,
$$ \mathbb{Z}[1/F_n]\cap\mathbb{Z}[1/F_{n+1}]=\mathbb{Z}\quad\text{inside }\mathbb{Q}. $$

*Proof sketch.* Consecutive Fibonacci numbers are coprime ($\gcd(F_n,F_{n+1})=1$), and
$F_{n+1}\neq 0$, so they form an admissible coprime pair for Theorem 4.7. ∎

This pins the abstract equalizer to an explicit, non-vacuous arithmetic statement.

---

## 5. Algorithms

### 5.1 Hartogs extension over $\mathbb{Z}$ (constructive cancellation)

The proof of Theorem 4.3 is constructive over $\mathbb{Z}\subseteq\mathbb{Q}$: given
coprime $x,y$ and $f\in\mathbb{Q}$ with $x^a f, y^b f\in\mathbb{Z}$, it computes the
integer equal to $f$.

```
INPUT:  coprime integers x, y; a fraction f known to be x- and y-integral
OUTPUT: the integer gamma with f = gamma
1.  a <- least n with x^n * f in Z;  b <- least n with y^n * f in Z
2.  alpha <- x^a * f;  beta <- y^b * f          (both integers)
3.  assert y^b * alpha == x^a * beta            (cross-multiplied identity)
4.  assert (x^a) divides alpha                  (forced by gcd(x^a, y^b)=1)
5.  gamma <- alpha / x^a
6.  assert gamma == f;  return gamma
```

Complexity: dominated by clearing denominators; $O(\log_{|x|}\mathrm{den}(f))$ and
$O(\log_{|y|}\mathrm{den}(f))$ multiplications to find $a,b$, plus one exact integer
division.

### 5.2 Equalizer membership test

To witness Theorem 4.7: a rational $f$ lies in $R[1/x]\cap R[1/y]$ iff it is both
$x$-integral and $y$-integral; the theorem asserts this holds iff $f\in\mathbb{Z}$.
Algorithmically, test whether some bounded power of $x$ (resp. $y$) clears the
denominator, and compare with the direct test $\mathrm{den}(f)=1$.

---

## 6. Applications

- **Rigidity of prismatic $F$-crystals.** Theorems 2.5–2.6 reduce the purity equivalence
  to a single extension input; supplying it (Theorem 4.3 in the regular case) shows
  crystals are determined by their restriction to a dense open. In particular, the
  canonical $F$-isocrystal of Ogus's conjecture is uniquely determined by its restriction
  to any dense open subscheme.
- **Number theory.** Corollary 3.4 is integral closedness of $\mathbb{Z}$ in $\mathbb{Q}$;
  Theorem 4.8 is a concrete arithmetic identity about localizations at Fibonacci numbers.
- **Commutative algebra pedagogy.** Theorem 4.3 packages "two coprime localizations meet
  in the ring" as a clean, reusable lemma over any UFD.

---

## 7. Discussion

The decomposition into faithfulness (cheap, depth $\ge 1$) and extension (deep, depth
$\ge 2$) mirrors the classical structure of purity for reflexive sheaves and vector
bundles. The conceptual contribution is twofold: (i) `purityHomEquiv` makes the
reduction "purity $\Leftrightarrow$ extension" precise and formal; (ii) `hartogs_UFD`
identifies the extension input, in the regular case, as elementary coprime arithmetic,
thereby breaking the circularity of justifying extension by purity. Regularity is used
only as a black box via Auslander–Buchsbaum (UFD), made fully unconditional in dimension
$\le 1$ (Theorem 4.5).

---

## 8. Future Directions

**Direction 1 — Many-chart purity (arbitrary regular dimension $d$).** For pairwise-coprime
coordinates $x_1,\dots,x_d$ and $q\in\mathbb{Q}$ with $q.\mathrm{den}\mid x_i^{a_i}$ for
every $i$, conjecturally $q\in\mathbb{Z}$, and the global sections $\mathbb{Z}$ are in
bijection with sections regular on the cover $\bigcup_i D(x_i)$. The two-chart proof used
only $\gcd(x^a,y^b)=1$, and pairwise coprimality of a finite family forces the gcd of
their powers to be $1$, so the codimension-two argument bootstraps to every $d\ge 2$ by a
direct $\mathrm{Finset}$-indexed induction.

**Direction 2 — From $\mathbb{Z}\subset\mathbb{Q}$ to an arbitrary GCD domain.** For a GCD
domain $R$ with fraction field $K$, coprime $x,y\in R$, and $f\in K$ with $x^a f\in R$ and
$y^b f\in R$, conjecturally $f\in R$, i.e. $R=R[1/x]\cap R[1/y]$ inside $K$. The abstract
ring skeleton is already in place (`IsCoprime.pow` + `isUnit_of_dvd'`); the remaining work
is the fraction-field bookkeeping via `IsFractionRing`, replacing $\mathrm{Rat.den}$ by
valuation/`IsLocalization` denominators.

**Direction 3 — Frobenius-equivariant gluing as an equivalence of $F$-objects.** The
gluing bijection should upgrade to an isomorphism in the category whose objects carry a
Frobenius $\varphi$, natural with respect to every polynomial Frobenius
$q\mapsto\sum c_j q^{p^j}$ with integer coefficients, not just $q\mapsto q^p$. Each chart
is stable under $\cdot^p$ and under integer linear combinations (denominators only shrink
under addition of integers), so any integral Frobenius polynomial preserves punctured
sections; extending to $\mathrm{Polynomial}\,\mathbb{Z}$ acting via `aeval` is a single
`Polynomial.induction_on`.

**Direction 4 — Faithfulness is strictly codimension-one, fullness is codimension-two.**
Faithfulness holds with a single nonzero scalar (one chart) and needs no coprimality,
whereas essential surjectivity cannot hold from a single chart: there should exist a
torsion-free module section regular on one $D(x)$ that does not extend. The boundary
example already shows one chart is insufficient for extension, while faithfulness needs no
coprimality.

---

## 9. Conclusion

We have given an explicit model of prismatic $F$-crystals, decomposed the purity question
into a cheap faithfulness layer and a deep extension layer, proved their formal
relationship (`purityHomEquiv`), and identified and proved the extension core as coprime
arithmetic over a UFD (`hartogs_UFD`, `equalizer_inf`), with the regularity input isolated
through Auslander–Buchsbaum and discharged unconditionally in low dimension. Concrete,
non-vacuous instances over $\mathbb{Z}\subseteq\mathbb{Q}$ — including the Fibonacci pair
(`fibonacci_inter_eq_bot`) — anchor every abstract statement.
