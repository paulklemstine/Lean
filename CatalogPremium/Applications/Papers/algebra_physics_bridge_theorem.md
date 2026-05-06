# Structure-Preserving Berggren–Photonic Bridge: Cross-Ratio Invariance as a Shared Algebraic-Physical Symmetry

## Abstract

We establish a rigorous structure-preserving correspondence between the Berggren tree — the ternary tree generating all primitive Pythagorean triples — and Möbius transformations on the real projective line. Using the *Stereographic Pythagorean Bridge* (SPB), defined by `(a, b, c) ↦ a/(c − b)`, we show that each Berggren generator induces a Möbius transformation on ℝ, and that the cross-ratio is invariant under the full Berggren monoid action. All results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords:** Pythagorean triples, Berggren tree, Möbius transformations, cross-ratio, projective invariants, formal verification

---

## 1. Introduction

### 1.1 The Berggren Tree

The remarkable fact that *all* primitive Pythagorean triples can be generated from a single root `(3, 4, 5)` by repeated application of three integer matrices was discovered by Berggren (1934) and independently by several later authors. The three generating matrices are:

```
U = ⎡ 1  -2   2 ⎤     A = ⎡ 1   2   2 ⎤     D = ⎡-1   2   2 ⎤
    ⎢ 2  -1   2 ⎥         ⎢ 2   1   2 ⎥         ⎢-2   1   2 ⎥
    ⎣ 2  -2   3 ⎦         ⎣ 2   2   3 ⎦         ⎣-2   2   3 ⎦
```

Each matrix preserves the Lorentz form `a² + b² − c² = 0` and maps primitive triples to primitive triples. The resulting ternary tree, rooted at `(3, 4, 5)`, contains every primitive Pythagorean triple exactly once.

### 1.2 The Photonic Frontier

The equation `a² + b² = c²` is the *mass-shell condition* for massless particles in (2+1)-dimensional Minkowski spacetime with metric signature (+, +, −). Primitive Pythagorean triples are thus "rational photons" — massless states with integer momentum components. The light cone `a² + b² = c²` in momentum space is the *photonic frontier*.

### 1.3 Main Contribution

We prove that the Berggren tree action descends, via a canonical stereographic projection, to Möbius transformations on ℝ, and that the cross-ratio is an invariant of this action. This result:

1. Identifies the Berggren tree as a discrete subgroup of PGL(2, ℤ)
2. Establishes cross-ratio as a shared invariant linking number theory and conformal geometry
3. Provides the algebraic foundation for studying Berggren dynamics through projective geometry

All proofs are machine-verified in Lean 4.

---

## 2. Definitions

### 2.1 Primitive Pythagorean Triples

A *primitive Pythagorean triple* (PPT) is a triple `(a, b, c) ∈ ℤ³` satisfying:
- `a² + b² = c²`
- `a > 0`, `b > 0`, `c > 0`
- `gcd(a, b) = 1`

### 2.2 The Stereographic Pythagorean Bridge

**Definition.** The *Stereographic Pythagorean Bridge* (SPB) is the map

```
spb(a, b, c) = a / (c − b)
```

This is the stereographic projection of the rational point `(a/c, b/c)` on the unit circle from the point `(0, −1)` to the real line `y = 0`. For any PPT, the value `spb(a, b, c)` is a positive rational number (since `c > b` for `a > 0`).

**Geometric interpretation.** The unit circle parameterized by `(cos θ, sin θ)` has stereographic coordinate `t = cos θ / (1 − sin θ) = tan(π/4 + θ/2)`. The SPB restricts this to rational points of the circle corresponding to PPTs.

### 2.3 Möbius Transformations

For real numbers `a, b, c, d` with `ad − bc ≠ 0`, the *Möbius transformation* is:

```
f(z) = (az + b) / (cz + d)
```

### 2.4 Cross-Ratio

The *cross-ratio* of four real numbers `z₁, z₂, z₃, z₄` is:

```
CR(z₁, z₂, z₃, z₄) = ((z₁ − z₃)(z₂ − z₄)) / ((z₁ − z₄)(z₂ − z₃))
```

---

## 3. The Berggren–Möbius Correspondence

### 3.1 Induced 2×2 Matrices

**Theorem 1** (SPB Equivariance). *Each Berggren generator induces a Möbius transformation on the SPB value. Specifically, if `(a, b, c)` is a PPT with `t = spb(a, b, c) = a/(c − b)`, then:*

| Generator | New SPB value | Möbius matrix | Determinant |
|-----------|---------------|---------------|-------------|
| U         | t + 2         | `[[1,2],[0,1]]` | +1 |
| A         | (2t + 1)/t    | `[[2,1],[1,0]]` | −1 |
| D         | (2t − 1)/t    | `[[2,−1],[1,0]]` | −1 |

*Proof.* For generator U: the transformed triple is `(a − 2b + 2c, 2a − b + 2c, 2a − 2b + 3c)`. The new denominator is `c' − b' = (2a − 2b + 3c) − (2a − b + 2c) = c − b`. Thus:

```
spb(U · (a,b,c)) = (a − 2b + 2c)/(c − b) = a/(c − b) + 2(c − b)/(c − b) = t + 2
```

This is the Möbius transformation `z ↦ (1·z + 2)/(0·z + 1)` with matrix `[[1,2],[0,1]]`.

For generators A and D, the computation uses the Pythagorean identity `a² + b² = c²` to simplify the resulting fractions. The verification is carried out in Lean 4 as `berggren_spb_equivariant_A` and `berggren_spb_equivariant_D`. □

### 3.2 The Monoid Homomorphism

The assignment `g ↦ berggren2x2(g)` extends uniquely via `FreeMonoid.lift` to a monoid homomorphism

```
Φ : FreeMonoid(Fin 3) →* Mat(2, ℤ)
```

satisfying `Φ(w₁ · w₂) = Φ(w₁) · Φ(w₂)`. The image of Φ lies in GL(2, ℤ) — the group of 2×2 integer matrices with determinant ±1.

**Remark.** Since det(A₂) = det(D₂) = −1, the image is not contained in SL(2, ℤ). However, even-length words in A and D (e.g., AA, AD, DA, DD) do map into SL(2, ℤ). The full image generates a subgroup of PGL(2, ℤ).

---

## 4. Main Theorem: Cross-Ratio Invariance

### 4.1 The Möbius Difference Lemma

**Lemma** (Möbius Difference). *For a Möbius transformation `f(z) = (az + b)/(cz + d)` with `cz₁ + d ≠ 0` and `cz₂ + d ≠ 0`:*

```
f(z₁) − f(z₂) = (ad − bc)(z₁ − z₂) / ((cz₁ + d)(cz₂ + d))
```

*Proof.* Direct computation:

```
f(z₁) − f(z₂) = (az₁+b)/(cz₁+d) − (az₂+b)/(cz₂+d)
               = [(az₁+b)(cz₂+d) − (az₂+b)(cz₁+d)] / [(cz₁+d)(cz₂+d)]
```

The numerator expands to `(ad − bc)(z₁ − z₂)`. □

### 4.2 Cross-Ratio Invariance

**Theorem 2** (Cross-Ratio Invariance). *For any Möbius transformation `f` with nonzero determinant, and four points `z₁, z₂, z₃, z₄` in the domain of `f` with `z₁ ≠ z₄` and `z₂ ≠ z₃`:*

```
CR(f(z₁), f(z₂), f(z₃), f(z₄)) = CR(z₁, z₂, z₃, z₄)
```

*Proof.* By the Möbius Difference Lemma:

```
f(zᵢ) − f(zⱼ) = (ad − bc)(zᵢ − zⱼ) / ((czᵢ + d)(czⱼ + d))
```

Substituting into the cross-ratio, the `(ad − bc)²` factors cancel, as do all denominator products `(czᵢ + d)`, yielding the original cross-ratio. □

### 4.3 The Main Result

**Theorem 3** (Berggren–Photonic Cross-Ratio Invariance). *For any word `w` in the free monoid on three generators, the Möbius transformation `Φ(w)` preserves the cross-ratio of four points:*

```
CR(Φ(w)·z₁, Φ(w)·z₂, Φ(w)·z₃, Φ(w)·z₄) = CR(z₁, z₂, z₃, z₄)
```

*Proof.* Immediate from Theorem 2, since each `Φ(w)` has nonzero determinant (det = ±1). □

**Corollary.** *If `p₁, p₂, p₃, p₄` are primitive Pythagorean triples and `w` is any Berggren word, then the cross-ratio of the SPB values is preserved under the Berggren action.*

---

## 5. Formal Verification

All theorems are machine-verified in Lean 4 with Mathlib. The formalization consists of three files:

| File | Content |
|------|---------|
| `Algebra/BerggrenPhotonic/Defs.lean` | Definitions of PPT, SPB, Möbius, cross-ratio, Berggren matrices |
| `Algebra/BerggrenPhotonic/CrossRatio.lean` | Möbius difference lemma, cross-ratio invariance theorem |
| `Algebra/BerggrenPhotonic/Main.lean` | SPB equivariance, main theorem, monoid homomorphism, verification |

Key formal statements:

```lean
-- Cross-ratio invariance under Möbius transformations (Theorem 2)
theorem cross_ratio_moebius_real (a b c d z₁ z₂ z₃ z₄ : ℝ)
    (hdet : a * d - b * c ≠ 0) ... :
    cross_ratio (moebiusReal a b c d z₁) (moebiusReal a b c d z₂)
                (moebiusReal a b c d z₃) (moebiusReal a b c d z₄) =
    cross_ratio z₁ z₂ z₃ z₄

-- Main theorem: Berggren–Photonic cross-ratio invariance (Theorem 3)
theorem berggren_photonic_cross_ratio_invariant
    (w : FreeMonoid (Fin 3))
    (Φ : FreeMonoid (Fin 3) →* Matrix (Fin 2) (Fin 2) ℤ) ... :
    cross_ratio (moebius (Φ w) z₁) (moebius (Φ w) z₂)
                (moebius (Φ w) z₃) (moebius (Φ w) z₄) =
    cross_ratio z₁ z₂ z₃ z₄
```

The proofs use no axioms beyond Lean's standard foundations (`propext`, `Classical.choice`, `Quot.sound`).

---

## 6. Discussion: Ancient Geometry Meets Modern Physics

*A Scientific American–style exposition*

### The World's Oldest Equation

The equation `a² + b² = c²` is perhaps the most ancient piece of mathematics still in active use. Babylonian clay tablets from 1800 BCE list Pythagorean triples, and the theorem bearing Pythagoras's name has been known for over 2,500 years. Yet this equation continues to reveal new structure.

In 1934, the Swedish mathematician B. Berggren discovered something remarkable: starting from the single triple (3, 4, 5) and applying three specific matrix transformations repeatedly, you can generate *every* primitive Pythagorean triple, each exactly once. The result is a ternary tree — an infinite branching structure where each node is a Pythagorean triple and its three children are obtained by the matrices U, A, and D.

### The Light Cone Connection

Now consider the same equation from a physicist's perspective. In Einstein's special relativity, the equation `E² = p₁² + p₂²` (with the speed of light set to 1) describes a massless particle — a photon — moving in two spatial dimensions. The "light cone" of all such states is precisely the Pythagorean surface `a² + b² = c²`.

This is not a coincidence — it's a mathematical identity. Every Pythagorean triple is a rational point on the light cone. The Berggren tree generates all the "rational photons."

### The Bridge

The Stereographic Pythagorean Bridge is a remarkably simple map: take a Pythagorean triple (a, b, c) and compute `t = a/(c − b)`. This single number encodes the triple's "projective position" on the photonic frontier.

What makes this bridge profound is what it preserves. Each of the three Berggren transformations, which are originally 3×3 matrix operations on triples, collapse through the bridge into simple fractional-linear (Möbius) transformations on the real line:

- **U**: `t ↦ t + 2` (shift by 2)
- **A**: `t ↦ (2t + 1)/t` (a kind of inversion)
- **D**: `t ↦ (2t − 1)/t` (another inversion)

Think of it this way: the Berggren tree is like a vast, branching genealogy of Pythagorean triples. The SPB is like assigning each family member a single coordinate. And the theorem says that the family relationships (encoded by U, A, D) correspond to simple geometric motions (Möbius transformations) on this coordinate.

### The Cross-Ratio: Nature's Invariant

The cross-ratio is one of the most fundamental objects in mathematics. Given four points on a line, the cross-ratio is a single number that captures their "projective shape" — it's the one quantity that doesn't change when you apply any projective transformation to all four points simultaneously. It was studied by the ancient Greeks, formalized by Möbius and Cayley in the 19th century, and remains central to modern conformal field theory and string theory.

Our theorem says: take any four Pythagorean triples, compute their SPB values, and measure the cross-ratio. Now apply *any* sequence of Berggren transformations to all four triples. The cross-ratio is unchanged.

This is significant because it means the Berggren tree — a purely number-theoretic construction from 1934 — respects the same projective symmetries that govern conformal field theory, twistor theory, and scattering amplitudes in modern physics. The algebra of Pythagorean triples and the geometry of massless particles are, in a precise sense, the same mathematics.

---

## 7. Applications

### 7.1 Error Detection in Pythagorean Triple Enumeration

The cross-ratio invariance provides a checksum for Berggren tree traversal. When generating large databases of Pythagorean triples (used in cryptography, signal processing, and antenna design), one can verify the correctness of a batch of transformations by checking that the cross-ratio of four reference triples is preserved at every step. A single bit-flip in the matrix multiplication will break the cross-ratio equality, providing immediate error detection.

### 7.2 Exact Rational Rotations in Computer Graphics

Pythagorean triples generate exact rational rotations via the formula `cos θ = (a² − b²)/(a² + b²)`, `sin θ = 2ab/(a² + b²)`. The Berggren tree provides a systematic way to enumerate all such exact rotations. The Möbius structure reveals which rotations are "close" in the projective sense: triples with similar SPB values produce rotations that are projectively adjacent, enabling efficient search for approximate rational rotations with bounded denominator.

### 7.3 Number Theory: Distribution of Pythagorean Triples

The SPB-Möbius correspondence transforms questions about the distribution of Pythagorean triples into questions about orbits under Möbius transformations. For instance, the density of SPB values in any interval `[a, b]` is related to the spectral theory of the corresponding Möbius group. This connects the ancient theory of Pythagorean triples to modern automorphic forms and the Selberg trace formula.

### 7.4 Scattering Amplitudes at Rational Kinematics

In the computation of massless scattering amplitudes, cross-ratios of external momenta are the fundamental conformal invariants. Our result shows that the space of rational null momenta (Pythagorean triples) has a natural discrete symmetry group (the Berggren monoid) that preserves these invariants. This opens the door to studying scattering amplitudes at rational kinematic points with exact arithmetic, potentially relevant for numerical bootstrap programs.

---

## 8. Future Directions

1. **Tropical Berggren–Feynman correspondence.** The Möbius matrices act on the tropical semiring via max-plus algebra. Investigating whether tropical Möbius transformations preserve a tropical cross-ratio would connect the Berggren tree to tropical geometry and tropical Feynman integrals.

2. **Higher-dimensional generalization.** The Berggren tree is specific to dimension 2+1. In higher dimensions, the analogous structure involves integer points on the light cone `x₁² + ... + x_{n}² = c²`, with the conformal group SO(n, 1; ℤ) replacing PGL(2, ℤ).

3. **Hecke operators.** The Berggren matrices generate a subgroup of GL(2, ℤ) that acts on modular forms. Understanding the relationship between Berggren dynamics and classical Hecke operators could yield new insights into the arithmetic of Pythagorean triples.

4. **Arithmetic dynamics.** The Berggren tree defines a dynamical system on the projective line. Questions about the ergodic properties of this system — measure-theoretic properties, Lyapunov exponents, entropy — connect to the well-studied dynamics of continued fraction maps and Gauss-type maps.

---

## References

- B. Berggren, "Pytagoreiska trianglar," *Tidskrift för Elementär Matematik, Fysik och Kemi*, 17 (1934), 129–139.
- A. Hall, "Genealogy of Pythagorean triads," *The Mathematical Gazette*, 54 (1970), 377–379.
- R. Penrose, "Twistor algebra," *Journal of Mathematical Physics*, 8 (1967), 345–366.
- S. Weinzierl, *Feynman Integrals*, Springer, 2022.
