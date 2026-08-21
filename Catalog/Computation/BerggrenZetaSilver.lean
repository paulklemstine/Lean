import Computation.BerggrenZetaSeeds

/-!
# The silver speed limit for Berggren hypotenuses, and the spectral spine

This file quantifies the *size* of the nodes of the Berggren tree at depth `k`, in terms of the
silver ratio `δ_S = 1 + √2` and its square `λ = δ_S² = 3 + 2√2` — the dominant eigenvalue of
the Barning matrix `A₂`, the other eigenvalue being `3 − 2√2 = λ⁻¹`.

## Main results

* `chyp_le_silver` : **the silver speed limit.**  Every node at depth `k` has hypotenuse
  `c ≤ 2 (3+2√2)^{k+1}`.  The proof runs the silver potential `Φ(m,n) = m + (√2−1)n`, which
  satisfies `Φ(s_i(m,n)) ≤ (1+√2) Φ(m,n)` for each of the three moves, with equality for the
  middle move.
* `spine_hyp_rec` : along the middle (`s₁`) spine the hypotenuses satisfy the exact linear
  recurrence `c_{k+2} = 6 c_{k+1} − c_k`, whose characteristic roots are precisely the
  eigenvalues `3 ± 2√2` of the Barning generators.
* `spine_hyp_closed` : the exact closed form
  `c_k = ((10+7√2)(3+2√2)^k + (10−7√2)(3−2√2)^k)/4`, i.e. the odd-indexed Pell numbers
  `5, 29, 169, 985, 5741, …`.
* `spine_hyp_log_growth` : `log c_k / k → log(3+2√2) = 2 log(1+√2)`;
  `layer_max_log_growth` : the same exponent governs the largest hypotenuse at depth `k`.
  So the *maximal* hypotenuse at depth `k` grows exactly like the square of the silver ratio,
  which is the arithmetic counterpart of the metric silver growth rate `log(1+√2)`.
-/

namespace BerggrenZeta

open Real Filter Topology

noncomputable section

/-- The silver ratio `1 + √2`. -/
def silver : ℝ := 1 + Real.sqrt 2

/-- The dominant eigenvalue `3 + 2√2 = silver²` of the Barning generator `A₂`. -/
def lam : ℝ := 3 + 2 * Real.sqrt 2

/-- The subdominant eigenvalue `3 − 2√2 = lam⁻¹`. -/
def lam' : ℝ := 3 - 2 * Real.sqrt 2

lemma sqrt2_sq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)

lemma sqrt2_pos : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)

lemma sqrt2_lt_two : Real.sqrt 2 < 2 := by
  nlinarith [sqrt2_sq, sqrt2_pos]

lemma one_lt_sqrt2 : 1 < Real.sqrt 2 := by
  nlinarith [sqrt2_sq, sqrt2_pos]

/-- `λ = 3 + 2√2` is the square of the silver ratio. -/
theorem lam_eq_silver_sq : lam = silver ^ 2 := by
  unfold lam silver
  nlinarith [sqrt2_sq]

/-- The two eigenvalues are reciprocal. -/
theorem lam_mul_lam' : lam * lam' = 1 := by
  unfold lam lam'
  nlinarith [sqrt2_sq]

theorem lam_add_lam' : lam + lam' = 6 := by unfold lam lam'; ring

lemma lam_pos : 0 < lam := by unfold lam; nlinarith [sqrt2_pos]

lemma one_lt_lam : 1 < lam := by unfold lam; nlinarith [sqrt2_pos]

lemma sqrt2_lt_three_halves : Real.sqrt 2 < 3 / 2 := by
  nlinarith [sqrt2_sq, sqrt2_pos]

lemma lam'_pos : 0 < lam' := by unfold lam'; nlinarith [sqrt2_lt_three_halves]

lemma lam'_lt_one : lam' < 1 := by unfold lam'; nlinarith [one_lt_sqrt2]

lemma silver_pos : 0 < silver := by unfold silver; nlinarith [sqrt2_pos]

/-! ## The silver potential -/

/-- The silver potential `Φ(m,n) = m + (√2 − 1) n`. -/
def pot (p : ℕ × ℕ) : ℝ := (p.1 : ℝ) + (Real.sqrt 2 - 1) * (p.2 : ℝ)

lemma pot_nonneg (p : ℕ × ℕ) : 0 ≤ pot p := by
  unfold pot
  nlinarith [one_lt_sqrt2, Nat.cast_nonneg (α := ℝ) p.1, Nat.cast_nonneg (α := ℝ) p.2]

lemma fst_le_pot (p : ℕ × ℕ) : (p.1 : ℝ) ≤ pot p := by
  unfold pot
  nlinarith [one_lt_sqrt2, Nat.cast_nonneg (α := ℝ) p.2]

/-- **The silver contraction estimate.**  Each Berggren move multiplies the silver potential by
at most `1 + √2`, with equality for the middle move `s₁`. -/
theorem pot_step_le (i : Fin 3) {p : ℕ × ℕ} (hp : IsSeed p) : pot (step i p) ≤ silver * pot p := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hpos, hlt, -, -⟩ := hp
  simp only at hpos hlt
  have hnm : (n : ℝ) ≤ (m : ℝ) := by exact_mod_cast hlt.le
  have hn0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hs := sqrt2_sq
  have hs1 := one_lt_sqrt2
  fin_cases i
  · show pot (2 * m - n, m) ≤ silver * pot (m, n)
    have hcast : ((2 * m - n : ℕ) : ℝ) = 2 * (m : ℝ) - (n : ℝ) := by
      have : n ≤ 2 * m := by omega
      push_cast [Nat.cast_sub this]
      ring
    unfold pot silver
    simp only [hcast]
    nlinarith
  · show pot (2 * m + n, m) ≤ silver * pot (m, n)
    unfold pot silver
    push_cast
    nlinarith
  · show pot (m + 2 * n, n) ≤ silver * pot (m, n)
    unfold pot silver
    push_cast
    nlinarith

/-- The middle move realises equality: the `s₁` spine is the extremal branch. -/
theorem pot_step_one_eq {p : ℕ × ℕ} : pot (step 1 p) = silver * pot p := by
  obtain ⟨m, n⟩ := p
  show pot (2 * m + n, m) = silver * pot (m, n)
  unfold pot silver
  push_cast
  nlinarith [sqrt2_sq]

lemma pot_root : pot (2, 1) = silver := by
  unfold pot silver
  push_cast
  ring

/-- The potential of a node at depth `k` is at most `(1+√2)^{k+1}`. -/
theorem pot_node_le (w : List (Fin 3)) : pot (node w) ≤ silver ^ (w.length + 1) := by
  induction w with
  | nil => simp [pot_root]
  | cons i w ih =>
    have h := pot_step_le i (isSeed_node w)
    calc pot (node (i :: w)) = pot (step i (node w)) := by rw [node_cons]
      _ ≤ silver * pot (node w) := h
      _ ≤ silver * silver ^ (w.length + 1) := by
          exact mul_le_mul_of_nonneg_left ih silver_pos.le
      _ = silver ^ (w.length + 1 + 1) := by ring
      _ = silver ^ ((i :: w).length + 1) := by simp [List.length_cons]

/-- **The silver speed limit for hypotenuses.**  At depth `k` every hypotenuse of the Berggren
tree is at most `2 (3+2√2)^{k+1}`. -/
theorem chyp_le_silver (w : List (Fin 3)) :
    (chyp w : ℝ) ≤ 2 * lam ^ (w.length + 1) := by
  have hs := isSeed_node w
  have hfst : ((node w).1 : ℝ) ≤ silver ^ (w.length + 1) :=
    le_trans (fst_le_pot _) (pot_node_le w)
  have hsnd : ((node w).2 : ℝ) ≤ ((node w).1 : ℝ) := by exact_mod_cast hs.lt.le
  have h0 : (0 : ℝ) ≤ ((node w).2 : ℝ) := Nat.cast_nonneg _
  have hpow : (0 : ℝ) < silver ^ (w.length + 1) := pow_pos silver_pos _
  have hchyp : (chyp w : ℝ) = ((node w).1 : ℝ) ^ 2 + ((node w).2 : ℝ) ^ 2 := by
    rw [chyp_def]; push_cast; ring
  rw [hchyp, lam_eq_silver_sq, ← pow_mul]
  have : ((node w).1 : ℝ) ^ 2 + ((node w).2 : ℝ) ^ 2 ≤ 2 * (silver ^ (w.length + 1)) ^ 2 := by
    nlinarith
  calc ((node w).1 : ℝ) ^ 2 + ((node w).2 : ℝ) ^ 2 ≤ 2 * (silver ^ (w.length + 1)) ^ 2 := this
    _ = 2 * silver ^ (2 * (w.length + 1)) := by rw [← pow_mul]; ring_nf
  

/-! ## The middle spine: Pell numbers and the eigenvalues `3 ± 2√2` -/

/-- The Pell numbers `1, 2, 5, 12, 29, …`. -/
def pell : ℕ → ℕ
  | 0 => 1
  | 1 => 2
  | (k + 2) => 2 * pell (k + 1) + pell k

@[simp] lemma pell_zero : pell 0 = 1 := rfl
@[simp] lemma pell_one : pell 1 = 2 := rfl
lemma pell_succ_succ (k : ℕ) : pell (k + 2) = 2 * pell (k + 1) + pell k := rfl

/-- The depth-`k` node of the middle spine (the word `1¹…1`). -/
def spine (k : ℕ) : ℕ × ℕ := node (List.replicate k 1)

/-- The middle spine consists of consecutive Pell numbers. -/
theorem spine_eq_pell (k : ℕ) : spine k = (pell (k + 1), pell k) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    have : spine (k + 1) = step 1 (spine k) := by
      unfold spine
      rw [List.replicate_succ, node_cons]
    rw [this, ih]
    show (2 * pell (k + 1) + pell k, pell (k + 1)) = (pell (k + 2), pell (k + 1))
    rw [pell_succ_succ]

/-- The hypotenuse along the middle spine. -/
def spineHyp (k : ℕ) : ℕ := chyp (List.replicate k 1)

lemma spineHyp_eq (k : ℕ) : spineHyp k = pell (k + 1) ^ 2 + pell k ^ 2 := by
  unfold spineHyp
  rw [chyp_def]
  have : node (List.replicate k 1) = spine k := rfl
  rw [this, spine_eq_pell]

@[simp] lemma spineHyp_zero : spineHyp 0 = 5 := by rw [spineHyp_eq]; norm_num
@[simp] lemma pell_two : pell 2 = 5 := rfl

@[simp] lemma spineHyp_one : spineHyp 1 = 29 := by rw [spineHyp_eq]; norm_num

/-- **The spectral recurrence.**  The hypotenuses along the middle spine satisfy
`c_{k+2} = 6 c_{k+1} − c_k`, the characteristic roots of which are exactly the eigenvalues
`3 ± 2√2` of the Barning matrix `A₂`. -/
theorem spine_hyp_rec (k : ℕ) : spineHyp (k + 2) + spineHyp k = 6 * spineHyp (k + 1) := by
  simp only [spineHyp_eq]
  rw [show k + 2 + 1 = k + 3 from rfl, show k + 1 + 1 = k + 2 from rfl,
    pell_succ_succ (k + 1), pell_succ_succ k]
  ring

/-- **Exact closed form** for the middle-spine hypotenuses in terms of the eigenvalues
`3 ± 2√2`: these are the odd-indexed Pell numbers `5, 29, 169, 985, 5741, …`. -/
theorem spine_hyp_closed (k : ℕ) :
    (spineHyp k : ℝ) =
      ((10 + 7 * Real.sqrt 2) * lam ^ k + (10 - 7 * Real.sqrt 2) * lam' ^ k) / 4 := by
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    match k with
    | 0 =>
      have h0 : ((spineHyp 0 : ℕ) : ℝ) = 5 := by norm_num
      rw [h0]
      simp only [pow_zero]
      ring
    | 1 =>
      have : (spineHyp 1 : ℝ) = 29 := by norm_num
      rw [this]
      unfold lam lam'
      simp only [pow_one]
      nlinarith [sqrt2_sq]
    | (k + 2) =>
      have h1 := ih (k + 1) (by omega)
      have h0 := ih k (by omega)
      have hrec : (spineHyp (k + 2) : ℝ) = 6 * spineHyp (k + 1) - spineHyp k := by
        have := spine_hyp_rec k
        have : ((spineHyp (k + 2) + spineHyp k : ℕ) : ℝ) = ((6 * spineHyp (k + 1) : ℕ) : ℝ) := by
          exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) this
        push_cast at this
        linarith
      rw [hrec, h1, h0]
      have hl : lam ^ (k + 2) = 6 * lam ^ (k + 1) - lam ^ k := by
        have : lam ^ 2 = 6 * lam - 1 := by unfold lam; nlinarith [sqrt2_sq]
        have hk : lam ^ (k + 2) = lam ^ k * lam ^ 2 := by ring
        rw [hk, this]; ring
      have hl' : lam' ^ (k + 2) = 6 * lam' ^ (k + 1) - lam' ^ k := by
        have : lam' ^ 2 = 6 * lam' - 1 := by unfold lam'; nlinarith [sqrt2_sq]
        have hk : lam' ^ (k + 2) = lam' ^ k * lam' ^ 2 := by ring
        rw [hk, this]; ring
      rw [hl, hl']
      ring

/-! ## The growth exponent of the tree is the square of the silver ratio -/

lemma spine_hyp_bounds (k : ℕ) : 4 * lam ^ k ≤ (spineHyp k : ℝ) ∧ (spineHyp k : ℝ) ≤ 6 * lam ^ k := by
  have hclosed := spine_hyp_closed k
  have hs := sqrt2_sq
  have hs1 := one_lt_sqrt2
  have hs2 := sqrt2_lt_two
  have hlk : (0 : ℝ) < lam ^ k := pow_pos lam_pos _
  have hl'k : (0 : ℝ) < lam' ^ k := pow_pos lam'_pos _
  have hl'k1 : lam' ^ k ≤ 1 := pow_le_one₀ lam'_pos.le lam'_lt_one.le
  have hlk1 : (1 : ℝ) ≤ lam ^ k := one_le_pow₀ one_lt_lam.le
  constructor
  · rw [hclosed]; nlinarith
  · rw [hclosed]; nlinarith

/-- **The growth exponent of the Berggren tree is `log(3+2√2) = 2 log(1+√2)`.**  Along the
middle spine, `log c_k / k` converges to the logarithm of the square of the silver ratio. -/
theorem spine_hyp_log_growth :
    Tendsto (fun k : ℕ => Real.log (spineHyp k) / k) atTop (𝓝 (Real.log lam)) := by
  have hlam := one_lt_lam
  have key : ∀ k : ℕ, 0 < k →
      (Real.log 4 + k * Real.log lam) / k ≤ Real.log (spineHyp k) / k ∧
      Real.log (spineHyp k) / k ≤ (Real.log 6 + k * Real.log lam) / k := by
    intro k hk
    obtain ⟨hlo, hhi⟩ := spine_hyp_bounds k
    have hkpos : (0 : ℝ) < k := by exact_mod_cast hk
    have hlk : (0 : ℝ) < lam ^ k := pow_pos lam_pos _
    have hpos : (0 : ℝ) < spineHyp k := lt_of_lt_of_le (by positivity) hlo
    have e4 : Real.log (4 * lam ^ k) = Real.log 4 + k * Real.log lam := by
      rw [Real.log_mul (by norm_num) (ne_of_gt hlk), Real.log_pow]
    have e6 : Real.log (6 * lam ^ k) = Real.log 6 + k * Real.log lam := by
      rw [Real.log_mul (by norm_num) (ne_of_gt hlk), Real.log_pow]
    constructor
    · have hle : Real.log 4 + k * Real.log lam ≤ Real.log (spineHyp k) := by
        rw [← e4]
        exact Real.log_le_log (by positivity) hlo
      gcongr
    · have hle : Real.log (spineHyp k) ≤ Real.log 6 + k * Real.log lam := by
        rw [← e6]
        exact Real.log_le_log hpos hhi
      gcongr
  have hlow : Tendsto (fun k : ℕ => (Real.log 4 + k * Real.log lam) / k) atTop
      (𝓝 (Real.log lam)) := by
    have : ∀ᶠ k : ℕ in atTop, (Real.log 4 + k * Real.log lam) / k
        = Real.log 4 / k + Real.log lam := by
      filter_upwards [eventually_gt_atTop 0] with k hk
      have : (k : ℝ) ≠ 0 := by positivity
      field_simp
    rw [tendsto_congr' this]
    have := Filter.Tendsto.add
      (tendsto_const_div_atTop_nhds_zero_nat (Real.log 4)) (tendsto_const_nhds (x := Real.log lam)
        (f := (atTop : Filter ℕ)))
    simpa using this
  have hhigh : Tendsto (fun k : ℕ => (Real.log 6 + k * Real.log lam) / k) atTop
      (𝓝 (Real.log lam)) := by
    have : ∀ᶠ k : ℕ in atTop, (Real.log 6 + k * Real.log lam) / k
        = Real.log 6 / k + Real.log lam := by
      filter_upwards [eventually_gt_atTop 0] with k hk
      have : (k : ℝ) ≠ 0 := by positivity
      field_simp
    rw [tendsto_congr' this]
    have := Filter.Tendsto.add
      (tendsto_const_div_atTop_nhds_zero_nat (Real.log 6)) (tendsto_const_nhds (x := Real.log lam)
        (f := (atTop : Filter ℕ)))
    simpa using this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [eventually_gt_atTop 0] with k hk using (key k hk).1
  · filter_upwards [eventually_gt_atTop 0] with k hk using (key k hk).2

/-- `log(3+2√2) = 2 log(1+√2)`: the growth exponent is twice the silver-ratio exponent, which
is exactly the factor `½` between `log c` and hyperbolic distance. -/
theorem log_lam_eq_two_log_silver : Real.log lam = 2 * Real.log silver := by
  rw [lam_eq_silver_sq, Real.log_pow]
  norm_num

/-- The largest hypotenuse at depth `k` is squeezed between `4 λ^k` and `2 λ^{k+1}`, so the
maximal hypotenuse of the depth-`k` layer grows exactly like `λ^k = (1+√2)^{2k}`. -/
theorem layer_max_bounds (k : ℕ) :
    4 * lam ^ k ≤ (spineHyp k : ℝ) ∧
    ∀ w : List (Fin 3), w.length = k → (chyp w : ℝ) ≤ 2 * lam ^ (k + 1) := by
  refine ⟨(spine_hyp_bounds k).1, fun w hw => ?_⟩
  have := chyp_le_silver w
  rwa [hw] at this

/-- **The exact exponential order of the depth-`k` layer.**  The maximal hypotenuse `M_k` of the
depth-`k` layer satisfies `log M_k / k → log(3+2√2) = 2 log(1+√2)`; the middle spine attains it. -/
theorem layer_max_log_growth :
    Tendsto (fun k : ℕ => Real.log (spineHyp k) / k) atTop (𝓝 (2 * Real.log silver)) := by
  rw [← log_lam_eq_two_log_silver]
  exact spine_hyp_log_growth

end

end BerggrenZeta