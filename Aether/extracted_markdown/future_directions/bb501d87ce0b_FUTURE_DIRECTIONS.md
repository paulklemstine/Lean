# Future Directions: Factored Bellman Residual Tensorization

## 1. Approximate Tensorization for Weakly Coupled MDPs

### Motivation
Real systems are rarely perfectly factored. Robots share corridors, supply chains share warehouses, network links share bandwidth. The current theorem handles exact independence; extending to weak coupling is the most impactful next step.

### Proposed Theorem Statement
```
theorem approxTensorization_weaklyCoupled
    {k : ℕ} (n : Fin k → ℕ) (hn : ∀ i, 0 < n i)
    (T : ((∀ i, Fin (n i)) → ℝ) → (∀ i, Fin (n i)) → ℝ)
    (Ti : ∀ i, (Fin (n i) → ℝ) → (Fin (n i) → ℝ))
    (ε : ℝ) (hε : 0 ≤ ε)
    (Vi : ∀ i, Fin (n i) → ℝ)
    (hApproxSep : ∀ (Wi : ∀ i, Fin (n i) → ℝ),
      finSupNorm (fun s => T (fun s => ∑ i, Wi i (s i)) s -
        (∑ i, Ti i (Wi i) (s i))) ≤ ε) :
    bellmanGap T (fun s => ∑ i, Vi i (s i)) ≤
      ∑ i, bellmanGap (Ti i) (Vi i) + ε
```

### Strategy
- Define coupling strength ε as the sup-norm deviation of T from separability.
- Prove residual tensorizes up to additive ε.
- For iterated sweeps: gap(Sweep^t V₀) ≤ max(ε · C, gap(V₀) - t·β).
- The error floor ε · C represents an irreducible coupling contribution.

### Cross-domain Connection
This mirrors Dobrushin's uniqueness condition in statistical physics. When interactions are weak (Dobrushin coefficient < 1), Gibbs measures concentrate on product-like distributions. The MDP analogue: weak coupling in dynamics implies near-tensorization of the planning problem.

### Impact
Would enable certified planning for 90% of practical multi-agent systems where interactions exist but are bounded.

---

## 2. Factored Policy Iteration with Sweep-Wise Suboptimality Decay

### Motivation
Value iteration is the simplest MDP algorithm but not the most efficient. Policy iteration converges in fewer steps for many problems. A factored policy iteration theory would combine the speed of policy iteration with the scalability of factored methods.

### Proposed Theorem Statement
```
theorem factored_policy_improvement_sweep
    {k : ℕ} {State : Type*} [Fintype State] [Nonempty State]
    (T : (State → ℝ) → (State → ℝ))
    (π : State → Action)
    (T_π : (State → ℝ) → (State → ℝ))  -- policy-specific Bellman
    (Ui : Fin k → (State → ℝ) → (State → ℝ))
    (β : Fin k → ℝ)
    (V : State → ℝ)
    (hImprove : ∀ i W, bellmanGap T (Ui i W) ≤ bellmanGap T W - β i)
    -- Policy improvement preserves factor structure
    (hPolicyFactor : ...) :
    ∃ π', suboptimality_gap π' ≤ suboptimality_gap π - ∑ i, β i
```

### Strategy
- Define suboptimality gap as ‖V_π - V*‖∞.
- Prove factored policy evaluation preserves separability.
- Prove factored policy improvement reduces suboptimality by sum of factor improvements.
- Derive finite-step convergence to optimal policy.

### Impact
Would make factored methods practical for large-scale RL, where policy iteration outperforms value iteration.

---

## 3. Entropy–Bellman Bridge: Tensorization Duality

### Motivation
The structural similarity between Bellman residual tensorization and entropy tensorization is not coincidental. Both express "the difficulty of a product system equals the sum of factor difficulties." Formalizing this connection would unify dynamic programming and information theory.

### Proposed Theorem Statement
```
-- Entropy tensorization (known, needs formalization)
theorem entropy_tensorizes
    {k : ℕ} (μ : ∀ i, ProbMeasure (Fin (n i)))
    (f : (∀ i, Fin (n i)) → ℝ) (hf_sep : ...) :
    Ent_{∏ μᵢ}(f) ≤ ∑ i, Ent_{μᵢ}(fᵢ)

-- Bridge theorem: Bellman residual as information divergence
theorem bellman_residual_as_divergence
    (T V : ...) :
    bellmanGap T V = D_∞(T(V) ‖ V)
    -- where D_∞ is the L∞ divergence

-- Unified tensorization
theorem unified_tensorization
    (gap : ... → ℝ)  -- abstract gap functional
    (hTriangle : ...) (hProduct : ...) :
    gap(product_system) ≤ ∑ i, gap(factor_system i)
```

### Strategy
- Interpret Bellman residuals as L∞ "divergences" between value functions.
- Show that L∞ tensorization (our Theorem 3) is a special case of a general norm tensorization principle.
- Prove that entropy (L1 log), Rényi divergence (Lp), and Bellman residual (L∞) all tensorize under product structure.
- Formalize the categorical structure: product objects, factor morphisms, tensorization as a natural property.

### Impact
Would establish a new mathematical framework connecting information theory, dynamic programming, and statistical physics through a single tensorization principle.

---

## 4. Compositional POMDPs: Belief-State Factorization

### Motivation
Partially Observable MDPs (POMDPs) are more realistic than MDPs — agents rarely have perfect state information. The belief state (a probability distribution over states) lives in a continuous simplex, making POMDPs much harder. For factored POMDPs, the belief state should approximately factorize.

### Proposed Theorem Statement
```
-- Factored belief state: product of factor beliefs
def FactoredBelief (k : ℕ) (n : Fin k → ℕ) :=
  ∀ i, ProbDist (Fin (n i))

-- Belief Bellman operator respects approximate factorization
theorem belief_bellman_approx_separable
    (T_belief : Belief → Belief)
    (ε : ℝ)
    (hWeak : coupling_strength ≤ ε) :
    ∀ b : FactoredBelief,
      d(T_belief(product b), product(T_factor b)) ≤ ε * C

-- Residual tensorization for belief MDPs
theorem belief_residual_tensorizes
    (hApprox : ...) :
    belief_gap(V) ≤ ∑ i, belief_gap_i(Vi) + ε * C
```

### Strategy
- Define factored belief states as products of factor probability distributions.
- Show that belief Bellman updates approximately preserve the product structure.
- Prove belief residual tensorization up to a coupling error.
- Derive convergence bounds for factored POMDP planning.

### Impact
Would enable scalable planning under uncertainty for multi-agent systems — a grand challenge in robotics and autonomous systems.

---

## 5. Mean-Field Limit: Residual Laws as Factor Count Grows

### Motivation
What happens as the number of factors k → ∞? In statistical physics, the mean-field limit describes the behavior of large systems of weakly interacting particles. The MDP analogue would describe the asymptotic behavior of the Bellman residual in large factored systems.

### Proposed Theorem Statement
```
-- Normalized residual converges as k → ∞
theorem mean_field_residual_limit
    (n : ℕ)  -- uniform factor size
    (γ : ℝ) (hγ : 0 ≤ γ ∧ γ < 1)
    (factor_mdp : FactorMDP n γ)  -- i.i.d. factors
    (V₀ : Fin n → ℝ)  -- common initial factor value
    :
    -- The per-factor residual converges to a deterministic limit
    ∀ ε > 0, ∃ K, ∀ k ≥ K,
      |gap_k(V₀) / k - gap_∞| < ε
    -- where gap_∞ = factor_gap(V₀) is the single-factor residual

-- Concentration: gap concentrates around its mean
theorem residual_concentration
    (k : ℕ) (factor_gaps : Fin k → ℝ) :
    -- By law of large numbers for bounded random variables
    |∑ i, factor_gaps i / k - E[factor_gap]| ≤ C / √k
```

### Strategy
- For i.i.d. factors, the sum of factor residuals satisfies a law of large numbers.
- Prove concentration inequalities for the total residual.
- Derive convergence rates for the normalized residual gap/k → E[factor_gap].
- Extend to non-i.i.d. (but exchangeable or mixing) factor distributions.

### Impact
Would provide a foundation for mean-field reinforcement learning — optimal control of large populations of identical agents, relevant to traffic management, epidemic control, and financial markets.

---

## Cross-Cutting Themes

All five directions share common mathematical infrastructure:

1. **Tensorization as a universal principle**: Products decompose. This should be axiomatized and reused across all settings.

2. **Approximate decomposition with error control**: Exact factorization is rare; bounded coupling is common. Error analysis is the key to practical applicability.

3. **Machine verification**: Each direction should produce formally verified theorems, building a library of compositional planning certificates.

4. **Algorithmic realization**: Every theoretical result should come with an implementable algorithm and complexity analysis.

The ultimate goal is a **compositional science of sequential decision-making**: a mathematical framework where complex planning problems are routinely decomposed into tractable pieces, with machine-verified guarantees that the pieces fit together.
