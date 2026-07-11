# Transreal Arithmetic: Total Division, the Collapse of the Ring Axioms, and the Wheel Nearby

## Abstract

Transreal arithmetic extends the real numbers with two signed infinities and a
distinguished element $\Phi$ ("nullity"), yielding a system in which every
arithmetic expression — including $1/0$, $0/0$, $\infty-\infty$, and
$0\times\infty$ — is assigned a value. The resulting operations are *total*:
there are no undefined forms, no exceptional inputs, and no partial functions.
We give a self-contained development of this system, denoted $\mathbb{T}$. We
prove that $\mathbb{T}$ forms a commutative monoid under each of addition and
multiplication, but that the passage to totality destroys the ring structure in
three precise ways: infinities lack additive inverses, zero fails to annihilate,
and — most consequentially — the distributive law fails, witnessed by
$(+\infty)(1+(-\infty)) = -\infty \neq \Phi = (+\infty)\cdot 1 + (+\infty)(-\infty)$.
We then compare $\mathbb{T}$ with the algebraic notion of a *wheel*, the standard
framework for total division. We prove that $\mathbb{T}$ is **not** a wheel,
isolating two structural obstructions: transreal infinities are signed (so
$\infty+\infty=\infty$ rather than the wheel's $\infty+\infty=\bot$), and the
transreal reciprocal is total but not an involution (it fails at $-\infty$).
Finally, we characterize the topology of $\mathbb{T}$ as the extended real
interval $[-\infty,+\infty]$ together with $\Phi$ as an isolated point, and use
this to determine which theorems of real analysis survive: compactness- and
connectedness-based results hold on the extended segment and are exactly obstructed
by the disconnection that $\Phi$ introduces, while the arithmetic operations are
continuous precisely away from the classical indeterminate forms, at which the
system returns $\Phi$.

**Keywords:** transreal arithmetic, nullity, division by zero, wheels, total
functions, extended real line, indeterminate forms, IEEE arithmetic.

---

## 1. Introduction

Division in a field is defined only for nonzero divisors. The expressions
$1/0$ and $0/0$ have no field-theoretic meaning: the first demands a solution to
$x\cdot 0 = 1$ (impossible, since $x\cdot 0=0$), and the second admits every $x$
as a solution to $x\cdot 0=0$ (hence none canonically). Yet in computation the
absence of a value is expensive: a partial operation forces every consumer of a
formula to guard against exceptional inputs, and a single unguarded division can
abort an otherwise valid calculation.

*Transreal arithmetic* responds by making division **total**. It adjoins to
$\mathbb{R}$ two signed infinities $\pm\infty$ and a nullity element $\Phi$, and
extends $+,\ \times,\ -(\cdot),$ and reciprocal so that every expression
evaluates. The design is deliberately reminiscent of IEEE 754 floating-point
arithmetic, whose infinities and `NaN` implement, in hardware, the same
philosophy of totality.

This paper is a self-contained account of the algebra and elementary analysis of
$\mathbb{T}$. Our contributions are:

1. A precise definition of the total operations on $\mathbb{T}$ (Section 2).
2. Monoid structure theorems and a sharp catalogue of the *failures* of the ring
   axioms, each with an explicit witness (Section 3).
3. A comparison theorem placing $\mathbb{T}$ relative to *wheels*: $\mathbb{T}$
   is not a wheel, and we identify exactly the two axioms it violates and why
   (Section 4).
4. A topological description of $\mathbb{T}$ and a survey of which real-analysis
   theorems survive, with the role of $\Phi$ as the value of the classical
   indeterminate forms made explicit (Section 5).

Throughout, "survives" means "holds verbatim or after an explicit, minimal
restriction," and every failure is accompanied by a concrete counterexample.

---

## 2. The transreal numbers

### 2.1 The carrier

**Definition 2.1 (Transreal numbers).**
The set of *transreal numbers* is
$$\mathbb{T} \;=\; \mathbb{R} \,\cup\, \{-\infty,\ \Phi,\ +\infty\},$$
where $-\infty,\ \Phi,\ +\infty$ are three symbols not in $\mathbb{R}$. The
elements $\pm\infty$ are the *signed infinities* and $\Phi$ is *nullity*. The
constants $0$ and $1$ are the usual real numbers.

We call an element *finite* if it lies in $\mathbb{R}$, *strict* if it lies in
$\mathbb{R}\cup\{\pm\infty\}$ (i.e. not nullity), and *infinite* if it is
$\pm\infty$.

### 2.2 Total operations

Transreal arithmetic is defined so that $1/0 = +\infty$ and $0/0 = \Phi$, and so
that $\Phi$ is a fixed point of every operation. We first give unary negation and
reciprocal, then addition and multiplication.

**Definition 2.2 (Negation).**
$$-x = \begin{cases} \text{usual } -x, & x\in\mathbb{R},\\ -\infty, & x=+\infty,\\ +\infty, & x=-\infty,\\ \Phi, & x=\Phi. \end{cases}$$

**Definition 2.3 (Reciprocal).**
$$x^{-1} = \tfrac{1}{x} = \begin{cases} \text{usual } 1/x, & x\in\mathbb{R}\setminus\{0\},\\ +\infty, & x=0,\\ 0, & x=+\infty,\\ 0, & x=-\infty,\\ \Phi, & x=\Phi. \end{cases}$$

**Definition 2.4 (Addition).** For $x,y\in\mathbb{T}$:
- If $x=\Phi$ or $y=\Phi$, then $x+y=\Phi$.
- If $x,y\in\mathbb{R}$, then $x+y$ is the usual real sum.
- $(+\infty)+y = +\infty$ for $y\in\mathbb{R}\cup\{+\infty\}$, and symmetrically
  $x+(+\infty)=+\infty$.
- $(-\infty)+y = -\infty$ for $y\in\mathbb{R}\cup\{-\infty\}$, and symmetrically.
- $(+\infty)+(-\infty) = (-\infty)+(+\infty) = \Phi.$

**Definition 2.5 (Multiplication).** For $x,y\in\mathbb{T}$:
- If $x=\Phi$ or $y=\Phi$, then $xy=\Phi$.
- If $x,y\in\mathbb{R}$, then $xy$ is the usual real product.
- For an infinite $x$ and a finite $y\neq 0$: $xy$ is $\pm\infty$ with sign the
  product of the signs of $x$ and $y$; symmetrically for finite $x$, infinite $y$.
- For infinite $x,y$: $xy$ is $\pm\infty$ with sign the product of the signs.
- $0\cdot(+\infty) = 0\cdot(-\infty) = (+\infty)\cdot 0 = (-\infty)\cdot 0 = \Phi.$

Subtraction and division are defined derivatively by $x-y := x+(-y)$ and
$x/y := x\cdot y^{-1}$. In particular $0/0 = 0\cdot 0^{-1} = 0\cdot(+\infty)=\Phi$
and $\infty-\infty = (+\infty)+(-\infty)=\Phi$, recovering the two motivating
identities.

**Proposition 2.6 (Totality).** Each of $+,\ \times,\ -(\cdot),\ (\cdot)^{-1}$ is
a total function on $\mathbb{T}$ (respectively $\mathbb{T}^2\to\mathbb{T}$ and
$\mathbb{T}\to\mathbb{T}$). Consequently every well-formed expression in these
operations denotes a unique element of $\mathbb{T}$.

*Proof.* Immediate from Definitions 2.2–2.5: every case of every operation is
listed, and the cases are exhaustive and mutually exclusive on the finite/
infinite/nullity trichotomy. $\square$

### 2.3 Nullity is absorbing

**Proposition 2.7 (Absorption).** For all $t\in\mathbb{T}$,
$$\Phi + t = \Phi,\qquad \Phi\cdot t = \Phi,\qquad -\Phi=\Phi,\qquad \Phi^{-1}=\Phi.$$
Hence any expression containing $\Phi$ as a subterm evaluates to $\Phi$.

*Proof.* The first two identities are the leading clauses of Definitions 2.4 and
2.5; the last two are clauses of Definitions 2.2 and 2.3. The final statement
follows by induction on expression structure. $\square$

Proposition 2.7 says $\Phi$ is a *bottom* element: it is a fixed point of every
operation and propagates through composition. This is exactly the behavior of
`NaN` in IEEE 754.

---

## 3. Monoid structure and the collapse of the ring axioms

### 3.1 What survives: commutative monoids

**Theorem 3.1 (Monoid structure).** $(\mathbb{T},+,0)$ and $(\mathbb{T},\times,1)$
are commutative monoids. That is, each operation is associative and commutative,
with identity $0$ (resp. $1$).

*Proof sketch.* Commutativity is visible from the symmetry of Definitions 2.4–
2.5. The identities: $0+t=t$ and $1\cdot t=t$ hold on $\mathbb{R}$ by the field
axioms, on $\pm\infty$ by the "finite + infinite" and "finite $\times$ infinite"
clauses (with $0$ finite, $1$ finite and nonzero), and on $\Phi$ by absorption.
Associativity is checked on the finite/infinite/$\Phi$ cases. When any argument
is $\Phi$, both groupings give $\Phi$ (Prop. 2.7). When all arguments are strict,
one uses the sign bookkeeping: for addition, a sum of strict elements is $\Phi$
iff both $+\infty$ and $-\infty$ occur among the summands, a condition symmetric
under regrouping; for multiplication, a product of strict elements is $\Phi$ iff
some factor is $0$ and some factor is infinite, again regrouping-invariant, and
otherwise the sign is the product of signs and the magnitude the extended
product, both associative. $\square$

Thus the additive and multiplicative *worlds*, taken separately, remain as
orderly as one could ask. The damage is confined to (i) inverses and (ii) the
interaction of the two operations.

### 3.2 What breaks: three failures

**Theorem 3.2 (No additive inverse for infinity).** There is no $t\in\mathbb{T}$
with $(+\infty)+t=0$. Consequently $(\mathbb{T},+,0)$ is not a group, and
$\mathbb{T}$ is not a ring.

*Proof.* By Definition 2.4, for every $t$:
$$(+\infty)+t = \begin{cases} +\infty, & t\in\mathbb{R}\cup\{+\infty\},\\ \Phi, & t\in\{-\infty,\Phi\}. \end{cases}$$
The value is always in $\{+\infty,\Phi\}$, never $0$. $\square$

**Theorem 3.3 (Failure of annihilation).** The law $0\cdot x=0$ fails:
$$0\cdot(+\infty)=\Phi\neq 0.$$

*Proof.* The last clause of Definition 2.5. $\square$

**Theorem 3.4 (Failure of distributivity).** The distributive law
$a(b+c)=ab+ac$ fails on $\mathbb{T}$. An explicit witness is
$a=+\infty,\ b=1,\ c=-\infty$:
$$a(b+c) = (+\infty)\bigl(1+(-\infty)\bigr) = (+\infty)(-\infty) = -\infty,$$
$$ab+ac = (+\infty)\cdot 1 + (+\infty)(-\infty) = (+\infty)+(-\infty) = \Phi,$$
and $-\infty \neq \Phi$.

*Proof.* Direct evaluation using $1+(-\infty)=-\infty$ (Def. 2.4),
$(+\infty)(-\infty)=-\infty$ and $(+\infty)\cdot 1=+\infty$ (Def. 2.5), and
$(+\infty)+(-\infty)=\Phi$ (Def. 2.4). The two results are distinct strict/
nullity elements. $\square$

Theorems 3.2–3.4 are the core negative results. They show the failure is not a
single blemish but a systematic collapse: inverses, annihilation, and
distributivity — the three axioms that turn two monoids into a ring — all fail,
each at the interface between the finite world and the newly adjoined edges.

**Remark 3.5 (Why distributivity is the deepest failure).** Theorem 3.2 can be
read as "$\pm\infty$ and $\Phi$ are simply new, inverse-less elements," and
Theorem 3.3 as "the annihilator is disturbed at the edges." Both concern single
operations. Theorem 3.4, by contrast, concerns the *bond* between addition and
multiplication, and it is this bond whose failure makes ordinary algebraic
manipulation — expanding brackets, factoring, clearing denominators — unsound on
$\mathbb{T}$ without side conditions. It also foreshadows the wheel comparison of
Section 4, where a *repaired* distributive law reappears.

---

## 4. Transreals versus wheels

Total division has an established abstract home: the *wheel*, introduced to
axiomatize algebraic structures in which reciprocal is a total operation. We
recall the definition, then locate $\mathbb{T}$ relative to it.

### 4.1 Wheels

**Definition 4.1 (Wheel).** A *wheel* is a structure
$(H,\ 0,\ 1,\ +,\ \cdot,\ /)$ in which $(H,+,0)$ and $(H,\cdot,1)$ are commutative
monoids, $/$ is a unary operation, and the following hold for all
$x,y,z\in H$:
1. $/(xy) = /x\cdot/y$ and $/1=1$; and $/$ is an *involution*: $//x = x$;
2. $(x+y)z + 0z = xz + yz$ (distributivity, corrected by a $0z$ term);
3. $(x + yz)/y = x/y + z + 0/y$;
4. $0\cdot 0 = 0$;
5. $(x + 0y)z = xz + 0y$;
6. $/(x + 0y) = /x + 0y$;
7. $0/0 + x = 0/0$.

Writing $\bot := 0/0$, axiom 7 says $\bot$ is a bottom element absorbing addition
(and, via the other axioms, every operation) — the wheel's analogue of $\Phi$.
The canonical example is the *wheel of fractions* of a commutative ring $R$,
obtained from $R\times R$ by a quotient that formally adjoins $/0$; for
$R=\mathbb{R}$ this produces the *projectively extended reals*
$\mathbb{R}\cup\{\infty,\bot\}$ with a **single, unsigned** infinity $\infty=1/0$.

Two features of wheels will be decisive. First, in the wheel of fractions one
computes
$$\infty + \infty = \bot,$$
because $\infty=(1,0)$ and $(1,0)+(1,0)=(1\cdot0+1\cdot0,\ 0\cdot0)=(0,0)=\bot$.
Second, reciprocal is a genuine involution: $//x=x$ for *all* $x$ by axiom 1.

### 4.2 The transreals are not a wheel

**Theorem 4.2 (Signed-infinity obstruction).** In $\mathbb{T}$,
$(+\infty)+(+\infty)=+\infty$. In any wheel, $\infty+\infty=\bot$. Hence
$\mathbb{T}$, with its addition, does not satisfy the additive law that a wheel's
infinity obeys; identifying $\pm\infty$ with a single $\infty$ and $\Phi$ with
$\bot$ does not turn $\mathbb{T}$ into a wheel.

*Proof.* $(+\infty)+(+\infty)=+\infty$ is the "like infinities" clause of
Definition 2.4. The wheel computation $\infty+\infty=\bot$ is the display above,
valid in the wheel of fractions and forced by the wheel axioms. Any structure
map $\mathbb{T}\to W$ into a wheel sending $\pm\infty\mapsto\infty$ and
$\Phi\mapsto\bot$ would have to send $+\infty=(+\infty)+(+\infty)$ to
$\infty+\infty=\bot$, contradicting $+\infty\mapsto\infty\neq\bot$. $\square$

**Theorem 4.3 (Non-involution of reciprocal).** The transreal reciprocal is
total but is *not* an involution: it satisfies $\bigl(x^{-1}\bigr)^{-1}=x$ for
$x\in\mathbb{R}\cup\{0,+\infty\}$ and for $x=\Phi$, but it fails at $x=-\infty$,
$$\bigl((-\infty)^{-1}\bigr)^{-1} = (0)^{-1} = +\infty \neq -\infty.$$
Since wheels require $//x=x$ for all $x$ (Definition 4.1(1)), $\mathbb{T}$ is not
a wheel.

*Proof.* For finite nonzero $x$, $\bigl(x^{-1}\bigr)^{-1}=x$ by the real field
axioms; $\Phi$ is a fixed point (Prop. 2.7); $0^{-1}=+\infty$ and
$(+\infty)^{-1}=0$ give the two identities $\bigl(0^{-1}\bigr)^{-1}=
(+\infty)^{-1}=0$ and $\bigl((+\infty)^{-1}\bigr)^{-1}=0^{-1}=+\infty$. But
$(-\infty)^{-1}=0$ and $0^{-1}=+\infty$, so double reciprocal sends $-\infty$ to
$+\infty$. The map is total (Prop. 2.6) yet not idempotent-under-squaring, i.e.
not an involution. $\square$

### 4.3 Interpretation

Theorems 4.2 and 4.3 are complementary. A wheel purchases clean algebra —
involutive division and a single, uniformly-behaved bottom — by **forgetting the
direction of infinity**: it bends $+\infty$ and $-\infty$ together, so
$\infty+\infty$ collapses to the hub and reciprocal is symmetric. The transreals
make the opposite choice: they **retain signed, directed infinities**, which is
what a numerical computation tracking the direction of an overflow requires, and
they pay for that memory with exactly the two failures above — the additive law
$\infty+\infty=\infty$ that no wheel can have, and the sign leak
$1/(1/(-\infty))=+\infty$ that breaks involution.

Thus the correct slogan is not "the transreals are a wheel" but rather: **the
wheel and the transreals are two principled, inequivalent completions of the
reals to a total-division structure**, and Theorems 4.2–4.3 pinpoint precisely
where and why they diverge. The wheel is the symmetric algebraic ideal; the
transreals are the direction-aware computational realization, mirrored in the
signed infinities of IEEE 754. Notably, the *repaired* distributive law of a
wheel, $(x+y)z+0z=xz+yz$, is precisely the kind of corrected identity one must
use in place of the failed Theorem 3.4 when reasoning on either total system.

---

## 5. Topology and surviving analysis

### 5.1 The shape of $\mathbb{T}$

Equip $\mathbb{R}\cup\{\pm\infty\}$ with the order topology of the extended real
line, under which it is homeomorphic to the compact interval $[-\infty,+\infty]$.
Adjoin $\Phi$ as an isolated point.

**Theorem 5.1 (Topology of $\mathbb{T}$).**
$$\mathbb{T} \;\cong\; [-\infty,+\infty]\ \sqcup\ \{\Phi\},$$
a disjoint union of a compact connected interval with a single isolated point.
Consequently $\mathbb{T}$ is compact and Hausdorff but not connected; its
connected components are $[-\infty,+\infty]$ and $\{\Phi\}$.

*Proof sketch.* $[-\infty,+\infty]$ is compact and connected as a closed
interval. Adjoining an isolated point preserves compactness (a finite union of
compacts) and Hausdorffness, and creates a second clopen component. $\square$

### 5.2 Continuity of the operations

**Theorem 5.2 (Continuity away from indeterminate forms).** Restricted to the
strict elements $\mathbb{R}\cup\{\pm\infty\}=[-\infty,+\infty]$:
- addition is continuous except at the pairs $(+\infty,-\infty)$ and
  $(-\infty,+\infty)$;
- multiplication is continuous except at the pairs $(0,\pm\infty)$ and
  $(\pm\infty,0)$;

and at exactly those excepted pairs the transreal operation returns $\Phi$.

*Proof sketch.* On $[-\infty,+\infty]$ the extended-arithmetic limits are the
standard ones: $x+y\to\pm\infty$ whenever a summand tends to $\pm\infty$ and the
other does not tend to the opposite infinity, and $xy\to\pm\infty$ whenever a
factor tends to $\pm\infty$ and the other stays bounded away from $0$. The only
pairs at which the multivalued limit disagrees along different approaches are
$\infty-\infty$ (for $+$) and $0\cdot\infty$ (for $\times$); these are the
classical indeterminate forms. Definitions 2.4–2.5 assign $\Phi$ at precisely
those pairs. $\square$

**Corollary 5.3 (Nullity names the indeterminate forms).** The nullity value
$\Phi$ occurs, among strict inputs, exactly as the transreal evaluation of the
indeterminate forms $\infty-\infty$ and $0\cdot\infty$. Transreal arithmetic does
not *resolve* these forms (their genuine limits are approach-dependent); it
*totalizes* them by assigning the dedicated value $\Phi$.

### 5.3 Which theorems of analysis survive

Theorem 5.1 furnishes a clean litmus test: a classical theorem survives on
$\mathbb{T}$ to the extent that it survives on the compact connected interval
$[-\infty,+\infty]$, and it is obstructed to the extent that it relies on global
connectedness (which $\Phi$ breaks) or on group/field arithmetic (which
Section 3 breaks).

**Survives (on the extended segment $[-\infty,+\infty]$).**
- *Compactness.* $[-\infty,+\infty]$ is compact; hence any continuous
  $f:[-\infty,+\infty]\to\mathbb{R}$ attains a maximum and a minimum (Extreme
  Value Theorem).
- *Intermediate Value Theorem.* $[-\infty,+\infty]$ is connected, so a continuous
  real-valued function on it takes every intermediate value.
- *Determinate limit laws.* All limit laws for sums, products, and quotients hold
  whenever the relevant form is not $\infty-\infty$ or $0\cdot\infty$; these are
  exactly the "determinate forms" of elementary calculus, now literally the
  domains of continuity in Theorem 5.2.

**Fails or requires restriction.**
- *Global connectedness / IVT across $\Phi$.* Because $\Phi$ is isolated
  (Theorem 5.1), $\mathbb{T}$ is disconnected; no continuous path joins a finite
  number to $\Phi$, so any statement requiring the whole system to be one
  connected piece must be restricted to $[-\infty,+\infty]$.
- *Algebraic identities from Section 3.* Any analytic argument that silently uses
  additive inverses ($x-x=0$), annihilation ($0\cdot x=0$), or distributivity is
  unsound at the edges. In particular telescoping, factoring, and "multiplying
  out" limits require the inputs to be finite (or the wheel-corrected identities
  of Section 4).
- *Indeterminate forms.* $\infty-\infty$ and $0\cdot\infty$ do not acquire true
  limits; they acquire the value $\Phi$, which correctly *flags* rather than
  resolves the indeterminacy.

The upshot is a clean division of labor. On the connected interior
$[-\infty,+\infty]$, transreal analysis is ordinary extended-real analysis, and
the classical compactness/connectedness theorems hold. Off to the side, $\Phi$
serves as a total, propagating marker for the two indeterminate forms, converting
what would be undefined behavior into inspectable data.

---

## 6. Algorithms

The totality of $\mathbb{T}$ makes it directly executable. We record the two
central procedures.

**Algorithm A (Transreal evaluation).** Given an arithmetic expression tree over
$+,-,\times,{}^{-1}$ with transreal leaves, evaluate bottom-up using the case
tables of Definitions 2.2–2.5. Because each operation is total (Prop. 2.6) and
$\Phi$ is absorbing (Prop. 2.7), the traversal never faults and any $\Phi$
subresult short-circuits its ancestors to $\Phi$. Complexity: $O(n)$ operations
for a tree of $n$ nodes, each an $O(1)$ table lookup.

**Algorithm B (Axiom auditor).** Given a candidate algebraic law as a term
identity $L(x_1,\dots,x_k)=R(x_1,\dots,x_k)$, quantify over the finite test set
$S=\{-2,-1,0,1,2,-\infty,\Phi,+\infty\}$ (which includes representatives of every
sign class and every adjoined element) and evaluate both sides with Algorithm A
for all $|S|^k$ assignments. Report the law as *refuted* with the first
disagreeing assignment, or as *not refuted on $S$*. This procedure discovers the
witnesses of Theorems 3.2–3.4 automatically; e.g. it returns
$(a,b,c)=(+\infty,1,-\infty)$ for distributivity.

---

## 7. Applications

**Fault-free numerical pipelines.** A computation expressed entirely in total
operations cannot raise a division-by-zero exception. Transient anomalies flow
around the computation; genuinely fatal ones propagate to the output as $\Phi$
and are detected by a single terminal test. This is the design rationale shared
with IEEE 754 infinities and `NaN`.

**Symbolic bookkeeping of indeterminate forms.** Corollary 5.3 lets a computer
algebra or limit-evaluation routine carry $\infty-\infty$ and $0\cdot\infty$ as
first-class values ($\Phi$) rather than as control-flow exceptions, deferring the
harder limit analysis to where it is actually needed.

**Foundational clarification.** Theorems 3.2–3.4 make explicit the trade-off
that motivates the field-theoretic prohibition on division by zero: totality and
the ring axioms are jointly unrealizable on any extension of $\mathbb{R}$ by
$1/0$. The prohibition is thus a design choice (retain the ring), not a logical
necessity.

---

## 8. Discussion and future work

Transreal arithmetic buys totality at the cost of the ring axioms, and it differs
from the wheel — the standard total-division structure — in two crisp,
complementary ways: it keeps infinity *signed* (Theorem 4.2) and therefore cannot
keep reciprocal *involutive* (Theorem 4.3). The topological picture (Theorem 5.1)
then cleanly separates the surviving analysis (everything on the connected
extended interval) from the obstructions ($\Phi$'s disconnection and the broken
algebra).

Several directions remain open. (1) *A corrected calculus.* One can seek the
weakest side conditions under which the Section 3 identities hold, mirroring the
wheel's corrected distributive law, and rebuild differentiation/integration on
$\mathbb{T}$ with those conditions built in. (2) *Ordered structure.* Extending
the order of $[-\infty,+\infty]$ over $\Phi$ (as an incomparable element) and
studying monotonicity and suprema. (3) *Categorical placement.* Characterizing
the transreals and wheels as different universal objects among total-division
extensions of a field, making Theorems 4.2–4.3 instances of a universal-property
divergence. (4) *Machine arithmetic.* Formalizing the precise relationship
between $\mathbb{T}$ (single $0$, $1/0=+\infty$) and IEEE 754 (signed zeros,
$1/{+0}=+\infty$, $1/{-0}=-\infty$), whose signed-zero convention is exactly what
would repair Theorem 4.3.

---

## 9. Conclusion

We have given a self-contained treatment of transreal arithmetic: total
operations extending $\mathbb{R}$ with $\pm\infty$ and nullity $\Phi$; the
survival of commutative-monoid structure alongside the systematic failure of the
ring axioms (no additive inverse for $\infty$, $0\cdot\infty=\Phi\neq 0$, and the
failure of distributivity witnessed by $(+\infty)(1+(-\infty))\neq(+\infty)\cdot
1+(+\infty)(-\infty)$); the sharp separation from wheels via signed infinity and
non-involutive reciprocal; and a topological account pinpointing which theorems
of analysis survive and why. The recurring moral is that totality is achievable
and useful, but never free: each convenience at the edges is paid for by a named,
locatable law that must be given up.
