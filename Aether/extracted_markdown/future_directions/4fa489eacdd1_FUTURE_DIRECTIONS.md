# Future Directions: Policy Gradient Formalization

## 1. Natural Policy Gradient and Fisher Information Geometry

The natural policy gradient uses the Fisher information matrix F(θ) to define a
Riemannian metric on the policy parameter space, replacing the Euclidean gradient
∇J with F(θ)⁻¹∇J. The key insight is that the Fisher information matrix of the
softmax policy has a closed-form inverse expressible via the covariance structure
of the score function, enabling an explicit convergence rate of O(1/√T) in the
Fisher-Rao metric rather than the parameter-space metric. Why now? Our softmax
formalization and variance decomposition provide the exact infrastructure needed:
the Fisher matrix is E_π[ψψᵀ] where ψ is the score function, and our
log-derivative trick directly connects ψ to the policy gradient. The conjecture
is that the natural policy gradient converges at rate O(1/T) for softmax policies
with compatible function approximation, strictly faster than vanilla PG's O(1/√T).

## 2. Bellman Contraction Fixed Point Uniqueness and Policy Iteration Convergence

Our Bellman contraction theorem establishes that T is a γ-contraction. The
Banach fixed point theorem then guarantees existence and uniqueness of V*, but we
have not formalized this composition. The key insight is that iterating the
Bellman operator T^k V converges geometrically at rate γ^k · ‖V - V*‖∞, and
this can be extended to show that policy iteration (alternating policy evaluation
and greedy improvement) converges in at most |A|^|S| steps. Why now? Mathlib's
`ContractingWith` and `IsFixedPt` machinery can be applied directly to our
`bellmanOp` once we show the completeness of the value function space (which is
(S → ℝ) with sup norm, a Banach space for finite S). The conjecture is that
policy iteration terminates in at most (1/(1-γ)) · log(1/ε) steps for
ε-approximate optimality.

## 3. Variance Reduction via Optimal Baselines with Function Approximation

Our `variance_shift_invariant` theorem shows that constant baselines preserve
unbiasedness, and `baseline_objective_quadratic` characterizes the optimal
constant baseline. The key insight is that state-dependent baselines b(s) can
reduce variance by an additional factor proportional to the correlation between
the value function and the score function, and the optimal state-dependent
baseline is exactly V^π(s) under the compatible function approximation
conditions. Why now? Our discrete variance framework naturally extends to
conditional variance given state, and the quadratic objective machinery
generalizes to function-valued baselines. The conjecture is that the variance
ratio Var[∇̂J with b*] / Var[∇̂J without baseline] ≤ 1 - ρ² where ρ is the
correlation between Q^π and the score function.

## 4. KL-Divergence Trust Regions and TRPO Convergence

Trust region policy optimization (TRPO) constrains policy updates via
KL(π_old ‖ π_new) ≤ δ. For softmax policies, this KL divergence has an explicit
form: KL = ∑ π_old(a) · (log π_old(a) - log π_new(a)). The key insight is that
the performance improvement lemma ─ J(π_new) - J(π_old) = (1/(1-γ)) ·
E_{s~d^π_new}[A^π_old(s,a)] ─ combined with Pinsker's inequality and our
Bellman contraction, yields a monotonic improvement guarantee when the KL
constraint is sufficiently tight: δ ≤ ε²(1-γ)³/(8γ). Why now? Our softmax
positivity theorems guarantee that KL is well-defined (no log(0) issues), and
the Bellman contraction provides the discount-factor dependence. The conjecture
is that TRPO with softmax policies converges to a local optimum at rate O(1/T)
in terms of the advantage function norm.

## 5. Multi-Agent Policy Gradients and Nash Equilibrium Convergence

In multi-agent settings, each agent i has its own softmax policy π_i(a_i|s;θ_i),
and the joint policy factorizes as π(a|s) = ∏_i π_i(a_i|s;θ_i). The key insight
is that independent policy gradient updates correspond to a potential game when
the reward structure satisfies a congestion condition, and in this case the joint
Bellman operator remains a contraction (with modified discount factor
γ_eff = γ · (1 + (N-1)·ε) for N agents with ε-coupling). Why now? Our finite
MDP framework naturally extends to product state-action spaces via Fintype
instances on product types, and the contraction theorem applies with the modified
discount factor. The conjecture is that independent policy gradient in N-player
potential games converges to an ε-Nash equilibrium in O(N²/ε²) gradient steps,
with the N² dependence being tight.
