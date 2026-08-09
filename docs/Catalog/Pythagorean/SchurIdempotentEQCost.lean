import Pythagorean.SchurIdempotentGap

/-!
# The blow-up number `eqCost` and the conjecture on idempotent Schur multipliers

The conjecture discussed in the literature says: *a boolean matrix `A` with
`‖A‖_{γ₂} ≤ γ` is a signed sum of `L` blow-ups of identity matrices, with `L` depending only
on `γ`*.  This file introduces the quantity `L` itself,

`eqCost A = ⨅ {L | A is a signed sum of L blow-ups}`,

records its basic properties, states the conjecture formally as a `Prop`, and proves it
outright in the regime below the gap constant `2√3/3` (with `L = 1`).

`eqCost` is exactly the number of *equality queries* `f l i = g l j` needed to compute `A` as
a signed combination — see `isSignedSumOfBlowUps_iff_equalityQueries` — which is the link
with the complexity class of communication problems with equality oracles.

Main results:

* `zero_isBlowUp`, `IsSignedSumOfBlowUps.succ` : padding a decomposition with zero blocks.
* `isSignedSumOfBlowUps_eqCost` : the infimum is attained (for boolean matrices).
* `gammaTwoLE_eqCost` : `‖A‖_{γ₂} ≤ eqCost A`.
* `eqCost_le_card_rows` : `eqCost A ≤ m` for a boolean `m × n` matrix.
* `eqCost_le_one_iff` : `eqCost A ≤ 1` iff `A` is a blow-up of a partial identity matrix.
* `eqCost_le_one_of_lt_gap` : **the conjecture holds, with `L = 1`, for every `γ < 2√3/3`.**
* `isSignedSumOfBlowUps_iff_equalityQueries` : the decomposition is literally a signed
  combination of `L` equality tests.
-/

namespace SchurIdempotent

open Finset

variable {m n : ℕ}

/-! ## Padding decompositions -/

/-- The zero matrix is a blow-up of a partial identity matrix (all labels distinct). -/
theorem zero_isBlowUp : IsBlowUp (fun (_ : Fin m) (_ : Fin n) => (0:ℝ)) := by
  refine ⟨fun i => (i : ℕ), fun j => n + m + (j : ℕ), ?_⟩
  intro i j
  have hi : (i : ℕ) < m := i.isLt
  have hne : ¬ ((i : ℕ) = n + m + (j : ℕ)) := by omega
  rw [if_neg hne]

theorem zero_isSignedSumOfBlowUps :
    IsSignedSumOfBlowUps (fun (_ : Fin m) (_ : Fin n) => (0:ℝ)) 1 := by
  refine ⟨fun _ _ _ => 0, fun _ => 1, fun _ => zero_isBlowUp, fun _ => Or.inl rfl, ?_⟩
  intro i j
  simp

/-- A decomposition into `L` blow-ups is also one into `L + 1` blow-ups. -/
theorem IsSignedSumOfBlowUps.succ {A : Fin m → Fin n → ℝ} {L : ℕ}
    (h : IsSignedSumOfBlowUps A L) : IsSignedSumOfBlowUps A (L + 1) := by
  obtain ⟨B, e, hB, he, hA⟩ := h
  refine ⟨Fin.snoc B (fun _ _ => 0), Fin.snoc e 1, ?_, ?_, ?_⟩
  · intro l
    refine Fin.lastCases ?_ (fun l => ?_) l
    · rw [Fin.snoc_last]; exact zero_isBlowUp
    · rw [Fin.snoc_castSucc]; exact hB l
  · intro l
    refine Fin.lastCases ?_ (fun l => ?_) l
    · rw [Fin.snoc_last]; exact Or.inl rfl
    · rw [Fin.snoc_castSucc]; exact he l
  · intro i j
    rw [Fin.sum_univ_castSucc]
    simp only [Fin.snoc_castSucc, Fin.snoc_last]
    rw [hA i j]
    ring

theorem IsSignedSumOfBlowUps.mono {A : Fin m → Fin n → ℝ} {L L' : ℕ} (hLL : L ≤ L')
    (h : IsSignedSumOfBlowUps A L) : IsSignedSumOfBlowUps A L' := by
  revert hLL
  induction L' with
  | zero =>
      intro h0
      have : L = 0 := Nat.le_zero.1 h0
      subst this
      exact h
  | succ k ih =>
      intro h1
      rcases Nat.lt_or_ge L (k + 1) with hlt | hge
      · exact (ih (by omega)).succ
      · have hLk : L = k + 1 := le_antisymm h1 hge
        subst hLk
        exact h

/-! ## The blow-up number -/

/-- The least number of blow-ups of identity matrices needed to write `A` as a signed sum
(`0` if there is none, which never happens for boolean matrices). -/
noncomputable def eqCost (A : Fin m → Fin n → ℝ) : ℕ :=
  sInf {L | IsSignedSumOfBlowUps A L}

theorem eqCost_le {A : Fin m → Fin n → ℝ} {L : ℕ} (h : IsSignedSumOfBlowUps A L) :
    eqCost A ≤ L :=
  Nat.sInf_le h

theorem isSignedSumOfBlowUps_eqCost {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    IsSignedSumOfBlowUps A (eqCost A) := by
  have hne : {L | IsSignedSumOfBlowUps A L}.Nonempty := ⟨m, isSignedSumOfBlowUps_of_boolean hA⟩
  exact Nat.sInf_mem hne

theorem eqCost_le_card_rows {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) : eqCost A ≤ m :=
  eqCost_le (isSignedSumOfBlowUps_of_boolean hA)

/-- The factorization norm is at most the blow-up number. -/
theorem gammaTwoLE_eqCost {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    GammaTwoLE A (eqCost A : ℝ) :=
  gammaTwoLE_of_signedSum (isSignedSumOfBlowUps_eqCost hA)

/-- A boolean matrix needs at most one blow-up exactly when it is one. -/
theorem eqCost_le_one_iff {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    eqCost A ≤ 1 ↔ IsBlowUp A := by
  constructor
  · intro h
    have hmem : IsSignedSumOfBlowUps A 1 :=
      (isSignedSumOfBlowUps_eqCost hA).mono h
    obtain ⟨B, e, hB, he, hA'⟩ := hmem
    have hsum : ∀ i j, A i j = e 0 * B 0 i j := by
      intro i j
      rw [hA' i j]
      simp
    rcases he 0 with h1 | h1
    · have : ∀ i j, A i j = B 0 i j := by
        intro i j; rw [hsum i j, h1, one_mul]
      obtain ⟨f, g, hfg⟩ := hB 0
      exact ⟨f, g, fun i j => by rw [this i j]; exact hfg i j⟩
    · -- `A = -B` with `A` boolean and `B` boolean forces `A = 0`
      have hzero : ∀ i j, A i j = 0 := by
        intro i j
        have hb := (hB 0).isBoolean i j
        have := hsum i j
        rw [h1] at this
        rcases hA i j with h0 | hone
        · exact h0
        · rcases hb with hb' | hb' <;> rw [hb'] at this <;> linarith
      obtain ⟨f, g, hfg⟩ := (zero_isBlowUp (m := m) (n := n))
      exact ⟨f, g, fun i j => by rw [hzero i j]; exact hfg i j⟩
  · intro h
    exact eqCost_le ⟨fun _ => A, fun _ => 1, fun _ => h, fun _ => Or.inl rfl, fun i j => by simp⟩

/-! ## The conjecture, and the regime where it is proved -/

/-- **Formal statement of the conjecture** on idempotent Schur multipliers: the number of
blow-ups needed is bounded by a function of the factorization norm alone, uniformly in the
size of the matrix.  (Stated here, not proved.) -/
def IdempotentSchurConjecture : Prop :=
  ∀ γ : ℝ, ∃ L : ℕ, ∀ (m n : ℕ) (A : Fin m → Fin n → ℝ),
    IsBoolean A → GammaTwoLE A γ → eqCost A ≤ L

/-- **The conjecture holds with `L = 1` below the gap constant.**  Every boolean matrix with
factorization norm `< 2√3/3` is a single blow-up. -/
theorem eqCost_le_one_of_lt_gap {A : Fin m → Fin n → ℝ} {c : ℝ} (hA : IsBoolean A)
    (h : GammaTwoLE A c) (hc : c < 2 * Real.sqrt 3 / 3) : eqCost A ≤ 1 :=
  (eqCost_le_one_iff hA).2 (gammaTwo_gap hA h hc)

/-- Restated: for every `γ < 2√3/3` the conjecture's conclusion holds with `L = 1`, uniformly
in the size of the matrix. -/
theorem idempotentSchurConjecture_below_gap (γ : ℝ) (hγ : γ < 2 * Real.sqrt 3 / 3) :
    ∀ (m n : ℕ) (A : Fin m → Fin n → ℝ), IsBoolean A → GammaTwoLE A γ → eqCost A ≤ 1 :=
  fun _ _ _ hA h => eqCost_le_one_of_lt_gap hA h hγ

/-! ## Equality queries -/

/-- A signed sum of `L` blow-ups is exactly a signed combination of `L` equality tests
`f l i = g l j`: this is the bridge to communication protocols with an equality oracle. -/
theorem isSignedSumOfBlowUps_iff_equalityQueries {A : Fin m → Fin n → ℝ} {L : ℕ} :
    IsSignedSumOfBlowUps A L ↔
      ∃ (f : Fin L → Fin m → ℕ) (g : Fin L → Fin n → ℕ) (e : Fin L → ℝ),
        (∀ l, e l = 1 ∨ e l = -1) ∧
        ∀ i j, A i j = ∑ l, e l * (if f l i = g l j then 1 else 0) := by
  classical
  constructor
  · rintro ⟨B, e, hB, he, hA⟩
    choose f g hfg using hB
    refine ⟨f, g, e, he, fun i j => ?_⟩
    rw [hA i j]
    exact Finset.sum_congr rfl fun l _ => by rw [← hfg l i j]
  · rintro ⟨f, g, e, he, hA⟩
    exact ⟨fun l i j => if f l i = g l j then 1 else 0, e,
      fun l => ⟨f l, g l, fun i j => rfl⟩, he, hA⟩

/-- Every boolean matrix is computed by at most `m` equality queries. -/
theorem exists_equalityQueries_of_boolean {A : Fin m → Fin n → ℝ} (hA : IsBoolean A) :
    ∃ (f : Fin m → Fin m → ℕ) (g : Fin m → Fin n → ℕ) (e : Fin m → ℝ),
      (∀ l, e l = 1 ∨ e l = -1) ∧
      ∀ i j, A i j = ∑ l, e l * (if f l i = g l j then 1 else 0) :=
  isSignedSumOfBlowUps_iff_equalityQueries.1 (isSignedSumOfBlowUps_of_boolean hA)

end SchurIdempotent