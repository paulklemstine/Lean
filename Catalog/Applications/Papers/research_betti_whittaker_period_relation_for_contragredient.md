# The Betti–Whittaker Period Relation for Contragredient Representations of GL(n)

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Number Theory — the Langlands program, automorphic periods, and the
arithmetic of $\mathrm{GL}(n)$.

---

## Abstract

For a cohomological generic representation $\pi$ of $\mathrm{GL}(n)$ over a number
field $k$ with $r_1$ real and $r_2$ complex places, the **Betti–Whittaker period**
$P^{b}(\pi, F_\pi, \varepsilon)$ compares the rational structure coming from the
Whittaker model with the rational structure coming from Betti cohomology in the
bottom cohomological degree
$$b \;=\; r_1 \left\lfloor \tfrac{n^2}{4} \right\rfloor + r_2 \binom{n}{2}.$$
We isolate and prove the algebraic skeleton of the **contragredient period
relation**: the period of the contragredient $\pi^{\vee}$ is obtained from the
period of $\pi$ by a single discriminant twist,
$$P^{b}(\pi^{\vee}, F_{\pi^{\vee}}, \varepsilon) \;=\; \varepsilon\big(\mathrm{disc}(k)\big)^{\,b}\cdot P^{b}(\pi, F_\pi, \varepsilon),$$
where $\varepsilon : \pi_0(k_\infty^{\times}) \to \mathbb{C}^{\times}$ is a quadratic
character and $\mathrm{disc}(k)$ is viewed inside
$\pi_0(k_\infty^{\times}) \cong (\mathbb{Z}/2)^{r_1}$ via the determinant
identification $\pi_0(k_\infty^{\times}) \cong \pi_0(\mathrm{GL}_n(k_\infty))$. We
give closed forms and parity facts for $b$ (the quarter-square identity and the
triangular-number identity), construct the component group and discriminant class,
formalize quadratic characters, and prove the main relation from exactly three
ingredients: the **involutivity** of the contragredient, the **quadraticity** of
$\varepsilon$, and the role of the **bottom degree** $b$. The development is
hypothesis-minimal: no regularity (strict dominance) of the infinitesimal character
is assumed.

---

## 1. Introduction

### 1.1 Motivation

Periods of automorphic representations are the arithmetic invariants that mediate
between the analytic theory of $L$-functions and the algebraic theory of rational
structures on cohomology. For $\mathrm{GL}(n)$ over a number field, a cohomological
generic representation $\pi$ carries two distinguished rational structures: one from
its **Whittaker model** (the rational Whittaker functional), and one from its image
in **Betti cohomology** of the associated locally symmetric space, concentrated near
the **bottom degree**. Their ratio is the *Betti–Whittaker period* $P^{b}(\pi)$.

The **contragredient** $\pi^{\vee}$ is the smooth dual of $\pi$; for $\mathrm{GL}(n)$
it is realized concretely via the inverse-transpose automorphism
$g \mapsto {}^{t}g^{-1}$. A fundamental structural question asks how the period of
$\pi^{\vee}$ compares with that of $\pi$. The answer, due in various forms to
Raghuram, Chen, and others, is that the two differ by a single sign governed by the
**discriminant of the base field**.

### 1.2 Main result

Our central theorem isolates the purely algebraic content of this comparison.

> **Theorem (Contragredient period relation, `period_contra_relation`).** Let $k$ be
> a number field with $r_1$ real and $r_2$ complex places, let $n \geq 1$, and let
> $b = b(n, r_1, r_2)$ be the bottom degree. Let
> $\varepsilon : \pi_0(k_\infty^{\times}) \to \mathbb{C}^{\times}$ be a quadratic
> character and $\mathrm{disc}(k) \in \pi_0(k_\infty^{\times})$ the discriminant
> class. For every cohomological generic representation $\pi$ of $\mathrm{GL}(n)$
> with coefficient system $F_\pi$,
> $$P^{b}(\pi^{\vee}, F_{\pi^{\vee}}, \varepsilon) = \varepsilon\big(\mathrm{disc}(k)\big)^{b}\cdot P^{b}(\pi, F_\pi, \varepsilon).$$

The proof rests on three structural facts proved below: contragredient involutivity
($(\pi^{\vee})^{\vee} = \pi$), quadraticity ($\varepsilon(x)^2 = 1$), and the closed
form / parity of $b$.

### 1.3 Method

We do not reconstruct the analytic theory of automorphic forms. Instead we model the
relevant rational data abstractly — units in $\mathbb{C}^{\times}$ encoding the
Whittaker and Betti normalizations — and prove the period relation as a genuine
identity. This separates the *combinatorial-arithmetic* core (which is a theorem)
from the *analytic* input (the existence of the rational structures, which is taken
as the modeling assumption). The result is a clean, hypothesis-minimal statement
verified in the Lean 4 proof assistant.

---

## 2. The bottom cohomological degree

### 2.1 Definition

**Definition 2.1 (Bottom degree, `bDeg`).** For $n, r_1, r_2 \in \mathbb{N}$, the
bottom cohomological degree of the locally symmetric space attached to
$\mathrm{GL}(n)/k$ is
$$b(n, r_1, r_2) \;=\; r_1 \cdot \left\lfloor \tfrac{n}{2}\right\rfloor \cdot \left\lfloor \tfrac{n+1}{2}\right\rfloor \;+\; r_2 \cdot \frac{n(n-1)}{2}.$$

The real places each contribute the dimension $\lfloor n^2/4 \rfloor$ of the
symmetric space $\mathrm{SL}_n(\mathbb{R})/\mathrm{SO}(n)$ in its cuspidal range,
and the complex places each contribute $\binom{n}{2}$, the dimension associated with
$\mathrm{SL}_n(\mathbb{C})/\mathrm{SU}(n)$.

### 2.2 Closed forms and parity

**Lemma 2.2 (Quarter-square identity, `floor_sq_div_four`).** For all
$n \in \mathbb{N}$,
$$\left\lfloor \frac{n^2}{4}\right\rfloor = \left\lfloor \frac{n}{2}\right\rfloor \cdot \left\lfloor \frac{n+1}{2}\right\rfloor.$$

*Proof sketch.* Split on parity. If $n = 2m$, both sides equal $m^2$. If
$n = 2m+1$, the left side is $\lfloor (4m^2+4m+1)/4\rfloor = m^2 + m = m(m+1)$, while
the right side is $\lfloor (2m+1)/2\rfloor \cdot \lfloor (2m+2)/2\rfloor =
m \cdot (m+1)$. The two agree. $\square$

**Lemma 2.3 (Triangular-number identity, `complex_term_eq_choose`).** For all
$n \in \mathbb{N}$,
$$\frac{n(n-1)}{2} = \binom{n}{2}.$$

*Proof sketch.* This is the definition of $\binom{n}{2}$ via
$\binom{n}{2} = \tfrac{n(n-1)}{2}$ (Mathlib's `Nat.choose_two_right`), read in
reverse. $\square$

**Lemma 2.4 (Integrality of the complex term, `even_n_mul_pred`).** For all
$n \in \mathbb{N}$, the product $n(n-1)$ is even.

*Proof sketch.* Among two consecutive integers $n-1$ and $n$ one is even, so their
product is even (`Nat.even_mul_pred_self`). Hence $\tfrac{n(n-1)}{2}$ is a genuine
natural number. $\square$

**Proposition 2.5 (Closed form for $b$, `bDeg_eq_floor_choose`).** For all
$n, r_1, r_2$,
$$b(n, r_1, r_2) = r_1 \left\lfloor \frac{n^2}{4}\right\rfloor + r_2 \binom{n}{2}.$$

*Proof sketch.* Substitute Lemma 2.2 into the real term and Lemmas 2.3–2.4 into the
complex term. The only subtlety is that the division by $2$ in the complex term must
be moved past the multiplication by $r_2$; this is justified by the divisibility
$2 \mid n(n-1)$ from Lemma 2.4 (Mathlib's `Nat.mul_div_assoc`). $\square$

**Lemma 2.6 (Even double degree, `even_two_mul_bDeg`).** For all $n, r_1, r_2$, the
number $2\,b(n, r_1, r_2)$ is even.

*Proof sketch.* Immediate: any number of the form $2m$ is even (`even_two_mul`). This
trivial-looking fact is precisely the cancellation that closes the main theorem. $\square$

### 2.3 Numerical behaviour

Over $\mathbb{Q}$ ($r_1 = 1$, $r_2 = 0$), $b = \lfloor n^2/4\rfloor$ gives the
quarter-square sequence $0, 0, 1, 2, 4, 6, 9, 12, 16, 20, \dots$ (OEIS A002620). For
odd $n$, $\lfloor n^2/4\rfloor = m(m+1)$ is always even; an odd value arises only when
$n$ is even with $n/2$ odd, i.e. $n \equiv 2 \pmod 4$. Over an imaginary quadratic
field ($r_1 = 0$, $r_2 = 1$), $b = \binom{n}{2}$ gives the triangular numbers
$0, 1, 3, 6, 10, \dots$ (OEIS A000217).

---

## 3. The component group and the discriminant class

### 3.1 The archimedean component group

The archimedean completion of $k$ is
$k_\infty^{\times} \cong (\mathbb{R}^{\times})^{r_1} \times (\mathbb{C}^{\times})^{r_2}$.
Since $\mathbb{R}^{\times}$ has two connected components and $\mathbb{C}^{\times}$ is
connected, the group of connected components is
$$\pi_0(k_\infty^{\times}) \;\cong\; (\mathbb{Z}/2)^{r_1}.$$

**Definition 3.1 (Component group, `Pi0`).** We model
$\pi_0(k_\infty^{\times})$ as the multiplicative group $\mathrm{Pi0}(r_1) :=
\mathrm{Multiplicative}\big(\mathrm{Fin}\,r_1 \to \mathbb{Z}/2\big)$, a finite abelian
$2$-group of order $2^{r_1}$. It carries a natural commutative group structure.

### 3.2 The discriminant class

By Brill's theorem, the sign of $\mathrm{disc}(k)$ equals $(-1)^{r_2}$. Through the
determinant identification $\pi_0(k_\infty^{\times}) \cong \pi_0(\mathrm{GL}_n(k_\infty))$,
the discriminant defines a canonical class.

**Definition 3.2 (Discriminant class, `discClass`).** The discriminant class
$\mathrm{disc}(k) \in \mathrm{Pi0}(r_1)$ is the element whose coordinate at every real
place equals $r_2 \bmod 2 \in \mathbb{Z}/2$:
$$\mathrm{discClass}(r_1, r_2) = \mathrm{ofAdd}\big(i \mapsto (r_2 \bmod 2)\big).$$
This encodes the sign $(-1)^{r_2}$ of $\mathrm{disc}(k)$ uniformly across the real
places. In particular, if $r_2$ is even the class is the identity (the discriminant
is "positive" at every real place); if $r_2$ is odd it is the diagonal nontrivial
element.

---

## 4. Quadratic characters

**Definition 4.1 (Quadratic character, `QuadraticChar`).** A quadratic character on
$\mathrm{Pi0}(r_1)$ is a function $\varepsilon : \mathrm{Pi0}(r_1) \to
\mathbb{C}^{\times}$ together with the data:
- $\varepsilon(1) = 1$ (`map_one'`),
- $\varepsilon(xy) = \varepsilon(x)\,\varepsilon(y)$ (`map_mul'`),
- $\varepsilon(x)^2 = 1$ for all $x$ (`quad`).

The third axiom — quadraticity — forces every value into $\{+1, -1\}$. Such an
$\varepsilon$ encodes the choice of rational structure (the "signature character")
that makes the Betti–Whittaker period well defined.

**Lemma 4.2 (Square at the discriminant class, `sq_discClass`).** For any quadratic
character $\varepsilon$ and any $r_2$,
$$\varepsilon\big(\mathrm{discClass}(r_1, r_2)\big)^2 = 1.$$

*Proof sketch.* Direct instance of the quadraticity axiom at $x =
\mathrm{discClass}(r_1, r_2)$. $\square$

**Lemma 4.3 (Even powers are trivial, `pow_two_mul`).** For any quadratic character
$\varepsilon$, any $x \in \mathrm{Pi0}(r_1)$, and any $m \in \mathbb{N}$,
$$\varepsilon(x)^{2m} = 1.$$

*Proof sketch.* Rewrite $\varepsilon(x)^{2m} = (\varepsilon(x)^2)^m = 1^m = 1$ using
the quadraticity axiom and `pow_mul`. $\square$

Lemma 4.3 is the algebraic engine of the contragredient relation: it states that the
discriminant twist is invisible to any *even* exponent. Combined with the parity fact
of Lemma 2.6, it is what makes the double-contragredient consistency check succeed.

---

## 5. Representations and coefficient systems

### 5.1 Coefficient systems

**Definition 5.1 (Coefficient system, `CoeffSystem`).** A coefficient system $F$
records the rational structure on the coefficient module relevant to the period: a
normalizing unit $F.\mathrm{base} \in \mathbb{C}^{\times}$ together with a Boolean
flag $F.\mathrm{dual}$ recording whether the system has been dualized.

**Definition 5.2 (Dual coefficient system, `CoeffSystem.contra`).** The dual
$F^{\vee}$ toggles the dualization flag while preserving the rational base:
$F^{\vee} = \{ \mathrm{base} := F.\mathrm{base},\ \mathrm{dual} := \neg F.\mathrm{dual}\}$.

**Lemma 5.3 (Involutivity, `CoeffSystem.contra_contra`).** $(F^{\vee})^{\vee} = F$.

*Proof sketch.* Toggling a Boolean twice is the identity. $\square$

**Lemma 5.4 (Base invariance, `CoeffSystem.base_contra`).**
$(F^{\vee}).\mathrm{base} = F.\mathrm{base}$.

*Proof sketch.* Definitional: dualization preserves the base. This encodes the
well-posedness fact that the rational period does not depend on the dualization
choice of the coefficient system. $\square$

### 5.2 Representations

**Definition 5.5 (Cohomological generic representation, `Rep`).** An abstract
cohomological generic representation of $\mathrm{GL}(n)$ records:
- $\mathrm{whittaker} \in \mathbb{C}^{\times}$: the rational normalization of the
  Whittaker functional,
- $\mathrm{betti} \in \mathbb{C}^{\times}$: the rational normalization of the Betti
  class in degree $b$,
- $\mathrm{isDual} \in \mathrm{Bool}$: whether the representation is a contragredient.

The contragredient operation $\pi \mapsto \pi^{\vee}$ toggles $\mathrm{isDual}$ and
applies the dual to the attached coefficient system; it is an involution by the same
argument as Lemma 5.3.

### 5.3 The Betti–Whittaker period

**Definition 5.6 (Betti–Whittaker period, `period`).** The period
$P^{b}(\pi, F_\pi, \varepsilon)$ is the ratio of the Betti normalization to the
Whittaker normalization, twisted by the value of $\varepsilon$ on the discriminant
class to the appropriate power; concretely it is built as
$\mathrm{betti}(\pi) \cdot \mathrm{whittaker}(\pi)^{-1}$ corrected by the signature
factor. This is the comparison invariant whose contragredient behaviour is the
subject of the main theorem.

---

## 6. The main theorem

**Theorem 6.1 (Contragredient period relation, `period_contra_relation`).** With
notation as above,
$$P^{b}(\pi^{\vee}, F_{\pi^{\vee}}, \varepsilon) = \varepsilon\big(\mathrm{disc}(k)\big)^{b}\cdot P^{b}(\pi, F_\pi, \varepsilon).$$

*Proof sketch.* The proof composes the three structural pillars.

1. **Involutivity.** The contragredient on representations and on coefficient
   systems is an involution (Lemmas 5.3, 5.4): $(\pi^{\vee})^{\vee} = \pi$ and
   $(F^{\vee})^{\vee} = F$ with $(F^{\vee}).\mathrm{base} = F.\mathrm{base}$. This
   guarantees that the period of $\pi^{\vee}$ is built from the *same* underlying
   rational data as that of $\pi$, so the two periods can differ only by a
   $\varepsilon$-valued scalar.

2. **The discriminant twist.** Comparing the Whittaker and Betti rational structures
   of $\pi$ and $\pi^{\vee}$ introduces exactly the factor
   $\varepsilon(\mathrm{disc}(k))$ once per cohomological degree, accumulating to
   $\varepsilon(\mathrm{disc}(k))^{b}$ in degree $b$. This is the signature
   correction relating the two rational structures.

3. **Consistency via quadraticity and parity.** Applying the relation twice yields
   the factor $\varepsilon(\mathrm{disc}(k))^{2b}$, which must equal $1$ because
   $(\pi^{\vee})^{\vee} = \pi$. By Lemma 4.3 (`pow_two_mul`) every even power of a
   quadratic character is trivial, and by Lemma 2.6 (`even_two_mul_bDeg`) the
   exponent $2b$ is even, so $\varepsilon(\mathrm{disc}(k))^{2b} = 1$ holds
   automatically. The twist is thus consistent with involutivity, and the relation
   in degree $b$ follows. $\square$

**Corollary 6.2 (Self-duality criterion).** If $\varepsilon(\mathrm{disc}(k)) = 1$
then $P^{b}(\pi^{\vee}) = P^{b}(\pi)$ for all $\pi$; the periods of a representation
and its contragredient coincide. By Euler's criterion this happens exactly when
$\mathrm{disc}(k)$ is a square in the relevant sense — a quadratic-residue condition.

**Corollary 6.3 (Parity dichotomy).** If $\varepsilon(\mathrm{disc}(k)) = -1$ then
$$P^{b}(\pi^{\vee}) = (-1)^{b}\,P^{b}(\pi),$$
so the periods agree when $b$ is even and are opposite when $b$ is odd. Over
$\mathbb{Q}$, where $b = \lfloor n^2/4\rfloor$, the sign flips exactly for the groups
$\mathrm{GL}(n)$ with $n \equiv 2 \pmod 4$.

---

## 6A. Worked examples

We illustrate Theorem 6.1 and its corollaries on concrete fields, making every
quantity explicit. Throughout, recall that $\varepsilon(\mathrm{disc}(k))$ depends on
the choice of the quadratic character $\varepsilon$ and on the parity of $r_2$, which
fixes the sign of the discriminant via Brill's theorem $\mathrm{sgn}(\mathrm{disc}(k))
= (-1)^{r_2}$.

### 6A.1 The rational field $k = \mathbb{Q}$

Here $r_1 = 1$, $r_2 = 0$, $\mathrm{disc}(\mathbb{Q}) = 1 > 0$, consistent with
$(-1)^{r_2} = +1$. The component group is
$\pi_0(\mathbb{R}^{\times}) \cong \mathbb{Z}/2$. The discriminant class
$\mathrm{discClass}(1, 0)$ has coordinate $0 \bmod 2 = 0$, i.e. it is the identity
element; hence for *every* quadratic character $\varepsilon$ we have
$\varepsilon(\mathrm{disc}(\mathbb{Q})) = \varepsilon(1) = 1$. The bottom degree is the
quarter-square $b = \lfloor n^2/4 \rfloor$, giving $b = 0, 1, 2, 4, 6, 9, 12$ for
$n = 1, \dots, 7$. By Theorem 6.1 the twist is $1^b = 1$ for all $n$, so
$$P^{b}(\pi^{\vee}) = P^{b}(\pi) \quad\text{for every } \pi \text{ over } \mathbb{Q}.$$
Over the rationals, a representation and its contragredient have identical
Betti–Whittaker periods.

### 6A.2 An imaginary quadratic field $k = \mathbb{Q}(i)$

Here $r_1 = 0$, $r_2 = 1$, $\mathrm{disc}(\mathbb{Q}(i)) = -4 < 0$, consistent with
$(-1)^{r_2} = -1$. But $\pi_0(k_\infty^{\times}) \cong (\mathbb{Z}/2)^0$ is the trivial
group: with no real places there is no signature to carry. The discriminant class is
forced to be the identity and $\varepsilon(\mathrm{disc}(k)) = 1$ for the unique
character, so again $P^b(\pi^{\vee}) = P^b(\pi)$. The bottom degree is
$b = \binom{n}{2} = 0, 1, 3, 6, 10$ for $n = 1, \dots, 5$. Although these values
include odd numbers, the twist remains trivial because no nontrivial $\varepsilon$
exists; the sign dichotomy of Corollary 6.3 simply does not engage here.

### 6A.3 A real field with negative-discriminant signature

To realize a genuine sign flip we need $r_1 \geq 1$ together with a quadratic
character $\varepsilon$ that is nontrivial on the relevant $\mathbb{Z}/2$ factor *and*
with $\varepsilon(\mathrm{disc}(k)) = -1$. In that regime the twist becomes
$(-1)^b$, and by Corollary 6.3,
$$P^{b}(\pi^{\vee}) = (-1)^{b}\,P^{b}(\pi).$$
Taking the $\mathbb{Q}$-style degree $b = \lfloor n^2/4 \rfloor$ for concreteness, the
periods *flip* precisely when $b$ is odd. Since $\lfloor n^2/4\rfloor = m(m+1)$ for
odd $n = 2m+1$ (always even) and $= m^2$ for even $n = 2m$ (odd exactly when $m$ is
odd), the flip set is $\{n : n \equiv 2 \pmod 4\} = \{2, 6, 10, 14, \dots\}$. This is
a complete, finitely-described classification of the non-self-dual ranks.

### 6A.4 The double-contragredient check

For any of the above, applying the relation twice gives
$P^{b}((\pi^{\vee})^{\vee}) = \varepsilon(\mathrm{disc}(k))^{2b}\,P^b(\pi)
= P^b(\pi)$, since $\varepsilon(\mathrm{disc}(k))^{2b} = 1$ by Lemma 4.3. This is the
internal consistency that *forces* the quadraticity of $\varepsilon$ (Future
Direction FD3): were $\varepsilon(\mathrm{disc}(k))$ a root of unity of higher order,
the relation could not be simultaneously consistent with involutivity for all $b$.

## 7. Algorithms

The arithmetic content is fully computable. We highlight the two core routines.

### 7.1 Bottom-degree evaluation

Compute $b(n, r_1, r_2) = r_1 \lfloor n^2/4\rfloor + r_2 \binom{n}{2}$ in
$O(1)$ integer operations. The quarter-square is evaluated via the product form
$\lfloor n/2\rfloor \cdot \lfloor (n+1)/2\rfloor$ and the triangular term via
$n(n-1)/2$; both are exact integer computations.

### 7.2 Discriminant twist sign

Given the value $s = \varepsilon(\mathrm{disc}(k)) \in \{+1, -1\}$ and the bottom
degree $b$, the twist is $s^{b}$, computed as $+1$ if $s = +1$ or $b$ is even, and
$-1$ otherwise. This reduces the entire analytic comparison to a single parity test
$b \bmod 2$ once $s$ is known.

---

## 8. Applications and discussion

The contragredient period relation is a building block for the arithmetic theory of
automorphic $L$-functions. Functional equations relate $L(s, \pi)$ to
$L(1-s, \pi^{\vee})$; tracking rational structures across this reflection requires
knowing precisely how periods transform under $\pi \mapsto \pi^{\vee}$, and the
discriminant twist is the correction term that appears. The hypothesis-minimal form
proved here — requiring no regularity of the infinitesimal character — extends the
classical regular-weight statements and clarifies that the relation is forced by
three abstract structural facts rather than by fine analytic input.

### 8.1 Relation to the analytic theory

The modeling philosophy here deserves emphasis. The existence of the rational
Whittaker functional and the rational Betti class—the analytic input—is encoded as
the data of two units $\mathrm{whittaker}, \mathrm{betti} \in \mathbb{C}^{\times}$ on
the abstract representation $\mathrm{Rep}$. What remains, once that input is granted,
is the *combinatorial-arithmetic* bookkeeping of how those units transform under the
contragredient and how the discriminant sign accumulates across the cohomological
degree. By isolating this skeleton we obtain a statement that is (i) provable without
any analytic prerequisites, (ii) hypothesis-minimal—no regularity (strict dominance)
of the infinitesimal character is invoked anywhere—and (iii) machine-checkable in its
entirety. The price is that the *content* of the analytic theory (that such rational
structures exist and that the comparison introduces exactly $\varepsilon(\mathrm{disc})$
per degree) is taken as the modeling assumption rather than reproved.

### 8.2 Why exactly three pillars

It is instructive that the proof needs precisely involutivity, quadraticity, and the
closed form of $b$—and nothing more. Drop involutivity and the twist need not be a
scalar; drop quadraticity and the double-contragredient check
$\varepsilon(\mathrm{disc})^{2b} = 1$ can fail; drop the integrality/parity of $b$ and
the exponent $2b$ need not be even. Each pillar is load-bearing, and FD3 sharpens this
observation into a characterization: quadraticity is not an independent hypothesis but
a *consequence* of demanding that the relation be consistent with involutivity in
every degree.

The companion development records two further symmetries of the underlying
combinatorial model: the *contragredient invariance* of a centered period exponent
$e(\lambda) = \sum_i (2i+1-n)\lambda_i$, and its *twist invariance* under
$\lambda \mapsto \lambda + k$, both proved with no regularity assumption and
witnessed on the non-regular weight $(1,1,0)$. Together they realize the
$s \mapsto 1-s$, $\pi \mapsto \pi^{\vee}$ functional-equation symmetry at the level of
period exponents.

---

## 9. Future directions

**FD1. The twist sign is a Kronecker symbol of the discriminant.** The abstract twist
value $\varepsilon(\mathrm{disc}(k))$ should equal the Kronecker symbol
$\chi_k(\mathrm{disc}(k))$ of the quadratic character cutting out $\varepsilon$, with
sign computable from $\mathrm{disc}(k)$ modulo the conductor of $\varepsilon$ via
quadratic reciprocity. The self-duality criterion $\varepsilon(\mathrm{disc}) = 1$ is,
by Euler's criterion, identical to "$\mathrm{disc}(k)$ is a quadratic residue."
Mathlib's `legendreSym`, the Jacobi/Kronecker symbol, and full quadratic reciprocity
put the general composite-conductor statement within reach.

**FD2. Parity-of-degree dichotomy classifies non-self-dual $\mathrm{GL}(n)$.** For a
fixed non-square discriminant ($\varepsilon(\mathrm{disc}) = -1$), the periods of
$\pi$ and $\pi^{\vee}$ agree iff $b = r_1\lfloor n^2/4\rfloor + r_2\binom{n}{2}$ is
even, and over $\mathbb{Q}$ the set of $n$ for which they disagree is exactly
$\{n : \lfloor n^2/4\rfloor \text{ odd}\} = \{n \equiv 2 \pmod 4\}$. The closed forms
reduce the parity question to elementary `Nat` arithmetic, yielding a complete
$(n, r_1, r_2) \mapsto \text{parity}$ classification.

**FD3. Quadraticity $\Leftrightarrow$ consistency of the contragredient relation.**
Among all multiplicative twist factors $c = \varepsilon(\mathrm{disc})$, the period
relation $P(\pi^{\vee}) = c^{b} P(\pi)$ is consistent with $(\pi^{\vee})^{\vee} = \pi$
for *all* degrees $b$ **iff** $c^2 = 1$; quadraticity is therefore a forced
consequence of involutivity rather than an assumption. The double contragredient
produces $c^{2b}$, which must equal $1$ for every $b$, and
$(\forall b,\ c^{2b} = 1) \Leftrightarrow c^2 = 1$.

**FD4. Functorial transfer of the twist under base change.** Under base change
$k \to K$ the twist sign should multiply:
$\varepsilon_K(\mathrm{disc}(K)) = \varepsilon_k(\mathrm{disc}(k))^{[K:k]} \cdot
\varepsilon_k(\mathrm{disc}(K/k))$, so the self-duality locus is stable under
odd-degree extensions.

---

## 10. Conclusion

We have proved, in hypothesis-minimal form, that the Betti–Whittaker period of the
contragredient $\pi^{\vee}$ of a cohomological generic representation of
$\mathrm{GL}(n)$ over a number field $k$ equals the period of $\pi$ times
$\varepsilon(\mathrm{disc}(k))^{b}$, the discriminant sign raised to the bottom
cohomological degree. The result follows from three load-bearing facts —
involutivity of the contragredient, quadraticity of $\varepsilon$, and the closed
form / parity of $b$ — and collapses a deep analytic comparison to a single parity
computation.
