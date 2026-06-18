# Future Directions: Compositional Finite Encoding Theory

## 1. N-ary Iterated Product Encoding

**Hypothesis:** The binary product encoding theorem generalizes to arbitrary finite products. Given a family of types `κ i` indexed by a finite type `ι`, each with an injective encoding into `Fin (B^(bits i))`, there exists an injective encoding of the dependent product `(i : ι) → κ i` into `Fin (B^(∑ i, bits i))`.

**Proof Strategy:** Induction on the cardinality of `ι`. The base case is trivial. For the inductive step, decompose the product as `κ i₀ × ((i : ι \ {i₀}) → κ i)` and apply the binary product encoding theorem. The key technical challenge is managing the dependent type bookkeeping in Lean.

**Formal Statement:**
```lean
theorem injective_list_prod_encoding
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (κ : ι → Type*) [∀ i, Fintype (κ i)] [∀ i, DecidableEq (κ i)]
    {B : ℕ} (hB : 1 ≤ B) (bits : ι → ℕ)
    (enc : ∀ i, κ i → Fin (B^(bits i)))
    (henc : ∀ i, Function.Injective (enc i)) :
    ∃ f : ((i : ι) → κ i) → Fin (B^(∑ i, bits i)), Function.Injective f
```

**Cross-domain connections:** This is the finite combinatorial core of multi-party protocol composition, tensor product state encoding in quantum information, and joint hypothesis class encoding in learning theory.

---

## 2. Mixed-Radix Encoding with Variable Bases

**Hypothesis:** The product encoding generalizes beyond uniform bases. Given types encoded into `Fin m` and `Fin n` (not necessarily powers of a common base), there exists an injective encoding of their product into `Fin (m * n)` via the mixed-radix map `(a, b) ↦ a * n + b`.

**Proof Strategy:** This is actually simpler than the power-of-base version since it avoids the `pow_add` rewriting. The `mixed_radix_eq_iff` lemma already handles the core argument. The `fin_prod_injective_to_fin_mul` theorem we proved is the existential version; the explicit constructive version with the mixed-radix formula should be straightforward.

**Formal Statement:**
```lean
def finProdPack (p : Fin m × Fin n) : Fin (m * n) :=
  ⟨p.1.val * n + p.2.val, ...⟩

theorem finProdPack_injective : Function.Injective (@finProdPack m n)
```

**Cross-domain connections:** Mixed-radix number systems, Chinese Remainder Theorem encodings, hash function composition, and database index packing.

---

## 3. Prefix-Free Coding Infrastructure

**Hypothesis:** The fixed-length encoding composition theorem extends to variable-length prefix-free codes. If two types admit prefix-free binary codes, their product admits a prefix-free binary code whose expected length is at most the sum of the individual expected lengths.

**Proof Strategy:** Formalize prefix-free codes as injective maps `α → List Bool` satisfying the prefix-free property. Define concatenation of prefix-free codes. Prove that concatenation preserves the prefix-free property and injectivity. This requires formalizing the prefix relation on lists and proving that concatenation of prefix-free codewords is uniquely decodable.

**Key Definitions Needed:**
```lean
def PrefixFree (f : α → List Bool) : Prop :=
  ∀ a b, a ≠ b → ¬(f a <+: f b)

def concatCode (f : α → List Bool) (g : β → List Bool) : α × β → List Bool :=
  fun (a, b) => f a ++ g b
```

**Cross-domain connections:** Shannon's source coding theorem, Kraft's inequality, Huffman coding optimality, and Kolmogorov complexity foundations.

---

## 4. Encoding-Based Lower Bounds and Tightness

**Hypothesis:** The additive code length bound `k + ℓ` is tight: there exist types for which no encoding into `Fin (2^(k+ℓ-1))` is injective, when both component encodings are surjective (i.e., `|α| = 2^k` and `|β| = 2^ℓ`).

**Proof Strategy:** Take `α = Fin (2^k)` and `β = Fin (2^ℓ)`. Then `|α × β| = 2^k · 2^ℓ = 2^(k+ℓ)`. Any injection into `Fin (2^(k+ℓ-1))` would require `2^(k+ℓ) ≤ 2^(k+ℓ-1)`, a contradiction. This connects the constructive encoding theorem to information-theoretic lower bounds.

**Formal Statement:**
```lean
theorem encoding_length_tight (k ℓ : ℕ) (hk : 0 < k) (hℓ : 0 < ℓ) :
    ¬∃ f : Fin (2^k) × Fin (2^ℓ) → Fin (2^(k + ℓ - 1)), Function.Injective f
```

**Cross-domain connections:** Counting arguments in complexity theory, pigeonhole-based lower bounds, and entropy as a fundamental limit.

---

## 5. Channel Product Encodings and Information Capacity

**Hypothesis:** The product encoding theorem provides the combinatorial foundation for proving that the capacity of a product of discrete memoryless channels equals the sum of individual capacities. Specifically, if channel 1 has input alphabet of size `2^k` and channel 2 has input alphabet of size `2^ℓ`, then the product channel admits `2^(k+ℓ)` distinguishable input states.

**Proof Strategy:** Define a discrete memoryless channel as a stochastic matrix. Define the product channel. Use the product encoding theorem to show that the input space of the product channel can be injectively encoded with additive bit-length. Connect this to mutual information and channel capacity via the data processing inequality (which already has combinatorial shadows in the existing `EntropyBridge.lean` infrastructure).

**Key Intermediate Results:**
- Formalize discrete memoryless channels as finite-type stochastic maps
- Prove that product channels preserve distinguishability of inputs
- Connect encoding length to log-cardinality and hence to capacity

**Cross-domain connections:** Shannon's channel coding theorem, network information theory, quantum channel capacity (via finite-dimensional analogues), and secure communication protocol composition.
