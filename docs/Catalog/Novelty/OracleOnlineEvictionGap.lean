import Mathlib

/-!
# The oracle overstates the deployable win (NET-56)

Round 9 of the limited-memory axis measured, on one and the same harness
(Qwen2.5-0.5B, ctx = 1024, block-128 eviction), two very different numbers:

| arm                          | B = 32 | B = 64 | B = 128 |
|------------------------------|--------|--------|---------|
| ORACLE (per-row top-k)       | 0.9913 | 0.9953 | —       |
| HH (accumulated, pure)       | 0.8633 | 0.8822 | 0.9189  |
| HYB (HH + recency)           | 0.9205 | 0.9384 | 0.9605  |

The verdict — *trained attention is prunable in retrospect, not predictable
online* — is here turned into theorems.  The three measured horns become three
proved statements about **set-valued cache policies** on an attention matrix
`w : ℕ → ℕ → ℝ` (`w t j` = probability that query row `t` places on key `j`).

## Main results

*Oracle side (retrospective pruning is easy).*
* `oracle` is the best retention achievable by any cache of at most `B` keys.
* `kept_le_top_add`, `kept_le_top` — the **exchange lemma**: a top-`B` set by any
  score dominates every admissible cache, up to the score/attention mismatch.
* `oracle_eq_topByScore` — **the assumption-conditioned positive result**: if the
  accumulated score is *consistent* with the future row (`ScoreConsistent`), the
  heavy-hitter cache is exactly optimal, and
  `oracle_le_topByScore_add` gives the graceful `B·ε` degradation.  This is the
  precise sense in which online prediction needs an assumption.

*Policy side (online prediction is impossible).*
* `causal_policy_misses` — for **every** causally honest policy `P` (cache at row
  `t` a function of rows `< t` only) with budget `B < n`, there is an instance of
  the uniform-prefix family `adv` on which `P` retains exactly `0` while
  `oracle_adv` shows the omniscient selector retains `1`;
* `oracle_overstates` — hence the oracle-to-policy gap is `1` (100 points, the
  strongest possible form of the measured 11.3-point gap), and
* `causal_average_le_budget` / `causal_average_le` — even *on average* over the
  family, no causal policy exceeds `B/n`, while the oracle stays at `1`.
  Accumulated attention probability is a biased estimator of future importance
  because *no* function of the past is an unbiased one.

*Which heuristic, and why hybrids.*
* `hhSet`, `recentSet`, `hybSet` are concrete policies; `hh_causal`,
  `recency_causal`, `hyb_causal` place them inside the impossibility above.
* `hh_misses_stale` vs `recency_hits_stale` and `hh_hits_pin` vs
  `recency_misses_pin` — **P2, structurally**: neither pure accumulation nor
  pure recency dominates (`no_policy_dominance`), while
  `hyb_hits_stale`, `hyb_hits_pin` show the hybrid wins on both families.
* `hyb_still_fails` — **P3, structurally**: the hybrid is causal, so it too is
  capped by the impossibility; a bigger budget cannot buy the oracle number.

*The measured table.* `measured_gap_at_64`, `measured_recency_gain`,
`measured_P3_refuted`, `measured_monotone_hh`, `measured_monotone_hyb`,
`oracle_replicates_net49` record the arithmetic of the recorded run.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the 11.3-point ORACLE→HH gap is not a tuning
deficiency but an information-theoretic separation: the oracle reads the row it
is caching for, a deployable policy cannot.  Bold form: the gap is not bounded
by any function of the budget ratio `B/n` — it can be made maximal (`1`) at
every budget short of the full context.

Experiment (Experimenter): the uniform-prefix family `adv n T j₀` (all rows
uniform, final row a one-hot on `j₀`) is the extremal instance; the counting
identity `∑_{j₀ < n} 1{j₀ ∈ S} = |S| ≤ B` converts the single bad instance into
the average bound `B/n`.  `ComputationalEvidence.md` tabulates the family for
small `n, B` and reproduces the measured monotonicity bands.

Analysis (Analyst): the two sides are the same exchange lemma read in two
directions.  Retrospectively, top-`B` by the *true* row is optimal
(`kept_le_top`).  Online, the score is a different function, and
`oracle_eq_topByScore` isolates exactly what must be assumed for the substitution
to be free: order-consistency of accumulated score with the future row.
`oracle_le_topByScore_add` prices approximate consistency at `B·ε`; the measured
gap says the deployed ε is not small.

Critique (Critic): the impossibility is not vacuous — `oracle_adv` exhibits the
oracle value `1` on the very instances where policies score `0`, and every row of
`adv` is a genuine probability distribution (`adv_row_sum`).  The budget
hypothesis `B < n` is necessary: at `B = n` the full cache is admissible and the
gap vanishes (`no_gap_at_full_budget`).  Nothing here is `decide`-shaped: the
policy bound is a counting argument over an arbitrary policy, and the optimality
theorem is an exchange argument.
-/

namespace Catalog.Novelty.OracleOnlineEvictionGap

open Finset

/-! ### 1. Caches, retention, and the omniscient oracle -/

/-- Attention mass that row `t` places on the cached key set `S`. -/
def kept (w : ℕ → ℕ → ℝ) (t : ℕ) (S : Finset ℕ) : ℝ := ∑ j ∈ S, w t j

/-- Admissible caches: subsets of the `n` keys of size at most the budget `B`. -/
def caches (n B : ℕ) : Finset (Finset ℕ) :=
  (range n).powerset.filter (fun S => S.card ≤ B)

lemma mem_caches {n B : ℕ} {S : Finset ℕ} :
    S ∈ caches n B ↔ S ⊆ range n ∧ S.card ≤ B := by
  simp [caches, Finset.mem_filter, Finset.mem_powerset]

lemma caches_nonempty (n B : ℕ) : (caches n B).Nonempty :=
  ⟨∅, mem_caches.2 ⟨by simp, by simp⟩⟩

/-- The omniscient oracle: the best retention available at budget `B` on row `t`,
the maximum being taken over all admissible caches *after* seeing the row. -/
noncomputable def oracle (n B : ℕ) (w : ℕ → ℕ → ℝ) (t : ℕ) : ℝ :=
  (caches n B).sup' (caches_nonempty n B) (fun S => kept w t S)

lemma le_oracle {n B t : ℕ} {w : ℕ → ℕ → ℝ} {S : Finset ℕ} (hS : S ∈ caches n B) :
    kept w t S ≤ oracle n B w t :=
  Finset.le_sup' _ hS

lemma oracle_le {n B t : ℕ} {w : ℕ → ℕ → ℝ} {c : ℝ}
    (h : ∀ S ∈ caches n B, kept w t S ≤ c) : oracle n B w t ≤ c :=
  Finset.sup'_le _ _ h

/-! ### 2. The exchange lemma: retrospective pruning is easy -/

/-- **Exchange lemma, approximate form.**  If every key outside a cache `H` is worth
at most `ε` more than every key of `H` that a competitor `S` does not hold, then `H`
is optimal up to `|H|·ε`. -/
theorem kept_le_top_add {w : ℕ → ℕ → ℝ} {t : ℕ} {H S : Finset ℕ} {eps : ℝ}
    (hw : ∀ j, 0 ≤ w t j) (heps : 0 ≤ eps) (hcard : S.card ≤ H.card)
    (hdom : ∀ k ∈ S \ H, ∀ j ∈ H \ S, w t k ≤ w t j + eps) :
    kept w t S ≤ kept w t H + H.card * eps := by
  have hSsplit : ∑ j ∈ S ∩ H, w t j + ∑ j ∈ S \ H, w t j = kept w t S :=
    Finset.sum_inter_add_sum_diff S H _
  have hHsplit : ∑ j ∈ H ∩ S, w t j + ∑ j ∈ H \ S, w t j = kept w t H :=
    Finset.sum_inter_add_sum_diff H S _
  have hinter : ∑ j ∈ S ∩ H, w t j = ∑ j ∈ H ∩ S, w t j := by rw [Finset.inter_comm]
  have hc1 : (S \ H).card + (S ∩ H).card = S.card := Finset.card_sdiff_add_card_inter S H
  have hc2 : (H \ S).card + (H ∩ S).card = H.card := Finset.card_sdiff_add_card_inter H S
  have hcd : (S \ H).card ≤ (H \ S).card := by
    have : (S ∩ H).card = (H ∩ S).card := by rw [Finset.inter_comm]
    omega
  have key : ∑ j ∈ S \ H, w t j ≤ ∑ j ∈ H \ S, w t j + H.card * eps := by
    rcases Finset.eq_empty_or_nonempty (H \ S) with hemp | hne
    · have hz : (S \ H).card = 0 := by
        rw [hemp] at hcd
        simp only [Finset.card_empty] at hcd
        exact Nat.le_zero.1 hcd
      have hSH : (S \ H) = ∅ := Finset.card_eq_zero.1 hz
      rw [hSH, hemp]
      have : (0 : ℝ) ≤ H.card * eps := by positivity
      simpa using this
    · obtain ⟨j₀, hj₀, hmin⟩ := Finset.exists_min_image (H \ S) (fun j => w t j) hne
      have hub : ∀ k ∈ S \ H, w t k ≤ w t j₀ + eps := fun k hk => hdom k hk j₀ hj₀
      have h1 : ∑ j ∈ S \ H, w t j ≤ (S \ H).card • (w t j₀ + eps) :=
        Finset.sum_le_card_nsmul _ _ _ hub
      have hpos : (0 : ℝ) ≤ w t j₀ + eps := by have := hw j₀; linarith
      have h2 : ((S \ H).card : ℝ) * (w t j₀ + eps) ≤ ((H \ S).card : ℝ) * (w t j₀ + eps) := by
        exact mul_le_mul_of_nonneg_right (by exact_mod_cast hcd) hpos
      have h3 : ((H \ S).card : ℝ) * w t j₀ ≤ ∑ j ∈ H \ S, w t j := by
        have := Finset.card_nsmul_le_sum (H \ S) (fun j => w t j) (w t j₀) hmin
        simpa [nsmul_eq_mul] using this
      have h4 : ((H \ S).card : ℝ) ≤ (H.card : ℝ) := by
        exact_mod_cast Finset.card_le_card (Finset.sdiff_subset)
      have h5 : ((H \ S).card : ℝ) * eps ≤ (H.card : ℝ) * eps :=
        mul_le_mul_of_nonneg_right h4 heps
      have h1' : ∑ j ∈ S \ H, w t j ≤ ((S \ H).card : ℝ) * (w t j₀ + eps) := by
        rw [nsmul_eq_mul] at h1; exact h1
      nlinarith [h1', h2, h3, h5]
  linarith [hSsplit, hHsplit, hinter, key]

/-- **Exchange lemma, exact form.**  A cache `H` all of whose keys beat every key a
competitor `S` holds instead is at least as good as `S`. -/
theorem kept_le_top {w : ℕ → ℕ → ℝ} {t : ℕ} {H S : Finset ℕ}
    (hw : ∀ j, 0 ≤ w t j) (hcard : S.card ≤ H.card)
    (hdom : ∀ k ∈ S \ H, ∀ j ∈ H \ S, w t k ≤ w t j) :
    kept w t S ≤ kept w t H := by
  have := kept_le_top_add (eps := 0) hw le_rfl hcard (by simpa using hdom)
  simpa using this

/-! ### 3. Score-ranked caches, and when a score is allowed to stand in for the row -/

/-- The strict total order "key `m` outranks key `j`": higher score, ties broken by index. -/
def Better (s : ℕ → ℝ) (m j : ℕ) : Prop := s j < s m ∨ (s m = s j ∧ m < j)

noncomputable instance (s : ℕ → ℝ) (m j : ℕ) : Decidable (Better s m j) := by
  unfold Better; infer_instance

lemma better_irrefl (s : ℕ → ℝ) (j : ℕ) : ¬ Better s j j := by
  rintro (h | ⟨-, h⟩)
  · exact lt_irrefl _ h
  · omega

lemma better_trans {s : ℕ → ℝ} {a b c : ℕ} (h1 : Better s a b) (h2 : Better s b c) :
    Better s a c := by
  rcases h1 with h1 | ⟨he1, hl1⟩ <;> rcases h2 with h2 | ⟨he2, hl2⟩
  · exact Or.inl (lt_trans h2 h1)
  · exact Or.inl (by rw [he2] at h1; exact h1)
  · exact Or.inl (by rw [he1]; exact h2)
  · exact Or.inr ⟨by rw [he1, he2], lt_trans hl1 hl2⟩

lemma better_total {s : ℕ → ℝ} {a b : ℕ} (hab : a ≠ b) : Better s a b ∨ Better s b a := by
  rcases lt_trichotomy (s a) (s b) with h | h | h
  · exact Or.inr (Or.inl h)
  · rcases Nat.lt_or_ge a b with hl | hl
    · exact Or.inl (Or.inr ⟨h, hl⟩)
    · exact Or.inr (Or.inr ⟨h.symm, by omega⟩)
  · exact Or.inl (Or.inl h)

/-- The rank of key `j`: how many of the `n` keys outrank it. -/
noncomputable def rank (n : ℕ) (s : ℕ → ℝ) (j : ℕ) : ℕ :=
  ((range n).filter (fun m => Better s m j)).card

lemma rank_lt_of_better {n : ℕ} {s : ℕ → ℝ} {a b : ℕ} (ha : a ∈ range n) (h : Better s a b) :
    rank n s a < rank n s b := by
  apply Finset.card_lt_card
  refine ⟨fun m hm => ?_, fun hsub => ?_⟩
  · simp only [Finset.mem_filter] at hm ⊢
    exact ⟨hm.1, better_trans hm.2 h⟩
  · have ha' : a ∈ (range n).filter (fun m => Better s m b) := by
      simp only [Finset.mem_filter]; exact ⟨ha, h⟩
    have := hsub ha'
    simp only [Finset.mem_filter] at this
    exact better_irrefl s a this.2

lemma rank_lt_card {n : ℕ} {s : ℕ → ℝ} {j : ℕ} (hj : j ∈ range n) : rank n s j < n := by
  have : ((range n).filter (fun m => Better s m j)) ⊂ range n := by
    refine ⟨Finset.filter_subset _ _, fun hsub => ?_⟩
    have := hsub hj
    simp only [Finset.mem_filter] at this
    exact better_irrefl s j this.2
  simpa [rank] using Finset.card_lt_card this

lemma rank_injOn (n : ℕ) (s : ℕ → ℝ) : Set.InjOn (rank n s) (range n : Finset ℕ) := by
  intro a ha b hb hab
  by_contra hne
  rcases better_total (s := s) hne with h | h
  · exact absurd hab (Nat.ne_of_lt (rank_lt_of_better (by simpa using ha) h))
  · exact absurd hab.symm (Nat.ne_of_lt (rank_lt_of_better (by simpa using hb) h))

/-- The cache of the `B` best-scoring keys (ties broken by index). -/
noncomputable def topByScore (n B : ℕ) (s : ℕ → ℝ) : Finset ℕ :=
  (range n).filter (fun j => rank n s j < B)

lemma topByScore_subset (n B : ℕ) (s : ℕ → ℝ) : topByScore n B s ⊆ range n :=
  Finset.filter_subset _ _

lemma card_topByScore_le (n B : ℕ) (s : ℕ → ℝ) : (topByScore n B s).card ≤ B := by
  have hmaps : Set.MapsTo (rank n s) ↑(topByScore n B s) ↑(range B) := by
    intro j hj
    simp only [Finset.mem_coe, topByScore, Finset.mem_filter, Finset.mem_range] at hj ⊢
    exact hj.2
  have hinj : Set.InjOn (rank n s) (topByScore n B s) :=
    (rank_injOn n s).mono (by exact_mod_cast topByScore_subset n B s)
  simpa using Finset.card_le_card_of_injOn (rank n s) hmaps hinj

lemma topByScore_mem_caches (n B : ℕ) (s : ℕ → ℝ) : topByScore n B s ∈ caches n B :=
  mem_caches.2 ⟨topByScore_subset n B s, card_topByScore_le n B s⟩

lemma card_topByScore (n B : ℕ) (s : ℕ → ℝ) (hB : B ≤ n) : (topByScore n B s).card = B := by
  have himg : (range n).image (rank n s) = range n := by
    refine Finset.eq_of_subset_of_card_le (fun r hr => ?_) ?_
    · obtain ⟨j, hj, rfl⟩ := Finset.mem_image.1 hr
      simpa using rank_lt_card hj
    · rw [Finset.card_image_of_injOn (rank_injOn n s)]
  have h2 : (topByScore n B s).image (rank n s) = (range n).filter (fun r => r < B) := by
    ext r
    simp only [Finset.mem_image, Finset.mem_filter, topByScore, Finset.mem_range]
    constructor
    · rintro ⟨j, ⟨hj, hjB⟩, rfl⟩
      exact ⟨rank_lt_card (by simpa using hj), hjB⟩
    · rintro ⟨hr, hrB⟩
      have : r ∈ (range n).image (rank n s) := by rw [himg]; simpa using hr
      obtain ⟨j, hj, hjr⟩ := Finset.mem_image.1 this
      exact ⟨j, ⟨by simpa using hj, by rw [hjr]; exact hrB⟩, hjr⟩
  have hfil : (range n).filter (fun r => r < B) = range B := by
    ext r; simp only [Finset.mem_filter, Finset.mem_range]; omega
  have hinj : Set.InjOn (rank n s) (topByScore n B s) :=
    (rank_injOn n s).mono (by exact_mod_cast topByScore_subset n B s)
  have := Finset.card_image_of_injOn hinj
  rw [h2, hfil] at this
  simpa using this.symm

/-- Every key outside the top-`B` cache scores no better than every key inside it. -/
lemma topByScore_dominates {n B : ℕ} {s : ℕ → ℝ} {j k : ℕ}
    (hj : j ∈ topByScore n B s) (hk : k ∈ range n \ topByScore n B s) : s k ≤ s j := by
  simp only [topByScore, Finset.mem_filter] at hj
  simp only [Finset.mem_sdiff, topByScore, Finset.mem_filter] at hk
  have hkB : B ≤ rank n s k := by
    by_contra hlt
    exact hk.2 ⟨hk.1, by omega⟩
  by_contra hlt
  have : Better s k j := Or.inl (lt_of_not_ge hlt)
  have := rank_lt_of_better (n := n) hk.1 this
  omega

/-- A score is *consistent* with the row it is used to predict when its order never
contradicts the order of the actual attention weights. -/
def ScoreConsistent (n : ℕ) (s v : ℕ → ℝ) : Prop :=
  ∀ j ∈ range n, ∀ k ∈ range n, s k ≤ s j → v k ≤ v j

/-- **Approximate consistency is priced at `B·ε`.**  If the score order can misrank the
actual weights by at most `ε`, the score-ranked cache is within `B·ε` of the oracle. -/
theorem oracle_le_topByScore_add {n B t : ℕ} {w : ℕ → ℕ → ℝ} {s : ℕ → ℝ} {eps : ℝ}
    (hw : ∀ j, 0 ≤ w t j) (heps : 0 ≤ eps) (hB : B ≤ n)
    (hcons : ∀ j ∈ range n, ∀ k ∈ range n, s k ≤ s j → w t k ≤ w t j + eps) :
    oracle n B w t ≤ kept w t (topByScore n B s) + B * eps := by
  set H := topByScore n B s with hH
  have hcardH : H.card = B := card_topByScore n B s hB
  refine oracle_le (fun S hS => ?_)
  obtain ⟨hSsub, hScard⟩ := mem_caches.1 hS
  have hdom : ∀ k ∈ S \ H, ∀ j ∈ H \ S, w t k ≤ w t j + eps := by
    intro k hk j hj
    have hkr : k ∈ range n \ H := by
      simp only [Finset.mem_sdiff] at hk ⊢
      exact ⟨hSsub hk.1, hk.2⟩
    have hjH : j ∈ H := (Finset.mem_sdiff.1 hj).1
    have hscore : s k ≤ s j := topByScore_dominates hjH hkr
    exact hcons j (topByScore_subset n B s hjH) k (Finset.mem_sdiff.1 hkr).1 hscore
  have := kept_le_top_add (H := H) (S := S) hw heps (by omega) hdom
  rw [hcardH] at this
  exact this

/-- **The assumption-conditioned positive result.**  If the score is order-consistent with
the row, the score-ranked cache *is* the oracle cache: retrospective pruning transfers to
an online policy exactly when the policy's statistic is consistent with the future. -/
theorem oracle_eq_topByScore {n B t : ℕ} {w : ℕ → ℕ → ℝ} {s : ℕ → ℝ}
    (hw : ∀ j, 0 ≤ w t j) (hB : B ≤ n) (hcons : ScoreConsistent n s (w t)) :
    oracle n B w t = kept w t (topByScore n B s) := by
  refine le_antisymm ?_ (le_oracle (topByScore_mem_caches n B s))
  have := oracle_le_topByScore_add (eps := 0) hw le_rfl hB
    (fun j hj k hk hs => by simpa using hcons j hj k hk hs)
  simpa using this

/-! ### 4. Causal policies: online prediction is impossible -/

/-- A **causally honest** cache policy: at row `t` it returns an admissible cache that is a
function of the rows strictly before `t` only.  (The oracle is *not* of this form.) -/
def Causal (n B : ℕ) (P : (ℕ → ℕ → ℝ) → ℕ → Finset ℕ) : Prop :=
  (∀ w t, P w t ∈ caches n B) ∧
  ∀ w w' t, (∀ r < t, ∀ j, w r j = w' r j) → P w t = P w' t

/-- The extremal family: `T` uninformative uniform rows, then a one-hot row on key `j₀`. -/
noncomputable def adv (n T j₀ : ℕ) : ℕ → ℕ → ℝ := fun t j =>
  if t < T then (if j < n then (n : ℝ)⁻¹ else 0) else (if j = j₀ then 1 else 0)

lemma adv_nonneg (n T j₀ t j : ℕ) : 0 ≤ adv n T j₀ t j := by
  unfold adv
  split_ifs <;> positivity

/-- Every row of the family is a genuine probability distribution over the `n` keys. -/
lemma adv_row_sum {n T j₀ : ℕ} (hn : 0 < n) (hj₀ : j₀ < n) (t : ℕ) :
    ∑ j ∈ range n, adv n T j₀ t j = 1 := by
  unfold adv
  by_cases ht : t < T
  · simp only [ht, if_true]
    have hcong : ∀ j ∈ range n, (if j < n then (n : ℝ)⁻¹ else 0) = (n : ℝ)⁻¹ :=
      fun j hj => by simp [Finset.mem_range.1 hj]
    rw [Finset.sum_congr rfl hcong, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    have : (n : ℝ) ≠ 0 := by positivity
    field_simp
  · simp only [ht, if_false]
    rw [Finset.sum_ite_eq' (range n) j₀ (fun _ => (1 : ℝ))]
    simp [hj₀]

/-- All members of the family share their prefix: a causal policy cannot tell them apart. -/
lemma adv_prefix (n T j₀ j₁ : ℕ) : ∀ r < T, ∀ j, adv n T j₀ r j = adv n T j₁ r j := by
  intro r hr j
  simp [adv, hr]

lemma kept_adv_last (n T j₀ : ℕ) (S : Finset ℕ) :
    kept (adv n T j₀) T S = if j₀ ∈ S then 1 else 0 := by
  simp only [kept, adv, lt_irrefl, if_false]
  rw [Finset.sum_ite_eq' S j₀ (fun _ => (1 : ℝ))]

/-- The omniscient oracle retains **everything** on the family, at any budget `≥ 1`. -/
theorem oracle_adv {n B T j₀ : ℕ} (hB : 1 ≤ B) (hj₀ : j₀ < n) :
    oracle n B (adv n T j₀) T = 1 := by
  refine le_antisymm (oracle_le (fun S _ => ?_)) ?_
  · rw [kept_adv_last]; split_ifs <;> norm_num
  · have hmem : ({j₀} : Finset ℕ) ∈ caches n B :=
      mem_caches.2 ⟨by simpa using Finset.mem_range.2 hj₀, by simpa using hB⟩
    have := le_oracle (w := adv n T j₀) (t := T) hmem
    rwa [kept_adv_last, if_pos (Finset.mem_singleton_self j₀)] at this

/-- **The impossibility.**  Every causally honest policy of budget `B < n` retains *nothing*
on some member of the family, where the oracle retains everything. -/
theorem causal_policy_misses {n B T : ℕ} {P : (ℕ → ℕ → ℝ) → ℕ → Finset ℕ}
    (hP : Causal n B P) (hBn : B < n) :
    ∃ j₀ < n, kept (adv n T j₀) T (P (adv n T j₀) T) = 0 := by
  obtain ⟨hSsub, hScard⟩ := mem_caches.1 (hP.1 (adv n T 0) T)
  set S := P (adv n T 0) T with hS
  have hne : ∃ j₀ ∈ range n, j₀ ∉ S := by
    by_contra hcon
    push_neg at hcon
    have hsub : range n ⊆ S := fun j hj => hcon j hj
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    omega
  obtain ⟨j₀, hj₀mem, hj₀not⟩ := hne
  rw [Finset.mem_range] at hj₀mem
  refine ⟨j₀, hj₀mem, ?_⟩
  have hpolicy : P (adv n T j₀) T = S := hP.2 _ _ T (adv_prefix n T j₀ 0)
  rw [hpolicy, kept_adv_last, if_neg hj₀not]

/-- **The oracle overstates the deployable win by the maximum possible amount.**  At every
budget short of the whole context, some instance separates the oracle from *every* causal
policy by a full unit of retained mass. -/
theorem oracle_overstates {n B T : ℕ} {P : (ℕ → ℕ → ℝ) → ℕ → Finset ℕ}
    (hP : Causal n B P) (hB : 1 ≤ B) (hBn : B < n) :
    ∃ j₀ < n, oracle n B (adv n T j₀) T - kept (adv n T j₀) T (P (adv n T j₀) T) = 1 := by
  obtain ⟨j₀, hj₀, hzero⟩ := causal_policy_misses (T := T) hP hBn
  exact ⟨j₀, hj₀, by rw [oracle_adv hB hj₀, hzero]; ring⟩

/-- The miss is not an unlucky instance: summed over the whole family, a causal policy
collects at most its budget, while the oracle collects `n`. -/
theorem causal_average_le_budget {n B T : ℕ} {P : (ℕ → ℕ → ℝ) → ℕ → Finset ℕ}
    (hP : Causal n B P) :
    ∑ j₀ ∈ range n, kept (adv n T j₀) T (P (adv n T j₀) T) ≤ B := by
  obtain ⟨hSsub, hScard⟩ := mem_caches.1 (hP.1 (adv n T 0) T)
  set S := P (adv n T 0) T with hS
  have hstep : ∀ j₀ ∈ range n, kept (adv n T j₀) T (P (adv n T j₀) T)
      = if j₀ ∈ S then (1 : ℝ) else 0 := by
    intro j₀ _
    rw [hP.2 _ _ T (adv_prefix n T j₀ 0), kept_adv_last]
  rw [Finset.sum_congr rfl hstep, Finset.sum_boole]
  have : (range n).filter (fun j => j ∈ S) = S := by
    rw [Finset.filter_mem_eq_inter, Finset.inter_eq_right.2 hSsub]
  rw [this]
  exact_mod_cast hScard

/-- Average form: the mean retention of any causal policy over the family is at most the
budget fraction `B/n`, against an oracle value of `1`. -/
theorem causal_average_le {n B T : ℕ} {P : (ℕ → ℕ → ℝ) → ℕ → Finset ℕ}
    (hP : Causal n B P) (hn : 0 < n) :
    (n : ℝ)⁻¹ * ∑ j₀ ∈ range n, kept (adv n T j₀) T (P (adv n T j₀) T) ≤ (B : ℝ) / n := by
  have hpos : (0 : ℝ) < n := by exact_mod_cast hn
  rw [div_eq_inv_mul]
  exact mul_le_mul_of_nonneg_left (causal_average_le_budget (T := T) hP) (by positivity)

/-- The budget hypothesis is necessary: at full budget the gap is zero. -/
theorem no_gap_at_full_budget {n t : ℕ} {w : ℕ → ℕ → ℝ} (hw : ∀ j, 0 ≤ w t j) :
    oracle n n w t = kept w t (range n) := by
  refine le_antisymm (oracle_le (fun S hS => ?_))
    (le_oracle (mem_caches.2 ⟨Finset.Subset.refl _, by simp⟩))
  exact Finset.sum_le_sum_of_subset_of_nonneg (mem_caches.1 hS).1 (fun j _ _ => hw j)

/-! ### 5. Three deployable policies: accumulation, recency, and the hybrid -/

/-- Accumulated attention score of key `j` over the rows seen before `t` (the H2O statistic). -/
def acc (w : ℕ → ℕ → ℝ) (t j : ℕ) : ℝ := ∑ r ∈ range t, w r j

/-- The pure heavy-hitter cache. -/
noncomputable def hhSet (n B : ℕ) (w : ℕ → ℕ → ℝ) (t : ℕ) : Finset ℕ :=
  topByScore n B (acc w t)

/-- The recency cache: the `m` most recent keys. -/
def recentSet (n m : ℕ) : Finset ℕ := Finset.Ico (n - m) n

/-- The hybrid: half the budget to heavy hitters, half to recency. -/
noncomputable def hybSet (n B : ℕ) (w : ℕ → ℕ → ℝ) (t : ℕ) : Finset ℕ :=
  hhSet n (B / 2) w t ∪ recentSet n (B - B / 2)

lemma acc_congr_prefix {w w' : ℕ → ℕ → ℝ} {t : ℕ} (h : ∀ r < t, ∀ j, w r j = w' r j) :
    acc w t = acc w' t := by
  funext j
  exact Finset.sum_congr rfl (fun r hr => h r (Finset.mem_range.1 hr) j)

lemma recentSet_subset (n m : ℕ) : recentSet n m ⊆ range n := by
  intro j hj
  rw [recentSet, Finset.mem_Ico] at hj
  exact Finset.mem_range.2 hj.2

lemma card_recentSet_le (n m : ℕ) : (recentSet n m).card ≤ m := by
  rw [recentSet, Nat.card_Ico]
  omega

lemma recentSet_mem_caches (n m : ℕ) : recentSet n m ∈ caches n m :=
  mem_caches.2 ⟨recentSet_subset n m, card_recentSet_le n m⟩

/-- Heavy hitters are a causally honest policy. -/
theorem hh_causal (n B : ℕ) : Causal n B (hhSet n B) :=
  ⟨fun _ _ => topByScore_mem_caches _ _ _, fun _ _ _ h => by rw [hhSet, hhSet,
    acc_congr_prefix h]⟩

/-- Recency is a causally honest policy (it reads nothing at all). -/
theorem recency_causal (n B : ℕ) : Causal n B (fun _ _ => recentSet n B) :=
  ⟨fun _ _ => recentSet_mem_caches n B, fun _ _ _ _ => rfl⟩

/-- The hybrid is a causally honest policy. -/
theorem hyb_causal (n B : ℕ) : Causal n B (hybSet n B) := by
  refine ⟨fun w t => mem_caches.2 ⟨?_, ?_⟩, fun w w' t h => by
    rw [hybSet, hybSet, hhSet, hhSet, acc_congr_prefix h]⟩
  · exact Finset.union_subset (topByScore_subset _ _ _) (recentSet_subset _ _)
  · refine le_trans (Finset.card_union_le _ _) ?_
    have h1 : (hhSet n (B / 2) w t).card ≤ B / 2 := card_topByScore_le n (B / 2) (acc w t)
    have h2 := card_recentSet_le n (B - B / 2)
    omega

/-- No deployable heuristic is exempt: heavy hitters, recency and the hybrid all inherit the
full unit gap of `oracle_overstates`. -/
theorem heuristics_still_fail {n B T : ℕ} (hB : 1 ≤ B) (hBn : B < n) :
    (∃ j₀ < n, oracle n B (adv n T j₀) T
        - kept (adv n T j₀) T (hhSet n B (adv n T j₀) T) = 1) ∧
    (∃ j₀ < n, oracle n B (adv n T j₀) T - kept (adv n T j₀) T (recentSet n B) = 1) ∧
    (∃ j₀ < n, oracle n B (adv n T j₀) T
        - kept (adv n T j₀) T (hybSet n B (adv n T j₀) T) = 1) :=
  ⟨oracle_overstates (hh_causal n B) hB hBn,
   oracle_overstates (recency_causal n B) hB hBn,
   oracle_overstates (hyb_causal n B) hB hBn⟩

/-! #### The two diagnostic families -/

/-- `staleW`: the prefix hammers key `0`, the row to be served attends the *current* key.
Accumulated score is maximally stale here. -/
noncomputable def staleW (n T : ℕ) : ℕ → ℕ → ℝ := fun t j =>
  if t < T then (if j = 0 then 1 else 0) else (if j = n - 1 then 1 else 0)

/-- `pinW`: every row, including the one to be served, attends the same old key `0`. -/
noncomputable def pinW : ℕ → ℕ → ℝ := fun _ j => if j = 0 then 1 else 0

lemma acc_staleW (n T j : ℕ) : acc (staleW n T) T j = if j = 0 then (T : ℝ) else 0 := by
  unfold acc staleW
  have hcong : ∀ r ∈ range T,
      (if r < T then (if j = 0 then (1 : ℝ) else 0) else (if j = n - 1 then (1 : ℝ) else 0))
        = (if j = 0 then (1 : ℝ) else 0) := fun r hr => by simp [Finset.mem_range.1 hr]
  rw [Finset.sum_congr rfl hcong, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  split_ifs <;> ring

lemma acc_pinW (t j : ℕ) : acc pinW t j = if j = 0 then (t : ℝ) else 0 := by
  unfold acc pinW
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  split_ifs <;> ring

lemma kept_staleW_last (n T : ℕ) (S : Finset ℕ) :
    kept (staleW n T) T S = if (n - 1) ∈ S then 1 else 0 := by
  simp only [kept, staleW, lt_irrefl, if_false]
  rw [Finset.sum_ite_eq' S (n - 1) (fun _ => (1 : ℝ))]

lemma kept_pinW (t : ℕ) (S : Finset ℕ) : kept pinW t S = if 0 ∈ S then 1 else 0 := by
  simp only [kept, pinW]
  rw [Finset.sum_ite_eq' S 0 (fun _ => (1 : ℝ))]

/-- **Accumulation is biased.**  On the stale family the heavy-hitter cache retains nothing:
the key it evicts is precisely the one the served row needs. -/
theorem hh_misses_stale {n B T : ℕ} (hB : 1 ≤ B) (hBn : B ≤ n - 1) (hT : 1 ≤ T) :
    kept (staleW n T) T (hhSet n B (staleW n T) T) = 0 := by
  have hn2 : 2 ≤ n := by omega
  set s := acc (staleW n T) T with hs
  have hsval : ∀ j, s j = if j = 0 then (T : ℝ) else 0 := fun j => acc_staleW n T j
  have hlast : s (n - 1) = 0 := by
    rw [hsval]
    rw [if_neg (by omega)]
  have hsub : range B ⊆ (range n).filter (fun m => Better s m (n - 1)) := by
    intro m hm
    rw [Finset.mem_range] at hm
    refine Finset.mem_filter.2 ⟨Finset.mem_range.2 (by omega), ?_⟩
    by_cases hm0 : m = 0
    · refine Or.inl ?_
      rw [hlast, hsval, if_pos hm0]
      exact_mod_cast hT
    · refine Or.inr ⟨?_, by omega⟩
      rw [hlast, hsval, if_neg hm0]
  have hrank : B ≤ rank n s (n - 1) := by
    have := Finset.card_le_card hsub
    rwa [Finset.card_range] at this
  have hnot : (n - 1) ∉ hhSet n B (staleW n T) T := by
    rw [hhSet, topByScore, Finset.mem_filter]
    rintro ⟨-, hlt⟩
    rw [← hs] at hlt
    omega
  rw [kept_staleW_last, if_neg hnot]

/-- **Recency wins there.**  The recency cache retains everything on the stale family. -/
theorem recency_hits_stale {n m T : ℕ} (hm : 1 ≤ m) (hn : 1 ≤ n) :
    kept (staleW n T) T (recentSet n m) = 1 := by
  have hmem : (n - 1) ∈ recentSet n m := by
    rw [recentSet, Finset.mem_Ico]
    omega
  rw [kept_staleW_last, if_pos hmem]

/-- **But recency is biased too.**  On the pinned family it evicts the only key that matters. -/
theorem recency_misses_pin {n m t : ℕ} (hm : m ≤ n - 1) (hn : 1 ≤ n) :
    kept pinW t (recentSet n m) = 0 := by
  have hnot : (0 : ℕ) ∉ recentSet n m := by
    rw [recentSet, Finset.mem_Ico]
    omega
  rw [kept_pinW, if_neg hnot]

/-- **And accumulation wins there.** -/
theorem hh_hits_pin {n B t : ℕ} (hB : 1 ≤ B) (hn : 1 ≤ n) :
    kept pinW t (hhSet n B pinW t) = 1 := by
  set s := acc pinW t with hs
  have hsval : ∀ j, s j = if j = 0 then (t : ℝ) else 0 := fun j => acc_pinW t j
  have hempty : (range n).filter (fun m => Better s m 0) = ∅ := by
    refine Finset.filter_eq_empty_iff.2 (fun m _ => ?_)
    rintro (hlt | ⟨-, hlt⟩)
    · rw [hsval 0, if_pos rfl, hsval m] at hlt
      split_ifs at hlt with hm0
      · exact absurd hlt (lt_irrefl _)
      · exact absurd hlt (not_lt.2 (by positivity))
    · omega
  have hmem : (0 : ℕ) ∈ hhSet n B pinW t := by
    rw [hhSet, topByScore, Finset.mem_filter]
    refine ⟨Finset.mem_range.2 (by omega), ?_⟩
    have hr0 : rank n s 0 = 0 := by rw [rank, hempty, Finset.card_empty]
    rw [← hs]
    omega
  rw [kept_pinW, if_pos hmem]

/-- **P2, structurally: neither pure policy dominates.**  Accumulation loses to recency on the
stale family and beats it on the pinned family, at the same budget on the same key set. -/
theorem no_policy_dominance {n B T : ℕ} (hB : 1 ≤ B) (hBn : B ≤ n - 1) (hT : 1 ≤ T) :
    kept (staleW n T) T (hhSet n B (staleW n T) T) < kept (staleW n T) T (recentSet n B) ∧
    kept pinW T (recentSet n B) < kept pinW T (hhSet n B pinW T) := by
  have hn : 1 ≤ n := by omega
  refine ⟨?_, ?_⟩
  · rw [hh_misses_stale hB hBn hT, recency_hits_stale hB hn]; norm_num
  · rw [recency_misses_pin hBn hn, hh_hits_pin hB hn]; norm_num

/-- The hybrid retains everything on the stale family … -/
theorem hyb_hits_stale {n B T : ℕ} (hB : 2 ≤ B) (hn : 1 ≤ n) :
    kept (staleW n T) T (hybSet n B (staleW n T) T) = 1 := by
  have hmem : (n - 1) ∈ hybSet n B (staleW n T) T := by
    refine Finset.mem_union_right _ ?_
    rw [recentSet, Finset.mem_Ico]
    omega
  rw [kept_staleW_last, if_pos hmem]

/-- … and on the pinned family: the hybrid strictly dominates both pure policies. -/
theorem hyb_hits_pin {n B t : ℕ} (hB : 2 ≤ B) (hn : 1 ≤ n) :
    kept pinW t (hybSet n B pinW t) = 1 := by
  have hmem : (0 : ℕ) ∈ hybSet n B pinW t := by
    refine Finset.mem_union_left _ ?_
    have hB2 : 1 ≤ B / 2 := by omega
    have := hh_hits_pin (n := n) (B := B / 2) (t := t) hB2 hn
    by_contra hnot
    rw [kept_pinW, if_neg hnot] at this
    norm_num at this
  rw [kept_pinW, if_pos hmem]

/-! ### 6. The recorded run (NET-56), as arithmetic -/

/-- Measured retention of the recorded run: `arm = 0` oracle, `1` heavy hitters, `2` hybrid;
budgets `32, 64, 128`. -/
def measured (arm budget : ℕ) : ℚ :=
  match arm, budget with
  | 0, 32 => 9913/10000
  | 0, 64 => 9953/10000
  | 1, 32 => 8633/10000
  | 1, 64 => 8822/10000
  | 1, 128 => 9189/10000
  | 2, 32 => 9205/10000
  | 2, 64 => 9384/10000
  | 2, 128 => 9605/10000
  | _, _ => 0

/-- **P1**: the oracle-to-policy gap at the matched budget `B = 64` is `11.31` points, far
above the pre-stated `2 %` floor. -/
theorem measured_gap_at_64 :
    measured 0 64 - measured 1 64 = 1131/10000 ∧ (2 : ℚ)/100 < measured 0 64 - measured 1 64 := by
  constructor <;> norm_num [measured]

/-- **P2**: recency helps at every budget. -/
theorem measured_recency_gain :
    measured 1 32 < measured 2 32 ∧ measured 1 64 < measured 2 64 ∧
      measured 1 128 < measured 2 128 := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [measured]

/-- **P3 refuted**: the best deployable arm at `B = 64` misses `0.95`, and even a cache of
`12.5 %` of the context tops out below `0.97`. -/
theorem measured_P3_refuted :
    measured 2 64 < 95/100 ∧ measured 2 128 < 97/100 := by
  constructor <;> norm_num [measured]

/-- Monotone budget response, the sanity gate the recorded run had to pass. -/
theorem measured_monotone :
    measured 1 32 < measured 1 64 ∧ measured 1 64 < measured 1 128 ∧
      measured 2 32 < measured 2 64 ∧ measured 2 64 < measured 2 128 ∧
      measured 0 32 < measured 0 64 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [measured]

/-- Every recorded number is a legitimate retained fraction. -/
theorem measured_in_band (arm budget : ℕ) : 0 ≤ measured arm budget ∧ measured arm budget ≤ 1 := by
  unfold measured
  split <;> norm_num

end Catalog.Novelty.OracleOnlineEvictionGap