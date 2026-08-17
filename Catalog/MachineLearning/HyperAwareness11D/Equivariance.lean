import MachineLearning.HyperAwareness11D.Injectivity

/-!
# Hyper-Awareness III: symmetry rigidity of 11-dimensional perception layers

A recurring design proposal for "hyper-aware" architectures is to make the 11 spatial axes
*interchangeable*, i.e. to impose the symmetries of the 11-dimensional hypercube on every
linear layer.  This file proves that such a demand is self-defeating, by computing exactly
which linear layers `x ↦ M x` on `ℝ¹¹` are equivariant for the two natural symmetry groups:

* the symmetric group `S₁₁` (permuting the 11 axes), and
* the hyperoctahedral group `B₁₁ = (ℤ/2)¹¹ ⋊ S₁₁` (permuting *and* reflecting the axes).

## Main results

* `HyperAwareness11D.permEquivariant_iff_entries` — permutation equivariance is exactly the
  statement that `M` has constant diagonal and constant off-diagonal entries.
* `HyperAwareness11D.permEquivariant_deepSets` — hence such a layer has the "Deep Sets" form
  `x ↦ a • x + b • (∑ x)`: **exactly two learnable parameters**, versus `121` for a general
  `11 × 11` layer.
* `HyperAwareness11D.exists_unique_deepSets_params` — the two parameters are unique.
* `HyperAwareness11D.signEquivariant_offDiag_zero` — sign equivariance forces `M` diagonal.
* `HyperAwareness11D.hyperoctahedral_rigidity` — the two symmetries together force
  `M = a • 1`: **exactly one learnable parameter**, a global gain.
* `HyperAwareness11D.no_hyperoctahedral_channel_swap` — consequently no `B₁₁`-equivariant
  layer can mix two perception channels: hypercube symmetry annihilates all
  11-dimensional cross-channel processing.

The moral for the mission: *lossless* 11-dimensional processing (the `22`-unit optimum of
`Injectivity.lean`) and *fully symmetric* 11-dimensional processing are incompatible design
goals; genuine 11-dimensional perception must break the hyperoctahedral symmetry.
-/

namespace HyperAwareness11D

open Finset

noncomputable section

variable {n : ℕ}

/-- A linear perception layer `x ↦ M x` on `ℝⁿ`. -/
def linLayer (M : Fin n → Fin n → ℝ) (x : Fin n → ℝ) : Fin n → ℝ := fun i => ∑ j, M i j * x j

/-- Equivariance under permutations of the `n` perception axes. -/
def PermEquivariant (M : Fin n → Fin n → ℝ) : Prop :=
  ∀ (σ : Equiv.Perm (Fin n)) (x : Fin n → ℝ), linLayer M (x ∘ σ) = (linLayer M x) ∘ σ

/-- Equivariance under sign flips (reflections) of the `n` perception axes. -/
def SignEquivariant (M : Fin n → Fin n → ℝ) : Prop :=
  ∀ (ε : Fin n → ℝ), (∀ i, ε i = 1 ∨ ε i = -1) → ∀ x : Fin n → ℝ,
    linLayer M (fun j => ε j * x j) = fun i => ε i * linLayer M x i

/-! ## A two-point transitivity lemma for permutations -/

/-- The symmetric group is `2`-transitive: any ordered pair of distinct points can be moved
to any other ordered pair of distinct points. -/
lemma exists_perm_pair {i j k l : Fin n} (hij : i ≠ j) (hkl : k ≠ l) :
    ∃ σ : Equiv.Perm (Fin n), σ i = k ∧ σ j = l := by
  classical
  set τ : Equiv.Perm (Fin n) := Equiv.swap i k with hτ
  have hτi : τ i = k := by simp [hτ]
  have hne : τ j ≠ k := by
    intro hjk
    have hji : τ j = τ i := by rw [hjk, hτi]
    exact hij (τ.injective hji).symm
  refine ⟨τ.trans (Equiv.swap (τ j) l), ?_, ?_⟩
  · simp only [Equiv.trans_apply, hτi]
    rw [Equiv.swap_apply_of_ne_of_ne (Ne.symm hne) hkl]
  · simp only [Equiv.trans_apply]
    rw [Equiv.swap_apply_left]

/-! ## Permutation equivariance -/

/-- Permutation equivariance of a linear layer is exactly invariance of the weight matrix
under simultaneous permutation of rows and columns. -/
theorem permEquivariant_iff_invariant (M : Fin n → Fin n → ℝ) :
    PermEquivariant M ↔ ∀ (σ : Equiv.Perm (Fin n)) (i j : Fin n), M (σ i) (σ j) = M i j := by
  classical
  constructor
  · intro h σ i j
    have hx := congrFun (h σ (fun t => if t = σ j then (1:ℝ) else 0)) i
    simp only [linLayer, Function.comp_apply] at hx
    have hL : (∑ t, M i t * (if σ t = σ j then (1:ℝ) else 0)) = M i j := by
      rw [Finset.sum_eq_single j]
      · simp
      · intro t _ ht
        have : σ t ≠ σ j := fun hc => ht (σ.injective hc)
        simp [this]
      · intro hj; exact absurd (Finset.mem_univ j) hj
    have hR : (∑ t, M (σ i) t * (if t = σ j then (1:ℝ) else 0)) = M (σ i) (σ j) := by
      rw [Finset.sum_eq_single (σ j)]
      · simp
      · intro t _ ht; simp [ht]
      · intro hj; exact absurd (Finset.mem_univ (σ j)) hj
    rw [hL, hR] at hx
    exact hx.symm
  · intro h σ x
    funext i
    simp only [linLayer, Function.comp_apply]
    have : ∑ j, M (σ i) j * x j = ∑ j, M (σ i) (σ j) * x (σ j) :=
      (Equiv.sum_comp σ (fun j => M (σ i) j * x j)).symm
    rw [this]
    exact Finset.sum_congr rfl fun j _ => by rw [h σ i j]

/-- A permutation-equivariant layer has constant diagonal and constant off-diagonal
entries. -/
theorem permEquivariant_iff_entries (hn : 2 ≤ n) (M : Fin n → Fin n → ℝ) :
    PermEquivariant M ↔ ∃ a b : ℝ, ∀ i j, M i j = if i = j then a else b := by
  classical
  have h0 : (0 : ℕ) < n := by omega
  have h1 : (1 : ℕ) < n := by omega
  set i0 : Fin n := ⟨0, h0⟩
  set i1 : Fin n := ⟨1, h1⟩
  have hi01 : i0 ≠ i1 := by
    intro h
    have := congrArg Fin.val h
    simp [i0, i1] at this
  constructor
  · intro h
    rw [permEquivariant_iff_invariant] at h
    refine ⟨M i0 i0, M i0 i1, ?_⟩
    intro i j
    by_cases hij : i = j
    · subst hij
      simp only [if_true]
      have hswap := h (Equiv.swap i0 i) i0 i0
      simp only [Equiv.swap_apply_left] at hswap
      exact hswap
    · simp only [if_neg hij]
      obtain ⟨σ, hσ1, hσ2⟩ := exists_perm_pair hi01 hij
      have hval := h σ i0 i1
      rw [hσ1, hσ2] at hval
      exact hval
  · rintro ⟨a, b, hM⟩
    rw [permEquivariant_iff_invariant]
    intro σ i j
    by_cases hij : i = j
    · subst hij; simp [hM]
    · have : σ i ≠ σ j := fun hc => hij (σ.injective hc)
      simp [hM, hij, this]

/-- **Deep Sets form.**  A permutation-equivariant linear perception layer acts as
`x ↦ a • x + b • (∑ x)`: two learnable parameters, whatever the dimension. -/
theorem permEquivariant_deepSets (hn : 2 ≤ n) (M : Fin n → Fin n → ℝ)
    (h : PermEquivariant M) :
    ∃ a b : ℝ, ∀ (x : Fin n → ℝ) (i : Fin n), linLayer M x i = a * x i + b * ∑ j, x j := by
  classical
  obtain ⟨a, b, hM⟩ := (permEquivariant_iff_entries hn M).mp h
  refine ⟨a - b, b, ?_⟩
  intro x i
  simp only [linLayer, hM]
  have hsplit : ∀ j, (if i = j then a else b) * x j
      = b * x j + (if i = j then (a - b) * x j else 0) := by
    intro j
    by_cases hij : i = j
    · simp [hij]; ring
    · simp [hij]
  rw [Finset.sum_congr rfl (fun j _ => hsplit j), Finset.sum_add_distrib, ← Finset.mul_sum,
    Finset.sum_ite_eq]
  simp
  ring

/-- The two Deep Sets parameters are uniquely determined by the layer. -/
theorem exists_unique_deepSets_params (hn : 2 ≤ n) (M : Fin n → Fin n → ℝ)
    (h : PermEquivariant M) :
    ∃! p : ℝ × ℝ, ∀ i j, M i j = if i = j then p.1 else p.2 := by
  classical
  obtain ⟨a, b, hM⟩ := (permEquivariant_iff_entries hn M).mp h
  have h0 : (0 : ℕ) < n := by omega
  have h1 : (1 : ℕ) < n := by omega
  set i0 : Fin n := ⟨0, h0⟩
  set i1 : Fin n := ⟨1, h1⟩
  have hi01 : i0 ≠ i1 := by
    intro hc
    have := congrArg Fin.val hc
    simp [i0, i1] at this
  refine ⟨(a, b), hM, ?_⟩
  rintro ⟨a', b'⟩ hM'
  have ha : a' = a := by
    have h1' := hM' i0 i0
    have h2' := hM i0 i0
    rw [h2'] at h1'
    simpa using h1'.symm
  have hb : b' = b := by
    have h1' := hM' i0 i1
    have h2' := hM i0 i1
    simp only [if_neg hi01] at h1' h2'
    rw [h2'] at h1'
    exact h1'.symm
  simp [ha, hb]

/-! ## Sign equivariance and hyperoctahedral rigidity -/

/-- Sign equivariance forces every off-diagonal weight to vanish: a reflection-equivariant
layer cannot transport information between two different perception axes. -/
theorem signEquivariant_offDiag_zero (M : Fin n → Fin n → ℝ) (h : SignEquivariant M)
    {i j : Fin n} (hij : i ≠ j) : M i j = 0 := by
  classical
  set ε : Fin n → ℝ := fun k => if k = j then -1 else 1 with hε
  have hεspec : ∀ k, ε k = 1 ∨ ε k = -1 := by
    intro k; by_cases hk : k = j <;> simp [hε, hk]
  set x : Fin n → ℝ := fun k => if k = j then (1:ℝ) else 0 with hx
  have hcall := congrFun (h ε hεspec x) i
  simp only [linLayer] at hcall
  have hL : (∑ k, M i k * (ε k * x k)) = -M i j := by
    rw [Finset.sum_eq_single j]
    · simp [hε, hx]
    · intro k _ hk; simp [hx, hk]
    · intro hj; exact absurd (Finset.mem_univ j) hj
  have hR : (∑ k, M i k * x k) = M i j := by
    rw [Finset.sum_eq_single j]
    · simp [hx]
    · intro k _ hk; simp [hx, hk]
    · intro hj; exact absurd (Finset.mem_univ j) hj
  rw [hL, hR] at hcall
  have hεi : ε i = 1 := by simp [hε, hij]
  rw [hεi] at hcall
  linarith [hcall]

/-- **Hyperoctahedral rigidity.**  A linear layer equivariant for both the permutations and
the reflections of the `n` perception axes is a scalar multiple of the identity: it has a
single learnable parameter and performs no cross-channel processing at all. -/
theorem hyperoctahedral_rigidity (hn : 2 ≤ n) (M : Fin n → Fin n → ℝ) :
    (PermEquivariant M ∧ SignEquivariant M) ↔ ∃ a : ℝ, ∀ i j, M i j = if i = j then a else 0 := by
  classical
  have h0 : (0 : ℕ) < n := by omega
  have h1 : (1 : ℕ) < n := by omega
  set i0 : Fin n := ⟨0, h0⟩
  set i1 : Fin n := ⟨1, h1⟩
  have hi01 : i0 ≠ i1 := by
    intro hc
    have := congrArg Fin.val hc
    simp [i0, i1] at this
  constructor
  · rintro ⟨hp, hs⟩
    obtain ⟨a, b, hM⟩ := (permEquivariant_iff_entries hn M).mp hp
    have hb : b = 0 := by
      have h01 := hM i0 i1
      rw [if_neg hi01] at h01
      rw [← h01]
      exact signEquivariant_offDiag_zero M hs hi01
    exact ⟨a, by intro i j; rw [hM i j, hb]⟩
  · rintro ⟨a, hM⟩
    constructor
    · rw [permEquivariant_iff_invariant]
      intro σ i j
      by_cases hij : i = j
      · subst hij; simp [hM]
      · have : σ i ≠ σ j := fun hc => hij (σ.injective hc)
        simp [hM, hij, this]
    · intro ε hε x
      funext i
      simp only [linLayer, hM]
      rw [Finset.sum_eq_single i, Finset.sum_eq_single i]
      · simp only [if_true]; ring
      · intro k _ hk; simp [Ne.symm hk]
      · intro hi; exact absurd (Finset.mem_univ i) hi
      · intro k _ hk; simp [Ne.symm hk]
      · intro hi; exact absurd (Finset.mem_univ i) hi

/-- In dimension 11: a fully hyperoctahedral-equivariant perception layer is a global gain
control `x ↦ a • x`. -/
theorem hyperoctahedral_scalar_11 (M : Fin 11 → Fin 11 → ℝ)
    (hp : PermEquivariant M) (hs : SignEquivariant M) :
    ∃ a : ℝ, ∀ x : Fin 11 → ℝ, linLayer M x = a • x := by
  obtain ⟨a, hM⟩ := (hyperoctahedral_rigidity (by norm_num) M).mp ⟨hp, hs⟩
  refine ⟨a, ?_⟩
  intro x
  funext i
  simp only [linLayer, hM, Pi.smul_apply, smul_eq_mul]
  rw [Finset.sum_eq_single i]
  · simp
  · intro k _ hk; simp [Ne.symm hk]
  · intro hi; exact absurd (Finset.mem_univ i) hi

/-- **No symmetric channel mixing.**  No hyperoctahedral-equivariant layer on `ℝ¹¹` can
exchange two perception channels; imposing the full hypercube symmetry destroys every
genuinely 11-dimensional (cross-channel) computation. -/
theorem no_hyperoctahedral_channel_swap (M : Fin 11 → Fin 11 → ℝ)
    (hp : PermEquivariant M) (hs : SignEquivariant M) :
    ¬ (∀ x : Fin 11 → ℝ, linLayer M x = x ∘ (Equiv.swap 0 1)) := by
  intro hswap
  obtain ⟨a, ha⟩ := hyperoctahedral_scalar_11 M hp hs
  -- test the layer on the second basis vector: a scalar layer maps it to `a • e₁`, whose
  -- `0`-th coordinate is `0`, while the channel swap must return `1` there.
  set y : Fin 11 → ℝ := fun k => if k = 1 then (1:ℝ) else 0 with hy
  have h3 := congrFun (ha y) 0
  have h4 := congrFun (hswap y) 0
  rw [h3] at h4
  simp [hy, Equiv.swap_apply_left] at h4

end

end HyperAwareness11D