# EML Transseries: A Hahn-Series Model, the Asymptotic Comparison Theorem, and the Exp-Substitution Automorphism

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Applications (asymptotic analysis / ordered algebra)

---

## Abstract

Power series cannot express the asymptotic relationship between a variable and its
exponential: no power-series valuation can encode an object that dominates $x^{a}$ for
every real $a$ simultaneously. *Transseries* repair this deficiency by enlarging the
monomial basis to formal products of iterated exponentials and logarithms with real
exponents. We present a rigorous, machine-checked model of single-tower, real-power
transseries built on Hahn series over the lexicographically ordered group of
**transmonomials** $\mathrm{Lex}(\mathbb{Z} \to_{f} \mathbb{R})$. We prove that this model
is a field, that its valuation realizes asymptotic dominance (in particular that $e^{x}$
dominates every power of $x$), and we establish the **asymptotic comparison theorem**: two
transseries agreeing to all orders are equal, so a transseries is uniquely determined by
its expansion. Our central new contribution is the **exp-substitution automorphism**: the
operation $x \mapsto e^{x}$ is realized as an injective ring homomorphism
$\mathrm{expShift}\colon \mathrm{TSeries} \to \mathrm{TSeries}$ that raises every tower
height by one, fixes the constant field $\mathbb{R}$, and satisfies
$\mathrm{expShift}(x) = e^{x}$. The load-bearing lemma is that the height shift preserves
the dominance order ($\mathrm{shift}(x) < \mathrm{shift}(y) \iff x < y$), proved via the
behavior of lexicographic comparison under a monotone relabeling of indices. We connect the
formal order to genuine real analysis and discuss algorithmic and structural consequences.

---

## 1. Introduction

### 1.1 Motivation

A foundational asymptotic fact is that $x^{n} = o(e^{x})$ as $x \to \infty$ for every $n$,
and more generally $x^{a} = o(e^{x})$ for every real $a$. Iterating, $(e^{x})^{a} =
o(e^{e^{x}})$, and dually $\log x$ is dominated by every positive power of $x$. These facts
organize the elementary functions into a doubly-infinite hierarchy of **tower heights**,
$$ \cdots \prec \log\log x \prec \log x \prec x \prec e^{x} \prec e^{e^{x}} \prec \cdots, $$
indexed by $h \in \mathbb{Z}$ (height $0 = x$, height $1 = e^{x}$, height $-1 = \log x$,
height $2 = e^{e^{x}}$, and so on).

Power series are structurally incapable of describing this hierarchy: their valuation is a
single integer (or real, for Puiseux/Hahn power series in one variable), and no such
valuation admits an element dominating $x^{a}$ for *all* $a$. Transseries, introduced by
Dahn–Göring, Écalle, and developed extensively by van den Dries–Macintyre–Marker and by
Aschenbrenner–van den Dries–van der Hoeven, resolve this by allowing formal series whose
monomials are products of iterated exp/log with real exponents.

The payoff of treating asymptotic data as a formal field is twofold. First, it converts
statements usually phrased as limits ($x^{n}/e^{x}\to 0$) into algebraic facts about an
order, where they can be manipulated symbolically. Second, it exposes operations — most
notably the change of variable $x\mapsto e^{x}$ — as structure-preserving maps of the entire
field, rather than ad hoc manipulations valid only case by case. The present development
focuses on the single-tower, real-power fragment, which already exhibits all of these
phenomena while remaining concrete enough to model directly on Mathlib's `HahnSeries`.
Working in this fragment keeps the value group equal to the transparent group
$\mathrm{Lex}(\mathbb{Z} \to_{f} \mathbb{R})$, so every order computation reduces to a finite
lexicographic comparison.

### 1.2 Contributions

We give a self-contained, formally verified development of the following, organized into
three layers.

1. **A field model (Section 3).** The transmonomials form the lexicographically ordered
   group $\mathrm{Lex}(\mathbb{Z} \to_{f} \mathbb{R})$; Hahn series over it form a field
   $\mathrm{TSeries}$ whose valuation `orderTop` is multiplicative and whose order realizes
   asymptotic dominance. We prove higher towers dominate (`mono_lt_mono_of_height`),
   same-height comparison reduces to exponent comparison (`mono_lt_mono_same`), and the
   signature fact `exp_dominates_pow`: $x^{a} \prec e^{x}$ for all real $a$.

2. **The asymptotic comparison theorem (Section 4).** Defining "agreement to all orders"
   via the valuation, we prove `agreeToAllOrders_iff_eq`: agreement to all orders is
   equivalent to equality, and is an equivalence relation. We ground the formal order in
   real analysis with `isLittleO_pow_exp` and `isLittleO_expPow_expExp`.

3. **The exp-substitution automorphism (Section 5).** We realize $x \mapsto e^{x}$ as an
   injective ring homomorphism `expShift`, with the dominance-preservation lemma
   `shift_lt_iff` as its engine, and we compute its action: `expShift_term`,
   `expShift_var` ($x \mapsto e^{x}$), `expShift_exp`, `expShift_log`, and `expShift_C`
   (fixing $\mathbb{R}$).

---

## 2. Preliminaries: Hahn series

Let $\Gamma$ be a linearly ordered abelian group and $K$ a field. A **Hahn series** over
$\Gamma$ with coefficients in $K$ is a function $f\colon \Gamma \to K$ whose support
$\{\gamma : f(\gamma) \neq 0\}$ is **well-ordered**. Hahn series form a ring under pointwise
addition and Cauchy-style convolution multiplication; when $K$ is a field they form a field
(every nonzero series is invertible). The **valuation** (here `orderTop`) sends a nonzero
series to the least element of its support (its leading transmonomial) and sends $0$ to
$\top$; it is multiplicative, $v(fg) = v(f) + v(g)$.

We use Mathlib's `HahnSeries` together with the constructor `HahnSeries.single g c` (the
one-term series $c \cdot g$), the constant embedding `HahnSeries.C`, and the
order-embedding ring homomorphism `HahnSeries.embDomainRingHom`, which lifts an injective,
order-reflecting additive group homomorphism of the value group to a ring homomorphism of
the Hahn-series field.

---

## 3. The field of transmonomials and transseries

### Definition 1 (Transmonomials)
The **transmonomial group** is
$$ \mathrm{TransMono} := \mathrm{Lex}(\mathbb{Z} \to_{f} \mathbb{R}), $$
the group of finitely supported functions $\mathbb{Z} \to \mathbb{R}$ under pointwise
addition, equipped with the lexicographic order. An element assigns a real exponent to each
tower height. Because Mathlib's `Finsupp.Lex` compares at the **least** differing index, we
store tower height $h$ at index $-h$, so that *higher* towers are *more significant*.
$\mathrm{TransMono}$ is a linearly ordered abelian group.

### Definition 2 (Transseries field)
The **transseries field** is the Hahn-series field
$$ \mathrm{TSeries} := \mathrm{HahnSeries}(\mathrm{TransMono}, \mathbb{R}). $$
By Mathlib's Hahn-series field instance over a linearly ordered group, `TSeries` is a field
(`instField`).

### Definition 3 (Single transmonomial)
For $h \in \mathbb{Z}$ and $a \in \mathbb{R}$,
$$ \mathrm{mono}(h,a) := \mathrm{toLex}\big(\mathrm{single}_{-h}\, a\big) \in \mathrm{TransMono}, $$
the transmonomial $(\text{level } h)^{a}$ — e.g. $\mathrm{mono}(1,1)=e^{x}$,
$\mathrm{mono}(0,a)=x^{a}$, $\mathrm{mono}(-1,a)=(\log x)^{a}$.

### Definition 4 (One-term transseries)
$$ \mathrm{term}(h,a) := \mathrm{single}\,(\mathrm{mono}(h,a))\, 1 \in \mathrm{TSeries}, $$
the transseries whose unique transmonomial is $(\text{level }h)^{a}$ with coefficient $1$.
We write $\mathrm{varX} = \mathrm{term}(0,1)$ ($=x$), $\mathrm{expX}=\mathrm{term}(1,1)$
($=e^{x}$), $\mathrm{logX}=\mathrm{term}(-1,1)$ ($=\log x$).

### Theorem A (Higher towers dominate — `mono_lt_mono_of_height`)
For $h < h'$ and $0 < a'$, and any $a$,
$$ \mathrm{mono}(h,a) < \mathrm{mono}(h',a'). $$

*Proof sketch.* By `Finsupp.Lex.lt_iff`, a strict inequality holds iff there is a least
index $i$ at which the two finsupps differ, below which they agree, with the first strictly
smaller at $i$. Take $i = -h'$. Below $-h'$ (i.e. for indices $d < -h'$, which correspond to
tower heights $> h'$) both single-supported finsupps vanish, so they agree. At $i=-h'$ the
left finsupp is $0$ (its support is $-h \neq -h'$) and the right is $a' > 0$. Hence the
left is strictly smaller. $\square$

### Theorem B (Same-height comparison — `mono_lt_mono_same`)
For any $h$ and $a < a'$,
$$ \mathrm{mono}(h,a) < \mathrm{mono}(h,a'). $$

*Proof sketch.* Apply `Finsupp.Lex.lt_iff` at index $-h$: below $-h$ both vanish; at $-h$
the values are $a < a'$. $\square$

### Theorem C (Exp dominates every power — `exp_dominates_pow`)
For every real $a$,
$$ \mathrm{mono}(0,a) < \mathrm{mono}(1,1), \qquad\text{i.e.}\qquad x^{a} \prec e^{x}. $$

*Proof sketch.* Immediate from Theorem A with $h=0<1=h'$, $a'=1>0$. The point is the
*universality* over all real $a$: this is impossible for any single power-series valuation
and is the defining feature separating transseries from power series. $\square$

### Valuation facts
- **`orderTop_term`:** $v(\mathrm{term}(h,a)) = \mathrm{mono}(h,a)$ (the valuation of a
  one-term series is its transmonomial).
- **`orderTop_mul`:** $v(xy) = v(x) + v(y)$ (multiplicativity, inherited from Hahn series).
- **`C_injective`:** the constant embedding $\mathbb{R} \hookrightarrow \mathrm{TSeries}$
  is an injective ring homomorphism, so $\mathbb{R}$ is a subfield.

---

## 4. The asymptotic comparison theorem

### Definition 5 (Agreement to all orders — `AgreeToAllOrders`)
Two transseries $a, b$ **agree to all orders** when their difference is asymptotically
smaller than every transmonomial:
$$ \mathrm{AgreeToAllOrders}(a,b) \;:\Longleftrightarrow\; \forall\, g \in \mathrm{TransMono},\ (g : \mathrm{WithTop}\,\mathrm{TransMono}) < v(a-b). $$

### Theorem D (Asymptotic comparison theorem — `agreeToAllOrders_iff_eq`)
$$ \mathrm{AgreeToAllOrders}(a,b) \iff a = b. $$

*Proof sketch.* ($\Rightarrow$) Suppose $a,b$ agree to all orders. If $v(a-b) \neq \top$,
write $v(a-b) = c$ for some transmonomial $c$ (via `WithTop.ne_top_iff_exists`); then
instantiating the hypothesis at $g = c$ gives $c < c$, contradicting irreflexivity. Hence
$v(a-b) = \top$, and `HahnSeries.orderTop_eq_top` gives $a-b = 0$, i.e. $a=b$.
($\Leftarrow$) If $a = b$ then $v(a-b) = v(0) = \top$, which is strictly above every
transmonomial $g$ since $g < \top$. $\square$

**Corollaries.**
- **`agreeToAllOrders_equivalence`:** agreement to all orders is an equivalence relation
  (it *is* equality).
- **`not_agree_zero_of_ne_zero`:** a nonzero transseries does not agree to all orders with
  $0$ — it has a genuine leading term.

**Interpretation.** A transseries is uniquely determined by its asymptotic expansion: there
is no nonzero "beyond all orders" remainder. This is the rigorous form of the classical
asymptotic comparison principle within the Hahn model.

### Analytic grounding
The formal order is faithful to real analysis:

### Theorem E (`isLittleO_pow_exp`)
For every $n \in \mathbb{N}$, $\ x^{n} = o(e^{x})$ as $x \to \infty$. *(Mathlib's
`Real.isLittleO_pow_exp_atTop`.)* This is the analytic shadow of Theorem C.

### Theorem F (`isLittleO_expPow_expExp`)
For every $n \in \mathbb{N}$, $\ (e^{x})^{n} = o\!\big(e^{e^{x}}\big)$ as $x \to \infty$.

*Proof sketch.* Compose `isLittleO_pow_exp` with $\exp \to \infty$
(`Real.tendsto_exp_atTop`). This is the analytic shadow of `mono_lt_mono_of_height` at
heights $1 < 2$. $\square$

---

## 5. The exp-substitution automorphism

We now realize the substitution $x \mapsto e^{x}$ — climbing the tower by one rung — as a
ring homomorphism.

### Definition 6 (Height shift — `shift`)
Let $\mathrm{shiftEquiv}\colon \mathbb{Z} \simeq \mathbb{Z}$ be $i \mapsto i-1$
(`Equiv.subRight 1`). The **height shift** on transmonomials relabels finsupp indices along
$\mathrm{shiftEquiv}$:
$$ \mathrm{shift}(x) := \mathrm{toLex}\big(\mathrm{equivMapDomain}\,\mathrm{shiftEquiv}\,(\mathrm{ofLex}\,x)\big). $$
Since index $-h$ becomes $-(h+1)$, the shift raises tower height $h$ to $h+1$. It is
additive (`shiftHom`, a group homomorphism) and injective (`shift_inj`, from
`Finsupp.mapDomain_injective`).

### Theorem G (Exp-substitution preserves dominance — `shift_lt_iff`)
For all transmonomials $x, y$,
$$ \mathrm{shift}(x) < \mathrm{shift}(y) \iff x < y. $$

*Proof sketch.* Unfold with `Finsupp.Lex.lt_iff` on both sides. A strict inequality is
witnessed by a least index $i$ of difference. Given a witness $i$ for $x < y$, the index
$\mathrm{shiftEquiv}(i)$ witnesses $\mathrm{shift}(x) < \mathrm{shift}(y)$: for $d <
\mathrm{shiftEquiv}(i)$ one has $\mathrm{shiftEquiv}^{-1}(d) < i$, so agreement transports
through `Finsupp.equivMapDomain_apply`; and the strict inequality at $i$ transports to
$\mathrm{shiftEquiv}(i)$. The converse is symmetric, using $\mathrm{shiftEquiv}^{-1}$.
Conceptually: a lexicographic comparison is decided at the least differing index, and a
monotone bijection of the index set maps "least differing index" to "least differing
index," so the order is preserved. The shift is thus an **order isomorphism** of the value
group. $\square$

As a consequence (`shiftHom_le_iff`), the non-strict order is also reflected:
$\mathrm{shiftHom}(g) \le \mathrm{shiftHom}(g') \iff g \le g'$, combining `shift_lt_iff`
with injectivity.

### Definition 7 (Exp-substitution ring homomorphism — `expShift`)
$$ \mathrm{expShift} := \mathrm{HahnSeries.embDomainRingHom}\ \mathrm{shiftHom}\ \mathrm{shift\_inj}\ \mathrm{shiftHom\_le\_iff} \;\colon\; \mathrm{TSeries} \to^{+*} \mathrm{TSeries}. $$
The three hypotheses required by `embDomainRingHom` are exactly: $\mathrm{shiftHom}$ is an
additive group homomorphism (Def 6), injective (`shift_inj`), and order-reflecting
(`shiftHom_le_iff`, from Theorem G). Hence $\mathrm{expShift}$ is a genuine ring
homomorphism: it respects addition and multiplication.

### Theorem H (Height shift on a transmonomial — `shift_mono`)
$$ \mathrm{shift}(\mathrm{mono}(h,a)) = \mathrm{mono}(h+1,a). $$

*Proof sketch.* Both sides are single-supported finsupps; compute the value at each index
$i$. The relabeling sends support index $-h$ to $-(h+1)$, matching the right side via
`Finsupp.single_apply` and case analysis on $-h = i+1$. $\square$

### Theorem I (Exp-substitution on a one-term transseries — `expShift_term`)
$$ \mathrm{expShift}(\mathrm{term}(h,a)) = \mathrm{term}(h+1,a). $$

*Proof sketch.* Unfold `expShift` and `term`; `embDomainRingHom_apply` and
`embDomain_single` reduce the goal to $\mathrm{single}(\mathrm{shift}(\mathrm{mono}(h,a)))\,1
= \mathrm{single}(\mathrm{mono}(h+1,a))\,1$, closed by Theorem H. $\square$

### Theorem J (Headline — `expShift_var`)
$$ \mathrm{expShift}(x) = e^{x}, \qquad \text{i.e.}\qquad \mathrm{expShift}(\mathrm{varX}) = \mathrm{expX}. $$

*Proof sketch.* $\mathrm{varX} = \mathrm{term}(0,1)$; by Theorem I,
$\mathrm{expShift}(\mathrm{term}(0,1)) = \mathrm{term}(1,1) = \mathrm{expX}$. $\square$

Specializing Theorem I further:
- **`expShift_exp`:** $\mathrm{expShift}(e^{x}) = e^{e^{x}} = \mathrm{term}(2,1)$.
- **`expShift_log`:** $\mathrm{expShift}(\log x) = x$ (height $-1 \mapsto 0$).

### Theorem K (Fixes the constant field — `expShift_C`)
For every $r \in \mathbb{R}$,
$$ \mathrm{expShift}(\mathrm{C}\,r) = \mathrm{C}\,r. $$

*Proof sketch.* `HahnSeries.embDomainRingHom_C`: an `embDomain` ring homomorphism fixes the
constant subfield because the value group homomorphism fixes the identity $0$ and constants
are supported at $0$ (and $\mathrm{shiftHom}(0)=0$). $\square$

### Theorem L (Injectivity — `expShift_injective`)
$\mathrm{expShift}$ is injective: it embeds $\mathrm{TSeries}$ into itself.

*Proof sketch.* `HahnSeries.embDomain_injective`, since the underlying value-group map is
injective. $\square$

**Synthesis.** Theorems J and K together show $\mathrm{expShift}$ is a *nontrivial* field
endomorphism: it moves $x$ to $e^{x}$ (so it is not the identity) while fixing $\mathbb{R}$
(so it is a genuine $\mathbb{R}$-algebra/substitution map). Theorem G is the entire
mathematical content — the order-reflection that certifies $x \mapsto e^{x}$ respects every
asymptotic scale simultaneously.

---

## 6. A worked example

We trace the machinery on a concrete transseries to make the definitions tangible. Consider
$$ t \;=\; 2\,e^{x} \;+\; 5\,x^{3} \;-\; 4 \;+\; \tfrac{1}{2}\,(\log x)^{-1} \;\in\; \mathrm{TSeries}, $$
which as a Hahn series is the finitely supported coefficient map
$$ \mathrm{mono}(1,1)\mapsto 2,\quad \mathrm{mono}(0,3)\mapsto 5,\quad \mathrm{mono}(0,0)\mapsto -4,\quad \mathrm{mono}(-1,-1)\mapsto \tfrac12. $$

**Leading term and valuation.** The supports are, as transmonomials, ordered by the
lexicographic rule. The largest is $\mathrm{mono}(1,1) = e^{x}$ (height $1$ beats heights
$0$ and $-1$ by Theorem A). Hence $v(t) = \mathrm{orderTop}(t) = \mathrm{mono}(1,1)$ and the
leading behavior of $t$ is $2e^{x}$, exactly the dominant growth one expects analytically.

**Exp-substitution.** Applying $\mathrm{expShift}$ (Theorem I, term by term) shifts every
height up by one and fixes the coefficients:
$$ \mathrm{expShift}(t) \;=\; 2\,e^{e^{x}} \;+\; 5\,(e^{x})^{3} \;-\; 4 \;+\; \tfrac{1}{2}\,x^{-1}. $$
Indeed $\mathrm{mono}(1,1)\mapsto\mathrm{mono}(2,1)=e^{e^{x}}$, $\mathrm{mono}(0,3)\mapsto\mathrm{mono}(1,3)=(e^{x})^{3}$, the constant $-4$ is fixed (Theorem K), and
$\mathrm{mono}(-1,-1)\mapsto\mathrm{mono}(0,-1)=x^{-1}$. The whole expression has been lifted
one rung up the tower, and because $\mathrm{expShift}$ is a *ring* homomorphism this is
consistent with substituting $e^{x}$ for $x$ inside any algebraic combination forming $t$.

**Uniqueness.** Suppose a second transseries $s$ satisfies $\mathrm{AgreeToAllOrders}(t,s)$.
Then $v(t-s) = \top$, so $t - s = 0$, so $s = t$ coefficient-for-coefficient (Theorem D).
There is no way to perturb $t$ "beyond all orders" without changing it: the four
coefficients above are an exact fingerprint.

## 7. Algorithms

The model is constructive enough to support symbolic computation. We record the core
routines (Python realizations appear in the demo).

**Algorithm 1 — Lexicographic dominance comparison.** Represent a transmonomial as a finite
map `height ↦ exponent`. To compare, scan heights from highest to lowest; at the first
height where exponents differ, the larger exponent dominates. Complexity $O(k \log k)$ for
$k$ nonzero exponents (sorting heights), then $O(k)$ for the scan. This realizes Theorems A
and B and the order underlying Theorem C.

**Algorithm 2 — Exp-substitution (tower shift).** Given a transseries as a finite set of
(transmonomial, coefficient) pairs, apply `expShift` by mapping every height $h \mapsto
h+1$ in every transmonomial, leaving coefficients fixed. Complexity linear in the total
number of nonzero exponents. Correctness is Theorems H–K; injectivity (Theorem L) means no
two distinct inputs collide.

**Algorithm 3 — Agreement-to-all-orders test.** Given $a, b$, compute $a-b$; it is zero iff
all coefficients vanish iff (Theorem D) $a$ and $b$ agree to all orders. Complexity linear
in the number of terms.

---

## 8. Applications

- **Symbolic limit computation.** Engines that decide $\lim_{x\to\infty}$ of exp-log
  expressions (e.g. Gruntz's algorithm) operate in a transseries-like setting; the
  dominance order (Theorems A–C) decides leading behavior and the comparison theorem
  (Theorem D) guarantees a unique answer.
- **Asymptotics of ODE solutions / WKB.** Solutions to algebraic differential equations
  admit transseries expansions; the exp-substitution automorphism models the change of
  variable that climbs the exponential tower.
- **Resurgence and trans-monomial bookkeeping.** The faithful valuation makes
  "beyond-all-orders" terms a precise, manipulable notion rather than a heuristic.

---

## 9. Discussion

The order-theoretic core (Section 3) is where transseries genuinely transcend power series:
`exp_dominates_pow` asserts dominance over $x^{a}$ for *all* real $a$, impossible for a
one-dimensional valuation. The comparison theorem (Section 4), while clean inside the Hahn
model, is exactly the classical uniqueness-of-expansion principle once Hahn coefficients are
identified with asymptotic data; its proof is genuinely quantified over the entire
uncountable monomial group. The exp-substitution automorphism (Section 5) is the structural
highlight: its existence reduces to a single combinatorial lemma about lexicographic order
under monotone relabeling (`shift_lt_iff`), and its concrete identity $\mathrm{expShift}(x)
= e^{x}$ certifies that the abstract construction is the operation of interest.

The choice to store tower height $h$ at finsupp index $-h$ deserves emphasis: it aligns the
direction of Mathlib's `Finsupp.Lex` (decided at the *least* index) with the asymptotic
convention that the *highest* tower is most significant. With this sign convention every
dominance proof becomes a transparent statement about the least differing index, and the
exp-substitution becomes a rigid translation of the index line — the cleanest possible form
of the height shift. This is what makes the load-bearing lemma `shift_lt_iff` a short,
conceptual argument rather than a delicate case analysis, and why the entire construction
lifts to a ring homomorphism through Mathlib's `embDomainRingHom` with exactly three
hypotheses.

---

## 10. Future directions

This research thread extends the Hahn-series model of transseries with verified files:
`ExponentLaws.lean` (law of exponents per tower height, the group hom
$(\mathbb{R},+) \to \mathrm{TSeries}^{\times}$, unboundedness of the value group, and
`pow_var_lt_exp`: no finite power of $x$ dominates $e^{x}$); `ExpShift.lean` (the
exp-substitution as an injective ring homomorphism studied here); and `ExpShiftEquiv.lean`
(exp-substitution is a field *automorphism* `expShiftEquiv` with inverse the
log-substitution `logShift`, and the exp-tower is cofinal, `exists_exp_tower_gt`).

Open conjectures for follow-up:

- **Valuation scaling (C2).** $(\mathrm{expShift}\,t).\mathrm{orderTop} =
  \mathrm{WithTop.map}\ \mathrm{shift}\ (t.\mathrm{orderTop})$; on positive-height
  transseries, $t.\mathrm{orderTop} < (\mathrm{expShift}\,t).\mathrm{orderTop}$.
- **Differential field (C4).** A derivation $\mathrm{deriv}\colon \mathrm{TSeries} \to
  \mathrm{TSeries}$ with Leibniz rule, power rule, and exp chain rule, making
  $\mathrm{TSeries}$ a differential field; the hard part is Hahn summability of the
  derivative family.
- **Catalog embedding (C5).** For normalized catalog `FormalTransseries` with embedded
  leading monomials $m_1 < m_2$, $T_1.\mathrm{eval} = o(T_2.\mathrm{eval})$, bridging
  analytic `eval` to the formal valuation.
- **Tower action (C6).** $n \mapsto \mathrm{expShiftEquiv}^{n}$ is an injective group
  homomorphism $\mathbb{Z} \to (\mathrm{TSeries} \simeq^{+*} \mathrm{TSeries})$ with
  $\mathrm{expShiftEquiv}^{n}(\mathrm{term}(h,a)) = \mathrm{term}(h+n,a)$.
- **Archimedean classes = tower heights (C7).** The Archimedean classes of the value group
  correspond to tower heights.

---

## 11. Conclusion

We have presented a verified field model of single-tower real-power transseries, established
that its order realizes asymptotic dominance (with $e^{x}$ beating every power), proved the
asymptotic comparison theorem (uniqueness of expansion), and constructed the
exp-substitution automorphism realizing $x \mapsto e^{x}$ as an injective, scalar-fixing
ring homomorphism. The unifying lesson is that asymptotic growth, taken as a formal object,
carries a clean arithmetic, a sharp order, and a genuine symmetry.

---

## References

1. M. Aschenbrenner, L. van den Dries, J. van der Hoeven, *Asymptotic Differential Algebra
   and Model Theory of Transseries*, Annals of Mathematics Studies, 2017.
2. J. van der Hoeven, *Transseries and Real Differential Algebra*, Lecture Notes in
   Mathematics 1888, Springer, 2006.
3. L. van den Dries, A. Macintyre, D. Marker, *Logarithmic-exponential series*, Annals of
   Pure and Applied Logic, 2001.
4. H. Hahn, *Über die nichtarchimedischen Größensysteme*, 1907.
5. D. Gruntz, *On Computing Limits in a Symbolic Manipulation System*, PhD thesis, ETH
   Zürich, 1996.
