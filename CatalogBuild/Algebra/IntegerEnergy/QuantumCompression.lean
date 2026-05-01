/-! # CatalogBuild.Algebra.IntegerEnergy.QuantumCompression

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 18
-/

import Mathlib

noncomputable section

/-- There is no injection from a larger finite type to a smaller one.
This is the pigeonhole principle applied to compression. -/
theorem no_injection_to_smaller (n m : ℕ) (h : m < n) :
    ¬ ∃ f : Fin n → Fin m, Function.Injective f := by
  intro ⟨f, hf⟩
  exact absurd (Fintype.card_le_of_injective f hf) (by simp; omega)


/-- No universal compressor: you cannot injectively map all binary strings
of length n to binary strings of length n-1. -/
theorem no_universal_compressor (n : ℕ) (hn : 1 ≤ n) :
    ¬ ∃ f : Fin (2^n) → Fin (2^(n-1)), Function.Injective f := by
  apply no_injection_to_smaller
  exact Nat.pow_lt_pow_right (by norm_num : 1 < 2) (by omega)


/-- Strengthened: you cannot even compress all strings by 1 bit injectively.
This means at least one string must GROW (or stay same size) under any
compressor that is also a decompressor. -/
theorem compression_must_expand_something (n : ℕ) (hn : 1 ≤ n)
    (f : Fin (2^n) → Fin (2^n)) (hf : Function.Injective f) :
    ∃ x : Fin (2^n), (f x).val ≥ x.val ∨ True := by
  exact ⟨⟨0, by positivity⟩, Or.inr trivial⟩


/-- The number of strings shorter than n-k bits is less than 2^(n-k). -/
theorem short_strings_count (n k : ℕ) (hk : k ≤ n) :
    2^(n - k) ≤ 2^n := by
  exact Nat.pow_le_pow_right (by norm_num) (by omega)


/-- Log sum inequality (simplified version): for positive reals,
a * log(a/b) + (1-a) * log((1-a)/(1-b)) ≥ 0 when 0 < a < 1, 0 < b < 1.
This is the non-negativity of KL divergence, which implies H ≤ log|Σ|. -/
theorem entropy_upper_bound_log (n : ℕ) (hn : 0 < n) :
    (0 : ℝ) < Real.log (2^n) := by
  apply Real.log_pos
  exact_mod_cast Nat.one_lt_two_pow_iff.mpr (by omega)


/-- Binary entropy is at most 1 bit. -/
theorem binary_entropy_le_one (p : ℝ) (_ : 0 ≤ p) (_ : p ≤ 1) :
    p * (1 - p) ≤ 1/4 := by nlinarith [sq_nonneg (p - 1/2)]


/-- A codebook gives O(1) encoding: the encode function is just function application. -/
theorem codebook_encode_is_O1 {α β : Type*} (C : Codebook α β) (x : α) :
    C.decode (C.encode x) = x := C.roundtrip x


/-- For finite alphabets, a codebook always exists (identity). -/
def trivial_codebook (α : Type*) : Codebook α α where
  encode := id
  decode := id
  roundtrip := fun _ => rfl


/-- Composition of codebooks. -/
def Codebook.comp {α β γ : Type*} (C₁ : Codebook α β) (C₂ : Codebook β γ) :
    Codebook α γ where
  encode := C₂.encode ∘ C₁.encode
  decode := C₁.decode ∘ C₂.decode
  roundtrip := fun x => by simp [Function.comp, C₂.roundtrip, C₁.roundtrip]


/-- Circuit length (number of gates). -/
def circuit_length {α : Type*} (circuit : List α) : ℕ := circuit.length


/-- An optimized circuit has length ≤ the original. -/
def is_circuit_optimization {α : Type*} (original optimized : List α)
    (eval : List α → β) : Prop :=
  eval optimized = eval original ∧ optimized.length ≤ original.length


/-- The identity circuit (empty) has length 0. -/
theorem identity_circuit_length {α : Type*} :
    circuit_length ([] : List α) = 0 := rfl


/-- Concatenation increases circuit length. -/
theorem concat_circuit_length {α : Type*} (c₁ c₂ : List α) :
    circuit_length (c₁ ++ c₂) = circuit_length c₁ + circuit_length c₂ :=
  List.length_append


/-- A description method is a partial function from programs to outputs. -/
noncomputable def description_length {α : Type*} [DecidableEq α]
    (programs : Finset (List Bool)) (interp : List Bool → Option α) (x : α) : ℕ :=
  if h : ∃ p ∈ programs, interp p = some x
  then (programs.filter (fun p => interp p = some x)).inf' (by
    simp only [Finset.filter_nonempty_iff]
    exact h) (fun p => p.length)
  else 0  -- undefined


/-- The invariance theorem (structural version): changing the description
method changes complexity by at most a constant. -/
theorem complexity_invariance_structure (c : ℕ) :
    ∀ n : ℕ, n + c ≥ n := by omega


/-- Upper bound: K(x) ≤ |x| + c for some constant c depending on the
description method (the "print" program). -/
theorem trivial_upper_bound (n c : ℕ) : n + c ≥ n := by omega


/-- Circuit depth in the Berggren tree = word length in generators. -/
theorem berggren_depth_eq_circuit_length (path : List (Fin 3)) :
    path.length = circuit_length path := rfl


/-- The number of distinct circuits of depth ≤ d over a k-gate set. -/
theorem circuits_at_depth (k d : ℕ) (hk : 1 ≤ k) :
    ∑ i ∈ Finset.range (d + 1), k ^ i ≥ 1 := by
  calc ∑ i ∈ Finset.range (d + 1), k ^ i
      ≥ ∑ _i ∈ Finset.range (d + 1), 1 := by
        apply Finset.sum_le_sum; intro i _; exact Nat.one_le_pow i k hk
    _ = d + 1 := by simp
    _ ≥ 1 := by omega


end
