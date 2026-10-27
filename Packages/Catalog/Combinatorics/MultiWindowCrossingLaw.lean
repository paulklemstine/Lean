import Catalog.Combinatorics.MultiWindowLayerCake

/-!
# Multi-window crossing law, part II: step posteriors and the polyhedral gate

An oracle names nested windows `[0, B 1) ⊂ [0, B 2) ⊂ … ⊂ [0, B (n-1))` of `M = B n` cells
(with `B 0 = 0`) and cumulative reliabilities `A 1 ≤ … ≤ A (n-1)` (`A 0 = 0`, `A n = 1`).
The **step posterior** spreads the block mass `A (i+1) - A i` uniformly over block
`[B i, B (i+1))`.  The last block is the complement of the widest window.

## Main results
* `committed_cost_blocks` — the committed cost is `Σ_i (A(i+1) - A i) · (mean slot of block i)`.
* `committed_cost_normalized` — exactly `M · Φ(B/M, A) + (A n - A 0)/2`, where
  `Φ(x, A) = Σ_i (A(i+1) - A i)(x i + x (i+1))/2` is the **gate functional**.
* `stepPosterior_antitone`, `multi_window_bayes_optimal` — for calibrated (nonincreasing)
  block densities, committed search is Bayes-optimal among all `M!` orders.
* **`multi_window_crossing_law_exact`** — speedup `s` is reachable by *some* order iff
  `s · (M Φ + 1/2) ≤ minBlind M`: an exact polyhedral gate at every finite `M`.
* **`multi_crossing_law`** — continuum gate: `s ≤ 1/(3Φ) ↔ Φ ≤ 1/(3s)`.
* `gateCost_add_area`, **`auc_crossing_law`** — `Φ = 1 - AUC` where `AUC` is the area under the
  piecewise-linear reliability curve, so `s` is reachable iff `AUC ≥ 1 - 1/(3s)`.
* **`single_window_crossing_law`** — the case `n = 2` is the classical crossing law
  `w ≤ α - α_min(s)` with `α_min(s) = 1 - 2/(3s)`.
* **`outer_reliability_gate`** — however many inner windows, reaching `s` forces the widest
  window's reliability strictly above `α_min(s)`: inner windows cannot substitute either.
* `refinement_identity`, `refinement_helps_iff` — adding a window point changes `Φ` by
  `-(x_r - x_l)(α' - chord(x'))/2`: a new window helps iff it lies above the chord.
* `gateCost_affine`, `gate_convex` — the reachable reliability profiles form a convex set.
* `gateCost_mono_reliability`, `gateCost_mono_width` — more reliability always helps, more
  width always hurts.
* `naive_gate_fails` — the gate *must* include the complement block; omitting it is false.
-/

namespace MultiWindowCrossingLaw

open Finset

/-! ## 1. Step posteriors and their committed cost -/

/-- Density of block `i = [B i, B (i+1))` carrying mass `A (i+1) - A i`. -/
noncomputable def blockDensity (B : ℕ → ℕ) (A : ℕ → ℝ) (i : ℕ) : ℝ :=
  (A (i + 1) - A i) / ((B (i + 1) : ℝ) - B i)

/-- Step weight of cell `j`: the density of the block containing it. -/
noncomputable def stepWeight (n : ℕ) (B : ℕ → ℕ) (A : ℕ → ℝ) (j : ℕ) : ℝ :=
  ∑ i ∈ range n, if B i ≤ j ∧ j < B (i + 1) then blockDensity B A i else 0

/-- The step posterior on `Fin M`. -/
noncomputable def stepPosterior {M : ℕ} (n : ℕ) (B : ℕ → ℕ) (A : ℕ → ℝ) (j : Fin M) : ℝ :=
  stepWeight n B A j

lemma sum_Ico_succ_real (a b : ℕ) (hab : a ≤ b) :
    ∑ j ∈ Ico a b, ((j : ℝ) + 1) = ((b : ℝ) - a) * (a + b + 1) / 2 := by
  induction b, hab using Nat.le_induction with
  | base => simp
  | succ m hm ih =>
    rw [sum_Ico_succ_top hm, ih]; push_cast; ring

/-- **Committed cost of a step posterior.**  It is the sum over blocks of the block mass
times the mean (1-based) slot of the block. -/
theorem committed_cost_blocks (M n : ℕ) (B : ℕ → ℕ) (A : ℕ → ℝ) (hB : StrictMono B)
    (hBn : B n ≤ M) :
    probeCost (stepPosterior (M := M) n B A) (Equiv.refl _) =
      ∑ i ∈ range n, (A (i + 1) - A i) * (((B i : ℝ) + B (i + 1) + 1) / 2) := by
  unfold probeCost stepPosterior
  simp only [Equiv.refl_apply]
  rw [Fin.sum_univ_eq_sum_range (fun j => ((j : ℝ) + 1) * stepWeight n B A j) M]
  unfold stepWeight
  simp_rw [mul_sum]
  rw [sum_comm]
  refine sum_congr rfl fun i hi => ?_
  simp only [mem_range] at hi
  have hle : B (i + 1) ≤ M := (hB.monotone (by omega : i + 1 ≤ n)).trans hBn
  have hlt : B i < B (i + 1) := hB (Nat.lt_succ_self i)
  have hfilt : (range M).filter (fun j => B i ≤ j ∧ j < B (i + 1)) = Ico (B i) (B (i + 1)) := by
    ext j; simp only [mem_filter, mem_range, mem_Ico]; omega
  have : ∑ j ∈ range M, ((j : ℝ) + 1) * (if B i ≤ j ∧ j < B (i + 1) then blockDensity B A i
      else 0) = blockDensity B A i * ∑ j ∈ Ico (B i) (B (i + 1)), ((j : ℝ) + 1) := by
    rw [← hfilt, sum_filter, mul_sum]
    exact sum_congr rfl fun j _ => by split_ifs <;> ring
  rw [this, sum_Ico_succ_real _ _ hlt.le]
  unfold blockDensity
  have hne : (B (i + 1) : ℝ) - B i ≠ 0 := by
    have : (B i : ℝ) < B (i + 1) := by exact_mod_cast hlt
    linarith
  field_simp

/-- The **gate functional** `Φ(x, A) = Σ_i (A(i+1) - A i) · (x i + x (i+1)) / 2`: block mass
times the mean normalized slot of the block. -/
noncomputable def gateCost (n : ℕ) (x A : ℕ → ℝ) : ℝ :=
  ∑ i ∈ range n, (A (i + 1) - A i) * ((x i + x (i + 1)) / 2)

lemma sum_range_telescope (n : ℕ) (f : ℕ → ℝ) : ∑ i ∈ range n, (f (i + 1) - f i) = f n - f 0 :=
  sum_range_sub f n

/-- **Normalized committed cost.**  With `x i = B i / M`, the committed cost is exactly
`M · Φ(x, A) + (A n - A 0)/2`. -/
theorem committed_cost_normalized (M n : ℕ) (hM : 0 < M) (B : ℕ → ℕ) (A : ℕ → ℝ)
    (hB : StrictMono B) (hBn : B n ≤ M) :
    probeCost (stepPosterior (M := M) n B A) (Equiv.refl _) =
      M * gateCost n (fun i => (B i : ℝ) / M) A + (A n - A 0) / 2 := by
  rw [committed_cost_blocks M n B A hB hBn, gateCost, ← sum_range_telescope n A, mul_sum,
    sum_div, ← sum_add_distrib]
  have hM' : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  refine sum_congr rfl fun i _ => ?_
  field_simp

/-! ## 2. Calibrated step posteriors: Bayes ≡ Committed -/

lemma stepWeight_on_block (n : ℕ) (B : ℕ → ℕ) (A : ℕ → ℝ) (hB : StrictMono B) (i j : ℕ)
    (hi : i < n) (h1 : B i ≤ j) (h2 : j < B (i + 1)) :
    stepWeight n B A j = blockDensity B A i := by
  unfold stepWeight
  rw [sum_eq_single i]
  · rw [if_pos ⟨h1, h2⟩]
  · intro l _ hli
    rw [if_neg]
    rintro ⟨hl1, hl2⟩
    rcases Nat.lt_or_gt_of_ne hli with h | h
    · have := hB.monotone (show l + 1 ≤ i by omega); omega
    · have := hB.monotone (show i + 1 ≤ l by omega); omega
  · intro h; exact absurd (mem_range.2 hi) h

lemma exists_block (n : ℕ) (B : ℕ → ℕ) (hB0 : B 0 = 0) (j : ℕ) (hj : j < B n) :
    ∃ i, i < n ∧ B i ≤ j ∧ j < B (i + 1) := by
  have hn : n ≠ 0 := by rintro rfl; omega
  have hex : ∃ i, j < B (i + 1) := ⟨n - 1, by rw [Nat.sub_add_cancel (by omega)]; exact hj⟩
  classical
  refine ⟨Nat.find hex, ?_, ?_, Nat.find_spec hex⟩
  · have := Nat.find_min' hex (show j < B (n - 1 + 1) by rw [Nat.sub_add_cancel (by omega)]; exact hj)
    omega
  · rcases h : Nat.find hex with _ | m
    · rw [hB0]; omega
    · have := Nat.find_min hex (show m < Nat.find hex by omega)
      omega

/-- **Calibrated step posteriors are nonincreasing.**  If the block densities are
nonincreasing, so is the step posterior on `Fin (B n)`. -/
theorem stepPosterior_antitone (n : ℕ) (B : ℕ → ℕ) (A : ℕ → ℝ) (hB : StrictMono B)
    (hB0 : B 0 = 0) (hd : AntitoneOn (blockDensity B A) (Set.Iio n)) :
    Antitone (stepPosterior (M := B n) n B A) := by
  intro j j' hjj'
  obtain ⟨i, hi, hi1, hi2⟩ := exists_block n B hB0 j j.isLt
  obtain ⟨i', hi', hi1', hi2'⟩ := exists_block n B hB0 j' j'.isLt
  have hjj : (j : ℕ) ≤ j' := hjj'
  have hii : i ≤ i' := by
    by_contra h
    have := hB.monotone (show i' + 1 ≤ i by omega)
    omega
  unfold stepPosterior
  rw [stepWeight_on_block n B A hB i j hi hi1 hi2, stepWeight_on_block n B A hB i' j' hi' hi1' hi2']
  exact hd (Set.mem_Iio.2 hi) (Set.mem_Iio.2 hi') hii

/-- **Bayes ≡ Committed for calibrated nested windows.**  If the block densities are
nonincreasing, committed search is optimal among all orders of the `M = B n` cells. -/
theorem multi_window_bayes_optimal (n : ℕ) (B : ℕ → ℕ) (A : ℕ → ℝ) (hB : StrictMono B)
    (hB0 : B 0 = 0) (hd : AntitoneOn (blockDensity B A) (Set.Iio n))
    (σ : Equiv.Perm (Fin (B n))) :
    probeCost (stepPosterior (M := B n) n B A) (Equiv.refl _) ≤
      probeCost (stepPosterior (M := B n) n B A) σ := by
  have hanti := stepPosterior_antitone n B A hB hB0 hd
  generalize hM : B n = M at σ hanti ⊢
  rcases M with _ | N
  · unfold probeCost; simp
  · exact committed_optimal_of_antitone N _ hanti σ

/-! ## 3. The exact multi-window crossing law -/

/-- The stipulated blind price: the min-law blind cost `(M+1)(2M+1)/(6M)`. -/
noncomputable def minBlind (M : ℕ) : ℝ := ((M : ℝ) + 1) * (2 * M + 1) / (6 * M)

/-- **Exact multi-window crossing law.**  For calibrated nested windows (`B 0 = 0`,
nonincreasing block densities, `A 0 = 0`, `A n = 1`) on `M = B n > 0` cells, speedup `s` is
reachable by **some** search order iff the gate functional satisfies
`s · (M · Φ(B/M, A) + 1/2) ≤ minBlind M`. -/
theorem multi_window_crossing_law_exact (n : ℕ) (B : ℕ → ℕ) (A : ℕ → ℝ) (hB : StrictMono B)
    (hB0 : B 0 = 0) (hM : 0 < B n) (hA0 : A 0 = 0) (hAn : A n = 1)
    (hd : AntitoneOn (blockDensity B A) (Set.Iio n)) (s : ℝ) (hs : 0 < s) :
    (∃ σ : Equiv.Perm (Fin (B n)),
        s * probeCost (stepPosterior (M := B n) n B A) σ ≤ minBlind (B n)) ↔
      s * ((B n : ℝ) * gateCost n (fun i => (B i : ℝ) / B n) A + 1 / 2) ≤ minBlind (B n) := by
  have hc := committed_cost_normalized (B n) n hM B A hB le_rfl
  rw [hA0, hAn] at hc
  constructor
  · rintro ⟨σ, hσ⟩
    have hopt := multi_window_bayes_optimal n B A hB hB0 hd σ
    rw [hc] at hopt
    have : s * ((B n : ℝ) * gateCost n (fun i => (B i : ℝ) / B n) A + (1 - 0) / 2) ≤
        s * probeCost (stepPosterior (M := B n) n B A) σ :=
      mul_le_mul_of_nonneg_left hopt hs.le
    norm_num at this ⊢
    linarith
  · intro h
    refine ⟨Equiv.refl _, ?_⟩
    rw [hc]; norm_num at h ⊢; linarith

/-! ## 4. The continuum gate -/

/-- Continuum priced speedup: blind cost `1/3` (per cell) against `Φ`. -/
noncomputable def multiSpeedup (n : ℕ) (x A : ℕ → ℝ) : ℝ := 1 / (3 * gateCost n x A)

/-- **THE MULTI-WINDOW CROSSING LAW (continuum).**  Speedup `s` is reachable iff
`Σ_i (A(i+1) - A i) · (mean slot of block i) ≤ 1/(3s)`. -/
theorem multi_crossing_law (n : ℕ) (x A : ℕ → ℝ) (s : ℝ) (hs : 0 < s)
    (hpos : 0 < gateCost n x A) :
    s ≤ multiSpeedup n x A ↔ gateCost n x A ≤ 1 / (3 * s) := by
  unfold multiSpeedup
  rw [le_div_iff₀ (by positivity), le_div_iff₀ (by positivity)]
  constructor <;> intro h <;> linarith

/-- Area under the piecewise-linear reliability curve through the points `(x i, A i)`. -/
noncomputable def reliabilityArea (n : ℕ) (x A : ℕ → ℝ) : ℝ :=
  ∑ i ∈ range n, ((A i + A (i + 1)) / 2) * (x (i + 1) - x i)

/-- **Gate functional + area = boundary term** (summation by parts). -/
theorem gateCost_add_area (n : ℕ) (x A : ℕ → ℝ) :
    gateCost n x A + reliabilityArea n x A = A n * x n - A 0 * x 0 := by
  unfold gateCost reliabilityArea
  rw [← sum_add_distrib, ← sum_range_telescope n (fun i => A i * x i)]
  exact sum_congr rfl fun i _ => by ring

/-- **AUC form of the crossing law.**  On the normalized cell range `[0, 1]` with total
reliability `1`, speedup `s` is reachable iff the area under the reliability curve is at least
`1 - 1/(3s)`. -/
theorem auc_crossing_law (n : ℕ) (x A : ℕ → ℝ) (hx0 : x 0 = 0) (hxn : x n = 1) (hAn : A n = 1)
    (s : ℝ) (hs : 0 < s) (hpos : 0 < gateCost n x A) :
    s ≤ multiSpeedup n x A ↔ 1 - 1 / (3 * s) ≤ reliabilityArea n x A := by
  rw [multi_crossing_law n x A s hs hpos]
  have := gateCost_add_area n x A
  rw [hx0, hxn, hAn] at this
  constructor <;> intro h <;> linarith

/-- The single-window reliability gate `α_min(s) = 1 - 2/(3s)`. -/
noncomputable def alphaMin (s : ℝ) : ℝ := 1 - 2 / (3 * s)

/-- Single-window profile: points `(0,0)`, `(w, α)`, `(1,1)`. -/
noncomputable def singleX (w : ℝ) : ℕ → ℝ := fun i => if i = 0 then 0 else if i = 1 then w else 1
noncomputable def singleA (α : ℝ) : ℕ → ℝ := fun i => if i = 0 then 0 else if i = 1 then α else 1

lemma gateCost_single (α w : ℝ) : gateCost 2 (singleX w) (singleA α) = (1 - α + w) / 2 := by
  simp [gateCost, sum_range_succ, singleX, singleA]; ring

/-- **The single-window case is the crossing law.**  For `n = 2` the multi-window gate reads
`w ≤ α - α_min(s)`. -/
theorem single_window_crossing_law (s α w : ℝ) (hs : 0 < s) (hpos : 0 < 1 - α + w) :
    s ≤ multiSpeedup 2 (singleX w) (singleA α) ↔ w ≤ α - alphaMin s := by
  rw [multi_crossing_law 2 _ _ s hs (by rw [gateCost_single]; linarith), gateCost_single,
    alphaMin]
  have h : 2 / (3 * s) = 2 * (1 / (3 * s)) := by ring
  rw [h]
  constructor <;> intro h <;> linarith

/-- **Outer reliability gate.**  For a monotone profile (`0 = x 0 ≤ x 1 ≤ … ≤ x n = 1`,
`A` nondecreasing, `A n = 1`, `n ≥ 1`), reaching speedup `s` forces
`(1 - A (n-1)) (1 + x (n-1)) ≤ 2/(3s)`; in particular, if the widest window has positive width,
its reliability must exceed `α_min(s)` — no number of inner windows can substitute. -/
theorem outer_reliability_gate (n : ℕ) (hn : 1 ≤ n) (x A : ℕ → ℝ) (hx0 : x 0 = 0)
    (hxm : Monotone x) (hxn : x n = 1) (hAm : Monotone A) (hAn : A n = 1) (s : ℝ) (hs : 0 < s)
    (hpos : 0 < gateCost n x A) (hreach : s ≤ multiSpeedup n x A) (hw : 0 < x (n - 1)) :
    alphaMin s < A (n - 1) := by
  rw [multi_crossing_law n x A s hs hpos] at hreach
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel] at hw ⊢
  have hlast : (1 - A m) * ((x m + 1) / 2) ≤ gateCost (m + 1) x A := by
    unfold gateCost
    rw [sum_range_succ, hAn, hxn]
    have : 0 ≤ ∑ i ∈ range m, (A (i + 1) - A i) * ((x i + x (i + 1)) / 2) := by
      refine sum_nonneg fun i _ => mul_nonneg (by linarith [hAm (Nat.le_succ i)]) ?_
      have := hxm (Nat.zero_le i); have := hxm (Nat.zero_le (i + 1)); linarith
    linarith
  have hA1 : A m ≤ 1 := by rw [← hAn]; exact hAm (Nat.le_succ m)
  unfold alphaMin
  have h3 : 1 / (3 * s) * 2 = 2 / (3 * s) := by ring
  rcases eq_or_lt_of_le hA1 with h | h
  · rw [h]; have : 0 < 2 / (3 * s) := by positivity
    linarith
  · have hprod : (1 - A m) * (x m + 1) ≤ 2 / (3 * s) := by linarith
    have : (1 - A m) * 1 < (1 - A m) * (x m + 1) := mul_lt_mul_of_pos_left (by linarith)
      (by linarith)
    linarith

/-! ## 5. Refinement, monotonicity and convexity of the gate -/

/-- **Refinement identity.**  Splitting the block `(x_l, a_l) → (x_r, a_r)` at the new window
point `(x', α')` changes the gate functional by `-(x_r - x_l)(α' - chord(x'))/2`, where
`(x_r - x_l) · chord(x') = a_l (x_r - x') + a_r (x' - x_l)`. -/
theorem refinement_identity (xl xr x' al ar α' : ℝ) :
    ((α' - al) * ((xl + x') / 2) + (ar - α') * ((x' + xr) / 2)) - (ar - al) * ((xl + xr) / 2) =
      -((xr - xl) * α' - (al * (xr - x') + ar * (x' - xl))) / 2 := by
  ring

/-- **A new window helps iff it lies strictly above the chord.** -/
theorem refinement_helps_iff (xl xr x' al ar α' : ℝ) :
    (α' - al) * ((xl + x') / 2) + (ar - α') * ((x' + xr) / 2) < (ar - al) * ((xl + xr) / 2) ↔
      al * (xr - x') + ar * (x' - xl) < (xr - xl) * α' := by
  have := refinement_identity xl xr x' al ar α'
  constructor <;> intro h <;> linarith

/-- The gate functional is affine (indeed linear) in the reliability profile. -/
theorem gateCost_affine (n : ℕ) (x A A' : ℕ → ℝ) (t : ℝ) :
    gateCost n x (fun i => t * A i + (1 - t) * A' i) =
      t * gateCost n x A + (1 - t) * gateCost n x A' := by
  unfold gateCost
  rw [mul_sum, mul_sum, ← sum_add_distrib]
  exact sum_congr rfl fun i _ => by ring

/-- **The gate is convex (polyhedral) in the reliabilities.**  If two reliability profiles
on the same windows both satisfy the gate `Φ ≤ 1/(3s)`, so does every mixture. -/
theorem gate_convex (n : ℕ) (x A A' : ℕ → ℝ) (s t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hA : gateCost n x A ≤ 1 / (3 * s)) (hA' : gateCost n x A' ≤ 1 / (3 * s)) :
    gateCost n x (fun i => t * A i + (1 - t) * A' i) ≤ 1 / (3 * s) := by
  rw [gateCost_affine]
  nlinarith

/-- Coefficient form: `Φ = boundary - Σ_{inner} A i · (x (i+1) - x (i-1))/2`.  Raising an inner
reliability `A j` (`0 < j < n`) by `δ` lowers `Φ` by `δ (x (j+1) - x (j-1))/2`. -/
theorem gateCost_mono_reliability (n j : ℕ) (hj0 : 0 < j) (hjn : j < n) (x A : ℕ → ℝ)
    (δ : ℝ) :
    gateCost n x (Function.update A j (A j + δ)) =
      gateCost n x A - δ * (x (j + 1) - x (j - 1)) / 2 := by
  obtain ⟨m, rfl⟩ : ∃ m, j = m + 1 := ⟨j - 1, by omega⟩
  have key : ∀ N, m + 2 ≤ N → gateCost N x (Function.update A (m + 1) (A (m + 1) + δ)) =
      gateCost N x A - δ * (x (m + 1 + 1) - x (m + 1 - 1)) / 2 := by
    intro N hN
    induction N, hN using Nat.le_induction with
    | base =>
      unfold gateCost
      rw [sum_range_succ, sum_range_succ, sum_range_succ, sum_range_succ]
      have hr : ∀ i ∈ range m, (Function.update A (m + 1) (A (m + 1) + δ) (i + 1) -
          Function.update A (m + 1) (A (m + 1) + δ) i) * ((x i + x (i + 1)) / 2) =
          (A (i + 1) - A i) * ((x i + x (i + 1)) / 2) := by
        intro i hi
        simp only [mem_range] at hi
        rw [Function.update_of_ne (by omega), Function.update_of_ne (by omega)]
      rw [sum_congr rfl hr]
      simp only [Function.update_self, Function.update_of_ne (show m ≠ m + 1 by omega),
        Function.update_of_ne (show m + 1 + 1 ≠ m + 1 by omega), Nat.add_sub_cancel]
      ring
    | succ N hN ih =>
      unfold gateCost at ih ⊢
      rw [sum_range_succ, sum_range_succ, ih,
        Function.update_of_ne (show N + 1 ≠ m + 1 by omega),
        Function.update_of_ne (show N ≠ m + 1 by omega)]
      ring
  exact key n (by omega)

/-- Widening an inner window `x j` (`0 < j < n`) by `δ`, at fixed cumulative reliabilities,
raises `Φ` by `δ (A (j+1) - A (j-1))/2 ≥ 0`: width never substitutes for reliability. -/
theorem gateCost_mono_width (n j : ℕ) (hj0 : 0 < j) (hjn : j < n) (x A : ℕ → ℝ) (δ : ℝ) :
    gateCost n (Function.update x j (x j + δ)) A =
      gateCost n x A + δ * (A (j + 1) - A (j - 1)) / 2 := by
  obtain ⟨m, rfl⟩ : ∃ m, j = m + 1 := ⟨j - 1, by omega⟩
  have key : ∀ N, m + 2 ≤ N → gateCost N (Function.update x (m + 1) (x (m + 1) + δ)) A =
      gateCost N x A + δ * (A (m + 1 + 1) - A (m + 1 - 1)) / 2 := by
    intro N hN
    induction N, hN using Nat.le_induction with
    | base =>
      unfold gateCost
      rw [sum_range_succ, sum_range_succ, sum_range_succ, sum_range_succ]
      have hr : ∀ i ∈ range m, (A (i + 1) - A i) *
          ((Function.update x (m + 1) (x (m + 1) + δ) i +
            Function.update x (m + 1) (x (m + 1) + δ) (i + 1)) / 2) =
          (A (i + 1) - A i) * ((x i + x (i + 1)) / 2) := by
        intro i hi
        simp only [mem_range] at hi
        rw [Function.update_of_ne (by omega), Function.update_of_ne (by omega)]
      rw [sum_congr rfl hr]
      simp only [Function.update_self, Function.update_of_ne (show m ≠ m + 1 by omega),
        Function.update_of_ne (show m + 1 + 1 ≠ m + 1 by omega), Nat.add_sub_cancel]
      ring
    | succ N hN ih =>
      unfold gateCost at ih ⊢
      rw [sum_range_succ, sum_range_succ, ih,
        Function.update_of_ne (show N + 1 ≠ m + 1 by omega),
        Function.update_of_ne (show N ≠ m + 1 by omega)]
      ring
  exact key n (by omega)

/-! ## 6. The complement block cannot be dropped -/

/-- **The naive gate (windows only, no complement block) is false.**  For one window of width
`1/2` and reliability `1/2`, the windows-only sum `α · w/2 = 1/8` is below `1/(3·2) = 1/6`,
yet the true priced speedup is `2/3 < 2`. -/
theorem naive_gate_fails :
    let α : ℝ := 1 / 2
    let w : ℝ := 1 / 2
    (α - 0) * ((0 + w) / 2) ≤ 1 / (3 * 2) ∧
      multiSpeedup 2 (singleX w) (singleA α) < 2 := by
  intro α w
  refine ⟨by norm_num [α, w], ?_⟩
  unfold multiSpeedup
  rw [gateCost_single]
  norm_num [α, w]

end MultiWindowCrossingLaw