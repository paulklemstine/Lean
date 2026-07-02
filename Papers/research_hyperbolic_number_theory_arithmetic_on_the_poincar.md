# Integer Structures on the Hyperbolic Disk: A Rigorous Foundation for Arithmetic on Curved Space

## Abstract

We develop a set of exact foundational results linking the two standard models of the hyperbolic plane — the upper half-plane and the Poincaré disk — with the arithmetic of integer lattices and the symmetries of the modular group. We prove that the Cayley transform $C(z) = (z-i)/(z+i)$ maps the upper half-plane bijectively onto the open unit disk, exhibiting an explicit two-sided inverse. We identify two explicit generators of the principal congruence subgroup $\Gamma(2) \subseteq \mathrm{SL}(2,\mathbb{Z})$ and show that the $\Gamma(2)$-orbit relation on the integer lattice $\mathbb{Z}^2$ is an equivalence relation, partitioning the lattice into "hyperbolic integer" classes. We establish discreteness of the lattice by proving that every Euclidean ball contains only finitely many lattice points. On the imaginary axis we analyze the hyperbolic midpoint, proving it is the geometric mean, that it is equidistant from its endpoints, commutative and idempotent, but — crucially — **not** associative, an exact fingerprint of curvature. Finally, we prove the projective invariance of the cross-ratio under all Möbius transformations. Together these results form a rigorous first floor for a program of "number theory on curved space," in which primes are envisioned as vertices of a hyperbolic tessellation and analytic questions acquire a geometric character.

**Keywords:** hyperbolic geometry, Poincaré disk, Cayley transform, modular group, congruence subgroup, cross-ratio, geometric mean, lattice discreteness, Möbius transformation.

---

## 1. Introduction

The integers $\mathbb{Z}$ are usually pictured on a flat, straight line. Yet many of the richest structures in modern mathematics — from automorphic forms to the geometry of numbers — arise when arithmetic is transported onto a *curved* stage. The hyperbolic plane is the archetype of such a stage: a space of constant negative curvature whose isometry group is intimately bound up with the modular group $\mathrm{SL}(2,\mathbb{Z})$, the master symmetry group of classical number theory.

This paper assembles a rigorous foundation for doing arithmetic in this curved setting. We work with the two standard conformal models of the hyperbolic plane:

- the **upper half-plane** $\mathbb{H} = \{ z \in \mathbb{C} : \operatorname{Im} z > 0 \}$, and
- the **Poincaré disk** $\mathbb{D} = \{ w \in \mathbb{C} : |w| < 1 \}$.

Our contributions are six exact results, each proved from first principles, which we organize into six parts:

1. **The Cayley transform** is an explicit conformal bijection $\mathbb{H} \to \mathbb{D}$ with an explicit inverse.
2. **Two explicit generators** of the principal congruence subgroup $\Gamma(2)$ are exhibited and verified.
3. **The $\Gamma(2)$-orbit relation** on $\mathbb{Z}^2$ is an equivalence relation.
4. **Lattice discreteness**: every Euclidean ball meets the lattice in a finite set.
5. **The hyperbolic midpoint** on the imaginary axis is the geometric mean, and is equidistant, commutative, idempotent, but not associative.
6. **Cross-ratio invariance** under all Möbius transformations.

The larger vision motivating this work is a "hyperbolic number theory," in which the vertices of a modular tessellation of the hyperbolic plane play the role of primes, and in which the distribution of these geometric primes could be governed by the geometry of the tiling. The present results are the load-bearing foundations for that program; they are complete and exact, and they stand on their own.

---

## 2. The Cayley Transform

### 2.1 Definitions

**Definition 2.1 (Cayley transform).** The *Cayley transform* is the map
$$C(z) = \frac{z - i}{z + i}.$$

**Definition 2.2 (inverse Cayley transform).** The *inverse Cayley transform* is
$$C^{-1}(w) = \frac{i\,(1 + w)}{1 - w}.$$

### 2.2 The transform maps the half-plane into the disk

**Theorem 2.3 (image in the disk).** *If $\operatorname{Im} z > 0$, then $|C(z)|^2 < 1$; that is, $C(z) \in \mathbb{D}$.*

**Proof sketch.** Write $z = x + iy$ with $y > 0$. Then
$$|z - i|^2 = x^2 + (y-1)^2, \qquad |z + i|^2 = x^2 + (y+1)^2.$$
Since
$$|z+i|^2 - |z-i|^2 = (y+1)^2 - (y-1)^2 = 4y > 0,$$
the denominator dominates the numerator, so $|C(z)|^2 = |z-i|^2 / |z+i|^2 < 1$. Geometrically, $C(z)$ is the ratio of the distance from $z$ to $i$ to the distance from $z$ to $-i$; a point above the real axis is strictly closer to $i$ than to $-i$. $\blacksquare$

### 2.3 The transform is invertible

**Theorem 2.4 (left inverse).** *For every $z \neq -i$, $C^{-1}(C(z)) = z$.*

**Theorem 2.5 (right inverse).** *For every $w \neq 1$, $C(C^{-1}(w)) = w$.*

**Proof sketch.** Both identities are direct algebraic computations valid away from the single pole of each map. For the left inverse, substitute $w = C(z) = (z-i)/(z+i)$ into $C^{-1}$:
$$C^{-1}(C(z)) = i \cdot \frac{1 + \frac{z-i}{z+i}}{1 - \frac{z-i}{z+i}} = i \cdot \frac{(z+i) + (z-i)}{(z+i) - (z-i)} = i \cdot \frac{2z}{2i} = z,$$
where clearing the compound fraction requires $z + i \neq 0$, i.e. $z \neq -i$. The right inverse is symmetric; substituting $z = C^{-1}(w) = i(1+w)/(1-w)$ into $C$ and simplifying yields $w$, valid provided $1 - w \neq 0$, i.e. $w \neq 1$. $\blacksquare$

**Remark 2.6.** The two excluded points $z = -i$ and $w = 1$ are precisely the poles of $C^{-1}$ and of the composite; on the extended complex plane they correspond to the point at infinity. Restricted to $\mathbb{H}$ and $\mathbb{D}$, where these poles never occur, $C$ is a genuine bijection, and it is conformal (angle-preserving) because it is a Möbius transformation. This is why one may freely transport hyperbolic-geometric statements between the two models.

---

## 3. Generators of the Congruence Subgroup $\Gamma(2)$

### 3.1 Background

The modular group is $\mathrm{SL}(2,\mathbb{Z})$, the group of $2\times 2$ integer matrices of determinant $1$. For a positive integer $N$, the *principal congruence subgroup of level $N$* is
$$\Gamma(N) = \left\{ g \in \mathrm{SL}(2,\mathbb{Z}) : g \equiv I \pmod{N} \right\},$$
the matrices congruent to the identity entrywise modulo $N$. The subgroup $\Gamma(2)$ is of special importance: it is free on two generators and its action tessellates $\mathbb{H}$ into ideal triangles.

### 3.2 Two generators

**Definition 3.1.** Let
$$T = \begin{pmatrix} 1 & 2 \\ 0 & 1 \end{pmatrix}, \qquad S = \begin{pmatrix} 1 & 0 \\ 2 & 1 \end{pmatrix}.$$

**Theorem 3.2 (membership).** *Both $T$ and $S$ belong to $\Gamma(2)$.*

**Proof sketch.** Each matrix has determinant $1\cdot 1 - 2\cdot 0 = 1$, so both lie in $\mathrm{SL}(2,\mathbb{Z})$. Reducing entries modulo $2$: the off-diagonal entries equal $2 \equiv 0$, and the diagonal entries equal $1$, so both matrices reduce to the identity matrix modulo $2$. Hence each lies in $\Gamma(2)$. $\blacksquare$

Geometrically $T$ acts on $\mathbb{H}$ by the translation $z \mapsto z + 2$, and $S$ by $z \mapsto z/(2z+1)$; together they generate the free group $\Gamma(2)$ (up to $\pm I$).

---

## 4. The $\Gamma(2)$-Orbit Relation on $\mathbb{Z}^2$

### 4.1 Definition

We consider the linear action of $\mathrm{SL}(2,\mathbb{Z})$ on integer column vectors $v \in \mathbb{Z}^2$ by matrix-vector multiplication $v \mapsto g\,v$.

**Definition 4.1 (orbit relation).** For $v, w \in \mathbb{Z}^2$, write $v \sim w$ iff there exists $g \in \Gamma(2)$ with $g\,v = w$. The equivalence classes are the *hyperbolic integer classes*.

### 4.2 It is an equivalence relation

**Theorem 4.2.** *The relation $\sim$ is reflexive, symmetric, and transitive.*

**Proof sketch.**
- *Reflexivity:* The identity matrix $I \in \Gamma(2)$ and $I\,v = v$, so $v \sim v$.
- *Symmetry:* If $g\,v = w$ with $g \in \Gamma(2)$, then $g^{-1} \in \Gamma(2)$ (congruence subgroups are subgroups, hence closed under inverses) and $g^{-1} w = v$, so $w \sim v$. Concretely, for $g = \left(\begin{smallmatrix} a & b \\ c & d\end{smallmatrix}\right) \in \mathrm{SL}(2,\mathbb{Z})$ the inverse is $\left(\begin{smallmatrix} d & -b \\ -c & a\end{smallmatrix}\right)$, which is again $\equiv I \pmod 2$ whenever $g$ is.
- *Transitivity:* If $g_1 v = w$ and $g_2 w = u$ with $g_1, g_2 \in \Gamma(2)$, then $g_2 g_1 \in \Gamma(2)$ (closure under products) and $(g_2 g_1) v = g_2(g_1 v) = g_2 w = u$, so $v \sim u$.

All three properties are inherited from the group axioms of $\Gamma(2)$. $\blacksquare$

**Remark 4.3.** Because $\sim$ is an equivalence relation arising from a group action, its classes are exactly the $\Gamma(2)$-orbits and they partition $\mathbb{Z}^2$. This is the algebraic substrate on which a notion of "hyperbolic integers grouped by symmetry" can be built.

---

## 5. Discreteness of the Lattice

A necessary precondition for any counting-based number theory (e.g. a "hyperbolic prime number theorem") is that the point set be discrete: no bounded region may contain infinitely many points.

**Theorem 5.1 (finiteness in balls).** *For every center $c = (c_1, c_2) \in \mathbb{R}^2$ and every radius $R \in \mathbb{R}$, the set*
$$\bigl\{ (m, n) \in \mathbb{Z}^2 : (m - c_1)^2 + (n - c_2)^2 < R^2 \bigr\}$$
*is finite.*

**Proof sketch.** If $(m,n)$ lies in the ball then each squared term is at most the whole sum, so $(m - c_1)^2 < R^2$ and $(n - c_2)^2 < R^2$. Hence $c_1 - |R| < m < c_1 + |R|$ and $c_2 - |R| < n < c_2 + |R|$. Thus $m$ ranges over integers in a bounded interval — at most those between $\lceil c_1 - |R| \rceil$ and $\lfloor c_1 + |R| \rfloor$ — and likewise $n$. Each interval contains finitely many integers, so the candidate set is contained in a finite product $\{m_{\min},\dots,m_{\max}\} \times \{n_{\min},\dots,n_{\max}\}$, hence is finite. $\blacksquare$

**Corollary 5.2.** Every $\Gamma(2)$-orbit intersects any bounded region in a finite set, so orbits are discrete. Counting lattice points, or orbit representatives, in a hyperbolic disk of growing radius is therefore a well-posed asymptotic problem.

---

## 6. The Hyperbolic Midpoint on the Imaginary Axis

### 6.1 Distance and midpoint

On the imaginary axis $\{ i s : s > 0 \} \subseteq \mathbb{H}$, hyperbolic distance takes a particularly simple logarithmic form. We represent the point $i s$ by the positive real $s$.

**Definition 6.1 (hyperbolic distance).** For $a, b > 0$,
$$d(a, b) = \bigl| \log(a / b) \bigr|.$$

**Definition 6.2 (hyperbolic midpoint).** For $s, t > 0$,
$$m(s, t) = \sqrt{s\,t}.$$

### 6.2 Properties

**Theorem 6.3 (equidistance).** *For $s, t > 0$, $\;d\bigl(s, m(s,t)\bigr) = d\bigl(m(s,t), t\bigr)$.*

**Proof sketch.** Both sides equal $\tfrac12 |\log(s/t)|$. Indeed
$$d(s, \sqrt{st}) = \left| \log \frac{s}{\sqrt{st}} \right| = \left| \tfrac12 \log \frac{s}{t} \right|, \quad d(\sqrt{st}, t) = \left| \log \frac{\sqrt{st}}{t} \right| = \left| \tfrac12 \log \frac{s}{t} \right|. \; \blacksquare$$

**Theorem 6.4 (commutativity).** *$m(s,t) = m(t,s)$ for all $s,t$.* — Immediate from $st = ts$.

**Theorem 6.5 (idempotence).** *For $s \geq 0$, $m(s,s) = s$.* — Since $\sqrt{s\cdot s} = |s| = s$.

**Theorem 6.6 (non-associativity).** *There exist $s,t,u > 0$ with $m(m(s,t),u) \neq m(s,m(t,u))$.*

**Proof.** Take $s = t = 1$, $u = 16$. Then
$$m(m(1,1),16) = m(1,16) = \sqrt{16} = 4, \qquad m(1, m(1,16)) = m(1,4) = \sqrt{4} = 2,$$
and $4 \neq 2$. $\blacksquare$

**Interpretation.** In additive coordinates $x = \log s$, the midpoint becomes the ordinary average $\tfrac12(x_s + x_t)$, which *is* commutative and idempotent but famously non-associative as a binary "mean" — $\operatorname{avg}(\operatorname{avg}(a,b),c) \neq \operatorname{avg}(a,\operatorname{avg}(b,c))$ in general. The geometric mean inherits exactly this behavior. Non-associativity is therefore not a pathology but the correct and expected signature of a genuine metric midpoint operation.

---

## 7. Invariance of the Cross-Ratio

### 7.1 Definitions

**Definition 7.1 (cross-ratio).** For distinct $z_1, z_2, z_3, z_4 \in \mathbb{C}$,
$$(z_1, z_2; z_3, z_4) = \frac{(z_1 - z_3)(z_2 - z_4)}{(z_1 - z_4)(z_2 - z_3)}.$$

**Definition 7.2 (Möbius transformation).** For $a,b,c,d \in \mathbb{C}$,
$$\mu(z) = \frac{a z + b}{c z + d}.$$

### 7.2 The invariance theorem

**Theorem 7.3 (cross-ratio invariance).** *Let $\mu(z) = (az+b)/(cz+d)$ with $ad - bc \neq 0$. Assume the four denominators $cz_k + d$ are nonzero and that $z_1 - z_4 \neq 0$, $z_2 - z_3 \neq 0$. Then*
$$\bigl( \mu(z_1), \mu(z_2); \mu(z_3), \mu(z_4) \bigr) = (z_1, z_2; z_3, z_4).$$

**Proof sketch.** The key algebraic identity is
$$\mu(z_i) - \mu(z_j) = \frac{a z_i + b}{c z_i + d} - \frac{a z_j + b}{c z_j + d} = \frac{(ad - bc)(z_i - z_j)}{(c z_i + d)(c z_j + d)}.$$
Substituting this for each of the four differences in the cross-ratio, every factor contributes a copy of $(ad-bc)$ and a pair of denominator factors. In the ratio
$$\frac{(\mu(z_1)-\mu(z_3))(\mu(z_2)-\mu(z_4))}{(\mu(z_1)-\mu(z_4))(\mu(z_2)-\mu(z_3))},$$
the numerator carries $(ad-bc)^2$ and denominators $(cz_1+d)(cz_3+d)(cz_2+d)(cz_4+d)$; the denominator carries the identical $(ad-bc)^2$ and the identical product of four linear denominators. All of these cancel, leaving exactly $\frac{(z_1-z_3)(z_2-z_4)}{(z_1-z_4)(z_2-z_3)}$. $\blacksquare$

**Remark 7.4.** Since Möbius transformations with real coefficients and positive determinant are exactly the orientation-preserving isometries of $\mathbb{H}$, the cross-ratio is an isometry invariant of the hyperbolic plane. It is the projective quantity from which hyperbolic distance itself can be reconstructed, and hence the fundamental invariant underlying the entire geometry.

---

## 8. Algorithms

The foundational results above are eminently computable. We highlight three algorithmic procedures that operationalize them.

### 8.1 Model conversion via the Cayley transform
Given a point in either model, convert to the other by evaluating $C$ or $C^{-1}$. This underlies any visualization or numerical experiment that must switch between the unbounded half-plane (convenient for the modular group) and the bounded disk (convenient for display).

### 8.2 Orbit enumeration under $\Gamma(2)$
Starting from a seed vector, repeatedly apply the generators $T$, $S$ and their inverses in breadth-first order, recording newly reached lattice points, to enumerate the portion of a $\Gamma(2)$-orbit lying within a bounded region. Termination in a bounded region is guaranteed by the discreteness theorem (Section 5).

### 8.3 Cross-ratio computation and isometry verification
Compute the cross-ratio of four points and confirm numerically that it is preserved under a sampled Möbius transformation — a direct empirical check of Theorem 7.3, useful as a regression test for any hyperbolic-geometry codebase.

---

## 9. Applications

- **Hyperbolic visualization.** The Cayley bijection is the standard bridge for rendering half-plane computations inside the Poincaré disk, where the whole plane is visible at once.
- **Tessellations and modular symmetry.** The generators of $\Gamma(2)$ produce the classical ideal-triangle tiling of $\mathbb{H}$; orbit enumeration draws it.
- **Discrete counting problems.** Lattice discreteness makes "count points in a growing hyperbolic disk" a well-defined asymptotic question — the entry point to any hyperbolic analogue of the prime number theorem.
- **Invariant-based geometry.** Cross-ratio invariance provides a coordinate-free handle on hyperbolic distance and angle, valuable in both proofs and numerics.

---

## 10. Discussion

The results here are deliberately foundational and fully rigorous. They do three things at once. First, they make the two hyperbolic models genuinely interchangeable via an explicit, invertible, conformal map. Second, they equip the integer lattice with the modular symmetry group $\Gamma(2)$ and organize it into well-defined orbit classes, while guaranteeing discreteness. Third, they expose the geometric personality of arithmetic on curved space: the "average" of two points becomes a geometric mean whose failure of associativity is the exact fingerprint of the logarithmic metric, and the cross-ratio emerges as the unshakeable invariant beneath all of it.

We are careful to distinguish the proven from the aspirational. The sweeping vision — hyperbolic primes as tessellation vertices, a hyperbolic prime number theorem, a hyperbolic zeta function with all zeros on a critical line — remains conjectural and is not claimed here. What *is* established is the exact, self-contained scaffolding on which such a program could be built: interchangeable models, a symmetry group with explicit generators, an orbit equivalence, discreteness, a metric midpoint, and a projective invariant.

---

## 11. Future Directions

Building on this foundation, several concrete directions emerge, centered on the Farey tessellation of the hyperbolic plane — the tiling whose vertices are the reduced fractions, with an edge joining $p/q$ and $r/s$ exactly when $|ps - qr| = 1$, on which the modular group acts by edge-preserving symmetries and mediants subdivide edges into ideal triangles.

1. **The golden ratio as the slowest-escaping cusp.** Among all geodesic rays of the modular tessellation that leave every bounded region, the Fibonacci ray toward the golden ratio appears to make the fewest "turns per unit of denominator growth." A mediant walk turns left or right at each ideal triangle exactly as the continued fraction of its limit reads $1$ or a larger partial quotient, so the all-ones expansion $[1;1,1,\dots]$ is the unique walk that never accelerates — conjecturally characterizing the golden ratio as the combinatorially most central boundary point.

2. **Determinant depth equals continued-fraction length.** For any two reduced fractions there should be a canonical shortest chain of mediant subdivisions connecting their edges, whose length equals the sum of the partial quotients of the continued fraction of their normalized ratio. Equivalently, graph distance in the Farey tessellation would be computed by the subtractive Euclidean algorithm, since each mediant step changes the determinant configuration exactly as one subtraction changes a continued-fraction remainder.

3. **A prime tessellation obstruction.** Restricting the vertex set to fractions $p/q$ with $q$ prime, the induced subgraph of the Farey tessellation is conjectured to be connected only if one allows a single extra "jump" per prime, with the minimum number of jumps needed to reach denominator $q$ growing like the number of distinct primes below $q$ — a geometric shadow of the distribution of primes.

Each of these converts a metric or analytic statement into a finite, checkable combinatorial one about turn sequences, subtraction chains, or connectivity, precisely because the incidence relation of the tessellation is pinned to determinant identities of the kind established here.
