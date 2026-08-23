# A Guarded Transfer Principle for Real Analysis over a Total Four-Constructor Arithmetic

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We study the extent to which ordinary real analysis survives passage into a *total* arithmetic: the four-constructor **transreal carrier**
$$\mathbb{T} \;=\; \{\mathrm{fin}\,x : x \in \mathbb{R}\} \;\cup\; \{+\infty\} \;\cup\; \{-\infty\} \;\cup\; \{\Phi\},$$
equipped with addition, negation, multiplication, reciprocal and division that are defined on *all* inputs, the exceptional element $\Phi$ ("nullity") absorbing the indeterminate forms $\infty - \infty$, $0\cdot\infty$ and $0/0$.

Our main theorem is a **guarded transfer principle**. Formalising "theorem built from continuous real functions by composition, addition, multiplication and division" as an inductive expression syntax with two semantics — a real one and a total transreal one — we prove that every expression whose denominator subexpressions are *nowhere vanishing* has transreal semantics equal to $\mathrm{fin} \circ (\text{real semantics})$, hence continuous into $\mathbb{T}$ under the natural compact Hausdorff topology. Transfer is moreover **exactly conservative** (two guarded expressions are transreally equal iff they are really equal) and **functorial** (guardedness is stable under continuous reparametrisation of the parameter space).

We then show that the guard is sharp, and that it is not an arbitrary side condition. Four independent characterisations pick out the same class of denominators:

1. **Algebraic.** An element of $\mathbb{T}$ is multiplicatively invertible iff it is a nonzero finite element; it is additively invertible iff it is finite. The guarded denominators are exactly the units.
2. **Topological.** Binary division $(a,b)\mapsto a/b$ is continuous at $(\mathrm{fin}\,x,\mathrm{fin}\,y)$ iff $y \neq 0$; this computes the continuity locus on the finite square exactly.
3. **Rigidity.** For every T₁ topology on $\mathbb{T}$, the punctured constant $x \mapsto x/x$ admits a continuous extension by exactly one value, namely $1$ — while total arithmetic is forced to return $\Phi$. Deleting the guard therefore fails by exactly one point and exactly one value, for every T₁ topology.
4. **Non-repairability.** In the natural topology, the reciprocal patched at the origin by *any* element of $\mathbb{T}$ is discontinuous there. Enlarging the number system does not repair unguarded division.

Finally we compute the exact boundary of failure. At an isolated zero $x_0$ of the denominator $g$ with numerator $f$, there is a trichotomy: $f(x_0) = g(x_0) = 0$ always destroys continuity (with no regularity hypotheses whatsoever); a *positive one-signed* pole ($f(x_0) > 0$ and $g > 0$ on a punctured neighbourhood) **preserves** continuity, with value $+\infty$ — so $x\mapsto 1/x^2$ is a continuous map $\mathbb{R} \to \mathbb{T}$; and a *sign-changing* pole destroys it, the two one-sided limits being the distinct points $\pm\infty$. The positivity is essential: because the total reciprocal of zero is $+\infty$ by convention, the value assigned at a pole follows the sign of the numerator alone, so a one-signed pole with a *negative* denominator also fails — and, strikingly, $1/(-x^2)$ and $(-1)/x^2$ agree as real functions off the origin yet are assigned $+\infty$ and $-\infty$ there, only the second being continuous. Hence the nowhere-vanishing guard is sufficient and syntactically unimprovable, but not necessary, and the unguarded failure is *generic* rather than universal — exactly as the informal conjecture predicts.

We close with the structural cost of totality: $\mathbb{T}$ is compact Hausdorff, but neither addition nor multiplication is jointly continuous (failing at $(+\infty,-\infty)$ and at $(0,+\infty)$ respectively), and distributivity fails on the exceptional constructors. The application context is exception-free arithmetic in cryptographic implementations, where division at the projective point at infinity forces either a data-dependent branch or a totalised quotient.

**Keywords:** transreal arithmetic, nullity, total division, transfer principle, two-point compactification, continuity locus, pole trichotomy, exception-free computation.

---

## 1. Introduction

### 1.1 Totality versus faithfulness

Division is the only partial operation of elementary arithmetic, and its partiality is the origin of an outsized share of engineering pain: hardware traps, exception handlers, data-dependent branches, and — in cryptographic code — timing side channels. A recurring proposal is therefore to *totalise*: extend the number system with enough exceptional values that every arithmetic operation returns something, so that programs never trap and formulas never need side conditions.

The best-known such extension is the **transreal line** of Anderson, which adjoins to $\mathbb{R}$ two signed infinities and a single further element $\Phi$ (*nullity*), and posits
$$\frac{1}{0} = +\infty,\qquad \frac{-1}{0} = -\infty, \qquad \frac{0}{0} = \Phi.$$
IEEE-754 floating point makes a closely related choice, with $\Phi$ playing the role of `NaN`.

Totalisation is cheap to state and easy to implement. The mathematical question it raises is *faithfulness*: if a theorem is proved about real numbers and then re-read in the totalised system, does it remain true? If not, exactly where does it break? A totalisation that quietly changes the truth value of theorems is worse than useless. One that provably does not is a licence to reason classically and implement branch-free.

This paper answers the question completely for the fragment generated by continuous real functions under composition, addition, multiplication and division.

### 1.2 Statement of the informal conjecture

> **Conjecture.** Every theorem built from continuous real functions using finite composition, addition, multiplication, and division by a nowhere-zero denominator transfers through the finite transreal fragment; while any unguarded extension allowing a denominator to reach zero generally fails to preserve continuity into a natural Hausdorff topology on the four-constructor carrier.

The conjecture is proved below in a strong form, and its two hedges — "nowhere-zero denominator" and "generally" — are both shown to be exactly the right words. The guard cannot be weakened (Section 6), and the word "generally" cannot be strengthened to "always", because of the one-signed pole regime (Section 7).

### 1.3 Contributions and outline

* **Section 2** constructs the carrier and its total arithmetic and proves *exact conservativity*: $\mathrm{fin}$ transports $+$, $\cdot$, $-$ verbatim and transports $/$ verbatim exactly when the denominator is nonzero, the failure being governed by a sign trichotomy.
* **Section 3** endows $\mathbb{T}$ with its natural topology, shows it is compact Hausdorff, that $\mathrm{fin}$ is an open embedding, and that $\{\Phi\}$ is open.
* **Section 4** introduces the expression syntax and the pointwise and uniform guards, and proves the **transfer principle**, its **faithfulness**, and its **functoriality**.
* **Section 5** characterises the guard algebraically: the guarded denominators are the units.
* **Section 6** proves sharpness: the exact continuity locus of binary division; the topology-independent failure of $x/x$; the rigidity theorem identifying $1$ as the unique repair value; and the non-repairability of the reciprocal.
* **Section 7** proves the pole trichotomy and exhibits $x \mapsto 1/x^2$ as a continuous unguarded map.
* **Section 8** records the structural cost of totality: failure of joint continuity of $+$ and $\cdot$, and failure of distributivity.
* **Sections 9–11** give algorithms, applications and future directions.

---

## 2. The carrier and its total arithmetic

### 2.1 Definition

**Definition 2.1 (Transreal carrier).** $\mathbb{T}$ is the four-constructor type
$$\mathbb{T} \;::=\; \mathrm{fin}\,(x : \mathbb{R}) \;\mid\; +\infty \;\mid\; -\infty \;\mid\; \Phi .$$
The map $\mathrm{fin} : \mathbb{R} \to \mathbb{T}$ is injective; its image is called the **finite fragment**, and an element in the image is called *finite*.

**Definition 2.2 (Addition).** $\Phi$ is absorbing: $\Phi + a = a + \Phi = \Phi$. Otherwise
$$\mathrm{fin}\,x + \mathrm{fin}\,y = \mathrm{fin}(x+y), \quad \mathrm{fin}\,x \pm\infty = \pm\infty \pm \mathrm{fin}\,x = \pm\infty,$$
$$(+\infty)+(+\infty) = +\infty, \quad (-\infty)+(-\infty) = -\infty, \quad (+\infty)+(-\infty) = (-\infty)+(+\infty) = \Phi.$$

**Definition 2.3 (Negation).** $-\mathrm{fin}\,x = \mathrm{fin}(-x)$, $-(+\infty) = -\infty$, $-(-\infty) = +\infty$, $-\Phi = \Phi$.

**Definition 2.4 (Multiplication).** $\Phi$ is absorbing. Otherwise $\mathrm{fin}\,x \cdot \mathrm{fin}\,y = \mathrm{fin}(xy)$; for a finite factor against an infinity,
$$\mathrm{fin}\,x \cdot (+\infty) \;=\; \begin{cases} \Phi & x = 0\\ +\infty & x > 0\\ -\infty & x < 0\end{cases} \qquad \mathrm{fin}\,x \cdot (-\infty) \;=\; \begin{cases} \Phi & x = 0\\ -\infty & x > 0\\ +\infty & x < 0\end{cases}$$
and symmetrically on the other side; and $(\pm\infty)\cdot(\pm\infty)$ follows the sign rule.

**Definition 2.5 (Reciprocal and division).**
$$\mathrm{recip}(\mathrm{fin}\,x) = \begin{cases} +\infty & x = 0 \\ \mathrm{fin}\,x^{-1} & x \ne 0\end{cases} \qquad \mathrm{recip}(\pm\infty) = \mathrm{fin}\,0, \qquad \mathrm{recip}(\Phi) = \Phi,$$
and $a / b := a \cdot \mathrm{recip}(b)$.

**Proposition 2.6.** Addition on $\mathbb{T}$ is commutative and associative with identity $\mathrm{fin}\,0$; multiplication is commutative with identity $\mathrm{fin}\,1$; and $-(-a) = a$. *(Proof: exhaustive case analysis on the constructors, the finite–finite cases reducing to the corresponding real laws.)*

We write $0$ and $1$ for $\mathrm{fin}\,0$ and $\mathrm{fin}\,1$ where no confusion arises.

### 2.2 Exact conservativity and the division boundary

**Theorem 2.7 (Exact conservativity of guarded arithmetic).** For all $x,y \in \mathbb{R}$:
$$\mathrm{fin}\,x + \mathrm{fin}\,y = \mathrm{fin}(x+y), \qquad \mathrm{fin}\,x\cdot\mathrm{fin}\,y = \mathrm{fin}(xy), \qquad -\mathrm{fin}\,x = \mathrm{fin}(-x),$$
and, provided $y \neq 0$,
$$\frac{\mathrm{fin}\,x}{\mathrm{fin}\,y} = \mathrm{fin}\!\left(\frac{x}{y}\right).$$

*Proof sketch.* The first three are the defining clauses. For the fourth, $y \neq 0$ gives $\mathrm{recip}(\mathrm{fin}\,y) = \mathrm{fin}\,y^{-1}$, whence $\mathrm{fin}\,x/\mathrm{fin}\,y = \mathrm{fin}\,x \cdot \mathrm{fin}\,y^{-1} = \mathrm{fin}(x y^{-1}) = \mathrm{fin}(x/y)$. $\square$

**Theorem 2.8 (The division boundary).** For every $x \in \mathbb{R}$,
$$\frac{\mathrm{fin}\,x}{\mathrm{fin}\,0} \;=\; \begin{cases} +\infty & x > 0,\\ -\infty & x < 0,\\ \Phi & x = 0.\end{cases}$$

*Proof sketch.* $\mathrm{recip}(\mathrm{fin}\,0) = +\infty$, so the quotient is $\mathrm{fin}\,x \cdot (+\infty)$; apply the sign clauses of Definition 2.4. $\square$

**Corollary 2.9 (Self-division).** $\dfrac{\mathrm{fin}\,x}{\mathrm{fin}\,x} = \begin{cases}\Phi & x = 0\\ 1 & x \ne 0.\end{cases}$

**Corollary 2.10 (Closure and its failure).** The finite fragment is closed under $+$, $\cdot$, $-$, and under division by a nonzero denominator; it is *not* closed under division by $0$ — for every $x$, $\mathrm{fin}\,x/\mathrm{fin}\,0$ is one of $+\infty$, $-\infty$, $\Phi$, none of which is finite.

Corollary 2.10 is the exact failure of conservativity, and everything that follows is an elaboration of it.

**Definition 2.11 (Strict lift).** For $f : \mathbb{R}\to\mathbb{R}$, the *strict lift* $\widehat f : \mathbb{T} \to \mathbb{T}$ sends $\mathrm{fin}\,x \mapsto \mathrm{fin}(f x)$ and every exceptional element to $\Phi$. Strict lifts compose on the nose: $\widehat f \circ \widehat g = \widehat{f\circ g}$.

Strict lifting encodes the design decision that a general real function has no canonical value at an exceptional argument; only the four arithmetic operations are extended by hand.

---

## 3. The natural topology

### 3.1 Construction

Let $\overline{\mathbb{R}} = [-\infty,+\infty]$ denote the two-point compactification of the line, with its order topology. There is an evident bijection
$$\iota : \mathbb{T} \longrightarrow \overline{\mathbb{R}} \sqcup \{\ast\}, \qquad \mathrm{fin}\,x \mapsto x,\quad \pm\infty \mapsto \pm\infty, \quad \Phi \mapsto \ast,$$
and we topologise $\mathbb{T}$ by pulling back the disjoint-union topology along $\iota$.

**Theorem 3.1.** With this topology:
1. $\mathbb{T}$ is Hausdorff;
2. $\mathbb{T}$ is compact;
3. $\mathrm{fin} : \mathbb{R} \to \mathbb{T}$ is an open embedding — the finite fragment is an open copy of the line;
4. $\{\Phi\}$ is open, i.e. nullity is an isolated point;
5. $\mathrm{fin}\,t \to +\infty$ as $t \to +\infty$ and $\mathrm{fin}\,t \to -\infty$ as $t \to -\infty$.

*Proof sketch.* $\iota$ is a bijection onto a compact Hausdorff space, and the induced topology makes it an embedding with full range, hence a closed embedding; Hausdorffness and compactness transfer. (3) holds because the canonical inclusion $\mathbb{R} \hookrightarrow \overline{\mathbb{R}}$ is an open embedding and $\overline{\mathbb{R}} \hookrightarrow \overline{\mathbb{R}}\sqcup\{\ast\}$ is one too. (4) is the openness of the second summand. (5) is the corresponding statement in $\overline{\mathbb{R}}$. $\square$

Item (4) has an immediate and much-used consequence.

**Corollary 3.2 (Nullity fibres are open).** If $h : X \to \mathbb{T}$ is continuous then $h^{-1}(\{\Phi\})$ is open in $X$.

### 3.2 Why this topology is the natural one

Three demands pin the topology down morally, and (as recorded in Section 11) conjecturally pin it down literally:

* the finite fragment must be an open copy of $\mathbb{R}$ (finite arithmetic should be locally indistinguishable from real arithmetic);
* $\pm\infty$ must be the two ends of the line, since that is exactly what makes $1/x \to \pm\infty$ true;
* $\Phi$ must be isolated, since nullity is not the limit of finite values under any arithmetic law — it is a *flag*, not a magnitude.

A compact Hausdorff space containing $\mathbb{R}$ as an open subset with a two-point remainder is the end compactification, because the line has exactly two ends; adjoining $\Phi$ as an isolated point is then the unique way to satisfy the third demand while retaining compactness. We use only the four stated properties in the positive results, and only T₁ separation in the strongest negative ones.

---

## 4. The transfer principle

### 4.1 The syntax

**Definition 4.1 (Expressions).** For a parameter space $X$, the set $\mathsf{Expr}(X)$ of *arithmetic expressions* is generated inductively by:
* $\mathrm{atom}\,f$ for $f : X \to \mathbb{R}$;
* $\mathrm{const}\,c$ for $c \in \mathbb{R}$;
* $\mathrm{comp}\,f\,e$ for $f : \mathbb{R}\to\mathbb{R}$ and $e \in \mathsf{Expr}(X)$;
* $e_1 + e_2$, $e_1 \cdot e_2$, $e_1 / e_2$.

**Definition 4.2 (Two semantics).** The *real semantics* $R\llbracket e\rrbracket : X \to \mathbb{R}$ interprets the constructors by ordinary real arithmetic, with the convention $c/0 = 0$ used for the (irrelevant) unguarded case. The *transreal semantics* $T\llbracket e\rrbracket : X \to \mathbb{T}$ interprets $\mathrm{atom}\,f$ as $\mathrm{fin}\circ f$, $\mathrm{const}\,c$ as the constant $\mathrm{fin}\,c$, $\mathrm{comp}\,f$ as the strict lift $\widehat f$, and $+,\cdot,/$ by total transreal arithmetic.

**Definition 4.3 (Pointwise guard).** $\mathrm{Def}(e, x)$ holds iff every denominator subexpression of $e$ has nonzero real value at $x$; formally, it is $\top$ on atoms and constants, propagates through $\mathrm{comp}$, $+$ and $\cdot$, and for $e_1/e_2$ requires $\mathrm{Def}(e_1,x)$, $\mathrm{Def}(e_2,x)$ and $R\llbracket e_2\rrbracket(x)\ne 0$.

**Definition 4.4 (Uniform guard).** For $X$ a topological space, $e$ is **guarded** iff every atom function is continuous, every composed function is continuous, and for every division subexpression $e_1/e_2$ the denominator satisfies $R\llbracket e_2\rrbracket(x) \ne 0$ for **all** $x \in X$. It is **weakly guarded** iff the same holds with the nowhere-vanishing clause deleted.

Guarded $\Rightarrow$ weakly guarded, and guarded $\Rightarrow$ $\mathrm{Def}(e,x)$ for every $x$ (both by structural induction).

### 4.2 The main theorems

**Theorem 4.5 (Pointwise exact conservativity).** If $\mathrm{Def}(e,x)$ then
$$T\llbracket e \rrbracket(x) \;=\; \mathrm{fin}\big(R\llbracket e \rrbracket(x)\big).$$
In particular $T\llbracket e\rrbracket(x)$ is finite: the exceptional constructors are unreachable under the guard.

*Proof sketch.* Structural induction. Atoms and constants are immediate. For $\mathrm{comp}\,f\,e$, the inductive hypothesis puts the argument in the finite fragment, where the strict lift acts as $f$. For $+$ and $\cdot$, apply the inductive hypotheses and the conservativity clauses of Theorem 2.7. The only nontrivial case is $e_1/e_2$, where the guard supplies $R\llbracket e_2\rrbracket(x) \neq 0$ and the guarded division clause of Theorem 2.7 applies. $\square$

**Theorem 4.6 (Guarded transfer principle).** Let $X$ be a topological space and $e$ a guarded expression. Then $R\llbracket e\rrbracket : X \to \mathbb{R}$ is continuous, $T\llbracket e\rrbracket = \mathrm{fin}\circ R\llbracket e\rrbracket$, and consequently
$$T\llbracket e\rrbracket : X \longrightarrow \mathbb{T}$$
is continuous into the compact Hausdorff carrier.

*Proof sketch.* Continuity of $R\llbracket e\rrbracket$ is a structural induction using continuity of sums, products, compositions, and of quotients with nowhere-vanishing denominator. The identity $T\llbracket e\rrbracket = \mathrm{fin}\circ R\llbracket e\rrbracket$ is Theorem 4.5 applied at every point. Continuity then follows since $\mathrm{fin}$ is continuous (Theorem 3.1(3)). $\square$

**Theorem 4.7 (Faithfulness / exact conservativity of transfer).** For guarded $e_1, e_2$,
$$\big(\forall x,\ T\llbracket e_1\rrbracket(x) = T\llbracket e_2\rrbracket(x)\big) \iff \big(\forall x,\ R\llbracket e_1\rrbracket(x) = R\llbracket e_2\rrbracket(x)\big).$$

*Proof sketch.* Both sides reduce, via Theorem 4.5, to the equality $\mathrm{fin}(R\llbracket e_1\rrbracket(x)) = \mathrm{fin}(R\llbracket e_2\rrbracket(x))$; and $\mathrm{fin}$ is injective. $\square$

Thus the transfer is not merely sound but *exactly conservative*: no guarded identity is lost, and no new one is gained.

**Definition 4.8 (Pullback).** For $g : Y \to X$, the expression $g^\ast e \in \mathsf{Expr}(Y)$ is obtained by replacing every atom $f$ with $f\circ g$. One checks by induction that $R\llbracket g^\ast e\rrbracket(y) = R\llbracket e\rrbracket(g y)$ and $T\llbracket g^\ast e\rrbracket(y) = T\llbracket e\rrbracket(g y)$.

**Theorem 4.9 (Functoriality of the guard).** If $g : Y \to X$ is continuous and $e$ is guarded, then $g^\ast e$ is guarded.

*Proof sketch.* Induction; atoms become $f\circ g$, continuous as a composite, and the nowhere-vanishing clause for a denominator $e_2$ transports because $R\llbracket g^\ast e_2\rrbracket(y) = R\llbracket e_2\rrbracket(g y) \neq 0$. $\square$

Hence a single guarded identity transfers simultaneously to every continuous family of instances of it.

### 4.3 A worked instance

**Example 4.10 (The logistic function).** Let $e = \dfrac{\exp(x)}{1 + \exp(x)}$, i.e. $\mathrm{comp}(\exp)(\mathrm{atom}\,\mathrm{id})$ divided by $\mathrm{const}\,1 + \mathrm{comp}(\exp)(\mathrm{atom}\,\mathrm{id})$. The denominator satisfies $1 + e^x \geq 1 > 0$ everywhere, so $e$ is guarded. By Theorem 4.6, $T\llbracket e\rrbracket$ is a continuous map $\mathbb{R}\to\mathbb{T}$ and
$$T\llbracket e\rrbracket(x) = \mathrm{fin}\!\left(\frac{e^x}{1+e^x}\right)$$
for every $x$. So the logistic function — the workhorse of statistics and of neural networks — transfers verbatim, values, continuity and all. Every identity it satisfies against other guarded expressions (for instance $\sigma(x) + \sigma(-x) = 1$) transfers in both directions by Theorem 4.7.

---

## 5. The guard is invertibility

Why "denominator nonzero" and not some other side condition? Because it is the unit group.

**Theorem 5.1 (Multiplicative units).** For $a \in \mathbb{T}$,
$$\big(\exists\, b \in \mathbb{T},\ a\cdot b = 1\big) \iff \big(\exists\, x \in \mathbb{R},\ x \ne 0 \text{ and } a = \mathrm{fin}\,x\big).$$

*Proof sketch.* ($\Leftarrow$) Take $b = \mathrm{fin}\,x^{-1}$. ($\Rightarrow$) Case on $a$. If $a = \mathrm{fin}\,0$, then $a\cdot b \in \{0, \Phi\}$ for every $b$, never $1$. If $a = \pm\infty$, then $a\cdot b$ is $\pm\infty$ or $\Phi$ for every $b$ (against a finite $y$ it is $\Phi$ if $y=0$ and an infinity otherwise; against an infinity it is an infinity; against $\Phi$ it is $\Phi$), never the finite value $1$. If $a = \Phi$ then $a\cdot b = \Phi$. $\square$

**Theorem 5.2 (Additive units).** For $a \in \mathbb{T}$, $\big(\exists\, b,\ a + b = 0\big)$ iff $a$ is finite.

*Proof sketch.* ($\Leftarrow$) $b = \mathrm{fin}(-x)$. ($\Rightarrow$) Sums involving $\pm\infty$ are $\pm\infty$ or $\Phi$, and $\Phi$ absorbs; none of these is $\mathrm{fin}\,0$. $\square$

**Interpretation.** Theorem 5.2 says the finite fragment is precisely the additive-group part of $\mathbb{T}$; Theorem 5.1 says the guarded denominators are precisely the multiplicative units. The two guards of the transfer principle — "stay finite" and "divide only by nonzero elements" — are therefore not chosen by hand: they are read off the algebra as the invertible parts of the two operations.

---

## 6. Sharpness of the guard

### 6.1 The continuity locus of binary division

**Theorem 6.1 (Guarded division is jointly continuous).** For $x, y \in \mathbb{R}$ with $y \neq 0$, the map $(a,b) \mapsto a/b$ on $\mathbb{T}\times\mathbb{T}$ is continuous at $(\mathrm{fin}\,x, \mathrm{fin}\,y)$.

*Proof sketch.* Since $\mathrm{fin}$ is an open embedding, so is $\mathrm{fin}\times\mathrm{fin}$, and it identifies $\mathcal{N}(x,y)$ with $\mathcal{N}(\mathrm{fin}\,x,\mathrm{fin}\,y)$. On a neighbourhood of $(x,y)$ the second coordinate is nonzero, so on that neighbourhood transreal division agrees with $\mathrm{fin}$ of real division, which is continuous at $(x,y)$ because $y \neq 0$. Transport back along the open embedding. $\square$

**Theorem 6.2 (Unguarded division is jointly discontinuous).** For *every* $x \in \mathbb{R}$, the map $(a,b)\mapsto a/b$ is **not** continuous at $(\mathrm{fin}\,x, \mathrm{fin}\,0)$.

*Proof sketch.* Restrict along $y \mapsto (\mathrm{fin}\,x, \mathrm{fin}\,y)$, which is continuous; if the binary map were continuous at the point, the restriction $y \mapsto \mathrm{fin}\,x/\mathrm{fin}\,y$ would be continuous at $0$. Two cases.
*If $x = 0$*: the value at $0$ is $\Phi$ and $\{\Phi\}$ is open, so $\Phi$-values would persist on a neighbourhood of $0$; but for $y \neq 0$ the value is $\mathrm{fin}(0/y) = 0 \neq \Phi$.
*If $x \neq 0$*: rescale. Writing $x/y = ((y/x))^{-1}$ exhibits $y \mapsto \mathrm{fin}\,x/\mathrm{fin}\,y$ as the patched reciprocal precomposed with the homeomorphism $y \mapsto y/x$; Theorem 6.4 below then applies. $\square$

Together, Theorems 6.1 and 6.2 compute the continuity locus of division on the finite square exactly: it is $\{(\mathrm{fin}\,x,\mathrm{fin}\,y) : y \text{ invertible}\}$. Topology recovers the algebraic characterisation of Section 5.

### 6.2 Topology-independent failure and rigidity

Define, for $v \in \mathbb{T}$, the *patched self-quotient*
$$s_v(x) = \begin{cases} v & x = 0 \\ 1 & x \ne 0.\end{cases}$$

**Lemma 6.3 (Punctured constants).** Let $t$ be any T₁ topology on $\mathbb{T}$ and $h : \mathbb{R}\to(\mathbb{T},t)$ continuous with $h(x) = v$ for all $x \neq 0$. Then $h(0) = v$.

*Proof sketch.* $\{v\}$ is closed by T₁, so $h^{-1}(\{v\})$ is closed and contains the dense set $\mathbb{R}\setminus\{0\}$, hence is all of $\mathbb{R}$. $\square$

**Theorem 6.4 (Rigidity: the unique repair value of $0/0$ is $1$).** For every T₁ topology on $\mathbb{T}$ and every $v\in\mathbb{T}$,
$$s_v \text{ is continuous} \iff v = 1.$$

*Proof sketch.* ($\Leftarrow$) $s_1$ is the constant $1$. ($\Rightarrow$) Lemma 6.3 with $h = s_v$. $\square$

**Corollary 6.5 (Arithmetic refuses the repair).** Total transreal arithmetic assigns $0/0 = \Phi \neq 1$. Hence $x \mapsto \mathrm{fin}\,x/\mathrm{fin}\,x$ is discontinuous, and is so for **every** T₁ topology on the carrier. Unguarded self-division therefore fails by exactly one point and exactly one value, and no re-topologisation whatsoever can repair it.

**Corollary 6.6 (Sharpness of the transfer principle).** There is a weakly guarded expression, namely $\mathrm{selfDiv} := \mathrm{atom}(\mathrm{id})/\mathrm{atom}(\mathrm{id})$, whose transreal semantics is discontinuous — for every T₁ topology on $\mathbb{T}$. Hence the nowhere-vanishing clause cannot be deleted from Definition 4.4 without destroying Theorem 4.6.

Note the strength of the statement: it is not "the natural topology is the wrong one", but "no T₁ topology exists that would make the unguarded fragment work". Sharpness is a property of the arithmetic, not of a modelling choice.

### 6.3 No value repairs the reciprocal

The rigidity theorem says the repair value for $x/x$ *exists* but is refused by the arithmetic. For the reciprocal, no repair value exists at all.

Define $r_v(y) = v$ if $y = 0$ and $\mathrm{fin}\,y^{-1}$ otherwise.

**Lemma 6.7 (Two-sided blow-up).** Suppose $r_v$ is continuous at $0$ in the natural topology, and let $V \ni v$ be open. Then for every $M > 0$ there exist $a > M$ and $b < -M$ with $\mathrm{fin}\,a \in V$ and $\mathrm{fin}\,b\in V$.

*Proof sketch.* Continuity gives an $\varepsilon$-ball around $0$ mapped into $V$. Choose $0 < y < \min(\varepsilon, (|M|+1)^{-1})$; then $y^{-1} > M$ and $\mathrm{fin}\,y^{-1}\in V$, while $-y$ lies in the same ball and $(-y)^{-1} < -M$. $\square$

**Theorem 6.8 (Non-repairability of the reciprocal).** For every $v \in \mathbb{T}$, $r_v$ is discontinuous at $0$.

*Proof sketch.* Apply Lemma 6.7 with a well-chosen neighbourhood of $v$.
* $v = \mathrm{fin}\,r$: take $V$ the image of the interval $(r-1, r+1)$; every finite element of $V$ is bounded above by $r+1$, contradicting the existence of arbitrarily large positive $a$.
* $v = +\infty$: take $V$ the image of $(0,+\infty]$; its finite elements are positive, contradicting the existence of $b < 0$.
* $v = -\infty$: symmetric, using $[-\infty,0)$.
* $v = \Phi$: take $V = \{\Phi\}$, which is open and contains no finite element at all. $\square$

**Corollary 6.9.** The transreal reciprocal itself, $y \mapsto 1/\mathrm{fin}\,y$, is the case $v = +\infty$, hence discontinuous. Adjoining two infinities and a nullity to $\mathbb{R}$ is *not* enough to make unguarded division continuous.

---

## 7. The pole trichotomy: exactly which unguarded quotients transfer

The conjecture says unguarded division "generally" fails. Section 6 shows the failure is severe; this section shows it is not universal, and computes the boundary precisely. Throughout, $f, g : \mathbb{R}\to\mathbb{R}$, $x_0 \in \mathbb{R}$, and we study $q(x) := \mathrm{fin}(f x)/\mathrm{fin}(g x)$.

### 7.1 Two limit lemmas

**Lemma 7.1.** Let $\ell$ be a filter on $\mathbb{R}$. If $f \to C > 0$ along $\ell$ and $g \to 0^{+}$ along $\ell$ (i.e. $g \to 0$ with $g > 0$ eventually), then $q \to +\infty$ along $\ell$ in $\mathbb{T}$. Symmetrically, if $g \to 0^{-}$ then $q \to -\infty$.

*Proof sketch.* Eventually $g > 0$, so eventually $q = \mathrm{fin}(f\cdot g^{-1})$; and $g^{-1} \to +\infty$, so $f g^{-1}\to+\infty$ because $f$ has positive limit. Finally $\mathrm{fin}\,t\to+\infty$ in $\mathbb{T}$ as $t \to +\infty$ (Theorem 3.1(5)). $\square$

### 7.2 Regime 1: coincident zeros

**Theorem 7.2 (The nullity jump).** Suppose $f(x_0) = g(x_0) = 0$ and $g \ne 0$ on a punctured neighbourhood of $x_0$. Then $q$ is discontinuous at $x_0$. *No regularity hypothesis on $f$ or $g$ is required.*

*Proof sketch.* $q(x_0) = 0/0 = \Phi$. If $q$ were continuous at $x_0$, then since $\{\Phi\}$ is open (Corollary 3.2), $q$ would equal $\Phi$ on a whole neighbourhood of $x_0$. But at punctured points $g \neq 0$, so $q = \mathrm{fin}(f/g)$ is finite there — contradiction. $\square$

The obstruction here is *purely topological*: it is the isolation of nullity, nothing else.

### 7.3 Regime 2: one-signed poles transfer

**Theorem 7.3 (One-signed poles are continuous).** Suppose $f$ and $g$ are continuous at $x_0$, $f(x_0) > 0$, $g(x_0) = 0$, and $g > 0$ on a punctured neighbourhood of $x_0$. Then $q$ *is* continuous at $x_0$, with $q(x_0) = +\infty$.

*Proof sketch.* The value is $\mathrm{fin}(f x_0)/0 = +\infty$ by Theorem 2.8, since $f(x_0)>0$. For the limit, apply Lemma 7.1 along the punctured neighbourhood filter: $f \to f(x_0) > 0$ and $g \to 0$ with $g>0$ eventually, so $q \to +\infty$, which equals $q(x_0)$. $\square$

**Corollary 7.4.** $x \mapsto \mathrm{fin}\,1 / \mathrm{fin}(x^2)$ is a *continuous* map $\mathbb{R}\to\mathbb{T}$, taking the value $+\infty$ at the origin.

*Proof sketch.* At $x \neq 0$ the map agrees with $\mathrm{fin}(1/x^2)$ on a neighbourhood, which is continuous. At $0$, apply Theorem 7.3 with $f \equiv 1$ and $g(x) = x^2 > 0$ off the origin. $\square$

Corollary 7.4 is exactly why the conjecture must say *generally*. The four-constructor carrier genuinely absorbs even-order poles: unguarded division is not uniformly bad.

**Remark 7.4a (the convention $1/0 = +\infty$ breaks the sign symmetry).** The positivity of $g$ in Theorem 7.3 is not cosmetic. The reciprocal is total by the convention $\mathrm{recip}(0) = +\infty$, so the value that the arithmetic assigns at $x_0$ is $\mathrm{fin}(f x_0)/0$, which depends on the sign of the *numerator only*: the arithmetic cannot see from which side the denominator vanished. If instead $g < 0$ on a punctured neighbourhood — say $q(x) = 1/(-x^2)$ — then both one-sided limits are $-\infty$ by Lemma 7.1, while the assigned value is $+\infty$. The quotient is therefore discontinuous, even though the pole is perfectly one-signed. Continuity in regime 2 therefore requires the denominator to approach zero *from above*.

This has a sharp corollary about presentation. The expressions $1/(-x^2)$ and $(-1)/x^2$ define the *same* real function off the origin, but their total evaluations at the origin are $+\infty$ and $-\infty$ respectively, and only the second is continuous. So outside the guard the transreal semantics is a function of the *syntax*, not of the real function it computes; the guard is exactly the condition under which that dependence disappears (Theorem 4.5), and faithfulness (Theorem 4.7) is a guarded statement for precisely this reason.

### 7.4 Regime 3: sign-changing poles break

**Theorem 7.5 (Sign change destroys continuity).** Suppose $f, g$ are continuous at $x_0$, $f(x_0) > 0$, $g(x_0) = 0$, $g > 0$ on a right-punctured neighbourhood, and $g < 0$ on a left-punctured one. Then $q$ is discontinuous at $x_0$.

*Proof sketch.* By Lemma 7.1 the right-hand limit is $+\infty$ and the left-hand limit is $-\infty$. Continuity at $x_0$ would force both to equal $q(x_0)$; but $\mathbb{T}$ is Hausdorff and $+\infty\ne-\infty$. $\square$

**Corollary 7.6.** $x \mapsto \mathrm{fin}\,1/\mathrm{fin}\,x$ is discontinuous at $0$ — the archetypal singularity, recovered as regime 3.

### 7.5 Summary of the boundary

| Local data at an isolated zero $x_0$ of $g$ | Transreal value at $x_0$ | Continuous? |
|---|---|---|
| $f(x_0) = 0 = g(x_0)$ | $\Phi$ | **No** (no hypotheses needed) |
| $f(x_0) \ne 0$, $g > 0$ near $x_0$ | $\pm\infty$ (sign of $f$) | **Yes** |
| $f(x_0) \ne 0$, $g < 0$ near $x_0$ | $\pm\infty$ (sign of $f$) | **No** (limits have the opposite sign) |
| $f(x_0) \ne 0$, $g$ changes sign at $x_0$ | $\pm\infty$ | **No** |
| $g(x_0)\ne 0$ | finite | **Yes** (guarded case) |

So: the nowhere-vanishing guard is *sufficient* (Theorem 4.6) and cannot be deleted (Corollary 6.6), but it is not *necessary*; the necessary and sufficient local condition at an isolated denominator zero is the second row.

---

## 8. The price of totality

The carrier is compact and Hausdorff, and the arithmetic is total. Something must give, and what gives is joint continuity.

**Theorem 8.1 ($\infty - \infty$).** Total addition $\mathbb{T}\times\mathbb{T}\to\mathbb{T}$ is not continuous at $(+\infty, -\infty)$.

*Proof sketch.* Along $t \mapsto (\mathrm{fin}\,t, \mathrm{fin}(-t))$ as $t \to +\infty$, the arguments converge to $(+\infty,-\infty)$ by Theorem 3.1(5), while the sums are constantly $\mathrm{fin}\,0$. Continuity would force $\mathrm{fin}\,0 = (+\infty)+(-\infty) = \Phi$, false. $\square$

**Theorem 8.2 ($0\cdot\infty$).** Total multiplication is not continuous at $(\mathrm{fin}\,0, +\infty)$.

*Proof sketch.* Along $t\mapsto(\mathrm{fin}\,t^{-1}, \mathrm{fin}\,t)$ as $t\to+\infty$, the arguments converge to $(\mathrm{fin}\,0, +\infty)$ while the products are eventually constantly $1$. Continuity would force $1 = 0\cdot(+\infty) = \Phi$, false. $\square$

**Theorem 8.3 (Distributivity fails).** It is not the case that $a(b+c) = ab + ac$ for all $a,b,c\in\mathbb{T}$: take $a = +\infty$, $b = 1$, $c = 0$. Then $a(b+c) = (+\infty)\cdot 1 = +\infty$, while $ab + ac = (+\infty) + \Phi = \Phi$.

**Remark 8.4.** All three failures are confined to the exceptional constructors. On the finite fragment — which is where the transfer principle lives — the field axioms of $\mathbb{R}$ hold verbatim, and both operations are jointly continuous. The exceptional elements are precisely the price of totality, and the guard is precisely the condition that avoids paying it.

---

## 9. Algorithms

The theory yields two decision procedures of practical interest, both linear in the size of the expression.

### 9.1 Guard checking

Given a syntax tree $e$ and, for each division node, an oracle or certificate establishing that its denominator is nowhere zero, one decides guardedness by a single post-order traversal, conjoining the continuity obligations of atoms and composed functions with the nonvanishing obligations of denominators. Complexity $O(n)$ in the number of nodes, plus the cost of the nonvanishing certificates. In practice the certificates are simple positivity facts ("$1 + e^x \geq 1$", "$1 + x^2 \geq 1$", "$\|v\|^2 > 0$ since $v \ne 0$").

### 9.2 Transreal evaluation with regime classification

Given a guarded or unguarded expression and a point, one evaluates bottom-up in the four-constructor arithmetic, propagating one of four tags (finite / $+\infty$ / $-\infty$ / $\Phi$). At each division node whose denominator evaluates to zero, one classifies the local regime by sampling the denominator's sign on both sides of the point:

* numerator zero as well $\Rightarrow$ regime 1 ($\Phi$; discontinuous);
* denominator of constant *positive* sign $\Rightarrow$ regime 2 ($\pm\infty$; continuous);
* denominator of constant *negative* sign $\Rightarrow$ regime 2$'$ ($\pm\infty$, but with the wrong sign; discontinuous);
* denominator sign-changing $\Rightarrow$ regime 3 ($\pm\infty$; discontinuous).

This gives, for a syntax tree of $n$ nodes, an $O(n)$ evaluation together with a certified continuity verdict at the point, subject to the correctness of the sign sampling. Combined with Theorems 7.2, 7.3 and 7.5, the verdict is exact whenever the sampled signs are the true one-sided signs.

---

## 10. Applications

### 10.1 Exception-free arithmetic in cryptographic implementations

In elliptic-curve cryptography a point is stored projectively as $(X : Y : Z)$, with the affine coordinates recovered as $x = X/Z$, $y = Y/Z$. The identity element of the group — the point at infinity — is exactly the locus $Z = 0$, where these divisions are unguarded. An implementation that divides must therefore branch on $Z = 0$; and a branch whose condition depends on secret data is a timing side channel. The engineering response has been "complete" addition formulas that avoid the exceptional case entirely, at a cost in field operations.

Total arithmetic offers an alternative response: never branch, and let the exceptional constructor record the exceptional case. Our results delimit exactly what that buys.

* **Inside the guard** (the scalar-multiplication ladder arranged so that $Z \neq 0$ throughout), Theorems 4.5–4.7 say the totalisation is *invisible*: identical values, identical equational theory, and continuity preserved. Reasoning may proceed classically and the implementation may be branch-free with no semantic risk.
* **At the boundary**, Corollaries 6.5 and 6.9 say the exceptional value is a genuine discontinuity that no re-topologisation and no repair value can smooth away. A totalised implementation is therefore *correct* but not *stable* at $Z = 0$: in a fixed-precision setting, a value near the boundary can flip between an infinity and a nullity on the basis of rounding noise, so an unguarded totalised routine must not be relied upon for a continuity-based argument (a smoothness assumption, a Lipschitz bound, an interpolation).
* **Regime 2** (Theorem 7.3) tells the implementer which unguarded situations are benign: a quotient whose denominator has an even-order zero at which it stays *positive*, and whose numerator does not vanish there, degrades gracefully to a signed infinity. A denominator with an odd-order zero, a negative even-order zero (Remark 7.4a), or a coincident zero of numerator and denominator, does not.

### 10.2 Machine learning and numerical software

Activation functions, normalisation layers and softmax denominators are guarded by construction ($1 + e^x$, $\sum_i e^{z_i}$, $\varepsilon + \sigma^2$). Theorem 4.6 certifies that implementing these in a total arithmetic — including `NaN`-carrying floating point — cannot change values or break continuity as long as the guard holds. Conversely, Theorem 7.2 identifies the dangerous pattern: a *ratio of two quantities that vanish together*, such as an unregularised $0/0$ in an attention mask or an empty-bucket average, is exactly the regime whose failure needs no regularity hypotheses at all.

### 10.3 A conceptual dividend

The guard has three faces — the unit group of the multiplication (Theorem 5.1), the continuity locus of the division map (Theorems 6.1 and 6.2), and the syntactic side condition of the transfer principle (Definition 4.4) — and they coincide. When a hypothesis admits several independent characterisations, it is generally the right hypothesis.

---

## 11. Discussion and future directions

### 11.1 What has been settled

The informal conjecture is now a theorem, in a strong form: guarded transfer holds (Theorem 4.6), is exact in both directions (Theorem 4.7), is functorial (Theorem 4.9), and its guard is sharp for every T₁ topology (Corollary 6.6) — while the guard itself is the unit group (Theorem 5.1) and the exact continuity locus (Theorems 6.1–6.2). The hedge "generally" in the failure clause is justified and quantified by the pole trichotomy (Theorems 7.2, 7.3, 7.5).

### 11.2 Open directions

**1. Uniqueness of the natural topology.** *Conjecture.* Let $t$ be a compact Hausdorff topology on the four-constructor carrier for which $\mathrm{fin} : \mathbb{R}\to\mathbb{T}$ is an open embedding and $\{\Phi\}$ is open. Then $t$ is the natural topology, i.e. the identity is a homeomorphism onto $\overline{\mathbb{R}}\sqcup\{\ast\}$.

The key insight is that a compact Hausdorff space containing $\mathbb{R}$ as an open subset with a two-point remainder must be the end compactification, because the line has exactly two ends and each remainder point must absorb one of them. The present development *chose* a topology and proved the guard sharp for it (and, in the self-division case, for every T₁ topology); uniqueness would upgrade "a natural topology" to "*the* natural topology" and make the sharpness theorems canonical rather than model-dependent.

**2. Complete characterisation of guardedness up to semantics.** *Conjecture.* For every expression all of whose atoms and compositions are continuous, the transreal evaluation is continuous **iff** at every zero $x_0$ of every denominator subexpression the local data fall in regime 2 of the pole trichotomy (numerator nonzero at $x_0$, denominator positive on a punctured neighbourhood).

The key insight is that the pole trichotomy is local and the syntax is finite, so continuity should be decidable by a finite conjunction of local regime tests. Establishing this would replace the *sufficient* syntactic guard with a *complete* semantic criterion, closing the gap between Theorem 4.6 and the trichotomy of Section 7. The technical obstacle is nesting: a denominator may itself take exceptional values, so the trichotomy must be relativised to quotients whose subexpressions are only partially finite.

**3. Higher dimensions and complex poles.** The two-point compactification is special to the line: $\mathbb{R}^n$ for $n \geq 2$ has one end, and $\mathbb{C}$ compactifies to a sphere with a single $\infty$. The analogue of the trichotomy over $\mathbb{C}$ should read: $0/0$ breaks; every isolated pole *transfers*, since the Riemann sphere has no sign to change. If so, the sign-changing regime is a purely one-dimensional, purely ordered phenomenon — a satisfying explanation of why real analysis finds $1/x$ harder than complex analysis does.

**4. Quantitative stability.** Continuity is qualitative. Near a regime-2 pole, how does a fixed-precision implementation behave, and can one give an explicit modulus of continuity for the transreal quotient in a metric inducing the natural topology (for instance, the arctangent metric on $\overline{\mathbb{R}}$ with $\Phi$ at distance $1$ from everything)? A metric answer would turn the qualitative guard into a numerical error bound.

**5. Beyond arithmetic.** Only $+$, $\cdot$, $-$, $/$ are extended by hand; other real functions are lifted strictly, sending every exceptional argument to $\Phi$. One could instead lift a function $f$ by its limits at $\pm\infty$ where these exist (e.g. $\exp(-\infty) = 0$, $\arctan(+\infty) = \pi/2$). This *continuous lift* would enlarge the guarded fragment; characterising exactly which functions admit one, and whether transfer remains exactly conservative, is open.

---

## 12. Conclusion

Total arithmetic is not a swindle, but neither is it free. On the guarded fragment — finite values, and division only by nowhere-vanishing denominators — totalisation is completely invisible: the same values, the same equational theory in both directions, and continuity into a compact Hausdorff carrier. That is a genuine transfer principle and a genuine licence for exception-free implementation.

The guard that makes it work is not an artefact. It is the unit group of the multiplication, and it is the exact continuity locus of the division map, and it cannot be weakened: unguarded self-division is discontinuous for *every* T₁ topology on the carrier, and unguarded reciprocation cannot be repaired by *any* value in the carrier. What lies past the guard is not chaos but a trichotomy: coincident zeros always break, sign-changing poles always break, and positive one-signed poles — remarkably — do not break at all, so that $1/x^2$ extends to a continuous map of the whole line into the four-constructor space.

Dividing by zero, then, is permitted. It merely costs continuity, at three named points — $0/0$, $\infty-\infty$, $0\cdot\infty$ — and nowhere else.
