import Novelty.OracleOnlineEvictionSharp

/-!
# Layers, blocks, and stationarity: closing three NET-56 follow-ups

Round 9 left three concrete questions.  This file answers them formally, on top of
`Novelty.OracleOnlineEvictionGap` and `Novelty.OracleOnlineEvictionSharp`.

## Main results

*When does accumulation actually work?*
* `hh_optimal_of_affine_stationary` — if the served row is an affine, order-preserving
  image of the accumulated score (`w_t = c · acc + d`, `c ≥ 0`), the heavy-hitter cache is
  **exactly** the oracle cache.  This is the stationarity hypothesis that H2O silently
  assumes, isolated.
* `hh_near_optimal_of_approx_stationary` — the robust version: if the row is within
  `ε/2` of such an affine image, the heavy-hitter cache loses at most `B·ε`.

*Does finer/coarser granularity rescue deployment?*
* `card_blockKeys_le`, `blockKeys_mem_caches` — a single block of `bs ≤ B` keys is an
  admissible cache;
* `block_oracle_adv` — a **block-granularity** oracle still retains everything on the
  adversarial family, while
* `block_granularity_does_not_rescue` — every causal policy still retains nothing there.
  So the separation is about causality, not about eviction granularity.

*Do the corrections add across layers?*
* `allocLoss` — the loss of an optimally allocated global budget over a list of layers
  (an iterated min-plus convolution); `allocLoss_pair` identifies the two-layer case with
  `minPlus`;
* `allocLoss_penalty` — a per-layer policy penalty `δ` passes through the optimisation and
  accumulates to `L·δ` over `L` layers.  A deployment table for an `L`-layer model must be
  corrected `L` times, and the correction cannot be optimised away by reallocating budget.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the measured 11.3 points are *not* granularity (block-128) and
*not* allocation (uniform per-layer budgets); they are causality, and they should therefore
survive both refinements.  Stationarity is the only hypothesis under which they vanish.

Experiment (Experimenter): the block lift keeps the adversarial family untouched and only
enlarges the oracle's admissible caches, so the separation must persist; the layer statement
is an induction over a list of loss curves.

Analysis (Analyst): the three results triangulate the same wall.  Granularity changes the
oracle's menu and not the policy's information; allocation changes the budget split and not
the per-layer defect; only stationarity changes the *statistic*, and it is exactly the
hypothesis under which the exchange lemma closes.

Critique (Critic): `block_oracle_adv` needs `1 ≤ bs ≤ B`, else a block is either empty or
inadmissible — both hypotheses are explicit and both are satisfied by the recorded
block-128/B-128 configuration.  `allocLoss_penalty` assumes only a pointwise per-layer
penalty and no monotonicity of the loss curves, so it applies to non-convex layers as well.
-/

namespace Catalog.Novelty.OracleOnlineEvictionLayers

open Finset Catalog.Novelty.OracleOnlineEvictionGap Catalog.Novelty.OracleOnlineEvictionSharp

/-! ### 1. Stationarity: the hypothesis under which heavy hitters are optimal -/

/-- **Exact stationarity.**  If the served row is an order-preserving affine image of the
accumulated score, the heavy-hitter cache attains the oracle. -/
theorem hh_optimal_of_affine_stationary {n B t : ℕ} {w : ℕ → ℕ → ℝ} {c d : ℝ}
    (hc : 0 ≤ c) (hw : ∀ j, 0 ≤ w t j) (hB : B ≤ n)
    (haff : ∀ j ∈ range n, w t j = c * acc w t j + d) :
    oracle n B w t = kept w t (hhSet n B w t) := by
  have hcons : ScoreConsistent n (acc w t) (w t) := by
    intro j hj k hk hle
    rw [haff j hj, haff k hk]
    have := mul_le_mul_of_nonneg_left hle hc
    linarith
  exact oracle_eq_topByScore hw hB hcons

/-- **Approximate stationarity.**  If the served row is within `ε/2` of an order-preserving
affine image of the accumulated score, the heavy-hitter cache loses at most `B·ε`. -/
theorem hh_near_optimal_of_approx_stationary {n B t : ℕ} {w : ℕ → ℕ → ℝ} {c d eps : ℝ}
    (hc : 0 ≤ c) (heps : 0 ≤ eps) (hw : ∀ j, 0 ≤ w t j) (hB : B ≤ n)
    (haff : ∀ j ∈ range n, |w t j - (c * acc w t j + d)| ≤ eps / 2) :
    oracle n B w t ≤ kept w t (hhSet n B w t) + B * eps := by
  refine oracle_le_topByScore_add hw heps hB (fun j hj k hk hle => ?_)
  have hj' := abs_le.1 (haff j hj)
  have hk' := abs_le.1 (haff k hk)
  have hmul := mul_le_mul_of_nonneg_left hle hc
  linarith [hj'.1, hk'.2]

/-! ### 2. Block granularity does not rescue deployment -/

/-- The keys of a single block of width `bs`. -/
def blockKeys (n bs b : ℕ) : Finset ℕ := (range n).filter (fun j => j / bs = b)

lemma card_blockKeys_le (n bs b : ℕ) (hbs : 1 ≤ bs) : (blockKeys n bs b).card ≤ bs := by
  have hmaps : Set.MapsTo (fun j => j % bs) ↑(blockKeys n bs b) ↑(range bs) := by
    intro j _
    simp only [Finset.mem_coe, Finset.mem_range]
    exact Nat.mod_lt _ (by omega)
  have hinj : Set.InjOn (fun j => j % bs) ↑(blockKeys n bs b) := by
    intro j hj k hk hjk
    simp only [Finset.mem_coe, blockKeys, Finset.mem_filter] at hj hk
    have hd : j / bs = k / bs := by rw [hj.2, hk.2]
    have hm : j % bs = k % bs := hjk
    have h1 := Nat.div_add_mod j bs
    have h2 := Nat.div_add_mod k bs
    rw [hd, hm] at h1
    omega
  simpa using Finset.card_le_card_of_injOn _ hmaps hinj

lemma blockKeys_mem_caches {n bs b B : ℕ} (hbs : 1 ≤ bs) (hB : bs ≤ B) :
    blockKeys n bs b ∈ caches n B :=
  mem_caches.2 ⟨Finset.filter_subset _ _, le_trans (card_blockKeys_le n bs b hbs) hB⟩

/-- Even a **block-granularity** oracle retains everything on the adversarial family: the
whole block containing the needed key is an admissible cache. -/
theorem block_oracle_adv {n bs B T j₀ : ℕ} (hbs : 1 ≤ bs) (hB : bs ≤ B) (hj₀ : j₀ < n) :
    blockKeys n bs (j₀ / bs) ∈ caches n B ∧
      kept (adv n T j₀) T (blockKeys n bs (j₀ / bs)) = 1 := by
  refine ⟨blockKeys_mem_caches hbs hB, ?_⟩
  have hmem : j₀ ∈ blockKeys n bs (j₀ / bs) :=
    Finset.mem_filter.2 ⟨Finset.mem_range.2 hj₀, rfl⟩
  rw [kept_adv_last, if_pos hmem]

/-- **The wall is causality, not granularity.**  At block granularity the oracle still
retains everything on some instance where a causal policy retains nothing. -/
theorem block_granularity_does_not_rescue {n bs B T : ℕ}
    {P : (ℕ → ℕ → ℝ) → ℕ → Finset ℕ} (hP : Causal n B P) (hbs : 1 ≤ bs) (hB : bs ≤ B)
    (hBn : B < n) :
    ∃ j₀ < n, kept (adv n T j₀) T (blockKeys n bs (j₀ / bs))
        - kept (adv n T j₀) T (P (adv n T j₀) T) = 1 := by
  obtain ⟨j₀, hj₀, hzero⟩ := causal_policy_misses (T := T) hP hBn
  refine ⟨j₀, hj₀, ?_⟩
  rw [(block_oracle_adv hbs hB hj₀).2, hzero]
  ring

/-! ### 3. `L` layers: the policy correction accumulates -/

/-- Loss of an optimally allocated global budget over a list of per-layer loss curves: an
iterated min-plus convolution, the last layer consuming the remaining budget. -/
noncomputable def allocLoss : List (ℕ → ℝ) → ℕ → ℝ
  | [], _ => 0
  | [f], B => f B
  | f :: g :: fs, B =>
      ((range (B + 1)).image (fun a => f a + allocLoss (g :: fs) (B - a))).min'
        (Finset.Nonempty.image Finset.nonempty_range_add_one _)

lemma allocLoss_cons_le {f g : ℕ → ℝ} {fs : List (ℕ → ℝ)} {B a : ℕ} (ha : a ≤ B) :
    allocLoss (f :: g :: fs) B ≤ f a + allocLoss (g :: fs) (B - a) := by
  rw [allocLoss]
  exact Finset.min'_le _ _ (Finset.mem_image.2 ⟨a, Finset.mem_range.2 (by omega), rfl⟩)

lemma allocLoss_cons_attained (f g : ℕ → ℝ) (fs : List (ℕ → ℝ)) (B : ℕ) :
    ∃ a ≤ B, allocLoss (f :: g :: fs) B = f a + allocLoss (g :: fs) (B - a) := by
  have hmem := Finset.min'_mem
    ((range (B + 1)).image (fun a => f a + allocLoss (g :: fs) (B - a)))
    (Finset.Nonempty.image Finset.nonempty_range_add_one _)
  obtain ⟨a, ha, hval⟩ := Finset.mem_image.1 hmem
  refine ⟨a, by simpa using Nat.lt_succ_iff.1 (Finset.mem_range.1 ha), ?_⟩
  rw [allocLoss]
  exact hval.symm

/-- The two-layer case is exactly the min-plus convolution of `OracleOnlineEvictionSharp`. -/
theorem allocLoss_pair (f g : ℕ → ℝ) (B : ℕ) : allocLoss [f, g] B = minPlus f g B := rfl

/-- **The policy correction accumulates over layers.**  If every layer's deployable loss
exceeds its oracle loss by at least `δ`, then the optimally allocated `L`-layer loss exceeds
the optimally allocated oracle loss by at least `L·δ`: reallocating the global budget cannot
recover the per-layer gap. -/
theorem allocLoss_penalty {delta : ℝ} :
    ∀ {fs fs' : List (ℕ → ℝ)}, List.Forall₂ (fun f f' => ∀ a, f a + delta ≤ f' a) fs fs' →
      ∀ B, allocLoss fs B + fs.length * delta ≤ allocLoss fs' B := by
  intro fs
  induction fs with
  | nil =>
    intro fs' h B
    cases h
    simp [allocLoss]
  | cons f fs ih =>
    intro fs' h B
    cases h with
    | cons hhead htail =>
      rename_i f' fs''
      cases fs with
      | nil =>
        cases htail
        have hb := hhead B
        simp only [allocLoss, List.length_cons, List.length_nil]
        push_cast
        linarith
      | cons g gs =>
        cases fs'' with
        | nil => cases htail
        | cons g' gs' =>
          obtain ⟨a, ha, hval⟩ := allocLoss_cons_attained f' g' gs' B
          have h1 : allocLoss (f :: g :: gs) B ≤ f a + allocLoss (g :: gs) (B - a) :=
            allocLoss_cons_le ha
          have h2 := ih htail (B - a)
          have h3 := hhead a
          have hlen : ((g :: gs).length : ℝ) + 1 = ((f :: g :: gs).length : ℝ) := by
            simp only [List.length_cons]
            push_cast
            ring
          rw [hval]
          have hgoal : allocLoss (f :: g :: gs) B + ((g :: gs).length + 1) * delta
              ≤ f' a + allocLoss (g' :: gs') (B - a) := by
            nlinarith [h1, h2, h3]
          calc allocLoss (f :: g :: gs) B + ((f :: g :: gs).length : ℝ) * delta
              = allocLoss (f :: g :: gs) B + (((g :: gs).length : ℝ) + 1) * delta := by
                rw [hlen]
            _ ≤ f' a + allocLoss (g' :: gs') (B - a) := hgoal

end Catalog.Novelty.OracleOnlineEvictionLayers