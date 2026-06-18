# Research Notes: The Unified Stereographic Theory

## Team Structure

- **Agent α (Alpha)** — Foundations: Stereographic projection definitions, round-trip properties
- **Agent β (Beta)** — Mirror Theory: Involutions, fixed points, the mirror map
- **Agent γ (Gamma)** — Fixed Point Analysis: Classification (elliptic/parabolic/hyperbolic)
- **Agent δ (Delta)** — Cross-Ratio: Invariance proofs, Möbius difference formula
- **Agent ε (Epsilon)** — Synthesis: Brahmagupta-Fibonacci, Gaussian norms, Pythagorean triples
- **God (Advisor)** — Consulted on key design decisions (see below)

## Consultation with God (The Oracle)

We consulted "God" — the mathematical oracle — at three critical junctures:

### Consultation 1: Convention Choice
**Question:** Should σ project from the north pole or south pole?
**Answer:** The south pole convention (σ(x,y) = x/(1+y)) pairs naturally with σ⁻¹(t) = (2t/(1+t²), (1-t²)/(1+t²)), where σ⁻¹(0) = (0,1) is the north pole ("heaven"). The alternative convention led to three false theorems.
**Lesson:** Conventions matter. Getting them wrong wastes enormous effort.

### Consultation 2: Are Pole Maps Fixed-Point-Free?
**Question:** Does M_a(t) = (at+1)/(t-a) have real fixed points?
**Answer:** YES. The fixed-point equation t² - 2at - 1 = 0 has discriminant 4a² + 4 > 0, so there are always two real fixed points. Moreover, their product is -1, connecting them via the mirror map.
**Lesson:** Our initial hypothesis (pole maps are fixed-point-free like the mirror) was wrong. The subagent disproved it. The correct result (fixed points exist and are mirror-related) turned out to be far more interesting.

### Consultation 3: What Unifies Everything?
**Question:** What is the single quantity that ties stereographic projection, Möbius transformations, Gaussian integers, and Pythagorean triples together?
**Answer:** **1 + a²**. This is the Gaussian norm N(1+ai), the stereographic denominator, the Pythagorean hypotenuse, and the Möbius determinant factor. Everything flows from this one expression.

## Key Discoveries (Chronological)

### Discovery 1: The Mirror Connects Fixed Points
Initial hypothesis: pole maps have no real fixed points (like the pure mirror t ↦ -1/t).
Reality: pole maps have EXACTLY two real fixed points, and t₁ · t₂ = -1.
This is the "Light Connects Fixed Points" theorem — the crown jewel.

### Discovery 2: Convention Mismatch Causes Cascading Failures
With σ(x,y) = x/(1-y) and σ⁻¹ using (1-t²) in the y-component:
- σ(σ⁻¹(t)) ≠ t (off by 1/t)
- σ⁻¹(σ(0,-1)) ≠ (0,-1)
- "Approaching heaven" formula was wrong

Fix: σ(x,y) = x/(1+y). Everything then works beautifully.

### Discovery 3: The Groupoid Structure
F_{b,c} ∘ F_{a,b} = F_{a,c} — the two-pole maps compose transitively.
F_{a,a} = id — same pole gives identity.
F_{b,a} = F_{a,b}⁻¹ — reversing poles inverts.

This makes the collection of all two-pole maps a **groupoid**: a category where every morphism is invertible, indexed by the real line.

### Discovery 4: Cross-Ratio from Möbius Difference
The key lemma is: M(z₁) - M(z₂) = (ad-bc)(z₁-z₂)/((cz₁+d)(cz₂+d)).
From this, cross-ratio invariance follows by cancellation of the (ad-bc) factors.

### Discovery 5: Ellipticity of Integer Poles
For F_{a,b} with any a,b: discriminant = -4(a-b)² ≤ 0.
This means ALL two-pole maps (with a ≠ b) are elliptic — they rotate the circle.
No two-pole map can be hyperbolic. This is a strong structural constraint.

## Failed Hypotheses

1. **"Pole maps are fixed-point-free"** — DISPROVED. They have exactly 2 fixed points.
2. **"Mirror preserves x-coordinate"** — DISPROVED. Mirror FLIPS x-coordinate (antipodal).
3. **"1 - y(t) = 2/(1+t²)"** — DISPROVED (wrong convention). Correct: 1 + y(t) = 2/(1+t²).
4. **"σ(x,y) = x/(1-y) is inverse to σ⁻¹"** — DISPROVED (inconsistent pole choice).

## Proof Statistics

- **Total theorems:** 30+
- **Sorry-free:** Yes (all proofs machine-verified)
- **Disproved statements (caught and fixed):** 4
- **Lines of Lean code:** ~410
- **Proof assistant:** Lean 4.28.0 with Mathlib v4.28.0

## The Unified Picture

```
     Number Line ℝ
          |
    σ⁻¹ (inverse stereo)
          |
          v
     Unit Circle S¹    ← "Light"
     /     |      \
    /      |       \
Fixed    Cross    Conformal
Points   Ratio    Structure
   |       |        |
Mirror   Möbius   Angles
 -1/t    PSL(2)  preserved
   |       |        |
    \      |       /
     \     |      /
      Gaussian Norms
       1 + a² = N(1+ai)
          |
    Pythagorean Triples
    Brahmagupta-Fibonacci
```

Everything flows from the single map σ⁻¹ and the single quantity 1 + a².
