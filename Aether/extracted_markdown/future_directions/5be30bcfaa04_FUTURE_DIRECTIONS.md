# Future Directions: Tropical Spectral Surgery Theory

This document outlines specific next theorems and research programs opened by the tropical spectral surgery invariance theorem. Each direction includes an exact statement, proof strategy, and cross-domain significance.

---

## 1. Tropical Spectral Gap Stability Radius

### Statement

Given $A \in \mathbb{R}^{n \times n}$ with spectral gap $\delta(A) = \lambda(A) - \max_{C \notin \text{Crit}(A)} \mu_A(C)$, define the **stability radius**:

$$r(A) = \sup \{ \varepsilon > 0 : \forall B,\ \|B - A\|_\infty < \varepsilon \text{ and } B|_{\text{Crit}(A)} = A|_{\text{Crit}(A)} \Rightarrow \text{Crit}(B) = \text{Crit}(A) \}$$

**Theorem (conjectured):** $r(A) \geq \delta(A) / n$ where $n$ is the matrix dimension.

### Proof Strategy

1. Use the critical graph surgery invariance theorem as the base case.
2. For any cycle $C$ of length $k \leq n$ using $m$ modified edges, bound the change in cycle mean:
   $$|\mu_B(C) - \mu_A(C)| \leq \frac{m \cdot \varepsilon}{k} \leq \varepsilon$$
3. If $\varepsilon < \delta/n$, then no non-critical cycle can become critical, and no modified cycle can exceed $\lambda(A)$.
4. Apply the surgery theorem.

### Cross-Domain Significance

- **Scheduling:** Provides explicit tolerance bounds for timing variations in manufacturing.
- **Network design:** Quantifies how much link degradation is tolerable before bottleneck shifts.
- **Algorithm design:** Enables incremental eigenvalue maintenance with certified error bounds.

### Lean Target

```
theorem stability_radius_lower_bound
    {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ)
    (δ : ℝ) (hδ : spectral_gap A = δ)
    (hε : ∀ i j, |B i j - A i j| < δ / n)
    (hcrit : ∀ i j, IsCriticalEdge A i j → B i j = A i j) :
    CriticalGraph B = CriticalGraph A
```

---

## 2. Tropical Pseudospectrum Theorem

### Statement

Define the **tropical ε-pseudospectrum** of $A$ as:

$$\Lambda_\varepsilon(A) = \{ \lambda(B) : \|B - A\|_\infty \leq \varepsilon \}$$

**Theorem (conjectured):** $\Lambda_\varepsilon(A) = [\lambda(A) - \varepsilon, \lambda(A) + \varepsilon]$ for all $\varepsilon \geq 0$.

### Proof Strategy

1. **Upper bound:** For any $B$ with $\|B-A\|_\infty \leq \varepsilon$, every cycle mean changes by at most $\varepsilon$, so $|\lambda(B) - \lambda(A)| \leq \varepsilon$.
2. **Attainability:** Construct explicit matrices $B^\pm$ achieving $\lambda(A) \pm \varepsilon$ by modifying weights on a critical cycle.
3. **Connectedness:** Use intermediate value theorem (or direct construction) for intermediate values.

### Cross-Domain Significance

- **Numerical analysis:** Tropical analogue of classical pseudospectra, enabling robust eigenvalue analysis.
- **Control theory:** Characterizes worst-case system behavior under bounded uncertainty.
- **Optimization:** Quantifies sensitivity of objective values to data perturbations.

### Lean Target

```
theorem tropical_pseudospectrum_interval
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) (hε : 0 ≤ ε) :
    ∀ μ, (∃ B, (∀ i j, |B i j - A i j| ≤ ε) ∧ tropEig B = μ)
      ↔ |μ - tropEig A| ≤ ε
```

---

## 3. Mean-Payoff Game Policy Rigidity

### Statement

In a mean-payoff game on a bipartite graph with Max and Min vertices, the **optimal policy** $\sigma^*$ for Max induces a recurrent set $R(\sigma^*)$. The critical graph of the game value matrix encodes $R(\sigma^*)$.

**Theorem (conjectured):** If weights on edges outside $R(\sigma^*)$ are modified without creating any cycle through $R(\sigma^*)^c$ with mean $\geq v^*$ (the game value), then the game value and optimal policy are unchanged.

### Proof Strategy

1. Encode the mean-payoff game as a tropical eigenvalue problem on the game graph.
2. Show that the optimal recurrent set $R(\sigma^*)$ corresponds to the critical graph.
3. Apply the surgery invariance theorem.
4. Translate back: invariance of critical graph implies invariance of optimal policy.

### Cross-Domain Significance

- **AI/RL:** Formal guarantee that optimal policies are robust to suboptimal-region perturbations.
- **Economics:** Game-theoretic stability results for repeated interactions.
- **Verification:** Certified policy invariance for formally verified control systems.

### Lean Target

```
theorem mean_payoff_policy_rigid
    {n : ℕ} [NeZero n]
    (G₁ G₂ : MeanPayoffGame (Fin n))
    (hR : ∀ e ∈ optimalRecurrentSet G₁, G₂.weight e = G₁.weight e)
    (hmod : ∀ C, usesNonRecurrentEdge G₁ C →
      cycleMean G₂ C < gameValue G₁) :
    gameValue G₂ = gameValue G₁ ∧
    optimalPolicy G₂ = optimalPolicy G₁
```

---

## 4. Subeigenvector Certificate Theorem

### Statement

A vector $u \in \mathbb{R}^n$ is a **tropical subeigenvector** at level $\lambda$ if $\max_j (A_{ij} + u_j) \leq \lambda + u_i$ for all $i$. The tropical Collatz-Wielandt theorem states $\lambda(A) = \inf_u \max_i [\max_j(A_{ij} + u_j) - u_i]$.

**Theorem (conjectured):** If $u$ is a tropical subeigenvector of $A$ at level $\lambda(A)$, and $B$ agrees with $A$ on all tight edges of $u$, then $u$ remains a subeigenvector of $B$ at level $\lambda(A)$, and $\lambda(B) \leq \lambda(A)$.

### Proof Strategy

1. Define tropical subeigenvectors and tight edges formally.
2. Show that tightness on an edge $(i,j)$ means $A_{ij} + u_j = \lambda + u_i$.
3. If $B_{ij} = A_{ij}$ on tight edges, the subeigenvector inequality is preserved.
4. By Collatz-Wielandt, $\lambda(B) \leq \lambda(A)$.
5. For the reverse inequality, use a critical cycle argument.

### Cross-Domain Significance

- **Optimization:** Provides dual certificates for tropical eigenvalue problems.
- **Tropical convexity:** Connects surgery invariance to the geometry of tropical polyhedra.
- **Dynamic programming:** Subeigenvectors are value functions; surgery invariance is Bellman invariance.

### Lean Target

```
theorem subeigenvector_surgery
    {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ)
    (u : Fin n → ℝ) (λ : ℝ)
    (hsub : IsSubeigenvector A u λ)
    (htight : ∀ i j, IsTightEdge A u λ i j → B i j = A i j) :
    IsSubeigenvector B u λ
```

---

## 5. Tropical Robustness for Neural Max-Affine Systems

### Statement

A **max-affine system** computes $f(x) = \max_i (w_i \cdot x + b_i)$ at each neuron. The **active region** for input $x$ is the set of indices $i$ achieving the maximum. This is precisely a critical graph in a tropical sense.

**Theorem (conjectured):** If a max-affine network's weights are modified only on inactive neurons (those not achieving the maximum for any input in a given domain), the network output is unchanged on that domain.

### Proof Strategy

1. Model the max-affine network as a tropical matrix-vector multiplication.
2. Identify the active region with the critical graph of the network at each input.
3. Apply surgery invariance pointwise: inactive weight modifications don't change the output.
4. Extend to a domain by uniform continuity / compactness.

### Cross-Domain Significance

- **Machine learning:** Certified adversarial robustness for piecewise-linear networks.
- **Interpretability:** Formal characterization of which neurons matter for which inputs.
- **Pruning:** Provably safe weight removal in regions that don't affect outputs.

### Lean Target

```
theorem max_affine_robustness
    {n m : ℕ}
    (W₁ W₂ : Matrix (Fin m) (Fin n) ℝ)
    (b₁ b₂ : Fin m → ℝ)
    (x : Fin n → ℝ)
    (hactive : ∀ i, ¬IsActive W₁ b₁ x i → W₂ i = W₁ i ∧ b₂ i = b₁ i) :
    maxAffineOutput W₂ b₂ x = maxAffineOutput W₁ b₁ x
```

---

## 6. Tropical Spectral Sheaf Theory

### Statement (Exploratory)

Consider a family of weighted digraphs $\{G_t\}_{t \in T}$ parameterized by a topological space $T$. The tropical eigenvalue $\lambda(G_t)$ and critical graph $\text{Crit}(G_t)$ define a **tropical spectral sheaf** over $T$.

**Conjecture:** The surgery invariance theorem implies local constancy of the tropical spectral sheaf: if the critical graph is constant in a neighborhood of $t_0$, then $\lambda$ and $\text{Crit}$ are constant in that neighborhood.

### Proof Strategy

1. Define tropical spectral data as a presheaf on a graph parameter space.
2. Use surgery invariance as the gluing condition.
3. Prove the sheaf condition: local data determine global spectral invariants.

### Cross-Domain Significance

- **Algebraic geometry:** Tropical spectral sheaves as shadows of non-Archimedean spectral data.
- **Persistent homology:** Spectral invariants as persistent features of graph filtrations.
- **Mathematical physics:** Tropical spectral theory for varying Hamiltonians.

---

## 7. Incremental Algorithms for Dynamic Graphs

### Statement

**Problem:** Given a weighted digraph $G$ with known $\lambda(G)$ and $\text{Crit}(G)$, and a stream of edge weight updates, maintain $\lambda$ and $\text{Crit}$ in amortized $O(1)$ time per update (when updates don't touch critical edges).

### Algorithm Sketch

1. Precompute $\lambda(G)$, $\text{Crit}(G)$, and the spectral gap $\delta(G)$ in $O(n^3)$.
2. For each update $(i, j, w')$:
   - If $(i,j) \in \text{Crit}(G)$: recompute from scratch in $O(n^3)$.
   - If $(i,j) \notin \text{Crit}(G)$ and $|w' - G_{ij}| < \delta/n$: certify invariance in $O(1)$.
   - Otherwise: recompute in $O(n^3)$.
3. By the surgery theorem, the $O(1)$ certification is provably correct.

### Cross-Domain Significance

- **Streaming algorithms:** First provably correct incremental max-cycle-mean algorithm.
- **Real-time systems:** Enables dynamic bottleneck monitoring with formal guarantees.
- **Database optimization:** Certified maintenance of query optimization structures.

---

## Research Team Directive

Each direction above is suitable for a focused research effort of 2–4 weeks. The recommended approach:

1. **Start with Direction 1** (stability radius) — it has the clearest proof path and the most immediate applications.
2. **Pursue Directions 2 and 3 in parallel** — they use different techniques but share the surgery theorem as a foundation.
3. **Direction 4** (subeigenvector certificates) provides the deepest mathematical content and should be pursued by a team member with tropical algebra expertise.
4. **Direction 5** (neural network robustness) is the most applied and should involve collaboration with ML researchers.
5. **Directions 6 and 7** are longer-term programs that build on the earlier results.

Each direction should produce:
- A formal theorem statement and machine-verified proof.
- A Python implementation demonstrating the result computationally.
- A connection to at least one application domain outside pure mathematics.
