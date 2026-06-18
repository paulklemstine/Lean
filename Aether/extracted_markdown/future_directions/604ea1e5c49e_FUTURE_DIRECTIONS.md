# Future Directions: Spectral Chain Framework — L²(π) Operator Layer

## What was established (this cycle)

The new file `Computation/SpectralChain/L2Operator.lean` lifts the spectral-chain
framework from combinatorial energy/variance algebra into genuine **self-adjoint
operator theory** on the finite weighted Hilbert space `L²(π)`. Building on the
foundations of `Computation/SpectralChain/Core.lean` (`ReversibleChain`, `weight`,
`mean`, `Var`, `DirichletForm`, `SpectralGapCert`, and the cross-domain bridge
`cheeger_easy_inequality`), it introduces the Markov operator action
`(P f)(i) = ∑_j P_ij f_j` and the weighted inner product
`⟨f, g⟩_π = ∑_i π_i f_i g_i`, then proves the four structural identities that connect
them. Every main theorem compiles with `sorry = 0` and uses only the standard axioms.

The proven results are:

- **`mean_applyP`** — the kernel action preserves the stationary mean: `mean(Pf) = mean(f)`.
  This is precisely the statement that `P` is a Markov (stochastic) operator on observables.
- **`innerPi_self_adjoint`** — reversibility is *exactly* the self-adjointness of `P`
  in `L²(π)`: `⟨Pf, g⟩_π = ⟨f, Pg⟩_π`. Detailed balance becomes a symmetry of an operator.
- **`DirichletForm_eq_innerPi_sub`** — the Dirichlet form is the quadratic form of
  `I − P`: `E(f) = ⟨f, f⟩_π − ⟨Pf, f⟩_π = ⟨(I − P)f, f⟩_π`. The geometric energy is now
  an operator-theoretic object.
- **`Var_eq_innerPi_sub_mean_sq`** — variance is the squared `L²(π)` norm minus the
  squared mean: `Var(f) = ⟨f, f⟩_π − mean(f)²`, i.e. the norm on the mean-zero subspace.
- **`applyP_inner_contraction`** — the cornerstone bridge: a Poincaré gap `γ` forces a
  *one-step contraction* on mean-zero observables, `⟨Pf, f⟩_π ≤ (1 − γ) ⟨f, f⟩_π`. This
  turns the abstract `SpectralGapCert` into a quantitative convergence statement.

The strengthening `Var_applyP_contraction_conjecture`
(`Var(Pf) ≤ (1 − γ)² · Var(f)`) is recorded as a `sorry`ed target, consuming exactly
`applyP_inner_contraction` and `innerPi_self_adjoint`.

---

## Direction 1: Full geometric ergodicity `Var(Pᵗ f) ≤ (1 − γ)^{2t} · Var(f)`

The one-step contraction `applyP_inner_contraction` is the algebraic heart of geometric
convergence, but the clean iterated bound requires upgrading the inner-product
contraction to an *operator-norm* contraction on the mean-zero subspace.
**The key insight is** that for a self-adjoint operator the inner-product bound
`⟨Pf, f⟩ ≤ (1 − γ)⟨f, f⟩` is not by itself enough — one also needs the *lower* spectral
bound `⟨Pf, f⟩ ≥ −(1 − γ)⟨f, f⟩` (laziness, or the absolute spectral gap), after which
`‖P|_{mean-zero}‖ ≤ 1 − γ` follows from the spectral theorem and iterates trivially to
`‖Pᵗ f − mean(f)‖_π ≤ (1 − γ)ᵗ ‖f − mean(f)‖_π`, which squares to the variance bound.
**Why now?** `innerPi_self_adjoint` already certifies self-adjointness, and
`Var_eq_innerPi_sub_mean_sq` already identifies the variance with the mean-zero norm;
the only missing ingredient is the finite-dimensional spectral theorem for self-adjoint
operators, which is fully available in current Mathlib once `applyP` is packaged as a
`LinearMap` on the Euclidean space `EuclideanSpace ℝ V` reweighted by `π`.

## Direction 2: The reversible kernel as a genuine `LinearMap` and its spectrum

This cycle treats `applyP` as a plain function `(V → ℝ) → (V → ℝ)`. Promoting it to a
`LinearMap ℝ (V → ℝ) (V → ℝ)` (or to a self-adjoint operator on `PiLp 2`) would expose
the entire eigenvalue calculus. **The key insight is** that, once `innerPi` is registered
as an `InnerProductSpace` structure (the weighting `π_i > 0` makes `innerPi` a genuine
positive-definite inner product by `π_pos`), `innerPi_self_adjoint` is literally the
hypothesis `IsSelfAdjoint` of Mathlib's spectral API, so the chain's spectral gap becomes
`1 − λ₂` where `λ₂` is the second-largest eigenvalue of the operator. **Why now?** All the
positivity facts needed for the inner-product axioms are already proven (`π_pos`,
`π_sum`), and `innerPi_self_adjoint` discharges the single nontrivial hypothesis of the
finite spectral theorem; this turns `SpectralGapCert` from a hand-supplied certificate
into a *theorem* about the actual spectrum.

## Direction 3: Variational (Courant–Fischer) characterisation of the optimal gap

Rather than asserting a gap via a certificate, the optimal Poincaré constant is the
Rayleigh quotient minimum `γ* = inf_{f ⊥ 1} E(f)/Var(f)`. **The key insight is** that the
identities `DirichletForm_eq_innerPi_sub` and `Var_eq_innerPi_sub_mean_sq` rewrite this
ratio purely in inner-product terms, `E(f)/Var(f) = ⟨(I−P)f,f⟩_π / ⟨f,f⟩_π` on the
mean-zero subspace, which is exactly the Rayleigh quotient of `I − P`; its infimum is the
smallest nonzero eigenvalue by Courant–Fischer. **Why now?** The two rewriting lemmas are
already proven and mutually compatible, so the Rayleigh quotient is expressible *today*;
the remaining step is to invoke `inner_le_iff` / the min–max theorem on the finite
self-adjoint operator of Direction 2, yielding an *existence* proof of an optimal
`SpectralGapCert` rather than requiring the user to supply one.

## Direction 4: Tensorisation — the gap of a product chain

A central structural fact is that the spectral gap of a product of reversible chains is
the *minimum* of the factor gaps: `γ(C₁ ⊗ C₂) = min(γ(C₁), γ(C₂))`. **The key insight is**
that the product chain's Dirichlet form splits additively along the two coordinates,
`E_{C₁⊗C₂}(f) = E₁⊗id(f) + id⊗E₂(f)`, and the product inner product factorises, so the
contraction `applyP_inner_contraction` applied coordinatewise immediately yields the lower
bound `min(γ₁, γ₂)` for the product gap. **Why now?** The operator layer makes the tensor
structure expressible: `applyP` on `V₁ × V₂` is the Kronecker action `P₁ ⊗ P₂`, and the
additive splitting of `DirichletForm_eq_innerPi_sub` over a product index is a pure
`Finset.sum_product` rearrangement — no new analysis, only the bookkeeping that the
inner-product formulation finally makes tractable.

## Direction 5: A log-Sobolev layer comparable to the spectral gap

Above the spectral gap sits the log-Sobolev constant `α`, governing hypercontractivity and
the sharper mixing bound `t_mix(ε) ≤ (1/2α)·log log(1/ε)`. **The key insight is** that the
entropy functional `Ent(g) = ∑_i π_i g_i log g_i − (∑ π_i g_i) log(∑ π_i g_i)` plays the
role that `Var` plays for the spectral gap, and that the *same* Dirichlet form
`DirichletForm_eq_innerPi_sub` appears on the right-hand side of the log-Sobolev inequality
`Ent(f²) ≤ (2/α)·E(f)`; linearising the entropy around its mean recovers the variance,
giving the universal ordering `α ≤ γ`. **Why now?** `DirichletForm`, `mean`, and the
inner-product machinery are all in place, and the entropy functional needs only `Real.log`
and `Finset.sum`, both already imported; a `LogSobolevCert` structure mirroring
`SpectralGapCert` would slot directly into the existing comparison apparatus and let the
two mixing regimes be compared as theorems.
