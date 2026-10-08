import Novelty.TropicalMaslovMarginBridge
import Novelty.AttentionRetentionKnee

/-!
# The tropical limit is lossy, but the recovery is fast (NET-50)

NET-50 pushed the oracle top-`k` attention sweep of NET-49 down to the tropical
(argmax) limit on Qwen2.5-0.5B and measured, per layer, the **Maslov gap**
`lse x - max x` of the causal scores and the **crystallization loss**
`∑ pᵢ (1 - pᵢ)` of the softmax.  This file turns the measured quantities into
theorems relating them, building on `TropicalMaslovMarginBridge` (`lse`,
`maslovGap`) and `AttentionRetentionKnee` (`retained`, `knee`).

1. **Gap = min-entropy.**  `softmax_eq_exp_neg_gap`: the softmax weight of any key
   is `exp (-(gap))`.  At the argmax this is the mass an argmax (`k = 1`) cache
   keeps.
2. **The Rényi sandwich.**  `collision_le_exp_neg_gap`,
   `exp_neg_two_gap_le_collision`, `crystallization_sandwich`: with `g` the
   Maslov gap at the argmax,
   `1 - e^{-g} ≤ ∑ p(1-p) ≤ 1 - e^{-2g}`.
   `crystallization_gt_quarter_of_gap`: any row with gap `> 1/3` nat has
   crystallization loss `> 1/4`.  This explains the refutation of P3 by the gap map
   (bulk medians up to 1.86 nats).
3. **Truncation in the log domain.**  `lse_sub_lseOn`: dropping every key outside
   `S` lowers `lse` by exactly `-log (mass S)`.
4. **Key-count lower bounds.**  `card_ge_of_mass_gap` (`#S ≥ τ e^{g}`) and
   `card_ge_of_mass_collision` (`#S ≥ τ² / ∑ p²`), and their versions for the
   catalog `knee`: `knee_ge_of_max_weight`, `knee_ge_of_collision`.
5. **Tropical core + thin soft correction.**  `truncation_loss_le_of_margin`: if
   every dropped key is at least `m` below every kept key, the lost mass is at
   most `(n-k)/k · e^{-m}`.
6. **Argmax gets worse with context.**  `argmaxFloor_antitone`,
   `argmaxFloor_tendsto_zero`, `softmax_max_ge_argmaxFloor`: at a fixed margin the
   guaranteed argmax mass `1/(1+(n-1)e^{-m})` decreases in `n` and goes to `0`.
7. **The measured recovery is not a mass curve.**  `retained_two_mul_le`: a
   sorted attention-mass curve satisfies `R(2k) ≤ 2 R(k)`.  The measured NET-50
   curve more than doubles from `k = 1` to `k = 2` at every context
   (`net50_recovery_not_attention_mass`),
   so the measured retention is a nonlinear readout of the kept mass.
   `prod_one_sub_ge` / `prod_one_sub_le_exp` bound a layer-compounded readout in
   both directions.
-/

namespace Catalog.Novelty.TropicalLimitRecovery

open Finset
open Catalog.Novelty.TropicalMaslovMarginBridge
open Catalog.Novelty.AttentionRetentionKnee

variable {n : ℕ}

/-! ### 1. Softmax and the Maslov gap -/

/-- Softmax attention weights of a score row. -/
noncomputable def softmax (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (x i) / ∑ j, Real.exp (x j)

theorem softmax_pos (x : Fin n → ℝ) (i : Fin n) : 0 < softmax x i :=
  div_pos (Real.exp_pos _) (sum_exp_pos x i)

theorem sum_softmax (x : Fin n → ℝ) (i : Fin n) : ∑ j, softmax x j = 1 := by
  unfold softmax
  rw [← Finset.sum_div, div_self (sum_exp_pos x i).ne']

/-- **Gap = min-entropy.**  The softmax weight of a key is `exp` of minus its
Maslov gap.  At the argmax this is exactly the mass kept by an argmax cache. -/
theorem softmax_eq_exp_neg_gap (x : Fin n → ℝ) (i : Fin n) :
    softmax x i = Real.exp (-(maslovGap x i)) := by
  have hZ := sum_exp_pos x i
  simp only [softmax, maslovGap, lse]
  rw [neg_sub, Real.exp_sub, Real.exp_log hZ]

theorem softmax_le_of_le (x : Fin n → ℝ) {i j : Fin n} (h : x j ≤ x i) :
    softmax x j ≤ softmax x i :=
  div_le_div_of_nonneg_right (Real.exp_le_exp.2 h) (sum_exp_pos x i).le

/-! ### 2. Collision, crystallization and the Rényi sandwich -/

/-- Collision probability `∑ pᵢ²` (exponential of minus the Rényi-2 entropy). -/
noncomputable def collision (x : Fin n → ℝ) : ℝ := ∑ i, softmax x i ^ 2

/-- Crystallization loss `∑ pᵢ (1 - pᵢ)`, as measured in NET-50. -/
noncomputable def crystallization (x : Fin n → ℝ) : ℝ :=
  ∑ i, softmax x i * (1 - softmax x i)

theorem crystallization_eq (x : Fin n → ℝ) (i : Fin n) :
    crystallization x = 1 - collision x := by
  unfold crystallization collision
  simp only [mul_sub, mul_one, Finset.sum_sub_distrib, sq]
  rw [sum_softmax x i]

/-- Rényi-2 entropy is at least min-entropy: `∑ p² ≤ p_max = e^{-g}`. -/
theorem collision_le_exp_neg_gap (x : Fin n → ℝ) (i : Fin n) (hmax : ∀ j, x j ≤ x i) :
    collision x ≤ Real.exp (-(maslovGap x i)) := by
  rw [← softmax_eq_exp_neg_gap]
  calc collision x = ∑ j, softmax x j * softmax x j := by simp [collision, sq]
    _ ≤ ∑ j, softmax x j * softmax x i :=
        Finset.sum_le_sum fun j _ =>
          mul_le_mul_of_nonneg_left (softmax_le_of_le x (hmax j)) (softmax_pos x j).le
    _ = softmax x i := by rw [← Finset.sum_mul, sum_softmax x i, one_mul]

/-- Rényi-2 entropy is at most twice min-entropy: `e^{-2g} = p_max² ≤ ∑ p²`. -/
theorem exp_neg_two_gap_le_collision (x : Fin n → ℝ) (i : Fin n) :
    Real.exp (-(2 * maslovGap x i)) ≤ collision x := by
  have h : Real.exp (-(2 * maslovGap x i)) = softmax x i ^ 2 := by
    rw [softmax_eq_exp_neg_gap, ← Real.exp_nat_mul]
    ring_nf
  rw [h]
  exact Finset.single_le_sum (f := fun j => softmax x j ^ 2)
    (fun j _ => sq_nonneg _) (mem_univ i)

/-- **The crystallization sandwich.**  With `g` the Maslov gap at the argmax,
`1 - e^{-g} ≤ ∑ p(1-p) ≤ 1 - e^{-2g}`. -/
theorem crystallization_sandwich (x : Fin n → ℝ) (i : Fin n) (hmax : ∀ j, x j ≤ x i) :
    1 - Real.exp (-(maslovGap x i)) ≤ crystallization x ∧
      crystallization x ≤ 1 - Real.exp (-(2 * maslovGap x i)) := by
  rw [crystallization_eq x i]
  exact ⟨by linarith [collision_le_exp_neg_gap x i hmax],
    by linarith [exp_neg_two_gap_le_collision x i]⟩

/-- **Why P3 failed.**  A row whose Maslov gap exceeds `1/3` nat has
crystallization loss above `1/4`. -/
theorem crystallization_gt_quarter_of_gap (x : Fin n → ℝ) (i : Fin n)
    (hmax : ∀ j, x j ≤ x i) (hg : 1 / 3 < maslovGap x i) :
    1 / 4 < crystallization x := by
  have h1 := (crystallization_sandwich x i hmax).1
  have hlog : Real.log (4 / 3) ≤ 1 / 3 := by
    have := Real.log_le_sub_one_of_pos (show (0 : ℝ) < 4 / 3 by norm_num)
    linarith
  have h2 : Real.exp (-(maslovGap x i)) < 3 / 4 := by
    have : -(maslovGap x i) < Real.log (3 / 4) := by
      have h34 : Real.log (3 / 4) = -Real.log (4 / 3) := by
        rw [show (3 : ℝ) / 4 = (4 / 3)⁻¹ by norm_num, Real.log_inv]
      rw [h34]; linarith
    calc Real.exp (-(maslovGap x i)) < Real.exp (Real.log (3 / 4)) := Real.exp_lt_exp.2 this
      _ = 3 / 4 := Real.exp_log (by norm_num)
  linarith

/-- Contrapositive: P3's crystallization budget `≤ 1/4` forces the row to be
sharply tropical, with gap at most `log (4/3) < 0.29` nat. -/
theorem gap_le_of_crystallization_le_quarter (x : Fin n → ℝ) (i : Fin n)
    (hmax : ∀ j, x j ≤ x i) (hc : crystallization x ≤ 1 / 4) :
    maslovGap x i ≤ Real.log (4 / 3) := by
  have h1 := (crystallization_sandwich x i hmax).1
  have h2 : 3 / 4 ≤ Real.exp (-(maslovGap x i)) := by linarith
  have h3 := Real.log_le_log (by norm_num) h2
  rw [Real.log_exp] at h3
  have h34 : Real.log (3 / 4) = -Real.log (4 / 3) := by
    rw [show (3 : ℝ) / 4 = (4 / 3)⁻¹ by norm_num, Real.log_inv]
  linarith

/-- **The lower half of the sandwich is sharp**: on a flat (maximally diffuse)
row, crystallization equals `1 - e^{-g}` exactly. -/
theorem crystallization_flat (x : Fin n → ℝ) (i : Fin n) (hflat : ∀ j, x j = x i) :
    crystallization x = 1 - Real.exp (-(maslovGap x i)) := by
  have hs : ∀ j, softmax x j = softmax x i := fun j => by simp [softmax, hflat j]
  have hcoll : collision x = softmax x i := by
    calc collision x = ∑ j, softmax x j * softmax x i := by
          simp only [collision, sq]; exact Finset.sum_congr rfl fun j _ => by rw [hs j]
      _ = softmax x i := by rw [← Finset.sum_mul, sum_softmax x i, one_mul]
  rw [crystallization_eq x i, hcoll, softmax_eq_exp_neg_gap]

/-! ### 3. Truncation in the log domain -/

/-- Softmax mass kept by a key set `S`. -/
noncomputable def mass (x : Fin n → ℝ) (S : Finset (Fin n)) : ℝ := ∑ j ∈ S, softmax x j

/-- `lse` restricted to the kept keys `S`. -/
noncomputable def lseOn (x : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  Real.log (∑ j ∈ S, Real.exp (x j))

theorem mass_eq (x : Fin n → ℝ) (S : Finset (Fin n)) :
    mass x S = (∑ j ∈ S, Real.exp (x j)) / ∑ j, Real.exp (x j) := by
  unfold mass softmax
  rw [Finset.sum_div]

/-- **Truncation costs exactly `-log (kept mass)` in the log domain.**  The
argmax cache (`S = {i}`) gives back the Maslov gap itself. -/
theorem lse_sub_lseOn (x : Fin n → ℝ) {S : Finset (Fin n)} (hS : S.Nonempty) :
    lse x - lseOn x S = -Real.log (mass x S) := by
  obtain ⟨i, hi⟩ := hS
  have hA : 0 < ∑ j ∈ S, Real.exp (x j) :=
    Finset.sum_pos (fun j _ => Real.exp_pos _) ⟨i, hi⟩
  rw [mass_eq, Real.log_div hA.ne' (sum_exp_pos x i).ne']
  simp only [lse, lseOn]
  ring

theorem mass_singleton (x : Fin n → ℝ) (i : Fin n) :
    mass x {i} = Real.exp (-(maslovGap x i)) := by
  simp [mass, softmax_eq_exp_neg_gap]

/-! ### 4. How many keys a retention target needs -/

/-- Each kept key carries at most the argmax weight `e^{-g}`. -/
theorem mass_le_card_mul (x : Fin n → ℝ) (i : Fin n) (hmax : ∀ j, x j ≤ x i)
    (S : Finset (Fin n)) : mass x S ≤ S.card * Real.exp (-(maslovGap x i)) := by
  rw [← softmax_eq_exp_neg_gap]
  calc mass x S ≤ ∑ _j ∈ S, softmax x i :=
        Finset.sum_le_sum fun j _ => softmax_le_of_le x (hmax j)
    _ = S.card * softmax x i := by rw [Finset.sum_const, nsmul_eq_mul]

/-- **Gap lower bound on the key count.**  Retaining mass `τ` needs at least
`τ e^{g}` keys. -/
theorem card_ge_of_mass_gap (x : Fin n → ℝ) (i : Fin n) (hmax : ∀ j, x j ≤ x i)
    (S : Finset (Fin n)) {tau : ℝ} (hS : tau ≤ mass x S) :
    tau * Real.exp (maslovGap x i) ≤ S.card := by
  have h := le_trans hS (mass_le_card_mul x i hmax S)
  have he : Real.exp (-(maslovGap x i)) * Real.exp (maslovGap x i) = 1 := by
    rw [← Real.exp_add]; simp
  have hpos := Real.exp_pos (maslovGap x i)
  calc tau * Real.exp (maslovGap x i)
      ≤ S.card * Real.exp (-(maslovGap x i)) * Real.exp (maslovGap x i) :=
        mul_le_mul_of_nonneg_right h hpos.le
    _ = S.card := by rw [mul_assoc, he, mul_one]

/-- **Collision lower bound on the key count** (Cauchy–Schwarz):
`(mass S)² ≤ #S · ∑ p²`. -/
theorem mass_sq_le_card_mul_collision (x : Fin n → ℝ) (S : Finset (Fin n)) :
    mass x S ^ 2 ≤ S.card * collision x := by
  calc mass x S ^ 2 ≤ S.card * ∑ j ∈ S, softmax x j ^ 2 := sq_sum_le_card_mul_sum_sq
    _ ≤ S.card * collision x := by
        apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg _)
        exact Finset.sum_le_sum_of_subset_of_nonneg (subset_univ S)
          (fun j _ _ => sq_nonneg _)

theorem card_ge_of_mass_collision (x : Fin n → ℝ) (i : Fin n)
    (S : Finset (Fin n)) {tau : ℝ} (htau : 0 ≤ tau) (hS : tau ≤ mass x S) :
    tau ^ 2 / collision x ≤ S.card := by
  have hc : 0 < collision x :=
    lt_of_lt_of_le (Real.exp_pos _) (exp_neg_two_gap_le_collision x i)
  rw [div_le_iff₀ hc]
  exact le_trans (pow_le_pow_left₀ htau hS 2) (mass_sq_le_card_mul_collision x S)

/-- The same bound phrased with the measured quantity: retaining `τ` needs at
least `τ² / (1 - crystallization)` keys. -/
theorem card_ge_of_mass_crystallization (x : Fin n → ℝ) (i : Fin n)
    (S : Finset (Fin n)) {tau : ℝ} (htau : 0 ≤ tau) (hS : tau ≤ mass x S) :
    tau ^ 2 / (1 - crystallization x) ≤ S.card := by
  rw [crystallization_eq x i, sub_sub_cancel]
  exact card_ge_of_mass_collision x i S htau hS

/-- Catalog-`knee` version of the gap bound: if no key of a sorted profile has
weight above `q`, the knee at `τ` is at least `τ / q`. -/
theorem knee_ge_of_max_weight {p : ℕ → ℝ} {q tau : ℝ} (hq : 0 < q)
    (hmax : ∀ i, p i ≤ q) (h : ∃ k, tau ≤ retained p k) :
    tau / q ≤ knee p tau := by
  have h1 := knee_spec h
  have h2 : retained p (knee p tau) ≤ knee p tau * q := by
    unfold retained
    calc ∑ i ∈ range (knee p tau), p i ≤ ∑ _i ∈ range (knee p tau), q :=
          Finset.sum_le_sum fun i _ => hmax i
      _ = knee p tau * q := by rw [Finset.sum_const, card_range, nsmul_eq_mul]
  rw [div_le_iff₀ hq]
  linarith

/-- Catalog-`knee` version of the collision bound. -/
theorem knee_ge_of_collision {p : ℕ → ℝ} {C tau : ℝ} (hC : 0 < C) (htau : 0 ≤ tau)
    (hcoll : ∀ k, ∑ i ∈ range k, p i ^ 2 ≤ C) (h : ∃ k, tau ≤ retained p k) :
    tau ^ 2 / C ≤ knee p tau := by
  have h1 := knee_spec h
  set K := knee p tau
  have h2 : retained p K ^ 2 ≤ K * C := by
    unfold retained
    calc (∑ i ∈ range K, p i) ^ 2 ≤ (range K).card * ∑ i ∈ range K, p i ^ 2 :=
          sq_sum_le_card_mul_sum_sq
      _ ≤ K * C := by
          rw [card_range]
          exact mul_le_mul_of_nonneg_left (hcoll K) (Nat.cast_nonneg _)
  rw [div_le_iff₀ hC]
  exact le_trans (pow_le_pow_left₀ htau h1 2) h2

/-- **Calibration with the gap map.**  For the 2048-token diffuse tail
(L22 median gap `2.69` nats), any profile with top weight at most `e^{-2.69}`
needs at least 13 keys for 98% retained mass. -/
theorem net50_tail_gap_forces_13_keys {p : ℕ → ℝ}
    (hmax : ∀ i, p i ≤ Real.exp (-2.69)) (h : ∃ k, (0.98 : ℝ) ≤ retained p k) :
    13 ≤ knee p 0.98 := by
  have hk := knee_ge_of_max_weight (Real.exp_pos _) hmax h
  have hq : (0.98 : ℝ) / Real.exp (-2.69) = 0.98 * Real.exp 2.69 := by
    rw [Real.exp_neg, div_inv_eq_mul]
  have he : (1.8986 : ℝ) ≤ Real.exp 0.6725 := by
    have := Real.quadratic_le_exp_of_nonneg (show (0 : ℝ) ≤ 0.6725 by norm_num)
    norm_num at this ⊢; linarith
  have he4 : Real.exp 2.69 = Real.exp 0.6725 ^ 4 := by
    rw [← Real.exp_nat_mul]; norm_num
  have hlow : (12 : ℝ) < 0.98 * Real.exp 2.69 := by
    rw [he4]
    have : (1.8986 : ℝ) ^ 4 ≤ Real.exp 0.6725 ^ 4 := pow_le_pow_left₀ (by norm_num) he 4
    nlinarith
  rw [hq] at hk
  have : (12 : ℝ) < knee p 0.98 := lt_of_lt_of_le hlow hk
  exact_mod_cast this

/-- **Calibration with the crystallization map.**  A profile with
crystallization at least `0.97` (collision at most `0.03`, the most diffuse
measured layer mean) needs at least 33 keys for 98% retained mass. -/
theorem net50_crystallization_forces_33_keys {p : ℕ → ℝ}
    (hcoll : ∀ k, ∑ i ∈ range k, p i ^ 2 ≤ 0.03) (h : ∃ k, (0.98 : ℝ) ≤ retained p k) :
    33 ≤ knee p 0.98 := by
  have hk := knee_ge_of_collision (by norm_num) (by norm_num) hcoll h
  have : (32 : ℝ) < knee p 0.98 := lt_of_lt_of_le (by norm_num) hk
  exact_mod_cast this

/-! ### 5. Tropical core + thin soft correction -/

/-- **Truncation loss under a margin.**  If every dropped key is at least `m`
below every kept key of a nonempty set `S`, the dropped mass is at most
`(n - #S)/#S · e^{-m}`. -/
theorem truncation_loss_le_of_margin (x : Fin n → ℝ) (S : Finset (Fin n)) (hS : S.Nonempty)
    (m : ℝ) (hm : ∀ j ∉ S, ∀ s ∈ S, x j + m ≤ x s) :
    1 - mass x S ≤ (Sᶜ.card : ℝ) * Real.exp (-m) / S.card := by
  obtain ⟨i, hi⟩ := hS
  set A := ∑ j ∈ S, Real.exp (x j)
  set B := ∑ j ∈ Sᶜ, Real.exp (x j)
  have hA : 0 < A := Finset.sum_pos (fun j _ => Real.exp_pos _) ⟨i, hi⟩
  have hB : 0 ≤ B := Finset.sum_nonneg fun j _ => (Real.exp_pos _).le
  have hZ : ∑ j, Real.exp (x j) = A + B := (Finset.sum_add_sum_compl S _).symm
  have hk : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.2 ⟨i, hi⟩
  have havg : ∀ j ∉ S, (S.card : ℝ) * Real.exp (x j) ≤ Real.exp (-m) * A := by
    intro j hj
    calc (S.card : ℝ) * Real.exp (x j) = ∑ _s ∈ S, Real.exp (x j) := by
          rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ∑ s ∈ S, Real.exp (-m) * Real.exp (x s) := by
          apply Finset.sum_le_sum
          intro s hs
          rw [← Real.exp_add]
          exact Real.exp_le_exp.2 (by linarith [hm j hj s hs])
      _ = Real.exp (-m) * A := by rw [Finset.mul_sum]
  have hkB : (S.card : ℝ) * B ≤ Sᶜ.card * (Real.exp (-m) * A) := by
    calc (S.card : ℝ) * B = ∑ j ∈ Sᶜ, (S.card : ℝ) * Real.exp (x j) := by rw [Finset.mul_sum]
      _ ≤ ∑ _j ∈ Sᶜ, Real.exp (-m) * A :=
          Finset.sum_le_sum fun j hj => havg j (Finset.mem_compl.1 hj)
      _ = Sᶜ.card * (Real.exp (-m) * A) := by rw [Finset.sum_const, nsmul_eq_mul]
  have hloss : 1 - mass x S = B / (A + B) := by
    rw [mass_eq, hZ]; field_simp; ring
  rw [hloss, div_le_div_iff₀ (by linarith) hk]
  have hc : 0 ≤ (Sᶜ.card : ℝ) * Real.exp (-m) :=
    mul_nonneg (Nat.cast_nonneg _) (Real.exp_pos _).le
  nlinarith

/-! ### 6. Argmax gets worse with context -/

/-- The argmax mass guaranteed by a top margin `m` in a context of `n` keys. -/
noncomputable def argmaxFloor (m : ℝ) (n : ℕ) : ℝ := 1 / (1 + ((n : ℝ) - 1) * Real.exp (-m))

/-- A margin `m` guarantees argmax mass at least `argmaxFloor m n`. -/
theorem softmax_max_ge_argmaxFloor (x : Fin n → ℝ) (i : Fin n) (m : ℝ)
    (hm : ∀ j, j ≠ i → m ≤ x i - x j) : argmaxFloor m n ≤ softmax x i := by
  have hg := maslovGap_le_of_margin x i m hm
  have hn : (1 : ℝ) ≤ n := by exact_mod_cast Fin.pos i
  have hpos : 0 < 1 + ((n : ℝ) - 1) * Real.exp (-m) := by
    have : 0 ≤ ((n : ℝ) - 1) * Real.exp (-m) := mul_nonneg (by linarith) (Real.exp_pos _).le
    linarith
  rw [softmax_eq_exp_neg_gap, argmaxFloor, one_div, ← Real.exp_log hpos, ← Real.exp_neg]
  exact Real.exp_le_exp.2 (by linarith)

/-- **P1, structurally.**  At a fixed margin the guaranteed argmax mass decreases
with the context length (for nonempty contexts). -/
theorem argmaxFloor_antitone (m : ℝ) {a b : ℕ} (ha : 1 ≤ a) (hab : a ≤ b) :
    argmaxFloor m b ≤ argmaxFloor m a := by
  have ha1 : (1 : ℝ) ≤ a := by exact_mod_cast ha
  have hab' : (a : ℝ) ≤ b := by exact_mod_cast hab
  have he := Real.exp_pos (-m)
  unfold argmaxFloor
  apply one_div_le_one_div_of_le
  · nlinarith
  · nlinarith

/-- In the long-context limit the argmax guarantee vanishes for every margin. -/
theorem argmaxFloor_tendsto_zero (m : ℝ) :
    Filter.Tendsto (argmaxFloor m) Filter.atTop (nhds 0) := by
  have h : Filter.Tendsto (fun n : ℕ => 1 + ((n : ℝ) - 1) * Real.exp (-m))
      Filter.atTop Filter.atTop := by
    apply Filter.tendsto_atTop_add_const_left
    apply Filter.Tendsto.atTop_mul_const (Real.exp_pos _)
    simp only [sub_eq_add_neg]
    exact Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop
  have hf : argmaxFloor m = fun n : ℕ => (1 + ((n : ℝ) - 1) * Real.exp (-m))⁻¹ := by
    funext n; simp [argmaxFloor]
  rw [hf]
  exact tendsto_inv_atTop_zero.comp h

/-! ### 7. The measured recovery curve is not an attention-mass curve -/

/-- A sorted (antitone) mass curve at most doubles when the key budget doubles. -/
theorem retained_two_mul_le {p : ℕ → ℝ} (hp : Antitone p) (k : ℕ) :
    retained p (2 * k) ≤ 2 * retained p k := by
  unfold retained
  rw [two_mul, Finset.sum_range_add]
  have : ∑ x ∈ range k, p (k + x) ≤ ∑ x ∈ range k, p x :=
    Finset.sum_le_sum fun x _ => hp (Nat.le_add_left x k)
  linarith

/-- Any curve whose second key more than doubles the first is not a sorted mass
curve. -/
theorem not_mass_curve_of_superdoubling {a b : ℝ} (hab : 2 * a < b) :
    ¬ ∃ p : ℕ → ℝ, Antitone p ∧ retained p 1 = a ∧ retained p 2 = b := by
  rintro ⟨p, hp, h1, h2⟩
  have := retained_two_mul_le hp 1
  rw [show 2 * 1 = 2 from rfl, h1, h2] at this
  linarith

/-- **NET-50's measured `k = 1 → 2` recovery is too fast to be kept attention
mass**: at all three contexts `R(2) > 2 R(1)` (ratios 2.16, 2.56, 2.80), which no
sorted mass curve allows. -/
theorem net50_recovery_not_attention_mass :
    (¬ ∃ p : ℕ → ℝ, Antitone p ∧ retained p 1 = 0.3637 ∧ retained p 2 = 0.7865) ∧
    (¬ ∃ p : ℕ → ℝ, Antitone p ∧ retained p 1 = 0.2885 ∧ retained p 2 = 0.7398) ∧
    (¬ ∃ p : ℕ → ℝ, Antitone p ∧ retained p 1 = 0.2503 ∧ retained p 2 = 0.7002) :=
  ⟨not_mass_curve_of_superdoubling (by norm_num),
    not_mass_curve_of_superdoubling (by norm_num),
    not_mass_curve_of_superdoubling (by norm_num)⟩

/-- Weierstrass product inequality: a readout compounding per-layer retentions
`1 - εₗ` keeps at least `1 - ∑ εₗ`. -/
theorem prod_one_sub_ge (eps : ℕ → ℝ) (h0 : ∀ l, 0 ≤ eps l) (h1 : ∀ l, eps l ≤ 1) (L : ℕ) :
    1 - ∑ l ∈ range L, eps l ≤ ∏ l ∈ range L, (1 - eps l) := by
  induction L with
  | zero => simp
  | succ L ih =>
    rw [Finset.sum_range_succ, Finset.prod_range_succ]
    have hP : 0 ≤ ∏ l ∈ range L, (1 - eps l) :=
      Finset.prod_nonneg fun l _ => by linarith [h1 l]
    have hS : 0 ≤ ∑ l ∈ range L, eps l := Finset.sum_nonneg fun l _ => h0 l
    nlinarith [h0 L, h1 L]

/-- And at most `exp (-∑ εₗ)`. -/
theorem prod_one_sub_le_exp (eps : ℕ → ℝ) (h1 : ∀ l, eps l ≤ 1) (L : ℕ) :
    ∏ l ∈ range L, (1 - eps l) ≤ Real.exp (-∑ l ∈ range L, eps l) := by
  rw [← Finset.sum_neg_distrib, Real.exp_sum]
  apply Finset.prod_le_prod
  · intro l _; linarith [h1 l]
  · intro l _; linarith [Real.add_one_le_exp (-eps l)]

/-- **Compounded argmax budget.**  If the compounded readout of the argmax cache
is `0.2503` (NET-50, 2048 tokens), the total per-layer loss lies between
`0.7497` and `log (1/0.2503) < 1.39` nats. -/
theorem net50_argmax_total_layer_loss (eps : ℕ → ℝ) (h0 : ∀ l, 0 ≤ eps l)
    (h1 : ∀ l, eps l ≤ 1) (L : ℕ) (hR : ∏ l ∈ range L, (1 - eps l) = 0.2503) :
    0.7497 ≤ ∑ l ∈ range L, eps l ∧ ∑ l ∈ range L, eps l ≤ Real.log (1 / 0.2503) := by
  constructor
  · have := prod_one_sub_ge eps h0 h1 L
    rw [hR] at this; linarith
  · have h := prod_one_sub_le_exp eps h1 L
    rw [hR] at h
    have h' := Real.log_le_log (by norm_num) h
    rw [Real.log_exp] at h'
    rw [one_div, Real.log_inv]
    linarith

end Catalog.Novelty.TropicalLimitRecovery