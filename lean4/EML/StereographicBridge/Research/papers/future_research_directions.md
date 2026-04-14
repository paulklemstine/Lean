# Future Research Directions for the Stereographic Projection Bridge

## A Prioritized Roadmap with Detailed Technical Approaches

---

## Executive Summary

This document outlines 25 research directions organized by feasibility, impact, and cross-disciplinary potential. Each direction includes: precise problem statements, proposed approaches, required mathematical infrastructure, estimated difficulty, and expected outcomes.

---

## Tier 1: Immediate Opportunities (3-6 months)

### 1.1 Formal Proof of the p±1 Law

**Problem**: Prove in Lean 4 that the SPB group over 𝔽_p has order p+1 when p ≡ 3 (mod 4) and p−1 when p ≡ 1 (mod 4).

**Approach**:
1. Define the SPB group as a quotient: {x ∈ 𝔽_p : 1−x² ≠ 0} / (poles)
2. Construct the Cayley transform C(x) = (1+ix)/(1−ix) over 𝔽_p (or 𝔽_{p²})
3. Show C is a group homomorphism from (SPB group) to (multiplicative group of norm-1 elements)
4. Count the norm-1 elements using Hilbert's Theorem 90

**Mathlib requirements**: `ZMod`, `GaloisField`, `Finset.card`, quadratic residue theory.

**Difficulty**: ★★★ | **Impact**: High (connects algebra to number theory)

### 1.2 Machin Formula Optimization

**Problem**: What is the minimum-leaf SPB tree evaluating to 1 using only reciprocals 1/n?

**Approach**:
- Exhaustive search for trees with ≤ 4 leaves
- Algebraic constraints: if spb(1/a, 1/b) = 1, then (1/a + 1/b)/(1 − 1/ab) = 1, giving a + b = ab − 1
- This factors as (a−1)(b−1) = 2, yielding (a,b) = (2,3) uniquely (up to order)
- Therefore Euler's formula is optimal at 2 leaves

**Outcome**: Machine-verified proof that Euler's formula is the unique 2-leaf Machin formula.

**Difficulty**: ★★ | **Impact**: Medium (elegant result, good exposition)

### 1.3 SPB Integer Classification

**Problem**: Classify all (a,b) ∈ ℤ² with spb(a,b) ∈ ℤ.

**Approach**:
- Condition: (1−ab) | (a+b)
- Write a = qd − b where d = 1−ab, q = spb(a,b) ∈ ℤ
- This gives parametric families: for each d | (a+b), get a solution
- Conjecture: the solutions form a tree structure related to the Stern-Brocot tree

**Computational support**: Python enumeration up to |a|, |b| ≤ 1000

**Difficulty**: ★★ | **Impact**: Medium

### 1.4 CORDIC Replacement Architecture

**Problem**: Design an arithmetic circuit computing trigonometric functions via SPB.

**Approach**:
- Input: angle θ in fixed-point, decompose θ = Σ arctan(2⁻ᵏ)
- Use spb(tan(α), tan(β)) = tan(α+β) with pre-stored tan(arctan(2⁻ᵏ)) = 2⁻ᵏ
- Each step: one addition, one multiplication, one subtraction, one division
- Compare latency and gate count with standard CORDIC

**Difficulty**: ★ | **Impact**: High (engineering application)

### 1.5 SPB Derivative Chain Rule Formalization

**Problem**: Formalize: d/dx[spb(spb(x,a),b)] = [(1+a²)/(1−xa)²] · [(1+b²)/(1−spb(x,a)·b)²]

**Approach**: Direct application of `HasDerivAt` from Mathlib, using the quotient rule.

**Difficulty**: ★★ | **Impact**: Medium (enables analytic applications)

---

## Tier 2: Medium-Term Goals (6-18 months)

### 2.1 Equidistribution of SPB Orbits

**Problem**: Prove that orbits of x ↦ spb(x, a) are equidistributed (w.r.t. Cauchy measure) when arctan(a)/π is irrational.

**Strategy**:
1. Show the Cayley transform conjugates the SPB orbit to an irrational rotation on S¹
2. Apply Weyl's equidistribution theorem (available in Mathlib as `AddCircle.tendsto_average`)
3. Push the uniform distribution through C⁻¹ to get the Cauchy distribution on ℝ

**Key challenge**: Formalizing the pushforward of Haar measure through the Cayley transform.

**Difficulty**: ★★★ | **Impact**: High (clean theoretical result)

### 2.2 Quaternionic SPB

**Problem**: Define and study spbH(q₁, q₂) = (q₁ + q₂)(1 + q̄₁q₂)⁻¹ for quaternions.

**Key phenomena**:
- Non-commutativity: spbH(q₁, q₂) ≠ spbH(q₂, q₁)
- The "defect" is Thomas precession
- Relates to SO(3) and the Rodrigues rotation formula
- Physical meaning: relativistic 3-velocity addition

**Mathlib status**: Quaternion algebra exists (`Quaternion`), but the geometric algebra is limited.

**Difficulty**: ★★★ | **Impact**: High (physics applications)

### 2.3 SPB Neural Networks

**Problem**: Prove universal approximation for networks with SPB neurons y = spbH(x, w) = (x+w)/(1+xw).

**Advantages over ReLU**:
- Natural boundedness: maps (−1,1) → (−1,1)
- Smoothness: infinitely differentiable
- Invertibility: inverse is spbH(y, −w)
- Group structure: composition of layers = single SPB with composed parameter

**Approach**: Adapt the Stone-Weierstrass theorem. The SPB neurons separate points on (−1,1) and are bounded, so their span is dense in C([−r, r]) for r < 1.

**Difficulty**: ★★ | **Impact**: High (practical ML application)

### 2.4 SPB Gate Synthesis for Quantum Computing

**Problem**: Given a target single-qubit gate U ∈ SU(2), find the shortest SPB decomposition.

**Strategy**:
- Every SU(2) gate acts as a Möbius transformation ζ ↦ (aζ+b)/(cζ+d)
- SPB gates are the special case c = −b, d = a (rotation class)
- Decompose arbitrary Möbius into SPB + scaling + SPB
- Connect to Solovay-Kitaev approximation for SPB-type gate sets

**Difficulty**: ★★★ | **Impact**: High (quantum computing)

### 2.5 Tropical SPB Structure Theory

**Problem**: Determine the algebraic structure of (ℝ, tropical_spb).

**Key observations**:
- Commutative: ✓
- Identity exists only for negative inputs (partial identity)
- Associative: fails in general (verified computationally)
- Idempotent for negative inputs: tspb(x, x) = x when x ≤ 0

**Conjecture**: Tropical SPB is a *tropical quasigroup* — a quasigroup in the tropical semiring sense.

**Approach**: Check the quasigroup axioms (unique solutions to a ⊕ x = b and x ⊕ a = b).

**Difficulty**: ★★ | **Impact**: Medium (foundational algebra)

### 2.6 p-adic SPB

**Problem**: Study the SPB group over ℤ_p and ℚ_p.

**Conjecture**: The SPB group over ℤ_p is the projective limit lim←(SPB groups over ℤ/p^n ℤ), and is pro-cyclic with the same order pattern as the p±1 law.

**Approach**: The p-adic Cayley transform extends naturally, and the p-adic norm-1 subgroup is well-understood.

**Difficulty**: ★★★ | **Impact**: Medium (number theory)

### 2.7 SPB Continued Fractions

**Problem**: Express convergence of continued fractions in SPB language.

**Observation**: The convergents pₙ/qₙ of tan(1) = [1; 1, 1, 3, 1, 5, 1, 7, ...] satisfy arctan(pₙ/qₙ) → 1. Each step of the continued fraction algorithm can be expressed as an SPB operation.

**Algorithm sketch**:
```
SPB-CF(x):
  If x ≈ 0, return []
  n = ⌊1/x⌉ (nearest integer reciprocal)
  remainder = spb(x, -1/n) (SPB subtraction)
  return n :: SPB-CF(remainder)
```

**Difficulty**: ★★ | **Impact**: Medium

---

## Tier 3: Long-Term Goals (1-3 years)

### 3.1 SPB Transport PDE

**Problem**: Study ∂u/∂t = spb(u, f(x,t)) = (u + f)/(1 − uf).

**Key questions**:
- Finite-time blowup when uf → 1 (denominator vanishes)
- Weak solutions past blowup (distributional solutions on ℝP¹)
- Connection to Riccati equation (SPB ODE is equivalent to Riccati)
- Shock formation analogy with Burgers' equation

**Strategy**: Through the Cayley transform, this becomes dv/dt = v·g(x,t) on S¹, which is linear and solvable. Singularities correspond to v passing through −1 (the image of ∞).

**Difficulty**: ★★★ | **Impact**: High (analysis)

### 3.2 Conformal Field Theory Connection

**Problem**: Connect SPB to the Virasoro algebra in 2D CFT.

**Observation**: SPB generates the finite-dimensional conformal group (Möbius transformations) on ℝP¹. The Virasoro algebra is the infinite-dimensional extension. The tangent vector field at the identity is d/dθ = L₀.

**Speculative direction**: Can SPB be "quantized" to produce the central extension? The central charge c might appear as an anomaly in the SPB composition rule.

**Difficulty**: ★★★★ | **Impact**: Very high (mathematical physics)

### 3.3 SPB-EML Universality Conjecture

**Problem**: Prove or disprove that every elementary function is a finite composition of SPB and EML.

**Known**:
- sin(x) via Weierstrass substitution: sin(x) = 2·spb(tan(x/2), ·)/(1 + tan²(x/2))
- exp(x) = eml(x, 1)
- log(x) = eml(0, 1/x)
- Polynomials via repeated multiplication (EML generates ×)

**Challenge**: Show these generate the *closure* under composition, which should include all elementary functions.

**Difficulty**: ★★★ | **Impact**: Very high (foundational)

### 3.4 Higher-Rank Symmetric Spaces

**Problem**: Generalize SPB to higher-rank symmetric spaces.

**Examples**:
| Symmetric space | SPB analogue | Application |
|----------------|-------------|-------------|
| SO(2)/SO(1) = S¹ | (x+y)/(1−xy) | Trigonometry |
| SO(3)/SO(2) = S² | Möbius on Ĉ | Bloch sphere |
| SO(3,1)/SO(3) = H³ | 3D velocity addition | Relativity |
| SU(n)/U(n-1) = ℂPⁿ⁻¹ | Matrix SPB | Quantum info |
| Sp(2n)/U(n) | Siegel transform | Moduli spaces |

**Difficulty**: ★★★★ | **Impact**: Very high (unifying framework)

### 3.5 SPB and Elliptic Curves

**Problem**: The SPB group over ℚ is isomorphic to ℚ/ℤ via arctan/π. Is there an "elliptic SPB" where the circle group is replaced by an elliptic curve?

**Approach**: Replace the Cayley transform with a Weierstrass ℘-function parametrization. The resulting operation would be an "elliptic tangent addition" related to the addition law on the curve.

**Difficulty**: ★★★★ | **Impact**: Very high (arithmetic geometry)

---

## Tier 4: Speculative Directions

### 4.1 SPB Cryptography

The SPB discrete logarithm problem over 𝔽_p: given g and h = spb^n(0, g), find n. The security reduces to the ordinary DLP in 𝔽_p* or 𝔽_{p²}*, which is well-studied. But the SPB formulation might admit novel algorithmic approaches.

### 4.2 SPB in String Theory

The Nambu-Goto action for a string moving on S¹ could be expressed in SPB coordinates. The worldsheet conformal symmetry becomes a Virasoro constraint on SPB modes.

### 4.3 SPB Machine Learning Architectures

Design neural architectures where:
- Layers are SPB transformations (inherently bounded)
- Skip connections use SPB composition (associative)
- Normalization is built-in (no batch norm needed)

### 4.4 SPB and Quantum Error Correction

The p±1 law gives groups of specific orders over 𝔽_p. For qudit codes of dimension p, these could provide:
- Transversal gates from the SPB group
- Stabilizer codes with SPB symmetry
- Threshold estimates from the group order formula

### 4.5 Genomic SPB

The 4-letter DNA alphabet can be mapped to 𝔽₅ (the 4 non-pole elements of the SPB group over 𝔽₅). Codon combinations under SPB might reveal algebraic structure in the genetic code.

---

## Methodology Recommendations

### Machine Verification Strategy
1. **State conjectures in Lean before proving**: catches formulation errors early
2. **Use `native_decide` for finite verification**: confirms p±1 law for specific primes
3. **Build proof skeletons with sorry**: validates proof architecture before details
4. **Cayley-conjugate strategy**: prove on S¹, push back through C

### Computational Exploration
1. **Python for discovery**: generate examples, test conjectures, find counterexamples
2. **SAGE for algebra**: finite field computations, group structure analysis
3. **Julia for numerics**: high-performance orbit computation, PDE simulation

### Collaboration Structure
- **Core team**: 2-3 people for Lean formalization
- **Number theory**: expert for p±1 formal proof
- **Physics**: expert for quaternionic/relativistic applications
- **Quantum computing**: expert for gate synthesis
- **Machine learning**: expert for neural network experiments

---

## Timeline

| Quarter | Focus | Deliverables |
|---------|-------|-------------|
| Q1 2026 | Foundations | p±1 formal proof, Machin optimality, integer classification |
| Q2 2026 | Analysis | Equidistribution, derivative chain rule, Lipschitz bounds |
| Q3 2026 | Applications | Neural network benchmarks, CORDIC replacement, quantum gates |
| Q4 2026 | Extensions | Quaternionic SPB, tropical structure, continued fractions |
| 2027 H1 | Deep theory | Transport PDE, p-adic SPB, elliptic SPB |
| 2027 H2 | Synthesis | SPB-EML universality, symmetric space generalization |

---

*This roadmap accompanies the machine-verified Lean 4 formalization and should be updated as results are obtained.*
