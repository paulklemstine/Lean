# Future Directions: Yamabe Problem Formalization

## 1. Sobolev Inequality as Yamabe Quotient Lower Bound

The Yamabe constant Y(M,[g]) on a compact manifold is always finite and bounded below, because the Sobolev inequality provides a uniform lower bound for the Yamabe quotient. Concretely, on Fin n, the power mean inequality gives ∑ uᵢ² ≥ n^{1-2/p} · (∑ |uᵢ|^p)^{2/p}, which bounds the Yamabe quotient from below.

**Conjecture**: For the discrete Yamabe functional on Fin n with E(u) = ∑ (u_{i+1} - uᵢ)² + ∑ Sᵢ uᵢ² and V(u) = ∑ |uᵢ|^p, if all Sᵢ ≥ -C, then yamConst ≥ -C · n^{2/p}.

The key insight is that the gradient term (discrete Laplacian) provides the missing coercivity that prevents the Yamabe constant from going to -∞, exactly mirroring the role of the Sobolev inequality in the continuous case.

**Why now?** We already have `PosHomog`, `yamQ`, and `yamConst_le_yamQ`. Adding a discrete gradient functional and proving the discrete Sobolev inequality would give a fully formalized proof that the discrete Yamabe constant is finite — the first machine-verified version of the compact Yamabe finiteness result.

## 2. Aubin's Inequality: Y(M,[g]) ≤ Y(Sⁿ,[g₀])

Aubin proved that the Yamabe constant of any compact manifold is bounded above by the Yamabe constant of the round sphere: Y(M,[g]) ≤ Y(Sⁿ,[g₀]) = n(n-1)·ω_n^{2/n}. When strict inequality holds, the infimum is achieved (by concentration-compactness), solving the Yamabe problem for "most" manifolds.

**Conjecture**: Using the abstract framework, if E₁ and E₂ are energy functionals with E₁(u) ≤ E₂(u) for all u, then yamConst E₁ V p ≤ yamConst E₂ V p.

The key insight is that Aubin's inequality can be decomposed into (a) monotonicity of the infimum under energy domination, and (b) explicit test function construction (bubbles) showing the sphere's Yamabe constant is an upper bound. Part (a) is purely abstract and formalizable now; part (b) requires analysis on spheres.

**Why now?** The monotonicity result follows directly from `yamConst` as an iInf and would be a one-line proof. The test function construction is where the real geometry enters, and formalizing the standard bubble concentrating at a point would be a significant advance toward a full Yamabe proof.

## 3. Concentration-Compactness Alternative for Yamabe Sequences

The Lions concentration-compactness principle is the key analytic tool for the Yamabe problem. For a minimizing sequence of the Yamabe functional, exactly one of three things happens: (i) compactness (the sequence converges), (ii) concentration (mass collapses to a point), or (iii) vanishing (mass escapes to infinity). On compact manifolds, (iii) is ruled out, and (ii) is ruled out when Y(M) < Y(Sⁿ).

**Conjecture**: In the discrete setting (functions on Fin n), every minimizing sequence for yamQ has a convergent subsequence (since Fin n is finite). On ℕ, construct an explicit minimizing sequence exhibiting vanishing.

The key insight is that concentration-compactness is fundamentally about the dichotomy between compact and non-compact domains. The finite case (Fin n) gives compactness for free, while the infinite case (ℕ) exhibits genuine non-compactness phenomena. Formalizing this dichotomy would be the first machine-verified account of why the Yamabe problem is harder on non-compact manifolds.

**Why now?** We have both the finite domain result (`finite_yamabe_bound`) and the abstract Yamabe quotient framework. Constructing an explicit vanishing sequence on ℕ requires only basic sequence analysis, no differential geometry.

## 4. Conformal Laplacian Covariance Formula

Under conformal change g̃ = φ^{4/(n-2)} g, the conformal Laplacian transforms as L_g(φ^{-1} · f) = φ^{-(n+2)/(n-2)} · L_g̃(f). This "conformal covariance" is the algebraic reason the Yamabe quotient is a conformal invariant.

**Conjecture**: Define an abstract "conformal Laplacian" as a linear operator L satisfying L(φ · u) = φ^{-(n+2)/(n-2)} · L̃(u) for conformal factor φ. Prove that the quadratic form ⟨u, Lu⟩ (= conformal energy) transforms correctly under conformal change, recovering `yamQ_scale_inv` as a corollary.

The key insight is that conformal covariance of L can be formulated as a cocycle condition on the pair (L, g) under the conformal group action, unifying the scale invariance of yamQ with the transformation law of the operator. This is a categorification of our `PosHomog` framework.

**Why now?** The `ConfFactor` group structure and `PosHomog` framework are in place. Defining the conformal Laplacian abstractly as a linear map with a specific transformation law would connect the algebraic (group action) and analytic (PDE) aspects of the Yamabe problem in a single formalization.

## 5. Negative Yamabe Constant and Uniqueness

When Y(M,[g]) < 0, the constant scalar curvature metric in the conformal class is unique (up to scaling). This is because the Yamabe equation -aΔu + Su = λu^{p-1} with λ < 0 has at most one positive solution by the maximum principle.

**Conjecture**: In the abstract framework, if yamConst E V p < 0 and E satisfies a "coercivity" condition (E(u) ≥ c·‖u‖² for some norm), then any two critical points u₁, u₂ of yamQ with V(u₁) = V(u₂) = 1 satisfy u₁ = u₂.

The key insight is that uniqueness in the negative case reduces to strict convexity of the energy functional restricted to the constraint V(u) = 1. When λ < 0, the Euler-Lagrange equation becomes E'(u) = λ V'(u) with λ < 0, and the second variation of the Lagrangian is positive definite. This can be formalized abstractly using convexity of the energy.

**Why now?** The Yamabe constant definition and its properties are formalized. Adding convexity assumptions on E and proving uniqueness of minimizers would give the first formalized treatment of the "easy case" of the Yamabe problem (negative Yamabe constant), which is also the most common case in applications to topology (e.g., hyperbolic 3-manifolds).
