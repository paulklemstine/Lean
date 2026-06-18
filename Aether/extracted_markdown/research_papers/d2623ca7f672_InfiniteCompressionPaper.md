# Stereographic Singularities and the Impossibility of Infinite Compression: A Formally Verified Analysis

## Abstract

We present a rigorous, machine-verified analysis of the mathematical claims underlying the concept of "infinite compression via stereographic singularities." While stereographic projection provides an elegant diffeomorphism between the plane and the punctured sphere — enabling arbitrarily high *information density* near the north pole — we prove that this geometric property cannot circumvent the pigeonhole principle. No lossless encoding, stereographic or otherwise, can compress all n-bit strings into fewer than n bits. All results are formalized and verified in Lean 4 with Mathlib, yielding 18 machine-checked theorems with zero sorry axioms and only the standard foundational axioms (propext, Classical.choice, Quot.sound).

**Keywords:** Stereographic projection, data compression, pigeonhole principle, formal verification, Lean 4, information theory

---

## 1. Introduction

The inverse stereographic projection σ⁻¹ : ℝ² → S² maps the entire Euclidean plane onto the unit sphere minus a single point (the north pole). As coordinates (u, v) grow without bound, the image point approaches the pole, concentrating arbitrarily many mapped points into an arbitrarily small spherical cap. This behavior has inspired speculative ideas about "infinite compression" — the notion that data could be packed arbitrarily densely near the pole of a stereographic projection, achieving compression ratios beyond information-theoretic limits.

In this paper, we rigorously formalize and verify the mathematical content of this framework, proving both:

1. **What is true:** The stereographic projection does map to the sphere, is invertible, and produces monotonically decreasing solid angles as data is packed closer to the pole.

2. **What is impossible:** No encoding scheme — including stereographic projection — can losslessly compress all n-bit strings to fewer than n bits, regardless of how high the "informational density" grows.

All proofs are machine-checked in Lean 4 using the Mathlib library.

## 2. Stereographic Projection: Verified Properties

### 2.1 The Inverse Stereographic Map

**Definition.** The inverse stereographic projection from ℝ² to S² is:

$$\sigma^{-1}(u, v) = \left(\frac{2u}{u^2+v^2+1},\ \frac{2v}{u^2+v^2+1},\ \frac{u^2+v^2-1}{u^2+v^2+1}\right)$$

**Theorem 1 (Sphere Landing).** *For all (u, v) ∈ ℝ², the image σ⁻¹(u,v) lies on S²:*

$$\left(\frac{2u}{D}\right)^2 + \left(\frac{2v}{D}\right)^2 + \left(\frac{D-2}{D}\right)^2 = 1$$

*where D = u² + v² + 1.*

*Proof.* Clearing denominators via `field_simp` reduces this to the polynomial identity (2u)² + (2v)² + (u² + v² − 1)² = (u² + v² + 1)², which holds by `ring`. ∎

**Theorem 2 (Circle Landing, 1D case).** *For all t ∈ ℝ:*

$$\left(\frac{2t}{t^2+1}\right)^2 + \left(\frac{t^2-1}{t^2+1}\right)^2 = 1$$

### 2.2 Roundtrip Identity

**Theorem 3 (Forward ∘ Inverse = Identity).** *The north-pole forward projection σ(x,y) = x/(1−y), composed with σ⁻¹, recovers the parameter:*

$$\frac{2t/(t^2+1)}{1 - (t^2-1)/(t^2+1)} = t$$

*Proof.* The denominator simplifies: 1 − (t²−1)/(t²+1) = 2/(t²+1). Then (2t/(t²+1)) / (2/(t²+1)) = t. Verified by `field_simp; ring`. ∎

**Theorems 4–5 (Inverse ∘ Forward = Identity).** For (x,y) on S¹ with appropriate non-degeneracy conditions, both components of σ⁻¹(σ(x,y)) recover x and y respectively. Proved using `grind` (Lean's automated reasoning).

### 2.3 Z-Coordinate and Solid Angle Properties

**Theorem 6 (Z-Bounded).** The Z-coordinate satisfies −1 ≤ Z ≤ 1.

**Theorem 7 (Solid Angle Formula).** 1 − Z = 2/(u² + v² + 1).

**Theorem 8 (Monotonicity).** For 0 ≤ r₁ ≤ r₂, the solid angle factor at r₂ is no greater than at r₁:

$$\frac{2}{r_2^2 + 1} \leq \frac{2}{r_1^2 + 1}$$

This confirms that packing data at larger stereographic radii (closer to the pole) does reduce the solid angle subtended.

## 3. The Impossibility of Infinite Compression

### 3.1 The Pigeonhole Principle

**Theorem 9 (Compression Pigeonhole).** *For N < M, there exists no injection f : Fin M → Fin N.*

This is the fundamental counting argument: you cannot injectively map a larger set into a smaller one.

### 3.2 Stereographic Encoding Cannot Beat Pigeonhole

**Theorem 10.** *For n ≥ 1, there is no injection from Fin(2ⁿ) to Fin(2ⁿ⁻¹).*

**Theorem 11 (Lossless ⟹ Injective).** *If decode ∘ encode = id, then encode is injective.*

**Theorem 12 (Main Impossibility).** *No lossless encoder-decoder pair can map 2ⁿ values into 2ⁿ⁻¹ slots:*

*For any encode : Fin(2ⁿ) → Fin(2ⁿ⁻¹) and decode : Fin(2ⁿ⁻¹) → Fin(2ⁿ) satisfying ∀ x, decode(encode(x)) = x, we derive False.*

### 3.3 Density Divergence Does Not Help

**Theorem 13 (Density Diverges).** *For any n > 0 and any bound B, there exists Ω > 0 such that n/Ω > B.*

This confirms that information density can be made arbitrarily large by reducing the solid angle.

**Theorem 14 (Density vs. Pigeonhole).** *Despite unbounded density, for k < n there is no injection Fin(2ⁿ) → Fin(2ᵏ).*

The key insight: high density is a *continuous* phenomenon (real-valued coordinates can be packed arbitrarily close), while compression is a *discrete* phenomenon (distinct bitstrings must map to distinct codewords). The pigeonhole principle operates on the discrete level and cannot be circumvented by continuous geometric tricks.

## 4. Warped Arithmetic

### 4.1 Circle Group Structure

**Theorem 15 (Circle Multiplication Closure).** *If (x₁,y₁) and (x₂,y₂) lie on S¹, then (x₁x₂ − y₁y₂, x₁y₂ + y₁x₂) also lies on S¹.*

This is the unit circle group under complex multiplication. The proof is a single `linear_combination` of the two unit-norm hypotheses.

**Theorem 16 (Tangent Addition on Circle).** *For any a, b ∈ ℝ with 1 − ab ≠ 0, the tangent-addition value t = (a+b)/(1−ab) maps to S¹ via σ⁻¹.*

This follows immediately from Theorem 2 (every real number maps to S¹ via σ⁻¹).

## 5. Quantization Resolution

**Theorem 17 (Quantization Resolution).** *If 2ᵏ < M, there is no injection Fin M → Fin(2ᵏ).*

This formalizes the fact that representing M distinct data points with k-bit precision requires M ≤ 2ᵏ. When stereographic coordinates are packed into a tiny region near the pole, distinguishing M points requires precision (number of bits) that grows with M — there is no free lunch.

## 6. Formal Verification Summary

| # | Theorem | Status |
|---|---------|--------|
| 1 | `inverse_stereo_on_sphere` | ✅ Verified |
| 2 | `inverse_stereo_on_circle` | ✅ Verified |
| 3 | `stereo_roundtrip` | ✅ Verified |
| 4 | `stereo_inverse_forward_fst` | ✅ Verified |
| 5 | `stereo_inverse_forward_snd` | ✅ Verified |
| 6 | `stereo_z_bounded` | ✅ Verified |
| 7 | `solid_angle_nonneg` | ✅ Verified |
| 8 | `solid_angle_formula` | ✅ Verified |
| 9 | `solid_angle_decreasing` | ✅ Verified |
| 10 | `compression_pigeonhole` | ✅ Verified |
| 11 | `stereo_compression_impossible` | ✅ Verified |
| 12 | `lossless_is_injective` | ✅ Verified |
| 13 | `infinite_compression_impossible` | ✅ Verified |
| 14 | `quantization_resolution` | ✅ Verified |
| 15 | `circle_mul_on_circle` | ✅ Verified |
| 16 | `tangent_addition` | ✅ Verified |
| 17 | `density_diverges` | ✅ Verified |
| 18 | `density_vs_pigeonhole` | ✅ Verified |

**Axioms used:** propext, Classical.choice, Quot.sound (all standard).

## 7. Conclusion

Stereographic projection is a beautiful and useful mathematical construction. Its ability to concentrate an infinite plane into a finite sphere — with information density diverging near the pole — is geometrically real and formally verified. However, this geometric concentration operates in the *continuous* domain (ℝ²) and does not translate to *discrete* compression gains. The pigeonhole principle, also formally verified, provides an absolute barrier: no injective map can exist from a larger finite set to a smaller one, regardless of how the encoding is geometrically arranged.

The formal verification methodology demonstrates that machine-checked proofs can definitively resolve claims at the intersection of geometry and information theory, leaving no room for ambiguity about what is mathematically possible and what is not.

---

*All proofs available in `Stereographic/InfiniteCompression.lean`, verified with Lean 4.28.0 and Mathlib.*
