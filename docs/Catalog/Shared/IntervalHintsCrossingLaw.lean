/-
# ET-HINTS-THEORY: the crossing law — width can never substitute for reliability
(FACT round 40 #2, paper 146, exp 480)

Continuation of `Logic.IntervalHintsTwoNumbers` (round 39 #5) and of the round-40 #4 files
`Combinatorics.IntervalHintsHedgingHump`, `…PlacementCeilings`, `…CalibrationGate`.
An oracle names a window of `W` of `M` cells with reliability `α`; the *stipulated pricing*
compares the Bayes-optimal min-law blind cost `minBlind M = (M+1)(2M+1)/(6M)` with the
two-number cost of the hinted search.

## Main results
* `exchange_sum_le`, `position_sum_ge` — exchange lemma: `W` probe slots have index sum at
  least `W(W+1)/2`, plus one per slot beyond the first `W`.
* **`displacement_law`** — for any two-valued posterior `(a, b)` and any of the `M!` orders,
  `cost(σ) - cost(committed) = (a-b)(Σ window slots - W(W+1)/2)` (closed form for all orders).
* `misplacement_cost`, **`bayes_eq_committed`** (Bayes ≡ Committed, `a ≥ b`),
  **`bayes_order_iff`** (for `a > b` the Bayes orders are *exactly* the window-first ones).
* `exists_order_with_slots`, **`interleaved_closed_form`**, `interleaved_strictly_dominated` —
  alternating window/outside costs exactly `(a-b) W(W-1)/2` more: strictly dominated.
* **`crossing_law`** — `s ≤ S(α, w) ↔ w ≤ α - α_min(s)` with `α_min(s) = 1 - 2/(3s)` and
  `S(α, w) = 2/(3(1-α+w))`; `reliability_gate`, **`width_cannot_substitute`**,
  `iso_speedup_iff`, `crossing_width` (linear law `μ/M = α - α_min(s)`).
* `paper137_gate` (`0.87154 < α_min(5.19) < 0.87155`), `paper137_width`
  (`μ/M ∈ (0.02845, 0.02846)` at `α = 0.90`).
* `pricedSpeedupM_eq` (exact closed form), `finite_reliability_gate` (gate at every finite `M`),
  `alphaMinM_tendsto`, `pricedSpeedupM_tendsto` (continuum limits).
* `probeCost_hint_ge`, **`bayes_cost_exact`** — the Bayes cost of the hint posterior is exactly
  `min((W+1+(1-α)M)/2, (M-W+1+αM)/2)` in every regime.
* **`bayes_two_sided_gate`** — for the Bayes-optimal searcher the gate is two-sided:
  `α > α_min^M(s)` **or** `1 - α > α_min^M(s)`; `bayes_gate_trusted` (one-sided when `α ≥ W/M`).
* `refl_add_blockRev`, `optCost_le_stipulated`, **`conservative_pricing`** — for *every*
  posterior with window mass `α`, the true Bayes speedup is at least the stipulated `S_M(W, α)`.

-- !-- Lab Notes -- !--
Hypothesizer: (C1) [BOLD] reliability gate independent of width; (C2) Bayes ≡ Committed with a
  *unique* optimal block structure; (C3) interleaving has a closed-form loss; (C4) [BOLD] the gate
  survives Bayes-optimal search over all `M!` orders; (C5) [BOLD] stipulated pricing is
  conservative for every calibrated posterior; (C6) the crossing is linear in `α`.
Experimenter (exact rationals, seed 20260828):
  `α_min(5.19) = 0.8715478…`, `0.9 - α_min(5.19) = 0.0284522…`.
  `M = 6`, all 720 orders, 55 cells (`W = 1..5`, `α = 0, 0.1, …, 1`): Bayes cost equals
  `min` of the two committed costs in 55/55 cells.
  300 random posteriors (`M = 6`): Bayes / stipulated ≤ 0.9632 (never above 1).
  `M = 8, W = 3, a = 1/5, b = 1/25`: interleaved excess `12/25 = (a-b)·3·2/2`.
  `M = 300`: closed form = brute sum exactly (`W = 9, α = .9`: `S = 5.02503`).
  Finite gate: `α_min^300(5.19) = 0.87090`, `α_min^10⁴(5.19) = 0.87153`.
Analyst: (C1),(C2),(C3),(C5),(C6) proved.  (C4) FALSE as stated: an anti-reliable hint
  (`α` small) is a reliable hint for the complement, so the Bayes gate is two-sided
  (`bayes_two_sided_gate`); the one-sided gate holds exactly in the trusted regime `α ≥ W/M`.
  `one_sided_gate_fails_for_bayes` is the explicit witness (`M = 4, W = 2, α = 0`).
Critic: the crossing law is a statement about the *stipulated* pricing.  `conservative_pricing`
  shows real posteriors can only do better, so outside the stipulated model the gate is a
  benchmark, not a universal necessary condition for arbitrary hint semantics.
-/
import Combinatorics.IntervalHintsCalibrationGate

namespace IntervalHintsCrossingLaw

open Finset Topology IntervalHintsTwoNumbers IntervalHintsPlacementCeilings

/-! ## 1. An exchange lemma for position sums -/

/-- **Exchange lemma.**  If `T` and `R` have the same size, every element of `T \ R` has weight
at least `c`, and every element of `R \ T` has weight at most `c - 1`, then
`Σ_R f + |T \ R| ≤ Σ_T f`. -/
theorem exchange_sum_le {ι : Type*} [DecidableEq ι] (T R : Finset ι) (f : ι → ℕ) (c : ℕ)
    (hcard : T.card = R.card) (hT : ∀ x ∈ T \ R, c ≤ f x) (hR : ∀ x ∈ R \ T, f x + 1 ≤ c) :
    ∑ x ∈ R, f x + (T \ R).card ≤ ∑ x ∈ T, f x := by
  have hk : (T \ R).card = (R \ T).card := by
    have h1 := card_sdiff_add_card_inter T R
    have h2 := card_sdiff_add_card_inter R T
    rw [inter_comm] at h2
    omega
  rw [← sum_inter_add_sum_diff R T f, ← sum_inter_add_sum_diff T R f, inter_comm R T]
  have hA' : ∑ x ∈ R \ T, (f x + 1) ≤ (R \ T).card * c := by
    rw [← smul_eq_mul, ← sum_const]
    exact sum_le_sum hR
  have hA : ∑ x ∈ R \ T, f x + (R \ T).card ≤ (R \ T).card * c := by
    rw [sum_add_distrib, ← card_eq_sum_ones] at hA'
    exact hA'
  have hB : (T \ R).card * c ≤ ∑ x ∈ T \ R, f x := by
    rw [← smul_eq_mul, ← sum_const]
    exact sum_le_sum hT
  rw [hk] at hB ⊢
  omega

/-- The first `k` cells of `Fin M`. -/
def firstCells (M k : ℕ) : Finset (Fin M) := univ.filter fun i => (i : ℕ) < k

lemma firstCells_map (M k : ℕ) (hk : k ≤ M) :
    (firstCells M k).map Fin.valEmbedding = range k := by
  ext x
  simp only [firstCells, Finset.mem_map, mem_filter, mem_univ, true_and,
    Fin.valEmbedding_apply, mem_range]
  constructor
  · rintro ⟨i, hi, rfl⟩; exact hi
  · intro hx; exact ⟨⟨x, by omega⟩, hx, rfl⟩

lemma card_firstCells (M k : ℕ) (hk : k ≤ M) : (firstCells M k).card = k := by
  rw [← card_map Fin.valEmbedding, firstCells_map M k hk, card_range]

/-- `Σ_{i < k} (i + 1) = k (k + 1) / 2` over the first `k` cells. -/
lemma sum_firstCells (M k : ℕ) (hk : k ≤ M) :
    ∑ i ∈ firstCells M k, (((i : ℕ) : ℝ) + 1) = (k : ℝ) * (k + 1) / 2 := by
  rw [← sum_range_succ_cast, ← firstCells_map M k hk, sum_map]
  rfl

/-- **Position-sum lower bound.**  Any `k` probe slots have total index at least
`k (k+1) / 2`, plus one for every slot beyond the first `k`. -/
theorem position_sum_ge (M k : ℕ) (hk : k ≤ M) (U : Finset (Fin M)) (hU : U.card = k) :
    (k : ℝ) * (k + 1) / 2 + ((U.filter fun i : Fin M => k ≤ (i : ℕ)).card : ℝ)
      ≤ ∑ i ∈ U, (((i : ℕ) : ℝ) + 1) := by
  have hex := exchange_sum_le U (firstCells M k) (fun i => (i : ℕ)) k
    (by rw [hU, card_firstCells M k hk])
    (by
      intro x hx
      simp only [mem_sdiff, firstCells, mem_filter, mem_univ, true_and] at hx
      show k ≤ (x : ℕ)
      omega)
    (by
      intro x hx
      simp only [mem_sdiff, firstCells, mem_filter, mem_univ, true_and] at hx
      show (x : ℕ) + 1 ≤ k
      omega)
  have hsd : U \ firstCells M k = U.filter fun i : Fin M => k ≤ (i : ℕ) := by
    ext i; simp [firstCells]
  rw [hsd] at hex
  have hexR : (∑ i ∈ firstCells M k, ((i : ℕ) : ℝ)) +
      ((U.filter fun i : Fin M => k ≤ (i : ℕ)).card : ℝ) ≤ ∑ i ∈ U, ((i : ℕ) : ℝ) := by
    exact_mod_cast hex
  have h1 : ∑ i ∈ U, (((i : ℕ) : ℝ) + 1) = ∑ i ∈ U, ((i : ℕ) : ℝ) + k := by
    rw [sum_add_distrib, sum_const, hU, nsmul_eq_mul, mul_one]
  have h2 : ∑ i ∈ firstCells M k, (((i : ℕ) : ℝ) + 1) =
      ∑ i ∈ firstCells M k, ((i : ℕ) : ℝ) + k := by
    rw [sum_add_distrib, sum_const, card_firstCells M k hk, nsmul_eq_mul, mul_one]
  rw [sum_firstCells M k hk] at h2
  linarith

/-! ## 2. The displacement law for two-valued posteriors -/

/-- A two-valued posterior: weight `a` on each of the window cells `{0, …, W-1}`, weight `b`
on every other cell.  The round-39 hint posterior is of this form. -/
def twoLevel {M : ℕ} (W : ℕ) (a b : ℝ) (j : Fin M) : ℝ := if (j : ℕ) < W then a else b

lemma hintPosterior_eq_twoLevel (M W : ℕ) (α : ℝ) :
    hintPosterior M W α = twoLevel W (α / W) ((1 - α) / ((M : ℝ) - W)) := rfl

/-- The probe slots in which the order `σ` inspects a window cell. -/
def windowSlots (M W : ℕ) (σ : Equiv.Perm (Fin M)) : Finset (Fin M) :=
  univ.filter fun i => (σ i : ℕ) < W

lemma windowSlots_refl (M W : ℕ) : windowSlots M W (Equiv.refl (Fin M)) = firstCells M W := rfl

lemma windowSlots_eq_map (M W : ℕ) (σ : Equiv.Perm (Fin M)) :
    windowSlots M W σ = (firstCells M W).map σ.symm.toEmbedding := by
  ext i
  simp only [windowSlots, firstCells, mem_filter, mem_univ, true_and, Finset.mem_map,
    Equiv.coe_toEmbedding]
  constructor
  · intro h; exact ⟨σ i, h, by simp⟩
  · rintro ⟨j, hj, rfl⟩; simpa using hj

lemma card_windowSlots (M W : ℕ) (hWM : W ≤ M) (σ : Equiv.Perm (Fin M)) :
    (windowSlots M W σ).card = W := by
  rw [windowSlots_eq_map, card_map, card_firstCells M W hWM]

lemma sum_all_slots (M : ℕ) : ∑ i : Fin M, (((i : ℕ) : ℝ) + 1) = (M : ℝ) * (M + 1) / 2 := by
  rw [Fin.sum_univ_eq_sum_range (fun i => (i : ℝ) + 1), sum_range_succ_cast]

/-- **Cost of an arbitrary order under a two-valued posterior.**
`E[probes] = b · M(M+1)/2 + (a - b) · Σ_{window slots} (slot index)`. -/
theorem probeCost_twoLevel (M W : ℕ) (a b : ℝ) (σ : Equiv.Perm (Fin M)) :
    probeCost (twoLevel W a b) σ =
      b * ((M : ℝ) * (M + 1) / 2) + (a - b) * ∑ i ∈ windowSlots M W σ, (((i : ℕ) : ℝ) + 1) := by
  unfold probeCost twoLevel windowSlots
  rw [sum_filter, ← sum_all_slots, mul_sum, mul_sum, ← sum_add_distrib]
  refine sum_congr rfl fun i _ => ?_
  split_ifs <;> ring

/-- **The displacement law.**  Relative to the committed (window-first) order, an arbitrary
order pays exactly `(a - b)` times the excess of its window-slot index sum over the minimum
`W (W+1)/2`. -/
theorem displacement_law (M W : ℕ) (hWM : W ≤ M) (a b : ℝ) (σ : Equiv.Perm (Fin M)) :
    probeCost (twoLevel W a b) σ - probeCost (twoLevel W a b) (Equiv.refl (Fin M)) =
      (a - b) * (∑ i ∈ windowSlots M W σ, (((i : ℕ) : ℝ) + 1) - (W : ℝ) * (W + 1) / 2) := by
  rw [probeCost_twoLevel, probeCost_twoLevel, windowSlots_refl, sum_firstCells M W hWM]
  ring

/-- Number of window cells that `σ` probes *after* slot `W` (misplaced window cells). -/
def misplaced (M W : ℕ) (σ : Equiv.Perm (Fin M)) : ℕ :=
  ((windowSlots M W σ).filter fun i : Fin M => W ≤ (i : ℕ)).card

/-- **Every misplaced window cell costs at least `a - b`.** -/
theorem misplacement_cost (M W : ℕ) (hWM : W ≤ M) (a b : ℝ) (hab : b ≤ a)
    (σ : Equiv.Perm (Fin M)) :
    probeCost (twoLevel W a b) (Equiv.refl (Fin M)) + (a - b) * misplaced M W σ ≤
      probeCost (twoLevel W a b) σ := by
  have hd := displacement_law M W hWM a b σ
  have hp := position_sum_ge M W hWM (windowSlots M W σ) (card_windowSlots M W hWM σ)
  unfold misplaced
  have : (a - b) * (((windowSlots M W σ).filter fun i : Fin M => W ≤ (i : ℕ)).card : ℝ) ≤
      (a - b) * (∑ i ∈ windowSlots M W σ, (((i : ℕ) : ℝ) + 1) - (W : ℝ) * (W + 1) / 2) :=
    mul_le_mul_of_nonneg_left (by linarith) (by linarith)
  linarith

/-- **Bayes ≡ Committed.**  For a two-valued posterior with `a ≥ b`, the committed order is
Bayes-optimal among all `M!` orders: its cost is the Bayes cost. -/
theorem bayes_eq_committed (M W : ℕ) (hWM : W ≤ M) (a b : ℝ) (hab : b ≤ a) :
    optCost (twoLevel (M := M) W a b) = probeCost (twoLevel W a b) (Equiv.refl (Fin M)) := by
  refine le_antisymm (inf'_le _ (mem_univ _)) (le_inf' _ _ fun σ _ => ?_)
  have h := misplacement_cost M W hWM a b hab σ
  have : 0 ≤ (a - b) * (misplaced M W σ : ℝ) := mul_nonneg (by linarith) (by positivity)
  linarith

/-- **Uniqueness of the Bayes order.**  If `a > b`, an order is Bayes-optimal **iff** it probes
every window cell within the first `W` slots: the Bayes order is unique up to permuting the
window block and the outside block. -/
theorem bayes_order_iff (M W : ℕ) (hWM : W ≤ M) (a b : ℝ) (hab : b < a)
    (σ : Equiv.Perm (Fin M)) :
    probeCost (twoLevel W a b) σ = optCost (twoLevel (M := M) W a b) ↔
      ∀ i : Fin M, (σ i : ℕ) < W → (i : ℕ) < W := by
  rw [bayes_eq_committed M W hWM a b hab.le]
  constructor
  · intro h i hi
    by_contra hiW
    have hpos : 1 ≤ misplaced M W σ := by
      unfold misplaced
      exact card_pos.mpr ⟨i, by simp [windowSlots, hi]; omega⟩
    have hc := misplacement_cost M W hWM a b hab.le σ
    have : (a - b) * 1 ≤ (a - b) * (misplaced M W σ : ℝ) :=
      mul_le_mul_of_nonneg_left (by exact_mod_cast hpos) (by linarith)
    linarith
  · intro h
    have hsub : windowSlots M W σ ⊆ firstCells M W := by
      intro i hi
      simp only [windowSlots, firstCells, mem_filter, mem_univ, true_and] at hi ⊢
      exact h i hi
    have heq : windowSlots M W σ = firstCells M W :=
      eq_of_subset_of_card_le hsub (by rw [card_windowSlots M W hWM, card_firstCells M W hWM])
    rw [probeCost_twoLevel, probeCost_twoLevel, heq, windowSlots_refl]

/-! ## 3. Interleaved procedures are strictly dominated -/

/-- Any set of `W` slots is realised as the window slots of some order. -/
theorem exists_order_with_slots (M W : ℕ) (hWM : W ≤ M) (T : Finset (Fin M))
    (hT : T.card = W) : ∃ σ : Equiv.Perm (Fin M), windowSlots M W σ = T := by
  classical
  let p : Fin M → Prop := fun i => i ∈ T
  let q : Fin M → Prop := fun j => (j : ℕ) < W
  have h1 : Fintype.card {i // p i} = Fintype.card {j // q j} := by
    rw [Fintype.card_subtype, Fintype.card_subtype]
    simp only [p, q, filter_mem_eq_inter, univ_inter]
    rw [hT]; exact (card_firstCells M W hWM).symm
  have h2 : Fintype.card {i // ¬ p i} = Fintype.card {j // ¬ q j} := by
    rw [Fintype.card_subtype_compl, Fintype.card_subtype_compl, h1]
  let e1 := Fintype.equivOfCardEq h1
  let e2 := Fintype.equivOfCardEq h2
  let σ : Equiv.Perm (Fin M) :=
    ((Equiv.sumCompl p).symm.trans (Equiv.sumCongr e1 e2)).trans (Equiv.sumCompl q)
  refine ⟨σ, ?_⟩
  ext i
  simp only [windowSlots, mem_filter, mem_univ, true_and]
  by_cases hi : p i
  · have : σ i = (e1 ⟨i, hi⟩ : Fin M) := by
      simp [σ, Equiv.sumCompl_symm_apply_of_pos hi]
    rw [this]
    exact ⟨fun _ => hi, fun _ => (e1 ⟨i, hi⟩).2⟩
  · have : σ i = (e2 ⟨i, hi⟩ : Fin M) := by
      simp [σ, Equiv.sumCompl_symm_apply_of_neg hi]
    rw [this]
    exact ⟨fun h => absurd h (e2 ⟨i, hi⟩).2, fun h => absurd h hi⟩

/-- The interleaved slot pattern: window cells at slots `0, 2, 4, …, 2W-2`. -/
def evenSlots (M W : ℕ) : Finset (Fin M) :=
  univ.filter fun i => Even (i : ℕ) ∧ (i : ℕ) < 2 * W

lemma evenSlots_map (M W : ℕ) (h : 2 * W ≤ M) :
    (evenSlots M W).map Fin.valEmbedding =
      (range W).map ⟨fun k => 2 * k, fun x y hxy => by simpa using hxy⟩ := by
  ext x
  simp only [evenSlots, Finset.mem_map, mem_filter, mem_univ, true_and,
    Fin.valEmbedding_apply, mem_range, Function.Embedding.coeFn_mk]
  constructor
  · rintro ⟨i, ⟨⟨k, hk⟩, hi⟩, rfl⟩
    exact ⟨k, by omega, by omega⟩
  · rintro ⟨k, hk, rfl⟩
    exact ⟨⟨2 * k, by omega⟩, ⟨⟨k, by ring⟩, by simp; omega⟩, rfl⟩

lemma card_evenSlots (M W : ℕ) (h : 2 * W ≤ M) : (evenSlots M W).card = W := by
  rw [← card_map Fin.valEmbedding, evenSlots_map M W h, card_map, card_range]

lemma sum_evenSlots (M W : ℕ) (h : 2 * W ≤ M) :
    ∑ i ∈ evenSlots M W, (((i : ℕ) : ℝ) + 1) = (W : ℝ) ^ 2 := by
  have : ∑ i ∈ evenSlots M W, (((i : ℕ) : ℝ) + 1) =
      ∑ x ∈ (evenSlots M W).map Fin.valEmbedding, ((x : ℝ) + 1) := by
    rw [sum_map]; rfl
  rw [this, evenSlots_map M W h, sum_map]
  simp only [Function.Embedding.coeFn_mk]
  clear this h
  induction W with
  | zero => simp
  | succ k ih => rw [sum_range_succ, ih]; push_cast; ring

/-- **Interleaving is strictly dominated (closed form).**  If `2W ≤ M` there is an order that
alternates window and outside cells (window cells at slots `1, 3, …, 2W-1`), and every such
order costs exactly `(a - b) · W (W-1) / 2` more than the committed order; for `a > b` and
`W ≥ 2` this is a strict loss. -/
theorem interleaved_closed_form (M W : ℕ) (h : 2 * W ≤ M) (a b : ℝ) :
    (∃ σ : Equiv.Perm (Fin M), windowSlots M W σ = evenSlots M W) ∧
    ∀ σ : Equiv.Perm (Fin M), windowSlots M W σ = evenSlots M W →
      probeCost (twoLevel W a b) σ =
        probeCost (twoLevel W a b) (Equiv.refl (Fin M)) + (a - b) * ((W : ℝ) * (W - 1) / 2) := by
  refine ⟨exists_order_with_slots M W (by omega) _ (card_evenSlots M W h), fun σ hσ => ?_⟩
  have hd := displacement_law M W (by omega) a b σ
  rw [hσ, sum_evenSlots M W h] at hd
  linarith [show (a - b) * ((W : ℝ) ^ 2 - W * (W + 1) / 2) = (a - b) * (W * (W - 1) / 2) by ring]

theorem interleaved_strictly_dominated (M W : ℕ) (h : 2 * W ≤ M) (hW : 2 ≤ W) (a b : ℝ)
    (hab : b < a) (σ : Equiv.Perm (Fin M)) (hσ : windowSlots M W σ = evenSlots M W) :
    optCost (twoLevel (M := M) W a b) < probeCost (twoLevel W a b) σ := by
  rw [bayes_eq_committed M W (by omega) a b hab.le, (interleaved_closed_form M W h a b).2 σ hσ]
  have hW' : (2 : ℝ) ≤ W := by exact_mod_cast hW
  have : 0 < (a - b) * ((W : ℝ) * (W - 1) / 2) := mul_pos (by linarith) (by nlinarith)
  linarith

/-! ## 4. The crossing law (continuum) -/

/-- The reliability gate `α_min(s) = 1 - 2/(3s)`. -/
noncomputable def alphaMin (s : ℝ) : ℝ := 1 - 2 / (3 * s)

/-- Priced continuum speedup: min-law blind cost `M/3` against the two-number committed cost
`(1 - α + w) M / 2`. -/
noncomputable def pricedSpeedup (α w : ℝ) : ℝ := 2 / (3 * (1 - α + w))

/-- **THE CROSSING LAW.**  Speedup `s` is reached iff the width fraction is at most the
reliability surplus over the gate: `s ≤ S(α, w) ↔ w ≤ α - α_min(s)`. -/
theorem crossing_law (s α w : ℝ) (hs : 0 < s) (hpos : 0 < 1 - α + w) :
    s ≤ pricedSpeedup α w ↔ w ≤ α - alphaMin s := by
  unfold pricedSpeedup alphaMin
  rw [le_div_iff₀ (by positivity)]
  constructor
  · intro h
    have : 1 - α + w ≤ 2 / (3 * s) := by rw [le_div_iff₀ (by positivity)]; nlinarith
    linarith
  · intro h
    have : 1 - α + w ≤ 2 / (3 * s) := by linarith
    rw [le_div_iff₀ (by positivity)] at this
    nlinarith

/-- **Hard reliability gate.**  Any window of positive width that reaches speedup `s` has
reliability strictly above `α_min(s)`. -/
theorem reliability_gate (s α w : ℝ) (hs : 0 < s) (hw : 0 < w) (hpos : 0 < 1 - α + w)
    (h : s ≤ pricedSpeedup α w) : alphaMin s < α := by
  have := (crossing_law s α w hs hpos).1 h
  linarith

/-- **Width can never substitute for reliability.**  If `α ≤ α_min(s)`, no window of positive
width, however narrow, reaches speedup `s`. -/
theorem width_cannot_substitute (s α w : ℝ) (hs : 0 < s) (hα : α ≤ alphaMin s) (hw : 0 < w) :
    pricedSpeedup α w < s := by
  unfold alphaMin at hα
  have h23 : 0 < 2 / (3 * s) := by positivity
  have hpos : 0 < 1 - α + w := by linarith
  by_contra hcon
  have := reliability_gate s α w hs hw hpos (not_lt.mp hcon)
  unfold alphaMin at this
  linarith

/-- **Linear crossing.**  Above the gate the crossing width is exactly the reliability surplus
`w = α - α_min(s)`; the iso-speedup curves are the parallel lines `w = α - α_min(s)`. -/
theorem iso_speedup_iff (s α w : ℝ) (hs : 0 < s) (hpos : 0 < 1 - α + w) :
    pricedSpeedup α w = s ↔ w = α - alphaMin s := by
  unfold pricedSpeedup alphaMin
  rw [div_eq_iff (by positivity)]
  constructor
  · intro h
    field_simp
    linarith
  · intro h
    rw [h]
    field_simp
    ring

theorem crossing_width (s α : ℝ) (hs : 0 < s) (hα : alphaMin s < α) :
    0 < α - alphaMin s ∧ pricedSpeedup α (α - alphaMin s) = s := by
  refine ⟨by linarith, (iso_speedup_iff s α _ hs ?_).2 rfl⟩
  unfold alphaMin
  have : 0 < 2 / (3 * s) := by positivity
  linarith

/-- **Paper 137's gate.**  The measured `5.19×` requires `α > 0.871547…`. -/
theorem paper137_gate : 0.87154 < alphaMin 5.19 ∧ alphaMin 5.19 < 0.87155 := by
  unfold alphaMin; constructor <;> norm_num

/-- At `α = 0.90` the crossing width is `μ/M = 0.9 - α_min(5.19) ≈ 0.02845`. -/
theorem paper137_width :
    0.02845 < 0.9 - alphaMin 5.19 ∧ 0.9 - alphaMin 5.19 < 0.02846 ∧
      pricedSpeedup 0.9 (0.9 - alphaMin 5.19) = 5.19 := by
  refine ⟨?_, ?_, (crossing_width 5.19 0.9 (by norm_num) ?_).2⟩ <;> unfold alphaMin <;> norm_num

/-! ## 5. Exact finite-`M` pricing and the finite gate -/

/-- Exact priced speedup: Bayes-optimal min-law blind cost over the committed hinted cost. -/
noncomputable def pricedSpeedupM (M W : ℕ) (α : ℝ) : ℝ := minBlind M / hintedCost M W α

/-- **Closed form (HINT-COST-PRICED).**
`S_M(W, α) = (M+1)(2M+1) / (3M ((1-α) M + W + 1))`. -/
theorem pricedSpeedupM_eq (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ) :
    pricedSpeedupM M W α = ((M : ℝ) + 1) * (2 * M + 1) / (3 * M * ((1 - α) * M + W + 1)) := by
  unfold pricedSpeedupM minBlind
  rw [hintedCost_eq M W hW hWM]
  have hM : (0 : ℝ) < M := by exact_mod_cast hW.trans hWM
  rw [show (W : ℝ) + 1 + (1 - α) * M = (1 - α) * M + W + 1 by ring]
  rw [div_div_eq_mul_div]
  field_simp
  ring

/-- The finite-`M` gate `α_min^M(s) = 1 - (M+1)(2M+1)/(3M² s)`. -/
noncomputable def alphaMinM (M : ℕ) (s : ℝ) : ℝ := 1 - ((M : ℝ) + 1) * (2 * M + 1) / (3 * (M : ℝ) ^ 2 * s)

/-- **Finite reliability gate.**  At every finite `M` and every width `W`, reaching speedup `s`
forces `α > α_min^M(s)`. -/
theorem finite_reliability_gate (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α s : ℝ) (hs : 0 < s)
    (hα : α ≤ 1) (h : s ≤ pricedSpeedupM M W α) : alphaMinM M s < α := by
  rw [pricedSpeedupM_eq M W hW hWM] at h
  have hM : (0 : ℝ) < M := by exact_mod_cast hW.trans hWM
  have hW' : (0 : ℝ) < W := by exact_mod_cast hW
  have h1 : 0 ≤ (1 - α) * M := mul_nonneg (by linarith) hM.le
  have hD : 0 < (1 - α) * M + W + 1 := by linarith
  rw [le_div_iff₀ (by positivity)] at h
  unfold alphaMinM
  rw [sub_lt_comm, lt_div_iff₀ (by positivity)]
  nlinarith

lemma tendsto_inv_nat : Filter.Tendsto (fun M : ℕ => (1 : ℝ) / M) Filter.atTop (𝓝 0) :=
  tendsto_one_div_atTop_nhds_zero_nat

/-- The finite gate converges to the continuum gate `1 - 2/(3s)`. -/
theorem alphaMinM_tendsto (s : ℝ) (hs : 0 < s) :
    Filter.Tendsto (fun M : ℕ => alphaMinM M s) Filter.atTop (𝓝 (alphaMin s)) := by
  have hlim : Filter.Tendsto (fun M : ℕ => 1 - (1 + 1 / (M : ℝ)) * (2 + 1 / M) / (3 * s))
      Filter.atTop (𝓝 (1 - (1 + 0) * (2 + 0) / (3 * s))) :=
    tendsto_const_nhds.sub (((tendsto_const_nhds.add tendsto_inv_nat).mul
      (tendsto_const_nhds.add tendsto_inv_nat)).div_const _)
  have he : alphaMin s = 1 - (1 + 0) * (2 + 0) / (3 * s) := by unfold alphaMin; ring_nf
  rw [he]
  refine hlim.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop 0] with M hM
  have hM' : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  unfold alphaMinM
  field_simp

/-- **Continuum limit of the exact closed form.**  If `W/M → w`, the exact priced speedup
converges to `2 / (3 (1 - α + w))`. -/
theorem pricedSpeedupM_tendsto (α w : ℝ) (hpos : 0 < 1 - α + w) (Wseq : ℕ → ℕ)
    (hlim : Filter.Tendsto (fun M : ℕ => (Wseq M : ℝ) / M) Filter.atTop (𝓝 w)) :
    Filter.Tendsto (fun M : ℕ =>
        ((M : ℝ) + 1) * (2 * M + 1) / (3 * M * ((1 - α) * M + Wseq M + 1)))
      Filter.atTop (𝓝 (pricedSpeedup α w)) := by
  have hnum : Filter.Tendsto (fun M : ℕ => (1 + (1 : ℝ) / M) * (2 + 1 / M)) Filter.atTop
      (𝓝 ((1 + 0) * (2 + 0))) :=
    (tendsto_const_nhds.add tendsto_inv_nat).mul (tendsto_const_nhds.add tendsto_inv_nat)
  have hden : Filter.Tendsto (fun M : ℕ => 3 * ((1 - α) + (Wseq M : ℝ) / M + 1 / M))
      Filter.atTop (𝓝 (3 * ((1 - α) + w + 0))) :=
    ((tendsto_const_nhds.add hlim).add tendsto_inv_nat).const_mul 3
  have hq := hnum.div hden (by simp only [add_zero]; positivity)
  have he : pricedSpeedup α w = (1 + 0) * (2 + 0) / (3 * ((1 - α) + w + 0)) := by
    unfold pricedSpeedup; ring_nf
  rw [he]
  refine hq.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop 0] with M hM
  have hM' : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  simp only [Pi.div_apply]
  rcases eq_or_ne ((1 - α) * M + Wseq M + 1 : ℝ) 0 with hD | hD
  · have : 1 - α + (Wseq M : ℝ) / M + 1 / M = 0 := by
      rw [show 1 - α + (Wseq M : ℝ) / M + 1 / M = ((1 - α) * M + Wseq M + 1) / M by
        field_simp]
      rw [hD, zero_div]
    rw [this, hD]; simp
  · field_simp

/-! ## 6. The Bayes-optimal searcher: a two-sided gate -/

/-- **Universal lower bound on every order.**  Under the hint posterior, every one of the `M!`
orders costs at least the cheaper of the two committed procedures: window first
(`(W + 1 + (1-α)M)/2`) or complement first (`(M - W + 1 + αM)/2`). -/
theorem probeCost_hint_ge (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ)
    (σ : Equiv.Perm (Fin M)) :
    min (((W : ℝ) + 1 + (1 - α) * M) / 2) (((M : ℝ) - W + 1 + α * M) / 2) ≤
      probeCost (hintPosterior M W α) σ := by
  have hW' : (0 : ℝ) < W := by exact_mod_cast hW
  have hMW : (0 : ℝ) < (M : ℝ) - W := by
    have : (W : ℝ) < M := by exact_mod_cast hWM
    linarith
  rw [hintPosterior_eq_twoLevel]
  set a := α / (W : ℝ)
  set b := (1 - α) / ((M : ℝ) - W)
  rcases le_or_gt b a with hab | hab
  · refine (min_le_left _ _).trans ?_
    have hc := misplacement_cost M W hWM.le a b hab σ
    have hcom : probeCost (twoLevel W a b) (Equiv.refl (Fin M)) =
        ((W : ℝ) + 1 + (1 - α) * M) / 2 := by
      rw [← hintedCost_eq M W hW hWM α]; rfl
    have : 0 ≤ (a - b) * (misplaced M W σ : ℝ) := mul_nonneg (by linarith) (by positivity)
    linarith
  · refine (min_le_right _ _).trans ?_
    rw [probeCost_twoLevel]
    set T := windowSlots M W σ
    have hTc : (univ \ T).card = M - W := by
      rw [card_sdiff_of_subset (subset_univ _), card_univ, Fintype.card_fin,
        card_windowSlots M W hWM.le]
    have hU := position_sum_ge M (M - W) (by omega) (univ \ T) hTc
    have hsplit := sum_sdiff (f := fun i : Fin M => (((i : ℕ) : ℝ) + 1)) (subset_univ T)
    rw [sum_all_slots] at hsplit
    have hcast : ((M - W : ℕ) : ℝ) = (M : ℝ) - W := by rw [Nat.cast_sub hWM.le]
    rw [hcast] at hU
    have hcard0 : (0 : ℝ) ≤ (((univ \ T).filter fun i : Fin M => M - W ≤ (i : ℕ)).card : ℝ) :=
      by positivity
    have hTle : ∑ i ∈ T, (((i : ℕ) : ℝ) + 1) ≤
        (M : ℝ) * (M + 1) / 2 - ((M : ℝ) - W) * ((M : ℝ) - W + 1) / 2 := by linarith
    have key : b * ((M : ℝ) * (M + 1) / 2) +
        (a - b) * ((M : ℝ) * (M + 1) / 2 - ((M : ℝ) - W) * ((M : ℝ) - W + 1) / 2) =
        ((M : ℝ) - W + 1 + α * M) / 2 := by
      simp only [a, b]
      field_simp
      ring
    have : (a - b) * ((M : ℝ) * (M + 1) / 2 - ((M : ℝ) - W) * ((M : ℝ) - W + 1) / 2) ≤
        (a - b) * ∑ i ∈ T, (((i : ℕ) : ℝ) + 1) :=
      mul_le_mul_of_nonpos_left hTle (by linarith)
    linarith

/-- **Exact Bayes cost in every regime.**  The Bayes-optimal cost of the hint posterior is
exactly the cheaper of the two committed procedures (window first, complement first):
`optCost = min ((W + 1 + (1-α)M)/2, (M - W + 1 + αM)/2)`. -/
theorem bayes_cost_exact (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ) :
    optCost (hintPosterior M W α) =
      min (((W : ℝ) + 1 + (1 - α) * M) / 2) (((M : ℝ) - W + 1 + α * M) / 2) := by
  obtain ⟨σ₀, -, hσ₀⟩ := exists_mem_eq_inf' (univ_nonempty (α := Equiv.Perm (Fin M)))
    (fun σ => probeCost (hintPosterior M W α) σ)
  refine le_antisymm (le_min ?_ ?_) ?_
  · rw [← hintedCost_eq M W hW hWM α]
    exact inf'_le _ (mem_univ _)
  · have hW' : (0 : ℝ) < W := by exact_mod_cast hW
    have hMW : (0 : ℝ) < (M : ℝ) - W := by
      have : (W : ℝ) < M := by exact_mod_cast hWM
      linarith
    set L := univ \ firstCells M (M - W)
    have hL : L.card = W := by
      rw [card_sdiff_of_subset (subset_univ _), card_univ, Fintype.card_fin,
        card_firstCells M (M - W) (by omega)]
      omega
    obtain ⟨σ, hσ⟩ := exists_order_with_slots M W hWM.le L hL
    refine (inf'_le _ (mem_univ σ)).trans (le_of_eq ?_)
    rw [hintPosterior_eq_twoLevel, probeCost_twoLevel, hσ]
    have hsplit := sum_sdiff (f := fun i : Fin M => (((i : ℕ) : ℝ) + 1))
      (subset_univ (firstCells M (M - W)))
    rw [sum_all_slots, sum_firstCells M (M - W) (by omega), Nat.cast_sub hWM.le] at hsplit
    have hLs : ∑ i ∈ L, (((i : ℕ) : ℝ) + 1) =
        (M : ℝ) * (M + 1) / 2 - ((M : ℝ) - W) * ((M : ℝ) - W + 1) / 2 := by linarith
    rw [hLs]
    field_simp
    ring
  · have := probeCost_hint_ge M W hW hWM α σ₀
    have h : optCost (hintPosterior M W α) = probeCost (hintPosterior M W α) σ₀ := hσ₀
    rw [h]; exact this

/-- **Two-sided Bayes gate.**  Even the Bayes-optimal searcher (best of all `M!` orders) can
reach speedup `s` only if the hint is reliably right (`α > α_min^M(s)`) or reliably wrong
(`1 - α > α_min^M(s)`, i.e. it is a reliable hint for the complementary window). -/
theorem bayes_two_sided_gate (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α s : ℝ) (h0 : 0 ≤ α)
    (h1 : α ≤ 1) (hs : 0 < s) (h : s ≤ minBlind M / optCost (hintPosterior M W α)) :
    alphaMinM M s < α ∨ alphaMinM M s < 1 - α := by
  obtain ⟨σ, -, hσ⟩ := exists_mem_eq_inf' (univ_nonempty (α := Equiv.Perm (Fin M)))
    (fun σ => probeCost (hintPosterior M W α) σ)
  have hopt : optCost (hintPosterior M W α) = probeCost (hintPosterior M W α) σ := hσ
  have hlow := probeCost_hint_ge M W hW hWM α σ
  rw [← hopt] at hlow
  have hM : (0 : ℝ) < M := by exact_mod_cast hW.trans hWM
  have hW' : (0 : ℝ) < W := by exact_mod_cast hW
  have hWM' : (W : ℝ) < M := by exact_mod_cast hWM
  set C := optCost (hintPosterior M W α)
  have hD1 : 0 < ((W : ℝ) + 1 + (1 - α) * M) / 2 := by nlinarith
  have hD2 : 0 < ((M : ℝ) - W + 1 + α * M) / 2 := by nlinarith
  have hC : 0 < C := lt_of_lt_of_le (lt_min hD1 hD2) hlow
  unfold minBlind at h
  rw [le_div_iff₀ hC, le_div_iff₀ (by positivity)] at h
  unfold alphaMinM
  rcases le_total (((W : ℝ) + 1 + (1 - α) * M) / 2) (((M : ℝ) - W + 1 + α * M) / 2) with hm | hm
  · rw [min_eq_left hm] at hlow
    left
    rw [sub_lt_comm, lt_div_iff₀ (by positivity)]
    have k1 : 0 ≤ s * (6 * M) * (C - ((W : ℝ) + 1 + (1 - α) * M) / 2) :=
      mul_nonneg (by positivity) (by linarith)
    have k2 : 0 < s * (3 * M) * ((W : ℝ) + 1) := by positivity
    nlinarith
  · rw [min_eq_right hm] at hlow
    right
    rw [sub_lt_comm, lt_div_iff₀ (by positivity)]
    have k1 : 0 ≤ s * (6 * M) * (C - ((M : ℝ) - W + 1 + α * M) / 2) :=
      mul_nonneg (by positivity) (by linarith)
    have k2 : 0 < s * (3 * M) * ((M : ℝ) - W + 1) := mul_pos (by positivity) (by linarith)
    nlinarith

/-- **The one-sided gate fails for the Bayes searcher.**  At `M = 4, W = 2` a hint that is
*always wrong* (`α = 0`) lets the Bayes-optimal searcher reach speedup `5/4`, although
`α = 0 < α_min^4(5/4) = 1/4`. -/
theorem one_sided_gate_fails_for_bayes :
    (5 / 4 : ℝ) ≤ minBlind 4 / optCost (hintPosterior 4 2 0) ∧ (0 : ℝ) < alphaMinM 4 (5 / 4) := by
  rw [bayes_cost_exact 4 2 (by norm_num) (by norm_num) 0]
  unfold minBlind alphaMinM
  norm_num

/-- **One-sided Bayes gate in the trusted regime.**  When `α ≥ W/M` the Bayes-optimal searcher
*is* the committed one, so its speedup is the closed form and it obeys the one-sided gate. -/
theorem bayes_gate_trusted (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α s : ℝ)
    (hα : (W : ℝ) ≤ α * M) (hα1 : α ≤ 1) (hs : 0 < s)
    (h : s ≤ minBlind M / optCost (hintPosterior M W α)) : alphaMinM M s < α := by
  rw [hintedCost_eq_optCost M W hW hWM α hα] at h
  exact finite_reliability_gate M W hW hWM α s hs hα1 h

/-! ## 7. Conservative pricing: the stipulated cost over-prices every posterior -/

/-- Block reversal: reverse the window `{0,…,W-1}` and, separately, the outside block. -/
def blockRevFun (M W : ℕ) (hWM : W ≤ M) (j : Fin M) : Fin M :=
  if h : (j : ℕ) < W then ⟨W - 1 - j, by omega⟩ else ⟨M + W - 1 - j, by have := j.isLt; omega⟩

lemma blockRevFun_involutive (M W : ℕ) (hWM : W ≤ M) :
    Function.Involutive (blockRevFun M W hWM) := by
  intro j
  have hj := j.isLt
  apply Fin.ext
  unfold blockRevFun
  by_cases h : (j : ℕ) < W
  · rw [dif_pos h, dif_pos (show W - 1 - (j : ℕ) < W by omega)]
    show W - 1 - (W - 1 - (j : ℕ)) = j
    omega
  · rw [dif_neg h, dif_neg (show ¬ (M + W - 1 - (j : ℕ) < W) by omega)]
    show M + W - 1 - (M + W - 1 - (j : ℕ)) = j
    omega

/-- The block-reversal permutation. -/
def blockRev (M W : ℕ) (hWM : W ≤ M) : Equiv.Perm (Fin M) :=
  (blockRevFun_involutive M W hWM).toPerm _

/-- **Pairing identity.**  For *any* weight vector with window mass `α` and total mass `1`,
the window-first scan and its block reversal together cost exactly twice the stipulated
two-number cost `(W + 1 + (1-α) M) / 2`. -/
theorem refl_add_blockRev (M W : ℕ) (hWM : W ≤ M) (q : Fin M → ℝ) (α : ℝ)
    (hα : ∑ j ∈ firstCells M W, q j = α) (htot : ∑ j, q j = 1) :
    probeCost q (Equiv.refl (Fin M)) + probeCost q (blockRev M W hWM) =
      (W : ℝ) + 1 + (1 - α) * M := by
  unfold probeCost
  have hre : ∑ i : Fin M, (((i : ℕ) : ℝ) + 1) * q (blockRev M W hWM i) =
      ∑ i : Fin M, ((((blockRev M W hWM i : Fin M) : ℕ) : ℝ) + 1) * q i := by
    have := Equiv.sum_comp (blockRev M W hWM)
      (fun i => ((((blockRev M W hWM i : Fin M) : ℕ) : ℝ) + 1) * q i)
    rw [← this]
    refine sum_congr rfl fun i _ => ?_
    simp only [blockRev, Function.Involutive.coe_toPerm, blockRevFun_involutive M W hWM i]
  rw [hre, ← sum_add_distrib]
  have hpt : ∀ i : Fin M, (((i : ℕ) : ℝ) + 1) * q ((Equiv.refl (Fin M)) i) +
      ((((blockRev M W hWM i : Fin M) : ℕ) : ℝ) + 1) * q i =
      ((W : ℝ) + 1 + (if (i : ℕ) < W then 0 else (M : ℝ))) * q i := by
    intro i
    simp only [blockRev, Function.Involutive.coe_toPerm, blockRevFun, Equiv.refl_apply]
    split_ifs with h
    · rw [Nat.cast_sub (by omega), Nat.cast_sub (by omega)]; push_cast; ring
    · rw [Nat.cast_sub (by omega), Nat.cast_sub (by omega)]; push_cast; ring
  rw [sum_congr rfl fun i _ => hpt i]
  have hsplit : ∀ c : ℝ, ∑ i : Fin M, (c + (if (i : ℕ) < W then 0 else (M : ℝ))) * q i =
      c * ∑ i, q i + (M : ℝ) * (∑ i, q i - ∑ j ∈ firstCells M W, q j) := by
    intro c
    have hp : ∀ i : Fin M, (c + (if (i : ℕ) < W then 0 else (M : ℝ))) * q i =
        c * q i + (M : ℝ) * (q i - if (i : ℕ) < W then q i else 0) := by
      intro i; split_ifs <;> ring
    rw [sum_congr rfl fun i _ => hp i, sum_add_distrib, ← mul_sum, ← mul_sum, sum_sub_distrib,
      firstCells, sum_filter]
  rw [hsplit, htot, hα]
  ring

/-- **Conservative pricing (cost form).**  For *every* weight vector with window mass `α`
and total mass `1` — uniform, prior-proportional, or anything else — the Bayes-optimal cost is
at most the stipulated two-number cost `(W + 1 + (1-α) M) / 2`. -/
theorem optCost_le_stipulated (M W : ℕ) (hWM : W ≤ M) (q : Fin M → ℝ) (α : ℝ)
    (hα : ∑ j ∈ firstCells M W, q j = α) (htot : ∑ j, q j = 1) :
    optCost q ≤ ((W : ℝ) + 1 + (1 - α) * M) / 2 := by
  have hpair := refl_add_blockRev M W hWM q α hα htot
  have h1 : optCost q ≤ probeCost q (Equiv.refl (Fin M)) := inf'_le _ (mem_univ _)
  have h2 : optCost q ≤ probeCost q (blockRev M W hWM) := inf'_le _ (mem_univ _)
  linarith

/-- **Conservative pricing (speedup form).**  Under any calibrated nonnegative posterior with
window mass `α`, the true Bayes speedup over the min-law blind scan is at least the stipulated
closed form `S_M(W, α)`: the stipulated pricing can only *understate* the oracle's value. -/
theorem conservative_pricing (M W : ℕ) (hW : 0 < W) (hWM : W < M) (q : Fin M → ℝ)
    (hq : ∀ j, 0 ≤ q j) (α : ℝ) (hα : ∑ j ∈ firstCells M W, q j = α) (htot : ∑ j, q j = 1) :
    pricedSpeedupM M W α ≤ minBlind M / optCost q := by
  have hopt := optCost_le_stipulated M W hWM.le q α hα htot
  have h1 := IntervalHintsCalibrationGate.one_le_optCost q hq htot
  have hM : (0 : ℝ) < M := by exact_mod_cast hW.trans hWM
  unfold pricedSpeedupM
  rw [hintedCost_eq M W hW hWM]
  exact div_le_div_of_nonneg_left (by unfold minBlind; positivity) (by linarith) hopt

end IntervalHintsCrossingLaw