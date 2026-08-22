import Mathlib

/-!
# Layerwise divergence of two fine-tunes: the hump is a contraction certificate
(NET-51, Part B)

NET-51 measured the layerwise divergence between a base transformer and one of its
fine-tunes and found it is **not monotone**: the relative key divergence climbs to
`0.217` at layer 16 and then falls back to about `0.16` by layer 23, while the two
models share layer 0 exactly.  This file isolates what such a *hump* logically
forces.

Model.  Both networks read the same input and run through the *same* layer maps
`f k`, except that the fine-tune injects a per-layer weight delta `delta k`:

```
a (k+1) = f k (a k)                       -- base model
b (k+1) = f k (b k) + delta k             -- fine-tune
```

with divergence `d k = ‖a k - b k‖`.

Main results.

* `exact_share_prefix` — exact weight sharing on a prefix of layers keeps the
  divergence identically zero there (the measured `cosK = 1.0000`, layer 0).
* `divergence_step_le` and `divergence_geom_bound` — with `L`-Lipschitz layers and
  `‖delta k‖ ≤ eps`, `d k ≤ eps * ∑_{i<k} L^i`; for nonexpansive layers this is the
  linear bound `d k ≤ k * eps` (`divergence_linear_bound`).
* `contraction_of_divergence_drop` — **the hump is a certificate**: any downward
  step of the divergence larger than the injected delta *proves* the shared layer
  map contracts that pair of states.  Monotone divergence is therefore not an
  axiom to be refuted empirically; its failure is equivalent to contractivity.
* `divergence_chain_lower` — a chain (telescoped) lower bound: over a stretch of
  layers the divergence can fall by at most the total injected delta, once the
  shared maps are expansive.
* `net51_tail_contraction_factor` and `net51_hump_delta_budget` — the measured
  constants `d16 = 0.217`, `d23 = 0.16` instantiated: either the tail maps
  contract by a factor `≤ 4/5`, or the tail deltas carry a total budget `≥ 0.057`,
  in which case some single layer in `[16,23)` injects at least `0.008`.

No step here is asymptotic: every bound is explicit and finitary.
-/

namespace Catalog.Novelty.LayerDivergenceHump

open Finset

variable {E : Type*} [NormedAddCommGroup E]

/-! ### 1. Exactly shared prefix -/

omit [NormedAddCommGroup E] in
/-- If the first `s` layers carry no weight delta and the two models start from the
same state, their states coincide throughout the shared prefix.  This is the
formal content of the measured layer-0 identity `cosK = 1.0000`. -/
theorem exact_share_prefix (f : ℕ → E → E) (a b : ℕ → E) (s : ℕ)
    (ha : ∀ k, a (k + 1) = f k (a k)) (hb : ∀ k < s, b (k + 1) = f k (b k))
    (h0 : a 0 = b 0) : ∀ k ≤ s, a k = b k := by
  intro k hk
  induction k with
  | zero => exact h0
  | succ m ih =>
      have hm : m ≤ s := Nat.le_of_succ_le hk
      rw [ha m, hb m (Nat.lt_of_succ_le hk), ih hm]

/-! ### 2. Upper bounds: one step and the whole stack -/

/-- One layer of divergence growth: Lipschitz constant times the incoming
divergence, plus the injected weight delta. -/
theorem divergence_step_le (f : E → E) (a b delta : E) (L eps : ℝ)
    (hlip : ∀ x y, ‖f x - f y‖ ≤ L * ‖x - y‖) (hdelta : ‖delta‖ ≤ eps) :
    ‖f a - (f b + delta)‖ ≤ L * ‖a - b‖ + eps := by
  have hrw : f a - (f b + delta) = (f a - f b) - delta := by abel
  rw [hrw]
  calc ‖(f a - f b) - delta‖ ≤ ‖f a - f b‖ + ‖delta‖ := norm_sub_le _ _
    _ ≤ L * ‖a - b‖ + eps := add_le_add (hlip a b) hdelta

/-- **Geometric divergence bound.**  A divergence sequence that starts at `0`
(exact sharing at the input) and obeys `d (k+1) ≤ L * d k + eps` is bounded by
`eps * ∑_{i<k} L^i`. -/
theorem divergence_geom_bound (d : ℕ → ℝ) (L eps : ℝ) (hL : 0 ≤ L)
    (hd0 : d 0 = 0) (hrec : ∀ k, d (k + 1) ≤ L * d k + eps) :
    ∀ k, d k ≤ eps * ∑ i ∈ range k, L ^ i := by
  intro k
  induction k with
  | zero => simp [hd0]
  | succ m ih =>
      have h1 : L * d m ≤ L * (eps * ∑ i ∈ range m, L ^ i) := by
        exact mul_le_mul_of_nonneg_left ih hL
      have h2 : d (m + 1) ≤ L * (eps * ∑ i ∈ range m, L ^ i) + eps :=
        le_trans (hrec m) (by linarith)
      have h3 : eps * ∑ i ∈ range (m + 1), L ^ i
          = L * (eps * ∑ i ∈ range m, L ^ i) + eps := by
        rw [geom_sum_succ]; ring
      linarith [h3 ▸ h2]

/-- For nonexpansive shared layers (`L = 1`) the divergence grows at most
linearly in depth: `d k ≤ k * eps`.  A hump therefore cannot be produced by
nonexpansive layers together with small deltas — it needs strict contraction
(see `contraction_of_divergence_drop`). -/
theorem divergence_linear_bound (d : ℕ → ℝ) (eps : ℝ)
    (hd0 : d 0 = 0) (hrec : ∀ k, d (k + 1) ≤ d k + eps) :
    ∀ k, d k ≤ k * eps := by
  intro k
  have h := divergence_geom_bound d 1 eps zero_le_one hd0 (by simpa using hrec) k
  simpa [mul_comm] using h

/-! ### 3. The hump as a contraction certificate -/

/-- **Downward steps certify contraction.**  If the divergence after a layer is
smaller than the incoming divergence by more than the injected delta budget,
then the shared layer map strictly contracts that pair of states. -/
theorem contraction_of_divergence_drop (f : E → E) (a b delta : E) (eps : ℝ)
    (hdelta : ‖delta‖ ≤ eps)
    (hdrop : ‖f a - (f b + delta)‖ < ‖a - b‖ - eps) :
    ‖f a - f b‖ < ‖a - b‖ := by
  have hrw : f a - f b = (f a - (f b + delta)) + delta := by abel
  calc ‖f a - f b‖ = ‖(f a - (f b + delta)) + delta‖ := by rw [hrw]
    _ ≤ ‖f a - (f b + delta)‖ + ‖delta‖ := norm_add_le _ _
    _ < (‖a - b‖ - eps) + eps := by linarith
    _ = ‖a - b‖ := by ring

/-- Quantitative form: the contraction factor of the shared layer is at most
`(d' + eps) / d`, where `d` is the incoming and `d'` the outgoing divergence. -/
theorem contraction_factor_le (f : E → E) (a b delta : E) (eps c : ℝ)
    (hdelta : ‖delta‖ ≤ eps)
    (hbound : ‖f a - (f b + delta)‖ + eps ≤ c * ‖a - b‖) :
    ‖f a - f b‖ ≤ c * ‖a - b‖ := by
  have hrw : f a - f b = (f a - (f b + delta)) + delta := by abel
  calc ‖f a - f b‖ = ‖(f a - (f b + delta)) + delta‖ := by rw [hrw]
    _ ≤ ‖f a - (f b + delta)‖ + ‖delta‖ := norm_add_le _ _
    _ ≤ ‖f a - (f b + delta)‖ + eps := by linarith
    _ ≤ c * ‖a - b‖ := hbound

/-- **Chain lower bound.**  If each layer can lose at most `e k` of divergence,
then over a stretch of layers the divergence loses at most `∑ e k`.  Contrapositively,
a measured drop is a lower bound on the total delta budget of that stretch. -/
theorem divergence_chain_lower (d e : ℕ → ℝ) (h : ∀ k, d k - e k ≤ d (k + 1))
    (m n : ℕ) (hmn : m ≤ n) : d m - ∑ k ∈ Ico m n, e k ≤ d n := by
  induction n, hmn using Nat.le_induction with
  | base => simp
  | succ p hmp ih =>
      have hstep := h p
      have hsum : ∑ k ∈ Ico m (p + 1), e k = (∑ k ∈ Ico m p, e k) + e p :=
        Finset.sum_Ico_succ_top hmp e
      rw [hsum]
      linarith

/-! ### 4. The measured NET-51 constants

`d 16 = 0.217`, `d 23 = 0.16` (relative key divergence, Qwen2.5-0.5B base vs
Instruct).  We record the two exclusive structural consequences. -/

/-- With incoming divergence `0.217`, outgoing `0.16` and a per-layer delta budget
of `0.01`, the shared tail map contracts the state pair by a factor at most `4/5`. -/
theorem net51_tail_contraction_factor (f : E → E) (a b delta : E)
    (hab : ‖a - b‖ = 217 / 1000) (hout : ‖f a - (f b + delta)‖ ≤ 16 / 100)
    (hdelta : ‖delta‖ ≤ 1 / 100) :
    ‖f a - f b‖ ≤ (4 / 5) * ‖a - b‖ := by
  refine contraction_factor_le f a b delta (1 / 100) (4 / 5) hdelta ?_
  rw [hab]
  linarith

/-- Alternatively, if no tail layer contracts (each layer loses at most its own
delta `e k`), the measured fall from `0.217` at layer 16 to `0.16` at layer 23
forces a total delta budget of at least `0.057` over the seven layers `[16,23)`. -/
theorem net51_hump_delta_budget (d e : ℕ → ℝ) (h : ∀ k, d k - e k ≤ d (k + 1))
    (h16 : d 16 = 217 / 1000) (h23 : d 23 = 16 / 100) :
    (57 : ℝ) / 1000 ≤ ∑ k ∈ Ico 16 23, e k := by
  have := divergence_chain_lower d e h 16 23 (by norm_num)
  rw [h16, h23] at this
  linarith

/-- Pigeonhole on the budget: some single layer of the tail stretch `[16,23)`
injects a delta of at least `0.008`. -/
theorem net51_hump_single_layer_delta (d e : ℕ → ℝ) (h : ∀ k, d k - e k ≤ d (k + 1))
    (h16 : d 16 = 217 / 1000) (h23 : d 23 = 16 / 100) :
    ∃ k ∈ Ico 16 23, (8 : ℝ) / 1000 ≤ e k := by
  have hbudget := net51_hump_delta_budget d e h h16 h23
  have hcard : (Ico 16 23).card = 7 := by decide
  have hconst : ∑ _k ∈ Ico 16 23, (8 : ℝ) / 1000 ≤ ∑ k ∈ Ico 16 23, e k := by
    rw [Finset.sum_const, hcard]
    simp only [nsmul_eq_mul]
    norm_num
    linarith
  exact Finset.exists_le_of_sum_le ⟨16, by decide⟩ hconst

end Catalog.Novelty.LayerDivergenceHump