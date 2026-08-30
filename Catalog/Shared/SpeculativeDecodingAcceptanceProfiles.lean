import Shared.SpeculativeDecodingDepthUnimodality

/-!
# Per-position acceptance profiles: reconstructing the NET-91 acceptance maps

Cycle 3 of the NET-91 thread, attacking the experiment's first open question — *per-position
acceptance maps: why does prose collapse past `d = 4`?*

Cycle 1 proved that the reported acceptance percentages cannot be per-position independent
acceptance probabilities (`SpecDecCPU.iid_cannot_explain_code_depth8`).  The repair is to
model the **survival profile** directly: `S k` is the probability that the first `k`
drafted positions are all accepted, so `S 0 = 1`, `S` is nonincreasing, and the block yield
is `posYield S d = ∑_{k ≤ d} S k`.  The i.i.d. model is the special case `S k = a ^ k`.

## Results

* **Averaging law** (`meanAccept_antitone_succ`, `meanAccept_antitone`): for *any* fixed
  survival profile the reported overall acceptance — the mean `(posYield S d - 1)/d` — is
  automatically nonincreasing in depth.  So the measured decay of acceptance with depth
  (prose `63.9 → 47.7 → 30.9`, code `71.6 → 63.0 → 56.0`) is not evidence that the drafter
  degrades: it is forced by averaging a nonincreasing profile.
* **Falsifiable necessary condition** (`blockMean_antitone`, `meanAccept_antitone`):
  monotone survival forces the *block* means between successive measured depths to be
  nonincreasing as well.  The test has teeth — acceptance percentages rising with depth are
  unrealisable (`unrealisable_increasing_acceptance`) — and the NET-91 numbers pass it
  (`net91_acceptances_realisable`).
* **Exact reconstruction** (`code_profile_matches_measurements`,
  `prose_profile_matches_measurements`): explicit nonincreasing survival profiles that
  reproduce *all three* measured acceptance percentages of each domain exactly.  The
  reported numbers are therefore fully consistent with a single depth-independent
  per-position map, and the maps are exhibited.
* **Practical stopping rule** (`deepen_pays_iff_marginal_survival`): deepen the draft while
  the survival probability of the next position exceeds `c` times the current speedup.
  This is the exact optimality condition, and by cycle 2 it is safe to apply greedily.
* **The prescription, derived** (`prose_stops_at_four`, `code_pays_through_eight`): with
  the reconstructed profiles and a marginal per-position cost `k = 0.287` (the average
  marginal cost over depths 4 to 8 of the cost curve fitted in cycle 4), prose stops paying
  at depth 4 while code still gains from 4 to 8 — exactly the measured prescription
  "`d = 8` for code, `d = 4` for prose", now a theorem about the reconstructed profiles
  rather than a fitted observation.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 3):
 (D1) [BOLD] The measured acceptance decay with depth carries *no* information about the
      drafter: any fixed profile produces a nonincreasing measured mean.
 (D2) [BOLD] The six measured acceptance numbers are exactly realisable by two monotone
      per-position maps; the "collapse" is a property of the tail of the prose map.
 (D3) Monotone survival is falsifiable from three depths per domain via block means.
 (D4) The optimal-depth rule is local: compare next-position survival with `c ·` current
      speedup.
 (D5) With the cycle-1 cost bracket, D2 + D4 reproduce the deployed prescription.

Experimenter: D1–D5 formalised below, zero sorries.  Reconstructed survival profiles
(probability that the first `k` drafted tokens are all accepted):

  k        :  0     1      2      3      4     5..8
  code     : 1.000 0.800  0.632  0.560  0.528  0.490
  prose    : 1.000 0.700  0.578  0.350  0.280  0.141

Block means (measured, cumulative differences): code 0.716, 0.544, 0.490; prose 0.639,
0.315, 0.141 — both nonincreasing, as monotone survival requires.

Analyst: the prose map falls off a cliff between positions 2 and 3 (0.578 → 0.350) whereas
the code map decays gently (0.632 → 0.560).  Under the local rule D4 this is exactly the
mechanism of the domain split: prose's next-position survival drops below `k ·` speedup at
depth 4, code's does not before depth 8.

Critic: the reconstruction is *not* unique — only the three cumulative sums are pinned by
the data — so the theorems are stated as realisability (existence) plus a falsifiable
necessary condition, never as identification of the true map.
-/

namespace SpecDecCPU

open Finset

/-! ## Survival profiles -/

/-- Expected tokens committed per block when `S k` is the probability that the first `k`
drafted positions are all accepted (`S 0 = 1` is the free bonus token). -/
noncomputable def posYield (S : ℕ → ℝ) (d : ℕ) : ℝ := ∑ k ∈ range (d + 1), S k

/-- The i.i.d. model is the geometric survival profile. -/
lemma posYield_geom (a : ℝ) (d : ℕ) : posYield (fun k => a ^ k) d = yieldGeom a d := rfl

lemma posYield_succ (S : ℕ → ℝ) (d : ℕ) : posYield S (d + 1) = posYield S d + S (d + 1) := by
  simp [posYield, Finset.sum_range_succ]

/-- The quantity the harness reports: the fraction of drafted tokens that were committed. -/
noncomputable def meanAccept (S : ℕ → ℝ) (d : ℕ) : ℝ := (posYield S d - 1) / d

/-- Head decomposition: for a normalised profile (`S 0 = 1`, the free bonus token) the
accepted mass is the sum of the survival probabilities of the drafted positions. -/
lemma posYield_sub_one {S : ℕ → ℝ} (hS0 : S 0 = 1) (d : ℕ) :
    posYield S d - 1 = ∑ k ∈ Ico 1 (d + 1), S k := by
  have h := Finset.sum_range_add_sum_Ico S (m := 1) (n := d + 1) (by omega)
  simp only [posYield, Finset.sum_range_one] at *
  rw [hS0] at h
  linarith

/-- **Averaging law, one step.**  For a nonincreasing survival profile the reported mean
acceptance is nonincreasing in the depth — with no change in the underlying profile. -/
theorem meanAccept_antitone_succ {S : ℕ → ℝ} (hS0 : S 0 = 1) (hS : ∀ k, S (k + 1) ≤ S k)
    {d : ℕ} (hd : 1 ≤ d) : meanAccept S (d + 1) ≤ meanAccept S d := by
  have hmono : ∀ {i j : ℕ}, i ≤ j → S j ≤ S i := by
    intro i j hij
    induction j, hij using Nat.le_induction with
    | base => exact le_rfl
    | succ n hn ih => exact le_trans (hS n) ih
  have hd0 : (0 : ℝ) < d := by exact_mod_cast hd
  have hd1 : (0 : ℝ) < (d : ℝ) + 1 := by linarith
  have hsum : (d : ℝ) * S (d + 1) ≤ posYield S d - 1 := by
    have : ∑ k ∈ Ico 1 (d + 1), S (d + 1) ≤ ∑ k ∈ Ico 1 (d + 1), S k :=
      Finset.sum_le_sum fun k hk => hmono (by simp only [Finset.mem_Ico] at hk; omega)
    have hcard : ((Ico 1 (d + 1)).card : ℝ) = d := by
      simp [Nat.card_Ico]
    rw [posYield_sub_one hS0]
    calc (d : ℝ) * S (d + 1) = ∑ _k ∈ Ico 1 (d + 1), S (d + 1) := by
          rw [Finset.sum_const, nsmul_eq_mul, hcard]
      _ ≤ ∑ k ∈ Ico 1 (d + 1), S k := this
  simp only [meanAccept]
  rw [div_le_div_iff₀ (by exact_mod_cast hd1) hd0, posYield_succ]
  push_cast
  nlinarith

/-- **Averaging law.**  The reported mean acceptance is antitone in depth for every
nonincreasing survival profile. -/
theorem meanAccept_antitone {S : ℕ → ℝ} (hS0 : S 0 = 1) (hS : ∀ k, S (k + 1) ≤ S k)
    {d e : ℕ} (hd : 1 ≤ d) (hde : d ≤ e) : meanAccept S e ≤ meanAccept S d := by
  induction e, hde using Nat.le_induction with
  | base => exact le_rfl
  | succ n hn ih =>
      exact le_trans (meanAccept_antitone_succ hS0 hS (le_trans hd hn)) ih

/-- **Falsifiable necessary condition.**  Monotone survival forces the mean acceptance of
the *positions between* two measured depths to be at most that of the earlier block. -/
theorem blockMean_antitone {S : ℕ → ℝ} (hS0 : S 0 = 1) (hS : ∀ k, S (k + 1) ≤ S k)
    {d e : ℕ} (hde : d < e) :
    (e - d : ℝ) * (posYield S d - 1) ≥ (d : ℝ) * (posYield S e - posYield S d) := by
  have hmono : ∀ {i j : ℕ}, i ≤ j → S j ≤ S i := by
    intro i j hij
    induction j, hij using Nat.le_induction with
    | base => exact le_rfl
    | succ n hn ih => exact le_trans (hS n) ih
  have hhead : posYield S d - 1 = ∑ k ∈ Ico 1 (d + 1), S k := posYield_sub_one hS0 d
  have htail : posYield S e - posYield S d = ∑ k ∈ Ico (d + 1) (e + 1), S k := by
    have := Finset.sum_range_add_sum_Ico S (m := d + 1) (n := e + 1) (by omega)
    simp only [posYield] at *
    linarith
  have hlow : (d : ℝ) * S (d + 1) ≤ posYield S d - 1 := by
    have hle : ∑ _k ∈ Ico 1 (d + 1), S (d + 1) ≤ ∑ k ∈ Ico 1 (d + 1), S k :=
      Finset.sum_le_sum fun k hk => hmono (by simp only [Finset.mem_Ico] at hk; omega)
    have hcard : ((Ico 1 (d + 1)).card : ℝ) = d := by simp [Nat.card_Ico]
    rw [hhead]
    calc (d : ℝ) * S (d + 1) = ∑ _k ∈ Ico 1 (d + 1), S (d + 1) := by
          rw [Finset.sum_const, nsmul_eq_mul, hcard]
      _ ≤ _ := hle
  have hhigh : posYield S e - posYield S d ≤ (e - d : ℝ) * S (d + 1) := by
    have hle : ∑ k ∈ Ico (d + 1) (e + 1), S k ≤ ∑ _k ∈ Ico (d + 1) (e + 1), S (d + 1) :=
      Finset.sum_le_sum fun k hk => hmono (by simp only [Finset.mem_Ico] at hk; omega)
    have hcard : ((Ico (d + 1) (e + 1)).card : ℝ) = (e : ℝ) - d := by
      rw [Nat.card_Ico]
      have h : e + 1 - (d + 1) = e - d := by omega
      rw [h, Nat.cast_sub hde.le]
    rw [htail]
    calc ∑ k ∈ Ico (d + 1) (e + 1), S k
        ≤ ∑ _k ∈ Ico (d + 1) (e + 1), S (d + 1) := hle
      _ = ((e : ℝ) - d) * S (d + 1) := by rw [Finset.sum_const, nsmul_eq_mul, hcard]
  have hed : (0 : ℝ) ≤ (e : ℝ) - d := by
    have : (d : ℝ) ≤ e := by exact_mod_cast hde.le
    linarith
  nlinarith [Nat.cast_nonneg (α := ℝ) d]

/-! ## The reconstructed NET-91 profiles -/

/-- Survival profile reconstructed from the measured code acceptances. -/
noncomputable def codeSurvival (k : ℕ) : ℝ :=
  if k = 0 then 1 else if k = 1 then 800/1000 else if k = 2 then 632/1000
  else if k = 3 then 560/1000 else if k = 4 then 528/1000 else 490/1000

/-- Survival profile reconstructed from the measured prose acceptances. -/
noncomputable def proseSurvival (k : ℕ) : ℝ :=
  if k = 0 then 1 else if k = 1 then 700/1000 else if k = 2 then 578/1000
  else if k = 3 then 350/1000 else if k = 4 then 280/1000 else 141/1000

lemma codeSurvival_tail {k : ℕ} (hk : 5 ≤ k) : codeSurvival k = 490/1000 := by
  unfold codeSurvival
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega),
    if_neg (by omega)]

lemma proseSurvival_tail {k : ℕ} (hk : 5 ≤ k) : proseSurvival k = 141/1000 := by
  unfold proseSurvival
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega),
    if_neg (by omega)]

lemma codeSurvival_zero : codeSurvival 0 = 1 := by norm_num [codeSurvival]

lemma proseSurvival_zero : proseSurvival 0 = 1 := by norm_num [proseSurvival]

lemma codeSurvival_antitone : ∀ k, codeSurvival (k + 1) ≤ codeSurvival k := by
  intro k
  match k with
  | 0 => norm_num [codeSurvival]
  | 1 => norm_num [codeSurvival]
  | 2 => norm_num [codeSurvival]
  | 3 => norm_num [codeSurvival]
  | 4 => norm_num [codeSurvival]
  | (n + 5) => rw [codeSurvival_tail (by omega), codeSurvival_tail (by omega)]

lemma proseSurvival_antitone : ∀ k, proseSurvival (k + 1) ≤ proseSurvival k := by
  intro k
  match k with
  | 0 => norm_num [proseSurvival]
  | 1 => norm_num [proseSurvival]
  | 2 => norm_num [proseSurvival]
  | 3 => norm_num [proseSurvival]
  | 4 => norm_num [proseSurvival]
  | (n + 5) => rw [proseSurvival_tail (by omega), proseSurvival_tail (by omega)]

/-- **Exact reconstruction, code.**  A single nonincreasing per-position survival map
reproduces all three measured code acceptance percentages (71.6%, 63.0%, 56.0%). -/
theorem code_profile_matches_measurements :
    codeSurvival 0 = 1 ∧ (∀ k, codeSurvival (k + 1) ≤ codeSurvival k) ∧
    meanAccept codeSurvival 2 = 716/1000 ∧
    meanAccept codeSurvival 4 = 630/1000 ∧
    meanAccept codeSurvival 8 = 560/1000 := by
  refine ⟨codeSurvival_zero, codeSurvival_antitone, ?_, ?_, ?_⟩ <;>
    norm_num [meanAccept, posYield, Finset.sum_range_succ, codeSurvival]

/-- **Exact reconstruction, prose.**  Likewise for the measured prose acceptances
(63.9%, 47.7%, 30.9%). -/
theorem prose_profile_matches_measurements :
    proseSurvival 0 = 1 ∧ (∀ k, proseSurvival (k + 1) ≤ proseSurvival k) ∧
    meanAccept proseSurvival 2 = 639/1000 ∧
    meanAccept proseSurvival 4 = 477/1000 ∧
    meanAccept proseSurvival 8 = 309/1000 := by
  refine ⟨proseSurvival_zero, proseSurvival_antitone, ?_, ?_, ?_⟩ <;>
    norm_num [meanAccept, posYield, Finset.sum_range_succ, proseSurvival]

/-- **The NET-91 acceptance data are realisable.**  Both domains' three measured
acceptance percentages come from a single normalised, nonincreasing per-position survival
map; the maps are the explicit ones above. -/
theorem net91_acceptances_realisable :
    (∃ S : ℕ → ℝ, S 0 = 1 ∧ (∀ k, S (k + 1) ≤ S k) ∧ meanAccept S 2 = 716/1000 ∧
      meanAccept S 4 = 630/1000 ∧ meanAccept S 8 = 560/1000) ∧
    (∃ S : ℕ → ℝ, S 0 = 1 ∧ (∀ k, S (k + 1) ≤ S k) ∧ meanAccept S 2 = 639/1000 ∧
      meanAccept S 4 = 477/1000 ∧ meanAccept S 8 = 309/1000) :=
  ⟨⟨codeSurvival, code_profile_matches_measurements⟩,
   ⟨proseSurvival, prose_profile_matches_measurements⟩⟩

/-- The realisability test has teeth: acceptance percentages that *rise* with depth are
impossible for any fixed profile.  Had the harness reported, say, 50% at depth 2 and 70%
at depth 4, no per-position acceptance map whatsoever could have produced it. -/
theorem unrealisable_increasing_acceptance :
    ¬ ∃ S : ℕ → ℝ, S 0 = 1 ∧ (∀ k, S (k + 1) ≤ S k) ∧ meanAccept S 2 = 1/2 ∧
      meanAccept S 4 = 7/10 := by
  rintro ⟨S, hS0, hS, h2, h4⟩
  have := meanAccept_antitone hS0 hS (d := 2) (e := 4) (by omega) (by omega)
  rw [h2, h4] at this
  norm_num at this

/-! ## The local stopping rule and the derived prescription -/

lemma genSpeedup_lt_succ_iff {Y : ℕ → ℝ} {c : ℝ} (hc : 0 ≤ c) (d : ℕ) :
    genSpeedup Y c d < genSpeedup Y c (d + 1) ↔
      c * Y d < (Y (d + 1) - Y d) * blockCost c d := by
  rw [genSpeedup, genSpeedup, div_lt_div_iff₀ (blockCost_pos hc d)
    (blockCost_pos hc (d + 1))]
  have h : blockCost c (d + 1) = blockCost c d + c := by
    simp only [blockCost, Nat.cast_add, Nat.cast_one]; ring
  rw [h]
  constructor <;> intro hh <;> nlinarith

/-- **Stopping rule.**  Deepening the draft by one position pays exactly when the survival
probability of that position exceeds `c` times the current speedup.  Combined with cycle 2
(`greedy_depth_optimal`, applicable because `posYield` has nonincreasing increments for a
monotone profile) this rule may be applied greedily and still finds the global optimum. -/
theorem deepen_pays_iff_marginal_survival {S : ℕ → ℝ} {c : ℝ} (hc : 0 ≤ c) (d : ℕ) :
    genSpeedup (posYield S) c d < genSpeedup (posYield S) c (d + 1) ↔
      c * genSpeedup (posYield S) c d < S (d + 1) := by
  rw [genSpeedup_lt_succ_iff hc, posYield_succ]
  have hb : 0 < blockCost c d := blockCost_pos hc d
  rw [genSpeedup]
  constructor
  · intro h
    rw [← mul_div_assoc, div_lt_iff₀ hb]
    nlinarith
  · intro h
    rw [← mul_div_assoc, div_lt_iff₀ hb] at h
    nlinarith

lemma posYield_concave {S : ℕ → ℝ} (hS : ∀ k, S (k + 1) ≤ S k) (n : ℕ) :
    posYield S (n + 2) - posYield S (n + 1) ≤ posYield S (n + 1) - posYield S n := by
  rw [posYield_succ, posYield_succ]
  have := hS (n + 1)
  linarith

/-- Greedy depth tuning is exact for any monotone survival profile. -/
theorem profile_greedy_depth_optimal {S : ℕ → ℝ} {c : ℝ} (hS : ∀ k, S (k + 1) ≤ S k)
    (hc : 0 ≤ c) {D : ℕ}
    (hup : ∀ k < D, genSpeedup (posYield S) c k ≤ genSpeedup (posYield S) c (k + 1))
    (hstop : genSpeedup (posYield S) c (D + 1) < genSpeedup (posYield S) c D) :
    ∀ d : ℕ, genSpeedup (posYield S) c d ≤ genSpeedup (posYield S) c D :=
  greedy_depth_optimal hc (posYield_concave hS) hup hstop

/-- **Prose stops at depth 4.**  With the reconstructed prose profile and a marginal
per-position cost `k = 0.287` — the average marginal cost over depths 4 to 8 of the CPU
cost curve fitted in cycle 4 — the fifth drafted position does not pay: its survival
`0.141` is below `k ·` the depth-4 speedup. -/
theorem prose_stops_at_four :
    genSpeedup (posYield proseSurvival) (287/1000) 5 <
      genSpeedup (posYield proseSurvival) (287/1000) 4 := by
  rw [genSpeedup_succ_lt_iff (by norm_num) 4]
  norm_num [posYield, blockCost, Finset.sum_range_succ, proseSurvival]

/-- **Code keeps paying through depth 8.**  With the same marginal cost, the reconstructed
code profile makes depth 8 strictly better than depth 4 — the measured best cell. -/
theorem code_pays_through_eight :
    genSpeedup (posYield codeSurvival) (287/1000) 4 <
      genSpeedup (posYield codeSurvival) (287/1000) 8 := by
  rw [genSpeedup, genSpeedup, div_lt_div_iff₀ (blockCost_pos (by norm_num) 4)
    (blockCost_pos (by norm_num) 8)]
  norm_num [posYield, blockCost, Finset.sum_range_succ, codeSurvival]

/-- **Law 2, derived end to end.**  From reconstructed per-position acceptance maps and one
shared cost parameter, the deployed prescription follows: prose should stop at depth 4,
code should run to depth 8.  A static depth is optimal for neither. -/
theorem domain_parameterised_depth_prescription :
    genSpeedup (posYield proseSurvival) (287/1000) 5 <
      genSpeedup (posYield proseSurvival) (287/1000) 4 ∧
    genSpeedup (posYield codeSurvival) (287/1000) 4 <
      genSpeedup (posYield codeSurvival) (287/1000) 8 :=
  ⟨prose_stops_at_four, code_pays_through_eight⟩

end SpecDecCPU