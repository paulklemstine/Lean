/-
# Degree hierarchy: three-way alignment defeats every pairwise encoding

Two further structural results for the phase-encoding programme.

## 1. Window stability is automatic (`Reindex` section)

Every quantity of the finite-sample calculus (`avg`, `cov`, `varr`, `msse`,
`Rsq`) is invariant under an arbitrary relabelling `e : κ ≃ ι` of the sample
space.  Consequently an *exactly zero* degree-1 effect transfers across windows
with ratio exactly `1`; a measured cross/same ratio different from `1` is
therefore evidence about the estimator, never about a genuine degree-1 signal.

## 2. The degree hierarchy does not stop at `2`

On `G × G × G` (`G` any finite additive commutative group; take `G = ZMod p`)
consider the **three-way alignment** target

  `triAlign (a,b,c) = if a + b + c = 0 then 1 else 0`.

Then `cov_triAlign_pairwise_eq_zero` : *every* predictor built from arbitrary
functions of **pairs** of coordinates,

  `pairwise F G H (a,b,c) = F (a,b) + G (b,c) + H (a,c)`,

has covariance exactly `0` with the target — so the entire degree-`≤2` layer,
interaction encodings included, is blind to it, while the target is trivially
degree-`3` measurable (`Rsq_triAlign_self_eq_one`).

This is the sharp prediction for the next experimental round: if the residual
excess is a `k`-way joint alignment, then encodings of degree `< k` must return
*exactly* zero population gain, no matter how many primes are dialled in.
-/
import Logic.PhaseRouteAlignment

namespace Logic.PhaseRoute

open Finset

/-! ### Relabelling invariance: window stability of exact statements -/

section Reindex

variable {ι κ : Type*} [Fintype ι] [Fintype κ] [Nonempty ι] [Nonempty κ]

omit [Nonempty ι] [Nonempty κ] in
lemma avg_reindex (e : κ ≃ ι) (f : ι → ℝ) : avg (fun k => f (e k)) = avg f := by
  have hcard : Fintype.card κ = Fintype.card ι := Fintype.card_congr e
  simp only [avg, hcard]
  rw [Equiv.sum_comp e f]

omit [Nonempty ι] [Nonempty κ] in
lemma cov_reindex (e : κ ≃ ι) (f g : ι → ℝ) :
    cov (fun k => f (e k)) (fun k => g (e k)) = cov f g := by
  have h1 : avg (fun k => f (e k) * g (e k)) = avg (fun i => f i * g i) :=
    avg_reindex e (fun i => f i * g i)
  simp only [cov, h1, avg_reindex]

omit [Nonempty ι] [Nonempty κ] in
lemma varr_reindex (e : κ ≃ ι) (f : ι → ℝ) : varr (fun k => f (e k)) = varr f :=
  cov_reindex e f f

omit [Nonempty ι] [Nonempty κ] in
lemma msse_reindex (e : κ ≃ ι) (y h : ι → ℝ) :
    msse (fun k => y (e k)) (fun k => h (e k)) = msse y h := by
  have h1 : avg (fun k => (y (e k) - h (e k)) * (y (e k) - h (e k)))
      = avg (fun i => (y i - h i) * (y i - h i)) :=
    avg_reindex e (fun i => (y i - h i) * (y i - h i))
  simp only [msse, h1]

omit [Nonempty ι] [Nonempty κ] in
/-- **Window stability of the exact calculus.** Relabelling the sample space
(moving to another window with the same population) leaves `R²` unchanged, so a
degree-1 effect that is exactly `0` in one window is exactly `0` in every
window: the cross/same ratio of a genuine null is `1`. -/
theorem Rsq_reindex (e : κ ≃ ι) (y h : ι → ℝ) :
    Rsq (fun k => y (e k)) (fun k => h (e k)) = Rsq y h := by
  simp only [Rsq, msse_reindex, varr_reindex]

end Reindex

/-! ### Three-way alignment on a finite abelian group -/

section Triple

variable {G : Type*} [Fintype G] [DecidableEq G] [AddCommGroup G]

/-- The three-way alignment target: the indicator of the "zero-sum" hyperplane. -/
noncomputable def triAlign : G × G × G → ℝ :=
  fun x => if x.1 + x.2.1 + x.2.2 = 0 then 1 else 0

/-- A degree-`≤2` predictor: arbitrary functions of each *pair* of coordinates. -/
def pairwise (F : G × G → ℝ) (H₂ : G × G → ℝ) (H₃ : G × G → ℝ) : G × G × G → ℝ :=
  fun x => F (x.1, x.2.1) + H₂ (x.2.1, x.2.2) + H₃ (x.1, x.2.2)

omit [DecidableEq G] in
lemma cardG_pos : (0:ℝ) < (Fintype.card G : ℝ) := by
  have : 0 < Fintype.card G := Fintype.card_pos
  positivity

omit [DecidableEq G] [AddCommGroup G] in
/-- Normal form for sums over the triple product. -/
lemma sum_triple_eq (f : G × G × G → ℝ) :
    (∑ x : G × G × G, f x) = ∑ a : G, ∑ b : G, ∑ c : G, f (a, b, c) := by
  rw [Fintype.sum_prod_type]
  exact Finset.sum_congr rfl fun a _ => Fintype.sum_prod_type _

omit [DecidableEq G] [AddCommGroup G] in
/-- Normal form for sums over pairs. -/
lemma sum_pair_eq (F : G × G → ℝ) : (∑ p : G × G, F p) = ∑ a : G, ∑ b : G, F (a, b) :=
  Fintype.sum_prod_type _

lemma sum_triAlign_mul_fst_snd (F : G × G → ℝ) :
    (∑ x : G × G × G, triAlign x * F (x.1, x.2.1)) = ∑ a : G, ∑ b : G, F (a, b) := by
  rw [sum_triple_eq]
  refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => ?_
  rw [Finset.sum_eq_single (-(a + b))]
  · simp only [triAlign]
    split_ifs with hif
    · ring
    · exfalso
      apply hif
      show a + b + -(a + b) = 0
      abel
  · intro c _ hc
    have hne : ¬ (a + b + c = 0) := fun h => hc (by linear_combination (norm := abel) h)
    simp [triAlign, hne]
  · intro hmem
    exact absurd (Finset.mem_univ (-(a + b))) hmem

lemma sum_triAlign_mul_snd_thd (H₂ : G × G → ℝ) :
    (∑ x : G × G × G, triAlign x * H₂ (x.2.1, x.2.2)) = ∑ b : G, ∑ c : G, H₂ (b, c) := by
  rw [sum_triple_eq, Finset.sum_comm]
  refine Finset.sum_congr rfl fun b _ => ?_
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [Finset.sum_eq_single (-(b + c))]
  · simp only [triAlign]
    split_ifs with hif
    · ring
    · exfalso
      apply hif
      show -(b + c) + b + c = 0
      abel
  · intro a _ ha
    have hne : ¬ (a + b + c = 0) := fun h => ha (by linear_combination (norm := abel) h)
    simp [triAlign, hne]
  · intro hmem
    exact absurd (Finset.mem_univ (-(b + c))) hmem

lemma sum_triAlign_mul_fst_thd (H₃ : G × G → ℝ) :
    (∑ x : G × G × G, triAlign x * H₃ (x.1, x.2.2)) = ∑ a : G, ∑ c : G, H₃ (a, c) := by
  rw [sum_triple_eq]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [Finset.sum_eq_single (-(a + c))]
  · simp only [triAlign]
    split_ifs with hif
    · ring
    · exfalso
      apply hif
      show a + -(a + c) + c = 0
      abel
  · intro b _ hb
    have hne : ¬ (a + b + c = 0) := fun h => hb (by linear_combination (norm := abel) h)
    simp [triAlign, hne]
  · intro hmem
    exact absurd (Finset.mem_univ (-(a + c))) hmem

lemma sum_triAlign : (∑ x : G × G × G, (triAlign x : ℝ)) = (Fintype.card G : ℝ) ^ 2 := by
  have h := sum_triAlign_mul_fst_snd (G := G) (fun _ => 1)
  simp only [mul_one] at h
  rw [h]
  simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, sq]

lemma avg_triAlign : avg (triAlign (G := G)) = 1 / (Fintype.card G : ℝ) := by
  have hG := cardG_pos (G := G)
  simp only [avg, sum_triAlign, Fintype.card_prod, Nat.cast_mul]
  field_simp

/-! Lifting functions of two coordinates to the triple product. -/

omit [DecidableEq G] [AddCommGroup G] in
lemma sum_lift_fst_snd (F : G × G → ℝ) :
    (∑ x : G × G × G, F (x.1, x.2.1))
      = (Fintype.card G : ℝ) * ∑ a : G, ∑ b : G, F (a, b) := by
  rw [sum_triple_eq, Finset.mul_sum]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun b _ => ?_
  simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

omit [DecidableEq G] [AddCommGroup G] in
lemma sum_lift_snd_thd (H₂ : G × G → ℝ) :
    (∑ x : G × G × G, H₂ (x.2.1, x.2.2))
      = (Fintype.card G : ℝ) * ∑ b : G, ∑ c : G, H₂ (b, c) := by
  rw [sum_triple_eq]
  have hconst : ∀ a : G, (∑ b : G, ∑ c : G, H₂ ((a, b, c).2.1, (a, b, c).2.2))
      = ∑ b : G, ∑ c : G, H₂ (b, c) := fun _ => rfl
  rw [Finset.sum_congr rfl fun a _ => hconst a, Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul]

omit [DecidableEq G] [AddCommGroup G] in
lemma sum_lift_fst_thd (H₃ : G × G → ℝ) :
    (∑ x : G × G × G, H₃ (x.1, x.2.2))
      = (Fintype.card G : ℝ) * ∑ a : G, ∑ c : G, H₃ (a, c) := by
  rw [sum_triple_eq, Finset.mul_sum]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Finset.sum_comm, Finset.mul_sum]
  refine Finset.sum_congr rfl fun c _ => ?_
  simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

omit [DecidableEq G] in
lemma avg_pairwise (F H₂ H₃ : G × G → ℝ) :
    avg (pairwise F H₂ H₃)
      = ((∑ a : G, ∑ b : G, F (a, b)) + (∑ b : G, ∑ c : G, H₂ (b, c))
          + ∑ a : G, ∑ c : G, H₃ (a, c)) / ((Fintype.card G : ℝ) ^ 2) := by
  have hG := cardG_pos (G := G)
  have hs : (∑ x : G × G × G, pairwise F H₂ H₃ x)
      = (Fintype.card G : ℝ) *
        ((∑ a : G, ∑ b : G, F (a, b)) + (∑ b : G, ∑ c : G, H₂ (b, c))
          + ∑ a : G, ∑ c : G, H₃ (a, c)) := by
    simp only [pairwise]
    rw [Finset.sum_add_distrib, Finset.sum_add_distrib, sum_lift_fst_snd, sum_lift_snd_thd,
      sum_lift_fst_thd]
    ring
  simp only [avg, hs, Fintype.card_prod, Nat.cast_mul]
  field_simp

lemma avg_triAlign_mul_pairwise (F H₂ H₃ : G × G → ℝ) :
    avg (fun x : G × G × G => triAlign x * pairwise F H₂ H₃ x)
      = ((∑ a : G, ∑ b : G, F (a, b)) + (∑ b : G, ∑ c : G, H₂ (b, c))
          + ∑ a : G, ∑ c : G, H₃ (a, c)) / ((Fintype.card G : ℝ) ^ 3) := by
  have hG := cardG_pos (G := G)
  have hs : (∑ x : G × G × G, triAlign x * pairwise F H₂ H₃ x)
      = (∑ a : G, ∑ b : G, F (a, b)) + (∑ b : G, ∑ c : G, H₂ (b, c))
          + ∑ a : G, ∑ c : G, H₃ (a, c) := by
    have hsplit : (fun x : G × G × G => triAlign x * pairwise F H₂ H₃ x)
        = fun x : G × G × G => (triAlign x * F (x.1, x.2.1)
            + triAlign x * H₂ (x.2.1, x.2.2)) + triAlign x * H₃ (x.1, x.2.2) := by
      funext x; simp only [pairwise]; ring
    rw [hsplit, Finset.sum_add_distrib, Finset.sum_add_distrib, sum_triAlign_mul_fst_snd,
      sum_triAlign_mul_snd_thd, sum_triAlign_mul_fst_thd]
  simp only [avg, hs, Fintype.card_prod, Nat.cast_mul]
  field_simp

/-- **The whole degree-`≤2` layer is blind to three-way alignment.** For any
functions of pairs of coordinates, the covariance with the three-way alignment
target is exactly `0`. -/
theorem cov_triAlign_pairwise_eq_zero (F H₂ H₃ : G × G → ℝ) :
    cov (triAlign (G := G)) (pairwise F H₂ H₃) = 0 := by
  have hG := cardG_pos (G := G)
  simp only [cov, avg_triAlign_mul_pairwise, avg_triAlign, avg_pairwise]
  field_simp
  ring

/-- Hence no pairwise encoding beats the intercept-only baseline. -/
theorem triAlign_pairwise_no_gain (F H₂ H₃ : G × G → ℝ) :
    varr (triAlign (G := G)) ≤ msse (triAlign (G := G)) (pairwise F H₂ H₃) :=
  msse_ge_varr_of_cov_eq_zero (cov_triAlign_pairwise_eq_zero F H₂ H₃)

omit [Fintype G] in
lemma triAlign_mul_self :
    (fun x : G × G × G => triAlign x * triAlign x) = triAlign (G := G) := by
  funext x
  by_cases h : x.1 + x.2.1 + x.2.2 = 0 <;> simp [triAlign, h]

/-- The variance of the three-way alignment target is `1/N - 1/N²`. -/
theorem varr_triAlign :
    varr (triAlign (G := G)) = 1 / (Fintype.card G : ℝ) - 1 / ((Fintype.card G : ℝ) ^ 2) := by
  have hG := cardG_pos (G := G)
  simp only [varr, cov, triAlign_mul_self, avg_triAlign]
  field_simp

theorem varr_triAlign_pos (hcard : 2 ≤ Fintype.card G) : 0 < varr (triAlign (G := G)) := by
  have hG : (2:ℝ) ≤ (Fintype.card G : ℝ) := by exact_mod_cast hcard
  have hG0 : (0:ℝ) < (Fintype.card G : ℝ) := by linarith
  rw [varr_triAlign, sub_pos, div_lt_div_iff₀ (by positivity) hG0]
  nlinarith

/-- In `R²` units: every degree-`≤2` encoding has nonpositive `R²`. -/
theorem Rsq_pairwise_nonpos (hcard : 2 ≤ Fintype.card G) (F H₂ H₃ : G × G → ℝ) :
    Rsq (triAlign (G := G)) (pairwise F H₂ H₃) ≤ 0 :=
  Rsq_nonpos_of_cov_eq_zero (cov_triAlign_pairwise_eq_zero F H₂ H₃) (varr_triAlign_pos hcard)

/-- The degree-3 encoding (the target itself, a joint indicator of all three
coordinates) is perfect. -/
theorem Rsq_triAlign_self_eq_one : Rsq (triAlign (G := G)) (triAlign (G := G)) = 1 :=
  Rsq_self _

/-- **Degree-3 separation.** For `|G| ≥ 2`: every pairwise (degree-`≤2`)
encoding has `R² ≤ 0`, while the degree-3 encoding has `R² = 1`. -/
theorem triple_degree_separation (hcard : 2 ≤ Fintype.card G) :
    (∀ F H₂ H₃ : G × G → ℝ, Rsq (triAlign (G := G)) (pairwise F H₂ H₃) ≤ 0) ∧
      Rsq (triAlign (G := G)) (triAlign (G := G)) = 1 :=
  ⟨fun F H₂ H₃ => Rsq_pairwise_nonpos hcard F H₂ H₃, Rsq_triAlign_self_eq_one⟩

/-- Concretely at the top of the high-prime window `p = 97`. -/
theorem triple_degree_separation_97 :
    (∀ F H₂ H₃ : ZMod 97 × ZMod 97 → ℝ,
        Rsq (triAlign (G := ZMod 97)) (pairwise F H₂ H₃) ≤ 0) ∧
      Rsq (triAlign (G := ZMod 97)) (triAlign (G := ZMod 97)) = 1 := by
  have hcard : 2 ≤ Fintype.card (ZMod 97) := by rw [ZMod.card]; norm_num
  exact triple_degree_separation hcard

end Triple

end Logic.PhaseRoute