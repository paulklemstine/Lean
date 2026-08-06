# Orbit Capacity of Symmetry-Invariant Patterns: Burnside Counting, Toroidal Descent, and Per-Orbit Entropy Deficit

**Author:** Aristotle

**Date:** 2026-08-06

---

## Abstract

We develop an exact combinatorial and information-theoretic theory of binary
patterns on a finite cell set that are invariant under a group of symmetries,
with the discrete time–pitch torus $\mathbb{Z}_p \times \mathbb{Z}_q$ as the
running model. The foundation is the *orbit capacity theorem*: if a group $G$
acts on a finite cell set $\alpha$ with $m$ orbits, then the space of
$G$-invariant binary patterns has cardinality exactly $2^m$, equivalently
capacity exactly $m$ bits. Combining this with Burnside's lemma converts the
capacity into an average of fixed-point counts, and we evaluate it in closed
form for the four generators of a planar crystallographic group acting on a
torus.

Our main quantitative results are: the point-reflection (retrograde–inversion)
capacity $2^{(pq + \tau(p)\tau(q))/2}$, where $\tau(n) \in \{1,2\}$ counts the
elements of $\mathbb{Z}_n$ equal to their own negatives; the full-translation
capacity $2^{q}$; the quarter-turn capacity
$2^{(p^2 + 2\tau(p) + \tau(p)^2)/4}$ on the square torus, specializing to
$2^{(p^2+3)/4}$ for odd $p$ and $2^{(p^2+8)/4}$ for even $p$; and the glide
capacity $2^{pq/2}$ for even $p$, obtained from the fixed-point freeness of the
glide reflection.

Structurally we prove: a *descent dichotomy* determining exactly which elements
of the order-eight point group of the square lattice survive quotienting to a
$p\times q$ torus (all of them iff $p=q$; otherwise exactly the order-four
diagonal subgroup); *strict* antitonicity of capacity in the symmetry group,
together with its exact converse; and a *realizability theorem* showing that
every subgroup of the ambient group occurs precisely as the symmetry group of an
explicit pattern, so no symmetry type is missing and a pattern's symmetry group
is strictly finer data than the ambient group.

We then formalize the musical predicate "canon at time distance $g$" and
determine its complete numerical signature: a number $k$ is the onset count of
some canon at distance $g$ on the $p\times q$ torus if and only if $d \mid k$
and $k \le pq$, where $d$ is the additive order of $g$. Finally we upgrade the
capacity count to a probabilistic statement: every distribution on invariant
patterns has Shannon entropy at most $m$ bits with equality exactly for the
uniform distribution, and the natural biased model — switch each orbit on
independently with probability $\theta$ — has entropy exactly $m\,H_2(\theta)$,
so its entropy deficit is exactly $m(1 - H_2(\theta))$: **stylistic bias costs a
fixed number of bits per orbit**.

---

## 1. Introduction

### 1.1 The counting problem

Let $\alpha$ be a finite set of *cells*, and let a group $G$ act on $\alpha$. A
**binary pattern** is a function $f : \alpha \to \{0,1\}$; without constraints
there are $2^{|\alpha|}$ of them. The pattern is **$G$-invariant** when
$f(g\cdot a) = f(a)$ for all $g \in G$, $a \in \alpha$.

The motivating instance is a quantized musical grid: $\alpha$ is a discrete
time–pitch (or time–instrument) grid, a cell is a possible onset, and $G$ is a
group of musical transformations — time shifts, inversion, retrograde,
retrograde–inversion, glide reflections. The question "how much room does a
style leave?" becomes "how many patterns are invariant under the style's
symmetry group?", and the question "how much information does a rhythm carry?"
becomes a Shannon-entropy question over that space.

This paper answers both, exactly, for the natural toroidal models.

### 1.2 Summary of contributions

1. **Orbit capacity** (Section 3). Invariant patterns are in bijection with
   Boolean functions on the orbit set, so their number is $2^{m}$ with $m$ the
   orbit count, and the capacity in bits is exactly $m$.
2. **Burnside evaluation** (Section 4), in both a division-free form and the
   usual averaged form.
3. **Closed-form capacities on the torus** (Sections 5–7) for translations,
   point reflection, quarter turns, and glides.
4. **Descent dichotomy** (Section 6.1) for the point group of the square
   lattice acting on a rectangular torus.
5. **Strict monotonicity and its converse** (Section 8).
6. **Realizability of every symmetry type** (Section 9).
7. **The complete onset spectrum of canons** (Section 10).
8. **Entropy theory**: maximum-entropy bound with equality case, and the exact
   per-orbit entropy deficit of the orbit-Bernoulli model (Section 11).

### 1.3 What is *not* claimed

We deliberately do not assert a "seventeen wallpaper groups of rhythm"
classification. Section 6 shows why such a claim requires care: on a
non-square torus, half of the point group of the plane fails to descend at all.
A genuine classification would require planar Euclidean isometries, lattice
discreteness, and compactness of the quotient as prerequisites. Similarly, we
treat musical labels ("canon", "round") as *predicates to be tested*, not as
outputs of a classification; Section 10 shows the shape a defensible treatment
takes.

---

## 2. Setup and notation

Throughout, $G$ is a group acting on a set $\alpha$ of cells; $\alpha$ is finite
whenever a cardinality is asserted.

**Definition 2.1 (Orbit relation).** Cells $a, b \in \alpha$ are *equivalent*,
written $a \sim_G b$, if $b = g \cdot a$ for some $g \in G$. This is an
equivalence relation; its classes are the **orbits**, and the set of orbits is
written $\alpha/G$, with $m := |\alpha/G|$.

**Definition 2.2 (Invariant pattern).** A **$G$-invariant pattern** is a
function $f : \alpha \to \{0,1\}$ that is constant on orbits, i.e. $a \sim_G b$
implies $f(a) = f(b)$. We write $\mathcal{P}_G(\alpha)$ for the set of such
patterns.

**Lemma 2.3 (Pointwise form of invariance).** *A pattern $f$ is constant on
orbits if and only if $f(g\cdot a) = f(a)$ for every $g \in G$ and $a \in
\alpha$.*

*Proof.* If $f$ is constant on orbits then $g\cdot a \sim_G a$ gives the
pointwise identity. Conversely, if $a \sim_G b$ then $a = g\cdot b$ for some
$g$, and the pointwise identity gives $f(a) = f(g\cdot b) = f(b)$. $\square$

Lemma 2.3 is a bijection of descriptions, not merely an implication: the
"constant on classes" formulation and the "pointwise invariant" formulation
define literally the same set of patterns, and we use them interchangeably.

**Definition 2.4 (Fixed set).** For $g \in G$, $\mathrm{Fix}(g) := \{a \in
\alpha : g\cdot a = a\}$.

**Definition 2.5 (Two-torsion count).** For $n \geq 1$,
$$ \tau(n) := \bigl|\{x \in \mathbb{Z}_n : -x = x\}\bigr|
   = \begin{cases} 2, & n \text{ even},\\ 1, & n \text{ odd}. \end{cases} $$

**Lemma 2.6.** *Definition 2.5 is correct: in $\mathbb{Z}_n$ with $n$ odd, $-x =
x$ forces $x = 0$; with $n = 2m$, $m > 0$, the solutions are exactly $x \in
\{0, m\}$.*

*Proof.* $-x = x$ is equivalent to $2x = 0$. If $n$ is odd then $2$ is a unit
modulo $n$ (it is coprime to $n$), so $x = 0$. If $n = 2m$, lift $x$ to its
representative $v \in \{0,\dots,2m-1\}$; then $2m \mid 2v$, so $m \mid v$, so
$v \in \{0, m\}$; and $0 \neq m$ in $\mathbb{Z}_{2m}$ because $2m \nmid m$ for
$m > 0$. $\square$

**Definition 2.7 (Time–pitch torus).** The $p\times q$ **torus** is the cell set
$\mathbb{Z}_p \times \mathbb{Z}_q$: time is cyclic with period $p$, pitch (or
instrument) cyclic with period $q$. It has $pq$ cells.

**Definition 2.8 (Symmetry group of a pattern).** For a pattern
$f : \alpha \to \{0,1\}$, its **symmetry group** is
$$ \mathrm{Sym}_G(f) := \{ g \in G : f(g\cdot a) = f(a) \text{ for all } a \}. $$
This is a subgroup of $G$: it contains the identity, is closed under products
(by $f((gh)\cdot a) = f(g\cdot(h\cdot a)) = f(h \cdot a) = f(a)$), and is closed
under inverses (apply the defining identity at $g^{-1}\cdot a$).

**Proposition 2.9.** *$f$ is $G$-invariant if and only if
$\mathrm{Sym}_G(f) = G$.* Immediate from Definition 2.8 and Lemma 2.3.

---

## 3. The orbit capacity theorem

**Theorem 3.1 (Orbit Capacity).** *Let $G$ act on a finite cell set $\alpha$
with $m$ orbits. Then*
$$ |\mathcal{P}_G(\alpha)| = 2^{m}. $$

*Proof sketch.* A pattern constant on orbits factors uniquely through the
quotient map $\alpha \twoheadrightarrow \alpha/G$; conversely any Boolean
function on $\alpha/G$ pulls back to an orbit-constant pattern. This gives a
bijection $\mathcal{P}_G(\alpha) \cong \{0,1\}^{\alpha/G}$, whose right-hand
side has $2^{m}$ elements. $\square$

**Corollary 3.2 (Capacity in bits).**
$$ \log_2 |\mathcal{P}_G(\alpha)| = m. $$

The content of Theorem 3.1 is that the entire counting problem is reduced to
counting orbits, and its exponential shape means that saving even one orbit
halves the pattern count. Both the trivial group (with $m = |\alpha|$, giving
the unconstrained $2^{|\alpha|}$) and a transitive group (with $m = 1$, giving
just the empty and full patterns) are limiting instances.

The bijection of Theorem 3.1 is used again in Section 11: it is precisely the
parametrization along which we transport a product measure on the orbit set to a
measure on invariant patterns.

---

## 4. Burnside evaluation of the capacity

**Theorem 4.1 (Burnside's lemma).** *For a finite group $G$ acting on a finite
set $\alpha$,*
$$ \sum_{g \in G} |\mathrm{Fix}(g)| \;=\; m \cdot |G|. $$

*Proof sketch.* Count the incidence set $\{(g,a) : g\cdot a = a\}$ in two ways:
by $g$ it is $\sum_g |\mathrm{Fix}(g)|$; by $a$ it is
$\sum_a |\mathrm{Stab}(a)|$, which by orbit–stabilizer equals
$\sum_a |G|/|\mathrm{Orb}(a)| = |G| \cdot m$. $\square$

**Theorem 4.2 (Burnside Capacity Formula, division-free).**
$$ |\mathcal{P}_G(\alpha)|^{\,|G|} \;=\; 2^{\sum_{g\in G} |\mathrm{Fix}(g)|}. $$

*Proof.* Raise Theorem 3.1 to the power $|G|$ and substitute Theorem 4.1:
$(2^m)^{|G|} = 2^{m|G|} = 2^{\sum_g |\mathrm{Fix}(g)|}$. $\square$

The division-free form is worth isolating because it is an identity of natural
numbers with no division and no hypothesis that $|G|$ divides the fixed-point
sum — that divisibility is a *consequence*, not a precondition.

**Theorem 4.3 (Burnside Capacity Formula).**
$$ |\mathcal{P}_G(\alpha)| \;=\; 2^{\;\frac{1}{|G|}\sum_{g\in G}
   |\mathrm{Fix}(g)|}. $$

*Proof.* Divide the exponent identity of Theorem 4.1 by $|G| > 0$ and apply
Theorem 3.1. $\square$

**Algorithmic content.** Theorem 4.3 is an algorithm. To compute the capacity of
a symmetry group one need never enumerate orbits (which costs a union–find pass
over all $|\alpha|$ cells and all $|G|$ generators); it suffices to solve, for
each group element separately, the usually trivial equation $g\cdot a = a$. All
four capacities below are obtained this way, and each fixed-point count is a
one-line calculation.

---

## 5. Translations and point reflections on the torus

### 5.1 Full time-shift invariance

Let $C_p$ denote the cyclic group of time shifts acting on the $p \times q$
torus by $g\cdot(t,n) = (t+g, n)$.

**Lemma 5.1 (Freeness of the shift action).** *For $g \neq 0$,
$\mathrm{Fix}(g) = \emptyset$; and $\mathrm{Fix}(0)$ is everything.*

*Proof.* $(t+g, n) = (t,n)$ forces $g = 0$ by cancellation in $\mathbb{Z}_p$.
$\square$

**Theorem 5.2 (Ostinato capacity).** *The number of patterns on the $p\times q$
torus invariant under **every** time shift is exactly $2^{q}$.*

*Proof.* By Lemma 5.1 the Burnside sum is $pq + 0 + \dots + 0 = pq$, and
$|C_p| = p$, so $m = pq/p = q$; apply Theorem 3.1. Geometrically: the orbits are
the $q$ horizontal circles. $\square$

*Example.* On the $4\times3$ grid there are exactly $8$ fully shift-invariant
patterns, out of $2^{12} = 4096$.

### 5.2 Point reflection (retrograde–inversion)

Let $\{\pm 1\}$ act on the torus with $-1$ acting by $(t,n)\mapsto(-t,-n)$.

**Lemma 5.3.** *The fixed cells of the point reflection are the pairs $(t,n)$
with $-t = t$ and $-n = n$; there are $\tau(p)\tau(q)$ of them.*

*Proof.* $-(t,n) = (t,n)$ holds coordinatewise, so the fixed set is the product
of the two-torsion subgroups; apply Lemma 2.6 in each factor. $\square$

**Theorem 5.4 (Point-Reflection Capacity).** *The number of
retrograde–inversion invariant patterns on the $p\times q$ torus is exactly*
$$ 2^{\bigl(pq + \tau(p)\tau(q)\bigr)/2}. $$
*In particular for $p, q$ both odd this is $2^{(pq+1)/2}$.*

*Proof.* Burnside sum $= pq + \tau(p)\tau(q)$ over a group of order two;
apply Theorem 4.3. $\square$

*Examples.* $3\times3$: $2^{(9+1)/2} = 2^5 = 32$. $4\times3$: $2^{(12+2)/2} =
2^{7} = 128$. The parity of the periods is not cosmetic — even periods
contribute additional two-torsion cells, hence additional orbits of size one,
hence strictly more capacity than the naive $2^{\lceil pq/2\rceil}$ guess would
sometimes suggest.

---

## 6. Descent to a torus, and quarter-turn capacity

### 6.1 Which planar symmetries descend?

The $p\times q$ torus is the quotient of the integer plane $\mathbb{Z}^2$ by the
sublattice
$$ \Lambda_{p,q} := p\mathbb{Z}\times q\mathbb{Z} = \{ v \in \mathbb{Z}^2 :
   p \mid v_1,\ q \mid v_2 \}. $$
A linear map of the plane descends to a well-defined map of the torus exactly
when it preserves $\Lambda_{p,q}$. The linear parts of the isometries preserving
$\mathbb{Z}^2$ are the eight signed permutation matrices, which split into
*diagonal* maps $\sigma_{\varepsilon_1,\varepsilon_2}(v) =
(\varepsilon_1 v_1, \varepsilon_2 v_2)$ and *swapping* maps
$\rho_{\varepsilon_1,\varepsilon_2}(v) = (\varepsilon_1 v_2, \varepsilon_2 v_1)$,
with $\varepsilon_i \in \{\pm 1\}$.

**Theorem 6.1 (Diagonal elements always descend).** *For all $p,q$ and all units
$\varepsilon_1, \varepsilon_2$, the map $\sigma_{\varepsilon_1,\varepsilon_2}$
preserves $\Lambda_{p,q}$.*

*Proof.* $p \mid v_1 \Rightarrow p \mid \varepsilon_1 v_1$, likewise in the
second coordinate. $\square$

**Theorem 6.2 (Swapping elements descend only to square tori).** *For units
$\varepsilon_1,\varepsilon_2$, the map $\rho_{\varepsilon_1,\varepsilon_2}$
preserves $\Lambda_{p,q}$ if and only if $p = q$.*

*Proof.* ($\Leftarrow$) If $p = q$ the divisibility conditions are symmetric in
the coordinates. ($\Rightarrow$) Test the map on $(p,0) \in \Lambda_{p,q}$: its
image is $(0, \varepsilon_2 p)$, so $q \mid \varepsilon_2 p$, and as
$\varepsilon_2$ is a unit, $q \mid p$. Test on $(0,q)$: its image is
$(\varepsilon_1 q, 0)$, so $p \mid q$. Hence $p = q$. $\square$

**Corollary 6.3 (Descent dichotomy).** *The subgroup of the order-eight point
group $D_4$ that descends to the $p\times q$ torus is all of $D_4$ when $p = q$,
and exactly the order-four diagonal subgroup $\{\sigma_{\pm1,\pm1}\}$ otherwise.*

Specializing to the quarter turn $\kappa(t,n) = (-n,t)$ (a swapping element with
$\varepsilon_1 = -1$, $\varepsilon_2 = +1$):

**Corollary 6.4 (Quarter-Turn Descent Criterion).** *The planar quarter turn
preserves $\Lambda_{p,q}$ — equivalently descends to the $p\times q$ torus — if
and only if $p = q$.*

This is the precise obstruction behind the intuitive remark that "you cannot
rotate a rhythm by ninety degrees unless your time and pitch axes are
commensurate": rotating trades a beat for a semitone, and the trade is only
legal when the two periodicities coincide.

### 6.2 The quarter-turn action on a square torus

On the square torus write $\kappa(t,n) := (-n, t)$.

**Lemma 6.5.** *$\kappa^2(t,n) = (-t,-n)$ and $\kappa^4 = \mathrm{id}$; moreover
$\kappa^3(t,n) = (n,-t)$, the anticlockwise quarter turn.*

*Proof.* Direct computation. $\square$

Thus $\kappa$ generates a cyclic group $Q \cong \mathbb{Z}_4$ of order (dividing)
four acting on $\mathbb{Z}_p\times\mathbb{Z}_p$, and its square is exactly the
point reflection of Section 5.2 — the two constructions are compatible.

**Lemma 6.6 (Fixed cells of a quarter turn).** *$\kappa(t,n) = (t,n)$ if and
only if $n = t$ and $-t = t$. Hence $|\mathrm{Fix}(\kappa)| =
|\mathrm{Fix}(\kappa^3)| = \tau(p)$, and these fixed cells are exactly the
diagonal cells $(t,t)$ with $t$ of order at most two.*

*Proof.* The two coordinate equations are $-n = t$ and $t = n$; substituting the
second into the first gives $-t = t$, and the fixed cells are then $(t,t)$ with
$-t=t$. Lemma 2.6 counts them. The count for $\kappa^3 = \kappa^{-1}$ is equal
because a map and its inverse have the same fixed set. $\square$

**Lemma 6.7 (Fixed cells of the half turn).** *$|\mathrm{Fix}(\kappa^2)| =
\tau(p)^2$, by Lemma 5.3 with $q = p$.*

**Theorem 6.8 (Burnside data for the quarter-turn action).**
$$ \sum_{g \in Q} |\mathrm{Fix}(g)| = p^2 + 2\tau(p) + \tau(p)^2. $$

*Proof.* The identity fixes all $p^2$ cells; $\kappa$ and $\kappa^3$ each fix
$\tau(p)$ (Lemma 6.6); $\kappa^2$ fixes $\tau(p)^2$ (Lemma 6.7). $\square$

**Theorem 6.9 (Quarter-Turn Capacity).** *The number of quarter-turn invariant
binary patterns on the $p\times p$ torus is exactly*
$$ 2^{\bigl(p^2 + 2\tau(p) + \tau(p)^2\bigr)/4}, $$
*and the quarter-turn action has exactly $(p^2 + 2\tau(p) + \tau(p)^2)/4$
orbits.*

*Proof.* Theorem 4.3 with Theorem 6.8 and $|Q| = 4$. The orbit count follows by
injectivity of $m \mapsto 2^m$. $\square$

**Corollary 6.10 (Parity specializations).**
$$ |\mathcal{P}_Q| = \begin{cases}
     2^{(p^2+3)/4}, & p \text{ odd } (\tau = 1),\\[2pt]
     2^{(p^2+8)/4}, & p \text{ even } (\tau = 2).
   \end{cases} $$

*Numerical instances.*

| $p$ | $\tau(p)$ | orbits | capacity |
|-----|-----------|--------|----------|
| $2$ | $2$ | $3$ | $8$ |
| $3$ | $1$ | $3$ | $8$ |
| $4$ | $2$ | $6$ | $64$ |
| $5$ | $1$ | $7$ | $128$ |

The coincidence at $p=2$ and $p=3$ is instructive: the small even torus has
*more* two-torsion, hence more singleton orbits, hence more freedom, exactly
compensating its smaller cell count.

---

## 7. Glide reflections

Translations, rotations and axis reflections do not exhaust the generators of a
planar crystallographic group. The remaining generator is the **glide
reflection**: a reflection composed with a translation by half a period along
the mirror line. It is the unique kind of planar isometry that is a symmetry of
no point, and musically it is the "inverted answer displaced by half a bar".

**Definition 7.1 (Toroidal glide).** For even $p$, define
$\gamma : \mathbb{Z}_p\times\mathbb{Z}_q \to \mathbb{Z}_p\times\mathbb{Z}_q$ by
$$ \gamma(t,n) := \bigl(t + \tfrac{p}{2},\; -n \bigr). $$

**Lemma 7.2 (Involution).** *For even $p$, $\gamma^2 = \mathrm{id}$.*

*Proof.* $\gamma^2(t,n) = (t + p/2 + p/2, n) = (t + p, n) = (t,n)$, using
$p/2 + p/2 = p \equiv 0$ in $\mathbb{Z}_p$ (this is where evenness enters) and
$-(-n) = n$. $\square$

So $\gamma$ generates a group $\Gamma \cong \mathbb{Z}_2$ acting on the torus.

**Theorem 7.3 (Fixed-point freeness).** *For even $p \geq 2$, $\mathrm{Fix}(\gamma)
= \emptyset$.*

*Proof.* A fixed cell requires $t + p/2 = t$ in $\mathbb{Z}_p$, hence
$p \mid p/2$; but $0 < p/2 < p$, a contradiction. $\square$

This is exactly the defining property of a glide, faithfully preserved by the
descent to the torus: unlike every rotation and every pure reflection, a glide
pins down no cell whatsoever.

**Theorem 7.4 (Glide Capacity).** *For even $p$, the glide $\gamma$ has exactly
$pq/2$ orbits on the $p\times q$ torus — all of size two — and the number of
$\gamma$-invariant patterns is exactly*
$$ 2^{\,pq/2}. $$

*Proof.* The Burnside sum is $pq + 0 = pq$ over a group of order two, giving
$m = pq/2$; apply Theorem 3.1. All orbits have size two by freeness of the
nontrivial element. $\square$

*Examples.* $4\times3$: $2^{6} = 64$. $2\times2$: $2^{2} = 4$.

Among the crystallographic generators, the glide has the cleanest price: it
halves the bit budget exactly, with no parity corrections, because it fixes
nothing.

---

## 8. Monotonicity of capacity, sharply

Let $H \le K \le G$ be subgroups. Since every $H$-orbit is contained in a
$K$-orbit, there is a canonical surjection $\alpha/H \twoheadrightarrow
\alpha/K$.

**Theorem 8.1 (Antitonicity).** *If $H \le K$ then $|\alpha/K| \le |\alpha/H|$
and hence*
$$ |\mathcal{P}_K(\alpha)| \le |\mathcal{P}_H(\alpha)|. $$

*Proof.* Surjections do not increase cardinality of finite sets; apply
Theorem 3.1 and monotonicity of $m \mapsto 2^m$. $\square$

**Theorem 8.2 (Strictness).** *Suppose $H \le K$ and there exist cells $a,b$
with $b \in K\cdot a$ but $b \notin H\cdot a$. Then*
$$ |\mathcal{P}_K(\alpha)| < |\mathcal{P}_H(\alpha)|. $$

*Proof.* The canonical surjection $\alpha/H \to \alpha/K$ sends the distinct
classes $[a]_H \neq [b]_H$ to the same $K$-class, so it is surjective and not
injective; a surjective non-injective map of finite sets strictly decreases
cardinality, and $m \mapsto 2^m$ is strictly increasing. $\square$

**Theorem 8.3 (Exact converse).** *If $H \le K$ and every $K$-relation is
already an $H$-relation — that is, $b \in K\cdot a$ implies $b \in H\cdot a$ for
all $a,b$ — then the canonical map is a bijection and*
$$ |\mathcal{P}_K(\alpha)| = |\mathcal{P}_H(\alpha)|. $$

Together, Theorems 8.2 and 8.3 identify the exact condition for a capacity drop:
capacity strictly falls if and only if the larger group genuinely fuses orbits.
Imposing a symmetry the smaller group already realizes is free.

*Concrete instance.* On the four-beat, one-instrument grid, requiring invariance
under the full shift group leaves strictly fewer patterns ($2$) than requiring
nothing ($2^4 = 16$), witnessed by the pair of cells $(0,0)$ and $(1,0)$, which
the full shift group merges and the trivial group does not.

---

## 9. Every symmetry type is realized

Theorem 8.1 is about a *fixed* group and *all* patterns. The complementary
question fixes a pattern and asks for its symmetry group $\mathrm{Sym}_G(f)$
(Definition 2.8). Which subgroups arise?

**Theorem 9.1 (Realizability, translation action).** *Let a group $G$ act on
itself by left translation, and for a subgroup $H \le G$ let $\mathbf{1}_H$ be
its indicator pattern. Then*
$$ \mathrm{Sym}_G(\mathbf{1}_H) = H. $$

*Proof.* ($\supseteq$) If $g \in H$ then $ga \in H \iff a \in H$ by the
cancellation law in cosets, so $\mathbf{1}_H(ga) = \mathbf{1}_H(a)$ for all $a$.
($\subseteq$) If $g \in \mathrm{Sym}_G(\mathbf{1}_H)$, evaluate at $a = 1$:
$\mathbf{1}_H(g) = \mathbf{1}_H(1) = 1$, so $g \in H$. $\square$

**Theorem 9.2 (Realizability on a drum grid).** *Let $C_p$ act on the $p\times
q$ torus by time shifts, and for a subgroup $H \le C_p$ define the pattern*
$$ f_H(t,n) := \begin{cases} 1, & \text{shift by } t \in H, \\ 0,
   & \text{otherwise.} \end{cases} $$
*Then $\mathrm{Sym}_{C_p}(f_H) = H$.*

*Proof.* Same two steps: containment of $H$ uses
$f_H(t+g, n) = f_H(t,n)$ from $H$-membership being invariant under multiplying
by an element of $H$; the reverse containment evaluates at $(0,0)$. $\square$

**Consequences.** (i) No symmetry type is missing: the whole subgroup lattice,
from trivial to total, is realized by explicit patterns. (ii) The symmetry group
of a pattern is strictly finer information than the ambient group, and the two
must not be conflated. The backbeat on a four-beat cycle (onsets at $t = 0, 2$)
is the canonical example: its symmetry group contains the half-bar shift, so it
is nontrivial, and omits the one-beat shift, so it is proper.

---

## 10. Canons: a musical label with a complete numerical signature

**Definition 10.1 (Canon).** A pattern $f$ on the $p\times q$ torus is a
**canon at time distance $g \in \mathbb{Z}_p$** if
$$ f(t + g, n) = f(t,n) \quad \text{for all } (t,n). $$
Equivalently (Definition 2.8), the shift by $g$ lies in $\mathrm{Sym}_{C_p}(f)$.

This is a definite, checkable property of a grid — the point being that it turns
an informal musical word into a falsifiable claim.

**Definition 10.2 (Onset count).** $\mathrm{ons}(f) := |\{a : f(a) = 1\}|$.

**Lemma 10.3 (Free actions divide invariant sets).** *If a finite group $\Gamma$
acts freely on a finite set $\alpha$ (i.e. $\gamma\cdot a = a \Rightarrow \gamma
= 1$) and $S \subseteq \alpha$ is $\Gamma$-invariant, then $|\Gamma|$ divides
$|S|$.*

*Proof sketch.* $\Gamma$ acts on $S$; every stabilizer is trivial, so every
orbit has exactly $|\Gamma|$ elements, and $S$ is the disjoint union of its
orbits. $\square$

**Theorem 10.4 (Canon Divisibility).** *If $f$ is a canon at time distance $g$
on the $p\times q$ torus and $d$ is the additive order of $g$ in
$\mathbb{Z}_p$, then $d \mid \mathrm{ons}(f)$.*

*Proof.* The cyclic group generated by the shift by $g$ has order $d$ and acts
freely on the torus (Lemma 5.1). The onset set is invariant under it by
Definition 10.1. Apply Lemma 10.3. $\square$

**Corollary 10.5.** *If $g$ generates $\mathbb{Z}_p$ (so $d = p$) then $p$
divides the onset count of any canon at distance $g$.*

Theorem 10.4 gives a necessary condition. It is also sufficient — the
obstruction is complete.

**Lemma 10.6 (Fibers of the orbit map).** *For a free action of a finite group
$\Gamma$ on a finite $\alpha$, every fiber of $\alpha \to \alpha/\Gamma$ has
exactly $|\Gamma|$ elements.*

*Proof.* Fix a representative $a$; then $\gamma \mapsto \gamma\cdot a$ is a
bijection from $\Gamma$ onto the orbit of $a$, injective precisely by freeness.
$\square$

**Lemma 10.7 (Invariant subsets of every admissible size).** *For a free action
of a finite group $\Gamma$ on a finite $\alpha$ with $M$ orbits, and every
$j \le M$, there is a $\Gamma$-invariant subset $S \subseteq \alpha$ with
$|S| = |\Gamma|\cdot j$.*

*Proof.* Choose any $j$ orbits and take $S$ to be their union: it is invariant
by construction, and each orbit contributes exactly $|\Gamma|$ elements by
Lemma 10.6. $\square$

**Theorem 10.8 (Sharpness).** *Let $d$ be the additive order of $g$ in
$\mathbb{Z}_p$. For every $k$ with $d \mid k$ and $k \le pq$, there exists a
canon at time distance $g$ on the $p\times q$ torus with exactly $k$ onsets.*

*Proof.* Write $k = d\,j$. The shift group $\Gamma$ generated by $g$ has order
$d$ and acts freely, so its orbit count is $M = pq/d$; the bound $k \le pq$
gives $j \le M$. Take $S$ from Lemma 10.7 and let $f$ be its indicator. $S$ is
shift-invariant, hence $f$ is a canon at distance $g$, and
$\mathrm{ons}(f) = |S| = d\,j = k$. $\square$

**Theorem 10.9 (Complete onset spectrum).** *A natural number $k$ is the onset
count of some canon at time distance $g$ on the $p\times q$ torus if and only
if*
$$ d \mid k \quad\text{and}\quad k \le pq, \qquad d = \mathrm{ord}(g). $$

*Proof.* Necessity: Theorem 10.4 and the trivial bound $\mathrm{ons}(f) \le pq$.
Sufficiency: Theorem 10.8. $\square$

*Worked instance.* On the four-beat, one-instrument grid with $g = 2$ (a
half-bar canon), $d = 2$, so the achievable onset counts are exactly
$\{0, 2, 4\}$. The backbeat, with onsets at $t = 0, 2$, realizes $k = 2$.

Theorem 10.9 is the model we advocate for handling musical vocabulary: state the
label as a predicate, derive a numerical consequence, and then prove the
consequence is *exactly* right, so that the test neither over- nor
under-rejects.

---

## 11. Entropy: capacity as an information-theoretic ceiling

Corollary 3.2 measures capacity uniformly. Real corpora are not uniform. This
section shows that the orbit count is nevertheless the correct measure — it is a
hard ceiling on the Shannon entropy of *any* model respecting the symmetry — and
computes the exact deficit of the natural biased model.

Throughout, $\eta(x) := -x\ln x$ (with $\eta(0) = 0$), and for a distribution
$P$ on a finite set $\beta$,
$$ H(P) := \frac{1}{\ln 2}\sum_{b\in\beta} \eta(P(b)) $$
is its Shannon entropy in bits.

### 11.1 Maximum-entropy bound with equality case

**Theorem 11.1 (Maximum entropy).** *For a probability distribution $P$ on a
finite nonempty set $\beta$,*
$$ \sum_{b} \eta(P(b)) \le \ln|\beta|, \qquad\text{i.e.}\qquad
   H(P) \le \log_2 |\beta|. $$

*Proof sketch.* $\eta$ is concave, so Jensen's inequality with uniform weights
$1/n$, $n = |\beta|$, gives
$\frac1n\sum_b \eta(P(b)) \le \eta\bigl(\frac1n\sum_b P(b)\bigr) =
\eta(1/n) = \frac1n\ln n$; multiply by $n$. $\square$

**Theorem 11.2 (Equality case).** *Equality holds in Theorem 11.1 if and only if
$P$ is uniform, $P(b) = 1/|\beta|$ for all $b$.*

*Proof sketch.* $\eta$ is *strictly* concave on $[0,\infty)$, and the equality
case of Jensen's inequality for a strictly concave function with strictly
positive weights forces all the arguments $P(b)$ to coincide; being a
probability distribution, they must all equal $1/|\beta|$. $\square$

**Theorem 11.3 (Entropy ceiling for invariant patterns).** *Let $G$ act on a
finite cell set with $m$ orbits, and let $P$ be any probability distribution on
$\mathcal{P}_G(\alpha)$. Then*
$$ H(P) \le m, $$
*with equality if and only if $P$ is the uniform distribution on invariant
patterns.*

*Proof.* By Theorem 3.1, $|\mathcal{P}_G(\alpha)| = 2^m$, so $\log_2
|\mathcal{P}_G(\alpha)| = m$; apply Theorems 11.1 and 11.2. $\square$

Theorem 11.3 is the precise sense in which the orbit count is the information
capacity of a style: no generative model that produces only $G$-invariant
patterns can carry more than $m$ bits per pattern, whatever its preferences.

### 11.2 The binary entropy function

**Definition 11.4.** For $\theta \in [0,1]$,
$$ H_2(\theta) := \frac{\eta(\theta) + \eta(1-\theta)}{\ln 2}
  = -\theta\log_2\theta - (1-\theta)\log_2(1-\theta). $$

**Theorem 11.5.** *$H_2(\theta) \le 1$ for all $\theta\in[0,1]$, with equality
if and only if $\theta = 1/2$.*

*Proof.* Apply Theorems 11.1 and 11.2 to the two-point distribution
$(\theta, 1-\theta)$ on a set of size $2$, and divide by $\ln 2$. $\square$

### 11.3 The orbit-Bernoulli model

**Definition 11.6 (Product weight).** For a finite index set $\iota$ and
$\theta \in [0,1]$, define on configurations $x : \iota \to \{0,1\}$
$$ w_\theta(x) := \prod_{i \in \iota}
   \bigl(\theta^{\,x_i}(1-\theta)^{\,1-x_i}\bigr). $$

**Lemma 11.7 (Normalization).** *$\sum_{x} w_\theta(x) = 1$.*

*Proof.* Expand $\prod_i (\theta + (1-\theta)) = 1$ by distributivity: the terms
of the expansion are exactly the $w_\theta(x)$. $\square$

**Theorem 11.8 (Entropy of a product weight).**
$$ \sum_{x \in \{0,1\}^{\iota}} \eta\bigl(w_\theta(x)\bigr)
   = |\iota|\,\bigl(\eta(\theta) + \eta(1-\theta)\bigr). $$

*Proof sketch.* Induct on $|\iota|$. For the inductive step, split a
configuration on $n+1$ coordinates as a first bit $b$ together with a
configuration $y$ on the remaining $n$, so $w_\theta(b,y) = c_b\, w_\theta(y)$
with $c_b \in \{\theta, 1-\theta\}$. Use the identity
$$ \eta(uv) = v\,\eta(u) + u\,\eta(v), $$
which for $u = c_b$, $v = w_\theta(y)$ gives, after summing over $y$ and
applying Lemma 11.7 and the inductive hypothesis,
$$ \sum_y \eta(w_\theta(c_b, y)) = \eta(c_b) + c_b\cdot n\bigl(\eta(\theta) +
   \eta(1-\theta)\bigr). $$
Summing over the two values of $b$ and using $\theta + (1-\theta) = 1$ yields
$(n+1)(\eta(\theta)+\eta(1-\theta))$. The passage from $\{1,\dots,n\}$ to a
general finite index set is by transport along any bijection, under which
$w_\theta$ is invariant since the defining product is over all coordinates.
$\square$

**Definition 11.9 (Orbit-Bernoulli distribution).** Fix $\theta \in [0,1]$.
Using the bijection $\mathcal{P}_G(\alpha) \cong \{0,1\}^{\alpha/G}$ of
Theorem 3.1, define
$$ P_\theta(f) := w_\theta\bigl(\text{the orbit configuration of } f \bigr). $$
In words: switch each orbit on independently with probability $\theta$. By
Lemma 11.7 this is a probability distribution on $\mathcal{P}_G(\alpha)$.

**Theorem 11.10 (Exact entropy of the orbit-Bernoulli model).**
$$ H(P_\theta) = m \cdot H_2(\theta), $$
*where $m$ is the number of orbits.*

*Proof.* Transport the entropy sum along the bijection of Theorem 3.1 (a
bijection permutes the summands and leaves the sum unchanged), apply
Theorem 11.8 with $\iota = \alpha/G$, so $|\iota| = m$, and divide by $\ln 2$.
$\square$

**Theorem 11.11 (Per-orbit entropy deficit).** *The gap between the uniform
capacity and the entropy of the orbit-Bernoulli model is exactly*
$$ m - H(P_\theta) \;=\; m\,\bigl(1 - H_2(\theta)\bigr). $$
*It is nonnegative for every $\theta \in [0,1]$, and if $m > 0$ it vanishes if
and only if $\theta = 1/2$.*

*Proof.* The identity is Theorem 11.10 rearranged. Nonnegativity and the
equality case follow from Theorem 11.5 together with $m \ge 0$; when $m > 0$ one
may cancel $m$. $\square$

### 11.4 Interpretation: geometry times taste

Theorem 11.11 is the paper's cleanest statement of the interaction between
structure and style:

$$ \underbrace{m}_{\text{geometry}} \times
   \underbrace{\bigl(1 - H_2(\theta)\bigr)}_{\text{taste}}
   \;=\; \text{total information lost to stylistic bias.} $$

The two factors are completely decoupled. The orbit count $m$ is determined by
the symmetry group and the grid, and computed by Burnside's lemma from
fixed-point data (Section 4). The per-orbit deficit $1 - H_2(\theta)$ depends
only on the onset density and not at all on the geometry. Doubling the grid, or
weakening the symmetry group, doubles both the raw capacity and the absolute
cost of the same taste; the price *per orbit* is unchanged.

Some representative per-orbit deficits: $\theta = 0.5$ costs $0$ bits per orbit;
$\theta = 0.3$ costs $\approx 0.119$; $\theta = 0.2$ costs $\approx 0.278$;
$\theta = 0.1$ costs $\approx 0.531$; $\theta = 0.05$ costs $\approx 0.714$.

---

## 12. Algorithms

Everything above is effective. We record the three procedures explicitly.

**Algorithm A (Burnside capacity).** *Input:* a finite cell set $\alpha$ and a
finite list of group elements acting on it. *Output:* the orbit count $m$ and
the capacity $2^m$.
1. For each $g$, count $|\mathrm{Fix}(g)| = |\{a : g\cdot a = a\}|$.
2. Sum and divide by $|G|$ to get $m$ (Theorem 4.3).
3. Return $(m, 2^m)$.

Cost: $\Theta(|G|\cdot|\alpha|)$ evaluations of the action — no orbit
enumeration required. When the fixed-point counts are known in closed form
(Sections 5–7), the cost is $O(1)$.

**Algorithm B (Orbit enumeration by union–find).** *Input:* the cell set and
generators. *Output:* the orbit partition. Union each cell $a$ with $g\cdot a$
for each generator $g$; the resulting classes are the orbits. Cost
$\Theta(|\alpha|\cdot|\text{gens}|\cdot\alpha^{-1})$ with the inverse-Ackermann
factor of union–find. This is the direct route, useful as a cross-check on
Algorithm A and for exhibiting the orbits themselves.

**Algorithm C (Canon synthesis at a prescribed onset count).** *Input:* $p,q,g$
and a target $k$. *Output:* a canon at distance $g$ with exactly $k$ onsets, or
a proof of impossibility.
1. Compute $d = \mathrm{ord}(g) = p/\gcd(p,g)$.
2. If $d \nmid k$ or $k > pq$, report impossibility (Theorem 10.9).
3. Otherwise set $j = k/d$, take the union of any $j$ orbits of the shift group
   generated by $g$, and return its indicator pattern (Theorem 10.8).

Cost $\Theta(pq)$. The correctness of both branches is Theorem 10.9: the test in
step 2 is exactly right, so step 3 never fails.

---

## 13. Applications

**Style capacity budgeting.** Given a symmetry hypothesis about a repertoire,
Algorithm A returns an exact number of bits available to a pattern in that
style. This is a hard upper bound on the description length of any generative
model constrained to be symmetric (Theorem 11.3), and hence a principled
parameter-count target.

**Detecting over-constraint.** Theorems 8.2 and 8.3 quantify the marginal cost
of each added symmetry. A symmetry that costs nothing is redundant given the
others; a symmetry that costs many bits should be justified.

**Falsification of structural labels.** Theorem 10.9 turns "this is a canon at
distance $g$" into an arithmetic test on the onset count, and guarantees the
test is neither over- nor under-restrictive. The same template applies to any
label that can be stated as invariance under a specified transformation.

**Model calibration.** Theorem 11.10 gives a closed-form entropy for the
one-parameter family of orbit-Bernoulli models. Matching the empirical onset
density of a corpus to $\theta$ yields a closed-form predicted entropy
$m H_2(\theta)$, against which measured corpus entropy can be compared; a
significant gap indicates dependence between orbits that the product model does
not capture.

**Grid design.** Corollary 6.3 says which point-group symmetries are even
*available* on a given grid. If quarter-turn structure is wanted, the grid must
be square; on a rectangular grid the axis reflections and half turn are all that
survive.

---

## 14. Discussion and limitations

The results here are exact and unconditional, but their scope should be stated
plainly.

*No wallpaper classification is claimed.* We have not proved that rhythmic
patterns are classified by the seventeen planar crystallographic groups, and
Corollary 6.3 indicates why the claim needs support: on a non-square torus, half
of the relevant point group does not descend. A genuine classification requires
planar Euclidean isometries, lattices, discreteness, and compactness of the
quotient as prior definitions, and then a theorem — not an analogy.

*Musical labels are hypotheses.* The canon predicate (Definition 10.1) is a
model of how to proceed: a label is worth stating when it has a testable
numerical consequence. Names such as "round" or "twelve-bar blues" are not
consequences of any classification above and should be treated as conjectures
about repertoire until given predicates of their own.

*Corpus claims require a protocol.* Any distributional statement about real
music — that a given fraction of patterns exhibits a given symmetry — depends on
an encoding of onset grids, a tolerance rule for quantization, a symmetry
detection procedure, and a statistical null model. None of these is supplied
here, and none of the theorems above should be read as a corpus claim.

*The product model is a first approximation.* The orbit-Bernoulli family is the
natural one-parameter family, and Theorem 11.10 computes its entropy exactly.
But real styles correlate orbits (a kick on the downbeat predicts a kick on beat
three). Theorem 11.3 still bounds such models; computing their deficits requires
a richer family.

---

## 15. Future directions

1. **Faithful wallpaper-group models.** Define planar Euclidean isometries,
   lattices, discreteness, and compact quotient conditions, and only then
   attempt an exact seventeen-group classification.
2. **Finite toroidal drum grids in full generality.** Determine, for each
   $(p,q)$, the complete group of planar symmetries that descends, extending
   Corollary 6.3 from the point group to the full space group with its glides.
3. **Entropy beyond product models.** Compute deficits for Markov and
   pairwise-interaction models on the orbit set, and identify the maximum-entropy
   model matching prescribed orbit correlations.
4. **Burnside for larger symmetry groups.** Evaluate the fixed-point sums for
   the full dihedral and space groups on the torus, obtaining closed-form
   capacities for every crystallographic type that descends.
5. **Corpus methodology.** Specify a reproducible encoding of onset grids,
   tolerance rules, a symmetry detection algorithm, and a statistical null
   model, before testing distributional claims.
6. **Musical interpretation validation.** Give formal predicates for named
   structures beyond the canon, each with a derived numerical signature and a
   sharpness theorem in the style of Theorem 10.9.

---

## 16. Conclusion

The information content of a symmetry-constrained pattern space is exactly its
orbit count, in bits. Burnside's lemma computes that count from fixed-point
data, which for each crystallographic generator on a toroidal grid is a one-line
calculation, yielding four closed-form capacities: $2^q$ for full translation
invariance, $2^{(pq+\tau(p)\tau(q))/2}$ for point reflection,
$2^{(p^2+2\tau(p)+\tau(p)^2)/4}$ for quarter turns on a square torus, and
$2^{pq/2}$ for glides. Capacity is antitone in the symmetry group, strictly so
exactly when orbits are genuinely fused; every subgroup is realized as the
symmetry group of an explicit pattern; the canon label has a complete onset
spectrum; and every probabilistic model respecting the symmetry obeys an
entropy ceiling of $m$ bits, with the natural biased model falling short by
exactly $m(1 - H_2(\theta))$ — one fixed cost per orbit.
