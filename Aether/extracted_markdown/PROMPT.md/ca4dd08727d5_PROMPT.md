

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## YOUR ASSIGNMENT: Tropical Shannon Theory — Max-Plus Entropy, Data Processing Inequality, and Idempotent Channel Capacity

**DOMAIN**: Tropical  
**MODE**: prove

---

### I. THE VISION

Classical Shannon theory measures *average* information; tropical (max-plus) information theory measures *worst-case* information. This is not a mere analogy — it is a categorical dual. Where Shannon entropy is an integral (sum over probabilities), tropical Shannon entropy is a supremum (max over probabilities). Where the Shannon data processing inequality bounds *expected* information loss, the tropical DPI bounds *maximum* information loss — which is exactly what certified robustness demands. By proving the tropical DPI, chain rule, and source coding theorem, we establish that max-plus information theory is the correct mathematical framework for worst-case analysis in ML verification, post-quantum security bounds, and zero-temperature thermodynamic limits of proof systems.

The Bridge Theorem — connecting tropical Shannon entropy to the free-energy gap from the catalog's thermodynamic proof semantics — establishes that **derivability entropy IS tropical Shannon entropy**, opening a new field: idempotent information theory.

---

### II. FOUNDATIONAL DEFINITIONS (5+ Required)

Define these in a file `TropicalInformationTheory.lean`:

```lean
/-- The max-plus (tropical) Shannon entropy: H_⊕(X) = -log(min_x p(x)).
    This is the Rényi entropy of order ∞, measuring worst-case surprise.
    Bridge: connects tropical algebra to information theory. -/
def tropicalShannonEntropy {α : Type*} [Fintype α] [LinearOrder α]
    (p : α → ℝ) (hp : IsProbabilityDistribution p) : ℝ :=
  -Real.log (Finset.min' (Finset.image p Finset.univ) (Finset.image_nonempty p))

/-- Tropical conditional entropy: H_⊕(Y|X) = max_x H_⊕(Y|X=x).
    The worst-case conditional uncertainty after observing X. -/
def tropicalConditionalEntropy {α β : Type*} [Fintype α] [Fintype β]
    [LinearOrder α] [LinearOrder β]
    (pXY : α × β → ℝ) (hp : IsProbabilityDistribution pXY) : ℝ :=
  Finset.sup' Finset.univ (Finset.univ.nonempty)
    (fun x => tropicalShannonEntropy (fun y => pXY (x, y) / marginalX pXY hp x) sorry)

/-- Tropical KL divergence: D_⊕(P‖Q) = max_x{log(p(x)/q(x))}.
    This is the max-plus analogue of KL divergence, always nonneg.
    Bridge: connects large deviation theory to tropical geometry. -/
def tropicalKLDivergence {α : Type*} [Fintype α] [LinearOrder α]
    (p q : α → ℝ) (hp : IsProbabilityDistribution p)
    (hq : IsProbabilityDistribution q) (hpos : ∀ x, 0 < q x) : ℝ :=
  Finset.sup' Finset.univ Finset.univ.nonempty
    (fun x => Real.log (p x / q x))

/-- Tropical mutual information: I_⊕(X;Y) = D_⊕(p_{XY} ‖ p_X ⊗ p_Y).
    Measures worst-case dependence between X and Y.
    Bridge: connects tropical information to post-quantum security. -/
def tropicalMutualInformation {α β : Type*} [Fintype α] [Fintype β]
    [LinearOrder α] [LinearOrder β]
    (pXY : α × β → ℝ) (hp : IsProbabilityDistribution pXY) : ℝ :=
  tropicalKLDivergence pXY (fun (x, y) => marginalX pXY hp x * marginalY pXY hp y) sorry sorry sorry

/-- A max-plus information channel: stochastic map in the tropical semiring.
    The channel capacity is the supremum of tropical mutual information. -/
structure MaxPlusChannel (α β : Type*) [Fintype α] [Fintype β] [LinearOrder α] [LinearOrder β] where
  kernel : α → β → ℝ
  kernel_nonneg : ∀ x y, 0 ≤ kernel x y
  kernel_row_stochastic : ∀ x, ∑' y, kernel x y = 1

/-- Tropical channel capacity: C_⊕ = sup_{p(X)} I_⊕(X;Y).
    Bridge: connects tropical information to lattice-based cryptography. -/
def tropicalChannelCapacity {α β : Type*} [Fintype α] [Fintype β]
    [LinearOrder α] [LinearOrder β]
    (ch : MaxPlusChannel α β) : ℝ :=
  sSup {r | ∃ (p : α → ℝ) (hp : IsProbabilityDistribution p),
         r = tropicalMutualInformation (jointDistribution ch p hp) (jointDist_isProb ch p hp)}
```

Also define auxiliary structures:
```lean
/-- Idempotent Markov chain structure for DPI proofs. -/
structure IdempotentMarkovChain (α β γ : Type*) where
  pXY : α × β → ℝ
  pYZ : β × γ → ℝ
  pXYZ : α × β × γ → ℝ
  markov_prop : ∀ x y z, pXYZ (x, y, z) = pXY (x, y) * (pYZ (y, z) / marginalY pXY sorry y)

/-- Joint distribution from a channel and input distribution. -/
def jointDistribution {α β : Type*} [Fintype α] [Fintype β]
    (ch : MaxPlusChannel α β) (p : α → ℝ) (hp : IsProbabilityDistribution p) : α × β → ℝ :=
  fun (x, y) => p x * ch.kernel x y
```

---

### III. CORE THEOREMS (10+ Required, Diverse Tactics, ZERO Sorries)

#### Theorem 1: Tropical Entropy Nonnegativity and Bounds
```lean
/-- Tropical entropy is nonneg and bounded by log |supp(X)|.
    The upper bound is the tropical analogue of Hartley's rule. -/
theorem tropical_entropy_nonneg {α : Type*} [Fintype α] [LinearOrder α]
    (p : α → ℝ) (hp : IsProbabilityDistribution p) :
    0 ≤ tropicalShannonEntropy p hp := by
  -- Use that min_x p(x) ≤ 1 since probabilities sum to 1, so -log(min) ≥ 0

theorem tropical_entropy_card_bound {α : Type*} [Fintype α] [LinearOrder α]
    (p : α → ℝ) (hp : IsProbabilityDistribution p) :
    tropicalShannonEntropy p hp ≤ Real.log (Fintype.card α) := by
  -- min_x p(x) ≥ 1/|α| since sum = 1 and all terms ≥ min, so |α|·min ≤ 1
```

**Proof strategy**: For nonnegativity, use `linarith` with `Real.log_nonpos` and the fact that `min_x p(x) ≤ 1`. For the card bound, use `Finset.sum_le_sum` to show `1 = Σ p(x) ≥ |α| · min_x p(x)`, then `linarith`.

#### Theorem 2: Tropical Chain Rule
```lean
/-- Tropical chain rule: H_⊕(X,Y) = max_x{(-log p(x)) + H_⊕(Y|X=x)}.
    This is NOT H_⊕(X) ⊕ H_⊕(Y|X) — the outer operation is a weighted max.
    Bridge: connects tropical information to thermodynamic additivity. -/
theorem tropical_chain_rule {α β : Type*} [Fintype α] [Fintype β]
    [LinearOrder α] [LinearOrder β]
    (pXY : α × β → ℝ) (hp : IsProbabilityDistribution pXY)
    (hpos : ∀ xy, 0 < pXY xy) :
    tropicalShannonEntropy pXY hp =
      Finset.sup' Finset.univ Finset.univ.nonempty
        (fun x => -Real.log (marginalX pXY hp x) +
                   tropicalShannonEntropy (fun y => pXY (x,y) / marginalX pXY hp x) sorry) := by
  -- Key: unfold H_⊕(X,Y) = -log(min_{x,y} p(x,y)) = -log(min_x{min_y{p(x,y)}})
  -- = max_x{-log(min_y{p(x,y)})} = max_x{-log(p(x) · min_y{p(y|x)})}
  -- = max_x{-log p(x) + (-log min_y{p(y|x)})} = max_x{-log p(x) + H_⊕(Y|X=x)}
```

**Proof strategy**: Unfold the definition of `tropicalShannonEntropy` for the joint. Use `Finset.min'_image` to express `min_{x,y} p(x,y)` as `min_x{min_y{p(x,y)}}`. Factor `min_y{p(x,y)}` as `p(x) · min_y{p(y|x)}` using positivity. Apply `Real.log_mul` and `Finset.sup'_congr`. Key lemma needed: `min_joint_factor` showing `min_y p(x,y) = p(x) · min_y p(y|x)`.

#### Theorem 3: Tropical KL Divergence Nonnegativity
```lean
/-- Tropical KL divergence is nonneg: max_x{log(p(x)/q(x))} ≥ 0.
    Equality iff p = q on the support of q.
    Bridge: connects to large deviation rate functions. -/
theorem tropical_kl_nonneg {α : Type*} [Fintype α] [LinearOrder α]
    (p q : α → ℝ) (hp : IsProbabilityDistribution p)
    (hq : IsProbabilityDistribution q) (hpos : ∀ x, 0 < q x) :
    0 ≤ tropicalKLDivergence p q hp hq hpos := by
  -- Since Σ p(x) = 1 and Σ q(x) = 1, by pigeonhole ∃ x where p(x) ≥ q(x)
  -- so max_x{p(x)/q(x)} ≥ 1, hence max_x{log(p(x)/q(x))} ≥ 0
```

**Proof strategy**: By `by_contra`. Suppose all `log(p(x)/q(x)) < 0`, then `p(x) < q(x)` for all `x`. Sum over all `x`: `1 = Σ p(x) < Σ q(x) = 1`, contradiction. Use `Finset.sum_lt_sum` and `linarith`.

#### Theorem 4: Tropical Data Processing Inequality (MAIN THEOREM)
```lean
/-- Tropical DPI: I_⊕(X;Z) ≤ I_⊕(X;Y) for Markov chain X → Y → Z.
    This is the worst-case information processing inequality, bounding
    maximum information leakage through any post-processing.
    Bridge: connects tropical information to post-quantum_security
    and certified_robustness bounds. -/
theorem tropical_data_processing_inequality {α β γ : Type*}
    [Fintype α] [Fintype β] [Fintype γ]
    [LinearOrder α] [LinearOrder β] [LinearOrder γ]
    (mc : IdempotentMarkovChain α β γ)
    (hp : IsProbabilityDistribution mc.pXYZ)
    (hpos : ∀ xyz, 0 < mc.pXYZ xyz) :
    tropicalMutualInformation (projXZ mc) (projXZ_isProb mc hp) ≤
      tropicalMutualInformation mc.pXY (projXY_isProb mc hp) := by
  -- Strategy A (direct): Show max_{x,z}{log(p(x,z)/(p(x)p(z)))} ≤ max_{x,y}{log(p(x,y)/(p(x)p(y)))}
  -- For any (x,z), pick y* = argmax_y p(y|x,z) = argmax_y p(y|x) (Markov property)
  -- Then p(x,z)/(p(x)p(z)) ≤ max_y{p(x,y)/(p(x)p(y))} by the data processing property
  --
  -- Strategy B (via tropical KL monotonicity): Prove D_⊕(p_{XZ} ‖ p_X ⊗ p_Z) ≤ D_⊕(p_{XY} ‖ p_X ⊗ p_Y)
  -- using the Markov property to factor p_{XZ} through p_{XY}
  --
  -- Strategy C (thermodynamic): Use the Bridge theorem to convert to free-energy language,
  -- where DPI becomes a statement about zero-temperature monotonicity of free energy gaps.
  -- Strategy A is most direct and most promising.
```

**Proof strategy (detailed)**:
1. **Lemma `markov_factorization`**: For Markov chain X→Y→Z, `p(x,y,z) = p(x)·p(y|x)·p(z|y)`. Prove by unfolding `IdempotentMarkovChain.markov_prop` and `rcases` on the product structure.
2. **Lemma `marginal_XZ_factorizes`**: `p(x,z) = Σ_y p(x)·p(y|x)·p(z|y)`. Use `markov_factorization` and `Finset.sum_congr`.
3. **Lemma `kl_ratio_channel_bound`**: For any fixed `(x₀, z₀)`, `p(x₀, z₀)/(p(x₀)·p(z₀)) ≤ max_y{p(x₀, y)/(p(x₀)·p(y))}`. This follows because `p(x₀, z₀) = Σ_y p(x₀)·p(y|x₀)·p(z₀|y)`, and by convexity of max, this is ≤ `max_y{p(x₀)·p(y|x₀)}·Σ_y p(z₀|y)` which simplifies. Key step: use `Finset.sup'_le_iff` to bound each term.
4. **Main proof**: Apply `kl_ratio_channel_bound` to each `(x,z)`, then `Finset.sup'_le_iff` to conclude `tropicalKLDivergence p_{XZ} (p_X ⊗ p_Z) ≤ tropicalKLDivergence p_{XY} (p_X ⊗ p_Y)`.

#### Theorem 5: Tropical Mutual Information Nonnegativity
```lean
/-- Tropical mutual information is nonneg: I_⊕(X;Y) ≥ 0.
    Equality iff X and Y are independent (worst-case independence).
    Bridge: connects to lattice_theoretic independence. -/
theorem tropical_mutual_info_nonneg {α β : Type*} [Fintype α] [Fintype β]
    [LinearOrder α] [LinearOrder β]
    (pXY : α × β → ℝ) (hp : IsProbabilityDistribution pXY)
    (hpos : ∀ xy, 0 < pXY xy) :
    0 ≤ tropicalMutualInformation pXY hp := by
  -- I_⊕(X;Y) = D_⊕(p_{XY} ‖ p_X ⊗ p_Y) ≥ 0 by tropical_kl_nonneg
```

#### Theorem 6: Tropical Source Coding Theorem
```lean
/-- Tropical source coding: the optimal worst-case compression rate for
    lossless coding of X equals H_⊕(X) = -log(min_x p(x)).
    Any prefix code has max codeword length ≥ H_⊕(X), and the bound is tight.
    Bridge: connects tropical information to certified_robustness (worst-case
    description length bounds adversarial perturbation cost). -/
theorem tropical_source_coding_lower {α : Type*} [Fintype α] [LinearOrder α]
    (p : α → ℝ) (hp : IsProbabilityDistribution p) (hpos : ∀ x, 0 < p x)
    (code : α → List Bool) (hprefix : IsPrefixCode code) :
    Finset.sup' (Finset.image (fun x => (code x).length) Finset.univ)
      Finset.univ.nonempty id ≥
      Real.log 2⁻¹ * tropicalShannonEntropy p hp := by
  -- Kraft's inequality for prefix codes: Σ 2^{-len(x)} ≤ 1
  -- So min_x{2^{-len(x)}} ≤ (1/|α|) ... but we need: max len ≥ H_⊕/log 2
  -- Since min_x p(x) ≤ 1 and Σ 2^{-len} ≤ 1, by optimality: max len ≥ -log_2(min p)
```

**Proof strategy**: Use Kraft's inequality (`Finset.sum_le_one_of_prefix_code`). Since `Σ 2^{-len(x)} ≤ 1` and `min_x p(x) ≤ 1`, show that `2^{-max len} ≤ Σ 2^{-len(x)} ≤ 1`, hence `max len ≥ 0 ≥ H_⊕/log 2` when `H_⊕ ≥ 0`. For the tight bound, use the specific construction where `len(x) = ⌈-log₂ p(x)⌉` and show this achieves the bound within 1 bit.

#### Theorem 7: Tropical Channel Capacity Formula
```lean
/-- Tropical channel capacity: C_⊕(W) = max_x max_{y} max_{x'} {log(W(y|x)/W(y|x'))}.
    For a binary symmetric channel with crossover ε, C_⊕ = -log(2ε).
    Bridge: connects to post_quantum_security (capacity bounds key leakage). -/
theorem tropical_capacity_binary_symmetric (ε : ℝ) (hε : 0 < ε) (hε' : ε < 1/2) :
    tropicalChannelCapacity (binarySymmetricChannel ε) = -Real.log (2 * ε) := by
  -- For BSC(ε): W(0|0) = 1-ε, W(1|0) = ε, W(0|1) = ε, W(1|1) = 1-ε
  -- I_⊕ = max_{x,y} log(W(y|x)/(1/2 · W(y|0) + 1/2 · W(y|1)))
  -- Max achieved at diagonal: log((1-ε)/(1/2)) = log(2(1-ε))
  -- But also at off-diagonal: log(ε/(1/2·(1-ε)+1/2·ε)) = log(2ε)
  -- Since ε < 1/2: 2ε < 1 < 2(1-ε), so min ratio is 2ε, giving C_⊕ = -log(2ε)
```

#### Theorem 8: Tropical Entropy Lipschitz Continuity
```lean
/-- Tropical entropy is 1-Lipschitz in the ∞-norm:
    |H_⊕(p) - H_⊕(q)| ≤ ‖p - q‖_∞ / min(min_x p(x), min_x q(x)).
    Bridge: connects tropical information to lipschitz_certified_robustness. -/
theorem tropical_entropy_lipschitz {α : Type*} [Fintype α] [LinearOrder α]
    (p q : α → ℝ) (hp : IsProbabilityDistribution p) (hq : IsProbabilityDistribution q)
    (hpos_p : ∀ x, 0 < p x) (hpos_q : ∀ x, 0 < q x) :
    |tropicalShannonEntropy p hp - tropicalShannonEntropy q hq| ≤
      Finset.sup' Finset.univ Finset.univ.nonempty (fun x => |p x - q x|) /
        min (Finset.min' (Finset.image p Finset.univ) sorry)
            (Finset.min' (Finset.image q Finset.univ) sorry) := by
  -- H_⊕(p) = -log(min_x p(x)), H_⊕(q) = -log(min_x q(x))
  -- |H_⊕(p) - H_⊕(q)| = |log(min_x q(x)) - log(min_x p(x))|
  --   = |log(min_x q(x) / min_x p(x))| ≤ max(|min_x q(x)/min_x p(x) - 1|) · 1/min
  -- Use |log(a/b)| ≤ |a-b|/min(a,b) for a,b > 0
```

#### Theorem 9: Tropical Pinsker Inequality
```lean
/-- Tropical Pinsker: D_⊕(P‖Q) ≥ -log(1 - TV(P,Q)/2).
    Relates max-plus KL to total variation for cryptographic security bounds.
    Bridge: connects to post_quantum_security (distinguishing advantage bounds). -/
theorem tropical_pinsker {α : Type*} [Fintype α] [LinearOrder α]
    (p q : α → ℝ) (hp : IsProbabilityDistribution p)
    (hq : IsProbabilityDistribution q) (hpos : ∀ x, 0 < q x) :
    tropicalKLDivergence p q hp hq hpos ≥
      -Real.log (1 - totalVariation p q hp hq / 2) := by
  -- TV(P,Q) = (1/2)Σ|p(x) - q(x)| ≤ 1 - min_x q(x)/max_x p(x)
  -- Since D_⊕ = max_x log(p(x)/q(x)) ≥ log(1/(1 - TV/2))
```

#### Theorem 10: BRIDGE THEOREM — Thermodynamic Equivalence
```lean
/-- Bridge Theorem: Tropical Shannon entropy equals the zero-temperature
    free-energy gap for proof semirings. Specifically, for a proof system
    with partition function Z(β) = Σ_{π} exp(-β · cost(π)),
    lim_{β→∞} β⁻¹ log Z(β) = -H_⊕(proof_distribution) + min_cost.
    This establishes that derivability entropy IS tropical Shannon entropy.
    Bridge: connects tropical information theory to thermodynamic proof
    semantics and quantum statistical mechanics. -/
theorem bridge_thermodynamic_tropical_entropy
    {S : Type*} [Semiring S] [LinearOrder S]
    (proofs : Finset S) (cost : S → ℝ) (hcost : ∀ s ∈ proofs, 0 ≤ cost s)
    (β : ℝ) (hβ : 0 < β) :
    let Z := Finset.sum proofs (fun s => Real.exp (-β * cost s))
    let p := fun s => Real.exp (-β * cost s) / Z
    let H_trop := -Real.log (Finset.min' (Finset.image (fun s => Real.exp (-β * cost s) / Z)
      proofs) sorry)
    let E_ground := Finset.min' (Finset.image cost proofs) sorry
    Real.log Z / β = -H_trop + E_ground + (Real.log Z / β - E_ground + H_trop) ∧
    Tendsto (fun β => Real.log (Finset.sum proofs (fun s => Real.exp (-β * cost s))) / β)
      atTop (nhds E_ground) := by
  -- As β → ∞: log Z(β)/β → min cost (Laplace's method for discrete sums)
  -- H_⊕(p_β) = -log(min_x p_β(x)) = -log(exp(-β·min_cost)/Z) = β·min_cost + log Z
  -- So: log Z/β = H_⊕/β + min_cost - β⁻¹·min_cost ... rearranging:
  -- log Z = β · (H_⊕/β) + β · min_cost ... 
  -- Key: as β→∞, H_⊕(p_β) ≈ β · E_ground + log Z, so log Z/β → E_ground
```

**Proof strategy for Bridge Theorem**:
1. **Lemma `partition_function_asymptotic`**: Show `log Z(β)/β → min cost` as `β → ∞` using Laplace's method. Write `Z(β) = exp(-β·min_cost) · (1 + Σ_{cost > min_cost} exp(-β(cost - min_cost)))`. The sum in parentheses → 1 as β → ∞. Use `Tendsto.congr` and `Real.tendsto_exp_atTop_neg`.
2. **Lemma `tropical_entropy_beta_scaling`**: Show `H_⊕(p_β) = β · min_cost + log Z(β)`. Direct computation: `min_x p_β(x) = exp(-β·min_cost)/Z`, so `H_⊕ = β·min_cost + log Z`.
3. **Combine**: `log Z / β = (H_⊕ - β·min_cost)/β + min_cost = H_⊕/β + min_cost - min_cost/β ... ` — wait, let me recompute. From (2): `H_⊕ = β·min_cost + log Z`, so `log Z = H_⊕ - β·min_cost`, so `log Z/β = H_⊕/β - min_cost`. Hmm, this gives `log Z/β → ?` as `β → ∞`. Since `H_⊕ ≈ β·min_cost + log Z`, we get `H_⊕/β → min_cost`. And `log Z/β → min_cost` (from (1)). Consistency check: `H_⊕/β = min_cost + log Z/β`, so `log Z/β → 0` and `H_⊕/β → min_cost`? No — `log Z/β → min_cost` from Laplace, so `H_⊕/β → 2·min_cost`? That can't be right.

Let me recompute. `Z(β) = Σ exp(-β·cost(s))`. As `β → ∞`, `Z(β) ≈ k · exp(-β·E_ground)` where `k = |{s : cost(s) = E_ground}|`. So `log Z(β) ≈ log k - β·E_ground`. So `log Z(β)/β → -E_ground + (log k)/β → -E_ground`. Wait, `log Z(β)/β → -E_ground + 0 = -E_ground`.

And `H_⊕(p_β) = -log(min_x p_β(x))`. `min_x p_β(x) = exp(-β·E_ground)/Z`. So `H_⊕ = β·E_ground + log Z`. So `H_⊕/β = E_ground + log Z/β → E_ground + (-E_ground) = 0`.

Hmm, that gives `H_⊕/β → 0` as `β → ∞`, which makes sense because the distribution concentrates and `min p → 1` (since all mass goes to the ground state).

The Bridge Theorem should state: **`H_⊕(p_β) = β·E_ground + log Z(β)`**, which after rearrangement gives **`log Z(β) = H_⊕(p_β) - β·E_ground`**, and dividing by β: **`log Z(β)/β = H_⊕(p_β)/β - E_ground`**.

The key insight is: **`lim_{β→∞} (H_⊕(p_β) - β·E_ground) = log k`** where `k` is the ground-state degeneracy. This connects tropical entropy (which equals `β·E_ground + log Z`) to the free energy `F(β) = -log Z(β)/β` via `H_⊕ = β·(E_ground - F(β))`.

The actual Bridge Theorem statement should be:

```lean
/-- Bridge Theorem: For a proof system with partition function Z(β),
    the tropical Shannon entropy satisfies:
    H_⊕(p_β) = β · E_ground + log Z(β)
    equivalently: H_⊕(p_β)/β = E_ground + log Z(β)/β
    As β → ∞: H_⊕(p_β) - β · E_ground → log(degeneracy)
    This is the tropical analogue of F = E - TS with S → tropical entropy.
    Bridge: connects tropical information theory to thermodynamic proof semantics. -/
```

#### Theorem 11: Tropical Capacity Subadditivity
```lean
/-- Tropical capacity of product channels is subadditive:
    C_⊕(W₁ ⊗ W₂) ≤ C_⊕(W₁) + C_⊕(W₂).
    Bridge: connects to lattice_cryptography (subadditivity bounds key rate). -/
theorem tropical_capacity_subadditive {α₁ α₂ β₁ β₂ : Type*}
    [Fintype α₁] [Fintype α₂] [Fintype β₁] [Fintype β₂]
    [LinearOrder α₁] [LinearOrder α₂] [LinearOrder β₁] [LinearOrder β₂]
    (ch₁ : MaxPlusChannel α₁ β₁) (ch₂ : MaxPlusChannel α₂ β₂) :
    tropicalChannelCapacity (productChannel ch₁ ch₂) ≤
      tropicalChannelCapacity ch₁ + tropicalChannelCapacity ch₂ := by
  -- Use the fact that I_⊕(X₁X₂; Y₁Y₂) ≤ I_⊕(X₁;Y₁) + I_⊕(X₂;Y₂)
  -- by the tropical chain rule and subadditivity of max
```

#### Theorem 12: Tropical DPI for Post-Quantum Security
```lean
/-- Application: Tropical DPI implies that post-quantum key exchange
    security degrades at most by the tropical mutual information of
    the classical channel. If I_⊕(K; C) < λ, then any quantum adversary
    cannot distinguish better than exp(λ) advantage.
    Bridge: connects tropical information to post_quantum_security. -/
theorem tropical_dpi_post_quantum_bound {α β γ : Type*}
    [Fintype α] [Fintype β] [Fintype γ]
    [LinearOrder α] [LinearOrder β] [LinearOrder γ]
    (mc : IdempotentMarkovChain α β γ)
    (hp : IsProbabilityDistribution mc.pXYZ)
    (hpos : ∀ xyz, 0 < mc.pXYZ xyz)
    (λ : ℝ) (hλ : tropicalMutualInformation mc.pXY (projXY_isProb mc hp) < λ) :
    tropicalMutualInformation (projXZ mc) (projXZ_isProb mc hp) < λ := by
  -- Direct application of tropical_data_processing_inequality
  -- I_⊕(X;Z) ≤ I_⊕(X;Y) < λ
  exact lt_of_le_of_lt tropical_data_processing_inequality hλ
```

---

### IV. PROOF STRATEGY ARCHITECTURE

**Path A (Direct Combinatorial)**: Prove each theorem by direct manipulation of max-plus expressions. Most promising for Theorems 1–5. Key tactics: `Finset.sup'_le_iff`, `Finset.le_sup'`, `linarith`, `field_simp`, `Real.log_mul`, `Real.log_div`.

**Path B (Thermodynamic/Large Deviation)**: Use the Bridge Theorem to translate tropical information quantities into free-energy language, prove the corresponding thermodynamic statements (which are often simpler due to convexity), then translate back. Most promising for Theorems 8–10.

**Path C (Categorical/Semiring-Theoretic)**: Observe that tropical Shannon entropy is a morphism from the category of probability distributions to the tropical semiring. Prove universal properties characterizing it as the unique such morphism. This would be the deepest approach and would yield all theorems as corollaries of the universal property. Most promising for a future extension.

**Recommended order**: A for Theorems 1–7, B for Theorems 8–10, then A for 11–12.

---

### V. SIGNIFICANCE

This work opens the field of **idempotent information theory**, the max-plus dual of Shannon theory. Every result in classical information theory has a tropical analogue, and these analogues are not merely formal — they carry genuine semantic content:

1. **ML certified robustness**: Tropical DPI says that worst-case information can only decrease through processing. This is exactly the statement needed for `lipschitz_certified_robustness` bounds in neural network verification: if `I_⊕(X; f(X)) < ε`, then `I_⊕(X; g(f(X))) < ε` for any post-processing `g`.

2. **Post-quantum cryptography**: Tropical mutual information bounds the maximum key leakage through any channel, providing `post_quantum_security` guarantees that hold even against quantum adversaries (since the bound is worst-case, not average-case).

3. **Thermodynamic proof theory**: The Bridge Theorem establishes that `tropical_shannon_entropy` IS the zero-temperature limit of proof-theoretic free energy, connecting tropical information to the catalog's `thermodynamic_sanov_large_deviation_completeness` and `thermodynamic_dual_semantics`.

4. **Lattice-based cryptography**: The subadditivity of tropical channel capacity provides `lattice_cryptography` bounds on information rates in worst-case settings.

---

### VI. FUTURE_DIRECTIONS.md

You MUST produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete, specific, breakthrough-level next steps:

1. **Tropical Rate-Distortion Theory**: Define tropical rate-distortion function `R_⊕(D) = min_{p(Ẋ|X): E[d(Ẋ,X)]_⊕ ≤ D} I_⊕(X;Ẋ)` where `E[·]_⊕` is max-plus expectation. Prove the tropical rate-distortion theorem characterizing optimal worst-case compression. This connects to `lipschitz_certified_robustness` via distortion-constrained adversarial perturbations.

2. **Tropical Random Coding Existence Bound**: Prove a max-plus analogue of the random coding bound: for any max-plus channel `W` with capacity `C_⊕`, there exist codes of rate `R < C_⊕` with maximum error probability `ε ≤ exp(-n(C_⊕ - R))`. This provides explicit `post_quantum_security` bounds for code-based cryptosystems.

3. **Quantum Tropical Information**: Define tropical quantum entropy `S_⊕(ρ) = -log(λ_min(ρ))` where `λ_min` is the minimum eigenvalue. Prove tropical strong subadditivity `S_⊕(ρ_{ABC}) + S_⊕(ρ_B) ≤ S_⊕(ρ_{AB}) + S_⊕(ρ_{BC})`, connecting to `quantum_thermodynamic` bounds on worst-case entanglement.

4. **Tropical Sanov's Theorem**: Prove that the tropical KL divergence `D_⊕(P‖Q)` is the exact large deviation rate function for the worst-case event: `lim_{n→∞} n⁻¹ log(max_ω P^n(ω)) = D_⊕(P‖Q)` where the max is over type-classes. This extends the catalog's `thermodynamic_sanov_large_deviation_completeness` to the max-plus setting.

5. **Tropical Network Information Theory**: Develop max-plus network coding theorems where the max-flow equals the tropical mutual information capacity. Prove that the tropical cutset bound is tight for max-plus multicast networks, connecting to `tropical_hash_collision` bounds for distributed systems.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of tropical (max-plus) information theory by proving the idempotent analogues of Shannon's foundational theorems. Define tropical Shannon entropy H_⊕(X) = max_x{−log p(x)} over discrete distributions on idempotent semirings, tropical mutual information I_⊕(X;Y) = H_⊕(X) ⊖ H_⊕(X|Y) where ⊖ is the tropical subtraction (bounded difference), and tropical KL divergence D_⊕(P‖Q) = max_x{log(p(x)/q(x))}. Prove: (1) Tropical chain rule: H_⊕(X,Y) = H_⊕(X) ⊕ H_⊕(Y|X) where ⊕ = max. (2) Tropical data processing inequality: I_⊕(X;Z) ≤ I_⊕(X;Y) for Markov chains X→Y→Z. (3) Tropical source coding theorem: the optimal max-plus compression rate for lossless coding equals H_⊕(X). (4) Tropical channel capacity: C_⊕ = sup_{p(X)} I_⊕(X;Y) with explicit computation for max-plus channels defined over sup-semilattices. (5) Bridge theorem: for coherent closure-generated proof semirings S with thermodynamic partition function Z(β), the proof-theoretic channel capacity C_proof equals the free-energy gap lim_{β→∞} β⁻¹ log Z(β), connecting tropical information theory to the catalog's thermodynamic proof semantics and establishing that derivability entropy IS tropical Shannon entropy.

            ### Precise Mathematical Framing
            Classical information theory is built on the probability semiring (ℝ_+, +, ×). Replacing this with the tropical semiring (ℝ ∪ {−∞}, max, +) yields a fundamentally different information theory where entropy becomes H_⊕(X) = max_x{−log p(x)} (the worst-case surprisal rather than the average), mutual information becomes I_⊕(X;Y) = H_⊕(X) − H_⊕(X|Y) (a sup-convolution rather than a sum), and channel capacity becomes a max-plus optimization rather than a convex program. The key technical challenge is proving the tropical data processing inequality without the additive structure that underpins classical DPI. The proof uses the ultrametric triangle inequality on tropical log-probabilities and the idempotent spectral theory established in the catalog's tropical Satake isomorphism. The bridge to thermodynamic proof theory follows from identifying H_⊕ with the min-energy rate function and C_proof with the Legendre dual of the log-partition function, using the catalog's free-energy separation theorems.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `bool_and_as_tropical_max` : theorem bool_and_as_tropical_max :
     (file: Tropical/Core/HashInversion.lean)
  2. `tropical_chain_rule` : theorem tropical_chain_rule (x₁ x₂ : ℝ) (g : ℝ) :
     (file: Tropical/Core/TropicalFrontierResearch.lean)
  3. `partition_function_tropical` : theorem partition_function_tropical (E₁ E₂ : ℝ) :
     (file: Tropical/Core/TropicalInformationRichness.lean)
  4. `logsumexp_le_max_plus_log` : theorem logsumexp_le_max_plus_log (x : Fin n → ℝ) (hn : 0 < n) (T : ℝ) (hT : 0 < T) :
     (file: Tropical/NeuralNetworks/TropicalViTFormalization.lean)
  5. `idempotent_spectral_tropical_bridge` : theorem idempotent_spectral_tropical_bridge {t : ℝ}
     (file: Tropical/SpectralIdempotentBridge.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Berggren Tree Completeness: Unique Descent and Exhaustiveness via Inverse Matrix Well-Founded Induction, Tropical Berggren Faithfulness via Signed Tropicalization: Exact Classical-to-Tropical Correspondence for Pythagorean Dynamics, Max-Plus One-Way Functions and Quantum Resistance from Idempotent Semiring Intractability


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Tropical
Research mode: prove
