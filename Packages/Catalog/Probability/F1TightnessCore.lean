import Mathlib

/-!
# F1 tightness: the slack factor of the master speed-up inequality (paper 250)

This file formalises the *shape layer* of the round-92 "F1-TIGHTNESS-CONNECTION"
deliverable.  The empirical situation is the following.  A scan visits the `M`
cells of a window one after another; the target sits in cell `i` with prior
probability `p i` (the measured **positional profile**, front-loaded, harmonic).
A *policy* is a permutation `σ` of the cells: it probes cell `i` at rank
`σ i + 1`, so its expected probe count is `polCost p σ = ∑ i, (σ i + 1) * p i`.

Three costs organise everything:

* `scanCost p` — the cost of the **ascending** (identity) policy;
* `revCost p`  — the cost of the **descending** (reversed) policy;
* `baseCost M = (M+1)/2` — the cost under a flat profile / random order.

The F1 master inequality of paper 225 reads `S ≤ 1/(Λ·Θ·q̂)`.  On this pool the
parameters are the *cost ratios*

  `Lam p = scanCost / revCost`,   `Theta p = scanCost / baseCost`,   `q̂ = 1`,

and the realizable ascending speed-up is `Sasc p = revCost / scanCost = 1/Λ`.

Main results.

* `scanCost_add_revCost_eq` — the **conservation identity** `c_asc + c_desc = M+1
  = 2·C₀`.  Everything below follows from this single identity: the whole
  parameter map is a one-parameter family.
* `gapX_eq_gapOfLam`, `Theta_eq_of_Lam` — `X = (1+Λ)/(2Λ)` and `Θ = 2Λ/(1+Λ)`
  exactly (no continuum approximation), so `X = 1/Θ`.
* `slack_identity` — `bound = X · S_asc`: the gap between the proven bound and
  the realizable ascending speed-up is exactly the factor `X`, *policy- and
  baseline-independent*.
* `policy_speedup_le_Sasc` — rearrangement: on an antitone (front-loaded)
  profile no policy beats the ascending scan, so `S_asc` is the best realizable
  speed-up.
* `scanCost_lt_baseCost` / `one_lt_gapX` — **strict slack from non-flatness**:
  an antitone profile that is not flat has `X > 1` strictly (a strict Chebyshev
  inequality, proved here from a pairwise identity).
* `no_policy_attains_bound`, `speedup_lt_bound` — consequently *no* realizable
  policy attains the master bound; every policy's speed-up is at most
  `bound / X < bound`.
* `gapX_eq_one_iff`, `gapX_flat` — equality `X = 1` happens exactly when the
  ascending cost equals the flat baseline, in particular for the flat profile;
  this is the equality case that the three independent tests (KS, LRT,
  conditional-logistic LRT) refute on the measured pool.
* `qhat_nonidentifiable`, `anchor_inversion_tautology` — the
  **tightness-circularity catch**: with `q̂` free, *any* observed speed-up can be
  turned into an exact equality, so an anchor whose parameters were obtained by
  inverting the law carries zero evidential weight for attainment.
* Numerical corollaries (`measured_gapX_approx`, `gapX_mem_interval`,
  `measured_bound_approx`, `predicted_speedup_lt_bound`) reproduce the booked
  numbers `Λ = 0.765671`, `Θ ≈ 0.867`, `X ≈ 1.15302 ∈ [1.10, 1.23]`,
  `S ≈ 1.306`, `bound ≈ 1.506`.
-/

open Finset

namespace F1Tightness

/-! ## A pairwise identity and a strict Chebyshev inequality -/

variable {ι : Type*}

/-- The pairwise expansion behind Chebyshev's sum inequality. -/
theorem sum_pairs_identity (s : Finset ι) (a b : ι → ℝ) :
    ∑ i ∈ s, ∑ j ∈ s, (a i - a j) * (b i - b j)
      = 2 * ((s.card : ℝ) * (∑ i ∈ s, a i * b i)
              - (∑ i ∈ s, a i) * (∑ i ∈ s, b i)) := by
  have h : ∀ i j : ι, (a i - a j) * (b i - b j)
      = a i * b i - a i * b j - a j * b i + a j * b j := by
    intro i j; ring
  simp only [h, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
    nsmul_eq_mul, ← Finset.mul_sum, ← Finset.sum_mul]
  ring

/-- Chebyshev's sum inequality with a strict conclusion: if all pairwise
products are nonpositive and at least one is strictly negative, then
`#s · ∑ a·b < (∑ a)(∑ b)`. -/
theorem card_mul_sum_lt_sum_mul_sum (s : Finset ι) (a b : ι → ℝ)
    (h : ∀ i ∈ s, ∀ j ∈ s, (a i - a j) * (b i - b j) ≤ 0)
    {i₀ j₀ : ι} (hi₀ : i₀ ∈ s) (hj₀ : j₀ ∈ s)
    (hlt : (a i₀ - a j₀) * (b i₀ - b j₀) < 0) :
    (s.card : ℝ) * (∑ i ∈ s, a i * b i) < (∑ i ∈ s, a i) * (∑ i ∈ s, b i) := by
  have hprod : ∑ x ∈ s ×ˢ s, (a x.1 - a x.2) * (b x.1 - b x.2) < 0 := by
    have hzero : ∑ _x ∈ s ×ˢ s, (0 : ℝ) = 0 := by simp
    rw [← hzero]
    refine Finset.sum_lt_sum ?_ ⟨(i₀, j₀), Finset.mem_product.2 ⟨hi₀, hj₀⟩, hlt⟩
    intro x hx
    exact h x.1 (Finset.mem_product.1 hx).1 x.2 (Finset.mem_product.1 hx).2
  rw [Finset.sum_product, sum_pairs_identity] at hprod
  linarith

/-! ## Costs of a scan policy -/

variable {M : ℕ}

/-- Expected probe count of the **ascending** (identity) policy: cell `i` is
probed at rank `i+1`. -/
noncomputable def scanCost (p : Fin M → ℝ) : ℝ := ∑ i : Fin M, (((i : ℕ) : ℝ) + 1) * p i

/-- Expected probe count of the **descending** (reversed) policy: cell `i` is
probed at rank `M - i`. -/
noncomputable def revCost (p : Fin M → ℝ) : ℝ := ∑ i : Fin M, ((M : ℝ) - ((i : ℕ) : ℝ)) * p i

/-- Baseline cost `C₀ = (M+1)/2`: the expected probe count of any policy under a
flat profile (equivalently, of a random order under any profile). -/
noncomputable def baseCost (M : ℕ) : ℝ := ((M : ℝ) + 1) / 2

/-- Expected probe count of the policy `σ`, which probes cell `i` at rank
`σ i + 1`. -/
noncomputable def polCost (p : Fin M → ℝ) (σ : Equiv.Perm (Fin M)) : ℝ :=
  ∑ i : Fin M, (((σ i : ℕ) : ℝ) + 1) * p i

/-- The F1 shape parameter `Λ`: ratio of the ascending to the descending cost.
`1/Λ` is the ascending-over-descending gain. -/
noncomputable def Lam (p : Fin M → ℝ) : ℝ := scanCost p / revCost p

/-- The F1 alignment parameter `Θ`: the ascending cost normalised by the flat
baseline. -/
noncomputable def Theta (p : Fin M → ℝ) : ℝ := scanCost p / baseCost M

/-- The gap (slack) factor `X = C₀ / c_asc`. -/
noncomputable def gapX (p : Fin M → ℝ) : ℝ := baseCost M / scanCost p

/-- Realizable speed-up of the policy `σ`, measured against the anti-aligned
(descending) policy. -/
noncomputable def speedup (p : Fin M → ℝ) (σ : Equiv.Perm (Fin M)) : ℝ :=
  revCost p / polCost p σ

/-- The realizable ascending speed-up `S_asc = 1/Λ`. -/
noncomputable def Sasc (p : Fin M → ℝ) : ℝ := revCost p / scanCost p

/-- The right-hand side of the paper-225 master inequality,
`bound = 1/(Λ·Θ·q̂)` (arm 1, `k_bits = 0`). -/
noncomputable def boundF1 (lam th q : ℝ) : ℝ := 1 / (lam * th * q)

/-- `X` as a function of `Λ` alone. -/
noncomputable def gapOfLam (lam : ℝ) : ℝ := (1 + lam) / (2 * lam)

/-! ## The conservation identity and positivity -/

/-- **Conservation identity.** The ascending and descending costs add up to
`M+1` times the total mass. -/
theorem scanCost_add_revCost (p : Fin M → ℝ) :
    scanCost p + revCost p = ((M : ℝ) + 1) * ∑ i : Fin M, p i := by
  simp only [scanCost, revCost, Finset.mul_sum, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- Conservation identity for a probability profile: `c_asc + c_desc = 2·C₀`. -/
theorem scanCost_add_revCost_eq {p : Fin M → ℝ} (hsum : ∑ i : Fin M, p i = 1) :
    scanCost p + revCost p = 2 * baseCost M := by
  rw [scanCost_add_revCost, hsum, baseCost]; ring

theorem one_le_scanCost {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : 1 ≤ scanCost p := by
  have h : ∑ i : Fin M, p i ≤ scanCost p := by
    refine Finset.sum_le_sum fun i _ => ?_
    have h1 : (1 : ℝ) ≤ ((i : ℕ) : ℝ) + 1 := by
      have := Nat.cast_nonneg (α := ℝ) (i : ℕ)
      linarith
    nlinarith [hp i]
  rwa [hsum] at h

theorem one_le_revCost {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : 1 ≤ revCost p := by
  have h : ∑ i : Fin M, p i ≤ revCost p := by
    refine Finset.sum_le_sum fun i _ => ?_
    have hlt : (i : ℕ) + 1 ≤ M := i.isLt
    have h1 : (1 : ℝ) ≤ (M : ℝ) - ((i : ℕ) : ℝ) := by
      have : ((i : ℕ) : ℝ) + 1 ≤ (M : ℝ) := by exact_mod_cast hlt
      linarith
    nlinarith [hp i]
  rwa [hsum] at h

theorem scanCost_pos {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : 0 < scanCost p :=
  lt_of_lt_of_le one_pos (one_le_scanCost hp hsum)

theorem revCost_pos {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : 0 < revCost p :=
  lt_of_lt_of_le one_pos (one_le_revCost hp hsum)

theorem baseCost_pos (M : ℕ) : 0 < baseCost M := by
  unfold baseCost; positivity

theorem Lam_pos {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i : Fin M, p i = 1) :
    0 < Lam p := div_pos (scanCost_pos hp hsum) (revCost_pos hp hsum)

theorem Theta_pos {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i : Fin M, p i = 1) :
    0 < Theta p := div_pos (scanCost_pos hp hsum) (baseCost_pos M)

theorem gapX_pos {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i : Fin M, p i = 1) :
    0 < gapX p := div_pos (baseCost_pos M) (scanCost_pos hp hsum)

/-! ## The identity chain -/

/-- `X = 1/Θ`: the slack factor is the reciprocal of the alignment parameter. -/
theorem gapX_eq_inv_Theta (p : Fin M → ℝ) : gapX p = (Theta p)⁻¹ := by
  unfold gapX Theta; rw [inv_div]

/-- **`X` from `Λ` alone**: `X = (1+Λ)/(2Λ)`, exactly (a consequence of the
conservation identity, with no continuum approximation). -/
theorem gapX_eq_gapOfLam {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : gapX p = gapOfLam (Lam p) := by
  have hc := (scanCost_pos hp hsum).ne'
  have hr := (revCost_pos hp hsum).ne'
  have hb : baseCost M = (scanCost p + revCost p) / 2 := by
    have := scanCost_add_revCost_eq (M := M) hsum; linarith
  unfold gapX gapOfLam Lam
  rw [hb]
  field_simp
  ring

/-- **`Θ` from `Λ` alone**: `Θ = 2Λ/(1+Λ)`. -/
theorem Theta_eq_of_Lam {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : Theta p = 2 * Lam p / (1 + Lam p) := by
  have hc := (scanCost_pos hp hsum).ne'
  have hr := (revCost_pos hp hsum).ne'
  have hb : baseCost M = (scanCost p + revCost p) / 2 := by
    have := scanCost_add_revCost_eq (M := M) hsum; linarith
  have hcr : scanCost p + revCost p ≠ 0 := by
    have := scanCost_pos hp hsum; have := revCost_pos hp hsum; positivity
  unfold Theta Lam
  rw [hb]
  field_simp
  rw [add_comm (revCost p) (scanCost p), div_self hcr]

/-- `S_asc = 1/Λ`. -/
theorem Sasc_eq_inv_Lam (p : Fin M → ℝ) : Sasc p = (Lam p)⁻¹ := by
  unfold Sasc Lam; rw [inv_div]

/-- **Slack identity.** The proven bound is exactly `X` times the realizable
ascending speed-up: `bound = X · S_asc`.  Since neither side mentions the
baseline of the speed-up, the slack factor is policy- and baseline-independent. -/
theorem slack_identity {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) :
    boundF1 (Lam p) (Theta p) 1 = gapX p * Sasc p := by
  have hc := (scanCost_pos hp hsum).ne'
  have hr := (revCost_pos hp hsum).ne'
  have hb := (baseCost_pos M).ne'
  unfold boundF1 gapX Sasc Lam Theta
  field_simp

/-! ## The mean-position form of the identity chain -/

/-- Mean normalised probe position `E_x = ∑ ((i + 1/2)/M) · p i`, the coordinate
in which the measured profile is reported. -/
noncomputable def meanPos (p : Fin M → ℝ) : ℝ :=
  ∑ i : Fin M, ((((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * p i

/-- The ascending cost in terms of the mean position: `c_asc = M·E_x + 1/2`. -/
theorem scanCost_eq_meanPos {p : Fin M → ℝ} (hM : 0 < M) (hsum : ∑ i : Fin M, p i = 1) :
    scanCost p = (M : ℝ) * meanPos p + 1 / 2 := by
  have hMR : (M : ℝ) ≠ 0 := by
    have : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
    exact this.ne'
  have h : ∀ i : Fin M, (((i : ℕ) : ℝ) + 1) * p i
      = (M : ℝ) * (((((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * p i) + (1 / 2) * p i := by
    intro i
    field_simp
    ring
  rw [scanCost]
  simp_rw [h]
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hsum, meanPos]
  ring

/-- **The booked identity chain**: `X = C₀/c_asc = (M+1)/(2·M·E_x + 1)`. -/
theorem gapX_eq_meanPos {p : Fin M → ℝ} (hM : 0 < M) (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) :
    gapX p = ((M : ℝ) + 1) / (2 * (M : ℝ) * meanPos p + 1) := by
  have hc := scanCost_pos hp hsum
  have hcm := scanCost_eq_meanPos hM hsum
  have hden : 2 * (M : ℝ) * meanPos p + 1 = 2 * scanCost p := by rw [hcm]; ring
  unfold gapX baseCost
  rw [hden]
  field_simp

/-! ## Monotonicity of the gap factor in `Λ` -/

theorem gapOfLam_strictAnti {l₁ l₂ : ℝ} (h₁ : 0 < l₁) (h : l₁ < l₂) :
    gapOfLam l₂ < gapOfLam l₁ := by
  have h₂ : 0 < l₂ := h₁.trans h
  unfold gapOfLam
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith

theorem gapOfLam_eq_one_iff {l : ℝ} (hl : 0 < l) : gapOfLam l = 1 ↔ l = 1 := by
  unfold gapOfLam
  rw [div_eq_one_iff_eq (by positivity)]
  constructor <;> intro h <;> linarith

theorem one_lt_gapOfLam_iff {l : ℝ} (hl : 0 < l) : 1 < gapOfLam l ↔ l < 1 := by
  unfold gapOfLam
  rw [lt_div_iff₀ (by positivity)]
  constructor <;> intro h <;> linarith

/-! ## Rearrangement: the ascending policy is optimal on a front-loaded profile -/

/-- **Rearrangement / master optimality.** On an antitone (front-loaded) profile
no policy costs less than the ascending scan. -/
theorem scanCost_le_polCost {p : Fin M → ℝ} (hanti : Antitone p)
    (σ : Equiv.Perm (Fin M)) : scanCost p ≤ polCost p σ := by
  have hav : Antivary p (fun i : Fin M => (((i : ℕ) : ℝ) + 1)) := by
    intro i j hij
    have hlt : i < j := by
      by_contra hji
      push_neg at hji
      have : ((j : ℕ) : ℝ) ≤ ((i : ℕ) : ℝ) := by
        exact_mod_cast Fin.le_iff_val_le_val.mp hji
      simp only at hij
      linarith
    exact hanti hlt.le
  have hre := hav.sum_smul_le_sum_smul_comp_perm (σ := σ)
  simp only [smul_eq_mul] at hre
  unfold scanCost polCost
  calc ∑ i : Fin M, (((i : ℕ) : ℝ) + 1) * p i
      = ∑ i : Fin M, p i * (((i : ℕ) : ℝ) + 1) := Finset.sum_congr rfl fun i _ => by ring
    _ ≤ ∑ i : Fin M, p i * (((σ i : ℕ) : ℝ) + 1) := hre
    _ = ∑ i : Fin M, (((σ i : ℕ) : ℝ) + 1) * p i :=
        Finset.sum_congr rfl fun i _ => by ring

/-- No policy has a larger speed-up than the ascending scan. -/
theorem policy_speedup_le_Sasc {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) (σ : Equiv.Perm (Fin M)) :
    speedup p σ ≤ Sasc p := by
  have hc := scanCost_pos hp hsum
  have hle := scanCost_le_polCost hanti σ
  unfold speedup Sasc
  exact div_le_div_of_nonneg_left (le_of_lt (revCost_pos hp hsum)) hc hle

/-! ## Strict slack: an antitone non-flat profile cannot attain the bound -/

theorem sum_rank_weights (M : ℕ) :
    ∑ i : Fin M, (((i : ℕ) : ℝ) + 1) = (M : ℝ) * ((M : ℝ) + 1) / 2 := by
  induction M with
  | zero => simp
  | succ n ih =>
      rw [Fin.sum_univ_castSucc]
      simp only [Fin.val_castSucc, Fin.val_last]
      rw [ih]
      push_cast
      ring

/-- **Strict Chebyshev slack.** An antitone profile that is not flat has
ascending cost strictly below the flat baseline. -/
theorem scanCost_lt_baseCost {p : Fin M → ℝ} (hsum : ∑ i : Fin M, p i = 1)
    (hanti : Antitone p) {i₀ j₀ : Fin M} (hne : p i₀ ≠ p j₀) :
    scanCost p < baseCost M := by
  set a : Fin M → ℝ := fun i => ((i : ℕ) : ℝ) + 1 with ha
  have hmono : ∀ i j : Fin M, i ≤ j → a i ≤ a j := by
    intro i j hij
    have : ((i : ℕ) : ℝ) ≤ ((j : ℕ) : ℝ) := by
      exact_mod_cast Fin.le_iff_val_le_val.mp hij
    simp only [ha]; linarith
  have hterm : ∀ i ∈ (univ : Finset (Fin M)), ∀ j ∈ (univ : Finset (Fin M)),
      (a i - a j) * (p i - p j) ≤ 0 := by
    intro i _ j _
    rcases le_total i j with hij | hij
    · have h1 : a i - a j ≤ 0 := by linarith [hmono i j hij]
      have h2 : 0 ≤ p i - p j := by linarith [hanti hij]
      nlinarith
    · have h1 : 0 ≤ a i - a j := by linarith [hmono j i hij]
      have h2 : p i - p j ≤ 0 := by linarith [hanti hij]
      nlinarith
  have hstrict : ∃ i ∈ (univ : Finset (Fin M)), ∃ j ∈ (univ : Finset (Fin M)),
      (a i - a j) * (p i - p j) < 0 := by
    rcases lt_trichotomy i₀ j₀ with h | h | h
    · refine ⟨i₀, mem_univ _, j₀, mem_univ _, ?_⟩
      have h1 : a i₀ < a j₀ := by
        have : ((i₀ : ℕ) : ℝ) < ((j₀ : ℕ) : ℝ) := by exact_mod_cast h
        simp only [ha]; linarith
      have h3 : p j₀ < p i₀ := lt_of_le_of_ne (hanti h.le) (Ne.symm hne)
      nlinarith
    · exact absurd (congrArg p h) hne
    · refine ⟨j₀, mem_univ _, i₀, mem_univ _, ?_⟩
      have h1 : a j₀ < a i₀ := by
        have : ((j₀ : ℕ) : ℝ) < ((i₀ : ℕ) : ℝ) := by exact_mod_cast h
        simp only [ha]; linarith
      have h3 : p i₀ < p j₀ := lt_of_le_of_ne (hanti h.le) hne
      nlinarith
  obtain ⟨i, hi, j, hj, hij⟩ := hstrict
  have hM : 0 < M := Nat.pos_of_ne_zero (by rintro rfl; exact absurd i₀.isLt (by simp))
  have key := card_mul_sum_lt_sum_mul_sum (univ : Finset (Fin M)) a p hterm hi hj hij
  rw [sum_rank_weights, hsum, Finset.card_univ, Fintype.card_fin] at key
  have hMpos : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hcost : scanCost p = ∑ i : Fin M, a i * p i := by simp only [scanCost, ha]
  rw [baseCost, hcost]
  nlinarith [key]

/-- **Strict slack.** For an antitone, non-flat profile the gap factor exceeds
one: the master bound overshoots. -/
theorem one_lt_gapX {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i : Fin M, p i = 1)
    (hanti : Antitone p) {i₀ j₀ : Fin M} (hne : p i₀ ≠ p j₀) :
    1 < gapX p := by
  have hc := scanCost_pos hp hsum
  have h := scanCost_lt_baseCost hsum hanti hne
  unfold gapX
  rw [lt_div_iff₀ hc]
  linarith

/-- Equality `X = 1` holds exactly when the ascending cost equals the flat
baseline. -/
theorem gapX_eq_one_iff {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) : gapX p = 1 ↔ scanCost p = baseCost M := by
  have hc := scanCost_pos hp hsum
  unfold gapX
  rw [div_eq_one_iff_eq (ne_of_gt hc)]
  exact eq_comm

/-- A flat profile attains `X = 1`: the bound is tight exactly in the refuted
flat case. -/
theorem gapX_flat (hM : 0 < M) : gapX (fun _ : Fin M => (M : ℝ)⁻¹) = 1 := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hc : scanCost (fun _ : Fin M => (M : ℝ)⁻¹) = baseCost M := by
    unfold scanCost baseCost
    rw [← Finset.sum_mul, sum_rank_weights]
    field_simp
  unfold gapX
  rw [hc]
  exact div_self (ne_of_gt (baseCost_pos M))

/-- **No realizable policy attains the master bound.**  On an antitone, non-flat
profile every policy's speed-up is at most `bound / X`, and `X > 1`. -/
theorem no_policy_attains_bound {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) {i₀ j₀ : Fin M}
    (hne : p i₀ ≠ p j₀) (σ : Equiv.Perm (Fin M)) :
    speedup p σ * gapX p ≤ boundF1 (Lam p) (Theta p) 1 ∧ 1 < gapX p := by
  refine ⟨?_, one_lt_gapX hp hsum hanti hne⟩
  have hX := gapX_pos hp hsum
  have h := policy_speedup_le_Sasc hp hsum hanti σ
  rw [slack_identity hp hsum, mul_comm (gapX p) (Sasc p)]
  exact mul_le_mul_of_nonneg_right h (le_of_lt hX)

/-- Quantitative form: the master bound strictly exceeds every realizable
speed-up, by at least the factor `X > 1`. -/
theorem speedup_lt_bound {p : Fin M → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i : Fin M, p i = 1) (hanti : Antitone p) {i₀ j₀ : Fin M}
    (hne : p i₀ ≠ p j₀) (σ : Equiv.Perm (Fin M)) :
    speedup p σ < boundF1 (Lam p) (Theta p) 1 := by
  obtain ⟨h1, h2⟩ := no_policy_attains_bound hp hsum hanti hne σ
  have hs : 0 < speedup p σ := by
    have hc := scanCost_pos hp hsum
    have hpol : 0 < polCost p σ := lt_of_lt_of_le hc (scanCost_le_polCost hanti σ)
    exact div_pos (revCost_pos hp hsum) hpol
  nlinarith

/-! ## The tightness-circularity catch: `q̂` is not identified -/

/-- With `q̂` unconstrained, *every* observed speed-up can be made an exact
equality in the master inequality.  Hence an "anchor" whose parameters were
obtained by inverting the law carries no evidential weight for tightness. -/
theorem qhat_nonidentifiable (lam th S : ℝ) (hlam : 0 < lam) (hth : 0 < th)
    (hS : 0 < S) : ∃ q, 0 < q ∧ boundF1 lam th q = S := by
  refine ⟨1 / (lam * th * S), by positivity, ?_⟩
  unfold boundF1
  field_simp

/-- Uniqueness of the inverted `q̂`: the inversion is a bijection onto the
positive reals, so no datum can falsify it. -/
theorem qhat_inversion_unique {lam th S q : ℝ} (hlam : 0 < lam) (hth : 0 < th)
    (hS : 0 < S) (hq : 0 < q) (h : boundF1 lam th q = S) :
    q = 1 / (lam * th * S) := by
  unfold boundF1 at h
  have hne : lam * th * q ≠ 0 := by positivity
  field_simp at h ⊢
  nlinarith [h]

/-- The legacy-anchor construction is a tautology: parameters read off at
`Λ = Θ = 1` through `S_A = 1/q̂` reproduce the observation exactly, for *every*
observation. -/
theorem anchor_inversion_tautology {S : ℝ} (hS : 0 < S) : boundF1 1 1 (1 / S) = S := by
  unfold boundF1
  field_simp

/-! ## The measured profile: numerical corollaries -/

/-- The measured shape parameter `Λ = 0.765671`. -/
noncomputable def LamMeas : ℝ := 765671 / 1000000

/-- The booked alignment parameter `Θ_asc ≈ 0.867`. -/
theorem measured_Theta_approx :
    |2 * LamMeas / (1 + LamMeas) - 867 / 1000| < 1 / 1000 := by
  unfold LamMeas
  rw [abs_lt]
  constructor <;> norm_num

/-- The measured gap factor `X = 1.15302` to five decimals. -/
theorem measured_gapX_approx : |gapOfLam LamMeas - 115302 / 100000| < 1 / 100000 := by
  unfold gapOfLam LamMeas
  rw [abs_lt]
  constructor <;> norm_num

/-- Interval transfer: the reported `Λ`-interval `[0.6939, 0.8309]` (equivalently
`Θ ∈ [0.8193, 0.9076]`) maps to `X ∈ [1.1017, 1.2206]`: a slack of at least 10%
and at most 23%. -/
theorem gapX_mem_interval {lam : ℝ} (h₁ : 6939 / 10000 ≤ lam) (h₂ : lam ≤ 8309 / 10000) :
    11017 / 10000 ≤ gapOfLam lam ∧ gapOfLam lam ≤ 12206 / 10000 := by
  have hpos : 0 < lam := by linarith
  unfold gapOfLam
  constructor
  · rw [le_div_iff₀ (by positivity)]; linarith
  · rw [div_le_iff₀ (by positivity)]; linarith

/-- The realizable ascending speed-up predicted by the map, `S ≈ 1.306`. -/
theorem predicted_speedup_approx : |(LamMeas)⁻¹ - 1306 / 1000| < 1 / 1000 := by
  unfold LamMeas
  rw [abs_lt]
  constructor <;> norm_num

/-- The master bound at the measured parameters, `bound ≈ 1.506 < 1.51`. -/
theorem measured_bound_approx :
    |boundF1 LamMeas (2 * LamMeas / (1 + LamMeas)) 1 - 1506 / 1000| < 1 / 1000 := by
  unfold boundF1 LamMeas
  rw [abs_lt]
  constructor <;> norm_num

/-- The decidable closer as a strict two-sided prediction: the predicted
speed-up sits strictly below the bound, and the gap is exactly the factor `X`. -/
theorem predicted_speedup_lt_bound :
    (LamMeas)⁻¹ < boundF1 LamMeas (2 * LamMeas / (1 + LamMeas)) 1 ∧
      boundF1 LamMeas (2 * LamMeas / (1 + LamMeas)) 1
        = gapOfLam LamMeas * (LamMeas)⁻¹ := by
  constructor
  · unfold boundF1 LamMeas; norm_num
  · unfold boundF1 gapOfLam LamMeas; norm_num

end F1Tightness