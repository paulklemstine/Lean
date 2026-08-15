import Mathlib
import Tropical.NeuralNetworks.EOSWidthCureProbability

/-!
# Depth propagation of the boundary margin

The recorded NET-26 failure mode is a *smooth* progressive-unroll collapse
(`n = 5 : 1.0000 → n = 6 : 0.9556 → n = 7 : 0.1445 → n = 8 : 0.0166`) rather
than a cliff.  This file explains the shape in the max-plus model: a recurrent
max-plus layer is monotone and *shift-equivariant*, hence can never amplify a
bounded boundary-vs-digit gap, at any depth.

* `mplusApply_mono`, `mplusApply_shift` — a max-plus layer is order preserving
  and commutes with tropical scalars, so a gap of `c` stays a gap of `c`.
* `mplusIter_shift` — by induction, the same at every depth `n`.
* `eosOf_le_shift_eosVec` — a block-supported boundary token is dominated by
  `maxᵢ cᵢ ⊙ (the all-digit token)`.
* `depth_uniform_ambiguity` — therefore, at *every* depth, the boundary
  trajectory stays within `maxᵢ cᵢ` of the all-digit trajectory: the fragile
  regime can never build up a large margin, no matter how deep the unroll.
* `exclusive_dim_persists` — by contrast, under the identity dynamics an
  exclusive dimension survives at every depth, so the robust regime keeps its
  unbounded margin.
-/

namespace EOSWidth

open Finset

/-- One max-plus (tropical) layer `x ↦ A ⊙ x`. -/
def mplusApply {m n : ℕ} (A : Fin m → Fin n → WithBot ℝ) (x : TVec n) : TVec m :=
  fun k => univ.sup fun i => A k i + x i

/-- `n`-fold unrolling of a square max-plus layer. -/
def mplusIter {N : ℕ} (A : Fin N → Fin N → WithBot ℝ) : ℕ → TVec N → TVec N
  | 0, x => x
  | (n + 1), x => mplusApply A (mplusIter A n x)

/-- A max-plus layer is monotone. -/
theorem mplusApply_mono {m n : ℕ} (A : Fin m → Fin n → WithBot ℝ) {x y : TVec n}
    (h : ∀ i, x i ≤ y i) (k : Fin m) : mplusApply A x k ≤ mplusApply A y k := by
  refine Finset.sup_le ?_
  intro i _
  exact le_trans (add_le_add (le_refl (A k i)) (h i))
    (Finset.le_sup (f := fun i => A k i + y i) (mem_univ i))

/-- **No amplification.**  A max-plus layer commutes with tropical scalars, so a
gap bounded by `c` before the layer is still bounded by `c` after it. -/
theorem mplusApply_shift {m n : ℕ} (A : Fin m → Fin n → WithBot ℝ) (c : ℝ)
    {x y : TVec n} (h : ∀ i, x i ≤ (c : WithBot ℝ) + y i) (k : Fin m) :
    mplusApply A x k ≤ (c : WithBot ℝ) + mplusApply A y k := by
  refine Finset.sup_le ?_
  intro i _
  have h1 : A k i + x i ≤ A k i + ((c : WithBot ℝ) + y i) :=
    add_le_add (le_refl (A k i)) (h i)
  have h2 : A k i + ((c : WithBot ℝ) + y i) = (c : WithBot ℝ) + (A k i + y i) := by
    rw [add_left_comm]
  have h3 : (c : WithBot ℝ) + (A k i + y i) ≤ (c : WithBot ℝ) + mplusApply A y k :=
    add_le_add (le_refl _) (Finset.le_sup (f := fun i => A k i + y i) (mem_univ i))
  exact le_trans h1 (le_trans (le_of_eq h2) h3)

/-- **Depth-uniform non-amplification.**  Iterating the layer keeps the gap
bounded by the same tropical scalar at every depth. -/
theorem mplusIter_shift {N : ℕ} (A : Fin N → Fin N → WithBot ℝ) (c : ℝ)
    {x y : TVec N} (h : ∀ i, x i ≤ (c : WithBot ℝ) + y i) :
    ∀ (n : ℕ) (k : Fin N), mplusIter A n x k ≤ (c : WithBot ℝ) + mplusIter A n y k := by
  intro n
  induction n with
  | zero => intro k; exact h k
  | succ n ih =>
      intro k
      exact mplusApply_shift A c (fun i => ih i) k

/-- A block-supported boundary token is dominated by the tropical scalar
`maxᵢ cᵢ` times the all-digit token. -/
theorem eosOf_le_shift_eosVec {N D : ℕ} (c : Fin D → ℝ) {v : ℝ}
    (hv : ∀ j : Fin D, c j ≤ v) (i : Fin N) :
    (eosOf c : TVec N) i ≤ (v : WithBot ℝ) + eosVec N D i := by
  unfold eosOf eosVec
  by_cases h : (i : ℕ) < D
  · rw [dif_pos h, if_pos h]
    have : ((c ⟨(i : ℕ), h⟩ : ℝ) : WithBot ℝ) ≤ ((v : ℝ) : WithBot ℝ) := by
      exact_mod_cast hv _
    simpa using this
  · rw [dif_neg h]
    exact bot_le

/-- **The fragile regime cannot build a margin at depth.**  At every unroll
depth the boundary trajectory stays within `maxᵢ cᵢ` of the all-digit
trajectory, so the smooth degradation observed with `E ≤ D` is forced: there is
no depth at which a block-supported boundary token becomes distinguishable by a
large margin. -/
theorem depth_uniform_ambiguity {N D : ℕ} (A : Fin N → Fin N → WithBot ℝ)
    (c : Fin D → ℝ) {v : ℝ} (hv : ∀ j : Fin D, c j ≤ v) (n : ℕ) (k : Fin N) :
    mplusIter A n (eosOf c) k ≤ (v : WithBot ℝ) + mplusIter A n (eosVec N D) k :=
  mplusIter_shift A v (eosOf_le_shift_eosVec c hv) n k

/-! ## The robust regime keeps its margin at depth -/

/-- The identity max-plus layer. -/
def idMat (N : ℕ) : Fin N → Fin N → WithBot ℝ := fun k i => if k = i then 0 else ⊥

lemma mplusApply_idMat {N : ℕ} (x : TVec N) : mplusApply (idMat N) x = x := by
  classical
  funext k
  have key : ∀ i : Fin N, (idMat N k i + x i) = if i = k then x i else ⊥ := by
    intro i
    by_cases h : i = k
    · subst h; simp [idMat]
    · have : ¬ (k = i) := fun hk => h hk.symm
      simp [idMat, this, h]
  rw [mplusApply]
  simp only [key]
  exact sup_ite_bot k x

lemma mplusIter_idMat {N : ℕ} (n : ℕ) (x : TVec N) : mplusIter (idMat N) n x = x := by
  induction n with
  | zero => rfl
  | succ n ih => rw [mplusIter, ih, mplusApply_idMat]

/-- **The robust regime survives depth.**  Under the identity dynamics an
exclusive dimension is preserved at every depth, so the unbounded separation of
`exclusive_dim_unbounded_margin` remains available after any number of unroll
steps. -/
theorem exclusive_dim_persists {N D : ℕ} (x : TVec N) {p : Fin N}
    (hp : ExclusiveDim N D x p) (n : ℕ) :
    ExclusiveDim N D (mplusIter (idMat N) n x) p := by
  rw [mplusIter_idMat]
  exact hp

end EOSWidth