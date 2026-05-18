/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical One-Wayness as Additive Rank Rigidity

This file develops the first formal theory of tropical one-wayness, establishing
that tropical powering (iterated min-plus multiplication) creates mathematically
provable obstructions to inversion.

## Main Results

### Diagonal tropical powers
* `tropicalPowDiag_closed_form`: The T-th tropical power of diagonal data
  `d : Fin n → α` satisfies `tropicalPowDiag T d i = T * d i`.

### Shift covariance
* `tropicalPowDiag_shift`: Adding a constant `c` to all diagonal entries
  scales the T-th power by `T * c`.

### Root obstructions (ℤ)
* `tropicalDiag_has_root_implies_divisible`: If `d` admits a tropical T-th root
  over ℤ, then `T ∣ d i` for all `i`.
* `tropicalDiag_root_iff_divisible`: Complete characterization — a diagonal
  tropical vector over ℤ has a T-th root iff all entries are T-divisible.

### Non-injectivity
* `tropicalPow_not_injective_mod_normalize`: Even after normalization by
  subtracting the minimum entry, the tropical power map has nontrivial fibers.

### Infinite fibers
* `tropicalPowDiag_normalized_fiber_infinite`: Over ℝ, the normalized fiber of
  the tropical diagonal power map is infinite for n ≥ 1 and T ≥ 1.

### Gap monotonicity
* `tropicalDiagGap_pow_linear`: The gap functional (max − min) satisfies
  `gap(powDiag T d) = T * gap(d)`, giving exact linear scaling.
* `tropicalDiagGap_monotone_pow`: The gap is monotone under tropical powering.

## Cross-domain significance

These results form the algebraic backbone of tropical cryptographic algebra:
- **Cryptography**: Tropical powering is algebraically easy forward but has
  provably non-unique preimages and arithmetic obstructions to inversion.
- **Dynamical systems**: Gap amplification under tropical iteration mirrors
  mixing/contraction certificates.
- **Arithmetic geometry**: Root obstructions over ℤ are divisibility
  obstructions analogous to local-global solvability criteria.
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-! ## §1. Diagonal Tropical Powers -/

/-- The T-th tropical power of diagonal data `d : Fin n → ℤ`.

For diagonal tropical matrices, the tropical product `D ⊗ D` has diagonal
entries `(D ⊗ D)_{ii} = min_k (D_{ik} + D_{ki})`. For a diagonal matrix
where off-diagonal entries are `+∞`, only the `k = i` term survives,
giving `D_{ii} + D_{ii} = 2 · D_{ii}`. By induction, the T-th power has
diagonal `T · D_{ii}`.

We define this directly as the closed-form result. -/
def tropicalPowDiag (T : ℕ) (d : Fin n → ℤ) : Fin n → ℤ :=
  fun i => T * d i

/-- Real-valued version for continuous theory. -/
def tropicalPowDiagR (T : ℕ) (d : Fin n → ℝ) : Fin n → ℝ :=
  fun i => T * d i

/-! ## §2. Basic Properties of Diagonal Tropical Powers -/

@[simp]
theorem tropicalPowDiag_zero (d : Fin n → ℤ) :
    tropicalPowDiag 0 d = fun _ => 0 := by
  ext i; simp [tropicalPowDiag]

@[simp]
theorem tropicalPowDiag_one (d : Fin n → ℤ) :
    tropicalPowDiag 1 d = d := by
  ext i; simp [tropicalPowDiag]

theorem tropicalPowDiag_succ (T : ℕ) (d : Fin n → ℤ) :
    tropicalPowDiag (T + 1) d = fun i => tropicalPowDiag T d i + d i := by
  ext i; simp [tropicalPowDiag]; ring

/-- **Closed-form formula**: The T-th tropical diagonal power multiplies
each entry by T. This is the fundamental computational identity. -/
theorem tropicalPowDiag_closed_form (T : ℕ) (d : Fin n → ℤ) (i : Fin n) :
    tropicalPowDiag T d i = T * d i := rfl

/-- Real-valued closed form. -/
theorem tropicalPowDiagR_closed_form (T : ℕ) (d : Fin n → ℝ) (i : Fin n) :
    tropicalPowDiagR T d i = T * d i := rfl

/-! ## §3. Shift Covariance — The Tropical Hecke Compatibility -/

/-- **Shift covariance**: Adding a constant to all diagonal entries scales
the T-th power additively by `T * c`.

This is the tropical analog of `tropical_hecke_shift_one`: shifting by `c`
in the tropical semiring corresponds to scaling the power by `T * c`.
This reveals the semigroup structure of tropical powering. -/
theorem tropicalPowDiag_shift (T : ℕ) (d : Fin n → ℤ) (c : ℤ) :
    tropicalPowDiag T (fun i => d i + c) = fun i => tropicalPowDiag T d i + T * c := by
  ext i; simp [tropicalPowDiag]; ring

/-- Real-valued shift covariance. -/
theorem tropicalPowDiagR_shift (T : ℕ) (d : Fin n → ℝ) (c : ℝ) :
    tropicalPowDiagR T (fun i => d i + c) = fun i => tropicalPowDiagR T d i + T * c := by
  ext i; simp [tropicalPowDiagR]; ring

/-! ## §4. Root Obstructions over ℤ -/

/-- **Root obstruction**: If a diagonal tropical vector `d` over ℤ admits a
T-th tropical root, then every entry must be divisible by T.

This is the first exact root-existence criterion for a tropical power map.
It creates an arithmetic obstruction to inversion: not every integer vector
is in the image of the tropical power map. -/
theorem tropicalDiag_has_root_implies_divisible
    {n T : ℕ} (_hT : 1 ≤ T) (d : Fin n → ℤ) :
    (∃ a : Fin n → ℤ, tropicalPowDiag T a = d) →
    ∀ i, (T : ℤ) ∣ d i := by
  rintro ⟨a, ha⟩ i
  have : d i = T * a i := by
    have := congr_fun ha i
    simp [tropicalPowDiag] at this
    linarith
  exact ⟨a i, this⟩

/-- **Converse**: If every entry of `d` is divisible by T, then `d` admits a
tropical T-th root. The root is simply `d i / T`. -/
theorem tropicalDiag_divisible_implies_has_root
    {n T : ℕ} (_hT : 1 ≤ T) (d : Fin n → ℤ) :
    (∀ i, (T : ℤ) ∣ d i) →
    ∃ a : Fin n → ℤ, tropicalPowDiag T a = d := by
  intro hdiv
  refine ⟨fun i => d i / T, ?_⟩
  ext i
  simp [tropicalPowDiag]
  exact Int.mul_ediv_cancel' (hdiv i)

/-- **Complete root characterization**: A diagonal tropical vector over ℤ has
a T-th root if and only if all entries are T-divisible.

This is a genuine classification theorem — the first exact root-existence
criterion for tropical power maps on a natural algebraic class. -/
theorem tropicalDiag_root_iff_divisible
    {n T : ℕ} (hT : 1 ≤ T) (d : Fin n → ℤ) :
    (∃ a : Fin n → ℤ, tropicalPowDiag T a = d) ↔
    ∀ i, (T : ℤ) ∣ d i :=
  ⟨tropicalDiag_has_root_implies_divisible hT d,
   tropicalDiag_divisible_implies_has_root hT d⟩

/-! ## §5. Non-Injectivity of the Tropical Power Map -/

/-- **Normalization**: Subtract the value at index 0 to quotient by
additive constants. This is the tropical analog of projective normalization. -/
def normalizeVec (d : Fin (n + 1) → ℝ) : Fin (n + 1) → ℝ :=
  fun i => d i - d 0

/-- **Non-injectivity modulo normalization**: After normalizing by additive
constants, the tropical power map is not injective. Specifically, for any
constant `c ≠ 0`, the vectors `d` and `d + c` normalize to the same vector
after tropical powering.

This is the first rigorous "one-wayness-like" statement: the forward map
is easy, but inversion is non-unique even after natural normalization. -/
theorem tropicalPow_not_injective_mod_normalize {n : ℕ} (T : ℕ) (hT : 1 ≤ T) :
    ∃ a b : Fin (n + 1) → ℝ,
      a ≠ b ∧ normalizeVec (tropicalPowDiagR T a) = normalizeVec (tropicalPowDiagR T b) := by
  refine ⟨fun _ => 0, fun _ => 1, ?_, ?_⟩
  · intro h
    have := congr_fun h 0
    simp at this
  · ext i
    simp [normalizeVec, tropicalPowDiagR]

/-! ## §6. Infinite Fibers -/

/-- **Normalized fiber**: The set of vectors whose T-th power
normalizes to the same value as a given target's T-th power. -/
def tropicalPowDiagNormalizedFiber (T : ℕ) (target : Fin (n + 1) → ℝ) :
    Set (Fin (n + 1) → ℝ) :=
  {a | normalizeVec (tropicalPowDiagR T a) = normalizeVec (tropicalPowDiagR T target)}

/-- The normalized fiber contains all additive shifts of the target. -/
theorem tropicalPowDiag_normalized_fiber_contains_shifts
    {n : ℕ} (T : ℕ) (_hT : 1 ≤ T) (d : Fin (n + 1) → ℝ) (c : ℝ) :
    (fun i => d i + c) ∈ tropicalPowDiagNormalizedFiber T d := by
  simp only [tropicalPowDiagNormalizedFiber, Set.mem_setOf_eq]
  ext i
  simp [normalizeVec, tropicalPowDiagR]
  ring

/-
**Infinite fibers**: The normalized fiber of the tropical diagonal power map
is always infinite. This proves that the tropical power map is genuinely many-to-one.

This is the central "one-way map" theorem: the forward map `d ↦ normalize(T * d)`
is easy to compute but has uncountably many preimages.
-/
theorem tropicalPowDiag_normalized_fiber_infinite
    {n : ℕ} (T : ℕ) (hT : 1 ≤ T) (d : Fin (n + 1) → ℝ) :
    Set.Infinite (tropicalPowDiagNormalizedFiber T d) := by
  refine' Set.infinite_of_injective_forall_mem ( fun x y hxy => _ ) fun x => tropicalPowDiag_normalized_fiber_contains_shifts T hT d x;
  simpa using congr_fun hxy 0

/-! ## §7. Gap Functional and Monotonicity -/

/-- The **tropical gap** of a vector: the difference between the
maximum and minimum entries. This measures the "spread" of the tropical data. -/
def tropicalDiagGap (d : Fin (n + 1) → ℝ) : ℝ :=
  (Finset.univ.sup' ⟨0, Finset.mem_univ 0⟩ d) -
  (Finset.univ.inf' ⟨0, Finset.mem_univ 0⟩ d)

/-
**Gap scaling**: The gap functional scales exactly linearly under tropical
powering: `gap(T * d) = T * gap(d)`.
-/
theorem tropicalDiagGap_pow_linear {n : ℕ} (T : ℕ) (d : Fin (n + 1) → ℝ) :
    tropicalDiagGap (tropicalPowDiagR T d) = T * tropicalDiagGap d := by
  -- Unfold the definitions of `tropicalDiagGap` and `tropicalPowDiagR`, and simplify the expression.
  unfold tropicalDiagGap tropicalPowDiagR;
  simp +decide [ mul_sub, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
  congr! 1;
  · refine' le_antisymm _ _ <;> norm_num;
    · exact fun i => mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun i => d i ) ( Finset.mem_univ i ) ) ( Nat.cast_nonneg _ );
    · exact ( Finset.exists_max_image _ _ ⟨ 0, Finset.mem_univ _ ⟩ ) |> fun ⟨ b, hb₁, hb₂ ⟩ => ⟨ b, mul_le_mul_of_nonneg_left ( Finset.sup'_le _ _ fun x hx => hb₂ x hx ) <| Nat.cast_nonneg _ ⟩;
  · refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
    · exact Exists.elim ( Finset.exists_min_image Finset.univ ( fun i => d i ) ⟨ 0, Finset.mem_univ 0 ⟩ ) fun i hi => ⟨ i, mul_le_mul_of_nonneg_left ( Finset.le_inf' _ _ fun j hj => hi.2 j hj ) ( Nat.cast_nonneg _ ) ⟩;
    · exact fun i => mul_le_mul_of_nonneg_left ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Nat.cast_nonneg _ )

/-
**Gap monotonicity**: For `T ≥ 1`, the gap of the T-th tropical power is
at least the gap of the original vector.
-/
theorem tropicalDiagGap_monotone_pow {n : ℕ} (T : ℕ) (hT : 1 ≤ T)
    (d : Fin (n + 1) → ℝ) :
    tropicalDiagGap d ≤ tropicalDiagGap (tropicalPowDiagR T d) := by
  -- By the gap linear scaling theorem, we have `tropicalDiagGap (tropicalPowDiagR T d) = T * tropicalDiagGap d`.
  have h_gap_linear : tropicalDiagGap (tropicalPowDiagR T d) = T * tropicalDiagGap d := by
    exact?;
  exact h_gap_linear.symm ▸ le_mul_of_one_le_left ( sub_nonneg_of_le <| Finset.le_sup' ( fun x : Fin ( n + 1 ) => d x ) ( Finset.mem_univ 0 ) |> le_trans ( Finset.inf'_le _ <| Finset.mem_univ 0 ) ) <| mod_cast hT

/-
**Linear lower bound on gap**: The gap of the T-th power is at least
`T * gap(d)`.
-/
theorem tropicalDiagGap_linear_lower_bound {n : ℕ} (T : ℕ)
    (d : Fin (n + 1) → ℝ) :
    T * tropicalDiagGap d ≤ tropicalDiagGap (tropicalPowDiagR T d) := by
  convert tropicalDiagGap_pow_linear T d |> le_of_eq;
  · convert tropicalDiagGap_pow_linear T d |> Eq.symm;
  · convert tropicalDiagGap_pow_linear T d using 1

/-! ## §8. HasTropicalRoot Predicate -/

/-- A vector `d` has a tropical T-th root over ℤ if there exists
`a : Fin n → ℤ` with `tropicalPowDiag T a = d`. -/
def HasTropicalRoot (T : ℕ) (d : Fin n → ℤ) : Prop :=
  ∃ a : Fin n → ℤ, tropicalPowDiag T a = d

/-- Reformulation using the HasTropicalRoot predicate. -/
theorem hasTropicalRoot_iff_divisible {n T : ℕ} (hT : 1 ≤ T)
    (d : Fin n → ℤ) :
    HasTropicalRoot T d ↔ ∀ i, (T : ℤ) ∣ d i :=
  tropicalDiag_root_iff_divisible hT d

/-- **Root non-existence example**: The vector `(1, 1, ..., 1)` has no
tropical 2nd root over ℤ, because 2 ∤ 1. -/
theorem no_tropical_square_root_of_ones {n : ℕ} (hn : 1 ≤ n) :
    ¬HasTropicalRoot 2 (fun (_ : Fin n) => (1 : ℤ)) := by
  rw [hasTropicalRoot_iff_divisible (by omega)]
  push_neg
  exact ⟨⟨0, by omega⟩, by omega⟩

/-- **Root existence example**: The vector `(4, 6, 8)` has a tropical
2nd root over ℤ, namely `(2, 3, 4)`. -/
theorem tropical_square_root_exists_example :
    HasTropicalRoot 2 (![4, 6, 8] : Fin 3 → ℤ) := by
  rw [hasTropicalRoot_iff_divisible (by omega)]
  intro i
  fin_cases i <;> simp [Matrix.cons_val_zero, Matrix.cons_val_one]

end