import Mathlib

/-!
# Idempotent Schur multipliers, the `γ₂` factorization norm, and blow-ups of the identity

This file develops, from scratch and with complete proofs, the elementary theory of the
factorization norm `γ₂` of a real matrix, in the form needed for the study of *idempotent
Schur multipliers*.

Background.  A Schur multiplier is the operation `B ↦ A ⊙ B` of entrywise (Hadamard)
multiplication by a fixed matrix `A`.  Such a multiplier is idempotent exactly when `A` is a
*boolean* matrix (all entries `0` or `1`), and its norm as an operator on the bounded
operators is the factorization norm `‖A‖_{γ₂}` (Grothendieck–Haagerup).  A conjecture
discussed in the literature asserts that every boolean matrix `A` with `‖A‖_{γ₂} ≤ γ` can be
written as a signed sum of at most `L = L(γ)` *blow-ups of identity matrices*.

What is proved here.

* `GammaTwoLE A c` : a self-contained, symmetric definition of `‖A‖_{γ₂} ≤ c`
  (a factorization `A i j = ⟪x i, y j⟫` with all `‖x i‖² ≤ c`, `‖y j‖² ≤ c`).
* `gammaTwoLE_iff_unbalanced` : this symmetric definition agrees with the usual asymmetric
  one, `max‖x i‖ · max‖y j‖ ≤ c` (the rescaling argument).
* `abs_entry_le_of_gammaTwoLE` : `|A i j| ≤ c` (Cauchy–Schwarz).
* `GammaTwoLE.add`, `GammaTwoLE.neg`, `gammaTwoLE_signedSum` : subadditivity and the fact
  that a signed sum of `L` blow-ups has `γ₂`-norm at most `L`.  This is the easy direction of
  the conjecture above.
* `isBlowUp_iff_gammaTwoLE_one` (main theorem, the `L = 1` case, i.e. Livshits' description
  of *contractive* idempotent Schur multipliers): a boolean matrix satisfies `‖A‖_{γ₂} ≤ 1`
  if and only if it is a blow-up of a partial identity matrix, if and only if it satisfies
  the purely combinatorial rigidity condition `RowRigid`.
* `not_gammaTwoLE_one_triangular`, `gammaTwoLE_two_triangular` : sharpness — the `2 × 2`
  triangular truth matrix has `1 < ‖A‖_{γ₂} ≤ 2` and needs at least two blow-ups.
* `gammaTwoLE_sqrt_of_boolean` : every boolean `m × n` matrix has `‖A‖_{γ₂} ≤ √(min m n)`,
  and is a sum of at most `min m n` blow-ups.
-/

namespace SchurIdempotent

open Finset

variable {m n : ℕ}

/-! ## The factorization norm -/

/-- A `γ₂`-factorization of `A` of size `c`: vectors `x i, y j ∈ ℝ^dim` with
`A i j = ⟪x i, y j⟫` and all squared norms bounded by `c`. -/
structure GammaFactorization (A : Fin m → Fin n → ℝ) (c : ℝ) where
  /-- the number of columns of the factorization -/
  dim : ℕ
  /-- the row vectors -/
  x : Fin m → Fin dim → ℝ
  /-- the column vectors -/
  y : Fin n → Fin dim → ℝ
  x_bound : ∀ i, ∑ t, (x i t) ^ 2 ≤ c
  y_bound : ∀ j, ∑ t, (y j t) ^ 2 ≤ c
  factor : ∀ i j, ∑ t, x i t * y j t = A i j

/-- `GammaTwoLE A c` says that the factorization norm of `A` is at most `c`. -/
def GammaTwoLE (A : Fin m → Fin n → ℝ) (c : ℝ) : Prop :=
  Nonempty (GammaFactorization A c)

/-- Monotonicity in the bound. -/
theorem GammaTwoLE.mono {A : Fin m → Fin n → ℝ} {c d : ℝ} (h : GammaTwoLE A c) (hcd : c ≤ d) :
    GammaTwoLE A d := by
  obtain ⟨F⟩ := h
  exact ⟨{ dim := F.dim, x := F.x, y := F.y,
           x_bound := fun i => (F.x_bound i).trans hcd,
           y_bound := fun j => (F.y_bound j).trans hcd,
           factor := F.factor }⟩

/-- A bound is always nonnegative, provided there is at least one row and one column
(otherwise the statement is vacuous, and indeed `c` may be negative). -/
theorem GammaTwoLE.nonneg_of_row {A : Fin m → Fin n → ℝ} {c : ℝ} (h : GammaTwoLE A c)
    (i : Fin m) : 0 ≤ c := by
  obtain ⟨F⟩ := h
  refine le_trans ?_ (F.x_bound i)
  exact Finset.sum_nonneg fun t _ => sq_nonneg _

/-! ### Cauchy–Schwarz: entries are bounded by the norm -/

theorem abs_entry_le_of_gammaTwoLE {A : Fin m → Fin n → ℝ} {c : ℝ} (h : GammaTwoLE A c)
    (i : Fin m) (j : Fin n) : |A i j| ≤ c := by
  obtain ⟨F⟩ := h
  have hc : 0 ≤ c := GammaTwoLE.nonneg_of_row ⟨F⟩ i
  have hCS : (∑ t, F.x i t * F.y j t) ^ 2
      ≤ (∑ t, (F.x i t) ^ 2) * ∑ t, (F.y j t) ^ 2 :=
    Finset.sum_mul_sq_le_sq_mul_sq _ _ _
  have hx0 : (0:ℝ) ≤ ∑ t, (F.x i t) ^ 2 := Finset.sum_nonneg fun t _ => sq_nonneg _
  have hy0 : (0:ℝ) ≤ ∑ t, (F.y j t) ^ 2 := Finset.sum_nonneg fun t _ => sq_nonneg _
  have hle : (A i j) ^ 2 ≤ c * c := by
    rw [← F.factor i j]
    exact hCS.trans (mul_le_mul (F.x_bound i) (F.y_bound j) hy0 hc)
  nlinarith [abs_nonneg (A i j), sq_abs (A i j), abs_nonneg (A i j)]

/-! ### The asymmetric ("unbalanced") formulation -/

/-- The classical definition of `‖A‖_{γ₂} ≤ c`: there is a factorization `A i j = ⟪x i, y j⟫`
with `max_i ‖x i‖ ≤ r`, `max_j ‖y j‖ ≤ s` and `r * s ≤ c`. -/
def GammaTwoLE' (A : Fin m → Fin n → ℝ) (c : ℝ) : Prop :=
  ∃ (d : ℕ) (x : Fin m → Fin d → ℝ) (y : Fin n → Fin d → ℝ) (r s : ℝ),
    0 ≤ r ∧ 0 ≤ s ∧ r * s ≤ c ∧
    (∀ i, ∑ t, (x i t) ^ 2 ≤ r ^ 2) ∧ (∀ j, ∑ t, (y j t) ^ 2 ≤ s ^ 2) ∧
    (∀ i j, ∑ t, x i t * y j t = A i j)

theorem GammaTwoLE.to_unbalanced {A : Fin m → Fin n → ℝ} {c : ℝ} (hc : 0 ≤ c)
    (h : GammaTwoLE A c) : GammaTwoLE' A c := by
  obtain ⟨F⟩ := h
  refine ⟨F.dim, F.x, F.y, Real.sqrt c, Real.sqrt c, Real.sqrt_nonneg _, Real.sqrt_nonneg _, ?_,
    ?_, ?_, F.factor⟩
  · exact le_of_eq (Real.mul_self_sqrt hc)
  · intro i; rw [Real.sq_sqrt hc]; exact F.x_bound i
  · intro j; rw [Real.sq_sqrt hc]; exact F.y_bound j

/-- The rescaling argument: the asymmetric definition implies the symmetric one. -/
theorem GammaTwoLE.of_unbalanced {A : Fin m → Fin n → ℝ} {c : ℝ} (h : GammaTwoLE' A c) :
    GammaTwoLE A c := by
  obtain ⟨d, x, y, r, s, hr, hs, hrs, hx, hy, hfac⟩ := h
  rcases eq_or_lt_of_le hr with hr0 | hr0
  · -- `r = 0` forces `A = 0`
    refine ⟨{ dim := d, x := fun _ _ => 0, y := fun _ _ => 0,
              x_bound := ?_, y_bound := ?_, factor := ?_ }⟩
    · intro i
      have : (0:ℝ) ≤ c := by
        have h1 : ∑ t, (x i t) ^ 2 ≤ r ^ 2 := hx i
        have : (0:ℝ) ≤ r ^ 2 := sq_nonneg _
        nlinarith [hrs, sq_nonneg r, hs, hr]
      simpa using this
    · intro j
      have : (0:ℝ) ≤ c := by nlinarith [hrs, sq_nonneg r, hs, hr]
      simpa using this
    · intro i j
      have hxi : ∀ t, x i t = 0 := by
        intro t
        have hsum : ∑ t, (x i t) ^ 2 ≤ 0 := by
          have := hx i; rw [← hr0] at this; simpa using this
        have hall := (Finset.sum_eq_zero_iff_of_nonneg
          (fun t (_ : t ∈ (Finset.univ : Finset (Fin d))) => sq_nonneg (x i t))).1
          (le_antisymm hsum (Finset.sum_nonneg fun t _ => sq_nonneg _))
        exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 (hall t (Finset.mem_univ t))
      have : A i j = 0 := by
        rw [← hfac i j]
        exact Finset.sum_eq_zero fun t _ => by rw [hxi t]; ring
      simp [this]
  rcases eq_or_lt_of_le hs with hs0 | hs0
  · refine ⟨{ dim := d, x := fun _ _ => 0, y := fun _ _ => 0,
              x_bound := ?_, y_bound := ?_, factor := ?_ }⟩
    · intro i
      have : (0:ℝ) ≤ c := by nlinarith [hrs, hr0, hs0]
      simpa using this
    · intro j
      have : (0:ℝ) ≤ c := by nlinarith [hrs, hr0, hs0]
      simpa using this
    · intro i j
      have hyj : ∀ t, y j t = 0 := by
        intro t
        have hsum : ∑ t, (y j t) ^ 2 ≤ 0 := by
          have := hy j; rw [← hs0] at this; simpa using this
        have hall := (Finset.sum_eq_zero_iff_of_nonneg
          (fun t (_ : t ∈ (Finset.univ : Finset (Fin d))) => sq_nonneg (y j t))).1
          (le_antisymm hsum (Finset.sum_nonneg fun t _ => sq_nonneg _))
        exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 (hall t (Finset.mem_univ t))
      have : A i j = 0 := by
        rw [← hfac i j]
        exact Finset.sum_eq_zero fun t _ => by rw [hyj t]; ring
      simp [this]
  -- the generic case: rescale by `√(s/r)`
  set a : ℝ := Real.sqrt (s / r) with ha
  have hapos : 0 < a := Real.sqrt_pos.2 (div_pos hs0 hr0)
  have ha2 : a ^ 2 = s / r := Real.sq_sqrt (le_of_lt (div_pos hs0 hr0))
  refine ⟨{ dim := d, x := fun i t => a * x i t, y := fun j t => (1 / a) * y j t,
            x_bound := ?_, y_bound := ?_, factor := ?_ }⟩
  · intro i
    have h1 : ∑ t, (a * x i t) ^ 2 = a ^ 2 * ∑ t, (x i t) ^ 2 := by
      rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun t _ => by ring
    rw [h1, ha2]
    have : s / r * ∑ t, (x i t) ^ 2 ≤ s / r * r ^ 2 :=
      mul_le_mul_of_nonneg_left (hx i) (le_of_lt (div_pos hs0 hr0))
    refine this.trans ?_
    have : s / r * r ^ 2 = r * s := by field_simp
    rw [this]; exact hrs
  · intro j
    have h1 : ∑ t, ((1 / a) * y j t) ^ 2 = (1 / a) ^ 2 * ∑ t, (y j t) ^ 2 := by
      rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun t _ => by ring
    rw [h1]
    have hinv : (1 / a) ^ 2 = r / s := by
      rw [div_pow, one_pow, ha2]
      field_simp
    rw [hinv]
    have : r / s * ∑ t, (y j t) ^ 2 ≤ r / s * s ^ 2 :=
      mul_le_mul_of_nonneg_left (hy j) (le_of_lt (div_pos hr0 hs0))
    refine this.trans ?_
    have : r / s * s ^ 2 = r * s := by field_simp
    rw [this]; exact hrs
  · intro i j
    rw [← hfac i j]
    refine Finset.sum_congr rfl fun t _ => ?_
    field_simp

theorem gammaTwoLE_iff_unbalanced {A : Fin m → Fin n → ℝ} {c : ℝ} (hc : 0 ≤ c) :
    GammaTwoLE A c ↔ GammaTwoLE' A c :=
  ⟨GammaTwoLE.to_unbalanced hc, GammaTwoLE.of_unbalanced⟩

/-! ### Algebraic operations -/

theorem GammaTwoLE.neg {A : Fin m → Fin n → ℝ} {c : ℝ} (h : GammaTwoLE A c) :
    GammaTwoLE (fun i j => -A i j) c := by
  obtain ⟨F⟩ := h
  refine ⟨{ dim := F.dim, x := F.x, y := fun j t => -F.y j t,
            x_bound := F.x_bound, y_bound := ?_, factor := ?_ }⟩
  · intro j; simpa using F.y_bound j
  · intro i j
    have : ∑ t, F.x i t * -F.y j t = -∑ t, F.x i t * F.y j t := by
      rw [← Finset.sum_neg_distrib]; exact Finset.sum_congr rfl fun t _ => by ring
    rw [this, F.factor i j]

/-- Subadditivity of the factorization norm, by concatenating factorizations. -/
theorem GammaTwoLE.add {A B : Fin m → Fin n → ℝ} {c d : ℝ}
    (hA : GammaTwoLE A c) (hB : GammaTwoLE B d) :
    GammaTwoLE (fun i j => A i j + B i j) (c + d) := by
  obtain ⟨F⟩ := hA
  obtain ⟨G⟩ := hB
  refine ⟨{ dim := F.dim + G.dim,
            x := fun i => Fin.append (F.x i) (G.x i),
            y := fun j => Fin.append (F.y j) (G.y j),
            x_bound := ?_, y_bound := ?_, factor := ?_ }⟩
  · intro i
    rw [Fin.sum_univ_add]
    simp only [Fin.append_left, Fin.append_right]
    exact add_le_add (F.x_bound i) (G.x_bound i)
  · intro j
    rw [Fin.sum_univ_add]
    simp only [Fin.append_left, Fin.append_right]
    exact add_le_add (F.y_bound j) (G.y_bound j)
  · intro i j
    rw [Fin.sum_univ_add]
    simp only [Fin.append_left, Fin.append_right]
    rw [F.factor i j, G.factor i j]

/-! ## Blow-ups of identity matrices -/

/-- `A` is a blow-up of a partial identity matrix: after permuting rows and columns it is
block diagonal with all-ones rectangular blocks on the diagonal (rows and columns not
belonging to a block are zero).  Equivalently, rows and columns carry labels and
`A i j = 1` exactly when the labels agree. -/
def IsBlowUp (A : Fin m → Fin n → ℝ) : Prop :=
  ∃ f : Fin m → ℕ, ∃ g : Fin n → ℕ, ∀ i j, A i j = if f i = g j then 1 else 0

/-- Boolean matrices, i.e. those whose Schur multiplier is idempotent. -/
def IsBoolean (A : Fin m → Fin n → ℝ) : Prop := ∀ i j, A i j = 0 ∨ A i j = 1

theorem IsBlowUp.isBoolean {A : Fin m → Fin n → ℝ} (h : IsBlowUp A) : IsBoolean A := by
  obtain ⟨f, g, hfg⟩ := h
  intro i j
  rw [hfg i j]
  by_cases h : f i = g j <;> simp [h]

/-- A blow-up of an identity matrix is a contraction: `‖A‖_{γ₂} ≤ 1`. -/
theorem IsBlowUp.gammaTwoLE_one {A : Fin m → Fin n → ℝ} (h : IsBlowUp A) :
    GammaTwoLE A 1 := by
  obtain ⟨f, g, hfg⟩ := h
  classical
  -- put all labels inside `Fin K`
  set K : ℕ :=
    ((Finset.univ.image f) ∪ (Finset.univ.image g)).sup id + 1 with hK
  have hfK : ∀ i, f i < K := by
    intro i
    have : f i ≤ ((Finset.univ.image f) ∪ (Finset.univ.image g)).sup id := by
      refine Finset.le_sup (f := id) ?_
      exact Finset.mem_union_left _ (Finset.mem_image_of_mem f (Finset.mem_univ i))
    omega
  have hgK : ∀ j, g j < K := by
    intro j
    have : g j ≤ ((Finset.univ.image f) ∪ (Finset.univ.image g)).sup id := by
      refine Finset.le_sup (f := id) ?_
      exact Finset.mem_union_right _ (Finset.mem_image_of_mem g (Finset.mem_univ j))
    omega
  set F : Fin m → Fin K := fun i => ⟨f i, hfK i⟩ with hF
  set G : Fin n → Fin K := fun j => ⟨g j, hgK j⟩ with hG
  refine ⟨{ dim := K,
            x := fun i t => if t = F i then 1 else 0,
            y := fun j t => if t = G j then 1 else 0,
            x_bound := ?_, y_bound := ?_, factor := ?_ }⟩
  · intro i
    have : ∑ t : Fin K, (if t = F i then (1:ℝ) else 0) ^ 2
        = ∑ t : Fin K, (if t = F i then (1:ℝ) else 0) := by
      refine Finset.sum_congr rfl fun t _ => ?_
      by_cases h : t = F i <;> simp [h]
    rw [this]
    simp
  · intro j
    have : ∑ t : Fin K, (if t = G j then (1:ℝ) else 0) ^ 2
        = ∑ t : Fin K, (if t = G j then (1:ℝ) else 0) := by
      refine Finset.sum_congr rfl fun t _ => ?_
      by_cases h : t = G j <;> simp [h]
    rw [this]
    simp
  · intro i j
    have hmul : ∀ t : Fin K,
        (if t = F i then (1:ℝ) else 0) * (if t = G j then (1:ℝ) else 0)
          = if t = F i then (if t = G j then (1:ℝ) else 0) else 0 := by
      intro t; by_cases h : t = F i <;> simp [h]
    rw [Finset.sum_congr rfl fun t _ => hmul t]
    rw [Finset.sum_ite_eq' Finset.univ (F i) (fun t => if t = G j then (1:ℝ) else 0)]
    simp only [Finset.mem_univ, if_true]
    rw [hfg i j]
    have : (F i = G j) ↔ (f i = g j) := by
      simp [hF, hG, Fin.ext_iff]
    by_cases h : f i = g j
    · simp [this.2 h, h]
    · have hne : ¬ F i = G j := fun hc => h (this.1 hc)
      simp [h, hne]

/-! ## The combinatorial rigidity condition -/

/-- `A` is *row rigid* if two rows carrying a `1` in a common column are equal. -/
def RowRigid (A : Fin m → Fin n → ℝ) : Prop :=
  ∀ i i' : Fin m, ∀ j : Fin n, A i j = 1 → A i' j = 1 → ∀ j', A i j' = A i' j'

theorem IsBlowUp.rowRigid {A : Fin m → Fin n → ℝ} (h : IsBlowUp A) : RowRigid A := by
  obtain ⟨f, g, hfg⟩ := h
  intro i i' j hij hi'j j'
  have h1 : f i = g j := by
    by_contra hc
    rw [hfg i j, if_neg hc] at hij
    norm_num at hij
  have h2 : f i' = g j := by
    by_contra hc
    rw [hfg i' j, if_neg hc] at hi'j
    norm_num at hi'j
  rw [hfg i j', hfg i' j', h1, h2]

/-- Contractive factorizations are rigid: this is the Cauchy–Schwarz equality case.
If `A i j = 1` and `‖A‖_{γ₂} ≤ 1`, then the two factorization vectors coincide. -/
theorem rowRigid_of_gammaTwoLE_one {A : Fin m → Fin n → ℝ} (h : GammaTwoLE A 1) :
    RowRigid A := by
  obtain ⟨F⟩ := h
  -- key: `A i j = 1 → F.x i = F.y j`
  have key : ∀ (i : Fin m) (j : Fin n), A i j = 1 → ∀ t, F.x i t = F.y j t := by
    intro i j hij t
    have hxy : ∑ t, F.x i t * F.y j t = 1 := by rw [F.factor i j, hij]
    have hsum : ∑ t, (F.x i t - F.y j t) ^ 2
        = (∑ t, (F.x i t) ^ 2) + (∑ t, (F.y j t) ^ 2) - 2 * ∑ t, F.x i t * F.y j t := by
      rw [Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun t _ => by ring
    have hle : ∑ t, (F.x i t - F.y j t) ^ 2 ≤ 0 := by
      rw [hsum, hxy]
      have := F.x_bound i
      have := F.y_bound j
      linarith
    have hzero : ∑ t, (F.x i t - F.y j t) ^ 2 = 0 :=
      le_antisymm hle (Finset.sum_nonneg fun t _ => sq_nonneg _)
    have hall := (Finset.sum_eq_zero_iff_of_nonneg
      (fun t (_ : t ∈ (Finset.univ : Finset (Fin F.dim))) => sq_nonneg (F.x i t - F.y j t))).1
      hzero t (Finset.mem_univ t)
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hall
    linarith
  intro i i' j hij hi'j j'
  have h1 := key i j hij
  have h2 := key i' j hi'j
  rw [← F.factor i j', ← F.factor i' j']
  exact Finset.sum_congr rfl fun t _ => by rw [h1 t, ← h2 t]

/-! ### From rigidity to a blow-up structure

We build explicit labels: a row is labelled by the least column in which it has a `1`
(and by a fresh label if it is a zero row); a column is labelled by the least column that
shares a `1`-row with it (and by a fresh label if it is a zero column).  -/

/-- The label of row `i`: the least column index carrying a `1`, or a fresh label. -/
noncomputable def rowLabel (A : Fin m → Fin n → ℝ) (i : Fin m) : ℕ :=
  sInf ({k | ∃ h : k < n, A i ⟨k, h⟩ = 1} ∪ {n + (i : ℕ)})

/-- The label of column `j`: the least column index sharing a `1`-row with `j`, or a fresh
label. -/
noncomputable def colLabel (A : Fin m → Fin n → ℝ) (j : Fin n) : ℕ :=
  sInf ({k | ∃ h : k < n, ∃ i : Fin m, A i j = 1 ∧ A i ⟨k, h⟩ = 1} ∪ {n + m + (j : ℕ)})

theorem rowLabel_mem (A : Fin m → Fin n → ℝ) (i : Fin m) :
    rowLabel A i ∈ ({k | ∃ h : k < n, A i ⟨k, h⟩ = 1} ∪ {n + (i : ℕ)} : Set ℕ) :=
  Nat.sInf_mem ⟨n + (i : ℕ), Or.inr rfl⟩

theorem colLabel_mem (A : Fin m → Fin n → ℝ) (j : Fin n) :
    colLabel A j ∈
      ({k | ∃ h : k < n, ∃ i : Fin m, A i j = 1 ∧ A i ⟨k, h⟩ = 1} ∪ {n + m + (j : ℕ)} : Set ℕ) :=
  Nat.sInf_mem ⟨n + m + (j : ℕ), Or.inr rfl⟩

theorem rowLabel_le_of_one {A : Fin m → Fin n → ℝ} {i : Fin m} {j : Fin n} (h : A i j = 1) :
    rowLabel A i ≤ (j : ℕ) :=
  Nat.sInf_le (Or.inl ⟨j.isLt, by simpa using h⟩)

theorem rowLabel_le_fresh (A : Fin m → Fin n → ℝ) (i : Fin m) : rowLabel A i ≤ n + (i : ℕ) :=
  Nat.sInf_le (Or.inr rfl)

theorem rowLabel_one {A : Fin m → Fin n → ℝ} (i : Fin m) (h : rowLabel A i < n) :
    A i ⟨rowLabel A i, h⟩ = 1 := by
  rcases rowLabel_mem A i with hmem | hmem
  · obtain ⟨h', hone⟩ := hmem
    exact hone
  · have : rowLabel A i = n + (i : ℕ) := hmem
    omega

/-- On a nonzero column, the column label agrees with the label of any row hitting it. -/
theorem colLabel_eq_rowLabel {A : Fin m → Fin n → ℝ} (hR : RowRigid A) {i₀ : Fin m} {j : Fin n}
    (h0 : A i₀ j = 1) : colLabel A j = rowLabel A i₀ := by
  have hlt : rowLabel A i₀ < n := lt_of_le_of_lt (rowLabel_le_of_one h0) j.isLt
  have hone : A i₀ ⟨rowLabel A i₀, hlt⟩ = 1 := rowLabel_one i₀ hlt
  have hle : colLabel A j ≤ rowLabel A i₀ := Nat.sInf_le (Or.inl ⟨hlt, i₀, h0, hone⟩)
  have hglt : colLabel A j < n := lt_of_le_of_lt hle hlt
  rcases colLabel_mem A j with hmem | hmem
  · obtain ⟨h', i₁, hi₁j, hi₁k⟩ := hmem
    have hrow := hR i₁ i₀ j hi₁j h0
    have hone' : A i₀ ⟨colLabel A j, h'⟩ = 1 := by rw [← hrow]; exact hi₁k
    have : rowLabel A i₀ ≤ colLabel A j := Nat.sInf_le (Or.inl ⟨h', hone'⟩)
    omega
  · have : colLabel A j = n + m + (j : ℕ) := hmem
    omega

/-- On a zero column, the column label is a fresh label. -/
theorem colLabel_of_zero_col {A : Fin m → Fin n → ℝ} {j : Fin n} (h : ∀ i, A i j ≠ 1) :
    colLabel A j = n + m + (j : ℕ) := by
  rcases colLabel_mem A j with hmem | hmem
  · obtain ⟨h', i₁, hi₁, _⟩ := hmem
    exact absurd hi₁ (h i₁)
  · exact hmem

/-- **Rigidity implies blow-up structure.**  A boolean matrix in which any two rows sharing a
`1` in some column are equal is, up to permutations, a blow-up of a partial identity matrix. -/
theorem IsBlowUp.of_rowRigid {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) (hR : RowRigid A) :
    IsBlowUp A := by
  classical
  refine ⟨rowLabel A, colLabel A, ?_⟩
  intro i j
  rcases hA i j with h0 | h1
  · have hne : rowLabel A i ≠ colLabel A j := by
      by_cases hcol : ∃ i₀, A i₀ j = 1
      · obtain ⟨i₀, hi₀⟩ := hcol
        have hgj := colLabel_eq_rowLabel hR hi₀
        intro heq
        have hfi₀ : rowLabel A i₀ < n := lt_of_le_of_lt (rowLabel_le_of_one hi₀) j.isLt
        have hff : rowLabel A i = rowLabel A i₀ := by omega
        have hfi : rowLabel A i < n := by omega
        have hone : A i ⟨rowLabel A i, hfi⟩ = 1 := rowLabel_one i hfi
        have heqfin : (⟨rowLabel A i, hfi⟩ : Fin n) = ⟨rowLabel A i₀, hfi₀⟩ := by
          exact Fin.val_injective hff
        have hone₀ : A i₀ ⟨rowLabel A i, hfi⟩ = 1 := by
          rw [heqfin]; exact rowLabel_one i₀ hfi₀
        have := hR i i₀ ⟨rowLabel A i, hfi⟩ hone hone₀ j
        rw [this, hi₀] at h0
        norm_num at h0
      · push_neg at hcol
        have hgj : colLabel A j = n + m + (j : ℕ) := colLabel_of_zero_col hcol
        have h1 := rowLabel_le_fresh A i
        have h2 := i.isLt
        omega
    rw [if_neg hne, h0]
  · have heq : rowLabel A i = colLabel A j := (colLabel_eq_rowLabel hR h1).symm
    rw [if_pos heq, h1]

/-- **Main theorem (the `L = 1` case of the conjecture; Livshits' characterisation of
contractive idempotent Schur multipliers).**  For a boolean matrix `A` the following are
equivalent: `A` is a blow-up of a partial identity matrix; `‖A‖_{γ₂} ≤ 1`; `A` is row rigid. -/
theorem isBlowUp_iff_gammaTwoLE_one {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    IsBlowUp A ↔ GammaTwoLE A 1 :=
  ⟨IsBlowUp.gammaTwoLE_one, fun h => IsBlowUp.of_rowRigid hA (rowRigid_of_gammaTwoLE_one h)⟩

theorem gammaTwoLE_one_iff_rowRigid {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    GammaTwoLE A 1 ↔ RowRigid A :=
  ⟨rowRigid_of_gammaTwoLE_one, fun h => (IsBlowUp.of_rowRigid hA h).gammaTwoLE_one⟩

/-- Purely combinatorial form of the characterisation: a boolean matrix is a blow-up of a
partial identity matrix iff any two rows sharing a `1` in a common column are equal. -/
theorem isBlowUp_iff_rowRigid {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    IsBlowUp A ↔ RowRigid A :=
  ⟨IsBlowUp.rowRigid, IsBlowUp.of_rowRigid hA⟩


/-! ## Signed sums of blow-ups: the easy direction of the conjecture -/

theorem GammaTwoLE.congr {A A' : Fin m → Fin n → ℝ} {c c' : ℝ} (hA : ∀ i j, A i j = A' i j)
    (hc : c = c') (h : GammaTwoLE A c) : GammaTwoLE A' c' := by
  obtain ⟨F⟩ := h
  subst hc
  exact ⟨{ dim := F.dim, x := F.x, y := F.y, x_bound := F.x_bound, y_bound := F.y_bound,
           factor := fun i j => (F.factor i j).trans (hA i j) }⟩

/-- Subadditivity for finite sums of matrices. -/
theorem gammaTwoLE_sum : ∀ (L : ℕ) (C : Fin L → Fin m → Fin n → ℝ) (c : Fin L → ℝ),
    (∀ l, GammaTwoLE (C l) (c l)) → GammaTwoLE (fun i j => ∑ l, C l i j) (∑ l, c l) := by
  intro L
  induction L with
  | zero =>
      intro C c _
      exact ⟨{ dim := 0, x := fun _ _ => 0, y := fun _ _ => 0,
               x_bound := by simp, y_bound := by simp, factor := by simp }⟩
  | succ L ih =>
      intro C c h
      have h1 := ih (fun l => C l.castSucc) (fun l => c l.castSucc) (fun l => h _)
      have h2 := h (Fin.last L)
      refine GammaTwoLE.congr (A := fun i j => (∑ l : Fin L, C l.castSucc i j) + C (Fin.last L) i j)
        (c := (∑ l : Fin L, c l.castSucc) + c (Fin.last L)) ?_ ?_ (h1.add h2)
      · intro i j; rw [Fin.sum_univ_castSucc]
      · rw [Fin.sum_univ_castSucc]

/-- `A` is a signed sum of `L` blow-ups of identity matrices. -/
def IsSignedSumOfBlowUps (A : Fin m → Fin n → ℝ) (L : ℕ) : Prop :=
  ∃ (B : Fin L → Fin m → Fin n → ℝ) (e : Fin L → ℝ),
    (∀ l, IsBlowUp (B l)) ∧ (∀ l, e l = 1 ∨ e l = -1) ∧
    ∀ i j, A i j = ∑ l, e l * B l i j

/-- **Easy direction of the conjecture.**  A signed sum of `L` blow-ups of identity matrices
has factorization norm at most `L`. -/
theorem gammaTwoLE_of_signedSum {A : Fin m → Fin n → ℝ} {L : ℕ}
    (h : IsSignedSumOfBlowUps A L) : GammaTwoLE A (L : ℝ) := by
  obtain ⟨B, e, hB, he, hA⟩ := h
  have hterm : ∀ l, GammaTwoLE (fun i j => e l * B l i j) 1 := by
    intro l
    rcases he l with h1 | h1
    · exact GammaTwoLE.congr (fun i j => by rw [h1]; ring) rfl (hB l).gammaTwoLE_one
    · exact GammaTwoLE.congr (fun i j => by rw [h1]; ring) rfl (hB l).gammaTwoLE_one.neg
  have := gammaTwoLE_sum L (fun l i j => e l * B l i j) (fun _ => 1) hterm
  refine GammaTwoLE.congr (fun i j => (hA i j).symm) ?_ this
  simp

/-! ## General upper bounds for boolean matrices -/

theorem GammaTwoLE.transpose {A : Fin m → Fin n → ℝ} {c : ℝ} (h : GammaTwoLE A c) :
    GammaTwoLE (fun j i => A i j) c := by
  obtain ⟨F⟩ := h
  refine ⟨{ dim := F.dim, x := F.y, y := F.x, x_bound := F.y_bound, y_bound := F.x_bound,
            factor := ?_ }⟩
  intro j i
  rw [← F.factor i j]
  exact Finset.sum_congr rfl fun t _ => mul_comm _ _

/-- Every boolean `m × n` matrix has factorization norm at most `√m`.
(Factor `A` as `I · A`: the rows of the left factor are unit vectors, the columns of the
right factor have squared norm at most `m`.) -/
theorem gammaTwoLE_sqrt_of_boolean {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    GammaTwoLE A (Real.sqrt m) := by
  refine GammaTwoLE.of_unbalanced ⟨m, fun i t => if t = i then 1 else 0, fun j t => A t j,
    1, Real.sqrt m, zero_le_one, Real.sqrt_nonneg _, by rw [one_mul], ?_, ?_, ?_⟩
  · intro i
    have : ∑ t : Fin m, (if t = i then (1:ℝ) else 0) ^ 2
        = ∑ t : Fin m, (if t = i then (1:ℝ) else 0) := by
      refine Finset.sum_congr rfl fun t _ => ?_
      by_cases h : t = i <;> simp [h]
    rw [this]
    simp
  · intro j
    rw [Real.sq_sqrt (by positivity : (0:ℝ) ≤ (m:ℝ))]
    have hbd : ∀ t : Fin m, (A t j) ^ 2 ≤ 1 := by
      intro t; rcases hA t j with h | h <;> rw [h] <;> norm_num
    calc ∑ t : Fin m, (A t j) ^ 2 ≤ ∑ _t : Fin m, (1:ℝ) :=
          Finset.sum_le_sum fun t _ => hbd t
      _ = (m : ℝ) := by simp
  · intro i j
    have : ∀ t : Fin m, (if t = i then (1:ℝ) else 0) * A t j
        = if t = i then A t j else 0 := by
      intro t; by_cases h : t = i <;> simp [h]
    rw [Finset.sum_congr rfl fun t _ => this t]
    simp

/-- Dually, every boolean `m × n` matrix has factorization norm at most `√n`. -/
theorem gammaTwoLE_sqrt_col_of_boolean {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    GammaTwoLE A (Real.sqrt n) := by
  have hAT : IsBoolean (fun j i => A i j) := fun j i => hA i j
  have := (gammaTwoLE_sqrt_of_boolean hAT).transpose
  exact GammaTwoLE.congr (fun i j => rfl) rfl this

/-- A matrix supported on a single row is a blow-up of a partial identity matrix. -/
theorem isBlowUp_singleRow {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) (l : Fin m) :
    IsBlowUp (fun i j => if i = l then A i j else 0) := by
  classical
  refine ⟨fun i => if i = l then 0 else 1 + (i : ℕ),
          fun j => if A l j = 1 then 0 else 1 + m + (j : ℕ), ?_⟩
  intro i j
  show (if i = l then A i j else 0)
      = if (if i = l then (0:ℕ) else 1 + (i:ℕ)) = (if A l j = 1 then 0 else 1 + m + (j:ℕ))
        then (1:ℝ) else 0
  have hlt : (i : ℕ) < m := i.isLt
  by_cases hi : i = l
  · have e1 : (if i = l then A i j else 0) = A i j := if_pos hi
    have e2 : (if i = l then (0:ℕ) else 1 + (i:ℕ)) = 0 := if_pos hi
    rw [e1, e2]
    by_cases hj : A l j = 1
    · rw [if_pos hj, if_pos rfl, hi]
      exact hj
    · rw [if_neg hj, if_neg (by omega : ¬ ((0:ℕ) = 1 + m + (j:ℕ)))]
      rcases hA i j with h0 | h1
      · exact h0
      · exact absurd (hi ▸ h1) hj
  · have e1 : (if i = l then A i j else 0) = (0:ℝ) := if_neg hi
    have e2 : (if i = l then (0:ℕ) else 1 + (i:ℕ)) = 1 + (i:ℕ) := if_neg hi
    rw [e1, e2]
    by_cases hj : A l j = 1
    · rw [if_pos hj, if_neg (by omega : ¬ (1 + (i:ℕ) = 0))]
    · rw [if_neg hj, if_neg (by omega : ¬ (1 + (i:ℕ) = 1 + m + (j:ℕ)))]

/-- **Every boolean matrix is a (positive) sum of `m` blow-ups**, one for each row. -/
theorem isSignedSumOfBlowUps_of_boolean {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    IsSignedSumOfBlowUps A m := by
  classical
  refine ⟨fun l i j => if i = l then A i j else 0, fun _ => 1,
    fun l => isBlowUp_singleRow hA l, fun _ => Or.inl rfl, ?_⟩
  intro i j
  have : ∀ l : Fin m, (1:ℝ) * (if i = l then A i j else 0) = if l = i then A i j else 0 := by
    intro l
    by_cases h : i = l
    · subst h; simp
    · have h' : ¬ (l = i) := fun hc => h hc.symm
      simp [h, h']
  rw [Finset.sum_congr rfl fun l _ => this l]
  simp

/-! ## Sharpness: the `2 × 2` triangular truth matrix -/

/-- The `2 × 2` triangular truth matrix `[[1,1],[1,0]]`. -/
def tri2 : Fin 2 → Fin 2 → ℝ := ![![1, 1], ![1, 0]]

theorem tri2_isBoolean : IsBoolean tri2 := by
  intro i j
  fin_cases i <;> fin_cases j <;> simp [tri2]

theorem tri2_not_rowRigid : ¬ RowRigid tri2 := by
  intro h
  have h1 : tri2 0 0 = 1 := by simp [tri2]
  have h2 : tri2 1 0 = 1 := by simp [tri2]
  have := h 0 1 0 h1 h2 1
  simp [tri2] at this

/-- The triangular matrix is not a blow-up of an identity matrix: one blow-up does not
suffice. -/
theorem tri2_not_isBlowUp : ¬ IsBlowUp tri2 := fun h => tri2_not_rowRigid h.rowRigid

/-- Consequently its factorization norm exceeds `1`. -/
theorem tri2_not_gammaTwoLE_one : ¬ GammaTwoLE tri2 1 := by
  intro h
  exact tri2_not_isBlowUp ((isBlowUp_iff_gammaTwoLE_one tri2_isBoolean).2 h)

/-- But two blow-ups suffice: `[[1,1],[1,0]] = [[1,1],[1,1]] - [[0,0],[0,1]]`. -/
theorem tri2_isSignedSumOfBlowUps : IsSignedSumOfBlowUps tri2 2 := by
  classical
  refine ⟨![fun _ _ => (1:ℝ), fun i j => if i = 1 ∧ j = 1 then (1:ℝ) else 0], ![1, -1], ?_, ?_, ?_⟩
  · intro l
    fin_cases l
    · exact ⟨fun _ => 0, fun _ => 0, fun i j => by simp⟩
    · refine ⟨fun i => if i = 1 then 0 else 2, fun j => if j = 1 then 0 else 3, ?_⟩
      intro i j
      fin_cases i <;> fin_cases j <;> norm_num
  · intro l; fin_cases l
    · exact Or.inl rfl
    · exact Or.inr rfl
  · intro i j
    fin_cases i <;> fin_cases j <;> simp [tri2, Fin.sum_univ_succ]

theorem tri2_gammaTwoLE_two : GammaTwoLE tri2 2 := by
  have := gammaTwoLE_of_signedSum tri2_isSignedSumOfBlowUps
  exact GammaTwoLE.congr (fun i j => rfl) (by norm_num) this

/-! ## Schur multipliers -/

/-- The Schur (Hadamard) multiplier associated with `A`. -/
def schur (A B : Fin m → Fin n → ℝ) : Fin m → Fin n → ℝ := fun i j => A i j * B i j

/-- A Schur multiplier is idempotent exactly when its symbol is a boolean matrix. -/
theorem schur_idempotent_iff_isBoolean (A : Fin m → Fin n → ℝ) :
    (∀ B, schur A (schur A B) = schur A B) ↔ IsBoolean A := by
  constructor
  · intro h i j
    have := congrFun (congrFun (h (fun _ _ => 1)) i) j
    simp only [schur, mul_one] at this
    have hfac : A i j * (A i j - 1) = 0 := by nlinarith [this]
    rcases mul_eq_zero.1 hfac with h0 | h1
    · exact Or.inl h0
    · exact Or.inr (by linarith)
  · intro h B
    funext i j
    simp only [schur]
    rcases h i j with h0 | h1
    · rw [h0]; ring
    · rw [h1]; ring

/-- **Contractive idempotent Schur multipliers are exactly the blow-ups of identity
matrices.**  (Livshits' theorem, in the `γ₂` formulation.) -/
theorem contractive_idempotent_iff_isBlowUp (A : Fin m → Fin n → ℝ) :
    ((∀ B, schur A (schur A B) = schur A B) ∧ GammaTwoLE A 1) ↔ IsBlowUp A := by
  constructor
  · rintro ⟨hidem, hcon⟩
    exact (isBlowUp_iff_gammaTwoLE_one ((schur_idempotent_iff_isBoolean A).1 hidem)).2 hcon
  · intro h
    exact ⟨(schur_idempotent_iff_isBoolean A).2 h.isBoolean, h.gammaTwoLE_one⟩


end SchurIdempotent