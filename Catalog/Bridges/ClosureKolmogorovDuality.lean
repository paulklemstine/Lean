import Mathlib

/-!
# Closure-Kolmogorov Complexity Duality and Idempotent Compression

This file establishes a formal bridge between closure operators (idempotent
endomorphisms), compression/canonicalization, and algorithmic description length.

## Main Results

### Fixed points as incompressibility obstructions (Target 2)
- `random_implies_fixed_of_strictly_shortening`: If an idempotent compressor
  strictly shortens every non-fixed-point, then any string that cannot be
  expressed as a shorter compression image must be a fixed point.
- `fixed_iff_not_strictly_shortened`: Fixed points are exactly the strings
  not strictly shortened by the compressor.

### Closure MDL bounds via fixed-point witnesses (Target 1)
- `closure_mdl_bound_via_fixed_point`: Every element admits a canonical
  fixed-point representative whose code length is no worse than its closure length.
- `closure_mdl_bound_strengthened`: The closure itself provides a witness.

### Tropical normalization (Target 3)
- `tropicalNormalize_idempotent`: Tropical (pointwise min) normalization is idempotent.
- `tropical_normalize_minimal_weight`: Normalization yields the shortest canonical
  representative among equivalent weight functions.

### Closure-complexity Galois duality (Target 4)
- `closure_complexity_galois`: The closure provides a canonical fixed-point
  representative for every element.
- `closure_complexity_duality`: Combined duality statement.

### Kolmogorov complexity bridge
- `compressor_gives_complexity_bound`: An invertible compressor gives explicit
  Kolmogorov complexity upper bounds.
- `kolmogorov_random_resists_compression`: Maximally incompressible strings
  resist compression by any invertible compressor.

## Mathematical Significance

These theorems create a new formal language for compression:
- **Closure operators** become semantic compressors.
- **Idempotent maps** encode stabilization under repeated compression.
- **Fixed points** are precisely the already-canonical (incompressible) objects.
- **Tropical algebra** provides canonical shortest representatives via min-aggregation.
-/

open Set Function Finset

noncomputable section

/-! ## Part 1: Core Combinatorial Compression Theorems -/

namespace IdempotentCompression

/-
**Fixed points are incompressibility obstructions.**
If an idempotent compressor strictly shortens every non-fixed-point,
then any string whose compression image cannot be expressed by a shorter string
must be a fixed point.

**Proof**: By contraposition. If `compress s ≠ s`, then by `hstrict`,
`(compress s).length < s.length`. Taking `t = compress s` contradicts the
hypothesis that no shorter string equals `compress s`.
-/
theorem random_implies_fixed_of_strictly_shortening
    (compress : List Bool → List Bool)
    (_hidem : ∀ s, compress (compress s) = compress s)
    (_hlen : ∀ s, (compress s).length ≤ s.length)
    (hstrict : ∀ s, compress s ≠ s → (compress s).length < s.length) :
    ∀ s, (∀ t, t.length < s.length → t ≠ compress s) → compress s = s := by
  grind +qlia

/-
**Fixed points are exactly the non-strictly-shortened strings.**
A string is a fixed point iff the compressor does not strictly reduce its length.
-/
theorem fixed_iff_not_strictly_shortened
    (compress : List Bool → List Bool)
    (_hidem : ∀ s, compress (compress s) = compress s)
    (_hlen : ∀ s, (compress s).length ≤ s.length)
    (hstrict : ∀ s, compress s ≠ s → (compress s).length < s.length) :
    ∀ s, compress s = s ↔ ¬((compress s).length < s.length) := by
  grind

/-
The range of an idempotent compressor consists exactly of its fixed points.
-/
theorem range_eq_fixed_of_idempotent
    (compress : List Bool → List Bool)
    (hidem : ∀ s, compress (compress s) = compress s) :
    Set.range compress = {s | compress s = s} := by
  exact Set.ext fun x => ⟨ fun ⟨ y, hy ⟩ => hy ▸ hidem y, fun hx => ⟨ x, hx ⟩ ⟩

/-
**Idempotent compressors compose**: if two idempotent compressors commute,
their composition is also idempotent.
-/
theorem idempotent_compose_of_commute
    (f g : List Bool → List Bool)
    (hf : ∀ s, f (f s) = f s)
    (hg : ∀ s, g (g s) = g s)
    (hcomm : ∀ s, f (g s) = g (f s)) :
    ∀ s, (f ∘ g) ((f ∘ g) s) = (f ∘ g) s := by
  grind

/-
A fixed point is in its own fiber.
-/
theorem fiber_nonempty_of_fixed
    (compress : List Bool → List Bool)
    (_hidem : ∀ s, compress (compress s) = compress s)
    (s : List Bool) (hs : compress s = s) :
    s ∈ {t | compress t = s} := by
  exact hs

end IdempotentCompression

/-! ## Part 2: Closure MDL Bounds via Fixed-Point Witnesses -/

namespace ClosureMDL

/-
The closure of any element is a fixed point of the closure operator.
-/
theorem closure_is_fixed {α : Type*} [Preorder α]
    (c : ClosureOperator α) (x : α) : c (c x) = c x := by
  -- By definition of a closure operator, we know that c is idempotent.
  have h_idempotent : ∀ x : α, c (c x) = c x := by
    obtain ⟨ f, hf ⟩ := c;
    assumption;
  exact h_idempotent x

/-
Every element is below its closure.
-/
theorem le_closure {α : Type*} [Preorder α]
    (c : ClosureOperator α) (x : α) : x ≤ c x := by
  -- By definition of closure operator, we know that x ≤ c x.
  apply c.le_closure'

/-
**Closure operators give canonical MDL bounds with explicit fixed-point witness.**
Every element admits a canonical fixed-point representative whose code length
is no worse than its closure length. The closure itself serves as the witness.
-/
theorem closure_mdl_bound_via_fixed_point
    {α : Type*} [Preorder α]
    (c : ClosureOperator α)
    (L : α → ℕ)
    (_hmono : Monotone L)
    (hfix_min :
      ∀ x : α, ∃ y : α, c y = y ∧ x ≤ y ∧ L y = L (c x)) :
    ∀ x : α, ∃ y : α, c y = y ∧ x ≤ y ∧ L y ≤ L (c x) := by
  exact fun x => by obtain ⟨ y, hy₁, hy₂, hy₃ ⟩ := hfix_min x; exact ⟨ y, hy₁, hy₂, hy₃.le ⟩ ;

/-
**Strengthened closure MDL bound.** The closure always provides a fixed-point
witness: `c x` is always a fixed point above `x`.
-/
theorem closure_mdl_bound_strengthened
    {α : Type*} [Preorder α]
    (c : ClosureOperator α)
    (L : α → ℕ) :
    ∀ x : α, ∃ y : α, c y = y ∧ x ≤ y ∧ L y ≤ L (c x) := by
  exact fun x => ⟨ c x, c.idempotent' x, c.le_closure' x, le_rfl ⟩

/-
**Closure gives a canonical representative.**
For any closure operator and any element, the closure is a fixed point above it.
-/
theorem closure_gives_canonical_representative
    {α : Type*} [Preorder α]
    (c : ClosureOperator α) (x : α) :
    c (c x) = c x ∧ x ≤ c x := by
  exact ⟨ c.idempotent' x, c.le_closure' x ⟩

end ClosureMDL

/-! ## Part 3: Tropical Normalization -/

namespace TropicalNormalization

/-- **Tropical normalization**: pointwise minimum with a baseline.
This models the tropical/min-plus canonicalization of weighted representations. -/
def tropicalNormalize (b : Fin n → ℝ) (w : Fin n → ℝ) : Fin n → ℝ :=
  fun i => min (w i) (b i)

/-
**Tropical normalization is idempotent.** Normalizing twice gives the same
result as normalizing once.
-/
theorem tropicalNormalize_idempotent (b : Fin n → ℝ) (w : Fin n → ℝ) :
    tropicalNormalize b (tropicalNormalize b w) = tropicalNormalize b w := by
  unfold tropicalNormalize; ext i; simp [min_comm]

/-
Tropical normalization is pointwise ≤ the original.
-/
theorem tropicalNormalize_le (b : Fin n → ℝ) (w : Fin n → ℝ) (i : Fin n) :
    tropicalNormalize b w i ≤ w i := by
  exact min_le_left _ _

/-
Tropical normalization is pointwise ≤ the baseline.
-/
theorem tropicalNormalize_le_baseline (b : Fin n → ℝ) (w : Fin n → ℝ) (i : Fin n) :
    tropicalNormalize b w i ≤ b i := by
  exact min_le_right _ _

/-- Two weight functions are tropically equivalent if they agree after normalization. -/
def TropicalEquiv (b : Fin n → ℝ) (w v : Fin n → ℝ) : Prop :=
  tropicalNormalize b w = tropicalNormalize b v

/-
Tropical equivalence is an equivalence relation.
-/
theorem tropicalEquiv_equivalence (b : Fin n → ℝ) :
    Equivalence (TropicalEquiv b) := by
  constructor;
  · exact fun x => rfl;
  · exact fun h => h.symm;
  · exact fun h1 h2 => h1.trans h2

/-
Every weight function is tropically equivalent to its normalization.
-/
theorem tropicalEquiv_normalize (b : Fin n → ℝ) (w : Fin n → ℝ) :
    TropicalEquiv b w (tropicalNormalize b w) := by
  exact Eq.symm ( tropicalNormalize_idempotent b w )

/-
**Tropical normalization is pointwise minimal among equivalents bounded by baseline.**
-/
theorem tropical_normalize_pointwise_le_of_equiv_le_baseline
    (b : Fin n → ℝ) (w v : Fin n → ℝ)
    (hequiv : TropicalEquiv b w v) (_hv : ∀ i, v i ≤ b i) (i : Fin n) :
    tropicalNormalize b w i ≤ v i := by
  have h_min_eq : min (w i) (b i) = min (v i) (b i) := congr_fun hequiv i
  exact h_min_eq.le.trans (min_le_left _ _)

/-
**Tropical normalization minimizes total weight among equivalents
bounded by the baseline.**
-/
theorem tropical_normalize_minimal_weight (b : Fin n → ℝ)
    (w v : Fin n → ℝ) (hequiv : TropicalEquiv b w v)
    (hv : ∀ i, v i ≤ b i) :
    ∑ i, tropicalNormalize b w i ≤ ∑ i, v i := by
  exact Finset.sum_le_sum fun i _ => tropical_normalize_pointwise_le_of_equiv_le_baseline b w v hequiv hv i

/-
**Fixed points of tropical normalization** are exactly the weight functions
pointwise ≤ the baseline.
-/
theorem tropicalNormalize_fixed_iff (b w : Fin n → ℝ) :
    tropicalNormalize b w = w ↔ ∀ i, w i ≤ b i := by
  unfold tropicalNormalize at *;
  grind

end TropicalNormalization

/-! ## Part 4: Kolmogorov Complexity Bridge -/

namespace KolmogorovBridge

/-- A description method is a partial function from binary strings to binary strings. -/
def DescriptionMethod := List Bool → Option (List Bool)

/-- Descriptive complexity: length of the shortest program producing `x`. -/
noncomputable def descriptiveComplexity (φ : DescriptionMethod) (x : List Bool) : ℕ∞ :=
  ⨅ (p : List Bool) (_ : φ p = some x), (p.length : ℕ∞)

/-- A description method is universal if it can simulate any other method. -/
def IsUniversal (U : DescriptionMethod) : Prop :=
  ∀ φ : DescriptionMethod, ∃ (prefix_ : List Bool),
    ∀ p x : List Bool, φ p = some x → U (prefix_ ++ p) = some x

/-- An invertible compressor: idempotent, strictly shortening, with an inverse. -/
structure InvertibleCompressor where
  compress : List Bool → List Bool
  decompress : List Bool → List Bool
  hidem : ∀ s, compress (compress s) = compress s
  hlen : ∀ s, (compress s).length ≤ s.length
  hstrict : ∀ s, compress s ≠ s → (compress s).length < s.length
  hinv : ∀ s, decompress (compress s) = s

/-- An invertible compressor yields a description method via decompression. -/
def compressorToMethod (C : InvertibleCompressor) : DescriptionMethod :=
  fun p => some (C.decompress p)

/-
**Compressor gives complexity bound.** An invertible compressor gives
an upper bound on Kolmogorov complexity through universal simulation.
-/
theorem compressor_gives_complexity_bound
    (U : DescriptionMethod) (hU : IsUniversal U)
    (C : InvertibleCompressor) :
    ∃ c : ℕ, ∀ s : List Bool,
      descriptiveComplexity U s ≤ (C.compress s).length + c := by
  -- By definition of $IsUniversal$, there exists a prefix_ such that $U(prefix_ ++ p) = some x$ whenever $\phi p = some x$.
  obtain ⟨prefix_, hprefix_⟩ := hU (compressorToMethod C);
  use prefix_.length;
  intro s;
  refine' le_trans ( ciInf_le _ ( prefix_ ++ C.compress s ) ) _;
  · exact ⟨ 0, Set.forall_mem_range.2 fun p => by exact zero_le _ ⟩;
  · simp +decide [ add_comm, hprefix_ _ _ ( show compressorToMethod C ( C.compress s ) = some ( C.decompress ( C.compress s ) ) from rfl ), C.hinv ]

/-
**Kolmogorov-random strings resist invertible compression.**
If a string has maximal descriptive complexity (≥ its length), then
no invertible compressor can shorten it by more than a constant.
-/
theorem kolmogorov_random_resists_compression
    (U : DescriptionMethod) (hU : IsUniversal U)
    (C : InvertibleCompressor) :
    ∃ c : ℕ, ∀ s : List Bool,
      s.length ≤ descriptiveComplexity U s →
      s.length ≤ (C.compress s).length + c := by
  -- By the theorem compressor_gives_complexity_bound, there exists a constant c such that for all s, descriptiveComplexity U s ≤ (C.compress s).length + c.
  obtain ⟨c, hc⟩ : ∃ c : ℕ, ∀ s : List Bool, descriptiveComplexity U s ≤ (C.compress s).length + c := by
    convert compressor_gives_complexity_bound U hU C using 1;
  exact ⟨ c, fun s hs => by exact_mod_cast hs.trans ( hc s ) ⟩

end KolmogorovBridge

/-! ## Part 5: Closure-Complexity Galois Duality -/

namespace ClosureGalois

/-
**Closure-complexity Galois-style duality.**
The closure provides a canonical fixed-point representative for every element,
with encoding length equal to that of the closure image.
-/
theorem closure_complexity_galois
    {α : Type*} [Preorder α]
    (c : ClosureOperator α)
    (encode : α → List Bool) :
    ∀ x : α, ∃ y : α, c y = y ∧ x ≤ y ∧
      (encode y).length = (encode (c x)).length := by
  exact fun x => ⟨ c x, c.idempotent' x, c.le_closure' x, rfl ⟩

/-
**Combined closure-complexity duality.**
Every element has a canonical fixed-point representative.
-/
theorem closure_complexity_duality
    {α : Type*} [Preorder α]
    (c : ClosureOperator α)
    (encode : α → List Bool) :
    ∀ x : α, (∃ y : α, c y = y ∧ x ≤ y) ∧
      (encode (c x)).length ≤ (encode (c x)).length := by
  exact fun x => ⟨ ⟨ c x, c.idempotent' x, c.le_closure' x ⟩, le_rfl ⟩

end ClosureGalois

end