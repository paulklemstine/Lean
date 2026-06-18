# Future Directions: Entropy-Complexity Bridge

## Overview

The theorems established in `Computation/EntropyBridge.lean` create the first formally verified bridge in this codebase from **compression/complexity** to **entropy/information**. The following directions build on this foundation toward a comprehensive formal information theory.

---

## 1. Data Processing Inequality for Finite Uniform Entropy

**Goal:** Formalize a real-valued or `Nat.log`-based version of the data processing inequality:

```
H(range(g ∘ f)) ≤ H(range(f))
```

**Status:** The combinatorial version `support_entropy_comp_monotone` is proved:
`|range(g ∘ f)| ≤ |range(f)|`. The next step is to wrap this in a `Nat.log`-based entropy definition and derive the logarithmic inequality. A real-valued entropy `H(α) := Real.log (Fintype.card α)` would be more expressive and enable connections to Shannon entropy proper.

**Strategy:**
- Define `uniformEntropy (α : Type*) [Fintype α] : ℝ := Real.log (Fintype.card α)`.
- Prove monotonicity: if `|S| ≤ |T|` then `Real.log |S| ≤ Real.log |T|` using `Real.log_le_log`.
- Derive `uniformEntropy (Set.range (g ∘ f)) ≤ uniformEntropy (Set.range f)` from `support_entropy_comp_monotone`.

**Cross-domain connections:** This directly connects to Shannon's data processing inequality and enables formal reasoning about information bottlenecks in deterministic channels.

---

## 2. Subadditivity Under Product Encodings — Strengthened Form

**Goal:** Prove the full subadditivity with explicit injective encodings:

```lean
theorem injective_prod_encoding
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β] {k ℓ : ℕ}
    (fα : α → Fin (2^k)) (fβ : β → Fin (2^ℓ))
    (hα : Function.Injective fα) (hβ : Function.Injective fβ) :
    ∃ f : α × β → Fin (2^(k + ℓ)), Function.Injective f
```

**Status:** `entropyBound_prod_of_entropyBound` proves the cardinality bound. The strengthened form would construct the explicit product encoding and prove its injectivity.

**Strategy:** Define `f (a, b) := ⟨fα(a).val * 2^ℓ + fβ(b).val, ...⟩` and prove injectivity from the injectivity of the components. This requires careful arithmetic with `Fin` values.

**Applications:** Enables formal analysis of joint coding schemes, product source compression, and multi-dimensional data representation.

---

## 3. Compression Lower Bounds from Counting

**Goal:** Formalize the contrapositive of the encoding bound: if `|α| > 2^k`, then no injective `k`-bit encoding exists.

```lean
theorem compression_lower_bound_bitcode
    {α : Type*} [Fintype α] [DecidableEq α] {k : ℕ}
    (hcard : 2^k < Fintype.card α) :
    ¬ ∃ f : α → (Fin k → Bool), Function.Injective f
```

**Status:** `no_injective_code_of_card_gt` proves this for `Fin (2^k)` codomain. The bitstring version `Fin k → Bool` follows from `fintype_card_fun_bool`.

**Strategy:** Derive directly from `no_injective_code_of_card_gt` and the cardinality identity `|Fin k → Bool| = 2^k`.

**Significance:** This is the formal foundation for proving that certain families are inherently incompressible — a cornerstone of complexity lower bounds.

---

## 4. Oracle/Data Bottleneck Theorem

**Goal:** Formalize that deterministic oracle post-processing cannot increase support entropy. If an oracle computes `g : β → γ` and we have a deterministic query strategy `f : α → β`, then the information content of the composed output `g ∘ f` is bounded by that of the query output `f`.

```lean
theorem oracle_bottleneck
    {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq β] [DecidableEq γ]
    (query : α → β) (oracle : β → γ) :
    Fintype.card (Set.range (oracle ∘ query)) ≤ Fintype.card (Set.range query)
```

**Status:** This is exactly `support_entropy_comp_monotone` applied to the oracle setting. The formalization is complete; what remains is to build the interpretive infrastructure connecting it to oracle complexity theory.

**Next steps:**
- Define an `OracleQuery` structure pairing a query strategy with an oracle function.
- Prove that chaining oracles yields monotonically non-increasing support entropy.
- Connect to `not_attractor_and_repulsor` from the existing catalog to show that incompatible structural roles (expansion and contraction of distinguishability) cannot coexist.

---

## 5. Kolmogorov-to-Shannon Bridge via Average Complexity

**Goal:** Use `compressor_gives_complexity_bound` to define a finite family complexity profile and compare its average bound to support entropy.

```lean
theorem avg_complexity_bounds_entropy
    (U : DescriptionMethod) (hU : IsUniversal U)
    {α : Type*} [Fintype α] [DecidableEq α]
    (embed : α → List Bool) (hembed : Function.Injective embed) :
    ∃ c : ℕ, Nat.log 2 (Fintype.card α) ≤
      (∑ a : α, (embed a).length) / Fintype.card α + c
```

**Strategy:**
- Instantiate `compressor_gives_complexity_bound` with the identity compressor to get baseline bounds.
- Use `complexity_bound_implies_finite_entropy_bound` to convert per-element complexity bounds into global cardinality bounds.
- Average over all elements using `Finset.sum_div_pow_mul_pow_le_pow_mul` or similar combinatorial inequalities.

**Significance:** This is the formal analog of the fundamental inequality relating Kolmogorov complexity to Shannon entropy: the average Kolmogorov complexity of elements from a finite set is bounded below by the log-cardinality of the set (up to constants). This connects algorithmic information theory to classical information theory.

---

## Broader Research Program

### Phase 1 (Immediate, building on current results)
- Real-valued entropy definition and basic properties
- Chain rule for finite uniform entropy: `H(α × β) = H(α) + H(β)` (for independent uniform sources)
- Conditional entropy definition: `H(α | β) = H(α × β) - H(β)`

### Phase 2 (Medium-term)
- Formal source coding theorem for finite uniform sources
- Extractability bounds: if `f : α → β` is injective and `|β| ≤ 2^k`, then `α` has at most `2^k` elements with extractable representations
- Pseudorandomness definitions using entropy bounds

### Phase 3 (Long-term)
- Full Shannon entropy formalization with probability distributions
- Mutual information and the general data processing inequality
- Oracle separation arguments using entropy bottlenecks
- Connections to circuit complexity via counting arguments
