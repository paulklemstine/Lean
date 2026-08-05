import Mathlib

/-!
# Cayley determinants of right-quantum matrices

This file develops the *Cayley (column-ordered) determinant* of a square matrix with entries
in an arbitrary, possibly noncommutative, ring, and proves that it is **alternating in the
columns** as soon as the matrix satisfies the *right-quantum relations* of Manin.

The right-quantum relations are the defining relations of the quantum-group-like algebras
studied in "Quantum determinants in polynomial time" (Chan--Pak): for `i < j` and `k < l`,

* `A i k * A j k = A j k * A i k`  (entries of a fixed column commute),
* `A i k * A j l - A j k * A i l = A j l * A i k - A i l * A j k`  (the crossing relation).

## Main results

* `QuantumDet.cdet` : the Cayley determinant `∑_σ sgn σ • A (σ 0) 0 * A (σ 1) 1 * ⋯`.
* `QuantumDet.IsRightQuantum.cross'` : the crossing relation in unrestricted symmetric form.
* `QuantumDet.IsRightQuantum.submatrix_col` : stability under permuting columns.
* `QuantumDet.cdet_swap_adjacent_cols` : swapping two *adjacent* columns of a right-quantum
  matrix negates the Cayley determinant.
* `QuantumDet.cdet_col_perm` : for a right-quantum matrix and **any** permutation `τ` of the
  columns, `cdet (A ∘ τ) = sgn τ • cdet A`.
* `QuantumDet.cdet_eq_zero_of_col_eq` : two equal columns force `cdet A = 0` (in a ring
  without additive `2`-torsion).
* `QuantumDet.cdet_row_perm` : permuting rows also multiplies `cdet` by the sign (no quantum
  hypothesis needed).
* `QuantumDet.invCount_mul_swap` : right multiplication by an adjacent transposition creates
  exactly one new inversion.
* `QuantumDet.sign_eq_neg_one_pow_invCount` : the sign of a permutation is the parity of its
  number of inversions.
* `QuantumDet.qcdet`, `QuantumDet.IsQRightQuantum` and
  `QuantumDet.qcdet_swap_adjacent_cols` : the `q`-deformed theory, in which an adjacent column
  swap multiplies the `q`-Cayley determinant by `-q⁻¹`.
* `QuantumDet.qcdet_one_eq_cdet` : at `q = 1` the `q`-Cayley determinant is `cdet`.
* `QuantumDet.isQRightQuantum_of_quantumTwo` : the generators of the quantum group `M_q(2)`
  form a `q`-right-quantum matrix, so the theory applies to quantum groups.

## The bridge to commutative linear algebra

`QuantumDet.cdet_eq_det` shows that over a commutative ring `cdet` is Mathlib's `Matrix.det`,
and `QuantumDet.isRightQuantum_of_comm` shows every matrix over a commutative ring is
right-quantum.  Consequently `cdet_col_perm` specialises to the classical statement that the
determinant is alternating.
-/

namespace QuantumDet

open Equiv Equiv.Perm List

variable {R : Type*} [Ring R] {n m : ℕ}

/-- The column-ordered word attached to a permutation `σ`:
`A (σ 0) 0 * A (σ 1) 1 * ⋯ * A (σ (n-1)) (n-1)`, the product being taken in the order of the
columns.  In a noncommutative ring the order matters, which is why we use `List.prod`. -/
def cword (A : Matrix (Fin n) (Fin n) R) (σ : Equiv.Perm (Fin n)) : R :=
  (List.ofFn fun j => A (σ j) j).prod

/-- The **Cayley determinant** (also called the column determinant) of a square matrix over a
possibly noncommutative ring. -/
def cdet (A : Matrix (Fin n) (Fin n) R) : R :=
  ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℤ) • cword A σ

/-- Manin's **right-quantum** relations. -/
structure IsRightQuantum (A : Matrix (Fin n) (Fin n) R) : Prop where
  col_comm : ∀ i j k, i < j → A i k * A j k = A j k * A i k
  cross : ∀ i j k l, i < j → k < l →
    A i k * A j l - A j k * A i l = A j l * A i k - A i l * A j k

section Cross

variable {A : Matrix (Fin n) (Fin n) R}

/-- Entries in a fixed column of a right-quantum matrix commute (all index pairs). -/
lemma IsRightQuantum.col_comm' (h : IsRightQuantum A) (i j k : Fin n) :
    A i k * A j k = A j k * A i k := by
  rcases lt_trichotomy i j with hij | rfl | hij
  · exact h.col_comm i j k hij
  · rfl
  · exact (h.col_comm j i k hij).symm

/-- The crossing relation in symmetric form, valid for **all** index quadruples. -/
lemma IsRightQuantum.cross' (h : IsRightQuantum A) (i j k l : Fin n) :
    A i k * A j l + A i l * A j k = A j l * A i k + A j k * A i l := by
  have key : ∀ a b c d : Fin n, a < b → c < d →
      A a c * A b d + A a d * A b c = A b d * A a c + A b c * A a d := by
    intro a b c d hab hcd
    have := h.cross a b c d hab hcd
    linear_combination (norm := abel) this
  rcases lt_trichotomy i j with hij | rfl | hij
  · rcases lt_trichotomy k l with hkl | rfl | hkl
    · exact key i j k l hij hkl
    · rw [h.col_comm' i j k]
    · have := key i j l k hij hkl
      linear_combination (norm := abel) this
  · rw [add_comm]
  · rcases lt_trichotomy k l with hkl | rfl | hkl
    · have := key j i k l hij hkl
      linear_combination (norm := abel) -this
    · rw [h.col_comm' i j k]
    · have := key j i l k hij hkl
      linear_combination (norm := abel) -this

/-- Right-quantum-ness is preserved by an arbitrary permutation of the columns. -/
lemma IsRightQuantum.submatrix_col (h : IsRightQuantum A) (τ : Equiv.Perm (Fin n)) :
    IsRightQuantum (A.submatrix id τ) where
  col_comm i j k _ := h.col_comm' i j (τ k)
  cross i j k l _ _ := by
    have := h.cross' i j (τ k) (τ l)
    simp only [Matrix.submatrix_apply, id_eq]
    linear_combination (norm := abel) this

end Cross

/-! ### Splitting the column word at two adjacent positions -/

section Split

variable {M : Type*} [Monoid M]

private lemma finRange_split (m : ℕ) (t : Fin m) :
    List.finRange (m + 1) =
      (List.finRange (m + 1)).take t ++ t.castSucc :: t.succ ::
        (List.finRange (m + 1)).drop ((t : ℕ) + 2) := by
  have hlen : (List.finRange (m + 1)).length = m + 1 := by simp
  have h1 : (t : ℕ) < (List.finRange (m + 1)).length := by rw [hlen]; omega
  have h2 : (t : ℕ) + 1 < (List.finRange (m + 1)).length := by
    rw [hlen]; exact Nat.succ_lt_succ t.isLt
  have e1 := List.drop_eq_getElem_cons h1
  have e2 := List.drop_eq_getElem_cons h2
  have g1 : (List.finRange (m + 1))[(t : ℕ)] = t.castSucc := by
    simp [List.getElem_finRange, Fin.ext_iff]
  have g2 : (List.finRange (m + 1))[(t : ℕ) + 1] = t.succ := by
    simp [List.getElem_finRange, Fin.ext_iff]
  have h3 := List.take_append_drop (t : ℕ) (List.finRange (m + 1))
  rw [e1, g1, e2, g2] at h3
  exact h3.symm

/-- The head part of the column word (columns before position `t`). -/
private def pre (t : Fin m) (f : Fin (m + 1) → M) : M :=
  (((List.finRange (m + 1)).take t).map f).prod

/-- The tail part of the column word (columns after position `t+1`). -/
private def post (t : Fin m) (f : Fin (m + 1) → M) : M :=
  (((List.finRange (m + 1)).drop ((t : ℕ) + 2)).map f).prod

private lemma prod_ofFn_split (t : Fin m) (f : Fin (m + 1) → M) :
    (List.ofFn f).prod = pre t f * (f t.castSucc * f t.succ) * post t f := by
  rw [List.ofFn_eq_map, finRange_split m t]
  simp [pre, post, List.prod_append, mul_assoc]

private lemma mem_take_lt {t : Fin m} {j : Fin (m + 1)}
    (hj : j ∈ (List.finRange (m + 1)).take (t : ℕ)) : (j : ℕ) < (t : ℕ) := by
  rw [List.mem_iff_getElem] at hj
  obtain ⟨i, hi, rfl⟩ := hj
  have hlen : ((List.finRange (m + 1)).take (t : ℕ)).length = min (t : ℕ) (m + 1) := by simp
  have hi' : i < (t : ℕ) := by
    rw [hlen] at hi; omega
  have hgi : ((List.finRange (m + 1)).take (t : ℕ))[i] =
      (List.finRange (m + 1))[i]'(by simp; omega) := List.getElem_take
  rw [hgi]
  simpa using hi'

private lemma mem_drop_gt {t : Fin m} {j : Fin (m + 1)}
    (hj : j ∈ (List.finRange (m + 1)).drop ((t : ℕ) + 2)) : (t : ℕ) + 1 < (j : ℕ) := by
  rw [List.mem_iff_getElem] at hj
  obtain ⟨i, hi, rfl⟩ := hj
  have hlen : ((List.finRange (m + 1)).drop ((t : ℕ) + 2)).length = m + 1 - ((t : ℕ) + 2) := by
    simp
  rw [hlen] at hi
  have hi' : (t : ℕ) + 2 + i < m + 1 := by omega
  have hgi : ((List.finRange (m + 1)).drop ((t : ℕ) + 2))[i] =
      (List.finRange (m + 1))[(t : ℕ) + 2 + i]'(by simpa using hi') := List.getElem_drop
  rw [hgi]
  simp only [List.getElem_finRange]
  simp
  omega

private lemma pre_congr {t : Fin m} {f g : Fin (m + 1) → M}
    (h : ∀ j : Fin (m + 1), (j : ℕ) < (t : ℕ) → f j = g j) : pre t f = pre t g := by
  unfold pre
  congr 1
  exact List.map_congr_left fun j hj => h j (mem_take_lt hj)

private lemma post_congr {t : Fin m} {f g : Fin (m + 1) → M}
    (h : ∀ j : Fin (m + 1), (t : ℕ) + 1 < (j : ℕ) → f j = g j) : post t f = post t g := by
  unfold post
  congr 1
  exact List.map_congr_left fun j hj => h j (mem_drop_gt hj)

end Split

/-! ### The adjacent column swap -/

section Swap

variable {A : Matrix (Fin (m + 1)) (Fin (m + 1)) R}

/-- The four column words attached to `σ` and to `σ * s` (where `s` swaps the adjacent columns
`t` and `t+1`), for `A` and for `A` with those two columns interchanged, all factor through a
common prefix `P` and a common suffix `Q`. -/
private lemma cword_split_pair (A : Matrix (Fin (m + 1)) (Fin (m + 1)) R) (t : Fin m)
    (σ : Equiv.Perm (Fin (m + 1))) :
    ∃ P Q : R,
      cword A σ = P * (A (σ t.castSucc) t.castSucc * A (σ t.succ) t.succ) * Q ∧
      cword A (σ * Equiv.swap t.castSucc t.succ)
        = P * (A (σ t.succ) t.castSucc * A (σ t.castSucc) t.succ) * Q ∧
      cword (A.submatrix id (Equiv.swap t.castSucc t.succ)) σ
        = P * (A (σ t.castSucc) t.succ * A (σ t.succ) t.castSucc) * Q ∧
      cword (A.submatrix id (Equiv.swap t.castSucc t.succ)) (σ * Equiv.swap t.castSucc t.succ)
        = P * (A (σ t.succ) t.succ * A (σ t.castSucc) t.castSucc) * Q := by
  set s : Equiv.Perm (Fin (m + 1)) := Equiv.swap t.castSucc t.succ with hs
  set k : Fin (m + 1) := t.castSucc with hk
  set l : Fin (m + 1) := t.succ with hl
  have hsk : s k = l := by rw [hs, Equiv.swap_apply_left]
  have hsl : s l = k := by rw [hs, Equiv.swap_apply_right]
  have hsj : ∀ j, j ≠ k → j ≠ l → s j = j := fun j h1 h2 => by
    rw [hs]; exact Equiv.swap_apply_of_ne_of_ne h1 h2
  have hne : ∀ j : Fin (m + 1), (j : ℕ) < (t : ℕ) ∨ (t : ℕ) + 1 < (j : ℕ) →
      j ≠ k ∧ j ≠ l := by
    intro j hj
    constructor
    · rintro rfl
      rw [hk] at hj; simp only [Fin.val_castSucc] at hj; omega
    · rintro rfl
      rw [hl] at hj; simp only [Fin.val_succ] at hj; omega
  have hagree : ∀ j : Fin (m + 1), (j : ℕ) < (t : ℕ) ∨ (t : ℕ) + 1 < (j : ℕ) →
      (A (σ j) (s j) = A (σ j) j ∧ A ((σ * s) j) j = A (σ j) j ∧
       A ((σ * s) j) (s j) = A (σ j) j) := by
    intro j hj
    obtain ⟨h1, h2⟩ := hne j hj
    have hsjj : s j = j := hsj j h1 h2
    refine ⟨by rw [hsjj], ?_, ?_⟩ <;> simp [Equiv.Perm.mul_apply, hsjj]
  set i := σ k with hi
  set jj := σ l with hjj
  have e1 : cword (A.submatrix id s) σ =
      pre t (fun j => A (σ j) j) * (A i l * A jj k) * post t (fun j => A (σ j) j) := by
    rw [cword, prod_ofFn_split t]
    congr 1
    · congr 1
      · exact pre_congr fun j hjlt => (hagree j (Or.inl hjlt)).1
      · simp only [Matrix.submatrix_apply, id_eq, ← hk, ← hl, hsk, hsl, ← hi, ← hjj]
    · exact post_congr fun j hjgt => (hagree j (Or.inr hjgt)).1
  have e2 : cword A σ =
      pre t (fun j => A (σ j) j) * (A i k * A jj l) * post t (fun j => A (σ j) j) := by
    rw [cword, prod_ofFn_split t]
  have e3 : cword (A.submatrix id s) (σ * s) =
      pre t (fun j => A (σ j) j) * (A jj l * A i k) * post t (fun j => A (σ j) j) := by
    rw [cword, prod_ofFn_split t]
    congr 1
    · congr 1
      · exact pre_congr fun j hjlt => (hagree j (Or.inl hjlt)).2.2
      · simp only [Matrix.submatrix_apply, id_eq, Equiv.Perm.mul_apply, ← hk, ← hl, hsk, hsl,
          ← hi, ← hjj]
    · exact post_congr fun j hjgt => (hagree j (Or.inr hjgt)).2.2
  have e4 : cword A (σ * s) =
      pre t (fun j => A (σ j) j) * (A jj k * A i l) * post t (fun j => A (σ j) j) := by
    rw [cword, prod_ofFn_split t]
    congr 1
    · congr 1
      · exact pre_congr fun j hjlt => (hagree j (Or.inl hjlt)).2.1
      · simp only [Equiv.Perm.mul_apply, ← hk, ← hl, hsk, hsl, ← hi, ← hjj]
    · exact post_congr fun j hjgt => (hagree j (Or.inr hjgt)).2.1
  exact ⟨_, _, e2, e4, e1, e3⟩

private lemma cword_pair_sum (hA : IsRightQuantum A) (t : Fin m)
    (σ : Equiv.Perm (Fin (m + 1))) :
    cword (A.submatrix id (Equiv.swap t.castSucc t.succ)) σ + cword A σ
      = cword (A.submatrix id (Equiv.swap t.castSucc t.succ))
          (σ * Equiv.swap t.castSucc t.succ)
        + cword A (σ * Equiv.swap t.castSucc t.succ) := by
  obtain ⟨P, Q, e2, e4, e1, e3⟩ := cword_split_pair A t σ
  rw [e1, e2, e3, e4, ← add_mul, ← add_mul, ← mul_add, ← mul_add]
  congr 2
  have := hA.cross' (σ t.castSucc) (σ t.succ) t.castSucc t.succ
  linear_combination (norm := abel) this

/-- **Swapping two adjacent columns of a right-quantum matrix negates the Cayley
determinant.**  This is the crossing relation, upgraded from `2 × 2` to `n × n`. -/
theorem cdet_swap_adjacent_cols (hA : IsRightQuantum A) (t : Fin m) :
    cdet (A.submatrix id (Equiv.swap t.castSucc t.succ)) + cdet A = 0 := by
  set s : Equiv.Perm (Fin (m + 1)) := Equiv.swap t.castSucc t.succ with hs
  have hkl : t.castSucc ≠ t.succ := by simp [Fin.ext_iff]
  have hsign : Equiv.Perm.sign s = -1 := by rw [hs, Equiv.Perm.sign_swap hkl]
  have hs2 : s * s = 1 := by rw [hs, Equiv.swap_mul_self]
  have hsum : cdet (A.submatrix id s) + cdet A =
      ∑ σ : Equiv.Perm (Fin (m + 1)),
        ((Equiv.Perm.sign σ : ℤ) • (cword (A.submatrix id s) σ + cword A σ)) := by
    simp only [cdet, smul_add]
    rw [Finset.sum_add_distrib]
  rw [hsum]
  refine Finset.sum_involution (fun σ _ => σ * s) ?_ ?_ (fun _ _ => Finset.mem_univ _) ?_
  · intro σ _
    have hsg : (Equiv.Perm.sign (σ * s) : ℤ) = -(Equiv.Perm.sign σ : ℤ) := by
      rw [map_mul, hsign]; simp
    rw [hsg, neg_smul, ← smul_neg, ← smul_add]
    have hpair := cword_pair_sum hA t σ
    rw [← hs] at hpair
    rw [show cword (A.submatrix id s) σ + cword A σ +
        -(cword (A.submatrix id s) (σ * s) + cword A (σ * s)) = 0 from by
      rw [hpair]; abel]
    simp
  · intro σ _ _ hcon
    have hs1 : s = 1 := by
      have := congrArg (fun x => σ⁻¹ * x) hcon
      simpa [← mul_assoc] using this
    rw [hs1] at hsign
    simp at hsign
  · intro σ _
    show σ * s * s = σ
    rw [mul_assoc, hs2, mul_one]

end Swap

/-! ### Arbitrary column permutations -/

omit [Ring R] in
private lemma submatrix_col_one (A : Matrix (Fin n) (Fin n) R) :
    A.submatrix id (1 : Equiv.Perm (Fin n)) = A := rfl

/-- **The Cayley determinant of a right-quantum matrix is alternating in the columns.** -/
theorem cdet_col_perm {A : Matrix (Fin n) (Fin n) R} (hA : IsRightQuantum A)
    (τ : Equiv.Perm (Fin n)) :
    cdet (A.submatrix id τ) = (Equiv.Perm.sign τ : ℤ) • cdet A := by
  cases n with
  | zero =>
      have hτ : τ = 1 := Subsingleton.elim _ _
      subst hτ
      rw [submatrix_col_one]
      simp
  | succ m =>
      have hgen := Equiv.Perm.mclosure_swap_castSucc_succ m
      have hmem : τ ∈ Submonoid.closure
          (Set.range fun i : Fin m => Equiv.swap i.castSucc i.succ) := by
        rw [hgen]; trivial
      induction hmem using Submonoid.closure_induction generalizing A with
      | mem x hx =>
          obtain ⟨i, rfl⟩ := hx
          have h := cdet_swap_adjacent_cols hA i
          have hkl : (i : Fin m).castSucc ≠ i.succ := by simp [Fin.ext_iff]
          rw [Equiv.Perm.sign_swap hkl]
          rw [eq_neg_of_add_eq_zero_left h]
          simp
      | one =>
          rw [submatrix_col_one]; simp
      | mul x y hx hy ihx ihy =>
          have hxq : IsRightQuantum (A.submatrix id x) := hA.submatrix_col x
          have hcomp : A.submatrix id (x * y) = (A.submatrix id x).submatrix id y := rfl
          rw [hcomp, ihy hxq, ihx hA, map_mul]
          rw [smul_smul]
          congr 1
          push_cast
          ring

/-- A right-quantum matrix with two equal columns has `cdet A + cdet A = 0`. -/
theorem cdet_add_self_eq_zero_of_col_eq {A : Matrix (Fin n) (Fin n) R}
    (hA : IsRightQuantum A) {k l : Fin n} (hkl : k ≠ l) (h : ∀ i, A i k = A i l) :
    cdet A + cdet A = 0 := by
  have hsub : A.submatrix id (Equiv.swap k l) = A := by
    ext i j
    simp only [Matrix.submatrix_apply, id_eq]
    rcases eq_or_ne j k with rfl | hjk
    · rw [Equiv.swap_apply_left, h i]
    · rcases eq_or_ne j l with rfl | hjl
      · rw [Equiv.swap_apply_right, h i]
      · rw [Equiv.swap_apply_of_ne_of_ne hjk hjl]
  have hmain := cdet_col_perm hA (Equiv.swap k l)
  rw [hsub, Equiv.Perm.sign_swap hkl] at hmain
  simp only [Units.val_neg, Units.val_one, neg_smul, one_smul] at hmain
  nth_rewrite 1 [hmain]
  abel

/-- If the ring has no additive `2`-torsion, a right-quantum matrix with two equal columns has
vanishing Cayley determinant. -/
theorem cdet_eq_zero_of_col_eq {A : Matrix (Fin n) (Fin n) R} (hA : IsRightQuantum A)
    (h2 : ∀ x : R, x + x = 0 → x = 0) {k l : Fin n} (hkl : k ≠ l) (h : ∀ i, A i k = A i l) :
    cdet A = 0 :=
  h2 _ (cdet_add_self_eq_zero_of_col_eq hA hkl h)

/-! ### Rows: no quantum hypothesis needed -/

/-- Permuting the rows of *any* matrix multiplies the Cayley determinant by the sign. -/
theorem cdet_row_perm (A : Matrix (Fin n) (Fin n) R) (π : Equiv.Perm (Fin n)) :
    cdet (A.submatrix π id) = (Equiv.Perm.sign π : ℤ) • cdet A := by
  have hword : ∀ σ : Equiv.Perm (Fin n), cword (A.submatrix π id) σ = cword A (π * σ) := by
    intro σ
    unfold cword
    congr 1
  calc cdet (A.submatrix π id)
      = ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℤ) • cword A (π * σ) := by
        unfold cdet
        exact Finset.sum_congr rfl fun σ _ => by rw [hword]
    _ = ∑ ρ : Equiv.Perm (Fin n), (Equiv.Perm.sign (π⁻¹ * ρ) : ℤ) • cword A ρ := by
        refine (Equiv.sum_comp (Equiv.mulLeft π⁻¹) _).symm.trans ?_
        refine Finset.sum_congr rfl fun ρ _ => ?_
        rw [Equiv.coe_mulLeft]
        congr 2
        rw [← mul_assoc, mul_inv_cancel, one_mul]
    _ = (Equiv.Perm.sign π : ℤ) • cdet A := by
        unfold cdet
        rw [Finset.smul_sum]
        refine Finset.sum_congr rfl fun ρ _ => ?_
        rw [map_mul, smul_smul]
        congr 1
        rcases Int.units_eq_one_or (Equiv.Perm.sign π) with h | h <;>
          simp [Equiv.Perm.sign_inv, h]

/-! ### Bridge to commutative linear algebra -/

/-- Every matrix over a commutative ring is right-quantum. -/
theorem isRightQuantum_of_comm {S : Type*} [CommRing S] (A : Matrix (Fin n) (Fin n) S) :
    IsRightQuantum A where
  col_comm i j k _ := mul_comm _ _
  cross i j k l _ _ := by ring

/-- Over a commutative ring the Cayley determinant is the usual determinant. -/
theorem cdet_eq_det {S : Type*} [CommRing S] (A : Matrix (Fin n) (Fin n) S) :
    cdet A = A.det := by
  rw [Matrix.det_apply]
  refine Finset.sum_congr rfl fun σ _ => ?_
  rw [cword, List.prod_ofFn, Units.smul_def, zsmul_eq_mul]

/-! ### Inversions of a permutation

The combinatorial input for the `q`-deformation: the number of inversions of a permutation,
and the fact that right multiplication by an adjacent transposition changes it by exactly one.
-/

section Inversions

/-- The number of inversions of a permutation of `Fin n`. -/
def invCount (σ : Equiv.Perm (Fin n)) : ℕ :=
  (Finset.univ.filter fun p : Fin n × Fin n => p.1 < p.2 ∧ σ p.2 < σ p.1).card

private lemma swap_val (t : Fin m) (z : Fin (m + 1)) :
    ((Equiv.swap t.castSucc t.succ z : Fin (m + 1)) : ℕ)
      = if (z : ℕ) = (t : ℕ) then (t : ℕ) + 1 else if (z : ℕ) = (t : ℕ) + 1 then (t : ℕ)
        else (z : ℕ) := by
  rcases eq_or_ne z t.castSucc with rfl | h1
  · rw [Equiv.swap_apply_left]; simp
  · rcases eq_or_ne z t.succ with rfl | h2
    · rw [Equiv.swap_apply_right]; simp
    · rw [Equiv.swap_apply_of_ne_of_ne h1 h2]
      have e1 : (z : ℕ) ≠ (t : ℕ) := fun hh => h1 (Fin.ext (by simpa using hh))
      have e2 : (z : ℕ) ≠ (t : ℕ) + 1 := fun hh => h2 (Fin.ext (by simpa using hh))
      simp [e1, e2]

/-- An adjacent transposition preserves the order of every pair of positions except the pair
it transposes. -/
private lemma swap_lt {t : Fin m} {x y : Fin (m + 1)} (hxy : x < y)
    (hne : ¬(x = t.castSucc ∧ y = t.succ)) :
    Equiv.swap t.castSucc t.succ x < Equiv.swap t.castSucc t.succ y := by
  rw [Fin.lt_def] at hxy ⊢
  rw [swap_val, swap_val]
  have hx : x = t.castSucc ↔ (x : ℕ) = (t : ℕ) := by
    constructor
    · rintro rfl; simp
    · intro hh; exact Fin.ext (by simpa using hh)
  have hy : y = t.succ ↔ (y : ℕ) = (t : ℕ) + 1 := by
    constructor
    · rintro rfl; simp
    · intro hh; exact Fin.ext (by simpa using hh)
  rw [hx, hy] at hne
  push_neg at hne
  split_ifs <;> omega

/-- Right multiplication by an adjacent transposition creates exactly one new inversion. -/
lemma invCount_mul_swap (t : Fin m) (σ : Equiv.Perm (Fin (m + 1)))
    (h : σ t.castSucc < σ t.succ) :
    invCount (σ * Equiv.swap t.castSucc t.succ) = invCount σ + 1 := by
  set s : Equiv.Perm (Fin (m + 1)) := Equiv.swap t.castSucc t.succ with hs
  set k : Fin (m + 1) := t.castSucc
  set l : Fin (m + 1) := t.succ
  have hkl : k < l := Fin.castSucc_lt_succ
  have hsk : s k = l := Equiv.swap_apply_left _ _
  have hsl : s l = k := Equiv.swap_apply_right _ _
  have hss : ∀ z, s (s z) = z := fun z => Equiv.swap_apply_self _ _ _
  set phi : Fin (m + 1) × Fin (m + 1) → Fin (m + 1) × Fin (m + 1) :=
    fun p => (s p.1, s p.2) with hphi
  set I : Equiv.Perm (Fin (m + 1)) → Finset (Fin (m + 1) × Fin (m + 1)) :=
    fun τ => Finset.univ.filter fun p : Fin (m + 1) × Fin (m + 1) =>
      p.1 < p.2 ∧ τ p.2 < τ p.1 with hI
  have hmemI : ∀ τ p, p ∈ I τ ↔ (p.1 < p.2 ∧ τ p.2 < τ p.1) := by
    intro τ p; simp [hI]
  have key : I (σ * s) = insert (k, l) ((I σ).image phi) := by
    ext p
    simp only [Finset.mem_insert, Finset.mem_image, hmemI]
    constructor
    · intro hp
      by_cases hpk : p = (k, l)
      · exact Or.inl hpk
      · refine Or.inr ⟨phi p, ⟨?_, ?_⟩, ?_⟩
        · refine swap_lt hp.1 ?_
          rintro ⟨e1, e2⟩
          exact hpk (Prod.ext e1 e2)
        · have := hp.2
          simpa [hphi, Equiv.Perm.mul_apply] using this
        · simp [hphi, hss]
    · rintro (rfl | ⟨p', hp', rfl⟩)
      · exact ⟨hkl, by simp [Equiv.Perm.mul_apply, hsk, hsl, h]⟩
      · refine ⟨?_, ?_⟩
        · refine swap_lt hp'.1 ?_
          rintro ⟨e1, e2⟩
          have hlt : σ p'.2 < σ p'.1 := hp'.2
          rw [e1, e2] at hlt
          exact absurd h (not_lt.mpr hlt.le)
        · simpa [hphi, Equiv.Perm.mul_apply, hss] using hp'.2
  have hnotmem : (k, l) ∉ (I σ).image phi := by
    simp only [Finset.mem_image, not_exists]
    rintro p ⟨hp, hpe⟩
    rw [hmemI] at hp
    have h1 : s p.1 = k := congrArg Prod.fst hpe
    have h2 : s p.2 = l := congrArg Prod.snd hpe
    have h3 : p.1 = l := by have := congrArg s h1; rwa [hss, hsk] at this
    have h4 : p.2 = k := by have := congrArg s h2; rwa [hss, hsl] at this
    rw [h3, h4] at hp
    exact absurd hp.1 (not_lt.mpr hkl.le)
  have hinj : Set.InjOn phi (I σ) := by
    intro p _ p' _ hpp
    exact Prod.ext (s.injective (congrArg Prod.fst hpp)) (s.injective (congrArg Prod.snd hpp))
  have hL : invCount (σ * s) = (I (σ * s)).card := rfl
  have hR : invCount σ = (I σ).card := rfl
  rw [hL, hR, key, Finset.card_insert_of_notMem hnotmem, Finset.card_image_of_injOn hinj]

private lemma perm_eq_one_of_strictMono (f : Equiv.Perm (Fin n)) (h : StrictMono f) : f = 1 := by
  have h1 : ∀ i : Fin n, (i : ℕ) ≤ ((f i : Fin n) : ℕ) := fun i => h.le_apply
  have hsum : ∑ i : Fin n, ((f i : Fin n) : ℕ) = ∑ i : Fin n, (i : ℕ) :=
    Equiv.sum_comp f (fun i => (i : ℕ))
  have hall := (Finset.sum_eq_sum_iff_of_le (fun i (_ : i ∈ Finset.univ) => h1 i)).mp hsum.symm
  ext i
  exact (hall i (Finset.mem_univ i)).symm

/-- A permutation has no inversions exactly when it is the identity. -/
theorem invCount_eq_zero_iff (σ : Equiv.Perm (Fin n)) : invCount σ = 0 ↔ σ = 1 := by
  constructor
  · intro h
    rw [invCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff] at h
    refine perm_eq_one_of_strictMono σ ?_
    intro x y hxy
    have hxy' := h (Finset.mem_univ (x, y))
    push_neg at hxy'
    exact lt_of_le_of_ne (hxy' hxy) fun hcon => hxy.ne (σ.injective hcon)
  · rintro rfl
    rw [invCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    rintro p -
    push_neg
    intro hp
    simpa using hp.le

/-- **The sign of a permutation is the parity of its number of inversions.**  This is the
bridge between the group-theoretic sign homomorphism and the combinatorics of inversions. -/
theorem sign_eq_neg_one_pow_invCount (σ : Equiv.Perm (Fin n)) :
    (Equiv.Perm.sign σ : ℤ) = (-1) ^ invCount σ := by
  induction hN : invCount σ using Nat.strong_induction_on generalizing σ with
  | _ N ih =>
    rcases Nat.eq_zero_or_pos N with rfl | hpos
    · rw [(invCount_eq_zero_iff σ).mp hN]
      simp
    · match n with
      | 0 => exact absurd ((invCount_eq_zero_iff σ).mpr (Subsingleton.elim _ _)) (by omega)
      | (m + 1) =>
        have hex : ∃ t : Fin m, ¬ (σ t.castSucc < σ t.succ) := by
          by_contra hc
          push_neg at hc
          have h1 : σ = 1 := perm_eq_one_of_strictMono σ (Fin.strictMono_iff_lt_succ.mpr hc)
          rw [(invCount_eq_zero_iff σ).mpr h1] at hN
          omega
        obtain ⟨t, ht⟩ := hex
        push_neg at ht
        have hne : σ t.succ ≠ σ t.castSucc := fun hcon =>
          (Fin.castSucc_lt_succ (i := t)).ne (σ.injective hcon).symm
        have hlt : σ t.succ < σ t.castSucc := lt_of_le_of_ne ht hne
        set s : Equiv.Perm (Fin (m + 1)) := Equiv.swap t.castSucc t.succ with hs
        have hs2 : s * s = 1 := by rw [hs, Equiv.swap_mul_self]
        have hstep : (σ * s) t.castSucc < (σ * s) t.succ := by
          rw [Equiv.Perm.mul_apply, Equiv.Perm.mul_apply, hs, Equiv.swap_apply_left,
            Equiv.swap_apply_right]
          exact hlt
        have hcount := invCount_mul_swap t (σ * s) hstep
        rw [mul_assoc, hs2, mul_one] at hcount
        have hIH := ih (invCount (σ * s)) (by omega) (σ * s) rfl
        have hsign : Equiv.Perm.sign σ = - Equiv.Perm.sign (σ * s) := by
          rw [map_mul, hs, Equiv.Perm.sign_swap (Fin.castSucc_lt_succ (i := t)).ne]
          simp
        rw [hsign]
        push_cast
        rw [hIH, ← hN, hcount]
        ring

end Inversions

/-! ### The `q`-analogue: `q`-right-quantum matrices and the `q`-Cayley determinant

Scalars now come from a commutative ring `K` acting on `R`, and `q : Kˣ` is an invertible
scalar.  A single inversion of a permutation carries the weight `-q⁻¹`, so the `q`-Cayley
determinant is `∑_σ (-q⁻¹)^{inv σ} A_{σ(1)1} ⋯ A_{σ(n)n}`.  Swapping two adjacent columns of a
`q`-right-quantum matrix multiplies it by `-q⁻¹`; at `q = 1` this is `cdet_swap_adjacent_cols`.
-/

section QCase

variable {K : Type*} [CommRing K] [Algebra K R]


/-- The weight `-q⁻¹` of a single inversion. -/
def qsign (q : Kˣ) : K := -((q⁻¹ : Kˣ) : K)

/-- The **`q`-Cayley determinant** of a square matrix over a noncommutative `K`-algebra. -/
def qcdet (q : Kˣ) (A : Matrix (Fin n) (Fin n) R) : R :=
  ∑ σ : Equiv.Perm (Fin n), (qsign q ^ invCount σ) • cword A σ

/-- At `q = 1` the `q`-Cayley determinant is the Cayley determinant: the weight `(-1)^{inv σ}`
is the sign of `σ`. -/
theorem qcdet_one_eq_cdet (A : Matrix (Fin n) (Fin n) R) : qcdet (1 : ℤˣ) A = cdet A := by
  unfold qcdet cdet
  refine Finset.sum_congr rfl fun σ _ => ?_
  rw [sign_eq_neg_one_pow_invCount σ]
  congr 1

/-- The **`q`-right-quantum** relations. -/
structure IsQRightQuantum (q : Kˣ) (A : Matrix (Fin n) (Fin n) R) : Prop where
  col_comm : ∀ i j k, i < j → A i k * A j k = ((q⁻¹ : Kˣ) : K) • (A j k * A i k)
  cross : ∀ i j k l, i < j → k < l →
    A i k * A j l - ((q⁻¹ : Kˣ) : K) • (A j k * A i l)
      = A j l * A i k - (q : K) • (A i l * A j k)


private lemma q_pair_zero {q : Kˣ} {A : Matrix (Fin (m + 1)) (Fin (m + 1)) R}
    (hA : IsQRightQuantum q A) (t : Fin m) (σ : Equiv.Perm (Fin (m + 1)))
    (hσ : σ t.castSucc < σ t.succ) :
    ((qsign (K := K) q ^ invCount σ) •
          cword (A.submatrix id (Equiv.swap t.castSucc t.succ)) σ
        - (qsign (K := K) q * qsign q ^ invCount σ) • cword A σ)
      + ((qsign (K := K) q ^ invCount (σ * Equiv.swap t.castSucc t.succ)) •
            cword (A.submatrix id (Equiv.swap t.castSucc t.succ))
              (σ * Equiv.swap t.castSucc t.succ)
          - (qsign (K := K) q * qsign q ^ invCount (σ * Equiv.swap t.castSucc t.succ)) •
            cword A (σ * Equiv.swap t.castSucc t.succ)) = 0 := by
  obtain ⟨P, Q, e2, e4, e1, e3⟩ := cword_split_pair A t σ
  set i := σ t.castSucc
  set j := σ t.succ
  have hkl : t.castSucc < t.succ := Fin.castSucc_lt_succ
  have hq : ((q⁻¹ : Kˣ) : K) * (q : K) = 1 := Units.inv_mul q
  have inner : A i t.succ * A j t.castSucc - qsign (K := K) q • (A i t.castSucc * A j t.succ)
      + qsign (K := K) q • (A j t.succ * A i t.castSucc)
      - (qsign (K := K) q * qsign q) • (A j t.castSucc * A i t.succ) = 0 := by
    have h' := congrArg (fun x : R => ((q⁻¹ : Kˣ) : K) • x) (hA.cross i j t.castSucc t.succ hσ hkl)
    simp only [smul_sub, smul_smul, hq, one_smul] at h'
    simp only [qsign, neg_smul, neg_mul]
    linear_combination (norm := module) h'
  have hPQ : P * (A i t.succ * A j t.castSucc
        - qsign (K := K) q • (A i t.castSucc * A j t.succ)
        + qsign (K := K) q • (A j t.succ * A i t.castSucc)
        - (qsign (K := K) q * qsign q) • (A j t.castSucc * A i t.succ)) * Q = 0 := by
    rw [inner]; simp
  have hPQ' : P * (A i t.succ * A j t.castSucc) * Q
      - qsign (K := K) q • (P * (A i t.castSucc * A j t.succ) * Q)
      + qsign (K := K) q • (P * (A j t.succ * A i t.castSucc) * Q)
      - (qsign (K := K) q * qsign q) • (P * (A j t.castSucc * A i t.succ) * Q) = 0 := by
    rw [← hPQ]
    simp only [mul_sub, sub_mul, mul_add, add_mul, mul_smul_comm, smul_mul_assoc]
  rw [invCount_mul_swap t σ hσ, pow_succ, e1, e2, e3, e4]
  linear_combination (norm := module) (qsign (K := K) q ^ invCount σ) • hPQ'

/-- **Swapping two adjacent columns of a `q`-right-quantum matrix multiplies the `q`-Cayley
determinant by `-q⁻¹`.** -/
theorem qcdet_swap_adjacent_cols {q : Kˣ} {A : Matrix (Fin (m + 1)) (Fin (m + 1)) R}
    (hA : IsQRightQuantum q A) (t : Fin m) :
    qcdet q (A.submatrix id (Equiv.swap t.castSucc t.succ)) = qsign q • qcdet q A := by
  set s : Equiv.Perm (Fin (m + 1)) := Equiv.swap t.castSucc t.succ with hs
  have hkl : t.castSucc ≠ t.succ := Fin.castSucc_lt_succ.ne
  have hs2 : s * s = 1 := by rw [hs, Equiv.swap_mul_self]
  have hsne : s ≠ 1 := by
    intro hcon
    apply hkl
    have hfix : s t.castSucc = t.castSucc := by rw [hcon]; rfl
    rw [hs, Equiv.swap_apply_left] at hfix
    exact hfix.symm
  have hsum : qcdet q (A.submatrix id s) - qsign q • qcdet q A
      = ∑ σ : Equiv.Perm (Fin (m + 1)),
          ((qsign (K := K) q ^ invCount σ) • cword (A.submatrix id s) σ
            - (qsign (K := K) q * qsign q ^ invCount σ) • cword A σ) := by
    unfold qcdet
    rw [Finset.smul_sum, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun σ _ => by rw [smul_smul]
  have hzero : (∑ σ : Equiv.Perm (Fin (m + 1)),
      ((qsign (K := K) q ^ invCount σ) • cword (A.submatrix id s) σ
        - (qsign (K := K) q * qsign q ^ invCount σ) • cword A σ)) = 0 := by
    refine Finset.sum_involution (fun σ _ => σ * s) ?_ ?_ (fun _ _ => Finset.mem_univ _) ?_
    · intro σ _
      have hne : σ t.castSucc ≠ σ t.succ := fun hcon => hkl (σ.injective hcon)
      rcases lt_or_gt_of_ne hne with hlt | hgt
      · exact q_pair_zero hA t σ hlt
      · have hσ' : (σ * s) t.castSucc < (σ * s) t.succ := by
          rw [Equiv.Perm.mul_apply, Equiv.Perm.mul_apply, hs, Equiv.swap_apply_left,
            Equiv.swap_apply_right]
          exact hgt
        have h2 := q_pair_zero hA t (σ * s) hσ'
        rw [mul_assoc, hs2, mul_one] at h2
        rw [add_comm]
        exact h2
    · intro σ _ _ hcon
      refine hsne ?_
      have := congrArg (fun x => σ⁻¹ * x) hcon
      simpa [← mul_assoc] using this
    · intro σ _
      show σ * s * s = σ
      rw [mul_assoc, hs2, mul_one]
  have := hsum.trans hzero
  exact sub_eq_zero.mp this

end QCase

/-- The classical alternating property of the determinant, recovered from the noncommutative
theorem. -/
theorem det_col_perm_of_cdet {S : Type*} [CommRing S] (A : Matrix (Fin n) (Fin n) S)
    (τ : Equiv.Perm (Fin n)) :
    (A.submatrix id τ).det = (Equiv.Perm.sign τ : ℤ) • A.det := by
  rw [← cdet_eq_det, ← cdet_eq_det, cdet_col_perm (isRightQuantum_of_comm A) τ]

/-! ### The `2 × 2` case, and genuinely noncommutative examples

These make the theory concrete and show that the hypotheses above are not vacuous. -/

/-- The Cayley determinant of a `2 × 2` matrix is `a₁₁ a₂₂ - a₂₁ a₁₂` (in this order!). -/
theorem cdet_fin_two (A : Matrix (Fin 2) (Fin 2) R) :
    cdet A = A 0 0 * A 1 1 - A 1 0 * A 0 1 := by
  have huniv : (Finset.univ : Finset (Equiv.Perm (Fin 2))) = {1, Equiv.swap 0 1} := by decide
  rw [cdet, huniv, Finset.sum_pair (by decide)]
  simp [cword, List.ofFn_succ, sub_eq_add_neg]

/-- The `q`-Cayley determinant of a `2 × 2` matrix is `a₁₁ a₂₂ - q⁻¹ a₂₁ a₁₂`. -/
theorem qcdet_fin_two {K : Type*} [CommRing K] [Algebra K R] (q : Kˣ)
    (A : Matrix (Fin 2) (Fin 2) R) :
    qcdet q A = A 0 0 * A 1 1 - ((q⁻¹ : Kˣ) : K) • (A 1 0 * A 0 1) := by
  have huniv : (Finset.univ : Finset (Equiv.Perm (Fin 2))) = {1, Equiv.swap 0 1} := by decide
  have h1 : invCount (1 : Equiv.Perm (Fin 2)) = 0 := by decide
  have h2 : invCount (Equiv.swap (0 : Fin 2) 1) = 1 := by decide
  rw [qcdet, huniv, Finset.sum_pair (by decide), h1, h2]
  simp [cword, List.ofFn_succ, qsign, sub_eq_add_neg]

/-- For arbitrary `x y` in an arbitrary (noncommutative) ring, the matrix `!![x, y; 1, 1]` is
right-quantum.  Its Cayley determinant is `x - y`. -/
theorem isRightQuantum_of_row_ones (x y : R) :
    IsRightQuantum (!![x, y; 1, 1] : Matrix (Fin 2) (Fin 2) R) := by
  constructor
  · intro i j k _
    fin_cases i <;> fin_cases j <;> fin_cases k <;> simp
  · intro i j k l _ _
    fin_cases i <;> fin_cases j <;> fin_cases k <;> fin_cases l <;> simp

/-- The Cayley determinant of the right-quantum matrix `!![x, y; 1, 1]` is `x - y`. -/
example (x y : R) : cdet (!![x, y; 1, 1] : Matrix (Fin 2) (Fin 2) R) = x - y := by
  rw [cdet_fin_two]
  simp

/-- Swapping the two columns of the right-quantum matrix `!![x, y; 1, 1]` indeed negates its
Cayley determinant, as `cdet_col_perm` predicts. -/
example (x y : R) :
    cdet (!![y, x; 1, 1] : Matrix (Fin 2) (Fin 2) R)
      = -cdet (!![x, y; 1, 1] : Matrix (Fin 2) (Fin 2) R) := by
  rw [cdet_fin_two, cdet_fin_two]
  simp

/-- Such matrices really are noncommutative: over `2 × 2` rational matrices the entries `x, y`
can be chosen not to commute. -/
example : ∃ x y : Matrix (Fin 2) (Fin 2) ℚ, x * y ≠ y * x := by
  refine ⟨!![0, 1; 0, 0], !![0, 0; 1, 0], ?_⟩
  intro h
  have := congrFun (congrFun h 0) 0
  simp [Matrix.mul_apply, Fin.sum_univ_two] at this

/-! #### The right-quantum hypothesis is necessary

Without it, column antisymmetry of the Cayley determinant genuinely fails. -/

/-- A nilpotent `2 × 2` rational matrix, used as a noncommuting ring element. -/
def exE : Matrix (Fin 2) (Fin 2) ℚ := !![0, 1; 0, 0]

/-- Its transpose; `exE * exF ≠ exF * exE`. -/
def exF : Matrix (Fin 2) (Fin 2) ℚ := !![0, 0; 1, 0]

/-- The diagonal matrix `!![exE, 0; 0, exF]` is *not* right-quantum. -/
example : ¬ IsRightQuantum (!![exE, 0; 0, exF] : Matrix (Fin 2) (Fin 2)
    (Matrix (Fin 2) (Fin 2) ℚ)) := by
  intro h
  have hc := h.cross 0 1 0 1 (by decide) (by decide)
  simp [exE, exF] at hc

/-- ... and for it the conclusion of `cdet_col_perm` fails: swapping the two columns does not
negate the Cayley determinant.  So the right-quantum relations are not decoration. -/
example : cdet (!![(0 : Matrix (Fin 2) (Fin 2) ℚ), exE; exF, 0])
    ≠ - cdet (!![exE, 0; 0, exF]) := by
  rw [cdet_fin_two, cdet_fin_two]
  simp [exE, exF]

/-- **The generators of the quantum group `M_q(2)` form a `q`-right-quantum matrix.**
Only four of the six defining relations of `M_q(2)` are needed. -/
theorem isQRightQuantum_of_quantumTwo {K : Type*} [CommRing K] [Algebra K R] (q : Kˣ)
    (a b c d : R) (hca : c * a = (q : K) • (a * c)) (hdb : d * b = (q : K) • (b * d))
    (hcb : c * b = b * c)
    (hda : a * d - d * a = ((q⁻¹ : Kˣ) : K) • (b * c) - (q : K) • (b * c)) :
    IsQRightQuantum q (!![a, b; c, d] : Matrix (Fin 2) (Fin 2) R) := by
  have hqq : ((q⁻¹ : Kˣ) : K) * (q : K) = 1 := Units.inv_mul q
  have h1 : a * c = ((q⁻¹ : Kˣ) : K) • (c * a) := by rw [hca, smul_smul, hqq, one_smul]
  have h2 : b * d = ((q⁻¹ : Kˣ) : K) • (d * b) := by rw [hdb, smul_smul, hqq, one_smul]
  have h3 : a * d - ((q⁻¹ : Kˣ) : K) • (c * b) = d * a - (q : K) • (b * c) := by
    rw [hcb]
    linear_combination (norm := module) hda
  constructor
  · intro i j k hij
    fin_cases i <;> fin_cases j <;> fin_cases k <;>
      first
        | exact absurd hij (by decide)
        | simpa using h1
        | simpa using h2
  · intro i j k l hij hkl
    fin_cases i <;> fin_cases j <;> fin_cases k <;> fin_cases l <;>
      first
        | exact absurd hij (by decide)
        | exact absurd hkl (by decide)
        | simpa using h3

/-- Interchanging the two columns of a `2 × 2` `q`-right-quantum matrix (in particular of a
quantum matrix of `M_q(2)`) multiplies the `q`-Cayley determinant by `-q⁻¹`. -/
theorem qcdet_swap_cols_fin_two {K : Type*} [CommRing K] [Algebra K R] (q : Kˣ) (a b c d : R)
    (h : IsQRightQuantum q (!![a, b; c, d] : Matrix (Fin 2) (Fin 2) R)) :
    qcdet q (!![b, a; d, c] : Matrix (Fin 2) (Fin 2) R)
      = qsign q • qcdet q (!![a, b; c, d] : Matrix (Fin 2) (Fin 2) R) := by
  have hsub : (!![a, b; c, d] : Matrix (Fin 2) (Fin 2) R).submatrix id
      (Equiv.swap (0 : Fin 2) 1) = !![b, a; d, c] := by
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [Equiv.swap_apply_left, Equiv.swap_apply_right]
  have hmain := qcdet_swap_adjacent_cols h (0 : Fin 1)
  rw [show ((0 : Fin 1) : Fin 1).castSucc = (0 : Fin 2) from rfl,
    show ((0 : Fin 1) : Fin 1).succ = (1 : Fin 2) from rfl, hsub] at hmain
  exact hmain

end QuantumDet