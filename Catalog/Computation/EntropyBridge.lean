import Mathlib

/-!
# Entropy-Complexity Bridge: From Compression to Information Bounds

This file establishes formal bridges between algorithmic compression/complexity
and entropy-like information bounds on finite types. The central theme is:

> **Compression controls entropy-like support complexity.**
> If a finite family of objects can be injectively encoded into a bounded
> code space, then the family's cardinality (and hence its log-cardinality,
> a uniform entropy surrogate) is bounded by the code space size.

## Main Results

### Finite cardinality bounds from injective encodings
- `card_le_of_injective_to_fin`: Injective map to `Fin N` bounds cardinality by `N`.
- `card_le_two_pow_of_injective_code`: Injective map to `Fin (2^k)` bounds cardinality by `2^k`.
- `card_le_two_pow_of_injective_bitcode`: Injective map to `Fin k → Bool` bounds cardinality by `2^k`.
- `card_range_le_two_pow_of_bitlength_bound`: Range of a map to `Fin (2^k)` has size ≤ `2^k`.

### Entropy bounds
- `EntropyBound`: Predicate `Fintype.card α ≤ 2^k`, the finite uniform entropy inequality.
- `entropyBound_of_injective_code`: Injective code implies entropy bound.
- `uniform_entropy_le_code_length`: Log-cardinality bounded by code length.

### Support monotonicity (data processing)
- `support_entropy_monotone_under_map`: `|range f| ≤ |α|`.
- `card_range_le_card_codomain`: `|range f| ≤ |β|`.
- `support_entropy_comp_monotone`: `|range (g ∘ f)| ≤ |range f|` — deterministic data processing.

### Cross-domain bridge
- `complexity_bound_implies_finite_entropy_bound`: Connects compressor bounds
  to finite cardinality control.

## Mathematical Significance

These theorems form the combinatorial skeleton of the source coding principle
and create a formal route from Kolmogorov-style complexity bounds to
entropy/information inequalities. The composition monotonicity theorem
`support_entropy_comp_monotone` is a combinatorial shadow of the
**data processing inequality**: deterministic post-processing cannot
increase the number of distinguishable outputs.
-/

open Set Function Finset Fintype

/-! ## Section 1: Core Finite Cardinality Bounds -/

/-- An injective map from a finite type to `Fin N` implies the source has
at most `N` elements. This is the fundamental counting principle underlying
all compression-to-entropy arguments. -/
theorem card_le_of_injective_to_fin
    {α : Type*} [Fintype α] [DecidableEq α] {N : ℕ}
    (f : α → Fin N) (hf : Function.Injective f) :
    Fintype.card α ≤ N := by
  calc Fintype.card α ≤ Fintype.card (Fin N) := Fintype.card_le_of_injective f hf
    _ = N := Fintype.card_fin N

/-- An injective encoding into `Fin (2^k)` bounds source cardinality by `2^k`.
This is the exponential form of the entropy bound: if objects can be
described by `k`-bit codes, there are at most `2^k` of them. -/
theorem card_le_two_pow_of_injective_code
    {α : Type*} [Fintype α] [DecidableEq α] {k : ℕ}
    (enc : α → Fin (2^k)) (henc : Function.Injective enc) :
    Fintype.card α ≤ 2^k :=
  card_le_of_injective_to_fin enc henc

/-- The cardinality of the function space `Fin k → Bool` is exactly `2^k`.
This witnesses bitstrings of length `k` as a code space of size `2^k`. -/
theorem fintype_card_fun_bool (k : ℕ) :
    Fintype.card (Fin k → Bool) = 2^k := by
  simp [Fintype.card_fin, Fintype.card_bool]

/-- An injective encoding into explicit bitstrings `Fin k → Bool` bounds
cardinality by `2^k`. This is the most concrete form: each element gets
a unique `k`-bit string, so there can be at most `2^k` elements. -/
theorem card_le_two_pow_of_injective_bitcode
    {α : Type*} [Fintype α] [DecidableEq α] {k : ℕ}
    (f : α → (Fin k → Bool)) (hf : Function.Injective f) :
    Fintype.card α ≤ 2^k := by
  calc Fintype.card α ≤ Fintype.card (Fin k → Bool) := Fintype.card_le_of_injective f hf
    _ = 2^k := fintype_card_fun_bool k

/-- The range of any map into `Fin (2^k)` has at most `2^k` elements.
This does not require injectivity — it bounds the number of distinguishable
outputs of any encoding scheme. -/
theorem card_range_le_two_pow_of_bitlength_bound
    {n k : ℕ} (f : Fin n → Fin (2^k)) :
    Fintype.card (Set.range f) ≤ 2^k := by
  calc Fintype.card (Set.range f) ≤ Fintype.card (Fin (2^k)) := Fintype.card_subtype_le _
    _ = 2^k := Fintype.card_fin _

/-! ## Section 2: Entropy Bound Predicate and Logarithmic Form -/

/-- `EntropyBound α k` asserts that the uniform entropy of the finite type `α`
is at most `k` bits: equivalently, `|α| ≤ 2^k`. This is the finite
combinatorial skeleton of the source coding bound `H(X) ≤ k` for a
uniform source over `α` encoded with `k`-bit codewords. -/
def EntropyBound (α : Type*) [Fintype α] (k : ℕ) : Prop :=
  Fintype.card α ≤ 2^k

/-- An injective encoding into `k`-bit codes implies the entropy bound.
This is the formal finite-uniform entropy inequality: if every element
of `α` receives a unique `k`-bit code, then `H(α) ≤ k`. -/
theorem entropyBound_of_injective_code
    {α : Type*} [Fintype α] [DecidableEq α] {k : ℕ}
    (enc : α → Fin (2^k)) (henc : Function.Injective enc) :
    EntropyBound α k :=
  card_le_two_pow_of_injective_code enc henc

/-
Logarithmic form of the entropy bound: if `α` injects into `Fin (2^k)`,
then `log₂ |α| ≤ k`. Uses `Nat.log` which is the floor of the logarithm.
-/
theorem uniform_entropy_le_code_length
    {α : Type*} [Fintype α] [DecidableEq α] {k : ℕ}
    (enc : α → Fin (2^k)) (henc : Function.Injective enc) :
    Nat.log 2 (Fintype.card α) ≤ k := by
  -- We have card_le_two_pow_of_injective_code which gives Fintype.card α ≤ 2^k.
  -- Taking the base-2 logarithm is monotonic, so log₂ |α| ≤ log₂ 2^k = k.
  have hcard : Fintype.card α ≤ 2 ^ k := by
    apply card_le_two_pow_of_injective_code enc henc
  exact (Nat.log_mono_right hcard).trans (Nat.log_pow (by norm_num : 1 < 2) k).le

/-- For any injective encoding `α → Fin (2^k)`, the
log-cardinality of `α` is bounded by `k`. -/
theorem log_card_range_le_of_embedding_into_bitstrings
    {α : Type*} [Fintype α] [DecidableEq α] {k : ℕ}
    (enc : α → Fin (2^k)) (henc : Function.Injective enc) :
    Nat.log 2 (Fintype.card α) ≤ k :=
  uniform_entropy_le_code_length enc henc

/-! ## Section 3: Support Monotonicity — Data Processing -/

/-- The range of a map has at most as many elements as its domain.
This is a combinatorial form of the principle that deterministic
processing cannot create new distinguishable outputs. -/
theorem support_entropy_monotone_under_map
    {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) :
    Fintype.card (Set.range f) ≤ Fintype.card α :=
  Fintype.card_range_le f

/-- The range of a map has at most as many elements as the codomain.
This is the trivial but useful fact that range ⊆ codomain implies
the cardinality inequality. -/
theorem card_range_le_card_codomain
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) :
    Fintype.card (Set.range f) ≤ Fintype.card β :=
  Fintype.card_subtype_le _

/-
**Combinatorial Data Processing Inequality.**
Composition cannot increase the number of distinguishable outputs:
`|range (g ∘ f)| ≤ |range f|`. This is the finite combinatorial
shadow of the data processing inequality `H(g(X)) ≤ H(X)` for
deterministic channels.
-/
theorem support_entropy_comp_monotone
    {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : β → γ) :
    Fintype.card (Set.range (g ∘ f)) ≤ Fintype.card (Set.range f) := by
  -- By definition of range, we know that every element in the range of `g ∘ f` is of the form `g (f a)` for some `a ∈ α`.
  have h_range : Set.range (g ∘ f) = g '' Set.range f := by
    grind +splitIndPred;
  simp +decide only [h_range, card_ofFinset];
  refine' le_trans ( Finset.card_image_le ) _;
  exact Finset.card_le_card fun x hx => by aesop;

/-! ## Section 4: Compression Lower Bounds -/

/-
If a type has more than `2^k` elements, no injective encoding into
`k`-bit codes exists. This is the compression impossibility theorem:
you cannot losslessly compress a family of size `> 2^k` into `k` bits.
-/
theorem no_injective_code_of_card_gt
    {α : Type*} [Fintype α] [DecidableEq α] {k : ℕ}
    (hcard : 2^k < Fintype.card α) :
    ¬ ∃ f : α → Fin (2^k), Function.Injective f := by
  exact fun ⟨ f, hf ⟩ => not_le_of_gt hcard ( card_le_of_injective_to_fin f hf )

/-! ## Section 5: Subadditivity Under Products -/

/-
Product encoding: if `α` has at most `2^k` elements and `β` has at most
`2^ℓ` elements, then `α × β` has at most `2^(k + ℓ)` elements.
This is entropy subadditivity: `H(X, Y) ≤ H(X) + H(Y)`.
-/
theorem entropyBound_prod_of_entropyBound
    {α β : Type*} [Fintype α] [Fintype β] {k ℓ : ℕ}
    (hα : EntropyBound α k) (hβ : EntropyBound β ℓ) :
    EntropyBound (α × β) (k + ℓ) := by
  unfold EntropyBound at *;
  simpa only [ pow_add, Fintype.card_prod ] using Nat.mul_le_mul hα hβ

/-! ## Section 6: Cross-Domain Bridge to Compression-Complexity -/

namespace EntropyComplexityBridge

/-- An invertible compressor with idempotence, length-bounding, and inverse. -/
structure InvertibleCompressor where
  compress : List Bool → List Bool
  decompress : List Bool → List Bool
  hidem : ∀ s, compress (compress s) = compress s
  hlen : ∀ s, (compress s).length ≤ s.length
  hstrict : ∀ s, compress s ≠ s → (compress s).length < s.length
  hinv : ∀ s, decompress (compress s) = s

/-
**Complexity bound implies finite entropy bound (bridge theorem).**

Given an invertible compressor `C` and a finite family of binary strings,
if every element has compressed length ≤ `k`, then the family has at most
`2^(k+1)` elements (since there are `2^(k+1) - 1` binary strings of
length ≤ `k`).

This is the key bridge: algorithmic complexity upper bounds (via compressors)
imply entropy upper bounds (via cardinality control).
-/
theorem complexity_bound_implies_finite_entropy_bound
    (C : InvertibleCompressor)
    {α : Type*} [Fintype α] [DecidableEq α]
    (embed : α → List Bool)
    (hembed : Function.Injective embed)
    {k : ℕ}
    (hbound : ∀ a : α, (C.compress (embed a)).length ≤ k) :
    Fintype.card α ≤ 2^(k+1) := by
  -- We know that `compress` is injective and its image is contained in the set of lists of length ≤ k.
  have h_image : Finset.card (Finset.image (fun a => C.compress (embed a)) Finset.univ) ≤ 2^(k+1) - 1 := by
    -- The set of lists of length ≤ k is finite and has cardinality 2^(k+1) - 1.
    have h_card : Finset.card (Finset.filter (fun l => l.length ≤ k) (Finset.biUnion (Finset.range (k + 1)) (fun i => Finset.image (fun l : Fin i → Bool => List.ofFn l) (Finset.univ : Finset (Fin i → Bool)))) ) ≤ 2^(k+1) - 1 := by
      refine' le_trans ( Finset.card_filter_le _ _ ) _;
      refine' le_trans ( Finset.card_biUnion_le ) _;
      rw [ Finset.sum_congr rfl fun i hi => Finset.card_image_of_injective _ fun x y hxy => by simpa [ funext_iff ] using hxy ] ; simp +decide [ Nat.geomSum_eq ];
    refine' le_trans ( Finset.card_le_card _ ) h_card;
    simp +decide [ Finset.subset_iff ];
    exact fun a => ⟨ ⟨ _, hbound a, fun i => ( C.compress ( embed a ) |> List.get <| ⟨ i, by linarith [ hbound a, i.2 ] ⟩ ), by simp +decide ⟩, hbound a ⟩;
  rw [ Finset.card_image_of_injective _ fun a b hab => hembed <| by have := C.hinv ( embed a ) ; have := C.hinv ( embed b ) ; aesop ] at h_image ; exact le_trans h_image ( Nat.sub_le _ _ )

/-- **Finite family complexity certificate.**
If a compressor certifies that every element of a finite type has
compressed representation of length ≤ `k`, this yields an entropy
bound on the type. -/
theorem entropyBound_of_compressor
    (C : InvertibleCompressor)
    {α : Type*} [Fintype α] [DecidableEq α]
    (embed : α → List Bool)
    (hembed : Function.Injective embed)
    {k : ℕ}
    (hbound : ∀ a : α, (C.compress (embed a)).length ≤ k) :
    EntropyBound α (k + 1) :=
  complexity_bound_implies_finite_entropy_bound C embed hembed hbound

end EntropyComplexityBridge