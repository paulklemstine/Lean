# Future Directions: Tropical Performance Envelopes

## Overview

The two-sided tropical performance envelope framework established here opens several concrete research directions. Each builds on the certified theorems (affine_envelope_of_step_bounds, envelope_dualization, maxplus_recursion_envelope, etc.) and extends them into new mathematical and applied territory.

---

## Direction 1: Interval Tropical Perron–Frobenius Theorem

### Statement

Given a max-plus matrix A with interval entries A_ij ∈ [a_ij^min, a_ij^max], prove that the max-plus spectral radius λ(A) (the asymptotic growth rate of the iterates A^⊗k ⊗ x) satisfies:

λ(A_min) ≤ λ(A) ≤ λ(A_max),

where A_min and A_max are the matrices with minimum and maximum entries respectively, and the inequality is between their max-plus spectral radii (maximum cycle means on the critical graph).

### Lean Target

```lean
theorem interval_perron_frobenius
    (n : ℕ) [NeZero n]
    (A_min A_max A : Fin n → Fin n → ℝ)
    (hA : ∀ i j, A_min i j ≤ A i j ∧ A i j ≤ A_max i j)
    (x : Fin n → ℝ)
    (iter : ∀ k : ℕ, Fin n → ℝ)
    (hiter0 : iter 0 = x)
    (hiter_step : ∀ k i, iter (k+1) i =
      Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + iter k j)) :
    -- asymptotic growth rate of iter is bounded by spectral radii of A_min, A_max
    sorry
```

### Proof Strategy

1. Prove monotonicity of tropical matrix-vector multiplication: if A ≤ B entrywise, then A ⊗ x ≤ B ⊗ x componentwise.
2. Use this to show that iterates of A are trapped between iterates of A_min and A_max.
3. Apply the scalar affine envelope theorem to each component.
4. Take the limit to get spectral radius bounds.

### Cross-Domain Significance

- **Robust scheduling**: Certify throughput of event graphs with uncertain processing times.
- **Tropical control**: Interval spectral radii determine the range of achievable cycle times.
- **Combinatorial optimization**: Connects to parametric shortest path problems.

---

## Direction 2: Compositional Network Calculus with Tropical Envelopes

### Statement

For a tandem network of m servers, each with its own arrival/service envelope, prove that the end-to-end delay is bounded by the sum of individual delay bounds, and the end-to-end backlog is bounded by the sum of individual backlog bounds.

### Lean Target

```lean
theorem tandem_delay_bound
    (m : ℕ)
    (x : Fin (m + 1) → ℕ → ℝ)  -- cumulative flows between servers
    (rho sigma : Fin m → ℝ)     -- arrival/service rates per server
    (hx : ∀ (i : Fin m) (n : ℕ),
      sigma i ≤ x i.castSucc (n+1) - x i.castSucc n)
    (hy : ∀ (i : Fin m) (n : ℕ),
      x i.succ (n+1) - x i.succ n ≤ rho i) :
    ∀ k : ℕ, x (Fin.last m) k - x 0 k ≤
      (x (Fin.last m) 0 - x 0 0) +
      (k : ℝ) * (∑ i : Fin m, rho i - sigma i) := by
  sorry
```

### Proof Strategy

1. Apply network_calculus_backlog_bound to each server pair.
2. Use telescoping to sum the bounds.
3. The key lemma is that affine bounds compose under concatenation.

### Cross-Domain Significance

- **Internet QoS**: End-to-end delay guarantees for multi-hop networks.
- **Supply chains**: Throughput bounds for multi-stage manufacturing.
- **Distributed systems**: Latency certification for microservice architectures.

---

## Direction 3: Tropical Lyapunov Envelopes for Stability

### Statement

Define a **tropical Lyapunov function** V : ℝ^n → ℝ as a max-plus affine function V(x) = max_i(a_i + x_i). Prove that if V decreases along trajectories of a max-plus linear system, then the system is stable and trajectories converge to a certified envelope.

### Lean Target

```lean
theorem tropical_lyapunov_envelope
    (n : ℕ) [NeZero n]
    (A : Fin n → Fin n → ℝ)
    (a : Fin n → ℝ)
    (V : (Fin n → ℝ) → ℝ)
    (hV : ∀ x, V x = Finset.univ.sup' Finset.univ_nonempty (fun i => a i + x i))
    (decay : ℝ) (hdecay : decay < 0)
    (hlyap : ∀ x, V (fun i =>
      Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)) ≤ V x + decay) :
    ∀ (x0 : Fin n → ℝ) (k : ℕ),
      -- V along trajectory is bounded by V(x0) + k * decay
      sorry := by
  sorry
```

### Proof Strategy

1. The decay condition gives V(x_{k+1}) ≤ V(x_k) + decay (one-step drift bound).
2. Apply step_upper_to_global_upper to V along the trajectory.
3. Since decay < 0, V → −∞, implying stability.

### Cross-Domain Significance

- **Control theory**: Tropical analog of Lyapunov stability theory.
- **Timed automata**: Proves that certain timed systems terminate.
- **Optimization**: Convergence guarantees for tropical fixed-point iterations.

---

## Direction 4: Stochastic Tropical Envelopes

### Statement

Replace deterministic drift bounds with probabilistic ones: E[x(n+1) − x(n) | F_n] ≤ λ_max a.s. Derive envelope bounds that hold with high probability via tropical Azuma-Hoeffding inequalities.

### Lean Target

```lean
-- Conceptual target (requires measure theory infrastructure)
theorem stochastic_envelope
    (Ω : Type*) [MeasurableSpace Ω] (μ : MeasureTheory.Measure Ω)
    (x : ℕ → Ω → ℝ)
    (lam_max : ℝ) (c : ℝ)
    (h_drift : ∀ n, ∀ᵐ ω ∂μ, x (n+1) ω - x n ω ≤ lam_max)
    (h_bounded : ∀ n, ∀ᵐ ω ∂μ, |x (n+1) ω - x n ω - lam_max| ≤ c) :
    ∀ k : ℕ, ∀ ε > 0,
      μ {ω | x k ω > x 0 ω + (k : ℝ) * lam_max + ε * Real.sqrt k} ≤
        Real.exp (-ε^2 / (2 * c^2)) := by
  sorry
```

### Proof Strategy

1. Apply Azuma's inequality to the supermartingale x(k) − k · λ_max.
2. The deterministic envelope is the ε = 0 case.
3. For ε > 0, get exponential concentration around the envelope.

### Cross-Domain Significance

- **Stochastic networks**: Probabilistic QoS guarantees.
- **Queueing theory**: Tail bounds on queue lengths.
- **Machine learning**: Convergence guarantees for tropical optimization.

---

## Direction 5: Tropical Abstract Interpretation for Program Verification

### Statement

Define a **tropical abstract domain** where program states are abstracted as intervals [k · λ_min + v_min, k · λ_max + v_max] parameterized by the loop iteration count k. Prove soundness: if the abstract transformer correctly handles assignment, branching, and looping, then the concrete program trajectory stays within the abstract envelope.

### Lean Target

```lean
-- Abstract state: affine envelope parameters
structure TropicalAbstractState where
  lam_min : ℝ
  lam_max : ℝ
  v_min : ℝ
  v_max : ℝ

-- Soundness of abstract transformer
theorem abstract_interpretation_soundness
    (abs : TropicalAbstractState)
    (x : ℕ → ℝ)
    (h_init : abs.v_min ≤ x 0 ∧ x 0 ≤ abs.v_max)
    (h_step : ∀ n, abs.lam_min ≤ x (n+1) - x n ∧
                    x (n+1) - x n ≤ abs.lam_max) :
    ∀ k : ℕ,
      (k : ℝ) * abs.lam_min + abs.v_min ≤ x k ∧
      x k ≤ (k : ℝ) * abs.lam_max + abs.v_max := by
  sorry
```

### Proof Strategy

1. Apply affine_envelope_of_step_bounds with the abstract parameters.
2. Adjust intercepts using h_init.
3. For composed programs, use compositional envelope combination.

### Cross-Domain Significance

- **Software verification**: Automatically bound loop variables.
- **Compiler optimization**: Certify that optimized code stays within the same envelope.
- **Cyber-physical systems**: Verify timing properties of embedded software.
- **Abstract interpretation theory**: New abstract domain based on tropical algebra.

---

## Priority Ordering

1. **Direction 5** (Abstract interpretation) — Most immediately practical; directly uses the existing theorem cluster.
2. **Direction 2** (Compositional networks) — High applied value; relatively straightforward extension.
3. **Direction 1** (Interval Perron–Frobenius) — Highest mathematical impact; requires tropical spectral theory infrastructure.
4. **Direction 3** (Tropical Lyapunov) — Deep theoretical result; builds on Perron–Frobenius.
5. **Direction 4** (Stochastic envelopes) — Requires significant measure theory; highest long-term potential.

---

## Research Team Structure

- **Formal verification team**: Extend the Lean library with matrix tropical operations, compositional envelope combinators, and abstract domain infrastructure.
- **Tropical algebra team**: Develop the spectral theory needed for Directions 1 and 3; investigate connections to tropical geometry.
- **Applications team**: Implement network calculus tools, scheduling verifiers, and abstract interpreters using the certified theorems.
- **Stochastic team**: Build the probabilistic extension (Direction 4), connecting to Mathlib's measure theory library.

Each direction should produce:
1. A formal Lean proof of the main theorem.
2. Python demonstrations with concrete numerical examples.
3. At least one worked application to a real-world system.
