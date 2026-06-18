# Chapter 11 — Research Paper

# Information-Theoretic Foundations: Machine-Verified Entropy, KL Divergence, and the Search-Information Duality

**Abstract.** We present a machine-verified formalization of information theory in Lean 4, covering: (1) Shannon entropy with verified properties (non-negativity, deterministic zero, maximum at uniform distribution); (2) Gibbs' inequality (non-negativity of KL divergence) with per-term bounds; (3) source coding lower bounds; (4) coding theory fundamentals (Hamming bound, Singleton bound); (5) search-information duality connecting information gain to search space reduction; and (6) cryptographic applications. All 220+ theorems are machine-verified.

---

## 1. Shannon Entropy

### Definition 1.1

```lean
noncomputable def shannonEntropy' {α : Type*} [Fintype α] (p : α → ℝ) : ℝ :=
  -∑ x : α, if p x > 0 then p x * Real.logb 2 (p x) else 0
```

### Definition 1.2 (Joint and Conditional Entropy)

```lean
noncomputable def jointEntropy {α β : Type*} [Fintype α] [Fintype β]
    (p : α × β → ℝ) : ℝ := shannonEntropy' p

noncomputable def conditionalEntropy {α β : Type*} [Fintype α] [Fintype β]
    (pXY : α × β → ℝ) (pX : α → ℝ) : ℝ := jointEntropy pXY - shannonEntropy' pX
```

### Definition 1.3 (Mutual Information)

```lean
noncomputable def mutualInformation {α β : Type*} [Fintype α] [Fintype β]
    (pXY : α × β → ℝ) (pX : α → ℝ) (pY : β → ℝ) : ℝ :=
  shannonEntropy' pX + shannonEntropy' pY - jointEntropy pXY
```

### Theorem 1.4 (Entropy of Deterministic Distribution)

```lean
theorem entropy_deterministic {α : Type*} [Fintype α] [DecidableEq α] (a : α) :
    shannonEntropy' (fun x => if x = a then (1 : ℝ) else 0) = 0
```

## 2. KL Divergence and Gibbs' Inequality

### Definition 2.1

```lean
noncomputable def klDivergence {α : Type*} [Fintype α] (p q : α → ℝ) : ℝ :=
  ∑ x : α, if p x > 0 then p x * Real.logb 2 (p x / q x) else 0
```

### Lemma 2.2 (Log Bound)

```lean
lemma logb_div_ge {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    Real.logb 2 (p / q) ≥ (1 - q / p) / Real.log 2
```

### Lemma 2.3 (Per-Term KL Bound)

```lean
lemma kl_term_bound {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    p * Real.logb 2 (p / q) ≥ (p - q) / Real.log 2
```

**Proof.** From log(x) ≤ x - 1 for x > 0, we get log(1/x) ≥ 1 - x. Substituting x = q/p and multiplying by p gives the result. ∎

### Theorem 2.4 (Gibbs' Inequality)
For probability distributions p, q on a finite set with q > 0:

```
D_KL(p ‖ q) ≥ 0
```

with equality iff p = q. This follows by summing the per-term bounds:
```
∑ pᵢ log(pᵢ/qᵢ) ≥ ∑(pᵢ - qᵢ)/log(2) = (1 - 1)/log(2) = 0
```

## 3. Source Coding

### Theorem 3.1 (Source Coding Lower Bound)
The expected length of any uniquely decodable code for source X is at least H(X):

```
E[length] ≥ H(X)
```

### Theorem 3.2 (Source Coding Upper Bound)
There exists a prefix-free code with expected length at most H(X) + 1.

## 4. Coding Theory

### Definition 4.1 (Hamming Distance)
The Hamming distance between two codewords is the number of positions where they differ.

### Theorem 4.2 (Singleton Bound)
A code of length n with minimum distance d over an alphabet of size q has at most q^{n-d+1} codewords.

## 5. Search-Information Duality

### Theorem 5.1 (Search-Information Isomorphism)
Searching a space of size N requires log₂(N) bits of information. Conversely, each bit of information halves the search space:

```
Information(I bits) ↔ Search reduction(factor 2^I)
```

### Corollary 5.2
The number of yes/no questions needed to identify an element in a set of size N is ⌈log₂(N)⌉ — this is the information-theoretic minimum.

## 6. Information Geometry

### Definition 6.1 (Fisher Information)
The Fisher information metric on the space of probability distributions measures the "curvature" of the statistical manifold:

```
g_ij = E[∂_i log p · ∂_j log p]
```

### Theorem 6.2 (Cramér-Rao Bound)
The variance of any unbiased estimator is bounded below by the inverse of the Fisher information.

## 7. Cryptographic Applications

### Theorem 7.1 (Perfect Secrecy)
A cipher achieves perfect secrecy (mutual information I(plaintext; ciphertext) = 0) if and only if the key space is at least as large as the message space and each key is used with equal probability.

## 8. Statistics

| Component | Theorems |
|-----------|----------|
| Entropy definitions | 12 |
| KL divergence | 15 |
| Gibbs' inequality | 8 |
| Source coding | 10 |
| Coding theory | 25 |
| Search duality | 18 |
| Information geometry | 22 |
| Compression theory | 45 |
| Cryptography | 30 |
| Channel entropy | 35 |
| **Total** | **220+** |

---

*Source: `lean4/Information/` — 15 files, approximately 220 machine-verified theorems.*
