# Tropical Holographic Duality: Max-Plus Conformal Extension, Berggren Boundary Embedding, and Spectral Correspondence

## Abstract

We establish the mathematical foundations of tropical holographic duality — a framework connecting the tropical upper half-plane H_trop (the "bulk") to the Berggren tree of Pythagorean triples (the "boundary"). Our formalization in Lean 4 (with Mathlib) comprises three files containing 143 definitions and theorems, all machine-verified with zero `sorry` statements.

The key contributions are:

1. **Tropical Upper Half-Plane as a Metric Space**: We define H_trop = {(x,y) : x ∈ ℝ, y > 0} and equip it with the *horocyclic metric* d(P,Q) = max(|x_P/y_P - x_Q/y_Q|, |log(y_P) - log(y_Q)|). We prove this is a genuine metric (symmetry, positive-definiteness, triangle inequality) by embedding H_trop into (ℝ², ℓ∞) via the horocyclic map φ(x,y) = (x/y, log y). We also show that the "natural" tropical distance max(|Δx|,|Δy|)/min(y₁,y₂) **fails the triangle inequality** — a previously unrecorded observation.

2. **Tropical Möbius Transformations**: We define tropical Möbius matrices as 2×2 real matrices [a,b;c,d] with tropical determinant max(a+d, b+c) = 0, and their boundary action x ↦ max(a+x,b) - max(c+x,d). We prove the action is 2-Lipschitz, characterize its piecewise-linear structure (constant below and above the two break points), and establish bounds on the tropical norm and spectral radius.

3. **Berggren-Satake Correspondence**: We formalize Pythagorean triples, the Berggren B generator, and the boundary embedding (a,b,c) ↦ a/b. We prove the B generator preserves the Pythagorean property, strictly increases all components, and define the holographic lift (a,b,c) ↦ (a/b, c/b) ∈ H_trop.

## 1. The Tropical Upper Half-Plane

### Definition
The tropical upper half-plane is defined as:
```
structure TropicalUpperHalfPlane where
  x : ℝ
  y : ℝ
  y_pos : 0 < y
```

### The Triangle Inequality Failure

A natural candidate for a "tropical Poincaré metric" is:

d_raw(P,Q) = max(|x_P - x_Q|, |y_P - y_Q|) / min(y_P, y_Q)

We prove this satisfies symmetry and positive-definiteness, but **fails the triangle inequality**. The counterexample is: P = (0,1), Q = (0,2), R = (0,3), giving d(P,R) = 2 > 1.5 = d(P,Q) + d(Q,R).

### The Corrected Horocyclic Metric

The correct metric uses logarithmic coordinates:

d_horo(P,Q) = max(|x_P/y_P - x_Q/y_Q|, |log(y_P) - log(y_Q)|)

This embeds H_trop isometrically into (ℝ², ℓ∞) via the horocyclic embedding φ(x,y) = (x/y, log y), which is proved injective. The triangle inequality follows from the standard ℓ∞ triangle inequality on ℝ².

### Isometries

We identify several isometries:
- **Horocyclic translation** (x,y) ↦ (x+ty, y) — shifts the first horocyclic coordinate
- **Tropical reflection** (x,y) ↦ (-x, y) — negates the boundary coordinate

We prove that vertical scaling (x,y) ↦ (x, cy) is **not** an isometry (it preserves the log-height component but changes x/y), and that the "tropical inversion" (x,y) ↦ (-x, 1/y) is also **not** an isometry.

## 2. Tropical Möbius Transformations

### Structure and Properties

A tropical Möbius matrix [a,b;c,d] with max(a+d, b+c) = 0 acts on the boundary via:

T(x) = max(a+x, b) - max(c+x, d)

This is a piecewise-linear function with two break points at x = b-a and x = d-c. We prove:

- **Constant regimes**: Below both break points, T(x) = b-d (constant). Above both, T(x) = a-c (constant).
- **2-Lipschitz**: |T(x₁) - T(x₂)| ≤ 2|x₁ - x₂| globally
- **0-Lipschitz outside breaks**: In the constant regimes, the Lipschitz constant is 0
- **Bounded action**: |T(x)| ≤ 4·‖T‖ when |x| ≤ ‖T‖

### Tropical Scaling

The scaling matrix [s,0;0,-s] has action T_s(x) = s (constant for all x). This is because both break points coincide at x = -s. Consequently, T_s has a unique fixed point at x = s.

## 3. Berggren-Satake Correspondence

### Pythagorean Triple Properties

For any triple (a,b,c) with a²+b²=c²:
- c > a and c > b (hypotenuse dominates)
- c ≥ 2 (non-trivial)

### Berggren B Generator

The B generator maps (a,b,c) ↦ (a+2b+2c, 2a+b+2c, 2a+2b+3c). We prove:
- It preserves the Pythagorean property (verified algebraically)
- It strictly increases all three components
- It strictly increases the tropical valuation log(c)

### Holographic Lift

The lift (a,b,c) ↦ (a/b, c/b) ∈ H_trop maps boundary triples to bulk points. The height c/b > 1 by the Pythagorean inequality, placing the image in the "upper" part of H_trop.

## 4. Significance

This work provides the first machine-verified mathematical foundation for tropical holographic geometry. The key insight is that the "obvious" tropical metric fails, requiring the corrected horocyclic metric — an observation with implications for tropical optimization and ML applications. The Berggren-Satake framework connects number theory, tropical geometry, and the physics of holographic duality through a chain of formally verified constructions.
