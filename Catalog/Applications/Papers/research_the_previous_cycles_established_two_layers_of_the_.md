# The Hodge–Deligne E-Polynomial as a Bridge to Arithmetic: Functional Equations for Duality and Mirror Symmetry

## Abstract

We develop, over an arbitrary field $K$, the elementary algebraic theory of the
two-variable **Hodge–Deligne E-polynomial** attached to an abstract Hodge diamond,
and we prove two genuine *functional equations* that encode the two principal
symmetries of complex algebraic geometry. The first, the **Serre/Poincaré
functional equation**, states that under Serre duality of the diamond
$X$, $E(X; u, v) = (uv)^{n} E(X; u^{-1}, v^{-1})$, where $n$ is the complex
dimension. The second, the **mirror functional equation**, holds unconditionally:
$E(\mathrm{mirror}\,X; u, v) = (-1)^{n} u^{n} E(X; u^{-1}, v)$, where the mirror
involution acts on Hodge numbers by $(p,q) \mapsto (n-p, q)$. Specialising at
$u = v = 1$ — where the E-polynomial collapses to the topological Euler
characteristic $\chi(X)$ — recovers the classical mirror sign law
$\chi(\mathrm{mirror}\,X) = (-1)^{n}\chi(X)$, the numerical fingerprint of mirror
symmetry observed by string theorists. We also record the mirror-invariance of the
total Hodge dimension and the involutivity of the mirror operation on the support.
The decisive technical observation is that both geometric symmetries are
reflections $j \mapsto n - j$ of an index range, so a single combinatorial engine —
reversal of a finite summation range — drives every functional equation; the
prefactors $(uv)^n$, $u^n$ and the signs $(-1)^n$ are exactly the bookkeeping of the
induced exponent shift $u^n \cdot u^{-p} = u^{n-p}$ and parity shift
$(-1)^{(n-p)+(n-q)} = (-1)^{2n}(-1)^{p+q}$. All results are formalised and
machine-checked, depending only on the standard foundational axioms.

**Keywords.** Hodge–Deligne polynomial, E-polynomial, Hodge diamond, Serre
duality, Poincaré duality, mirror symmetry, Calabi–Yau, Euler characteristic,
functional equation.

---

## 1. Introduction

### 1.1 Motivation

To a smooth projective complex variety $X$ of complex dimension $n$ one attaches its
**Hodge numbers** $h^{p,q}(X) = \dim_{\mathbb C} H^q(X, \Omega_X^p)$, the dimensions of
the Dolbeault cohomology groups. Organised into the **Hodge diamond**, these numbers
are among the most refined topological-analytic invariants of $X$. Two symmetries
constrain the diamond profoundly:

1. **Serre/Poincaré duality**, $h^{p,q} = h^{n-p, n-q}$, the central $180°$ symmetry
   of the diamond reflecting Poincaré duality on cohomology.
2. **Mirror symmetry**, the conjectural pairing of Calabi–Yau manifolds $X
   \leftrightarrow X^\vee$ under which $h^{p,q}(X^\vee) = h^{n-p,q}(X)$, exchanging
   complex-structure and Kähler moduli. Discovered in string theory, mirror
   symmetry has driven a generation of advances in enumerative geometry.

The **Hodge–Deligne E-polynomial** (a specialisation of the Deligne–Hodge mixed
$E$-polynomial of a variety) packages the diamond into a single object,
$$
E(X; u, v) = \sum_{p,q} (-1)^{p+q} h^{p,q} u^p v^q,
$$
which is multiplicative on products, additive on stratifications, and specialises to
the Euler characteristic, the signature, and the Poincaré polynomial. It is the
natural carrier of the diamond's symmetries.

This paper isolates the *purely algebraic skeleton* of these symmetries. We work
with an abstract Hodge diamond — a dimension $n$ together with an arbitrary integer
function $h$ — and over an arbitrary field $K$. Stripping away the geometry reveals
that the symmetries are reflections of a summation index, and that their
polynomial-level consequences are exact functional equations whose classical
numerical avatars are mere specialisations.

### 1.2 Contributions

- A field-independent definition of the E-polynomial, Euler characteristic, and
  total dimension of an abstract Hodge diamond (§2).
- The specialisation identity $E(X;1,1) = \chi(X)$ (Theorem 3.1).
- The **mirror functional equation**, unconditional (Theorem 4.1).
- The **Serre functional equation**, under the Serre-duality hypothesis
  (Theorem 5.1).
- The **mirror sign law** $\chi(\mathrm{mirror}\,X) = (-1)^n \chi(X)$ as a corollary
  (Theorem 4.2), together with total-dimension invariance and involutivity (§6).
- Identification of a single combinatorial engine — range reversal of a finite sum —
  underlying all the functional equations (§7).

---

## 2. Definitions

Throughout, $K$ denotes a field and $n, p, q$ denote natural numbers.

**Definition 2.1 (Hodge diamond).** A *Hodge diamond* is a pair $X = (n, h)$ where
$n \in \mathbb N$ is the *complex dimension* and $h : \mathbb N \times \mathbb N \to
\mathbb Z$ assigns to each $(p,q)$ the *Hodge number* $h^{p,q} := h(p,q)$. Only the
values with $0 \le p, q \le n$ are regarded as meaningful; values outside this range
are padding and never enter any sum below.

> *Design note.* Defining $h$ on all of $\mathbb N \times \mathbb N$ rather than on a
> finite index type $\mathrm{Fin}(n+1)^2$ avoids dependent-type friction in the
> formalisation, at the cost that purely definitional identities (such as
> involutivity of the mirror) hold only on the support $\{p,q \le n\}$. We therefore
> state such identities pointwise on the support or at the level of the E-polynomial.

**Definition 2.2 (E-polynomial).** For $u, v \in K$, the *Hodge–Deligne
E-polynomial* of $X = (n,h)$ is
$$
E(X; u, v) \;=\; \sum_{p=0}^{n} \sum_{q=0}^{n} (-1)^{p+q}\, (h^{p,q})_K\, u^p v^q
\;\in\; K,
$$
where $(\,\cdot\,)_K : \mathbb Z \to K$ is the canonical ring homomorphism.

**Definition 2.3 (Euler characteristic).** The *Euler characteristic* of $X$ is the
integer
$$
\chi(X) \;=\; \sum_{p=0}^{n} \sum_{q=0}^{n} (-1)^{p+q}\, h^{p,q} \;\in\; \mathbb Z.
$$

**Definition 2.4 (Total dimension).** The *total Hodge dimension* (total Betti
number) of $X$ is
$$
b(X) \;=\; \sum_{p=0}^{n} \sum_{q=0}^{n} h^{p,q} \;\in\; \mathbb Z.
$$

**Definition 2.5 (Mirror).** The *mirror* of $X = (n, h)$ is the Hodge diamond
$\mathrm{mirror}\,X = (n, h')$ with
$$
h'^{\,p,q} \;=\; h^{\,n-p,\; q},
$$
the involution $(p,q) \mapsto (n-p, q)$ on Hodge numbers. (Here $n - p$ is
truncated natural subtraction, harmless on the support.)

**Definition 2.6 (Serre duality).** A diamond $X = (n,h)$ is *Serre-dual*,
written $\mathrm{SerreDual}(X)$, if
$$
\forall\, p, q \le n : \quad h^{p,q} = h^{\,n-p,\; n-q}.
$$

---

## 3. The E-polynomial specialises to the Euler characteristic

**Theorem 3.1 (Euler specialisation).** For any Hodge diamond $X$ and any field
$K$,
$$
E(X; 1, 1) \;=\; (\chi(X))_K.
$$

*Proof sketch.* Setting $u = v = 1$ kills all powers $u^p v^q = 1$, leaving
$E(X;1,1) = \sum_{p,q} (-1)^{p+q}(h^{p,q})_K$. The integer-to-$K$ cast is a ring
homomorphism, hence commutes with the finite double sum and with the sign
$(-1)^{p+q}$; pushing it outside yields $(\sum_{p,q}(-1)^{p+q} h^{p,q})_K =
(\chi(X))_K$. $\qquad\blacksquare$

This theorem is the linchpin of the paper: every functional equation proved below
casts, upon the substitution $u = v = 1$, a numerical shadow that is a classical
statement about $\chi$.

---

## 4. The mirror functional equation

**Theorem 4.1 (Mirror functional equation).** For any Hodge diamond $X$ of
dimension $n$, any field $K$, and any $u \in K^\times$ (i.e. $u \ne 0$),
$$
E(\mathrm{mirror}\,X; u, v) \;=\; (-1)^{n}\, u^{n}\, E\!\left(X; u^{-1}, v\right).
$$

*Proof sketch.* By Definitions 2.2 and 2.5,
$$
E(\mathrm{mirror}\,X; u, v) = \sum_{p=0}^{n}\sum_{q=0}^{n} (-1)^{p+q} (h^{n-p,q})_K\, u^p v^q.
$$
Reverse the inner $p$-summation by the substitution $p \mapsto n - p$ (range
reversal of a finite sum; the bijection $p \leftrightarrow n-p$ of $\{0,\dots,n\}$).
The term indexed by the new variable $p$ becomes
$$
(-1)^{(n-p)+q} (h^{p,q})_K\, u^{\,n-p} v^q.
$$
Now factor: using $u \ne 0$, write $u^{\,n-p} = u^n \cdot u^{-p}$ (valid since
$u^{n-p}\cdot u^{p} = u^n$), and split the sign via $(-1)^{(n-p)+q} = (-1)^n
(-1)^{-p+q} = (-1)^n (-1)^{p+q}$ (because $(-1)^{-p} = (-1)^p$). Pulling the global
factors $(-1)^n u^n$ outside both sums leaves
$$
(-1)^n u^n \sum_{p,q} (-1)^{p+q} (h^{p,q})_K (u^{-1})^p v^q = (-1)^n u^n\, E(X; u^{-1}, v).
\qquad\blacksquare
$$

The hypothesis $u \ne 0$ is genuinely needed (we invert $u$); no hypothesis on the
diamond is required — the equation is *unconditional*.

**Theorem 4.2 (Mirror sign law).** For any Hodge diamond $X$ of dimension $n$,
$$
\chi(\mathrm{mirror}\,X) \;=\; (-1)^{n}\, \chi(X).
$$

*Proof sketch.* Two routes. (i) Specialise Theorem 4.1 at $u = v = 1$ over
$K = \mathbb Q$ (where $1 \ne 0$): the left side becomes $(\chi(\mathrm{mirror}\,X))_K$
by Theorem 3.1, the right side $(-1)^n \cdot 1 \cdot (\chi(X))_K$, and injectivity of
$\mathbb Z \hookrightarrow \mathbb Q$ removes the cast. (ii) Directly: in
$\chi(\mathrm{mirror}\,X) = \sum_{p,q}(-1)^{p+q} h^{n-p,q}$ reverse the $p$-index; the
parity shift $(-1)^{(n-p)+q} = (-1)^n (-1)^{p+q}$ produces the global sign $(-1)^n$
in front of $\chi(X)$. $\qquad\blacksquare$

**Interpretation.** For even $n$, mirror preserves the Euler characteristic; for odd
$n$ it negates it. Calabi–Yau threefolds have $n = 3$, so $\chi(X^\vee) = -\chi(X)$ —
the celebrated sign flip. For the quintic threefold, $\chi = -200$ and its mirror has
$\chi = +200$ (see §8).

---

## 5. The Serre functional equation

**Theorem 5.1 (Serre/Poincaré functional equation).** Let $X$ be a Hodge diamond of
dimension $n$ satisfying $\mathrm{SerreDual}(X)$. Then for any field $K$ and any
$u, v \in K^\times$,
$$
E(X; u, v) \;=\; (u v)^{n}\, E\!\left(X; u^{-1}, v^{-1}\right).
$$

*Proof sketch.* The cleanest derivation chains the mirror equation with Serre
duality. Apply Theorem 4.1 to the diamond $\mathrm{mirror}\,X$ in the variable $u$;
this reflects the $p$-index. Separately reflect the $q$-index by range reversal,
producing the symmetric prefactor $(uv)^n$ and the parity factor $(-1)^{2n} = 1$.
The Serre-duality hypothesis $h^{p,q} = h^{n-p,n-q}$ is exactly what identifies the
doubly reflected coefficient $h^{n-p,n-q}$ with $h^{p,q}$, closing the identity.
Concretely, expanding $(uv)^n E(X; u^{-1}, v^{-1})$ and substituting $p \mapsto n-p$,
$q \mapsto n-q$:
$$
(uv)^n \sum_{p,q} (-1)^{p+q} h^{p,q} u^{-p} v^{-q}
= \sum_{p,q} (-1)^{p+q} h^{p,q} u^{n-p} v^{n-q}
= \sum_{p,q} (-1)^{(n-p)+(n-q)} h^{n-p,n-q} u^{p} v^{q},
$$
and $(-1)^{(n-p)+(n-q)} = (-1)^{2n}(-1)^{p+q} = (-1)^{p+q}$, while Serre duality gives
$h^{n-p,n-q} = h^{p,q}$, recovering $E(X;u,v)$. $\qquad\blacksquare$

This is a *functional equation* in the strict sense — a self-symmetry of $E$ under
$u \mapsto u^{-1}$, $v \mapsto v^{-1}$ — directly analogous to the functional
equations of zeta and $L$-functions, where Poincaré duality plays the same role.

---

## 6. Structural corollaries

**Proposition 6.1 (Mirror is involutive on the support).** For all $p, q \le n$,
$$
(\mathrm{mirror}(\mathrm{mirror}\,X))^{p,q} = h^{p,q}.
$$
*Proof sketch.* $(\mathrm{mirror}^2 X)^{p,q} = (\mathrm{mirror}\,X)^{n-p,q} =
h^{n-(n-p),q} = h^{p,q}$, using $n-(n-p) = p$ for $p \le n$ (where natural
subtraction behaves). Equivalently, $E(\mathrm{mirror}^2 X; u, v) = E(X; u, v)$ by
applying Theorem 4.1 twice. $\qquad\blacksquare$

**Proposition 6.2 (Total-dimension invariance).**
$b(\mathrm{mirror}\,X) = b(X).$
*Proof sketch.* $b(\mathrm{mirror}\,X) = \sum_{p,q} h^{n-p,q}$; range-reversing the
$p$-index is a bijection of $\{0,\dots,n\}$, so the (sign-free) sum is unchanged.
$\qquad\blacksquare$

**Calabi–Yau data.** The mirror involution lifts to genuine Calabi–Yau data:
a Calabi–Yau diamond is one with the trivial-canonical normalisation
($h^{n,0} = h^{0,0} = 1$ and the Serre symmetry), and mirroring sends Calabi–Yau
data to Calabi–Yau data, exchanging the moduli-counting numbers $h^{1,1}$ and
$h^{n-1,1}$. For threefolds this is precisely the $h^{1,1} \leftrightarrow h^{2,1}$
exchange defining a mirror pair.

---

## 7. The unifying combinatorial principle

The proofs of Theorems 4.1, 4.2, 5.1 and Propositions 6.1–6.2 all reduce to one
fact: a finite sum over $\{0, 1, \dots, n\}$ is invariant under the *reversal*
$j \mapsto n - j$,
$$
\sum_{j=0}^{n} f(j) \;=\; \sum_{j=0}^{n} f(n - j).
$$
This is `Finset.sum_range_reflect` in the formal development. Every geometric
symmetry in this paper is a reflection of one or both indices, and the entire
"content" of each functional equation is the bookkeeping induced by reflection:

| Quantity | Under $p \mapsto n - p$ |
|---|---|
| Exponent $u^p$ | $u^{n-p} = u^n \cdot u^{-p}$ (needs $u \ne 0$) |
| Sign $(-1)^{p+q}$ | $(-1)^{(n-p)+q} = (-1)^n (-1)^{p+q}$ |
| Hodge number $h^{p,q}$ (mirror) | $h^{n-p,q}$ — *the definition of mirror* |
| Hodge number $h^{p,q}$ (Serre, both indices) | $h^{n-p,n-q} = h^{p,q}$ — *the hypothesis* |

The mirror equation reflects only $p$ (hence $u^n$, $(-1)^n$, $u^{-1}$ alone); the
Serre equation reflects both (hence $(uv)^n$, $(-1)^{2n}=1$, both inverted). This is
the single sentence that explains why all the prefactors look the way they do.

---

## 8. Worked numerical examples

We illustrate with three standard diamonds. (Numerical verification appears in the
accompanying `demo.py`.)

**Elliptic curve ($n=1$).** Diamond $h^{0,0}=h^{1,1}=1$, $h^{1,0}=h^{0,1}=1$.
$$
E(X; u, v) = 1 - u - v + uv = (1-u)(1-v), \qquad \chi(X) = 1 - 1 - 1 + 1 = 0.
$$
Mirror equation: $E(\mathrm{mirror}\,X;u,v) = (1-u)(1-v) = -u \cdot E(X;u^{-1},v)$
since $E(X;u^{-1},v) = (1-u^{-1})(1-v) = -u^{-1}(1-u)(1-v)$. Sign law: $\chi(\mathrm{mirror}) = (-1)^1 \cdot 0 = 0$. ✓

**K3 surface ($n=2$).** Diamond $h^{0,0}=h^{2,2}=h^{2,0}=h^{0,2}=1$, $h^{1,1}=20$,
others $0$.
$$
\chi(X) = 1 + 1 + 1 + 20 + 1 = 24.
$$
This is Serre-dual; the Serre functional equation holds, and the mirror sign law
gives $\chi(\mathrm{mirror}) = (-1)^2 \cdot 24 = 24$ (Euler number preserved in even
dimension). ✓

**Quintic Calabi–Yau threefold ($n=3$).** The nonzero Hodge numbers are
$h^{0,0}=h^{3,3}=h^{3,0}=h^{0,3}=1$, $h^{1,1}=h^{2,2}=1$, $h^{2,1}=h^{1,2}=101$.
$$
\chi(X) = 2(h^{1,1} - h^{2,1}) = 2(1 - 101) = -200.
$$
The mirror operation $(p,q)\mapsto(3-p,q)$ sends $h^{1,1} = 1$ to position $(1,1)$ of
the mirror, drawing its value from $h^{3-1,1} = h^{2,1} = 101$; thus the mirror has
$h^{1,1}=101$, $h^{2,1}=1$ — *the mirror quintic*. Its Euler characteristic is
$2(101-1) = +200 = (-1)^3 \cdot (-200)$, exactly the sign law. ✓

These three examples span the even/odd dichotomy and recover, from the abstract
framework alone, the textbook Euler numbers $0$, $24$, and $\pm 200$.

---

## 8.5 Detailed verification of the mirror equation for the elliptic curve

It is instructive to trace the mirror functional equation symbol-by-symbol on the
simplest nontrivial case, $n = 1$, to see the reflection engine at work without any
clutter. The elliptic-curve diamond has $h^{0,0}=h^{1,1}=h^{1,0}=h^{0,1}=1$, so
$$
E(X; u, v) = (-1)^0 \cdot 1 + (-1)^1 u + (-1)^1 v + (-1)^2 uv = 1 - u - v + uv = (1-u)(1-v).
$$
The mirror sends $h^{p,q} \mapsto h^{1-p,q}$, which for this symmetric diamond again
yields all four entries equal to $1$; hence $E(\mathrm{mirror}\,X;u,v) = (1-u)(1-v)$
as well. The right-hand side of Theorem 4.1 is
$$
(-1)^1 u^1 E(X; u^{-1}, v) = -u\,(1 - u^{-1})(1 - v) = -u\cdot u^{-1}(u-1)(1-v) = -(u-1)(1-v) = (1-u)(1-v),
$$
where the cancellation $u \cdot u^{-1} = 1$ uses precisely the hypothesis $u \ne 0$.
Both sides equal $(1-u)(1-v)$, confirming the equation. Notice how the prefactor
$-u$ exactly absorbs the exponent shift from $u^{-1}$ back to $u^0$ and the parity flip
from the single reflected index — the entire content of the theorem in miniature.

## 8.6 The Hodge polynomial versus the Poincaré polynomial

A closely related invariant drops the bigrading and keeps only the total degree: the
**Poincaré polynomial** $P(X; t) = \sum_{k} b_k t^k$ in the Betti numbers
$b_k = \sum_{p+q=k} h^{p,q}$. The E-polynomial refines $P$ in two ways: it remembers
the full bigrading (so $P$ is the diagonal specialisation $u = v = t$ up to signs), and
it carries the alternating sign that turns the top specialisation into the Euler
characteristic rather than the total Betti number. Our total-dimension invariant
$b(X)$ (Definition 2.4) is the sign-free companion: $b(X) = P(X;1) = \sum_k b_k$. Thus
the three numbers $\chi(X) = E(X;1,1)$, $b(X) = \sum h^{p,q}$, and (for surfaces) the
signature $\tau(X) = E(X;1,-1)$ are three distinct evaluations of, or companions to, a
single polynomial, and the mirror reflection acts on each predictably: $\chi$ picks up
$(-1)^n$, $b$ is invariant, and the signature transforms according to the parity of $n$.

---

## 8.7 Related work and historical context

The Hodge diamond and the symmetries $h^{p,q} = h^{q,p}$ (complex conjugation) and
$h^{p,q} = h^{n-p,n-q}$ (Serre duality) are classical, going back to Hodge theory and
the Hodge decomposition of the cohomology of a compact Kähler manifold. The
$E$-polynomial in the form used here is the Hodge–Deligne specialisation of the mixed
Hodge-structure data introduced by Deligne; it is multiplicative under products and
motivic (additive on locally closed stratifications), which makes it a workhorse for
computing cohomology of moduli spaces and character varieties.

Mirror symmetry originated in string theory in the late 1980s, where the observation
that pairs of Calabi–Yau threefolds share mirrored Hodge diamonds (and hence opposite
Euler characteristics) was an early and striking numerical signal. The quintic example
and its mirror, with $(\chi, -\chi) = (-200, +200)$, became the canonical illustration.
The present development does not attempt to prove mirror symmetry geometrically;
rather, it isolates and certifies the *algebraic consequences* a mirror pair must
exhibit at the level of the E-polynomial, turning the diagnostic numerics into
theorems and exhibiting them all as instances of a single index-reflection principle.

## 8.8 Notes on the formalisation

The theory is formalised over an arbitrary field via the integer-to-field ring
homomorphism, which keeps the combinatorial heart separate from any analytic input. A
deliberate design choice stores Hodge numbers as a total function on
$\mathbb N \times \mathbb N$, so that the index arithmetic $n - p$ uses truncated
natural subtraction; this is harmless on the support $\{p \le n\}$ where all sums live,
but it is the reason involutivity (Proposition 6.1) is stated pointwise on the support
rather than as a definitional equality of structures. The single nontrivial proof
ingredient is the reversal-of-range identity for finite sums; the remaining steps are
field algebra (factoring $u^{n-p} = u^n u^{-p}$, splitting $(-1)^{(n-p)+q}$) discharged
by ring normalisation. All theorems were machine-checked and depend only on the
standard foundational axioms (propositional extensionality, choice, and quotient
soundness).

---

## 9. Applications and context

- **Bridge to arithmetic.** The Hodge–Deligne E-polynomial is a specialisation of
  the motivic/Deligne $E$-polynomial, which for varieties over finite fields is
  linked to point counts via the Weil conjectures. Functional equations of $E$ are
  the geometric source of functional equations of zeta functions; our Serre equation
  is the abstract shadow of the zeta functional equation under Poincaré duality.
- **Mirror symmetry diagnostics.** The mirror sign law and the
  $h^{1,1}\leftrightarrow h^{n-1,1}$ exchange are the first numerical checks any
  conjectural mirror pair must pass; the framework makes them theorems.
- **Stringy invariants.** The same E-polynomial formalism underlies stringy Hodge
  numbers and orbifold cohomology, where similar reflection symmetries govern the
  $E$-function; the abstract engine here transfers directly.

---

## 10. Discussion and future work

The development is deliberately minimal: it keeps only what is needed to expose the
reflection principle. Several natural extensions, faithful to the present structure,
suggest themselves.

1. **From the diamond to the variety.** Connect the abstract diamond to the genuine
   Deligne $E$-polynomial of a complex variety, so that Theorems 4.1 and 5.1 are
   corollaries of Poincaré–Serre duality on cohomology rather than abstract
   hypotheses. This requires importing the mixed Hodge structure machinery.

2. **Mixed and weighted diamonds.** Generalise from pure Hodge numbers to mixed
   Hodge numbers $h^{p,q}$ with a weight filtration, where the E-polynomial gains its
   full Deligne form. The reflection engine should persist with weight-shifted
   prefactors.

3. **The full Calabi–Yau mirror dictionary.** Upgrade Calabi–Yau data to carry the
   complete moduli exchange and prove that the mirror functor is an involution on the
   category of such data, with the E-polynomial as a monoidal invariant under
   disjoint union and product.

4. **Stringy E-functions and orbifolds.** Extend to the stringy E-function of a
   Gorenstein orbifold, where a reflection symmetry analogous to Theorem 5.1 governs
   the relation between an orbifold and its crepant resolution; the present range-
   reversal argument is the expected core.

5. **Arithmetic specialisations.** Substitute $u = v = q$ (a prime power) to obtain
   point-count asymptotics, and study the functional equation's image under this
   substitution as a step toward an abstract Weil-type functional equation.

6. **Higher-variable refinements.** Track Hodge and weight gradings separately in a
   three-variable polynomial and identify the reflection symmetries of *each*
   grading, decomposing the present equations into independent pieces.

---

## 11. Conclusion

We have isolated, over an arbitrary field, the algebraic heart of two of the deepest
symmetries of complex geometry. The Hodge–Deligne E-polynomial of an abstract Hodge
diamond satisfies an unconditional **mirror functional equation**
$E(\mathrm{mirror}\,X; u, v) = (-1)^n u^n E(X; u^{-1}, v)$ and, under Serre duality, a
**Serre/Poincaré functional equation** $E(X; u, v) = (uv)^n E(X; u^{-1}, v^{-1})$.
Specialising at $u = v = 1$ — where $E$ collapses to the Euler characteristic —
recovers the mirror sign law $\chi(\mathrm{mirror}\,X) = (-1)^n \chi(X)$, the
numerical signature of mirror symmetry. A single combinatorial fact, the reversal of
a finite summation range, drives every result; the prefactors and signs are nothing
but the accounting of the induced exponent and parity shifts. The work is fully
formalised and machine-verified, resting only on the standard foundational axioms.
