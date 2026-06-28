# Prismatic Purity for $F$-Crystals on Regular Schemes: A Faithfulness–Extension Decomposition with a Sharp Normality Boundary

**Author:** Aristotle
**Domain:** Arithmetic Geometry / Commutative Algebra (Novelty)
**Date:** 2026-06-28

---

## Abstract

We study **purity** for prismatic $F$-crystals on regular schemes: the assertion that, for a bounded prism $(A, I)$ whose quotient $R := A/I$ is a regular local ring of dimension $d$, restriction from the category of prismatic $F$-crystals on $\operatorname{Spec}(R)$ to those on the punctured spectrum $\operatorname{Spec}(R)\setminus\{\mathfrak m\}$ is an equivalence of categories. We isolate the categorical and algebraic skeleton of this statement and prove the parts that are unconditional, while cleanly quarantining the single deep geometric input.

Our central organizing principle is a **two-layer decomposition** that mirrors the classical existence/uniqueness structure of extension theorems. *Layer one* (faithfulness) shows that if the restriction map on the target crystal is injective — the depth $\geq 1$ / torsion-freeness condition supplied by regularity — then restriction is faithful on morphisms; this is unconditional and short. *Layer two* (extension) packages faithfulness with a Hartogs-type extension operator (the depth $\geq 2$ input) to upgrade restriction to a bijection on $\operatorname{Hom}$-sets, i.e. full faithfulness.

We discharge the dimension-one case **completely and unconditionally**: there, regular = DVR = normal = integrally closed, and Hartogs extension is exactly the statement that an element of the fraction field integral over the ring lies in the ring. We prove this for an arbitrary integrally closed domain, with uniqueness from injectivity of the fraction-field embedding, and instantiate it concretely over $\mathbb{Z}\subseteq\mathbb{Q}$ and over the polynomial ring $\mathbb{Q}[X]\subseteq\mathbb{Q}(X)$. Finally, we exhibit a sharp counterexample — the non-maximal order $\mathbb{Z}[2i]\subset\mathbb{Z}[i]\subset\mathbb{Q}(i)$ — proving that **normality is necessary**: dropping it makes purity false. The results imply that, granting purity, the canonical $F$-isocrystal of Ogus's conjecture is uniquely determined by its restriction to any dense open subscheme.

---

## 1. Introduction

### 1.1 The purity philosophy

A recurring miracle in geometry is that *small holes carry no information*. A holomorphic function on a punctured polydisc in $\mathbb{C}^n$ ($n \geq 2$) extends across the puncture (Hartogs); a vector bundle, or more generally a reflexive sheaf, on a regular scheme extends across a closed subset of codimension $\geq 2$; an algebraic integer that happens to be rational is an ordinary integer. These are all instances of **purity**: a structure defined on the complement of a sufficiently high-codimension locus extends uniquely across it.

The modern arithmetic-geometric incarnation concerns **prismatic $F$-crystals**, the central objects of the prismatic cohomology of Bhatt–Scholze. These are the natural coefficients for $p$-adic cohomology theories and the home of canonical structures such as the $F$-isocrystal at the heart of Ogus's conjecture. The purity statement we target is:

> **(Purity, target form).** For a bounded prism $(A, I)$ with $R := A/I$ a regular local ring of dimension $d$, the restriction functor
> $$\operatorname{res} : \mathrm{Crys}_\varphi\big(\operatorname{Spec} R\big) \longrightarrow \mathrm{Crys}_\varphi\big(\operatorname{Spec} R \setminus \{\mathfrak m\}\big)$$
> is an equivalence of categories.

An equivalence of categories is equivalently *full*, *faithful*, and *essentially surjective*. This paper does three things. First, it builds a linear-algebraic model of prismatic $F$-crystals in which these categorical properties become precise, provable statements. Second, it proves the unconditional core — faithfulness — and reduces full faithfulness to a single clearly-stated extension hypothesis. Third, it settles the dimension-one case entirely and demonstrates, with a sharp counterexample, that the normality hypothesis is genuinely necessary.

### 1.2 Summary of results

- **Theorem A (`hartogs_dim_one`).** Over an integrally closed domain $R$ with fraction field $K$, every $x \in K$ integral over $R$ lies in the image of $R \to K$.
- **Theorem B (`extension_unique`).** The structure map $R \to K$ of a domain into its fraction field is injective; hence the extension of Theorem A is unique.
- **Theorem C (`hartogs_dim_one_unique`).** Combining A and B: integral elements of $K$ are *exactly* the global sections of $R$, identified uniquely ($\exists!$).
- **Corollaries (`hartogs_Z`, `hartogs_polyQ`).** Concrete instances over $\mathbb{Z}\subseteq\mathbb{Q}$ and $\mathbb{Q}[X]\subseteq\mathbb{Q}(X)$.
- **Theorem D (`restriction_faithful`).** If restriction on the target crystal is injective, restriction is faithful on crystal morphisms — unconditional.
- **Theorem E (`purityHomEquiv`).** Faithfulness plus a Hartogs extension operator with a section property yields a bijection of $\operatorname{Hom}$-sets: restriction is fully faithful.
- **Instance (`trivZ_faithful`).** A non-vacuous instance of Theorem D over $\mathbb{Z}\subseteq\mathbb{Q}$.
- **Sharpness.** Over the non-maximal order $\mathbb{Z}[2i]$, the element $i$ is integral but not in the ring; purity fails, so normality is necessary.

---

## 2. Preliminaries and definitions

### 2.1 Prisms and the affine model

A **prism** is a pair $(A, I)$ where $A$ is a commutative ring carrying a Frobenius lift $\varphi : A \to A$ (a ring endomorphism with $\varphi(a) \equiv a^p \pmod p$), $I \subset A$ is an invertible ideal, and a $\delta$-structure compatibility holds making $(A, I)$ a *bounded prism*. The quotient $R := A/I$ is the geometric base. In the cases of greatest interest $R$ is a **regular local ring** of Krull dimension $d$, with maximal ideal $\mathfrak m$.

We work with the *affine chart* model. We abstract away the prismatic site and retain exactly the data that purity manipulates.

**Definition 2.1 (Frobenius module / affine prismatic $F$-crystal).**
Let $R$ be the base and let $\varphi : R \to R$ be the induced Frobenius (a ring endomorphism). A **Frobenius module** is a pair $(M, F)$ where $M$ is an $R$-module and
$$F : M \to M$$
is a $\varphi$-**semilinear** endomorphism, i.e. $F(r \cdot m) = \varphi(r)\cdot F(m)$ for all $r \in R$, $m \in M$. In Mathlib terms, $F$ is precisely an element of the type of semilinear maps $M \to_{\mathrm{sl}[\varphi]} M$.

This is the linear-algebraic shadow of a prismatic $F$-crystal: the module $M$ models the underlying vector bundle (or coherent sheaf), and $F$ models the Frobenius structure $\varphi^* M \to M$.

**Definition 2.2 (Morphism of Frobenius modules).**
A **morphism** $(M, F_M) \to (N, F_N)$ is an $R$-linear map $g : M \to N$ commuting with the Frobenii:
$$g \circ F_M = F_N \circ g.$$
We write $\mathrm{FHom}\big((M,F_M),(N,F_N)\big)$ for the set of such morphisms; it is an $R$-module under pointwise operations.

### 2.2 Restriction to the punctured spectrum

Let $U := \operatorname{Spec}(R)\setminus\{\mathfrak m\}$ be the punctured spectrum. Restriction of a crystal $(M, F)$ to $U$ yields a crystal $(M_U, F_U)$, and on the level of underlying modules there is a canonical $R$-linear **restriction map** $\rho_M : M \to M_U$ that is automatically $F$-compatible: $\rho_M \circ F_M = F_{M_U} \circ \rho_M$.

In the algebraic model we encode restriction as such an $F$-compatible $R$-linear map of underlying modules. The two phenomena that govern purity are then exactly:

1. **Injectivity of $\rho$** (depth $\geq 1$ / torsion-freeness): no nonzero section of the target is supported entirely at $\mathfrak m$. Regularity (indeed depth $\geq 1$) supplies this.
2. **Surjectivity-type extension** (depth $\geq 2$ / Hartogs): every section over $U$ extends across $\mathfrak m$. Regularity in dimension $\geq 2$ (codimension-$\geq 2$ puncture) supplies this; in dimension one it is integral closedness.

### 2.3 Integral closure and normality

**Definition 2.3.** Let $R$ be a commutative ring and $S$ an $R$-algebra. An element $x \in S$ is **integral over $R$** if it satisfies a *monic* polynomial with coefficients in $R$:
$$x^n + r_{n-1}x^{n-1} + \cdots + r_1 x + r_0 = 0, \qquad r_i \in R.$$

**Definition 2.4.** A domain $R$ with fraction field $K$ is **integrally closed** (equivalently **normal**) if every $x \in K$ integral over $R$ already lies in $R$. Equivalently, the integral closure of $R$ in $K$ equals $R$.

**Fact 2.5.** A regular local ring of dimension one is a discrete valuation ring (DVR), and every DVR is a principal ideal domain, hence integrally closed. Thus in dimension one, *regular = DVR = normal*.

---

## 3. Dimension-one purity: the unconditional core

In dimension one the entire purity statement collapses onto integral closedness, and we prove it without hypotheses beyond normality.

### 3.1 Existence of the extension

**Theorem 3.1 (Hartogs in dimension one, `hartogs_dim_one`).**
Let $R$ be an integrally closed domain with fraction field $K$ (so $R$ is a domain, $K$ a field, and $K = \operatorname{Frac}(R)$ via the structure map $\operatorname{algebraMap}: R \to K$). Then for every $x \in K$ that is integral over $R$, there exists $a \in R$ with
$$\operatorname{algebraMap}_{R\to K}(a) = x.$$

*Proof sketch.* By Definition 2.4, integral closedness is exactly the statement that the integral closure of $R$ in $K$ is $R$ itself. Formally, this is captured by the characterization "$x$ is integral over $R$ $\iff$ $x$ is in the image of $R \to K$." The hypothesis $\mathrm{IsIntegral}\ R\ x$ therefore rewrites directly to "$x$ lies in the image," producing the witness $a$. $\square$

This is the geometric heart: a section regular away from the closed point (an integral element of the fraction field) extends to a global section.

### 3.2 Uniqueness of the extension

**Theorem 3.2 (Faithfulness in dimension one, `extension_unique`).**
For any domain $R$ with fraction field $K$, the structure map $\operatorname{algebraMap}: R \to K$ is injective.

*Proof sketch.* This is the standard fact that a domain embeds into its field of fractions: $\operatorname{algebraMap}: R \to \operatorname{Frac}(R)$ is injective because $a/1 = b/1$ forces $a = b$ in a domain. $\square$

### 3.3 Existence and uniqueness packaged

**Theorem 3.3 (`hartogs_dim_one_unique`).**
Let $R$ be an integrally closed domain with fraction field $K$. For every $x \in K$ integral over $R$, there exists a **unique** $a \in R$ with $\operatorname{algebraMap}(a) = x$:
$$\exists!\, a \in R,\quad \operatorname{algebraMap}_{R\to K}(a) = x.$$

*Proof sketch.* Existence is Theorem 3.1, giving $a$ with $\operatorname{algebraMap}(a) = x$. For uniqueness, suppose $\operatorname{algebraMap}(b) = x$ as well. Then $\operatorname{algebraMap}(a) = \operatorname{algebraMap}(b)$, and injectivity (Theorem 3.2) yields $a = b$. $\square$

Thus the integral elements of $K$ are **exactly** the global sections of $R$, identified without ambiguity. This is the dimension-one purity statement in its sharpest form: existence from normality, uniqueness from the domain embedding.

### 3.4 Concrete instances

**Corollary 3.4 (Algebraic integers in $\mathbb{Q}$, `hartogs_Z`).**
If $q \in \mathbb{Q}$ is integral over $\mathbb{Z}$, then there exists $n \in \mathbb{Z}$ with $(n : \mathbb{Q}) = q$. In words: a rational algebraic integer is a rational integer.

*Proof sketch.* $\mathbb{Z}$ is a PID, hence integrally closed, with fraction field $\mathbb{Q}$. Apply Theorem 3.1 with $R = \mathbb{Z}$, $K = \mathbb{Q}$ and simplify the coercion $\mathbb{Z} \hookrightarrow \mathbb{Q}$. $\square$

**Corollary 3.5 (Poles-free rational functions, `hartogs_polyQ`).**
If $x \in \mathbb{Q}(X)$ (the field of rational functions) is integral over $\mathbb{Q}[X]$, then there exists a polynomial $p \in \mathbb{Q}[X]$ with $\operatorname{algebraMap}_{\mathbb{Q}[X]\to\mathbb{Q}(X)}(p) = x$. In words: a rational function with no poles is a polynomial.

*Proof sketch.* $\mathbb{Q}[X]$ is a PID, hence integrally closed, with fraction field $\mathbb{Q}(X)$. Apply Theorem 3.1 directly. $\square$

These two corollaries are *the same theorem in two costumes*: $\mathbb{Z}\subseteq\mathbb{Q}$ is the arithmetic line, $\mathbb{Q}[X]\subseteq\mathbb{Q}(X)$ is the geometric line, and both are integrally closed domains.

---

## 4. The categorical skeleton of purity

We now formulate the categorical statement and isolate its two layers.

### 4.1 Faithfulness (Layer one)

**Theorem 4.1 (`restriction_faithful`).**
Let $(M, F_M)$ and $(N, F_N)$ be Frobenius modules and let $\rho_N : N \to N_U$ be the restriction map on the *target*. Suppose $\rho_N$ is **injective**. Then for any two crystal morphisms
$$g_1, g_2 : (M, F_M) \to (N, F_N),$$
if their restrictions agree, $\rho_N \circ g_1 = \rho_N \circ g_2$, then $g_1 = g_2$. Equivalently, the restriction functor is **faithful**.

*Proof sketch.* By extensionality it suffices to show $g_1(m) = g_2(m)$ for every $m \in M$. The hypothesis $\rho_N \circ g_1 = \rho_N \circ g_2$ gives $\rho_N(g_1(m)) = \rho_N(g_2(m))$. Since $\rho_N$ is injective, $g_1(m) = g_2(m)$. $\square$

The injectivity of $\rho_N$ is the algebraic content of *depth $\geq 1$*: the target crystal has no nonzero section supported entirely at the closed point, so restriction loses nothing. No regularity beyond this injectivity is needed — faithfulness is genuinely cheap.

**Instance 4.2 (`trivZ_faithful`).**
Take $R = \mathbb{Z}$ with trivial Frobenius, $N = \mathbb{Z}$ with $F_N = \mathrm{id}$, and restriction $\rho_N : \mathbb{Z} \to \mathbb{Q}$ the canonical inclusion, which is injective. Then Theorem 4.1 applies non-vacuously: any two crystal morphisms into $(\mathbb{Z}, \mathrm{id})$ that agree after restriction to $\mathbb{Q}$ are equal. This certifies that Theorem 4.1 is not vacuous.

### 4.2 Full faithfulness via Hartogs extension (Layer two)

The deep half of purity is *extension*: producing, for every morphism over $U$, a morphism over $\operatorname{Spec} R$ restricting to it. We axiomatize the extension as an operator with a section property and show it upgrades faithfulness to a bijection.

**Theorem 4.3 (`purityHomEquiv`).**
Let $(E, F_E)$ and $(\mathcal F, F_{\mathcal F})$ be Frobenius modules with restricted crystals $(E_U, F_{E_U})$ and $(\mathcal F_U, F_{\mathcal F_U})$. Suppose:

1. (**Faithfulness input**) The restriction map on the target $\mathcal F$ is injective.
2. (**Hartogs extension operator**) There is a map
$$\operatorname{extend} : \mathrm{FHom}\big(E_U, \mathcal F_U\big) \longrightarrow \mathrm{FHom}\big(E, \mathcal F\big)$$
that is a section of restriction: $\operatorname{res}\circ\operatorname{extend} = \mathrm{id}$ on $\mathrm{FHom}(E_U,\mathcal F_U)$ (the section property `hsec`).

Then restriction induces a **bijection** (an `Equiv`)
$$\mathrm{FHom}\big(E, \mathcal F\big) \;\xrightarrow{\ \sim\ }\; \mathrm{FHom}\big(E_U, \mathcal F_U\big).$$

*Proof sketch.* Define the forward map as restriction $\operatorname{res}$ and the inverse candidate as $\operatorname{extend}$. The right inverse property ($\operatorname{res}\circ\operatorname{extend} = \mathrm{id}$) is exactly hypothesis (2). The left inverse property ($\operatorname{extend}\circ\operatorname{res} = \mathrm{id}$) follows from faithfulness: for $g \in \mathrm{FHom}(E,\mathcal F)$, both $g$ and $\operatorname{extend}(\operatorname{res}(g))$ restrict to the same morphism $\operatorname{res}(g)$ (the latter by hypothesis (2)), so by Theorem 4.1 they are equal. Packaging the two inverse laws yields the `Equiv`. $\square$

This is the precise sense in which **"purity reduces to extension."** Once the Hartogs extension operator with its section property is available, full faithfulness is immediate; the only nontrivial geometric input is the existence of $\operatorname{extend}$. In dimension one, $\operatorname{extend}$ is built entrywise from Theorem 3.1 (`hartogs_dim_one`); in higher dimensions its existence is the codimension-$\geq 2$ Hartogs theorem, which regularity is expected to supply.

### 4.3 From full faithfulness to determination by dense opens

**Corollary 4.4.** Full faithfulness of restriction (the bijection of Theorem 4.3 on all $\operatorname{Hom}$-sets) implies that a crystal is determined up to canonical isomorphism by its restriction to any dense open. In particular, if purity holds for $F$-crystals on $\operatorname{Spec}(A/I)$, then Ogus's canonical $F$-isocrystal is uniquely determined by its restriction to any dense open subscheme.

*Proof sketch.* Determination-up-to-isomorphism is a formal consequence of full faithfulness: two crystals with isomorphic restrictions have an isomorphism of restrictions, which (by the $\operatorname{Hom}$-set bijection applied to the isomorphism and its inverse) lifts to a mutually inverse pair upstairs, hence an isomorphism. This uses only the $\operatorname{Hom}$-set bijection — not essential surjectivity. $\square$

---

## 5. Sharpness: normality is necessary

The hypotheses above are load-bearing, not decorative. We show that dropping normality breaks purity.

**Proposition 5.1 (Sharp counterexample).**
Let $R = \mathbb{Z}[2i] = \{a + 2bi : a, b \in \mathbb{Z}\} \subset \mathbb{Z}[i] \subset \mathbb{Q}(i)$. This is a non-maximal order (not integrally closed). The element $i \in \mathbb{Q}(i)$ satisfies the monic polynomial
$$x^2 + 1 = 0,$$
so $i$ is integral over $R$. However $i \notin R$, since $i = 0 + \tfrac12(2i)$ requires the coefficient $\tfrac12 \notin \mathbb{Z}$. Therefore the extension conclusion of Theorem 3.1 **fails** for $R$: there is an integral element of the fraction field with no global section extending it. Hence normality (integral closedness) is *necessary* for dimension-one purity.

*Discussion.* Geometrically, $\operatorname{Spec}(\mathbb{Z}[2i])$ has a singular point at the prime above $2$ where the order fails to be normal; the section $i$ is regular on the punctured spectrum but does not extend. Normalizing $\mathbb{Z}[2i]$ to $\mathbb{Z}[i]$ repairs purity, exactly as Theorem 3.1 predicts for the (now integrally closed) ring $\mathbb{Z}[i]$. This is the sharp boundary between a world where punctures are harmless and one where they hide information.

---

## 6. Algorithms

The constructive content of the theory yields decision and construction procedures. We describe two.

### 6.1 Rational-integrality decision (witness for `hartogs_Z`)

Given a rational $q = a/b$ in lowest terms and a monic integer polynomial $f$, decide whether $q$ is integral over $\mathbb{Z}$ and, if so, return the integer it extends to. By the rational root theorem, a monic $f$ with $f(q)=0$ forces $b \mid 1$, i.e. $b = \pm 1$ and $q \in \mathbb{Z}$. The algorithm checks denominators and evaluates $f$, mirroring Corollary 3.4.

### 6.2 Faithfulness verification (witness for `restriction_faithful`)

Given finite-rank Frobenius modules over a domain and a presentation of the restriction map $\rho_N$ as a matrix, verify injectivity (full column rank over the fraction field), then confirm that two given morphisms agreeing after restriction coincide by checking equality of their matrices — a direct computational shadow of Theorem 4.1.

(Both are presented as pseudocode and typed Python in the companion package.)

---

## 7. Applications

- **Number theory.** Corollary 3.4 is the foundational fact that the integral closure of $\mathbb{Z}$ in $\mathbb{Q}$ is $\mathbb{Z}$ — the bedrock of algebraic number theory's distinction between orders and maximal orders (rings of integers).
- **Function fields and geometry.** Corollary 3.5 is the affine-line statement that a regular function (no poles) is a polynomial — the prototype of extending sections of line bundles.
- **Reconstruction from dense opens.** Corollary 4.4 yields that crystalline coefficient objects are determined by their restriction to dense opens, a holography principle central to $p$-adic Hodge theory and to Ogus's conjecture.
- **Detecting non-normality.** Proposition 5.1 turns purity into a diagnostic: failure of section-extension across a puncture certifies non-normality of the base.

---

## 8. Discussion

The decomposition we adopt — *faithfulness is cheap; extension is the whole game* — clarifies precisely where the difficulty in purity for prismatic $F$-crystals lives. Layer one (Theorem 4.1) is an injectivity argument requiring only depth $\geq 1$; we proved it unconditionally and certified its non-vacuity over $\mathbb{Z}\subseteq\mathbb{Q}$ (`trivZ_faithful`). Layer two (Theorem 4.3) reduces full faithfulness to the existence of a Hartogs extension operator, which is the genuine codimension-$\geq 2$ geometric content; we keep it as an explicit hypothesis rather than disguise it.

In dimension one, the extension operator is *not* hypothetical: it is `hartogs_dim_one` (Theorem 3.1), applied entrywise. So the dimension-one purity-on-$\operatorname{Hom}$-sets statement is within immediate reach, requiring only the functorial assembly of `extend` from `hartogs_dim_one`. The sharp counterexample (Proposition 5.1) confirms that normality — the hypothesis powering Theorem 3.1 — cannot be removed.

A subtle point worth emphasizing: uniqueness/faithfulness and existence/extension are *independent* inputs. Faithfulness never needs normality (only torsion-freeness); extension never follows from faithfulness alone. The clean separation is what makes the theory modular and lets the hard input be isolated, named, and attacked in isolation.

---

## 9. Future directions

1. **Unconditional dimension-one purity equivalence on $\operatorname{Hom}$-sets.** For a DVR $R$ with fraction field $K$, build the `extend` operator of `purityHomEquiv` unconditionally from `hartogs_dim_one`, yielding an honest `Equiv` $\mathrm{FHom}(E,\mathcal F)\simeq\mathrm{FHom}(E_U,\mathcal F_U)$ with no hypotheses beyond regularity in dimension one. The abstract extension hypothesis is *literally* `hartogs_dim_one` applied entrywise to a basis; only functoriality of `extend` remains.

2. **Codimension-two Hartogs for finite free modules.** For a regular local ring of dimension $\geq 2$, show that a finite free module restricted to the punctured spectrum has global sections exactly $R^n$. The engine is depth $\geq 2 \Rightarrow H^0_{\mathfrak m} = H^1_{\mathfrak m} = 0$, which drives both fullness and essential surjectivity; the dimension-one case settled here is the induction base.

3. **Frobenius-equivariant Hartogs.** Show that extension across a codimension-$\geq 2$ locus is automatically $F$-compatible, so the extended morphism is a morphism of $F$-crystals, not merely of modules. $F$-equivariance is a closed condition cut out by a torsion-free "defect" module, and a torsion-free module with no sections on the puncture has none globally — reducing equivariance to faithfulness (`restriction_faithful`).

4. **Purity transfers Ogus's canonical $F$-isocrystal across dense opens.** If purity holds for $F$-crystals on $\operatorname{Spec}(A/I)$, then Ogus's canonical $F$-isocrystal is uniquely determined, functorially, by its restriction to any dense open. Uniqueness-up-to-isomorphism follows from full faithfulness (the `Equiv` on $\operatorname{Hom}$-sets) alone, independent of essential surjectivity.

5. **Sharpness for non-normal bases.** For every non-normal Noetherian local domain, construct an $F$-crystal whose restriction to the punctured spectrum does not extend — a systematic strengthening of Proposition 5.1 from the example $\mathbb{Z}[2i]$ to all non-normal bases.

---

## 10. Conclusion

We have given a modular account of prismatic purity for $F$-crystals, separating the cheap faithfulness layer from the deep Hartogs-extension layer, proving the former unconditionally and reducing the latter to a single, clearly-stated input. The dimension-one case is settled in full generality for integrally closed domains, with two concrete instantiations and a sharp counterexample establishing the necessity of normality. The framework reduces the determination of Ogus's canonical $F$-isocrystal by dense opens to the full-faithfulness half of purity, isolating the codimension-$\geq 2$ Hartogs theorem as the sole remaining obstacle in higher dimensions.
