import Pythagorean.SchurIdempotentGammaTwo

/-!
# Algebraic closure properties of blow-ups and of the factorization norm

Composition of Schur multipliers corresponds to the Hadamard (entrywise) product of their
symbols.  This file proves that the objects appearing in the conjecture on idempotent Schur
multipliers are stable under the natural algebraic operations:

* `GammaTwoLE.hadamard` : submultiplicativity `‖A ⊙ B‖_{γ₂} ≤ ‖A‖_{γ₂} ‖B‖_{γ₂}`
  (tensoring the two factorizations).
* `IsBlowUp.hadamard` : blow-ups of identity matrices are stable under Hadamard products,
  i.e. **contractive idempotent Schur multipliers are closed under composition**.
* `IsSignedSumOfBlowUps.add`, `.neg`, `.hadamard`, `.complement` : the class of finite signed
  sums of blow-ups is closed under sums (`L₁ + L₂` terms), negation, Hadamard products
  (`L₁ * L₂` terms) and complementation (`L + 1` terms).  In other words it is a subring of
  the matrices for the Hadamard product, and the "number of blow-ups" behaves like a
  degree.
-/

namespace SchurIdempotent

open Finset

variable {m n : ℕ}

/-! ## Reindexing a sum over `Fin (d * d')` -/

theorem sum_finProd (d d' : ℕ) (F : Fin d → Fin d' → ℝ) :
    ∑ t : Fin (d * d'),
        F (finProdFinEquiv.symm t).1 (finProdFinEquiv.symm t).2
      = ∑ s : Fin d, ∑ s' : Fin d', F s s' := by
  have h := Fintype.sum_equiv finProdFinEquiv.symm
    (fun t : Fin (d * d') => F (finProdFinEquiv.symm t).1 (finProdFinEquiv.symm t).2)
    (fun st : Fin d × Fin d' => F st.1 st.2) fun t => rfl
  rw [h, Fintype.sum_prod_type]

/-! ## Submultiplicativity of the factorization norm -/

/-- The Hadamard (entrywise) product of matrices. -/
def hadamard (A B : Fin m → Fin n → ℝ) : Fin m → Fin n → ℝ := fun i j => A i j * B i j

/-- **Submultiplicativity**: `‖A ⊙ B‖_{γ₂} ≤ ‖A‖_{γ₂} · ‖B‖_{γ₂}`, proved by tensoring the
two factorizations. -/
theorem GammaTwoLE.hadamard {A B : Fin m → Fin n → ℝ} {c d : ℝ} (hc : 0 ≤ c)
    (hA : GammaTwoLE A c) (hB : GammaTwoLE B d) :
    GammaTwoLE (SchurIdempotent.hadamard A B) (c * d) := by
  obtain ⟨F⟩ := hA
  obtain ⟨G⟩ := hB
  refine ⟨{ dim := F.dim * G.dim,
            x := fun i t => F.x i (finProdFinEquiv.symm t).1 * G.x i (finProdFinEquiv.symm t).2,
            y := fun j t => F.y j (finProdFinEquiv.symm t).1 * G.y j (finProdFinEquiv.symm t).2,
            x_bound := ?_, y_bound := ?_, factor := ?_ }⟩
  · intro i
    have h := sum_finProd F.dim G.dim (fun s s' => (F.x i s) ^ 2 * (G.x i s') ^ 2)
    have heq : ∑ t : Fin (F.dim * G.dim),
        (F.x i (finProdFinEquiv.symm t).1 * G.x i (finProdFinEquiv.symm t).2) ^ 2
        = ∑ s : Fin F.dim, ∑ s' : Fin G.dim, (F.x i s) ^ 2 * (G.x i s') ^ 2 := by
      rw [← h]
      exact Finset.sum_congr rfl fun t _ => by ring
    rw [heq, ← Finset.sum_mul_sum]
    have hx : (0:ℝ) ≤ ∑ s : Fin F.dim, (F.x i s) ^ 2 := Finset.sum_nonneg fun s _ => sq_nonneg _
    have hy : (0:ℝ) ≤ ∑ s : Fin G.dim, (G.x i s) ^ 2 := Finset.sum_nonneg fun s _ => sq_nonneg _
    exact mul_le_mul (F.x_bound i) (G.x_bound i) hy hc
  · intro j
    have h := sum_finProd F.dim G.dim (fun s s' => (F.y j s) ^ 2 * (G.y j s') ^ 2)
    have heq : ∑ t : Fin (F.dim * G.dim),
        (F.y j (finProdFinEquiv.symm t).1 * G.y j (finProdFinEquiv.symm t).2) ^ 2
        = ∑ s : Fin F.dim, ∑ s' : Fin G.dim, (F.y j s) ^ 2 * (G.y j s') ^ 2 := by
      rw [← h]
      exact Finset.sum_congr rfl fun t _ => by ring
    rw [heq, ← Finset.sum_mul_sum]
    have hx : (0:ℝ) ≤ ∑ s : Fin F.dim, (F.y j s) ^ 2 := Finset.sum_nonneg fun s _ => sq_nonneg _
    have hy : (0:ℝ) ≤ ∑ s : Fin G.dim, (G.y j s) ^ 2 := Finset.sum_nonneg fun s _ => sq_nonneg _
    exact mul_le_mul (F.y_bound j) (G.y_bound j) hy hc
  · intro i j
    have h := sum_finProd F.dim G.dim
      (fun s s' => (F.x i s * F.y j s) * (G.x i s' * G.y j s'))
    have heq : ∑ t : Fin (F.dim * G.dim),
        (F.x i (finProdFinEquiv.symm t).1 * G.x i (finProdFinEquiv.symm t).2) *
          (F.y j (finProdFinEquiv.symm t).1 * G.y j (finProdFinEquiv.symm t).2)
        = ∑ s : Fin F.dim, ∑ s' : Fin G.dim,
            (F.x i s * F.y j s) * (G.x i s' * G.y j s') := by
      rw [← h]
      exact Finset.sum_congr rfl fun t _ => by ring
    rw [heq, ← Finset.sum_mul_sum, F.factor i j, G.factor i j]
    rfl

/-! ## Blow-ups are closed under Hadamard products -/

/-- **Contractive idempotent Schur multipliers are closed under composition.**  The Hadamard
product of two blow-ups of partial identity matrices is again one; the labels are the
Cantor pairings of the two label functions. -/
theorem IsBlowUp.hadamard {A B : Fin m → Fin n → ℝ} (hA : IsBlowUp A) (hB : IsBlowUp B) :
    IsBlowUp (SchurIdempotent.hadamard A B) := by
  obtain ⟨f₁, g₁, h₁⟩ := hA
  obtain ⟨f₂, g₂, h₂⟩ := hB
  refine ⟨fun i => Nat.pair (f₁ i) (f₂ i), fun j => Nat.pair (g₁ j) (g₂ j), ?_⟩
  intro i j
  show A i j * B i j = _
  rw [h₁ i j, h₂ i j]
  by_cases e₁ : f₁ i = g₁ j <;> by_cases e₂ : f₂ i = g₂ j <;>
    simp [e₁, e₂, Nat.pair_eq_pair]

/-- Composition of contractive idempotent Schur multipliers is again contractive and
idempotent. -/
theorem contractive_idempotent_hadamard {A B : Fin m → Fin n → ℝ}
    (hA : (∀ C, schur A (schur A C) = schur A C) ∧ GammaTwoLE A 1)
    (hB : (∀ C, schur B (schur B C) = schur B C) ∧ GammaTwoLE B 1) :
    (∀ C, schur (SchurIdempotent.hadamard A B) (schur (SchurIdempotent.hadamard A B) C)
        = schur (SchurIdempotent.hadamard A B) C) ∧
      GammaTwoLE (SchurIdempotent.hadamard A B) 1 :=
  (contractive_idempotent_iff_isBlowUp _).2
    (((contractive_idempotent_iff_isBlowUp A).1 hA).hadamard
      ((contractive_idempotent_iff_isBlowUp B).1 hB))

/-! ## Closure properties of finite signed sums of blow-ups -/

theorem IsSignedSumOfBlowUps.neg {A : Fin m → Fin n → ℝ} {L : ℕ}
    (h : IsSignedSumOfBlowUps A L) : IsSignedSumOfBlowUps (fun i j => -A i j) L := by
  obtain ⟨B, e, hB, he, hA⟩ := h
  refine ⟨B, fun l => -e l, hB, ?_, ?_⟩
  · intro l; rcases he l with h1 | h1 <;> simp [h1]
  · intro i j
    show -A i j = ∑ l, -e l * B l i j
    rw [hA i j, ← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun l _ => by ring

theorem IsSignedSumOfBlowUps.add {A B : Fin m → Fin n → ℝ} {L₁ L₂ : ℕ}
    (hA : IsSignedSumOfBlowUps A L₁) (hB : IsSignedSumOfBlowUps B L₂) :
    IsSignedSumOfBlowUps (fun i j => A i j + B i j) (L₁ + L₂) := by
  obtain ⟨B₁, e₁, hB₁, he₁, hA₁⟩ := hA
  obtain ⟨B₂, e₂, hB₂, he₂, hA₂⟩ := hB
  refine ⟨Fin.append B₁ B₂, Fin.append e₁ e₂, ?_, ?_, ?_⟩
  · refine Fin.addCases (fun l => ?_) (fun l => ?_)
    · rw [Fin.append_left]; exact hB₁ l
    · rw [Fin.append_right]; exact hB₂ l
  · refine Fin.addCases (fun l => ?_) (fun l => ?_)
    · rw [Fin.append_left]; exact he₁ l
    · rw [Fin.append_right]; exact he₂ l
  · intro i j
    show A i j + B i j = _
    rw [Fin.sum_univ_add]
    simp only [Fin.append_left, Fin.append_right]
    rw [hA₁ i j, hA₂ i j]

/-- A signed sum of `L₁` blow-ups times a signed sum of `L₂` blow-ups is a signed sum of
`L₁ * L₂` blow-ups. -/
theorem IsSignedSumOfBlowUps.hadamard {A B : Fin m → Fin n → ℝ} {L₁ L₂ : ℕ}
    (hA : IsSignedSumOfBlowUps A L₁) (hB : IsSignedSumOfBlowUps B L₂) :
    IsSignedSumOfBlowUps (SchurIdempotent.hadamard A B) (L₁ * L₂) := by
  obtain ⟨B₁, e₁, hB₁, he₁, hA₁⟩ := hA
  obtain ⟨B₂, e₂, hB₂, he₂, hA₂⟩ := hB
  refine ⟨fun l => SchurIdempotent.hadamard (B₁ (finProdFinEquiv.symm l).1)
                                            (B₂ (finProdFinEquiv.symm l).2),
          fun l => e₁ (finProdFinEquiv.symm l).1 * e₂ (finProdFinEquiv.symm l).2, ?_, ?_, ?_⟩
  · intro l; exact (hB₁ _).hadamard (hB₂ _)
  · intro l
    show e₁ (finProdFinEquiv.symm l).1 * e₂ (finProdFinEquiv.symm l).2 = 1 ∨
      e₁ (finProdFinEquiv.symm l).1 * e₂ (finProdFinEquiv.symm l).2 = -1
    rcases he₁ (finProdFinEquiv.symm l).1 with h1 | h1 <;>
      rcases he₂ (finProdFinEquiv.symm l).2 with h2 | h2 <;> rw [h1, h2] <;> norm_num
  · intro i j
    show A i j * B i j = _
    rw [hA₁ i j, hA₂ i j, Finset.sum_mul_sum, ← sum_finProd L₁ L₂
      (fun s s' => (e₁ s * B₁ s i j) * (e₂ s' * B₂ s' i j))]
    exact Finset.sum_congr rfl fun l _ => by
      show _ = _ * (B₁ _ i j * B₂ _ i j)
      ring

theorem IsSignedSumOfBlowUps.congr {A A' : Fin m → Fin n → ℝ} {L : ℕ}
    (hAA : ∀ i j, A i j = A' i j) (h : IsSignedSumOfBlowUps A L) :
    IsSignedSumOfBlowUps A' L := by
  obtain ⟨B, e, hB, he, hA⟩ := h
  exact ⟨B, e, hB, he, fun i j => by rw [← hAA i j]; exact hA i j⟩

/-- The all-ones matrix is a blow-up (a single block). -/
theorem isSignedSumOfBlowUps_one :
    IsSignedSumOfBlowUps (fun (_ : Fin m) (_ : Fin n) => (1:ℝ)) 1 := by
  refine ⟨fun _ _ _ => 1, fun _ => 1, ?_, fun _ => Or.inl rfl, ?_⟩
  · intro l; exact ⟨fun _ => 0, fun _ => 0, fun i j => by simp⟩
  · intro i j; simp

/-- The complement of a signed sum of `L` blow-ups is a signed sum of `L + 1` blow-ups
(the all-ones matrix is itself a blow-up). -/
theorem IsSignedSumOfBlowUps.complement {A : Fin m → Fin n → ℝ} {L : ℕ}
    (h : IsSignedSumOfBlowUps A L) :
    IsSignedSumOfBlowUps (fun i j => 1 - A i j) (1 + L) :=
  (isSignedSumOfBlowUps_one.add h.neg).congr fun i j => by ring

end SchurIdempotent