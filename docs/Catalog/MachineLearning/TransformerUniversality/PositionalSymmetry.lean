import Mathlib

/-!
# Permutation symmetry and how additive positional encodings destroy it

`Catalog/MachineLearning/SoftmaxAttentionEquivariance.lean` proves that softmax attention is
permutation equivariant, and `Catalog/MachineLearning/TransformerArchitecture.lean` introduces
additive positional encodings but proves nothing about the interaction of the two.  This file
determines that interaction **exactly**.

Working with the bilinear (pre-softmax) attention score of the catalog architecture, we show:

* `linAttention_equivariant` — with no positional encoding, the whole attention read is
  equivariant under every simultaneous token permutation;
* `posScore_equivariant_iff` — with an additive positional encoding `p`, a permutation `σ`
  preserves all scores for all inputs **iff** `p ∘ σ = p`;
* `posStab` — consequently the residual symmetry group is exactly the stabilizer subgroup of
  the positional encoding, and `mem_posStab_iff` identifies it with the equivariant
  permutations;
* `posStab_eq_bot_of_injective` — pairwise distinct positional encodings destroy *all*
  permutation symmetry;
* `exists_symmetry_breaking` and `two_token_symmetry_breaking` — an explicit two-token
  counterexample.
-/

open scoped BigOperators

namespace PositionalSymmetry

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ]

/-- Feature-space inner product used by the bilinear attention score. -/
def dot (u v : κ → ℝ) : ℝ := ∑ a, u a * v a

theorem dot_add_right (u v w : κ → ℝ) :
    dot u (fun a => v a + w a) = dot u v + dot u w := by
  simp only [dot, mul_add, Finset.sum_add_distrib]

theorem dot_self_eq_zero {u : κ → ℝ} (h : dot u u = 0) : ∀ a, u a = 0 := by
  intro a
  have hnn : ∀ b ∈ (Finset.univ : Finset κ), 0 ≤ u b * u b := fun b _ => mul_self_nonneg _
  have := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp h a (Finset.mem_univ a)
  exact by nlinarith [this]

/-- Reindex a token-indexed tensor by a permutation. -/
def permute (σ : Equiv.Perm ι) (x : ι → κ → ℝ) : ι → κ → ℝ := fun i => x (σ.symm i)

/-- Bilinear attention score with an additive positional encoding `p`. -/
def posScore (p x : ι → κ → ℝ) (i j : ι) : ℝ :=
  dot (fun a => x i a + p i a) (fun a => x j a + p j a)

/-- Bilinear attention read (linear attention, no softmax). -/
def linAttention (x : ι → κ → ℝ) (v : ι → ℝ) (i : ι) : ℝ :=
  ∑ j, dot (x i) (x j) * v j

omit [DecidableEq ι] in
/-- **No positional encoding: full permutation equivariance.** -/
theorem linAttention_equivariant (σ : Equiv.Perm ι) (x : ι → κ → ℝ) (v : ι → ℝ) (i : ι) :
    linAttention (permute σ x) (fun j => v (σ.symm j)) (σ i) = linAttention x v i := by
  simp only [linAttention, permute, Equiv.symm_apply_apply]
  rw [← Equiv.sum_comp σ (fun j => dot (x i) (x (σ.symm j)) * v (σ.symm j))]
  simp [Equiv.symm_apply_apply]

/-- **Positional encodings break permutation symmetry exactly on the non-stabilizing
permutations.**  For at least two tokens, `σ` preserves every positionally-encoded score for
every input if and only if `σ` fixes the positional encoding pointwise. -/
theorem posScore_equivariant_iff (hcard : 2 ≤ Fintype.card ι)
    (σ : Equiv.Perm ι) (p : ι → κ → ℝ) :
    (∀ x : ι → κ → ℝ, ∀ i j, posScore p (permute σ x) (σ i) (σ j) = posScore p x i j)
      ↔ ∀ i, p (σ i) = p i := by
  constructor
  · intro hall i
    obtain ⟨j, hj⟩ : ∃ j : ι, j ≠ i := by
      obtain ⟨a, b, hab⟩ := Fintype.exists_pair_of_one_lt_card hcard
      by_cases h : a = i
      · exact ⟨b, fun hb => hab (by rw [h, hb])⟩
      · exact ⟨a, h⟩
    -- Step 1: the purely positional term is preserved.
    have hzero := hall (fun _ _ => 0) i j
    simp only [posScore, permute, zero_add] at hzero
    -- Step 2: probe with an input supported at `j`.
    have hprobe : ∀ y : κ → ℝ, dot (p (σ i)) y = dot (p i) y := by
      intro y
      set x : ι → κ → ℝ := fun m => if m = j then y else fun _ => 0 with hxdef
      have hxi : x i = fun _ => (0:ℝ) := by
        simp only [hxdef, if_neg (Ne.symm hj)]
      have hxj : x j = y := by simp only [hxdef, if_pos rfl]
      have h := hall x i j
      simp only [posScore, permute, Equiv.symm_apply_apply, hxi, hxj, zero_add] at h
      rw [dot_add_right, dot_add_right] at h
      linarith [h, hzero]
    -- Step 3: a self-probe forces the two positional vectors to agree.
    funext a
    have hdiff : dot (fun b => p (σ i) b - p i b) (fun b => p (σ i) b - p i b) = 0 := by
      have h1 := hprobe (fun b => p (σ i) b - p i b)
      simp only [dot, sub_mul, Finset.sum_sub_distrib] at h1 ⊢
      have h2 : ∑ b, p (σ i) b * (p (σ i) b - p i b)
          = ∑ b, p i b * (p (σ i) b - p i b) := by
        simpa [dot, mul_sub, Finset.sum_sub_distrib] using h1
      simp only [mul_sub, Finset.sum_sub_distrib] at h2
      linarith [h2]
    have := dot_self_eq_zero hdiff a
    linarith [this]
  · intro hp x i j
    simp only [posScore, permute, Equiv.symm_apply_apply, hp]

/-- The stabilizer subgroup of a positional encoding: the residual symmetry group of a
transformer layer with additive positional encodings. -/
def posStab (p : ι → κ → ℝ) : Subgroup (Equiv.Perm ι) where
  carrier := {σ | ∀ i, p (σ i) = p i}
  one_mem' := by intro i; rfl
  mul_mem' := by
    intro a b ha hb i
    simp only [Equiv.Perm.mul_apply]
    rw [ha (b i), hb i]
  inv_mem' := by
    intro a ha i
    have h := ha (a.symm i)
    rw [Equiv.apply_symm_apply] at h
    simp only [Equiv.Perm.inv_def]
    rw [← h]

/-- Membership in the residual symmetry group is exactly score equivariance. -/
theorem mem_posStab_iff (hcard : 2 ≤ Fintype.card ι) (σ : Equiv.Perm ι) (p : ι → κ → ℝ) :
    σ ∈ posStab p ↔
      ∀ x : ι → κ → ℝ, ∀ i j, posScore p (permute σ x) (σ i) (σ j) = posScore p x i j :=
  (posScore_equivariant_iff hcard σ p).symm

omit [Fintype ι] [DecidableEq ι] [Fintype κ] in
/-- **Distinct positional encodings destroy all permutation symmetry.** -/
theorem posStab_eq_bot_of_injective (p : ι → κ → ℝ) (hp : Function.Injective p) :
    posStab p = ⊥ := by
  ext σ
  simp only [Subgroup.mem_bot]
  constructor
  · intro hσ
    ext i
    exact congrArg (·) (hp (hσ i))
  · rintro rfl
    intro i
    rfl

omit [Fintype ι] [DecidableEq ι] [Fintype κ] in
/-- **A transitive symmetry destroys all positional information.**  If a permutation whose
powers act transitively on positions is a symmetry of the encoding, then the encoding is
constant and *every* permutation is a symmetry. -/
theorem posStab_eq_top_of_transitive (p : ι → κ → ℝ) (σ : Equiv.Perm ι)
    (hσ : σ ∈ posStab p) (htrans : ∀ i j, ∃ n : ℕ, (σ ^ n) i = j) :
    posStab p = ⊤ := by
  have hpow : ∀ (n : ℕ) (i : ι), p ((σ ^ n) i) = p i := by
    intro n
    induction n with
    | zero => intro i; simp
    | succ n ih =>
      intro i
      have hstep : (σ ^ (n + 1)) i = σ ((σ ^ n) i) := by
        rw [pow_succ']
        rfl
      rw [hstep, hσ ((σ ^ n) i), ih i]
  have hconst : ∀ i j, p i = p j := by
    intro i j
    obtain ⟨n, hn⟩ := htrans i j
    rw [← hn, hpow n i]
  ext τ
  simp only [Subgroup.mem_top, iff_true]
  intro i
  exact (hconst (τ i) i)

omit [Fintype κ] in
/-- Concretely, on three positions a three-cycle symmetry forces total permutation
invariance. -/
theorem three_cycle_symmetry_forces_top (p : Fin 3 → κ → ℝ)
    (h : (Equiv.swap (0 : Fin 3) 1 * Equiv.swap 1 2) ∈ posStab p) :
    posStab p = ⊤ := by
  refine posStab_eq_top_of_transitive p _ h ?_
  intro i j
  refine ⟨(j - i : Fin 3).val, ?_⟩
  fin_cases i <;> fin_cases j <;> decide

omit [Fintype κ] in
/-- **Not every subgroup is a residual symmetry group.**  On three positions no additive
positional encoding has residual symmetry group exactly the cyclic group generated by a
three-cycle: the residual symmetry group is always the pointwise stabilizer of the encoding,
which is a Young subgroup of the level-set partition. -/
theorem no_cyclic_residual_symmetry :
    ¬ ∃ p : Fin 3 → κ → ℝ,
      posStab p = Subgroup.zpowers (Equiv.swap (0 : Fin 3) 1 * Equiv.swap 1 2) := by
  rintro ⟨p, hp⟩
  have hc : (Equiv.swap (0 : Fin 3) 1 * Equiv.swap 1 2) ∈ posStab p := by
    rw [hp]; exact Subgroup.mem_zpowers _
  have htop := three_cycle_symmetry_forces_top p hc
  have hmem : Equiv.swap (0 : Fin 3) 1 ∈
      Subgroup.zpowers (Equiv.swap (0 : Fin 3) 1 * Equiv.swap 1 2) := by
    rw [← hp, htop]; trivial
  obtain ⟨k, hk⟩ := hmem
  have hsign := congrArg Equiv.Perm.sign hk
  rw [map_zpow] at hsign
  have hc1 : Equiv.Perm.sign (Equiv.swap (0 : Fin 3) 1 * Equiv.swap 1 2) = 1 := by decide
  have hc2 : Equiv.Perm.sign (Equiv.swap (0 : Fin 3) 1) = -1 := by decide
  rw [hc1, hc2, one_zpow] at hsign
  exact absurd hsign (by decide)

/-- **Symmetry breaking.**  If a permutation moves the positional encoding, some input and
some pair of positions have their score changed. -/
theorem exists_symmetry_breaking (hcard : 2 ≤ Fintype.card ι)
    (σ : Equiv.Perm ι) (p : ι → κ → ℝ) (hσ : ∃ i, p (σ i) ≠ p i) :
    ∃ (x : ι → κ → ℝ) (i j : ι),
      posScore p (permute σ x) (σ i) (σ j) ≠ posScore p x i j := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨i, hi⟩ := hσ
  exact hi ((posScore_equivariant_iff hcard σ p).mp (fun x i j => hcon x i j) i)

/-- **Explicit two-token counterexample.**  With two tokens, one feature, and the positional
encoding `p 0 = 0`, `p 1 = 1`, the transposition is not a symmetry. -/
theorem two_token_symmetry_breaking :
    ∃ (x : Fin 2 → Fin 1 → ℝ) (i j : Fin 2),
      posScore (fun m _ => if m = 0 then (0:ℝ) else 1) (permute (Equiv.swap 0 1) x)
          (Equiv.swap 0 1 i) (Equiv.swap 0 1 j)
        ≠ posScore (fun m _ => if m = 0 then (0:ℝ) else 1) x i j := by
  refine ⟨fun _ _ => 0, 0, 0, ?_⟩
  simp [posScore, permute, dot]

end PositionalSymmetry