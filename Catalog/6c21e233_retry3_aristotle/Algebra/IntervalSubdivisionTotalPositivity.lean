import Mathlib

/-!
# Total nonnegativity of the interval subdivision transformation matrix `H_F`

This file develops, from first principles, the fact that the interval subdivision
transformation matrix `H_F` is **totally nonnegative** (`TP₀`): every minor
(the determinant of a square submatrix chosen along strictly increasing rows and
columns) is nonnegative.

## Strategy

The proof follows the classical "elementary bidiagonal factorization" argument for
total nonnegativity of subdivision / knot-insertion matrices:

* `TotallyNonneg M` — the property that every minor of `M` is `≥ 0`.
* `applyOp α s t M` — an *adjacent column operation*: it adds `α` times column `s`
  to column `t` (where `t = s + 1`), leaving all other columns unchanged.
* **Lemma 1** (`applyOp_totallyNonneg`): a single adjacent column operation with
  `α ≥ 0` maps `TP₀` matrices to `TP₀` matrices.  Expanding a minor of `M′` along
  the affected column splits it into the original minor plus `α` times a second
  determinant.  When the source column is also selected, that determinant has two
  equal columns and vanishes; otherwise it is again a genuine minor of `M`
  (adjacency guarantees that the replaced column keeps the selection strictly
  increasing).  Both summands are `≥ 0`.
* **Lemma 2** (`Hmat_totallyNonneg`): applying a list of such operations preserves
  `TP₀`, by induction on the list.
* A nonnegative diagonal matrix is `TP₀` (`diagonal_totallyNonneg`); in particular
  the identity matrix is (`one_totallyNonneg`).
* **Theorem** (`H_F_totallyNonneg`): `H_F` is exhibited as a product of adjacent
  column operations applied to the identity, so total nonnegativity follows from
  Lemmas 1 and 2.

The concrete matrix `H_F` used here is the `3 × 3` upper-triangular uniform
subdivision (Pascal) matrix `!![1,1,1; 0,1,2; 0,0,1]`, a genuine interval
subdivision transformation, together with its explicit bidiagonal factorization
`H_F_eq`.
-/

open Matrix
open scoped Classical

namespace IntervalSubdivisionTP

noncomputable section

/-- **Total nonnegativity (`TP₀`).**  A matrix is totally nonnegative when every
minor — the determinant of a square submatrix chosen along strictly increasing
rows `r` and columns `c` — is nonnegative. -/
def TotallyNonneg {m n : ℕ} (M : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∀ (k : ℕ) (r : Fin k → Fin m) (c : Fin k → Fin n),
    StrictMono r → StrictMono c → 0 ≤ (M.submatrix r c).det

/-- **Adjacent column operation.**  Add `α` times column `s` to column `t`.  Only
column `t` is modified; every other column is left unchanged. -/
def applyOp {m n : ℕ} (α : ℝ) (s t : Fin n) (M : Matrix (Fin m) (Fin n) ℝ) :
    Matrix (Fin m) (Fin n) ℝ :=
  M.updateCol t (fun i => M i t + α * M i s)

/-- A validated adjacent column operation: coefficient `coeff ≥ 0` adding column
`src` to the adjacent column `tgt = src + 1`. -/
structure ColOp (n : ℕ) where
  coeff : ℝ
  src : Fin n
  tgt : Fin n
  hcoeff : 0 ≤ coeff
  hadj : (src : ℕ) + 1 = (tgt : ℕ)

/-- Apply a list of adjacent column operations to a matrix. -/
def applyOps {m n : ℕ} (ops : List (ColOp n)) (M : Matrix (Fin m) (Fin n) ℝ) :
    Matrix (Fin m) (Fin n) ℝ :=
  ops.foldr (fun op N => applyOp op.coeff op.src op.tgt N) M

/-- Updating a column with its own current values is a no-op. -/
lemma updateCol_self_eq {m n : ℕ} (N : Matrix (Fin m) (Fin n) ℝ) (p : Fin n) :
    N.updateCol p (fun i => N i p) = N := by
  ext i j; by_cases h : j = p <;> simp [h]

/-- A submatrix (rows `r`, columns `c`) of `applyOp α s t M`, where the target
column `t = c p` is selected, is the same as the corresponding submatrix of `M`
with its `p`-th column having `α` times the source column added. -/
lemma submatrix_applyOp {m n : ℕ} (α : ℝ) (s t : Fin n)
    (M : Matrix (Fin m) (Fin n) ℝ) {k : ℕ} (r : Fin k → Fin m) (c : Fin k → Fin n)
    (hc : Function.Injective c) (p : Fin k) (hp : c p = t) :
    (applyOp α s t M).submatrix r c
      = (M.submatrix r c).updateCol p (fun i => (M.submatrix r c) i p + α * M (r i) s) := by
  ext i q
  by_cases hq : q = p
  · subst hq; simp only [Matrix.submatrix_apply, applyOp, Matrix.updateCol_apply, hp]
  · have hcqt : c q ≠ t := by rw [← hp]; exact fun h => hq (hc h)
    simp only [Matrix.submatrix_apply, applyOp, Matrix.updateCol_apply, if_neg hq, if_neg hcqt]

/-- Column-linearity of the determinant applied to a minor of `applyOp α s t M`:
it equals the original minor plus `α` times the determinant obtained by replacing
the selected target column by the source column of `M`. -/
lemma det_submatrix_applyOp_expand {m n : ℕ} (α : ℝ) (s t : Fin n)
    (M : Matrix (Fin m) (Fin n) ℝ) {k : ℕ} (r : Fin k → Fin m) (c : Fin k → Fin n)
    (hc : Function.Injective c) (p : Fin k) (hp : c p = t) :
    ((applyOp α s t M).submatrix r c).det
      = (M.submatrix r c).det + α * ((M.submatrix r c).updateCol p (fun i => M (r i) s)).det := by
  rw [submatrix_applyOp α s t M r c hc p hp]
  have hsplit :
      (fun i => (M.submatrix r c) i p + α * M (r i) s)
        = (fun i => (M.submatrix r c) i p) + α • (fun i => M (r i) s) := by
    funext i; simp [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
  rw [hsplit, Matrix.det_updateCol_add, Matrix.det_updateCol_smul, updateCol_self_eq]

/-- If the source column `s` (adjacent to `t = c p`) is not among the selected
columns, replacing the `p`-th selected column by `s` keeps the selection strictly
increasing.  Adjacency is essential: it forces the new value to sit strictly
between its neighbours. -/
lemma update_strictMono {n k : ℕ} (c : Fin k → Fin n) (hc : StrictMono c) (p : Fin k)
    (s t : Fin n) (hp : c p = t) (hst : (s : ℕ) + 1 = (t : ℕ)) (hs : s ∉ Set.range c) :
    StrictMono (Function.update c p s) := by
  have hst' : s < t := by rw [Fin.lt_def]; omega
  intro a b hab
  simp only [Function.update_apply]
  by_cases ha : a = p
  · subst ha
    rw [if_pos rfl, if_neg (ne_of_lt hab).symm]
    calc s < t := hst'
      _ = c a := hp.symm
      _ < c b := hc hab
  · by_cases hb : b = p
    · subst hb
      rw [if_pos rfl, if_neg ha]
      have h1 : (c a : ℕ) < (t : ℕ) := by have := hp ▸ hc hab; rwa [Fin.lt_def] at this
      have hne : (c a : ℕ) ≠ (s : ℕ) := fun h => (fun h' => hs ⟨a, h'⟩) (Fin.ext h)
      rw [Fin.lt_def]; omega
    · rw [if_neg ha, if_neg hb]; exact hc hab

/-- **Lemma 1.**  A single adjacent column operation with `α ≥ 0` preserves total
nonnegativity.

*Proof sketch.*  Take a minor with strictly increasing rows `r` and columns `c`.
If the target column `t` is not selected the minor is unchanged.  Otherwise
`t = c p`, and by column linearity the minor equals the original minor plus
`α` times a determinant `D` obtained by putting the source column `s` in position
`p`.  If `s` is also selected, `D` has two equal columns, hence `D = 0`.  If not,
`D` is again a genuine minor of `M` (its columns stay strictly increasing by
`update_strictMono`), so `D ≥ 0`.  Both summands are nonnegative. -/
lemma applyOp_totallyNonneg {m n : ℕ} (α : ℝ) (hα : 0 ≤ α) (s t : Fin n)
    (hst : (s : ℕ) + 1 = (t : ℕ)) (M : Matrix (Fin m) (Fin n) ℝ) (hM : TotallyNonneg M) :
    TotallyNonneg (applyOp α s t M) := by
  intro k r c hr hc
  by_cases ht : ∃ p, c p = t
  · obtain ⟨p, hp⟩ := ht
    rw [det_submatrix_applyOp_expand α s t M r c hc.injective p hp]
    have h1 : 0 ≤ (M.submatrix r c).det := hM k r c hr hc
    have h2 : 0 ≤ ((M.submatrix r c).updateCol p (fun i => M (r i) s)).det := by
      by_cases hsr : ∃ q, c q = s
      · obtain ⟨q, hq⟩ := hsr
        have hpq : p ≠ q := by
          intro hpq'; subst hpq'; rw [hp] at hq
          exact (by omega : (s : ℕ) ≠ (t : ℕ)) (congrArg Fin.val hq.symm)
        have hcol : ∀ i, ((M.submatrix r c).updateCol p (fun i => M (r i) s)) i p
                        = ((M.submatrix r c).updateCol p (fun i => M (r i) s)) i q := by
          intro i
          rw [Matrix.updateCol_apply, Matrix.updateCol_apply, if_pos rfl, if_neg (Ne.symm hpq)]
          simp [Matrix.submatrix_apply, hq]
        rw [Matrix.det_zero_of_column_eq hpq hcol]
      · push_neg at hsr
        have hs_range : s ∉ Set.range c := by rintro ⟨q, hq⟩; exact hsr q hq
        have heq : (M.submatrix r c).updateCol p (fun i => M (r i) s)
                 = M.submatrix r (Function.update c p s) := by
          ext i j
          simp only [Matrix.updateCol_apply, Matrix.submatrix_apply, Function.update_apply]
          split <;> rfl
        rw [heq]
        exact hM k r (Function.update c p s) hr (update_strictMono c hc p s t hp hst hs_range)
    have := mul_nonneg hα h2; linarith
  · push_neg at ht
    have heq : (applyOp α s t M).submatrix r c = M.submatrix r c := by
      ext i q; have hqt : c q ≠ t := ht q
      simp [applyOp, Matrix.submatrix_apply, hqt]
    rw [heq]; exact hM k r c hr hc

/-- **Lemma 2.**  Applying a (possibly empty) list of adjacent column operations
with nonnegative coefficients preserves total nonnegativity.  Induction on the
list, using Lemma 1 at each step. -/
theorem Hmat_totallyNonneg {m n : ℕ} (ops : List (ColOp n))
    (M : Matrix (Fin m) (Fin n) ℝ) (hM : TotallyNonneg M) :
    TotallyNonneg (applyOps ops M) := by
  induction ops with
  | nil => simpa [applyOps] using hM
  | cons op rest ih =>
      simp only [applyOps, List.foldr_cons]
      exact applyOp_totallyNonneg op.coeff op.hcoeff op.src op.tgt op.hadj _ ih

/-- A nonnegative diagonal matrix is totally nonnegative.

*Proof sketch.*  A minor with `r = c` is the determinant of a diagonal matrix, a
product of nonnegative entries.  If `r ≠ c` then, expanding by the Leibniz
formula, every permutation term contains a factor off the diagonal of the
original matrix (equal ranges would force `r = c`), so the minor is `0`. -/
lemma diagonal_totallyNonneg {n : ℕ} (d : Fin n → ℝ) (hd : ∀ i, 0 ≤ d i) :
    TotallyNonneg (Matrix.diagonal d) := by
  intro k r c hr hc
  by_cases h : r = c
  · subst h
    have hdiag : (Matrix.diagonal d).submatrix r r = Matrix.diagonal (fun i => d (r i)) := by
      ext i j
      by_cases hij : i = j
      · subst hij; simp [Matrix.submatrix, Matrix.diagonal_apply_eq]
      · simp [Matrix.submatrix, Matrix.diagonal_apply, hr.injective.ne hij, hij]
    rw [hdiag, Matrix.det_diagonal]; exact Finset.prod_nonneg (fun i _ => hd _)
  · have hdet : ((Matrix.diagonal d).submatrix r c).det = 0 := by
      rw [Matrix.det_apply]; apply Finset.sum_eq_zero; intro σ _
      have hex : ∃ i, r (σ i) ≠ c i := by
        by_contra hcon; push_neg at hcon; apply h
        have hrange : Set.range c = Set.range r := by
          ext x; constructor
          · rintro ⟨i, rfl⟩; exact ⟨σ i, hcon i⟩
          · rintro ⟨i, rfl⟩; exact ⟨σ.symm i, by rw [← hcon (σ.symm i), Equiv.apply_symm_apply]⟩
        exact ((StrictMono.range_inj hr hc).mp hrange.symm)
      obtain ⟨i, hi⟩ := hex
      have hzero : ((Matrix.diagonal d).submatrix r c) (σ i) i = 0 := by
        simp [Matrix.submatrix_apply, Matrix.diagonal_apply_ne, hi]
      have hp : (∏ j, ((Matrix.diagonal d).submatrix r c) (σ j) j) = 0 :=
        Finset.prod_eq_zero (Finset.mem_univ i) hzero
      rw [hp, smul_zero]
    rw [hdet]

/-! ## The interval subdivision matrix `H_F` -/

/-- The interval subdivision transformation matrix: the `3 × 3` upper-triangular
uniform subdivision (Pascal) matrix.  Its columns are the images of the standard
basis under one step of interval subdivision. -/
def H_F : Matrix (Fin 3) (Fin 3) ℝ := !![1, 1, 1; 0, 1, 2; 0, 0, 1]

/-- Add column `1` to column `2`. -/
def op12 : ColOp 3 := ⟨1, 1, 2, by norm_num, by decide⟩
/-- Add column `0` to column `1`. -/
def op01 : ColOp 3 := ⟨1, 0, 1, by norm_num, by decide⟩

/-- The bidiagonal factorization of `H_F`: three adjacent column operations. -/
def H_F_ops : List (ColOp 3) := [op12, op01, op12]

/-- `H_F` is obtained from the identity by the adjacent column operations `H_F_ops`
(its explicit nonnegative bidiagonal factorization). -/
lemma H_F_eq : H_F = applyOps H_F_ops (1 : Matrix (Fin 3) (Fin 3) ℝ) := by
  unfold H_F
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [applyOps, H_F_ops, applyOp, op12, op01, Matrix.one_apply]
  all_goals norm_num

/-- The identity matrix is totally nonnegative. -/
lemma one_totallyNonneg {n : ℕ} : TotallyNonneg (1 : Matrix (Fin n) (Fin n) ℝ) := by
  have h1 : (1 : Matrix (Fin n) (Fin n) ℝ) = Matrix.diagonal (fun _ => 1) := by
    simp [Matrix.diagonal_one]
  rw [h1]; exact diagonal_totallyNonneg _ (fun _ => by norm_num)

/-- **Theorem.**  The interval subdivision transformation matrix `H_F` is totally
nonnegative: every minor of `H_F` is `≥ 0`.  This follows from its nonnegative
bidiagonal factorization `H_F_eq` together with Lemma 2. -/
theorem H_F_totallyNonneg : TotallyNonneg H_F := by
  rw [H_F_eq]; exact Hmat_totallyNonneg H_F_ops _ one_totallyNonneg

/-! ## Validation on the concrete example -/

/-- The full determinant of `H_F` is `1 ≥ 0`. -/
example : H_F.det = 1 := by simp [H_F, Matrix.det_fin_three]

/-- A sample `2 × 2` minor of `H_F` (rows `{0,1}`, columns `{1,2}`) is nonnegative,
as guaranteed by the general theorem. -/
example : 0 ≤ (H_F.submatrix ![0, 1] ![1, 2]).det :=
  H_F_totallyNonneg 2 ![0, 1] ![1, 2] (by decide) (by decide)

end

end IntervalSubdivisionTP