module

public import Mathlib

/-!
# Two-sided tie correction of Spearman's rho and the headroom product bound

A *tie profile* is a list `L = [l₁, …, l_k]` of block sizes with `n = Σ lⱼ`.
The canonical midrank vector of `L` assigns to the `lⱼ` positions of block `j`
the midrank `sⱼ + (lⱼ + 1)/2`, where `sⱼ = l₁ + … + l_{j-1}`.
-/

@[expose] public section

open Finset

namespace Catalog.Logic.TieHeadroom

/-- Midrank at the 0-indexed position `i` of the canonical midrank vector of profile `L`. -/
noncomputable def profileRank : List ℕ → ℕ → ℝ
  | [], _ => 0
  | l :: L, i => if i < l then ((l : ℝ) + 1) / 2 else (l : ℝ) + profileRank L (i - l)

/-- The tie mass `Σⱼ (lⱼ³ - lⱼ)` of a profile. -/
noncomputable def tieMass (L : List ℕ) : ℝ := (L.map (fun l : ℕ => (l : ℝ) ^ 3 - l)).sum

/-- The classical tie-attenuation factor `1 - Σ (lⱼ³ - lⱼ)/(n³ - n)` (`spearmanSq L`). -/
noncomputable def tieFactor (L : List ℕ) : ℝ :=
  1 - tieMass L / ((L.sum : ℝ) ^ 3 - (L.sum : ℝ))

/-- Centered sum of squares of the midrank vector of `L`. -/
noncomputable def rankSS (L : List ℕ) : ℝ :=
  ∑ i ∈ range L.sum, (profileRank L i - ((L.sum : ℝ) + 1) / 2) ^ 2

lemma profileRank_cons_lt (l : ℕ) (L : List ℕ) {i : ℕ} (h : i < l) :
    profileRank (l :: L) i = ((l : ℝ) + 1) / 2 := by
  simp [profileRank, h]

lemma profileRank_cons_add (l : ℕ) (L : List ℕ) (x : ℕ) :
    profileRank (l :: L) (l + x) = (l : ℝ) + profileRank L x := by
  simp [profileRank]

lemma sum_profileRank (L : List ℕ) :
    ∑ i ∈ range L.sum, profileRank L i = (L.sum : ℝ) * (L.sum + 1) / 2 := by
  induction L with
  | nil => simp
  | cons l L ih =>
    rw [List.sum_cons, Finset.sum_range_add]
    rw [Finset.sum_congr rfl (fun x hx => profileRank_cons_lt l L (Finset.mem_range.mp hx)),
      Finset.sum_congr rfl (fun x _ => profileRank_cons_add l L x),
      Finset.sum_add_distrib, ih]
    simp; ring

lemma sum_sq_profileRank (L : List ℕ) :
    ∑ i ∈ range L.sum, profileRank L i ^ 2 =
      (L.sum : ℝ) * (L.sum + 1) * (2 * L.sum + 1) / 6 - tieMass L / 12 := by
  induction L with
  | nil => simp [tieMass]
  | cons l L ih =>
    have hs := sum_profileRank L
    rw [List.sum_cons, Finset.sum_range_add]
    have h1 : ∑ x ∈ range l, profileRank (l :: L) x ^ 2 = ∑ x ∈ range l, (((l : ℝ) + 1) / 2) ^ 2 :=
      Finset.sum_congr rfl (fun x hx => by rw [profileRank_cons_lt l L (Finset.mem_range.mp hx)])
    have h2 : ∑ x ∈ range L.sum, profileRank (l :: L) (l + x) ^ 2 =
        ∑ x ∈ range L.sum, ((l : ℝ) + profileRank L x) ^ 2 :=
      Finset.sum_congr rfl (fun x _ => by rw [profileRank_cons_add l L x])
    rw [h1, h2]
    have e : ∀ x, ((l : ℝ) + profileRank L x) ^ 2 =
        (l : ℝ) ^ 2 + 2 * l * profileRank L x + profileRank L x ^ 2 := fun x => by ring
    simp only [e, Finset.sum_add_distrib, ← Finset.mul_sum, ih, hs]
    simp [tieMass]; ring

/-- **Two-sided tie correction, variance form.**
`Σ (Rᵢ - (n+1)/2)² = ((n³ - n) - Σ (lⱼ³ - lⱼ)) / 12`. -/
theorem rankSS_eq (L : List ℕ) :
    rankSS L = (((L.sum : ℝ) ^ 3 - L.sum) - tieMass L) / 12 := by
  unfold rankSS
  have e : ∀ i, (profileRank L i - ((L.sum : ℝ) + 1) / 2) ^ 2 =
      profileRank L i ^ 2 - ((L.sum : ℝ) + 1) * profileRank L i + ((L.sum : ℝ) + 1) ^ 2 / 4 :=
    fun i => by ring
  simp only [e, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    sum_sq_profileRank, sum_profileRank]
  simp; ring

lemma cube_sub_pos {n : ℕ} (hn : 2 ≤ n) : (0 : ℝ) < (n : ℝ) ^ 3 - n := by
  have : (2 : ℝ) ≤ n := by exact_mod_cast hn
  have h : (n : ℝ) ^ 3 - n = n * ((n : ℝ) ^ 2 - 1) := by ring
  rw [h]; apply mul_pos <;> nlinarith

/-- Variance form with the tie factor: `rankSS L = (n³ - n)/12 · tieFactor L`. -/
theorem rankSS_eq_tieFactor (L : List ℕ) (hn : 2 ≤ L.sum) :
    rankSS L = ((L.sum : ℝ) ^ 3 - L.sum) / 12 * tieFactor L := by
  rw [rankSS_eq, tieFactor]
  have hne := (cube_sub_pos hn).ne'
  rw [mul_sub, mul_one,
    show ((L.sum : ℝ) ^ 3 - L.sum) / 12 * (tieMass L / ((L.sum : ℝ) ^ 3 - L.sum)) = tieMass L / 12 by
      rw [div_mul_div_comm, mul_comm (_ ^ 3 - _) (tieMass L), mul_div_mul_right _ _ hne]]
  ring

/-- The tie factor lies in `[0, 1]`; nonnegativity comes from the variance identity. -/
theorem tieFactor_nonneg (L : List ℕ) (hn : 2 ≤ L.sum) : 0 ≤ tieFactor L := by
  have h := rankSS_eq_tieFactor L hn
  have h0 : 0 ≤ rankSS L := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have := cube_sub_pos hn
  by_contra hc
  push_neg at hc
  have : ((L.sum : ℝ) ^ 3 - L.sum) / 12 * tieFactor L < 0 :=
    mul_neg_of_pos_of_neg (by positivity) hc
  linarith

lemma natCube_sub_nonneg (l : ℕ) : (0 : ℝ) ≤ (l : ℝ) ^ 3 - l := by
  rcases Nat.eq_zero_or_pos l with h | h
  · subst h; simp
  · have : (1 : ℝ) ≤ l := by exact_mod_cast h
    have e : (l : ℝ) ^ 3 - l = l * ((l : ℝ) ^ 2 - 1) := by ring
    rw [e]; apply mul_nonneg <;> nlinarith

lemma tieMass_nonneg (L : List ℕ) : 0 ≤ tieMass L := by
  unfold tieMass
  apply List.sum_nonneg
  intro x hx
  obtain ⟨l, -, rfl⟩ := List.mem_map.mp hx
  exact natCube_sub_nonneg l

theorem tieFactor_le_one (L : List ℕ) (hn : 2 ≤ L.sum) : tieFactor L ≤ 1 := by
  unfold tieFactor
  have := div_nonneg (tieMass_nonneg L) (cube_sub_pos hn).le
  linarith


/-! ## Rank covariance, the product bound and its equality case -/

/-- Centered cross-product of the midranks of `L` (observation order) against the midranks
of `M` assigned to the observations through the pairing `σ`. -/
noncomputable def rankCov (L M : List ℕ) (σ : Equiv.Perm (Fin L.sum)) : ℝ :=
  ∑ i : Fin L.sum, (profileRank L i - ((L.sum : ℝ) + 1) / 2) *
    (profileRank M (σ i) - ((L.sum : ℝ) + 1) / 2)

/-- Spearman's rho with the *untied* normalisation `(n³ - n)/12` (the textbook formula). -/
noncomputable def rhoUncorr (L M : List ℕ) (σ : Equiv.Perm (Fin L.sum)) : ℝ :=
  rankCov L M σ / (((L.sum : ℝ) ^ 3 - L.sum) / 12)

/-- Spearman's rho with the two-sided tie correction (Pearson correlation of midranks). -/
noncomputable def rhoCorr (L M : List ℕ) (σ : Equiv.Perm (Fin L.sum)) : ℝ :=
  rankCov L M σ / Real.sqrt (rankSS L * rankSS M)

/-- Maximal attainable (untied-normalised) Spearman rho over all pairings. -/
noncomputable def maxRho (L M : List ℕ) : ℝ := ⨆ σ : Equiv.Perm (Fin L.sum), rhoUncorr L M σ

lemma rankSS_fin (L M : List ℕ) (h : M.sum = L.sum) :
    rankSS M = ∑ i : Fin L.sum, (profileRank M i - ((L.sum : ℝ) + 1) / 2) ^ 2 := by
  rw [rankSS, h, Finset.sum_range]

/-- **Cauchy–Schwarz on the rank vectors.** -/
theorem rankCov_sq_le (L M : List ℕ) (h : M.sum = L.sum) (σ : Equiv.Perm (Fin L.sum)) :
    rankCov L M σ ^ 2 ≤ rankSS L * rankSS M := by
  unfold rankCov
  refine le_trans (Finset.sum_mul_sq_le_sq_mul_sq _ _ _) (le_of_eq ?_)
  rw [rankSS_fin L L rfl, rankSS_fin L M h,
    Equiv.sum_comp σ (fun j => (profileRank M j - ((L.sum : ℝ) + 1) / 2) ^ 2)]

/-- **Product (headroom) bound.** For any tie profiles `L`, `M` on the same `n ≥ 2`
observations and any pairing, `ρ² ≤ tieFactor L · tieFactor M` — exactly, with no
`O(1/n²)` remainder. -/
theorem rhoUncorr_sq_le_tieFactor_mul (L M : List ℕ) (h : M.sum = L.sum) (hn : 2 ≤ L.sum)
    (σ : Equiv.Perm (Fin L.sum)) :
    rhoUncorr L M σ ^ 2 ≤ tieFactor L * tieFactor M := by
  have hD : (0 : ℝ) < ((L.sum : ℝ) ^ 3 - L.sum) / 12 := by have := cube_sub_pos hn; positivity
  have hL := rankSS_eq_tieFactor L hn
  have hM := rankSS_eq_tieFactor M (h ▸ hn)
  rw [h] at hM
  have hcs := rankCov_sq_le L M h σ
  rw [hL, hM] at hcs
  unfold rhoUncorr
  rw [div_pow, div_le_iff₀ (by positivity)]
  nlinarith

/-- Equality case: identical aligned profiles attain the product bound. -/
theorem rhoUncorr_self_aligned (L : List ℕ) (hn : 2 ≤ L.sum) :
    rhoUncorr L L 1 = tieFactor L ∧ rhoUncorr L L 1 ^ 2 = tieFactor L * tieFactor L := by
  have hD : (0 : ℝ) < ((L.sum : ℝ) ^ 3 - L.sum) / 12 := by have := cube_sub_pos hn; positivity
  have hc : rankCov L L 1 = rankSS L := by
    rw [rankCov, rankSS_fin L L rfl]
    exact Finset.sum_congr rfl (fun i _ => by simp [sq])
  have : rhoUncorr L L 1 = tieFactor L := by
    rw [rhoUncorr, hc, rankSS_eq_tieFactor L hn, mul_div_cancel_left₀ _ hD.ne']
  exact ⟨this, by rw [this, sq]⟩

/-- Relation between the corrected and uncorrected coefficients:
`ρ_corr = ρ_uncorr / √(tieFactor L · tieFactor M)`. -/
theorem rhoCorr_eq (L M : List ℕ) (h : M.sum = L.sum) (hn : 2 ≤ L.sum)
    (σ : Equiv.Perm (Fin L.sum)) :
    rhoCorr L M σ = rhoUncorr L M σ / Real.sqrt (tieFactor L * tieFactor M) := by
  have hD : (0 : ℝ) < ((L.sum : ℝ) ^ 3 - L.sum) / 12 := by have := cube_sub_pos hn; positivity
  have hM := rankSS_eq_tieFactor M (h ▸ hn)
  rw [h] at hM
  rw [rhoCorr, rhoUncorr, rankSS_eq_tieFactor L hn, hM]
  have : ((L.sum : ℝ) ^ 3 - L.sum) / 12 * tieFactor L * (((L.sum : ℝ) ^ 3 - L.sum) / 12 * tieFactor M)
      = (((L.sum : ℝ) ^ 3 - L.sum) / 12) ^ 2 * (tieFactor L * tieFactor M) := by ring
  rw [this, Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq hD.le, div_div]

/-- The tie-corrected coefficient never exceeds 1 in absolute value. -/
theorem rhoCorr_sq_le_one (L M : List ℕ) (h : M.sum = L.sum) (σ : Equiv.Perm (Fin L.sum)) :
    rhoCorr L M σ ^ 2 ≤ 1 := by
  have h0L : 0 ≤ rankSS L := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have h0M : 0 ≤ rankSS M := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hcs := rankCov_sq_le L M h σ
  rw [rhoCorr, div_pow, Real.sq_sqrt (mul_nonneg h0L h0M)]
  rcases (mul_nonneg h0L h0M).eq_or_lt with h0 | h0
  · rw [← h0, div_zero]; exact zero_le_one
  · rw [div_le_one h0]; exact hcs

/-! ## Flattening the dial: the tie factor equals 1 exactly for tie-free profiles -/

lemma natCube_sub_eq_zero_iff (l : ℕ) : (l : ℝ) ^ 3 - l = 0 ↔ l ≤ 1 := by
  constructor
  · intro h
    by_contra hl
    push_neg at hl
    have : (2 : ℝ) ≤ l := by exact_mod_cast hl
    have e : (l : ℝ) ^ 3 - l = l * ((l : ℝ) ^ 2 - 1) := by ring
    have : (0 : ℝ) < l * ((l : ℝ) ^ 2 - 1) := mul_pos (by linarith) (by nlinarith)
    linarith
  · intro hl
    interval_cases l <;> norm_num

theorem tieFactor_eq_one_iff (L : List ℕ) (hn : 2 ≤ L.sum) :
    tieFactor L = 1 ↔ ∀ l ∈ L, l ≤ 1 := by
  have hpos := cube_sub_pos hn
  have hmass : tieFactor L = 1 ↔ tieMass L = 0 := by
    unfold tieFactor
    constructor
    · intro h1
      have : tieMass L / ((L.sum : ℝ) ^ 3 - L.sum) = 0 := by linarith
      rcases div_eq_zero_iff.mp this with h | h
      · exact h
      · exact absurd h hpos.ne'
    · intro h0; rw [h0]; simp
  rw [hmass]
  clear hmass hpos hn
  induction L with
  | nil => simp [tieMass]
  | cons l L ih =>
    have ht : tieMass (l :: L) = ((l : ℝ) ^ 3 - l) + tieMass L := by simp [tieMass]
    rw [ht, add_eq_zero_iff_of_nonneg (natCube_sub_nonneg l) (tieMass_nonneg L),
      natCube_sub_eq_zero_iff, ih.trans Iff.rfl]
    simp


/-! ## Aligned pairings maximise rho (rearrangement inequality) -/

lemma profileRank_nonneg (L : List ℕ) (i : ℕ) : 0 ≤ profileRank L i := by
  induction L generalizing i with
  | nil => simp [profileRank]
  | cons l L ih =>
    unfold profileRank
    split_ifs
    · positivity
    · have := ih (i - l); positivity

lemma profileRank_mono (L : List ℕ) {i j : ℕ} (hij : i ≤ j) (hj : j < L.sum) :
    profileRank L i ≤ profileRank L j := by
  induction L generalizing i j with
  | nil => simp at hj
  | cons l L ih =>
    simp only [List.sum_cons] at hj
    unfold profileRank
    by_cases hjl : j < l
    · rw [if_pos (lt_of_le_of_lt hij hjl), if_pos hjl]
    · rw [if_neg hjl]
      by_cases hil : i < l
      · rw [if_pos hil]
        have h1 : (1 : ℝ) ≤ l := by exact_mod_cast (show 1 ≤ l by omega)
        have := profileRank_nonneg L (j - l)
        linarith
      · rw [if_neg hil]
        have := ih (i := i - l) (j := j - l) (by omega) (by omega)
        linarith

/-- **Aligned pairing is optimal.** Among all pairings, the one that sorts both profiles
in the same direction maximises the rank covariance. -/
theorem rankCov_le_aligned (L M : List ℕ) (h : M.sum = L.sum) (σ : Equiv.Perm (Fin L.sum)) :
    rankCov L M σ ≤ rankCov L M 1 := by
  have hf : Monotone (fun i : Fin L.sum => profileRank L i - ((L.sum : ℝ) + 1) / 2) :=
    fun i j hij => by
      have := profileRank_mono L (i := i) (j := j) hij j.2
      simpa using this
  have hg : Monotone (fun i : Fin L.sum => profileRank M i - ((L.sum : ℝ) + 1) / 2) :=
    fun i j hij => by
      have := profileRank_mono M (i := i) (j := j) hij (by rw [h]; exact j.2)
      simpa using this
  have := (hf.monovary hg).sum_mul_comp_perm_le_sum_mul (σ := σ)
  simpa [rankCov] using this

theorem rhoUncorr_le_aligned (L M : List ℕ) (h : M.sum = L.sum) (hn : 2 ≤ L.sum)
    (σ : Equiv.Perm (Fin L.sum)) : rhoUncorr L M σ ≤ rhoUncorr L M 1 := by
  have hD : (0 : ℝ) < ((L.sum : ℝ) ^ 3 - L.sum) / 12 := by have := cube_sub_pos hn; positivity
  exact div_le_div_of_nonneg_right (rankCov_le_aligned L M h σ) hD.le

/-- The maximal attainable rho is the aligned value: it is a function of the
*joint* (aligned) profile, not of the two marginal tie factors separately. -/
theorem maxRho_eq_aligned (L M : List ℕ) (h : M.sum = L.sum) (hn : 2 ≤ L.sum) :
    maxRho L M = rhoUncorr L M 1 :=
  le_antisymm (ciSup_le (rhoUncorr_le_aligned L M h hn))
    (le_ciSup (Set.finite_range _).bddAbove 1)

/-! ## The flattened (tie-free) dial: the ceiling is `tieFactor M`, not `√tieFactor M` -/

lemma profileRank_untied (n i : ℕ) (hi : i < n) :
    profileRank (List.replicate n 1) i = (i : ℝ) + 1 := by
  induction n generalizing i with
  | zero => omega
  | succ n ih =>
    rw [List.replicate_succ]
    rcases i with _ | i
    · simp [profileRank]
    · rw [show i + 1 = 1 + i by omega, profileRank_cons_add, ih i (by omega)]
      push_cast; ring

lemma sum_untied (n : ℕ) : (List.replicate n 1).sum = n := by simp

lemma tieMass_untied (n : ℕ) : tieMass (List.replicate n 1) = 0 := by
  simp [tieMass]

theorem tieFactor_untied (n : ℕ) : tieFactor (List.replicate n 1) = 1 := by
  simp [tieFactor, tieMass_untied]

lemma sum_succ_cast (n : ℕ) : ∑ x ∈ range n, ((x : ℝ) + 1) = (n : ℝ) * (n + 1) / 2 := by
  induction n with
  | zero => simp
  | succ m ihm => rw [Finset.sum_range_succ, ihm]; push_cast; ring

lemma rankCov_one_range (L M : List ℕ) : rankCov L M 1 = ∑ i ∈ range L.sum,
    (profileRank L i - ((L.sum : ℝ) + 1) / 2) * (profileRank M i - ((L.sum : ℝ) + 1) / 2) := by
  rw [rankCov, Finset.sum_range]; simp

/-- Block-averaging identity: `Σ (i+1)·Rᵢ = Σ Rᵢ²` for the midrank vector of any profile. -/
lemma sum_succ_mul_profileRank (M : List ℕ) :
    ∑ i ∈ range M.sum, ((i : ℝ) + 1) * profileRank M i =
      ∑ i ∈ range M.sum, profileRank M i ^ 2 := by
  induction M with
  | nil => simp
  | cons l L ih =>
    have hs := sum_profileRank L
    rw [List.sum_cons, Finset.sum_range_add, Finset.sum_range_add]
    have h1 : ∑ x ∈ range l, ((x : ℝ) + 1) * profileRank (l :: L) x =
        ∑ x ∈ range l, ((x : ℝ) + 1) * (((l : ℝ) + 1) / 2) :=
      Finset.sum_congr rfl (fun x hx => by rw [profileRank_cons_lt l L (Finset.mem_range.mp hx)])
    have h1' : ∑ x ∈ range l, profileRank (l :: L) x ^ 2 = ∑ x ∈ range l, (((l : ℝ) + 1) / 2) ^ 2 :=
      Finset.sum_congr rfl (fun x hx => by rw [profileRank_cons_lt l L (Finset.mem_range.mp hx)])
    have h2 : ∑ x ∈ range L.sum, (((l + x : ℕ) : ℝ) + 1) * profileRank (l :: L) (l + x) =
        ∑ x ∈ range L.sum, ((l : ℝ) * l + ((l : ℝ) * profileRank L x +
          (l : ℝ) * ((x : ℝ) + 1)) + ((x : ℝ) + 1) * profileRank L x) :=
      Finset.sum_congr rfl (fun x _ => by rw [profileRank_cons_add l L x]; push_cast; ring)
    have h2' : ∑ x ∈ range L.sum, profileRank (l :: L) (l + x) ^ 2 =
        ∑ x ∈ range L.sum, ((l : ℝ) ^ 2 + 2 * l * profileRank L x + profileRank L x ^ 2) :=
      Finset.sum_congr rfl (fun x _ => by rw [profileRank_cons_add l L x]; ring)
    rw [h1, h1', h2, h2', ← Finset.sum_mul, sum_succ_cast l]
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum, ih, hs, sum_succ_cast L.sum]
    simp; ring

/-- With a tie-free dial, the aligned rank covariance equals the response's own
centered sum of squares. -/
theorem rankCov_untied_aligned (M : List ℕ) :
    rankCov (List.replicate M.sum 1) M 1 = rankSS M := by
  have hs := sum_profileRank M
  have hx := sum_succ_mul_profileRank M
  rw [rankCov_one_range, sum_untied,
    Finset.sum_congr rfl (fun i hi => by
      rw [profileRank_untied M.sum i (Finset.mem_range.mp hi)])]
  rw [rankSS]
  have e1 : ∀ i : ℕ, ((i : ℝ) + 1 - ((M.sum : ℝ) + 1) / 2) * (profileRank M i - ((M.sum : ℝ) + 1) / 2)
      = ((i : ℝ) + 1) * profileRank M i - ((M.sum : ℝ) + 1) / 2 * profileRank M i
        - ((M.sum : ℝ) + 1) / 2 * ((i : ℝ) + 1) + (((M.sum : ℝ) + 1) / 2) ^ 2 := fun i => by ring
  have e2 : ∀ i : ℕ, (profileRank M i - ((M.sum : ℝ) + 1) / 2) ^ 2
      = profileRank M i ^ 2 - 2 * (((M.sum : ℝ) + 1) / 2) * profileRank M i
        + (((M.sum : ℝ) + 1) / 2) ^ 2 := fun i => by ring
  simp only [e1, e2, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, hx, hs]
  have hsx : ∑ x ∈ range M.sum, (x : ℝ) + ∑ x ∈ range M.sum, (1 : ℝ) =
      (M.sum : ℝ) * (M.sum + 1) / 2 := by
    rw [← Finset.sum_add_distrib]; exact sum_succ_cast _
  rw [hsx]
  ring

/-- **Flattened-dial ceiling.** With a tie-free predictor, the maximal attainable
(untied-normalised) rho is exactly `tieFactor M`. -/
theorem maxRho_untied (M : List ℕ) (hn : 2 ≤ M.sum) :
    maxRho (List.replicate M.sum 1) M = tieFactor M := by
  have hs : (List.replicate M.sum 1).sum = M.sum := sum_untied _
  have hn' : 2 ≤ (List.replicate M.sum 1).sum := by rw [hs]; exact hn
  rw [maxRho_eq_aligned _ M hs.symm hn', rhoUncorr, rankCov_untied_aligned,
    rankSS_eq_tieFactor M hn, hs]
  have hD : (0 : ℝ) < ((M.sum : ℝ) ^ 3 - M.sum) / 12 := by have := cube_sub_pos hn; positivity
  exact mul_div_cancel_left₀ _ hD.ne'

/-- **Refutation of "equality for aligned profiles".** With a tie-free dial and a tied
response (`0 < tieFactor M < 1`), the product bound `ρ² ≤ tieFactor L · tieFactor M`
is *never* attained: the best achievable `ρ²` is `tieFactor M ²`, strictly smaller. -/
theorem untied_product_bound_strict (M : List ℕ) (hn : 2 ≤ M.sum)
    (h0 : 0 < tieFactor M) (h1 : tieFactor M < 1) :
    maxRho (List.replicate M.sum 1) M ^ 2 <
      tieFactor (List.replicate M.sum 1) * tieFactor M := by
  rw [maxRho_untied M hn, tieFactor_untied, one_mul]
  nlinarith

/-- Tie-corrected ceiling with a flat dial: the best corrected rho is `√(tieFactor M)`. -/
theorem rhoCorr_untied_aligned (M : List ℕ) (hn : 2 ≤ M.sum) (h0 : 0 < tieFactor M) :
    rhoCorr (List.replicate M.sum 1) M 1 = Real.sqrt (tieFactor M) := by
  have hs : (List.replicate M.sum 1).sum = M.sum := sum_untied _
  have hn' : 2 ≤ (List.replicate M.sum 1).sum := by rw [hs]; exact hn
  have hmax := maxRho_untied M hn
  rw [maxRho_eq_aligned _ M hs.symm hn'] at hmax
  rw [rhoCorr_eq _ M hs.symm hn', hmax, tieFactor_untied, one_mul]
  have := Real.sq_sqrt h0.le
  have hp : 0 < Real.sqrt (tieFactor M) := Real.sqrt_pos.mpr h0
  field_simp
  linarith

/-! ## Non-factorisation: the ceiling is not a function of the two tie factors -/

/-- Two pairs of profiles with *identical* marginal tie factors (`9/10, 9/10`) whose maximal
attainable rho differ (`9/10` vs `4/5`). Hence no function `F` satisfies
`maxRho L M = F (tieFactor L) (tieFactor M)`; in particular the multiplicative headroom
conjecture fails. -/
theorem maxRho_not_function_of_tieFactors :
    ¬ ∃ F : ℝ → ℝ → ℝ, ∀ L M : List ℕ, M.sum = L.sum → 2 ≤ L.sum →
      maxRho L M = F (tieFactor L) (tieFactor M) := by
  rintro ⟨F, hF⟩
  have hA := hF [1, 1, 2] [1, 1, 2] rfl (by decide)
  have hB := hF [1, 1, 2] [2, 1, 1] rfl (by decide)
  have t1 : tieFactor [1, 1, 2] = 9 / 10 := by norm_num [tieFactor, tieMass]
  have t2 : tieFactor [2, 1, 1] = 9 / 10 := by norm_num [tieFactor, tieMass]
  rw [maxRho_eq_aligned [1, 1, 2] [1, 1, 2] rfl (by decide)] at hA
  rw [maxRho_eq_aligned [1, 1, 2] [2, 1, 1] rfl (by decide)] at hB
  rw [t1] at hA hB
  rw [t2] at hB
  have cA : rhoUncorr [1, 1, 2] [1, 1, 2] 1 = 9 / 10 := by
    rw [(rhoUncorr_self_aligned [1, 1, 2] (by decide)).1, t1]
  have cB : rhoUncorr [1, 1, 2] [2, 1, 1] 1 = 4 / 5 := by
    simp [rhoUncorr, rankCov, Fin.sum_univ_four, profileRank]
    norm_num
  rw [cA] at hA
  rw [cB] at hB
  linarith


/-! ## Joint-profile law for nested (coarsened) profiles

A grouping `G : List (List ℕ)` describes a fine profile `G.flatten` together with the coarse
profile `G.map List.sum` obtained by merging each group of consecutive blocks. -/

lemma profileRank_append_lt (g L : List ℕ) {i : ℕ} (hi : i < g.sum) :
    profileRank (g ++ L) i = profileRank g i := by
  induction g generalizing i with
  | nil => simp at hi
  | cons l g ih =>
    simp only [List.sum_cons] at hi
    simp only [List.cons_append, profileRank]
    split_ifs with h
    · rfl
    · rw [ih (by omega)]

lemma profileRank_append_add (g L : List ℕ) (x : ℕ) :
    profileRank (g ++ L) (g.sum + x) = (g.sum : ℝ) + profileRank L x := by
  induction g with
  | nil => simp
  | cons l g ih =>
    rw [List.cons_append, List.sum_cons, Nat.add_assoc, profileRank_cons_add, ih]
    push_cast; ring

/-- Block-averaging identity for a coarsening: `Σ R^fine_i · R^coarse_i = Σ (R^coarse_i)²`. -/
lemma sum_mul_profileRank_coarsen (G : List (List ℕ)) :
    ∑ i ∈ range (G.map List.sum).sum, profileRank G.flatten i * profileRank (G.map List.sum) i =
      ∑ i ∈ range (G.map List.sum).sum, profileRank (G.map List.sum) i ^ 2 := by
  induction G with
  | nil => simp
  | cons g G ih =>
    have hsF := sum_profileRank G.flatten
    have hsM := sum_profileRank (G.map List.sum)
    have heq : G.flatten.sum = (G.map List.sum).sum := List.sum_flatten
    rw [heq] at hsF
    have hg := sum_profileRank g
    simp only [List.map_cons, List.flatten_cons, List.sum_cons]
    rw [Finset.sum_range_add, Finset.sum_range_add]
    have h1 : ∑ x ∈ range g.sum, profileRank (g ++ G.flatten) x *
        profileRank (g.sum :: G.map List.sum) x =
        ∑ x ∈ range g.sum, profileRank g x * (((g.sum : ℝ) + 1) / 2) :=
      Finset.sum_congr rfl (fun x hx => by
        rw [profileRank_append_lt g _ (Finset.mem_range.mp hx),
          profileRank_cons_lt _ _ (Finset.mem_range.mp hx)])
    have h1' : ∑ x ∈ range g.sum, profileRank (g.sum :: G.map List.sum) x ^ 2 =
        ∑ x ∈ range g.sum, (((g.sum : ℝ) + 1) / 2) ^ 2 :=
      Finset.sum_congr rfl (fun x hx => by
        rw [profileRank_cons_lt _ _ (Finset.mem_range.mp hx)])
    have h2 : ∑ x ∈ range (G.map List.sum).sum, profileRank (g ++ G.flatten) (g.sum + x) *
        profileRank (g.sum :: G.map List.sum) (g.sum + x) =
        ∑ x ∈ range (G.map List.sum).sum, ((g.sum : ℝ) * g.sum +
          ((g.sum : ℝ) * profileRank (G.map List.sum) x + (g.sum : ℝ) * profileRank G.flatten x) +
          profileRank G.flatten x * profileRank (G.map List.sum) x) :=
      Finset.sum_congr rfl (fun x _ => by
        rw [profileRank_append_add, profileRank_cons_add]; ring)
    have h2' : ∑ x ∈ range (G.map List.sum).sum, profileRank (g.sum :: G.map List.sum) (g.sum + x) ^ 2 =
        ∑ x ∈ range (G.map List.sum).sum, ((g.sum : ℝ) * g.sum +
          ((g.sum : ℝ) * profileRank (G.map List.sum) x + (g.sum : ℝ) * profileRank (G.map List.sum) x) +
          profileRank (G.map List.sum) x ^ 2) :=
      Finset.sum_congr rfl (fun x _ => by rw [profileRank_cons_add]; ring)
    rw [h1, h1', h2, h2', ← Finset.sum_mul, hg]
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum, ih, hsF, hsM]
    simp; ring

lemma rankCov_eq_rankSS_of_cross {L M : List ℕ} (h : M.sum = L.sum)
    (hx : ∑ i ∈ range L.sum, profileRank L i * profileRank M i =
      ∑ i ∈ range L.sum, profileRank M i ^ 2) :
    rankCov L M 1 = rankSS M := by
  have hsL := sum_profileRank L
  have hsM := sum_profileRank M
  rw [h] at hsM
  rw [rankCov_one_range, rankSS, h]
  have e1 : ∀ i : ℕ, (profileRank L i - ((L.sum : ℝ) + 1) / 2) *
      (profileRank M i - ((L.sum : ℝ) + 1) / 2)
      = profileRank L i * profileRank M i - ((L.sum : ℝ) + 1) / 2 * profileRank M i
        - ((L.sum : ℝ) + 1) / 2 * profileRank L i + (((L.sum : ℝ) + 1) / 2) ^ 2 := fun i => by ring
  have e2 : ∀ i : ℕ, (profileRank M i - ((L.sum : ℝ) + 1) / 2) ^ 2
      = profileRank M i ^ 2 - 2 * (((L.sum : ℝ) + 1) / 2) * profileRank M i
        + (((L.sum : ℝ) + 1) / 2) ^ 2 := fun i => by ring
  simp only [e1, e2, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, hx,
    hsL, hsM]
  ring

/-- **Joint-profile law (uncorrected).** If `M` coarsens `L`, the aligned rank covariance
equals the coarse profile's own sum of squares, so the ceiling is `tieFactor M`. -/
theorem maxRho_coarsen (G : List (List ℕ)) (hn : 2 ≤ G.flatten.sum) :
    maxRho G.flatten (G.map List.sum) = tieFactor (G.map List.sum) := by
  have heq : (G.map List.sum).sum = G.flatten.sum := List.sum_flatten.symm
  have hc : rankCov G.flatten (G.map List.sum) 1 = rankSS (G.map List.sum) := by
    apply rankCov_eq_rankSS_of_cross heq
    rw [← heq]; exact sum_mul_profileRank_coarsen G
  rw [maxRho_eq_aligned _ _ heq hn, rhoUncorr, hc, rankSS_eq_tieFactor _ (heq ▸ hn), heq]
  have hD : (0 : ℝ) < ((G.flatten.sum : ℝ) ^ 3 - G.flatten.sum) / 12 := by
    have := cube_sub_pos hn; positivity
  exact mul_div_cancel_left₀ _ hD.ne'

/-- **Joint-profile law (tie-corrected).** For nested profiles the best corrected rho is
`√(tieFactor coarse / tieFactor fine)` — a *ratio*, not a product, of attenuation factors. -/
theorem rhoCorr_coarsen_aligned (G : List (List ℕ)) (hn : 2 ≤ G.flatten.sum)
    (h0 : 0 < tieFactor (G.map List.sum)) :
    rhoCorr G.flatten (G.map List.sum) 1 =
      Real.sqrt (tieFactor (G.map List.sum) / tieFactor G.flatten) := by
  have heq : (G.map List.sum).sum = G.flatten.sum := List.sum_flatten.symm
  have hmax := maxRho_coarsen G hn
  rw [maxRho_eq_aligned _ _ heq hn] at hmax
  have hfL : 0 < tieFactor G.flatten := by
    have hsq := rhoUncorr_sq_le_tieFactor_mul _ _ heq hn 1
    rw [hmax] at hsq
    have hle := tieFactor_nonneg G.flatten hn
    rcases hle.eq_or_lt with h | h
    · rw [← h, zero_mul] at hsq; nlinarith
    · exact h
  rw [rhoCorr_eq _ _ heq hn, hmax, Real.sqrt_mul hfL.le, Real.sqrt_div' _ hfL.le]
  have hpL : 0 < Real.sqrt (tieFactor G.flatten) := Real.sqrt_pos.mpr hfL
  have hpM : 0 < Real.sqrt (tieFactor (G.map List.sum)) := Real.sqrt_pos.mpr h0
  have := Real.sq_sqrt h0.le
  field_simp
  linarith

end Catalog.Logic.TieHeadroom