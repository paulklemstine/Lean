# Formal Foundations for Orbit Shadowing in Dynamical Systems

## Abstract

We present a formal mathematical foundation for orbit shadowing theory in discrete dynamical systems on metric spaces. Our development centers on three main contributions: (1) the **Contractive Shadowing Lemma** with an explicit geometric-series bound δ/(1−L), establishing that every δ-pseudo-orbit of an L-contraction is shadowed by a true orbit; (2) **Shadowing Uniqueness** for expansive maps, proving that the shadowing orbit is unique within the expansivity radius; and (3) the novel concept of a **Shadowing Certificate**, a computational witness structure that bundles a pseudo-orbit with its verified shadowing orbit. All results are formalized in Lean 4 with machine-checked proofs, providing the first fully verified treatment of orbit shadowing that bridges abstract dynamical systems theory with certified numerical computation.

**Keywords**: Orbit shadowing, pseudo-orbits, contractive maps, expansive maps, shadowing lemma, certified computation, dynamical systems, formal verification.

---

## 1. Introduction

The shadowing lemma, first established by Anosov [1] for hyperbolic diffeomorphisms and generalized by Bowen [2], is a cornerstone of dynamical systems theory. It asserts that approximate orbits (pseudo-orbits) of sufficiently hyperbolic systems are uniformly approximated by genuine orbits. This result has profound implications for numerical dynamics: it guarantees that computer simulations, despite accumulated rounding errors, track genuine trajectories of the system.

Despite its importance, the shadowing lemma has received limited attention in the formal mathematics community. The present work addresses this gap by developing a complete formal framework for orbit shadowing, starting from the contractive case and building toward the general theory.

### 1.1 Contributions

1. **Core Definitions**: We formalize pseudo-orbits, shadowing, the shadowing property, and expansivity as Lean 4 structures over arbitrary pseudo-metric spaces.

2. **Contractive Shadowing Lemma**: We prove that every δ-pseudo-orbit of an L-Lipschitz map with L < 1 is δ/(1−L)-shadowed by the true orbit starting at the pseudo-orbit's initial point. The proof proceeds by induction, using the geometric series bound on accumulated Lipschitz contractions.

3. **Expansive Uniqueness**: We prove that if f is c-expansive and two orbits both ε-shadow the same pseudo-orbit with 2ε ≤ c, they coincide at every time step. The key insight is that the orbit property allows reduction to the base case via functional iteration.

4. **Shadowing Certificates**: We introduce a novel structure that packages a pseudo-orbit, its shadowing orbit, and the proofs of validity into a single composable object.

5. **Supporting Results**: We prove pseudo-orbit perturbation stability, iterated contraction bounds, exponential convergence, and shadowing defect estimates.

## 2. Preliminaries

### 2.1 Pseudo-Orbits

**Definition 2.1** (Pseudo-orbit). Let (X, d) be a pseudo-metric space and f : X → X. A sequence (xₙ)ₙ∈ℕ is a *δ-pseudo-orbit* of f if for all n ∈ ℕ,

d(f(xₙ), xₙ₊₁) ≤ δ.

The parameter δ quantifies the per-step error. In numerical computations, δ bounds the local truncation error at each iteration. A true orbit corresponds to δ = 0.

### 2.2 Shadowing

**Definition 2.2** (Shadowing). A sequence (yₙ)ₙ∈ℕ *ε-shadows* a sequence (xₙ)ₙ∈ℕ under f if:
1. (yₙ) is a true orbit: yₙ₊₁ = f(yₙ) for all n, and
2. d(yₙ, xₙ) ≤ ε for all n.

**Definition 2.3** (Shadowing Property). The map f has the *(δ, ε)-shadowing property* if every δ-pseudo-orbit of f is ε-shadowed by some true orbit.

### 2.3 Expansivity

**Definition 2.4** (Expansive Map). A map f : X → X is *c-expansive* if for all x₁, x₂ ∈ X,

(∀ n ∈ ℕ, d(f^n(x₁), f^n(x₂)) ≤ c) ⟹ x₁ = x₂.

Expansivity captures the idea that f has sensitive dependence on initial conditions with a uniform separation constant.

## 3. The Contractive Shadowing Lemma

### 3.1 True Orbit Construction

Given a pseudo-orbit (xₙ) and a map f, the shadowing candidate is simply the true orbit of f starting at x₀:

y₀ = x₀, yₙ₊₁ = f(yₙ).

### 3.2 Inductive Distance Bound

**Lemma 3.1** (Geometric Accumulation). Let f be L-Lipschitz (L ≥ 0) and (xₙ) a δ-pseudo-orbit with δ ≥ 0. Then for all n ∈ ℕ,

d(yₙ, xₙ) ≤ δ · Σᵢ₌₀ⁿ⁻¹ Lⁱ.

*Proof sketch.* By induction on n. The base case n = 0 gives d(x₀, x₀) = 0 ≤ 0. For the inductive step:

d(yₙ₊₁, xₙ₊₁) = d(f(yₙ), xₙ₊₁)
≤ d(f(yₙ), f(xₙ)) + d(f(xₙ), xₙ₊₁)    [triangle inequality]
≤ L · d(yₙ, xₙ) + δ                       [Lipschitz + pseudo-orbit]
≤ L · δ · Σᵢ₌₀ⁿ⁻¹ Lⁱ + δ                 [induction hypothesis]
= δ · (L · Σᵢ₌₀ⁿ⁻¹ Lⁱ + 1)
= δ · Σᵢ₌₀ⁿ Lⁱ.                            □

### 3.3 Main Theorem

**Theorem 3.2** (Contractive Shadowing Lemma). Let f : X → X be L-Lipschitz with L < 1. Then for every δ-pseudo-orbit (xₙ) with δ ≥ 0, the true orbit starting at x₀ is a δ/(1−L)-shadow.

*Proof.* By Lemma 3.1, d(yₙ, xₙ) ≤ δ · Σᵢ₌₀ⁿ⁻¹ Lⁱ. Since 0 ≤ L < 1, the partial sums are bounded by the infinite geometric series:

Σᵢ₌₀ⁿ⁻¹ Lⁱ ≤ Σᵢ₌₀^∞ Lⁱ = 1/(1−L).

Therefore d(yₙ, xₙ) ≤ δ/(1−L). □

**Corollary 3.3.** Every L-contraction (L < 1) has the (δ, δ/(1−L))-shadowing property.

The bound δ/(1−L) is *optimal*: consider f(x) = Lx on ℝ with constant pseudo-orbit error δ. The shadowing distance converges to exactly δ/(1−L).

## 4. Shadowing Uniqueness

**Theorem 4.1** (Uniqueness for Expansive Maps). Let f be c-expansive. If two orbits (y₁,ₙ) and (y₂,ₙ) both ε-shadow the same pseudo-orbit (xₙ) with 2ε ≤ c, then y₁,ₙ = y₂,ₙ for all n.

*Proof.* First, show y₁,₀ = y₂,₀ by applying expansivity. Since both are orbits, f^n(yᵢ,₀) = yᵢ,ₙ. The triangle inequality gives:

d(f^n(y₁,₀), f^n(y₂,₀)) = d(y₁,ₙ, y₂,ₙ)
≤ d(y₁,ₙ, xₙ) + d(xₙ, y₂,ₙ) ≤ 2ε ≤ c.

By expansivity, y₁,₀ = y₂,₀. The full result follows by induction: yᵢ,ₙ₊₁ = f(yᵢ,ₙ), so equality at step n implies equality at step n+1. □

## 5. Shadowing Certificates

### 5.1 Definition

A **Shadowing Certificate** for a map f : X → X is a tuple (N, x, y, δ, ε, π_x, π_y) where:
- N is the orbit length,
- x : ℕ → X is the pseudo-orbit,
- y : ℕ → X is the shadow orbit,
- δ, ε are the error bounds,
- π_x is a proof that x is a δ-pseudo-orbit,
- π_y is a proof that y ε-shadows x.

### 5.2 Construction

The contractive shadowing lemma provides a canonical construction: given an L-contraction and a δ-pseudo-orbit x, the certificate is (N, x, trueOrbit(f, x₀), δ, δ/(1−L), ·, ·) where the proof components are supplied by the lemma.

### 5.3 Significance

The Shadowing Certificate transforms an existence theorem into a *programming object*. In classical dynamical systems theory, the shadowing lemma merely asserts existence. The certificate makes this constructive, enabling:

1. **Composability**: Certificates for consecutive orbit segments can be joined.
2. **Auditability**: Each certificate carries its own validity proof.
3. **Quantitative bounds**: The radius ε is explicitly computed, not merely existential.

## 6. Supporting Results

### 6.1 Perturbation Stability

**Theorem 6.1.** If x is a δ-pseudo-orbit of a 1-Lipschitz map and x' satisfies d(xₙ, x'ₙ) ≤ r for all n, then x' is a (δ + 2r)-pseudo-orbit.

This establishes that the pseudo-orbit property is stable under bounded perturbations, crucial for applications where the pseudo-orbit itself is subject to measurement or rounding errors.

### 6.2 Iterated Contraction

**Theorem 6.2.** If f is L-Lipschitz, then f^n is Lⁿ-Lipschitz.

**Theorem 6.3** (Exponential Convergence). For L-Lipschitz f: d(f^n(x), f^n(y)) ≤ Lⁿ · d(x, y).

### 6.3 Shadowing Defect

The shadowing defect of a candidate shadow y for pseudo-orbit x over window [0, N] is:

D(y, x, N) = max_{0 ≤ n ≤ N} d(yₙ, xₙ).

We establish that D ≥ 0 and that it bounds each individual distance.

## 7. Algorithms

### 7.1 Pseudo-Orbit Verification

```
Input: Map f, sequence x[0..N], tolerance δ
Output: True if x is a δ-pseudo-orbit

for n = 0 to N-1:
    if dist(f(x[n]), x[n+1]) > δ:
        return False
return True
```

### 7.2 Shadowing Certificate Construction

```
Input: L-contraction f (L < 1), δ-pseudo-orbit x[0..N]
Output: ShadowingCertificate

y[0] = x[0]
for n = 0 to N-1:
    y[n+1] = f(y[n])
ε = δ / (1 - L)
return Certificate(x, y, δ, ε)
```

### 7.3 Shadowing Defect Computation

```
Input: Sequences y[0..N], x[0..N]
Output: max_{n} dist(y[n], x[n])

defect = 0
for n = 0 to N:
    defect = max(defect, dist(y[n], x[n]))
return defect
```

## 8. Discussion

### 8.1 Relation to the Full Anosov–Bowen Lemma

Our contractive shadowing lemma handles the uniformly contractive case. The full Anosov–Bowen lemma applies to *hyperbolic* systems — those with both contracting and expanding directions. The extension requires:

1. Decomposition into stable and unstable manifolds.
2. A fixed-point argument in a function space (typically the Schauder or contraction mapping theorem applied to the space of orbit corrections).
3. Uniform hyperbolicity estimates (cone conditions or Lyapunov exponents).

This extension is a major formalization challenge that we identify as the primary future direction.

### 8.2 Connection to Certified Computation

The Shadowing Certificate concept bridges dynamical systems theory and verified computation. In the catalog of existing formalized results, connections exist to:

- **Error suppression** in toric codes, where small local errors are corrected by global structure.
- **Fixed-point orbit bounds**, where contractive dynamics yields explicit convergence estimates.
- **Energy landscape theory**, where gradient descent on loss surfaces is a contractive dynamical system.

### 8.3 Optimality of Bounds

The bound δ/(1−L) is tight. Consider f(x) = Lx on ℝ with the constant pseudo-orbit xₙ = δ · Σᵢ₌₀ⁿ⁻¹ Lⁱ and constant error δ at each step. The true orbit starting at 0 satisfies yₙ = 0, so d(yₙ, xₙ) = δ · Σᵢ₌₀ⁿ⁻¹ Lⁱ → δ/(1−L) as n → ∞.

## 9. Future Work

1. **Hyperbolic Shadowing**: Extend to Anosov diffeomorphisms on compact manifolds.
2. **Stochastic Shadowing**: Develop shadowing theory for random dynamical systems.
3. **Certificate Composition**: Formalize the composition of shadowing certificates for modular simulation verification.
4. **Quantitative Refinement**: Sharpen bounds using adapted metrics and Lyapunov functions.
5. **Computational Implementation**: Build a certified numerical ODE integrator based on shadowing certificates.

## References

[1] D.V. Anosov, "Geodesic flows on closed Riemannian manifolds with negative curvature," *Trudy Mat. Inst. Steklov*, 90, 1967.

[2] R. Bowen, "ω-limit sets for Axiom A diffeomorphisms," *J. Differential Equations*, 18(2):333–339, 1975.

[3] S.Yu. Pilyugin, *Shadowing in Dynamical Systems*, Lecture Notes in Mathematics 1706, Springer, 1999.

[4] K.J. Palmer, *Shadowing in Dynamical Systems: Theory and Applications*, Kluwer Academic Publishers, 2000.

[5] S.Yu. Pilyugin and S.B. Tikhomirov, "Lipschitz shadowing implies structural stability," *Nonlinearity*, 23(5):1233, 2010.
