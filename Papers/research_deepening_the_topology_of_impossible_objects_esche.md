# The First Cohomology of a Cyclic Figure: A Homological Theory of Impossible Objects

## Abstract

Impossible figures — the Penrose triangle, Escher's endless staircase, the
one-sided Möbius band — are usually treated as curiosities of visual
perception. We develop them instead as objects of algebraic topology. A
cyclic figure is modelled as a discrete arrangement of $n$ overlapping
patches carrying local *depth increments* valued in an abelian group $A$.
We organise this local data into a two-term cochain complex whose maps are
the *coboundary* (the increment forced by a global height assignment) and
the *holonomy* (the total increment accumulated once around the loop). Our
main results are: (i) both maps are group homomorphisms; (ii) holonomy is
surjective; (iii) the complex is **exact** — the coboundaries coincide
exactly with the figures of vanishing holonomy; and consequently (iv) the
first cohomology group of a cyclic figure is *canonically isomorphic to the
coefficient group*, $H^1 \cong A$, with holonomy realising the isomorphism.
We deduce that a figure is realizable if and only if its holonomy vanishes,
that holonomy is a complete invariant of the cohomology class, that the
Penrose triangle is impossible and generates the integral impossibility
group, and that a band with an odd number of orientation flips is
non-orientable because it carries the nonzero class of $H^1(S^1;
\mathbb{Z}/2)$. The development is a discrete, combinatorial analogue of
the classical computation $H^1(S^1; A) \cong A$, and it turns the informal
notion of an "impossible object" into a precise, computable topological
obstruction.

## 1. Introduction

An impossible figure is a two-dimensional drawing that the eye reads as a
coherent three-dimensional object, even though no such object exists. The
Penrose triangle presents three mutually perpendicular beams, each junction
locally consistent, whose global assembly cannot be realised in Euclidean
space. Escher's *Ascending and Descending* depicts a rectangular staircase
on which every flight rises yet the loop returns to its starting height.
*Waterfall* routes a stream downhill along a closed circuit.

The unifying feature is a conflict between **local** consistency and
**global** consistency. Each junction, edge, or overlap of the figure is
individually plausible; the contradiction appears only when one traverses a
closed loop and demands that the accumulated data return to its starting
value. This is precisely the situation that cohomology was invented to
measure: the failure of locally consistent data to patch into a global
section.

This paper makes that analogy exact for cyclic (one-dimensional, loop-like)
figures. We define a cochain complex directly from the combinatorial data
of the figure, identify its coboundary and holonomy maps, and prove the
complex is exact. The payoff is a complete classification: the group of
impossibility classes of a cyclic figure is canonically isomorphic to the
coefficient group, and holonomy is the isomorphism. Every downstream fact
— the impossibility of the Penrose triangle, the non-orientability of the
Möbius band and Klein bottle, the "only one impossible triangle up to
strength" phenomenon — follows as a corollary.

Throughout, $n \geq 1$ is the number of patches (we assume $n \neq 0$), and
$A$ is an arbitrary abelian group written additively. We index patches by
the cyclic group $\mathbb{Z}/n$, so that patch $i$ overlaps patch $i+1$
with indices read modulo $n$.

## 2. Definitions

**Definition 2.1 (Cochain / figure).** A *cyclic figure* on $n$ patches
with coefficients in $A$ is a function
$$t : \mathbb{Z}/n \to A,$$
also called a $1$-*cochain*. The value $t_i$ is the *local increment* across
the overlap between patch $i$ and patch $i+1$: for a depth figure it is the
apparent change in depth, for an orientation figure the apparent flip of
handedness. We write $C^1 = (\mathbb{Z}/n \to A)$ for the group of all
figures, under pointwise addition.

**Definition 2.2 (Gauge / coboundary).** A *gauge* is a function
$h : \mathbb{Z}/n \to A$ assigning a global value (a height, or a depth
datum) to each patch. Its *coboundary* is the figure
$$(\delta h)_i \;=\; h_{i+1} - h_i, \qquad i \in \mathbb{Z}/n.$$
We write $C^0 = (\mathbb{Z}/n \to A)$ for the group of gauges. A figure of
the form $t = \delta h$ is called *realizable* (or *trivial*): it is exactly
the pattern of increments produced by an honest global assignment.

**Definition 2.3 (Holonomy).** The *holonomy* of a figure $t$ is the total
increment accumulated once around the cycle,
$$\mathrm{hol}(t) \;=\; \sum_{i \in \mathbb{Z}/n} t_i \;\in\; A.$$
Holonomy is the numerical measure of the figure's global inconsistency.

**Definition 2.4 (Cohomologous figures / first cohomology).** Two figures
$t, s$ are *cohomologous*, written $t \sim s$, if they differ by a
coboundary:
$$t \sim s \iff \exists\, h,\; t - s = \delta h.$$
This is an equivalence relation, and the quotient group
$$H^1 \;=\; C^1 / \mathrm{im}(\delta)$$
is the *first cohomology group* of the cyclic figure. A cohomology class is
the *impossibility class* of a figure — the invariant that persists after
all realizable adjustments are quotiented away.

These definitions assemble into the two-term cochain complex
$$C^0 \xrightarrow{\ \delta\ } C^1 \xrightarrow{\ \mathrm{hol}\ } A. \tag{$\ast$}$$

## 3. Main results

### 3.1 The maps are homomorphisms

**Proposition 3.1.** The coboundary $\delta : C^0 \to C^1$ and the holonomy
$\mathrm{hol} : C^1 \to A$ are group homomorphisms.

*Proof sketch.* Both are built from addition. For the coboundary,
$(\delta(h+g))_i = (h+g)_{i+1} - (h+g)_i = (h_{i+1}-h_i) + (g_{i+1}-g_i) =
(\delta h)_i + (\delta g)_i$, and $\delta 0 = 0$. For holonomy, the sum of
a pointwise sum is the sum of the sums:
$\mathrm{hol}(t+s) = \sum_i (t_i + s_i) = \sum_i t_i + \sum_i s_i =
\mathrm{hol}(t) + \mathrm{hol}(s)$, and $\mathrm{hol}(0) = 0$. In
particular holonomy respects differences, $\mathrm{hol}(t - s) =
\mathrm{hol}(t) - \mathrm{hol}(s)$. $\qquad\blacksquare$

### 3.2 Holonomy is surjective

**Proposition 3.2 (Surjectivity).** For every $a \in A$ there is a figure
$t$ with $\mathrm{hol}(t) = a$.

*Proof sketch.* Concentrate the entire increment on a single overlap:
define $t_0 = a$ and $t_i = 0$ for $i \neq 0$. Then $\mathrm{hol}(t) =
\sum_i t_i = a$. $\qquad\blacksquare$

Interpreted physically: every possible degree and kind of impossibility is
attained by some figure — one need only put all of the discrepancy at one
corner.

### 3.3 Exactness: coboundaries are exactly the zero-holonomy figures

**Lemma 3.3 (Coboundaries are closed).** For every gauge $h$,
$\mathrm{hol}(\delta h) = 0$.

*Proof sketch.* Compute
$$\mathrm{hol}(\delta h) = \sum_{i} \big(h_{i+1} - h_i\big)
= \sum_i h_{i+1} - \sum_i h_i.$$
The map $i \mapsto i+1$ is a bijection of $\mathbb{Z}/n$, so the two sums
range over the same multiset of values and are equal; their difference is
$0$. This is the telescoping cancellation around the loop. $\qquad
\blacksquare$

**Lemma 3.4 (Discrete Poincaré lemma).** If $\mathrm{hol}(t) = 0$, then
$t = \delta h$ for some gauge $h$; explicitly one may take the *partial
sums*
$$h_i \;=\; \sum_{j=0}^{i-1} t_j \qquad (h_0 = 0).$$

*Proof sketch.* For each patch $i$ that is not the closing seam, $h_{i+1} -
h_i = t_i$ directly from the definition of partial sums. The only subtlety
is the wrap-around index, where one must check $h_0 - h_{n-1} = t_{n-1}$;
equivalently that the full partial sum $h_0$ (interpreted after a complete
lap) returns consistently. Writing out the last step, this identity is
exactly $\sum_{j=0}^{n-1} t_j = 0$, i.e. the hypothesis $\mathrm{hol}(t) =
0$. Hence the partial-sum gauge realises $t$. $\qquad\blacksquare$

**Theorem 3.5 (Exactness of the figure complex).** The complex $(\ast)$ is
exact at $C^1$:
$$\mathrm{im}(\delta) \;=\; \ker(\mathrm{hol}).$$

*Proof.* The inclusion $\mathrm{im}(\delta) \subseteq \ker(\mathrm{hol})$
is Lemma 3.3. The reverse inclusion $\ker(\mathrm{hol}) \subseteq
\mathrm{im}(\delta)$ is Lemma 3.4. $\qquad\blacksquare$

**Theorem 3.6 (Realizability criterion).** A figure $t$ is realizable if
and only if $\mathrm{hol}(t) = 0$.

*Proof.* Immediate from Theorem 3.5: realizable means $t \in
\mathrm{im}(\delta)$, and vanishing holonomy means $t \in
\ker(\mathrm{hol})$. $\qquad\blacksquare$

### 3.4 Classification: $H^1 \cong A$

**Theorem 3.7 (Holonomy is a complete invariant).** Two figures are
cohomologous if and only if they have equal holonomy:
$$t \sim s \iff \mathrm{hol}(t) = \mathrm{hol}(s).$$

*Proof.* If $t \sim s$ then $t - s = \delta h$, so by Lemma 3.3
$\mathrm{hol}(t) - \mathrm{hol}(s) = \mathrm{hol}(t - s) =
\mathrm{hol}(\delta h) = 0$. Conversely, if $\mathrm{hol}(t) =
\mathrm{hol}(s)$, then $\mathrm{hol}(t - s) = 0$, so by Lemma 3.4
$t - s = \delta h$ for some $h$, i.e. $t \sim s$. $\qquad\blacksquare$

**Corollary 3.8 (First cohomology of a cyclic figure).** Holonomy induces a
group isomorphism
$$H^1 \;\xrightarrow{\ \cong\ }\; A.$$

*Proof.* By Proposition 3.1 holonomy is a homomorphism $C^1 \to A$; by
Theorem 3.5 its kernel is exactly $\mathrm{im}(\delta)$, so it descends to
an injective homomorphism $\overline{\mathrm{hol}} : H^1 = C^1/\mathrm{im}
(\delta) \to A$. By Proposition 3.2 it is surjective. Hence
$\overline{\mathrm{hol}}$ is an isomorphism. $\qquad\blacksquare$

This is the discrete counterpart of the classical fact $H^1(S^1; A) \cong
A$. The cyclic arrangement of overlapping patches is a combinatorial
circle; its first cohomology is "one-dimensional," free of rank one over
$A$, and holonomy is the coordinate.

### 3.5 The Penrose triangle

**Theorem 3.9 (Penrose impossibility).** Over $A = \mathbb{Z}$ with $n = 3$,
the figure $p$ defined by $p_0 = 1$, $p_1 = p_2 = 0$ has $\mathrm{hol}(p) =
1 \neq 0$; hence the Penrose triangle is not realizable.

**Theorem 3.10 (Penrose generation).** The class $[p] \in H^1 \cong
\mathbb{Z}$ is a generator. Every integral impossibility class of the
triangle is an integer multiple $k[p]$, corresponding under holonomy to
$k \in \mathbb{Z}$.

*Proof sketch.* By Corollary 3.8, $H^1 \cong \mathbb{Z}$ with $[p]$ mapping
to $\mathrm{hol}(p) = 1$, and $1$ generates $\mathbb{Z}$. $\qquad
\blacksquare$

Thus there is essentially *one* impossible triangle, occurring in all
integer strengths $k$: the drawing whose beams "gain" $k$ units of depth
per lap.

### 3.6 Orientation, the Möbius band and the Klein bottle

Taking $A = \mathbb{Z}/2$ reinterprets the increments as *orientation
flips*: $t_i = 1$ if the local sense of handedness reverses across overlap
$i$, and $t_i = 0$ otherwise. Holonomy is now the parity of the number of
flips.

**Theorem 3.11 (Orientation obstruction).** A cyclic band with an odd
number of orientation flips has holonomy equal to the nonzero element of
$\mathbb{Z}/2$; its class in $H^1(S^1; \mathbb{Z}/2) \cong \mathbb{Z}/2$ is
nonzero, so the band admits no consistent global orientation. It is
therefore non-orientable — a Möbius band.

*Proof sketch.* The number of flips is odd iff its residue mod $2$ is $1$,
which is exactly $\mathrm{hol}(t) = 1 \neq 0$ in $\mathbb{Z}/2$. By Theorem
3.6 no realizing gauge (no consistent global orientation) exists. $\qquad
\blacksquare$

Gluing two Möbius bands along their boundary produces a Klein bottle; its
non-orientability is again the odd-flip holonomy class, an obstruction in
$H^1(\,\cdot\,;\mathbb{Z}/2)$. The endless Escher staircase (holonomy in
$\mathbb{Z}$ or $\mathbb{R}$) and the one-sided Möbius band (holonomy in
$\mathbb{Z}/2$) are two instances of one theorem, differing only in the
coefficient group.

## 4. Algorithms

The theory is entirely computable. Two elementary algorithms extract every
invariant.

**Algorithm A (Holonomy / realizability test).** Given a figure $t$ as a
list of $n$ elements of $A$, compute $\mathrm{hol}(t) = \sum_i t_i$. The
figure is realizable iff the result is $0$. Complexity: $O(n)$ group
additions.

**Algorithm B (Gauge reconstruction).** Given a figure $t$ with
$\mathrm{hol}(t) = 0$, reconstruct a witnessing gauge by partial sums:
$h_0 = 0$ and $h_{i} = h_{i-1} + t_{i-1}$. Return $h$. Verifying $\delta h =
t$ takes another $O(n)$ additions. If $\mathrm{hol}(t) \neq 0$ the algorithm
correctly reports non-realizability (the partial sums fail to close).

**Algorithm C (Complete invariant / cohomology comparison).** To decide
whether two figures $t, s$ are cohomologous, compute $\mathrm{hol}(t)$ and
$\mathrm{hol}(s)$ and compare. They are cohomologous iff the holonomies are
equal (Theorem 3.7). Complexity: $O(n)$.

## 5. Applications

1. **Design and detection of impossible figures.** Any candidate loop of
depth increments can be tested for realizability in linear time; the
holonomy quantifies "how impossible" it is and in which direction.

2. **Discrete gauge theory and lattice models.** The complex $(\ast)$ is
the $U(1)$ (or general abelian) lattice gauge theory on a cycle: gauges are
$0$-cochains, figures are connections, holonomy is the Wilson loop, and
gauge equivalence is cohomology. The classification $H^1 \cong A$ is the
statement that the Wilson loop is the complete gauge-invariant observable.

3. **Orientation and non-orientability.** The $\mathbb{Z}/2$ specialisation
gives a purely combinatorial proof that odd-twist bands (Möbius, Klein) are
non-orientable, packaging the classical first Stiefel–Whitney obstruction
as a holonomy.

4. **Perception and computer vision.** Local depth cues extracted from an
image can be integrated around detected contours; a nonzero holonomy flags
a figure the visual system will read as "impossible," giving a principled
detector for such illusions.

## 6. Discussion

The value of the homological packaging is that it replaces a case-by-case
list of impossible figures with a single structural theorem. Impossibility
is not an accident of any particular drawing; it is the nonvanishing of a
cohomology class, and the cohomology is computed once and for all: $H^1
\cong A$. Every classical example is then a choice of coefficient group and
a choice of class — $\mathbb{Z}$ and a generator for the Penrose triangle,
$\mathbb{R}$ and a positive number for the Escher staircase, $\mathbb{Z}/2$
and the nonzero element for the Möbius band and Klein bottle.

The three pillars — surjectivity, exactness, and the resulting isomorphism
— have transparent meanings. Surjectivity says every impossibility is
attainable. Exactness says the *only* obstruction to realizability is
holonomy: once it vanishes, a consistent global structure can always be
built by partial summation. The isomorphism says holonomy is not merely
*necessary and sufficient* but a *complete invariant*, sorting figures into
classes indexed faithfully by $A$.

## 7. Future directions

This cycle deepened the cohomological theory of impossible figures in two
ways. First, the pointwise "realizable iff zero holonomy" dichotomy for
one-dimensional figures (Penrose triangle, Escher staircase) was upgraded
to a genuine homological statement: the coboundary and holonomy maps form
an exact two-term complex, and the first cohomology group of a cyclic
figure is *canonically isomorphic to the coefficient group*, with holonomy
realising the isomorphism. Second, the theory extends to genuinely
two-dimensional figures (Escher's *Waterfall*) on the discrete torus, where
realizability is governed by a *local* curvature and *two* global periods,
together with a discrete Stokes / Gauss–Bonnet identity forcing the total
curvature of any closed figure to vanish.

Three conjectures push the program further.

**Higher-genus impossibility and Betti numbers.** For a cyclic figure drawn
on a closed orientable surface of genus $g$, the group of impossibility
classes should be free of rank $2g$, and a figure realizable exactly when
it is flat and all $2g$ period integrals around a symplectic basis of loops
vanish. The pattern $\mathrm{rank} = 2g$ follows the settled cases
$H^1(S^1) \cong A$ (rank $1$) and $H^1(T^2) \cong A^2$ (rank $2$).

**Non-abelian monodromy and the Penrose "staircase group."** When the local
gluing data takes values in a non-abelian group $G$ (rotations of apparent
viewpoint, not merely depth shifts), a figure should be realizable iff its
*ordered monodromy* is trivial, with realizable figures forming a normal
subgroup whose quotient is a free product determined by the loop structure.
The abelian holonomy sum is the shadow of an ordered product of gluing
transformations; commutativity is exactly what collapses a conjugacy class
to a single number.

**Klein bottles and the orientation obstruction as a torsion class.** On a
non-orientable base (Möbius band, Klein bottle) the impossibility group
carries torsion, and the orientation obstruction is a distinguished
$2$-torsion class detecting one-sidedness independently of any depth data.

## 8. Conclusion

Impossible objects, long the playground of artists and psychologists, admit
a clean and complete mathematical theory. Modelling a cyclic figure as a
$1$-cochain valued in an abelian group, we proved that the coboundary and
holonomy maps form an exact complex, that holonomy is surjective, and hence
that the first cohomology group is canonically isomorphic to the coefficient
group. Realizability is equivalent to vanishing holonomy; holonomy is a
complete invariant of impossibility; the Penrose triangle generates the
integral theory; and orientation flips over $\mathbb{Z}/2$ recover the
non-orientability of the Möbius band and Klein bottle. The impossibility of
an object is, quite literally, a number one computes by walking around it.
