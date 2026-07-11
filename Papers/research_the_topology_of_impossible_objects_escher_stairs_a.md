# The Cohomology of Impossible Figures: Holonomy Obstructions for Penrose Triangles, Escher Staircases, and Non-Orientable Surfaces

## Abstract

Impossible figures such as the Penrose triangle and the Escher staircase are locally consistent yet globally unrealizable pictures. We give a complete and elementary mathematical account of this phenomenon by modeling a figure as a cyclic arrangement of overlapping patches carrying local reconciliation data valued in an abelian group. We define the **holonomy** of a figure as the total increment accumulated once around the cycle, and prove the master equivalence: *a figure is realizable — admits a global gauge inducing its local data — if and only if its holonomy vanishes.* This single theorem yields, as corollaries, rigorous impossibility proofs for the Penrose triangle and for any closed everywhere-ascending staircase; the non-orientability of the Möbius band and the Klein bottle (as an odd-holonomy phenomenon over $\mathbb{Z}/2$); and the statement that the impossibility class is a **complete invariant** whose values fill the entire group, so that $H^1 \cong A$. We show that impossibility is a genuinely *global* invariant by exhibiting a contrarian pair: uniform local data (the Penrose triangle) that is impossible, and maximally non-uniform data that is perfectly realizable. Finally we develop the **multiplicative** model over a commutative group — Penrose's original scaling-ambiguity formulation — in which realizability corresponds to buildability as a developable (flat) surface, package the total monodromy as a surjective group homomorphism whose kernel is exactly the developable figures, and refute the plausible conjecture that every overlap-nontrivial figure is impossible.

## 1. Introduction

An *impossible figure* is a two-dimensional drawing that the visual system interprets as a three-dimensional object, but for which no consistent three-dimensional object exists. The two most celebrated examples are the **Penrose triangle** (three beams forming a loop, each apparently receding) and the **Escher staircase** (a closed flight of stairs on which every step rises). Their paradoxical quality has a precise mathematical explanation, first articulated by Roger Penrose (*On the cohomology of impossible figures*, 1992): the impossibility is not a *local* defect. Every sufficiently small region of the drawing depicts a perfectly realizable fragment of a solid object. The contradiction is a *global* obstruction that only manifests when one traverses the entire loop.

This paper formalizes that insight completely and elementarily. The mathematical content is the first cohomology of a cyclic (circle-like) space with coefficients in an abelian group, but we require no prior cohomology: the entire theory reduces to the statement that a sum around a cycle telescopes to zero precisely when the summands are consecutive differences of a function on the cycle. We take this reduction as the definition and build everything on it, obtaining self-contained proofs of every classical impossibility result together with several sharpenings.

The contributions are:

1. A **master equivalence** (Theorem 3.4): realizability $\iff$ vanishing holonomy, over an arbitrary abelian coefficient group.
2. **Well-definedness on cohomology** (Proposition 4.1): the holonomy is invariant under gauge changes (coboundaries), so it is genuinely a class in $H^1$.
3. Concrete **impossibility theorems**: the Penrose triangle (Theorem 5.1), the closed ascending staircase (Theorem 5.2), and the Möbius/Klein non-orientability over $\mathbb{Z}/2$ (Theorems 6.1–6.2).
4. **Completeness and surjectivity** (Theorems 7.1–7.2): the impossibility class detects realizability exactly and attains every value, so $H^1 \cong A$.
5. A **contrarian analysis** (Section 8) proving impossibility is global not local: uniform data can be impossible; non-uniform data can be realizable.
6. A **multiplicative model** for developable surfaces (Section 9): developability $\iff$ trivial monodromy; the monodromy is a surjective homomorphism whose kernel is the developable figures; and a refutation of the conjecture that overlap-nontrivial figures are impossible.

## 2. The model

Fix an integer $n \geq 1$ and index the patches of a cyclic figure by the cyclic group $\mathbb{Z}/n$ of residues modulo $n$. Fix an abelian group $(A, +, 0)$ of coefficients.

**Definition 2.1 (Local increment data).** A *figure* (with $n$ patches and coefficients in $A$) is a function
$$t : \mathbb{Z}/n \to A.$$
The value $t_i := t(i)$ is the *increment* prescribed on the overlap from patch $i$ to patch $i+1$ (indices taken modulo $n$, so patch $n$ is patch $0$).

Two interpretations drive the applications:

- $A = \mathbb{R}$: $t_i$ is a **depth / height** increment. The Penrose triangle and the Escher staircase live here.
- $A = \mathbb{Z}/2$: $t_i$ is an **orientation** bit ($0$ = preserve, $1$ = reverse). The Möbius band and Klein bottle live here.

**Definition 2.2 (Holonomy).** The *holonomy* of a figure $t$ is the total increment accumulated once around the cycle,
$$\mathrm{hol}(t) \;:=\; \sum_{i \in \mathbb{Z}/n} t_i \;\in\; A.$$

**Definition 2.3 (Realizability).** A figure $t$ is *realizable* if its local increments arise from a global field ("gauge") $h : \mathbb{Z}/n \to A$ as consecutive differences:
$$\exists\, h : \mathbb{Z}/n \to A \quad \text{such that} \quad h(i+1) - h(i) = t_i \quad \text{for all } i \in \mathbb{Z}/n.$$
The field $h$ is the honest global quantity (depth, height, or orientation) that the figure purports to depict; a figure is realizable exactly when such an honest quantity exists.

In the language of simplicial/cellular cohomology of the circle $S^1$ triangulated with $n$ vertices, a figure $t$ is a $1$-cochain, realizability says $t$ is a coboundary, and the holonomy is the pairing of $t$ with the fundamental class of the loop. We do not need this language, but it explains the name "cohomology of impossible figures."

## 3. The master equivalence

**Lemma 3.1 (Holonomy of a coboundary vanishes).** For any $h : \mathbb{Z}/n \to A$,
$$\mathrm{hol}\big(i \mapsto h(i+1) - h(i)\big) = 0.$$

*Proof.* The map $i \mapsto i+1$ is a bijection of $\mathbb{Z}/n$, so $\sum_i h(i+1) = \sum_i h(i)$. Hence
$$\sum_i \big(h(i+1) - h(i)\big) = \sum_i h(i+1) - \sum_i h(i) = 0.$$
This is the discrete Fundamental Theorem of Calculus on the cycle: consecutive differences telescope. $\qquad\blacksquare$

**Proposition 3.2 (Forward direction).** If $t$ is realizable then $\mathrm{hol}(t) = 0$.

*Proof.* Let $h$ witness realizability, so $t_i = h(i+1) - h(i)$ for all $i$. Then $\mathrm{hol}(t) = \mathrm{hol}(i \mapsto h(i+1)-h(i)) = 0$ by Lemma 3.1. $\qquad\blacksquare$

**Proposition 3.3 (Reverse direction).** If $\mathrm{hol}(t) = 0$ then $t$ is realizable.

*Proof.* Define the *partial-sum gauge* by
$$h(i) \;:=\; \sum_{j=0}^{\,\mathrm{val}(i)-1} t(j),$$
where $\mathrm{val}(i) \in \{0, 1, \dots, n-1\}$ is the canonical representative of $i$. For any $i$ whose representative satisfies $\mathrm{val}(i)+1 < n$, the representative of $i+1$ is $\mathrm{val}(i)+1$, and
$$h(i+1) - h(i) = \sum_{j=0}^{\mathrm{val}(i)} t(j) - \sum_{j=0}^{\mathrm{val}(i)-1} t(j) = t(\mathrm{val}(i)) = t_i.$$
For the wrap-around step, where $\mathrm{val}(i) = n-1$ and $i+1 = 0$, we have $h(i+1) = h(0) = 0$ (empty sum) while $h(i) = \sum_{j=0}^{n-2} t(j)$. The hypothesis $\mathrm{hol}(t) = \sum_{j=0}^{n-1} t(j) = 0$ gives $\sum_{j=0}^{n-2} t(j) = -t(n-1)$, hence
$$h(i+1) - h(i) = 0 - \big(-t(n-1)\big) = t(n-1) = t_i.$$
Thus $h$ witnesses realizability. $\qquad\blacksquare$

**Theorem 3.4 (Master equivalence).** *A figure $t : \mathbb{Z}/n \to A$ is realizable if and only if $\mathrm{hol}(t) = 0$.*

*Proof.* Combine Propositions 3.2 and 3.3. $\qquad\blacksquare$

Theorem 3.4 is the entire theory in one line: **impossibility is exactly nonzero holonomy.**

## 4. The holonomy is a cohomology class

Realizability is unaffected by, and holonomy is invariant under, changing the gauge by a coboundary. This is what makes $\mathrm{hol}$ a well-defined function on $H^1 = (\text{cochains})/(\text{coboundaries})$.

**Proposition 4.1 (Gauge invariance).** For any figure $t$ and any $c : \mathbb{Z}/n \to A$,
$$\mathrm{hol}\big(i \mapsto t_i + (c(i+1) - c(i))\big) = \mathrm{hol}(t).$$

*Proof.* By additivity of the sum and Lemma 3.1,
$$\sum_i \big(t_i + (c(i+1)-c(i))\big) = \sum_i t_i + \sum_i (c(i+1)-c(i)) = \mathrm{hol}(t) + 0. \qquad\blacksquare$$

**Proposition 4.2 (Additivity).** $\mathrm{hol}(t + s) = \mathrm{hol}(t) + \mathrm{hol}(s)$ for all figures $t, s$.

*Proof.* $\sum_i (t_i + s_i) = \sum_i t_i + \sum_i s_i$. $\qquad\blacksquare$

Thus $\mathrm{hol} : (\mathbb{Z}/n \to A) \to A$ is a group homomorphism (the *Penrose class map*) whose kernel is exactly the realizable figures. We identify its image below.

## 5. Impossibility of the classical figures (depth model, $A = \mathbb{R}$)

**Theorem 5.1 (The Penrose triangle is impossible).** *The figure with $n = 3$ and $t_0 = t_1 = t_2 = 1$ is not realizable.*

*Proof.* Its holonomy is $1 + 1 + 1 = 3 \neq 0$; apply Theorem 3.4. Concretely, a gauge $h$ would satisfy $h_1 - h_0 = h_2 - h_1 = h_0 - h_2 = 1$; summing yields $0 = 3$, a contradiction. $\qquad\blacksquare$

**Theorem 5.2 (The Escher staircase is impossible).** *If every step ascends, i.e. $t_i > 0$ for all $i$, then $t$ is not realizable.*

*Proof.* A sum of strictly positive reals over the nonempty index set $\mathbb{Z}/n$ is strictly positive, so $\mathrm{hol}(t) = \sum_i t_i > 0 \neq 0$. Apply Theorem 3.4. $\qquad\blacksquare$

## 6. Non-orientable surfaces (orientation model, $A = \mathbb{Z}/2$)

Now let the coefficients be $\mathbb{Z}/2 = \{0, 1\}$ with $1 + 1 = 0$: two orientation reversals cancel. The holonomy counts orientation flips modulo two. A "gauge" $h : \mathbb{Z}/n \to \mathbb{Z}/2$ is a global choice of local orientation; realizability means a globally consistent orientation exists.

**Theorem 6.1 (Odd holonomy forbids orientation).** *If $\mathrm{hol}(s) = 1$ in $\mathbb{Z}/2$ then $s$ is not realizable; i.e. a closed band whose orientation reverses an odd number of times around the loop admits no global orientation.*

*Proof.* If $s$ were realizable then $\mathrm{hol}(s) = 0$ by Theorem 3.4, contradicting $\mathrm{hol}(s) = 1$. $\qquad\blacksquare$

**Theorem 6.2 (The Möbius band is non-orientable).** *The single-patch figure $n = 1$, $t_0 = 1 \in \mathbb{Z}/2$ (one self-gluing with a flip) is not realizable.*

*Proof.* Its holonomy is $1$; apply Theorem 6.1. $\qquad\blacksquare$

The Klein bottle is the closed surface obtained by such a one-sided gluing; Theorem 6.1 is exactly the statement that it carries no global orientation, and hence (by a standard argument) no embedding in $\mathbb{R}^3$ without self-intersection. The Penrose triangle (real depth) and the Klein bottle (mod-two orientation) are thus two instances of a single theorem, differing only in the coefficient group.

## 7. The impossibility class is a complete invariant

**Theorem 7.1 (Completeness).** *For $A = \mathbb{R}$, a figure $t$ is impossible (not realizable) if and only if $\mathrm{hol}(t) \neq 0$. The holonomy class alone decides realizability.*

*Proof.* Negate Theorem 3.4. $\qquad\blacksquare$

**Theorem 7.2 (Surjectivity, $H^1 \cong \mathbb{R}$).** *For every $r \in \mathbb{R}$ there is a figure with $\mathrm{hol}(t) = r$.*

*Proof.* Take $t_0 = r$ and $t_i = 0$ for $i \neq 0$; then $\mathrm{hol}(t) = r$. $\qquad\blacksquare$

Combining Propositions 4.1–4.2 with Theorems 7.1–7.2: the Penrose class map $\mathrm{hol}$ is a surjective homomorphism with kernel the realizable figures, so it descends to an isomorphism $H^1 \cong \mathbb{R}$. Impossibility is not a mere flag but a continuous real-valued measurement: its sign and magnitude record the direction and degree of the paradox.

## 8. Impossibility is global, not local (contrarian results)

A natural but false intuition is that one can diagnose impossibility from the local data. We refute both directions of this intuition.

**Theorem 8.1 (Uniform yet impossible).** *The Penrose triangle has perfectly uniform local data — every overlap prescribes the identical increment $t_i = 1$ — yet it is impossible.*

*Proof.* Uniformity is immediate; impossibility is Theorem 5.1. $\qquad\blacksquare$

**Theorem 8.2 (Non-uniform yet realizable).** *The figure with $n = 3$ and pairwise distinct increments $t_0 = 1,\ t_1 = 2,\ t_2 = -3$ is realizable.*

*Proof.* $\mathrm{hol}(t) = 1 + 2 + (-3) = 0$, so $t$ is realizable by Theorem 3.4; the three values are pairwise distinct. $\qquad\blacksquare$

Theorems 8.1 and 8.2 together show that no function of the *multiset* of local increments can determine realizability: uniform data can be impossible and maximally varied data can be realizable. Only the *ordered sum* — the holonomy — is decisive. This is the precise sense in which the impossibility of an impossible figure is a global, cohomological phenomenon.

## 9. The multiplicative model: developable surfaces

Penrose's original formulation records at each overlap a *scaling ambiguity* rather than an additive increment: the freedom to rescale the apparent depth of a patch. We reproduce the entire theory multiplicatively. Fix a commutative group $(G, \cdot, 1)$ (Penrose used the positive reals $\mathbb{R}_{>0}$ under multiplication).

**Definition 9.1.** A *multiplicative figure* is a function $t : \mathbb{Z}/n \to G$, with $t_i$ the scaling across the overlap $i \to i+1$. Its *monodromy* is
$$\mathrm{mon}(t) := \prod_{i \in \mathbb{Z}/n} t_i \in G.$$
It is *realizable* — buildable as a genuine developable (flat) surface — if there is a gauge $h : \mathbb{Z}/n \to G$ with $h(i+1)\, h(i)^{-1} = t_i$ for all $i$.

**Theorem 9.2 (Multiplicative master equivalence / classification of developable figures).** *A multiplicative figure is realizable (equivalently, developable) if and only if its monodromy is trivial, $\mathrm{mon}(t) = 1$.*

*Proof.* Identical to Theorem 3.4 with $+$ replaced by $\cdot$ and $0$ by $1$. Forward: a coboundary $t_i = h(i+1)h(i)^{-1}$ telescopes to $\prod_i t_i = \big(\prod_i h(i+1)\big)\big(\prod_i h(i)\big)^{-1} = 1$ since $i \mapsto i+1$ permutes $\mathbb{Z}/n$. Reverse: the partial-product gauge $h(i) = \prod_{j<\mathrm{val}(i)} t(j)$ realizes $t$, the wrap-around step closing up precisely because $\mathrm{mon}(t) = 1$. $\qquad\blacksquare$

**Proposition 9.3 (Monodromy homomorphism).** The map $\mathrm{mon} : (\mathbb{Z}/n \to G) \to G$ from the group of figures under pointwise multiplication is a group homomorphism ($\mathrm{mon}(1) = 1$ and $\mathrm{mon}(t \cdot s) = \mathrm{mon}(t)\,\mathrm{mon}(s)$), it is surjective (take $t_0 = g$, $t_i = 1$ otherwise), and the realizable/developable figures are exactly its kernel. Hence $H^1 \cong G$ and the monodromy is a complete invariant.

**Theorem 9.4 (The Penrose scaling triangle is not developable).** *If every beam of a three-overlap figure rescales by the same $g \in G$ with $g^3 \neq 1$, the figure has monodromy $g^3 \neq 1$ and is not developable.*

*Proof.* $\mathrm{mon} = g \cdot g \cdot g = g^3 \neq 1$; apply Theorem 9.2. $\qquad\blacksquare$

**Theorem 9.5 (Contrarian disproof).** *The conjecture "if every overlap genuinely rescales the figure ($t_i \neq 1$ for all $i$) then it is impossible" is FALSE.* For any $g \neq 1$, the two-overlap figure $t_0 = g$, $t_1 = g^{-1}$ has both factors nontrivial ($g \neq 1$ and $g^{-1} \neq 1$) yet is developable, since $\mathrm{mon}(t) = g \cdot g^{-1} = 1$.

*Proof.* Both nontriviality claims are immediate; developability follows from $\mathrm{mon}(t) = 1$ via Theorem 9.2. $\qquad\blacksquare$

## 10. Algorithms

All results are effective. Given a figure as a finite list of increments, one computes its holonomy (or monodromy) by a single pass, decides realizability by comparison with the identity, and, when realizable, reconstructs an explicit global gauge by accumulating partial sums (or products). These procedures are detailed in the accompanying computational material; each runs in $O(n)$ group operations for a figure with $n$ patches.

## 11. Applications and discussion

The pattern established here — locally trivial, globally obstructed, with the obstruction a quantity accumulated around loops — is the elementary heart of a vast body of mathematics and physics:

- **Curvature holonomy.** Parallel transport of a vector around a closed loop on a curved surface returns it rotated by an angle equal to the enclosed curvature; the drawing of a Penrose triangle is a $1$-cochain whose holonomy is the analogue of that rotation.
- **The Aharonov–Bohm effect.** A charged particle transported around a solenoid acquires a phase determined by the enclosed magnetic flux, even where the field vanishes locally — a physical holonomy over $U(1)$, structurally identical to our multiplicative model.
- **Obstruction theory and de Rham cohomology.** A closed differential form that is locally exact but not globally exact represents a nonzero class in $H^1$; "locally consistent, globally impossible" is the defining feature of nontrivial cohomology.
- **Non-orientable manifolds.** The first Stiefel–Whitney class $w_1 \in H^1(X; \mathbb{Z}/2)$ obstructs orientability; our $\mathbb{Z}/2$ holonomy is precisely $w_1$ evaluated on a loop, giving the Möbius/Klein results.

The unifying message is that impossibility, correctly understood, is a *measurement*: a homomorphism from local data to a coefficient group whose vanishing is realizability and whose value quantifies the obstruction.

## 12. Future directions

Several extensions suggest themselves. **True manifold statements.** The full geometric framing — for instance, that every non-orientable $3$-manifold contains a suitable "Penrose" surface, or the relation between our $\mathbb{Z}/2$ holonomy and non-orientability — is naturally phrased by realizing $\mathrm{hol}$ as the pairing of a cellular $1$-cocycle with the fundamental class of a loop, i.e. as an element of $H^1(S^1; A)$, and relating the orientation case to $w_1 \neq 0$. **Higher figures and branched covers.** Replacing the single loop by a general finite CW-complex $X$ turns impossibility into non-vanishing of a class in $H^1(X; A)$, with richer figures corresponding to higher-genus or branched configurations. **Continuous and smooth models.** Passing from the discrete cycle $\mathbb{Z}/n$ to the circle $S^1$ recovers the de Rham picture, where the holonomy is the integral of a $1$-form and realizability is exactness. Each direction connects the elementary combinatorics developed here to the standard machinery of algebraic and differential topology.

## 13. Conclusion

We have reduced the mystery of impossible figures to a single, elementary, and complete invariant. A cyclic figure carrying local reconciliation data in an abelian group is realizable if and only if its holonomy — the total increment around the loop — is trivial. This one equivalence proves the impossibility of the Penrose triangle and the Escher staircase, explains the non-orientability of the Möbius band and Klein bottle as an odd-holonomy phenomenon, identifies the impossibility class with all of $H^1 \cong A$, and, through a contrarian pair of examples, demonstrates that impossibility is irreducibly global. The multiplicative refinement classifies developable figures by their monodromy and refutes the naive local heuristic. Escher's staircases and Penrose's triangle are, at bottom, pictures of holonomy — the mathematics of what changes when you go around and come back.
