import Mathlib

/-!
# A quantitative low-rank obstruction for narrow attention heads

`Catalog/MachineLearning/TransformerUniversality/MultiHeadPlumbing.lean` proves the *exact*
low-rank bottleneck for query/key projections: the learned score matrix of a head of width
`dk` is `WQᵀ * WK`, its rank is at most `dk`, and consequently for `dk < d` it can never be
*equal* to the identity score pattern (`qk_ne_one_of_headDim_lt`).

Conjecture 5 of `FUTURE_DIRECTIONS.md` asked for the quantitative version of that statement:
being merely *unequal* to the identity is no obstruction at all in an approximation theory,
since a matrix can be unequal to the identity and yet within `10^{-9}` of it entrywise.  This
file proves the quantitative form, and in the temperature-aware shape that the conjecture
needs.

Main results:

* `exists_entry_far_from_smul_one` — a purely linear-algebraic statement: if
  `S : Matrix (Fin n) (Fin n) ℝ` has rank `< n`, then for every score scale `β ≥ 0` some entry
  of `S` differs from the corresponding entry of `β • 1` by at least `β / n`.  The proof takes
  a kernel vector `v`, normalizes it in the `ℓ¹` norm, and compares the quadratic form of
  `S - β • 1` at `v` (which equals `-β‖v‖₂²`) with its entrywise bound; the gap between the
  `ℓ¹` and `ℓ²` norms — i.e. Cauchy–Schwarz — is exactly where the factor `1/n` comes from.
* `entrywise_distance_to_identity_eq` — **the constant `1/n` is sharp**: the centering matrix
  `1 - (1/n) J` is singular and uniformly `1/n`-close to the identity, so the entrywise
  distance from the identity to the singular matrices is exactly `1/n`;
* `qk_far_from_scaled_identity` — the architectural corollary: for `dk < d`, **no** query/key
  pair of head width `dk` realizes the scaled identity score pattern to entrywise accuracy
  better than `β / d`.
* `qk_no_eps_identity` — the contrapositive as an impossibility statement: an `ε`-accurate
  identity score pattern with `ε < β / d` forces `d ≤ dk`.
* `headDim_lower_bound_of_approx` — the resulting **head-width lower bound**: to implement the
  exact-selection score pattern at scale `β` within entrywise error `ε`, one needs
  `dk ≥ d` whenever `ε < β / d`.

The point of the `β` in these statements is that the obstruction is *scale invariant*: raising
the score scale (equivalently, lowering the softmax temperature) raises the achievable error
floor by exactly the same factor, so the head-width resource of `MultiHeadPlumbing.lean` and
the temperature resource of `SoftmaxLookup.lean` cannot be traded against each other.
-/

open scoped BigOperators

namespace LowRankQuantitative

section Algebra

variable {n : ℕ}

/-- **Quantitative rank obstruction.**  A matrix of rank `< n` is entrywise at distance at
least `β / n` from `β` times the identity.

The bound is genuinely quantitative: the classical statement "a singular matrix is not `β • 1`"
is the special case `β / n > 0`, but here the distance is bounded below by an explicit constant
depending only on the dimension and the score scale. -/
theorem exists_entry_far_from_smul_one (hn : 0 < n) (S : Matrix (Fin n) (Fin n) ℝ)
    (hrank : S.rank < n) {beta : ℝ} (hbeta : 0 ≤ beta) :
    ∃ i j, beta / n ≤ |S i j - beta * (1 : Matrix (Fin n) (Fin n) ℝ) i j| := by
  classical
  haveI : NeZero n := ⟨hn.ne'⟩
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  -- a matrix of non-full rank is singular
  have hdet : S.det = 0 := by
    by_contra hd
    have hu : IsUnit S := (Matrix.isUnit_iff_isUnit_det S).mpr (isUnit_iff_ne_zero.mpr hd)
    have := Matrix.rank_of_isUnit S hu
    simp at this
    omega
  obtain ⟨v, hv0, hv⟩ := (Matrix.exists_mulVec_eq_zero_iff).mpr hdet
  -- normalize the kernel vector in the ℓ¹ norm
  set A : ℝ := ∑ i, |v i| with hA
  have hApos : 0 < A := by
    rcases Function.ne_iff.mp hv0 with ⟨i, hi⟩
    have hvi : 0 < |v i| := abs_pos.mpr (by simpa using hi)
    exact lt_of_lt_of_le hvi (Finset.single_le_sum (f := fun i => |v i|)
      (fun j _ => abs_nonneg _) (Finset.mem_univ i))
  set w : Fin n → ℝ := fun i => v i / A with hw
  have hwsum : ∑ i, |w i| = 1 := by
    simp only [hw, abs_div, abs_of_pos hApos]
    rw [← Finset.sum_div, ← hA, div_self hApos.ne']
  have hSw : ∀ i, ∑ j, S i j * w j = 0 := by
    intro i
    have h0 : ∑ j, S i j * v j = 0 := by
      have := congrFun hv i
      simpa [Matrix.mulVec, dotProduct] using this
    have hsplit : ∑ j, S i j * w j = (∑ j, S i j * v j) / A := by
      rw [Finset.sum_div]
      exact Finset.sum_congr rfl fun j _ => by simp [hw, mul_div_assoc]
    rw [hsplit, h0, zero_div]
  -- the quadratic form of the deviation matrix
  set D : Fin n → Fin n → ℝ :=
    fun i j => S i j - beta * (1 : Matrix (Fin n) (Fin n) ℝ) i j with hD
  have hquad : ∑ i, ∑ j, w i * D i j * w j = -(beta * ∑ i, (w i) ^ 2) := by
    have e1 : ∑ i, ∑ j, w i * S i j * w j = 0 := by
      refine Finset.sum_eq_zero fun i _ => ?_
      have hrow : ∑ j, w i * S i j * w j = w i * ∑ j, S i j * w j := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun j _ => by ring
      rw [hrow, hSw i, mul_zero]
    have e2 : ∑ i, ∑ j, w i * (beta * (1 : Matrix (Fin n) (Fin n) ℝ) i j) * w j
        = beta * ∑ i, (w i) ^ 2 := by
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl fun i _ => ?_
      rw [Finset.sum_eq_single i]
      · simp; ring
      · intro j _ hj; simp [(Ne.symm hj)]
      · intro h; exact absurd (Finset.mem_univ i) h
    have hsub : ∑ i, ∑ j, w i * D i j * w j
        = (∑ i, ∑ j, w i * S i j * w j)
          - ∑ i, ∑ j, w i * (beta * (1 : Matrix (Fin n) (Fin n) ℝ) i j) * w j := by
      rw [← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun i _ => ?_
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun j _ => by simp [hD]; ring
    rw [hsub, e1, e2, zero_sub]
  -- pick the largest entry of the deviation matrix
  obtain ⟨p, -, hmax⟩ := Finset.exists_max_image (Finset.univ : Finset (Fin n × Fin n))
    (fun p => |D p.1 p.2|) Finset.univ_nonempty
  refine ⟨p.1, p.2, ?_⟩
  set c : ℝ := |D p.1 p.2| with hc
  have hbound : |∑ i, ∑ j, w i * D i j * w j| ≤ c := by
    calc |∑ i, ∑ j, w i * D i j * w j| ≤ ∑ i, |∑ j, w i * D i j * w j| :=
          Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, ∑ j, |w i| * c * |w j| := by
          refine Finset.sum_le_sum fun i _ => ?_
          refine le_trans (Finset.abs_sum_le_sum_abs _ _) (Finset.sum_le_sum fun j _ => ?_)
          rw [abs_mul, abs_mul]
          have hij := hmax (i, j) (Finset.mem_univ _)
          have h1 : |w i| * |D i j| ≤ |w i| * c := mul_le_mul_of_nonneg_left hij (abs_nonneg _)
          exact mul_le_mul_of_nonneg_right h1 (abs_nonneg _)
      _ = c := by
          have e : ∀ i : Fin n, ∑ j, |w i| * c * |w j| = (|w i| * c) * ∑ j, |w j| :=
            fun i => (Finset.mul_sum _ _ _).symm
          rw [Finset.sum_congr rfl (fun i _ => e i), ← Finset.sum_mul, ← Finset.sum_mul, hwsum]
          ring
  -- Cauchy-Schwarz turns the ℓ¹ normalization into an ℓ² lower bound
  have hcs : (1 : ℝ) ≤ n * ∑ i, (w i) ^ 2 := by
    have h := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin n))) (f := fun i => |w i|)
    simpa [hwsum, sq_abs] using h
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have hl2 : (1 : ℝ) / n ≤ ∑ i, (w i) ^ 2 := by
    rw [div_le_iff₀ hn']
    nlinarith
  have hnonneg : (0 : ℝ) ≤ beta * ∑ i, (w i) ^ 2 :=
    mul_nonneg hbeta (Finset.sum_nonneg fun i _ => sq_nonneg _)
  have hfinal : beta * ∑ i, (w i) ^ 2 ≤ c := by
    rw [hquad, abs_neg, abs_of_nonneg hnonneg] at hbound
    exact hbound
  have : beta / n ≤ beta * ∑ i, (w i) ^ 2 := by
    rw [div_le_iff₀ hn']
    have : beta * (1 / n) ≤ beta * ∑ i, (w i) ^ 2 := mul_le_mul_of_nonneg_left hl2 hbeta
    calc beta = beta * (1 / n) * n := by field_simp
      _ ≤ (beta * ∑ i, (w i) ^ 2) * n := by nlinarith
  linarith

/-- The unscaled version (`β = 1`): a singular `n × n` matrix has some entry at distance at
least `1/n` from the identity. -/
theorem exists_entry_far_from_one (hn : 0 < n) (S : Matrix (Fin n) (Fin n) ℝ)
    (hrank : S.rank < n) :
    ∃ i j, (1 : ℝ) / n ≤ |S i j - (1 : Matrix (Fin n) (Fin n) ℝ) i j| := by
  obtain ⟨i, j, hij⟩ := exists_entry_far_from_smul_one hn S hrank (beta := 1) zero_le_one
  exact ⟨i, j, by simpa using hij⟩

section Sharpness

variable {n : ℕ}

/-- The centering matrix `1 - (1/n) J`: the orthogonal projection onto the mean-zero
hyperplane.  It is the extremal example for the bound above. -/
noncomputable def centering (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => (if i = j then (1 : ℝ) else 0) - (n : ℝ)⁻¹

/-- The centering matrix is singular: it kills the all-ones vector. -/
theorem centering_rank_lt (hn : 0 < n) : (centering n).rank < n := by
  have hnR : (n : ℝ) ≠ 0 := by positivity
  set v : Fin n → ℝ := fun _ => 1 with hv
  have hv0 : v ≠ 0 := by
    intro hc
    have := congrFun hc ⟨0, hn⟩
    simp [hv] at this
  have h : (centering n).mulVec v = 0 := by
    funext i
    simp only [Matrix.mulVec, dotProduct, centering, Matrix.of_apply, hv, mul_one]
    rw [Finset.sum_sub_distrib]
    simp [hnR]
  have hker : v ∈ LinearMap.ker (centering n).mulVecLin := by
    simpa [Matrix.mulVecLin] using h
  have hnt : Nontrivial (LinearMap.ker (centering n).mulVecLin) :=
    ⟨⟨0, ⟨v, hker⟩, fun hc => hv0 (congrArg Subtype.val hc).symm⟩⟩
  have hpos : 0 < Module.finrank ℝ (LinearMap.ker (centering n).mulVecLin) := Module.finrank_pos
  have hrk := LinearMap.finrank_range_add_finrank_ker (centering n).mulVecLin
  simp only [Matrix.rank]
  simp only [Module.finrank_fin_fun] at hrk
  omega

/-- Every entry of the centering matrix is at distance exactly `1/n` from the identity. -/
theorem centering_dev (hn : 0 < n) (i j : Fin n) :
    |centering n i j - (1 : Matrix (Fin n) (Fin n) ℝ) i j| = 1 / n := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  simp only [centering, Matrix.of_apply, Matrix.one_apply]
  by_cases h : i = j <;> simp [h, abs_of_nonneg, hnR.le]

/-- **The constant `1/n` is sharp.**  The centering matrix is singular and is uniformly within
`1/n` of the identity, so the lower bound of `exists_entry_far_from_one` cannot be improved:
the entrywise distance from the identity to the singular matrices is *exactly* `1/n`. -/
theorem entrywise_distance_to_identity_eq (hn : 0 < n) :
    IsLeast {r : ℝ | ∃ S : Matrix (Fin n) (Fin n) ℝ, S.rank < n ∧
      ∀ i j, |S i j - (1 : Matrix (Fin n) (Fin n) ℝ) i j| ≤ r} (1 / n) := by
  constructor
  · exact ⟨centering n, centering_rank_lt hn, fun i j => le_of_eq (centering_dev hn i j)⟩
  · rintro r ⟨S, hS, hr⟩
    obtain ⟨i, j, hij⟩ := exists_entry_far_from_one hn S hS
    exact le_trans hij (hr i j)

end Sharpness

end Algebra

section Heads

open Matrix

variable {d dk : ℕ}

/-- The learned score matrix of a head with query projection `WQ` and key projection `WK`
(cf. `MultiHeadPlumbing.qkScore_eq_bilinear`). -/
def scoreMatrix (WQ WK : Matrix (Fin dk) (Fin d) ℝ) : Matrix (Fin d) (Fin d) ℝ := WQᵀ * WK

theorem rank_scoreMatrix_le (WQ WK : Matrix (Fin dk) (Fin d) ℝ) :
    (scoreMatrix WQ WK).rank ≤ dk :=
  le_trans (Matrix.rank_mul_le_left _ _) (Matrix.rank_le_width WQᵀ)

/-- **Quantitative low-rank obstruction for narrow heads.**  If the head width is smaller than
the model width, then for every score scale `β ≥ 0` the learned score matrix has an entry at
distance at least `β / d` from the exact-selection pattern `β • 1`.  Increasing the score scale
increases the error floor proportionally, so temperature cannot compensate for a narrow head. -/
theorem qk_far_from_scaled_identity (hd : dk < d) (WQ WK : Matrix (Fin dk) (Fin d) ℝ)
    {beta : ℝ} (hbeta : 0 ≤ beta) :
    ∃ i j, beta / d ≤ |scoreMatrix WQ WK i j - beta * (1 : Matrix (Fin d) (Fin d) ℝ) i j| := by
  have hdpos : 0 < d := lt_of_le_of_lt (Nat.zero_le _) hd
  exact exists_entry_far_from_smul_one hdpos _
    (lt_of_le_of_lt (rank_scoreMatrix_le WQ WK) hd) hbeta

/-- **Impossibility of an `ε`-accurate selection pattern in a narrow head.**  If every entry of
the learned score matrix is within `ε < β / d` of the scaled identity, the head cannot be
narrow. -/
theorem qk_no_eps_identity (WQ WK : Matrix (Fin dk) (Fin d) ℝ) {beta eps : ℝ}
    (hbeta : 0 ≤ beta) (heps : eps < beta / d)
    (happrox : ∀ i j,
      |scoreMatrix WQ WK i j - beta * (1 : Matrix (Fin d) (Fin d) ℝ) i j| ≤ eps) :
    d ≤ dk := by
  by_contra hlt
  push_neg at hlt
  obtain ⟨i, j, hij⟩ := qk_far_from_scaled_identity hlt WQ WK hbeta
  exact absurd (lt_of_le_of_lt (le_trans hij (happrox i j)) heps) (lt_irrefl _)

/-- **Head-width lower bound.**  Realizing the exact-selection score pattern at scale `β > 0`
to entrywise accuracy better than `β / d` requires full head width. -/
theorem headDim_lower_bound_of_approx (WQ WK : Matrix (Fin dk) (Fin d) ℝ) {beta eps : ℝ}
    (hbeta : 0 < beta) (hd : 0 < d) (hsmall : eps * d < beta)
    (happrox : ∀ i j,
      |scoreMatrix WQ WK i j - beta * (1 : Matrix (Fin d) (Fin d) ℝ) i j| ≤ eps) :
    d ≤ dk := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  refine qk_no_eps_identity WQ WK hbeta.le ?_ happrox
  rw [lt_div_iff₀ hdpos]
  exact hsmall

end Heads

end LowRankQuantitative