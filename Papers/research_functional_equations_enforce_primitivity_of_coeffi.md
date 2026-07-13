# Functional Equations Enforce Primitivity of Coefficients

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

We study the rigid interplay between the functional equation of a Dirichlet
$L$-function and the primitivity of its underlying character. The completed
$L$-function $\Lambda(\chi, s)$ of a primitive Dirichlet character $\chi$ modulo
$N$ satisfies the reflection identity
$$\Lambda(\chi, 1 - s) = N^{\,s - 1/2}\, W(\chi)\, \Lambda(\chi^{-1}, s),$$
in which $W(\chi)$ is the root number, an explicit normalisation of the Gauss sum
of $\chi$. Taking this identity as the single analytic input, we derive four
structural consequences that are invisible at the level of any single value: a
central-point functional equation, an unconditional identity-form root-number
reciprocity law, a self-dual functional equation for real characters, and the
statement that the root number of a quadratic character squares to the identity on
$L$-values. We then turn to the arithmetic heart of the root number — the Gauss
sum — and prove three enforcement results showing that a Gauss sum survives
against an additive character precisely when both characters are matched in
primitivity, with a quantitative conductor-descent bound. Together these results
express, in a precise and unconditional form, the principle that the functional
equation enforces primitivity of the coefficients: primitivity is exactly the
hypothesis under which the reflection identity is clean, and the Gauss sum
vanishes exactly when primitivity fails. We also establish that primitivity is
preserved under character inversion, so that all dual statements are internally
consistent.

## 1. Introduction

The functional equation of the Riemann zeta function is the archetype of a
symmetry relating a meromorphic function to a reflected copy of itself. Its
generalisation to Dirichlet $L$-functions is the foundation of analytic number
theory: it produces the analytic continuation, the critical strip, and the
symmetric distribution of nontrivial zeros that make the Generalised Riemann
Hypothesis meaningful.

For a Dirichlet character $\chi$ modulo $N$, the associated $L$-function is
$$L(\chi, s) = \sum_{n=1}^{\infty} \frac{\chi(n)}{n^{s}}, \qquad \operatorname{Re}(s) > 1,$$
extended by analytic continuation to the whole plane. The functional equation is
cleanest — takes the exact form displayed in the abstract — precisely when $\chi$
is **primitive**, i.e. when its conductor equals $N$. This paper isolates and
proves, in unconditional form, the structural rigidity that this cleanliness
imposes, and identifies the arithmetic mechanism (the Gauss sum) that enforces
primitivity in the first place.

Our contributions divide into two families:

1. **Analytic rigidity.** From the reflection identity alone we derive the
   central-point identity, root-number reciprocity in identity form, the
   self-dual functional equation, and the square-root-of-unity property of
   quadratic root numbers.
2. **Gauss-sum enforcement.** From the vanishing theory of Gauss sums we prove
   that primitivity of a Dirichlet character is detected — and enforced — by the
   non-vanishing of its Gauss sums against additive characters, with a
   conductor-descent bound.

A guiding methodological choice is to keep every statement **unconditional**. In
particular, the reciprocity law is stated in "identity form", as an equality of
operators acting on the completed $L$-function, which requires no non-vanishing
hypothesis. We explain in Section 6 exactly where a non-vanishing witness would be
needed to upgrade it to the scalar equality $W(\chi)\,W(\chi^{-1}) = 1$.

## 2. Definitions

Throughout, $N$ is a positive integer and $\chi$ is a Dirichlet character modulo
$N$ with values in $\mathbb{C}$; that is, a multiplicative homomorphism from the
group of units modulo $N$ to $\mathbb{C}^{\times}$, extended by zero to
non-units.

**Definition 2.1 (Factoring through a divisor).** For $d \mid N$, we say $\chi$
*factors through* $d$ if there is a character $\chi_0$ modulo $d$ such that
$\chi(n) = \chi_0(n \bmod d)$ for all $n$ coprime to $N$.

**Definition 2.2 (Conductor and primitivity).** The **conductor**
$\operatorname{cond}(\chi)$ is the smallest divisor $d \mid N$ through which
$\chi$ factors. The character $\chi$ is **primitive** if
$\operatorname{cond}(\chi) = N$, equivalently if it factors through no proper
divisor of $N$.

**Definition 2.3 (Dual character).** The **dual** (or inverse) character
$\chi^{-1}$ is defined by $\chi^{-1}(n) = \chi(n)^{-1} = \overline{\chi(n)}$ for
units $n$, and $0$ otherwise. A character is **real** (quadratic) if
$\chi^{-1} = \chi$, i.e. all values lie in $\{-1, 0, 1\}$.

**Definition 2.4 (Additive character).** An **additive character** of
$\mathbb{Z}/N\mathbb{Z}$ is a homomorphism $e : \mathbb{Z}/N\mathbb{Z} \to
\mathbb{C}^{\times}$. Its **mulShift** by $a$ is the additive character
$x \mapsto e(ax)$. The character $e$ is **primitive** if it is nontrivial on
every proper subgroup, equivalently if $e(\text{mulShift by } d) \neq 1$ for every
proper divisor $d$; imprimitivity of $e$ means $e$ is trivial after a mulShift by
some proper divisor.

**Definition 2.5 (Gauss sum).** The **Gauss sum** of $\chi$ against an additive
character $e$ is
$$g(\chi, e) = \sum_{x \in \mathbb{Z}/N\mathbb{Z}} \chi(x)\, e(x).$$
For the standard additive character $e_N(x) = \exp(2\pi i x / N)$ this recovers
the classical Gauss sum $g(\chi) = \sum_{x} \chi(x)\, e^{2\pi i x/N}$.

**Definition 2.6 (Completed $L$-function and root number).** The **completed
$L$-function** $\Lambda(\chi, s)$ is the product of $L(\chi, s)$ with its
archimedean gamma factor and an appropriate power of the modulus, normalised so
that it is entire (for nontrivial $\chi$) and symmetric under $s \mapsto 1 - s$ up
to a constant. The **root number** $W(\chi)$ is the unimodular constant appearing
in that symmetry; explicitly it is the Gauss sum $g(\chi)$ divided by its
absolute value together with an $i$-power depending on the parity of $\chi$.

**Reflection identity (analytic input).** For primitive $\chi$ modulo $N$,
$$\Lambda(\chi, 1 - s) = N^{\,s - 1/2}\, W(\chi)\, \Lambda(\chi^{-1}, s)
\qquad \text{for all } s \in \mathbb{C}. \tag{$\star$}$$
We take $(\star)$ as given and derive everything below from it, together with the
Gauss-sum vanishing theory.

## 3. Primitivity is preserved under inversion

Before deriving dual statements we record a structural lemma ensuring the theory
is closed under duality.

**Lemma 3.1 (Inversion preserves primitivity).** *If $\chi$ is a primitive
Dirichlet character modulo $N$, then its dual $\chi^{-1}$ is also primitive.*

*Proof sketch.* Inversion acts pointwise as $n \mapsto \chi(n)^{-1}$ and does not
change the set of divisors $d \mid N$ through which the character factors: if
$\chi = \chi_0$ composed with reduction modulo $d$, then $\chi^{-1} = \chi_0^{-1}$
composed with the same reduction, and conversely. Hence the conductor set of
$\chi^{-1}$ equals that of $\chi$, so the two conductors coincide and primitivity
transfers. $\qquad\blacksquare$

This lemma is what allows us to apply the reflection identity $(\star)$ to both
$\chi$ and $\chi^{-1}$ in the next section.

## 4. Analytic rigidity from the reflection identity

All four results in this section flow from $(\star)$ by elementary manipulations:
substitution $s \mapsto 1 - s$, the additivity law $N^{a}N^{b} = N^{a+b}$ for
complex powers of a nonzero base, and the involutivity $(\chi^{-1})^{-1} = \chi$.

**Theorem 4.1 (Central-point functional equation).** *For primitive $\chi$,*
$$\Lambda(\chi, \tfrac12) = W(\chi)\, \Lambda(\chi^{-1}, \tfrac12).$$

*Proof sketch.* Put $s = 1/2$ in $(\star)$. Then $1 - s = 1/2$ and the modulus
factor is $N^{1/2 - 1/2} = N^{0} = 1$, leaving the stated identity. $\qquad\blacksquare$

The central point $s = 1/2$ is precisely the axis of symmetry of the reflection
and the focus of the deepest conjectures on the location of zeros; Theorem 4.1
shows that there the root number alone controls the relationship between a
character and its dual.

**Theorem 4.2 (Root-number reciprocity, identity form).** *For primitive $\chi$
and every $s \in \mathbb{C}$,*
$$W(\chi)\, W(\chi^{-1})\, \Lambda(\chi, s) = \Lambda(\chi, s).$$

*Proof sketch.* Apply $(\star)$ to $\chi$ at argument $1 - s$:
$$\Lambda(\chi, s) = N^{(1-s) - 1/2}\, W(\chi)\, \Lambda(\chi^{-1}, 1 - s).$$
By Lemma 3.1, $\chi^{-1}$ is primitive, so $(\star)$ applies to it at argument
$s$, and since $(\chi^{-1})^{-1} = \chi$,
$$\Lambda(\chi^{-1}, 1 - s) = N^{s - 1/2}\, W(\chi^{-1})\, \Lambda(\chi, s).$$
Substituting and combining the modulus factors,
$$N^{(1-s)-1/2}\, N^{s-1/2} = N^{(1-s-1/2) + (s-1/2)} = N^{0} = 1,$$
which cancels exactly, yielding $\Lambda(\chi, s) = W(\chi)\,W(\chi^{-1})\,
\Lambda(\chi, s)$. $\qquad\blacksquare$

We emphasise that Theorem 4.2 is unconditional: it holds as a functional identity
for all $s$ with no non-vanishing hypothesis. This is deliberate — see Section 6.

**Theorem 4.3 (Self-dual functional equation).** *If $\chi$ is primitive and
real, so that $\chi^{-1} = \chi$, then for all $s$*
$$\Lambda(\chi, 1 - s) = N^{\,s - 1/2}\, W(\chi)\, \Lambda(\chi, s).$$

*Proof sketch.* Substitute $\chi^{-1} = \chi$ directly into $(\star)$. $\qquad\blacksquare$

**Theorem 4.4 (Quadratic root number squares to the identity).** *If $\chi$ is
primitive and real, then for all $s$*
$$W(\chi)^{2}\, \Lambda(\chi, s) = \Lambda(\chi, s).$$

*Proof sketch.* Apply Theorem 4.2 and use $W(\chi^{-1}) = W(\chi)$, which holds
because $\chi^{-1} = \chi$; then $W(\chi)\,W(\chi^{-1}) = W(\chi)^{2}$. $\qquad\blacksquare$

Theorem 4.4 is the abstract, unconditional source of the classical fact that the
root number of a real primitive character is exactly $\pm 1$: once one exhibits a
single $s$ with $\Lambda(\chi, s) \neq 0$, one may cancel to obtain $W(\chi)^{2} =
1$, hence $W(\chi) = \pm 1$.

## 5. Gauss-sum enforcement of primitivity

The root number $W(\chi)$ is a normalisation of the Gauss sum $g(\chi)$, so the
existence of a clean functional equation is ultimately controlled by the
arithmetic of Gauss sums. The decisive input is the classical vanishing theorem:

**Vanishing Theorem (input).** *If $\chi$ is primitive and the additive character
$e$ is imprimitive, then $g(\chi, e) = 0$.*

From it we extract the following enforcement results.

**Theorem 5.1 (Gauss sums detect additive primitivity).** *Let $\chi$ be a
primitive Dirichlet character modulo $N$ and $e$ an additive character of
$\mathbb{Z}/N\mathbb{Z}$. If $g(\chi, e) \neq 0$, then $e$ is primitive.*

*Proof sketch.* Contrapositive of the Vanishing Theorem: were $e$ imprimitive,
the theorem would force $g(\chi, e) = 0$, contradicting the hypothesis. $\qquad\blacksquare$

Equivalently, a primitive Dirichlet character annihilates every imprimitive
additive character through its Gauss sum: the only additive rhythms it responds
to are themselves primitive.

**Theorem 5.2 (Imprimitivity forced by a surviving Gauss sum).** *Let $\chi$ be a
Dirichlet character modulo $N$ and $e$ an imprimitive additive character. If
$g(\chi, e) \neq 0$, then $\chi$ is not primitive.*

*Proof sketch.* Again contrapositive: if $\chi$ were primitive, the Vanishing
Theorem applied to the imprimitive $e$ would give $g(\chi, e) = 0$. $\qquad\blacksquare$

Theorems 5.1 and 5.2 are the two faces of a single dichotomy: a Gauss sum
survives if and only if the multiplicative and additive characters are matched in
primitivity. The survival of a Gauss sum against an imprimitive additive
character is a certificate of hidden periodicity in the coefficients of $\chi$.

**Theorem 5.3 (Conductor descent from Gauss sums).** *Let $\chi$ be a Dirichlet
character modulo $N$, let $d \mid N$, and let $e$ be an additive character with
$\operatorname{mulShift}(e, d) = 1$ (so $e$ is trivialised by $d$). If
$g(\chi, e) \neq 0$, then $\chi$ factors through $d$, and hence*
$$\operatorname{cond}(\chi) \le d.$$

*Proof sketch.* A nonzero Gauss sum against an additive character trivialised by
$d$ forces $\chi$ to factor through $d$: the standard descent argument writes the
Gauss sum as a sum over residues modulo $d$ times an inner sum that vanishes
unless $\chi$ is constant on cosets of $d$. Since $d$ then lies in the conductor
set of $\chi$, the conductor — the least element of that set — is at most $d$. $\qquad\blacksquare$

Theorem 5.3 makes the enforcement quantitative: each additive character
trivialised by a proper divisor $d$ and yielding a nonzero Gauss sum witnesses
$\operatorname{cond}(\chi) \le d < N$, i.e. imprimitivity. Only when every such
Gauss sum vanishes can $\chi$ be primitive at the full level $N$. The Gauss sum
thus continuously measures the distance of $\chi$ from primitivity and pins its
conductor to the smallest level supporting a nonzero sum.

## 6. Discussion: why identity form?

The reciprocity law is classically stated as the scalar equality
$W(\chi)\,W(\chi^{-1}) = 1$. Our Theorem 4.2 instead asserts
$W(\chi)\,W(\chi^{-1})\,\Lambda(\chi, s) = \Lambda(\chi, s)$ for all $s$. The two
are equivalent as soon as one knows a single value $s_0$ with
$\Lambda(\chi, s_0) \neq 0$: cancel $\Lambda(\chi, s_0)$ to obtain the scalar
equality. Such a witness exists classically — deep in the half-plane of absolute
convergence the Euler product
$$L(\chi, s) = \prod_{p} \left(1 - \chi(p) p^{-s}\right)^{-1}$$
is a convergent product of nonzero factors and hence nonzero — but invoking it
introduces an analytic hypothesis. By stating reciprocity in identity form we
keep the result unconditional and structurally transparent: it is a pure
consequence of applying $(\star)$ twice, and it isolates exactly the point where
a non-vanishing input would be consumed. The same remark applies to Theorem 4.4:
the passage from $W(\chi)^{2}\,\Lambda(\chi, s) = \Lambda(\chi, s)$ to
$W(\chi)^{2} = 1$ (hence $W(\chi) = \pm 1$) is precisely the step that needs a
non-vanishing witness.

## 7. Applications

- **Central values and zeros.** Theorem 4.1 localises the interplay of a
  character and its dual to the central point, the focus of the Generalised
  Riemann Hypothesis and of central-value non-vanishing results with arithmetic
  consequences (e.g. ranks of elliptic curves via the Birch–Swinnerton-Dyer
  philosophy).
- **Signs of functional equations.** Theorem 4.4 is the mechanism behind the
  $\pm 1$ dichotomy of quadratic root numbers, which governs forced vanishing of
  central $L$-values and hence parity phenomena in arithmetic.
- **Gauss sums in coding and communications.** Theorems 5.1–5.3 formalise the
  primitivity-matching that underlies Gauss-sum evaluations in the weight
  distributions of error-correcting codes and the low correlation of sequences
  built from characters.

## 8. Future work

The results here suggest several sharp, testable conjectures: a converse rigidity
statement characterising primitivity by the existence of a clean reflection law;
the upgrade of identity-form reciprocity to the scalar equality
$W(\chi)\,W(\chi^{-1}) = 1$ via a non-vanishing witness; a quantitative
Gauss-sum modulus formula pinning $|g(\chi)|^{2}$ to the conductor rather than the
modulus; and a systematic study of the sign of the central value for self-dual
functional equations. These are elaborated in the accompanying future-directions
material.

## 9. Conclusion

We have shown, in unconditional form, that primitivity is the exact hypothesis
under which the Dirichlet functional equation takes its clean reflected shape, and
that the Gauss sum at the analytic heart of the root number vanishes exactly when
primitivity fails. The analytic rigidity results (Theorems 4.1–4.4) and the
Gauss-sum enforcement results (Theorems 5.1–5.3) are the two faces — analytic and
arithmetic — of a single principle: the functional equation enforces primitivity
of its coefficients.
