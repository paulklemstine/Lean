/-
# Tropical (max-plus) matrices with finite entries

For matrices with entries in `ℝ` (i.e. no `-∞` entries) tropical multiplication is

  `(A ⊗ B) i j = max_k (A i k + B k j)`,

implemented with `Finset.sup'`.  We prove

* `tmul_assoc` : tropical matrix multiplication is associative (a hands-on proof,
  independent of the semiring instance);
* `tmul_embed`  : this operation agrees with multiplication in `Matrix ι ι (MaxPlus ℝ)`,
  so the two developments are coherent;
* `tpow_isGreatest` : **max-plus powers compute optimal paths** — the `(i,j)` entry of
  `A^{⊗(m+1)}` is the maximal weight of a length-`(m+1)` walk from `i` to `j`
  (the algebraic form of the Bellman dynamic-programming principle).
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.MaxPlusSemiring

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Tropical (max-plus) matrix product: `(A ⊗ B) i j = max_k (A i k + B k j)`. -/
noncomputable def tmul (A B : Matrix ι ι ℝ) : Matrix ι ι ℝ :=
  fun i j => Finset.univ.sup' Finset.univ_nonempty fun k => A i k + B k j

/-- Tropical matrix-vector product: `(A ⊗ v) i = max_j (A i j + v j)`. -/
noncomputable def tmulVec (A : Matrix ι ι ℝ) (v : ι → ℝ) : ι → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty fun j => A i j + v j

theorem le_tmul (A B : Matrix ι ι ℝ) (i j k : ι) : A i k + B k j ≤ tmul A B i j :=
  Finset.le_sup' (fun k => A i k + B k j) (Finset.mem_univ k)

theorem tmul_le {A B : Matrix ι ι ℝ} {i j : ι} {c : ℝ} (h : ∀ k, A i k + B k j ≤ c) :
    tmul A B i j ≤ c := Finset.sup'_le _ _ fun k _ => h k

theorem exists_tmul_eq (A B : Matrix ι ι ℝ) (i j : ι) : ∃ k, tmul A B i j = A i k + B k j := by
  obtain ⟨k, _, hk⟩ :=
    Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ι)) (fun k => A i k + B k j)
  exact ⟨k, hk⟩

theorem le_tmulVec (A : Matrix ι ι ℝ) (v : ι → ℝ) (i j : ι) : A i j + v j ≤ tmulVec A v i :=
  Finset.le_sup' (fun j => A i j + v j) (Finset.mem_univ j)

theorem exists_tmulVec_eq (A : Matrix ι ι ℝ) (v : ι → ℝ) (i : ι) :
    ∃ j, tmulVec A v i = A i j + v j := by
  obtain ⟨j, _, hj⟩ :=
    Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ι)) (fun j => A i j + v j)
  exact ⟨j, hj⟩

/-- **Associativity of tropical matrix multiplication**, proved directly from the
`max`-of-sums formula. -/
theorem tmul_assoc (A B C : Matrix ι ι ℝ) : tmul (tmul A B) C = tmul A (tmul B C) := by
  funext i j
  apply le_antisymm
  · refine tmul_le fun k => ?_
    obtain ⟨l, hl⟩ := exists_tmul_eq A B i k
    have h1 := le_tmul B C l j k
    have h2 := le_tmul A (tmul B C) i j l
    rw [hl]; linarith
  · refine tmul_le fun l => ?_
    obtain ⟨k, hk⟩ := exists_tmul_eq B C l j
    have h1 := le_tmul A B i k l
    have h2 := le_tmul (tmul A B) C i j k
    rw [hk]; linarith

/-- Tropical multiplication distributes over the entrywise `max` of matrices. -/
theorem tmul_add_distrib (A B C : Matrix ι ι ℝ) (i j : ι) :
    tmul A (fun i j => max (B i j) (C i j)) i j = max (tmul A B i j) (tmul A C i j) := by
  apply le_antisymm
  · refine tmul_le fun k => ?_
    show A i k + max (B k j) (C k j) ≤ _
    rcases le_total (B k j) (C k j) with h | h
    · rw [max_eq_right h]
      exact le_trans (le_tmul A C i j k) (le_max_right _ _)
    · rw [max_eq_left h]
      exact le_trans (le_tmul A B i j k) (le_max_left _ _)
  · refine max_le (tmul_le fun k => ?_) (tmul_le fun k => ?_)
    · have h1 := le_tmul A (fun i j => max (B i j) (C i j)) i j k
      have h2 := le_max_left (B k j) (C k j)
      simp only at h1
      linarith
    · have h1 := le_tmul A (fun i j => max (B i j) (C i j)) i j k
      have h2 := le_max_right (B k j) (C k j)
      simp only at h1
      linarith

section Embedding

/-- Embed a finite-entry real matrix into the max-plus semiring `MaxPlus ℝ`. -/
def embed (A : Matrix ι ι ℝ) : Matrix ι ι (MaxPlus ℝ) :=
  fun i j => MaxPlus.ofBot ((A i j : ℝ) : WithBot ℝ)

theorem coe_sup' {κ : Type*} {s : Finset κ} (H : s.Nonempty) (f : κ → ℝ) :
    ((s.sup' H f : ℝ) : WithBot ℝ) = s.sup (fun i => ((f i : ℝ) : WithBot ℝ)) := by
  obtain ⟨k, hk, hks⟩ := Finset.exists_mem_eq_sup' H f
  apply le_antisymm
  · rw [hks]; exact Finset.le_sup (f := fun i => ((f i : ℝ) : WithBot ℝ)) hk
  · refine Finset.sup_le fun i hi => ?_
    exact_mod_cast Finset.le_sup' f hi

/-- **Coherence**: the hands-on `max`-of-sums product agrees with the semiring
matrix product in `Matrix ι ι (MaxPlus ℝ)`. -/
theorem tmul_embed (A B : Matrix ι ι ℝ) (i j : ι) :
    MaxPlus.toBot ((embed A * embed B) i j) = ((tmul A B i j : ℝ) : WithBot ℝ) := by
  rw [MaxPlus.toBot_matrix_mul, tmul, coe_sup']
  refine Finset.sup_congr rfl fun k _ => ?_
  simp [embed]

end Embedding

section Paths

/-- Tropical powers: `tpow A m = A^{⊗(m+1)}`. -/
noncomputable def tpow (A : Matrix ι ι ℝ) : ℕ → Matrix ι ι ℝ
  | 0 => A
  | (m + 1) => tmul (tpow A m) A

/-- The weight of the length-`m` walk `p 0 → p 1 → ⋯ → p m`. -/
def pathWeight (A : Matrix ι ι ℝ) (p : ℕ → ι) (m : ℕ) : ℝ :=
  ∑ t ∈ Finset.range m, A (p t) (p (t + 1))

/-- **Tropical powers compute maximum-weight walks.**  The `(i,j)` entry of the
`(m+1)`-st tropical power of `A` is the greatest weight of a walk of length `m+1`
from `i` to `j`; in particular that optimum is attained. -/
theorem tpow_isGreatest (A : Matrix ι ι ℝ) (m : ℕ) (i j : ι) :
    IsGreatest {w : ℝ | ∃ p : ℕ → ι, p 0 = i ∧ p (m + 1) = j ∧ w = pathWeight A p (m + 1)}
      (tpow A m i j) := by
  induction m generalizing i j with
  | zero =>
      constructor
      · refine ⟨fun t => if t = 0 then i else j, by simp, by simp, ?_⟩
        simp [pathWeight, tpow]
      · rintro w ⟨p, hp0, hp1, rfl⟩
        simp [pathWeight, hp0, hp1, tpow]
  | succ m ih =>
      constructor
      · obtain ⟨k, hk⟩ := exists_tmul_eq (tpow A m) A i j
        obtain ⟨p, hp0, hpm, hpw⟩ := (ih i k).1
        refine ⟨fun t => if t ≤ m + 1 then p t else j, by simpa using hp0, by simp, ?_⟩
        have hsum : ∑ t ∈ Finset.range (m + 1),
            A ((fun t => if t ≤ m + 1 then p t else j) t)
              ((fun t => if t ≤ m + 1 then p t else j) (t + 1)) = pathWeight A p (m + 1) := by
          refine Finset.sum_congr rfl fun t ht => ?_
          simp only [Finset.mem_range] at ht
          have h1 : t ≤ m + 1 := by omega
          have h2 : t + 1 ≤ m + 1 := by omega
          simp [h1, h2]
        show tpow A (m + 1) i j = pathWeight A _ (m + 2)
        rw [pathWeight, Finset.sum_range_succ, hsum]
        have hlt : ¬ (m + 2 ≤ m + 1) := by omega
        simp only [hlt, if_false, le_refl, if_true]
        rw [hpm] at *
        show tmul (tpow A m) A i j = _
        rw [hk, ← hpw]
      · rintro w ⟨p, hp0, hpm, rfl⟩
        rw [pathWeight, Finset.sum_range_succ]
        have h1 : ∑ t ∈ Finset.range (m + 1), A (p t) (p (t + 1)) ≤ tpow A m i (p (m + 1)) :=
          (ih i (p (m + 1))).2 ⟨p, hp0, rfl, rfl⟩
        have h2 : tpow A m i (p (m + 1)) + A (p (m + 1)) j ≤ tmul (tpow A m) A i j :=
          le_tmul (tpow A m) A i j (p (m + 1))
        have h3 : A (p (m + 1)) (p (m + 2)) = A (p (m + 1)) j := by rw [hpm]
        show _ ≤ tmul (tpow A m) A i j
        rw [h3]
        linarith

end Paths

end TropicalLA