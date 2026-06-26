# Duality of Sublevel-Set Homotopy Types for RC Functions on Finite-Dimensional Banach Spaces

**Author:** Aristotle

**Domain:** Geometry (convex geometry, algebraic topology, Morse theory)

---

## Abstract

We study the topology of sublevel sets of *ratio-of-convex* (RC) functions $f = p/q$, where $p, q \ge 0$ are positively homogeneous convex functions of degree one on a finite-dimensional real Banach space. Such ratios are degree-zero homogeneous, so their sublevel sets are cones. To each RC function $f$ one associates a polarity dual $f^{\circ}$, and the duality is realized in finite dimensions by an invertible continuous linear map $L$ — the *polarity map* — satisfying the intertwining identity $f^{\circ} \circ L = f$. We prove that this single identity forces a complete topological duality of the sublevel landscapes. Specifically: (i) the polarity map carries each sublevel set of $f$ exactly onto the corresponding sublevel set of $f^{\circ}$, $\{f^{\circ} \le c\} = L(\{f \le c\})$; (ii) it restricts to a homeomorphism $\{f \le c\} \cong \{f^{\circ} \le c\}$; (iii) the two sublevel sets are therefore homotopy equivalent; and (iv) applying the singular homology functor yields, in every degree $n$, an isomorphism $H_n(\{f \le c\}) \cong H_n(\{f^{\circ} \le c\})$, with the identical statement for reduced homology. A central structural observation is that the topological conclusion uses *only* the linearity and invertibility of $L$ — convexity's role is confined to guaranteeing that such a linear polarity map exists. We also record the cone-level specialization, in which the division-free sublevel cones of two RC functions are homeomorphic via $L$. A concrete non-vacuous instance on $\mathbb{R}^2$, with polarity realized by the coordinate swap, certifies that the hypotheses are genuinely satisfiable and that the conclusion has content.

---

## 1. Introduction

Sublevel sets are among the most ubiquitous geometric objects in mathematics and its applications. Given a function $f : X \to \mathbb{R}$ and a threshold $c \in \mathbb{R}$, the sublevel set is

$$\{f \le c\} := \{\, x \in X \mid f(x) \le c \,\}.$$

In optimization they are feasible regions; in physics they are basins of low energy; in topological data analysis they are the filtration whose evolving homology constitutes a *persistence diagram*; and in Morse theory they are the elementary pieces from which the topology of a space is reconstructed, one critical value at a time. Knowing the homotopy type of $\{f \le c\}$ — its connectivity and its holes in each dimension — is knowing the coarse architecture of the problem $f$ encodes.

This paper concerns a precise topological *duality* between the sublevel landscapes of two functions that are related by polarity. The functions in question form a flexible and natural class.

**Ratio-of-convex (RC) functions.** Let $p, q : X \to \mathbb{R}$ be non-negative, positively homogeneous of degree one, and convex. The associated RC function is the quotient

$$f = \frac{p}{q}, \qquad \text{defined on } \{x : q(x) > 0\}.$$

The class includes ratios of norms, ratios of support functions, and ratios of gauges of convex bodies. RC functions are scale-invariant: since $p$ and $q$ are degree-one homogeneous, $f$ is degree-zero homogeneous, $f(tx) = f(x)$ for $t > 0$, and hence constant along rays. This forces every sublevel set $\{f \le c\}$ to be a **cone** (a union of rays through the origin).

**Polarity duality.** The theory of convex bodies equips gauges and support functions with a duality operation — polarity, governed by the bipolar theorem — that, in finite dimensions, is realized at the level of the ambient space by an invertible *linear* map. Transported to RC functions, this produces a dual function $f^{\circ}$ on a (possibly different) space $Y$ and an invertible continuous linear map $L : X \to Y$, the *polarity map*, satisfying the intertwining identity

$$f^{\circ}(L(x)) = f(x) \qquad \text{for all } x. \tag{$\ast$}$$

The research conjecture motivating this work asserts that, under $(\ast)$, the sublevel sets of $f$ and $f^{\circ}$ are homeomorphic via $L$ and consequently have isomorphic (reduced) homology in all degrees. We prove exactly this. Our main structural finding is that the topological half of the conjecture is *purely formal*: it depends only on $L$ being a linear homeomorphism intertwining $f$ and $f^{\circ}$, and not on convexity. Convexity is the (essential) provider of the map $L$; once $L$ is in hand, topology does the rest by functoriality.

### Contributions

1. **The image identity (Theorem 3.1).** $\{f^{\circ} \le c\} = L(\{f \le c\})$ for every $c$. This is the linchpin and is where invertibility of $L$ is used.
2. **The explicit duality homeomorphism (Theorem 3.2 / Definition 3.3).** $L$ restricts to a homeomorphism $\{f \le c\} \cong \{f^{\circ} \le c\}$, the *same* linear map for every level $c$.
3. **Equal homotopy type (Theorem 3.5).** The two sublevel sets are homotopy equivalent.
4. **Homology duality in all degrees (Theorem 3.6).** The singular homology functor sends the homeomorphism to an isomorphism $H_n(\{f \le c\}) \cong H_n(\{f^{\circ} \le c\})$ in every degree $n$; the same holds for reduced homology.
5. **Cone specialization (Theorem 3.7).** The division-free sublevel cones of two RC functions are homeomorphic under $L$.
6. **A concrete non-vacuous instance (Section 5).** Explicit RC functions on $\mathbb{R}^2$ whose polarity map is the coordinate swap.

---

## 2. Setting and definitions

Throughout, $X$ and $Y$ are finite-dimensional real Banach spaces (normed real vector spaces); in the formalization they are general real normed spaces, and finite-dimensionality is the geometric context in which the polarity map is automatically linear. We write $\|\cdot\|$ for the norm.

**Definition 2.1 (Positive homogeneity).** A function $g : X \to \mathbb{R}$ is *positively homogeneous of degree $k$* if $g(tx) = t^k g(x)$ for all $t > 0$ and all $x$. Degree-one homogeneity is the case $k = 1$; degree-zero homogeneity, $g(tx) = g(x)$, expresses scale invariance.

**Definition 2.2 (Convex gauge).** A *non-negative homogeneous convex function* is a map $g : X \to \mathbb{R}$ with $g \ge 0$, positively homogeneous of degree one, and convex: $g(\lambda x + (1-\lambda)x') \le \lambda g(x) + (1-\lambda) g(x')$ for $\lambda \in [0,1]$. Norms and gauges of convex bodies containing the origin are the prototypical examples.

**Definition 2.3 (RC function and its ratio).** Given non-negative degree-one homogeneous convex $p, q : X \to \mathbb{R}$, the associated *ratio* is

$$\operatorname{ratio}(p, q)(x) = \frac{p(x)}{q(x)}, \qquad x \in \{q > 0\}.$$

We denote it $f = p/q$ and call it an *RC function*. It is degree-zero homogeneous: for $t > 0$,

$$f(tx) = \frac{p(tx)}{q(tx)} = \frac{t\,p(x)}{t\,q(x)} = f(x). \tag{2.1}$$

This is the homogeneity fact recorded in the formalization as `ratio_smul_pos`.

**Definition 2.4 (Sublevel set).** For $f : X \to \mathbb{R}$ and $c \in \mathbb{R}$,

$$\{f \le c\} = \{x \in X : f(x) \le c\},$$

regarded as a topological subspace of $X$ with the subspace topology. In Lean this is the subtype `{x // f x ≤ c}`.

**Definition 2.5 (Division-free sublevel cone).** To avoid the domain restriction $\{q > 0\}$ in the ratio, one packages the sublevel condition of $f = p/q$ in a *division-free* form. The *sublevel cone*

$$\operatorname{coneSub}(p, q, c) = \{\, x : p(x) \le c \cdot q(x) \,\}$$

records the inequality $p \le c\,q$ directly. On $\{q > 0\}$ this coincides with $\{f \le c\}$, but it is defined everywhere and is manifestly a cone: if $x \in \operatorname{coneSub}(p,q,c)$ and $t > 0$, then $p(tx) = t\,p(x) \le t\,c\,q(x) = c\,q(tx)$, so $tx \in \operatorname{coneSub}(p,q,c)$. This is the closure property recorded as `coneSub_smul_mem`.

**Definition 2.6 (Polarity map and intertwining).** A *polarity map* between RC functions $f$ on $X$ and $f^{\circ}$ on $Y$ is an invertible continuous linear map with continuous inverse,

$$L : X \xrightarrow{\;\sim\;} Y \qquad (L \in X \simeq_{L[\mathbb{R}]} Y \text{ in Lean notation}),$$

satisfying the *intertwining identity* $(\ast)$:

$$f^{\circ}(L(x)) = f(x) \qquad \text{for all } x \in X.$$

In the formalization this is the hypothesis `hdual : ∀ x, fdual (L x) = f x`. The pair $(f^{\circ}, L)$ is the *polarity dual* data of $f$. We emphasize that $L$ is a single fixed map, independent of the threshold $c$.

A note on coefficients and functoriality. Singular homology is developed in the formalization as a functor $\mathrm{TopCat} \to C$ valued in an arbitrary homological category $C$ (preadditive, with the requisite coproducts and a homology calculus) and a chosen coefficient object $R \in C$. The classical case $C = R\text{-Mod}$ recovers ordinary singular homology with coefficients in a ring $R$. All homology statements below hold at this level of generality; the reader may safely instantiate $C = \mathbb{Z}\text{-Mod}$ and $R = \mathbb{Z}$ throughout.

---

## 3. Main results

We fix RC functions $f : X \to \mathbb{R}$ and $f^{\circ} : Y \to \mathbb{R}$, an invertible continuous linear polarity map $L : X \to Y$, and assume the intertwining identity $(\ast)$ holds: $f^{\circ}(L(x)) = f(x)$ for all $x$. Fix a threshold $c \in \mathbb{R}$.

### 3.1 The image identity

**Theorem 3.1 (Polarity carries sublevel sets onto sublevel sets — `sublevel_image`).**

$$\{\, y \in Y \mid f^{\circ}(y) \le c \,\} \;=\; L\big(\{\, x \in X \mid f(x) \le c \,\}\big).$$

*Proof sketch.* We prove the two inclusions.

($\subseteq$) Let $y$ satisfy $f^{\circ}(y) \le c$. Set $x := L^{-1}(y)$. Using the intertwining identity and $L(L^{-1}(y)) = y$,

$$f(x) = f\big(L^{-1}(y)\big) = f^{\circ}\big(L(L^{-1}(y))\big) = f^{\circ}(y) \le c,$$

so $x \in \{f \le c\}$ and $y = L(x) \in L(\{f \le c\})$. Here invertibility of $L$ is essential: it produces the preimage $x$.

($\supseteq$) Let $y = L(x)$ with $f(x) \le c$. Then by $(\ast)$, $f^{\circ}(y) = f^{\circ}(L(x)) = f(x) \le c$, so $y \in \{f^{\circ} \le c\}$.

Both inclusions hold for every $c$, with the same $L$. $\qquad\blacksquare$

This identity is the geometric core: it states that the dual sublevel landscape is literally the $L$-image of the primal one, level by level.

### 3.2 The duality homeomorphism

**Theorem 3.2 / Definition 3.3 (`sublevelHomeo`).** *The linear polarity map $L$ restricts to a homeomorphism*

$$\Phi_c : \{\, x : f(x) \le c \,\} \;\xrightarrow{\;\cong\;}\; \{\, y : f^{\circ}(y) \le c \,\}, \qquad \Phi_c(x) = L(x).$$

*Proof sketch.* $L$ is a homeomorphism $X \cong Y$ (continuous, with continuous inverse). The intertwining identity $(\ast)$ shows it maps the source sublevel condition to the target one: if $f(x) \le c$ then $f^{\circ}(L(x)) = f(x) \le c$. A homeomorphism that maps a subspace into a target subspace and whose inverse maps back (guaranteed by Theorem 3.1) restricts to a homeomorphism of subspaces. In Lean this is `ContinuousLinearEquiv.toHomeomorph` composed with `Homeomorph.subtype`, the subspace condition discharged precisely by rewriting with $(\ast)$. $\qquad\blacksquare$

**Lemma 3.4 (Action of the homeomorphism — `sublevelHomeo_apply`).** *For $x \in \{f \le c\}$, the underlying point of $\Phi_c(x)$ in $Y$ is exactly $L(x)$.* (In the formalization this is definitional, holding by `rfl`.) This makes the homeomorphism completely explicit: it *is* the polarity map, restricted.

The crucial qualitative feature is that $\Phi_c$ is induced by one fixed linear map $L$ for *all* $c$. The homeomorphism is not an ad-hoc deformation depending on the level; it is the same rigid mirror throughout, which is what later permits the duality to be promoted to a statement about filtrations and Morse theory (Section 6).

### 3.3 Equal homotopy type

**Theorem 3.5 (Same homotopy type — `sublevel_homotopyEquiv`).** *The sublevel sets $\{f \le c\}$ and $\{f^{\circ} \le c\}$ are homotopy equivalent.*

*Proof sketch.* Every homeomorphism is, in particular, a homotopy equivalence: its continuous inverse serves as a homotopy inverse, with the composites equal — hence homotopic — to the identities. Applying this to $\Phi_c$ from Theorem 3.2 yields a homotopy equivalence $\{f \le c\} \simeq \{f^{\circ} \le c\}$. In Lean: `(sublevelHomeo …).toHomotopyEquiv`. $\qquad\blacksquare$

Consequently the two sublevel sets agree on every homotopy invariant: number of path components, homotopy groups in all dimensions, and (via the next result) homology.

### 3.4 Homology duality in all degrees

**Theorem 3.6 (Duality homology isomorphism — `sublevelHomologyIso` / `sublevel_homology_iso`).** *For every degree $n \in \mathbb{N}$ there is an isomorphism of homology objects*

$$H_n\big(\{\, x : f(x) \le c \,\}\big) \;\cong\; H_n\big(\{\, y : f^{\circ}(y) \le c \,\}\big),$$

*where $H_n = ((\text{singularHomologyFunctor}\; C\; n).\mathrm{obj}\, R)$ denotes the $n$-th singular homology with coefficients $R$ in a homological category $C$. The corresponding statement for reduced homology holds identically.*

*Proof sketch.* Singular homology is a functor from topological spaces (as objects of $\mathrm{TopCat}$) to the homological category $C$. Functors send isomorphisms to isomorphisms. The homeomorphism $\Phi_c$ of Theorem 3.2 is an isomorphism in $\mathrm{TopCat}$ (via `TopCat.isoOfHomeo`); applying the homology functor (`mapIso`) yields an isomorphism of homology objects in each degree $n$. No homology group is ever computed; the isomorphism is produced *automatically by functoriality*. The reduced version is the same argument applied to the augmented chain complex, whose functoriality is identical. $\qquad\blacksquare$

This is the technical payoff of insisting on a genuine homeomorphism rather than a mere homotopy equivalence proved by hand: the homology isomorphism costs nothing beyond invoking the functor, and it is uniform in $n$.

### 3.5 The cone specialization

When working with the division-free cones of Definition 2.5, one avoids the domain restriction $\{q > 0\}$ entirely.

**Theorem 3.7 (Cone duality — `coneSubHomeo`).** *Let $f = p/q$ on $X$ and $f^{\circ} = p'/q'$ on $Y$ be RC functions, and suppose the linear polarity map $L$ carries each sublevel cone of $f$ to the corresponding cone of $f^{\circ}$:*

$$x \in \operatorname{coneSub}(p, q, c) \iff L(x) \in \operatorname{coneSub}(p', q', c) \quad \text{for all } x.$$

*Then $L$ restricts to a homeomorphism*

$$\operatorname{coneSub}(p, q, c) \;\cong\; \operatorname{coneSub}(p', q', c).$$

*Proof sketch.* Identical in structure to Theorem 3.2: $L$ is a homeomorphism $X \cong Y$, and the membership equivalence is exactly the condition needed for `Homeomorph.subtype` to restrict it to the two cone subspaces. $\qquad\blacksquare$

The cone form is the most directly geometric statement: it says the polarity map is a homeomorphism of the conical regions themselves, with no division and no auxiliary positivity hypothesis.

---

## 4. The role of convexity: a structural remark

A reader may be surprised that the proofs in Section 3 invoke no convexity. This is deliberate and is, we argue, the conceptual heart of the matter.

**Observation 4.1 (Convexity is offstage).** Every conclusion of Section 3 — the image identity, the homeomorphism, the homotopy equivalence, and the homology isomorphism — follows from the single hypothesis that $L$ is an invertible continuous linear map intertwining $f$ and $f^{\circ}$. Convexity of $p$ and $q$ is never used in these arguments.

The reason convexity appears in the conjecture at all is that it is responsible for the *existence and linearity of the polarity map*. The duality of convex bodies via polarity (and the bipolar theorem) is what guarantees, in finite dimensions, that the abstract duality of the gauges $p, q$ is realized by an honest linear isomorphism $L$ on the ambient space. In other words:

- **Convexity (analysis):** produces a *linear* polarity map $L$ with $f^{\circ} \circ L = f$.
- **Linearity + invertibility (topology):** turns that map into a homeomorphism of sublevel sets and hence an isomorphism of homology.

Separating these two roles clarifies precisely which hypothesis is load-bearing for which conclusion. It also indicates the natural generalization: the topological duality holds for *any* class of degree-zero homogeneous functions whose duality happens to be realized linearly, convex or not.

**Non-vacuity.** One might worry that the intertwining hypothesis $(\ast)$ is so strong as to be unsatisfiable except trivially. It is not. Section 5 exhibits genuine RC functions and a genuine non-identity linear polarity map for which $(\ast)$ holds, and for which the sublevel sets are honestly distinct as subsets of the plane while being homeomorphic via $L$. The image identity (Theorem 3.1) likewise has content: it inverts $L$ on the dual side and is false for non-invertible maps.

---

## 5. A concrete non-vacuous instance

We make everything explicit on the plane $X = Y = \mathbb{R}^2$, with the polarity map taken to be the coordinate swap.

**The data.** Define

$$p(x, y) = |x|, \qquad q(x, y) = |x| + |y|, \qquad f(x, y) = \frac{p(x,y)}{q(x,y)} = \frac{|x|}{|x| + |y|},$$

and the dual data

$$p^{\circ}(x, y) = |y|, \qquad q^{\circ}(x, y) = |x| + |y|, \qquad f^{\circ}(x, y) = \frac{|y|}{|x| + |y|}.$$

Each of $p, q, p^{\circ}, q^{\circ}$ is non-negative, convex, and positively homogeneous of degree one; both $f$ and $f^{\circ}$ are degree-zero homogeneous and defined off the origin.

**The polarity map.** Take the coordinate swap

$$L(x, y) = (y, x),$$

a genuine non-identity continuous linear equivalence (in Lean, `ContinuousLinearEquiv.prodComm`), with $L^{-1} = L$.

**The intertwining identity.** A direct computation verifies $(\ast)$:

$$f^{\circ}\big(L(x, y)\big) = f^{\circ}(y, x) = \frac{|x|}{|y| + |x|} = \frac{|x|}{|x| + |y|} = f(x, y).$$

Thus all hypotheses of Section 3 are met, and we conclude:

- $\{f^{\circ} \le c\} = L(\{f \le c\})$ for every $c$ (Theorem 3.1);
- $\{f \le c\} \cong \{f^{\circ} \le c\}$ via the swap $L$ (Theorem 3.2);
- the two are homotopy equivalent and have isomorphic homology in all degrees (Theorems 3.5, 3.6).

**Why this is non-trivial.** As subsets of $\mathbb{R}^2$, $\{f \le c\}$ and $\{f^{\circ} \le c\}$ differ: the former is a cone of directions clustered around the vertical ($y$-)axis (where $|x|$ is small relative to $|x|+|y|$), while the latter clusters around the horizontal ($x$-)axis. They are exchanged by reflection across the diagonal $y = x$, which is exactly $L$. The map is not the identity, the two sets are genuinely distinct, and yet they are homeomorphic — precisely the content the theorem promises.

For a concrete threshold, take $c = \tfrac12$. Then $\{f \le \tfrac12\} = \{(x,y) : |x| \le \tfrac12(|x|+|y|)\} = \{|x| \le |y|\}$, the double wedge around the $y$-axis; and $\{f^{\circ} \le \tfrac12\} = \{|y| \le |x|\}$, the double wedge around the $x$-axis. The swap $L$ carries one onto the other exactly.

---

## 6. Applications and connections

**Topological data analysis and persistence.** The map $L$ relating $\{f \le c\}$ to $\{f^{\circ} \le c\}$ is *the same for every $c$*. It therefore commutes with the sublevel inclusion maps $\{f \le c\} \hookrightarrow \{f \le c'\}$ (for $c \le c'$) and so descends to an isomorphism of the entire sublevel *filtrations* of $f$ and $f^{\circ}$. In the language of persistent homology, $f$ and $f^{\circ}$ have isomorphic persistence modules and hence identical persistence diagrams: every topological feature is born and dies at the same parameter for both functions. A dataset analyzed through $f$ and through its dual $f^{\circ}$ yields the same barcodes.

**Morse theory.** In the Morse-theoretic picture, the topology of $\{f \le c\}$ changes only at critical values of $f$. Because the duality homeomorphism is uniform in $c$, the critical values and the topological transitions of $f$ correspond one-to-one with those of $f^{\circ}$. The two RC functions are Morse-theoretic twins: a level-by-level equivalence underlies their critical-point structure. This is the bridge to the "critical-point Morse equivalence" anticipated for RC duality.

**Convex geometry and optimization.** RC functions arise as ratios of gauges and support functions; their sublevel sets are the feasible cones of fractional-programming and Rayleigh-quotient–type problems. The duality says such a problem and its polar dual have the same feasible-region topology, so structural questions (connectivity of the feasible set, presence of obstructions/holes) can be transferred to whichever formulation is more tractable.

**Computation.** The image identity reduces computing the dual landscape to applying a single linear map. Numerically, one samples or meshes $\{f \le c\}$ once and obtains $\{f^{\circ} \le c\}$ by the linear transform $L$, with topological invariants (component counts, Betti numbers) guaranteed equal a priori. The companion `demo.py` exhibits this on the planar example, verifying the intertwining identity, the image identity, and the equality of discrete Betti numbers across thresholds.

---

## 7. Discussion

The results isolate a clean principle: *a duality of degree-zero-homogeneous functions that is realized by an invertible linear intertwiner is automatically a topological duality of sublevel sets, in every degree and at every level.* The argument is short because it is functorial — the deep input (homology respects homeomorphisms) is borrowed wholesale, and the only bespoke step is the image identity, which records that an invertible linear map exchanges the two sublevel conditions.

Two features deserve emphasis. First, the *uniformity in $c$*: a single map $L$ works at all levels, which is what lifts the result from isolated spaces to filtrations and Morse theory. Second, the *separation of hypotheses*: convexity provides the map, linearity provides the topology. This makes the convexity hypothesis precisely diagnosable and points to generalizations beyond the convex world.

A limitation, by design, is that the existence and linearity of the polarity map are *assumed*, not derived, in the topological theorems. Establishing that convex homogeneity *forces* $L$ to be linear (Conjecture C2 below) would close this loop and show the "explicit linear transformation" of the conjecture is canonical rather than merely sufficient.

---

## 8. Future directions

The following directions extend the present cycle. Each is intended to be concrete and falsifiable.

**C1. The cone deformation-retracts onto its spherical link.** Every RC sublevel cone $\operatorname{coneSub}(p, q, c)$, minus the origin, should deformation-retract onto its intersection with the unit sphere, so that its reduced homology equals that of the "link." The mechanism is that degree-zero homogeneity makes the radial map $x \mapsto x / \|x\|$ a deformation retraction, converting a homology computation in $\mathbb{R}^n$ into one on $S^{n-1}$. This would upgrade the abstract homotopy equivalence of Theorem 3.5 into an *explicit* homology computation. The cone structure (Definition 2.5, `coneSub_smul_mem`) and the homeomorphism/homotopy machinery are already in place.

**C2. The polarity map is forced to be linear.** For non-negative degree-one convex gauges $p, q$ in finite dimensions, the sublevel duality $\{f \le c\} \leftrightarrow \{f^{\circ} \le c\}$ should be realizable by *no map other than a linear isomorphism* (up to the cone's automorphisms). The intuition: a homogeneous convex gauge is determined by its unit ball, polarity of convex bodies is induced by the linear bipolar duality, so any homeomorphism respecting the cone gradings must be linear on rays. Proving necessity would show the linear polarity map is canonical, not just one valid choice.

**C3. Homology duality is a Morse-theoretic invariance.** The isomorphism $H_*(\{f \le c\}) \cong H_*(\{f^{\circ} \le c\})$ should persist across all regular values $c$ and change only at the shared critical values of $f$ and $f^{\circ}$, yielding a level-by-level Morse equivalence. The mechanism is naturality in $c$: the polarity homeomorphism is the same $L$ for every level, so it commutes with the sublevel inclusions and hence with the persistence/Morse filtration. Theorem 3.1 already shows $L$ carries $\{f \le c\}$ onto $\{f^{\circ} \le c\}$ uniformly in $c$; promoting this to a morphism of filtered spaces is the direct next step.

**C4. The bipolar identity is the only hypothesis needed.** The intertwining identity $(\ast)$ should be not only sufficient but the *minimal* hypothesis: any additional regularity or convexity assumptions are dispensable for the topological conclusion, with convexity confined entirely to the prior existence of $L$.

---

## 9. Conclusion

We have established a complete topological duality for the sublevel sets of RC functions related by a linear polarity map. From the single intertwining identity $f^{\circ} \circ L = f$ follow the image identity $\{f^{\circ} \le c\} = L(\{f \le c\})$, an explicit homeomorphism of sublevel sets realized by $L$ at every level, their resulting homotopy equivalence, and an isomorphism of singular (and reduced) homology in all degrees — together with the division-free cone specialization. The conclusions are purely formal in $L$, with convexity responsible only for the existence of the map, and they are non-vacuous, as the planar coordinate-swap instance certifies. The uniformity of $L$ across thresholds positions these results as the topological backbone of a Morse-theoretic and persistence-theoretic equivalence between an RC function and its polar dual.
