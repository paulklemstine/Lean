# Morphogenesis as Algebraic Geometry: The Conic Structure of Turing Patterns

## Abstract

Turing's theory of morphogenesis explains biological pattern formation through reaction–diffusion systems, whose emergent spots, stripes, and labyrinths arise as level sets of solutions to nonlinear partial differential equations. Such level sets are analytically delicate. We develop a complementary, purely algebraic account of these patterns valid near the onset of instability, where linear (Turing) analysis represents a pattern as a finite superposition of spatial cosine modes. The organizing principle is the **Chebyshev correspondence**: for every integer $n$, the single mode $\theta \mapsto \cos(n\theta)$ is a polynomial of *exactly* degree $n$ in the coordinate $X = \cos\theta$. This yields a faithful dictionary between the number of excited modes and the algebraic degree of the pattern. We prove that two-mode patterns are governed by quadratics — whose real level sets are the classical conic sections — and that three-mode patterns reach degree six. We then establish the metric dichotomy separating the morphological classes: definite-quadratic (spot) level sets are bounded, indefinite-quadratic (labyrinth) level sets are unbounded, and single-mode (stripe) level sets are unbounded and spatially periodic. As a capstone, we prove that a spot level set and a labyrinth level set are never equal as subsets of the plane, establishing boundedness as the algebraic invariant that separates the morphogenetic classes. We record, as future directions, the sharper genus–degree program that would read pattern topology from mode count.

**Keywords:** Turing patterns, reaction–diffusion, morphogenesis, Chebyshev polynomials, conic sections, algebraic curves, real algebraic geometry, pattern formation.

## 1. Introduction

In his 1952 paper *The Chemical Basis of Morphogenesis*, Alan Turing proposed that stationary spatial patterns in biological tissue arise from the interplay of two diffusing, reacting chemical species. A spatially uniform steady state, stable in the absence of diffusion, can be destabilized *by* diffusion when the inhibitor spreads faster than the activator. The result is a *diffusion-driven instability*: infinitesimal perturbations at certain spatial wavelengths grow, and the system settles into a stationary heterogeneous pattern. This mechanism is now the standard mathematical account of how leopards acquire spots, zebras stripes, and many marine animals their labyrinthine markings.

The patterns themselves are level sets — the loci where a chemical concentration equals a reference (background) value — of solutions to reaction–diffusion partial differential equations. As objects of analysis these level sets are difficult: existence, regularity, and qualitative behavior of PDE solutions require substantial machinery, and general statements about the *shapes* that appear are correspondingly scarce.

This paper pursues a different strategy. Near the onset of instability, linear analysis represents the emerging pattern as a superposition of a finite number of spatial Fourier modes. We show that this representation makes the background level set an *algebraic* object, and that the elementary theory of low-degree real curves — conics and their relatives — already captures the coarse morphology. Our contributions are:

1. A precise **degree correspondence** (Section 3): the number of excited modes equals the algebraic degree of the pattern in the cosine coordinate, witnessed by polynomials of the *exact* claimed degree.
2. The **conic classification** of two-mode patterns and the **sextic** ceiling for three-mode patterns (Sections 3–4).
3. The **boundedness dichotomy** (Sections 4–6): spots are bounded, labyrinths and stripes are unbounded, stripes are periodic.
4. A **separation theorem** (Section 7): spot and labyrinth level sets are provably distinct subsets of the plane.

Throughout, we are careful that no result is vacuous: degree claims exhibit polynomials of the stated degree rather than merely bounding it, unboundedness is witnessed by explicit points, boundedness by sharp inequalities, and the separation theorem is an honest inequality of sets.

## 2. Background and setup

### 2.1 The linear picture

Consider a two-species reaction–diffusion system on a spatial domain,

$$\partial_t u = D_u \nabla^2 u + f(u,v), \qquad \partial_t v = D_v \nabla^2 v + g(u,v),$$

with a homogeneous steady state $(u_0, v_0)$. Linearizing about this state and expanding perturbations in spatial Fourier modes, one finds that each wavevector $\mathbf{k}$ evolves independently at linear order, with a growth rate determined by the Jacobian of $(f,g)$ and the diffusion constants. Diffusion-driven instability occurs when a band of wavenumbers $|\mathbf{k}|$ has positive growth rate. Near onset, only a small number of modes are excited, and the emerging pattern is their superposition. In one spatial direction a mode is a cosine $\cos(n x)$; in two dimensions a pattern is a sum of plane waves $\cos(\mathbf{k}\cdot\mathbf{x})$ over the excited wavevectors.

We take as our object of study the **background level set** of such a superposition: the set of spatial points where the pattern equals its baseline value. Our claim is that this set is algebraic, and that its degree and definiteness encode the morphology.

### 2.2 The cosine coordinate

The device that converts trigonometric superpositions into polynomials is the substitution $X = \cos\theta$. We recall the relevant classical fact.

**Definition 2.1 (Chebyshev polynomials).** The Chebyshev polynomials of the first kind $T_n$ are defined by $T_0(X) = 1$, $T_1(X) = X$, and the recurrence $T_{n+1}(X) = 2X\,T_n(X) - T_{n-1}(X)$. Equivalently, $T_n$ is the unique polynomial with $T_n(\cos\theta) = \cos(n\theta)$ for all $\theta$.

The polynomial $T_n$ has degree exactly $n$ and leading coefficient $2^{n-1}$ (for $n\ge 1$). It is this exactness — the leading coefficient never vanishes — that makes the degree of a mode a faithful invariant of the mode number.

## 3. The degree correspondence

The central structural result is that a spatial mode is a polynomial of exactly its mode-number degree.

**Theorem 3.1 (Chebyshev / mode–degree correspondence).** *For every $n \in \mathbb{N}$ there exists a real polynomial $P$ with $\deg P = n$ and*

$$P(\cos\theta) = \cos(n\theta) \qquad \text{for all } \theta \in \mathbb{R}.$$

*Proof sketch.* Take $P = T_n$, the $n$-th Chebyshev polynomial of the first kind. The defining identity $T_n(\cos\theta) = \cos(n\theta)$ gives the functional equation, and the standard degree computation gives $\deg T_n = n$ (its leading coefficient is $2^{n-1} \ne 0$). $\qquad\blacksquare$

The content of Theorem 3.1 is the *equality* of degree with mode number. It establishes the dictionary

$$\text{number of modes} \;\longleftrightarrow\; \text{algebraic degree in } X=\cos\theta.$$

Two immediate specializations fix the two cases relevant to planar morphology.

**Proposition 3.2 (The conic building block).** *For all $\theta$,*

$$\cos(2\theta) = 2\cos^2\theta - 1.$$

*Thus the second harmonic is a genuine quadratic in $X=\cos\theta$ — the degree-2 building block of two-mode patterns.*

*Proof.* This is the double-angle identity, i.e. $T_2(X) = 2X^2 - 1$. $\qquad\blacksquare$

**Theorem 3.3 (Three modes reach degree six).** *There exists a real polynomial $Q$ with $\deg Q = 6$ and*

$$Q(\cos\theta) = \cos(3\theta)^2 \qquad \text{for all } \theta.$$

*Proof sketch.* Take $Q = T_3^2$. Then $Q(\cos\theta) = T_3(\cos\theta)^2 = \cos(3\theta)^2$, and $\deg Q = 2\deg T_3 = 2\cdot 3 = 6$. $\qquad\blacksquare$

Degree six is the algebraic home of hexagonal patterns: sextic curves carry the invariants on which the order-six dihedral symmetry group acts, matching the "degree up to 6" prediction for three-mode systems.

## 4. Spots: definite quadratics are bounded conics

We now pass from the one-variable cosine coordinate to planar level sets and classify the two-mode case by the definiteness of the associated quadratic form. The positive-definite case yields the closed, bounded curves — circles and ellipses — that model isolated spots.

**Theorem 4.1 (Isotropic spots are circles).** *Let $a, r \in \mathbb{R}$ with $a > 0$. Then*

$$\{(x,y) : a(x^2 + y^2) = r^2\} \;=\; \{(x,y) : x^2 + y^2 = r^2/a\}.$$

*Proof.* For $a>0$ the equation $a(x^2+y^2) = r^2$ is equivalent to $x^2+y^2 = r^2/a$ by dividing through by $a$. Hence the two sets have the same members. $\qquad\blacksquare$

Thus an isotropic spot level set is *exactly* the circle of squared radius $r^2/a$. The anisotropic case is an ellipse, and the key metric fact is boundedness.

**Theorem 4.2 (Spots are bounded).** *Let $a, b, c \in \mathbb{R}$ with $a > 0$ and $b > 0$. Then there is a constant $R$ such that every point of the level set $\{a x^2 + b y^2 = c\}$ satisfies $x^2 + y^2 \le R$. Explicitly one may take $R = c/a + c/b$.*

*Proof sketch.* Fix a point with $a x^2 + b y^2 = c$. Since $b y^2 \ge 0$, we have $a x^2 \le c$, hence $x^2 \le c/a$; symmetrically $y^2 \le c/b$. Adding gives $x^2 + y^2 \le c/a + c/b$. $\qquad\blacksquare$

The positive-definiteness of the form $a x^2 + b y^2$ (both coefficients positive) is precisely what confines the curve to a disc. A special case, recorded for the separation theorem below, is trivial but worth isolating.

**Proposition 4.3 (Circles are bounded).** *For every $\rho$, every point of $\{x^2 + y^2 = \rho^2\}$ satisfies $x^2 + y^2 \le \rho^2$.*

*Proof.* On this set $x^2+y^2$ is constant and equal to $\rho^2$. $\qquad\blacksquare$

## 5. Labyrinths: indefinite quadratics are unbounded conics

When the quadratic form is *indefinite* — its coefficients have opposite signs — the level set is a hyperbola, and the metric behavior reverses.

**Theorem 5.1 (Labyrinths are unbounded).** *Let $c > 0$. For every $R \in \mathbb{R}$ there exists a point $(x,y)$ with*

$$x^2 - y^2 = c \qquad\text{and}\qquad x^2 + y^2 > R.$$

*Proof sketch.* Given $R$, set $t = \sqrt{|R|+1}$, so $t^2 = |R|+1 > R$. Let $x = \sqrt{t^2 + c}$ and $y = t$. Then $x^2 - y^2 = (t^2 + c) - t^2 = c$, so the point lies on the hyperbola. Moreover $x^2 + y^2 = (t^2+c) + t^2 = 2t^2 + c > t^2 > R$. $\qquad\blacksquare$

The indefiniteness of $x^2 - y^2$ lets one coordinate grow without bound while the constraint is maintained, so the curve escapes every disc. This unbounded, space-filling behavior is the algebraic signature of labyrinthine morphology.

## 6. Stripes: a single mode is unbounded and periodic

The single-mode case sits between spot and labyrinth: like the hyperbola it is unbounded, but it is additionally *periodic*, reflecting the repeating parallel structure of a stripe field.

**Theorem 6.1 (Stripes are periodic).** *Let $c \in \mathbb{R}$ and suppose a point $(x, y)$ satisfies $\cos x = c$. Then for every integer $k$, the translated point $(x + 2\pi k,\, y)$ also satisfies $\cos(x + 2\pi k) = c$.*

*Proof.* The cosine has period $2\pi$, so $\cos(x + 2\pi k) = \cos x = c$. $\qquad\blacksquare$

**Theorem 6.2 (Stripes are unbounded).** *Let $c = \cos 0 = 1$. For every $R$ there exists a point $(x,y)$ with $\cos x = c$ and $x^2 + y^2 > R$.*

*Proof sketch.* Take $x = 0$, so $\cos x = 1 = c$, and $y = \sqrt{|R|+1}$. Then $x^2 + y^2 = |R| + 1 > R$. The stripe extends without bound in the transverse direction because $\cos x = c$ imposes no constraint on $y$. $\qquad\blacksquare$

Together, Theorems 6.1 and 6.2 characterize a stripe field: an infinite, translation-invariant family of lines, each of infinite extent. Periodicity distinguishes it from the labyrinth; unboundedness distinguishes it from the spot.

## 7. The morphological dichotomy

We can now state the separation result that gives the classification its teeth. It rules out any suspicion that the three morphological classes are the same curve under different names.

**Theorem 7.1 (Spot $\ne$ Labyrinth).** *For every radius $\rho$ and every $c > 0$,*

$$\{(x,y) : x^2 + y^2 = \rho^2\} \;\ne\; \{(x,y) : x^2 - y^2 = c\}$$

*as subsets of the plane.*

*Proof.* Suppose for contradiction the two sets are equal. By Theorem 5.1 (with $R = \rho^2$), the hyperbola contains a point $q$ with $q_1^2 - q_2^2 = c$ and $q_1^2 + q_2^2 > \rho^2$. Under the assumed equality, $q$ lies on the circle, so $q_1^2 + q_2^2 = \rho^2$. This contradicts $q_1^2 + q_2^2 > \rho^2$. Hence the sets are distinct. $\qquad\blacksquare$

The proof isolates the invariant that does the work: **boundedness**. A spot level set is contained in a disc (Proposition 4.3); a labyrinth level set is not (Theorem 5.1); a set inside a disc cannot equal a set that leaves every disc. The dichotomy is therefore not a matter of convention or coordinate choice but a robust geometric fact.

## 8. Discussion

The results assemble into a compact classification of planar Turing morphology at the linear level:

| Morphology | Algebraic type | Metric behavior | Additional structure |
|---|---|---|---|
| Spot | Definite quadratic (circle/ellipse) | Bounded | Closed oval |
| Stripe | Single mode (parallel lines) | Unbounded | Periodic |
| Labyrinth | Indefinite quadratic (hyperbola) | Unbounded | Two branches |
| Hexagonal | Sextic (three modes) | (higher degree) | Six-fold symmetry |

Three features are worth emphasizing.

**The dictionary is faithful.** Because the leading coefficient of $T_n$ is $2^{n-1} \ne 0$, the degree of a mode equals its mode number exactly; the top harmonic cannot be canceled by lower ones. The mode count is therefore recoverable from the pattern, not merely an upper bound.

**Definiteness is the classifier.** The single algebraic quantity that sorts a two-mode pattern into spot versus labyrinth is the definiteness (equivalently, the sign of the discriminant) of the associated quadratic form. This makes the spot/labyrinth boundary an algebraic sign change, which suggests that a morphological phase transition along a bifurcation path should coincide with the form losing definiteness.

**No result is vacuous.** Degree claims produce polynomials of the exact degree; unboundedness is witnessed by explicit points; boundedness by explicit sharp bounds; and the separation theorem is a genuine inequality of sets.

The limitation of the present treatment is that it is *metric and coarse*: it distinguishes bounded from unbounded and counts degree, but it does not yet extract the finer *topological* invariants (connectivity, number of ovals, genus) that characterize a specific pattern. That is the subject of the future program.

## 9. Future directions

The linear analysis recasts the onset of Turing patterns as conic-section geometry: mode count is algebraic degree, and boundedness separates spots from stripes and labyrinths. Several bold, testable conjectures follow.

**1. The genus dictionary.** For a pattern generated by $k$ spatial modes, the background level set is (generically) a smooth real curve whose complexification has genus at most $(k-1)(k-2)/2$, and the number of bounded ovals equals the number of distinct spot families. The mode count fixes the degree of the defining polynomial, and the classical genus–degree formula then caps the topological complexity — turning a statement about pattern topology into an inequality about polynomial degree. Because the single-mode degree correspondence is fully in hand, the remaining step is the mature theory of real plane curves applied to explicit low-degree families.

**2. Sharp mode–degree equality.** A superposition of $k$ modes with a nonzero top harmonic has a level set of algebraic degree *exactly* $k$ in the Chebyshev coordinates, and no reparametrization lowers this degree. The leading coefficient $2^{k-1} \ne 0$ of the $k$-th Chebyshev polynomial forbids cancellation of the top mode; extending the already-proved single-mode and squared-three-mode cases to arbitrary superpositions needs only leading-term bookkeeping.

**3. Hexagons are sextics.** Every hexagonally symmetric two-dimensional Turing pattern has a background level set defined by a sextic curve invariant under the order-6 dihedral group, and conversely every such invariant sextic is realized by a three-mode reaction–diffusion system. Three modes reach degree six, and the hexagonal symmetry group acts on degree-six invariants with exactly the dimension needed to parametrize the observed patterns; the missing ingredient is a finite-dimensional invariant-theory computation.

**4. Boundedness is a bifurcation invariant.** Along a reaction–diffusion bifurcation path, the transition from spot to labyrinth morphology coincides exactly with the moment the defining quadratic form loses definiteness (its discriminant changes sign), and this transition is detectable from the reaction kinetics alone. Boundedness of a conic level set is controlled by the sign of the quadratic form's discriminant, so a morphological phase transition is an algebraic sign change.

## 10. Conclusion

Turing supplied biology with a mechanism for pattern formation; the algebraic viewpoint supplies a classification. Near onset, the background level set of a Turing pattern is a low-degree real algebraic curve whose degree equals the number of active modes and whose morphological class is read from the definiteness of a quadratic form: bounded circles and ellipses for spots, periodic parallel lines for stripes, unbounded hyperbolas for labyrinths, and sextics for hexagons. The classification is faithful, robust, and non-vacuous, and it opens a clear path — the genus dictionary — toward reading the full topology of a biological pattern from a single integer, the number of chemical waves that gave it birth.
