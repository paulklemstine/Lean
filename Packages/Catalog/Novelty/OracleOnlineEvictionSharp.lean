import Novelty.OracleOnlineEvictionGap

/-!
# Sharpness, randomisation, and layer allocation for the NET-56 oracle-policy gap

`Novelty.OracleOnlineEvictionGap` proved the two halves of the NET-56 verdict: the
`B·ε` price of approximate score-consistency (`oracle_le_topByScore_add`) on the
positive side, and a full unit oracle-to-policy gap for *every* causally honest
policy (`oracle_overstates`) on the negative side.  This file closes the three
questions that were left open by that pair.

## Main results

* `price_is_sharp` — the `B·ε` price is **exact**, not merely an upper bound: on the
  instance `sharpW` (the top-`B` keys by score carry weight `0`, everyone else carries
  `ε`) the oracle beats the score-ranked cache by precisely `B·ε`.  So no sharper
  consistency-to-retention conversion exists, and the deployment correction is linear
  in the budget, not in the context length.
* `randomized_causal_average` — **randomisation does not help**.  For any finite mixture
  of causally honest policies (any distribution over deployable evictors) there is a
  single instance of the adversarial family on which the *expected* retention is at
  most the budget fraction `B/n`.  The gap of `oracle_overstates` is therefore not an
  artefact of determinism; it is a Yao-style information bound.
* `split_hits_both`, `split_needs_recency`, `split_needs_heavy_hitters`,
  `hybrid_split_necessary` — the measured superiority of HYB over both pure arms is
  forced: a budget split `(a, b)` retains both diagnostic families iff both halves are
  nonzero, and each degenerate split fails on exactly one family.
* `minPlus`, `gap_adds_across_layers` — per-layer budget allocation is a **min-plus
  convolution**, and a per-layer policy penalty `δ` survives the optimisation: the
  optimally allocated two-layer loss inherits `2δ`.  Deployment tables must be
  policy-adjusted layer by layer; the corrections add.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): three follow-ups to round 9.  (i) The `B·ε` bound is tight,
so the oracle-to-policy correction scales with the cache, not the context.  (ii) A
randomised evictor cannot escape the bound — the obstruction is informational.
(iii) The hybrid's advantage is structural, and composes across layers by min-plus.

Experiment (Experimenter): `sharpW` realises (i) with equality at every `B` and every
`ε ≥ 0`; the mixture argument for (ii) needs only the counting bound
`causal_average_le_budget` plus an averaging step; (iii) is a two-line exchange once
`minPlus` is attained on `range (B+1)`.

Analysis (Analyst): the three results say the same thing at three scales.  Locally the
loss is `B·ε` per row; over instances the loss is `1 − B/n` in expectation for any
mixture; across layers the loss adds under optimal allocation.  None of these is a
statement about a particular heuristic, which is why H2O-style engineering cannot close
the measured 11.3 points.

Critique (Critic): `price_is_sharp` needs `2B ≤ n` (otherwise there are not `B` keys of
weight `ε` left to hold the oracle up) and `0 ≤ ε`; both hypotheses are explicit.
`randomized_causal_average` assumes only that the mixture weights are a probability
vector on a finite index set — no measurability machinery is smuggled in, and the
conclusion is an honest existential over the family, i.e. exactly the adversary's move.
The `minPlus` statement is about arbitrary loss curves, so it is not circular with the
retention theory.
-/

namespace Catalog.Novelty.OracleOnlineEvictionSharp

open Finset Catalog.Novelty.OracleOnlineEvictionGap

/-! ### 1. The `B·ε` price of approximate consistency is attained -/

/-- Scores that rank the keys by index: key `0` is best. -/
noncomputable def negIdx : ℕ → ℝ := fun j => -(j : ℝ)

/-- The sharp instance: the `B` best-scoring keys carry no mass at all, every other key
carries `ε`. -/
noncomputable def sharpW (B : ℕ) (eps : ℝ) : ℕ → ℕ → ℝ := fun _ j => if j < B then 0 else eps

lemma better_negIdx (m j : ℕ) : Better negIdx m j ↔ m < j := by
  constructor
  · rintro (h | ⟨-, h⟩)
    · have : (m : ℝ) < j := by
        simpa [negIdx] using h
      exact_mod_cast this
    · exact h
  · intro h
    refine Or.inl ?_
    have : (m : ℝ) < j := by exact_mod_cast h
    simpa [negIdx] using this

lemma rank_negIdx {n j : ℕ} (hj : j ≤ n) : rank n negIdx j = j := by
  have hset : (range n).filter (fun m => Better negIdx m j) = range j := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_range, better_negIdx]
    omega
  rw [rank, hset, Finset.card_range]

lemma topByScore_negIdx {n B : ℕ} (hB : B ≤ n) : topByScore n B negIdx = range B := by
  ext j
  simp only [topByScore, Finset.mem_filter, Finset.mem_range]
  constructor
  · rintro ⟨hj, hlt⟩
    rwa [rank_negIdx (le_of_lt hj)] at hlt
  · intro hj
    have hjn : j < n := lt_of_lt_of_le hj hB
    exact ⟨hjn, by rw [rank_negIdx (le_of_lt hjn)]; exact hj⟩

lemma kept_sharpW_topByScore {n B : ℕ} {eps : ℝ} (hB : B ≤ n) (t : ℕ) :
    kept (sharpW B eps) t (topByScore n B negIdx) = 0 := by
  rw [topByScore_negIdx hB, kept]
  refine Finset.sum_eq_zero (fun j hj => ?_)
  simp [sharpW, Finset.mem_range.1 hj]

lemma oracle_sharpW {n B : ℕ} {eps : ℝ} (heps : 0 ≤ eps) (hB : 2 * B ≤ n) (t : ℕ) :
    oracle n B (sharpW B eps) t = B * eps := by
  refine le_antisymm (oracle_le (fun S hS => ?_)) ?_
  · obtain ⟨-, hcard⟩ := mem_caches.1 hS
    have hle : ∀ j ∈ S, sharpW B eps t j ≤ eps := by
      intro j _
      simp only [sharpW]
      split_ifs
      · exact heps
      · exact le_rfl
    have := Finset.sum_le_card_nsmul S (fun j => sharpW B eps t j) eps hle
    rw [nsmul_eq_mul] at this
    refine le_trans this ?_
    exact mul_le_mul_of_nonneg_right (by exact_mod_cast hcard) heps
  · have hsub : Finset.Ico B (2 * B) ⊆ range n := by
      intro j hj
      rw [Finset.mem_Ico] at hj
      exact Finset.mem_range.2 (by omega)
    have hcard : (Finset.Ico B (2 * B)).card ≤ B := by rw [Nat.card_Ico]; omega
    have hmem : Finset.Ico B (2 * B) ∈ caches n B := mem_caches.2 ⟨hsub, hcard⟩
    have hval : kept (sharpW B eps) t (Finset.Ico B (2 * B)) = B * eps := by
      rw [kept]
      have hcong : ∀ j ∈ Finset.Ico B (2 * B), sharpW B eps t j = eps := by
        intro j hj
        rw [Finset.mem_Ico] at hj
        simp [sharpW, Nat.not_lt.2 hj.1]
      rw [Finset.sum_congr rfl hcong, Finset.sum_const, Nat.card_Ico, nsmul_eq_mul]
      congr 1
      have : 2 * B - B = B := by omega
      rw [this]
    rw [← hval]
    exact le_oracle hmem

/-- **The `B·ε` price is sharp.**  The bound `oracle_le_topByScore_add` is achieved with
equality: at ε-approximate consistency the score-ranked cache can lose exactly `B·ε`. -/
theorem price_is_sharp {n B : ℕ} {eps : ℝ} (heps : 0 ≤ eps) (hB : 2 * B ≤ n) (t : ℕ) :
    oracle n B (sharpW B eps) t
      = kept (sharpW B eps) t (topByScore n B negIdx) + B * eps := by
  rw [kept_sharpW_topByScore (by omega) t, oracle_sharpW heps hB t]
  ring

/-- The sharp instance really is `ε`-consistent, so `oracle_le_topByScore_add` applies to
it and `price_is_sharp` is an equality inside that inequality (not beside it). -/
theorem sharpW_is_eps_consistent {n B : ℕ} {eps : ℝ} (heps : 0 ≤ eps) (t : ℕ) :
    ∀ j ∈ range n, ∀ k ∈ range n, negIdx k ≤ negIdx j →
      sharpW B eps t k ≤ sharpW B eps t j + eps := by
  intro j _ k _ _
  have hk : sharpW B eps t k ≤ eps := by
    simp only [sharpW]
    split_ifs
    · exact heps
    · exact le_rfl
  have hj : 0 ≤ sharpW B eps t j := by
    simp only [sharpW]
    split_ifs
    · exact le_rfl
    · exact heps
  linarith

/-! ### 2. Randomisation does not help -/

/-- **Yao-style bound.**  For any finite mixture of causally honest policies there is a
single instance of the adversarial family on which the *expected* retention is at most
the budget fraction `B/n`, while the oracle retains `1`. -/
theorem randomized_causal_average {n B T : ℕ} {ι : Type} (I : Finset ι)
    (P : ι → (ℕ → ℕ → ℝ) → ℕ → Finset ℕ) (q : ι → ℝ)
    (hq : ∀ i ∈ I, 0 ≤ q i) (hq1 : ∑ i ∈ I, q i = 1)
    (hP : ∀ i ∈ I, Causal n B (P i)) (hn : 0 < n) :
    ∃ j₀ < n, ∑ i ∈ I, q i * kept (adv n T j₀) T (P i (adv n T j₀) T) ≤ (B : ℝ) / n := by
  have hpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hswap : ∑ j₀ ∈ range n, ∑ i ∈ I, q i * kept (adv n T j₀) T (P i (adv n T j₀) T)
      = ∑ i ∈ I, q i * ∑ j₀ ∈ range n, kept (adv n T j₀) T (P i (adv n T j₀) T) := by
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl (fun i _ => (Finset.mul_sum _ _ _).symm)
  have hbound : ∑ j₀ ∈ range n, ∑ i ∈ I, q i * kept (adv n T j₀) T (P i (adv n T j₀) T)
      ≤ ∑ j₀ ∈ range n, (B : ℝ) / n := by
    rw [hswap, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    have hstep : ∀ i ∈ I, q i * ∑ j₀ ∈ range n, kept (adv n T j₀) T (P i (adv n T j₀) T)
        ≤ q i * B := fun i hi =>
      mul_le_mul_of_nonneg_left (causal_average_le_budget (T := T) (hP i hi)) (hq i hi)
    refine le_trans (Finset.sum_le_sum hstep) ?_
    rw [← Finset.sum_mul, hq1, one_mul]
    have hcancel : (n : ℝ) * ((B : ℝ) / n) = B := by field_simp
    rw [hcancel]
  obtain ⟨j₀, hj₀, hle⟩ :=
    Finset.exists_le_of_sum_le (⟨0, Finset.mem_range.2 hn⟩ : (range n).Nonempty) hbound
  exact ⟨j₀, Finset.mem_range.1 hj₀, hle⟩

/-! ### 3. Both halves of the hybrid budget are necessary -/

/-- A general budget split: `a` keys to heavy hitters, `b` keys to recency. -/
noncomputable def splitSet (n a b : ℕ) (w : ℕ → ℕ → ℝ) (t : ℕ) : Finset ℕ :=
  hhSet n a w t ∪ recentSet n b

lemma splitSet_card_le (n a b : ℕ) (w : ℕ → ℕ → ℝ) (t : ℕ) :
    (splitSet n a b w t).card ≤ a + b := by
  refine le_trans (Finset.card_union_le _ _) ?_
  have h1 : (hhSet n a w t).card ≤ a := card_topByScore_le n a (acc w t)
  have h2 := card_recentSet_le n b
  omega

/-- A genuine split retains both diagnostic families. -/
theorem split_hits_both {n a b T : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) (hn : 1 ≤ n) :
    kept (staleW n T) T (splitSet n a b (staleW n T) T) = 1 ∧
    kept pinW T (splitSet n a b pinW T) = 1 := by
  constructor
  · have hmem : (n - 1) ∈ splitSet n a b (staleW n T) T := by
      refine Finset.mem_union_right _ ?_
      rw [recentSet, Finset.mem_Ico]
      omega
    rw [kept_staleW_last, if_pos hmem]
  · have hmem : (0 : ℕ) ∈ splitSet n a b pinW T := by
      refine Finset.mem_union_left _ ?_
      have hhit := hh_hits_pin (n := n) (B := a) (t := T) ha hn
      by_contra hnot
      rw [kept_pinW, if_neg hnot] at hhit
      norm_num at hhit
    rw [kept_pinW, if_pos hmem]

/-- With no recency budget the split loses the stale family completely. -/
theorem split_needs_recency {n a T : ℕ} (ha : 1 ≤ a) (han : a ≤ n - 1) (hT : 1 ≤ T) :
    kept (staleW n T) T (splitSet n a 0 (staleW n T) T) = 0 := by
  have hnot : (n - 1) ∉ splitSet n a 0 (staleW n T) T := by
    rw [splitSet, Finset.mem_union]
    rintro (hin | hin)
    · have hmiss := hh_misses_stale (n := n) (B := a) (T := T) ha han hT
      rw [kept_staleW_last, if_pos hin] at hmiss
      norm_num at hmiss
    · rw [recentSet, Finset.mem_Ico] at hin
      omega
  rw [kept_staleW_last, if_neg hnot]

/-- With no heavy-hitter budget the split loses the pinned family completely. -/
theorem split_needs_heavy_hitters {n b T : ℕ} (hb : b ≤ n - 1) (hn : 1 ≤ n) :
    kept pinW T (splitSet n 0 b pinW T) = 0 := by
  have hnot : (0 : ℕ) ∉ splitSet n 0 b pinW T := by
    rw [splitSet, Finset.mem_union]
    rintro (hin | hin)
    · rw [hhSet, topByScore, Finset.mem_filter] at hin
      omega
    · rw [recentSet, Finset.mem_Ico] at hin
      omega
  rw [kept_pinW, if_neg hnot]

/-- **The hybrid split is forced.**  Both halves of the budget are load-bearing: a split
retains both families exactly when neither half is zero. -/
theorem hybrid_split_necessary {n a b T : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) (han : a ≤ n - 1)
    (hbn : b ≤ n - 1) (hT : 1 ≤ T) (hn : 1 ≤ n) :
    (kept (staleW n T) T (splitSet n a b (staleW n T) T) = 1 ∧
      kept pinW T (splitSet n a b pinW T) = 1) ∧
    kept (staleW n T) T (splitSet n a 0 (staleW n T) T) = 0 ∧
    kept pinW T (splitSet n 0 b pinW T) = 0 :=
  ⟨split_hits_both ha hb hn, split_needs_recency ha han hT, split_needs_heavy_hitters hbn hn⟩

/-! ### 4. Per-layer allocation is a min-plus convolution, and the penalty survives it -/

lemma minPlus_nonempty (f g : ℕ → ℝ) (B : ℕ) :
    ((range (B + 1)).image (fun a => f a + g (B - a))).Nonempty :=
  ⟨f 0 + g (B - 0), Finset.mem_image.2 ⟨0, by simp, rfl⟩⟩

/-- Best two-layer loss at total budget `B`: the min-plus (tropical) convolution of the
two per-layer loss curves. -/
noncomputable def minPlus (f g : ℕ → ℝ) (B : ℕ) : ℝ :=
  ((range (B + 1)).image (fun a => f a + g (B - a))).min' (minPlus_nonempty f g B)

lemma minPlus_le {f g : ℕ → ℝ} {B a : ℕ} (ha : a ≤ B) : minPlus f g B ≤ f a + g (B - a) :=
  Finset.min'_le _ _ (Finset.mem_image.2 ⟨a, Finset.mem_range.2 (by omega), rfl⟩)

lemma minPlus_attained (f g : ℕ → ℝ) (B : ℕ) :
    ∃ a ≤ B, minPlus f g B = f a + g (B - a) := by
  obtain ⟨x, hx, hval⟩ := Finset.mem_image.1 (Finset.min'_mem _ (minPlus_nonempty f g B))
  exact ⟨x, by simpa using Nat.lt_succ_iff.1 (Finset.mem_range.1 hx), hval.symm⟩

/-- **The policy correction survives optimal allocation.**  If each layer's deployable loss
exceeds its oracle loss by at least `δ`, then the optimally allocated two-layer loss exceeds
the optimally allocated oracle loss by at least `2δ`: gaps add across layers, so a deployment
table must be policy-adjusted layer by layer. -/
theorem gap_adds_across_layers {f g f' g' : ℕ → ℝ} {delta : ℝ} (B : ℕ)
    (hf : ∀ a, f a + delta ≤ f' a) (hg : ∀ a, g a + delta ≤ g' a) :
    minPlus f g B + 2 * delta ≤ minPlus f' g' B := by
  obtain ⟨a, ha, hval⟩ := minPlus_attained f' g' B
  have h1 : minPlus f g B ≤ f a + g (B - a) := minPlus_le ha
  have h2 := hf a
  have h3 := hg (B - a)
  rw [hval]
  linarith

/-- Min-plus allocation is symmetric in the two layers. -/
theorem minPlus_comm (f g : ℕ → ℝ) (B : ℕ) : minPlus f g B = minPlus g f B := by
  have key : ∀ u v : ℕ → ℝ, minPlus u v B ≤ minPlus v u B := by
    intro u v
    obtain ⟨a, ha, hval⟩ := minPlus_attained v u B
    have h := minPlus_le (f := u) (g := v) (B := B) (a := B - a) (by omega)
    have hBa : B - (B - a) = a := by omega
    rw [hBa] at h
    rw [hval]
    linarith
  exact le_antisymm (key f g) (key g f)

end Catalog.Novelty.OracleOnlineEvictionSharp