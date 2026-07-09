# Monochromatic Pythagorean Triples in Every Level Set of a Completely Multiplicative Coloring

## Abstract

We study Pythagorean triples $(x, y, z)$ with $x^2 + y^2 = z^2$ under
completely multiplicative colorings of the positive integers, that is,
maps $f : \mathbb{Z}_{>0} \to G$ into a finite abelian group $G$
satisfying $f(1) = 1$ and $f(mn) = f(m)f(n)$. A Pythagorean triple is
*monochromatic of color $\omega$* when $f(x) = f(y) = f(z) = \omega$. Our
central result is a **reduction**: the existence of a single monochromatic
Pythagorean triple of *any* color forces, for every color $\omega$ in the
image of $f$, the existence of a Pythagorean triple monochromatic of color
exactly $\omega$. Consequently the realizability of colors by monochromatic
triples is an *all-or-nothing* phenomenon governed by the image subgroup
of $f$. In particular, the special case $\omega = 1$ (the neutral color) is
logically equivalent to the full every-color statement, even though the
naive substitution $n \mapsto f(n)/\omega$ fails to be multiplicative. The
argument rests on two structural facts: the scale invariance of
Pythagorean triples, and the fact that the image of a completely
multiplicative map into a *finite* group is a subgroup. We isolate the
genuinely analytic content — the existence of even one monochromatic
triple — as an explicit hypothesis and derive several unconditional
corollaries, including that a monochromatic $(3,4,5)$ suffices to realize
all colors.

**Keywords.** Pythagorean triples, completely multiplicative functions,
roots of unity, monochromatic configurations, level sets, finite abelian
groups, scale invariance, arithmetic Ramsey theory.

## 1. Introduction

The interaction between multiplicative structure and additive Diophantine
configurations is a persistent theme in number theory. Pythagorean
triples — integer solutions of $x^2 + y^2 = z^2$ — are the archetypal
additive configuration, while completely multiplicative functions are the
archetypal carriers of multiplicative structure. A completely
multiplicative coloring assigns to each positive integer a "color" in a
finite abelian group $G$ in a way that respects multiplication:
$$f(1) = 1, \qquad f(mn) = f(m)f(n) \quad (m, n \ge 1).$$
The prototypical example takes $G = \mu_k$, the group of $k$-th roots of
unity; then $f$ is a Dirichlet-character-like $k$-coloring of the
integers. However, nothing in our arguments uses more than the finite
abelian group structure, so we state everything at that level of
generality; $\mu_k$ is then a special case.

Given a color $\omega \in G$, its **level set** (or **color class**) is
the fiber $f^{-1}(\{\omega\})$. We ask a Ramsey-type question:

> Does every level set of a completely multiplicative coloring contain a
> Pythagorean triple?

Equivalently: for each color $\omega$ appearing in $f$, is there a
Pythagorean triple $(x, y, z)$ with $f(x) = f(y) = f(z) = \omega$?

At first sight the general color $\omega$ seems strictly harder than the
neutral color $\omega = 1$. Indeed the natural attempt to reduce a general
color to the neutral one — replacing $f$ by $n \mapsto f(n)\omega^{-1}$ —
destroys multiplicativity, since $f(mn)\omega^{-1} \ne
(f(m)\omega^{-1})(f(n)\omega^{-1})$ in general. This paper shows that,
despite the failure of that naive substitution, the reduction *does* hold,
by a completely different mechanism: one moves the *triple*, not the
*coloring*.

### 1.1 Summary of contributions

1. **Scale invariance as a coloring engine (Section 3).** Pythagorean
   triples are invariant under positive scaling; under a multiplicative
   coloring, scaling by $t$ shifts the common color of a monochromatic
   triple by the factor $f(t)$.
2. **The image is a subgroup (Section 4).** For a completely
   multiplicative $f$ into a *finite* group, the set of realized colors is
   a subgroup. Closure under products is immediate; closure under inverses
   uses finiteness via $g^{-1} = g^{|G|-1}$.
3. **The Reduction (Section 5).** One monochromatic triple of any color
   yields a monochromatic triple of every color in the image.
4. **The All-or-Nothing Dichotomy and corollaries (Section 5–6).** The
   neutral-color case is equivalent to the full statement; a monochromatic
   $(3,4,5)$ suffices; non-vacuity is witnessed by the trivial coloring.

## 2. Definitions and setup

Throughout, $G$ is a finite abelian group written multiplicatively, with
identity $1$, and $f : \mathbb{Z}_{\ge 0} \to G$ is defined on all
naturals but only constrained and used on the positive integers.

**Definition 2.1 (Completely multiplicative coloring).** A function
$f : \mathbb{Z}_{\ge 0} \to G$ is a *completely multiplicative coloring*
if $f(1) = 1$ and $f(mn) = f(m)f(n)$ for all positive integers $m, n$.

**Definition 2.2 (Pythagorean triple).** A triple $(x, y, z)$ of positive
integers is a *Pythagorean triple* if $x^2 + y^2 = z^2$. We write
$\mathrm{IsPyth}(x,y,z)$ for the predicate $x, y, z > 0 \wedge x^2 + y^2 =
z^2$.

**Definition 2.3 (Monochromatic triple).** A triple $(x, y, z)$ is
*monochromatic* under $f$ if $f(x) = f(y)$ and $f(y) = f(z)$. It is
*monochromatic of color $\omega$* if in addition $f(x) = f(y) = f(z) =
\omega$.

**Definition 2.4 (Image).** A color $g \in G$ is *in the image* of $f$,
written $g \in \operatorname{Im}(f)$, if there exists a positive integer
$n$ with $f(n) = g$.

## 3. Scale invariance

**Lemma 3.1 (Scaling preserves Pythagorean triples).** *If
$\mathrm{IsPyth}(x,y,z)$ and $t \ge 1$, then $\mathrm{IsPyth}(tx, ty,
tz)$.*

*Proof.* Positivity of $tx, ty, tz$ follows from positivity of $t, x, y,
z$. For the equation,
$$(tx)^2 + (ty)^2 = t^2(x^2 + y^2) = t^2 z^2 = (tz)^2. \qquad \blacksquare$$

**Lemma 3.2 (Colors under scaling).** *If $f$ is a completely
multiplicative coloring and $t, n \ge 1$, then $f(tn) = f(t)f(n)$.* This
is immediate from Definition 2.1 but is worth recording: scaling every
entry of a triple by $t$ multiplies each of the three colors by the single
common factor $f(t)$. Hence a monochromatic triple of color $v$ becomes,
after scaling by $t$, a monochromatic triple of color $f(t)\,v$.

**Lemma 3.3 (Powers).** *If $f$ is a completely multiplicative coloring
and $n \ge 1$, then $f(n^j) = f(n)^j$ for every $j \ge 0$.*

*Proof.* Induction on $j$. The base case $f(n^0) = f(1) = 1 = f(n)^0$ is
the normalization. For the step, $f(n^{j+1}) = f(n^j \cdot n) = f(n^j)f(n)
= f(n)^j f(n) = f(n)^{j+1}$ using multiplicativity and the inductive
hypothesis. $\blacksquare$

## 4. The image is a subgroup

We now show that the realized colors form a subgroup of $G$. Only closure
under inverses requires finiteness.

**Lemma 4.1 (Identity).** *The neutral color satisfies $1 \in
\operatorname{Im}(f)$.*

*Proof.* $f(1) = 1$ with $1 > 0$. $\blacksquare$

**Lemma 4.2 (Closure under products).** *If $a, b \in
\operatorname{Im}(f)$ then $ab \in \operatorname{Im}(f)$.*

*Proof.* Write $a = f(m)$, $b = f(n)$ with $m, n > 0$. Then $ab = f(m)f(n)
= f(mn)$ and $mn > 0$. $\blacksquare$

**Lemma 4.3 (Closure under inverses).** *If $g \in \operatorname{Im}(f)$
then $g^{-1} \in \operatorname{Im}(f)$.*

*Proof.* Write $g = f(n)$ with $n > 0$. Since $G$ is finite of order $N =
|G|$, every element satisfies $g^N = 1$, hence $g^{N-1} \cdot g = g^N = 1$,
so $g^{-1} = g^{N-1}$. By Lemma 3.3, $g^{N-1} = f(n)^{N-1} = f(n^{N-1})$,
and $n^{N-1} > 0$. Therefore $g^{-1} = f(n^{N-1}) \in \operatorname{Im}(f)$.
$\blacksquare$

**Proposition 4.4.** *$\operatorname{Im}(f)$ is a subgroup of $G$.*

*Proof.* Immediate from Lemmas 4.1–4.3. $\blacksquare$

The role of finiteness is essential and confined to Lemma 4.3. For a
general infinite target group, the image of a completely multiplicative map
is only a submonoid, and the reduction below can fail.

## 5. The reduction and the dichotomy

**Theorem 5.1 (The Reduction).** *Let $f$ be a completely multiplicative
coloring into a finite abelian group $G$. Suppose there exists a single
monochromatic Pythagorean triple — that is, $(a, b, c)$ with
$\mathrm{IsPyth}(a,b,c)$, $f(a) = f(b)$, and $f(b) = f(c)$. Then for every
color $\omega \in \operatorname{Im}(f)$ there exists a Pythagorean triple
$(x, y, z)$ with $f(x) = f(y) = f(z) = \omega$.*

*Proof.* Let $v_0 := f(a)$; by monochromaticity $f(a) = f(b) = f(c) = v_0$,
and $v_0 \in \operatorname{Im}(f)$ since $a > 0$. Fix a target color
$\omega \in \operatorname{Im}(f)$. By Proposition 4.4, the "color gap"
$v_0^{-1}\omega$ lies in $\operatorname{Im}(f)$: indeed $v_0^{-1} \in
\operatorname{Im}(f)$ by Lemma 4.3 and the product with $\omega$ stays in
the image by Lemma 4.2. Choose $t > 0$ with $f(t) = v_0^{-1}\omega$.

Set $(x, y, z) := (ta, tb, tc)$. By Lemma 3.1 this is a Pythagorean
triple. Its colors are
$$f(ta) = f(t)f(a) = (v_0^{-1}\omega)\,v_0 = \omega,$$
using commutativity to cancel $v_0^{-1} v_0 = 1$; identically $f(tb) =
f(t)f(b) = (v_0^{-1}\omega)v_0 = \omega$ and $f(tc) =
(v_0^{-1}\omega)v_0 = \omega$. Thus $(x,y,z)$ is monochromatic of color
exactly $\omega$. $\blacksquare$

The single algebraic identity powering the color computation is the
commutative cancellation $v^{-1} w\, v = w$, valid in any abelian group.

**Theorem 5.2 (All-or-Nothing Dichotomy).** *Let $f$ be a completely
multiplicative coloring into a finite abelian group. Then the following are
equivalent:*
1. *there exists a monochromatic Pythagorean triple of the neutral color
   $1$; and*
2. *for every $\omega \in \operatorname{Im}(f)$ there exists a Pythagorean
   triple monochromatic of color $\omega$.*

*Proof.* $(1 \Rightarrow 2)$: A triple monochromatic of color $1$ is in
particular monochromatic, so Theorem 5.1 applies and yields a triple of
every color. $(2 \Rightarrow 1)$: The neutral color $1$ lies in
$\operatorname{Im}(f)$ by Lemma 4.1, so instantiating (2) at $\omega = 1$
gives a monochromatic triple of color $1$. $\blacksquare$

Theorem 5.2 formally refutes the intuition that the general-color problem
is strictly harder than the neutral case: the two are equivalent. The
genuine difficulty is not *which* color, but whether *any* monochromatic
triple exists at all.

## 6. Corollaries and non-vacuity

**Corollary 6.1 (The $(3,4,5)$ criterion).** *If $f(3) = f(4) = f(5)$,
then for every $\omega \in \operatorname{Im}(f)$ there is a Pythagorean
triple monochromatic of color $\omega$.*

*Proof.* $(3,4,5)$ is a Pythagorean triple ($9 + 16 = 25$) that is
monochromatic by hypothesis; apply Theorem 5.1. $\blacksquare$

**Corollary 6.2 (Non-vacuity).** *The hypothesis of Theorem 5.1 is
satisfiable. For the trivial coloring $f \equiv 1$, the triple $(3,4,5)$ is
monochromatic, so every color (here only $1$) is realized.*

These corollaries guard against vacuous truth: the reduction is not empty,
and it has unconditional instances whenever a concrete small triple lands
in a single color class.

## 7. Relationship to the analytic core

The results above cleanly separate two layers of the general problem.

- **The algebraic/combinatorial layer** — passing from one monochromatic
  triple to all colors — is *fully settled* by scale invariance and the
  subgroup structure of the image (Sections 3–5).
- **The analytic layer** — the existence of even one monochromatic
  Pythagorean triple for an arbitrary completely multiplicative coloring —
  is the remaining deep input. We isolate it as the hypothesis $\mathrm{hex}$
  of Theorem 5.1 rather than reprove it.

The motivating instance of the analytic layer is the case $G = \mu_k$ with
$\omega = 1$: for $\varepsilon$ small enough, an approximate-concentration
argument forces three multiplicative values on a Pythagorean configuration
to coincide, and since $\mu_k$ is discrete the near-coincidence is an exact
coincidence. Our reduction shows that establishing this one existence
statement — for any single color — immediately yields the full every-color
theorem, so future analytic effort can be concentrated precisely there.

## 8. Algorithms

The proofs are constructive, and the constructions translate directly into
algorithms.

**Algorithm A (Color transport).** Given a monochromatic seed triple
$(a, b, c)$ of color $v_0$, a completely multiplicative coloring $f$, and a
target color $\omega \in \operatorname{Im}(f)$, produce a triple
monochromatic of color $\omega$:
1. compute the gap $\gamma := v_0^{-1}\omega$;
2. search for a positive integer $t$ with $f(t) = \gamma$ (guaranteed to
   exist because $\gamma \in \operatorname{Im}(f)$);
3. return $(ta, tb, tc)$.

**Algorithm B (Inverse color as a power).** Given $g = f(n)$ and the group
order $N = |G|$, return $n^{N-1}$; then $f(n^{N-1}) = g^{-1}$. This makes
Lemma 4.3 executable and supplies inverse colors when transporting.

**Algorithm C (Spectrum enumeration).** Given $f$ restricted to $\{1,
\dots, M\}$, enumerate the realized colors $\{f(n) : 1 \le n \le M\}$; once
one monochromatic triple is found among small integers, Algorithm A
realizes the entire enumerated spectrum.

## 9. Applications and interpretation

**Multiplicative $k$-colorings.** With $G = \mu_k$, a completely
multiplicative coloring is precisely a completely multiplicative $k$-valued
function. The dichotomy says: either no color class contains a Pythagorean
triple, or every color class does. This is a structural constraint on how
such colorings can avoid monochromatic right triangles.

**Contrast with additive colorings.** The celebrated result that any
$2$-coloring of the integers admits a monochromatic Pythagorean triple is
an additive/combinatorial statement with no multiplicative hypothesis. Our
setting is orthogonal: we *assume* multiplicative structure and derive that
the color spectrum of monochromatic triples is all-or-nothing, a
conclusion that additive colorings need not satisfy.

**Design of extremal colorings.** For anyone attempting to *build* a
multiplicative coloring with no monochromatic Pythagorean triple, the
dichotomy shows it suffices to block a single color — say the neutral one —
since blocking one blocks all, and conversely admitting one admits all.

## 10. Discussion and future work

The reduction reorganizes the problem: it converts a family of questions
indexed by colors into a single existence question, and it exposes the
coset structure of "which scale factors work." The scaling engine is not
special to squares; any homogeneous, scale-invariant Diophantine relation
inherits the same all-or-nothing law.

Directions for further study:

1. **Existence of a single monochromatic triple for every completely
   multiplicative coloring.** The reduction shows this lone statement
   carries the whole general-color problem; the remaining difficulty is
   analytic — forcing the first coincidence of three multiplicative values
   on a Pythagorean configuration.
2. **Density of realizing scales.** The scale factor must land in a fixed
   coset of the level set of $f$; quantifying the natural density of such
   integers is a multiplicative-function counting problem governed by the
   index of the color subgroup.
3. **Simultaneous monochromatic triples across colors.** Upgrade
   individual realizability to a disjoint family of monochromatic triples
   realizing all colors simultaneously, spacing scales along a fast-growing
   sequence to ensure disjointness — a Ramsey-type partition statement.
4. **Beyond Pythagorean configurations.** Extend the reduction to any
   homogeneous Diophantine relation invariant under simultaneous scaling,
   characterizing the color spectrum of monochromatic solutions in general.

## 11. Conclusion

For completely multiplicative colorings into a finite abelian group, the
realizability of colors by monochromatic Pythagorean triples is governed
entirely by the image subgroup and is an all-or-nothing invariant. A single
monochromatic triple of any color propagates to every color via triple
scaling; the neutral-color case is equivalent to the full statement; and a
monochromatic $(3,4,5)$ suffices unconditionally. The only remaining
ingredient is the existence of one monochromatic triple — the analytic
heart of the matter, now cleanly separated from the algebraic scaffolding.
