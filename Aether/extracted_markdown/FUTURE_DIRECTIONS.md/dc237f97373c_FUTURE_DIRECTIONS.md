# Future Directions

## Synthesis

The formal infrastructure established here — Minkowski sums, support function linearization, Brunn–Minkowski for boxes, and Newton's log-concavity via PF₂ — provides a reusable foundation for five major research directions. Each direction extends the box-based calculus toward general convex bodies, higher-order mixed volumes, information-theoretic analogues, or combinatorial applications. The common thread is the principle that **volume behaves concavely under natural addition operations**, and each direction tests a different facet of this principle.

The PF₂ machinery developed for Newton's inequality is particularly versatile: it applies not only to convex geometry but to any setting where polynomial coefficients arise from products of linear factors with nonneg coefficients — including characteristic polynomials, generating functions in combinatorics, and partition functions in statistical mechanics.

---

## Direction 1: Brunn–Minkowski for General Convex Bodies via Measure Theory

**Conjecture:** For arbitrary nonempty compact convex sets K, L in ℝⁿ (with Lebesgue measure μ),

μ(K ⊕ₘ L)^{1/n} ≥ μ(K)^{1/n} + μ(L)^{1/n}

where K ⊕ₘ L is the Minkowski sum as defined in `Defs.lean`.

**Test:** Formally verify this for:
1. Finite unions of boxes (approximating arbitrary convex bodies)
2. Simplices (via barycentric coordinates)
3. Ellipsoids (via affine transformations of balls)

Each test requires connecting `MeasureTheory.MeasureSpace.volume` to the box volume formula and establishing that the Minkowski sum of measurable sets is measurable.

**Impact:** This would be the first fully machine-verified Brunn–Minkowski inequality for general convex bodies, unlocking all downstream applications (isoperimetry, concentration of measure, optimal transport).

**Catalog References:** `Geometry/ConvexBodies/BrunnMinkowski.lean` (box version as foundation), `Geometry/ConvexBodies/Defs.lean` (Minkowski sum definition).

**Proof Strategy:** Approximate general convex bodies by unions of boxes (outer approximation). Use the box BM inequality at each scale, then pass to the limit using monotone convergence. Alternatively, use the Prékopa–Leindler inequality (a functional form of BM) as the primary tool.

**Domain Bridges:** Geometric measure theory, functional analysis, optimal transport.

**Lineage:** Direct extension of `brunn_minkowski_box`.

**Ambition:** Grand challenge — would require substantial new Mathlib infrastructure.

---

## Direction 2: Formal Steiner Formula and Mixed Volume Definition

**Conjecture:** For a convex body K and the unit ball B in ℝⁿ, the parallel volume vol(K + tB) is a polynomial of degree n in t for t ≥ 0:

vol(K + tB) = ∑_{k=0}^{n} C(n,k) · W_k(K) · t^k

where W_k are the quermassintegrals (intrinsic volumes) of K.

**Test:**
1. Verify the polynomial formula for boxes (where B is the ℓ^∞ ball): vol(K + tB_∞) = ∏_i (s_i + 2t). This is `boxParallelVolume` in `BrunnMinkowski.lean`.
2. Compute W_k explicitly for boxes and verify they match the mixed volume coefficients.
3. Test that the derivative at t=0 gives the surface area (matching `boxPerimProxy`).

**Impact:** Formalizing the Steiner formula would provide the bridge between volume inequalities and curvature measures, opening the path to mean curvature flow and geometric PDE.

**Catalog References:** `Geometry/ConvexBodies/BrunnMinkowski.lean` (boxParallelVolume, boxPerimProxy, boxMixedCoeff).

**Proof Strategy:** For boxes, direct computation. For general convex bodies, use the theory of valuations on convex bodies (Hadwiger's theorem).

**Domain Bridges:** Differential geometry, PDE, geometric measure theory.

**Lineage:** Extends `boxParallelVolume` and `boxMixedCoeff`.

**Ambition:** Solid extension — the box case is computationally tractable, general case requires geometric measure theory.

---

## Direction 3: Entropy Power Inequality via Brunn–Minkowski

**Conjecture:** For independent random vectors X, Y in ℝⁿ with finite differential entropy:

N(X + Y) ≥ N(X) + N(Y)

where N(X) = (2πe)^{-1} · exp(2h(X)/n) is the entropy power and h is differential entropy.

**Test:**
1. Verify computationally for Gaussian distributions (where EPI becomes an equality when X, Y have proportional covariances).
2. Verify for uniform distributions on boxes (where EPI reduces to BM for boxes).
3. Test edge cases: degenerate distributions, distributions with atoms.

The computational test is implemented in `applications.py` (demo_entropy).

**Impact:** A formal proof of the EPI would bridge convex geometry and information theory, with applications to channel capacity bounds, rate-distortion theory, and privacy guarantees.

**Catalog References:** `Geometry/ConvexBodies/BrunnMinkowski.lean` (prod_add_rpow_le), `applications.py` (entropy_power_analogy).

**Proof Strategy:** For the Gaussian case, reduce to BM for ellipsoids (affine transformation of the ball). For the general case, use the Blachman-Stam proof via Fisher information, or the optimal transport proof of Villani.

**Domain Bridges:** Information theory, probability theory, optimal transport.

**Lineage:** Application of `brunn_minkowski_box` to the Gaussian special case.

**Ambition:** Grand challenge — the general EPI requires substantial probability theory infrastructure.

---

## Direction 4: Log-Concavity in Combinatorics via PF₂ Machinery

**Conjecture:** The PF₂ machinery developed in `Newton.lean` can be extended to prove:
1. Log-concavity of the sequence of face numbers of convex polytopes.
2. Mason's conjecture (log-concavity of the number of independent sets of a matroid by size).
3. Ultra-log-concavity of binomial coefficients and their generalizations.

**Test:**
1. Formalize the binomial coefficient sequence C(n,0), C(n,1), ..., C(n,n) and verify it is PF₂ (this is the special case a_i = b_i = 1 for all i in `prodLinCoeff`).
2. Verify computationally that the f-vector of random convex polytopes is log-concave.
3. Test the PF₂ property for characteristic polynomials of graphic matroids.

**Impact:** Connecting the PF₂ framework to combinatorial log-concavity would provide a unified approach to several major conjectures that were recently resolved using algebraic geometry (Adiprasito–Huh–Katz).

**Catalog References:** `Geometry/ConvexBodies/Newton.lean` (IsPF2, isPF2_conv, prodLinCoeff_isPF2).

**Proof Strategy:** Show that generating functions of matroid-like objects can be expressed as products of linear factors (or limits thereof). Apply the PF₂ preservation theorem.

**Domain Bridges:** Combinatorics, algebraic geometry, matroid theory.

**Lineage:** Direct application of `isPF2_conv` to new domains.

**Ambition:** Solid extension for special cases, grand challenge for the full matroid conjecture.

---

## Direction 5: Displacement Convexity and Optimal Transport

**Conjecture:** The Brunn–Minkowski inequality can be reformulated as a displacement convexity statement:

For probability measures μ₀, μ₁ on ℝⁿ with densities f₀, f₁, and the Wasserstein geodesic μ_t between them:

H(μ_t) ≤ (1-t) · H(μ₀) + t · H(μ₁) - (1/2)t(1-t) · W₂(μ₀, μ₁)²/(n-1)

where H is the relative entropy and W₂ is the 2-Wasserstein distance.

**Test:**
1. Verify computationally for discrete approximations to Gaussian distributions.
2. Verify for uniform distributions on boxes (where the Wasserstein geodesic has explicit form).
3. Test the Bakry–Émery criterion for log-concave distributions.

**Impact:** Displacement convexity is the foundation of modern optimal transport theory. Formalizing even special cases would connect to machine learning (Wasserstein GANs), economics (optimal allocation), and PDE (gradient flows).

**Catalog References:** `Geometry/ConvexBodies/BrunnMinkowski.lean` (volume concavity as the geometric origin), `Geometry/ConvexBodies/Defs.lean` (Minkowski sum as the geometric operation underlying displacement interpolation).

**Proof Strategy:** Begin with the one-dimensional case (McCann's displacement convexity theorem). Use the Monge-Ampère equation to connect to the BM inequality. The box case provides explicit computations.

**Domain Bridges:** Optimal transport, PDE, machine learning, economics.

**Lineage:** Conceptual descendant of `brunn_minkowski_box` via the Riemannian generalization.

**Ambition:** Grand challenge — requires Mathlib's probability theory and potentially measure-theoretic optimal transport.
