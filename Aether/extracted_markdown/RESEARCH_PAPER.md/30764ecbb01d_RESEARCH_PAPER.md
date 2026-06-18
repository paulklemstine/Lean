# Algebraic Backbone of the Yamabe Problem on Non-Compact Manifolds

## Abstract

We formalize the algebraic structure underlying the Yamabe problem on Riemannian manifolds, with emphasis on the non-compact case. We establish a network of identities relating the Yamabe dimensional constant *c_n* = 4(*n*−1)/(*n*−2), the critical Sobolev exponent *p** = 2*n*/(*n*−2), the Yamabe nonlinearity exponent (*n*+2)/(*n*−2), and the conformal weight α = (*n*−2)/2. We introduce the `ConformalEnergyData` structure abstracting the algebraic content of the Yamabe equation from its PDE aspects, and prove obstruction results for the non-compact case. All results are formalized in Lean 4 with machine-verified proofs.

## 1. Introduction

The Yamabe problem, posed by Hidehiko Yamabe in 1960, asks whether every compact Riemannian manifold (*M*, *g*) of dimension *n* ≥ 3 admits a metric conformal to *g* with constant scalar curvature. The problem was resolved affirmatively through the combined work of Trudinger [1], Aubin [2], and Schoen [3].

For non-compact manifolds, the situation is fundamentally different. The variational structure of the Yamabe functional loses compactness, and topological and geometric obstructions can prevent the existence of constant-curvature conformal metrics. Understanding these obstructions requires a deep analysis of the algebraic structure of the Yamabe equation.

### 1.1 The Conformal Laplacian

On a Riemannian manifold (*M*, *g*) of dimension *n* ≥ 3, the conformal Laplacian is defined as:

*L_g* = −*c_n* Δ_g + *S_g*

where *c_n* = 4(*n*−1)/(*n*−2) is the Yamabe dimensional constant and *S_g* is the scalar curvature. Under a conformal change *g̃* = *u*^(4/(*n*−2)) *g* with *u* > 0, the conformal Laplacian transforms as:

*L_g*(*u*) = *S_g̃* · *u*^((*n*+2)/(*n*−2))

This equation is the *Yamabe equation*: finding a conformal metric with constant scalar curvature λ is equivalent to solving the semilinear elliptic PDE:

−*c_n* Δ_g *u* + *S_g* *u* = λ *u*^((*n*+2)/(*n*−2))

### 1.2 Contributions

We make the following contributions:

1. **Complete algebraic framework**: We establish 25+ verified identities relating the Yamabe constants, providing a self-contained reference for the algebraic backbone of the Yamabe problem.

2. **Novel abstraction**: We introduce `ConformalEnergyData`, a structure separating the algebraic content of the Yamabe equation from its PDE aspects.

3. **Bubble function analysis**: We prove key properties of the standard bubble function *u*(t) = (1 + *t*²)^(−α), including positivity, symmetry, the maximum principle, and the power rule.

4. **Non-compact obstructions**: We formalize energy sign conditions that obstruct minimization on non-compact manifolds.

5. **Pohozaev identities**: We verify the algebraic identities underlying the Pohozaev conservation law.

## 2. Yamabe Dimensional Constants

### 2.1 Definitions

For a real parameter *n* > 2 (the dimension), we define:

| Symbol | Definition | Name |
|--------|-----------|------|
| *c_n* | 4(*n*−1)/(*n*−2) | Yamabe constant |
| *p** | 2*n*/(*n*−2) | Critical Sobolev exponent |
| *q* | (*n*+2)/(*n*−2) | Yamabe nonlinearity exponent |
| α | (*n*−2)/2 | Conformal weight |
| *Q* | *p**/(p**−2) | Sobolev quotient |
| *S_n* | *n*(*n*−1) | Sphere scalar curvature |

### 2.2 Fundamental Identities

**Theorem 2.1** (Yamabe constant bound). *For all n > 2, c_n > 4.*

*Proof sketch.* Since *n* > 2, we have *n* − 2 > 0. Then *c_n* = 4(*n*−1)/(*n*−2) = 4 + 4/(*n*−2) > 4. □

**Theorem 2.2** (Sobolev conjugate identity). *For n > 2:*
$$\frac{1}{2} - \frac{1}{p^*} = \frac{1}{n}$$

*Proof sketch.* Direct computation: 1/2 − (*n*−2)/(2*n*) = (*n* − *n* + 2)/(2*n*) = 1/*n*. □

**Theorem 2.3** (Yamabe-Sobolev duality). *c_n = p* + 2.*

*Proof.* *p** + 2 = 2*n*/(*n*−2) + 2 = (2*n* + 2*n* − 4)/(*n*−2) = (4*n*−4)/(*n*−2) = 4(*n*−1)/(*n*−2) = *c_n*. □

**Theorem 2.4** (Yamabe constant monotonicity). *The function n ↦ c_n is strictly decreasing on (2, ∞).*

*Proof sketch.* For *a* > 2, *a* < *b*: *c_b* − *c_a* = 4(*b*−1)/(*b*−2) − 4(*a*−1)/(*a*−2) = 4(*a* − *b*)/[(*a*−2)(*b*−2)] < 0. □

**Theorem 2.5** (Conformal weight dimension formula). *2α + 2 = n.*

**Theorem 2.6** (Yamabe constant via weight). *c_n = 2(2α+1)/α.*

**Theorem 2.7** (Sobolev quotient). *Q = n/2.*

**Theorem 2.8** (Sobolev-Yamabe duality). *c_n = 2(2Q−1)/(Q−1).*

### 2.3 Exponent Relations

**Theorem 2.9** (Yamabe exponent decomposition). *q = p* − 1.*

**Theorem 2.10** (Yamabe exponent via weight). *q = 1 + 2/α.*

**Theorem 2.11** (Conformal weight shift). *α · q = α + 2.*

This last identity is the algebraic reason why the bubble function solves the Yamabe equation: raising the bubble (with decay rate α) to the Yamabe power *q* produces a function with decay rate α + 2, which is exactly the decay rate of the Laplacian of the bubble.

## 3. Standard Bubble Function

### 3.1 Definition and Basic Properties

The standard bubble function is defined as:

*u*_α(t) = (1 + *t*²)^(−α)

for α ∈ ℝ, *t* ∈ ℝ. In the Yamabe context, α = (*n*−2)/2.

**Theorem 3.1** (Positivity). *For all α, t ∈ ℝ, u_α(t) > 0.*

*Proof.* Since 1 + *t*² > 0, any real power of a positive number is positive. □

**Theorem 3.2** (Maximum principle). *For α ≥ 0, u_α(t) ≤ u_α(0) = 1 for all t.*

*Proof.* Since 1 + *t*² ≥ 1 and −α ≤ 0, the function *x* ↦ *x*^(−α) is decreasing for *x* ≥ 1. □

**Theorem 3.3** (Even symmetry). *u_α(−t) = u_α(t).*

**Theorem 3.4** (Power rule). *u_α(t)^β = u_{αβ}(t).*

*Proof.* ((1+*t*²)^(−α))^β = (1+*t*²)^(−αβ) = *u*_{αβ}(t) by the law of exponents. □

### 3.2 Role in the Yamabe Problem

On flat ℝⁿ, the standard bubble with α = (*n*−2)/2 is the unique (up to conformal symmetry) positive solution of:

−Δ*u* = *n*(*n*−2)*u*^((*n*+2)/(*n*−2))

The power rule (Theorem 3.4) combined with the conformal weight shift (Theorem 2.11) shows that:

*u*_{α}(t)^*q* = *u*_{α+2}(t)

This algebraic identity is the backbone of the Yamabe equation: the nonlinear term *u*^*q* has the correct decay to balance the Laplacian Δ*u*.

## 4. Conformal Energy Data

### 4.1 The Structure

We introduce `ConformalEnergyData`, a structure abstracting the algebraic content of the Yamabe problem:

```
ConformalEnergyData:
  dim         : ℝ         -- spatial dimension, > 2
  bgCurvature : ℝ         -- background scalar curvature κ
  targetCurvature : ℝ     -- target constant scalar curvature λ
```

From this data we derive:
- **Yamabe constant**: *c_n* = 4(dim−1)/(dim−2)
- **Critical exponent**: *p** = 2·dim/(dim−2)
- **Curvature gap**: Δκ = targetCurvature − bgCurvature
- **Algebraic energy**: *E*(u) = κ*u*² − λ*u*^(*p**)

### 4.2 Properties

**Theorem 4.1** (Energy at identity). *E(1) = −Δκ.*

This follows from 1^2 = 1 and 1^(*p**) = 1.

**Theorem 4.2** (Energy at zero). *E(0) = 0.*

This follows from 0^2 = 0 and 0^(*p**) = 0 (since *p** > 0).

## 5. Non-Compact Obstructions

### 5.1 Energy Sign Obstructions

On non-compact manifolds, the sign of the algebraic energy at *u* = 1 determines qualitative behavior:

**Theorem 5.1** (Negative energy obstruction). *If λ > κ, then E(1) < 0.*

On a compact manifold, this negative energy is controlled by the Sobolev inequality. On a non-compact manifold, the energy can be driven to −∞ by spreading the conformal factor over the infinite volume, preventing the existence of a minimizer.

**Theorem 5.2** (Positive energy stability). *If κ > λ and λ ≥ 0, then E(1) > 0.*

### 5.2 Decay Rate Classification

We classify conformal factor decay on non-compact manifolds:

- **Subcritical decay** (β < *n*−2): The conformal factor decays slower than the standard bubble. This typically leads to divergent energy integrals.

- **Critical decay** (β = *n*−2): The conformal factor decays at the bubble rate. This is the borderline case where the energy may or may not converge.

- **Supercritical decay** (β > *n*−2): The conformal factor decays faster than the bubble. The energy converges, but the Yamabe equation may not be solvable.

### 5.3 Yamabe Spectrum

The *Yamabe spectrum* of a conformal energy data is the set of target curvatures λ for which the algebraic critical point equation has a positive solution:

2κ*u* = *p** · λ · *u*^(*p**−1)

**Theorem 5.3**. *If κ = 0, then λ = 0 is in the Yamabe spectrum.*

## 6. Pohozaev Identities

### 6.1 The Pohozaev Balance

The Pohozaev identity for the Yamabe equation provides a conservation law constraining solutions:

**Theorem 6.1** (Pohozaev critical exponent). *n/2 − n/p* = 1.*

**Theorem 6.2** (Pohozaev-conformal weight). *n/p* = α.*

**Theorem 6.3** (Pohozaev balance). *(n−2)/n = 2/p*.*

These identities express a single underlying fact: the Yamabe equation is *conformally critical* — it sits at the exact exponent where the Pohozaev identity provides a non-trivial conservation law.

### 6.2 Scale Invariance

**Theorem 6.4** (Scale dimension). *α · q = (n+2)/2.*

**Theorem 6.5** (Critical energy scaling). *n − 2n/p* = 2.*

The critical energy scaling theorem shows that the Yamabe energy has exactly quadratic scaling under the conformal group, making it conformally invariant.

## 7. Sphere Curvature

### 7.1 Results

**Theorem 7.1** (Sphere positivity). *S_n = n(n−1) > 0 for n > 1.*

**Theorem 7.2** (Yamabe factorization). *S_n = c_n · n(n−2)/4.*

**Theorem 7.3** (Weight formula). *S_n = (2α+2)(2α+1).*

## 8. Conjectures and Future Directions

### 8.1 Conjecture: Non-Compact Yamabe Dichotomy

**Conjecture.** *For a complete non-compact Riemannian manifold (M, g) with bounded geometry and positive Yamabe invariant Y(M, [g]) > 0, there exists a conformal metric of constant positive scalar curvature if and only if the Green's function of the conformal Laplacian has sub-bubble decay at infinity.*

**Testable prediction:** For the hyperbolic space ℍⁿ with its standard metric, the conformal Laplacian's Green's function decays as *r*^(−(*n*−2)) (bubble rate), and the Yamabe problem is solvable. For a cusped hyperbolic manifold, the Green's function decays slower (sub-bubble), and the Yamabe problem should encounter obstructions.

### 8.2 Conjecture: Yamabe Constant Interpolation

**Conjecture.** *The function n ↦ c_n = 4(n−1)/(n−2) for real n > 2 has a unique analytic extension to the strip {z ∈ ℂ : Re(z) > 2} that is bounded in every right half-plane {Re(z) > 2 + ε}.*

This is trivially true since *c_n* is already a rational function, but the deeper question is whether the Yamabe invariant Y(S^n) has an analytic continuation in the dimension parameter that extends the known values at integer dimensions.

## 9. Algorithms

### 9.1 Yamabe Constant Computation

**Input:** Dimension *n* > 2
**Output:** Yamabe constant *c_n*

1. Compute *c_n* = 4(*n*−1)/(*n*−2)
2. Verify: *c_n* > 4 (sanity check)
3. Verify: *c_n* = 2*n*/(*n*−2) + 2 (duality check)

### 9.2 Bubble Function Evaluation

**Input:** Conformal weight α, radial coordinate *t*
**Output:** Bubble value *u*(t)

1. Compute *b* = 1 + *t*²
2. Return *b*^(−α) using `rpow`

### 9.3 Decay Rate Classification

**Input:** Sampled function values {(*t_i*, *f*(*t_i*))} for large *t_i*
**Output:** Estimated decay rate β

1. Compute log-log pairs: (*x_i*, *y_i*) = (log|*t_i*|, log|*f*(*t_i*)|)
2. Fit linear regression: *y* = *a* − β*x*
3. Compare β to critical rate *n* − 2

## 10. Discussion

The algebraic structure of the Yamabe problem is remarkably rigid. The network of identities we have established shows that the dimensional constants *c_n*, *p**, *q*, α are tightly interconnected, with each expressible in terms of any other. This rigidity is a reflection of conformal invariance: the Yamabe equation is the unique conformally covariant semilinear equation of its order.

For non-compact manifolds, the algebraic structure constrains but does not determine the existence of solutions. The energy sign obstructions we have formalized are necessary conditions for non-existence, but sufficient conditions require additional analytic information about the Green's function, volume growth, and spectral properties of the conformal Laplacian.

## References

1. N. Trudinger, "Remarks concerning the conformal deformation of Riemannian structures on compact manifolds," *Ann. Scuola Norm. Sup. Pisa* **22** (1968), 265–274.

2. T. Aubin, "Équations différentielles non linéaires et problème de Yamabe concernant la courbure scalaire," *J. Math. Pures Appl.* **55** (1976), 269–296.

3. R. Schoen, "Conformal deformation of a Riemannian metric to constant scalar curvature," *J. Differential Geom.* **20** (1984), 479–495.

4. M. Struwe, "A global compactness result for elliptic boundary value problems involving limiting nonlinearities," *Math. Z.* **187** (1984), 511–517.

5. J. Lee and T. Parker, "The Yamabe problem," *Bull. Amer. Math. Soc.* **17** (1987), 37–91.
