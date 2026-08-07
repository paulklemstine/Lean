/-
# Cyclicity of tropical powers for integer matrices

This file settles conjecture **C1** of `FUTURE_DIRECTIONS.md` — *tropical powers are
eventually exactly periodic* — for matrices with integer entries (equivalently, after
rescaling, for matrices with rational entries):

  `exists_cyclicity`: for `A` with integer entries there are a period `p ≥ 1` and a
  transient `N` such that for all `m ≥ N`

      `A^{⊗(m+p+1)} = (p·λ) ⊗ A^{⊗(m+1)}`,  i.e.  `tpow A (m+p) = fun i j => p*λ + tpow A m i j`,

  where `λ = maxCycleMean A`.

The proof is exactly the strategy outlined in the conjecture, now made precise:

1. entries of tropical powers of an integer matrix are integers (`tpow_isInt`);
2. `q·λ` is an integer, where `q ≤ n` is the length of a critical cycle
   (`exists_critical_cycle_int`);
3. by `exists_uniform_entry_bound` the normalised powers `A^{⊗(m+1)} − (m+1)λ` live in a
   fixed compact box, so along the arithmetic progression `m = N + t·q` the *integer*
   matrices `A^{⊗(m+1)} − t·(qλ)` take only finitely many values;
4. pigeonhole gives two equal terms, i.e. one exact relation
   `tpow A (M₀ + p) = p·λ + tpow A M₀`;
5. the relation propagates to all later exponents because tropical multiplication commutes
   with adding a constant (`tmul_const_add`).

Boundedness alone does not give periodicity over ℝ; integrality is what makes the box
finite, and that is exactly the hypothesis used here.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalCyclicity

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Adding a constant to every entry of the left factor shifts the tropical product. -/
theorem tmul_const_add (X A : Matrix ι ι ℝ) (c : ℝ) :
    tmul (fun i j => c + X i j) A = fun i j => c + tmul X A i j := by
  funext i j
  apply le_antisymm
  · refine tmul_le fun k => ?_
    have := le_tmul X A i j k
    show c + X i k + A k j ≤ c + tmul X A i j
    linarith
  · obtain ⟨k, hk⟩ := exists_tmul_eq X A i j
    have hle : (fun i j => c + X i j) i k + A k j ≤ tmul (fun i j => c + X i j) A i j :=
      le_tmul (fun i j => c + X i j) A i j k
    simp only at hle
    rw [hk]
    linarith

/-- Tropical powers of an integer matrix have integer entries. -/
theorem tpow_isInt {A : Matrix ι ι ℝ} (hA : ∀ i j, ∃ z : ℤ, A i j = (z : ℝ)) (m : ℕ) (i j : ι) :
    ∃ z : ℤ, tpow A m i j = (z : ℝ) := by
  induction m generalizing i j with
  | zero => simpa [tpow] using hA i j
  | succ m ih =>
      obtain ⟨k, hk⟩ := exists_tmul_eq (tpow A m) A i j
      obtain ⟨z₁, hz₁⟩ := ih i k
      obtain ⟨z₂, hz₂⟩ := hA k j
      refine ⟨z₁ + z₂, ?_⟩
      show tmul (tpow A m) A i j = _
      rw [hk, hz₁, hz₂]
      push_cast
      ring

omit [Fintype ι] [Nonempty ι] in
/-- Path weights of an integer matrix are integers. -/
theorem pathWeight_isInt {A : Matrix ι ι ℝ} (hA : ∀ i j, ∃ z : ℤ, A i j = (z : ℝ))
    (c : ℕ → ι) (m : ℕ) : ∃ z : ℤ, pathWeight A c m = (z : ℝ) := by
  induction m with
  | zero => exact ⟨0, by simp [pathWeight]⟩
  | succ m ih =>
      obtain ⟨z₁, hz₁⟩ := ih
      obtain ⟨z₂, hz₂⟩ := hA (c m) (c (m + 1))
      refine ⟨z₁ + z₂, ?_⟩
      rw [pathWeight, Finset.sum_range_succ, ← pathWeight, hz₁, hz₂]
      push_cast
      ring

/-- For an integer matrix, some multiple `q · λ` of the maximum cycle mean is an integer,
with `1 ≤ q ≤ n`. -/
theorem exists_critical_cycle_int {A : Matrix ι ι ℝ} (hA : ∀ i j, ∃ z : ℤ, A i j = (z : ℝ)) :
    ∃ (q : ℕ) (w : ℤ), 0 < q ∧ (q : ℝ) * maxCycleMean A = (w : ℝ) := by
  obtain ⟨q, c, hq0, _, _, hcw⟩ := exists_critical_cycle_maxCycleMean (A := A)
  obtain ⟨w, hw⟩ := pathWeight_isInt hA c q
  exact ⟨q, w, hq0, by rw [← hcw, hw]⟩

/-- **Rationality of the max-plus spectral radius of an integer matrix**: the maximum cycle
mean is `w / q` for an integer `w` and a cycle length `1 ≤ q ≤ n`. -/
theorem maxCycleMean_rat {A : Matrix ι ι ℝ} (hA : ∀ i j, ∃ z : ℤ, A i j = (z : ℝ)) :
    ∃ (w : ℤ) (q : ℕ), 0 < q ∧ q ≤ Fintype.card ι ∧ maxCycleMean A = (w : ℝ) / (q : ℝ) := by
  obtain ⟨q, c, hq0, hqn, _, hcw⟩ := exists_critical_cycle_maxCycleMean (A := A)
  obtain ⟨w, hw⟩ := pathWeight_isInt hA c q
  refine ⟨w, q, hq0, hqn, ?_⟩
  have hq : ((q : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  rw [hw] at hcw
  field_simp
  linarith [hcw]

/-- **Propagation of one exact relation.**  If a single tropical power satisfies
`tpow A (M₀ + p) = c + tpow A M₀` entrywise, the same relation holds for all larger
exponents. -/
theorem tpow_periodic_of_step {A : Matrix ι ι ℝ} {M₀ p : ℕ} {c : ℝ}
    (h : tpow A (M₀ + p) = fun i j => c + tpow A M₀ i j) :
    ∀ m, M₀ ≤ m → tpow A (m + p) = fun i j => c + tpow A m i j := by
  intro m hm
  obtain ⟨d, rfl⟩ : ∃ d, m = M₀ + d := ⟨m - M₀, by omega⟩
  induction d with
  | zero => simpa using h
  | succ d ih =>
      have hstep : tpow A (M₀ + d + p) = fun i j => c + tpow A (M₀ + d) i j := ih (by omega)
      have hidx : M₀ + (d + 1) + p = (M₀ + d + p) + 1 := by omega
      rw [hidx]
      show tmul (tpow A (M₀ + d + p)) A = _
      rw [hstep, tmul_const_add]
      rfl

/-- **Cyclicity of tropical powers (conjecture C1) for integer matrices.**
If all entries of `A` are integers then there are a period `p ≥ 1` and a transient `N`
such that `A^{⊗(m+p+1)} = (p·λ) ⊗ A^{⊗(m+1)}` for every `m ≥ N`, where `λ` is the maximum
cycle mean: after a finite transient the tropical powers are *exactly* — not merely
asymptotically — linear in the exponent. -/
theorem exists_cyclicity (A : Matrix ι ι ℝ) (hA : ∀ i j, ∃ z : ℤ, A i j = (z : ℝ)) :
    ∃ p N : ℕ, 0 < p ∧ ∀ m, N ≤ m →
      tpow A (m + p) = fun i j => (p : ℝ) * maxCycleMean A + tpow A m i j := by
  classical
  set lam := maxCycleMean A with hlam
  obtain ⟨q, w, hq0, hqw⟩ := exists_critical_cycle_int hA
  obtain ⟨K, N, hK0, hbound⟩ := exists_uniform_entry_bound A
  -- integer values of the powers along the progression `m = N + t*q`
  have hint : ∀ (t : ℕ) (i j : ι), ∃ z : ℤ, tpow A (N + t * q) i j = (z : ℝ) :=
    fun t i j => tpow_isInt hA _ i j
  choose e he using hint
  -- the normalised integer matrices are uniformly bounded
  set M : ℤ := ⌈K + |((N : ℝ) + 1) * lam|⌉ with hM
  have hMbound : ∀ (t : ℕ) (i j : ι), (e t i j - t * w) ∈ Finset.Icc (-M) M := by
    intro t i j
    have hb := hbound (N + t * q) (by omega) i j
    rw [he t i j] at hb
    have hcast : (((N + t * q : ℕ) : ℝ) + 1) * lam = ((N : ℝ) + 1) * lam + (t : ℝ) * (w : ℝ) := by
      have : (((N + t * q : ℕ) : ℝ) + 1) = ((N : ℝ) + 1) + (t : ℝ) * (q : ℝ) := by
        push_cast; ring
      rw [this, add_mul, mul_assoc, hqw]
    rw [hcast] at hb
    have habs : |((e t i j : ℝ) - (t : ℝ) * (w : ℝ))| ≤ K + |((N : ℝ) + 1) * lam| := by
      have h1 := abs_le.mp hb
      have h2 := abs_le.mp (le_refl |((N : ℝ) + 1) * lam|)
      have h3 : -|((N : ℝ) + 1) * lam| ≤ ((N : ℝ) + 1) * lam := neg_abs_le _
      have h4 : ((N : ℝ) + 1) * lam ≤ |((N : ℝ) + 1) * lam| := le_abs_self _
      rw [abs_le]
      constructor <;> [linarith [h1.1]; linarith [h1.2]]
    have hle : |((e t i j - t * w : ℤ) : ℝ)| ≤ (M : ℝ) := by
      have : ((e t i j - t * w : ℤ) : ℝ) = (e t i j : ℝ) - (t : ℝ) * (w : ℝ) := by push_cast; ring
      rw [this]
      exact le_trans habs (by rw [hM]; exact_mod_cast Int.le_ceil _)
    have := abs_le.mp hle
    simp only [Finset.mem_Icc]
    constructor
    · exact_mod_cast this.1
    · exact_mod_cast this.2
  -- pigeonhole: two of these integer matrices coincide
  set F : ℕ → (ι × ι → (Finset.Icc (-M) M : Finset ℤ)) :=
    fun t p => ⟨e t p.1 p.2 - t * w, hMbound t p.1 p.2⟩ with hF
  obtain ⟨t₁, t₂, hne, hFeq⟩ := Finite.exists_ne_map_eq_of_infinite F
  -- normalise so that `t₁ < t₂`
  obtain ⟨s₁, s₂, hs, hseq⟩ : ∃ s₁ s₂ : ℕ, s₁ < s₂ ∧ ∀ i j : ι,
      e s₁ i j - s₁ * w = e s₂ i j - s₂ * w := by
    have hval : ∀ i j : ι, e t₁ i j - t₁ * w = e t₂ i j - t₂ * w := by
      intro i j
      have := congrFun hFeq (i, j)
      simpa [hF] using congrArg Subtype.val this
    rcases lt_or_gt_of_ne hne with h | h
    · exact ⟨t₁, t₂, h, hval⟩
    · exact ⟨t₂, t₁, h, fun i j => (hval i j).symm⟩
  refine ⟨(s₂ - s₁) * q, N + s₁ * q, Nat.mul_pos (by omega) hq0, ?_⟩
  -- the single exact relation, then propagate
  have hstep : tpow A ((N + s₁ * q) + (s₂ - s₁) * q)
      = fun i j => ((((s₂ - s₁) * q : ℕ) : ℝ)) * lam + tpow A (N + s₁ * q) i j := by
    have hidx : (N + s₁ * q) + (s₂ - s₁) * q = N + s₂ * q := by
      have : (s₂ - s₁) * q + s₁ * q = s₂ * q := by
        have : (s₂ - s₁) + s₁ = s₂ := by omega
        calc (s₂ - s₁) * q + s₁ * q = ((s₂ - s₁) + s₁) * q := by ring
          _ = s₂ * q := by rw [this]
      omega
    rw [hidx]
    funext i j
    have hij := hseq i j
    have hreal : (e s₂ i j : ℝ) = (e s₁ i j : ℝ) + ((s₂ : ℝ) - (s₁ : ℝ)) * (w : ℝ) := by
      have : ((e s₂ i j : ℤ) : ℝ) = ((e s₁ i j - s₁ * w + s₂ * w : ℤ) : ℝ) := by
        exact_mod_cast congrArg (fun z : ℤ => ((z : ℝ))) (by omega : e s₂ i j = e s₁ i j - s₁ * w + s₂ * w)
      rw [this]; push_cast; ring
    have hcast : ((((s₂ - s₁) * q : ℕ) : ℝ)) * lam = ((s₂ : ℝ) - (s₁ : ℝ)) * (w : ℝ) := by
      have h1 : (((s₂ - s₁) * q : ℕ) : ℝ) = ((s₂ : ℝ) - (s₁ : ℝ)) * (q : ℝ) := by
        have : ((s₂ - s₁ : ℕ) : ℝ) = (s₂ : ℝ) - (s₁ : ℝ) := by
          have : s₁ ≤ s₂ := by omega
          push_cast [this]; ring
        push_cast [this]
        ring
      rw [h1, mul_assoc, hqw]
    rw [he s₂ i j, he s₁ i j, hreal, hcast]
    ring
  intro m hm
  exact tpow_periodic_of_step hstep m hm

/-- The hypothesis of `exists_cyclicity` is satisfied by (the real image of) any integer
matrix, so the cyclicity theorem is not vacuous. -/
theorem exists_cyclicity_of_intMatrix (B : Matrix ι ι ℤ) :
    ∃ p N : ℕ, 0 < p ∧ ∀ m, N ≤ m →
      tpow (Matrix.of fun i j => (B i j : ℝ)) (m + p)
        = fun i j => (p : ℝ) * maxCycleMean (Matrix.of fun i j => (B i j : ℝ))
            + tpow (Matrix.of fun i j => (B i j : ℝ)) m i j :=
  exists_cyclicity _ fun i j => ⟨B i j, rfl⟩

/-! ## Positive rescaling, and cyclicity for commensurable entries -/

section Scaling

variable {A : Matrix ι ι ℝ} {lam c : ℝ} {v : ι → ℝ}

/-- Multiplying all entries by `c ≥ 0` multiplies the eigenvalue and the eigenvector by `c`. -/
theorem isTropEigen_const_mul (hc : 0 ≤ c) (h : IsTropEigen A lam v) :
    IsTropEigen (Matrix.of fun i j => c * A i j) (c * lam) (fun i => c * v i) := by
  intro i
  apply le_antisymm
  · refine Finset.sup'_le _ _ fun j _ => ?_
    have hle := h.le_of i j
    have := mul_le_mul_of_nonneg_left hle hc
    show c * A i j + c * v j ≤ c * lam + c * v i
    nlinarith
  · obtain ⟨j, hj⟩ := h.exists_tight i
    have hle : (Matrix.of fun i j => c * A i j) i j + c * v j ≤
        tmulVec (Matrix.of fun i j => c * A i j) (fun i => c * v i) i :=
      le_tmulVec (Matrix.of fun i j => c * A i j) (fun i => c * v i) i j
    have hval : c * (A i j + v j) = c * (lam + v i) := by rw [hj]
    show c * lam + c * v i ≤ _
    simp only [Matrix.of_apply] at hle
    nlinarith

/-- The maximum cycle mean is positively homogeneous. -/
theorem maxCycleMean_const_mul (hc : 0 ≤ c) (A : Matrix ι ι ℝ) :
    maxCycleMean (Matrix.of fun i j => c * A i j) = c * maxCycleMean A := by
  obtain ⟨v, hv⟩ := exists_tropEigen A
  exact ((tropEigen_iff_eq_maxCycleMean _ (c * maxCycleMean A)).1
    ⟨_, isTropEigen_const_mul hc hv⟩).symm

/-- Tropical powers are positively homogeneous. -/
theorem tpow_const_mul (hc : 0 ≤ c) (A : Matrix ι ι ℝ) (m : ℕ) (i j : ι) :
    tpow (Matrix.of fun i j => c * A i j) m i j = c * tpow A m i j := by
  induction m generalizing i j with
  | zero => rfl
  | succ m ih =>
      show tmul (tpow (Matrix.of fun i j => c * A i j) m) (Matrix.of fun i j => c * A i j) i j
        = c * tmul (tpow A m) A i j
      apply le_antisymm
      · refine tmul_le fun k => ?_
        have h1 := le_tmul (tpow A m) A i j k
        have h2 := mul_le_mul_of_nonneg_left h1 hc
        rw [ih i k]
        show c * tpow A m i k + c * A k j ≤ c * tmul (tpow A m) A i j
        nlinarith
      · obtain ⟨k, hk⟩ := exists_tmul_eq (tpow A m) A i j
        have hle := le_tmul (tpow (Matrix.of fun i j => c * A i j) m)
          (Matrix.of fun i j => c * A i j) i j k
        rw [ih i k] at hle
        simp only [Matrix.of_apply] at hle
        rw [hk]
        nlinarith

/-- **Cyclicity for commensurable entries.**  If some positive integer multiple `d·A` of `A`
has integer entries (equivalently: the entries of `A` are rationals with a common
denominator), then the tropical powers of `A` are eventually exactly periodic with the
spectral shift `p·λ`.  In particular this covers every rational matrix. -/
theorem exists_cyclicity_of_commensurable (A : Matrix ι ι ℝ) (d : ℕ) (hd : 0 < d)
    (hA : ∀ i j, ∃ z : ℤ, (d : ℝ) * A i j = (z : ℝ)) :
    ∃ p N : ℕ, 0 < p ∧ ∀ m, N ≤ m →
      tpow A (m + p) = fun i j => (p : ℝ) * maxCycleMean A + tpow A m i j := by
  have hd0 : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  set B : Matrix ι ι ℝ := Matrix.of fun i j => (d : ℝ) * A i j with hB
  obtain ⟨p, N, hp, hcyc⟩ := exists_cyclicity B (fun i j => hA i j)
  refine ⟨p, N, hp, fun m hm => ?_⟩
  funext i j
  have h1 := congrFun (congrFun (hcyc m hm) i) j
  rw [hB] at h1
  rw [tpow_const_mul (le_of_lt hd0) A (m + p) i j, tpow_const_mul (le_of_lt hd0) A m i j,
    maxCycleMean_const_mul (le_of_lt hd0) A] at h1
  have h2 : (d : ℝ) * tpow A (m + p) i j
      = (d : ℝ) * ((p : ℝ) * maxCycleMean A + tpow A m i j) := by
    rw [h1]; ring
  exact mul_left_cancel₀ (ne_of_gt hd0) h2

end Scaling

end TropicalLA