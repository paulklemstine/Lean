import Probability.NET90MajorisationSweep

/-!
# NET-90, fifth cycle: three domains, and the `6 · d` ladder

Cycles 1–4 settled the two-domain mixing-ratio response: the sup-convolution model, the
bump at the balanced arm, the sharp factor-two ceiling, and Schur-concavity of the knee in
the imbalance.  Direction 2 of `FUTURE_DIRECTIONS.md` asked whether the premium keeps
growing when a *third* content type enters the context — a code + prose + logs workload —
or whether the per-domain cost saturates.

This file answers it for `d = 3`.  The three-domain head mass is the threefold
sup-convolution, obtained by nesting the two-domain one:

  `mix3Head a b c m l n k = max_{j ≤ k} (mixHead a b m l j + headMass c (min (k-j) n))`,

and `le_mix3Head_split` / `mix3Head_le_splits` show this really is the optimum over all
allocations `j₁ + j₂ + j₃ ≤ k` of the budget across the three domains.

Results:

* `mix3Knee_le_add` — subadditivity: the three-domain knee never exceeds the sum of the
  three pure knees;
* `add_kstar_le_mix3Knee` — the mechanism bound: it is at least the sum of the three pure
  knees at gates relaxed by the *other two* domains' mass share, so all three heads must
  be bought;
* `mix3Knee_pure_third` — dropping a domain recovers the two-domain theory exactly;
* `mix3Knee_geomHalf_eq_eighteen` — on the geometric profile at gate `0.98` the balanced
  three-domain context has knee **exactly 18**, and
* `net90_domain_ladder` — the ladder `6 → 12 → 18`: the premium does **not** saturate, the
  budget is exactly `6·d` for `d` massive domains, so the `d`-fold ceiling of direction 2
  is attained at `d = 3`.

The arithmetic heart is `pow_half_triple_lower`: for `j₁ + j₂ + j₃ ≤ 17` the tail term
`(1/2)^{j₁} + (1/2)^{j₂} + (1/2)^{j₃}` is at least `1/16`, minimised by the *balanced*
allocation `(6,6,5)`.  That is once more the Robin Hood phenomenon of cycle 4, now
controlling the failure of budget 17.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 5):
 (T1) The `d`-domain budget is exactly `d` times the pure budget for equally massive
      domains — no saturation.                                                 [BOLD]
 (T2) The `d`-fold head mass is the `d`-fold sup-convolution and can be built by nesting,
      so the two-domain API is reusable verbatim.
 (T3) The extremal allocation at the failing budget is the balanced one, so the exact
      threshold is decided by an integer balancing inequality.

Experimenter: T2 = `mix3Head` with `le_mix3Head_split` / `mix3Head_le_splits`; T1 =
`mix3Knee_geomHalf_eq_eighteen` and `net90_domain_ladder`; T3 = `pow_half_triple_lower`,
proved by reduction to a sorted triple and case analysis on the smallest coordinate.
Zero sorries.

Analyst: the ladder is exact, not merely bracketed — subadditivity gives `≤ 18` and the
balancing inequality gives `> 17`.  Note the two bounds come from genuinely different
places: the upper one is a construction (serve each domain to the gate), the lower one is
an impossibility (no allocation of 17 keys clears the gate).

Critic: the result is stated for domains of *comparable mass*; the cycle-2 lemma
`mixKnee_lightMinority_eq_six` already shows that a light third domain leaves the knee
where it was, so "three domains cost `3×`" is a statement about mass, exactly as in the
two-domain case.  Nothing here is vacuous: `mix3Knee_pure_third` checks the construction
degenerates correctly to the two-domain theory.
-/

namespace AttentionBudget

open Finset

variable {a b c : ℕ → ℝ} {m l n k : ℕ} {τ : ℝ}

/-! ## The threefold sup-convolution -/

/-- Head mass of a top-`k` truncation of a three-domain context, built by nesting the
two-domain sup-convolution. -/
noncomputable def mix3Head (a b c : ℕ → ℝ) (m l n k : ℕ) : ℝ :=
  (range (k + 1)).sup' nonempty_range_add_one
    fun j => mixHead a b m l j + headMass c (min (k - j) n)

/-- Total mass of a three-domain context. -/
noncomputable def mix3Total (a b c : ℕ → ℝ) (m l n : ℕ) : ℝ := mixTotal a b m l + headMass c n

/-- Retained fraction of a three-domain context under a top-`k` truncation. -/
noncomputable def mix3Retained (a b c : ℕ → ℝ) (m l n k : ℕ) : ℝ :=
  mix3Head a b c m l n k / mix3Total a b c m l n

/-- The knee of a three-domain context. -/
noncomputable def mix3Knee (a b c : ℕ → ℝ) (m l n : ℕ) (τ : ℝ) : ℕ :=
  sInf {k | τ ≤ mix3Retained a b c m l n k}

lemma le_mix3Head (a b c : ℕ → ℝ) (m l n : ℕ) {j k : ℕ} (hj : j ≤ k) :
    mixHead a b m l j + headMass c (min (k - j) n) ≤ mix3Head a b c m l n k := by
  rw [mix3Head]
  exact Finset.le_sup' (fun i => mixHead a b m l i + headMass c (min (k - i) n))
    (mem_range.2 (Nat.lt_succ_of_le hj))

lemma mix3Head_le {C : ℝ}
    (h : ∀ j ≤ k, mixHead a b m l j + headMass c (min (k - j) n) ≤ C) :
    mix3Head a b c m l n k ≤ C :=
  Finset.sup'_le _ _ fun j hj => h j (by simpa [Nat.lt_succ_iff] using mem_range.1 hj)

/-- Every allocation of the budget across the three domains is available to the head. -/
lemma le_mix3Head_split (hc : ∀ i, 0 < c i) {j₁ j₂ j₃ : ℕ} (h : j₁ + j₂ + j₃ ≤ k) :
    headMass a (min j₁ m) + headMass b (min j₂ l) + headMass c (min j₃ n)
      ≤ mix3Head a b c m l n k := by
  have h1 : headMass a (min j₁ m) + headMass b (min j₂ l) ≤ mixHead a b m l (j₁ + j₂) := by
    have h0 := le_mixHead a b m l (j := j₁) (k := j₁ + j₂) (by omega)
    simpa [Nat.add_sub_cancel_left] using h0
  have h2 : headMass c (min j₃ n) ≤ headMass c (min (k - (j₁ + j₂)) n) :=
    headMass_mono hc (by omega)
  have h3 := le_mix3Head a b c m l n (j := j₁ + j₂) (k := k) (by omega)
  linarith

/-- Conversely, the head is the best of all allocations. -/
lemma mix3Head_le_splits {C : ℝ}
    (h : ∀ j₁ j₂ j₃, j₁ + j₂ + j₃ ≤ k →
      headMass a (min j₁ m) + headMass b (min j₂ l) + headMass c (min j₃ n) ≤ C) :
    mix3Head a b c m l n k ≤ C := by
  refine mix3Head_le fun j hj => ?_
  have hmix : mixHead a b m l j ≤ C - headMass c (min (k - j) n) := by
    refine mixHead_le fun i hi => ?_
    have := h i (j - i) (k - j) (by omega)
    linarith
  linarith

/-- The optimal split of the outer budget is attained. -/
lemma exists_split_eq_mix3Head (a b c : ℕ → ℝ) (m l n k : ℕ) :
    ∃ j ≤ k, mix3Head a b c m l n k = mixHead a b m l j + headMass c (min (k - j) n) := by
  obtain ⟨j, hj, hval⟩ := Finset.exists_mem_eq_sup' (Finset.nonempty_range_add_one (n := k))
    fun j => mixHead a b m l j + headMass c (min (k - j) n)
  exact ⟨j, by simpa [Nat.lt_succ_iff] using mem_range.1 hj, hval⟩

section Positive

variable (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hc : ∀ i, 0 < c i)

include ha hb hc

lemma mix3Head_le_total (m l n k : ℕ) : mix3Head a b c m l n k ≤ mix3Total a b c m l n :=
  mix3Head_le fun _ _ =>
    add_le_add (mixHead_le_total ha hb _ _ _) (headMass_mono hc (min_le_right _ _))

omit ha hb in
lemma mix3Head_mono (m l n : ℕ) : Monotone (mix3Head a b c m l n) := by
  intro k k' hkk
  refine mix3Head_le fun j hj => ?_
  refine le_trans ?_ (le_mix3Head a b c m l n (j := j) (k := k') (by omega))
  exact add_le_add le_rfl (headMass_mono hc (by omega))

lemma mix3Head_full (m l n : ℕ) : mix3Head a b c m l n (m + l + n) = mix3Total a b c m l n := by
  refine le_antisymm (mix3Head_le_total ha hb hc _ _ _ _) ?_
  have h := le_mix3Head a b c m l n (j := m + l) (k := m + l + n) (by omega)
  rw [mixHead_full ha hb] at h
  simpa [mix3Total, Nat.add_sub_cancel_left] using h

lemma mix3Total_pos (hm : 0 < m) (hl : 0 < l) (hn : 0 < n) : 0 < mix3Total a b c m l n :=
  add_pos (mixTotal_pos ha hb hm hl) (headMass_pos hc hn)

lemma mix3Retained_full (hm : 0 < m) (hl : 0 < l) (hn : 0 < n) :
    mix3Retained a b c m l n (m + l + n) = 1 := by
  rw [mix3Retained, mix3Head_full ha hb hc, div_self (mix3Total_pos ha hb hc hm hl hn).ne']

lemma mix3Retained_mono (hm : 0 < m) (hl : 0 < l) (hn : 0 < n) :
    Monotone (mix3Retained a b c m l n) := fun _ _ hkk =>
  div_le_div_of_nonneg_right (mix3Head_mono hc m l n hkk) (mix3Total_pos ha hb hc hm hl hn).le

lemma gate_le_mix3Retained_mix3Knee (hm : 0 < m) (hl : 0 < l) (hn : 0 < n) (hτ : τ ≤ 1) :
    τ ≤ mix3Retained a b c m l n (mix3Knee a b c m l n τ) := by
  have hmem : m + l + n ∈ {k | τ ≤ mix3Retained a b c m l n k} := by
    simp only [Set.mem_setOf_eq, mix3Retained_full ha hb hc hm hl hn]
    exact hτ
  exact Nat.sInf_mem ⟨_, hmem⟩

lemma mix3Knee_le_context (hm : 0 < m) (hl : 0 < l) (hn : 0 < n) (hτ : τ ≤ 1) :
    mix3Knee a b c m l n τ ≤ m + l + n :=
  Nat.sInf_le (by simpa [Set.mem_setOf_eq, mix3Retained_full ha hb hc hm hl hn] using hτ)

end Positive

lemma mix3Knee_le_of_pass (h : τ ≤ mix3Retained a b c m l n k) : mix3Knee a b c m l n τ ≤ k :=
  Nat.sInf_le h

lemma lt_mix3Knee_of_fail (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hc : ∀ i, 0 < c i)
    (hm : 0 < m) (hl : 0 < l) (hn : 0 < n) (hτ : τ ≤ 1)
    (h : mix3Retained a b c m l n k < τ) : k < mix3Knee a b c m l n τ := by
  by_contra hcon
  push_neg at hcon
  have h1 := mix3Retained_mono ha hb hc hm hl hn hcon
  have h2 := gate_le_mix3Retained_mix3Knee ha hb hc hm hl hn hτ
  linarith

/-! ## Degeneration to the two-domain theory -/

lemma mix3Head_pure_third (hb : ∀ i, 0 < b i) (m l k : ℕ) :
    mix3Head a b c m l 0 k = mixHead a b m l k := by
  refine le_antisymm (mix3Head_le fun j hj => ?_) ?_
  · have h0 : headMass c (min (k - j) 0) = 0 := by simp [headMass]
    rw [h0, add_zero]
    exact mixHead_mono hb m l hj
  · have h := le_mix3Head a b c m l 0 (j := k) (k := k) le_rfl
    simpa [headMass] using h

/-- Dropping the third domain recovers the two-domain knee exactly. -/
theorem mix3Knee_pure_third (hb : ∀ i, 0 < b i) (m l : ℕ) (τ : ℝ) :
    mix3Knee a b c m l 0 τ = mixKnee a b m l τ := by
  have hset : {k | τ ≤ mix3Retained a b c m l 0 k} = {k | τ ≤ mixRetained a b m l k} := by
    ext k
    simp [Set.mem_setOf_eq, mix3Retained, mix3Head_pure_third hb, mix3Total, mixRetained,
      headMass]
  simp [mix3Knee, mixKnee, hset]

/-! ## Sub- and superadditivity across three domains -/

/-- **Subadditivity.**  Serving each of the three domains to the gate separately serves
the mixture, so the three-domain knee is at most the sum of the three pure knees. -/
theorem mix3Knee_le_add (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hc : ∀ i, 0 < c i)
    (hm : 0 < m) (hl : 0 < l) (hn : 0 < n) (hτ : τ ≤ 1) :
    mix3Knee a b c m l n τ ≤ kstar a m τ + kstar b l τ + kstar c n τ := by
  set kA := kstar a m τ
  set kB := kstar b l τ
  set kC := kstar c n τ
  have hSA : 0 < headMass a m := headMass_pos ha hm
  have hSB : 0 < headMass b l := headMass_pos hb hl
  have hSC : 0 < headMass c n := headMass_pos hc hn
  have hA : τ * headMass a m ≤ headMass a (min kA m) := by
    have h := gate_le_retained_kstar ha hm hτ (n := m) (τ := τ)
    rw [retained, le_div_iff₀ hSA] at h; linarith
  have hB : τ * headMass b l ≤ headMass b (min kB l) := by
    have h := gate_le_retained_kstar hb hl hτ (n := l) (τ := τ)
    rw [retained, le_div_iff₀ hSB] at h; linarith
  have hC : τ * headMass c n ≤ headMass c (min kC n) := by
    have h := gate_le_retained_kstar hc hn hτ (n := n) (τ := τ)
    rw [retained, le_div_iff₀ hSC] at h; linarith
  refine mix3Knee_le_of_pass (k := kA + kB + kC) ?_
  have hsplit := le_mix3Head_split (a := a) (b := b) (c := c) (m := m) (l := l) (n := n)
    (k := kA + kB + kC) hc (j₁ := kA) (j₂ := kB) (j₃ := kC) le_rfl
  rw [mix3Retained, le_div_iff₀ (mix3Total_pos ha hb hc hm hl hn), mix3Total, mixTotal]
  nlinarith

/-- **The mechanism bound in three domains.**  Every domain must be served to a gate
relaxed only by the *other two* domains' mass share: the three-domain knee dominates the
sum of three pure knees at those relaxed gates. -/
theorem add_kstar_le_mix3Knee (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hc : ∀ i, 0 < c i)
    (hm : 0 < m) (hl : 0 < l) (hn : 0 < n) (hτ : τ ≤ 1) :
    kstar a m (τ - (1 - τ) * ((headMass b l + headMass c n) / headMass a m))
      + kstar b l (τ - (1 - τ) * ((headMass a m + headMass c n) / headMass b l))
      + kstar c n (τ - (1 - τ) * ((headMass a m + headMass b l) / headMass c n))
      ≤ mix3Knee a b c m l n τ := by
  have hSA : 0 < headMass a m := headMass_pos ha hm
  have hSB : 0 < headMass b l := headMass_pos hb hl
  have hSC : 0 < headMass c n := headMass_pos hc hn
  set k := mix3Knee a b c m l n τ with hk
  have hgate : τ ≤ mix3Retained a b c m l n k :=
    gate_le_mix3Retained_mix3Knee ha hb hc hm hl hn hτ
  obtain ⟨j, hjk, hj⟩ := exists_split_eq_mix3Head a b c m l n k
  obtain ⟨i, hij, hi⟩ := exists_split_eq_mixHead a b m l j
  have hmass : τ * (headMass a m + headMass b l + headMass c n)
      ≤ headMass a (min i m) + headMass b (min (j - i) l) + headMass c (min (k - j) n) := by
    rw [mix3Retained, le_div_iff₀ (mix3Total_pos ha hb hc hm hl hn), mix3Total, mixTotal] at hgate
    rw [hj, hi] at hgate
    linarith
  have hbA : headMass a (min i m) ≤ headMass a m := headMass_mono ha (min_le_right _ _)
  have hbB : headMass b (min (j - i) l) ≤ headMass b l := headMass_mono hb (min_le_right _ _)
  have hbC : headMass c (min (k - j) n) ≤ headMass c n := headMass_mono hc (min_le_right _ _)
  have hA : τ - (1 - τ) * ((headMass b l + headMass c n) / headMass a m) ≤ retained a m i := by
    rw [retained, le_div_iff₀ hSA]
    have hexp : (τ - (1 - τ) * ((headMass b l + headMass c n) / headMass a m)) * headMass a m
        = τ * headMass a m - (1 - τ) * (headMass b l + headMass c n) := by field_simp
    rw [hexp]; nlinarith
  have hB : τ - (1 - τ) * ((headMass a m + headMass c n) / headMass b l)
      ≤ retained b l (j - i) := by
    rw [retained, le_div_iff₀ hSB]
    have hexp : (τ - (1 - τ) * ((headMass a m + headMass c n) / headMass b l)) * headMass b l
        = τ * headMass b l - (1 - τ) * (headMass a m + headMass c n) := by field_simp
    rw [hexp]; nlinarith
  have hC : τ - (1 - τ) * ((headMass a m + headMass b l) / headMass c n)
      ≤ retained c n (k - j) := by
    rw [retained, le_div_iff₀ hSC]
    have hexp : (τ - (1 - τ) * ((headMass a m + headMass b l) / headMass c n)) * headMass c n
        = τ * headMass c n - (1 - τ) * (headMass a m + headMass b l) := by field_simp
    rw [hexp]; nlinarith
  have h1 := kstar_le_of_pass hA
  have h2 := kstar_le_of_pass hB
  have h3 := kstar_le_of_pass hC
  omega

/-! ## The balancing inequality behind budget 17 -/

private lemma half_pow_antitone {i j : ℕ} (h : i ≤ j) : ((1 : ℝ) / 2) ^ j ≤ ((1 : ℝ) / 2) ^ i :=
  pow_le_pow_of_le_one (by norm_num) (by norm_num) h

private lemma pow_half_triple_sorted {x y z : ℕ} (hxy : x ≤ y) (hyz : y ≤ z)
    (h : x + y + z ≤ 17) :
    (1 / 16 : ℝ) ≤ (1 / 2 : ℝ) ^ x + (1 / 2 : ℝ) ^ y + (1 / 2 : ℝ) ^ z := by
  have hpos : ∀ i : ℕ, (0 : ℝ) < (1 / 2 : ℝ) ^ i := fun i => by positivity
  have h5 : ((1 : ℝ) / 2) ^ 5 = 1 / 32 := by norm_num
  have h6 : ((1 : ℝ) / 2) ^ 6 = 1 / 64 := by norm_num
  rcases le_or_gt x 4 with hx | hx
  · have h1 : ((1 : ℝ) / 2) ^ 4 ≤ ((1 : ℝ) / 2) ^ x := half_pow_antitone hx
    have h4 : ((1 : ℝ) / 2) ^ 4 = 1 / 16 := by norm_num
    linarith [(hpos y).le, (hpos z).le]
  · -- `3x ≤ x + y + z ≤ 17` forces `x = 5`
    have hx5 : x = 5 := by omega
    subst hx5
    have hy : y ≤ 6 := by omega
    interval_cases y
    · linarith [(hpos z).le]
    · have h3 : ((1 : ℝ) / 2) ^ 6 ≤ ((1 : ℝ) / 2) ^ z := half_pow_antitone (by omega)
      linarith

/-- **The balancing inequality.**  Seventeen keys cannot be spread across three geometric
tails without leaving at least `1/16` of the geometric tail mass behind; the minimiser is
the balanced allocation `(6,6,5)`. -/
lemma pow_half_triple_lower {j₁ j₂ j₃ : ℕ} (h : j₁ + j₂ + j₃ ≤ 17) :
    (1 / 16 : ℝ) ≤ (1 / 2 : ℝ) ^ j₁ + (1 / 2 : ℝ) ^ j₂ + (1 / 2 : ℝ) ^ j₃ := by
  rcases le_total j₁ j₂ with h12 | h12 <;> rcases le_total j₂ j₃ with h23 | h23 <;>
    rcases le_total j₁ j₃ with h13 | h13
  · have := pow_half_triple_sorted (x := j₁) (y := j₂) (z := j₃) h12 h23 (by omega)
    linarith
  · have := pow_half_triple_sorted (x := j₁) (y := j₂) (z := j₃) h12 h23 (by omega)
    linarith
  · have := pow_half_triple_sorted (x := j₁) (y := j₃) (z := j₂) h13 h23 (by omega)
    linarith
  · have := pow_half_triple_sorted (x := j₃) (y := j₁) (z := j₂) h13 h12 (by omega)
    linarith
  · have := pow_half_triple_sorted (x := j₂) (y := j₁) (z := j₃) h12 h13 (by omega)
    linarith
  · have := pow_half_triple_sorted (x := j₂) (y := j₃) (z := j₁) h23 h13 (by omega)
    linarith
  · have := pow_half_triple_sorted (x := j₃) (y := j₂) (z := j₁) h23 h12 (by omega)
    linarith
  · have := pow_half_triple_sorted (x := j₃) (y := j₂) (z := j₁) h23 h12 (by omega)
    linarith

/-! ## The exact three-domain knee on the geometric profile -/

lemma mix3Head_geomHalf_seventeen {m l n : ℕ} :
    mix3Head geomHalf geomHalf geomHalf m l n 17 ≤ 6 - 1 / 8 := by
  refine mix3Head_le_splits fun j₁ j₂ j₃ h => ?_
  rw [headMass_geomHalf, headMass_geomHalf, headMass_geomHalf]
  have e1 : ((1 : ℝ) / 2) ^ j₁ ≤ ((1 : ℝ) / 2) ^ (min j₁ m) := half_pow_antitone (min_le_left _ _)
  have e2 : ((1 : ℝ) / 2) ^ j₂ ≤ ((1 : ℝ) / 2) ^ (min j₂ l) := half_pow_antitone (min_le_left _ _)
  have e3 : ((1 : ℝ) / 2) ^ j₃ ≤ ((1 : ℝ) / 2) ^ (min j₃ n) := half_pow_antitone (min_le_left _ _)
  have hlow := pow_half_triple_lower h
  linarith

/-- **The three-domain knee is exactly 18.**  Three geometric domains of at least 16 keys
each, at gate `0.98`, need exactly `18 = 3 · 6` keys. -/
theorem mix3Knee_geomHalf_eq_eighteen {m l n : ℕ} (hm : 16 ≤ m) (hl : 16 ≤ l) (hn : 16 ≤ n) :
    mix3Knee geomHalf geomHalf geomHalf m l n (0.98 : ℝ) = 18 := by
  have hm0 : 0 < m := by omega
  have hl0 : 0 < l := by omega
  have hn0 : 0 < n := by omega
  have hTpos : 0 < mix3Total geomHalf geomHalf geomHalf m l n :=
    mix3Total_pos geomHalf_pos geomHalf_pos geomHalf_pos hm0 hl0 hn0
  have hupA := headMass_geomHalf_lt_two m
  have hupB := headMass_geomHalf_lt_two l
  have hupC := headMass_geomHalf_lt_two n
  have hlowA := headMass_geomHalf_ge hm
  have hlowB := headMass_geomHalf_ge hl
  have hlowC := headMass_geomHalf_ge hn
  have h16 : (2 : ℝ) * (1 - (1 / 2 : ℝ) ^ 16) = 65535 / 32768 := by norm_num
  rw [h16] at hlowA hlowB hlowC
  have hpass : (0.98 : ℝ) ≤ mix3Retained geomHalf geomHalf geomHalf m l n 18 := by
    have hsplit := le_mix3Head_split (a := geomHalf) (b := geomHalf) (c := geomHalf)
      (m := m) (l := l) (n := n) (k := 18) geomHalf_pos (j₁ := 6) (j₂ := 6) (j₃ := 6) (by omega)
    have h6m : headMass geomHalf (min 6 m) = 63 / 32 := by
      rw [min_eq_left (by omega), headMass_geomHalf]; norm_num
    have h6l : headMass geomHalf (min 6 l) = 63 / 32 := by
      rw [min_eq_left (by omega), headMass_geomHalf]; norm_num
    have h6n : headMass geomHalf (min 6 n) = 63 / 32 := by
      rw [min_eq_left (by omega), headMass_geomHalf]; norm_num
    rw [h6m, h6l, h6n] at hsplit
    rw [mix3Retained, le_div_iff₀ hTpos, mix3Total, mixTotal]
    linarith
  have hfail : mix3Retained geomHalf geomHalf geomHalf m l n 17 < (0.98 : ℝ) := by
    have hhead := mix3Head_geomHalf_seventeen (m := m) (l := l) (n := n)
    rw [mix3Retained, div_lt_iff₀ hTpos, mix3Total, mixTotal]
    linarith
  have h1 : mix3Knee geomHalf geomHalf geomHalf m l n (0.98 : ℝ) ≤ 18 :=
    mix3Knee_le_of_pass hpass
  have h2 : 17 < mix3Knee geomHalf geomHalf geomHalf m l n (0.98 : ℝ) :=
    lt_mix3Knee_of_fail geomHalf_pos geomHalf_pos geomHalf_pos hm0 hl0 hn0 (by norm_num) hfail
  omega

/-- **The domain ladder `6 → 12 → 18`.**  On the geometric profile at gate `0.98` the
budget of a balanced mixture of `d` equally massive domains is exactly `6·d` for
`d = 1, 2, 3`: the per-domain cost does not saturate. -/
theorem net90_domain_ladder {N : ℕ} (hN : 16 ≤ N) :
    kstar geomHalf N (0.98 : ℝ) = 6 ∧
      mixKnee geomHalf geomHalf N N (0.98 : ℝ) = 12 ∧
      mix3Knee geomHalf geomHalf geomHalf N N N (0.98 : ℝ) = 18 ∧
      mix3Knee geomHalf geomHalf geomHalf N N N (0.98 : ℝ)
        = 3 * kstar geomHalf N (0.98 : ℝ) := by
  have h1 := kstar_geomHalf_eq_six hN
  have h2 := mixKnee_geomHalf_eq_twelve hN hN
  have h3 := mix3Knee_geomHalf_eq_eighteen hN hN hN
  exact ⟨h1, h2, h3, by rw [h1, h3]⟩

end AttentionBudget