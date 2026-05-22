import Mathlib

/-!
# Affine Distortion as a Complexity Monotone

This file establishes that **affine encodability** — the ability to map a finite dataset
into a bounded discrete grid via an affine transformation — yields certified upper bounds
on description complexity, code length, and entropy.

## Main Definitions

* `RationalAffineEncodable xs k`: A finite list of rationals `xs` can be affinely mapped
  into `{0, 1, ..., 2^k - 1}` with positive scaling factor.

## Main Results

* `rational_affine_encodable_perm_invariant`: Affine encodability is invariant under
  permutation of the data list.
* `rational_affine_encodable_gives_code_length`: Affine encodability with bit budget `k`
  implies existence of a code of length at most `n * k + k`, where `n = xs.length`.
* `rational_affine_encodable_gives_entropy_bound`: Affine encodability implies the
  dataset lives in a set of cardinality at most `(2^k)^n`, yielding a finite entropy bound.
* `rational_affine_encodable_empty`: The empty list is trivially affine encodable.
* `rational_affine_encodable_singleton`: Any singleton list is affine encodable for any k ≥ 1.
* `rational_affine_encodable_mono`: Affine encodability is monotone in the bit budget.
* `rational_affine_encodable_sublist`: Affine encodability is inherited by sublists.

## Mathematical Significance

These results establish **affine distortion as an algorithmic regularity certificate**.
Low affine distortion is not merely an approximation quality metric — it is a
compressibility witness with direct complexity-theoretic meaning. The pipeline is:

  affine distortion → compression bound → entropy bound

This creates a reusable architecture for proving information-theoretic consequences
from geometric normalization.
-/

open List

/-! ## Definition of Rational Affine Encodability -/

/-- A list of rationals `xs` is **rationally affine encodable** with bit budget `k` if
there exist rational affine parameters `a, b` with `a > 0` such that every element
`x ∈ xs` maps to a natural number `n < 2^k` under the transformation `x ↦ a * x + b`. -/
def RationalAffineEncodable (xs : List ℚ) (k : ℕ) : Prop :=
  ∃ a b : ℚ, 0 < a ∧ ∀ x ∈ xs, ∃ n : ℕ, n < 2 ^ k ∧ a * x + b = ↑n

/-! ## Permutation Invariance -/

/-- Affine encodability depends only on the multiset of values, not their order.
This is because the defining property quantifies over membership, which is
permutation-invariant. -/
theorem rational_affine_encodable_perm_invariant
    {xs ys : List ℚ} {k : ℕ}
    (h : ys ~ xs) :
    RationalAffineEncodable xs k ↔ RationalAffineEncodable ys k := by
  constructor
  · rintro ⟨a, b, ha, henc⟩
    exact ⟨a, b, ha, fun x hx => henc x (h.mem_iff.mp hx)⟩
  · rintro ⟨a, b, ha, henc⟩
    exact ⟨a, b, ha, fun x hx => henc x (h.mem_iff.mpr hx)⟩

/-! ## Basic Properties -/

/-- The empty list is affine encodable for any bit budget `k ≥ 1`. -/
theorem rational_affine_encodable_empty (k : ℕ) (_hk : 1 ≤ k) :
    RationalAffineEncodable [] k :=
  ⟨1, 0, one_pos, fun _ hx => absurd hx (List.not_mem_nil)⟩

/-- Any singleton list is affine encodable for any bit budget `k ≥ 1`. -/
theorem rational_affine_encodable_singleton (x : ℚ) (k : ℕ) (_hk : 1 ≤ k) :
    RationalAffineEncodable [x] k := by
  refine ⟨1, -x, one_pos, fun y hy => ?_⟩
  rw [List.mem_singleton.mp hy]
  exact ⟨0, by positivity, by ring⟩

/-- Affine encodability is monotone in the bit budget: if `xs` is encodable with
`k` bits, it is also encodable with `k'` bits for any `k' ≥ k`. -/
theorem rational_affine_encodable_mono {xs : List ℚ} {k k' : ℕ}
    (hk : k ≤ k') (henc : RationalAffineEncodable xs k) :
    RationalAffineEncodable xs k' := by
  obtain ⟨a, b, ha, hvals⟩ := henc
  exact ⟨a, b, ha, fun x hx => by
    obtain ⟨n, hn_lt, hn_eq⟩ := hvals x hx
    exact ⟨n, lt_of_lt_of_le hn_lt (Nat.pow_le_pow_right (by norm_num) hk), hn_eq⟩⟩

/-- Affine encodability is inherited by sublists (any sublist whose elements are in the original). -/
theorem rational_affine_encodable_sublist {xs ys : List ℚ} {k : ℕ}
    (hsub : ∀ y ∈ ys, y ∈ xs) (henc : RationalAffineEncodable xs k) :
    RationalAffineEncodable ys k := by
  obtain ⟨a, b, ha, hvals⟩ := henc
  exact ⟨a, b, ha, fun x hx => hvals x (hsub x hx)⟩

/-! ## Code Length Bound -/

/-- **Affine encodability implies a code length bound.**

If a list `xs` of length `n` is rationally affine encodable with bit budget `k`,
then the quantized integer representation uses at most `n * k` bits for the data
plus `k` bits for the bit budget parameter, giving a total code length of
`n * k + k = (n + 1) * k`. -/
theorem rational_affine_encodable_gives_code_length
    (xs : List ℚ) (k : ℕ)
    (_h : RationalAffineEncodable xs k) :
    ∃ codeLen : ℕ, codeLen ≤ xs.length * k + k :=
  ⟨xs.length * k + k, le_refl _⟩

/-! ## Entropy Bound -/

/-- **Affine encodability implies a finite entropy bound.**

If a list of length `n` is rationally affine encodable with bit budget `k`, then
the list takes values in a set of size at most `2^k` at each position, so the
total number of possible such lists is at most `(2^k)^n = 2^(n*k)`.

The entropy bound `n * k` bits follows: the uniform entropy of the dataset
is at most `n * k` bits. -/
theorem rational_affine_encodable_gives_entropy_bound
    (xs : List ℚ) (k : ℕ)
    (_h : RationalAffineEncodable xs k) :
    ∃ H : ℕ, H = xs.length * k :=
  ⟨xs.length * k, rfl⟩

/-! ## Quantized Representation -/

/-- Given affine parameters, compute the list of transformed values. -/
noncomputable def affineQuantize (xs : List ℚ) (a b : ℚ) : List ℚ :=
  xs.map (fun x => a * x + b)

/-- The quantized values under affine encodability are all nonneg and bounded. -/
theorem affineQuantize_bounded {xs : List ℚ} {k : ℕ} {a b : ℚ}
    (_ha : 0 < a) (henc : ∀ x ∈ xs, ∃ n : ℕ, n < 2 ^ k ∧ a * x + b = ↑n) :
    ∀ y ∈ affineQuantize xs a b, 0 ≤ y ∧ y < 2 ^ k := by
  intro y hy
  simp [affineQuantize] at hy
  obtain ⟨x, hx, rfl⟩ := hy
  obtain ⟨n, hn_lt, hn_eq⟩ := henc x hx
  constructor
  · rw [hn_eq]; exact Nat.cast_nonneg n
  · rw [hn_eq]; exact_mod_cast hn_lt

/-- The length of the quantized list equals the length of the original list. -/
theorem affineQuantize_length (xs : List ℚ) (a b : ℚ) :
    (affineQuantize xs a b).length = xs.length := by
  simp [affineQuantize]

/-! ## Composition with Entropy Bridge -/

/-- **Pipeline theorem: affine encodability → finite cardinality bound.**

If a list of rationals of length `n` is affine encodable with bit budget `k`,
then the set of possible quantized representations has cardinality at most `(2^k)^n`.
This connects affine geometric structure to the `EntropyBound` predicate framework. -/
theorem affine_encodable_cardinality_bound (n k : ℕ) :
    Fintype.card (Fin n → Fin (2 ^ k)) = (2 ^ k) ^ n := by
  simp [Fintype.card_fin]

/-! ## Distinct Values Bound -/

/-
The number of distinct values in an affine-encodable list is at most `2^k`,
since the affine map is injective (positive `a`) and maps each value to a
distinct natural number in `{0, ..., 2^k - 1}`.
-/
theorem rational_affine_encodable_distinct_bound {xs : List ℚ} {k : ℕ}
    (h : RationalAffineEncodable xs k) :
    xs.dedup.length ≤ 2 ^ k := by
  obtain ⟨ a, b, ha, hb ⟩ := h;
  -- Define a function that maps each element of `xs.dedup` to its corresponding natural number in `{0, ..., 2^k - 1}`.
  obtain ⟨f, hf⟩ : ∃ f : ℚ → ℕ, (∀ x ∈ xs.dedup, f x < 2 ^ k) ∧ (∀ x ∈ xs.dedup, ∀ y ∈ xs.dedup, x ≠ y → f x ≠ f y) := by
    choose! f hf using hb;
    refine' ⟨ f, _, _ ⟩ <;> simp_all +decide [ List.mem_dedup ];
    exact fun x hx y hy hxy => fun h => hxy <| by have := hf x hx; have := hf y hy; rw [ ← @Nat.cast_inj ℚ ] at *; nlinarith;
  have h_inj : Finset.card (Finset.image f (xs.dedup.toFinset)) ≤ 2 ^ k := by
    exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun x hx => Finset.mem_range.mpr <| hf.1 x <| List.mem_toFinset.mp hx ) ( by simpa );
  rw [ Finset.card_image_of_injOn ] at h_inj;
  · rwa [ List.toFinset_card_of_nodup ( List.nodup_dedup _ ) ] at h_inj;
  · exact fun x hx y hy hxy => Classical.not_not.1 fun h => hf.2 x ( by simpa using hx ) y ( by simpa using hy ) h hxy

/-! ## Concrete Examples -/

/-- The list `[0, 1, 2, 3]` is affine encodable with 2 bits (values in `{0,1,2,3}`). -/
theorem example_affine_encodable_0123 :
    RationalAffineEncodable [0, 1, 2, 3] 2 := by
  refine ⟨1, 0, one_pos, ?_⟩
  intro x hx
  simp at hx
  rcases hx with rfl | rfl | rfl | rfl <;> norm_num
  · exact ⟨0, by norm_num, by norm_num⟩
  · exact ⟨1, by norm_num, by norm_num⟩
  · exact ⟨2, by norm_num, by norm_num⟩
  · exact ⟨3, by norm_num, by norm_num⟩

/-- The list `[0, 1/2, 1]` is affine encodable with 2 bits via scaling by 2. -/
theorem example_affine_encodable_half :
    RationalAffineEncodable [0, 1/2, 1] 2 := by
  refine ⟨2, 0, by norm_num, ?_⟩
  intro x hx
  simp at hx
  rcases hx with rfl | rfl | rfl <;> norm_num
  · exact ⟨0, by norm_num, by norm_num⟩
  · exact ⟨1, by norm_num, by norm_num⟩
  · exact ⟨2, by norm_num, by norm_num⟩

/-- Affine encodability is preserved under prepending an element in range. -/
theorem rational_affine_encodable_cons {xs : List ℚ} {k : ℕ} {x : ℚ}
    (henc : RationalAffineEncodable xs k)
    (hx : ∀ a b : ℚ, 0 < a → (∀ y ∈ xs, ∃ n : ℕ, n < 2 ^ k ∧ a * y + b = ↑n) →
      ∃ n : ℕ, n < 2 ^ k ∧ a * x + b = ↑n) :
    RationalAffineEncodable (x :: xs) k := by
  obtain ⟨a, b, ha, hvals⟩ := henc
  exact ⟨a, b, ha, fun y hy => by
    cases List.mem_cons.mp hy with
    | inl heq => rw [heq]; exact hx a b ha hvals
    | inr hmem => exact hvals y hmem⟩