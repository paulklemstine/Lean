# Stereographic Bridge to the Gravitational Constant: Algorithmic Light from Integer Arithmetic

## Abstract

We construct a **stereographic bridge** connecting the integer arithmetic of continued fractions to the gravitational constant *G* = 6.67430 × 10⁻¹¹ m³/(kg·s²). The significant digits of *G*, expressed as the rational number 66743/10000, possess a continued fraction expansion [6; 1, 2, 14, 4, 2, 25] whose seven convergents each map, via inverse stereographic projection, to a rational point on the unit circle S¹. Each such point generates a Pythagorean triple, and the conformal factor at each convergent defines a decreasing "algorithmic light" sequence measuring geometric stretching. The SL(2,ℤ) matrices encoding the continued fraction steps reveal that this bridge has modular structure. All results are formalized and machine-verified in Lean 4 with Mathlib.

---

## 1. Introduction

### 1.1 Motivation

The gravitational constant *G* occupies a singular position in physics — it is the least precisely known fundamental constant, with relative uncertainty ~2.2 × 10⁻⁵. Unlike electromagnetic or quantum constants, *G* resists expression in terms of simpler quantities. This paper asks: **what do the integers have to say about *G*?**

We answer this question through the **stereographic bridge** — a framework that connects three mathematical domains:
1. **Integer arithmetic** (continued fractions, SL(2,ℤ))
2. **Geometry** (stereographic projection, the unit circle)
3. **Number theory** (Pythagorean triples, Farey sequences)

The bridge is bidirectional: from the integers encoding *G*'s digits, we obtain geometric objects (rational points on S¹, right triangles), and from the geometry, we recover the integer structure (modular matrices, determinant conditions).

### 1.2 The Stereographic–Pythagorean Correspondence

The classical parametrization of Pythagorean triples via stereographic projection is well known: the inverse stereographic map

$$t \mapsto \left(\frac{2t}{1+t^2}, \frac{1-t^2}{1+t^2}\right)$$

sends $t = p/q \in \mathbb{Q}$ to the rational point

$$\left(\frac{2pq}{p^2+q^2}, \frac{q^2-p^2}{p^2+q^2}\right) \in S^1 \cap \mathbb{Q}^2$$

and the resulting identity $(2pq)^2 + (p^2-q^2)^2 = (p^2+q^2)^2$ produces a Pythagorean triple. Our contribution is to **systematically apply this correspondence to the convergents of *G*'s continued fraction**, revealing a structured sequence of right triangles, conformal factors, and modular matrices.

---

## 2. The Continued Fraction of *G*

### 2.1 Expansion

Taking the CODATA 2018 recommended value *G* = 6.67430(15) × 10⁻¹¹ m³/(kg·s²), we extract the significant digits as the exact rational number:

$$G_{\text{digits}} = \frac{66743}{10000} = 6.6743$$

The Euclidean algorithm yields the continued fraction expansion:

$$\frac{66743}{10000} = 6 + \cfrac{1}{1 + \cfrac{1}{2 + \cfrac{1}{14 + \cfrac{1}{4 + \cfrac{1}{2 + \cfrac{1}{25}}}}}}$$

In compact notation: **[6; 1, 2, 14, 4, 2, 25]**.

### 2.2 Convergents

The convergent sequence $p_k/q_k$ is computed via the recurrence $p_k = a_k p_{k-1} + p_{k-2}$:

| k | $a_k$ | $p_k$ | $q_k$ | $p_k/q_k$ | Error |
|---|-------|--------|--------|------------|-------|
| 0 | 6     | 6      | 1      | 6.0000     | 6.74 × 10⁻¹ |
| 1 | 1     | 7      | 1      | 7.0000     | 3.26 × 10⁻¹ |
| 2 | 2     | 20     | 3      | 6.6667     | 7.63 × 10⁻³ |
| 3 | 14    | 287    | 43     | 6.6744     | 1.19 × 10⁻⁴ |
| 4 | 4     | 1168   | 175    | 6.6743     | 1.43 × 10⁻⁵ |
| 5 | 2     | 2623   | 393    | 6.67430    | 2.54 × 10⁻⁷ |
| 6 | 25    | 66743  | 10000  | 6.67430    | 0 |

**Key observation**: The partial quotient $a_3 = 14$ is anomalously large. By the theory of continued fractions, a large partial quotient means the preceding convergent $p_2/q_2 = 20/3 \approx 6.667$ is an exceptionally good rational approximation to *G*'s digits — achieving < 0.8% error with a denominator of only 3. This is the **gravitational sweet spot**: the simplest fraction that closely encodes gravity.

---

## 3. Stereographic Projection of Convergents

### 3.1 Rational Points on S¹

Each convergent $p_k/q_k$ maps to a point on the unit circle via inverse stereographic projection:

| k | $x_k = \frac{2p_kq_k}{p_k^2+q_k^2}$ | $y_k = \frac{q_k^2-p_k^2}{p_k^2+q_k^2}$ | Verified: $x_k^2+y_k^2$ |
|---|-------|-------|---------|
| 0 | 12/37 ≈ 0.3243  | −35/37 ≈ −0.9459  | 1 ✓ |
| 1 | 14/50 = 0.2800  | −48/50 = −0.9600  | 1 ✓ |
| 2 | 120/409 ≈ 0.2934 | −391/409 ≈ −0.9560 | 1 ✓ |
| 6 | 1334860000/4554628049 | −4354628049/4554628049 | 1 ✓ |

All seven convergent points cluster in a small arc near the "south-southwest" of S¹, converging to the **gravitational point** $P_G \approx (0.2931, -0.9561)$, at angle $\theta_G \approx 163.0°$ from the positive y-axis.

### 3.2 The Conformal Ladder

The **conformal factor** of inverse stereographic projection at parameter $t$ is

$$\lambda(t) = \frac{2}{1 + t^2}$$

At a rational convergent $p_k/q_k$, this becomes $\lambda_k = 2q_k^2/(p_k^2 + q_k^2)$.

**Theorem** (Conformal Monotonicity, *formalized in Lean 4*): If $|t_1| < |t_2|$, then $\lambda(t_2) < \lambda(t_1)$.

The conformal ladder for *G*:

| k | $\lambda_k$ | Interpretation |
|---|-------------|----------------|
| 0 | 2/37 ≈ 0.0541 | Maximum stretching (coarsest approx.) |
| 1 | 2/50 = 0.0400 | Drop to 7/1 |
| 2 | 18/409 ≈ 0.0440 | Slight increase (oscillation from alternating convergents) |
| 3 | 3698/84218 ≈ 0.0439 | Stabilizing |
| ⋮ | ⋮ | ⋮ |
| 6 | 200000000/4554628049 ≈ 0.0439 | Final value |

We call this sequence the **algorithmic light** of *G*: it measures how the sphere's Riemannian metric is "stretched" at the gravitational parameter's position. The rapid stabilization after $k = 2$ reflects the good rational approximability of *G*.

### 3.3 The Gravitational Stretching Factor

**Definition**: The gravitational stretching factor is

$$\lambda_G = \frac{2}{1 + G_{\text{digits}}^2} = \frac{200{,}000{,}000}{4{,}554{,}628{,}049} \approx 0.04391$$

**Theorem** (*formalized*): $0 < \lambda_G < 1$.

Physical interpretation: when the number line $\mathbb{R}$ is wrapped onto $S^1$ via inverse stereographic projection, the metric at *G*'s position is compressed by a factor of ~0.044 relative to the south pole. Gravity's numerical value places it in the "high-compression zone" of the stereographic metric, far from the equatorial isometry at $t = \pm 1$.

---

## 4. Pythagorean Triples from Gravity

### 4.1 The Gravitational Triple Sequence

Each convergent $(p_k, q_k)$ generates a Pythagorean triple $(a, b, c) = (2p_kq_k, |p_k^2 - q_k^2|, p_k^2 + q_k^2)$:

| k | Triple $(a, b, c)$ | Verified |
|---|---------------------|----------|
| 0 | (12, 35, 37) | 144 + 1225 = 1369 ✓ |
| 1 | (14, 48, 50) | 196 + 2304 = 2500 ✓ |
| 2 | (120, 391, 409) | 14400 + 152881 = 167281 ✓ |
| 3 | (24682, 80520, 84218) | ✓ |
| 4 | (408800, 1333599, 1394849) | ✓ |
| 5 | (2061678, 6725680, 7034578) | ✓ |
| 6 | (1334860000, 4354628049, 4554628049) | ✓ |

All seven identities are proved by `norm_num` in Lean 4.

**Observation**: The triple (12, 35, 37) from the first convergent 6/1 is a well-known primitive Pythagorean triple. The triple (14, 48, 50) = 2·(7, 24, 25) from 7/1 is a scaled version of another classic triple. These are the simplest geometric shadows that the integers cast onto *G*.

### 4.2 Growth of Hypotenuses

The hypotenuse $c_k = p_k^2 + q_k^2$ grows roughly as the square of the convergent denominators:

$$c_0 = 37, \quad c_1 = 50, \quad c_2 = 409, \quad c_3 = 84218, \quad c_6 = 4{,}554{,}628{,}049$$

The jumps in $c_k$ reflect the partial quotients: the large $a_3 = 14$ causes $c_3/c_2 \approx 206$, a dramatic expansion of the gravitational triangle.

---

## 5. The SL(2,ℤ) Bridge

### 5.1 Step Matrices

Each partial quotient $a_k$ defines a continued fraction step matrix

$$M_k = \begin{pmatrix} a_k & 1 \\ 1 & 0 \end{pmatrix}, \qquad \det(M_k) = -1$$

**Theorem** (*formalized*): $\det(M_k) = -1$ for all $k$.

**Theorem** (*formalized*): For any two partial quotients $a, b$, $\det(M_a \cdot M_b) = 1$, giving an element of SL(2,ℤ).

### 5.2 The Full Bridge Matrix

The product of all seven step matrices is:

$$M_0 M_1 M_2 M_3 M_4 M_5 M_6 = \begin{pmatrix} 66743 & 2623 \\ 10000 & 393 \end{pmatrix}$$

with $\det = 66743 \cdot 393 - 2623 \cdot 10000 = 26{,}229{,}999 - 26{,}230{,}000 = -1 = (-1)^7$.

This matrix encodes the **complete modular bridge** from the identity to the gravitational constant: it maps the "origin" vector $(1, 0)^T$ to $(66743, 10000)^T$, recovering *G*'s digits.

### 5.3 Farey Neighbor Condition

Adjacent convergents satisfy the classical determinant condition:

$$|p_k q_{k+1} - p_{k+1} q_k| = 1 \qquad \text{for } k = 0, 1, \ldots, 5$$

All six conditions are verified by `norm_num` in Lean 4. This means consecutive convergents are **Farey neighbors** — they are adjacent vertices in the Stern–Brocot tree, connected by a single mediant operation.

---

## 6. Formalization

All theorems in this paper are machine-verified in **Lean 4** (v4.28.0) with **Mathlib** (v4.28.0), located in `Physics/GravitationalConstant/StereographicBridge.lean`. The formalization includes:

1. **`stereo_on_circle'`**: $(\text{stereoX}' \, t)^2 + (\text{stereoY}' \, t)^2 = 1$
2. **`pythagorean_from_stereo'`**: $(2pq)^2 + (p^2-q^2)^2 = (p^2+q^2)^2$
3. **`confFactor_decreasing`**: $|t_1| < |t_2| \Rightarrow \lambda(t_2) < \lambda(t_1)$
4. **`confFactor_ratio`**: $\lambda(p/q) = 2q^2/(p^2+q^2)$
5. **`convergent_k_triple`**: All seven Pythagorean identities (k = 0, …, 6)
6. **`convergent_det_ij`**: All six Farey neighbor conditions
7. **`gravStretchFactor_lt_one`**: $0 < \lambda_G < 1$
8. **`cfStepMatrix_det`**: $\det(M_k) = -1$
9. **`even_steps_det_one`**: $\det(M_a M_b) = 1$ (SL(2,ℤ) structure)

No axioms beyond the standard Lean 4 foundations (`propext`, `Classical.choice`, `Quot.sound`) are used.

---

## 7. Discussion

### 7.1 What the Integers Say

The continued fraction [6; 1, 2, 14, 4, 2, 25] is *G*'s integer fingerprint. Its notable features:

- **Length 7**: Seven steps of integer arithmetic suffice to encode *G* to 5 significant figures.
- **The spike at $a_3 = 14$**: This anomalously large quotient makes 20/3 an exceptionally good approximation, suggesting that *G*'s digits have above-average rational approximability at this scale.
- **The final quotient $a_6 = 25$**: The last step is also relatively large, indicating that the preceding convergent 2623/393 ≈ 6.674300… already captures *G* to high precision.

### 7.2 The Algorithmic Light

The conformal factor sequence $\{\lambda_k\}$ — the "algorithmic light" — measures the information content of each continued fraction step in geometric terms. The rapid convergence of $\lambda_k$ to ~0.044 after $k = 2$ shows that the stereographic bridge "focuses" quickly: the first three convergents already determine *G*'s angular position on S¹ to within ~0.02°.

### 7.3 Physical Significance

We do not claim that the continued fraction expansion of *G* has direct physical significance — the expansion depends on the choice of units (SI), and different unit systems would yield different continued fractions. Rather, the stereographic bridge demonstrates a **structural principle**: any real number, including fundamental constants, admits a canonical decomposition into integer data (partial quotients), geometric data (points on S¹, Pythagorean triples), and algebraic data (SL(2,ℤ) matrices), all connected by stereographic projection.

The gravitational constant merely provides a compelling concrete example. The framework applies equally to any physical constant.

### 7.4 Connections to Other Work

- **Pythagorean triples and physics**: The appearance of Pythagorean triples in fundamental physics has been noted in the context of null vectors in Minkowski spacetime (see `Physics/ArithmeticPhotons` in this project).
- **Modular group and physics**: SL(2,ℤ) appears in string theory (T-duality), conformal field theory, and the theory of modular forms. Our bridge provides a concrete (if elementary) instance of modular structure arising from a physical constant.
- **Conformal geometry**: The conformal factor of stereographic projection is central to conformal field theory and the AdS/CFT correspondence.

---

## 8. Conclusion

The integers speak of *G* through a seven-step modular bridge. Each step generates a Pythagorean triple, a rational point on the unit circle, and a conformal stretching factor. The "algorithmic light" — the conformal ladder — rapidly focuses on *G*'s geometric position, revealing that the integer arithmetic of continued fractions provides a natural and structured encoding of the gravitational constant.

All results are formalized in Lean 4, providing machine-verified certainty for every identity and inequality.

---

## Appendix: Project Structure

| File | Description |
|------|-------------|
| `Physics/GravitationalConstant/StereographicBridge.lean` | Lean 4 formalization (all proofs) |
| `tools/gravitational_stereo_demo.py` | Python computational demo |
| `tools/gravitational_stereo_visuals.svg` | SVG visualization |
| `GRAVITATIONAL_STEREOGRAPHIC_RESEARCH.md` | This paper |

---

*Formalized with Lean 4 and Mathlib. Visualized with Python and SVG.*
